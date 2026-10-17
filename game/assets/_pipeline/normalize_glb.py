"""Normalise a Hunyuan GLB for the game without touching mesh data.

  python normalize_glb.py in.glb out.glb --kind tile|prop|unit --size S [--yaw DEG] [--report]

Adds one root node (translation/rotation/scale) above the existing scene roots so that:
  * +Y is up, the lowest point sits at y = 0, the footprint is centred on the origin;
  * 1.0 world unit = one hex measured flat-to-flat (the convention for every model in MANIFEST.json);
  * tile: the hexagonal base slab is rotated to pointy-top (corners on +-Z) and scaled to exactly 1.0
    flat-to-flat; prop/unit: the larger horizontal extent is scaled to S (fraction of a hex).
Prints a JSON line with the resulting bounds.
"""
import argparse, json, math, sys
import numpy as np
import pygltflib
from pygltflib import GLTF2, Node

COMP = {5126: np.float32, 5123: np.uint16, 5125: np.uint32, 5121: np.uint8}


def node_matrix(n):
    if n.matrix:
        return np.array(n.matrix, dtype=np.float64).reshape(4, 4).T
    T = np.eye(4); R = np.eye(4); S = np.eye(4)
    if n.translation: T[:3, 3] = n.translation
    if n.rotation:
        x, y, z, w = n.rotation
        R[:3, :3] = [[1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w)],
                     [2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w)],
                     [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y)]]
    if n.scale: S[0, 0], S[1, 1], S[2, 2] = n.scale
    return T @ R @ S


def read_accessor(g, blob, idx):
    a = g.accessors[idx]
    bv = g.bufferViews[a.bufferView]
    n = {"SCALAR": 1, "VEC2": 2, "VEC3": 3, "VEC4": 4}[a.type]
    dt = COMP[a.componentType]
    off = (bv.byteOffset or 0) + (a.byteOffset or 0)
    stride = bv.byteStride or n * np.dtype(dt).itemsize
    raw = np.frombuffer(blob, dtype=np.uint8, count=stride * (a.count - 1) + n * np.dtype(dt).itemsize, offset=off)
    if stride == n * np.dtype(dt).itemsize:
        return raw.view(dt).reshape(a.count, n).astype(np.float64)
    return np.stack([np.frombuffer(raw[i * stride:i * stride + n * np.dtype(dt).itemsize].tobytes(), dt)
                     for i in range(a.count)]).astype(np.float64)


def world_points(g):
    blob = g.binary_blob()
    pts = []

    def walk(ni, M):
        n = g.nodes[ni]
        M = M @ node_matrix(n)
        if n.mesh is not None:
            for p in g.meshes[n.mesh].primitives:
                v = read_accessor(g, blob, p.attributes.POSITION)
                v = (M @ np.c_[v, np.ones(len(v))].T).T[:, :3]
                pts.append(v)
        for c in n.children or []:
            walk(c, M)

    for r in g.scenes[g.scene or 0].nodes:
        walk(r, np.eye(4))
    return np.concatenate(pts)


def hex_fit(xz):
    """Best-fit pointy-top hexagon around the base outline.
    Tries every rotation (0..60 deg); for each, the enclosing hexagon with edge normals n_k is found and its
    inradius measured; the rotation with the smallest enclosing hexagon wins. Returns (yaw_deg, inradius, centre)."""
    from scipy.spatial import ConvexHull
    pts = xz[ConvexHull(xz).vertices]
    best = None
    for deg in np.arange(0, 60, 0.5):
        # pointy-top (corners on +-Z) has edge normals at 0, 60, 120 deg from +X; we rotate the points by -deg
        t = math.radians(deg)
        c, s_ = math.cos(t), math.sin(t)
        P = pts @ np.array([[c, s_], [-s_, c]])  # rotate points by +deg in x->z sense
        N = np.array([[math.cos(math.radians(a)), math.sin(math.radians(a))] for a in (0, 60, 120)])
        proj = P @ N.T  # (n,3)
        mid = (proj.max(0) + proj.min(0)) / 2
        half = (proj.max(0) - proj.min(0)) / 2
        ctr, *_ = np.linalg.lstsq(N, mid, rcond=None)
        r = np.max(np.abs(P @ N.T - ctr @ N.T))
        if best is None or r < best[1]:
            best = (deg, r, ctr, float(half.std() / half.mean()))
    deg, r, ctr, irregular = best
    t = math.radians(deg)
    c, s_ = math.cos(t), math.sin(t)
    centre = ctr @ np.array([[c, s_], [-s_, c]]).T  # back to original frame
    return deg, r, centre, irregular


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("inp"); ap.add_argument("out")
    ap.add_argument("--kind", required=True, choices=["tile", "prop", "unit"])
    ap.add_argument("--size", type=float, default=1.0)
    ap.add_argument("--by", default="extent", choices=["extent", "height", "mean"], help="prop/unit: size measures max horizontal extent or height")
    ap.add_argument("--hsize", type=float, default=0.0, help="--by mean: target height (size = target extent)")
    ap.add_argument("--fit3", type=float, nargs=3, default=None, metavar=("W", "D", "H"),
                    help="non-uniform fit to real width (X), depth (Z), height (Y), each axis within --clamp of the mean")
    ap.add_argument("--clamp", type=float, default=1.6)
    ap.add_argument("--face", default="none", choices=["none", "fixed", "long", "box", "boxx"],
                    help="unit/prop facing: the source images show objects facing front-left, i.e. (-X,+Z) in the raw "
                         "model. fixed: turn that direction to +Z; long: use the footprint's long axis (vehicles), "
                         "signed towards (-X,+Z), and turn it to +Z")
    ap.add_argument("--yaw", type=float, default=0.0, help="extra yaw (deg) applied after alignment")
    a = ap.parse_args()

    g = GLTF2().load(a.inp)
    P = world_points(g)
    Praw = P
    ymin, ymax = P[:, 1].min(), P[:, 1].max()
    info = {}
    if a.kind == "tile":
        h = ymax - ymin
        base = P[P[:, 1] < ymin + 0.08 * h]
        yaw, inr, c, irregular = hex_fit(base[:, [0, 2]])
        scale = 0.5 / inr  # inradius -> 0.5, i.e. flat-to-flat 1.0
        cx, cz = c
        info.update(hex_irregularity=round(irregular, 3))
    else:
        pre = 0.0
        if a.face in ("box", "boxx"):
            # buildings: turn the minimum-area footprint rectangle onto the X/Z axes with the smallest turn
            xz = P[:, [0, 2]]
            best = None
            for deg in np.arange(0, 90, 0.5):
                t_ = math.radians(deg); c_, s_ = math.cos(t_), math.sin(t_)
                Q = xz @ np.array([[c_, s_], [-s_, c_]])
                ar = np.ptp(Q[:, 0]) * np.ptp(Q[:, 1])
                if best is None or ar < best[1]:
                    best = (deg, ar, np.ptp(Q[:, 0]), np.ptp(Q[:, 1]))
            if a.face == "boxx":  # modular segments: long side along X
                pre = best[0] + (90.0 if best[3] > best[2] else 0.0)
            else:
                pre = best[0] if best[0] <= 45.0 else best[0] - 90.0  # smallest turn: keep the raw front (+Z) facing +Z
            t_ = math.radians(pre); c_, s_ = math.cos(t_), math.sin(t_)
            Q = xz @ np.array([[c_, s_], [-s_, c_]])
            P = P.copy(); P[:, 0], P[:, 2] = Q[:, 0], Q[:, 1]
        cx = (P[:, 0].min() + P[:, 0].max()) / 2
        cz = (P[:, 2].min() + P[:, 2].max()) / 2
        ext = max(P[:, 0].max() - P[:, 0].min(), P[:, 2].max() - P[:, 2].min())
        if a.by == "mean":  # compromise between real length and real height for stylised proportions
            scale = math.sqrt((a.size / ext) * (a.hsize / (ymax - ymin)))
        else:
            scale = a.size / (ext if a.by == "extent" else (ymax - ymin))
        yaw = pre
        if pre:
            cx, cz = np.array([cx, cz]) @ np.array([[c_, s_], [-s_, c_]]).T  # centre back to the raw frame
        f = np.array([-1.0, 1.0]) / math.sqrt(2)
        if a.face == "long":
            xz = P[:, [0, 2]] - P[:, [0, 2]].mean(0)
            w, v = np.linalg.eigh(np.cov(xz.T))
            ax = v[:, np.argmax(w)]
            f = ax if ax @ f >= 0 else -ax
            info["long_axis_ratio"] = round(float(math.sqrt(w.max() / max(w.min(), 1e-9))), 2)
        if a.face not in ("none", "box", "boxx"):
            phi = math.degrees(math.atan2(f[1], f[0]))
            yaw = 90.0 - phi  # rotation in the x->z sense brings f onto +Z
    yaw += a.yaw
    # glTF rotation about +Y by angle t maps x->z by -t (right-handed, Y up: (x,z) -> (x cos t + z sin t, -x sin t + z cos t))
    # We computed 'yaw' as a rotation x->z, i.e. t = -yaw.
    t = math.radians(-yaw)
    q = [0.0, math.sin(t / 2), 0.0, math.cos(t / 2)]
    # root transform: S * R * T(-c)
    Tm = np.eye(4); Tm[:3, 3] = [-cx, -ymin, -cz]
    Rm = node_matrix(Node(rotation=q))
    Sm = np.eye(4) * scale; Sm[3, 3] = 1
    if a.fit3 and a.kind != "tile":
        # measure extents in the aligned frame (P was rotated for box/boxx)
        ex = [np.ptp(P[:, 0]), ymax - ymin, np.ptp(P[:, 2])]
        want = [a.fit3[0], a.fit3[2], a.fit3[1]]
        s3 = np.array([w / e for w, e in zip(want, ex)])
        gm = float(np.prod(s3) ** (1 / 3))
        s3 = np.clip(s3, gm / a.clamp, gm * a.clamp)
        Sm = np.diag([s3[0], s3[1], s3[2], 1.0])
        info["fit3_scale"] = [round(float(v), 4) for v in s3]
    M = Sm @ Rm @ Tm
    roots = list(g.scenes[g.scene or 0].nodes)
    root = Node(name="norm_root", matrix=[float(x) for x in M.T.flatten()], children=roots)
    g.nodes.append(root)
    g.scenes[g.scene or 0].nodes = [len(g.nodes) - 1]
    # glTF defaults metallicFactor to 1.0 when absent; the generators omit it, which renders black in Godot.
    for m in g.materials:
        pbr = m.pbrMetallicRoughness
        if pbr is None:
            m.pbrMetallicRoughness = pbr = pygltflib.PbrMetallicRoughness()
        if pbr.metallicRoughnessTexture is None:
            pbr.metallicFactor = 0.0
            pbr.roughnessFactor = 0.85
        m.doubleSided = True
    g.save(a.out)
    Q = (M @ np.c_[Praw, np.ones(len(Praw))].T).T[:, :3]
    info.update(kind=a.kind, scale=round(float(scale), 5), yaw=round(yaw, 1),
                bounds_min=[round(float(v), 3) for v in Q.min(0)], bounds_max=[round(float(v), 3) for v in Q.max(0)],
                height=round(float(Q[:, 1].max()), 3), verts=int(len(P)))
    print(json.dumps(info))


if __name__ == "__main__":
    main()
