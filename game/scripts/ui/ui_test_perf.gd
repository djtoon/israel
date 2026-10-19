class_name PerfRun
extends RefCounted
## perf60: the stutter scenario (UITest mode --ui-test-perf). A new game (Full control), then
##   1. panning: the camera flies over the map like keyboard panning (9 / zoom units a second) along Tel Aviv -
##      Haifa - the Galilee - Jerusalem - the Negev and back, zooming in and out, for --perf-pan-s seconds (120);
##   2. turn-ends: --perf-turns (10) End Turns through GameUI.end_turn (forced, so the run needs no clicks), each
##      followed by 4 s of slow panning; the turn-end hitch = the longest frame from the press to 4 s later.
## Prints "PERF ..." lines (FrameLog statistics, the spikes and what ran in them) and writes <dir>/perf.txt.
##   tools/godot.sh [--headless] --path /c/civ/game -- --shot=x.png --ui-test=<dir> --ui-test-perf [--perf-pan-s=120]
##       [--perf-turns=10] [--perf-load=<save.json>] [--tier=<GfxTier>] [--frame-log=<dir>/frames.txt]
## Headless: the main thread's CPU time per frame (no renderer, no cap). Windowed (agent runs are capped at 30 fps):
## the real frames, where only frames over about 34 ms are hitches.

const WAY := [["tel_aviv", 2.5], ["haifa", 1.6], ["tiberias", 1.2], ["jerusalem", 2.2], ["beersheba", 1.0], ["tel_aviv", 2.0]]


static func _arg(name: String, def: float) -> float:
	for a in OS.get_cmdline_user_args():
		if a.begins_with(name + "="):
			return float(a.substr(name.length() + 1))
	return def


static func run(t: UITest) -> void:
	var ui = t.ui
	var game: Node = t.get_tree().get_first_node_in_group("game")
	var fl := FrameLog.ensure(game)
	var lines: Array = []
	var say := func(l: String) -> void:
		lines.append(l)
		t.say(l)   # (as it happens: a run stopped by the GPU guard still leaves its numbers)
	var pan_s := _arg("--perf-pan-s", 120.0)
	var turns := int(_arg("--perf-turns", 10.0))
	ui.start_new_game(false, false, {"play_style": "full"})
	FrameLog.phase = "settle"
	await t._frames(90)
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--perf-load="):   # a save to start from (the late game: Tel Aviv 2023)
			await _wait_map(t, game)
			ui.quick_load(a.substr(12))
			await t._frames(30)
	await _wait_map(t, game)
	await t._frames(30)
	# ---- 1. panning
	var pts: Array = []
	for w in WAY:
		var c: Dictionary = game.map.find_city(str(w[0]))
		if not c.is_empty():
			var p: Vector2 = c["pos"]
			pts.append([p, float(w[1])])
	FrameLog.phase = "pan"
	fl.reset()
	var t_end := Time.get_ticks_msec() + int(pan_s * 1000.0)
	var seg := 0
	var pos: Vector2 = pts[0][0]
	var zoom: float = pts[0][1]
	var last := Time.get_ticks_msec()
	while Time.get_ticks_msec() < t_end:
		await t.get_tree().process_frame
		var now := Time.get_ticks_msec()
		var dt := minf((now - last) / 1000.0, 0.1)
		last = now
		var nxt: Array = pts[(seg + 1) % pts.size()]
		var to: Vector2 = nxt[0]
		var step := 9.0 / zoom * dt
		var d := pos.distance_to(to)
		if d <= step:
			pos = to
			seg = (seg + 1) % pts.size()
		else:
			var along := 1.0 - (d - step) / maxf(d, 0.001)
			pos = pos.move_toward(to, step)
			zoom = lerpf(zoom, float(nxt[1]), clampf(along * 1.5, 0.0, 1.0))
		game.set_camera(pos.x, pos.y, zoom, true)
	var pan_ts := fl.select("pan")
	var pst := FrameLog.stats(pan_ts)
	say.call("PERF pan %d s: %s" % [int(pan_s), FrameLog.fmt(pst)])
	for s in fl.spikes(50.0, "pan").slice(0, 12):
		say.call("PERF   pan spike %.1f ms  %s" % [s[0], s[2]])
	# ---- 2. turn-ends
	var hitches: Array = []
	var home: Dictionary = game.map.find_city("tel_aviv")
	var hp: Vector2 = home.get("pos", pos)
	game.set_camera(hp.x, hp.y, 2.4, true)
	for i in turns:
		if ui.sim == null or ui.sim.state.game_over:
			break
		FrameLog.phase = "turn%d" % i
		await t.get_tree().process_frame
		var k0 := fl.times.size()
		var before: int = ui.sim.state.turn
		FrameLog.mark("END TURN pressed")
		ui.hud.last_shift = false
		ui.end_turn(true)
		var t4 := Time.get_ticks_msec() + 4000
		var ang := 0.0
		while Time.get_ticks_msec() < t4 or _busy(game):
			await t.get_tree().process_frame
			ang += 0.01
			game.set_camera(hp.x + sin(ang) * 0.6, hp.y + cos(ang) * 0.4, 2.4, true)
			if Time.get_ticks_msec() > t4 + 20000:
				break
		var mx := 0.0
		var what := ""
		var tot := 0.0
		for j in range(k0, fl.times.size()):
			tot += fl.times[j]
			if fl.times[j] > mx:
				mx = fl.times[j]
				what = str(fl.notes[j])
		hitches.append(mx)
		say.call("PERF turn %d (%d -> %d): hitch %.1f ms  [%s]" % [i + 1, before, ui.sim.state.turn, mx, what])
		for s in fl.spikes(50.0, "turn%d" % i).slice(1, 6):
			say.call("PERF     then %.1f ms  %s" % [s[0], s[2]])
	hitches.sort()
	var all_turn := PackedFloat32Array()
	for i in fl.times.size():
		if str(fl.phases[i]).begins_with("turn"):
			all_turn.append(fl.times[i])
	say.call("PERF turn-ends %d: hitch max %.1f ms, median %.1f ms; turn frames %s" % [hitches.size(), hitches.back() if hitches.size() > 0 else 0.0,
		hitches[hitches.size() / 2] if hitches.size() > 0 else 0.0, FrameLog.fmt(FrameLog.stats(all_turn))])
	say.call("PERF all: %s" % FrameLog.fmt(FrameLog.stats(fl.times)))
	say.call("PERF mode %s tier %s render %s headless %s" % ["HD+" if Quality.is_hdplus() else ("HD" if Quality.is_hd() else "SD " + Quality.level),
		_tier(), str(game.get_viewport().get_texture().get_size()), str(DisplayServer.get_name() == "headless")])
	var fa := FileAccess.open(t.dir + "/perf.txt", FileAccess.WRITE)
	if fa:
		fa.store_string("\n".join(lines) + "\n")
	t._finish()


static func _wait_map(t: UITest, game: Node) -> void:
	for i in 2000:
		if not _busy(game) and not game.get("_dirty"):
			return
		await t.get_tree().process_frame


static func _busy(game: Node) -> bool:
	return game.renderer.has_method("busy") and game.renderer.call("busy")


static func _tier() -> String:
	## (works on the code before perf60 too: the stutter report's "before" run)
	var s: Script = load("res://scripts/map/gfx_tier.gd") if ResourceLoader.exists("res://scripts/map/gfx_tier.gd") else null
	return str(s.get("active")) if s != null and str(s.get("active")) != "" else "-"
