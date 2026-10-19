"""Blender (background) batch decimation for the web build's models.
   blender -b --factory-startup -P blender_decimate.py -- jobs.json
jobs.json: [{"in": src.glb, "out": dst.glb, "tris": target}]. Each model is imported with its vertices welded by
position (the generated models are cut along their texture seams; welded, they simplify freely while the UV seams are
kept as loop data), decimated (collapse) to about the target triangle count, smooth-shaded by angle and exported as GLB
with the same texture. Hierarchy, transforms and materials come back as they went in (the game finds every
MeshInstance3D under the scene root and accumulates its transforms)."""
import bpy, sys, json, math, os, time

jobs = json.load(open(sys.argv[sys.argv.index("--") + 1], encoding="utf-8"))


def tri_count(objs):
    n = 0
    for o in objs:
        if o.type == "MESH":
            for p in o.data.polygons:
                n += len(p.vertices) - 2
    return n


for j in jobs:
    t0 = time.time()
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=j["in"], merge_vertices=True, import_shading="NORMALS")
    meshes = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    before = tri_count(meshes)
    ratio = min(1.0, float(j["tris"]) / max(1, before))
    for o in meshes:
        bpy.context.view_layer.objects.active = o
        for s in bpy.context.view_layer.objects.selected:
            s.select_set(False)
        o.select_set(True)
        # weld by position (merge by distance): the seams stay as UV loop data
        bpy.ops.object.mode_set(mode="EDIT")
        bpy.ops.mesh.select_all(action="SELECT")
        bpy.ops.mesh.remove_doubles(threshold=float(j.get("weld", 0.0005)) * max(o.dimensions))
        bpy.ops.object.mode_set(mode="OBJECT")
        want = tri_count([o]) * ratio
        for _pass in range(3):   # collapse lands above the asked share on these meshes: refine up to twice
            have = tri_count([o])
            r = want / max(1, have)
            if r >= 0.9:
                break
            m = o.modifiers.new("web_decimate", "DECIMATE")
            m.decimate_type = "COLLAPSE"
            m.ratio = r
            m.use_collapse_triangulate = True
            bpy.ops.object.modifier_apply(modifier=m.name)
        # fresh normals: smooth, split at hard edges (the decimated surface no longer matches the custom normals)
        try:
            bpy.ops.mesh.customdata_custom_splitnormals_clear()
        except Exception:
            pass
        try:
            bpy.ops.object.shade_auto_smooth(angle=math.radians(40.0))
        except Exception:
            bpy.ops.object.shade_smooth()
    after = tri_count(meshes)
    os.makedirs(os.path.dirname(j["out"]), exist_ok=True)
    mesh_only = bool(j.get("mesh_only", False))   # (the web far LODs: geometry only, the near model's material is used)
    bpy.ops.export_scene.gltf(filepath=j["out"], export_format="GLB", export_apply=True, export_yup=True,
                              export_image_format="NONE" if mesh_only else "AUTO",
                              export_materials="NONE" if mesh_only else "EXPORT", export_normals=True, export_tangents=False,
                              export_animations=False, export_skins=False, export_morph=False,
                              export_cameras=False, export_lights=False, export_extras=False)
    print("WEBDEC %s %d -> %d tris (%.1f s)" % (os.path.basename(j["in"]), before, after, time.time() - t0), flush=True)
