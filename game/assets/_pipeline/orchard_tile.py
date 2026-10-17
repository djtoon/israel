"""Orchard rows: crop to whole tree cells (borders run through bare earth) then overlap-crossfade the wrap."""
import numpy as np, sys
from PIL import Image
raw, out, prev, box = sys.argv[1], sys.argv[2], sys.argv[3], [int(v) for v in sys.argv[4].split(",")]
a = np.asarray(Image.open(raw).convert("RGB"), np.float32)[box[1]:box[3], box[0]:box[2]]
b = 48
def wrap(a, axis):
    a = np.moveaxis(a, axis, 0)
    n = a.shape[0]
    t = np.linspace(0, 1, b)[:, None, None]
    head = a[n - b:] * (1 - t) + a[:b] * t
    res = np.concatenate([head, a[b:n - b]], 0)
    return np.moveaxis(res, 0, axis)
a = wrap(wrap(a, 0), 1)
im = Image.fromarray(np.clip(a, 0, 255).astype(np.uint8)).resize((1024, 1024), Image.LANCZOS)
im.save(out)
p = Image.new("RGB", (2048, 2048))
for i in range(2):
    for j in range(2): p.paste(im, (i * 1024, j * 1024))
p.resize((1024, 1024), Image.LANCZOS).save(prev)
