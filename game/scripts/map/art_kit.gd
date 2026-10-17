class_name ArtKit
extends RefCounted
## Art-builder metre-scale models (assets/MANIFEST.json kind "building"/"bld_*", "jer_wall_*", ...) prepared
## for MultiMesh instancing: each GLB is flattened to one ArrayMesh per surface, decimated with
## meshoptimizer (ImporterMesh LODs) to a few thousand triangles, and given a per-instance tinted material.

const TARGET_TRIS := 1000
static var _cache := {}      # id -> Array of {mesh: ArrayMesh, mat: Material, xf: Transform3D} or [] if unusable
static var _shader: Shader


static func get_parts(id: String) -> Array:
	if _cache.has(id):
		return _cache[id]
	var parts := []
	_cache[id] = parts
	var a: Dictionary = CityBuilder.manifest().get(id, {})
	if a.is_empty():
		return parts
	var path := "res://assets/" + str(a["file"])
	if not ResourceLoader.exists(path):
		return parts
	if _shader == null:
		_shader = load("res://scripts/map/artinst.gdshader")
	var t0 := Time.get_ticks_msec()
	var ps := load(path) as PackedScene
	if ps == null:
		return parts
	var root: Node3D = ps.instantiate()
	for mi in root.find_children("*", "MeshInstance3D", true, false):
		var m := mi as MeshInstance3D
		var xf := Transform3D.IDENTITY
		var node: Node = m
		while node and node != root:
			if node is Node3D:
				xf = (node as Node3D).transform * xf
			node = node.get_parent()
		for si in m.mesh.get_surface_count():
			var arrays := m.mesh.surface_get_arrays(si)
			var src := m.get_active_material(si)
			var mesh := _decimate(arrays)
			var mat := ShaderMaterial.new()
			mat.shader = _shader
			if src is BaseMaterial3D:
				mat.set_shader_parameter("albedo_tex", (src as BaseMaterial3D).albedo_texture)
				mat.set_shader_parameter("albedo_col", (src as BaseMaterial3D).albedo_color)
			if id.begins_with("shore_"):
				mat.set_shader_parameter("is_shore", 1.0)   # HD effects: no city grime on shore rocks
			if id.begins_with("veg_"):
				mat.set_shader_parameter("is_veg", 1.0)   # HD effects: foliage wind and translucency (artinst.gdshader)
			parts.append({"mesh": mesh, "mat": mat, "xf": xf})
	root.free()
	print("artkit: %s ready in %d ms" % [id, Time.get_ticks_msec() - t0])
	return parts


static func _decimate(arrays: Array) -> ArrayMesh:
	var idx: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
	var out := ArrayMesh.new()
	if idx.size() / 3 > TARGET_TRIS:
		var im := ImporterMesh.new()
		im.add_surface(Mesh.PRIMITIVE_TRIANGLES, arrays)
		im.generate_lods(25.0, 60.0, [])
		var best := idx
		for l in im.get_surface_lod_count(0):
			var li := im.get_surface_lod_indices(0, l)
			best = li
			if li.size() / 3 <= TARGET_TRIS:
				break
		arrays[Mesh.ARRAY_INDEX] = best
	out.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return out
