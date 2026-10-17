class_name GhostPanel
extends UIWindow
## "Ghost of history": your six tracks against the recorded Historical Israel run, with itemised reasons;
## the multi-year terms your choices set (sim.get_streams); and why lasting stats moved (sim.get_stat_log).

var tab := "tracks"   # tracks | endings | path | terms | stats
var stat_filter := ""


func _init() -> void:
	super._init("Ghost of History")


func open_tab(t: String) -> void:
	tab = t
	refresh()


func refresh() -> void:
	clear_body()
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 6)
	body.add_child(tabs)
	var streams: Array = ui.sim.get_streams()
	var ledger: Array = ui.sim.get_path_ledger() if ui.sim.has_method("get_path_ledger") else []
	for td in [["tracks", "Vs. history"], ["endings", "Ending outlook"], ["path", "Your path (%d)" % ledger.size()], ["terms", "Ongoing terms (%d)" % streams.filter(func(x): return x.get("active", false)).size()], ["stats", "Why stats moved"]]:
		var b := UITheme.button(td[1], open_tab.bind(td[0]), 16)
		if tab == td[0]:
			b.add_theme_stylebox_override("normal", UITheme.sb(Color(0.16, 0.30, 0.55), UIKit.GOLD_LIGHT, 2, 5, 10))
		tabs.add_child(b)
	match tab:
		"endings": _endings()
		"terms": _terms(streams)
		"stats": _stats()
		"path": _path(ledger)
		_: _tracks()


# ------------------------------------------------------------------ ending outlook (v3)

func _endings() -> void:
	## Progress toward each ending's thresholds (sim-endgame get_endings): after Q3 2023 the game ends in the ending whose
	## thresholds are all met (the largest margin if several), else a mixed record.
	var sim = ui.sim
	var out: Array = V3Adapter.outlook(sim)
	var left: int = maxi(0, V3Adapter.last_turn(sim) - int(sim.state.turn))
	body.add_child(UITheme.rich("[b]How will your Israel end?[/b]  After " + V3Adapter.end_label(sim) + " the game ends in the end state whose thresholds are all met (the one with the widest margin if several are); otherwise with a mixed record. [color=#a8b0c4]%d quarters to go. Thresholds are measured now; ratios compare your Israel with history's ghost on the same date.[/color]" % left, 16))
	var sc := ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.custom_minimum_size = Vector2(0, 560)
	body.add_child(sc)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 8)
	sc.add_child(list)
	var risks := out.filter(func(x): return bool(x.get("collapse", false)))
	out = out.filter(func(x): return not bool(x.get("collapse", false)))
	if risks.any(func(x): return str(x.get("level", "")) == "danger"):
		_collapse_cards(list, risks)   # a collapse in sight comes first
		risks = []
	for e in out:
		var card := PanelContainer.new()
		var lead: bool = bool(e.get("likely", false)) or bool(e.get("primary", false))
		card.add_theme_stylebox_override("panel", UITheme.sb(Color(0.07, 0.13, 0.26, 0.96) if lead else Color(0.05, 0.08, 0.16, 0.95), UIKit.GOLD_LIGHT if lead else UIKit.GOLD_DARK, 2 if lead else 1, 6, 10))
		var v := VBoxContainer.new()
		v.add_theme_constant_override("separation", 3)
		card.add_child(v)
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 10)
		v.add_child(h)
		var nm := UITheme.label(str(e.get("name", "")), 20, UIKit.GOLD_LIGHT, "body_bold")
		nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(nm)
		var ths: Array = e.get("thresholds", [])
		var met_n := ths.filter(func(t): return bool(t.get("met", false))).size()
		var tag := ""
		var tcol := UIKit.TEXT_DIM
		if bool(e.get("mixed", false)):
			tag = "if no end state is reached" if not bool(e.get("met", false)) else "where you stand now"
		elif bool(e.get("met", false)):
			tag = "every threshold met"
			tcol = UIKit.GREEN
		else:
			tag = "%d of %d thresholds met" % [met_n, ths.size()]
			if lead:
				tag += "  (closest)"
				tcol = UIKit.GOLD_LIGHT
		h.add_child(UITheme.label(tag, 16, tcol, "body_bold"))
		if not bool(e.get("mixed", false)):
			h.add_child(_progress_bar(clampf(float(e.get("progress", 0)), 0, 1), bool(e.get("met", false))))
		if str(e.get("desc", "")) != "":
			v.add_child(UITheme.rich("[color=#c8ccd6]%s[/color]" % UITheme.humanise(str(e["desc"])), 16))
		for t in ths:
			var ok := bool(t.get("met", false))
			var th := HBoxContainer.new()
			th.add_theme_constant_override("separation", 8)
			var mark := UITheme.label("✓" if ok else "•", 17, UIKit.GREEN if ok else UIKit.BAD, "body_bold")
			mark.custom_minimum_size = Vector2(18, 0)
			th.add_child(mark)
			var tl := UITheme.label(UITheme.humanise(str(t.get("label", ""))), 16)
			tl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			tl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			th.add_child(tl)
			var val := UITheme.label(V3Adapter.threshold_text(t), 16, UIKit.GREEN if ok else UIKit.TEXT, "body_bold")
			val.custom_minimum_size = Vector2(300, 0)
			val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			th.add_child(val)
			v.add_child(th)
			var alt: Dictionary = t.get("or", {})
			if not alt.is_empty():   # v3 fix3-econ: "or" an alternative threshold that meets the same criterion
				var ah := HBoxContainer.new()
				ah.add_theme_constant_override("separation", 8)
				var am := UITheme.label("", 15)
				am.custom_minimum_size = Vector2(18, 0)
				ah.add_child(am)
				var aok := bool(alt.get("met", false))
				var al := UITheme.label("or " + UITheme.humanise(str(alt.get("label", ""))), 15, UIKit.GREEN if aok else UIKit.TEXT_DIM)
				al.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				al.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				ah.add_child(al)
				var av := UITheme.label(V3Adapter.threshold_text(alt), 15, UIKit.GREEN if aok else UIKit.TEXT_DIM, "body_bold")
				av.custom_minimum_size = Vector2(300, 0)
				av.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
				ah.add_child(av)
				v.add_child(ah)
		list.add_child(card)
	if not risks.is_empty():
		_collapse_cards(list, risks)
	var gn := V3Adapter.gap_note()
	if not gn.is_empty():
		list.add_child(UITheme.rich("[color=#a8b0c4][b]%s.[/b] %s[/color]" % [str(gn.get("title", "")), str(gn.get("text", ""))], 15))


func _collapse_cards(list: VBoxContainer, risks: Array) -> void:
	## v3 item 13 (fix-v3a): the early endings for a collapse of the state, with how close each is and how to recover.
	list.add_child(UITheme.title("RISKS TO THE STATE: EARLY ENDINGS", 17, UIKit.GOLD))
	list.add_child(UITheme.rich("[color=#a8b0c4]The game ends early if one of these holds quarter after quarter. Each quarter its conditions all hold, the danger grows by one; when they do not, it eases. The top bar warns you first.[/color]", 15))
	for e in risks:
		var lvl := str(e.get("level", "ok"))
		var danger := lvl == "danger"
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", UITheme.sb(Color(0.22, 0.05, 0.05, 0.96) if danger else Color(0.05, 0.08, 0.16, 0.95), UIKit.BAD if danger else UIKit.GOLD_DARK, 2 if danger else 1, 6, 10))
		var v := VBoxContainer.new()
		v.add_theme_constant_override("separation", 3)
		card.add_child(v)
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 10)
		v.add_child(h)
		var nm := UITheme.label(str(e.get("name", "")), 19, UIKit.BAD if danger else UIKit.GOLD_LIGHT, "body_bold")
		nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(nm)
		var tag := "no danger"
		var tcol := UIKit.GREEN
		if danger:
			tag = "DANGER: %d of %d quarters, %d left" % [int(e.get("strain", 0)), int(e.get("limit", 1)), int(e.get("quarters_left", 0))]
			tcol = UIKit.BAD
		elif lvl == "warning":   # fix3-econ's tiers: every condition holds (or the strain is building)
			tag = "warning: %d of %d quarters" % [int(e.get("strain", 0)), int(e.get("limit", 1))]
			tcol = UIKit.BAD
		elif lvl == "watch":
			tag = "watch: %d of %d quarters" % [int(e.get("strain", 0)), int(e.get("limit", 1))]
			tcol = UIKit.WARN
		h.add_child(UITheme.label(tag, 16, tcol, "body_bold"))
		h.add_child(_progress_bar(clampf(float(e.get("progress", 0)), 0, 1), false))
		v.add_child(UITheme.rich("[color=#c8ccd6]%s[/color]" % UITheme.humanise(str(e.get("desc", ""))), 15))
		for t in e.get("thresholds", []):
			var ok := not bool(t.get("met", false))   # here "met" is bad: the danger condition holds
			var th := HBoxContainer.new()
			th.add_theme_constant_override("separation", 8)
			var mark := UITheme.label("✓" if ok else "!", 17, UIKit.GREEN if ok else UIKit.BAD, "body_bold")
			mark.custom_minimum_size = Vector2(18, 0)
			th.add_child(mark)
			var tl := UITheme.label(UITheme.humanise(str(t.get("label", ""))), 15)
			tl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			tl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			th.add_child(tl)
			var val := UITheme.label(V3Adapter.threshold_text_collapse(t), 15, UIKit.TEXT if ok else UIKit.BAD, "body_bold")
			val.custom_minimum_size = Vector2(300, 0)
			val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			th.add_child(val)
			v.add_child(th)
		if danger or lvl == "watch":
			v.add_child(UITheme.rich("[color=#f3d98f]%s[/color]" % UITheme.humanise(str(e.get("advice", ""))), 15))
		list.add_child(card)


# ------------------------------------------------------------------ tracks

func _tracks() -> void:
	var s: Dictionary = ui.sim.get_score()
	var has_ghost: bool = s.get("has_ghost", false)
	var head := "[b]%s[/b]   " % str(s.get("date", ""))
	if has_ghost:
		var summ := str(s.get("summary", ""))
		if summ == "":
			summ = "Ahead in %d, level in %d, behind in %d" % [int(s.get("ahead", 0)), int(s.get("even", 0)), int(s.get("behind", 0))]
		head += "%s  [color=#a8b0c4](within 1%% counts as level)[/color].  Overall %d%% of history's level." % [summ, int(float(s.get("overall", 100)))]
		if ui.sim.state.turn < GameUI.GHOST_FROM_TURN:
			head += "\n[color=#ffb070]Early days: until about Q2 1950 both runs are still almost the same country.[/color]"
	else:
		head += "[color=#ffb070]The recorded historical run (game/data/ghost.json) is not available, so only your own values are shown.[/color]"
	body.add_child(UITheme.rich(head, 17))
	body.add_child(UITheme.rich("[color=#a8b0c4]The ghost is a scripted playthrough that follows the real dates (techs, civics, foundings, national projects and the choices actually made), measured in the game's own units.[/color]", 14))
	var g := GridContainer.new()
	g.columns = 5
	g.add_theme_constant_override("h_separation", 14)
	g.add_theme_constant_override("v_separation", 5)
	body.add_child(g)
	for k in ["Track", "You", "History", "", ""]:
		g.add_child(UITheme.label(k, 15, UIKit.GOLD, "title"))
	for t in s.get("tracks", []):
		var nm := UITheme.label(str(t["name"]), 16, UIKit.TEXT, "body_bold")
		nm.custom_minimum_size = Vector2(240, 0)
		nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		g.add_child(nm)
		g.add_child(UITheme.label(_fmt(str(t["id"]), float(t["player"])), 16))
		var valid := has_ghost and float(t["ghost"]) > 0
		g.add_child(UITheme.label(_fmt(str(t["id"]), float(t["ghost"])) if valid else "-", 16, UIKit.TEXT_DIM))
		g.add_child(_ratio_bar(float(t.get("ratio", 1.0)), valid, str(t.get("status", ""))))
		var st := str(t.get("status", "ahead" if t.get("ahead", false) else "behind"))
		g.add_child(UITheme.label({"ahead": "ahead", "even": "level", "behind": "behind"}.get(st, st) if valid else "", 15,
			UIKit.GREEN if st == "ahead" else (UIKit.TEXT_DIM if st == "even" else UIKit.BAD), "body_bold"))
		var lab: Dictionary = t.get("label", {})
		if not lab.is_empty() and float(lab.get("history", 0)) > 0:
			g.add_child(Control.new())
			var src: Array = lab.get("source", [])
			var txt := UITheme.label("Real figure: %s %s; you: %s  [%s]" % [_short(float(lab["history"])), str(lab.get("unit", "")), _short(float(lab.get("player", 0))), ", ".join(src)], 13, Color(0.6, 0.65, 0.75))
			g.add_child(txt)
			for i in 3:
				g.add_child(Control.new())
	body.add_child(UITheme.sep())
	body.add_child(UITheme.title("WHY", 16, UIKit.GOLD))
	var reasons: Array = s.get("reasons", [])
	if reasons.is_empty():
		body.add_child(UITheme.label("No milestones differ from history yet." if has_ghost else "Reasons appear once the ghost is available.", 16, UIKit.TEXT_DIM))
	var list := scroll_body(150)
	for r in reasons:
		var good := int(r.get("turns", 0)) > 0
		list.add_child(UITheme.rich("[color=%s]%s[/color]  %s  [color=#8a93a8](%s)[/color]" % ["#9fe07a" if good else "#ff8f7a", "+" if good else "−", UITheme.humanise(str(r.get("text", ""))), UITheme.pretty(str(r.get("track", "")))], 15))


# ------------------------------------------------------------------ your path ("Your Israel vs history")

func _path(ledger: Array) -> void:
	body.add_child(UITheme.rich("Every cabinet decision and event choice you have made, whether it matched history, and the lasting terms it set.", 16))
	var list := scroll_body(380)
	if ledger.is_empty():
		list.add_child(UITheme.label("No decisions with lasting terms yet.", 16, UIKit.TEXT_DIM))
		return
	for i in range(ledger.size() - 1, -1, -1):
		var e: Dictionary = ledger[i]
		var r := UIRow.new(true)
		var h := r.hrow()
		var nm := UITheme.label(str(e.get("title", "")), 17, UIKit.GOLD_LIGHT, "body_bold")
		nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		h.add_child(nm)
		var hist: bool = UITheme.ledger_matched(e)
		h.add_child(UITheme.label("as history" if hist else "your own path", 14, UIKit.TEXT_DIM if hist else Color(1.0, 0.75, 0.4), "body_bold"))
		var when := SimDB.date_label(int(e.get("turn", 0))) if int(e.get("turn", 0)) > 0 else ""
		var chosen := str(e.get("chosen_label", e.get("chosen", "")))
		if not hist and str(e.get("historical_label", "")) != "":
			chosen += "  [color=#a8b0c4](history: %s)[/color]" % UITheme.humanise(str(e["historical_label"]))
		var f: Dictionary = ui.sim.get_fork(str(e.get("id", ""))) if ui.sim.has_method("get_fork") else {}
		for o in f.get("options", []):
			if str(o.get("id", "")) == chosen:
				chosen = str(o.get("label", chosen))
		r.add(UITheme.rich("[color=#8a93a8]%s[/color]  %s" % [when, UITheme.humanise(chosen)], 15))
		var terms: Array = e.get("terms", [])
		if terms.size() > 0:
			var tt := ""
			for t in terms:
				tt += ("\n" if tt != "" else "") + "  [color=#f3d98f]•[/color] " + UITheme.clean_terms(str(t))
			r.add(UITheme.rich(tt, 14))
		list.add_child(r)


# ------------------------------------------------------------------ ongoing terms (streams)

func _terms(streams: Array) -> void:
	body.add_child(UITheme.rich("Multi-year terms set by your choices in dated events: income or costs per turn, standing, trust, or a readiness level, between two dates. [color=#a8b0c4]A refusal can remove a stream history had; an agreement can add one.[/color]", 16))
	var list := scroll_body(260)
	if streams.is_empty():
		list.add_child(UITheme.label("No multi-year terms are running or scheduled.", 16, UIKit.TEXT_DIM))
		return
	streams.sort_custom(func(a, b): return int(a.get("from", 0)) < int(b.get("from", 0)))
	for st in streams:
		var amt := float(st.get("amount", 0))
		var typ := str(st.get("type", ""))
		var unit: String = {"gold": " Gold per turn", "standing": " Standing per turn", "trust": " trust per turn", "readiness": " Readiness (level)"}.get(typ, " " + typ)
		var active: bool = st.get("active", false)
		var when := "%s to %s" % [SimDB.date_label(int(st.get("from", 0))), SimDB.date_label(int(st.get("until", 0)))]
		var r := UIRow.new(true)
		var h := r.hrow()
		var nm := UITheme.label(str(st.get("label", typ)), 17, UIKit.GOLD_LIGHT if active else UIKit.TEXT_DIM, "body_bold")
		nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		h.add_child(nm)
		h.add_child(UITheme.label(("%s%s" % [UITheme.fmt_signed(amt, 1), unit]), 16, UIKit.GREEN if UITheme.stat_good(typ, amt) else UIKit.BAD, "body_bold"))
		var src := str(st.get("src", ""))
		var ev = SimDB.get_db().event_by_id.get(src)
		r.add(UITheme.label("%s   %s%s" % [when, "running" if active else "scheduled", ("   from: " + str(ev.get("title", src))) if ev != null else ""], 14, UIKit.TEXT_DIM))
		if ev != null:
			r.pressed.connect(func(_s): ui.open_event(src))
		list.add_child(r)


# ------------------------------------------------------------------ stat history (stat log)

func set_filter(f: String) -> void:
	stat_filter = f
	refresh()


const STAT_TABS := [["standing", "Standing"], ["trust", "Civic Trust"], ["readiness", "Readiness"], ["inflation", "Inflation"], ["gold", "Gold"]]
const HIST_KEY := {"standing": "standing", "trust": "cohesion", "readiness": "readiness", "gold": "gold"}
const BAD_UP := ["inflation", "weariness", "war_weariness"]


func _stats() -> void:
	var log: Array = ui.sim.get_stat_log("")
	var counts := {}
	for e in log:
		var k := str(e.get("stat", ""))
		counts[k] = int(counts.get(k, 0)) + 1
	var tabs := [["", "All"]]
	var known := {}
	for t in STAT_TABS:
		tabs.append(t)
		known[t[0]] = true
	for k in counts:
		if not known.has(k):
			tabs.append([k, UITheme.pretty(k)])
	var fh := HFlowContainer.new()
	fh.add_theme_constant_override("h_separation", 4)
	fh.add_theme_constant_override("v_separation", 4)
	body.add_child(fh)
	fh.add_child(UITheme.label("Show:", 15, UIKit.TEXT_DIM))
	for t in tabs:
		var k: String = t[0]
		var n := log.size() if k == "" else int(counts.get(k, 0))
		var b := UITheme.button("%s (%d)" % [t[1], n], set_filter.bind(k), 14)
		if stat_filter == k:
			b.add_theme_stylebox_override("normal", UITheme.sb(Color(0.16, 0.30, 0.55), UIKit.GOLD_LIGHT, 2, 5, 8))
		fh.add_child(b)
	var nat: Dictionary = ui.sim.get_national_summary()
	body.add_child(UITheme.rich("Now: [b]Standing %d[/b]   [b]Civic Trust %d[/b]   [b]Readiness %d[/b]   [b]Inflation %d%%[/b]   [b]Treasury %s[/b]. Every lasting change with its reason, newest first; each Q4 adds the year's drift by cause." % [int(nat.get("standing", 0)), int(nat.get("avg_trust", 0)), int(nat.get("readiness", 0)), int(nat.get("inflation", 0)), UITheme.fmt_num(float(nat.get("gold_treasury", 0)))], 15))
	var list := scroll_body(400)
	var shown := 0
	for i in range(log.size() - 1, -1, -1):
		var e: Dictionary = log[i]
		var st := str(e.get("stat", ""))
		if stat_filter != "" and st != stat_filter:
			continue
		var amt := float(e.get("amount", 0))
		var good := UITheme.stat_good(str(st), amt)
		list.add_child(UITheme.rich("[color=#8a93a8]%s[/color]  [color=%s][b]%s %s[/b][/color]  %s" % [SimDB.date_label(int(e.get("turn", 0))), "#9fe07a" if good else "#ff8f7a", UITheme.fmt_signed(amt, 1), UITheme.pretty(st), UITheme.humanise(str(e.get("reason", "")))], 15))
		shown += 1
		if shown >= 200:
			break
	if shown == 0 and HIST_KEY.has(stat_filter):
		_net_changes(list, stat_filter)
	elif shown == 0:
		list.add_child(UITheme.label("No lasting changes recorded yet.", 16, UIKit.TEXT_DIM))


func _net_changes(list: VBoxContainer, stat: String) -> void:
	## The sim has not itemised this stat yet: show its net change each quarter from the history record.
	var key: String = HIST_KEY[stat]
	var h: Array = ui.sim.get_history()
	list.add_child(UITheme.rich("[color=#a8b0c4]No itemised causes are recorded for %s yet. Its net change each quarter:[/color]" % UITheme.pretty(stat).to_lower(), 15))
	var n := 0
	for i in range(h.size() - 1, 0, -1):
		var a := float((h[i].get("v", {}) as Dictionary).get(key, 0.0))
		var b := float((h[i - 1].get("v", {}) as Dictionary).get(key, 0.0))
		var d := a - b
		if absf(d) < 0.05:
			continue
		var good := UITheme.stat_good(stat, d)
		list.add_child(UITheme.rich("[color=#8a93a8]%s[/color]  [color=%s][b]%s %s[/b][/color]  [color=#a8b0c4](now %s)[/color]" % [SimDB.date_label(int(h[i].get("t", 0))), "#9fe07a" if good else "#ff8f7a", UITheme.fmt_signed(d, 1), UITheme.pretty(stat), UITheme.fmt_num(a)], 15))
		n += 1
		if n >= 60:
			break
	if n == 0:
		list.add_child(UITheme.label("No change yet.", 16, UIKit.TEXT_DIM))


func _progress_bar(p: float, met: bool) -> Control:
	## Average progress toward an ending's thresholds (each capped at 100%).
	var c := Control.new()
	c.custom_minimum_size = Vector2(190, 22)
	c.tooltip_text = "Average progress toward the thresholds: %d%%" % int(round(p * 100))
	c.mouse_filter = Control.MOUSE_FILTER_PASS
	c.draw.connect(func():
		var w := 140.0
		c.draw_rect(Rect2(0, 6, w, 10), Color(0, 0.02, 0.06, 0.9))
		c.draw_rect(Rect2(0, 6, w * p, 10), UIKit.GREEN if met else UIKit.GOLD)
		c.draw_rect(Rect2(0, 6, w, 10), Color(UIKit.GOLD_DARK, 0.8), false, 1.0)
		c.draw_string(UIKit.font("body"), Vector2(w + 6, 18), "%d%%" % int(round(p * 100)), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, UIKit.TEXT))
	return c


func _ratio_bar(ratio: float, valid: bool, status: String) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(190, 22)
	c.draw.connect(func():
		var w := 140.0
		c.draw_rect(Rect2(0, 6, w, 10), Color(0, 0.02, 0.06, 0.9))
		if valid:
			var f := clampf(ratio / 2.0, 0.0, 1.0)
			var col := UIKit.GREEN if status == "ahead" else (Color(0.62, 0.66, 0.75) if status == "even" else UIKit.BAD)
			if status == "":
				col = UIKit.GREEN if ratio >= 1.0 else UIKit.BAD
			c.draw_rect(Rect2(0, 6, w * f, 10), col)
			c.draw_line(Vector2(w * 0.5, 2), Vector2(w * 0.5, 20), UIKit.GOLD_LIGHT, 1.5)
			c.draw_string(UIKit.font("body"), Vector2(w + 6, 18), SimScore.ratio_text(ratio), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, UIKit.TEXT))
	return c


static func _fmt(id: String, v: float) -> String:
	match id:
		"population":
			return "%.2fM" % (v / 1e6)
		"science":
			return "%.1f techs" % v
	return "%.1f" % v


static func _short(v: float) -> String:
	if absf(v) >= 1e6:
		return "%.2fM" % (v / 1e6)
	if absf(v) >= 1000:
		return UITheme.fmt_num(v)
	if absf(v) >= 100:
		return str(int(round(v)))
	if absf(v) >= 10:
		return "%.1f" % v
	return "%.2f" % v
