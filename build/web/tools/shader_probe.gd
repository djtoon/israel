extends SceneTree
## temporary (build/web only): time the first draw of each custom shader on this renderer
## godot --path build/web/src/game --rendering-driver opengl3_angle --script res://shader_probe.gd -- terrain building ...

func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var names := OS.get_cmdline_user_args()
	if names.is_empty():
		names = PackedStringArray(["water", "artinst", "artmodel", "diorama", "foliage", "props", "veg_shadow", "building", "terrain"])
	var cam := Camera3D.new()
	root.add_child(cam)
	cam.position = Vector3(0, 2, 4)
	cam.look_at(Vector3.ZERO)
	var sun := DirectionalLight3D.new()
	sun.shadow_enabled = true
	root.add_child(sun)
	sun.rotation_degrees = Vector3(-40, 30, 0)
	for f in 3:
		await process_frame
	for n in names:
		var sh := load("res://scripts/map/%s.gdshader" % n) as Shader
		var mi := MeshInstance3D.new()
		var pm := PlaneMesh.new()
		pm.size = Vector2(2, 2)
		mi.mesh = pm
		var m := ShaderMaterial.new()
		m.shader = sh
		mi.material_override = m
		root.add_child(mi)
		var t0 := Time.get_ticks_msec()
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		print("PROBE %s first draws %d ms" % [n, Time.get_ticks_msec() - t0])
		mi.queue_free()
		await process_frame
	quit()
