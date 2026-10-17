extends SceneTree
func _initialize() -> void:
	var sim := Sim.new()
	if not sim.load_game("user://end_state.json"):
		print("PROBE no save"); quit(); return
	var l := sim.get_path_ledger()
	for e in l.slice(0, 3):
		print("PROBE ", JSON.stringify(e).substr(0, 600))
	print("PROBE final ", JSON.stringify(sim.score.final_summary()).substr(0, 500))
	quit()
