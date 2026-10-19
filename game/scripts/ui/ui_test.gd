class_name UITest
extends Node
## Plays turns through the UI code paths (HUD button, panels, rows, unit clicks) and screenshots each new screen.
##   bash tools/shot.sh <any.png> --ui-test=<abs dir> [--ui-test-turns=20]
## (shot.sh's own --shot is ignored by this mode; the test quits when done.)

var ui
var dir := ""
var n := 0
var log_lines: Array = []
var seen := {}
var failures: Array = []


func _frames(k: int) -> void:
	for i in k:
		await get_tree().process_frame


func shot(tag: String) -> void:
	_i18n_scan(tag)
	if DisplayServer.get_name() == "headless":
		n += 1
		log_lines.append("(headless, no pixels) %02d_%s" % [n, tag])
		return
	await _frames(3)
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	n += 1
	var p := "%s/%02d_%s.png" % [dir, n, tag]
	img.save_png(p)
	print("UITEST SHOT ", p)
	log_lines.append(p)


func say(s: String) -> void:
	print("UITEST ", s)
	log_lines.append(s)


func run(u, d: String) -> void:
	ui = u
	dir = d
	DirAccess.make_dir_recursive_absolute(dir)
	if DisplayServer.get_name() == "headless":
		# the headless window is 64x64; lay the UI out as on a 16:9 screen (1280x720, 1672x941 and 1920x1080 all
		# give the same 1672x941 layout under the canvas_items stretch), so layout checks mean something
		get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	var sd := SaveSlots.dir()   # user://saves_test/ in test runs: start with no slots or autosaves
	if DirAccess.dir_exists_absolute(sd):
		for fn in DirAccess.get_files_at(sd):
			DirAccess.remove_absolute(sd + fn)
	var turns := 20
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--ui-test-turns="):
			turns = int(a.substr(16))
	# v4: --ui-test-style=full|story. Every v3 suite plays Full control (the v3 game) unless it says otherwise.
	ui.test_style = "full"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--ui-test-style="):
			ui.test_style = "story" if a.substr(16) == "story" else "full"
	if "--ui-test-layout" in OS.get_cmdline_user_args():
		ui.harness_begin()   # (windowed: capture.gd's --shot waits for the layout audit instead of quitting after 90 frames)
	await _frames(40)
	if "--ui-test-perf" in OS.get_cmdline_user_args():   # perf60: the stutter scenario (scripts/ui/ui_test_perf.gd)
		await PerfRun.run(self)
		return
	if "--ui-test-daynight" in OS.get_cmdline_user_args():   # v5 day / night check (scripts/ui/ui_test_daynight.gd)
		await DayNightCheck.run(self)
		return
	if "--ui-test-layout" in OS.get_cmdline_user_args() or "--ui-test-layout-quick" in OS.get_cmdline_user_args():   # layout-audit: HUD vs panels at every screen and UI scale (scripts/ui/ui_test_layout.gd)
		await LayoutAudit.run(self)
		return
	if "--ui-test-casual-end" in OS.get_cmdline_user_args():
		await run_casual_end()
		return
	if "--ui-test-casual-scenarios" in OS.get_cmdline_user_args():
		await run_casual_scenarios(turns if _has_arg("--ui-test-turns=") else 3)
		return
	if "--ui-test-casual" in OS.get_cmdline_user_args():
		await run_casual(turns if _has_arg("--ui-test-turns=") else 40)
		return
	if "--ui-test-tutorial" in OS.get_cmdline_user_args():
		await run_tutorial(turns)
		return
	if "--ui-test-end" in OS.get_cmdline_user_args():
		await run_end()
		return
	if "--ui-test-stings" in OS.get_cmdline_user_args():
		await run_stings()
		return
	if "--ui-test-v2" in OS.get_cmdline_user_args():
		await run_v2(turns)
		return
	if "--ui-test-v3" in OS.get_cmdline_user_args():
		await run_v3(turns)
		return
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--ui-test-scenarios"):   # --ui-test-scenarios[=start_1967,start_1977] [--ui-test-turns=N]
			await run_scenarios(a.substr(20).split(",", false) if a.contains("=") else PackedStringArray(), turns)
			return
	ui._show_start()
	await _frames(20)
	await shot("start_screen")
	await check_i18n_start()
	ui.show_help()
	await _frames(5)
	await shot("how_to_play")
	var ht := HelpOverlay.all_text().to_lower()
	for need in ["fork", "state budget", "minister", "coalition", "front", "inflation", "debt", "civilopedia", "save", "mid-year review", "immigra",
			"secure state", "a nation ahead", "ending outlook", "fiscal collapse", "collapse of public trust", "military collapse", "envoy", "delegation",
			"national programmes", "difficulty", "historian", "scenario", "i diplomacy", "o ending outlook", "memorial"]:   # v3 onboarding (fix3-ui)
		if not ht.contains(need):
			failures.append("How to Play does not cover '%s'" % need)
	_check_min_font(ui.help, "How to Play")
	if he_run():   # every How to Play page and every tutorial / advisor card text, not only the two shot here
		for pi in HelpOverlay.PAGES.size():
			ui.help.show_page(pi)
			await _frames(2)
			_i18n_scan("how_to_play_page_%d" % pi)
		var cards := []
		for st in Tutorial.STEPS + Tutorial.STEPS_STORY:
			for k in ["title", "text", "todo", "wait"]:
				if str(st.get(k, "")) != "": cards.append(V3Adapter.endify(str(st[k])))
			cards.append("Next: %s." % str(st["title"]))
		for tk in Tutorial.TIPS:
			cards.append(str(Tutorial.TIPS[tk]["title"])); cards.append(str(Tutorial.TIPS[tk]["text"]))
		var cm := {}
		for ct in cards:
			for m in L10n.audit(ct): cm[m] = true
		if not cm.is_empty():
			i18n_by_screen["tutorial and advisor cards"] = cm.keys()
	ui.help.show_page(_help_page("Money: debt and inflation"))
	await _frames(3)
	await shot("how_to_play_money")
	ui.help.close()
	var nb := _find_button(ui.start_screen, "New Game")
	if nb == null:
		failures.append("no New Game button")
		_finish()
		return
	nb.pressed.emit()
	await _frames(5)
	await check_new_game_setup()
	var fb := _find_button(ui.start_screen, "Full game")
	if fb == null:
		failures.append("no Full game button")
		_finish()
		return
	fb.pressed.emit()
	await _frames(120)
	await shot("t1_start")
	if ui.sim.has_method("get_difficulty") and str(ui.sim.get_difficulty().get("id", "")) != "normal":
		failures.append("new game: difficulty is %s, not the chosen Normal" % str(ui.sim.get_difficulty().get("id", "")))
	await v2_checks()
	await v3_checks()
	await play_turns(turns)
	await fix3_checks()
	check_he_runtime()   # fix4-ui: runtime-composed Hebrew text (her M1-M5)
	await check_fix4_layout()
	check_audio_hooks()
	_check_autosaves()
	await shot("final_hud")
	ui.open_panel("ghost"); await _frames(5); await shot("ghost_final"); ui.ghost_p.close()
	var t_end: int = ui.sim.state.turn
	ui.quick_load()
	await _frames(90)
	say("quick-load: turn %d -> %d (%s)" % [t_end, ui.sim.state.turn, ui.sim.date_label()])
	await shot("after_quickload")
	await check_continue()
	_finish()


func play_turns(turns: int) -> void:
	for t in turns:
		var guard := 0
		var last := ""
		var repeats := 0
		while guard < 120:
			guard += 1
			var a: Dictionary = ui.sim.next_action()
			var key := "%s:%s" % [a["type"], str(a.get("event", a.get("city", a.get("unit", ""))))]
			await _tips()
			if a["type"] == "end_turn":
				break
			repeats = repeats + 1 if key == last else 0
			last = key
			if repeats >= 3:
				failures.append("T%d stuck on %s" % [ui.sim.state.turn, key])
				say("STUCK on " + key + " - forcing via sim")
				_force(a)
				continue
			await _resolve(a)
		if not seen.has("combat_preview"):
			await try_combat_preview()
		if ui.sim.state.turn == 3 and not seen.has("ghost"):
			seen["ghost"] = true
			ui.open_panel("ghost"); await _frames(5); await shot("ghost_panel"); ui.ghost_p.close()
		if ui.sim.state.turn == 4 and not seen.has("policy"):
			seen["policy"] = true
			ui.open_panel("policy"); await _frames(5); await shot("policy_panel"); ui.policy_p.close()
		if ui.sim.state.turn == 6:
			ui.quick_save()
			say("quick-saved at %s" % ui.sim.date_label())
		if t % 5 == 4:
			await shot("hud_%s" % ui.sim.date_label().replace(" ", "_"))
		var before: int = ui.sim.state.turn
		ui.hud.last_shift = false
		ui._on_next_pressed()
		await _frames(30)
		if ui.sim.state.turn == before:
			failures.append("end turn did not advance at T%d" % before)
			say("end turn did not advance: " + str(ui.sim.next_action()))
			ui.end_turn(true)
			await _frames(30)
		say("turn %d -> %s, cities %d, techs %d, civics %d, gold %d" % [before, ui.sim.date_label(), ui.sim.active_cities().size(), ui.sim.state.techs.size(), ui.sim.state.civics.size(), int(ui.sim.state.gold)])
		# close the auto popups (digest) at turn start but screenshot the first one
		await _frames(60)
		if ui.popup.visible and ui.popup.mode == "digest":
			if not seen.has("digest"):
				seen["digest"] = true
				await shot("digest")
			var cb := _find_button(ui.popup, "Continue")
			if cb: cb.pressed.emit()
			await _frames(3)


var tips_seen := {}


func _tips() -> void:
	## Contextual advisor cards (after a taken tutorial): each may show once; screenshot the first of each.
	var tut: Tutorial = ui.tutorial
	await _frames(1)
	tut._tip_check()
	if tut.tip == "":
		return
	var id := tut.tip
	if tips_seen.has(id):
		failures.append("advisor tip %s shown twice" % id)
	tips_seen[id] = true
	say("advisor tip: %s at %s" % [id, ui.sim.date_label()])
	if tips_seen.size() == 1 and ui.sim.state.turn == 1 and not (id in ["crisis", "front"]):
		failures.append("the first advisor card on turn 1 is %s, not the war" % id)
	await _frames(3)
	if tut.card.visible and tut._home_window() == null and tut._windows().size() > 0:
		failures.append("tip %s shown over an unrelated window (%s)" % [id, tut._windows()[0].name])
	if tut._show.visible:
		tut._show.pressed.emit()   # open the screen it explains: the card docks beside it
		await _frames(6)
	var home: Control = tut._home_window()
	if home != null:
		_check_card_beside(tut, home, "tip " + id)
	await shot("advisor_%s" % id)
	tut._primary.pressed.emit()
	await _frames(2)


func check_collapse_end() -> void:
	## v3 item 13 (fix-v3a): a collapse of the state ends the game early: no 7 October memorial, the end screen shows
	## the collapse and its "what went wrong" epilogue, and the danger shows on the top bar and the Ending outlook first.
	ui.start_new_game(true)
	await _frames(20)
	for i in 3:
		ui.harness_end_turn()
		await _frames(4)
	ui.sim.collapse.debug_set("collapse_fiscal", 3)
	ui._refresh_all()
	await _frames(6)
	var items: Array = ui.hud.live.get("top_items", [])
	if not items.any(func(it): return str(it[0]) == "danger"):
		failures.append("collapse: no DANGER item on the top bar while a collapse is in danger")
	ui.open_ghost_tab("endings")
	await _frames(6)
	if not _has_text(ui.ghost_p, "RISKS TO THE STATE") or not _has_text(ui.ghost_p, "Fiscal Collapse"):
		failures.append("collapse: the Ending outlook does not show the collapse in danger")
	await shot("collapse_warning")
	ui.ghost_p.close()
	ui.last_memorial_text = ""
	ui.sim.collapse.debug_end("collapse_fiscal")
	ui.sim.state.game_over = true
	ui.sim.game_over.emit(ui.sim.score.final_summary())
	await _frames(20)
	if ui.last_memorial_text != "":
		failures.append("collapse: the 7 October memorial was shown after a collapse")
	if not ui.end_s.visible:
		failures.append("collapse: the results screen did not open")
	var txt := ""
	for l in ui.end_s.find_children("*", "RichTextLabel", true, false):
		txt += (l as RichTextLabel).get_parsed_text() + "\n" + (l as RichTextLabel).text + "\n"
	for l in ui.end_s.find_children("*", "Label", true, false):
		txt += (l as Label).text + "\n"
	for need in ["What went wrong", "FISCAL COLLAPSE", "THE SIX TRACKS"]:
		if txt.find(need) < 0 and txt.find(L10n.t(need)) < 0:
			failures.append("collapse end screen lacks '%s'" % need)
	if txt.find("never forget") >= 0:
		failures.append("collapse end screen shows memorial text")
	await shot("collapse_end")
	say("collapse ending: end screen %s, memorial %s" % ["open" if ui.end_s.visible else "closed", "not shown" if ui.last_memorial_text == "" else "SHOWN"])
	ui.end_s.close()
	if ui.tutorial and ui.tutorial.tip == "collapse":
		ui.tutorial._close_tip()
	await _frames(5)


func run_end() -> void:
	## Plays a full game to Q3 2023 (autoplayer, UI fast path), then exercises the end screen: content,
	## "Keep viewing the map", reopening, "Return to start", and a new game from the title screen.
	## First loads a divergent end save (a player who went their own way: 128 ledger rows, long reasons) and
	## checks the end screen fits the screen: --ui-test-end-save=<path> (default: the v2 critic's run).
	await check_end_divergent()
	await check_collapse_end()
	check_he_runtime()
	if "--ui-test-quick" in OS.get_cmdline_user_args():
		_finish()
		return
	ui._show_start()
	await _frames(10)
	_find_button(ui.start_screen, "New Game").pressed.emit()
	await _frames(5)
	_find_button(ui.start_screen, "Full game").pressed.emit()
	await _frames(30)
	var t0 := Time.get_ticks_msec()
	ui.fast_forward(V3Adapter.last_turn(ui.sim) + 1)   # the sim's configured last turn
	await _frames(30)
	say("fast-forward to %s in %d ms, game_over=%s" % [ui.sim.date_label(), Time.get_ticks_msec() - t0, str(ui.sim.state.game_over)])
	if not ui.sim.state.game_over:
		failures.append("game did not end")
	if not ui.end_s.visible:
		failures.append("end screen did not open on game_over")
	# the 7 October 2023 memorial comes first, word for word from data/ending_oct7.json (never in the demo)
	if MemorialScreen.applies(ui.sim):
		var md := MemorialScreen.load_data(ui.sim)
		var want := "\n\n".join(PackedStringArray(md.get("paragraphs", []) + [md.get("closing", "")]))
		if ui.last_memorial_text != want:
			failures.append("memorial text not shown verbatim")
		else:
			say("memorial shown verbatim (%d chars)" % want.length())
	ui.end_s.set_all_open(true)   # the path ledger's decades are folded by default (fix4-ui): read every row
	await _frames(4)
	var txt := ""
	for l in ui.end_s.find_children("*", "RichTextLabel", true, false):
		txt += (l as RichTextLabel).get_parsed_text() + "\n"
		if L10n.lang != "en":   # Hebrew run: the checks below read the English source
			txt += (l as RichTextLabel).text + "\n"
	for l in ui.end_s.find_children("*", "Label", true, false):
		txt += (l as Label).text + "\n"
	for need in ["THE SIX TRACKS", "OVER TIME", "YOUR PATH", "Population", "Economy"]:
		if txt.find(need) < 0:
			failures.append("end screen lacks '%s'" % need)
	var raw_span := RegEx.new()
	raw_span.compile("\\b([1-9]\\d{0,2})[-–]([1-9]\\d{0,2})\\b(?![%\\d])")
	for m in raw_span.search_all(txt):
		if int(m.get_string(1)) < 400 and int(m.get_string(2)) < 400 and int(m.get_string(2)) > int(m.get_string(1)) + 1:
			failures.append("raw turn span in ledger: " + m.get_string(0) + "  in: ..." + txt.substr(maxi(0, m.get_start() - 80), 120).replace("\n", " | "))
			break
	var own_n := 0
	for e in ui.sim.get_path_ledger():
		if not UITheme.ledger_matched(e):
			own_n += 1
	if own_n > 0 and txt.find("your own path") < 0:
		failures.append("ledger has %d own-path decisions but the end screen shows none" % own_n)
	say("ledger: %d own-path decisions" % own_n)
	say("end screen text sample: " + txt.substr(0, 600).replace("\n", " | "))
	await check_end_layout("AI end, every decade open")
	await shot("end_ledger_open")
	ui.end_s.set_all_open(false)
	await _frames(4)
	await check_end_layout("AI end")
	_check_end_dates("AI end")
	if ui.sim.has_method("get_epilogue"):
		var ep: Dictionary = ui.sim.get_epilogue()
		if txt.find("EPILOGUE") < 0:
			failures.append("end screen lacks the epilogue")
		elif str(ep.get("name", "")) != "" and txt.find(str(ep.get("name", "")).to_upper()) < 0:
			failures.append("end screen does not name the ending reached (%s)" % str(ep.get("name", "")))
		if txt.find("THE ENDINGS AT THE END") < 0:
			failures.append("end screen lacks the endings' thresholds")
		say("ending reached: %s; epilogue %d paragraphs" % [str(ep.get("name", "")), (ep.get("paragraphs", []) as Array).size()])
		await shot("end_epilogue")
	# the end screen at 150% UI scale still fits and scrolls
	GameSettings.ui_scale = 1.5
	GameSettings.apply_scale()
	ui.show_end_screen()
	await _frames(8)
	await check_end_layout("AI end at 150%")
	if ui.end_s.scale.x < 1.3:
		failures.append("end screen at 150%%: drawn at %.2f" % ui.end_s.scale.x)
	await shot("end_screen_150")
	GameSettings.ui_scale = 1.0
	GameSettings.apply_scale()
	await _frames(4)
	ui.sim.save_game("user://end_state.json")
	say("end state saved to " + ProjectSettings.globalize_path("user://end_state.json"))
	await shot("end_screen")
	var kb := _find_button(ui.end_s, "Keep viewing")
	if kb == null:
		failures.append("no Keep viewing button")
	else:
		kb.pressed.emit()
		await _frames(3)
		if ui.end_s.visible:
			failures.append("Keep viewing did not close the end screen")
	ui.hud.last_shift = false
	var t_end: int = ui.sim.state.turn
	ui._on_next_pressed()   # after the end the button reads GAME OVER and reopens the summary
	await _frames(3)
	if not ui.end_s.visible or ui.sim.state.turn != t_end:
		failures.append("GAME OVER button did not reopen the end screen (or advanced)")
	ui.end_s.close()
	await _frames(2)
	ui.open_panel("end")
	await _frames(3)
	if not ui.end_s.visible:
		failures.append("open_panel(end) did not reopen")
	var rb := _find_button(ui.end_s, "Return to start")
	if rb == null:
		failures.append("no Return to start button")
	else:
		rb.pressed.emit()
		await _frames(10)
		if ui.start_screen == null or ui.started:
			failures.append("Return to start did not show the title screen")
		else:
			_find_button(ui.start_screen, "New Game").pressed.emit()
			await _frames(5)
			_find_button(ui.start_screen, "Full game").pressed.emit()
			await _frames(30)
			if ui.sim == null or ui.sim.state.turn != 1:
				failures.append("new game after the end did not start at turn 1")
			else:
				await play_turns(2)
	_finish()


func check_fix4_layout() -> void:
	## fix4-ui: the top bar's era name is never cut (a long name takes two lines or its short form); the notification
	## rail ends above an open advisor card; world labels skip the rail, the sidebar and the advisor card.
	var hud = ui.hud
	var keep = hud.live.get("era", "")
	var cut := []
	var drawn := 0
	for era in ["Immigration from the Former USSR and the Oslo Process", "Political Change and Stabilization", "High-Tech Growth and the Second Intifada", str(keep)]:
		hud.live["era"] = era
		hud.era_drawn = []
		hud.queue_redraw()
		await _frames(2)
		if not (hud.era_drawn as Array).is_empty():
			drawn += 1
			if " ".join(hud.era_drawn).contains("…"):
				cut.append("%s -> %s" % [era, str(hud.era_drawn)])
	hud.live["era"] = keep
	hud.queue_redraw()
	if not cut.is_empty():
		failures.append("top bar: the era name is cut: " + " | ".join(cut))
	say("top bar era names: %s" % ("%d drawn, none cut" % drawn if drawn > 0 else "not drawn in this mode (headless)"))
	# the rail against an advisor card (show one: the deficit tip sits elsewhere, so use the plain card position)
	var tut: Tutorial = ui.tutorial
	ui.rail.set_items([{"kind": "event", "text": "Treasury", "turn": ui.sim.state.turn}, {"kind": "event", "text": "Revenue", "turn": ui.sim.state.turn}])
	var was_visible: bool = tut.card.visible
	var was_tip: String = tut.tip
	tut.tip = "fix4_layout_check"   # a plain advisor tip: the card sits beside the decision button, left of the minimap
	tut.card.visible = true
	tut._place_card()
	await _frames(4)
	ui._fit_rail()
	await _frames(3)
	var cr: Rect2 = tut.card.get_global_rect()
	var hit := []
	for c in ui.rail.get_children():
		if tut.card.is_visible_in_tree() and c is Control and (c as Control).is_visible_in_tree() and (c as Control).get_global_rect().intersects(cr.grow(-2)):
			hit.append(str((c as Control).get_global_rect()))
	if not hit.is_empty():
		failures.append("the advisor card %s covers notification cards %s" % [str(cr), ", ".join(hit)])
	ui._label_occluders()
	var ov = ui.game.get("overlay") if ui.game != null else null
	var occ_n: int = (ov.occluders as Array).size() if ov != null else -1
	say("rail vs advisor card: card %s (%s), rail bottom offset %d, %d overlaps; map-label occluders %d" % [str(cr), "shown" if tut.card.is_visible_in_tree() else "hidden by a window", int(ui.rail.offset_bottom), hit.size(), occ_n])
	if ov != null and occ_n <= 5:
		failures.append("map labels: the rail and the advisor card are not occluders (%d rects)" % occ_n)
	tut.tip = was_tip
	tut.card.visible = was_visible
	ui.rail.set_items([])
	ui._fit_rail()


# ================================================================== --ui-test-stings (fix4-ui, var N9)

const STING_KINDS := ["research", "era", "war", "peace", "election", "government", "fork", "game_end"]


func run_stings() -> void:
	## A fast-forwarded full game through the UI's own audio wiring, without sound (UIAudio stays muted, so the
	## AudioDirector is never called): the sim's signals queue stingers in game_ui (_sting), forks and envoys are answered
	## through the UI's own choose_fork / choose_diplomacy (history's option), and after every turn the real
	## game_ui._flush_audio() picks the quarter's stinger. Logs every stinger asked for and fails if a kind never
	## fires. --ui-test-turns=N stops after N turns (then game_end is not expected).
	var limit := 100000
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--ui-test-turns="):
			limit = int(a.substr(16))
	ui._show_start()
	await _frames(10)
	_find_button(ui.start_screen, "New Game").pressed.emit()
	await _frames(5)
	_find_button(ui.start_screen, "Full game").pressed.emit()
	await _frames(30)
	var sim = ui.sim
	UIAudio.sting_log.clear()
	var queued := {}
	var played := {}
	var first := {}
	var lines: Array = []
	var t0 := Time.get_ticks_msec()
	var n_turns := 0
	var forks := 0
	var envoys := 0
	while not sim.state.game_over and n_turns < limit:
		var n0 := UIAudio.sting_log.size()   # this quarter: the fork / envoy answers, then the flush
		# the player's own decisions through the UI (their stingers), as history answered them
		for d in sim.blocking_decisions():
			if str(d.get("type", "")) == "fork":
				var fid := str(d.get("fork", ""))
				var oid := str(sim.forks.historical_option(fid)) if sim.get("forks") != null and sim.forks.has_method("historical_option") else ""
				if oid == "" and (d.get("options", []) as Array).size() > 0:
					oid = str(d["options"][0].get("id", ""))
				if fid != "" and oid != "":
					ui.choose_fork(fid, oid)
					forks += 1
					ui.popup.visible = false
		var dd: Dictionary = V3Adapter.diplo_decision(sim)
		if not dd.is_empty():
			var opts: Array = dd.get("options", [])
			var hi := 0
			for i in opts.size():
				if bool(opts[i].get("historical", false)):
					hi = i
			ui.choose_diplomacy(hi)
			envoys += 1
			ui.diplo_w.visible = false
		var before: int = sim.state.turn
		SimAI.play_turn(sim)
		if sim.state.turn == before and not sim.state.game_over:
			sim.end_turn(true)
		var q: Array = (ui._audio_q as Array).duplicate()
		for k in q:
			queued[k] = int(queued.get(k, 0)) + 1
		ui._flush_audio(false)   # the real per-turn flush (harness_end_turn and fast_forward skip it)
		ui._notes.clear()
		n_turns += 1
		var now: Array = UIAudio.sting_log.slice(n0)
		if not q.is_empty() or not now.is_empty():
			lines.append("%s  queued %s  played %s" % [sim.date_label(), str(q), str(now)])
	# everything the UI played this run (forks play at once, the quarter's flush plays one)
	for k in UIAudio.sting_log:
		played[k] = int(played.get(k, 0)) + 1
	await _frames(20)   # game over: the memorial (skipped in tests) and the results, which play game_end
	var tail: Array = UIAudio.sting_log.slice(0)
	var ge := tail.count("game_end")
	if ge > 0:
		played["game_end"] = ge
		lines.append("%s  played [\"game_end\"] (results)" % sim.date_label())
	# the first turn each kind played
	for ln in lines:
		for k in STING_KINDS:
			if not first.has(k) and str(ln).contains("played") and str(ln).substr(str(ln).find("played")).contains("\"%s\"" % k):
				first[k] = str(ln).split("  ")[0]
	var fl := FileAccess.open(dir + "/stings.txt", FileAccess.WRITE)
	if fl:
		fl.store_string("\n".join(lines))
	say("stings: %d turns to %s in %d s (game over %s), %d forks and %d envoys answered through the UI" % [n_turns, sim.date_label(), (Time.get_ticks_msec() - t0) / 1000, str(sim.state.game_over), forks, envoys])
	say("stings queued by the sim's signals: %s" % str(queued))
	say("stings played (UIAudio.sting, muted): %s" % str(played))
	say("stings first played: %s" % str(first))
	# the director's file for each kind (no sound: only the mapping and the file are checked)
	var d0 = UIAudio.director()
	if d0 != null and d0.get_script() != null:
		var cm: Dictionary = (d0.get_script() as Script).get_script_constant_map()
		var alias: Dictionary = cm.get("STING_ALIAS", {})
		var miss := []
		for k in STING_KINDS:
			var f := str(alias.get(k, k))
			if k == "game_end": f = "game_end_good"
			if not ResourceLoader.exists("res://assets/audio/stingers/%s.ogg" % f):
				miss.append("%s -> %s.ogg" % [k, f])
		if not miss.is_empty():
			failures.append("stings: no stinger file for " + ", ".join(miss))
		say("stings: AudioDirector maps %s" % str(STING_KINDS.map(func(k): return "%s->%s" % [k, alias.get(k, k)])))
	var need: Array = STING_KINDS.duplicate()
	if not sim.state.game_over:
		need.erase("game_end")
	for k in need:
		if int(played.get(k, 0)) == 0:
			failures.append("stings: '%s' never played in %d turns (queued %d times)" % [k, n_turns, int(queued.get(k, 0))])
	_finish()


const DIVERGENT_END :="C:/civ/progress/test_saves/end_q3_2023.json"   # a finished game (ends Q3 2023), made by a headless fast-forward


func check_end_divergent() -> void:
	var path := DIVERGENT_END
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--ui-test-end-save="):
			path = a.substr(19)
	if not FileAccess.file_exists(path):
		failures.append("divergent end save not found: " + path)
		return
	ui.quick_load(path)
	await _frames(30)
	if not ui.sim.state.game_over:
		failures.append("divergent end save is not a finished game")
	if not ui.end_s.visible:
		failures.append("divergent end save: the end screen did not open")
		return
	var own := 0
	for e in ui.sim.get_path_ledger():
		if not UITheme.ledger_matched(e):
			own += 1
	say("divergent end save %s: %s, %d ledger rows, %d own-path, %d reasons" % [path, ui.sim.date_label(), ui.sim.get_path_ledger().size(), own, (ui.sim.get_end_summary().get("reasons", []) as Array).size()])
	await check_end_layout("divergent end")
	_check_end_dates("divergent end")
	await shot("end_divergent")
	# every reason in full: still inside the screen (the scroll area takes it)
	var more := _find_button(ui.end_s, "Show all")
	if more == null:
		more = _find_button(ui.end_s, "Show in full")
	if more != null:
		more.pressed.emit()
		await _frames(8)
		await check_end_layout("divergent end, reasons in full")
		var fewer := _find_button(ui.end_s, "Show fewer")
		if fewer == null:
			failures.append("divergent end: no Show fewer after expanding the reasons")
		else:
			fewer.pressed.emit()
			await _frames(4)
	# the folded ledger: one line per decade; opening one shows its decisions, folding it hides them again (fix4-ui)
	var heads: Array = ui.end_s._inner.get_children().filter(func(c): return c is Button and c.has_meta("ledger_group"))
	if heads.is_empty():
		failures.append("divergent end: the path ledger has no decade headers")
	else:
		var n0: int = ui.end_s._inner.get_child_count()
		var h_closed: float = ui.end_s._inner.get_combined_minimum_size().y
		(heads[0] as Button).pressed.emit()
		await _frames(4)
		var n1: int = ui.end_s._inner.get_child_count()
		if n1 <= n0:
			failures.append("divergent end: opening the decade %s showed no decisions" % str((heads[0] as Button).get_meta("ledger_group")))
		await shot("end_divergent_decade_open")
		var h2: Array = ui.end_s._inner.get_children().filter(func(c): return c is Button and c.has_meta("ledger_group"))
		(h2[0] as Button).pressed.emit()
		await _frames(4)
		if ui.end_s._inner.get_child_count() != n0:
			failures.append("divergent end: folding the decade again left %d rows (was %d)" % [ui.end_s._inner.get_child_count(), n0])
		say("divergent end: %d decades folded, %d px folded (decade open: %d rows more)" % [heads.size(), int(h_closed), n1 - n0])
	# scroll to the bottom: the last ledger row is reachable and the buttons stay put
	var sc: ScrollContainer = ui.end_s._scroll
	sc.scroll_vertical = 1000000
	await _frames(4)
	await check_end_layout("divergent end, scrolled to the bottom")
	ui.end_s.close()
	await _frames(2)


func _check_end_dates(where: String) -> void:
	## V3 fixes A12 / B: the end screen names the real end (Q3 2023), never a later year, and its numbers agree.
	var title: String = ui.end_s.title_label.text
	var want := EndScreen.end_label(ui.sim).to_upper()
	if not bool(ui.sim.state.get("game_over")):
		return
	var collapsed := str(ui.sim.get_end_summary().get("collapse", "")) != ""
	if not collapsed and L10n.lang == "en" and title.find(want) < 0:
		failures.append("%s: end screen title '%s' does not name the end date %s" % [where, title, want])
	var txt := ""
	for l in ui.end_s.find_children("*", "RichTextLabel", true, false):
		txt += (l as RichTextLabel).get_parsed_text() + "\n"
	for bad in ["2024", "2025", "2026"]:
		if title.find(bad) >= 0 or txt.find("in " + bad) >= 0:
			failures.append("%s: end screen mentions %s" % [where, bad])
	var re := RegEx.create_from_string("Overall (\\d+)% of history's")
	var m := re.search(txt)
	var ep := RegEx.create_from_string("(?:at|stood at) (\\d+)% of history's record")
	var m2 := ep.search(txt)
	if m != null and m2 != null and m.get_string(1) != m2.get_string(1):
		failures.append("%s: header %s%% against the epilogue's %s%%" % [where, m.get_string(1), m2.get_string(1)])
	say("%s: title '%s'%s" % [where, title, (", header %s%% / epilogue %s%%" % [m.get_string(1), m2.get_string(1)]) if m != null and m2 != null else ""])


const END_MAX_SCROLL := 6000.0


func check_end_layout(where: String) -> void:
	## The end screen inside the viewport: title, verdict and the three buttons visible; reasons capped; text >= 12 px at 720p.
	await _frames(6)
	var vp: Rect2 = ui.end_s.get_viewport_rect()
	var es: UIWindow = ui.end_s
	var r := es.get_global_rect()
	if r.position.y < -1.0 or r.end.y > vp.size.y + 1.0 or r.position.x < -1.0 or r.end.x > vp.size.x + 1.0:
		failures.append("%s: end screen %s outside the viewport %s" % [where, str(r), str(vp.size)])
	var tr := es.title_label.get_global_rect()
	if tr.position.y < 0.0 or tr.end.y > vp.size.y:
		failures.append("%s: end screen title off screen (%s)" % [where, str(tr)])
	for b in ["Return to start", "Keep viewing", "Ghost of history"]:
		var btn := _find_button(es, b)
		if btn == null:
			failures.append("%s: no '%s' button" % [where, b])
			continue
		var br := btn.get_global_rect()
		if br.position.y < 0.0 or br.end.y > vp.size.y or br.position.x < 0.0 or br.end.x > vp.size.x:
			failures.append("%s: '%s' button off screen (%s in %s)" % [where, b, str(br), str(vp.size)])
	var sc: ScrollContainer = es._scroll
	if sc == null or not is_instance_valid(sc):
		failures.append("%s: the end screen body is not in a scroll area" % where)
	elif es._inner.get_combined_minimum_size().y > sc.size.y + 2.0 and sc.get_v_scroll_bar().max_value <= sc.size.y:
		failures.append("%s: end screen content taller than its scroll area but not scrollable" % where)
	var verdict_rt := es.body.get_child(0) as RichTextLabel
	if verdict_rt == null or verdict_rt.get_global_rect().position.y < 0.0:
		failures.append("%s: verdict not pinned on screen" % where)
	_check_min_font(es, where)
	# fix4-ui: folded, the end screen is a few screens long, not ~17,600 px (fullr minor)
	if sc != null and is_instance_valid(sc) and not es.is_open("*") and not es._all_reasons and es._inner.get_combined_minimum_size().y > END_MAX_SCROLL:
		failures.append("%s: the folded end screen scrolls %d px (at most %d)" % [where, int(es._inner.get_combined_minimum_size().y), int(END_MAX_SCROLL)])
	say("%s layout (viewport %s, window %s): end screen %s, scroll %s of %s" % [where, str(vp.size), str(get_window().size), str(r), str(sc.size if sc else Vector2.ZERO), str(es._inner.get_combined_minimum_size() if sc else Vector2.ZERO)])


func _check_min_font(w: Control, where: String, min_px := 12.0) -> void:
	## Body text at least min_px on a 1280x720 screen (the UI is laid out at 1672x941 and scaled).
	var k := 720.0 / 941.0
	var small := []
	for l in w.find_children("*", "Label", true, false):
		if (l as Control).is_visible_in_tree() and (l as Label).text.strip_edges() != "":
			var fs := (l as Label).get_theme_font_size("font_size")
			if fs * k < min_px - 0.01:
				small.append("%s (%d)" % [(l as Label).text.substr(0, 30), fs])
	for l in w.find_children("*", "RichTextLabel", true, false):
		if (l as Control).is_visible_in_tree() and (l as RichTextLabel).get_parsed_text().strip_edges() != "":
			var fs2 := (l as RichTextLabel).get_theme_font_size("normal_font_size")
			if fs2 * k < min_px - 0.01:
				small.append("%s (%d)" % [(l as RichTextLabel).get_parsed_text().substr(0, 30), fs2])
	if small.size() > 0:
		failures.append("%s: %d texts below %d px at 1280x720, e.g. %s" % [where, small.size(), int(min_px), ", ".join(small.slice(0, 3))])


func _finish() -> void:
	_i18n_finish()
	say("FAILURES: %d" % failures.size())
	for f in failures:
		say("  " + f)
	var fa := FileAccess.open(dir + "/ui_test_log.txt", FileAccess.WRITE)
	if fa:
		fa.store_string("\n".join(log_lines))
	get_tree().quit()


func _resolve(a: Dictionary) -> void:
	var t := str(a["type"])
	ui.hud.last_shift = false
	ui._on_next_pressed()          # the end-turn button jumps to the decision
	await _frames(4)
	var first := not seen.has(t)
	seen[t] = true
	match t:
		"event_choice":
			if first: await shot("event_popup")
			var rows := _rows(ui.popup.body)
			var pick: UIRow = null
			var want_hist: bool = ui.sim.state.turn % 2 == 1
			for r in rows:
				var hist := _has_label(r, "historical")
				if hist == want_hist:
					pick = r
					break
			if pick == null and rows.size() > 0:
				pick = rows[0]
			if pick:
				pick.pressed.emit(false)
				await _frames(4)
				if first: await shot("event_result")
				var cb := _find_button(ui.popup, "Continue")
				if cb: cb.pressed.emit()
		"immigration":
			if first: await shot("immigration")
			var rows := _rows(ui.popup.body)
			if rows.size() > 0:
				rows[ui.sim.state.turn % rows.size()].pressed.emit(false)
		"fork":
			if first: await shot("fork")
			var frows := _rows(ui.popup.body).filter(func(r): return r.enabled)
			if frows.size() > 0:
				frows[(ui.sim.state.turn) % frows.size()].pressed.emit(false)
				await _frames(3)
				if first: await shot("fork_result")
				var cb2 := _find_button(ui.popup, "Continue")
				if cb2: cb2.pressed.emit()
		"diplomacy":
			# v3 (sim-diplomacy): the envoy decision opens on the diplomacy screen ("<leader> says", then the answers)
			var dw: DiplomacyScreen = ui.diplo_w
			if not dw.visible or dw.mode != "envoy":
				failures.append("T%d: the envoy decision did not open the diplomacy screen" % ui.sim.state.turn)
			if first:
				await _frames(4)
				await shot("diplomacy_envoy")
				_check_legible(dw, "envoy decision")
				_in_view(dw, "envoy decision")
			var drows: Array = _rows(dw._mid).filter(func(r): return r.enabled) if dw.visible else []
			if drows.size() > 0:
				drows[ui.sim.state.turn % drows.size()].pressed.emit(false)
				await _frames(4)
				if dw.mode != "result":
					failures.append("T%d: answering the envoy showed no result" % ui.sim.state.turn)
				elif first:
					await shot("diplomacy_envoy_result")
				var dc := _find_button(dw, "Continue")
				if dc: dc.pressed.emit()
			else:
				_force(a)
		"programme":
			var pw: ProgrammesPanel = ui.prog_w
			if first:
				await _frames(4)
				await shot("programme_decision")
				_check_legible(pw, "programme decision")
				_below_top_bar(pw, "programme decision")
			var prows: Array = _rows(pw.body).filter(func(r): return r.enabled) if pw.visible else []
			if prows.size() > 0:
				prows[0].pressed.emit(false)
				await _frames(3)
				pw.close()
			else:
				_force(a)
		"crisis_response", "dedication", "agenda":
			if first: await shot(t)
			if t == "crisis_response":
				_check_front_preview()
			for r in _rows(ui.popup.body):
				if r.enabled:
					r.pressed.emit(false)
					break
		"fill_policy":
			if first: await shot("policy_fill")
			var done := false
			for c in ui.policy_p.find_children("*", "PanelContainer", true, false):
				if (c as Control).has_meta("pid") and (c as Control).is_visible_in_tree() and (c as Control).get_parent() is GridContainer:
					var before: int = ui.sim.blocking_decisions().filter(func(x): return x["type"] == "fill_policy").size()
					ui.policy_p.pick_card(str(c.get_meta("pid")))   # the card's click handler
					done = ui.sim.blocking_decisions().filter(func(x): return x["type"] == "fill_policy").size() < before
					break
			if not done:
				_force(a)
			ui.policy_p.close()
		"policy_review":
			if first:
				await _frames(4)
				await shot("policy_review")
			if not _press(ui.policy_p, "Confirm policies"):
				_force(a)
		"state_budget", "budget_review", "minister", "coalition":
			await _cabinet(t, first)
		"choose_research", "choose_civic":
			var p: UIWindow = ui.research_p if t == "choose_research" else ui.civic_p
			if first: await shot(t)
			var rows := _rows(p.body).filter(func(r): return r.enabled)
			var rec := rows.filter(func(r): return _has_label(r, "Recommended"))
			if rec.size() > 0: rec[0].pressed.emit(false)
			elif rows.size() > 0: rows[0].pressed.emit(false)
		"choose_production":
			if first:
				await _frames(10)
				await shot("city_screen")
			var rows := _rows(ui.city_s.body).filter(func(r): return r.enabled)
			var rec := rows.filter(func(r): return _has_label(r, "Recommended"))
			if rec.size() > 0: rec[0].pressed.emit(false)
			elif rows.size() > 0: rows[0].pressed.emit(false)
			await _frames(2)
			await finish_placement()
		"unit_orders":
			await _unit(int(a["unit"]), first)
	await _frames(2)


func _unit(id: int, first: bool) -> void:
	var u = ui.sim.unit_by_id(id)
	if u == null:
		return
	if ui.selected_unit != id:
		ui.select_unit(id, true)
	await _frames(20)
	match str(u.type):
		"settler":
			if not seen.has("settler_sel"):
				seen["settler_sel"] = true
				await shot("settler_selected")
			var fb := _find_button(ui.unit_p, "Found")
			if fb == null or fb.disabled:
				var best = null
				var bd := 999
				for p in ui._targets:
					if ui._targets[p] == "settle":
						var d := SimHex.distance(u.pos(), p)
						if d < bd:
							bd = d
							best = p
				if best != null:
					ui._on_tile_clicked(best.x, best.y)     # click the gold tile
					await _frames(30)
				fb = _find_button(ui.unit_p, "Found")
			if fb and not fb.disabled:
				fb.pressed.emit()
				await _frames(20)
				if not seen.has("founded"):
					seen["founded"] = true
					await shot("town_founded")
				say("founded a town at %s" % ui.sim.date_label())
			else:
				_press(ui.unit_p, "Skip")
		"builder":
			var bb := _find_button(ui.unit_p, "Build ")
			if bb == null:
				var best = null
				var bd := 999
				for p in ui._targets:
					if ui._targets[p] == "build":
						var d := SimHex.distance(u.pos(), p)
						if d < bd:
							bd = d
							best = p
				if best != null:
					if not seen.has("builder_sel"):
						seen["builder_sel"] = true
						await shot("builder_selected")
					ui._on_tile_clicked(best.x, best.y)
					await _frames(30)
				bb = _find_button(ui.unit_p, "Build ")
			if bb and not bb.disabled:
				var lab := bb.text
				bb.pressed.emit()
				say("builder: %s" % lab)
			else:
				_press(ui.unit_p, "Sleep")
		_:
			if first: await shot("unit_orders")
			if not _press(ui.unit_p, "Fortify"):
				_press(ui.unit_p, "Skip")
	await _frames(4)


func _force(a: Dictionary) -> void:
	var s: Sim = ui.sim
	match str(a["type"]):
		"event_choice": s.choose_event(str(a["event"]), 0)
		"crisis_response": s.choose_crisis_response(a["options"].size() - 1)
		"dedication": s.choose_dedication("innovation")
		"agenda": s.choose_agenda(0)
		"fill_policy": SimAI.fill_policies(s)
		"choose_research": s.set_research(SimAI.pick_research(s))
		"choose_civic": s.set_civic(SimAI.pick_civic(s))
		"choose_production":
			var c = s.city_by_id(int(a["city"]))
			var p: Dictionary = SimAI.pick_production(s, c)
			if not p.is_empty(): s.set_production(c.id, p["kind"], p["id"], p.get("tile", -1))
			else: s.set_city_automated(c.id, true)
		"unit_orders": s.unit_action(int(a["unit"]), "sleep")
		"immigration": s.choose_immigration(str(a.get("historical", "cities")))
		"policy_review":
			SimAI.fill_policies(s)
			s.confirm_policies()
		_:
			if s.has_method("resolve_recommended"):
				s.resolve_recommended(a)
	ui._refresh_all()


# ------------------------------------------------------------------ helpers

func _press(root: Node, prefix: String) -> bool:
	var b := _find_button(root, prefix)
	if b and not b.disabled:
		b.pressed.emit()
		return true
	return false


func _find_button(root: Node, prefix: String) -> Button:
	if root == null:
		return null
	for c in root.find_children("*", "Button", true, false):
		if (c as Button).text.begins_with(prefix) and (c as Button).is_visible_in_tree():
			return c
	return null


func _rows(root: Node) -> Array:
	return _rows_rec(root)


func _rows_rec(root: Node) -> Array:
	var out := []
	for c in root.get_children():
		if c is UIRow:
			out.append(c)
		out.append_array(_rows_rec(c))
	return out


func _all(root: Node, cls: String) -> Array:
	return root.find_children("*", cls, true, false)


func _has_label(r: Node, text: String) -> bool:
	for c in r.find_children("*", "Label", true, false):
		if (c as Label).text == text:
			return true
	return false


# ================================================================== tutorial run (--ui-test-tutorial)

func _check_gate(tut: Tutorial) -> void:
	## While the tutorial runs, every visible blocker must be one the tutorial has introduced or reserved.
	if not tut.active:
		return
	for d in ui.sim.blocking_decisions():
		if not tut.allowed(d):
			failures.append("T%d step %s: non-introduced blocker shown: %s" % [ui.sim.state.turn, tut.cur()["id"], d["type"]])
	# the player sees one decision at a time: no satellite blocker buttons, no "+N more"
	if ui.sats.get_child_count() > 0 or str(ui.hud.live.get("next_sub", "")) != "":
		failures.append("T%d step %s: more than one decision shown (%d satellites, '%s')" % [ui.sim.state.turn, tut.cur()["id"], ui.sats.get_child_count(), str(ui.hud.live.get("next_sub", ""))])


func _check_card_beside(tut: Tutorial, win: Control, where: String) -> void:
	## The advisor card sits beside the window it explains, never over it, and inside the screen.
	if not tut.card.visible or not win.visible:
		return
	var cr := Rect2(tut.card.position, tut.card.size)
	var wr := win.get_global_rect()
	if cr.grow(-2).intersects(wr):
		failures.append("%s: the advisor card %s overlaps its window %s" % [where, str(cr), str(wr)])
	var vp: Vector2 = tut.size
	if cr.position.x < 0 or cr.position.y < 0 or cr.end.x > vp.x + 1 or cr.end.y > vp.y + 1:
		failures.append("%s: the advisor card %s is off screen" % [where, str(cr)])


func run_tutorial(turns_after: int) -> void:
	var tut: Tutorial = ui.tutorial
	if ui.test_style == "story":
		await run_tutorial_story(turns_after)   # v4: --ui-test-tutorial --ui-test-style=story
		return
	ui._show_start()
	await _frames(10)
	_find_button(ui.start_screen, "New Game").pressed.emit()
	await _frames(5)
	await shot("start_mode_choice")
	_find_button(ui.start_screen, "Tutorial").pressed.emit()
	await _frames(120)
	if not tut.active:
		failures.append("tutorial did not start")
	var last_step := -1
	var same := 0
	var shots_taken := 0
	for it in 160:
		if not tut.active:
			break
		await _frames(12)
		tut.tick()
		_check_gate(tut)
		var s: Dictionary = tut.cur()
		var id := str(s["id"])
		if tut.step == last_step:
			same += 1
		else:
			same = 0
			last_step = tut.step
			say("tutorial step %d %s at %s (blockers: %s)" % [tut.step + 1, id, ui.sim.date_label(), str(ui.sim.blocking_decisions().map(func(d): return d["type"]))])
			if shots_taken < 14:
				shots_taken += 1
				await shot("tut_%02d_%s" % [tut.step + 1, id])
		if same > 8:
			failures.append("tutorial stuck on step " + id)
			tut._primary.pressed.emit()
			continue
		if not tut._ready_now(s):
			# the card is waiting (for a later turn or a decision): finish the turn's decisions, then NEXT TURN
			var g := 0
			while str(ui.sim.next_action()["type"]) != "end_turn" and g < 40:
				g += 1
				await _resolve(ui.sim.next_action())
			ui.hud.last_shift = false
			ui._on_next_pressed()
			await _frames(40)
			continue
		match id:
			"welcome", "topbar", "finish", "budget":
				tut._primary.pressed.emit()
			"war", "front", "agenda", "fork":
				tut._show.pressed.emit()
				await _frames(10)
				await shot("tut_%s_popup" % id)
				_check_card_beside(tut, ui.popup, id)
				var rows := _rows(ui.popup.body).filter(func(r): return r.enabled)
				if rows.size() > 0:
					rows[0].pressed.emit(false)
				await _frames(5)
				if ui.popup.visible and ui.popup.mode == "result":
					ui.popup.close()
			"state_budget":
				tut._show.pressed.emit()
				await _frames(10)
				await shot("tut_state_budget_open")
				if not ui.cabinet_p.visible:
					failures.append("tutorial state_budget: Show me did not open the State Budget")
				_check_card_beside(tut, ui.cabinet_p, id)
				var brows := _rows(ui.cabinet_p.body).filter(func(r): return r.enabled and _has_label(r, "Recommended"))
				if brows.size() > 0:
					brows[0].pressed.emit(false)
				await _frames(5)
				if ui.cabinet_p.visible:
					ui.cabinet_p.close()
			"civics", "history", "outlook":
				tut._show.pressed.emit()
				await _frames(10)
				await shot("tut_%s_shown" % id)
				if id == "outlook" and not (ui.ghost_p.visible and _has_text(ui.ghost_p, "RISKS TO THE STATE")):
					failures.append("tutorial outlook: Show me did not open the Ending outlook with its risks")
				if id == "civics":
					ui.civic_p.close()
					ui.open_panel("policy")
					await _frames(5)
					ui.policy_p.close()
				else:
					ui.ghost_p.close()
				tut._primary.pressed.emit()
			"event":
				tut._show.pressed.emit()
				await _frames(10)
				await shot("tut_event_popup")
				var rows := _rows(ui.popup.body)
				var pick: UIRow = null
				for r in rows:
					if _has_label(r, "historical"):
						pick = r
				if pick == null and rows.size() > 0:
					pick = rows[0]
				if pick:
					pick.pressed.emit(false)
					await _frames(5)
					var cb := _find_button(ui.popup, "Continue")
					if cb: cb.pressed.emit()
			"research":
				tut._show.pressed.emit()
				await _frames(10)
				await shot("tut_research_open")
				var rows := _rows(ui.research_p.body).filter(func(r): return r.enabled and _has_label(r, "Recommended"))
				if rows.size() > 0: rows[0].pressed.emit(false)
			"city":
				tut._show.pressed.emit()
				await _frames(15)
				await shot("tut_city_open")
				var rows := _rows(ui.city_s.body).filter(func(r): return r.enabled)
				var rec := rows.filter(func(r): return _has_label(r, "Recommended"))
				if rec.size() > 0: rec[0].pressed.emit(false)
				elif rows.size() > 0: rows[0].pressed.emit(false)
				await _frames(5)
				await finish_placement()
				ui.city_s.close()
			"next":
				ui.hud.last_shift = false
				ui._on_next_pressed()
				await _frames(40)
			"immigration":
				tut._show.pressed.emit()
				await _frames(10)
				await shot("tut_immigration_open")
				var rows := _rows(ui.popup.body)
				if rows.size() > 0: rows[0].pressed.emit(false)
			"settler", "crew":
				if not tut._has_unit("settler" if id == "settler" else "builder"):
					tut._primary.pressed.emit()
				else:
					tut._show.pressed.emit()
					await _frames(10)
					if ui.selected_unit >= 0:
						await _unit(ui.selected_unit, false)
					if tut.step == last_step and tut.cur()["id"] == id:
						same += 2
			_:
				tut._primary.pressed.emit()
		# blockers left on this turn after the step: end the turn only when nothing kept is open
	if tut.active:
		failures.append("tutorial did not finish (step %s)" % tut.cur()["id"])
	say("tutorial finished at %s; steps done: %s" % [ui.sim.date_label(), str(tut.done.keys())])
	await shot("tut_after_finish")
	await _howto_check()
	if "--ui-test-quick" in OS.get_cmdline_user_args():
		_finish()
		return
	# skip mid-way
	ui.start_new_game(false, true)
	await _frames(60)
	for k in 3:
		tut._primary.pressed.emit()
		await _frames(8)
	var step_before: int = tut.step
	tut._skip.pressed.emit()
	await _frames(10)
	if tut.active or tut.card.visible:
		failures.append("skip tutorial did not switch to the full game")
	var kinds := {}
	for d in ui.sim.blocking_decisions():
		kinds[str(d["type"])] = true
	say("skip at step %d -> full game; blockers now: %s" % [step_before + 1, str(kinds.keys())])
	await shot("tut_skipped_full_game")
	# save / load keeps tutorial state
	ui.start_new_game(false, true)
	await _frames(40)
	tut._primary.pressed.emit()
	await _frames(8)
	var st: int = tut.step
	ui.quick_save()
	ui.start_new_game(false, false)
	await _frames(30)
	ui.quick_load()
	await _frames(60)
	if not tut.active or tut.step != st:
		failures.append("tutorial state not restored by quick-load (active %s step %d vs %d)" % [str(tut.active), tut.step, st])
	else:
		say("quick-load restored tutorial step %d" % (st + 1))
	tut._skip.pressed.emit()
	await _frames(10)
	say("playing %d full-game turns" % turns_after)
	await play_turns(turns_after)
	_finish()


# ================================================================== v4 onboarding (story-mode tutorial, How to Play)

func _help_page(title: String) -> int:
	for i in HelpOverlay.PAGES.size():
		if str(HelpOverlay.PAGES[i][0]) == title:
			return i
	failures.append("How to Play has no page '%s'" % title)
	return 0


static func _sentences(t: String) -> int:
	## Sentences in a tutorial card (BBCode removed): a full stop, ! or ? followed by a space or the end.
	var plain := RegEx.create_from_string("\\[[^\\]]*\\]").sub(t.replace("VS. ", "VS "), "", true)
	return RegEx.create_from_string("[.!?](\\s|$)").search_all(plain.strip_edges()).size()


func _howto_check() -> void:
	## V4 box 7: How to Play opens on the story-mode pages, then the v3 pages as the reference.
	var first := ["Start here: story mode", "One decision at a time", "Your ministers", "Era goals", "Full control"]
	for i in first.size():
		if HelpOverlay.PAGES.size() <= i or str(HelpOverlay.PAGES[i][0]) != first[i]:
			failures.append("How to Play page %d is '%s', want '%s'" % [i + 1, str(HelpOverlay.PAGES[i][0]) if HelpOverlay.PAGES.size() > i else "-", first[i]])
	var need := [["NOW", "Decide", "END TURN", "ministers", "Settings", "tutorial"],
		["NOW", "Details", "More options", "Always yours"],
		["brief", "Balanced", "Security", "Prosperity", "Peace", "Society", "Cabinet Room", "You decide", "Minister decides", "report"],
		["goals", "reward", "setback", "never ends the game"],
		["Full control", "Settings", "Cabinet Room", "reference"]]
	if HelpOverlay.PAGES.size() < 15:
		failures.append("How to Play: the v3 pages do not follow the story pages (%d pages)" % HelpOverlay.PAGES.size())
	ui.show_help()
	await _frames(4)
	for i in HelpOverlay.PAGES.size():
		ui.help.show_page(i)
		await _frames(2)
		var txt := str(HelpOverlay.PAGES[i][1])
		if txt.length() < 200:
			failures.append("How to Play page '%s' is almost empty" % str(HelpOverlay.PAGES[i][0]))
		if i < need.size():
			for w in need[i]:
				if not txt.contains(w):
					failures.append("How to Play '%s' does not mention '%s'" % [str(HelpOverlay.PAGES[i][0]), w])
		_check_min_font(ui.help, "How to Play page %d" % (i + 1))
		_i18n_scan("how_to_play_page_%d" % i)
		if i < 5 and not seen.has("howto_shot_%d" % i):
			seen["howto_shot_%d" % i] = true
			await shot("howto_%d" % (i + 1))
	var ht := HelpOverlay.all_text().to_lower()
	for w in ["story mode", "one decision at a time", "your ministers", "era goals", "full control", "fork", "state budget", "inflation"]:
		if not ht.contains(w):
			failures.append("How to Play text does not cover '%s'" % w)
	say("How to Play: %d pages, first '%s'" % [HelpOverlay.PAGES.size(), str(HelpOverlay.PAGES[0][0])])
	ui.help.close()


func run_tutorial_story(turns_after: int) -> void:
	## --ui-test-tutorial --ui-test-style=story: New Game -> Tutorial in story mode; every STEPS_STORY card is reached
	## in 10 turns by doing what it asks (Decide, pick, End Turn, the report, the Cabinet Room, the budget, the envoy...).
	var tut: Tutorial = ui.tutorial
	ui._show_start()
	await _frames(10)
	_find_button(ui.start_screen, "New Game").pressed.emit()
	await _frames(5)
	await shot("tut_story_mode_choice")
	_find_button(ui.start_screen, "Tutorial").pressed.emit()
	await _frames(120)
	if not tut.active or not tut.story_tut or tut.steps != Tutorial.STEPS_STORY:
		failures.append("story tutorial did not start (active %s, story %s)" % [str(tut.active), str(tut.story_tut)])
		_finish()
		return
	if not ui.is_story():
		failures.append("the tutorial game is not in story mode")
	var ids := Tutorial.STEPS_STORY.map(func(x): return str(x["id"]))
	for st in Tutorial.STEPS_STORY:
		var n: int = _sentences(str(st["text"])) + _sentences(str(st.get("todo", "")))
		if n > 2:
			failures.append("story card '%s' has %d sentences (at most 2)" % [str(st["id"]), n])
		if str(st["text"]) == "" or str(st["title"]) == "":
			failures.append("story card '%s' has no title or text" % str(st["id"]))
	var reached := {}
	var last_id := ""
	var same := 0
	var shots := 0
	for it in 400:
		if not tut.active or ui.sim.state.game_over:
			break
		await _frames(10)
		tut.tick()
		if ui.sim.state.turn > 16:
			failures.append("story tutorial: still active at turn %d (step %s)" % [ui.sim.state.turn, str(tut.cur()["id"])])
			break
		if not tut.card.visible:
			await _casual_turn("rec")   # nothing to explain now: the player takes the turn
			last_id = ""
			continue
		var s: Dictionary = tut.cur()
		var id := str(s["id"])
		if id == last_id:
			same += 1
		else:
			same = 0
			last_id = id
			if not reached.has(id):
				reached[id] = ui.sim.state.turn
				say("story tutorial %d/%d %s at %s (T%d): %s" % [tut.step + 1, ids.size(), id, ui.sim.date_label(), ui.sim.state.turn, str(s["title"])])
				var cr := Rect2(tut.card.position, tut.card.size)
				var vp: Vector2 = tut.size
				if cr.position.x < 0 or cr.position.y < 0 or cr.end.x > vp.x + 1 or cr.end.y > vp.y + 1:
					failures.append("story card %s is off screen %s" % [id, str(cr)])
				for w in [ui.story_c, ui.room_w, ui.settings_w, ui.help]:
					_check_card_beside(tut, w, id)
				if int(s.get("turn", 1)) > ui.sim.state.turn:
					failures.append("story card %s shown at T%d before its turn %d" % [id, ui.sim.state.turn, int(s["turn"])])
				if shots < 8 and id in ["s_welcome", "s_now", "s_pick", "s_report", "s_room", "s_budget", "s_history", "s_final"]:
					shots += 1
					await shot("tut_story_%s" % id)
		if same > 6:
			failures.append("story tutorial stuck on %s at T%d" % [id, ui.sim.state.turn])
			tut._primary.pressed.emit()
			continue
		match id:
			"s_now":
				_click(ui.next_w.go_btn)
			"s_pick":
				await _casual_decide("rec")
			"s_end":
				await _casual_end_turn()
			"s_report":
				ui.report_w.toggle_btn.pressed.emit()
			"s_budget":
				await _casual_decide("rec", "state_budget")
			"s_envoy":
				await _casual_decide("rec", "diplomacy")
			"s_room", "s_try", "s_help", "s_echo", "s_history", "s_quiet":
				tut._show.pressed.emit()
				await _frames(8)
				tut.tick()
				var win: Control = {"s_room": ui.room_w, "s_try": ui.room_w, "s_help": ui.help, "s_echo": ui.ghost_p, "s_history": ui.ghost_p, "s_quiet": ui.settings_w}[id]
				if not win.visible:
					failures.append("story card %s: Show me did not open its screen" % id)
				else:
					say("DIAG %s tut.size %s root %s card %s %s win %s shift %s" % [id, str(tut.size), str(ui.root.size), str(tut.card.position), str(tut.card.size), str(win.get_global_rect()), str((win as UIWindow).shift_x)])
					_check_card_beside(tut, win, id)
					if id in ["s_room", "s_history"] and not seen.has("tut_open_" + id):
						seen["tut_open_" + id] = true
						await shot("tut_story_%s_open" % id)
					if id == "s_try":   # v4polish item 2: do what the card says, then the screen must be calm again
						var c0 := count_interactive()
						var tg: CheckButton = ui.room_w.find_child("auto_research", true, false)
						if tg != null:
							tg.toggled.emit(false)
							await _frames(4)
							tg = ui.room_w.find_child("auto_research", true, false)
							if tg != null:
								tg.toggled.emit(true)
							await _frames(4)
						(win as UIWindow).close()
						ui._refresh_hud()
						await _frames(3)
						var c1 := count_interactive()
						say("story tutorial s_try: Research taken over and handed back: %d interactive before, %d after (HUD %s)" % [int(c0["total"]), int(c1["total"]), str(c1["hud_keys"])])
						if ui.hud.story_show.has("research") or Unlocks.is_on(ui, "research"):
							failures.append("item 2: the tutorial's 'try a ministry' left the research and civics cards on the HUD")
						await shot("tut_story_s_try_after")
					(win as UIWindow).close()
				await _frames(4)
				tut.tick()
				if tut.active and str(tut.cur()["id"]) == id:
					tut._primary.pressed.emit()
			_:
				tut._primary.pressed.emit()
		await _frames(3)
	for id in ids:
		if not reached.has(id):
			failures.append("story tutorial: step %s was never reached" % id)
	if tut.active:
		failures.append("story tutorial did not finish (step %s)" % str(tut.cur()["id"]))
	say("story tutorial finished at %s (T%d); reached %d of %d steps; done: %s" % [ui.sim.date_label(), ui.sim.state.turn, reached.size(), ids.size(), str(tut.done.keys())])
	await shot("tut_story_after_finish")
	if he_run():   # every card on screen in Hebrew
		for i in ids.size():
			tut.replay(i)
			await _frames(3)
			await shot("tut_story_card_%d" % (i + 1))
		tut.replaying = -1
		tut.card.visible = false
	await _howto_check()
	# skip mid-way: the story game goes on as it is
	ui.start_new_game(false, true)
	await _frames(60)
	for k in 2:
		tut._primary.pressed.emit()
		await _frames(8)
	tut._skip.pressed.emit()
	await _frames(10)
	if tut.active or tut.card.visible:
		failures.append("skip tutorial did not stop the story tutorial")
	if not ui.is_story():
		failures.append("skip tutorial left story mode")
	# save / load keeps the story tutorial's step
	ui.start_new_game(false, true)
	await _frames(40)
	tut._primary.pressed.emit()
	await _frames(8)
	var st: int = tut.step
	ui.quick_save()
	ui.start_new_game(false, false)
	await _frames(30)
	ui.quick_load()
	await _frames(60)
	if not tut.active or tut.step != st or not tut.story_tut:
		failures.append("story tutorial state not restored by quick-load (active %s step %d vs %d, story %s)" % [str(tut.active), tut.step, st, str(tut.story_tut)])
	else:
		say("quick-load restored story tutorial step %d" % (st + 1))
	tut._skip.pressed.emit()
	await _frames(10)
	for t in mini(turns_after, 3):
		await _casual_turn("rec")
	_finish()


# ================================================================== v2 features (Civilopedia, saves, district lens, citizens, previews)

func run_v2(turns: int) -> void:
	## --ui-test-v2: a short run focused on the v2 screens (for windowed screenshots at any resolution).
	ui._show_start()
	await _frames(10)
	_find_button(ui.start_screen, "New Game").pressed.emit()
	await _frames(5)
	_find_button(ui.start_screen, "Full game").pressed.emit()
	await _frames(90)
	await v2_checks()
	await play_turns(mini(turns, 4))
	if not seen.has("combat_preview"):
		say("no attack target in reach during the v2 run (combat preview checked headless in the 40-turn run)")
	await check_continue()
	_finish()


func v2_checks() -> void:
	ui.popup.visible = false   # the turn's queued popups come back through the end-turn button
	ui.cabinet_p.visible = false
	await check_pedia()
	await check_saves()
	await check_district_lens()
	await check_citizens()


func _pedia_text() -> String:
	# the shown text and its English source (in a Hebrew run the shown text is translated)
	return ui.pedia.article.get_parsed_text() + "\n" + ui.pedia.article.text


func check_pedia() -> void:
	ui.hud.panel_pressed.emit("pedia")   # the HUD book button
	await _frames(5)
	var pd: Civilopedia = ui.pedia
	if not pd.visible:
		failures.append("HUD Civilopedia button did not open the Civilopedia")
		ui.open_pedia()
		await _frames(3)
	for t in Civilopedia.TABS:
		var n := pd.entries(t[0]).size()
		if n == 0:
			failures.append("Civilopedia tab %s is empty" % t[0])
	say("civilopedia: %s" % ", ".join(Civilopedia.TABS.map(func(t): return "%s %d" % [t[0], pd.entries(t[0]).size()])))
	# v3 fix round (fix-v3a): nothing dated after the configured last turn (Q3 2023) in the events and wars tabs
	var dbe := SimDB.get_db()
	var last_t := Sim.full_last_turn()
	var past := []
	for e in pd.entries("event"):
		if SimDB.turn_of(dbe.event_by_id.get(str(e["id"]), {}).get("date"), 1 << 20) > last_t: past.append(str(e["id"]))
	for e in pd.entries("war"):
		var wv: Dictionary = dbe.wars.get(str(e["id"]), {})
		if SimDB.turn_of(dbe.event_by_id.get(str(wv.get("event", "")), {}).get("date"), 1 << 20) > last_t: past.append(str(e["id"]))
	if not past.is_empty():
		failures.append("Civilopedia lists %d entries dated after %s: %s" % [past.size(), SimDB.date_label(last_t), ", ".join(past.slice(0, 8))])
	var up: Array = ui.sim.get_upcoming_events(400)
	if up.any(func(x): return int(x.get("turn", 0)) > Sim.last_playable_turn()):
		failures.append("Coming up lists events after the last turn")
	# v3 integration (2026-10-14): content after Q3 2023 is deleted from the data, so the visibility helpers hide nothing
	var late_ev: Array = dbe.events.filter(func(x): return int(x.get("_turn", 0)) > last_t or not dbe.event_shown(x))
	var late_w: Array = dbe.wars.values().filter(func(w): return not dbe.war_shown(w))
	var late_f: Array = dbe.fork_list.filter(func(f): return not dbe.fork_shown(f))
	if not (late_ev.is_empty() and late_w.is_empty() and late_f.is_empty()):
		failures.append("the data still holds content dated after %s (events %s, wars %s, forks %s)" % [SimDB.date_label(last_t),
			", ".join(late_ev.slice(0, 4).map(func(x): return str(x["id"]))), ", ".join(late_w.slice(0, 4).map(func(x): return str(x.get("id", "")))), ", ".join(late_f.slice(0, 4).map(func(x): return str(x["id"])))])
	if not SimDB.scrub_log.is_empty():
		failures.append("the load-time scrub still changed %d item(s): %s" % [SimDB.scrub_log.size(), str(SimDB.scrub_log[0])])
	say("civilopedia: events %d, wars %d, none dated after %s (%d events, %d wars and %d forks in the data are past the end; the load-time scrub changed %d)" % [pd.entries("event").size(), pd.entries("war").size(), SimDB.date_label(last_t),
		late_ev.size(), late_w.size(), late_f.size(), SimDB.scrub_log.size()])
	# every entry: no deleted or banned content, an article with a title and a sources section, no raw keys
	var db := SimDB.get_db()
	var raw := RegEx.new()
	raw.compile("\\b[a-z]+_[a-z0-9_]+\\b")
	var raw_hits := 0
	var late_hits := 0   # v3 fix3-story (A11)
	for e in pd.entries():
		if db.deleted_ids.has(str(e["id"])):
			failures.append("Civilopedia lists deleted content: " + str(e["id"]))
		var txt := pd.article_text(e["kind"], e["id"])
		if pd.banned(txt):
			failures.append("Civilopedia article mentions deleted content: %s:%s" % [e["kind"], e["id"]])
		if txt.find("Sources") < 0:
			failures.append("Civilopedia article without sources section: %s:%s" % [e["kind"], e["id"]])
		var plain := RegEx.new()
		plain.compile("\\[[^\\]]*\\]")
		var vis := plain.sub(txt, "", true)
		vis = vis.substr(vis.find("\n", vis.find("\n") + 1))   # skip the title and the header line (it shows the id on purpose)
		var sa := vis.find("Sources")
		if sa > 0:
			vis = vis.substr(0, sa)   # citations are verbatim bibliography (file names, URLs)
		var m := raw.search(vis)
		if m != null and raw_hits < 5:
			raw_hits += 1
			failures.append("raw key '%s' in Civilopedia %s:%s" % [m.get_string(), e["kind"], e["id"]])
		# v3 fix3-story (A11, BLOCKER): no year after the game's end in any article (cities' status timelines, techs,
		# programmes...); the Sources section is bibliography and is not scanned
		var late: Array = SimDB.years_after_end(vis)
		if not late.is_empty() and late_hits < 8:
			late_hits += 1
			failures.append("Civilopedia %s:%s mentions %s, after the game's end" % [e["kind"], e["id"], str(late[0])])
	await shot("pedia_tech")
	# tabs and search
	var bb := _find_button(pd, "Buildings")
	if bb: bb.pressed.emit()
	await _frames(3)
	if pd.tab != "building":
		failures.append("Civilopedia Buildings tab did not switch")
	pd.search.text = "desalination"
	pd.search.text_changed.emit(pd.search.text)
	await _frames(3)
	var hits := pd.list_box.get_children().filter(func(c): return c is Button).size()
	if hits == 0:
		failures.append("Civilopedia search 'desalination' found nothing")
	say("civilopedia search 'desalination': %d results" % hits)
	var first: Button = null
	for c in pd.list_box.get_children():
		if c is Button:
			first = c
			break
	if first:
		first.pressed.emit()
		await _frames(3)
		await shot("pedia_search")
	pd.search.text = ""
	pd.search.text_changed.emit("")
	# a link inside an article, and Back
	var tech_id := str(db.tech_list[3]["id"])
	ui.open_pedia("tech", tech_id)
	await _frames(2)
	var t0 := _pedia_text()
	if t0.find(str(db.tech_list[3]["name"])) < 0:
		failures.append("open_pedia(tech) did not show the entry")
	var bid := ""
	for id in db.buildings:
		bid = str(id)
		break
	pd._on_meta("pedia:building:" + bid)
	await _frames(2)
	if pd.cur_kind != "building" or pd.cur_id != bid:
		failures.append("Civilopedia link did not open the building entry")
	pd.go_back()
	await _frames(2)
	if pd.cur_id != tech_id:
		failures.append("Civilopedia Back did not return to the previous entry")
	# an event and a war, with sources shown
	ui.open_pedia("war", "war_1967_six_day")
	await _frames(2)
	if _pedia_text().find("Fronts") < 0:
		failures.append("war entry lacks its fronts")
	await shot("pedia_war")
	pd.close()
	# F1 -> How to Play -> Civilopedia
	ui.show_help()
	await _frames(3)
	var hb := _find_button(ui.help, "Civilopedia")
	if hb == null:
		failures.append("How to Play has no Civilopedia button")
	else:
		hb.pressed.emit()
		await _frames(3)
		if not pd.visible:
			failures.append("F1 Civilopedia button did not open it")
	pd.close()
	# from the city screen: the "?" beside a production row
	var cap = ui.sim.city_by_key(ui.sim.state.capital)
	if cap != null:
		ui.open_city(cap.id, false)
		await _frames(3)
		var qb := _find_button(ui.city_s, "?")
		if qb == null:
			failures.append("city production rows have no Civilopedia button")
		else:
			qb.pressed.emit()
			await _frames(2)
			if not pd.visible or not pd.cur_kind in ["building", "district", "unit", "project", "city_project"]:
				failures.append("production row ? did not open its Civilopedia entry")
		pd.close()
		ui.city_s.close()
	# research chooser: right-click a row
	ui.open_panel("research")
	await _frames(3)
	var rr := _rows(ui.research_p.body)
	if rr.size() > 0:
		rr[0].right_pressed.emit()
		await _frames(2)
		if not pd.visible or pd.cur_kind != "tech":
			failures.append("right-click on a research row did not open the Civilopedia")
	pd.close()
	ui.research_p.close()


func check_saves() -> void:
	var d := SaveSlots.dir()
	ui.open_panel("save")
	await _frames(3)
	var w: SaveWindow = ui.save_w
	if not w.visible:
		failures.append("save window did not open")
		return
	w.name_edit.text = "UI test slot"
	w.name_edit.text_changed.emit(w.name_edit.text)
	await shot("save_window")
	w.save_btn.pressed.emit()
	await _frames(3)
	var path := d + "UI_test_slot.json"
	if not FileAccess.file_exists(path) or not FileAccess.file_exists(SaveSlots.meta_path(path)):
		failures.append("named save not written: " + path)
	var m := SaveSlots.read_meta(path)
	if int(m.get("turn", -1)) != ui.sim.state.turn or str(m.get("label", "")) != ui.sim.date_label() or str(m.get("era_name", "")) == "":
		failures.append("save meta wrong: " + str(m))
	# saving again under the same name asks first
	w.name_edit.text = "UI test slot"
	w.name_edit.text_changed.emit(w.name_edit.text)
	w.save_btn.pressed.emit()
	await _frames(2)
	var asked := false
	for l in w.find_children("*", "Label", true, false):
		if (l as Label).text.contains("overwrite"):
			asked = true
	if not asked:
		failures.append("saving over an existing slot did not ask to overwrite")
	w.save_btn.pressed.emit()
	await _frames(2)
	# load tab lists it with its date, turn and era
	_find_button(w, "Load").pressed.emit()
	await _frames(3)
	if w.mode != "load":
		failures.append("Load tab did not switch")
	var found := false
	for r in _rows(w.body):
		var txt := ""
		for l in r.find_children("*", "Label", true, false):
			txt += (l as Label).text + " "
		if txt.contains("UI test slot") and txt.contains(ui.sim.date_label()) and txt.contains("turn %d" % ui.sim.state.turn):
			found = true
	if not found:
		failures.append("load list lacks the named slot with date and turn")
	await shot("load_window")
	# a second slot, deleted with the two-step Delete
	ui.save_slot(d + "UI_test_delete.json", "UI test delete")
	w.refresh()
	await _frames(2)
	var del_row: UIRow = null
	for r in _rows(w.body):
		if _has_label(r, "UI test delete"):
			del_row = r
	if del_row == null:
		failures.append("second slot not listed")
	else:
		_find_button(del_row, "Delete").pressed.emit()
		await _frames(2)
		var again: Button = null
		for r in _rows(w.body):
			if _has_label(r, "UI test delete"):
				again = _find_button(r, "Really")
		if again == null:
			failures.append("Delete did not ask for confirmation")
		else:
			again.pressed.emit()
			await _frames(2)
		if FileAccess.file_exists(d + "UI_test_delete.json"):
			failures.append("Delete did not remove the save")
	w.close()
	say("saves: %s" % ", ".join(SaveSlots.list_all().map(func(x): return "%s (%s)" % [x["name"], SaveSlots.describe(x)])))


func _check_autosaves() -> void:
	var autos := SaveSlots.list_all(false).filter(func(m): return str(m.get("kind", "")) == "auto")
	var t: int = ui.sim.state.turn
	say("autosaves at %s: %s" % [ui.sim.date_label(), str(autos.map(func(m): return int(m.get("turn", 0))))])
	if t >= 6 and autos.is_empty():
		failures.append("no autosave after %d turns" % (t - 1))
	if autos.size() > SaveSlots.AUTOSAVE_KEEP:
		failures.append("%d autosaves kept (max %d)" % [autos.size(), SaveSlots.AUTOSAVE_KEEP])
	for m in autos:
		if (int(m.get("turn", 0)) - 1) % SaveSlots.AUTOSAVE_EVERY != 0:
			failures.append("autosave at an off-cycle turn %d" % int(m.get("turn", 0)))
	if t >= 2 + SaveSlots.AUTOSAVE_EVERY * SaveSlots.AUTOSAVE_KEEP and autos.size() < SaveSlots.AUTOSAVE_KEEP:
		failures.append("only %d autosaves kept after %d turns" % [autos.size(), t - 1])


func check_continue() -> void:
	## The start screen's Continue loads the newest save of any kind.
	var newest := SaveSlots.newest()
	ui.return_to_start()
	await _frames(10)
	if ui.start_screen == null or ui.start_screen.continue_btn == null:
		failures.append("start screen has no Continue button")
		return
	var cb: Button = ui.start_screen.continue_btn
	say("continue button: '%s' (newest: %s %s)" % [cb.text, str(newest.get("name", "")), SaveSlots.describe(newest)])
	if newest.is_empty():
		return
	if cb.disabled or (str(newest.get("label", "")) != "" and not cb.text.contains(str(newest["label"]))):
		failures.append("Continue does not name the newest save: " + cb.text)
	await shot("start_continue")
	var lb := _find_button(ui.start_screen, "Load Game")
	if lb == null:
		failures.append("start screen has no Load Game button")
	else:
		lb.pressed.emit()
		await _frames(3)
		if not ui.save_w.visible or ui.save_w.mode != "load":
			failures.append("start screen Load Game did not open the load window")
		ui.save_w.close()
	cb.pressed.emit()
	await _frames(90)
	if ui.sim == null or (int(newest.get("turn", -1)) > 0 and ui.sim.state.turn != int(newest["turn"])):
		failures.append("Continue loaded turn %s, newest save is turn %s" % [str(ui.sim.state.turn if ui.sim else -1), str(newest.get("turn"))])
	else:
		say("continue: loaded %s (%s)" % [str(newest.get("name", "")), ui.sim.date_label()])


func _district_city() -> Array:
	## [city id, district row] for the first city (capital first) that can start a district now.
	var cs: Array = ui.sim.get_cities()
	cs.sort_custom(func(a, b): return (1 if a["capital"] else 0) * 1000000 + int(a["pop"]) > (1 if b["capital"] else 0) * 1000000 + int(b["pop"]))
	for c in cs:
		for o in ui.sim.get_buildable(int(c["id"])):
			if o["kind"] == "district" and o["available"]:
				return [int(c["id"]), o]
	return []


func check_district_lens() -> void:
	var pick := _district_city()
	if pick.is_empty():
		say("district lens: no city can start a district yet (checked later)")
		return
	var cid: int = pick[0]
	var o: Dictionary = pick[1]
	var c = ui.sim.city_by_id(cid)
	var before: Array = c.queue.duplicate(true)
	ui.city_s.tab = "production"
	ui.open_city(cid, true)
	await _frames(5)
	ui.city_s.show_locked = false
	var row: UIRow = null
	for r in _rows(ui.city_s.body):
		if _has_label(r, str(o["name"])) and r.enabled:
			row = r
	if row == null:
		failures.append("district row %s not found in the city screen" % o["name"])
		return
	row.pressed.emit(false)
	await _frames(5)
	if ui.placing.is_empty() or ui.lens.mode != "district":
		failures.append("picking a district did not open the placement lens")
		return
	var sites: Array = ui.sim.get_district_sites(cid, str(o["id"]))
	if ui.lens.sites.size() != sites.size():
		failures.append("lens shows %d sites, sim has %d" % [ui.lens.sites.size(), sites.size()])
	for i in mini(sites.size(), ui.lens.sites.size()):
		if absf(float(ui.lens.sites[i]["adjacency"]) - float(sites[i]["adjacency"])) > 0.01:
			failures.append("lens adjacency differs from the sim at a site")
			break
	var best: Dictionary = sites[0]
	ui._on_tile_hovered(int(best["q"]), int(best["r"]))
	await _frames(2)
	if not (ui.place_text.get_parsed_text() + ui.place_text.text).contains("This tile"):
		failures.append("hovering a site does not show its adjacency breakdown")
	say("district lens: %s in %s, %d sites, best %s at %d,%d: %s" % [o["name"], c.name, sites.size(), str(best["adjacency"]), int(best["q"]), int(best["r"]), ui.place_text.get_parsed_text().replace("\n", " | ")])
	await shot("district_lens")
	# an invalid tile keeps the lens; Esc cancels and leaves production unchanged
	ui._on_tile_clicked(c.q, c.r)
	await _frames(2)
	if ui.placing.is_empty():
		failures.append("clicking an invalid tile closed the placement lens")
	ui._escape()
	await _frames(2)
	if not ui.placing.is_empty() or ui.lens.mode == "district" or ui.place_bar.visible:
		failures.append("Esc did not cancel the placement lens")
	if str(c.queue) != str(before):
		failures.append("cancelled placement changed the production queue")
	# place it on the best tile with a map click
	row = null
	for r in _rows(ui.city_s.body):
		if _has_label(r, str(o["name"])) and r.enabled:
			row = r
	if row:
		row.pressed.emit(false)
		await _frames(3)
		ui._on_tile_clicked(int(best["q"]), int(best["r"]))
		await _frames(3)
		var ok := false
		for it in c.queue:
			if str(it["kind"]) == "district" and str(it["id"]) == str(o["id"]) and int(it.get("tile", -1)) == SimHex.key(int(best["q"]), int(best["r"])):
				ok = true
		if not ok:
			failures.append("clicking a site did not place the district there (queue %s)" % str(c.queue))
		if not ui.placing.is_empty():
			failures.append("placement lens still open after placing")
	ui.city_s.close()


func finish_placement() -> void:
	## A district picked from the production list opens the lens: place it on the best tile, as a player would.
	if ui.placing.is_empty():
		return
	var cid := int(ui.placing["city"])
	var sites: Array = ui.sim.get_district_sites(cid, str(ui.placing["district"]))
	if not seen.has("lens_turn"):
		seen["lens_turn"] = true
		await shot("district_lens_turn")
	if sites.is_empty():
		ui.cancel_placement()
		return
	ui._on_tile_clicked(int(sites[0]["q"]), int(sites[0]["r"]))
	await _frames(2)


func check_citizens() -> void:
	var cap = ui.sim.city_by_key(ui.sim.state.capital)
	if cap == null:
		return
	ui.city_s.tab = "production"
	ui.open_city(cap.id, true)
	await _frames(4)
	var tb := _find_button(ui.city_s, "Citizens")
	if tb == null:
		failures.append("city screen has no Citizens tab")
		return
	tb.pressed.emit()
	await _frames(4)
	if ui.city_s.tab != "citizens" or ui.lens.mode != "citizens":
		failures.append("Citizens tab did not open the citizens lens")
	var rows := _rows(ui.city_s.body)
	if rows.is_empty():
		failures.append("Citizens tab lists no tiles")
		ui.city_s.close()
		return
	var live := SimAdapter.locks_live(ui.sim)
	# lock a free tile from the list
	var target: UIRow = null
	for r in rows:
		if _has_label(r, "free"):
			target = r
			break
	if target == null:
		target = rows[rows.size() - 1]
	var y0: Dictionary = ui.sim.get_city(cap.id)["yields"].duplicate()
	target.pressed.emit(false)
	await _frames(3)
	var cz := SimAdapter.citizens(ui.sim, cap.id)
	var locked: Array = cz["tiles"].filter(func(t): return t["locked"])
	if locked.is_empty():
		failures.append("clicking a tile row did not lock a citizen")
	else:
		var lt: Dictionary = locked[0]
		if live:
			var info: Dictionary = ui.sim.get_city(cap.id)["info"]
			if not int(lt["key"]) in info.get("worked", []).map(func(k): return int(k)):
				failures.append("a locked tile is not worked by the sim")
			say("citizens: locked %d,%d; yields %s -> %s" % [int(lt["q"]), int(lt["r"]), str(y0), str(ui.sim.get_city(cap.id)["yields"])])
		else:
			say("citizens: locked %d,%d (UI marker; sim lock API not in API.md yet)" % [int(lt["q"]), int(lt["r"])])
		var still := false
		for r in _rows(ui.city_s.body):
			if _has_label(r, "LOCKED"):
				still = true
		if not still:
			failures.append("the citizens list does not show the lock")
		await shot("citizens")
		# unlock with a map click on the same tile
		ui._on_tile_clicked(int(lt["q"]), int(lt["r"]))
		await _frames(3)
		if SimAdapter.citizens(ui.sim, cap.id)["tiles"].any(func(t): return t["locked"]):
			failures.append("a map click did not unlock the citizen")
	ui.city_s.tab = "production"
	ui.city_s.close()
	await _frames(2)
	if ui.lens.mode != "":
		failures.append("closing the city screen left a lens on the map")


func try_combat_preview() -> void:
	## Select each military unit; if an enemy is in reach, hover it: the preview must show odds and modifiers.
	for u in ui.sim.get_units("player"):
		if str(u["cls"]) == "civilian" or float(u["moves"]) <= 0:
			continue
		ui.select_unit(int(u["id"]))
		await _frames(1)
		for p in ui._targets:
			if ui._targets[p] == "attack":
				ui._on_tile_hovered(p.x, p.y)
				await _frames(3)
				var pv := SimAdapter.unit_preview(ui.sim, int(u["id"]), p.x, p.y)
				if not ui.cpv.visible:
					failures.append("hovering an enemy in reach did not show the combat preview")
				var w := float(pv.get("win_odds", -1))
				if w < 0.0 or w > 1.0:
					failures.append("combat preview odds out of range: %s" % str(w))
				if (pv.get("modifiers", []) as Array).is_empty():
					failures.append("combat preview has no modifiers")
				seen["combat_preview"] = true
				# V3 fixes B3: the preview ends above the bottom bar's action buttons (circles from y 826 of 941)
				var cr: Rect2 = ui.cpv.get_global_rect()
				var kk: float = ui.cpv.get_viewport_rect().size.y / 941.0
				if cr.end.y > 822.0 * kk:
					failures.append("combat preview %s runs into the bottom bar (from y %d)" % [str(cr), int(822.0 * kk)])
				say("combat preview: %s vs %s, odds %d%%, dealt %s, taken %s; rect %s" % [pv.get("attacker_name"), pv.get("defender_name"), int(w * 100), str(pv.get("dealt_range")), str(pv.get("taken_range")), str(cr)])
				await shot("combat_preview")
				ui._on_tile_hovered(u["q"], u["r"])
				await _frames(1)
				if ui.cpv.visible:
					failures.append("combat preview stayed open off the target")
				ui.select_unit(-1)
				return
	ui.select_unit(-1)


func _check_front_preview() -> void:
	var d: Dictionary = ui.sim.state.crisis_decision
	if not d.get("war_turn", false):
		return
	var n := 0
	for l in ui.popup.find_children("*", "Label", true, false):
		if (l as Label).text.begins_with("Preview"):
			n += 1
	var fronts := (d.get("options", []) as Array).filter(func(o): return str(o.get("id", "")).begins_with("dfront:") or str(o.get("id", "")) == "full_mobilization")
	if fronts.size() > 0 and n == 0:
		failures.append("T%d war-front popup has no combat preview" % ui.sim.state.turn)
	for o in fronts:
		var fp := SimAdapter.front_preview(ui.sim, o)
		var w := float(fp.get("win_odds", -1))
		# -1 with a verdict is by design: a front with no enemy formation to target shows "Defensive order" (fix4-ui)
		if (w < 0.0 and not (is_equal_approx(w, -1.0) and str(fp.get("verdict", "")) != "")) or w > 1.0:
			failures.append("front preview odds out of range for %s (%s)" % [str(o["id"]), str(w)])
	var stakes := {}
	var nfront := 0
	for o in fronts:
		if str(o["id"]).begins_with("dfront:"):
			nfront += 1
			stakes[CombatPreview.front_stake(SimAdapter.front_preview(ui.sim, o))] = true
	if nfront >= 2 and stakes.size() < 2:
		failures.append("T%d war fronts all show the same headline: %s" % [ui.sim.state.turn, str(stakes.keys())])
	if not seen.has("front_preview_say"):
		seen["front_preview_say"] = true
		say("front preview: %d blocks for %d front orders at %s" % [n, fronts.size(), ui.sim.date_label()])


func _cabinet(t: String, first: bool) -> void:
	## v2 cabinet decisions through their screen: state budget (a custom split once, else the recommended preset),
	## mid-year review, ministers (spend a title), coalition talks.
	var cp: CabinetPanel = ui.cabinet_p
	await _frames(3)
	if not cp.visible:
		failures.append("T%d %s: the decision button did not open the cabinet screen" % [ui.sim.state.turn, t])
		return
	if first:
		await shot("cabinet_" + t)
	_check_legible(cp, t)
	var before: int = ui.sim.blocking_decisions().filter(func(x): return str(x["type"]) == t).size()
	if t == "state_budget" and not seen.has("custom_budget"):
		seen["custom_budget"] = true
		var ids: Array = cp._sliders.keys()
		if ids.size() == 4:
			(cp._sliders[ids[0]] as HSlider).value = 40.0   # the slider path: the others rebalance to 100%
			await _frames(2)
			var tot := 0
			for k in cp.shares:
				tot += int(round(float(cp.shares[k]) * 100.0))
			if tot != 100:
				failures.append("budget sliders add up to %d%%" % tot)
			if not (cp._preview.get_parsed_text() + cp._preview.text).contains("Your split"):
				failures.append("budget preview missing")
			await shot("cabinet_budget_custom")
			say("custom budget: %s -> %s" % [str(cp.shares), cp._preview.get_parsed_text()])
			cp._pass_btn.pressed.emit()
			await _frames(3)
	elif t == "minister" and cp._form_btn != null and is_instance_valid(cp._form_btn) and cp._form_btn.is_visible_in_tree():
		# the cabinet multi-pick: the Recommended set is preselected; drop one and pick it again, then confirm
		var n_sel: int = cp._sel.size()
		if n_sel > 0:
			var first_id: String = cp._sel[0]
			cp._toggle_pick(first_id)
			cp._toggle_pick(first_id)
		if cp._sel.size() != n_sel:
			failures.append("T%d minister multi-pick: toggling changed the picks (%d -> %d)" % [ui.sim.state.turn, n_sel, cp._sel.size()])
		if first:
			say("minister multi-pick at %s: %d titles, %d preselected (%s)" % [ui.sim.date_label(), int(cp.data.get("picks", 0)), n_sel, str(cp._sel)])
		cp._form_btn.pressed.emit()
		await _frames(3)
		if ui.sim.blocking_decisions().any(func(x): return str(x["type"]) == "minister"):
			failures.append("T%d minister multi-pick did not resolve the cabinet screen" % ui.sim.state.turn)
	else:
		var rows := _rows(cp.body).filter(func(r): return r.enabled)
		var rec := rows.filter(func(r): return _has_label(r, "Recommended"))
		if rec.size() > 0: rec[0].pressed.emit(false)
		elif rows.size() > 0: rows[0].pressed.emit(false)
		await _frames(3)
	var after: int = ui.sim.blocking_decisions().filter(func(x): return str(x["type"]) == t).size()
	if t != "minister" and after >= before and before > 0:
		failures.append("T%d %s not resolved through the cabinet screen" % [ui.sim.state.turn, t])
	say("cabinet %s at %s: %d -> %d open" % [t, ui.sim.date_label(), before, after])
	if cp.visible and after == 0:
		cp.close()


func _check_legible(w: Control, where: String) -> void:
	## No raw snake_case keys and no double signs in a screen's visible text.
	var txt := ""
	for l in w.find_children("*", "Label", true, false):
		txt += (l as Label).text + "\n"
	for l in w.find_children("*", "RichTextLabel", true, false):
		txt += (l as RichTextLabel).get_parsed_text() + "\n"
	var raw := RegEx.new()
	raw.compile("\\b[a-z]+_[a-z0-9_]+\\b")
	var m := raw.search(txt)
	if m != null:
		failures.append("%s: raw key '%s' in: %s" % [where, m.get_string(), txt.substr(maxi(0, m.get_start() - 60), 120).replace("\n", " | ")])
	for bad in ["+-", "+−", "--", "−−", "+ -"]:
		if txt.contains(bad):
			failures.append("%s: double sign '%s' in: %s" % [where, bad, txt.substr(maxi(0, txt.find(bad) - 40), 80).replace("\n", " | ")])
			break


# ================================================================== v3 features (settings, indicator, difficulty, endings, diplomacy)

func run_v3(turns: int) -> void:
	## --ui-test-v3: a short run focused on the v3 screens (for windowed screenshots): the New Game panel, Settings,
	## the top bar, the ending outlook, diplomacy, programmes and the 150% scale; then a few turns.
	ui._show_start()
	await _frames(10)
	await shot("v3_start_screen")
	_find_button(ui.start_screen, "New Game").pressed.emit()
	await _frames(8)
	await check_new_game_setup()
	_find_button(ui.start_screen, "Full game").pressed.emit()
	await _frames(90)
	await shot("v3_t1_hud")
	await v3_checks()
	await play_turns(turns)
	check_audio_hooks()
	await check_scenario_start()
	_finish()


func run_scenarios(ids: PackedStringArray, turns: int) -> void:
	## v3 integration: every scenario start (1967, 1977, 1992 by default) from the New Game panel, its briefing, then a
	## few turns through the UI code paths; the date must move on and nothing dated after the end may be listed.
	var avail := V3Adapter.scenarios().filter(func(x): return bool(x.get("available", false)) and str(x.get("id", "")) != "")
	var want := Array(ids) if not ids.is_empty() else avail.map(func(x): return str(x["id"]))
	say("scenario starts: %s" % ", ".join(want))
	if want.is_empty():
		failures.append("scenarios: no scenario start is available")
	ui._show_start()
	await _frames(20)
	for sid in want:
		if ui.sim != null:
			ui.return_to_start()
			await _frames(10)
		_find_button(ui.start_screen, "New Game").pressed.emit()
		await _frames(5)
		ui.start_screen.set_scenario(str(sid))
		tips_seen.clear()
		await _frames(2)
		_find_button(ui.start_screen, "Full game").pressed.emit()
		await _frames(120)
		if ui.sim == null or ui.sim.state.turn <= 1:
			failures.append("scenario %s: the game did not start at its date (turn %d)" % [sid, ui.sim.state.turn if ui.sim else -1])
			continue
		var t0: int = ui.sim.state.turn
		say("scenario %s: started at %s (turn %d)" % [sid, ui.sim.date_label(), t0])
		if not (ui.popup.visible and ui.popup.mode == "result"):
			failures.append("scenario %s: no briefing popup" % sid)
		await shot("scenario_%s_briefing" % sid)
		await play_turns(turns)
		if ui.sim.state.turn <= t0:
			failures.append("scenario %s: no turn was played (still turn %d)" % [sid, ui.sim.state.turn])
		var up: Array = ui.sim.get_upcoming_events(400)
		if up.any(func(x): return int(x.get("turn", 0)) > Sim.last_playable_turn()):
			failures.append("scenario %s: Coming up lists events after the last turn" % sid)
		say("scenario %s: played to %s (turn %d)" % [sid, ui.sim.date_label(), ui.sim.state.turn])
		await shot("scenario_%s_end" % sid)
	_finish()


func check_scenario_start() -> void:
	## A scenario start from the New Game panel (when the sim provides the seeded starts): a later date and its briefing.
	var avail := V3Adapter.scenarios().filter(func(x): return bool(x.get("available", false)) and str(x.get("id", "")) != "")
	if avail.is_empty():
		say("scenarios: none available yet")
		return
	var sc: Dictionary = avail[0]
	ui.return_to_start()
	await _frames(10)
	_find_button(ui.start_screen, "New Game").pressed.emit()
	await _frames(5)
	ui.start_screen.set_scenario(str(sc["id"]))
	tips_seen.clear()   # a new game: its first-time advisor cards come again
	await _frames(2)
	await shot("new_game_scenario")
	if _find_button(ui.start_screen, "Tutorial") != null and not _find_button(ui.start_screen, "Tutorial").disabled:
		failures.append("scenario: the tutorial stays enabled for a %s start" % str(sc["id"]))
	_find_button(ui.start_screen, "Full game").pressed.emit()
	await _frames(120)
	if ui.sim == null or ui.sim.state.turn <= 1:
		failures.append("scenario %s: the game did not start at its date (turn %d)" % [str(sc["id"]), ui.sim.state.turn if ui.sim else -1])
		return
	say("scenario %s: started at %s (turn %d)" % [str(sc["id"]), ui.sim.date_label(), ui.sim.state.turn])
	if not (ui.popup.visible and ui.popup.mode == "result"):
		failures.append("scenario %s: no briefing popup" % str(sc["id"]))
	await shot("scenario_briefing")
	await play_turns(1)


func v3_checks() -> void:
	## Settings (persisted and applied), the top-bar debt / inflation indicator and food reading, the ending outlook,
	## the diplomacy screen (partners, a deal, the deal flow), national programmes, art and audio hooks, UI scale fit.
	ui.popup.visible = false
	ui.cabinet_p.visible = false
	await check_settings()
	await check_indicator()
	await check_outlook()
	await check_diplomacy()
	await check_programmes()
	check_art()
	await check_credits()
	await check_scale_fit()


func _in_view(w: Control, where: String) -> void:
	var vp: Vector2 = w.get_viewport_rect().size
	var r := w.get_global_rect()
	if r.position.x < -1.0 or r.position.y < -1.0 or r.end.x > vp.x + 1.0 or r.end.y > vp.y + 1.0:
		failures.append("%s: %s outside the viewport %s" % [where, str(r), str(vp)])


func fix3_checks() -> void:
	## V3 fix round (fix3-ui): the top bar's colours (B1), the Treasury's levers and the City screen's Upkeep tab
	## (fix3-econ), the ghost chip's state-of-health line and the "or" thresholds of the endings.
	var w68: Array = ui._econ_item({"inflation": 6.8, "trend": 1.5, "baseline": 3.0, "level": "ok", "debt": 0.0, "debt_ratio": 0.0})
	var w81: Array = ui._econ_item({"inflation": 8.1, "trend": 0.0, "baseline": 7.0, "level": "danger", "debt": 0.0, "debt_ratio": 0.0})
	var wwarn: Array = ui._econ_item({"inflation": 5.0, "trend": 0.0, "baseline": 5.0, "level": "warning", "debt": 10.0, "debt_ratio": 0.8})
	if w68[3] == UIKit.TEXT:
		failures.append("top bar: 6.8% inflation and rising above history's reads plain white")
	if w81[3] != UIKit.BAD:
		failures.append("top bar: inflation at the danger tier is not red")
	if wwarn[3] != UIKit.WARN_HI or wwarn[4] != UIKit.WARN_HI:
		failures.append("top bar: the fiscal warning tier is not orange")
	var t35: Array = ui._trust_item(35.0)
	var t50: Array = ui._trust_item(50.0)
	if t35[3] != UIKit.BAD or t50[3] == UIKit.TEXT:
		failures.append("top bar: Civic Trust 35% / 50% not coloured (red / amber)")
	say("top bar colours: inflation 6.8%% rising %s, danger %s, warning %s; trust 35%% %s, 50%% %s" % [w68[3].to_html(false), w81[3].to_html(false), wwarn[3].to_html(false), t35[3].to_html(false), t50[3].to_html(false)])
	var gs: Dictionary = ui.ghost_summary()
	if ui.sim.state.turn >= GameUI.GHOST_FROM_TURN and ui.sim.get_score().has("health") and not gs.has("health"):
		failures.append("VS. HISTORY: the state's health is not passed to the chip")
	if float(gs.get("health", 1.0)) < 0.995:
		ui._refresh_hud()
		if ui.ticker.offset_top < HUD.R_GHOST_HEALTH.end.y:
			failures.append("VS. HISTORY: the history sidebar covers the state's health strip")
		say("VS. HISTORY: %s" % str(gs.get("health_text", "")))
	# the Treasury: running costs and the three levers
	if FiscalPanel.available(ui.sim):
		ui.open_fiscal()
		await _frames(6)
		await shot("fiscal_levers")
		_in_view(ui.fiscal_w, "fiscal levers")
		_below_top_bar(ui.fiscal_w, "fiscal levers")
		_check_legible(ui.fiscal_w, "fiscal levers")
		_check_min_font(ui.fiscal_w, "fiscal levers")
		if L10n.lang == "en":
			for need in ["MOTHBALL OR CLOSE", "PRIVATIS", "STABILIS"]:
				if not _has_text(ui.fiscal_w, need):
					failures.append("fiscal levers: no '%s' section" % need)
		say("fiscal levers: %d privatisations, stabilisation %s" % [(ui.sim.get_privatisations() as Array).size(), "available" if bool(ui.sim.get_stabilisation().get("available", false)) else str(ui.sim.get_stabilisation().get("reason", "not now"))])
		ui.fiscal_w.close()
		await _frames(2)
	else:
		say("fiscal levers: the sim has no fiscal report")
	# the City screen's Upkeep tab: mothball a building, then reopen it
	if ui.sim.has_method("get_city_upkeep"):
		var best := -1
		var most := 0
		for c in ui.sim.active_cities():
			var nb := (ui.sim.get_city_upkeep(c.id).get("buildings", []) as Array).size()
			if nb > most:
				most = nb; best = c.id
		if best < 0:
			say("city upkeep: no city has a building with upkeep yet")
		else:
			ui.open_city(best, true)
			await _frames(4)
			ui.city_s.tab = "upkeep"
			ui.city_s.refresh()
			await _frames(4)
			await shot("city_upkeep")
			_check_legible(ui.city_s, "city upkeep")
			var mb := _find_button(ui.city_s, "Mothball")
			if mb == null:
				failures.append("city upkeep: no Mothball button in a city with %d buildings with upkeep" % most)
			else:
				var n0 := (ui.sim.get_city_upkeep(best).get("mothballed", []) as Array).size()
				mb.pressed.emit()
				await _frames(4)
				var n1 := (ui.sim.get_city_upkeep(best).get("mothballed", []) as Array).size()
				say("city upkeep: mothball in %s -> %d mothballed (was %d); toast '%s'" % [ui.sim.get_city(best).get("name", ""), n1, n0, ui.toast.text])
				if n1 == n0 and not ui.toast.visible:
					failures.append("city upkeep: Mothball did nothing and said nothing")
				var rb := _find_button(ui.city_s, "Reopen")
				if n1 > n0 and rb == null:
					failures.append("city upkeep: a mothballed building has no Reopen button")
				elif rb != null:
					rb.pressed.emit()
					await _frames(4)
					say("city upkeep: reopen -> %d mothballed; toast '%s'" % [(ui.sim.get_city_upkeep(best).get("mothballed", []) as Array).size(), ui.toast.text])
			ui.city_s.close()
			await _frames(2)
	# the endings' "or" thresholds (fix3-econ): shown as a second line
	var has_or := false
	if ui.sim.has_method("get_endings"):
		var en = ui.sim.get_endings()
		if en is Dictionary:
			for e in en.get("endings", []):
				for c in e.get("criteria", []):
					if (c as Dictionary).has("or"):
						has_or = true
	if has_or:
		ui.open_ghost_tab("endings")
		await _frames(5)
		var found := false
		for l in ui.ghost_p.find_children("*", "Label", true, false):
			if (l as Label).text.begins_with("or ") and (l as Label).is_visible_in_tree():
				found = true
		if not found and L10n.lang == "en":
			failures.append("ending outlook: a criterion with an 'or' threshold shows no 'or ...' line")
		else:
			say("ending outlook: 'or' thresholds shown")
		await shot("outlook_or")
		ui.ghost_p.close()
		await _frames(2)


func _below_top_bar(w: Control, where: String) -> void:
	## V3 fixes B2: a centred window starts below the top bar (resources and date stay visible) when it fits.
	var r := w.get_global_rect()
	var k: float = w.get_viewport_rect().size.y / 941.0
	if r.position.y < 47.0 * k - 1.0:
		failures.append("%s: the window starts at y %d, over the top bar" % [where, int(r.position.y)])
	else:
		say("%s: window at y %d, below the top bar" % [where, int(r.position.y)])


func _cfg() -> ConfigFile:
	var c := ConfigFile.new()
	c.load(GameSettings.path)
	return c


func check_new_game_setup() -> void:
	## The New Game panel: difficulty (from the sim's levels), the start (1948 and the scenario starts), then a choice.
	var ss: StartScreen = ui.start_screen
	if ss.setup_panel == null or not ss.setup_panel.visible:
		failures.append("new game: the setup panel did not open")
		return
	var nd := ss._diff_btns.size()
	if nd < 3:
		failures.append("new game: %d difficulty levels" % nd)
	ss.set_difficulty("hard")
	if ss.difficulty != "hard" or not ss._diff_desc.text.length() > 10:
		failures.append("new game: choosing Hard did not show its description")
	await _frames(3)
	await shot("new_game_setup")
	_check_legible(ss.setup_panel, "new game setup")
	_check_min_font(ss.setup_panel, "new game setup")
	ss.set_difficulty("normal")
	if ss._scen_btns.size() < 2:
		failures.append("new game: no scenario starts listed (want 1948 plus the round-2 placeholders)")
	var avail := V3Adapter.scenarios().filter(func(x): return bool(x.get("available", false))).size()
	say("new game: %d difficulty levels, %d starts (%d available)" % [nd, ss._scen_btns.size(), avail])


func check_settings() -> void:
	var sw: SettingsWindow = ui.settings_w
	ui.open_settings("audio")
	await _frames(6)
	if not sw.visible:
		failures.append("settings: the window did not open")
		return
	await shot("settings_audio")
	_in_view(sw, "settings (audio)")
	_check_legible(sw, "settings (audio)")
	_check_min_font(sw, "settings (audio)")
	for b in GameSettings.BUSES:
		if sw.find_child("vol_" + str(b[0]), true, false) == null:
			failures.append("settings: no %s volume slider" % b[0])
	var sl: HSlider = sw.find_child("vol_Music", true, false)
	if sl != null:
		sl.value = 35   # the slider's own signal path
		await _frames(2)
	if absf(float(GameSettings.volumes.get("Music", 0)) - 0.35) > 0.011:
		failures.append("settings: the Music slider did not set the volume (%s)" % str(GameSettings.volumes.get("Music")))
	if absf(float(_cfg().get_value("audio", "Music", -1)) - 0.35) > 0.011:
		failures.append("settings: the Music volume was not saved to %s" % GameSettings.path)
	var bi := AudioServer.get_bus_index("Music")
	if bi >= 0 and absf(AudioServer.get_bus_volume_db(bi) - linear_to_db(0.35)) > 0.2:
		failures.append("settings: the Music bus volume is %.1f dB, not %.1f" % [AudioServer.get_bus_volume_db(bi), linear_to_db(0.35)])
	say("settings: buses present %s, missing %s" % [str(GameSettings.BUSES.map(func(b): return b[0]).filter(func(b): return AudioServer.get_bus_index(b) >= 0)), str(GameSettings.missing_buses())])
	# display
	sw.open("display")
	await _frames(4)
	await shot("settings_display")
	_check_legible(sw, "settings (display)")
	_check_min_font(sw, "settings (display)")
	for nm in ["scale", "palette", "fullscreen", "gfx_tier" if GfxTier.web() else "quality", "language"]:   # (web: the two web presets replace the quality rows)
		if sw.find_child(nm, true, false) == null:
			failures.append("settings: no '%s' control" % nm)
	sw.set_scale_pct(130)
	await _frames(4)
	if absf(UIWindow.ui_scale - GameSettings.effective_scale()) > 0.001 or absf(GameSettings.ui_scale - 1.3) > 0.001:
		failures.append("settings: UI scale 130%% not applied (%s / %s)" % [str(GameSettings.ui_scale), str(UIWindow.ui_scale)])
	if absf(float(_cfg().get_value("ui", "scale", 0)) - 1.3) > 0.01:
		failures.append("settings: UI scale not saved")
	await _frames(6)
	_in_view(sw, "settings at 130%")
	if sw.scale.x < 1.2:
		failures.append("settings: the window is drawn at %.2f, not about 1.3" % sw.scale.x)
	await shot("settings_scale130")
	sw.set_scale_pct(100)
	sw.set_palette("colourblind")
	await _frames(3)
	if UITheme.GOOD_HEX != UITheme.CB_GOOD or not UITheme.pal("[color=#9fe07a]green helps[/color]").contains("blue helps") or str(_cfg().get_value("ui", "palette", "")) != "colourblind":
		failures.append("settings: the colourblind palette was not applied and saved")
	if UIKit.GREEN.is_equal_approx(Color(0.55, 0.85, 0.35)):
		failures.append("settings: UIKit.GREEN did not follow the palette")
	await shot("settings_palette_cb")
	ui.open_ghost_tab("tracks")
	await _frames(4)
	await shot("ghost_palette_cb")
	ui.ghost_p.close()
	sw.set_palette("standard")
	sw.set_quality("low")
	if str(_cfg().get_value("graphics", "quality", "")) != "low" or Quality.level != "low":
		failures.append("settings: graphics preset Low not applied / saved")
	sw.set_quality("medium")
	sw._on_fullscreen(true)
	if not bool(_cfg().get_value("display", "fullscreen", false)):
		failures.append("settings: fullscreen not saved")
	sw._on_fullscreen(false)
	var lo: OptionButton = sw.find_child("language", true, false)
	if lo != null and lo.item_count < 2:
		failures.append("settings: the language selector lists %d languages" % lo.item_count)
	# controls: rebind Research to Y, a conflict moves Y to Civics, defaults restore R
	sw.open("controls")
	await _frames(4)
	await shot("settings_controls")
	_check_legible(sw, "settings (controls)")
	if sw.find_child("key_end_turn", true, false) == null or sw.find_child("key_pedia", true, false) == null:
		failures.append("settings: key rows missing")
	sw.begin_capture("research")
	await _frames(2)
	var ev := InputEventKey.new()
	ev.keycode = KEY_Y
	ev.pressed = true
	sw._input(ev)
	await _frames(2)
	if int(GameSettings.binding("research").get("key", 0)) != KEY_Y:
		failures.append("settings: Research was not rebound to Y")
	if GameSettings.action_for(ev) != "research":
		failures.append("settings: Y does not trigger Research (%s)" % GameSettings.action_for(ev))
	var er := InputEventKey.new()
	er.keycode = KEY_R
	er.pressed = true
	if GameSettings.action_for(er) == "research":
		failures.append("settings: R still triggers Research after the rebind")
	var keys_y = _cfg().get_value("keys", "research", {})
	if typeof(keys_y) != TYPE_DICTIONARY or int(keys_y.get("key", 0)) != KEY_Y:
		failures.append("settings: the Research binding was not saved")
	# the rebinding works in play: Y opens the research panel
	ui.settings_w.close()
	ui.research_p.visible = false
	ui._unhandled_key_input(ev)
	await _frames(3)
	if not ui.research_p.visible:
		failures.append("settings: pressing the rebound key (Y) did not open Research")
	ui.research_p.visible = false
	# the top bar (treasury, yields, date, menu buttons) is drawn in every play style (v4: Full control once lost it)
	ui.hud.top_drawn = -1
	ui.hud.queue_redraw()
	await _frames(3)
	if ui.hud.top_drawn < 0 and DisplayServer.get_name() != "headless":
		failures.append("hud: the top bar was not drawn (style %s)" % str(ui.sim.auto.style() if ui.sim and "auto" in ui.sim and ui.sim.auto else "full"))
	say("hud top bar drawn: %s (display %s)" % [str(ui.hud.top_drawn >= 0), DisplayServer.get_name()])
	# the bottom Research and Culture buttons open their panels when clicked (the Research button's hit box was
	# once overwritten by the left research card's, which share the name "research")
	for pair in [["research", ui.research_p], ["culture", ui.civic_p]]:
		(pair[1] as Control).visible = false
		var click := InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.pressed = true
		click.position = ui.hud._hit_rect("act_" + str(pair[0])).get_center() * ui.hud._ref_scale()
		ui.hud._gui_input(click)
		await _frames(3)
		if not (pair[1] as Control).visible:
			failures.append("hud: clicking the bottom %s button did not open its panel" % pair[0])
		(pair[1] as Control).visible = false
	# windows can be dragged by the title bar, and closing puts them back
	ui.open_panel("research")
	await _frames(3)
	var w: UIWindow = ui.research_p
	var before := w.get_global_rect().position
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	w._on_head_input(press)
	w._drag_from -= Vector2(60, 30)   # as if the mouse had moved by (60, 30) since the press
	w._on_head_input(InputEventMouseMotion.new())
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	w._on_head_input(release)
	await _frames(3)
	var moved := w.get_global_rect().position - before
	if moved.distance_to(Vector2(60, 30) * w.get_global_transform().get_scale().x) > 6.0 and moved.length() < 20.0:
		failures.append("window drag: the research panel did not move (%s)" % str(moved))
	w.close()
	ui.open_panel("research")
	await _frames(3)
	if w.get_global_rect().position.distance_to(before) > 2.0:
		failures.append("window drag: closing did not put the research panel back")
	say("window drag: moved %s, back after close" % str(moved))
	w.close()
	var taken := sw.apply_binding("civics", ev)
	if taken != "research" or int(GameSettings.binding("research").get("key", 0)) != KEY_NONE:
		failures.append("settings: rebinding Y to Civics did not unbind Research (%s)" % taken)
	var ctrl_s := InputEventKey.new()
	ctrl_s.keycode = KEY_S
	ctrl_s.ctrl_pressed = true
	ctrl_s.pressed = true
	if GameSettings.action_for(ctrl_s) != "save":
		failures.append("settings: Ctrl+S is not Save (%s)" % GameSettings.action_for(ctrl_s))
	var sh_en := InputEventKey.new()
	sh_en.keycode = KEY_ENTER
	sh_en.shift_pressed = true
	sh_en.pressed = true
	if GameSettings.action_for(sh_en) != "end_turn_force":
		failures.append("settings: Shift+Enter is not the forced end turn")
	# persisted and re-applied on start: reload the file
	GameSettings.volumes["Music"] = 0.9
	GameSettings.load_cfg()
	if absf(float(GameSettings.volumes.get("Music", 0)) - 0.35) > 0.011 or int(GameSettings.binding("civics").get("key", 0)) != KEY_Y:
		failures.append("settings: values did not survive a reload of %s" % GameSettings.path)
	sw._defaults()
	await _frames(2)
	if int(GameSettings.binding("research").get("key", 0)) != KEY_R or absf(GameSettings.ui_scale - 1.0) > 0.001 or GameSettings.palette != "standard":
		failures.append("settings: Restore defaults did not restore R / 100% / standard")
	sw.close()
	say("settings: volumes, scale, palette, quality, fullscreen, language and key bindings checked (file %s)" % ProjectSettings.globalize_path(GameSettings.path))


func check_indicator() -> void:
	ui._refresh_hud()
	await _frames(2)
	var items: Array = ui.hud.live.get("top_items", [])
	var tips: Array = ui.hud.live.get("top_tips", [])
	var econ: Array = []
	var food: Array = []
	for it in items:
		if str(it[0]) == "economy": econ = it
		if str(it[0]) == "food": food = it
	if econ.is_empty():
		failures.append("indicator: no debt / inflation item in the top bar")
	if tips.size() != items.size():
		failures.append("indicator: %d top-bar tooltips for %d items" % [tips.size(), items.size()])
	var etip := ""
	for t in tips:
		if str(t).begins_with("Inflation"):
			etip = str(t)
	if etip == "" or not etip.contains("debt") and not etip.contains("Public debt"):
		failures.append("indicator: the tooltip does not explain inflation and debt: " + etip.substr(0, 120))
	if not str(food[1] if food.size() > 1 else "").begins_with("+") and not str(food[1] if food.size() > 1 else "").begins_with("−"):
		failures.append("indicator: food is not a signed national balance (%s)" % str(food))
	var ftip := ""
	for t in tips:
		if str(t).begins_with("National food"):
			ftip = str(t)
	if ftip == "":
		failures.append("indicator: no national food tooltip")
	# the HUD's own tooltip lookup at the item's position
	var hud: HUD = ui.hud
	if hud._tip_rects.size() == items.size() and items.size() > 0:
		var r: Rect2 = hud._tip_rects[items.size() - 1]
		var tip := hud._get_tooltip(r.get_center() * hud._ref_scale())
		if hud.tip_host != null:   # v4polish: the top bar explains its items in its own panel, under the bar
			hud.show_top_tip(hud.top_tip_at(r.get_center() * hud._ref_scale()))
			tip = hud.tip_label.text if hud.tip_host.visible else ""
			var tr: Rect2 = hud.tip_host.get_global_rect()
			if hud.tip_host.visible and (tr.position.y < 40.0 or tr.end.x > ui.root.get_global_rect().end.x + 1 or tr.position.x < -1):
				failures.append("indicator: the top bar's explanation runs off the screen or under the bar (%s)" % str(tr))
			hud.show_top_tip(-1)
		if not tip.begins_with("Inflation"):
			failures.append("indicator: hovering the indicator shows '%s'" % tip.substr(0, 60))
	var city: Dictionary = ui.hud.live.get("city", {})
	if not city.is_empty() and str(city.get("food_tip", "")) == "":
		failures.append("indicator: the city panel food row has no explanation")
	for t in tips:
		if UITheme.humanise(str(t)) != str(t) and RegEx.create_from_string("\\b[a-z]+_[a-z0-9_]+\\b").search(str(t)) != null:
			failures.append("indicator: raw key in tooltip: " + str(t).substr(0, 80))
	say("indicator: %s | food %s | %s" % [str(econ.slice(1, 3)), str(food.slice(1, 3)), etip.replace("\n", " / ").substr(0, 200)])


func check_outlook() -> void:
	ui.open_ghost_tab("endings")
	await _frames(6)
	await shot("ending_outlook")
	_in_view(ui.ghost_p, "ending outlook")
	_check_legible(ui.ghost_p, "ending outlook")
	_check_min_font(ui.ghost_p, "ending outlook")
	var out: Array = V3Adapter.outlook(ui.sim)
	if out.size() < 5:
		failures.append("ending outlook: %d endings (want 4 end states and the mixed record)" % out.size())
	for e in out:
		for t in e.get("thresholds", []):
			if not _has_text(ui.ghost_p, UITheme.humanise(str(t.get("label", ""))).substr(0, 24)):
				failures.append("ending outlook: threshold '%s' not shown" % str(t.get("label", "")))
				break
	say("ending outlook (%s): %s" % ["sim" if V3Adapter.outlook_live(ui.sim) else "fallback", ", ".join(out.map(func(e): return "%s %d%%" % [str(e.get("name", "")), int(round(float(e.get("progress", 0)) * 100))]))])
	ui.ghost_p.close()


func _has_text(w: Node, needle: String) -> bool:
	for l in w.find_children("*", "Label", true, false):
		if (l as Label).text.contains(needle):
			return true
	for l in w.find_children("*", "RichTextLabel", true, false):
		if (l as RichTextLabel).get_parsed_text().contains(needle):
			return true
	return false


func check_diplomacy() -> void:
	var dw: DiplomacyScreen = ui.diplo_w
	ui._on_action("diplomacy")   # the HUD Diplomacy button
	await _frames(8)
	if not dw.visible:
		failures.append("diplomacy: the HUD button did not open the screen")
		return
	await shot("diplomacy_screen")
	_in_view(dw, "diplomacy screen")
	_check_legible(dw, "diplomacy screen")
	_check_min_font(dw, "diplomacy screen")
	var rows := _rows(dw._list)
	if rows.size() < 3:
		failures.append("diplomacy: only %d partners listed" % rows.size())
	if not _has_text(dw, "WHY THE RELATION IS"):
		failures.append("diplomacy: no relation causes section")
	if rows.size() > 1:
		(rows[1] as UIRow).pressed.emit(false)
		await _frames(4)
		if dw.selected == "" or not _has_text(dw, "INTEL REPORT"):
			failures.append("diplomacy: selecting a partner did not show its intel report")
	# a partner with deals: open the deal screen, then back
	var deal_rows: Array = _rows(dw._mid).filter(func(r): return r.enabled)
	var opened := false
	for r in deal_rows:
		r.pressed.emit(false)
		await _frames(4)
		if dw.mode == "deal":
			opened = true
			break
	if not opened:
		failures.append("diplomacy: no deal could be opened")
	else:
		await shot("diplomacy_deal")
		_check_legible(dw, "diplomacy deal")
		if not _has_text(dw, "ISRAEL GIVES") or not _has_text(dw, "ISRAEL GETS"):
			failures.append("diplomacy: the deal screen does not show both sides")
		if _find_button(dw, "Make the deal") == null:
			failures.append("diplomacy: no Make the deal button")
		# fix3-story (A6): a deal with a sourced counter-offer shows its terms and a second button. Real counter-offers
		# open in their era (1960s US arms, the German loans); outside it the screen is checked with the same shape.
		var real_co := false
		for rid in ["usa", "germany", "west_germany", "us"]:
			if ui.sim.has_method("get_deals"):
				for dl2 in ui.sim.get_deals(rid):
					if dl2 is Dictionary and not (dl2.get("counter", {}) as Dictionary).is_empty():
						real_co = true
		var keep_deal: Dictionary = dw.deal
		var fake: Dictionary = keep_deal.duplicate()
		if (fake.get("counter", {}) as Dictionary).is_empty():
			fake["counter"] = {"label": "Press for better terms", "advocate": "", "historical": true, "cite": [{"source": "S0"}],
				"note": "", "now": [], "lasting": [], "relation": []}   # words the Hebrew catalog has: the Hebrew run checks it too
		dw.open_deal(fake)
		await _frames(3)
		var cob := _find_button(dw, "Counter-offer: ")
		if cob == null or (L10n.lang == "en" and not _has_text(dw, "COUNTER-OFFER")):
			failures.append("diplomacy: a deal with a counter-offer shows no Counter-offer button or terms")
		else:
			say("diplomacy: counter-offer button '%s'%s" % [cob.text, " (a real counter-offer is open now)" if real_co else ""])
		dw.open_deal(keep_deal)
		await _frames(2)
		var back := _find_button(dw, "Back")
		if back: back.pressed.emit()
		await _frames(3)
		if dw.mode != "overview":
			failures.append("diplomacy: Back did not return to the intel report")
	# make an available deal (a delegation, or any sim deal that is ready)
	var made := false
	for r0 in _rows(dw._list):
		(r0 as UIRow).pressed.emit(false)
		await _frames(2)
		for dl in dw._actor.get("deals", []):
			if bool(dl.get("available", false)) and bool(dl.get("acceptable", true)):
				var g0: float = ui.sim.state.gold
				dw.open_deal(dl)
				await _frames(2)
				var mk := _find_button(dw, "Make the deal")
				if mk and not mk.disabled:
					mk.pressed.emit()
					await _frames(4)
					made = dw.mode == "result"
					say("diplomacy: made '%s' with %s (gold %d -> %d): %s" % [str(dl.get("title", "")), dw.selected, int(g0), int(ui.sim.state.gold), "ok" if made else "refused"])
				break
		if made:
			break
	if not made:
		say("diplomacy: no deal was available to make at %s" % ui.sim.date_label())
	else:
		await shot("diplomacy_deal_made")
		var cb := _find_button(dw, "Continue")
		if cb: cb.pressed.emit()
	dw.close()
	await _frames(2)


func check_programmes() -> void:
	if not ui.sim.has_method("get_programmes"):
		say("programmes: the sim has no national programmes yet")
		return
	ui.open_programmes()
	await _frames(6)
	await shot("programmes")
	_in_view(ui.prog_w, "programmes")
	_below_top_bar(ui.prog_w, "programmes")
	_check_legible(ui.prog_w, "programmes")
	_check_min_font(ui.prog_w, "programmes")
	say("programmes: %d listed" % (ui.sim.get_programmes() as Array).size())
	ui.prog_w.close()


func check_art() -> void:
	var eid := "evt_1948_independence"
	if UIArt.event_art(eid) == null:
		say("art: no illustration for %s yet" % eid)
		return
	ui.popup.show_info_event(eid)
	if ui.popup.find_child("illustration", true, false) == null:
		failures.append("art: the event popup does not show the illustration of %s" % eid)
	ui.popup.close()
	say("art: event illustrations shown (manifest %s)" % ("present" if FileAccess.file_exists(UIArt.MANIFEST) else "absent, file fallback"))


func check_scale_fit() -> void:
	## Every big window fits the screen at 150% (drawn as large as fits).
	GameSettings.ui_scale = 1.5
	GameSettings.apply_scale()
	for pair in [[ui.diplo_w, "diplomacy"], [ui.policy_p, "policy"], [ui.pedia, "pedia"], [ui.cabinet_p, "cabinet"], [ui.ghost_p, "ghost"]]:
		var w: UIWindow = pair[0]
		match pair[1]:
			"diplomacy": ui.open_diplomacy()
			"policy": ui.open_panel("policy")
			"pedia": ui.open_pedia()
			"cabinet": ui.open_panel("cabinet")
			"ghost": ui.open_panel("ghost")
		await _frames(8)
		_in_view(w, "%s at 150%%" % pair[1])
		if w.scale.x < 0.99:
			failures.append("%s at 150%%: drawn smaller than 100%% (%.2f)" % [pair[1], w.scale.x])
		w.close()
	var c = ui.sim.city_by_key(ui.sim.state.capital)
	if c != null:
		ui.open_city(c.id)
		await _frames(8)
		_in_view(ui.city_s, "city screen at 150%")
		await shot("city_screen_150")
		ui.city_s.close()
	GameSettings.ui_scale = 1.0
	GameSettings.apply_scale()
	await _frames(3)


func check_audio_hooks() -> void:
	for need in ["play_sfx:click", "play_sfx:end_turn"]:
		if UIAudio.count(need) == 0:
			failures.append("audio: the UI never called %s" % need)
	say("audio hooks called: %s (AudioDirector %s)" % [str(UIAudio.log.slice(-12)), "present" if UIAudio.director() != null else "absent"])


# ================================================================== v3: Hebrew UI (--lang=he) and credits

var i18n_by_screen := {}     # screenshot tag -> untranslated UI texts seen on that screen
var i18n_offscreen := {}


func he_run() -> bool:
	return L10n.lang != "en"


func _i18n_skipped(c: Node) -> bool:
	var p := c
	for i in 14:
		if p == null:
			return false
		if p.has_meta("i18n_skip"):
			return true
		p = p.get_parent()
	return false


func _i18n_scan(tag: String) -> void:
	## Hebrew run: every visible text on screen (labels, buttons, rich text, option items, placeholders and
	## tooltips) through L10n.audit(); untranslated UI text is a failure (data text waiting for its translator, names
	## and allowed Latin tokens are not). Also: every visible window inside the 1280x720 screen, and window content
	## laid out right to left.
	if not he_run() or ui == null:
		return
	var found := {}
	for n in get_tree().root.find_children("*", "Control", true, false):
		var c := n as Control
		if not c.is_visible_in_tree() or _i18n_skipped(c) or not c.can_auto_translate():
			continue
		var texts: Array = []
		if c is Label:
			texts.append((c as Label).text)
		elif c is RichTextLabel:
			texts.append((c as RichTextLabel).text)
		elif c is OptionButton:
			for i in (c as OptionButton).item_count:
				texts.append((c as OptionButton).get_item_text(i))
		elif c is Button:
			texts.append((c as Button).text)
		elif c is LineEdit:
			texts.append((c as LineEdit).placeholder_text)
		if c.tooltip_text != "":
			texts.append(c.tooltip_text)
		for t in texts:
			for m in L10n.audit(str(t)):
				found[m] = true
			_latin_check(str(t), tag)
	if not found.is_empty():
		i18n_by_screen[tag] = found.keys()
	var vp: Vector2 = ui.root.get_viewport_rect().size
	for w in ui.root.get_children():
		if w is UIWindow and (w as UIWindow).visible:
			var r := (w as Control).get_global_rect()
			if r.position.x < -2.0 or r.position.y < -2.0 or r.end.x > vp.x + 2.0 or r.end.y > vp.y + 2.0:
				i18n_offscreen["%s: %s %s" % [tag, w.name, str(r)]] = true
			var bd: Control = (w as UIWindow).body
			if bd != null and not bd.is_layout_rtl() and not _i18n_skipped(w):
				i18n_offscreen["%s: %s content is not right-to-left" % [tag, w.name]] = true


# Latin-script words allowed on a Hebrew screen besides L10n's own allowed tokens (key names, units, licences, S-ids,
# links) and the verbatim citations: names of works and tools that are published under their Latin names.
const LATIN_OK := ["Jewish Virtual Library", "Wikipedia", "Wikimedia Commons", "Wikimedia", "Frank Ruhl Libre",
	"Noto Sans Hebrew", "Crimson Pro", "Cinzel", "Cormorant Garamond", "Godot Engine", "Godot", "Dan Shamir",
	"ElevenLabs", "OpenAI", "Hunyuan", "Trellis", "Natural Earth", "OpenStreetMap", "Civilization VI", "Creative Commons",
	"Open Font License", "Maddison Project", "ynet", "Ynet"]
# also allowed: all-capital acronyms of organisations and sources (BBC, PCHR, FRUS, QIZ) and file paths (sources/SOURCES.md)
var latin_hits := {}          # Latin word(s) on a Hebrew screen -> "tag: text" of the first place it was seen
var _latin_word_re: RegEx
var _latin_tag_re: RegEx


func _latin_check(src: String, tag: String) -> void:
	## Hebrew run, the runtime Latin-script check (fix4-ui): the text as the screen shows it (after translation and
	## any runtime joins) must not hold Latin-script words, apart from the verbatim citations, the allowed names and
	## L10n's allowed tokens. This catches text built at runtime that the catalog audit cannot see (her M1-M4).
	if src.strip_edges() == "" or not L10n.has_latin(src):
		return
	if _latin_word_re == null:
		_latin_word_re = RegEx.create_from_string("[A-Za-z][A-Za-z'’\\-]*[A-Za-z]")
		_latin_tag_re = RegEx.create_from_string("\\[url=[^\\]]*\\]|\\[/?[a-z_]+(?:[= ][^\\]]*)?\\]|\\b[A-Z]{2,6}\\d*s?\\b|[\\w.\\-]*/[\\w./\\-]*")
	var shown: String = L10n._tr(src, 0)[0]
	var s := shown
	for v in L10n.verbatim:   # citations: shown as published (case-insensitive), removed before anything else
		var i := s.to_lower().find(str(v))
		while i >= 0 and str(v) != "":
			s = s.substr(0, i) + " " + s.substr(i + str(v).length())
			i = s.to_lower().find(str(v))
	for nm in LATIN_OK:
		s = s.replace(nm, " ")
	if L10n._allow_re != null:
		s = L10n._allow_re.sub(s, " ", true)
	s = _latin_tag_re.sub(s, " ", true)
	var words: Array = []
	for m in _latin_word_re.search_all(s):
		words.append(m.get_string())
	if words.is_empty():
		return
	var key := " ".join(words.slice(0, 8))
	if not latin_hits.has(key):
		latin_hits[key] = "%s: %s" % [tag, shown.replace("\n", " / ").substr(0, 220)]


# the Cabinet Agenda's option effects (sim_events agenda candidates), for the effect-text checks
const AGENDA_FX := [{"gold": -45, "housing_city": 2, "city": 1}, {"immigrant_weight_city": -60, "city": 1, "trust_city": -3},
	{"inflation": -2, "readiness": 5, "standing": -1, "cohesion": 2}, {"reserve": 3, "trust_all": 2, "amenity_all": 1},
	{"budget_focus": "education"}, {"temp": {"type": "growth_pct", "pct": 10}, "turns": 4},
	{"temp": {"type": "yield_pct", "yield": "science", "pct": -5}, "turns": 6}, {"borrow": 120},
	{"temp": {"type": "water_demand_pct", "pct": -12}, "turns": 8}, {"temp": {"type": "water_supply_pct", "pct": 10}, "turns": 8}]


static func he_runtime_texts(sim) -> Array:
	## Text the UI builds at runtime from sim and data pieces, which a short run may never put on screen (her M1-M5):
	## the collapse advice (with the running-costs sentence the sim appends), the history sidebar's status words,
	## the agenda cards' effect lines, the coalition partners' descriptions, the collapse countdown line.
	var out: Array = []
	for e in SimCollapse.defs():
		for k in ["name", "summary", "warning", "advice"]:
			if str(e.get(k, "")) != "": out.append(UITheme.humanise(str(e[k])))
		out.append(UITheme.humanise("%s: %d quarters left. %s" % [str(e.get("name", "")), 3, str(e.get("advice", ""))]))
	if sim != null and sim.get("collapse") != null:
		for c in sim.collapse.status():
			out.append(UITheme.humanise(str(c.get("advice", ""))))
			for k in c.get("conditions", []):
				out.append(str(k.get("text", "")))
	if sim != null and sim.get("econ") != null and sim.econ.has_method("upkeep_text"):
		out.append(UITheme.humanise(sim.econ.upkeep_text(true)))
		out.append(UITheme.humanise(sim.econ.upkeep_text(false)))
	for k in UITheme.STATUS_WORDS:   # the sidebar rows ("Sakhnin comes under Israeli administration (israel military government).")
		if str(k).begins_with(" ("):
			out.append("• " + UITheme.humanise("Sakhnin comes under Israeli administration%s." % str(k)))
	for stt in ["israel_military_government", "evacuated", "palestinian_authority", "pa_area_a", "hamas_de_facto", "jordanian_held", "egyptian_held", "arab_held", "syria_un_buffer", "contested"]:
		out.append(UITheme.humanise("Sakhnin: status changed to %s. 1200 residents relocated." % stt.replace("_", " ")))
	var pol := ""
	for pk in SimDB.get_db().policies:
		pol = str(pk)
		break
	for fx in AGENDA_FX + [{"adopt_policy": pol}, {"building": "maabara"}, {"rural_capacity": 1200}]:
		out.append(DecisionPopup._fx_text(fx))
		if sim != null and sim.get("events") != null:
			out.append(CabinetPanel.fx_lines(sim.events.agenda_struct(fx)))
	for ex in [{"stat": "gold", "amount": 12.3, "unit": "per turn (upkeep saved)", "when": "lasting"}, {"stat": "amenity", "amount": -1.0, "unit": "where a service building stops", "when": "while mothballed"},
			{"stat": "upkeep", "amount": -15.0, "unit": "%", "when": "3 years"}, {"stat": "gold", "amount": 9.5, "unit": "per turn (card cost saved)", "when": "lasting"},
			{"stat": "inflation", "amount": -6.0, "unit": "percentage points (about)", "when": "now"}, {"stat": "trust", "amount": -5.0, "unit": "points in every city", "when": "now"},
			{"stat": "gold", "amount": 150.0, "unit": "points, borrowed (public debt repaid with interest over 15 years)", "when": "now"}]:
		out.append(CabinetPanel.fx_lines([ex]))
	if true:
		for p in SimDB.get_db().gov.get("coalition_partners", []):
			out.append(str(p.get("label", "")))
			out.append(UITheme.humanise(str(p.get("desc", ""))))
	return out


func check_he_runtime() -> void:
	## Hebrew run: every runtime-composed text above through the Latin-script check and the catalog audit.
	## Every language: the Cabinet Agenda's structured effects have a text (her M4: empty effects left only commas).
	if ui == null:
		return
	if ui.sim != null and ui.sim.get("events") != null:
		var bad := []
		for fx in AGENDA_FX:
			var ln := CabinetPanel.fx_lines(ui.sim.events.agenda_struct(fx))
			var plain := RegEx.create_from_string("\\[[^\\]]*\\]").sub(ln, "", true).replace(",", "").strip_edges()
			if plain == "" or ln.contains("][/color]"):
				bad.append("%s -> '%s'" % [str(fx), ln])
		if not bad.is_empty():
			failures.append("agenda effects without text: " + " | ".join(bad))
		else:
			say("agenda effects: %d option kinds all have text" % AGENDA_FX.size())
	if not he_run():
		return
	check_he_prefix_hyphen()
	var texts := he_runtime_texts(ui.sim)
	var miss := {}
	for t in texts:
		_latin_check(str(t), "runtime")
		for m in L10n.audit(str(t)):
			miss[m] = true
	if not miss.is_empty():
		i18n_by_screen["runtime-composed text"] = miss.keys()
	say("i18n runtime-composed texts checked: %d" % texts.size())


func check_he_prefix_hyphen() -> void:
	## v4final (her M1): a prefix hyphen before a number ("כ-5", "מ-14") reaches the screen as the maqaf (U+05BE),
	## never as a hyphen-minus that reads as the number's sign; real signs ("−2", "+3", "-4") stay as they are.
	var bad := []
	var digit_re := RegEx.create_from_string("-\\d")
	for s in ["כ-5 יישובים נפגעים", "הובילו את מדינת ישראל מ-14 במאי 1948", "(מ-78 ל-76; מתוך 100)", "משנות ה-50", "כפי שעשתה ישראל ב-1949–1951", "ייצור ו-+3% למשך שנה"]:
		var out := L10n.translate(s)
		var bare := out.replace(char(0x2066), "").replace(char(0x2069), "").replace(char(0x200F), "")
		if digit_re.search(bare) != null or bare.contains("-+") or not out.contains(char(0x05BE)):
			bad.append("'%s' -> '%s'" % [s, out])
	for pair in [["−2 לכידות", "−2"], ["+3 אוצר", "+3"], ["לכידות -4", "-4"]]:
		var out2 := L10n.translate(str(pair[0]))
		if out2.contains(char(0x05BE)) or not out2.contains(str(pair[1])):
			bad.append("sign changed: '%s' -> '%s'" % [pair[0], out2])
	if L10n._bidi_lines("Years 1948-1956, about -5").contains(char(0x05BE)):   # English text: never a maqaf
		bad.append("English text got a maqaf")
	if not bad.is_empty():
		failures.append("he prefix hyphen (M1): " + " | ".join(bad))
	else:
		say("he prefix hyphen: 'כ-5' and 5 more samples show the maqaf, no hyphen-minus before a digit; signs and English unchanged")


func _i18n_finish() -> void:
	if not he_run():
		return
	var fl := FileAccess.open(dir + "/i18n_latin.txt", FileAccess.WRITE)
	if fl:
		for k in latin_hits:
			fl.store_line("%s\n    %s" % [k, latin_hits[k]])
	say("i18n latin check: %d texts with Latin-script words on Hebrew screens" % latin_hits.size())
	if not latin_hits.is_empty():
		var ex: Array = []
		for k in latin_hits.keys().slice(0, 10):
			ex.append("'%s' (%s)" % [k, str(latin_hits[k]).substr(0, 90)])
		failures.append("i18n latin: %d texts show Latin-script words (i18n_latin.txt), e.g. %s" % [latin_hits.size(), " | ".join(ex)])
	var keys := L10n.misses.keys()
	keys.sort_custom(func(a, b): return int(L10n.misses[a]) > int(L10n.misses[b]))
	L10n.dump_misses(dir + "/i18n_missing.json")
	L10n.dump_misses(dir + "/i18n_missing_parts.json", true)
	var pend := L10n.pending.keys()
	pend.sort_custom(func(a, b): return int(L10n.pending[a]) > int(L10n.pending[b]))
	var fp := FileAccess.open(dir + "/i18n_pending_data.txt", FileAccess.WRITE)
	if fp:
		fp.store_string("Data text shown in English because its translation is not in yet (%d texts):\n" % pend.size() + "\n".join(pend.slice(0, 400)))
	var fs := FileAccess.open(dir + "/i18n_by_screen.txt", FileAccess.WRITE)
	if fs:
		for tag in i18n_by_screen:
			fs.store_line("== %s\n  %s" % [tag, "\n  ".join(i18n_by_screen[tag])])
	say("i18n (%s): %d UI catalog keys, %d data texts (%d translated), %d patterns; untranslated UI texts %d, data texts pending %d" % [
		L10n.lang, int(L10n.stats.get("ui", 0)), int(L10n.stats.get("data", 0)), int(L10n.stats.get("data_translated", 0)),
		int(L10n.stats.get("patterns", 0)), keys.size(), pend.size()])
	if keys.size() > 0:
		failures.append("i18n: %d untranslated UI texts (i18n_missing.json), e.g. %s" % [keys.size(), " | ".join(keys.slice(0, 12))])
	for k in i18n_offscreen:
		failures.append("i18n layout: " + str(k))


func _any_rtl() -> bool:
	for v in get_tree().root.find_children("*", "Container", true, false):
		if (v as Control).layout_direction == Control.LAYOUT_DIRECTION_RTL:
			return true
	return false


func check_i18n_start() -> void:
	## Hebrew: the first-launch language prompt and the Hebrew title. English: a live switch to Hebrew and back.
	if he_run():
		if not ui.start_screen._he_title.visible:
			failures.append("i18n: the Hebrew title is not shown on the start screen")
		if not _any_rtl():
			failures.append("i18n: no right-to-left content on the start screen")
		ui.show_language_prompt()
		await _frames(4)
		await shot("language_prompt")
		if ui.lang_prompt.find_child("lang_he", true, false) == null or ui.lang_prompt.find_child("lang_en", true, false) == null:
			failures.append("i18n: the language prompt lacks English / Hebrew")
		ui.lang_prompt.queue_free()
		ui.lang_prompt = null
		await _frames(2)
		return
	if not GameSettings.language_available("he"):
		failures.append("i18n: Hebrew is not available in Settings")
		return
	var nb := _find_button(ui.start_screen, "New Game")
	ui.settings_w.set_language("he")
	await _frames(3)
	var shown := nb.atr(nb.text) if nb != null else ""
	if shown == "New Game" or shown == "" or not _any_rtl():
		failures.append("i18n: live switch to Hebrew did not translate / mirror the start screen (%s)" % shown)
	ui.settings_w.set_language("en")
	await _frames(3)
	if nb != null and nb.atr(nb.text) != "New Game":
		failures.append("i18n: switching back to English left '%s'" % nb.atr(nb.text))
	if L10n.lang != "en" or _any_rtl():
		failures.append("i18n: English after the switch back still has right-to-left content")
	say("i18n: live switch English -> Hebrew -> English checked (New Game read '%s')" % shown)


func check_credits() -> void:
	## Credits: title, author, fonts, every manifest photo reference (CC BY / BY-SA with author, licence and link),
	## the AI note and the sources note; scrolls and fits the screen.
	ui.show_credits()
	await _frames(6)
	var cw: CreditsScreen = ui.credits_w
	if not cw.visible:
		failures.append("credits: the window did not open")
		return
	_in_view(cw, "credits")
	var refs := CreditsScreen.photo_refs()
	if refs.is_empty() or cw.refs_shown != refs.size():
		failures.append("credits: %d of %d photo references listed" % [cw.refs_shown, refs.size()])
	for r in refs:
		if str(r["license"]).begins_with("CC BY") and (str(r["credit"]) == "" or str(r["url"]) == ""):
			failures.append("credits: CC reference without author or link: %s" % str(r["title"]))
	var all := ""
	for l in cw.find_children("*", "Label", true, false):
		all += (l as Label).text + "\n"
	for need in ["Dan Shamir", "Illustrations, models and music generated with AI tools", "OFL", "Frank Ruhl Libre", "History sources"]:
		if not all.contains(need):
			failures.append("credits: missing '%s'" % need)
	var sc := cw.find_children("*", "ScrollContainer", true, false)
	if sc.is_empty():
		failures.append("credits: does not scroll")
	await shot("credits")
	if not sc.is_empty():
		(sc[0] as ScrollContainer).scroll_vertical = 4000
		await _frames(3)
		await shot("credits_end")
	say("credits: %d photo references (%d CC BY / BY-SA), fonts, AI note, sources" % [cw.refs_shown, cw.refs_required])
	cw.close()


# ================================================================== v4: the casual suites (story mode, V4_DESIGN 3.1-3.2)
#   --ui-test-casual [--ui-test-turns=40] [--lang=he]: story mode through the real UI: one primary prompt every turn,
#       the queue at most 3 chips, at most 7 interactive elements at turn 1 (the 1.1 counter), every unlock
#       introduction once, every ministry's toggle, the mid-game style switch both ways, auto-advance, save / load.
#   --ui-test-casual-end: the whole game in story mode with history's story picks; prints CLICKS casual N / full M =
#       ratio (fails under 4.0) and checks the memorial word for word.
#   --ui-test-casual-scenarios [--ui-test-turns=3]: the 1967, 1977 and 1992 starts in story mode.

var clicks := 0                    # every simulated press of a player-facing control in the casual suites
var casual_turns: Array = []       # [turn, player decisions, war]
const ROUTINE_TYPES := ["choose_production", "choose_research", "choose_civic", "unit_orders", "fill_policy", "policy_review", "minister", "budget_review"]
# the minimum clicks of each v3 decision on the Recommended path (V4_DESIGN 2.7)
const V3_CLICKS := {"event_choice": 2, "fork": 2, "crisis_response": 2, "immigration": 2, "dedication": 2, "diplomacy": 2, "choose_research": 2,
	"choose_civic": 2, "unit_orders": 2, "minister": 2, "state_budget": 3, "budget_review": 3, "coalition": 3, "programme": 3, "policy_review": 3,
	"fill_policy": 3, "choose_production": 3, "agenda": 2}


func _has_arg(prefix: String) -> bool:
	for a in OS.get_cmdline_user_args():
		if str(a).begins_with(prefix):
			return true
	return false


func _click(b: BaseButton) -> void:
	clicks += 1
	b.pressed.emit()


func _click_row(r: UIRow) -> void:
	clicks += 1
	r.pressed.emit(false)


func count_interactive(within: Node = null) -> Dictionary:
	## The design's 1.1 counter (progress/v4design/probe_ui.gd): the HUD's drawn hit regions and top-bar items, and
	## every visible, enabled control under GameUI.root (buttons, ranges, line edits, tab bars, option rows, any
	## Control with a connected gui_input). A window's title bar (its drag handle) is not counted.
	var acc := []
	_interactive(within if within != null else ui.root, acc)
	var hud_n := 0
	var hud_keys: Array = []
	if within == null:
		hud_keys = ui.hud._hit.keys()
		hud_n = hud_keys.size() + maxi(ui.hud._tip_rects.size(), (ui.hud.live.get("top_items", []) as Array).size())
	return {"total": hud_n + acc.size(), "hud": hud_n, "hud_keys": hud_keys, "controls": acc.map(func(c): return _ctl_name(c))}


func _ctl_name(c: Control) -> String:
	if c is Button and (c as Button).text != "":
		return "%s '%s'" % [c.name, (c as Button).text.substr(0, 24)]
	return str(c.name)


func _interactive(nd: Node, acc: Array) -> void:
	for c in nd.get_children():
		if c is CanvasItem and not (c as CanvasItem).visible:
			continue
		if c is Control:
			var ctl := c as Control
			if ctl == ui.hud:
				continue
			var hit := false
			if ctl is BaseButton and not (ctl as BaseButton).disabled:
				hit = true
			elif ctl is LineEdit or ctl is Range or ctl is ItemList or ctl is Tree or ctl is TabBar:
				hit = true
			elif ctl is UIRow and (ctl as UIRow).enabled:
				hit = true
			elif ctl is RichTextLabel:
				hit = (ctl as RichTextLabel).text.contains("[url")   # text, unless it holds links
			elif ctl.mouse_filter != Control.MOUSE_FILTER_IGNORE and ctl.gui_input.get_connections().size() > 0:
				var gp := ctl.get_parent().get_parent() if ctl.get_parent() != null else null
				hit = not (gp is UIWindow and (gp as UIWindow)._title_bar == ctl)
			if hit:
				acc.append(ctl)
		_interactive(c, acc)


func _casual_start(scenario := "") -> bool:
	## New Game -> "How do you want to play?" Story -> (a start) -> Full game, as a player does.
	ui.test_style = "story"
	if ui.sim != null:
		ui.return_to_start()
		await _frames(10)
	if ui.start_screen == null:
		ui._show_start()
		await _frames(20)
	var nb := _find_button(ui.start_screen, "New Game")
	if nb == null:
		failures.append("casual: no New Game button")
		return false
	nb.pressed.emit()
	await _frames(5)
	var ss: StartScreen = ui.start_screen
	var sb: Button = ss.setup_panel.find_child("style_story", true, false)
	var fb0: Button = ss.setup_panel.find_child("style_full", true, false)
	if sb == null or fb0 == null:
		failures.append("casual: the New Game panel has no Story / Full control choice")
	else:
		fb0.pressed.emit()
		await _frames(2)
		if ss.play_style != "full":
			failures.append("casual: choosing Full control on the New Game panel did not take")
		sb.pressed.emit()
		await _frames(2)
		if ss.play_style != "story":
			failures.append("casual: choosing Story on the New Game panel did not take")
	if scenario != "":
		ss.set_scenario(scenario)
		await _frames(2)
	if not seen.has("casual_new_game"):
		seen["casual_new_game"] = true
		await shot("casual_new_game")
	var fb := _find_button(ui.start_screen, "Full game")
	if fb == null:
		failures.append("casual: no Full game button")
		return false
	fb.pressed.emit()
	await _frames(120)
	if ui.sim == null:
		failures.append("casual: the game did not start")
		return false
	if not ui.is_story() or ui.full_hud or not ui.hud.story_mode:
		failures.append("casual: a new game from the Story choice is not in story mode (full_hud %s, hud story %s)" % [str(ui.full_hud), str(ui.hud.story_mode)])
	for dd in NextStep.DOMAINS:
		if not NextStep.is_auto(ui, str(dd[0])):
			failures.append("casual: the %s ministry is not on auto in a new story game" % str(dd[0]))
	return true


func _casual_t1() -> void:
	## Turn 1 in 1948 (V4 box 5): at most about 7 interactive elements, the one prompt names the war; its card holds at
	## most 3 options, More options, Details and the close button.
	await _frames(10)
	if ui.story_c.visible:
		failures.append("casual T1: the story card opened before the player looked at the goals")
	var c := count_interactive()
	say("casual T1 interactive: %d (HUD %d %s; controls %s)" % [int(c["total"]), int(c["hud"]), str(c["hud_keys"]), str(c["controls"])])
	if int(c["total"]) > 7:
		failures.append("casual T1: %d interactive elements on the 1948 screen (at most 7): %s" % [int(c["total"]), str(c["controls"])])
	seen["t1_interactive"] = int(c["total"])
	if not ui.goals_w.is_visible_in_tree():
		failures.append("casual T1: the era goals card is not on screen")
	var pd := NextStep.player_decisions(ui)
	if pd.is_empty() or str(pd[0]["type"]) != "crisis_response":
		failures.append("casual T1: the primary prompt is not the 1948 war (%s)" % (str(pd[0]["type"]) if not pd.is_empty() else "end turn"))
	if str(ui.next_w.cur.get("type", "")) != (str(pd[0]["type"]) if not pd.is_empty() else "end_turn"):
		failures.append("casual T1: the prompt shows %s, the first player decision is %s" % [str(ui.next_w.cur.get("type", "")), str(pd[0]["type"]) if not pd.is_empty() else "end_turn"])
	if ui.next_w.chip_count() > 0:
		failures.append("casual T1: queue chips before they unlock (turn 2)")
	say("casual T1 prompt: '%s' / '%s' / [%s]; player decisions %s" % [ui.next_w.head.text, ui.next_w.sub.text, ui.next_w.go_btn.text, str(pd.map(func(x): return x["type"]))])
	_check_story_labels("T1")
	# v4 fix round: the Cabinet Secretary's first introduction is on screen now, and clears when the player acts
	for i in 30:
		if ui.intro_shown_id != "":
			break
		await _frames(2)
	var intro_t1: String = ui.intro_shown_id
	say("casual T1 intro strip: '%s' visible %s" % [intro_t1, str(ui.intro_w.visible)])
	if intro_t1 != "goals" or not ui.intro_w.visible:
		failures.append("casual T1: the goals introduction is not on the strip (%s)" % intro_t1)
	await shot("casual_t1")
	_click(ui.next_w.go_btn)
	await _frames(5)
	if ui.intro_w.visible or ui.intro_shown_id != "":
		failures.append("casual T1: the introduction strip stayed after the player pressed Decide (v4 fix A2)")
	if not ui.story_c.visible:
		failures.append("casual T1: Decide did not open the story card")
		return
	# while the card is open the HUD under it is inert (a dim layer above it, below the card)
	if not ui.story_block.visible or ui.story_block.get_index() > ui.story_c.get_index() or ui.story_block.mouse_filter != Control.MOUSE_FILTER_STOP:
		failures.append("casual T1: the HUD is not inert under the open story card (block %s, index %d / card %d)" % [str(ui.story_block.visible), ui.story_block.get_index(), ui.story_c.get_index()])
	var cc := count_interactive(ui.story_c)
	var rws: Array = ui.story_c.rows()
	say("casual T1 card '%s': %d elements %s" % [ui.story_c.title_label.text, int(cc["total"]), str(cc["controls"])])
	if int(cc["total"]) > 6:
		failures.append("casual T1: the story card has %d elements (at most 6: 3 options, More options, Details, close)" % int(cc["total"]))
	if rws.size() > 3:
		failures.append("casual T1: the story card shows %d options (at most 3)" % rws.size())
	if ui.story_c._btn_details == null:
		failures.append("casual T1: the war card has no Details")
	# v4 fix round A5: the stat words explain themselves (a hover on each option) and, the first time, on the card
	var tipped: Array = rws.filter(func(r): return (r as Control).tooltip_text != "")
	say("casual T1 card glossary: %s; %d of %d options with a hover explanation" % [str(ui.story_c.glossed_now), tipped.size(), rws.size()])
	if tipped.is_empty() or ui.story_c.glossed_now.is_empty():
		failures.append("casual T1: the war card explains none of its stat words (glossary %s, %d hovers)" % [str(ui.story_c.glossed_now), tipped.size()])
	elif not he_run() and not tipped.any(func(r): return (r as Control).tooltip_text.contains(":")):
		failures.append("casual T1: the option hovers are empty")
	_check_legible(ui.story_c, "story card")
	_check_min_font(ui.story_c, "story card")
	_in_view(ui.story_c, "story card")
	await shot("casual_story_card")


func _check_story_labels(where: String) -> void:
	## v4 fix round A4: story mode names its four key numbers on the top bar (Treasury, Population, Civic Trust,
	## Readiness: v4polish, one name per stat).
	ui._refresh_hud()
	var labs: Array = ui.hud.live.get("top_labels", [])
	var want := ["Treasury", "Population", "Civic Trust", "Readiness"]
	if labs.size() < 4 or labs.slice(0, 4) != want:
		failures.append("%s: the story top bar does not label its key numbers (%s)" % [where, str(labs)])
	if (ui.hud.live.get("top_items", []) as Array).size() != labs.size():
		failures.append("%s: %d top-bar labels for %d numbers" % [where, labs.size(), (ui.hud.live.get("top_items", []) as Array).size()])
	if DisplayServer.get_name() != "headless":
		ui.hud.queue_redraw()
		await _frames(2)
		if ui.hud.labels_drawn.size() < 4:
			failures.append("%s: the top-bar labels were not drawn (%s)" % [where, str(ui.hud.labels_drawn)])
	say("%s story top bar: %s" % [where, str(labs)])


func _casual_fix_checks() -> void:
	## v4 fix round (V4_FIXES A): at Q4 1950 (turn 11) in story mode. The HUD stays calm (at most 10 interactive
	## elements, the design's 1.1 counter with the report folded), the Government menu holds the screens, the top bar
	## names its numbers, the Cabinet is read-only while its minister appoints, and the intro strip clears itself.
	var folded := false
	if ui.report_w.opened:
		_click(ui.report_w.toggle_btn)   # (a player who has not unfolded the report)
		folded = true
		await _frames(3)
	if ui.story_c.visible:
		ui.story_c.close()
	ui.flush_intros()
	await _frames(3)
	var c := count_interactive()
	seen["t11_interactive"] = int(c["total"])
	say("casual T11 HUD: %d interactive (HUD %d %s; controls %s)" % [int(c["total"]), int(c["hud"]), str(c["hud_keys"]), str(c["controls"])])
	if int(c["total"]) > 10:
		failures.append("casual T11: %d interactive elements in story mode (at most 10): %s" % [int(c["total"]), str(c["controls"])])
	if ui.hud.story_show.has("ghost") or ui.hud._hit.has("ghost"):
		failures.append("casual T11: the VS. HISTORY chip is still on the map (it is a line on the goals card in story mode)")
	if Unlocks.is_on(ui, "ghost") and not ui.goals_w.hist_lbl.visible:
		failures.append("casual T11: the goals card has no 'Against history' line")
	if ui.story_bar.get_children().filter(func(b): return b is Button and (b as Button).visible).size() != 1:
		failures.append("casual T11: the story bar has %d buttons (one Government menu)" % ui.story_bar.get_child_count())
	await _check_story_labels("T11")
	await shot("fix_t11_hud")
	# the Government menu: one button opens the list; an item opens its screen and closes the list
	if ui.gov_btn == null or not ui.gov_btn.is_visible_in_tree():
		failures.append("casual T11: no Government menu button")
	else:
		_click(ui.gov_btn)
		await _frames(3)
		var items: Array = ui.gov_items()
		var btns: Array = ui.gov_menu.find_children("bar_*", "Button", true, false)
		say("Government menu: %d items %s" % [btns.size(), str(items.map(func(x): return str(x[0])))])
		if not ui.gov_menu.visible or btns.size() != items.size() or items.size() < 3:
			failures.append("Government menu: the list did not open with its %d items (%d buttons, visible %s)" % [items.size(), btns.size(), str(ui.gov_menu.visible)])
		_in_view(ui.gov_menu, "Government menu")
		await shot("fix_gov_menu")
		var room_b: Button = ui.gov_menu.find_child("bar_cabinet_room", true, false)
		if room_b == null:
			failures.append("Government menu: no Cabinet Room item")
		else:
			_click(room_b)
			await _frames(4)
			if not ui.room_w.visible or ui.gov_menu.visible:
				failures.append("Government menu: the Cabinet Room item did not open the Cabinet Room (or the list stayed open)")
			ui.room_w.close()
			await _frames(2)
		_click(ui.gov_btn)
		await _frames(2)
		var tb: Button = ui.gov_menu.find_child("bar_fiscal", true, false)
		if tb != null:
			_click(tb)
			await _frames(4)
			if not ui.fiscal_w.visible:
				failures.append("Government menu: the Treasury item did not open the Treasury")
			ui.fiscal_w.close()
		else:
			ui.gov_menu.visible = false
		await _frames(2)
	# the Cabinet, read-only while its minister appoints (A1): who runs what, and one way to take over
	if not NextStep.is_auto(ui, "cabinet"):
		failures.append("casual T11: the appointments are not on auto")
	ui.open_panel("cabinet")
	await _frames(4)
	if ui.story_c.visible:
		ui.story_c.close()   # (a budget or coalition card took the Cabinet button: open the view itself)
		ui.cabinet_p.show_view()
		await _frames(3)
	var cp: CabinetPanel = ui.cabinet_p
	var seats: Array = cp.find_children("*", "OptionButton", true, false)
	var rows_c: Array = cp.find_children("*", "UIRow", true, false)
	var lines: Array = cp.find_children("cab_line*", "", true, false)
	say("Cabinet (story, auto): read-only %s, %d lines, %d seat pickers, %d option rows" % [str(cp.story_readonly), lines.size(), seats.size(), rows_c.size()])
	if not cp.visible or not cp.story_readonly or not seats.is_empty() or not rows_c.is_empty() or lines.is_empty():
		failures.append("Cabinet (story mode, appointments on auto) is not the short read-only view (read-only %s, %d seat pickers, %d rows, %d lines)" % [str(cp.story_readonly), seats.size(), rows_c.size(), lines.size()])
	_check_legible(cp, "Cabinet (read-only)")
	_in_view(cp, "Cabinet (read-only)")
	await shot("fix_cabinet_readonly")
	var take: Button = cp.find_child("cab_take_over", true, false)
	if take == null:
		failures.append("Cabinet (read-only): no 'Take over appointments'")
	else:
		_click(take)
		await _frames(4)
		if NextStep.is_auto(ui, "cabinet") or cp.story_readonly or not cp.visible:
			failures.append("Cabinet: 'Take over appointments' did not hand the appointments over with the full screen")
		ui.set_domain_auto("cabinet", true)
		await _frames(2)
	cp.close()
	await _frames(2)
	# the intro strip: shown once, gone after its seconds, never over a window, a stale one dropped, cleared on End Turn
	ui._intro_gap = 0.0
	ui.queue_intro("fix_test", Unlocks.intro("goals"))
	ui._intro_tick(0.0)
	if ui.intro_shown_id != "fix_test":
		failures.append("intro strip: a queued introduction did not show")
	ui._intro_tick(GameUI.INTRO_SECS + 0.5)
	if ui.intro_w.visible:
		failures.append("intro strip: still on screen after %d s" % int(GameUI.INTRO_SECS))
	ui._intro_gap = 0.0
	ui.open_cabinet_room()
	await _frames(2)
	ui.queue_intro("fix_test2", Unlocks.intro("report"))
	ui._intro_tick(0.1)
	if ui.intro_w.visible:
		failures.append("intro strip: it covered the Cabinet Room")
	ui.room_w.close()
	await _frames(2)
	ui._intro_gap = 0.0
	ui._intro_tick(0.1)
	if ui.intro_shown_id != "fix_test2":
		failures.append("intro strip: the waiting introduction did not show after the Cabinet Room closed")
	ui._hide_intro()
	ui._intro_gap = 0.0
	ui._intro_q.append(["fix_stale", Unlocks.intro("help"), ui.sim.state.turn - 3])
	ui._intro_tick(0.1)
	if ui.intro_shown_id == "fix_stale":
		failures.append("intro strip: a two-quarter-old introduction was still shown")
	ui._hide_intro()
	ui._intro_gap = 0.0
	ui.queue_intro("fix_test3", Unlocks.intro("queue"))
	ui._intro_tick(0.1)
	seen["intro_before_end"] = ui.intro_shown_id
	if folded:
		_click(ui.report_w.toggle_btn)
		await _frames(2)


func _casual_checks() -> void:
	## Every turn: exactly one primary prompt (the first player decision, or END TURN); at most 3 chips; no routine
	## decision ever reaches the player while its ministry is on auto; the v3 rail and satellites are not shown.
	ui._refresh_hud()
	await _frames(2)
	var pd := NextStep.player_decisions(ui)
	var want := str(pd[0]["type"]) if not pd.is_empty() else "end_turn"
	if not ui.next_w.is_visible_in_tree() or not ui.next_w.go_btn.is_visible_in_tree():
		failures.append("T%d: no primary prompt on screen" % ui.sim.state.turn)
	elif str(ui.next_w.cur.get("type", "")) != want:
		failures.append("T%d: the prompt shows %s, the first decision is %s" % [ui.sim.state.turn, str(ui.next_w.cur.get("type", "")), want])
	var prompts: Array = ui.root.find_children("next_step_go", "Button", true, false).filter(func(b): return (b as Control).is_visible_in_tree())
	if prompts.size() != 1:
		failures.append("T%d: %d primary prompts on screen" % [ui.sim.state.turn, prompts.size()])
	if ui.next_w.chip_count() > 3:
		failures.append("T%d: %d queue chips (at most 3)" % [ui.sim.state.turn, ui.next_w.chip_count()])
	if Unlocks.is_on(ui, "queue") and pd.size() >= 2 and ui.next_w.chip_count() != mini(pd.size() - 1, 3):
		failures.append("T%d: %d chips for %d waiting decisions" % [ui.sim.state.turn, ui.next_w.chip_count(), pd.size() - 1])
	for d in pd:
		var dom := NextStep.domain_of(ui.sim, d)
		if dom != "" and NextStep.is_auto(ui, dom):
			failures.append("T%d: a routine decision reached the player: %s (%s is on auto)" % [ui.sim.state.turn, str(d["type"]), dom])
		elif str(d["type"]) in ROUTINE_TYPES and NextStep.is_auto(ui, dom):
			failures.append("T%d: routine %s in the player's queue" % [ui.sim.state.turn, str(d["type"])])
	if ui.rail.is_visible_in_tree() or ui.sats.get_child_count() > 0 and ui.sats.is_visible_in_tree():
		failures.append("T%d: the v3 notification rail or satellite blockers show in story mode" % ui.sim.state.turn)
	_check_overdraft()
	if ui.intro_overlaps_now():
		failures.append("T%d: the Cabinet Secretary's strip covers the NOW card (%s over %s)" % [ui.sim.state.turn, str(ui.intro_w.get_global_rect()), str(ui.next_w.card.get_global_rect())])
	_check_now_fits("T%d" % ui.sim.state.turn)


# ================================================================== v4polish checks (items 1, 2, 3, 9, 10)

func _check_overdraft() -> void:
	## Item 1: the first quarter the Treasury is below zero in story mode, the Cabinet Secretary's overdraft strip is
	## queued (once); the Treasury reads red only in real danger (the fiscal indicator's warning or danger), else amber;
	## the debt and inflation item is never red on "ok" or "watch".
	if not ui.is_story() or ui.sim == null:
		return
	var n: Dictionary = ui.sim.get_national_summary()
	var items: Array = ui.hud.live.get("top_items", [])
	if items.is_empty():
		return
	var lvl := str(ui.sim.get_fiscal_indicator().get("level", "ok"))
	var cb := V3Adapter.collapse_bar(ui.sim)
	var bad: bool = lvl in ["warning", "danger"] or (bool(cb.get("show", false)) and str(cb.get("id", "")).contains("fiscal"))
	if float(n.get("gold_treasury", 0)) < 0.0:
		if not seen.has("overdraft_first"):
			seen["overdraft_first"] = ui.sim.state.turn
			var queued: bool = ui._intro_q.any(func(e): return str(e[0]) == "overdraft") or ui.intro_log.any(func(e): return str(e[0]) == "overdraft")
			say("overdraft: the Treasury first below zero at %s (%d gold, fiscal %s); the Cabinet Secretary's strip %s" % [ui.sim.date_label(), int(n["gold_treasury"]), lvl, "queued" if queued else "MISSING"])
			if not queued or not (ui.intros_seen as Dictionary).has("overdraft"):
				failures.append("item 1: the Treasury went below zero at %s and no overdraft strip was queued" % ui.sim.date_label())
		var gc = (items[0] as Array)[3] if (items[0] as Array).size() > 3 else null
		if gc is Color:
			var want: Color = UIKit.BAD if bad else UIKit.WARN
			if not (gc as Color).is_equal_approx(want):
				failures.append("item 1: at %s the Treasury (%d) reads %s, want %s (fiscal %s)" % [ui.sim.date_label(), int(n["gold_treasury"]), str(gc), "red" if bad else "amber", lvl])
	for it in items:
		if str((it as Array)[0]) == "economy" and lvl in ["ok", "watch"]:
			for ci in [3, 4]:
				if (it as Array).size() > ci and (it as Array)[ci] is Color and ((it as Array)[ci] as Color).is_equal_approx(UIKit.BAD):
					failures.append("item 1: at %s the debt and inflation item reads red while the fiscal indicator says %s" % [ui.sim.date_label(), lvl])


func _check_now_fits(where: String) -> void:
	## Item 6: the NOW card and its button stay whole on the screen (END TURN → Q3 1948 was cut at the right edge).
	if not ui.next_w.is_visible_in_tree():
		return
	var vr: Rect2 = ui.root.get_global_rect()
	var cr: Rect2 = ui.next_w.card.get_global_rect()
	var br: Rect2 = ui.next_w.go_btn.get_global_rect()
	if cr.position.x < vr.position.x - 1 or cr.end.x > vr.end.x + 1 or cr.end.y > vr.end.y + 1:
		failures.append("%s: the NOW card runs off the screen (%s in %s)" % [where, str(cr), str(vr)])
	if br.end.x > cr.end.x + 1 or br.position.x < cr.position.x - 1:
		failures.append("%s: the NOW button '%s' sticks out of its card (%s in %s)" % [where, ui.next_w.go_btn.text, str(br), str(cr)])
	if ui.next_w.go_btn.get_combined_minimum_size().x > br.size.x + 1:
		failures.append("%s: the NOW button '%s' is clipped" % [where, ui.next_w.go_btn.text])


func _check_intro_clear() -> void:
	## Item 10: the Cabinet Secretary's strip never overlaps the NOW card or its button: forced on screen with a long
	## line, with the prompt on a decision and on END TURN, at 100%, 125% and 150% UI scale.
	var long: String = ui.overdraft_intro(false)
	var rep := []
	for sc in [1.0, 1.25, 1.5]:
		GameSettings.ui_scale = sc
		GameSettings.apply_scale()
		await _frames(3)
		for state in ["decide", "end"]:
			if state == "end":
				ui.next_w.show_for(ui.sim, [])
			else:
				ui.next_w.show_for(ui.sim, NextStep.player_decisions(ui))
			await _frames(2)
			ui._hide_intro()
			ui._intro_gap = 0.0
			ui.queue_intro("polish_overlap", long)
			ui._intro_tick(0.0)
			await _frames(3)
			ui._intro_tick(0.0)
			await _frames(1)
			if not ui.intro_w.visible:
				failures.append("item 10: the forced introduction did not show (scale %.2f, %s)" % [sc, state])
				continue
			var over: bool = ui.intro_overlaps_now()
			var ir: Rect2 = ui.intro_w.get_global_rect()
			rep.append("%d%% %s: strip %s, card %s%s" % [int(sc * 100), state, str(ir), str(ui.next_w.card.get_global_rect()), " OVERLAP" if over else ""])
			if over:
				failures.append("item 10: the Cabinet Secretary's strip covers the NOW card at %d%% (%s)" % [int(sc * 100), state])
			if ir.position.y < ui.root.get_global_rect().position.y + 40:
				failures.append("item 10: the strip runs under the top bar at %d%% (%s)" % [int(sc * 100), str(ir)])
			_check_now_fits("item 6 at %d%% (%s)" % [int(sc * 100), state])
			if not seen.has("intro_clear_shot") and sc == 1.0:
				seen["intro_clear_shot"] = true
				await shot("polish_intro_above_now")
			ui._hide_intro()
	GameSettings.ui_scale = 1.0
	GameSettings.apply_scale()
	ui.intro_log = ui.intro_log.filter(func(e): return str(e[0]) != "polish_overlap")   # (the test's own strip)
	ui._refresh_hud()
	await _frames(3)
	say("item 10: the strip against the NOW card: %s" % " | ".join(rep))


func _check_report_strip(where: String) -> void:
	## Item 3: the ministers' report opens on its 3 most important lines plus "N more" (which opens the rest); no line
	## uses the old jargon; a line with a word of the period explains it on hover, and the first time in a short line.
	var rw = ui.report_w
	if rw == null or not rw.is_visible_in_tree():
		return
	var was: bool = rw.opened
	rw.opened = true
	rw.expanded = false
	rw.refresh()
	await _frames(2)
	var all: Array = MinistersPanel.ranked_lines(ui)
	var bullets := (rw.lines_box.get_children() as Array).filter(func(c): return c is Label and str((c as Label).text).begins_with("•"))
	if bullets.size() > MinistersPanel.STRIP_TOP:
		failures.append("item 3 %s: the report shows %d lines collapsed (at most %d)" % [where, bullets.size(), MinistersPanel.STRIP_TOP])
	if all.size() > MinistersPanel.STRIP_TOP and rw.more_btn == null:
		failures.append("item 3 %s: %d report lines and no 'N more' button" % [where, all.size()])
	for i in mini(all.size(), MinistersPanel.STRIP_TOP):
		for j in range(i + 1, all.size()):
			if MinistersPanel.line_rank(all[j]) > MinistersPanel.line_rank(all[i]):
				failures.append("item 3 %s: '%s' ranks below '%s'" % [where, str(all[i].get("text", "")), str(all[j].get("text", ""))])
	var tips := 0
	for b in bullets:
		if (b as Label).tooltip_text != "":
			tips += 1
	var jl := all.slice(0, MinistersPanel.STRIP_TOP).filter(func(l): return not MinistersPanel.jargon_in(str(l.get("text", ""))).is_empty())
	if jl.size() > tips:
		failures.append("item 3 %s: %d shown lines use a word of the period, %d explain it on hover" % [where, jl.size(), tips])
	for l2 in all:
		for w in ["improvements", "standing orders", "settlement group", "slotted", "refinanced", "mothballed"]:
			if str(l2.get("text", "")).contains(w):
				failures.append("item 3 %s: a report line still says '%s': %s" % [where, w, str(l2.get("text", ""))])
	if rw.more_btn != null:
		_click(rw.more_btn)
		await _frames(2)
		var b2 := (rw.lines_box.get_children() as Array).filter(func(c): return c is Label and str((c as Label).text).begins_with("•"))
		if b2.size() != all.size():
			failures.append("item 3 %s: 'N more' showed %d of %d lines" % [where, b2.size(), all.size()])
		if not seen.has("report_more_shot"):
			seen["report_more_shot"] = true
			await shot("polish_report_expanded")
		rw.expanded = false
	rw.opened = was
	rw.refresh()
	say("item 3 %s: %d report lines, %d shown first (%s), %d with a hover gloss, glossed now %s" % [where, all.size(), mini(all.size(), MinistersPanel.STRIP_TOP),
		" | ".join(all.slice(0, MinistersPanel.STRIP_TOP).map(func(l): return str(l.get("text", "")))), tips, str(rw.glossed_now)])


func _check_stat_names(where: String) -> void:
	## Item 9: one name per stat on the screen: "Civic Trust" (never "Trust" alone or "Civic trust"), "Standing" (never
	## "International Standing"), in the top bar's labels and explanations, the card glossary, the goals and the report.
	var texts := []
	texts.append_array(ui.hud.live.get("top_labels", []))
	texts.append_array(ui.hud.live.get("top_tips", []))
	for g in StoryCard.GLOSS:
		texts.append_array([str(g[1]), str(g[2])])
	var gv := GoalsCard.view(ui.sim)
	for x in gv.get("goals", []):
		texts.append_array([str(x.get("title", "")), str(x.get("progress_label", "")), str(x.get("reward_text", ""))])
	for l in MinistersPanel.strip_lines(ui):
		texts.append(str(l.get("text", "")))
	for it in ui.gov_items():
		texts.append(str(it[1]))
	var re := RegEx.create_from_string("(?<!Civic )\\bTrust\\b|Civic trust|International Standing")
	var bad := []
	for t in texts:
		var m := re.search(str(t))
		if m != null:
			bad.append("'%s' in \"%s\"" % [m.get_string(), str(t).substr(0, 80)])
	if not bad.is_empty():
		failures.append("item 9 %s: a stat goes by another name: %s" % [where, "; ".join(bad.slice(0, 4))])
	say("item 9 %s: %d texts checked for one name per stat (%d off)" % [where, texts.size(), bad.size()])


func _hist_index(view: Dictionary) -> int:
	for o in view.get("all", []):
		if bool(o.get("historical", false)):
			return int(o.get("index", -1))
	return -1


func _casual_decide(mode: String, stop_after := "") -> int:
	## Answers this quarter's decisions on the story card, one click each: history's option when it shows (mode
	## "history"), or the Recommended one / history's on alternate turns ("mixed"). Returns how many.
	var made := 0
	var guard := 0
	while guard < 14:
		guard += 1
		var pd := NextStep.player_decisions(ui)
		if pd.is_empty() or ui.sim.state.game_over:
			break
		if not ui.story_c.visible:
			_click(ui.next_w.go_btn)
			await _frames(3)
		if not ui.story_c.visible:
			failures.append("T%d: the prompt (%s) opened no story card" % [ui.sim.state.turn, str(pd[0]["type"])])
			ui.sim.resolve_recommended(pd[0])
			ui._refresh_all()
			continue
		var rws: Array = ui.story_c.rows().filter(func(r): return (r as UIRow).enabled)
		if ui.story_c.rows().size() > 3 and not ui.story_c.show_more:
			failures.append("T%d: the %s card shows %d options" % [ui.sim.state.turn, str(pd[0]["type"]), ui.story_c.rows().size()])
		if rws.is_empty():
			failures.append("T%d: the %s card has no option to take" % [ui.sim.state.turn, str(pd[0]["type"])])
			ui.story_c.close()
			ui.sim.resolve_recommended(pd[0])
			ui._refresh_all()
			continue
		var want := -1
		var hi := _hist_index(ui.story_c.view)
		var rec := int((ui.story_c.view.get("recommended", {}) as Dictionary).get("index", -1))
		if mode == "history" or (mode == "mixed" and ui.sim.state.turn % 2 == 0):
			want = hi if hi >= 0 else rec
		else:
			want = rec
		var pick: UIRow = rws[0]
		for r in rws:
			if int(r.get_meta("story_index", -1)) == want:
				pick = r
		var t0 := str(pd[0]["type"])
		var key0 := _dkey(pd[0])
		_click_row(pick)
		await _frames(3)
		made += 1
		if stop_after != "" and t0 == stop_after:
			break   # (the tutorial test answers one decision, so the next card can be explained in turn)
		if not seen.has("casual_card_" + t0):
			seen["casual_card_" + t0] = true
			say("story card %s at %s: result %d chars; next %s" % [t0, ui.sim.date_label(), ui.story_c.result_text.length(), str(ui.story_c.deco.get("type", ""))])
			if ui.story_c.result_text == "":
				failures.append("T%d: the %s pick showed no result in its card" % [ui.sim.state.turn, t0])
			if not seen.has("casual_result_shot"):
				seen["casual_result_shot"] = true
				await shot("casual_story_result")
		if NextStep.player_decisions(ui).any(func(x): return _dkey(x) == key0):
			failures.append("T%d: the %s pick did not resolve the decision (%s)" % [ui.sim.state.turn, t0, key0])
	return made


func _dkey(d: Dictionary) -> String:
	## One decision's identity (a war's opening response and its first front orders share the crisis id).
	var k := "%s:%s" % [str(d.get("type", "")), str(d.get("event", d.get("fork", d.get("envoy", d.get("fiscal_year", d.get("crisis", d.get("kind", "")))))))]
	if str(d.get("type", "")) == "crisis_response":
		k += ":%s:%s" % [str(d.get("phase", "")), str(bool(d.get("war_turn", false)))]
	return k


func _casual_end_turn() -> void:
	var before: int = ui.sim.state.turn
	if ui.sim.state.game_over:
		return
	if ui.story_c.visible and ui.story_c._btn_end != null and is_instance_valid(ui.story_c._btn_end) and ui.story_c._btn_end.is_visible_in_tree():
		_click(ui.story_c._btn_end)
	else:
		if ui.story_c.visible:
			ui.story_c.close()
		if str(ui.next_w.cur.get("type", "")) != "end_turn":
			failures.append("T%d: END TURN with decisions pending (%s)" % [before, str(ui.next_w.cur.get("type", ""))])
		_click(ui.next_w.go_btn)
	await _frames(20)
	if ui.sim.state.turn == before and not ui.sim.state.game_over:
		failures.append("T%d: END TURN did not advance (%s)" % [before, str(NextStep.primary(ui).get("type", ""))])
		ui.end_turn(true)
		await _frames(10)


func _casual_intros() -> void:
	ui.flush_intros()
	var cnt := {}
	for e in ui.intro_log:
		cnt[str(e[0])] = int(cnt.get(str(e[0]), 0)) + 1
	for k in cnt:
		if int(cnt[k]) > 1 and not seen.has("intro_twice_" + str(k)):
			seen["intro_twice_" + str(k)] = true
			failures.append("the introduction of '%s' was shown %d times" % [k, int(cnt[k])])


func _casual_turn(mode: String) -> void:
	await _casual_checks()
	var war: bool = ui.sim.state.crises.size() > 0 or not ui.sim.state.crisis_decision.is_empty()
	var t: int = ui.sim.state.turn
	var nd := await _casual_decide(mode)
	casual_turns.append([t, nd, war])
	_casual_intros()
	await _casual_end_turn()


func _casual_toggles() -> void:
	## Every ministry's toggle in the Cabinet Room: manual (its prompts reach the player and its HUD parts unlock),
	## then auto again (the minister answers what was left).
	if ui.story_c.visible:
		ui.story_c.close()
	ui._refresh_hud()
	await _frames(2)
	var calm_before := count_interactive()
	if ui.gov_btn != null:
		_click(ui.gov_btn)   # (v4 fix round: the Cabinet Room is in the Government menu)
		await _frames(3)
		var rb: Button = ui.gov_menu.find_child("bar_cabinet_room", true, false) if ui.gov_menu != null else null
		if rb != null:
			_click(rb)
	await _frames(6)
	if not ui.room_w.visible:
		failures.append("the Government menu's Cabinet Room did not open the Cabinet Room")
		ui.open_cabinet_room()
		await _frames(4)
	await shot("casual_cabinet_room")
	_check_legible(ui.room_w, "Cabinet Room")
	_in_view(ui.room_w, "Cabinet Room")
	var tgs: Array = ui.room_w.find_children("auto_*", "CheckButton", true, false)
	if tgs.size() != NextStep.DOMAINS.size():
		failures.append("Cabinet Room: %d ministry toggles (want %d)" % [tgs.size(), NextStep.DOMAINS.size()])
	var sim: Sim = ui.sim
	var done := []
	for d in NextStep.domains(sim):
		var id := str(d["id"])
		var tg: CheckButton = ui.room_w.find_child("auto_" + id, true, false)
		if tg == null:
			failures.append("Cabinet Room: no toggle for %s" % id)
			continue
		clicks += 1
		tg.toggled.emit(false)
		await _frames(4)
		if NextStep.is_auto(ui, id):
			failures.append("Cabinet Room: the %s toggle did not hand the ministry to the player" % id)
		# make the ministry's own prompt appear, as it would when its work runs out
		var probe := ""
		match id:
			"research":
				sim.state.current_tech = ""
				probe = "choose_research"
			"civics":
				sim.state.current_civic = ""
				probe = "choose_civic"
			"production":
				var cap = sim.city_by_key(sim.state.capital)
				if cap != null:
					cap.queue.clear()
					probe = "choose_production"
		ui._refresh_all()
		await _frames(2)
		var pd := NextStep.player_decisions(ui)
		if probe != "" and not pd.any(func(x): return str(x["type"]) == probe) and sim.blocking_decisions().any(func(x): return str(x["type"]) == probe):
			failures.append("Cabinet Room: with %s manual, its %s prompt did not reach the player" % [id, probe])
		var part: String = {"research": "research", "civics": "research", "production": "city_card", "units": "units", "settlement": "units", "trade": "trade"}.get(id, "")
		if part != "" and not Unlocks.is_on(ui, part):
			failures.append("Cabinet Room: taking over %s did not unlock its HUD part (%s)" % [id, part])
		if id in ["research", "civics"] and not ui.hud.story_show.has("research"):
			failures.append("Cabinet Room: the research and civic cards did not appear with %s manual" % id)
		if not seen.has("casual_manual_shot") and id == "research":
			seen["casual_manual_shot"] = true
			ui.room_w.visible = false
			await _frames(3)
			await shot("casual_research_manual")
			ui.open_cabinet_room()
			await _frames(3)
		tg = ui.room_w.find_child("auto_" + id, true, false)
		if tg == null:
			ui.set_domain_auto(id, true)
		else:
			clicks += 1
			tg.toggled.emit(true)
		await _frames(4)
		if not NextStep.is_auto(ui, id):
			failures.append("Cabinet Room: the %s toggle did not hand the ministry back" % id)
		# v4polish item 2: what only this take-over unlocked is locked again
		var pd2 := NextStep.player_decisions(ui)
		for p in Unlocks.DOMAIN_PARTS.get(id, []):
			if Unlocks.is_on(ui, str(p)) and not Unlocks.triggered(ui, str(p), pd2) and str(p) in (Unlocks.DOMAIN_PARTS.get(id, []) as Array) \
					and not Unlocks.DOMAIN_PARTS.keys().any(func(o): return o != id and not NextStep.is_auto(ui, str(o)) and str(p) in (Unlocks.DOMAIN_PARTS[o] as Array)):
				failures.append("item 2: handing %s back left its HUD part '%s' on screen" % [id, str(p)])
		if id == "civics" and ui.hud.story_show.has("research"):
			failures.append("item 2: research and civics are both back on auto but their cards stay on the HUD")
		if id == "production" and ui.hud.story_show.has("city"):
			failures.append("item 2: production is back on auto but the city card stays on the HUD")
		var left := NextStep.player_decisions(ui).filter(func(x): return NextStep.domain_of(sim, x) == id)
		if not left.is_empty():
			failures.append("Cabinet Room: handing %s back left %d of its prompts with the player" % [id, left.size()])
		done.append(id)
	ui.room_w.close()
	await _frames(3)
	say("Cabinet Room: %d ministries taken over and handed back at %s (%s)" % [done.size(), sim.date_label(), ", ".join(done)])
	ui._refresh_hud()
	await _frames(2)
	var calm_after := count_interactive()
	say("item 2: interactive elements before the take-overs %d (HUD %s), after handing every ministry back %d (HUD %s)" % [int(calm_before["total"]), str(calm_before["hud_keys"]), int(calm_after["total"]), str(calm_after["hud_keys"])])
	if int(calm_after["total"]) > int(calm_before["total"]) + 1:
		failures.append("item 2: after every ministry was handed back the screen has %d interactive elements (%d before the take-overs)" % [int(calm_after["total"]), int(calm_before["total"])])
	await shot("polish_after_hand_back")


func _casual_brief() -> void:
	## The ministers' brief changes in the Cabinet Room and in Settings > Gameplay.
	ui.open_cabinet_room()
	await _frames(4)
	var bb: Button = ui.room_w.find_child("room_brief_society", true, false)
	if bb == null:
		failures.append("Cabinet Room: no ministers' brief buttons")
	else:
		_click(bb)
		await _frames(4)
		if NextStep.brief(ui) != "society":
			failures.append("Cabinet Room: the brief did not change to Society (%s)" % NextStep.brief(ui))
	ui.room_w.close()
	ui.open_settings("gameplay")
	await _frames(4)
	var b2: Button = ui.settings_w.find_child("brief_balanced", true, false)
	if b2 == null:
		failures.append("Settings > Gameplay: no ministers' brief buttons")
	else:
		_click(b2)
		await _frames(4)
		if NextStep.brief(ui) != "balanced":
			failures.append("Settings > Gameplay: the brief did not change back to Balanced")
	ui.settings_w.close()


func _casual_style_switch() -> void:
	## Settings > Gameplay mid-game: Full control (the v3 HUD and every v3 prompt), one quarter played through the v3
	## screens, then Story again (the ministers settle at once).
	ui.open_settings("gameplay")
	await _frames(5)
	await shot("casual_settings_gameplay")
	_check_legible(ui.settings_w, "settings (gameplay)")
	_check_min_font(ui.settings_w, "settings (gameplay)")
	_in_view(ui.settings_w, "settings (gameplay)")
	var bf: Button = ui.settings_w.find_child("style_full", true, false)
	if bf == null:
		failures.append("Settings > Gameplay: no Full control button")
		ui.settings_w.close()
		return
	_click(bf)
	await _frames(6)
	if not ui.full_hud or ui.hud.story_mode or not ui.rail.visible or ui.next_w.visible or not ui.hud._hit.has("next"):
		failures.append("style switch: Full control did not bring back the v3 HUD (full %s, story HUD %s, rail %s)" % [str(ui.full_hud), str(ui.hud.story_mode), str(ui.rail.visible)])
	for dd in NextStep.DOMAINS:
		if NextStep.is_auto(ui, str(dd[0])):
			failures.append("style switch: %s stays on auto in Full control" % str(dd[0]))
	ui.settings_w.close()
	await _frames(3)
	var t0: int = ui.sim.state.turn
	await play_turns(1)
	say("style switch: one quarter in Full control (%s -> %s), next action now %s" % [SimDB.date_label(t0), ui.sim.date_label(), str(ui.sim.next_action().get("type", ""))])
	ui.open_settings("gameplay")
	await _frames(4)
	var bs: Button = ui.settings_w.find_child("style_story", true, false)
	if bs != null:
		_click(bs)
	await _frames(6)
	ui.settings_w.close()
	if not ui.is_story() or not ui.hud.story_mode:
		failures.append("style switch: Story again did not bring back the story HUD")
	var pd := NextStep.player_decisions(ui)
	for d in pd:
		if str(d["type"]) in ROUTINE_TYPES:
			failures.append("style switch: back in story mode, routine %s is still the player's" % str(d["type"]))
	say("style switch: story again at %s; unlocked %d elements; player decisions %s" % [ui.sim.date_label(), ui.unlocked.size(), str(pd.map(func(x): return x["type"]))])
	# Simplify the screen again
	ui.open_settings("gameplay")
	await _frames(4)
	var simp: Button = ui.settings_w.find_child("simplify", true, false)
	var n_before: int = ui.unlocked.size()
	if simp == null:
		failures.append("Settings > Gameplay: no Simplify the screen again")
	else:
		_click(simp)
		await _frames(4)
		if ui.unlocked.size() >= n_before:
			failures.append("Simplify the screen again re-locked nothing (%d -> %d)" % [n_before, ui.unlocked.size()])
	ui.settings_w.close()
	say("simplify: %d -> %d unlocked elements" % [n_before, ui.unlocked.size()])


func _casual_auto_advance() -> void:
	## Settings > Gameplay "Auto-advance quiet quarters": a quiet quarter ends on its own; any input stops it.
	ui.open_settings("gameplay")
	await _frames(4)
	var cb: CheckBox = ui.settings_w.find_child("auto_advance", true, false)
	if cb == null:
		failures.append("Settings > Gameplay: no auto-advance setting")
		ui.settings_w.close()
		return
	if GameSettings.auto_advance:
		failures.append("auto-advance is on by default")
	clicks += 1
	cb.button_pressed = true
	await _frames(2)
	ui.settings_w.close()
	if not GameSettings.auto_advance:
		failures.append("auto-advance: the setting did not turn on")
	seen["auto_from"] = ui.sim.state.turn   # from here every quiet quarter must end on its own (run_casual's loop)
	# the turn-start trigger itself, on a quarter made quiet: decide everything, then the quarter's start hook runs again
	await _casual_decide("mixed")
	if ui.story_c.visible:
		ui.story_c.close()
	await _frames(2)
	ui.flush_intros()
	if NextStep.quiet(ui) and ui._quiet_ok():
		var tq: int = ui.sim.state.turn
		ui._story_turn_start(false)
		await _frames(2)
		if not ui.next_w.auto_running():
			failures.append("auto-advance: a quiet quarter did not start the countdown")
		else:
			await shot("casual_auto_advance")
			await get_tree().create_timer(2.8).timeout
			await _frames(20)
			if ui.sim.state.turn == tq:
				failures.append("auto-advance: the quiet quarter %s did not end on its own" % SimDB.date_label(tq))
			else:
				seen["auto_natural"] = int(seen.get("auto_natural", 0)) + 1
				say("auto-advance: the quiet quarter %s ended on its own" % SimDB.date_label(tq))
	else:
		say("auto-advance: this quarter cannot be quiet (%s); the countdown is checked directly" % str(NextStep.player_decisions(ui).map(func(x): return x["type"])))
	# stop on input, directly: decide everything, then start the countdown and press a key
	await _casual_decide("mixed")
	if ui.story_c.visible:
		ui.story_c.close()
	await _frames(2)
	if NextStep.quiet(ui):
		var t1: int = ui.sim.state.turn
		ui.next_w.start_auto(2.0)
		await _frames(3)
		var ev := InputEventKey.new()
		ev.keycode = KEY_A
		ev.pressed = true
		ui._input(ev)
		await get_tree().create_timer(2.5).timeout
		if ui.next_w.auto_running() or ui.sim.state.turn != t1:
			failures.append("auto-advance: a key press did not stop the countdown")
		else:
			say("auto-advance: a key press stopped the countdown at %s" % SimDB.date_label(t1))


func _casual_auto_seen() -> void:
	## A quiet quarter began with auto-advance on: the countdown runs; the first ends the quarter on its own, the
	## second is stopped by a key press (then END TURN by hand).
	var t0: int = ui.sim.state.turn
	casual_turns.append([t0, 0, false])
	if int(seen.get("auto_natural", 0)) >= 1 and int(seen.get("auto_stopped", 0)) == 0:
		var ev := InputEventKey.new()
		ev.keycode = KEY_A
		ev.pressed = true
		ui._input(ev)
		await get_tree().create_timer(2.6).timeout
		if ui.next_w.auto_running() or ui.sim.state.turn != t0:
			failures.append("auto-advance: a key press did not stop the countdown at %s" % SimDB.date_label(t0))
		else:
			seen["auto_stopped"] = 1
			say("auto-advance: a key press stopped the quiet quarter %s" % SimDB.date_label(t0))
		await _casual_end_turn()
		return
	if not seen.has("auto_shot"):
		seen["auto_shot"] = true
		await shot("casual_auto_advance")
	await get_tree().create_timer(2.8).timeout
	await _frames(20)
	if ui.sim.state.turn == t0:
		failures.append("auto-advance: the quiet quarter %s did not end on its own" % SimDB.date_label(t0))
		await _casual_end_turn()
	else:
		seen["auto_natural"] = int(seen.get("auto_natural", 0)) + 1
		say("auto-advance: the quiet quarter %s ended on its own" % SimDB.date_label(t0))


func _casual_save_load() -> void:
	ui.quick_save()
	await _frames(3)
	var t: int = ui.sim.state.turn
	var un: int = ui.unlocked.size()
	var br := NextStep.brief(ui)
	ui.quick_load()
	await _frames(60)
	if ui.sim.state.turn != t or not ui.is_story() or ui.unlocked.size() < un or NextStep.brief(ui) != br:
		failures.append("save / load: story mode not restored (turn %d/%d, story %s, unlocked %d/%d, brief %s/%s)" % [ui.sim.state.turn, t, str(ui.is_story()), ui.unlocked.size(), un, NextStep.brief(ui), br])
	for dd in NextStep.DOMAINS:
		if not NextStep.is_auto(ui, str(dd[0])):
			failures.append("save / load: %s came back manual" % str(dd[0]))
	say("save / load: %s, story %s, %d unlocked, brief %s" % [ui.sim.date_label(), str(ui.is_story()), ui.unlocked.size(), NextStep.brief(ui)])


func _casual_he_texts() -> void:
	## Hebrew run: every v4 string the UI composes (the introductions, the ministries, the briefs, the prompt and card
	## labels) through the catalog audit, not only the ones a 20-turn run puts on screen.
	if not he_run():
		return
	var texts: Array = []
	for x in Unlocks.ITEMS:
		texts.append(str(x[1]))
	for d in NextStep.DOMAINS:
		texts.append_array([str(d[1]), str(d[2]), str(d[4])])
	for b in NextStep.BRIEFS:
		texts.append_array([str(b[1]), str(b[2])])
	for s in StartScreen.STYLES:
		texts.append_array([str(s[1]), str(s[2])])
	texts.append_array(["Minister of Construction and Housing", "Minister of Absorption", "The Jewish Agency", "Minister decides", "You decide",
		"A quiet quarter: continuing in 2 s", "Nothing needs you this quarter.", "Your ministers carry on with the routine.", "The game is over.",
		"Decide ▸", "END TURN → %s" % SimDB.date_label(ui.sim.state.turn + 1), "QUIET", "NOW", "THE QUARTER IS DONE", "NOTHING NEEDS YOU",
		"Story mode: your ministers run the routine; you make the big calls.", "Full control: every decision is yours.",
		"Finance kept the surplus; the programmes come up again at the budget.", "Finance deferred the programme to a quieter quarter.",
		"New government: the prime minister's programme sets the policy cards.", "Prime Minister's Office: the cabinet's titles went to the Recommended appointments.",
		"The screen is simple again: panels come back when they matter.", "This era's goals arrive with its briefing.", "Nothing to report this quarter.",
		"History itself fell short of this goal.", "Take over production", "Open the city screen", "Era goals", "Play style: Story or Full control",
		"Cabinet Room: your ministers", "Switch to Story mode", "Keep Full control", "Story mode", "More options (2)", "Fewer options", "Details",
		"[color=#9fe07a]No cost[/color]", "[color=#9fe07a]You made the historical choice.[/color]", "[color=#ffb070]You chose differently from history.[/color]"])
	for t in ["event_choice", "fork", "coalition", "state_budget", "immigration", "programme", "dedication", "brief", "choose_research", "choose_civic", "fill_policy", "policy_review", "minister", "budget_review"]:
		texts.append(NextStep.chip_label(ui.sim, {"type": t}))
	# v4 fix round: the Government menu, the labelled top bar, the read-only Cabinet, the card's glossary, the banner
	for g in StoryCard.GLOSS:
		texts.append_array([str(g[1]), str(g[2])])
	for it in ui.gov_items():
		texts.append(str(it[1]))
	texts.append_array(["Government ▴", "Cabinet Room: your ministers", "Against history: the six tracks", "Show the minimap", "Hide the minimap",
		"Treasury", "Population", "Civic Trust", "Readiness", "Standing", "Inflation", "Food", ui.overdraft_line(true), ui.overdraft_line(false),
		"Your government's screens: the Cabinet Room, the Treasury, programmes, diplomacy and how you stand against history.",
		"DECISION 1 OF 2 THIS QUARTER", "WORDS ON THIS CARD", "Then:", "A NEW ERA", "3 new era goals: see the card on the left.",
		"A new chapter of the story begins.", "The Prime Minister's Office appoints your ministers and gives out the cabinet's titles. Here is who runs what.",
		"In office.", "Not appointed yet.", "No minister is appointed yet.", "Take over appointments",
		"You choose the appointments and promotions yourself; the full Cabinet screen opens.", "Against history: 3 up, 2 level, 1 down",
		"Your Israel against history's on the six tracks (population, economy, science, water, standing, cohesion).", "The Government menu opens the details.",
		"State's health 80%: hover for why.", "An offer is on the table: Egypt would make a deal with Israel. Open Diplomacy in the Government menu to see it."])
	# v4polish: the overdraft strip, the report's glosses and "N more", the scale notes, the short Game menu and Quit,
	# the Government menu's new items, How to Play's Reference heading, the plain report lines
	texts.append_array([ui.overdraft_intro(true), ui.overdraft_intro(false), "The Treasury now has its own screen in the Government menu: its running costs and Finance's levers.",
		"5 more ▾", "Fewer ▴", "▸ Reference (17 pages)", "▾ Reference (17 pages)", "Save game... (Ctrl+S)", "Load game... (Ctrl+L)", "Settings (F10)",
		"How to play (F1)", "Civilopedia", "Quit", "Return to the title screen", "New game (same difficulty)", "Quit to desktop", "Back",
		"Unsaved progress since the last autosave is lost.", "F5 quick-saves, F9 quick-loads.", "Credits", "Era goals: every era",
		"Event log and this quarter in history", "Display, sound, controls, and Gameplay: the play style, your ministers, era goals and quiet quarters.",
		"Why Standing, Civic Trust and Readiness moved", "Standing: 45 of 100. How the world sees Israel: it opens deals, aid and backing in a crisis.",
		"Readiness: 40 of 100. How ready the army is: higher readiness makes every counter-attack hit harder and wars cost less.",
		"−28 Cohesion: a big cost (the reserve has 30).", "+3 Readiness: a small rise (from 40 to 43 of 100).", "−2 Civic Trust: a small drop (from 82 to 80 of 100).",
		"−13 gold: a medium cost (the Treasury has 70).", "+40 gold: a big gain (the Treasury has 1,200).", "−8 Standing: a big drop (from 50 to 42 of 100).",
		"Standing up", "The delegation was received: relations and Standing improve."])
	for j in MinistersPanel.JARGON:
		texts.append_array([str(j[1]), str(j[2])])
	for k in SimAuto.TEMPLATES:
		var dom := str(k).get_slice(".", 1)
		var sh := ""
		for dd in NextStep.domains(ui.sim):
			if str(dd.get("id", "")) == dom:
				sh = str(dd.get("short", ""))
		if sh != "" and not str(SimAuto.TEMPLATES[k]).contains("{title}"):
			texts.append("%s: %s" % [sh, str(SimAuto.TEMPLATES[k]).format({"n": 3, "city": "Haifa", "item": "Shikun Blocks", "gold": 40, "partner": "Haifa", "actor": "France"})])
	var miss := {}
	for t2 in texts:
		_latin_check(str(t2), "v4 texts")
		for m in L10n.audit(str(t2)):
			miss[m] = true
	if not miss.is_empty():
		i18n_by_screen["v4 composed texts"] = miss.keys()
	say("i18n v4 composed texts checked: %d" % texts.size())


func _decision_stats() -> String:
	var tot := 0; var n := 0; var mx := 0; var wt := 0; var wn := 0
	var mx_at: Array = []
	for r in casual_turns:
		if bool(r[2]):
			wt += int(r[1]); wn += 1
		else:
			tot += int(r[1]); n += 1
			if int(r[1]) > mx:
				mx = int(r[1]); mx_at = [SimDB.date_label(int(r[0]))]
			elif int(r[1]) == mx and mx_at.size() < 6:
				mx_at.append(SimDB.date_label(int(r[0])))
	return "player decisions a turn outside war %.2f (max %d at %s; %d turns); in war quarters %.2f (%d turns); quiet quarters %d" % [
		float(tot) / maxf(1.0, n), mx, ", ".join(mx_at), n, float(wt) / maxf(1.0, wn), wn, casual_turns.filter(func(r): return int(r[1]) == 0).size()]


func run_casual(turns: int) -> void:
	if not await _casual_start():
		_finish()
		return
	await _casual_t1()
	var t := 0
	while t < turns and not ui.sim.state.game_over:
		var tn: int = ui.sim.state.turn
		if GameSettings.auto_advance and ui.next_w.auto_running():
			await _casual_auto_seen()
			t += 1
			continue
		await _casual_turn("mixed")
		t += 1
		_save_at()
		if tn == 2 and not seen.has("casual_report"):
			seen["casual_report"] = true
			if not ui.report_w.is_visible_in_tree():
				failures.append("T2: the ministers' report is not on screen")
			else:
				_click(ui.report_w.toggle_btn)
				await _frames(4)
				var lines: Array = MinistersPanel.strip_lines(ui)
				say("ministers' report at %s: %d lines: %s" % [ui.sim.date_label(), lines.size(), " | ".join(lines.map(func(x): return str(x.get("text", ""))))])
				if lines.is_empty():
					failures.append("T2: the ministers' report is empty after a quarter of routine")
				await shot("casual_ministers_report")
				_check_legible(ui.report_w, "ministers' report")
				await _check_report_strip("T2")
		if ui.sim.state.turn == 3 and not seen.has("polish_intro_clear"):
			seen["polish_intro_clear"] = true
			await _check_intro_clear()
		if ui.sim.state.turn in [5, 9] and not seen.has("polish_report_%d" % ui.sim.state.turn):
			seen["polish_report_%d" % ui.sim.state.turn] = true
			await _check_report_strip("T%d" % ui.sim.state.turn)
		if ui.sim.state.turn == 12 and not seen.has("casual_toggles"):
			seen["casual_toggles"] = true
			await _casual_toggles()
			await _casual_brief()
			await _check_report_strip("T12")
		if seen.has("intro_before_end") and not seen.has("intro_end_checked"):
			seen["intro_end_checked"] = true
			if str(seen["intro_before_end"]) != "" and ui.intro_shown_id == str(seen["intro_before_end"]):
				failures.append("intro strip: End Turn did not clear the introduction '%s'" % str(seen["intro_before_end"]))
			say("intro strip: '%s' before End Turn, '%s' after" % [str(seen["intro_before_end"]), ui.intro_shown_id])
		if ui.sim.state.turn == 11 and not seen.has("casual_mid"):
			seen["casual_mid"] = true
			var c := count_interactive()
			say("casual %s interactive: %d (HUD %d %s)" % [ui.sim.date_label(), int(c["total"]), int(c["hud"]), str(c["hud_keys"])])
			await shot("casual_mid_game")
			await _casual_fix_checks()
			_check_stat_names("T11")
		if ui.sim.state.era != int(seen.get("era_now", ui.sim.state.era)) and not seen.has("era_banner_checked"):
			seen["era_banner_checked"] = true
			if not ui.era_banner.visible and ui._era_banner_t <= 0.0 and int(ui.casual.get("era_banner", -1)) != int(ui.sim.state.era):
				failures.append("era change at %s: no 'A new era' banner" % ui.sim.date_label())
			else:
				say("era banner at %s: '%s'" % [ui.sim.date_label(), (ui.era_banner.find_child("era_name", true, false) as Label).text])
				if ui.era_banner.visible:
					await shot("fix_era_banner")
		seen["era_now"] = ui.sim.state.era
		if ui.sim.state.turn == 20 and not seen.has("casual_switch") and turns >= 30:
			seen["casual_switch"] = true
			await _casual_style_switch()
		if ui.sim.state.turn == 26 and not seen.has("casual_auto") and turns >= 30:
			seen["casual_auto"] = true
			await _casual_auto_advance()
		if ui.sim.state.turn == 32 and not seen.has("casual_save") and turns >= 30:
			seen["casual_save"] = true
			await _casual_save_load()
		if t % 10 == 0:
			say("casual turn %d -> %s, cities %d, gold %d, clicks %d, actions %d" % [tn, ui.sim.date_label(), ui.sim.active_cities().size(), int(ui.sim.state.gold), clicks, ui.player_actions])
		_save_at()
	if seen.has("casual_auto"):
		say("auto-advance: %d quiet quarters ended on their own, %d stopped by a key press" % [int(seen.get("auto_natural", 0)), int(seen.get("auto_stopped", 0))])
		if int(seen.get("auto_natural", 0)) == 0 and casual_turns.any(func(r): return int(r[1]) == 0 and int(r[0]) > int(seen.get("auto_from", 999))):
			failures.append("auto-advance: quiet quarters came but none advanced on its own")
		ui.set_auto_advance(false)
	_casual_intros()
	say("map focus after decisions: %d (%s)" % [ui.focus_log.size(), str(ui.focus_log.slice(0, 6))])
	if turns >= 20 and ui.focus_log.is_empty():
		failures.append("the map never showed the place of a decision in %d turns (v4 fix A7)" % turns)
	var ids: Array = ui.intro_log.map(func(e): return "%s@T%d" % [str(e[0]), int(e[1])])
	say("unlock introductions: %s" % ", ".join(ids))
	for need in (["goals", "report", "city_view", "minimap", "help", "ghost", "budget", "queue"] if turns >= 20 else ["goals", "report"]):
		if not ui.intro_log.any(func(e): return str(e[0]) == need):
			failures.append("the '%s' element never unlocked with its introduction in %d turns" % [need, turns])
	say("casual: %d turns to %s; %s; clicks %d, player actions %d" % [t, ui.sim.date_label(), _decision_stats(), clicks, ui.player_actions])
	_check_stat_names("end")
	say("map: %d story cards opened on their place (%s); %d places lit after a decision" % [ui.preview_log.size(), str(ui.preview_log.slice(0, 6)), ui.focus_log.size()])
	if turns >= 20 and ui.preview_log.is_empty():
		failures.append("item 4: no story card in %d turns panned the map to its place" % turns)
	_casual_he_texts()
	check_he_runtime()
	await shot("casual_final_hud")
	_finish()


func _save_at() -> void:
	## --ui-test-save-at=3,20 --ui-test-save-dir=<dir>: saves for windowed captures (checked as each turn begins and
	## after the turn's checks, so a turn whose checks end quarters of their own, such as T20's style switch, still saves)
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--ui-test-save-at=") and str(ui.sim.state.turn) in a.substr(18).split(","):
			var sdir := "C:/civ/progress/v4ui/saves"
			for b in OS.get_cmdline_user_args():
				if b.begins_with("--ui-test-save-dir="):
					sdir = b.substr(19)
			DirAccess.make_dir_recursive_absolute(sdir)
			var sp := "%s/story_t%03d.json" % [sdir, ui.sim.state.turn]
			if not seen.has(sp):
				seen[sp] = true
				say("saved %s: %s" % [sp, str(SaveSlots.write(sp, ui.sim, ui.ui_state(), "Story %s" % ui.sim.date_label(), "manual"))])


func run_casual_scenarios(turns: int) -> void:
	## The scenario starts (1967, 1977, 1992) in story mode: the briefing, then a few quarters through the story card.
	var avail := V3Adapter.scenarios().filter(func(x): return bool(x.get("available", false)) and str(x.get("id", "")) != "")
	var want: Array = avail.map(func(x): return str(x["id"]))
	say("casual scenario starts: %s" % ", ".join(want))
	if want.is_empty():
		failures.append("casual scenarios: no scenario start is available")
	for sid in want:
		if not await _casual_start(str(sid)):
			continue
		var t0: int = ui.sim.state.turn
		if t0 <= 1:
			failures.append("casual scenario %s: the game did not start at its date" % sid)
			continue
		if not (ui.popup.visible and ui.popup.mode == "result"):
			failures.append("casual scenario %s: no briefing" % sid)
		else:
			await shot("casual_scenario_%s_briefing" % sid)
			var cb := _find_button(ui.popup, "Continue")
			if cb != null:
				_click(cb)
			await _frames(6)
		say("casual scenario %s: %s (turn %d); goals '%s'" % [sid, ui.sim.date_label(), t0, ui.goals_w.head_btn.text])
		for k in turns:
			if ui.sim.state.game_over:
				break
			await _casual_turn("mixed")
		if ui.sim.state.turn <= t0:
			failures.append("casual scenario %s: no quarter was played" % sid)
		var up: Array = ui.sim.get_upcoming_events(400)
		if up.any(func(x): return int(x.get("turn", 0)) > Sim.last_playable_turn()):
			failures.append("casual scenario %s: Coming up lists events after the last turn" % sid)
		say("casual scenario %s: played to %s; %s" % [sid, ui.sim.date_label(), _decision_stats()])
		await shot("casual_scenario_%s_end" % sid)
		casual_turns.clear()
	_finish()


func run_casual_end() -> void:
	## The whole game in story mode through the UI, history's story picks (the history option is always among the
	## three), auto-advance off; then the same game's decisions in Full control on the Recommended path at v3's
	## minimum clicks (V4_DESIGN 2.7). Prints CLICKS casual N / full M = ratio; fails under 4.0. Checks the memorial.
	ui.fast_dates = true
	if not await _casual_start():
		_finish()
		return
	var t0 := Time.get_ticks_msec()
	clicks = 0
	ui.player_actions = 0
	var guard := 0
	while not ui.sim.state.game_over and guard < 330:
		guard += 1
		await _casual_turn("history")
		if ui.story_c.visible and ui.sim.state.game_over:
			ui.story_c.close()
		if ui.sim.state.turn % 40 == 0:
			say("casual end: %s, clicks %d, %d s" % [ui.sim.date_label(), clicks, (Time.get_ticks_msec() - t0) / 1000])
	await _frames(30)
	var casual_clicks := clicks
	var casual_actions: int = ui.player_actions
	say("casual end: game over %s at %s in %d s; clicks %d, player actions %d; %s" % [str(ui.sim.state.game_over), ui.sim.date_label(), (Time.get_ticks_msec() - t0) / 1000, casual_clicks, casual_actions, _decision_stats()])
	if not ui.sim.state.game_over:
		failures.append("casual end: the game did not end")
	if MemorialScreen.applies(ui.sim):
		var md := MemorialScreen.load_data(ui.sim)
		var want := "\n\n".join(PackedStringArray(md.get("paragraphs", []) + [md.get("closing", "")]))
		if ui.last_memorial_text != want:
			failures.append("casual end: the memorial text was not shown verbatim")
		else:
			say("casual end: memorial shown verbatim (%d chars)" % want.length())
	if not ui.end_s.visible:
		failures.append("casual end: the end screen did not open")
	var ep: Dictionary = ui.sim.get_epilogue() if ui.sim.has_method("get_epilogue") else {}
	var sc: Dictionary = ui.sim.get_score()
	say("casual end: ending %s, overall %s" % [str(ep.get("name", "")), str(sc.get("overall", sc.get("summary", "")))])
	await shot("casual_end_screen")
	_check_end_dates("casual end")
	ui.end_s.close()
	# Full control: the same start, every decision through next_action at v3's minimum clicks
	var full_clicks := 0
	var full_dec := 0
	ui.test_style = "full"
	ui.start_new_game(true, false, {"difficulty": "normal", "play_style": "full"})
	await _frames(20)
	var sim: Sim = ui.sim
	var t1 := Time.get_ticks_msec()
	var g2 := 0
	while not sim.state.game_over and g2 < 330:
		g2 += 1
		var gg := 0
		while gg < 400:
			gg += 1
			var a := sim.next_action()
			if str(a["type"]) == "end_turn":
				break
			full_clicks += int(V3_CLICKS.get(str(a["type"]), 2))
			full_dec += 1
			var ok := false
			if str(a["type"]) == "unit_orders":
				var u = sim.unit_by_id(int(a["unit"]))
				if u != null:
					if u.type == "builder": SimAI._builder(sim, u)
					elif u.type == "settler": SimAI._settler(sim, u)
					else: SimAI._military(sim, u)
				ok = true
				if sim.blocking_decisions().any(func(x): return str(x["type"]) == "unit_orders" and int(x["unit"]) == int(a["unit"])):
					ok = sim.resolve_recommended(a)
			else:
				ok = sim.resolve_recommended(a)
			if not ok:
				break
		full_clicks += 1
		if not sim.end_turn(false):
			sim.end_turn(true)
		ui._notes.clear()
		if sim.state.turn % 60 == 0:
			say("full control count: %s, clicks %d (%d s)" % [sim.date_label(), full_clicks, (Time.get_ticks_msec() - t1) / 1000])
	var ratio := float(full_clicks) / maxf(1.0, float(casual_clicks))
	say("CLICKS casual %d / full %d = %.2f (full control: %d decisions to %s; casual player actions %d)" % [casual_clicks, full_clicks, ratio, full_dec, sim.date_label(), casual_actions])
	print("CLICKS casual %d / full %d = %.2f" % [casual_clicks, full_clicks, ratio])
	if ratio < 4.0:
		failures.append("click ratio %.2f under 4.0 (casual %d, full %d)" % [ratio, casual_clicks, full_clicks])
	_finish()
