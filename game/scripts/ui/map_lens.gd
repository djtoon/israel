class_name MapLens
extends Control
## Screen-space map lenses drawn over the terrain (CanvasLayer 1, beside the unit flags):
##  - "district": Civ VI district placement badges: a round yield icon with the adjacency bonus on every valid tile
##    (best site starred), the tile tint comes from MapView.set_tile_labels;
##  - "citizens": the yields of each of the city's tiles (worked and locked medallions come from MapView.set_worked_tiles).

var ui
var cam: Camera3D
var mode := ""             # "" | "district" | "citizens"
var sites: Array = []      # district: [{q, r, adjacency, best}]
var yield_type := ""       # district: the yield its adjacency gives
var tiles: Array = []      # citizens: [{q, r, yields, worked, locked, workable}]
var hover := Vector2i(-999, -999)

const YIELD_ICON := {"science": "science", "gold": "gold", "production": "production", "culture": "culture", "food": "food", "amenity": "happy", "cohesion": "star", "faith": "star"}
const YIELD_ORDER := ["food", "production", "gold", "science", "culture"]


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func show_district(s: Array, ytype: String) -> void:
	mode = "district"
	sites = s
	yield_type = ytype
	queue_redraw()


func show_citizens(t: Array) -> void:
	mode = "citizens"
	tiles = t
	queue_redraw()


func clear() -> void:
	mode = ""
	sites = []
	tiles = []
	queue_redraw()


func _process(_d: float) -> void:
	if mode != "":
		queue_redraw()


func _screen(q: int, r: int, lift := 0.25):
	if cam == null or ui == null or ui.mv == null:
		return null
	var wp: Vector3 = ui.mv.tile_world(q, r) + Vector3(0, lift, 0)
	if cam.is_position_behind(wp):
		return null
	var sp := cam.unproject_position(wp)
	if not get_viewport_rect().grow(60).has_point(sp):
		return null
	return sp


func _scale_at(q: int, r: int) -> float:
	var wp: Vector3 = ui.mv.tile_world(q, r)
	return clampf(14.0 / maxf(1.0, cam.global_position.distance_to(wp)), 0.6, 1.25)


func _draw() -> void:
	if mode == "" or ui == null or cam == null:
		return
	match mode:
		"district": _draw_district()
		"citizens": _draw_citizens()


func _draw_district() -> void:
	var ic := str(YIELD_ICON.get(yield_type, "cities"))
	for st in sites:
		var q := int(st["q"]); var r := int(st["r"])
		var sp = _screen(q, r)
		if sp == null:
			continue
		var s := _scale_at(q, r)
		var adj := float(st.get("adjacency", 0))
		var best := bool(st.get("best", false))
		var hov: bool = hover == Vector2i(q, r)
		var rad := (22.0 if not hov else 25.0) * s
		var c: Vector2 = sp
		draw_circle(c + Vector2(0, 2), rad + 2, Color(0, 0, 0, 0.45))
		var fill := Color(0.06, 0.20, 0.10, 0.94) if adj > 0 else Color(0.10, 0.11, 0.16, 0.92)
		draw_circle(c, rad, fill)
		draw_arc(c, rad, 0, TAU, 28, UIKit.GOLD_LIGHT if best or hov else (UIKit.GREEN if adj > 0 else Color(0.6, 0.62, 0.7)), 2.2 if best or hov else 1.5, true)
		UIKit.icon_at(self, ic, c + Vector2(0, -6 * s), 22 * s)
		var txt := UITheme.fmt_signed(adj, 0 if adj == roundf(adj) else 1) if adj != 0 else "0"
		var fs := int(18 * s)
		draw_string(UIKit.font("title"), c + Vector2(-rad, rad * 0.62), txt, HORIZONTAL_ALIGNMENT_CENTER, rad * 2, fs,
			UIKit.GREEN.lightened(0.25) if adj > 0 else UIKit.TEXT_DIM)
		if best:
			UIKit.star_of_david(self, c + Vector2(rad * 0.95, -rad * 0.85), 5.0 * s, UIKit.GOLD_LIGHT, 1.4)


func _draw_citizens() -> void:
	for t in tiles:
		if not bool(t.get("workable", true)):
			continue
		var q := int(t["q"]); var r := int(t["r"])
		var sp = _screen(q, r, 0.3)
		if sp == null:
			continue
		var s := _scale_at(q, r)
		var y: Dictionary = t.get("yields", {})
		var items := []
		for k in YIELD_ORDER:
			var v := float(y.get(k, 0))
			if v >= 0.5:
				items.append([k, v])
		if items.is_empty():
			continue
		var w := 0.0
		var fs := int(12 * s)
		for it in items:
			w += 13.0 * s + UIKit.text_width(str(int(round(it[1]))), "body_bold", fs) + 3.0 * s
		var hov: bool = hover == Vector2i(q, r)
		var bx := Rect2(sp + Vector2(-w * 0.5 - 4 * s, -24 * s), Vector2(w + 8 * s, 16 * s))
		var on := bool(t.get("worked", false)) or bool(t.get("locked", false))
		draw_colored_polygon(UIKit.rrect_points(bx, 5.0 * s), Color(0.02, 0.05, 0.12, 0.88 if on else 0.62))
		var pl := UIKit.rrect_points(bx, 5.0 * s); pl.append(pl[0])
		draw_polyline(pl, (UIKit.GOLD_LIGHT if hov else (UIKit.GOLD if on else Color(0.45, 0.45, 0.5, 0.7))), 1.2, true)
		var x := bx.position.x + 4 * s
		for it in items:
			UIKit.icon_at(self, str(YIELD_ICON.get(it[0], "star")), Vector2(x + 6 * s, bx.get_center().y), 12 * s, Color(1, 1, 1, 1.0 if on else 0.7))
			x += 13.0 * s
			var nt := str(int(round(it[1])))
			draw_string(UIKit.font("body_bold"), Vector2(x, bx.get_center().y + 4.5 * s), nt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, UIKit.TEXT if on else UIKit.TEXT_DIM)
			x += UIKit.text_width(nt, "body_bold", fs) + 3.0 * s
