class_name UnitFlags
extends Control
## Screen-space unit flags above unit models: blue/gold for Israeli units, red for hostile forces,
## a ring on the selected unit and a "!" on units that still need orders.

var ui
var cam: Camera3D


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


var _tick := 0


var _web := OS.has_feature("web")
var _sig := []


func _process(_d: float) -> void:
	_tick += 1
	if _tick % 45 == 0 and ui and ui.sim:
		ui._sync_banners(false)
	if _web and ui != null and cam != null:
		# web: redraw only when something on screen can have changed (the camera, the units, the banners, the
		# selection), the selection ring's pulse at 20 Hz and a refresh every 10 frames (hit points, orders)
		var sel: int = ui.selected_unit if ui.get("selected_unit") != null else -1
		var sig := [cam.global_transform, ui.unit_cache.size() if ui.get("unit_cache") != null else 0, sel,
			(ui._pending_banners as Array).size() if ui.get("_pending_banners") != null else 0, get_viewport_rect().size]
		if sig == _sig and _tick % 10 != 0 and not (sel >= 0 and _tick % 3 == 0):
			return
		_sig = sig
	queue_redraw()


func _draw_pending(vr: Rect2) -> void:
	for b in ui._pending_banners:
		var wp: Vector3 = ui.mv.tile_world(int(b["q"]), int(b["r"])) + Vector3(0, 0.5, 0)
		if cam.is_position_behind(wp):
			continue
		var sp := cam.unproject_position(wp)
		if not vr.grow(100).has_point(sp):
			continue
		var k := clampf(12.0 / cam.global_position.distance_to(wp), 0.55, 1.0)
		var nm := L10n.t(str(b["name"])).to_upper()
		var fs := int(18 * k)
		var w := UIKit.text_width(nm, "title", fs) + 60 * k
		var h := 30.0 * k
		var r := Rect2(sp.x - w * 0.5, sp.y - h, w, h)
		draw_colored_polygon(UIKit.rrect_points(r, h * 0.5), Color(0.03, 0.07, 0.16, 0.92))
		var pl := UIKit.rrect_points(r, h * 0.5); pl.append(pl[0])
		draw_polyline(pl, UIKit.GOLD, 1.6, true)
		var c := Vector2(r.position.x + h * 0.5, r.get_center().y)
		draw_circle(c, h * 0.5 - 2, Color(0.02, 0.05, 0.12))
		draw_arc(c, h * 0.5 - 2, 0, TAU, 24, UIKit.GOLD_LIGHT, 1.4, true)
		draw_string(UIKit.font("title"), c + Vector2(-h * 0.5, fs * 0.36), str(b["pop"]), HORIZONTAL_ALIGNMENT_CENTER, h, fs, Color.WHITE)
		draw_string(UIKit.font("title"), Vector2(r.position.x + h + 6 * k, r.get_center().y + fs * 0.36), nm, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, UIKit.TEXT)


const LETTER := {"melee": "I", "armor": "A", "siege": "G", "air": "J", "naval": "N", "defense": "D", "civilian": "C", "rockets": "R"}


func _draw() -> void:
	if ui == null or ui.sim == null or cam == null or ui.mv == null or not ui.started:
		return
	var vr := get_viewport_rect()
	_draw_pending(vr)
	var t := Time.get_ticks_msec() / 1000.0
	# group by hex: a full flag only for the selected unit or units needing orders; otherwise one count badge
	var hexes := {}
	var order := []
	for u in ui.unit_cache:
		var k := Vector2i(int(u["q"]), int(u["r"]))
		if not hexes.has(k):
			hexes[k] = []
			order.append(k)
		hexes[k].append(u)
	for k in order:
		var us: Array = hexes[k]
		var main = null
		for u in us:
			if int(u["id"]) == ui.selected_unit:
				main = u
		if main == null:
			for u in us:
				if u.get("needs_orders", false) and str(u["owner"]) == "player":
					main = u; break
		var wp: Vector3 = ui.mv.tile_world(k.x, k.y) + Vector3(-0.35, 0.62, 0.3)
		if cam.is_position_behind(wp):
			continue
		var sp := cam.unproject_position(wp)
		if not vr.grow(40).has_point(sp):
			continue
		var s := clampf(14.0 / cam.global_position.distance_to(wp), 0.6, 1.15)
		var any_hostile := us.any(func(x): return str(x["owner"]) != "player")
		if main == null:
			# quiet badge: how many units stand here
			var rr := 8.0 * s
			draw_circle(sp, rr, Color(0.55, 0.12, 0.10, 0.85) if any_hostile else Color(0.05, 0.12, 0.28, 0.80))
			draw_arc(sp, rr, 0, TAU, 20, Color(1, 0.8, 0.7, 0.8) if any_hostile else Color(UIKit.GOLD, 0.7), 1.2, true)
			draw_string(UIKit.font("body_bold"), sp + Vector2(-rr, 4.5 * s), str(us.size()), HORIZONTAL_ALIGNMENT_CENTER, rr * 2, int(12 * s), Color.WHITE)
			continue
		var u: Dictionary = main
		var hostile: bool = str(u["owner"]) != "player"
		var fill := Color(0.62, 0.12, 0.10, 0.95) if hostile else Color(0.08, 0.20, 0.48, 0.95)
		var rim := Color(1.0, 0.75, 0.65) if hostile else UIKit.GOLD_LIGHT
		var r := 12.0 * s
		draw_circle(sp + Vector2(0, 2), r + 2, Color(0, 0, 0, 0.4))
		draw_circle(sp, r, fill)
		draw_arc(sp, r, 0, TAU, 24, rim, 1.6, true)
		var cls := str(u.get("cls", ""))
		var letter: String = "S" if u["type"] == "settler" else ("B" if u["type"] == "builder" else LETTER.get(cls, "?"))
		var fs := int(15 * s)
		draw_string(UIKit.font("title"), sp + Vector2(-r, fs * 0.36), letter, HORIZONTAL_ALIGNMENT_CENTER, r * 2, fs, Color.WHITE)
		if us.size() > 1:
			var bc := sp + Vector2(r * 0.95, r * 0.75)
			draw_circle(bc, 6.5 * s, Color(0.02, 0.04, 0.10, 0.95))
			draw_string(UIKit.font("body_bold"), bc + Vector2(-7 * s, 4 * s), str(us.size()), HORIZONTAL_ALIGNMENT_CENTER, 14 * s, int(10 * s), Color.WHITE)
		var hpw := r * 2.0
		draw_rect(Rect2(sp + Vector2(-r, r + 3), Vector2(hpw, 3)), Color(0, 0, 0, 0.7))
		draw_rect(Rect2(sp + Vector2(-r, r + 3), Vector2(hpw * float(u["hp"]) / 100.0, 3)), UIKit.GREEN if float(u["hp"]) > 50 else UIKit.BAD)
		if int(u["id"]) == ui.selected_unit:
			draw_arc(sp, r + 5 + sin(t * 5.0) * 1.5, 0, TAU, 32, Color(1, 1, 1, 0.95), 2.2, true)
		elif u.get("needs_orders", false) and not hostile:
			var c := sp + Vector2(r * 0.9, -r * 0.9)
			draw_circle(c, 6 * s, Color(0.95, 0.65, 0.15))
			draw_string(UIKit.font("title"), c + Vector2(-6 * s, 4.5 * s), "!", HORIZONTAL_ALIGNMENT_CENTER, 12 * s, int(12 * s), Color.BLACK)
		if ui.auto_units.has(int(u["id"])) and not hostile:
			draw_string(UIKit.font("body_bold"), sp + Vector2(-r - 4, -r - 3), L10n.t("auto"), HORIZONTAL_ALIGNMENT_CENTER, r * 2 + 8, int(11 * s), UIKit.GREEN)
		elif str(u.get("orders", "")) == "fortify" and not hostile:
			draw_string(UIKit.font("body_bold"), sp + Vector2(-r, -r - 3), L10n.t("fort."), HORIZONTAL_ALIGNMENT_CENTER, r * 2, int(11 * s), UIKit.TEXT_DIM)
