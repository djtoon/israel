import numpy as np, wave, os, sys
SR = 44100
out = sys.argv[1]
os.makedirs(out, exist_ok=True)
rng = np.random.default_rng(7)


def t(d):
    return np.arange(int(SR * d)) / SR


def env(n, a=0.003, r=0.05, curve=3.0):
    x = np.ones(n)
    na = max(1, int(SR * a))
    x[:na] = np.linspace(0, 1, na)
    nr = min(n, max(1, int(SR * r)))
    x[-nr:] *= np.linspace(1, 0, nr) ** curve
    return x


def decay(tt, tau):
    return np.exp(-tt / tau)


def tone(f, d, tau=0.08, harm=(1, 0.3, 0.1)):
    tt = t(d)
    y = sum(h * np.sin(2 * np.pi * f * (i + 1) * tt) for i, h in enumerate(harm))
    return y * decay(tt, tau) * env(len(tt), 0.002, 0.02)


def noise_band(d, lo, hi, tau):
    tt = t(d)
    n = rng.standard_normal(len(tt))
    F = np.fft.rfft(n)
    fr = np.fft.rfftfreq(len(n), 1 / SR)
    F[(fr < lo) | (fr > hi)] = 0
    y = np.fft.irfft(F, len(n))
    y /= np.max(np.abs(y)) + 1e-9
    return y * decay(tt, tau) * env(len(tt), 0.002, 0.02)


def pad(*parts, gap=0.0):
    return np.concatenate(parts)


def mix(*ys):
    n = max(len(y) for y in ys)
    o = np.zeros(n)
    for y in ys:
        o[:len(y)] += y
    return o


def at(y, off, total):
    o = np.zeros(total)
    s = int(SR * off)
    o[s:s + len(y)] += y[:total - s]
    return o


def save(name, y, peak_db=-4.5):
    y = y / (np.max(np.abs(y)) + 1e-9) * 10 ** (peak_db / 20)
    y = np.append(y, np.zeros(int(SR * 0.02)))
    with wave.open(f"{out}/{name}.wav", "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes((np.clip(y, -1, 1) * 32767).astype("<i2").tobytes())


# click: soft wooden tick
save("click", mix(tone(1800, 0.05, 0.012, (1, .4)), noise_band(0.03, 2000, 6000, 0.006) * 0.4))
save("hover", tone(2600, 0.035, 0.01, (1, .15)) * 0.5, -12)
# panel open: rising soft whoosh + tone; close: falling
def sweep(f0, f1, d):
    tt = t(d)
    f = np.linspace(f0, f1, len(tt))
    ph = 2 * np.pi * np.cumsum(f) / SR
    return (np.sin(ph) + 0.25 * np.sin(2 * ph)) * env(len(tt), 0.01, 0.08, 2)
save("panel_open", mix(sweep(420, 760, 0.16) * 0.7, noise_band(0.16, 800, 4000, 0.07) * 0.25), -6)
save("panel_close", mix(sweep(700, 380, 0.14) * 0.7, noise_band(0.14, 600, 3000, 0.06) * 0.2), -7)
# end turn: two-note soft bell/chime plus low thud
tot = int(SR * 0.9)
bell = lambda f, d=0.8: tone(f, d, 0.22, (1, .5, .25, .12))
save("end_turn", mix(at(tone(110, 0.25, 0.08, (1, .5)) * 0.9, 0, tot), at(bell(392), 0.03, tot) * 0.7, at(bell(523.25), 0.16, tot) * 0.7), -4)
# build complete: rising major arpeggio with hammer tick
tot = int(SR * 1.1)
save("build_complete", mix(at(noise_band(0.05, 1500, 5000, 0.01), 0, tot) * 0.5, at(bell(392, 0.7), 0.06, tot), at(bell(493.88, 0.7), 0.17, tot), at(bell(587.33, 0.7), 0.28, tot), at(bell(783.99, 0.8), 0.40, tot)), -4)
# notification: two-tone ping
tot = int(SR * 0.6)
save("notification", mix(at(bell(880, 0.4), 0, tot), at(bell(1174.66, 0.45), 0.12, tot) * 0.9), -5)
# unit move: soft footstep pair / cloth
tot = int(SR * 0.35)
step = lambda: mix(noise_band(0.08, 150, 1200, 0.025), tone(90, 0.08, 0.03, (1,)) * 0.6)
save("unit_move", mix(at(step(), 0, tot), at(step() * 0.8, 0.17, tot)), -8)
# unit attack: low impact + metallic noise burst
tot = int(SR * 0.55)
save("unit_attack", mix(at(tone(70, 0.4, 0.09, (1, .6, .3)), 0, tot), at(noise_band(0.25, 400, 7000, 0.07), 0, tot) * 0.8, at(tone(1250, 0.3, 0.06, (1, .3)), 0.01, tot) * 0.2), -3.5)
save("deny", mix(tone(220, 0.14, 0.06, (1, .4)), at(tone(165, 0.18, 0.08, (1, .4)), 0.1, int(SR * 0.3))), -8)
