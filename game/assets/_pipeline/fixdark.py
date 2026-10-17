"""fixdark.py in.glb out.glb [thresh]  -> repaint near-black texels of the baked texture from the nearest good texel."""
import sys, io, numpy as np
from PIL import Image
from scipy.ndimage import distance_transform_edt
from pygltflib import GLTF2
g = GLTF2().load(sys.argv[1]); th = float(sys.argv[3]) if len(sys.argv) > 3 else 28
blob = bytearray(g.binary_blob())
bv = g.bufferViews[g.images[0].bufferView]
im = np.asarray(Image.open(io.BytesIO(bytes(blob[bv.byteOffset:bv.byteOffset + bv.byteLength]))).convert("RGB"))
lum = im @ np.array([0.3, 0.59, 0.11])
bad = lum < th
_, (iy, ix) = distance_transform_edt(bad, return_indices=True)
fixed = im[iy, ix]
buf = io.BytesIO(); Image.fromarray(fixed.astype(np.uint8)).save(buf, "PNG"); data = buf.getvalue()
# append new image data to the end of the buffer and repoint the bufferView
pad = (-len(blob)) % 4
blob += b"\0" * pad
bv.byteOffset = len(blob); bv.byteLength = len(data)
blob += data
g.buffers[0].byteLength = len(blob)
g.set_binary_blob(bytes(blob))
g.images[0].mimeType = "image/png"
g.save(sys.argv[2])
print(f"repainted {bad.mean():.3f} of texels")
