class_name CameraRig
extends Node3D
## Civ-style strategy camera: angled perspective, WASD / arrow / edge pan, drag pan, scroll zoom
## with tilt that flattens as you zoom in.

signal moved

@export var min_zoom := 0.6
@export var max_zoom := 3.0
var target := Vector3.ZERO
var zoom := 1.0
var _t := Vector3.ZERO
var _z := 1.0
var bounds := Rect2(-10, -10, 200, 200)
var edge_pan := true
var cam: Camera3D
var _drag := false
var _drag_moved := false
var _drag_origin := Vector3.ZERO
var _press_pos := Vector2.ZERO
var height_fn: Callable
var yaw_deg := -40.0     # 0 = looking north; negative turns the view toward the north-east
var _yaw := -40.0

const BASE_DIST := 11.0


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--yaw="):   # capture helper: --yaw=0 looks due north
			yaw_deg = float(a.substr(6)); _yaw = yaw_deg
	cam = Camera3D.new()
	cam.fov = 42.0
	cam.near = 0.05
	cam.far = 400.0
	add_child(cam)
	_apply()


func set_view(x: float, z: float, zm: float, snap := true) -> void:
	target = Vector3(x, 0, z)
	zoom = clampf(zm, min_zoom, max_zoom)
	if snap:
		_t = target; _z = zoom; _yaw = yaw_deg
		_apply()


func pitch_deg(z: float) -> float:
	# far out: steep (top-down-ish); close in: flatter, more cinematic
	var t := inverse_lerp(min_zoom, max_zoom, z)
	t = clampf(t, 0.0, 1.0)
	if t < 0.5:
		return lerpf(70.0, 34.0, t / 0.5)
	return lerpf(34.0, 26.0, (t - 0.5) / 0.5)


func dist(z: float) -> float:
	return BASE_DIST / z


func _apply() -> void:
	if cam == null:
		return
	var p := deg_to_rad(pitch_deg(_z))
	var d := dist(_z)
	var ground := 0.15
	if height_fn.is_valid():
		ground = maxf(0.0, height_fn.call(_t.x, _t.z)) * 0.5 + 0.1
	var focus := Vector3(_t.x, ground, _t.z)
	var off := Basis(Vector3.UP, deg_to_rad(_yaw)) * Vector3(0, sin(p) * d, cos(p) * d)
	cam.global_position = focus + off
	cam.look_at(focus, Vector3.UP)
	moved.emit()


func _process(delta: float) -> void:
	var v := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP): v.y -= 1
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN): v.y += 1
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT): v.x -= 1
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT): v.x += 1
	if edge_pan and DisplayServer.window_is_focused():
		var mp := get_viewport().get_mouse_position()
		var vs := get_viewport().get_visible_rect().size
		var m := 6.0
		if mp.x >= 0 and mp.y >= 0 and mp.x <= vs.x and mp.y <= vs.y:
			if mp.x < m: v.x -= 1
			if mp.x > vs.x - m: v.x += 1
			if mp.y < m: v.y -= 1
			if mp.y > vs.y - m: v.y += 1
	if Input.is_physical_key_pressed(KEY_Q): yaw_deg += 60.0 * delta
	if Input.is_physical_key_pressed(KEY_E): yaw_deg -= 60.0 * delta
	if v != Vector2.ZERO:
		var speed := 9.0 / zoom
		target += Basis(Vector3.UP, deg_to_rad(_yaw)) * Vector3(v.x, 0, v.y).normalized() * speed * delta
	target.x = clampf(target.x, bounds.position.x, bounds.end.x)
	target.z = clampf(target.z, bounds.position.y, bounds.end.y)
	var k := 1.0 - exp(-delta * 10.0)
	var nt := _t.lerp(target, k)
	var nz := lerpf(_z, zoom, k)
	var ny := lerpf(_yaw, yaw_deg, k)
	if nt.distance_squared_to(_t) > 1e-8 or absf(nz - _z) > 1e-5 or absf(ny - _yaw) > 1e-3:
		_t = nt; _z = nz; _yaw = ny
		_apply()


func ground_point(screen: Vector2, y := 0.0) -> Vector3:
	var o := cam.project_ray_origin(screen)
	var d := cam.project_ray_normal(screen)
	if absf(d.y) < 1e-5:
		return o
	var t := (y - o.y) / d.y
	return o + d * t


func handle_input(e: InputEvent) -> bool:
	## returns true if the event was a camera action (consumed); click-without-drag is left for picking.
	if e is InputEventMouseButton:
		var mb := e as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			zoom = clampf(zoom * 1.12, min_zoom, max_zoom); return true
		if mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			zoom = clampf(zoom / 1.12, min_zoom, max_zoom); return true
		if mb.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
			if mb.pressed:
				_drag = true; _drag_moved = false
				_press_pos = mb.position
				_drag_origin = ground_point(mb.position, 0.1)
			else:
				_drag = false
				return _drag_moved
	elif e is InputEventMouseMotion and _drag:
		var mm := e as InputEventMouseMotion
		if not _drag_moved and mm.position.distance_to(_press_pos) < 6.0:
			return false
		_drag_moved = true
		var now := ground_point(mm.position, 0.1)
		var delta := _drag_origin - now
		target += Vector3(delta.x, 0, delta.z)
		_t += Vector3(delta.x, 0, delta.z)
		_apply()
		_drag_origin = ground_point(mm.position, 0.1)
		return true
	return false
