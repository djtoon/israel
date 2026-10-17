extends SceneTree
## Prints path-ledger term lines (raw and formatted) from the end-state save.
func _initialize() -> void:
	var sim := Sim.new()
	if not sim.load_game("user://end_state.json"):
		print("PROBE no save"); quit(); return
	for e in sim.get_path_ledger():
		for t in e.get("terms", []):
			var f := UITheme.turn_spans(str(t))
			if f != str(t) or str(t).find("-") >= 0:
				print("PROBE RAW ", str(t).substr(0, 140))
				print("PROBE FMT ", f.substr(0, 140))
	quit()
