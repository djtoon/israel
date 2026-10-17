class_name SettingsWindow
extends UIWindow
## Settings (Civ VI options screen): Audio (Master, Music, SFX, Ambience, UI volumes), Display (UI scale 90-150%,
## colourblind-safe palette, fullscreen, graphics preset, language) and Controls (key rebinding through the
## InputMap). Every change applies at once and is saved to user://game.cfg (GameSettings).

var tab := "gameplay"
var _capturing := ""         # action id waiting for a key press
var _cap_btn: Button
var _msg: Label
var _vol_labels := {}


func _init() -> void:
	super._init("Settings")


func open(t := "") -> void:
	if t != "":
		tab = t
	_capturing = ""
	refresh()
	visible = true


func capturing() -> bool:
	return visible and _capturing != ""


func refresh() -> void:
	clear_body()
	_vol_labels.clear()
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 6)
	body.add_child(tabs)
	for td in [["gameplay", "Gameplay"], ["audio", "Audio"], ["display", "Display"], ["controls", "Controls"]]:
		var b := UITheme.button(td[1], _set_tab.bind(td[0]), 18)
		b.custom_minimum_size = Vector2(150, 0)
		if tab == td[0]:
			b.add_theme_stylebox_override("normal", UITheme.sb(Color(0.16, 0.30, 0.55), UIKit.GOLD_LIGHT, 2, 5, 10))
		tabs.add_child(b)
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tabs.add_child(sp)
	tabs.add_child(UITheme.button("Restore defaults", _defaults, 16))
	body.add_child(UITheme.sep())
	match tab:
		"display": _display()
		"controls": _controls()
		"gameplay": _gameplay()
		_: _audio()
	_msg = UITheme.label("", 16, UIKit.GOLD_LIGHT)
	_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(_msg)
	var foot := HBoxContainer.new()
	foot.alignment = BoxContainer.ALIGNMENT_END
	var saved := UITheme.label("Changes apply at once and are saved for your next game.", 15, UIKit.TEXT_DIM)
	saved.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	foot.add_child(saved)
	if ui != null and ui.has_method("show_credits") and ui.get("sim") != null:
		var cr := UITheme.button("Credits", func(): close(); ui.show_credits(), 16)   # (v4polish: story mode's short Game menu)
		cr.name = "settings_credits"
		foot.add_child(cr)
	foot.add_child(UITheme.button("Done", close, 18))
	body.add_child(foot)


func _set_tab(t: String) -> void:
	tab = t
	_capturing = ""
	refresh()


func _row(label: String, tip := "") -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	var l := UITheme.label(label, 18, UIKit.TEXT, "body_bold")
	l.custom_minimum_size = Vector2(260, 0)
	if tip != "":
		l.tooltip_text = tip
		l.mouse_filter = Control.MOUSE_FILTER_PASS
	h.add_child(l)
	body.add_child(h)
	return h


func _note(text: String) -> void:
	var l := UITheme.rich("[color=#a8b0c4]%s[/color]" % text, 15)
	body.add_child(l)


# ------------------------------------------------------------------ gameplay (v4: the play style, the ministries, auto-advance)

func _gameplay() -> void:
	var in_game: bool = ui != null and ui.get("sim") != null
	var st: String = NextStep.style(ui) if in_game else GameSettings.play_style
	var h := _row("Play style", "Story: your ministers run the routine and you make the big calls. Full control: every decision is yours, as in a classic 4X.")
	for p in [["story", "Story"], ["full", "Full control"]]:
		var b := UITheme.button(p[1], _on_style.bind(p[0]), 17)
		b.name = "style_" + p[0]
		b.custom_minimum_size = Vector2(170, 0)
		MinistersPanel._mark(b, st == p[0])
		h.add_child(b)
	if st == "custom":
		h.add_child(UITheme.label("Custom: some ministries are yours", 15, UIKit.TEXT_DIM))
	_note("Story: your ministers run production, research, policies, units and the routine budget; you decide the wars, forks, peace, budgets and programmes. Full control: every decision is yours. It changes at once, mid-game included." if in_game
		else "The play style of your next new game (the New Game panel asks too).")
	if in_game:
		var hb := _row("Ministers' brief", "What your ministers put first in the routine. Balanced is the Recommended choice in every ministry.")
		var cur_b := NextStep.brief(ui)
		for b2 in NextStep.BRIEFS:
			var bb := UITheme.button(b2[1], func(): ui.set_ministers_brief(str(b2[0])); refresh(), 15)
			bb.tooltip_text = str(b2[2])
			bb.name = "brief_" + str(b2[0])
			MinistersPanel._mark(bb, cur_b == b2[0])
			hb.add_child(bb)
		body.add_child(UITheme.title("THE MINISTRIES", 16, UIKit.GOLD))
		MinistersPanel.add_domain_rows(body, ui, true)
	var h2 := _row("Quiet quarters")
	var cb := CheckBox.new()
	cb.text = "Auto-advance quiet quarters (the turn ends after 2 s; any key or click stops it)"
	cb.add_theme_font_size_override("font_size", 17)
	cb.focus_mode = Control.FOCUS_NONE
	cb.button_pressed = GameSettings.auto_advance
	cb.name = "auto_advance"
	cb.toggled.connect(_on_auto_advance)
	h2.add_child(cb)
	# v4 fix round (B5, the UI side): the era goals follow the play style (on in Story, off in Full control, so Full
	# control plays v3); this switch changes it for the game in progress
	var gs = ui.sim.get("goals") if in_game else null
	if gs is Object and (gs as Object).has_method("set_enabled") and (gs as Object).has_method("enabled"):
		var hg := _row("Era goals", "Two or three real goals of each era, with a reward when met. On by default in Story, off in Full control.")
		var gb := CheckBox.new()
		gb.text = "Show and score the era goals in this game"
		gb.add_theme_font_size_override("font_size", 17)
		gb.focus_mode = Control.FOCUS_NONE
		gb.button_pressed = bool(gs.enabled())
		gb.name = "era_goals"
		gb.toggled.connect(func(on: bool): ui.set_era_goals(on))
		hg.add_child(gb)
	if in_game and not ui.full_hud:
		var h3 := _row("The screen", "Panels appear as they start to matter. This hides again what you are not using; each comes back when it matters.")
		var sb := UITheme.button("Simplify the screen again", func(): ui.simplify_screen(); refresh(), 16)
		sb.name = "simplify"
		h3.add_child(sb)


func _on_style(s: String) -> void:
	if ui != null and ui.get("sim") != null:
		ui.set_play_style(s)
	else:
		GameSettings.play_style = "full" if s == "full" else "story"
		GameSettings.save_cfg()
	refresh()


func _on_auto_advance(on: bool) -> void:
	if ui != null and ui.has_method("set_auto_advance"):
		ui.set_auto_advance(on)
	else:
		GameSettings.auto_advance = on
		GameSettings.save_cfg()


# ------------------------------------------------------------------ audio

func _audio() -> void:
	for b in GameSettings.BUSES:
		var bus: String = b[0]
		var h := _row(b[1])
		var s := HSlider.new()
		s.min_value = 0; s.max_value = 100; s.step = 1
		s.value = round(float(GameSettings.volumes.get(bus, 0.8)) * 100.0)
		s.custom_minimum_size = Vector2(360, 28)
		s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		s.focus_mode = Control.FOCUS_NONE
		s.name = "vol_" + bus
		h.add_child(s)
		var vl := UITheme.label("%d%%" % int(s.value), 18)
		vl.custom_minimum_size = Vector2(60, 0)
		h.add_child(vl)
		_vol_labels[bus] = vl
		s.value_changed.connect(_on_volume.bind(bus))
		s.drag_ended.connect(func(_c): UIAudio.click())
	var miss := GameSettings.missing_buses()
	if miss.size() == GameSettings.BUSES.size() - 1 and GameSettings.audio_director() == null:
		_note("Music and sound effects arrive with the game's audio; your levels are kept and applied as soon as it loads.")
	elif miss.size() > 0:
		_note("Not in this build yet: %s. Your levels for them are kept." % ", ".join(miss))


func set_volume(bus: String, linear: float) -> void:
	GameSettings.volumes[bus] = clampf(linear, 0.0, 1.0)
	GameSettings.apply_audio()
	GameSettings.save_cfg()
	if _vol_labels.has(bus) and is_instance_valid(_vol_labels[bus]):
		(_vol_labels[bus] as Label).text = "%d%%" % int(round(linear * 100.0))


func _on_volume(v: float, bus: String) -> void:
	set_volume(bus, v / 100.0)


# ------------------------------------------------------------------ display

func _option(items: Array, selected: int, cb: Callable, width := 360.0) -> OptionButton:
	var o := OptionButton.new()
	o.focus_mode = Control.FOCUS_NONE
	o.add_theme_font_size_override("font_size", 18)
	o.custom_minimum_size = Vector2(width, 0)
	for i in items.size():
		o.add_item(str(items[i]), i)
	o.select(selected)
	o.item_selected.connect(cb)
	o.get_popup().add_theme_font_size_override("font_size", 18)
	return o


func _display() -> void:
	# UI scale
	var h := _row("UI scale", "Windows, panels and popups. A window that would not fit the screen at this scale is drawn as large as fits.")
	var steps := []
	var sel := 1
	var pct := 90
	while pct <= 150:
		steps.append("%d%%" % pct)
		if absf(GameSettings.ui_scale * 100.0 - pct) < 2.5:
			sel = steps.size() - 1
		pct += 10
	var so := _option(steps, sel, _on_scale, 200)
	so.name = "scale"
	h.add_child(so)
	var eff := GameSettings.effective_scale()
	if absf(eff - GameSettings.ui_scale) > 0.01:
		h.add_child(UITheme.label("(%d%% on this screen: text stays readable)" % int(round(eff * 100.0)), 15, UIKit.TEXT_DIM))
	# palette
	var h2 := _row("Colours for good and bad", "How effects are coloured everywhere: what helps you and what hurts.")
	var pal_items := GameSettings.PALETTES.map(func(p): return p[1])
	var pi := 1 if GameSettings.palette == "colourblind" else 0
	var po := _option(pal_items, pi, _on_palette, 470)
	po.name = "palette"
	h2.add_child(po)
	var prev := UITheme.rich("Preview:  [color=%s]+3 Gold per turn, +2 Civic Trust[/color]   [color=%s]−4 Standing, inflation +5%%[/color]" % [UITheme.GOOD_HEX, UITheme.BAD_HEX], 17)
	prev.name = "palette_preview"
	body.add_child(prev)
	# window
	var h3 := _row("Fullscreen")
	var fs := CheckBox.new()
	fs.text = "Fullscreen (F11 or Alt+Enter switches)"
	fs.add_theme_font_size_override("font_size", 18)
	fs.focus_mode = Control.FOCUS_NONE
	fs.button_pressed = GameSettings.fullscreen
	fs.name = "fullscreen"
	fs.toggled.connect(_on_fullscreen)
	h3.add_child(fs)
	# graphics
	var h4 := _row("Graphics quality", "Low suits laptops and older graphics cards; High draws every model and tree shadow.")
	var qi := 1
	for i in GameSettings.QUALITIES.size():
		if GameSettings.QUALITIES[i][0] == GameSettings.quality:
			qi = i
	var qo := _option(GameSettings.QUALITIES.map(func(q): return q[1]), qi, _on_quality, 200)
	qo.name = "quality"
	h4.add_child(qo)
	_note("Shadows, ambient occlusion and edge smoothing change at once; tree shadows and how far away buildings are drawn change the next time you start the game.")
	var h4b := _row("Graphics: SD / HD", "HD: a warm low sun with soft shadows, bounce light, detailed ground, a new sea with surf and reefs, haze and a film-like colour grade. Needs a stronger graphics card.")
	var gm := _option(["SD (standard)", "HD (high definition)", "HD+ (high definition plus)"], (2 if Quality.is_hdplus() else 1) if Quality.is_hd() else 0, func(i: int): set_graphics_mode(i >= 1, i == 2), 260)
	gm.name = "graphics_mode"
	h4b.add_child(gm)
	_note("SD / HD switches at once; in HD, tree shadows and distant buildings follow the next time you start the game.")
	_note("HD+ adds tilt-shift depth of field, drifting cloud shadows, sea caustics, the seasons, wind in the trees and weathered roads and walls.")
	var h4c := _row("Upscaling (faster)", "FSR 2 draws the 3D map at a lower resolution and sharpens it back up to full size: a little softer, but faster. Works in HD.")
	var uo := _option(["Off", "FSR 2"], 1 if GameSettings.upscaling else 0, func(i: int): set_upscaling(i == 1), 200)
	uo.name = "upscaling"
	h4c.add_child(uo)
	_note("Try FSR 2 in HD if the game feels slow in big, late-game cities such as Tel Aviv.")
	# v5 day and night (scripts/map/daynight.gd): the time of day, the length of a day, pausing the clock
	var h4d := _row("Time of day", "The sun and the moon cross the sky in real time while you play; turns stay quarters. Or keep one time of day.")
	var tod_items := ["Day and night (real time)", "Dawn", "Noon", "Sunset", "Night"]
	var to := _option(tod_items, maxi(DayNight.MODES.find(GameSettings.time_of_day), 0), func(i: int): set_time_of_day(DayNight.MODES[i]), 300)
	to.name = "time_of_day"
	h4d.add_child(to)
	var h4e := _row("Day length", "How many real minutes a whole day and night takes.")
	var lo2 := _option(DayNight.LENGTHS.map(func(m): return "%d minutes" % m), maxi(DayNight.LENGTHS.find(GameSettings.day_length_min), 0), func(i: int): set_day_length(DayNight.LENGTHS[i]), 160)
	lo2.name = "day_length"
	h4e.add_child(lo2)
	var pc := CheckBox.new()
	pc.text = "Pause the clock"
	pc.add_theme_font_size_override("font_size", 17)
	pc.focus_mode = Control.FOCUS_NONE
	pc.button_pressed = GameSettings.clock_paused
	pc.name = "clock_paused"
	pc.toggled.connect(set_clock_paused)
	h4e.add_child(pc)
	_note("Day and night is only a look: the map, its labels and the turns stay the same, and nights stay readable.")
	# language (switches live; the content of windows reads right to left in Hebrew)
	var h5 := _row("Language", "The language of every menu, window and message. Data text (events, decisions, the Civilopedia) follows as its translation is completed; anything not translated yet shows in English.")
	var li := 0
	var names := []
	for i in GameSettings.LANGUAGES.size():
		var code: String = GameSettings.LANGUAGES[i][0]
		names.append(str(GameSettings.LANGUAGES[i][1]) + ("" if GameSettings.language_available(code) else "  (in a coming update)"))
		if code == GameSettings.current_language():
			li = i
	var lo := _option(names, li, _on_language, 360)
	lo.name = "language"
	for i in GameSettings.LANGUAGES.size():
		lo.set_item_disabled(i, not GameSettings.language_available(GameSettings.LANGUAGES[i][0]))
	h5.add_child(lo)
	if GameSettings.lang_override != "":
		_note("This run is started in %s from the command line; the language saved for your next game is %s." % [L10n.lang_name(GameSettings.lang_override), L10n.lang_name(GameSettings.language)])
	else:
		_note("The language changes at once. The 7 October 2023 memorial at the end of the game is always shown in the author's own words.")


func set_scale_pct(pct: int) -> void:
	GameSettings.ui_scale = clampf(pct / 100.0, GameSettings.SCALE_MIN, GameSettings.SCALE_MAX)
	GameSettings.apply_scale()
	GameSettings.save_cfg()
	refresh()


func _on_scale(i: int) -> void:
	set_scale_pct(90 + 10 * i)


func set_palette(p: String) -> void:
	GameSettings.palette = p
	GameSettings.apply_palette()
	GameSettings.save_cfg()
	if ui and ui.has_method("on_palette_changed"):
		ui.on_palette_changed()
	refresh()


func _on_palette(i: int) -> void:
	set_palette(GameSettings.PALETTES[i][0])


func _on_fullscreen(on: bool) -> void:
	GameSettings.fullscreen = on
	GameSettings.save_cfg()
	if ui == null or not (ui.capture or ui.testing):
		GameSettings.apply_window()


func set_quality(q: String) -> void:
	GameSettings.quality = q
	GameSettings.save_cfg()
	var r := GameSettings.apply_quality(ui.game if ui else null)
	if _msg:
		_msg.text = "Graphics: %s (%s)." % [q.capitalize(), "applied" if r == "applied" else "saved for the next start"]


func set_graphics_mode(hd: bool, plus := false) -> void:
	GameSettings.graphics_hd = hd
	GameSettings.graphics_plus = hd and plus
	GameSettings.save_cfg()
	var r := GameSettings.apply_graphics_mode(ui.game if ui else null)
	if _msg:
		_msg.text = "Graphics: %s (%s)." % [("HD+" if plus else "HD") if hd else "SD", "applied" if r == "applied" else "saved for the next start"]


func set_upscaling(on: bool) -> void:
	GameSettings.upscaling = on
	GameSettings.save_cfg()
	var r := GameSettings.apply_upscaling(ui.game if ui else null)
	if _msg:
		_msg.text = "Upscaling: %s (%s)." % ["FSR 2" if on else "Off", "applied" if r == "applied" else "saved; it works in HD"]


func _dn_snap() -> bool:
	return ui != null and (bool(ui.get("capture")) or bool(ui.get("testing")))


func set_time_of_day(m: String) -> void:
	## v5: "cycle" (real time) or a fixed dawn / noon / sunset / night; applied at once (the clock runs there)
	GameSettings.time_of_day = m if m in DayNight.MODES else "cycle"
	GameSettings.save_cfg()
	GameSettings.apply_daynight(_dn_snap())
	if _msg:
		var names := {"cycle": "Day and night (real time)", "dawn": "Dawn", "noon": "Noon", "sunset": "Sunset", "night": "Night"}
		_msg.text = "Time of day: %s." % names[GameSettings.time_of_day]


func set_day_length(minutes: int) -> void:
	GameSettings.day_length_min = minutes if minutes in DayNight.LENGTHS else 8
	GameSettings.save_cfg()
	GameSettings.apply_daynight(_dn_snap())
	if _msg:
		_msg.text = "Day length: %d minutes." % GameSettings.day_length_min


func set_clock_paused(on: bool) -> void:
	GameSettings.clock_paused = on
	GameSettings.save_cfg()
	GameSettings.apply_daynight(_dn_snap())
	if _msg:
		_msg.text = "The clock is paused." if on else "The clock runs."


func _on_quality(i: int) -> void:
	set_quality(GameSettings.QUALITIES[i][0])


func _on_language(i: int) -> void:
	set_language(GameSettings.LANGUAGES[i][0])


func set_language(code: String) -> void:
	if not GameSettings.language_available(code):
		return
	GameSettings.language = code
	GameSettings.language_chosen = true
	GameSettings.lang_override = ""
	GameSettings.save_cfg()
	GameSettings.apply_language()
	if ui and ui.has_method("on_language_changed"):
		ui.on_language_changed()
	refresh()


# ------------------------------------------------------------------ controls

func _controls() -> void:
	_note("Click a key to change it, then press the new key (with Ctrl, Alt or Shift if you like). Esc cancels. A key already in use moves to the new action. The camera always uses W A S D, the arrow keys and Q / E.")
	var sc := ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.custom_minimum_size = Vector2(0, 430)
	body.add_child(sc)
	var g := GridContainer.new()
	g.columns = 3
	g.add_theme_constant_override("h_separation", 14)
	g.add_theme_constant_override("v_separation", 4)
	g.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sc.add_child(g)
	for a in GameSettings.ACTIONS:
		var id: String = a[0]
		var l := UITheme.label(str(a[1]), 17)
		l.custom_minimum_size = Vector2(380, 0)
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		g.add_child(l)
		var b := UITheme.button("Press a key..." if _capturing == id else GameSettings.binding_text(id), begin_capture.bind(id), 17)
		b.custom_minimum_size = Vector2(170, 0)
		b.name = "key_" + id
		if _capturing == id:
			b.add_theme_stylebox_override("normal", UITheme.sb(Color(0.55, 0.38, 0.08), UIKit.GOLD_LIGHT, 2, 5, 10))
			_cap_btn = b
		g.add_child(b)
		var c := UITheme.button("Clear", _clear_key.bind(id), 15)
		c.disabled = int(GameSettings.binding(id).get("key", 0)) == KEY_NONE
		g.add_child(c)


func begin_capture(id: String) -> void:
	_capturing = id
	refresh()


func _clear_key(id: String) -> void:
	GameSettings.unbind(id)
	GameSettings.save_cfg()
	_capturing = ""
	refresh()
	_msg.text = "%s is now unbound." % GameSettings.label_of(id)


func _input(e: InputEvent) -> void:
	if _capturing == "" or not visible:
		return
	if not (e is InputEventKey) or not e.pressed or e.echo:
		return
	var k := e as InputEventKey
	if k.keycode in [KEY_SHIFT, KEY_CTRL, KEY_ALT, KEY_META, KEY_CAPSLOCK]:
		return
	get_viewport().set_input_as_handled()
	if k.keycode == KEY_ESCAPE:
		_capturing = ""
		refresh()
		return
	apply_binding(_capturing, k)


func apply_binding(id: String, k: InputEventKey) -> String:
	var taken := GameSettings.rebind(id, k)
	GameSettings.save_cfg()
	_capturing = ""
	refresh()
	var txt := "%s: %s." % [GameSettings.label_of(id), GameSettings.binding_text(id)]
	if taken != "":
		txt += " It was used by %s, which is now unbound." % GameSettings.label_of(taken)
	if not k.ctrl_pressed and not k.alt_pressed and k.keycode in [KEY_W, KEY_A, KEY_S, KEY_D, KEY_Q, KEY_E, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT]:
		txt += " This key also moves the camera."
	_msg.text = txt
	return taken


func _defaults() -> void:
	GameSettings.reset_defaults()
	GameSettings.apply_all(get_tree(), ui == null or not (ui.capture or ui.testing))
	GameSettings.apply_daynight(_dn_snap())
	GameSettings.save_cfg()
	if ui and ui.has_method("on_palette_changed"):
		ui.on_palette_changed()
	_capturing = ""
	refresh()
	_msg.text = "Every setting is back to its default."


func close() -> void:
	_capturing = ""
	super.close()
