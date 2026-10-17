import subprocess, sys, os, json, urllib.request, time
from concurrent.futures import ThreadPoolExecutor
from PIL import Image
OUT = "C:/civ/game/assets/images/events/"
W = "C:/civ/work_fix3/"
STYLE_REF = "C:/civ/game/assets/images/events/evt_1948_independence.png"
UA = "civ-game-art/1.0 (educational game)"

def fetch(url, dest):
    for i in range(5):
        try:
            data = urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent": UA}), timeout=90).read()
            open(dest, "wb").write(data)
            return True
        except Exception as e:
            time.sleep(4 * (i + 1))
    return False

def run(spec):
    i = spec["id"]
    out = OUT + i + ".png"
    if os.path.exists(out) and os.path.getsize(out) > 20000 and not spec.get("force"):
        return i, "skip"
    src = W + i + ".png"
    cmd = [sys.executable, "C:/civ/tools/gen.py", "image", "", src, "--aspect", "16:9", "--quality", "high"]
    style = ("in the painted style of the style reference: visible oil-paint brushwork, muted navy-blue and warm gold palette, dignified and neutral, "
             "no text, no captions, no readable lettering, no graphic violence, accurate period details. ")
    if spec.get("photo"):
        ph = W + i + "_photo.jpg"
        if not os.path.exists(ph) and not fetch(spec["photo"]["thumb"], ph):
            return i, "FAIL photo download"
        cmd[3] = ("Redraw the FIRST reference image (a real photograph) as a painted historical illustration, keeping its real composition, setting, "
                  "people, clothing and camera angle faithfully. Render " + style + "Scene: " + spec["desc"])
        cmd += ["--ref", ph, "--ref", STYLE_REF]
    else:
        cmd[3] = "Painted historical illustration " + style + "Scene: " + spec["desc"]
        cmd += ["--ref", STYLE_REF]
    c = subprocess.run(cmd, capture_output=True, text=True)
    if not os.path.exists(src):
        return i, "FAIL " + c.stdout[-200:] + c.stderr[-300:]
    im = Image.open(src).convert("RGB")
    im.resize((1536, 864), Image.LANCZOS).save(out)
    im.resize((768, 432), Image.LANCZOS).save(OUT + i + "_768.png")
    return i, "ok"

if __name__ == "__main__":
    specs = json.load(open(sys.argv[1], encoding="utf-8"))
    only = set(sys.argv[2:])
    specs = [s for s in specs if not only or s["id"] in only]
    if only:
        for s in specs: s["force"] = True
        for s in specs:
            for suf in ("", "_photo"):
                pass
    with ThreadPoolExecutor(5) as ex:
        for i, s in ex.map(run, specs):
            print(i, s, flush=True)
