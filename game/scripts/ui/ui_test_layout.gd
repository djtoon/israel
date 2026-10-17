class_name LayoutAudit
extends RefCounted
## layout-audit (UITest mode --ui-test-layout; headless, a few minutes):
##   tools/godot.sh --headless --path /c/civ/game -- --shot=<x.png> --ui-test=<dir> --ui-test-layout [--ui-test-layout-quick]
## The HUD draws its 1672x941 reference layout scaled by the screen height (HUD._ref_scale) and anchored left / right /
## centre; the UI's Controls are placed in the window's own units. On a screen that is not 16:9, or at a UI scale other
## than 100%, a Control that does not follow the HUD's scale slides under (or over) the HUD's drawn parts: the user's
## report, 2026-10-17 ("THIS QUARTER IN HISTORY" over the VS. HISTORY chip on a 16:10 screen).
## For every play style, turn (1 and 11), screen size and UI scale, this collects the screen rects of every HUD-drawn part
## and every visible Control panel, in several scenes (bare HUD, toast and banners, advisor card, docked windows, unit
## panel and combat preview, health strip, Government menu), and fails on every overlap of two things that must not
## overlap, and on every panel that runs off the screen. Headless, each screen is reproduced exactly by its stretched
## canvas (content_scale_size with aspect KEEP: --resolution does not size the headless window).

## [physical screen, its stretched canvas (aspect "expand" on the 1672x941 base)] (the first is the reference itself)
const SCREENS := [Vector2i(1672, 941), Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(1920, 1200), Vector2i(1440, 900),
	Vector2i(2560, 1600), Vector2i(1280, 1024), Vector2i(2560, 1080)]
const SCALES := [0.9, 1.0, 1.25, 1.5]
const LATE_TURN := 11   # past Q2 1950: VS. HISTORY and the history sidebar both show (GameUI.GHOST_FROM_TURN = 9)

## Overlaps that are the design (the same at 1672x941): [a, b, why]. Names are prefixes (see _collect).
const ALLOW := [
	["p:now_queue", "p:now", "the queue line is a row of the NOW card"],
]


## Known and reported, not failed: [screen, element, why]. (Nice-to-have per the lead, 2026-10-17.)
const KNOWN := [
	["1280x1024", "p:cpv", "5:4 (the HUD layout is 1176 units wide): the combat preview, shown while hovering an attack target, has no free spot left of the unit panel and covers the city card / history sidebar"],
]


static func _known(sk: String, p: String) -> bool:
	for kn in KNOWN:
		if sk == str(kn[0]) and p.contains(str(kn[1])):
			return true
	return false


static func canvas_for(screen: Vector2i) -> Vector2i:
	## The canvas a screen of this size gets under canvas_items / expand on the 1672x941 base.
	var base := Vector2(1672, 941)
	var s := Vector2(screen)
	if s.x / s.y >= base.x / base.y:
		return Vector2i(int(round(base.y * s.x / s.y)), 941)
	return Vector2i(1672, int(round(base.x * s.y / s.x)))


static func hud_rects(ui) -> Array:
	## [name, screen rect] of every part the HUD draws now (its _draw), in the HUD's pixels.
	var hud: HUD = ui.hud
	var k: float = hud._ref_scale()
	var out := []
	var lv: Dictionary = hud.live
	var refs := []
	refs.append(["hud:topbar", Rect2(0, 0, hud.size.x / k, 49)])
	var gd: Dictionary = lv.get("ghost", {})
	var ghost_on := lv.has("ghost") and (not hud.story_mode or hud.story_show.has("ghost"))
	var city_on: bool = not (lv.get("city", {}) as Dictionary).is_empty() and (not hud.story_mode or hud.story_show.has("city"))
	if not hud.story_mode or hud.story_show.has("research"):
		refs.append(["hud:research", hud._hit_rect("research")])
		refs.append(["hud:civic", hud._hit_rect("civic")])
	if ghost_on:
		refs.append(["hud:ghost", hud._ghost_r()])
		if float(gd.get("health", 1.0)) < 0.995 and str(gd.get("health_text", "")) != "":
			refs.append(["hud:health", hud._ghost_health_r()])
	if city_on:
		refs.append(["hud:city", HUD.R_CITY])
	if not hud.story_mode or hud.story_show.has("minimap"):
		refs.append(["hud:minimap", Rect2(Vector2(hud._xr(HUD.R_MINIMAP.position.x), HUD.R_MINIMAP.position.y), HUD.R_MINIMAP.size).grow(3)])
		refs.append(["hud:mmtools", Rect2(Vector2(hud._xr(HUD.R_MMTOOLS.position.x), HUD.R_MMTOOLS.position.y), HUD.R_MMTOOLS.size)])
	if not hud.story_mode:
		refs.append(["hud:next", Rect2(Vector2(hud._xr(HUD.R_NEXT.position.x), HUD.R_NEXT.position.y), HUD.R_NEXT.size).grow(3)])
		for i in HUD.ACTIONS.size():
			var cx: float = hud._xc(HUD.ACTION_X[i])
			var lw := UIKit.text_width(str(HUD.ACTIONS[i][1]), "body", 17) + 16.0
			var wv := maxf(76.0, lw)
			refs.append(["hud:act_" + str(HUD.ACTIONS[i][0]), Rect2(cx - wv * 0.5, HUD.ACTION_Y - 38.0, wv, 98.0)])
	for e in refs:
		var r: Rect2 = e[1]
		out.append([e[0], Rect2(r.position * k, r.size * k)])
	return out


static func _ctl(out: Array, nm: String, c) -> void:
	if c == null or not is_instance_valid(c) or not (c is Control):
		return
	var ctl := c as Control
	if not ctl.is_visible_in_tree() or ctl.size.x < 2.0 or ctl.size.y < 2.0:
		return
	out.append([nm, ctl.get_global_rect()])


static func _union(out: Array, nm: String, parent) -> void:
	## The visible children of a box as one rect (the rail's cards, the satellite buttons).
	if parent == null or not (parent as Control).is_visible_in_tree():
		return
	var u := Rect2()
	var any := false
	for c in (parent as Node).get_children():
		if c is Control and (c as Control).is_visible_in_tree() and (c as Control).size.y > 1.0 and not (c as Node).is_queued_for_deletion():
			var r := (c as Control).get_global_rect()
			u = r if not any else u.merge(r)
			any = true
	if any:
		out.append([nm, u])


static func panel_rects(ui) -> Array:
	var out := []
	_ctl(out, "p:ticker", ui.ticker)
	_union(out, "p:rail", ui.rail)
	_union(out, "p:sats", ui.sats)
	_ctl(out, "p:toast", ui.toast)
	_ctl(out, "p:cpv", ui.cpv)
	_ctl(out, "p:goals", ui.goals_w)
	_ctl(out, "p:strip", ui.report_w)
	if ui.next_w != null and ui.next_w.is_visible_in_tree():
		_ctl(out, "p:now", ui.next_w.card)
		_ctl(out, "p:now_queue", ui.next_w.queue_lbl)
		if ui.next_w.chips.get_child_count() > 0:
			_ctl(out, "p:now_chips", ui.next_w.chips)
		_ctl(out, "p:now_auto", ui.next_w.auto_bar)
	_ctl(out, "p:gov_btn", ui.gov_btn)
	_ctl(out, "p:gov_menu", ui.gov_menu)
	_ctl(out, "p:intro", ui.intro_w)
	_ctl(out, "p:era", ui.era_banner)
	if ui.tutorial != null:
		_ctl(out, "p:advisor", ui.tutorial.card)
	for w in [ui.research_p, ui.civic_p]:
		_ctl(out, "win:left", w)
	_ctl(out, "win:right", ui.city_s)
	_ctl(out, "win:unit", ui.unit_p)
	var ov = ui.game.get("overlay") if ui.game != null else null
	if ov != null and ov is MapLabels:
		for h in (ov as MapLabels).banner_hits:
			out.append(["banner:" + str(h.get("id", "")), h["rect"]])
	return out


static func _kind(n: String) -> String:
	return n.split(":")[0]


static func must_not(a: String, b: String) -> bool:
	## The pairs that must never overlap.
	var ka := _kind(a)
	var kb := _kind(b)
	if ka == "hud" and kb == "hud":
		return false   # (the HUD's own drawing)
	if ka == "banner" and kb == "banner":
		return false   # (MapLabels declutters its banners)
	if (ka == "banner" and kb == "win") or (ka == "win" and kb == "banner"):
		return false   # (a window covers the map)
	for al in ALLOW:
		if (a.begins_with(al[0]) and b.begins_with(al[1])) or (a.begins_with(al[1]) and b.begins_with(al[0])):
			return false
	if ka == "win" or kb == "win":
		var w := a if ka == "win" else b
		var o := b if ka == "win" else a
		if _kind(o) == "win":
			return true                    # two docked windows side by side
		if w == "win:unit":
			return _kind(o) == "hud" or o in ["p:cpv", "p:sats", "p:rail"]   # the unit panel has its own slot by the action bar (the rail ends above it)
		if _kind(o) == "hud":
			return o == "hud:topbar" or (w == "win:right" and o == "hud:next")   # windows open under the top bar; the right one above NEXT TURN
		return false                       # a window may cover the HUD's side panels (it is on top while open)
	return true


static func overlaps(rects: Array) -> Array:
	var res := []
	for i in rects.size():
		for j in range(i + 1, rects.size()):
			var a: Array = rects[i]
			var b: Array = rects[j]
			if not must_not(str(a[0]), str(b[0])):
				continue
			var ir := (a[1] as Rect2).intersection(b[1] as Rect2)
			if ir.size.x > 1.5 and ir.size.y > 1.5:
				res.append("%s x %s" % [a[0], b[0]] if str(a[0]) < str(b[0]) else "%s x %s" % [b[0], a[0]])
	return res


static func offscreen(rects: Array, vp: Vector2) -> Array:
	var res := []
	var sr := Rect2(Vector2.ZERO, vp).grow(1.0)
	for e in rects:
		if _kind(str(e[0])) in ["banner"]:
			continue
		if not sr.encloses(e[1] as Rect2):
			res.append("offscreen %s" % e[0])
	return res


# ------------------------------------------------------------------ the run

static func _close_windows(ui) -> void:
	for w in [ui.research_p, ui.civic_p, ui.city_s, ui.unit_p, ui.popup, ui.info_p, ui.policy_p, ui.ghost_p, ui.pedia, ui.save_w,
			ui.cabinet_p, ui.diplo_w, ui.prog_w, ui.settings_w, ui.fiscal_w, ui.help, ui.end_s, ui.story_c, ui.room_w, ui.credits_w]:
		if w != null and (w as Control).visible:
			(w as Control).visible = false
	if ui.tree_w != null:
		ui.tree_w.visible = false
	if ui.gov_menu != null:
		ui.gov_menu.visible = false
	ui.select_unit(-1)
	if ui.cpv != null:
		ui.cpv.visible = false
	if ui.toast != null:
		ui.toast.visible = false
		ui._toast_t = 0.0
	if ui.era_banner != null:
		ui.era_banner.visible = false
		ui._era_banner_t = 0.0
	ui._hide_intro()
	ui._intro_gap = 0.0
	if ui.tutorial != null:
		ui.tutorial.tip = ""
		ui.tutorial.card.visible = false


static func _rail_items(ui) -> void:
	var t: int = ui.sim.state.turn
	ui.rail.set_items([{"kind": "event", "text": "The Knesset meets for the first time in Jerusalem", "turn": t},
		{"kind": "production", "text": "Tel Aviv-Yafo finished a Granary", "turn": t},
		{"kind": "tech", "text": "Research complete: Irrigation. Choose the next technology.", "turn": t}])


static func _scene(t: UITest, ui, scene: String) -> bool:
	## Puts the screen in one scene; false = the scene does not apply here.
	_close_windows(ui)
	_rail_items(ui)
	match scene:
		"hud":
			pass
		"toast":
			ui.show_toast("Saved: the game is saved in slot 3 (Q2 1950). Load it from the Menu at any time.", 30.0)
			if ui.is_story():
				ui.show_era_banner()
				ui._era_banner_t = 30.0
				ui.queue_intro("layout_audit", "The Treasury now has its own screen in the Government menu: its running costs and Finance's levers.")
				ui._intro_tick(0.0)
		"advisor":
			ui.tutorial.tip = "layout_audit"   # a plain advisor tip: the card sits beside the decision button
			ui.tutorial.card.visible = true
			ui.tutorial._place_card()
		"docks":
			var c = ui.sim.city_by_key(ui.sim.state.capital)
			if c == null:
				return false
			ui.open_city(c.id)
			await t._frames(2)
			ui.research_p.visible = true   # (the left dock beside the city screen: both docks at once)
			ui._front(ui.research_p)
		"unit":
			var uid := -1
			for u in ui.sim.get_units("player"):
				uid = int(u["id"])
				break
			if uid < 0:
				return false
			ui.select_unit(uid)
			await t._frames(1)
			if not ui.unit_p.visible:
				return false
			ui.cpv.show_unit({"win_odds": 0.62, "attacker_name": "7th Brigade", "defender_name": "Hostile armour", "attacker": 30, "defender": 26,
				"dealt_range": [18, 30], "taken_range": [8, 16], "kill_chance": 0.2, "modifiers": [{"label": "Flanking", "amount": 2, "side": "attacker"}, {"label": "Hills", "amount": 3, "side": "defender"}]})
			ui.cpv.visible = true
		"health":
			if ui.is_story():
				return false
			var g: Dictionary = (ui.hud.live.get("ghost", {}) as Dictionary)
			if not ui.hud.live.has("ghost"):
				return false
			g["health"] = 0.82
			if str(g.get("health_text", "")) == "":
				g["health_text"] = "State's health 82%: the debt weighs on the score"
			ui.hud.live["ghost"] = g
			ui._ticker_health = true
			ui._place_ticker()
			ui.hud.queue_redraw()
		"gov_menu":
			if not ui.is_story() or ui.gov_btn == null:
				return false
			ui.toggle_gov_menu()
	await t._frames(5)
	# what GameUI refreshes every 0.2 s (the rail's bottom, the map labels' occluders), now, then the map labels redraw
	ui._fit_rail()
	ui._label_occluders()
	var ov = ui.game.get("overlay") if ui.game != null else null
	if ov != null:
		(ov as CanvasItem).queue_redraw()
	await t._frames(2)
	if scene == "health":   # (a camera move may have refreshed the HUD: keep the strip on)
		if not float((ui.hud.live.get("ghost", {}) as Dictionary).get("health", 1.0)) < 0.995:
			return false
	return true


static func _set_screen(t: UITest, screen: Vector2i, sc: float) -> void:
	var win := t.get_window()
	if DisplayServer.get_name() == "headless":   # (windowed: the real screen as it is)
		win.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
		win.content_scale_size = canvas_for(screen)
	GameSettings.ui_scale = sc
	GameSettings.apply_scale()
	# the player's scale with the real screen's legibility floor (GameSettings.effective_scale reads the headless
	# window as 1280x720)
	UIWindow.ui_scale = maxf(sc, minf(12.0 * 941.0 / (16.0 * float(screen.y)), 1.0))
	await t._frames(3)


static func audit_config(t: UITest, ui, screen: Vector2i, sc: float) -> Dictionary:
	## Every scene at one screen size and UI scale: {scene: [problems]} (scenes that do not apply are left out).
	await _set_screen(t, screen, sc)
	var res := {}
	for scene in ["hud", "toast", "advisor", "docks", "unit", "health", "gov_menu"]:
		var ok: bool = await _scene(t, ui, scene)
		if not ok:
			continue
		var rects: Array = hud_rects(ui) + panel_rects(ui)
		var vp: Vector2 = ui.root.get_viewport_rect().size
		var probs: Array = overlaps(rects) + offscreen(rects.filter(func(e): return _kind(str(e[0])) != "hud"), vp)
		res[scene] = probs
		if DisplayServer.get_name() != "headless" and scene in ["hud", "unit", "health", "gov_menu"]:   # windowed: a screenshot of each
			await t.shot("layout_%s_T%d_%dx%d_%s" % ["story" if ui.is_story() else "full", ui.sim.state.turn, screen.x, screen.y, scene])
		if not probs.is_empty() and t.seen.get("layout_rects_said", 0) < 60:
			t.seen["layout_rects_said"] = int(t.seen.get("layout_rects_said", 0)) + 1
			t.say("layout rects %s %dx%d %d%% %s: %s" % ["story" if ui.is_story() else "full", screen.x, screen.y, int(sc * 100), scene,
				", ".join(rects.filter(func(e): return _kind(str(e[0])) != "banner").map(func(e): return "%s %s" % [e[0], str(e[1])]))])
	_close_windows(ui)
	ui.rail.set_items([])
	ui._refresh_hud()
	return res


static func _start(t: UITest, ui, style: String) -> void:
	if ui.sim != null:
		ui.return_to_start()
		await t._frames(10)
	ui.test_style = style
	ui.start_new_game(true)
	await t._frames(90)
	_close_windows(ui)
	ui._refresh_all()
	await t._frames(10)


static func run(t: UITest) -> void:
	var ui = t.ui
	ui.harness_begin()   # (windowed: capture.gd's --shot waits for the audit instead of quitting after 90 frames)
	var quick :="--ui-test-layout-quick" in OS.get_cmdline_user_args()
	var screens: Array = SCREENS if not quick else [SCREENS[0], Vector2i(1920, 1200), Vector2i(1280, 1024), Vector2i(2560, 1080)]
	var scales: Array = SCALES if not quick else [1.0, 1.5]
	var phases := ["T1", "late"]
	if DisplayServer.get_name() != "headless":   # windowed (screenshots): the real window, 100%, the late turn
		screens = [DisplayServer.window_get_size()]
		scales = [1.0]
		phases = ["late"]
	var table := {}       # "style T<turn>" -> {"WxH": {"pct": [problems]}}
	var total := 0
	var distinct := {}
	for style in ["full", "story"]:
		await _start(t, ui, style)
		if ui.sim == null:
			t.failures.append("layout: the %s game did not start" % style)
			continue
		for phase in phases:
			if phase == "late":
				ui.fast_forward(LATE_TURN)
				await t._frames(20)
				_close_windows(ui)
				ui._refresh_all()
				await t._frames(10)
			var key := "%s T%d" % [style, ui.sim.state.turn]
			table[key] = {}
			for screen in screens:
				var sk := "%dx%d" % [screen.x, screen.y]
				table[key][sk] = {}
				for sc in scales:
					var r: Dictionary = await audit_config(t, ui, screen, sc)
					var probs := []
					for scene in r:
						for p in r[scene]:
							probs.append("%s [%s]" % [p, scene])
							distinct[p] = int(distinct.get(p, 0)) + 1
					table[key][sk][str(int(sc * 100))] = probs
					total += probs.size()
					t.say("LAYOUT %s %s %d%%: %s" % [key, sk, int(sc * 100), ("%d problems: %s" % [probs.size(), "; ".join(probs)]) if not probs.is_empty() else "clean (%s)" % ",".join(r.keys())])
					var fails: Array = probs.filter(func(p): return not _known(sk, str(p)))
					if fails.size() < probs.size():
						t.say("LAYOUT-KNOWN %s %s %d%%: %d known (see KNOWN)" % [key, sk, int(sc * 100), probs.size() - fails.size()])
					if not fails.is_empty():
						t.failures.append("layout %s %s %d%%: %s" % [key, sk, int(sc * 100), "; ".join(fails)])
	# back to the reference screen
	await _set_screen(t, Vector2i(1672, 941), 1.0)
	# the summary: problems per configuration
	for key in table:
		var head := "LAYOUT-TABLE %-12s" % key
		for sc in scales:
			head += " %5d%%" % int(sc * 100)
		t.say(head)
		for sk in table[key]:
			var row := "LAYOUT-TABLE   %-10s" % sk
			for sc in scales:
				row += " %6d" % (table[key][sk][str(int(sc * 100))] as Array).size()
			t.say(row)
	var dl: Array = distinct.keys()
	dl.sort()
	for p in dl:
		t.say("LAYOUT-PAIR %4d  %s" % [int(distinct[p]), p])
	t.say("LAYOUT total problems %d over %d configurations" % [total, 2 * 2 * screens.size() * scales.size()])
	var fa := FileAccess.open(t.dir + "/layout.json", FileAccess.WRITE)
	if fa:
		fa.store_string(JSON.stringify({"table": table, "pairs": distinct}, " "))
	t._finish()
