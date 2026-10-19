class_name WebVideoPlayer
extends Control
## Web build only: plays one of the start screen's videos as a WebM file in an HTML <video> element (the page's
## window.ibnVideo, build/web/shell/index.html) instead of a Theora VideoStreamPlayer, which Godot decodes on the CPU
## in WASM. It stands in for VideoStreamPlayer in StartScreen (same members: play, stop, finished, loop, volume_db,
## expand), so the intro sequence, the skip and the fades stay StartScreen's own.
##   - logo and intro: in front of the canvas; the menu loop: behind it (behind = true), seen through the canvas's
##     transparent pixels while the root viewport draws no 3D and a transparent background.
##   - volume: volume_db times the Master volume of the Settings (live).
##   - a video that cannot play ends at once (finished), so the sequence moves on; StartScreen then shows a still.
## The desktop never creates one (OS.has_feature("web") checks in StartScreen._video).

signal finished

const FILES := {"logo.ogv": "video/logo.webm", "intro.ogv": "video/intro.webm", "menu_loop.ogv": "video/menu.webm"}

var src := ""
var loop := false
var volume_db := 0.0
var expand := true
var behind := false
var failed := false
var _playing := false
var _js = null
var _vol := -1.0
var _was_transparent := false
var _was_no3d := false
var _hidden: Array = []   # CanvasLayers hidden while the menu loop plays behind the canvas


static func available() -> bool:
	if not OS.has_feature("web"):
		return false
	return str(JavaScriptBridge.eval("(window.ibnVideo && window.ibnVideo.supported()) ? 'yes' : 'no'", true)) == "yes"


static func for_path(path: String) -> WebVideoPlayer:
	## a player for res://assets/intro/<name>.ogv, or null when that video has no WebM
	var f: String = FILES.get(path.get_file(), "")
	if f == "":
		return null
	var w := WebVideoPlayer.new()
	w.src = f
	w.behind = path.get_file() == "menu_loop.ogv"
	w.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return w


func _api():
	if _js == null:
		_js = JavaScriptBridge.get_interface("ibnVideo")
	return _js


func _volume() -> float:
	var m := float(GameSettings.volumes.get("Master", 1.0)) if GameSettings.volumes.has("Master") else 1.0
	return clampf(db_to_linear(volume_db) * m, 0.0, 1.0) if volume_db > -79.0 else 0.0


func play() -> void:
	failed = false
	_playing = true
	_vol = _volume()
	if behind:
		var vp := get_viewport()
		_was_transparent = vp.transparent_bg
		_was_no3d = WorldView.is_3d_off(vp)
		vp.transparent_bg = true   # the menu loop shows through the canvas
		WorldView.show_3d(vp, false)       # (and the map is not drawn under it)
		# the 2D layers under the start screen (the HUD, the map labels) would show over the video: hidden meanwhile
		var mine := get_canvas_layer_node()
		var my_layer := mine.layer if mine else 0
		_hidden.clear()
		for c in get_tree().root.find_children("*", "CanvasLayer", true, false):
			var cl := c as CanvasLayer
			if cl != mine and cl.visible and cl.layer < my_layer:
				cl.visible = false
				_hidden.append(cl)
	_api().play(src, loop, _vol, behind)


func stop() -> void:
	if not _playing:
		return
	_playing = false
	_api().stop()
	_restore()


func _restore() -> void:
	if behind:
		var vp := get_viewport()
		if vp:
			vp.transparent_bg = _was_transparent
			WorldView.show_3d(vp, not _was_no3d)
		for cl in _hidden:
			if is_instance_valid(cl):
				cl.visible = true
		_hidden.clear()


func is_playing() -> bool:
	return _playing


func _process(_delta: float) -> void:
	if not _playing:
		return
	if not is_visible_in_tree():   # (the start screen closed or hid this video)
		stop()
		return
	var v := _volume()
	if absf(v - _vol) > 0.001:
		_vol = v
		_api().volume(v)
	var st := str(_api().state())
	if st == "ended" or st == "error":
		failed = st == "error"
		_playing = false
		if failed:
			print("web video: %s could not play" % src)
			_api().stop()
			_restore()
		finished.emit()


func _exit_tree() -> void:
	stop()
