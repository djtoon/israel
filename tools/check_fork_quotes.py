#!/usr/bin/env python3
"""Net-check the verbatim quotes in gameplay data: fork option cites (game/data/forks/*.json), war front cites
(game/data/wars/*.json) and gameplay sources with a "quote" (sources/sim_sources.json).

Reuses tools/check_sources.py's fetcher (live page, then web.archive.org fallback, cached in tools/.source_cache)
and its tolerant matching (punctuation-insensitive, "[...]" splits a quote into fragments that must all appear).

Usage:  python tools/check_fork_quotes.py        # exit 1 if any quote is not found on its page
"""
import glob, json, os, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import check_sources as cs  # noqa: E402


def main():
    sim = json.load(open(os.path.join(ROOT, "sources", "sim_sources.json"), encoding="utf-8"))
    hist = json.load(open(os.path.join(ROOT, "sources", "sources.json"), encoding="utf-8"))
    url_of = {s["id"]: s.get("url") for s in hist + sim}
    pseudo = []
    for s in sim:
        if s.get("quote") and cs.is_url(s.get("url")):
            pseudo.append({"id": "source " + s["id"], "cite": [{"url": s["url"], "quote": s["quote"]}]})
    for p in sorted(glob.glob(os.path.join(ROOT, "game", "data", "forks", "*.json"))):
        for f in json.load(open(p, encoding="utf-8")).get("forks", []):
            for o in f.get("options", []):
                cites = []
                for c in o.get("cite", []):
                    u = c.get("url") or url_of.get(c.get("source"))
                    if c.get("quote") and cs.is_url(u):
                        cites.append({"url": u, "quote": c["quote"]})
                if cites:
                    pseudo.append({"id": "%s %s/%s" % (os.path.basename(p), f["id"], o["id"]), "cite": cites})
    for p in sorted(glob.glob(os.path.join(ROOT, "game", "data", "wars", "*.json"))):
        w = json.load(open(p, encoding="utf-8"))
        for fr in w.get("fronts", []):
            cites = []
            for c in fr.get("cite", []):
                u = c.get("url") or url_of.get(c.get("source"))
                if c.get("quote") and cs.is_url(u):
                    cites.append({"url": u, "quote": c["quote"]})
            if cites:
                pseudo.append({"id": "%s front %s" % (w.get("id"), fr.get("id")), "cite": cites})
    errs, n = cs.net_check(pseudo)
    fails = [e for e in errs if e.startswith("NET ")]
    for e in errs:
        print(e)
    print(f"{len(pseudo)} quoted items, {n} urls checked, {len(fails)} quote(s) not found, {len(errs) - len(fails)} warning(s)")
    sys.exit(1 if fails else 0)


if __name__ == "__main__":
    main()
