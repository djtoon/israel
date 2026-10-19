class_name HDCycle
extends Node
## Perf / A-B harness for SD / HD / HD+ (testing only; added by HDRender.apply when --hd-cycle= is given).
## Several configurations in ONE Godot run, switched live through the Settings path
## (GameSettings.apply_graphics_mode), so comparison shots and frame times share the camera, seed, turn and GPU
## temperature, the run count stays low, and live switching itself is exercised.
##
##   --hd-cycle=hd;hdplus;sd;hdplus+fsr   --hd-out=C:/abs/dir/prefix_   [--hd-pan] [--no-hud]
##   (with --quality=hd --shot=<any>.png --frames=100000, so capture.gd sets capture mode but never shoots first)
##
## cfg: "sd"; "hd" (alias "base") = HD without the HD+ effects; "hdplus" = HD+ with every effect; "hdplus-a-b" =
## HD+ without effects a, b; "+fsr" adds FSR 2 upscaling; "#x,z,zoom" at the end moves the camera.
## v5: "@dawn" / "@noon" / "@sunset" / "@night" / "@<hour>" / "@off" before the "#" fixes the day / night clock
## (DayNight.set_time; "@off" = no day / night at all, for the noon identity A/B). --hd-quick skips the frame-time
## measurement (screenshots only: a much shorter, cooler run); --hd-pan-only measures only while panning.
## Per cfg: switch, settle, measure GPU/CPU render time over MEASURE frames static (and with --hd-pan again while
## the camera pans along the coast, then snaps back), converge, save <prefix><index>_<cfg>.png. Prints "hd-perf[...]" lines.

var SETTLE := 40
var MEASURE := 90
var CONVERGE := 40   # perf60: --hd-settle=N / --hd-measure=N / --hd-converge=N (shorter, cooler runs)

var cfgs: Array = []
var out := ""
var pan := false
var nohud := false
var quick := false


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--hd-cycle="):
			cfgs = Array(a.substr(11).split(";", false))
		elif a.begins_with("--hd-out="):
			out = a.substr(9)
		elif a == "--hd-pan":
			pan = true
		elif a == "--no-hud":
			nohud = true
		elif a == "--hd-quick":
			quick = true
		elif a.begins_with("--hd-settle="):
			SETTLE = int(a.substr(12))
		elif a.begins_with("--hd-measure="):
			MEASURE = int(a.substr(13))
		elif a.begins_with("--hd-converge="):
			CONVERGE = int(a.substr(14))
	_run.call_deferred()


func _run() -> void:
	var game := get_tree().get_first_node_in_group("game")
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--hd-size="):   # v5: force the window to WxH physical pixels (the fps bar is 1920x1080)
			var wh := a.substr(10).split("x")
			DisplayServer.window_set_size(Vector2i(int(wh[0]), int(wh[1])))
	for i in 120:   # capture setup (--cam, --ui-ff) and the map build
		await get_tree().process_frame
	var tw := Time.get_ticks_msec()
	while (ArtKit.warm_busy() or game.renderer.cities._lod_serial != ArtKit.far_serial or game.renderer.busy() or bool(game.get("_dirty"))) and Time.get_ticks_msec() - tw < 60000:
		await get_tree().process_frame   # perf60: the background model warm-up and far LODs first (with --async-map)
	print("hd-cycle: waited %d ms for the model warm-up" % (Time.get_ticks_msec() - tw))
	print("hd-cycle: window %s screen %s scale %.2f render %s" % [str(DisplayServer.window_get_size()), str(DisplayServer.screen_get_size()),
		DisplayServer.screen_get_scale(), str(get_viewport().get_texture().get_size())])
	print("hd-cycle: window.size %s content_scale %s factor %.3f stretch %s final xf %s dpi %d" % [str(get_window().size), str(get_window().content_scale_size),
		get_window().content_scale_factor, str(get_window().content_scale_mode), str(get_viewport().get_final_transform().get_scale()), DisplayServer.screen_get_dpi()])
	var rig: CameraRig = game.get("rig")
	var t0 := rig.target
	var z0 := rig.zoom
	var vp := get_viewport().get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(vp, true)
	if "--hd-heavy" in OS.get_cmdline_user_args():
		_heavy()
	for ci in cfgs.size():
		var cc: String = cfgs[ci]
		var c := cc
		if "#" in cc:
			var cp := cc.get_slice("#", 1).split(",")
			t0 = Vector3(float(cp[0]), 0.0, float(cp[1]))
			z0 = float(cp[2])
			c = cc.get_slice("#", 0)
		var tod := ""
		if "@" in c:
			tod = c.get_slice("@", 1)
			c = c.get_slice("@", 0)
		var names: Array = []
		var parts := c.split("+", false)
		var base := str(parts[0]) if parts.size() > 0 else "hd"
		if base.begins_with("t-"):   # perf60: "t-<tier>[+lever=value...]" = a GfxTier ladder step (+ lever overrides)
			GfxTier.select(base.substr(2))
			var lv := GfxTier.levers.duplicate()
			for p in parts.slice(1):
				if "=" in p:
					var kv := str(p).split("=")
					lv[kv[0]] = (kv[1] == "1" or kv[1] == "true") if kv[0] in ["ssil", "ssao", "pcss", "fxaa", "glow", "fsr", "shadow_proxy", "shadow_far"] else float(kv[1])
			GfxTier.levers = lv
			Quality.fsr = bool(lv.get("fsr", false))
			HDPlus.set_effects(lv.get("fx", HDPlus.ALL_FX) as Array)
			GameSettings.graphics_hd = Quality.hd
			GameSettings.graphics_plus = Quality.plus
			GameSettings.quality = Quality.level
			GameSettings.upscaling = Quality.fsr
			HDRender.apply(game, Quality.hd)
			if not Quality.hd:
				GameSettings.apply_quality(game)
			GfxTier.apply(game)
			await _measure_cfg(game, rig, t0, z0, tod, c, ci, lv.get("fx", []) as Array)
			continue
		GfxTier.select("")
		var plus := base.begins_with("hdplus")
		if plus:
			names = HDPlus.ALL_FX.duplicate()
			for n in base.split("-", false).slice(1):
				names.erase(n)
		HDPlus.set_effects(names)
		if base.begins_with("sd-"):   # v5: "sd-medium" / "sd-low" / "sd-high" = SD with that preset (never saved)
			GameSettings.quality = base.get_slice("-", 1)
			base = "sd"
		Quality.fsr = parts.has("fsr")
		GameSettings.upscaling = Quality.fsr
		GameSettings.graphics_hd = base != "sd"
		GameSettings.graphics_plus = plus
		GameSettings.apply_graphics_mode(game)   # the Settings path (never saved here)
		await _measure_cfg(game, rig, t0, z0, tod, c, ci, names)
	get_tree().quit()


func _measure_cfg(game: Node, rig: CameraRig, t0: Vector3, z0: float, tod: String, c: String, ci: int, names: Array) -> void:
	var vp := get_viewport().get_viewport_rid()
	rig.set_view(t0.x, t0.z, z0, true)
	DayNight.set_time(tod if tod != "" else "noon")
	if tod != "":
		c += "@" + tod
	for i in SETTLE:
		await get_tree().process_frame
	var v := get_viewport()
	var runs: Array = [] if quick else ([false, true] if pan else [false])
	if "--hd-pan-only" in OS.get_cmdline_user_args():   # v5: only the panning measurement (the fps bar), a shorter run
		runs = [true]
	for panning in runs:
		var g := 0.0; var cpu := 0.0; var gmax := 0.0
		var ts: Array = []
		for i in MEASURE:
			if panning:
				rig.set_view(rig.target.x + 0.04, rig.target.z - 0.03, rig.zoom, true)
			await get_tree().process_frame
			var gt := RenderingServer.viewport_get_measured_render_time_gpu(vp)
			g += gt; gmax = maxf(gmax, gt)
			ts.append(gt)
			cpu += RenderingServer.viewport_get_measured_render_time_cpu(vp)
		var vs := Vector2(v.get_texture().get_size())
		if "--hd-dump" in OS.get_cmdline_user_args():
			print("hd-dump[%s%s] %s" % [c, " pan" if panning else "", " ".join(PackedStringArray(ts.map(func(x): return "%.1f" % x)))])
		ts.sort()
		_passes(c + (" pan" if panning else ""))
		print("hd-p95[%s%s] %.2f ms  median %.2f  avg %.2f  trimmed-p95 %.2f" % [c, " pan" if panning else "", float(ts[int(ts.size() * 0.95)]), float(ts[ts.size() / 2]), g / maxf(ts.size(), 1), GfxDetect.trimmed_p95(ts)])
		print("hd-perf[%s%s] gpu avg %.2f ms (max %.2f) = %.0f fps  cpu avg %.2f ms  over %d frames  window %dx%d 3d-scale %.2f msaa %d fx=%s" % [
			c, " pan" if panning else "", g / MEASURE, gmax, 1000.0 / maxf(g / MEASURE, 0.01), cpu / MEASURE, MEASURE, int(vs.x), int(vs.y),
			v.scaling_3d_scale, v.msaa_3d, ",".join(PackedStringArray(names))])
	if pan:
		rig.set_view(t0.x, t0.z, z0, true)
	for i in CONVERGE:
		await get_tree().process_frame
	if out != "":
		if nohud:
			_hide_2d(get_tree().root)
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var path: String = out + "%d_" % ci + c.replace("+", "_") + ".png"
		v.get_texture().get_image().save_png(path)
		print("HD CYCLE CAPTURED ", path)


static func _tris(m: Mesh) -> int:
	if m == null:
		return 0
	var n := 0
	for si in m.get_surface_count():
		var a := m.surface_get_arrays(si)
		if a.size() == 0:
			continue
		n += ((a[Mesh.ARRAY_INDEX] as PackedInt32Array).size() if a[Mesh.ARRAY_INDEX] != null else (a[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()) / 3
	return n


func _heavy() -> void:
	## perf60: the heaviest geometry in the scene (triangles, x instances), whether it casts shadows, its draw range
	var game := get_tree().get_first_node_in_group("game")
	var rows: Array = []
	var cache := {}
	for g in game.find_children("*", "GeometryInstance3D", true, false):
		var gi := g as GeometryInstance3D
		if not gi.is_visible_in_tree():
			continue
		var tri := 0
		var key := ""
		if gi is MeshInstance3D:
			var m := (gi as MeshInstance3D).mesh
			if m == null: continue
			if not cache.has(m): cache[m] = _tris(m)
			tri = cache[m]
			key = str(m.resource_path.get_file()) if m.resource_path != "" else gi.name
		elif gi is MultiMeshInstance3D:
			var mm := (gi as MultiMeshInstance3D).multimesh
			if mm == null or mm.mesh == null: continue
			if not cache.has(mm.mesh): cache[mm.mesh] = _tris(mm.mesh)
			tri = cache[mm.mesh] * mm.instance_count
			key = "MM:" + str(gi.name).get_slice("_", 0) + "/" + str(gi.name)
		else:
			continue
		rows.append([tri, key, gi.get_path(), gi.cast_shadow, gi.visibility_range_end])
	rows.sort_custom(func(a, b): return a[0] > b[0])
	var tot := 0; var tot_sh := 0
	for r in rows:
		tot += r[0]
		if r[3] != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF: tot_sh += r[0]
	print("hd-heavy: %d geometry nodes, %d triangles (%d casting shadows)" % [rows.size(), tot, tot_sh])
	var cat := {}
	for r in rows:
		var path := str(r[2])
		var c := "other"
		for k in ["/Terrain", "/Vegetation/", "/Cities/Global", "/Cities/Chunk", "/Cities/Hex", "HDShore", "/Static/", "Boats", "Water"]:
			if k in path:
				c = k
				break
		if c == "/Cities/Chunk":
			c += (" far" if "/far_" in path else (" shp" if "/shp_" in path else (" mid" if "/mid_" in path else (" art" if "/art_" in path else " kit"))))
		if r[3] != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF:
			c += " [casts]"
		if c == "/Vegetation/":
			c += str(path.get_file())
		cat[c] = int(cat.get(c, 0)) + int(r[0])
	var ck := cat.keys()
	ck.sort_custom(func(a, b): return cat[a] > cat[b])
	for k in ck.slice(0, 14):
		print("hd-heavy-cat %10d  %s" % [cat[k], k])
	for r in rows.slice(0, 25):
		print("hd-heavy %9d tris  shadow %d  range %.0f  %s  %s" % [r[0], r[3], r[4], r[1], str(r[2]).replace("/root/Main/", "")])


func _passes(tag: String) -> void:
	## perf60: where the GPU time goes (the renderer's timestamps of the last captured frame) and what was drawn
	var vp := get_viewport().get_viewport_rid()
	print("hd-info[%s] primitives %d  draw calls %d  objects %d  (total: %d prims)" % [tag,
		RenderingServer.viewport_get_render_info(vp, RenderingServer.VIEWPORT_RENDER_INFO_TYPE_VISIBLE, RenderingServer.VIEWPORT_RENDER_INFO_PRIMITIVES_IN_FRAME),
		RenderingServer.viewport_get_render_info(vp, RenderingServer.VIEWPORT_RENDER_INFO_TYPE_VISIBLE, RenderingServer.VIEWPORT_RENDER_INFO_DRAW_CALLS_IN_FRAME),
		RenderingServer.viewport_get_render_info(vp, RenderingServer.VIEWPORT_RENDER_INFO_TYPE_VISIBLE, RenderingServer.VIEWPORT_RENDER_INFO_OBJECTS_IN_FRAME),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)])
	print("hd-info[%s] shadow: primitives %d  draw calls %d" % [tag,
		RenderingServer.viewport_get_render_info(vp, RenderingServer.VIEWPORT_RENDER_INFO_TYPE_SHADOW, RenderingServer.VIEWPORT_RENDER_INFO_PRIMITIVES_IN_FRAME),
		RenderingServer.viewport_get_render_info(vp, RenderingServer.VIEWPORT_RENDER_INFO_TYPE_SHADOW, RenderingServer.VIEWPORT_RENDER_INFO_DRAW_CALLS_IN_FRAME)])
	var rd := RenderingServer.get_rendering_device()
	if rd == null:
		return
	var n := rd.get_captured_timestamps_count()
	var out := PackedStringArray()
	var prev := -1.0
	var pname := ""
	for i in n:
		var t := float(rd.get_captured_timestamp_gpu_time(i)) / 1000.0   # usec -> ms
		if prev >= 0.0 and t - prev > 0.15:
			out.append("%s %.2f" % [pname, t - prev])
		prev = t
		pname = rd.get_captured_timestamp_name(i)
	print("hd-pass[%s] %d stamps: %s" % [tag, n, " | ".join(out)])


func _hide_2d(n: Node) -> void:
	for ch in n.get_children():
		if ch is CanvasLayer:
			ch.visible = false
		elif ch is CanvasItem and not ch is Node3D:
			ch.visible = false
		else:
			_hide_2d(ch)
