class_name GameUI
extends Node
## UI integration: owns the Sim, drives the HUD with live values and runs the Civ VI turn loop
## (Next Action button, choosers, city screen, event popups, notifications, units, save/load, start screen).
## Created by one hook in main.gd: `GameUI.attach(self)`; main.end_turn() delegates to harness_end_turn().
##
## Extra user args:  --ui-start (show the start screen in captures)  --ui-open=<panel>  --ui-turns=N
##                   --ui-test=<dir> (play turns through the UI code paths, screenshot each step; see ui_test.gd)

const QUICKSAVE := "user://quicksave.json"
const UNIT_MODELS := {"settler": "unit_settler_group", "builder": "unit_worker_builder", "armored_brigade": "unit_sherman_m50",
	"mbt_division": "unit_merkava", "mech_infantry": "unit_merkava", "fighter_squadron": "unit_jet_mirage", "jet_squadron": "unit_jet_mirage",
	"strike_squadron": "unit_jet_f16", "uav_squadron": "unit_jet_f16", "patrol_boat": "unit_saar_missile_boat", "missile_boat": "unit_saar_missile_boat",
	"air_defense_battery": "unit_iron_dome", "iron_dome_battery": "unit_iron_dome", "laser_defense_battery": "unit_iron_dome",
	"hostile_armor": "unit_sherman_m50", "hostile_rockets": "unit_trader_truck", "missile_salvo": "unit_trader_truck"}
const SMALL_TOWN_POP := 3          # towns at or below this population start on automated production

var game
var sim: Sim
var mv: MapView
var hud: HUD
var layer: CanvasLayer
var root: Control
var flags: UnitFlags
var start_screen: StartScreen
var help: HelpOverlay
var research_p: ChooserPanel
var civic_p: ChooserPanel
var city_s: CityScreen
var popup: DecisionPopup
var policy_p: PolicyPanel
var ghost_p: GhostPanel
var unit_p: UnitPanel
var info_p: UIWindow
var end_s: EndScreen
var pedia: Civilopedia
var cabinet_p: CabinetPanel
var save_w: SaveWindow
var lens: MapLens
var cpv: CombatPreview
var diplo_w: DiplomacyScreen      # v3: Civ VI-style diplomacy screen (partners, intel, deals, envoy decisions)
var settings_w: SettingsWindow    # v3: Settings (audio, UI scale, palette, keys, graphics, language)
var prog_w: ProgrammesPanel       # v3: national programmes (sim-endgame)
var fiscal_w: FiscalPanel         # V3 fix round: running costs and the fiscal levers (fix3-econ)
var credits_w: CreditsScreen      # v3: credits (start screen and game menu)
var lang_prompt: Control          # v3: the first-launch language choice (English / עברית)
var _start_after_language := false   # first launch: the start screen waits for the language choice
var _audio_q: Array = []          # stingers raised during a turn; the most important one plays once the turn is shown
var new_game_opts := {}           # v3: the New Game screen's difficulty and scenario
var place_bar: PanelContainer      # district placement banner (top centre)
var place_text: RichTextLabel
var placing := {}                  # district placement lens: {city, district, queue, sites: {Vector2i: site}}
var testing := false               # --ui-test run (autosaves go to user://saves_test/)
var rail: NotifyRail
var toast: Label

var started := false
var capture := false
var show_digest := false        # the full digest popup each turn (off: the history ticker shows headlines)
var ticker: HistoryTicker
## layout-audit (2026-10-17): the HUD's own coordinate system. The HUD draws its 1672x941 layout scaled to the screen's
## height and anchored left / right / centre; the panels that sit beside its drawn parts (the history sidebar, the
## notification rail, the blocker buttons, the combat preview, story mode's goals, NOW card, Government button, strip
## and era banner) are children of this box, laid out in the same 1672x941 units, so they grow and move with the HUD
## on any screen (16:10, 4:3, 21:9) instead of sliding under it. Windows stay in `root` (they follow the UI scale).
var hud_space: Control
var sats: HBoxContainer          # Civ VI satellite blocker buttons beside the end-turn button
var tree_w: TechTreeWindow
var tutorial: Tutorial
var loading: LoadingScreen   # dark fade + small flag and "Loading..." between screens
var auto_units := {}             # unit id -> true: crews / settlers the UI moves with the autoplayer each turn
var _hist_notes: Array = []      # this turn's history headlines (ticker), separate from actionable notes
var selected_unit := -1
var hud_city := -1
var unit_cache: Array = []
var _shown_units := {}       # str(id) -> Vector2i
var _targets := {}           # Vector2i -> "move" | "settle" | "build" | "attack"
var _build_opts := {}        # Vector2i -> [improvement ids]
var _notes: Array = []
var _queue: Array = []       # popups waiting to open
var _toast_t := 0.0
var _pending_banners: Array = []   # sim cities the map does not draw yet (player-founded ahead of history)

# ------------------------------------------------------------------ v4: story mode (V4_DESIGN 2.3-2.8)
var full_hud := true               # Full control: every ministry manual and the v3 HUD exactly; false = story mode
var casual := {}                   # the fallback ministers while the sim has no sim.auto: {auto: {domain: bool}, brief, report, ...}
var unlocked := {}                 # Unlocks: HUD element id -> the turn it appeared (saved in ui_state)
var intros_seen := {}              # Unlocks: element id -> the turn its one-line introduction was shown (once per save)
var intro_log: Array = []          # [id, turn] of every introduction shown this session (tests)
var _intro_q: Array = []           # [id, text] waiting for the strip
var _intro_t := 0.0
var test_style := ""               # --ui-test-style (UITest): the play style of every new game in a test run
var player_actions := 0            # every public player action (the click budget's cross-check, V4_DESIGN 2.7)
var fast_dates := false            # long UI tests: the map's date follows every 20 turns only
var story_c: StoryCard             # the story card (one card per decision)
var next_w: NextStep               # the primary prompt, the queue chips and auto-advance
var goals_w: GoalsCard
var report_w: MinistersPanel.Strip
var room_w: MinistersPanel         # the Cabinet Room
var story_left: VBoxContainer      # the left column in story mode: the era goals, then the ministers' report
var story_bar: HBoxContainer       # story mode's action buttons (only what is unlocked)
var intro_w: PanelContainer        # the Cabinet Secretary's one-line introduction strip
var intro_lbl: Label
var _first_turn := -1              # a new game's first turn: its first decision waits for the player's click
var gov_btn: Button                # story mode: the one "Government" button (its list holds every unlocked screen)
var gov_menu: PanelContainer       # its list, opened above it
var era_banner: PanelContainer     # story mode: "A new era" for a few seconds at an era change
var _era_banner_t := 0.0
var _focus_t := 0.0                # the map's highlight of the last decision's place (seconds left)
var story_block: Control           # story mode: the dim layer under an open story card (the HUD below is inert)


static func attach(g) -> GameUI:
	var ui := GameUI.new()
	ui.name = "GameUI"
	g.add_child(ui)
	ui.setup(g)
	g.set("game_ui", ui)
	return ui


func db() -> SimDB:
	return SimDB.get_db()


# ================================================================== setup

func setup(g) -> void:
	game = g
	hud = g.hud
	mv = g.map_view
	capture = g.capture_mode
	_load_settings()
	hud.live_mode = true
	if hud.next_turn_pressed.is_connected(g.end_turn):
		hud.next_turn_pressed.disconnect(g.end_turn)
	hud.next_turn_pressed.connect(_on_next_pressed)
	hud.panel_pressed.connect(_on_panel_pressed)
	hud.action_pressed.connect(_on_action)
	mv.tile_clicked.connect(_on_tile_clicked)
	mv.tile_right_clicked.connect(_on_tile_right_clicked)
	# unit flags sit with the map labels (below the HUD)
	var fl := CanvasLayer.new(); fl.layer = 1; add_child(fl)
	flags = UnitFlags.new(); flags.ui = self; flags.cam = g.rig.cam
	fl.add_child(flags)
	lens = MapLens.new(); lens.ui = self; lens.cam = g.rig.cam
	fl.add_child(lens)
	mv.tile_hovered.connect(_on_tile_hovered)
	layer = CanvasLayer.new(); layer.layer = 3; add_child(layer)
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = UITheme.get_theme()
	layer.add_child(root)
	hud_space = Control.new()
	hud_space.name = "HudSpace"
	hud_space.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(hud_space)
	hud.resized.connect(_fit_hud_space)
	_fit_hud_space()
	rail = NotifyRail.new(); rail.ui = self
	_place(rail, Vector2(1, 0), Vector2(1, 1), Rect2(-330, 110, 320, -(941 - 662) - 110))
	hud_space.add_child(rail)
	ticker = HistoryTicker.new(); ticker.ui = self
	_place(ticker, Vector2(0, 0), Vector2(0, 0), Rect2(10, 276, 298, 0))
	hud_space.add_child(ticker)
	sats = HBoxContainer.new()
	sats.alignment = BoxContainer.ALIGNMENT_END
	sats.add_theme_constant_override("separation", 6)
	_place(sats, Vector2(1, 1), Vector2(1, 1), Rect2(-1672 + 1060, -941 + 864, 1418 - 1060, 44))
	sats.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_space.add_child(sats)
	_build_story_ui()
	research_p = _win(ChooserPanel.new("tech"), "left", 450)
	civic_p = _win(ChooserPanel.new("civic"), "left", 450)
	city_s = _win(CityScreen.new(), "right", 500)
	policy_p = _win(PolicyPanel.new(), "center", 1240)
	ghost_p = _win(GhostPanel.new(), "center", 820)
	info_p = _win(UIWindow.new("Info"), "center", 700)
	unit_p = _win(UnitPanel.new(), "unit", UIWindow.UNIT_SLOT_X.y - UIWindow.UNIT_SLOT_X.x)
	popup = _win(DecisionPopup.new(), "center", 800)
	help = _win(HelpOverlay.new(), "center", 860)
	end_s = _win(EndScreen.new(), "center", 1220)
	pedia = _win(Civilopedia.new(), "center", 1240)
	cabinet_p = _win(CabinetPanel.new(), "center", 1080)
	cabinet_p.closed.connect(func(): _pump.call_deferred())
	save_w = _win(SaveWindow.new(), "center", 860)
	diplo_w = _win(DiplomacyScreen.new(), "center", 1300) as DiplomacyScreen
	diplo_w.closed.connect(func(): _refresh_hud(); _pump.call_deferred())
	settings_w = _win(SettingsWindow.new(), "center", 900) as SettingsWindow
	prog_w = _win(ProgrammesPanel.new(), "center", 1180) as ProgrammesPanel
	fiscal_w = _win(FiscalPanel.new(), "center", 980) as FiscalPanel
	fiscal_w.closed.connect(func(): _refresh_hud(); _pump.call_deferred())
	credits_w = _win(CreditsScreen.new(), "center", 1000) as CreditsScreen
	story_c = _win(StoryCard.new(), "center", 780) as StoryCard
	story_c.closed.connect(func(): _refresh_hud())
	story_c.visibility_changed.connect(_sync_story_block)
	room_w = _win(MinistersPanel.new(), "center", 1120) as MinistersPanel
	room_w.closed.connect(func(): _story_layout(); _refresh_hud())
	tree_exiting.connect(L10n.shutdown)
	prog_w.closed.connect(func(): _refresh_hud(); _pump.call_deferred())
	cpv = CombatPreview.new()
	_place(cpv, Vector2(1, 1), Vector2(1, 1), Rect2(-1672 + 1078 - 400, -941 + 818, 392, 0))   # ends above the action buttons (circles from y 824)
	cpv.grow_vertical = Control.GROW_DIRECTION_BEGIN
	hud_space.add_child(cpv)
	place_bar = PanelContainer.new()
	place_bar.add_theme_stylebox_override("panel", UITheme.sb(Color(0.03, 0.07, 0.15, 0.95), UIKit.GOLD_LIGHT, 2, 8, 12))
	# between the research / civic cards (left column, x < 312) and the city screen (right, x > 1164)
	_place(place_bar, Vector2(0.5, 0), Vector2(0.5, 0), Rect2(-516, 58, 836, 0))
	place_bar.grow_horizontal = Control.GROW_DIRECTION_END
	var pbh := HBoxContainer.new()
	pbh.add_theme_constant_override("separation", 10)
	place_bar.add_child(pbh)
	place_text = UITheme.rich("", 16)
	place_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	place_text.custom_minimum_size = Vector2(620, 0)
	pbh.add_child(place_text)
	pbh.add_child(UITheme.button("Cancel (Esc)", func(): cancel_placement(), 15))
	place_bar.visible = false
	root.add_child(place_bar)
	tree_w = TechTreeWindow.new()
	tree_w.ui = self
	tree_w.visible = false
	_place(tree_w, Vector2(0, 0), Vector2(1, 1), Rect2(16, 54, -32, -54 - 70))
	root.add_child(tree_w)
	popup.closed.connect(func(): _pump.call_deferred())
	city_s.closed.connect(_on_city_closed)
	unit_p.closed.connect(func(): select_unit(-1))
	toast = UITheme.label("", 19, UIKit.GOLD_LIGHT, "body_bold")
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast.add_theme_stylebox_override("normal", UITheme.sb(Color(0.03, 0.06, 0.13, 0.92), UIKit.GOLD, 1, 6, 10))
	_place(toast, Vector2(0.5, 0), Vector2(0.5, 0), Rect2(-356, 58, 660, 0))
	toast.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART   # long toasts wrap instead of growing over the side panels
	toast.visible = false
	root.add_child(toast)
	# v4polish: the top bar's explanations open under the bar, inside the screen (the HUD positions it)
	var tph := PanelContainer.new()
	tph.name = "TopTip"
	tph.add_theme_stylebox_override("panel", UITheme.sb(Color(0.03, 0.06, 0.13, 0.97), UIKit.GOLD, 1, 6, 10))
	tph.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tph.visible = false
	var tpl := UITheme.label("", 16, UIKit.TEXT)
	tpl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tph.add_child(tpl)
	root.add_child(tph)
	hud.tip_host = tph
	hud.tip_label = tpl
	tutorial = Tutorial.new()
	tutorial.ui = self
	root.add_child(tutorial)
	loading = LoadingScreen.new()
	add_child(loading)
	var args := OS.get_cmdline_user_args()
	var test_dir := ""
	for a in args:
		if a.begins_with("--ui-test="):
			test_dir = a.substr(10)
	if test_dir != "":
		testing = true
		var t := UITest.new()
		add_child(t)
		t.run.call_deferred(self, test_dir)
	elif capture and not ("--ui-start" in args):
		harness_begin()
		start_new_game(true)
		_capture_flags.call_deferred(args)
	else:
		_show_start()
		if capture:
			harness_begin()
			_start_flags.call_deferred(args)   # (v4polish: --ui-start takes --ui-open=new_game, --ui-click, --ui-hover, --ui-save)
	_refresh_hud()


func _start_flags(args: Array) -> void:
	## Captures of the title screen: --ui-open=new_game opens the New Game panel ("how do you want to play"); then the
	## clicks, the hover and the save, as in a game.
	await get_tree().process_frame
	await get_tree().process_frame
	for a in args:
		if str(a) == "--ui-open=new_game" and start_screen != null and is_instance_valid(start_screen):
			start_screen._show_menu_now()
			if not start_screen.setup_panel.visible:
				start_screen._ask_mode()
			print("UI-OPEN new_game: the New Game panel is open")
		elif str(a).begins_with("--ui-open=") and str(a) != "--ui-open=new_game":
			open_panel(str(a).substr(10))
	await _harness_inputs(args)
	harness_done()


func _capture_flags(args: Array) -> void:
	for a in args:
		if a.begins_with("--ui-load="):   # --ui-load=<save.json>: start from a save (e.g. the end state)
			quick_load(a.substr(10))
		elif a == "--ui-memorial":   # capture flag: show the finished 7 October memorial screen (for a screenshot)
			var layer := CanvasLayer.new()
			layer.layer = 99
			add_child(layer)
			var m := MemorialScreen.new()
			layer.add_child(m)
			m.play(MemorialScreen.load_data(sim))
			m.show_all_now()
		elif a.begins_with("--ui-ff="):   # --ui-ff=N: fast-forward to turn N (303 = past Q3 2023: the end screen)
			# V3 fixes B4: a full fast-forward takes about 4 minutes, longer than godot.sh's default windowed limit (240 s),
			# which killed the capture before its screenshot. Either run it with GODOT_LIMIT=600, or (cooler for the GPU)
			# fast-forward headless with --ui-ff-save=<path.json> (it saves and quits) and capture with --ui-load=<path.json>.
			fast_forward(int(a.substr(8)))
			for b in args:
				if b.begins_with("--ui-ff-save="):
					var sp: String = b.substr(13)
					var ok := SaveSlots.write(sp, sim, ui_state(), "Fast-forward %s" % sim.date_label(), "manual")
					print("UI-FF saved %s at %s (game over %s): %s" % [sp, sim.date_label(), str(sim.state.game_over), "ok" if ok else "FAILED"])
					get_tree().quit()
					return
	var target := 1
	for a in args:
		if a.begins_with("--turns="):   # capture.gd ends these turns itself (one per frame), after this runs
			target += int(a.substr(8))
	for a in args:
		if a.begins_with("--ui-turns="):
			for i in int(a.substr(11)):
				harness_end_turn()
			target += int(a.substr(11))
	# open panels only once every requested turn has run (so --turns=N --ui-open=... shows the current turn)
	for i in 900:
		if sim == null or sim.state.turn >= target or sim.state.game_over:
			break
		await get_tree().process_frame
	await get_tree().process_frame
	_refresh_all()
	if "--ui-tutorial" in args:   # --ui-tutorial [--ui-tut-step=<id>]: show a tutorial card (for screenshots)
		tutorial.begin(is_story())   # (--ui-style=story shows the story tutorial)
		for a in args:
			if a.begins_with("--ui-tut-step="):
				tutorial.jump_to_step(a.substr(14))
	for a in args:
		if a.begins_with("--ui-open="):
			open_panel(a.substr(10))
	await _harness_inputs(args)
	harness_done()


## v4polish (item 11): the capture harness for critics. capture.gd waits for it (root meta "ui_harness_busy") before its
## screenshot, so every click of a run lands before the shot is taken, however many there are.
##   --ui-click=x,y        a real left click at window pixels, in order; each prints "UI-CLICK n (x, y) on <control>"
##   --ui-click-delay=s    seconds before each click (default 1.5; the first waits 2.5 s for the screen to settle)
##   --ui-hover=x,y        the mouse rests there afterwards (a tooltip or the top bar's panel for the screenshot)
##   --ui-save=<path.json> after the clicks, the game is saved there (and its _meta / _ui sidecars); load it with
##                         --ui-load=<path.json> to chain turns with your own choices ("UI-SAVE <path> ok")
##   --ui-start --ui-open=new_game   the title screen with the New Game panel ("how do you want to play") open
func harness_begin() -> void:
	get_tree().root.set_meta("ui_harness_busy", true)


func harness_done() -> void:
	get_tree().root.set_meta("ui_harness_busy", false)


func _harness_inputs(args: Array) -> void:
	var delay := 1.5
	for a in args:
		if str(a).begins_with("--ui-click-delay="):
			delay = maxf(0.2, float(str(a).substr(17)))
	var n := 0
	for a in args:
		if str(a).begins_with("--ui-click="):   # --ui-click=x,y : a real left click at screen pixels (full input path)
			var p: PackedStringArray = str(a).substr(11).split(",")
			await get_tree().create_timer(2.5 if n == 0 else delay).timeout
			n += 1
			await _sim_click(Vector2(float(p[0]), float(p[1])), n)
	for a in args:
		if str(a).begins_with("--ui-hover="):   # --ui-hover=x,y : the mouse rests at screen pixels (a tooltip for a screenshot)
			var hp: PackedStringArray = str(a).substr(11).split(",")
			await get_tree().create_timer(1.5).timeout
			for k in 6:
				var mm := InputEventMouseMotion.new()
				mm.position = Vector2(float(hp[0]) + k * 0.5, float(hp[1]))
				mm.global_position = mm.position
				Input.parse_input_event(mm)
				await get_tree().process_frame
	for a in args:
		if str(a).begins_with("--ui-save="):
			var sp := str(a).substr(10)
			await get_tree().create_timer(0.5).timeout
			var ok := false
			if sim != null:
				tutorial.save()
				ok = SaveSlots.write(sp, sim, ui_state(), "Capture %s" % sim.date_label(), "manual")
			print("UI-SAVE %s %s (%s)" % [sp, "ok" if ok else "FAILED", sim.date_label() if sim != null else "no game"])


func _load_settings() -> void:
	## Settings (user://game.cfg) are applied before the first window is built. UI tests use their own file (fresh
	## each run); captures (--shot) keep the defaults so screenshots do not depend on the player's settings, except
	## for explicit --ui-scale=<pct> / --palette=colourblind overrides.
	var args := OS.get_cmdline_user_args()
	var is_test := Array(args).any(func(a): return str(a).begins_with("--ui-test="))
	if is_test:
		GameSettings.path = "user://game_test.cfg"
		if FileAccess.file_exists(GameSettings.path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(GameSettings.path))
	GameSettings.load_cfg()
	if capture and not is_test:
		GameSettings.reset_defaults()
		GameSettings.quality = Quality.level if Quality.level != "" else "medium"
	for a in args:
		if str(a).begins_with("--ui-scale="):
			GameSettings.ui_scale = clampf(float(str(a).substr(11)) / 100.0, GameSettings.SCALE_MIN, GameSettings.SCALE_MAX)
		elif str(a) == "--palette=colourblind":
			GameSettings.palette = "colourblind"
		elif str(a).begins_with("--lang="):   # this run only (tests, captures); the saved language is untouched
			GameSettings.lang_override = str(a).substr(7)
	UIAudio.muted = is_test
	GameSettings.apply_all(get_tree(), not capture and not is_test)
	if DisplayServer.get_name() != "headless":
		get_tree().root.theme = UITheme.get_theme()   # tooltips and popups use the navy-and-gold look
	_retry_audio.call_deferred(0)


func _retry_audio(n: int) -> void:
	## The AudioDirector may create its buses after the UI starts: apply the saved levels once they exist.
	if n > 20 or GameSettings.missing_buses().size() < GameSettings.BUSES.size() - 1:
		GameSettings.apply_audio()
		return
	await get_tree().create_timer(0.5).timeout
	_retry_audio(n + 1)


func open_settings(t := "") -> void:
	info_p.visible = false
	settings_w.open(t)
	_front(settings_w)


func on_palette_changed() -> void:
	## The colourblind palette changed: redraw what is on screen with the new good / bad colours.
	_refresh_hud()
	for w in [research_p, civic_p, policy_p, ghost_p, cabinet_p, diplo_w, prog_w]:
		if w.visible and ui_has_refresh(w):
			w.refresh()
	if city_s.visible:
		city_s.refresh()


static func ui_has_refresh(w) -> bool:
	return w != null and w.has_method("refresh")


func _sim_click(pos: Vector2, n := 0) -> void:
	## A real click: the pointer moves there (a motion event, so hover and tooltips follow), then a press and a release
	## on separate frames. Prints what is under the pointer, so a critic sees what each click hit.
	get_viewport().warp_mouse(pos)
	var mm := InputEventMouseMotion.new()
	mm.position = pos
	mm.global_position = pos
	Input.parse_input_event(mm)
	await get_tree().process_frame
	await get_tree().process_frame
	var hc := get_viewport().gui_get_hovered_control()
	print("UI-CLICK %d (%d, %d) on %s" % [n, int(pos.x), int(pos.y), (str(hc.name) + (" '%s'" % str((hc as Button).text).substr(0, 30) if hc is Button else "") + " in " + str(hc.get_parent().name)) if hc != null else "the map"])
	for pressed in [true, false]:
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT
		e.pressed = pressed
		e.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		e.position = pos
		e.global_position = pos
		Input.parse_input_event(e)
		await get_tree().process_frame
	await get_tree().process_frame


var _ticker_health := false   # the health strip under VS. HISTORY is showing (the ticker sits below it)


func _place_ticker() -> void:
	## "This quarter in history" sits under the VS. HISTORY chip (and its health strip), in the HUD's own units: it is
	## in hud_space, so it grows and moves with the chip on any screen. (A fixed pixel spot let the bigger chip slide
	## under the ticker on a 16:10 screen: the user's report, 2026-10-17.)
	if ticker == null:
		return
	var top := 276.0 + (28.0 if _ticker_health else 0.0)
	if absf(ticker.offset_top - top) > 0.5:
		_place(ticker, Vector2(0, 0), Vector2(0, 0), Rect2(10, top, 298, 0))


func _fit_hud_space() -> void:
	## hud_space covers the screen in the HUD's 1672x941 units (as wide as the screen allows) at the HUD's scale.
	if hud_space == null or hud == null:
		return
	var vs: Vector2 = hud.size if hud.size.y >= 10.0 else root.get_viewport_rect().size   # (before the HUD's first layout)
	var k := maxf(vs.y, 1.0) / 941.0   # = HUD._ref_scale()
	var want := vs / k
	if absf(hud_space.scale.x - k) > 0.0001 or hud_space.size.distance_to(want) > 0.25 or hud_space.position != Vector2.ZERO:
		hud_space.position = Vector2.ZERO
		hud_space.size = want
		hud_space.scale = Vector2(k, k)
	_place_ticker()
	if era_banner != null and era_banner.visible:
		_place_era_banner()
	if sats != null:
		# the blocker buttons end at the minimap's toolbar (right-anchored) and start right of the action bar (centred):
		# on a narrow layout (4:3, 5:4) the action bar comes closer, so the row is shorter (_build_sats shows what fits)
		var dx := want.x - 1672.0
		var sl := maxf(1060.0 + dx, 1060.0 + dx * 0.5) - want.x
		if absf(sats.offset_left - sl) > 0.5:
			sats.offset_left = sl
			if sim != null:
				_refresh_hud.call_deferred()   # (rebuilds the row for its new room)


func _place(c: Control, a0: Vector2, a1: Vector2, r: Rect2) -> void:
	c.anchor_left = a0.x; c.anchor_top = a0.y; c.anchor_right = a1.x; c.anchor_bottom = a1.y
	c.offset_left = r.position.x; c.offset_top = r.position.y
	c.offset_right = r.position.x + r.size.x; c.offset_bottom = r.position.y + r.size.y


func _win(w: UIWindow, where: String, width: float) -> UIWindow:
	w.ui = self
	w.visible = false
	w.dock = where if where in ["left", "right", "unit"] else ""
	if where == "right":
		w.dock_bottom = 88.0
	match where:
		"left":
			_place(w, Vector2(0, 0), Vector2(0, 1), Rect2(8, 54, width, -54 - 30))
		"right":
			_place(w, Vector2(1, 0), Vector2(1, 1), Rect2(-width - 8, 54, width, -54 - 88))
			w.grow_horizontal = Control.GROW_DIRECTION_BEGIN  # wider content grows leftwards, not off-screen
		"unit":
			# (its slot, at the HUD's scale, is kept by UIWindow._fit_docked: the action bar left, the minimap right)
			_place(w, Vector2(1, 1), Vector2(1, 1), Rect2(-1672 + UIWindow.UNIT_SLOT_X.x, -941 + UIWindow.UNIT_SLOT_BOTTOM, UIWindow.UNIT_SLOT_X.y - UIWindow.UNIT_SLOT_X.x, 0))
			w.grow_vertical = Control.GROW_DIRECTION_BEGIN
		_:
			_place(w, Vector2(0.5, 0.5), Vector2(0.5, 0.5), Rect2(-width * 0.5, -150, width, 300))
			w.grow_horizontal = Control.GROW_DIRECTION_BOTH
			w.grow_vertical = Control.GROW_DIRECTION_BOTH
			w.centered = true
			w.pref_width = width
	root.add_child(w)
	return w


func _show_start() -> void:
	# first launch: the language comes before anything else, so the intro and the menu already show in it
	var first := not GameSettings.language_chosen and GameSettings.lang_override == "" and not capture and not testing
	if first:
		_start_after_language = true
		show_language_prompt()
		return
	_show_start_screen()
	if "--ui-lang-prompt" in OS.get_cmdline_user_args():
		show_language_prompt()


func _show_start_screen() -> void:
	start_screen = StartScreen.new()
	start_screen.ui = self
	root.add_child(start_screen)
	if "--ui-help" in OS.get_cmdline_user_args():
		show_help()
	if "--ui-credits" in OS.get_cmdline_user_args():
		show_credits.call_deferred()


func show_credits() -> void:
	info_p.visible = false
	credits_w.open()
	_front(credits_w)


func show_language_prompt() -> void:
	## First launch: English or Hebrew, before anything else (also in Settings > Display > Language at any time).
	if lang_prompt != null and is_instance_valid(lang_prompt):
		lang_prompt.queue_free()
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.72)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	L10n.keep_ltr(dim)
	var cc := CenterContainer.new()
	cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.add_child(cc)
	var pc := PanelContainer.new()
	pc.add_theme_stylebox_override("panel", UITheme.sb(Color(0.03, 0.06, 0.14, 0.98), UIKit.GOLD, 2, 10, 28))
	cc.add_child(pc)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	pc.add_child(v)
	for t in [["Choose your language", 24], ["בחרו שפה", 26]]:
		var l := L10n.raw_label(UITheme.title("", int(t[1]), UIKit.GOLD_LIGHT), str(t[0])) as Label
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(l)
	v.add_child(UITheme.sep())
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 18)
	h.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_child(h)
	for code in ["en", "he"]:
		var b := L10n.raw_label(UITheme.button("", choose_language.bind(code), 26), L10n.lang_name(code)) as Button
		b.custom_minimum_size = Vector2(220, 64)
		b.add_theme_font_override("font", UIKit.font("title") if code == "en" else L10n.hebrew_font(700))
		b.name = "lang_" + code
		h.add_child(b)
	var note := L10n.raw_label(UITheme.label("", 16, UIKit.TEXT_DIM), "You can change it later in Settings.  ·  אפשר לשנות זאת בכל עת בהגדרות.") as Label
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(note)
	lang_prompt = dim
	root.add_child(dim)


func choose_language(code: String) -> void:
	settings_w.set_language(code)
	settings_w.visible = false
	if lang_prompt != null and is_instance_valid(lang_prompt):
		lang_prompt.queue_free()
	lang_prompt = null
	if _start_after_language:   # first launch: now the intro and the menu
		_start_after_language = false
		_show_start_screen()


func on_language_changed() -> void:
	## A live language switch (Settings or the first-launch prompt): the text on screen re-translates itself; what
	## code built from the language (window bodies, the start screen's column, the HUD) is rebuilt.
	_refresh_hud()
	hud.queue_redraw()
	for w in [research_p, civic_p, policy_p, ghost_p, cabinet_p, diplo_w, prog_w, help, pedia, credits_w, save_w, city_s, end_s, story_c, room_w]:
		if w != null and w.visible and ui_has_refresh(w):
			w.refresh()
	_story_layout()
	if start_screen != null and is_instance_valid(start_screen) and start_screen.has_method("refresh_language"):
		start_screen.refresh_language()


func show_help() -> void:
	help.refresh()
	help.visible = true
	help.move_to_front()


# ================================================================== game lifecycle

func start_new_game(quiet := false, with_tutorial := false, opts := {}) -> void:
	## opts (the New Game screen): {difficulty, scenario}; defaults to new_game_opts, then Normal from 14 May 1948.
	_drop_sim()
	sim = Sim.new()
	var o := new_game_opts.duplicate() if opts.is_empty() else opts.duplicate()
	var ng := {"mode": "player", "seed": 1948}
	if str(o.get("difficulty", "")) != "":
		ng["difficulty"] = str(o["difficulty"])
	if str(o.get("scenario", "")) != "" and not with_tutorial:
		ng["scenario"] = str(o["scenario"])
	# v4: the play style (New Game: Story by default, or Full control). The v3 tutorial teaches Full control until
	# the story tutorial (v4-onboarding: Tutorial.STEPS_STORY) exists.
	var style := str(o.get("play_style", _default_style()))
	if with_tutorial and not _tutorial_story():
		style = "full"
	ng["play_style"] = "full" if style == "full" else "story"
	sim.new_game(ng)
	V3Adapter.reset()
	_connect_sim()
	UIAudio.set_era(int(sim.state.era))
	started = true
	if start_screen:
		start_screen.queue_free()
		start_screen = null
	# Many localities exist on day one: only the larger cities ask for production; small towns automate.
	for c in sim.active_cities():
		if c.pop() <= SMALL_TOWN_POP and c.key != sim.state.capital:
			_automate(c)
	_notes = sim.get_notifications().filter(func(n): return int(n.get("turn", 0)) >= sim.state.turn and n.get("kind") != "blocked")
	hud_city = sim.city_by_key(sim.state.capital).id if sim.city_by_key(sim.state.capital) else -1
	game.set_date(sim.state.turn)
	_reset_units()
	if with_tutorial:
		tutorial.begin(ng["play_style"] == "story")   # v4: the story tutorial in story mode, the v3 steps in Full control
	else:
		tutorial.active = false
		tutorial.card.visible = false
		tutorial.advisor = false
		tutorial.advised.clear()
		tutorial.tip = ""
	_init_style(style)
	if ng.has("scenario") and sim.state.turn > 1 and not quiet:
		_show_briefing(str(ng["scenario"]))   # queued first: the briefing opens before the quarter's decisions
	_after_turn_start(quiet)


func _show_briefing(sid: String) -> void:
	for sc in V3Adapter.scenarios():
		if str(sc.get("id", "")) == sid:
			_queue.push_front(func():
				popup.show_result(str(sc.get("name", "")), "[color=#e6c76e]%s[/color]\n\n%s" % [sim.date_label(), str(sc.get("desc", ""))], {})
				_front(popup))
			return


func start_from_save() -> void:
	quick_load()


func _drop_sim() -> void:
	if sim:
		sim.dispose()
	sim = null
	selected_unit = -1
	auto_units.clear()
	for w in [research_p, civic_p, city_s, policy_p, ghost_p, info_p, unit_p, popup, end_s, cabinet_p, diplo_w, prog_w, story_c, room_w]:
		w.visible = false
	if next_w != null:
		next_w.stop_auto()
	_intro_q.clear()
	if intro_w != null:
		intro_w.visible = false
	_queue.clear()
	_audio_q.clear()
	_end_placement()
	cpv.visible = false
	SimAdapter.reset_fallback()


func _connect_sim() -> void:
	sim.notification.connect(_on_sim_note)
	sim.production_completed.connect(_on_prod_done)
	sim.boost_triggered.connect(_on_boost)
	sim.city_founded.connect(_on_city_founded)
	sim.combat.connect(_on_combat)
	sim.game_over.connect(_on_game_over)
	# v3 audio hooks (AudioDirector, null-safe): stingers are queued during the turn and the most important one plays
	sim.tech_completed.connect(func(_id): _sting("research"))
	sim.era_changed.connect(func(era, _age): _sting("era"); UIAudio.set_era(int(era)))
	sim.crisis_started.connect(func(_c): _sting("war"))
	sim.crisis_ended.connect(func(_r): _sting("peace"))
	sim.diplomacy_changed.connect(func(_a, st): if str(st) in ["peace", "normalized"]: _sting("peace"))


const STING_ORDER := ["game_end", "war", "peace", "era", "government", "election", "research", "fork"]


func _sting(kind: String) -> void:
	if not kind in _audio_q:
		_audio_q.append(kind)


func _flush_audio(notes: bool) -> void:
	## One stinger per turn (the most important), the notification chime if anything new arrived, and the music
	## situation (war while a crisis is open).
	var best := ""
	for k in STING_ORDER:
		if k in _audio_q:
			best = k
			break
	_audio_q.clear()
	if best != "":
		UIAudio.sting(best)
	elif notes:
		UIAudio.sfx("notification")
	if sim != null:
		UIAudio.set_situation("war" if sim.state.crises.size() > 0 else "normal")


func _on_prod_done(cid: int, kind: String, item: String) -> void:
	_notes.append({"turn": sim.state.turn, "kind": "production", "text": "%s completed %s." % [_city_name(cid), item_name(kind, item)], "city": cid})


func _on_boost(kind: String, id: String, text: String) -> void:
	var cond := text.strip_edges().trim_suffix(".")
	if cond.length() > 0:
		cond = cond.substr(0, 1).to_lower() + cond.substr(1)
	var news := "%s! %s is %d%% %s (boost condition met: %s)." % ["Eureka" if kind == "tech" else "Inspiration", item_name(kind, id), _boost_pct(kind, id), "researched" if kind == "tech" else "complete", cond]
	if text.begins_with("History:"):
		news = "%s advanced by history: %s" % [item_name(kind, id), text.substr(8).strip_edges()]
	_notes.append({"turn": sim.state.turn, "kind": "boost", "text": news, "id": id, "tree": kind})


func _boost_pct(kind: String, id: String) -> int:
	var prog := float((sim.state.tech_progress if kind == "tech" else sim.state.civic_progress).get(id, 0.0))
	var cost: float = sim.tech_cost(id) if kind == "tech" else sim.civic_cost(id)
	return int(round(100.0 * clampf(prog / maxf(1.0, cost), 0, 1)))


func _on_city_founded(cid: int) -> void:
	var c = sim.city_by_id(cid)
	if c != null and (c.founded_by == "player" or c.pop() <= SMALL_TOWN_POP):
		_automate(c)   # new towns default to automated production; untick Automate in the city screen to manage one


func _on_combat(r: Dictionary) -> void:
	_notes.append({"turn": sim.state.turn, "kind": "combat", "text": _combat_text(r)})


func _automate(c) -> void:
	sim.set_city_automated(c.id, true)
	if c.queue.is_empty():
		var pick: Dictionary = SimAI.pick_production(sim, c)
		if not pick.is_empty():
			sim.set_production(c.id, pick["kind"], pick["id"], pick.get("tile", -1))


const HISTORY_KINDS := ["event", "city_joined", "city_removed", "territory"]


func _on_sim_note(n: Dictionary) -> void:
	if str(n.get("kind", "")) in ["blocked"]:
		return
	if str(n.get("kind", "")) == "government":
		_sting("government")
	elif str(n.get("kind", "")) == "election" or (str(n.get("kind", "")) == "event" and _event_kind(str(n.get("event", ""))) == "election"):
		# an election reaches the UI as an "event" notification (its own kind is the event record's): found by
		# --ui-test-stings, the election sting never fired before (fix4-ui, var N9)
		_sting("election")
	_notes.append(n)


var _ev_kinds := {}


func _event_kind(eid: String) -> String:
	if eid == "":
		return ""
	if _ev_kinds.is_empty():
		for ev in SimDB.get_db().events:
			_ev_kinds[str(ev.get("id", ""))] = str(ev.get("kind", ""))
	return str(_ev_kinds.get(eid, ""))


func _is_history(n: Dictionary) -> bool:
	var k := str(n.get("kind", ""))
	if k in HISTORY_KINDS:
		return true
	return k == "city_founded" and str(n.get("text", "")).find("historical") >= 0


func _split_notes() -> void:
	## Actionable items go to the right-hand rail; history headlines go to the ticker (deduplicated foundings).
	var act := []
	var hist := []
	var founded := {}
	var q0 := SimDB.date_iso(sim.state.turn) if sim else ""
	var titles := {}
	for n in _notes:
		if str(n.get("kind")) == "event":
			titles[str(n.get("text", ""))] = true
	for n in _notes:
		if str(n.get("kind")) == "event" and n.has("event"):
			var ev = db().event_by_id.get(str(n["event"]))
			if ev != null and (str(ev.get("date", "")) < q0 or int(ev.get("_turn", sim.state.turn)) < sim.state.turn) and not bool(n.get("has_choice", false)):
				continue   # dated before this quarter (e.g. a 1948-54 affair starting in January): log only
		if str(n.get("kind")) == "crisis" and titles.has(str(n.get("text", "")).trim_prefix("Crisis: ")):
			continue   # the war already shows as the event headline; its response is on the end-turn button
		if _is_history(n):
			if str(n.get("kind")) == "city_founded":
				founded[int(n.get("city", -1))] = true
			hist.append(n)
		else:
			act.append(n)
	hist = hist.filter(func(n): return not (str(n.get("kind")) == "city_joined" and founded.has(int(n.get("city", -2)))))
	# Decisions come before the quarter's headlines (Civ VI order): while a cabinet decision (fork) or an
	# event choice is open, this quarter's outcomes stay hidden so a headline never answers a pending fork.
	var open_forks := _forks_open()
	if open_forks > 0:
		var held := hist.filter(func(n): return int(n.get("turn", sim.state.turn)) >= sim.state.turn)
		hist = hist.filter(func(n): return int(n.get("turn", sim.state.turn)) < sim.state.turn)
		if held.size() > 0:
			hist.append({"kind": "hold", "turn": sim.state.turn,
				"text": "%d headline%s this quarter: shown after your %s." % [held.size(), "" if held.size() == 1 else "s", "decision" if open_forks == 1 else "decisions"]})
	_hist_notes = hist
	if is_story():   # story mode: no rail and no sidebar; the headlines go into the ministers' report
		rail.set_items([])
		ticker.set_items([], [])
		return
	rail.set_items(act)
	ticker.set_items(hist, sim.get_upcoming_events(6) if sim else [])


func _combat_text(r: Dictionary) -> String:
	## A readable line for a combat result (never the raw dictionary).
	if r.has("text"):
		return str(r["text"])
	var att = sim.unit_by_id(int(r.get("attacker", -1))) if r.has("attacker") else null
	var an := item_name("unit", str(att.type)) if att != null else "Your unit"
	var where := ""
	if r.get("target") is Array and (r["target"] as Array).size() == 2:
		var c = sim.city_at(Vector2i(int(r["target"][0]), int(r["target"][1])))
		if c != null:
			where = " at " + str(c.name)
	var bits := []
	if r.has("damage_dealt"):
		bits.append("dealt %d damage" % int(round(float(r["damage_dealt"]))))
	if r.has("damage_taken") and float(r["damage_taken"]) > 0:
		bits.append("took %d" % int(round(float(r["damage_taken"]))))
	if r.has("killed"):
		bits.append("the enemy unit was destroyed")
	if bool(r.get("attacker_killed", false)):
		bits.append("the unit was lost")
	if bits.is_empty():
		return "%s fought%s." % [an, where]
	return "%s attacked%s%s: %s." % [an, " (ranged)" if bool(r.get("ranged", false)) else "", where, ", ".join(bits)]


# ================================================================== the turn loop

func _on_next_pressed() -> void:
	if not started:
		return
	if sim and sim.state.game_over:
		show_end_screen()   # "GAME OVER" reopens the end summary
		return
	if is_story():
		story_primary()   # story mode: the one primary prompt (Shift+click forcing exists only in Full control)
		return
	if hud.last_shift or Input.is_key_pressed(KEY_SHIFT):
		end_turn(true)
	else:
		next_action()


func next_action() -> void:
	if is_story():
		story_primary()
		return
	var a := sim.next_action()
	match str(a["type"]):
		"end_turn":
			end_turn(false)
		"event_choice":
			open_event(str(a["event"]))
		"crisis_response", "dedication", "agenda":
			popup.show_options(str(a["type"]), a)
			_front(popup)
		"fill_policy":
			open_panel("policy")
		"choose_research":
			open_panel("research")
		"choose_civic":
			open_panel("civic")
		"choose_production":
			open_city(int(a["city"]), true)
		"unit_orders":
			select_unit(int(a["unit"]), true)
		"immigration":
			popup.show_immigration(a); _front(popup)
		"fork":
			popup.show_fork(a); _front(popup)
		"policy_review":
			open_panel("policy")
		"state_budget", "budget_review", "minister", "coalition":
			open_cabinet(a)
		"programme":
			open_programmes(a)
		_:
			if V3Adapter.is_diplo_decision(a):
				open_diplomacy("", a)
			else:
				open_generic(a)


func open_diplomacy(actor := "", d := {}) -> void:
	info_p.visible = false
	diplo_w.open(actor, d)
	_front(diplo_w)


func open_programmes(d := {}) -> void:
	prog_w.open(d)
	_front(prog_w)


func open_fiscal() -> void:
	if sim == null or fiscal_w == null:
		return
	fiscal_w.open()
	_front(fiscal_w)


func _after_lever(msg: String) -> void:
	_refresh_all()
	if city_s.visible:
		city_s.refresh()
	if fiscal_w.visible:
		fiscal_w.refresh()
	if msg != "":
		show_toast(msg, 4.0)


func fiscal_building(action: String, city_id: int, bid: String) -> String:
	## The City screen's Upkeep tab and the fiscal panel: "mothball" | "reopen" | "close" one building. "" = done.
	var why := ""
	match action:
		"mothball": why = sim.mothball_building(city_id, bid)
		"reopen": why = sim.reopen_building(city_id, bid)
		"close": why = sim.close_building(city_id, bid)
	var nm := item_name("building", bid)
	_after_lever(("%s: %s." % [nm, {"mothball": "mothballed", "reopen": "reopened", "close": "closed for good"}.get(action, action)]) if why == "" else ("%s: %s." % [nm, why]))
	return why


func mothball_plan(plan: Array) -> bool:
	var saved := 0.0
	if sim.get("econ") != null and sim.econ.has_method("mothball_many"):
		saved = float(sim.econ.mothball_many(plan))
	else:
		for x in plan:
			if sim.mothball_building(int(x["city"]), str(x["building"])) == "":
				saved += float(x.get("saves", 0))
	_after_lever("%d buildings mothballed: about %d Gold a quarter saved." % [plan.size(), int(round(saved))])
	return saved > 0.0


func privatise(pid: String) -> bool:
	var ok: bool = sim.privatise(pid)
	_after_lever("" if ok else "The sale is not possible now.")
	return ok


func policy_cut(pid: String, mode: String) -> bool:
	## The Treasury's costly policy cards (fix4-econ): "half" | "suspend" | "restore". The sim's own notice says what it saved.
	if not sim.has_method("scale_back_policy"):
		return false
	var why: String = sim.restore_policy(pid) if mode == "restore" else sim.scale_back_policy(pid, mode)
	var nm := str(db().policies.get(pid, {}).get("name", pid))
	_after_lever(("%s: %s." % [nm, {"half": "runs at half strength", "suspend": "suspended", "restore": "restored in full"}.get(mode, mode)]) if why == "" else ("%s: %s." % [nm, why]))
	if policy_p != null and policy_p.visible:
		policy_p.refresh()
	return why == ""


func stabilise() -> bool:
	var ok: bool = sim.stabilise()
	_after_lever("The stabilisation package is adopted." if ok else "The package is not possible now.")
	return ok


func open_generic(a: Dictionary) -> void:
	## Decision types added to the sim later (API is additive): options popup resolved by sim.choose_<type>(index).
	if a.has("options"):
		popup.show_options(str(a["type"]), a)
		_front(popup)
	else:
		show_toast(str(a.get("label", a["type"])))


func choose_generic(t: String, i: int) -> void:
	player_actions += 1
	var m := "choose_" + t
	var ok := false
	if sim.has_method(m):
		ok = bool(sim.call(m, i))
	elif sim.has_method("resolve_decision"):
		ok = bool(sim.call("resolve_decision", t, i))
	if not ok:
		show_toast("That option is not available.")
		return
	popup.close()
	_refresh_all()


func end_turn(force := false) -> bool:
	if sim == null or sim.state.game_over:
		return false
	player_actions += 1
	var story := is_story()
	if story:
		MinistersPanel.settle(self)
		if not force and not NextStep.blocking_left(self).is_empty():
			var p: Dictionary = NextStep.blocking_left(self)[0]
			show_toast("Decide first: %s." % NextStep.title_of(sim, p))
			story_open(p)
			return false
	for w in [research_p, civic_p, city_s, unit_p, popup, info_p, policy_p, ghost_p, tree_w, pedia, save_w, cabinet_p, diplo_w, prog_w, settings_w, story_c, room_w]:
		w.visible = false
	if next_w != null:
		next_w.stop_auto()
	_queue.clear()
	_on_city_closed()
	select_unit(-1)
	_notes.clear()
	if tutorial.active:
		tutorial.gate()
	var ok := sim.end_turn(force)
	if not ok and story and not force:
		# story mode: what still blocks is routine the ministers could not answer: they end the quarter for it
		MinistersPanel.settle(self)
		if sim.blocking_decisions().all(func(d): return NextStep.owner_of(self, d) != ""):
			ok = sim.end_turn(true)
	if not ok:
		show_toast("Cannot end the turn yet: " + str(sim.next_action().get("label", "")))
		_refresh_hud()
		return false
	UIAudio.sfx("end_turn")
	_post_turn(capture)
	_flush_audio(_notes.size() > 0)
	return true


func _post_turn(quiet: bool) -> void:
	## Show the new turn's UI at once; the map (about 2 s to rebuild) catches up a couple of frames later.
	_hide_intro()   # (End Turn clears the Cabinet Secretary's strip; the next quarter's introductions follow)
	_run_auto_units()
	_after_turn_start(quiet)
	_push_date()
	if sim and not sim.state.game_over and SaveSlots.autosave_due(sim.state.turn) and (testing or not capture):
		var ap := SaveSlots.autosave(sim, ui_state())
		if ap != "" and not quiet:
			show_toast("Autosaved (%s)." % sim.date_label(), 2.0)


func _push_date() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	if sim and (not fast_dates or sim.state.turn % 20 == 0 or sim.state.game_over):
		game.set_date(sim.state.turn)


func harness_end_turn() -> void:
	## main.end_turn() (tools/shot.sh --turns=N): resolve everything as the autoplayer would and end exactly one turn.
	if not started:
		start_new_game(true)
	if sim.state.game_over:
		return
	var before := sim.state.turn
	SimAI.play_turn(sim)          # play_turn ends the turn itself
	if sim.state.turn == before:
		sim.end_turn(true)
	_notes = _notes.filter(func(n): return int(n.get("turn", 0)) >= sim.state.turn - 1)
	_post_turn(true)


func _run_auto_units() -> void:
	for id in auto_units.keys():
		var u = sim.unit_by_id(int(id))
		if u == null:
			auto_units.erase(id)
			continue
		if u.type == "builder":
			SimAI._builder(sim, u)
		elif u.type == "settler":
			SimAI._settler(sim, u)
	_sync_units()


func _after_turn_start(quiet: bool) -> void:
	if is_story():
		_story_turn_start(quiet and not testing)   # (UI tests see story mode as a player does: the card opens itself)
		return
	_refresh_all()
	if quiet or tutorial.active:
		return   # (the tutorial opens things itself, one step at a time)
	var fired := []
	for le in sim.state.event_log:
		if int(le.get("turn", -1)) == sim.state.turn:
			fired.append(str(le["id"]))
	# forks come first: a pending fork holds back the quarter's events, so its outcome is never shown before it
	for d in sim.blocking_decisions():
		if str(d["type"]) == "fork":
			_queue.append(_open_fork_decision.bind(str(d.get("fork", ""))))
	_queue_turn_items(fired)


func _queue_turn_items(fired: Array) -> void:
	var lab := sim.date_label()
	for pe in sim.get_pending_events():
		_queue.append(_open_event_if_pending.bind(str(pe["event"])))
	for d in sim.blocking_decisions():
		if d["type"] in ["crisis_response", "dedication"]:
			_queue.append(_open_option_decision.bind(str(d["type"])))
	for d in sim.blocking_decisions():
		if V3Adapter.is_diplo_decision(d):
			_queue.append(_open_diplo_if_pending)   # Civ VI: a foreign leader's envoy greets you at the start of the turn
			break
	if show_digest and fired.size() > 0:   # headlines after the decisions
		_queue.append(_queued_digest.bind(lab, fired))
	_pump()


func _open_event_if_pending(eid: String) -> void:
	for pe in sim.get_pending_events():
		if str(pe["event"]) == eid:
			open_event(eid)
			return
	_pump()


func _open_diplo_if_pending() -> void:
	var d := V3Adapter.diplo_decision(sim)
	if d.is_empty() or diplo_w.visible:
		_pump()
		return
	open_diplomacy("", d)


func _open_fork_decision(fid: String) -> void:
	for x in sim.blocking_decisions():
		if str(x["type"]) == "fork" and str(x.get("fork", "")) == fid:
			popup.show_fork(x)
			_front(popup)
			return
	_pump()


func _queued_digest(lab: String, fired: Array) -> void:
	if _forks_open() == 0:
		popup.show_digest(lab, fired)
		_front(popup)
	else:
		_pump()


func _forks_open() -> int:
	var n := 0
	if sim and not sim.state.game_over:
		for d in sim.blocking_decisions():
			if str(d.get("type", "")) in ["fork", "event_choice"]:
				n += 1
	return n


func _open_option_decision(t: String) -> void:
	for x in sim.blocking_decisions():
		if x["type"] == t:
			popup.show_options(t, x)
			_front(popup)
			return
	_pump()


func _pump() -> void:
	if is_story() and _queue.is_empty() and not popup.visible:
		_story_after_window()   # a v3 screen (Details, a panel) closed: the ministers settle, the prompt follows
		return
	if popup.visible or _queue.is_empty() or sim == null:
		return
	var f: Callable = _queue.pop_front()
	f.call()


func _on_game_over(summary: Dictionary) -> void:
	_queue.clear()
	_audio_q.clear()
	popup.visible = false
	if tutorial:
		tutorial.active = false
		tutorial.card.visible = false
	# the game ends on 7 October 2023 (the user's decision): fade to black and the memorial text first, then the results
	if MemorialScreen.applies(sim):
		_play_memorial(summary)
		return
	_show_results(summary)


var last_memorial_text := ""   # what the memorial showed (the UI test checks it word for word)


func _play_memorial(summary: Dictionary) -> void:
	var layer := CanvasLayer.new()
	layer.layer = 99
	add_child(layer)
	var m := MemorialScreen.new()
	m.ui = self
	layer.add_child(m)
	m.play(MemorialScreen.load_data(sim))
	last_memorial_text = m.shown_text()
	m.finished.connect(func():
		layer.queue_free()
		_show_results(summary))
	var testing := DisplayServer.get_name() == "headless"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--ui-test"):
			testing = true
	if capture and not ("--ui-memorial-play" in OS.get_cmdline_user_args()):
		testing = true   # a capture (--shot) of the game-over path shows the results; --ui-memorial captures the memorial itself
	if testing:
		m.finish()   # tests read last_memorial_text and go straight on to the results


func _show_results(summary: Dictionary) -> void:
	UIAudio.sting("game_end")
	end_s.show_summary(summary)
	_front(end_s)


func show_end_screen() -> void:
	if sim == null:
		return
	if tutorial:
		tutorial.card.visible = false
	end_s.show_summary(sim.get_end_summary() if sim.has_method("get_end_summary") else sim.score.final_summary())
	_front(end_s)


func return_to_start(open_new_game := false) -> void:
	## End screen "Return to start": drop the game and show the title screen over the map (menu at once, no logo
	## or intro again). open_new_game: open the New Game panel ("how do you want to play") on it.
	if tutorial:
		tutorial.active = false
		tutorial.card.visible = false
	_drop_sim()
	started = false
	_reset_units()
	for l in ["move", "settle", "build", "attack", "city", "worked"]:
		mv.clear_highlights(l)
	_notes.clear()
	rail.set_items([])
	_story_layout()
	_refresh_hud()
	var ad = get_node_or_null("/root/AudioDirector")
	if ad != null and ad.has_method("to_menu"):
		ad.to_menu()   # the game's music and ambience stop; the menu music starts again from the top
	if start_screen == null:
		_show_start()
	if open_new_game and start_screen != null and is_instance_valid(start_screen):
		(func(): if not start_screen.setup_panel.visible: start_screen._ask_mode()).call_deferred()


func fast_forward(to_turn: int) -> void:
	## Test/capture fast path (--ui-ff=N): the autoplayer resolves every decision and the map is only
	## redrawn once at the end (no per-turn rebuild), so a full game fits in one capture run.
	if not started:
		start_new_game(true)
	var t0 := Time.get_ticks_msec()
	while sim.state.turn < to_turn and not sim.state.game_over:
		if is_story():
			Unlocks.update(self)   # what the player would have seen unlock on the way (story mode)
		SimAI.play_turn(sim)
		_notes.clear()
		sim.end_turn(true)
		if sim.state.turn % 40 == 0:
			print("UI-FF %s (%d s)" % [sim.date_label(), (Time.get_ticks_msec() - t0) / 1000])
	print("UI-FF done at %s, game over %s, %d s" % [sim.date_label(), str(sim.state.game_over), (Time.get_ticks_msec() - t0) / 1000])
	game.set_date(sim.state.turn)
	_reset_units()
	_intro_q.clear()
	_story_layout()
	_refresh_all()


# ================================================================== refresh

func _refresh_all() -> void:
	if tutorial and tutorial.active:
		tutorial.gate()
	_sync_units()
	_sync_banners(true)
	_refresh_hud()
	_split_notes()
	if city_s.visible:
		city_s.refresh()
	if selected_unit >= 0:
		select_unit(selected_unit)


func _sync_banners(push_pop := false) -> void:
	## Banners show the sim's population; towns the player founded ahead of history get a UI-drawn banner
	## until the map draws them on their real date.
	if sim == null:
		return
	var shown := {}
	for c in mv.cities():
		shown[str(c.get("id", ""))] = true
	_pending_banners = []
	for c in sim.active_cities():
		if push_pop:
			mv.set_city_info(c.key, c.pop())
		if not shown.has(c.key):
			_pending_banners.append({"id": c.id, "name": c.name, "q": c.q, "r": c.r, "pop": c.pop()})


func _refresh_hud() -> void:
	if sim == null:
		hud.live = {"next_label": "NEW GAME", "next_blocking": false, "date": "14 May 1948", "turn": 0, "era": "",
			"top_items": [["gold", "-", ""], ["science", "-", ""], ["culture", "-", ""], ["food", "-", ""], ["happy", "-", ""]],
			"research": {"name": "-", "turns": 0, "progress": 0.0, "icon": "research"}, "civic": {"name": "-", "turns": 0, "progress": 0.0, "icon": "civics_columns"},
			"city": {"name": "-", "population": "-", "production": "-", "food": "-", "housing": "-", "building": "-", "building_turns": 0, "building_progress": 0.0}}
		hud.queue_redraw()
		return
	if tutorial and tutorial.active:
		tutorial.gate()
	var n := sim.get_national_summary()
	var d := sim.get_date()
	var live := {}
	live["turn"] = d["turn"]
	live["date"] = d["label"]
	live["era"] = d["era_name"]
	UITheme.show_hints = V3Adapter.hints(sim)
	var fr := V3Adapter.food(sim)
	var ec := V3Adapter.economy(sim)
	var food_bal := float(fr["surplus"])
	var net := float(n.get("gold_net", 0))
	live["top_items"] = [
		["gold", UITheme.fmt_num(float(n["gold_treasury"])), UITheme.fmt_signed(net), UIKit.BAD if float(n["gold_treasury"]) < 0 else UIKit.TEXT, UIKit.BAD if net < 0 else UIKit.TEXT],
		["science", "+%d" % int(n.get("science", 0)), ""],
		["culture", "+%d" % int(n.get("culture", 0)), ""],
		["food", UITheme.fmt_signed(food_bal), "", UIKit.TEXT if food_bal >= 0 else UIKit.BAD],
		_trust_item(float(n.get("avg_trust", 0))),
		["cities", "%.2fM" % (float(n.get("residents", 0)) / 1e6), ""],
		_econ_item(ec),
	]
	live["top_tips"] = [_gold_tip(n), "Science per turn: %d (research)." % int(n.get("science", 0)), "Culture per turn: %d (civics)." % int(n.get("culture", 0)),
		"\n".join(fr["tooltip"]), _trust_tip(float(n.get("avg_trust", 0))),
		"Population: %s residents (%d localities)." % [UITheme.fmt_num(float(n.get("residents", 0))), int(n.get("cities", 0))], "\n".join(ec["tooltip"])]
	var cb := V3Adapter.collapse_bar(sim)   # v3 item 13: a collapse of the state in sight: a red DANGER item
	if bool(cb.get("show", false)):
		live["top_items"].append(["danger", str(cb.get("text", "")), "", UIKit.BAD, UIKit.BAD])   # the red triangle and the quarters left
		live["top_tips"].append("\n".join(cb.get("tooltip", [])))
		if str(cb.get("id", "")) == "collapse_trust":
			var hi: Array = live["top_items"][4]   # Civic Trust in red
			while hi.size() < 4: hi.append("")
			hi[3] = UIKit.BAD
	live["research"] = _track_card("tech", str(n.get("current_tech", "")), float(n.get("science", 1)))
	live["civic"] = _track_card("civic", str(n.get("current_civic", "")), float(n.get("culture", 1)))
	live["ghost"] = ghost_summary()
	# the state's health strip under VS. HISTORY (fix3-econ score health) pushes the history sidebar down
	_ticker_health = float(live["ghost"].get("health", 1.0)) < 0.995 and str(live["ghost"].get("health_text", "")) != ""
	_place_ticker()
	live["city"] = _city_card()
	var a := sim.next_action()
	var lab := str(a.get("label", "NEXT TURN"))
	var nice := {"event_choice": "EVENT DECISION", "crisis_response": "CRISIS RESPONSE", "dedication": "CHOOSE DEDICATION", "fill_policy": "FILL POLICY SLOT",
		"choose_research": "CHOOSE RESEARCH", "choose_civic": "CHOOSE CIVIC", "choose_production": "CHOOSE PRODUCTION", "unit_orders": "UNIT NEEDS ORDERS",
		"agenda": "CABINET AGENDA", "immigration": "PLACE IMMIGRANTS", "fork": "CABINET DECISION", "policy_review": "REVIEW POLICIES", "end_turn": "NEXT TURN",
		"state_budget": "STATE BUDGET", "budget_review": "BUDGET REVIEW", "minister": "APPOINT MINISTER", "coalition": "COALITION TALKS",
			"diplomacy": "ENVOY", "programme": "NATIONAL PROGRAMME"}
	live["next_label"] = nice.get(str(a["type"]), lab)
	live["next_blocking"] = str(a["type"]) != "end_turn"
	var groups := decision_groups() if not (tutorial and tutorial.active) else []   # tutorial: one decision at a time
	live["next_sub"] = ("+%d more decisions" % (groups.size() - 1)) if groups.size() > 1 else ""
	live["next_tip"] = ("Before the turn can end: " + "; ".join(groups.map(func(g): return "%s%s" % [GROUP_LABEL.get(g["group"], str(g["group"]).capitalize()), (" (%d)" % int(g["count"])) if int(g["count"]) > 1 else ""])) + ". Shift+click forces the turn.") if groups.size() > 0 else "End the turn (%s)." % GameSettings.binding_text("end_turn")
	_build_sats(groups if not is_story() else [])
	if sim.state.game_over:
		live["next_label"] = "GAME OVER"; live["next_blocking"] = false; live["next_sub"] = ""
	if is_story():
		_story_live(live, n, fr, ec)
	hud.live = live
	hud.queue_redraw()
	if tutorial and tutorial.active:
		tutorial.tick.call_deferred()


const GROUP_OF := {"diplomacy": "diplomacy", "programme": "programme", "state_budget": "budget", "budget_review": "budget", "minister": "minister", "coalition": "coalition", "policy_review": "policy", "fork": "fork", "immigration": "immigration", "event_choice": "event", "crisis_response": "crisis", "dedication": "dedication", "fill_policy": "policy",
	"choose_research": "research", "choose_civic": "civic", "choose_production": "production", "unit_orders": "units", "agenda": "agenda"}
const GROUP_ICON := {"diplomacy": "diplomacy", "programme": "unlock_project", "budget": "gold", "minister": "unlock_policy", "coalition": "diplomacy", "fork": "unlock_policy", "immigration": "housing", "event": "star", "crisis": "diplomacy", "dedication": "star", "policy": "civics_columns", "research": "science",
	"civic": "culture", "production": "production", "units": "cities", "agenda": "gold"}
const GROUP_LABEL := {"diplomacy": "Envoy: a diplomatic decision", "programme": "National programme", "budget": "State budget", "minister": "Appoint or promote a minister", "coalition": "Coalition talks", "fork": "Cabinet decision", "immigration": "Place immigrants", "event": "Event decision", "crisis": "Crisis response", "dedication": "Choose dedication", "policy": "Fill policy slot",
	"research": "Choose research", "civic": "Choose civic", "production": "Choose production", "units": "Units need orders", "agenda": "Cabinet agenda"}


func decision_groups() -> Array:
	## Blocking decisions grouped like Civ VI blockers: one entry per kind, with a count. First = the button's.
	var order := []
	var by := {}
	var first := str(sim.next_action().get("type", ""))
	for d in sim.blocking_decisions():
		var g: String = GROUP_OF.get(str(d["type"]), str(d["type"]))
		if not by.has(g):
			by[g] = {"group": g, "type": d["type"], "count": 0, "first": d}
			order.append(g)
		by[g]["count"] += 1
	var out := []
	var fg: String = GROUP_OF.get(first, first)
	if by.has(fg):
		out.append(by[fg])
	for g in order:
		if g != fg:
			out.append(by[g])
	return out


func _build_sats(groups: Array) -> void:
	for c in sats.get_children():
		c.queue_free()
	var fit := maxi(0, int((sats.offset_right - sats.offset_left + 6.0) / 50.0))   # 44 px buttons, 6 apart (the rest: "+N more" on the button)
	for i in range(1, mini(groups.size(), mini(6, fit + 1))):
		var g: Dictionary = groups[i]
		var b := Button.new()
		b.focus_mode = Control.FOCUS_NONE
		b.icon = UIKit.icon(GROUP_ICON.get(g["group"], "star"))
		b.expand_icon = true
		b.custom_minimum_size = Vector2(44, 44)
		b.text = ""
		b.tooltip_text = "%s%s" % [GROUP_LABEL.get(g["group"], str(g["group"]).capitalize()), (" (%d)" % int(g["count"])) if int(g["count"]) > 1 else ""]
		b.add_theme_stylebox_override("normal", UITheme.sb(Color(0.45, 0.28, 0.06, 0.95), UIKit.GOLD_LIGHT, 2, 22, 6))
		b.add_theme_stylebox_override("hover", UITheme.sb(Color(0.70, 0.45, 0.12, 0.98), Color.WHITE, 2, 22, 6))
		b.add_theme_constant_override("icon_max_width", 28)
		var d: Dictionary = g["first"]
		b.pressed.connect(func(): jump_to(d))
		if int(g["count"]) > 1:
			var badge := UITheme.label(str(int(g["count"])), 13, Color.WHITE, "body_bold")
			badge.add_theme_stylebox_override("normal", UITheme.sb(Color(0.75, 0.15, 0.12), Color.WHITE, 1, 9, 3))
			badge.position = Vector2(26, -6)
			badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
			b.add_child(badge)
		sats.add_child(b)


func jump_to(d: Dictionary) -> void:
	player_actions += 1
	match str(d["type"]):
		"event_choice": open_event(str(d["event"]))
		"crisis_response", "dedication", "agenda":
			popup.show_options(str(d["type"]), d); _front(popup)
		"fill_policy": open_panel("policy")
		"choose_research": open_panel("research")
		"choose_civic": open_panel("civic")
		"choose_production": open_city(int(d["city"]), true)
		"unit_orders": select_unit(int(d["unit"]), true)
		"immigration":
			popup.show_immigration(d); _front(popup)
		"fork":
			popup.show_fork(d); _front(popup)
		"policy_review": open_panel("policy")
		"state_budget", "budget_review", "minister", "coalition": open_cabinet(d)
		"programme": open_programmes(d)
		_:
			if V3Adapter.is_diplo_decision(d):
				open_diplomacy("", d)
			else:
				open_generic(d)


const GHOST_FROM_TURN := 9      # the comparison means little before the player has made choices (Q2 1950)
const GHOST_TIE := 0.01         # within 1% of history counts as even (same rule as SimScore)


func ghost_counts(sample: Dictionary) -> Dictionary:
	var v: Dictionary = sample.get("v", {})
	var g: Dictionary = sample.get("g", {})
	var out := {"ahead": 0, "even": 0, "behind": 0}
	if g.is_empty():
		return out
	for t in SimScore.TRACKS:
		var pv := float(v.get(t["id"], 0)); var gv := float(g.get(t["id"], 0))
		if gv <= 0:
			out["even"] += 1
		elif pv > gv * (1.0 + GHOST_TIE):
			out["ahead"] += 1
		elif pv < gv * (1.0 - GHOST_TIE):
			out["behind"] += 1
		else:
			out["even"] += 1
	return out


func _econ_item(ec: Dictionary) -> Array:
	## The top bar's debt and inflation indicator: inflation with its trend (rising is bad), then the debt in years of revenue.
	var inf := float(ec["inflation"])
	var tr := float(ec["trend"])
	var arrow := " ▲" if tr >= 1.0 else (" ▼" if tr <= -1.0 else "")
	var base := float(ec.get("baseline", inf))
	var lvl := str(ec.get("level", "ok"))   # ok | watch | warning | danger (fix3-econ's tiers; older sims: ok | watch | danger)
	# inflation: red when high, far above history's or climbing fast; amber when rising above history's path or the
	# fiscal indicator is on watch; green when low and steady (V3 fixes B1)
	var c1: Color = UIKit.TEXT
	if lvl == "danger" or inf > maxf(15.0, base + 3.0) or (tr >= 3.0 and inf > 10.0):
		c1 = UIKit.BAD
	elif lvl == "warning":
		c1 = UIKit.WARN_HI
	elif (tr >= 1.0 and inf > base + 0.5) or inf > base + 1.5 or inf > 10.0 or lvl == "watch":
		c1 = UIKit.WARN
	elif inf <= 5.0 and tr <= 0.5:
		c1 = UIKit.GREEN
	var debt := float(ec["debt"])
	var dtxt := "" if debt < 0.5 else "debt %sy" % str(snappedf(float(ec["debt_ratio"]), 0.1))
	var c2: Color = UIKit.TEXT_DIM if debt < 0.5 else (UIKit.BAD if float(ec["debt_ratio"]) > 1.5 or lvl == "danger" else UIKit.WARN_HI if lvl == "warning" else (UIKit.WARN if float(ec["debt_ratio"]) > 1.0 or lvl == "watch" else UIKit.TEXT))
	var it := ("%d%%" % int(round(inf))) if absf(inf) >= 10.0 else ("%.1f%%" % inf)
	return ["economy", it + arrow, dtxt, c1, c2, true, lvl]


func _trust_trend() -> Array:
	## [change in Civic Trust over the last four quarters (points), history's cohesion now (or -1)] from the score samples.
	var h: Array = sim.get_history()
	if h.size() < 2:
		return [0.0, -1.0]
	var last: Dictionary = h[h.size() - 1]
	var then: Dictionary = h[maxi(0, h.size() - 5)]
	var now_c := float((last.get("v", {}) as Dictionary).get("cohesion", 0.0))
	var then_c := float((then.get("v", {}) as Dictionary).get("cohesion", now_c))
	var gd: Dictionary = last.get("g", {})
	return [now_c - then_c, float(gd.get("cohesion", -1.0)) if not gd.is_empty() else -1.0]


func _trust_item(avg: float) -> Array:
	## Civic Trust on the top bar, coloured by level and trend (V3 fixes B1): red when low or falling fast, amber when
	## middling or slipping, green when high and steady; an arrow when it moved 2+ points in a year.
	var tr := float(_trust_trend()[0])
	var arrow := " ▲" if tr >= 2.0 else (" ▼" if tr <= -2.0 else "")
	var c: Color = UIKit.TEXT
	if avg < 40.0 or (tr <= -6.0 and avg < 60.0):
		c = UIKit.BAD
	elif avg < 55.0 or tr <= -3.0:
		c = UIKit.WARN
	elif avg >= 70.0 and tr > -1.0:
		c = UIKit.GREEN
	return ["happy", ("%d%%" % int(round(avg))) + arrow, "", c]


func _trust_tip(avg: float) -> String:
	var tt := _trust_trend()
	var lines := ["Civic Trust: %d%% on average across the cities. Low trust slows growth and production." % int(round(avg))]
	if absf(float(tt[0])) >= 1.0:
		lines.append("%s %d points on a year ago." % ["Up" if float(tt[0]) > 0 else "Down", int(round(absf(float(tt[0]))))])
	if float(tt[1]) > 0.0 and sim.state.turn >= 9:
		lines.append("History's level now: %d%%." % int(round(float(tt[1]))))
	lines.append("Its colour: good at 70% or more and steady; watch it under 55% or when slipping; bad under 40% or when falling fast.")
	return "\n".join(lines)


func _gold_tip(n: Dictionary) -> String:
	var lb: Dictionary = sim.state.counters.get("last_budget", {})
	var t := "Treasury: %s Gold. Last quarter %s." % [UITheme.fmt_num(float(n["gold_treasury"])), UITheme.fmt_signed(float(n.get("gold_net", 0)))]
	if not lb.is_empty():
		var parts := ["income %s" % UITheme.fmt_num(float(lb.get("income", 0))), "upkeep −%s" % UITheme.fmt_num(float(lb.get("upkeep", 0)))]
		if float(lb.get("imports", 0)) > 0.5: parts.append("food imports −%s" % UITheme.fmt_num(float(lb["imports"])))
		if float(lb.get("debt", 0)) > 0.5: parts.append("debt service −%s" % UITheme.fmt_num(float(lb["debt"])))
		if float(lb.get("absorption", 0)) > 0.5: parts.append("absorption −%s" % UITheme.fmt_num(float(lb["absorption"])))
		var other := float(lb.get("events", 0)) + float(lb.get("policies", 0)) + float(lb.get("choices", 0))
		if absf(other) > 0.5: parts.append("policies, events and terms %s" % UITheme.fmt_signed(other))
		t += "\n" + ", ".join(parts) + "."
	return t


func ghost_summary() -> Dictionary:
	## Uses the sim's own ahead / level / behind counts (within 1% = level); trend against a year earlier.
	var h: Array = sim.get_history()
	if h.is_empty() or not (h[h.size() - 1] as Dictionary).has("g"):
		return {"text": "no record yet", "ahead": 0, "behind": 0, "even": 6}
	if sim.state.turn < GHOST_FROM_TURN:
		return {"text": "from Q2 1950", "ahead": 0, "behind": 0, "even": 6, "early": true}
	var sc := sim.get_score()
	var na := int(sc.get("ahead", 0)); var nb := int(sc.get("behind", 0)); var ne := int(sc.get("even", 6 - na - nb))
	var prev := ghost_counts(h[maxi(0, h.size() - 5)])
	var score_now := na - nb
	var score_prev := int(prev["ahead"]) - int(prev["behind"])
	var arrow := "  ▲" if score_now > score_prev else ("  ▼" if score_now < score_prev else "")
	var txt := "%d up, %d level, %d down%s" % [na, ne, nb, arrow]
	# v3 fix3-econ: the headline overall is weighed by the state's health; when it is below 1 the chip says so
	return {"text": txt, "ahead": na, "behind": nb, "even": ne, "trend": score_now - score_prev, "summary": str(sc.get("summary", "")),
		"health": float(sc.get("health", 1.0)), "health_text": str(sc.get("health_text", ""))}


func _track_card(kind: String, cur: String, rate: float) -> Dictionary:
	if cur == "":
		return {"name": "Choose a technology" if kind == "tech" else "Choose a civic", "turns": 0, "progress": 0.0, "icon": "research" if kind == "tech" else "civics_columns"}
	var cost: float = sim.tech_cost(cur) if kind == "tech" else sim.civic_cost(cur)
	var prog := float((sim.state.tech_progress if kind == "tech" else sim.state.civic_progress).get(cur, 0.0))
	var nm := item_name(kind, cur)
	return {"name": nm, "turns": int(ceil(maxf(0.0, cost - prog) / maxf(1.0, rate))), "progress": clampf(prog / maxf(1.0, cost), 0, 1),
		"icon": "research" if kind == "tech" else "civics_columns"}


func _city_card() -> Dictionary:
	var c := sim.get_city(hud_city)
	if c.is_empty():
		return {}
	var y: Dictionary = c["yields"]
	var info: Dictionary = c["info"]
	var pr: Dictionary = c.get("producing", {})
	var late := sim.year() >= 2005
	var fs := float(y.get("food", 0)) - 2.0 * int(c["pop"])
	var nat_food := V3Adapter.food(sim)
	var pooled: bool = fs < 0 and float(nat_food["surplus"]) >= 0
	var ftip := "%s grows %s food and its %d population points eat %s: %s." % [str(c["name"]), str(snappedf(float(y.get("food", 0)), 0.1)), int(c["pop"]), str(2 * int(c["pop"])),
		("a surplus of %s, which speeds its growth" % UITheme.fmt_signed(fs, 1)) if fs >= 0 else ("%s short" % str(snappedf(-fs, 0.1)))]
	if pooled:
		ftip += " The national pool covers it (the country has a surplus of %s), so this is not a shortage: a large city lives on the farms of the country. Its growth follows housing, jobs and amenities." % UITheme.fmt_signed(float(nat_food["surplus"]))
	elif fs < 0:
		ftip += " The country is short of food too, so the gap is imported and growth slows."
	return {"name": c["name"], "population": "%d   (%s)" % [int(c["pop"]), _short_res(float(c["residents"]))],
		"production": "%d" % int(round(float(y.get("production", 0)))),
		"food": UITheme.fmt_signed(fs, 1),   # net surplus: the same number as City Details
		"food_label": "Food (fed nationally)" if pooled else "Food surplus", "food_col": UIKit.TEXT_DIM if pooled else (UIKit.BAD if fs < 0 else UIKit.GREEN), "food_tip": ftip,
		"housing": "%d / %s" % [int(c["pop"]), str(snappedf(float(info.get("housing", 0)), 0.5))],   # pop / housing, as Civ VI
		"thumb": "res://assets/ui/thumb_telaviv.png" if late else "res://assets/ui/thumb_city_early.png",
		"building": item_name(pr["kind"], pr["id"]) if not pr.is_empty() else "Nothing - choose",
		"building_turns": int(pr.get("turns", 0)), "building_progress": clampf(float(pr.get("progress", 0)) / maxf(1.0, float(pr.get("cost", 1))), 0, 1),
		"building_thumb": ""}


static func _short_res(v: float) -> String:
	if v >= 1e6:
		return "%.2fM" % (v / 1e6)
	if v >= 1000:
		return "%dk" % int(round(v / 1000.0))
	return str(int(v))


# ================================================================== panels

func open_panel(id: String) -> void:
	if sim == null and not id in ["help", "pedia", "civilopedia", "load", "settings"]:
		return
	if id.begins_with("deal:"):   # capture: --ui-open=deal:<actor>:<deal id> opens that deal's screen
		var dp := id.split(":")
		open_diplomacy(dp[1])
		if dp.size() > 2:
			for dl in diplo_w._actor.get("deals", []):
				if str(dl.get("id", "")) == dp[2]:
					diplo_w.open_deal(dl)
		return
	match id:
		"new_game":   # captures (v4polish): the title screen's New Game panel, "how do you want to play"
			if start_screen == null or not is_instance_valid(start_screen):
				_show_start_screen()
			start_screen._show_menu_now.call_deferred()
			(func(): if not start_screen.setup_panel.visible: start_screen._ask_mode()).call_deferred()
		"pedia", "civilopedia":
			open_pedia()
		"cabinet":
			if is_story():
				# story mode: the budget and the coalition are story cards; appointments are the minister's while on
				# auto (CabinetPanel then shows its short read-only view, v4 fix round A1)
				for d in NextStep.player_decisions(self):
					if str(d["type"]) in ["coalition", "state_budget"]:
						story_open(d)
						return
					if str(d["type"]) in ["minister", "budget_review"]:
						open_cabinet(d)
						return
				cabinet_p.show_view(); _front(cabinet_p)
				return
			for d in sim.get_pending_decisions():
				if str(d["type"]) in ["coalition", "state_budget", "budget_review", "minister"]:
					open_cabinet(d)
					return
			cabinet_p.show_view(); _front(cabinet_p)
		"state_budget", "budget_review", "minister", "coalition":
			for d in sim.get_pending_decisions():
				if str(d["type"]) == id:
					open_cabinet(d)
					return
		"save":
			save_w.open("save"); _front(save_w)
		"load":
			save_w.open("load"); _front(save_w)
		"tree", "tech_tree":
			open_tree("tech")
		"civic_tree":
			open_tree("civic")
		"research", "tech":
			civic_p.visible = false
			research_p.refresh(); research_p.visible = true; _front(research_p)
		"civic", "culture":
			research_p.visible = false
			civic_p.refresh(); civic_p.visible = true; _front(civic_p)
		"policy":
			policy_p.refresh(); policy_p.visible = true; _front(policy_p)
		"end":
			show_end_screen()
		"ghost":
			ghost_p.tab = "tracks"; ghost_p.refresh(); ghost_p.visible = true; _front(ghost_p)
		"ghost_terms":
			open_ghost_tab("terms")
		"ghost_path":
			open_ghost_tab("path")
		"ghost_stats":
			open_ghost_tab("stats")
		"help":
			show_help()
		"city":
			open_city(hud_city, true)
		"cities":
			_show_city_list()
		"log":
			_show_event_log()
		"diplomacy":
			open_diplomacy()
		"diplomacy_list":
			_show_diplomacy()
		"envoy":
			diplo_w.open_envoy(); _front(diplo_w)
		"endings", "outlook":
			open_ghost_tab("endings")
		"programmes":
			open_programmes()
		"fiscal":
			open_fiscal()
		"trade":
			_show_trade()
		"event":
			var pe := sim.get_pending_events()
			if pe.size() > 0:
				open_event(str(pe[0]["event"]))
			else:
				for le in sim.state.event_log:
					if int(le.get("turn", -1)) == sim.state.turn:
						popup.show_info_event(str(le["id"])); _front(popup)
						break
		"digest":
			if _forks_open() > 0:
				show_toast("Take this quarter's decisions first; the headlines follow.")
				next_action()
				return
			var fired := []
			for le in sim.state.event_log:
				if int(le.get("turn", -1)) == sim.state.turn:
					fired.append(str(le["id"]))
			popup.show_digest(sim.date_label(), fired); _front(popup)
		"menu":
			_show_menu()
		"settings":
			open_settings()
		"cabinet_room", "ministers":
			open_cabinet_room()
		"gov_menu":   # captures: the story HUD's Government menu, open
			if gov_menu != null and not gov_menu.visible:
				toggle_gov_menu()
		"cabinet_view":   # captures: the Cabinet as its button shows it (story mode: read-only while on auto)
			cabinet_p.show_view(); _front(cabinet_p)
		"story", "story_card":   # captures: the primary decision on its story card
			var sp := NextStep.primary(self)
			if str(sp.get("type", "")) != "end_turn":
				story_open(sp)
		"report":   # captures: the ministers' report, open
			if report_w != null:
				report_w.opened = true
				report_w.refresh()
		"gameplay":
			open_settings("gameplay")
		"unit":
			for u in sim.get_units("player"):
				if u.get("needs_orders", false):
					select_unit(int(u["id"]), true)
					return
			var us := sim.get_units("player")
			if us.size() > 0:
				select_unit(int(us[0]["id"]), true)
		"settler":
			for u in sim.get_units("player"):
				if u["type"] == "settler":
					select_unit(int(u["id"]), true)
					return
		"builder":
			for u in sim.get_units("player"):
				if u["type"] == "builder":
					select_unit(int(u["id"]), true)
					return
		"city_details", "city_purchase":
			city_s.tab = "details" if id == "city_details" else "purchase"
			open_city(hud_city if hud_city >= 0 else sim.city_by_key(sim.state.capital).id, true)
		"immigration":
			for d in sim.blocking_decisions():
				if d["type"] == "immigration":
					popup.show_immigration(d); _front(popup)
		"agenda", "crisis_response", "dedication":
			for d in sim.blocking_decisions():
				if d["type"] == id:
					popup.show_options(id, d); _front(popup)
		"fork":
			for d in sim.blocking_decisions():
				if d["type"] == "fork":
					popup.show_fork(d); _front(popup)
					break


func open_tree(kind: String) -> void:
	research_p.visible = false
	civic_p.visible = false
	tree_w.show_tree(kind)
	_front(tree_w)


func _front(w: Control) -> void:
	if next_w != null and next_w.auto_running():
		next_w.stop_auto()   # opening a panel stops the auto-advance of a quiet quarter
	if gov_menu != null and w != gov_menu:
		gov_menu.visible = false
	if w is UIWindow and w != story_c:
		_hide_intro()   # (the player acted; the Cabinet Secretary's strip never covers a window)
	if w == story_c and story_block != null and story_block.visible:
		toast.visible = false
		_sync_story_block()   # the dim layer, then the card, then the tutorial's card and the toast
		return
	w.move_to_front()
	if w is UIWindow and (w as UIWindow).centered:
		toast.visible = false   # a toast from the last action must never sit on a new window's title bar
	toast.move_to_front()


func _on_panel_pressed(id: String) -> void:
	UIAudio.click()
	if not started and not id in ["help", "pedia", "settings"]:
		return
	match id:
		"top:gold", "top:economy":   # the Treasury and the debt-and-inflation items: running costs and the levers
			if FiscalPanel.available(sim): open_fiscal()
			else: open_panel("cabinet")
		"top:danger", "top:happy":
			open_ghost_tab("endings")
		"top:readiness":
			open_ghost_tab("stats")
		"top:diplomacy":
			open_diplomacy()
		"top:science": _toggle(research_p, "research")
		"top:culture": _toggle(civic_p, "civic")
		"top:food", "top:cities":
			pass
		"research": _toggle(research_p, "research")
		"civic": _toggle(civic_p, "civic")
		"ghost": _toggle(ghost_p, "ghost")
		"pedia": _toggle(pedia, "pedia")
		"city": open_panel("city")
		_: open_panel(id)


func _toggle(w: UIWindow, id: String) -> void:
	if w.visible:
		w.close()
	else:
		open_panel(id)


func _on_action(id: String) -> void:
	if not started:
		return
	UIAudio.click()
	match id:
		"cities": open_panel("cities")
		"research": _toggle(research_p, "research")
		"culture": _toggle(civic_p, "civic")
		"diplomacy":
			if diplo_w.visible:
				diplo_w.close()
			else:
				open_panel("diplomacy")
		"trade": open_panel("trade")


func open_event(eid: String) -> void:
	for pe in sim.get_pending_events():
		if str(pe["event"]) == eid:
			popup.show_event(pe)
			_front(popup)
			return
	popup.show_info_event(eid)
	_front(popup)


func on_notification(n: Dictionary) -> void:
	match str(n.get("kind", "")):
		"event", "what_happened":
			if n.has("event"):
				open_event(str(n["event"]))
		"tech", "boost":
			if str(n.get("tree", "tech")) == "civic":
				open_panel("civic")
			else:
				open_panel("research")
		"civic", "government":
			open_panel("civic" if n.get("kind") == "civic" else "policy")
		"crisis", "crisis_end", "combat":
			open_panel("unit")
		"stat":
			open_ghost_tab("stats")
		"collapse":
			open_ghost_tab("endings")   # v3 item 13: the collapse warnings live in the Ending outlook
		"fiscal":
			open_fiscal()   # the structural-deficit alarm (fix3-econ): the levers
		"terms":
			open_ghost_tab("terms")
		_:
			if n.has("city"):
				open_city(int(n["city"]), true)


func open_ghost_tab(t: String) -> void:
	ghost_p.tab = t
	ghost_p.refresh()
	ghost_p.visible = true
	_front(ghost_p)


func show_toast(text: String, secs := 3.5) -> void:
	toast.text = text
	toast.visible = true
	toast.move_to_front()
	_toast_t = secs


var _cam_t := 0.0
var _city_pinned := false


func _follow_camera() -> void:
	## The bottom-left city panel shows the open city, else the nearest city to the camera, else hides.
	if sim == null or city_s.visible:
		return
	var t: Vector3 = game.rig.target
	var here := TerrainMath.world_to_offset(Vector2(t.x, t.z))
	var best = null
	var bd := 6
	for c in sim.active_cities():
		var d := SimHex.distance(here, c.pos())
		if d < bd or (d == bd and best != null and c.pop() > best.pop()):
			bd = d; best = c
	var nid: int = best.id if best != null else -1
	if nid != hud_city:
		hud_city = nid
		_refresh_hud()


func _process(delta: float) -> void:
	_intro_tick(delta)
	if _era_banner_t > 0.0:
		_era_banner_t -= delta
		if (_era_banner_t <= 0.0 or not is_story()) and era_banner != null:
			era_banner.visible = false
			_era_banner_t = 0.0
	if _focus_t > 0.0:
		_focus_t -= delta
		if _focus_t <= 0.0 and mv != null:
			mv.clear_highlights("story")
	_cam_t += delta
	if _cam_t > 0.4:
		_cam_t = 0.0
		_follow_camera()
	if place_bar.visible:
		_fit_place_bar()
	_occ_t += delta
	if _occ_t > 0.2:
		_occ_t = 0.0
		_fit_hud_space()   # (also on hud.resized; this catches a resize that came before the first layout)
		_fit_rail()
		_label_occluders()
	if _toast_t > 0:
		_toast_t -= delta
		if _toast_t <= 0:
			toast.visible = false
		else:
			_place_toast()


var _occ_t := 0.0
const RAIL_BOTTOM := -279.0   # the notification rail ends above the minimap (1672x941 layout)


func _fit_rail() -> void:
	## v3 final (fix4-ui, var N6): an advisor card beside the decision button covered the bottom of the notification
	## rail; the rail now ends above the card while it is open. layout-audit: the same for the unit panel (its slot by
	## the minimap grows upwards at a larger UI scale). The rail is in hud_space: rects are taken in its units.
	if rail == null or hud_space == null:
		return
	var want := RAIL_BOTTOM
	var inv := hud_space.get_global_transform().affine_inverse()
	var hs := hud_space.size
	var rx0 := hs.x + rail.offset_left
	var rx1 := hs.x + rail.offset_right
	var r_bot := hs.y + RAIL_BOTTOM
	for c in [tutorial.card if tutorial != null else null, unit_p]:
		if c == null or not (c as Control).is_visible_in_tree():
			continue
		var cr: Rect2 = inv * (c as Control).get_global_rect()
		if cr.position.x < rx1 and cr.end.x > rx0 and cr.position.y < r_bot and cr.end.y > rail.offset_top:
			want = minf(want, maxf(cr.position.y - 8.0, rail.offset_top + 120.0) - hs.y)
	if absf(rail.offset_bottom - want) > 0.5:
		rail.offset_bottom = want


func label_occluders() -> Array:
	## The HUD pieces drawn over the map besides MapLabels' own defaults: the notification cards, the history sidebar,
	## the advisor card and the toast (screen rects).
	var out := []
	if rail != null and rail.is_visible_in_tree():
		for c in rail.get_children():
			if c is Control and (c as Control).is_visible_in_tree() and (c as Control).size.y > 1.0:
				out.append((c as Control).get_global_rect().grow(4))
	for c in [ticker, tutorial.card if tutorial != null else null, toast, cpv, era_banner, gov_menu]:   # (layout-audit: the combat preview, the era banner and the Government menu too)
		if c != null and (c as Control).is_visible_in_tree():
			out.append((c as Control).get_global_rect().grow(4))
	if sats != null and sats.is_visible_in_tree():
		for b in sats.get_children():
			if b is Control and (b as Control).is_visible_in_tree():
				out.append((b as Control).get_global_rect().grow(4))
	if is_story():   # v4: the story HUD's own pieces
		for c2 in [story_left, story_bar, intro_w, next_w.card, next_w.chips, next_w.auto_bar]:
			if c2 != null and (c2 as Control).is_visible_in_tree() and (c2 as Control).size.y > 1.0:
				out.append((c2 as Control).get_global_rect().grow(4))
	return out


func _label_occluders() -> void:
	## v3 final (fix4-ui, var N6): a world label ("NEGBA") was drawn half under the notification rail and the advisor
	## card; MapLabels skips labels under these rects as it does under its default HUD rects.
	var ov = game.get("overlay") if game != null else null
	if ov == null or not (ov is MapLabels):
		return
	# layout-audit: and under every part the HUD draws now, at its scale (MapLabels' defaults are Full control's HUD and
	# miss VS. HISTORY and its health strip; story mode draws its cards on the right)
	var hud_rs := []
	if hud != null:
		var k: float = hud._ref_scale()
		for r in hud._regions():
			if (r as Rect2).size.x > 0.0 and (r as Rect2).size.y > 0.0:
				hud_rs.append(Rect2((r as Rect2).position * k, (r as Rect2).size * k).grow(4))
	(ov as MapLabels).occluders = []
	var base: Array = [] if is_story() else (ov as MapLabels)._occ()
	(ov as MapLabels).occluders = base + hud_rs + label_occluders()


func _fit_place_bar() -> void:
	## The district banner spans the gap between the research / civic cards (left column) and the city screen.
	var vp := root.get_viewport_rect().size
	var k: float = hud._ref_scale()   # (the cards' right edge and the top bar at the HUD's scale)
	var left := 318.0 * k
	var right := vp.x - 8.0
	if city_s.visible:
		right = city_s.get_global_rect().position.x - 8.0
	var w := maxf(420.0, right - left)
	place_text.custom_minimum_size.x = maxf(260.0, w - 190.0)
	place_bar.position = Vector2(left, 58.0 * k)
	place_bar.size = Vector2(w, place_bar.get_combined_minimum_size().y)


func _place_toast() -> void:
	## Toasts sit under the top bar, between the side panels; if that would cover an open window's title (or the
	## district banner), they drop to the bottom centre above the action bar, then to the clearest free spot.
	var vp := root.get_viewport_rect().size
	var k: float = hud._ref_scale()   # (under the top bar and above the action bar at the HUD's scale)
	var w := 660.0
	var h := maxf(toast.get_combined_minimum_size().y, 36.0)
	var cands := [Vector2((vp.x - w) * 0.5, 58.0 * k), Vector2((vp.x - w) * 0.5, vp.y - 190.0 * k - h), Vector2((vp.x - w) * 0.5, vp.y * 0.5 - h * 0.5)]
	var blocks := []
	for c in root.get_children():
		if c is UIWindow and (c as Control).visible:
			var r := (c as Control).get_global_rect()
			blocks.append(Rect2(r.position, Vector2(r.size.x, minf(r.size.y, 64.0))))   # the title bar
		elif c == place_bar and place_bar.visible:
			blocks.append(place_bar.get_global_rect())
	for c2 in [era_banner, intro_w]:   # (layout-audit: story mode's era banner sits at the top centre too)
		if c2 != null and (c2 as Control).is_visible_in_tree():
			blocks.append((c2 as Control).get_global_rect())
	var pick: Vector2 = cands[0]
	for p in cands:
		var tr := Rect2(p, Vector2(w, h))
		if not blocks.any(func(b): return (b as Rect2).intersects(tr)):
			pick = p
			break
	toast.position = pick
	toast.size = Vector2(w, h)


# ------------------------------------------------------------------ small list panels (info_p)

func _info(title: String) -> VBoxContainer:
	info_p.clear_body()
	info_p.title_label.text = title.to_upper()
	info_p.visible = true
	_front(info_p)
	return info_p.scroll_body(440)


func _show_city_list() -> void:
	var list := _info("Cities")
	var cs := sim.get_cities()
	cs.sort_custom(func(a, b): return int(a["pop"]) > int(b["pop"]))
	list.add_child(UITheme.label("%d localities. Click one to open it." % cs.size(), 15, UIKit.TEXT_DIM))
	for c in cs:
		var r := UIRow.new(true)
		var h := r.hrow()
		var nm := UITheme.label("%s%s" % [c["name"], "  (capital)" if c["capital"] else ""], 18, UIKit.GOLD_LIGHT, "body_bold")
		nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(nm)
		h.add_child(UITheme.label("pop %d" % int(c["pop"]), 16))
		var cc = sim.city_by_id(int(c["id"]))
		var prod := str(c["producing"])
		var q: Array = cc.queue if cc else []
		h.add_child(UITheme.label((item_name(q[0]["kind"], prod) if prod != "" and q.size() > 0 else "-") + (" (auto)" if cc and cc.automate else ""), 15, UIKit.TEXT_DIM))
		var cid := int(c["id"])
		r.pressed.connect(func(_s): info_p.visible = false; open_city(cid, true))
		list.add_child(r)


func _show_event_log() -> void:
	var list := _info("Event log")
	if _notes.size() > 0:
		list.add_child(UITheme.section("This turn"))
		for n in _notes:
			var nl := UITheme.label(str(n.get("text", "")), 15, UIKit.TEXT)
			nl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			list.add_child(nl)
		list.add_child(UITheme.section("Dated events"))
	var log := sim.get_event_log(60)
	log.reverse()
	for le in log:
		var r := UIRow.new(true)
		r.add(UITheme.label("%s  -  %s" % [SimDB.date_label(int(le["turn"])), str(le.get("title", ""))], 17, UIKit.TEXT))
		var eid := str(le["id"])
		r.pressed.connect(func(_s): info_p.visible = false; open_event(eid))
		list.add_child(r)


func _show_diplomacy() -> void:
	var list := _info("Diplomacy")
	var n := sim.get_national_summary()
	list.add_child(UITheme.label("Standing %d   Readiness %d   War weariness %d" % [int(n["standing"]), int(n["readiness"]), int(n["war_weariness"])], 16, UIKit.GOLD))
	for d in sim.get_diplomacy():
		var r := UIRow.new(true)
		var h := r.hrow()
		var nm := UITheme.label(str(d["name"]), 18, UIKit.GOLD_LIGHT, "body_bold")
		nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(nm)
		h.add_child(UITheme.label("%s (since %s)" % [UITheme.pretty(str(d["status"])), str(d["since"])], 15))
		h.add_child(UITheme.label("relation %d" % int(float(d["relation"])), 15, UIKit.TEXT_DIM))
		var aid := str(d["id"])
		var b := UITheme.button("Delegation", _delegation.bind(aid), 14)
		b.disabled = not d.get("delegation_ready", false) or str(d["status"]) == "war"
		h.add_child(b)
		list.add_child(r)


func _delegation(aid: String) -> void:
	if sim.send_delegation(aid):
		show_toast("Delegation sent.")
		_show_diplomacy()
		_refresh_hud()
	else:
		show_toast("Not possible now (cost, cooldown or war).")


func _open_route(cid: int, pid: String) -> void:
	if sim.start_trade_route(cid, pid):
		show_toast("Export route opened.")
		_show_trade()
		_refresh_hud()
	else:
		show_toast("Not possible (capacity or an existing route).")


func _show_trade() -> void:
	var list := _info("Export routes")
	list.add_child(UITheme.label("Routes %d / %d. Each route lasts 14 turns and earns Gold." % [sim.state.trade_routes.size(), sim.trade_capacity()], 16, UIKit.GOLD))
	for tr in sim.state.trade_routes:
		list.add_child(UITheme.label("%s -> %s (%s left)" % [_city_name(int(tr["from"])), _actor(str(tr["partner"])), UITheme.turns(int(tr["turns"]))], 16))
	var cap = sim.city_by_key(sim.state.capital)
	for p in sim.trade_partners():
		var pid := str(p)
		var b := UITheme.button("Open a route from %s to %s" % [cap.name if cap else "?", _actor(pid)], _open_route.bind(cap.id if cap else -1, pid), 15)
		b.disabled = sim.state.trade_routes.size() >= sim.trade_capacity()
		list.add_child(b)


func _show_menu() -> void:
	var list := _info("Game menu")
	if is_story():
		# v4polish (new-player menu: 12+ entries that scroll): story mode keeps six; the government's screens are in the
		# Government menu, the play style and the rest in Settings, and Quit offers the title screen or a new game
		var sb := UITheme.button("Save game... (Ctrl+S)", func(): info_p.visible = false; open_panel("save"))
		sb.name = "menu_save"
		sb.tooltip_text = "F5 quick-saves, F9 quick-loads."
		list.add_child(sb)
		var lb := UITheme.button("Load game... (Ctrl+L)", func(): info_p.visible = false; open_panel("load"))
		lb.name = "menu_load"
		list.add_child(lb)
		var st := UITheme.button("Settings (%s)" % GameSettings.binding_text("settings"), func(): open_settings())
		st.name = "menu_settings"
		st.tooltip_text = "Display, sound, controls, and Gameplay: the play style, your ministers, era goals and quiet quarters."
		list.add_child(st)
		var hp := UITheme.button("How to play (F1)", func(): info_p.visible = false; show_help())
		hp.name = "menu_help"
		list.add_child(hp)
		var pb := UITheme.button("Civilopedia", func(): info_p.visible = false; open_pedia())
		pb.name = "menu_pedia"
		list.add_child(pb)
		var qb := UITheme.button("Quit", func(): _show_quit_menu())
		qb.name = "menu_quit"
		list.add_child(qb)
		var dn0 := V3Adapter.difficulty_name(sim)
		if dn0 != "":
			list.add_child(UITheme.label("Difficulty: %s" % dn0, 15, UIKit.TEXT_DIM))
		_fit_info(list)
		return
	list.add_child(UITheme.button("Save game... (Ctrl+S)", func(): info_p.visible = false; open_panel("save")))
	list.add_child(UITheme.button("Load game... (Ctrl+L)", func(): info_p.visible = false; open_panel("load")))
	list.add_child(UITheme.button("Quick-save (F5)", quick_save))
	list.add_child(UITheme.button("Quick-load (F9)", func(): quick_load()))
	list.add_child(UITheme.button("Civilopedia", func(): info_p.visible = false; open_pedia()))
	list.add_child(UITheme.button("Policies and government (P)", func(): open_panel("policy")))
	list.add_child(UITheme.button("Cabinet and State Budget (K)", func(): info_p.visible = false; open_panel("cabinet")))
	list.add_child(UITheme.button("Ghost of history (%s)" % GameSettings.binding_text("ghost"), func(): open_panel("ghost")))
	list.add_child(UITheme.button("Ending outlook (%s)" % GameSettings.binding_text("endings"), func(): info_p.visible = false; open_ghost_tab("endings")))
	list.add_child(UITheme.button("Diplomacy (%s)" % GameSettings.binding_text("diplomacy"), func(): open_diplomacy()))
	if sim.has_method("get_programmes"):
		list.add_child(UITheme.button("National programmes", func(): info_p.visible = false; open_programmes()))
	if FiscalPanel.available(sim):
		list.add_child(UITheme.button("Treasury: running costs and fiscal levers", func(): info_p.visible = false; open_fiscal()))
	list.add_child(UITheme.button("Ongoing terms of your choices", func(): info_p.visible = false; open_ghost_tab("terms")))
	list.add_child(UITheme.button("Why Standing, Civic Trust and Readiness moved", func(): info_p.visible = false; open_ghost_tab("stats")))
	list.add_child(UITheme.button("Event log (L)", func(): open_panel("log")))
	list.add_child(UITheme.button("This quarter in history", func(): info_p.visible = false; open_panel("digest")))
	list.add_child(UITheme.button("How to play (F1)", func(): info_p.visible = false; show_help()))
	list.add_child(UITheme.button("Era goals", func(): _show_goals_list()))
	list.add_child(UITheme.button("Play style: Story or Full control", func(): info_p.visible = false; open_settings("gameplay")))
	list.add_child(UITheme.button("Credits", func(): show_credits()))
	list.add_child(UITheme.button("Settings (%s)" % GameSettings.binding_text("settings"), func(): open_settings()))
	var dn := V3Adapter.difficulty_name(sim)
	if dn != "":
		list.add_child(UITheme.label("Difficulty: %s" % dn, 16, UIKit.TEXT_DIM))
	list.add_child(UITheme.button("New game", func(): info_p.visible = false; loading.run(func(): return_to_start(true))))
	list.add_child(UITheme.button("Return to the title screen", func(): info_p.visible = false; loading.run(func(): return_to_start())))
	list.add_child(UITheme.button("Quit", func(): get_tree().quit()))


func _show_quit_menu() -> void:
	## Story mode's Quit: leave to the title screen, start again, or quit the game.
	var list := _info("Quit")
	list.add_child(UITheme.label("Unsaved progress since the last autosave is lost.", 15, UIKit.TEXT_DIM))
	list.add_child(UITheme.button("Return to the title screen", func(): info_p.visible = false; loading.run(func(): return_to_start())))
	list.add_child(UITheme.button("New game", func(): info_p.visible = false; loading.run(func(): return_to_start(true))))
	list.add_child(UITheme.button("Quit to desktop", func(): get_tree().quit()))
	list.add_child(UITheme.button("Back", func(): _show_menu()))
	_fit_info(list)


func _fit_info(list: VBoxContainer) -> void:
	## A short list in the Info window: its scroll area is only as tall as the list (no empty half-window).
	var sc := list.get_parent() as Control
	if sc != null:
		sc.custom_minimum_size = Vector2(0, list.get_combined_minimum_size().y + 4.0)


# ================================================================== actions used by panels

func choose_research(kind: String, id: String) -> void:
	player_actions += 1
	var ok := sim.set_research(id) if kind == "tech" else sim.set_civic(id)
	if not ok:
		show_toast("Cannot choose that now.")
		return
	(research_p if kind == "tech" else civic_p).visible = false
	_refresh_hud()


func choose_production(city_id: int, kind: String, id: String, queue := false, tile := -1) -> void:
	player_actions += 1
	var c = sim.city_by_id(city_id)
	var was_empty: bool = c != null and c.queue.is_empty()
	var ok := sim.enqueue(city_id, kind, id, tile) if queue else sim.set_production(city_id, kind, id, tile)
	if not ok:
		show_toast("Cannot build that here.")
	hud_city = city_id
	if ok and was_empty and not queue and sim.blocking_decisions().any(func(d): return d["type"] == "choose_production"):
		# like Civ VI: after a forced choice, go straight to the next city that needs one
		var nxt := sim.next_action()
		if str(nxt["type"]) == "choose_production":
			open_city(int(nxt["city"]), true)
			_refresh_hud()
			return
	city_s.refresh()
	_refresh_hud()


func purchase(city_id: int, kind: String, id: String) -> void:
	player_actions += 1
	if sim.purchase(city_id, kind, id, "gold"):
		show_toast("Purchased %s." % item_name(kind, id))
		_sync_units()
	else:
		show_toast("Cannot purchase that.")
	city_s.refresh()
	_refresh_hud()


func clear_queue(city_id: int) -> void:
	var c = sim.city_by_id(city_id)
	if c and c.queue.size() > 1:
		c.queue.resize(1)   # keep the current item (sim.clear_queue would drop it too)
	city_s.refresh()


func set_focus(city_id: int, f: String) -> void:
	sim.set_city_focus(city_id, f)
	city_s.refresh()
	_refresh_hud()


func set_automate(city_id: int, on: bool) -> void:
	var c = sim.city_by_id(city_id)
	if c == null:
		return
	if on:
		_automate(c)
	else:
		sim.set_city_automated(city_id, false)
	city_s.refresh()
	_refresh_hud()


func set_policy(slot: int, pid: String) -> void:
	player_actions += 1
	if not sim.set_policy(slot, pid):
		show_toast("Cannot slot that card (cost %d Gold)." % sim.policy_swap_cost())
	policy_p.refresh()
	_refresh_hud()


func choose_event(eid: String, idx: int) -> void:
	player_actions += 1
	var title := ""
	for pe in sim.get_pending_events():
		if str(pe["event"]) == eid:
			title = str(pe["title"])
	var before := sim.state.notifications.size()
	if not sim.choose_event(eid, idx):
		show_toast("That choice is not available.")
		return
	var text := ""
	var applied := {}
	for i in range(before, sim.state.notifications.size()):
		var n: Dictionary = sim.state.notifications[i]
		if n.get("kind") == "what_happened":
			text = str(n.get("text", ""))
			applied = n.get("applied", {})
			var hist := int(n.get("historical", -1))
			text = ("[color=#9fe07a]You made the historical choice.[/color]\n" if hist == idx else "[color=#ffb070]You chose differently from history.[/color]\n") + text
	for i in range(before, sim.state.notifications.size()):
		var n2: Dictionary = sim.state.notifications[i]
		if n2.get("kind") == "terms":
			text += "\n\n[color=#e6c76e]%s[/color]" % str(n2.get("text", ""))
	popup.show_result(title, text, applied)
	_refresh_all()


func choose_fork(fid: String, oid: String) -> void:
	player_actions += 1
	var d := {}
	for x in sim.blocking_decisions():
		if str(x["type"]) == "fork" and str(x.get("fork", "")) == fid:
			d = x
	if d.is_empty() and sim.has_method("get_fork"):
		d = sim.get_fork(fid)
	var held: bool = sim.events.has_method("events_held") and sim.events.events_held()
	var log_before := sim.state.event_log.size()
	if not sim.choose_fork(fid, oid):
		show_toast("That option is not available.")
		return
	popup.show_fork_result(d, oid)
	_front(popup)
	UIAudio.sting("fork")
	_refresh_all()
	if held:
		# the quarter's events waited for this decision: show them now, after the result
		var fired := []
		for i in range(log_before, sim.state.event_log.size()):
			fired.append(str(sim.state.event_log[i]["id"]))
		_queue_turn_items(fired)


func confirm_policies() -> void:
	player_actions += 1
	## Closes the election/government-change policy review (sim round 5: blocking policy_review).
	if sim.has_method("confirm_policies"):
		sim.confirm_policies()
	policy_p.close()
	_refresh_all()


func open_cabinet(d: Dictionary) -> void:
	cabinet_p.show_decision(d)
	_front(cabinet_p)


func choose_cabinet(t: String, i: int) -> void:
	player_actions += 1
	## v2 cabinet decisions: state_budget (a preset), budget_review, minister (spend a title), coalition.
	var ok := false
	match t:
		"state_budget": ok = sim.choose_state_budget(i)
		"budget_review": ok = sim.choose_budget_review(i)
		"minister": ok = sim.choose_minister(i)
		"coalition": ok = sim.choose_coalition(i)
	if not ok:
		show_toast("That option is not available.")
		return
	_after_cabinet(t)


func choose_ministers(ids: Array) -> void:
	player_actions += 1
	## v2 cabinet multi-pick: every title in one go (sim.choose_ministers); the screen is then done for the quarter.
	if ids.is_empty():
		show_toast("Choose at least one appointment or programme.")
		return
	var ok: bool = sim.choose_ministers(ids) if sim.has_method("choose_ministers") else sim.choose_minister(0)
	if not ok:
		show_toast("Those picks are not available.")
		return
	show_toast("Cabinet: %d title%s spent." % [ids.size(), "" if ids.size() == 1 else "s"], 2.5)
	cabinet_p.close()
	_refresh_all()


func pass_custom_budget(shares: Dictionary) -> void:
	player_actions += 1
	if sim.set_budget_shares(shares):
		show_toast("Budget passed: " + ", ".join(shares.keys().map(func(k): return "%s %d%%" % [str(k).capitalize(), int(round(float(shares[k]) * 100.0))])), 3.0)
		_after_cabinet("state_budget")
	else:
		show_toast("The shares must add up to 100% (10-55% each).")


func move_minister(mid: String, city_id: int) -> void:
	if sim.appoint_minister(mid, city_id):
		show_toast("Minister moved to %s (two quarters to settle in)." % _city_name(city_id), 2.5)
	cabinet_p.refresh()
	_refresh_hud()


func _after_cabinet(t: String) -> void:
	# another title or decision of the same kind may follow (several titles): show it at once
	for d in sim.get_pending_decisions():
		if str(d["type"]) == t and (bool(d.get("blocking", false)) or t == "minister"):
			cabinet_p.show_decision(d)
			_refresh_all()
			return
	cabinet_p.close()
	_refresh_all()


func choose_policy_proposal(i: int) -> void:
	player_actions += 1
	if sim.choose_policy_proposal(i):
		policy_p.close()
		_refresh_all()
	else:
		show_toast("That programme cannot be adopted now.")


func policy_review_pending() -> bool:
	return sim != null and sim.blocking_decisions().any(func(d): return str(d["type"]) == "policy_review")


func propose_deal(actor: String, deal: Dictionary, variant := "") -> void:
	player_actions += 1
	## variant "counter": the deal on its sourced counter-terms (fix3-story A6)
	var r := V3Adapter.propose(sim, actor, deal, variant)
	if bool(r.get("ok", false)):
		UIAudio.sfx("notification")
		diplo_w.show_result(str(deal.get("title", "Deal")), "[color=#9fe07a]%s[/color]" % UITheme.humanise(str(r.get("text", "Agreed."))))
	else:
		show_toast(str(r.get("text", "Not possible now.")))
		diplo_w.refresh()
	_refresh_hud()


func choose_diplomacy(i: int) -> void:
	player_actions += 1
	var d := V3Adapter.diplo_decision(sim)
	if d.is_empty():
		return
	var before := sim.state.notifications.size()
	if not V3Adapter.choose_diplo(sim, d, i):
		show_toast("That answer is not available.")
		return
	var opts: Array = d.get("options", [])
	var o: Dictionary = opts[i] if i < opts.size() else {}
	var hist := bool(o.get("historical", false))
	var txt := ("[color=#9fe07a]You answered as Israel did.[/color]" if hist else "[color=#ffb070]You answered differently from history.[/color]")
	for k in range(before, sim.state.notifications.size()):
		var n: Dictionary = sim.state.notifications[k]
		if str(n.get("kind", "")) in ["what_happened", "terms", "diplomacy"]:
			txt += "\n\n" + UITheme.humanise(str(n.get("text", "")))
	var fx := []
	for e in o.get("effects", []):
		var s1 := V3Adapter._fx_one(e)
		if s1 != "":
			fx.append(s1)
	if fx.size() > 0:
		txt += "\n\n[b]Your answer:[/b] " + ", ".join(fx)
	_sting("fork")
	_flush_audio(false)
	diplo_w.show_result(str(d.get("title", "Envoy")), txt)
	_front(diplo_w)
	_refresh_all()


func choose_programme_option(i: int) -> void:
	player_actions += 1
	if sim.has_method("choose_programme") and sim.choose_programme(i):
		prog_w.after_choice()
		_refresh_all()
	else:
		show_toast("That option is not available (cost or timing).")


func fund_programme(pid: String, expand := false) -> void:
	player_actions += 1
	var ok: bool = sim.expand_programme(pid) if expand else sim.fund_programme(pid)
	if ok:
		show_toast("Programme under way: paid in quarterly instalments.", 2.5)
		UIAudio.sfx("build_complete")
	else:
		show_toast("Not possible now (cost, timing or a programme already under way).")
	prog_w.refresh()
	_refresh_hud()


func choose_immigration(id: String) -> void:
	player_actions += 1
	if sim.choose_immigration(id):
		popup.close()
		_refresh_all()
	else:
		show_toast("That option is not available.")


func choose_crisis(i: int) -> void:
	player_actions += 1
	if sim.choose_crisis_response(i):
		popup.close()
		_sync_units()
		_refresh_hud()
	else:
		show_toast("Not available.")


func choose_dedication(id: String) -> void:
	player_actions += 1
	sim.choose_dedication(id)
	popup.close()
	_refresh_hud()


func choose_agenda(i: int) -> void:
	player_actions += 1
	sim.choose_agenda(i)
	popup.close()
	_refresh_all()


# ================================================================== city screen

func open_city(city_id: int, focus := false) -> void:
	var c = sim.city_by_id(city_id)
	if c == null:
		return
	select_unit(-1)
	research_p.visible = false; civic_p.visible = false
	hud_city = city_id
	city_s.open_city(city_id)
	_front(city_s)
	var d := sim.get_city(city_id)
	mv.highlight_tiles(d.get("tiles", []), Color(0.95, 0.85, 0.45, 0.25), "city")
	_show_city_tiles()
	if focus:
		mv.focus_tile(c.q, c.r, maxf(game.rig.zoom, 1.6))
	_refresh_hud()


# ================================================================== map input

func _on_tile_clicked(q: int, r: int) -> void:
	if not started:
		return
	if next_w != null:
		next_w.stop_auto()   # a click on the map stops the auto-advance
	if is_story() and placing.is_empty() and not city_s.visible and _story_tile_click(q, r):
		return
	var p := Vector2i(q, r)
	if not placing.is_empty():
		place_district_at(q, r)   # district lens: click a tile to place, Esc cancels
		return
	if city_s.visible and city_s.tab == "citizens" and selected_unit < 0:
		var cd := sim.get_city(city_s.city_id)
		for t in cd.get("tiles", []):
			if int(t[0]) == q and int(t[1]) == r and not (q == int(cd.get("q", -1)) and r == int(cd.get("r", -1))):
				toggle_citizen(city_s.city_id, q, r)   # Civ VI citizen management: click a tile to lock / unlock
				return
	var bc = _banner_city_at_mouse()
	if bc != null and not (selected_unit >= 0 and _targets.has(p)):
		open_city(bc.id)
		return
	if selected_unit >= 0 and _targets.has(p):
		var u = sim.unit_by_id(selected_unit)
		if u != null and u.pos() != p:
			_order_unit(p)
			return
	var mine := sim.get_units("player").filter(func(u): return int(u["q"]) == q and int(u["r"]) == r)
	if mine.size() > 0:
		var idx := 0
		for i in mine.size():
			if int(mine[i]["id"]) == selected_unit:
				idx = (i + 1) % mine.size()
		select_unit(int(mine[idx]["id"]))
		return
	var c = sim.city_at(p)
	if c != null and c.active:
		open_city(c.id)
		return
	select_unit(-1)


func _on_tile_right_clicked(q: int, r: int) -> void:
	if started and selected_unit >= 0:
		_order_unit(Vector2i(q, r))


func _banner_city_at_mouse():
	var ov = game.get("overlay")
	var ren = game.get("renderer")
	if ov == null or ren == null or not ov.has_method("_banner_rect"):
		return null
	var mp: Vector2 = root.get_viewport().get_mouse_position()
	var cam: Camera3D = game.rig.cam
	var s: float = ov._ui_scale() if ov.has_method("_ui_scale") else 1.0
	for a in ren.city_anchors:
		var city: Dictionary = a["city"]
		var c = sim.city_by_key(str(city.get("id", "")))
		if c == null or not c.active:
			continue
		var p: Vector3 = a["pos"] + Vector3(0, 0.42 + 0.14 * int(city.get("size", 0)), 0)
		if cam.is_position_behind(p):
			continue
		var d := cam.global_position.distance_to(p)
		var k := clampf(12.0 / d, 0.55, 1.0) * s
		var rect: Rect2 = ov._banner_rect(cam.unproject_position(p), k, city)
		if rect.has_point(mp):
			return c
	return null


# ================================================================== units

func _reset_units() -> void:
	for id in _shown_units.keys():
		mv.remove_unit(id)
	_shown_units.clear()
	_sync_units()


func _sync_units() -> void:
	if sim == null:
		return
	unit_cache = sim.get_units("")
	var seen := {}
	for u in unit_cache:
		var id := str(u["id"])
		var p := Vector2i(int(u["q"]), int(u["r"]))
		seen[id] = true
		if not _shown_units.has(id):
			var hostile := str(u["owner"]) != "player"
			mv.show_unit(id, p.x, p.y, _model_for(u), 180.0 if hostile else 0.0,
				Color(1.0, 0.72, 0.68) if hostile else Color.WHITE, Color(0.85, 0.15, 0.12, 0.85) if hostile else Color(0.20, 0.45, 0.95, 0.7))
		elif _shown_units[id] != p:
			mv.move_unit(id, p.x, p.y)
		_shown_units[id] = p
	for id in _shown_units.keys():
		if not seen.has(id):
			mv.remove_unit(id)
			_shown_units.erase(id)


func _model_for(u: Dictionary) -> String:
	return UNIT_MODELS.get(str(u["type"]), "unit_palmach_infantry")


func select_unit(id: int, focus := false) -> void:
	selected_unit = id
	if cpv:
		cpv.visible = false
	for l in ["move", "settle", "build", "attack"]:
		mv.clear_highlights(l)
	_targets.clear()
	_build_opts.clear()
	if id < 0 or sim == null:
		unit_p.visible = false
		return
	var uv := {}
	for u in sim.get_units("player"):
		if int(u["id"]) == id:
			uv = u
	if uv.is_empty():
		selected_unit = -1
		unit_p.visible = false
		return
	city_s.visible = false
	mv.clear_highlights("city"); mv.clear_highlights("worked")
	_compute_targets(uv)
	var by := {"move": [], "settle": [], "build": [], "attack": []}
	for p in _targets:
		by[_targets[p]].append(p)
	if str(uv["cls"]) != "civilian":   # civilians move 8: show only their goals (gold / green), any tile still works
		mv.highlight_tiles(by["move"], Color(0.35, 0.70, 1.0, 0.35), "move")
	mv.highlight_tiles(by["settle"], Color(1.0, 0.82, 0.30, 0.75), "settle")
	mv.highlight_tiles(by["build"], Color(UIKit.GREEN.lightened(0.2), 0.6), "build")
	mv.highlight_tiles(by["attack"], Color(1.0, 0.30, 0.25, 0.7) if not UITheme.colourblind else Color(UIKit.BAD, 0.75), "attack")
	unit_p.show_unit(uv)
	_front(unit_p)
	if focus:
		mv.focus_tile(int(uv["q"]), int(uv["r"]), maxf(game.rig.zoom, 1.4))


func _compute_targets(u: Dictionary) -> void:
	var pos := Vector2i(int(u["q"]), int(u["r"]))
	var cls := str(u["cls"])
	var mp := float(u["moves"])
	var radius := int(ceil(mp))
	if mp > 0 and cls != "air":
		for p in SimHex.within(pos.x, pos.y, radius):
			if p == pos:
				continue
			if sim.military.passable(cls, SimHex.key(p.x, p.y)):
				_targets[p] = "move"
	if str(u["type"]) == "settler":
		for t in sim.get_settle_targets():
			_targets[Vector2i(int(t["q"]), int(t["r"]))] = "settle"
	elif str(u["type"]) == "builder" and int(u["charges"]) > 0:
		for p in SimHex.within(pos.x, pos.y, maxi(radius, 1)):
			var opts := _improvements_at(p)
			if opts.size() > 0:
				_build_opts[p] = opts
				_targets[p] = "build"
	if cls != "civilian" and mp > 0:
		var rng := maxi(1, int(u.get("range", 0)))
		for h in sim.get_units(""):
			if str(h["owner"]) != "player":
				var hp := Vector2i(int(h["q"]), int(h["r"]))
				if SimHex.distance(pos, hp) <= rng:
					_targets[hp] = "attack"


func _improvements_at(p: Vector2i) -> Array:
	var k := SimHex.key(p.x, p.y)
	var ts: Dictionary = sim.econ.tstate(k)
	var city = sim.city_by_id(int(ts.get("o", 0)))
	if city == null:
		return []
	var out := []
	for imp in db().improvements:
		if sim.military.improvement_ok(str(imp), k, city) == "":
			out.append(str(imp))
	return out


func _order_unit(p: Vector2i) -> void:
	player_actions += 1
	var u = sim.unit_by_id(selected_unit)
	if u == null:
		return
	var kind := str(_targets.get(p, "move"))
	var res: Dictionary
	if kind == "attack":
		cpv.visible = false
		res = sim.unit_action(u.id, "attack", {"q": p.x, "r": p.y})
	else:
		res = sim.unit_action(u.id, "move", {"q": p.x, "r": p.y})
	if not res.get("ok", false):
		show_toast("Cannot go there%s." % ((": " + str(res["reason"])) if res.has("reason") else ""))
	_sync_units()
	var still = sim.unit_by_id(selected_unit)
	if still == null:
		select_unit(-1)
	else:
		select_unit(selected_unit)
	_refresh_hud()
	_split_notes()


func unit_hint(u: Dictionary) -> String:
	match str(u["type"]):
		"settler":
			var t = sim.snap_settle_target(Vector2i(int(u["q"]), int(u["r"])), 3)
			var n := sim.get_settle_targets().size()
			if t != null:
				return "Ready to found [b]%s[/b] (historically founded %s)." % [t["name"], t["historical_date"]]
			return "[color=#f7dc8f]Gold tiles[/color]: %d real localities open for founding. Move next to one and press Found Town." % n if n > 0 else "No locality is open for founding yet (localities open 6 years before their real date)."
		"builder":
			var opts := _improvements_at(Vector2i(int(u["q"]), int(u["r"])))
			if opts.size() > 0:
				return "This tile can take: " + ", ".join(opts.map(func(i): return item_name("improvement", i)))
			return "[color=#9fe07a]Green tiles[/color]: tiles your cities own that can be improved. Move there, then build."
	if sim.state.crises.size() > 0 and str(u["cls"]) != "civilian":
		return "A crisis is active. Fortify, or move toward the front ([color=#ff8f7a]red[/color] = enemy in reach)."
	return ""


func unit_actions(u: Dictionary) -> Array:
	var out := []
	var id := int(u["id"])
	var pos := Vector2i(int(u["q"]), int(u["r"]))
	match str(u["type"]):
		"settler":
			var t = sim.snap_settle_target(pos, 3)
			out.append({"label": "Found %s (B)" % (t["name"] if t != null else "Town"), "cb": func(): unit_do("found"), "enabled": t != null,
				"tip": "Found the nearest real locality within 3 tiles."})
		"builder":
			for imp in _improvements_at(pos):
				var ii: String = imp
				out.append({"label": "Build " + item_name("improvement", ii), "cb": func(): unit_do("build", ii), "enabled": float(u["moves"]) > 0})
	if str(u["type"]) in ["builder", "settler"]:
		out.append({"label": "Automate", "cb": func(): set_auto_unit(id, true), "enabled": true,
			"tip": "Let this unit work on its own every turn (the autoplayer's choices). Select it and press Stop to take it back."} if not auto_units.has(id) else
			{"label": "Stop automation", "cb": func(): set_auto_unit(id, false), "enabled": true})
	if str(u["cls"]) != "civilian":
		out.append({"label": "Fortify (F)", "cb": func(): unit_do("fortify"), "enabled": true})
		var idle := sim.get_units("player").filter(func(x): return x.get("needs_orders", false) and str(x["cls"]) != "civilian")
		if idle.size() > 1:
			out.append({"label": "Fortify all %d" % idle.size(), "cb": func(): fortify_all(), "enabled": true, "tip": "Fortify every military unit that is waiting for orders."})
	out.append({"label": "Skip (Space)", "cb": func(): unit_do("skip"), "enabled": true})
	out.append({"label": "Sleep", "cb": func(): unit_do("sleep"), "enabled": true})
	out.append({"label": "Next unit (.)", "cb": func(): next_unit(), "enabled": true})
	return out


func set_auto_unit(id: int, on: bool) -> void:
	if on:
		auto_units[id] = true
		var u = sim.unit_by_id(id)
		if u != null:
			if u.type == "builder": SimAI._builder(sim, u)
			elif u.type == "settler": SimAI._settler(sim, u)
		show_toast("Unit automated.")
		_sync_units()
		_refresh_all()
		next_unit(true)
	else:
		auto_units.erase(id)
		var u2 = sim.unit_by_id(id)
		if u2 != null:
			u2.orders = ""
		select_unit(id)
		_refresh_hud()


func fortify_all() -> void:
	for x in sim.get_units("player"):
		if x.get("needs_orders", false) and str(x["cls"]) != "civilian":
			sim.unit_action(int(x["id"]), "fortify")
	_sync_units()
	_refresh_hud()
	next_unit(true)


func unit_do(action: String, arg := "") -> void:
	player_actions += 1
	if selected_unit < 0:
		return
	var id := selected_unit
	var res: Dictionary
	match action:
		"found":
			res = sim.unit_action(id, "found_city", {"radius": 3})
			if res.get("ok", false):
				show_toast("Founded %s (historically %s). Production is automated; untick Automate to choose." % [res.get("snapped_to", ""), res.get("historical_date", "")], 6.0)
				var nc = sim.city_by_id(int(res["city"]))
				if nc != null and mv.has_method("force_city"):
					mv.force_city(nc.key)
				_sync_units()
				select_unit(-1)
				_refresh_all()
				open_city(int(res["city"]), true)
				return
		"build":
			res = sim.unit_action(id, "build", {"improvement": arg})
			if res.get("ok", false):
				show_toast("%s built." % item_name("improvement", arg))
		_:
			res = sim.unit_action(id, action)
	if not res.get("ok", false):
		show_toast("Cannot: %s" % str(res.get("reason", action)))
	_sync_units()
	_refresh_hud()
	if action in ["fortify", "skip", "sleep"] or sim.unit_by_id(id) == null:
		next_unit(true)
	else:
		select_unit(id)


func next_unit(only_needing := false) -> void:
	var us := sim.get_units("player").filter(func(u): return u.get("needs_orders", false))
	if us.is_empty() and not only_needing:
		us = sim.get_units("player")
	if us.is_empty():
		select_unit(-1)
		return
	var idx := 0
	for i in us.size():
		if int(us[i]["id"]) == selected_unit:
			idx = (i + 1) % us.size()
	select_unit(int(us[idx]["id"]), true)


# ================================================================== save / load

func ui_state() -> Dictionary:
	## The UI sidecar saved next to every save (automated units, digest preference).
	return {"auto_units": auto_units.keys(), "show_digest": show_digest, "advised": tutorial.advised.keys(), "tips_off": tutorial.tips_off,
		"v4": 1, "full_hud": full_hud, "casual": casual.duplicate(true), "unlocked": unlocked.duplicate(), "intros_seen": intros_seen.duplicate(),
		"goals_open": goals_w.opened if goals_w != null else true, "report_open": report_w.opened if report_w != null else false}


static func quick_path() -> String:
	## The quick-save file. UI test runs keep theirs in user://saves_test/, so a test never leaves a "Continue:
	## quick-save" on the player's start screen (v4 fix round, new-player m8).
	for a in OS.get_cmdline_user_args():
		if str(a).begins_with("--ui-test"):
			return "user://saves_test/quicksave.json"
	return QUICKSAVE


func quick_save() -> void:
	if sim == null:
		return
	tutorial.save()
	if SaveSlots.write(quick_path(), sim, ui_state(), "Quick-save", "quick"):
		show_toast("Quick-saved (%s)." % sim.date_label())
	else:
		show_toast("Quick-save failed.")


func save_slot(path: String, name: String) -> bool:
	## Save window: a named slot.
	if sim == null:
		return false
	if SaveSlots.write(path, sim, ui_state(), name, "manual"):
		show_toast("Saved \"%s\" (%s)." % [name, sim.date_label()])
		return true
	show_toast("Saving failed.")
	return false


func load_slot(path: String) -> void:
	## Save window / start screen: load any save (manual, autosave or the quick-save).
	save_w.visible = false
	loading.run(func(): quick_load(path))


func continue_latest() -> void:
	## Start screen "Continue": the newest save of any kind.
	var m := SaveSlots.newest()
	if m.is_empty():
		show_toast("No saved game yet.")
		return
	load_slot(str(m["path"]))


func quick_load(path := "") -> void:
	if path == "":
		path = quick_path()
	if not FileAccess.file_exists(path):
		show_toast("No quick-save yet (F5 saves)." if path == quick_path() else "That save no longer exists.")
		return
	var meta := SaveSlots.read_meta(path)
	_drop_sim()
	sim = Sim.new()
	if not sim.load_game(path):
		show_toast("Quick-load failed.")
		start_new_game()
		return
	_connect_sim()
	V3Adapter.reset()
	UIAudio.set_era(int(sim.state.era))
	started = true
	auto_units.clear()
	var uip := path.replace(".json", "_ui.json")
	var v4_ui := {}
	if FileAccess.file_exists(uip):
		var d = JSON.parse_string(FileAccess.get_file_as_string(uip))
		if typeof(d) == TYPE_DICTIONARY:
			for id in d.get("auto_units", []):
				auto_units[int(id)] = true
			show_digest = bool(d.get("show_digest", false))
			for k in d.get("advised", []):
				tutorial.advised[str(k)] = true
			tutorial.tips_off = bool(d.get("tips_off", tutorial.tips_off))
			if d.has("v4"):
				v4_ui = d
	_restore_style(v4_ui)
	if start_screen:
		start_screen.queue_free()
		start_screen = null
	_notes = sim.get_notifications().filter(func(n): return int(n.get("turn", 0)) >= sim.state.turn and n.get("kind") != "blocked")
	game.set_date(sim.state.turn)
	_reset_units()
	if path == quick_path() and not sim.state.game_over:
		tutorial.load_state()   # the tutorial sidecar belongs to the quick-save only
	else:
		tutorial.active = false
		tutorial.card.visible = false
	_story_layout()
	if is_story():
		MinistersPanel.settle(self)
		Unlocks.update(self)
		_story_layout()
	_refresh_all()
	if v4_ui.is_empty() and full_hud and not sim.state.game_over and not testing and not capture:
		_offer_story.call_deferred()   # a v3 save loads as Full control: offer story mode once
	var what := "Quick-loaded" if path == quick_path() else ("Loaded autosave" if str(meta.get("kind", "")) == "auto" else "Loaded \"%s\"" % L10n.mark_verbatim(str(meta.get("name", "save"))))   # a save name is the player's own text
	show_toast("%s (%s)%s." % [what, sim.date_label(), " - tutorial continues" if tutorial.active else ""])
	if sim.state.game_over:
		show_end_screen()   # a finished game opens on its end summary


# ================================================================== keys

func _unhandled_key_input(e: InputEvent) -> void:
	## Keys go through the InputMap (GameSettings.ACTIONS, rebindable in Settings > Controls). Esc is fixed.
	if not (e is InputEventKey) or not e.pressed or e.echo:
		return
	if settings_w.capturing():
		return
	var k: int = e.keycode
	var a := GameSettings.action_for(e)
	if k == KEY_ENTER and e.alt_pressed:
		a = "fullscreen"
	match a:
		"help":
			show_help(); get_viewport().set_input_as_handled(); return
		"fullscreen":
			GameSettings.toggle_fullscreen(); get_viewport().set_input_as_handled(); return
		"settings":
			if settings_w.visible: settings_w.close()
			else: open_settings()
			get_viewport().set_input_as_handled(); return
		"pedia":
			_toggle(pedia, "pedia"); get_viewport().set_input_as_handled(); return
		"load":
			open_panel("load"); get_viewport().set_input_as_handled(); return
	if not started:
		if k == KEY_ESCAPE:
			for w in [settings_w, save_w, pedia, help]:
				if w.visible:
					w.close()
					get_viewport().set_input_as_handled()
					return
		return
	match a:
		"save": open_panel("save")
		"end_turn": next_action()
		"end_turn_force":
			if is_story():
				story_primary()   # forcing a turn exists only in Full control
			else:
				end_turn(true)
		"quick_save": quick_save()
		"quick_load": loading.run(func(): quick_load())
		"research": _toggle(research_p, "research")
		"civics": _toggle(civic_p, "civic")
		"policies": _toggle(policy_p, "policy")
		"ghost": _toggle(ghost_p, "ghost")
		"endings":
			if ghost_p.visible and ghost_p.tab == "endings":
				ghost_p.close()
			else:
				open_ghost_tab("endings")
		"diplomacy":
			if diplo_w.visible:
				diplo_w.close()
			else:
				open_diplomacy()
		"log": open_panel("log")
		"cabinet":
			if cabinet_p.visible:
				cabinet_p.close()
			else:
				open_panel("cabinet")
		"tech_tree":
			if tree_w.visible:
				tree_w.close()
			else:
				open_tree("tech")
		"next_unit": next_unit()
		"unit_fortify", "unit_skip", "unit_found":
			if selected_unit < 0:
				return
			unit_do({"unit_fortify": "fortify", "unit_skip": "skip", "unit_found": "found"}[a])
		_:
			if k == KEY_ESCAPE:
				_escape()
			else:
				return
	get_viewport().set_input_as_handled()


func _escape() -> void:
	if not placing.is_empty():
		cancel_placement()
		return
	if gov_menu != null and gov_menu.visible:
		gov_menu.visible = false
		return
	for w in [settings_w, room_w, popup, cabinet_p, diplo_w, prog_w, pedia, save_w, help, info_p, tree_w, policy_p, ghost_p, research_p, civic_p, city_s, story_c]:
		if w.visible:
			if w == popup and popup.mode in ["event"]:
				return   # decisions cannot be dismissed
			w.close()
			return
	if selected_unit >= 0:
		select_unit(-1)
	else:
		_show_menu()


# ================================================================== names

func item_name(kind: String, id: String) -> String:
	var d := db()
	match kind:
		"tech": return str(d.techs.get(id, {}).get("name", UITheme.pretty(id)))
		"civic": return str(d.civics.get(id, {}).get("name", UITheme.pretty(id)))
		"building": return str(d.buildings.get(id, {}).get("name", UITheme.pretty(id)))
		"district": return str(d.districts.get(id, {}).get("name", UITheme.pretty(id)))
		"unit": return str(d.units.get(id, {}).get("name", UITheme.pretty(id)))
		"project": return str(d.projects.get(id, {}).get("name", UITheme.pretty(id)))
		"city_project": return str(d.city_projects.get(id, {}).get("name", UITheme.pretty(id)))
		"improvement", "improvements": return str(d.improvements.get(id, {}).get("name", UITheme.pretty(id)))
		"policy", "policies": return str(d.policies.get(id, {}).get("name", UITheme.pretty(id)))
	return UITheme.pretty(id)


func item_detail(kind: String, id: String) -> String:
	var d := db()
	match kind:
		"building":
			var b: Dictionary = d.buildings.get(id, {})
			var parts := []
			for yk in b.get("yields", {}):
				parts.append("%s %s" % [UITheme.fmt_signed(float(b["yields"][yk])), str(yk).capitalize()])
			if float(b.get("housing", 0)) != 0: parts.append("%s Housing" % UITheme.fmt_signed(float(b["housing"]), 1).replace(".0", ""))
			if float(b.get("amenities", 0)) != 0: parts.append("%s Amenities" % UITheme.fmt_signed(float(b["amenities"]), 1).replace(".0", ""))
			if int(b.get("upkeep", 0)) > 0: parts.append("upkeep %d" % int(b["upkeep"]))
			return ", ".join(parts)
		"unit":
			var u: Dictionary = d.units.get(id, {})
			return "%s%s" % [str(u.get("cls", "")).capitalize(), (", strength %d" % int(u["cs"])) if int(u.get("cs", 0)) > 0 else ""]
		"project":
			return str(d.projects.get(id, {}).get("desc", ""))
		"city_project":
			return str(d.city_projects.get(id, {}).get("desc", ""))
		"district":
			return str(d.districts.get(id, {}).get("desc", d.districts.get(id, {}).get("description", "")))
	return ""


func unlock_text(u: Dictionary) -> String:
	var parts := []
	var map := {"districts": "district", "buildings": "building", "units": "unit", "policies": "policy", "improvements": "improvement", "projects": "project"}
	for k in u:
		var arr = u[k]
		if typeof(arr) != TYPE_ARRAY:
			continue
		for id in arr:
			parts.append(item_name(map.get(k, k), str(id)))
	return ", ".join(parts)


func _city_name(id: int) -> String:
	var c = sim.city_by_id(id)
	return "?" if c == null else c.name


func _actor(id: String) -> String:
	return str(db().actors.get(id, {}).get("name", UITheme.pretty(id)))


# ================================================================== Civilopedia (v2)

func open_pedia(kind := "", id := "") -> void:
	pedia.open(kind, id)
	_front(pedia)


func on_pedia_meta(meta) -> void:
	## meta_clicked handler for any RichTextLabel with Civilopedia links ([url=pedia:kind:id]).
	var s := str(meta)
	if s.begins_with("pedia:"):
		var p := s.substr(6).split(":")
		if p.size() >= 2:
			open_pedia(p[0], p[1])
	elif s.begins_with("http"):
		OS.shell_open(s)


func pedia_button(kind: String, id: String) -> Button:
	## Small "?" button that opens an entry (Buttons keep the mouse inside UIRows).
	var b := UITheme.button("?", func(): open_pedia(kind, id), 13)
	b.custom_minimum_size = Vector2(26, 24)
	b.tooltip_text = "Civilopedia: %s" % item_name(kind, id)
	return b


func unlock_links(u: Dictionary) -> String:
	## Like unlock_text, but each name is a Civilopedia link.
	var parts := []
	var map := {"districts": "district", "buildings": "building", "units": "unit", "policies": "policy", "improvements": "improvement", "projects": "project"}
	for k in u:
		var arr = u[k]
		if typeof(arr) != TYPE_ARRAY:
			continue
		for id in arr:
			var kk: String = map.get(k, k)
			parts.append(Civilopedia.link(kk, str(id), item_name(kk, str(id))))
	return ", ".join(parts)


# ================================================================== district placement lens (v2)

func begin_district_placement(city_id: int, did: String, queue := false) -> void:
	## Civ VI: picking a district shows its valid tiles with their adjacency bonus; click one to place, Esc cancels.
	var sites: Array = SimAdapter.district_sites(sim, city_id, did)
	if sites.is_empty():
		show_toast("No valid tile for %s in this city." % item_name("district", did))
		return
	var by := {}
	var best := float(sites[0].get("adjacency", 0))
	var lens_sites := []
	var labels := []
	for s in sites:
		var p := Vector2i(int(s["q"]), int(s["r"]))
		var adj := float(s.get("adjacency", 0))
		var e: Dictionary = (s as Dictionary).duplicate()
		e["best"] = adj >= best and best > 0
		by[p] = e
		lens_sites.append(e)
		var g := clampf(adj / maxf(1.0, best), 0.0, 1.0)
		labels.append({"q": p.x, "r": p.y, "label": "", "color": Color(0.45 - 0.2 * g, 0.55 + 0.4 * g, 0.40, 0.45 + 0.3 * g)})
	placing = {"city": city_id, "district": did, "queue": queue, "sites": by, "invalid": SimAdapter.invalid_sites(sim, city_id, did)}
	for w in [popup, cabinet_p, info_p, pedia]:
		w.visible = false   # the lens needs the map (an open decision comes back with the end-turn button)
	toast.visible = false
	mv.clear_highlights("worked")
	if mv.has_method("clear_worked_tiles"):
		mv.clear_worked_tiles()
	if lens.mode == "citizens":
		lens.clear()
	if mv.has_method("set_tile_labels"):
		mv.set_tile_labels(labels, "district_lens")
	else:
		mv.highlight_tiles(by.keys(), Color(0.45, 0.95, 0.45, 0.45), "district_lens")
	var yt := str(db().districts.get(did, {}).get("yield_type", ""))
	lens.show_district(lens_sites, yt)
	_place_text(Vector2i(-999, -999))
	place_bar.visible = true
	_fit_place_bar()
	_front(place_bar)
	var c = sim.city_by_id(city_id)
	if c != null:
		mv.focus_tile(c.q, c.r, maxf(game.rig.zoom, 1.5))


func _place_text(hover: Vector2i) -> void:
	var did := str(placing.get("district", ""))
	var yt := str(db().districts.get(did, {}).get("yield_type", ""))
	var n: int = (placing.get("sites", {}) as Dictionary).size()
	var s := "[b][color=#f7dc8f]PLACE %s[/color][/b]  [color=#c8ccd6]%d valid tile%s. The number on each tile is its adjacency bonus%s; the star marks the best; the green outline marks this city's tiles. Click a tile to build there.[/color]" % [
		item_name("district", did).to_upper(), n, "" if n == 1 else "s", (" (%s)" % yt.capitalize()) if yt != "" else ""]
	var site = placing.get("sites", {}).get(hover)
	if site != null:
		var parts: Array = site.get("parts", [])
		if parts.is_empty():
			parts = SimAdapter.adjacency_parts(sim, int(placing["city"]), did, hover.x, hover.y)
		var adj := float(site.get("adjacency", 0))
		var t := "\n[b]This tile: %s[/b]" % UITheme.fmt_signed(adj, 0 if adj == roundf(adj) else 1)
		if parts.size() > 0:
			var bits := []
			for pp in parts:
				var a := float(pp["amount"])
				bits.append("[color=%s]%s[/color] [color=#a8b0c4](%s)[/color]" % ["#9fe07a" if a >= 0 else "#ff8f7a", UITheme.fmt_signed(a, 0 if a == roundf(a) else 1), str(pp["label"])])
			t += "  " + ", ".join(bits)
		else:
			t += "  [color=#a8b0c4]no adjacency bonus here[/color]"
		if site.has("appeal"):
			t += "   [color=#a8b0c4]Appeal %s[/color]" % UITheme.fmt_signed(float(site["appeal"]))
		s += t
	elif placing.get("invalid", {}).has(hover):
		s += "\n[color=#ff8f7a]This tile: %s[/color]" % UITheme.humanise(str(placing["invalid"][hover]))
	place_text.text = UITheme.pal(s)


func place_district_at(q: int, r: int) -> bool:
	var p := Vector2i(q, r)
	if not placing.get("sites", {}).has(p):
		show_toast("Not a valid tile for %s. Pick a highlighted tile, or press Esc." % item_name("district", str(placing.get("district", ""))))
		return false
	var cid := int(placing["city"])
	var did := str(placing["district"])
	var q2: bool = placing.get("queue", false)
	_end_placement()
	choose_production(cid, "district", did, q2, SimHex.key(q, r))
	var c = sim.city_by_id(cid)
	var placed := false
	if c != null:
		for it in c.queue:
			if str(it.get("kind", "")) == "district" and str(it.get("id", "")) == did and int(it.get("tile", -1)) == SimHex.key(q, r):
				placed = true
	if placed:
		show_toast("%s will be built on this tile." % item_name("district", did), 2.5)
	_show_city_tiles()
	return placed


func cancel_placement() -> void:
	_end_placement()
	_show_city_tiles()


func _end_placement() -> void:
	if placing.is_empty() and (lens == null or lens.mode != "district"):
		return
	placing = {}
	if mv.has_method("clear_tile_labels"):
		mv.clear_tile_labels("district_lens")
	mv.clear_highlights("district_lens")
	if lens:
		lens.clear()
	if place_bar:
		place_bar.visible = false


# ================================================================== citizens (v2)

func _show_city_tiles() -> void:
	## City screen open: the city's worked citizens (blue) and locks (gold); the Citizens tab also shows each tile's yields.
	if city_s == null or not city_s.visible or sim == null or not placing.is_empty():
		return
	var cid := city_s.city_id
	var cz := SimAdapter.citizens(sim, cid)
	var worked := []
	var locked := []
	for t in cz.get("tiles", []):
		var p := Vector2i(int(t["q"]), int(t["r"]))
		if bool(t.get("locked", false)):
			locked.append(p)
		elif bool(t.get("worked", false)):
			worked.append(p)
	if mv.has_method("set_worked_tiles"):
		mv.clear_highlights("worked")
		mv.set_worked_tiles(worked, locked)
	else:
		mv.highlight_tiles(worked + locked, Color(0.45, 0.95, 0.55, 0.45), "worked")
	if city_s.tab == "citizens":
		lens.show_citizens(cz.get("tiles", []))
	elif lens.mode == "citizens":
		lens.clear()


func toggle_citizen(city_id: int, q: int, r: int) -> void:
	var res := SimAdapter.toggle_lock(sim, city_id, q, r)
	if not res.get("ok", false):
		show_toast(str(res.get("reason", "Cannot lock that tile.")))
		return
	city_s.refresh()
	_show_city_tiles()
	_refresh_hud()


func _on_city_closed() -> void:
	mv.clear_highlights("city"); mv.clear_highlights("worked")
	if mv.has_method("clear_worked_tiles"):
		mv.clear_worked_tiles()
	_end_placement()
	if lens and lens.mode == "citizens":
		lens.clear()


# ================================================================== combat preview (v2)

func _on_tile_hovered(q: int, r: int) -> void:
	if not started or sim == null:
		return
	var p := Vector2i(q, r)
	if lens:
		lens.hover = p
	if not placing.is_empty():
		_place_text(p)
		return
	if selected_unit >= 0 and str(_targets.get(p, "")) == "attack":
		var pv := SimAdapter.unit_preview(sim, selected_unit, q, r)
		cpv.show_unit(pv)
		_front(cpv)
	elif cpv.visible:
		cpv.visible = false


# ================================================================== v4: story mode (V4_DESIGN 2.3-2.8)
# Story mode (the default for new games): the ministers run the routine (sim.auto, else MinistersPanel.settle), the
# player sees ONE primary prompt (NextStep), one story card per decision (StoryCard), the era goals (GoalsCard), the
# ministers' report and the Cabinet Room (MinistersPanel), and a HUD that unlocks as systems start to matter
# (Unlocks). Full control (full_hud) is the v3 game and HUD exactly.

const STORY_CARD_TYPES := ["event_choice", "fork", "coalition", "crisis_response", "treasury", "state_budget", "immigration", "diplomacy", "programme", "dedication", "brief", "agenda"]


func is_story() -> bool:
	return sim != null and not full_hud


func _default_style() -> String:
	## A new game's play style: --ui-test-style in the UI tests (Full control unless a suite asks for story), else the
	## player's last choice on the New Game panel (Full control the first time; the user, 2026-10-17).
	if test_style != "":
		return test_style
	for a in OS.get_cmdline_user_args():
		if str(a).begins_with("--ui-style="):   # captures: --ui-style=story|full
			return "full" if str(a).substr(11) == "full" else "story"
	return GameSettings.play_style


static func _tutorial_story() -> bool:
	var s: Script = Tutorial
	return s.get_script_constant_map().has("STEPS_STORY")


func _build_story_ui() -> void:
	story_left = VBoxContainer.new()
	story_left.name = "StoryLeft"
	story_left.add_theme_constant_override("separation", 6)
	story_left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_place(story_left, Vector2(0, 0), Vector2(0, 0), Rect2(10, 56, 430, 0))
	hud_space.add_child(story_left)   # (the HUD's units: layout-audit)
	goals_w = GoalsCard.new()
	goals_w.ui = self
	goals_w.custom_minimum_size = Vector2(430, 0)
	story_left.add_child(goals_w)
	report_w = MinistersPanel.Strip.new()
	report_w.ui = self
	report_w.custom_minimum_size = Vector2(430, 0)
	story_left.add_child(report_w)
	story_bar = HBoxContainer.new()
	story_bar.name = "StoryBar"
	story_bar.add_theme_constant_override("separation", 6)
	story_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_place(story_bar, Vector2(0, 1), Vector2(0, 1), Rect2(10, -62, 0, 44))
	hud_space.add_child(story_bar)   # (the HUD's units: layout-audit)
	next_w = NextStep.new()
	next_w.ui = self
	next_w.primary_pressed.connect(story_primary)
	next_w.chip_pressed.connect(func(d): player_actions += 1; story_open(d))
	hud_space.add_child(next_w)   # (the HUD's units: layout-audit)
	intro_w = PanelContainer.new()
	intro_w.name = "IntroStrip"
	intro_w.add_theme_stylebox_override("panel", UITheme.sb(Color(0.05, 0.09, 0.19, 0.97), UIKit.GOLD_LIGHT, 2, 8, 10))
	intro_w.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ih := HBoxContainer.new()
	ih.add_theme_constant_override("separation", 10)
	ih.mouse_filter = Control.MOUSE_FILTER_IGNORE
	intro_w.add_child(ih)
	var por := TextureRect.new()
	if ResourceLoader.exists(Tutorial.PORTRAIT):
		por.texture = load(Tutorial.PORTRAIT)
	por.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	por.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	por.custom_minimum_size = Vector2(52, 52)
	por.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ih.add_child(por)
	var iv := VBoxContainer.new()
	iv.mouse_filter = Control.MOUSE_FILTER_IGNORE
	iv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ih.add_child(iv)
	var it := UITheme.title("CABINET SECRETARY", 14, UIKit.GOLD)
	it.mouse_filter = Control.MOUSE_FILTER_IGNORE
	iv.add_child(it)
	intro_lbl = UITheme.label("", 16, UIKit.TEXT)
	intro_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro_lbl.custom_minimum_size = Vector2(400, 0)
	intro_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	iv.add_child(intro_lbl)
	intro_w.visible = false
	hud_space.add_child(intro_w)   # (the HUD's units: layout-audit)
	for c in [story_left, story_bar, next_w]:
		c.visible = false
	# v4 fix round (V4_DESIGN 2.6): while a story card is open the HUD under it is inert: a light dim layer catches the
	# clicks (Esc or the card's X folds the card back into the NOW prompt)
	story_block = ColorRect.new()
	story_block.name = "StoryBlock"
	(story_block as ColorRect).color = Color(0.0, 0.02, 0.06, 0.28)
	story_block.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	story_block.mouse_filter = Control.MOUSE_FILTER_STOP
	story_block.visible = false
	root.add_child(story_block)
	# the era change banner (non-interactive)
	era_banner = PanelContainer.new()
	era_banner.name = "EraBanner"
	era_banner.add_theme_stylebox_override("panel", UITheme.sb(Color(0.04, 0.08, 0.18, 0.97), UIKit.GOLD_LIGHT, 2, 10, 16))
	era_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ev := VBoxContainer.new()
	ev.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ev.add_theme_constant_override("separation", 2)
	era_banner.add_child(ev)
	for i in 3:
		var l := UITheme.label("", [15, 26, 16][i], [UIKit.GOLD, UIKit.GOLD_LIGHT, UIKit.TEXT][i], ["title", "title", "body"][i])
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		l.name = ["era_kicker", "era_name", "era_sub"][i]
		ev.add_child(l)
	era_banner.visible = false
	_place(era_banner, Vector2(0.5, 0), Vector2(0.5, 0), Rect2(-330, 70, 660, 0))
	hud_space.add_child(era_banner)   # (the HUD's units: layout-audit)


func _init_style(style: String) -> void:
	## A new game: Story (every ministry on auto, the staged HUD) or Full control (every ministry manual, the v3 HUD).
	full_hud = style == "full"
	casual = {"auto": {}, "brief": "balanced", "report": [], "brief_asked": false, "start_turn": sim.state.turn, "era_seen": int(sim.state.era)}
	unlocked = {}
	intros_seen = {}
	intro_log.clear()   # (this game's introductions)
	_intro_q.clear()
	if intro_w != null:
		intro_w.visible = false
	_first_turn = sim.state.turn
	if not NextStep.has_api(sim, "set_style"):
		NextStep.set_all(self, not full_hud)   # (with sim.auto, new_game's play_style set it up; Full control stays v3 exactly)
	if not full_hud:
		_story_quiet_tips()
		if goals_w != null:
			goals_w.opened = true
		if report_w != null:
			report_w.opened = false
	_story_layout()


func _restore_style(d: Dictionary) -> void:
	## A loaded save: its v4 sidecar (the play style, the fallback ministries, the unlocked HUD). A v3 save, which has
	## none, loads as Full control (v3 behaviour).
	unlocked = {}
	intros_seen = {}
	_intro_q.clear()
	_first_turn = -1
	if d.is_empty():
		full_hud = true
		casual = {"auto": {}, "brief": "balanced", "report": [], "brief_asked": true}
		if NextStep.has_api(sim, "style"):
			full_hud = str(NextStep.auto_api(sim).style()) == "full"
		elif full_hud:
			NextStep.set_all(self, false)
		return
	full_hud = bool(d.get("full_hud", true))
	var cs = d.get("casual", {})
	casual = (cs as Dictionary).duplicate(true) if cs is Dictionary else {}
	if not casual.has("auto"):
		casual["auto"] = {}
	var ul = d.get("unlocked", {})
	unlocked = (ul as Dictionary).duplicate() if ul is Dictionary else {}
	var isn = d.get("intros_seen", {})
	intros_seen = (isn as Dictionary).duplicate() if isn is Dictionary else {}
	if goals_w != null:
		goals_w.opened = bool(d.get("goals_open", true))
	if report_w != null:
		report_w.opened = bool(d.get("report_open", false))
	if not full_hud:
		_story_quiet_tips()


func _story_quiet_tips() -> void:
	## Story mode: the story card and the unlock strips explain each decision, so the v3 first-time advisor cards
	## (whose "Show me" opens the v3 screens) stay quiet; the danger, risk and deficit cards still come.
	if tutorial == null:
		return
	for k in ["crisis", "front", "fork", "state_budget", "budget_review", "minister", "coalition", "diplomacy", "programme", "agenda", "election"]:
		tutorial.advised[k] = true


func _offer_story() -> void:
	## A v3 save loads as Full control: offer Story mode once.
	if sim == null or not full_hud:
		return
	var list := _info("Story mode")
	var t := UITheme.rich("This save comes from an earlier version and plays in Full control: every decision is yours. Switch to Story mode? Your ministers then run the routine and you make the big calls. You can switch back in Settings > Gameplay at any time.", 17)
	list.add_child(t)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	list.add_child(h)
	h.add_child(UITheme.button("Switch to Story mode", func(): info_p.visible = false; set_play_style("story"), 18))
	h.add_child(UITheme.button("Keep Full control", func(): info_p.visible = false, 18))


func set_play_style(s: String) -> void:
	## Settings > Gameplay, the Cabinet Room, the old-save offer: Story <-> Full control, mid-game included (2.8).
	if sim == null:
		GameSettings.play_style = "full" if s == "full" else "story"
		GameSettings.save_cfg()
		return
	player_actions += 1
	var was_full := full_hud
	if s == "full":
		full_hud = true
		if NextStep.has_api(sim, "set_style"):
			NextStep.auto_api(sim).set_style("full")
		NextStep.set_all(self, false)
		story_c.visible = false
		next_w.stop_auto()
		_intro_q.clear()
		intro_w.visible = false
	else:
		full_hud = false
		if NextStep.has_api(sim, "set_style"):
			NextStep.auto_api(sim).set_style("story")
		NextStep.set_all(self, true)
		if was_full:
			Unlocks.unlock_all_silent(self)   # the player has seen the whole HUD: it stays (Simplify re-locks it)
		_story_quiet_tips()
		MinistersPanel.settle(self)
	_story_layout()
	_refresh_all()
	if room_w.visible:
		room_w.refresh.call_deferred()
	if settings_w.visible:
		settings_w.refresh.call_deferred()
	show_toast("Full control: every decision is yours." if s == "full" else "Story mode: your ministers run the routine; you make the big calls.", 3.5)


func set_domain_auto(id: String, on: bool) -> void:
	## A ministry's toggle (the Cabinet Room, Settings > Gameplay): auto or manual, at any time.
	if sim == null:
		return
	player_actions += 1
	if on and full_hud:
		full_hud = false   # a ministry handed back in Full control: story mode with that ministry on auto (Custom)
		Unlocks.unlock_all_silent(self)
		_story_quiet_tips()
	var unlocked_before: Dictionary = (unlocked as Dictionary).duplicate()
	NextStep.set_auto(self, id, on)
	if on:
		MinistersPanel.settle(self)
	Unlocks.update(self)
	if on:
		Unlocks.hand_back(self, id)   # v4polish: the parts only this ministry's take-over showed go away again
	else:
		Unlocks.note_takeover(self, id, unlocked_before)
	_story_layout()
	_refresh_all()
	if room_w.visible:
		room_w.refresh.call_deferred()
	if settings_w.visible:
		settings_w.refresh.call_deferred()
	show_toast(("%s: your minister decides again." if on else "%s: you decide now.") % domain_name(id), 3.0)


func domain_name(id: String) -> String:
	for d in NextStep.domains(sim):
		if str(d["id"]) == id:
			return str(d.get("name", id))
	return id


func set_ministers_brief(b: String) -> void:
	if sim == null:
		return
	player_actions += 1
	NextStep.set_brief(self, b)
	if room_w.visible:
		room_w.refresh.call_deferred()
	if settings_w.visible:
		settings_w.refresh.call_deferred()
	for x in NextStep.BRIEFS:
		if x[0] == b:
			show_toast("The ministers' brief: %s." % str(x[1]), 2.5)


func set_era_goals(on: bool) -> void:
	## Settings > Gameplay: the era goals on or off for the game in progress (sim.goals.set_enabled, v4fix-sim B5).
	var g = sim.get("goals") if sim != null else null
	if not (g is Object and (g as Object).has_method("set_enabled")):
		return
	player_actions += 1
	g.set_enabled(on)
	_story_layout()
	_refresh_hud()
	show_toast("Era goals: on." if on else "Era goals: off.", 2.5)


func set_auto_advance(on: bool) -> void:
	GameSettings.auto_advance = on
	GameSettings.save_cfg()
	if not on and next_w != null:
		next_w.stop_auto()


func simplify_screen() -> void:
	## Settings > Gameplay: "Simplify the screen again" re-locks what is not in use.
	if sim == null:
		return
	Unlocks.simplify(self)
	_story_layout()
	_refresh_hud()
	show_toast("The screen is simple again: panels come back when they matter.", 3.0)


func open_cabinet_room() -> void:
	if sim == null:
		return
	room_w.open_room()
	_front(room_w)


# ------------------------------------------------------------------ the turn in story mode

func _story_turn_start(quiet: bool) -> void:
	next_w.stop_auto()
	MinistersPanel.settle(self)
	var era_now := int(sim.state.era)
	var era_changed := int(casual.get("era_seen", era_now)) != era_now
	casual["era_seen"] = era_now
	Unlocks.update(self)
	_deal_hint()
	_story_layout()
	_refresh_all()
	if era_changed and not quiet and not sim.state.game_over:
		show_era_banner()
	if quiet or (tutorial.active and not tutorial.story_tut) or sim.state.game_over:
		return
	if not _queue.is_empty():
		var f: Callable = _queue.pop_front()   # a scenario's briefing first
		f.call()
		return
	var pd := NextStep.player_decisions(self)
	if pd.is_empty():
		if GameSettings.auto_advance and not era_changed and _quiet_ok():
			next_w.start_auto(2.0)
		return
	if sim.state.turn == _first_turn:
		return   # a new game's first quarter: the goals and the prompt first; the player clicks Decide
	story_open(pd[0])


func _quiet_ok() -> bool:
	## A quiet quarter for the auto-advance: nothing to decide, no new element to introduce, no goal met or missed,
	## no collapse warning.
	if not _intro_q.is_empty() or (intro_w != null and intro_w.visible):
		return false
	if sim.has_method("get_collapse_warnings") and not (sim.get_collapse_warnings() as Array).is_empty():
		return false
	for n in sim.get_notifications():
		if int(n.get("turn", -1)) == sim.state.turn and str(n.get("kind", "")) in ["goal", "era", "collapse"]:
			return false
	return true


func auto_advance_now() -> void:
	## The quiet quarter's countdown ran out: the turn ends on its own.
	if sim == null or not is_story() or sim.state.game_over:
		return
	if NextStep.quiet(self) and not (story_c.visible or room_w.visible or settings_w.visible):
		end_turn(false)


func _input(e: InputEvent) -> void:
	## Any key or click stops the auto-advance of a quiet quarter.
	if next_w != null and next_w.auto_running():
		if (e is InputEventKey and (e as InputEventKey).pressed) or (e is InputEventMouseButton and (e as InputEventMouseButton).pressed):
			next_w.stop_auto()


func story_primary() -> void:
	## The primary prompt's button (and Enter): the first decision on its story card, or End Turn.
	if sim == null:
		return
	if sim.state.game_over:
		show_end_screen()
		return
	if next_w != null:
		next_w.stop_auto()
	_hide_intro()
	var p := NextStep.primary(self)
	if str(p.get("type", "")) == "end_turn":
		end_turn(false)
		return
	player_actions += 1
	story_open(p)


func story_open(d: Dictionary) -> void:
	## A story decision opens on the story card; a routine one the player runs (a ministry on manual) opens its v3 screen.
	if str(d.get("type", "")) in STORY_CARD_TYPES:
		info_p.visible = false
		story_c.open_for(d)
		_front(story_c)
		preview_decision(d)   # v4polish: the map shows where the decision is (a front, a city); no place, no move
	else:
		jump_to(d)


func story_pick(d: Dictionary, o: Dictionary) -> void:
	## One click: the option is taken, its result opens in the same card and the next decision follows in it.
	player_actions += 1
	_hide_intro()
	var r := StoryCard.resolve(self, d, o)
	if not bool(r.get("ok", false)):
		var why := StoryCard.reason_of(o)
		var msg := ("Not possible now: %s" % why) if why != "" else "That option is not available now."
		if NextStep.has_api(sim, "refusal_text"):
			var rt := str(NextStep.auto_api(sim).refusal_text(d, int(o.get("index", 0))))
			if rt != "":
				msg = rt   # (sim.auto: always a sentence, the specific reason when there is one)
		show_toast(msg, 5.0)
		var pd0 := NextStep.player_decisions(self)
		if pd0.is_empty():
			story_c.show_end()
		else:
			story_c.open_for(pd0[0], true)
		return
	if str(d.get("type", "")) in ["fork", "diplomacy"]:
		UIAudio.sting("fork")
	var focused0 := focus_log.size()
	focus_decision(d, o)
	MinistersPanel.settle(self)
	Unlocks.update(self)
	_story_layout()
	_refresh_all()
	story_c.picks_this_turn += 1
	story_c.result_text = str(r.get("text", ""))
	story_c.result_title = str(r.get("title", ""))
	var pd := NextStep.player_decisions(self)
	if pd.is_empty():
		story_c.show_end()
	else:
		story_c.open_for(pd[0], true)
		if focus_log.size() == focused0:
			preview_decision(pd[0])   # (the last pick lit no place: the next card's place, if any; else its highlight plays)
	_front(story_c)


func story_details(d: Dictionary) -> void:
	## "Details": the full v3 screen of the decision (advocates, sources, previews, lasting terms, custom budget).
	player_actions += 1
	story_c.visible = false
	if str(d.get("type", "")) == "treasury":
		open_fiscal()
	else:
		jump_to(d)


func story_end_turn() -> void:
	story_c.visible = false
	end_turn(false)


func story_headlines() -> Array:
	## This quarter's history headlines (the ministers' report shows them in story mode; the ticker in Full control).
	return _hist_notes.filter(func(n): return str(n.get("kind", "")) != "hold" and int(n.get("turn", -1)) >= sim.state.turn - 1)


func _story_after_window() -> void:
	## A v3 screen closed in story mode (Details, a panel): the ministers settle what followed; the prompt updates.
	if sim == null or sim.state.game_over:
		return
	MinistersPanel.settle(self)
	Unlocks.update(self)
	_story_layout()
	_refresh_all()


# ------------------------------------------------------------------ the story HUD

const STANDING_WATCH := 30.0      # story mode: International Standing joins the top bar below this (amber; red below half)


func overdraft_line(bad: bool) -> String:
	## The plain line under a Treasury below zero (story mode's top bar tooltip and the Treasury's introduction).
	if bad:
		return "The Treasury is in danger: open Treasury in the Government menu and take Finance's plan."
	if sim != null and sim.year() <= 1953:
		return "Finance is borrowing to pay for immigration, as Israel did in 1949–51. Watch it only if it turns red."
	return "Finance is running an overdraft, as Israel's governments often did. Watch it only if it turns red."


func overdraft_intro(bad: bool) -> String:
	## The Cabinet Secretary's strip the first time the Treasury goes below zero (story mode): what it means, whether to
	## worry, what to do.
	if bad:
		return "Prime Minister, the Treasury is below zero and its number is red: the debt is getting dangerous. Open Treasury in the Government menu and take Finance's plan."
	if sim != null and sim.year() <= 1953:
		return "Prime Minister, the Treasury is below zero: Finance is borrowing to house the newcomers, as Israel did in 1949–51. No need to worry while the number is amber. If it turns red, open Treasury in the Government menu and take Finance's plan."
	return "Prime Minister, the Treasury is below zero: Finance is borrowing to cover the gap, as Israel's governments often did. No need to worry while the number is amber. If it turns red, open Treasury in the Government menu and take Finance's plan."


func _story_live(live: Dictionary, n: Dictionary, fr: Dictionary, ec: Dictionary) -> void:
	## Story mode's top bar: the Treasury, Population, Civic Trust and Readiness; Standing, the debt and inflation
	## indicator, Science and Culture and Food as they unlock; the collapse danger as in v3.
	var vi: Array = live.get("top_items", [])
	var vt: Array = live.get("top_tips", [])
	if vi.size() < 7 or vt.size() < 7:
		return
	var rd := float(n.get("readiness", 0))
	var rcol: Color = UIKit.BAD if rd < 30.0 else (UIKit.WARN if rd < 50.0 else (UIKit.GREEN if rd >= 70.0 else UIKit.TEXT))
	# v4 fix round (new-player N1, A6): a Treasury below zero inside history's own overdraft reads amber with a plain
	# line; red only when the Treasury is really in danger (the fiscal indicator's warning / danger, or a collapse)
	var gold_it: Array = (vi[0] as Array).duplicate()
	var gold_tip := str(vt[0])
	var flvl := str(ec.get("level", "ok"))
	var cb := V3Adapter.collapse_bar(sim)
	var fiscal_bad: bool = flvl in ["warning", "danger"] or (bool(cb.get("show", false)) and str(cb.get("id", "")).contains("fiscal"))
	if float(n.get("gold_treasury", 0)) < 0.0:
		while gold_it.size() < 5: gold_it.append(UIKit.TEXT)
		gold_it[3] = UIKit.BAD if fiscal_bad else UIKit.WARN
		gold_it[4] = UIKit.BAD if fiscal_bad else UIKit.WARN
		gold_tip += "\n" + overdraft_line(fiscal_bad)
		# v4polish (new-player L010): the first time the Treasury goes below zero, the Cabinet Secretary says in plain
		# words what it means, whether to worry and what to do
		if not (intros_seen as Dictionary).has("overdraft") and started:
			intros_seen["overdraft"] = sim.state.turn
			queue_intro("overdraft", overdraft_intro(fiscal_bad))
	elif float(n.get("gold_net", 0)) < 0.0:
		gold_it[4] = UIKit.TEXT   # (a quarter's deficit with money in the bank is no alarm in story mode)
	gold_tip += "\n" + ("Inflation %s a year; debt %s years of revenue." % [str(vi[6][1]).replace(" ▲", "").replace(" ▼", ""), str(snappedf(float(ec.get("debt_ratio", 0.0)), 0.1))])
	var gh: Dictionary = live.get("ghost", {})
	if float(gh.get("health", 1.0)) < 0.995 and str(gh.get("health_text", "")) != "":
		gold_tip += "\n" + str(gh["health_text"])
	var items := [gold_it, vi[5], vi[4], ["readiness", "%d" % int(round(rd)), "", rcol]]
	var tips := [gold_tip, vt[5], vt[4], "Readiness: %d of 100. How ready the army is: higher readiness makes every counter-attack hit harder and wars cost less." % int(round(rd))]
	var labels := ["Treasury", "Population", "Civic Trust", "Readiness"]   # (v4polish: one name per stat, as on the cards and goals)
	# the other numbers show only while they need attention (amber or red); their full story is in the drill-downs
	var stv := float(n.get("standing", 0))
	if Unlocks.is_on(self, "standing") and stv < STANDING_WATCH:
		items.append(["diplomacy", "%d" % int(round(stv)), "", UIKit.BAD if stv < STANDING_WATCH * 0.5 else UIKit.WARN])
		tips.append("Standing: %d of 100. How the world sees Israel: it opens deals, aid and backing in a crisis." % int(round(stv)))
		labels.append("Standing")
	var econ_it: Array = (vi[6] as Array).duplicate()
	# v4polish (new-player L012): in story mode red means real danger only (the fiscal indicator's warning or danger);
	# a high or rising inflation the indicator still calls "watch" reads amber
	for ci in [3, 4]:
		if econ_it.size() > ci and econ_it[ci] is Color:
			var cc: Color = econ_it[ci]
			if flvl in ["ok", "watch"] and (cc.is_equal_approx(UIKit.BAD) or cc.is_equal_approx(UIKit.WARN_HI)):
				econ_it[ci] = UIKit.WARN
			elif flvl == "warning" and cc.is_equal_approx(UIKit.BAD):
				econ_it[ci] = UIKit.WARN_HI
	var attention := func(c) -> bool: return c is Color and ((c as Color).is_equal_approx(UIKit.WARN) or (c as Color).is_equal_approx(UIKit.WARN_HI) or (c as Color).is_equal_approx(UIKit.BAD))
	if Unlocks.is_on(self, "treasury") and (flvl != "ok" or attention.call(econ_it[3] if econ_it.size() > 3 else null) or attention.call(econ_it[4] if econ_it.size() > 4 else null)):
		items.append(econ_it); tips.append(vt[6])
		labels.append("Inflation")
	if not NextStep.is_auto(self, "research") or not NextStep.is_auto(self, "civics"):
		items.append(vi[1]); tips.append(vt[1]); labels.append("")
		items.append(vi[2]); tips.append(vt[2]); labels.append("")
	if Unlocks.is_on(self, "food") and (float(fr.get("surplus", 0.0)) < 0.0 or not NextStep.is_auto(self, "production")):
		items.append(vi[3]); tips.append(vt[3]); labels.append("Food")
	for k in range(7, mini(vi.size(), vt.size())):
		items.append(vi[k]); tips.append(vt[k]); labels.append("")   # the collapse danger (v3 item 13)
	live["top_items"] = items
	live["top_tips"] = tips
	live["top_labels"] = labels
	live["next_sub"] = ""
	if next_w != null:
		next_w.show_for(sim, NextStep.player_decisions(self))


func _story_layout() -> void:
	## Shows story mode's pieces by what is unlocked (or the v3 HUD in Full control).
	var on := is_story() and started
	for c in [story_left, story_bar, next_w]:
		if c != null:
			c.visible = on
	if rail != null:
		rail.visible = not on
	if ticker != null:
		ticker.visible = not on
	if sats != null:
		sats.visible = not on
	if hud == null:
		return
	if not on:
		hud.set_story(false)
		if intro_w != null:
			intro_w.visible = false
		for c2 in [gov_menu, era_banner, story_block]:
			if c2 != null:
				c2.visible = false
		return
	# v4 fix round (new-player N3): a calm screen. VS. HISTORY is a line on the era goals card (its panel is in the
	# Government menu); the minimap shows when the player commands units or asks for it in the Government menu; the
	# Civilopedia and How to Play live in the Menu (F1 still opens How to Play).
	var parts := {}
	if Unlocks.is_on(self, "research"):
		parts["research"] = true
		parts["civic"] = true
	if Unlocks.is_on(self, "city_card"): parts["city"] = true
	if minimap_shown(): parts["minimap"] = true
	hud.set_story(true, parts, ["menu"])
	goals_w.visible = Unlocks.is_on(self, "goals") and GoalsCard.shown(sim)
	report_w.visible = Unlocks.is_on(self, "report")
	report_w.room_btn.visible = false   # (the Cabinet Room is in the Government menu)
	next_w.chips_on = Unlocks.is_on(self, "queue")
	next_w.set_right_edge(292.0 if parts.has("minimap") else 10.0)
	_story_bar_build(parts.has("city"))
	goals_w.refresh()
	report_w.refresh()


func _sync_story_block() -> void:
	## The dim layer follows the story card: under it, above the HUD, the goals and the NOW prompt.
	if story_block == null or story_c == null:
		return
	var on := story_c.visible and is_story()
	story_block.visible = on
	if on:
		if gov_menu != null:
			gov_menu.visible = false
		story_block.move_to_front()
		story_c.move_to_front()
		if tutorial != null:
			tutorial.move_to_front()   # (the story tutorial's card sits beside the story card and stays clickable)
		if toast != null:
			toast.move_to_front()


func _deal_hint() -> void:
	## v4 fix round (veteran m8): the first time a deal is on the table, one gentle line points at the deal screen.
	if sim == null or full_hud or casual.has("deal_hint") or not Unlocks.is_on(self, "standing"):
		return
	for r in V3Adapter.diplo_rows(sim):
		if int(r.get("deals_ready", 0)) > 0:
			casual["deal_hint"] = sim.state.turn
			queue_intro("deal", "An offer is on the table: %s would make a deal with Israel. Open Diplomacy in the Government menu to see it." % str(r.get("name", "")))
			return


var focus_log: Array = []          # [turn, city] of every place the map showed after a decision (tests)


var preview_log: Array = []        # [turn, decision type, q, r] of every place the map panned to as a card opened (tests)


func decision_place(d: Dictionary, o := {}) -> Array:
	## v4polish (new-player: "decisions have no visible effect on the map"): the place a story decision is about, as
	## [q, r]: a war front (the option's front, else the most threatened one), the decision's city, its event's places,
	## or the first town its words name. [] when it has no place (a budget, a programme, an envoy): the view stays.
	if sim == null:
		return []
	var t := str(d.get("type", ""))
	if t in ["state_budget", "programme", "brief", "treasury", "agenda", "dedication"]:
		return []
	if t == "crisis_response":
		var opts: Array = d.get("options", [])
		var want := str(o.get("id", ""))
		if want == "":
			var rec: Dictionary = sim.auto.recommend(d) if NextStep.has_api(sim, "recommend") else {}
			var ri := int(rec.get("index", -1)) if rec is Dictionary else -1
			if ri >= 0 and ri < opts.size():
				want = str(opts[ri].get("id", ""))
		var cr := SimAdapter._crisis_of(sim, opts[0] if not opts.is_empty() else {})
		var fronts: Array = cr.get("data_fronts", []) if cr.get("data_fronts") is Array else []
		for fr in fronts:
			if want.ends_with(":" + str(fr.get("id", ""))) and fr.get("pos") is Array:
				return [int(fr["pos"][0]), int(fr["pos"][1])]
		for o2 in opts:
			var oid := str(o2.get("id", ""))
			if oid.begins_with("front:"):
				var xy := oid.substr(6).split(",")
				if xy.size() >= 2:
					return [int(xy[0]), int(xy[1])]
		if not fronts.is_empty() and fronts[0].get("pos") is Array:
			return [int(fronts[0]["pos"][0]), int(fronts[0]["pos"][1])]
	var key := _decision_city_key(d, o)
	if key != "":
		var c = sim.city_by_key(key)
		if c != null:
			return [int(c.q), int(c.r)]
	return []


func preview_decision(d: Dictionary) -> void:
	## A story card opened: the map pans gently to the decision's place, beside the card (no zoom jump). No place: the
	## view stays.
	if sim == null or mv == null or game == null or game.get("rig") == null:
		return
	var p := decision_place(d)
	if p.is_empty():
		return
	var c := TerrainMath.offset_center(int(p[0]), int(p[1]))
	var tgt := Vector2(c.x, c.y + 0.4)
	# the card covers the middle of the screen: put the place in the free band right of it
	var cam: Camera3D = game.rig.cam
	var vp := get_viewport().get_visible_rect().size
	if cam != null and vp.x > 0.0:
		var depth: float = cam.global_position.distance_to(Vector3(game.rig.target.x, 0.0, game.rig.target.z))
		var mid := cam.project_position(vp * 0.5, depth)
		var side := cam.project_position(Vector2(vp.x * 0.80, vp.y * 0.5), depth)
		tgt -= Vector2(side.x - mid.x, side.z - mid.z)
	game.rig.set_view(tgt.x, tgt.y, game.rig.zoom, false)
	preview_log.append([sim.state.turn, str(d.get("type", "")), int(p[0]), int(p[1])])


func _decision_city_key(d: Dictionary, o := {}) -> String:
	## The city a decision names (its own city, its event's first place, or the first town its words name), or "".
	var places: Array = []
	if str(d.get("type", "")) == "event_choice":
		var ev = sim.db.event_by_id.get(str(d.get("event", "")))
		if ev != null and ev.get("places") is Array:
			places = ev["places"]
	elif d.has("city"):
		var c0 = sim.city_by_id(int(d["city"]))
		if c0 != null:
			places = [c0.key]
	if places.is_empty():
		var words := " ".join([str(o.get("label", "")), str(d.get("title", "")), str(d.get("label", "")), str(d.get("text", d.get("explain", "")))])
		var best_at := 1 << 30
		var best_key := ""
		for c1 in sim.active_cities():
			var nm := str(c1.name)
			if nm.length() < 4:
				continue
			var at := words.find(nm)
			if at >= 0 and (at < best_at or (at == best_at and best_key != "" and nm.length() > str(sim.city_by_key(best_key).name).length())):
				best_at = at
				best_key = str(c1.key)
		if best_key != "":
			places = [best_key]
	for p in places:
		var c = sim.city_by_key(str(p))
		if c != null and c.active:
			return str(c.key)
	return ""


func focus_decision(d: Dictionary, o := {}) -> void:
	## v4 fix round (new-player: "the map stays the same"): after a decision that names a place, the map pans to it and
	## lights it for a few seconds.
	if sim == null or mv == null or game == null:
		return
	var places: Array = []
	if str(d.get("type", "")) == "event_choice":
		var ev = sim.db.event_by_id.get(str(d.get("event", "")))
		if ev != null and ev.get("places") is Array:
			places = ev["places"]
	elif d.has("city"):
		var c0 = sim.city_by_id(int(d["city"]))
		if c0 != null:
			places = [c0.key]
	if places.is_empty():
		# a fork, a front, an envoy: the first town its own words name (the option taken first, then the question)
		var words := " ".join([str(o.get("label", "")), str(d.get("title", "")), str(d.get("label", "")), str(d.get("text", d.get("explain", "")))])
		var best_at := 1 << 30
		var best_key := ""
		for c1 in sim.active_cities():
			var nm := str(c1.name)
			if nm.length() < 4:
				continue
			var at := words.find(nm)
			if at >= 0 and (at < best_at or (at == best_at and best_key != "" and nm.length() > str(sim.city_by_key(best_key).name).length())):
				best_at = at
				best_key = str(c1.key)
		if best_key != "":
			places = [best_key]
	for p in places:
		var c = sim.city_by_key(str(p))
		if c == null or not c.active:
			continue
		mv.focus_tile(c.q, c.r, maxf(game.rig.zoom, 1.4))
		var cd := sim.get_city(c.id)
		var tiles: Array = cd.get("tiles", [])
		mv.highlight_tiles(tiles if not tiles.is_empty() else [[c.q, c.r]], Color(1.0, 0.82, 0.35, 0.35), "story")
		_focus_t = 4.0
		focus_log.append([sim.state.turn, str(c.name)])
		return


func show_era_banner() -> void:
	## v4 fix round (new-player m10): an era change is announced: "A NEW ERA", its name, and its new goals.
	if era_banner == null or sim == null:
		return
	var d := sim.get_date()
	var gv := GoalsCard.view(sim)
	var ng := (gv.get("goals", []) as Array).size()
	(era_banner.find_child("era_kicker", true, false) as Label).text = "A NEW ERA"
	(era_banner.find_child("era_name", true, false) as Label).text = str(d.get("era_name", "")).to_upper()
	(era_banner.find_child("era_sub", true, false) as Label).text = ("%d new era goals: see the card on the left." % ng) if ng > 0 else "A new chapter of the story begins."
	era_banner.visible = true
	_place_era_banner()
	era_banner.move_to_front()
	_era_banner_t = 6.0
	casual["era_banner"] = int(sim.state.era)


func _place_era_banner() -> void:
	## Top centre in the HUD's units, but never over the era goals card on the left (x 10-440): on a 16:10 or 4:3
	## screen the centre comes closer to it (layout-audit).
	if era_banner == null or hud_space == null:
		return
	var w := 660.0
	var x := hud_space.size.x * 0.5 - w * 0.5
	var left := 442.0
	if story_left != null and story_left.visible:
		left = maxf(left, story_left.get_rect().end.x)   # (the goals card grows wider than 430 with its content)
	if x < left + 2.0:
		x = left + 8.0
	if absf(era_banner.offset_left - x) > 0.5 or era_banner.anchor_left != 0.0:
		_place(era_banner, Vector2(0, 0), Vector2(0, 0), Rect2(x, 70, w, 0))


func minimap_shown() -> bool:
	## Story mode's minimap: on when the player commands units or settlement, or switched on in the Government menu.
	if not Unlocks.is_on(self, "minimap") and NextStep.is_auto(self, "units") and NextStep.is_auto(self, "settlement"):
		return false
	if not NextStep.is_auto(self, "units") or not NextStep.is_auto(self, "settlement"):
		return true
	return bool(casual.get("minimap_on", false))


func toggle_minimap() -> void:
	player_actions += 1
	casual["minimap_on"] = not bool(casual.get("minimap_on", false))
	_story_layout()
	_refresh_hud()


func gov_items() -> Array:
	## The Government menu (story mode): [panel id, label, icon] for every unlocked screen. One button on the HUD opens
	## this short list; only the NOW prompt stands alone (v4 fix round, new-player N3).
	var items := []
	if Unlocks.is_on(self, "report"): items.append(["cabinet_room", "Cabinet Room: your ministers", "unlock_policy"])
	if Unlocks.is_on(self, "budget") or Unlocks.is_on(self, "coalition"): items.append(["cabinet", "Cabinet", "unlock_policy"])
	if Unlocks.is_on(self, "treasury"): items.append(["fiscal", "Treasury", "gold"])
	if Unlocks.is_on(self, "programmes"): items.append(["programmes", "Programmes", "unlock_project"])
	if Unlocks.is_on(self, "standing"): items.append(["diplomacy", "Diplomacy", "diplomacy"])
	if Unlocks.is_on(self, "ghost"):
		items.append(["outlook", "Ending outlook", "star"])
		items.append(["ghost", "Against history: the six tracks", "star"])
	if Unlocks.is_on(self, "city_card"): items.append(["cities", "Cities", "cities"])
	if Unlocks.is_on(self, "research"):
		items.append(["research", "Research", "science"])
		items.append(["civic", "Civics", "culture"])
	if Unlocks.is_on(self, "policies"): items.append(["policy", "Policies", "civics_columns"])
	if Unlocks.is_on(self, "trade"): items.append(["trade", "Trade", "trade"])
	if Unlocks.is_on(self, "minimap") and NextStep.is_auto(self, "units") and NextStep.is_auto(self, "settlement"):
		items.append(["minimap", "Hide the minimap" if bool(casual.get("minimap_on", false)) else "Show the minimap", "cities"])
	# v4polish: what story mode's short Game menu no longer lists (every era's goals, the event log and the quarter's
	# history; the terms and the stat changes are tabs of Against history)
	if not items.is_empty():
		if Unlocks.is_on(self, "goals"): items.append(["goals_list", "Era goals: every era", "star"])
		items.append(["log", "Event log and this quarter in history", "unlock_policy"])
	return items


func _story_bar_build(city_card: bool) -> void:
	for c in story_bar.get_children():
		story_bar.remove_child(c)
		c.queue_free()
	var items := gov_items()
	gov_btn = null
	var was_open := gov_menu != null and gov_menu.visible
	if gov_menu != null:
		gov_menu.queue_free()
		gov_menu = null
	if not items.is_empty():
		gov_btn = UITheme.button("Government ▴", toggle_gov_menu, 16)
		gov_btn.icon = UIKit.icon("unlock_policy")
		gov_btn.expand_icon = true
		gov_btn.add_theme_constant_override("icon_max_width", 24)
		gov_btn.custom_minimum_size = Vector2(0, 42)
		gov_btn.add_theme_stylebox_override("normal", UITheme.sb(Color(0.05, 0.10, 0.22, 0.95), UIKit.GOLD, 1, 8, 8))
		gov_btn.add_theme_stylebox_override("hover", UITheme.sb(Color(0.10, 0.20, 0.40, 0.98), UIKit.GOLD_LIGHT, 1, 8, 8))
		gov_btn.tooltip_text = "Your government's screens: the Cabinet Room, the Treasury, programmes, diplomacy and how you stand against history."
		gov_btn.name = "gov_menu_btn"
		story_bar.add_child(gov_btn)
		gov_menu = PanelContainer.new()
		gov_menu.name = "GovMenu"
		gov_menu.add_theme_stylebox_override("panel", UITheme.sb(Color(0.03, 0.07, 0.16, 0.98), UIKit.GOLD_LIGHT, 2, 8, 8))
		gov_menu.mouse_filter = Control.MOUSE_FILTER_STOP
		var v := VBoxContainer.new()
		v.add_theme_constant_override("separation", 4)
		gov_menu.add_child(v)
		for it in items:
			var pid := str(it[0])
			var b := UITheme.button(str(it[1]), func(): gov_pick(pid), 16)
			b.icon = UIKit.icon(str(it[2]))
			b.expand_icon = true
			b.add_theme_constant_override("icon_max_width", 22)
			b.alignment = HORIZONTAL_ALIGNMENT_LEFT
			b.custom_minimum_size = Vector2(300, 36)
			b.name = "bar_" + pid
			v.add_child(b)
		gov_menu.visible = false
		hud_space.add_child(gov_menu)   # (the HUD's units: layout-audit)
	_place(story_bar, Vector2(0, 1), Vector2(0, 1), Rect2(400.0 if city_card else 10.0, -62, 0, 44))
	if was_open and gov_menu != null:
		toggle_gov_menu()   # (the list stays open across a redraw)


func toggle_gov_menu() -> void:
	if gov_menu == null:
		return
	gov_menu.visible = not gov_menu.visible
	if gov_menu.visible:
		var h := gov_menu.get_combined_minimum_size().y
		var x0 := story_bar.offset_left
		_place(gov_menu, Vector2(0, 1), Vector2(0, 1), Rect2(x0, -62.0 - 8.0 - h, 320, h))
		gov_menu.move_to_front()
		_hide_intro()


func gov_pick(pid: String) -> void:
	## A Government menu item: the list closes and its screen opens.
	if gov_menu != null:
		gov_menu.visible = false
	if pid == "minimap":
		toggle_minimap()
		return
	if pid == "goals_list":
		_show_goals_list()
		return
	open_panel(pid)


func queue_intro(id: String, text: String) -> void:
	if tutorial != null and tutorial.active and tutorial.story_tut and id in Tutorial.COVERED_INTROS:
		return   # (the story tutorial has its own card for it)
	if id == "treasury" and (intros_seen as Dictionary).has("overdraft"):
		text = "The Treasury now has its own screen in the Government menu: its running costs and Finance's levers."   # (the overdraft strip already said what to do)
	_intro_q.append([id, text, sim.state.turn if sim != null else 0])


func flush_intros() -> void:
	## Shows every waiting introduction at once (tests: the strip otherwise waits its few seconds per line).
	while not _intro_q.is_empty():
		var it: Array = _intro_q.pop_front()
		intro_log.append([str(it[0]), sim.state.turn if sim != null else 0])
		intro_lbl.text = str(it[1])
	if intro_w != null:
		intro_w.visible = false


const INTRO_SECS := 7.0            # an introduction stays this long, unless the player acts or ends the turn first
const INTRO_GAP := 1.2             # the pause before the next one
var intro_shown_id := ""           # the introduction on the strip now ("" = none) (tests)
var _intro_gap := 0.0


func _hide_intro() -> void:
	## v4 fix round (new-player N3, veteran m9): the strip shows each introduction once and then clears: after a few
	## seconds, when the player acts, or on End Turn. It never stays over a window.
	if intro_w != null and intro_w.visible:
		intro_w.visible = false
		_intro_gap = INTRO_GAP
	intro_shown_id = ""


func _intro_blocked() -> bool:
	## A window is open (the Cabinet Room, a panel, the Government menu): the strip waits rather than cover it.
	if gov_menu != null and gov_menu.visible:
		return true
	for w in [room_w, cabinet_p, settings_w, popup, info_p, prog_w, fiscal_w, diplo_w, ghost_p, policy_p, help, pedia, save_w, end_s, city_s, tree_w]:
		if w != null and w.visible:
			return true
	return false


func _intro_tick(delta: float) -> void:
	if intro_w == null:
		return
	if intro_w.visible:
		if not is_story() or _intro_blocked():
			_hide_intro()
			return
		_intro_t -= delta
		if _intro_t <= 0.0:
			_hide_intro()
		else:
			_intro_place()
		return
	if _intro_gap > 0.0:
		_intro_gap -= delta
		return
	if _intro_q.is_empty() or not is_story() or sim == null or _intro_blocked():
		return
	# an introduction queued two quarters ago or more is stale (a fast-forward, a long tutorial): it is dropped
	while not _intro_q.is_empty() and _intro_q[0].size() > 2 and int(_intro_q[0][2]) < sim.state.turn - 1:
		var old: Array = _intro_q.pop_front()
		intro_log.append([str(old[0]), int(old[2])])   # (its element unlocked then; the strip skipped its line)
	if _intro_q.is_empty():
		return
	var it: Array = _intro_q.pop_front()
	intro_lbl.text = str(it[1])
	intro_log.append([str(it[0]), sim.state.turn])
	intro_shown_id = str(it[0])
	_intro_t = INTRO_SECS * (1.8 if str(it[0]) == "overdraft" else 1.0)   # (the overdraft strip has three sentences to read)
	intro_w.visible = true
	_intro_place()
	intro_w.move_to_front()


func _intro_place() -> void:
	## v4polish (new-player t01, item 10): the strip sits above the NOW card and whatever stacks on it (chips, the
	## auto-advance bar), measured from their real rects, and grows upwards, so it never covers the card or Decide.
	intro_w.grow_vertical = Control.GROW_DIRECTION_BEGIN
	intro_w.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	var h := intro_w.get_combined_minimum_size().y
	if next_w == null or not next_w.visible:
		_place(intro_w, Vector2(1, 1), Vector2(1, 1), Rect2(-510.0, -130.0 - h, 500.0, h))
		return
	var cr: Rect2 = next_w.card.get_rect()
	var top := cr.position.y
	if next_w.chips.visible and next_w.chips.get_child_count() > 0:
		top = minf(top, next_w.chips.get_rect().position.y)
	if next_w.auto_bar.visible:
		top = minf(top, next_w.auto_bar.get_rect().position.y)
	var w := maxf(500.0, intro_w.get_combined_minimum_size().x)
	_place(intro_w, Vector2(0, 0), Vector2(0, 0), Rect2(cr.end.x - w, top - 8.0 - h, w, h))


func intro_overlaps_now() -> bool:
	## The Cabinet Secretary's strip covers the NOW card or its button (tests; it never should).
	if intro_w == null or not intro_w.visible or next_w == null or not next_w.visible:
		return false
	var ir := intro_w.get_global_rect().grow(-1.0)
	return ir.intersects(next_w.card.get_global_rect()) or ir.intersects(next_w.go_btn.get_global_rect())


func _story_tile_click(q: int, r: int) -> bool:
	## Story mode's map clicks: city banners are labels until "Your cities" unlocks (turn 3), then a read-only view
	## while the production minister runs the cities; unit flags only once the player commands units. true = handled.
	var p := Vector2i(q, r)
	var bc = _banner_city_at_mouse()
	if bc == null:
		var c0 = sim.city_at(p)
		if c0 != null and c0.active:
			bc = c0
	if bc != null and not (selected_unit >= 0 and _targets.has(p)):
		if not Unlocks.is_on(self, "city_view"):
			return true
		if NextStep.is_auto(self, "production"):
			_story_city_view(bc.id)
			return true
		return false
	if not Unlocks.is_on(self, "units"):
		select_unit(-1)
		return true
	return false


func _story_city_view(cid: int) -> void:
	var c := sim.get_city(cid)
	if c.is_empty():
		return
	player_actions += 1
	hud_city = cid
	var cc := _city_card()
	var list := _info(str(c["name"]))
	list.add_child(UITheme.label("Population %s" % str(cc.get("population", c["pop"])), 18, UIKit.GOLD_LIGHT, "body_bold"))
	list.add_child(UITheme.label("Building: %s%s" % [str(cc.get("building", "")), ("  (%s)" % UITheme.turns(int(cc.get("building_turns", 0)))) if int(cc.get("building_turns", 0)) > 0 else ""], 17))
	list.add_child(UITheme.label("%s: %s" % [str(cc.get("food_label", "Food surplus")), str(cc.get("food", ""))], 17))
	list.add_child(UITheme.label("Housing: %s" % str(cc.get("housing", "")), 17))
	list.add_child(UITheme.rich("[color=#a8b0c4]The %s chooses what %s builds. Take production over to choose yourself.[/color]" % [NextStep.minister_label(sim, "production"), str(c["name"])], 15))
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	list.add_child(h)
	h.add_child(UITheme.button("Take over production", func(): info_p.visible = false; set_domain_auto("production", false), 16))
	h.add_child(UITheme.button("Open the city screen", func(): info_p.visible = false; open_city(cid, true), 16))
	_refresh_hud()


func _show_goals_list() -> void:
	## Every era's goals with their status (the menu's "Era goals"; the HUD card shows the current era's).
	if sim == null:
		return
	var list := _info("Era goals")
	var eras: Array = []
	var g = sim.get("goals")
	if g is Object and (g as Object).has_method("all"):
		var a = g.all()
		if a is Array:
			eras = a   # one view per era
	if eras.is_empty():
		eras = [GoalsCard.view(sim)]
	var n_goals := 0
	for ev in eras:
		var gl: Array = (ev as Dictionary).get("goals", []) if ev is Dictionary else []
		if gl.is_empty():
			continue
		list.add_child(UITheme.section(str(ev.get("era_name", "")).to_upper()))
		for x in gl:
			n_goals += 1
			var st := str(x.get("status", "active"))
			var mark: String = {"met": "✓", "missed": "✗"}.get(st, "○")
			var h := HBoxContainer.new()
			h.add_theme_constant_override("separation", 10)
			list.add_child(h)
			h.add_child(UITheme.label(mark, 17, UIKit.GOLD_LIGHT if st == "met" else UIKit.TEXT, "body_bold"))
			var tl := UITheme.label(str(x.get("title", "")), 17, UIKit.GOLD_LIGHT if st == "met" else UIKit.TEXT, "body_bold")
			tl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			h.add_child(tl)
			h.add_child(UITheme.label(str(x.get("deadline_label", "")), 15, UIKit.GOLD))
			if str(x.get("history", "")) != "":
				list.add_child(UITheme.rich("[color=#a8b0c4]%s[/color]" % str(x["history"]), 15))
			var sub := str(x.get("reward_text", "")) if st != "missed" else str(x.get("setback_text", ""))
			if sub != "":
				list.add_child(UITheme.label(("Reward: %s" if st != "missed" else "Setback: %s") % sub, 15, UIKit.GOLD))
	if n_goals == 0:
		list.add_child(UITheme.label("This era's goals arrive with its briefing.", 16, UIKit.TEXT_DIM))
