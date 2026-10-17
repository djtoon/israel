"""The picture edit and finishing pass for the v6 cinematic trailer.
   python -I edit.py [--workers 5] [--from S --to S] [--out path]  ->  work/picture.mp4 (no audio)
Per frame: the shot's plate (upscaled + sharpened, speed-ramped with frame blending) -> per-shot balance ->
the one show grade (tone curve, split tone navy shadows / gold highlights, halation, vignette) -> the strata type
overlay (colour + matte passes) -> light leaks and exposure pops on the big hits -> the 2.39:1 letterbox (animated
open for Act 3) -> film grain.  Everything is driven by the shot list SHOTS (trailer seconds, 24 fps)."""
import numpy as np, cv2, subprocess, sys, os, json, math
from concurrent.futures import ProcessPoolExecutor

FPS, W, H = 24, 1920, 1080
TOTAL = 102.0
SRC = "C:/civ/trailer_v6/src/"
SD, FT, WK, ST = SRC + "seedance/", "C:/civ/features/", SRC + "work/", SRC + "stills/"
LB_H = 804                         # 2.39:1 active picture
LB_Y0 = (H - LB_H) // 2            # 138


def sd(n):
    return SD + n + "_a.mp4"


# ------------------------------------------------------------------ the shot list
# t: trailer start, d: duration, src, i: source in-point (s), sp: speed or ramp [(t_rel, speed), ...],
# z: (zoom_start, zoom_end) push, y: vertical offset of the image in px (letterbox framing),
# g: per-shot balance {exp (stops), sat, warm, blur}, xf: cross-dissolve in (s), fi/fo: fade from/to black (s),
# grade: 0 = no show grade (titles/logo), lb: letterboxed (1) or full frame (0)
# the diplomacy burst: 12 painted leaders, cut on the score's 8ths / triplets / 16ths, accelerating into the 63.0 downbeat
LEADERS = [("pm_ben_gurion", "DAVID BEN-GURION", "ISRAEL"), ("us_truman", "HARRY S. TRUMAN", "UNITED STATES"),
           ("pm_eshkol", "LEVI ESHKOL", "ISRAEL"), ("us_johnson", "LYNDON B. JOHNSON", "UNITED STATES"),
           ("pm_meir", "GOLDA MEIR", "ISRAEL"), ("us_nixon", "RICHARD NIXON", "UNITED STATES"),
           ("pm_begin", "MENACHEM BEGIN", "ISRAEL"), ("us_carter", "JIMMY CARTER", "UNITED STATES"),
           ("pm_rabin", "YITZHAK RABIN", "ISRAEL"), ("us_clinton", "BILL CLINTON", "UNITED STATES"),
           ("pm_sharon", "ARIEL SHARON", "ISRAEL"), ("us_bush43", "GEORGE W. BUSH", "UNITED STATES"),
           ("pm_netanyahu", "BENJAMIN NETANYAHU", "ISRAEL"), ("pm_ben_gurion", "DAVID BEN-GURION", "ISRAEL")]
BURST_FRAMES = [12, 12, 6, 6, 6, 6, 6, 6, 6, 6, 4, 4, 4, 12]   # = 96 frames = 59.0 -> 63.0
BURST_T0 = 59.0
BURST, BURST_CUTS = [], []
_f = 0
for (pid, nm, ct), nf in zip(LEADERS, BURST_FRAMES):
    t0 = BURST_T0 + _f / 24
    BURST.append(dict(t=t0, d=nf / 24, src=SRC + f"stills/leaders/{pid}.png", i=0.0, sp=1.0,
                      z=(1.0, 1.0 + (0.045 if nf >= 8 else 0.03)), y=0, lb=1, name=f"leader: {nm}"))
    BURST_CUTS.append((round(t0, 4), nf, nm, ct))
    _f += nf
R_IN = [(0, 1.9), (0.22, 1.0)]                 # Act 2 cut energy: each shot enters fast and settles
R_HIT = [(0, 2.4), (0.3, 1.0), (2.0, 0.85)]    # climax ramps
SHOTS = [
    dict(t=0.0, d=7.0, src="C:/civ/newIntro/logo_comp.mp4", i=6.0, sp=[(0, 1.5), (1.999, 1.5), (2.0, 1.0)], lb=0, grade=0,
         add=WK + "r_logo_fx.mp4", fo=0.6, name="TMT logo + strata light pass"),
    # ACT 1 - the birth
    dict(t=7.0, d=5.0, src=sd("s01_jaffa_dawn"), i=1.0, sp=1.0, z=(1.0, 1.03), fi=1.1, g=dict(exp=-0.1, warm=0.03), name="dawn coast (Seedance)"),
    dict(t=12.0, d=3.0, src=sd("s40_galilee"), i=0.4, sp=1.0, z=(1.02, 1.05), g=dict(exp=-0.05), name="Galilee morning (Seedance)"),
    dict(t=15.0, d=4.0, src=ST + "hall_25d.mp4", i=0.0, sp=1.0, xf=0.5, z=(1.0, 1.07), pan=-60, g=dict(exp=0.0), name="declaration hall 2.5D"),
    dict(t=19.0, d=4.0, src=ST + "hall_25d.mp4", i=4.0, sp=1.0, z=(1.07, 1.13), g=dict(exp=-1.35, sat=0.75, blur=2.2), name="hall under title"),
    dict(t=23.0, d=4.0, src=sd("s03_ship"), i=0.4, sp=1.0, z=(1.0, 1.02), g=dict(exp=-0.15, sat=0.92), name="the ship (Seedance)"),
    dict(t=27.0, d=4.0, src=sd("s05_ezra"), i=0.3, sp=1.0, z=(1.02, 1.0), g=dict(exp=-0.15, sat=0.9), name="the airlift (Seedance)"),
    dict(t=31.0, d=4.0, src=sd("s04_maabarot"), i=0.6, sp=1.0, xf=0.6, z=(1.0, 1.03), g=dict(exp=-0.1), name="transit camp (Seedance)"),
    # ACT 2 - build a nation
    dict(t=35.0, d=4.0, src=FT + "06_living_map_timelapse.mp4", i=0.0, sp=1.25, z=(1.04, 1.0), y=-20, name="the timelapse (game)"),
    dict(t=39.0, d=2.0, src=sd("s11_water"), i=0.9, sp=R_IN, name="water carrier (Seedance)"),
    dict(t=41.0, d=2.0, src=FT + "08_hdplus_graphics.mp4", i=2.2, sp=R_IN, z=(1.02, 1.06), y=30, name="HD+ fields (game)"),
    dict(t=43.0, d=2.0, src=sd("s14_haifa"), i=1.2, sp=R_IN, name="Haifa golden hour (Seedance)"),
    dict(t=45.0, d=2.0, src=sd("s16_highway"), i=1.5, sp=R_IN, name="highway (Seedance)"),
    dict(t=47.0, d=2.0, src=sd("s23_rail"), i=1.4, sp=R_IN, name="railway (Seedance)"),
    dict(t=49.0, d=2.0, src="C:/civ/work_video/tlv_test.mp4", i=0.6, sp=R_IN, name="Tel Aviv towers crane (Seedance)"),
    # ACT 3 - every decision. 59-63: the diplomacy burst (full-frame painted portraits, still images: camera/scale/light only)
    *BURST,
    # ACT 3 - every decision (strata, full frame)
    dict(t=51.0, d=16.0, src=WK + "r_act3.mp4", i=0.0, sp=1.0, lb=0, grade=0.5, name="Act 3 strata 3D UI"),
    # ACT 4 - climax
    dict(t=67.0, d=2.0, src=sd("s19_shavit"), i=0.0, sp=[(0, 1.0), (0.5, 1.2), (2.0, 1.45)], z=(1.0, 1.08), name="rocket launch (Seedance)"),
    dict(t=69.0, d=1.5, src=sd("s39_jerusalem"), i=1.8, sp=R_HIT, z=(1.0, 1.09), name="Jerusalem golden (Seedance)"),
    dict(t=70.5, d=1.5, src=sd("s15_eilat"), i=0.3, sp=R_HIT, z=(1.09, 1.0), name="Eilat (Seedance)"),
    dict(t=72.0, d=2.0, src=FT + "07_day_night.mp4", i=0.0, sp=[(0, 2.4), (2.0, 2.4)], z=(1.0, 1.06), name="golden hour to night (game)"),
    dict(t=74.0, d=2.0, src=sd("s30_night"), i=1.5, sp=1.3, z=(1.0, 1.08), g=dict(exp=0.35), name="night city (Seedance)"),
    dict(t=76.0, d=2.0, src=sd("s35_eurovision"), i=1.0, sp=R_HIT, z=(1.0, 1.1), g=dict(exp=-0.1), name="stage lights (Seedance)"),
    dict(t=78.0, d=2.0, src=WK + "r_fronts.mp4", i=0.0, sp=1.0, grade=0.5, name="war fronts card (strata)"),
    dict(t=80.0, d=2.0, src=sd("s32_tanks"), i=0.6, sp=1.6, z=(1.0, 1.08), pan=-80, g=dict(exp=-0.35, sat=0.85), name="armour in the dust (Seedance)"),
    dict(t=82.0, d=2.0, src=ST + "treaty_25d.mp4", i=0.3, sp=1.0, z=(1.0, 1.09), g=dict(exp=-0.1), name="peace treaty 2.5D"),
    dict(t=84.0, d=2.0, src=sd("s20_beresheet"), i=1.5, sp=1.4, z=(1.0, 1.08), name="moon lander (Seedance)"),
    dict(t=86.0, d=1.0, src=sd("s17_desal"), i=1.0, sp=R_HIT, z=(1.0, 1.07), name="desalination (Seedance)"),
    dict(t=87.0, d=1.0, src=sd("s21_whitecity"), i=1.5, sp=R_HIT, z=(1.07, 1.0), name="White City (Seedance)"),
    dict(t=88.0, d=1.0, src=sd("s11_water"), i=3.6, sp=R_HIT, z=(1.0, 1.07), name="water (Seedance)"),
    dict(t=89.0, d=2.0, src=sd("s14_haifa"), i=3.3, sp=0.8, z=(1.0, 1.06), name="Haifa last gold (Seedance)"),
    # the breath, then the finale
    dict(t=91.0, d=2.75, src="C:/civ/work_video/tlv_test.mp4", i=2.6, sp=0.8, fo=1.0, z=(1.0, 1.03), name="last light (Seedance)"),
    dict(t=93.75, d=8.25, src=WK + "r_finale.mp4", i=0.0, sp=1.0, lb=0, grade=0, name="finale strata logo resolve"),
]
LEAKS = [(7.0, 2.2, 0.55), (19.0, 1.2, 0.5), (35.0, 1.1, 0.75), (58.95, 0.6, 0.32), (61.0, 0.4, 0.16), (62.7, 0.5, 0.22),
         (67.0, 1.2, 0.85), (95.0, 1.6, 0.6)]  # t, dur, strength
# soft dark "slots" graded into the plate under the type (t0, t1, y centre, half height, strength)
SLOTS = [(8.0, 11.9, 872, 120, 0.35), (15.4, 18.9, 872, 120, 0.35), (23.3, 26.9, 850, 140, 0.45),
         (27.2, 30.9, 850, 140, 0.45), (34.9, 38.9, 530, 260, 0.38), (39.0, 51.0, 858, 130, 0.45),
         (59.0, 63.0, 860, 130, 0.45), (78.0, 86.0, 846, 150, 0.5)]
_ys = np.arange(H, dtype=np.float32)


def slot_gain(t):
    g = np.ones(H, np.float32)
    for t0, t1, yc, hh, st in SLOTS:
        if t0 <= t < t1:
            env = min(1.0, (t - t0) / 0.3, (t1 - t) / 0.3)
            g *= 1 - st * env * np.exp(-((_ys - yc) / hh) ** 2)
    return g[:, None, None]


POPS = [(19.0, 0.35), (35.0, 0.5), (59.0, 0.55), (60.0, 0.22), (61.0, 0.28), (62.0, 0.22), (62.5, 0.3),
        (63.0, 0.45), (67.0, 0.6), (78.0, 0.25), (82.0, 0.25), (84.0, 0.25)]  # exposure flash on hits


def lb_amount(t):
    """1 = 2.39 bars in, 0 = full frame; the bars glide open for Act 3 and close on the climax hit"""
    e = lambda u: 0.5 - 0.5 * math.cos(math.pi * min(max(u, 0), 1))
    if t < 7.0 or t >= 93.75:
        return 0.0
    if 59.0 <= t < 63.0:   # the diplomacy burst plays in scope
        return 1.0
    if 51.0 <= t < 67.0:
        return max(1 - e((t - 51.0) / 0.45), e((t - 66.6) / 0.4))
    return 1.0


# ------------------------------------------------------------------ helpers
def probe(path):
    out = subprocess.run(["ffprobe", "-v", "error", "-select_streams", "v:0", "-show_entries",
                          "stream=width,height,r_frame_rate", "-of", "json", path], capture_output=True, text=True).stdout
    s = json.loads(out)["streams"][0]
    a, b = s["r_frame_rate"].split("/")
    return s["width"], s["height"], float(a) / float(b)


def src_time_fn(sp, d):
    if not isinstance(sp, list):
        return lambda tr: sp * tr
    pts = np.array(sp, float)
    ts = np.linspace(0, d + 1.0, 2000)
    spd = np.interp(ts, pts[:, 0], pts[:, 1])
    cum = np.concatenate([[0], np.cumsum((spd[1:] + spd[:-1]) / 2 * np.diff(ts))])
    return lambda tr: float(np.interp(tr, ts, cum))


class Stream:
    """sequential frame reader from an ffmpeg pipe with a small look-back cache (memory-light random access
    for monotonic time maps)"""
    def __init__(self, path, t0, w, h):
        self.w, self.h = w, h
        self.p = subprocess.Popen(["ffmpeg", "-v", "error", "-ss", f"{max(0.0, t0):.4f}", "-i", path, "-f", "rawvideo",
                                   "-pix_fmt", "bgr24", "-"], stdout=subprocess.PIPE, bufsize=w * h * 3 * 2)
        self.cache, self.n, self.last = {}, 0, None
        self.size = w * h * 3

    def get(self, k):
        while self.n <= k:
            buf = self.p.stdout.read(self.size)
            if len(buf) < self.size:
                break
            self.last = np.frombuffer(buf, np.uint8).reshape(self.h, self.w, 3)
            self.cache[self.n] = self.last
            self.n += 1
            for old in [x for x in self.cache if x < self.n - 8]:
                del self.cache[old]
        if k in self.cache:
            return self.cache[k]
        if k >= self.n:
            return self.last if self.last is not None else np.zeros((self.h, self.w, 3), np.uint8)
        return self.cache[min(self.cache)]

    def close(self):
        try:
            self.p.kill()
        except Exception:
            pass


class Source:
    def __init__(self, shot, ta=0.0, tb=None):
        self.shot = shot
        self.path = shot["src"]
        self.w, self.h, self.fps = probe(self.path)
        d = shot["d"] + 2.0
        self.st = src_time_fn(shot.get("sp", 1.0), d)
        tb = d if tb is None else tb
        t0 = shot.get("i", 0.0) + self.st(max(0.0, ta))
        if self.path.lower().endswith((".png", ".jpg")):
            t0 = 0.0
        # start the decode on the source's own frame grid, so a 1:1 shot maps frame to frame (no blend)
        self.base = max(0.0, math.floor((t0 - 0.05) * self.fps + 1e-6) / self.fps)
        self.stream = Stream(self.path, self.base, self.w, self.h)
        self.count = 10 ** 9

    def at(self, trel, speed_hint):
        """source frame for shot-relative time trel, with frame blending (and shutter blur when fast)"""
        if self.path.lower().endswith((".png", ".jpg")):
            return self.stream.get(0).astype(np.float32)
        s0 = self.shot.get("i", 0.0) + self.st(trel)
        s1 = self.shot.get("i", 0.0) + self.st(trel + 0.5 / FPS)
        k = int(min(5, max(1, round((s1 - s0) * self.fps * 2))))
        acc = None
        for j in range(k):
            s = s0 + (s1 - s0) * (j / k if k > 1 else 0)
            f = (s - self.base) * self.fps
            f = max(f, 0)
            a = int(f + 1e-4); w = f - a
            if w < 0.03:
                w = 0.0
            elif w > 0.97:
                a, w = a + 1, 0.0
            img = self.stream.get(a).astype(np.float32)
            if w > 0.02:
                img = img * (1 - w) + self.stream.get(a + 1).astype(np.float32) * w
            acc = img if acc is None else acc + img
        return acc / k


def place(img, shot, trel):
    """fit the source to the 1920x1080 canvas: width-fit, centred (+y), push-zoom; sharpen generated footage"""
    h, w = img.shape[:2]
    s = W / w
    z = shot.get("z", (1.0, 1.0))
    u = trel / shot["d"]
    zz = z[0] + (z[1] - z[0]) * (u * u * (3 - 2 * u) * 0.6 + 0.4 * u)
    sc = s * zz
    if w * s * 1.0 < W or h * s < (LB_H if shot.get("lb", 1) else H):
        sc = max(sc, (LB_H if shot.get("lb", 1) else H) / h)
    px = shot.get("pan", 0) * (u - 0.5)
    M = np.float32([[sc, 0, W / 2 - sc * w / 2 + px], [0, sc, H / 2 - sc * h / 2 + shot.get("y", 0)]])
    out = cv2.warpAffine(img, M, (W, H), flags=cv2.INTER_LANCZOS4 if sc > 1.05 else cv2.INTER_LINEAR,
                         borderMode=cv2.BORDER_CONSTANT)
    if sc > 1.2:  # upscaled 720p generations: unsharp to match the 1080p game footage
        bl = cv2.GaussianBlur(out, (0, 0), 1.3)
        out = cv2.addWeighted(out, 1.55, bl, -0.55, 0)
    return out


# ------------------------------------------------------------------ the look
_x = np.linspace(0, 1, 1024)
_curve = np.interp(_x, [0, 0.06, 0.25, 0.5, 0.75, 0.92, 1.0], [0.0, 0.035, 0.215, 0.5, 0.775, 0.925, 0.975])
LUT = (_curve * 1023).astype(np.float32)
yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
VIG = (1 - 0.32 * np.clip(((xx - W / 2) / (W * 0.62)) ** 2 + ((yy - H / 2) / (H * 0.7)) ** 2, 0, 1.4) ** 1.6)[..., None]
_rng = np.random.default_rng(23)
GRAIN = [cv2.resize(cv2.GaussianBlur(_rng.standard_normal((H // 2, W // 2)).astype(np.float32), (0, 0), 0.6), (W, H),
                    interpolation=cv2.INTER_LINEAR) for _ in range(10)]


def balance(img, g):
    if not g:
        return img
    img = img * (2 ** g.get("exp", 0.0))
    w = g.get("warm", 0.0)
    if w:
        img[..., 2] *= 1 + w; img[..., 0] *= 1 - w
    if "sat" in g:
        l = img @ np.float32([0.114, 0.587, 0.299])
        img = l[..., None] + (img - l[..., None]) * g["sat"]
    if g.get("blur"):
        img = cv2.GaussianBlur(img, (0, 0), g["blur"])
    return img


def show_grade(img, amt):
    """img float BGR 0..1"""
    if amt <= 0:
        return img
    src = img
    l = img @ np.float32([0.114, 0.587, 0.299])
    # halation: warm bloom around the highlights
    hl = np.clip((l - 0.72) / 0.28, 0, 1)
    small = cv2.resize(hl, (W // 4, H // 4), interpolation=cv2.INTER_AREA)
    small = cv2.GaussianBlur(small, (0, 0), 7)
    hal = cv2.resize(small, (W, H), interpolation=cv2.INTER_LINEAR)[..., None] * np.float32([0.10, 0.26, 0.55])
    img = img + hal * 0.55
    # saturation, gently
    img = l[..., None] + (img - l[..., None]) * 1.05
    # tone curve
    idx = np.clip(img * 1023, 0, 1023)
    img = LUT[idx.astype(np.int32)] / 1023.0
    # split tone: navy shadows, gold highlights
    l2 = img @ np.float32([0.114, 0.587, 0.299])
    sw = np.clip(1 - l2 / 0.42, 0, 1)[..., None] ** 1.5
    hw = np.clip((l2 - 0.55) / 0.45, 0, 1)[..., None] ** 1.2
    img = img + sw * np.float32([0.030, 0.008, -0.012]) + hw * np.float32([-0.035, 0.004, 0.028])
    img = img * VIG
    return src * (1 - amt) + img * amt if amt < 1 else img


def leak(t):
    """procedural warm light leaks on the big hits (screen-blended)"""
    tot = None
    for t0, d, st in LEAKS:
        u = (t - t0) / d
        if not (-0.05 <= u <= 1.0):
            continue
        env = math.sin(math.pi * min(max(u, 0), 1)) ** 1.5 * st
        sw, sh = 240, 135
        Y, X = np.mgrid[0:sh, 0:sw].astype(np.float32)
        acc = np.zeros((sh, sw, 3), np.float32)
        for k, (col, sx, sy, r) in enumerate([((0.25, 0.55, 1.0), -0.2, 0.3, 0.55), ((0.15, 0.35, 0.95), 0.2, 0.7, 0.4),
                                               ((0.55, 0.8, 1.0), -0.5, 0.5, 0.3)]):
            cx = (sx + 1.6 * u + 0.15 * k) * sw
            cy = sy * sh
            g = np.exp(-(((X - cx) / (r * sw)) ** 2 + ((Y - cy) / (r * sh * 1.3)) ** 2))
            acc += g[..., None] * np.float32(col)
        acc = cv2.resize(acc, (W, H), interpolation=cv2.INTER_CUBIC) * env
        tot = acc if tot is None else tot + acc
    return tot


WHIPS = [59.0, 63.0]   # horizontal whip-blur through these cuts (in and out of the burst)


def whip(img, t):
    for tc in WHIPS:
        a = 1 - abs(t - tc) / 0.13
        if a > 0:
            L = int(9 + 150 * a * a)
            small = cv2.resize(img, (W // 2, H // 2), interpolation=cv2.INTER_AREA)
            k = np.ones((1, L // 2 * 2 + 1), np.float32) / (L // 2 * 2 + 1)
            bl = cv2.resize(cv2.filter2D(small, -1, k, borderType=cv2.BORDER_REFLECT), (W, H))
            return img * (1 - a) + bl * a
    return img


def pop(t):
    v = 0.0
    for t0, s in POPS:
        if 0 <= t - t0 < 0.3:
            v += s * math.exp(-(t - t0) / 0.07)
    return v


class Overlay:
    """strata type passes, colour and matte, decoded once per worker for its frame range"""
    def __init__(self, f0, f1):
        self.f0 = f0
        self.c = Stream(WK + "r_type_color.mp4", f0 / FPS, W, H)
        self.m = Stream(WK + "r_type_matte.mp4", f0 / FPS, W, H)

    def apply(self, img, f):
        k = f - self.f0
        m = self.m.get(k)
        if m.max() < 8:
            return img
        a = m.astype(np.float32).mean(2, keepdims=True) / 255.0
        a = np.clip(a * 1.08, 0, 1)
        return img * (1 - a) + self.c.get(k).astype(np.float32) / 255.0


def shot_at(t):
    fi = int(round(t * FPS))
    for i, s in enumerate(SHOTS):
        if int(round(s["t"] * FPS)) <= fi < int(round((s["t"] + s["d"]) * FPS)):
            return i
    return len(SHOTS) - 1


def render_range(args):
    f0, f1, out = args
    cache = {}
    ov = Overlay(f0, f1)
    ff = subprocess.Popen(["ffmpeg", "-v", "error", "-y", "-f", "rawvideo", "-pix_fmt", "bgr24", "-s", f"{W}x{H}",
                           "-r", str(FPS), "-i", "-", "-c:v", "libx264", "-preset", "slow", "-crf", "10",
                           "-pix_fmt", "yuv420p", out], stdin=subprocess.PIPE)

    def plate(i, t):
        s = SHOTS[i]
        if i not in cache:
            for k in list(cache):
                if k < i - 1:
                    cache[k].stream.close(); del cache[k]
            cache[i] = Source(s, f0 / FPS - s["t"] - 0.1, f1 / FPS - s["t"] + 0.1)
        src = cache[i]
        trel = t - s["t"]
        img = place(src.at(trel, 1), s, trel).astype(np.float32) / 255.0
        img = balance(img, s.get("g"))
        add = s.get("add")
        if add:
            if "add_src" not in s:
                s["add_src"] = Source(dict(src=add, i=0.0, d=s["d"], sp=1.0), f0 / FPS - s["t"] - 0.1,
                                      f1 / FPS - s["t"] + 0.1)
            img = img + s["add_src"].at(trel, 1).astype(np.float32) / 255.0
        fi, fo = s.get("fi", 0), s.get("fo", 0)
        if fi and trel < fi:
            img = img * (trel / fi) ** 1.5
        if fo and trel > s["d"] - fo:
            img = img * max(0, (s["d"] - trel) / fo) ** 1.5
        return img, s.get("grade", 1.0)

    for f in range(f0, f1):
        t = f / FPS
        i = shot_at(t)
        img, gamt = plate(i, t)
        s = SHOTS[i]
        xf = s.get("xf", 0)
        if xf and t - s["t"] < xf and i > 0:
            prev, pg = plate(i - 1, t)
            u = (t - s["t"]) / xf
            u = u * u * (3 - 2 * u)
            img = prev * (1 - u) + img * u
        img = show_grade(img, gamt)
        img = whip(img, t)
        img = img * slot_gain(t)
        p = pop(t)
        if p:
            img = img * (1 + p) + p * 0.06
        lk = leak(t)
        if lk is not None:
            img = 1 - (1 - np.clip(img, 0, 1)) * (1 - np.clip(lk, 0, 1))
        img = ov.apply(img, f)
        # letterbox
        a = lb_amount(t)
        if a > 0:
            bh = int(round(LB_Y0 * a))
            if bh:
                img[:bh] = 0; img[H - bh:] = 0
        # grain (after everything, as on film)
        l = img @ np.float32([0.114, 0.587, 0.299])
        gw = 0.6 + 0.4 * (1 - np.abs(2 * np.clip(l, 0, 1) - 1))
        img = img + (GRAIN[(f * 7) % len(GRAIN)] * 0.024 * gw)[..., None]
        ff.stdin.write((np.clip(img, 0, 1) * 255 + 0.5).astype(np.uint8).tobytes())
    ff.stdin.close(); ff.wait()
    return out


if __name__ == "__main__":
    args = sys.argv[1:]
    workers = int(args[args.index("--workers") + 1]) if "--workers" in args else 5
    a0 = float(args[args.index("--from") + 1]) if "--from" in args else 0.0
    a1 = float(args[args.index("--to") + 1]) if "--to" in args else TOTAL
    out = args[args.index("--out") + 1] if "--out" in args else WK + "picture.mp4"
    F0, F1 = int(round(a0 * FPS)), int(round(a1 * FPS))
    # split on shot boundaries where possible so a worker decodes few sources
    n = max(workers * 4, int((F1 - F0) / 40))
    edges = [F0 + (F1 - F0) * k // n for k in range(n + 1)]
    jobs = [(edges[k], edges[k + 1], WK + f"chunk_{k:03d}.mp4") for k in range(n)]
    with ProcessPoolExecutor(workers) as ex:
        for r in ex.map(render_range, jobs):
            print("done", r, flush=True)
    with open(WK + "chunks.txt", "w") as fh:
        for _, _, p in jobs:
            fh.write(f"file '{p}'\n")
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-f", "concat", "-safe", "0", "-i", WK + "chunks.txt", "-c", "copy", out],
                   check=True)
    print("wrote", out)
