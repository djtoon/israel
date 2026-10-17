"""mkjobs.py out.json [id ...]  -> image jobs for assets whose raw image is missing (or the listed ids, forced)."""
import json, os, sys
import assets as A

HERE = os.path.dirname(os.path.abspath(__file__))
ASSETS = os.path.dirname(HERE)
force = set(sys.argv[2:])
jobs = []
for i, grp, raw, prompt, tr in A.all_images():
    if force and i not in force:
        continue
    if not force and os.path.exists(os.path.join(ASSETS, raw)):
        continue
    j = {"kind": "image", "out": "game/assets/" + raw, "prompt": prompt, "aspect": "1:1", "quality": "high"}
    if tr:
        j["transparent"] = True
    jobs.append(j)
json.dump(jobs, open(sys.argv[1], "w"), indent=1)
print(len(jobs), "jobs")
