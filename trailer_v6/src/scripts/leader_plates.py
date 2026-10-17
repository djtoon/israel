"""Full-frame 2.39 plates of the game's painted leader portraits (still images: camera/scale/light only).
The 1024x1024 portrait is cropped to face and shoulders (a 1024 x 560 band) and widened to 2.39:1 by
extending its own painted navy backdrop at the sides (edge-stretched, heavily blurred, darkened), so the face
and the shoulders stay untouched paint.   python -I leader_plates.py -> stills/leaders/<id>.png (2000x837)"""
import numpy as np, cv2, sys
P = "C:/civ/game/assets/images/portraits/"
OUT = "C:/civ/trailer_v6/src/stills/leaders/"
IDS = ["pm_ben_gurion", "us_truman", "pm_eshkol", "us_johnson", "pm_meir", "us_nixon", "pm_begin", "us_carter",
       "pm_rabin", "us_clinton", "pm_sharon", "us_bush43", "pm_netanyahu"]
Y0 = {"pm_ben_gurion": 50}   # band top (default 80)
BH = 560
TW, TH = 2000, 837   # 2.39:1, a little larger than 1920x804 for the push-in


def plate(pid):
    im = cv2.imread(P + pid + ".png").astype(np.float32)
    y0 = Y0.get(pid, 80)
    band = im[y0:y0 + BH]
    s = TH / BH
    core = cv2.resize(band, (int(round(1024 * s)), TH), interpolation=cv2.INTER_LANCZOS4)
    cw = core.shape[1]
    side = (TW - cw) // 2 + 2
    # backdrop: the band stretched to the full width, blurred hard, darkened -> painted navy continues
    back = cv2.resize(band, (TW, TH), interpolation=cv2.INTER_AREA)
    back = cv2.GaussianBlur(back, (0, 0), 38) * 0.62
    out = back.copy()
    x0 = (TW - cw) // 2
    # feathered blend of the untouched portrait over the backdrop (feather only in the outer 90 px)
    xs = np.arange(cw, dtype=np.float32)
    a = np.clip(np.minimum(xs, cw - 1 - xs) / 90.0, 0, 1)[None, :, None]
    out[:, x0:x0 + cw] = core * a + out[:, x0:x0 + cw] * (1 - a)
    # gentle sharpen of the upscaled paint, and a vignette that pulls focus to the face
    bl = cv2.GaussianBlur(out, (0, 0), 1.2)
    out = cv2.addWeighted(out, 1.4, bl, -0.4, 0)
    yy, xx = np.mgrid[0:TH, 0:TW].astype(np.float32)
    v = 1 - 0.45 * np.clip(((xx - TW / 2) / (TW * 0.55)) ** 2 + ((yy - TH * 0.42) / (TH * 0.9)) ** 2, 0, 1)
    out *= v[..., None]
    cv2.imwrite(OUT + pid + ".png", np.clip(out, 0, 255).astype(np.uint8))


for pid in IDS:
    plate(pid)
print("ok", len(IDS))
