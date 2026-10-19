class_name WebSaves
extends RefCounted
## Web build only (OS.has_feature("web")): saves live in this browser (user:// is IndexedDB), so the Save / Load window
## offers Export (download one save as a file) and Import (pick a file: it becomes a save slot here).
## The file is one JSON: {"format": "ibn_save_1", "name", "meta", "save": <the save's JSON text>, "ui": <its UI sidecar>}.
## A plain save .json from the desktop game (user://saves/<name>.json) imports too.

const FORMAT := "ibn_save_1"
static var _cb = null     # (JavaScriptObject) the JS callback the file picker calls (kept alive here)
static var _done: Callable


static func available() -> bool:
	return OS.has_feature("web")


static func pack(path: String) -> String:
	## the export file's text for the save at path ("" if it cannot be read)
	if not FileAccess.file_exists(path):
		return ""
	var m := SaveSlots.read_meta(path)
	m.erase("path")
	var d := {"format": FORMAT, "game": "Israel", "name": str(m.get("name", "Save")), "meta": m,
		"save": FileAccess.get_file_as_string(path)}
	var up := SaveSlots.ui_path(path)
	if FileAccess.file_exists(up):
		d["ui"] = FileAccess.get_file_as_string(up)
	return JSON.stringify(d)


static func export_save(path: String) -> String:
	## downloads the save as <name>.ibnsave.json; returns the file name ("" on failure)
	var text := pack(path)
	if text == "" or not available():
		return ""
	var m := SaveSlots.read_meta(path)
	var fn := "%s.ibnsave.json" % SaveSlots.slug(str(m.get("name", "save")))
	JavaScriptBridge.download_buffer(text.to_utf8_buffer(), fn, "application/json")
	return fn


static func pick_file(done: Callable) -> void:
	## opens the browser's file picker; done(result: Dictionary) gets install()'s result once a file is read
	if not available():
		return
	_done = done
	if _cb == null:
		_cb = JavaScriptBridge.create_callback(_on_file)
	JavaScriptBridge.eval("""window.ibnPickSave = function (cb) {
		const i = document.createElement('input');
		i.type = 'file'; i.accept = '.json,application/json'; i.style.display = 'none';
		document.body.appendChild(i);
		i.addEventListener('change', function () {
			const f = i.files && i.files[0];
			i.remove();
			if (!f) { return; }
			f.text().then(function (t) { cb(f.name, t); }, function () { cb(f.name, ''); });
		});
		i.click();
	};""", true)
	var win = JavaScriptBridge.get_interface("window")
	win.ibnPickSave(_cb)


static func _on_file(args: Array) -> void:
	var r := install(str(args[0]) if args.size() > 0 else "save.json", str(args[1]) if args.size() > 1 else "")
	if _done.is_valid():
		_done.call(r)


static func install(file_name: String, text: String) -> Dictionary:
	## writes an exported save (or a plain save .json) as a new slot; {ok, path, name, error}
	var j = JSON.parse_string(text)
	if typeof(j) != TYPE_DICTIONARY:
		return {"ok": false, "error": "That file is not a saved game."}
	var name := file_name.get_file().trim_suffix(".json").trim_suffix(".ibnsave").replace("_", " ")
	var save_text := text
	var meta := {}
	var ui_text := ""
	if str(j.get("format", "")) == FORMAT:
		name = str(j.get("name", name))
		save_text = str(j.get("save", ""))
		meta = j.get("meta", {}) if typeof(j.get("meta", {})) == TYPE_DICTIONARY else {}
		ui_text = str(j.get("ui", ""))
	var s = JSON.parse_string(save_text)
	if typeof(s) != TYPE_DICTIONARY or not (s.has("turn") or s.has("cities")):
		return {"ok": false, "error": "That file is not a saved game."}
	var base := SaveSlots.dir() + SaveSlots.slug(name)
	var path := base + ".json"
	var k := 2
	while FileAccess.file_exists(path):
		path = "%s_%d.json" % [base, k]
		k += 1
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return {"ok": false, "error": "The save could not be written in this browser."}
	f.store_string(save_text)
	f.close()
	meta["name"] = name
	meta["kind"] = "manual"
	if not meta.has("saved_unix"):
		meta["saved_unix"] = Time.get_unix_time_from_system()
	if not meta.has("turn"):
		meta["turn"] = int(s.get("turn", -1))
	var mf := FileAccess.open(SaveSlots.meta_path(path), FileAccess.WRITE)
	if mf:
		mf.store_string(JSON.stringify(meta))
		mf.close()
	if ui_text != "":
		var uf := FileAccess.open(SaveSlots.ui_path(path), FileAccess.WRITE)
		if uf:
			uf.store_string(ui_text)
			uf.close()
	return {"ok": true, "path": path, "name": name}
