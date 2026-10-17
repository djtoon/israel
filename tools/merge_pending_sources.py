#!/usr/bin/env python3
"""Fold data agents' pending gameplay sources into sources/sim_sources.json, then re-render SIM_SOURCES.md.

Usage:
  python tools/merge_pending_sources.py            # merge sources/pending/*.json into sources/sim_sources.json
  python tools/merge_pending_sources.py --check    # report only; exit 1 on problems

Pending files: sources/pending/sim_sources_<range>.json, each a JSON list (or {"sources": [...]}) of entries
shaped like sim_sources.json: {id, citation, url, archived_url, accessed, kind, opened, provenance, quote, supports, note}.
Rules: ids in the gameplay ranges only (S500-S699, S750-S799, S900-S999, S5000-S5999), no id already used in sources.json / sim_sources.json /
map_sources.json, an opened entry needs a url (the verbatim quote goes in the entry's "quote" or in each
fork/war cite; sim_test --validate-only checks the cites). Pending files stay in place;
re-running is idempotent (already-merged ids with the same citation are refreshed, not duplicated).
"""
import json, os, sys, glob, shutil


def gameplay_id(n):
    return 500 <= n <= 699 or 750 <= n <= 799 or 900 <= n <= 999 or 5000 <= n <= 5999

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "sources")
SIMJ = os.path.join(SRC, "sim_sources.json")
HISTJ = os.path.join(SRC, "sources.json")
MAPJ = os.path.join(SRC, "map_sources.json")
PEND = os.path.join(SRC, "pending")


def load_list(p):
    if not os.path.exists(p):
        return []
    d = json.load(open(p, encoding="utf-8"))
    return d.get("sources", []) if isinstance(d, dict) else d


def render(sim):
    L = ["# Sources - Civilization: Israel (gameplay / simulation data)", "",
         "Rendered from `sources/sim_sources.json` by `python tools/merge_pending_sources.py`. Do not hand-edit.", "",
         "- S500-S699, S750-S799, S900-S999 and S5000-S5999 are reserved for gameplay sources (techs, civics, policies, governments, buildings, forks, wars, label series).",
         "- Gameplay data also cites history sources (`sources.json`) by their permanent ids.", "",
         "Provenance: `opened` = opened and the quoted claim checked; `not_opened` = reference only - cite it with a verbatim quote from an opened URL.", ""]
    for s in sorted(sim, key=lambda s: int(s["id"][1:])):
        if s.get("retired"):
            L.append(f"**[{s['id']}]** RETIRED (no longer cited{'; ' + s['retired_note'] if s.get('retired_note') else ''}) — {s.get('citation', '')} — {s.get('url') or 'no URL (print)'}")
            L.append("")
            continue
        L.append(f"**[{s['id']}]** {s.get('citation', '')} — {s.get('url') or 'no URL (print)'} — accessed: {s.get('accessed') or 'n/a'} — provenance: {s.get('provenance', 'opened' if s.get('opened') else 'not_opened')}")
        if s.get("note"):
            L.append(f"  - Note: {s['note']}")
        if s.get("quote"):
            L.append(f"  - Quote: \"{s['quote']}\"")
        sup = s.get("supports") or []
        if isinstance(sup, str):
            sup = [sup]
        if sup:
            L.append("  - Supports:")
            for x in sup:
                L.append(f"    - {x}")
        L.append("")
    open(os.path.join(SRC, "SIM_SOURCES.md"), "w", encoding="utf-8").write("\n".join(L))


def main():
    check = "--check" in sys.argv
    sim = load_list(SIMJ)
    used = {s["id"]: "sim_sources.json" for s in sim}
    for s in load_list(HISTJ):
        used.setdefault(s["id"], "sources.json")
    for s in load_list(MAPJ):
        used.setdefault(str(s.get("id")), "map_sources.json")
    errs, add, files, upd = [], [], [], []
    for p in sorted(glob.glob(os.path.join(PEND, "*.json"))):
        files.append(p)
        try:
            entries = load_list(p)
        except Exception as e:
            errs.append(f"{os.path.basename(p)}: JSON error: {e}")
            continue
        for s in entries:
            sid = str(s.get("id", ""))
            w = f"{os.path.basename(p)} {sid or '(no id)'}"
            if not (sid.startswith("S") and sid[1:].isdigit() and gameplay_id(int(sid[1:]))):
                errs.append(f"{w}: id must be in a gameplay range (S500-S699, S750-S799, S900-S999, S5000-S5999)")
                continue
            if sid in used:
                if used[sid] == "sim_sources.json" and any(x["id"] == sid and x.get("citation") == s.get("citation") for x in sim):
                    upd.append(s)   # merged before: refresh its fields (quote, url, supports) from the pending file
                    continue
                errs.append(f"{w}: id already used in {used[sid]}")
                continue
            if not s.get("citation"):
                errs.append(f"{w}: missing citation")
            opened = s.get("provenance") == "opened" or s.get("opened") is True
            if opened and not str(s.get("url") or "").startswith("http"):
                errs.append(f"{w}: an opened source needs a url (quotes go in the source's \"quote\" or in each fork cite)")
            s.setdefault("provenance", "opened" if opened else "not_opened")
            s.setdefault("opened", opened)
            s.setdefault("note", "Added by a gameplay data agent (" + os.path.basename(p) + ").")
            used[sid] = os.path.basename(p)
            add.append(s)
    for e in errs:
        print("ERROR", e)
    print(f"{len(files)} pending file(s), {len(add)} new source(s), {len(errs)} error(s)")
    if check or errs:
        sys.exit(1 if errs else 0)
    if add or upd:
        by_id = {x["id"]: x for x in sim}
        for s in upd:
            by_id[s["id"]].update(s)
        sim.extend(add)
        json.dump(sim, open(SIMJ, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print(f"{len(upd)} previously merged source(s) refreshed")
    render(sim)
    print(f"sim_sources.json now has {len(sim)} entries; SIM_SOURCES.md re-rendered")


if __name__ == "__main__":
    main()
