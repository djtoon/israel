class_name DayNight
extends Node
## v5: the real-time day / night cycle, in SD, HD and HD+. Purely visual: turns stay quarters.
##
## One clock (DayNight.hour, 0..24) drives the sun (or the moon at night: the same DirectionalLight3D, so no extra
## light), the ambient light, the sky colours and stars, fog and haze, exposure and grade, and three shader globals:
##   dn_lights  0..1  city lights: lit windows (building / artinst / artmodel shaders), street lamps and the warm town
##                    glow on the ground (terrain.gdshader), harbour lights on the water (water_hd.gdshader)
##   dn_night   0..1  darkness, for effects that only make sense in daylight (warm cliff bounce, foliage glow)
##   dn_glint   rgb = colour of the sun / moon glitter path on the HD sea, a = its strength (1 = HD's daytime glint)
##   dn_sea     rgb = the SD sea's colour multiplier (1 by day; dawn: cooler and about 15 % dimmer)
## Surfaces get their night grade from dn_night in scripts/map/daynight.gdshaderinc (pale ground and walls compressed
## to the brightness of the green land, desaturated moonlit blue; walls and roofs darker; warm windows).
##
## Everything is RELATIVE to what SD / HD / HD+ (main.gd, hd_render.gd, hdplus.gd and its seasons) set: those systems
## write their "base" look, and this class blends from it. At noon (hour 12) every blend weight is exactly 0 and
## every multiplier exactly 1, so the noon look is the accepted look of each mode, bit for bit.
## The writers bracket their changes with DayNight.begin() / DayNight.end(): begin puts the base values back, end
## captures the fresh base and applies the time of day on top (nested calls only act at the outermost level).
##
## Clock: Settings → Display "Time of day" (cycle, or a fixed dawn / noon / sunset / night), "Day length"
## (4 / 8 / 16 real minutes for a whole day, default 8) and "Pause the clock" (GameSettings, [graphics] in
## user://game.cfg). Captures and tests (--shot=, --ui-test=) are fixed at noon; --time=dawn|noon|sunset|night|<hour>
## fixes any time (--time=cycle lets the clock run); --daynight=off never touches the lighting (A/B checks).

const PRESETS := {"dawn": 6.1, "noon": 12.0, "sunset": 17.75, "night": 22.0}
const MODES := ["cycle", "dawn", "noon", "sunset", "night"]
const LENGTHS := [4, 8, 16]
const SUN_UP := 5.5       # the light is the sun from SUN_UP to SUN_DOWN (its energy is 0 around both switches)
const SUN_DOWN := 18.45
const MOON_ROT := Vector3(-45.0, -55.0, 0.0)   # moon high in the south-west (compass 235°): near the day's sun side, so
const SUN_STEP := 1.0           # degrees: the sun (shadow) direction steps this much at a time (no shadow crawl)
static var sun_step := SUN_STEP  # --sun-step=<deg> overrides it for A/B checks (0 = continuous, the old behaviour)
static var day_min_arg := 0.0   # --day-min=<minutes>: a faster clock for flicker checks
                                                # the slopes and walls that are lit by day stay lit (no black cliff walls)
const TWEEN_H_PER_S := 6.0  # a changed "Time of day" setting runs the clock forward this fast (smooth, never a jump)

static var inst: DayNight
static var hour := 12.0
static var mode := "cycle"      # "cycle" or a key of PRESETS, or "hour" (a --time=<hour> lock)
static var paused := false
static var day_min := 8.0
static var fixed := false       # capture / test / --time: settings do not move the clock until the player changes them
static var off := false         # --daynight=off: never touch the lighting
static var _depth := 0
static var _goal := -1.0
static var _sun: DirectionalLight3D
static var _env: Environment
static var _sun_base := {}
static var _env_base := {}
static var _sky_mat: ProceduralSkyMaterial
static var _sky_base := {}
static var _sky_last := {}
static var _sky_cover_base: Texture2D
static var _stars: ImageTexture
static var _look := {}          # the last applied look (tests, logs)

var game: Node
var _dirty := true
var _sky_t := 0.0

const SUN_KEYS := ["rotation_degrees", "light_color", "light_energy", "shadow_opacity"]
const ENV_KEYS := ["ambient_light_energy", "ambient_light_color", "ambient_light_sky_contribution", "tonemap_exposure",
	"adjustment_saturation", "adjustment_contrast", "fog_light_color", "fog_density", "fog_sun_scatter", "glow_hdr_threshold"]
const SKY_KEYS := ["sky_top_color", "sky_horizon_color", "ground_horizon_color", "ground_bottom_color", "sky_cover_modulate"]

# ---- the look over the day. w: weight of the colour targets (0 = the mode's own look); el: sun elevation as a
# fraction of the base elevation; az: compass offset of the sun from the base azimuth (deg); lk: light energy x
# (sun by day, moon by night); amb: ambient energy x; ambc / asky: ambient colour and sky share; top / hor / gnd: sky;
# fog: fog colour, fk: fog density x, sc: + sun scatter; exp / sat / con: exposure, saturation, contrast x;
# lights, night, stars: 0..1; gl / gk: glitter path colour and strength.
# sho: shadow strength x (the moon casts softer, weaker shadows: no black dot patches beside every tree);
# sea: the SD sea's colour x (dawn: a cooler, dimmer mint-blue; night has its own navy via dn_night)
# (v5-daynight-fix: the night ambient is a neutral moonlit blue, less green, so straw grass does not turn olive)
const NIGHT := {"w": 1.0, "el": 0.3, "az": -140.0, "lk": 0.27, "sun": Color(0.70, 0.76, 1.0), "amb": 1.25,
	"ambc": Color(0.28, 0.31, 0.52), "asky": 0.35, "sho": 0.5, "sea": Color(1, 1, 1), "top": Color(0.03, 0.05, 0.11), "hor": Color(0.08, 0.11, 0.21),
	"gnd": Color(0.03, 0.04, 0.07), "fog": Color(0.13, 0.17, 0.30), "fk": 0.8, "sc": 0.0, "exp": 1.22, "sat": 0.72,
	"con": 1.0, "lights": 1.0, "night": 1.0, "stars": 1.0, "gl": Color(0.66, 0.76, 1.0), "gk": 0.45, "glow": 0.85}
const DAY := {"w": 0.0, "el": 1.0, "az": 0.0, "lk": 1.0, "sun": Color(1, 1, 1), "amb": 1.0, "ambc": Color(0, 0, 0),
	"asky": 1.0, "sho": 1.0, "sea": Color(1, 1, 1), "top": Color(0, 0, 0), "hor": Color(0, 0, 0), "gnd": Color(0, 0, 0), "fog": Color(0, 0, 0), "fk": 1.0,
	"sc": 0.0, "exp": 1.0, "sat": 1.0, "con": 1.0, "lights": 0.0, "night": 0.0, "stars": 0.0, "gl": Color(1.0, 0.92, 0.75), "gk": 1.0, "glow": 1.0}
static var KEYS: Array = []


static func _keys() -> Array:
	if not KEYS.is_empty():
		return KEYS
	var k := func(h: float, over: Dictionary, from: Dictionary = DAY) -> Dictionary:
		var d := from.duplicate()
		d.merge(over, true)
		d["h"] = h
		return d
	KEYS = [
		k.call(0.0, {}, NIGHT),
		k.call(4.6, {}, NIGHT),
		# pre-dawn blue hour: the moon has set, a rose horizon, the lights still on
		k.call(5.4, {"w": 0.92, "el": 0.3, "az": -142.0, "lk": 0.0, "sun": Color(1.0, 0.55, 0.45), "amb": 1.12,
			"ambc": Color(0.30, 0.31, 0.50), "asky": 0.55, "top": Color(0.12, 0.16, 0.34), "hor": Color(0.58, 0.44, 0.54),
			"gnd": Color(0.06, 0.06, 0.09), "fog": Color(0.40, 0.38, 0.50), "fk": 1.1, "sc": 0.1, "exp": 1.2, "sat": 0.82,
			"con": 0.98, "lights": 0.85, "night": 0.65, "stars": 0.35, "gl": Color(1.0, 0.62, 0.55), "gk": 0.4, "glow": 0.9,
			"sho": 0.6, "sea": Color(0.86, 0.87, 0.92)}),
		k.call(5.65, {"w": 0.88, "el": 0.32, "az": -140.0, "lk": 0.05, "sun": Color(1.0, 0.58, 0.58), "amb": 1.05,
			"ambc": Color(0.34, 0.33, 0.52), "asky": 0.75, "top": Color(0.22, 0.27, 0.54), "hor": Color(0.80, 0.58, 0.68),
			"gnd": Color(0.10, 0.09, 0.12), "fog": Color(0.56, 0.52, 0.64), "fk": 1.1, "sc": 0.2, "exp": 1.12, "sat": 0.9,
			"con": 0.99, "lights": 0.7, "night": 0.5, "stars": 0.15, "gl": Color(1.0, 0.62, 0.6), "gk": 0.7, "glow": 0.95,
			"sho": 0.7, "sea": Color(0.80, 0.82, 0.88)}),
		# sunrise ("dawn"): cooler and pinker than the golden hour (v5-daynight-fix, critic v5 D4): a low rose-gold
		# sun in the east-south-east, a lavender sky with a pink horizon, a clear (not hazy) morning, a mint-blue sea
		# about 15 % dimmer in SD; the saturated orange stays the sunset's
		k.call(6.1, {"w": 0.72, "el": 0.38, "az": -130.0, "lk": 0.8, "sun": Color(1.0, 0.68, 0.58), "amb": 1.0,
			"top": Color(0.42, 0.48, 0.80), "hor": Color(0.94, 0.76, 0.82), "gnd": Color(0.30, 0.28, 0.35),
			"fog": Color(0.80, 0.78, 0.90), "fk": 1.1, "sc": 0.25, "exp": 1.04, "sat": 0.94, "lights": 0.1, "night": 0.2,
			"gl": Color(1.0, 0.76, 0.74), "gk": 1.3, "sea": Color(0.70, 0.80, 0.76)}),
		k.call(7.4, {"w": 0.3, "el": 0.68, "az": -95.0, "lk": 0.95, "sun": Color(1.0, 0.80, 0.70), "amb": 0.98,
			"top": Color(0.28, 0.45, 0.78), "hor": Color(0.92, 0.86, 0.86), "gnd": Color(0.30, 0.34, 0.37),
			"fog": Color(0.84, 0.84, 0.88), "fk": 1.05, "sc": 0.1, "gl": Color(1.0, 0.86, 0.76), "gk": 1.1,
			"sea": Color(0.95, 0.96, 0.97)}),
		k.call(9.5, {"el": 0.92, "az": -40.0}),
		k.call(12.0, {}),   # noon: exactly the mode's own look
		k.call(14.5, {"el": 0.95, "az": 14.0}),
		k.call(16.6, {"w": 0.35, "el": 0.7, "az": 26.0, "lk": 0.97, "sun": Color(1.0, 0.70, 0.46),
			"top": Color(0.24, 0.40, 0.70), "hor": Color(1.0, 0.82, 0.62), "gnd": Color(0.30, 0.30, 0.30),
			"fog": Color(0.92, 0.82, 0.70), "fk": 1.1, "sc": 0.15, "sat": 1.03, "gl": Color(1.0, 0.80, 0.55), "gk": 1.15}),
		# golden hour ("sunset"): a deep gold sun low in the west-north-west, orange horizon, warm haze glowing toward the sun
		k.call(17.75, {"w": 0.75, "el": 0.42, "az": 38.0, "lk": 0.9, "sun": Color(1.0, 0.60, 0.36), "amb": 0.95,
			"top": Color(0.28, 0.40, 0.66), "hor": Color(1.0, 0.64, 0.40), "gnd": Color(0.28, 0.24, 0.24),
			"fog": Color(0.95, 0.74, 0.58), "fk": 1.15, "sc": 0.45, "exp": 1.04, "sat": 1.0, "con": 1.03, "lights": 0.1,
			"night": 0.15, "gl": Color(1.0, 0.58, 0.28), "gk": 1.5}),
		k.call(18.3, {"w": 0.9, "el": 0.32, "az": 42.0, "lk": 0.0, "sun": Color(1.0, 0.42, 0.30), "amb": 1.0,
			"ambc": Color(0.34, 0.29, 0.44), "asky": 0.7, "top": Color(0.20, 0.20, 0.42), "hor": Color(0.85, 0.45, 0.42),
			"gnd": Color(0.08, 0.07, 0.09), "fog": Color(0.62, 0.45, 0.50), "fk": 1.2, "sc": 0.3, "exp": 1.12, "sat": 0.9,
			"lights": 0.7, "night": 0.45, "stars": 0.1, "gl": Color(1.0, 0.5, 0.4), "gk": 0.6, "glow": 0.95}),
		# dusk: the blue hour, every light on
		k.call(18.6, {"w": 0.95, "el": 0.3, "az": 44.0, "lk": 0.0, "amb": 1.15, "ambc": Color(0.27, 0.30, 0.52), "asky": 0.5,
			"top": Color(0.10, 0.13, 0.30), "hor": Color(0.40, 0.32, 0.45), "gnd": Color(0.05, 0.05, 0.08),
			"fog": Color(0.30, 0.30, 0.45), "fk": 1.0, "exp": 1.24, "sat": 0.8, "con": 0.98, "lights": 0.95, "night": 0.75,
			"stars": 0.5, "sun": Color(0.8, 0.7, 0.9), "gl": Color(0.8, 0.7, 0.9), "gk": 0.35, "glow": 0.9}),
		k.call(19.4, {}, NIGHT),
	]
	return KEYS


# ================================================================== setup

static func attach(g: Node) -> DayNight:
	var d := DayNight.new()
	d.name = "DayNight"
	d.game = g
	g.add_child(d)
	return d


func _ready() -> void:
	inst = self
	_depth = 0
	_goal = -1.0
	_sun = null; _env = null; _sky_mat = null; _sky_cover_base = null
	_sun_base.clear(); _env_base.clear(); _sky_base.clear(); _sky_last.clear()
	off = false
	fixed = false
	var test := false
	var t_arg := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--shot=") or a.begins_with("--ui-test"):
			test = true
		elif a.begins_with("--time="):
			t_arg = a.substr(7).to_lower()
		elif a == "--daynight=off":
			off = true
		elif a.begins_with("--sun-step="):
			sun_step = maxf(0.0, float(a.substr(11)))
		elif a.begins_with("--day-min="):
			day_min_arg = maxf(0.1, float(a.substr(10)))
	# the player's settings (GameSettings; GameUI loads the file a moment later and calls from_settings)
	mode = GameSettings.time_of_day if GameSettings.time_of_day in MODES else "cycle"
	paused = GameSettings.clock_paused
	day_min = float(GameSettings.day_length_min)
	if day_min_arg > 0.0:
		day_min = day_min_arg
	hour = 12.0
	if test:
		fixed = true
		mode = "noon"
		paused = false
	if t_arg != "":
		fixed = t_arg != "cycle"
		if t_arg in MODES:
			mode = t_arg
		elif t_arg.is_valid_float():
			mode = "hour"
			hour = fposmod(float(t_arg), 24.0)
		else:
			push_warning("daynight: unknown --time=%s (dawn, noon, sunset, night, cycle or an hour 0-24)" % t_arg)
	if PRESETS.has(mode):
		hour = PRESETS[mode]
	if off:
		print("daynight: off (--daynight=off)")
		return
	_capture()
	_apply()
	print("daynight: %s at %s (day %d min%s%s)" % [mode, clock_text(), int(day_min), ", paused" if paused else "", ", fixed for captures" if fixed else ""])


static func from_settings() -> void:
	## the saved settings were (re)loaded (GameSettings.load_cfg): follow them, unless a capture / test / --time
	## fixed the clock. A saved fixed time of day starts there at once.
	if inst == null or not is_instance_valid(inst) or fixed:
		return
	apply_settings(true)


static func apply_settings(snap := false) -> void:
	## GameSettings → the clock (the Settings window). A fixed capture / test clock follows too: the player (or the
	## test) changed a setting. snap: jump there (tests, start); otherwise the clock runs forward to it in a second or two.
	if inst == null or not is_instance_valid(inst):
		return
	fixed = false
	paused = GameSettings.clock_paused
	day_min = day_min_arg if day_min_arg > 0.0 else float(GameSettings.day_length_min)
	var m: String = GameSettings.time_of_day if GameSettings.time_of_day in MODES else "cycle"
	mode = m
	if PRESETS.has(m):
		if snap:
			hour = PRESETS[m]
			_goal = -1.0
		else:
			_goal = PRESETS[m]
	else:
		_goal = -1.0
	inst._dirty = true
	if snap:
		inst._apply_now()


static func set_time(t: String) -> void:
	## testing (hd_cycle.gd "@time", the day/night check): fix the clock at a preset, an hour, or "off" / "on"
	if inst == null or not is_instance_valid(inst):
		return
	if t == "off":
		if not off:
			_restore(true)
		off = true
		RenderingServer.global_shader_parameter_set("dn_lights", 0.0)
		RenderingServer.global_shader_parameter_set("dn_night", 0.0)
		RenderingServer.global_shader_parameter_set("dn_glint", Vector4(1.0, 0.92, 0.75, 1.0))
		RenderingServer.global_shader_parameter_set("dn_sea", Vector4(1.0, 1.0, 1.0, 1.0))
		return
	if off:
		off = false
		_capture()
	fixed = true
	_goal = -1.0
	if PRESETS.has(t):
		mode = t
		hour = PRESETS[t]
	elif t.is_valid_float():
		mode = "hour"
		hour = fposmod(float(t), 24.0)
	inst._apply_now()


static func clock_text() -> String:
	var m := int(round(hour * 60.0)) % 1440
	return "%02d:%02d" % [m / 60, m % 60]


static func running() -> bool:
	return not off and not fixed and not paused and mode == "cycle"


static func look() -> Dictionary:
	return _look


# ================================================================== bracket for the writers (hd_render, hdplus)

static func begin(with_sky := false) -> void:
	## before a writer sets its base lighting: put the base values back (so nothing compounds and duplicates of the
	## environment never inherit the night). with_sky: also the sky material (HDRender.apply duplicates it).
	if inst == null or not is_instance_valid(inst) or off:
		return
	if _depth == 0:
		_restore(with_sky)
	_depth += 1


static func end() -> void:
	if inst == null or not is_instance_valid(inst) or off:
		return
	_depth = maxi(_depth - 1, 0)
	if _depth == 0:
		_capture()
		inst._apply()


static func _restore(with_sky: bool) -> void:
	if _sun and is_instance_valid(_sun):
		for k in _sun_base:
			if k == "rotation_degrees" and (_sun_base[k] as Vector3).is_equal_approx(_sun.rotation_degrees):
				continue
			_sun.set(k, _sun_base[k])
	if _env:
		for k in _env_base:
			_env.set(k, _env_base[k])
	if with_sky and _sky_mat:
		for k in _sky_base:
			_sky_mat.set(k, _sky_base[k])
		_sky_mat.sky_cover = _sky_cover_base
		_sky_last.clear()


static func _capture() -> void:
	var g: Node = inst.game
	if g == null:
		return
	_sun = g.get_node_or_null("Sun") as DirectionalLight3D
	_sun_base.clear()
	if _sun:
		for k in SUN_KEYS:
			_sun_base[k] = _sun.get(k)
	_env = null
	for c in g.get_children():
		if c is WorldEnvironment:
			_env = (c as WorldEnvironment).environment
			break
	_env_base.clear()
	if _env:
		for k in ENV_KEYS:
			_env_base[k] = _env.get(k)
	var sm: ProceduralSkyMaterial = null
	if _env and _env.sky:
		sm = _env.sky.sky_material as ProceduralSkyMaterial
	if sm != _sky_mat:
		# a new sky (an HD switch duplicated the environment): its values are the base (restored before duplicating)
		_sky_mat = sm
		_sky_base.clear()
		_sky_last.clear()
		if sm:
			for k in SKY_KEYS:
				_sky_base[k] = sm.get(k)
			_sky_cover_base = sm.sky_cover


# ================================================================== the clock

func _process(delta: float) -> void:
	if off:
		return
	if _goal >= 0.0:
		var d := fposmod(_goal - hour, 24.0)
		var step := delta * TWEEN_H_PER_S
		if d <= step or d > 23.999:
			hour = _goal
			_goal = -1.0
		else:
			hour = fposmod(hour + step, 24.0)
		_dirty = true
	elif running():
		hour = fposmod(hour + delta * 24.0 / (maxf(day_min, 0.5) * 60.0), 24.0)
		_dirty = true
	_sky_t += delta
	if _dirty:
		_dirty = false
		_apply()


func _apply_now() -> void:
	_sky_t = 1.0
	_apply()


static func sample(h: float) -> Dictionary:
	## the look at hour h: keyframes blended with a smoothstep (cyclic over 24 h)
	var ks := _keys()
	var n := ks.size()
	var i := n - 1
	for j in n:
		if float(ks[j]["h"]) <= h:
			i = j
	var a: Dictionary = ks[i]
	var b: Dictionary = ks[(i + 1) % n]
	var ha := float(a["h"])
	var hb := float(b["h"]) if i + 1 < n else float(b["h"]) + 24.0
	var t := clampf((h - ha) / maxf(hb - ha, 1e-4), 0.0, 1.0)
	t = t * t * (3.0 - 2.0 * t)
	var out := {}
	for k in a:
		var va = a[k]
		if va is Color:
			out[k] = (va as Color).lerp(b[k], t)
		else:
			out[k] = lerpf(float(va), float(b[k]), t)
	out["h"] = h
	return out


func _apply() -> void:
	if off or game == null:
		return
	var L := sample(hour)
	_look = L
	var w: float = L["w"]
	# ---- the light: the sun by day (its base pose moved along an arc), the moon by night
	if _sun and is_instance_valid(_sun) and not _sun_base.is_empty():
		var br: Vector3 = _sun_base["rotation_degrees"]
		var bc: Color = _sun_base["light_color"]
		var be: float = _sun_base["light_energy"]
		var rot := MOON_ROT
		if hour >= SUN_UP and hour <= SUN_DOWN:
			rot = Vector3(-(-br.x * float(L["el"])), br.y - float(L["az"]), br.z)
			# the shadow-casting direction moves in SUN_STEP-degree steps: a light that turns a little every frame
			# re-renders the shadow map at a new angle each frame and the shadow edges crawl and shimmer
			# (the user's "shadow flicker", 2026-10-17). Colour and brightness stay smooth.
			if sun_step > 0.0:   # (snap only the offset from the base pose, so noon stays exactly the base pose)
				rot = br + Vector3(snappedf(rot.x - br.x, sun_step), snappedf(rot.y - br.y, sun_step), 0.0)
		if not rot.is_equal_approx(_sun.rotation_degrees):   # (an unchanged pose is not re-written: no float round trip)
			_sun.rotation_degrees = rot
		_sun.light_color = bc.lerp(L["sun"], w)
		_sun.light_energy = be * float(L["lk"])
		_sun.shadow_opacity = float(_sun_base["shadow_opacity"]) * float(L["sho"])
		RenderingServer.global_shader_parameter_set("hd_sun_dir", Basis.from_euler(_sun.rotation_degrees * PI / 180.0).z.normalized())
	# ---- ambient, exposure, grade, fog
	if _env and not _env_base.is_empty():
		_env.ambient_light_energy = float(_env_base["ambient_light_energy"]) * float(L["amb"])
		_env.ambient_light_color = (_env_base["ambient_light_color"] as Color).lerp(L["ambc"], w)
		_env.ambient_light_sky_contribution = lerpf(float(_env_base["ambient_light_sky_contribution"]), float(L["asky"]), w)
		_env.tonemap_exposure = float(_env_base["tonemap_exposure"]) * float(L["exp"])
		_env.adjustment_saturation = float(_env_base["adjustment_saturation"]) * float(L["sat"])
		_env.adjustment_contrast = float(_env_base["adjustment_contrast"]) * float(L["con"])
		_env.fog_light_color = (_env_base["fog_light_color"] as Color).lerp(L["fog"], w)
		_env.fog_density = float(_env_base["fog_density"]) * float(L["fk"])
		_env.fog_sun_scatter = float(_env_base["fog_sun_scatter"]) + float(L["sc"])
		_env.glow_hdr_threshold = float(_env_base["glow_hdr_threshold"]) * float(L["glow"])
	# ---- the sky (it feeds the ambient light and the sea's reflections): throttled, each change re-filters the radiance
	if _sky_mat and not _sky_base.is_empty() and (_sky_t >= 0.25 or _sky_last.is_empty()):
		_sky_t = 0.0
		var want := {
			"sky_top_color": (_sky_base["sky_top_color"] as Color).lerp(L["top"], w),
			"sky_horizon_color": (_sky_base["sky_horizon_color"] as Color).lerp(L["hor"], w),
			"ground_horizon_color": (_sky_base["ground_horizon_color"] as Color).lerp((L["hor"] as Color) * 0.8, w),
			"ground_bottom_color": (_sky_base["ground_bottom_color"] as Color).lerp(L["gnd"], w),
		}
		var st := float(L["stars"])
		if st > 0.001 and _sky_mat.sky_cover == null:
			_sky_mat.sky_cover = _star_tex()
		# the stars only once they are ours (a sky without them keeps its own cover modulate, so noon is untouched)
		want["sky_cover_modulate"] = Color(1, 1, 1, st) if (_stars and _sky_mat.sky_cover == _stars) else _sky_base["sky_cover_modulate"]
		var changed := false
		for k in want:
			var o = _sky_last.get(k)
			var v: Color = want[k]
			if o == null or absf(v.r - o.r) + absf(v.g - o.g) + absf(v.b - o.b) + absf(v.a - o.a) > 0.003:
				changed = true
				break
		if changed:
			for k in want:
				_sky_mat.set(k, want[k])
			_sky_last = want
			if running() and _env and _env.sky and _env.sky.process_mode != Sky.PROCESS_MODE_INCREMENTAL:
				_env.sky.process_mode = Sky.PROCESS_MODE_INCREMENTAL   # spread the re-filtering over frames (no spikes)
	# ---- shader globals: city lights, darkness, the glitter path on the sea
	RenderingServer.global_shader_parameter_set("dn_lights", float(L["lights"]))
	RenderingServer.global_shader_parameter_set("dn_night", float(L["night"]))
	var gc: Color = L["gl"]
	RenderingServer.global_shader_parameter_set("dn_glint", Vector4(gc.r, gc.g, gc.b, float(L["gk"])))
	var sc: Color = L["sea"]
	RenderingServer.global_shader_parameter_set("dn_sea", Vector4(sc.r, sc.g, sc.b, (sc.r + sc.g + sc.b) / 3.0))


static func _star_tex() -> ImageTexture:
	## the night sky's stars: an equirectangular panorama for ProceduralSkyMaterial.sky_cover (upper half only),
	## a few thousand points of varied brightness and tint plus a faint band of the Milky Way; made once, seeded
	if _stars:
		return _stars
	var W := 2048
	var H := 1024
	var img := Image.create(W, H, false, Image.FORMAT_RGB8)
	img.fill(Color(0, 0, 0))
	var rng := RandomNumberGenerator.new()
	rng.seed = 1948
	for i in 4200:
		var x := rng.randi() % W
		var y := int(pow(rng.randf(), 1.15) * (H * 0.5 - 4))
		var m := pow(rng.randf(), 7.0)
		var b := 0.12 + 0.88 * m
		var tint := Color(0.85 + 0.15 * rng.randf(), 0.9, 1.0) if rng.randf() < 0.7 else Color(1.0, 0.92, 0.8)
		img.set_pixel(x, y, tint * b)
		if m > 0.5:   # the brightest few get a soft cross
			for o in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var p: Vector2i = Vector2i(x, y) + o
				if p.x >= 0 and p.x < W and p.y >= 0 and p.y < H:
					img.set_pixel(p.x, p.y, tint * b * 0.35)
	for i in 9000:   # the Milky Way: a faint band of dust across the sky
		var u := rng.randf()
		var x := int(u * W)
		var yc := H * (0.18 + 0.12 * sin(u * TAU * 1.0 + 0.6))
		var y := int(yc + rng.randfn(0.0, H * 0.035))
		if y >= 0 and y < H / 2:
			var c := img.get_pixel(x, y)
			img.set_pixel(x, y, c + Color(0.05, 0.055, 0.07) * rng.randf())
	_stars = ImageTexture.create_from_image(img)
	return _stars
