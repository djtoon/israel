class_name GfxTier
extends RefCounted
## perf60: the graphics tier ladder, from the richest look to the cheapest. A tier is one graphics mode (SD / HD / HD+,
## Quality), its SD preset, the upscaling, and a few "levers" that change what costs GPU time. The first-launch
## detector (scripts/ui/gfx_detect.gd) walks down this ladder until the map renders inside the 60 fps budget, the
## run-time safety net (GameUI) drops one step, and Settings → Display "Graphics preset" picks one directly.
##
## Levers (absent = the mode's own value, so the top of each mode looks exactly as before):
##   ssil      false: no screen-space indirect light (HD's bounce light)
##   ssao      false: no ambient occlusion
##   splits    2 or 4 directional shadow splits
##   shadow_k  x the shadow distance (HD: x the zoom-adaptive distance of HDRender._on_cam_moved)
##   pcss      false: hard-edged filtered shadows (no PCSS soft shadows, low soft-shadow filter)
##   msaa      0 / 1 / 2 = off / 2x / 4x (ignored while FSR 2 runs: it brings its own antialiasing)
##   fxaa      true: FXAA (cheap edge smoothing when MSAA is off)
##   scale     3D render scale below 1 (FSR 1 upscaling, which compiles in an instant, unlike FSR 2's first use) when
##             FSR 2 is not on; MSAA stays unless "msaa" says otherwise
##   glow      false: no glow
##   fx        HD+ effects (HDPlus.ALL_FX subset)
##   tree_k    x the near-tree LOD distance (TreeKit)
##   art_mid   kit buildings show their mid LOD (ArtKit) from this distance instead of their full model (0 = never)
##   shadow_proxy  false: kit buildings cast shadows from their full models (default: from the mid LOD)
##   web only: shadows (false: no sun shadows), world_scale (the 3D map's resolution, WorldView), canvas_scale (the
##   canvas's pixel ratio, 0 = the display's), terrain_lite, trees (the share of trees drawn), tree_shadows (false: no
##   tree ground shadows), shadow_size
## [graphics] tier = "<name>" in user://game.cfg (GameSettings.gfx_tier); "custom" = the player set the separate rows
## (Quality, SD / HD, Upscaling) himself, so no lever applies. --tier=<name> overrides it for one run (captures, tests).

const LADDER := ["hdplus", "hdplus_lite", "hd", "hd_fast", "sd_high", "sd_medium", "sd_low", "sd_min"]
const TIERS := {
	"hdplus": {"mode": "hdplus", "quality": "high"},
	"hdplus_lite": {"mode": "hdplus", "quality": "high", "ssil": false, "pcss": false, "fx": ["clouds", "season", "terrain", "foliage", "decals"]},
	"hd": {"mode": "hd", "quality": "high"},
	"hd_fast": {"mode": "hd", "quality": "high", "scale": 0.77, "ssil": false, "pcss": false, "splits": 2, "shadow_far": true, "msaa": 0, "fxaa": true},
	"sd_high": {"mode": "sd", "quality": "high"},
	"sd_medium": {"mode": "sd", "quality": "medium"},
	"sd_low": {"mode": "sd", "quality": "low", "art_mid": 5.0, "shadow_far": true},
	"sd_min": {"mode": "sd", "quality": "low", "scale": 0.67, "msaa": 0, "fxaa": true, "art_mid": 4.0, "shadow_far": true, "tree_k": 0.7},
	# web (HTML5, Compatibility renderer on WebGL 2): the SD look without what WebGL lacks or pays dearly for (no SSAO,
	# no HD / HD+). Only these two exist in the web build (WEB_LADDER); the desktop ladder never offers them.
	# (no glow on the web: the Compatibility renderer checks its glow framebuffers every frame, a WebGL sync point)
	# (art_mid: the kit buildings' far LOD, about 500 triangles, from build/web's web_far models, from this distance)
	"web": {"mode": "sd", "quality": "medium", "ssao": false, "msaa": 1, "splits": 2, "glow": false, "art_mid": 5.0, "shadow_k": 0.7,
		"canvas_scale": 0.0, "world_scale": 1.0},
	# web_low (integrated graphics, measured on a Radeon 610M, 2026-10-18): no sun shadows (they cost a third of the
	# frame), the kit buildings' 500-triangle far LOD from 1 unit, 40 % of the trees, a coarser terrain grid, the 3D map
	# at 0.66 of the page's CSS pixels with the UI at the display's full resolution (WorldView), 30 fps. The near trees'
	# range and their ground shadows are the web tier's (they measured free).
	"web_low": {"mode": "sd", "quality": "low", "ssao": false, "msaa": 0, "splits": 2, "glow": false,
		"art_mid": 1.0, "shadows": false, "canvas_scale": 0.0, "world_scale": 0.66, "terrain_lite": true, "trees": 0.4},
}
const WEB_LADDER := ["web", "web_low"]
## the label of each tier in Settings and in the detector's note
const LABELS := {"hdplus": "HD+", "hdplus_lite": "HD+ lite", "hd": "HD", "hd_fast": "HD fast", "sd_high": "SD high",
	"sd_medium": "SD medium", "sd_low": "SD low", "sd_min": "SD low, reduced resolution",
	"web": "Web", "web_low": "Web, lighter"}
const SAFE := "sd_medium"   # the detector's fallback when it cannot measure

static var levers := {}       # the active tier's levers ({} = none: custom, or a capture without --tier)
static var active := ""       # the active tier name ("" = none / custom)
static var _forced := ""      # --tier=<name>


static func _with_args(lv: Dictionary) -> Dictionary:
	## --lever=<name>:<value> (tests, e.g. --lever=shadows:true --lever=trees:1): one lever changed for one run
	var out := lv
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--lever=") and ":" in a:
			var kv := a.substr(8).split(":", true, 1)
			if out == lv:
				out = lv.duplicate()
			out[kv[0]] = true if kv[1] == "true" else (false if kv[1] == "false" else float(kv[1]))
	return out


static func web() -> bool:
	## the web (HTML5) build, or its source copy (build/web/src/game) run natively: the project setting israel/web_look
	## exists only in that copy (build/web/refresh_src.sh). The desktop game never has it.
	return OS.has_feature("web") or bool(ProjectSettings.get_setting("israel/web_look", false))


static func ladder() -> Array:
	## the tiers this build offers: the desktop ladder, or the two web tiers
	return WEB_LADDER if web() else LADDER


static func web_default() -> String:
	## web: no GPU timer to benchmark with (WebGL), so a fixed tier from the adapter: integrated or software graphics
	## get the lighter one. --gpu-prior=integrated forces it (test).
	var n := RenderingServer.get_video_adapter_name().to_lower()
	if OS.has_feature("web"):   # (WebGL reports "WebKit WebGL"; the unmasked name says which GPU the browser uses: the
		# game context's own (window.ibnGpu: its high-performance hint can put it on the discrete GPU), else a probe's)
		n = str(JavaScriptBridge.eval("(() => { if (window.ibnGpu) { return window.ibnGpu; } try { const gl = document.createElement('canvas').getContext('webgl2'); const e = gl.getExtension('WEBGL_debug_renderer_info'); return e ? gl.getParameter(e.UNMASKED_RENDERER_WEBGL) : ''; } catch (x) { return ''; } })()", true)).to_lower()
	# web_low unless the GPU is clearly a discrete one (most laptops run the browser on their integrated GPU; Firefox
	# reports a generic "or similar" name, which counts as unknown): NVIDIA GeForce / RTX / GTX / Quadro, AMD Radeon RX /
	# Pro W, Intel Arc A / B (not the integrated "Arc Graphics")
	var nv := "nvidia" in n or "geforce" in n or "rtx" in n or "gtx" in n or "quadro" in n
	var amd := "radeon" in n and (" rx " in n or "rx " in n or "pro w" in n)
	var discrete := nv or amd or "arc(tm) a" in n or "arc a" in n or "arc b" in n
	var weak := not discrete or "or similar" in n
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--gpu-prior="):
			weak = a.substr(12) != "discrete"
	return "web_low" if weak else "web"


static func valid(t: String) -> bool:
	return TIERS.has(t) and ladder().has(t)


static func label(t: String) -> String:
	return str(LABELS.get(t, "Custom"))


static func index(t: String) -> int:
	return ladder().find(t)


static func forced() -> String:
	if _forced == "":
		_forced = "-"
		for a in OS.get_cmdline_user_args():
			if a.begins_with("--tier="):
				_forced = a.substr(7)
	return _forced if valid(_forced) else ""


static func select(t: String) -> void:
	## make t the active tier (its levers apply on the next apply()); also sets Quality's mode, preset and upscaling
	if not valid(t):
		active = ""
		levers = {}
		return
	active = t
	levers = _with_args(TIERS[t])
	var m: String = levers["mode"]
	Quality.hd = m != "sd"
	Quality.plus = m == "hdplus"
	Quality.level = str(levers.get("quality", "medium"))
	Quality.fsr = bool(levers.get("fsr", false))
	HDPlus.set_effects(levers.get("fx", HDPlus.ALL_FX) as Array)


static func to_settings(t: String) -> void:
	## the tier into the Settings values (GameSettings: saved by the caller)
	if not valid(t):
		return
	var lv: Dictionary = TIERS[t]
	GameSettings.gfx_tier = t
	GameSettings.graphics_hd = lv["mode"] != "sd"
	GameSettings.graphics_plus = lv["mode"] == "hdplus"
	GameSettings.quality = str(lv.get("quality", "medium"))
	GameSettings.upscaling = bool(lv.get("fsr", false))


static func apply_live(game: Node, t: String) -> void:
	## switch to tier t now (Settings, the detector, the safety net, hd_cycle). Never saves.
	select(t)
	GameSettings.graphics_hd = Quality.hd
	GameSettings.graphics_plus = Quality.plus
	GameSettings.quality = Quality.level
	GameSettings.upscaling = Quality.fsr
	if game == null or not game.is_inside_tree():
		return
	HDRender.apply(game, Quality.hd)
	if not Quality.hd:
		GameSettings.apply_quality(game)
	apply(game)
	if web():
		GameSettings.apply_fps()   # (web_low caps at 30)


static func _arg_f(key: String, def: float) -> float:
	for a in OS.get_cmdline_user_args():
		if a.begins_with(key):
			return float(a.substr(key.length()))
	return def


static func web_canvas_scale() -> void:
	## web: the canvas's pixel ratio (the page's window.ibnSetScale: Godot sizes its canvas by the pixel ratio the page
	## reports): the page's CSS pixels (1.0) on every tier, so the UI text is never blurred; "canvas_scale" (or
	## --canvas-scale=) 0 = the display's own pixel ratio. The 3D map's own resolution is "world_scale" (web_world_scale).
	if OS.has_feature("web"):
		var cs := _arg_f("--canvas-scale=", float(levers.get("canvas_scale", 1.0)))
		JavaScriptBridge.eval("window.ibnSetScale && window.ibnSetScale(%.3f)" % cs, true)


static func web_world_scale(game: Node) -> void:
	## web: the 3D map's resolution, "world_scale" (or --world-scale=) of the page's CSS pixels; below 1 the map renders
	## into WorldView's SubViewport, the UI stays at the canvas's full resolution
	var ws := _arg_f("--world-scale=", float(levers.get("world_scale", 1.0)))
	var pr := 1.0   # the canvas's pixels per CSS pixel
	if OS.has_feature("web"):
		pr = maxf(0.25, float(JavaScriptBridge.eval("window.ibnScaleNow ? window.ibnScaleNow() : 1", true)))
	var k := minf(1.0, ws / pr)
	var vp := game.get_viewport()
	if bool(levers.get("world_native", false)):
		# the renderer's own 3D scale (bilinear) instead of a SubViewport: needs the page's stencil-blit fix on Windows
		# browsers (build/web/shell/index.html; Godot #119317, fixed in 4.8)
		WorldView.apply(game, 1.0)
		vp.scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
		vp.scaling_3d_scale = k
	else:
		vp.scaling_3d_scale = 1.0
		WorldView.apply(game, k)


static func shadow_k() -> float:
	return float(levers.get("shadow_k", 1.0))


static func apply(game: Node) -> void:
	## the active tier's levers on top of what HDRender / the SD preset just set. Called after every graphics switch
	## (GameSettings.apply_graphics_mode / apply_quality / apply_upscaling) and at start (main.gd).
	if game == null or not game.is_inside_tree():
		return
	var vp := game.get_viewport()
	var sun := game.get_node_or_null("Sun") as DirectionalLight3D
	var env: Environment = null
	for c in game.get_children():
		if c is WorldEnvironment:
			env = (c as WorldEnvironment).environment
	var fsr2 := vp.scaling_3d_mode == Viewport.SCALING_3D_MODE_FSR2
	# render scale (FSR 1) when FSR 2 is not on; back to native otherwise
	if not fsr2:
		var sc := float(levers.get("scale", 1.0))
		vp.scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR if sc < 0.999 and not web() else Viewport.SCALING_3D_MODE_BILINEAR   # (no FSR in the Compatibility renderer)
		vp.scaling_3d_scale = sc
		if sc < 0.999:
			vp.fsr_sharpness = float(levers.get("sharpness", 1.0))   # (FSR 1's default sharpening turned the facades grainy)
		if levers.has("msaa"):
			vp.msaa_3d = [Viewport.MSAA_DISABLED, Viewport.MSAA_2X, Viewport.MSAA_4X][int(levers["msaa"])]
	vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA if bool(levers.get("fxaa", false)) else Viewport.SCREEN_SPACE_AA_DISABLED
	if env:
		if levers.has("ssil"):
			env.ssil_enabled = bool(levers["ssil"]) and Quality.hd
		if levers.has("ssao"):
			env.ssao_enabled = bool(levers["ssao"])
		if levers.has("glow"):
			env.glow_enabled = bool(levers["glow"])
	if sun:
		if levers.has("shadows"):   # (web_low)
			sun.shadow_enabled = bool(levers["shadows"])
		elif web() and not sun.shadow_enabled:   # (back from web_low to web: shadows again)
			sun.shadow_enabled = true
		if levers.has("splits"):
			var sp_n := int(levers["splits"])
			sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS if sp_n == 4 else (DirectionalLight3D.SHADOW_ORTHOGONAL if sp_n == 1 else DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS)
		if web():   # (web_low: a smaller shadow map)
			RenderingServer.directional_shadow_atlas_set_size(int(levers.get("shadow_size", 4096)), true)
		if levers.has("pcss") and not bool(levers["pcss"]):
			sun.light_angular_distance = 0.0
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
		if not Quality.hd and levers.has("shadow_k"):
			sun.directional_shadow_max_distance = float(Quality.current()["shadow_dist"]) * shadow_k()
	TreeKit.set_near_k(float(levers.get("tree_k", 1.0)))
	if web():   # web_low: the terrain's cheap fragment path (terrain.gdshader LITE)
		var rr = game.get("renderer")
		if rr != null and rr.terrain_mat != null:
			rr.terrain_mat.set_shader_parameter("web_lite", 1.0 if bool(levers.get("terrain_lite", false)) else 0.0)
	# kit-building LODs: the mid LOD's range and the shadow proxies (CityBuilder.relod when they change)
	var am := float(levers.get("art_mid", 0.0))
	var sp := bool(levers.get("shadow_proxy", true))
	var sf := bool(levers.get("shadow_far", false))
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--art-mid="):
			am = float(a.substr(10))
		elif a == "--shadow-proxy=off":
			sp = false
		elif a == "--shadow-far":
			sf = true
	if am != CityBuilder.art_mid or sp != CityBuilder.shadow_proxy or sf != CityBuilder.shadow_far:
		CityBuilder.art_mid = am
		CityBuilder.shadow_proxy = sp
		CityBuilder.shadow_far = sf
		var r = game.get("renderer")
		if r != null and r.cities != null and r.cities.R != null:
			r.cities.relod()
	var rig = game.get("rig")
	if Quality.hd and rig is CameraRig:
		HDRender._on_cam_moved(rig, sun)   # the zoom-adaptive shadow range with shadow_k
	if web():
		web_canvas_scale()   # (also at start)
		web_world_scale(game)   # (web_low: the map at 0.66, the UI sharp)


static func from_cfg(cf: ConfigFile) -> void:
	## Quality.current(): the saved tier (its levers; Quality's mode, preset and upscaling are saved beside it)
	var t := str(cf.get_value("graphics", "tier", ""))
	if valid(t):
		active = t
		levers = _with_args(TIERS[t])
		var flags := false
		for a in OS.get_cmdline_user_args():
			flags = flags or a.begins_with("--fx")
		if levers.has("fx") and not flags:
			HDPlus.set_effects(levers["fx"] as Array)


static func capture_reset() -> void:
	## captures (--shot) without --tier keep the plain modes, as before the tiers existed
	active = ""
	levers = {}
