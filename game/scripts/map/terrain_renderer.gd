class_name TerrainRenderer
extends Node3D
## Builds the 3D map: displaced terrain mesh, water, coast rocks (static) and a date-dependent
## layer (vegetation, cities, landmarks, harbours, boats) that is rebuilt when the date changes the map.

const TEX_DIR := "res://assets/textures/"
const TREE_SCALE := 0.95   # ~8-15 m trees against the metre-scale buildings
const PALM_MAX_ELEV := 300.0   # date palms / fan palms only on the coastal plain, valleys and the rift

var map: MapData
var terrain_mat: ShaderMaterial
var water_mat: ShaderMaterial
var data_tex: ImageTexture
var height_tex: ImageTexture
var data2_tex: ImageTexture
var rng := RandomNumberGenerator.new()
var resource_pins: Array = []   # [{pos:Vector3, resource:String}]
var city_anchors: Array = []    # [{pos:Vector3, city:Dictionary}]
var dynamic: Node3D             # rebuilt by apply_date()
var cities: CityBuilder
var _target: Node3D             # parent for _mm()


func _noise_tex(freq: float, normal := false, seed_ := 1, size := 512) -> NoiseTexture2D:
	var n := FastNoiseLite.new()
	n.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n.frequency = freq
	n.seed = seed_
	n.fractal_octaves = 5
	var t := NoiseTexture2D.new()
	t.width = size; t.height = size
	t.seamless = true
	t.noise = n
	if normal:
		t.as_normal_map = true
		t.bump_strength = 6.0
	t.generate_mipmaps = true
	return t


func _opt_tex(names: Array) -> Texture2D:
	for n in names:
		for ext in [".png", ".jpg", ".webp"]:
			var p: String = TEX_DIR + n + ext
			if ResourceLoader.exists(p):
				return load(p)
	return null


static func kit_tex(name: String) -> Texture2D:
	var p := "res://assets/kit/%s.png" % name
	return load(p) if ResourceLoader.exists(p) else null


func _build_terrain() -> void:
	var size := map.world_size()
	var margin := 14.0
	var pm := PlaneMesh.new()
	pm.size = size + Vector2(margin * 2, margin * 2)
	var spacing := 0.16
	pm.subdivide_width = int(pm.size.x / spacing)
	pm.subdivide_depth = int(pm.size.y / spacing)
	var mi := MeshInstance3D.new()
	mi.name = "Terrain"
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.mesh = pm
	mi.position = Vector3(size.x * 0.5 - 1.0, 0, size.y * 0.5 - 1.0)
	mi.custom_aabb = AABB(Vector3(-pm.size.x * 0.5, -1.0, -pm.size.y * 0.5), Vector3(pm.size.x, 4.0, pm.size.y))
	terrain_mat = ShaderMaterial.new()
	terrain_mat.shader = load("res://scripts/map/terrain.gdshader")
	set_common(terrain_mat)
	terrain_mat.set_shader_parameter("detail_normal", _noise_tex(0.02, true, 3))
	var slots := {"t_grass": "terrain_grassland", "t_plains": "terrain_plains", "t_hills": "terrain_hills_limestone",
		"t_rock": "terrain_desert_rock", "t_sand": "terrain_desert_sand", "t_marsh": "terrain_marsh",
		"t_beach": "terrain_beach_sand", "t_forest": "terrain_pine_forest_floor", "t_basalt": "terrain_basalt"}
	var found := 0
	for k in slots:
		var t := _opt_tex(["terrain/" + slots[k], slots[k]])
		if t:
			terrain_mat.set_shader_parameter(k, t)
			found += 1
	if found == slots.size():
		terrain_mat.set_shader_parameter("use_textures", 1.0)
	var pav := kit_tex("kit_paving")
	if pav:
		terrain_mat.set_shader_parameter("t_paving", pav)
		terrain_mat.set_shader_parameter("use_paving", 1.0)
	mi.material_override = terrain_mat
	add_child(mi)


func set_common(mat: ShaderMaterial) -> void:
	mat.set_shader_parameter("hex_data", data_tex)
	mat.set_shader_parameter("hex_height", height_tex)
	mat.set_shader_parameter("hex_data2", data2_tex)
	mat.set_shader_parameter("map_size", Vector2i(map.cols, map.rows))
	var ca := PackedVector4Array([Vector4(), Vector4(), Vector4()])
	var cb := PackedVector4Array([Vector4(), Vector4(), Vector4()])
	for i in mini(3, map.tm.craters.size()):
		var cr: Dictionary = map.tm.craters[i]
		ca[i] = Vector4(cr["c"].x, cr["c"].y, cr["ax"].x, cr["ax"].y)
		cb[i] = Vector4(cr["L"], cr["W"], cr["rim"], cr["floor"])
	mat.set_shader_parameter("crater_a", ca)
	mat.set_shader_parameter("crater_b", cb)


func _build_water() -> void:
	var size := map.world_size()
	var pm := PlaneMesh.new()
	pm.size = size + Vector2(260, 260)
	pm.subdivide_width = 240
	pm.subdivide_depth = 240
	var mi := MeshInstance3D.new()
	mi.name = "Water"
	mi.mesh = pm
	mi.position = Vector3(size.x * 0.5, 0.0, size.y * 0.5)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	water_mat = ShaderMaterial.new()
	water_mat.shader = load("res://scripts/map/water.gdshader")
	set_common(water_mat)
	water_mat.set_shader_parameter("wave_n1", _noise_tex(0.03, true, 11))
	water_mat.set_shader_parameter("wave_n2", _noise_tex(0.05, true, 23))
	mi.material_override = water_mat
	add_child(mi)


func set_hover(off: Vector2i) -> void:
	terrain_mat.set_shader_parameter("hover_off", off)


func set_selected(off: Vector2i) -> void:
	terrain_mat.set_shader_parameter("select_off", off)


func height_at(x: float, z: float) -> float:
	return map.tm.height(Vector2(x, z))


func tile_elev(p: Vector2) -> float:
	return float(map.tile_at(TerrainMath.world_to_offset(p)).get("elevation_m", 0.0))


# ---------------------------------------------------------------- helpers

func props_material(wind := 1.0) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = load("res://scripts/map/props.gdshader")
	m.set_shader_parameter("wind", wind)
	return m


const CHUNK := 8.0   # MultiMeshes are split into CHUNK-sized world tiles so frustum/shadow culling works


func mm(mesh: Mesh, xforms: Array, tints: Array, mat: Material, name_: String, parent: Node = null, shadows := true) -> MultiMeshInstance3D:
	if xforms.is_empty():
		return null
	var buckets := {}
	for i in xforms.size():
		var o: Vector3 = (xforms[i] as Transform3D).origin
		var key := Vector2i(int(floor(o.x / CHUNK)), int(floor(o.z / CHUNK)))
		if not buckets.has(key):
			buckets[key] = []
		buckets[key].append(i)
	var last: MultiMeshInstance3D = null
	for key in buckets:
		var idx: Array = buckets[key]
		var m := MultiMesh.new()
		m.transform_format = MultiMesh.TRANSFORM_3D
		m.use_custom_data = true
		m.mesh = mesh
		m.instance_count = idx.size()
		for j in idx.size():
			m.set_instance_transform(j, xforms[idx[j]])
			m.set_instance_custom_data(j, tints[idx[j]])
		if mesh.has_meta("tree_kind"):   # v5 trees: near / far LODs and contact-shadow discs (TreeKit, own material)
			last = TreeKit.add_lods(str(mesh.get_meta("tree_kind")), m, "%s_%d_%d" % [name_, key.x, key.y], parent if parent else _target, shadows)
			continue
		var mmi := MultiMeshInstance3D.new()
		mmi.name = "%s_%d_%d" % [name_, key.x, key.y]
		mmi.multimesh = m
		mmi.material_override = mat
		if not shadows:
			mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		(parent if parent else _target).add_child(mmi)
		last = mmi
	return last


func rand_in_hex(c: Vector2, r := 0.8) -> Vector2:
	for i in 64:
		var p := Vector2(rng.randf_range(-r, r), rng.randf_range(-r, r))
		var ax := absf(p.x); var az := absf(p.y)
		if ax <= r * 0.866 and az <= r - ax * 0.577:
			return c + p
	return c


func tree_xf(p: Vector2, s: float, yaw := -1.0) -> Transform3D:
	var y := height_at(p.x, p.y)
	s *= TREE_SCALE
	var b := Basis(Vector3.UP, rng.randf() * TAU if yaw < 0 else yaw).scaled(Vector3(s, s, s))
	return Transform3D(b, Vector3(p.x, y - 0.004, p.y))


func tint(base: Color, v := 0.12) -> Color:
	var k := 1.0 + rng.randf_range(-v, v)
	return Color(base.r * 0.5 * k, base.g * 0.5 * k * (1.0 + rng.randf_range(-0.05, 0.05)), base.b * 0.5 * k, 0)


func build(m: MapData) -> void:
	map = m
	rng.seed = 1948
	data_tex = ImageTexture.create_from_image(map.data_image())
	height_tex = ImageTexture.create_from_image(map.height_image())
	data2_tex = ImageTexture.create_from_image(map.data2_dated())
	_build_terrain()
	_build_water()
	var st := Node3D.new(); st.name = "Static"; add_child(st)
	_target = st
	_build_coast()
	dynamic = Node3D.new(); dynamic.name = "Dynamic"; add_child(dynamic)
	_veg_root = Node3D.new(); _veg_root.name = "Vegetation"; dynamic.add_child(_veg_root)
	_veg_init()
	cities = CityBuilder.new()
	cities.name = "Cities"
	dynamic.add_child(cities)
	apply_date()


func apply_date() -> void:
	## call after map.set_date() returned true. Incremental: only changed cities and the vegetation
	## chunks around hexes that became (or stopped being) urban are rebuilt.
	var t0 := Time.get_ticks_msec()
	if cities.R == null:
		cities.build(self, map)
	else:
		cities.update()
	data_tex.update(map.data_image())
	height_tex.update(map.height_image())
	data2_tex.update(map.data2_dated())   # historical terrain changes (Hula drainage, Dead Sea south basin)
	var t1 := Time.get_ticks_msec()
	var nveg := _veg_update()
	_target = dynamic
	if _boats:
		_boats.free()
	_boats = Node3D.new(); _boats.name = "Boats"; dynamic.add_child(_boats)
	_target = _boats
	rng.seed = 1948
	_build_boats()
	_target = dynamic
	_collect_resources()
	_zone_labels()
	_wonder_labels()
	print("render: %s cities=%d | %s | veg chunks %d | total %d ms" % [map.date, map.cities.size(), cities.stats, nveg, Time.get_ticks_msec() - t0])
	if HDPlus.plus and is_inside_tree():   # HD+: the quarter's season follows the map date (hdplus.gd)
		HDPlus.on_date(get_tree().get_first_node_in_group("game"))


func rebuild_dynamic() -> void:
	apply_date()


var _sun: DirectionalLight3D


func _process(_delta: float) -> void:
	TreeKit.sync_mode()   # v5 trees: a live SD <-> HD switch swaps the near tree LODs (a bool check otherwise)
	if _sun == null or not is_instance_valid(_sun):
		var g := get_tree().get_first_node_in_group("game") if is_inside_tree() else null
		_sun = g.get_node_or_null("Sun") as DirectionalLight3D if g else null
	TreeKit.sync_light(_sun)   # v5 trees: the ground shadows follow the sun / moon


# ---------------------------------------------------------------- vegetation (per-hex cache, chunked)

const VEG_KINDS := ["pine", "broad", "cypress", "olive", "citrus", "palm", "palm_cluster", "eucalyptus", "oleander", "acacia"]
var _veg_root: Node3D
var _veg := {}            # Vector2i hex -> {kind: [xforms, tints]}
var _veg_chunk_hexes := {} # chunk -> [hex]
var _veg_chunks := {}     # chunk -> Node3D
var _veg_urban := {}      # urban hexes at the last vegetation build
var _veg_mat: ShaderMaterial
var _veg_meshes := {}
var _boats: Node3D


func _veg_init() -> void:
	_veg_mat = TreeKit.material()   # v5 trees: TreeKit species (mm() adds their LODs and ground shadows)
	TreeKit.bind_terrain(self)      # the ground shadows drape on the terrain height (set_common)
	_veg_meshes = {}
	for kind in VEG_KINDS:
		_veg_meshes[kind] = TreeKit.mesh(kind)
	for t in map.tiles:
		var k := Vector2i(int(t["q"]), int(t["r"]))
		rng.seed = TerrainMath.hash2u(k.x * 13 + 5, k.y * 7 + 11)
		var sets := {}
		for kind in VEG_KINDS:
			sets[kind] = [[], []]
		_veg_hex(t, k, sets)
		var n := 0
		for kind in VEG_KINDS:
			n += sets[kind][0].size()
		if n == 0:
			continue
		# the hex's tree density in the tint's alpha (the foliage reads only rgb): the ground shadows of dense woods
		# are lighter each, so overlapping shadows do not pile up into a black floor (veg_shadow.gdshader)
		var dens := clampf((n - 8) / 48.0, 0.0, 1.0)
		for kind in VEG_KINDS:
			var tl: Array = sets[kind][1]
			for i in tl.size():
				var c: Color = tl[i]
				c.a = dens
				tl[i] = c
		_veg[k] = sets
		var ch := CityBuilder._chunk_of(k)
		if not _veg_chunk_hexes.has(ch):
			_veg_chunk_hexes[ch] = []
		_veg_chunk_hexes[ch].append(k)


func _veg_update() -> int:
	var dirty := {}
	if _veg_chunks.is_empty():
		for ch in _veg_chunk_hexes:
			dirty[ch] = true
	else:
		for k in map.urban:
			if not _veg_urban.has(k) and _veg.has(k):
				dirty[CityBuilder._chunk_of(k)] = true
		for k in _veg_urban:
			if not map.urban.has(k) and _veg.has(k):
				dirty[CityBuilder._chunk_of(k)] = true
	_veg_urban = map.urban.duplicate()
	for ch in dirty:
		if _veg_chunks.has(ch):
			(_veg_chunks[ch] as Node).free()
		var node := Node3D.new()
		node.name = "Veg_%d_%d" % [ch.x, ch.y]
		_veg_root.add_child(node)
		_veg_chunks[ch] = node
		var merged := {}
		for kind in VEG_KINDS:
			merged[kind] = [[], []]
		for k in _veg_chunk_hexes.get(ch, []):
			if map.urban.has(k):
				continue
			for kind in VEG_KINDS:
				merged[kind][0].append_array(_veg[k][kind][0])
				merged[kind][1].append_array(_veg[k][kind][1])
		for kind in VEG_KINDS:
			mm(_veg_meshes[kind], merged[kind][0], merged[kind][1], _veg_mat, kind, node, true)   # TreeKit follows the preset's tree shadows
	return dirty.size()


func _veg_hex(t: Dictionary, k: Vector2i, sets: Dictionary) -> void:
	var c := TerrainMath.offset_center(k.x, k.y)
	var feat: String = t.get("feature", "none")
	var ter: String = t.get("terrain", "")
	var elev := float(t.get("elevation_m", 0.0))
	if ter in ["ocean", "coast", "lake"]:
		return
	if feat == "forest":
		var n := 64 if ter != "mountains" else 34
		for i in n:
			var p := rand_in_hex(c, 0.95)
			var r := rng.randf()
			var kind := "pine" if r < 0.5 else ("broad" if r < 0.8 else "cypress")
			sets[kind][0].append(tree_xf(p, rng.randf_range(0.85, 1.3)))
			sets[kind][1].append(tint(Color.WHITE))
	elif feat == "orchard":
		var kind := "citrus" if (TerrainMath.hash2(k.x, k.y) < 0.5 and ter in ["grassland", "plains"] and elev < 200.0) else "olive"
		if ter in ["desert", "desert_hills"]:
			kind = "palm"   # date groves of the Arava, the Dead Sea and the Jordan valley
		var yaw := rng.randf() * PI
		var patch_off := Vector2(rng.randf_range(-0.25, 0.25), rng.randf_range(-0.25, 0.25))
		var patch_r := rng.randf_range(0.4, 0.62)
		var dir := Vector2(cos(yaw), sin(yaw)); var side := Vector2(-dir.y, dir.x)
		for a in range(-5, 6):
			for b in range(-5, 6):
				var p := c + dir * a * 0.13 + side * b * 0.13
				if (p - c).distance_to(patch_off) > patch_r * (0.85 + 0.3 * TerrainMath.vnoise(p * 3.0)):
					continue
				sets[kind][0].append(tree_xf(p + Vector2(rng.randf_range(-0.01, 0.01), rng.randf_range(-0.01, 0.01)), rng.randf_range(0.9, 1.15)))
				sets[kind][1].append(tint(Color.WHITE, 0.08))
	elif feat == "oasis":
		for i in 14:
			var p := rand_in_hex(c, 0.55)
			var kind := "palm_cluster" if rng.randf() < 0.4 else "palm"
			sets[kind][0].append(tree_xf(p, rng.randf_range(0.8, 1.2)))
			sets[kind][1].append(tint(Color.WHITE))
	elif str(t.get("region", "")) == "Carmel" and not map.urban.has(k):
		# Mount Carmel: dense Aleppo pine, oak and maquis woodland
		for i in 80:
			var p := rand_in_hex(c, 0.97)
			var r := rng.randf()
			var kind := "pine" if r < 0.6 else ("broad" if r < 0.9 else "cypress")
			sets[kind][0].append(tree_xf(p, rng.randf_range(0.7, 1.2)))
			sets[kind][1].append(tint(Color.WHITE))
	elif ter in ["hills", "mountains"] and str(t.get("base", "")) == "grassland" and feat == "none":
		# Mediterranean maquis and pine-oak woodland on the rainy hills
		for i in (40 if ter == "hills" else 26):
			var p := rand_in_hex(c, 0.95)
			var r := rng.randf()
			var kind := "pine" if r < 0.45 else ("broad" if r < 0.8 else ("olive" if r < 0.9 else "cypress"))
			sets[kind][0].append(tree_xf(p, rng.randf_range(0.7, 1.15)))
			sets[kind][1].append(tint(Color.WHITE))
	elif ter in ["grassland", "plains", "hills"] and feat == "none":
		for g in rng.randi_range(1, 3):
			var gc := rand_in_hex(c, 0.8)
			for i in rng.randi_range(3, 9):
				var p := gc + Vector2(rng.randf_range(-0.22, 0.22), rng.randf_range(-0.22, 0.22))
				var kind := "olive" if (ter == "hills" or elev > 400.0) and rng.randf() < 0.6 else ("cypress" if rng.randf() < 0.3 else ("pine" if elev > 400.0 else "broad"))
				if kind == "broad" and elev < 150.0 and ter != "hills" and TerrainMath.hash2(k.x * 3 + g, k.y) < 0.4:
					kind = "eucalyptus"   # the planted eucalyptus groves of the coastal plain and the valleys
				sets[kind][0].append(tree_xf(p, rng.randf_range(0.7, 1.1)))
				sets[kind][1].append(tint(Color.WHITE))
	if t.get("stream") != null and ter in ["desert", "desert_hills", "plains"]:
		# umbrella-thorn acacias (and on the plains some tamarisks) along the wadi bed
		for i in rng.randi_range(3, 7):
			var p := c + Vector2(rng.randf_range(-0.3, 0.3), rng.randf_range(-0.3, 0.3))
			if ter == "plains" and rng.randf() < 0.4:
				sets["broad"][0].append(tree_xf(p, rng.randf_range(0.4, 0.6)))
				sets["broad"][1].append(tint(Color(0.85, 0.9, 0.7)))
			else:
				sets["acacia"][0].append(tree_xf(p, rng.randf_range(0.75, 1.1)))
				sets["acacia"][1].append(tint(Color(0.95, 0.95, 0.85)))
	elif t.get("stream") != null and ter in ["grassland", "hills"] and not map.urban.has(k):
		# oleander thickets along the streams of the north
		for i in rng.randi_range(2, 4):
			var p := c + Vector2(rng.randf_range(-0.3, 0.3), rng.randf_range(-0.3, 0.3))
			sets["oleander"][0].append(tree_xf(p, rng.randf_range(0.8, 1.1)))
			sets["oleander"][1].append(tint(Color.WHITE, 0.06))
	if t.get("coast", false) and ter in ["grassland", "plains", "desert"] and elev < PALM_MAX_ELEV:
		for i in rng.randi_range(2, 5):
			var p := rand_in_hex(c, 0.75)
			if height_at(p.x, p.y) < 0.04:
				continue
			sets["palm"][0].append(tree_xf(p, rng.randf_range(0.8, 1.1)))
			sets["palm"][1].append(tint(Color.WHITE))


# ---------------------------------------------------------------- coast (static)

func _build_coast() -> void:
	var rx: Array = []; var rc: Array = []
	for t in map.tiles:
		if not t.get("coast", false):
			continue
		var k := Vector2i(int(t["q"]), int(t["r"]))
		var c := TerrainMath.offset_center(k.x, k.y)
		var rocky: bool = float(t.get("lat", 32.0)) > 32.6 or t.get("terrain", "") in ["hills", "mountains"]
		var n := 40 if rocky else 12
		for i in n:
			var p := rand_in_hex(c, 1.05)
			var h := height_at(p.x, p.y)
			if h < -0.035 or h > 0.012:
				continue
			for j in rng.randi_range(1, 4):
				var q := p + Vector2(rng.randf_range(-0.06, 0.06), rng.randf_range(-0.06, 0.06))
				var s := rng.randf_range(0.04, 0.10)
				var b := Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3(s * rng.randf_range(0.8, 1.5), s * rng.randf_range(0.5, 0.9), s))
				rx.append(Transform3D(b, Vector3(q.x, height_at(q.x, q.y) - s * 0.25, q.y)))
				var g := rng.randf_range(0.72, 0.88)
				rc.append(Color(g * 1.02 * 0.5, g * 0.98 * 0.5, g * 0.9 * 0.5, 0))
	mm(MeshKit.rock(), rx, rc, props_material(0.0), "CoastRocks")
	_art_shore()


func _art_shore() -> void:
	## art-builder shore rocks: kurkar / sandstone clusters on rocky coasts, the Carmel headland, the
	## Rosh HaNikra chalk cliff (map.json natural wonder hex), flat abrasion platforms on sandy coasts
	var sets := {}
	var put := func(id: String, p: Vector2, yaw: float, sc: float, y: float) -> void:
		var parts := ArtKit.get_parts(id)
		if parts.is_empty():
			return
		for i in parts.size():
			var key := "%s:%d" % [id, i]
			if not sets.has(key):
				sets[key] = [[], []]
			sets[key][0].append(Transform3D(Basis(Vector3.UP, yaw) * Basis.from_scale(Vector3.ONE * sc), Vector3(p.x, y, p.y)) * (parts[i]["xf"] as Transform3D))
			sets[key][1].append(Color(0.5, 0.5, 0.5, 0))
	for t in map.tiles:
		if not t.get("coast", false):
			continue
		var k := Vector2i(int(t["q"]), int(t["r"]))
		var c := TerrainMath.offset_center(k.x, k.y)
		var lat := float(t.get("lat", 32.0))
		var rocky: bool = lat > 32.6 or t.get("terrain", "") in ["hills", "mountains"]
		for i in 0:   # art shore rocks read as floating spikes at map scale; only the Rosh HaNikra cliff below
			for tries in 12:
				var p := rand_in_hex(c, 1.0)
				var h := height_at(p.x, p.y)
				if h > -0.03 and h < 0.01:
					var id: String
					if str(t.get("region", "")) == "Carmel":
						id = "shore_rocks_large"
					elif rocky:
						id = ["shore_rocks_medium", "shore_rocks_small", "shore_rocks_jaffa"][rng.randi() % 3]
					else:
						id = "shore_reef_flat" if rng.randf() < 0.5 else "shore_rocks_small"
					put.call(id, p, rng.randf() * TAU, 0.006 * rng.randf_range(0.8, 1.3), h - 0.01)
					break
	for w in map.natural_wonders:
		if str(w.get("id", "")) == "rosh_hanikra_grottoes":
			for qr in w.get("hexes", []):
				var c := TerrainMath.offset_center(int(qr[0]), int(qr[1]))
				for tries in 30:
					var p := rand_in_hex(c, 1.0)
					var h := height_at(p.x, p.y)
					if h > -0.02 and h < 0.03:
						put.call("shore_cliff_roshhanikra", p, -PI * 0.5, 0.009, h - 0.02)
						break
	for key in sets:
		var bits := str(key).split(":")
		var part: Dictionary = ArtKit.get_parts(bits[0])[int(bits[1])]
		mm(part["mesh"], sets[key][0], sets[key][1], part["mat"], "Shore_" + bits[0])


func _build_boats() -> void:
	var xs: Array = []; var cs: Array = []
	for c in map.cities:
		var k := Vector2i(c["q"], c["r"])
		var near_sea := false
		for nb in TerrainMath.offset_neighbors(k):
			if map.tile_at(nb).get("terrain", "") in ["coast", "ocean"]:
				near_sea = true
		if not near_sea:
			continue
		var center: Vector2 = c["pos"]
		var placed := 0
		var tries := 0
		while placed < 2 + int(c["size"]) * 2 and tries < 200:
			tries += 1
			var p := center + Vector2(rng.randf_range(-3.0, 1.0), rng.randf_range(-2.5, 2.5))
			if height_at(p.x, p.y) > -0.08:
				continue
			var b := Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3.ONE * rng.randf_range(0.6, 0.8))
			xs.append(Transform3D(b, Vector3(p.x, 0.0, p.y)))
			cs.append(Color(0.5, 0.5, 0.5, 0))
			placed += 1
	mm(MeshKit.boat(), xs, cs, props_material(0.0), "Boats")


static func resource_plausible(r: String, t: Dictionary) -> bool:
	## crops need rain or irrigation: hide farm resources on dry desert hexes without a river/oasis
	var ter := str(t.get("terrain", ""))
	if r in ["sheep", "cattle"]:
		return false   # no herding icon yet; the wheat icon misread as crops in the desert
	var arid: bool = ter in ["desert", "desert_hills"] or (t.get("rain_mm") != null and float(t["rain_mm"]) < 200.0)
	if r in ["wheat", "citrus", "olives", "grapes"] and arid:
		return t.get("river", false) or str(t.get("feature", "")) == "oasis"
	return true


func _collect_resources() -> void:
	resource_pins.clear()
	for t in map.tiles:
		var rv = t.get("resource", null)
		if rv == null:
			continue
		var r: String = str(rv)
		if r == "none" or r == "":
			continue
		var k := Vector2i(int(t["q"]), int(t["r"]))
		if map.urban.has(k) or not resource_plausible(r, t) or not map.resource_visible(t):
			continue
		var c := TerrainMath.offset_center(k.x, k.y) + Vector2(0.35, -0.25)
		resource_pins.append({"pos": Vector3(c.x, maxf(0.0, height_at(c.x, c.y)), c.y), "resource": r})



var _zone_root: Node3D


const ZONE_NAMES := {"Lebanon": "Security zone (1985-2000)", "Samaria": "West Bank (military administration)",
	"Judea": "West Bank (military administration)", "Judean Desert": "West Bank (military administration)",
	"Gaza Strip": "Gaza Strip (military administration)", "Sinai": "Sinai (military administration)",
	"Golan": "Golan Heights (military administration)", "Syria": "Syrian buffer zone (IDF)"}


func _zone_labels() -> void:
	## A label on the centroid of every connected cluster (>= 3 hexes) of hexes held only militarily in the
	## current border era (map.json military_control); named by the cluster's majority region.
	if _zone_root:
		_zone_root.free()
	_zone_root = Node3D.new(); _zone_root.name = "ZoneLabels"; dynamic.add_child(_zone_root)
	var hexes := {}
	for qr in map.military_control.get(map.border_era, []):
		hexes[Vector2i(int(qr[0]), int(qr[1]))] = true
	var era_label := map.border_era
	for e in map.border_eras:
		if str(e.get("id", "")) == map.border_era:
			era_label = str(e.get("label", era_label))
	var seen := {}
	for k0 in hexes:
		if seen.has(k0):
			continue
		var comp := [k0]; var stack := [k0]; seen[k0] = true
		while stack.size() > 0:
			var c: Vector2i = stack.pop_back()
			for n in TerrainMath.offset_neighbors(c):
				if hexes.has(n) and not seen.has(n):
					seen[n] = true; comp.append(n); stack.append(n)
		if comp.size() < 3:
			continue
		var acc := Vector2.ZERO
		var regions := {}
		for k in comp:
			acc += TerrainMath.offset_center(k.x, k.y)
			var rg := str(map.tile_at(k).get("region", ""))
			regions[rg] = int(regions.get(rg, 0)) + 1
		acc /= comp.size()
		var top := ""
		for rg in regions:
			if top == "" or regions[rg] > regions[top]:
				top = rg
		var text: String = ZONE_NAMES.get(top, era_label)
		if top == "Lebanon" and map.date < "1985-06-10":
			text = "IDF in Lebanon (1982-85)"
		var l := Label3D.new()
		l.text = text
		l.font = UIKit.font("title")
		l.font_size = 64
		l.outline_size = 26
		l.modulate = Color(1.0, 0.88, 0.78)
		l.outline_modulate = Color(0.12, 0.02, 0.01, 0.92)
		l.pixel_size = 0.00048
		l.fixed_size = true
		l.add_to_group("map_area_label")
		l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		l.no_depth_test = true
		l.position = Vector3(acc.x, maxf(0.0, height_at(acc.x, acc.y)) + 0.5, acc.y)
		_zone_root.add_child(l)



var _wonder_root: Node3D


func _wonder_labels() -> void:
	if _wonder_root:
		return
	_wonder_root = Node3D.new(); _wonder_root.name = "WonderLabels"; add_child(_wonder_root)
	for w in map.natural_wonders:
		var hx: Array = w.get("hexes", [])
		if hx.is_empty() or str(w.get("kind", "")) == "lake":
			continue
		var acc := Vector2.ZERO
		var lo := 99.0
		for qr in hx:
			var c := TerrainMath.offset_center(int(qr[0]), int(qr[1]))
			acc += c
			lo = minf(lo, height_at(c.x, c.y))
		acc /= hx.size()
		var l := Label3D.new()
		l.text = str(w.get("name", ""))
		l.font = UIKit.font("title")
		l.font_size = 64
		l.outline_size = 26
		l.modulate = Color(0.85, 1.0, 0.95)
		l.outline_modulate = Color(0.02, 0.12, 0.12, 0.92)
		l.pixel_size = 0.00048
		l.fixed_size = true
		l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		l.no_depth_test = true
		# craters: inside the depression, just above the floor
		var y := (lo + 0.25) if str(w.get("kind", "")) == "crater" else maxf(0.0, height_at(acc.x, acc.y)) + 0.5
		l.position = Vector3(acc.x, y, acc.y)
		l.add_to_group("map_area_label")
		_wonder_root.add_child(l)
