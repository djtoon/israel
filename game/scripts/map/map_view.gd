class_name MapView
extends Node3D
## Public map API for gameplay/UI code (see MAP_API.md). Lives at Main/MapView, group "map_view".
## Everything here is presentation only: the sim owns the truth and pushes it in.

signal tile_clicked(q: int, r: int)
signal tile_right_clicked(q: int, r: int)
signal tile_hovered(q: int, r: int)
signal city_clicked(id: String)

var map: MapData
var renderer: TerrainRenderer
var rig: CameraRig
var labels: MapLabels
var units := {}            # id -> Node3D
var _hl_layers := {}       # layer -> {Vector2i: Color}
var _hl_img: Image
var _hl_tex: ImageTexture


func setup(m: MapData, r: TerrainRenderer, c: CameraRig, l: MapLabels) -> void:
	map = m; renderer = r; rig = c; labels = l
	add_to_group("map_view")
	_hl_img = Image.create(map.cols, map.rows, false, Image.FORMAT_RGBA8)
	_hl_img.fill(Color(0, 0, 0, 0))
	_hl_tex = ImageTexture.create_from_image(_hl_img)
	renderer.terrain_mat.set_shader_parameter("hl_tex", _hl_tex)


# ------------------------------------------------------------------ tiles

func highlight_tiles(tiles: Array, color: Color, layer := "default") -> void:
	## tiles: [Vector2i] or [[q, r]]; replaces that layer. Later layers draw over earlier ones.
	var d := {}
	for t in tiles:
		var k := t as Vector2i if t is Vector2i else Vector2i(int(t[0]), int(t[1]))
		d[k] = color
	_hl_layers[layer] = d
	_rebuild_highlights()


func clear_highlights(layer := "") -> void:
	if layer == "":
		_hl_layers.clear()
	else:
		_hl_layers.erase(layer)
	_rebuild_highlights()


# ---- ui-v2 hooks: labelled tile highlights (district lens) and worked-tile markers (citizen management)

var _label_layers := {}
var _worked_layers := {}


func set_tile_labels(entries: Array, layer := "labels") -> void:
	## entries: [{q, r, label: String, color: Color}] (also accepts "tile": Vector2i). Each tile gets a tinted
	## fill and rim in `color` plus `label` (e.g. "+3") drawn at the hex centre. Replaces that layer.
	var d := {}
	for e in entries:
		var k := Vector2i(int(e["q"]), int(e["r"])) if e.has("q") else (e["tile"] as Vector2i)
		d[k] = {"label": str(e.get("label", "")), "color": e.get("color", Color(1, 0.9, 0.4, 0.8))}
	_label_layers[layer] = d
	var hl := {}
	for k in d:
		hl[k] = d[k]["color"]
	_hl_layers["lbl:" + layer] = hl
	_rebuild_highlights()
	_push_markers()


func clear_tile_labels(layer := "") -> void:
	if layer == "":
		for l in _label_layers:
			_hl_layers.erase("lbl:" + l)
		_label_layers.clear()
	else:
		_label_layers.erase(layer)
		_hl_layers.erase("lbl:" + layer)
	_rebuild_highlights()
	_push_markers()


func set_worked_tiles(worked: Array, locked: Array = [], layer := "worked") -> void:
	## worked / locked: [Vector2i] or [[q, r]]. Worked tiles get a citizen ring marker, locked ones a padlock-style
	## gold marker. Replaces that layer.
	var d := {}
	for t in worked:
		d[_k(t)] = false
	for t in locked:
		d[_k(t)] = true
	_worked_layers[layer] = d
	_push_markers()


func clear_worked_tiles(layer := "") -> void:
	if layer == "":
		_worked_layers.clear()
	else:
		_worked_layers.erase(layer)
	_push_markers()


func _k(t) -> Vector2i:
	return t as Vector2i if t is Vector2i else Vector2i(int(t[0]), int(t[1]))


func _push_markers() -> void:
	if labels == null:
		return
	var tl := {}
	for layer in _label_layers:
		tl.merge(_label_layers[layer], true)
	var wk := {}
	for layer in _worked_layers:
		wk.merge(_worked_layers[layer], true)
	labels.tile_labels = tl
	labels.worked_tiles = wk


func _rebuild_highlights() -> void:
	var merged := {}
	for layer in _hl_layers:
		var d: Dictionary = _hl_layers[layer]
		for k in d:
			merged[k] = d[k]
	if labels:
		labels.highlights = merged   # screen-space rims drawn above buildings
	_hl_img.fill(Color(0, 0, 0, 0))
	for layer in _hl_layers:
		var d: Dictionary = _hl_layers[layer]
		for k in d:
			if k.x >= 0 and k.y >= 0 and k.x < map.cols and k.y < map.rows:
				_hl_img.set_pixelv(k, d[k])
	_hl_tex.update(_hl_img)


func tile_world(q: int, r: int) -> Vector3:
	var c := TerrainMath.offset_center(q, r)
	return Vector3(c.x, maxf(0.0, renderer.height_at(c.x, c.y)), c.y)


func tile_info(q: int, r: int) -> Dictionary:
	return map.tile_at(Vector2i(q, r))


func city_at(q: int, r: int) -> Dictionary:
	for c in map.cities:
		if int(c["q"]) == q and int(c["r"]) == r:
			return c
	return {}


# ------------------------------------------------------------------ cities

func focus_city(id: String, zoom := 2.0) -> void:
	var c := map.find_city(id)
	if c.is_empty():
		return
	var p: Vector2 = c["pos"]
	rig.set_view(p.x, p.y + 0.4, zoom, false)


func focus_tile(q: int, r: int, zoom := -1.0) -> void:
	var c := TerrainMath.offset_center(q, r)
	rig.set_view(c.x, c.y + 0.4, rig.zoom if zoom < 0 else zoom, false)


func set_city_info(id: String, pop = null, name = null, badge = null) -> void:
	## Override what a city's banner shows. pop: int (banner number), name: String,
	## badge: "israel" | "israel_beyond_lines" | "palestine" | "jordan" | "egypt" | "syria" | "lebanon" | "hamas" | "contested".
	## Pass null to leave a field unchanged. Overrides survive date changes.
	var o: Dictionary = map.city_info.get(id, {})
	if pop != null: o["display_pop"] = int(pop)
	if name != null: o["name"] = str(name)
	if badge != null: o["badge"] = str(badge)
	map.city_info[id] = o
	map.apply_city_info()


func force_city(id: String, on := true) -> void:
	## Show a real locality from now on even if history founds it later (player founded it early).
	if on:
		map.forced[id] = true
	else:
		map.forced.erase(id)
	var game := get_tree().get_first_node_in_group("game")
	if game and game.has_method("set_date"):
		game.set_date(game.turn, true)


func cities() -> Array:
	## localities shown at the current date: [{id, name, q, r, pos, pop, size, control, status, ...}]
	return map.cities


# ------------------------------------------------------------------ units

func show_unit(id: String, q: int, r: int, model: String, yaw_deg := 0.0, tint := Color.WHITE, ring := Color(0, 0, 0, 0)) -> void:
	## model: a manifest id (e.g. "unit_palmach_infantry"); hex-scale, yaw_fix applied.
	## tint multiplies the model's colours; ring (alpha > 0) draws a faction-coloured disc under the unit.
	remove_unit(id, true)
	var a: Dictionary = CityBuilder.manifest().get(model, {})
	if a.is_empty() or not ResourceLoader.exists("res://assets/" + str(a["file"])):
		push_warning("map: unknown unit model " + model)
		return
	var holder := Node3D.new()
	holder.name = "Unit_" + id
	var n: Node3D = (load("res://assets/" + str(a["file"])) as PackedScene).instantiate()
	var s := TerrainMath.SQ3 * 0.36 * float(a.get("suggested_scale", 1.0))
	n.scale = Vector3.ONE * s
	n.rotation.y = deg_to_rad(float(a.get("yaw_fix", 0.0) if a.get("yaw_fix") != null else 0.0))
	holder.add_child(n)
	holder.rotation.y = deg_to_rad(yaw_deg)
	add_child(holder)
	for mi in n.find_children("*", "MeshInstance3D", true, false):
		var m := mi as MeshInstance3D
		CityBuilder._fix_materials(m)
		if tint != Color.WHITE:
			for si in m.mesh.get_surface_count():
				var sm := m.get_surface_override_material(si)
				if sm is ShaderMaterial:
					var d := (sm as ShaderMaterial).duplicate() as ShaderMaterial
					d.set_shader_parameter("tint", Vector3(tint.r, tint.g, tint.b))
					m.set_surface_override_material(si, d)
	if false and ring.a > 0.0:   # ring decals read as stray blue props in cities; the UI flag shows the faction
		var disc := MeshInstance3D.new()
		var cm := TorusMesh.new()
		cm.inner_radius = 0.15; cm.outer_radius = 0.18; cm.rings = 32; cm.ring_segments = 6
		disc.mesh = cm
		var dm := StandardMaterial3D.new()
		dm.albedo_color = ring
		dm.emission_enabled = true
		dm.emission = ring * 0.4
		disc.material_override = dm
		disc.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		disc.position.y = 0.01
		holder.add_child(disc)
	var naval := model.contains("boat") or model.contains("ship")
	holder.set_meta("naval", naval)
	holder.set_meta("air", model.contains("jet"))
	holder.set_meta("gun", model.contains("merkava") or model.contains("sherman") or model.contains("iron_dome") or model.contains("truck"))
	holder.set_meta("phase", fposmod(float(hash(id)) * 0.00137, TAU))
	holder.set_meta("base_y", n.position.y)
	holder.position = _unit_pos(q, r, naval)
	holder.set_meta("qr", Vector2i(q, r))
	units[id] = holder


func move_unit(id: String, q: int, r: int, seconds := 0.6) -> void:
	## Walks the unit hex by hex along the straight hex line from its current hex (no teleporting). `seconds`
	## is the minimum time; long paths take ~0.28 s per hex (max 2.4 s). Faces the direction of travel.
	var u: Node3D = units.get(id)
	if u == null or not u.is_inside_tree():
		return
	var naval := bool(u.get_meta("naval", false))
	var from: Vector2i = u.get_meta("qr", Vector2i(q, r))
	var path: Array = _hex_line(from, Vector2i(q, r))
	var pts: Array = []
	for i in range(1, path.size()):
		pts.append(_unit_pos(path[i].x, path[i].y, naval))
	if pts.is_empty():
		pts.append(_unit_pos(q, r, naval))
	var total := clampf(maxf(seconds, 0.28 * pts.size()), 0.1, 2.4)
	var each: float = total / pts.size()
	u.set_meta("qr", Vector2i(q, r))
	if u.has_meta("move_tw"):
		var old = u.get_meta("move_tw")
		if old is Tween and (old as Tween).is_valid():
			(old as Tween).kill()
	var tw := u.create_tween()   # bound to the unit: freed with it, so no callbacks on a dead node
	u.set_meta("move_tw", tw)
	u.set_meta("moving", true)
	for p in pts:
		tw.tween_callback(_face_unit.bind(u, p))
		tw.tween_property(u, "position", p, each).set_trans(Tween.TRANS_SINE if pts.size() == 1 else Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tw.tween_callback(u.set_meta.bind("moving", false))


func _face_unit(u: Node3D, to: Vector3) -> void:
	if not is_instance_valid(u):
		return
	var d := to - u.position
	if Vector2(d.x, d.z).length() > 0.01:
		u.rotation.y = atan2(d.x, d.z)


func _hex_line(a: Vector2i, b: Vector2i) -> Array:
	## offset (q, r) hexes on the line a -> b, inclusive (via axial/cube rounding)
	var aa: Vector2i = TerrainMath.offset_to_axial(a)
	var bb: Vector2i = TerrainMath.offset_to_axial(b)
	var n := maxi(1, int((absi(aa.x - bb.x) + absi(aa.x + aa.y - bb.x - bb.y) + absi(aa.y - bb.y)) / 2))
	var out: Array = []
	for i in n + 1:
		var t := float(i) / n
		var fx := lerpf(aa.x, bb.x, t) + 1e-6
		var fy := lerpf(aa.y, bb.y, t) + 1e-6
		var fz := -fx - fy
		var rx := roundf(fx)
		var ry := roundf(fy)
		var rz := roundf(fz)
		var dx := absf(rx - fx)
		var dy := absf(ry - fy)
		var dz := absf(rz - fz)
		if dx > dy and dx > dz:
			rx = -ry - rz
		elif dy > dz:
			ry = -rx - rz
		out.append(TerrainMath.axial_to_offset(Vector2i(int(rx), int(ry))))
	out[0] = a
	out[out.size() - 1] = b
	return out


func remove_unit(id: String, instant := false) -> void:
	## A unit that leaves the map fades out over ~0.45 s (dithered dissolve + sink); `instant` skips that.
	if not units.has(id):
		return
	var u: Node3D = units[id]
	units.erase(id)
	if instant or not is_inside_tree():
		u.queue_free()
		return
	_play_death(u)


func kill_unit(id: String) -> void:
	## Death: glow plus the dissolve (same as remove_unit(id)).
	remove_unit(id)


func attack_unit(attacker_id: String, target, ranged := false) -> void:
	## Attack feedback. `target` = a unit id (String) or a hex (Vector2i). Melee: the attacker lunges 40% of the way
	## and back; ranged (or guns/jets/boats): it recoils slightly and a muzzle flash pops at its front. Either way
	## an impact flash plus a damage shake play on the target after ~0.18 s.
	var u: Node3D = units.get(attacker_id)
	if u == null:
		return
	var tpos := Vector3.ZERO
	var tid := ""
	if target is String:
		tid = target
		if not units.has(tid):
			return
		tpos = (units[tid] as Node3D).position
	elif target is Vector2i:
		tpos = _unit_pos(target.x, target.y, bool(u.get_meta("naval", false)))
		for k in units:
			if units[k].get_meta("qr", Vector2i(-9, -9)) == target:
				tid = k
				break
	else:
		return
	var dir := tpos - u.position
	dir.y = 0
	if dir.length() < 0.01:
		dir = Vector3.FORWARD
	u.rotation.y = atan2(dir.x, dir.z)
	var body: Node3D = u.get_child(0)
	if not u.is_inside_tree():
		return
	ranged = ranged or bool(u.get_meta("naval", false)) or bool(u.get_meta("air", false)) or bool(u.get_meta("gun", false))
	var tw := u.create_tween()
	if ranged:
		_flash_at(u.position + dir.normalized() * 0.2 + Vector3(0, 0.18, 0), Color(1.0, 0.85, 0.45), 0.09, 0.14)
		tw.tween_property(body, "position:z", -0.06, 0.06).as_relative()
		tw.tween_property(body, "position:z", 0.06, 0.18).as_relative().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		var lunge := minf(dir.length() * 0.4, 0.45)
		tw.tween_property(body, "position:z", lunge, 0.1).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(body, "position:z", -lunge, 0.22).as_relative().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var hit_at := tpos + Vector3(0, 0.15, 0)
	get_tree().create_timer(0.18).timeout.connect(func():
		_flash_at(hit_at, Color(1.0, 0.6, 0.3), 0.12, 0.2)
		if tid != "":
			hit_unit(tid))


func hit_unit(id: String) -> void:
	## Damage feedback: a quick positional shake and a red-white glow on the unit.
	var u: Node3D = units.get(id)
	if u == null or not u.get_child_count():
		return
	var body: Node3D = u.get_child(0)
	if u.get_meta("shaking", false):
		return
	if not u.is_inside_tree():
		return
	u.set_meta("shaking", true)
	var tw := u.create_tween()
	for i in 6:
		tw.tween_property(body, "position:x", (0.03 if i % 2 == 0 else -0.03) * (1.0 - i / 6.0), 0.035)
	tw.tween_property(body, "position:x", 0.0, 0.03)
	tw.tween_callback(u.set_meta.bind("shaking", false))
	_set_flash(1.0, u)
	var tf := u.create_tween()
	tf.tween_method(_set_flash.bind(u), 1.0, 0.0, 0.3)


func _set_flash(v: float, u: Node3D) -> void:
	if not is_instance_valid(u):
		return
	for mi in u.find_children("*", "MeshInstance3D", true, false):
		(mi as MeshInstance3D).set_instance_shader_parameter("flash", v)


func _set_fade(v: float, u: Node3D) -> void:
	if not is_instance_valid(u):
		return
	for mi in u.find_children("*", "MeshInstance3D", true, false):
		(mi as MeshInstance3D).set_instance_shader_parameter("fade", v)


func _play_death(u: Node3D) -> void:
	u.set_meta("dying", true)
	if u.has_meta("move_tw"):
		var mt = u.get_meta("move_tw")
		if mt is Tween and (mt as Tween).is_valid():
			(mt as Tween).kill()
	if not u.get_child_count():
		u.queue_free()
		return
	var body: Node3D = u.get_child(0)
	_set_flash(0.8, u)
	var tw := u.create_tween().set_parallel(true)
	tw.tween_method(_set_fade.bind(u), 1.0, 0.0, 0.45).set_delay(0.08)
	tw.tween_property(body, "position:y", body.position.y - 0.06, 0.5)
	tw.tween_method(_set_flash.bind(u), 0.8, 0.0, 0.3)
	tw.chain().tween_callback(u.queue_free)


func _flash_at(pos: Vector3, col: Color, radius: float, secs: float) -> void:
	## cheap muzzle/impact flash: one emissive sphere that pops and fades (no particles, no lights)
	var m := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = radius
	sm.height = radius * 2.0
	sm.radial_segments = 8
	sm.rings = 4
	m.mesh = sm
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = col
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.material_override = mat
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	m.position = pos
	m.scale = Vector3.ONE * 0.5
	add_child(m)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(m, "scale", Vector3.ONE * 1.5, secs).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(mat, "albedo_color:a", 0.0, secs)
	tw.chain().tween_callback(m.queue_free)


func _process(_dt: float) -> void:
	## idle motion: a breathing bob for troops, a faint sway for vehicles, boats rock on the swell, jets hover-drift.
	## Only touches the unit's child body (never the holder the move tween drives); skips units that are busy.
	if units.is_empty():
		return
	var t := Time.get_ticks_msec() * 0.001
	for id in units:
		var u: Node3D = units[id]
		if not u.get_child_count() or u.get_meta("shaking", false):
			continue
		var ph: float = u.get_meta("phase", 0.0)
		var body: Node3D = u.get_child(0)
		var base: float = u.get_meta("base_y", 0.0)
		var moving := bool(u.get_meta("moving", false))
		if u.get_meta("naval", false):
			body.position.y = base + sin(t * 1.6 + ph) * 0.012
			body.rotation.z = sin(t * 1.3 + ph) * 0.05
			body.rotation.x = sin(t * 0.9 + ph * 1.7) * 0.03
		elif u.get_meta("air", false):
			body.position.y = base + 0.05 + sin(t * 1.1 + ph) * 0.02
			body.rotation.z = sin(t * 0.8 + ph) * 0.04
		elif u.get_meta("gun", false):
			body.position.y = base + (absf(sin(t * 9.0 + ph)) * 0.006 if moving else 0.0)
			body.rotation.z = sin(t * 0.7 + ph) * 0.006
		else:
			var f := 8.0 if moving else 2.0
			var a := 0.03 if moving else 0.006
			body.position.y = base + absf(sin(t * f + ph)) * a
			body.rotation.z = sin(t * f * 0.5 + ph) * (0.06 if moving else 0.012)


func _unit_pos(q: int, r: int, naval := false) -> Vector3:
	## A spot on dry, non-beach land (open water for ships) that is not a landmark, harbour, plaza or
	## old-town hex; if the unit's own hex has none, the nearest valid neighbouring hex is used.
	var ctr := TerrainMath.offset_center(q, r)
	var cb := renderer.cities
	var offs := [Vector2(-0.35, 0.3), Vector2(0.35, 0.3), Vector2(-0.35, -0.3), Vector2(0.35, -0.3), Vector2(0, 0.55), Vector2(0, -0.55), Vector2(0.55, 0), Vector2(-0.55, 0), Vector2.ZERO]
	var centres := [ctr]
	var ax := TerrainMath.offset_to_axial(Vector2i(q, r))
	for ring in [1, 2]:
		for d in TerrainMath.AX_DIRS:
			centres.append(TerrainMath.axial_center(ax + d * ring))
	for cc in centres:
		for o in offs:
			var c: Vector2 = cc + o
			var h := renderer.height_at(c.x, c.y)
			var ok := (h < -0.08) if naval else (h > 0.06)
			if ok and cb and cb.in_footprint(c):
				ok = false
			if ok:
				return Vector3(c.x, maxf(h, 0.0), c.y)
	var f := ctr + Vector2(-0.35, 0.3)
	return Vector3(f.x, maxf(renderer.height_at(f.x, f.y), 0.0), f.y)

