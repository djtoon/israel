"""relight_back.py in.glb out.glb [--lo 70]

TRELLIS bakes the side of an object it could not see in the source image too dark and too blue. This remaps dark
texels onto the colour statistics of the well-lit texels (Reinhard-style mean/std transfer per channel), blended in
smoothly below luminance --lo, so facade detail (windows, balconies) is kept but the back reads like the front.
Only texels actually used by the mesh UVs are measured. Prints {"relit": fraction of used texels changed}.
"""
import argparse, io, json
import numpy as np
from PIL import Image, ImageDraw
from pygltflib import GLTF2
import trimesh


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("inp"); ap.add_argument("out")
    ap.add_argument("--lo", type=float, default=70.0)
    a = ap.parse_args()
    g = GLTF2().load(a.inp)
    blob = bytearray(g.binary_blob())
    bv = g.bufferViews[g.images[g.textures[g.materials[0].pbrMetallicRoughness.baseColorTexture.index].source].bufferView]
    im = np.asarray(Image.open(io.BytesIO(bytes(blob[bv.byteOffset:bv.byteOffset + bv.byteLength]))).convert("RGB"),
                    np.float32)
    H, W = im.shape[:2]
    # mask of texels covered by UV triangles
    m = trimesh.load(a.inp, force="mesh", process=False)
    uv = m.visual.uv[m.faces]
    mask_img = Image.new("L", (W, H), 0)
    d = ImageDraw.Draw(mask_img)
    for tri in uv:
        d.polygon([(float(u * W), float((1 - v) * H)) for u, v in tri], fill=255)
    used = np.asarray(mask_img) > 0
    lum = im @ np.array([0.3, 0.59, 0.11], np.float32)
    good = used & (lum >= a.lo)
    dark = used & (lum < a.lo * 0.75)
    if good.sum() < 100 or dark.sum() < 100:
        g.save(a.out); print(json.dumps({"relit": 0.0})); return
    mg, sg = im[good].mean(0), im[good].std(0) + 1e-3
    md, sd = im[dark].mean(0), im[dark].std(0) + 1e-3
    gain = np.clip(sg / sd, 0.5, 2.5)
    mapped = (im - md) * gain + mg
    w = np.clip((a.lo - lum) / (a.lo * 0.5), 0, 1)[..., None] * used[..., None]
    outim = np.clip(im * (1 - w) + mapped * w, 0, 255).astype(np.uint8)
    buf = io.BytesIO(); Image.fromarray(outim).save(buf, "PNG"); data = buf.getvalue()
    blob += b"\0" * ((-len(blob)) % 4)
    bv.byteOffset = len(blob); bv.byteLength = len(data)
    blob += data
    g.buffers[0].byteLength = len(blob)
    g.set_binary_blob(bytes(blob))
    for img in g.images:
        if img.bufferView is not None and g.bufferViews[img.bufferView] is bv:
            img.mimeType = "image/png"
    g.save(a.out)
    print(json.dumps({"relit": round(float((w[..., 0] > 0.05).sum() / used.sum()), 3)}))


if __name__ == "__main__":
    main()
