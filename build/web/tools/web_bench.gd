extends Node
## Web build measurement tool (autoload in build/web's copy only; inert without --web-bench).
## --web-bench[=<view>] with a capture (--shot=... --frames=999999): holds the camera, then runs each configuration
## for a few seconds and prints "WEBBENCH <name> fps=<median> worst_ms=<p95>": which part of the frame costs what in
## WebGL, where there is no GPU timer. <view>: x,z,zoom (default: the start view).

const WARM := 2.0
const MEASURE := 4.0
var _on := false
var _view := ""


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--web-bench"):
			_on = true
			if "=" in a:
				_view = a.get_slice("=", 1)
		elif a == "--web-shader-probe":
			_probe.call_deferred()
		elif a.begins_with("--web-shots="):
			_shots.call_deferred(a.substr(12))
		elif a.begins_with("--web-pan="):
			_pan.call_deferred(a.substr(10))
		elif a.begins_with("--web-ablate="):
			_ablate.call_deferred(a.substr(13))
		elif a.begins_with("--web-steps="):
			_steps.call_deferred(a.substr(12))
		elif a.begins_with("--web-hit="):
			_hit.call_deferred(a.substr(10))
		elif a.begins_with("--web-ab="):
			_ab.call_deferred(a.substr(9))
		elif a.begins_with("--web-diag="):
			_diag.call_deferred(a.substr(11))
		elif a.begins_with("--web-open-test="):
			_open_url = a.substr(16)   # the next mouse click opens this URL as the citation links do (OS.shell_open)


var _open_url := ""


var _save_test := 0   # --web-save-test: 1st click exports the newest save, 2nd click opens the import picker


func _input(e: InputEvent) -> void:
	if not (e is InputEventMouseButton and not e.pressed):
		return
	if _open_url != "":
		print("WEBOPEN shell_open %s" % _open_url)
		OS.shell_open(_open_url)
		_open_url = ""
	elif "--web-save-test" in OS.get_cmdline_user_args() and not SaveSlots.newest().is_empty():
		_save_test += 1
		if _save_test == 1:
			var n := SaveSlots.newest()
			print("WEBSAVE export %s -> %s" % [str(n.get("path", "")), WebSaves.export_save(str(n.get("path", "")))])
		elif _save_test == 2:
			WebSaves.pick_file(func(r): print("WEBSAVE import %s" % str(r)))
	if _on:
		_run.call_deferred()


func _shots(spec: String) -> void:
	## --web-shots=<view>;<view>;...  view = name:x/z/zoom[:save path]  (with a capture: --shot=... --frames=999999)
	## for each view: load the save (if any), set the camera, noon then night; hides the 2D layers and prints
	## "WEBSHOT <name>_<time>" when the frame is ready (the browser test screenshots the page then), "WEBSHOT done"
	for i in 60:
		await get_tree().process_frame
	var g := _game()
	while g == null or g.renderer == null or g.renderer.busy():
		await get_tree().process_frame
		g = _game()
	for v in spec.split(";", false):
		var parts := v.split(":")
		var nm := parts[0]
		var cam := parts[1].split("/")
		if parts.size() > 2 and parts[2] != "":
			var ui = g.get("game_ui")
			ui.quick_load(parts[2])
			for i in 30:
				await get_tree().process_frame
			while g.renderer.busy() or bool(g.get("_dirty")):
				await get_tree().process_frame
			if ui.end_s and ui.end_s.visible:
				ui.end_s.close()
			await _frames_for(10.0)   # (new buildings fade in after a load)
		for t in ["noon", "night"]:
			g.set_camera(float(cam[0]), float(cam[1]), float(cam[2]))
			GameSettings.time_of_day = t
			GameSettings.apply_daynight(true)
			_hide_layers(true)
			await _frames_for(4.0)
			print("WEBSHOT %s_%s" % [nm, t])
			await _frames_for(3.0)
		_hide_layers(false)
	print("WEBSHOT done")


func _diag(out_dir: String) -> void:
	## --web-diag=<dir> (native runs of the web copy): at the current time of day, one PNG per toggle of what lights
	## the scene (fog, shadows, adjustments, the light's energy, the ambient), to find what a renderer does differently
	for i in 60:
		await get_tree().process_frame
	var g := _game()
	while g == null or g.renderer == null or g.renderer.busy():
		await get_tree().process_frame
		g = _game()
	await _frames_for(3.0)
	var sun := g.get_node_or_null("Sun") as DirectionalLight3D
	var env: Environment = null
	for c in g.get_children():
		if c is WorldEnvironment:
			env = (c as WorldEnvironment).environment
	DayNight.paused = true
	var configs := [["base", func(): pass, func(): pass]]
	var e0 := sun.light_energy
	for pr in [[0.4, 2.5], [0.8, 2.5], [0.8, 3.5], [1.2, 3.0], [0.5, 4.0]]:
		var ae: float = pr[0]
		var mk: float = pr[1]
		configs.append(["amb%.1f_moon%.1f" % [ae, mk], func(): env.ambient_light_energy = ae; sun.light_energy = e0 * mk, func(): sun.light_energy = e0])
	_hide_layers(true)
	for c in configs:
		(c[1] as Callable).call()
		await _frames_for(1.0)
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/diag_%s.png" % [out_dir, c[0]])
		print("WEBDIAG %s light=%.3f %s amb=%s %.2f src=%d" % [c[0], sun.light_energy, str(sun.light_color), str(env.ambient_light_color), env.ambient_light_energy, env.ambient_light_source])
		(c[2] as Callable).call()
	print("WEBDIAG done")
	get_tree().quit()


func _pan(spec: String) -> void:
	## --web-pan=x/z/zoom[:save path] (with a capture): loads the save, then pans the camera slowly for 20 s and prints
	## "WEBPAN fps=<median> p5=<5th percentile fps> worst_ms=<worst frame>", then the same static
	for i in 60:
		await get_tree().process_frame
	var g := _game()
	while g == null or g.renderer == null or g.renderer.busy():
		await get_tree().process_frame
		g = _game()
	var parts := spec.split(":")
	var cam := parts[0].split("/")
	if parts.size() > 1 and parts[1] != "":
		g.get("game_ui").quick_load(parts[1])
		for i in 30:
			await get_tree().process_frame
		while g.renderer.busy() or bool(g.get("_dirty")):
			await get_tree().process_frame
		var ui = g.get("game_ui")
		if ui.end_s and ui.end_s.visible:
			ui.end_s.close()
	var x := float(cam[0])
	var z := float(cam[1])
	var zoom := float(cam[2])
	g.set_camera(x, z, zoom)
	await _frames_for(12.0)   # (fade-ins, shader compiles)
	for mode in ["pan", "static"]:
		var ts := []
		var t0 := Time.get_ticks_usec()
		var last := t0
		while Time.get_ticks_usec() - t0 < 20e6:
			if mode == "pan":
				var k := (Time.get_ticks_usec() - t0) / 20e6
				g.set_camera(x + sin(k * TAU) * 2.5, z + (k - 0.5) * 3.0, zoom, false)
			await get_tree().process_frame
			var now := Time.get_ticks_usec()
			ts.append((now - last) / 1000.0)
			last = now
		ts.sort()
		var med: float = ts[ts.size() / 2]
		var p95: float = ts[mini(ts.size() - 1, int(ts.size() * 0.95))]
		print("WEBPAN %s tier=%s fps=%.1f p5_fps=%.1f worst_ms=%.0f frames=%d" % [mode, GfxTier.active, 1000.0 / med, 1000.0 / p95, ts.back(), ts.size()])
	print("WEBPAN done")


func _ablate(spec: String) -> void:
	## --web-ablate=x/z/zoom[:save][:only=a+b+c] (with a capture): every effect on, every effect off ("bare"), then each
	## effect removed from "on" and each added to "bare", "on" and "bare" again; for each, the same scripted 8 s camera
	## pan: "WEBABL <config> fps=<median> p5=<5th pct fps> ms=<median frame ms>", the frame-rate cap lifted
	for i in 60:
		await get_tree().process_frame
	var g := _game()
	while g == null or g.renderer == null or g.renderer.busy():
		await get_tree().process_frame
		g = _game()
	var parts := spec.split(":")
	var cam := parts[0].split("/")
	var only: Array = []
	for pp in parts:
		if pp.begins_with("only="):
			only = Array(pp.substr(5).split("+"))
	if parts.size() > 1 and parts[1] != "" and not parts[1].begins_with("only="):
		g.get("game_ui").quick_load(parts[1])
		for i in 30:
			await get_tree().process_frame
		while g.renderer.busy() or bool(g.get("_dirty")):
			await get_tree().process_frame
		var ui = g.get("game_ui")
		if ui.end_s and ui.end_s.visible:
			ui.end_s.close()
	var x := float(cam[0])
	var z := float(cam[1])
	var zoom := float(cam[2])
	g.set_camera(x, z, zoom)
	Engine.max_fps = 0
	await _frames_for(12.0)
	var vp := get_viewport()
	var sun := g.get_node_or_null("Sun") as DirectionalLight3D
	var env: Environment = null
	for c in g.get_children():
		if c is WorldEnvironment:
			env = (c as WorldEnvironment).environment
	var r: Node = g.renderer
	var dyn := r.get_node_or_null("Dynamic")
	var cities := r.get("cities") as Node3D
	var veg := dyn.get_node_or_null("Vegetation") if dyn else null
	var shadows_n: Array = veg.find_children("shadow", "MultiMeshInstance3D", true, false) if veg else []
	var heroes: Array = cities.find_children("*", "MeshInstance3D", true, false) if cities else []
	var kits: Array = cities.find_children("*", "MultiMeshInstance3D", true, false) if cities else []
	var layers: Array = get_tree().root.find_children("*", "CanvasLayer", true, false)
	var msaa := vp.msaa_3d
	var tm: ShaderMaterial = r.get("terrain_mat")
	var ui2 = g.get("game_ui")
	var fx := {
		"shadows": [func(): sun.shadow_enabled = false, func(): sun.shadow_enabled = true],
		"daynight": [func(): DayNight.inst.set_process(false), func(): DayNight.inst.set_process(true)],
		"water": [func(): _vis(r, "Water", false), func(): _vis(r, "Water", true)],
		"terrain": [func(): _vis(r, "Terrain", false), func(): _vis(r, "Terrain", true)],
		"terrain_textures": [func(): tm.set_shader_parameter("use_textures", 0.0); tm.set_shader_parameter("use_paving", 0.0),
			func(): tm.set_shader_parameter("use_textures", 1.0); tm.set_shader_parameter("use_paving", 1.0)],
		"grid_borders": [func(): tm.set_shader_parameter("grid_alpha", 0.0), func(): tm.set_shader_parameter("grid_alpha", 0.16)],
		"trees": [func(): _vis(dyn, "Vegetation", false), func(): _vis(dyn, "Vegetation", true)],
		"tree_shadows": [func(): _setv(shadows_n, false), func(): _setv(shadows_n, true)],
		"kit_buildings": [func(): _setv(kits, false), func(): _setv(kits, true)],
		"landmarks_heroes": [func(): _setv(heroes, false), func(): _setv(heroes, true)],
		"coast_static": [func(): _vis(r, "Static", false), func(): _vis(r, "Static", true)],
		"boats_units": [func(): _vis(dyn, "Boats", false); _vis(g, "MapView", false), func(): _vis(dyn, "Boats", true); _vis(g, "MapView", true)],
		"labels_3d": [func(): _vis(dyn, "ZoneLabels", false); _vis(r, "WonderLabels", false), func(): _vis(dyn, "ZoneLabels", true); _vis(r, "WonderLabels", true)],
		"hud_labels_2d": [func(): _setv(layers, false), func(): _setv(layers, true)],
		"fog": [func(): env.fog_enabled = false, func(): env.fog_enabled = true],
		"msaa": [func(): vp.msaa_3d = Viewport.MSAA_DISABLED, func(): vp.msaa_3d = msaa],
		"scale_0.5": [func(): vp.scaling_3d_scale = 0.5, func(): vp.scaling_3d_scale = 1.0],
		"game_ui_process": [func(): ui2.set_process(false), func(): ui2.set_process(true)],
		"layer1_map_labels": [func(): _layer(layers, 1, false), func(): _layer(layers, 1, true)],
		"layer2_hud": [func(): _layer(layers, 2, false), func(): _layer(layers, 2, true)],
		"layer3_game_ui": [func(): _layer(layers, 3, false), func(): _layer(layers, 3, true)],
		"kit_far_lod_everywhere": [func(): _kit_lod(cities, 0.01), func(): _kit_lod(cities, -1.0)],
		"minimap": [func(): _minimap(g, false), func(): _minimap(g, true)],
		"canvas_0.75": [func(): JavaScriptBridge.eval("window.ibnSetScale(0.75)", true), func(): JavaScriptBridge.eval("window.ibnSetScale(1.0)", true)],
		"canvas_0.5": [func(): JavaScriptBridge.eval("window.ibnSetScale(0.5)", true), func(): JavaScriptBridge.eval("window.ibnSetScale(1.0)", true)],
	}
	if not only.is_empty():
		for k in fx.keys():
			if not only.has(k):
				fx.erase(k)
	var keys: Array = fx.keys()
	var run := func(name: String) -> void:
		await _frames_for(2.0)
		var ts := []
		var t0 := Time.get_ticks_usec()
		var last := t0
		while Time.get_ticks_usec() - t0 < 8e6:
			var k := (Time.get_ticks_usec() - t0) / 8e6
			g.set_camera(x + sin(k * TAU) * 2.0, z + (k - 0.5) * 2.4, zoom, false)
			await get_tree().process_frame
			var now := Time.get_ticks_usec()
			ts.append((now - last) / 1000.0)
			last = now
		ts.sort()
		var med: float = ts[ts.size() / 2]
		var p95: float = ts[mini(ts.size() - 1, int(ts.size() * 0.95))]
		print("WEBABL %s tier=%s fps=%.1f p5=%.1f ms=%.1f n=%d" % [name, GfxTier.active, 1000.0 / med, 1000.0 / p95, med, ts.size()])
	var all_off := func() -> void:
		for k in keys: (fx[k][0] as Callable).call()
	var all_on := func() -> void:
		for k in keys: (fx[k][1] as Callable).call()
	await run.call("ON")
	all_off.call()
	await run.call("BARE")
	all_on.call()
	for k in keys:
		(fx[k][0] as Callable).call()
		await run.call("ON-minus-" + k)
		(fx[k][1] as Callable).call()
	all_off.call()
	for k in keys:
		(fx[k][1] as Callable).call()
		await run.call("BARE-plus-" + k)
		(fx[k][0] as Callable).call()
	await run.call("BARE-again")
	all_on.call()
	await run.call("ON-again")
	print("WEBABL done")


func _steps(spec: String) -> void:
	## --web-steps=x/z/zoom[:save] (with --tier=web_low): the same 8 s pan after each web_low step, cumulatively:
	## "WEBSTEP <n> <step> fps=<median> p5=<5th pct fps> ms=<median frame ms>" (the frame-rate cap lifted)
	for i in 60:
		await get_tree().process_frame
	var g := _game()
	while g == null or g.renderer == null or g.renderer.busy():
		await get_tree().process_frame
		g = _game()
	var parts := spec.split(":")
	var cam := parts[0].split("/")
	if parts.size() > 1 and parts[1] != "":
		g.get("game_ui").quick_load(parts[1])
		for i in 30:
			await get_tree().process_frame
		while g.renderer.busy() or bool(g.get("_dirty")):
			await get_tree().process_frame
		var ui = g.get("game_ui")
		if ui.end_s and ui.end_s.visible:
			ui.end_s.close()
	var x := float(cam[0])
	var z := float(cam[1])
	var zoom := float(cam[2])
	g.set_camera(x, z, zoom)
	var sun := g.get_node_or_null("Sun") as DirectionalLight3D
	var tm: ShaderMaterial = g.renderer.get("terrain_mat")
	var cities: Node = g.renderer.get("cities")
	var lod := func(mid: float) -> void:
		CityBuilder.art_mid = mid
		cities.relod()
	var pan := func(name: String) -> void:
		Engine.max_fps = 0
		await _frames_for(3.0)
		var ts := []
		var t0 := Time.get_ticks_usec()
		var last := t0
		while Time.get_ticks_usec() - t0 < 8e6:
			var k := (Time.get_ticks_usec() - t0) / 8e6
			g.set_camera(x + sin(k * TAU) * 2.0, z + (k - 0.5) * 2.4, zoom, false)
			await get_tree().process_frame
			var now := Time.get_ticks_usec()
			ts.append((now - last) / 1000.0)
			last = now
		ts.sort()
		var med: float = ts[ts.size() / 2]
		var p95: float = ts[mini(ts.size() - 1, int(ts.size() * 0.95))]
		print("WEBSTEP %s fps=%.1f p5=%.1f ms=%.1f n=%d" % [name, 1000.0 / med, 1000.0 / p95, med, ts.size()])
	await _frames_for(10.0)
	# 0: as the first zip on a 150 % display: the canvas at 1.5x, the full terrain, full kit models near, no shadows
	JavaScriptBridge.eval("window.ibnSetScale(1.5)", true)
	tm.set_shader_parameter("web_lite", 0.0)
	lod.call(0.0)
	sun.shadow_enabled = false
	await pan.call("0_before_canvas1.5")
	JavaScriptBridge.eval("window.ibnSetScale(1.0)", true)
	await pan.call("1_canvas_css_pixels_1.0")
	JavaScriptBridge.eval("window.ibnSetScale(0.66)", true)
	await pan.call("2_canvas_0.66")
	tm.set_shader_parameter("web_lite", 1.0)
	await pan.call("3_terrain_lite")
	lod.call(1.0)
	await pan.call("4_building_mid_lod_1000tris")
	sun.shadow_enabled = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	sun.directional_shadow_max_distance = 10.0
	RenderingServer.directional_shadow_atlas_set_size(2048, true)
	await pan.call("5_cheap_shadows_1split_2048_10u")
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	sun.directional_shadow_max_distance = 14.0
	RenderingServer.directional_shadow_atlas_set_size(4096, true)
	await pan.call("6_shadows_2splits_4096_14u")
	sun.shadow_enabled = false
	await pan.call("7_again_step4")
	print("WEBSTEP done")


var _kit_mid0 := -2.0


func _hit(spec: String) -> void:
	## --web-hit=<x>x<y> (window fractions): after 4 s, every visible Control whose rectangle holds that point
	await get_tree().create_timer(4.0).timeout
	var p := spec.split("x")
	var vs := get_viewport().get_visible_rect().size
	var pt := Vector2(float(p[0]) * vs.x, float(p[1]) * vs.y)
	print("WEBHIT point %s of %s" % [pt, vs])
	for n in get_tree().root.find_children("*", "Control", true, false):
		var c := n as Control
		if c.is_visible_in_tree() and c.get_global_rect().has_point(pt) and c.get_global_rect().size.y < vs.y * 0.3:
			print("WEBHIT %s %s rect=%s" % [c.get_class(), c.get_path(), c.get_global_rect()])
	print("WEBHIT done")


func _ab(spec: String) -> void:
	## --web-ab=x/z/zoom:save:cfg|cfg|...  (with a capture and --tier): for each configuration the levers it names on top
	## of the tier's (cfg = name=value+name=value: canvas_scale, world_scale, world_native, shadows, splits, shadow_size,
	## shadow_k, tree_shadows, msaa ...), applied live (GfxTier.apply), then the same 8 s pan with the frame-rate cap
	## lifted: "WEBAB <cfg> fps=<median> p5=<5th pct fps> ms=<median frame ms>"; each twice (A B A B order)
	for i in 60:
		await get_tree().process_frame
	var g := _game()
	while g == null or g.renderer == null or g.renderer.busy():
		await get_tree().process_frame
		g = _game()
	var parts := spec.split(":")
	var cam := parts[0].split("/")
	if parts.size() > 1 and parts[1] != "":
		g.get("game_ui").quick_load(parts[1])
		for i in 30:
			await get_tree().process_frame
		while g.renderer.busy() or bool(g.get("_dirty")):
			await get_tree().process_frame
		var ui = g.get("game_ui")
		if ui.end_s and ui.end_s.visible:
			ui.end_s.close()
	var x := float(cam[0])
	var z := float(cam[1])
	var zoom := float(cam[2])
	g.set_camera(x, z, zoom)
	var cfgs: Array = Array(parts[2].split("|")) if parts.size() > 2 else ["base"]
	var base: Dictionary = GfxTier.levers.duplicate()
	var veg: Node = g.renderer.get_node_or_null("Dynamic/Vegetation")
	var tshadows: Array = veg.find_children("shadow", "MultiMeshInstance3D", true, false) if veg else []
	await _frames_for(10.0)
	for rep in 2:
		for cfg in cfgs:
			var lv := base.duplicate()
			if cfg != "base":
				for kv in str(cfg).split("+"):
					var p := kv.split("=")
					lv[p[0]] = true if p[1] == "true" else (false if p[1] == "false" else float(p[1]))
			GfxTier.levers = lv
			GfxTier.apply(g)
			_setv(tshadows, bool(lv.get("tree_shadows", true)))
			Engine.max_fps = 0
			await _frames_for(3.0)
			var ts := []
			var t0 := Time.get_ticks_usec()
			var last := t0
			while Time.get_ticks_usec() - t0 < 8e6:
				var k := (Time.get_ticks_usec() - t0) / 8e6
				g.set_camera(x + sin(k * TAU) * 2.0, z + (k - 0.5) * 2.4, zoom, false)
				await get_tree().process_frame
				var now := Time.get_ticks_usec()
				ts.append((now - last) / 1000.0)
				last = now
			ts.sort()
			var med: float = ts[ts.size() / 2]
			var p95: float = ts[mini(ts.size() - 1, int(ts.size() * 0.95))]
			var ws := DisplayServer.window_get_size()
			var wv := WorldView.current
			var sub_s := (str(wv.sub.size) + (" off" if wv._off else " on") + " upd%d" % wv.sub.render_target_update_mode) if wv != null and is_instance_valid(wv) else "-"
			var img := get_viewport().get_texture().get_image()
			var cc := Color(0, 0, 0)
			if img:
				for yy in 5:
					for xx in 5:
						cc += img.get_pixel(int(img.get_width() * (0.3 + 0.1 * xx)), int(img.get_height() * (0.3 + 0.1 * yy))) / 25.0
			sub_s += " centre=%.2f,%.2f,%.2f" % [cc.r, cc.g, cc.b]
			print("WEBAB %s fps=%.1f p5=%.1f ms=%.1f n=%d canvas=%dx%d sub=%s root3d=%s" % [cfg, 1000.0 / med, 1000.0 / p95, med, ts.size(), ws.x, ws.y, sub_s, str(not get_viewport().disable_3d)])
	print("WEBAB done")


func _kit_lod(cities: Node, mid: float) -> void:
	## mid < 0: back to the tier's own value
	if _kit_mid0 < -1.0:
		_kit_mid0 = CityBuilder.art_mid
	CityBuilder.art_mid = mid if mid >= 0.0 else _kit_mid0
	if cities and cities.has_method("relod"):
		cities.relod()


func _layer(layers: Array, n: int, on: bool) -> void:
	for l in layers:
		if is_instance_valid(l) and (l as CanvasLayer).layer == n:
			(l as CanvasLayer).visible = on


func _minimap(g: Node, on: bool) -> void:
	var hud = g.get("hud")
	if hud == null:
		return
	for c in (hud as Node).find_children("*", "Control", true, false):
		if str(c.name).to_lower().contains("minimap"):
			(c as Control).visible = on


func _vis(parent: Node, name: String, on: bool) -> void:
	if parent == null:
		return
	var n := parent.get_node_or_null(name)
	if n is Node3D:
		(n as Node3D).visible = on
	elif n is CanvasItem:
		(n as CanvasItem).visible = on


func _setv(nodes: Array, on: bool) -> void:
	for n in nodes:
		if is_instance_valid(n):
			if n is CanvasLayer:
				(n as CanvasLayer).visible = on
			else:
				n.visible = on


var _hid: Array = []


func _hide_layers(on: bool) -> void:
	if on:
		for c in get_tree().root.find_children("*", "CanvasLayer", true, false):
			if (c as CanvasLayer).visible:
				(c as CanvasLayer).visible = false
				_hid.append(c)
	else:
		for c in _hid:
			if is_instance_valid(c):
				c.visible = true
		_hid.clear()


func _probe() -> void:
	## --web-shader-probe: the game's scene is dropped before its first frame; each custom shader is drawn once, alone,
	## with a shadowed sun, and the time of its first two frames (its compiles) is printed: WEBPROBE <shader> <ms>
	var cs := get_tree().current_scene
	if cs:
		cs.queue_free()
	await get_tree().process_frame
	var root := Node3D.new()
	get_tree().root.add_child(root)
	var cam := Camera3D.new()
	root.add_child(cam)
	cam.position = Vector3(0, 2, 4)
	cam.look_at_from_position(cam.position, Vector3.ZERO)
	cam.make_current()
	var sun := DirectionalLight3D.new()
	sun.shadow_enabled = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	sun.rotation_degrees = Vector3(-40, 30, 0)
	root.add_child(sun)
	for i in 10:
		await get_tree().process_frame
	var names := ["standard", "water", "artinst", "artmodel", "diorama", "foliage", "props", "veg_shadow", "building", "terrain"]
	for n in names:
		var mi := MeshInstance3D.new()
		var pm := PlaneMesh.new()
		pm.size = Vector2(2, 2)
		mi.mesh = pm
		if n == "standard":
			mi.material_override = StandardMaterial3D.new()
		else:
			var m := ShaderMaterial.new()
			m.shader = load("res://scripts/map/%s.gdshader" % n)
			mi.material_override = m
		root.add_child(mi)
		var t0 := Time.get_ticks_msec()
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		print("WEBPROBE %s %d ms" % [n, Time.get_ticks_msec() - t0])
		mi.queue_free()
		await get_tree().process_frame
	print("WEBPROBE done")


func _frames_for(sec: float) -> Array:
	var ts := []
	var t0 := Time.get_ticks_usec()
	var last := t0
	while (Time.get_ticks_usec() - t0) < sec * 1e6:
		await get_tree().process_frame
		var now := Time.get_ticks_usec()
		ts.append((now - last) / 1000.0)
		last = now
	return ts


func _stat(ts: Array) -> String:
	var s := ts.duplicate()
	s.sort()
	var med: float = s[s.size() / 2]
	var p95: float = s[mini(s.size() - 1, int(s.size() * 0.95))]
	return "fps=%.1f frame_ms=%.1f p95_ms=%.1f n=%d" % [1000.0 / med, med, p95, s.size()]


func _set_vis(nodes: Array, on: bool) -> void:
	for n in nodes:
		if n is Node3D:
			(n as Node3D).visible = on


func _game() -> Node:
	return get_tree().get_first_node_in_group("game")


func _run() -> void:
	# wait for the map and the shaders
	for i in 30:
		await get_tree().process_frame
	var g := _game()
	while g == null or g.renderer == null or g.renderer.busy():
		await get_tree().process_frame
		g = _game()
	if _view != "":
		var p := _view.split(",")
		g.set_camera(float(p[0]), float(p[1]), float(p[2]))
	await _frames_for(6.0)
	var vp := get_viewport()
	var sun := g.get_node_or_null("Sun") as DirectionalLight3D
	var env: Environment = null
	for c in g.get_children():
		if c is WorldEnvironment:
			env = (c as WorldEnvironment).environment
	var r: Node = g.renderer
	var terrain := r.get_node_or_null("Terrain") as Node3D
	var water := r.get_node_or_null("Water") as Node3D
	var dyn := r.get_node_or_null("Dynamic") as Node3D
	var stat := r.get_node_or_null("Static") as Node3D
	var msaa := vp.msaa_3d
	var cities := r.get("cities") as Node3D
	var veg := dyn.get_node_or_null("Vegetation") as Node3D if dyn else null
	var bgm := env.background_mode
	var configs := [
		["baseline", func(): pass, func(): pass],
		["no_sun", func(): sun.visible = false, func(): sun.visible = true],
		["no_sky", func(): env.background_mode = Environment.BG_COLOR; env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR; env.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED,
			func(): env.background_mode = bgm; env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY; env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY],
		["no_vegetation", func(): _set_vis([veg], false), func(): _set_vis([veg], true)],
		["no_city_builder", func(): _set_vis([cities], false), func(): _set_vis([cities], true)],
		["only_terrain", func(): _set_vis([dyn, stat, water, cities], false), func(): _set_vis([dyn, stat, water, cities], true)],
		["nothing_3d_but_sky", func(): r.visible = false, func(): r.visible = true],
		["no_shadows", func(): sun.shadow_enabled = false, func(): sun.shadow_enabled = true],
		["no_msaa", func(): vp.msaa_3d = Viewport.MSAA_DISABLED, func(): vp.msaa_3d = msaa],
		["no_water", func(): water.visible = false, func(): water.visible = true],
		["no_terrain", func(): terrain.visible = false, func(): terrain.visible = true],
		["no_cities_veg", func(): dyn.visible = false; stat.visible = false, func(): dyn.visible = true; stat.visible = true],
		["no_glow_fog", func(): env.glow_enabled = false; env.fog_enabled = false, func(): env.glow_enabled = true; env.fog_enabled = true],
		["half_res", func(): vp.scaling_3d_scale = 0.5, func(): vp.scaling_3d_scale = 1.0],
		["no_3d", func(): vp.disable_3d = true, func(): vp.disable_3d = false],
		["baseline_again", func(): pass, func(): pass],
	]
	for c in configs:
		(c[1] as Callable).call()
		await _frames_for(WARM)
		var ts: Array = await _frames_for(MEASURE)
		print("WEBBENCH %s %s" % [c[0], _stat(ts)])
		(c[2] as Callable).call()
	print("WEBBENCH done")
