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
	poll_warm()   # perf60: maybe the background warm-up has it ready
	if _cache.has(id):
		return _cache[id]
	var parts := build_parts(id)
	_cache[id] = parts
	return parts


# ---------------------------------------------------------------- perf60: background warm-up
# Preparing a kit model (load, flatten, decimate) takes 30-140 ms the first time it is used, and later eras bring
# new models: a hitch in the middle of a turn's map rebuild. warm() prepares every kit model on a worker thread
# in the background (build_parts touches no shared state); poll_warm() moves the finished ones into the cache on
# the main thread. A model needed before the worker reached it is built at once, as before.
static var _warm_task := -1
static var _warm_done := {}
static var _warm_mutex := Mutex.new()
static var _warm_far := {}
static var far_serial := 0   # perf60: bumps when new far LODs arrive (CityBuilder.upgrade_lods adds them to built chunks)


static func warm(ids: Array) -> void:
	if _warm_task >= 0 or OS.get_name() == "Web" or "--no-warm" in OS.get_cmdline_user_args():
		return
	if _shader == null:
		_shader = load("res://scripts/map/artinst.gdshader")
	var todo: Array = ids.filter(func(i): return not _cache.has(i))
	var first: Array = _cache.keys().filter(func(i): return ids.has(i) and not _far.has(i))
	if todo.is_empty() and first.is_empty():
		return
	_warm_task = WorkerThreadPool.add_task(_warm_run.bind(todo, first), false, "artkit warm-up")
	print("artkit: warming %d kit models and %d far LODs in the background" % [todo.size(), first.size() + todo.size()])


static func _warm_run(ids: Array, far_first: Array) -> void:
	## far LODs of the models already on the map first, then every other model (its parts and its far LOD)
	for id in far_first:
		var f := build_far(id)
		_warm_mutex.lock()
		_warm_far[id] = f
		_warm_mutex.unlock()
	for id in ids:
		_warm_mutex.lock()
		var have: bool = _warm_done.has(id)
		_warm_mutex.unlock()
		if not have:
			var parts := build_parts(id)
			_warm_mutex.lock()
			_warm_done[id] = parts
			_warm_mutex.unlock()
		if not far_first.has(id):
			var f2 := build_far(id)
			_warm_mutex.lock()
			_warm_far[id] = f2
			_warm_mutex.unlock()


static func poll_warm() -> void:
	if _warm_task < 0:
		return
	_warm_mutex.lock()
	for id in _warm_done:
		if not _cache.has(id):
			_cache[id] = _warm_done[id]
	_warm_done.clear()
	if not _warm_far.is_empty():
		for id in _warm_far:
			_far[id] = _warm_far[id]
		_warm_far.clear()
		far_serial += 1
	_warm_mutex.unlock()
	FrameLog.mark("artkit poll")
	if WorkerThreadPool.is_task_completed(_warm_task):
		WorkerThreadPool.wait_for_task_completion(_warm_task)
		_warm_task = -2   # done (never again this run)
		_warm_mutex.lock()
		for id in _warm_done:
			if not _cache.has(id):
				_cache[id] = _warm_done[id]
		_warm_done.clear()
		for id in _warm_far:
			_far[id] = _warm_far[id]
		if not _warm_far.is_empty():
			far_serial += 1
		_warm_far.clear()
		_warm_mutex.unlock()
		print("artkit: warm-up done (%d models, %d with a far LOD)" % [_cache.size(), _far.size()])


static func warm_busy() -> bool:
	return _warm_task >= 0


static func build_parts(id: String) -> Array:
	## the model's MultiMesh parts (pure: reads the manifest and the file, writes nothing shared)
	var parts := []
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
	if GfxTier.web():
		_web_far(id, path, parts.size())
	var tris := 0
	var untex := 0
	for pt in parts:
		var am := pt["mesh"] as ArrayMesh
		for si in am.get_surface_count():
			tris += am.surface_get_array_index_len(si) / 3
		if (pt["mat"] as ShaderMaterial).get_shader_parameter("albedo_tex") == null:
			untex += 1
	print("artkit: %s ready in %d ms (%d triangles%s)" % [id, Time.get_ticks_msec() - t0, tris, ", %d parts WITHOUT a texture" % untex if untex > 0 else ""])
	return parts


const FAR_SHARE := 0.1   # perf60: the far LOD keeps about this share of the near triangles (at least FAR_MIN)
const MID_SHARE := 0.3   # perf60: the mid LOD (shadow casting up close; the mid range in the lighter tiers)
const FAR_MIN := 60
static var _far := {}    # perf60: id -> [far mesh per part (null = none)], filled by the warm-up thread (poll_warm)


static func _web_far(id: String, path: String, n_parts: int) -> void:
	## web build: no worker threads to build the LODs on (warm() is off), so build/web/web_diet.py ships a far LOD of each
	## kit model (about 500 triangles, geometry only) in models/web_far/; it serves as the mid and the far LOD
	var fp := "res://assets/models/web_far/" + path.get_file()
	if _far.has(id) or not ResourceLoader.exists(fp):
		return
	var ps := load(fp) as PackedScene
	if ps == null:
		return
	var fars := _web_lod_meshes(ps)
	var mids := fars
	var mp := "res://assets/models/web_mid/" + path.get_file()   # (about 1000 triangles: the mid LOD, when there)
	if ResourceLoader.exists(mp):
		var mps := load(mp) as PackedScene
		if mps != null:
			var m2 := _web_lod_meshes(mps)
			if m2.size() == fars.size():
				mids = m2
	if fars.size() == n_parts:
		var out: Array = []
		for i in fars.size():
			out.append([mids[i], fars[i]])
		_far[id] = out
		far_serial += 1


static func _web_lod_meshes(ps: PackedScene) -> Array:
	var root: Node3D = ps.instantiate()
	var out: Array = []
	for mi in root.find_children("*", "MeshInstance3D", true, false):
		var m := (mi as MeshInstance3D).mesh
		for si in m.get_surface_count():
			var am := ArrayMesh.new()
			am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, m.surface_get_arrays(si))
			out.append(am)
	root.free()
	return out


static func far_mesh(id: String, i: int) -> Mesh:
	var f = _far.get(id)
	return (f[i] as Array)[1] if f is Array and i < (f as Array).size() else null


static func mid_mesh(id: String, i: int) -> Mesh:
	## perf60: the middle LOD (about a quarter of the near triangles): shadow casting up close, and the mid range
	var f = _far.get(id)
	return (f[i] as Array)[0] if f is Array and i < (f as Array).size() else null


static func build_far(id: String) -> Array:
	## perf60: a coarse LOD of every part for the far range (CityBuilder.ART_NEAR and beyond). The generated models are
	## cut up by their texture seams, so meshoptimizer stops after one halving; welded by position they simplify freely
	## (the seams smear a little, invisible at that distance). Pure (thread-safe). About 50-100 ms per model.
	var out: Array = []
	var a: Dictionary = CityBuilder.manifest().get(id, {})
	if a.is_empty():
		return out
	var path := "res://assets/" + str(a["file"])
	if not ResourceLoader.exists(path):
		return out
	var ps := load(path) as PackedScene
	if ps == null:
		return out
	var root: Node3D = ps.instantiate()
	for mi in root.find_children("*", "MeshInstance3D", true, false):
		var m := mi as MeshInstance3D
		for si in m.mesh.get_surface_count():
			out.append(_far_lod(m.mesh.surface_get_arrays(si)))
	root.free()
	return out


static func _far_lod(arrays: Array) -> Array:
	## [mid mesh, far mesh] (either null when it cannot be reduced)
	var idx = arrays[Mesh.ARRAY_INDEX]
	if idx == null or arrays[Mesh.ARRAY_NORMAL] == null or arrays[Mesh.ARRAY_TEX_UV] == null:
		return [null, null]
	var vs: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var ns: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var uv: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
	var ii: PackedInt32Array = idx
	var key := {}
	var remap := PackedInt32Array()
	remap.resize(vs.size())
	var nv := PackedVector3Array()
	var nn := PackedVector3Array()
	var nu := PackedVector2Array()
	for i in vs.size():
		var v := vs[i]
		var k := Vector3i(roundi(v.x * 2000.0), roundi(v.y * 2000.0), roundi(v.z * 2000.0))
		var j = key.get(k)
		if j != null:
			remap[i] = j
			nn[j] += ns[i]
		else:
			key[k] = nv.size()
			remap[i] = nv.size()
			nv.append(v)
			nn.append(ns[i])
			nu.append(uv[i])
	var ni := PackedInt32Array()
	for t in range(0, ii.size(), 3):
		var x := remap[ii[t]]
		var y := remap[ii[t + 1]]
		var z := remap[ii[t + 2]]
		if x != y and y != z and x != z:
			ni.append(x)
			ni.append(y)
			ni.append(z)
	for i in nn.size():
		nn[i] = nn[i].normalized()
	var w := []
	w.resize(Mesh.ARRAY_MAX)
	w[Mesh.ARRAY_VERTEX] = nv
	w[Mesh.ARRAY_NORMAL] = nn
	w[Mesh.ARRAY_TEX_UV] = nu
	w[Mesh.ARRAY_INDEX] = ni
	var im := ImporterMesh.new()
	im.add_surface(Mesh.PRIMITIVE_TRIANGLES, w)
	im.generate_lods(180.0, 180.0, [])
	# shares of the near mesh (the near mesh is about half the source: see _decimate)
	var out: Array = []
	for share in [MID_SHARE, FAR_SHARE]:
		var want := maxi(FAR_MIN, int(ii.size() / 3 * share * 0.5))
		var best := PackedInt32Array()
		for l in im.get_surface_lod_count(0):
			best = im.get_surface_lod_indices(0, l)
			if best.size() / 3 <= want:
				break
		if best.is_empty() or best.size() >= ni.size():
			out.append(null)
			continue
		var wl := w.duplicate()
		wl[Mesh.ARRAY_INDEX] = best
		var mesh := ArrayMesh.new()
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, wl)
		out.append(mesh)
	return out


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
