class_name NotifyRail
extends VBoxContainer
## Right-hand notification stack (Civ VI NotificationPanel): newest at the bottom, just above the minimap.
## Left click acts (opens the event, city, tree); right click dismisses.

const ICONS := {"event": "star", "crisis": "diplomacy", "crisis_end": "diplomacy", "tech": "science", "civic": "civics_columns",
	"production": "production", "city_founded": "cities", "city_joined": "cities", "city_removed": "cities",
	"what_happened": "culture_masks", "boost": "research", "government": "civics_columns", "trade_route": "trade",
	"territory": "cities", "growth": "food", "moment": "star", "combat": "diplomacy", "unit": "production", "invalid": "happy", "blocked": "happy",
	"stat": "diplomacy", "terms": "gold", "immigration": "housing", "history_course": "culture_masks", "consequence": "culture_masks", "cabinet": "unlock_policy", "collapse": "diplomacy"}
const MAX_SHOWN := 3
const FADE_AFTER := 14.0   # seconds a card stays before fading (the event log keeps everything)

var ui
var items: Array = []


func _init() -> void:
	theme = UITheme.get_theme()
	alignment = BoxContainer.ALIGNMENT_END
	add_theme_constant_override("separation", 4)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


var _age := 0.0


func set_items(list: Array) -> void:
	items = list
	_age = 0.0
	modulate.a = 1.0
	_rebuild()


func _process(d: float) -> void:
	if items.is_empty():
		return
	_age += d
	if _age > FADE_AFTER:
		modulate.a = maxf(0.0, 1.0 - (_age - FADE_AFTER) / 1.5)
		if modulate.a <= 0.0:
			items = []
			_rebuild()
			modulate.a = 1.0


func _rebuild() -> void:
	for c in get_children():
		c.queue_free()
	var shown := items.slice(maxi(0, items.size() - MAX_SHOWN))
	if items.size() > MAX_SHOWN:
		var more := UITheme.label("+%d more in the log (L)" % (items.size() - MAX_SHOWN), 14, UIKit.TEXT_DIM)
		more.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		more.add_theme_stylebox_override("normal", UITheme.sb(Color(0.03, 0.06, 0.13, 0.9), Color(UIKit.GOLD_DARK, 0.8), 1, 5, 6))
		more.mouse_filter = Control.MOUSE_FILTER_STOP
		more.gui_input.connect(func(e):
			if e is InputEventMouseButton and e.pressed:
				ui.open_panel("log"))
		add_child(more)
	for n in shown:
		add_child(_card(n))


func _card(n: Dictionary) -> Control:
	var p := PanelContainer.new()
	var col := _kind_col(str(n.get("kind", "")))
	var st := UITheme.sb(Color(0.03, 0.06, 0.13, 0.93), col, 1, 6, 6)
	st.border_width_left = 4
	p.add_theme_stylebox_override("panel", st)
	p.mouse_filter = Control.MOUSE_FILTER_STOP
	p.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	p.tooltip_text = UITheme.humanise(str(n.get("text", ""))) + "\n(left click: open, right click: dismiss)"
	var h := HBoxContainer.new()
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_theme_constant_override("separation", 6)
	p.add_child(h)
	h.add_child(UITheme.icon(ICONS.get(str(n.get("kind", "")), "star"), 24))
	var l := UITheme.label(UITheme.humanise(str(n.get("text", ""))), 15, UIKit.TEXT)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.max_lines_visible = 2
	l.text_overrun_behavior = TextServer.OVERRUN_TRIM_WORD_ELLIPSIS   # on a word boundary (her minor 5: "0,000" cut mid-number)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(l)
	p.gui_input.connect(func(e):
		if e is InputEventMouseButton and e.pressed:
			if e.button_index == MOUSE_BUTTON_LEFT:
				_age = 0.0
				ui.on_notification(n)
			elif e.button_index == MOUSE_BUTTON_RIGHT:
				items.erase(n)
				_rebuild.call_deferred())
	return p


static func _kind_col(k: String) -> Color:
	match k:
		"event", "what_happened", "history_course", "consequence": return UIKit.GOLD
		"crisis", "combat", "collapse": return Color(0.95, 0.35, 0.30)
		"tech", "boost": return UIKit.BLUE
		"civic", "government": return UIKit.PURPLE
		"production", "city_founded", "city_joined": return Color(0.95, 0.65, 0.25)
		"invalid", "blocked": return Color(0.8, 0.3, 0.3)
	return Color(0.6, 0.65, 0.75)
