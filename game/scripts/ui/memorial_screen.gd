class_name MemorialScreen
extends Control
## The end of the game (the user's decision, 2026-10-13): after the player ends the last turn (Q3 2023) the whole
## screen fades to black over 2.5 s and the music fades out (no stinger); the user's 7 October image fades in, dimmed. Over it, the memorial text of
## data/ending_oct7.json (or sim.get_ending_memorial()) is shown VERBATIM: its paragraphs fade in one by one, then the
## closing line "We will never forget." in larger type. After about 6 s a small Continue button appears (Enter or a
## click), which leads on to the results and epilogue screen.
## This is the one screen where the 7 October 2023 text appears: nothing here passes through UITheme.humanise(), tidy(),
## the BBCode palette or the Civilopedia's phrase guard, so the words show exactly as written.
## The demo (which ends in 1967) never shows it.

signal finished

const DATA := "res://data/ending_oct7.json"
const FADE := 2.5          # to black
const PARA_IN := 1.8       # each paragraph fades in
const PARA_GAP := 1.0      # pause between paragraphs
const BUTTON_AFTER := 6.0  # no button for this long after the closing line appears
const IMAGE_IN := 2.5      # the 7 October image fades in on the black
const IMAGE_HOLD := 1.5    # the image alone before the text
const IMAGE_DIM := 0.62    # image brightness under the text

var ui
var data := {}
var black: ColorRect
var box: VBoxContainer
var para_labels: Array[Label] = []
var closing_label: Label
var continue_btn: Button
var can_continue := false
var _done := false
var _audio_tween: Tween
var _bus_db := {}


static func load_data(sim) -> Dictionary:
	if sim != null and sim.has_method("get_ending_memorial"):
		var d = sim.get_ending_memorial()
		if d is Dictionary and not (d as Dictionary).is_empty():
			return d
	if FileAccess.file_exists(DATA):
		var j = JSON.parse_string(FileAccess.get_file_as_string(DATA))
		if j is Dictionary:
			return j
	return {}


static func applies(sim) -> bool:
	## Shown when the game ends at its last turn, never in the demo (which keeps its 1967 end).
	if Sim.is_demo():
		return false
	if sim != null and sim.get("collapse") != null and sim.collapse.ended():
		return false   # v3 item 13: a collapse of the state ends the game early; the memorial belongs to 7 October 2023 only
	var d := load_data(sim)
	return not d.is_empty() and not (d.get("paragraphs", []) as Array).is_empty()


func _init() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	theme = UITheme.get_theme()
	name = "Memorial"
	L10n.keep_ltr(self)   # the memorial reads as written (English, left to right) unless the user adds a translation


func play(d: Dictionary) -> void:
	data = d
	black = ColorRect.new()
	black.color = Color.BLACK
	black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	black.modulate.a = 0.0
	add_child(black)
	# the user's 7 October image (ref/7oct.png) fades in on the black, slightly dimmed so the text reads over it
	var img: TextureRect = null
	var ipath := str(d.get("image", ""))
	if ipath != "" and ResourceLoader.exists(ipath):
		img = TextureRect.new()
		img.texture = load(ipath)
		img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		img.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		img.mouse_filter = Control.MOUSE_FILTER_IGNORE
		img.modulate = Color(IMAGE_DIM, IMAGE_DIM, IMAGE_DIM, 0.0)
		add_child(img)
	var cc := CenterContainer.new()
	cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cc)
	box = VBoxContainer.new()
	box.custom_minimum_size = Vector2(minf(1040.0, get_viewport_rect().size.x - 120.0), 0)
	box.add_theme_constant_override("separation", 26)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cc.add_child(box)
	var text_col := Color(0.96, 0.93, 0.84)
	# the user's own words, never machine-translated: English unless ending_oct7.json has paragraphs_<lang>
	for p in L10n.memorial_paragraphs(d):
		var l := _text_label(str(p), 22, text_col, "body")
		para_labels.append(l)
		box.add_child(l)
	var close := str(d.get("closing_" + L10n.lang, d.get("closing", ""))) if L10n.lang != "en" and not (d.get("paragraphs_" + L10n.lang, []) as Array).is_empty() else str(d.get("closing", ""))
	if close != "":
		var sp := Control.new()
		sp.custom_minimum_size = Vector2(0, 12)
		box.add_child(sp)
		closing_label = _text_label(close, 38, UIKit.GOLD_LIGHT, "body_bold")
		box.add_child(closing_label)
	var bh := HBoxContainer.new()
	bh.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(bh)
	continue_btn = Button.new()
	continue_btn.text = "Continue"
	continue_btn.focus_mode = Control.FOCUS_NONE
	continue_btn.add_theme_font_override("font", UIKit.font("body"))
	continue_btn.add_theme_font_size_override("font_size", 18)
	continue_btn.add_theme_color_override("font_color", Color(0.80, 0.78, 0.72))
	continue_btn.add_theme_stylebox_override("normal", UITheme.sb(Color(0, 0, 0, 0), Color(0.45, 0.42, 0.36), 1, 4, 14))
	continue_btn.add_theme_stylebox_override("hover", UITheme.sb(Color(0.08, 0.08, 0.08), Color(0.75, 0.70, 0.60), 1, 4, 14))
	continue_btn.modulate.a = 0.0
	continue_btn.disabled = true
	continue_btn.pressed.connect(finish)
	bh.add_child(continue_btn)
	_fade_audio()
	var t := create_tween()
	t.tween_property(black, "modulate:a", 1.0, FADE)
	if img:
		t.tween_property(img, "modulate:a", 1.0, IMAGE_IN)
		t.tween_interval(IMAGE_HOLD)
	for l in para_labels:
		t.tween_property(l, "modulate:a", 1.0, PARA_IN)
		t.tween_interval(PARA_GAP)
	if closing_label:
		t.tween_property(closing_label, "modulate:a", 1.0, PARA_IN)
	t.tween_interval(BUTTON_AFTER)
	t.tween_callback(_show_continue)
	t.tween_property(continue_btn, "modulate:a", 1.0, 0.8)


func show_all_now() -> void:
	## Skip the fades (screenshots): black, image, text and button all shown at once.
	for c in get_children():
		if c is CanvasItem:
			(c as CanvasItem).modulate.a = 1.0
	for l in para_labels:
		l.modulate.a = 1.0
	if closing_label:
		closing_label.modulate.a = 1.0
	continue_btn.modulate.a = 1.0
	_show_continue()
	for t in get_tree().get_processed_tweens():
		t.kill()


func _text_label(s: String, size: int, col: Color, kind: String) -> Label:
	## Plain Label, never BBCode or humanise(): the text stays exactly as written.
	var l := L10n.raw_label(Label.new(), s) as Label   # verbatim in every language: never translated (L10n)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_override("font", UIKit.font(kind))
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	# drop shadow plus a soft dark outline, so the text reads over the image
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	l.add_theme_constant_override("shadow_offset_x", 3)
	l.add_theme_constant_override("shadow_offset_y", 3)
	l.add_theme_constant_override("shadow_outline_size", 8)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.75))
	l.add_theme_constant_override("outline_size", 4)
	l.modulate.a = 0.0
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _show_continue() -> void:
	can_continue = true
	continue_btn.disabled = false


func _fade_audio() -> void:
	## Music and ambience fade out with the picture; the saved levels come back on Continue.
	_audio_tween = create_tween().set_parallel(true)
	for b in ["Music", "Ambience"]:
		var i := AudioServer.get_bus_index(b)
		if i >= 0:
			_bus_db[b] = AudioServer.get_bus_volume_db(i)
			_audio_tween.tween_method(func(v: float): AudioServer.set_bus_volume_db(i, v), AudioServer.get_bus_volume_db(i), -60.0, FADE)


func _gui_input(e: InputEvent) -> void:
	if can_continue and e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		finish()


func _unhandled_key_input(e: InputEvent) -> void:
	if not (e is InputEventKey) or not e.pressed or e.echo:
		return
	get_viewport().set_input_as_handled()   # no game keys while the memorial is on screen
	if can_continue and (e as InputEventKey).keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_ESCAPE]:
		finish()


func shown_text() -> String:
	## The text on screen (paragraphs and the closing line), for the UI test.
	var parts := []
	for l in para_labels:
		parts.append(l.text)
	if closing_label:
		parts.append(closing_label.text)
	return "\n\n".join(parts)


func finish() -> void:
	if _done:
		return
	_done = true
	if _audio_tween and _audio_tween.is_valid():
		_audio_tween.kill()
	GameSettings.apply_audio()   # the player's own levels (the director then plays the end theme)
	finished.emit()
	queue_free()
