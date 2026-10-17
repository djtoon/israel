class_name SaveWindow
extends UIWindow
## Save / Load window: named slots (date, turn and era shown), autosaves and the quick-save, with Delete.
## Opens from the game menu, the start screen ("Load game") and Ctrl+S / Ctrl+L.

var mode := "save"     # save | load
var name_edit: LineEdit
var save_btn: Button
var _confirm := ""     # path awaiting a second click (overwrite / delete)
var _name := ""        # the typed slot name (kept across refreshes)


func _init() -> void:
	super._init("Save game")


func open(m: String) -> void:
	mode = m
	_confirm = ""
	_name = ""
	visible = true
	refresh()


func refresh() -> void:
	clear_body()
	title_label.text = "SAVE GAME" if mode == "save" else "LOAD GAME"
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 4)
	body.add_child(tabs)
	for t in [["save", "Save"], ["load", "Load"]]:
		var k: String = t[0]
		var b := UITheme.button(t[1], func(): mode = k; _confirm = ""; refresh(), 16)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.disabled = k == "save" and (ui == null or ui.sim == null)
		if mode == k:
			b.add_theme_stylebox_override("normal", UITheme.sb(Color(0.18, 0.34, 0.66), UIKit.GOLD_LIGHT, 2, 5, 8))
		tabs.add_child(b)
	if mode == "save":
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 8)
		body.add_child(h)
		name_edit = LineEdit.new()
		name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_edit.text = _name if _name != "" else L10n.plain("Israel %s" % ui.sim.date_label() if ui and ui.sim else "Israel")   # the default name in the player's language
		name_edit.text_changed.connect(func(t): _name = t)
		name_edit.placeholder_text = "Name this save"
		name_edit.max_length = 48
		name_edit.add_theme_font_size_override("font_size", 18)
		name_edit.add_theme_stylebox_override("normal", UITheme.sb(Color(0.02, 0.05, 0.11, 0.95), UIKit.GOLD_DARK, 1, 5, 8))
		name_edit.text_submitted.connect(func(_t): _save_clicked())
		h.add_child(name_edit)
		save_btn = UITheme.button("Save", _save_clicked, 18)
		save_btn.custom_minimum_size = Vector2(120, 0)
		h.add_child(save_btn)
		var path := SaveSlots.dir() + SaveSlots.slug(name_edit.text) + ".json"
		if _confirm != "" and _confirm == path:
			body.add_child(UITheme.label("A save with this name exists: press Save again to overwrite it.", 15, Color(1.0, 0.75, 0.35)))
		body.add_child(UITheme.label("Autosave every %d turns (the last %d are kept). F5 quick-saves, F9 quick-loads." % [SaveSlots.AUTOSAVE_EVERY, SaveSlots.AUTOSAVE_KEEP], 14, UIKit.TEXT_DIM))
	var list := scroll_body(420)
	var all := SaveSlots.list_all()
	if all.is_empty():
		list.add_child(UITheme.label("No saves yet.", 17, UIKit.TEXT_DIM))
	for m in all:
		list.add_child(_row(m))


func _row(m: Dictionary) -> UIRow:
	var path := str(m["path"])
	var kind := str(m.get("kind", "manual"))
	var r := UIRow.new(true)
	var h := r.hrow()
	var badge: String = {"auto": "AUTOSAVE", "quick": "QUICK-SAVE"}.get(kind, "SAVE")
	var bl := UITheme.label(badge, 12, Color(0.80, 0.86, 1.0) if kind != "manual" else UIKit.GOLD, "title")
	bl.custom_minimum_size = Vector2(96, 0)
	h.add_child(bl)
	var nm := UITheme.label(L10n.mark_verbatim(str(m.get("name", path.get_file()))) if kind == "manual" else str(m.get("name", path.get_file())), 18, UIKit.GOLD_LIGHT, "body_bold")   # the player's own name for the save
	nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nm.clip_text = true
	h.add_child(nm)
	if mode == "load":
		var lb := UITheme.button("Load", func(): ui.load_slot(path), 15)
		h.add_child(lb)
	else:
		var ob := UITheme.button("Overwrite" if _confirm != path else "Confirm", func(): _overwrite(m), 15)
		ob.disabled = kind != "manual"
		ob.tooltip_text = "Save the current game into this slot" if kind == "manual" else "Autosaves and the quick-save are written automatically"
		h.add_child(ob)
	var del_path := "del:" + path
	var db := UITheme.button("Delete" if _confirm != del_path else "Really delete?", func(): _delete(path), 15)
	h.add_child(db)
	var sub := SaveSlots.describe(m)
	var wt := SaveSlots.when(m)
	r.add(UITheme.label("%s%s%s" % [sub, "    " if sub != "" and wt != "" else "", wt], 14, UIKit.TEXT_DIM))
	if mode == "load":
		r.pressed.connect(func(_s): ui.load_slot(path))
	else:
		r.pressed.connect(func(_s):
			if kind == "manual" and name_edit:
				_name = str(m.get("name", ""))
				name_edit.text = _name)
	return r


func _save_clicked() -> void:
	if ui == null or ui.sim == null:
		return
	var nm := name_edit.text.strip_edges()
	if nm == "":
		nm = L10n.plain("Israel %s" % ui.sim.date_label())
	var path := SaveSlots.dir() + SaveSlots.slug(nm) + ".json"
	if FileAccess.file_exists(path) and _confirm != path:
		_confirm = path
		_name = nm
		refresh()
		return
	_confirm = ""
	if ui.save_slot(path, nm):
		refresh()


func _overwrite(m: Dictionary) -> void:
	var path := str(m["path"])
	if _confirm != path:
		_confirm = path
		refresh()
		return
	_confirm = ""
	if ui.save_slot(path, str(m.get("name", "Save"))):
		refresh()


func _delete(path: String) -> void:
	if _confirm != "del:" + path:
		_confirm = "del:" + path
		refresh()
		return
	_confirm = ""
	SaveSlots.delete(path)
	ui.show_toast("Save deleted.")
	refresh()
	if ui.start_screen:
		ui.start_screen.refresh_continue()
