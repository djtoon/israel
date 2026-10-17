extends Node3D
## Art preview / contact sheet for the asset set (owned by the art piece).
## Run:  godot --path game res://scenes/art_preview.tscn -- --shot=<abs.png> [--mode=grid|gridturn|sheet|turntable|terrain|scale]
## grid: one framed viewport per model (contact sheet); gridturn: 4 orbit angles per model (turntable).
##        [--filter=<id prefix, comma separated>] [--cols=N] [--labels=0]
## Reads res://assets/MANIFEST.json. Models are normalised so 1.0 world unit = one hex (flat-to-flat),
## so here everything is simply scaled by HEX.

const HEX := 2.0  # preview hex flat-to-flat width in world units
var mode := "sheet"
var filters: PackedStringArray = []
var cols := 0
var labels := true
var zoom := 1.0
var pitch_deg := 45.0
var manifest: Array = []

func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--mode="): mode = a.substr(7)
		elif a.begins_with("--filter="): filters = a.substr(9).split(",")
		elif a.begins_with("--cols="): cols = int(a.substr(7))
		elif a.begins_with("--labels="): labels = a.substr(9) != "0"
		elif a.begins_with("--zoom="): zoom = float(a.substr(7))
		elif a.begins_with("--pitch="): pitch_deg = float(a.substr(8))
	var mpath := "res://assets/MANIFEST.json"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--manifest="): mpath = a.substr(11)
	var f := FileAccess.open(mpath, FileAccess.READ)
	if f:
		var j = JSON.parse_string(f.get_as_text())
		manifest = j["assets"] if j is Dictionary else j
	_setup_env()
	match mode:
		"terrain": _terrain_sheet()
		"turntable": _model_sheet(true)
		"scale": _scale_lineup()
		"grid": _grid(false)
		"diorama": _diorama()
		"street": _street()
		"harbour": _harbour()
		"block": _block()
		"rot": _rot()
		"gridturn": _grid(true)
		_: _model_sheet(false)

func _keep(e: Dictionary) -> bool:
	if filters.is_empty(): return true
	for p in filters:
		if String(e["id"]).begins_with(p): return true
	return false

func _setup_env() -> void:
	var env := Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color(0.33, 0.55, 0.85)
	sm.sky_horizon_color = Color(0.85, 0.82, 0.75)
	sm.ground_bottom_color = Color(0.35, 0.3, 0.25)
	sm.ground_horizon_color = Color(0.85, 0.8, 0.7)
	sky.sky_material = sm
	env.sky = sky
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.17, 0.2, 0.26)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.6
	env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 1.0
	env.ssao_enabled = true
	env.ssao_intensity = 1.2
	env.glow_enabled = true
	env.glow_intensity = 0.3
	env.adjustment_enabled = true
	env.adjustment_saturation = 1.12
	env.adjustment_contrast = 1.05
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -40, 0)
	sun.light_color = Color(1.0, 0.9, 0.74)
	sun.light_energy = 1.35
	sun.shadow_enabled = not ("--noshadow" in OS.get_cmdline_user_args())
	sun.directional_shadow_max_distance = 120.0
	add_child(sun)

func _hex(pos: Vector3, tex_path: String, color := Color(0.62, 0.58, 0.48)) -> void:
	var m := MeshInstance3D.new()
	var c := CylinderMesh.new()
	c.radial_segments = 6
	c.rings = 1
	c.top_radius = HEX / sqrt(3.0) * 0.985
	c.bottom_radius = c.top_radius
	c.height = 0.08
	m.mesh = c
	# CylinderMesh with 6 segments already has corners on +-Z (pointy-top)
	var mat := StandardMaterial3D.new()
	if tex_path != "" and ResourceLoader.exists(tex_path):
		mat.albedo_texture = load(tex_path)
		mat.uv1_triplanar = true
		mat.uv1_world_triplanar = true
		mat.uv1_scale = Vector3.ONE / (HEX * 0.5)  # one repeat per half hex (MANIFEST suggested_scale 0.5)
	else:
		mat.albedo_color = color
	mat.roughness = 0.95
	m.material_override = mat
	m.position = pos + Vector3(0, -0.04, 0)
	add_child(m)

func _label(pos: Vector3, text: String, px := 0.005) -> void:
	if not labels: return
	var l := Label3D.new()
	l.text = text
	l.font_size = 40
	l.pixel_size = px
	l.outline_size = 10
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.position = pos
	add_child(l)

func _ground_for(e: Dictionary) -> String:
	var t := String(e.get("preview_terrain", "terrain_plains"))
	return "res://assets/textures/terrain/%s.png" % t

func _place(e: Dictionary, pos: Vector3, rot_y := 0.0) -> Node3D:
	var path := "res://assets/" + String(e["file"])
	if not ResourceLoader.exists(path):
		_label(pos + Vector3(0, 0.4, 0), "MISSING " + String(e["id"]))
		return null
	var n: Node3D = (load(path) as PackedScene).instantiate()
	n.scale = Vector3.ONE * HEX * float(e.get("suggested_scale", 1.0))
	n.rotation_degrees.y = rot_y
	n.position = pos
	add_child(n)
	return n

func _hex_pos(i: int, ncol: int) -> Vector3:
	var row := i / ncol
	var col := i % ncol
	var dx := HEX
	var dz := HEX * sqrt(3.0) / 2.0
	return Vector3(col * dx + (dx * 0.5 if row % 2 == 1 else 0.0), 0, row * dz)

func _frame(ncol: int, nrow: int) -> void:
	var w := ncol * HEX
	var d := nrow * HEX * sqrt(3.0) / 2.0
	var cam := Camera3D.new()
	cam.fov = 32
	add_child(cam)
	var center := Vector3((ncol - 1) * HEX * 0.5 + (HEX * 0.25 if nrow > 1 else 0.0), 0, (nrow - 1) * HEX * sqrt(3.0) / 4.0)
	var dist: float = max(w * 0.62, d * 1.15) / tan(deg_to_rad(cam.fov * 0.5)) * 0.62 * zoom + 0.5
	var pitch := deg_to_rad(pitch_deg)
	cam.position = center + Vector3(0, sin(pitch), cos(pitch)) * dist
	cam.look_at(center)
	cam.far = 500

func _model_sheet(turntable: bool) -> void:
	var items: Array = []
	for e in manifest:
		if e.get("kind", "") in ["texture", "icon"]: continue
		if _keep(e): items.append(e)
	var reps := 4 if turntable else 1
	var ncol := cols if cols > 0 else (reps if turntable else int(ceil(sqrt(items.size() * 1.6))))
	var i := 0
	for e in items:
		for r in reps:
			var p := _hex_pos(i, ncol)
			_hex(p, _ground_for(e))
			_place(e, p, r * 90.0)
			if r == 0: _label(p + Vector3(0, 0.05, HEX * 0.5), String(e["id"]))
			i += 1
	_frame(ncol, int(ceil(float(i) / ncol)))

func _scale_lineup() -> void:
	# one city tile with a unit, trees and a prop next to it, to judge relative scale at game zoom
	var items: Array = []
	for e in manifest:
		if e.get("kind", "") in ["texture", "icon"]: continue
		if _keep(e): items.append(e)
	var ncol := cols if cols > 0 else 6
	var i := 0
	for e in items:
		var p := _hex_pos(i, ncol)
		_hex(p, _ground_for(e))
		_place(e, p)
		_label(p + Vector3(0, 0.05, HEX * 0.5), String(e["id"]))
		i += 1
	_frame(ncol, int(ceil(float(i) / ncol)))

func _terrain_sheet() -> void:
	var items: Array = []
	for e in manifest:
		if e.get("kind", "") == "texture" and _keep(e): items.append(e)
	var ncol := cols if cols > 0 else 5
	# each terrain: a 3-hex-wide cluster (7 hexes) so tiling across hexes is visible
	var cluster := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -1), Vector2i(1, -1), Vector2i(0, 1), Vector2i(1, 1)]
	var k := 0
	for e in items:
		var cx := (k % ncol) * 3.4 * HEX
		var cz := (k / ncol) * 3.2 * HEX
		for c in cluster:
			var off := Vector3(c.x * HEX - (HEX * 0.5 if c.y != 0 else 0.0), 0, c.y * HEX * sqrt(3.0) / 2.0)
			_hex(Vector3(cx, 0, cz) + off, "res://assets/" + String(e["file"]))
		_label(Vector3(cx, 0.1, cz + HEX * 1.5), String(e["id"]))
		k += 1
	var nrow := int(ceil(float(k) / ncol))
	var cam := Camera3D.new()
	cam.fov = 32
	add_child(cam)
	var center := Vector3((ncol - 1) * 3.4 * HEX * 0.5, 0, (nrow - 1) * 3.2 * HEX * 0.5)
	cam.position = center + Vector3(0, 1, 0.55).normalized() * (ncol * 3.4 * HEX) * 0.95
	cam.look_at(center)
	cam.far = 500


# ---------- grid contact sheet: one SubViewport (own world) per model view ----------
func _grid(turn: bool) -> void:
	var items: Array = []
	for e in manifest:
		if e.get("kind", "") in ["texture", "icon"]: continue
		if _keep(e): items.append(e)
	var views := 4 if turn else 1
	var total := items.size() * views
	var vp := get_viewport().get_visible_rect().size
	var ncol := cols if cols > 0 else (4 if turn else int(ceil(sqrt(total * vp.x / vp.y))))
	var nrow := int(ceil(float(total) / ncol))
	var label_h := 18.0
	var cw: float = floor(vp.x / ncol)
	var ch: float = floor(vp.y / nrow) - label_h
	var layer := CanvasLayer.new()
	add_child(layer)
	var bg := ColorRect.new()
	bg.color = Color(0.09, 0.12, 0.2)
	bg.size = vp
	layer.add_child(bg)
	var i := 0
	for e in items:
		for v in views:
			var x := (i % ncol) * cw
			var y := (i / ncol) * (ch + label_h)
			var svc := SubViewportContainer.new()
			svc.position = Vector2(x, y)
			svc.size = Vector2(cw - 2, ch)
			svc.stretch = true
			layer.add_child(svc)
			var sv := SubViewport.new()
			sv.own_world_3d = true
			sv.msaa_3d = Viewport.MSAA_4X
			sv.size = Vector2i(int(cw - 2), int(ch))
			svc.add_child(sv)
			var w := Node3D.new()
			sv.add_child(w)
			_cell_world(w, e, v * 90.0, cw / ch)
			var l := Label.new()
			l.text = "%s%s" % [e["id"], ("  [%s]" % String(e.get("generator", "")).get_file()) if v == 0 else ""] if v == 0 else "%d deg" % (v * 90)
			l.position = Vector2(x + 4, y + ch)
			l.add_theme_font_size_override("font_size", 12)
			layer.add_child(l)
			i += 1

func _cell_world(w: Node3D, e: Dictionary, orbit: float, aspect: float) -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.2, 0.25, 0.34)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.72, 0.76, 0.85)
	env.ambient_light_energy = 0.55
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.ssao_enabled = true
	env.adjustment_enabled = true
	env.adjustment_saturation = 1.1
	var we := WorldEnvironment.new()
	we.environment = env
	w.add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -40, 0)
	sun.light_color = Color(1.0, 0.9, 0.74)
	sun.light_energy = 1.35
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 30.0
	w.add_child(sun)
	# ground hex
	var m := MeshInstance3D.new()
	var c := CylinderMesh.new()
	c.radial_segments = 6
	c.rings = 1
	c.top_radius = HEX / sqrt(3.0) * 1.6
	c.bottom_radius = c.top_radius
	c.height = 0.06
	m.mesh = c
	var mat := StandardMaterial3D.new()
	var tp := _ground_for(e)
	if ResourceLoader.exists(tp):
		mat.albedo_texture = load(tp)
		mat.uv1_triplanar = true
		mat.uv1_world_triplanar = true
		mat.uv1_scale = Vector3.ONE / (HEX * 0.5)
	m.material_override = mat
	m.position.y = -0.031
	w.add_child(m)
	var path := "res://assets/" + String(e["file"])
	var nb: Dictionary = e.get("normalised", {})
	var bmin: Array = nb.get("bounds_min", [-0.5, 0, -0.5])
	var bmax: Array = nb.get("bounds_max", [0.5, 0.5, 0.5])
	var sc := HEX * float(e.get("suggested_scale", 1.0))
	if String(e.get("scale_units", "hex")) == "m": sc = 0.05  # metre-scale buildings: 20 m per preview unit
	if ResourceLoader.exists(path):
		var n: Node3D = (load(path) as PackedScene).instantiate()
		n.scale = Vector3.ONE * sc
		w.add_child(n)
	var size := Vector3(float(bmax[0]) - float(bmin[0]), float(bmax[1]) - float(bmin[1]), float(bmax[2]) - float(bmin[2])) * sc
	var target := Vector3((float(bmax[0]) + float(bmin[0])) * 0.5 * sc, size.y * 0.4, (float(bmax[2]) + float(bmin[2])) * 0.5 * sc)
	var r: float = max(size.length() * 0.5, 0.05)
	var cam := Camera3D.new()
	cam.fov = 30
	var p := deg_to_rad(pitch_deg)
	var a := deg_to_rad(orbit)
	var fit: float = r / sin(deg_to_rad(cam.fov * 0.5)) * zoom * (1.0 if aspect >= 1.0 else 1.0 / aspect)
	cam.position = target + Vector3(sin(a) * cos(p), sin(p), cos(a) * cos(p)) * fit
	cam.near = 0.01
	w.add_child(cam)
	cam.look_at(target)
	cam.current = true


# ---------- diorama: a small hand-placed map at game zoom, to judge scale and style against ref/screenshot.png ----------
func _find(id: String) -> Dictionary:
	for e in manifest:
		if e["id"] == id: return e
	return {}

func _water_hex(pos: Vector3) -> void:
	var m := MeshInstance3D.new()
	var c := CylinderMesh.new()
	c.radial_segments = 6
	c.rings = 1
	c.top_radius = HEX / sqrt(3.0) * 0.985
	c.bottom_radius = c.top_radius
	c.height = 0.04
	m.mesh = c
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.1, 0.55, 0.68)
	mat.roughness = 0.15
	mat.metallic_specular = 0.8
	m.material_override = mat
	m.position = pos + Vector3(0, -0.07, 0)
	add_child(m)

func _diorama() -> void:
	# rows of [terrain-or-model, extras...]; "sea" = water hex. Extras: "id@dx,dz,rot"
	var rows := [
		["sea", "sea", "terrain_beach_sand|nat_date_palm@-0.3,0.1|nat_date_palm@0.25,-0.2", "imp_citrus_grove", "terrain_grassland|nat_olive_tree@0,0|nat_cypress@0.3,0.2|nat_cypress@-0.3,-0.25", "imp_wheat_field", "terrain_hills_limestone|nat_rock_outcrop@0.1,0.1|nat_olive_tree@-0.3,-0.2"],
		["sea|unit_saar_missile_boat@0,0,200", "city_haifa_port", "city_modern_tlv", "city_1950s_bauhaus", "terrain_plains|unit_merkava@0,0,140", "imp_olive_grove", "lm_bahai_gardens"],
		["sea", "terrain_beach_sand|unit_palmach_infantry@-0.15,0.1,120|unit_palmach_infantry@0.15,0.05,120|unit_palmach_infantry@0,-0.15,120", "city_jerusalem_stone", "lm_azrieli_towers", "terrain_pine_forest_floor|nat_aleppo_pine@-0.2,0|nat_aleppo_pine@0.25,0.15|nat_aleppo_pine@0.1,-0.3", "city_kibbutz", "imp_solar_field"],
		["imp_gas_platform", "sea", "terrain_beach_sand|unit_settler_group@0,0,160", "imp_fish_ponds", "terrain_desert_rock|unit_trader_truck@0,0,100", "lm_nuclear_research", "terrain_desert_sand|nat_date_palm@0,0"],
	]
	var ncol := 7
	for r in rows.size():
		for cidx in rows[r].size():
			var parts: PackedStringArray = String(rows[r][cidx]).split("|")
			var p := _hex_pos(r * ncol + cidx, ncol)
			var head := parts[0]
			if head == "sea":
				_water_hex(p)
			elif head.begins_with("terrain_"):
				_hex(p, "res://assets/textures/terrain/%s.png" % head)
			else:
				var e := _find(head)
				_hex(p, _ground_for(e))
				if not e.is_empty(): _place(e, p)
			for k in range(1, parts.size()):
				var bits := parts[k].split("@")
				var e2 := _find(bits[0])
				var o := bits[1].split(",")
				var rot := float(o[2]) if o.size() > 2 else randf() * 360.0
				if not e2.is_empty(): _place(e2, p + Vector3(float(o[0]), 0, float(o[1])) * HEX, rot)
	var cam := Camera3D.new()
	cam.fov = 38
	add_child(cam)
	var center := Vector3(6.4, 0, 2.2)
	var pitch := deg_to_rad(pitch_deg)
	cam.position = center + Vector3(0, sin(pitch), cos(pitch)) * 13.0 * zoom
	cam.look_at(center)


# ---------- street: metre-scale models side by side at true relative scale ----------
# --ref=<id> puts that model (e.g. bld_bauhaus_block) at the start of every row; --cols=N models per row.
func _street() -> void:
	var ref := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--ref="): ref = a.substr(6)
	var items: Array = []
	for e in manifest:
		if String(e.get("scale_units", "hex")) == "m" and _keep(e) and e["id"] != ref and e.get("status", "ok") == "ok": items.append(e)
	var per_row := cols if cols > 0 else 8
	var k := 0.05  # world units per metre
	var rows: Array = []
	for i in range(0, items.size(), per_row):
		var r: Array = []
		if ref != "": r.append(_find(ref))
		r.append_array(items.slice(i, i + per_row))
		rows.append(r)
	var z := 0.0
	var maxx := 0.0
	var tallest := 0.0
	for r in rows:
		var x := 0.0
		var depth := 0.0
		for e in r:
			if e.is_empty(): continue
			var rm: Dictionary = e["real_m"]
			var nb: Dictionary = e.get("normalised", {})
			var bmin: Array = nb.get("bounds_min", [-float(rm["w"]) / 2, 0, -float(rm["d"]) / 2])
			var bmax: Array = nb.get("bounds_max", [float(rm["w"]) / 2, 0, float(rm["d"]) / 2])
			var w := (float(bmax[0]) - float(bmin[0])) * k
			var d := (float(bmax[2]) - float(bmin[2])) * k
			var n: Node3D = (load("res://assets/" + String(e["file"])) as PackedScene).instantiate()
			n.scale = Vector3.ONE * k
			n.position = Vector3(x + w * 0.5 - (float(bmax[0]) + float(bmin[0])) * 0.5 * k, 0, z)
			add_child(n)
			var h := float(nb.get("height", rm["h"]))
			_label(Vector3(x + w * 0.5, 0.05, z + d * 0.5 + 0.3), "%s
%dm" % [String(e["id"]).replace("veg_", "").replace("bld_", "").replace("shore_", ""), int(round(h))], 0.0028)
			tallest = max(tallest, h * k)
			depth = max(depth, d)
			x += w + 0.45
		maxx = max(maxx, x)
		z += max(depth, 1.0) + 2.2
	var g := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(maxx + 6, z + 6)
	g.mesh = pm
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = load("res://assets/textures/terrain/terrain_plains.png")
	mat.uv1_triplanar = true
	mat.uv1_world_triplanar = true
	mat.uv1_scale = Vector3.ONE * 0.5
	g.material_override = mat
	g.position = Vector3(maxx * 0.5, 0, z * 0.5 - 1.5)
	add_child(g)
	var cam := Camera3D.new()
	cam.fov = 30
	add_child(cam)
	var c := Vector3(maxx * 0.5 - 0.4, tallest * 0.3, z * 0.5 - 1.6)
	var vp := get_viewport().get_visible_rect().size
	var hfov := 2.0 * atan(tan(deg_to_rad(cam.fov * 0.5)) * vp.x / vp.y)
	var dist: float = max((maxx * 0.5 + 0.3) / tan(hfov * 0.5), tallest * 1.3 / tan(deg_to_rad(cam.fov * 0.5))) * zoom + z * 0.3
	cam.position = c + Vector3(0, sin(deg_to_rad(pitch_deg)), cos(deg_to_rad(pitch_deg))) * dist
	cam.look_at(c)
	cam.far = 2000


# ---------- harbour: shoreline vignette at true metre scale (k = 0.05 world units per metre) ----------
func _put(id: String, x: float, z: float, rot := 0.0, y := 0.0) -> void:
	var e := _find(id)
	if e.is_empty() or not ResourceLoader.exists("res://assets/" + String(e["file"])): return
	var n: Node3D = (load("res://assets/" + String(e["file"])) as PackedScene).instantiate()
	n.scale = Vector3.ONE * 0.05
	n.position = Vector3(x, y, z) * 0.05
	n.rotation_degrees.y = rot
	add_child(n)

func _harbour() -> void:
	# land: z < 0 ; sea: z > 0 ; quay edge at z = 0
	var land := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(16, 6)
	land.mesh = pm
	var lm := StandardMaterial3D.new()
	lm.albedo_texture = load("res://assets/textures/terrain/terrain_beach_sand.png")
	lm.uv1_triplanar = true
	lm.uv1_world_triplanar = true
	lm.uv1_scale = Vector3.ONE * 0.6
	land.material_override = lm
	land.position = Vector3(0, 0, -3)
	add_child(land)
	var sea := MeshInstance3D.new()
	var sp := PlaneMesh.new()
	sp.size = Vector2(16, 10)
	sea.mesh = sp
	var sm := StandardMaterial3D.new()
	sm.albedo_color = Color(0.08, 0.5, 0.62)
	sm.roughness = 0.12
	sea.material_override = sm
	sea.position = Vector3(0, -0.12, 5)
	add_child(sea)
	var Y := -2.4  # quay/boats: top of quay is ~1.6 m above sea; models are 4 m tall
	# quay line along x, sea face towards +z
	var qe := _find("hb_quay_straight")
	var ql := float(qe["real_m"]["w"]) if not qe.is_empty() else 20.0
	var n_q := int(130.0 / ql)
	for i in n_q:
		_put("hb_quay_straight", -64 + ql * 0.5 + i * ql, 2, 0, Y)
	_put("hb_quay_corner", -64 + n_q * ql + 4, 2, 0, Y)
	_put("hb_wooden_pier", -80, 16, 90, -2.0)
	# breakwater going out to sea, lighthouse at its end
	for i in 5:
		_put("hb_breakwater", 70, 20 + i * 20, 90, -2.4)
	_put("hb_lighthouse", 70, 122, 0, -1.0)
	# boats
	_put("boat_jaffa_motorboat", -30, 14, 80, -2.4)
	_put("boat_jaffa_rowboat", -8, 11, 100, -0.8)
	_put("boat_jaffa_rowboat", -2, 13, 70, -0.8)
	_put("boat_felucca", 20, 20, 60, -1.2)
	_put("boat_sailboat", 40, 40, 30, -1.4)
	# shore rocks to the west of the quay
	_put("shore_rocks_large", -110, 8, 20, -2.0)
	_put("shore_rocks_medium", -92, 18, 0, -1.2)
	_put("shore_rocks_small", -100, 26, 40, -0.6)
	_put("shore_rocks_jaffa", -60, 60, 0, -2.5)
	_put("shore_reef_flat", -130, 22, 10, -0.6)
	# old town behind the quay
	var row := ["old_house_jaffa", "old_house_akko", "market_arcade", "bld_jaffa_clock_tower", "old_house_nazareth", "jer_apartment_c", "old_house_jaffa", "bld_bauhaus_block", "bld_bauhaus_b"]
	var x := -64.0
	for id in row:
		var e := _find(id)
		var w := 14.0
		if not e.is_empty() and e.get("real_m") != null: w = float(e["real_m"]["w"])
		_put(id, x + w * 0.5, -14, 0)
		x += w + 3.0
	for i in 7:
		_put("veg_date_palm_tall" if i % 2 == 0 else "veg_washingtonia", -60 + i * 18, -2, i * 50.0)
	_put("veg_bougainvillea", -20, -4, 0)
	_put("veg_olive", 10, -4, 0)
	_put("veg_cypress", 40, -26, 0)
	_put("veg_eucalyptus", 75, -24, 0)
	var cam := Camera3D.new()
	cam.fov = 35
	add_child(cam)
	var c := Vector3(-0.5, 0, 0.6)
	var p := deg_to_rad(pitch_deg)
	cam.position = c + Vector3(0.0, sin(p), cos(p)) * 13.0 * zoom
	cam.look_at(c)


# ---------- block: a neighbourhood of metre-scale buildings on 30 m lots, seen from a game-like high camera ----------
func _block() -> void:
	var items: Array = []
	for e in manifest:
		if String(e.get("scale_units", "hex")) == "m" and _keep(e) and e.get("status", "ok") == "ok": items.append(e)
	if items.is_empty(): return
	var k := 0.05
	var lot := 32.0
	var n := 7
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var g := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(n * lot * k + 2, n * lot * k + 2)
	g.mesh = pm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.78, 0.72, 0.62)
	g.material_override = mat
	g.position = Vector3(n * lot * k * 0.5, 0, n * lot * k * 0.5)
	add_child(g)
	for ix in n:
		for iz in n:
			if (ix % 3 == 2) or (iz % 3 == 2): continue  # streets
			var e: Dictionary = items[rng.randi() % items.size()]
			var nm: Dictionary = e.get("normalised", {})
			var b0: Array = nm.get("bounds_min", [-8, 0, -8])
			var b1: Array = nm.get("bounds_max", [8, 0, 8])
			var w := float(b1[0]) - float(b0[0])
			var d := float(b1[2]) - float(b0[2])
			var rot := 90.0 if (d > w and rng.randf() < 0.5) else 0.0
			var fit: float = min(1.0, lot * 0.85 / max(w, d))  # long slabs shrink to fit a lot (preview only)
			var node: Node3D = (load("res://assets/" + String(e["file"])) as PackedScene).instantiate()
			node.scale = Vector3.ONE * k * fit
			node.rotation_degrees.y = rot + (180.0 if rng.randf() < 0.5 else 0.0)
			node.position = Vector3((ix + 0.5) * lot * k, 0, (iz + 0.5) * lot * k)
			add_child(node)
	for i in 10:
		_put("veg_date_palm_tall" if i % 3 else "veg_washingtonia", (2.5 + (i % 2) * 3.0) * lot, (i * 0.7 + 0.3) * lot, i * 40.0)
	var cam := Camera3D.new()
	cam.fov = 35
	add_child(cam)
	var c := Vector3(n * lot * k * 0.5, 0, n * lot * k * 0.5)
	var p := deg_to_rad(pitch_deg)
	cam.position = c + Vector3(0, sin(p), cos(p)) * n * lot * k * 1.25 * zoom
	cam.look_at(c)
	cam.far = 1000


# ---------- rot: each model at yaw 0/90/180/270 in the main (game-like) environment, high camera ----------
func _rot() -> void:
	var items: Array = []
	for e in manifest:
		if _keep(e): items.append(e)
	var k := 0.05
	var row := 0
	for e in items:
		for r in 4:
			var n: Node3D = (load("res://assets/" + String(e["file"])) as PackedScene).instantiate()
			n.scale = Vector3.ONE * k
			n.rotation_degrees.y = r * 90.0
			n.position = Vector3(r * 3.0, 0, row * 3.0)
			add_child(n)
		_label(Vector3(-2.2, 0.05, row * 3.0), String(e["id"]), 0.004)
		row += 1
	var g := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(20, row * 3.0 + 6)
	g.mesh = pm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.78, 0.72, 0.62)
	g.material_override = mat
	g.position = Vector3(4.5, 0, row * 1.5 - 1.5)
	add_child(g)
	var cam := Camera3D.new()
	cam.fov = 40
	add_child(cam)
	var c := Vector3(3.5, 0, row * 1.5 - 1.5)
	var p := deg_to_rad(pitch_deg)
	cam.position = c + Vector3(0, sin(p), cos(p)) * (9.0 + row * 1.5) * zoom
	cam.look_at(c)
