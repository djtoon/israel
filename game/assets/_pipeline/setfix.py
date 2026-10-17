"""setfix.py id=deg ...  -> store yaw_fix (extra yaw, x->z sense) in MANIFEST.json for build.py"""
import json, sys
p = "../MANIFEST.json"
m = json.load(open(p, encoding="utf-8"))
fx = dict(a.split("=") for a in sys.argv[1:])
for e in m["assets"]:
    if e["id"] in fx:
        e["yaw_fix"] = float(fx[e["id"]])
json.dump(m, open(p, "w", encoding="utf-8"), indent=1, ensure_ascii=False)
