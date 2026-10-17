#!/usr/bin/env python3
"""Builds the translator skeletons game/data/i18n/<lang>/<source>.json from the English game data.

    python tools/i18n/make_skeletons.py [--lang he] [--check] [--only fiscal,endings]

Every display string in the data gets an entry {"en": <English>, "he": ""} under its record key and field path
(format: game/i18n/I18N.md). Re-running keeps every existing translation; when the English of an entry changed
since it was translated, the old translation is kept and the entry is marked "stale": true (the game ignores
stale entries until a translator re-checks them and deletes the flag). --check only prints coverage.
"""
import glob
import json
import os
import re
import sys
from datetime import datetime, timezone

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DATA = os.path.join(ROOT, "game", "data")

# keys whose string values are shown to the player
TEXT_KEYS = {
    "name", "title", "summary", "label", "desc", "description", "text", "note", "short", "role", "verdict",
    "commit_label", "risk", "risk_text", "open", "close", "how", "prompt", "question", "explain", "hist",
    "advocate", "tradeoffs", "effects_text", "group", "briefing", "subtitle", "headline", "caption", "goal",
    "status_label", "reason", "detail", "lead", "body", "party", "portfolio", "outcome", "result", "epilogue",
    "paragraphs", "lines", "intro", "flavor", "quote_en_summary", "leader_title", "names",
    "portfolios", "agenda", "pm", "unit", "area", "civilians", "accept_label", "decline_label",
}
# subtrees never translated (sources and citations stay in their original language; paths, ids, files)
SKIP_KEYS = {"cite", "source", "sources", "url", "quote", "file", "file_small", "path", "image", "ref", "refs",
             "claim", "page", "id", "kind", "date", "date_end", "from", "until", "to", "metric", "unit_id",
             "name_he", "title_he", "paragraphs_he", "closing_he", "src", "tiles", "hexes", "borders"}
TOP_SKIP = {"note", "cost_note", "diplomacy_note", "status_rails_note", "version", "generated", "generator",
            "field_notes", "hex_size_note", "terrain_rules", "source_list", "sources", "range"}
ID_RE = re.compile(r"^[a-z0-9_:./\-]+$")


def is_text(s: str) -> bool:
    if not isinstance(s, str):
        return False
    t = s.strip()
    if len(re.findall(r"[A-Za-z]", t)) < 2:
        return False
    if ID_RE.match(t):
        return False
    if t.startswith("res://") or t.startswith("http"):
        return False
    return True


def walk(node, path, out, rec_key, in_text=False):
    """out: {record_key: {field_path: en}}. path is the field path relative to the record."""
    if isinstance(node, dict):
        rid = node.get("id") if isinstance(node.get("id"), str) else None
        for k, v in node.items():
            if k in SKIP_KEYS:
                continue
            if isinstance(v, str):
                if (k in TEXT_KEYS or in_text) and is_text(v):
                    out.setdefault(rec_key, {})[(path + "." if path else "") + k] = v
            else:
                walk(v, (path + "." if path else "") + k, out, rec_key, in_text or k in TEXT_KEYS)
    elif isinstance(node, list):
        for i, v in enumerate(node):
            if isinstance(v, str):
                if in_text and is_text(v):
                    out.setdefault(rec_key, {})[path + "." + str(i)] = v
            else:
                walk(v, path + "." + str(i), out, rec_key, in_text)


def records_of(data, prefix=""):
    """Yields (record_key, record) for the top-level collections of a data file."""
    if isinstance(data, list):
        for i, r in enumerate(data):
            key = r.get("id") if isinstance(r, dict) and isinstance(r.get("id"), str) else str(i)
            yield (prefix + key, r)
        return
    for k, v in data.items():
        if k in TOP_SKIP:
            continue
        if isinstance(v, list) and v and all(isinstance(x, dict) for x in v):
            for i, r in enumerate(v):
                rid = r.get("id") if isinstance(r.get("id"), str) else None
                yield (prefix + k + "/" + (rid if rid else str(i)), r)
        elif isinstance(v, dict) and v and all(isinstance(x, dict) for x in v.values()):
            for rid, r in v.items():
                yield (prefix + k + "/" + rid, r)
        elif isinstance(v, str):
            if is_text(v) and k in TEXT_KEYS:
                yield (prefix + k, {"text": v})
        elif isinstance(v, (dict, list)):
            yield (prefix + k, v)


def collect(data, prefix=""):
    out = {}
    for key, rec in records_of(data, prefix):
        walk(rec, "", out, key, False)
    return out


def load(p):
    with open(p, encoding="utf-8") as f:
        return json.load(f)


def sources():
    """source name -> {record: {field: en}}, plus prefilled Hebrew {source: {record: {field: he}}}."""
    src = {}
    pre = {}
    plain = ["techs", "civics", "buildings", "units", "districts", "policies", "governments", "actors", "diplomacy",
             "endings", "projects", "difficulty", "events", "fiscal"]
    for s in plain:
        p = os.path.join(DATA, s + ".json")
        if os.path.exists(p):
            src[s] = collect(load(p))
    # V4 era goals (v4-goals): "history" is the goal's history line (shown to the player); renamed to the translatable key "hist"
    eg_path = os.path.join(DATA, "era_goals.json")
    if os.path.exists(eg_path):
        eg = load(eg_path)
        for g in eg.get("goals", []):
            if "history" in g:
                g["hist"] = g.pop("history")
        src["era_goals"] = collect(eg)
    # events: title_he already exists
    ev = load(os.path.join(DATA, "events.json"))
    pre["events"] = {e["id"]: {"title": e["title_he"]} for e in ev if isinstance(e, dict) and e.get("title_he") and e.get("id")}
    # choice terms: stream labels per event
    ct = load(os.path.join(DATA, "choice_terms.json"))
    src["choice_terms"] = collect(ct.get("events", {}))
    for p in sorted(glob.glob(os.path.join(DATA, "forks", "*.json"))):
        name = "forks_" + os.path.splitext(os.path.basename(p))[0]
        src[name] = collect(load(p).get("forks", []))
    wars = {}
    for p in sorted(glob.glob(os.path.join(DATA, "wars", "*.json"))):
        d = load(p)
        wid = d.get("id", os.path.splitext(os.path.basename(p))[0])
        w = {}
        walk(d, "", w, wid, False)
        wars.update(w)
    src["wars"] = wars
    # art manifest: portrait names and roles, illustration titles (credits stay as published)
    am = load(os.path.join(DATA, "art_manifest.json"))
    art = {}
    for sect in ("portraits", "events"):
        for rid, r in (am.get(sect) or {}).items():
            for f in ("name", "role", "title", "caption"):
                if isinstance(r.get(f), str) and is_text(r[f]):
                    art.setdefault(sect + "/" + rid, {})[f] = r[f]
    src["art_manifest"] = art
    # places: map places, natural wonders, regions, border eras; cities (name_he prefilled)
    m = load(os.path.join(DATA, "map.json"))
    places = {}
    ppre = {}
    for i, p in enumerate(m.get("places", [])):
        k = "places/" + p.get("name", str(i))
        places[k] = {"name": p["name"]}
        if p.get("name_he"):
            ppre[k] = {"name": p["name_he"]}
    for w in m.get("natural_wonders", []):
        k = "natural_wonders/" + w.get("id", w.get("name", ""))
        places[k] = {"name": w["name"]}
        if w.get("name_he"):
            ppre[k] = {"name": w["name_he"]}
    for reg in sorted({t.get("region") for t in m.get("tiles", []) if t.get("region")}):
        places["regions/" + reg] = {"name": reg}
    for be in m.get("border_eras", []):
        places["border_eras/" + be.get("id", "")] = {"label": be.get("label", "")}
    for c in load(os.path.join(DATA, "cities.json")):
        k = "cities/" + c["id"]
        places[k] = {"name": c["name"]}
        if c.get("name_he"):
            ppre[k] = {"name": c["name_he"]}
    src["places"] = places
    pre["places"] = ppre
    return src, pre


def main():
    lang = "he"
    check = "--check" in sys.argv
    if "--lang" in sys.argv:
        lang = sys.argv[sys.argv.index("--lang") + 1]
    outdir = os.path.join(DATA, "i18n", lang)
    os.makedirs(outdir, exist_ok=True)
    src, pre = sources()
    tot_e = tot_t = 0
    only = sys.argv[sys.argv.index("--only") + 1].split(",") if "--only" in sys.argv else None
    for name in sorted(src):
        if only and name not in only:
            continue
        path = os.path.join(outdir, name + ".json")
        old = load(path) if os.path.exists(path) else {}
        out = {}
        n = t = stale = 0
        for rk in src[name]:
            for fk, en in src[name][rk].items():
                oe = (old.get(rk) or {}).get(fk) or {}
                he = oe.get("he", "") if isinstance(oe, dict) else ""
                e = {"en": en, "he": he}
                if he and isinstance(oe, dict) and oe.get("en") not in (None, en):
                    e["stale"] = True
                elif isinstance(oe, dict) and oe.get("stale"):
                    e["stale"] = True
                if not he and lang == "he":
                    ph = (pre.get(name, {}).get(rk) or {}).get(fk, "")
                    if ph:
                        e["he"] = ph
                out.setdefault(rk, {})[fk] = e
                n += 1
                if e["he"] and not e.get("stale"):
                    t += 1
                if e.get("stale"):
                    stale += 1
        tot_e += n
        tot_t += t
        print("%-28s %5d entries  %5d translated  %4d stale" % (name, n, t, stale))
        if check:
            continue
        meta = {"source": name, "lang": lang, "entries": n, "translated": t,
                "generated": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
                "format": "game/i18n/I18N.md: {record: {field: {en, he[, stale]}}}; fill 'he', keep 'en' as is"}
        doc = {"_meta": meta}
        doc.update(out)
        with open(path, "w", encoding="utf-8", newline="\n") as f:
            json.dump(doc, f, ensure_ascii=False, indent=1)
            f.write("\n")
    print("total %d entries, %d translated (%.0f%%)" % (tot_e, tot_t, 100.0 * tot_t / max(tot_e, 1)))


if __name__ == "__main__":
    main()
