# Brief: fix event findings from CRITIC_HISTORY_02 (round 4) for "Civilization: Israel"

Work dir `C:\civ`. Read `C:\civ\CONTRACT.md` (Bars -> History) and the "Failing items (compact)" section of `C:\civ\sources\CRITIC_HISTORY_02.md` (plus the per-event rows in its Detailed tables). DO NOT run `tools/history/apply.py`, DO NOT edit game/data/*.json or sources/*.json or any other file; you write exactly ONE patch file (name given in your assignment) in `tools/history/patches/`. No Godot.

## Rules
- Every number/date/claim needs a cite with a URL you actually opened and a VERBATIM quote (or a print `page`). Never invent a quote. Never use Wikipedia (any language) as a source. Attribute contested figures to who published them ("according to B'Tselem ...", "Israeli military said ..."), and when sources disagree, state both and cite both. Every casualty/displacement event lists every affected population (Israeli, Palestinian, other) with [low, high] figures, "none reported" or "not quantified"; add a `note` with the as-of date and attribution on each group. Neutral wording, no editorialising.
- Tools: `python tools/history/cityq.py grep URL term [term...]` prints passages of a page (cached; falls back to web.archive.org; PDFs parsed); `... text URL 3000` prints its start. curl with a browser UA also works. WebFetch only gives summaries, not verbatim text: use it to find URLs, then confirm the exact wording with cityq grep. Read the current event with python from `game/data/events.json` (use PYTHONIOENCODING=utf-8). Existing sources: `sources/sources.json`.
- A cite whose only URL is a web.archive.org copy that cannot be opened is useless: prefer live primary pages.

## Patch file format (applied by apply.py after all earlier patches)
```
{"titles": {"<url>": "Org/Author, 'Title', Publisher, date"},       // optional nicer citation text for NEW urls
 "patches": [
   {"id": "evt_...",
    "set": {"summary": "...", "affected_populations": [ {"group":"...", "killed":[lo,hi]|"none reported"|"not quantified", "wounded":..., "displaced":..., "note":"as-of date; who reports it"} ], ...},
    "add_cite": [ {"claim":"short claim the quote supports", "url":"...", "quote":"verbatim", "page":"optional", "source":"optional existing S-id"} ],
    "remove_claims": ["exact claim text of an existing cite to drop"] } ],
 "flags": ["..."], "unsourced": ["..."]}
```
`set` replaces whole keys (so re-send the full summary / full affected_populations). `add_cite` with only a url mints a new S-id. If you change a summary, make sure every number in it has a cite, and remove cites of claims you removed. For a choice (option) fix, `set` the whole `choices` list (each non-historical choice needs a named advocate, `source` and a quoted `cite`; exactly one `historical: true`).
Check the result: write your patch, then verify quotes with a tiny python snippet that calls `check_sources.fetch` the way cityq.py `verify` does, or temporarily put the quotes through `python tools/history/cityq.py grep URL "<distinctive words>"`. Every quote must appear on its page.
Where a published figure genuinely cannot be opened, say "not quantified" and list it in "unsourced" rather than guessing.
Finish with a SHORT report: events done, new cites, what you could not source, what you dropped or reworded.
