"""Make a terrain texture seamlessly tileable and write a 2x2 preview.

  python tileable.py raw.png out.png preview.png [--period]

Method: offset the image by half (so its seams meet in a cross at the centre), then paint the original
(seam-free) centre back over that cross through a soft, noise-modulated mask. Everything that touches the
image border comes from the offset copy, so opposite borders match exactly. --period first crops the raw
image to a whole number of periods (for orchard rows) found by autocorrelation.
"""
import sys
import numpy as np
from PIL import Image, ImageFilter


def period_crop(a):
    g = a.mean(axis=2)
    out = a
    for axis in (0, 1):
        prof = g.mean(axis=1 - axis)
        prof = prof - prof.mean()
        n = len(prof)
        ac = np.correlate(prof, prof, "full")[n - 1:]
        ac /= ac[0]
        # first strong peak after the first zero crossing
        z = np.argmax(ac < 0)
        p = z + int(np.argmax(ac[z:n // 2]))
        k = n // p
        L = k * p
        print(f"axis {axis}: period {p}px, keeping {k} periods = {L}px")
        if axis == 0:
            out = out[:L]
        else:
            out = out[:, :L]
    return out


def make_tileable(a, seed=1):
    h, w = a.shape[:2]
    off = np.roll(np.roll(a, h // 2, 0), w // 2, 1)
    yy, xx = np.mgrid[0:h, 0:w]
    # distance to the nearest border, normalised 0 (edge) .. 1 (centre)
    d = np.minimum(np.minimum(xx, w - 1 - xx) / (w / 2), np.minimum(yy, h - 1 - yy) / (h / 2))
    rng = np.random.default_rng(seed)
    noise = Image.fromarray((rng.random((h // 16, w // 16)) * 255).astype(np.uint8)).resize((w, h), Image.BICUBIC)
    noise = np.asarray(noise.filter(ImageFilter.GaussianBlur(8)), np.float32) / 255.0 - 0.5
    t = d + 0.35 * noise
    m = np.clip((t - 0.22) / 0.16, 0, 1)
    m = m * m * (3 - 2 * m)
    return (a * m[..., None] + off * (1 - m[..., None])).astype(np.float32)


def main():
    raw, out, prev = sys.argv[1:4]
    a = np.asarray(Image.open(raw).convert("RGB"), np.float32)
    if "--period" in sys.argv:
        a = period_crop(a)
        a = np.asarray(Image.fromarray(a.astype(np.uint8)).resize((1024, 1024), Image.LANCZOS), np.float32)
    t = make_tileable(a)
    im = Image.fromarray(np.clip(t, 0, 255).astype(np.uint8)).resize((1024, 1024), Image.LANCZOS)
    im.save(out)
    p = Image.new("RGB", (2048, 2048))
    for i in range(2):
        for j in range(2):
            p.paste(im, (i * 1024, j * 1024))
    p.resize((1024, 1024), Image.LANCZOS).save(prev)
    # seam check: mean abs diff across the wrap vs. across an interior column
    b = np.asarray(im, np.float32)
    wrap = np.abs(b[:, 0] - b[:, -1]).mean() + np.abs(b[0] - b[-1]).mean()
    inner = np.abs(b[:, 511] - b[:, 512]).mean() + np.abs(b[511] - b[512]).mean()
    print(f"{out}: wrap-diff {wrap:.1f} vs interior {inner:.1f}")


if __name__ == "__main__":
    main()
