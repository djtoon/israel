"""Clean + downsize HUD icons: fill accidental alpha holes inside the medallion with navy, crop to content, 128 px."""
import glob, os
import numpy as np
from PIL import Image
from scipy.ndimage import binary_fill_holes, binary_erosion
NAVY = np.array([15, 30, 63], np.float32)
OUT = {"yield": "icons/yield", "action": "icons/action", "res": "icons/resource"}
for f in sorted(glob.glob("_pipeline/raw/*.png")):
    i = os.path.basename(f)[:-4]
    pre = i.split("_")[0]
    if pre not in OUT: continue
    a = np.asarray(Image.open(f).convert("RGBA"), np.float32)
    solid = a[..., 3] > 128
    filled = binary_fill_holes(solid)
    holes = filled & ~solid
    al = a[..., 3:4] / 255.0
    rgb = a[..., :3] * al + NAVY * (1 - al)
    a[..., :3] = np.where(filled[..., None], rgb, a[..., :3])
    a[..., 3] = np.where(filled, 255, a[..., 3])
    # kill pale halos: light, partly transparent pixels more than 3 px outside the solid badge
    from scipy.ndimage import binary_dilation
    near = binary_dilation(filled, iterations=3)
    lum = a[..., :3] @ np.array([0.3, 0.59, 0.11])
    halo = (~near) & (lum > 150)
    a[..., 3] = np.where(halo | (~binary_dilation(filled, iterations=12)), 0, a[..., 3])
    ys, xs = np.nonzero(a[..., 3] > 8)
    cy, cx = (ys.min() + ys.max()) / 2, (xs.min() + xs.max()) / 2
    half = max(ys.max() - ys.min(), xs.max() - xs.min()) / 2 + 6
    im = Image.fromarray(a.astype(np.uint8)).crop((int(cx - half), int(cy - half), int(cx + half), int(cy + half)))
    os.makedirs(OUT[pre], exist_ok=True)
    im.resize((128, 128), Image.LANCZOS).save(f"{OUT[pre]}/{i}.png")
    print(i, "holes filled:", int(holes.sum()))
