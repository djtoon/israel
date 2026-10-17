class_name HDRender
extends RefCounted
## Graphics mode HD (Quality.hd). Rendering only, no model changes: a warmer, lower sun with PCSS soft shadows,
## screen-space indirect light (bounce) plus a tuned sky ambient, subtle SSAO, generated PBR detail maps for the
## terrain (normal, cavity AO, roughness) and the building kit (its baked AO maps), the HD water shader
## (water_hd.gdshader: ripples, sky reflection, sparkle, depth colour, refraction, reef rocks, shoreline foam),
## vegetation colour variety and back lighting, distance haze with aerial perspective, AgX with a gentle colour grade.
## The shaders read the global uniform `hd_mode` (project.godot [shader_globals], 0 = SD): every HD branch is
## skipped in SD, so SD renders exactly as before.
## apply(game, on) switches live (the settings window calls it); tree shadows and the art draw range follow the
## HD preset on the next start. HD+ (Quality.plus) adds the effects ported from the HD lab (hdplus.gd: tilt-shift DOF,
## cloud shadows, caustics, seasons, terrain blending, foliage wind, decals) and the optional FSR 2 upscaling.

const HD_DIR := "res://assets/textures/hd/"
const SDFGI := false   # SDFGI measured too heavy / leaky at this map scale; SSIL + tuned sky ambient instead

static var _sd_env: Environment
static var _hd_env: Environment
static var _sd_sun := {}
static var _sd_aa := {}
static var active := false
static var _cycle_added := false


static func apply(game: Node, on: bool) -> void:
	if game == null:
		return
	var we: WorldEnvironment = null
	for c in game.get_children():
		if c is WorldEnvironment:
			we = c
			break
	var sun := game.get_node_or_null("Sun") as DirectionalLight3D
	if not on and not active:
		return   # SD start: touch nothing
	DayNight.begin(true)   # v5: the base look back first (never duplicate a night environment), the time of day after
	if we and _sd_env == null:
		_sd_env = we.environment
	if sun and _sd_sun.is_empty():
		for k in ["rotation_degrees", "light_color", "light_energy", "light_angular_distance", "shadow_blur",
				"directional_shadow_mode", "directional_shadow_max_distance", "directional_shadow_split_1",
				"directional_shadow_split_2", "directional_shadow_split_3", "shadow_bias", "shadow_normal_bias",
				"light_indirect_energy", "directional_shadow_blend_splits"]:
			_sd_sun[k] = sun.get(k)
	var vp := game.get_viewport()
	if _sd_aa.is_empty() and vp:
		_sd_aa = {"msaa": vp.msaa_3d, "deband": vp.use_debanding, "ssaa": vp.screen_space_aa}
	active = on
	RenderingServer.global_shader_parameter_set("hd_mode", 1.0 if on else 0.0)
	if on:
		if we:
			_hd_env = _make_env(_sd_env)
			we.environment = _hd_env
		if sun:
			_hd_sun(sun)
		if vp:
			vp.msaa_3d = Viewport.MSAA_2X
			vp.use_debanding = true
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
	else:
		if we and _sd_env:
			we.environment = _sd_env
		if sun:
			for k in _sd_sun:
				sun.set(k, _sd_sun[k])
		if vp and not _sd_aa.is_empty():
			vp.msaa_3d = _sd_aa["msaa"]
			vp.use_debanding = _sd_aa["deband"]
			vp.screen_space_aa = _sd_aa["ssaa"]
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
	var r = game.get("renderer")
	if r is TerrainRenderer:
		apply_materials(r, on)
		_sync_tree_shadows(r)
	var rig = game.get("rig")
	if rig is CameraRig:
		if not rig.has_meta("hd_hook"):
			rig.set_meta("hd_hook", true)
			rig.moved.connect(func(): HDRender._on_cam_moved(rig, sun))
		_on_cam_moved(rig, sun)
	HDPlus.apply(game, _hd_env if on else null, sun, on)   # the HD effects (hdplus.gd): dof, clouds, caustics, season, ...
	if on and not _cycle_added:
		for arg in OS.get_cmdline_user_args():
			if arg.begins_with("--hd-cycle="):   # perf / A-B harness (testing only, hd_cycle.gd)
				_cycle_added = true
				game.add_child(HDCycle.new())
	DayNight.end()


static func _on_cam_moved(rig: CameraRig, sun: DirectionalLight3D) -> void:
	## zoom-adaptive haze and shadow range: aerial haze at close, cinematic zoom; a clear, readable map from far out
	if not active or _hd_env == null or rig.cam == null:
		return
	DayNight.begin()
	var h := rig.cam.global_position.y
	var far := smoothstep(2.5, 14.0, h)
	_hd_env.fog_density = lerpf(0.016, 0.003, far)
	_hd_env.fog_aerial_perspective = lerpf(0.65, 0.3, far)
	# far out the low sun leaves slopes facing away from it in dark streaks: more sky light there
	_hd_env.ambient_light_energy = lerpf(0.48, 1.05, far)
	_hd_env.ssao_intensity = lerpf(1.6, 0.7, far)
	if sun and is_instance_valid(sun):
		sun.directional_shadow_max_distance = lerpf(30.0, 13.0, smoothstep(7.0, 16.0, h))
		sun.light_energy = lerpf(2.45, 2.1, far)   # flatter light from far out; the sky light fills the far slopes
		# from far out the sun climbs (no tree shadows there anyway), so lee slopes no longer read as dark streaks
		sun.rotation_degrees = Vector3(lerpf(-25.0, -50.0, far), -64.0, 0.0)
		RenderingServer.global_shader_parameter_set("hd_sun_dir", Basis.from_euler(sun.rotation_degrees * PI / 180.0).z.normalized())
	HDPlus.on_cam(rig, sun, _hd_env, far)
	DayNight.end()


static func _tex(n: String) -> Texture2D:
	var p := HD_DIR + n + ".png"
	return load(p) if ResourceLoader.exists(p) else null


static func _sync_tree_shadows(r: TerrainRenderer) -> void:
	## v3r fix: vegetation chunks keep the shadow flag they were built with; after a live HD -> SD switch the tree
	## shadows stayed. Match the current preset (SD medium: off; HD / high: on).
	if r._veg_root == null:
		return
	var want := GeometryInstance3D.SHADOW_CASTING_SETTING_ON if bool(Quality.current()["tree_shadows"]) else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for chunk in r._veg_root.get_children():
		for m in chunk.get_children():
			if m is MultiMeshInstance3D and m.cast_shadow != want:
				m.cast_shadow = want


static func apply_materials(r: TerrainRenderer, on: bool) -> void:
	if r.terrain_mat:
		var slots := {"n_grass": "terrain_grassland", "n_plains": "terrain_plains", "n_hills": "terrain_hills_limestone",
			"n_rock": "terrain_desert_rock", "n_sand": "terrain_desert_sand", "n_beach": "terrain_beach_sand"}
		for k in slots:
			var t := _tex(slots[k] + "_nrm")
			if t:
				r.terrain_mat.set_shader_parameter(k, t)
		var pn := TerrainRenderer.kit_tex("kit_paving_n")
		if pn:
			r.terrain_mat.set_shader_parameter("n_paving", pn)
	if r.water_mat:
		var sd_shader: Shader = r.water_mat.get_meta("sd_shader", r.water_mat.shader)
		r.water_mat.set_meta("sd_shader", sd_shader)
		r.water_mat.shader = load("res://scripts/map/water_hd.gdshader") if on else sd_shader
		if on:
			var rip := _tex("water_ripple_n")
			if rip:
				r.water_mat.set_shader_parameter("ripple_n", rip)
	var shore := r.get_node_or_null("HDShore")
	if on and shore == null:
		shore = build_shore(r)
	if shore:
		shore.visible = on
	if r.cities and r.cities.bmat:
		for k in ["stone_facade", "bauhaus_facade", "shikun_facade", "glass_facade", "roof_flat", "roof_tiles"]:
			var t := TerrainRenderer.kit_tex("kit_" + k + "_ao")
			if t:
				r.cities.bmat.set_shader_parameter("ao_" + k.replace("_facade", ""), t)


static func _hd_sun(sun: DirectionalLight3D) -> void:
	# warm, lower late-afternoon sun from the same side as SD (shadows keep their direction), soft PCSS shadows
	sun.rotation_degrees = Vector3(-25, -64, 0)
	sun.light_color = Color(1.0, 0.78, 0.55)
	sun.light_energy = 2.45
	sun.light_angular_distance = 0.0 if "--pcss=off" in OS.get_cmdline_user_args() else 0.5   # --pcss=off: flicker A/B checks
	sun.shadow_blur = 0.8
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
	sun.directional_shadow_max_distance = 30.0
	sun.directional_shadow_split_1 = 0.07
	sun.directional_shadow_split_2 = 0.18
	sun.directional_shadow_split_3 = 0.42
	sun.directional_shadow_blend_splits = true
	sun.shadow_bias = 0.03
	sun.shadow_normal_bias = 1.0
	# world direction toward the sun for the foliage shading (props.gdshader)
	RenderingServer.global_shader_parameter_set("hd_sun_dir", Basis.from_euler(sun.rotation_degrees * PI / 180.0).z.normalized())


static func _make_env(sd: Environment) -> Environment:
	var env: Environment = sd.duplicate(true)
	var sm := env.sky.sky_material as ProceduralSkyMaterial
	if sm:
		sm.sky_top_color = Color(0.22, 0.42, 0.74)
		sm.sky_horizon_color = Color(0.88, 0.84, 0.76)
		sm.ground_horizon_color = Color(0.88, 0.84, 0.76)
		sm.ground_bottom_color = Color(0.30, 0.34, 0.36)
		sm.sun_angle_max = 20.0
	# ambient: sky light, a little warmer and lower than SD; SSIL adds the local bounce between buildings
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.48
	env.ambient_light_sky_contribution = 1.0
	env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	if SDFGI or "--hd-sdfgi" in OS.get_cmdline_user_args():   # measured option, see MAP_API.md
		env.sdfgi_enabled = true
		env.sdfgi_use_occlusion = true
		env.sdfgi_cascades = 4
		env.sdfgi_min_cell_size = 0.08
		env.sdfgi_y_scale = Environment.SDFGI_Y_SCALE_50_PERCENT
		env.sdfgi_energy = 1.0
		env.sdfgi_bounce_feedback = 0.4
	env.ssil_enabled = true
	env.ssil_radius = 0.6
	env.ssil_intensity = 1.4
	env.ssil_sharpness = 0.98
	env.ssil_normal_rejection = 1.0
	# subtle SSAO that grounds buildings and trees (SD's is stronger and wider)
	env.ssao_enabled = true
	env.ssao_radius = 0.35
	env.ssao_intensity = 1.6
	env.ssao_power = 1.4
	env.ssao_detail = 0.7
	env.ssao_horizon = 0.06
	env.ssao_sharpness = 0.98
	env.ssao_light_affect = 0.15
	env.ssao_ao_channel_affect = 0.6
	# tonemapping: AgX, controlled exposure
	env.tonemap_mode = Environment.TONE_MAPPER_AGX
	env.tonemap_exposure = 1.08
	env.tonemap_white = 8.0
	# restrained glow on sparkle and sunlit foam only
	env.glow_enabled = true
	env.glow_intensity = 0.3
	env.glow_strength = 0.9
	env.glow_bloom = 0.0
	env.glow_hdr_threshold = 1.15
	env.glow_hdr_scale = 1.6
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
	# light distance haze with aerial perspective (distant land softens toward the sky colour)
	env.fog_enabled = true
	env.fog_mode = Environment.FOG_MODE_EXPONENTIAL
	env.fog_light_color = Color(0.80, 0.82, 0.84)
	env.fog_light_energy = 1.0
	env.fog_density = 0.016
	env.fog_aerial_perspective = 0.65
	env.fog_sun_scatter = 0.25
	env.fog_sky_affect = 0.5
	env.fog_height = 1.2
	env.fog_height_density = 0.0
	# colour: a little less saturation than SD's candy look, gentle contrast, warm highlights / cool shadows
	env.adjustment_enabled = true
	env.adjustment_saturation = 1.25
	env.adjustment_contrast = 1.13
	env.adjustment_brightness = 1.0
	env.adjustment_color_correction = _grade_lut()
	return env


static func _grade_lut() -> GradientTexture1D:
	## 1D colour-correction curve per channel: lifted cool shadows, slightly warm highlights, soft S-curve
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.25, 0.5, 0.75, 1.0])
	g.colors = PackedColorArray([Color(0.015, 0.025, 0.045), Color(0.235, 0.245, 0.26), Color(0.51, 0.5, 0.49),
		Color(0.775, 0.76, 0.735), Color(1.0, 0.985, 0.95)])
	var t := GradientTexture1D.new()
	t.gradient = g
	t.width = 256
	return t


# ---------------------------------------------------------------- HD shore (existing rock props, no new models)

const ROCK_M := 0.0123   # world units per metre (city_builder STOREY 0.037 = one 3 m storey)


static func _rockiness(t: Dictionary) -> float:
	## how rocky this coast hex really is: Jaffa's reef and old harbour, the Sharon kurkar cliffs, the Carmel coast,
	## Akko and Rosh HaNikra (and the Lebanese coast) are rocky; the southern coast (Bat Yam to Gaza, Sinai) is sand
	var lat := float(t.get("lat", 32.0))
	var lon := float(t.get("lon", 34.5))
	if lat < 30.0 and lon > 34.4:
		return 0.35   # Gulf of Aqaba: coral and granite
	if lat > 32.6:
		return 1.0
	if lat > 32.02 and lat < 32.075:
		return 1.0    # Jaffa
	if lat > 32.14 and lat < 32.5:
		return 0.4    # Herzliya - Netanya kurkar
	return 0.0


static func build_shore(r: TerrainRenderer) -> Node3D:
	## Boulders (MeshKit.rock, as the SD CoastRocks), art-kit shore rock clusters and flat abrasion ledges
	## (shore_rocks_*, shore_reef_flat) along the waterline of rocky coasts. HD only, MultiMesh, distance-culled.
	var node := Node3D.new()
	node.name = "HDShore"
	r.add_child(node)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1948   # own generator: never disturbs the SD placement sequence
	var bx: Array = []; var bc: Array = []
	var art := {}
	var put := func(id: String, p: Vector2, yaw: float, sc: float, y: float) -> void:
		var parts := ArtKit.get_parts(id)
		for i in parts.size():
			var key := "%s:%d" % [id, i]
			if not art.has(key):
				art[key] = [[], []]
			art[key][0].append(Transform3D(Basis(Vector3.UP, yaw) * Basis.from_scale(Vector3.ONE * sc), Vector3(p.x, y, p.y)) * (parts[i]["xf"] as Transform3D))
			var g := rng.randf_range(0.46, 0.54)
			art[key][1].append(Color(g, g * 0.98, g * 0.95, 0))
	for t in r.map.tiles:
		if not t.get("coast", false):
			continue
		var k := _rockiness(t)
		if k <= 0.0:
			continue
		var c := TerrainMath.offset_center(int(t["q"]), int(t["r"]))
		var want := int(60 * k)
		var got := 0
		for i in 900:   # sample the hex densely, keep points on the waterline strip
			if got >= want:
				break
			var p := c + Vector2(rng.randf_range(-1.0, 1.0), rng.randf_range(-0.9, 0.9))
			var h := r.height_at(p.x, p.y)
			if h < -0.04 or h > 0.008:
				continue
			if r.cities and r.cities._in_footprint(p):   # harbours and landmarks only: the old-town shore keeps its rocks
				continue
			got += 1
			var roll := rng.randf()
			if roll < 0.12:
				put.call("shore_reef_flat", p, rng.randf() * TAU, ROCK_M * rng.randf_range(0.45, 0.8), minf(h, 0.0) - 0.006)
			elif roll < 0.24:
				var id: String = ["shore_rocks_small", "shore_rocks_small", "shore_rocks_small", "shore_rocks_medium"][rng.randi() % 4]
				var rel: float = {"shore_rocks_small": 1.1, "shore_rocks_jaffa": 0.42, "shore_rocks_medium": 0.55}[id]
				var sc := ROCK_M * rel * rng.randf_range(1.4, 2.3)
				put.call(id, p, rng.randf() * TAU, sc, h - 0.006)
			else:
				for j in rng.randi_range(2, 5):
					var q := p + Vector2(rng.randf_range(-0.05, 0.05), rng.randf_range(-0.05, 0.05))
					var s := rng.randf_range(0.035, 0.085)
					var b := Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3(s * rng.randf_range(0.9, 1.5), s * rng.randf_range(0.45, 0.8), s))
					bx.append(Transform3D(b, Vector3(q.x, r.height_at(q.x, q.y) - s * 0.3, q.y)))
					var g := rng.randf_range(0.7, 0.92)
					bc.append(Color(g * 1.04 * 0.5, g * 0.96 * 0.5, g * 0.84 * 0.5, 0))   # warm kurkar sandstone
	r.mm(MeshKit.rock(), bx, bc, r.props_material(0.0), "HDBoulders", node)
	for key in art:
		var bits := str(key).split(":")
		var part: Dictionary = ArtKit.get_parts(bits[0])[int(bits[1])]
		r.mm(part["mesh"], art[key][0], art[key][1], part["mat"], "HDShore_" + bits[0], node)
	for ch in node.get_children():
		if ch is GeometryInstance3D:
			(ch as GeometryInstance3D).visibility_range_end = 26.0
			(ch as GeometryInstance3D).visibility_range_end_margin = 3.0
	print("hd: shore rocks %d boulders, %d art parts" % [bx.size(), art.size()])
	return node
