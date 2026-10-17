# verify quotes of given event ids against their pages: python tools/history/evq.py evt_a evt_b ...
import sys, os, re, json
sys.stdout.reconfigure(encoding="utf-8")
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
import check_sources as cs
E = {e["id"]: e for e in cs.load(cs.EV)}
pairs = {}
for i in sys.argv[1:]:
    e = E[i]
    for c in (e.get("cite") or []) + [x for ch in e.get("choices") or [] for x in ch.get("cite") or []]:
        if c.get("url") and c.get("quote"): pairs.setdefault(c["url"], []).append((i, c["quote"]))
errs, n = cs.net_check([E[i] for i in sys.argv[1:]])
print(n, "urls;", len(errs), "issues")
for x in errs: print(x)
