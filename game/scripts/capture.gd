extends Node
## Test/critic harness. Command-line user args (after `--`):
##   --shot=<abs path.png>   save a screenshot then quit
##   --frames=<n>            frames to wait before the shot (default 90)
##   --turns=<n>             auto-end n turns first (if the game exposes end_turn on group "game")
##   --cam=<x,z,zoom>        optional camera override (if the game exposes set_camera on group "game")
##   --no-hud                hide every 2D layer (HUD, panels, banners) so critics judge the 3D world alone
## The game's UI harness (scripts/ui/game_ui.gd, "the capture harness for critics") runs first and the shot waits for
## it: --ui-click=x,y (repeatable, in order; --ui-click-delay=s), --ui-hover=x,y, --ui-save=<path.json> (saves after the
## clicks; continue from it with --ui-load=<path.json>), --ui-open=<panel>, --ui-start --ui-open=new_game.
## Windowed captures stop after godot.sh's limit (240 s): keep a run to about 30 clicks, or set GODOT_LIMIT.
var _shot := ""
var _no_hud := false
var _frames := 90
var _turns := 0
var _cam := ""

func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--shot="): _shot = a.substr(7)
		elif a.begins_with("--frames="): _frames = int(a.substr(9))
		elif a.begins_with("--turns="): _turns = int(a.substr(8))
		elif a.begins_with("--cam="): _cam = a.substr(6)
		elif a == "--no-hud": _no_hud = true
		elif a.begins_with("--cine="):   # trailer capture: scripts/cinematic.gd plays a shot plan (record with --write-movie)
			var c = load("res://scripts/cinematic.gd").new()
			c.setup(a.substr(7))
			add_child(c)
	if _shot != "":
		_run.call_deferred()

func _run() -> void:
	await get_tree().process_frame
	var game := get_tree().get_first_node_in_group("game")
	if game:
		if _cam != "" and game.has_method("set_camera"):
			var p := _cam.split(",")
			game.set_camera(float(p[0]), float(p[1]), float(p[2]) if p.size() > 2 else 1.0)
		for i in _turns:
			if game.has_method("end_turn"):
				game.end_turn()
				await get_tree().process_frame
	# v4polish: the UI harness (--ui-click, --ui-hover, --ui-save, --ui-open=new_game; GameUI) runs to its end before the
	# shot, however long its clicks take; then the --frames wait (at least 20 frames after the last click)
	var waited := 0
	var harness := false
	while bool(get_tree().root.get_meta("ui_harness_busy", false)) and waited < 30000:
		harness = true
		await get_tree().process_frame
		waited += 1
	if harness:
		print("CAPTURE the UI harness finished after %d frames" % waited)
	for i in maxi(_frames - waited, 20 if harness else 0):
		await get_tree().process_frame
	if _no_hud:
		_hide_2d(get_tree().root)
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png(_shot)
	print("CAPTURED ", _shot)
	get_tree().quit()


func _hide_2d(n: Node) -> void:
	for c in n.get_children():
		if c is CanvasLayer:
			c.visible = false
		elif c is CanvasItem and not c is Node3D:
			c.visible = false
		else:
			_hide_2d(c)
