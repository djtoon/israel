# Apply city_fixes_b.json in memory and check: offline city rules for patched cities + verbatim quotes of all cites in patched statuses
import json, sys, re, importlib.util
sys.stdout.reconfigure(encoding="utf-8")
spec = importlib.util.spec_from_file_location("cs", r"C:\civ\tools\check_sources.py"); cs = importlib.util.module_from_spec(spec); spec.loader.exec_module(cs)
P = json.load(open(__import__("os").path.join(__import__("os").path.dirname(__import__("os").path.abspath(__file__)), "data", "city_fixes_b.json"), encoding="utf-8"))
C = json.load(open(cs.CI, encoding="utf-8")); S = json.load(open(cs.SJ, encoding="utf-8"))
ids = {s["id"] for s in S}
SD = {s["id"]: s for s in S}
for s in P["sources"]:
    assert 2050 <= int(s["id"][1:]) <= 2099
    if s["id"] in SD: assert SD[s["id"]]["url"] == s["url"], ("id clash", s["id"])
S2 = S + [s for s in P["sources"] if s["id"] not in SD]
D = {c["id"]: c for c in C}
for x in P["cities"]:
    D[x["id"]].update(x["set"])
patched = {x["id"] for x in P["cities"]}
errs = cs.check([], C, S2)
mine = [e for e in errs if any(f"city {i}:" in e for i in patched) or "S20" in e]
print("offline errors on patched cities:", len(mine)); [print(" ", e) for e in mine]
print("remaining city errors overall:", len([e for e in errs if e.startswith("city ")]))
# quote check
SID = {s["id"]: s for s in S2}
loose = lambda t: re.sub(r"[\W_]+", "", cs.norm(t))
bad = 0; n = 0
for cid in sorted(patched):
    for stt in D[cid].get("status") or []:
        if stt["from"] and not re.match(r"^\d{4}(-\d{2}){0,2}$", stt["from"]): print("BAD from", cid, stt["from"])
        for c in stt.get("cite") or []:
            if c["source"] not in SID: print("MISSING SRC", cid, c["source"]); bad += 1; continue
            if not c.get("quote"): continue
            n += 1
            t, fin = cs.fetch(c["url"])
            if t is None: print("UNREACHABLE", cid, c["url"]); bad += 1; continue
            nt = loose(t)
            frags = [f for f in re.split(r"\.\.\.|…|\[\.\.\.\]", c["quote"]) if len(loose(f)) > 3]
            ok = all(loose(f) in nt for f in frags)
            if not ok and re.search(r"t=pdf|symbol/access|\.pdf", fin or "", re.I):
                toks = re.findall(r"\w+", cs.norm(t)); ok = all(loose(f) in nt or cs.pdf_match(f, toks) for f in frags)
            if not ok: bad += 1; print("QUOTE NOT FOUND", cid, c["source"], c["url"], "|", c["quote"][:90])
print("quotes checked", n, "bad", bad)
