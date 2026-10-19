class_name GfxDetect
extends CanvasLayer
## perf60: the first-launch graphics detector ("Optimizing graphics for your computer..."). It runs once, when no
## graphics choice is saved yet ([graphics] tier in user://game.cfg), right after the language prompt and before the
## intro; again from Settings → Display → "Detect best settings"; and with the --detect capture flag.
##
## 1. A prior from the graphics adapter (RenderingServer.get_video_adapter_name / _vendor / _type): where on the
##    GfxTier ladder to start, and the highest tier allowed (integrated GPUs never go above SD high; software
##    renderers stay at the bottom). VRAM is not exposed by Godot, so it is not used.
## 2. A short GPU-time benchmark: the map renders behind the dimmed overlay while the camera pans slowly; each tier is
##    switched in live (which also compiles its shaders and pipelines), warmed for a few frames, then the viewport's
##    measured GPU time is sampled (RenderingServer.viewport_get_measured_render_time_gpu). Step down the ladder until
##    the 95th percentile is at most BUDGET_MS (13 ms: headroom inside the 16.7 ms of a 60 fps frame); a tier far under
##    the budget tries one step up (if the prior allows). At most MAX_S seconds of measuring.
## 3. The tier is applied and saved, and one line says so: "Graphics set to HD (60 fps). You can change this in Settings."
## If it cannot measure (no GPU timing), it falls back to GfxTier.SAFE (SD medium), never above the prior's cap.
## Test flags: --gpu-prior=integrated|discrete|software (force the adapter kind), --detect-shot=<path.png> (a screenshot
## of the screen mid-run), --detect-budget=<ms>.

signal finished(tier: String)

const BUDGET_MS := 13.0
const MAX_S := 6.0           # no new tier is tried after this; HARD_S stops even mid-tier; the result line stays NOTE_S
const HARD_S := 7.5
const NOTE_S := 1.6
const WARM := 8              # frames after a switch that are not measured (shader / pipeline compiles, clocks)
const QUIET := 5             # ... and until this many frames in a row compiled no pipeline (at most WARM_MS)
const WARM_MS := 2000
const SAMPLES := 40
const LATE_K := 1.15         # the budget is BUDGET_MS / LATE_K when measured on the 1948 map (see run())
## relative GPU cost of each tier (RTX 5070 Laptop, 1920x1080, Jaffa 1948 and Tel Aviv 2023 panning: see
## scripts/map/MAP_API.md "perf60"); used to skip straight to a tier that should fit when one is far over the budget
const REL := {"hdplus": 1.0, "hdplus_lite": 0.86, "hd": 1.04, "hd_fast": 0.56, "sd_high": 0.8, "sd_medium": 0.6, "sd_low": 0.35, "sd_min": 0.27}

var game: Node
var ui
var result := ""
var note := ""
var measured := {}           # tier -> p95 ms
var _root: Control
var _bar: ProgressBar
var _status: Label
var _title: Label
var _t0 := 0
var _budget := BUDGET_MS


static func prior() -> Dictionary:
	## {start, cap, kind, name, vendor, why}: where the benchmark starts and the highest tier it may pick
	var name := RenderingServer.get_video_adapter_name()
	var vendor := RenderingServer.get_video_adapter_vendor()
	var type := RenderingServer.get_video_adapter_type()
	var n := name.to_lower()
	var kind := "discrete"
	if type == RenderingDevice.DEVICE_TYPE_INTEGRATED_GPU:
		kind = "integrated"
	elif type == RenderingDevice.DEVICE_TYPE_CPU or type == RenderingDevice.DEVICE_TYPE_VIRTUAL_GPU:
		kind = "software"
	if "llvmpipe" in n or "swiftshader" in n or "microsoft basic" in n or "software" in n:
		kind = "software"
	elif kind == "discrete" and (("intel" in n and ("uhd" in n or "iris" in n or "hd graphics" in n)) or n.contains("radeon(tm) graphics")
			or n == "amd radeon graphics" or ("apple" in n and " m" in n)):
		kind = "integrated"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--gpu-prior="):
			kind = a.substr(12)
	var start := "hd"
	var cap := "hdplus"
	var why := ""
	match kind:
		"software":
			start = "sd_min"; cap = "sd_min"; why = "software renderer"
		"integrated":
			start = "sd_medium"; cap = "sd_high"; why = "integrated graphics: SD high at most"
			if "apple" in n and ("pro" in n or "max" in n or "ultra" in n):
				start = "sd_high"; cap = "hd_fast"; why = "Apple silicon (Pro / Max): HD fast at most"
			elif "780m" in n or "880m" in n or "890m" in n or "arc" in n:
				start = "sd_high"; why = "a strong integrated GPU: SD high at most"
		_:
			var rx := RegEx.new()
			var gen := 0
			var lvl := 0
			rx.compile("rtx\\s*(?:a)?(\\d{2})(\\d{2})")
			var m := rx.search(n)
			if m:
				gen = int(m.get_string(1)); lvl = int(m.get_string(2))
				start = "hdplus" if lvl >= 70 else ("hd" if lvl >= 60 else "hd_fast")
				if gen <= 20 and lvl < 80:
					start = _down(start)
				why = "NVIDIA RTX %d%02d" % [gen, lvl]
			elif "gtx" in n:
				start = "sd_high" if ("gtx 16" in n or "gtx 107" in n or "gtx 108" in n) else "sd_medium"
				why = "NVIDIA GTX"
			else:
				rx.compile("rx\\s*(\\d)(\\d)(\\d)0")
				m = rx.search(n)
				if m:
					gen = int(m.get_string(1)); lvl = int(m.get_string(2))
					start = "hdplus" if (gen >= 9 or lvl >= 8) else ("hd" if lvl >= 7 or (lvl == 6 and gen >= 7) else "hd_fast")
					if gen <= 5:
						start = "sd_high"
					why = "AMD Radeon RX %d%d00" % [gen, lvl]
				elif "arc" in n:
					start = "hd" if ("a7" in n or "b5" in n or "b7" in n) else "hd_fast"
					why = "Intel Arc"
				else:
					why = "discrete GPU"
			if "laptop" in n or "mobile" in n or "max-q" in n:
				start = _down(start)
				why += " (laptop)"
	if GfxTier.index(start) < GfxTier.index(cap):
		start = cap
	return {"start": start, "cap": cap, "kind": kind, "name": name, "vendor": vendor, "type": type, "why": why}


static func _down(t: String) -> String:
	var i := GfxTier.index(t)
	return GfxTier.LADDER[mini(i + 1, GfxTier.LADDER.size() - 1)]


# ------------------------------------------------------------------ the screen

func _ready() -> void:
	layer = 90
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)
	var dim := ColorRect.new()
	dim.color = Color(0.01, 0.02, 0.05, 0.62)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(dim)
	var cc := CenterContainer.new()
	cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(cc)
	var pc := PanelContainer.new()
	pc.add_theme_stylebox_override("panel", UITheme.sb(Color(0.03, 0.06, 0.14, 0.96), UIKit.GOLD, 2, 10, 30))
	pc.custom_minimum_size = Vector2(620, 0)
	cc.add_child(pc)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 16)
	pc.add_child(v)
	var logo := TextureRect.new()
	if ResourceLoader.exists(StartScreen.LOGO):
		logo.texture = load(StartScreen.LOGO)
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.custom_minimum_size = Vector2(0, 120)
	v.add_child(logo)
	_title = UITheme.title("Optimizing graphics for your computer…", 24, UIKit.GOLD_LIGHT)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(_title)
	_bar = ProgressBar.new()
	_bar.min_value = 0.0
	_bar.max_value = 1.0
	_bar.show_percentage = false
	_bar.custom_minimum_size = Vector2(540, 14)
	_bar.add_theme_stylebox_override("background", UITheme.sb(Color(0.02, 0.04, 0.09, 1.0), UIKit.GOLD_DARK, 1, 6, 0))
	_bar.add_theme_stylebox_override("fill", UITheme.sb(UIKit.GOLD, UIKit.GOLD_LIGHT, 1, 6, 0))
	v.add_child(_bar)
	_status = UITheme.label("A few seconds, once: the game measures your graphics card for a steady 60 frames a second.", 16, UIKit.TEXT_DIM)
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.custom_minimum_size = Vector2(540, 0)
	v.add_child(_status)
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--detect-budget="):
			_budget = float(a.substr(16))


func _process(_d: float) -> void:
	if _t0 > 0 and result == "":
		_bar.value = clampf((Time.get_ticks_msec() - _t0) / 1000.0 / MAX_S, 0.0, 0.97)


# ------------------------------------------------------------------ the benchmark

func run() -> String:
	## the whole step (a coroutine): measure, apply, save, show the line, close. Returns the tier.
	var pr := prior()
	print("detect: adapter '%s' (%s, type %d): %s; start %s, cap %s" % [pr["name"], pr["vendor"], int(pr["type"]), pr["why"] if pr["why"] != "" else pr["kind"], pr["start"], pr["cap"]])
	var rig = game.get("rig")
	var vp := game.get_viewport().get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(vp, true)
	var t0: Vector3 = rig.target if rig else Vector3.ZERO
	var z0: float = rig.zoom if rig else 2.4
	_t0 = Time.get_ticks_msec()
	# the background model warm-up's far LODs for the map first (TerrainRenderer.warm_assets), at most 2.5 s
	var r = game.get("renderer")
	while r != null and (ArtKit.warm_busy() or r.cities._lod_serial != ArtKit.far_serial) and Time.get_ticks_msec() - _t0 < 1000:
		await _pan_frame(rig, t0, z0)
	# the early map is sparse: Tel Aviv 2023 costs 1.2-1.6x the 1948 Jaffa view in every tier (scripts/map/MAP_API.md "perf60"), so
	# measured on an early map the budget leaves room for the late game (13 ms in 2010+, 11.3 ms in 1948)
	var yr := int(game.map.year) if game.get("map") != null else 1948
	var dens := clampf(LATE_K - (LATE_K - 1.0) * float(yr - 1948) / 62.0, 1.0, LATE_K)
	_budget = _budget / dens
	print("detect: budget %.1f ms (map year %d, late-game headroom x%.2f)" % [_budget, yr, dens])
	var cap_i := GfxTier.index(pr["cap"])
	var t: String = pr["start"]
	var best := ""
	var tried_up := false
	var next_guess := ""   # the tier the costs say should fit next (picked if time runs out before it is measured)
	var shot_done := false
	var ok := true
	while Time.get_ticks_msec() - _t0 < int(MAX_S * 1000.0) or measured.is_empty() and Time.get_ticks_msec() - _t0 < int(HARD_S * 1000.0):
		_status.text = "Testing %s…" % GfxTier.label(t)
		GfxTier.apply_live(game, t)
		# warm: the tier's shaders and pipelines compile (the first launch has no shader cache yet) and the clocks settle
		var tw := Time.get_ticks_msec()
		var quiet := 0
		var wf := 0
		var pc := _compiles()
		while (wf < WARM or quiet < QUIET) and Time.get_ticks_msec() - tw < WARM_MS and Time.get_ticks_msec() - _t0 < int(HARD_S * 1000.0):
			await _pan_frame(rig, t0, z0)
			wf += 1
			var c := _compiles()
			quiet = quiet + 1 if c == pc else 0
			pc = c
		var ts: Array = []
		var skipped := 0
		for i in SAMPLES:
			if Time.get_ticks_msec() - _t0 > int(HARD_S * 1000.0) and ts.size() >= 12:
				break
			await _pan_frame(rig, t0, z0)
			var c2 := _compiles()
			if c2 != pc:   # a frame that compiled a pipeline is a one-off hitch, not this tier's cost
				pc = c2
				skipped += 1
				continue
			ts.append(RenderingServer.viewport_get_measured_render_time_gpu(vp))
			if not shot_done and Time.get_ticks_msec() - _t0 > 1500:
				shot_done = true
				await _shot()
		if ts.size() < 6:
			ts.append(999.0)   # (could not measure it in time: treated as too slow)
		ts.sort()
		var p95 := trimmed_p95(ts)
		if float(ts.back()) <= 0.01:
			ok = false
			print("detect: no GPU timing on this system")
			break
		measured[t] = p95
		print("detect: %s p95 %.2f ms (median %.2f, %d frames, %d compiling skipped, warm %d frames) after %d ms" % [t, p95,
			float(ts[ts.size() / 2]), ts.size(), skipped, wf, Time.get_ticks_msec() - _t0])
		var i_t := GfxTier.index(t)
		if p95 <= _budget:
			if best == "" or GfxTier.index(best) > i_t:
				best = t
			# well under the budget: one try up, at the richest tier the costs say should fit (never one that costs as
			# much as a tier that was already too slow; never above the prior's cap)
			var failed_rel := 99.0
			for k in measured:
				if float(measured[k]) > _budget:
					failed_rel = minf(failed_rel, float(REL[k]))
			var up := ""
			if not tried_up:
				for j in range(maxi(cap_i, 0), i_t):
					var c: String = GfxTier.LADDER[j]
					if not measured.has(c) and float(REL[c]) < failed_rel and p95 * float(REL[c]) / float(REL[t]) <= _budget * 0.9:
						up = c
						break
			if up != "":
				tried_up = true
				t = up
				continue
			break
		if best != "":
			break   # (the step up did not fit: keep the one below)
		# over the budget: skip to the first lower tier that should fit (REL), else one step down
		var nxt := i_t + 1
		for j in range(i_t + 1, GfxTier.LADDER.size()):
			nxt = j
			if p95 * float(REL[GfxTier.LADDER[j]]) / float(REL[t]) <= _budget:
				break
		if nxt >= GfxTier.LADDER.size() or i_t >= GfxTier.LADDER.size() - 1:
			best = GfxTier.LADDER.back()
			break
		t = GfxTier.LADDER[nxt]
		next_guess = t
	if best == "":
		for k in GfxTier.LADDER:   # (the richest measured tier within the budget)
			if measured.has(k) and float(measured[k]) <= _budget:
				best = k
				break
	if best == "":
		if not ok or measured.is_empty():
			best = GfxTier.SAFE
		elif next_guess != "" and not measured.has(next_guess):
			best = next_guess   # (out of time: the step the measured costs point to)
		else:
			# out of time over budget: the next tier that costs clearly less than the cheapest one measured
			var lo := ""
			for k in measured:
				if lo == "" or float(REL[k]) < float(REL[lo]):
					lo = k
			best = cheaper(lo)
	if GfxTier.index(best) < cap_i:
		best = pr["cap"]
	result = best
	GfxTier.apply_live(game, best)
	if rig:
		rig.set_view(t0.x, t0.z, z0, true)
	var p: float = measured.get(best, -1.0)
	var fps60 := p > 0.0 and p <= 16.7
	note = "Graphics set to %s%s. You can change this in Settings." % [GfxTier.label(best), " (60 fps)" if fps60 or p < 0.0 else ""]
	print("detect: picked %s (p95 %s) in %d ms; %s" % [best, "%.2f ms" % p if p > 0.0 else "not measured", Time.get_ticks_msec() - _t0, str(measured)])
	GfxTier.to_settings(best)
	GameSettings.detected_tier = best
	GameSettings.save_cfg()
	_bar.value = 1.0
	_title.text = "Graphics optimized"
	_status.text = note
	_status.add_theme_color_override("font_color", UIKit.GOLD_LIGHT)
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--detect-shot-end="):   # (a screenshot of the result line)
			for i in 3:
				await get_tree().process_frame
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png(a.substr(18))
	await get_tree().create_timer(NOTE_S).timeout
	var tw := create_tween()
	tw.tween_property(_root, "modulate:a", 0.0, 0.3)
	await tw.finished
	finished.emit(best)
	queue_free()
	return best


static func trimmed_p95(sorted_ts: Array) -> float:
	## the 95th percentile of a tier's GPU frame times without isolated spikes over 1.6x the median: on this laptop
	## about one frame in ten reads 2-4x the median at every tier, SD low included (GPU clocks / other processes),
	## which is not the tier's own cost; a tier that is really too slow is slow in most of its frames
	if sorted_ts.is_empty():
		return 999.0
	var med := float(sorted_ts[sorted_ts.size() / 2])
	var kept: Array = sorted_ts.filter(func(x): return float(x) <= med * 1.6)
	return float(kept[mini(kept.size() - 1, int(kept.size() * 0.95))])


static func cheaper(t: String) -> String:
	## the next tier down the ladder that costs clearly less (REL), for the run-time safety net's one-step drop
	var i := GfxTier.index(t)
	if GfxTier.web():   # web: Web -> Web, lighter
		return GfxTier.WEB_LADDER.back()
	for j in range(i + 1, GfxTier.LADDER.size()):
		if float(REL[GfxTier.LADDER[j]]) < float(REL.get(t, 1.0)) * 0.9:
			return GfxTier.LADDER[j]
	return GfxTier.LADDER.back()


static func _compiles() -> int:
	## pipeline compilations so far (Godot's rendering info; frames where it moves are compile hitches)
	var n := 0
	for k in ["RENDERING_INFO_PIPELINE_COMPILATIONS_CANVAS", "RENDERING_INFO_PIPELINE_COMPILATIONS_MESH",
			"RENDERING_INFO_PIPELINE_COMPILATIONS_SURFACE", "RENDERING_INFO_PIPELINE_COMPILATIONS_DRAW", "RENDERING_INFO_PIPELINE_COMPILATIONS_SPECIALIZATION"]:
		if ClassDB.class_has_integer_constant("RenderingServer", k):
			n += RenderingServer.get_rendering_info(ClassDB.class_get_integer_constant("RenderingServer", k))
	return n


func _pan_frame(rig, t0: Vector3, z0: float) -> void:
	## a slow pan around the start view (like keyboard panning), so the measurement includes moving shadows / culling
	await get_tree().process_frame
	if rig == null:
		return
	var s := (Time.get_ticks_msec() - _t0) / 1000.0
	rig.set_view(t0.x + sin(s * 0.9) * 1.4, t0.z + (1.0 - cos(s * 0.7)) * 0.9, z0, true)


func _shot() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--detect-shot="):
			await RenderingServer.frame_post_draw
			var img := get_viewport().get_texture().get_image()
			img.save_png(a.substr(14))
			print("detect: screenshot ", a.substr(14))
