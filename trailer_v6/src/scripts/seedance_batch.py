"""Run Seedance i2v generations in parallel:
   python -I seedance_batch.py name1 name2 ... [--par 5] [--tag a] [--seed N]
Inputs seedance/in/<img or name>.png, prompts seedance/shots.json, outputs seedance/<name>_<tag>.mp4"""
import json, subprocess, sys, os
from concurrent.futures import ThreadPoolExecutor

S = "C:/civ/trailer_v6/src/seedance"
args = sys.argv[1:]
par, tag, seed = 5, "a", None
if "--par" in args:
    i = args.index("--par"); par = int(args[i + 1]); del args[i:i + 2]
if "--tag" in args:
    i = args.index("--tag"); tag = args[i + 1]; del args[i:i + 2]
if "--seed" in args:
    i = args.index("--seed"); seed = args[i + 1]; del args[i:i + 2]
shots = json.load(open(f"{S}/shots.json", encoding="utf-8"))


def run(n):
    sh = shots[n]
    out = f"{S}/{n}_{tag}.mp4"
    if os.path.exists(out):
        return n, "exists"
    cmd = ["python", "C:/civ/tools/gen.py", "video", sh["p"], out, "--image", f"{S}/in/{sh.get('img', n)}.png",
           "--seconds", str(sh.get("sec", 5)), "--aspect", sh.get("aspect", "adaptive"), "--no-audio"]
    if sh.get("last"):
        cmd += ["--last", f"{S}/in/{sh['last']}.png"]
    if seed:
        cmd += ["--seed", seed]
    r = subprocess.run(cmd, capture_output=True, text=True, cwd="C:/civ")
    with open(f"{S}/{n}_{tag}.log", "w", encoding="utf-8") as f:
        f.write(" ".join(cmd[:3]) + "\n" + r.stdout + r.stderr)
    return n, "ok" if os.path.exists(out) else "FAIL " + (r.stdout + r.stderr)[-400:]


with ThreadPoolExecutor(par) as ex:
    for n, st in ex.map(run, args):
        print(n, st, flush=True)
