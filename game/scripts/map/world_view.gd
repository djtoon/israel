class_name WorldView
extends Node
## web: the 3D map at a lower resolution than the page, the 2D UI at full resolution. The Compatibility renderer
## (WebGL) has no 3D render scale of its own (Viewport.scaling_3d_scale does nothing there), so the map is drawn by a
## second camera into a SubViewport of the same World3D at a fraction of the window's pixels and shown stretched on a
## canvas layer below every UI layer; the HUD, the map labels and the windows stay sharp.
## The game's own camera (CameraRig.cam) stays the current camera of the window: picking, hover, drag-pan, the map
## labels' unproject and the minimap all keep working in window coordinates, unchanged. Only this node's camera copies
## it every frame (the last thing before the frame is drawn). The window itself draws no 3D while a WorldView is on.
## GfxTier's "world_scale" lever (web_low) turns it on; 1.0 (or the desktop game) never creates one.

static var current: WorldView = null   # the active one (null = the window draws the 3D itself, as always)

var k := 1.0
var src: Camera3D
var sub: SubViewport
var cam: Camera3D
var layer: CanvasLayer
var rect: TextureRect
var _off := false   # the game's "no 3D now" (menu still, videos): the SubViewport stops drawing


static func apply(game: Node, scale: float) -> void:
	## the map's 3D resolution as a fraction of the window's pixels: below 1 a WorldView, 1 the window's own 3D
	if game == null or not game.is_inside_tree():
		return
	var rig = game.get("rig")
	if scale >= 0.999 or rig == null:
		if current != null and is_instance_valid(current):
			current._remove()
		return
	if current == null or not is_instance_valid(current):
		var wv := WorldView.new()
		wv.name = "WorldView"
		wv.src = rig.cam
		game.add_child(wv)
		current = wv
	current.k = scale
	current._resize()


static func show_3d(vp: Viewport, on: bool) -> void:
	## the game's switch for the map's 3D (menu still, the WebM videos, the web warm-up): the SubViewport's while a
	## WorldView is on (the window draws no 3D then), else the window's own, as before
	if current != null and is_instance_valid(current) and vp == current.get_viewport():
		current._set_off(not on)
	else:
		vp.disable_3d = not on


static func is_3d_off(vp: Viewport) -> bool:
	if current != null and is_instance_valid(current) and vp == current.get_viewport():
		return current._off
	return vp.disable_3d


static func render_rid(vp: Viewport) -> RID:
	## the viewport that draws the 3D map (render info, timings)
	if current != null and is_instance_valid(current) and vp == current.get_viewport():
		return current.sub.get_viewport_rid()
	return vp.get_viewport_rid()


func _ready() -> void:
	var root := get_viewport()
	_off = root.disable_3d
	sub = _new_sub(_target_size())
	layer = CanvasLayer.new()
	layer.name = "WorldLayer"
	layer.layer = -100   # below the map labels (1), the HUD (2) and every window
	add_child(layer)
	rect = TextureRect.new()
	rect.texture = sub.get_texture()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(rect)
	_set_off(_off)
	root.disable_3d = true
	root.size_changed.connect(_resize)
	RenderingServer.frame_pre_draw.connect(_pre_draw)
	process_priority = 1 << 20   # after the camera rig and everything else that moves the camera
	_sync()
	_resize()


func _set_off(off: bool) -> void:
	## no 3D: the SubViewport stops drawing and its picture is hidden (the window's clear colour, as before)
	_off = off
	sub.disable_3d = off
	sub.render_target_update_mode = SubViewport.UPDATE_DISABLED if off else SubViewport.UPDATE_ALWAYS
	layer.visible = not off


func _remove() -> void:
	if current == self:
		current = null
	set_process(false)   # (no _sync until it is freed: its guard would switch the window's 3D off again)
	var root := get_viewport()
	if root:
		root.disable_3d = _off
		if root.size_changed.is_connected(_resize):
			root.size_changed.disconnect(_resize)
	if RenderingServer.frame_pre_draw.is_connected(_pre_draw):
		RenderingServer.frame_pre_draw.disconnect(_pre_draw)
	if src and is_instance_valid(src):
		src.make_current()
	queue_free()


func _exit_tree() -> void:
	if RenderingServer.frame_pre_draw.is_connected(_pre_draw):
		RenderingServer.frame_pre_draw.disconnect(_pre_draw)
	if current == self:
		current = null


func _new_sub(s: Vector2i) -> SubViewport:
	var v := SubViewport.new()
	v.name = "World3D"
	v.size = s   # (before it enters the tree: see _resize)
	v.world_3d = get_viewport().world_3d   # the same scene: lights, environment, map
	v.transparent_bg = false
	v.handle_input_locally = false
	v.gui_disable_input = true
	v.audio_listener_enable_3d = false
	v.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(v)
	cam = Camera3D.new()
	cam.name = "WorldCam"
	v.add_child(cam)
	cam.current = true
	return v


func _target_size() -> Vector2i:
	var ws := Vector2(get_window().size)   # the canvas's pixels (the page's CSS pixels x its pixel ratio)
	return Vector2i(maxi(1, roundi(ws.x * k)), maxi(1, roundi(ws.y * k)))


func _resize() -> void:
	if sub == null:
		return
	var s := _target_size()
	if sub.size != s:
		sub.size = s


func _process(_d: float) -> void:
	_sync()


func _sync() -> void:
	if src == null or not is_instance_valid(src) or cam == null:
		return
	var root := get_viewport()
	# the window's 3D settings (GfxTier / Quality / HDRender set them on the window) apply to the SubViewport
	if sub.msaa_3d != root.msaa_3d:
		sub.msaa_3d = root.msaa_3d
	if sub.screen_space_aa != root.screen_space_aa:
		sub.screen_space_aa = root.screen_space_aa
	if sub.use_debanding != root.use_debanding:
		sub.use_debanding = root.use_debanding
	if sub.positional_shadow_atlas_size != root.positional_shadow_atlas_size:
		sub.positional_shadow_atlas_size = root.positional_shadow_atlas_size
	if sub.mesh_lod_threshold != root.mesh_lod_threshold:
		sub.mesh_lod_threshold = root.mesh_lod_threshold
	if not root.disable_3d:   # (something switched the window's 3D on directly: keep it off, take it as "3D on")
		root.disable_3d = true
		if _off:
			_set_off(false)
	if cam.fov != src.fov:
		cam.fov = src.fov
	if cam.near != src.near or cam.far != src.far:
		cam.near = src.near
		cam.far = src.far
	if cam.projection != src.projection:
		cam.projection = src.projection
		cam.size = src.size
	if cam.keep_aspect != src.keep_aspect:
		cam.keep_aspect = src.keep_aspect
	if cam.cull_mask != src.cull_mask:
		cam.cull_mask = src.cull_mask
	if cam.environment != src.environment:
		cam.environment = src.environment
	if cam.attributes != src.attributes:
		cam.attributes = src.attributes
	cam.h_offset = src.h_offset
	cam.v_offset = src.v_offset
	cam.global_transform = src.global_transform


func _pre_draw() -> void:
	## the camera exactly where the game's camera ended this frame (moves made after _process, e.g. in input events)
	if current != self or src == null or not is_instance_valid(src) or cam == null:
		return
	RenderingServer.camera_set_transform(cam.get_camera_rid(), src.get_camera_transform())
