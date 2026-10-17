"""relight_sides.py in.glb out.glb [--ratio 0.85]

Image-to-3D bakes the sides the source image never showed (usually the back) darker and bluer. Faces are binned by
dominant normal direction (+X, -X, +Z, -Z walls; +Y roof). For every wall bin whose mean luminance is below --ratio x
the best wall's, the texels belonging to that bin get a per-channel mean/std colour transfer onto the best wall's
statistics, so backs match fronts in brightness and hue while keeping their own detail.
Prints {"sides_fixed": [...], "lum": {bin: before}}.
"""
import argparse, io, json
import numpy as np
from PIL import Image, ImageDraw
from pygltflib import GLTF2
import trimesh

BINS = {"+X": (0, 1), "-X": (0, -1), "+Z": (2, 1), "-Z": (2, -1)}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("inp"); ap.add_argument("out")
    ap.add_argument("--ratio", type=float, default=0.85)
    a = ap.parse_args()
    g = GLTF2().load(a.inp)
    blob = bytearray(g.binary_blob())
    tex_i = g.materials[0].pbrMetallicRoughness.baseColorTexture.index
    bv = g.bufferViews[g.images[g.textures[tex_i].source].bufferView]
    im = np.asarray(Image.open(io.BytesIO(bytes(blob[bv.byteOffset:bv.byteOffset + bv.byteLength]))).convert("RGB"),
                    np.float32)
    H, W = im.shape[:2]
    m = trimesh.load(a.inp, force="mesh", process=False)
    n = m.face_normals
    uv = m.visual.uv[m.faces]
    label = Image.new("L", (W, H), 0)
    d = ImageDraw.Draw(label)
    names = ["", "+X", "-X", "+Z", "-Z", "+Y"]
    for fi in range(len(n)):
        nx, ny, nz = n[fi]
        if ny > 0.7:
            lab = 5
        elif ny < -0.7:
            continue
        elif abs(nx) >= abs(nz):
            lab = 1 if nx > 0 else 2
        else:
            lab = 3 if nz > 0 else 4
        d.polygon([(float(u * W), float((1 - v) * H)) for u, v in uv[fi]], fill=lab)
    L = np.asarray(label)
    lum = im @ np.array([0.3, 0.59, 0.11], np.float32)
    stats = {}
    for k in range(1, 6):
        sel = L == k
        if sel.sum() > 500:
            stats[names[k]] = (float(lum[sel].mean()), im[sel].mean(0), im[sel].std(0) + 1e-3, sel)
    walls = {k: v for k, v in stats.items() if k != "+Y"}
    out = im.copy()
    fixed = []
    if walls:
        best = max(walls, key=lambda k: walls[k][0])
        bl, bm, bs, _ = walls[best]
        for k, (l, mu, sd, sel) in walls.items():
            if k != best and l < a.ratio * bl:
                gain = np.clip(bs / sd, 0.6, 2.0)
                out[sel] = (im[sel] - mu) * gain + bm
                fixed.append(k)
    outim = np.clip(out, 0, 255).astype(np.uint8)
    buf = io.BytesIO(); Image.fromarray(outim).save(buf, "PNG"); data = buf.getvalue()
    blob += b"\0" * ((-len(blob)) % 4)
    bv.byteOffset = len(blob); bv.byteLength = len(data)
    blob += data
    g.buffers[0].byteLength = len(blob)
    g.set_binary_blob(bytes(blob))
    g.images[g.textures[tex_i].source].mimeType = "image/png"
    g.save(a.out)
    print(json.dumps({"sides_fixed": fixed, "lum": {k: round(v[0]) for k, v in stats.items()}}))


if __name__ == "__main__":
    main()
