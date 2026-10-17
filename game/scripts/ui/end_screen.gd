class_name EndScreen
extends UIWindow
## The end summary (after Q3 2023, or at a collapse) (Civ VI end-of-game style): overall result, the six tracks against the ghost of
## history with real-world labels, key stats over time (you vs the ghost), and "Your Israel vs history"
## (fork and event choices against what history chose, with their lasting terms).

const CHARTS := [["population", "Population", UIKit.GOLD_LIGHT], ["economy", "Economy (output per capita)", Color(0.55, 0.85, 0.35)],
	["standing", "International standing", Color(0.45, 0.75, 1.0)]]


var _scroll: ScrollContainer     # the body between the pinned verdict and the pinned buttons
var _inner: VBoxContainer
var _buttons: HBoxContainer
var _summary := {}
var _all_reasons := false        # "What made the difference": 5 one-line items, or every item in full
const REASONS_SHOWN := 5


func _init() -> void:
	super._init("Your Israel vs History")


func _process(d: float) -> void:
	## Pinned title, verdict and buttons; the scroll area takes what is left of the screen (never off-screen).
	if visible and _scroll != null and is_instance_valid(_scroll):
		var vp := view_size()
		var chrome := get_combined_minimum_size().y - _scroll.custom_minimum_size.y
		var want := _inner.get_combined_minimum_size().y
		var room := maxf(120.0, vp.y - 24.0 - chrome)
		var h := clampf(want, 120.0, room)
		if absf(_scroll.custom_minimum_size.y - h) > 0.5:
			_scroll.custom_minimum_size.y = h
	super._process(d)


func show_summary(summary: Dictionary) -> void:
	_summary = summary
	_all_reasons = false
	_open.clear()
	_build()


func _build() -> void:
	var summary := _summary
	var keep_scroll := _scroll.scroll_vertical if _scroll != null and is_instance_valid(_scroll) else 0
	clear_body()
	var sim: Sim = ui.sim
	var s: Dictionary = sim.get_score()
	for k in summary:
		if not s.has(k):
			s[k] = summary[k]
	if sim.has_method("get_end_summary"):   # sim round 5: one call with tracks, verdict, ledger, crises, highlights
		var es: Dictionary = sim.get_end_summary()
		for k in es:
			s[k] = es[k]
	var end_date := end_label(sim)
	title_label.text = "%s: YOUR ISRAEL VS HISTORY" % end_date.to_upper()
	var has_ghost: bool = s.get("has_ghost", false)
	var ahead := int(s.get("ahead", 0)); var even := int(s.get("even", 0)); var behind := int(s.get("behind", 6 - ahead - even))
	var verdict := "You outperformed history on %d of 6 tracks" % ahead if ahead >= 4 else ("You matched history overall" if ahead + even >= 3 else "History did better on most tracks")
	if str(s.get("verdict", "")) != "":
		verdict = str(s["verdict"]).trim_suffix(".")
	var ending := V3Adapter.ending(sim, s)
	var head := "[font_size=26][color=#f7dc8f]%s.[/color][/font_size]\n" % verdict
	if not ending.is_empty():
		var also: Array = ending.get("also", [])
		head = "[font_size=28][color=#f7dc8f]%s[/color][/font_size]   [color=#c8ccd6]%s.[/color]%s\n" % [str(ending.get("name", "")).to_upper(), verdict,
			("  [color=#9fe07a]Also reached: %s.[/color]" % ", ".join(also.map(func(x): return V3Adapter.ending_name(sim, str(x))))) if also.size() > 0 else ""]
	var collapsed := bool(ending.get("collapse", false)) or str(s.get("collapse", "")) != ""
	if collapsed and not ending.is_empty():
		# v3 item 13: a collapse of the state ended the game early (no memorial; the results follow as usual)
		end_date = sim.date_label()   # a collapse ends the game at its own date
		title_label.text = "%s: THE GAME ENDS EARLY" % end_date.to_upper()
		head = "[font_size=28][color=#ff8f7a]%s[/color][/font_size]   [color=#c8ccd6]The game ended early, in %s. The results below are measured at that date.[/color]\n" % [str(ending.get("name", "")).to_upper(), end_date]
	if has_ghost:
		head += "Ahead on [color=#9fe07a][b]%d[/b][/color], level on [b]%d[/b], behind on [color=#ff8f7a][b]%d[/b][/color].   Overall [b]%d%%[/b] of history's level.   " % [ahead, even, behind, int(round(float(s.get("overall", 100))))]   # rounded like the epilogue's %.0f
	# the same count as the epilogue's "Of N cabinet decisions, you answered M differently" (V3 full-game critic, minor)
	var cab: Array = sim.forks.get_path_ledger() if sim.get("forks") != null and sim.forks.has_method("get_path_ledger") else []
	var cab_own := cab.filter(func(x): return not bool(x.get("matched_history", true))).size()
	var cab_n := cab.size()
	var lsum: Dictionary = s.get("ledger_summary", {}) if s.get("ledger_summary") is Dictionary else {}
	if lsum.has("differed") and lsum.has("decisions"):   # fix4-econ: one source for every count of the end screen
		cab_own = int(lsum["differed"])
		cab_n = int(lsum["decisions"])
	var n_cr = s.get("crises", sim.state.crisis_log.size())
	var n_tl = summary.get("timeline", sim.state.timeline.size())
	head += "[color=#a8b0c4]%d of %d cabinet decisions answered differently from history; %d historic moments; %d crises.[/color]" % [cab_own, cab_n, (n_tl.size() if n_tl is Array else int(n_tl)), (n_cr.size() if n_cr is Array else int(n_cr))]
	if Sim.is_demo():
		title_label.text = "DEMO COMPLETE: %s" % sim.date_label().to_upper()
		head = "[font_size=22][color=#f7dc8f]Thanks for playing the demo of Israel: The Birth of a Nation.[/color][/font_size]\n[color=#dfe6f3]The demo ends after the Six-Day War. The full game continues to 7 October 2023: the War of Attrition, 1973, peace with Egypt, the 1990s aliyah and more.[/color]\n\n" + head
	body.add_child(UITheme.rich(head, 17))   # pinned: the verdict stays on screen however long the body is
	body.add_child(UITheme.sep())            # a rule between the pinned verdict and the scrolling body: scrolled text ends there (V3 fixes B3)
	# --- the scrolling body
	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.custom_minimum_size = Vector2(0, 300)
	body.add_child(_scroll)
	_inner = VBoxContainer.new()
	_inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_inner.add_theme_constant_override("separation", 6)
	_scroll.add_child(_inner)
	if not ending.is_empty():
		_epilogue(ending)
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 18)
	_inner.add_child(cols)
	# --- left: the six tracks
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(560, 0)
	cols.add_child(left)
	left.add_child(UITheme.title("THE SIX TRACKS", 16, UIKit.GOLD))
	var g := GridContainer.new()
	g.columns = 4
	g.add_theme_constant_override("h_separation", 12)
	g.add_theme_constant_override("v_separation", 3)
	left.add_child(g)
	for k in ["Track", "You", "History", ""]:
		g.add_child(UITheme.label(k, 15, UIKit.GOLD, "title"))
	var reals := []
	var track_names := {}
	for t in s.get("tracks", []):
		track_names[str(t.get("id", ""))] = str(t.get("name", "")).split(" (")[0]
		var valid := has_ghost and float(t.get("ghost", 0)) > 0
		var nm := UITheme.label(str(t["name"]), 16, UIKit.TEXT, "body_bold")
		nm.custom_minimum_size = Vector2(230, 0)
		nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		g.add_child(nm)
		g.add_child(UITheme.label(GhostPanel._fmt(str(t["id"]), float(t["player"])), 16))
		g.add_child(UITheme.label(GhostPanel._fmt(str(t["id"]), float(t["ghost"])) if valid else "-", 16, UIKit.TEXT_DIM))
		var st := str(t.get("status", "ahead" if t.get("ahead", false) else "behind"))
		var stc: Color = UIKit.GREEN if st == "ahead" else (UIKit.TEXT_DIM if st == "even" else UIKit.BAD)
		g.add_child(UITheme.label(("%s  %s" % [{"ahead": "ahead", "even": "level", "behind": "behind"}.get(st, st), SimScore.ratio_text(float(t.get("ratio", 1)))]) if valid else "", 15, stc, "body_bold"))
		var lab: Dictionary = t.get("label", {})
		if not lab.is_empty() and float(lab.get("history", 0)) > 0:
			reals.append("%s: real %s %s, yours on that scale %s [%s]" % [str(t["name"]).split(" (")[0], GhostPanel._short(float(lab["history"])), str(lab.get("unit", "")), GhostPanel._short(float(lab.get("player", 0))), ", ".join(lab.get("source", []))])
	var reasons: Array = s.get("reasons", [])
	if reasons.size() > 0:
		left.add_child(UITheme.title("WHAT MADE THE DIFFERENCE", 15, UIKit.GOLD))
		var shown: Array = reasons if _all_reasons else reasons.slice(0, REASONS_SHOWN)
		for r in shown:
			left.add_child(_reason_line(r, track_names, _all_reasons))
		var more_txt := "Show fewer" if _all_reasons else (("Show all %d in full" % reasons.size()) if reasons.size() > REASONS_SHOWN else "Show in full")
		var more := UITheme.button(more_txt, _toggle_reasons, 14)
		more.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		left.add_child(more)
	if reals.size() > 0:
		left.add_child(UITheme.title("REAL-WORLD FIGURES, %d" % SimDB.year_of(ui.sim.state.turn), 15, UIKit.GOLD))
		for rs in reals:
			var rl := UITheme.label(rs, 14, Color(0.68, 0.72, 0.82))
			rl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			left.add_child(rl)
	# --- right: key stats over time
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 4)
	cols.add_child(right)
	var th := HBoxContainer.new()
	var tt := UITheme.title("OVER TIME", 16, UIKit.GOLD)
	tt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	th.add_child(tt)
	var legend := UITheme.rich("[right][color=#f7dc8f]━ you[/color]   [color=#9aa3b8]┅ history[/color][/right]", 14, true)
	legend.autowrap_mode = TextServer.AUTOWRAP_OFF
	legend.custom_minimum_size = Vector2(200, 0)
	th.add_child(legend)
	right.add_child(th)
	var hist: Array = sim.get_history()
	for c in CHARTS:
		right.add_child(_chart(hist, c[0], c[1], c[2]))
	# --- path ledger (inside the same scroll area)
	_inner.add_child(UITheme.sep())
	var ledger: Array = s.get("ledger", []) if s.get("ledger") is Array else (sim.get_path_ledger() if sim.has_method("get_path_ledger") else [])
	var cab_l := ledger.filter(func(e): return str(e.get("kind", "")) != "diplomacy")
	var dip_l := ledger.filter(func(e): return str(e.get("kind", "")) == "diplomacy")
	var n_hist := cab_l.filter(func(e): return UITheme.ledger_matched(e)).size()
	var path_line := "[font_size=16][color=#e6c76e]YOUR PATH[/color][/font_size]   %d cabinet decisions: %d as history, %d your own way." % [cab_l.size(), n_hist, cab_l.size() - n_hist]
	if dip_l.size() > 0:
		var d_hist := dip_l.filter(func(e): return UITheme.ledger_matched(e)).size()
		path_line += "  %d envoy answers: %d as history, %d your own way." % [dip_l.size(), d_hist, dip_l.size() - d_hist]
	_inner.add_child(UITheme.rich(path_line, 15))
	if ledger.is_empty():
		_inner.add_child(UITheme.label("No cabinet decisions with lasting terms were taken.", 15, UIKit.TEXT_DIM))
	# v3 final (fix4-ui): the ledger is grouped by decade, each group folded to one line until opened (the whole list
	# made the screen about 17,600 px long)
	var groups := {}
	var order: Array = []
	for e in ledger:
		var tn := int(e.get("turn", 0))
		var y := SimDB.year_of(tn) if tn > 0 else 1948
		var d0 := 1948 + floori(float(y - 1948) / LEDGER_YEARS) * LEDGER_YEARS
		if not groups.has(d0):
			groups[d0] = []
			order.append(d0)
		(groups[d0] as Array).append(e)
	if order.size() > 1:
		var tools := HBoxContainer.new()
		tools.add_theme_constant_override("separation", 8)
		tools.add_child(UITheme.button("Open every decade", func(): set_all_open(true), 14))
		tools.add_child(UITheme.button("Fold every decade", func(): set_all_open(false), 14))
		_inner.add_child(tools)
	var y_last := SimDB.year_of(mini(int(sim.state.turn), maxi(1, V3Adapter.last_turn(sim))))
	for d0 in order:
		var ge: Array = groups[d0]
		var g_own := ge.filter(func(x): return not UITheme.ledger_matched(x)).size()
		var key := "ledger:%d" % d0
		var opened := is_open(key)
		var head_txt := "%s %d–%d   %d decisions: %d as history, %d your own way" % [_fold_mark(opened), d0, mini(d0 + LEDGER_YEARS - 1, maxi(d0, y_last)), ge.size(), ge.size() - g_own, g_own]
		var hb := UITheme.button(head_txt, func(): _toggle(key), 15)
		hb.flat = true
		hb.alignment = HORIZONTAL_ALIGNMENT_LEFT
		hb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hb.add_theme_color_override("font_color", UIKit.GOLD_LIGHT if g_own > 0 else UIKit.TEXT)
		hb.set_meta("ledger_group", d0)
		_inner.add_child(hb)
		if opened:
			_ledger_rows(sim, ge)
	# --- buttons (pinned below the scroll area)
	body.add_child(UITheme.sep())
	_buttons = HBoxContainer.new()
	_buttons.add_theme_constant_override("separation", 10)
	_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	body.add_child(_buttons)
	_buttons.add_child(UITheme.button("Return to start", func(): ui.loading.run(func(): ui.return_to_start()), 18))
	_buttons.add_child(UITheme.button("Keep viewing the map", func(): close(), 18))
	_buttons.add_child(UITheme.button("Ghost of history: details", func(): close(); ui.open_panel("ghost"), 18))
	visible = true
	if keep_scroll > 0:
		_restore_scroll.call_deferred(keep_scroll)


const LEDGER_YEARS := 10
var _open := {}   # folded sections that are open: "ledger:<first year>", or "*" for all


func is_open(key: String) -> bool:
	return _open.has("*") or _open.has(key)


func set_all_open(on: bool) -> void:
	## Opens (or folds) every decade of the path ledger.
	_open.clear()
	if on:
		_open["*"] = true
	_build()


func _toggle(key: String) -> void:
	if _open.has("*"):
		_open.erase("*")
	elif _open.has(key):
		_open.erase(key)
	else:
		_open[key] = true
	_build()


static func _fold_mark(opened: bool) -> String:
	if opened:
		return "▾"
	return "◂" if L10n.rtl else "▸"


func _ledger_rows(sim, ledger: Array) -> void:
	for e in ledger:
		var own: bool = not UITheme.ledger_matched(e)
		var chosen := str(e.get("chosen_label", e.get("chosen", "")))
		var hist_lab := str(e.get("historical_label", ""))
		if hist_lab == "" or chosen == str(e.get("chosen", "")):
			var f: Dictionary = sim.get_fork(str(e.get("id", ""))) if sim.has_method("get_fork") else {}
			for o in f.get("options", []):
				if str(o.get("id", "")) == chosen:
					chosen = str(o.get("label", chosen))
				if hist_lab == "" and (str(o.get("id", "")) == str(e.get("historical", "")) or (typeof(o.get("historical")) == TYPE_BOOL and o["historical"])):
					hist_lab = str(o.get("label", ""))
		if chosen == str(e.get("chosen", "")) and chosen.to_lower() == chosen:
			chosen = UITheme.pretty(chosen)   # an option id no longer in the data (an older save): "decline" -> "Decline"
		var line := "[color=#8a93a8]%s[/color]  [b]%s[/b]: %s" % [SimDB.date_label(int(e.get("turn", 0))) if int(e.get("turn", 0)) > 0 else "", str(e.get("title", "")), UITheme.humanise(chosen)]
		if own:
			line += "  [color=#ffbf66](your own path%s)[/color]" % ((": history chose " + UITheme.humanise(hist_lab)) if hist_lab != "" else "")
		else:
			line += "  [color=#a8b0c4](as history)[/color]"
		var terms: Array = e.get("terms", [])
		for t in terms.filter(func(x): return not UITheme.is_zero_term(str(x))).slice(0, 2):
			line += "\n      [color=#f3d98f]•[/color] " + UITheme.clean_terms(str(t))
		_inner.add_child(UITheme.rich(line, 15))


static func end_label(sim) -> String:
	## The date the game ended: the last playable quarter (Q3 2023), never a later turn an old save or the data reaches.
	var t := int(sim.state.turn)
	var last := V3Adapter.last_turn(sim)
	if bool(sim.state.game_over) and last > 0 and t > last:
		t = last
	return SimDB.date_label(t)


func _epilogue(e: Dictionary) -> void:
	## The ending reached (sim-endgame): its summary, the epilogue built from the player's record, and the thresholds of
	## every ending at the end (what was met, what was missed).
	var box := PanelContainer.new()
	box.add_theme_stylebox_override("panel", UITheme.sb(Color(0.05, 0.09, 0.19, 0.96), UIKit.GOLD, 1, 6, 14))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	box.add_child(v)
	v.add_child(UITheme.title(("WHAT HAPPENED: %s" if bool(e.get("collapse", false)) else "EPILOGUE: %s") % str(e.get("name", "")).to_upper(), 18, UIKit.GOLD_LIGHT))
	if str(e.get("summary", "")) != "":
		v.add_child(UITheme.rich("[i]%s[/i]" % UITheme.humanise(str(e["summary"])), 17))
	for p in V3Adapter.epilogue_paragraphs(e):
		if p is Dictionary:
			var t := str(p.get("title", ""))
			var tx := UITheme.humanise(str(p.get("text", "")))
			if tx.strip_edges() == "":
				continue
			if str(p.get("kind", "")) == "gap_note":
				v.add_child(UITheme.rich("[color=#a8b0c4][b]%s.[/b] %s[/color]" % [t, tx], 15))
			elif t != "":
				v.add_child(UITheme.rich("[color=#e6c76e][b]%s.[/b][/color] %s" % [t, tx], 16))
			else:
				v.add_child(UITheme.rich(tx, 16))
		else:
			v.add_child(UITheme.rich(UITheme.humanise(str(p)), 16))
	# every ending's thresholds at the end
	var outl: Array = V3Adapter.outlook(ui.sim)
	var g := GridContainer.new()
	g.columns = 3
	g.add_theme_constant_override("h_separation", 14)
	g.add_theme_constant_override("v_separation", 2)
	var any := false
	for o in outl:
		if bool(o.get("mixed", false)) or bool(o.get("collapse", false)) or bool(e.get("collapse", false)):
			continue   # a collapse ends the game before the end states are measured
		any = true
		var ths: Array = o.get("thresholds", [])
		var met_n := ths.filter(func(t): return bool(t.get("met", false))).size()
		var nm := UITheme.label(str(o.get("name", "")), 16, UIKit.GOLD_LIGHT if bool(o.get("met", false)) else UIKit.TEXT, "body_bold")
		nm.custom_minimum_size = Vector2(240, 0)
		g.add_child(nm)
		g.add_child(UITheme.label("%d of %d thresholds" % [met_n, ths.size()], 16, UIKit.GREEN if bool(o.get("met", false)) else UIKit.TEXT_DIM))
		var miss := ths.filter(func(t): return not bool(t.get("met", false))).map(func(t): return "%s (%s)" % [UITheme.humanise(str(t.get("label", ""))), V3Adapter.threshold_text(t)])
		var ml := UITheme.label(("missed: " + "; ".join(miss)) if miss.size() > 0 else "reached", 16, UIKit.TEXT_DIM)
		ml.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ml.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		ml.custom_minimum_size = Vector2(560, 0)
		g.add_child(ml)
	if any:
		v.add_child(UITheme.title("THE ENDINGS AT THE END", 15, UIKit.GOLD))
		v.add_child(g)
	_inner.add_child(box)


func _toggle_reasons() -> void:
	_all_reasons = not _all_reasons
	_build()


func _restore_scroll(v: int) -> void:
	if _scroll != null and is_instance_valid(_scroll):
		_scroll.scroll_vertical = v


func _reason_line(r: Dictionary, track_names: Dictionary, full: bool) -> Control:
	## One "What made the difference" item: a one-line summary (the full text on hover), or the full text.
	var kind := str(r.get("kind", ""))
	var mark := "•"
	var col := "#e6c76e"
	if r.has("good"):
		mark = "+" if bool(r["good"]) else "−"
		col = "#9fe07a" if bool(r["good"]) else "#ff8f7a"
	elif kind != "choice" and int(r.get("turns", 0)) != 0:
		mark = "+" if int(r.get("turns", 0)) > 0 else "−"
		col = "#9fe07a" if int(r.get("turns", 0)) > 0 else "#ff8f7a"
	var tr := str(track_names.get(str(r.get("track", "")), ""))
	var txt := UITheme.humanise(str(r.get("text", "")))
	var one := UITheme.humanise(str(r.get("headline", ""))) if str(r.get("headline", "")) != "" else _one_line(txt)
	if full:
		return UITheme.rich("[color=%s]%s[/color] %s%s" % [col, mark, ("[color=#a8b0c4]%s:[/color] " % tr) if tr != "" else "", txt], 15)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 6)
	h.add_child(UITheme.label(mark, 15, Color.html(UITheme.pal(col)), "body_bold"))
	if tr != "":
		h.add_child(UITheme.label(tr + ":", 15, Color(0.66, 0.69, 0.77)))
	var l := UITheme.label(one, 15)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.text_overrun_behavior = TextServer.OVERRUN_TRIM_WORD_ELLIPSIS   # on a word boundary (her minor 5: "0,000" cut mid-number)
	l.clip_text = true
	l.custom_minimum_size = Vector2(60, 0)
	l.tooltip_text = txt
	l.mouse_filter = Control.MOUSE_FILTER_PASS
	h.add_child(l)
	return h


static func _one_line(t: String) -> String:
	## 'Your cabinet chose "A" at "B" (history: "C"): terms' -> 'B: A (first term)'; other reasons stay as they are.
	var re := RegEx.new()
	re.compile("^Your cabinet chose \"([^\"]+)\" at \"([^\"]+)\"")
	var m := re.search(t)
	if m != null:
		var rest := t.substr(m.get_end())
		var colon := rest.find("): ")
		var first := ""
		if colon >= 0:
			first = rest.substr(colon + 3).split(";")[0].strip_edges()
		return "%s: %s%s" % [m.get_string(2), m.get_string(1), (" (" + first + ")") if first != "" else ""]
	return t


func _chart(hist: Array, key: String, title: String, col: Color) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(540, 112)
	var pv := PackedFloat32Array(); var gv := PackedFloat32Array(); var ts := PackedInt32Array()
	var mx := 0.0
	for h in hist:
		var v := float((h.get("v", {}) as Dictionary).get(key, 0.0))
		var gd: Dictionary = h.get("g", {})
		var gval := float(gd.get(key, -1.0)) if not gd.is_empty() else -1.0
		pv.append(v); gv.append(gval); ts.append(int(h.get("t", 0)))
		mx = maxf(mx, maxf(v, gval))
	c.draw.connect(func():
		var r := Rect2(Vector2(0, 0), c.size)
		c.draw_rect(r, Color(0.02, 0.04, 0.09, 0.85))
		c.draw_rect(r, Color(UIKit.GOLD_DARK, 0.8), false, 1.0)
		var f := UIKit.font("body")
		c.draw_string(f, Vector2(8, 19), L10n.t(title), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, UIKit.TEXT)
		if pv.size() < 2 or mx <= 0.0:
			c.draw_string(f, Vector2(8, 60), L10n.t("No history recorded."), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, UIKit.TEXT_DIM)
			return
		var plot := Rect2(36, 28, r.size.x - 46, r.size.y - 50)
		var t0 := float(ts[0]); var t1 := float(maxi(ts[ts.size() - 1], ts[0] + 1))
		var y_end := SimDB.year_of(int(t1))
		for yr in [1948, 1967, 1987, 2006, y_end]:
			if yr > y_end or (yr != y_end and y_end - yr < 6):
				continue
			var tt := float((yr - 1948) * 4)
			var x := plot.position.x + plot.size.x * clampf((tt - t0) / (t1 - t0), 0, 1)
			c.draw_line(Vector2(x, plot.position.y), Vector2(x, plot.end.y), Color(1, 1, 1, 0.07), 1.0)
			c.draw_string(f, Vector2(x - 17, plot.end.y + 17), str(yr), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, UIKit.TEXT_DIM)
		var gp := PackedVector2Array(); var pp := PackedVector2Array()
		for i in pv.size():
			var x := plot.position.x + plot.size.x * (float(ts[i]) - t0) / (t1 - t0)
			pp.append(Vector2(x, plot.end.y - plot.size.y * pv[i] / (mx * 1.05)))
			if gv[i] >= 0.0:
				gp.append(Vector2(x, plot.end.y - plot.size.y * gv[i] / (mx * 1.05)))
		if gp.size() >= 2:
			for i in range(0, gp.size() - 1, 2):
				c.draw_line(gp[i], gp[i + 1], Color(0.62, 0.66, 0.75, 0.9), 1.6, true)
		c.draw_polyline(pp, col, 2.2, true)
		var last := pv[pv.size() - 1]
		var lab := L10n.t(GhostPanel._fmt(key, last))
		c.draw_string(f, Vector2(r.size.x - 8 - UIKit.text_width(lab, "body", 16), 19), lab, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, col))
	return c
