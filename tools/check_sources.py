#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""History-data provenance checker for Civilization: Israel.

Usage:
  python tools/check_sources.py            # offline structural checks (must pass before history ships)
  python tools/check_sources.py --net      # also fetch every cited URL (falls back to web.archive.org)
                                           # and confirm each quote appears in the page text
  python tools/check_sources.py --render   # regenerate sources/SOURCES.md from sources/sources.json, then check

Data:
  game/data/events.json   events with `source` ids, per-claim `cite` list, `affected_populations`, `choices[].source/cite`
  game/data/cities.json   cities with `source`, `population_source`, `status[].source`
  sources/sources.json    master source list (SOURCES.md is rendered from it)

Fails (exit 1) when:
  - (round 4) a city status[] entry has an empty cite; a city has no founded cite (pre-1948 cities need a cite for existence);
    a source rests only on Wikipedia (any language); a status quote names neither the town nor an alias (warning if the
    source is a list/table); with --net, events whose ONLY cites are unreachable web.archive.org copies are listed (no fail);
  - an event, city, choice or cite references a source id that does not exist;
  - an event has no `cite`, or one of its `source` ids is never backed by a cite entry;
  - a cite has neither (url + verbatim quote) nor a print page number;
  - a cited source has no live or archived URL and no page number in the citing entry;
  - a source is accessed: n/a / via-Wikipedia / snippet-only (opened=false) and a citation of it has no quote or page;
  - a casualty / displacement / war-type event has no `affected_populations`, or (war, military_operation,
    terrorism, displacement) lacks an Israeli group or a non-Israeli group, or an entry gives no figure / "none reported";
  - a choice set does not have exactly one historical option, or a non-historical option has no source + cite;
  - an event's turn does not match the contract formula, ids repeat, or SOURCES.md is out of sync.
"""
import json, os, re, sys, html, hashlib, gzip, io, time, argparse, unicodedata
import urllib.request, urllib.error
from concurrent.futures import ThreadPoolExecutor

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
EV = os.path.join(ROOT, "game", "data", "events.json")
CI = os.path.join(ROOT, "game", "data", "cities.json")
SJ = os.path.join(ROOT, "sources", "sources.json")
SM = os.path.join(ROOT, "sources", "SOURCES.md")
SIMJ = os.path.join(ROOT, "sources", "sim_sources.json")   # gameplay sources (S500-S699, S750-S799, S900-S999, S5000-S5999; owned by the sim builder)
MAPJ = os.path.join(ROOT, "sources", "map_sources.json")   # map sources ([MAP:id], owned by the map builder)
CACHE = os.path.join(ROOT, "tools", ".source_cache")
CITY_WARNS = []

CASUALTY_KINDS = {"war", "military_operation", "terrorism", "displacement", "disaster", "assassination"}
TWO_SIDED_KINDS = {"war", "military_operation", "terrorism", "displacement"}
NONE = "none reported"
UNQUANTIFIED = "not quantified"   # population affected, but no sourced figure exists


def load(p):
    return json.load(open(p, encoding="utf-8"))


def turn_of(d):
    y, m = int(d[:4]), int(d[5:7])
    return (y - 1948) * 4 + (m - 1) // 3


def is_url(u):
    return isinstance(u, str) and u.startswith(("http://", "https://"))


def cite_ok(c):
    """A cite is verifiable if it has url+quote, or a print page."""
    if c.get("page"):
        return True
    return is_url(c.get("url")) and bool((c.get("quote") or "").strip())


def israeli(group):
    return "israel" in group.lower()


def figure_ok(v):
    if v in (NONE, UNQUANTIFIED):
        return True
    return isinstance(v, list) and len(v) == 2 and all(isinstance(x, (int, float)) for x in v) and v[0] <= v[1]


# ---------------------------------------------------------------- SOURCES.md
def render_md(S):
    L = ["# Sources — Civilization: Israel (history data)", "",
         "Generated from `sources/sources.json` by `python tools/check_sources.py --render`. Do not hand-edit.", "",
         "Each entry: **[Sxxx]** Author/Org, *Title*, Publisher, Year — URL — archived URL — accessed date — provenance.",
         "Provenance: `opened` = the page/file was opened and the quoted claims checked; `not_opened` / `snippet` = "
         "listed for reference only — such a source may be cited only through a `cite` entry that carries a verbatim quote "
         "from an opened URL (original or web.archive.org) or a print page number. Per-claim quotes live in the `cite` "
         "lists of `game/data/events.json`.", ""]
    for s in sorted(S, key=lambda s: int(s["id"][1:])):
        if s.get("retired"):
            L.append(f"**[{s['id']}]** RETIRED (no longer cited{'; superseded by ' + s['superseded_by'] if s.get('superseded_by') else ''}) — {s['citation']} — {s.get('url') or 'no URL'}")
            L.append("")
            continue
        L.append(f"**[{s['id']}]** {s['citation']} — {s.get('url') or 'no URL (print)'} — archived: {s.get('archived_url') or 'n/a'} — accessed: {s.get('accessed') or 'n/a'} — provenance: {s.get('provenance', 'opened' if s.get('opened') else 'not_opened')}")
        if s.get("mirror_of"):
            L.append(f"  - Mirror/digest of: {s['mirror_of']}")
        if s.get("note"):
            L.append(f"  - Note: {s['note']}")
        if s.get("supports"):
            L.append("  - Supports:")
            for x in s["supports"]:
                L.append(f"    - {x}")
        L.append("")
    open(SM, "w", encoding="utf-8").write("\n".join(L))


# ---------------------------------------------------------------- content after the end of the game
GAME_END = "2023-09-30"   # the game ends after Q3 2023 (turn 302); everything later was deleted (the user, 2026-10-14)
GAME_END_TURN = 302
DATA = os.path.join(ROOT, "game", "data")
# bibliography and file metadata are not content; the memorial is the user's own text
_BIB_KEYS = {"url", "archived_url", "quote", "accessed", "page", "generated", "citation", "provenance", "file", "file_small",
             "cbs_code", "elevation_m", "_meta", "credit", "credits", "license", "prompt", "model"}
_DATE_KEYS = {"year", "until", "from", "hist", "date", "date_end", "to", "start", "end"}
_YEAR_RE = re.compile(r"(?<![\d/.-])(20[2-9]\d)(?!\d)")
_RANGE_RE = re.compile(r"\b(?:1[89]\d\d|20\d\d)\s*[-–]\s*(20[2-9]\d)\b")


def _late_years(text):
    out = []
    for m in list(_YEAR_RE.finditer(text)) + list(_RANGE_RE.finditer(text)):
        y = int(m.group(1))
        pre = text[max(0, m.start() - 12):m.start()].lower()
        if pre.endswith(("decision ", "resolution ", "no. ", "code ", "החלטת ממשלה ", "החלטה ", "החלטת ")):
            continue
        if 2023 < y < 2100:
            out.append(y)
    return out


def _late_date(v):
    if isinstance(v, bool) or v is None:
        return False
    if isinstance(v, (int, float)):
        return 2023 < v < 2100
    s = str(v)
    if re.match(r"^\d{4}-\d{2}-\d{2}", s):
        return s[:10] > GAME_END
    if re.match(r"^\d{4}-\d{2}$", s):
        return s > GAME_END[:7]
    if re.match(r"^\d{4}$", s):
        return 2023 < int(s) < 2100
    return False


def after_end_scan(dead):
    """Deleted-content scan (v3, 2026-10-14): no tombstoned id and no date or year after Q3 2023 anywhere in the game
    data, the Hebrew data catalogs or the UI catalogs. Whitelisted: data/ending_oct7.json (the memorial), the ghost and
    scenario saves (numbers), portrait eras in art_manifest.json, map tile/border coordinates, bibliography keys."""
    import glob as _g
    errs = []

    def walk(where, x, key=""):
        if len(errs) >= 200 or key in _BIB_KEYS:
            return
        if isinstance(x, dict):
            for k, v in x.items():
                if k in dead:
                    errs.append(f"{where}: deleted id {k} used as a key")
                walk(where, v, k)
        elif isinstance(x, list):
            for v in x:
                walk(where, v, key)
        elif isinstance(x, str):
            if x in dead:
                errs.append(f"{where}.{key}: deleted id {x}")
            elif key in ("source", "sources", "id"):
                pass   # S-ids and record ids are not years
            elif key in _DATE_KEYS and _late_date(x):
                errs.append(f"{where}.{key} = {x} (date after Q3 2023)")
            elif _late_years(x):
                errs.append(f"{where}.{key}: mentions {_late_years(x)[0]}: {x[:90]}")
        elif isinstance(x, (int, float)) and not isinstance(x, bool):
            if key == "turn" and x > GAME_END_TURN:
                errs.append(f"{where}.turn = {x} (after the last turn)")
            elif key in _DATE_KEYS and _late_date(x):
                errs.append(f"{where}.{key} = {x} (year after 2023)")

    for p in sorted(_g.glob(os.path.join(DATA, "**", "*.json"), recursive=True)):
        rel = os.path.relpath(p, DATA).replace(os.sep, "/")
        if rel in ("ghost.json", "ending_oct7.json") or rel.startswith("scenarios/"):
            continue
        d = load(p)
        if rel == "map.json":
            d = {k: d.get(k) for k in ("border_eras", "places", "natural_wonders", "field_notes")} | {
                k: list((d.get(k) or {}).keys()) for k in ("borders", "military_control", "areas")}
        elif rel == "art_manifest.json":
            d = dict(d)
            d["portraits"] = {k: {kk: vv for kk, vv in v.items() if kk not in ("era_from", "era_to")}
                              for k, v in (d.get("portraits") or {}).items() if isinstance(v, dict)}
        elif rel.startswith("i18n/"):
            d = {k: v for k, v in d.items() if k != "_meta"}
        if rel.startswith("wars/") and os.path.splitext(os.path.basename(p))[0] in dead:
            errs.append(f"wars/{os.path.basename(p)}: a deleted war file is back")
        walk(rel, d)
    for p in sorted(_g.glob(os.path.join(ROOT, "game", "i18n", "he", "*.json"))):
        for k, v in load(p).items():
            if not str(k).startswith("_"):
                walk("i18n/he/" + os.path.basename(p), {"en": str(k), "he": str(v)})
    return errs


# ---------------------------------------------------------------- offline checks
def cross_piece(S):
    """Ids must be unique across history, sim and map source lists; history must stay out of the gameplay ranges."""
    errs = []
    pieces = {"history": S}
    for name, path in (("sim", SIMJ), ("map", MAPJ)):
        if os.path.exists(path):
            d = load(path)
            pieces[name] = d if isinstance(d, list) else d.get("sources", [])
    owner = {}
    for name, lst in pieces.items():
        seen = set()
        for x in lst:
            i = x.get("id")
            if i in seen:
                errs.append(f"{name}: duplicate id {i}")
            seen.add(i)
            if i in owner and owner[i] != name:
                errs.append(f"id collision: {i} used by both {owner[i]} and {name}")
            owner.setdefault(i, name)
    for x in S:
        m = re.match(r"S(\d+)$", x["id"])
        if m and (500 <= int(m.group(1)) <= 699 or 750 <= int(m.group(1)) <= 799 or 900 <= int(m.group(1)) <= 999 or 5000 <= int(m.group(1)) <= 5999):
            errs.append(f"history source {x['id']} is in a reserved gameplay range (S500-S699, S750-S799, S900-S999, S5000-S5999)")
    return errs


GAME_START = "1948-05-14"


def _d(s):
    """Normalise '1948' / '1948-07' / '1948-07-16' to a comparable 'YYYY-MM-DD' (None if not a date)."""
    if s is None or not re.match(r"^\d{4}(-\d{2}){0,2}$", str(s)):
        return None
    s = str(s)
    return s + "-01-01" if len(s) == 4 else (s + "-01" if len(s) == 7 else s)


def city_timeline(C, SID):
    """Localities must exist only from their founding and be Israeli-held only from a dated capture/transfer:
    - `founded` is required: a date, or "pre-1948" for places older than the state;
    - a locality existing at game start (14 May 1948) needs a status covering that date (e.g. contested before capture);
    - a locality founded later must not have a status or a census figure before its founding, and needs `founded_source`;
    - a status starting in 1948-49 (the war and armistices) must be dated at least to the month."""
    errs = []
    for c in C:
        cid, f = c["id"], c.get("founded")
        sts = c.get("status") or []
        if f is None or f == "":
            errs.append(f"city {cid}: no founded date (use a date, or \"pre-1948\" with founded_note)")
            continue
        fd = _d(f)
        if fd is None and f != "pre-1948":
            errs.append(f"city {cid}: founded '{f}' is neither a date nor \"pre-1948\"")
            continue
        pre = f == "pre-1948" or fd <= GAME_START
        if pre:
            if not any((_d(s.get("from")) or "0000") <= GAME_START < (_d(s.get("to")) or "9999") for s in sts):
                errs.append(f"city {cid}: exists at game start but has no status dated at turn 1 ({GAME_START})")
        else:
            if not c.get("founded_source") or c["founded_source"] not in SID:
                errs.append(f"city {cid}: founded {f} lacks a valid founded_source")
            elif not any(x.get("quote") and x.get("source") == c["founded_source"] for x in c.get("founded_cite") or []):
                errs.append(f"city {cid}: founded {f} has no quoted founded_cite from {c['founded_source']}")
            for s in sts:
                if (_d(s.get("from")) or "0000") < fd:
                    errs.append(f"city {cid}: status {s.get('status')} from {s.get('from')} predates founding {f}")
            for y, v in (c.get("population") or {}).items():
                if v is not None and str(y)[:4] < f[:4]:
                    errs.append(f"city {cid}: population figure for {y} predates founding {f}")
        for s in sts:
            fr = str(s.get("from") or "")
            if re.fullmatch(r"194[89]", fr):
                errs.append(f"city {cid}: status {s.get('status')} from year-only '{fr}' (war years need a month or day)")
            if not s.get("source"):
                errs.append(f"city {cid}: status {s.get('status')} from {fr} has no source")
    return errs


# ---------------------------------------------------------------- round-4 hardening
WIKI_RE = re.compile(r"^https?://([a-z\-]+\.)?(m\.)?wikipedia\.org/|^https?://([a-z\-]+\.)?wikimedia\.org/|^https?://web\.archive\.org/web/[^/]+/https?://([a-z\-]+\.)?(m\.)?wikipedia\.org/", re.I)
LIST_HINT = re.compile(r"\.xlsx?($|\?)|\.csv|list of|table|census|bycode|locality|\bcbs\b|register|index", re.I)
# aliases (transliteration variants / old names) accepted for rule (d); a city may also carry an `aliases` list
ALIASES = {
    "acre": ["akko", "acco", "acre", "עכו"],
    "beit_shean": ["beisan", "bet shean", "beth shean", "beit she'an", "bet she'an", "beth-shean", "baysan", "beit shean"],
    "qalqilya": ["qalqilyah", "kalkilya", "qalqiliya", "kalkiliya", "qalqilia", "kalkilia"],
    "jenin": ["janin", "jenin"],
    "sakhnin": ["sakhnin", "sikhnin", "sakhnin", "sukhnin"],
    "abu_ghosh": ["abu gosh", "abu ghosh", "abu ghosh", "abu-ghosh"],
    "lod": ["lydda", "lod", "ludd", "lydda"],
    "ramla": ["ramle", "ramleh", "ramla"],
    "tiberias": ["tiberias", "tveria", "teveria"],
    "beer_sheva": ["beersheba", "beer sheva", "be'er sheva", "beersheva", "beer-sheba", "bir as-saba", "bir al-sab"],
    "kiryat_shmona": ["qiryat shemona", "kiryat shemona", "kiryat shmona", "qiryat shmona", "kiryat shemonah"],
    "ashkelon": ["ashkelon", "majdal", "migdal gad", "al-majdal", "ascalon", "askalan"],
    "haifa": ["haifa", "hefa"],
    "nazareth": ["nazareth", "nasra", "natzrat"],
    "safed": ["safed", "tsfat", "zefat", "tzfat", "safad", "tsefat"],
    "eilat": ["eilat", "elat", "umm rashrash", "um rashrash", "umm al-rashrash"],
    "rahat": ["rahat", "rahat"],
    "yamit": ["yamit"],
    "neve_dekalim": ["neve dekalim", "nevei dekalim", "neve-dekalim"],
}


def _nm(t):
    return re.sub(r"[^\w]+", "", norm(t))


def city_cite_rules(C, SID):
    """Round-4 rules: (a) every status entry carries a non-empty cite; (b) every city has a founded cite
    (a pre-1948 city needs a cite for its existence); (c) no source rests only on Wikipedia; (d) a status quote names the town."""
    fails = {"a": [], "b": [], "c": [], "d": []}
    warns = []
    for c in C:
        cid = c["id"]
        for st in c.get("status") or []:
            cl = [x for x in st.get("cite") or [] if cite_ok(x)]
            if not cl:
                fails["a"].append(f"city {cid}: status {st.get('status')} from {st.get('from')} has an empty cite")
                continue
            names = {c.get("name", ""), c.get("name_he", ""), cid.replace("_", " ")} | set(c.get("aliases") or []) | set(ALIASES.get(cid, []))
            names = {_nm(n) for n in names if n}
            named = 0
            for x in cl:
                q = _nm(x.get("quote") or "")
                if not q:
                    named += 1   # print cite with a page number only
                    continue
                if any(n and n in q for n in names):
                    named += 1
                    continue
                src = SID.get(x.get("source"), {})
                tablelike = bool(LIST_HINT.search((x.get("url") or "") + " " + (src.get("citation") or "")))
                if x.get("covers"):
                    continue   # a primary document for a whole TYPE of transfer (e.g. armistice Art. VI); `covers` says why it applies
                msg = f"city {cid}: status {st.get('status')} from {st.get('from')}: quote from {x.get('source')} does not name the town or an alias"
                (warns if tablelike else fails["d"]).append(msg)
            if not named:
                fails["d"].append(f"city {cid}: status {st.get('status')} from {st.get('from')}: no cite in this entry names the town")
        for st in c.get("status") or []:
            for x in st.get("cite") or []:
                if SID.get(x.get("source"), {}).get("retired"):
                    fails["c"].append(f"city {cid}: status cite uses retired source {x.get('source')}")
        fc = [x for x in c.get("founded_cite") or [] if cite_ok(x)]
        if c.get("founded") == "pre-1948":
            if not fc and not [x for st in c.get("status") or [] for x in st.get("cite") or [] if cite_ok(x)]:
                fails["b"].append(f"city {cid}: pre-1948 with no cite for its existence")
        elif not fc:
            fails["b"].append(f"city {cid}: no founded cite (founded {c.get('founded')})")
    for sid, s in SID.items():
        if s.get("retired"):
            continue
        urls = [u for u in (s.get("url"), s.get("archived_url")) if u]
        if re.match(r"\s*(via )?wikipedia", s.get("citation") or "", re.I) or (urls and all(WIKI_RE.match(u) for u in urls)):
            fails["c"].append(f"source {sid} rests only on Wikipedia: {(s.get('citation') or '')[:70]}")
    return fails, warns


def check(E, C, S):
    errs = cross_piece(S)
    SID = {s["id"]: s for s in S}
    RETIRED = {s["id"] for s in S if s.get("retired")}
    # CONTRACT: ids are validated across the source files. Events may also cite opened gameplay sources
    # (sim_sources.json, S5000-S5999 etc.) through a quoted cite with a URL (v2 fix round, fix-wars-events).
    SID_HIST = dict(SID)
    if os.path.exists(SIMJ):
        for s in load(SIMJ):
            if s.get("id") not in SID:
                SID[s["id"]] = s
                if s.get("retired"):
                    RETIRED.add(s["id"])
    for s in S:
        if s.get("retired"):
            continue
        if not (is_url(s.get("url")) or is_url(s.get("archived_url")) or s.get("kind") == "print"):
            errs.append(f"{s['id']}: no live or archived URL and not marked print")
    quoted_sources = set()  # sources that have at least one verified cite somewhere
    seen = set()
    for e in E:
        eid = e.get("id", "?")
        if eid in seen:
            errs.append(f"{eid}: duplicate event id")
        seen.add(eid)
        if not ("1948-05-14" <= e["date"] <= GAME_END):
            errs.append(f"{eid}: date {e['date']} outside the game period (14 May 1948 - 30 Sep 2023; nothing after Q3 2023)")
        if e.get("turn") != turn_of(e["date"]):
            errs.append(f"{eid}: turn {e.get('turn')} != {turn_of(e['date'])}")
        cites = list(e.get("cite") or [])
        for ch in e.get("choices") or []:
            cites += ch.get("cite") or []
        if not e.get("cite"):
            errs.append(f"{eid}: no cite entries")
        for sid in e.get("source", []):
            if sid not in SID:
                errs.append(f"{eid}: source {sid} missing from sources.json")
        backed = set()
        for c in cites:
            sid = c.get("source")
            if sid not in SID:
                errs.append(f"{eid}: cite references missing source {sid}")
                continue
            if not cite_ok(c):
                errs.append(f"{eid}: cite for {sid} has no url+quote and no page ({c.get('claim','')[:50]})")
                continue
            src = SID[sid]
            if sid in RETIRED:
                errs.append(f"{eid}: cites retired source {sid}")
            if not c.get("page") and not (is_url(c.get("url"))):
                errs.append(f"{eid}: cite for {sid} has no URL and no page")
            if src.get("kind") == "print" and not c.get("page") and not is_url(c.get("url")):
                errs.append(f"{eid}: print source {sid} cited without page")
            backed.add(sid)
            quoted_sources.add(sid)
        for sid in e.get("source", []):
            if sid in SID and sid not in backed:
                prov = SID[sid].get("provenance")
                errs.append(f"{eid}: source {sid} ({prov}) has no quote/page cite in this event")
        # affected populations
        ef = e.get("effects", {})
        needs = bool(ef.get("casualties") or ef.get("displacement")) or e.get("kind") in CASUALTY_KINDS
        if needs:
            ap = e.get("affected_populations") or []
            if not ap:
                errs.append(f"{eid}: casualty/displacement event without affected_populations")
            else:
                for a in ap:
                    figs = [a.get(k) for k in ("killed", "wounded", "displaced") if k in a]
                    if not a.get("group") or not figs or not all(figure_ok(v) for v in figs):
                        errs.append(f"{eid}: affected_populations entry needs group and killed/wounded/displaced as [lo,hi] or '{NONE}': {a}")
                if e.get("kind") in TWO_SIDED_KINDS:
                    groups = [a.get("group", "") for a in ap]
                    if not any(israeli(g) for g in groups) or not any(not israeli(g) for g in groups):
                        errs.append(f"{eid}: affected_populations must list an Israeli and a non-Israeli population (use '{NONE}')")
        # choices
        chs = e.get("choices") or []
        if chs:
            if len(chs) < 2:
                errs.append(f"{eid}: a choice set needs at least 2 options")
            if sum(1 for c in chs if c.get("historical")) != 1:
                errs.append(f"{eid}: choices need exactly one historical option")
            for c in chs:
                if not c.get("historical"):
                    if not c.get("source") or not any(cite_ok(x) for x in c.get("cite") or []):
                        errs.append(f"{eid}: non-historical choice '{c.get('label','')[:40]}' lacks source + quoted cite")
                for sid in c.get("source", []):
                    if sid not in SID:
                        errs.append(f"{eid}: choice source {sid} missing")
    # unopened sources may only be used through quoted/paged cites (already enforced per event)
    for c in C:
        cid = c["id"]
        for sid in c.get("source", []):
            if sid not in SID:
                errs.append(f"city {cid}: source {sid} missing")
        for y, sid in (c.get("population_source") or {}).items():
            if sid not in SID:
                errs.append(f"city {cid}: population {y} source {sid} missing")
            elif not (is_url(SID[sid].get("url")) or is_url(SID[sid].get("archived_url"))):
                errs.append(f"city {cid}: population {y} source {sid} has no URL")
        for st in c.get("status", []):
            stc = [x for x in st.get("cite") or [] if cite_ok(x)]
            for x in st.get("cite") or []:
                if x.get("source") not in SID:
                    errs.append(f"city {cid}: status cite references missing source {x.get('source')}")
            backed = {x.get("source") for x in stc}
            for sid in st.get("source", []):
                if sid not in SID:
                    errs.append(f"city {cid}: status source {sid} missing")
                elif sid not in backed and not SID[sid].get("opened"):
                    errs.append(f"city {cid}: status ({st.get('status')}, {st.get('from')}) cites unopened source {sid} without a quoted cite")
    errs += city_timeline(C, SID_HIST)
    _f, _w = city_cite_rules(C, SID_HIST)
    for k in "abcd":
        errs += [f"[rule {k}] " + m for m in _f[k]]
    global CITY_WARNS
    CITY_WARNS = _w
    # SOURCES.md sync
    if os.path.exists(SM):
        md = open(SM, encoding="utf-8").read()
        missing = [s["id"] for s in S if f"**[{s['id']}]**" not in md]
        if missing:
            errs.append(f"SOURCES.md out of sync (missing {missing[:5]}...); run with --render")
    else:
        errs.append("SOURCES.md missing; run with --render")
    return errs


# ---------------------------------------------------------------- network checks
def norm(t):
    t = unicodedata.normalize("NFKC", t)
    t = t.replace("’", "'").replace("‘", "'").replace("“", '"').replace("”", '"')
    t = re.sub("[ʼʾʿʻ′`]", "'", t)  # modifier-letter apostrophes (transliterations)
    t = t.replace("–", "-").replace("—", "-").replace(" ", " ").replace("­", "")
    t = re.sub(r"\s+", " ", t)
    return t.lower().strip()


def page_text(raw, ctype, url):
    if raw[:4] == b"%PDF" or url.lower().endswith(".pdf"):
        try:
            import pdfplumber
            out = []
            with pdfplumber.open(io.BytesIO(raw)) as pdf:
                for pg in pdf.pages:
                    out.append(pg.extract_text() or "")
                    w, h = pg.width, pg.height
                    for box in ((0, 0, w / 2, h), (w / 2, 0, w, h)):  # two-column layouts (UN documents)
                        try:
                            out.append(pg.crop(box).extract_text() or "")
                        except Exception:
                            pass
            return "\n".join(out)
        except Exception:
            return raw.decode("latin-1", "ignore")
    if url.lower().endswith((".xls", ".xlsx")) or raw[:2] == b"PK" or raw[:4] == b"\xd0\xcf\x11\xe0":
        rows = []
        try:  # spreadsheets: one line per row, cells joined with " | "
            if raw[:2] == b"PK":
                import openpyxl
                wb = openpyxl.load_workbook(io.BytesIO(raw), read_only=True)
                for ws in wb.worksheets:
                    for r in ws.iter_rows(values_only=True):
                        rows.append(" | ".join("" if v is None else str(v) for v in r))
            else:
                import xlrd
                wb = xlrd.open_workbook(file_contents=raw)
                for sh in wb.sheets():
                    for i in range(sh.nrows):
                        rows.append(" | ".join(str(int(v)) if isinstance(v, float) and v == int(v) else str(v)
                                               for v in sh.row_values(i)))
        except Exception:
            pass
        return "\n".join(rows)
    t = raw.decode("utf-8", "ignore")
    t = re.sub(r"(?is)<(script|style|noscript)[^>]*>.*?</\1>", " ", t)
    t = re.sub(r"<[^>]+>", " ", t)
    return html.unescape(t)


PDF_URLS = set()
UNREACH = set()   # URLs that could not be opened (live or archived) in this --net run


def fetch(url):
    os.makedirs(CACHE, exist_ok=True)
    key = os.path.join(CACHE, hashlib.sha1(url.encode()).hexdigest())
    if os.path.exists(key):
        try:
            d = json.load(open(key, encoding="utf-8"))
            if d.get("pdf"):
                PDF_URLS.add(d["final"])
            return d["text"], d["final"]
        except Exception:
            os.remove(key)
    tries = [url]
    if "web.archive.org" not in url:
        tries.append("https://web.archive.org/web/2026/" + url)
    def rawurl(u):  # ask the Wayback Machine for the original bytes, not the toolbar frame
        return re.sub(r"(web\.archive\.org/web/\d+)(/)", r"\1id_\2", u) if "web.archive.org/web/" in u and "id_/" not in u else u
    for u in tries:
        u = rawurl(u)
        try:
            req = urllib.request.Request(u, headers={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) civ-history-checker/1.0", "Accept-Encoding": "gzip"})
            r = urllib.request.urlopen(req, timeout=45)
            raw = r.read()
            if r.headers.get("Content-Encoding") == "gzip":
                raw = gzip.decompress(raw)
            text = page_text(raw, r.headers.get("Content-Type", ""), u)
            low = text.lower()
            blocked = len(text.strip()) < 1500 or "just a moment" in low or "access denied" in low or "enable javascript" in low or "captcha" in low
            if blocked and u is not tries[-1]:
                continue
            if raw[:4] == b"%PDF":
                PDF_URLS.add(u)
            json.dump({"text": text, "final": u, "pdf": raw[:4] == b"%PDF"}, open(key, "w", encoding="utf-8"))
            return text, u
        except Exception:
            time.sleep(1)
            continue
    return None, None


def pdf_match(frag, toks, gap=60):
    """Layout-tolerant match for PDF text: the fragment's words must occur in order, each within `gap`
    tokens of the previous one; every number must be present; at most ~10% of other words may be
    missing (words split by hyphenation or OCR)."""
    W = re.findall(r"\w+", norm(frag))
    if not W:
        return True
    allow = max(1, len(W) // 10)
    starts = [i for i, t in enumerate(toks) if t == W[0]] + ([i for i, t in enumerate(toks) if t == W[1]] if len(W) > 1 else [])
    for s in starts[:400]:
        p, miss = s, 0
        for k, w in enumerate(W):
            if k == 0 and toks[s] != w:
                miss += 1
                continue
            j = next((x for x in range(p, min(len(toks), p + gap)) if toks[x] == w), None)
            if j is None:
                if w.isdigit() or any(ch.isdigit() for ch in w):
                    miss = allow + 1
                    break
                miss += 1
                if miss > allow:
                    break
                continue
            p = j + 1
        if miss <= allow:
            return True
    return False


def ocr_match(frag, text):
    """Best character-level similarity of `frag` to a same-length window of `text` (for OCR'd scans)."""
    import difflib
    f = norm(frag)
    t = norm(text)
    words = sorted(set(re.findall(r"\w{6,}", f)), key=len, reverse=True)[:5] or re.findall(r"\w+", f)[:3]
    best, L = 0.0, len(f)
    for w in words:
        off = f.find(w)
        for m in list(re.finditer(re.escape(w), t))[:50]:
            for a in range(max(0, m.start() - off - 15), max(0, m.start() - off) + 16, 5):
                best = max(best, difflib.SequenceMatcher(None, f, t[a:a + L], autojunk=False).ratio())
    return best


def net_check(E, C=()):
    pairs = {}
    for city in C:
        for c in city.get("founded_cite") or []:
            if is_url(c.get("url")) and c.get("quote"):
                pairs.setdefault(c["url"], []).append(("city " + city["id"] + " founded", c["quote"]))
        for st in city.get("status", []):
            for c in st.get("cite") or []:
                if is_url(c.get("url")) and c.get("quote"):
                    pairs.setdefault(c["url"], []).append(("city " + city["id"], c["quote"]))
    for e in E:
        allc = list(e.get("cite") or [])
        for ch in e.get("choices") or []:
            allc += ch.get("cite") or []
        for c in allc:
            if is_url(c.get("url")) and c.get("quote"):
                pairs.setdefault(c["url"], []).append((e["id"], c["quote"]))
    errs = []
    def one(u):
        text, final = fetch(u)
        out = []
        if text is None:
            UNREACH.add(u)
            out.append(f"WARN-NET {u}: unreachable (live and archive); quotes not re-checked")
            return out
        loose = lambda t: re.sub(r"[\W_]+", "", norm(t))  # ignore punctuation/spacing/typography (keeps Hebrew/Arabic letters)
        nt = loose(text)
        is_pdf = final in PDF_URLS or bool(re.search(r"\.pdf\b|t=pdf|symbol/access", final, re.I))
        toks = re.findall(r"\w+", norm(text)) if is_pdf else None
        for eid, q in pairs[u]:
            # tolerate ellipses: every fragment must be present
            raw_frags = [f for f in re.split(r"\.\.\.|…|\[\.\.\.\]", q) if len(loose(f)) > 3]
            ok = all(loose(f) in nt for f in raw_frags)
            if not ok and is_pdf:
                # multi-column / scanned PDFs interleave columns and split words; accept an in-order word match
                ok = all(loose(f) in nt or pdf_match(f, toks) for f in raw_frags)
            if not ok and is_pdf and all(loose(f) in nt or pdf_match(f, toks) or ocr_match(f, text) >= 0.88 for f in raw_frags):
                out.append(f"WARN-OCR {eid}: quote matches {final} only approximately (scanned/OCR text): \"{q[:80]}\"")
                continue
            if not ok:
                out.append(f"NET {eid}: quote not found at {final}: \"{q[:80]}\"")
        return out
    with ThreadPoolExecutor(8) as ex:
        for r in ex.map(one, list(pairs)):
            errs += r
    return errs, len(pairs)


def archive_only_unreachable(E):
    """(e) events whose ONLY cites are web.archive.org copies, all unreachable in this run. Reported, not failed."""
    out = []
    for e in E:
        urls = [c.get("url") for c in list(e.get("cite") or []) if is_url(c.get("url"))]
        if urls and all("web.archive.org" in u for u in urls) and all(u in UNREACH for u in urls):
            out.append(e["id"])
    return out


EG = os.path.join(ROOT, "game", "data", "era_goals.json")   # V4 era goals (v4-goals)


def check_era_goals(S):
    """V4 era goals: 3 per era (24), every source id exists and is opened with a URL, at least one source per goal carries a
    verbatim quote, dates inside the game period, no goal text from after Q3 2023 (fail list, not warnings)."""
    errs = []
    if not os.path.exists(EG):
        return errs
    D = load(EG)
    SID = {s["id"]: s for s in S}
    if os.path.exists(SIMJ):
        for s in load(SIMJ):
            SID.setdefault(s["id"], s)
    per = {}
    seen = set()
    for g in D.get("goals", []):
        gid = g.get("id", "?")
        if gid in seen:
            errs.append(f"era goal {gid}: duplicate id")
        seen.add(gid)
        per[g.get("era")] = per.get(g.get("era"), 0) + 1
        for k in ("title", "text", "history"):
            if not g.get(k):
                errs.append(f"era goal {gid}: no {k}")
        src = g.get("source") or []
        if not src:
            errs.append(f"era goal {gid}: no source")
        quoted = False
        for sid in src:
            so = SID.get(sid)
            if so is None:
                errs.append(f"era goal {gid}: unknown source id {sid}")
                continue
            if so.get("retired"):
                errs.append(f"era goal {gid}: retired source {sid}")
            if so.get("opened") is False or so.get("provenance") not in (None, "opened", "primary"):
                errs.append(f"era goal {gid}: source {sid} was not opened")
            if not (is_url(so.get("url")) or is_url(so.get("archived_url")) or so.get("kind") == "print"):
                errs.append(f"era goal {gid}: source {sid} has no URL")
            if so.get("quote") or sid in {x["id"] for x in S}:
                quoted = True
        if not quoted:
            errs.append(f"era goal {gid}: no history source and no gameplay source with a verbatim quote")
        for k in ("at", "by"):
            if g.get(k) and not ("1948-05" <= g[k] <= "2023-09"):
                errs.append(f"era goal {gid}: {k} {g[k]} outside the game period")
        if g.get("check") == "at" and not g.get("at") or g.get("check") == "by" and not g.get("by"):
            errs.append(f"era goal {gid}: check '{g.get('check')}' without its date")
        for k in ("reward", "setback"):
            if (g.get(k) or {}).get("kind") not in ("track_bonus", "programme_discount", "stream", "story_beat", "none"):
                errs.append(f"era goal {gid}: {k} kind {(g.get(k) or {}).get('kind')!r} is not allowed (a goal never ends the game)")
        blob = json.dumps(g, ensure_ascii=False).lower()
        for bad in ("7 october 2023", "oct 7", "gaza war", "2024", "2025", "2026"):
            if bad in blob:
                errs.append(f"era goal {gid}: contains '{bad}' (nothing after Q3 2023)")
    if len(seen) != 24 or any(per.get(f"era{i}") != 3 for i in range(1, 9)):
        errs.append(f"era goals: need 24 goals, three per era (have {len(seen)}: {per})")
    return errs


def main():
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    ap = argparse.ArgumentParser()
    ap.add_argument("--net", action="store_true")
    ap.add_argument("--render", action="store_true")
    ap.add_argument("--strict", action="store_true", help="with --net, also fail on URLs that cannot be fetched (bot-blocked sites)")
    a = ap.parse_args()
    E, C, S = load(EV), load(CI), load(SJ)
    if a.render:
        render_md(S)
    errs = check(E, C, S)
    errs += check_era_goals(S)
    # content the user permanently deleted (7 Oct 2023 / Gaza war, 2026-10-11): its ids must never come back
    hist = os.path.join(os.path.dirname(os.path.abspath(__file__)), "history", "data")
    del_ev = set(json.load(open(os.path.join(hist, "deleted_event_ids.json"), encoding="utf-8")))
    del_src = set(json.load(open(os.path.join(hist, "deleted_source_ids.json"), encoding="utf-8")))
    errs += [f"deleted event re-added: {e['id']}" for e in E if e.get("id") in del_ev]
    errs += [f"deleted source id reused: {s['id']}" for s in S if s.get("id") in del_src]
    errs += [f"{c['id']}: Yellow Line status re-added" for c in C for st in c.get("status") or []
             if "yellow_line" in (st.get("status") or "")]
    # everything dated after Q3 2023 was deleted (2026-10-14); its event, fork and war ids are tombstoned with the rest
    late = after_end_scan(del_ev)
    print(f"deleted-content scan: {len(del_ev)} tombstoned ids, {len(late)} hit(s) after Q3 2023 in game/data and the catalogs")
    errs += ["after the end of the game: " + x for x in late]
    nurl = 0
    warns = []
    if a.net:
        nerrs, nurl = net_check(E, C)
        warns = [x for x in nerrs if x.startswith("WARN")]
        print(f"{sum(x.startswith('WARN-OCR') for x in warns)} OCR-approximate quote(s), "
              f"{sum(x.startswith('WARN-NET') for x in warns)} unreachable URL(s) (use --strict to fail on these)")
        errs += [x for x in nerrs if not x.startswith("WARN")]
        if a.strict:
            errs += warns
        for x in warns:
            print(x)
        ao = archive_only_unreachable(E)
        print(f"{len(ao)} event(s) whose ONLY cites are unreachable web.archive.org copies (not a failure; needs a live/primary cite):")
        for x in ao:
            print("ARCHIVE-ONLY", x)
    ncites = sum(len(e.get("cite") or []) + sum(len(c.get("cite") or []) for c in e.get("choices") or []) for e in E)
    print(f"events {len(E)}  cities {len(C)}  sources {len(S)}  cites {ncites}" + (f"  urls fetched {nurl}" if a.net else ""))
    if CITY_WARNS:
        print(f"{len(CITY_WARNS)} city status quote(s) in list/table sources do not name the town (warning only)")
    if errs:
        for x in errs:
            print("FAIL", x)
        print(f"{len(errs)} problem(s)")
        sys.exit(1)
    print("OK: all provenance checks passed")


if __name__ == "__main__":
    main()
