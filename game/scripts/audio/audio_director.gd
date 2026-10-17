extends Node
## AudioDirector (autoload). Buses Music / SFX / Ambience / UI (res://default_bus_layout.tres).
## Era music (2 rotating tracks per era), war / peace / end situation themes, stingers with ducking,
## ambience loops and UI/city SFX. Safe when headless or when files are missing (every call is a no-op then).
## Hooks the sim itself (era, crisis/war, treaties, tech, production, combat, game over) by polling
## GameUI.sim; see scripts/audio/AUDIO_API.md for what the UI may still call.

signal music_changed(key: String)

const ROOT := "res://assets/audio/"
const BUSES := ["Music", "SFX", "Ambience", "UI"]
const FADE := 3.0
const DUCK_DB := -9.0
const ERA_COUNT := 8
const STING_LEN := {"war_begins": 5.0, "ceasefire": 6.0, "peace_treaty": 6.0, "election": 6.0, "government": 6.0, "fork_decided": 5.0,
	"research_complete": 5.0, "era_change": 8.0, "game_end_good": 8.0, "game_end_mixed": 8.0}
const TREATY_SECONDS := 75.0
const OPENING_HOLD := 22.0       # the opening era theme plays this long before a turn-1 war theme fades in
const XFADE_LEAD := 3.5          # start the A/B rotation crossfade this long before the loop point

var enabled := true
var era := 1
var situation := "peace"          # peace | war | end | treaty
var current_music := ""           # key of the playing music, e.g. "era3_a" (never restarted if already current)
var current_ambience := ""

var _cache := {}
var _mus: Array[AudioStreamPlayer] = []
var _mus_i := 0
var _amb: Array[AudioStreamPlayer] = []
var _amb_i := 0
var _tw_m: Tween
var _tw_a: Tween
var _tw_duck: Tween
var _sfx_pool: Array[AudioStreamPlayer] = []
var _ui_pool: Array[AudioStreamPlayer] = []
var _sting: AudioStreamPlayer
var _era_next := {}               # era -> index of next track (rotation)
var _war_next := 0
var _last_pos := 0.0
var _music_t0 := 0
var _last_played := {}            # rate limit: name -> msec
var _sim = null
var _sim_id := 0
var _poll := 0.0
var _treaty_t := 0.0
var _ceasefire_msec := -100000
var _end_good := false
var _handed_over := false
var _opening_until := 0         # msec; while now < this a war theme is held back (game start)
var _pending_music := ""       # war theme waiting for the opening hold to end


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_buses()
	enabled = DisplayServer.get_name() != "headless"
	_load_volumes()
	if not enabled:
		return
	for i in 2:
		_mus.append(_mk(&"Music"))
		_amb.append(_mk(&"Ambience"))
	for i in 6:
		_sfx_pool.append(_mk(&"SFX"))
	for i in 4:
		_ui_pool.append(_mk(&"UI"))
	_sting = _mk(&"SFX")


func _mk(bus: StringName) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.bus = bus
	add_child(p)
	return p


func _ensure_buses() -> void:
	for b in BUSES:
		if AudioServer.get_bus_index(b) < 0:
			AudioServer.add_bus()
			var i := AudioServer.bus_count - 1
			AudioServer.set_bus_name(i, b)
			AudioServer.set_bus_send(i, &"Master")


# ------------------------------------------------------------------ volume

func set_volume(bus: String, linear: float) -> void:
	var i := AudioServer.get_bus_index(_bus_name(bus))
	if i < 0:
		return
	linear = clampf(linear, 0.0, 1.0)
	AudioServer.set_bus_volume_db(i, linear_to_db(linear) if linear > 0.0005 else -80.0)
	AudioServer.set_bus_mute(i, linear <= 0.0005)


## Alias used by the Settings code (UI GameSettings.apply_audio). Persistence is the Settings code's job.
func set_bus_volume(bus: String, linear: float) -> void:
	set_volume(bus, linear)


func get_volume(bus: String) -> float:
	var i := AudioServer.get_bus_index(_bus_name(bus))
	if i < 0 or AudioServer.is_bus_mute(i):
		return 0.0
	return db_to_linear(AudioServer.get_bus_volume_db(i))


func _bus_name(bus: String) -> String:
	var b := bus.to_lower()
	if b == "master":
		return "Master"
	if b == "sfx":
		return "SFX"
	if b == "ui":
		return "UI"
	return b.capitalize()


func _load_volumes() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://game.cfg") != OK:
		return
	for b in BUSES + ["Master"]:
		if cfg.has_section_key("audio", b):
			var l := clampf(float(cfg.get_value("audio", b, 0.8)), 0.0, 1.0)
			var i := AudioServer.get_bus_index(b)
			if i >= 0:
				AudioServer.set_bus_volume_db(i, linear_to_db(l) if l > 0.0005 else -80.0)
				AudioServer.set_bus_mute(i, l <= 0.0005)


# ------------------------------------------------------------------ loading

func _stream(path: String, loop: bool) -> AudioStream:
	if _cache.has(path):
		return _cache[path]
	var s: AudioStream = null
	if ResourceLoader.exists(path):
		s = load(path) as AudioStream
		if s is AudioStreamOggVorbis:
			(s as AudioStreamOggVorbis).loop = loop
	_cache[path] = s
	return s


func has_audio(path_rel: String) -> bool:
	return ResourceLoader.exists(ROOT + path_rel)


# ------------------------------------------------------------------ SFX / UI / stingers

const STING_ALIAS := {"war": "war_begins", "peace": "peace_treaty", "election": "election", "government": "government",
	"fork": "fork_decided", "research": "research_complete", "era": "era_change"}
const SFX_ALIAS := {"research_done": "@research_complete"}


func play_sfx(sfx_name: String, volume_db := 0.0) -> void:
	if SFX_ALIAS.has(sfx_name):
		play_sting("research_complete")
		return
	_play_pool(_sfx_pool, "sfx/%s.ogg" % sfx_name, volume_db)


func play_ui(ui_name: String, volume_db := 0.0) -> void:
	_play_pool(_ui_pool, "sfx/%s.ogg" % ui_name, volume_db)


func _play_pool(pool: Array[AudioStreamPlayer], rel: String, volume_db: float) -> void:
	if not enabled:
		return
	var now := Time.get_ticks_msec()
	if now - int(_last_played.get(rel, -1000)) < 60:
		return
	_last_played[rel] = now
	var s := _stream(ROOT + rel, false)
	if s == null:
		return
	for p in pool:
		if not p.playing:
			p.stream = s
			p.volume_db = volume_db
			p.play()
			return
	pool[0].stream = s   # all busy: steal the oldest
	pool[0].volume_db = volume_db
	pool[0].play()


## kind: war_begins | ceasefire | peace_treaty | election | government | fork_decided | research_complete | era_change | game_end_good | game_end_mixed
func play_sting(kind: String) -> void:
	if kind == "peace" and Time.get_ticks_msec() - _ceasefire_msec < 4000:
		kind = "ceasefire"   # the UI sends "peace" when a crisis ends; that is a ceasefire, not a treaty
	elif kind == "game_end":
		kind = "game_end_good" if _end_good else "game_end_mixed"
	else:
		kind = STING_ALIAS.get(kind, kind)
	var s: AudioStream = null
	if enabled:
		s = _stream(ROOT + "stingers/%s.ogg" % kind, false)
	print("AudioDirector: sting -> ", kind, "" if (s != null or not enabled) else " (missing file)", "" if enabled else " (silent: headless)")
	if s == null:
		return
	_sting.stream = s
	_sting.volume_db = 0.0
	_sting.play()
	duck_for_sting(float(STING_LEN.get(kind, s.get_length())))


## Lowers Music and Ambience for `seconds` so a stinger can be heard, then restores them.
func duck_for_sting(seconds := 5.0) -> void:
	if not enabled:
		return
	if _tw_duck:
		_tw_duck.kill()
	var m := AudioServer.get_bus_index("Music")
	var a := AudioServer.get_bus_index("Ambience")
	_tw_duck = create_tween()
	_tw_duck.set_parallel(true)
	_tw_duck.tween_method(func(v): _duck_set(m, a, v), _duck_db, DUCK_DB, 0.25)
	_tw_duck.chain().tween_interval(maxf(0.1, seconds - 1.0))
	_tw_duck.chain().tween_method(func(v): _duck_set(m, a, v), DUCK_DB, 0.0, 1.5)


var _duck_db := 0.0


## The duck is applied on the per-player volume_db of the music/ambience players, so it never fights the user's bus sliders.
func _duck_set(_m: int, _a: int, v: float) -> void:
	_duck_db = v
	for p in _mus:
		p.set_meta("duck", v)
	_apply_levels()


func _apply_levels() -> void:
	for p in _mus + _amb:
		if p.has_meta("base"):
			p.volume_db = float(p.get_meta("base")) + _duck_db


# ------------------------------------------------------------------ music

func set_era(era_id) -> void:
	var e := _era_num(era_id)
	var changed := e != era
	era = e
	if not changed and current_music.begins_with("era%d_" % e):
		return
	if situation == "peace" or situation == "treaty":
		_play_music(_pick_era_track(), changed)


## "peace" (back to era music) | "war" | "end" | "treaty" (peace theme for a while, then back to era music)
func set_situation(sit: String) -> void:
	if sit == "normal":
		sit = "peace"
	if sit == situation or (sit == "peace" and situation == "treaty"):
		return
	print("AudioDirector: situation -> ", sit, " (was ", situation, ", era ", era, ") [t=", snappedf(Time.get_ticks_msec() / 1000.0, 0.1), "s]")
	situation = sit
	_treaty_t = TREATY_SECONDS if sit == "treaty" else 0.0
	_pending_music = ""
	match sit:
		"war":
			_war_next = (_war_next + 1) % 2
			var wk := "war_" + "ab"[_war_next]
			if Time.get_ticks_msec() < _opening_until and enabled:
				_pending_music = wk   # let the opening era theme play its phrase first
				print("AudioDirector: war theme ", wk, " held for the opening (", snappedf((_opening_until - Time.get_ticks_msec()) / 1000.0, 0.1), " s)")
			else:
				_play_music(wk, true)
		"end":
			_play_music("endgame", true)
		"treaty":
			_play_music("peace", true)
		_:
			_play_music(_pick_era_track(), true)


func _era_num(v) -> int:
	if typeof(v) == TYPE_INT or typeof(v) == TYPE_FLOAT:
		return clampi(int(v), 1, ERA_COUNT)
	var s := str(v).to_lower().replace("era", "")
	return clampi(int(s) if s.is_valid_int() else 1, 1, ERA_COUNT)


func _pick_era_track() -> String:
	var i := int(_era_next.get(era, 0))
	_era_next[era] = (i + 1) % 2
	var key := "era%d_%s" % [era, "ab"[i]]
	if key == current_music:   # never the same track twice in a row
		i = (i + 1) % 2
		_era_next[era] = (i + 1) % 2
		key = "era%d_%s" % [era, "ab"[i]]
	return key


func _play_music(key: String, _force := false) -> void:
	if key == current_music and _mus.size() > 0 and _mus[_mus_i].playing:
		return   # never stack the same music
	if current_music == "" and _opening_until == 0:
		_opening_until = Time.get_ticks_msec() + int(OPENING_HOLD * 1000.0)   # very first music of the session = the opening
	current_music = key
	_pending_music = ""
	if not enabled:
		return
	var s := _stream(ROOT + "music/%s.ogg" % key, true)
	if s == null:
		return
	_take_over_menu_music()
	var old := _mus[_mus_i]
	_mus_i = 1 - _mus_i
	var p := _mus[_mus_i]
	p.stream = s
	p.set_meta("base", -60.0)
	p.volume_db = -60.0
	p.play()
	_last_pos = 0.0
	_music_t0 = Time.get_ticks_msec()
	if _tw_m:
		_tw_m.kill()
	_tw_m = create_tween().set_parallel(true)
	_tw_m.tween_method(func(v): p.set_meta("base", v); p.volume_db = v + _duck_db, -60.0, 0.0, FADE)
	if old.playing:
		var ob := float(old.get_meta("base")) if old.has_meta("base") else 0.0
		_tw_m.tween_method(func(v): old.set_meta("base", v); old.volume_db = v + _duck_db, ob, -60.0, FADE)
		_tw_m.chain().tween_callback(func(): if old != _mus[_mus_i]: old.stop())
	music_changed.emit(key)
	print("AudioDirector: music -> ", key, " [t=", snappedf(Time.get_ticks_msec() / 1000.0, 0.1), "s]")


func to_menu() -> void:
	## Back to the title screen: fade out the game's music and ambience and forget the game, so the menu music
	## (StartScreen) starts again from the top and the next game takes it over again.
	if _tw_m:
		_tw_m.kill()
	for p in _mus + _amb:
		if p.playing:
			var t := p.create_tween()
			t.tween_property(p, "volume_db", -60.0, 1.0)
			t.tween_callback(p.stop)
	current_music = ""
	current_ambience = ""
	situation = "peace"
	era = 1
	_handed_over = false
	_pending_music = ""
	_opening_until = 0
	_sim = null
	_sim_id = 0


func _take_over_menu_music() -> void:
	if _handed_over:
		return
	var mm := get_tree().root.get_node_or_null("MenuMusic") as AudioStreamPlayer
	if mm == null:
		return
	_handed_over = true
	var tw := mm.create_tween()
	tw.tween_property(mm, "volume_db", -60.0, FADE)
	tw.tween_callback(mm.queue_free)


# ------------------------------------------------------------------ ambience

## kind: coast | city | desert | jerusalem | "" / "none" to stop
func set_ambience(kind: String) -> void:
	if kind == "none":
		kind = ""
	if kind == current_ambience:
		return
	current_ambience = kind
	print("AudioDirector: ambience -> ", kind if kind != "" else "none")
	if not enabled:
		return
	var s: AudioStream = null
	if kind != "":
		s = _stream(ROOT + "ambience/%s.ogg" % kind, true)
		if s == null:
			return
	var old := _amb[_amb_i]
	_amb_i = 1 - _amb_i
	var p := _amb[_amb_i]
	if _tw_a:
		_tw_a.kill()
	_tw_a = create_tween().set_parallel(true)
	if s != null:
		p.stream = s
		p.set_meta("base", -60.0)
		p.volume_db = -60.0
		p.play()
		_tw_a.tween_method(func(v): p.set_meta("base", v); p.volume_db = v + _duck_db, -60.0, 0.0, FADE)
	if old.playing:
		_tw_a.tween_method(func(v): old.set_meta("base", v); old.volume_db = v + _duck_db, 0.0, -60.0, FADE)
		_tw_a.chain().tween_callback(func(): if old != _amb[_amb_i] or s == null: old.stop())


# ------------------------------------------------------------------ per-frame: loop rotation, treaty timeout, sim hooks

func _process(delta: float) -> void:
	if not enabled:
		return
	var cur := _mus[_mus_i]
	if _pending_music != "" and Time.get_ticks_msec() >= _opening_until:
		var pk := _pending_music
		_pending_music = ""
		if situation == "war":
			_play_music(pk, true)
	elif cur.playing and cur.stream != null and (situation == "peace" or situation == "war") 			and Time.get_ticks_msec() - _music_t0 > 15000:
		# the files are seamless loops; rotate to the other track (A/B) with a crossfade shortly before the loop point
		var len_s: float = cur.stream.get_length()
		if len_s > 20.0 and len_s - cur.get_playback_position() <= XFADE_LEAD:
			if situation == "war":
				_war_next = (_war_next + 1) % 2
				_play_music("war_" + "ab"[_war_next])
			else:
				_play_music(_pick_era_track())
	if _treaty_t > 0.0:
		_treaty_t -= delta
		if _treaty_t <= 0.0 and situation == "treaty":
			set_situation("peace")
	_poll -= delta
	if _poll <= 0.0:
		_poll = 0.5
		_find_sim()


func _find_sim() -> void:
	var g := get_tree().get_first_node_in_group("game")
	if g == null:
		return
	var ui = g.get("game_ui")
	if ui == null:
		return
	var s = ui.get("sim")
	if s == null:
		if _sim != null:
			_sim = null
			_sim_id = 0
		return
	if s.get_instance_id() == _sim_id:
		return
	_sim = s
	_sim_id = s.get_instance_id()
	_connect_sim(s)


func _connect_sim(s) -> void:
	s.era_changed.connect(_on_era_changed)
	s.crisis_started.connect(_on_crisis_started)
	s.crisis_ended.connect(_on_crisis_ended)
	s.diplomacy_changed.connect(_on_diplomacy)
	s.production_completed.connect(func(_c, _k, _i): play_sfx("build_complete"))
	s.combat.connect(func(_r): play_sfx("unit_attack"))
	s.unit_moved.connect(func(_u, _f, _t): play_sfx("unit_move", -4.0))
	s.game_over.connect(_on_game_over)
	s.historic_moment.connect(_on_moment)
	s.event_fired.connect(_on_event)
	var was_war := situation == "war"
	situation = "peace"
	_treaty_t = 0.0
	era = _era_num(int(s.state.era))
	if not current_music.begins_with("era%d_" % era) or was_war:   # a new/loaded sim must not restart the music
		_play_music(_pick_era_track(), true)
	if current_ambience == "":
		set_ambience("coast")
	if _has_war(s):
		set_situation("war")


func _has_war(s) -> bool:
	for cr in s.state.crises:
		if cr.get("active", true) and cr.has("war_id"):
			return true
	return false


func _on_era_changed(idx: int, _age: String) -> void:
	set_era(idx)   # the era_change sting is played by the UI (play_sting("era"))


func _on_crisis_started(cr: Dictionary) -> void:
	if cr.has("war_id") or str(cr.get("kind", "war")) == "war":
		set_situation("war")


func _on_crisis_ended(_rep: Dictionary) -> void:
	if _sim != null and _has_war(_sim):
		return
	_ceasefire_msec = Time.get_ticks_msec()
	if situation == "war":
		set_situation("peace")


func _on_diplomacy(_actor: String, status: String) -> void:
	if status in ["peace", "normalized"]:
		_ceasefire_msec = -100000
		if situation == "peace":
			set_situation("treaty")


func _on_moment(_m: Dictionary) -> void:
	pass


func _on_event(_id: String) -> void:
	pass


func _on_game_over(summary: Dictionary) -> void:
	_end_good = int(summary.get("ahead", 0)) >= 4
	set_situation("end")   # the end sting is played by the UI (play_sting("game_end"))
