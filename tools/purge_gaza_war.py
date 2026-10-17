"""Permanently remove the 7 Oct 2023 / 2023- Gaza war content from a game data folder (user decision, 2026-10-11).
Used for frozen checkpoints; the live data is cleaned at source by tools/history and tools/build_map.py.
  python tools/purge_gaza_war.py <game_dir>
"""
import json, sys, os
IDS = {"evt_2023_october_7_attack", "evt_2023_gaza_war", "evt_2023_november_truce", "evt_2024_icj_provisional_measures",
       "evt_2024_flour_massacre", "evt_2024_wck_convoy_strike", "evt_2024_nuseirat_hostage_rescue",
       "evt_2024_six_hostages_found_executed", "evt_2024_sinwar_killed", "evt_2024_icc_warrants",
       "evt_2024_knesset_unrwa_laws", "evt_2025_january_ceasefire", "evt_2025_war_resumes",
       "evt_2025_ghf_aid_site_killings", "evt_2025_gaza_famine", "evt_2025_doha_strike", "evt_2025_october_ceasefire",
       "evt_2025_unscr_2803", "evt_2026_last_hostage_returned", "evt_2026_hamas_commanders_killed"}
YELLOW = {"israeli_military_control_yellow_line", "partial_israeli_military_control_yellow_line"}
d = os.path.join(sys.argv[1], "data")
def load(n): return json.load(open(os.path.join(d, n), encoding="utf-8"))
def save(n, o): json.dump(o, open(os.path.join(d, n), "w", encoding="utf-8"), ensure_ascii=False, indent=1)

ev = load("events.json")
kept = [e for e in ev if e.get("id") not in IDS]
save("events.json", kept); print("events removed:", len(ev) - len(kept))

cities = load("cities.json"); n = 0
for c in cities:
    st = c.get("status") or []
    new = [s for s in st if s.get("status", s.get("control")) not in YELLOW]
    n += len(st) - len(new); c["status"] = new
save("cities.json", cities); print("city statuses removed:", n)

m = load("map.json")
era = "2025_gaza_yellow_line"
for key in ("borders", "military_control"):
    if isinstance(m.get(key), dict): m[key].pop(era, None)
if isinstance(m.get("border_eras"), list):
    m["border_eras"] = [e for e in m["border_eras"] if e.get("id") != era]
    for e in m["border_eras"]:
        if e.get("id") == "2024_syria_buffer_zone": e["end"] = None
if isinstance(m.get("areas"), dict): m["areas"].pop("gaza_yellow_line_2025", None)
save("map.json", m); print("map era removed")

p = os.path.join(d, "choice_terms.json")
if os.path.exists(p):
    ct = load("choice_terms.json")
    evs = ct.get("events", ct)
    for k in list(evs):
        if k in IDS: evs.pop(k)
    save("choice_terms.json", ct); print("choice terms cleaned")

# scrub references to the deleted content from kept events and city notes (same rules as the live pipeline)
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "history"))
import scrub_deleted
ev, cities = load("events.json"), load("cities.json")
scrub_deleted.scrub(ev, cities)
save("events.json", ev); save("cities.json", cities); print("text scrubbed")
