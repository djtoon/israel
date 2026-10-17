extends SceneTree
## Dev tool: renders the GLBs of one model dir side by side, each normalised to a 1-unit box.
## godot --path game --script res://scripts/map/_preview_models.gd -- <dir> <out.png>
func _init() -> void:
	await process_frame
	var args := OS.get_cmdline_user_args()
	var root := Node3D.new(); get_root().add_child(root)
	var dir := DirAccess.open("res://assets/models/" + args[0])
	var i := 0
	for f in dir.get_files():
		if not f.ends_with(".glb"): continue
		var n: Node3D = (load("res://assets/models/%s/%s" % [args[0], f]) as PackedScene).instantiate()
		var a: Dictionary = CityBuilder.manifest().get(f.get_basename(), {})
		var rm = a.get("real_m")
		var s := 1.0 / maxf(float(rm["w"]), float(rm["h"])) if typeof(rm) == TYPE_DICTIONARY else 1.0
		n.scale = Vector3.ONE * s
		n.position = Vector3((i % 5) * 1.3, 0, (i / 5) * 1.4)
		root.add_child(n); i += 1
	var cam := Camera3D.new(); root.add_child(cam)
	cam.look_at_from_position(Vector3(2.6, 2.4, 4.2), Vector3(2.6, 0.3, 0.7)); cam.fov = 55
	var l := DirectionalLight3D.new(); l.rotation_degrees = Vector3(-45, -40, 0); root.add_child(l)
	var we := WorldEnvironment.new(); we.environment = Environment.new(); we.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR; we.environment.ambient_light_color = Color(0.6,0.6,0.7); we.environment.background_mode = Environment.BG_COLOR; we.environment.background_color = Color(0.3,0.35,0.4); root.add_child(we)
	for k in 30: await process_frame
	await RenderingServer.frame_post_draw
	get_root().get_texture().get_image().save_png(args[1])
	quit()
