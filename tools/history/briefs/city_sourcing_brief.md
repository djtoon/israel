# Brief: source the city cites (round 4) for "Civilization: Israel"

Work dir `C:\civ`. Read `C:\civ\CONTRACT.md` (Bars -> History) first. Data is built by a pipeline; DO NOT run `tools/history/apply.py`, DO NOT edit game/data/*.json, sources/*.json or any other file. You write ONE file: `tools/history/data/city_fixes_e<N>.json` (N given in your assignment). Do not run Godot.

## Why
`tools/check_sources.py` now FAILS on: (a) any city status[] entry with an empty `cite`; (b) any city with no `founded_cite` (a city with founded "pre-1948" needs at least one cite for its existence, either founded_cite or a status cite); (c) a source whose only basis is Wikipedia (any language) - never use Wikipedia, in any language, not even as a "pointer"; (d) a status-entry quote that does not contain the town's name or a known alias (English or Hebrew name, `cities.json` name/name_he, or an alias).
Quotes must be VERBATIM from a page you actually opened (live or web.archive.org), as the checker re-fetches every URL and matches the quote text (ellipses "..." allowed between fragments).

## Tools
- `python tools/history/cityq.py grep URL term [term...]` prints passages of the page containing ALL terms (use the name, a year, etc.). Copy quotes verbatim from this output. `... text URL 3000` prints the start of the page.
- `python tools/history/cityq.py verify tools/history/data/city_fixes_eN.json` checks every quote against its page and rule (d). Run it until clean.
- curl with a browser User-Agent also works; WebFetch gives summaries, NOT verbatim text, so only use it to find URLs, then confirm with cityq grep.
- Good sources that fetch well: Jewish Virtual Library (jewishvirtuallibrary.org/<city>, Encyclopaedia Judaica text), CBS locality files (cbs.gov.il ... bycode2022.xlsx; the quote is one spreadsheet row as the checker prints it, see Ashdod's founded_cite in game/data/cities.json for the exact style), municipal sites, JTA archive (jta.org/archive/...), UN documents (documents.un.org, undocs.org, un.org/unispal), Avalon Project (avalon.law.yale.edu), history.state.gov (FRUS), Britannica (may block), Times of Israel, B'Tselem, HRW, OCHA, UNRWA, Morris books (print: give `page`, plus a Google Books/archive.org URL only if you opened it and can quote it; otherwise a page-number cite needs the book's S-id: `"source":"S105"` etc. and `"page":"p. 123"` with a short paraphrase in `claim`).
- Existing city entries and their current cites: `game/data/cities.json` (read it with python; print with PYTHONIOENCODING=utf-8). Existing source list: `sources/sources.json` (S-id -> url). Reuse an existing S-id (`"source":"S157"`) when the URL is the same; otherwise give only `url` and the pipeline mints an S-id.

## What to produce for each assigned city
1. `founded_cite`: list of cites for the founding year (quote must contain the year and the town). For Israeli localities with `cbs_code`, the CBS locality row (S004, bycode2022.xlsx) works: copy the exact style of existing founded_cites (the row string and `page` text). Prefer a narrative source too if easy (JVL/municipality). For pre-1948 cities: cite a page that shows the town existed before 1948 (e.g. JVL Encyclopaedia Judaica, UN/Morris/FRUS text naming the town in 1948).
2. For EVERY status entry in the city (all `from` dates), at least one cite whose quote names the town and supports that status/date (who held it from what date). Where the existing cites are non-naming (generic armistice, military-government, general war narrative), replace them: set `"replace": true` on that status_cites item and list the full new cite set. Best practice for transfers: one primary document per transfer type, e.g.
   - 1948 captures: Morris, *Birth of the Palestinian Refugee Problem Revisited* (2004) or *1948* (2008) with page; JTA 1948 archive; UN documents (Bernadotte progress report A/648, etc.).
   - 1949 Iraqi->Jordanian handover: Israel-Jordan Armistice Art. VI (https://avalon.law.yale.edu/20th_century/arm03.asp), quote "It is agreed that the forces of the Hashemite Jordan Kingdom shall replace the forces of Iraq in the sector now held by the latter forces". This document names no town: add `"covers": "<why it applies to this town, e.g. the northern West Bank sector of the Iraqi front>"` on that cite, AND ensure the entry has at least one other cite that names the town.
   - 1967: UN reports, JTA. 1995 Oslo II handovers: S013 (UN chronology) / S014 (jweekly Arafat in Jenin) - quote the lines that name the town. 2002 Defensive Shield: UN report A/ES-10/186 (documents.un.org) or equivalent. 2005: disengagement law/press.
   A cite that does not name the town may only be kept if it carries `covers` AND the same status entry has another cite that names the town.
3. Everything must be neutral and show affected populations accurately; no editorialising. Where sources disagree, cite both.
4. If, while sourcing, you find an existing status/founding date is wrong, correct it via `set.status` (replace the whole status list; keep fields from, to, status, note, source, cite) and explain in a top-level "flags" list. Keep notes factual.
5. If you cannot find an openable source for an item, do not invent one: leave it out and list it under "unsourced" (city, item, what you tried). Prefer to drop an unsupportable detail than to ship it.

## File format
```
{"titles": {"<url>": "Author/Org, 'Title', Publisher, date"},      // optional: citation text for NEW urls (so the source list has proper titles, not just the domain)
 "cities": [
  {"id": "ashdod",
   "set": {"founded_cite": [{"claim": "...", "url": "...", "quote": "...", "page": "optional"}], "founded_source": "optional S-id"},
   "status_cites": [ {"from": "1956", "status": "israel", "replace": false,
                      "cite": [{"claim": "...", "url": "...", "quote": "...", "source": "optional S-id", "covers": "optional"}],
                      "note": "optional new note for this status entry"} ]}
 ],
 "flags": ["..."], "unsourced": ["..."]}
```
`from` must equal the status entry's current `from` string exactly. `claim` is a short sentence of what the quote supports. For displacement/demolition notes include figures AND the as-of date and the source's attribution (e.g. "according to Morris ..."), and also name every affected population.
When finished: run `verify`, fix all problems, then reply with a SHORT report: cities done, count of cites, anything unsourced, anything you corrected or dropped.
