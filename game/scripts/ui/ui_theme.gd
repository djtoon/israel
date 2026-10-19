class_name UITheme
extends RefCounted
## Navy-and-gold Theme for Control-based panels (matches UIKit / the HUD look).

static var _theme: Theme
## Good / bad colours (Settings: standard red-green, or the colourblind-safe blue-orange of Okabe & Ito).
## BBCode in the code is written with the standard hexes; pal() swaps them when the colourblind palette is on.
const STD_GOOD := "#9fe07a"
const STD_BAD := "#ff8f7a"
const CB_GOOD := "#5fb8f0"     # sky blue
const CB_BAD := "#f5a03a"      # orange
static var GOOD_HEX := STD_GOOD
static var BAD_HEX := STD_BAD
static var colourblind := false
## Historian difficulty (sim.hints_enabled() false): no Recommended badges, history's choice hidden until after the pick.
static var show_hints := true
## Smallest font size in the UI (layout units, 1672x941). The UI scales with the window, so 16 here is 12.2 px on a
## 1280x720 screen: the legibility floor for body text (v2 visual critic).
const MIN_FONT := 16


static func sb(bg: Color, border := UIKit.GOLD, bw := 2, rad := 6, pad := 10.0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(bw)
	s.set_corner_radius_all(rad)
	s.content_margin_left = pad; s.content_margin_right = pad
	s.content_margin_top = pad * 0.6; s.content_margin_bottom = pad * 0.6
	s.anti_aliasing = true
	return s


static func get_theme() -> Theme:
	if _theme:
		return _theme
	var t := Theme.new()
	t.default_font = UIKit.font("body")
	t.default_font_size = 18
	# panels
	var panel := sb(Color(0.035, 0.065, 0.14, 0.97), UIKit.GOLD, 2, 8, 14)
	panel.shadow_color = Color(0, 0, 0, 0.45); panel.shadow_size = 10
	t.set_stylebox("panel", "PanelContainer", panel)
	t.set_stylebox("panel", "Panel", panel)
	# buttons
	var bn := sb(Color(0.08, 0.14, 0.28, 0.95), Color(0.45, 0.38, 0.22), 1, 5, 10)
	var bh := sb(Color(0.13, 0.22, 0.42, 0.98), UIKit.GOLD_LIGHT, 1, 5, 10)
	var bp := sb(Color(0.18, 0.32, 0.62, 1.0), UIKit.GOLD_LIGHT, 2, 5, 10)
	var bd := sb(Color(0.05, 0.07, 0.12, 0.85), Color(0.25, 0.25, 0.28), 1, 5, 10)
	var bf := sb(Color(0, 0, 0, 0), UIKit.GOLD_LIGHT, 1, 5, 10)
	t.set_stylebox("normal", "Button", bn)
	t.set_stylebox("hover", "Button", bh)
	t.set_stylebox("pressed", "Button", bp)
	t.set_stylebox("disabled", "Button", bd)
	t.set_stylebox("focus", "Button", bf)
	t.set_color("font_color", "Button", UIKit.TEXT)
	t.set_color("font_hover_color", "Button", Color.WHITE)
	t.set_color("font_pressed_color", "Button", Color.WHITE)
	t.set_color("font_disabled_color", "Button", Color(0.55, 0.56, 0.6))
	t.set_font("font", "Button", UIKit.font("body_bold"))
	t.set_font_size("font_size", "Button", 18)
	# labels
	t.set_color("font_color", "Label", UIKit.TEXT)
	# (web: no drop shadow, which draws every glyph of every Label twice; the panels behind the text are dark)
	t.set_color("font_shadow_color", "Label", Color(0, 0, 0, 0.0 if OS.has_feature("web") else 0.6))
	t.set_constant("shadow_offset_x", "Label", 1)
	t.set_constant("shadow_offset_y", "Label", 1)
	t.set_color("default_color", "RichTextLabel", UIKit.TEXT)
	t.set_font("normal_font", "RichTextLabel", UIKit.font("body"))
	t.set_font("bold_font", "RichTextLabel", UIKit.font("body_bold"))
	t.set_font_size("normal_font_size", "RichTextLabel", 18)
	t.set_font_size("bold_font_size", "RichTextLabel", 18)
	# scrollbars
	var grab := sb(Color(0.55, 0.45, 0.25, 0.9), Color(0, 0, 0, 0), 0, 4, 0)
	var grab_h := sb(UIKit.GOLD_LIGHT, Color(0, 0, 0, 0), 0, 4, 0)
	var track := sb(Color(0.02, 0.04, 0.09, 0.8), Color(0, 0, 0, 0), 0, 4, 0)
	track.content_margin_left = 5; track.content_margin_right = 5   # a visible bar: long lists show they scroll
	track.content_margin_top = 5; track.content_margin_bottom = 5
	for k in ["VScrollBar", "HScrollBar"]:
		t.set_stylebox("grabber", k, grab)
		t.set_stylebox("grabber_highlight", k, grab_h)
		t.set_stylebox("grabber_pressed", k, grab_h)
		t.set_stylebox("scroll", k, track)
	t.set_stylebox("panel", "ScrollContainer", StyleBoxEmpty.new())
	# option buttons and their popups (Settings)
	for k in ["OptionButton", "MenuButton"]:
		t.set_stylebox("normal", k, bn)
		t.set_stylebox("hover", k, bh)
		t.set_stylebox("pressed", k, bp)
		t.set_stylebox("disabled", k, bd)
		t.set_stylebox("focus", k, bf)
		t.set_color("font_color", k, UIKit.TEXT)
		t.set_color("font_hover_color", k, Color.WHITE)
		t.set_font("font", k, UIKit.font("body_bold"))
		t.set_font_size("font_size", k, 18)
	var pm := sb(Color(0.035, 0.065, 0.14, 0.99), UIKit.GOLD, 1, 4, 8)
	t.set_stylebox("panel", "PopupMenu", pm)
	t.set_stylebox("hover", "PopupMenu", sb(Color(0.16, 0.30, 0.55), UIKit.GOLD_LIGHT, 1, 3, 6))
	t.set_color("font_color", "PopupMenu", UIKit.TEXT)
	t.set_color("font_hover_color", "PopupMenu", Color.WHITE)
	t.set_color("font_disabled_color", "PopupMenu", Color(0.55, 0.56, 0.6))
	t.set_font("font", "PopupMenu", UIKit.font("body"))
	t.set_font_size("font_size", "PopupMenu", 18)
	t.set_stylebox("panel", "TooltipPanel", sb(Color(0.03, 0.06, 0.13, 0.97), UIKit.GOLD, 1, 4, 8))
	t.set_color("font_color", "TooltipLabel", UIKit.TEXT)
	t.set_font("font", "TooltipLabel", UIKit.font("body"))
	t.set_font_size("font_size", "TooltipLabel", 17)
	# sliders
	var sl := sb(Color(0.02, 0.04, 0.09, 0.9), Color(0.45, 0.38, 0.22), 1, 4, 0)
	sl.content_margin_top = 4; sl.content_margin_bottom = 4
	var sla := sb(Color(0.55, 0.45, 0.25, 0.95), Color(0, 0, 0, 0), 0, 4, 0)
	sla.content_margin_top = 4; sla.content_margin_bottom = 4
	t.set_stylebox("slider", "HSlider", sl)
	t.set_stylebox("grabber_area", "HSlider", sla)
	t.set_stylebox("grabber_area_highlight", "HSlider", sla)
	# check box
	t.set_color("font_color", "CheckBox", UIKit.TEXT)
	t.set_color("font_color", "CheckButton", UIKit.TEXT)
	_theme = t
	return t


static func set_palette(p: String) -> void:
	colourblind = p == "colourblind"
	GOOD_HEX = CB_GOOD if colourblind else STD_GOOD
	BAD_HEX = CB_BAD if colourblind else STD_BAD
	UIKit.GREEN = Color.html(CB_GOOD) if colourblind else Color(0.55, 0.85, 0.35)
	UIKit.BAD = Color.html(CB_BAD) if colourblind else Color(0.95, 0.52, 0.42)
	UIKit.WARN = Color.html("#f0e442") if colourblind else Color(1.0, 0.78, 0.36)
	UIKit.WARN_HI = Color.html("#e69f00") if colourblind else Color(1.0, 0.60, 0.24)


static func good_word() -> String:
	return "blue" if colourblind else "green"


static func bad_word() -> String:
	return "orange" if colourblind else "red"


static func pal(bb: String) -> String:
	## BBCode with the standard good/bad hexes -> the current palette (also the words "green" / "red" written
	## straight after such a colour tag, e.g. "[color=#9fe07a]green helps[/color]").
	if not colourblind or bb == "":
		return bb
	var out := bb
	if out.contains(STD_GOOD):
		out = out.replace("[color=%s]green" % STD_GOOD, "[color=%s]blue" % CB_GOOD).replace("[color=%s]Green" % STD_GOOD, "[color=%s]Blue" % CB_GOOD)
		out = out.replace(STD_GOOD, CB_GOOD)
	if out.contains("#ffc75c"):   # the "watch it" amber (UIKit.WARN): yellow in the colourblind palette
		out = out.replace("[color=#ffc75c]amber", "[color=#f0e442]yellow").replace("[color=#ffc75c]Amber", "[color=#f0e442]Yellow").replace("#ffc75c", "#f0e442")
	if out.contains(STD_BAD):
		out = out.replace("[color=%s]red" % STD_BAD, "[color=%s]orange" % CB_BAD).replace("[color=%s]Red" % STD_BAD, "[color=%s]Orange" % CB_BAD)
		out = out.replace(STD_BAD, CB_BAD)
	return out


static func good_col(good: bool) -> Color:
	return UIKit.GREEN if good else UIKit.BAD


static func label(text: String, size := 18, col := UIKit.TEXT, kind := "body") -> Label:
	var l := Label.new()
	l.text = text
	if L10n.rtl and size <= 14 and kind.begins_with("title"):
		kind = "title_sans"   # v4final (her minor 3): small headings in Hebrew in Noto Sans Hebrew (a legible zayin)
	l.add_theme_font_override("font", UIKit.font(kind))
	l.add_theme_font_size_override("font_size", maxi(size, MIN_FONT))
	l.add_theme_color_override("font_color", col)
	return l


static func title(text: String, size := 22, col := UIKit.GOLD_LIGHT) -> Label:
	return label(text, size, col, "title")


static func rich(bb: String, size := 18, fit := true) -> RichTextLabel:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = fit
	r.scroll_active = not fit
	size = maxi(size, MIN_FONT)
	r.add_theme_font_size_override("normal_font_size", size)
	r.add_theme_font_size_override("bold_font_size", size)
	r.add_theme_font_size_override("italics_font_size", size)
	r.add_theme_font_override("italics_font", UIKit.font("body"))
	r.text = pal(bb)
	r.mouse_filter = Control.MOUSE_FILTER_PASS
	return r


static func button(text: String, cb: Callable, size := 18) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size", maxi(size, MIN_FONT))
	b.pressed.connect(cb)
	b.pressed.connect(UIAudio.click)
	b.mouse_entered.connect(UIAudio.hover)
	b.focus_mode = Control.FOCUS_NONE
	return b


static func sep() -> HSeparator:
	var s := HSeparator.new()
	var st := StyleBoxLine.new()
	st.color = Color(UIKit.GOLD_DARK, 0.9)
	st.thickness = 1
	s.add_theme_stylebox_override("separator", st)
	return s


static func section(text: String) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", sb(Color(0.12, 0.22, 0.42, 0.95), UIKit.GOLD, 1, 4, 8))
	var l := title(text, 17, UIKit.TEXT)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	p.add_child(l)
	return p


static func icon(name: String, sz := 24) -> TextureRect:
	var tr := TextureRect.new()
	tr.texture = UIKit.icon(name)
	tr.custom_minimum_size = Vector2(sz, sz)
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return tr


static func fmt_num(v: float) -> String:
	var n := int(round(v))
	var neg := n < 0
	var s := str(absi(n))
	var out := ""
	while s.length() > 3:
		out = "," + s.substr(s.length() - 3) + out
		s = s.substr(0, s.length() - 3)
	return ("−" if neg else "") + s + out


static func fmt_signed(v: float, dec := 0) -> String:
	var s := ("%." + str(dec) + "f") % absf(v)
	return ("+" + s) if v >= 0 else ("−" + s)


static func pretty(id: String) -> String:
	return id.replace("_", " ").capitalize()


static func turns(n: int) -> String:
	## "1 turn" / "3 turns"
	return "%d turn%s" % [n, "" if absi(n) == 1 else "s"]


# words whose increase is bad for the player (inflation up = red, camps down = green)
const BAD_UP := ["inflation", "camp", "transit", "weariness", "debt", "deficit", "upkeep", "demand", "cost", "unemploy",
	"damage", "casualt", "killed", "displac", "emigra", "loss", "losses", "price", "interest", "repayment", "debt service",
	"strikes on", "town strike", "at risk", "wounded"]
const GOOD_WORDS := ["grows fast", "grows faster", "growth", "gains", "higher", "boost", "faster", "more jobs", "saves"]
const BAD_WORDS := ["slower", "lower", "loses", "fewer", "worse", "shortage", "starv", "strikes a front town"]
static var _num_re: RegEx
static var _key_re: RegEx


static func _signed_num(seg: String) -> int:
	## +1 / -1 for the first signed number in seg, 0 if none (unsigned or zero numbers are neutral).
	if _num_re == null:
		_num_re = RegEx.new()
		# a sign counts only at the start or after a space/bracket, so year spans ("1949-1953") stay neutral
		_num_re.compile("(?:^|[\\s(])([+\\-\u2212])\\s?(\\d[\\d,.]*)")
	var m := _num_re.search(seg)
	if m == null:
		return 0
	if float(m.get_string(2).replace(",", "")) == 0.0:
		return 0
	return 1 if m.get_string(1) == "+" else -1


static func effect_polarity(seg: String) -> int:
	## +1 good for the player, -1 bad, 0 neutral. Number sign, flipped for things that hurt when they go up.
	var low := seg.to_lower()
	var sgn := _signed_num(seg)
	var bad_up := false
	for w in BAD_UP:
		if low.contains(w):
			bad_up = true
			break
	if sgn != 0:
		return -sgn if bad_up else sgn
	for w in BAD_WORDS:
		if low.contains(w):
			return -1
	for w in GOOD_WORDS:
		if low.contains(w):
			return 1
	return 0


static func color_effects(text: String) -> String:
	## Colours each comma/semicolon-separated part of an effects line by whether it helps (green) or hurts (red).
	var t := humanise(text)
	var out := ""
	var seg := ""
	var i := 0
	while i < t.length():
		var ch := t[i]
		if (ch == "," or ch == ";") and (i + 1 >= t.length() or t[i + 1] == " ") and not (i > 0 and t[i - 1].is_valid_int() and i + 1 < t.length() and t[i + 1].is_valid_int()):
			var cs := _col_seg(seg)
			if cs != "":
				out += cs + ch
			seg = ""
		else:
			seg += ch
		i += 1
	var last := _col_seg(seg)
	if last == "" and out.ends_with(",") or last == "" and out.ends_with(";"):
		out = out.substr(0, out.length() - 1)
	return out + last


static func _col_seg(seg: String) -> String:
	if seg.strip_edges() == "":
		return seg
	if is_zero_term(seg):
		return ""
	match effect_polarity(seg):
		1: return "[color=#9fe07a]%s[/color]" % seg
		-1: return "[color=#ff8f7a]%s[/color]" % seg
	return "[color=#dfe3ec]%s[/color]" % seg


const KEY_WORDS := {"gold_per_turn": "gold per turn", "intl_standing": "international standing", "morale": "civic trust",
	"war_weariness": "war weariness", "per_turn": "per turn"}


static var _meta_res: Array = []


static func strip_meta(text: String) -> String:
	## Design notes that leak into player-facing text: "Civ VI: Campus.", "(Civ VI's Future Tech)", "like Civ VI governors".
	if not text.contains("Civ VI"):
		return text
	if _meta_res.is_empty():
		for pat in ["\\s*\\([^()]*Civ VI[^()]*\\)", "Civ VI( equivalent)?:\\s*[^.;\\n]*[.;]?\\s*", ",? like (a )?Civ VI governors?", "Civ VI'?s? "]:
			var re := RegEx.new()
			re.compile(pat)
			_meta_res.append(re)
	var out := text
	for re in _meta_res:
		out = (re as RegEx).sub(out, "", true)
	return out.replace("  ", " ").strip_edges()


static func humanise(text: String) -> String:
	## Replaces raw snake_case keys that leak from data into readable words (names for known ids).
	if _key_re == null:
		_key_re = RegEx.new()
		_key_re.compile("\\b[a-z]+(?:_[a-z0-9]+)+\\b")
	var out := strip_meta(text)
	for m in _key_re.search_all(out):
		var k := m.get_string()
		var rep: String = KEY_WORDS.get(k, "")
		if rep == "":
			var db := SimDB.get_db()
			for tbl in [db.techs, db.civics, db.buildings, db.districts, db.units, db.policies, db.projects]:
				if (tbl as Dictionary).has(k):
					rep = str(tbl[k].get("name", ""))
					break
		if rep == "":
			rep = k.replace("_", " ")
		out = out.replace(k, rep)
	return tidy(out)


static func clean_terms(t: String) -> String:
	## A lasting-terms line "<effect>, <years> (<reason>)": no leading dash (we draw our own bullet), humanised.
	## Shared by the event/fork popups, the ghost panel's Your Path / Ongoing terms tabs and the end screen.
	## Only the effect is coloured (green = good for the player, red = bad; inflation, camps and costs going
	## DOWN count as good); the dates and the reason stay neutral so their digits and words cannot flip it.
	var s := t.strip_edges()
	while s.begins_with("- ") or s.begins_with("* "):
		s = s.substr(2).strip_edges()
	s = humanise(turn_spans(s))
	var cut := -1
	var i := s.find(", ")
	while i >= 0:
		if i + 2 < s.length() and s[i + 2].is_valid_int():
			cut = i
			break
		i = s.find(", ", i + 2)
	if cut < 0:
		cut = s.find(" (")
	if cut < 0:
		return _col_seg(s)
	return _col_seg(s.substr(0, cut)) + "[color=#a8b0c4]%s[/color]" % s.substr(cut)


static func term_polarity(t: String) -> int:
	## +1 / -1 / 0 for a lasting-terms line, judged on its effect part only (see clean_terms).
	var f := clean_terms(t)
	if f.begins_with("[color=#9fe07a]"):
		return 1
	if f.begins_with("[color=#ff8f7a]"):
		return -1
	return 0


static var _span_re: RegEx
static var _one_re: RegEx


static func turn_spans(s: String) -> String:
	## Term spans written as raw turn numbers ("5-111", ", 40 (") become years ("1949–1975").
	if _span_re == null:
		_span_re = RegEx.new()
		_span_re.compile("(?<![\\d.])(\\d{1,4})\\s*[-–]\\s*(\\d{1,4})(?![\\d%])")
		_one_re = RegEx.new()
		_one_re.compile(", (\\d{1,3}) \\(")
	var out := ""
	var pos := 0
	for m in _span_re.search_all(s):
		var a := int(m.get_string(1)); var b := int(m.get_string(2))
		if a >= 1 and a <= 400 and (b <= 400 or b >= 1940) and b >= a or (a >= 1 and a <= 400 and b >= 1940):
			var ya := str(SimDB.year_of(a)) if a < 1000 else str(a)
			var yb := str(SimDB.year_of(b)) if b < 1000 else str(b)
			out += s.substr(pos, m.get_start() - pos) + (ya if ya == yb else ya + "–" + yb)
			pos = m.get_end()
	out += s.substr(pos)
	var out2 := ""
	pos = 0
	for m in _one_re.search_all(out):
		var t := int(m.get_string(1))
		out2 += out.substr(pos, m.get_start() - pos) + ", %d (" % SimDB.year_of(t)
		pos = m.get_end()
	return out2 + out.substr(pos)


static func ledger_matched(e: Dictionary) -> bool:
	## Path-ledger entry: did the player take the historical option? (sim: matched_history; older saves: historical bool)
	if e.has("matched_history"):
		return bool(e["matched_history"])
	var h = e.get("historical", false)
	if typeof(h) == TYPE_BOOL:
		return h
	return str(e.get("chosen", "")) == str(h)


static func has_bad_up(text: String) -> bool:
	var low := text.to_lower()
	for w in BAD_UP:
		if low.contains(w):
			return true
	return false


static func fx_good(e: Dictionary) -> bool:
	## Is a structured effect {stat, amount, label, good?} good for the player? Things that hurt when they rise (war
	## weariness, inflation, debt, casualties, demand) are judged on their label's sign, whatever the sim's flag says;
	## otherwise the sim's `good`, else the stat's direction.
	var lab := str(e.get("label", ""))
	if lab != "" and has_bad_up(lab):
		var pol := effect_polarity(lab)
		if pol != 0:
			return pol > 0
	if e.has("good"):
		return bool(e["good"])
	return stat_good(str(e.get("stat", "")) + " " + str(e.get("unit", "")), float(e.get("amount", 0)))


static func stat_good(stat: String, amount: float) -> bool:
	## Is a change of `amount` in `stat` good for the player? (inflation, camps, weariness, costs going down = good)
	var low := stat.to_lower()
	for w in BAD_UP:
		if low.contains(w):
			return amount <= 0
	return amount >= 0


static var _tidy_res := {}


static func _re(k: String, pat: String) -> RegEx:
	if not _tidy_res.has(k):
		var r := RegEx.new()
		r.compile(pat)
		_tidy_res[k] = r
	return _tidy_res[k]


static func _about(n: float) -> String:
	## A readable round figure: 74,173 -> "about 74,000"; 1,260 -> "about 1,300"; small figures stay exact.
	if n >= 10000.0:
		return "about " + fmt_num(roundf(n / 1000.0) * 1000.0)
	if n >= 1000.0:
		return "about " + fmt_num(roundf(n / 100.0) * 100.0)
	return fmt_num(n)


# locality status ids that reach notifications with only their underscores replaced
const STATUS_WORDS := {" (israel)": "", " (israel military government)": " (under military government)",
	" (israeli occupied)": " (under occupation)", " (israeli law applied)": " (Israeli law applied)",
	" (israel west only)": " (West Jerusalem)", " (israel with annexed east)": " (with East Jerusalem annexed)",
	" (israeli settlement)": " (settlement)", " (israeli controlled)": " (under Israeli control)",
	" (israeli forces present)": " (Israeli forces present)", "status changed to israel military government": "now under military government"}


static func tidy(text: String) -> String:
	## Player-facing number hygiene for text that comes ready-made from the sim or the data:
	##  - "housing room 335952" -> "housing room for about 336,000 people";
	##  - thousands separators (74173 -> 74,173; 4-digit numbers that are not years too), never inside ids (S5200);
	##  - no full-precision floats (0.123456 -> 0.12, 12.3456 -> 12.3);
	##  - no doubled parentheses ("(Operation Magic Carpet (Yemen))" -> "(Operation Magic Carpet, Yemen)").
	if text == "":
		return text
	var out := text
	if out.contains(" (isr") or out.contains("status changed"):
		for k in STATUS_WORDS:
			out = out.replace(k, STATUS_WORDS[k])
	# housing room in readable units
	var hr := _re("hr", "([Hh]ousing room)((?: in [^:()\\d]*?)?)(:?) (\\d{3,})")
	var acc := ""
	var pos := 0
	for m in hr.search_all(out):
		var n := float(m.get_string(4))
		var rep := "%s%s%s %s people" % [m.get_string(1), m.get_string(2), ":" if m.get_string(3) != "" else " for", _about(n)]
		acc += out.substr(pos, m.get_start() - pos) + rep
		pos = m.get_end()
	out = acc + out.substr(pos)
	# long floats
	var fl := _re("fl", "(?<![\\w.])(\\d+)\\.(\\d{3,})(?!\\d)")
	acc = ""; pos = 0
	for m in fl.search_all(out):
		var v := float(m.get_string(0))
		var rep2 := str(int(round(v))) if v >= 100.0 else ("%.1f" % v if v >= 1.0 else "%.2f" % v)
		acc += out.substr(pos, m.get_start() - pos) + rep2
		pos = m.get_end()
	out = acc + out.substr(pos)
	# thousands separators: 5+ digit integers, and 4-digit ones that are not years
	var th := _re("th", "(?<![\\w.,#])(\\d{4,})(?![\\d,]|\\.\\d)")
	acc = ""; pos = 0
	for m in th.search_all(out):
		var sdig := m.get_string(1)
		var rep3 := sdig
		var v2 := int(sdig)
		if sdig.length() >= 5 or (v2 >= 1000 and (v2 < 1800 or v2 > 2100)):
			rep3 = fmt_num(float(v2))
		acc += out.substr(pos, m.get_start() - pos) + rep3
		pos = m.get_end()
	out = acc + out.substr(pos)
	# doubled parentheses
	var nest := _re("nest", "\\(([^()]*)\\(([^()]*)\\)([^()]*)\\)")
	for it in 3:
		var ms := nest.search_all(out)
		if ms.is_empty():
			break
		acc = ""; pos = 0
		for m in ms:
			var a1 := m.get_string(1).strip_edges()
			var inner := (a1 + ", " if a1 != "" else "") + m.get_string(2).strip_edges() + m.get_string(3).rstrip(" ")
			acc += out.substr(pos, m.get_start() - pos) + "(" + inner + ")"
			pos = m.get_end()
		out = acc + out.substr(pos)
	return out


static func is_zero_term(t: String) -> bool:
	## A term or effect whose only figure is zero ("Standing +0", "+0.0 Gold per turn, 1949-1953"): not worth showing.
	var s := t.strip_edges()
	var cut := s.length()
	var c1 := s.find(" (")
	if c1 >= 0: cut = mini(cut, c1)
	var m2 := _re("span", ", \\d").search(s)
	if m2 != null: cut = mini(cut, m2.get_start())
	var eff := s.substr(0, cut)
	if _re("zero", "(?:^|[\\s(])[+\\-−]?0(?:\\.0+)?(?![\\d.])").search(eff) == null:
		return false
	return _re("nz", "[1-9]").search(eff) == null
