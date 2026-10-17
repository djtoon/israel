# SUPERSEDED - DO NOT RE-RUN. On 2026-10-11 the user permanently deleted the 7 Oct 2023 / Gaza war content; the
# Yellow Line statuses were removed from data/city_fixes_d.json by hand. Re-running this would re-add them.
# -*- coding: utf-8 -*-
"""Lead decisions after round 3 -> data/city_fixes_d.json (applied by apply.py after city_fixes_a..c).

1. Northern West Bank (Jenin, Nablus, Tulkarm, Qalqilya): split like the Little Triangle -
   Iraqi-held from May 1948 until the Iraqi-Jordanian handover provided for by Article VI of the
   Israel-Jordan armistice (Rhodes, 3 April 1949), then Jordanian-administered.
2. Gaza City and Khan Yunis: not wholly Israeli-held after 10 Oct 2025 -> status
   "partial_israeli_military_control_yellow_line" with Al Jazeera's per-neighbourhood description.
   Rafah keeps full Yellow Line control (Al Jazeera: "Nearly all of the Rafah governorate").

Built from the published cities.json; run once, then `python tools/history/apply.py`.
Idempotent: re-running on already-split statuses leaves them unchanged.
"""
import json, os, sys, copy
sys.stdout.reconfigure(encoding="utf-8")
H = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(H))
C = {c["id"]: c for c in json.load(open(os.path.join(ROOT, "game", "data", "cities.json"), encoding="utf-8"))}

AVALON = "https://avalon.law.yale.edu/20th_century/arm03.asp"
IRAQ_REPLACE = {"claim": "Armistice Art. VI: Jordanian forces to replace the Iraqi forces in the sector they held",
                "url": AVALON,
                "quote": "It is agreed that the forces of the Hashemite Jordan Kingdom shall replace the forces of Iraq in the sector now held by the latter forces"}
RHODES_DATE = {"claim": "Israel-Jordan armistice signed at Rhodes on 3 April 1949", "url": AVALON,
               "quote": "DONE at Rhodes, Island of Rhodes, Greece, on the third of April one thousand nine hundred and forty-nine"}

out = {"cities": [], "sources": [], "flags": []}
for cid in ["jenin", "nablus", "tulkarm", "qalqilya"]:
    st = copy.deepcopy(C[cid]["status"])
    if st[0]["status"] == "iraqi_held":
        out["flags"].append(f"{cid}: already split"); out["cities"].append({"id": cid, "set": {"status": st}}); continue
    first = st[0]
    old_cites = [c for c in first.get("cite") or [] if c.get("quote")]
    held = [c for c in old_cites if "Iraqi troops" in c["quote"]]
    iraqi = {"from": first["from"], "to": "1949-04", "status": "iraqi_held",
             "note": "Held by Iraqi forces from May 1948 (the Iraqi front in the northern West Bank).",
             "source": [], "cite": [dict(c) for c in held] + [dict(IRAQ_REPLACE)]}
    jordan = {"from": "1949-04", "to": first["to"], "status": "jordanian_administered",
              "note": "Under Article VI of the Israel-Jordan armistice signed at Rhodes on 3 April 1949, Jordan's forces replaced the Iraqi forces in this sector in spring 1949; Jordan annexed the West Bank in April 1950, an annexation recognised by few states.",
              "source": [x for x in first.get("source", [])],
              "cite": [dict(RHODES_DATE), dict(IRAQ_REPLACE)] + [dict(c) for c in old_cites if c not in held]}
    out["cities"].append({"id": cid, "set": {"status": [iraqi, jordan] + st[1:]}})

AJ_PARTIAL = {
    "gaza_city": "Israeli forces stayed in parts of eastern Gaza City (Shujayea, Tuffah and Zeitoun)",
    "khan_yunis": "Israeli forces stayed in more than half of Khan Younis governorate",
}
for cid, aj in AJ_PARTIAL.items():
    st = copy.deepcopy(C[cid]["status"])
    last = st[-1]
    if last["status"] not in ("israeli_military_control_yellow_line", "partial_israeli_military_control_yellow_line"):
        out["flags"].append(f"{cid}: unexpected last status {last['status']}"); continue
    last["status"] = "partial_israeli_military_control_yellow_line"
    last["note"] = ("From 10 October 2025 the ceasefire 'Yellow Line' ran through this area: according to Al Jazeera's map, "
                    + aj + ", while the rest of the built-up area stayed under Hamas de facto control. Strip-wide, about 53% "
                    "lay east of the line according to CFR and CNN (almost 58% according to Gisha and Al Jazeera's Sanad team), "
                    "and in May 2026 CNN reported a new 'orange line' with about 64% under Israeli control.")
    out["cities"].append({"id": cid, "set": {"status": st}})

json.dump(out, open(os.path.join(H, "data", "city_fixes_d.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print(len(out["cities"]), "cities;", "; ".join(out["flags"]) or "no flags")
