# -*- coding: utf-8 -*-
"""Helper for sourcing city cites (round 4).
  python tools/history/cityq.py grep URL term [term...]   # print passages of the page text containing ALL terms (case-insens.)
  python tools/history/cityq.py text URL [n]              # print first n chars of the page text
  python tools/history/cityq.py verify FILE.json          # check every cite quote in a city_fixes_e*.json against its page
Uses check_sources.fetch (cached in tools/.source_cache; falls back to web.archive.org). A quote must be copied VERBATIM
from the printed passage (same words; ellipses "..." allowed between fragments).
"""
import sys, os, re, json
sys.stdout.reconfigure(encoding="utf-8")
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
import check_sources as cs

def passages(text, terms, width=260):
    t = re.sub(r"\s+", " ", text)
    low = t.lower()
    out, last = [], -10**9
    first = terms[0].lower()
    for m in re.finditer(re.escape(first), low):
        a, b = max(0, m.start() - width), min(len(t), m.end() + width)
        seg = low[a:b]
        if all(x.lower() in seg for x in terms) and m.start() - last > width:
            out.append(t[a:b]); last = m.start()
    return out

def main():
    cmd = sys.argv[1]
    if cmd in ("grep", "text"):
        text, final = cs.fetch(sys.argv[2])
        if text is None:
            print("UNREACHABLE"); return
        print("# fetched:", final, len(text), "chars")
        if cmd == "text":
            print(re.sub(r"\s+", " ", text)[: int(sys.argv[3]) if len(sys.argv) > 3 else 3000]); return
        ps = passages(text, sys.argv[3:])
        for p in ps[:12]:
            print("--", p)
        if not ps: print("NO MATCH")
    elif cmd == "verify":
        F = json.load(open(sys.argv[2], encoding="utf-8"))
        items = []
        for fx in F.get("cities", []):
            cid = fx["id"]
            for sc in fx.get("status_cites", []):
                for c in sc["cite"]: items.append((f"{cid} status {sc['from']}", c))
            for c in (fx.get("set") or {}).get("founded_cite", []): items.append((f"{cid} founded", c))
            for st in (fx.get("set") or {}).get("status", []):
                for c in st.get("cite", []): items.append((f"{cid} status {st['from']}", c))
        CI = {c["id"]: c for c in json.load(open(os.path.join(cs.ROOT, "game", "data", "cities.json"), encoding="utf-8"))}
        for who, c in items:   # rule (d): a status quote must name the town (or alias) unless it carries "covers"
            cid = who.split()[0]; q = cs._nm(c.get("quote") or "")
            if "status" in who and q and not c.get("covers") and cid in CI:
                cc = CI[cid]
                names = {cs._nm(n) for n in [cc["name"], cc["name_he"], cid.replace("_", " ")] + list(cc.get("aliases") or []) + cs.ALIASES.get(cid, []) if n}
                if not any(n in q for n in names):
                    print("RULE-D (quote does not name the town):", who, "|", c["quote"][:90])
        pairs = {}
        for who, c in items:
            if not c.get("quote") and not c.get("page"):
                print("BAD (no quote/page):", who, c.get("claim")); continue
            if c.get("url") and c.get("quote"): pairs.setdefault(c["url"], []).append((who, c["quote"]))
        bad = 0
        for u, lst in pairs.items():
            text, final = cs.fetch(u)
            if text is None:
                print("UNREACHABLE", u, [w for w, _ in lst]); bad += len(lst); continue
            loose = lambda t: re.sub(r"[\W_]+", "", cs.norm(t))
            nt = loose(text)
            is_pdf = final in cs.PDF_URLS or bool(re.search(r"\.pdf\b|t=pdf|symbol/access", final, re.I))
            toks = re.findall(r"\w+", cs.norm(text)) if is_pdf else None
            for who, q in lst:
                frags = [f for f in re.split(r"\.\.\.|…|\[\.\.\.\]", q) if len(loose(f)) > 3]
                ok = all(loose(f) in nt for f in frags) or (is_pdf and all(loose(f) in nt or cs.pdf_match(f, toks) for f in frags))
                if not ok:
                    bad += 1; print("QUOTE NOT ON PAGE:", who, u, "|", q[:100])
        print(f"{len(items)} cites, {len(pairs)} urls, {bad} problems")
main()
