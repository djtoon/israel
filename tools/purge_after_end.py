"""Permanently delete all game content dated after the end of the game (Q3 2023, turn 302).

The user's decision, 2026-10-14: "we dont need them after oct 7". The game ends after Q3 2023 with the user's
7 October memorial (game/data/ending_oct7.json, untouched: it is the only 7 Oct content). Everything dated later is
deleted at the source instead of hidden at runtime:
  - wars, events and forks dated after Q3 2023 (their ids are tombstoned in tools/history/data/deleted_event_ids.json);
  - their choice terms, art (event illustrations), the actor name change and map era they introduced;
  - city status entries starting after the end (a later end date becomes "still in force");
  - lasting terms starting after the end (dropped) or ending after it (capped at 2023-09);
  - history dates after 2023 in techs, programmes, governments and the real-world series;
  - sources cited only by the deleted items are retired ("retired": true; S-ids are never reused).
Load-modify-save and idempotent: running it again changes nothing.

  python tools/purge_after_end.py [--dry-run]
"""
import glob
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GAME = os.path.join(ROOT, "game")
DATA = os.path.join(GAME, "data")
HIST = os.path.join(ROOT, "tools", "history", "data")
SRC = os.path.join(ROOT, "sources")
END = "2023-09-30"
END_YM = "2023-09"
END_Y = 2023
LAST_TURN = 302
DRY = "--dry-run" in sys.argv
counts = {}


def bump(k, n=1):
    counts[k] = counts.get(k, 0) + n


def load(p):
    with open(p, encoding="utf-8") as f:
        return json.load(f)


def save(p, o, compact=False):
    if DRY:
        return
    with open(p, "w", encoding="utf-8", newline="\n") as f:
        if compact:
            json.dump(o, f, ensure_ascii=False, separators=(",", ":"))
        else:
            json.dump(o, f, ensure_ascii=False, indent=1)
            f.write("\n")


def _orig_trailing_newline(p):
    with open(p, "rb") as f:
        f.seek(-1, os.SEEK_END)
        return f.read(1) == b"\n"


def save_like(p, o):
    """Saves with the indent the file already uses (1 or 2 spaces), keeping its trailing newline or not."""
    if DRY:
        return
    raw = open(p, encoding="utf-8").read()
    m = re.match(r"[\[{]\r?\n( +)", raw)
    ind = len(m.group(1)) if m else 1
    nl = raw.endswith("\n")
    with open(p, "w", encoding="utf-8", newline="\n") as f:
        json.dump(o, f, ensure_ascii=False, indent=ind)
        if nl:
            f.write("\n")


def after(d) -> bool:
    """True for a date (YYYY, YYYY-MM or YYYY-MM-DD, or an int year) after Q3 2023."""
    if d is None or isinstance(d, bool):
        return False
    if isinstance(d, (int, float)):
        return int(d) > END_Y
    s = str(d).strip()
    if re.match(r"^\d{4}-\d{2}-\d{2}", s):
        return s[:10] > END
    if re.match(r"^\d{4}-\d{2}$", s):
        return s > END_YM
    if re.match(r"^\d{4}$", s):
        return int(s) > END_Y
    return False


SID_RE = re.compile(r"\bS\d{3,5}\b")


def source_refs():
    """Every S-id named anywhere in the game data (not the translations) and code."""
    refs = set()
    files = [f for f in glob.glob(os.path.join(DATA, "**", "*.json"), recursive=True)
             if os.sep + "i18n" + os.sep not in f]
    files += glob.glob(os.path.join(GAME, "scripts", "**", "*.gd"), recursive=True)
    for f in files:
        refs |= set(SID_RE.findall(open(f, encoding="utf-8").read()))
    return refs


def map_refs(m):
    used = set()
    for e in m.get("border_eras", []):
        used.update(e.get("source", []))
    for p in m.get("places", []):
        used.update(p.get("source", []))
    for t in m.get("tiles", []):
        if t.get("resource_source"):
            used.add(t["resource_source"])
        if t.get("historical_change"):
            used.add(t["historical_change"].get("source"))
    for w in m.get("natural_wonders", []):
        used.add(w.get("source"))
    return used


def cap_terms(terms, where):
    """Lasting terms: drop the ones that start after the end, cap the ones that end after it. Terms with a relative
    "years" length get their dates when chosen, so their dated from/until fields are only notes: dropped if late."""
    out = []
    for s in terms or []:
        if not isinstance(s, dict):
            out.append(s)
            continue
        if "years" in s:
            if after(s.get("from")) or after(s.get("until")):
                s.pop("from", None)
                s.pop("until", None)
                bump("terms: dated note removed (relative term)")
            out.append(s)
            continue
        if after(s.get("from")):
            bump("terms dropped (start after the end)")
            continue
        if after(s.get("until")):
            s["until"] = END_YM
            bump("terms capped at 2023-09")
        out.append(s)
    return out


def walk_terms(node, where):
    """Applies cap_terms to every "lasting" / "streams" list in a data tree."""
    if isinstance(node, dict):
        for k in list(node):
            if k in ("lasting", "streams") and isinstance(node[k], list):
                node[k] = cap_terms(node[k], where)
            else:
                walk_terms(node[k], where)
    elif isinstance(node, list):
        for v in node:
            walk_terms(v, where)


def main():
    refs_before = source_refs()
    m_path = os.path.join(DATA, "map.json")
    m = load(m_path)
    map_before = map_refs(m)

    # ---------------------------------------------------------------- events
    ev_path = os.path.join(DATA, "events.json")
    events = load(ev_path)
    gone_ev = [e["id"] for e in events if after(e.get("date")) or int(e.get("turn") or 0) > LAST_TURN]
    events = [e for e in events if e["id"] not in gone_ev]
    bump("events deleted", len(gone_ev))
    save_like(ev_path, events)

    # ---------------------------------------------------------------- forks
    gone_fk = []
    for p in sorted(glob.glob(os.path.join(DATA, "forks", "*.json"))):
        d = load(p)
        keep = []
        for f in d.get("forks", []):
            if after(f.get("date")) or after(f.get("until")):
                gone_fk.append(f["id"])
                continue
            for o in f.get("options", []):
                if "lasting" in o:
                    o["lasting"] = cap_terms(o["lasting"], f["id"])
            keep.append(f)
        d["forks"] = keep
        if isinstance(d.get("range"), str):
            d["range"] = re.sub(r"(19|20)\d\d$", lambda mm: str(min(int(mm.group(0)), END_Y)), d["range"])
        save_like(p, d)
    bump("forks deleted", len(gone_fk))

    # ---------------------------------------------------------------- wars
    gone_war = []
    for p in sorted(glob.glob(os.path.join(DATA, "wars", "*.json"))):
        w = load(p)
        if w.get("event") in gone_ev or after(w.get("date")) or after(w.get("start")):
            gone_war.append(w.get("id", os.path.splitext(os.path.basename(p))[0]))
            if not DRY:
                os.remove(p)
        else:
            walk_terms(w, w.get("id"))
            save_like(p, w)
    bump("wars deleted", len(gone_war))
    gone = set(gone_ev) | set(gone_fk) | set(gone_war)

    # ---------------------------------------------------------------- choice terms
    ct_path = os.path.join(DATA, "choice_terms.json")
    ct = load(ct_path)
    evs = ct.get("events", ct)
    for k in list(evs):
        if k in gone:
            evs.pop(k)
            bump("choice_terms entries deleted")
    walk_terms(evs, "choice_terms")
    save_like(ct_path, ct)

    # ---------------------------------------------------------------- actors (name changes, status rails)
    a_path = os.path.join(DATA, "actors.json")
    ad = load(a_path)
    for a in ad.get("actors", []):
        if isinstance(a.get("names"), list):
            n0 = len(a["names"])
            a["names"] = [x for x in a["names"] if x.get("from_event") not in gone and not after(x.get("from"))]
            bump("actor name changes deleted", n0 - len(a["names"]))
            if not a["names"]:
                a.pop("names")
    rails = []
    for r in ad.get("status_rails", []):
        if r.get("from_event") in gone or after(r.get("from")):
            bump("status rails deleted")
            continue
        if r.get("to_event") in gone:
            r.pop("to_event")
            bump("status rails: end event removed (open-ended)")
        if after(r.get("to")):
            r.pop("to")   # no end date = it holds to the end of the game
            bump("status rails: end date after the end removed (open-ended)")
        rails.append(r)
    if "status_rails" in ad:
        ad["status_rails"] = rails
    for k in ("dated_relations",):
        if isinstance(ad.get(k), list):
            n0 = len(ad[k])
            ad[k] = [x for x in ad[k] if x.get("from_event") not in gone and x.get("event") not in gone
                     and not after(x.get("date")) and not after(x.get("from"))]
            bump("dated relations deleted", n0 - len(ad[k]))
    walk_terms(ad, "actors")
    save_like(a_path, ad)

    # ---------------------------------------------------------------- diplomacy (terms; nothing else is dated late)
    d_path = os.path.join(DATA, "diplomacy.json")
    dd = load(d_path)
    walk_terms(dd, "diplomacy")
    save_like(d_path, dd)

    # ---------------------------------------------------------------- cities: status timelines end with the game
    c_path = os.path.join(DATA, "cities.json")
    cities = load(c_path)
    for c in cities:
        st = c.get("status")
        if isinstance(st, list):
            keep = []
            for s in st:
                if after(s.get("from")):
                    bump("city status entries deleted")
                    continue
                if after(s.get("to")):
                    s["to"] = None
                    bump("city status entries: later end date -> still in force")
                if isinstance(s.get("note"), str):
                    n2 = re.sub(r"\s*On 27 July 2024 a rocket strike on a football pitch killed 12 children\.", "", s["note"])
                    if n2 != s["note"]:
                        s["note"] = n2
                        bump("city status notes: post-end sentence removed")
                keep.append(s)
            c["status"] = keep
        pop = c.get("population")
        if isinstance(pop, dict):
            for y in list(pop):
                if after(str(y)[:4]):
                    pop.pop(y)
                    bump("city population points after the end deleted")
    save_like(c_path, cities)

    # ---------------------------------------------------------------- techs: Iron Beam (laser interception)
    t_path = os.path.join(DATA, "techs.json")
    td = load(t_path)
    for era in td.get("eras", []):
        if isinstance(era.get("note"), str):
            n2 = re.sub(r"\b(\d{4})-(20[2-9]\d)\b", lambda mm: "%s-%d" % (mm.group(1), END_Y) if int(mm.group(2)) > END_Y else mm.group(0), era["note"])
            if n2 != era["note"]:
                era["note"] = n2
                bump("tech era notes capped at 2023")
    for t in td.get("techs", []):
        for k in ("description", "source", "cite", "desc", "text", "note", "history"):
            if k + "_until_end" in t:
                t[k] = t.pop(k + "_until_end")
                bump("tech texts: rewritten to stop at 2023")
        if t.get("year") is not None and after(t["year"]):
            # History had not fielded it by Q3 2023: no history year; the sim gates it as "not reached by the end"
            t["year"] = None
            t.pop("date", None)
            t["hist_after_end"] = True
            bump("tech history years after 2023 removed")
    save_like(t_path, td)

    # ---------------------------------------------------------------- programmes: Iron Beam level
    p_path = os.path.join(DATA, "projects.json")
    pd = load(p_path)
    for p in pd.get("programmes", []):
        for lv in p.get("levels", []):
            if after(lv.get("hist")):
                # as SimDB.scrub_programmes did at runtime: no history date; opens 8 years before its real date as a
                # level history had not reached by Q3 2023 (Iron Beam: operational Sept 2025 -> from Q3 2017)
                y, mo = int(lv["hist"][:4]), int(lv["hist"][5:7])
                if "from" not in lv:
                    lv["from"] = "%04d-%02d" % (y - 8, (mo - 1) // 3 * 3 + 1)
                lv.pop("hist")
                if lv.get("advocate_until_end") and not lv.get("advocate"):
                    lv["advocate"] = lv["advocate_until_end"]
                lv.pop("advocate_until_end", None)
                bump("programme history dates after 2023 removed")
            for k in ("desc", "cite"):
                if k + "_until_end" in lv:
                    lv[k] = lv.pop(k + "_until_end")
                    bump("programme texts: rewritten to stop at 2023")
    save_like(p_path, pd)

    # ---------------------------------------------------------------- governments: spans end with the game
    g_path = os.path.join(DATA, "governments.json")
    gd = load(g_path)

    def cap_years(node):
        if isinstance(node, dict):
            for k, v in node.items():
                if k == "until" and isinstance(v, int) and not isinstance(v, bool) and v > END_Y:
                    node[k] = END_Y
                    bump("government spans capped at 2023")
                else:
                    cap_years(v)
        elif isinstance(node, list):
            for v in node:
                cap_years(v)
    cap_years(gd)
    walk_terms(gd, "governments")
    save_like(g_path, gd)

    # ---------------------------------------------------------------- real-world series: no data points after 2023
    r_path = os.path.join(DATA, "real_series.json")
    rs = load(r_path)
    for k, s in rs.items():
        if isinstance(s, dict) and isinstance(s.get("values"), dict):
            for y in list(s["values"]):
                if after(y):
                    s["values"].pop(y)
                    bump("real-series points after 2023 deleted")
            if isinstance(s.get("note"), str):
                n2 = re.sub(r"\b(1[89]\d\d|20\d\d)-(20[2-9]\d)\b", lambda mm: "%s-%d" % (mm.group(1), END_Y) if int(mm.group(2)) > END_Y else mm.group(0), s["note"])
                if n2 != s["note"]:
                    s["note"] = n2
                    bump("real-series notes capped at 2023")
    save_like(r_path, rs)

    # ---------------------------------------------------------------- map: border eras after the end
    eras = m.get("border_eras", [])
    gone_era = [e["id"] for e in eras if after(e.get("start"))]
    m["border_eras"] = [e for e in eras if e["id"] not in gone_era]
    for e in m["border_eras"]:
        if after(e.get("end")):
            e["end"] = None
            bump("map eras: end after 2023 -> open")
    for key in ("borders", "military_control"):
        if isinstance(m.get(key), dict):
            for eid in gone_era:
                m[key].pop(eid, None)
    fn = m.get("field_notes")
    if isinstance(fn, dict) and isinstance(fn.get("historical_change"), str):
        fn["historical_change"] = fn["historical_change"].replace("1948-2026", "1948-2023")
    bump("map eras deleted", len(gone_era))
    save(m_path, m, compact=True)
    map_after = map_refs(m)

    # ---------------------------------------------------------------- art: illustrations only of deleted events
    am_path = os.path.join(DATA, "art_manifest.json")
    am = load(am_path)
    ev_art = am.get("events") or {}
    for k in list(ev_art):
        if k in gone:
            r = ev_art.pop(k)
            bump("event illustrations deleted")
            for fk in ("file", "file_small"):
                f = str(r.get(fk) or "")
                if f.startswith("res://"):
                    fp = os.path.join(GAME, f[len("res://"):].replace("/", os.sep))
                    for x in (fp, fp + ".import"):
                        if os.path.exists(x) and not DRY:
                            os.remove(x)
                            bump("image files deleted")
                    base = os.path.basename(fp)
                    for x in glob.glob(os.path.join(GAME, ".godot", "imported", base + "-*")):
                        if not DRY:
                            os.remove(x)
    save_like(am_path, am)

    # ---------------------------------------------------------------- tombstones and the history pipeline
    de_path = os.path.join(HIST, "deleted_event_ids.json")
    de = load(de_path)
    new = sorted(set(de) | gone)
    bump("tombstones added", len(new) - len(de))
    save(de_path, new)
    be_path = os.path.join(HIST, "base_events.json")
    be = load(be_path)
    be2 = [e for e in be if e.get("id") not in gone]
    bump("history base events deleted", len(be) - len(be2))
    save_like(be_path, be2)

    # ---------------------------------------------------------------- sources cited only by the deleted items
    refs_after = source_refs()
    only_gone = refs_before - refs_after
    retired = []
    for fn_ in ("sources.json", "sim_sources.json"):
        p = os.path.join(SRC, fn_)
        S = load(p)
        arr = S.get("sources", S) if isinstance(S, dict) else S
        ch = False
        for s in arr:
            if s.get("id") in only_gone and not s.get("retired"):
                s["retired"] = True
                s["retired_note"] = "cited only by content dated after Q3 2023, deleted 2026-10-14 (the game ends 7 Oct 2023)"
                retired.append(s["id"])
                ch = True
        if ch:
            save_like(p, S)
    mp = os.path.join(SRC, "map_sources.json")
    MS = load(mp)
    for s in MS:
        if s.get("id") in (map_before - map_after) and not s.get("retired"):
            s["retired"] = True
            s["status"] = "retired"
            s["retired_note"] = "cited only by the map era after Q3 2023, deleted 2026-10-14"
            retired.append("MAP:" + s["id"])
    save_like(mp, MS)
    bump("sources retired", len(retired))

    print(json.dumps({"deleted_events": gone_ev, "deleted_forks": gone_fk, "deleted_wars": gone_war,
                      "deleted_map_eras": gone_era, "retired_sources": sorted(retired)}, indent=1))
    for k in sorted(counts):
        print("%-60s %d" % (k, counts[k]))


if __name__ == "__main__":
    main()
