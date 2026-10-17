class_name UIAudio
extends RefCounted
## Null-safe hooks into the AudioDirector autoload (scripts/audio/, the audio piece). Every call is a no-op until
## the autoload exists or when it lacks the method, so the UI never depends on it.
##   sfx: click, hover, end_turn, notification, build_complete, research_done
##   sting: war, peace, election, government, fork, research, era, game_end

static var muted := false       # UI tests: no sound calls at all
static var log: Array = []      # the last calls (UI tests check the hooks fire): ["sfx:click", "sting:war", ...]
static var _hover_t := 0


static func director() -> Node:
	var ml := Engine.get_main_loop()
	if ml is SceneTree and (ml as SceneTree).root != null:
		return (ml as SceneTree).root.get_node_or_null("AudioDirector")
	return null


static func _call(m: String, arg) -> void:
	log.append("%s:%s" % [m, str(arg)])
	if log.size() > 200:
		log = log.slice(-100)
	if muted:
		return
	var d := director()
	if d != null and d.has_method(m):
		d.call(m, arg)


const UI_SOUNDS := ["click", "hover", "end_turn", "notification", "panel_open", "panel_close", "deny"]


static func sfx(name: String) -> void:
	## Interface sounds go to the UI bus (AudioDirector.play_ui), the rest to SFX.
	if name in UI_SOUNDS:
		var d := director()
		if d != null and d.has_method("play_ui"):
			log.append("play_sfx:%s" % name)
			if not muted:
				d.call("play_ui", name)
			return
	_call("play_sfx", name)


static var sting_log: Array = []   # every stinger the UI asked for, in order (--ui-test-stings reads it; never trimmed by _call)


static func sting(kind: String) -> void:
	sting_log.append(kind)
	if sting_log.size() > 4000:
		sting_log = sting_log.slice(-2000)
	_call("play_sting", kind)


static func click() -> void:
	sfx("click")


static func hover() -> void:
	## At most one hover sound every 60 ms (sweeping across a button row is not a drum roll).
	var now := Time.get_ticks_msec()
	if now - _hover_t < 60:
		return
	_hover_t = now
	var d := director()
	if d != null and not muted:
		if d.has_method("play_ui"):
			d.call("play_ui", "hover")
		elif d.has_method("play_sfx"):
			d.call("play_sfx", "hover")


static func set_era(era: int) -> void:
	_call("set_era", era)


static func set_situation(kind: String) -> void:
	## "war" | "peace" | "normal" (music variant), if the director supports it.
	_call("set_situation", kind)


static func count(entry: String) -> int:
	return log.filter(func(x): return str(x) == entry).size()
