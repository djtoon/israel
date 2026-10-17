extends SceneTree
## Windowed transition self-test:  godot.sh --path game --windowed --script res://scripts/audio/audio_selftest.gd
## Prints the AudioDirector log for opening hold, war, ceasefire, treaty, peace, era change, end and the stingers.

func _initialize() -> void:
	await process_frame
	await process_frame
	var ad = root.get_node("AudioDirector")
	ad.set_era(1)
	ad.set_ambience("coast")
	await create_timer(2.0).timeout
	print("TEST war at game start (should be held)")
	ad.set_situation("war")
	ad.play_sting("war")
	await create_timer(1.0).timeout
	ad._opening_until = Time.get_ticks_msec()
	await create_timer(2.0).timeout
	print("TEST ceasefire")
	ad._ceasefire_msec = Time.get_ticks_msec()
	ad.set_situation("peace")
	ad.play_sting("peace")
	await create_timer(5.0).timeout
	print("TEST treaty")
	ad.set_situation("treaty")
	ad.play_sting("peace_treaty")
	await create_timer(4.0).timeout
	print("TEST era change / research / election / ambience")
	ad.set_era(2)
	ad.play_sting("era")
	ad.play_sfx("research_done")
	ad.play_sting("election")
	ad.play_sting("government")
	ad.set_ambience("city")
	await create_timer(4.0).timeout
	print("TEST end")
	ad.set_situation("end")
	ad.play_sting("game_end")
	await create_timer(4.0).timeout
	quit()
