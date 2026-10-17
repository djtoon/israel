class_name UIFlags
extends Control
## A partner's flag, drawn (no image files), for diplomacy partners without a leader portrait for that year
## (V3 fixes B6 / the full-game critic's "EC/" and "(G" placeholders). Flags are simplified but follow the date
## (Egypt's and Syria's changes, Iran before and after 1979, the USSR / Russia, the EEC before its 1985 flag).
## Movements without a state flag (Hamas, Hezbollah) get a neutral emblem with clean initials.
##   var f := UIFlags.make("egypt", 1956, "Egypt", Vector2(46, 46))

var actor := ""
var year := 1948
var label := ""        # the actor's name (for the neutral emblem's initials)
var round_clip := true # drawn inside a circle (the ribbon avatar); false: a plain rectangle with a frame

const RED := Color(0.80, 0.10, 0.14)
const WHITE := Color(0.96, 0.96, 0.95)
const BLACK := Color(0.08, 0.08, 0.08)
const GREEN := Color(0.0, 0.48, 0.24)
const BLUE := Color(0.0, 0.20, 0.55)
const GOLD := Color(0.98, 0.78, 0.10)


static func make(a: String, y: int, name: String, sz: Vector2, round := true) -> UIFlags:
	var f := UIFlags.new()
	f.actor = a
	f.year = y
	f.label = name
	f.round_clip = round
	f.custom_minimum_size = sz
	f.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return f


static func has_flag(a: String) -> bool:
	return not a in ["hamas", "hezbollah", ""]


static func initials(name: String) -> String:
	## Clean initials of a name ("(West) Germany" -> "WG", "European Community / EU" -> "EC"): letters only.
	var s := ""
	var clean := name.split(" / ")[0].replace("(", " ").replace(")", " ").replace("'", "")
	for w in clean.split(" ", false):
		if w in ["of", "the", "and", "The", "People", "Peoples"]:
			continue
		var c := w.substr(0, 1)
		if c.to_upper() != c.to_lower():   # a letter
			s += c.to_upper()
	return s.substr(0, 3)


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	if round_clip:
		# the flag fills a square inset into the circle; a dark ring hides the corners
		var c := size * 0.5
		var rad := minf(size.x, size.y) * 0.5
		var fr := Rect2(c - Vector2(rad * 1.0, rad * 0.68), Vector2(rad * 2.0, rad * 1.36))
		draw_circle(c, rad, Color(0.05, 0.09, 0.18))
		_flag(fr)
		# mask the corners outside the circle with ring segments
		for i in 6:
			draw_arc(c, rad + i * 1.6, 0, TAU, 48, Color(0.05, 0.09, 0.18), 2.2, true)
		draw_arc(c, rad - 0.5, 0, TAU, 48, UIKit.GOLD, 1.2, true)
	else:
		_flag(r)
		draw_rect(r, Color(UIKit.GOLD_DARK, 0.9), false, 1.0)


func _hstripes(r: Rect2, cols: Array) -> void:
	for i in cols.size():
		draw_rect(Rect2(r.position + Vector2(0, r.size.y * i / cols.size()), Vector2(r.size.x, r.size.y / cols.size() + 0.5)), cols[i])


func _vstripes(r: Rect2, cols: Array) -> void:
	for i in cols.size():
		draw_rect(Rect2(r.position + Vector2(r.size.x * i / cols.size(), 0), Vector2(r.size.x / cols.size() + 0.5, r.size.y)), cols[i])


func _star(c: Vector2, rad: float, col: Color, points := 5) -> void:
	var pts := PackedVector2Array()
	for i in points * 2:
		var a := -PI / 2.0 + PI * i / points
		pts.append(c + Vector2(cos(a), sin(a)) * (rad if i % 2 == 0 else rad * 0.42))
	draw_colored_polygon(pts, col)


func _crescent(c: Vector2, rad: float, col: Color, bg: Color, dx := 0.32) -> void:
	draw_circle(c, rad, col)
	draw_circle(c + Vector2(rad * dx, 0), rad * 0.80, bg)


func _hoist_triangle(r: Rect2, col: Color, depth := 0.45) -> void:
	draw_colored_polygon(PackedVector2Array([r.position, r.position + Vector2(r.size.x * depth, r.size.y * 0.5), r.position + Vector2(0, r.size.y)]), col)


func _flag(r: Rect2) -> void:
	var h := r.size.y
	var c := r.get_center()
	match actor:
		"usa":
			for i in 13:
				draw_rect(Rect2(r.position + Vector2(0, h * i / 13.0), Vector2(r.size.x, h / 13.0 + 0.5)), RED if i % 2 == 0 else WHITE)
			var cant := Rect2(r.position, Vector2(r.size.x * 0.42, h * 7.0 / 13.0))
			draw_rect(cant, Color(0.15, 0.20, 0.45))
			for i in 3:
				for j in 3:
					draw_circle(cant.position + Vector2(cant.size.x * (0.2 + 0.3 * j), cant.size.y * (0.2 + 0.3 * i)), maxf(0.8, h * 0.025), WHITE)
		"uk":
			draw_rect(r, Color(0.0, 0.14, 0.45))
			var w := h * 0.14
			draw_line(r.position, r.end, WHITE, w * 1.4)
			draw_line(Vector2(r.position.x, r.end.y), Vector2(r.end.x, r.position.y), WHITE, w * 1.4)
			draw_line(r.position, r.end, RED, w * 0.5)
			draw_line(Vector2(r.position.x, r.end.y), Vector2(r.end.x, r.position.y), RED, w * 0.5)
			draw_rect(Rect2(Vector2(r.position.x, c.y - w * 1.1), Vector2(r.size.x, w * 2.2)), WHITE)
			draw_rect(Rect2(Vector2(c.x - w * 1.1, r.position.y), Vector2(w * 2.2, h)), WHITE)
			draw_rect(Rect2(Vector2(r.position.x, c.y - w * 0.65), Vector2(r.size.x, w * 1.3)), RED)
			draw_rect(Rect2(Vector2(c.x - w * 0.65, r.position.y), Vector2(w * 1.3, h)), RED)
		"france":
			_vstripes(r, [Color(0.0, 0.14, 0.58), WHITE, Color(0.94, 0.16, 0.18)])
		"west_germany", "germany":
			_hstripes(r, [BLACK, Color(0.86, 0.0, 0.0), Color(1.0, 0.80, 0.0)])
		"ussr", "russia":
			if year >= 1992:
				_hstripes(r, [WHITE, Color(0.0, 0.22, 0.65), Color(0.84, 0.17, 0.12)])
			else:
				draw_rect(r, Color(0.80, 0.0, 0.0))
				_star(r.position + Vector2(r.size.x * 0.2, h * 0.22), h * 0.11, GOLD)
				draw_arc(r.position + Vector2(r.size.x * 0.2, h * 0.48), h * 0.11, PI * 0.1, PI * 1.2, 12, GOLD, maxf(1.0, h * 0.05))
		"egypt":
			if year < 1953:   # the Kingdom: green, a white crescent and three stars
				draw_rect(r, Color(0.0, 0.50, 0.16))
				_crescent(c + Vector2(-h * 0.06, 0), h * 0.26, WHITE, Color(0.0, 0.50, 0.16))
				for i in 3:
					_star(c + Vector2(h * 0.12, (i - 1) * h * 0.16), h * 0.06, WHITE)
			else:
				_hstripes(r, [Color(0.81, 0.07, 0.15), WHITE, BLACK])
				if year >= 1958 and year < 1972:   # the United Arab Republic: two green stars
					_star(c + Vector2(-h * 0.22, 0), h * 0.12, GREEN)
					_star(c + Vector2(h * 0.22, 0), h * 0.12, GREEN)
				else:   # the eagle (1953-58, from 1984) or the hawk (1972-84): a gold emblem
					draw_circle(c, h * 0.13, Color(0.78, 0.60, 0.15))
		"syria":
			if year < 1958 or (year >= 1961 and year < 1963):   # the independence flag
				_hstripes(r, [GREEN, WHITE, BLACK])
				for i in 3:
					_star(c + Vector2((i - 1) * h * 0.32, 0), h * 0.10, RED)
			else:
				_hstripes(r, [Color(0.81, 0.07, 0.15), WHITE, BLACK])
				if year >= 1972 and year < 1980:
					draw_circle(c, h * 0.13, Color(0.78, 0.60, 0.15))
				elif year >= 1963 and year < 1972:
					for i in 3:
						_star(c + Vector2((i - 1) * h * 0.32, 0), h * 0.10, GREEN)
				else:
					_star(c + Vector2(-h * 0.22, 0), h * 0.12, GREEN)
					_star(c + Vector2(h * 0.22, 0), h * 0.12, GREEN)
		"jordan":
			_hstripes(r, [BLACK, WHITE, GREEN])
			_hoist_triangle(r, Color(0.81, 0.07, 0.15), 0.5)
			_star(r.position + Vector2(r.size.x * 0.17, h * 0.5), h * 0.07, WHITE, 7)
		"lebanon":
			_hstripes(r, [RED, WHITE, WHITE, RED])
			draw_colored_polygon(PackedVector2Array([c + Vector2(0, -h * 0.22), c + Vector2(h * 0.2, h * 0.16), c + Vector2(-h * 0.2, h * 0.16)]), Color(0.0, 0.62, 0.26))
		"iraq":
			_hstripes(r, [Color(0.81, 0.07, 0.15), WHITE, BLACK])
			if year >= 1963:
				for i in 3:
					_star(c + Vector2((i - 1) * h * 0.3, 0), h * 0.09, GREEN)
		"iran":
			_hstripes(r, [Color(0.14, 0.62, 0.25), WHITE, Color(0.85, 0.12, 0.14)])
			if year < 1979:
				draw_circle(c, h * 0.11, Color(0.80, 0.62, 0.15))   # the lion and sun
			else:
				draw_arc(c, h * 0.10, 0, TAU, 16, Color(0.85, 0.12, 0.14), maxf(1.0, h * 0.05))
		"plo", "palestinian_authority", "pa":
			_hstripes(r, [BLACK, WHITE, Color(0.0, 0.48, 0.23)])
			_hoist_triangle(r, Color(0.81, 0.07, 0.15), 0.42)
		"turkey":
			draw_rect(r, Color(0.89, 0.04, 0.09))
			_crescent(c + Vector2(-h * 0.12, 0), h * 0.25, WHITE, Color(0.89, 0.04, 0.09))
			_star(c + Vector2(h * 0.2, 0), h * 0.09, WHITE)
		"un":
			draw_rect(r, Color(0.36, 0.61, 0.84))
			draw_arc(c, h * 0.28, 0, TAU, 32, WHITE, maxf(1.0, h * 0.05), true)
			draw_arc(c, h * 0.16, 0, TAU, 24, WHITE, maxf(1.0, h * 0.04), true)
			draw_line(c + Vector2(-h * 0.28, 0), c + Vector2(h * 0.28, 0), WHITE, maxf(1.0, h * 0.03))
			draw_line(c + Vector2(0, -h * 0.28), c + Vector2(0, h * 0.28), WHITE, maxf(1.0, h * 0.03))
		"eec_eu":
			draw_rect(r, Color(0.0, 0.20, 0.60))
			if year >= 1986:   # the European flag, used by the Community from 1986
				for i in 12:
					var a := TAU * i / 12.0
					_star(c + Vector2(cos(a), sin(a)) * h * 0.32, h * 0.06, Color(1.0, 0.80, 0.0))
			else:   # before it: a plain gold ring
				draw_arc(c, h * 0.28, 0, TAU, 32, Color(1.0, 0.80, 0.0), maxf(1.0, h * 0.06), true)
		"uae":
			_hstripes(r, [Color(0.0, 0.45, 0.18), WHITE, BLACK])
			draw_rect(Rect2(r.position, Vector2(r.size.x * 0.26, h)), Color(0.80, 0.07, 0.15))
		"bahrain":
			draw_rect(r, Color(0.81, 0.07, 0.15))
			var pts := PackedVector2Array([r.position, r.position + Vector2(r.size.x * 0.25, 0)])
			for i in 10:
				pts.append(r.position + Vector2(r.size.x * (0.38 if i % 2 == 0 else 0.25), h * (i + 0.5) / 10.0))
			pts.append(r.position + Vector2(r.size.x * 0.25, h))
			pts.append(r.position + Vector2(0, h))
			draw_colored_polygon(pts, WHITE)
		"qatar":
			draw_rect(r, Color(0.54, 0.08, 0.24))
			draw_rect(Rect2(r.position, Vector2(r.size.x * 0.3, h)), WHITE)
		"sudan":
			_hstripes(r, [Color(0.81, 0.07, 0.15), WHITE, BLACK])
			_hoist_triangle(r, Color(0.0, 0.45, 0.20), 0.36)
		"morocco":
			draw_rect(r, Color(0.76, 0.09, 0.15))
			var pts2 := PackedVector2Array()
			for i in 5:
				var a := -PI / 2.0 + TAU * (i * 2 % 5) / 5.0
				pts2.append(c + Vector2(cos(a), sin(a)) * h * 0.26)
			pts2.append(pts2[0])
			draw_polyline(pts2, Color(0.0, 0.42, 0.22), maxf(1.0, h * 0.05), true)
		"saudi_arabia":
			draw_rect(r, Color(0.0, 0.42, 0.21))
			draw_rect(Rect2(c + Vector2(-h * 0.36, -h * 0.12), Vector2(h * 0.72, h * 0.08)), WHITE)
			draw_line(c + Vector2(-h * 0.36, h * 0.16), c + Vector2(h * 0.36, h * 0.16), WHITE, maxf(1.0, h * 0.04))
		"china":
			draw_rect(r, Color(0.87, 0.16, 0.06))
			_star(r.position + Vector2(r.size.x * 0.17, h * 0.27), h * 0.13, Color(1.0, 0.87, 0.0))
			for i in 4:
				_star(r.position + Vector2(r.size.x * (0.32 + 0.04 * (i % 2)), h * (0.12 + 0.11 * i)), h * 0.04, Color(1.0, 0.87, 0.0))
		"india":
			_hstripes(r, [Color(1.0, 0.60, 0.20), WHITE, Color(0.07, 0.53, 0.03)])
			draw_arc(c, h * 0.12, 0, TAU, 20, Color(0.0, 0.0, 0.5), maxf(1.0, h * 0.03), true)
		_:
			# movements and bodies without a state flag: a neutral disc with clean initials (no national symbol)
			draw_rect(r, Color(0.16, 0.20, 0.30))
			var ini := initials(label if label != "" else actor)
			var fs := int(clampf(h * 0.42, 9, 60))
			UIKit.text(self, Vector2(r.position.x, c.y + fs * 0.36), ini, "title", fs, UIKit.GOLD_LIGHT, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
