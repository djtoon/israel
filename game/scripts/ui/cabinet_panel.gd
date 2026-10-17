class_name CabinetPanel
extends UIWindow
## v2 recurring cabinet decisions (sim SimCabinet), Civ VI style:
##  - "budget":    the yearly State Budget: presets plus your own split of the four envelopes (sliders, live effects);
##  - "review":    the mid-year budget review;
##  - "minister":  the cabinet (Civ VI governors): spend a cabinet title to appoint or promote a minister, move seats;
##  - "coalition": coalition talks after an election: which partner joins, and its price;
##  - "view":      the cabinet and the budget in force, with no decision open (K).

var mode := ""
var data := {}
var shares := {}           # custom budget split being edited (envelope id -> share 0..1)
var _sliders := {}
var _share_labels := {}
var _preview: RichTextLabel
var _pass_btn: Button
var _sel: Array = []          # minister multi-pick: chosen option ids, in click order
var _sel_rows := {}           # option id -> UIRow
var _pick_label: Label
var _form_btn: Button
var story_readonly := false   # v4 fix round: the short read-only view is on screen (story mode, appointments on auto)

const ENV_ICON := {"defence": "diplomacy", "absorption": "housing", "development": "production", "education": "science"}


func _init() -> void:
	super._init("Cabinet")


static func fx_label(l: String) -> String:
	## "+12.0 Readiness" -> "+12 Readiness"; ASCII minus -> "−"; no double signs.
	var s := l.strip_edges()
	var re := RegEx.new()
	re.compile("(\\d)\\.0(?!\\d)")
	s = re.sub(s, "$1", true)
	s = s.replace("+-", "−").replace("--", "−").replace("+−", "−")
	# gold in whole numbers ("+12.37 Gold" -> "+12 Gold"; fix4-diplo: effect amounts keep 0.01 precision)
	var rg := RegEx.create_from_string("(\\d+)\\.\\d+(?= Gold)")
	var acc := ""
	var pos := 0
	for m in rg.search_all(s):
		acc += s.substr(pos, m.get_start() - pos) + str(int(roundf(float(m.get_string(0)))))
		pos = m.get_end()
	s = acc + s.substr(pos)
	if s.begins_with("-"):
		s = "−" + s.substr(1)
	return UITheme.humanise(s)


const STAT_NAMES := {"gold": "Gold", "readiness": "Readiness", "standing": "Standing", "cohesion": "Cohesion", "trust": "trust",
	"amenity": "Amenity", "housing": "housing", "water": "water reserve", "upkeep": "upkeep", "science": "Science", "culture": "Culture",
	"production": "Production", "food": "Food", "growth_pct": "Growth", "water_demand_pct": "water demand",
	"water_supply_pct": "water supply", "faith": "Faith", "tourism": "Tourism"}


static func struct_label(e: Dictionary) -> String:
	## A label for a structured effect that has none ({stat, amount, unit, when}, the Cabinet Agenda's options and the
	## fiscal levers): "−45 Gold", "+2 housing", "−60% immigrants to the city", "−3 trust in the city", "+10% Growth for
	## 4 turns". Without it the agenda cards showed only the commas between empty effects (her M4, in both languages).
	var stat := str(e.get("stat", ""))
	var a := float(e.get("amount", 0))
	var unit := str(e.get("unit", ""))
	var when := str(e.get("when", ""))
	var num := UITheme.fmt_signed(roundf(a) if stat == "gold" else snappedf(a, 0.1))
	var nm: String = STAT_NAMES.get(stat, STAT_NAMES.get(str(e.get("type", "")), UITheme.pretty(stat).replace(" Pct", "")))
	var out := ""
	match stat:
		"inflation":
			out = "inflation %s points (lasting)" % num if when == "lasting" else "inflation %s points" % num
		"trust":
			out = "%s trust %s" % [num, unit.trim_prefix("points ").trim_prefix("point ")] if unit.begins_with("point") else "%s trust" % num
		"amenity":
			out = ("%s amenity everywhere (%s)" % [num, when]) if unit == "in every city" else ("%s Amenity %s" % [num, unit]).strip_edges()
		"housing":
			out = "%s housing" % num
		"water":
			out = "%s water reserve" % num
		"population":
			out = "%s%% immigrants to the city" % num if unit.contains("arrivals") else "%s %s" % [num, unit]
		_:
			if unit.begins_with("%"):
				out = "%s%% %s" % [num, nm]
			elif unit == "points" or unit == "":
				out = "%s %s" % [num, nm]
			elif unit.begins_with("points, "):
				out = "%s %s, %s" % [num, nm, unit.substr(8)]
			else:
				out = "%s %s %s" % [num, nm, unit]
	if when != "" and not (when in ["now", "lasting"]) and not out.contains("(" + when + ")"):
		out += " for %s" % when if when.ends_with("turns") or when.ends_with("years") or when.ends_with("quarters") else " (%s)" % when
	return out


static func fx_lines(effects: Array) -> String:
	## Structured effect lines [{stat, amount, label}] coloured by whether they help the player.
	var parts := []
	for e in effects:
		if typeof(e) == TYPE_DICTIONARY:
			var a := float(e.get("amount", 0))
			var lab := fx_label(str(e.get("label", "")) if str(e.get("label", "")) != "" else struct_label(e))
			if absf(a) < 0.05 or UITheme.is_zero_term(lab):
				continue   # no "+0" terms
			parts.append("[color=%s]%s[/color]" % ["#9fe07a" if UITheme.fx_good(e) else "#ff8f7a", lab])
		else:
			var ce := UITheme.color_effects(fx_label(str(e)))
			if ce != "":
				parts.append(ce)
	return ", ".join(parts)


func show_decision(d: Dictionary) -> void:
	data = d
	match str(d.get("type", "")):
		"state_budget": mode = "budget"
		"budget_review": mode = "review"
		"minister": mode = "minister"
		"coalition": mode = "coalition"
		_: mode = "view"
	shares = {}
	_sel = []
	if mode == "minister" and d.has("picks"):
		for id in d.get("recommended", []):
			_sel.append(str(id))
	visible = true
	refresh()


func show_view() -> void:
	data = {}
	mode = "view"
	visible = true
	refresh()


var _portraits_seen := {}   # texture instance id -> cards that showed it this refresh


func refresh() -> void:
	_portraits_seen.clear()
	clear_body()
	_sliders.clear()
	_share_labels.clear()
	story_readonly = false
	pref_width = 1080.0
	match mode:
		"budget": _budget()
		"review": _review()
		"minister": _ministers(true)
		"coalition": _coalition()
		_:
			if ui != null and ui.is_story() and NextStep.is_auto(ui, "cabinet"):
				_story_cabinet()
			else:
				_ministers(false)


func _story_cabinet() -> void:
	## v4 fix round (new-player N2): story mode with the appointments on auto. A short read-only view (who runs what,
	## one line each) and one way to take the appointments over; the full screen is for manual or Full control.
	story_readonly = true
	pref_width = 720.0
	var sim: Sim = ui.sim
	var cab: Dictionary = sim.get_cabinet() if sim.has_method("get_cabinet") else {}
	title_label.text = "THE CABINET"
	var intro := UITheme.label("The Prime Minister's Office appoints your ministers and gives out the cabinet's titles. Here is who runs what.", 16, Color(0.78, 0.80, 0.84))
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.custom_minimum_size = Vector2(560, 0)
	body.add_child(intro)
	# v4final (vet N7): who leads the government and its latest coalition agreement (the sim has no personal names
	# for the ministers; a seat held by a coalition partner names that party on its line)
	var term: Dictionary = sim.events.current_term() if sim.events.has_method("current_term") else {}
	if str(term.get("pm", "")) != "":
		var pml := UITheme.label("Prime Minister %s, since %s" % [str(term["pm"]), DecisionPopup._date_text(str(term.get("start", "")))], 16, UIKit.GOLD_LIGHT, "body_bold")
		pml.name = "cab_pm"
		body.add_child(pml)
	var coals: Array = cab.get("coalitions", [])
	if not coals.is_empty() and str(coals[-1].get("label", "")) != "":
		var cl := UITheme.label("Coalition agreement: %s." % str(coals[-1]["label"]), 15, Color(0.78, 0.80, 0.84))
		cl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cl.custom_minimum_size = Vector2(560, 0)
		cl.name = "cab_coalition"
		body.add_child(cl)
	var g := VBoxContainer.new()
	g.add_theme_constant_override("separation", 3)
	body.add_child(g)
	for m in cab.get("ministers", []):
		var on := bool(m.get("appointed", false))
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 10)
		h.name = "cab_line"
		g.add_child(h)
		var tl := UITheme.label(str(m.get("title", m.get("name", ""))), 16, UIKit.GOLD_LIGHT if on else UIKit.TEXT_DIM, "body_bold")
		tl.custom_minimum_size = Vector2(330, 0)
		h.add_child(tl)
		var cn := str(m.get("city_name", ""))
		var st := ("In office, seated in %s." % cn if cn != "" else "In office.") if on else "Not appointed yet."
		var partner := str(m.get("partner", ""))
		if on and partner != "":
			var sv := VBoxContainer.new()
			sv.add_theme_constant_override("separation", 0)
			h.add_child(sv)
			sv.add_child(UITheme.label(st, 16, UIKit.TEXT))
			sv.add_child(UITheme.label("held by a coalition partner (%s)" % partner, 13, UIKit.TEXT_DIM))
			continue
		h.add_child(UITheme.label(st, 16, UIKit.TEXT if on else UIKit.TEXT_DIM))
	if (cab.get("ministers", []) as Array).is_empty():
		g.add_child(UITheme.label("No minister is appointed yet.", 16, UIKit.TEXT_DIM))
	var foot := HBoxContainer.new()
	foot.add_theme_constant_override("separation", 10)
	foot.alignment = BoxContainer.ALIGNMENT_END
	body.add_child(foot)
	var tb := UITheme.button("Take over appointments", func(): ui.set_domain_auto("cabinet", false); refresh(), 16)
	tb.name = "cab_take_over"
	tb.tooltip_text = "You choose the appointments and promotions yourself; the full Cabinet screen opens."
	foot.add_child(tb)
	foot.add_child(UITheme.button("Done", close, 16))


func _head(title: String, sub: String, text: String) -> void:
	title_label.text = title
	var holder: Container = body
	var pm := str(ui.sim.events.current_term().get("pm", "")) if ui.sim.events.has_method("current_term") else ""
	var pt := UIArt.pm_portrait(pm)   # v3: the prime minister's portrait (art-2d), when present
	if pt != null:
		var hb := HBoxContainer.new()
		hb.add_theme_constant_override("separation", 12)
		body.add_child(hb)
		hb.add_child(portrait_box(pt, 92, pm))
		var vb := VBoxContainer.new()
		vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vb.add_theme_constant_override("separation", 4)
		hb.add_child(vb)
		holder = vb
	if sub != "":
		var l := UITheme.label(sub, 20, UIKit.GOLD_LIGHT, "body_bold")
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		holder.add_child(l)
	if text != "":
		holder.add_child(UITheme.rich("[color=#c8ccd6]%s[/color]" % UITheme.humanise(text), 16))


static func portrait_box(t: Texture2D, sz: int, tip := "") -> Control:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UITheme.sb(Color(0.02, 0.04, 0.09), UIKit.GOLD, 1, 4, 2))
	var tr := TextureRect.new()
	tr.texture = t
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	tr.custom_minimum_size = Vector2(sz, sz)
	tr.clip_contents = true
	tr.mouse_filter = Control.MOUSE_FILTER_PASS if tip != "" else Control.MOUSE_FILTER_IGNORE
	tr.tooltip_text = tip
	p.add_child(tr)
	return p


static func finance_line(sim) -> String:
	## Public finances in one line: Treasury, net per quarter, public debt with its service and the borrowing limit,
	## inflation. Debt, its service and inflation are red when they weigh on you.
	var n: Dictionary = sim.get_national_summary()
	var net := float(n.get("gold_net", 0))
	var s := "[color=#a8b0c4]Treasury[/color] [b]%s[/b]   [color=#a8b0c4]Net[/color] [color=%s][b]%s[/b][/color] a quarter" % [
		UITheme.fmt_num(float(n.get("gold_treasury", 0))), "#9fe07a" if net >= 0 else "#ff8f7a", UITheme.fmt_signed(net)]
	var debt := float(n.get("debt", 0))
	if debt >= 1.0:
		s += "   [color=#a8b0c4]Public debt[/color] [color=#ff8f7a][b]%s[/b][/color]" % UITheme.fmt_num(debt)
		var svc := float(n.get("debt_service", 0))
		if svc >= 0.5:
			s += " [color=#ff8f7a](interest and repayment %s a quarter)[/color]" % UITheme.fmt_num(svc)
		if float(n.get("borrow_cap", 0)) > 0:
			s += " [color=#a8b0c4]of a %s limit[/color]" % UITheme.fmt_num(float(n["borrow_cap"]))
	var inf := float(n.get("inflation", 0))
	s += "   [color=#a8b0c4]Inflation[/color] [color=%s][b]%d%%[/b][/color] a year" % ["#ff8f7a" if inf >= 15.0 else "#dfe3ec", int(round(inf))]
	var rails: Array = n.get("deficit_streams", []) if typeof(n.get("deficit_streams")) == TYPE_ARRAY else []
	if rails.size() > 0:
		var rs := []
		for r in rails.slice(0, 3):
			rs.append("%s [color=#ff8f7a]%s Gold a quarter[/color] (%s)" % [str(r.get("label", "")), UITheme.fmt_signed(float(r.get("amount", 0))), str(r.get("ends", ""))])
		s += "\n[color=#a8b0c4]Standing deficits:[/color] " + "; ".join(rs)
	return s


func _finance_row(line: String) -> void:
	## The public-finances line, with the way to the fiscal levers (fix3-econ: mothball, privatise, stabilise).
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	var rt := UITheme.rich(line, 15)
	rt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(rt)
	if FiscalPanel.available(ui.sim):
		var b := UITheme.button("Running costs and levers", func(): ui.open_fiscal(), 14)
		b.tooltip_text = "What the state spends against what it takes in; mothball or close buildings, privatise, a stabilisation package."
		b.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		h.add_child(b)
	body.add_child(h)


func _sources(src) -> void:
	if typeof(src) == TYPE_ARRAY and (src as Array).size() > 0:
		body.add_child(UITheme.rich("[color=#8a93a8]Sources: %s[/color]" % ", ".join(src), 13))


func _rec_tag(h: HBoxContainer) -> void:
	if not UITheme.show_hints:
		return
	h.add_child(UITheme.label("Recommended", 14, UIKit.GREEN, "body_bold"))


# ------------------------------------------------------------------ state budget

func _budget() -> void:
	var d := data
	_head("THE STATE BUDGET", "Budget Law %s" % str(d.get("fiscal_year", "")), str(d.get("text", "")))
	_finance_row(finance_line(ui.sim))
	_sources(d.get("source", []))
	var list := scroll_body(250)
	var i := 0
	for o in d.get("options", []):
		var r := UIRow.new(true)
		var h := r.hrow()
		var nm := UITheme.label(str(o.get("label", "")), 18, UIKit.GOLD_LIGHT, "body_bold")
		nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(nm)
		if o.get("default", false):
			_rec_tag(h)
		r.add(UITheme.rich("[color=#c8ccd6]%s[/color]" % UITheme.humanise(str(o.get("desc", ""))), 14))
		var fx: Array = o.get("effects", o.get("effects_text", []))
		r.add(UITheme.rich(fx_lines(fx) if fx.size() > 0 else "[color=#a8b0c4]No gains, no losses[/color]", 14))
		var idx := i
		r.pressed.connect(func(_s): ui.choose_cabinet("state_budget", idx))
		list.add_child(r)
		i += 1
	# your own split
	body.add_child(UITheme.section("Or set your own split (10–55% each)"))
	var envs: Array = d.get("envelopes", [])
	if shares.is_empty():
		for e in envs:
			shares[str(e["id"])] = float(e.get("current_share", 0.25))
		_normalise("")
	var g := GridContainer.new()
	g.columns = 4
	g.add_theme_constant_override("h_separation", 10)
	body.add_child(g)
	for e in envs:
		var id := str(e["id"])
		g.add_child(UITheme.icon(ENV_ICON.get(id, "star"), 22))
		var nl := UITheme.label(str(e.get("name", id)), 16, UIKit.TEXT, "body_bold")
		nl.tooltip_text = str(e.get("desc", "")) + "\nAt 40%: " + ", ".join((e.get("effects_at_40", []) as Array).map(func(x): return fx_label(str(x))))
		nl.mouse_filter = Control.MOUSE_FILTER_PASS
		nl.custom_minimum_size = Vector2(300, 0)
		g.add_child(nl)
		var sl := HSlider.new()
		sl.min_value = float(d.get("share_min", 0.10)) * 100.0
		sl.max_value = float(d.get("share_max", 0.55)) * 100.0
		sl.step = 1
		sl.value = round(float(shares.get(id, 0.25)) * 100.0)
		sl.custom_minimum_size = Vector2(300, 24)
		sl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sl.value_changed.connect(func(v): set_share(id, v / 100.0))
		g.add_child(sl)
		var pl := UITheme.label("%d%%" % int(round(float(shares.get(id, 0.25)) * 100.0)), 17, UIKit.GOLD_LIGHT, "body_bold")
		pl.custom_minimum_size = Vector2(54, 0)
		g.add_child(pl)
		_sliders[id] = sl
		_share_labels[id] = pl
	_preview = UITheme.rich("", 15)
	body.add_child(_preview)
	_pass_btn = UITheme.button("Pass this budget", func(): ui.pass_custom_budget(shares), 17)
	body.add_child(_pass_btn)
	_update_preview()


func set_share(id: String, v: float) -> void:
	## Move one envelope; the others take up the difference in proportion (each kept within 10–55%).
	shares[id] = v
	_normalise(id)
	for k in _sliders:
		var s: HSlider = _sliders[k]
		s.set_value_no_signal(round(float(shares[k]) * 100.0))
		(_share_labels[k] as Label).text = "%d%%" % int(round(float(shares[k]) * 100.0))
	_update_preview()


func _normalise(fixed: String) -> void:
	var lo := float(data.get("share_min", 0.10))
	var hi := float(data.get("share_max", 0.55))
	var keys := shares.keys()
	for it in 8:
		var tot := 0.0
		for k in keys:
			tot += float(shares[k])
		var diff := 1.0 - tot
		if absf(diff) < 0.0005:
			break
		var free := keys.filter(func(k): return k != fixed and (float(shares[k]) < hi - 0.0001 if diff > 0 else float(shares[k]) > lo + 0.0001))
		if free.is_empty():
			if fixed != "":
				shares[fixed] = clampf(float(shares[fixed]) + diff, lo, hi)
			break
		var w := 0.0
		for k in free:
			w += float(shares[k])
		for k in free:
			shares[k] = clampf(float(shares[k]) + diff * (float(shares[k]) / maxf(0.001, w)), lo, hi)
	# whole percents that add up to 100
	var tot2 := 0
	for k in keys:
		shares[k] = round(float(shares[k]) * 100.0) / 100.0
		tot2 += int(round(float(shares[k]) * 100.0))
	if tot2 != 100 and keys.size() > 0:
		var adj = keys.filter(func(k): return k != fixed)
		if adj.is_empty(): adj = keys
		shares[adj[0]] = float(shares[adj[0]]) + (100 - tot2) / 100.0


func _update_preview() -> void:
	if _preview == null:
		return
	var cab = ui.sim.cabinet
	var lines: Array = cab.effect_lines(cab.budget_effects(shares))
	var tot := 0
	for k in shares:
		tot += int(round(float(shares[k]) * 100.0))
	_preview.text = UITheme.pal("[color=#e6c76e]Your split:[/color] " + (fx_lines(lines) if lines.size() > 0 else "[color=#a8b0c4]an even split: no gains, no losses[/color]"))
	_pass_btn.disabled = tot != 100


# ------------------------------------------------------------------ mid-year review

func _review() -> void:
	var d := data
	_head("MID-YEAR BUDGET REVIEW", "Budget year %s" % str(d.get("fiscal_year", "")), str(d.get("text", "")))
	_finance_row(finance_line(ui.sim))
	var b: Dictionary = d.get("budget", {})
	var envs: Array = b.get("envelopes", [])
	if envs.size() > 0:
		var parts := []
		for e in envs:
			parts.append("%s %d%%" % [str(e.get("name", e.get("id", ""))), int(round(float(e.get("share", 0)) * 100.0))])
		body.add_child(UITheme.rich("[color=#a8b0c4]In force:[/color] " + ", ".join(parts), 15))
	var i := 0
	for o in d.get("options", []):
		var r := UIRow.new(true)
		var h := r.hrow()
		var nm := UITheme.label(str(o.get("label", "")), 18, UIKit.GOLD_LIGHT, "body_bold")
		nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		h.add_child(nm)
		if o.get("default", false):
			_rec_tag(h)
		r.add(UITheme.rich("[color=#c8ccd6]%s[/color]" % UITheme.humanise(str(o.get("desc", ""))), 14))
		var fx: Array = o.get("effects", [])
		if fx.size() > 0:
			r.add(UITheme.rich(fx_lines(fx), 14))
		var idx := i
		r.pressed.connect(func(_s): ui.choose_cabinet("budget_review", idx))
		body.add_child(r)
		i += 1


# ------------------------------------------------------------------ ministers (Civ VI governors)

func _ministers(deciding: bool) -> void:
	var sim: Sim = ui.sim
	var cab: Dictionary = sim.get_cabinet() if sim.has_method("get_cabinet") else {}
	var titles := int(cab.get("titles", data.get("titles", 0)))
	if deciding:
		var md := str(data.get("mode", ""))
		var sub := "%d cabinet title%s to spend" % [titles, "" if titles == 1 else "s"]
		if md == "cabinet":
			sub = "%s's government takes office: choose %d priorit%s" % [str((data.get("government", {}) as Dictionary).get("pm", "The prime minister")), titles, "y" if titles == 1 else "ies"]
		elif md == "promotion":
			sub = "The year's ministerial programme: %d title%s" % [titles, "" if titles == 1 else "s"]
		_head("THE CABINET", sub, str(data.get("text", "")))
	else:
		_head("THE CABINET", "%d cabinet title%s%s" % [titles, "" if titles == 1 else "s",
			(", the next in %s" % UITheme.turns(int(cab.get("next_title_in", 0)))) if int(cab.get("next_title_in", 0)) > 0 else ""],
			"Each minister has a seat city, where a local effect starts after two quarters; each promotion is a national programme. Cabinet titles accrue every two quarters and with every new government.")
		if sim.has_method("get_budget"):
			var b: Dictionary = sim.get_budget()
			var envs: Array = b.get("envelopes", [])
			if envs.size() > 0:
				var parts := []
				for e in envs:
					parts.append("%s %d%%" % [str(e.get("name", e.get("id", ""))), int(round(float(e.get("share", 0)) * 100.0))])
				body.add_child(UITheme.rich("[color=#e6c76e]State Budget %s:[/color] %s" % [str(b.get("fy", "")), ", ".join(parts)], 15))
		_finance_row(finance_line(sim))
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	body.add_child(h)
	# left: what a title can buy now
	var opts: Array = data.get("options", cab.get("options", []))
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(500, 0)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(left)
	left.add_child(UITheme.section("Spend a title"))
	var ls := ScrollContainer.new()
	ls.custom_minimum_size = Vector2(0, 470)
	ls.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	left.add_child(ls)
	var lv := VBoxContainer.new()
	lv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lv.add_theme_constant_override("separation", 6)
	ls.add_child(lv)
	if titles <= 0:
		lv.add_child(UITheme.label("No title to spend this quarter.", 16, UIKit.TEXT_DIM))
	var multi := deciding and data.has("picks") and titles > 0
	_sel_rows.clear()
	var i := 0
	for o in opts:
		var r := UIRow.new(titles > 0, multi and str(o.get("id", "")) in _sel)
		var rh := r.hrow()
		var tag := UITheme.label("APPOINT" if str(o.get("kind", "")) == "appoint" else "PROMOTE  T%d" % int(o.get("tier", 1)), 12, Color(0.75, 0.86, 1.0), "title")
		tag.custom_minimum_size = Vector2(92, 0)
		rh.add_child(tag)
		var nm := UITheme.label(str(o.get("label", "")), 17, UIKit.GOLD_LIGHT, "body_bold")
		nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		rh.add_child(nm)
		if o.get("default", false) and titles > 0:
			_rec_tag(rh)
		if str(o.get("desc", "")) != "":
			r.add(UITheme.rich("[color=#c8ccd6]%s[/color]" % UITheme.humanise(str(o["desc"])), 14))
		var fx: Array = o.get("effects", [])
		if fx.size() > 0:
			r.add(UITheme.rich(fx_lines(fx), 14))
		var idx := i
		if multi:
			var oid := str(o.get("id", ""))
			_sel_rows[oid] = r
			r.pressed.connect(func(_s): _toggle_pick(oid))
		else:
			r.pressed.connect(func(_s): ui.choose_cabinet("minister", idx))
		lv.add_child(r)
		i += 1
	if multi:
		var fh := HBoxContainer.new()
		fh.add_theme_constant_override("separation", 10)
		_pick_label = UITheme.label("", 16, UIKit.GOLD_LIGHT, "body_bold")
		_pick_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_pick_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		fh.add_child(_pick_label)
		_form_btn = UITheme.button("Confirm", func(): ui.choose_ministers(_sel.duplicate()), 17)
		fh.add_child(_form_btn)
		left.add_child(fh)
		_update_picks()
	if deciding and not bool(data.get("blocking", true)):
		left.add_child(UITheme.button("Keep the title%s for later" % ("" if titles == 1 else "s"), func(): close(), 16))
	# right: the cabinet as it stands
	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(520, 0)
	h.add_child(right)
	right.add_child(UITheme.section("Ministers"))
	var rs := ScrollContainer.new()
	rs.custom_minimum_size = Vector2(0, 470)
	rs.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	right.add_child(rs)
	var rv := VBoxContainer.new()
	rv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rv.add_theme_constant_override("separation", 6)
	rs.add_child(rv)
	for m in cab.get("ministers", data.get("ministers", [])):
		rv.add_child(_minister_card(m))


func _toggle_pick(oid: String) -> void:
	## Multi-pick: click to choose or drop a programme or appointment, up to the titles waiting.
	var n := int(data.get("picks", data.get("titles", 1)))
	if oid in _sel:
		_sel.erase(oid)
	elif _sel.size() >= n:
		if n == 1:
			_sel = [oid]
		else:
			ui.show_toast("All %d titles are chosen: click a chosen one to drop it first." % n, 2.5)
			return
	else:
		_sel.append(oid)
	_update_picks()


func _update_picks() -> void:
	var n := int(data.get("picks", data.get("titles", 1)))
	for k in _sel_rows:
		(_sel_rows[k] as UIRow).set_selected(k in _sel)
	if _pick_label:
		_pick_label.text = "%d of %d title%s chosen%s" % [_sel.size(), n, "" if n == 1 else "s", ": click a row to choose or drop it" if _sel.size() < n else ""]
	if _form_btn:
		_form_btn.disabled = _sel.is_empty()
		var md := str(data.get("mode", ""))
		_form_btn.text = ("Form the cabinet" if md == "cabinet" else "Confirm") + (" (%d)" % _sel.size() if _sel.size() > 0 else "")


func _minister_card(m: Dictionary) -> PanelContainer:
	var pc := PanelContainer.new()
	pc.add_theme_stylebox_override("panel", UITheme.sb(Color(0.06, 0.11, 0.22, 0.95) if m.get("appointed", false) else Color(0.04, 0.06, 0.11, 0.85),
		UIKit.GOLD if m.get("appointed", false) else Color(0.3, 0.3, 0.34), 1, 5, 9))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 2)
	pc.add_child(v)
	var h := HBoxContainer.new()
	v.add_child(h)
	var mp := UIArt.minister_portrait(str(m.get("id", "")), ui.sim.year())   # v3: minister portraits by era (art-2d)
	if mp != null:
		var pb := portrait_box(mp, 44, str(m.get("name", "")))
		# v3 final (fix4-ui, var N7): the era's shared portrait shown again for another portfolio is mirrored, so
		# neighbouring cards do not repeat the same picture (a portfolio's own art, when present, is used as is)
		var seen := int(_portraits_seen.get(mp.get_instance_id(), 0))
		_portraits_seen[mp.get_instance_id()] = seen + 1
		if seen % 2 == 1:
			(pb.get_child(0) as TextureRect).flip_h = true
		h.add_child(pb)
	var nm := UITheme.label(str(m.get("title", m.get("name", ""))), 17, UIKit.GOLD_LIGHT if m.get("appointed", false) else UIKit.TEXT_DIM, "body_bold")
	nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(nm)
	if m.get("appointed", false):
		var seat := OptionButton.new()
		seat.focus_mode = Control.FOCUS_NONE
		seat.add_theme_font_size_override("font_size", 16)
		seat.tooltip_text = "Move the minister's seat (free; two quarters to settle in)."
		var cs: Array = ui.sim.get_cities()
		cs.sort_custom(func(a, b): return int(a["pop"]) > int(b["pop"]))
		var sel := -1
		var ids := []
		for c in cs.slice(0, 30):
			seat.add_item(str(c["name"]))
			ids.append(int(c["id"]))
			if int(c["id"]) == int(m.get("city", 0)):
				sel = ids.size() - 1
		if sel < 0 and str(m.get("city_name", "")) != "":
			seat.add_item(str(m["city_name"]))
			ids.append(int(m.get("city", 0)))
			sel = ids.size() - 1
		seat.select(sel)
		var mid := str(m.get("id", ""))
		seat.item_selected.connect(func(ix): ui.move_minister(mid, int(ids[ix])))
		h.add_child(UITheme.label("Seat:", 14, UIKit.TEXT_DIM))
		h.add_child(seat)
		var st := "settled in" if m.get("established", false) else "settling in (2 quarters)"
		var partner := str(m.get("partner", ""))
		v.add_child(UITheme.label("%s%s" % [st, (", held by a coalition partner (%s)" % partner) if partner != "" else ""], 13, UIKit.TEXT_DIM))
	else:
		h.add_child(UITheme.label("not appointed", 14, UIKit.TEXT_DIM))
	var base: Array = m.get("base", [])
	if base.size() > 0:
		v.add_child(UITheme.rich("[color=#a8b0c4]In the seat city:[/color] " + fx_lines(base), 14))
	var pr := []
	for p in m.get("promotions", []):
		var col := "#9fe07a" if p.get("taken", false) else ("#f3d98f" if p.get("available", false) else "#7d8494")
		pr.append("[color=%s]T%d %s%s[/color]" % [col, int(p.get("tier", 1)), str(p.get("name", "")), " ✓" if p.get("taken", false) else ""])
	if pr.size() > 0:
		var rt := UITheme.rich("[color=#a8b0c4]Promotions:[/color] " + ", ".join(pr), 14)
		var tips := []
		for p in m.get("promotions", []):
			tips.append("T%d %s: %s%s" % [int(p.get("tier", 1)), str(p.get("name", "")), ", ".join((p.get("effects", []) as Array).map(func(x): return fx_label(str(x)))), (" (" + str(p["reason"]) + ")") if str(p.get("reason", "")) not in ["", "taken"] else ""])
		rt.tooltip_text = "\n".join(tips)
		v.add_child(rt)
	return pc


# ------------------------------------------------------------------ coalition talks

func _coalition() -> void:
	var d := data
	var g: Dictionary = d.get("government", {})
	var pm := str(g.get("pm", "The prime minister"))
	var sub: String = {"succession": "%s takes over without an election", "rotation": "%s takes office under the rotation agreement",
		"unity": "%s forms a national unity government", "reformed": "%s rebuilds the coalition without an election"}.get(str(d.get("how", g.get("how", "election"))), "%s forms a government after the election") % pm
	_head("COALITION TALKS", sub, str(d.get("text", "")))
	var i := 0
	for o in d.get("options", []):
		var r := UIRow.new(true)
		var h := r.hrow()
		var nm := UITheme.label(str(o.get("label", "")), 18, UIKit.GOLD_LIGHT, "body_bold")
		nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		h.add_child(nm)
		if o.get("historical", false) and UITheme.show_hints:
			var ht := UITheme.label("historical", 14, Color(0.75, 0.72, 0.62))
			ht.tooltip_text = "The partner that actually joined this government."
			h.add_child(ht)
		if o.get("default", false):
			_rec_tag(h)
		var who := []
		if str(o.get("party", "")) != "":
			who.append(L10n.plain(str(o["party"])))
		var pf: Array = o.get("portfolios", []) if typeof(o.get("portfolios")) == TYPE_ARRAY else []
		if pf.size() > 0:   # each portfolio translated on its own before the list is joined ("Social Welfare" in Hebrew)
			who.append("asks for " + ", ".join(pf.map(func(x): return L10n.plain(str(x)))))
		if who.size() > 0:
			r.add(UITheme.rich("[color=#e6c76e]%s[/color]" % UITheme.humanise("; ".join(who)), 14))
		if str(o.get("advocate", "")) != "":
			r.add(UITheme.rich("[color=#a8b0c4]Advocated by %s[/color]" % str(o["advocate"]), 14))
		r.add(UITheme.rich("[color=#c8ccd6]%s[/color]" % UITheme.humanise(str(o.get("desc", ""))), 14))
		var fx: Array = o.get("effects", [])
		if fx.size() > 0:
			r.add(UITheme.rich(fx_lines(fx), 14))
		var src: Array = o.get("source", [])
		if src.size() > 0:
			r.add(UITheme.rich("[color=#8a93a8]Sources: %s[/color]" % ", ".join(src), 13))
		var idx := i
		r.pressed.connect(func(_s): ui.choose_cabinet("coalition", idx))
		body.add_child(r)
		i += 1
