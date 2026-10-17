# -*- coding: utf-8 -*-
"""Remove references to the user-deleted content (7 Oct 2023 attack and the 2023- Gaza war; decided 2026-10-11)
from events and cities that were KEPT. Called by apply.py just before writing the game data, and by
tools/purge_gaza_war.py for frozen checkpoints.

Displayed text (titles, summaries, notes, claim labels, affected-population notes) is rewritten minimally so it stays
true. Verbatim source quotes are left untouched, but cites whose claim exists only to support deleted content are removed.
"""
import json, re

TITLE = {}   # (the West Bank toll 2023-26 event itself was deleted with everything after Q3 2023, 2026-10-14)

# (event id, regex on summary, replacement); the events these rules rewrote were all dated after Q3 2023 and were
# deleted on 2026-10-14 (tools/purge_after_end.py), so none is left
SUMMARY = []

# cites (by claim text) that only supported deleted content
DROP_CLAIM = re.compile(r"7 October Nova|Survivor of the 7 October|Hostage families|Yellow Line|after the Gaza ceasefire|"
                        r"attacked on 7 October|Haniyeh|13 Oct 2023|1\.1 million people in northern Gaza|Threat to resume|in the 7 October attack|after the 7 October attack|January 2025 Gaza ceasefire", re.I)

# city status notes
NOTE = [
    (r"\s*After the Hamas-led attack of 7 October 2023 the Strip became the main theatre of the Israel-Hamas war[^.]*\.(\s*[^.]*(?:ceasefire|Yellow Line)[^.]*\.)*", ""),
    (r";? one of the communities attacked on 7 October 2023", ""),
    (r"\s*Under the October 2025 ceasefire[^.]*\.", ""),
]


QUOTE_PREFIX = re.compile(r"^\s*Since 7 October 2023,?\s*", re.I)


def _clean_cites(lst):
    out = []
    for c in lst or []:
        if DROP_CLAIM.search(c.get("claim", "")):
            continue
        if c.get("claim"):
            c["claim"] = re.sub(r" in support of Hamas", "", c["claim"])
        if c.get("quote"):
            c["quote"] = re.split(r",? which began a day after Hamas", c["quote"])[0]
            # keep the quote verbatim but start it after the reference (still a substring of the source text)
            c["quote"] = QUOTE_PREFIX.sub("", c["quote"])
            # a trailing reference: cut the quote just before it (the remainder is still verbatim)
            c["quote"] = re.split(r"\s+since 7 October 2023", c["quote"], flags=re.I)[0]
        out.append(c)
    return out


def scrub(events, cities):
    for e in events:
        if e.get("id") in TITLE:
            e["title"], e["title_he"] = TITLE[e["id"]]
        for eid, pat, rep in SUMMARY:
            if e.get("id") == eid and e.get("summary"):
                e["summary"] = re.sub(pat, rep, e["summary"])
        e["cite"] = _clean_cites(e.get("cite"))
        for ch in e.get("choices") or []:
            ch["cite"] = _clean_cites(ch.get("cite"))
        if e.get("affected_populations"):
            e["affected_populations"] = [a for a in e["affected_populations"]
                                         if "Haniyeh" not in (a.get("note") or "")]
    for c in cities:
        gone_c = set()
        if "Since October 2023" in (c.get("population_comment") or "") or "wartime displacement since October 2023" in (c.get("population_comment") or ""):
            c.pop("population_comment", None)
        for key in ("founded_note", "note", "population_notes"):
            if isinstance(c.get(key), str):
                c[key] = re.sub(r"\s*One of the communities attacked on 7 October 2023\.", "", c[key])
                c[key] = re.sub(r";? one of the communities attacked on 7 October 2023", "", c[key]).strip()
        for k in ("founded_cite",):
            if isinstance(c.get(k), list):
                c[k] = _clean_cites(c[k])
        for st in c.get("status") or []:
            if st.get("note"):
                for pat, rep in NOTE:
                    st["note"] = re.sub(pat, rep, st["note"]).strip()
            before = {c.get("source") for c in st.get("cite") or []}
            st["cite"] = _clean_cites(st.get("cite"))
            gone = before - {c.get("source") for c in st["cite"]}
            gone_c |= gone
            if isinstance(st.get("source"), list):
                st["source"] = [x for x in st["source"] if x not in gone]
        if gone_c and isinstance(c.get("source"), list):
            still = json.dumps([c.get("status"), c.get("founded_cite"), c.get("population_source")])
            c["source"] = [x for x in c["source"] if x not in gone_c or f'"{x}"' in still]
    return events, cities


# ---------------------------------------------------------------- content dated after the end of the game (2026-10-14)
# The game ends after Q3 2023 (the user: "we dont need them after oct 7"). tools/purge_after_end.py removed the late
# content from the live data; this keeps a re-run of the history pipeline from bringing city timeline entries back.
END = "2023-09-30"


def _after(d):
    s = str(d or "")
    if re.match(r"^\d{4}-\d{2}-\d{2}", s):
        return s[:10] > END
    if re.match(r"^\d{4}-\d{2}$", s):
        return s > END[:7]
    if re.match(r"^\d{4}$", s):
        return s > END[:4]
    return False


def scrub_after_end(cities):
    for c in cities:
        keep = []
        for st in c.get("status") or []:
            if _after(st.get("from")):
                continue
            if _after(st.get("to")):
                st["to"] = None
            if st.get("note"):
                st["note"] = re.sub(r"\s*On 27 July 2024 a rocket strike on a football pitch killed 12 children\.", "", st["note"])
            keep.append(st)
        if "status" in c:
            c["status"] = keep
    return cities
