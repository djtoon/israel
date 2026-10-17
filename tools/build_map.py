#!/usr/bin/env python3
"""
build_map.py -- generates game/data/map.json for "Civilization: Israel".

Re-runnable. Downloads (once, cached in tools/map_cache/) public geodata:
  * Elevation + bathymetry: Mapzen/AWS "Terrarium" terrain tiles, zoom 10
    (s3.amazonaws.com/elevation-tiles-prod; SRTM 3" on land, ETOPO1/GEBCO at sea).
  * Coastline, country polygons, Green Line / West Bank / Gaza / Golan / UNDOF /
    East Jerusalem / Latrun polygons, lakes: Natural Earth 1:10m v5
    (admin_0_countries, admin_0_disputed_areas, lakes).
  * Rivers and wadis: OpenStreetMap (waterway=river, via Overpass API), ODbL.
  * Annual precipitation: WorldClim 2.1 BIO12, 2.5 arc-minute (Fick & Hijmans 2017).

Usage:
  python tools/build_map.py                 # build map.json + debug PNG
  python tools/build_map.py --desc first    # name of the debug shot
  python tools/build_map.py --no-shot       # json only

Projection: equirectangular about lat 31.45N (km = deg * 94.97 E-W, * 110.86 N-S).
Grid: pointy-top hexes, odd-r offset (odd rows shifted right by half a hex);
tile (0,0) centre = origin (lat 33.45, lon 34.15); x grows east, y (row) grows south.
hex_km = distance between neighbouring hex centres (= flat-to-flat width).
"""
import argparse, io, json, math, os, re, struct, sys, zlib, hashlib, datetime
from concurrent.futures import ThreadPoolExecutor

import numpy as np
import requests
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import shapely
from shapely.geometry import shape, box, Point, LineString, MultiLineString
from shapely.ops import unary_union
from scipy import ndimage

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CACHE = os.path.join(ROOT, "tools", "map_cache")
OUT_JSON = os.path.join(ROOT, "game", "data", "map.json")
SHOTS = os.path.join(ROOT, "progress", "shots")
LOG = os.path.join(ROOT, "progress", "log.jsonl")
REF = os.path.join(ROOT, "ref", "israel_map.webp")

# ----------------------------------------------------------------------------- extent / grid
LAT_N, LAT_S = 33.45, 29.30
LON_W, LON_E = 34.15, 36.05
LAT_C = 31.45
KX = 111.320 * math.cos(math.radians(LAT_C))   # km per degree longitude
KY = 110.86                                      # km per degree latitude (~31.5N)
HEX_KM = 3.5
ROW_KM = HEX_KM * math.sqrt(3) / 2
W_KM = (LON_E - LON_W) * KX
H_KM = (LAT_N - LAT_S) * KY
COLS = int(W_KM // HEX_KM) + 1
ROWS = int(H_KM // ROW_KM) + 1
RES = 0.25                                       # analysis raster, km per pixel
PAD = 4.0                                        # km padding of the raster around the grid
UA = {"User-Agent": "civ-israel-mapbuilder/1.0", "Accept": "*/*"}


def ll2xy(lat, lon):
    return (np.asarray(lon) - LON_W) * KX, (LAT_N - np.asarray(lat)) * KY


def xy2ll(x, y):
    return LAT_N - np.asarray(y) / KY, LON_W + np.asarray(x) / KX


def hex_center(q, r):
    return HEX_KM * (q + 0.5 * (r & 1)), ROW_KM * r


def xy2hex(x, y):
    """vectorised km -> (col,row) odd-r"""
    size = HEX_KM / math.sqrt(3)
    qa = (math.sqrt(3) / 3 * x - y / 3) / size
    ra = (2 / 3 * y) / size
    xa, za = qa, ra
    ya = -xa - za
    rx, ry, rz = np.round(xa), np.round(ya), np.round(za)
    dx, dy, dz = np.abs(rx - xa), np.abs(ry - ya), np.abs(rz - za)
    m1 = (dx > dy) & (dx > dz)
    rx = np.where(m1, -ry - rz, rx)
    m2 = ~m1 & (dy > dz)
    ry = np.where(m2, -rx - rz, ry)
    rz = np.where(~m1 & ~m2, -rx - ry, rz)
    row = rz.astype(int)
    col = rx.astype(int) + (row - (row & 1)) // 2
    return col, row


def neighbors(q, r):
    if r & 1:
        d = [(1, 0), (-1, 0), (1, -1), (0, -1), (1, 1), (0, 1)]
    else:
        d = [(1, 0), (-1, 0), (0, -1), (-1, -1), (0, 1), (-1, 1)]
    for dq, dr in d:
        nq, nr = q + dq, r + dr
        if 0 <= nq < COLS and 0 <= nr < ROWS:
            yield nq, nr


def hex_corners(cx, cy, s=1.0):
    rad = HEX_KM / math.sqrt(3) * s
    return [(cx + rad * math.cos(math.radians(60 * i - 30)), cy + rad * math.sin(math.radians(60 * i - 30))) for i in range(6)]


def hsh(*a):
    """deterministic pseudo-random in [0,1)"""
    h = hashlib.md5(("|".join(map(str, a))).encode()).hexdigest()
    return int(h[:8], 16) / 2 ** 32

# ----------------------------------------------------------------------------- downloads (cached)

def fetch(url, path, **kw):
    if os.path.exists(path) and os.path.getsize(path) > 0:
        return path
    os.makedirs(os.path.dirname(path), exist_ok=True)
    r = requests.get(url, headers=UA, timeout=300, **kw)
    r.raise_for_status()
    with open(path + ".part", "wb") as f:
        f.write(r.content)
    os.replace(path + ".part", path)
    return path


NE_BASE = "https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/"


def load_ne(name):
    p = fetch(NE_BASE + name + ".geojson", os.path.join(CACHE, "ne", name + ".geojson"))
    with open(p, encoding="utf-8") as f:
        return json.load(f)["features"]


def load_osm_rivers():
    p = os.path.join(CACHE, "osm", "rivers.json")
    if not os.path.exists(p):
        q = '[out:json][timeout:150];way["waterway"="river"](29.4,34.1,33.5,36.1);out geom tags;'
        os.makedirs(os.path.dirname(p), exist_ok=True)
        r = requests.post("https://overpass-api.de/api/interpreter", data={"data": q},
                          headers={**UA, "Accept": "application/json"}, timeout=300)
        r.raise_for_status()
        open(p, "wb").write(r.content)
    with open(p, encoding="utf-8") as f:
        return json.load(f)["elements"]


def overpass(query, path):
    """cached Overpass query; retries a few times because the public server is often busy"""
    if not os.path.exists(path):
        import time
        os.makedirs(os.path.dirname(path), exist_ok=True)
        last = None
        for attempt in range(6):
            try:
                r = requests.post("https://overpass-api.de/api/interpreter", data={"data": query},
                                  headers={**UA, "Accept": "application/json"}, timeout=300)
                if r.ok and r.content.lstrip()[:1] == b"{":
                    json.loads(r.content)
                    open(path, "wb").write(r.content)
                    break
                last = r.text[:200]
            except Exception as ex:      # noqa: BLE001
                last = str(ex)
            time.sleep(30)
        else:
            raise RuntimeError(f"Overpass failed for {path}: {last}")
    with open(path, encoding="utf-8") as f:
        return json.load(f)["elements"]


def load_arava_border():
    """Israel-Jordan land boundary south of the Dead Sea from OSM (Jordan admin_level=2 relation members). OSM follows
    the 1994 treaty line (Annex I); Natural Earth 10m puts it ~2 km too far west at Eilat (34.957E vs the Yitzhak Rabin
    crossing at 34.978E). Returns a south->north list of (lon, lat)."""
    q = ('[out:json][timeout:200];rel["ISO3166-1"="JO"]["admin_level"="2"];'
         'way(r)(29.45,34.85,31.25,35.7);out geom tags;')
    ways = [e for e in overpass(q, os.path.join(CACHE, "osm", "border_il_jo.json"))
            if e.get("tags", {}).get("maritime") != "yes" and len(e.get("geometry", [])) >= 2]
    segs = [[(p["lon"], p["lat"]) for p in e["geometry"]] for e in ways]
    # chain the segments greedily from the southernmost endpoint
    segs = [sg if sg[0][1] <= sg[-1][1] else sg[::-1] for sg in segs]
    segs.sort(key=lambda sg: sg[0][1])
    line = list(segs.pop(0))
    while segs:
        end = line[-1]
        j = min(range(len(segs)), key=lambda i: (segs[i][0][0] - end[0]) ** 2 + (segs[i][0][1] - end[1]) ** 2)
        line += segs.pop(j)[1:]
    return line


def load_osm_streams():
    q = '[out:json][timeout:250];way["waterway"="stream"]["name"](29.3,34.1,33.5,36.1);out geom tags;'
    p = os.path.join(CACHE, "osm", "streams.json")
    if not os.path.exists(p) and os.environ.get("MAP_SKIP_STREAMS"):
        return []
    try:
        return overpass(q, p)
    except RuntimeError as ex:
        print("WARNING: no OSM streams:", ex)
        return []


DEM_Z = 10


def tile_xy(lat, lon, z):
    n = 2 ** z
    x = (lon + 180) / 360 * n
    y = (1 - math.asinh(math.tan(math.radians(lat))) / math.pi) / 2 * n
    return x, y


def load_dem():
    """returns (array elevation m, x0, y0) in global terrarium pixel space at DEM_Z"""
    lat0, lon0 = LAT_N + 0.15, LON_W - 0.15
    lat1, lon1 = LAT_S - 0.15, LON_E + 0.15
    tx0, ty0 = [int(v) for v in tile_xy(lat0, lon0, DEM_Z)]
    tx1, ty1 = [int(v) for v in tile_xy(lat1, lon1, DEM_Z)]
    jobs = [(x, y) for y in range(ty0, ty1 + 1) for x in range(tx0, tx1 + 1)]

    def get(xy):
        x, y = xy
        return fetch(f"https://s3.amazonaws.com/elevation-tiles-prod/terrarium/{DEM_Z}/{x}/{y}.png",
                     os.path.join(CACHE, "terrarium", str(DEM_Z), f"{x}_{y}.png"))
    with ThreadPoolExecutor(8) as ex:
        paths = list(ex.map(get, jobs))
    W, H = (tx1 - tx0 + 1) * 256, (ty1 - ty0 + 1) * 256
    dem = np.zeros((H, W), np.float32)
    for (x, y), p in zip(jobs, paths):
        a = np.asarray(Image.open(p).convert("RGB"), np.float32)
        e = a[..., 0] * 256 + a[..., 1] + a[..., 2] / 256 - 32768
        dem[(y - ty0) * 256:(y - ty0 + 1) * 256, (x - tx0) * 256:(x - tx0 + 1) * 256] = e
    return dem, tx0 * 256, ty0 * 256


WC_URL = "https://geodata.ucdavis.edu/climate/worldclim/2_1/base/wc2.1_2.5m_bio.zip"
WC_MEMBER = "wc2.1_2.5m_bio_12.tif"


def load_rain():
    """WorldClim 2.1 BIO12 (annual precipitation, mm), cropped. Pulls one member out of the
    remote zip with HTTP range requests so we don't download 650 MB."""
    p = os.path.join(CACHE, "worldclim", "bio12_crop.npz")
    if not os.path.exists(p):
        import tifffile
        os.makedirs(os.path.dirname(p), exist_ok=True)
        n = int(requests.head(WC_URL, allow_redirects=True, headers=UA).headers["Content-Length"])
        tail = requests.get(WC_URL, headers={**UA, "Range": f"bytes={n - 65536}-{n - 1}"}).content
        i = tail.rfind(b"PK\x05\x06")
        cd_size, cd_off = struct.unpack("<II", tail[i + 12:i + 20])
        cd = requests.get(WC_URL, headers={**UA, "Range": f"bytes={cd_off}-{cd_off + cd_size - 1}"}).content
        pos, ent = 0, None
        while pos < len(cd):
            csz, usz = struct.unpack("<II", cd[pos + 20:pos + 28])
            fl, el, cl = struct.unpack("<HHH", cd[pos + 28:pos + 34])
            off, = struct.unpack("<I", cd[pos + 42:pos + 46])
            name = cd[pos + 46:pos + 46 + fl].decode()
            if name == WC_MEMBER:
                ent = (off, csz)
            pos += 46 + fl + el + cl
        off, csz = ent
        hdr = requests.get(WC_URL, headers={**UA, "Range": f"bytes={off}-{off + 29}"}).content
        fl, el = struct.unpack("<HH", hdr[26:30])
        start = off + 30 + fl + el
        raw = requests.get(WC_URL, headers={**UA, "Range": f"bytes={start}-{start + csz - 1}"}, timeout=600).content
        tif = zlib.decompress(raw, -15)
        arr = tifffile.imread(io.BytesIO(tif))          # 4320 x 8640, 1/24 deg, top-left (-180, 90)
        r0, r1 = int((90 - (LAT_N + 0.5)) * 24), int((90 - (LAT_S - 0.5)) * 24)
        c0, c1 = int((LON_W - 0.5 + 180) * 24), int((LON_E + 0.5 + 180) * 24)
        np.savez_compressed(p, a=arr[r0:r1, c0:c1].astype(np.float32), r0=r0, c0=c0)
    z = np.load(p)
    return z["a"], int(z["r0"]), int(z["c0"])


# Long-term annual rainfall normals (mm), Israel Meteorological Service and Jordanian/Egyptian station
# climatologies, rounded. Used to correct WorldClim's 2.5' smoothing, which spreads the steep rain shadow.
RAIN_STATIONS = [
    ("Tel Aviv", 32.08, 34.78, 530), ("Haifa", 32.80, 35.00, 580), ("Zefat", 32.96, 35.50, 680),
    ("Tiberias", 32.79, 35.53, 410), ("Beit She'an", 32.50, 35.50, 300), ("Jerusalem", 31.78, 35.22, 550),
    ("Hebron", 31.53, 35.10, 560), ("Gaza", 31.52, 34.45, 390), ("Beersheba", 31.25, 34.80, 200),
    ("Arad", 31.25, 35.21, 150), ("Dimona", 31.07, 35.03, 90), ("Sde Boker", 30.87, 34.79, 90),
    ("Mitzpe Ramon", 30.61, 34.80, 90), ("Yotvata", 29.89, 35.06, 30), ("Eilat", 29.55, 34.95, 25),
    ("Aqaba", 29.53, 35.00, 30), ("Sodom", 31.03, 35.39, 50), ("Ein Gedi", 31.46, 35.39, 70),
    ("Jericho", 31.86, 35.46, 160), ("Amman", 31.95, 35.93, 270), ("El Arish", 31.13, 33.80, 100),
]


def calibrate_rain(RAIN, ELEV, LAT, LON):
    """1) Lee-side correction: east of the Judean/Samarian watershed rainfall falls off within ~15 km
    (Jerusalem 550 mm -> Ein Gedi 70 mm), which a 4.6 km grid blurs. Scale rain by the drop below the
    highest ground within 15 km to the west (only south of ~32.3N, where that rain shadow exists).
    2) Station calibration: Gaussian-weighted (sigma 10 km) log-ratio of station normal / gridded value,
    blended back to no correction away from stations."""
    win = int(15 / RES)
    westmax = ndimage.maximum_filter1d(ELEV, size=win + 1, axis=1, origin=win // 2, mode="nearest")
    lee = np.clip(westmax - ELEV, 0, None)
    f = np.clip(1 - lee / 1400.0, 0.25, 1.0)
    w = np.clip((32.35 - LAT) / 0.4, 0, 1)
    R = RAIN * (1 - w * (1 - f))
    X, Y = ll2xy(LAT, LON)
    num = np.zeros_like(R)
    den = np.full_like(R, 0.3)
    for name, la, lo, mm in RAIN_STATIONS:
        sx, sy = ll2xy(la, lo)
        iy = int(np.clip((sy + PAD) / RES, 0, R.shape[0] - 1))
        ix = int(np.clip((sx + PAD) / RES, 0, R.shape[1] - 1))
        g = R[max(0, iy - 2):iy + 3, max(0, ix - 2):ix + 3].mean() if (0 <= sx + PAD < R.shape[1] * RES) else None
        if g is None or not np.isfinite(g) or g <= 0:
            continue
        wt = np.exp(-((X - sx) ** 2 + (Y - sy) ** 2) / (2 * 10.0 ** 2))
        num += wt * np.log(mm / g)
        den += wt
    return R * np.exp(num / den)


def bilinear(a, fy, fx):
    fy = np.clip(fy, 0, a.shape[0] - 1.001)
    fx = np.clip(fx, 0, a.shape[1] - 1.001)
    y0, x0 = np.floor(fy).astype(int), np.floor(fx).astype(int)
    dy, dx = fy - y0, fx - x0
    return (a[y0, x0] * (1 - dy) * (1 - dx) + a[y0 + 1, x0] * dy * (1 - dx)
            + a[y0, x0 + 1] * (1 - dy) * dx + a[y0 + 1, x0 + 1] * dy * dx)

# ----------------------------------------------------------------------------- hand-authored knowledge
# Region helper polygons (lon,lat). Only used for sub-regions inside Israel / West Bank
# that no admin dataset delimits; boundaries follow standard physiographic descriptions.
CARMEL = [(34.955, 32.84), (35.015, 32.80), (35.07, 32.74), (35.11, 32.67), (35.10, 32.59), (35.00, 32.56), (34.96, 32.62), (34.94, 32.75)]
JEZREEL = [(35.07, 32.73), (35.17, 32.72), (35.30, 32.66), (35.40, 32.62), (35.50, 32.56), (35.50, 32.46), (35.40, 32.47), (35.30, 32.50), (35.20, 32.50), (35.10, 32.58), (35.05, 32.66)]
HULA = [(35.575, 33.035), (35.65, 33.035), (35.655, 33.13), (35.58, 33.13)]   # 1948 lake + swamps
LAKE_HULA = (33.075, 35.612)   # centre of Lake Hula (drained 1951-58)

# landmark places (name, Hebrew, lat, lon, kind)
PLACES = [
    ("Jerusalem Old City", "העיר העתיקה", 31.7767, 35.2345, "holy_site"),
    ("Masada", "מצדה", 31.3157, 35.3536, "heritage"),
    ("Haifa port", "נמל חיפה", 32.8200, 35.0000, "port"),
    ("Dead Sea", "ים המלח", 31.5400, 35.4800, "lake"),
    ("Mount Hermon", "חרמון", 33.4160, 35.8570, "mountain"),
    ("Ramon Crater", "מכתש רמון", 30.5900, 34.8300, "crater"),
    ("Timna", "תמנע", 29.7800, 34.9800, "mine"),
    ("Kinneret", "כנרת", 32.8200, 35.5900, "lake"),
    ("Eilat", "אילת", 29.5580, 34.9520, "port"),
    ("Jaffa port", "נמל יפו", 32.0540, 34.7500, "port"),
    ("Acre Old City", "העיר העתיקה של עכו", 32.9230, 35.0690, "heritage"),
    ("Caesarea", "קיסריה", 32.5000, 34.8920, "heritage"),
    ("Mount Carmel", "הר הכרמל", 32.7300, 35.0500, "mountain"),
    ("Mount Meron", "הר מירון", 32.9980, 35.4100, "mountain"),
    ("Mount Tabor", "הר תבור", 32.6870, 35.3900, "mountain"),
    ("Megiddo", "מגידו", 32.5850, 35.1850, "heritage"),
    ("Hula Valley", "עמק החולה", 33.0800, 35.6100, "wetland"),
    ("Rosh HaNikra", "ראש הנקרה", 33.0850, 35.1100, "nature"),  # just S of the border cliff (NE border is ~1 km coarse)
    ("Banias", "בניאס", 33.2480, 35.6940, "nature"),
    ("Ein Gedi", "עין גדי", 31.4600, 35.3880, "oasis"),
    ("Qumran", "קומראן", 31.7410, 35.4590, "heritage"),
    ("Qasr al-Yahud", "קאסר אל-יהוד", 31.8380, 35.5380, "holy_site"),
    ("Jericho", "יריחו", 31.8710, 35.4440, "heritage"),
    ("Mount Sodom", "הר סדום", 31.0800, 35.3900, "mountain"),
    ("Cave of the Patriarchs", "מערת המכפלה", 31.5247, 35.1107, "holy_site"),
    ("Church of the Nativity", "כנסיית המולד", 31.7043, 35.2077, "holy_site"),
    ("Basilica of the Annunciation", "כנסיית הבשורה", 32.7021, 35.2978, "holy_site"),
    ("Bahá'í Gardens", "הגנים הבהאיים", 32.8144, 34.9870, "holy_site"),
    ("Latrun", "לטרון", 31.8370, 34.9800, "heritage"),
    ("Sde Boker", "שדה בוקר", 30.8740, 34.7930, "heritage"),
    ("Negev Nuclear Research Center", "הקריה למחקר גרעיני", 31.0010, 35.1440, "facility"),
    ("Ashdod port", "נמל אשדוד", 31.8250, 34.6430, "port"),
    ("Gaza port", "נמל עזה", 31.5250, 34.4300, "port"),
    ("Aqaba", "עקבה", 29.5260, 35.0060, "port"),
    ("Petra", "פטרה", 30.3285, 35.4444, "heritage"),
    ("Mount Nebo", "הר נבו", 31.7680, 35.7250, "holy_site"),
    ("Amman Citadel", "מצודת עמאן", 31.9545, 35.9349, "foreign_capital"),
    ("Kadesh Barnea", "קדש ברנע", 30.6500, 34.4200, "oasis"),
    ("Gamla", "גמלא", 32.9040, 35.7400, "heritage"),
]

OASES = [(31.8710, 35.4440), (31.4600, 35.3880), (29.8890, 35.0590), (30.6500, 34.4200), (31.7100, 35.4500), (30.7790, 35.2620),
         (30.8170, 34.7650)]   # Jericho, Ein Gedi, Yotvata, Ein el-Qudeirat, Ein Feshkha, Ein Hatzeva, Ein Avdat
# (lat, lon, resource, reveal, note)  -- point resources placed on the tile that contains them
POINT_RESOURCES = [  # (lat, lon, resource, reveal date (ISO prefix: YYYY, YYYY-MM or YYYY-MM-DD), note, source id)
    (30.9150, 35.0170, "phosphates", None, "Oron (Zafir field, Oron-Zin): Negev Phosphates founded 1952", "negev_phosphates"),
    (30.8650, 35.1350, "phosphates", None, "Zin (Zafir field, Oron-Zin) phosphate mine", "negev_phosphates"),
    (31.0700, 35.1900, "phosphates", None, "Rotem phosphate field (Mishor Rotem)", "negev_phosphates"),
    (31.0400, 35.3900, "potash", None, "Sodom (Sdom): Palestine Potash plant planned 1934; production interrupted in 1948 and resumed 1954 under Dead Sea Works", "dead_sea_works"),
    (31.7500, 35.5100, "potash", None, "Kalia: Palestine Potash bromine (1931) and potash plant, destroyed in 1948", "dead_sea_works"),
    (31.1100, 35.5300, "potash", None, "Ghor al-Safi: Arab Potash Company (established 1956)", "dead_sea_works"),
    (29.7800, 34.9800, "copper", None, "Timna: modern copper mining 1959-1976 and 1980-1985", "timna_copper"),
    (30.6300, 35.4900, "copper", None, "Feinan (Wadi Faynan) ancient copper mines, Jordan", "timna_copper"),
    (30.5850, 34.7900, "gypsum", None, "Makhtesh Ramon gypsum quarry (first worked under the British Mandate)", "negev_minerals"),
    (30.6300, 34.9100, "clay", None, "Makhtesh Ramon clay quarries", "negev_minerals"),
    (31.0800, 35.3900, "salt", None, "Mount Sodom (Sedom) rock-salt diapir", "negev_minerals"),
    (30.9370, 35.3750, "dates", None, "Neot HaKikar / Ein Tamar date groves", "arava_dates"),
    (30.7800, 35.2450, "dates", None, "Hatzeva / Ein Hatzeva date groves", "arava_dates"),
    (29.9700, 35.0600, "dates", None, "Ketura / Yotvata date groves", "arava_dates"),
    (30.6600, 35.2400, "dates", None, "Ein Yahav date groves", "arava_dates"),
    (31.5800, 34.6500, "oil", "1955-09-26", "Heletz: the state's first successful oil well (26 Sep 1955)", "heletz_1955"),
    (33.0780, 33.9510, "natural_gas", "2009-01", "Tamar field (true position ~18 km west of map edge; discovery announced Jan 2009, production from Apr 2013)", "tamar_leviathan"),
    (33.1680, 33.6170, "natural_gas", "2010-12-29", "Leviathan field (true position ~130 km off Haifa, beyond the map edge; discovery announced 29 Dec 2010, production from 31 Dec 2019)", "tamar_leviathan"),
    (31.7000, 34.3500, "natural_gas", "2004", "Mari-B (approx. position, ~25 miles off Ashdod; supplying Israel since 2004)", "yam_tethys_gaza_marine"),
    (31.6000, 34.0500, "natural_gas", "2000", "Gaza Marine (approx. position; discovered 2000)", "yam_tethys_gaza_marine"),
]

# ----------------------------------------------------------------------------- build


def build(args):
    print(f"grid {COLS} x {ROWS} hexes, hex {HEX_KM} km, extent {W_KM:.1f} x {H_KM:.1f} km")
    # -- analysis raster
    gx = np.arange(-PAD, W_KM + PAD, RES) + RES / 2
    gy = np.arange(-PAD, H_KM + PAD, RES) + RES / 2
    XX, YY = np.meshgrid(gx, gy)
    LAT, LON = xy2ll(XX, YY)
    H, W = XX.shape
    print("raster", W, H)

    # elevation
    dem, ox, oy = load_dem()
    n = 2 ** DEM_Z * 256
    mx = (LON + 180) / 360 * n - ox
    my = (1 - np.arcsinh(np.tan(np.radians(LAT))) / np.pi) / 2 * n - oy
    ELEV = bilinear(dem, my, mx)

    # rain
    rain, r0, c0 = load_rain()
    rain = np.where(rain < -1000, np.nan, rain)            # WorldClim nodata over the sea
    nan = np.isnan(rain)
    if nan.any():                                           # fill sea cells from the nearest land cell
        ii = ndimage.distance_transform_edt(nan, return_distances=False, return_indices=True)
        rain = rain[tuple(ii)]
    RAIN = bilinear(rain, (90 - LAT) * 24 - 0.5 - r0, (LON + 180) * 24 - 0.5 - c0)
    RAIN = calibrate_rain(RAIN, ELEV, LAT, LON)

    # vector data
    bb = box(LON_W - 0.3, LAT_S - 0.3, LON_E + 0.3, LAT_N + 0.3)
    countries = {}
    for ft in load_ne("ne_10m_admin_0_countries"):
        g = shape(ft["geometry"])
        if g.intersects(bb):
            countries[ft["properties"]["ADM0_A3"]] = g.intersection(bb)
    disputed = {}
    for ft in load_ne("ne_10m_admin_0_disputed_areas"):
        g = shape(ft["geometry"])
        if g.intersects(bb):
            disputed[ft["properties"]["BRK_NAME"]] = g.intersection(bb)
    lakes = []
    for ft in load_ne("ne_10m_lakes"):
        g = shape(ft["geometry"])
        if g.intersects(bb):
            lakes.append((ft["properties"]["name"], g))
    print("countries", sorted(countries), "disputed", sorted(disputed))

    def rast(geom):
        return shapely.contains_xy(geom, LON, LAT)

    land = rast(unary_union(list(countries.values())))
    # area codes (later codes override earlier)
    AREA = np.zeros((H, W), np.int8)
    codes = ["SEA", "LBN", "SYR", "JOR", "EGY", "SAU", "ISR49", "WB", "GAZA", "EJ", "LATRUN", "NML_JLM", "SCOPUS", "GOLAN", "SHEBAA", "UNDOF", "ISR_OTHER"]
    cid = {c: i for i, c in enumerate(codes)}
    AREA[land] = cid["ISR_OTHER"]
    for a3, code in [("LBN", "LBN"), ("SYR", "SYR"), ("JOR", "JOR"), ("EGY", "EGY"), ("SAU", "SAU")]:
        if a3 in countries:
            AREA[rast(countries[a3])] = cid[code]
    for name, code in [("Israel", "ISR49"), ("West Bank", "WB"), ("Gaza", "GAZA"), ("East Jerusalem", "EJ"),
                       ("No Man's Land (Fort Latrun)", "LATRUN"), ("No Man's Land (Jerusalem)", "NML_JLM"),
                       ("Mount Scopus", "SCOPUS"), ("Golan Heights", "GOLAN"), ("Shebaa Farms", "SHEBAA"),
                       ("UNDOF Zone", "UNDOF")]:
        AREA[rast(disputed[name])] = cid[code]
    # Arava: replace Natural Earth's Israel-Jordan segment with the 1994 treaty line (OSM)
    arava = load_arava_border()
    if arava:
        east = shapely.Polygon(arava + [(36.6, arava[-1][1]), (36.6, arava[0][1])])
        band = (LAT > arava[0][1]) & (LAT < min(arava[-1][1], 31.2)) & (LON > 34.85)
        ineast = rast(east)
        AREA[band & ineast & (AREA == cid["ISR49"])] = cid["JOR"]
        AREA[band & ~ineast & (AREA == cid["JOR"])] = cid["ISR49"]
    AREA[~land] = cid["SEA"]
    # Judea/Samaria watershed: per raster row, the crest of the smoothed DEM between 34.95E and 35.45E
    smo = ndimage.gaussian_filter(ELEV, 6)
    xa, xb = float(ll2xy(31.5, 34.95)[0]), float(ll2xy(31.5, 35.45)[0])
    colm = (gx >= xa) & (gx <= xb)
    WS_X = ndimage.median_filter(gx[colm][np.argmax(smo[:, colm], axis=1)], size=41, mode="nearest")

    LAKE = np.zeros((H, W), np.int8)   # 1 kinneret, 2 dead sea north, 3 dead sea south
    for name, g in lakes:
        m = rast(g)
        if name == "Sea of Galilee":
            LAKE[m] = 1
        elif name == "Dead Sea":
            LAKE[m] = 2 if g.bounds[3] > 31.5 else 3
    # sea = outside NE land polygons; also require it to be connected to the open sea
    sea = ~land & (LAKE == 0)
    lab, _ = ndimage.label(sea)
    keep = set()
    for la, lo in [(32.5, 34.3), (29.47, 34.95)]:
        x, y = ll2xy(la, lo)
        keep.add(lab[int((y + PAD) / RES), int((x + PAD) / RES)])
    SEA = np.isin(lab, list(keep - {0}))
    HULA_M = rast(shapely.Polygon(HULA)) & (ELEV < 85)

    # rivers (OSM)
    rivers = load_osm_rivers()
    PERENNIAL = {"River Jordan": "Jordan", "Nahal Dan": "Jordan", "Hasbani River": "Jordan", "Nahal Snir (Hatsbani)": "Jordan",
                 "Nahal Yarmukh": "Yarmouk", "Yarmuk River": "Yarmouk", "Yarmukh": "Yarmouk",
                 "Nahal Yarkon": "Yarkon", "Nahal Kishon": "Kishon", "Litani River": "Litani", "Zarqa River": "Zarqa"}
    river_lines, wadi_ways = [], []
    for e in rivers:
        t = e.get("tags", {})
        nm = t.get("name:en") or t.get("name", "")
        pts = [(p["lon"], p["lat"]) for p in e.get("geometry", [])]
        if len(pts) < 2:
            continue
        if nm in PERENNIAL:
            river_lines.append((PERENNIAL[nm], pts))
        else:
            wadi_ways.append(e)
    # -- tile assignment of raster pixels
    cq, cr = xy2hex(XX, YY)
    valid = (cq >= 0) & (cq < COLS) & (cr >= 0) & (cr < ROWS)
    tid = np.where(valid, cr * COLS + cq, -1).ravel()
    order = np.argsort(tid, kind="stable")
    tid_sorted = tid[order]
    starts = np.searchsorted(tid_sorted, np.arange(COLS * ROWS))
    ends = np.searchsorted(tid_sorted, np.arange(COLS * ROWS), side="right")

    E, Rn, A, L, S, Hm = ELEV.ravel(), RAIN.ravel(), AREA.ravel(), LAKE.ravel(), SEA.ravel(), HULA_M.ravel()

    # slope (m per km) on the raster
    gyy, gxx = np.gradient(ELEV, RES * 1000)
    SLOPE = (np.hypot(gxx, gyy) * 1000).ravel()          # m per km

    T = {}
    for r in range(ROWS):
        for q in range(COLS):
            k = r * COLS + q
            idx = order[starts[k]:ends[k]]
            x, y = hex_center(q, r)
            lat, lon = xy2ll(x, y)
            e = E[idx]
            sea_f = S[idx].mean()
            lake_v = L[idx]
            lake_f = (lake_v > 0).mean()
            land_idx = idx[(~S[idx]) & (L[idx] == 0)]
            el = E[land_idx] if len(land_idx) else e
            areas = A[land_idx] if (len(land_idx) and lake_f < 0.42) else A[idx]
            lake_major = int(np.bincount(lake_v[lake_v > 0]).argmax()) if lake_f > 0 else 0
            if lake_f >= 0.42 and lake_major == 1:
                areas = np.full(1, cid["ISR49"])   # Kinneret lay wholly inside Israel's 1923/1949 line
            ac = np.bincount(areas[areas > 0], minlength=len(codes)) if (areas > 0).any() else np.zeros(len(codes), int)
            T[(q, r)] = dict(
                q=q, r=r, lat=float(lat), lon=float(lon),
                sea_f=float(sea_f), lake_f=float(lake_f),
                lake_id=lake_major,
                depth=float(np.mean(e[S[idx]])) if sea_f > 0 else 0.0,
                elev=float(np.mean(el)), emax=float(np.max(el)), emin=float(np.min(el)),
                p90=float(np.percentile(el, 90)), p10=float(np.percentile(el, 10)),
                slope=float(np.mean(SLOPE[land_idx])) if len(land_idx) else 0.0,
                rain=float(np.mean(Rn[idx])),
                area=codes[int(ac.argmax())] if ac.sum() else "SEA",
                area_counts={codes[i]: int(c) for i, c in enumerate(ac) if c},
                hula=float(Hm[idx].mean()),
                east_ws=bool(31.15 < lat < 32.45 and lon < 35.57 and x > WS_X[min(len(WS_X) - 1, int((y + PAD) / RES))] + 1.0),
            )
    # Seasonal streams and wadis: OSM waterway=river (non-perennial) + named waterway=stream ways, grouped by their
    # Hebrew name (falling back to English / local / Arabic name) so a wadi whose segments carry different English or
    # Arabic names (Besor -> Wadi Gaza, Paran -> Wadi al-Girafi) stays one continuous named course.
    groups = {}
    for e in wadi_ways + load_osm_streams():
        t = e.get("tags", {})
        pts = [(p["lon"], p["lat"]) for p in e.get("geometry", [])]
        if len(pts) < 2:
            continue
        if t.get("name:he") in BANIAS_HE or t.get("name:ar") in BANIAS_AR:
            river_lines.append(("Banias", pts))           # perennial Jordan source
            continue
        key = t.get("name:he") or t.get("name:en") or t.get("name") or t.get("name:ar")
        if not key:
            continue
        xs, ys = ll2xy([p[1] for p in pts], [p[0] for p in pts])
        ln = float(np.sum(np.hypot(np.diff(xs), np.diff(ys))))
        g = groups.setdefault(key, {"len": 0.0, "names": {}, "lines": []})
        g["len"] += ln
        en = t.get("name:en") or t.get("name") or t.get("name:ar")
        g["names"][en] = g["names"].get(en, 0) + ln
        g["lines"].append(pts)
    streams, big = [], []
    for key, g in groups.items():
        if g["len"] < 20:
            continue
        disp = STREAM_DISPLAY.get(key) or max(g["names"].items(), key=lambda kv: kv[1])[0]
        for pts in g["lines"]:
            streams.append((disp, pts))
            if g["len"] >= 35:
                big.append((disp, pts))
    for la, lo, code, why in TILE_AREA_OVERRIDES:
        xx, yy = ll2xy(la, lo)
        T[tuple(int(v) for v in xy2hex(np.array(xx), np.array(yy)))]["area"] = code
    classify(T, river_lines, big, streams)
    snap_places(T, AREA, codes)
    return T, dict(ELEV=ELEV, RAIN=RAIN, SEA=SEA, LAKE=LAKE, AREA=AREA, codes=codes, gx=gx, gy=gy,
                   river_lines=river_lines, wadi_lines=big, stream_lines=streams, disputed=disputed, countries=countries)


BANIAS_HE = {"נחל חרמון", "נחל בניאס"}
BANIAS_AR = {"نهر بانياس"}
STREAM_DISPLAY = {"נחל הבשור": "Nahal HaBsor / Wadi Gaza", "נחל פארן": "Nahal Paran", "נחל צין": "Nahal Zin",
                  "נחל ערבה": "Nahal Arava"}
TILE_AREA_OVERRIDES = [  # (lat, lon, area code, why)
    (33.2490, 35.6520, "ISR49", "Tel Dan / Dan spring lay inside Mandate Palestine and Israel's 1949 line; the NE polygons "
                               "give the hex majority to the Golan"),
]
# natural wonders: (id, name, name_he, kind, source, polygon (lon,lat) or None, point (lat,lon))
MAKHTESHIM = [
    ("makhtesh_ramon", "Makhtesh Ramon", "מכתש רמון", "crater", "unesco_makhteshim",
     [(34.63, 30.500), (34.70, 30.545), (34.80, 30.592), (34.88, 30.635), (34.95, 30.675), (34.985, 30.662),
      (34.95, 30.612), (34.88, 30.574), (34.80, 30.542), (34.72, 30.512), (34.66, 30.488)], (30.590, 34.820)),
    ("makhtesh_gadol", "HaMakhtesh HaGadol", "המכתש הגדול", "crater", "unesco_makhteshim",
     [(34.915, 30.885), (34.95, 30.900), (35.00, 30.948), (35.025, 30.985), (35.00, 30.992), (34.96, 30.960),
      (34.93, 30.920), (34.905, 30.895)], (30.935, 34.968)),
    ("makhtesh_katan", "HaMakhtesh HaKatan", "המכתש הקטן", "crater", "unesco_makhteshim",
     [(35.155, 30.935), (35.20, 30.935), (35.21, 30.960), (35.195, 30.985), (35.16, 30.980), (35.15, 30.955)],
     (30.957, 35.180)),
]
WONDERS = []
DIRS_EVEN = [(1, 0), (0, -1), (-1, -1), (-1, 0), (-1, 1), (0, 1)]    # E, NE, NW, W, SW, SE (odd-r, even row)
DIRS_ODD = [(1, 0), (1, -1), (0, -1), (-1, 0), (0, 1), (1, 1)]       # E, NE, NW, W, SW, SE (odd row)


def neighbor_dir(q, r, i):
    dq, dr = (DIRS_ODD if r & 1 else DIRS_EVEN)[i]
    nq, nr = q + dq, r + dr
    return (nq, nr) if 0 <= nq < COLS and 0 <= nr < ROWS else None


def landforms(T):
    """Relief pass: makhtesh floors (flat desert ringed by desert_hills and cliffs), prominence mountains, cliff edges,
    natural wonders."""
    WONDERS.clear()
    floor_of = {}
    for wid, name, he, kind, src, poly, (pla, plo) in MAKHTESHIM:
        pg = shapely.Polygon(poly)
        hexes = [k for k, t in T.items() if t["water"] is None and pg.contains(Point(t["lon"], t["lat"]))]
        if not hexes:
            xx, yy = ll2xy(pla, plo)
            hexes = [tuple(int(v) for v in xy2hex(np.array(xx), np.array(yy)))]
        for k in hexes:
            T[k]["terrain"] = "desert"
            T[k]["feature"] = "none"
            floor_of[k] = wid
        for k in hexes:
            for n in neighbors(*k):
                if n not in floor_of and T[n]["water"] is None and T[n]["terrain"] in ("desert", "plains"):
                    T[n]["terrain"] = "desert_hills"
        WONDERS.append(dict(id=wid, name=name, name_he=he, kind=kind, hexes=sorted([list(k) for k in hexes], key=lambda v: (v[1], v[0])),
                            source=src))
    # prominence mountains: local highs standing >= 250 m above their lowest land neighbour
    prom = []
    for k, t in T.items():
        if t["water"] is not None or k in floor_of or t["terrain"] in ("mountains", "marsh"):
            continue
        nb = [T[n]["elev"] for n in neighbors(*k) if T[n]["water"] is None]
        if len(nb) >= 3 and t["elev"] > max(nb) and t["elev"] - min(nb) >= 250:
            prom.append(k)
    for k in prom:
        T[k]["terrain"] = "mountains"
        T[k]["prominent"] = True
    # cliff edges: land-land edges with >= 200 m difference in hex-mean elevation, plus every makhtesh rim edge
    for k, t in T.items():
        t["cliff_edges"] = []
        if t["water"] is not None:
            continue
        for i in range(6):
            n = neighbor_dir(*k, i)
            if n is None or T[n]["water"] is not None:
                continue
            if abs(t["elev"] - T[n]["elev"]) >= 200 or (floor_of.get(k) != floor_of.get(n)):
                t["cliff_edges"].append(i)
    return floor_of


PLACE_TILES = []


def snap_places(T, AREA, codes):
    """Put each landmark on the hex that contains it, unless that hex breaks a rule: a land site must not sit on water,
    a port must be on a coastal land hex, and the hex must belong to the same territory as the site itself
    (e.g. Eilat must not land on a Jordanian hex). In those cases use the nearest hex within two rings that satisfies the rules."""
    PLACE_TILES.clear()
    for name, he, lat, lon, kind in PLACES:
        x, y = ll2xy(lat, lon)
        q0, r0 = [int(v) for v in xy2hex(np.array(x), np.array(y))]
        if not (0 <= q0 < COLS and 0 <= r0 < ROWS):
            continue
        iy, ix = int((y + PAD) / RES), int((x + PAD) / RES)
        a_pt = codes[AREA[iy, ix]]
        if a_pt == "SEA":                       # coastal site whose point falls just offshore: use the nearest land cell
            win = AREA[iy - 10:iy + 11, ix - 10:ix + 11]
            yy, xx = np.nonzero(win != codes.index("SEA"))
            if len(yy):
                j = int(np.argmin((yy - 10) ** 2 + (xx - 10) ** 2))
                a_pt = codes[win[yy[j], xx[j]]]
        ring = {(q0, r0)}
        for _ in range(2):
            ring |= {n for k in ring for n in neighbors(*k)}

        def ok(k):
            t = T[k]
            if kind == "lake":
                return t["terrain"] == "lake"
            if t["water"] is not None:
                return False
            if kind == "port" and not t["coast"]:
                return False
            if a_pt not in ("SEA",) and t["area"] != a_pt:
                return False
            return True
        cands = [k for k in ring if ok(k)] or [(q0, r0)]

        def dist(k):
            cx, cy = hex_center(*k)
            return (cx - x) ** 2 + (cy - y) ** 2
        q, r = (q0, r0) if (q0, r0) in cands else min(cands, key=dist)
        PLACE_TILES.append(dict(name=name, name_he=he, q=q, r=r, kind=kind, lat=lat, lon=lon, source=["places_coords"]))


def tiles_on_line(pts, step_km=0.4):
    out = []
    for (lo0, la0), (lo1, la1) in zip(pts[:-1], pts[1:]):
        x0, y0 = ll2xy(la0, lo0)
        x1, y1 = ll2xy(la1, lo1)
        n = max(1, int(math.hypot(x1 - x0, y1 - y0) / step_km))
        for i in range(n + 1):
            t = i / n
            q, r = xy2hex(np.array(x0 + (x1 - x0) * t), np.array(y0 + (y1 - y0) * t))
            out.append((int(q), int(r)))
    return out


def in_poly(poly, lat, lon):
    return shapely.Polygon(poly).contains(Point(lon, lat))


FORCED = [  # (lat, lon, terrain, why) -- landforms smaller than the DEM averaging can resolve
    (31.0800, 35.3900, "desert_hills", "Mount Sodom: 11 km rock-salt ridge rising ~200 m above the Dead Sea shore"),
]


def classify(T, river_lines, wadi_lines, streams=()):
    # ---- water
    for k, t in T.items():
        t["water"] = None
        if t["lake_f"] >= 0.42:
            t["water"] = "lake"
        elif t["sea_f"] >= 0.5:
            t["water"] = "sea"
    for k, t in T.items():
        if t["water"] == "sea":
            near_land = any(T[n]["water"] is None for n in neighbors(*k))
            t["terrain"] = "coast" if (near_land or t["depth"] > -40) else "ocean"
        elif t["water"] == "lake":
            t["terrain"] = "lake"
    # ---- land terrain
    for k, t in T.items():
        if t["water"]:
            continue
        relief = t["p90"] - t["p10"]
        e, rain = t["elev"], t["rain"]
        lee = t["east_ws"]                     # Judean / Samarian desert slope east of the watershed
        arid = rain < 180 or (lee and rain <= 300)
        if t["hula"] > 0.3:
            ter = "marsh"
        elif (e >= 1150) or (t["emax"] >= 1100 and relief >= 250) or (e >= 650 and relief >= 420) or (relief >= 750):
            ter = "mountains"
        elif e < -50 and relief < 300:          # Jordan rift floor: the Zor badlands don't make a hill hex
            ter = None
        elif relief >= 150 or t["slope"] >= 90 or (e >= 600 and relief >= 60) or (e >= 450 and relief >= 90) \
                or (100 <= e <= 500 and (relief >= 60 or t["slope"] >= 40)) or (arid and relief >= 100):
            ter = "desert_hills" if arid else "hills"
        else:
            ter = None
        if ter is None:
            if arid:
                ter = "desert"
            elif rain >= 430:
                ter = "grassland"
            else:
                ter = "plains"
        if ter == "mountains" and arid and e < 700 and relief < 850:
            ter = "desert_hills"
        t["terrain"] = ter
        t["relief"] = relief
    # intermontane valleys: a non-arid hill-country hex that is nearly flat and sits >= 60 m below its neighbours'
    # mean (Dothan, Sanur, Lubban, Beit Netofa, Hula/Harod margins) reads as farmland, not hills
    for k, t in T.items():
        if t["water"] or t["terrain"] != "hills" or t["relief"] >= 120 or t["elev"] < 150:
            continue
        nb = [T[n]["elev"] for n in neighbors(*k) if T[n]["water"] is None]
        if len(nb) >= 4 and t["elev"] < np.mean(nb) - 60:
            t["terrain"] = "grassland" if t["rain"] >= 430 else "plains"
            t["valley"] = True
    # coastal sands: in 1948 a belt of dunes and kurkar ridges lined the shore south of Haifa (Holot); sea-front
    # hexes there are plains rather than grassland
    for k, t in T.items():
        if t["water"] is None and t["terrain"] == "grassland" and t["lat"] < 32.75 and t["lon"] < 35.0 and t["elev"] < 60                 and any(T[n]["water"] == "sea" for n in neighbors(*k)):
            t["terrain"] = "plains"
    for la, lo, ter, why in FORCED:
        x, y = ll2xy(la, lo)
        k = tuple(int(v) for v in xy2hex(np.array(x), np.array(y)))
        if T[k]["water"] is None:
            T[k]["terrain"] = ter
    # ---- Lake Hula (1948): one lake tile in the middle of the marsh
    x, y = ll2xy(*LAKE_HULA)
    kh = tuple(int(v) for v in xy2hex(np.array(x), np.array(y)))
    T[kh]["terrain"], T[kh]["water"], T[kh]["lake_id"] = "lake", "lake", 4
    for la, lo in OASES:                          # one oasis hex per spring: the land hex nearest to it
        x, y = ll2xy(la, lo)
        q0, r0 = [int(v) for v in xy2hex(np.array(x), np.array(y))]
        cands = [k for k in [(q0, r0)] + list(neighbors(q0, r0)) if T[k]["water"] is None]
        k = (q0, r0) if (q0, r0) in cands else min(cands, key=lambda k: (hex_center(*k)[0] - x) ** 2 + (hex_center(*k)[1] - y) ** 2)
        T[k]["oasis"] = True
        if T[k]["terrain"] in ("desert_hills", "hills", "plains"):
            T[k]["terrain"] = "desert"
    floor_of = landforms(T)
    # ---- coast flag
    for k, t in T.items():
        t["coast"] = (t["water"] is None) and any(T[n]["water"] == "sea" for n in neighbors(*k))
    # ---- rivers
    for k, t in T.items():
        t["river"] = False
        t["river_name"] = None
    for name, pts in river_lines:
        for k in tiles_on_line(pts):
            if k in T and T[k]["water"] is None:
                T[k]["river"] = True
                if T[k]["river_name"] is None or name == "Jordan":   # the Jordan wins at confluences
                    T[k]["river_name"] = name
    for k, t in T.items():
        t["stream"] = None
    for name, pts in streams:
        for k in tiles_on_line(pts):
            if k in T and T[k]["water"] is None and not T[k]["river"] and T[k]["stream"] is None:
                T[k]["stream"] = name
    wadi_tiles = {}
    for name, pts in wadi_lines:
        for k in tiles_on_line(pts):
            if k in T:
                wadi_tiles.setdefault(k, name)
    # ---- regions
    for k, t in T.items():
        t["region"] = region_of(t)
    # ---- features
    for k, t in T.items():
        f = "none"
        lat, lon = t["lat"], t["lon"]
        if t["water"] == "sea" and t["region"] == "Gulf of Aqaba" and t["terrain"] == "coast":
            f = "reef"
        elif t["water"] is None:
            if t.get("oasis"):
                f = "oasis"
            elif k in wadi_tiles and t["rain"] < 320 and not t["river"] and t["terrain"] in ("desert", "desert_hills", "plains"):
                f = "wadi"
            elif t["terrain"] in ("hills", "mountains") and t["rain"] >= 560 and t["elev"] < 1800 and (
                    t["region"] in ("Carmel",) or hsh("forest", *k) < (0.5 if t["region"] in ("Galilee", "Lebanon") else 0.3)):
                f = "forest"
            elif t["region"] == "Carmel" and t["terrain"] == "hills":
                f = "forest"
            elif t["region"] in ("Sharon", "Coastal Plain") and t["terrain"] in ("grassland", "plains") and t["elev"] < 120 \
                    and 31.6 < lat < 32.6 and hsh("orchard", *k) < 0.45:
                f = "orchard"
            elif t["region"] in ("Jordan Valley",) and t["terrain"] != "marsh" and hsh("orchard", *k) < 0.25:
                f = "orchard"
        t["feature"] = f
    # ---- resources
    for k, t in T.items():
        t["resource"] = None
        t["resource_reveal"] = None
        t["resource_note"] = None
        t["resource_source"] = None
    assign_resources(T)
    add_point_wonders(T)
    # ---- historical changes
    for k, t in T.items():
        t["historical_change"] = None
        if (t["terrain"] == "marsh" and t["region"] == "Galilee") or t["lake_id"] == 4:
            t["historical_change"] = {"date": "1958", "to_terrain": "grassland", "source": "hula_drainage",
                                      "note": "Lake Hula and its swamps were drained 1951-1958 by the Jewish National Fund for farmland; "
                                              "a small area was re-flooded as the Agamon Hula wetland in 1994."}
        if t["terrain"] == "lake" and t["lake_id"] == 3:
            t["historical_change"] = {"date": "1990", "to_terrain": "marsh", "source": "dead_sea_level",
                                      "note": "Southern basin of the Dead Sea, connected to the northern basin by a strait in the "
                                              "1973 Landsat image; the strait is dry in the 1990 image and the basin is used for the "
                                              "salt and potash industries' evaporation ponds (USGS). Closest terrain: marsh; the "
                                              "1990 date is the first image showing the change, not the exact year."}


def add_point_wonders(T):
    def hx(la, lo):
        xx, yy = ll2xy(la, lo)
        return tuple(int(v) for v in xy2hex(np.array(xx), np.array(yy)))
    rh = hx(33.0850, 35.1100)
    eg = min((k for k, t in T.items() if t.get("oasis")), key=lambda k: abs(T[k]["lat"] - 31.46) + abs(T[k]["lon"] - 35.388))
    hermon = [k for k, t in T.items() if t["water"] is None and t["elev"] >= 1800]
    dead = [k for k, t in T.items() if t["terrain"] == "lake" and t["lake_id"] == 2]
    timna = hx(29.7880, 34.9890)
    for wid, name, he, kind, src, hexes in [
            ("rosh_hanikra_grottoes", "Rosh HaNikra grottoes", "נקרות ראש הנקרה", "sea_cave", "inpa_reserves", [rh]),
            ("ein_gedi", "Ein Gedi", "עין גדי", "oasis", "inpa_reserves", [eg]),
            ("mount_hermon", "Mount Hermon", "הר החרמון", "mountain", "mount_hermon", hermon),
            ("dead_sea", "Dead Sea", "ים המלח", "lake", "dead_sea_level", dead),
            ("timna_valley", "Timna Valley", "בקעת תמנע", "canyon", "timna_copper", [timna])]:
        WONDERS.append(dict(id=wid, name=name, name_he=he, kind=kind,
                            hexes=sorted([list(k) for k in hexes], key=lambda v: (v[1], v[0])), source=src))


def region_of(t):
    lat, lon, e, a = t["lat"], t["lon"], t["elev"], t["area"]
    if t["water"] == "lake":
        return {1: "Sea of Galilee", 4: "Galilee"}.get(t["lake_id"], "Dead Sea")
    if t["water"] == "sea":
        return "Gulf of Aqaba" if lat < 29.7 and lon > 34.7 else "Mediterranean Sea"
    if a in ("LBN",):
        return "Lebanon"
    if a in ("SYR", "UNDOF"):
        return "Syria"
    if a == "JOR":
        return "Jordan"
    if a == "SAU":
        return "Saudi Arabia"
    if a == "EGY":
        return "Sinai"
    if a in ("GOLAN", "SHEBAA"):
        return "Golan"
    if a == "GAZA":
        return "Gaza Strip"
    # Israel + West Bank: physiographic regions
    if t["hula"] > 0.2 or in_poly(HULA, lat, lon) and e < 150:
        return "Galilee"
    if lat < 31.15 and lon > 34.98 and e < (260 if lat < 30.4 else 60):
        return "Arava"
    if lat < 29.75:
        return "Arava" if e < 150 else "Negev"
    if 31.75 < lat < 32.72 and e < -60 and lon > 35.35:
        return "Jordan Valley"
    if 31.3 <= lat <= 31.95 and lon > 35.2 and (t["rain"] < 260 or e < 0) or (31.1 <= lat < 31.3 and e < -300):
        return "Judean Desert"
    if lat < 31.25 or (lat < 31.5 and t["rain"] < 260 and e < 600) or (lat < 31.45 and lon < 34.7):
        return "Negev"
    if in_poly(CARMEL, lat, lon) and e > 120:
        return "Carmel"
    if in_poly(JEZREEL, lat, lon) and e < 160:
        return "Jezreel Valley"
    if lat >= 32.68:
        if lon < 35.13 and e < 80:
            return "Coastal Plain"
        return "Galilee"
    if lat >= 32.08:
        if e < 90 and lon < 35.02:
            return "Sharon"
        return "Samaria"
    if lat >= 31.95:
        if e < 90 and lon < 34.98:
            return "Coastal Plain"
        return "Samaria"
    # Judea / Shephelah / coastal plain
    if e < 90 and lon < 34.95:
        return "Coastal Plain"
    if e < 380 and lon < 35.1:
        return "Shephelah"
    return "Judea"


FLAT = ("grassland", "plains", "desert")
HILLY = ("hills", "desert_hills")
# region -> list of (resource, weight, terrains or None, note)
REGION_RES = {
    "Sharon": [("citrus", 4, FLAT, "Citrus groves (Jaffa oranges)"), ("cattle", 1, FLAT, None), ("wheat", 1, FLAT, None)],
    "Coastal Plain": [("citrus", 3, FLAT, "Citrus groves (Jaffa oranges)"), ("wheat", 2, FLAT, None), ("cattle", 1, FLAT, None),
                      ("grapes", 1, None, None)],
    "Gaza Strip": [("citrus", 3, FLAT, "Gaza citrus groves"), ("wheat", 1, FLAT, None), ("olives", 1, None, None)],
    "Galilee": [("olives", 4, HILLY, None), ("grapes", 1, HILLY, None), ("sheep", 1, None, None), ("cattle", 1, None, None),
                ("wheat", 2, FLAT, None)],
    "Carmel": [("grapes", 2, None, None), ("olives", 2, None, None)],
    "Jezreel Valley": [("wheat", 3, None, None), ("cattle", 2, None, None)],
    "Samaria": [("olives", 5, HILLY, None), ("grapes", 1, HILLY, None), ("sheep", 1, None, None), ("wheat", 2, FLAT, None)],
    "Judea": [("olives", 3, HILLY, "Terraced olive groves"), ("grapes", 3, HILLY, "Hebron hills vineyards"), ("sheep", 1, None, None),
              ("limestone", 1, HILLY, "Jerusalem stone quarries")],
    "Shephelah": [("wheat", 2, FLAT, None), ("olives", 2, None, None), ("grapes", 1, None, None),
                  ("limestone", 1, HILLY, "Shephelah limestone quarries")],
    "Judean Desert": [("sheep", 2, None, "Bedouin pastoralism"), ("camels", 1, None, "Bedouin pastoralism")],
    "Arava": [("camels", 1, None, "Bedouin pastoralism")],
    "Jordan Valley": [("dates", 3, None, "Date palms"), ("wheat", 1, FLAT, None)],
    "Golan": [("cattle", 3, None, None), ("wheat", 1, FLAT, None), ("sheep", 1, None, None)],
    "Lebanon": [("olives", 2, None, None), ("tobacco", 1, None, "South Lebanon tobacco"), ("sheep", 1, None, None)],
    "Syria": [("wheat", 2, FLAT, None), ("sheep", 1, None, None)],
    "Sinai": [("camels", 1, None, "Bedouin pastoralism")],
    "Saudi Arabia": [("camels", 1, None, None)],
}


def region_options(t):
    reg, ter, lat, rain = t["region"], t["terrain"], t["lat"], t["rain"]
    if ter in ("mountains", "marsh", "ocean", "lake"):
        return []
    if ter == "coast":
        return [("fish", 1, None, None)] if reg in ("Mediterranean Sea", "Gulf of Aqaba") else []
    if reg == "Negev":
        if lat > 31.0 and ter in ("plains", "desert"):
            opts = [("wheat", 2, None, "Northern Negev loess dry-farming"), ("sheep", 2, None, "Bedouin pastoralism"),
                    ("camels", 1, None, "Bedouin pastoralism")]
        else:
            opts = [("camels", 2, None, "Bedouin pastoralism"), ("sheep", 1, None, "Bedouin pastoralism")]
    elif reg == "Jordan":
        if rain > 350:
            opts = [("wheat", 2, FLAT, None), ("olives", 2, None, None), ("sheep", 1, None, None)]
        elif rain > 150:
            opts = [("wheat", 1, FLAT, None), ("sheep", 2, None, None)]
        else:
            opts = [("camels", 1, None, None), ("sheep", 1, None, None)]
    else:
        opts = REGION_RES.get(reg, [])
    return [o for o in opts if o[2] is None or ter in o[2]]


def assign_resources(T):
    def put(k, res, reveal=None, note=None, src=None):
        t = T[k]
        t["resource"], t["resource_reveal"], t["resource_note"], t["resource_source"] = res, reveal, note, src

    # point resources (off-map gas fields are pulled to the westernmost sea tile of their latitude)
    for lat, lon, res, reveal, note, src in POINT_RESOURCES:
        lo = max(lon, LON_W)
        x, y = ll2xy(lat, lo)
        q, r = [int(v) for v in xy2hex(np.array(x), np.array(y))]
        q = max(0, min(COLS - 1, q))
        r = max(0, min(ROWS - 1, r))
        put((q, r), res, reveal, note + ("" if lon >= LON_W else " [placed at map edge]"), src)
    for lat, lon in [(32.57, 34.95), (31.96, 34.80)]:     # Carmel winery cellars
        x, y = ll2xy(lat, lon)
        q, r = [int(v) for v in xy2hex(np.array(x), np.array(y))]
        put((q, r), "grapes", None, "Carmel winery cellars (Rishon LeZion 1890, Zichron Ya'akov 1892)", "carmel_winery")
    for k, t in T.items():                                 # lakes
        if t["resource"]:
            continue
        h = hsh("res", *k)
        if t["terrain"] == "lake" and t["lake_id"] == 3 and h < 0.25:
            put(k, "potash", None, "Dead Sea brines (potash, bromine, magnesium)", "dead_sea_works")
        elif t["terrain"] == "lake" and t["lake_id"] == 1 and h < 0.3:
            put(k, "fish", None, "Kinneret fishery (St Peter's fish / tilapia, Kinneret sardine)")
    # spread pass: real regional products, no two resources adjacent, the same resource at least 5 hexes apart
    # (min. 5 hexes apart, so any one type appears at most ~4-5 times on a 10x7 screen), deterministic order
    placed = {k: t["resource"] for k, t in T.items() if t["resource"]}
    near3 = {}

    def within(k, d):
        if (k, d) not in near3:
            ring = {k}
            for _ in range(d):
                ring |= {n for m in ring for n in neighbors(*m)}
            near3[(k, d)] = ring
        return near3[(k, d)]
    for k in sorted(T, key=lambda k: hsh("order", *k)):
        t = T[k]
        if k in placed or hsh("p", *k) > 0.6:
            continue
        opts = region_options(t)
        if not opts or any(n in placed for n in neighbors(*k)):
            continue
        opts = [o for o in opts if not any(placed.get(m) == o[0] for m in within(k, 4))]
        if not opts:
            continue
        tot = sum(o[1] for o in opts)
        x, acc = hsh("pick", *k) * tot, 0
        for res, w, _, note in opts:
            acc += w
            if x < acc:
                break
        put(k, res, None, note)
        placed[k] = res


# ----------------------------------------------------------------------------- borders / eras


def hex_dist(a, b):
    def cube(q, r):
        x = q - (r - (r & 1)) // 2
        return x, r, -x - r
    ax, ay, az = cube(*a)
    bx, by, bz = cube(*b)
    return max(abs(ax - bx), abs(ay - by), abs(az - bz))


_BORDERS = {}


def borders(T):
    """Era hex sets. Returns (borders, border_eras, areas, military_control).
    borders[era]          = every hex Israel held (sovereign territory + territory where Israel applied its law +
                            territory under Israeli military control / de facto use), land and lake hexes only.
    military_control[era] = the subset held only militarily (or by de facto use), i.e. not Israeli sovereign territory and
                            not an area where Israel applied its own law."""
    if "v" in _BORDERS:
        return _BORDERS["v"]
    land = {k: t for k, t in T.items() if t["water"] != "sea"}
    by_area = {}
    for k, t in land.items():
        by_area.setdefault(t["area"], []).append(k)

    def A(*codes):
        s = set()
        for c in codes:
            s.update(by_area.get(c, []))
        return s
    core = A("ISR49", "SCOPUS", "ISR_OTHER")
    # Taba: the Egyptian land hex nearest to Taba (29.49N, 34.90E)
    x, y = ll2xy(29.4920, 34.9040)
    taba = min((k for k, t in T.items() if t["area"] == "EGY" and t["water"] is None),
               key=lambda k: (hex_center(*k)[0] - x) ** 2 + (hex_center(*k)[1] - y) ** 2)
    sinai = A("EGY")
    # Syrian (pre-1973) Hermon summit sector: the northern end of the UNDOF polygon
    hermon_syria = {k for k in A("UNDOF") if T[k]["lat"] >= 33.30}
    undof = A("UNDOF")
    # southern Negev and Arava taken in Operation Uvda (Mar 1949): 1949-line hexes south of 30.55N
    uvda = {k for k in core if T[k]["lat"] < 30.55}
    # Arava land east of the 1994 treaty line used by Israel c.1967-1994 (Arieli 2018: ~300 km2 around Yotvata, Lotan,
    # Ketura, Grofit): Jordanian hexes adjacent to Israel between 29.65N and 30.45N
    arava_strip = {k for k in A("JOR") if 29.65 < T[k]["lat"] < 30.45 and any(n in core for n in neighbors(*k))}
    # Lebanon: 1982-85 all on-map Lebanon; 1985-2000 security zone ~800 km2 (~75 hexes), 5-20 km deep
    lebanon = A("LBN")
    israel_n = [k for k in core if T[k]["lat"] > 32.9]
    sz_depth = {k: min(hex_dist(k, c) for c in israel_n) for k in lebanon}
    security_zone = {k for k, dd in sz_depth.items() if dd <= (3 if T[k]["lon"] < 35.35 else 4)}
    gaza = A("GAZA")
    WB, EJ, GOLAN = A("WB", "LATRUN", "NML_JLM"), A("EJ"), A("GOLAN", "SHEBAA")

    def era(id, start, end, label, src, sov, law, mil, description, others=None):
        return dict(id=id, start=start, end=end, label=label, src=src, sov=set(sov), law=set(law), mil=set(mil),
                    description=description, others=others or {})

    S67 = "occupied in June 1967"
    eras = [
        era("1948_war", "1948-05-14", "1949-03-10", "1948 war (approximate)", ["armistice_1949", "operation_uvda_1949"],
            core - uvda, set(), set(),
            "Turns before the armistices. No reliable dated polygons of the shifting 1948 front lines are encoded, so this era "
            "uses the 1949 Armistice Lines minus the southern Negev and Arava (south of ~30.55N), where Israeli troops moved "
            "down the Wadi Araba road in early March 1949 and occupied Um Reshresh on the Gulf of Aqaba on 10 Mar 1949 (UN "
            "observer report via JTA; UN doc. S/1295). Earlier changes of control during the 1948 war are NOT modelled."),
        era("1949_uvda", "1949-03-10", "1949-07-20", "Spring 1949 (armistice talks)", ["armistice_1949", "operation_uvda_1949"],
            core, set(), set(),
            "After Israeli forces reached Um Reshresh on the Gulf of Aqaba (10 Mar 1949). Uses the final 1949 lines for the "
            "whole era, including the lines of the Israel-Jordan armistice signed at Rhodes on 3 Apr 1949."),
        era("1949_armistice", "1949-07-20", "1956-10-29", "1949 Armistice Lines (Green Line)", ["armistice_1949"],
            core, set(), set(),
            "Lines of the General Armistice Agreements with Egypt (24 Feb 1949), Lebanon (23 Mar), Jordan (3 Apr) and Syria "
            "(20 Jul). Demilitarised zones and the Mount Scopus enclave are smaller than a hex and not encoded.",
            {"West Bank incl. East Jerusalem": "Jordan", "Gaza Strip": "Egypt", "Golan Heights": "Syria",
             "Latrun / Jerusalem no man's land": "neither party"}),
        era("1956_sinai_campaign", "1956-10-29", "1957-03-08", "Suez/Sinai war occupation", ["suez_1956"],
            core, set(), gaza | sinai,
            "Israeli forces crossed into Sinai on 29 Oct 1956 and withdrew in stages from November 1956; UNEF took over the "
            "Gaza Strip on the night of 6/7 Mar 1957 and the Sharm el-Sheikh area on 8 Mar 1957 (UNEF I background). Holding "
            "all on-map Sinai until March overstates the last weeks."),
        era("1957_armistice_restored", "1957-03-08", "1967-06-05", "Green Line restored",
            ["suez_1956", "armistice_1949", "arieli_arava_2018"],
            core, set(), set(),
            "Same lines as 1949. Israeli use of land east of the later 1994 Arava line began in the 1960s (Arieli 2018) but is "
            "only encoded from 1967."),
        era("1967_ceasefire", "1967-06-10", "1973-10-22", "After the Six-Day War (1967 ceasefire lines)",
            ["six_day_war_1967", "unsc_242", "unsc_478", "arieli_arava_2018"],
            core, EJ, (WB | gaza | GOLAN | (undof - hermon_syria) | sinai | arava_strip),
            "Between 5 and 10 Jun 1967 Israel occupied the Sinai Peninsula, the Gaza Strip, the West Bank, East Jerusalem and "
            "the Golan Heights (US Office of the Historian). UN Security Council Resolution 242 (22 Nov 1967) called for the "
            "'withdrawal of Israeli armed forces from territories occupied in the recent conflict'. On 28 Jun 1967 Israel "
            "extended the Jerusalem municipality to East Jerusalem (Law Library of Congress); UNSC Resolution 478 (1980) "
            "censured Israel's 1980 'basic law' on Jerusalem. Golan control = NE 'Golan Heights' + UNDOF polygons "
            "(approximating the 1967 ceasefire line, incl. Quneitra) but not the Syrian Hermon summit. arava_strip = land "
            "east of the later 1994 treaty line used by Israel (approximation; Arieli 2018: 300 km2 returned in 1994)."),
        era("1973_hermon", "1973-10-22", "1974-06-26", "Yom Kippur War: Hermon summit taken",
            ["yom_kippur_hermon_1973", "disengagement_1974"],
            core, EJ, (WB | gaza | GOLAN | undof | sinai | arava_strip),
            "On 22 Oct 1973 Israel took all Syrian positions on Mount Hermon (JTA timeline). Held until the 1974 disengagement. "
            "The 1973 salient east of the ceasefire line lies mostly beyond this map and is not encoded."),
        era("1974_golan_disengagement", "1974-06-26", "1981-12-14", "Israel-Syria disengagement (1974)", ["disengagement_1974"],
            core, EJ, (WB | gaza | GOLAN | sinai | arava_strip),
            "The Agreement on Disengagement (UN doc. S/11302/Add.1, May 1974) placed Israeli forces west of Line A (Line A-1 at "
            "Quneitra), put all territory east of Line A under Syrian administration and made the area between Lines A and B an "
            "area of separation for the UN Disengagement Observer Force (UNSC Res. 350). The era start date (26 Jun 1974, "
            "completion of the Israeli pull-back) is approximate."),
        era("1981_golan_heights_law", "1981-12-14", "1982-04-25", "Golan Heights Law",
            ["golan_heights_law_1981", "unsc_497", "us_golan_2019"],
            core, EJ | GOLAN, (WB | gaza | sinai | arava_strip),
            "The Knesset adopted the Golan Heights Law, applying Israeli law, jurisdiction and administration to the Golan "
            "Heights. Sources differ on the date: the Law Library of Congress gives 15 Dec 1981, while the Syrian complaint "
            "cited in UNSC Resolution 497 is dated 14 Dec 1981. Resolution 497 (17 Dec 1981) declared the decision 'null and "
            "void and without international legal effect'; the United States recognised the Golan as part of Israel on 25 Mar "
            "2019 (Proclamation 9852). Lines unchanged from 1974."),
        era("1982_sinai_returned", "1982-04-25", "1982-06-06", "Sinai returned to Egypt", ["egypt_israel_treaty_1979"],
            core, EJ | GOLAN, (WB | gaza | {taba} | arava_strip),
            "Under the Egypt-Israel Peace Treaty (26 Mar 1979) Israel withdrew its forces and civilians from Sinai; on 25 Apr "
            "1982 the Egyptian flag was raised at Sharm el-Sheikh and Rafah (Christian Science Monitor, 26 Apr 1982). The Taba "
            "border dispute went to arbitration and Taba stayed Israeli-held."),
        era("1982_lebanon_war", "1982-06-06", "1985-06-10", "Lebanon War: IDF in southern Lebanon", ["lebanon_war_1982"],
            core, EJ | GOLAN, (WB | gaza | {taba} | arava_strip | lebanon),
            "In June 1982 Israel invaded Lebanon (Operation Peace for Galilee); in 1985 it withdrew from most Lebanese "
            "territory (CRS report RS20566). All on-map Lebanon is encoded as under Israeli military control; the 10 Jun 1985 "
            "end date is approximate. Military control only: Israel did not claim sovereignty."),
        era("1985_security_zone", "1985-06-10", "1989-03-15", "South Lebanon security zone", ["south_lebanon_security_zone"],
            core, EJ | GOLAN, (WB | gaza | {taba} | arava_strip | security_zone),
            "After the 1985 partial withdrawal Israel kept a self-declared 'security zone' in southern Lebanon: roughly 10% of "
            "Lebanon and nine miles deep per CRS, 1,100 km2 per INSS (sources differ). Encoded as Lebanese hexes within 3 hexes "
            "of Israel west of 35.35E and 4 hexes east of it (~1,000 km2, approximation)."),
        era("1989_taba", "1989-03-15", "1994-10-26", "Taba returned to Egypt",
            ["taba_award_1988", "oslo_accords", "south_lebanon_security_zone"],
            core, EJ | GOLAN, (WB | gaza | arava_strip | security_zone),
            "An arbitral tribunal decided the Taba boundary case on 29 Sep 1988; the Egyptian flag was raised over Taba on 15 "
            "Mar 1989 (JTA). The 1993 Declaration of Principles provided for a Palestinian Interim Self-Government Authority in "
            "the West Bank and Gaza (signed 13 Sep 1993). Under the 1995 Oslo II agreement, which came after this era's start, "
            "over 60% of the West Bank became Area C, where Israel retains near-exclusive control (OCHA). Areas A/B are "
            "finer than the hex grid and are not encoded."),
        era("1994_jordan_treaty", "1994-10-26", "2000-05-24", "Israel-Jordan peace treaty",
            ["jordan_treaty_1994", "arieli_arava_2018", "south_lebanon_security_zone"],
            core, EJ | GOLAN, (WB | gaza | security_zone),
            "The Israel-Jordan peace treaty, signed at the Arava/Araba crossing on 26 Oct 1994, delimited the boundary with "
            "reference to the Mandate boundary; about 300 km2 Israel had taken over east of it were returned (Arieli 2018). "
            "The Naharayim/Baqura and Zofar/Al-Ghamr arrangements are sub-hex."),
        era("2000_lebanon_withdrawal", "2000-05-24", "2005-09-12", "Withdrawal from southern Lebanon",
            ["lebanon_withdrawal_2000"],
            core, EJ | GOLAN, (WB | gaza),
            "Israel left the security zone unilaterally on 24 May 2000 (INSS); on 16 Jun 2000 the UN Secretary-General "
            "confirmed that Israeli forces had withdrawn from Lebanon in compliance with resolution 425 (S/2000/590)."),
        era("2005_gaza_disengagement", "2005-09-12", None, "After the Gaza disengagement", ["gaza_disengagement_2005"],
            core, EJ | GOLAN, WB,
            "Israeli troops pulled out of the Gaza Strip on 12 Sep 2005, more than 38 years after capturing it (BBC)."),
        # (the era after Q3 2023 - the IDF in the UNDOF zone from Dec 2024 - was deleted with all content after the end of
        # the game, 2026-10-14; its source syria_buffer_zone_2024 is retired in sources/map_sources.json)
    ]
    out, meta, mil = {}, [], {}

    def srt(s):
        return sorted([[q, r] for q, r in s], key=lambda v: (v[1], v[0]))
    for e in eras:
        held = e["sov"] | e["law"] | e["mil"]
        out[e["id"]] = srt(held)
        mil[e["id"]] = srt(e["mil"] - e["sov"] - e["law"])
        status = {}
        for name, s in [("israel_1949_lines", e["sov"]), ("israeli_law_applied", e["law"] - e["sov"]),
                        ("military_control", e["mil"] - e["sov"] - e["law"])]:
            status[name] = len(s)
        meta.append(dict(id=e["id"], start=e["start"], end=e["end"], label=e["label"], description=e["description"],
                         others=e["others"], hex_counts=status, tile_count=len(held), source=e["src"] + ["natural_earth_10m"]))
    area_names = {"ISR49": "israel_1949", "WB": "west_bank", "EJ": "east_jerusalem", "GAZA": "gaza_strip", "GOLAN": "golan_heights",
                  "SHEBAA": "shebaa_farms", "UNDOF": "undof_zone", "LATRUN": "latrun_no_mans_land", "EGY": "sinai",
                  "LBN": "lebanon", "SYR": "syria", "JOR": "jordan"}
    areas = {v: srt(A(k)) for k, v in area_names.items() if k in by_area}
    areas.update(taba=srt({taba}), hermon_syrian_summit=srt(hermon_syria), arava_pre1994_strip=srt(arava_strip),
                 south_lebanon_1982=srt(lebanon), south_lebanon_security_zone=srt(security_zone),
                 negev_south_of_uvda=srt(uvda))
    _BORDERS["v"] = (out, meta, areas, mil)
    return _BORDERS["v"]

# ----------------------------------------------------------------------------- output


def write_json(T):
    tiles = []
    for r in range(ROWS):
        for q in range(COLS):
            t = T[(q, r)]
            d = dict(q=q, r=r, lat=round(t["lat"], 4), lon=round(t["lon"], 4), terrain=t["terrain"], feature=t["feature"],
                     elevation_m=int(round(t["elev"] if t["water"] != "sea" else t["depth"])),
                     river=t["river"], coast=bool(t["coast"]), region=t["region"], resource=t["resource"])
            if t["river_name"]:
                d["river_name"] = t["river_name"]
            if t.get("stream"):
                d["stream"] = t["stream"]
            d["cliff_edges"] = t.get("cliff_edges", [])
            if t["terrain"] in ("hills", "mountains", "desert_hills"):
                d["base"] = "desert" if t["terrain"] == "desert_hills" or t["rain"] < 180 else (
                    "grassland" if t["rain"] >= 430 else "plains")
            if t["resource_reveal"]:
                d["resource_reveal"] = t["resource_reveal"]
            if t["resource_note"]:
                d["resource_note"] = t["resource_note"]
            if t["resource_source"]:
                d["resource_source"] = t["resource_source"]
            if t["historical_change"]:
                d["historical_change"] = t["historical_change"]
            if t["water"] is None:
                d["rain_mm"] = int(round(t["rain"]))
            tiles.append(d)
    b, meta, areas, mil = borders(T)
    places = list(PLACE_TILES)
    doc = dict(
        cols=COLS, rows=ROWS, hex_km=HEX_KM, origin=dict(lat=LAT_N, lon=LON_W), layout="pointy-odd-r",
        projection=dict(kind="equirectangular", lat_ref=LAT_C, km_per_deg_lon=round(KX, 4), km_per_deg_lat=KY,
                        note="tile centre x_km = hex_km*(q + 0.5*(r&1)), y_km = hex_km*sqrt(3)/2*r; "
                             "lat = origin.lat - y_km/km_per_deg_lat, lon = origin.lon + x_km/km_per_deg_lon"),
        generated=datetime.datetime.now().isoformat(timespec="seconds"),
        generator="tools/build_map.py",
        source_list="sources/MAP_SOURCES.md (ids in border_eras[].source, places[].source, tiles[].resource_source, "
                    "tiles[].historical_change.source; master list sources/map_sources.json)",
        hex_size_note=("3.5 km between hex centres (~10.6 km^2 per tile). Israel within the Green Line is ~1,950 tiles; "
                       "Tel Aviv-Jerusalem is 15 tiles, Haifa-Tel Aviv 24, Gaza Strip 2-3 tiles wide, Kinneret ~15 tiles, "
                       "northern Dead Sea basin 4 tiles wide. Smaller hexes (2-3 km) push the map past 13,000 tiles; larger ones "
                       "(5+ km) erase the Gaza Strip, the Carmel ridge and the Gulf of Eilat."),
        sources=dict(
            elevation="Mapzen/AWS Terrarium terrain tiles z10 (SRTM 3\" on land, ETOPO1/GEBCO bathymetry)",
            boundaries="Natural Earth 1:10m v5 admin_0_countries and admin_0_disputed_areas (Green Line, West Bank, Gaza, "
                       "East Jerusalem, Latrun, Golan Heights, UNDOF zone, Shebaa Farms)",
            lakes="Natural Earth 1:10m lakes (Sea of Galilee, Dead Sea north and south basins)",
            rivers="OpenStreetMap waterway=river via Overpass API (ODbL)",
            streams="OpenStreetMap named waterway=stream ways (course >= 20 km) via Overpass API (ODbL)",
            arava_border="OpenStreetMap Israel-Jordan land boundary (members of Jordan's admin_level=2 relation), which follows "
                         "the 1994 treaty line; replaces Natural Earth's segment south of the Dead Sea (NE is ~2 km too far west)",
            rainfall="WorldClim 2.1 BIO12 annual precipitation, 2.5 arc-min (Fick & Hijmans 2017)",
        ),
        terrain_rules=("Each hex aggregates ~170 cells of a 250 m analysis raster. water: >=50% sea -> 'coast' if it touches land or "
                       "mean depth > -40 m, else 'ocean'; >=42% lake -> 'lake'. land: relief = p90-p10 elevation inside the hex. "
                       "mountains if mean >= 1150 m, or max >= 1100 m and relief >= 250 m, or mean >= 650 m and relief >= 420 m, "
                       "or relief >= 750 m; hills if relief >= 150 m, or mean slope >= 9%, or mean >= 600 m with relief >= 60 m, "
                       "or >= 450 m with relief >= 90 m, or 100-500 m with relief >= 60 m or slope >= 4% (Shephelah foothills); "
                       "on the rift floor below -50 m only relief >= 300 m counts. East of the Judea/Samaria watershed "
                       "(31.15-32.45N, west of 35.57E) a hex is arid at <= 300 mm and becomes desert_hills from 100 m relief. Arid = rain < 180 mm/yr "
                       "(WorldClim BIO12, corrected for the lee-side rain shadow east of the watershed and calibrated to 21 station "
                       "normals, see RAIN_STATIONS) turns flat land into desert and hills into desert_hills (low arid 'mountains' become "
                       "desert_hills); otherwise flat land is grassland if >= 430 mm else plains. Oasis hexes are flat desert. "
                       "Hula basin = marsh plus one Lake Hula hex (1948 state, see historical_change). Mount Sodom is forced to desert_hills."),
        field_notes=dict(
            river="true where a perennial river crosses the hex (river_name: Jordan incl. Dan/Hasbani headwaters, Yarmouk, "
                  "Yarkon, Kishon, Litani, Zarqa)",
            cliff_edges="list of edge indices (0-5) of this hex that are cliffs: a >= 200 m step in hex-mean elevation to "
                        "the land neighbour, or a makhtesh rim. Index = direction to the neighbour: 0 E, 1 NE, 2 NW, 3 W, 4 SW, "
                        "5 SE; odd-r offsets even row [(1,0),(0,-1),(-1,-1),(-1,0),(-1,1),(0,1)], odd row "
                        "[(1,0),(1,-1),(0,-1),(-1,0),(0,1),(1,1)]. Symmetric: the neighbour lists the opposite edge.",
            base="hills/mountains/desert_hills only: the underlying flat terrain by rainfall (grassland >= 430 mm, plains, "
                 "desert < 180 mm), like Civ VI's grassland-hills vs plains-hills",
            natural_wonders="landforms: makhtesh floors are flat desert hexes ringed by cliff edges",
            military_control="per era id: the subset of borders[era] held only militarily or by de facto use (not Israeli "
                             "sovereign territory, not an area where Israel applied its law). border_eras[].hex_counts splits "
                             "each era into israel_1949_lines / israeli_law_applied / military_control.",
            stream="name of a named seasonal stream / wadi (OSM waterway=stream, course >= 20 km) crossing the hex; not a river",
            coast="true on land hexes touching a sea hex (Mediterranean or Gulf of Aqaba); lake shores are not flagged",
            elevation_m="mean land elevation of the hex in metres (mean depth for sea hexes)",
            rain_mm="mean annual precipitation, mm (land hexes only)",
            borders="per era id: hexes held by Israel (sovereign territory plus territory under Israeli military administration "
                    "or Israeli law); land and lake hexes only. border_eras gives dates, descriptions and sources; areas lists "
                    "the component territories (west_bank, gaza_strip, golan_heights, ...).",
            resource_reveal="date the deposit became known (natural gas, oil), as an ISO date prefix (YYYY, YYYY-MM or "
                            "YYYY-MM-DD) to the precision the source gives; hide the resource before it",
            historical_change="terrain that changed during 1948-2023: switch to to_terrain at date",
        ),
        tiles=tiles,
        borders=b,
        border_eras=meta,
        military_control=mil,
        areas=areas,
        natural_wonders=WONDERS,
        places=places,
    )
    os.makedirs(os.path.dirname(OUT_JSON), exist_ok=True)
    with open(OUT_JSON, "w", encoding="utf-8") as f:
        json.dump(doc, f, ensure_ascii=False, separators=(",", ":"))
    return doc

# ----------------------------------------------------------------------------- debug render

COL = {"ocean": (34, 78, 140), "coast": (70, 140, 200), "lake": (96, 176, 226), "grassland": (100, 170, 62),
       "plains": (192, 186, 96), "hills": (150, 136, 78), "mountains": (128, 108, 100), "desert": (238, 216, 160),
       "desert_hills": (206, 168, 112), "marsh": (58, 140, 122)}

# control points for the reference image: (pixel x, pixel y, lat, lon) read off ref/israel_map.webp
REF_CP = [
    (318, 265, 32.833, 34.957),   # Carmel cape (Haifa)
    (566, 276, 32.810, 35.590),   # Kinneret centre
    (382, 143, 33.093, 35.105),   # Rosh HaNikra
    (421, 722, 31.780, 35.215),   # Jerusalem
    (545, 732, 31.765, 35.545),   # Dead Sea north tip
    (244, 595, 32.080, 34.780),   # Tel Aviv
    (187, 717, 31.800, 34.650),   # Ashdod
    (243, 967, 31.250, 34.790),   # Beersheba
    (299, 1725, 29.555, 34.955),  # head of the Gulf of Eilat
]


def ref_affine():
    A, bx, by = [], [], []
    for px, py, lat, lon in REF_CP:
        x, y = ll2xy(lat, lon)
        A.append([float(x), float(y), 1.0])
        bx.append(px)
        by.append(py)
    A = np.array(A)
    cx = np.linalg.lstsq(A, np.array(bx, float), rcond=None)[0]
    cy = np.linalg.lstsq(A, np.array(by, float), rcond=None)[0]
    res = np.hypot(A @ cx - bx, A @ cy - by)
    return cx, cy, res


def _edge(q, r, nq, nr):
    """the shared edge between two neighbouring hexes, in km"""
    x, y = hex_center(q, r)
    c = hex_corners(x, y)
    nx, ny = hex_center(nq, nr)
    i = int(round(math.degrees(math.atan2(ny - y, nx - x)) / 60)) % 6
    return c[i], c[(i + 1) % 6]


def _font(sz, bold=False):
    try:
        return ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf", sz)
    except OSError:
        return ImageFont.load_default()


def _inwin(x, y, win):
    return win[0] - 3 < x < win[2] + 3 and win[1] - 3 < y < win[3] + 3


def panel_hex(T, R, S, win, labels=True):
    """hex map panel. win = (x0, y0, x1, y1) in km. returns PIL image"""
    x0, y0, x1, y1 = win
    PW, PH = int((x1 - x0) * S), int((y1 - y0) * S)

    def P(x, y):
        return ((x - x0) * S, (y - y0) * S)
    img = Image.new("RGB", (PW, PH), (20, 20, 24))
    d = ImageDraw.Draw(img)
    for (q, r), t in T.items():
        x, y = hex_center(q, r)
        if _inwin(x, y, win):
            d.polygon([P(*p) for p in hex_corners(x, y)], fill=COL[t["terrain"]])
    # subtle hillshade on land hexes
    ELEV, gx, gy = R["ELEV"], R["gx"], R["gy"]
    gyy, gxx = np.gradient(np.maximum(ELEV, 0), RES * 1000)
    shade = np.clip(1.0 + (-gxx - gyy) * 0.9, 0.82, 1.12).astype(np.float32)
    uu, vv = np.meshgrid(np.arange(PW), np.arange(PH))
    shf = bilinear(shade, ((vv / S + y0) - gy[0]) / RES, ((uu / S + x0) - gx[0]) / RES)
    lm = Image.new("L", (PW, PH), 0)
    dl = ImageDraw.Draw(lm)
    for (q, r), t in T.items():
        x, y = hex_center(q, r)
        if t["water"] is None and _inwin(x, y, win):
            dl.polygon([P(*p) for p in hex_corners(x, y)], fill=255)
    lmf = np.asarray(lm, np.float32) / 255
    arr = np.asarray(img, np.float32) * (1 + (shf - 1) * lmf)[..., None]
    img = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8))
    d = ImageDraw.Draw(img)
    k = S / 4.0
    w1 = max(1, int(round(2 * k)))
    for (q, r), t in T.items():
        x, y = hex_center(q, r)
        if not _inwin(x, y, win):
            continue
        d.polygon([P(*p) for p in hex_corners(x, y)], outline=(60, 60, 60))
        cx, cy = P(x, y)
        f = t["feature"]
        if f == "forest":
            d.polygon([(cx, cy - 4 * k), (cx - 3.5 * k, cy + 3 * k), (cx + 3.5 * k, cy + 3 * k)], fill=(20, 80, 30))
        elif f == "orchard":
            d.ellipse([cx - 2.5 * k, cy - 2.5 * k, cx + 2.5 * k, cy + 2.5 * k], fill=(240, 150, 30))
        elif f == "oasis":
            d.ellipse([cx - 3 * k, cy - 3 * k, cx + 3 * k, cy + 3 * k], fill=(40, 200, 120))
        elif f == "wadi":
            d.line([cx - 4 * k, cy + 2 * k, cx + 4 * k, cy - 2 * k], fill=(150, 110, 60), width=w1)
        elif f == "reef":
            d.ellipse([cx - 2.5 * k, cy - 2.5 * k, cx + 2.5 * k, cy + 2.5 * k], fill=(255, 120, 160))
        if t["resource"]:
            d.rectangle([cx + 2 * k, cy + 2 * k, cx + 6 * k, cy + 6 * k], fill=(255, 255, 255), outline=(0, 0, 0))
        if t["river"]:
            d.ellipse([cx - 2 * k, cy - 2 * k, cx + 2 * k, cy + 2 * k], fill=(30, 90, 255))
    for name, pts in R.get("stream_lines", []):
        xs, ys = ll2xy([p[1] for p in pts], [p[0] for p in pts])
        d.line([P(a, b) for a, b in zip(xs, ys)], fill=(120, 200, 235), width=1)
    for name, pts in R["river_lines"]:
        xs, ys = ll2xy([p[1] for p in pts], [p[0] for p in pts])
        d.line([P(a, b) for a, b in zip(xs, ys)], fill=(40, 110, 255), width=w1)
    # cliffs (dark brown) and natural wonders (gold outline)
    for (q, r), t in T.items():
        if not _inwin(*hex_center(q, r), win):
            continue
        for i in t.get("cliff_edges", []):
            n = neighbor_dir(q, r, i)
            if n and n > (q, r):
                d.line([P(*pp) for pp in _edge(q, r, *n)], fill=(70, 30, 10), width=max(2, int(round(2.5 * k))))
    for w in WONDERS:
        hs = set(map(tuple, w["hexes"]))
        for (q, r) in hs:
            if not _inwin(*hex_center(q, r), win):
                continue
            for n in neighbors(q, r):
                if n not in hs:
                    d.line([P(*pp) for pp in _edge(q, r, *n)], fill=(255, 210, 0), width=max(1, int(round(1.5 * k))))
    draw_borders(d, T, P, k, win)
    draw_places(d, T, P, k, win, labels)
    if labels and (x1 - x0) > 150:                       # legend in the open sea, full view only
        f = _font(13)
        lx, ly = 60, PH * 0.12
        items = list(COL.items()) + [("forest", None), ("orchard", None), ("wadi", None), ("oasis", None), ("reef", None),
                                     ("resource", None), ("river hex", None), ("stream", None), ("cliff edge", None), ("wonder", None)]
        d.rectangle([lx - 6, ly - 6, lx + 130, ly + 18 * len(items) + 2], fill=(15, 25, 45), outline=(200, 200, 200))
        mark = {"forest": (20, 80, 30), "orchard": (240, 150, 30), "wadi": (150, 110, 60), "oasis": (40, 200, 120),
                "reef": (255, 120, 160), "resource": (255, 255, 255), "river hex": (30, 90, 255),
                "stream": (120, 200, 235), "cliff edge": (70, 30, 10), "wonder": (255, 210, 0)}
        for i, (name, c) in enumerate(items):
            yy = ly + 18 * i
            d.rectangle([lx, yy, lx + 14, yy + 12], fill=c or mark[name], outline=(0, 0, 0))
            d.text((lx + 20, yy - 1), name, fill=(255, 255, 255), font=f)
    return img


_borders_cache = {}


def draw_borders(d, T, P, k, win, only_green=False):
    if "b" not in _borders_cache:
        _borders_cache["b"] = borders(T)[0]
    b = _borders_cache["b"]
    s49 = set(map(tuple, b["1949_armistice"]))
    snow = set(map(tuple, b["2005_gaza_disengagement"]))
    s67 = set(map(tuple, b["1967_ceasefire"]))
    country = {kk: (t["region"] if t["region"] in ("Lebanon", "Syria", "Jordan", "Sinai", "Saudi Arabia") else "IL")
               for kk, t in T.items() if t["water"] != "sea"}
    w2, w3 = max(1, int(round(2 * k))), max(2, int(round(3 * k)))
    for (q, r) in T:
        if (q, r) not in country or not _inwin(*hex_center(q, r), win):
            continue
        for nq, nr in neighbors(q, r):
            if (nq, nr) < (q, r) or (nq, nr) not in country:
                continue
            e = [P(*p) for p in _edge(q, r, nq, nr)]
            if not only_green:
                if country[(q, r)] != country[(nq, nr)]:
                    d.line(e, fill=(70, 70, 70), width=w2)
                if ((q, r) in s67) != ((nq, nr) in s67):
                    d.line(e, fill=(230, 60, 200), width=w2)
                if ((q, r) in snow) != ((nq, nr) in snow):
                    d.line(e, fill=(255, 255, 255), width=w2)
            if ((q, r) in s49) != ((nq, nr) in s49):
                d.line(e, fill=(0, 200, 60) if not only_green else (0, 150, 40), width=w3)


def draw_places(d, T, P, k, win, labels=True):
    font = _font(int(13 * min(max(k, 1.0), 1.6)))
    for pl in places_list():
        x, y = hex_center(pl["q"], pl["r"])
        if not _inwin(x, y, win):
            continue
        cx, cy = P(x, y)
        rr = 4 * min(k, 1.5)
        if labels:
            d.ellipse([cx - rr, cy - rr, cx + rr, cy + rr], fill=(220, 20, 20), outline=(255, 255, 255))
            d.text((cx + rr + 2, cy - 7), pl["name"], fill=(255, 255, 255), font=font, stroke_width=2, stroke_fill=(0, 0, 0))
        else:
            d.ellipse([cx - rr, cy - rr, cx + rr, cy + rr], outline=(220, 0, 0), width=2)


def panel_ref(T, S, win, overlay):
    x0, y0, x1, y1 = win
    PW, PH = int((x1 - x0) * S), int((y1 - y0) * S)
    ref = Image.open(REF).convert("RGB")
    cx_, cy_, res = ref_affine()
    a, b, c = cx_
    d_, e, f = cy_
    # output px (u,v) -> km (u/S + x0, v/S + y0) -> ref px
    coeffs = (a / S, b / S, a * x0 + b * y0 + c, d_ / S, e / S, d_ * x0 + e * y0 + f)
    img = ref.transform((PW, PH), Image.AFFINE, coeffs, resample=Image.BICUBIC, fillcolor=(20, 20, 24))
    if overlay:
        d = ImageDraw.Draw(img)
        k = S / 4.0

        def P(x, y):
            return ((x - x0) * S, (y - y0) * S)
        for (q, r), t in T.items():
            if not _inwin(*hex_center(q, r), win):
                continue
            for nq, nr in neighbors(q, r):
                if (t["water"] is not None) != (T[(nq, nr)]["water"] is not None):
                    d.line([P(*p) for p in _edge(q, r, nq, nr)], fill=(230, 0, 0), width=max(2, int(round(1.5 * k))))
        draw_borders(d, T, P, k, win, only_green=True)
        draw_places(d, T, P, k, win, labels=False)
    return img


def _titled(img, title):
    out = Image.new("RGB", (img.width, img.height + 30), (20, 20, 24))
    out.paste(img, (0, 30))
    ImageDraw.Draw(out).text((8, 6), title, fill=(255, 255, 255), font=_font(16, True))
    return out


def _lat_ticks(img, S, win):
    d = ImageDraw.Draw(img)
    x0, y0, x1, y1 = win
    f = _font(12)
    for lat in np.arange(29.0, 34.0, 0.25 if (y1 - y0) < 200 else 0.5):
        _, y = ll2xy(lat, LON_W)
        if y0 < y < y1:
            v = (y - y0) * S + 30
            d.line([(0, v), (6, v)], fill=(255, 255, 0))
            d.text((8, v - 7), f"{lat:.2f}N", fill=(255, 255, 0), font=f, stroke_width=2, stroke_fill=(0, 0, 0))


REGION_COL = {
    "Galilee": (90, 160, 70), "Golan": (150, 120, 200), "Jezreel Valley": (170, 220, 90), "Sharon": (60, 190, 150),
    "Coastal Plain": (120, 210, 200), "Carmel": (30, 110, 50), "Shephelah": (200, 200, 110), "Judea": (170, 120, 70),
    "Samaria": (200, 150, 90), "Judean Desert": (230, 180, 120), "Negev": (240, 220, 160), "Arava": (250, 160, 90),
    "Jordan Valley": (240, 110, 110), "Gaza Strip": (230, 90, 170), "Sinai": (200, 190, 170), "Lebanon": (140, 140, 160),
    "Jordan": (170, 160, 140), "Syria": (150, 150, 120), "Saudi Arabia": (190, 170, 150), "Mediterranean Sea": (40, 80, 140),
    "Gulf of Aqaba": (40, 90, 160), "Sea of Galilee": (90, 170, 230), "Dead Sea": (110, 180, 230)}


def panel_regions(T, S, win):
    x0, y0, x1, y1 = win
    PW, PH = int((x1 - x0) * S), int((y1 - y0) * S)
    img = Image.new("RGB", (PW, PH), (20, 20, 24))
    d = ImageDraw.Draw(img)

    def P(x, y):
        return ((x - x0) * S, (y - y0) * S)
    cent = {}
    for (q, r), t in T.items():
        x, y = hex_center(q, r)
        d.polygon([P(*p) for p in hex_corners(x, y)], fill=REGION_COL.get(t["region"], (255, 0, 255)), outline=(70, 70, 70))
        if t["water"] != "sea":
            cent.setdefault(t["region"], []).append((x, y))
    f = _font(13, True)
    for reg, pts in cent.items():
        a = np.array(pts)
        m = a.mean(0)
        j = int(np.argmin(((a - m) ** 2).sum(1)))      # label on the member tile closest to the centroid
        d.text(P(*a[j]), reg, fill=(0, 0, 0), font=f, anchor="mm", stroke_width=2, stroke_fill=(255, 255, 255))
    return img


def triptych(T, R, S, win, title):
    p1 = _titled(panel_hex(T, R, S, win), f"HEX MAP {title}")
    p2 = _titled(panel_ref(T, S, win, False), "REFERENCE ref/israel_map.webp (warped to the same frame)")
    p3 = _titled(panel_ref(T, S, win, True), "REFERENCE + hex land/water edges (red) + Green Line")
    p4 = _titled(panel_regions(T, S, win), "REGIONS")
    for p in (p1, p2, p3, p4):
        _lat_ticks(p, S, win)
    out = Image.new("RGB", (p1.width * 4 + 30, p1.height), (0, 0, 0))
    for i, p in enumerate((p1, p2, p3, p4)):
        out.paste(p, (i * (p1.width + 10), 0))
    return out


ZOOMS = [  # name, lat_n, lon_w, lat_s, lon_e
    ("Haifa / Carmel / Jezreel", 33.12, 34.80, 32.40, 35.50),
    ("Kinneret / Hula / Golan", 33.30, 35.30, 32.55, 35.95),
    ("Dead Sea / Judean Desert", 31.95, 35.05, 31.00, 35.75),
    ("Gulf of Eilat / Arava", 30.10, 34.65, 29.30, 35.30),
    ("Gaza / Ashkelon / Shephelah", 31.85, 34.20, 31.15, 34.90),
    ("Tel Aviv / Sharon / Samaria", 32.55, 34.55, 31.85, 35.30),
    ("Negev: makhteshim, Ramon, Zin, Paran", 31.05, 34.55, 30.35, 35.30),
]


def render(T, R, out_png, title):
    cx_, cy_, res = ref_affine()
    print("ref georef residuals px:", np.round(res, 1))
    full = triptych(T, R, 4.0, (-6, -6, W_KM + 6, H_KM + 6),
                    f"{COLS}x{ROWS} @ {HEX_KM} km   green=1949 Green Line  magenta=1967 extent  white=2005+  grey=intl")
    full.save(out_png)
    print("wrote", out_png)
    pairs = []
    for name, la_n, lo_w, la_s, lo_e in ZOOMS:
        xa, ya = ll2xy(la_n, lo_w)
        xb, yb = ll2xy(la_s, lo_e)
        win = (float(xa), float(ya), float(xb), float(yb))
        S = 9.0
        a = _titled(panel_hex(T, R, S, win), name)
        b = _titled(panel_ref(T, S, win, True), name + " - reference + hex edges")
        _lat_ticks(a, S, win)
        pair = Image.new("RGB", (a.width * 2 + 10, a.height), (0, 0, 0))
        pair.paste(a, (0, 0))
        pair.paste(b, (a.width + 10, 0))
        pairs.append(pair)
    # two columns of pairs
    cols = [pairs[0::2], pairs[1::2]]
    colw = [max(p.width for p in c) for c in cols]
    colh = [sum(p.height + 10 for p in c) for c in cols]
    sheet = Image.new("RGB", (sum(colw) + 20, max(colh)), (0, 0, 0))
    x = 0
    for c, w in zip(cols, colw):
        y = 0
        for p in c:
            sheet.paste(p, (x, y))
            y += p.height + 10
        x += w + 20
    zp = out_png[:-4] + "_zoom.png"
    sheet.save(zp)
    print("wrote", zp)


def places_list():
    return PLACE_TILES


def next_shot_name(desc):
    os.makedirs(SHOTS, exist_ok=True)
    nums = [int(m.group(1)) for f in os.listdir(SHOTS) if (m := re.match(r"(\d{3})_", f))]
    n = max(nums, default=-1) + 1
    return f"{n:03d}_map_{desc}.png"


MAP_SOURCES_JSON = os.path.join(ROOT, "sources", "map_sources.json")
MAP_SOURCES_MD = os.path.join(ROOT, "sources", "MAP_SOURCES.md")


def check_and_render_sources(doc):
    """Every source id cited in map.json must exist in sources/map_sources.json AND carry at least one opened record
    (url + accessed date + verbatim quote), per CONTRACT.md: "accessed: n/a" does not count. Refuses to build otherwise.
    Renders sources/MAP_SOURCES.md (SOURCES.md is generated from the history piece's sources.json)."""
    S = json.load(open(MAP_SOURCES_JSON, encoding="utf-8"))
    by_id = {s["id"]: s for s in S}
    used = set()
    for e in doc["border_eras"]:
        used.update(e["source"])
    for p in doc["places"]:
        used.update(p.get("source", []))
    for t in doc["tiles"]:
        if t.get("resource_source"):
            used.add(t["resource_source"])
        if t.get("historical_change"):
            used.add(t["historical_change"]["source"])
    for w in doc.get("natural_wonders", []):
        used.add(w["source"])
    missing = sorted(used - set(by_id))
    unverified = sorted(i for i in used & set(by_id)
                        if not any(o.get("url") and o.get("quote") and o.get("accessed") for o in by_id[i].get("opened", [])))
    if missing or unverified:
        raise SystemExit(f"map.json cites sources that are undefined {missing} or have no opened URL + verbatim quote "
                         f"{unverified}; fix sources/map_sources.json first")
    L = ["# Map sources (game/data/map.json)", "",
         "Generated from `sources/map_sources.json` by `python tools/build_map.py`. Do not hand-edit.", "",
         "Each entry: **[MAP:id]** citation — status. Every cited source was opened; each 'Opened' line gives the URL that "
         "loaded, the access date and a verbatim quote from it (PDF quotes are as extracted, so hyphenation and OCR "
         "artefacts are kept). `replaced` = an earlier unverified citation was swapped for this openable one.", ""]
    for s in S:
        if s.get("retired"):
            L.append(f"**[MAP:{s['id']}]** RETIRED (no longer cited{'; ' + s['retired_note'] if s.get('retired_note') else ''}) — {s['citation']}")
            L.append("")
            continue
        L.append(f"**[MAP:{s['id']}]** {s['citation']} — {s.get('status', 'verified')}")
        L.append(f"  - Supports: {s['supports']}")
        for o in s.get("opened", []):
            extra = f" ({o['place']}, {o['dist_km']} km from the map point)" if o.get("place") else ""
            L.append(f"  - Opened {o['accessed']}: {o['url']}{extra} — \"{o['quote']}\"")
        L.append("")
    open(MAP_SOURCES_MD, "w", encoding="utf-8").write("\n".join(L) + "\n")
    print(f"sources: {len(used)} ids cited, all opened with URL + quote; wrote sources/MAP_SOURCES.md")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--desc", default="build")
    ap.add_argument("--no-shot", action="store_true")
    ap.add_argument("--note", default=None)
    ap.add_argument("--no-log", action="store_true")
    ap.add_argument("--out", default=None, help="write the debug PNG here instead of progress/shots (implies --no-log)")
    args = ap.parse_args()
    T, R = build(args)
    doc = write_json(T)
    check_and_render_sources(doc)
    from collections import Counter
    print("terrain:", Counter(t["terrain"] for t in doc["tiles"]).most_common())
    print("regions:", Counter(t["region"] for t in doc["tiles"]).most_common())
    print("features:", Counter(t["feature"] for t in doc["tiles"]).most_common())
    print("resources:", Counter(t["resource"] for t in doc["tiles"] if t["resource"]).most_common())
    print("eras:", {k: len(v) for k, v in doc["borders"].items()})
    if args.out:
        render(T, R, args.out, args.desc)
    elif not args.no_shot:
        name = next_shot_name(args.desc)
        render(T, R, os.path.join(SHOTS, name), args.desc)
        if not args.no_log:
            line = {"t": datetime.datetime.now().astimezone().isoformat(timespec="seconds"), "piece": "map", "kind": "build",
                    "img": "shots/" + name, "note": args.note or f"map {COLS}x{ROWS} @ {HEX_KM} km: {args.desc}"}
            with open(LOG, "a", encoding="utf-8") as f:
                f.write(json.dumps(line, ensure_ascii=False) + "\n")


if __name__ == "__main__":
    main()
