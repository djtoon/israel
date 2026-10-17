class_name UIKit
extends RefCounted
## Shared HUD look: navy + gold palette, fonts, and draw helpers.

const NAVY_TOP := Color(0.075, 0.115, 0.215, 0.94)
const NAVY_BOT := Color(0.030, 0.055, 0.125, 0.96)
const NAVY_DEEP := Color(0.02, 0.04, 0.09, 0.97)
const GOLD := Color(0.80, 0.66, 0.38)
const GOLD_LIGHT := Color(0.97, 0.86, 0.56)
const GOLD_DARK := Color(0.45, 0.35, 0.18)
const TEXT := Color(0.96, 0.95, 0.91)
const TEXT_DIM := Color(0.78, 0.80, 0.86)
const BLUE := Color(0.25, 0.62, 0.98)
const PURPLE := Color(0.62, 0.40, 0.95)
static var GREEN := Color(0.55, 0.85, 0.35)   # "good" (palette: GameSettings / UITheme.set_palette)
static var BAD := Color(0.95, 0.52, 0.42)      # "bad"
static var WARN := Color(1.0, 0.78, 0.36)      # "watch it": amber (colourblind palette: Okabe-Ito yellow)
static var WARN_HI := Color(1.0, 0.60, 0.24)   # "act soon": orange, the fiscal indicator's warning tier (colourblind: Okabe-Ito orange)

static var _fonts := {}
static var _icons := {}


static func font(kind: String) -> Font:
	if _fonts.has(kind):
		return _fonts[kind]
	var f := FontVariation.new()
	match kind:
		"title":
			f.base_font = load("res://assets/fonts/Cinzel.ttf")
			f.variation_opentype = {"wght": 700}
			f.spacing_glyph = 1
		"title_wide":
			f.base_font = load("res://assets/fonts/Cinzel.ttf")
			f.variation_opentype = {"wght": 700}
			f.spacing_glyph = 4
		"title_reg":
			f.base_font = load("res://assets/fonts/Cinzel.ttf")
			f.variation_opentype = {"wght": 500}
			f.spacing_glyph = 1
		"body":
			f.base_font = load("res://assets/fonts/CrimsonPro.ttf")
			f.variation_opentype = {"wght": 560}
			f.opentype_features = {"lnum": 1}
		"body_bold", "bold_sans":
			f.base_font = load("res://assets/fonts/CrimsonPro.ttf")
			f.variation_opentype = {"wght": 700}
			f.opentype_features = {"lnum": 1}
		"title_sans":
			f.base_font = load("res://assets/fonts/Cinzel.ttf")
			f.variation_opentype = {"wght": 700}
			f.spacing_glyph = 1
		_:
			f.base_font = ThemeDB.fallback_font
	# Hebrew (L10n): Frank Ruhl Libre at the matching weight; Cinzel and Crimson Pro have no Hebrew letters.
	# v4final (her minor 3): the "_sans" kinds (small headings) take Noto Sans Hebrew instead: Frank Ruhl's bold zayin
	# reads as a vav at small sizes ("מזכיר" as "מוכיר"). English looks the same as title / body_bold.
	var w := int((f.variation_opentype as Dictionary).get("wght", 500))
	var hf := L10n.hebrew_font(clampi(w if not kind.ends_with("_sans") else 600, 400, 800), kind.ends_with("_sans"))
	if hf != null:
		f.fallbacks = [hf]
	_fonts[kind] = f
	return f


static func icon(name: String) -> Texture2D:
	if _icons.has(name):
		return _icons[name]
	var p := "res://assets/ui/icons/%s.png" % name
	var t: Texture2D = load(p) if ResourceLoader.exists(p) else null
	_icons[name] = t
	return t


static func tex(path: String) -> Texture2D:
	if _icons.has(path):
		return _icons[path]
	var t: Texture2D = load(path) if ResourceLoader.exists(path) else null
	_icons[path] = t
	return t


static func rrect_points(r: Rect2, rad: float, seg := 5) -> PackedVector2Array:
	var pts := PackedVector2Array()
	rad = minf(rad, minf(r.size.x, r.size.y) * 0.5)
	var cs := [Vector2(r.end.x - rad, r.position.y + rad), Vector2(r.end.x - rad, r.end.y - rad),
		Vector2(r.position.x + rad, r.end.y - rad), Vector2(r.position.x + rad, r.position.y + rad)]
	var a0 := [-PI / 2, 0.0, PI / 2, PI]
	for i in 4:
		for s in seg + 1:
			var a: float = a0[i] + (PI / 2) * s / seg
			var q: Vector2 = cs[i] + Vector2(cos(a), sin(a)) * rad
			if pts.is_empty() or pts[pts.size() - 1].distance_to(q) > 0.05:
				pts.append(q)
	if pts.size() > 2 and pts[0].distance_to(pts[pts.size() - 1]) < 0.05:
		pts.remove_at(pts.size() - 1)
	return pts


static func gradient_poly(ci: CanvasItem, pts: PackedVector2Array, top: Color, bot: Color, y0: float, y1: float) -> void:
	var cols := PackedColorArray()
	for p in pts:
		cols.append(top.lerp(bot, clampf((p.y - y0) / maxf(1.0, y1 - y0), 0.0, 1.0)))
	ci.draw_polygon(pts, cols)


static func panel(ci: CanvasItem, r: Rect2, rad := 6.0, top := NAVY_TOP, bot := NAVY_BOT, border := true) -> void:
	# soft drop shadow
	for i in 3:
		var g := r.grow(2.0 + i * 2.0)
		ci.draw_colored_polygon(rrect_points(g.grow_individual(0, 0, 0, 2), rad + 2 + i * 2), Color(0, 0, 0, 0.10))
	var pts := rrect_points(r, rad)
	gradient_poly(ci, pts, top, bot, r.position.y, r.end.y)
	if border:
		var pl := pts.duplicate(); pl.append(pts[0])
		ci.draw_polyline(pl, GOLD, 1.6, true)
		var inner := rrect_points(r.grow(-3.5), maxf(1.0, rad - 3))
		var il := inner.duplicate(); il.append(inner[0])
		ci.draw_polyline(il, Color(GOLD_DARK, 0.7), 1.0, true)


static func ring(ci: CanvasItem, c: Vector2, rad: float, width: float, col: Color, frac := 1.0, start := -PI / 2) -> void:
	if frac <= 0.0:
		return
	ci.draw_arc(c, rad, start, start + TAU * frac, 64, col, width, true)


static func bar(ci: CanvasItem, r: Rect2, frac: float, col: Color) -> void:
	ci.draw_rect(r, Color(0.0, 0.02, 0.06, 0.85))
	ci.draw_rect(r, Color(0.35, 0.40, 0.50, 0.5), false, 1.0)
	var f := Rect2(r.position, Vector2(r.size.x * clampf(frac, 0, 1), r.size.y))
	ci.draw_rect(f, col)
	ci.draw_rect(Rect2(f.position, Vector2(f.size.x, f.size.y * 0.4)), Color(1, 1, 1, 0.25))


static func text(ci: CanvasItem, pos: Vector2, s: String, kind: String, size: int, col := TEXT, align := HORIZONTAL_ALIGNMENT_LEFT, width := -1.0, shadow := true) -> void:
	## Custom-drawn text (HUD, map banners): translated here (L10n), measured the same way by text_width().
	s = L10n.t(s)
	var f := font(kind)
	if shadow:
		ci.draw_string(f, pos + Vector2(1, 1.5), s, align, width, size, Color(0, 0, 0, 0.75))
	ci.draw_string(f, pos, s, align, width, size, col)


static func text_width(s: String, kind: String, size: int) -> float:
	s = L10n.t(s)
	return font(kind).get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x


static func icon_at(ci: CanvasItem, name: String, c: Vector2, size: float, mod := Color.WHITE) -> void:
	var t := icon(name)
	if t:
		ci.draw_texture_rect(t, Rect2(c - Vector2(size, size) * 0.5, Vector2(size, size)), false, mod)


static func gold_circle(ci: CanvasItem, c: Vector2, rad: float, fill_top := NAVY_TOP, fill_bot := NAVY_DEEP) -> void:
	ci.draw_circle(c + Vector2(0, 2), rad + 3, Color(0, 0, 0, 0.35))
	var pts := PackedVector2Array(); var cols := PackedColorArray()
	for i in 40:
		var a := TAU * i / 40.0
		var p := c + Vector2(cos(a), sin(a)) * rad
		pts.append(p); cols.append(fill_top.lerp(fill_bot, (p.y - (c.y - rad)) / (2 * rad)))
	ci.draw_polygon(pts, cols)
	ci.draw_arc(c, rad, 0, TAU, 48, GOLD, 2.4, true)
	ci.draw_arc(c, rad - 3.0, 0, TAU, 48, Color(GOLD_DARK, 0.8), 1.0, true)
	ci.draw_arc(c, rad + 1.2, PI * 1.1, PI * 1.6, 16, Color(GOLD_LIGHT, 0.7), 1.2, true)


static func star_of_david(ci: CanvasItem, c: Vector2, rad: float, col: Color, width := 2.0) -> void:
	for k in 2:
		var pts := PackedVector2Array()
		for i in 4:
			var a := -PI / 2 + k * PI + TAU * i / 3.0
			pts.append(c + Vector2(cos(a), sin(a)) * rad)
		ci.draw_polyline(pts, col, width, true)
