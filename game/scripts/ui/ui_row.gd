class_name UIRow
extends PanelContainer
## A clickable list row (any content). Emits `pressed(shift)` on left click and `right_pressed` on right click.

signal pressed(shift: bool)
signal right_pressed

var enabled := true
var selected := false
var accent := UIKit.BLUE
var _hover := false
var box: VBoxContainer


func _init(is_enabled := true, is_selected := false) -> void:
	enabled = is_enabled
	selected = is_selected
	mouse_filter = Control.MOUSE_FILTER_STOP
	box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(box)
	mouse_entered.connect(func(): _hover = true; _style())
	mouse_exited.connect(func(): _hover = false; _style())
	_style()
	if enabled:
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _ready() -> void:
	_ignore_mouse(box)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _style() -> void:
	var bg := Color(0.07, 0.12, 0.24, 0.95)
	var br := Color(0.32, 0.30, 0.25, 0.9)
	if not enabled:
		bg = Color(0.05, 0.06, 0.10, 0.85); br = Color(0.2, 0.2, 0.24)
	elif selected:
		bg = Color(0.14, 0.27, 0.52, 0.98); br = UIKit.GOLD_LIGHT
	elif _hover:
		bg = Color(0.11, 0.19, 0.37, 0.98); br = UIKit.GOLD
	var s := UITheme.sb(bg, br, 2 if selected else 1, 5, 9)
	add_theme_stylebox_override("panel", s)


func set_selected(v: bool) -> void:
	selected = v
	_style()


func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed:
		if e.button_index == MOUSE_BUTTON_LEFT and enabled:
			pressed.emit(e.shift_pressed)
			accept_event()
		elif e.button_index == MOUSE_BUTTON_RIGHT:
			right_pressed.emit()
			accept_event()


func add(c: Control) -> Control:
	_ignore_mouse(c)
	box.add_child(c)
	return c


func _ignore_mouse(c: Control) -> void:
	if not (c is Button):
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for ch in c.get_children():
		if ch is Control:
			_ignore_mouse(ch)


func hrow() -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 8)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(h)
	return h
