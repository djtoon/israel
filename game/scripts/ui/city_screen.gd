class_name CityScreen
extends UIWindow
## City screen (Civ VI city panel + production panel + City Details):
##  - facts grid and yields with citizen focus; worked tiles highlighted on the map
##  - tabs: Production (current build with Buy, queue, grouped list with district effects), Purchase, Details
##    (itemised growth, food, housing and amenity breakdowns; buildings and districts with their effects)

var city_id := -1
var show_locked := false
var tab := "production"
var _scroll_keep := 0

const KIND_ICON := {"district": "cities", "building": "production", "unit": "diplomacy", "project": "star", "city_project": "gold"}
const YIELD_ICON := {"science": "science", "gold": "gold", "production": "production", "culture": "culture", "amenity": "happy", "food": "food"}


func _init() -> void:
	super._init("City")


func open_city(id: int) -> void:
	if id != city_id:
		_scroll_keep = 0
	city_id = id
	visible = true
	refresh()


func refresh() -> void:
	var sc := _find_scroll()
	if sc:
		_scroll_keep = sc.scroll_vertical
	clear_body()
	var sim: Sim = ui.sim
	var c := sim.get_city(city_id)
	if c.is_empty():
		visible = false
		return
	var cobj = sim.city_by_id(city_id)
	title_label.text = str(c["name"]).to_upper() + ("  (CAPITAL)" if c.get("capital", false) else "")
	var y: Dictionary = c.get("yields", {})
	var info: Dictionary = c.get("info", {})
	var pop := int(c.get("pop", 1))
	# --- header facts
	var g := GridContainer.new()
	g.columns = 4
	g.add_theme_constant_override("h_separation", 14)
	g.add_theme_constant_override("v_separation", 2)
	body.add_child(g)
	var ttg := int(c.get("turns_to_grow", -1))
	var housing := float(info.get("housing", 0))
	var gb := CityMath.growth(sim, cobj)
	_fact(g, "Population", "%d  (%s residents)" % [pop, UITheme.fmt_num(float(c["residents"]))], "Population points = round(sqrt(residents / 1000)).")
	_fact(g, "Growth", UITheme.turns(ttg) if ttg > 0 and ttg < 999 else "stalled", "Growth rate %d%% of the natural rate. See Details." % int(round(gb["mult"] * 100)))
	var surplus := float(y.get("food", 0)) - 2.0 * pop
	_fact(g, "Food", "%s surplus" % UITheme.fmt_signed(surplus, 1), "%s produced - %d eaten (2 per population). See Details." % [str(snappedf(float(y.get("food", 0)), 0.1)), 2 * pop])
	_fact(g, "Housing", "%d / %s (pop / housing)" % [pop, str(snappedf(housing, 0.5))], "Growth x%.2f from housing. See Details." % gb["housing_f"])
	var transit := float(info.get("transit", 0))
	_fact(g, "Transit camps", UITheme.fmt_num(transit) + " residents" if transit > 0 else "none", "Residents beyond housing capacity live in transit camps (ma'abarot).")
	var ast := str(info.get("amenity_state", "")).capitalize()
	var tb := str(info.get("trust_band", "")).capitalize()
	_fact(g, "Amenities", UITheme.fmt_signed(float(info.get("amenity_balance", 0))) + ((" (%s)" % ast) if ast != "" else ""), "See Details for sources.")
	_fact(g, "Civic Trust", str(int(float(c.get("trust", 0)))) + ((" (%s)" % tb) if tb != "" else ""), "")
	var ghost := float(c.get("ghost_residents", 0))
	_fact(g, "History (census)", UITheme.fmt_num(ghost) if ghost > 0 else "-", "The sourced census figure for this locality at this date.")
	# --- yields row with focus buttons
	var yr := HBoxContainer.new()
	yr.add_theme_constant_override("separation", 4)
	body.add_child(yr)
	for yk in ["food", "production", "gold", "science", "culture"]:
		var b := Button.new()
		b.focus_mode = Control.FOCUS_NONE
		b.icon = UIKit.icon(yk)
		b.expand_icon = false
		b.text = UITheme.fmt_signed(float(y.get(yk, 0)), 1)
		b.add_theme_constant_override("icon_max_width", 22)
		b.tooltip_text = "Citizen focus: favour %s (click again to clear)" % yk.capitalize()
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if str(c.get("focus", "")) == yk:
			b.add_theme_stylebox_override("normal", UITheme.sb(Color(0.16, 0.30, 0.55), UIKit.GOLD_LIGHT, 2, 5, 6))
		var fk: String = yk
		b.pressed.connect(func(): ui.set_focus(city_id, "" if str(c.get("focus", "")) == fk else fk))
		yr.add_child(b)
	# --- tabs
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 4)
	body.add_child(tabs)
	var tdefs := [["production", "Production"], ["citizens", "Citizens"], ["purchase", "Purchase"], ["details", "Details"]]
	if sim.has_method("get_city_upkeep"):
		tdefs.append(["upkeep", "Upkeep"])   # V3 fix round (fix3-econ): mothball or close buildings
	elif tab == "upkeep":
		tab = "production"
	for tdef in tdefs:
		var tbn := UITheme.button(tdef[1], func(): tab = tdef[0]; _scroll_keep = 0; refresh(); ui._show_city_tiles(), 16)
		tbn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if tab == tdef[0]:
			tbn.add_theme_stylebox_override("normal", UITheme.sb(Color(0.18, 0.34, 0.66), UIKit.GOLD_LIGHT, 2, 5, 8))
		tabs.add_child(tbn)
	match tab:
		"citizens": _tab_citizens(sim, c)
		"purchase": _tab_purchase(sim, c)
		"details": _tab_details(sim, c, cobj, gb)
		"upkeep": _tab_upkeep(sim)
		_: _tab_production(sim, c, y)
	await get_tree().process_frame
	var sc2 := _find_scroll()
	if sc2:
		sc2.scroll_vertical = _scroll_keep


# ------------------------------------------------------------------ production tab

func _tab_production(sim: Sim, c: Dictionary, y: Dictionary) -> void:
	var cur: Dictionary = c.get("producing", {})
	var ph := HBoxContainer.new()
	body.add_child(ph)
	ph.add_child(UITheme.icon("production", 26))
	if cur.is_empty():
		ph.add_child(UITheme.label("Choose production below", 19, Color(1.0, 0.75, 0.35), "body_bold"))
	else:
		var nm := UITheme.label("%s: %s" % [ui.item_name(cur["kind"], cur["id"]), UITheme.turns(int(cur["turns"]))], 18, UIKit.GOLD_LIGHT, "body_bold")
		nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nm.clip_text = true
		nm.tooltip_text = "%d of %d production stored" % [int(cur["progress"]), int(cur["cost"])]
		ph.add_child(nm)
		var cp: Dictionary = sim.current_purchase(city_id)
		var pc := int(cp.get("gold_cost", -1))
		if pc > 0:
			var bb := UITheme.button("Buy %d" % pc, func(): ui.purchase(city_id, cp["kind"], cp["id"]), 14)
			bb.icon = UIKit.icon("gold")
			bb.add_theme_constant_override("icon_max_width", 16)
			var why := str(cp.get("reason", ""))
			bb.disabled = float(sim.state.gold) < pc or why != ""
			bb.tooltip_text = ("Finish the current build now with Gold" if why == "" else "Cannot buy: " + why)
			ph.add_child(bb)
		elif str(cp.get("reason", "")) != "":
			var nb := UITheme.label("(cannot be bought)", 13, UIKit.TEXT_DIM)
			nb.tooltip_text = str(cp["reason"])
			ph.add_child(nb)
	var auto := CheckBox.new()
	auto.text = "Automate"
	auto.focus_mode = Control.FOCUS_NONE
	auto.button_pressed = bool(c.get("automate", false))
	auto.tooltip_text = "The city chooses its own production (new and small towns start automated)."
	auto.toggled.connect(func(on): ui.set_automate(city_id, on))
	ph.add_child(auto)
	if not cur.is_empty():
		var pb := _bar(float(cur["progress"]) / maxf(1.0, float(cur["cost"])), UIKit.BLUE)
		body.add_child(pb)
	var q: Array = c.get("queue", [])
	if q.size() > 1:
		var names := []
		for i in range(1, q.size()):
			names.append(ui.item_name(q[i]["kind"], q[i]["id"]))
		var qh := HBoxContainer.new()
		var ql := UITheme.label("Queue: " + ", ".join(names), 15, UIKit.TEXT_DIM)
		ql.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		ql.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		qh.add_child(ql)
		qh.add_child(UITheme.button("Clear", func(): ui.clear_queue(city_id), 14))
		body.add_child(qh)
	var th := HBoxContainer.new()
	body.add_child(th)
	var tl := UITheme.label("Click: build now. Shift+click: queue. Hover: what it does.", 14, UIKit.TEXT_DIM)
	tl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	th.add_child(tl)
	var lk := CheckBox.new()
	lk.text = "Show locked"
	lk.focus_mode = Control.FOCUS_NONE
	lk.button_pressed = show_locked
	lk.toggled.connect(func(on): show_locked = on; refresh())
	th.add_child(lk)
	var list := scroll_body(240)
	var opts: Array = sim.get_buildable(city_id)
	var rec: Dictionary = SimAI.pick_production(sim, sim.city_by_id(city_id))
	for grp in [["district", "Districts"], ["building", "Buildings"], ["unit", "Units"], ["project", "National Projects"], ["city_project", "City Projects"]]:
		var rows := opts.filter(func(o): return o["kind"] == grp[0] and (o["available"] or show_locked))
		if rows.is_empty():
			continue
		rows.sort_custom(func(a, b): return (0 if a["available"] else 1) * 10000 + int(a["turns"]) < (0 if b["available"] else 1) * 10000 + int(b["turns"]))
		list.add_child(UITheme.section(grp[1]))
		for o in rows:
			list.add_child(_prod_row(o, cur, rec))


func _prod_row(o: Dictionary, cur: Dictionary, rec: Dictionary) -> UIRow:
	var is_cur: bool = not cur.is_empty() and cur["kind"] == o["kind"] and cur["id"] == o["id"]
	var r := UIRow.new(o["available"], is_cur)
	var h := r.hrow()
	h.add_child(UITheme.icon(_icon_for(o["kind"], o["id"]), 24))
	var nm := UITheme.label(str(o["name"]), 18, UIKit.TEXT if o["available"] else UIKit.TEXT_DIM, "body_bold")
	nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	h.add_child(nm)
	if not rec.is_empty() and rec.get("kind") == o["kind"] and rec.get("id") == o["id"] and o["available"] and UITheme.show_hints:
		h.add_child(UITheme.label("Recommended", 14, UIKit.GREEN, "body_bold"))
	if o["available"]:
		h.add_child(UITheme.label(UITheme.turns(int(o["turns"])), 17))
	if o["kind"] in ["building", "district", "unit", "project", "city_project"]:
		h.add_child(ui.pedia_button(o["kind"], o["id"]))
	var what := effect_text(o["kind"], o["id"], o)
	var ml := UITheme.label(what, 14, Color(0.80, 0.83, 0.90))
	ml.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	r.add(ml)
	r.tooltip_text = "%s\nCost %d production%s" % [what, int(o["cost"]), ("; %d stored" % int(o["progress"])) if float(o.get("progress", 0)) > 0 else ""]
	if not o["available"]:
		r.add(UITheme.label(str(o.get("reason", "")), 14, UIKit.BAD))
	if o["available"]:
		if o["kind"] == "district":
			# Civ VI: a district is placed on the map (the lens shows each valid tile's adjacency bonus)
			r.pressed.connect(func(shift): ui.begin_district_placement(city_id, o["id"], shift))
			r.tooltip_text += " Click to choose its tile on the map."
		else:
			r.pressed.connect(func(shift): ui.choose_production(city_id, o["kind"], o["id"], shift))
	return r


func _icon_for(kind: String, id: String) -> String:
	if kind == "district":
		return YIELD_ICON.get(str(ui.db().districts.get(id, {}).get("yield_type", "")), "cities")
	return KIND_ICON.get(kind, "production")


func effect_text(kind: String, id: String, o := {}) -> String:
	## What an item does, in one line (district adjacency included, like Civ VI's tooltips).
	var d: SimDB = ui.db()
	match kind:
		"district":
			var dd: Dictionary = d.districts.get(id, {})
			var parts := []
			if str(dd.get("yield_type", "")) != "":
				var adj := []
				for a in dd.get("adjacency", []):
					adj.append(_adj_text(a))
				parts.append("Yields %s" % str(dd["yield_type"]).capitalize() + ((" from adjacency (" + "; ".join(adj) + ")") if adj.size() > 0 else ""))
			var sites: Array = o.get("sites", [])
			if sites.size() > 0 and sites[0].has("adjacency") and float(sites[0]["adjacency"]) >= 0.05:
				parts.append("Best site here: %s" % UITheme.fmt_signed(float(sites[0]["adjacency"]), 0 if absf(float(sites[0]["adjacency"]) - roundf(float(sites[0]["adjacency"]))) < 0.05 else 1))
			if dd.get("specialist") != null and typeof(dd.get("specialist")) == TYPE_DICTIONARY:
				var sp := []
				for k in dd["specialist"]:
					sp.append("%s %s" % [UITheme.fmt_signed(float(dd["specialist"][k])), str(k).capitalize()])
				parts.append("Specialists: " + ", ".join(sp))
			if dd.has("housing") and float(dd["housing"]) > 0: parts.append("+%s Housing" % str(dd["housing"]))
			if dd.has("housing_by_appeal"): parts.append("Housing 2-6 by appeal")
			if dd.has("water_supply"): parts.append("+%d water supply" % int(dd["water_supply"]))
			if dd.has("trade_route"): parts.append("+1 export route")
			if dd.get("defense", false): parts.append("defends the city")
			var bl := []
			for b in dd.get("buildings", []):
				bl.append(ui.item_name("building", b))
			if bl.size() > 0:
				parts.append("Buildings: " + ", ".join(bl))
			return ". ".join(parts.map(func(x): return str(x).trim_suffix("."))) + ("." if parts.size() > 0 else "")
		_:
			return ui.item_detail(kind, id)


static func _adj_text(a: Dictionary) -> String:
	var amt := "+%s" % str(a.get("amount", 1))
	var per := (" per %d" % int(a["per"])) if a.has("per") else ""
	match str(a.get("src", "")):
		"district_any": return "%s%s districts" % [amt, per if per != "" else " per"]
		"district": return "%s per %s%s" % [amt, UITheme.pretty(str(a.get("id", ""))), per]
		"terrain", "feature", "improvement": return "%s per %s%s" % [amt, UITheme.pretty(str(a.get("id", ""))), per]
		"river": return "%s next to a river" % amt
		"city_center": return "%s next to the city centre" % amt
		"sea_resource": return "%s per sea resource" % amt
		"natural_wonder": return "%s per natural wonder" % amt
		"project": return "%s per national project" % amt
		"place_kind": return "%s per heritage or holy site" % amt
	return "%s %s" % [amt, str(a.get("src", ""))]


# ------------------------------------------------------------------ citizens tab (Civ VI "Manage Citizens")

func _tab_citizens(sim: Sim, c: Dictionary) -> void:
	var cz := SimAdapter.citizens(sim, city_id)
	var tiles: Array = cz.get("tiles", []).filter(func(t): return bool(t.get("workable", true)))
	var pop := int(c.get("pop", 0))
	var nw := tiles.filter(func(t): return bool(t["worked"]) or bool(t["locked"])).size()
	var nl := tiles.filter(func(t): return bool(t["locked"])).size()
	var spec := int(cz.get("specialists", c.get("info", {}).get("specialists", 0)))
	var head := HBoxContainer.new()
	body.add_child(head)
	var hl := UITheme.label("%d of %d citizens work tiles (%d locked)%s" % [mini(nw, pop), pop, nl, (", %d specialist%s" % [spec, "" if spec == 1 else "s"]) if spec > 0 else ""], 17, UIKit.GOLD_LIGHT, "body_bold")
	hl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(hl)
	if nl > 0:
		head.add_child(UITheme.button("Unlock all", func(): SimAdapter.clear_locks(sim, city_id); refresh(); ui._show_city_tiles(), 14))
	var note := "Click a tile (here or on the map) to lock a citizen on it: locked tiles are always worked, the others follow the city focus. Click again to unlock. Citizens without a tile take town jobs or specialist slots."
	if not bool(cz.get("live", false)):
		note += " [color=#ffb070]Locks are marked on the map; this build's economy does not apply them yet, so yields still follow the focus.[/color]"
	body.add_child(UITheme.rich("[color=#c8ccd6]%s[/color]" % note, 14))
	var list := scroll_body(300)
	tiles.sort_custom(func(a, b): return _tile_rank(a) > _tile_rank(b))
	for t in tiles:
		list.add_child(_citizen_row(t))


static func _tile_rank(t: Dictionary) -> float:
	var y: Dictionary = t.get("yields", {})
	var tot := 0.0
	for k in y:
		tot += float(y[k])
	return (2000.0 if bool(t.get("locked", false)) else 0.0) + (1000.0 if bool(t.get("worked", false)) else 0.0) + tot


func _citizen_row(t: Dictionary) -> UIRow:
	var locked := bool(t.get("locked", false))
	var worked := bool(t.get("worked", false)) or locked
	var r := UIRow.new(true, locked)
	var h := r.hrow()
	var tag := UITheme.label("LOCKED" if locked else ("WORKED" if worked else "free"), 12, Color(1.0, 0.82, 0.30) if locked else (Color(0.60, 0.85, 1.0) if worked else UIKit.TEXT_DIM), "title")
	tag.custom_minimum_size = Vector2(70, 0)
	h.add_child(tag)
	var parts := [UITheme.pretty(str(t.get("terrain", "")))]
	if str(t.get("feature", "")) not in ["", "none"]:
		parts.append(UITheme.pretty(str(t["feature"])))
	if str(t.get("improvement", "")) != "":
		parts.append(ui.item_name("improvement", str(t["improvement"])))
	var nm := UITheme.label(", ".join(parts), 16, UIKit.TEXT if worked else UIKit.TEXT_DIM, "body_bold")
	nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nm.clip_text = true
	h.add_child(nm)
	var y: Dictionary = t.get("yields", {})
	for k in ["food", "production", "gold", "science", "culture"]:
		var v := float(y.get(k, 0))
		if v < 0.05:
			continue
		h.add_child(UITheme.icon(k, 18))
		h.add_child(UITheme.label(str(snappedf(v, 0.1)).trim_suffix(".0"), 15))
	r.tooltip_text = "Click to %s a citizen on this tile." % ("unlock" if locked else "lock")
	var q := int(t["q"]); var rr := int(t["r"])
	r.pressed.connect(func(_s): ui.toggle_citizen(city_id, q, rr))
	return r


# ------------------------------------------------------------------ purchase tab

func _tab_purchase(sim: Sim, c: Dictionary) -> void:
	var gold := float(sim.state.gold)
	var coh := float(sim.state.cohesion)
	body.add_child(UITheme.label("Treasury %s Gold, %s Cohesion. Districts and projects cannot be bought." % [UITheme.fmt_num(gold), UITheme.fmt_num(coh)], 15, UIKit.GOLD))
	var list := scroll_body(300)
	var opts: Array = sim.get_buildable(city_id).filter(func(o): return o["available"] and (int(o.get("gold_cost", -1)) > 0 or int(o.get("cohesion_cost", -1)) > 0))
	var cur: Dictionary = c.get("producing", {})
	var cp: Dictionary = sim.current_purchase(city_id)
	if not cur.is_empty() and int(cp.get("gold_cost", -1)) > 0 and str(cp.get("reason", "")) == "":
		opts = opts.filter(func(o): return not (o["kind"] == cp["kind"] and o["id"] == cp["id"]))
		opts.push_front({"kind": cp["kind"], "id": cp["id"], "name": ui.item_name(cp["kind"], cp["id"]) + " (current build)", "turns": int(cur["turns"]),
			"gold_cost": int(cp["gold_cost"]), "cohesion_cost": int(cp.get("cohesion_cost", -1))})
	if opts.is_empty():
		list.add_child(UITheme.label("Nothing can be bought here right now.", 16, UIKit.TEXT_DIM))
	opts.sort_custom(func(a, b): return int(a["gold_cost"]) < int(b["gold_cost"]))
	for o in opts:
		var r := UIRow.new(true)
		var h := r.hrow()
		h.add_child(UITheme.icon(_icon_for(o["kind"], o["id"]), 22))
		var nm := UITheme.label(str(o["name"]), 17, UIKit.TEXT, "body_bold")
		nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		h.add_child(nm)
		var gc := int(o.get("gold_cost", -1))
		if gc > 0:
			var b := UITheme.button("%d Gold" % gc, func(): ui.purchase(city_id, o["kind"], o["id"]), 14)
			b.icon = UIKit.icon("gold"); b.add_theme_constant_override("icon_max_width", 16)
			b.disabled = gold < gc
			h.add_child(b)
		var cc := int(o.get("cohesion_cost", -1))
		if cc > 0:
			var b2 := UITheme.button("%d Cohesion" % cc, func(): ui.purchase(city_id, o["kind"], o["id"], "cohesion"), 14)
			b2.disabled = coh < cc
			h.add_child(b2)
		r.add(UITheme.label("%s   (%s to build normally)" % [effect_text(o["kind"], o["id"], o), UITheme.turns(int(o.get("turns", 0)))], 13, UIKit.TEXT_DIM))
		list.add_child(r)


# ------------------------------------------------------------------ details tab

func _tab_details(sim: Sim, c: Dictionary, cobj, gb: Dictionary) -> void:
	var list := scroll_body(300)
	var y: Dictionary = c.get("yields", {})
	var pop := int(c["pop"])
	var fb := CityMath.food(sim, cobj)
	var s := "[b][color=#f7dc8f]Food[/color][/b]\n"
	s += _line("Worked tiles (%d)" % int(fb["tiles_n"]), fb["tiles"])
	s += _line("Buildings, districts, specialists and other", fb["other"])
	s += _line("Total produced", float(y.get("food", 0)), true)
	s += _line("Eaten (2 per population)", -2.0 * pop)
	s += _line("Surplus", float(y.get("food", 0)) - 2.0 * pop, true)
	s += "[color=#a8b0c4]The country also needs %d food (2 per population) nationally; surplus speeds growth by up to 10%%.[/color]\n\n" % int(sim.national().get("food_need", 0))
	s += "[b][color=#f7dc8f]Growth (residents per quarter)[/color][/b]\n"
	s += "Natural increase %.1f%% a year in %d.\n" % [gb["nat"] * 100.0, sim.year()]
	s += _mult("Housing (%s housing for %s pop-equivalent)" % [str(snappedf(gb["housing"], 0.1)), str(snappedf(gb["pf"], 0.1))], gb["housing_f"])
	s += _mult("Amenities (%s)" % str(c["info"].get("amenity_state", "")), 1.0 + gb["amen_pct"] / 100.0)
	s += _mult("Civic Trust (%s)" %str(c["info"].get("trust_band", "")), 1.0 + gb["trust_pct"] / 100.0)
	if gb["bld_pct"] != 0:
		s += _mult("Buildings and policies", 1.0 + gb["bld_pct"] / 100.0)
	s += _mult("Food", gb["food_f"])
	if gb["damaged"]:
		s += _mult("Recently damaged", 0.5)
	s += "[b]= x%.2f  ->  %s residents this quarter[/b] (plus immigrants placed by the absorption system; %s received so far)\n" % [gb["mult"], UITheme.fmt_signed(gb["gain"]), UITheme.fmt_num(float(cobj.immigrants))]
	s += "[color=#a8b0c4]Housing: 2+ spare = full growth, 1 spare = 85%, short by up to 4 = 70%, worse = 50%. Residents beyond housing live in transit camps.[/color]\n\n"
	var hb := CityMath.housing(sim, cobj)
	s += "[b][color=#f7dc8f]Housing[/color][/b]\n"
	for k in hb:
		s += _line(k, hb[k])
	s += "\n[b][color=#f7dc8f]Amenities[/color][/b]\n"
	var ab := CityMath.amenities(sim, cobj)
	for k in ab["src"]:
		s += _line(k, ab["src"][k])
	s += _line("Required (1 per 2 population)", -float(c["info"].get("amen_required", 0)))
	s += _line("Balance", float(c["info"].get("amenity_balance", 0)), true)
	s += "Effects: %s%% yields, %s%% growth, %s trust per turn.\n\n" % [UITheme.fmt_signed(float(c["info"].get("amenity_yield_pct", 0))), UITheme.fmt_signed(float(c["info"].get("amenity_growth_pct", 0))), UITheme.fmt_signed(float(c["info"].get("amenity_trust", 0)))]
	s += "[b][color=#f7dc8f]Districts[/color][/b]\n"
	if (c.get("districts", {}) as Dictionary).is_empty():
		s += "none\n"
	for did in c.get("districts", {}):
		var k := int(c["districts"][did])
		var adj: float = sim.econ.adjacency(cobj, did, k)
		s += "[b]%s[/b] (adjacency %s): %s\n" % [Civilopedia.link("district", did, ui.item_name("district", did)), UITheme.fmt_signed(adj), effect_text("district", did)]
	s += "\n[b][color=#f7dc8f]Buildings[/color][/b]\n"
	if (c.get("buildings", []) as Array).is_empty():
		s += "none\n"
	for b in c.get("buildings", []):
		s += "[b]%s[/b]: %s\n" % [Civilopedia.link("building", b, ui.item_name("building", b)), ui.item_detail("building", b)]
	var rt := UITheme.rich(s, 15)
	rt.meta_clicked.connect(func(m): ui.on_pedia_meta(m))
	list.add_child(rt)


var _confirm_close := ""   # a building whose "Close for good" asked to be confirmed


func _tab_upkeep(sim) -> void:
	## The city's running costs and the building levers (fix3-econ): mothball (stops it, keeps 20% of its upkeep,
	## reopen later), close for good (no upkeep). Least-used buildings (least use per gold of upkeep) first.
	var list := scroll_body(300)
	var cu: Dictionary = sim.get_city_upkeep(city_id)
	var rows: Array = (cu.get("buildings", []) as Array).duplicate()
	rows.sort_custom(func(a, b): return float(a.get("value", 0)) / maxf(0.1, float(a.get("upkeep", 1))) < float(b.get("value", 0)) / maxf(0.1, float(b.get("upkeep", 1))))
	var head := "[b][color=#f7dc8f]Running costs here: %s Gold a quarter[/color][/b]" % str(snappedf(float(cu.get("total", 0)), 0.1))
	if sim.has_method("get_fiscal_report"):
		var fr: Dictionary = sim.get_fiscal_report()
		var ratio := float(fr.get("ratio", 0))
		head += "\n[color=%s]The state's running costs and debt service take %d%% of its revenue%s.[/color]" % ["#ff8f7a" if bool(fr.get("alarm", false)) else "#a8b0c4", int(round(ratio * 100.0)), ": a structural deficit" if bool(fr.get("alarm", false)) else ""]
	head += "\n[color=#a8b0c4]Mothball: the building stops working and keeps a fifth of its upkeep; reopen it later. Close: no upkeep, for good. A building that serves residents (amenities, housing, trust) costs this city some Civic Trust when stopped.[/color]"
	list.add_child(UITheme.rich(head, 15))
	if rows.is_empty():
		list.add_child(UITheme.label("No building here has upkeep.", 15, UIKit.TEXT_DIM))
	for r in rows:
		var bid := str(r.get("id", ""))
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 6)
		var use := float(r.get("value", 0)) / maxf(0.1, float(r.get("upkeep", 1)))
		var nm := UITheme.rich("[b]%s[/b]  [color=#a8b0c4]%s Gold a quarter%s%s[/color]" % [ui.item_name("building", bid), str(snappedf(float(r.get("upkeep", 0)), 0.1)),
			", little used" if use < 1.0 else "", ", serves residents" if bool(r.get("service", false)) else ""], 15)
		nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nm.tooltip_text = ui.item_detail("building", bid)
		h.add_child(nm)
		h.add_child(UITheme.button("Mothball", func(): ui.fiscal_building("mothball", city_id, bid), 14))
		var ck := "b:" + bid
		h.add_child(UITheme.button("Confirm close" if _confirm_close == ck else "Close", func():
			if _confirm_close != ck:
				_confirm_close = ck
				refresh()
			else:
				_confirm_close = ""
				ui.fiscal_building("close", city_id, bid), 14))
		list.add_child(h)
	var mb: Array = cu.get("mothballed", [])
	if not mb.is_empty():
		list.add_child(UITheme.title("MOTHBALLED", 15, UIKit.GOLD))
		for m in mb:
			var bid2 := str(m.get("id", ""))
			var h2 := HBoxContainer.new()
			h2.add_theme_constant_override("separation", 6)
			var nl := UITheme.label(ui.item_name("building", bid2), 15, UIKit.TEXT_DIM)
			nl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			h2.add_child(nl)
			h2.add_child(UITheme.button("Reopen (%d Gold)" % int(m.get("reopen_cost", 0)), func(): ui.fiscal_building("reopen", city_id, bid2), 14))
			var ck2 := "m:" + bid2
			h2.add_child(UITheme.button("Confirm close" if _confirm_close == ck2 else "Close", func():
				if _confirm_close != ck2:
					_confirm_close = ck2
					refresh()
				else:
					_confirm_close = ""
					ui.fiscal_building("close", city_id, bid2), 14))
			list.add_child(h2)
	if FiscalPanel.available(sim):
		list.add_child(UITheme.button("The state's running costs and all fiscal levers", func(): ui.open_fiscal(), 15))


static func _line(k: String, v: float, bold := false) -> String:
	var col := "#9fe07a" if v > 0.001 else ("#ff8f7a" if v < -0.001 else "#c8ccd6")
	var t := "%s  [color=%s]%s[/color]\n" % [k, col, UITheme.fmt_signed(v, 1)]
	return ("[b]%s[/b]" % t.strip_edges()) + "\n" if bold else t


static func _mult(k: String, f: float) -> String:
	var col := "#9fe07a" if f > 1.001 else ("#ff8f7a" if f < 0.999 else "#c8ccd6")
	return "%s  [color=%s]x%.2f[/color]\n" % [k, col, f]


# ------------------------------------------------------------------ helpers

func _bar(frac: float, col: Color) -> ProgressBar:
	var pb := ProgressBar.new()
	pb.show_percentage = false
	pb.custom_minimum_size = Vector2(0, 6)
	pb.max_value = 1.0
	pb.value = clampf(frac, 0, 1)
	var fill := StyleBoxFlat.new(); fill.bg_color = col
	var bg := StyleBoxFlat.new(); bg.bg_color = Color(0, 0.02, 0.06, 0.9)
	pb.add_theme_stylebox_override("fill", fill); pb.add_theme_stylebox_override("background", bg)
	return pb


func _find_scroll() -> ScrollContainer:
	for ch in body.get_children():
		if ch is ScrollContainer:
			return ch
	return null


func _fact(g: GridContainer, k: String, v: String, tip := "") -> void:
	var kl := UITheme.label(k, 15, UIKit.TEXT_DIM)
	var l := UITheme.label(v, 16, UIKit.TEXT, "body_bold")
	if tip != "":
		kl.tooltip_text = tip; l.tooltip_text = tip
		kl.mouse_filter = Control.MOUSE_FILTER_PASS; l.mouse_filter = Control.MOUSE_FILTER_PASS
	g.add_child(kl)
	g.add_child(l)
