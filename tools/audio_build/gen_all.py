import sys, os, subprocess
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from jobs import J
from concurrent.futures import ThreadPoolExecutor
raw = "C:/civ/progress/audio_raw"
os.makedirs(raw, exist_ok=True)


def run(n):
    c, p, s, l, u = J[n]
    out = f"{raw}/{n}.mp3"
    if os.path.exists(out) and os.path.getsize(out) > 10000:
        return n, "skip"
    r = subprocess.run(["python", "C:/civ/tools/gen.py", "audio", p, out, "--seconds", str(s)], capture_output=True, text=True)
    return n, (r.returncode, r.stdout[-200:], r.stderr[-200:])


names = sys.argv[1:] or list(J)
with ThreadPoolExecutor(4) as ex:
    for n, r in ex.map(run, names):
        print(n, r, flush=True)
