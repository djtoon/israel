class_name LoadingScreen
extends CanvasLayer
## Short loading screen between screens (new game, load, back to the title): the view fades to dark navy,
## a small waving flag and "Loading..." in the game's title font sit in the bottom-right corner, the work
## runs, the map settles, and the view fades back in. Use: `await ui.loading.run(func(): ...)`.

const SHEET := "res://assets/ui/loading/loading_sheet.png"   # 16 frames of 256x256, from ref/loading.gif
const FRAMES := 16
const FRAME_TIME := 0.08
const ICON := 56.0
const FADE_IN := 0.25
const FADE_OUT := 0.4
const MIN_SHOW := 0.7      # seconds on screen at least, so it never just flickers

var _root: Control
var _icon: TextureRect
var _atlas: AtlasTexture
var _label: Label
var _t := 0.0
var _busy := false


func _ready() -> void:
	layer = 100
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.modulate.a = 0.0
	_root.visible = false
	add_child(_root)
	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.04, 0.09, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(bg)

	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	box.alignment = BoxContainer.ALIGNMENT_END
	box.anchor_left = 1.0; box.anchor_top = 1.0; box.anchor_right = 1.0; box.anchor_bottom = 1.0
	box.offset_left = -320; box.offset_right = -28
	box.offset_top = -ICON - 24; box.offset_bottom = -24
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(box)
	_label = Label.new()
	_label.text = "Loading..."
	_label.add_theme_font_override("font", UIKit.font("title"))
	_label.add_theme_font_size_override("font_size", 20)
	_label.add_theme_color_override("font_color", UIKit.GOLD_LIGHT)
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(_label)
	_icon = TextureRect.new()
	_icon.custom_minimum_size = Vector2(ICON, ICON)
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if ResourceLoader.exists(SHEET):
		_atlas = AtlasTexture.new()
		_atlas.atlas = load(SHEET)
		_atlas.region = Rect2(0, 0, 256, 256)
		_icon.texture = _atlas
	box.add_child(_icon)
	if "--ui-loading" in OS.get_cmdline_user_args():   # capture flag: show the loading screen for a screenshot
		_root.visible = true
		_root.modulate.a = 1.0


func _process(d: float) -> void:
	if not _root.visible or _atlas == null:
		return
	_t += d
	var f := int(_t / FRAME_TIME) % FRAMES
	_atlas.region = Rect2(f * 256, 0, 256, 256)


func _instant() -> bool:
	## Headless runs and UI tests skip the fade: their frames run much faster than real time.
	if DisplayServer.get_name() == "headless":
		return true
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--ui-test") or a.begins_with("--shot"):
			return true
	return false


func run(work: Callable, text := "Loading...") -> void:
	## Fade in, run `work`, let the map rebuild settle, fade out. Calls while already loading are ignored
	## (a double-click must not start the game twice).
	if _busy:
		return
	if _instant():
		work.call()
		return
	_busy = true
	_label.text = text
	_root.visible = true
	var shown := Time.get_ticks_msec()
	var t := create_tween()
	t.tween_property(_root, "modulate:a", 1.0, FADE_IN)
	await t.finished
	await get_tree().process_frame
	await get_tree().process_frame
	work.call()
	for i in 6:   # the map's date rebuild is deferred a couple of frames after the work
		await get_tree().process_frame
	var left := MIN_SHOW - (Time.get_ticks_msec() - shown) / 1000.0
	if left > 0.0:
		await get_tree().create_timer(left).timeout
	var t2 := create_tween()
	t2.tween_property(_root, "modulate:a", 0.0, FADE_OUT)
	await t2.finished
	_root.visible = false
	_busy = false
