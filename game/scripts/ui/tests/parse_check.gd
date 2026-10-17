extends SceneTree
## Loads every UI script and prints parse errors (headless; quits by itself).
func _init() -> void:
	for f in DirAccess.get_files_at("res://scripts/ui"):
		if f.ends_with(".gd"):
			var s = load("res://scripts/ui/" + f)
			print("PARSE ", f, " ", "ok" if s != null and s.can_instantiate() else "FAILED")
	quit()
