class_name Quality
extends RefCounted
## Graphics quality presets (Low / Medium / High). Read from user://game.cfg, then res://game.cfg,
## section [graphics] key quality; a --quality=low|medium|high command-line arg overrides both.
## Default: medium. The settings menu can call Quality.save(level) and restart the map.
##
## Graphics mode SD / HD / HD+ (independent of the preset): [graphics] mode = "sd" | "hd" | "hdplus" (default sd).
## --quality=hd|hdplus|sd (or --graphics=...) overrides the file. In HD and HD+ the "hd" preset below replaces the
## SD preset and HDRender (hd_render.gd) adds the HD lighting, GI, water and materials; HD+ adds the effects of
## hdplus.gd on top (Quality.plus). SD renders exactly as before HD existed.
##
## Upscaling (HD only): [graphics] upscaling = "off" | "fsr2" (default off); --fsr / --fsr=off override it, and
## --shot= captures ignore the saved value (off unless --fsr).
## FSR 2 renders 3D at 0.77 scale and upscales with its own temporal AA (HDPlus.apply_upscaling).

const PRESETS := {
	"low": {"shadow_dist": 14.0, "shadow_splits": 2, "ssao": false, "tree_shadows": false, "art_range": 26.0, "msaa": 0},
	"medium": {"shadow_dist": 20.0, "shadow_splits": 2, "ssao": true, "tree_shadows": false, "art_range": 38.0, "msaa": 1},
	"high": {"shadow_dist": 32.0, "shadow_splits": 4, "ssao": true, "tree_shadows": true, "art_range": 0.0, "msaa": 2},
	"hd": {"shadow_dist": 30.0, "shadow_splits": 4, "ssao": true, "tree_shadows": true, "art_range": 0.0, "msaa": 1},
}
static var level := ""
static var hd := false
static var plus := false  # HD+ (HD plus the hdplus.gd effects); only meaningful while hd
static var fsr := false   # Upscaling (faster): FSR 2 at 0.77, HD only


static func current() -> Dictionary:
	if level == "":
		level = "medium"
		hd = false
		for path in ["res://game.cfg", "user://game.cfg"]:
			var cf := ConfigFile.new()
			if cf.load(path) == OK:
				level = str(cf.get_value("graphics", "quality", level)).to_lower()
				var m := str(cf.get_value("graphics", "mode", "hdplus" if plus else ("hd" if hd else "sd"))).to_lower()
				hd = m == "hd" or m == "hdplus"
				plus = m == "hdplus"
				fsr = str(cf.get_value("graphics", "upscaling", "fsr2" if fsr else "off")).to_lower() == "fsr2"
		for a in OS.get_cmdline_user_args():
			if a.begins_with("--shot="):
				fsr = false   # captures ignore the saved upscaling (comparable shots); --fsr turns it on
		for a in OS.get_cmdline_user_args():
			if a.begins_with("--quality=") or a.begins_with("--graphics="):
				var v := a.get_slice("=", 1).to_lower()
				if v == "hd" or v == "sd" or v == "hdplus":
					hd = v != "sd"
					plus = v == "hdplus"
				else:
					level = v
			elif a == "--fsr" or a == "--fsr=on":
				fsr = true
			elif a == "--fsr=off":
				fsr = false
		for a in OS.get_cmdline_user_args():
			if a.begins_with("--fx="):   # testing: an explicit HD+ effect set implies HD+
				hd = true
				plus = true
		if not PRESETS.has(level) or level == "hd":
			level = "medium"
	return PRESETS["hd"] if hd else PRESETS[level]


static func is_hd() -> bool:
	current()
	return hd


static func is_hdplus() -> bool:
	current()
	return hd and plus


static func save(lv: String) -> void:
	var cf := ConfigFile.new()
	cf.load("user://game.cfg")
	cf.set_value("graphics", "quality", lv)
	cf.save("user://game.cfg")
	level = lv


static func save_mode(on: bool, hdplus := false) -> void:
	## Graphics: SD / HD / HD+, stored as [graphics] mode in user://game.cfg
	var cf := ConfigFile.new()
	cf.load("user://game.cfg")
	cf.set_value("graphics", "mode", ("hdplus" if hdplus else "hd") if on else "sd")
	cf.save("user://game.cfg")
	current()
	hd = on
	plus = on and hdplus

