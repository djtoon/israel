class_name ProgrammesPanel
extends UIWindow
## National programmes (sim-endgame, V3 item 2): the late-game projects of a state (start-ups, space and cyber, the
## missile shield, desalination, the gas fields, peace dividends...). Each level is paid from the treasury in
## quarterly instalments and leaves lasting terms and a gain on the six tracks. The open "programme" decision
## (a new programme on the agenda, or "invest the surplus") is answered at the top.

const GROUP_LABEL := {"security": "Security", "prosperity": "Prosperity", "peace": "Peace", "society": "Society"}
const STATUS_COL := {"done": "#9fe07a", "active": "#f7dc8f", "available": "#dfe3ec", "locked": "#8a93a8"}

var data := {}      # the open programme decision, if any
var _scroll: ScrollContainer


func _init() -> void:
	super._init("National Programmes")


func _process(d: float) -> void:
	## The list scrolls in what is left of the screen below the top bar (V3 fixes B2: the window never covers it).
	if visible and _scroll != null and is_instance_valid(_scroll):
		var vp := view_size()
		var chrome := get_combined_minimum_size().y - _scroll.custom_minimum_size.y
		var want := 470.0 if not data.is_empty() else 600.0
		var h := clampf(vp.y - (TOP_BAR * hud_k() + 10.0) / maxf(ui_scale, 0.01) - chrome, 160.0, want)   # (the top bar at the HUD's scale)
		if absf(_scroll.custom_minimum_size.y - h) > 0.5:
			_scroll.custom_minimum_size.y = h
	super._process(d)


func open(d := {}) -> void:
	data = d
	if data.is_empty() and ui and ui.sim:
		for x in ui.sim.get_pending_decisions():
			if str(x.get("type", "")) == "programme":
				data = x
	refresh()
	visible = true


func after_choice() -> void:
	data = {}
	refresh()


func refresh() -> void:
	if ui == null or ui.sim == null:
		return
	var keep := _scroll.scroll_vertical if _scroll != null and is_instance_valid(_scroll) else 0
	clear_body()
	var sim = ui.sim
	var n: Dictionary = sim.get_national_summary()
	body.add_child(UITheme.rich("[color=#a8b0c4]Treasury[/color] [b]%s[/b] Gold (%s a quarter)    [color=#a8b0c4]A programme is paid in quarterly instalments; once complete it leaves lasting terms and a gain on the six tracks that grows over four years. History's ghost takes the historical levels on their real dates; launching early, the levels history never built and the expansions are where you get ahead.[/color]" % [
		UITheme.fmt_num(float(n.get("gold_treasury", 0))), UITheme.fmt_signed(float(n.get("gold_net", 0)))], 16))
	if not data.is_empty() and bool(data.get("blocking", true)):
		_decision()
	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.custom_minimum_size = Vector2(0, 470 if not data.is_empty() else 600)
	body.add_child(_scroll)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 8)
	_scroll.add_child(v)
	var progs: Array = sim.get_programmes() if sim.has_method("get_programmes") else []
	if progs.is_empty():
		v.add_child(UITheme.label("No national programme is open at this date.", 17, UIKit.TEXT_DIM))
	for p in progs:
		v.add_child(_card(p))
	body.add_child(UITheme.button("Close", close, 17))
	if keep > 0:
		_restore.call_deferred(keep)


func _restore(k: int) -> void:
	if _scroll != null and is_instance_valid(_scroll):
		_scroll.scroll_vertical = k


func _decision() -> void:
	var box := PanelContainer.new()
	box.add_theme_stylebox_override("panel", UITheme.sb(Color(0.12, 0.10, 0.04, 0.96), UIKit.GOLD_LIGHT, 2, 6, 12))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 5)
	box.add_child(v)
	v.add_child(UITheme.label(UITheme.humanise(str(data.get("label", "National programme"))), 19, UIKit.GOLD_LIGHT, "body_bold"))
	if str(data.get("text", "")) != "":
		v.add_child(UITheme.rich(UITheme.humanise(str(data["text"])), 16))
	var i := 0
	for o in data.get("options", []):
		var ok := bool(o.get("available", true))
		var r := UIRow.new(ok)
		var h := r.hrow()
		var l := UITheme.label(UITheme.humanise(str(o.get("label", ""))), 18, UIKit.GOLD_LIGHT if ok else UIKit.TEXT_DIM, "body_bold")
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		h.add_child(l)
		if bool(o.get("default", false)) and UITheme.show_hints:
			h.add_child(UITheme.label("Recommended", 16, UIKit.GREEN, "body_bold"))
		if str(o.get("desc", "")) != "":
			r.add(UITheme.rich("[color=#c8ccd6]%s[/color]" % UITheme.humanise(str(o["desc"])), 16))
		var fx: Array = o.get("effects", []) if o.get("effects") is Array else []
		var fl := CabinetPanel.fx_lines(fx)
		if fl != "":
			r.add(UITheme.rich(fl, 16))
		if not ok:
			r.add(UITheme.label("Not affordable this quarter", 16, UIKit.BAD))
		var idx := i
		r.pressed.connect(func(_s): ui.choose_programme_option(idx))
		v.add_child(r)
		i += 1
	body.add_child(box)


func _card(p: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", UITheme.sb(Color(0.05, 0.09, 0.18, 0.95), UIKit.GOLD_DARK, 1, 6, 10))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 3)
	card.add_child(v)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	v.add_child(h)
	var nm := UITheme.label(str(p.get("name", "")), 19, UIKit.GOLD_LIGHT, "body_bold")
	nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(nm)
	var gs: Array = p.get("groups", [])
	if gs.size() > 0:
		h.add_child(UITheme.label(", ".join(gs.map(func(g): return GROUP_LABEL.get(str(g), UITheme.pretty(str(g))))), 16, Color(0.75, 0.72, 0.62)))
	var lvls: Array = p.get("levels", [])
	h.add_child(UITheme.label("%d of %d level%s" % [int(p.get("levels_done", 0)), lvls.size(), "" if lvls.size() == 1 else "s"], 16, UIKit.TEXT_DIM))
	if str(p.get("desc", "")) != "":
		v.add_child(UITheme.rich("[color=#c8ccd6]%s[/color]" % UITheme.humanise(str(p["desc"])), 16))
	var act: Dictionary = p.get("active", {})
	if not act.is_empty():
		v.add_child(UITheme.rich("[color=#f7dc8f]Under way:[/color] %s, %d quarter%s left (%s Gold a quarter)" % [
			("level %d" % int(act.get("level", 0))) if str(act.get("kind", "level")) == "level" else "expansion", int(act.get("quarters_left", 0)),
			"" if int(act.get("quarters_left", 0)) == 1 else "s", UITheme.fmt_num(float(act.get("instalment", 0)))], 16))
	var pid := str(p.get("id", ""))
	var next_done := false
	for l in lvls:
		var st := str(l.get("status", "locked"))
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		var hist := str(l.get("hist_label", ""))
		var ttxt := "[color=%s][b]%d. %s[/b][/color]  [color=#8a93a8]%s[/color]" % [STATUS_COL.get(st, "#dfe3ec"), int(l.get("level", 0)), UITheme.humanise(str(l.get("name", ""))),
			{"done": "done" + ((" " + SimDB.date_label(int(l.get("done_turn", 0)))) if int(l.get("done_turn", 0)) > 0 else ""), "active": "under way", "available": "%s Gold over %d quarters" % [UITheme.fmt_num(float(l.get("cost", 0))), int(l.get("turns", 4))],
				"locked": UITheme.humanise(str(l.get("reason", "")))}.get(st, st)]
		if hist != "" and UITheme.show_hints:
			ttxt += "  [color=#8a93a8](history: %s)[/color]" % hist
		elif not bool(l.get("historical", true)) and str(l.get("advocate", "")) != "":
			ttxt += "  [color=#8a93a8](not built in history; proposed by %s)[/color]" % str(l["advocate"])
		var tl := UITheme.rich(ttxt, 16)
		tl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(tl)
		if st == "available" and not next_done and act.is_empty():
			next_done = true
			row.add_child(UITheme.button("Launch", func(): ui.fund_programme(pid), 16))
		v.add_child(row)
		if st in ["available", "active"]:
			var eff: Array = l.get("effects", [])
			if eff.size() > 0:
				v.add_child(UITheme.rich("      " + UITheme.color_effects(", ".join(eff.map(func(x): return str(x)))), 16))
	var ex: Dictionary = p.get("expand", {})
	if not ex.is_empty() and int(p.get("levels_done", 0)) >= lvls.size():
		var er := HBoxContainer.new()
		var reason := str(ex.get("reason", ""))
		var et := UITheme.rich("[color=#dfe3ec][b]Expand: %s[/b][/color]  [color=#8a93a8]%d of %d done; %s Gold over %d quarters%s[/color]" % [UITheme.humanise(str(ex.get("name", ""))), int(ex.get("count", 0)), int(ex.get("max", 3)),
			UITheme.fmt_num(float(ex.get("cost", 0))), int(ex.get("turns", 4)), ("; " + UITheme.humanise(reason)) if reason != "" else ""], 16)
		et.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		er.add_child(et)
		var eb := UITheme.button("Expand", func(): ui.fund_programme(pid, true), 16)
		eb.disabled = reason != "" or not act.is_empty()
		er.add_child(eb)
		v.add_child(er)
	var ln: Dictionary = p.get("legacy_now", {})
	if not ln.is_empty():
		var parts := []
		for t in ln:
			if absf(float(ln[t])) >= 0.05:
				parts.append("[color=%s]%s%% %s[/color]" % [UITheme.GOOD_HEX if float(ln[t]) > 0 else UITheme.BAD_HEX, UITheme.fmt_signed(float(ln[t]), 1), UITheme.pretty(str(t))])
		if parts.size() > 0:
			v.add_child(UITheme.rich("[color=#a8b0c4]Gain on the tracks now:[/color] " + ", ".join(parts), 16))
	return card
