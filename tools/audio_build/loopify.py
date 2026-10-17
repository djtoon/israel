"""Re-render music/*.ogg into seamless loops. usage: loopify.py measure|build"""
import subprocess, sys, glob, os, shutil
import numpy as np
FF = "C:/ffmpeg-8.1.1-essentials_build/bin/ffmpeg.exe"
SR = 44100
MUS = "C:/civ/game/assets/audio/music"
ORIG = "C:/civ/tools/audio_build/music_orig"
XF = 4.0  # crossfade seconds

def load(p):
    r = subprocess.run([FF, "-v", "error", "-i", p, "-f", "f32le", "-ac", "2", "-ar", str(SR), "-"], capture_output=True)
    return np.frombuffer(r.stdout, np.float32).reshape(-1, 2)

def levels(x, win=1.0, hop=0.25):
    w, h = int(win * SR), int(hop * SR)
    cs = np.concatenate([[0.0], np.cumsum(np.mean(x.astype(np.float64) ** 2, axis=1))])
    n = (len(x) - w) // h
    idx = np.arange(n) * h
    return 10 * np.log10((cs[idx + w] - cs[idx]) / w + 1e-18), hop

def seam(p):
    x = load(p)
    loop = np.concatenate([x, x])
    L, hop = levels(loop)
    body = levels(x)[0]
    med = np.median(body)
    c = len(x) / SR
    a, b = int((c - 3) / hop), int((c + 1) / hop)   # windows whose span touches the seam
    mn = L[a:b].min()
    return med, mn, med - mn

def trim_points(x):
    """Trim to the span where the music is solidly at body level: every 1 s window within 10 s of each edge is >= med-3 dB."""
    L, hop = levels(x, 1.0, 0.25)
    med = np.median(L)
    good = L >= med - 6
    k = int(6 / hop)
    run = np.convolve(good.astype(int), np.ones(k, int), mode="valid") == k   # window i..i+k all good
    ok = np.where(run)[0]
    if len(ok) == 0:
        ok = np.where(L >= med - 4)[0]
        return ok[0] * hop, ok[-1] * hop + 1.0
    return ok[0] * hop, (ok[-1] + k) * hop - 1.0 + 1.0

def smooth(v, w):
    c = np.concatenate([[0.0], np.cumsum(np.pad(v, (w // 2, w - w // 2 - 1), mode="edge"))])
    return (c[w:] - c[:-w]) / w

def build(f):
    base = os.path.basename(f)
    o = os.path.join(ORIG, base)
    if not os.path.exists(o):
        shutil.copy(f, o)
    x = load(o)
    t0, t1 = trim_points(x)
    t0 = max(t0, {'war_a.ogg': 4.0, 'peace.ogg': 3.0}.get(base, 0.0))
    a, b = int(t0 * SR), int(t1 * SR)
    body = x[a:b]
    n = int(XF * SR)
    mid = body[n:-n]
    t = np.linspace(0, np.pi / 2, n)[:, None]
    blend = body[-n:] * np.cos(t) + body[:n] * np.sin(t)   # equal-power
    # level compensation: lift the blend where it sags below the body level (max +9 dB)
    med = np.median(levels(body)[0])
    w = int(0.5 * SR)
    env = np.sqrt(smooth(np.mean(blend ** 2, axis=1), w) + 1e-12)
    env_db = 20 * np.log10(env)
    g_db = np.clip((med + 0.5) - env_db, 0, 9)
    g_db = smooth(g_db, w)
    g_db[:int(0.05 * SR)] *= np.linspace(0, 1, int(0.05 * SR))  # blend start continues mid exactly
    ramp = int(0.05 * SR)
    g_db[-ramp:] *= np.linspace(1, 0, ramp)
    blend = blend * (10 ** (g_db / 20))[:, None]
    out = np.concatenate([mid, blend]).astype(np.float32)
    # cheap guard: tail of blend meets mid[0] naturally (blend ends at body[n]-ish)
    r = subprocess.run([FF, "-v", "error", "-y", "-f", "f32le", "-ar", str(SR), "-ac", "2", "-i", "-",
                        "-c:a", "libvorbis", "-q:a", "5", f], input=out.tobytes(), capture_output=True)
    print(base, "trim %.1f-%.1f of %.1f -> %.1fs" % (t0, t1, len(x) / SR, len(out) / SR), r.stderr.decode()[:200])

if __name__ == "__main__":
    files = sorted(glob.glob(MUS + "/*.ogg"))
    if sys.argv[1] == "build":
        for f in files: build(f)
    else:
        src = ORIG if sys.argv[1] == "measure_orig" else MUS
        for f in files:
            p = os.path.join(src, os.path.basename(f))
            med, mn, d = seam(p)
            print("%-14s body %.1f dB  seam min %.1f dB  dip %.1f dB" % (os.path.basename(f), med, mn, d))
