class_name FiscalPanel
extends UIWindow
## The Treasury's running costs and the fiscal levers (V3 fix round, fix3-econ's sim.get_fiscal_report()): what the
## state spends against what it takes in, the structural-deficit alarm (it names upkeep), and the three ways out:
## mothball or close buildings (here as a plan, and per building in the City screen's Upkeep tab), privatise state
## companies (one-off gold and lasting terms, each sale history's or a named advocate's), and an emergency stabilisation
## package (cuts and a wage freeze, at a cost in trust and output). Opened from the top bar's Treasury and debt items,
## the game menu, the State Budget and the structural-deficit notice.

var _scroll: ScrollContainer
var _confirm := ""   # a lever that asked "click again to confirm"


func _init() -> void:
	super._init("Treasury: running costs and fiscal levers")


func open() -> void:
	_confirm = ""
	refresh()
	visible = true


func _process(d: float) -> void:
	if visible and _scroll != null and is_instance_valid(_scroll):
		var vp := view_size()
		var chrome := get_combined_minimum_size().y - _scroll.custom_minimum_size.y
		var h := clampf(vp.y - (TOP_BAR * hud_k() + 10.0) / maxf(ui_scale, 0.01) - chrome, 160.0, 560.0)   # (the top bar at the HUD's scale)
		if absf(_scroll.custom_minimum_size.y - h) > 0.5:
			_scroll.custom_minimum_size.y = h
	super._process(d)


static func available(sim) -> bool:
	return sim != null and sim.has_method("get_fiscal_report")


func refresh() -> void:
	if ui == null or ui.sim == null:
		return
	var keep := _scroll.scroll_vertical if _scroll != null and is_instance_valid(_scroll) else 0
	clear_body()
	var sim = ui.sim
	if not available(sim):
		body.add_child(UITheme.label("No fiscal report in this version of the game.", 16, UIKit.TEXT_DIM))
		body.add_child(UITheme.button("Close", close, 17))
		return
	var fr: Dictionary = sim.get_fiscal_report()
	var n: Dictionary = sim.get_national_summary()
	var rev := float(fr.get("revenue", 0))
	var up := float(fr.get("upkeep", 0))
	var ds := float(fr.get("debt_service", 0))
	var ratio := float(fr.get("ratio", 0))
	var alarm := bool(fr.get("alarm", false))
	var blines: Array = fr.get("lines", []) if fr.get("lines") is Array else []
	if not blines.is_empty():
		_head_lines(fr, n, blines, ratio, alarm)
	else:
		_head_old(fr, n, rev, up, ds, ratio, alarm)
	# --- the scrolling levers
	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.custom_minimum_size = Vector2(0, 420)
	body.add_child(_scroll)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 8)
	_scroll.add_child(v)
	if not blines.is_empty():
		_budget_section(v, blines)
	_mothball_section(v, fr)
	_policy_section(v, fr)
	_privatise_section(v, fr)
	_stabilise_section(v, fr)
	body.add_child(UITheme.button("Close", close, 17))
	if keep > 0:
		_restore.call_deferred(keep)


func _head_lines(fr: Dictionary, n: Dictionary, blines: Array, ratio: float, alarm: bool) -> void:
	## v3 final (fix4-econ N1): every outflow is counted; the headline is revenue against all outflows.
	var rev := float(fr.get("revenue", 0))
	var outf := float(fr.get("outflow", 0))
	var head := "[color=#a8b0c4]Treasury[/color] [b]%s[/b] Gold (%s a quarter).   [color=#a8b0c4]Revenue[/color] [b]%s[/b]   [color=#a8b0c4]outflows[/color] [b]%s[/b]" % [
		UITheme.fmt_num(float(n.get("gold_treasury", 0))), UITheme.fmt_signed(float(fr.get("net", n.get("gold_net", 0)))), UITheme.fmt_num(rev), UITheme.fmt_num(outf)]
	body.add_child(UITheme.rich(head, 16))
	var col := "#ff8f7a" if alarm else ("#ffc75c" if ratio > 0.9 else "#9fe07a")
	var st := "[color=%s][b]Outflows take %d%% of revenue.[/b][/color]" % [col, int(round(ratio * 100.0))]
	if alarm:
		st += "  [color=#ff8f7a]Structural deficit for %d quarters: the state spends more than it takes in, quarter after quarter.[/color]" % int(fr.get("quarters_over", 0))
	body.add_child(UITheme.rich(st, 16))
	# the three largest outflows, so the cause is on screen without scrolling
	var outs := blines.filter(func(l): return str(l.get("kind", "")) == "outflow" and float(l.get("amount", 0)) <= -0.5)
	outs.sort_custom(func(a, b): return float(a["amount"]) < float(b["amount"]))
	if not outs.is_empty():
		var tops := []
		for l in outs.slice(0, 3):
			tops.append("%s %s" % [str(l.get("label", "")), UITheme.fmt_num(-float(l["amount"]))])
		body.add_child(UITheme.rich("[color=#c8ccd6]Largest outflows: %s.[/color]" % "; ".join(tops), 15))


func _head_old(fr: Dictionary, n: Dictionary, rev: float, up: float, ds: float, ratio: float, alarm: bool) -> void:
	# --- the headline: running costs against revenue (a sim without the budget lines)
	var head := "[color=#a8b0c4]Treasury[/color] [b]%s[/b] Gold (%s a quarter).   [color=#a8b0c4]Revenue[/color] [b]%s[/b]   [color=#a8b0c4]running costs[/color] [b]%s[/b]   [color=#a8b0c4]debt service[/color] [b]%s[/b]" % [
		UITheme.fmt_num(float(n.get("gold_treasury", 0))), UITheme.fmt_signed(float(n.get("gold_net", 0))), UITheme.fmt_num(rev), UITheme.fmt_num(up), UITheme.fmt_num(ds)]
	body.add_child(UITheme.rich(head, 16))
	var parts: Dictionary = fr.get("parts", {})
	var pl := []
	for k in [["buildings", "buildings"], ["public", "public services"], ["districts", "districts"], ["units", "units"], ["mothballed", "mothballed buildings (20%)"]]:
		if float(parts.get(k[0], 0)) > 0.5:
			pl.append("%s %s" % [k[1], UITheme.fmt_num(float(parts[k[0]]))])
	if not pl.is_empty():
		body.add_child(UITheme.rich("[color=#a8b0c4]Running costs: %s.[/color]" % ", ".join(pl), 15))
	var col := "#ff8f7a" if alarm else ("#ffc75c" if ratio > 0.9 else "#9fe07a")
	var st := "[color=%s][b]Running costs and debt service take %d%% of revenue.[/b][/color]" % [col, int(round(ratio * 100.0))]
	if alarm:
		st += "  [color=#ff8f7a]Structural deficit for %d quarters: the state spends more than it takes in, quarter after quarter.[/color]" % int(fr.get("quarters_over", 0))
	body.add_child(UITheme.rich(st, 16))
	if str(fr.get("text", "")) != "":
		body.add_child(UITheme.rich("[color=#c8ccd6]%s[/color]" % UITheme.humanise(str(fr["text"])), 15))


func _budget_section(v: VBoxContainer, blines: Array) -> void:
	## Every line of the quarter's budget (fix4-econ): revenue lines, then outflows; a line's items on hover and, for
	## the largest few, on a second line. The lines (without the investment) add up to the quarter's net.
	var bv := _section(v, "THE QUARTER'S BUDGET", "Every gold piece the state takes in and pays out this quarter. National programmes are an investment paid only from a surplus.")
	var g := GridContainer.new()
	g.columns = 3
	g.add_theme_constant_override("h_separation", 14)
	g.add_theme_constant_override("v_separation", 3)
	bv.add_child(g)
	for l in blines:
		var amt := float(l.get("amount", 0))
		var kind := str(l.get("kind", ""))
		if absf(amt) < 0.5 and not (str(l.get("id", "")) in ["income", "running"]):
			continue
		var nm := UITheme.label(str(l.get("label", "")), 15, UIKit.TEXT if kind != "investment" else UIKit.TEXT_DIM, "body_bold" if kind == "revenue" else "body")
		nm.custom_minimum_size = Vector2(300, 0)
		nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		g.add_child(nm)
		var al := UITheme.label(UITheme.fmt_signed(snappedf(amt, 0.1)), 15, UIKit.GREEN if amt > 0.0 else (UIKit.TEXT_DIM if kind == "investment" else Color(1.0, 0.56, 0.48)), "body_bold")
		al.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		al.custom_minimum_size = Vector2(70, 0)
		L10n.keep_ltr(al)
		g.add_child(al)
		var its: Array = l.get("items", []) if l.get("items") is Array else []
		var sub := its.slice(0, 3).map(func(x): return "%s %s" % [str(x.get("label", "")), UITheme.fmt_num(absf(float(x.get("amount", 0))))])
		var il := UITheme.label(", ".join(sub) + (" ..." if its.size() > 3 else ""), 14, Color(0.66, 0.69, 0.77))
		il.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		il.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		il.custom_minimum_size = Vector2(260, 0)
		g.add_child(il)
		if its.size() > 0:
			var tip := "\n".join(its.map(func(x): return "%s  %s" % [str(x.get("label", "")), UITheme.fmt_signed(snappedf(float(x.get("amount", 0)), 0.1))]))
			nm.tooltip_text = tip
			il.tooltip_text = tip
			nm.mouse_filter = Control.MOUSE_FILTER_PASS
			il.mouse_filter = Control.MOUSE_FILTER_PASS


func _policy_section(v: VBoxContainer, fr: Dictionary) -> void:
	## fix4-econ's lever: scale back (half cost, half benefits) or suspend a policy card that costs gold, as history's own
	## benefit cuts did (1985, 2002-03); restore it later at no trust cost.
	var cards: Array = fr.get("policy_cards", []) if fr.get("policy_cards") is Array else []
	if cards.is_empty() and ui.sim.has_method("get_policy_costs"):
		cards = ui.sim.get_policy_costs()
	if cards.is_empty() and not ui.sim.has_method("get_policy_costs"):
		return
	var bv := _section(v, "COSTLY POLICY CARDS", "A slotted policy card that costs gold can run at half strength (half its cost and half its benefits) or be suspended (no cost and no benefits; it keeps its slot). Either costs Civic Trust, as Israel's own benefit cuts did. A card can be restored in full later.")
	if cards.is_empty():
		bv.add_child(UITheme.label("No slotted policy card costs gold now.", 15, UIKit.TEXT_DIM))
		return
	for c in cards:
		var pid := str(c.get("id", ""))
		var state := str(c.get("state", "full"))
		var r := UIRow.new(true)
		var h := r.hrow()
		var nm := UITheme.label(str(c.get("name", pid)), 17, UIKit.GOLD_LIGHT, "body_bold")
		nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(nm)
		var stt: String = {"full": "in full", "half": "at half strength", "suspended": "suspended"}.get(state, state)
		h.add_child(UITheme.label("%s: %s Gold a quarter" % [stt, UITheme.fmt_num(float(c.get("cost", 0)))], 15, UIKit.TEXT if state == "full" else Color(1.0, 0.75, 0.4)))
		var desc_done := false
		for o in c.get("options", []):
			var mode := str(o.get("mode", ""))
			if not desc_done and str(o.get("desc", "")) != "":
				r.add(UITheme.rich("[color=#c8ccd6]%s[/color]" % UITheme.humanise(str(o["desc"])), 14))
				desc_done = true
			r.add(UITheme.rich("[b]%s[/b]  %s" % [str(o.get("label", mode)), _fx(o.get("effects_text", []))], 14))
			var who := []
			if bool(o.get("historical", false)) and str(o.get("hist_label", "")) != "": who.append("History: " + str(o["hist_label"]))
			if str(o.get("advocate", "")) != "": who.append("Advocated by " + str(o["advocate"]))
			if not (o.get("source", []) as Array).is_empty(): who.append("Sources: " + ", ".join(o["source"]))
			if not who.is_empty():
				r.add(UITheme.rich("\n".join(who.map(func(x): return "[color=#a8b0c4]%s[/color]" % x)), 13))
			if bool(o.get("available", true)):
				var key := "pol:%s:%s" % [pid, mode]
				var bl: String = {"half": "Scale back", "suspend": "Suspend", "restore": "Restore in full"}.get(mode, mode)
				r.add(UITheme.button(("Click again: " + bl.to_lower()) if _confirm == key else bl, func(): _lever(key, func(): return ui.policy_cut(pid, mode)), 15))
			elif str(o.get("reason", "")) != "":
				r.add(UITheme.rich("[color=#ff8f7a]%s[/color]" % UITheme.humanise(str(o["reason"])).capitalize(), 14))
		bv.add_child(r)


func _restore(k: int) -> void:
	if _scroll != null and is_instance_valid(_scroll):
		_scroll.scroll_vertical = k


func _section(v: VBoxContainer, title: String, text: String) -> VBoxContainer:
	var box := PanelContainer.new()
	box.add_theme_stylebox_override("panel", UITheme.sb(Color(0.05, 0.08, 0.16, 0.95), UIKit.GOLD_DARK, 1, 6, 12))
	var bv := VBoxContainer.new()
	bv.add_theme_constant_override("separation", 5)
	box.add_child(bv)
	bv.add_child(UITheme.title(title, 17, UIKit.GOLD_LIGHT))
	if text != "":
		bv.add_child(UITheme.rich("[color=#a8b0c4]%s[/color]" % text, 15))
	v.add_child(box)
	return bv


func _mothball_section(v: VBoxContainer, fr: Dictionary) -> void:
	var bv := _section(v, "MOTHBALL OR CLOSE BUILDINGS", "A mothballed building stops working and keeps a fifth of its upkeep; it can be reopened later for six quarters of its upkeep. A closed one costs nothing, for good. Stopping a building that serves residents (amenities, housing, trust) costs that city some Civic Trust. Each city's buildings are in its City screen, tab Upkeep.")
	var tops: Array = fr.get("top_cities", [])
	if not tops.is_empty():
		var fl := HFlowContainer.new()
		fl.add_theme_constant_override("h_separation", 6)
		fl.add_theme_constant_override("v_separation", 4)
		fl.add_child(UITheme.label("Most upkeep:", 15, UIKit.TEXT_DIM))
		for t in tops:
			var cid := int(t.get("id", -1))
			var b := UITheme.button("%s  %s" % [str(t.get("name", "")), UITheme.fmt_num(float(t.get("upkeep", 0)))], func(): close(); ui.city_s.tab = "upkeep"; ui.open_city(cid, true), 14)
			b.tooltip_text = "Open the city's Upkeep tab"
			fl.add_child(b)
		bv.add_child(fl)
	var plan: Array = fr.get("mothball_plan", [])
	if plan.is_empty():
		bv.add_child(UITheme.label("No building is worth stopping now: each one does more than its upkeep.", 15, UIKit.TEXT_DIM))
	else:
		var saves := 0.0
		for x in plan: saves += float(x.get("saves", 0))
		var lines := []
		for x in plan.slice(0, 8):
			lines.append("• %s in %s: saves %s" % [str(x.get("name", "")), str(x.get("city_name", "")), str(snappedf(float(x.get("saves", 0)), 0.1))])
		if plan.size() > 8:
			lines.append("... and %d more" % (plan.size() - 8))
		bv.add_child(UITheme.rich("[b]The least-used buildings first[/b] (least use per gold of upkeep):\n" + "\n".join(lines), 15))
		var key := "plan"
		var lab := ("Click again to mothball %d buildings" % plan.size()) if _confirm == key else ("Mothball these %d buildings: about %d Gold a quarter saved" % [plan.size(), int(round(saves))])
		var pb := UITheme.button(lab, func(): _lever(key, func(): return ui.mothball_plan(plan)), 16)
		bv.add_child(pb)
	var mb: Array = fr.get("mothballed", [])
	if not mb.is_empty():
		bv.add_child(UITheme.label("Mothballed now: %d buildings" % mb.size(), 15, UIKit.GOLD))
		for x in mb.slice(0, 12):
			var h := HBoxContainer.new()
			h.add_theme_constant_override("separation", 8)
			var nl := UITheme.label("%s in %s" % [str(x.get("name", "")), str(x.get("city_name", ""))], 15)
			nl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			h.add_child(nl)
			var cid2 := int(x.get("city", -1)); var bid := str(x.get("building", ""))
			h.add_child(UITheme.button("Reopen (%d Gold)" % int(x.get("reopen_cost", 0)), func(): ui.fiscal_building("reopen", cid2, bid), 14))
			bv.add_child(h)


func _privatise_section(v: VBoxContainer, fr: Dictionary) -> void:
	var bv := _section(v, "PRIVATISE STATE COMPANIES", "A sale brings gold now and lowers upkeep for years; some change output, and workers and unions oppose them (Civic Trust). Each sale is history's, on its date, or proposed at the time by a named advocate.")
	var any := false
	for o in fr.get("privatisations", []):
		if bool(o.get("done", false)):
			bv.add_child(UITheme.rich("[color=#8a93a8]%s: sold.[/color]" % str(o.get("name", "")), 15))
			continue
		any = true
		var ok := bool(o.get("available", false))
		var r := UIRow.new(ok)
		var h := r.hrow()
		var nm := UITheme.label(str(o.get("name", "")), 17, UIKit.GOLD_LIGHT if ok else UIKit.TEXT_DIM, "body_bold")
		nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		h.add_child(nm)
		if bool(o.get("historical", false)) and UITheme.show_hints:
			h.add_child(UITheme.label("historical now", 14, Color(0.75, 0.72, 0.62)))
		if str(o.get("desc", "")) != "":
			r.add(UITheme.rich("[color=#c8ccd6]%s[/color]" % str(o["desc"]), 14))
		r.add(UITheme.rich(_fx(o.get("effects_text", [])), 14))
		var who := []
		if str(o.get("hist_label", "")) != "": who.append("History: " + str(o["hist_label"]))
		if str(o.get("advocate", "")) != "": who.append("Advocated by " + str(o["advocate"]))
		if not (o.get("source", []) as Array).is_empty(): who.append("Sources: " + ", ".join(o["source"]))
		if not who.is_empty():   # a colour tag per line: each line is translated on its own
			r.add(UITheme.rich("\n".join(who.map(func(x): return "[color=#a8b0c4]%s[/color]" % x)), 13))
		if not ok and str(o.get("reason", "")) != "":
			r.add(UITheme.rich("[color=#ff8f7a]%s[/color]" % UITheme.humanise(str(o["reason"])).capitalize(), 14))
		var pid := str(o.get("id", ""))
		if ok:
			var key := "priv:" + pid
			r.add(UITheme.button("Click again to sell" if _confirm == key else "Privatise", func(): _lever(key, func(): return ui.privatise(pid)), 15))
		bv.add_child(r)
	if not any:
		bv.add_child(UITheme.label("Nothing left to sell.", 15, UIKit.TEXT_DIM))


func _stabilise_section(v: VBoxContainer, fr: Dictionary) -> void:
	var o: Dictionary = fr.get("stabilisation", {})
	if o.is_empty():
		return
	var bv := _section(v, "EMERGENCY STABILISATION PACKAGE", "For a crisis only: deep cuts, a wage and price freeze and an anchor for inflation, as Israel did in 1949, 1966 and 1985. It works, at a price in Civic Trust, amenities and a year of lower output.")
	var ok := bool(o.get("available", false))
	bv.add_child(UITheme.label(str(o.get("name", "")), 17, UIKit.GOLD_LIGHT if ok else UIKit.TEXT, "body_bold"))
	if str(o.get("desc", "")) != "":
		bv.add_child(UITheme.rich("[color=#c8ccd6]%s[/color]" % str(o["desc"]), 14))
	bv.add_child(UITheme.rich(_fx(o.get("effects_text", [])), 14))
	var who := []
	if int(o.get("hist_year", 0)) > 0: who.append("History: adopted in %d" % int(o["hist_year"]))
	if str(o.get("advocate", "")) != "": who.append("Advocated by " + str(o["advocate"]))
	if not (o.get("source", []) as Array).is_empty(): who.append("Sources: " + ", ".join(o["source"]))
	if not who.is_empty():
		bv.add_child(UITheme.rich("\n".join(who.map(func(x): return "[color=#a8b0c4]%s[/color]" % x)), 13))
	if ok:
		var key := "stab"
		bv.add_child(UITheme.button("Click again to adopt the package" if _confirm == key else "Adopt the package", func(): _lever(key, func(): return ui.stabilise()), 16))
	elif str(o.get("reason", "")) != "":
		bv.add_child(UITheme.rich("[color=#a8b0c4]Not now: %s.[/color]" % UITheme.humanise(str(o["reason"])), 14))


static func _fx(lines: Array) -> String:
	## Effect lines coloured by what they do for the player (gold in and upkeep down help; trust, output and amenities lost hurt).
	var out := []
	for l in lines:
		var t := str(l)
		var good := t.begins_with("+") and not t.contains("Upkeep +") or t.begins_with("Upkeep -") or t.begins_with("Upkeep −") or t.begins_with("Inflation brought down")
		var bad := t.begins_with("-") or t.begins_with("−") or t.contains("Civic Trust") and not t.begins_with("+")
		if t.begins_with("Upkeep -") or t.begins_with("Upkeep −"):
			bad = false
		out.append("[color=%s]%s[/color]" % ["#9fe07a" if good and not bad else ("#ff8f7a" if bad else "#dfe3ec"), t])
	return ", ".join(out)


func _lever(key: String, f: Callable) -> void:
	## Every lever asks once more before it acts (each has lasting effects).
	if _confirm != key:
		_confirm = key
		refresh()
		return
	_confirm = ""
	f.call()
	refresh()
