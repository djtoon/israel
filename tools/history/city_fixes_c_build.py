# SUPERSEDED - DO NOT RE-RUN. On 2026-10-11 the user permanently deleted the 7 Oct 2023 / Gaza war content; the
# Yellow Line statuses were removed from data/city_fixes_c.json by hand. Re-running this would re-add them.
# -*- coding: utf-8 -*-
"""Gaza localities' status timeline (lead decision, round 3) -> data/city_fixes_c.json.

Built from the published events.json / cities.json (quotes are reused from verified event cites and the
map's Yellow Line sources). The stored data/city_fixes_c.json is what apply.py uses.

Timeline:
  1948-05-14 .. 1967-06      Egyptian administration
  1967-06    .. 2005-09-12   Israeli military occupation (PA civil control in parts from May 1994)
  2005-09-12 .. 2007-06-14   Palestinian Authority (after the disengagement)
  2007-06-14 .. 2025-10-10   Hamas de facto control (blockade; war from Oct 2023)
  2025-10-10 ..              inside the Yellow Line hexes of map.json military_control["2025_gaza_yellow_line"]:
                             "israeli_military_control_yellow_line"; outside: Hamas de facto control continues
"""
import json, os, math, sys
sys.stdout.reconfigure(encoding="utf-8")
H = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(H))
E = {e["id"]: e for e in json.load(open(os.path.join(ROOT, "game", "data", "events.json"), encoding="utf-8"))}
C = {c["id"]: c for c in json.load(open(os.path.join(ROOT, "game", "data", "cities.json"), encoding="utf-8"))}
M = json.load(open(os.path.join(ROOT, "game", "data", "map.json"), encoding="utf-8"))
YL = set(map(tuple, M["military_control"]["2025_gaza_yellow_line"]))
TILES = M["tiles"]

def ev_cites(eid, kws, n=2):
    cs = [c for c in E[eid]["cite"] if c.get("quote")]
    pick = [c for c in cs if any(k in (c["claim"] + " " + c["quote"]).lower() for k in kws)]
    return [dict(c) for c in (pick or cs)[:n]]

def hexof(c):
    t = min(TILES, key=lambda t: (t["lat"] - c["lat"]) ** 2 + ((t["lon"] - c["lon"]) * math.cos(math.radians(c["lat"]))) ** 2)
    return (t["q"], t["r"])

CFR = "https://www.cfr.org/articles/guide-trumps-twenty-point-gaza-peace-deal"
CNN = "https://edition.cnn.com/2026/05/14/middleeast/gaza-israel-ceasefire-permanent-division-intl"
GISHA = "https://gisha.org/en/the-yellow-line/"
AJ = "https://www.aljazeera.com/news/2025/10/9/map-of-gaza-shows-how-israeli-forces-will-withdraw-under-ceasefire-deal"
YL_CITES = [
    {"claim": "Yellow Line leaves Israel in control of 53% of Gaza (CFR)", "url": CFR, "quote": "In the first phase of the ceasefire, the IDF agreed to withdraw their troops up to a so-called yellow line that leaves it in control of 53 percent of the enclave"},
    {"claim": "Yellow Line first revealed in an IDF briefing on 10 October 2025 (Gisha)", "url": GISHA, "quote": "was revealed for the first time officially in a briefing held by the IDF Spokesperson on October 10"},
    {"claim": "In May 2026 CNN reported an 'orange line' with about 64% under Israeli control", "url": CNN, "quote": "new map marking an “orange line,” which shows Israel now controlling about 64% of the territory"},
    {"claim": "Alternative estimate: almost 58 percent (Gisha; also Al Jazeera's Sanad team)", "url": GISHA, "quote": "in what amounts to almost 58 percent of the territory of the Strip"},
]
GOV = {  # T-Politography via Gisha: share of each governorate inside the Yellow Line
    "gaza_city": ("64.3 percent of the Gaza City Governorate", "64.3% of Gaza City governorate"),
    "khan_yunis": ("68.3 percent of the Khan Younis Governorate", "68.3% of Khan Yunis governorate"),
    "rafah": ("62.9 percent of the Rafah Governorate", "62.9% of Rafah governorate"),
    "jabalia": ("43.8 percent of the North Gaza Governorate", "43.8% of North Gaza governorate"),
    "deir_al_balah": ("21.9 percent of the Deir al-Balah Governorate", "21.9% of Deir al-Balah governorate"),
}
AJ_LOCAL = {
    "gaza_city": ("Parts of Gaza City’s Shujayea, Tuffah and Zeitoun", "Israeli forces stay in parts of eastern Gaza City (Shujayea, Tuffah, Zeitoun)"),
    "khan_yunis": ("More than half of the Khan Younis governorate", "Israeli forces stay in more than half of Khan Younis governorate"),
    "rafah": ("Nearly all of the Rafah governorate", "Israeli forces stay in nearly all of Rafah governorate"),
}

occ = ev_cites("evt_1967_six_day_war", ["gaza"], 1)
pa = ev_cites("evt_1994_gaza_jericho", ["gaza", "palestinian authority", "self-rule"], 2)
dis = ev_cites("evt_2005_gaza_disengagement", ["gaza", "september", "settlement"], 2)
out = {"cities": [], "sources": [], "flags": []}
for cid in ["gaza_city", "khan_yunis", "rafah", "deir_al_balah", "jabalia"]:
    old = C[cid]["status"]
    eg = dict(old[0]); eg["to"] = "1967-06"
    hamas_old = dict([s for s in old if s["status"] in ("hamas_controlled", "hamas_de_facto")][0])
    hamas_old["note"] = hamas_old["note"].split(" Under the October 2025 ceasefire")[0]
    hamas_old["cite"] = [c for c in hamas_old.get("cite", []) if "gisha" not in c.get("url", "") and "cfr.org" not in c.get("url", "")]
    inside = hexof(C[cid]) in YL
    st = [eg,
          {"from": "1967-06", "to": "2005-09-12", "status": "israeli_occupied",
           "note": "Captured by Israel in the Six-Day War and held under military occupation; from May 1994 the Palestinian Authority took over civil control of most of the Strip under the Gaza-Jericho Agreement, while Israeli settlements and military zones remained until the 2005 disengagement.",
           "source": [], "cite": occ + pa},
          {"from": "2005-09-12", "to": "2007-06-14", "status": "palestinian_authority",
           "note": "After Israel's disengagement (completed 12 September 2005) the Palestinian Authority governed the Strip, while Israel kept control of its airspace, sea access and most crossings.",
           "source": [], "cite": dis},
          {"from": "2007-06-14", "to": "2025-10-10" if inside else None, "status": "hamas_de_facto",
           "note": hamas_old["note"] + (" Under the October 2025 ceasefire Israeli forces pulled back to the 'Yellow Line'; this locality lies west of it and stayed under Hamas de facto control." if not inside else ""),
           "source": list(hamas_old["source"]), "cite": [dict(c) for c in hamas_old.get("cite", [])] + ([] if inside else [dict(YL_CITES[0])])}]
    gq, gtxt = GOV[cid]
    gcite = {"claim": f"T-Politography via Gisha: {gtxt} inside the Yellow Line", "url": GISHA, "quote": gq}
    if inside:
        aq = AJ_LOCAL.get(cid)
        st.append({"from": "2025-10-10", "to": None, "status": "israeli_military_control_yellow_line",
                   "note": "From 10 October 2025 Israeli forces held the area east of the ceasefire 'Yellow Line' - about 53% of the Strip according to CFR and CNN, almost 58% according to Gisha and Al Jazeera's Sanad team; in May 2026 CNN reported a new 'orange line' with about 64% under Israeli control. On the game map this locality's hex lies inside the approximate Yellow Line area; "
                           + gtxt + " was inside the line per T-Politography (via Gisha)" + (", and Al Jazeera's map listed: " + aq[1].lower() if aq else "") + ". Parts of the built-up area remained west of the line under Hamas de facto control.",
                   "source": [], "cite": [dict(c) for c in YL_CITES] + [gcite] + ([{"claim": aq[1], "url": AJ, "quote": aq[0]}] if aq else [])})
    else:
        st[-1]["cite"].append(gcite)
    out["cities"].append({"id": cid, "set": {"status": st}})
    out["flags"].append(f"{cid}: map hex {hexof(C[cid])} {'inside' if inside else 'outside'} the Yellow Line hex set")
json.dump(out, open(os.path.join(H, "data", "city_fixes_c.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print("\n".join(out["flags"]))
