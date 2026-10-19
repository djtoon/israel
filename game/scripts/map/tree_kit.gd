class_name TreeKit
extends RefCounted
## v5 trees: stylised procedural vegetation for the map (woods, maquis, orchards, oases, wadis) and the towns
## (street trees). Every species is built here from tapered trunk and branch tubes (the bark strips of the atlas) and
## painted leaf-cluster cards (assets/models/vegetation/veg_atlas.png, built by assets/_pipeline/veg_atlas.py from
## tools/gen.py paintings), with crown-spherical normals for soft lighting, AO baked into the vertex colour, and a
## trunk that reaches 2 m below the ground so trees never float on slopes.
##
## Vertex format: COLOR.rgb = colour * AO (sRGB), COLOR.a = leaf mask (0 bark, 1 leaves), UV = atlas,
## UV2.x = flutter weight (frond tips). Shader: scripts/map/foliage.gdshader; contact shadow: veg_disc.gdshader.
## LODs per species: 0 = HD near (all cards), 1 = SD near (about half the cards, coarser trunks), 2 = far in both
## modes (a few large cards). TerrainRenderer.mm() turns every mesh with meta "tree_kind" into a near / far pair of
## MultiMesh chunks with visibility ranges plus a ground-shadow chunk (add_lods); a live SD <-> HD switch swaps the
## near meshes and ranges (sync_mode, polled by TerrainRenderer).
## v5 fix: broadleaf, oak, olive, citrus, eucalyptus, shrubs and the far pine are built from 2-3 lumpy domed clumps
## (opaque, painted with the leaf cell, dark underneath) with leaf cards on their surface for a leafy outline, so no
## ground shows through a crown at any LOD. Trees cast no shadow-map shadows at all (small casters came out as a
## dithered screen-door under the soft-shadow filter): each tree draws its own soft ground shadow instead (shadow(),
## veg_shadow.gdshader: contact patch + trunk stripe + crown ellipse cast along the real sun / moon direction, draped
## on the terrain height on the GPU, weaker by moonlight and under clouds; sync_light).

const M := 0.01            # one metre in hex-scale units (TerrainRenderer.TREE_SCALE applies on top)
const SIZE := 1.1          # stylised presence: every species a little larger than life, like the blob trees it replaced
const ATLAS := 2048.0
const CELLS := {           # pixel rects in veg_atlas.png; keep in sync with assets/_pipeline/veg_atlas.py
	"broad": Rect2(0, 0, 512, 512), "pine": Rect2(512, 0, 512, 512), "olive": Rect2(1024, 0, 512, 512),
	"citrus": Rect2(1536, 0, 512, 512), "bougain": Rect2(0, 512, 512, 512), "oleander": Rect2(512, 512, 512, 512),
	"eucalyptus": Rect2(1024, 512, 512, 512), "fanfrond": Rect2(1536, 512, 512, 512), "datefrond": Rect2(0, 1024, 1024, 384),
	"acacia": Rect2(1024, 1024, 1024, 384), "cypress": Rect2(0, 1408, 256, 640), "deadfronds": Rect2(256, 1408, 512, 512),
	"bark": Rect2(768, 1408, 256, 256), "palmtrunk": Rect2(1024, 1408, 256, 640),
}
const KINDS := ["pine", "broad", "cypress", "olive", "citrus", "palm", "palm_cluster", "fanpalm", "eucalyptus",
	"oleander", "bougainvillea", "acacia"]
## ground shadow per species (metres, before SIZE): crown centre height, crown radius, crown half-height, trunk
## half-width (veg_shadow.gdshader casts the crown ellipse and the trunk stripe along the light)
const SHADOW := {"pine": Vector4(10.9, 7.3, 1.7, 0.4), "broad": Vector4(7.9, 7.3, 4.0, 0.5), "cypress": Vector4(9.6, 2.5, 8.6, 0.3),
	"olive": Vector4(4.5, 5.4, 2.6, 0.45), "citrus": Vector4(3.1, 3.8, 2.7, 0.25), "palm": Vector4(13.0, 5.4, 1.5, 0.4),
	"palm_cluster": Vector4(8.0, 5.6, 2.6, 0.45), "fanpalm": Vector4(19.6, 3.0, 2.6, 0.35), "eucalyptus": Vector4(12.0, 6.4, 6.0, 0.45),
	"oleander": Vector4(2.0, 2.6, 1.5, 0.0), "bougainvillea": Vector4(1.8, 2.5, 1.3, 0.0), "acacia": Vector4(5.4, 5.2, 0.7, 0.25)}
const NEAR_HD := 18.0      # HD / HD+: LOD 0 closer than this (AABB centre of an 8-unit chunk), LOD 2 beyond
const NEAR_SD := 15.0      # SD: LOD 1 closer than this, LOD 2 beyond
const SHADOW_END := 30.0   # ground shadows this near the camera (about the sun's shadow range at play zoom)
const CROWN := 1.3      # the clump crowns fuller than life, so a forest hex covers at least as much as the v4 blobs
const BARK := Color(0.42, 0.33, 0.25)

static var _meshes := {}   # "kind:lod" -> ArrayMesh
static var _shadows := {}  # kind -> ArrayMesh (ground-shadow grid)
static var _mat: ShaderMaterial
static var _shadow_mats := {}   # kind -> ShaderMaterial (veg_shadow.gdshader with the species' shape)
static var _live: Array = []   # [WeakRef(near MMI), kind, WeakRef(far MMI)]
static var _live_hd := false
static var _light_key := Vector4(INF, 0, 0, 0)
static var near_k := 1.0   # perf60: x the near-LOD distance (GfxTier lever tree_k; 1 = as designed)


# ---------------------------------------------------------------- public

static func mesh(kind: String, lod := -1) -> ArrayMesh:
	## the species mesh at a LOD (-1 = this mode's near LOD); carries meta "tree_kind" for TerrainRenderer.mm()
	if lod < 0:
		lod = 0 if Quality.is_hd() else 1
	var key := "%s:%d" % [kind, lod]
	if not _meshes.has(key):
		var b := Builder.new(hash(kind) & 0xffff, lod)
		match kind:
			"pine": _pine(b)
			"cypress": _cypress(b)
			"olive": _olive(b)
			"citrus": _citrus(b)
			"palm": _date_palm(b, Vector3.ZERO, 13.0, Vector3(1.6, 0, 0.2), [16, 11, 7][lod], 7.6)
			"palm_cluster": _palm_cluster(b)
			"fanpalm": _fanpalm(b)
			"eucalyptus": _eucalyptus(b)
			"oleander": _shrub(b, "oleander", Color(1, 1, 1), 3.4, 2.5, 5)
			"bougainvillea": _shrub(b, "bougain", Color(1, 1, 1), 3.0, 2.5, 3)
			"acacia": _acacia(b)
			_: _broad(b)
		var m := b.finish()
		m.set_meta("tree_kind", kind)
		m.set_meta("tree_lod", lod)
		_meshes[key] = m
	return _meshes[key]


static func material() -> ShaderMaterial:
	if _mat == null:
		_mat = ShaderMaterial.new()
		_mat.shader = load("res://scripts/map/foliage.gdshader")
		_mat.set_shader_parameter("atlas", load("res://assets/models/vegetation/veg_atlas.png"))
	return _mat


static var _terrain: WeakRef = null   # the TerrainRenderer whose hex textures the ground shadows read (set_common)


static func bind_terrain(r: Object) -> void:
	## TerrainRenderer: the ground shadows drape themselves on the terrain height (hexcommon.gdshaderinc) on the GPU
	_terrain = weakref(r)
	for k in _shadow_mats:
		r.call("set_common", _shadow_mats[k])


static func shadow_material(kind: String) -> ShaderMaterial:
	if not _shadow_mats.has(kind):
		var m := ShaderMaterial.new()
		m.shader = load("res://scripts/map/veg_shadow.gdshader")
		var s: Vector4 = SHADOW.get(kind, SHADOW["broad"])
		m.set_shader_parameter("shape", s * (M * SIZE))
		if _light_key.x != INF:
			m.set_shader_parameter("light_dir", Vector3(_light_key.x, _light_key.y, _light_key.z))
			m.set_shader_parameter("light_k", _light_key.w)
		var r = _terrain.get_ref() if _terrain else null
		if r:
			r.call("set_common", m)
		_shadow_mats[kind] = m
	return _shadow_mats[kind]


static func shadow(kind: String) -> ArrayMesh:
	## the ground-shadow grid of a species: UV.x 0..1 from the trunk foot to the tip of the crown's shadow, UV.y -1..1
	## across; veg_shadow.gdshader places every vertex on the ground along the light (so the mesh needs a wide AABB)
	if not _shadows.has(kind):
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var na := 6   # 21 vertices: enough to follow the terrain's 0.16-unit grid along a long low-sun shadow
		var nb := 2
		for i in na:
			for j in nb:
				var q := [Vector2(float(i) / na, float(j) / nb), Vector2(float(i + 1) / na, float(j) / nb),
					Vector2(float(i + 1) / na, float(j + 1) / nb), Vector2(float(i) / na, float(j + 1) / nb)]
				for k in [0, 1, 2, 0, 2, 3]:
					var uv := Vector2(q[k].x, q[k].y * 2.0 - 1.0)
					st.set_normal(Vector3.UP)
					st.set_uv(uv)
					st.add_vertex(Vector3(uv.x * 0.1, 0.0, uv.y * 0.05))
		st.index()
		var m := st.commit()
		m.custom_aabb = AABB(Vector3(-1.0, -0.6, -1.0), Vector3(2.0, 1.2, 2.0))   # the shadow reaches out along the light
		_shadows[kind] = m
	return _shadows[kind]


static func disc(kind: String) -> ArrayMesh:
	## (v5 dev preview tools) the ground shadow
	return shadow(kind)


static func sync_light(sun: DirectionalLight3D) -> void:
	## every frame (TerrainRenderer._process): the ground shadows follow the light's direction (sun by day, moon by
	## night) and its strength (DayNight's light factor: about 0.27 by moonlight, 0 around the sun / moon switch)
	if sun == null or not is_instance_valid(sun):
		return
	var d := sun.global_transform.basis.z.normalized()   # toward the light
	var k := 1.0
	if not DayNight.off and DayNight._look.has("lk"):
		k = clampf(float(DayNight._look["lk"]), 0.0, 1.0)
	if not sun.visible or sun.light_energy <= 0.0:
		k = 0.0
	var key := Vector4(d.x, d.y, d.z, k)
	if key.is_equal_approx(_light_key):
		return
	_light_key = key
	for kind in _shadow_mats:
		var m: ShaderMaterial = _shadow_mats[kind]
		m.set_shader_parameter("light_dir", d)
		m.set_shader_parameter("light_k", k)


static func add_lods(kind: String, mm_near: MultiMesh, name_: String, parent: Node, _shadows := true) -> MultiMeshInstance3D:
	## one chunk of one species: near LOD, far LOD and the ground shadows, all sharing the instance data, under one
	## holder node (so HDRender._sync_tree_shadows, which sets the shadow flag of every MultiMesh directly under a
	## vegetation chunk, leaves them alone). No shadow-map casters in any mode (see the header); the ground shadow
	## (shadow()) replaces both the old contact disc and the proxy shadows, by day and by moonlight.
	var hd := Quality.is_hd()
	_live_hd = hd
	var holder := Node3D.new()
	holder.name = name_
	var near := MultiMeshInstance3D.new()
	mm_near.mesh = mesh(kind, 0 if hd else 1)
	near.name = "near"
	near.multimesh = mm_near
	near.material_override = material()
	var far := MultiMeshInstance3D.new()
	far.name = "far"
	far.multimesh = _clone(mm_near, mesh(kind, 2))
	far.material_override = material()
	near.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	far.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_ranges(near, far, hd)
	var gs := MultiMeshInstance3D.new()
	gs.name = "shadow"
	gs.multimesh = _clone(mm_near, shadow(kind))
	gs.material_override = shadow_material(kind)
	gs.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	gs.visibility_range_end = SHADOW_END
	gs.visibility_range_end_margin = 0.0   # (no hysteresis band, see _ranges)
	if GfxTier.web() and not bool(GfxTier.levers.get("tree_shadows", true)):
		gs.visible = false   # (web, integrated graphics: no tree ground shadows: each drapes itself on the terrain per vertex)
	holder.add_child(near)
	holder.add_child(far)
	holder.add_child(gs)
	parent.add_child(holder)
	_live.append([weakref(near), kind, weakref(far)])
	return near


static func _clone(src: MultiMesh, m: Mesh) -> MultiMesh:
	## the same instances (transforms and tints) with another mesh (format and count first, then the buffer)
	var d := MultiMesh.new()
	d.transform_format = MultiMesh.TRANSFORM_3D
	d.use_custom_data = src.use_custom_data
	d.use_colors = src.use_colors   # (web: white instance colours, see TerrainRenderer)
	d.mesh = m
	d.instance_count = src.instance_count
	var buf := src.buffer
	if buf.size() == src.instance_count * (12 + (4 if src.use_colors else 0) + (4 if src.use_custom_data else 0)):
		d.buffer = buf
	elif DisplayServer.get_name() != "headless":   # headless (dummy renderer) keeps no instance data: nothing to copy
		push_warning("TreeKit: unexpected MultiMesh buffer size %d for %d instances" % [buf.size(), src.instance_count])
	return d


static func sync_mode() -> void:
	## a live SD <-> HD switch: swap the near LOD meshes and the LOD distances (cheap: no instance data changes)
	var hd := Quality.hd
	if hd == _live_hd:
		return
	_live_hd = hd
	var keep: Array = []
	for e in _live:
		var near = (e[0] as WeakRef).get_ref()
		var far = (e[2] as WeakRef).get_ref()
		if near == null or far == null:
			continue
		(near as MultiMeshInstance3D).multimesh.mesh = mesh(str(e[1]), 0 if hd else 1)
		_ranges(near, far, hd)
		keep.append(e)
	_live = keep


static func _ranges(near: GeometryInstance3D, far: GeometryInstance3D, hd: bool) -> void:
	## no margins: a visibility-range margin is a hysteresis band (the state only flips once the distance is past the
	## threshold by the margin), so on a cold start with a still camera every chunk whose centre sat within 1 unit of
	## the switch drew neither LOD (v5-trees-fix regression: a band of missing trees in SD / HD at far zoom, only their
	## ground shadows left). A small overlap instead: both LODs draw for chunks within 0.25 units of the switch.
	var d := (NEAR_HD if hd else NEAR_SD) * near_k
	near.visibility_range_end = d + 0.25
	near.visibility_range_end_margin = 0.0
	far.visibility_range_begin = d - 0.25
	far.visibility_range_begin_margin = 0.0


static func set_near_k(k: float) -> void:
	## perf60 (GfxTier tree_k): the near / far switch distance of every live tree chunk, live
	if is_equal_approx(k, near_k):
		return
	near_k = k
	for e in _live:
		var near = (e[0] as WeakRef).get_ref()
		var far = (e[2] as WeakRef).get_ref()
		if near != null and far != null:
			_ranges(near, far, _live_hd)


static func cuv(cell: String, u: float, v: float) -> Vector2:
	var r: Rect2 = CELLS[cell]
	return Vector2((r.position.x + clampf(u, 0.0, 1.0) * r.size.x) / ATLAS, (r.position.y + clampf(v, 0.0, 1.0) * r.size.y) / ATLAS)


static func tri_count(kind: String, lod: int) -> int:
	var m := mesh(kind, lod)
	var n := 0
	for s in m.get_surface_count():
		var a := m.surface_get_arrays(s)
		n += (a[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3 if a[Mesh.ARRAY_INDEX] != null else (a[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() / 3
	return n


# ---------------------------------------------------------------- builder (metres; scaled by M on output)

class Builder:
	var st := SurfaceTool.new()
	var rng := RandomNumberGenerator.new()
	var lod := 0

	func _init(seed_: int, lod_: int) -> void:
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		rng.seed = seed_
		lod = lod_

	func finish() -> ArrayMesh:
		st.index()
		return st.commit()

	func vtx(p: Vector3, n: Vector3, uv: Vector2, col: Color, flut := 0.0, solid := 0.0) -> void:
		## UV2.y = solid: 1 on the domed clumps (drawn opaque whatever the painted alpha, so no ground shows through)
		st.set_color(col)
		st.set_normal(n)
		st.set_uv(uv)
		st.set_uv2(Vector2(flut, solid))
		st.add_vertex(p * (TreeKit.M * TreeKit.SIZE))

	func dome(cc: Vector3, r: Vector3, cell: String, col: Color, seg := 8, rings := 4, flat := 0.5, uvs := 0.3, grad := 0.42, flut := 0.2) -> void:
		## one domed leaf clump: a lumpy ellipsoid with a flattened underside, painted with the middle of the leaf
		## cell (planar from above) and shaded light on top to dark underneath (about 0.58 .. 1.06; the far LOD
		## flatter, so a far tree reads as one mid-tone); normals lean to the sky like the cards'
		var g := grad * (0.6 if lod == 2 else 1.0)
		var ph := rng.randf() * TAU
		for j in rings:
			var t0 := PI * j / rings
			var t1 := PI * (j + 1) / rings
			for i in seg:
				var p0 := TAU * i / seg + ph
				var p1 := TAU * (i + 1) / seg + ph
				var quad: Array = []
				for tp in [[t0, p0], [t1, p0], [t1, p1], [t0, p1]]:
					quad.append(Vector3(sin(tp[0]) * cos(tp[1]), cos(tp[0]), sin(tp[0]) * sin(tp[1])))
				for k in [0, 1, 2, 0, 2, 3]:
					var u: Vector3 = quad[k]
					var e := Vector3(u.x, u.y if u.y >= 0.0 else u.y * flat, u.z)
					var jit := 1.0 + 0.11 * sin(u.x * 7.0 + u.z * 5.0 + ph) * cos(u.y * 6.0 + u.x * 3.0) * (1.0 - absf(u.y) * 0.6)
					var p := cc + e * r * jit
					var nn := (Vector3(e.x / r.x, e.y / r.y, e.z / r.z).normalized() + Vector3.UP * 0.25).normalized()
					var sh := lerpf(1.0 - g, 1.06, smoothstep(-0.55, 0.85, u.y))
					var cl := Color(col.r * sh, col.g * sh, col.b * sh, 1.0)
					vtx(p, nn, TreeKit.cuv(cell, 0.5 + u.x * uvs, 0.5 + u.z * uvs), cl, flut, 1.0)

	func tube(pts: Array, radii: Array, sides: int, col0: Color, col1: Color, cell := "bark", leaf := 0.0, flut := 0.0) -> void:
		## a tapered tube along a polyline (parallel-transported rings, smooth radial normals)
		var n := pts.size()
		if n < 2:
			return
		var lens: Array = [0.0]
		var total := 0.0
		for i in range(1, n):
			total += ((pts[i] as Vector3) - (pts[i - 1] as Vector3)).length()
			lens.append(total)
		total = maxf(total, 1e-4)
		var rings: Array = []
		var b1 := Vector3.ZERO
		for i in n:
			var p: Vector3 = pts[i]
			var t: Vector3
			if i == 0:
				t = ((pts[1] as Vector3) - p).normalized()
			elif i == n - 1:
				t = (p - (pts[i - 1] as Vector3)).normalized()
			else:
				t = ((pts[i + 1] as Vector3) - (pts[i - 1] as Vector3)).normalized()
			if i == 0:
				var ref := Vector3.FORWARD if absf(t.dot(Vector3.FORWARD)) < 0.9 else Vector3.RIGHT
				b1 = t.cross(ref).normalized()
			else:
				b1 = (b1 - t * b1.dot(t)).normalized()
			var b2 := t.cross(b1).normalized()
			var ring: Array = []
			for j in sides + 1:
				var a := TAU * j / sides
				var d := b1 * cos(a) + b2 * sin(a)
				ring.append([p + d * float(radii[i]), d, float(j) / sides])
			rings.append(ring)
		for i in n - 1:
			var va: float = float(lens[i]) / total
			var vb: float = float(lens[i + 1]) / total
			var ca := col0.lerp(col1, va)
			var cb := col0.lerp(col1, vb)
			ca.a = leaf
			cb.a = leaf
			for j in sides:
				var q := [[rings[i][j], ca, va], [rings[i + 1][j], cb, vb], [rings[i + 1][j + 1], cb, vb], [rings[i][j + 1], ca, va]]
				for k in [0, 1, 2, 0, 2, 3]:
					var e: Array = q[k]
					var rv: Array = e[0]
					vtx(rv[0], rv[1], TreeKit.cuv(cell, rv[2], 1.0 - float(e[2])), e[1], flut * float(e[2]))

	func ao(p: Vector3, cc: Vector3, cr: Vector3) -> float:
		## crown occlusion: darker toward the inside and the underside of the crown
		var q := (p - cc) / cr
		var top := clampf(q.y * 0.5 + 0.5, 0.0, 1.0)
		var rad := clampf(Vector2(q.x, q.z).length(), 0.0, 1.0)
		var lo := 0.88 if lod == 2 else 0.7   # the far LOD: little internal darkening (one mid-tone, no speckle)
		return lerpf(lo, 1.04, clampf(top * 0.7 + rad * 0.4, 0.0, 1.0))

	func card(c: Vector3, n: Vector3, w: float, h: float, cell: String, col: Color, cc: Vector3, cr: Vector3, rot := 0.0, flut := 0.35, bend := 0.8) -> void:
		## one leaf-cluster card; its normals bend toward the crown sphere so the crown shades as one soft volume
		n = n.normalized()
		var ref := Vector3.UP if absf(n.y) < 0.92 else Vector3.FORWARD
		var right := ref.cross(n).normalized()
		var up := n.cross(right).normalized()
		if rot != 0.0:
			right = right.rotated(n, rot)
			up = up.rotated(n, rot)
		var hw := right * w * 0.5
		var hh := up * h * 0.5
		var corners := [c - hw + hh, c + hw + hh, c + hw - hh, c - hw - hh]
		var uvs := [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]
		for k in [0, 1, 2, 0, 2, 3]:
			var p: Vector3 = corners[k]
			var sph := ((p - cc) / cr).normalized()
			var nn := (sph * bend + n * (1.0 - bend)).normalized()
			var cl := Color(col.r, col.g, col.b) * ao(p, cc, cr)
			cl.a = 1.0
			vtx(p, nn, TreeKit.cuv(cell, uvs[k].x, uvs[k].y), cl, flut)

	func crown(cc: Vector3, cr: Vector3, n: int, cell: String, size: float, col: Color, up_bias := 0.6, ymin := -0.45,
			flut := 0.35, aspect := 1.0, shell := Vector2(0.7, 1.0), spin := TAU) -> Array:
		## n cards spread over an ellipsoid (golden-angle spiral, top first), facing outward and up; returns the centres
		var pts: Array = []
		var ga := PI * (3.0 - sqrt(5.0))
		var off := rng.randf() * TAU
		for i in n:
			var y := lerpf(0.95, ymin, (i + 0.5) / n)
			var rr := sqrt(maxf(0.0, 1.0 - y * y))
			var a := off + ga * i
			var d := Vector3(cos(a) * rr, y, sin(a) * rr)
			d = (d + Vector3(rng.randf_range(-0.18, 0.18), rng.randf_range(-0.1, 0.1), rng.randf_range(-0.18, 0.18))).normalized()
			var p := cc + d * cr * rng.randf_range(shell.x, shell.y)
			var nrm := (d + Vector3.UP * up_bias).normalized()
			var s := size * rng.randf_range(0.82, 1.18)
			var cv := rng.randf_range(0.92, 1.05)
			if lod == 2:
				cv = 1.0 + (cv - 1.0) * 0.3   # far: one mid-tone per tree
			card(p, nrm, s * aspect, s, cell, col * cv, cc, cr, rng.randf_range(-0.5, 0.5) * spin, flut)
			pts.append(p)
		return pts

	func core(cc: Vector3, cr: Vector3, cell: String, col: Color, seg := 6, rings := 4, uvs := 0.22, any_lod := false) -> void:
		## a lumpy, dark inner volume for dense crowns, only seen through the gaps between the cards (LOD 0 only,
		## unless any_lod: the date bunches)
		if lod > 0 and not any_lod:
			return
		for j in rings:
			var t0 := PI * j / rings
			var t1 := PI * (j + 1) / rings
			for i in seg:
				var p0 := TAU * i / seg
				var p1 := TAU * (i + 1) / seg
				var quad: Array = []
				for tp in [[t0, p0], [t1, p0], [t1, p1], [t0, p1]]:
					quad.append(Vector3(sin(tp[0]) * cos(tp[1]), cos(tp[0]), sin(tp[0]) * sin(tp[1])))
				for k in [0, 1, 2, 0, 2, 3]:
					var u: Vector3 = quad[k]
					var jit := 1.0 + 0.14 * sin(u.x * 9.0 + u.z * 5.0 + float(rng.seed % 7)) * cos(u.y * 7.0)
					var p := cc + u * cr * jit
					var cl := Color(col.r, col.g, col.b) * ao(p, cc, cr * 1.3)
					cl.a = 0.5
					vtx(p, u, TreeKit.cuv("bark", 0.5 + u.x * uvs, 0.5 + u.z * uvs), cl, 0.1)

	func limb(a: Vector3, b: Vector3, r0: float, r1: float, sides: int, bend := 0.0, col := Color(0.42, 0.33, 0.25)) -> void:
		## a branch from a to b with a slight upward bow
		var mid := (a + b) * 0.5 + Vector3(0, bend, 0)
		tube([a, mid, b], [r0, (r0 + r1) * 0.5, r1], sides, col, col.lightened(0.08))


# ---------------------------------------------------------------- species (metres; +Y up, base at 0)

static func _pick(b: Builder, l0: int, l1: int, l2: int) -> int:
	return [l0, l1, l2][b.lod]


static func _pine(b: Builder) -> void:
	## Aleppo pine: a tall, leaning bare trunk that forks into a candelabra of limbs, each ending in a broad flat pad
	## of needle tufts; the pads overlap into the open umbrella crown of the Carmel and the Jerusalem hills
	var sides := _pick(b, 6, 5, 3)
	var top := Vector3(1.0, 7.2, 0.3)
	b.tube([Vector3(0, -2, 0), Vector3(0, 0, 0), Vector3(0.45, 3.4, 0.1), top], [0.55, 0.5, 0.4, 0.3], sides, BARK * 0.85, BARK)
	var pk := 1.22 * (1.08 if b.lod == 2 else 1.0)   # v5 fix: a wider umbrella (forest cover at least the v4 blobs')
	var cc := Vector3(0.5, 10.9, 0.2)
	var cr := Vector3(6.4 * pk, 2.2, 6.2 * pk)
	var pads := [Vector3(3.9, 10.4, 1.7), Vector3(-2.9, 10.9, -1.2), Vector3(1.4, 11.9, -3.3), Vector3(-1.0, 10.2, 3.4), Vector3(0.6, 12.2, 0.4), Vector3(-3.3, 11.6, 1.9)]
	var npads := _pick(b, 6, 4, 3)
	# the umbrella's body under the pads (every LOD), so no ground shows through the crown; darker underneath
	b.dome(cc + Vector3(0, -0.5, 0), Vector3(5.0 * pk, 1.3, 4.8 * pk), "pine", Color(0.86, 0.96, 0.74), _pick(b, 8, 7, 6), 3, 0.7, 0.32, 0.4)
	for i in npads:
		var p: Vector3 = cc + ((pads[i] as Vector3) - cc) * Vector3(pk, 1.0, pk)
		if b.lod < 2:
			b.limb(top, p - Vector3(0, 0.7, 0), 0.26, 0.1, _pick(b, 4, 3, 3), 0.5)
		var n := _pick(b, 4, 3, 3)
		for k in n:
			var o := Vector3(b.rng.randf_range(-1.6, 1.6) * pk, b.rng.randf_range(-0.25, 0.45), b.rng.randf_range(-1.6, 1.6) * pk)
			var nrm := (Vector3.UP * 1.8 + (o + p - cc).normalized()).normalized()
			var sz := b.rng.randf_range(4.4, 5.4) * float([1.0, 1.15, 1.35][b.lod]) * pk
			b.card(p + o, nrm, sz, sz * 0.85, "pine", Color(0.92, 1.0, 0.84) * b.rng.randf_range(0.95, 1.05), cc, cr, b.rng.randf() * TAU, 0.3, 0.7)
		if b.lod == 0:   # a steeper card on each pad's rim, for the side view
			var out := Vector3(p.x - cc.x, 0, p.z - cc.z).normalized()
			b.card(p + out * 1.8 - Vector3(0, 0.2, 0), (out + Vector3.UP * 0.6).normalized(), 3.8, 2.6, "pine", Color(0.95, 0.95, 0.95), cc, cr, 0.0, 0.3, 0.7)


static func _clumps(b: Builder, clumps: Array, cell: String, hull: Color, leaf: Color, cards: Array, size: float, flat := 0.5,
		uvs := 0.3, up_bias := 0.35, flut := 0.35, hull_cell := "") -> void:
	## a crown of domed clumps ([centre, radii] in metres, scaled by CROWN about the trunk axis), each an opaque
	## painted dome with leaf cards on its upper surface (cards = per LOD) for a leafy, lumpy outline
	var seg := _pick(b, 8, 7, 5)
	var rings := _pick(b, 4, 4, 3)
	var per: int = cards[b.lod]
	for cl in clumps:
		var c: Vector3 = cl[0] * Vector3(CROWN, 1.0, CROWN) + Vector3(0, (CROWN - 1.0) * 2.0, 0)
		var r: Vector3 = cl[1] * CROWN * (1.1 if b.lod == 2 else 1.0)   # far: a little fuller (no alpha fringe)
		b.dome(c, r, cell if hull_cell == "" else hull_cell, hull, seg, rings, flat, uvs)
		if per > 0:
			b.crown(c, r, per, cell, size * CROWN * float([1.0, 1.12, 1.3][b.lod]), leaf, up_bias, -0.1, flut, 1.0, Vector2(0.86, 1.02))


static func _broad(b: Builder) -> void:
	## broadleaf (Tabor oak, carob, terebinth; ficus and plane in towns): a short trunk and limbs under a full,
	## rounded crown of three domed clumps (two low, one on top), dark underneath, leafy at the outline
	var sides := _pick(b, 6, 5, 3)
	var fork := Vector3(0.2, 3.0, 0.0)
	b.tube([Vector3(0, -2, 0), Vector3(0, 0, 0), Vector3(0.1, 1.6, 0.05), fork], [0.6, 0.55, 0.45, 0.38], sides, BARK * 0.8, BARK)
	var clumps := [[Vector3(2.0, 6.6, 1.0), Vector3(3.6, 3.1, 3.4)], [Vector3(-2.1, 6.9, -0.9), Vector3(3.5, 3.2, 3.4)],
		[Vector3(0.1, 9.0, -0.1), Vector3(3.3, 2.9, 3.2)]]
	if b.lod < 2:
		for i in 3:
			var lc: Vector3 = clumps[i][0]
			b.limb(fork, lc - (lc - fork).normalized() * 1.6, 0.3, 0.12, _pick(b, 4, 3, 3), 0.4)
	_clumps(b, clumps, "broad", Color(0.92, 1.0, 0.86), Color(1, 1, 1), [6, 4, 1], 3.5, 0.62)


static func _olive(b: Builder) -> void:
	## olive: two gnarled, twisting trunks from a wide base, low spreading limbs and a round, silver-green crown of
	## three soft clumps
	var sides := _pick(b, 6, 5, 3)
	var c0 := BARK.lerp(Color(0.5, 0.47, 0.42), 0.5)
	b.tube([Vector3(0, -1.5, 0), Vector3(0.1, 0, 0), Vector3(0.45, 0.7, 0.2), Vector3(0.2, 1.4, 0.45), Vector3(0.7, 2.1, 0.3)], [0.6, 0.55, 0.42, 0.36, 0.28], sides, c0 * 0.8, c0)
	if b.lod < 2:
		b.tube([Vector3(0, -1.5, 0), Vector3(-0.15, 0, -0.1), Vector3(-0.6, 0.9, -0.25), Vector3(-0.45, 1.6, -0.7), Vector3(-0.9, 2.3, -0.8)], [0.5, 0.45, 0.36, 0.3, 0.24], sides, c0 * 0.8, c0)
		var ends := [Vector3(1.6, 3.4, 0.8), Vector3(-1.6, 3.6, -0.7), Vector3(0.3, 4.3, 0.2)]
		for i in 3:
			b.limb(Vector3(0.7, 2.1, 0.3) if i % 2 == 0 else Vector3(-0.9, 2.3, -0.8), ends[i], 0.22, 0.08, 3, 0.3, c0)
	var clumps := [[Vector3(1.4, 3.9, 0.7), Vector3(2.9, 2.3, 2.8)], [Vector3(-1.4, 4.1, -0.6), Vector3(2.8, 2.4, 2.7)],
		[Vector3(0.1, 5.0, 0.1), Vector3(2.5, 1.8, 2.5)]]
	_clumps(b, clumps, "olive", Color(0.84, 1.0, 0.76), Color(0.88, 1.0, 0.82), [7, 4, 1], 2.9, 0.65, 0.3, 0.45, 0.4)


static func _citrus(b: Builder) -> void:
	## orange / citrus: short trunk, a dense, round, glossy crown almost to the ground (one big dome and a smaller
	## one), fruit in the painted cards
	var sides := _pick(b, 5, 4, 3)
	b.tube([Vector3(0, -1.5, 0), Vector3(0, 0, 0), Vector3(0.05, 1.1, 0.0)], [0.3, 0.25, 0.2], sides, BARK * 0.8, BARK)
	var clumps := [[Vector3(0.0, 2.7, 0.0), Vector3(3.0, 2.3, 3.0)], [Vector3(0.6, 3.9, -0.4), Vector3(2.0, 1.5, 2.0)]]
	_clumps(b, clumps, "citrus", Color(0.88, 1.0, 0.9), Color(1, 1, 1), [8, 5, 2], 2.9, 0.6, 0.32, 0.4, 0.3)


static func _cypress(b: Builder) -> void:
	## Mediterranean cypress: a dark, narrow flame-shaped column (a ragged spindle) with two crossed painted cards
	var sides := _pick(b, 7, 6, 4)
	var rings := _pick(b, 9, 6, 4)
	b.tube([Vector3(0, -2, 0), Vector3(0, 1.2, 0)], [0.35, 0.3], 3, BARK * 0.8, BARK)
	var H := 17.5
	var col := Color(0.62, 0.72, 0.6) * (1.14 if b.lod == 2 else 1.0)   # far: less of a dark speck
	for j in rings:
		var t0 := float(j) / rings
		var t1 := float(j + 1) / rings
		for i in sides:
			var a0 := TAU * i / sides
			var a1 := TAU * (i + 1) / sides
			var quad: Array = []
			for ta in [[t0, a0], [t1, a0], [t1, a1], [t0, a1]]:
				var t: float = ta[0]
				var r := 2.75 * pow(sin(PI * clampf(t * 0.92 + 0.06, 0.0, 1.0)), 0.55) * (1.0 - 0.62 * t)
				r *= 1.0 + 0.16 * sin(float(ta[1]) * 3.0 + t * 17.0) * (1.0 if t > 0.001 and t < 0.999 else 0.0)
				var y := 0.8 + t * H
				quad.append([Vector3(cos(ta[1]) * r, y, sin(ta[1]) * r), Vector3(cos(ta[1]), 0.35 - t * 0.2, sin(ta[1])).normalized(), ta])
			for k in [0, 1, 2, 0, 2, 3]:
				var e: Array = quad[k]
				var p: Vector3 = e[0]
				var tt: float = e[2][0]
				var cl := col * lerpf(0.6, 1.0, clampf(tt * 1.4, 0.0, 1.0))
				cl.a = 1.0
				b.vtx(p, e[1], cuv("pine", 0.3 + 0.4 * float(e[2][1]) / TAU, 0.72 - tt * 0.44), cl, 0.15 * tt)
	if b.lod < 2:
		var cc := Vector3(0, 8.5, 0)
		var cr := Vector3(2.6, 8.5, 2.6)
		for k in 2:
			var a := PI * 0.5 * k + 0.4
			b.card(Vector3(0, 0.6 + H * 0.5, 0), Vector3(cos(a), 0, sin(a)), 5.6, H + 0.6, "cypress", Color(0.95, 0.97, 0.92), cc, cr, 0.0, 0.2, 0.75)


static func _frond(b: Builder, base: Vector3, dir: Vector3, length: float, width: float, elev: float, droop: float, segs: int, fold: bool, col: Color, cc: Vector3, cr: Vector3) -> void:
	## one pinnate frond: a strip along an arching curve, V-folded along the rib in LOD 0; UV u along the frond
	var h := Vector3(dir.x, 0, dir.z).normalized()
	var side := Vector3.UP.cross(h).normalized()
	var rows: Array = []
	for k in segs + 1:
		var t := float(k) / segs
		var p := base + h * cos(elev) * length * t + Vector3.UP * (sin(elev) * length * t - droop * length * t * t)
		var tang := (h * cos(elev) + Vector3.UP * (sin(elev) - 2.0 * droop * t)).normalized()
		var s := side * width * 0.5
		var lift := tang.cross(side).normalized() * width * 0.22 if fold else Vector3.ZERO
		rows.append([p - s - lift, p + lift * 0.0, p + s - lift, t])
	for k in segs:
		var r0: Array = rows[k]
		var r1: Array = rows[k + 1]
		var t0: float = r0[3]
		var t1: float = r1[3]
		var strips := [[0, 1], [1, 2]] if fold else [[0, 2]]
		for sp in strips:
			var va0 := 0.0 if sp[0] == 0 else 0.5
			var va1 := 0.5 if sp[1] == 1 else 1.0
			var q := [[r0[sp[0]], t0, va0], [r1[sp[0]], t1, va0], [r1[sp[1]], t1, va1], [r0[sp[1]], t0, va1]]
			for kk in [0, 1, 2, 0, 2, 3]:
				var e: Array = q[kk]
				var p: Vector3 = e[0]
				var sph := ((p - cc) / cr).normalized()
				var nn := (sph * 0.7 + Vector3.UP * 0.5).normalized()
				var cl := Color(col.r, col.g, col.b) * lerpf(0.72, 1.05, clampf(float(e[1]) * 1.2 + (p.y - cc.y) / cr.y * 0.3, 0.0, 1.0))
				cl.a = 1.0
				b.vtx(p, nn, cuv("datefrond", 0.02 + float(e[1]) * 0.96, float(e[2])), cl, 0.25 + float(e[1]))


static func _date_palm(b: Builder, base: Vector3, h: float, lean: Vector3, nf: int, flen: float) -> void:
	## date palm: a curved, scaly ringed trunk and a crown of arching pinnate fronds with a few upright young
	## ones, and orange date bunches under the crown (LOD 0)
	var sides := _pick(b, 6, 5, 3)
	var top := base + Vector3(0, h, 0) + lean
	var pts: Array = [base + Vector3(0, -2, 0), base]
	var rad: Array = [0.5, 0.48]
	var segs := _pick(b, 4, 3, 1)
	for i in range(1, segs + 1):
		var t := float(i) / segs
		pts.append(base + Vector3(0, h * t, 0) + lean * t * t)
		rad.append(lerpf(0.46, 0.34, t))
	var tc := Color(0.62, 0.5, 0.38)
	b.tube(pts, rad, sides, tc * 0.8, tc, "palmtrunk")
	var cc := top + Vector3(0, 0.6, 0)
	var cr := Vector3(flen, flen * 0.5, flen)
	var leaf := Color(0.98, 1.0, 0.92)
	var segf := _pick(b, 3, 3, 1)
	var fold := b.lod == 0
	var ga := PI * (3.0 - sqrt(5.0))
	for f in nf:
		var a := ga * f * 2.0 + b.rng.randf_range(-0.1, 0.1)
		var upper := f >= int(nf * 0.68)
		var elev := b.rng.randf_range(0.75, 1.05) if upper else b.rng.randf_range(0.05, 0.42)
		var droop := 0.25 if upper else b.rng.randf_range(0.42, 0.6)
		var ln := flen * (0.72 if upper else b.rng.randf_range(0.9, 1.08))
		_frond(b, top, Vector3(cos(a), 0, sin(a)), ln, ln * float([0.48, 0.54, 0.6][b.lod]), elev, droop, segf, fold, leaf * b.rng.randf_range(0.9, 1.04), cc, cr)
	if b.lod == 0:
		for k in 3:
			var a := TAU * k / 3.0 + 0.5
			var p := top + Vector3(cos(a) * 0.6, -0.8, sin(a) * 0.6)
			b.core(p, Vector3(0.26, 0.45, 0.26), "bark", Color(0.62, 0.36, 0.14), 4, 2, 0.1, true)
	else:
		b.core(top + Vector3(0, -0.4, 0), Vector3(0.6, 0.7, 0.6), "bark", Color(0.6, 0.48, 0.3), 3 if b.lod == 2 else 4, 2, 0.1, true)


static func _palm_cluster(b: Builder) -> void:
	## a date-palm clump (oases, the Arava, the Jordan valley): four curving stems of different heights from one base
	var stems := [[Vector3(-0.3, 0, -0.2), 10.5, Vector3(-1.4, 0, -1.0)], [Vector3(0.9, 0, -0.5), 8.2, Vector3(4.2, 0, -2.6)],
		[Vector3(-0.8, 0, 0.6), 6.4, Vector3(-4.0, 0, 2.6)], [Vector3(0.3, 0, 1.0), 4.4, Vector3(1.4, 0, 3.6)]]
	var n := _pick(b, 4, 4, 3)
	for i in n:
		var s: Array = stems[i]
		_date_palm(b, s[0], s[1], s[2], _pick(b, 11, 8, 5), 5.2 + float(s[1]) * 0.1)
	if b.lod < 2:   # suckers at the foot
		var cc := Vector3(0, 1.0, 0)
		var cr := Vector3(3, 1.5, 3)
		for k in _pick(b, 5, 3, 0):
			var a := TAU * k / 5.0 + 0.3
			_frond(b, Vector3(cos(a) * 0.4, 0.2, sin(a) * 0.4), Vector3(cos(a), 0, sin(a)), 2.8, 0.9, 0.9, 0.45, 2, false, Color(0.92, 0.95, 0.85), cc, cr)


static func _fanpalm(b: Builder) -> void:
	## Washingtonia fan palm (Tel Aviv's boulevards): a very tall, slim straight trunk, a skirt of dry fronds under a
	## small round head of pleated fan leaves on short stalks
	var sides := _pick(b, 6, 5, 3)
	var H := 19.0
	var top := Vector3(0.4, H, 0)
	b.tube([Vector3(0, -2, 0), Vector3(0, 0, 0), Vector3(0.1, H * 0.5, 0), top], [0.55, 0.5, 0.36, 0.32], sides, Color(0.55, 0.47, 0.38), Color(0.62, 0.55, 0.45), "palmtrunk")
	# the dead-frond skirt: a short tube textured with the dry fronds, ragged at the bottom (alpha)
	var sk := _pick(b, 7, 5, 4)
	b.tube([top - Vector3(0, 3.0, 0), top - Vector3(0, 1.4, 0), top + Vector3(0, 0.3, 0)], [0.62, 0.72, 0.75], sk, Color(0.8, 0.72, 0.62), Color(0.95, 0.9, 0.82), "deadfronds", 0.5)
	var cc := top + Vector3(0, 1.2, 0)
	var cr := Vector3(3.2, 2.4, 3.2)
	var n := _pick(b, 15, 10, 6)
	var ga := PI * (3.0 - sqrt(5.0))
	for f in n:
		var a := ga * f * 2.0
		var d := Vector3(cos(a), 0, sin(a))
		var upper := f >= int(n * 0.6)
		var el := b.rng.randf_range(0.7, 1.05) if upper else b.rng.randf_range(0.1, 0.45)
		var dir := (d * cos(el) + Vector3.UP * sin(el)).normalized()
		var s: float = b.rng.randf_range(3.4, 4.0) * float([1.0, 1.1, 1.3][b.lod])
		var c := top + Vector3(0, 0.5, 0) + dir * (s * 0.55)
		# the fan faces outward and up; its stalk end (bottom of the card) points back to the head
		var nrm := (d * 0.6 + Vector3.UP * 0.8).normalized() if not upper else (d + Vector3.UP * 0.2).normalized()
		var right := Vector3.UP.cross(d).normalized()
		var up_v := nrm.cross(right).normalized()
		var rot := up_v.signed_angle_to(dir, nrm) if up_v.length() > 0.5 else 0.0
		b.card(c, nrm, s, s, "fanfrond", Color(1, 1, 1) * b.rng.randf_range(0.9, 1.04), cc, cr, rot, 0.6, 0.65)


static func _eucalyptus(b: Builder) -> void:
	## eucalyptus (the planted groves of the coastal plain and the valleys): a tall pale trunk that forks high, with
	## a tall, open, irregular crown of hanging grey-green leaves
	var sides := _pick(b, 6, 5, 3)
	var bc := Color(0.82, 0.78, 0.7)
	var fork := Vector3(0.5, 6.0, 0.2)
	b.tube([Vector3(0, -2, 0), Vector3(0, 0, 0), Vector3(0.3, 3.5, 0.1), fork], [0.65, 0.6, 0.45, 0.36], sides, bc * 0.75, bc)
	var lobes := [[Vector3(1.9, 9.0, 0.9), Vector3(4.2, 3.9, 4.0)], [Vector3(-1.6, 11.6, -0.8), Vector3(4.0, 4.1, 3.9)], [Vector3(0.4, 14.8, 0.3), Vector3(3.4, 3.2, 3.4)]]
	if b.lod < 2:
		for i in lobes.size():
			var lc: Vector3 = lobes[i][0]
			b.limb(fork, lc - Vector3(0, 1.2, 0), 0.3, 0.12, _pick(b, 4, 3, 3), 0.2, bc)
	# tall, irregular grey-green clumps with hanging leaf cards around them
	_clumps(b, lobes, "eucalyptus", Color(0.84, 0.95, 0.8), Color(0.84, 1.0, 0.74), [6, 3, 1], 3.9, 0.6, 0.3, 0.15, 0.45, "broad")


static func _shrub(b: Builder, cell: String, col: Color, h: float, r: float, stems: int) -> void:
	## flowering shrubs (oleander along streams and in town medians, bougainvillea on walls): a few stems and a
	## dense dome of flowering cards
	var cc := Vector3(0, h * 0.62, 0)
	var cr := Vector3(r, h * 0.42, r * 0.95)
	if b.lod < 2:
		for i in _pick(b, stems, 2, 0):
			var a := TAU * i / stems + 0.3
			b.tube([Vector3(0, -1, 0), Vector3(0, 0, 0), Vector3(cos(a) * r * 0.45, h * 0.55, sin(a) * r * 0.45)], [0.12, 0.1, 0.05], 3, BARK, BARK)
	b.dome(cc + Vector3(0, -0.1, 0), cr * 0.92, cell, Color(0.92, 1.0, 0.88), _pick(b, 7, 6, 5), _pick(b, 4, 3, 3), 0.6, 0.3)
	b.crown(cc, cr, _pick(b, 9, 6, 2), cell, _pick(b, r * 1.25, r * 1.5, r * 1.9), col, 0.5, -0.1, 0.35, 1.0, Vector2(0.85, 1.02), 0.6)


static func _acacia(b: Builder) -> void:
	## umbrella-thorn acacia of the Negev and Arava wadis: several thin trunks splaying from the foot and a very flat,
	## wide, thin crown
	var stems := [Vector3(1.7, 4.1, 0.9), Vector3(-1.5, 4.3, -0.6), Vector3(0.2, 4.6, -1.7)]
	var c0 := Color(0.4, 0.33, 0.27)
	var cc := Vector3(0.0, 5.4, 0.0)
	var cr := Vector3(5.3, 0.8, 5.0)
	for i in _pick(b, 3, 3, 2):
		var e: Vector3 = stems[i]
		b.tube([Vector3(0, -1.5, 0), Vector3(0, 0, 0), e * Vector3(0.35, 0.45, 0.35), e], [0.3, 0.26, 0.17, 0.1], _pick(b, 4, 3, 3), c0 * 0.85, c0)
		if b.lod == 0:
			b.limb(e, e + Vector3(e.x * 0.9, 0.9, e.z * 0.9), 0.09, 0.04, 3, 0.2, c0)
	b.dome(cc + Vector3(0, -0.15, 0), Vector3(4.6, 0.75, 4.4), "acacia", Color(0.9, 1.0, 0.85), _pick(b, 8, 7, 6), 3, 0.5, 0.3, 0.35)
	var n := _pick(b, 7, 5, 3)
	b.crown(cc, cr, n, "acacia", _pick(b, 2.8, 3.2, 3.8), Color(1, 1, 1), 3.0, 0.1, 0.35, 2.5, Vector2(0.4, 0.8), 0.6)
	if b.lod == 0:   # a couple of steeper rim cards so the crown keeps its edge from the side
		for k in 3:
			var a := TAU * k / 3.0 + 0.7
			var d := Vector3(cos(a), 0, sin(a))
			b.card(cc + d * 3.2, (d + Vector3.UP * 0.9).normalized(), 5.0, 1.9, "acacia", Color(0.95, 0.95, 0.95), cc, cr, 0.0, 0.35, 0.7)
