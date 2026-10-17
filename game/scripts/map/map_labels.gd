class_name MapLabels
extends Control
## Screen-space overlays anchored to the 3D map: city banners, resource pins, tile tooltip.

var cam: Camera3D
var renderer: TerrainRenderer
var map: MapData
var hover_tile := {}
var hover_screen := Vector2.ZERO
var show_tooltip := false
var home_city := "Tel Aviv-Yafo"

const RES_PIN := {"fish": "res_fish", "olives": "res_olives", "citrus": "res_citrus", "wheat": "res_wheat",
	"dates": "res_dates", "natural_gas": "res_gas", "gas": "res_gas", "oil": "res_gas", "potash": "res_potash",
	"phosphates": "res_phosphate", "phosphate": "res_phosphate", "copper": "res_copper", "grapes": "res_wine",
	"sheep": "res_wheat", "cattle": "res_wheat"}


const CIV_COL := {"iraq": Color(0.55, 0.42, 0.25), "contested": Color(0.55, 0.55, 0.58), "palestine": Color(0.20, 0.55, 0.35), "hamas": Color(0.16, 0.42, 0.28), "jordan": Color(0.62, 0.22, 0.25), "egypt": Color(0.80, 0.62, 0.22),
	"lebanon": Color(0.30, 0.62, 0.45), "syria": Color(0.45, 0.35, 0.62)}


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_d: float) -> void:
	queue_redraw()


## Screen rects (in this control's pixels) that map labels must not draw under (HUD panels).
## Defaults follow the current HUD layout on the 1672x941 reference canvas; the UI may replace them.
var occluders: Array = []
const REF_OCCLUDERS := [Rect2(0, 0, 99999, 52), Rect2(0, 58, 315, 172), Rect2(0, 655, 398, 286),
	Rect2(-470, 815, 470, 126), Rect2(-290, 660, 290, 281)]   # negative x = from the right edge / centre (see _occ)


func reset() -> void:
	pass


func _occ() -> Array:
	if not occluders.is_empty():
		return occluders
	var s := _ui_scale()
	var out := []
	for i in REF_OCCLUDERS.size():
		var r: Rect2 = REF_OCCLUDERS[i]
		var x := r.position.x * s
		if i == 3: x = size.x * 0.5 - 235 * s          # action buttons, centred
		elif r.position.x < 0: x = size.x + r.position.x * s
		out.append(Rect2(x, r.position.y * s, r.size.x * s, r.size.y * s))
	return out


func _blocked(r: Rect2, taken: Array) -> bool:
	for o in _occ():
		if (o as Rect2).intersects(r):
			return true
	for t in taken:
		if (t as Rect2).grow(3).intersects(r):
			return true
	return false


func _ui_scale() -> float:
	return size.y / 941.0


## Banners drawn this frame, top-most first: [{rect: Rect2 (screen px), id: city id}]. Clicks on them emit
## MapView.city_clicked (main.gd).
var banner_hits: Array = []
## Vector2i hex -> Color; set by MapView.highlight_tiles. Drawn as screen-space rims above the 3D city.
var highlights := {}


func banner_at(p: Vector2) -> String:
	for h in banner_hits:
		if (h["rect"] as Rect2).has_point(p):
			return h["id"]
	return ""


## k -> {label, color}; set by MapView.set_tile_labels
var tile_labels := {}
## k -> locked (bool); set by MapView.set_worked_tiles
var worked_tiles := {}


func _hex_screen(k: Vector2i) -> Variant:
	## screen position of a hex centre, or null when behind the camera / off-screen
	var c := TerrainMath.offset_center(k.x, k.y)
	var p3 := Vector3(c.x, maxf(0.0, renderer.height_at(c.x, c.y)) + 0.05, c.y)
	if cam.is_position_behind(p3):
		return null
	var sp := cam.unproject_position(p3)
	if not get_viewport_rect().grow(40).has_point(sp):
		return null
	return sp


func _draw_tile_markers() -> void:
	var s := _ui_scale()
	var font := ThemeDB.fallback_font
	for k in tile_labels:
		var sp = _hex_screen(k)
		if sp == null:
			continue
		var e: Dictionary = tile_labels[k]
		var col: Color = e["color"]
		var txt: String = L10n.t(str(e["label"]))   # ui-i18n: Hebrew labels (the fallback font has Hebrew via L10n)
		if txt == "":
			continue
		var fs := int(18 * s)
		var tw := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
		var r := Rect2(sp - Vector2(tw.x * 0.5 + 6 * s, tw.y * 0.5 + 1 * s), tw + Vector2(12 * s, 2 * s))
		draw_rect(r, Color(0.05, 0.05, 0.07, 0.78), true)
		draw_rect(r, Color(col.r, col.g, col.b, 0.95), false, 1.5)
		draw_string(font, sp + Vector2(-tw.x * 0.5, tw.y * 0.3), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(col.r, col.g, col.b, 1.0).lightened(0.35))
	for k in worked_tiles:
		var sp = _hex_screen(k)
		if sp == null:
			continue
		var locked: bool = worked_tiles[k]
		var rad := 11.0 * s
		var pos: Vector2 = sp + Vector2(0, 16 * s)
		var base := Color(1.0, 0.82, 0.25) if locked else Color(0.55, 0.85, 1.0)
		draw_circle(pos, rad + 2, Color(0, 0, 0, 0.7))
		draw_circle(pos, rad, Color(base.r * 0.35, base.g * 0.35, base.b * 0.35, 0.95))
		draw_arc(pos, rad, 0, TAU, 20, base, 2.0, true)
		draw_circle(pos + Vector2(0, -3 * s), 3.2 * s, base)                      # head
		draw_arc(pos + Vector2(0, 7 * s), 6 * s, PI * 1.1, PI * 1.9, 8, base, 2.2, true)   # shoulders
		if locked:
			draw_rect(Rect2(pos + Vector2(5 * s, 3 * s), Vector2(7 * s, 6 * s)), base, true)


func _is_convex(poly: PackedVector2Array) -> bool:
	var n := poly.size()
	var sgn := 0.0
	for i in n:
		var a := poly[i]; var b := poly[(i + 1) % n]; var c := poly[(i + 2) % n]
		var cr := (b - a).cross(c - b)
		if absf(cr) < 0.01:
			return false
		if sgn == 0.0:
			sgn = signf(cr)
		elif signf(cr) != sgn:
			return false
	return true


func _draw_highlights() -> void:
	if highlights.is_empty():
		return
	var vr_rect := get_viewport_rect()
	for k in highlights:
		var col: Color = highlights[k]
		var c := TerrainMath.offset_center(k.x, k.y)
		var pts := PackedVector2Array()
		var ok := true
		for i in 7:
			var a := deg_to_rad(30.0 + 60.0 * (i % 6))
			var w := c + Vector2(cos(a), sin(a)) * 0.97
			var p3 := Vector3(w.x, maxf(0.0, renderer.height_at(w.x, w.y)) + 0.02, w.y)
			if cam.is_position_behind(p3):
				ok = false
				break
			pts.append(cam.unproject_position(p3))
		if not ok:
			continue
		var fill := pts.duplicate()
		fill.remove_at(6)
		# skip off-screen hexes entirely (also avoids degenerate projections with no real camera)
		var bb := Rect2(fill[0], Vector2.ZERO)
		for fp in fill:
			bb = bb.expand(fp)
		if not bb.grow(8).intersects(vr_rect):
			continue
		# only fill convex, non-degenerate polygons: triangulate_polygon / draw_colored_polygon log errors otherwise
		if bb.size.x > 2.0 and bb.size.y > 2.0 and _is_convex(fill):
			draw_colored_polygon(fill, Color(col.r, col.g, col.b, 0.14 * col.a))
		draw_polyline(pts, Color(0, 0, 0, 0.45), 5.0, true)
		draw_polyline(pts, Color(col.r, col.g, col.b, 0.95), 2.6, true)


func _draw() -> void:
	if cam == null or renderer == null:
		return
	var s := _ui_scale()
	var cpos := cam.global_position
	var vr := get_viewport_rect()
	_draw_highlights()
	_draw_tile_markers()
	# resource pins
	for pin in renderer.resource_pins:
		var p: Vector3 = pin["pos"]
		var d := cpos.distance_to(p)
		if d > 40.0 or cam.is_position_behind(p):
			continue
		var sp := cam.unproject_position(p + Vector3(0, 0.05, 0))
		if not vr.grow(40).has_point(sp):
			continue
		var k := clampf(11.0 / d, 0.55, 1.25) * s
		var pr := Rect2(sp - Vector2(20, 40) * k, Vector2(40, 40) * k)
		if _blocked(pr, []):
			continue
		_pin(sp, k, String(pin["resource"]))
	# city banners: screen-space declutter, biggest cities first; nothing under HUD panels
	var cand := []
	for a in renderer.city_anchors:
		var city: Dictionary = a["city"]
		var p: Vector3 = a["pos"] + Vector3(0, 0.42 + 0.14 * int(city.get("size", 0)), 0)
		if cam.is_position_behind(p):
			continue
		var d := cpos.distance_to(p)
		if d > 70.0:
			continue
		var sp := cam.unproject_position(p)
		if not vr.grow(150).has_point(sp):
			continue
		var k := clampf(12.0 / d, 0.55, 1.0) * s
		cand.append([sp, k, city, int(city.get("pop", 0)) + int(city.get("size", 0)) * 1000000])
	cand.sort_custom(func(x, y): return x[3] > y[3])
	var taken := []
	var draw_list := []
	for c in cand:
		# above the city; if a HUD panel or another banner is in the way, try below it
		var placed := false
		var bw := _banner_rect(c[0], c[1], c[2]).size.x
		for off in [Vector2.ZERO, Vector2(0, 70), Vector2(0.6, 0), Vector2(-0.6, 0), Vector2(0.6, 70), Vector2(-0.6, 70)]:
			var sp: Vector2 = c[0] + Vector2(off.x * bw, off.y * c[1])
			var r := _banner_rect(sp, c[1], c[2])
			if not vr.encloses(r) or _blocked(r, taken):
				continue
			taken.append(r)
			draw_list.append([sp, c[1], c[2]])
			placed = true
			break
	banner_hits.clear()
	for c in draw_list:
		banner_hits.append({"rect": _banner_rect(c[0], c[1], c[2]), "id": str(c[2].get("id", ""))})
	draw_list.reverse()
	for c in draw_list:
		_banner(c[0], c[1], c[2])
	# world-space area / wonder labels (Label3D, group "map_area_label") give way to city banners
	for n in get_tree().get_nodes_in_group("map_area_label"):
		var l := n as Label3D
		if cam.is_position_behind(l.global_position):
			continue
		var sp := cam.unproject_position(l.global_position)
		var d := cpos.distance_to(l.global_position)
		var px := l.pixel_size * l.font_size * vr.size.y / (2.0 * tan(deg_to_rad(cam.fov) * 0.5))
		if not l.fixed_size:
			px /= maxf(d, 0.01)
		var lines := l.text.split("\n")
		var longest := 0
		for ln in lines:
			longest = maxi(longest, ln.length())
		var w := px * longest * 0.62
		var lh := px * 1.2 * lines.size()
		var rr := Rect2(sp.x - w * 0.5, sp.y - lh * 0.5, w, lh)
		var hit := false
		for t in taken:
			if (t as Rect2).intersects(rr):
				hit = true
				break
		if not hit:   # nor under a HUD panel (top bar, cards, action buttons, minimap, city panel; critic v3 B10)
			for o in _occ():
				if (o as Rect2).intersects(rr):
					hit = true
					break
		l.visible = not hit
	if show_tooltip and not hover_tile.is_empty():
		_tooltip(hover_screen + Vector2(18, 22) * s, s)


static func badge_for(city: Dictionary) -> String:
	## "israel" | "palestine" | "jordan" | ... with suffix "_beyond_lines" when Israeli-controlled outside the 1949 lines
	if city.has("badge"):
		return str(city["badge"])
	var control := str(city.get("control", "israel"))
	if control != "israel_occupied":
		return control
	var kind := str(city.get("kind", ""))
	var base := "palestine" if kind.contains("palestin") else ("syria" if kind.contains("syria") else "israel")
	return base + "_beyond_lines"


var _wonder_pos := {}


func _wonder_anchor(w: Dictionary) -> Vector3:
	var id := str(w.get("id", ""))
	if _wonder_pos.has(id):
		return _wonder_pos[id]
	var acc := Vector2.ZERO
	var hx: Array = w.get("hexes", [])
	for qr in hx:
		acc += TerrainMath.offset_center(int(qr[0]), int(qr[1]))
	acc /= maxf(1.0, hx.size())
	var p := Vector3(acc.x, maxf(0.0, renderer.height_at(acc.x, acc.y)) + 0.35, acc.y)
	_wonder_pos[id] = p
	return p


func _wonder_rect(sp: Vector2, k: float, w: Dictionary) -> Rect2:
	var fs := int(round(17 * k))
	var tw := UIKit.text_width(String(w.get("name", "")).to_upper(), "title", fs)
	var h := 28.0 * k
	return Rect2(sp.x - (tw + 50 * k) * 0.5, sp.y - h, tw + 50 * k, h)


func _wonder(sp: Vector2, k: float, w: Dictionary, r: Rect2) -> void:
	## Civ VI-style natural wonder label: teal plate, gold rim, star medallion
	var h := r.size.y
	var pts := UIKit.rrect_points(r, h * 0.5, 6)
	UIKit.gradient_poly(self, pts, Color(0.05, 0.30, 0.30, 0.94), Color(0.02, 0.16, 0.18, 0.94), r.position.y, r.end.y)
	var pl := pts.duplicate(); pl.append(pts[0])
	draw_polyline(pl, UIKit.GOLD_LIGHT, 1.5 * k, true)
	var mc := Vector2(r.position.x + h * 0.5, r.get_center().y)
	draw_circle(mc, h * 0.5 + 1.5 * k, Color(0.02, 0.12, 0.13))
	draw_arc(mc, h * 0.5 + 1.5 * k, 0, TAU, 24, UIKit.GOLD_LIGHT, 1.5 * k, true)
	var star := PackedVector2Array()
	for i in 10:
		var a := -PI / 2 + TAU * i / 10.0
		star.append(mc + Vector2(cos(a), sin(a)) * h * (0.36 if i % 2 == 0 else 0.15))
	draw_colored_polygon(star, UIKit.GOLD_LIGHT)
	UIKit.text(self, Vector2(r.position.x + h + 6 * k, r.get_center().y + 6 * k), String(w.get("name", "")).to_upper(), "title", int(round(17 * k)), Color(0.92, 1.0, 0.96))
	# pointer to the landform
	draw_colored_polygon(PackedVector2Array([Vector2(sp.x - 6 * k, r.end.y), Vector2(sp.x + 6 * k, r.end.y), Vector2(sp.x, r.end.y + 7 * k)]), Color(0.02, 0.16, 0.18, 0.94))


func _banner_rect(sp: Vector2, k: float, city: Dictionary) -> Rect2:
	var name_: String = String(city.get("name", "")).to_upper()
	var fs := int(round(20 * k))
	var w := UIKit.text_width(name_, "title", fs) + 118.0 * k
	var h := 34.0 * k
	var r := Rect2(sp.x - w * 0.5, sp.y - h, w, h)
	if String(city.get("id", "")) == "tel_aviv":
		r = r.grow_individual(0, 0, 0, 26 * k)
	return r


func _pin(sp: Vector2, k: float, res: String) -> void:
	var art := UIKit.tex("res://assets/icons/resource/%s.png" % RES_PIN.get(res, "res_wheat"))
	var sz := 38.0 * k
	if art:
		# art pins are medallions with the pointer at the bottom centre
		draw_texture_rect(art, Rect2(sp - Vector2(sz * 0.5, sz * 1.02), Vector2(sz, sz)), false)
		return
	var r := 17.0 * k
	var c := sp - Vector2(0, r + 8 * k)
	draw_circle(c, r, Color(0.04, 0.08, 0.18, 0.96))
	draw_arc(c, r, 0, TAU, 32, Color(0.85, 0.88, 0.95, 0.9), 1.6 * k, true)


func _banner(sp: Vector2, k: float, city: Dictionary) -> void:
	if k < 0.2:
		return
	var name_: String = String(city.get("name", "")).to_upper()
	var fs := int(round(20 * k))
	var tw := UIKit.text_width(name_, "title", fs)
	var h := 34.0 * k
	var w := tw + 118.0 * k
	var r := Rect2(sp.x - w * 0.5, sp.y - h, w, h)
	var pts := UIKit.rrect_points(r, h * 0.5, 6)
	for i in 3:
		draw_colored_polygon(UIKit.rrect_points(r.grow(1.5 + i * 2.0), h * 0.5 + 2 + i * 2.0, 6), Color(0, 0, 0, 0.12))
	UIKit.gradient_poly(self, pts, Color(0.07, 0.11, 0.22, 0.96), Color(0.02, 0.04, 0.10, 0.96), r.position.y, r.end.y)
	var pl := pts.duplicate(); pl.append(pts[0])
	draw_polyline(pl, UIKit.GOLD_LIGHT, 1.8 * k, true)
	# population circle
	var pc := Vector2(r.position.x + h * 0.5, r.get_center().y)
	draw_circle(pc, h * 0.5 + 1.5 * k, Color(0.03, 0.06, 0.14))
	draw_arc(pc, h * 0.5 + 1.5 * k, 0, TAU, 32, UIKit.GOLD_LIGHT, 1.8 * k, true)
	var pop := int(city.get("display_pop", 0))
	var pop_s := str(pop) if pop > 0 else "–"   # no sourced figure for this date
	UIKit.text(self, Vector2(pc.x - 20 * k, pc.y + 7 * k), pop_s, "body_bold", int(round(20 * k)), UIKit.TEXT, HORIZONTAL_ALIGNMENT_CENTER, 40 * k)
	# little skyline glyph
	var gx := r.position.x + h + 8 * k; var gy := r.get_center().y + 7 * k
	for b in [[0, 10, 4], [5, 14, 4], [10, 8, 4]]:
		draw_rect(Rect2(gx + b[0] * k, gy - b[1] * k, b[2] * k, b[1] * k), UIKit.TEXT)
	UIKit.text(self, Vector2(gx + 22 * k, r.get_center().y + 7 * k), name_, "title", fs, UIKit.TEXT, HORIZONTAL_ALIGNMENT_LEFT, -1, true)
	# star badge on the right
	var sc := Vector2(r.end.x - h * 0.5 - 2 * k, r.get_center().y)
	var civ := badge_for(city)
	var beyond := civ.ends_with("_beyond_lines")
	civ = civ.trim_suffix("_beyond_lines")
	if civ == "jordan":
		var fr := Rect2(sc - Vector2(h * 0.42, h * 0.28), Vector2(h * 0.84, h * 0.56))
		draw_circle(sc, h * 0.46, Color(0.92, 0.92, 0.92))
		for i in 3:
			draw_rect(Rect2(fr.position + Vector2(0, fr.size.y * i / 3.0), Vector2(fr.size.x, fr.size.y / 3.0)), [Color(0.08, 0.08, 0.08), Color(1, 1, 1), Color(0.0, 0.48, 0.24)][i])
		draw_colored_polygon(PackedVector2Array([fr.position, fr.position + Vector2(fr.size.x * 0.45, fr.size.y * 0.5), fr.position + Vector2(0, fr.size.y)]), Color(0.8, 0.07, 0.15))
		draw_rect(fr, Color(0.2, 0.2, 0.2), false, 1.0)
	elif civ == "israel":
		draw_circle(sc, h * 0.42, Color(0.85, 0.88, 0.95))
		UIKit.star_of_david(self, sc, h * 0.28, Color(0.12, 0.30, 0.75), 2.0 * k)
	else:
		# other polities: neutral coloured badge, no national symbol
		var bc: Color = CIV_COL.get(civ, Color(0.6, 0.6, 0.6))
		draw_circle(sc, h * 0.42, bc)
		draw_arc(sc, h * 0.42, 0, TAU, 24, Color(0.9, 0.9, 0.9), 1.5 * k, true)
	if beyond:
		# under Israeli control beyond the 1949 lines: dashed blue ring
		for i in 10:
			var a0 := TAU * i / 10.0
			draw_arc(sc, h * 0.52, a0, a0 + TAU / 20.0, 4, Color(0.35, 0.6, 1.0), 2.2 * k, true)
	# yield chips under the home city
	if String(city.get("id", "")) == "tel_aviv":
		var icons := ["production", "food", "culture_masks", "civics_columns"]
		var cw := 30.0 * k
		var row := Rect2(sp.x - cw * icons.size() * 0.5 - 4 * k, r.end.y + 1, cw * icons.size() + 8 * k, 24 * k)
		UIKit.gradient_poly(self, UIKit.rrect_points(row, 4 * k), Color(0.05, 0.09, 0.18, 0.95), Color(0.02, 0.04, 0.10, 0.95), row.position.y, row.end.y)
		for i in icons.size():
			UIKit.icon_at(self, icons[i], Vector2(row.position.x + 4 * k + cw * (i + 0.5), row.get_center().y), 19 * k)
		draw_colored_polygon(PackedVector2Array([Vector2(sp.x - 7 * k, row.end.y), Vector2(sp.x + 7 * k, row.end.y), Vector2(sp.x, row.end.y + 7 * k)]), Color(0.02, 0.04, 0.10, 0.95))


func _tooltip(pos: Vector2, s: float) -> void:
	var t := hover_tile
	var lines := []
	var terr := String(t.get("terrain", "?")).replace("_", " ").capitalize()
	var feat := String(t.get("feature", "none"))
	var title := terr + ("" if feat == "none" else " · " + feat.capitalize())
	lines.append(["title", title])
	lines.append(["body", "Region: " + String(t.get("region", "—"))])
	lines.append(["body", "Elevation: %d m" % int(t.get("elevation_m", 0))])
	var rv = t.get("resource", null)
	var res := "" if rv == null else str(rv)
	if res != "none" and res != "":
		lines.append(["body", "Resource: " + res.replace("_", " ").capitalize()])
	if t.get("river", false):
		lines.append(["body", "River"])
	lines.append(["dim", "Hex %d, %d   ·   %.2f°N %.2f°E" % [int(t["q"]), int(t["r"]), float(t.get("lat", 0)), float(t.get("lon", 0))]])
	var w := 0.0
	for l in lines:
		w = maxf(w, UIKit.text_width(l[1], "title" if l[0] == "title" else "body", int((15 if l[0] == "title" else 17) * s)))
	var r := Rect2(pos, Vector2(w + 28 * s, (18 + lines.size() * 21) * s))
	if r.end.x > size.x: r.position.x -= r.size.x + 40 * s
	if r.end.y > size.y: r.position.y -= r.size.y + 40 * s
	UIKit.panel(self, r, 5.0 * s)
	var y := r.position.y + 25 * s
	for l in lines:
		match l[0]:
			"title": UIKit.text(self, Vector2(r.position.x + 14 * s, y), l[1], "title", int(15 * s), UIKit.GOLD_LIGHT)
			"dim": UIKit.text(self, Vector2(r.position.x + 14 * s, y), l[1], "body", int(15 * s), UIKit.TEXT_DIM)
			_: UIKit.text(self, Vector2(r.position.x + 14 * s, y), l[1], "body", int(17 * s), UIKit.TEXT)
		y += 21 * s
