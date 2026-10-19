class_name StartScreen
extends Control
## Title sequence: the creator's logo video plays, then the intro video (each skippable), fades to black, then the menu loop fades in on repeat,
## the logo fades in on the left and the menu buttons fade in below it one by one.
## Captures and UI tests (--shot / --ui-test) skip the intro and show the finished menu at once; --intro forces it.

const BRAND_VIDEO := "res://assets/intro/logo.ogv"   # the creator's logo (newIntro/logo_comp.mp4), the very first video
const INTRO_VIDEO := "res://assets/intro/intro.ogv"
const MENU_VIDEO := "res://assets/intro/menu_loop.ogv"
const MENU_STILL := "res://assets/intro/menu_still.jpg"   # web build only: shown if the menu loop's WebM cannot play
const LOGO := "res://assets/intro/title.png"
const MUSIC := "res://assets/audio/menu_music.mp3"
const MUSIC_DB := -8.0
const MUSIC_FADE := 2.5
const FADE_OUT := 0.8     # intro -> black
const FADE_IN := 1.2      # black -> menu loop
const LOGO_FADE := 1.0
const BTN_FADE := 0.35
const BTN_STAGGER := 0.18

var ui
var mode_box: VBoxContainer      # the New Game setup (difficulty, start, tutorial / full game), right of the menu
var setup_panel: PanelContainer
var new_btn: Button
var continue_btn: Button
var difficulty := ""             # chosen on the New Game panel (remembered in user://game.cfg [game] difficulty)
var scenario := ""               # "" = 14 May 1948; scenario ids from the sim (round 2)
var _diff_btns := {}
var _diff_desc: Label
var _scen_btns := {}
var _tut_btn: Button
var play_style := ""             # "full" (default) | "story" (remembered in user://game.cfg [game] play_style)
var _style_btns := {}
var _style_desc: Label
const STYLES := [["full", "Full control", "Every decision is yours, as in a classic 4X: production, research, units, budgets."],
	["story", "Story", "Your ministers run the routine; you make the big calls."]]

var _brand   # the logo video, played before the intro (VideoStreamPlayer; WebVideoPlayer in the web build)
var _in_brand := false
var _intro   # (VideoStreamPlayer; WebVideoPlayer in the web build)
var _loop    # (VideoStreamPlayer; WebVideoPlayer in the web build)
var _bg_rect: ColorRect   # the black behind the menu loop (clear on the web, where the loop plays behind the canvas)
var _black: ColorRect
var _menu: Control
var _logo: TextureRect
var _items: Array[Control] = []
var _he_title: Label         # the title in Hebrew under the logo art (the logo image is English)
var _in_intro := false
static var intro_played := false   # the logo and intro play once per launch; later title screens open on the menu


func refresh_continue() -> void:
	## "Continue" names the newest save (quick-save, named slot or autosave).
	if continue_btn == null:
		return
	var m := SaveSlots.newest()
	continue_btn.disabled = m.is_empty()
	continue_btn.visible = not m.is_empty()   # a fresh install shows no Continue at all (v4 fix round, new-player m8)
	if m.is_empty():
		continue_btn.text = "Continue  (no saved game yet)"
	else:
		var kind := str(m.get("kind", ""))
		var what := "quick-save" if kind == "quick" else ("autosave" if kind == "auto" else "\"%s\"" % str(m.get("name", "")))
		continue_btn.text = "Continue  -  %s%s" % [what, (", " + str(m["label"])) if str(m.get("label", "")) != "" else ""]


func refresh_language() -> void:
	## Live language switch: the buttons and labels re-translate themselves; the Hebrew title shows in Hebrew only.
	if _he_title:
		_he_title.visible = L10n.is_he()
	refresh_continue()


func _ask_mode() -> void:
	## "New Game" opens the setup panel: difficulty, where to start, then Tutorial or the full game.
	setup_panel.visible = not setup_panel.visible
	if setup_panel.visible:
		setup_panel.modulate.a = 0.0
		create_tween().tween_property(setup_panel, "modulate:a", 1.0, BTN_FADE)


func set_difficulty(id: String) -> void:
	difficulty = id
	for k in _diff_btns:
		var b: Button = _diff_btns[k]
		var on: bool = k == id
		b.add_theme_stylebox_override("normal", UITheme.sb(Color(0.16, 0.34, 0.66) if on else Color(0.08, 0.14, 0.28, 0.95), UIKit.GOLD_LIGHT if on else Color(0.45, 0.38, 0.22), 2 if on else 1, 5, 10))
	for d in V3Adapter.difficulties():
		if str(d.get("id", "")) == id and _diff_desc:
			_diff_desc.text = str(d.get("desc", ""))
	if GameSettings.cfg != null:
		GameSettings.cfg.set_value("game", "difficulty", id)
		GameSettings.save_cfg()


func set_scenario(id: String) -> void:
	scenario = id
	for k in _scen_btns:
		var b: Button = _scen_btns[k]
		var on: bool = k == id
		b.add_theme_stylebox_override("normal", UITheme.sb(Color(0.16, 0.34, 0.66) if on else Color(0.08, 0.14, 0.28, 0.95), UIKit.GOLD_LIGHT if on else Color(0.45, 0.38, 0.22), 2 if on else 1, 5, 10))
	if _tut_btn:
		_tut_btn.disabled = id != ""
		_tut_btn.tooltip_text = "The tutorial starts on 14 May 1948." if id != "" else "The real game from 14 May 1948, one system at a time, with the Cabinet Secretary as your guide. Skip at any time."


func set_play_style(id: String) -> void:
	## v4: "How do you want to play?": Story (the ministers run the routine) or Full control (the v3 game).
	play_style = "full" if id == "full" else "story"
	for k in _style_btns:
		var b: Button = _style_btns[k]
		var on: bool = k == play_style
		b.add_theme_stylebox_override("normal", UITheme.sb(Color(0.16, 0.34, 0.66) if on else Color(0.08, 0.14, 0.28, 0.95), UIKit.GOLD_LIGHT if on else Color(0.45, 0.38, 0.22), 2 if on else 1, 5, 10))
	for s in STYLES:
		if s[0] == play_style and _style_desc != null:
			_style_desc.text = str(s[2])
	if ui != null and ui.test_style == "":   # a UI test never changes the player's saved choice
		GameSettings.play_style = play_style
		GameSettings.save_cfg()


func _start(with_tutorial: bool) -> void:
	var d := difficulty
	if with_tutorial and d == "historian":
		d = "hard"   # the tutorial teaches with the Recommended picks, which Historian hides
	ui.new_game_opts = {"difficulty": d, "scenario": "" if with_tutorial else scenario, "play_style": play_style if play_style != "" else "full"}
	ui.loading.run(func(): ui.start_new_game(false, with_tutorial))


func _ready() -> void:
	theme = UITheme.get_theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	# menu loop video (behind everything), the intro video above it, and a black fade layer on top
	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	_bg_rect = bg
	# web, integrated graphics (web_low): a still behind the menu, not the loop video (it cost the game frames)
	var web_still := OS.has_feature("web") and GfxTier.active == "web_low"
	_loop = _video(MENU_VIDEO) if not web_still else null
	if _loop:
		_loop.loop = true
		_loop.volume_db = -80.0
		if _loop is WebVideoPlayer:   # web: the loop plays behind the canvas, seen through it
			bg.color = Color(0, 0, 0, 0)
			_loop.finished.connect(_web_loop_failed)
	elif OS.has_feature("web"):   # (a browser without WebM: a still of the menu loop)
		_web_loop_failed()
	_build_menu()
	_intro = _video(INTRO_VIDEO)
	_brand = _video(BRAND_VIDEO)
	if _brand:
		_brand.visible = false
	_black = ColorRect.new()
	_black.color = Color.BLACK
	_black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_black)

	var args := OS.get_cmdline_user_args()
	var quick: bool = DisplayServer.get_name() == "headless"
	for a in args:
		if a.begins_with("--shot") or a.begins_with("--ui-test"):
			quick = true
	if "--intro" in args:
		quick = false
	if "--web-intro-done" in args:   # web: the page played the logo and the intro before the game started
		intro_played = true
	if quick or _intro == null or intro_played:
		_show_menu_now()
	else:
		_play_intro()


func _web_loop_failed() -> void:
	## web: the menu loop's WebM could not play: a still of it (web build only, build/web/web_diet.py) on black
	_bg_rect.color = Color.BLACK
	if ResourceLoader.exists(MENU_STILL):
		var tr := TextureRect.new()
		tr.texture = load(MENU_STILL)
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		tr.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(tr)
		move_child(tr, _bg_rect.get_index() + 1)
	_web_no3d = true   # (the opaque still covers the map: it is not drawn while the start screen shows)
	_sync_web_3d()


var _web_no3d := false


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		_sync_web_3d()


func _sync_web_3d() -> void:
	if _web_no3d and is_inside_tree():
		WorldView.show_3d(get_viewport(), not is_visible_in_tree())


func _exit_tree() -> void:
	if _web_no3d:
		WorldView.show_3d(get_viewport(), true)


func _video(path: String):
	## a VideoStreamPlayer for path; in the web build a WebVideoPlayer (WebM in an HTML <video>) when the page has one
	if OS.has_feature("web") and WebVideoPlayer.available():
		var w := WebVideoPlayer.for_path(path)
		if w:
			w.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			add_child(w)
			return w
	if not ResourceLoader.exists(path):
		push_warning("StartScreen: missing video " + path)
		return null
	var v := VideoStreamPlayer.new()
	v.stream = load(path)
	v.expand = true
	v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(v)
	return v


# ------------------------------------------------------------------ sequence

func _play_intro() -> void:
	intro_played = true
	_in_intro = true
	_menu.visible = false
	if _loop:
		_loop.visible = false
	_black.modulate.a = 0.0
	if _brand:   # the logo first; the intro starts when it ends or is skipped
		_in_brand = true
		_intro.visible = false
		_brand.visible = true
		_brand.finished.connect(_end_brand, CONNECT_ONE_SHOT)
		_brand.play()
		return
	_intro.finished.connect(_end_intro, CONNECT_ONE_SHOT)
	_intro.play()


func _end_brand() -> void:
	if not _in_brand:
		return
	_in_brand = false
	var t := create_tween()
	t.tween_property(_black, "modulate:a", 1.0, FADE_OUT)
	t.tween_callback(func():
		_brand.stop()
		_brand.visible = false
		if not _in_intro:   # the intro was skipped too during the fade
			return
		_intro.visible = true
		_intro.finished.connect(_end_intro, CONNECT_ONE_SHOT)
		_intro.play())
	t.tween_property(_black, "modulate:a", 0.0, FADE_OUT)


func _end_intro() -> void:
	if not _in_intro:
		return
	_in_intro = false
	var t := create_tween()
	t.tween_property(_black, "modulate:a", 1.0, FADE_OUT)
	t.tween_callback(_start_menu)


func _start_menu() -> void:
	if _brand:
		_brand.stop()
		_brand.visible = false
	if _intro:
		_intro.stop()
		_intro.visible = false
	if _loop:
		_loop.visible = true
		_loop.play()
	_menu.visible = true
	_logo.modulate.a = 0.0
	for it in _items:
		it.modulate.a = 0.0
	var t := create_tween()
	_start_music(true)
	t.tween_property(_black, "modulate:a", 0.0, FADE_IN)
	t.tween_property(_logo, "modulate:a", 1.0, LOGO_FADE)
	for it in _items:
		t.tween_interval(BTN_STAGGER)
		t.parallel().tween_property(it, "modulate:a", 1.0, BTN_FADE)


func _show_menu_now() -> void:
	_in_intro = false
	_in_brand = false
	if _brand:
		_brand.stop()
		_brand.visible = false
	if _intro:
		_intro.visible = false
	if _loop:
		_loop.visible = true
		_loop.play()
	_black.modulate.a = 0.0
	_menu.visible = true
	_start_music(false)


func _start_music(fade: bool) -> void:
	## Menu music loops from the menu onward. The player lives on the scene root (not this screen),
	## so it keeps playing into the game; it is created once and reused.
	if DisplayServer.get_name() == "headless" or not ResourceLoader.exists(MUSIC):
		return
	var root := get_tree().root
	var p := root.get_node_or_null("MenuMusic") as AudioStreamPlayer
	if p == null:
		p = AudioStreamPlayer.new()
		p.name = "MenuMusic"
		var s: AudioStream = load(MUSIC)
		if s is AudioStreamMP3:
			(s as AudioStreamMP3).loop = true
		p.stream = s
		root.add_child.call_deferred(p)
		await p.tree_entered
	if p.playing:
		return
	p.volume_db = -40.0 if fade else MUSIC_DB
	p.play()
	print("menu music: playing (loop=%s)" % str(p.stream.get("loop")))
	if fade:
		p.create_tween().tween_property(p, "volume_db", MUSIC_DB, MUSIC_FADE)


func _gui_input(e: InputEvent) -> void:
	if _in_intro and e is InputEventMouseButton and e.pressed:
		_skip_video()
		accept_event()


func _unhandled_input(e: InputEvent) -> void:
	if _in_intro and e is InputEventKey and e.pressed and e.keycode in [KEY_ESCAPE, KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]:
		_skip_video()
		get_viewport().set_input_as_handled()


# ------------------------------------------------------------------ menu (left column: logo, then buttons)

func _build_menu() -> void:
	_menu = Control.new()
	_menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_menu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_menu)
	# soft dark gradient on the left so the logo and buttons read over the video
	var shade := TextureRect.new()
	var g := Gradient.new()
	g.set_color(0, Color(0.01, 0.03, 0.08, 0.78))
	g.set_color(1, Color(0.01, 0.03, 0.08, 0.0))
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.fill_to = Vector2(1, 0)
	shade.texture = gt
	shade.stretch_mode = TextureRect.STRETCH_SCALE
	shade.anchor_bottom = 1.0
	shade.offset_right = 900
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_menu.add_child(shade)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	col.anchor_top = 0.5; col.anchor_bottom = 0.5
	col.offset_left = 70; col.offset_right = 70 + 600
	col.offset_top = -330; col.offset_bottom = 330
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	_menu.add_child(col)

	_logo = TextureRect.new()
	if ResourceLoader.exists(LOGO):
		_logo.texture = load(LOGO)
	_logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_logo.custom_minimum_size = Vector2(600, 170)   # logo art is about 3.8:1
	col.add_child(_logo)
	_he_title = L10n.raw_label(UITheme.title("", 34, UIKit.GOLD_LIGHT), "ישראל") as Label
	_he_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_he_title.visible = L10n.is_he()
	col.add_child(_he_title)
	var sub := UITheme.label(("DEMO: lead the State of Israel from 14 May 1948 through the Six-Day War (1967). One turn is one quarter." if Sim.is_demo() else "Lead the State of Israel from 14 May 1948 to %s. One turn is one quarter." % V3Adapter.end_label()), 18, Color(0.92, 0.90, 0.84))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(sub)
	_items.append(sub)
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 10)
	col.add_child(gap)

	var nb := UITheme.button("New Game", _ask_mode, 24)
	nb.custom_minimum_size = Vector2(0, 58)
	nb.add_theme_stylebox_override("normal", UITheme.sb(Color(0.14, 0.32, 0.78), UIKit.GOLD_LIGHT, 2, 6, 12))
	nb.add_theme_stylebox_override("hover", UITheme.sb(Color(0.22, 0.42, 0.92), UIKit.GOLD_LIGHT, 2, 6, 12))
	nb.add_theme_font_override("font", UIKit.font("title"))
	col.add_child(nb)
	_items.append(nb)
	new_btn = nb
	_build_setup()
	continue_btn = UITheme.button("Continue", func(): ui.continue_latest(), 18)
	col.add_child(continue_btn)
	_items.append(continue_btn)
	var lb := UITheme.button("Load Game", func(): ui.open_panel("load"), 18)
	col.add_child(lb)
	_items.append(lb)
	refresh_continue()
	var hb := UITheme.button("How to Play", func(): ui.show_help(), 18)
	col.add_child(hb)
	_items.append(hb)
	var sb2 := UITheme.button("Settings", func(): ui.open_settings(), 18)
	col.add_child(sb2)
	_items.append(sb2)
	var cb := UITheme.button("Credits", func(): ui.show_credits(), 18)
	cb.name = "credits"
	col.add_child(cb)
	_items.append(cb)
	if not OS.has_feature("web"):   # (a browser tab cannot quit itself: no Quit on the web)
		var qb := UITheme.button("Quit", func(): get_tree().quit(), 16)
		col.add_child(qb)
		_items.append(qb)
	var note := UITheme.label("History is factual and sourced; every event shows its citation ids.", 14, Color(0.78, 0.80, 0.86))
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(note)
	_items.append(note)


func _build_setup() -> void:
	## The New Game panel (right of the menu column): difficulty against history's ghost, where to start (1948; the
	## 1967 / 1977 / 1992 scenario starts once the sim provides them), then Tutorial or the full game.
	setup_panel = PanelContainer.new()
	setup_panel.add_theme_stylebox_override("panel", UITheme.sb(Color(0.02, 0.05, 0.12, 0.93), UIKit.GOLD, 2, 8, 16))
	setup_panel.anchor_top = 0.5; setup_panel.anchor_bottom = 0.5
	setup_panel.offset_left = 720; setup_panel.offset_right = 720 + 640
	setup_panel.offset_top = -340; setup_panel.offset_bottom = 300
	setup_panel.visible = false
	_menu.add_child(setup_panel)
	mode_box = VBoxContainer.new()
	mode_box.add_theme_constant_override("separation", 8)
	setup_panel.add_child(mode_box)
	var t := UITheme.title("NEW GAME", 24, UIKit.GOLD_LIGHT)
	mode_box.add_child(t)
	mode_box.add_child(UITheme.sep())
	mode_box.add_child(UITheme.title("DIFFICULTY", 16, UIKit.GOLD))
	var dh := HBoxContainer.new()
	dh.add_theme_constant_override("separation", 6)
	mode_box.add_child(dh)
	var saved := str(GameSettings.cfg.get_value("game", "difficulty", "")) if GameSettings.cfg != null else ""
	var first := ""
	for d in V3Adapter.difficulties():
		var id := str(d.get("id", ""))
		var b := UITheme.button(str(d.get("name", id)), set_difficulty.bind(id), 18)
		b.custom_minimum_size = Vector2(140, 44)
		b.tooltip_text = str(d.get("desc", ""))
		dh.add_child(b)
		_diff_btns[id] = b
		if bool(d.get("default", false)) and first == "":
			first = id
	_diff_desc = UITheme.label("", 16, Color(0.88, 0.88, 0.86))
	_diff_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_diff_desc.custom_minimum_size = Vector2(600, 66)
	mode_box.add_child(_diff_desc)
	set_difficulty(saved if _diff_btns.has(saved) else (first if first != "" else "normal"))
	mode_box.add_child(UITheme.title("START", 16, UIKit.GOLD))
	for sc in V3Adapter.scenarios():
		var sid := str(sc.get("id", ""))
		var avail := bool(sc.get("available", false))
		var sb := UITheme.button(str(sc.get("name", "")) + ("" if avail else "   (in a coming update)"), set_scenario.bind(sid), 18)
		sb.disabled = not avail
		sb.alignment = HORIZONTAL_ALIGNMENT_LEFT
		sb.tooltip_text = str(sc.get("desc", ""))
		sb.custom_minimum_size = Vector2(0, 38)
		mode_box.add_child(sb)
		_scen_btns[sid] = sb
	var sd := UITheme.label("Each start has its own short briefing. Scenario starts are seeded from the historical record of that date.", 15, Color(0.78, 0.80, 0.86))
	sd.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mode_box.add_child(sd)
	# v4: how do you want to play? (Story by default; Full control is the v3 game)
	mode_box.add_child(UITheme.title("HOW DO YOU WANT TO PLAY?", 16, UIKit.GOLD))
	var ph := HBoxContainer.new()
	ph.add_theme_constant_override("separation", 6)
	mode_box.add_child(ph)
	for s in STYLES:
		var sb2 := UITheme.button(str(s[1]), set_play_style.bind(str(s[0])), 18)
		sb2.set_meta("label", str(s[1]))
		sb2.custom_minimum_size = Vector2(200, 42)
		sb2.tooltip_text = str(s[2])
		sb2.name = "style_" + str(s[0])
		ph.add_child(sb2)
		_style_btns[str(s[0])] = sb2
	_style_desc = UITheme.label("", 15, Color(0.88, 0.88, 0.86))
	_style_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_desc.custom_minimum_size = Vector2(600, 0)
	mode_box.add_child(_style_desc)
	set_play_style(ui._default_style() if ui != null else "full")
	mode_box.add_child(UITheme.sep())
	var tb := UITheme.button("Tutorial  (recommended for your first game)", func(): _start(true), 20)
	tb.custom_minimum_size = Vector2(0, 50)
	tb.add_theme_stylebox_override("normal", UITheme.sb(Color(0.62, 0.42, 0.10), UIKit.GOLD_LIGHT, 2, 6, 12))
	tb.add_theme_stylebox_override("hover", UITheme.sb(Color(0.78, 0.55, 0.16), UIKit.GOLD_LIGHT, 2, 6, 12))
	tb.tooltip_text = "The real game from 14 May 1948, one system at a time, with the Cabinet Secretary as your guide. Skip at any time."
	mode_box.add_child(tb)
	_tut_btn = tb
	var tl := UITheme.label("The real game from 14 May 1948, introduced one step at a time. You can skip it whenever you like.", 15, Color(0.85, 0.85, 0.85))
	tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mode_box.add_child(tl)
	var fb := UITheme.button("Full game  (no tutorial)", func(): _start(false), 20)
	fb.custom_minimum_size = Vector2(0, 50)
	fb.add_theme_stylebox_override("normal", UITheme.sb(Color(0.14, 0.32, 0.78), UIKit.GOLD_LIGHT, 2, 6, 12))
	fb.add_theme_stylebox_override("hover", UITheme.sb(Color(0.22, 0.42, 0.92), UIKit.GOLD_LIGHT, 2, 6, 12))
	mode_box.add_child(fb)
	set_scenario("")


func _skip_video() -> void:
	## a click or key skips the video playing now: the logo moves on to the intro, the intro to the menu
	if _in_brand:
		_end_brand()
	else:
		_end_intro()
