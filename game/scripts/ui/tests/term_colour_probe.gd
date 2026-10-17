extends SceneTree
## Prints every ledger / stream term with the polarity the shared helper (UITheme.clean_terms) assigns.
func _initialize() -> void:
	var sim := Sim.new()
	if not sim.load_game("user://end_state.json"):
		print("PROBE no save"); quit(); return
	var seen := {}
	for e in sim.get_path_ledger():
		for t in e.get("terms", []):
			_p(str(t), seen)
	if sim.has_method("get_streams"):
		for s in sim.get_streams():
			_p(str(s.get("text", s.get("label", ""))), seen)
	quit()

func _p(t: String, seen: Dictionary) -> void:
	if t == "" or seen.has(t): return
	seen[t] = true
	var f := UITheme.clean_terms(t)
	var tag := "GREEN" if f.find("#9fe07a") >= 0 else ""
	if f.find("#ff8f7a") >= 0: tag += "RED"
	print("PROBE [%s] %s" % [tag, t.substr(0, 150)])
