"""The v6 trailer sound: the edited score + sound design + the game's own UI sounds, mixed to -14 LUFS / -1 dBTP.
   python -I mix.py  ->  work/mix.wav
Score edit (score_a1.wav, downbeats on whole seconds, 4-s bars, 8-s phrases):
   a1[4:88] -> trailer 7:91 (one continuous take), a1[96:106] -> trailer 91:101 (the drop and the final hit at 95).
   Act 1 lifted +6 dB, Act 3 (51-67) through a low-pass that opens from 420 Hz to full over the act (the "decisions" pulse)."""
import numpy as np, subprocess, json

SR = 48000
TOTAL = 102.0
SRC = "C:/civ/trailer_v6/src/"
G = "C:/civ/game/assets/audio/"


def load(p):
    raw = subprocess.run(["ffmpeg", "-v", "error", "-i", p, "-ac", "2", "-ar", str(SR), "-f", "f32le", "-"],
                         capture_output=True).stdout
    return np.frombuffer(raw, np.float32).reshape(-1, 2).astype(np.float64)


def db(x):
    return 10 ** (x / 20)


N = int(TOTAL * SR)
mus = np.zeros((N, 2))
sfx = np.zeros((N, 2))
a1 = load(SRC + "music/score_a1.wav")


def put(buf, x, t, gain_db=0.0, fade_in=0.0, fade_out=0.0):
    x = x.copy() * db(gain_db)
    if fade_in:
        n = int(fade_in * SR); x[:n] *= np.linspace(0, 1, n)[:, None] ** 2
    if fade_out:
        n = int(fade_out * SR); x[-n:] *= np.linspace(1, 0, n)[:, None] ** 2
    i0 = int(round(t * SR))
    if i0 < 0:
        x = x[-i0:]; i0 = 0
    n = min(len(x), N - i0)
    buf[i0:i0 + n] += x[:n]


# ---- the score
seg1 = a1[int(4 * SR):int(88 * SR) + int(0.04 * SR)]
seg2 = a1[int(96 * SR) - int(0.04 * SR):]
xf = int(0.04 * SR)
seg1[-xf:] *= np.linspace(1, 0, xf)[:, None]
seg2[:xf] *= np.linspace(0, 1, xf)[:, None]
put(mus, seg1, 7.0, fade_in=0.35)
put(mus, seg2, 91.0 - 0.04)
# gain automation (dB) by time
tt = np.arange(N) / SR
gain = np.interp(tt, [0, 7, 33.5, 35.0, 50.8, 51.2, 66.5, 67, 99.5, 101.3, 102], [0, 10, 10, 3.5, 3.5, 2.5, 2.5, 0, 0, -14, -60])
mus *= db(gain)[:, None]
# Act 3: a two-pole low-pass that opens over the act
a, b = int(50.9 * SR), int(67.05 * SR)
seg = mus[a:b].copy()
u = np.linspace(0, 1, b - a)
fc = 420 * (20000 / 420) ** (u ** 2.2)
fc[: int(0.1 * SR)] = np.linspace(20000, 420, int(0.1 * SR))  # snap closed on the cut
al = np.exp(-2 * np.pi * fc / SR)
y = np.zeros_like(seg)
for _ in range(2):
    s = np.zeros(2)
    out = np.empty_like(seg)
    for k in range(len(seg)):
        s = (1 - al[k]) * seg[k] + al[k] * s
        out[k] = s
    seg = out
mus[a:b] = seg

# ---- sound design (synthesised in sfx.py) and the game's UI sounds
S = lambda n: load(SRC + f"sfx/{n}.wav")
L = {n: S(n) for n in ["impact_big", "impact_soft", "braam", "subdrop", "riser_4s", "riser_2s", "reverse_1s",
                       "reverse_2s", "whoosh_a", "whoosh_b", "whoosh_fast", "shimmer", "rumble", "tick"]}
UI = {n: load(G + f"sfx/{n}.ogg") for n in ["click", "panel_open", "notification", "end_turn", "hover"]}


def ending(name, t_end, g):
    """place a swell/riser so that it ENDS on t_end"""
    x = L[name]
    put(sfx, x, t_end - len(x) / SR, g)


cues = []
def cue(t, name, g, **kw):
    cues.append((t, name, g))
    put(sfx, L[name] if name in L else UI[name], t, g, **kw)


# cold open
cue(0.0, "rumble", -9, fade_in=1.0)
ending("reverse_2s", 3.3, -6)
cue(3.3, "impact_big", -3); cue(3.3, "subdrop", -6); cue(3.3, "shimmer", -12)
cue(6.2, "whoosh_b", -16)
put(sfx, load(G + "ambience/coast.ogg")[: int(9 * SR)], 7.0, -24, fade_in=1.5, fade_out=2.0)
# act 1
ending("reverse_1s", 19.0, -9)
cue(19.0, "impact_big", -4); cue(19.0, "subdrop", -8); cue(19.0, "shimmer", -17)
cue(23.0, "whoosh_a", -21)
ending("reverse_1s", 27.0, -12); cue(27.0, "impact_soft", -10)
cue(30.9, "whoosh_b", -22)
ending("riser_4s", 35.0, -10)
# act 2
cue(35.0, "impact_big", -2); cue(35.0, "braam", -8); cue(35.0, "subdrop", -6)
for k in range(6):
    cue(39.0 + 2 * k - 0.12, "whoosh_fast", -19)
ending("riser_2s", 51.0, -13)
# act 3: the drop, then the game's own interface sounds on the UI moments
cue(51.0, "subdrop", -4); cue(51.0, "impact_soft", -8); cue(50.85, "whoosh_b", -15)
cue(53.72, "click", -5)
cue(55.0, "panel_open", -8); cue(54.9, "whoosh_a", -18)
cue(55.9, "hover", -14); cue(56.4, "hover", -14)
cue(57.0, "tick", -20); cue(57.6, "tick", -22)
# the diplomacy burst: whip in, a shutter tick on every portrait cut, whip out into the downbeat
cue(58.82, "whoosh_fast", -13); cue(59.0, "impact_soft", -10)
_bf = [12, 12, 6, 6, 6, 6, 6, 6, 6, 6, 4, 4, 4, 12]
_t = 59.0
for _n in _bf[:-1]:
    _t += _n / 24
    cue(_t, "tick", -21 if _n >= 6 else -24)
cue(62.84, "whoosh_fast", -14)
cue(63.0, "panel_open", -10); cue(62.9, "whoosh_a", -17)
cue(64.0, "impact_soft", -7)
ending("riser_2s", 67.0, -9); ending("reverse_1s", 67.0, -8)
# act 4: the climax
cue(67.0, "braam", -3); cue(67.0, "impact_big", -3); cue(67.0, "subdrop", -4)
cue(67.2, "rumble", -16, fade_out=1.5)
for t in (69.0, 70.5, 72.0, 74.0, 76.0, 86.0, 87.0, 88.0):
    cue(t - 0.1, "whoosh_fast", -20)
cue(78.0, "impact_soft", -6); cue(80.0, "rumble", -17, fade_in=0.3, fade_out=1.0)
cue(82.0, "impact_soft", -7); cue(84.0, "impact_soft", -7)
put(sfx, load(G + "ambience/city.ogg")[: int(4 * SR)], 74.0, -26, fade_in=0.3, fade_out=1.0)
# the breath and the finale
cue(91.0, "subdrop", -9)
ending("reverse_2s", 95.0, -6)
cue(95.0, "braam", -6); cue(95.0, "impact_big", -4); cue(95.0, "shimmer", -10)

mix = mus + sfx
# master: gentle glue, then loudness to -14 LUFS and a true-peak limit at -1 dBTP (ffmpeg, two pass)
mix = np.tanh(mix * 0.9) / 0.9
pcm = mix.astype(np.float32)
open(SRC + "work/premix.f32", "wb").write(pcm.tobytes())
json.dump(cues, open(SRC + "work/cues.json", "w"))
pre = ["-f", "f32le", "-ar", str(SR), "-ac", "2", "-i", SRC + "work/premix.f32"]
def measure(path_args):
    e = subprocess.run(["ffmpeg", "-hide_banner"] + path_args + ["-af", "ebur128=peak=true", "-f", "null", "-"],
                       capture_output=True, text=True).stderr
    I = float(e[e.rindex("I:"):].split()[1]); tp = float(e[e.rindex("Peak:"):].split()[1])
    return I, tp


I0, _ = measure(pre)
g = -14.0 - I0
for it in range(3):
    af = f"volume={g:.2f}dB,alimiter=limit=0.83:attack=1:release=80:level=false:asc=1"
    subprocess.run(["ffmpeg", "-v", "error", "-y"] + pre + ["-af", af, "-c:a", "pcm_s24le", SRC + "work/mix.wav"], check=True)
    I, tp = measure(["-i", SRC + "work/mix.wav"])
    print(f"pass {it}: gain {g:+.2f} dB -> {I:.2f} LUFS, true peak {tp:.2f} dBTP")
    if abs(I + 14.0) < 0.15 and tp <= -1.0:
        break
    g += -14.0 - I
print("->", SRC + "work/mix.wav")
