"""Remove flat upward-facing 'ground card' faces at the very bottom of a no-base model (white background leaks).
  python strip_groundcard.py in.glb out.glb   -> prints {"removed": n}"""
import json, sys
import trimesh
m = trimesh.load(sys.argv[1], force="mesh", process=False)
v, f = m.vertices, m.faces
h = v[:, 1].max() - v[:, 1].min()
low = v[f][:, :, 1].max(1) <= v[:, 1].min() + 0.012 * h
flat_up = m.face_normals[:, 1] > 0.9
bad = low & flat_up
if bad.any():
    m.update_faces(~bad)
    m.remove_unreferenced_vertices()
mat = getattr(m.visual, "material", None)
if mat is not None and hasattr(mat, "metallicFactor"):
    mat.metallicFactor = 0.0; mat.roughnessFactor = 0.85; mat.doubleSided = True
m.export(sys.argv[2], include_normals=False)
print(json.dumps({"removed": int(bad.sum())}))
