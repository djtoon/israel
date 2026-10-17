"""v5-trees: builds the vegetation foliage atlas game/assets/models/vegetation/veg_atlas.png (2048x2048 RGBA).

Sources: painted leaf-cluster cards in veg_src/ (generated with `python tools/gen.py image ... --transparent`,
prompts in progress/v5trees/prompts.txt), plus procedural bark and palm-trunk strips.
Each card is cropped to its alpha, graded toward the game palette, fitted into its cell and colour-bled
into the transparent area (so mipmaps never pull in a dark fringe). The cell rects are mirrored in
scripts/map/tree_kit.gd (TreeKit.CELLS); change both together.

    python game/assets/_pipeline/veg_atlas.py
"""
import os
import colorsys
import numpy as np
from PIL import Image, ImageFilter
from scipy.ndimage import uniform_filter

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "veg_src")
OUT = os.path.join(HERE, "..", "models", "vegetation", "veg_atlas.png")
N = 2048

# name: (x, y, w, h) in pixels; keep in sync with TreeKit.CELLS
CELLS = {
    "broad": (0, 0, 512, 512),
    "pine": (512, 0, 512, 512),
    "olive": (1024, 0, 512, 512),
    "citrus": (1536, 0, 512, 512),
    "bougain": (0, 512, 512, 512),
    "oleander": (512, 512, 512, 512),
    "eucalyptus": (1024, 512, 512, 512),
    "fanfrond": (1536, 512, 512, 512),
    "datefrond": (0, 1024, 1024, 384),
    "acacia": (1024, 1024, 1024, 384),
    "cypress": (0, 1408, 256, 640),
    "deadfronds": (256, 1408, 512, 512),
    "bark": (768, 1408, 256, 256),
    "palmtrunk": (1024, 1408, 256, 640),
}
# grading per card: (saturation x, value x, hue shift)
GRADE = {
    "broad": (0.78, 0.86, 0.075),
    "pine": (1.0, 1.08, 0.0),
    "olive": (1.1, 1.02, 0.015),
    "citrus": (1.0, 1.15, 0.035),
    "bougain": (1.0, 1.05, 0.0),
    "oleander": (1.0, 1.05, 0.0),
    "eucalyptus": (1.1, 1.0, 0.0),
    "fanfrond": (0.95, 1.02, 0.05),
    "datefrond": (0.92, 1.02, 0.06),
    "acacia": (1.12, 0.9, 0.04),
    "cypress": (1.0, 1.5, 0.0),
    "deadfronds": (0.85, 0.95, 0.0),
}
# cards whose leaves are sparse: thicken the alpha a little so the cluster still reads at small sizes
THICKEN = {"olive": 3, "eucalyptus": 3, "acacia": 2, "datefrond": 4, "fanfrond": 2, "pine": 1}


def grade(rgb, s, v, h):
    hsv = np.array(Image.fromarray((np.clip(rgb, 0, 1) * 255).astype(np.uint8)).convert("HSV")).astype(float) / 255
    hsv[..., 0] = (hsv[..., 0] + h) % 1.0
    hsv[..., 1] = np.clip(hsv[..., 1] * s, 0, 1)
    hsv[..., 2] = np.clip(hsv[..., 2] * v, 0, 1)
    return np.array(Image.fromarray((hsv * 255).astype(np.uint8), "HSV").convert("RGB")).astype(float) / 255


def card(name, w, h):
    im = Image.open(os.path.join(SRC, name + ".png")).convert("RGBA")
    a = np.array(im).astype(float) / 255
    m = a[..., 3] > 0.35
    ys, xs = np.where(m)
    im = im.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
    # fit into the cell keeping the aspect, 3% margin
    sc = min(w * 0.94 / im.width, h * 0.94 / im.height)
    im = im.resize((max(1, int(im.width * sc)), max(1, int(im.height * sc))), Image.LANCZOS)
    cell = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    cell.alpha_composite(im, ((w - im.width) // 2, (h - im.height) // 2))
    c = np.array(cell).astype(float) / 255
    al = c[..., 3]
    if name in THICKEN:
        k = THICKEN[name] * 2 + 1
        dil = np.array(Image.fromarray((al * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(k))).astype(float) / 255
        al = np.maximum(al, dil * 0.75)
    rgb = grade(c[..., :3], *GRADE.get(name, (1, 1, 0)))
    return bleed(rgb, al)


def bleed(rgb, al):
    """push-pull colour bleed: transparent texels take the colour of the nearest opaque ones"""
    w = (al > 0.02).astype(float)
    acc = rgb * w[..., None]
    out = rgb.copy()
    filled = w.copy()
    cur_c, cur_w = acc, w
    for r in [2, 4, 8, 16, 32, 64]:
        bc = np.stack([uniform_filter(cur_c[..., i], 2 * r + 1, mode="nearest") for i in range(3)], -1)
        bw = uniform_filter(cur_w, 2 * r + 1, mode="nearest")
        take = (filled < 0.5) & (bw > 1e-4)
        out[take] = bc[take] / bw[take][..., None]
        filled = np.maximum(filled, take.astype(float))
    left = filled < 0.5
    out[left] = rgb[al > 0.5].mean(0) if (al > 0.5).any() else 0.4
    return np.concatenate([np.clip(out, 0, 1), al[..., None]], -1)


def bark(w, h, seed=3):
    rng = np.random.default_rng(seed)
    x = np.arange(w)[None, :] / w
    y = np.arange(h)[:, None] / h
    n = np.zeros((h, w))
    for f, amp in [(6, 0.5), (13, 0.3), (29, 0.2)]:
        ph = rng.uniform(0, 6.28, 4)
        n += amp * np.sin(x * 6.283 * f + ph[0] + np.sin(y * 6.283 * 2 + ph[1]) * 1.5)
    v = 0.86 + 0.12 * n + rng.normal(0, 0.03, (h, w))
    rgb = np.stack([v, v * 0.97, v * 0.93], -1)
    return np.concatenate([np.clip(rgb, 0, 1), np.ones((h, w, 1))], -1)


def palm_trunk(w, h):
    """rows of overlapping leaf-base scars (the ringed / scaly date-palm trunk), tiles in v every 1/8"""
    x = np.arange(w)[None, :] / w
    y = np.arange(h)[:, None] / h
    rows = 16
    t = (y * rows) % 1.0
    odd = np.floor(y * rows) % 2
    u = (x * 6 + odd * 0.5) % 1.0
    scar = np.clip(1.0 - np.abs(u - 0.5) * 2.0 - t * 0.9, 0, 1)
    ring = 0.72 + 0.28 * np.clip(t * 1.6, 0, 1)
    v = ring * (0.92 + 0.12 * scar)
    rgb = np.stack([v * 1.04, v, v * 0.9], -1)
    return np.concatenate([np.clip(rgb, 0, 1), np.ones((h, w, 1))], -1)


def main():
    atlas = np.zeros((N, N, 4))
    atlas[..., :3] = 0.35
    for name, (x, y, w, h) in CELLS.items():
        if name == "bark":
            c = bark(w, h)
        elif name == "palmtrunk":
            c = palm_trunk(w, h)
        else:
            c = card(name, w, h)
        atlas[y:y + h, x:x + w] = c
    Image.fromarray((atlas * 255 + 0.5).astype(np.uint8), "RGBA").save(OUT)
    print("wrote", os.path.normpath(OUT))


if __name__ == "__main__":
    main()
