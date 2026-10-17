import subprocess, sys, os, concurrent.futures as cf
from PIL import Image
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from jobs import *
ROOT = "C:/civ/game/assets/images/"
REF = "C:/civ/game/assets/ui/advisor_secretary.png"

def gen(prompt, out, aspect, ref, full, small, tries=3):
    if os.path.exists(small):
        return out + " skip"
    os.makedirs(os.path.dirname(out), exist_ok=True)
    err = ""
    for i in range(tries):
        cmd = [sys.executable, "C:/civ/tools/gen.py", "image", prompt, out, "--aspect", aspect, "--quality", "high"]
        if ref:
            cmd += ["--ref", ref]
        r = subprocess.run(cmd, capture_output=True, text=True)
        err = r.stderr[-300:]
        if os.path.exists(out) and r.returncode == 0:
            im = Image.open(out).convert("RGB").resize(full, Image.LANCZOS)
            im.save(out)
            im.resize((256, 256) if full[0] == full[1] else (768, 432), Image.LANCZOS).save(small)
            return out + " ok"
    return out + " FAIL " + err

def jobs(which):
    L = []
    if which in ("p", "all"):
        for (i, n, role, a, b, act, d) in P:
            L.append((STYLE + f"{n}, {role}. Recognisable respectful likeness of their public image, no caricature. {d}.", ROOT + f"portraits/{i}.png", "1:1", REF, (1024, 1024), ROOT + f"portraits/{i}_256.png"))
        for (i, n, role, a, b, d) in M:
            L.append((STYLE + d + ". Dignified, generic, not a real person.", ROOT + f"portraits/{i}.png", "1:1", REF, (1024, 1024), ROOT + f"portraits/{i}_256.png"))
    if which in ("e", "all"):
        from events import E
        for (i, cap, d) in E:
            L.append((f"Painterly historical illustration, warm golden palette with navy-blue accents, soft brushwork like a Civ VI loading-screen painting, wide cinematic composition. {d} Respectful, neutral, no violence, no gore, no bodies, no weapons pointed at people, no text, no letters, no flags with writing, no logos.", ROOT + f"events/{i}.png", "16:9", None, (1536, 864), ROOT + f"events/{i}_768.png"))
    return L

if __name__ == "__main__":
    w = sys.argv[1]
    n = int(sys.argv[2]) if len(sys.argv) > 2 else 6
    with cf.ThreadPoolExecutor(n) as ex:
        for r in ex.map(lambda j: gen(*j), jobs(w)):
            print(r, flush=True)
