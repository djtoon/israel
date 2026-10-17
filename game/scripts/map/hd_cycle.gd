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

const SETTLE := 40
const MEASURE := 90
const CONVERGE := 40

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
	_run.call_deferred()


func _run() -> void:
	var game := get_tree().get_first_node_in_group("game")
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--hd-size="):   # v5: force the window to WxH physical pixels (the fps bar is 1920x1080)
			var wh := a.substr(10).split("x")
			DisplayServer.window_set_size(Vector2i(int(wh[0]), int(wh[1])))
	for i in 120:   # capture setup (--cam, --ui-ff) and the map build
		await get_tree().process_frame
	print("hd-cycle: window %s screen %s scale %.2f render %s" % [str(DisplayServer.window_get_size()), str(DisplayServer.screen_get_size()),
		DisplayServer.screen_get_scale(), str(get_viewport().get_texture().get_size())])
	var rig: CameraRig = game.get("rig")
	var t0 := rig.target
	var z0 := rig.zoom
	var vp := get_viewport().get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(vp, true)
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
			for i in MEASURE:
				if panning:
					rig.set_view(rig.target.x + 0.04, rig.target.z - 0.03, rig.zoom, true)
				await get_tree().process_frame
				var gt := RenderingServer.viewport_get_measured_render_time_gpu(vp)
				g += gt; gmax = maxf(gmax, gt)
				cpu += RenderingServer.viewport_get_measured_render_time_cpu(vp)
			var vs := Vector2(v.get_texture().get_size())
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
	get_tree().quit()


func _hide_2d(n: Node) -> void:
	for ch in n.get_children():
		if ch is CanvasLayer:
			ch.visible = false
		elif ch is CanvasItem and not ch is Node3D:
			ch.visible = false
		else:
			_hide_2d(ch)
