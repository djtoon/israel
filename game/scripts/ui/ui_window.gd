class_name UIWindow
extends PanelContainer
## A gold-framed panel with a title bar and an optional close button. Subclasses fill `body`.

signal closed

var body: VBoxContainer
var title_label: Label
var close_btn: Button
var ui  # GameUI
var centered := false      # keep centred and shrink to content (set by GameUI for centre popups)
var pref_width := 600.0
var shift_x := 0.0         # centred windows: horizontal nudge (the advisor card docks beside the window)
## UI scale (Settings, 90-150%): every window is drawn at this scale, but never larger than fits the screen
## (a window that would not fit at the chosen scale is drawn as large as fits). Set by GameSettings.apply_scale().
static var ui_scale := 1.0
var dock := ""             # "left" | "right" | "unit": docked windows (GameUI._win); "" = centred or free
var dock_top := 54.0       # docked windows: space kept free above and below (the top bar, the action bar)
var dock_bottom := 30.0
const TOP_BAR := 52.0      # the HUD's top bar (46 px and its gold rule): centred windows start below it when they fit
## The unit panel's slot in the HUD's 1672x941 layout: right of the action bar, left of the minimap's toolbar (x 1388),
## its bottom above NEXT TURN (y 861). The panel fills the slot's width at any UI scale; a larger scale makes it taller.
const UNIT_SLOT_X := Vector2(1078.0, 1384.0)
const UNIT_SLOT_BOTTOM := 858.0
const UNIT_ACTIONS_END := 1066.0   # the action bar's right end (centred: on a narrower layout it comes closer)
const UNIT_SLOT_MIN := 290.0       # narrower than this (16:10, 4:3): the panel keeps its width and sits above the action bar
const UNIT_SLOT_RAISED := 818.0    # (as the combat preview does: the action circles start at y 824)
## Every window can be dragged by its title bar (double-click it to put the window back); closing resets the spot.
var drag_off := Vector2.ZERO
var _title_bar: HBoxContainer
var _dragging := false
var _drag_from := Vector2.ZERO
var _home := []           # offsets before the first drag (free and docked windows), restored on close


func _init(title_text := "", closable := true) -> void:
	theme = UITheme.get_theme()
	mouse_filter = Control.MOUSE_FILTER_STOP
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	add_child(v)
	var head := HBoxContainer.new()
	head.mouse_filter = Control.MOUSE_FILTER_STOP
	head.mouse_default_cursor_shape = Control.CURSOR_MOVE
	head.tooltip_text = "Drag to move · double-click to put back"
	head.gui_input.connect(_on_head_input)
	_title_bar = head
	v.add_child(head)
	title_label = UITheme.title(title_text.to_upper(), 22)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title_label)
	if closable:
		close_btn = UITheme.button("X", close, 16)
		close_btn.custom_minimum_size = Vector2(34, 30)
		close_btn.tooltip_text = "Close (Esc)"
		head.add_child(close_btn)
	v.add_child(UITheme.sep())
	body = VBoxContainer.new()
	body.add_theme_constant_override("separation", 6)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(body)


func _process(_d: float) -> void:
	if not visible:
		return
	if centered:
		_fit_centered()
		return
	if dock != "":
		_fit_docked()
	_keep_on_screen()


func view_size() -> Vector2:
	## The screen in this window's own (unscaled) units: what a window that sizes itself to the screen can use.
	return get_viewport_rect().size / maxf(ui_scale, 0.01)


func hud_k() -> float:
	## The HUD's scale (HUD._ref_scale: its 1672x941 layout is drawn at the screen's height, so on a 16:10 or 4:3 screen it
	## is larger than the window's own units). The spots windows keep free (the top bar, NEXT TURN, the action bar, the
	## unit slot) are in the HUD's units times this (layout-audit, 2026-10-17).
	return maxf(get_viewport_rect().size.y, 1.0) / 941.0


func fit_scale(w: float, h: float) -> float:
	var vp := get_viewport_rect().size
	if vp.x < 10.0 or vp.y < 10.0:
		return 1.0
	return clampf(minf(ui_scale, minf((vp.x - 12.0) / maxf(w, 1.0), (vp.y - 12.0) / maxf(h, 1.0))), 0.6, 2.0)


func _fit_centered() -> void:
	var ms := get_combined_minimum_size()
	var w := maxf(pref_width, ms.x)
	var h := ms.y
	var k := fit_scale(w, h)
	# keep the top bar (resources, date) visible: a tall window moves down as far as the room below allows (V3 fixes B2)
	var vp := get_viewport_rect().size
	var dy := 0.0
	if vp.y > 10.0:
		var top := vp.y * 0.5 - h * k * 0.5
		var below := vp.y - 4.0 - (vp.y * 0.5 + h * k * 0.5)
		var bar := TOP_BAR * hud_k()
		if top < bar:
			dy = clampf(bar - top, 0.0, maxf(0.0, below))
	if drag_off == Vector2.ZERO and (absf((offset_right - offset_left) - w) > 0.5 or absf((offset_bottom - offset_top) - h) > 0.5 or absf(offset_left - (-w * 0.5 + shift_x)) > 0.5 or absf(offset_top - (-h * 0.5 + dy)) > 0.5):
		offset_left = -w * 0.5 + shift_x; offset_right = w * 0.5 + shift_x
		offset_top = -h * 0.5 + dy; offset_bottom = h * 0.5 + dy
	if drag_off != Vector2.ZERO:   # moved by the player: the same centred size, shifted
		var want := Vector2(-w * 0.5 + shift_x, -h * 0.5 + dy) + drag_off
		if absf(offset_left - want.x) > 0.5 or absf(offset_top - want.y) > 0.5:
			offset_left = want.x; offset_right = want.x + w
			offset_top = want.y; offset_bottom = want.y + h
	var piv := Vector2(w, h) * 0.5
	if pivot_offset.distance_to(piv) > 0.5:
		pivot_offset = piv
	if absf(scale.x - k) > 0.001:
		scale = Vector2(k, k)


func _fit_docked() -> void:
	## Docked side panels keep their edge (left, right, bottom-right) and the free space above and below; at a larger
	## scale they are made shorter in their own units so the scaled panel still ends above the action bar.
	var vp := get_viewport_rect().size
	if vp.y < 10.0:
		return
	var hk := hud_k()   # (the free spots above and below are the HUD's, at its scale)
	var k := clampf(minf(ui_scale, vp.x * 0.55 / maxf(size.x, 1.0)), 0.6, 2.0)
	if dock == "unit":
		k = clampf(ui_scale, 0.6, 2.0)
	var piv := Vector2.ZERO
	match dock:
		"right": piv = Vector2(size.x, 0)
		"unit": piv = size
	if pivot_offset.distance_to(piv) > 0.5:
		pivot_offset = piv
	if dock in ["left", "right"]:
		var top := dock_top * hk
		var room := vp.y - top - dock_bottom * hk
		# a panel whose content is taller than its slot at this scale is drawn as large as fits (as centred windows are):
		# it never runs over the top bar or NEXT TURN
		var mh := get_combined_minimum_size().y
		if mh * k > room:
			k = clampf(room / maxf(mh, 1.0), 0.6, k)
		var want_top := top + drag_off.y
		var want_bottom := top + room / k - vp.y + drag_off.y
		if absf(offset_top - want_top) > 0.5:
			offset_top = want_top
		if absf(offset_bottom - want_bottom) > 0.5:
			offset_bottom = want_bottom
	elif dock == "unit":
		# the slot between the action bar and the minimap's toolbar, above NEXT TURN: its width at any scale (the content
		# wraps and the panel grows upwards)
		var dx := vp.x / hk - 1672.0   # the HUD layout's extra width (right-anchored parts move by dx, centred ones by dx / 2)
		var r_ref := UNIT_SLOT_X.y + dx
		var l_ref := maxf(UNIT_SLOT_X.x + dx, UNIT_ACTIONS_END + dx * 0.5)
		var b_ref := UNIT_SLOT_BOTTOM
		if r_ref - l_ref < UNIT_SLOT_MIN:
			l_ref = r_ref - (UNIT_SLOT_X.y - UNIT_SLOT_X.x)
			b_ref = UNIT_SLOT_RAISED
		var right := -(1672.0 - UNIT_SLOT_X.y) * hk + drag_off.x
		var w_own := (r_ref - l_ref) * hk / k
		var bottom := -(941.0 - b_ref) * hk + drag_off.y
		if absf(offset_right - right) > 0.5 or absf(offset_left - (right - w_own)) > 0.5 or absf(offset_bottom - bottom) > 0.5:
			offset_right = right
			offset_left = right - w_own
			offset_bottom = bottom
			offset_top = bottom
	if absf(scale.x - k) > 0.001:
		scale = Vector2(k, k)


func _keep_on_screen() -> void:
	## Nudge the window back inside the viewport if its content made it wider or taller than its slot.
	var vp := get_viewport_rect().size
	var r := get_global_rect()
	var dx := 0.0
	if r.end.x > vp.x - 4.0:
		dx = vp.x - 4.0 - r.end.x
	if r.position.x + dx < 4.0:
		dx = 4.0 - r.position.x
	if absf(dx) > 0.5:
		offset_left += dx; offset_right += dx
	if r.end.y > vp.y - 4.0 and r.position.y > 4.0:
		var dy := maxf(vp.y - 4.0 - r.end.y, 4.0 - r.position.y)
		offset_top += dy; offset_bottom += dy


func clear_body() -> void:
	for c in body.get_children():
		body.remove_child(c)
		c.queue_free()


func scroll_body(min_h := 300.0) -> VBoxContainer:
	## Adds a scroll area to the body and returns its inner VBox.
	var sc := ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sc.custom_minimum_size = Vector2(0, min_h)
	body.add_child(sc)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 6)
	sc.add_child(v)
	return v


func close() -> void:
	visible = false
	_reset_drag()
	closed.emit()


func _on_head_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and (e as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		var mb := e as InputEventMouseButton
		if mb.pressed and mb.double_click:
			_dragging = false
			_reset_drag()
		elif mb.pressed:
			if _home.is_empty() and not centered:
				_home = [offset_left, offset_top, offset_right, offset_bottom]
			_dragging = true
			_drag_from = get_global_mouse_position()
			if ui != null and ui.has_method("_front"):
				ui._front(self)
		else:
			_dragging = false
		accept_event()
	elif e is InputEventMouseMotion and _dragging:
		var now := get_global_mouse_position()
		var d := now - _drag_from
		# keep the title bar on screen
		var vp := get_viewport_rect().size
		var r := get_global_rect()
		d.x = clampf(d.x, 40.0 - r.end.x, vp.x - 40.0 - r.position.x)
		d.y = clampf(d.y, 4.0 - r.position.y, vp.y - 40.0 - r.position.y)
		_drag_from += d
		drag_off += d
		if not centered:   # centred windows re-place themselves from drag_off; the others move directly
			offset_left += d.x; offset_right += d.x
			offset_top += d.y; offset_bottom += d.y
		accept_event()


func _reset_drag() -> void:
	if not _home.is_empty():
		offset_left = _home[0]; offset_top = _home[1]; offset_right = _home[2]; offset_bottom = _home[3]
		_home = []
	drag_off = Vector2.ZERO


func refresh() -> void:
	pass
