"""add_normals.py in.glb out.glb [--angle DEG]

TRELLIS/Hunyuan GLBs carry no NORMAL attribute and Godot 4.7 then shades every vertex with a constant +Z normal: the
model is lit only when its +Z side faces the sun and goes uniformly dark when rotated. This bakes the node transform
and writes crease-aware smooth normals (corners at the same position share their normal only with faces whose normal
is within --angle, default 40 deg), so buildings keep crisp edges and are lit correctly from any yaw.
Pure numpy (no per-component submeshes), so memory stays small. Material forced non-metallic, double-sided.
"""
import argparse, json
import numpy as np
import trimesh
from trimesh.visual import TextureVisuals


def crease_normals(V, F, angle_deg):
    tri = V[F]                                          # (f,3,3)
    fn = np.cross(tri[:, 1] - tri[:, 0], tri[:, 2] - tri[:, 0])
    area2 = np.linalg.norm(fn, axis=1) + 1e-20
    fu = fn / area2[:, None]
    corners = F.reshape(-1)                             # corner -> vertex
    cface = np.repeat(np.arange(len(F)), 3)
    # group corners by quantised position (welds seams that differ only in uv)
    q = np.round(V[corners] / (np.ptp(V, 0).max() * 1e-5 + 1e-12)).astype(np.int64)
    _, gid = np.unique(q, axis=0, return_inverse=True)
    gid = gid.reshape(-1)
    order = np.argsort(gid, kind="stable")
    gs = gid[order]
    starts = np.r_[0, np.nonzero(np.diff(gs))[0] + 1]
    sizes = np.diff(np.r_[starts, len(gs)])
    cosT = np.cos(np.radians(angle_deg))
    out = fn[cface].copy()                              # area-weighted own face normal
    # pair corners within each group (groups are small); process by group size to stay vectorised
    for s in np.unique(sizes):
        if s == 1:
            continue
        st = starts[sizes == s]
        idx = order[st[:, None] + np.arange(s)[None, :]]  # (g, s) corner ids
        fi = cface[idx]                                    # (g, s)
        u = fu[fi]                                         # (g, s, 3)
        w = fn[fi]                                         # (g, s, 3)
        dots = np.einsum("gid,gjd->gij", u, u)             # (g, s, s)
        mask = (dots >= cosT).astype(np.float64)
        acc = np.einsum("gij,gjd->gid", mask, w)           # (g, s, 3)
        out[idx.reshape(-1)] = acc.reshape(-1, 3)
    out /= np.linalg.norm(out, axis=1, keepdims=True) + 1e-20
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("inp"); ap.add_argument("out")
    ap.add_argument("--angle", type=float, default=40.0)
    a = ap.parse_args()
    m = trimesh.load(a.inp, force="mesh", process=False)
    V, F = np.asarray(m.vertices, np.float64), np.asarray(m.faces, np.int64)
    uv = np.asarray(m.visual.uv) if hasattr(m.visual, "uv") and m.visual.uv is not None else None
    N = crease_normals(V, F, a.angle)
    # unmerged corners -> dedupe identical (vertex, normal) pairs
    corners = F.reshape(-1)
    key = np.c_[corners, np.round(N * 1000).astype(np.int64)]
    uk, first, inv = np.unique(key, axis=0, return_index=True, return_inverse=True)
    newV = V[corners[first]]
    newN = N[first]
    newF = inv.reshape(-1, 3)
    mat = getattr(m.visual, "material", None)
    if mat is not None and hasattr(mat, "metallicFactor"):
        mat.metallicFactor = 0.0
        mat.roughnessFactor = 0.85
        mat.doubleSided = True
    vis = TextureVisuals(uv=uv[corners[first]], material=mat) if uv is not None else None
    out = trimesh.Trimesh(vertices=newV, faces=newF, vertex_normals=newN, visual=vis, process=False)
    out.export(a.out, include_normals=True)
    print(json.dumps({"faces": int(len(F)), "verts": int(len(newV)), "angle": a.angle}))


if __name__ == "__main__":
    main()
