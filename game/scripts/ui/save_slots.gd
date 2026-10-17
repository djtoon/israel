class_name SaveSlots
extends RefCounted
## Named save slots, autosaves and the quick-save, each with a small sidecar `<save>_meta.json`
## ({name, kind, turn, label, era_name, saved_unix}) so lists never parse a full save.
##   manual saves  user://saves/<slug>.json
##   autosaves     user://saves/autosave_t<turn>.json   every AUTOSAVE_EVERY turns, the newest AUTOSAVE_KEEP kept
##   quick-save    user://quicksave.json                F5 / F9
## UI test runs (--ui-test=...) use user://saves_test/ so they never touch the player's slots.

const AUTOSAVE_EVERY := 4
const AUTOSAVE_KEEP := 3


static func dir() -> String:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--ui-test"):
			return "user://saves_test/"
	return "user://saves/"


static func slug(name: String) -> String:
	var s := ""
	for ch in name.strip_edges():
		if ch.is_valid_identifier() or ch.is_valid_int() or ch in ["-", "_"]:
			s += ch
		elif ch == " ":
			s += "_"
	s = s.substr(0, 48)
	return s if s != "" else "save"


static func meta_path(path: String) -> String:
	return path.trim_suffix(".json") + "_meta.json"


static func ui_path(path: String) -> String:
	return path.trim_suffix(".json") + "_ui.json"


static func write(path: String, sim: Sim, ui_state: Dictionary, name: String, kind: String) -> bool:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	if not sim.save_game(path):
		return false
	var d := sim.get_date()
	var meta := {"name": name, "kind": kind, "turn": int(d.get("turn", sim.state.turn)), "label": str(d.get("label", "")),
		"era_name": str(d.get("era_name", "")), "saved_unix": Time.get_unix_time_from_system(), "game_over": bool(sim.state.game_over)}
	var f := FileAccess.open(meta_path(path), FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(meta))
		f.close()
	var u := FileAccess.open(ui_path(path), FileAccess.WRITE)
	if u:
		u.store_string(JSON.stringify(ui_state))
		u.close()
	return true


static func read_meta(path: String) -> Dictionary:
	var mp := meta_path(path)
	var m := {}
	if FileAccess.file_exists(mp):
		var j = JSON.parse_string(FileAccess.get_file_as_string(mp))
		if typeof(j) == TYPE_DICTIONARY:
			m = j
	if m.is_empty():
		# an older save without a sidecar: name it from the file, date it by its modification time
		m = {"name": path.get_file().trim_suffix(".json").replace("_", " ").capitalize(), "kind": "manual", "turn": -1, "label": "", "era_name": "",
			"saved_unix": float(FileAccess.get_modified_time(path))}
	m["path"] = path
	if path == GameUI.quick_path():
		m["kind"] = "quick"
		m["name"] = "Quick-save"
	return m


static func list_all(include_quick := true) -> Array:
	## Every save, newest first.
	var out := []
	var d := dir()
	if DirAccess.dir_exists_absolute(d):
		for fn in DirAccess.get_files_at(d):
			if fn.ends_with(".json") and not fn.ends_with("_meta.json") and not fn.ends_with("_ui.json"):
				out.append(read_meta(d + fn))
	if include_quick and FileAccess.file_exists(GameUI.quick_path()):
		out.append(read_meta(GameUI.quick_path()))
	out.sort_custom(func(a, b): return float(a.get("saved_unix", 0)) > float(b.get("saved_unix", 0)))
	return out


static func newest() -> Dictionary:
	var l := list_all()
	return l[0] if l.size() > 0 else {}


static func delete(path: String) -> void:
	for p in [path, meta_path(path), ui_path(path)]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)


static func autosave_due(turn: int) -> bool:
	return turn > 1 and (turn - 1) % AUTOSAVE_EVERY == 0


static func autosave(sim: Sim, ui_state: Dictionary) -> String:
	## Writes autosave_t<turn>.json and prunes autosaves beyond the newest AUTOSAVE_KEEP. Returns the path ("" on failure).
	var path := dir() + "autosave_t%03d.json" % sim.state.turn
	if not write(path, sim, ui_state, "Autosave", "auto"):
		return ""
	var autos := list_all(false).filter(func(m): return str(m.get("kind", "")) == "auto")
	autos.sort_custom(func(a, b): return int(a.get("turn", 0)) > int(b.get("turn", 0)))
	for i in range(AUTOSAVE_KEEP, autos.size()):
		delete(str(autos[i]["path"]))
	return path


static func describe(m: Dictionary) -> String:
	## "Q3 1951 · turn 14 · Statehood Consolidation"
	var parts := []
	if str(m.get("label", "")) != "": parts.append(str(m["label"]))
	if int(m.get("turn", -1)) > 0: parts.append("turn %d" % int(m["turn"]))
	if str(m.get("era_name", "")) != "": parts.append(str(m["era_name"]))
	if bool(m.get("game_over", false)): parts.append("finished")
	return "  ·  ".join(parts)


static func when(m: Dictionary) -> String:
	var t := float(m.get("saved_unix", 0))
	if t <= 0:
		return ""
	var bias := int(Time.get_time_zone_from_system().get("bias", 0)) * 60
	var dt := Time.get_datetime_dict_from_unix_time(int(t) + bias)
	const M := ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
	return "saved %d %s %d, %02d:%02d" % [int(dt["day"]), M[int(dt["month"])], int(dt["year"]), int(dt["hour"]), int(dt["minute"])]
