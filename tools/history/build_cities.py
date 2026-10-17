# -*- coding: utf-8 -*-
import json, sys, re, os, xlrd, openpyxl
from pyproj import Transformer
sys.stdout.reconfigure(encoding="utf-8")
HERE = os.path.dirname(os.path.abspath(__file__))
RAW = os.path.join(HERE, "raw")
sys.path.insert(0, HERE)
from meta import CITIES, EXTRA_POP, POP_NOTES_EXTRA

TAGS = json.load(open(os.path.join(RAW, "tags.json"), encoding="utf-8")) if os.path.exists(os.path.join(RAW, "tags.json")) else {}
itm = Transformer.from_crs("EPSG:2039", "EPSG:4326", always_xy=True)

# CBS 1995 census list: census-year populations 1948..1995
b = xlrd.open_workbook(os.path.join(RAW, "nonum.xls")); s = b.sheet_by_name("רשימת הישובים")
C95 = {}
for i in range(1, s.nrows):
    r = s.row_values(i)
    try: c = int(r[0])
    except: continue
    C95[c] = dict(zip(["1948", "1961", "1972", "1983", "1995"], r[14:19]))
# 2008 locality file
b = xlrd.open_workbook(os.path.join(RAW, "bycode2008.xls")); s = b.sheet_by_index(0)
C08 = {}
for i in range(2, s.nrows):
    r = s.row_values(i)
    if isinstance(r[2], float): C08[int(r[2])] = r[10]
# 2022 census
ws = openpyxl.load_workbook(os.path.join(RAW, "census2022.xlsx"), read_only=True).worksheets[0]
C22 = {r[1]: r[2] for r in ws.iter_rows(values_only=True) if isinstance(r[1], int)}
# 2022 locality file: coords, founding year
ws = openpyxl.load_workbook(os.path.join(RAW, "bycode2022.xlsx"), read_only=True).worksheets[0]
rows = list(ws.iter_rows(values_only=True)); hdr = rows[0]
BY22 = {}
for r in rows[1:]:
    d = dict(zip(hdr, r)); BY22[d["סמל יישוב"]] = d
WD = json.load(open(os.path.join(RAW, "extract.json"), encoding="utf-8"))

def num(v):
    if isinstance(v, (int, float)) and v > 0: return int(round(v))
    return None

def resolve(srcs):
    out = []
    for x in srcs:
        if x.startswith("@"):
            v = TAGS.get(x)
            if not v: raise SystemExit("unresolved tag " + x)
            out += v if isinstance(v, list) else [v]
        else:
            out.append(x)
    return list(dict.fromkeys(out))

out = []
for m in CITIES:
    cid = m["id"]; codes = m.get("cbs_sum") or ([m["cbs"]] if m.get("cbs") else [])
    pop, psrc, pnote = {}, {}, {}
    if codes:
        for y in ["1948", "1961", "1972", "1983", "1995"]:
            vals = [num(C95.get(c, {}).get(y)) for c in codes]
            if all(v is not None for v in vals) and not (cid == "harish"):
                pop[y] = sum(vals); psrc[y] = "S001"
        vals = [num(C08.get(c)) for c in codes]
        if all(v is not None for v in vals): pop["2008"] = sum(vals); psrc["2008"] = "S002"
        vals = [num(C22.get(c)) for c in codes]
        if all(v is not None for v in vals): pop["2022"] = sum(vals); psrc["2022"] = "S003"
    for y, (v, sid, note) in EXTRA_POP.get(cid, {}).items():
        pop[y] = v; psrc[y] = sid; pnote[y] = note
    # coordinates
    lat = lon = None; csrc = None
    c0 = codes[0] if codes else None
    if c0 and BY22.get(c0) and BY22[c0].get("קואורדינטות"):
        k = str(BY22[c0]["קואורדינטות"]).strip()
        if len(k) == 12:
            lon, lat = itm.transform(int(k[:6]), int(k[6:])); csrc = "S004"
    if lat is None and m.get("coords"):
        lat, lon = m["coords"]; csrc = "S015"
    if lat is None:
        lat, lon = WD[cid]["lat"], WD[cid]["lon"]; csrc = "S015"
    status = []
    for t in m["status"]:
        a, b_, c, d, e = t[:5]
        st = dict(zip(["from", "to", "status", "note", "source"], (a, b_, c, d, resolve(e))))
        if len(t) > 5: st["cite"] = t[5]
        status.append(st)
    srcs = []
    for v in psrc.values(): srcs.append(v)
    srcs.append(csrc)
    if m.get("founded") and c0 and BY22.get(c0): srcs.append("S004")
    for st in status: srcs += st["source"]
    if c0 in (89, 82) or m.get("cbs_sum"): srcs.append("S004")
    CROSS = {"S005": ["haifa","tel_aviv","jerusalem","bnei_brak","bat_yam","givatayim","herzliya","hadera","holon","tiberias","netanya","afula","kfar_saba","lod","nahariya","nes_ziona","rehovot","ramla","raanana","safed","kiryat_bialik","kiryat_yam","beersheba"],
             "S006": ["beersheba","majdal_shams","arad"], "S012": ["ariel","maale_adumim","beersheba"]}
    for sid, lst in CROSS.items():
        if cid in lst: srcs.append(sid)
    if "2022" in pop: srcs.append("S008")
    rec = {
        "id": cid, "name": m["name"], "name_he": m["he"], "kind": m["kind"],
        "lat": round(lat, 5), "lon": round(lon, 5), "q": None, "r": None,
        "founded": m.get("founded"),
    }
    if m.get("founded_note"): rec["founded_note"] = m["founded_note"]
    rec["cbs_code"] = m.get("cbs") or (m.get("cbs_sum") if m.get("cbs_sum") else None)
    rec["status"] = status
    rec["population"] = dict(sorted(pop.items()))
    rec["population_source"] = dict(sorted(psrc.items()))
    notes = {}
    for y in pop:
        if psrc[y] == "S001":
            notes[y] = {"1948": "census 8 Nov 1948", "1961": "census 22 May 1961", "1972": "census 20 May 1972", "1983": "census 4 Jun 1983", "1995": "census 4 Nov 1995"}[y]
        elif psrc[y] == "S002": notes[y] = "CBS end-2008 figure following the 2008 census"
        elif psrc[y] == "S003": notes[y] = "2022 census estimate (fieldwork Apr-Dec 2022)"
    notes.update(pnote)
    rec["population_notes"] = dict(sorted(notes.items()))
    if POP_NOTES_EXTRA.get(cid): rec["population_comment"] = POP_NOTES_EXTRA[cid]
    if m.get("notes"): rec["notes"] = m["notes"]
    if m.get("merged_into"): rec["merged_into"] = m["merged_into"]
    if m.get("coords"): rec["coord_note"] = "approximate centre chosen for map placement only"
    rec["coord_source"] = csrc
    rec["source"] = list(dict.fromkeys(x for x in srcs if x))
    out.append(rec)

json.dump(out, open(sys.argv[1], "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print(len(out), "cities")
for r in out:
    print(r["id"], r["lat"], r["lon"], r["population"])
