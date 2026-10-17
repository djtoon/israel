"""Find the top of a tile model's hex slab and optionally cut the slab away.

  python strip_plinth.py normalised.glb [out_noplinth.glb]

Prints JSON {"ground_y": <slab top height in model units>, ...}. The slab top is the height band (in the lower 35%
of the model) holding the largest area of upward-facing triangles. With an output path, every triangle lying
entirely at or below ground_y (+1% of height) is removed, i.e. the plinth sides and the slab's own ground cover go,
buildings/trees/props stay; the result is shifted down so its new ground line is y = 0.
"""
import json, sys
import numpy as np
import trimesh


def main():
    src = sys.argv[1]
    m = trimesh.load(src, force="mesh", process=False)
    v, f = m.vertices, m.faces
    h = v[:, 1].max() - v[:, 1].min()
    y0 = v[:, 1].min()
    cy = v[f][:, :, 1].mean(1)
    up = m.face_normals[:, 1] > 0.85
    area = m.area_faces
    sel = up & (cy < y0 + 0.35 * h)
    bins = np.linspace(y0, y0 + 0.35 * h, 71)
    hist, _ = np.histogram(cy[sel], bins=bins, weights=area[sel])
    # the slab top is the highest strong peak (inverted bottom faces can also show up as "up" at y0),
    # extended upward over the contiguous ground relief (paving, lawns)
    tot = hist.sum()
    k = int(np.nonzero(hist >= 0.4 * hist.max())[0].max())
    while k + 1 < len(hist) and hist[k + 1] >= 0.05 * tot:
        k += 1
    ground = float(bins[k + 1])
    # covered fraction of the footprint at that level, to judge whether it is really a slab
    foot = (v[:, 0].max() - v[:, 0].min()) * (v[:, 2].max() - v[:, 2].min())
    info = {"ground_y": round(ground - y0, 4), "slab_area_frac": round(float(hist[k] / foot), 3)}
    if len(sys.argv) > 2:
        cut = ground + 0.01 * h
        keep = ~(v[f][:, :, 1].max(1) <= cut)
        m.update_faces(keep)
        m.remove_unreferenced_vertices()
        m.apply_translation([0, -(m.vertices[:, 1].min()), 0])
        mat = getattr(m.visual, "material", None)
        if mat is not None and hasattr(mat, "metallicFactor"):
            mat.metallicFactor = 0.0
            mat.roughnessFactor = 0.85
            mat.doubleSided = True
        m.export(sys.argv[2], include_normals=False)
        info.update(faces_kept=int(keep.sum()), faces_removed=int((~keep).sum()),
                    height=round(float(m.vertices[:, 1].max()), 3))
    print(json.dumps(info))


if __name__ == "__main__":
    main()
