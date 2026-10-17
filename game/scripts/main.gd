extends Node3D
## Game root (group "game"). Builds the map renderer, camera, lighting and HUD.
## Harness API: set_camera(x, z, zoom) in world units (hex size 1, see TerrainMath), end_turn().
## Extra user args: --hover=q,r  --select=q,r  (show hover/selection + tooltip in captures)

var map := MapData.new()
var renderer: TerrainRenderer
var rig: CameraRig
var hud: HUD
var overlay: MapLabels
var game_ui: GameUI         # UI/sim hook (scripts/ui/game_ui.gd)
var map_view: MapView      # public map API for gameplay/UI code, see scripts/map/MAP_API.md
var turn := 1
var hover_off := Vector2i(-99, -99)
var selected_off := Vector2i(-99, -99)
var capture_mode := false
var _poll := 0.0
var _forced_hover := false


func _ready() -> void:
	add_to_group("game")
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--shot="):
			capture_mode = true
	map.load_map()
	_setup_world()
	renderer = TerrainRenderer.new()
	renderer.name = "Map"
	add_child(renderer)
	renderer.build(map)
	rig = CameraRig.new()
	rig.name = "CameraRig"
	add_child(rig)
	rig.height_fn = renderer.height_at
	var ws := map.world_size()
	rig.bounds = Rect2(-2, -2, ws.x + 4, ws.y + 4)
	rig.edge_pan = not capture_mode
	rig.cam.make_current()
	HDRender.apply(self, Quality.is_hd())   # Graphics: HD (scripts/map/hd_render.gd); SD start touches nothing
	DayNight.attach(self)   # v5 day / night on top of SD / HD / HD+ (scripts/map/daynight.gd); noon = the mode's own look
	_setup_ui()
	map_view = MapView.new()
	map_view.name = "MapView"
	add_child(map_view)
	map_view.setup(map, renderer, rig, overlay)
	rig.moved.connect(_on_cam_moved)
	var home := map.find_city("tel_aviv")
	if home.is_empty() and map.cities.size() > 0:
		home = map.cities[0]
	# default framing like the target: Jaffa harbour lower-centre, the city filling the frame behind it
	var c: Vector2 = home.get("pos", map.world_size() * 0.5)
	var jaffa := map.latlon_to_world(32.0530, 34.7530)
	var f := jaffa.lerp(c, 0.55)
	set_camera(f.x, f.y, 2.5)
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--hover="):
			var p := a.substr(8).split(",")
			_set_hover(Vector2i(int(p[0]), int(p[1])))
			_forced_hover = true
		elif a == "--api-demo":
			_api_demo.call_deferred()
		elif a.begins_with("--select="):
			var p := a.substr(9).split(",")
			_select(Vector2i(int(p[0]), int(p[1])))
	_update_hud()
	game_ui = GameUI.attach(self)   # UI/sim hook (scripts/ui owns it): creates the Sim and drives the HUD and turns


func _api_demo() -> void:
	## --api-demo: exercises the MapView API (for MAP_API.md screenshots)
	var ta := map.find_city("tel_aviv")
	var k := Vector2i(ta["q"], ta["r"])
	var ring := []
	for n in TerrainMath.offset_neighbors(k + Vector2i(2, 0)):
		ring.append(n)
	map_view.highlight_tiles(ring, Color(0.3, 0.8, 1.0, 1.0), "move")
	map_view.highlight_tiles([k + Vector2i(3, -2)], Color(1.0, 0.3, 0.2, 1.0), "attack")
	map_view.show_unit("u1", k.x + 2, k.y, "unit_palmach_infantry")
	map_view.show_unit("u2", k.x + 3, k.y - 1, "unit_settler_group")
	map_view.set_city_info("tel_aviv", 21, null, null)


func _setup_world() -> void:
	var env := Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color(0.32, 0.52, 0.82)
	sm.sky_horizon_color = Color(0.93, 0.86, 0.74)
	sm.ground_horizon_color = Color(0.93, 0.86, 0.74)
	sm.ground_bottom_color = Color(0.35, 0.42, 0.45)
	sm.sun_angle_max = 20.0
	sky.sky_material = sm
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.38
	env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	env.tonemap_mode = Environment.TONE_MAPPER_AGX
	env.tonemap_exposure = 1.05
	env.tonemap_white = 6.0
	var qp := Quality.current()
	env.ssao_enabled = qp["ssao"]
	env.ssao_radius = 0.7
	env.ssao_intensity = 2.6
	env.ssao_power = 1.6
	env.ssao_detail = 0.6
	env.glow_enabled = true
	env.glow_intensity = 0.35
	env.glow_bloom = 0.05
	env.glow_hdr_threshold = 1.2
	env.fog_enabled = true
	env.fog_light_color = Color(0.90, 0.84, 0.74)
	env.fog_density = 0.011
	env.fog_aerial_perspective = 0.3
	env.fog_sun_scatter = 0.15
	env.fog_sky_affect = 0.4
	env.adjustment_enabled = true
	env.adjustment_saturation = 1.35
	env.adjustment_contrast = 1.12
	env.adjustment_brightness = 1.0
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-27, -60, 0)
	sun.light_color = Color(1.0, 0.80, 0.56)
	sun.light_energy = 2.15
	sun.shadow_enabled = true
	sun.shadow_blur = 0.6
	sun.light_angular_distance = 0.5 if Quality.level == "high" else 0.0   # >0 = PCSS soft shadows (costly)
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS if int(qp["shadow_splits"]) == 4 else DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	sun.directional_shadow_max_distance = float(qp["shadow_dist"])
	get_viewport().msaa_3d = [Viewport.MSAA_DISABLED, Viewport.MSAA_2X, Viewport.MSAA_4X][int(qp["msaa"])]
	sun.directional_shadow_split_1 = 0.08
	sun.directional_shadow_split_2 = 0.22
	sun.shadow_bias = 0.03
	sun.shadow_normal_bias = 1.0
	add_child(sun)


func _setup_ui() -> void:
	var ol := CanvasLayer.new(); ol.layer = 1; add_child(ol)
	overlay = MapLabels.new()
	overlay.cam = rig.cam; overlay.renderer = renderer; overlay.map = map
	ol.add_child(overlay)
	var hl := CanvasLayer.new(); hl.layer = 2; add_child(hl)
	hud = HUD.new()
	hl.add_child(hud)
	hud.set_map(map)
	hud.next_turn_pressed.connect(end_turn)
	hud.minimap_clicked.connect(func(w: Vector2): set_camera(w.x, w.y, rig.zoom, false))


# ------------------------------------------------------------------ harness API

func set_camera(x: float, z: float, zoom: float = 1.0, snap := true) -> void:
	if rig:
		rig.set_view(x, z, zoom, snap)
		_on_cam_moved()


func end_turn() -> void:
	if game_ui:   # UI/sim hook: the sim advances the turn and calls set_date() back
		game_ui.harness_end_turn()
		return
	turn += 1
	set_date(turn)


var _dirty := false
var _minimap_key := ""
var _dirty_t := 0.0


func set_date(t: int, force := false) -> void:
	## Show the map as it was on turn t (turn 1 = Q2 1948): localities, names, control, borders, skyline.
	## Incremental: only cities whose state changed are rebuilt (see CityBuilder.update).
	turn = t
	if map.set_date(MapData.turn_to_date(t), force):
		_dirty = true
		_dirty_t = 0.0
	_update_hud()


func _apply_date_now() -> void:
	_dirty = false
	renderer.apply_date()
	overlay.reset()
	# the minimap bitmap is costly to redraw: only when borders change or cities grew noticeably
	var mm_key := "%s|%d" % [map.border_era, map.urban.size() / 10]
	if mm_key != _minimap_key:
		_minimap_key = mm_key
		var t0 := Time.get_ticks_msec()
		hud.set_map(map)
		print("render: minimap redrawn in %d ms" % (Time.get_ticks_msec() - t0))
	_on_cam_moved()
	_update_hud()


func _update_hud() -> void:
	if hud == null:
		return
	hud.state["turn"] = turn
	var q := turn  # turn 1 = Q2 1948
	var months := (q - 1) * 3 + 3   # quarter index from Q1 1948 = 1
	var year := 1948 + months / 12
	var quarter := (months % 12) / 3 + 1
	hud.state["date"] = "Q%d %d" % [quarter, year]
	hud.state["era"] = "Modern Era"  # placeholder until the sim piece supplies eras
	var home := map.find_city("tel_aviv")
	hud.set_placeholders(map.year, home)


# ------------------------------------------------------------------ input / picking

var _fps_t := 0.0
var _perf := []
var _perf_frames := 0


func _perf_sample() -> void:
	## --perf: GPU/CPU render time averaged over 120 frames (independent of the fps cap), after the map settles
	var vp := get_viewport().get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(vp, true)
	_perf_frames += 1
	if _dirty:
		_perf_frames = 0
	if _perf_frames < 90:
		return
	_perf.append([RenderingServer.viewport_get_measured_render_time_gpu(vp), RenderingServer.viewport_get_measured_render_time_cpu(vp)])
	if "--perf-pan" in OS.get_cmdline_user_args():   # worst case for GI/shadow updates: a steady pan along the coast
		rig.set_view(rig.target.x + 0.04, rig.target.z - 0.03, rig.zoom, true)
	if _perf.size() >= 120:
		var g := 0.0; var c := 0.0; var gmax := 0.0
		for s in _perf:
			g += s[0]; c += s[1]; gmax = maxf(gmax, s[0])
		var vs := Vector2(get_viewport().get_texture().get_size())
		var ws := DisplayServer.window_get_size()
		print("perf[%s %s render %dx%d window %dx%d] gpu avg %.2f ms (max %.2f)  cpu avg %.2f ms over %d frames" % ["HD" if Quality.hd else "SD", Quality.level, int(vs.x), int(vs.y), ws.x, ws.y, g / _perf.size(), gmax, c / _perf.size(), _perf.size()])
		_perf.clear()
var _rest := 0.0


func _process(delta: float) -> void:
	if _dirty:
		_dirty_t += delta
		if _dirty_t > 0.15:
			_apply_date_now()
	# tile tooltip appears after the mouse rests briefly (always on for forced --hover captures)
	_rest += delta
	if overlay and not _forced_hover:
		overlay.show_tooltip = _rest > 0.45 and not overlay.hover_tile.is_empty() and not capture_mode
	if "--perf" in OS.get_cmdline_user_args():
		_perf_sample()
	_fps_t += delta
	if _fps_t > 1.0 and OS.is_debug_build() and "--fps" in OS.get_cmdline_user_args():
		_fps_t = 0.0
		var vp := get_viewport().get_viewport_rid()
		RenderingServer.viewport_set_measure_render_time(vp, true)
		print("fps %d  gpu %.1f ms  cpu %.1f ms  (fps capped by tools/godot.sh)" % [Engine.get_frames_per_second(),
			RenderingServer.viewport_get_measured_render_time_gpu(vp), RenderingServer.viewport_get_measured_render_time_cpu(vp)])
	if map.src_path == MapData.STANDIN_PATH and not capture_mode:
		_poll += delta
		if _poll > 5.0:
			_poll = 0.0
			if MapData.real_map_exists():
				print("map: data/map.json appeared, reloading")
				get_tree().reload_current_scene()


var _map_press := {}   # mouse button -> its press reached the map (see _unhandled_input)


func _unhandled_input(e: InputEvent) -> void:
	if rig == null:
		return
	# a click counts on the map only if its press reached the map too: a release whose press went to a window
	# (a button that closed or rebuilt its window, so the release falls through) must not pick what lies behind
	if e is InputEventMouseButton and e.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
		if e.pressed:
			_map_press[e.button_index] = true
		elif not _map_press.get(e.button_index, false):
			return
		else:
			_map_press[e.button_index] = false
	if rig.handle_input(e):
		return
	if e is InputEventMouseMotion and not _forced_hover and not capture_mode:
		_rest = 0.0
		_set_hover(pick(e.position))
		overlay.hover_screen = e.position
	elif e is InputEventMouseButton and not e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		var bid := overlay.banner_at(e.position)
		if bid != "":
			map_view.city_clicked.emit(bid)
			return
		var off := pick(e.position)
		_select(off)
		map_view.tile_clicked.emit(off.x, off.y)
		var c := map_view.city_at(off.x, off.y)
		if not c.is_empty():
			map_view.city_clicked.emit(str(c["id"]))
	elif e is InputEventMouseButton and not e.pressed and e.button_index == MOUSE_BUTTON_RIGHT:
		var off := pick(e.position)
		map_view.tile_right_clicked.emit(off.x, off.y)


func pick(screen: Vector2) -> Vector2i:
	var y := 0.1
	var hit := Vector3.ZERO
	for i in 4:
		hit = rig.ground_point(screen, y)
		y = maxf(0.0, renderer.height_at(hit.x, hit.z))
	return TerrainMath.world_to_offset(Vector2(hit.x, hit.z))


func _set_hover(off: Vector2i) -> void:
	if off == hover_off:
		return
	hover_off = off
	renderer.set_hover(off)
	if map_view:
		map_view.tile_hovered.emit(off.x, off.y)
	overlay.hover_tile = map.tile_at(off)
	overlay.show_tooltip = not overlay.hover_tile.is_empty() and (_forced_hover or not capture_mode)
	if _forced_hover or capture_mode:
		var c := TerrainMath.offset_center(off.x, off.y)
		var p := Vector3(c.x, renderer.height_at(c.x, c.y), c.y)
		overlay.hover_screen = rig.cam.unproject_position(p)


func _select(off: Vector2i) -> void:
	selected_off = off
	renderer.set_selected(off)


func _on_cam_moved() -> void:
	if hud == null or rig == null:
		return
	var vs := Vector2(get_viewport().get_texture().get_size())
	var pts := PackedVector2Array()
	for s in [Vector2(0, 47), Vector2(vs.x, 47), vs, Vector2(0, vs.y)]:
		var g := rig.ground_point(s, 0.0)
		pts.append(Vector2(g.x, g.z))
	hud.set_view_quad(pts)
