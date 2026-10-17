class_name HistoryTicker
extends PanelContainer
## Non-blocking "This quarter in history" side panel (left, under the VS. HISTORY chip): this turn's dated
## headlines, history's foundings grouped into one line, and the next dated events. Click a headline to read it.

var ui
var collapsed := false
var _items: Array = []
var _upcoming: Array = []
var _max := MAX_LINES
const BOTTOM := 652.0   # the bottom-left city panel starts at y 662 (1672x941 layout)
const MAX_LINES := 5   # headlines of at most two lines each: the panel stays above the city panel (16 px text)


func _init() -> void:
	theme = UITheme.get_theme()
	mouse_filter = Control.MOUSE_FILTER_STOP
	add_theme_stylebox_override("panel", UITheme.sb(Color(0.03, 0.06, 0.13, 0.88), Color(UIKit.GOLD_DARK, 0.9), 1, 6, 8))


func set_items(items: Array, upcoming: Array) -> void:
	_items = items
	_upcoming = upcoming
	_max = MAX_LINES
	_rebuild()


func _process(_d: float) -> void:
	# never run into the city panel below: drop headlines (they stay under "Read all") until it fits
	if visible and not collapsed and get_global_rect().end.y > get_viewport_rect().size.y * BOTTOM / 941.0 and _max > 1:   # (the HUD scales with the screen height)
		_max -= 1
		_rebuild()


func _rebuild() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 3)
	add_child(v)
	var head := HBoxContainer.new()
	v.add_child(head)
	var t := UITheme.title("THIS QUARTER IN HISTORY", 12, UIKit.GOLD_LIGHT)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(t)
	var tg := UITheme.button("+" if collapsed else "-", func(): collapsed = not collapsed; _rebuild(), 13)
	tg.custom_minimum_size = Vector2(24, 20)
	tg.tooltip_text = "Show / hide the history headlines"
	head.add_child(tg)
	if collapsed:
		return
	var events := []
	var founded := []
	var other := []
	for n in _items:
		match str(n.get("kind", "")):
			"event": events.append(n)
			"city_founded": founded.append(str(n.get("text", "")).split(" founded")[0])
			_: other.append(n)
	var lines := 0
	if events.is_empty() and founded.is_empty() and other.is_empty():
		v.add_child(UITheme.label("A quiet quarter.", 14, UIKit.TEXT_DIM))
	for n in events:
		if lines >= _max:
			break
		v.add_child(_line("• " + UITheme.humanise(str(n.get("text", ""))), str(n.get("event", ""))))
		lines += 1
	if founded.size() > 0 and lines < _max:
		var fl := UITheme.label("Founded on their historical dates: " + ", ".join(founded), 13, Color(0.75, 0.8, 0.9))
		fl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		fl.custom_minimum_size = Vector2(270, 0)
		_cap(fl)
		v.add_child(fl)
		lines += 1
	for n in other:
		if lines >= _max:
			break
		var ol := UITheme.label(UITheme.humanise(str(n.get("text", ""))), 13, Color(0.75, 0.8, 0.9))
		ol.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ol.custom_minimum_size = Vector2(270, 0)
		_cap(ol)
		v.add_child(ol)
		lines += 1
	var more := events.size() + other.size() + (1 if founded.size() > 0 else 0) - lines
	var rb := UITheme.button(("Read all (%d more)" % more) if more > 0 else "Read the quarter's history", func(): ui.open_panel("digest"), 13)
	v.add_child(rb)
	if _upcoming.size() > 0:
		v.add_child(UITheme.sep())
		v.add_child(UITheme.title("COMING UP", 11, UIKit.GOLD))
		var shown := 0
		for e in _upcoming:
			if shown >= (2 if _max >= 3 else 1):
				break
			var up_date := SimDB.date_label(int(e["turn"]))
			if L10n.lang == "en":
				up_date = up_date.replace(" ", char(0x2007))   # v4final (vet N4): Crimson Pro's space at 13 px read "Q41954"; a figure space keeps "Q4 1954" apart and on one line
			var ul := UITheme.label("%s  %s" % [up_date, str(e.get("title", ""))], 13, UIKit.TEXT_DIM)
			ul.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			ul.custom_minimum_size = Vector2(270, 0)
			_cap(ul, 1)
			v.add_child(ul)
			shown += 1


static func _cap(l: Label, n := 2) -> void:
	## At most n lines (an ellipsis ends a longer text; the whole text is on hover).
	l.max_lines_visible = n
	l.text_overrun_behavior = TextServer.OVERRUN_TRIM_WORD_ELLIPSIS   # on a word boundary (her minor 5: "0,000" cut mid-number)
	if l.tooltip_text == "":
		l.tooltip_text = l.text
	l.mouse_filter = Control.MOUSE_FILTER_PASS


func _line(text: String, eid: String) -> Control:
	var l := UITheme.label(text, 14, UIKit.TEXT)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(270, 0)
	_cap(l)
	l.mouse_filter = Control.MOUSE_FILTER_STOP
	l.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	l.tooltip_text = text.trim_prefix("• ") + "\n(click to read the event and its sources)"
	l.gui_input.connect(func(e):
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT and eid != "":
			ui.open_event(eid))
	return l
