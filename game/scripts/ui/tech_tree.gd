class_name TechTreeWindow
extends UIWindow
## Full-screen technology / civics tree (Civ VI TechTree): era bands, nodes placed by the year history reached
## them, prerequisite lines, progress, boost state. Drag to pan, wheel to zoom, click a node to research it
## (a locked node starts the first available step on its path).

var kind := "tech"
var canvas: TreeCanvas
var info: RichTextLabel
var kind_btn: Button


func _init() -> void:
	super._init("Technology Tree")
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 8)
	body.add_child(bar)
	kind_btn = UITheme.button("Show civics tree", func(): show_tree("civic" if kind == "tech" else "tech"), 15)
	bar.add_child(kind_btn)
	bar.add_child(UITheme.button("List view", func(): close(); ui.open_panel("research" if kind == "tech" else "civic"), 15))
	var hint := UITheme.label("Drag to pan, mouse wheel to zoom. Click a node to research it; a locked node starts the first step on its path. Right-click: Civilopedia.", 15, UIKit.TEXT_DIM)
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(hint)
	canvas = TreeCanvas.new()
	canvas.win = self
	canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	canvas.custom_minimum_size = Vector2(0, 400)
	body.add_child(canvas)
	info = UITheme.rich("", 16)
	info.fit_content = false
	info.custom_minimum_size = Vector2(0, 92)
	info.scroll_active = true
	info.meta_clicked.connect(func(m): ui.on_pedia_meta(m))
	body.add_child(info)


func show_tree(k: String) -> void:
	kind = k
	title_label.text = "TECHNOLOGY TREE" if k == "tech" else "CIVICS TREE"
	kind_btn.text = "Show civics tree" if k == "tech" else "Show technology tree"
	visible = true
	refresh()


func refresh() -> void:
	canvas.build(kind)
	show_info(canvas.cur_id if canvas.cur_id != "" else "")


func show_info(id: String) -> void:
	var n: Dictionary = canvas.by_id.get(id, {})
	if n.is_empty():
		info.text = UITheme.pal("[color=#a8b0c4]Hover a node for details.[/color]")
		return
	var t: Dictionary = n["d"]
	var s := "[b][color=#f7dc8f]%s[/color][/b]   " % t["name"]
	if t["done"]:
		s += "[color=#9fe07a]Done[/color]"
	elif t["available"]:
		s += "%s  (cost %d)" % [UITheme.turns(int(canvas.turns_text(t))), int(t["cost"])]
	else:
		s += "[color=#ff8f7a]%s[/color]" % str(t.get("reason", ""))
	if t.get("year") != null:
		s += "   History: %d" % int(t["year"])
	var un: String = ui.unlock_links(t.get("unlocks", {}))
	if un != "":
		s += "\nUnlocks: " + un
	s += "   " + Civilopedia.link(kind, id, "Civilopedia entry")
	var bt := str(t.get("boost_text", ""))
	if t.get("boosted", false):
		s += "\n[color=#9fe07a]Boosted[/color]"
	elif bt != "" and bt != "Arrives with history.":
		s += "\n[color=#b3d1ff]To boost: %s[/color]" % bt
	var desc := str(t.get("description", ""))
	if desc == "":
		desc = str((ui.db().techs if kind == "tech" else ui.db().civics).get(id, {}).get("description", ""))
	if desc != "":
		s += "\n[i]%s[/i]" % desc
	var src: Array = t.get("source", [])
	if src.size() > 0:
		s += "  [color=#8a93a8][%s][/color]" % ", ".join(src)
	info.text = UITheme.pal(s)


func clicked(id: String) -> void:
	var n: Dictionary = canvas.by_id.get(id, {})
	if n.is_empty():
		return
	var t: Dictionary = n["d"]
	if t["done"]:
		return
	if t["available"]:
		ui.choose_research(kind, id)
		canvas.build(kind)
		return
	# Civ VI: clicking a distant node starts its path -> research the first available prerequisite
	var step := _first_step(id, {})
	if step != "":
		ui.choose_research(kind, step)
		ui.show_toast("Researching %s, on the path to %s." % [ui.item_name(kind, step), t["name"]])
		canvas.build(kind)
	else:
		ui.show_toast("%s: %s" % [t["name"], str(t.get("reason", "not available yet"))])


func _first_step(id: String, seen: Dictionary) -> String:
	if seen.has(id):
		return ""
	seen[id] = true
	var n: Dictionary = canvas.by_id.get(id, {})
	if n.is_empty():
		return ""
	var t: Dictionary = n["d"]
	if t["done"]:
		return ""
	if t["available"]:
		return id
	var best := ""
	var best_cost := 1e12
	for p in t.get("prereqs", []):
		var s := _first_step(str(p), seen)
		if s != "":
			var c := float(canvas.by_id[s]["d"]["cost"])
			if c < best_cost:
				best = s; best_cost = c
	return best


class TreeCanvas extends Control:
	const NW := 232.0
	const NH := 74.0
	const COL_W := 262.0
	const ROW_H := 84.0
	const TOP := 50.0
	const UNLOCK_ICON := {"districts": ["unlock_district", "cities"], "buildings": ["unlock_building", "production"], "units": ["unlock_unit", "diplomacy"],
		"improvements": ["unlock_improvement", "food"], "policies": ["unlock_policy", "civics_columns"], "projects": ["unlock_project", "star"]}
	var win
	var nodes: Array = []
	var by_id := {}
	var eras: Array = []
	var offset := Vector2(40, 10)
	var zoom := 1.0
	var hover := ""
	var cur_id := ""
	var rate := 1.0
	var maxrow := 0
	var _fit := true
	var _now_x := 0.0
	var _drag := false
	var _moved := false
	var _press := Vector2.ZERO

	func _init() -> void:
		clip_contents = true
		mouse_filter = Control.MOUSE_FILTER_STOP
		resized.connect(func(): _fit = true; queue_redraw())

	func turns_text(t: Dictionary) -> String:
		var rem := maxf(0.0, float(t["cost"]) - float(t["progress"]))
		var tt := rem / maxf(1.0, rate)
		return "%d" % int(ceil(tt))

	func build(k: String) -> void:
		var sim: Sim = win.ui.sim
		var items: Array = sim.get_techs() if k == "tech" else sim.get_civics()
		var nat := sim.get_national_summary()
		rate = maxf(1.0, float(nat.get("science" if k == "tech" else "culture", 1)))
		cur_id = str(nat.get("current_tech" if k == "tech" else "current_civic", ""))
		nodes.clear(); by_id.clear()
		var cols := {}
		# place by the year history reached it (3-year columns); items without a year go after their prerequisites
		var sorted := items.duplicate()
		sorted.sort_custom(func(a, b): return _yr(a) < _yr(b))
		maxrow = 0
		for t in sorted:
			var col := int(floor((_yr(t) - 1948.0) / 3.0))
			for p in t.get("prereqs", []):
				if by_id.has(p):
					col = maxi(col, int(by_id[p]["col"]) + 1)
			col = maxi(col, 0)
			var row := int(cols.get(col, 0))
			cols[col] = row + 1
			maxrow = maxi(maxrow, row)
			var n := {"id": t["id"], "d": t, "col": col, "row": row}
			nodes.append(n)
			by_id[t["id"]] = n
		eras = []
		var db: SimDB = win.ui.db()
		for e in db.eras:
			var y := float(str(e.get("start", "1948")).substr(0, 4))
			eras.append({"name": str(e.get("name", "")), "x": _col_x((y - 1948.0) / 3.0)})
		_now_x = _col_x((SimDB.year_f(sim.state.turn) - 1948.0) / 3.0)
		_fit = true
		queue_redraw()

	func _apply_fit() -> void:
		## Fill the window's height with the busiest column (Civ VI trees are dense), and start on the present.
		_fit = false
		if size.y < 50:
			_fit = true
			return
		var h := TOP + (maxrow + 1) * ROW_H + 16.0
		zoom = clampf(size.y / h, 0.55, 1.3)
		offset = Vector2(clampf(-(_now_x - COL_W) * zoom, -1e6, 30.0), 0.0)

	static func _yr(t: Dictionary) -> float:
		return float(t["year"]) if t.get("year") != null else 2030.0

	func _col_x(c: float) -> float:
		return 20.0 + c * COL_W

	func _node_rect(n: Dictionary) -> Rect2:
		return Rect2(_col_x(float(n["col"])), TOP + float(n["row"]) * ROW_H, NW, NH)

	func _to_world(p: Vector2) -> Vector2:
		return (p - offset) / zoom

	func _hit(p: Vector2) -> String:
		var w := _to_world(p)
		for n in nodes:
			if _node_rect(n).has_point(w):
				return str(n["id"])
		return ""

	func _gui_input(e: InputEvent) -> void:
		if e is InputEventMouseButton:
			if e.button_index == MOUSE_BUTTON_WHEEL_UP or e.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				if e.pressed:
					var before := _to_world(e.position)
					zoom = clampf(zoom * (1.12 if e.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0 / 1.12), 0.35, 1.6)
					offset = e.position - before * zoom
					queue_redraw()
				accept_event()
			elif e.button_index == MOUSE_BUTTON_LEFT:
				if e.pressed:
					_drag = true; _moved = false; _press = e.position
				else:
					_drag = false
					if not _moved:
						var id := _hit(e.position)
						if id != "":
							win.clicked(id)
				accept_event()
			elif e.button_index == MOUSE_BUTTON_RIGHT and e.pressed:
				var rid := _hit(e.position)
				if rid != "":
					win.ui.open_pedia(win.kind, rid)   # right-click: the Civilopedia entry (Civ VI)
				accept_event()
		elif e is InputEventMouseMotion:
			if _drag and (e.position.distance_to(_press) > 5 or _moved):
				_moved = true
				offset += e.relative
				queue_redraw()
			var h := _hit(e.position)
			if h != hover:
				hover = h
				win.show_info(h if h != "" else cur_id)
				queue_redraw()

	func _draw() -> void:
		if _fit:
			_apply_fit()
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.04, 0.09, 0.96))
		draw_set_transform(offset, 0.0, Vector2(zoom, zoom))
		var hgt := maxf(TOP + (maxrow + 1) * ROW_H + 20, size.y / maxf(zoom, 0.01))
		for i in eras.size():
			var x0: float = eras[i]["x"] - 15
			var x1: float = (eras[i + 1]["x"] - 15) if i + 1 < eras.size() else x0 + 2400
			draw_rect(Rect2(x0, 0, x1 - x0, hgt), Color(0.07, 0.11, 0.21, 0.55) if i % 2 == 0 else Color(0.04, 0.07, 0.15, 0.55))
			draw_line(Vector2(x0, 0), Vector2(x0, hgt), Color(UIKit.GOLD_DARK, 0.8), 1.5)
			draw_string(UIKit.font("title"), Vector2(x0 + 10, 28), L10n.t(str(eras[i]["name"])).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, x1 - x0 - 20, 15, UIKit.GOLD_LIGHT)
		# "now" marker
		draw_line(Vector2(_now_x - 8, 36), Vector2(_now_x - 8, hgt), Color(1.0, 0.85, 0.35, 0.35), 2.0)
		draw_string(UIKit.font("body_bold"), Vector2(_now_x - 4, 46), L10n.t("NOW"), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1.0, 0.85, 0.35, 0.8))
		for n in nodes:
			var r := _node_rect(n)
			for p in n["d"].get("prereqs", []):
				if not by_id.has(p):
					continue
				var pr := _node_rect(by_id[p])
				var a := Vector2(pr.end.x, pr.get_center().y)
				var b := Vector2(r.position.x, r.get_center().y)
				var mx := (a.x + b.x) * 0.5
				var done: bool = by_id[p]["d"]["done"]
				var col := Color(UIKit.GOLD, 0.85) if done else Color(0.45, 0.50, 0.62, 0.8)
				draw_polyline(PackedVector2Array([a, Vector2(mx, a.y), Vector2(mx, b.y), b]), col, 2.0, true)
		for n in nodes:
			_draw_node(n)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	func _icon(names: Array) -> Texture2D:
		for nm in names:
			var t := UIKit.icon(str(nm))
			if t:
				return t
		return null

	func _draw_node(n: Dictionary) -> void:
		var t: Dictionary = n["d"]
		var r := _node_rect(n)
		var id := str(n["id"])
		var tech: bool = win.kind == "tech"
		var bg := Color(0.09, 0.10, 0.14)
		var br := Color(0.30, 0.31, 0.36)
		var tc := UIKit.TEXT_DIM
		if t["done"]:
			bg = Color(0.20, 0.16, 0.08); br = UIKit.GOLD; tc = UIKit.GOLD_LIGHT
		elif id == cur_id:
			bg = Color(0.16, 0.32, 0.65); br = UIKit.GOLD_LIGHT; tc = Color.WHITE
		elif t["available"]:
			bg = Color(0.08, 0.16, 0.34); br = Color(0.45, 0.62, 0.95); tc = UIKit.TEXT
		if id == hover:
			br = Color.WHITE
		var pts := UIKit.rrect_points(r, 7.0)
		draw_colored_polygon(pts, bg)
		var pl := pts.duplicate(); pl.append(pts[0])
		draw_polyline(pl, br, 2.0 if id == cur_id or id == hover else 1.2, true)
		# medallion with a progress ring (Civ VI)
		var c := r.position + Vector2(30, NH * 0.5)
		draw_circle(c, 23, Color(0.02, 0.05, 0.12))
		draw_arc(c, 23, 0, TAU, 32, UIKit.GOLD if t["done"] else Color(0.5, 0.52, 0.6), 1.6, true)
		var fr := 1.0 if t["done"] else clampf(float(t["progress"]) / maxf(1.0, float(t["cost"])), 0, 1)
		if fr > 0:
			draw_arc(c, 20, -PI / 2, -PI / 2 + TAU * fr, 32, UIKit.BLUE if tech else UIKit.PURPLE, 3.0, true)
		var ic := _icon(["science"] if tech else ["culture"])
		if ic:
			draw_texture_rect(ic, Rect2(c - Vector2(15, 15), Vector2(30, 30)), false, Color(1, 1, 1, 1.0 if t["available"] or t["done"] else 0.55))
		var x0 := r.position.x + 60
		var w := NW - 66
		var f := UIKit.font("body_bold")
		var right := ""
		if t["done"]:
			right = "Done"
		elif t["available"]:
			right = UITheme.turns(int(turns_text(t)))
		var nfs := 15
		var tname := L10n.t(str(t["name"]))
		while nfs > 12 and UIKit.text_width(tname, "body_bold", nfs) > w:
			nfs -= 1
		draw_string(f, Vector2(x0, r.position.y + 19), tname, HORIZONTAL_ALIGNMENT_LEFT, w, nfs, tc)
		if t.get("year") != null:
			right += ("  ·  " if right != "" else "") + str(int(t["year"]))
		right = L10n.t(right)
		var rw := UIKit.text_width(right, "body_bold", 12) if right != "" else 0.0
		if right != "":
			draw_string(f, Vector2(r.end.x - 6 - rw, r.position.y + 41), right, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, UIKit.GOLD_LIGHT if t["done"] else Color(0.95, 0.92, 0.85))
		# unlock icons (Civ VI shows what a node unlocks as a row of icons)
		var ix := x0
		var un: Dictionary = t.get("unlocks", {})
		for k in un:
			if typeof(un[k]) != TYPE_ARRAY:
				continue
			var tex := _icon(UNLOCK_ICON.get(k, ["star"]))
			for _i in (un[k] as Array).size():
				if ix > r.end.x - rw - 34:
					break
				draw_circle(Vector2(ix + 10, r.position.y + 36), 11, Color(0.02, 0.05, 0.12, 0.9))
				if tex:
					draw_texture_rect(tex, Rect2(Vector2(ix + 1, r.position.y + 27), Vector2(18, 18)), false)
				ix += 23
		# bottom line: the boost condition, or why it is locked
		var line := ""
		var lc := Color(0.70, 0.82, 1.0)
		var bt := str(t.get("boost_text", ""))
		var boost := false
		if t["done"]:
			line = ""
		elif t.get("rail", false):
			line = "Arrives with history"; lc = Color(0.65, 0.70, 0.80)
		elif not t["available"]:
			line = str(t.get("reason", "")); lc = Color(0.95, 0.6, 0.5)
		elif t.get("boosted", false):
			line = "Boosted"; lc = UIKit.GREEN
		elif bt != "" and bt != "Arrives with history.":
			line = bt; boost = true
		line = L10n.t(line)
		if line != "":
			if boost:
				var bi := _icon(["boost", "research"])
				if bi:
					draw_texture_rect(bi, Rect2(Vector2(x0 - 2, r.position.y + 52), Vector2(15, 15)), false)
				draw_string(UIKit.font("body"), Vector2(x0 + 15, r.position.y + 64), line, HORIZONTAL_ALIGNMENT_LEFT, w - 17, 12, lc)
			else:
				draw_string(UIKit.font("body"), Vector2(x0, r.position.y + 64), line, HORIZONTAL_ALIGNMENT_LEFT, w, 12, lc)
