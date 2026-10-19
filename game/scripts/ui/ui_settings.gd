class_name GameSettings
extends RefCounted
## Player settings (the Settings window): audio volumes, UI scale, key bindings, the colourblind-safe palette,
## the graphics preset, fullscreen / windowed and the language. Saved to user://game.cfg and applied on start
## (GameUI.setup). Sections: [audio] Master/Music/SFX/Ambience/UI (linear 0..1), [ui] scale, palette,
## [display] fullscreen, language, [graphics] quality (also read by scripts/map/quality.gd), [keys] <action>.
## UI tests use user://game_test.cfg (set `path` before load) so a test never touches the player's settings.

const BUSES := [["Master", "Master volume"], ["Music", "Music"], ["SFX", "Sound effects"], ["Ambience", "Ambience"], ["UI", "Interface sounds"]]
const SCALE_MIN := 0.9
const SCALE_MAX := 1.5
const QUALITIES := [["low", "Low"], ["medium", "Medium"], ["high", "High"]]
const PALETTES := [["standard", "Standard (green helps, red hurts)"], ["colourblind", "Colourblind-safe (blue helps, orange hurts)"]]
## Languages offered in the selector, each named in its own language. A language is selectable once its catalog
## exists (game/i18n/<code>/, see L10n); --lang=<code> on the command line overrides the setting for one run.
const LANGUAGES := [["en", "English"], ["he", "עברית"]]

## Rebindable actions: [id, label, default key, ctrl, shift, alt]. KEY_NONE = unbound by default.
const ACTIONS := [
	["end_turn", "End turn / next decision (Shift: force)", KEY_ENTER, false, false, false],
	["research", "Research", KEY_R, false, false, false],
	["civics", "Civics", KEY_C, false, false, false],
	["policies", "Policies and government", KEY_P, false, false, false],
	["cabinet", "Cabinet and State Budget", KEY_K, false, false, false],
	["diplomacy", "Diplomacy", KEY_I, false, false, false],
	["ghost", "Ghost of history", KEY_G, false, false, false],
	["endings", "Ending outlook", KEY_O, false, false, false],
	["tech_tree", "Technology tree", KEY_T, false, false, false],
	["log", "Event log", KEY_L, false, false, false],
	["pedia", "Civilopedia", KEY_F2, false, false, false],
	["help", "How to Play", KEY_F1, false, false, false],
	["save", "Save game", KEY_S, true, false, false],
	["load", "Load game", KEY_L, true, false, false],
	["quick_save", "Quick-save", KEY_F5, false, false, false],
	["quick_load", "Quick-load", KEY_F9, false, false, false],
	["fullscreen", "Fullscreen / windowed", KEY_F11, false, false, false],
	["settings", "Settings", KEY_F10, false, false, false],
	["next_unit", "Next unit", KEY_PERIOD, false, false, false],
	["unit_fortify", "Unit: fortify", KEY_F, false, false, false],
	["unit_skip", "Unit: skip turn", KEY_SPACE, false, false, false],
	["unit_found", "Settlers: found town", KEY_B, false, false, false],
]
const PREFIX := "isr_"     # InputMap action names: isr_end_turn, ...

static var path := "user://game.cfg"
static var cfg: ConfigFile
static var ui_scale := 1.0          # the player's choice (0.9..1.5)
static var palette := "standard"
static var language := "en"
static var language_chosen := false   # [display] language_asked: the player picked a language (else the first-launch prompt)
static var lang_override := ""        # --lang=<code> (tests, captures): this run only, never saved
static var fullscreen := false
static var quality := "medium"
static var graphics_hd := false     # [graphics] mode = "sd" | "hd" | "hdplus" (render-hd: scripts/map/hd_render.gd)
static var graphics_plus := false   # HD+ (with graphics_hd): HD plus the effects of scripts/map/hdplus.gd
static var upscaling := false       # [graphics] upscaling = "off" | "fsr2" (HD only: FSR 2 at 0.77, scripts/map/hdplus.gd)
# perf60: [graphics] tier = a GfxTier ladder step ("" = never chosen: the first launch detects one; "custom" = the separate
# rows), detected_tier = what the detector picked (Restore defaults goes back to it), fps = "60" | "30" | "unlimited"
static var gfx_tier := ""
static var detected_tier := ""
static var fps_mode := "60"
const FPS_MODES := [["60", "60 (recommended)"], ["30", "30, battery saver"], ["unlimited", "Unlimited"]]
static var _cmd_fps_cap := -1       # godot.sh / --max-fps from the command line: never raised (GPU safety for agent runs)
static var volumes := {}            # bus -> linear 0..1
static var play_style := "full"     # [game] play_style: the New Game panel's last choice ("full" default, the user 2026-10-17 | "story")
static var auto_advance := false    # v4 [game] auto_advance: quiet quarters end on their own after 2 s (off by default)
# v5 day / night (scripts/map/daynight.gd): [graphics] time_of_day = "cycle" | "dawn" | "noon" | "sunset" | "night",
# day_length = 4 | 8 | 16 (real minutes for a whole day), clock_paused
static var time_of_day := "cycle"
static var day_length_min := 8
static var clock_paused := false


static func load_cfg() -> void:
	cfg = ConfigFile.new()
	cfg.load(path)   # a missing file leaves the defaults
	ui_scale = clampf(float(cfg.get_value("ui", "scale", 1.0)), SCALE_MIN, SCALE_MAX)
	palette = str(cfg.get_value("ui", "palette", "standard"))
	if not palette in ["standard", "colourblind"]:
		palette = "standard"
	language = str(cfg.get_value("display", "language", "en"))
	language_chosen = bool(cfg.get_value("display", "language_asked", false))
	fullscreen = bool(cfg.get_value("display", "fullscreen", default_fullscreen()))
	if OS.has_feature("web"):   # a browser only enters full screen from a click or key press: never at start
		fullscreen = false
	quality = str(cfg.get_value("graphics", "quality", "medium")).to_lower()
	if not quality in ["low", "medium", "high"]:
		quality = "medium"
	var gmode := str(cfg.get_value("graphics", "mode", "sd")).to_lower()
	graphics_hd = gmode == "hd" or gmode == "hdplus"
	graphics_plus = gmode == "hdplus"
	upscaling = str(cfg.get_value("graphics", "upscaling", "off")).to_lower() == "fsr2"
	gfx_tier = str(cfg.get_value("graphics", "tier", ""))
	if gfx_tier != "custom" and not GfxTier.valid(gfx_tier):
		gfx_tier = ""
	detected_tier = str(cfg.get_value("graphics", "detected_tier", ""))
	fps_mode = str(cfg.get_value("graphics", "fps", "60"))
	if not fps_mode in ["60", "30", "unlimited"]:
		fps_mode = "60"
	play_style = "story" if str(cfg.get_value("game", "play_style", "full")) == "story" else "full"
	auto_advance = bool(cfg.get_value("game", "auto_advance", false))
	time_of_day = str(cfg.get_value("graphics", "time_of_day", "cycle")).to_lower()
	if not time_of_day in DayNight.MODES:
		time_of_day = "cycle"
	day_length_min = int(cfg.get_value("graphics", "day_length", 8))
	if not day_length_min in DayNight.LENGTHS:
		day_length_min = 8
	clock_paused = bool(cfg.get_value("graphics", "clock_paused", false))
	DayNight.from_settings()
	volumes.clear()
	for b in BUSES:
		volumes[b[0]] = clampf(float(cfg.get_value("audio", b[0], 0.8 if b[0] != "Master" else 1.0)), 0.0, 1.0)
	setup_input_map()


static func save_cfg() -> bool:
	if cfg == null:
		cfg = ConfigFile.new()
		cfg.load(path)
	cfg.set_value("ui", "scale", snappedf(ui_scale, 0.05))
	cfg.set_value("ui", "palette", palette)
	cfg.set_value("display", "language", language)
	cfg.set_value("display", "language_asked", language_chosen)
	cfg.set_value("display", "fullscreen", fullscreen)
	cfg.set_value("graphics", "quality", quality)
	cfg.set_value("graphics", "mode", ("hdplus" if graphics_plus else "hd") if graphics_hd else "sd")
	cfg.set_value("graphics", "upscaling", "fsr2" if upscaling else "off")
	if gfx_tier != "":   # (never written before the player or the detector chose: the first launch detects)
		cfg.set_value("graphics", "tier", gfx_tier)
	if detected_tier != "":
		cfg.set_value("graphics", "detected_tier", detected_tier)
	cfg.set_value("graphics", "fps", fps_mode)
	cfg.set_value("game", "play_style", play_style)
	cfg.set_value("game", "auto_advance", auto_advance)
	cfg.set_value("graphics", "time_of_day", time_of_day)
	cfg.set_value("graphics", "day_length", day_length_min)
	cfg.set_value("graphics", "clock_paused", clock_paused)
	for b in volumes:
		cfg.set_value("audio", b, snappedf(float(volumes[b]), 0.01))
	for a in ACTIONS:
		cfg.set_value("keys", a[0], binding(a[0]))
	return cfg.save(path) == OK


static func default_fullscreen() -> bool:
	## the project's own window mode: the release build starts fullscreen (refresh_src.sh sets mode 3)
	return int(ProjectSettings.get_setting("display/window/size/mode", 0)) >= 3


static func reset_defaults() -> void:
	ui_scale = 1.0
	palette = "standard"
	# the language is kept: Restore defaults should not switch the player's language
	fullscreen = default_fullscreen()
	quality = "medium"
	graphics_hd = false
	graphics_plus = false
	upscaling = false
	fps_mode = "60"
	if GfxTier.valid(detected_tier):   # perf60: the graphics this computer was measured for
		GfxTier.to_settings(detected_tier)
	elif gfx_tier != "":
		gfx_tier = GfxTier.SAFE
		GfxTier.to_settings(GfxTier.SAFE)
	auto_advance = false   # (the play style is kept: it is the player's choice of game, not a display setting)
	time_of_day = "cycle"
	day_length_min = 8
	clock_paused = false
	for b in BUSES:
		volumes[b[0]] = 0.8 if b[0] != "Master" else 1.0
	for a in ACTIONS:
		_set_event(a[0], _default_dict(a))


# ================================================================== apply

static func apply_all(tree: SceneTree, live_window := true) -> void:
	## live_window false (captures, UI tests, headless): never switch the real window to fullscreen.
	apply_audio()
	apply_palette()
	apply_scale(tree)
	apply_language()
	apply_fps()
	if live_window and not OS.has_feature("web"):   # (web: full screen only from the player's click or key)
		apply_window()


static func fps_cap() -> int:
	## the frame-rate limit of the chosen mode (0 = none); a command-line --max-fps (tools/godot.sh) is never raised
	if _cmd_fps_cap < 0:
		_cmd_fps_cap = Engine.max_fps
	var want := {"60": 60, "30": 30, "unlimited": 0}.get(fps_mode, 60) as int
	if GfxTier.web() and GfxTier.active == "web_low":   # (web, integrated graphics: a steady 30)
		want = 30 if want == 0 else mini(want, 30)
	if _cmd_fps_cap > 0:
		return _cmd_fps_cap if want == 0 else mini(want, _cmd_fps_cap)
	return want


static func apply_fps() -> void:
	## perf60: steady frame pacing. 60 (default): vsync plus a 60 fps cap, so a frame never waits a whole extra
	## refresh at random (the 60 / 30 judder); 30: battery saver; Unlimited: no cap, no vsync.
	if DisplayServer.get_name() == "headless":
		return   # (headless runs, the sim and UI suites, stay uncapped)
	Engine.max_fps = fps_cap()
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED if fps_mode == "unlimited" else DisplayServer.VSYNC_ENABLED)


static func apply_audio() -> void:
	## Bus volumes (AudioDirector creates the buses; a bus that does not exist yet is applied when it appears).
	var ad := audio_director()
	for b in volumes:
		var lin := float(volumes[b])
		if ad != null and ad.has_method("set_bus_volume"):
			ad.call("set_bus_volume", b, lin)
			continue
		var i := AudioServer.get_bus_index(b)
		if i >= 0:
			AudioServer.set_bus_volume_db(i, linear_to_db(maxf(lin, 0.0001)))
			AudioServer.set_bus_mute(i, lin <= 0.001)


static func missing_buses() -> Array:
	var out := []
	for b in volumes:
		if AudioServer.get_bus_index(b) < 0:
			out.append(b)
	return out


static func audio_director() -> Node:
	var ml := Engine.get_main_loop()
	if ml is SceneTree:
		return (ml as SceneTree).root.get_node_or_null("AudioDirector")
	return null


static func apply_palette() -> void:
	UITheme.set_palette(palette)


static func effective_scale() -> float:
	## The player's scale, but never so small that 16-unit body text falls under 12 px on this screen
	## (at 1280x720 the floor is about 98%).
	var ml := Engine.get_main_loop()
	var h := 941.0
	if ml is SceneTree:
		var w: Window = (ml as SceneTree).root
		if w != null and DisplayServer.get_name() != "headless":
			h = float(w.size.y)
		elif w != null:
			h = 720.0   # headless UI tests are laid out as a 1280x720 screen
	var floor_k := 12.0 * 941.0 / (16.0 * maxf(h, 1.0))
	return maxf(ui_scale, minf(floor_k, 1.0))


static func apply_scale(_tree: SceneTree = null) -> void:
	UIWindow.ui_scale = effective_scale()


static func current_language() -> String:
	return lang_override if lang_override != "" else language


static func apply_language() -> void:
	## Loads the catalogs (L10n) and switches every text on screen; the content of windows mirrors right to left
	## for Hebrew. Works live: Labels, Buttons and tooltips re-translate themselves, windows rebuild on refresh.
	var code := current_language()
	if code != "en" and not language_available(code):
		code = "en"
	if L10n.ready and L10n.lang == code:
		return
	L10n.setup(code)
	var ml := Engine.get_main_loop()
	if ml is SceneTree:
		L10n.relayout((ml as SceneTree).root)


static func language_available(code: String) -> bool:
	return L10n.available(code)


static func apply_window() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var full := DisplayServer.window_get_mode() in [DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]
	if fullscreen != full:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)


static func toggle_fullscreen() -> void:
	fullscreen = not (DisplayServer.window_get_mode() in [DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN])
	apply_window()
	save_cfg()


static func apply_quality(game: Node) -> String:
	## Applies what can change live (shadows, SSAO, MSAA); tree shadows and the art draw range follow on the next start.
	Quality.level = quality
	var qp: Dictionary = Quality.PRESETS.get(quality, Quality.PRESETS["medium"])
	if game == null or not game.is_inside_tree():
		return "saved"
	if Quality.hd:
		return "saved"   # HD mode owns the lighting; the preset applies again when switching back to SD"
	for we in game.find_children("*", "WorldEnvironment", false, false):
		var env: Environment = (we as WorldEnvironment).environment
		if env:
			env.ssao_enabled = bool(qp["ssao"])
	var sun := game.get_node_or_null("Sun") as DirectionalLight3D
	if sun:
		sun.directional_shadow_max_distance = float(qp["shadow_dist"])
		sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS if int(qp["shadow_splits"]) == 4 else DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
		sun.light_angular_distance = 0.5 if quality == "high" else 0.0
	game.get_viewport().msaa_3d = [Viewport.MSAA_DISABLED, Viewport.MSAA_2X, Viewport.MSAA_4X][int(qp["msaa"])]
	GfxTier.apply(game)   # perf60: the tier's levers on top
	return "applied"


static func apply_upscaling(game: Node) -> String:
	## Upscaling (faster): Off / FSR 2 at 0.77 render scale. Switches live; only acts in HD.
	Quality.fsr = upscaling
	if game == null or not game.is_inside_tree():
		return "saved"
	HDPlus.apply_upscaling(game.get_viewport())
	GfxTier.apply(game)
	return "applied" if Quality.hd else "saved"


static func apply_graphics_mode(game: Node) -> String:
	## Graphics: SD / HD / HD+. Switches live (lighting, GI, water, materials); tree shadows and the far building range
	## follow on the next start. Back to SD re-applies the chosen quality preset.
	Quality.hd = graphics_hd
	Quality.plus = graphics_hd and graphics_plus
	if game == null or not game.is_inside_tree():
		return "saved"
	HDRender.apply(game, graphics_hd)
	if not graphics_hd:
		apply_quality(game)
	GfxTier.apply(game)   # perf60: the tier's levers on top (none for "custom")
	return "applied"


static func set_custom() -> void:
	## perf60: the player changed one of the separate graphics rows: no tier levers from now on
	gfx_tier = "custom"
	GfxTier.select("")


static func apply_daynight(snap := false) -> String:
	## v5 Day and night (Time of day, Day length, Pause the clock): live. snap jumps straight to a chosen time of day
	## (tests); otherwise the clock runs forward to it in a second or two.
	if DayNight.inst == null or not is_instance_valid(DayNight.inst):
		return "saved"
	DayNight.apply_settings(snap)
	return "applied"


# ================================================================== key bindings (InputMap)

static func act(id: String) -> String:
	return PREFIX + id


static func _default_dict(a: Array) -> Dictionary:
	return {"key": int(a[2]), "ctrl": bool(a[3]), "shift": bool(a[4]), "alt": bool(a[5])}


static func setup_input_map() -> void:
	for a in ACTIONS:
		var name := act(a[0])
		if not InputMap.has_action(name):
			InputMap.add_action(name)
		var d = cfg.get_value("keys", a[0]) if cfg != null and cfg.has_section_key("keys", a[0]) else null
		if typeof(d) != TYPE_DICTIONARY:
			d = _default_dict(a)
		_set_event(a[0], d)


static func _set_event(id: String, d: Dictionary) -> void:
	var name := act(id)
	if not InputMap.has_action(name):
		InputMap.add_action(name)
	InputMap.action_erase_events(name)
	var k := int(d.get("key", KEY_NONE))
	if k == KEY_NONE:
		return
	var e := InputEventKey.new()
	e.keycode = k as Key
	e.ctrl_pressed = bool(d.get("ctrl", false))
	e.shift_pressed = bool(d.get("shift", false))
	e.alt_pressed = bool(d.get("alt", false))
	InputMap.action_add_event(name, e)
	if id == "end_turn" and k == KEY_ENTER:
		var kp := e.duplicate() as InputEventKey
		kp.keycode = KEY_KP_ENTER
		InputMap.action_add_event(name, kp)


static func binding(id: String) -> Dictionary:
	var name := act(id)
	if InputMap.has_action(name):
		for e in InputMap.action_get_events(name):
			if e is InputEventKey:
				var k := e as InputEventKey
				return {"key": int(k.keycode), "ctrl": k.ctrl_pressed, "shift": k.shift_pressed, "alt": k.alt_pressed}
	return {"key": KEY_NONE, "ctrl": false, "shift": false, "alt": false}


static func binding_text(id: String) -> String:
	return key_text(binding(id))


static func key_text(d: Dictionary) -> String:
	var k := int(d.get("key", KEY_NONE))
	if k == KEY_NONE:
		return "(unbound)"
	var parts := []
	if bool(d.get("ctrl", false)): parts.append("Ctrl")
	if bool(d.get("alt", false)): parts.append("Alt")
	if bool(d.get("shift", false)): parts.append("Shift")
	var ks := OS.get_keycode_string(k as Key)
	parts.append({"Period": ".", "Space": "Space", "Enter": "Enter"}.get(ks, ks))
	return "+".join(parts)


static func label_of(id: String) -> String:
	for a in ACTIONS:
		if a[0] == id:
			return str(a[1])
	return id


static func rebind(id: String, e: InputEventKey) -> String:
	## Binds id to the key of e (with its modifiers). Another action that used the same key loses it; returns
	## that action's id ("" if none).
	var d := {"key": int(e.keycode), "ctrl": e.ctrl_pressed, "shift": e.shift_pressed, "alt": e.alt_pressed}
	var taken := ""
	for a in ACTIONS:
		if a[0] != id and binding(a[0]).hash() == d.hash():
			taken = a[0]
			_set_event(a[0], {"key": KEY_NONE})
	_set_event(id, d)
	return taken


static func unbind(id: String) -> void:
	_set_event(id, {"key": KEY_NONE})


static func action_for(e: InputEvent) -> String:
	## The rebindable action this key press triggers (exact modifiers), or "". Shift+<end turn> -> "end_turn_force".
	if not (e is InputEventKey) or not e.is_pressed() or e.is_echo():
		return ""
	for a in ACTIONS:
		if InputMap.has_action(act(a[0])) and e.is_action_pressed(act(a[0]), false, true):
			return a[0]
	var k := e as InputEventKey
	if k.shift_pressed and InputMap.has_action(act("end_turn")) and e.is_action_pressed(act("end_turn"), false, false):
		return "end_turn_force"
	return ""
