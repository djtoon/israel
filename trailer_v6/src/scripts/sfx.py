"""Synthesised trailer sound design (numpy): impacts, braams, sub drops, risers, reverse swells, whooshes, shimmer.
   python -I sfx.py  ->  C:/civ/trailer_v6/src/sfx/*.wav  (44.1 kHz stereo float WAV)"""
import numpy as np, wave, os

SR = 44100
OUT = "C:/civ/trailer_v6/src/sfx"
os.makedirs(OUT, exist_ok=True)
rng = np.random.default_rng(1948)


def t_(d):
    return np.arange(int(d * SR)) / SR


def write(name, x, rev=False):
    if x.ndim == 1:
        x = np.stack([x, x], 1)
    n = len(x)
    if rev:  # grows to a hard stop: short fade at the very end only
        x = x * np.minimum(np.arange(n)[::-1] / (0.004 * SR), 1)[:, None]
    else:    # soft start guard and a long natural tail fade
        x = x * np.minimum(np.arange(n) / (0.002 * SR), 1)[:, None]
        x = x * np.clip((n - np.arange(n)) / (0.35 * n), 0, 1)[:, None] ** 1.5
    x = x / (np.max(np.abs(x)) + 1e-9) * 0.89
    pcm = (np.clip(x, -1, 1) * 32767).astype(np.int16)
    with wave.open(f"{OUT}/{name}.wav", "wb") as w:
        w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR); w.writeframes(pcm.tobytes())


def onepole_lp(x, fc):
    """time-varying one-pole low-pass; fc scalar or per-sample array"""
    fc = np.broadcast_to(np.asarray(fc, float), x.shape[:1])
    a = np.exp(-2 * np.pi * fc / SR)
    y = np.empty_like(x); s = np.zeros(x.shape[1:]) if x.ndim > 1 else 0.0
    for i in range(len(x)):
        s = (1 - a[i]) * x[i] + a[i] * s
        y[i] = s
    return y


def fft_filter(x, lo=None, hi=None):
    X = np.fft.rfft(x, axis=0); f = np.fft.rfftfreq(len(x), 1 / SR)
    m = np.ones_like(f)
    if lo: m *= 1 / (1 + (lo / np.maximum(f, 1)) ** 4)
    if hi: m *= 1 / (1 + (f / hi) ** 4)
    return np.fft.irfft(X * (m[:, None] if x.ndim > 1 else m), n=len(x), axis=0)


def reverb(x, decay=2.5, wet=0.35, pre=0.02, bright=6000):
    n = int(decay * SR)
    ir = rng.standard_normal((n, 2)) * np.exp(-6.9 * t_(decay) / decay)[:, None]
    ir = fft_filter(ir, lo=120, hi=bright)
    ir[: int(pre * SR)] = 0
    if x.ndim == 1:
        x = np.stack([x, x], 1)
    L = len(x) + n
    y = np.stack([np.fft.irfft(np.fft.rfft(x[:, c], L) * np.fft.rfft(ir[:, c], L), L) for c in range(2)], 1)
    y /= np.max(np.abs(y)) + 1e-9
    xx = np.zeros((L, 2)); xx[: len(x)] = x / (np.max(np.abs(x)) + 1e-9)
    return xx * (1 - wet) + y * wet


def impact(d=4.0, f0=62, f1=32, body=1.0, crack=0.6, tail=3.0):
    t = t_(d)
    f = f1 + (f0 - f1) * np.exp(-t / 0.25)
    sub = np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t / 1.3) * body
    thump = np.sin(2 * np.pi * np.cumsum(140 * np.exp(-t / 0.05) + 60) / SR) * np.exp(-t / 0.12)
    nz = fft_filter(rng.standard_normal(len(t)), lo=200, hi=5000) * np.exp(-t / 0.07) * crack
    x = np.tanh(1.6 * (sub + 0.8 * thump + nz)) * np.clip((d - t) / (0.5 * d), 0, 1) ** 2
    return reverb(x, decay=tail, wet=0.22, bright=2500)


def braam(d=5.0, root=55.0):
    t = t_(d)
    env = np.minimum(t / 0.05, 1) * np.exp(-t / 2.2)
    x = np.zeros(len(t))
    for mult, amp in [(1, 1), (1.5, 0.6), (2, 0.7), (3, 0.25), (0.5, 0.8)]:
        for det in (-0.25, 0, 0.3):
            ph = 2 * np.pi * root * mult * (1 + det / 100) * t
            x += amp * (2 * ((ph / (2 * np.pi)) % 1) - 1)  # saw
    cut = 200 + 2400 * np.exp(-t / 0.6)
    x = onepole_lp(onepole_lp(x / 8, cut), cut)
    x = np.tanh(2.2 * x) * env
    return reverb(x + 0.6 * impact(d, crack=0.3)[: len(t), 0], decay=3.5, wet=0.3)


def sub_drop(d=2.5, f0=90, f1=28):
    t = t_(d)
    f = f1 + (f0 - f1) * np.exp(-t / 0.5)
    return np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t / 0.9) * np.minimum(t / 0.01, 1)


def riser(d=4.0, f0=300, f1=6000, tonal=True):
    t = t_(d)
    u = t / d
    nz = rng.standard_normal((len(t), 2))
    fc = f0 * (f1 / f0) ** (u ** 1.5)
    x = onepole_lp(nz, fc) - onepole_lp(nz, fc * 0.35)
    x = x / (np.max(np.abs(x)) + 1e-9)
    if tonal:
        tone = np.zeros(len(t))
        for k in range(5):  # rising stacked fifths (shepard-like)
            fr = 110 * 2 ** (k * 0.585) * 2 ** (u * 1.0)
            tone += np.sin(2 * np.pi * np.cumsum(fr) / SR) / (k + 1)
        x = x * 0.7 + 0.5 * tone[:, None] / 2
    env = u ** 2.2
    return x * env[:, None]


def reverse_swell(d=2.0):
    # a reversed reverberant hit: grows to a sudden stop
    src = np.zeros((int(0.3 * SR), 2)); src[:200] = rng.standard_normal((200, 2))
    src += np.stack([sub_drop(0.3, 120, 60)] * 2, 1) * 0.5
    wet = reverb(src, decay=d + 0.3, wet=1.0, bright=7000)
    n = int(d * SR)
    y = wet[::-1][-n:]
    u = np.arange(len(y)) / len(y)
    return y * (u ** 2.5)[:, None]


def whoosh(d=0.9, f0=400, f1=2800, pan=True, peak=0.55):
    t = t_(d)
    u = t / d
    nz = rng.standard_normal((len(t), 2))
    fc = f0 + (f1 - f0) * np.sin(np.pi * u)
    x = onepole_lp(nz, fc * 1.6) - onepole_lp(nz, fc * 0.5)
    env = np.where(u < peak, (u / peak) ** 2, ((1 - u) / (1 - peak)) ** 1.5)
    x *= env[:, None]
    if pan:
        p = np.clip(u, 0, 1)
        x[:, 0] *= np.cos(p * np.pi / 2) * 1.2
        x[:, 1] *= np.sin(p * np.pi / 2) * 1.2
    return x


def shimmer(d=4.0):
    t = t_(d)
    x = np.zeros(len(t))
    for f in [1760, 2217, 2637, 3520, 4434]:
        x += np.sin(2 * np.pi * f * t + rng.uniform(0, 6)) * (0.5 + 0.5 * np.sin(2 * np.pi * rng.uniform(3, 7) * t))
    env = np.minimum(t / 0.02, 1) * np.exp(-t / 1.2)
    return reverb(x * env / 5, decay=3.0, wet=0.6, bright=12000)


def rumble(d=6.0):
    t = t_(d)
    nz = rng.standard_normal((len(t), 2))
    x = onepole_lp(onepole_lp(nz, 90), 90)
    x /= np.max(np.abs(x))
    env = np.minimum(t / 2.5, 1) * np.minimum((d - t) / 1.5, 1)
    return x * env[:, None] + 0.3 * sub_drop(d, 45, 38)[:, None] * env[:, None]


def tick(d=0.25):
    t = t_(d)
    x = np.sin(2 * np.pi * 2400 * t) * np.exp(-t / 0.012) + 0.5 * fft_filter(rng.standard_normal(len(t)), lo=3000) * np.exp(-t / 0.006)
    return reverb(x, decay=0.8, wet=0.25, bright=10000)


if __name__ == "__main__":
    write("impact_big", impact(5.0, body=1.0, crack=0.7, tail=3.5))
    write("impact_soft", impact(3.0, f0=50, f1=34, body=0.8, crack=0.2, tail=2.5))
    write("braam", braam(6.0))
    write("braam_hi", braam(5.0, root=73.4))
    write("subdrop", sub_drop(3.0))
    write("riser_4s", riser(4.0), rev=True)
    write("riser_2s", riser(2.0, 500, 7000), rev=True)
    write("reverse_1s", reverse_swell(1.0), rev=True)
    write("reverse_2s", reverse_swell(2.0), rev=True)
    write("whoosh_a", whoosh(0.8))
    write("whoosh_b", whoosh(1.1, 250, 1800, peak=0.45))
    write("whoosh_fast", whoosh(0.45, 600, 4000, peak=0.6))
    write("shimmer", shimmer(4.0))
    write("rumble", rumble(6.0))
    write("tick", tick())
    print("ok")
