"""Parallel batch runner around tools/gen.py with a spend log.

  python game/assets/_pipeline/batch.py jobs.json [--workers 6]

jobs.json: [ {"kind":"image","prompt":..,"out":..,"aspect":"1:1","quality":"high","transparent":false,"ref":[..]},
             {"kind":"model","image":..,"out":..} ]
Every call (ok or failed) is appended to game/assets/_pipeline/genlog.jsonl.
"""
import json, os, subprocess, sys, time, datetime
from concurrent.futures import ThreadPoolExecutor

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
LOG = os.path.join(os.path.dirname(__file__), "genlog.jsonl")
GEN = os.path.join(ROOT, "tools", "gen.py")


def run(job):
    t0 = time.time()
    if job["kind"] == "image":
        cmd = [sys.executable, GEN, "image", job["prompt"], job["out"], "--aspect", job.get("aspect", "1:1"),
               "--quality", job.get("quality", "high")]
        if job.get("transparent"):
            cmd.append("--transparent")
        for r in job.get("ref", []):
            cmd += ["--ref", r]
    else:
        cmd = [sys.executable, GEN, "model", job["image"], job["out"]]
        if job.get("faces"):
            cmd += ["--faces", str(job["faces"])]
    p = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True)
    ok = p.returncode == 0 and os.path.exists(os.path.join(ROOT, job["out"]))
    attempts = p.stderr.count("attempt ") + 1
    rec = {"t": datetime.datetime.now().isoformat(timespec="seconds"), "kind": job["kind"], "out": job["out"],
           "ok": ok, "secs": round(time.time() - t0), "attempts": attempts,
           "quality": job.get("quality"), "err": (p.stderr.strip()[-300:] if not ok else "")}
    if job["kind"] == "model":
        rec["generator"] = "firtoz/trellis" if "falling back to firtoz/trellis" in p.stderr else "tencent/hunyuan-3d-3.1"
    with open(LOG, "a", encoding="utf-8") as f:
        f.write(json.dumps(rec) + "\n")
    print(("OK  " if ok else "FAIL") + f" {job['out']} {rec['secs']}s {rec.get('generator','')} {rec['err']}", flush=True)
    return ok


if __name__ == "__main__":
    jobs = json.load(open(sys.argv[1], encoding="utf-8"))
    w = int(sys.argv[sys.argv.index("--workers") + 1]) if "--workers" in sys.argv else 6
    with ThreadPoolExecutor(w) as ex:
        res = list(ex.map(run, jobs))
    print(f"done {sum(res)}/{len(res)}")
