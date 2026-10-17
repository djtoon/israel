extends Node
## Trailer capture director (started by capture.gd with --cine=<abs path to plan.json>; record with Godot's
## Movie Maker: --write-movie <out.avi> --fixed-fps 30). The plan drives the real game: camera keyframes
## (x, z, zoom, yaw, eased between keys), optional --no-hud, starting or fast-forwarding a game, ending turns,
## and a time-lapse that advances the years while the camera moves, with a small year caption.
## Plan: {"duration": s, "no_hud": bool, "ff": turn, "keys": [{"t","x","z","zoom","yaw"}...],
##        "timelapse": {"t0", "t1", "from", "to"}, "actions": [{"t", "do": "end_turn"|"start"}], "year_label": bool}
## Or "flight": {...} instead of "keys" for a free low-level camera flight (see _build_flight).

var plan := {}
var game
var ui
var t := 0.0
var _acted := {}
var _year_lbl: Label
var _tl_turn := -1
var _ended := false
var _fl := {}            # flight mode: sampled spline (see _build_flight)
var _fl_look := Vector3.INF
var _fl_last := 0.0
var _fl_g := -1.0e9       # smoothed ground clearance height


func setup(path: String) -> void:
	var j = JSON.parse_string(FileAccess.get_file_as_string(path))
	plan = j if j is Dictionary else {}


func _ready() -> void:
	set_process(false)
	_begin.call_deferred()


func _begin() -> void:
	for i in 3:
		await get_tree().process_frame
	game = get_tree().get_first_node_in_group("game")
	ui = game.game_ui if game and "game_ui" in game else null
	var ff := int(plan.get("ff", 0))
	for a in OS.get_cmdline_user_args():   # segment recording: --cine-load=<save.json> --cine-t0=s --cine-t1=s
		if a.begins_with("--cine-load="):
			plan["load"] = a.substr(12)
		elif a.begins_with("--cine-t0="):
			plan["t0"] = float(a.substr(10))
		elif a.begins_with("--cine-t1="):
			plan["t1"] = float(a.substr(10))
	if ui:
		if plan.has("load"):   # a saved game instead of fast-forwarding (much quicker; every segment starts identical)
			ui.quick_load(str(plan["load"]))
		elif ff > 1:
			ui.fast_forward(ff)
		elif plan.get("start", true):
			ui.start_new_game(false, false)
	for i in 20:
		await get_tree().process_frame
	if plan.get("no_hud", false):
		_hide_2d(get_tree().root)
	if plan.get("year_label", false):
		var layer := CanvasLayer.new()
		layer.layer = 120
		add_child(layer)
		_year_lbl = Label.new()
		_year_lbl.add_theme_font_override("font", load("res://assets/fonts/Cinzel.ttf"))
		_year_lbl.add_theme_font_size_override("font_size", 84)
		_year_lbl.add_theme_color_override("font_color", Color(1.0, 0.93, 0.75))
		_year_lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
		_year_lbl.add_theme_constant_override("shadow_offset_x", 3)
		_year_lbl.add_theme_constant_override("shadow_offset_y", 3)
		_year_lbl.add_theme_constant_override("shadow_outline_size", 10)
		_year_lbl.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
		_year_lbl.offset_left = -420; _year_lbl.offset_top = 60; _year_lbl.offset_right = -70
		_year_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		layer.add_child(_year_lbl)
	# a segment starting at t0 replays the camera's smoothing from 0 so it joins the previous segment exactly
	var t0 := float(plan.get("t0", 0.0))
	var pre := 0.0
	while pre < t0 - 1e-6:
		_apply_cam(pre)
		pre += 1.0 / 30.0
	t = t0
	_apply_cam(t)
	_apply_dn(t)
	# feature clips: "pre" actions set the scene up (open a panel, click) before the recording starts
	for a in plan.get("pre", []):
		await _do_action(a)
		for i in int(a.get("wait", 2)):
			_apply_cam(t)
			await get_tree().process_frame
	# hold the first view while the map streams in its detailed models, so a segment never opens on a pop
	for i in int(plan.get("warm_frames", 0)):
		_apply_cam(t)
		await get_tree().process_frame
	print("CINE START at frame %d" % Engine.get_frames_drawn())   # trim the recording from here
	print("CINE window %s, viewport %s" % [str(DisplayServer.window_get_size()), str(get_viewport().get_visible_rect().size)])
	set_process(true)


func _process(dt: float) -> void:
	if _ended:
		return
	t += dt
	_apply_cam(t)
	for i in (plan.get("actions", []) as Array).size():
		var a: Dictionary = plan["actions"][i]
		if not _acted.has(i) and t >= float(a.get("t", 0)):
			_acted[i] = true
			_do_action(a)
	_apply_dn(t)
	var tl: Dictionary = plan.get("timelapse", {})
	if not tl.is_empty() and ui and ui.sim:
		var p := clampf((t - float(tl["t0"])) / (float(tl["t1"]) - float(tl["t0"])), 0.0, 1.0)
		var want := int(round(lerpf(float(tl["from"]), float(tl["to"]), p)))
		var stp := int(tl.get("step", 4))   # "step": turns per jump (short clips: fewer, larger jumps, so the map redraws between them)
		want = int(want / stp) * stp + int(tl["from"]) % stp   # whole years
		if p >= 1.0:
			want = int(tl["to"])
		if want > ui.sim.state.turn and want != _tl_turn:
			_tl_turn = want
			ui.fast_forward(want)
			if plan.get("no_hud", false):
				_hide_2d(get_tree().root)
	if _year_lbl and ui and ui.sim:
		_year_lbl.text = ui.sim.date_label().right(4)
	if t >= float(plan.get("t1", plan.get("duration", 8.0))):
		_ended = true
		print("CINE DONE at %.2f s, turn %d" % [t, ui.sim.state.turn if ui and ui.sim else 0])
		get_tree().quit()


## Plan actions ("actions" at time t, or "pre" before the recording starts; "wait": frames after a "pre" action):
##   "end_turn"; feature clips (none run unless a plan asks): "open" {"panel"} (GameUI.open_panel), "click" {"x","y"}
##   (a real click at window pixels), "hover" {"x","y"}, "call" {"method","args"[,"target"]} (a GameUI method, or one
##   on the GameUI member "target"), "new_game" (the title screen's New Game panel), "time" {"hour"} (DayNight),
##   "hide_toast". Plan "daynight": {"t0","t1","from","to"} sweeps the clock (hours) across the shot.
func _do_action(a: Dictionary) -> void:
	if ui == null:
		return
	match str(a.get("do", "")):
		"end_turn":
			ui.end_turn(true)
		"open":
			ui.open_panel(str(a.get("panel", "")))
		"click":   # x, y in the recorded frame's pixels (the viewport); events go in window pixels
			if a.has("rx"):   # release elsewhere ("rx", "ry"): when the press rebuilds the window, the release can't fall on the map
				await _click_moved(Vector2(float(a["x"]), float(a["y"])) * _win_scale(), Vector2(float(a["rx"]), float(a["ry"])) * _win_scale())
			else:
				await ui._sim_click(Vector2(float(a["x"]), float(a["y"])) * _win_scale())
		"hover":
			var mm := InputEventMouseMotion.new()
			mm.position = Vector2(float(a["x"]), float(a["y"])) * _win_scale()
			mm.global_position = mm.position
			get_viewport().warp_mouse(mm.position)
			Input.parse_input_event(mm)
		"wheel":   # "n" mouse-wheel steps at x, y ("up": true scrolls up), one every other frame
			var wp := Vector2(float(a["x"]), float(a["y"])) * _win_scale()
			for k in int(a.get("n", 3)):
				for pressed in [true, false]:
					var we := InputEventMouseButton.new()
					we.button_index = MOUSE_BUTTON_WHEEL_UP if a.get("up", false) else MOUSE_BUTTON_WHEEL_DOWN
					we.pressed = pressed
					we.factor = 1.0
					we.position = wp
					we.global_position = wp
					Input.parse_input_event(we)
				await get_tree().process_frame
				await get_tree().process_frame
		"call":
			var obj = ui
			for part in (str(a["target"]).split(".") if a.has("target") else []):   # "tutorial.card": a member of a member
				obj = obj.get(part) if obj != null else null
			if obj != null and obj.has_method(str(a.get("method", ""))):
				obj.callv(str(a["method"]), a.get("args", []))
			else:
				push_warning("cinematic: no method %s" % str(a.get("method", "")))
		"new_game":
			var ss = ui.start_screen
			if ss != null and is_instance_valid(ss):
				ss._show_menu_now()
				if not ss.setup_panel.visible:
					ss._ask_mode()
		"time":
			DayNight.set_time(str(a.get("hour", "noon")))
		"hide_toast":
			if ui.toast != null:
				ui.toast.visible = false


func _click_moved(p: Vector2, rp: Vector2) -> void:
	for step in [[p, true], [rp, false]]:
		var pos: Vector2 = step[0]
		get_viewport().warp_mouse(pos)
		var mm := InputEventMouseMotion.new()
		mm.position = pos
		mm.global_position = pos
		mm.button_mask = 0 if step[1] else MOUSE_BUTTON_MASK_LEFT
		Input.parse_input_event(mm)
		await get_tree().process_frame
		await get_tree().process_frame
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT
		e.pressed = step[1]
		e.button_mask = MOUSE_BUTTON_MASK_LEFT if step[1] else 0
		e.position = pos
		e.global_position = pos
		Input.parse_input_event(e)
		await get_tree().process_frame


func _win_scale() -> Vector2:
	var vs := get_viewport().get_visible_rect().size
	return Vector2(DisplayServer.window_get_size()) / vs if vs.x > 0 and vs.y > 0 else Vector2.ONE


func _apply_dn(tt: float) -> void:
	var dn: Dictionary = plan.get("daynight", {})
	if dn.is_empty():
		return
	var t0 := float(dn.get("t0", 0.0))
	var q := clampf((tt - t0) / maxf(0.001, float(dn.get("t1", 5.0)) - t0), 0.0, 1.0)
	DayNight.set_time(str(lerpf(float(dn["from"]), float(dn["to"]), q)))


func _apply_cam(tt: float) -> void:
	if plan.has("flight"):
		_apply_flight(tt)
		return
	var keys: Array = plan.get("keys", [])
	if keys.is_empty() or game == null or not ("rig" in game) or game.rig == null:
		return
	var a: Dictionary = keys[0]
	var b: Dictionary = keys[0]
	for i in keys.size() - 1:
		if tt >= float(keys[i]["t"]):
			a = keys[i]; b = keys[i + 1]
	if tt >= float(keys[keys.size() - 1]["t"]):
		a = keys[keys.size() - 1]; b = a
	var span := maxf(0.001, float(b["t"]) - float(a["t"]))
	var u := clampf((tt - float(a["t"])) / span, 0.0, 1.0)
	u = u * u * (3.0 - 2.0 * u)   # smoothstep between keys
	var rig = game.rig
	rig.yaw_deg = lerpf(float(a.get("yaw", -40)), float(b.get("yaw", -40)), u)
	game.set_camera(lerpf(float(a["x"]), float(b["x"]), u), lerpf(float(a["z"]), float(b["z"]), u),
		lerpf(float(a["zoom"]), float(b["zoom"]), u), true)


## Flight mode: plan "flight": {"points": [{"x","z","v","alt"}...], "look": 7, "look_h": 0.3, "ease": 0.5}.
## A free camera flies a Catmull-Rom spline through the points at "alt" units above the terrain (interpolated),
## looking "look" units ahead along the path (then at "target": {"x","z"} past its end). "v" weights the speed near each point (lower = slower); the
## whole flight is stretched to fit "duration", easing in and out. The rig is frozen and the camera set directly.
func _build_flight() -> void:
	var fp: Dictionary = plan["flight"]
	var wp: Array = fp.get("points", [])
	var P: Array = []; var V: Array = []; var A: Array = []
	for w in wp:
		P.append(Vector2(float(w["x"]), float(w["z"])))
		V.append(maxf(0.05, float(w.get("v", 1.0))))
		A.append(float(w.get("alt", 1.5)))
	var pos := PackedVector2Array(); var alt := PackedFloat32Array(); var vel := PackedFloat32Array()
	var n := P.size()
	const SUB := 48
	for i in n - 1:
		var p0: Vector2 = P[maxi(i - 1, 0)]; var p1: Vector2 = P[i]; var p2: Vector2 = P[i + 1]; var p3: Vector2 = P[mini(i + 2, n - 1)]
		for k in SUB:
			var u := float(k) / SUB
			var u2 := u * u; var u3 := u2 * u
			pos.append(0.5 * (2.0 * p1 + (p2 - p0) * u + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * u2 + (3.0 * p1 - p0 - 3.0 * p2 + p3) * u3))
			var su := u * u * (3.0 - 2.0 * u)
			alt.append(lerpf(A[i], A[i + 1], su)); vel.append(lerpf(V[i], V[i + 1], su))
	pos.append(P[n - 1]); alt.append(A[n - 1]); vel.append(V[n - 1])
	var s := PackedFloat32Array([0.0]); var tau := PackedFloat32Array([0.0])
	for i in range(1, pos.size()):
		var ds := pos[i].distance_to(pos[i - 1])
		s.append(s[i - 1] + ds)
		tau.append(tau[i - 1] + ds / (0.5 * (vel[i] + vel[i - 1])))
	_fl = {"pos": pos, "alt": alt, "s": s, "tau": tau}
	if game and "rig" in game and game.rig:
		game.rig.set_process(false)


func _fl_find(arr: PackedFloat32Array, v: float) -> Vector2:
	## index i and fraction f with arr[i] <= v <= arr[i+1]
	var i := clampi(arr.bsearch(v) - 1, 0, arr.size() - 2)
	var span := maxf(1e-6, arr[i + 1] - arr[i])
	return Vector2(i, clampf((v - arr[i]) / span, 0.0, 1.0))


func _fl_ground(x: float, z: float) -> float:
	var rig = game.rig
	if rig.height_fn.is_valid():
		return maxf(0.0, rig.height_fn.call(x, z)) * 0.5 + 0.1
	return 0.15


func _apply_flight(tt: float) -> void:
	if game == null or not ("rig" in game) or game.rig == null or game.rig.cam == null:
		return
	if _fl.is_empty():
		_build_flight()
	var fp: Dictionary = plan["flight"]
	if not fp.get("labels", false):   # area labels (Label3D) would float on the horizon at this height
		for n in get_tree().get_nodes_in_group("map_area_label"):
			n.remove_from_group("map_area_label")
			(n as Node3D).visible = false
	var pos: PackedVector2Array = _fl["pos"]; var alt: PackedFloat32Array = _fl["alt"]
	var s: PackedFloat32Array = _fl["s"]; var tau: PackedFloat32Array = _fl["tau"]
	var u := clampf(tt / float(plan.get("duration", 25.0)), 0.0, 1.0)
	u = lerpf(u, u * u * (3.0 - 2.0 * u), float(fp.get("ease", 0.5)))
	var at := _fl_find(tau, u * tau[tau.size() - 1])
	var i := int(at.x)
	var p := pos[i].lerp(pos[i + 1], at.y)
	var a := lerpf(alt[i], alt[i + 1], at.y)
	var s_now := lerpf(s[i], s[i + 1], at.y)
	var look_d := float(fp.get("look", 7.0))
	var la := _fl_find(s, minf(s_now + look_d, s[s.size() - 1]))
	var lp := pos[int(la.x)].lerp(pos[int(la.x) + 1], la.y)
	if fp.has("target"):   # past the end of the path the gaze moves on to the final target
		var excess := s_now + look_d - s[s.size() - 1]
		if excess > 0.0:
			lp = lp.lerp(Vector2(float(fp["target"]["x"]), float(fp["target"]["z"])), clampf(excess / look_d, 0.0, 1.0))
	# clearance: the highest ground under the camera and just ahead of it
	var g := _fl_ground(p.x, p.y)
	var fwd := (lp - p).normalized() if lp.distance_to(p) > 0.01 else Vector2.ZERO
	for d in [0.5, 1.0, 2.0, 3.0, 4.5, 6.0]:
		var q: Vector2 = p + fwd * d
		g = maxf(g, _fl_ground(q.x, q.y) - 0.12 * d)
	var dt := maxf(0.0, tt - _fl_last)
	_fl_last = tt
	# rise quickly for terrain ahead, sink slowly after it, so the height never steps
	_fl_g = g if _fl_g < -1.0e8 else lerpf(_fl_g, g, 1.0 - exp(-dt * (5.0 if g > _fl_g else 1.2)))
	var cam_pos := Vector3(p.x, maxf(_fl_g, _fl_ground(p.x, p.y) + 0.3) + a, p.y)
	var look := Vector3(lp.x, _fl_ground(lp.x, lp.y) + float(fp.get("look_h", 0.3)), lp.y)
	_fl_look = look if _fl_look == Vector3.INF else _fl_look.lerp(look, 1.0 - exp(-dt * 3.0))
	# keep the map's level of detail and streaming centred on where we look
	game.set_camera(_fl_look.x, _fl_look.z, clampf(11.0 / maxf(1.0, a * 2.2), 0.6, 3.0), true)
	var cam: Camera3D = game.rig.cam
	cam.global_position = cam_pos
	if cam_pos.distance_to(_fl_look) > 0.01:
		cam.look_at(_fl_look, Vector3.UP)


func _hide_2d(n: Node) -> void:
	for c in n.get_children():
		if c == self or c.get_parent() == self:
			continue
		if c is CanvasLayer:
			if c.get_parent() != self:
				c.visible = false
		elif c is CanvasItem and not c is Node3D:
			c.visible = false
		else:
			_hide_2d(c)
