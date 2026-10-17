class_name MinistersPanel
extends UIWindow
## v4 story mode (V4_DESIGN 2.2, 2.6): the Cabinet Room (one row per ministry: who runs it, what it did last, and the
## auto / manual toggle; the ministers' brief; the play style) and, as the inner class Strip, the HUD's "Your ministers
## did" report. While the sim has no `sim.auto`, `settle()` is the UI's own fallback minister: it answers every
## routine decision of an auto ministry with the Recommended pick (SimAI, the same code as the Recommended badges)
## and writes the report lines.

const MAX_QUARTERS := 8

var _msg: Label


func _init() -> void:
	super._init("Cabinet Room")


func open_room() -> void:
	refresh()
	visible = true


func refresh() -> void:
	clear_body()
	if ui == null or ui.sim == null:
		return
	title_label.text = "CABINET ROOM"
	body.add_child(UITheme.rich("[color=#c8ccd6]Your ministers run the routine with the Recommended choices and report what they did each quarter. Take a ministry over at any time; hand it back the same way. The big calls (wars, forks, peace, budgets, programmes) are always yours.[/color]", 16))
	# play style
	var sh := HBoxContainer.new()
	sh.add_theme_constant_override("separation", 8)
	body.add_child(sh)
	var sl := UITheme.label("How do you play?", 17, UIKit.GOLD, "body_bold")
	sl.custom_minimum_size = Vector2(250, 0)
	sh.add_child(sl)
	var st := NextStep.style(ui)
	for p in [["story", "Story"], ["full", "Full control"]]:
		var b := UITheme.button(p[1], ui.set_play_style.bind(p[0]), 16)
		b.name = "room_style_" + p[0]
		_mark(b, st == p[0])
		sh.add_child(b)
	if st == "custom":
		sh.add_child(UITheme.label("(Custom: some ministries are yours)", 15, UIKit.TEXT_DIM))
	# the ministers' brief
	var bh := HBoxContainer.new()
	bh.add_theme_constant_override("separation", 6)
	body.add_child(bh)
	var bl := UITheme.label("What should your ministers put first?", 17, UIKit.GOLD, "body_bold")
	bl.custom_minimum_size = Vector2(250, 0)
	bl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bh.add_child(bl)
	var cur_b := NextStep.brief(ui)
	for b2 in NextStep.BRIEFS:
		var bb := UITheme.button(b2[1], ui.set_ministers_brief.bind(b2[0]), 15)
		bb.tooltip_text = str(b2[2])
		bb.name = "room_brief_" + str(b2[0])
		_mark(bb, cur_b == b2[0])
		bh.add_child(bb)
	body.add_child(UITheme.sep())
	add_domain_rows(body, ui)
	_msg = UITheme.label("", 15, UIKit.GOLD_LIGHT)
	_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(_msg)
	# the last quarters' reports
	body.add_child(UITheme.section("YOUR MINISTERS DID"))
	var sc := scroll_body(150)
	var any := false
	var reps: Array = all_reports(ui)
	for r in reps:
		var lines: Array = r.get("lines", [])
		if lines.is_empty():
			continue
		any = true
		sc.add_child(UITheme.label(SimDB.date_label(int(r.get("turn", 0))), 15, UIKit.GOLD))
		for ln in lines:
			var l := UITheme.label("• " + line_text(ui, ln), 15, UIKit.TEXT)
			l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			l.tooltip_text = jargon_tip(str(ln.get("text", "")))
			if l.tooltip_text != "":
				l.mouse_filter = Control.MOUSE_FILTER_PASS
			sc.add_child(l)
	if not any:
		sc.add_child(UITheme.label("Nothing yet: the ministers report from the next quarter.", 15, UIKit.TEXT_DIM))
	var foot := HBoxContainer.new()
	foot.add_theme_constant_override("separation", 8)
	foot.alignment = BoxContainer.ALIGNMENT_END
	body.add_child(foot)
	foot.add_child(UITheme.button("Cabinet and State Budget", func(): close(); ui.open_panel("cabinet"), 16))
	foot.add_child(UITheme.button("Done", close, 16))


static func _mark(b: Button, on: bool) -> void:
	b.add_theme_stylebox_override("normal", UITheme.sb(Color(0.16, 0.34, 0.66) if on else Color(0.08, 0.14, 0.28, 0.95), UIKit.GOLD_LIGHT if on else Color(0.45, 0.38, 0.22), 2 if on else 1, 5, 8))


static func add_domain_rows(box: Control, ui, compact := false) -> void:
	## One row per ministry: the minister of the day, the domain, its last action and the toggle (Cabinet Room and
	## Settings > Gameplay).
	var g := GridContainer.new()
	g.columns = 3 if compact else 4
	g.add_theme_constant_override("h_separation", 12)
	g.add_theme_constant_override("v_separation", 4)
	box.add_child(g)
	var last := last_lines(ui)
	for d in NextStep.domains(ui.sim):
		var id := str(d["id"])
		var who := UITheme.label(NextStep.minister_label(ui.sim, id), 16, UIKit.GOLD_LIGHT, "bold_sans")   # v4final: "(מזכיר הממשלה)" legible in Hebrew
		who.custom_minimum_size = Vector2(250, 0)
		g.add_child(who)
		var what := UITheme.label(str(d.get("name", id)), 16, UIKit.TEXT)
		what.tooltip_text = str(d.get("desc", ""))
		what.mouse_filter = Control.MOUSE_FILTER_PASS
		what.custom_minimum_size = Vector2(230, 0)
		g.add_child(what)
		if not compact:
			var ll := UITheme.label(str(last.get(id, "-")), 14, UIKit.TEXT_DIM)
			ll.custom_minimum_size = Vector2(250, 0)
			ll.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			ll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			g.add_child(ll)
		var on := NextStep.is_auto(ui, id)
		var tg := CheckButton.new()
		tg.text = "Minister decides" if on else "You decide"
		tg.button_pressed = on
		tg.focus_mode = Control.FOCUS_NONE
		tg.add_theme_font_size_override("font_size", 15)
		tg.name = "auto_" + id
		tg.toggled.connect(func(v: bool): ui.set_domain_auto(id, v))
		g.add_child(tg)


static func last_lines(ui) -> Dictionary:
	## domain id -> its latest report line (the Cabinet Room's "last action" column).
	var out := {}
	if NextStep.has_api(ui.sim, "domain_view"):
		for dv in NextStep.auto_api(ui.sim).domain_view():
			var last: Array = dv.get("last", []) if dv.get("last") is Array else []
			if not last.is_empty():
				out[str(dv.get("id", ""))] = line_text(ui, last[last.size() - 1]) if last[last.size() - 1] is Dictionary else str(last[last.size() - 1])
		return out
	var reps: Array = all_reports(ui)
	for r in reps:
		for ln in r.get("lines", []):
			var dom := str(ln.get("domain", ""))
			if dom != "" and not out.has(dom):
				out[dom] = line_text(ui, ln)
	return out


# ================================================================== the report

static func report(ui, turn := -1) -> Dictionary:
	## {turn, lines: [{domain, key, args, text, ref}]} for one quarter (the latest when turn = -1).
	if ui == null or ui.sim == null:
		return {"turn": 0, "lines": []}
	var t: int = ui.sim.state.turn if turn < 0 else turn
	if NextStep.has_api(ui.sim, "report"):
		var r = NextStep.auto_api(ui.sim).report(t)
		if r is Dictionary:
			return r
	for r2 in ui.casual.get("report", []):
		if int(r2.get("turn", -1)) == t:
			return r2
	return {"turn": t, "lines": []}


static func all_reports(ui) -> Array:
	## The last quarters' reports, newest first.
	var out := []
	if ui == null or ui.sim == null:
		return out
	for k in MAX_QUARTERS:
		var t: int = ui.sim.state.turn - k
		if t < 1:
			break
		var r := report(ui, t)
		if not (r.get("lines", []) as Array).is_empty():
			out.append(r)
	return out


static func strip_lines(ui) -> Array:
	## What the HUD strip shows: the quarter that just ended (with this quarter's turn-start actions) and what the
	## ministers did since (deduplicated, at most 8).
	var out := []
	var seen := {}
	if ui == null or ui.sim == null:
		return out
	var reps := []
	if NextStep.has_api(ui.sim, "report"):
		reps = [NextStep.auto_api(ui.sim).report(-1), NextStep.auto_api(ui.sim).report(ui.sim.state.turn)]
	else:
		reps = [report(ui, ui.sim.state.turn), report(ui, ui.sim.state.turn - 1)]
	for r in reps:
		if not (r is Dictionary):
			continue
		for ln in r.get("lines", []):
			var tx := str(ln.get("text", ""))
			if tx == "" or seen.has(tx):
				continue
			seen[tx] = true
			out.append(ln)
	return out.slice(0, 8)


# v4polish (new-player: "a wall of jargon"): the strip shows the 3 most important lines first ("N more" opens the rest),
# and the words of the period explain themselves: a hover on the line, and once per game a short line under it.
const STRIP_TOP := 3
const LINE_RANK := {"auto.settlement.found": 10, "auto.budget.levers": 9, "auto.budget.plan_end": 9, "auto.immigration.plan": 8,
	"auto.budget.loan": 8, "auto.policies.review": 7, "auto.production.project": 7, "auto.units.attacks": 6, "auto.cabinet.ministers": 6,
	"auto.budget.review": 6, "auto.budget.agenda": 6, "auto.trade.route": 5, "auto.delegations.sent": 5, "auto.research.set": 5,
	"auto.civics.set": 4, "auto.production.set": 4, "auto.budget.hold_surplus": 4, "auto.budget.hold_last": 4, "auto.budget.defer": 4,
	"auto.budget.reopen": 4, "auto.budget.restore": 4, "auto.policies.fill": 4, "auto.policies.reslot": 4, "auto.budget.purchase": 3,
	"auto.budget.spent": 3, "auto.production.replan": 2, "auto.settlement.build": 2, "auto.units.stand_down": 2, "auto.units.moved": 1,
	"auto.units.orders": 1, "auto.settlement.moved": 1, "auto.settlement.orders": 1}
# [regex on the English line, the first-time gloss, the hover]
const JARGON := [
	["[Mm]a'abar(a|ot)|Transit Camp", "Transit camp (ma'abara): a camp of tents and tin huts where newcomers lived until homes were built.",
		"Transit camp (ma'abara): a camp of tents and tin huts where newcomers lived in the 1950s until homes were built. Crowded camps lower Civic Trust and growth."],
	["Shikun", "Shikun blocks: plain public housing the state built fast for newcomers.",
		"Shikun blocks: plain public housing blocks the state built fast for newcomers. They empty the transit camps."],
	["Absorption Centre", "Absorption centre: a hostel where newcomers learn Hebrew and find work.",
		"Absorption centre: a hostel where newcomers spend their first months, learn Hebrew and find work."],
	["[Ss]ettlers|[Ss]ettlement [Gg]roup", "Settlers: groups of newcomers sent out to found new towns and villages.",
		"Settlers (settlement groups): groups of newcomers sent out to found new towns, kibbutzim and moshavim."],
	["[Ww]ork crews?|Public Works Crew", "Work crews: teams that build farms, roads and water works around the towns.",
		"Work crews (public works crews): teams that build farms, roads, orchards and water works on the land around the towns."],
	["[Dd]evelopment [Tt]owns?", "Development towns: new towns of the 1950s on the edges of the country.",
		"Development towns: new towns built in the 1950s on the edges of the country to house the newcomers."],
	["overdraft", "Overdraft: Finance spends more than the Treasury holds and borrows the rest.",
		"Overdraft: Finance spends more than the Treasury holds and borrows the rest, as Israel did in 1949-51."],
	["[Pp]olicy|policies", "Policy: one of the government's standing programmes (its policy cards).",
		"Policy (policy card): one of the government's standing programmes. Each new government sets its own."],
]
static var _jargon_re := {}


static func line_rank(ln: Dictionary) -> int:
	## How much a report line matters to the player (higher first): a new town, the Treasury and the newcomers lead; the
	## units' and crews' routine comes last.
	var k := str(ln.get("key", "")).trim_suffix(".one")
	if LINE_RANK.has(k):
		return int(LINE_RANK[k])
	var tx := str(ln.get("text", ""))
	if tx.contains("founded"): return 10
	if tx.begins_with("Finance") or tx.begins_with("Absorption"): return 6
	if tx.begins_with("Defence") or tx.begins_with("Agriculture"): return 2
	return 3


static func ranked_lines(ui) -> Array:
	## The strip's lines, most important first (a stable order among equals).
	var ls: Array = strip_lines(ui)
	var idx := []
	for i in ls.size():
		idx.append([-line_rank(ls[i]), i])
	idx.sort()
	return idx.map(func(x): return ls[int(x[1])])


static func jargon_in(text: String) -> Array:
	## The JARGON entries a report line uses (English text).
	var out := []
	for j in JARGON:
		var w := str(j[0])
		if not _jargon_re.has(w):
			_jargon_re[w] = RegEx.create_from_string("\\b(?:" + w + ")")
		if (_jargon_re[w] as RegEx).search(text) != null:
			out.append(j)
	return out


static func jargon_tip(text: String) -> String:
	return "\n".join(jargon_in(text).map(func(j): return str(j[2])))


static func line_text(ui, ln: Dictionary) -> String:
	## A report line as the screen shows it. English: the sim's text. Hebrew: the template by its key with the
	## translated values ("L10n.t(short) + ': ' + L10n.t(key).format(args)", API.md), else the text itself.
	var tx := str(ln.get("text", ""))
	var key := str(ln.get("key", ""))
	if L10n.lang == "en" or key == "" or not L10n.catalog.has(key) or (L10n._tr(tx, 0)[1] as Array).is_empty():
		return tx   # (sim_v4_auto.json translates the finished English line; the template path is the fallback)
	var args = ln.get("args", {})
	var a2 := {}
	if args is Dictionary:
		for k in args:
			var v = args[k]
			a2[k] = L10n.t(str(v)) if v is String else str(v)
	var short := ""
	for d in NextStep.domains(ui.sim):
		if str(d.get("id", "")) == str(ln.get("domain", "")):
			short = str(d.get("short", ""))
	var body_t := str(L10n.catalog[key]).format(a2)
	return (L10n.t(short) + ": " + body_t) if short != "" else body_t


static func _record(ui, lines: Array) -> void:
	if lines.is_empty():
		return
	var reps: Array = ui.casual.get("report", [])
	var t: int = ui.sim.state.turn
	var cur := {}
	for r in reps:
		if int(r.get("turn", -1)) == t:
			cur = r
	if cur.is_empty():
		cur = {"turn": t, "lines": []}
		reps.append(cur)
	for ln in lines:
		(cur["lines"] as Array).append(ln)
	while reps.size() > MAX_QUARTERS + 2:
		reps.pop_front()
	ui.casual["report"] = reps


# ================================================================== the fallback ministers (until sim.auto exists)

static func settle(ui) -> int:
	## Answers every pending routine decision of an auto ministry with the Recommended pick, at most 120 passes, with a
	## per-decision fail guard (as Tutorial.gate). Returns how many it answered. sim.auto.settle() when the sim has it.
	if ui == null or ui.sim == null or ui.sim.state.game_over or ui.full_hud:
		return 0
	var sim = ui.sim
	if NextStep.has_api(sim, "settle"):
		return int(NextStep.auto_api(sim).settle())
	var n := 0
	var lines: Array = []
	var fail := {}
	var had_style: bool = sim.state.counters.has("ai_style")
	var keep_style = sim.state.counters.get("ai_style", "")
	var br := NextStep.brief(ui)
	if br != "balanced":
		sim.state.counters["ai_style"] = "strategist_" + br   # the brief tilts the routine only (2.2)
	if NextStep.is_auto(ui, "production"):
		for c in sim.active_cities():
			if not c.automate:
				sim.set_city_automated(c.id, true)
	var agg := {}   # the units and productions of this pass, summed into one line each
	for i in 120:
		var target := {}
		var dom := ""
		for d in sim.blocking_decisions():
			var o := NextStep.owner_of(ui, d)
			if o == "":
				continue
			var key := "%s:%s" % [str(d["type"]), str(d.get("event", d.get("city", d.get("unit", d.get("slot", "")))))]
			if int(fail.get(key, 0)) >= 3:
				continue
			fail[key] = int(fail.get(key, 0)) + 1
			target = d
			dom = o
			break
		if target.is_empty():
			break
		_resolve_routine(ui, target, dom, lines, agg)
		n += 1
	_programme_rules(ui, lines)
	if br != "balanced":
		if had_style:
			sim.state.counters["ai_style"] = keep_style
		else:
			sim.state.counters.erase("ai_style")
	_agg_lines(ui, agg, lines)
	_record(ui, lines)
	return n


static func _resolve_routine(ui, d: Dictionary, dom: String, lines: Array, agg: Dictionary) -> void:
	var sim = ui.sim
	var t := str(d["type"])
	match t:
		"unit_orders":
			var u = sim.unit_by_id(int(d["unit"]))
			if u == null:
				return
			var towns0: int = sim.active_cities().size()
			var ch0 := int(u.charges)
			if str(u.type) == "settler":
				SimAI._settler(sim, u)
				if sim.active_cities().size() > towns0:
					var nc = sim.active_cities()[sim.active_cities().size() - 1]
					lines.append(_ln("settlement", "Agriculture: a settlement group founded %s." % str(nc.name), {"kind": "city", "id": nc.id}))
			elif str(u.type) == "builder":
				SimAI._builder(sim, u)
				if sim.unit_by_id(int(d["unit"])) == null or int(u.charges) < ch0:
					agg["crews"] = int(agg.get("crews", 0)) + 1
			else:
				SimAI._military(sim, u)
				agg["units"] = int(agg.get("units", 0)) + 1
			if sim.unit_by_id(int(d["unit"])) != null and sim.blocking_decisions().any(func(x): return str(x["type"]) == "unit_orders" and int(x.get("unit", -1)) == int(d["unit"])):
				sim.resolve_recommended(d)
		"choose_production":
			var c = sim.city_by_id(int(d["city"]))
			sim.resolve_recommended(d)
			if c != null and not c.queue.is_empty():
				var it: Dictionary = c.queue[0]
				var pl: Array = agg.get("prod", [])
				pl.append([str(c.name), ui.item_name(str(it.get("kind", "")), str(it.get("id", ""))), c.id])
				agg["prod"] = pl
		"choose_research":
			sim.resolve_recommended(d)
			if sim.state.current_tech != "":
				lines.append(_ln("research", "Education: research %s." % ui.item_name("tech", sim.state.current_tech), {"kind": "panel", "id": "research"}))
		"choose_civic":
			sim.resolve_recommended(d)
			if sim.state.current_civic != "":
				lines.append(_ln("civics", "Education: civic %s." % ui.item_name("civic", sim.state.current_civic), {"kind": "panel", "id": "civic"}))
		"fill_policy":
			var before: Array = sim.state.policies.map(func(p): return str(p.get("id", "")))
			sim.resolve_recommended(d)
			for i in sim.state.policies.size():
				var pid := str(sim.state.policies[i].get("id", ""))
				if pid != "" and not pid.begins_with("__") and (i >= before.size() or pid != before[i]):
					lines.append(_ln("policies", "Prime Minister's Office: the %s card fills a policy slot." % ui.item_name("policy", pid), {"kind": "panel", "id": "policy"}))
		"policy_review":
			sim.resolve_recommended(d)
			lines.append(_ln("policies", "New government: the prime minister's programme sets the policy cards.", {"kind": "panel", "id": "policy"}))
		"immigration":
			var opts: Array = d.get("options", [])
			sim.resolve_recommended(d)
			var plan: Dictionary = sim.state.immigration_plan if sim.state.get("immigration_plan") is Dictionary else {}
			var lab := ""
			for o in opts:
				if str(o.get("id", "")) in [str(plan.get("variant", "")), str(plan.get("option", ""))] and lab == "":
					lab = str(o.get("label", ""))
			lines.append(_ln("immigration", ("Absorption: this year's newcomers go to %s." % lab.to_lower()) if lab != "" else "Absorption: this year's immigration plan is set.", {"kind": "", "id": ""}))
		"minister":
			sim.resolve_recommended(d)
			lines.append(_ln("cabinet", "Prime Minister's Office: the cabinet's titles went to the Recommended appointments.", {"kind": "panel", "id": "cabinet"}))
		"budget_review":
			var ro: Array = sim.cabinet.review_options()
			var pick := SimAI.pick_option(sim, ro, false, ["supplement", "keep"])
			if not sim.choose_budget_review(pick):
				sim.resolve_recommended(d)
			var lab2 := str(ro[pick].get("label", "")) if pick >= 0 and pick < ro.size() else ""
			lines.append(_ln("budget", ("Finance: the mid-year review: %s." % lab2) if lab2 != "" else "Finance: the mid-year review is done.", {"kind": "panel", "id": "cabinet"}))
		"agenda":
			var title := str(sim.state.agenda.get("title", ""))
			var ao: Array = sim.state.agenda.get("options", [])
			var ai := SimAI.pick_agenda(sim)
			sim.choose_agenda(ai)
			var lab3 := str(ao[ai].get("label", "")) if ai >= 0 and ai < ao.size() else ""
			lines.append(_ln("budget", ("Finance: %s: %s." % [title, UITheme.humanise(lab3)]) if lab3 != "" else "Finance: the cabinet agenda is answered.", {"kind": "", "id": ""}))
		_:
			sim.resolve_recommended(d)


static func _programme_rules(ui, lines: Array) -> void:
	## Queue rules 2 and 3 (2.4): at most one surplus prompt a year besides the budget's, and a quarter that already
	## holds 3 player decisions defers its programme decision (Finance holds the surplus or answers "not now").
	var sim = ui.sim
	if NextStep.has_api(sim, "settle"):
		return
	var pd: Array = sim.blocking_decisions().filter(func(x): return NextStep.owner_of(ui, x) == "")
	var prog := {}
	for d in pd:
		if str(d["type"]) == "programme":
			prog = d
	if prog.is_empty():
		return
	var kind := str(prog.get("kind", ""))
	var yr: int = sim.year()
	var crowded := pd.size() - 1 >= 3
	var budget_q := pd.any(func(x): return str(x["type"]) == "state_budget")
	var extra := kind == "surplus" and not budget_q and int(ui.casual.get("surplus_year", -1)) == yr
	if not crowded and not extra:
		if kind == "surplus" and not budget_q:
			ui.casual["surplus_year"] = yr
		return
	var opts: Array = prog.get("options", [])
	for i in opts.size():
		if str(opts[i].get("id", "")) in ["hold", "defer"]:
			if sim.choose_programme(i):
				lines.append(_ln("budget", "Finance kept the surplus; the programmes come up again at the budget." if kind == "surplus" else "Finance deferred the programme to a quieter quarter.", {"kind": "panel", "id": "programmes"}))
			return


static func _agg_lines(ui, agg: Dictionary, lines: Array) -> void:
	var pl: Array = agg.get("prod", [])
	if pl.size() == 1:
		lines.push_front(_ln("production", "Production: %s builds %s." % [pl[0][0], pl[0][1]], {"kind": "city", "id": pl[0][2]}))
	elif pl.size() > 1:
		lines.push_front(_ln("production", "Production: %d cities chose their next build (%s: %s; %s: %s)." % [pl.size(), pl[0][0], pl[0][1], pl[1][0], pl[1][1]], {"kind": "panel", "id": "cities"}))
	if int(agg.get("units", 0)) > 0:
		var war: bool = ui.sim.state.crises.size() > 0
		lines.append(_ln("units", ("Defence: %d units took up positions for the war." if war else "Defence: %d units took their orders.") % int(agg["units"]), {"kind": "", "id": ""}))
	if int(agg.get("crews", 0)) > 0:
		lines.append(_ln("settlement", "Agriculture: public-works crews improved %d tiles." % int(agg["crews"]), {"kind": "", "id": ""}))


static func _ln(domain: String, text: String, ref: Dictionary) -> Dictionary:
	return {"domain": domain, "key": "", "args": [], "text": text, "ref": ref}


# ================================================================== the HUD strip

class Strip:
	extends PanelContainer
	## "YOUR MINISTERS DID, Q1 1973 ▾" + [Cabinet Room]; open, the quarter's lines and this quarter's headlines.
	var ui
	var opened := false
	var expanded := false              # v4polish: every line ("N more" pressed), else the 3 most important
	var more_btn: Button
	var glossed_now: Array = []        # the JARGON words this refresh explained for the first time (tests)
	var _shown_turn := -1
	var toggle_btn: Button
	var room_btn: Button
	var lines_box: VBoxContainer

	func _init() -> void:
		add_theme_stylebox_override("panel", UITheme.sb(Color(0.03, 0.07, 0.15, 0.93), UIKit.GOLD, 1, 6, 8))
		mouse_filter = Control.MOUSE_FILTER_STOP
		name = "MinistersStrip"
		var v := VBoxContainer.new()
		v.add_theme_constant_override("separation", 4)
		add_child(v)
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 6)
		v.add_child(h)
		toggle_btn = UITheme.button("", func(): opened = not opened; refresh(), 15)
		toggle_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		toggle_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		toggle_btn.name = "ministers_toggle"
		h.add_child(toggle_btn)
		room_btn = UITheme.button("Cabinet Room", func(): ui.open_cabinet_room(), 15)
		room_btn.name = "cabinet_room"
		h.add_child(room_btn)
		lines_box = VBoxContainer.new()
		lines_box.add_theme_constant_override("separation", 2)
		v.add_child(lines_box)

	func refresh() -> void:
		if ui == null or ui.sim == null:
			return
		var ls: Array = MinistersPanel.ranked_lines(ui)
		var t: int = ui.sim.state.turn
		if _shown_turn != t:
			_shown_turn = t
			expanded = false   # each quarter's report opens on its 3 most important lines
		toggle_btn.text = "%s  YOUR MINISTERS DID, %s  (%d)" % ["▾" if opened else "▸", SimDB.date_label(maxi(1, t - 1)), ls.size()]
		for c in lines_box.get_children():
			lines_box.remove_child(c)
			c.queue_free()
		more_btn = null
		glossed_now = []
		lines_box.visible = opened
		if not opened:
			return
		if ls.is_empty():
			lines_box.add_child(UITheme.label("Nothing to report this quarter.", 14, UIKit.TEXT_DIM))
		var seen: Dictionary = ui.casual.get("glossed_report", {}) if ui.casual.get("glossed_report") is Dictionary else {}
		var shown: Array = ls if expanded else ls.slice(0, MinistersPanel.STRIP_TOP)
		for ln in shown:
			var en := str(ln.get("text", ""))
			var l := UITheme.label("• " + MinistersPanel.line_text(ui, ln), 14, UIKit.TEXT)
			l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			l.custom_minimum_size = Vector2(380, 0)
			l.tooltip_text = MinistersPanel.jargon_tip(en)
			if l.tooltip_text != "":
				l.mouse_filter = Control.MOUSE_FILTER_PASS   # (the hover explains the period's words)
			lines_box.add_child(l)
			for j in MinistersPanel.jargon_in(en):
				var w := str(j[0])
				if seen.has(w) and int(seen[w]) != t:
					continue   # (explained on an earlier quarter's report)
				seen[w] = int(seen.get(w, t))
				if w in glossed_now:
					continue
				glossed_now.append(w)
				var gl := UITheme.label(str(j[1]), 13, Color(0.72, 0.75, 0.82))
				gl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				gl.custom_minimum_size = Vector2(370, 0)
				gl.name = "report_gloss"
				lines_box.add_child(gl)
		ui.casual["glossed_report"] = seen
		var hist: Array = ui.story_headlines()
		var n_more: int = maxi(0, ls.size() - MinistersPanel.STRIP_TOP) + mini(hist.size(), 4)
		if n_more > 0:
			more_btn = UITheme.button(("%d more ▾" % n_more) if not expanded else "Fewer ▴", func(): expanded = not expanded; refresh(), 14)
			more_btn.name = "ministers_more"
			more_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			lines_box.add_child(more_btn)
		if not expanded:
			return   # (the quarter's headlines wait under "N more", with the other lines)
		if not hist.is_empty():
			lines_box.add_child(UITheme.label("THIS QUARTER IN HISTORY", 14, UIKit.GOLD, "title"))
			var bb := ""
			for n in hist.slice(0, 4):
				var eid := str(n.get("event", ""))
				var tx := UITheme.humanise(str(n.get("text", "")))
				bb += ("• [url=event:%s]%s[/url]\n" % [eid, tx]) if eid != "" else ("• %s\n" % tx)
			var r := UITheme.rich(bb.strip_edges(), 14)
			r.custom_minimum_size = Vector2(380, 0)
			r.meta_clicked.connect(func(m): if str(m).begins_with("event:"): ui.open_event(str(m).substr(6)))
			lines_box.add_child(r)
