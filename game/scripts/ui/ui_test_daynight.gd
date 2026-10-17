class_name DayNightCheck
extends RefCounted
## v5 day / night check (UITest mode --ui-test-daynight; headless, about a minute):
##   tools/godot.sh --headless --path /c/civ/game -- --shot=<x.png> --ui-test=<dir> --ui-test-daynight [--time=sunset]
## 1. the start clock: noon under --shot / --ui-test, or the --time= flag (dawn|noon|sunset|night|<hour>), fixed;
## 2. noon is the mode's own look, bit for bit (sun, environment, sky) in SD, HD and HD+;
## 3. night: the moon, city lights on, lifted exposure; dawn / sunset: a low warm sun;
## 4. live SD / HD / HD+ switches at night never compound: back at noon each mode is exactly its own look again;
## 5. the curves are smooth over 24 h and the sun / moon switch happens with the light off;
## 6. Settings → Display: Time of day, Day length and Pause the clock exist, apply at once and are saved;
## 7. the Hebrew catalog has every new string.

const EPS := 1e-5


static func run(t: UITest) -> void:
	var game: Node = t.get_tree().get_first_node_in_group("game")
	var f: Array = t.failures
	if DayNight.inst == null:
		f.append("daynight: no DayNight node on the game")
		t._finish()
		return
	# ---- 1. the start clock
	var want := 12.0
	var targ := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--time="):
			targ = a.substr(7)
	if targ != "":
		want = float(DayNight.PRESETS[targ]) if DayNight.PRESETS.has(targ) else float(targ)
	if absf(DayNight.hour - want) > EPS:
		f.append("daynight: the start clock is %s, not %.2f (--time=%s)" % [DayNight.clock_text(), want, targ])
	if not DayNight.fixed or DayNight.running():
		f.append("daynight: the capture / test clock is not fixed")
	var h0 := DayNight.hour
	await t._frames(30)
	if absf(DayNight.hour - h0) > EPS:
		f.append("daynight: the fixed clock moved (%.4f -> %.4f)" % [h0, DayNight.hour])
	t.say("daynight: start %s mode %s (want %.2f)" % [DayNight.clock_text(), DayNight.mode, want])
	# ---- 2-4. each mode: noon = its own look; night / dawn / sunset; switching at night never compounds
	var noon := {}
	for m in ["sd", "hd", "hdplus", "sd", "hdplus", "hd"]:
		var first := not noon.has(m)
		DayNight.set_time("night")   # switch at night: the base must still come back exactly
		await _mode(t, game, m)
		DayNight.set_time("noon")
		await t._frames(2)
		var s := _state(game)
		if first:
			noon[m] = s
			_check_base(f, m)
		else:
			var d := _diff(noon[m], s)
			if d != "":
				f.append("daynight: %s noon changed after switching modes at night: %s" % [m, d])
		if first:
			await _check_times(t, game, m)
	# --daynight=off (A/B) gives the same noon
	await _mode(t, game, "hdplus")
	DayNight.set_time("noon")
	var on_noon := _state(game)
	DayNight.set_time("off")
	await t._frames(2)
	var d2 := _diff(on_noon, _state(game))
	if d2 != "":
		f.append("daynight: HD+ noon differs from no day / night at all: %s" % d2)
	DayNight.set_time("noon")
	# ---- 5. smooth curves; the light is off when the sun becomes the moon
	var prev := DayNight.sample(0.0)
	var worst := 0.0
	var worst_at := 0.0
	var hh := 0.02
	while hh <= 24.0:
		var cur := DayNight.sample(fmod(hh, 24.0))
		for k in ["lk", "amb", "exp", "lights", "w", "el"]:
			var dv := absf(float(cur[k]) - float(prev[k]))
			if dv > worst:
				worst = dv; worst_at = hh
		prev = cur
		hh += 0.02
	if worst > 0.12:
		f.append("daynight: a jump of %.3f per 72 game-seconds at %.2f h (not smooth)" % [worst, worst_at])
	for sw in [DayNight.SUN_UP, DayNight.SUN_DOWN]:
		if float(DayNight.sample(sw)["lk"]) > 0.06:
			f.append("daynight: the light is still on (%.2f) when the sun / moon switch at %.2f h" % [float(DayNight.sample(sw)["lk"]), sw])
	t.say("daynight: largest step %.3f at %.2f h" % [worst, worst_at])
	# ---- 6. the Settings rows
	await _check_settings(t, game)
	# ---- 7. Hebrew
	var he = JSON.parse_string(FileAccess.get_file_as_string("res://i18n/he/ui_v5_daynight.json"))
	if typeof(he) != TYPE_DICTIONARY:
		f.append("daynight: i18n/he/ui_v5_daynight.json is missing or not JSON")
	else:
		for s in ["Time of day", "Day length", "Pause the clock", "Day and night (real time)", "Dawn", "Noon", "Sunset", "Night",
				"{#0} minutes", "Time of day: {0}.", "Day length: {#0} minutes.", "The clock is paused.", "The clock runs."]:
			if str(he.get(s, "")) == "":
				f.append("daynight: no Hebrew for '%s'" % s)
	t.say("daynight: %d failures" % f.size())
	t._finish()


static func _mode(t: UITest, game: Node, m: String) -> void:
	GameSettings.graphics_hd = m != "sd"
	GameSettings.graphics_plus = m == "hdplus"
	GameSettings.apply_graphics_mode(game)
	await t._frames(3)


static func _env(game: Node) -> Environment:
	for c in game.get_children():
		if c is WorldEnvironment:
			return (c as WorldEnvironment).environment
	return null


static func _state(game: Node) -> Dictionary:
	var s := {}
	var sun := game.get_node("Sun") as DirectionalLight3D
	for k in DayNight.SUN_KEYS:
		s["sun." + k] = sun.get(k)
	var env := _env(game)
	for k in DayNight.ENV_KEYS:
		s["env." + k] = env.get(k)
	var sm := env.sky.sky_material as ProceduralSkyMaterial
	for k in ["sky_top_color", "sky_horizon_color", "ground_horizon_color", "ground_bottom_color"]:
		s["sky." + k] = sm.get(k)
	s["sky.cover_a"] = sm.sky_cover_modulate.a if sm.sky_cover != null else 0.0
	# the shader globals as DayNight last set them (RenderingServer cannot read globals back headless)
	for g in ["lights", "night", "gk"]:
		s["dn." + g] = float(DayNight.look().get(g, 0.0))
	return s


static func _diff(a: Dictionary, b: Dictionary) -> String:
	var out := []
	for k in a:
		var x = a[k]
		var y = b.get(k)
		var bad := false
		if x is Color:
			bad = not (x as Color).is_equal_approx(y)
		elif x is Vector3:
			bad = not (x as Vector3).is_equal_approx(y)
		elif x is float or x is int:
			bad = absf(float(x) - float(y)) > EPS
		if bad:
			out.append("%s %s -> %s" % [k, str(x), str(y)])
	return ", ".join(out)


static func _check_base(f: Array, m: String) -> void:
	## at noon the applied values ARE the captured base (multipliers 1, weights 0)
	## (a pose re-set after the night reads back within ~1e-5 degrees: Node3D keeps radians)
	var sun := DayNight._sun
	for k in DayNight._sun_base:
		if _diff({k: DayNight._sun_base[k]}, {k: sun.get(k)}) != "":
			f.append("daynight: %s noon sun.%s is %s, the mode's own %s" % [m, k, str(sun.get(k)), str(DayNight._sun_base[k])])
	for k in DayNight._env_base:
		if _diff({k: DayNight._env_base[k]}, {k: DayNight._env.get(k)}) != "":
			f.append("daynight: %s noon env.%s is %s, the mode's own %s" % [m, k, str(DayNight._env.get(k)), str(DayNight._env_base[k])])
	if float(DayNight.look()["lights"]) != 0.0 or float(DayNight.look()["night"]) != 0.0:
		f.append("daynight: %s noon has the city lights on" % m)
	var gc: Color = DayNight.look()["gl"]
	var gl := Vector4(gc.r, gc.g, gc.b, float(DayNight.look()["gk"]))
	if not gl.is_equal_approx(Vector4(1.0, 0.92, 0.75, 1.0)):
		f.append("daynight: %s noon glitter is %s, not HD's own" % [m, str(gl)])


static func _check_times(t: UITest, game: Node, m: String) -> void:
	var f: Array = t.failures
	var sun := game.get_node("Sun") as DirectionalLight3D
	var be: float = DayNight._sun_base["light_energy"]
	var bx: float = DayNight._env_base["tonemap_exposure"]
	DayNight.set_time("night")
	await t._frames(2)
	if not sun.rotation_degrees.is_equal_approx(DayNight.MOON_ROT):
		f.append("daynight: %s night light is not the moon (%s)" % [m, str(sun.rotation_degrees)])
	if sun.light_energy >= be * 0.6 or sun.light_energy <= 0.0:
		f.append("daynight: %s moonlight energy %.2f (sun %.2f)" % [m, sun.light_energy, be])
	if sun.light_color.b <= sun.light_color.r:
		f.append("daynight: %s moonlight is not blue (%s)" % [m, str(sun.light_color)])
	if float(DayNight.look()["lights"]) < 0.99:
		f.append("daynight: %s night without city lights" % m)
	if DayNight._env.tonemap_exposure <= bx:
		f.append("daynight: %s night exposure not lifted (%.2f vs %.2f)" % [m, DayNight._env.tonemap_exposure, bx])
	var sm := DayNight._env.sky.sky_material as ProceduralSkyMaterial
	if sm.sky_cover == null or sm.sky_cover_modulate.a < 0.9:
		f.append("daynight: %s night sky has no stars" % m)
	for tod in ["dawn", "sunset"]:
		DayNight.set_time(tod)
		await t._frames(2)
		var el := -sun.rotation_degrees.x
		var bel := -float((DayNight._sun_base["rotation_degrees"] as Vector3).x)
		if el >= bel * 0.6 or el <= 2.0:
			f.append("daynight: %s %s sun elevation %.1f (noon %.1f)" % [m, tod, el, bel])
		if sun.light_color.b >= sun.light_color.g * 0.85:
			f.append("daynight: %s %s sun is not warm (%s)" % [m, tod, str(sun.light_color)])
		if sun.light_energy < be * 0.5:
			f.append("daynight: %s %s sun too dim (%.2f vs %.2f)" % [m, tod, sun.light_energy, be])
	t.say("daynight: %s night moon %.2f exposure %.2f, sunset sun %s" % [m, be * float(DayNight.sample(22.0)["lk"]), bx * float(DayNight.sample(22.0)["exp"]), str(sun.light_color)])
	DayNight.set_time("noon")
	await t._frames(1)


static func _check_settings(t: UITest, game: Node) -> void:
	var f: Array = t.failures
	var ui = t.ui
	ui.open_settings("display")
	await t._frames(4)
	var sw: SettingsWindow = ui.settings_w
	for nm in ["time_of_day", "day_length", "clock_paused"]:
		if sw.find_child(nm, true, false) == null:
			f.append("daynight: Settings has no '%s' control" % nm)
	await t.shot("settings_daynight")
	t._in_view(sw, "settings (day and night)")
	t._check_min_font(sw, "settings (day and night)")
	var cf := ConfigFile.new()
	sw.set_time_of_day("sunset")
	await t._frames(2)
	cf.load(GameSettings.path)
	if str(cf.get_value("graphics", "time_of_day", "")) != "sunset":
		f.append("daynight: Time of day Sunset not saved")
	if absf(DayNight.hour - DayNight.PRESETS["sunset"]) > EPS or DayNight.mode != "sunset":
		f.append("daynight: Time of day Sunset not applied (%s %s)" % [DayNight.mode, DayNight.clock_text()])
	sw.set_day_length(4)
	cf.load(GameSettings.path)
	if int(cf.get_value("graphics", "day_length", 0)) != 4 or absf(DayNight.day_min - 4.0) > EPS:
		f.append("daynight: Day length 4 minutes not saved / applied")
	sw.set_clock_paused(false)
	sw.set_time_of_day("cycle")
	var a0 := DayNight.hour
	var t0 := Time.get_ticks_msec()
	await t._frames(40)
	var dt := (Time.get_ticks_msec() - t0) / 1000.0
	var moved := fposmod(DayNight.hour - a0, 24.0)
	if not DayNight.running() or moved <= 0.0:
		f.append("daynight: the clock does not run in 'Day and night (real time)' (moved %.4f h)" % moved)
	elif moved > dt * 24.0 / (4.0 * 60.0) * 1.6 + 0.02:
		f.append("daynight: the clock ran %.3f h in %.1f s, too fast for a 4-minute day" % [moved, dt])
	sw.set_clock_paused(true)
	await t._frames(2)
	var p0 := DayNight.hour
	await t._frames(30)
	cf.load(GameSettings.path)
	if absf(DayNight.hour - p0) > EPS or not bool(cf.get_value("graphics", "clock_paused", false)):
		f.append("daynight: Pause the clock did not stop / save the clock")
	t.say("daynight: settings: cycle moved %.4f h in %.1f s at 4 min/day, paused at %s" % [moved, dt, DayNight.clock_text()])
	# the player's other choices come back: defaults (real time, 8 minutes, running)
	GameSettings.time_of_day = "cycle"
	GameSettings.day_length_min = 8
	GameSettings.clock_paused = false
	GameSettings.save_cfg()
	sw.close()
