"""List recent Replicate predictions (and optionally download succeeded seedance outputs by prompt prefix)."""
import json, os, sys, urllib.request
T = os.environ["REPLICATE_API_TOKEN"]
H = {"Authorization": f"Bearer {T}", "User-Agent": "Mozilla/5.0 civ-gen"}
def get(u):
    return json.loads(urllib.request.urlopen(urllib.request.Request(u, headers=H), timeout=60).read())
d = get("https://api.replicate.com/v1/predictions")
res = d["results"]
if d.get("next"): res += get(d["next"])["results"]
for p in res[:60]:
    inp = p.get("input", {}) or {}
    print(p["id"], p["model"].split("/")[-1], p["status"], p["created_at"][11:19], (inp.get("prompt") or "")[:60].replace("\n", " "), "|", str(p.get("output"))[:100])
