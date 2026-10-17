"""Generates the HD-mode PBR detail maps under game/assets/textures/hd/ from the existing textures.

  python game/scripts/map/hd_gen_maps.py

For each terrain texture: <name>_nrm.png, RGBA = normal.x, normal.y (tangent space, 0.5 = flat), AO (cavity),
roughness; derived from the albedo luminance (blurred height -> Sobel normal, high-pass cavity -> AO).
Plus water_ripple_n.png: a tileable ripple normal map (sum of periodic waves) for the HD water sparkle.
Run `tools/godot.sh --headless --path /c/civ/game --import` afterwards.
"""
import os
import numpy as np
from PIL import Image
from scipy import ndimage

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
SRC = os.path.join(ROOT, "assets", "textures", "terrain")
DST = os.path.join(ROOT, "assets", "textures", "hd")

# name: (normal strength, cavity strength, base roughness)
TERRAIN = {
    "terrain_grassland": (2.2, 2.0, 0.93),
    "terrain_plains": (2.4, 2.2, 0.94),
    "terrain_hills_limestone": (3.0, 2.6, 0.88),
    "terrain_desert_rock": (3.4, 2.8, 0.86),
    "terrain_desert_sand": (1.6, 1.4, 0.95),
    "terrain_marsh": (1.8, 1.6, 0.80),
    "terrain_beach_sand": (1.4, 1.2, 0.92),
    "terrain_pine_forest_floor": (2.6, 2.4, 0.95),
    "terrain_basalt": (3.2, 2.6, 0.84),
}


def wrap_blur(a, s):
    return ndimage.gaussian_filter(a, s, mode="wrap")


def terrain_map(name, strength, cav, rough):
    im = np.asarray(Image.open(os.path.join(SRC, name + ".png")).convert("RGB"), dtype=np.float32) / 255.0
    lum = im @ np.array([0.3, 0.55, 0.15], dtype=np.float32)
    # height: fine detail plus some mid-scale relief (stones and clods read as bumps)
    h = wrap_blur(lum, 0.8) * 0.65 + wrap_blur(lum, 3.0) * 0.35
    gx = ndimage.sobel(h, axis=1, mode="wrap")
    gy = ndimage.sobel(h, axis=0, mode="wrap")
    n = np.stack([-gx * strength, -gy * strength, np.ones_like(h)], axis=-1)
    n /= np.linalg.norm(n, axis=-1, keepdims=True)
    # cavity AO: darker where a pixel sits below its neighbourhood
    hp = wrap_blur(lum, 6.0) - wrap_blur(lum, 1.0)
    ao = np.clip(1.0 - np.maximum(hp, 0.0) * cav * 4.0, 0.45, 1.0)
    ao = wrap_blur(ao, 0.7)
    r = np.clip(rough + (0.5 - lum) * 0.12, 0.6, 1.0)
    out = np.stack([n[..., 0] * 0.5 + 0.5, n[..., 1] * 0.5 + 0.5, ao, r], axis=-1)
    Image.fromarray((np.clip(out, 0, 1) * 255 + 0.5).astype(np.uint8), "RGBA").save(os.path.join(DST, name + "_nrm.png"))


def water_ripple(size=512, seed=7):
    rng = np.random.default_rng(seed)
    y, x = np.mgrid[0:size, 0:size].astype(np.float32) / size
    h = np.zeros((size, size), np.float32)
    # periodic waves with integer wave numbers: tileable; a dominant wind direction plus cross chop
    for i in range(48):
        k = int(rng.integers(3, 28))
        ang = rng.normal(0.35, 0.7)
        kx, ky = int(round(np.cos(ang) * k)), int(round(np.sin(ang) * k))
        if kx == 0 and ky == 0:
            continue
        amp = 1.0 / (np.hypot(kx, ky) ** 1.2)
        ph = rng.uniform(0, 2 * np.pi)
        w = np.sin(2 * np.pi * (kx * x + ky * y) + ph)
        h += amp * (1.0 - np.abs(w)) ** 1.6   # sharp crests
    h = (h - h.min()) / (h.max() - h.min())
    gx = ndimage.sobel(h, axis=1, mode="wrap")
    gy = ndimage.sobel(h, axis=0, mode="wrap")
    s = 6.0
    n = np.stack([-gx * s, -gy * s, np.ones_like(h)], axis=-1)
    n /= np.linalg.norm(n, axis=-1, keepdims=True)
    out = np.stack([n[..., 0] * 0.5 + 0.5, n[..., 1] * 0.5 + 0.5, n[..., 2] * 0.5 + 0.5], axis=-1)
    Image.fromarray((np.clip(out, 0, 1) * 255 + 0.5).astype(np.uint8), "RGB").save(os.path.join(DST, "water_ripple_n.png"))


if __name__ == "__main__":
    os.makedirs(DST, exist_ok=True)
    for k, v in TERRAIN.items():
        terrain_map(k, *v)
        print("hd:", k)
    water_ripple()
    print("hd: water_ripple_n")
