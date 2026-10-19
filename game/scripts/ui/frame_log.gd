class_name FrameLog
extends Node
## perf60: frame-time log. Every frame's wall time (from one _process to the next, so it covers the main thread's
## work, the render and any wait for the frame cap / vsync) with what happened in it: FrameLog.mark("<what> <ms>")
## from the turn end, the map rebuild, autosave, the minimap and so on.
##   --frame-log[=<path.txt>]   any run: log, and on quit print the summary (and write every frame to the path)
## The stutter scenario (scripts/ui/ui_test_perf.gd, UITest mode --ui-test-perf) drives one and reads summary().
## Headless runs have no renderer and no frame cap, so their frame times are the main thread's CPU work alone;
## windowed agent runs are capped at 30 fps by tools/godot.sh, so there a frame under about 34 ms is not a hitch.

static var inst: FrameLog
static var phase := ""          # the scenario's current phase ("pan", "turn" ...), stored with each frame

var times := PackedFloat32Array()   # ms per frame
var phases: Array = []
var notes: Array = []               # the marks of each frame ("" = none)
var _last := 0
var _marks: Array = []
var _path := ""
var enabled := true


static func mark(what: String) -> void:
	if inst != null and is_instance_valid(inst):
		inst._marks.append(what)


static func ensure(parent: Node) -> FrameLog:
	if inst != null and is_instance_valid(inst):
		return inst
	var f := FrameLog.new()
	f.name = "FrameLog"
	parent.add_child(f)
	return f


func _ready() -> void:
	inst = self
	process_priority = -1000   # first in the frame: the delta since the last frame start
	process_mode = Node.PROCESS_MODE_ALWAYS
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--frame-log="):
			_path = a.substr(12)
	tree_exiting.connect(_on_exit)


func _process(_d: float) -> void:
	var now := Time.get_ticks_usec()
	if _last != 0 and enabled:
		times.append((now - _last) / 1000.0)
		phases.append(phase)
		notes.append(", ".join(PackedStringArray(_marks)))
	_marks.clear()
	_last = now


func reset() -> void:
	times = PackedFloat32Array()
	phases.clear()
	notes.clear()
	_last = 0


static func stats(ts: PackedFloat32Array, over := 33.4) -> Dictionary:
	var s := Array(ts)
	s.sort()
	var n := s.size()
	if n == 0:
		return {"n": 0, "p50": 0.0, "p95": 0.0, "p99": 0.0, "max": 0.0, "over33": 0, "over50": 0, "over100": 0, "over250": 0}
	var c33 := 0; var c50 := 0; var c100 := 0; var c250 := 0
	for v in s:
		if v > over: c33 += 1
		if v > 50.0: c50 += 1
		if v > 100.0: c100 += 1
		if v > 250.0: c250 += 1
	return {"n": n, "p50": s[int(n * 0.5)], "p95": s[mini(n - 1, int(n * 0.95))], "p99": s[mini(n - 1, int(n * 0.99))], "max": s[n - 1],
		"over33": c33, "over50": c50, "over100": c100, "over250": c250}


func select(ph: String) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	for i in times.size():
		if ph == "" or phases[i] == ph:
			out.append(times[i])
	return out


func spikes(limit_ms: float, ph := "") -> Array:
	## [ms, phase, notes] of every frame over limit_ms, longest first
	var out: Array = []
	for i in times.size():
		if times[i] > limit_ms and (ph == "" or phases[i] == ph):
			out.append([times[i], phases[i], notes[i]])
	out.sort_custom(func(a, b): return a[0] > b[0])
	return out


static func fmt(st: Dictionary) -> String:
	return "frames %d  p50 %.1f  p95 %.1f  p99 %.1f  max %.1f ms  >33 ms %d  >50 ms %d  >100 ms %d  >250 ms %d" % [st["n"], st["p50"], st["p95"],
		st["p99"], st["max"], st["over33"], st["over50"], st["over100"], st["over250"]]


func _on_exit() -> void:
	if _path == "" and not "--frame-log" in OS.get_cmdline_user_args():
		return
	print("FRAMELOG ", fmt(stats(times)))
	for s in spikes(50.0).slice(0, 15):
		print("FRAMELOG spike %.1f ms [%s] %s" % [s[0], s[1], s[2]])
	if _path != "":
		var fa := FileAccess.open(_path, FileAccess.WRITE)
		if fa:
			for i in times.size():
				fa.store_line("%.2f\t%s\t%s" % [times[i], phases[i], notes[i]])
