"""darkcheck.py a.glb [b.glb ...] -> fraction of surface area whose baked texture is near-black (failed bake)."""
import sys, numpy as np, trimesh
for f in [a for a in sys.argv[1:] if not a.startswith("--")]:
    try:
        m = trimesh.load(f, force="mesh")
        img = np.asarray(m.visual.material.baseColorTexture.convert("RGB"), np.float32)
        uv = m.visual.uv[m.faces].mean(1)
        H, W = img.shape[:2]
        px = img[np.clip(((uv[:, 1] if "--noflip" in sys.argv else 1 - uv[:, 1]) * H).astype(int), 0, H - 1), np.clip((uv[:, 0] * W).astype(int), 0, W - 1)]
        lum = px @ [0.3, 0.59, 0.11]
        a = m.area_faces
        print(f"{f}: dark {float(a[lum < 30].sum() / a.sum()):.3f}  mean lum {float((lum * a).sum() / a.sum()):.0f}")
    except Exception as e:
        print(f, "ERR", e)
