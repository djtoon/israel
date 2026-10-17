class_name HDPlus
extends RefCounted
## HD+ effects, ported from the HD lab (build/hd_lab/HD_LAB.md) and approved by the user (2026-10-14): Settings →
## Graphics "HD+" = HD plus these effects (Quality.plus). Plain HD gets only the HD bug fixes of the terrain shader
## (Ramon cliff walls, far-field checkerboard: global hdp_terrain = 0.5) and the optional FSR 2. SD never calls
## into this file's effects.
##
##   dof       tilt-shift depth of field focused on the hex at the screen centre
##   clouds    drifting cloud shadows on every map shader
##   caustics  seabed caustics in the shallows
##   season    the quarter's season (from the map date) drives the sun, haze and grade, and greens / dries the ground
##   terrain   height-blended slopes and triplanar cliff normals; also the cliff-wall and far-field fixes
##   foliage   wind gusts and back-lit translucency on trees and palms
##   decals    worn roads, wet sand, field tracks, city grime (procedural masks)
##
## Testing flags (imply HD+): --fx=a,b (exactly these), --fx=none (HD+ without effects = HD), --fx-off=a,b,
## --season=winter|spring|summer|autumn. Upscaling (Settings → "Upscaling (faster)": FSR 2 at 0.77) is a
## separate option, Quality.fsr, applied here in HD and HD+. Shader side: hdplus.gdshaderinc (globals hdp_*).

const ALL_FX := ["dof", "clouds", "caustics", "season", "terrain", "foliage", "decals"]
const FSR_SCALE := 0.77

# seasons: sun pitch offset (deg), sun colour, energy x, fog x, fog colour, saturation, contrast, exposure,
# grade tint (shadows, highlights), shader season (x: -1 green .. +1 dry, y: cloud cover +more).
# Summer haze is milder than in the lab (fog 1.7 -> 1.2, a less sandy fog colour, a lighter warm grade), so the
# sea keeps its blue.
const SEASONS := {
	"winter": {"pitch": 3.0, "sun": Color(1.0, 0.90, 0.80), "energy": 0.96, "fog": 0.55, "fog_col": Color(0.76, 0.82, 0.88),
		"sat": 1.22, "con": 1.16, "exp": 1.04, "lo": Color(0.92, 0.98, 1.08), "hi": Color(0.98, 1.0, 1.02), "shader": Vector4(-1.0, 1.0, 0, 0)},
	"spring": {"pitch": 0.0, "sun": Color(1.0, 0.78, 0.55), "energy": 1.0, "fog": 1.0, "fog_col": Color(0.80, 0.82, 0.84),
		"sat": 1.25, "con": 1.13, "exp": 1.08, "lo": Color(1, 1, 1), "hi": Color(1, 1, 1), "shader": Vector4(0.0, 0.0, 0, 0)},
	"summer": {"pitch": -7.0, "sun": Color(1.0, 0.75, 0.48), "energy": 1.04, "fog": 1.2, "fog_col": Color(0.84, 0.84, 0.80),
		"sat": 1.2, "con": 1.09, "exp": 1.09, "lo": Color(1.03, 1.0, 0.96), "hi": Color(1.03, 1.0, 0.93), "shader": Vector4(1.0, -1.0, 0, 0)},
	"autumn": {"pitch": 1.5, "sun": Color(1.0, 0.76, 0.52), "energy": 0.98, "fog": 1.1, "fog_col": Color(0.84, 0.82, 0.78),
		"sat": 1.21, "con": 1.12, "exp": 1.07, "lo": Color(1.02, 1.0, 0.97), "hi": Color(1.02, 1.0, 0.95), "shader": Vector4(0.45, 0.4, 0, 0)},
}

static var fx := {}           # effect name -> true when on
static var _parsed := false
static var active := false    # HD or HD+ (upscaling, terrain bug fixes)
static var plus := false      # HD+: the effects in fx
static var season := "spring"
static var _attr: CameraAttributesPractical
static var _base_grade: GradientTexture1D
static var _base_env := {}
static var _base_scale := {}


static func parse() -> void:
	## the effect set: all of ALL_FX unless the --fx= / --fx-off= testing flags say otherwise
	fx.clear()
	_parsed = true
	var set_: Array = ALL_FX.duplicate()
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--fx="):
			set_ = Array(a.substr(5).split(",", false))
			set_.erase("none")
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--fx-off="):
			for n in a.substr(9).split(",", false):
				set_.erase(n)
	for n in set_:
		if ALL_FX.has(n):
			fx[n] = true
		else:
			push_warning("hdplus: unknown effect '%s' (known: %s)" % [n, ", ".join(ALL_FX)])


static func on(n: String) -> bool:
	return plus and fx.get(n, false)


static func apply(game: Node, env: Environment, sun: DirectionalLight3D, hd_on: bool) -> void:
	## called by HDRender.apply after the HD setup (hd_on false when switching to SD). Every effect is set or
	## reset here, so SD / HD / HD+ and the effect set can be switched live (Settings, scripts/map/hd_cycle.gd).
	if not _parsed:
		parse()
	active = hd_on
	plus = hd_on and Quality.plus
	var vp := game.get_viewport()
	if env and _base_env.is_empty():
		_base_grade = env.adjustment_color_correction as GradientTexture1D
		for k in ["adjustment_saturation", "adjustment_contrast", "tonemap_exposure", "fog_light_color"]:
			_base_env[k] = env.get(k)
	_globals()
	var cam: Camera3D = game.get("rig").cam if game.get("rig") else null
	# ---- reset to plain HD, then switch on what is asked for
	if env:
		for k in _base_env:
			env.set(k, _base_env[k])
		env.adjustment_color_correction = _base_grade
	if sun and hd_on:
		sun.light_color = Color(1.0, 0.78, 0.55)   # HDRender._hd_sun
	if cam and _attr and cam.attributes == _attr:
		cam.attributes = null
	apply_upscaling(vp)
	if not plus:
		if active:
			print("hdplus: HD (no HD+ effects)")
		return
	print("hdplus: effects ", ", ".join(PackedStringArray(fx.keys())))
	var r = game.get("renderer")
	if r is TerrainRenderer and r.terrain_mat:
		r.terrain_mat.set_shader_parameter("hdp_caustic_tex", load(HDRender.HD_DIR + "hdp_caustics.png") as Texture2D)
	if cam and on("dof"):
		if _attr == null:
			_attr = CameraAttributesPractical.new()
		cam.attributes = _attr
		RenderingServer.camera_attributes_set_dof_blur_quality(RenderingServer.DOF_BLUR_QUALITY_HIGH, false)
		RenderingServer.camera_attributes_set_dof_blur_bokeh_shape(RenderingServer.DOF_BOKEH_CIRCLE)
	on_date(game, env, sun)


static func apply_upscaling(vp: Viewport) -> void:
	## Settings "Upscaling (faster)": FSR 2 at 0.77 render scale, in HD and HD+ only (FSR 2 brings its own temporal
	## antialiasing, so MSAA is off while it runs). Off restores the native render and HD's MSAA 2x.
	if vp == null:
		return
	if _base_scale.is_empty():
		_base_scale = {"mode": vp.scaling_3d_mode, "scale": vp.scaling_3d_scale}
	var want := active and Quality.fsr
	if want:
		vp.msaa_3d = Viewport.MSAA_DISABLED
		vp.scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR2
		vp.scaling_3d_scale = FSR_SCALE
		vp.fsr_sharpness = 0.35
		print("hd: upscaling FSR 2 at %.2f" % FSR_SCALE)
	elif vp.scaling_3d_mode == Viewport.SCALING_3D_MODE_FSR2:
		vp.scaling_3d_mode = _base_scale["mode"]
		vp.scaling_3d_scale = _base_scale["scale"]
		if active:
			vp.msaa_3d = Viewport.MSAA_2X   # HDRender's HD antialiasing
		# (in SD, HDRender has just restored the preset's MSAA)


static func set_effects(names: Array) -> void:
	## hd_cycle.gd: the HD+ effect set for the next HDRender.apply
	fx.clear()
	_parsed = true
	for n in names:
		fx[n] = true


static func _globals() -> void:
	RenderingServer.global_shader_parameter_set("hdp_clouds", 0.3 if on("clouds") else 0.0)
	RenderingServer.global_shader_parameter_set("hdp_caustics", 1.0 if on("caustics") else 0.0)
	# 1 = HD+ terrain (height blend, soil, triplanar); 0.5 = only the HD bug fixes (Ramon walls, far field)
	RenderingServer.global_shader_parameter_set("hdp_terrain", 1.0 if on("terrain") else (0.5 if active else 0.0))
	RenderingServer.global_shader_parameter_set("hdp_foliage", 1.0 if on("foliage") else 0.0)
	RenderingServer.global_shader_parameter_set("hdp_decals", 1.0 if on("decals") else 0.0)
	var sv: Vector4 = SEASONS[season]["shader"] if on("season") else Vector4.ZERO
	RenderingServer.global_shader_parameter_set("hdp_season", sv)


static func on_date(game: Node, env: Environment = null, sun: DirectionalLight3D = null) -> void:
	## the quarter's season (map date middle month: Feb winter, May spring, Aug summer, Nov autumn); called on
	## every map date change (TerrainRenderer.apply_date) and on each HD switch
	if not plus or game == null:
		return
	DayNight.begin()   # v5: the season is set on the base look; the time of day goes on top at end()
	var s := "spring"
	var m: MapData = game.get("map")
	if m and str(m.date).length() >= 7:
		var mon := int(str(m.date).substr(5, 2))
		s = "winter" if mon <= 3 or mon == 12 else ("spring" if mon <= 5 else ("summer" if mon <= 9 else "autumn"))
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--season="):
			s = a.substr(9)
	if not SEASONS.has(s):
		s = "spring"
	var changed := s != season
	season = s
	if env == null:
		env = HDRender._hd_env
	if sun == null:
		sun = game.get_node_or_null("Sun") as DirectionalLight3D
	_globals()
	if env and on("season"):
		var p: Dictionary = SEASONS[s]
		env.adjustment_saturation = p["sat"]
		env.adjustment_contrast = p["con"]
		env.tonemap_exposure = p["exp"]
		env.fog_light_color = p["fog_col"]
		env.adjustment_color_correction = _tinted_grade(p["lo"], p["hi"])
		if sun:
			sun.light_color = p["sun"]
	if changed:
		print("hdplus: season %s (map date %s)" % [s, str(m.date) if m else "?"])
	var rig = game.get("rig")
	if rig is CameraRig:
		HDRender._on_cam_moved(rig, sun)
	DayNight.end()


static func _tinted_grade(lo: Color, hi: Color) -> GradientTexture1D:
	if _base_grade == null:
		return null
	if lo == Color(1, 1, 1) and hi == Color(1, 1, 1):
		return _base_grade
	var g := _base_grade.gradient.duplicate() as Gradient
	var cols := g.colors
	for i in cols.size():
		var k := lo.lerp(hi, g.offsets[i])
		cols[i] = Color(cols[i].r * k.r, cols[i].g * k.g, cols[i].b * k.b)
	g.colors = cols
	var tex := GradientTexture1D.new()
	tex.gradient = g
	tex.width = 256
	return tex


static func on_cam(rig: CameraRig, sun: DirectionalLight3D, env: Environment, far: float) -> void:
	## after HDRender's zoom-adaptive values: season scaling and the depth-of-field focus
	if not plus or rig.cam == null:
		return
	if on("season"):
		var p: Dictionary = SEASONS[season]
		env.fog_density *= p["fog"]
		if sun:
			sun.light_color = p["sun"]
			sun.light_energy *= p["energy"]
			sun.rotation_degrees.x += p["pitch"] * (1.0 - far * 0.6)
			RenderingServer.global_shader_parameter_set("hd_sun_dir", Basis.from_euler(sun.rotation_degrees * PI / 180.0).z.normalized())
	if on("dof") and _attr:
		_dof(rig)


static func _dof(rig: CameraRig) -> void:
	## tilt-shift: focus on the ground at the screen centre (the hex being looked at, found by marching the
	## terrain height), keep a margin of about a hex around it sharp, blur the foreground and the far map.
	## Strongest at strategy zoom, fading out up close. Labels, banners and flags are 2D and stay sharp.
	var cam := rig.cam
	var vs := cam.get_viewport().get_visible_rect().size
	var y := 0.1
	var hit := Vector3.ZERO
	for i in 4:
		hit = rig.ground_point(vs * 0.5, y)
		y = maxf(0.0, rig.height_fn.call(hit.x, hit.z)) if rig.height_fn.is_valid() else 0.0
	var fd := cam.global_position.distance_to(hit)
	var z := rig.zoom
	# gentler than the lab (2026-10-14): at city zoom the lab's blur made the far blocks and towers soft, so the
	# sharp band is deeper (about a third of the focus distance beyond it) and the blur lighter, still strongest at
	# strategy zoom and gone up close
	var keep := maxf(1.6, fd * 0.22)
	_attr.dof_blur_far_enabled = true
	_attr.dof_blur_far_distance = fd + keep * 1.5
	_attr.dof_blur_far_transition = fd * 1.1 + 2.0
	_attr.dof_blur_near_enabled = true
	_attr.dof_blur_near_distance = maxf(0.3, fd - keep)
	_attr.dof_blur_near_transition = fd * 0.4
	_attr.dof_blur_amount = lerpf(0.025, 0.06, smoothstep(0.6, 1.1, z)) * lerpf(1.0, 0.15, smoothstep(1.4, 2.6, z))
