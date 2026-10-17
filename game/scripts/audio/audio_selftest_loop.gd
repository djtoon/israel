extends SceneTree
## Windowed: seek era music near its loop point and watch the A/B rotation crossfade.
func _initialize() -> void:
	await process_frame
	await process_frame
	var ad = root.get_node("AudioDirector")
	ad.set_era(1)
	await create_timer(16.0).timeout
	var p = ad._mus[ad._mus_i]
	p.seek(p.stream.get_length() - 5.0)
	print("TEST seek to loop end, len=", p.stream.get_length(), " loop=", p.stream.loop)
	await create_timer(7.0).timeout
	quit()
