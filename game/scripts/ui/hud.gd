class_name HUD
extends Control
## Navy-and-gold HUD laid out on a 1672x941 reference canvas (scaled by the window stretch).
## Values are placeholders until the sim piece wires real data in via `state`.

signal next_turn_pressed
signal action_pressed(id: String)
var top_drawn := -1   # the frame the top bar was last drawn (ui_test checks it in both play styles)
signal minimap_clicked(world: Vector2)
signal panel_pressed(id: String)   # research | civic | city | ghost | help | menu | settings (sim-driven UI)

## Live mode (scripts/ui/game_ui.gd): `live` overrides `state` at draw time and placeholders are ignored.
var live_mode := false
var live := {}
var _S := {}

var state := {
	"gold": 1280, "gold_rate": 42, "science": 86, "culture": 54, "food": 38, "happiness": 82,
	"turn": 1, "date": "Q2 1948", "era": "Modern Era",
	"research": {"name": "Desalination", "turns": 4, "progress": 0.68, "icon": "water_drops"},
	"civic": {"name": "Cultural Heritage", "turns": 6, "progress": 0.45, "icon": "civics_columns"},
	"city": {"name": "Tel Aviv-Yafo", "population": 18, "production": 64, "food": "+38", "housing": 22,
		"building": "Solar Plant", "building_turns": 3, "building_progress": 0.55},
}

var map: MapData
var minimap_tex: Texture2D
var minimap_view: PackedVector2Array = PackedVector2Array()   # world-space ground quad
var _mm_world := Rect2()
var _hover := ""
var last_shift := false
var _hit := {}
var _tip_rects: Array = []     # top-bar item rects (ref units), matched to live["top_tips"] for tooltips
var _tip_kinds: Array = []     # the kind of each top-bar item ("gold", "economy", "danger"...): a click emits panel_pressed("top:<kind>")
var era_drawn: Array = []      # the era name as last drawn in the top bar: one line, or two when it is long (tests)
var labels_drawn: Array = []   # story mode: the words drawn beside the top-bar numbers, as last drawn (tests)
# v4polish (new-player H_treasury): the top bar's tooltips are a panel of the UI layer, opened just under the bar and
# kept on screen, instead of the engine tooltip (which ran off the top of the screen, under the bar)
var tip_host: PanelContainer   # set by GameUI (in its window layer); null = the engine tooltip
var tip_label: Label
var tip_index := -1            # the top-bar item whose panel is open (-1 = none) (tests)
# short era names for a crowded top bar (data/techs.json eras)
const ERA_SHORT := {"Independence and Mass Immigration": "Mass Immigration", "After the Six-Day War": "After 1967",
	"Political Change and Stabilization": "Political Change", "Immigration from the Former USSR and the Oslo Process": "Aliyah and Oslo",
	"High-Tech Growth and the Second Intifada": "High-Tech and Intifada", "Gas, Desalination and Cyber": "Gas and Cyber",
	"The Late 2010s and 2020s": "The 2010s and 2020s"}


static func _two_lines(s: String) -> Array:
	## Splits a name at the word boundary that best balances its two halves.
	var words := s.split(" ", false)
	var best := 1
	var bd := 1 << 30
	for i in range(1, words.size()):
		var a := " ".join(words.slice(0, i))
		var b := " ".join(words.slice(i))
		var d := absi(a.length() - b.length())
		if d < bd:
			bd = d
			best = i
	return [" ".join(words.slice(0, best)), " ".join(words.slice(best))]

const R_TOP := Rect2(0, 0, 1672, 47)
const R_RESEARCH := Rect2(10, 63, 298, 76)
const R_CIVIC := Rect2(10, 148, 298, 76)
const R_CITY := Rect2(10, 662, 380, 250)
const R_MINIMAP := Rect2(1423, 673, 239, 180)
const R_GHOST := Rect2(10, 232, 298, 36)
const R_GHOST_HEALTH := Rect2(10, 271, 298, 24)   # under the chip, only while the state's health is below 100%
const LEFT_HITS := ["research", "civic", "city", "ghost"]
const RIGHT_HITS := ["next", "minimap", "pedia", "help", "menu", "settings"]
const R_MMTOOLS := Rect2(1388, 733, 30, 94)
const R_NEXT := Rect2(1424, 861, 238, 51)
const ACTIONS := [["cities", "Cities", "cities"], ["research", "Research", "research"], ["culture", "Culture", "culture_masks"],
	["diplomacy", "Diplomacy", "diplomacy"], ["trade", "Trade", "trade"]]
const ACTION_X := [649.0, 741.0, 833.0, 924.0, 1021.0]
const ACTION_Y := 862.0
## v4 story mode (game_ui sets it through set_story): only the unlocked parts are drawn and clickable; the decision
## button, the action circles and the left cards are replaced by GameUI's NextStep, GoalsCard and action bar.
## Full control: story_mode false, the v3 HUD exactly (the v3 hit regions are restored).
var story_mode := false
var story_show := {}                # "ghost" | "research" | "civic" | "city" | "minimap" -> true
var story_keys: Array = ["menu"]    # the top-right buttons shown in story mode (from: pedia, help, menu, settings)
const STORY_GHOST := Rect2(1364, 56, 298, 36)      # right-anchored in story mode (the left column holds the goals)
const STORY_RESEARCH := Rect2(1364, 126, 298, 76)
const STORY_CIVIC := Rect2(1364, 210, 298, 76)
const TOP_KEYS := ["pedia", "help", "menu", "settings"]
var _v3_hit := {}


func set_story(on: bool, parts := {}, keys := ["menu"]) -> void:
	story_mode = on
	story_show = parts.duplicate()
	story_keys = TOP_KEYS.filter(func(k): return k in keys)
	if _v3_hit.is_empty():
		_v3_hit = _hit.duplicate()
	if not on:
		_hit = _v3_hit.duplicate()
		queue_redraw()
		return
	_hit = {}
	for k in story_keys:
		_hit[k] = Rect2(_btn_cx(k) - 15, 8, 30, 30)
	if story_show.has("ghost"): _hit["ghost"] = STORY_GHOST
	if story_show.has("research"): _hit["research"] = STORY_RESEARCH
	if story_show.has("civic"): _hit["civic"] = STORY_CIVIC
	if story_show.has("city"): _hit["city"] = R_CITY
	if story_show.has("minimap"): _hit["minimap"] = R_MINIMAP
	queue_redraw()


func _btn_cx(k: String) -> float:
	## x (ref units, before right-anchoring) of a top-right button's centre.
	if not story_mode:
		return 1512.0 + 44.0 * TOP_KEYS.find(k)
	var i := story_keys.find(k)
	return 1644.0 - 44.0 * (story_keys.size() - 1 - i)


func _era_right() -> float:
	var first: String = TOP_KEYS[0] if not story_mode or story_keys.is_empty() else str(story_keys[0])
	return _btn_cx(first) - 36.0


func _ghost_r() -> Rect2:
	if story_mode:
		return Rect2(Vector2(_xr(STORY_GHOST.position.x), STORY_GHOST.position.y), STORY_GHOST.size)
	return R_GHOST


func _ghost_health_r() -> Rect2:
	var r := _ghost_r()
	return Rect2(r.position + Vector2(0, 39), Vector2(r.size.x, 24))


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	resized.connect(queue_redraw)
	for i in ACTIONS.size():
		_hit["act_" + ACTIONS[i][0]] = Rect2(ACTION_X[i] - 38, ACTION_Y - 38, 76, 90)   # own keys: "research" is also the left card
	_hit["next"] = R_NEXT
	_hit["minimap"] = R_MINIMAP
	_hit["research"] = R_RESEARCH
	_hit["civic"] = R_CIVIC
	_hit["city"] = R_CITY
	_hit["ghost"] = R_GHOST
	_hit["pedia"] = Rect2(1512 - 15, 8, 30, 30)
	_hit["help"] = Rect2(1556 - 15, 8, 30, 30)
	_hit["menu"] = Rect2(1600 - 15, 8, 30, 30)
	_hit["settings"] = Rect2(1644 - 15, 8, 30, 30)
	_v3_hit = _hit.duplicate()


func _ref_scale() -> float:
	return maxf(size.y, 1.0) / 941.0


func _ref_xf() -> Transform2D:
	# keep the 1672x941 layout, anchored left/right when the aspect differs
	var s := _ref_scale()
	return Transform2D(0.0, Vector2(s, s), 0.0, Vector2.ZERO)


func _to_ref(p: Vector2) -> Vector2:
	return p / _ref_scale()


func _xr(x: float) -> float:
	# x for right-anchored elements
	return x + (size.x / _ref_scale() - 1672.0)


func _xc(x: float) -> float:
	return x + (size.x / _ref_scale() - 1672.0) * 0.5


func _has_point(p: Vector2) -> bool:
	var q := _to_ref(p)
	for r in _regions():
		if r.has_point(q):
			return true
	return false


func _regions() -> Array:
	var dx := size.x / _ref_scale() - 1672.0
	if story_mode:
		var rs := [Rect2(0, 0, size.x / _ref_scale(), 47)]
		for k in ["ghost", "research", "civic", "city", "minimap"]:
			if _hit.has(k):
				rs.append(_hit_rect(k))
		if _hit.has("ghost") and float((live.get("ghost", {}) as Dictionary).get("health", 1.0)) < 0.995:
			rs.append(_ghost_health_r())
		if _hit.has("minimap"):
			rs.append(Rect2(R_MMTOOLS.position + Vector2(dx, 0), R_MMTOOLS.size))
		return rs
	return [Rect2(0, 0, size.x / _ref_scale(), 47), R_RESEARCH, R_CIVIC, R_CITY if not live.get("city", {"x": 1}).is_empty() else Rect2(), R_GHOST,
		R_GHOST_HEALTH if float((live.get("ghost", {}) as Dictionary).get("health", 1.0)) < 0.995 else Rect2(),
		Rect2(R_MINIMAP.position + Vector2(dx, 0), R_MINIMAP.size), Rect2(R_MMTOOLS.position + Vector2(dx, 0), R_MMTOOLS.size),
		Rect2(R_NEXT.position + Vector2(dx, 0), R_NEXT.size), Rect2(_xc(600), 815, 470, 110)]


func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_EXIT:
		show_top_tip(-1)


func top_tip_at(local: Vector2) -> int:
	## The top-bar item under a point (HUD local pixels), or -1.
	var q := _to_ref(local)
	for i in _tip_rects.size():
		if (_tip_rects[i] as Rect2).has_point(q):
			return i
	return -1


func show_top_tip(i: int) -> void:
	## Opens the top-bar item i's explanation under the bar (i = -1 closes it). The panel stays inside the screen.
	if tip_host == null or tip_label == null:
		return
	var tips: Array = live.get("top_tips", [])
	if i < 0 or i >= tips.size() or i >= _tip_rects.size() or str(tips[i]) == "":
		tip_host.visible = false
		tip_index = -1
		return
	tip_index = i
	tip_label.text = str(tips[i])
	tip_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	tip_label.custom_minimum_size = Vector2.ZERO
	tip_host.reset_size()
	if tip_label.get_combined_minimum_size().x > 640.0:
		tip_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		tip_label.custom_minimum_size = Vector2(640, 0)
	tip_host.reset_size()
	var par := tip_host.get_parent() as Control
	var r: Rect2 = _tip_rects[i]
	var xf := get_global_transform_with_canvas()
	var to_par: Transform2D = par.get_global_transform_with_canvas().affine_inverse() if par != null else Transform2D.IDENTITY
	var p0: Vector2 = to_par * (xf * (Vector2(r.position.x, 50.0) * _ref_scale()))
	var sz := tip_host.get_combined_minimum_size()
	var vw: float = par.size.x if par != null else size.x
	var vh: float = par.size.y if par != null else size.y
	p0.x = clampf(p0.x, 6.0, maxf(6.0, vw - sz.x - 6.0))
	p0.y = clampf(p0.y, 0.0, maxf(0.0, vh - sz.y))
	tip_host.position = p0
	tip_host.size = sz
	tip_host.visible = true
	tip_host.move_to_front()


func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseMotion:
		var q := _to_ref(e.position)
		if tip_host != null:
			var ti := top_tip_at(e.position)
			if ti != tip_index:
				show_top_tip(ti)
		var h := ""
		for k in _hit:
			if _hit_rect(k).has_point(q):
				h = k
		if h != _hover:
			_hover = h
			queue_redraw()
	elif e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		var q := _to_ref(e.position)
		last_shift = e.shift_pressed
		show_top_tip(-1)
		if story_mode:
			if _hit.has("minimap") and _hit_rect("minimap").has_point(q):
				var mr := _hit_rect("minimap")
				minimap_clicked.emit(_mm_world.position + (q - mr.position) / mr.size * _mm_world.size)
			else:
				for k in ["research", "civic", "city", "ghost", "pedia", "help", "menu", "settings"]:
					if _hit.has(k) and _hit_rect(k).has_point(q):
						panel_pressed.emit(k)
				for i in mini(_tip_rects.size(), _tip_kinds.size()):
					if (_tip_rects[i] as Rect2).has_point(q):
						panel_pressed.emit("top:" + str(_tip_kinds[i]))
			accept_event()
			return
		if _hit_rect("next").has_point(q):
			next_turn_pressed.emit()
		elif _hit_rect("minimap").has_point(q):
			var r := _hit_rect("minimap")
			var uv := (q - r.position) / r.size
			minimap_clicked.emit(_mm_world.position + uv * _mm_world.size)
		else:
			for a in ACTIONS:
				if _hit_rect("act_" + a[0]).has_point(q):
					action_pressed.emit(a[0])
			for k in LEFT_HITS + ["pedia", "help", "menu", "settings"]:
				if _hit_rect(k).has_point(q):
					panel_pressed.emit(k)
			for i in mini(_tip_rects.size(), _tip_kinds.size()):
				if (_tip_rects[i] as Rect2).has_point(q):
					panel_pressed.emit("top:" + str(_tip_kinds[i]))
		accept_event()


func _hit_rect(k: String) -> Rect2:
	var r: Rect2 = _hit[k]
	if story_mode and k in ["ghost", "research", "civic"]:
		return Rect2(Vector2(_xr(r.position.x), r.position.y), r.size)
	if k in LEFT_HITS:
		return r
	if k in RIGHT_HITS:
		return Rect2(Vector2(_xr(r.position.x), r.position.y), r.size)
	return Rect2(Vector2(_xc(r.position.x), r.position.y), r.size)


func set_placeholders(year: int, home: Dictionary) -> void:
	if live_mode:
		return
	## Neutral placeholders until the sim piece drives the HUD; nothing that claims a specific achievement
	## for the date. From 2010 on the values mirror the target frame (desalination and solar are real then).
	var late := year >= 2010
	state["research"] = {"name": "Desalination", "turns": 4, "progress": 0.68, "icon": "water_drops"} if late 		else {"name": "Choose a technology", "turns": 0, "progress": 0.0, "icon": "research"}
	state["civic"] = {"name": "Cultural Heritage", "turns": 6, "progress": 0.45, "icon": "civics_columns"} if late 		else {"name": "Choose a civic", "turns": 0, "progress": 0.0, "icon": "civics_columns"}
	var pop = home.get("display_pop", -1)
	state["city"] = {"name": home.get("name", "—"), "population": pop if int(pop) > 0 else "—",
		"production": "—", "food": "—", "housing": "—",
		"thumb": "res://assets/ui/thumb_telaviv.png" if late else "res://assets/ui/thumb_city_early.png",
		"building": "Solar Plant" if late else "Nothing", "building_turns": 3 if late else 0,
		"building_progress": 0.55 if late else 0.0, "building_thumb": "res://assets/ui/thumb_solar.png" if late else ""}
	if late:
		state["city"]["production"] = 64; state["city"]["food"] = "+38"; state["city"]["housing"] = 22
	queue_redraw()


func refresh() -> void:
	queue_redraw()


# ------------------------------------------------------------------ minimap

const MM_COL := {"ocean": Color(0.09, 0.26, 0.50), "coast": Color(0.16, 0.50, 0.70), "lake": Color(0.20, 0.52, 0.78),
	"grassland": Color(0.40, 0.58, 0.20), "plains": Color(0.66, 0.62, 0.30), "hills": Color(0.56, 0.52, 0.30),
	"mountains": Color(0.58, 0.52, 0.45), "desert": Color(0.90, 0.76, 0.48), "desert_hills": Color(0.78, 0.58, 0.40),
	"marsh": Color(0.30, 0.48, 0.32)}


const MM_VOID := Color(0.16, 0.17, 0.20)   # outside the map (unexplored), not sea
const MM_PPU := 2.5          # minimap pixels per world unit
const MM_WINDOW := 105.0     # world units shown across the minimap
var _mm_full := Rect2()      # world rect covered by minimap_tex


var _mm_task := -1             # perf60: WorkerThreadPool task drawing the minimap bitmap (-1 = none)
var _mm_img: Image
var _mm_again := false


func set_map(m: MapData, threaded := false) -> void:
	## the minimap bitmap (terrain, towns, borders). perf60: threaded (in play, on desktop) draws it on a worker thread
	## (about 0.25 s of per-pixel work that froze the turn-end frame) and swaps it in when done; the first draw and
	## loading screens draw at once.
	map = m
	var ws := m.world_size()
	_mm_full = Rect2(-2.0, -2.0, ws.x + 4.0, ws.y + 4.0)
	var W := int(_mm_full.size.x * MM_PPU); var H := int(_mm_full.size.y * MM_PPU)
	var own := m.owner_map()
	var tile_col := {}
	for t in m.tiles:
		var k := Vector2i(int(t["q"]), int(t["r"]))
		var c: Color = MM_COL.get(t.get("terrain", "ocean"), MM_COL["ocean"])
		if t.get("feature", "") == "forest":
			c = c.darkened(0.25)
		if m.urban.has(k):
			c = Color(0.88, 0.84, 0.76)
		tile_col[k] = c
	if threaded and minimap_tex != null and OS.get_name() != "Web":
		if _mm_task >= 0:
			_mm_again = true   # (a newer map arrives while one is drawing: draw again after it)
			return
		_mm_task = WorkerThreadPool.add_task(_mm_draw.bind(W, H, own.duplicate(), tile_col, _mm_full), false, "minimap")
		set_process(true)
		return
	_mm_draw(W, H, own, tile_col, _mm_full)
	minimap_tex = ImageTexture.create_from_image(_mm_img)
	_mm_img = null
	_set_window(ws * 0.5)


func minimap_pending() -> bool:
	return _mm_task >= 0


func _mm_draw(W: int, H: int, own: Dictionary, tile_col: Dictionary, full: Rect2) -> void:
	## pure: reads only its arguments and TerrainMath (thread-safe); leaves the bitmap in _mm_img
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	for y in H:
		for x in W:
			var wp := full.position + Vector2(x + 0.5, y + 0.5) / MM_PPU
			var k := TerrainMath.world_to_offset(wp)
			var c: Color = tile_col.get(k, MM_VOID)
			var cc := TerrainMath.offset_center(k.x, k.y)
			var dc := wp.distance_to(cc)
			c = c.darkened(0.10 * smoothstep(0.6, 0.95, dc) + 0.06 * TerrainMath.hash2(k.x, k.y))
			if own.has(k):
				if dc > 0.62:
					for nb in TerrainMath.offset_neighbors(k):
						if not own.has(nb) and wp.distance_to((TerrainMath.offset_center(nb.x, nb.y) + cc) * 0.5) < 0.6:
							c = Color(0.92, 0.96, 1.0)
			img.set_pixel(x, y, c)
	_mm_img = img


func _mm_poll() -> void:
	if _mm_task < 0 or not WorkerThreadPool.is_task_completed(_mm_task):
		return
	WorkerThreadPool.wait_for_task_completion(_mm_task)
	_mm_task = -1
	if _mm_img != null:
		minimap_tex = ImageTexture.create_from_image(_mm_img)
		_mm_img = null
		queue_redraw()
	if _mm_again and map != null:
		_mm_again = false
		set_map(map, true)


func _set_window(center: Vector2) -> void:
	var sz := Vector2(MM_WINDOW, MM_WINDOW * R_MINIMAP.size.y / R_MINIMAP.size.x)
	var pos := center - sz * 0.5
	pos.x = clampf(pos.x, _mm_full.position.x, maxf(_mm_full.position.x, _mm_full.end.x - sz.x))
	pos.y = clampf(pos.y, _mm_full.position.y, maxf(_mm_full.position.y, _mm_full.end.y - sz.y))
	_mm_world = Rect2(pos, sz)


func set_view_quad(world_pts: PackedVector2Array) -> void:
	minimap_view = world_pts
	if world_pts.size() == 4:
		var c := (world_pts[0] + world_pts[1] + world_pts[2] + world_pts[3]) * 0.25
		_set_window(c)
	queue_redraw()


# ------------------------------------------------------------------ drawing

func _draw() -> void:
	if size.y < 10:
		return
	_S = state.duplicate()
	_S.merge(live, true)
	draw_set_transform_matrix(_ref_xf())
	if story_mode:
		_draw_top()
		if story_show.has("ghost") and _S.has("ghost"):
			_draw_ghost_chip(_S["ghost"])
		if story_show.has("research"):
			_draw_card(_hit_rect("research"), "RESEARCH", _S["research"], UIKit.BLUE)
		if story_show.has("civic"):
			_draw_card(_hit_rect("civic"), "CIVICS", _S["civic"], UIKit.PURPLE)
		if story_show.has("city") and not _S.get("city", {}).is_empty():
			_draw_city()
		if story_show.has("minimap"):
			_draw_minimap()
		return
	_draw_top()   # Full control: the v3 HUD, top bar included (critic4-vet blocker)
	_draw_card(R_RESEARCH, "RESEARCH", _S["research"], UIKit.BLUE)
	_draw_card(R_CIVIC, "CIVICS", _S["civic"], UIKit.PURPLE)
	if _S.has("ghost"):
		_draw_ghost_chip(_S["ghost"])
	if not _S.get("city", {}).is_empty():
		_draw_city()
	_draw_actions()
	_draw_minimap()
	_draw_next()


func _draw_top() -> void:
	top_drawn = Engine.get_process_frames()
	var w := size.x / _ref_scale()
	var bar := PackedVector2Array([Vector2(0, 0), Vector2(w, 0), Vector2(w, 46), Vector2(0, 46)])
	UIKit.gradient_poly(self, bar, Color(0.06, 0.10, 0.20, 1.0), Color(0.02, 0.05, 0.12, 1.0), 0, 46)
	draw_line(Vector2(0, 46), Vector2(w, 46), UIKit.GOLD, 1.6)
	draw_line(Vector2(0, 48.5), Vector2(w, 48.5), Color(0, 0, 0, 0.35), 2.0)
	# logo block with a slanted gold edge
	var logo := PackedVector2Array([Vector2(0, 0), Vector2(252, 0), Vector2(234, 46), Vector2(0, 46)])
	UIKit.gradient_poly(self, logo, Color(0.03, 0.06, 0.14, 0.98), Color(0.01, 0.03, 0.08, 0.98), 0, 46)
	draw_line(Vector2(252, 0), Vector2(234, 46), UIKit.GOLD, 2.0, true)
	draw_line(Vector2(246, 0), Vector2(228, 46), Color(UIKit.GOLD_DARK, 0.7), 1.0, true)
	UIKit.star_of_david(self, Vector2(40, 26), 19, Color(0.93, 0.95, 1.0), 2.4)
	# the game's name, "Israel", centred in the slanted block (the star at its left)
	var nfs := 30
	while nfs > 16 and UIKit.text_width("ISRAEL", "title_wide", nfs) > 146.0:
		nfs -= 1
	UIKit.text(self, Vector2(78, 23.0 + nfs * 0.36), "ISRAEL", "title_wide", nfs, Color(0.96, 0.90, 0.74))
	# yields
	var x := 268.0
	var items := [["gold", "%s" % _thousands(_S["gold"]), "+%d" % _S["gold_rate"]],
		["science", "+%d" % _S["science"], ""], ["culture", "+%d" % _S["culture"], ""],
		["food", "+%d" % _S["food"], ""], ["happy", "%d%%" % _S["happiness"], ""]]
	if _S.has("top_items"):
		items = _S["top_items"]
	_tip_rects.clear()
	_tip_kinds.clear()
	# v4 fix round (new-player N5): story mode names each number ("Treasury 70 +0"), so no icon is a riddle
	var top_labels: Array = _S.get("top_labels", []) if story_mode else []
	labels_drawn = []
	for i in items.size():
		var it: Array = items[i]
		var x0 := x
		if str(it[0]) == "economy":
			_econ_glyph(Vector2(x + 13, 23), str(it[6]) if it.size() > 6 else "ok")
		elif str(it[0]) == "danger":
			_danger_glyph(Vector2(x + 13, 23))
		elif str(it[0]) == "readiness":
			_shield_glyph(Vector2(x + 13, 23))
		else:
			UIKit.icon_at(self, it[0], Vector2(x + 13, 23), 27)
		var tx := x + 32
		var c1: Color = it[3] if it.size() > 3 and it[3] is Color else UIKit.TEXT
		var c2: Color = it[4] if it.size() > 4 and it[4] is Color else UIKit.TEXT
		if i < top_labels.size() and str(top_labels[i]) != "":
			var lab := L10n.t(str(top_labels[i]))
			labels_drawn.append(lab)
			UIKit.text(self, Vector2(tx, 30), lab, "body", 15, Color(UIKit.GOLD_LIGHT, 0.85))
			tx += UIKit.text_width(lab, "body", 15) + 7
		UIKit.text(self, Vector2(tx, 31), it[1], "body", 21, c1)
		tx += UIKit.text_width(it[1], "body", 21) + 8
		if it[2] != "":
			var small: bool = it.size() > 5 and bool(it[5])
			UIKit.text(self, Vector2(tx, 31 if not small else 30), it[2], "body", 21 if not small else 17, c2)
			tx += UIKit.text_width(it[2], "body", 21 if not small else 17)
		x = maxf(tx + (24 if items.size() <= 7 and top_labels.is_empty() else 16), x + (96 if items.size() <= 7 else 80))   # a collapse item: tighter, so the era name keeps its room
		_tip_rects.append(Rect2(x0 - 4, 2, x - x0 - 8, 42))
		_tip_kinds.append(str(it[0]))
		if i < items.size() - 1:
			draw_line(Vector2(x - 13, 12), Vector2(x - 13, 36), Color(UIKit.GOLD_DARK, 0.9), 1.2)
	# right side: turn / era / buttons
	var era_s := L10n.t(String(_S["era"])).to_upper()   # translated before it is shortened to fit
	var turn_s := "TURN %d" % _S["turn"]
	var ds0 := str(_S.get("date", ""))
	var room := _xr(_era_right()) - (x - 10) - UIKit.text_width(turn_s, "title_reg", 15) - UIKit.text_width(ds0, "title_reg", 15) - 70
	var efs := 15
	while efs > 11 and UIKit.text_width(era_s, "title_reg", efs) > room:
		efs -= 1
	# v3 final (fix4-ui): a long era name that does not fit on one line takes two short lines before it is ever cut
	var era_lines := [era_s]
	if UIKit.text_width(era_s, "title_reg", efs) > room and era_s.contains(" "):
		era_lines = _two_lines(era_s)
		efs = 13
		while efs > 10 and maxf(UIKit.text_width(era_lines[0], "title_reg", efs), UIKit.text_width(era_lines[1], "title_reg", efs)) > room:
			efs -= 1
		# still too long: the era's short name (the full name is in the Civilopedia and the era banner)
		var short_en := str(ERA_SHORT.get(String(_S["era"]), ""))
		if short_en != "" and maxf(UIKit.text_width(era_lines[0], "title_reg", efs), UIKit.text_width(era_lines[1], "title_reg", efs)) > room:
			var sh := L10n.t(short_en).to_upper()
			efs = 15
			while efs > 11 and UIKit.text_width(sh, "title_reg", efs) > room:
				efs -= 1
			era_lines = [sh]
			if UIKit.text_width(sh, "title_reg", efs) > room and sh.contains(" "):
				era_lines = _two_lines(sh)
				efs = 13
				while efs > 10 and maxf(UIKit.text_width(era_lines[0], "title_reg", efs), UIKit.text_width(era_lines[1], "title_reg", efs)) > room:
					efs -= 1
	for li in era_lines.size():
		while str(era_lines[li]).length() > 8 and UIKit.text_width(era_lines[li], "title_reg", efs) > room:
			era_lines[li] = str(era_lines[li]).substr(0, str(era_lines[li]).length() - 2).strip_edges() + "…"
			era_lines[li] = str(era_lines[li]).replace("……", "…")
	era_s = " ".join(era_lines)
	var era_w := 0.0
	for ln in era_lines:
		era_w = maxf(era_w, UIKit.text_width(ln, "title_reg", efs))
	var era_x := _xr(_era_right()) - era_w
	if era_lines.size() == 1:
		UIKit.text(self, Vector2(era_x, 30), era_s, "title_reg", efs, UIKit.TEXT)
	else:
		for li in 2:
			var lw := UIKit.text_width(era_lines[li], "title_reg", efs)
			UIKit.text(self, Vector2(_xr(_era_right()) - lw, 21 + li * 15), era_lines[li], "title_reg", efs, UIKit.TEXT)
	era_drawn = era_lines.duplicate()
	draw_line(Vector2(era_x - 12, 13), Vector2(era_x - 12, 35), Color(UIKit.GOLD_DARK, 0.9), 1.2)
	var rx := era_x - 24 - UIKit.text_width(turn_s, "title_reg", 15)
	UIKit.text(self, Vector2(rx, 30), turn_s, "title_reg", 15, UIKit.TEXT)
	draw_line(Vector2(_xr(_era_right() + 14.0), 13), Vector2(_xr(_era_right() + 14.0), 35), Color(UIKit.GOLD_DARK, 0.9), 1.2)
	var keys: Array = TOP_KEYS if not story_mode else story_keys
	for i in keys.size():
		var c := Vector2(_xr(_btn_cx(str(keys[i]))), 23)
		var hov: bool = _hover == keys[i]
		draw_circle(c, 13.5, Color(0.08, 0.14, 0.28) if hov else Color(0.02, 0.04, 0.10))
		draw_arc(c, 13.5, 0, TAU, 40, UIKit.GOLD_LIGHT if hov else UIKit.TEXT_DIM, 1.6, true)
		match str(keys[i]):
			"pedia": _book(c)
			"help": UIKit.text(self, c + Vector2(-5, 7), "?", "title", 19, UIKit.TEXT, HORIZONTAL_ALIGNMENT_LEFT, -1, false)
			"menu":
				for k in 3:
					draw_line(c + Vector2(-6, -5 + k * 5), c + Vector2(6, -5 + k * 5), UIKit.TEXT, 1.8)
			"settings": _gear(c, 8.0)
	# date under the turn (small)
	var ds := str(_S.get("date", ""))
	var dx := rx - 22 - UIKit.text_width(ds, "title_reg", 15)
	UIKit.text(self, Vector2(dx, 30), ds, "title_reg", 15, UIKit.GOLD)
	draw_line(Vector2(rx - 12, 13), Vector2(rx - 12, 35), Color(UIKit.GOLD_DARK, 0.9), 1.2)


func _danger_glyph(c: Vector2) -> void:
	## A collapse of the state in sight (v3 item 13): a red warning triangle.
	var tri := PackedVector2Array([c + Vector2(0, -12), c + Vector2(12, 10), c + Vector2(-12, 10)])
	draw_colored_polygon(tri, Color(0.75, 0.12, 0.10))
	draw_polyline(tri + PackedVector2Array([tri[0]]), Color(1.0, 0.85, 0.75), 1.6, true)
	draw_line(c + Vector2(0, -5), c + Vector2(0, 3), Color.WHITE, 2.4, true)
	draw_circle(c + Vector2(0, 6.5), 1.6, Color.WHITE)


func _shield_glyph(c: Vector2) -> void:
	## Readiness (v4 story top bar): a gold-rimmed shield.
	var sh := PackedVector2Array([c + Vector2(-10, -11), c + Vector2(10, -11), c + Vector2(10, -1), c + Vector2(0, 12), c + Vector2(-10, -1)])
	draw_colored_polygon(sh, Color(0.10, 0.20, 0.42))
	draw_polyline(sh + PackedVector2Array([sh[0]]), UIKit.GOLD_LIGHT, 1.8, true)
	draw_line(c + Vector2(0, -8), c + Vector2(0, 7), Color(UIKit.GOLD_LIGHT, 0.8), 1.4, true)
	draw_line(c + Vector2(-7, -4), c + Vector2(7, -4), Color(UIKit.GOLD_LIGHT, 0.8), 1.4, true)


func _econ_glyph(c: Vector2, level := "ok") -> void:
	## Debt and inflation: a coin rim with a percent sign. The rim shows the fiscal indicator's tier: gold (ok), amber
	## (watch), orange (warning), red on a red coin (danger).
	var rim: Color = UIKit.GOLD_LIGHT
	var fill := Color(0.10, 0.08, 0.04)
	match level:
		"watch": rim = UIKit.WARN
		"warning": rim = UIKit.WARN_HI
		"danger":
			rim = UIKit.BAD
			fill = Color(0.42, 0.07, 0.05)
	draw_circle(c, 11.5, fill)
	draw_arc(c, 11.5, 0, TAU, 32, rim, 2.0 if level == "ok" else 2.6, true)
	draw_arc(c, 8.5, 0, TAU, 28, Color(UIKit.GOLD_DARK, 0.9), 1.0, true)
	draw_circle(c + Vector2(-3.6, -3.6), 2.0, UIKit.GOLD_LIGHT)
	draw_circle(c + Vector2(3.6, 3.6), 2.0, UIKit.GOLD_LIGHT)
	draw_line(c + Vector2(4.8, -5.2), c + Vector2(-4.8, 5.2), UIKit.GOLD_LIGHT, 1.8, true)


func _get_tooltip(at: Vector2) -> String:
	## Top-bar items and the city panel's food row explain themselves (live["top_tips"], live["city"]["food_tip"]).
	var q := _to_ref(at)
	var tips: Array = live.get("top_tips", [])
	if tip_host != null:
		tips = []   # (the top bar's own panel explains its items)
	for i in mini(_tip_rects.size(), tips.size()):
		if (_tip_rects[i] as Rect2).has_point(q):
			return str(tips[i])
	var cd: Dictionary = live.get("city", {})
	if not cd.is_empty() and Rect2(R_CITY.position + Vector2(12, 100), Vector2(R_CITY.size.x - 24, 30)).has_point(q):
		return str(cd.get("food_tip", ""))
	if not story_mode and Rect2(_xr(R_NEXT.position.x), R_NEXT.position.y, R_NEXT.size.x, R_NEXT.size.y).has_point(q):
		return str(live.get("next_tip", ""))
	var gd: Dictionary = live.get("ghost", {})
	if _ghost_health_r().has_point(q) and float(gd.get("health", 1.0)) < 0.995 and (not story_mode or story_show.has("ghost")):
		return str(gd.get("health_text", "")) + "\nThe overall score against history is weighed by the state's health; the six tracks are not."
	return ""


func _book(c: Vector2) -> void:
	## Civilopedia: an open book.
	var col := UIKit.TEXT
	draw_polyline(PackedVector2Array([c + Vector2(0, -4), c + Vector2(-4, -6), c + Vector2(-8, -5.5), c + Vector2(-8, 5), c + Vector2(-4, 4.5), c + Vector2(0, 6.5)]), col, 1.5, true)
	draw_polyline(PackedVector2Array([c + Vector2(0, -4), c + Vector2(4, -6), c + Vector2(8, -5.5), c + Vector2(8, 5), c + Vector2(4, 4.5), c + Vector2(0, 6.5)]), col, 1.5, true)
	draw_line(c + Vector2(0, -4), c + Vector2(0, 6.5), col, 1.3, true)


func _gear(c: Vector2, r: float) -> void:
	var pts := PackedVector2Array()
	for i in 48:
		var a := TAU * i / 48.0
		var rr := r if (i % 6) < 3 else r * 0.72
		pts.append(c + Vector2(cos(a), sin(a)) * rr)
	pts.append(pts[0])
	draw_polyline(pts, UIKit.TEXT, 1.5, true)
	draw_arc(c, r * 0.33, 0, TAU, 16, UIKit.TEXT, 1.5, true)


func _thousands(n: int) -> String:
	var s := str(n)
	var out := ""
	while s.length() > 3:
		out = "," + s.substr(s.length() - 3) + out
		s = s.substr(0, s.length() - 3)
	return s + out


func _draw_card(r: Rect2, title: String, d: Dictionary, accent: Color) -> void:
	UIKit.panel(self, r, 5.0)
	var c := Vector2(r.position.x + 44, r.position.y + r.size.y * 0.5)
	UIKit.gold_circle(self, c, 29, Color(0.06, 0.16, 0.34), Color(0.02, 0.05, 0.12))
	draw_arc(c, 25.5, 0, TAU, 48, Color(accent, 0.18), 4.0, true)
	UIKit.ring(self, c, 25.5, 4.0, accent, d["progress"])
	UIKit.icon_at(self, d["icon"], c, 38)
	var tx := r.position.x + 90
	UIKit.text(self, Vector2(tx, r.position.y + 20), title, "title", 13, UIKit.TEXT)
	var nfs := 21
	while nfs > 12 and UIKit.text_width(str(d["name"]), "body", nfs) > r.end.x - tx - 8:
		nfs -= 1
	UIKit.text(self, Vector2(tx, r.position.y + 44), str(d["name"]), "body", nfs, UIKit.TEXT)
	UIKit.bar(self, Rect2(tx, r.position.y + 54, 132, 6), d["progress"], accent)
	if int(d["turns"]) > 0:
		UIKit.text(self, Vector2(tx + 142, r.position.y + 61), UITheme.turns(int(d["turns"])), "body", 16, UIKit.TEXT_DIM)


func _draw_ghost_chip(g: Dictionary) -> void:
	var r := _ghost_r()
	var hov: bool = _hover == "ghost"
	UIKit.panel(self, r, 5.0, Color(0.09, 0.15, 0.30, 0.95) if hov else UIKit.NAVY_TOP, UIKit.NAVY_BOT)
	UIKit.text(self, r.position + Vector2(14, 24), "VS. HISTORY", "title", 13, UIKit.GOLD_LIGHT)
	var t := str(g.get("text", ""))
	var tfs := 17
	while tfs > 12 and UIKit.text_width(t, "body", tfs) > 140:
		tfs -= 1
	UIKit.text(self, r.position + Vector2(112, 24), t, "body", tfs, UIKit.TEXT_DIM if g.get("early", false) else UIKit.TEXT)
	var n := int(g.get("ahead", 0))
	var nb := int(g.get("behind", 0))
	for i in 6:
		var c := r.position + Vector2(262 + (i % 3) * 7, 13 + (i / 3) * 10)
		var col := Color(0.30, 0.32, 0.40)
		if i < n: col = UIKit.GREEN
		elif i >= 6 - nb: col = UIKit.BAD
		draw_circle(c, 3.0, col)
	draw_polyline(PackedVector2Array([r.end - Vector2(14, 25), r.end - Vector2(8, 18), r.end - Vector2(14, 11)]), UIKit.TEXT, 1.8, true)
	# v3 fix3-econ: the headline score is weighed by the state's health; below 100% a strip under the chip says why
	var hf := float(g.get("health", 1.0))
	if hf < 0.995 and str(g.get("health_text", "")) != "":
		var hr := _ghost_health_r()
		UIKit.panel(self, hr, 4.0, Color(0.22, 0.06, 0.05, 0.95) if hf < 0.85 else Color(0.20, 0.13, 0.04, 0.95), Color(0.08, 0.03, 0.03, 0.95))
		var ht := str(g["health_text"]).trim_suffix(".")
		var hfs := 14
		while hfs > 12 and UIKit.text_width(ht, "body", hfs) > hr.size.x - 20:
			hfs -= 1
		if UIKit.text_width(ht, "body", hfs) > hr.size.x - 20:   # too long: the figure here, the reasons in the tooltip
			ht = "State's health %d%% (hover for why)" % int(round(hf * 100.0))
			hfs = 14
		UIKit.text(self, hr.position + Vector2(10, 17), ht, "body", hfs, UIKit.BAD if hf < 0.85 else UIKit.WARN)


func _draw_city() -> void:
	var r := R_CITY
	var d: Dictionary = _S["city"]
	UIKit.panel(self, r, 6.0)
	var th := UIKit.tex(str(d.get("thumb", "res://assets/ui/thumb_telaviv.png")))
	var tr := Rect2(r.position + Vector2(12, 10), Vector2(56, 56))
	if th:
		draw_texture_rect(th, tr, false)
	draw_rect(tr, UIKit.GOLD, false, 1.5)
	UIKit.text(self, r.position + Vector2(78, 31), String(d["name"]).to_upper(), "title", 22, UIKit.GOLD_LIGHT)
	UIKit.text(self, r.position + Vector2(81, 55), "Population  %s" % str(d["population"]), "body", 19, UIKit.TEXT)
	UIKit.star_of_david(self, r.position + Vector2(348, 36), 12, UIKit.TEXT, 2.0)
	var food_col: Color = d.get("food_col", UIKit.BAD if str(d["food"]).begins_with("−") else UIKit.GREEN)
	var rows := [["production", "Production", str(d["production"]), UIKit.GOLD_LIGHT], ["food", str(d.get("food_label", "Food surplus")), str(d["food"]), food_col],
		["housing", "Housing", str(d["housing"]), UIKit.TEXT]]
	for i in rows.size():
		var y := r.position.y + 71 + i * 30
		var rowr := Rect2(r.position.x + 12, y - 1, r.size.x - 24, 28)
		var rp := UIKit.rrect_points(rowr.grow_individual(0, 0, 0, -2), 4.0)
		UIKit.gradient_poly(self, rp, Color(0.13, 0.19, 0.32, 0.75), Color(0.07, 0.11, 0.21, 0.75), rowr.position.y, rowr.end.y)
		var rl := rp.duplicate(); rl.append(rp[0])
		draw_polyline(rl, Color(0.35, 0.42, 0.58, 0.35), 1.0, true)
		UIKit.icon_at(self, rows[i][0], Vector2(r.position.x + 36, y + 13), 22)
		UIKit.text(self, Vector2(r.position.x + 60, y + 20), rows[i][1], "body", 19, UIKit.TEXT)
		UIKit.text(self, Vector2(r.position.x + 160, y + 20), rows[i][2], "body", 21, rows[i][3], HORIZONTAL_ALIGNMENT_RIGHT, 200)
	# building box
	var b := Rect2(r.position + Vector2(12, 169), Vector2(r.size.x - 24, 70))
	UIKit.panel(self, b, 4.0, Color(0.05, 0.09, 0.18, 0.95), Color(0.02, 0.04, 0.10, 0.95))
	var bthumb := str(d.get("building_thumb", ""))
	var bt := UIKit.tex(bthumb) if bthumb != "" else null
	var btr := Rect2(b.position + Vector2(9, 9), Vector2(76, 52))
	if bt:
		draw_texture_rect_region(bt, btr, Rect2(0, 160, 1024, 700))
	else:
		draw_rect(btr, Color(0.03, 0.06, 0.13))
		_gear(btr.get_center(), 14.0)
	draw_rect(btr, UIKit.GOLD, false, 1.2)
	var btxt := "BUILDING:  " + String(d["building"]).to_upper()
	var bfs := 14
	while bfs > 10 and UIKit.text_width(btxt, "title", bfs) > b.size.x - 108:
		bfs -= 1
	UIKit.text(self, b.position + Vector2(99, 25), btxt, "title", bfs, UIKit.TEXT)
	UIKit.bar(self, Rect2(b.position.x + 99, b.position.y + 43, 176, 7), d["building_progress"], UIKit.BLUE)
	if int(d["building_turns"]) > 0:
		UIKit.text(self, Vector2(b.position.x + 290, b.position.y + 51), UITheme.turns(int(d["building_turns"])), "body", 16, UIKit.TEXT_DIM)


func _draw_actions() -> void:
	for i in ACTIONS.size():
		var a: Array = ACTIONS[i]
		var c := Vector2(_xc(ACTION_X[i]), ACTION_Y)
		var hov: bool = _hover == "act_" + a[0]
		UIKit.gold_circle(self, c, 36.0 if not hov else 38.0, Color(0.10, 0.18, 0.36), Color(0.02, 0.05, 0.12))
		draw_arc(c, 31.5, 0, TAU, 48, Color(UIKit.GOLD_DARK, 0.9), 1.2, true)
		UIKit.icon_at(self, a[2], c, 46 if not hov else 50)
		var lw := UIKit.text_width(a[1], "body", 17) + 16
		var lr := Rect2(c.x - lw * 0.5, ACTION_Y + 38, lw, 22)
		draw_colored_polygon(UIKit.rrect_points(lr, 9.0), Color(0.02, 0.04, 0.10, 0.96))   # opaque: world labels behind never show through
		UIKit.text(self, Vector2(c.x - 60, ACTION_Y + 54), a[1], "body", 17, UIKit.TEXT, HORIZONTAL_ALIGNMENT_CENTER, 120)


func _draw_minimap() -> void:
	var r := Rect2(Vector2(_xr(R_MINIMAP.position.x), R_MINIMAP.position.y), R_MINIMAP.size)
	UIKit.panel(self, r.grow(3), 6.0)
	if minimap_tex:
		draw_rect(r, MM_VOID)
		var src := Rect2((_mm_world.position - _mm_full.position) * MM_PPU, _mm_world.size * MM_PPU)
		draw_texture_rect_region(minimap_tex, r, src)
	draw_rect(r, UIKit.GOLD, false, 1.5)
	UIKit.text(self, Vector2(r.end.x - 22, r.position.y + 22), "N", "title", 14, UIKit.TEXT)
	if minimap_view.size() == 4 and _mm_world.size.x > 0:
		var pts := PackedVector2Array()
		for p in minimap_view:
			var uv := (p - _mm_world.position) / _mm_world.size
			uv = uv.clamp(Vector2(0.01, 0.01), Vector2(0.99, 0.99))
			pts.append(r.position + uv * r.size)
		pts.append(pts[0])
		draw_polyline(pts, Color(1, 1, 1, 0.95), 1.6, true)
	# little toolbar on the left of the minimap
	var t := Rect2(Vector2(_xr(R_MMTOOLS.position.x), R_MMTOOLS.position.y), R_MMTOOLS.size)
	UIKit.panel(self, t, 4.0)
	var cx := t.get_center().x
	# mountain, leaf, compass glyphs
	draw_polyline(PackedVector2Array([Vector2(cx - 8, t.position.y + 23), Vector2(cx - 2, t.position.y + 13), Vector2(cx + 1, t.position.y + 17), Vector2(cx + 4, t.position.y + 12), Vector2(cx + 9, t.position.y + 23), Vector2(cx - 8, t.position.y + 23)]), UIKit.TEXT, 1.6, true)
	draw_line(Vector2(cx - 6, t.position.y + 56), Vector2(cx + 6, t.position.y + 40), UIKit.TEXT, 1.6, true)
	for k in 3:
		draw_line(Vector2(cx - 2 + k * 3, t.position.y + 51 - k * 4), Vector2(cx - 7 + k * 3, t.position.y + 47 - k * 4), UIKit.TEXT, 1.3, true)
		draw_line(Vector2(cx - 2 + k * 3, t.position.y + 51 - k * 4), Vector2(cx + 3 + k * 3, t.position.y + 50 - k * 4), UIKit.TEXT, 1.3, true)
	var cc := Vector2(cx, t.position.y + 76)
	draw_arc(cc, 7, 0, TAU, 24, UIKit.TEXT, 1.5, true)
	draw_line(cc + Vector2(-3, 3), cc + Vector2(3, -3), UIKit.TEXT, 1.6, true)


func _draw_next() -> void:
	var r := Rect2(Vector2(_xr(R_NEXT.position.x), R_NEXT.position.y), R_NEXT.size)
	var hov: bool = _hover == "next"
	UIKit.panel(self, r.grow(3), 6.0, Color(0.04, 0.07, 0.15, 0.95), Color(0.02, 0.04, 0.10, 0.95))
	var blocking: bool = _S.get("next_blocking", false)
	var top := Color(0.20, 0.42, 0.92) if not hov else Color(0.28, 0.52, 1.0)
	var bot := Color(0.08, 0.20, 0.58) if not hov else Color(0.12, 0.28, 0.70)
	if blocking:
		top = Color(0.92, 0.64, 0.18) if not hov else Color(1.0, 0.74, 0.28)
		bot = Color(0.62, 0.36, 0.06) if not hov else Color(0.72, 0.44, 0.10)
	var pts := UIKit.rrect_points(r, 5.0)
	UIKit.gradient_poly(self, pts, top, bot, r.position.y, r.end.y)
	var pl := pts.duplicate(); pl.append(pts[0])
	draw_polyline(pl, UIKit.GOLD_LIGHT, 1.6, true)
	draw_rect(Rect2(r.position + Vector2(4, 3), Vector2(r.size.x - 8, r.size.y * 0.42)), Color(1, 1, 1, 0.07))
	var lab := str(_S.get("next_label", "NEXT TURN"))
	var fs := 20
	while fs > 12 and UIKit.text_width(lab, "title", fs) > r.size.x - 64:
		fs -= 1
	var sub := str(_S.get("next_sub", ""))
	var ly := r.position.y + 25 + fs * 0.4 - (7.0 if sub != "" else 0.0)
	UIKit.text(self, Vector2(r.position.x + 4, ly), lab, "title", fs, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 36)
	if sub != "":
		UIKit.text(self, Vector2(r.position.x, r.position.y + 44), sub, "body", 14, Color(1, 0.95, 0.85), HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 10)
	var ax := r.end.x - 26; var ay := r.get_center().y
	draw_polyline(PackedVector2Array([Vector2(ax - 4, ay - 8), Vector2(ax + 3, ay), Vector2(ax - 4, ay + 8)]), Color.WHITE, 2.4, true)


func _process(_d: float) -> void:
	if _mm_task >= 0:
		_mm_poll()   # perf60: the minimap bitmap from the worker thread
