class_name CityBuilder
extends Node3D
## Date-aware city fabric for the current MapData date.
## - Procedural building kit (textured facades from assets/kit): Bauhaus blocks, shikun slabs, glass towers,
##   limestone houses with domes and arches, red-tile-roof houses, ma'abara huts, public buildings.
## - Buildings fill a global street-block grid (PX, PZ, SW) that the terrain shader also paints.
## - Art-builder dioramas (assets/models/city) for signature districts, with plinths cut away at the terrain surface.
## - Landmarks and harbours appear only from the year they existed.

const STOREY := 0.037
const SINK := 0.02         # buildings are sunk this far so slopes don't show a gap (building.gdshader)

# style ids (INSTANCE_CUSTOM.a = (id + 0.5) / 10), see building.gdshader
const S_STONE := 0
const S_BAUHAUS := 1
const S_SHIKUN := 2
const S_GLASS := 3
const S_PLASTER := 4
const S_PLAIN := 5
const S_TILES := 6
const S_HUT := 7
const S_FLAT := 8      # flat colour (containers, solar heaters)

const OLD_TOWNS := ["acre", "safed", "nazareth", "tiberias", "beit_shean", "east_jerusalem", "jaffa", "ramla", "lod"]


var R: TerrainRenderer
var map: MapData
var rng := RandomNumberGenerator.new()
var B := {}
var footprints: Array = []     # [Vector2 centre, radius]
var plazas := {}               # Vector2i lattice cell -> true
var bmat: ShaderMaterial
var _dio_cache := {}


const KINDS := ["box", "cyl", "roof", "dome", "cone", "palm", "tree", "cypress", "pine", "olive", "citrus", "bougainvillea", "rock", "boat", "fountain", "gantry", "jib", "fanpalm"]
var _parent: Node3D            # where art models / dioramas go (global node or the hex node being built)
var _global: Node3D
var _global_sig := ""
var _hexes := {}               # Vector2i -> {sig, prof, B, node, chunk}
var _chunks := {}              # Vector2i chunk -> Node3D
var _meshes := {}
var _mats := {}
var stats := ""
var _global_sig_changed := false
var _max_hex := [0.0, ""]
var _max_chunk := 0.0
var _chunk_inst := 0


func build(renderer: TerrainRenderer, m: MapData) -> void:
	R = renderer
	map = m
	bmat = ShaderMaterial.new()
	bmat.shader = load("res://scripts/map/building.gdshader")
	var kits := ["stone", "bauhaus", "shikun", "glass", "roof_flat", "roof_tiles", "paving"]
	if GfxTier.web() and ResourceLoader.exists(WEB_KIT_T) and ResourceLoader.exists(WEB_KIT_N):
		# web build: the kit facades and their normal maps as two texture arrays (WebGL 2's 16 texture units;
		# building.gdshader's WEB_LOOK branch), built by build/web/web_diet.py in that copy only
		bmat.set_shader_parameter("kit_t", load(WEB_KIT_T))
		bmat.set_shader_parameter("kit_n", load(WEB_KIT_N))
		kits = []
	for k in kits:
		var fac := "_facade" if k in ["stone", "bauhaus", "shikun", "glass"] else ""
		var t := TerrainRenderer.kit_tex("kit_" + k + fac)
		var n := TerrainRenderer.kit_tex("kit_" + k + fac + "_n")
		if t:
			bmat.set_shader_parameter("t_" + k, t)
		if n:
			bmat.set_shader_parameter("n_" + k, n)
	_meshes = {"box": MeshKit.box(), "cyl": MeshKit.cylinder(), "roof": MeshKit.roof(), "dome": MeshKit.dome(), "cone": MeshKit.cone(),
		"fountain": MeshKit.fountain(), "palm": MeshKit.palm(), "tree": MeshKit.broadleaf(), "cypress": MeshKit.cypress(),
		"pine": MeshKit.pine(), "olive": MeshKit.olive(), "citrus": MeshKit.citrus(), "bougainvillea": MeshKit.bougainvillea(), "rock": MeshKit.rock(), "boat": MeshKit.boat(),
		"gantry": MeshKit.crane_gantry(), "jib": MeshKit.crane_jib(), "fanpalm": MeshKit.fanpalm()}
	var pm := R.props_material()
	var still := R.props_material(0.0)
	for k in KINDS:
		if k in ["box", "cyl", "roof", "dome", "cone", "fountain"]:
			_mats[k] = bmat
		elif k in ["rock", "boat", "gantry", "jib"]:
			_mats[k] = still
		else:
			_mats[k] = pm   # trees, citrus, bougainvillea
	update()


func _new_buffers() -> Dictionary:
	var d := {}
	for k in KINDS:
		d[k] = [[], []]
	return d


static func _chunk_of(k: Vector2i) -> Vector2i:
	var c := TerrainMath.offset_center(k.x, k.y)
	return Vector2i(int(floor(c.x / TerrainRenderer.CHUNK)), int(floor(c.y / TerrainRenderer.CHUNK)))


func update(slice_ms := 0.0) -> void:
	## Incremental: rebuild only the hexes whose city state changed at the current map date.
	## perf60: slice_ms > 0 spreads the work over frames (a coroutine: await it): after each hex / chunk the job yields
	## once a frame has used slice_ms. Everything new is built hidden and swapped in at the end, in one frame, so the
	## map never shows half a city; 0 = all at once (the first build, loading screens, captures and tests).
	var t0 := Time.get_ticks_msec()
	var work_ms := 0.0
	var slice_t := Time.get_ticks_usec()
	var frames := 1
	var all_dirty := false
	var gs := _global_signature()
	_global_sig_changed = gs != _global_sig
	var old_nodes: Array = []      # freed at the swap
	var new_nodes: Array = []      # shown at the swap
	if gs != _global_sig:
		_global_sig = gs
		if _global:
			old_nodes.append(_global)
		_global = Node3D.new()
		_global.name = "Global"
		_global.visible = false
		add_child(_global)
		new_nodes.append(_global)
		_parent = _global
		_drop_fp(GLOBAL_FP)   # perf60: only the landmark / harbour footprints (the towns keep theirs, tagged by hex)
		var n_fp := footprints.size()
		rng.seed = 7
		R.rng.seed = 7
		seed(7)   # Array.shuffle() uses the global RNG: seed it so city layouts are identical every launch
		B = _new_buffers()
		_place_landmarks()
		_place_dioramas()
		_build_harbours()
		_flush_into(B, _global)
		_tag_fp(n_fp, GLOBAL_FP)
		FrameLog.mark("city global %d ms" % ((Time.get_ticks_usec() - slice_t) / 1000))
	var dirty_chunks := {}
	var rebuilt := 0
	for k in _hexes.keys():
		if not map.urban.has(k):
			var h: Dictionary = _hexes[k]
			if h["node"]:
				old_nodes.append(h["node"])
			dirty_chunks[h["chunk"]] = true
			_hexes.erase(k)
			_drop_fp(k)
	var todo: Array = []
	for k in map.urban:
		var city: Dictionary = map.urban_owner.get(k, {})
		if city.is_empty():
			continue
		var sig := _hex_signature(k, city)
		var h: Dictionary = _hexes.get(k, {})
		if not all_dirty and not h.is_empty() and h["sig"] == sig:
			if h["prof"] == "old":
				map.district[k] = "old"
			continue
		todo.append([k, city, sig])
	for it in todo:
		if slice_ms > 0.0 and (Time.get_ticks_usec() - slice_t) / 1000.0 > slice_ms:
			work_ms += (Time.get_ticks_usec() - slice_t) / 1000.0
			await get_tree().process_frame
			frames += 1
			slice_t = Time.get_ticks_usec()
		var k: Vector2i = it[0]
		var city: Dictionary = it[1]
		var h: Dictionary = _hexes.get(k, {})
		if not h.is_empty() and h["node"]:
			old_nodes.append(h["node"])
		var node := Node3D.new()
		node.name = "Hex_%d_%d" % [k.x, k.y]
		node.visible = false
		add_child(node)
		new_nodes.append(node)
		_parent = node
		B = _new_buffers()
		_drop_fp(k)   # perf60: its own old footprints go first (they made its signature change on every update)
		var n_hfp := footprints.size()
		var seed_ := TerrainMath.hash2u(k.x * 31 + 7, k.y * 17 + 3)
		rng.seed = seed_
		R.rng.seed = seed_
		seed(seed_)
		var th := Time.get_ticks_usec()
		var prof := _build_hex(k, city)
		var dth := (Time.get_ticks_usec() - th) / 1000.0
		_tag_fp(n_hfp, k)
		if dth > _max_hex[0]:
			_max_hex = [dth, "%s %s" % [prof, str(k)]]
		var ch := _chunk_of(k)
		_hexes[k] = {"sig": it[2], "prof": prof, "B": B, "node": node, "chunk": ch}
		dirty_chunks[ch] = true
		rebuilt += 1
	var new_chunks := {}
	for ch in dirty_chunks:
		if slice_ms > 0.0 and (Time.get_ticks_usec() - slice_t) / 1000.0 > slice_ms:
			work_ms += (Time.get_ticks_usec() - slice_t) / 1000.0
			await get_tree().process_frame
			frames += 1
			slice_t = Time.get_ticks_usec()
		var merged := _new_buffers()
		for k in _hexes:
			var h: Dictionary = _hexes[k]
			if h["chunk"] != ch:
				continue
			for kind in h["B"]:
				if not merged.has(kind):
					merged[kind] = [[], []]
				merged[kind][0].append_array(h["B"][kind][0])
				merged[kind][1].append_array(h["B"][kind][1])
		var cn := Node3D.new()
		cn.name = "Chunk_%d_%d_n" % [ch.x, ch.y]
		cn.visible = false
		add_child(cn)
		var tc := Time.get_ticks_usec()
		_flush_into(merged, cn)
		var n_inst := 0
		for kind in merged:
			n_inst += (merged[kind][0] as Array).size()
		_max_chunk = maxf(_max_chunk, (Time.get_ticks_usec() - tc) / 1000.0)
		_chunk_inst = maxi(_chunk_inst, n_inst)
		new_chunks[ch] = cn
	# ---- the swap: one frame, old out, new in
	for ch in new_chunks:
		if _chunks.has(ch) and is_instance_valid(_chunks[ch]):
			old_nodes.append(_chunks[ch])
		_chunks[ch] = new_chunks[ch]
		new_nodes.append(new_chunks[ch])
	for n in old_nodes:
		if is_instance_valid(n):
			(n as Node).free()
	for ch in new_chunks:
		(new_chunks[ch] as Node).name = "Chunk_%d_%d" % [ch.x, ch.y]
	for n in new_nodes:
		if is_instance_valid(n):
			(n as Node3D).visible = true
	R.city_anchors.clear()
	for c in map.cities:
		var ap: Vector2 = c["pos"]
		if not map.is_land(TerrainMath.world_to_offset(ap)):
			ap = TerrainMath.offset_center(int(c["q"]), int(c["r"]))
		R.city_anchors.append({"pos": Vector3(ap.x, R.height_at(ap.x, ap.y), ap.y), "city": c})
	work_ms += (Time.get_ticks_usec() - slice_t) / 1000.0
	stats = "%d/%d hexes rebuilt, %d chunks, global %s, %d ms" % [rebuilt, map.urban.size(), dirty_chunks.size(),
		"rebuilt" if _global_sig_changed else "kept", int(work_ms)]
	if frames > 1:
		stats += " over %d frames (%d ms)" % [frames, Time.get_ticks_msec() - t0]
	stats += "; slowest hex %.0f ms (%s), slowest chunk %.0f ms, max %d instances" % [_max_hex[0], _max_hex[1], _max_chunk, _chunk_inst]
	_max_hex = [0.0, ""]
	_max_chunk = 0.0
	_chunk_inst = 0


const GLOBAL_FP := Vector2i(-99999, -99999)   # perf60: the owner tag of landmark / harbour footprints


func _tag_fp(from: int, owner: Vector2i) -> void:
	## perf60: footprints appended since index `from` belong to owner (a hex, or GLOBAL_FP): [centre, radius, owner]
	for i in range(from, footprints.size()):
		var f: Array = footprints[i]
		if f.size() < 3:
			f.append(owner)


func _drop_fp(owner: Vector2i) -> void:
	footprints = footprints.filter(func(f): return f.size() < 3 or f[2] != owner)


func _global_signature() -> String:
	var s := ""
	for lm in LANDMARKS:
		s += "0" if _asset(lm[0]).is_empty() else "1"
	s += "|%d" % (1 if map.year >= 2001 else 0)
	for p in map.places:
		if p.get("kind", "") == "port":
			var spec: Array = PORTS.get(p.get("name", ""), [0, "small"])
			s += "1" if map.year >= int(spec[0]) else "0"
	s += "|%d|%d|%d" % [1 if map.year >= 1939 else 0, 1 if map.year >= 1975 else 0,
		1 if (map.jaffa_hex.x >= 0 and map.urban.has(map.jaffa_hex)) else 0]
	s += "|" + str(_asset("city_modern_tlv").is_empty())
	for c in map.cities:
		if c["id"] in ["tel_aviv", "haifa", "acre"]:
			s += c["id"]
	return s


func _hex_signature(k: Vector2i, city: Dictionary) -> String:
	# the year bucket is staggered per hex so redevelopment spreads over the decades instead of one turn
	var stagger := int(TerrainMath.hash2u(k.x, k.y) % 8)
	var bucket := int((map.year + stagger) / 8)
	if not _cbd_at(k).is_empty():
		bucket = int((map.year + stagger) / 4)
	var fps: Array = []
	var c := TerrainMath.offset_center(k.x, k.y)
	for f in footprints:
		if f.size() >= 3 and f[2] == k:
			continue   # perf60: never its own footprints (they are rebuilt with it)
		if (f[0] as Vector2).distance_to(c) < 1.0 + float(f[1]):
			fps.append("%.2f,%.2f,%.2f;" % [f[0].x, f[0].y, f[1]])
	fps.sort()   # (order-free: a neighbour rebuilt later moves its footprints to the end of the list)
	var fp := "".join(PackedStringArray(fps))
	return "%s|%s|%d|%d|%s|%d|%s|%s" % [city.get("id", ""), city.get("control", ""), int(map.urban[k]),
		int(float(city.get("pop", 0)) / 8000.0), _profile(city, k), bucket, map.district.get(k, "") + ("|core" if map.core.has(k) else ""), fp]


func _flush_into(buf: Dictionary, parent: Node3D) -> void:
	for k in buf:
		if str(k).begins_with("art:"):
			var bits := str(k).split(":")
			var part: Dictionary = ArtKit.get_parts(bits[1])[int(bits[2])]
			var n0 := parent.get_child_count()
			R.mm(part["mesh"], buf[k][0], buf[k][1], part["mat"], k, parent)
			for ci in range(n0, parent.get_child_count()):
				var g := parent.get_child(ci) as MultiMeshInstance3D
				if g == null:
					continue
				g.set_meta("art_part", [bits[1], int(bits[2])])
				_art_ranges(g, ArtKit.far_mesh(bits[1], int(bits[2])), ArtKit.mid_mesh(bits[1], int(bits[2])))
		else:
			R.mm(_meshes[k], buf[k][0], buf[k][1], _mats[k], k, parent, not (k in ["palm", "tree", "cypress", "pine", "olive", "citrus", "bougainvillea", "rock"]) and not _web_shadow_subset())


const WEB_TALL := 0.45   # web "shadow_subset": a kit building part at least this tall (world units) casts a shadow


static func _web_shadow_subset() -> bool:
	## web (GfxTier lever shadow_subset): sun shadows from the tall kit buildings only (a part whose top is WEB_TALL up), from their near range; the small
	## buildings and the procedural blocks cast none
	return GfxTier.web() and bool(GfxTier.levers.get("shadow_subset", false))


static var art_mid := 0.0          # perf60 (GfxTier lever art_mid): the mid LOD drawn from this distance (0 = none)
static var shadow_proxy := true    # perf60 (GfxTier lever shadow_proxy): kit buildings cast their shadow from the mid LOD
static var shadow_far := false     # perf60 (GfxTier lever shadow_far): ... from the far LOD (lighter tiers)


func _art_ranges(g: MultiMeshInstance3D, far_mesh: Mesh, mid_mesh: Mesh = null) -> void:
	## perf60: kit-building LODs for one chunk MultiMesh (ArtKit.build_far: welded meshoptimizer LODs):
	##   full model up to ART_NEAR (or up to art_mid, then the mid LOD to ART_NEAR, in the lighter tiers),
	##   the far LOD (about a tenth of the triangles) from ART_NEAR to the preset's art range,
	##   and the shadows of the near range cast by the mid LOD (a shadows-only twin): the shadow passes drew every full
	##   model again in each split (45 million triangles a frame in Tel Aviv 2023 in HD).
	## Without LODs (not ready yet, --art-lod=off, headless) the old single range.
	var rng_end := float(Quality.current()["art_range"])
	if far_mesh == null or "--art-lod=off" in OS.get_cmdline_user_args() or DisplayServer.get_name() == "headless":
		if rng_end > 0.0:
			# HLOD: art buildings drop out far from the camera (procedural boxes, roofs and trees remain)
			g.visibility_range_end = rng_end
			g.visibility_range_end_margin = 4.0
		return
	var casts: bool = g.get_meta("art_cast") if g.has_meta("art_cast") else g.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	g.set_meta("art_cast", casts)
	var subset := _web_shadow_subset()
	if subset and casts and g.multimesh != null and g.multimesh.mesh != null:
		casts = g.multimesh.mesh.get_aabb().end.y >= WEB_TALL   # (web "shadow_subset": only the tall kit buildings cast)
	var mid_from := art_mid if (art_mid > 0.0 and mid_mesh != null and art_mid < ART_NEAR) else ART_NEAR
	g.visibility_range_begin = 0.0
	g.visibility_range_end = mid_from + 0.25   # (a small overlap and no margins: see TreeKit._ranges)
	g.visibility_range_end_margin = 0.0
	var proxy := shadow_proxy and casts and mid_mesh != null
	g.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if proxy or not casts else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	var add := func(nm: String, mesh: Mesh, b: float, e: float, cast: int) -> void:
		var f := MultiMeshInstance3D.new()
		f.name = nm + str(g.name)
		f.multimesh = TreeKit._clone(g.multimesh, mesh)
		f.material_override = g.material_override
		f.cast_shadow = cast
		f.visibility_range_begin = maxf(b - 0.25, 0.0) if b > 0.0 else 0.0
		f.visibility_range_begin_margin = 0.0
		if e > 0.0:
			f.visibility_range_end = e + (0.25 if e < rng_end or rng_end <= 0.0 else 0.0)
			f.visibility_range_end_margin = 0.0 if e < rng_end or rng_end <= 0.0 else 4.0
		f.set_meta("art_lod", true)
		g.get_parent().add_child(f)
	var on := GeometryInstance3D.SHADOW_CASTING_SETTING_ON if casts else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if mid_from < ART_NEAR:
		add.call("mid_", mid_mesh, mid_from, ART_NEAR, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if proxy else on)
	if proxy:
		add.call("shp_", far_mesh if shadow_far else mid_mesh, 0.0, ART_NEAR, GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY)
	add.call("far_", far_mesh, ART_NEAR, rng_end, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if subset else on)
	g.set_meta("art_far", true)


func relod() -> void:
	## perf60: the LOD levers changed (GfxTier: art_mid, shadow_proxy): redo every chunk's kit-building LODs, live
	if DisplayServer.get_name() == "headless":
		return
	for ch in _chunks.values():
		if not is_instance_valid(ch):
			continue
		for c in (ch as Node).get_children():
			if c.has_meta("art_lod"):
				c.free()
		for g in (ch as Node).get_children():
			if g is MultiMeshInstance3D and g.has_meta("art_part") and g.has_meta("art_far"):
				g.remove_meta("art_far")
				var ap: Array = g.get_meta("art_part")
				_art_ranges(g as MultiMeshInstance3D, ArtKit.far_mesh(str(ap[0]), int(ap[1])), ArtKit.mid_mesh(str(ap[0]), int(ap[1])))


var _lod_serial := -1


func upgrade_lods(slice_ms := 4.0) -> void:
	## perf60: far LODs that arrived from the warm-up thread after their chunks were built: add them (a coroutine)
	if _lod_serial == ArtKit.far_serial or DisplayServer.get_name() == "headless":
		return
	_lod_serial = ArtKit.far_serial
	var st := Time.get_ticks_usec()
	var n := 0
	for ch in _chunks.values().duplicate():
		if not is_instance_valid(ch):
			continue
		for g in (ch as Node).get_children():
			if not g is MultiMeshInstance3D or not g.has_meta("art_part") or g.has_meta("art_far"):
				continue
			var ap: Array = g.get_meta("art_part")
			var fm := ArtKit.far_mesh(str(ap[0]), int(ap[1]))
			if fm != null:
				_art_ranges(g as MultiMeshInstance3D, fm, ArtKit.mid_mesh(str(ap[0]), int(ap[1])))
				n += 1
		if slice_ms > 0.0 and (Time.get_ticks_usec() - st) / 1000.0 > slice_ms:
			await get_tree().process_frame
			st = Time.get_ticks_usec()
	if n > 0:
		print("render: %d kit-building chunks got their far LOD" % n)


# ---------------------------------------------------------------- primitives

func _cd(style: int, col: Color) -> Color:
	return Color(col.r * 0.5, col.g * 0.5, col.b * 0.5, (style + 0.5) / 10.0)


func _bldg(p: Vector2, w: float, d: float, h: float, style: int, col: Color, yaw := 0.0, mesh := "box") -> float:
	## returns the roof height (world y)
	var y := minf(minf(R.height_at(p.x - w * 0.5, p.y - d * 0.5), R.height_at(p.x + w * 0.5, p.y - d * 0.5)),
		minf(R.height_at(p.x - w * 0.5, p.y + d * 0.5), R.height_at(p.x + w * 0.5, p.y + d * 0.5)))
	var b := Basis(Vector3.UP, yaw).scaled(Vector3(w, h + SINK, d))
	B[mesh][0].append(Transform3D(b, Vector3(p.x, y - SINK, p.y)))
	B[mesh][1].append(_cd(style, col))
	return y + h


func _roof(p: Vector2, w: float, d: float, y: float, yaw := 0.0) -> void:
	var b := Basis(Vector3.UP, yaw).scaled(Vector3(w * 1.08, minf(w, d) * 0.42, d * 1.08))
	B["roof"][0].append(Transform3D(b, Vector3(p.x, y - 0.002, p.y)))
	var c := Color(1.0, 1.0, 1.0).lerp(Color(0.85, 0.8, 0.78), rng.randf())
	B["roof"][1].append(_cd(S_TILES, c))


func _dome(p: Vector2, r: float, y: float, col: Color) -> void:
	B["dome"][0].append(Transform3D(Basis.IDENTITY.scaled(Vector3(r * 2, r * 2, r * 2)), Vector3(p.x, y - r * 0.15, p.y)))
	B["dome"][1].append(_cd(S_PLAIN, col))


func _tree(kind: String, p: Vector2, s: float) -> void:
	if kind == "palm" and TerrainMath.hash2(int(p.x * 97.0), int(p.y * 89.0)) < 0.2 + 0.35 * _year_t(1950, 1990):
		kind = "fanpalm"   # v5 trees: Washingtonia fan palms on the streets and promenades (by position: no RNG draw)
		s *= 1.05
	B[kind][0].append(R.tree_xf(p, s))
	B[kind][1].append(R.tint(Color.WHITE))


func _city_tree(p: Vector2, s := 0.7) -> void:
	var e := R.tile_elev(p)
	if e < R.PALM_MAX_ELEV and rng.randf() < 0.45:
		_tree("palm", p, s * 0.8)
	elif e >= R.PALM_MAX_ELEV and rng.randf() < 0.4:
		_tree("cypress" if rng.randf() < 0.6 else "pine", p, s)
	else:
		_tree("tree", p, s)


func in_footprint(p: Vector2) -> bool:
	## public: landmark / harbour footprints and old-town fabric (MapView keeps units off these)
	if map and map.district.get(TerrainMath.world_to_offset(p), "") in ["old", "old_city"]:
		return true
	return _in_footprint(p)


func _in_footprint(p: Vector2) -> bool:
	for f in footprints:
		if p.distance_to(f[0]) < f[1]:
			return true
	return false


static func _in_hex(lp: Vector2, r: float) -> bool:
	var ax := absf(lp.x); var az := absf(lp.y)
	return ax <= r * 0.866 and az <= r - ax * 0.577


# ---------------------------------------------------------------- city fabric (street blocks)
# Every urban hex is covered by a global grid of street blocks (period PX x PZ, streets SW wide incl.
# sidewalks; terrain.gdshader paints the same grid). Each block is filled edge to edge by two rows of
# 2-4 lots fronting the streets, with a courtyard between the rows. Modules depend on region and date.

const PX := 0.6
const PZ := 0.5
const SW := 0.08
# Central business districts: [lat, lon, first tower year, glass from year, max towers in the hex]
const CBD := [
	[32.0700, 34.7760, 1965, 1999, 3],   # Tel Aviv centre (Shalom Meir Tower 1965)
	[32.0745, 34.7920, 1985, 1999, 1],   # Azrieli / HaShalom
	[32.0835, 34.8020, 1990, 2000, 2],   # Ramat Gan Diamond Exchange district
	[32.8197, 35.0006, 1999, 2002, 1],   # Haifa downtown (Sail Tower 2002)
]


func _profile(c: Dictionary, k: Vector2i) -> String:
	var dist: String = map.district.get(k, "")
	if dist != "":
		return dist
	var id: String = c.get("id", "")
	var kind: String = c.get("kind", "")
	if id == "jerusalem":
		return "jerusalem"
	if id in OLD_TOWNS and Vector2i(c["q"], c["r"]) == k:
		return "old"
	if kind.contains("arab") or kind.contains("palestin") or kind.contains("druze") or kind.contains("bedouin") or kind.contains("syrian") or c.get("control", "") in ["jordan", "egypt", "syria", "palestine", "hamas", "contested"]:
		return "old"
	if kind in ["kibbutz", "moshav"]:
		return "village"
	var f: String = c.get("founded", "")
	if f != "" and int(f.substr(0, 4)) >= 1949 and int(f.substr(0, 4)) <= 1965 and not kind.begins_with("settlement"):
		return "devtown"
	if int(c.get("pop", 0)) < 25000:
		return "town"
	return "modern"


func _cbd_at(k: Vector2i) -> Array:
	for c in CBD:
		if map.latlon_to_offset(c[0], c[1]) == k and map.year >= int(c[2]):
			return c
	return []


func _build_hex(k: Vector2i, city: Dictionary) -> String:
	var center := TerrainMath.offset_center(k.x, k.y)
	var prof := _profile(city, k)
	var full: bool = int(map.urban[k]) >= 2
	var radius := 0.98 if full else clampf(0.4 + float(city.get("pop", 0)) / 40000.0 * 0.55, 0.4, 0.9)
	if prof in ["old", "old_city"]:
		radius = maxf(radius, 0.88)
	match prof:
		"old":
			map.district[k] = "old"
			_old_town(center, radius, city, k)
		"old_city":
			_old_city(center, city, k)
		"village":
			_village(center, city, Vector2i(city["q"], city["r"]) == k)
		_:
			if prof == "devtown" and map.year < int(str(city.get("founded", "1950")).substr(0, 4)) + 8:
				_maabara(center, radius * 0.75)
			elif not full and float(city.get("pop", 0)) < 15000:
				_small_town(center, city, prof)
			else:
				_blocks(k, center, radius, city, prof, Rect2())
	# beach promenade palms
	if map.tile_at(k).get("coast", false) and prof != "old":
		for i in 18:
			var q := R.rand_in_hex(center, 1.0)
			var hq := R.height_at(q.x, q.y)
			if hq > 0.03 and hq < 0.07 and R.tile_elev(q) < R.PALM_MAX_ELEV and not _in_footprint(q):
				_tree("palm", q, rng.randf_range(0.6, 0.8))
	return prof


func _small_town(center: Vector2, city: Dictionary, prof: String) -> void:
	## Towns under ~15,000 people, or without a sourced population yet: a main street and a cross street
	## lined with houses and small blocks, gardens and trees (never an empty hex).
	var cpos: Vector2 = city.get("pos", center)
	var ck := TerrainMath.world_to_offset(center)
	if TerrainMath.world_to_offset(cpos) != ck:
		cpos = center
	var pop := float(city.get("pop", 0))
	var n := int(clampf(12.0 + pop / 500.0, 12.0, 40.0))
	var yaw := rng.randf() * PI
	var dir := Vector2(cos(yaw), sin(yaw))
	var side := Vector2(-dir.y, dir.x)
	var placed := 0
	var tries := 0
	var y := map.year
	while placed < n and tries < n * 6:
		tries += 1
		var along := rng.randf_range(-0.6, 0.6)
		var cross := rng.randf() < 0.35
		var off := rng.randf_range(0.05, 0.13) * (1.0 if rng.randf() < 0.5 else -1.0)
		var p := cpos + (side * along + dir * off if cross else dir * along + side * off)
		if R.height_at(p.x, p.y) < 0.035 or _in_footprint(p) or TerrainMath.world_to_offset(p) != ck:
			continue
		var w := rng.randf_range(0.07, 0.1)
		var d := rng.randf_range(0.06, 0.09)
		var r := rng.randf()
		var ang := -dir.angle()
		if prof == "devtown" and r < 0.6:
			_bldg(p, w * 1.6, d, 4 * STOREY, S_SHIKUN, Color(0.95, 0.94, 0.9), ang)
		elif r < 0.55 or y < 1960:
			var col: Color = [Color(1.0, 0.97, 0.9), Color(1.0, 0.93, 0.82), Color(0.98, 0.9, 0.85)][rng.randi() % 3]
			var top := _bldg(p, w, d, rng.randi_range(1, 2) * STOREY, S_PLASTER, col, ang)
			_roof(p, w, d, top, ang)
		else:
			var top := _bldg(p, w * 1.2, d * 1.1, rng.randi_range(2, 4) * STOREY, S_BAUHAUS, Color(1, 1, 1), ang)
			_roof_clutter(p, w, d, top, y)
		if rng.randf() < 0.5:
			_street_tree(p + side * 0.05, prof)
		placed += 1


func _year_t(a: float, b: float) -> float:
	return clampf((float(map.year) - a) / (b - a), 0.0, 1.0)


func _blocks(k: Vector2i, center: Vector2, radius: float, city: Dictionary, prof: String, exclude: Rect2) -> void:
	## Per-hex lot layout: a street lattice (PX x PZ lots, SW streets; terrain.gdshader paints the same grid)
	## gives ~6-12 lots per hex. Each lot holds 2-4 buildings from the era/region kit around a garden,
	## so ~40 % of every lot stays green. One plaza per city core.
	var cpos: Vector2 = city.get("pos", center)
	var is_core := Vector2i(city["q"], city["r"]) == k
	var cbd := _cbd_at(k)
	_core_hex = map.core.has(k)
	var budget := int(cbd[4]) if not cbd.is_empty() else 0
	var density := 1.0 if is_core else 0.92
	if prof == "town":
		density = 0.75
	var i0 := int(floor((center.x - 1.0) / PX)); var i1 := int(ceil((center.x + 1.0) / PX))
	var j0 := int(floor((center.y - 1.0) / PZ)); var j1 := int(ceil((center.y + 1.0) / PZ))
	var plaza := Vector2i(int(floor(cpos.x / PX)), int(floor(cpos.y / PZ)))
	var gaps := []
	for i in range(i0, i1 + 1):
		for j in range(j0, j1 + 1):
			var bc := Vector2((i + 0.5) * PX, (j + 0.5) * PZ)
			if TerrainMath.world_to_offset(bc) != k or not _in_hex(bc - center, radius):
				continue
			var rect := Rect2(i * PX + SW * 0.5, j * PZ + SW * 0.5, PX - SW, PZ - SW)
			if exclude.has_area() and exclude.intersects(rect.grow(0.02)):
				continue
			if _in_footprint(bc) or R.height_at(bc.x, bc.y) < 0.035:
				continue
			_street_trees(rect, prof)
			if is_core and Vector2i(i, j) == plaza:
				_plaza_block(rect, prof)
			elif TerrainMath.hash2(i * 7 + 3, j * 13 + 1) < (0.04 if is_core else 0.07):
				_park_block(rect, prof)
			else:
				budget = _lot(rect, prof, city, cbd, density, budget, gaps)
	# 3-6 palms / cypresses in the gaps between lots
	gaps.shuffle()
	for g in gaps.slice(0, rng.randi_range(3, 6)):
		_street_tree(g, prof)


const KIT := {
	# [id, from year, weight]; ids are art-builder metre-scale models (MANIFEST.json); "proc_*" = procedural kit
	"modern": [["r3_bauhaus_corner", 1933, 3.0], ["r3_bauhaus_long", 1934, 3.0], ["r3_bauhaus_cube", 1935, 3.0], ["bld_bauhaus_b", 1932, 1.5],
		["bld_bauhaus_c", 1935, 1.5], ["bld_bauhaus_d", 1933, 1.0], ["proc_bauhaus", 0, 1.0], ["r3_shikun_pilotis", 1952, 1.2],
		["r3_shikun_stepped", 1958, 1.0], ["r3_block8_a", 1968, 1.0], ["r3_block8_b", 1978, 1.0], ["r3_block8_c", 1990, 1.2], ["proc_house", 0, 0.4]],
	"devtown": [["r3_devtown_a", 1957, 3.0], ["r3_devtown_b", 1957, 3.0], ["r3_devtown_c", 1965, 1.5], ["r3_shikun_l", 1950, 2.0],
		["r3_shikun_pilotis", 1952, 1.5], ["r3_block8_a", 1975, 1.0], ["r3_block8_c", 1992, 0.8]],
	"town": [["proc_house", 0, 2.5], ["r3_bauhaus_cube", 1935, 1.5], ["r3_bauhaus_long", 1934, 1.0], ["r3_shikun_l", 1950, 1.0],
		["r3_devtown_a", 1960, 0.8], ["r3_block8_c", 1995, 0.6]],
	"jerusalem": [["r3_jer_flat_3", 1930, 3.0], ["r3_jer_flat_5", 1960, 2.5], ["r3_jer_flat_6t", 1970, 1.5], ["jer_apartment_a", 1920, 1.5],
		["jer_apartment_b", 1920, 1.5], ["r3_arab_courtyard", 0, 1.2], ["proc_stone", 0, 0.6]],
	"templer": [["r3_templer_house_a", 1870, 3.0], ["r3_templer_house_b", 1870, 3.0]],
	"old": [["r3_arab_dome_cluster", 0, 3.0], ["r3_arab_courtyard", 0, 2.5], ["r3_arab_tall_narrow", 0, 2.0]],
}
# German Templer colonies: the only places with red-tiled Templer houses [lat, lon]
const TEMPLER := [[32.0720, 34.7870], [32.8180, 34.9900], [31.7630, 35.2190], [32.0340, 34.8750]]
# CBD glass towers by era (setback crowns); before 2000 the concrete tower
const TOWERS := [["r3_glass_setback_c", 2000], ["r3_glass_setback_a", 2005], ["r3_glass_setback_b", 2015]]
const STONE_TINT := Color(1.06, 0.96, 0.8)
const WHITEWASH := {"r3_bauhaus_corner": 0.6, "r3_bauhaus_long": 0.5, "r3_bauhaus_cube": 0.6,
	"bld_bauhaus_block": 1.0, "bld_bauhaus_b": 1.0, "bld_bauhaus_c": 1.0, "bld_bauhaus_d": 1.0,
	"bld_white_block_5070": 0.85, "bld_shikun_block": 0.7, "bld_concrete_tower_7090": 0.4,
	# Jerusalem limestone / sandstone: lift toward pale cream (tint warms it)
	"jer_apartment_a": 0.3, "jer_apartment_b": 0.3, "jer_apartment_c": 0.3, "bld_arab_stone_house": 0.4, "bld_jaffa_old_house": 0.35,
	"r3_jer_flat_3": 0.5, "r3_jer_flat_5": 0.5, "r3_jer_flat_6t": 0.5, "r3_arab_dome_cluster": 0.35, "r3_arab_courtyard": 0.35,
	"r3_arab_tall_narrow": 0.35, "old_house_jaffa": 0.3, "old_house_akko": 0.3, "old_house_nazareth": 0.3}


func _pick_kit(prof: String) -> String:
	var opts: Array = KIT.get(prof, KIT["modern"])
	var tot := 0.0
	var cand := []
	for o in opts:
		if map.year < int(o[1]):
			continue
		var wgt := float(o[2])
		if str(o[0]) in ["bld_white_block_5070", "proc_slab", "bld_shikun_block"]:
			wgt *= 0.3 + _year_t(1955, 1990)
		if not str(o[0]).begins_with("proc_") and ArtKit.get_parts(o[0]).is_empty():
			continue
		cand.append([o[0], wgt]); tot += wgt
	var r := rng.randf() * tot
	for c in cand:
		r -= c[1]
		if r <= 0.0:
			return c[0]
	return "proc_bauhaus"


func _lot(rect: Rect2, prof: String, city: Dictionary, cbd: Array, density: float, budget: int, gaps: Array) -> int:
	var y := map.year
	# CBD: one tower per lot while the city's tower budget lasts (real skylines only)
	if budget > 0 and rng.randf() < 0.6:
		var glass := y >= int(cbd[3])
		var tc := rect.get_center() + Vector2(rng.randf_range(-0.05, 0.05), rng.randf_range(-0.04, 0.04))
		var h := (0.75 if glass else 0.5) * rng.randf_range(0.85, 1.15)
		var tid := "bld_concrete_tower_7090"
		if glass:
			var opts := []
			for t in TOWERS:
				if y >= int(t[1]):
					opts.append(t[0])
			tid = opts[rng.randi() % opts.size()] if not opts.is_empty() else "bld_glass_tower_2000s"
		if not _kit_place(tid, tc, _yaw4(), 0.22, 1.0, Color(1, 1, 1), h):
			_bldg(tc, 0.16, 0.16, h, S_GLASS if glass else S_SHIKUN, Color(0.85, 0.9, 0.98))
		budget -= 1
		for s in 2:
			var q := rect.get_center() + Vector2((s - 0.5) * rect.size.x * 0.62, rect.size.y * 0.28)
			_building(q, minf(rect.size.x * 0.34, 0.2), prof, city)
		return budget
	var half := rect.size * 0.5
	if _core_hex and false:
		# (round 6 dense core: read as a white sea; gardens between buildings beat density)
		for o in [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)]:
			var p := rect.get_center() + Vector2(o.x * half.x * 0.52, o.y * half.y * 0.5) + Vector2(rng.randf_range(-0.008, 0.008), rng.randf_range(-0.008, 0.008))
			if R.height_at(p.x, p.y) >= 0.03 and not _in_footprint(p):
				_building(p, minf(half.x, half.y) * 0.98, prof, city)
		for m in rng.randi_range(1, 2):
			var p := rect.get_center() + Vector2(rng.randf_range(-0.1, 0.1) * rect.size.x, (half.y * 0.55) * (1.0 if m == 0 else -1.0))
			if R.height_at(p.x, p.y) >= 0.03 and not _in_footprint(p):
				_building(p, minf(half.x, half.y) * 0.7, prof, city)
		return budget
	# 2-4 buildings on the lot corners, the rest is garden
	var slots := [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)]
	slots.shuffle()
	var nb := 4 if rng.randf() < 0.35 else (3 if rng.randf() < 0.7 else 2)
	for si in 4:
		var o: Vector2 = slots[si]
		var p := rect.get_center() + Vector2(o.x * half.x * 0.5, o.y * half.y * 0.5) + Vector2(rng.randf_range(-0.012, 0.012), rng.randf_range(-0.012, 0.012))
		if si >= nb or rng.randf() > density:
			gaps.append(p)
			for g in 3:
				_garden_plant(p + Vector2(rng.randf_range(-0.06, 0.06), rng.randf_range(-0.05, 0.05)), prof)
			continue
		if R.height_at(p.x, p.y) < 0.03 or _in_footprint(p):
			continue
		_building(p, minf(half.x, half.y) * 0.95, prof, city)
	return budget


const PLASTER := [Color(1.12, 1.11, 1.08), Color(1.1, 1.02, 0.86), Color(1.06, 0.92, 0.72), Color(1.02, 0.84, 0.62),
	Color(1.06, 0.82, 0.52), Color(1.08, 0.88, 0.62), Color(1.06, 0.86, 0.78), Color(0.98, 0.9, 0.78)]


func _garden_plant(p: Vector2, prof: String) -> void:
	if R.height_at(p.x, p.y) < 0.03 or _in_footprint(p):
		return
	var r := rng.randf()
	if prof == "jerusalem" or R.tile_elev(p) >= R.PALM_MAX_ELEV:
		_street_tree(p, prof)
	elif r < 0.3:
		_tree("palm", p, rng.randf_range(0.55, 0.75))
	elif r < 0.55:
		_tree("tree", p, rng.randf_range(0.6, 0.85))        # ficus / plane
	elif r < 0.8:
		_tree("citrus", p, rng.randf_range(0.8, 1.0))
	elif r < 0.88:
		_tree("tree", p, rng.randf_range(0.55, 0.75))
	else:
		_tree("bougainvillea", p, rng.randf_range(0.45, 0.6))


func _plaster(id: String) -> Color:
	## cream, sand, tan, pale ochre, warm stone: Bauhaus-era buildings lean white/cream, later blocks warmer
	var r := rng.randf()
	if id.contains("bauhaus"):
		return PLASTER[0] if r < 0.45 else PLASTER[1 + rng.randi() % 3]
	return PLASTER[rng.randi() % PLASTER.size()]


func _in_templer(p: Vector2) -> bool:
	for t in TEMPLER:
		if p.distance_to(_ll(t[0], t[1])) < 0.45:
			return true
	return false


func _building(p: Vector2, fit: float, prof: String, city: Dictionary) -> void:
	var id := _pick_kit("templer" if (prof != "jerusalem" or rng.randf() < 0.6) and _in_templer(p) else prof)
	var yaw := _yaw4() + rng.randf_range(-0.06, 0.06)
	var hj := rng.randf_range(0.85, 1.2)        # +-1 storey
	var white := _plaster(id)
	var tint: Color = Color(1.08, 1.0, 0.86) if (id.begins_with("jer_") or id.begins_with("r3_jer") or id.begins_with("r3_arab")) else (STONE_TINT if prof == "jerusalem" or id in ["bld_arab_stone_house", "bld_jaffa_old_house"] else white)
	tint = _jit(tint, 0.06)
	match id:
		"proc_bauhaus":
			_apt(p, fit, fit * 0.8, rng.randi_range(3, 4), S_BAUHAUS, white, map.year, "bauhaus")
		"proc_slab":
			_apt(p, fit, fit * 0.6, rng.randi_range(5, 8), S_PLASTER, white, map.year, "pilotis")
		"proc_shikun":
			_apt(p, fit, fit * 0.55, 4, S_SHIKUN, Color(0.96, 0.95, 0.92), map.year)
		"proc_house":
			_house(p, fit, fit * 0.8, false)
		"proc_villa":
			_house(p, fit, fit * 0.8, true)
		"proc_stone":
			var st := rng.randi_range(2, 3) if map.year < 1960 else rng.randi_range(3, 5)
			_apt(p, fit, fit * 0.85, st, S_STONE, Color(1, 0.97, 0.92), map.year)
		_:
			if not _kit_place(id, p, yaw, fit, hj, tint):
				_apt(p, fit, fit * 0.8, 3, S_BAUHAUS, white, map.year, "bauhaus")


const M2W_B := 0.016   # metres -> world for instanced art buildings (Civ-style: buildings read larger than true scale)


func _kit_place(id: String, p: Vector2, yaw: float, fit: float, hmul: float, tint: Color, abs_h := -1.0) -> bool:
	## instance an art-builder model (decimated, MultiMesh) at p, footprint fitted into `fit`;
	## height = true height * hmul, or abs_h world units if given
	var parts := ArtKit.get_parts(id)
	if parts.is_empty():
		return false
	var rm: Dictionary = CityBuilder.manifest()[id]["real_m"]
	var s := minf(M2W_B, fit / maxf(float(rm["w"]), float(rm["d"])))
	var sy := abs_h / float(rm["h"]) if abs_h > 0.0 else s * hmul
	var hw := float(rm["w"]) * s * 0.5
	var y := minf(R.height_at(p.x, p.y), minf(R.height_at(p.x + hw, p.y), R.height_at(p.x - hw, p.y)))
	var b := Basis(Vector3.UP, yaw) * Basis.from_scale(Vector3(s, sy, s))
	for i in parts.size():
		var key := "art:%s:%d" % [id, i]
		if not B.has(key):
			B[key] = [[], []]
		B[key][0].append(Transform3D(b, Vector3(p.x, y - 0.01, p.y)) * (parts[i]["xf"] as Transform3D))
		B[key][1].append(Color(tint.r * 0.5, tint.g * 0.5, tint.b * 0.5, float(WHITEWASH.get(id, 0.0))))
	art_count += 1
	return true


var _core_hex := false   # current hex is a dense urban core: packed lots, paved ground, a tree at every road edge


func _street_trees(rect: Rect2, prof: String) -> void:
	var o := 0.016
	var edges := [[rect.position + Vector2(0, -o), Vector2(1, 0), rect.size.x], [rect.position + Vector2(0, rect.size.y + o), Vector2(1, 0), rect.size.x],
		[rect.position + Vector2(-o, 0), Vector2(0, 1), rect.size.y], [rect.position + Vector2(rect.size.x + o, 0), Vector2(0, 1), rect.size.y]]
	for e in edges:
		var n := int(e[2] / 0.11)
		for s in range(1, n):
			if rng.randf() < 0.92:
				var p: Vector2 = e[0] + e[1] * s * 0.11
				if R.height_at(p.x, p.y) > 0.03 and not _in_footprint(p):
					_street_tree(p, prof)


func _street_tree(p: Vector2, prof: String) -> void:
	var e := R.tile_elev(p)
	if prof == "jerusalem" or e >= R.PALM_MAX_ELEV:
		var r := rng.randf()
		_tree("cypress" if r < 0.45 else ("pine" if r < 0.75 else "olive"), p, rng.randf_range(0.55, 0.7))
	elif rng.randf() < 0.5:
		_tree("palm", p, rng.randf_range(0.55, 0.7))
	else:
		_tree("tree", p, rng.randf_range(0.5, 0.65))


func _plaza_block(rect: Rect2, prof: String) -> void:
	var c := rect.get_center()
	footprints.append([c, minf(rect.size.x, rect.size.y) * 0.45])
	var y := R.height_at(c.x, c.y)
	B["fountain"][0].append(Transform3D(Basis.IDENTITY.scaled(Vector3(0.09, 0.035, 0.09)), Vector3(c.x, y - 0.005, c.y)))
	B["fountain"][1].append(_cd(S_PLAIN, Color(0.95, 0.93, 0.88)))
	for a in 8:
		var o := Vector2(cos(a * TAU / 8.0), sin(a * TAU / 8.0)) * Vector2(rect.size.x * 0.38, rect.size.y * 0.36)
		_street_tree(c + o, prof)
	# a public building on the north side (town hall / synagogue / church), stone with a dome
	var pb := Vector2(c.x, rect.position.y + 0.055)
	var top := _bldg(pb, rect.size.x * 0.55, 0.1, STOREY * 3, S_STONE, Color(1, 0.98, 0.93))
	if prof != "modern" or rng.randf() < 0.5:
		_dome(pb, 0.04, top, Color(0.9, 0.88, 0.82))


func _park_block(rect: Rect2, prof: String) -> void:
	for i in 12:
		var p := rect.position + Vector2(rng.randf() * rect.size.x, rng.randf() * rect.size.y)
		_street_tree(p, prof)


func _lots(width: float, nmin: int, nmax: int) -> Array:
	var n := rng.randi_range(nmin, nmax)
	var ws := []
	var tot := 0.0
	for i in n:
		var w := rng.randf_range(0.7, 1.3)
		ws.append(w); tot += w
	for i in n:
		ws[i] = ws[i] / tot * width
	return ws


func _jit(c: Color, a := 0.08) -> Color:
	var k := 1.0 + rng.randf_range(-a, a)
	return Color(c.r * k * (1.0 + rng.randf_range(-0.02, 0.02)), c.g * k, c.b * k * (1.0 + rng.randf_range(-0.02, 0.02)))


func _apt(p: Vector2, w: float, d: float, storeys: int, style: int, col: Color, y: int, kind := "") -> float:
	## one apartment building: body with colour/yaw jitter, parapet lip, roof clutter; returns roof y
	var yaw := rng.randf_range(-0.05, 0.05)
	var c := _jit(col)
	var h := storeys * STOREY + rng.randf_range(-0.004, 0.006)
	var top: float
	if kind == "pilotis":
		# 1960s-90s slab on pilotis: recessed dark ground floor, slab above
		var y0 := minf(R.height_at(p.x - w * 0.5, p.y), R.height_at(p.x + w * 0.5, p.y))
		_box_at(p, y0 - SINK, w * 0.86, STOREY + SINK, d * 0.7, S_FLAT, Color(0.36, 0.35, 0.33), yaw)
		_box_at(p, y0 + STOREY, w, h - STOREY, d, style, c, yaw)
		top = y0 + h
	else:
		top = _bldg(p, w, d, h, style, c, yaw)
	# parapet lip
	_box_at(p, top - 0.002, w + 0.006, 0.006, d + 0.006, S_PLAIN, _jit(c.lerp(Color(1, 1, 1), 0.3), 0.04), yaw)
	if kind == "bauhaus":
		# rounded corner balconies (Bauhaus / International Style)
		var corner := Vector2(w * 0.5 * (1.0 if rng.randf() < 0.5 else -1.0), d * 0.5).rotated(-yaw)
		var cr := minf(w, d) * 0.32
		var y0 := R.height_at(p.x, p.y)
		B["cyl"][0].append(Transform3D(Basis.IDENTITY.scaled(Vector3(cr * 2.0, top - y0 - STOREY * 0.35 + SINK, cr * 2.0)), Vector3(p.x + corner.x, y0 - SINK, p.y + corner.y)))
		B["cyl"][1].append(_cd(S_BAUHAUS, c))
	_roof_clutter(p, w, d, top, y)
	return top


func _house(p: Vector2, w: float, d: float, stone: bool) -> void:
	## one or two small houses on the lot, red tile roofs, a garden tree
	var n := 2 if w > 0.13 else 1
	for i in n:
		var hw := w / n - 0.012
		var hd := minf(d * 0.75, 0.1)
		var q := p + Vector2((i - (n - 1) * 0.5) * (w / n), -d * 0.5 + hd * 0.5 + 0.005)
		var col: Color = [Color(1.0, 0.97, 0.9), Color(1.0, 0.93, 0.82), Color(0.98, 0.9, 0.85), Color(0.95, 0.95, 0.9)][rng.randi() % 4]
		var top := _bldg(q, hw, hd, rng.randi_range(1, 2) * STOREY, S_STONE if stone else S_PLASTER, _jit(col), rng.randf_range(-0.06, 0.06))
		_roof(q, hw, hd, top)
	if rng.randf() < 0.8:
		_street_tree(p + Vector2(rng.randf_range(-0.3, 0.3) * w, d * 0.3), "modern")


func _roof_clutter(p: Vector2, w: float, d: float, top: float, y: int) -> void:
	if rng.randf() < 0.6:
		# stairwell / lift room
		var q := p + Vector2(rng.randf_range(-0.25, 0.25) * w, rng.randf_range(-0.25, 0.25) * d)
		_box_at(q, top - 0.003, w * 0.26, STOREY * 0.7, d * 0.26, S_PLAIN, Color(0.98, 0.97, 0.94))
	if rng.randf() < 0.5:
		# water tank on short legs
		var q := p + Vector2(rng.randf_range(-0.3, 0.3) * w, rng.randf_range(-0.3, 0.3) * d)
		B["cyl"][0].append(Transform3D(Basis.IDENTITY.scaled(Vector3(0.014, 0.012, 0.014)), Vector3(q.x, top + 0.004, q.y)))
		B["cyl"][1].append(_cd(S_FLAT, Color(0.86, 0.86, 0.84) if rng.randf() < 0.6 else Color(0.25, 0.27, 0.3)))
	if y >= 1960 and rng.randf() < 0.45:
		# solar water heaters (dud shemesh, mandatory on new homes from 1980)
		for i in rng.randi_range(1, 3):
			var q := p + Vector2(rng.randf_range(-0.35, 0.35) * w, rng.randf_range(-0.35, 0.35) * d)
			_box_at(q, top - 0.002, 0.018, 0.009, 0.013, S_FLAT, Color(0.2, 0.25, 0.33))
	if y >= 1975 and rng.randf() < 0.4:
		# AC units
		for i in rng.randi_range(1, 3):
			var q := p + Vector2(rng.randf_range(-0.4, 0.4) * w, rng.randf_range(-0.4, 0.4) * d)
			_box_at(q, top - 0.002, 0.008, 0.006, 0.006, S_FLAT, Color(0.88, 0.88, 0.86))


func _kit_xf(id: String, xf: Transform3D, tint: Color) -> bool:
	var parts := ArtKit.get_parts(id)
	if parts.is_empty():
		return false
	for i in parts.size():
		var key := "art:%s:%d" % [id, i]
		if not B.has(key):
			B[key] = [[], []]
		B[key][0].append(xf * (parts[i]["xf"] as Transform3D))
		B[key][1].append(Color(tint.r * 0.5, tint.g * 0.5, tint.b * 0.5, 0))
	return true


func _piece(id: String, p: Vector2, yaw: float, scale: float, y := 0.0, tint := Color(1, 1, 1)) -> bool:
	## art-builder metre-scale piece at true proportions: scale = world units per metre
	if _asset(id).is_empty() or ArtKit.get_parts(id).is_empty():
		return false
	return _kit_xf(id, Transform3D(Basis(Vector3.UP, yaw) * Basis.from_scale(Vector3.ONE * scale), Vector3(p.x, y, p.y)), tint)


func _box_at(p: Vector2, y: float, w: float, h: float, d: float, style: int, col: Color, yaw := 0.0) -> void:
	B["box"][0].append(Transform3D(Basis(Vector3.UP, yaw).scaled(Vector3(w, h, d)), Vector3(p.x, y, p.y)))
	B["box"][1].append(_cd(style, col))


func _old_town(center: Vector2, radius: float, city: Dictionary, k: Vector2i, inside := Rect2()) -> void:
	## dense limestone town packed edge to edge: courtyard houses, domes, a minaret, narrow alleys
	var cell := 0.08 if not inside.has_area() else 0.065
	var n := int(radius / cell) + 1
	var modern_mix := _year_t(1975, 2015) * (0.3 if city.get("control", "") != "israel" else 0.12)
	var minaret_done := false
	for i in range(-n, n + 1):
		for j in range(-n, n + 1):
			var lp := Vector2(i * cell, j * cell) + Vector2(rng.randf_range(-0.012, 0.012), rng.randf_range(-0.012, 0.012))
			var p := center + lp
			if inside.has_area():
				if not inside.has_point(p):
					continue
			elif not _in_hex(lp, radius):
				continue
			if _in_footprint(p) or R.height_at(p.x, p.y) < 0.03:
				continue
			# alleys: a few continuous lanes plus random courtyards
			if (i + 1000) % 6 == 0 or rng.randf() < 0.07:
				if rng.randf() < 0.25:
					_street_tree(p, "jerusalem" if R.tile_elev(p) > 300 else "old")
				continue
			var w := cell * rng.randf_range(0.92, 1.05); var d := cell * rng.randf_range(0.92, 1.05)
			var c := Color(1, 1, 1).lerp(Color(0.9, 0.84, 0.74), rng.randf())
			if rng.randf() < modern_mix:
				_bldg(p, w, d, rng.randi_range(3, 5) * STOREY, S_STONE, c)
				continue
			if rng.randf() < 0.55 and _kit_place(_old_module(city, k), p, _yaw4() + rng.randf_range(-0.1, 0.1), cell * 1.2, rng.randf_range(0.85, 1.15), _jit(STONE_TINT, 0.07)):
				continue
			var st := rng.randi_range(1, 3)
			var top := _bldg(p, w, d, st * STOREY, S_STONE, c)
			var rr := rng.randf()
			if rr < 0.12:
				_dome(p, minf(w, d) * 0.36, top, Color(0.95, 0.92, 0.85))
			elif rr < 0.18:
				_roof(p, w, d, top)
			elif rr < 0.3:
				_box_at(p + Vector2(w * 0.25, 0), top - 0.003, w * 0.4, STOREY * 0.8, d * 0.5, S_STONE, c)   # roof room
			if not minaret_done and lp.length() < 0.4 and rng.randf() < 0.12:
				minaret_done = true
				_minaret(p + Vector2(w * 0.6, 0), top)


func _old_module(city: Dictionary, k: Vector2i) -> String:
	var id: String = city.get("id", "")
	var r := rng.randf()
	if id == "acre" and r < 0.5:
		return "old_house_akko"
	if id == "nazareth" and r < 0.5:
		return "old_house_nazareth"
	if (id in ["jaffa", "tel_aviv"] or map.tile_at(k).get("coast", false)) and r < 0.45:
		return "old_house_jaffa"
	return ["r3_arab_dome_cluster", "r3_arab_courtyard", "r3_arab_tall_narrow", "bld_arab_stone_house"][rng.randi() % 4]


# 1949 armistice line through Jerusalem (approximate trace along the Old City's west wall, Mamilla,
# Musrara and Abu Tor), lat/lon
const JLM_LINE := [[31.8010, 35.2135], [31.7930, 35.2195], [31.7860, 35.2228], [31.7815, 35.2252], [31.7770, 35.2254],
	[31.7735, 35.2258], [31.7700, 35.2290], [31.7655, 35.2335], [31.7600, 35.2390]]


func _armistice_jerusalem() -> void:
	## Divided Jerusalem 1948-67: a half-hex-wide no-man's-land band of bare, cratered earth with concrete
	## barriers and wire along the line, a bold red-white dashed line on top, and labels.
	var pts := []
	for ll in JLM_LINE:
		pts.append(_ll(ll[0], ll[1]))
	for i in pts.size() - 1:
		var s0: Vector2 = pts[i]
		var s1: Vector2 = pts[i + 1]
		var dl := s0.distance_to(s1)
		var dd := (s1 - s0) / dl
		var nrm := Vector2(-dd.y, dd.x)
		var yaw := -nrm.angle() + PI * 0.5
		var mid := (s0 + s1) * 0.5
		var y0 := minf(R.height_at(s0.x, s0.y), R.height_at(s1.x, s1.y))
		# bare earth band (~0.45 world = half a hex) sunk into the slope
		_box_at(mid, y0 - 0.05, 0.5, 0.08, dl + 0.05, S_FLAT, Color(0.52, 0.38, 0.26), yaw)
		footprints.append([mid, 0.25])
		var n := int(dl / 0.02)
		for k in n:
			var q := s0 + dd * (k + 0.5) * dl / n
			var yq := R.height_at(q.x, q.y)
			# red-white dashes on the line itself
			_box_at(q, maxf(yq, y0 + 0.03) - 0.004, 0.05, 0.02, dl / n * 0.9, S_FLAT, Color(0.9, 0.08, 0.06) if k % 2 == 0 else Color(1, 1, 1), yaw)
			# craters and rubble
			for c in 2:
				var cq := q + nrm * rng.randf_range(-0.2, 0.2)
				var sz := rng.randf_range(0.008, 0.02)
				B["rock"][0].append(Transform3D(Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3(sz * 1.3, sz * 0.6, sz)), Vector3(cq.x, R.height_at(cq.x, cq.y) + 0.02, cq.y)))
				B["rock"][1].append(Color(0.36, 0.33, 0.3, 0))
			# concrete anti-sniper walls on both edges, wire posts
			for sg in [-1.0, 1.0]:
				var wq: Vector2 = q + nrm * sg * 0.2
				if k % 3 == 0:
					_box_at(wq, R.height_at(wq.x, wq.y) - 0.01, 0.012, 0.05, dl / n * 2.6, S_FLAT, Color(0.62, 0.6, 0.56), yaw)
				var pq: Vector2 = q + nrm * sg * 0.15
				_box_at(pq, R.height_at(pq.x, pq.y), 0.003, 0.025, 0.003, S_FLAT, Color(0.2, 0.18, 0.16))
	var c0: Vector2 = pts[pts.size() / 2]
	_label3d("1949 Armistice Line", c0 + Vector2(-0.2, 0.55), Color(1, 0.95, 0.9), 0.0034)
	_label3d("Jordanian-held", c0 + Vector2(0.85, -0.45), Color(1.0, 0.85, 0.7), 0.0036)


func _label3d(text: String, p: Vector2, col: Color, px: float) -> void:
	## world-space map label (visible in --no-hud captures; scales with the camera like the terrain)
	var l := Label3D.new()
	l.text = text
	l.font = UIKit.font("title")
	l.font_size = 64
	l.outline_size = 26
	l.modulate = col
	l.outline_modulate = Color(0.04, 0.03, 0.03, 0.92)
	l.pixel_size = px
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.fixed_size = true
	l.pixel_size = px * 0.1
	l.position = Vector3(p.x, R.height_at(p.x, p.y) + 0.45, p.y)
	l.add_to_group("map_area_label")
	(_parent if _parent else self).add_child(l)


func _ll(lat: float, lon: float) -> Vector2:
	return map.latlon_to_world(lat, lon)


func _old_city(center: Vector2, city: Dictionary, k: Vector2i) -> void:
	## Jerusalem's walled Old City (Ottoman walls, 1530s) with the Temple Mount / Haram al-Sharif platform;
	## the rest of the hex is ordinary Jerusalem stone blocks.
	var a := _ll(31.7815, 35.2265); var b := _ll(31.7735, 35.2380)
	var walls := Rect2(a, b - a)
	var tm_a := _ll(31.7810, 35.2340); var tm_b := _ll(31.7755, 35.2368)
	var mount := Rect2(tm_a, tm_b - tm_a)
	# walls with towers
	var corners := [walls.position, Vector2(walls.end.x, walls.position.y), walls.end, Vector2(walls.position.x, walls.end.y)]
	for e in 4:
		var p0: Vector2 = corners[e]; var p1: Vector2 = corners[(e + 1) % 4]
		var len := p0.distance_to(p1)
		var dir := (p1 - p0) / len
		var n := int(len / 0.1)
		var yaw := -dir.angle()
		var stone := Color(1.0, 0.9, 0.72)
		for s_ in n:
			# Ottoman curtain wall: art wall modules (crenellated Jerusalem stone), stretched per piece
			var q := p0 + dir * (s_ + 0.5) * len / n
			var y0 := minf(R.height_at(q.x, q.y), minf(R.height_at(q.x - dir.x * 0.05, q.y - dir.y * 0.05), R.height_at(q.x + dir.x * 0.05, q.y + dir.y * 0.05)))
			if not _kit_xf("jer_wall_straight", Transform3D(Basis(Vector3.UP, yaw) * Basis.from_scale(Vector3((len / n + 0.004) / 20.0, 0.15 / 12.3, 0.045 / 5.4)), Vector3(q.x, y0 - 0.035, q.y)), _jit(stone, 0.04)):
				_box_at(q, y0 - 0.04, len / n + 0.002, 0.15, 0.03, S_STONE, stone, yaw)
				for m in 5:
					var cq := q + dir * ((m - 2) * len / n / 5.0)
					_box_at(cq, y0 + 0.11, len / n / 9.0, 0.02, 0.034, S_STONE, stone, yaw)
		var cq0: Vector2 = corners[e]
		var cy := R.height_at(cq0.x, cq0.y)
		if not _kit_xf("jer_wall_corner", Transform3D(Basis(Vector3.UP, yaw) * Basis.from_scale(Vector3(0.075 / 15.5, 0.19 / 12.6, 0.075 / 14.0)), Vector3(cq0.x, cy - 0.035, cq0.y)), _jit(stone, 0.04)):
			_box_at(cq0, cy - 0.04, 0.07, 0.2, 0.07, S_STONE, stone, yaw)
	# 1948-67: the armistice line ran just outside the west and north walls: a no-man's-land strip of
	# rubble, concrete anti-sniper walls and wire between West Jerusalem and the Jordanian-held Old City
	if map.date >= "1948-05-28" and map.date < "1967-06-07":
		_armistice_jerusalem()
	# Temple Mount platform + al-Aqsa mosque (the Dome of the Rock is a landmark model)
	var mc := mount.get_center()
	var my := R.height_at(mc.x, mc.y)
	_box_at(mc, my - 0.04, mount.size.x, 0.07, mount.size.y, S_PLAIN, Color(0.98, 0.95, 0.88))
	var aq := _ll(31.7762, 35.2356)
	var at := _bldg(aq, 0.09, 0.05, STOREY * 1.3, S_STONE, Color(1, 0.97, 0.9))
	_dome(aq + Vector2(0, -0.012), 0.022, at, Color(0.45, 0.47, 0.5))
	for t in 6:
		_street_tree(mc + Vector2(rng.randf_range(-0.4, 0.4) * mount.size.x, rng.randf_range(-0.45, 0.45) * mount.size.y), "jerusalem")
	footprints.append([mc, minf(mount.size.x, mount.size.y) * 0.5])
	# Church of the Holy Sepulchre dome
	var hs := _ll(31.7785, 35.2296)
	var ht := _bldg(hs, 0.08, 0.07, STOREY * 2.2, S_STONE, Color(1, 0.96, 0.9))
	_dome(hs, 0.03, ht, Color(0.55, 0.57, 0.6))
	footprints.append([hs, 0.06])
	# dense quarters inside the walls
	_old_town(walls.get_center(), 1.0, city, k, walls.grow(-0.03))
	# modern Jerusalem around it
	# open ground around the walls (Hinnom and Kidron valleys, the 1948-67 no man's land): olive groves
	for i in 40:
		var q := walls.grow(0.2).position + Vector2(rng.randf(), rng.randf()) * walls.grow(0.2).size
		if not walls.grow(0.03).has_point(q) and not _in_footprint(q):
			_tree("olive" if rng.randf() < 0.7 else "cypress", q, rng.randf_range(0.55, 0.7))
	_blocks(k, center, 0.98, city, "jerusalem", walls.grow(0.2))


func _minaret(p: Vector2, base_y: float) -> void:
	var y0 := R.height_at(p.x, p.y)
	var h := 0.22
	B["cyl"][0].append(Transform3D(Basis.IDENTITY.scaled(Vector3(0.028, h + SINK, 0.028)), Vector3(p.x, y0 - SINK, p.y)))
	B["cyl"][1].append(_cd(S_PLAIN, Color(0.96, 0.93, 0.86)))
	B["cyl"][0].append(Transform3D(Basis.IDENTITY.scaled(Vector3(0.04, 0.012, 0.04)), Vector3(p.x, y0 + h * 0.8, p.y)))
	B["cyl"][1].append(_cd(S_PLAIN, Color(0.9, 0.86, 0.78)))
	B["cone"][0].append(Transform3D(Basis.IDENTITY.scaled(Vector3(0.03, 0.05, 0.03)), Vector3(p.x, y0 + h, p.y)))
	B["cone"][1].append(_cd(S_PLAIN, Color(0.55, 0.62, 0.6)))


func _village(center: Vector2, city: Dictionary, is_core: bool) -> void:
	if is_core and _diorama("city_kibbutz", city["pos"], 0.6, 0.0):
		var c2: Vector2 = city["pos"] + Vector2(0.45, 0.2)
		_art("bld_kibbutz_dining_hall", c2, _yaw4(), 0.3)
		_art("bld_kibbutz_water_tower", c2 + Vector2(-0.1, 0.32), 0.0, 0.0, 0.3)
		return
	for i in 14:
		var p := R.rand_in_hex(center, 0.5)
		var w := 0.07; var top := _bldg(p, w, w * 0.8, STOREY, S_PLASTER, Color(1, 0.97, 0.92))
		_roof(p, w, w * 0.8, top)
		_city_tree(p + Vector2(0.07, 0.03), 0.7)


func _maabara(center: Vector2, radius: float) -> void:
	## transit camp: rows of tin huts and tents (1949-1950s)
	_diorama("city_1948_maabara", center, 0.6, 0.3)
	for i in 10:
		var p := R.rand_in_hex(center, radius)
		if not _in_footprint(p):
			_kit_place("bld_maabara_tents", p, _yaw4(), 0.16, 1.0, Color(1, 1, 1))
	if not _asset("bld_maabara_tents").is_empty():
		return
	for i in range(-6, 7):
		for j in range(-6, 7):
			var p := center + Vector2(i * 0.075, j * 0.06)
			if not _in_hex(p - center, radius) or rng.randf() < 0.2:
				continue
			_bldg(p, 0.055, 0.032, 0.022, S_HUT, Color(0.85, 0.85, 0.82).lerp(Color(0.7, 0.68, 0.6), rng.randf()))


# ---------------------------------------------------------------- art models (assets/MANIFEST.json)

const M2W := 0.0135        # metres -> world for metre-scale buildings (Civ-style exaggeration of buildings)
const ART_P := 0.08        # share of lots that use an art-builder building instead of the procedural kit
const ART_VIS_END := 60.0
const ART_NEAR := 12.0     # perf60: kit buildings switch to their far LOD (ArtKit mesh_far) beyond this (chunk centre)
const WEB_KIT_T := "res://assets/kit/web_kit_array.png"     # web build only (build/web/web_diet.py): the facades, 7 layers
const WEB_KIT_N := "res://assets/kit/web_kit_n_array.png"   # ... and their normal maps, 5 layers
const ART_LOD_BIAS := 4.0  # far culling for the heavy single-building models (auto-LOD handles mid range)
static var _manifest := {}
static var _scenes := {}
var art_count := 0


static func manifest() -> Dictionary:
	if _manifest.is_empty():
		var d = JSON.parse_string(FileAccess.get_file_as_string("res://assets/MANIFEST.json")) if FileAccess.file_exists("res://assets/MANIFEST.json") else null
		if typeof(d) == TYPE_DICTIONARY:
			for a in d.get("assets", []):
				if str(a.get("status", "ok")) == "ok":
					_manifest[str(a["id"])] = a
	return _manifest


func _asset(id: String) -> Dictionary:
	## manifest entry if the asset exists and was in use at the current date
	var a: Dictionary = manifest().get(id, {})
	if a.is_empty():
		return {}
	var era = a.get("era", {})
	if typeof(era) == TYPE_DICTIONARY:
		if map.year < int(era.get("from", 0)) or map.year > int(era.get("to", 9999)):
			return {}
	if not ResourceLoader.exists("res://assets/" + str(a["file"])):
		return {}
	return a


static func _scene(path: String) -> PackedScene:
	if not _scenes.has(path):
		# perf60: TerrainRenderer.warm_assets may have it loading (or loaded) on a thread already
		if ResourceLoader.load_threaded_get_status(path) != ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			_scenes[path] = ResourceLoader.load_threaded_get(path) as PackedScene
		else:
			_scenes[path] = load(path)
	return _scenes[path]


func _art(id: String, p: Vector2, yaw: float, fit := 0.0, max_h := 99.0, scale := M2W) -> bool:
	## place a metre-scale building model; fit = max footprint in world units (0 = real size)
	var a := _asset(id)
	if a.is_empty():
		return false
	var rm = a.get("real_m", null)
	if typeof(rm) != TYPE_DICTIONARY:
		return false
	var s := scale
	if fit > 0.0:
		s = minf(s, fit / maxf(float(rm["w"]), float(rm["d"])))
	s = minf(s, max_h / float(rm["h"]))
	var sc := _scene("res://assets/" + str(a["file"]))
	if sc == null:
		return false
	var n: Node3D = sc.instantiate()
	var hw := float(rm["w"]) * s * 0.5
	var y := minf(R.height_at(p.x, p.y), minf(R.height_at(p.x + hw, p.y), R.height_at(p.x - hw, p.y)))
	n.scale = Vector3.ONE * s
	n.rotation.y = yaw
	n.position = Vector3(p.x, y - 0.012, p.y)
	(_parent if _parent else self).add_child(n)
	for mi in n.find_children("*", "GeometryInstance3D", true, false):
		var g := mi as GeometryInstance3D
		g.visibility_range_end = ART_VIS_END
		g.visibility_range_end_margin = 6.0
		g.lod_bias = ART_LOD_BIAS
		if g is MeshInstance3D:
			_fix_materials(g as MeshInstance3D)
			var mb := g as MeshInstance3D   # v5: buildings (not units) light their windows at night (artmodel.gdshader)
			for si in mb.mesh.get_surface_count():
				var smb := mb.get_surface_override_material(si) as ShaderMaterial
				if smb:
					smb.set_shader_parameter("is_bldg", 1.0)
			if CLIP_TOP.has(id):
				var mi3 := g as MeshInstance3D
				for si in mi3.mesh.get_surface_count():
					var sm := mi3.get_surface_override_material(si) as ShaderMaterial
					if sm:
						sm.set_shader_parameter("clip_top", float(CLIP_TOP[id]))
	art_count += 1
	return true


static var _mat_fix := {}


static func _fix_materials(m: MeshInstance3D) -> void:
	## generated GLBs: matte shader with geometric normals (see artmodel.gdshader)
	for si in m.mesh.get_surface_count():
		var src := m.get_active_material(si)
		if not (src is BaseMaterial3D):
			continue
		if not _mat_fix.has(src):
			var d := ShaderMaterial.new()
			d.shader = load("res://scripts/map/artmodel.gdshader")
			d.set_shader_parameter("albedo_tex", (src as BaseMaterial3D).albedo_texture)
			d.set_shader_parameter("albedo_col", (src as BaseMaterial3D).albedo_color)
			_mat_fix[src] = d
		m.set_surface_override_material(si, _mat_fix[src])


func _place_dioramas() -> void:
	for c in map.cities:
		var id: String = c["id"]
		if id == "tel_aviv":
			pass   # skyline = per-city CBD tower budget + Azrieli landmark; White City from the lot kit
		elif id == "haifa":
			pass   # procedural port (_major_port) replaces the diorama, which floated over the bay
		elif id == "acre":
			var ac := map.find_place("Acre Old City")
			if not ac.is_empty():
				_diorama("city_jerusalem_stone", TerrainMath.offset_center(int(ac["q"]), int(ac["r"])), 0.55, 0.8)


# [manifest id (metre-scale, no base) | hex tile id, place name | [lat, lon], max footprint (world)]
const LANDMARKS := [
	["lm_dome_of_the_rock_nb", [31.7780, 35.2354], 0.3],
	["lm_knesset_nb", [31.7767, 35.2055], 0.3],
	["lm_bahai_gardens", "Bahá'í Gardens", 0.0],      # terraces (tile) from 2001
	["lm_bahai_shrine_nb", "Bahá'í Gardens", 0.45],   # the Shrine of the Báb alone before that
	# the modern glass terminal (Ben Gurion Terminal 3 type) only from 2004, when Terminal 3 opened; before that it
	# read as a white placeholder slab at the far view of 1948 Lydda (critic v3 B9). Optional 4th field = from year.
	["lm_airport_terminal_nb", [32.0055, 34.8854], 0.8, 2004],
	["lm_desalination_nb", [31.9330, 34.7020], 0.8],
	["lm_nuclear_dome_nb", "Negev Nuclear Research Center", 0.7],
	["lm_azrieli_towers_nb", [32.0745, 34.7920], 0.7],
	# v3 hero buildings (metre-scale; appear from the manifest era: KDH 1931, Shalom Meir Tower 1965, Yad Vashem museum 2005)
	["v3_king_david_hotel", [31.7750, 35.2190], 0.5],
	["v3_yad_vashem_museum", [31.7740, 35.1766], 1.0],
	["v3_shalom_meir_tower", [32.0626, 34.7737], 0.35],
	["v3_liebling_house", [32.0722, 34.7745], 0.26],     # White City: Max Liebling House (1936)
	["v3_dizengoff_circle", [32.0775, 34.7742], 0.3],    # White City: Dizengoff Circle corner block (1938)
]


# generated models with a stray spike above the roof: mesh height (m) above which artmodel.gdshader cuts the mesh.
# Shalom Meir Tower: roof at 120 m, plant room to 127 m, then a 15 m red-brown blob from the image-to-3D generator
# that read as a figure standing on the roof (critic v3 B9)
const CLIP_TOP := {"v3_shalom_meir_tower": 128.0}


func _place_landmarks() -> void:
	var gardens := map.year >= 2001
	for lm in LANDMARKS:
		var id: String = lm[0]
		if id == "lm_bahai_gardens" and not gardens:
			continue
		if id == "lm_bahai_shrine_nb" and gardens:
			continue
		if lm.size() > 3 and map.year < int(lm[3]):
			continue
		var ctr := Vector2.ZERO
		if lm[1] is String:
			var p := map.find_place(lm[1])
			if p.is_empty():
				continue
			ctr = map.latlon_to_world(float(p["lat"]), float(p["lon"])) if p.get("lat") != null else TerrainMath.offset_center(int(p["q"]), int(p["r"]))
		else:
			ctr = map.latlon_to_world(lm[1][0], lm[1][1])
		if not map.is_land(TerrainMath.world_to_offset(ctr)):
			continue
		var ok := false
		if id.ends_with("_nb") or str(manifest().get(id, {}).get("scale_units", "hex")) == "m":
			var a := _asset(id)
			if a.is_empty():
				continue
			ok = _art(id, ctr, -0.5, lm[2], 1.25, M2W * 1.2)
			if ok:
				footprints.append([ctr, float(lm[2]) * 0.45])
		else:
			ok = _diorama(id, ctr, 0.45, -0.5, "landmark")


func _diorama(id: String, ctr: Vector2, scale: float, yaw: float, _dir := "city") -> bool:
	## hex-scale tile model (1.0 = one hex flat-to-flat); prefers the *_noplinth variant
	var a := _asset(id + "_noplinth")
	if a.is_empty():
		a = _asset(id)
	if a.is_empty():
		return false
	var dsc := _scene("res://assets/" + str(a["file"]))
	if dsc == null:
		return false
	var n: Node3D = dsc.instantiate()
	n.name = str(a["id"])
	var s := TerrainMath.SQ3 * scale * float(a.get("suggested_scale", 1.0))
	var ground := maxf(0.03, R.height_at(ctr.x, ctr.y))
	var gy := float(a.get("ground_y", 0.0) if a.get("ground_y") != null else 0.0)
	n.scale = Vector3.ONE * s
	n.rotation.y = yaw
	n.position = Vector3(ctr.x, ground - gy * s, ctr.y)
	(_parent if _parent else self).add_child(n)
	var rad := TerrainMath.SQ3 * 0.5 * scale
	for mi in n.find_children("*", "MeshInstance3D", true, false):
		var m := mi as MeshInstance3D
		for si in m.mesh.get_surface_count():
			var src := m.get_active_material(si)
			var sm := ShaderMaterial.new()
			sm.shader = load("res://scripts/map/diorama.gdshader")
			R.set_common(sm)
			if src is BaseMaterial3D:
				sm.set_shader_parameter("albedo_tex", (src as BaseMaterial3D).albedo_texture)
				sm.set_shader_parameter("albedo_col", (src as BaseMaterial3D).albedo_color)
			sm.set_shader_parameter("plinth_top", ground)
			sm.set_shader_parameter("center", ctr)
			sm.set_shader_parameter("radius", rad)
			if id == "city_kibbutz":
				sm.set_shader_parameter("dark_lift", 0.85)   # v3r: dark stockade wood read as black at far zoom
			m.set_surface_override_material(si, sm)
	footprints.append([ctr, rad * 0.95])
	return true


# ---------------------------------------------------------------- harbours and ports

# map.json port places: [first year, kind] (major = deep-water port with piers, cranes and from 1975 containers)
const PORTS := {"Haifa port": [1933, "major"], "Ashdod port": [1965, "major"], "Eilat": [1957, "major"],
	"Aqaba": [1950, "small"], "Jaffa port": [0, "fishing"], "Gaza port": [0, "fishing"]}
const CONTAINER_COLS := [Color(0.75, 0.2, 0.15), Color(0.15, 0.35, 0.65), Color(0.2, 0.5, 0.3), Color(0.85, 0.5, 0.15),
	Color(0.9, 0.9, 0.88), Color(0.45, 0.47, 0.5), Color(0.55, 0.15, 0.2), Color(0.1, 0.55, 0.6)]


func _build_harbours() -> void:
	for p in map.places:
		if p.get("kind", "") != "port":
			continue
		var name_: String = p.get("name", "")
		var spec: Array = PORTS.get(name_, [0, "small"])
		if map.year < int(spec[0]):
			continue
		var c := TerrainMath.offset_center(int(p["q"]), int(p["r"]))
		if p.get("lat") != null:
			c = map.latlon_to_world(float(p["lat"]), float(p["lon"]))
		if spec[1] == "major":
			_major_port(c, name_)
		else:
			_harbour(c, spec[1] == "fishing")
	# Acre's old harbour (south side of the walled peninsula)
	_harbour(_ll(32.9195, 35.0675), true)
	# Haifa refineries (1939) on Haifa Bay
	if map.year >= 1939:
		_tank_farm(_ll(32.800, 35.055), 0.55)
	# Jaffa landmarks: clock tower (1903) and the Mahmoudiya mosque dome + minaret
	if map.jaffa_hex.x >= 0 and map.urban.has(map.jaffa_hex):
		var jc := _ll(32.0551, 34.7563)
		if not _art("v3_jaffa_clock_tower2", jc, -0.5, 0.0, 0.42, 0.016):
			_bldg(jc, 0.05, 0.05, 0.2, S_STONE, Color(1, 0.96, 0.9))
		footprints.append([jc, 0.07])
		var mc := jc + Vector2(-0.13, 0.08)
		var top := _bldg(mc, 0.13, 0.11, STOREY * 1.6, S_STONE, Color(1, 0.97, 0.9))
		_dome(mc, 0.045, top, Color(0.92, 0.9, 0.85))
		_minaret(mc + Vector2(0.08, -0.05), top)
		footprints.append([mc, 0.1])


func _sea_dir(c: Vector2) -> Vector2:
	var best := Vector2.LEFT; var best_h := 1.0
	for a in 32:
		var d := Vector2(cos(TAU * a / 32.0), sin(TAU * a / 32.0))
		var h := R.height_at(c.x + d.x * 0.9, c.y + d.y * 0.9) + R.height_at(c.x + d.x * 0.5, c.y + d.y * 0.5)
		if h < best_h:
			best_h = h; best = d
	return best


func _shore(c: Vector2, out: Vector2) -> Vector2:
	var s := c
	for i in 60:
		var h := R.height_at(s.x, s.y)
		if h < 0.0:
			break
		s += out * 0.03
	for i in 60:
		if R.height_at(s.x, s.y) >= 0.0:
			break
		s -= out * 0.03
	return s


func _mound(p0: Vector2, p1: Vector2, width: float, top: float) -> void:
	## breakwater: a continuous rubble mound (solid core from the seabed up to just above the water,
	## stone crown walk on top) with armour boulders packed along both sides at the waterline
	var len := p0.distance_to(p1)
	var dir := (p1 - p0) / maxf(len, 1e-4)
	var side := Vector2(-dir.y, dir.x)
	var mid := (p0 + p1) * 0.5
	var yaw := -side.angle() + PI * 0.5
	_box_at(mid, -0.3, width * 0.7, 0.3 + top * 0.5, len + width * 0.5, S_FLAT, Color(0.40, 0.38, 0.35), yaw)
	var n := int(len / 0.012)
	for i in n + 1:
		for sgn in [-1.0, 1.0]:
			var q: Vector2 = p0 + dir * (i * len / n + rng.randf_range(-0.004, 0.004)) + side * sgn * (width * 0.5 + rng.randf_range(-0.004, 0.006))
			var sz := rng.randf_range(0.016, 0.026)
			var b := Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3(sz * 1.3, sz * 0.8, sz))
			B["rock"][0].append(Transform3D(b, Vector3(q.x, top - sz * 0.35, q.y)))
			var g := rng.randf_range(0.66, 0.84)
			B["rock"][1].append(Color(g * 0.5, g * 0.48, g * 0.44, 0))


func _ship(p: Vector2, along: Vector2, length: float, cargo: bool) -> void:
	var yaw := -along.angle() + PI * 0.5
	var hull: Color = [Color(0.55, 0.12, 0.1), Color(0.12, 0.18, 0.32), Color(0.2, 0.22, 0.25)][rng.randi() % 3]
	_box_at(p, -0.03, 0.055, 0.05, length, S_FLAT, hull, yaw)
	_box_at(p, 0.018, 0.05, 0.004, length * 0.98, S_FLAT, Color(0.75, 0.72, 0.65), yaw)
	_box_at(p - along * length * 0.36, 0.02, 0.045, 0.05, length * 0.14, S_FLAT, Color(0.95, 0.95, 0.93), yaw)
	if cargo:
		for i in 6:
			var q := p + along * (length * (0.3 - i * 0.1))
			_box_at(q, 0.022, 0.045, 0.022, length * 0.085, S_FLAT, CONTAINER_COLS[rng.randi() % CONTAINER_COLS.size()], yaw)


func _major_port(c: Vector2, name_: String) -> void:
	var out := _sea_dir(c)
	var side := Vector2(-out.y, out.x)
	var shore := _shore(c, out)
	var L := 1.3 if name_ == "Haifa port" else 1.0
	var containers := map.year >= 1975
	# quay apron along the shore, half on land
	_box_at(shore - out * 0.02, -0.12, 0.14, 0.14, L, S_PLAIN, Color(0.82, 0.81, 0.78), -side.angle() + PI * 0.5)
	footprints.append([shore - out * 0.1, 0.25])
	# piers
	var piers := [-0.4, 0.0, 0.4] if L > 1.1 else [-0.25, 0.2]
	for po in piers:
		var a: Vector2 = shore + side * po * L
		var b: Vector2 = a + out * 0.42
		_box_at((a + b) * 0.5, -0.12, 0.1, 0.14, 0.42, S_PLAIN, Color(0.84, 0.83, 0.8), -out.angle() + PI * 0.5)
		# cranes along the pier
		for ci in 3:
			var q: Vector2 = a + out * (0.1 + ci * 0.12) + side * 0.035
			if _piece("hp_gantry_crane" if containers else "hp_crane_1930s", q, -side.angle(), 0.0022 if containers else 0.0035, 0.02):
				continue
			var mesh := "gantry" if containers else "jib"
			var s := 1.0 if containers else 0.8
			B[mesh][0].append(Transform3D(Basis(Vector3.UP, -side.angle()).scaled(Vector3.ONE * s), Vector3(q.x, 0.02, q.y)))
			B[mesh][1].append(Color(0.5, 0.5, 0.5, 0))
		# ships alongside
		if rng.randf() < 0.85:
			pass   # procedural ships read as floating slabs
	# main breakwater: parallel to the shore, out at sea, with a lighthouse at the tip
	var b0 := shore + out * 0.62 - side * L * 0.6
	var b1 := shore + out * 0.62 + side * L * 0.45
	_mound(b0, b1, 0.06, 0.02)
	_mound(b0, b0 - out * 0.45 + side * 0.05, 0.06, 0.02)
	B["cyl"][0].append(Transform3D(Basis.IDENTITY.scaled(Vector3(0.03, 0.15, 0.03)), Vector3(b1.x, 0.0, b1.y)))
	B["cyl"][1].append(_cd(S_PLAIN, Color(1, 1, 0.97)))
	B["cone"][0].append(Transform3D(Basis.IDENTITY.scaled(Vector3(0.035, 0.03, 0.035)), Vector3(b1.x, 0.15, b1.y)))
	B["cone"][1].append(_cd(S_PLAIN, Color(0.75, 0.25, 0.2)))
	# port land: warehouses (older) or container yard (from 1975)
	for i in range(-6, 7):
		for j in 3:
			var q := shore - out * (0.12 + j * 0.09) + side * i * 0.1 * L
			if R.height_at(q.x, q.y) < 0.0:
				continue
			if containers and j < 2:
				# container yard: rows of brightly coloured stacks, 1-4 high
				for s in 3:
					for t in 2:
						var cq := q + side * (s - 1.0) * 0.034 - out * (t - 0.5) * 0.09
						var stack := rng.randi_range(1, 4)
						for z in stack:
							_box_at(cq, R.height_at(cq.x, cq.y) - 0.005 + z * 0.026, 0.11, 0.025, 0.03, S_FLAT, CONTAINER_COLS[rng.randi() % CONTAINER_COLS.size()], -side.angle())
			else:
				var y0 := R.height_at(q.x, q.y)
				_box_at(q, y0 - 0.02, 0.085, 0.065, 0.075, S_SHIKUN if rng.randf() < 0.3 else S_PLAIN, Color(0.9, 0.88, 0.84), -side.angle())
				if rng.randf() < 0.5:
					_roof(q, 0.085, 0.075, y0 + 0.045, -side.angle())
	# vessels at anchor in the roadstead (procedural ships read as floating slabs; skipped)
	for i in 0:
		var q := shore + out * rng.randf_range(0.9, 1.6) + side * rng.randf_range(-1.0, 1.0)
		if R.height_at(q.x, q.y) < -0.1:
			_ship(q, Vector2(cos(rng.randf() * TAU), sin(rng.randf() * TAU)), 0.32, containers)


func _tank_farm(c: Vector2, size: float) -> void:
	if not _asset("hp_refinery_tanks").is_empty() and not ArtKit.get_parts("hp_refinery_tanks").is_empty():
		for i in 3:
			var q := c + Vector2((i - 1) * 0.42, rng.randf_range(-0.1, 0.1))
			if R.height_at(q.x, q.y) > 0.02:
				_piece("hp_refinery_tanks", q, rng.randf_range(-0.2, 0.2), 0.0055, R.height_at(q.x, q.y) - 0.01)
		footprints.append([c, size * 0.6])
		return
	for i in range(-3, 4):
		for j in range(-2, 3):
			var q := c + Vector2(i * 0.085, j * 0.085) + Vector2(rng.randf_range(-0.01, 0.01), rng.randf_range(-0.01, 0.01))
			if R.height_at(q.x, q.y) < 0.02 or rng.randf() < 0.2 or abs(i * 0.085) > size * 0.5:
				continue
			var r := rng.randf_range(0.05, 0.07)
			var y0 := R.height_at(q.x, q.y)
			B["cyl"][0].append(Transform3D(Basis.IDENTITY.scaled(Vector3(r, 0.045, r)), Vector3(q.x, y0 - 0.01, q.y)))
			B["cyl"][1].append(_cd(S_FLAT, Color(0.92, 0.92, 0.9)))
	for s in 2:
		var q := c + Vector2(0.32, -0.1 + s * 0.12)
		var y0 := R.height_at(q.x, q.y)
		B["cyl"][0].append(Transform3D(Basis.IDENTITY.scaled(Vector3(0.016, 0.3, 0.016)), Vector3(q.x, y0, q.y)))
		B["cyl"][1].append(_cd(S_FLAT, Color(0.75, 0.3, 0.25)))
	footprints.append([c, size * 0.6])


func _harbour(c: Vector2, fishing: bool) -> void:
	## Hand-composed old coastal harbour (Jaffa, Acre): rubble breakwater with a lighthouse on its rocks,
	## stone quay with an arcade of vaulted warehouses, market awnings, wooden piers and moored boats.
	## Uses the art builder's harbour pieces (hb_*, boat_*) where available, procedural parts otherwise.
	var out := _sea_dir(c)
	var side := Vector2(-out.y, out.x)
	var shore := _shore(c, out)
	var qyaw := -side.angle() + PI * 0.5      # local z along the quay
	var HS := 0.0075                         # world units per metre for harbour pieces
	# stone quay (solid down to the seabed) with art quay sections along its face
	var quay := shore + out * 0.04
	_box_at(quay, -0.2, 0.07, 0.212, 0.5, S_STONE, Color(1.0, 0.92, 0.78), qyaw)
	for i in 5:
		_piece("hb_quay_straight", quay + out * 0.03 + side * (i - 2) * 14.8 * HS, -side.angle(), HS, -0.012)
	# arcade of vaulted stone warehouses behind the quay, facing the sea
	for i in 5:
		var q := shore - out * 0.045 + side * (i - 2) * 0.085
		if R.height_at(q.x, q.y) < -0.01:
			continue
		var y0 := maxf(0.0, R.height_at(q.x, q.y))
		_box_at(q, y0 - 0.03, 0.08, 0.075, 0.07, S_STONE, _jit(Color(1.0, 0.9, 0.72), 0.05), qyaw + PI * 0.5)
		for k in 3:   # dark arch openings on the seaward face
			var aq := q + out * 0.036 + side * (k - 1) * 0.024
			_box_at(aq, y0, 0.016, 0.03, 0.006, S_FLAT, Color(0.16, 0.12, 0.1), qyaw + PI * 0.5)
			B["cyl"][0].append(Transform3D(Basis(Vector3.RIGHT, PI * 0.5).scaled(Vector3(0.016, 0.006, 0.016)), Vector3(aq.x, y0 + 0.03, aq.y)))
			B["cyl"][1].append(_cd(S_FLAT, Color(0.16, 0.12, 0.1)))
		# market awnings in front of the arcade
		if rng.randf() < 0.8:
			var wq := q + out * 0.06
			var awn: Color = [Color(0.85, 0.25, 0.2), Color(0.95, 0.75, 0.25), Color(0.2, 0.45, 0.7), Color(0.95, 0.95, 0.9), Color(0.3, 0.6, 0.4)][rng.randi() % 5]
			_box_at(wq, y0 + 0.032, 0.05, 0.004, 0.04, S_FLAT, awn, qyaw + rng.randf_range(-0.1, 0.1))
			for pk in 2:
				var pq := wq + side * (pk - 0.5) * 0.035 + out * 0.015
				_box_at(pq, y0, 0.003, 0.034, 0.003, S_FLAT, Color(0.35, 0.25, 0.15))
	footprints.append([shore - out * 0.04, 0.24])
	# wooden piers with boats tied alongside
	for pi in 2:
		var a := shore + out * 0.07 + side * (-0.12 + pi * 0.2)
		var plen := 0.2
		var mid := a + out * plen * 0.5
		if not _piece("hb_wooden_pier", mid, -out.angle(), plen / 11.4, -0.01):
			_box_at(mid, 0.006, 0.022, 0.006, plen, S_FLAT, Color(0.45, 0.32, 0.2), -out.angle() + PI * 0.5)
			for s in 5:
				var pq := a + out * s * plen / 4.0
				for sg in [-1.0, 1.0]:
					_box_at(pq + side * sg * 0.011, -0.05, 0.004, 0.06, 0.004, S_FLAT, Color(0.3, 0.22, 0.14))
		for s in 3:
			var bq := a + out * (0.04 + s * 0.07) + side * (0.03 if s % 2 == 0 else -0.03)
			_boat(bq, -out.angle() + rng.randf_range(-0.15, 0.15))
	# rubble breakwater: out to sea, then turning along the coast, lighthouse on a rock pile at the tip
	var tip := shore + out * 0.36 + side * 0.22
	_breakwater(shore + out * 0.06 - side * 0.26, shore + out * 0.36 - side * 0.2)
	_breakwater(shore + out * 0.36 - side * 0.2, tip)
	for r in 10:
		var q := tip + Vector2(rng.randf_range(-0.04, 0.04), rng.randf_range(-0.04, 0.04))
		var sz := rng.randf_range(0.025, 0.04)
		B["rock"][0].append(Transform3D(Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3(sz * 1.2, sz * 0.9, sz)), Vector3(q.x, 0.01, q.y)))
		B["rock"][1].append(Color(0.38, 0.37, 0.35, 0))
	if not _piece("hb_lighthouse", tip, 0.0, 0.0085, 0.0):
		B["cyl"][0].append(Transform3D(Basis.IDENTITY.scaled(Vector3(0.026, 0.12, 0.026)), Vector3(tip.x, 0.02, tip.y)))
		B["cyl"][1].append(_cd(S_PLAIN, Color(1, 1, 0.97)))
		B["cone"][0].append(Transform3D(Basis.IDENTITY.scaled(Vector3(0.03, 0.03, 0.03)), Vector3(tip.x, 0.14, tip.y)))
		B["cone"][1].append(_cd(S_FLAT, Color(0.75, 0.2, 0.15)))
	# fishing boats inside the harbour basin
	for i in (8 if fishing else 4):
		var q := shore + out * rng.randf_range(0.12, 0.3) + side * rng.randf_range(-0.2, 0.15)
		if R.height_at(q.x, q.y) > -0.03:
			continue
		_boat(q, side.angle() + rng.randf_range(-0.4, 0.4) + (PI if rng.randf() < 0.5 else 0.0))


func _boat(q: Vector2, yaw: float) -> void:
	var ids := ["boat_jaffa_rowboat", "boat_jaffa_motorboat", "boat_felucca" if map.year < 1970 else "boat_sailboat"]
	if _piece(ids[rng.randi() % ids.size()], q, yaw, 0.006, -0.004):
		return
	var b := Basis(Vector3.UP, yaw + PI * 0.5).scaled(Vector3.ONE * rng.randf_range(0.5, 0.65))
	B["boat"][0].append(Transform3D(b, Vector3(q.x, 0.0, q.y)))
	B["boat"][1].append(Color(0.5, 0.5, 0.5, 0))


func _breakwater(p0: Vector2, p1: Vector2) -> void:
	## art armour-block breakwater segments (20 m each) along p0-p1; rubble mound fallback
	var len := p0.distance_to(p1)
	var dir := (p1 - p0) / maxf(len, 1e-4)
	var seg := 20.0 * 0.0075
	var n := maxi(1, int(round(len / seg)))
	var ok := true
	for i in n:
		var q := p0 + dir * (i + 0.5) * len / n
		if not _piece("hb_breakwater", q, -dir.angle(), (len / n) / 20.0, -0.018):
			ok = false
			break
	if not ok:
		_mound(p0, p1, 0.05, 0.014)


func _yaw4() -> float:
	return (rng.randi() % 4) * PI * 0.5
