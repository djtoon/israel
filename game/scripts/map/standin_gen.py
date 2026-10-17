"""TEMPORARY stand-in map generator (renderer piece).

Writes game/scripts/map/standin_map.json in the map.json schema from CONTRACT.md so the
renderer has something Israel-shaped to draw until the map builder ships game/data/map.json.
The renderer always prefers data/map.json when it exists. Geography here is a rough hand
approximation, not data for gameplay or history.
"""
import json, math, os, random

random.seed(7)
HEX_KM = 5.0
LAT0, LAT1 = 33.45, 29.35   # north, south
LON0, LON1 = 33.85, 36.15   # west, east
KM_LAT = 110.95
KM_LON = 111.32 * math.cos(math.radians(31.5))
ROW_KM = HEX_KM * math.sqrt(3) / 2  # pointy hexes: hex_km = flat-to-flat width
ROWS = int((LAT0 - LAT1) * KM_LAT / ROW_KM) + 1
COLS = int((LON1 - LON0) * KM_LON / HEX_KM) + 1

COAST = [(33.45, 35.24), (33.27, 35.19), (33.09, 35.10), (32.93, 35.07), (32.86, 35.06),
         (32.83, 34.98), (32.80, 34.95), (32.70, 34.93), (32.50, 34.88), (32.33, 34.84),
         (32.08, 34.77), (32.03, 34.74), (31.80, 34.63), (31.67, 34.54), (31.52, 34.44),
         (31.32, 34.23), (31.20, 34.05), (31.12, 33.80), (31.08, 33.40), (31.05, 33.0)]


def interp(pts, lat):
    for (a, la), (b, lb) in zip(pts, pts[1:]):
        if a >= lat >= b:
            t = (a - lat) / (a - b) if a != b else 0
            return la + (lb - la) * t
    return pts[-1][1]


def coast_lon(lat):
    return interp(COAST, lat)


def bump(lat, lon, clat, clon, rlat, rlon):
    d = ((lat - clat) / rlat) ** 2 + ((lon - clon) / rlon) ** 2
    return math.exp(-d)


def rift_lon(lat):
    # Hula -> Kinneret -> Jordan -> Dead Sea -> Arava -> Eilat
    return interp([(33.5, 35.62), (32.82, 35.59), (32.2, 35.55), (31.75, 35.52), (31.2, 35.42),
                   (30.6, 35.20), (30.0, 35.05), (29.55, 34.98), (29.0, 34.80)], lat)


def classify(lat, lon):
    """returns (water_kind or None, elevation_m)"""
    # sea
    if lat > 31.0 and lon < coast_lon(lat):
        d_km = (coast_lon(lat) - lon) * KM_LON
        return ("coast" if d_km < 7 else "ocean"), -min(2000, 20 + d_km * 25)
    if lat <= 31.05 and lat > 30.9 and lon < 33.6:
        return "ocean", -200
    # Gulf of Aqaba
    if lat < 29.56:
        c = interp([(29.56, 34.97), (29.0, 34.78)], lat)
        if abs(lon - c) < 0.07 + (29.56 - lat) * 0.15:
            return "coast", -60
    # lakes
    if ((lat - 32.82) / 0.09) ** 2 + ((lon - 35.59) / 0.055) ** 2 < 1:
        return "lake", -210
    if 31.1 < lat < 31.78 and 35.39 < lon < 35.57 and not (31.2 < lat < 31.3 and lon < 35.45):
        return "lake", -430
    rl = rift_lon(lat)
    dr = (lon - rl) * KM_LON
    e = 0.0
    # base rise from the coast inland
    dc = max(0.0, (lon - coast_lon(lat)) * KM_LON) if lat > 31.0 else 60
    e += min(250, dc * 6)
    # central ridges (west of rift)
    ridge = 0.0
    ridge += 950 * bump(lat, lon, 31.75, 35.18, 0.42, 0.11)    # Judea
    ridge += 800 * bump(lat, lon, 32.25, 35.22, 0.30, 0.10)    # Samaria
    ridge += 1000 * bump(lat, lon, 32.98, 35.35, 0.14, 0.16)   # Upper Galilee
    ridge += 450 * bump(lat, lon, 32.75, 35.30, 0.08, 0.15)    # Lower Galilee
    ridge += 480 * bump(lat, lon, 32.70, 35.04, 0.07, 0.06)    # Carmel
    ridge += 500 * bump(lat, lon, 32.48, 35.38, 0.05, 0.08)    # Gilboa
    ridge += 600 * bump(lat, lon, 30.62, 34.80, 0.45, 0.25)    # Negev highlands / Ramon
    ridge += 500 * bump(lat, lon, 29.70, 34.90, 0.25, 0.10)    # Eilat mountains
    ridge -= 180 * bump(lat, lon, 32.60, 35.25, 0.05, 0.14)    # Jezreel valley
    e += ridge
    # Golan, Hermon and the Jordanian plateau east of the rift
    if dr > 0:
        plateau = 950 if lat < 32.6 else 650
        e = max(e * 0.3, plateau * min(1.0, dr / 14.0))
        e += 1800 * bump(lat, lon, 33.40, 35.85, 0.08, 0.12)
    # the rift itself drops below sea level
    rift = math.exp(-(dr / 7.0) ** 2)
    floor = interp([(33.5, 70), (33.1, 70), (32.82, -210), (32.2, -260), (31.75, -390),
                    (31.0, -350), (30.5, -50), (30.0, 100), (29.55, 30)], lat)
    e = e * (1 - rift) + floor * rift
    # Sinai / west Negev lowlands
    if lat < 31.3 and lon < 34.5:
        e = min(e, 120 + (34.5 - lon) * 200 + (31.3 - lat) * 250)
    e += random.uniform(-25, 25)
    return None, e


def region(lat, lon, water):
    if water == "lake":
        return "Sea of Galilee" if lat > 32.5 else "Dead Sea"
    if water:
        return "Gulf of Aqaba" if lat < 30 else "Mediterranean Sea"
    rl = rift_lon(lat)
    if lon > rl + 0.06:
        if lat > 32.68:
            return "Mount Hermon" if lat > 33.28 else "Golan Heights"
        return "Transjordan"
    if lat > 33.1 and lon < 35.6:
        return "Lebanon"
    if abs(lon - rl) < 0.06:
        if lat > 32.9:
            return "Hula Valley"
        if lat > 31.8:
            return "Jordan Valley"
        if lat > 30.9:
            return "Dead Sea"
        return "Arava"
    if lat < 29.7:
        return "Eilat"
    if lat < 31.0 and lon < 34.25:
        return "Sinai"
    if 31.2 < lat < 31.6 and lon < coast_lon(lat) + 0.10:
        return "Gaza Strip"
    if lat < 31.25:
        return "Negev"
    if lat > 32.68 and lon < 35.08 and lat < 32.85:
        return "Carmel"
    if lat > 32.72:
        return "Galilee"
    if lat > 32.52:
        return "Jezreel Valley"
    if lon < coast_lon(lat) + 0.13:
        if lat > 32.15:
            return "Sharon"
        if lat > 31.9:
            return "Gush Dan"
        return "Southern Coastal Plain"
    if lon < 34.98:
        return "Shephelah"
    if lat > 32.0:
        return "Samaria"
    return "Judean Mountains"


def terrain_for(lat, lon, water, e, reg):
    if water:
        return water, "none"
    arid = lat < 31.35 or reg in ("Dead Sea", "Arava", "Sinai", "Eilat") or \
        (lon > 35.30 and lat < 31.9 and reg != "Transjordan") or (reg == "Transjordan" and lat < 31.6)
    if reg == "Hula Valley" and 32.98 < lat < 33.12:
        return "marsh", "none"
    feature = "none"
    if arid:
        t = "desert_hills" if e > 450 else "desert"
        if reg in ("Dead Sea",) and 31.42 < lat < 31.50:
            feature = "oasis"
        elif random.random() < 0.12:
            feature = "wadi"
        if reg == "Eilat" and lon < 35.0 and lat < 29.6:
            feature = "none"
        return t, feature
    if e > 900:
        t = "mountains"
    elif e > 380:
        t = "hills"
    elif reg in ("Sharon", "Gush Dan", "Jezreel Valley", "Hula Valley", "Jordan Valley") or lat > 32.4:
        t = "grassland"
    else:
        t = "plains"
    r = random.random()
    if reg in ("Carmel", "Galilee") and t != "mountains" and r < 0.55:
        feature = "forest"
    elif reg in ("Judean Mountains", "Samaria") and r < 0.25:
        feature = "forest" if r < 0.1 else "orchard"
    elif reg in ("Sharon", "Gush Dan", "Southern Coastal Plain", "Shephelah", "Jezreel Valley") and r < 0.35:
        feature = "orchard"
    elif t == "grassland" and r < 0.15:
        feature = "forest"
    return t, feature


RES = {"Sharon": ["citrus", "wheat"], "Southern Coastal Plain": ["citrus", "wheat"], "Jezreel Valley": ["wheat"],
       "Galilee": ["olives"], "Samaria": ["olives"], "Judean Mountains": ["olives", "stone"],
       "Negev": ["copper", "phosphate"], "Dead Sea": ["potash"], "Golan Heights": ["cattle"], "Shephelah": ["wheat"]}

PLACES = [("Tel Aviv-Yafo", "תל אביב-יפו", 32.075, 34.78, "city"), ("Jerusalem", "ירושלים", 31.778, 35.22, "city"),
          ("Haifa", "חיפה", 32.80, 34.99, "city"), ("Beersheba", "באר שבע", 31.25, 34.79, "city"),
          ("Eilat", "אילת", 29.56, 34.95, "city"), ("Tiberias", "טבריה", 32.79, 35.53, "city"),
          ("Nazareth", "נצרת", 32.70, 35.30, "city"), ("Akko", "עכו", 32.93, 35.08, "city"),
          ("Netanya", "נתניה", 32.33, 34.86, "city"), ("Ashdod", "אשדוד", 31.80, 34.65, "city"),
          ("Ashkelon", "אשקלון", 31.67, 34.57, "city"), ("Safed", "צפת", 32.96, 35.50, "city"),
          ("Hadera", "חדרה", 32.44, 34.92, "city"), ("Rishon LeZion", "ראשון לציון", 31.96, 34.80, "city"),
          ("Kiryat Shmona", "קריית שמונה", 33.21, 35.57, "town"), ("Dimona", "דימונה", 31.07, 35.03, "town"),
          ("Gaza", "غزة", 31.50, 34.47, "city"), ("Amman", "عمان", 31.95, 35.93, "city")]


def main():
    tiles = []
    grid = {}
    for r in range(ROWS):
        for q in range(COLS):
            x_km = HEX_KM * (q + 0.5 * (r & 1))
            y_km = ROW_KM * r
            lat = LAT0 - y_km / KM_LAT
            lon = LON0 + x_km / KM_LON
            water, e = classify(lat, lon)
            reg = region(lat, lon, water)
            t, f = terrain_for(lat, lon, water, e, reg)
            if t == "coast" and lat < 29.6 and random.random() < 0.4:
                f = "reef"
            res = "none"
            if not water and reg in RES and random.random() < 0.06:
                res = random.choice(RES[reg])
            if water in ("ocean", "coast") and random.random() < 0.03:
                res = "fish"
            tile = {"q": q, "r": r, "lat": round(lat, 4), "lon": round(lon, 4), "terrain": t, "feature": f,
                    "elevation_m": round(e), "river": False, "coast": False, "region": reg, "resource": res}
            grid[(q, r)] = tile
            tiles.append(tile)
    # coast flag + river (Jordan, Yarkon, Kishon roughly)
    def nbrs(q, r):
        odd = r & 1
        dirs = [(1, 0), (-1, 0), (odd, -1), (odd - 1, -1), (odd, 1), (odd - 1, 1)]
        return [(q + a, r + b) for a, b in dirs]
    for t in tiles:
        if t["terrain"] in ("ocean", "coast", "lake"):
            continue
        t["coast"] = any(grid.get(n, {}).get("terrain") in ("ocean", "coast") for n in nbrs(t["q"], t["r"]))
        if abs(t["lon"] - rift_lon(t["lat"])) < 0.03 and 31.78 < t["lat"] < 33.2 and not (32.73 < t["lat"] < 32.91):
            t["river"] = True
        if 32.08 < t["lat"] < 32.13 and 34.78 < t["lon"] < 34.98:
            t["river"] = True
    # rough 1949 armistice-line polygon (lon, lat) for the stand-in border
    ARM = [(35.10, 33.09), (35.62, 33.28), (35.65, 32.70), (35.57, 32.40), (35.20, 32.55), (35.05, 32.40),
           (34.97, 32.10), (35.02, 31.85), (35.23, 31.79), (35.10, 31.70), (34.95, 31.63), (34.90, 31.37),
           (35.40, 31.43), (35.45, 31.10), (35.10, 30.40), (34.95, 29.55), (34.88, 29.50), (34.27, 31.22),
           (34.56, 31.60), (34.48, 31.59), (34.55, 31.68), (34.60, 31.85), (34.98, 32.83), (35.10, 33.09)]

    def inside(lon, lat, poly):
        c = False
        for (x1, y1), (x2, y2) in zip(poly, poly[1:]):
            if (y1 > lat) != (y2 > lat) and lon < (x2 - x1) * (lat - y1) / (y2 - y1) + x1:
                c = not c
        return c
    border = [[t["q"], t["r"]] for t in tiles if t["terrain"] not in ("ocean", "coast") and inside(t["lon"], t["lat"], ARM)]
    places = []
    for n, nh, la, lo, k in PLACES:
        r = round((LAT0 - la) * KM_LAT / ROW_KM)
        q = round((lo - LON0) * KM_LON / HEX_KM - 0.5 * (r & 1))
        places.append({"name": n, "name_he": nh, "q": q, "r": r, "kind": k})
    out = {"cols": COLS, "rows": ROWS, "hex_km": HEX_KM, "origin": {"lat": LAT0, "lon": LON0}, "layout": "pointy-odd-r",
           "standin": True, "tiles": tiles, "borders": {"1949": border}, "places": places}
    p = os.path.join(os.path.dirname(__file__), "standin_map.json")
    with open(p, "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False)
    print(p, COLS, ROWS, len(tiles))


if __name__ == "__main__":
    main()
