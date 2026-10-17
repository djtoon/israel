class_name SimAI
extends RefCounted
## Two autoplayers that use only the public Sim API (the same calls the UI makes):
##  - "historical": the Historical Israel ghost. Researches and adopts on the real dates, makes the
##    historical event choices, builds national projects in their real year, never founds towns early.
##  - "player": a simple optimising policy used by sim_test to play the whole game.
## Also provides recommendations ("Recommended" badges) for the UI via pick_* functions.

const DISTRICT_ORDER := ["university", "business_district", "industrial_park", "port", "tech_park", "cultural_center", "recreation_complex",
	"housing_project", "water_connection", "desalination_plant", "idf_base", "airport", "government_complex", "space_defense_rnd"]


static func historical(sim) -> bool:
	## The ghost (mode "historical") and player-mode runs set to make every historical pick (ai_style "historical").
	return sim.state.mode == "historical" or str(sim.state.counters.get("ai_style", "")) == "historical"


# ------------------------------------------------------------------ whole turn

static func play_turn(sim) -> bool:
	if style(sim).begins_with("ruin_"):
		_ruin_turn(sim)   # sim_test's collapse report: deliberately ruinous drivers (fix-v3a)
	_units(sim)
	_trade_and_diplomacy(sim)
	_ministries(sim)
	_resolve(sim)
	_start_projects(sim)
	if str(strategy(sim).get("group", "")) == "society":
		_replan_city_projects(sim)   # fix4-econ: the society strategist's cities do not repeat a fallback project for ever (housing first)
	_maybe_reslot(sim)
	_programmes(sim)
	_fiscal_levers(sim)   # v3 fix3-econ: mothball, privatise, stabilise when the structural deficit is reported
	_history_bonds(sim)
	_purchases(sim)
	_units(sim)
	_resolve(sim)
	for d in sim.blocking_decisions():
		if d["type"] == "unit_orders":
			var uu = sim.unit_by_id(int(d["unit"]))
			if uu != null: uu.orders = "sleep"
	if not sim.end_turn():
		sim.log_error("AI could not resolve: " + str(sim.next_action()))
		return sim.end_turn(true)
	return true


static func style(sim) -> String:
	## "historical" (the ghost), "recommended" (default player AI) or "varied" (deliberately non-historical, for divergence tests)
	if historical(sim):
		return "historical"
	return str(sim.state.counters.get("ai_style", "recommended"))


# v3 (sim-endgame): four strategists, one per ending ("strategist_security" | "_prosperity" | "_peace" | "_society").
# Track weights shape fork, event and programme picks; each has a State Budget emphasis, an immigration pattern and a
# programme group it invests in first. Used by sim_test's strategy report (no single dominant strategy).
const STRATEGIES := {
	"security": {"group": "security", "budget": "defence", "imm": "", "weights": {"readiness": 2.2, "standing": 1.3, "economy": 0.8, "science": 1.1, "water": 0.8, "cohesion": 0.9, "population": 0.8}},
	"prosperity": {"group": "prosperity", "budget": "education", "imm": "cities", "weights": {"economy": 2.2, "science": 1.8, "water": 1.1, "standing": 0.8, "cohesion": 0.7, "population": 0.9, "readiness": 0.6}},
	"peace": {"group": "peace", "budget": "development", "imm": "", "weights": {"standing": 2.4, "economy": 1.0, "water": 1.1, "cohesion": 1.0, "science": 0.8, "population": 0.8, "readiness": 0.6}},
	"society": {"group": "society", "budget": "absorption", "imm": "", "weights": {"cohesion": 2.4, "population": 1.3, "standing": 0.9, "economy": 1.0, "science": 0.8, "water": 0.9, "readiness": 0.6}},
}


static func strategy(sim) -> Dictionary:
	var s := style(sim)
	if s.begins_with("strategist_"):
		return STRATEGIES.get(s.substr(11), {})
	return {}


static func _track_w(sim, track: String) -> float:
	var st := strategy(sim)
	if st.is_empty():
		return 1.0
	return float(st["weights"].get(track, 1.0))


static func pick_programme(sim, d: Dictionary) -> int:
	## The programme decision: history launches its historical levels on their dates (else defers); a strategist takes
	## the option in its group (or the best affordable); varied prefers what history did not do; otherwise Recommended.
	var opts: Array = d.get("options", [])
	if opts.is_empty():
		return -1
	var hold := opts.size() - 1
	for i in range(opts.size()):
		if str(opts[i]["id"]) in ["defer", "hold"]: hold = i
	var st := style(sim)
	if st == "historical":
		for i in range(opts.size()):
			var o: Dictionary = opts[i]
			if str(o["id"]).begins_with("launch:") and o.get("historical", false) and sim.year() >= int(str(o.get("hist_label", "9999"))):
				return i
		return hold
	var sg := strategy(sim)
	if not sg.is_empty() or st == "varied":
		var best := -1; var bv := -1e9
		for i in range(opts.size()):
			var o2: Dictionary = opts[i]
			var oid := str(o2["id"])
			if not (oid.begins_with("launch:") or oid.begins_with("expand:")) or not o2.get("available", true):
				continue
			if sim.state.gold - float(o2.get("instalment", 0.0)) * 2.0 < sim.endgame.reserve() * 0.6:
				continue
			var v := float(o2.get("value", 0.0))
			var pid: String = oid.split(":")[1]
			if not sg.is_empty() and str(sg["group"]) in SimEndgame.programme_def(pid).get("groups", []): v += 6.0
			if st == "varied" and not o2.get("historical", false): v += 4.0
			if v > bv:
				bv = v; best = i
		if best >= 0 and not sg.is_empty() and str(opts[best]["id"]).begins_with("expand:") \
				and not (str(sg["group"]) in SimEndgame.programme_def(str(opts[best]["id"]).split(":")[1]).get("groups", [])):
			return hold   # a strategist keeps the surplus for its own group's programmes (funded from the Programmes panel)
		if best >= 0:
			return best
	for i in range(opts.size()):
		if opts[i].get("default", false): return i
	return hold


static func _programmes(sim) -> void:
	## Varied and strategist styles also fund programmes directly from the Programmes panel (sim.fund_programme /
	## expand_programme), one a quarter, when the treasury is above the reserve.
	var st := style(sim)
	var sg := strategy(sim)
	if (sg.is_empty() and st != "varied") or sim.state.mode == "historical":
		return
	var w := {}
	for t in SimEndgame.TRACKS:
		w[t] = _track_w(sim, t)
	w["readiness"] = _track_w(sim, "readiness")
	var rsv: float = sim.endgame.reserve()
	var best = null; var bv := -1e9
	for c in sim.endgame.candidates(w):
		if sim.state.gold - float(c["instalment"]) < 0.5 * rsv:   # one instalment in hand (the strategist banks its surplus)
			continue
		var v := float(c["value_per_gold"])
		if not sg.is_empty():
			if str(sg["group"]) in c["groups"]: v *= 2.5
			elif c["kind"] == "expand": continue   # a strategist expands only its own group's programmes
		if st == "varied" and not c["historical"]: v *= 1.6
		if v > bv:
			bv = v; best = c
	if best != null:
		if best["kind"] == "launch": sim.fund_programme(str(best["programme"]))
		else: sim.expand_programme(str(best["programme"]))


static func _resolve(sim) -> void:
	for i in range(80):
		var d: Dictionary = sim.next_action()
		if str(d["type"]) == "end_turn":
			break
		if sim.has_meta("decision_log"):
			sim.get_meta("decision_log").append([sim.state.turn, str(d["type"]), _rec_key(d)])
		if not resolve_one(sim, d):
			break
	for s in sim.state.policies:
		if s["id"] == "__none":
			s["id"] = ""


static func _rec_key(d: Dictionary) -> String:
	## The Recommended option of a decision as a short key (for the pick-share report in sim_test).
	var opts: Array = d.get("options", d.get("choices", []))
	var keys := []
	for o in opts:
		if typeof(o) == TYPE_DICTIONARY and o.get("default", false):
			keys.append(str(o.get("id", o.get("label", ""))))
	if str(d.get("type", "")) == "agenda":
		return str(d.get("label", "")).replace("CABINET AGENDA: ", "").split(" in ")[0].split(" at ")[0] + " -> " + ",".join(keys)
	return ",".join(keys)


static func pick_fork(sim, d: Dictionary) -> String:
	var opts: Array = d.get("options", [])
	if opts.is_empty():
		return ""
	var st := style(sim)
	if st == "historical":
		for o in opts:
			if o.get("historical", false): return str(o["id"])
	# recommended: the option whose lasting terms add the most across the six tracks;
	# varied (v3 fix3-econ, A7): a non-historical option, taken without weighing its terms (a cabinet that answers
	# differently from history on principle, as the full-game critic's run did), so choices visibly change the outcome
	var f = sim.db.forks.get(str(d.get("fork", "")))
	var best := str(opts[0]["id"]); var bv := -1e9
	if st == "varied" and f != null:
		var nh: Array = f["options"].filter(func(o): return not o.get("historical", false))
		if not nh.is_empty():
			return str(nh[absi(hash(str(d.get("fork", "")) + str(sim.state.rng_seed))) % nh.size()]["id"])
	if f != null:
		for o in f["options"]:
			if st == "varied" and o.get("historical", false):
				continue
			var v := 0.0
			for s in o.get("lasting", []):
				var t := str(s.get("type", ""))
				var val := float(s.get("amount", 0)) / float(SimDB.TERM_TYPICAL.get(t, 1.0))
				if t == "inflation": val = -val
				if t == "immigrant_weight": val = 0.0
				var yrs := maxf(0.25, float(SimDB.turn_of(s.get("until"), 0) - SimDB.turn_of(s.get("from"), 0) + 1) / 4.0)
				v += val * clampf(yrs / 8.0, 0.25, 3.0) * _track_w(sim, str(SimDB.TERM_TRACK.get(t, "economy")).replace("_neg", ""))
			if o.get("historical", false) and st != "varied": v += 0.3
			if v > bv:
				bv = v; best = str(o["id"])
	return best


static func resolve_one(sim, d: Dictionary) -> bool:
	## Resolves one decision with this AI's pick. Returns false if it could not (the caller stops looping).
	if style(sim).begins_with("ruin_"):
		var rr := _ruin_resolve(sim, d)
		if rr >= 0:
			return rr == 1
	match str(d.get("type", "")):
			"fork":
				return sim.choose_fork(str(d["fork"]), pick_fork(sim, d))
			"event_choice":
				var ev = sim.db.event_by_id.get(d["event"])
				return sim.choose_event(d["event"], pick_event_choice(sim, ev))
			"crisis_response":
				return sim.choose_crisis_response(pick_crisis_response(sim, d["options"]))
			"dedication":
				return sim.choose_dedication(pick_dedication(sim))
			"fill_policy":
				if not fill_policies(sim):
					sim.state.policies[int(d["slot"])]["id"] = "__none"
				return true
			"choose_research":
				var t := pick_research(sim)
				return t != "" and sim.set_research(t)
			"choose_civic":
				var c := pick_civic(sim)
				return c != "" and sim.set_civic(c)
			"choose_production":
				var city = sim.city_by_id(int(d["city"]))
				if city == null: return false
				var p := pick_production(sim, city)
				if p.is_empty() or not sim.set_production(city.id, p["kind"], p["id"], int(p.get("tile", -1))):
					city.queue.append({"kind": "city_project", "id": "infrastructure_bonds", "tile": -1})
				return true
			"unit_orders":
				var u = sim.unit_by_id(int(d["unit"]))
				if u != null:
					u.orders = "skip" if sim.military.is_military(u) else "sleep"
				return true
			"agenda":
				return sim.choose_agenda(pick_agenda(sim))
			"immigration":
				var io := pick_immigration(sim)
				var allowed: Array = sim.econ.immigration_options_allowed()
				if not (io in allowed) and not allowed.is_empty():
					io = str(allowed[0])
				return sim.choose_immigration(io)
			"policy_review":
				var props: Array = d.get("proposals", sim.policy_proposals())
				return sim.choose_policy_proposal(0) if not props.is_empty() else sim.confirm_policies()
			"state_budget":
				var presets: Array = sim.cabinet.budget_presets().map(func(p): return {"id": p["id"], "default": str(p["id"]) == sim.cabinet.recommended_preset()})
				var sgb := strategy(sim)
				if not sgb.is_empty() and sim.cabinet.recommended_preset() != "war" and SimDB.year_of(sim.state.turn) % 5 < 3:
					for i in range(presets.size()):
						if str(presets[i]["id"]) == str(sgb["budget"]): return sim.choose_state_budget(i)
				return sim.choose_state_budget(pick_option(sim, presets, false, ["absorption", "development"]))
			"programme":
				if sim.choose_programme(pick_programme(sim, d)):
					return true
				# the treasury moved since the quarter began (e.g. a deal paid first): hold / defer instead
				for i in range(d.get("options", []).size()):
					if str(d["options"][i]["id"]) in ["hold", "defer"] and sim.choose_programme(i): return true
				return false
			"budget_review":
				return sim.choose_budget_review(pick_option(sim, sim.cabinet.review_options(), false, ["supplement", "keep"]))
			"minister":
				# one cabinet screen: every waiting title in one multi-pick (fix-cabinet)
				var mo: Array = sim.cabinet.minister_options()
				var n := int(d.get("picks", sim.cabinet.titles()))
				if style(sim) == "varied":
					# the varied cabinet builds people first: housing, health, absorption and trust programmes
					var scored := []
					for i in range(mo.size()):
						var v := float(mo[i].get("value", 0.0))
						for l in mo[i].get("effects", []):
							if str(l.get("stat", "")) in ["population", "housing", "trust", "amenity"]: v += 6.0
						scored.append({"id": mo[i]["id"], "minister": mo[i]["minister"], "value": v})
					scored.sort_custom(func(a, b): return float(a["value"]) > float(b["value"]))
					return sim.choose_ministers(sim.cabinet.recommended_set(scored, n))
				return sim.choose_ministers(mo.filter(func(o): return o.get("default", false)).map(func(o): return str(o["id"])))
			"coalition":
				var co: Array = sim.cabinet.coalition_options()
				if style(sim) == "varied":
					# the varied cabinet courts the party that stayed out (or the second partner)
					for i in range(co.size()):
						if not co[i].get("historical", false): return sim.choose_coalition(i)
				return sim.choose_coalition(pick_option(sim, co, true))
			"diplomacy":
				# v3 (sim-diplomacy): the envoy decision; SimDiplomacy scores the options for this AI style
				return sim.choose_diplomacy(sim.diplo.ai_pick(style(sim)))
			"treasury", "brief":
				# v4 (v4-sim-auto): the casual layer's own player-facing items (never in a v3 game)
				return sim.auto != null and sim.auto.resolve_pseudo(d)
	return false


static func pick_option(sim, opts: Array, varied_second := false, varied_pref := []) -> int:
	## Recommended pick for the v2 cabinet decisions: the option marked default. The "varied" divergence style
	## deliberately takes another one (rotating through them), like a competent but different cabinet.
	if opts.is_empty():
		return -1
	var rec := 0
	for i in range(opts.size()):
		if opts[i].get("default", false): rec = i
	if style(sim) == "varied" and opts.size() > 1:
		# a consistent different strategy (absorption-first budgets, supplements, religious partners), not noise
		for want in varied_pref:
			for i in range(opts.size()):
				if str(opts[i].get("id", "")) == str(want) and i != rec:
					return i
		if varied_second:
			return 1 if rec == 0 else 0
		return (rec + 1 + sim.state.turn % (opts.size() - 1)) % opts.size()
	return rec


# ------------------------------------------------------------------ research and civics

static func pick_research(sim) -> String:
	var best := ""; var bs := -1e9
	var y: float = SimDB.year_f(sim.state.turn)
	for t in sim.db.tech_list:
		if sim.tech_available(t["id"]) != "":
			continue
		var s := 0.0
		var ty = SimDB.hist_year(t)   # v3 fix3-story A11: includes a year after the game's end (hidden from the UI)
		if historical(sim):
			if t.get("repeatable", false):
				s = -1.0e8   # history never "researches a programme" while a real technology is open
			elif ty == null:
				s = -500.0
			else:
				s = -float(ty) * 10.0 - (1000.0 if float(ty) > y + 0.5 else 0.0)
		else:
			var cost: float = sim.tech_cost(t["id"])
			var prog := float(sim.state.tech_progress.get(t["id"], 0.0))
			s = -(cost - prog) / 100.0
			if sim.state.boosts.has("tech:" + t["id"]): s += 4.0
			if ty != null: s -= maxf(0.0, float(ty) - y) * 0.6
			if t["id"] in ["groundwater_drilling", "prefab_housing", "national_water_carrier", "desalination", "drip_irrigation", "chip_design", "electronic_computing", "venture_capital", "wastewater_reuse"]:
				s += 3.0
			if ty == null: s -= 3.0
			if t.get("repeatable", false): s = -1.0e8   # only when nothing else is open
			# don't sink science into an item that cannot be completed yet
			var ec: float = sim.earliest_completion(t)
			if ec > 0.0 and prog >= cost - 1.0 and y < ec: s -= 1000.0
			elif ec > y + 2.0: s -= (ec - y) * 1.5
		if s > bs:
			bs = s; best = t["id"]
	return best


static func pick_civic(sim) -> String:
	var best := ""; var bs := -1e9
	var y: float = SimDB.year_f(sim.state.turn)
	for c in sim.db.civic_list:
		if sim.civic_available(c["id"]) != "":
			continue
		var cy := float(c["year"]) if c.get("year") != null else 2100.0
		var s := -cy
		if historical(sim) and cy > y + 0.5:
			s -= 1000.0
		if not historical(sim):
			s = -(sim.civic_cost(c["id"]) - float(sim.state.civic_progress.get(c["id"], 0.0))) / 100.0 - maxf(0.0, cy - y) * 0.5
			if sim.state.boosts.has("civic:" + c["id"]): s += 4.0
		if c.get("repeatable", false): s = -1.0e8   # only when nothing else is open
		if s > bs:
			bs = s; best = c["id"]
	return best


# ------------------------------------------------------------------ production

static func _avail(opts: Array, kind: String, id: String) -> Variant:
	for o in opts:
		if o["kind"] == kind and o["id"] == id and o["available"]:
			return o
	return null


static func pick_production(sim, c) -> Dictionary:
	if c == null:
		return {}
	var opts: Array = sim.buildable(c)
	var info: Dictionary = c.info
	var P: int = c.pop()
	var hist := historical(sim)
	var housing_gap := float(info.get("housing", P)) - sqrt(c.residents / 1000.0)
	# national projects: planned nationally (best-placed city for each), see plan_projects()
	var plan := plan_projects(sim)
	if plan.has(c.id):
		var po = _avail(opts, "project", str(plan[c.id]))
		if po != null: return _sel(po)
	var ts := float(info.get("transit_share", 0.0))
	# 1. housing pressure (real overcrowding; mild shortfalls wait for districts and buildings below)
	var ts_lim := 0.01 if str(strategy(sim).get("group", "")) == "society" else 0.03   # fix4-econ: the society strategist houses the last transit residents too
	if ts > ts_lim or housing_gap < 0.0 or (housing_gap < 1.0 and P < 8):
		for id in ["shikun_blocks", "food_depot", "water_tower", "sewage_plant", "absorption_center"]:
			var o = _avail(opts, "building", id)
			if o != null: return _sel(o)
		var hp = _avail(opts, "district", "housing_project")
		if hp != null: return _sel(hp, hp["sites"])
		var wc = _avail(opts, "district", "water_connection")
		if wc != null: return _sel(wc, wc["sites"])
		if ts > 0.08 and (hist or sim.state.era <= 2):
			var m = _avail(opts, "building", "maabara")
			if m != null: return _sel(m)
	# 2. amenities
	if float(info.get("amenity_balance", 0)) < 0:
		for id in ["clinic", "community_center", "solar_heaters", "hospital", "shopping_mall", "sports_arena", "zoo", "stadium"]:
			var o2 = _avail(opts, "building", id)
			if o2 != null: return _sel(o2)
		var rc = _avail(opts, "district", "recreation_complex")
		if rc != null and P >= 6: return _sel(rc, rc["sites"])
	# 3. military during a crisis or when readiness is low
	var mil_n := 0
	for u in sim.state.units:
		if u.owner == "player" and sim.military.is_military(u): mil_n += 1
	var def_n := 0
	for u in sim.state.units:
		if u.owner == "player" and str(sim.db.units.get(u.type, {}).get("cls", "")) == "defense": def_n += 1
	if P >= 10 and def_n < 2 + sim.state.era / 3:
		for id in ["laser_defense_battery", "iron_dome_battery", "air_defense_battery"]:
			var ad = _avail(opts, "unit", id)
			if ad != null: return _sel(ad)
	if (sim.state.crises.size() > 0 and P >= 8 and mil_n < 6 + sim.active_cities().size() / 6) or (sim.state.readiness < 30 and P >= 10 and mil_n < 10):
		var bu = _best_unit(opts)
		if bu != null: return _sel(bu)
	# 5. water infrastructure
	if float(sim.state.water.get("ratio", 1.0)) < 1.05 and P >= 5:
		for id in ["water_tower", "reclamation_plant", "desal_expansion"]:
			var o3 = _avail(opts, "building", id)
			if o3 != null: return _sel(o3)
		for did in ["desalination_plant", "water_connection"]:
			var dd = _avail(opts, "district", did)
			if dd != null: return _sel(dd, dd["sites"])
	# 6. settlers (player mode only: history founds towns itself)
	if not hist and c.residents > 15000 and not c.automate:   # automated towns never raise settlement groups
		var sett = _avail(opts, "unit", "settler")
		var alive := 0
		for u in sim.state.units:
			if u.owner == "player" and u.type == "settler": alive += 1
		if sett != null and alive < 2 and sim.settle_targets().size() > alive:
			return _sel(sett)
	# 7. builders
	var builders := 0
	for u in sim.state.units:
		if u.owner == "player" and u.type == "builder": builders += 1
	var need_b := maxi(2, sim.active_cities().size() / (8 if hist else 5))
	if builders < need_b and P >= 3:
		var b = _avail(opts, "unit", "builder")
		if b != null: return _sel(b)
	# 8. districts by priority and adjacency
	var stress := fiscal_stress(sim)   # v3 fix3-econ: no new upkeep while running costs exceed revenue
	var best_d = null; var bds := -1e9
	for i in range(DISTRICT_ORDER.size()):
		var did: String = DISTRICT_ORDER[i]
		if stress and not (did in ["business_district", "port"]): continue
		var o4 = _avail(opts, "district", did)
		if o4 == null or o4["sites"].is_empty():
			continue
		if did == "housing_project" and housing_gap > 3.0: continue
		if did == "water_connection" and housing_gap > 2.0: continue
		if did == "desalination_plant" and float(sim.state.water.get("ratio", 1.0)) > 1.1: continue
		if did == "idf_base" and _count_district(sim, "idf_base") >= 1 + sim.active_cities().size() / 15: continue
		if did == "airport" and _count_district(sim, "airport") >= 3: continue
		if did == "recreation_complex" and P < 8: continue
		if did == "space_defense_rnd" and _count_district(sim, did) >= 1: continue
		var s: float = 10.0 - i + float(o4["sites"][0]["adjacency"]) * 2.0 - float(o4["turns"]) * 0.15
		if hist: s -= i * 0.5
		if s > bds:
			bds = s; best_d = o4
	if best_d != null and (P >= 3 or best_d["id"] in ["port"]):
		return _sel(best_d, best_d["sites"])
	# 9. buildings in districts (cheapest useful first)
	var best_b = null; var bbs := -1e9
	for o5 in opts:
		if o5["kind"] != "building" or not o5["available"] or o5["id"] in ["maabara", "fortifications"]:
			continue
		var bd: Dictionary = sim.db.buildings[o5["id"]]
		if stress and float(bd.get("upkeep", 0)) > float(bd.get("yields", {}).get("gold", 0)):
			continue
		var val := 0.0
		for k in bd.get("yields", {}): val += float(bd["yields"][k])
		val += float(bd.get("housing", 0)) * 1.5 + float(bd.get("amenities", 0)) * 2.0 + float(bd.get("water_supply", 0)) * 0.1
		var s2: float = val / maxf(1.0, float(o5["cost"])) * 100.0 - float(o5["turns"]) * 0.1
		if s2 > bbs:
			bbs = s2; best_b = o5
	if best_b != null and bbs > 0.5:
		return _sel(best_b)
	# 10. fallback projects
	for id in (["infrastructure_bonds", "research_grants", "cultural_festival"] if stress else ["research_grants", "cultural_festival", "infrastructure_bonds"]):
		var o6 = _avail(opts, "city_project", id)
		if o6 != null: return _sel(o6)
	return {}


# ------------------------------------------------------------------ national projects

const PROJECT_MAX_TURNS := 30     # the player AI starts a project when its best city can finish it in time
const PROJECT_CONCURRENT := 2     # national projects under way at once (player AI)


static func plan_projects(sim) -> Dictionary:
	## {city_id: project_id}: which national projects to build now and where. Each project goes to the
	## eligible city that finishes it soonest; projects already under way stay where they are.
	## Cached per turn. Also drives the "Recommended" badge for projects in the production panel.
	var key := "ai_project_plan"
	if sim.has_meta(key):
		var cached: Dictionary = sim.get_meta(key)
		if int(cached.get("turn", -1)) == sim.state.turn and int(cached.get("built", -1)) == sim.state.projects.size():
			return cached["plan"]
	var hist := historical(sim)
	var plan := {}
	var running := 0
	var cands := []
	for pid in sim.db.projects:
		if sim.state.projects.has(pid): continue
		var where := -1
		for c in sim.active_cities():
			if sim._queued(c, "project", pid): where = c.id
		if where >= 0:
			plan[where] = pid
			running += 1
			continue
		var p: Dictionary = sim.db.projects[pid]
		var py = p.get("year")
		if hist and (py == null or sim.year() < int(py) - 1): continue
		var best = null; var bt := 1 << 30
		for c in sim.active_cities():
			var o: Array = sim.buildable(c, "project", pid)
			if o.is_empty() or not o[0]["available"]: continue
			if int(o[0]["turns"]) < bt:
				bt = int(o[0]["turns"]); best = c
		if best == null: continue
		if not hist and bt > PROJECT_MAX_TURNS: continue
		cands.append({"pid": pid, "city": best.id, "turns": bt, "value": _project_value(sim, p, bt)})
	cands.sort_custom(func(a, b): return a["value"] > b["value"])
	for cd in cands:
		if plan.has(cd["city"]): continue
		if not hist and running >= PROJECT_CONCURRENT: break
		plan[cd["city"]] = cd["pid"]
		running += 1
	sim.set_meta(key, {"turn": sim.state.turn, "built": sim.state.projects.size(), "plan": plan})
	return plan


static func _project_value(sim, p: Dictionary, turns: int) -> float:
	var v := 10.0 - float(turns) * 0.2
	var ratio := float(sim.state.water.get("ratio", 1.0))
	for e in p.get("effects", []):
		match str(e.get("type", "")):
			"water_supply": v += 6.0 + (10.0 if ratio < 1.15 else 0.0)
			"gold_per_turn", "trade_route_capacity": v += 5.0
			"policy_slot", "yield_pct": v += 6.0
			"readiness": v += 4.0 + (6.0 if sim.state.readiness < 50 else 0.0)
			"trust_national", "amenity_national": v += 4.0
			_: v += 2.0
	return v


static func _start_projects(sim) -> void:
	## Switch the planned city to its project now (progress on the interrupted item is kept).
	var plan := plan_projects(sim)
	for cid in plan:
		var c = sim.city_by_id(int(cid))
		if c == null or sim._queued(c, "project", str(plan[cid])): continue
		if not c.queue.is_empty() and str(c.queue[0]["kind"]) == "project": continue
		var old = null if c.queue.is_empty() else c.queue[0]
		if sim.set_production(c.id, "project", str(plan[cid]), -1) and old != null:
			c.queue.insert(1, old)


static func _sel(o: Dictionary, sites := []) -> Dictionary:
	var d := {"kind": o["kind"], "id": o["id"], "tile": -1}
	if sites.size() > 0:
		d["tile"] = SimHex.key(int(sites[0]["q"]), int(sites[0]["r"]))
	return d


static func _best_unit(opts: Array) -> Variant:
	var best = null; var bs := -1.0
	for o in opts:
		if o["kind"] == "unit" and o["available"] and not (o["id"] in ["settler", "builder"]):
			var s := float(o["cost"])
			if s > bs:
				bs = s; best = o
	return best


static func _count_district(sim, did: String) -> int:
	var n := 0
	for c in sim.active_cities():
		if c.has_district(did): n += 1
	return n


# ------------------------------------------------------------------ choices

static func pick_event_choice(sim, ev) -> int:
	if ev == null:
		return 0
	if historical(sim):
		return sim.events.historical_choice(ev)
	var varied: bool = style(sim) == "varied" and ev.get("choices", []).size() > 1
	var hc: int = sim.events.historical_choice(ev)
	if varied:   # v3 fix3-econ (A7): a choice history did not make, not weighed (see pick_fork)
		var others := []
		for j in range(ev.get("choices", []).size()):
			if j != hc: others.append(j)
		return int(others[absi(hash(str(ev.get("id", "")) + str(sim.state.rng_seed))) % others.size()])
	var best := 0 if hc != 0 or not varied else 1; var bs := -1e9
	var i := 0
	for ch in ev.get("choices", []):
		var e: Dictionary = ch.get("effects", {})
		if varied and i == hc:
			i += 1
			continue
		var s := _terms_value(sim, ev, i) + 3.0 * float(e.get("morale", 0)) * _track_w(sim, "cohesion") + 2.0 * float(e.get("intl_standing", 0)) * _track_w(sim, "standing") +  (float(e.get("gold", 0)) / 20.0 + float(e.get("gold_per_turn", 0)) * 2.0 + float(e.get("production", 0)) / 15.0) * _track_w(sim, "economy") +  float(e.get("science", 0)) / 15.0 * _track_w(sim, "science") + float(e.get("culture", 0)) / 20.0
		if s > bs:
			bs = s; best = i
		i += 1
	return best


static func pick_immigration(sim) -> String:
	## Where to settle this year's arrivals. History follows the governments of the day; the Recommended pick
	## (SimEconomy.recommended_immigration) weighs cost, camps, readiness, food, water, science and the last plans;
	## the varied style settles the periphery first (development towns, then villages).
	if historical(sim):
		return sim.econ.historical_immigration_choice()
	var opts: Array = sim.econ.immigration_options()
	if style(sim) == "varied":
		for want in ["dev_towns", "villages"]:
			for o in opts:
				if str(o.get("base", "")) == want and not o.get("historical", false): return str(o["id"])
	var sgi := strategy(sim)
	if not sgi.is_empty() and str(sgi.get("imm", "")) != "":
		for o in opts:
			if str(o.get("base", "")) == str(sgi["imm"]): return str(o["id"])
	for o in opts:
		if o.get("default", false): return str(o["id"])
	return str(opts[0]["id"]) if not opts.is_empty() else "cities"


static func _terms_value(sim, ev, idx: int) -> float:
	## Value of the multi-year terms a choice sets (choice_terms.json), on the same scale as one-off effects.
	var v := 0.0
	var e = sim.db.choice_terms.get(str(ev["id"]), {})
	var cs: Array = e.get("choices", []) if typeof(e) == TYPE_DICTIONARY else []
	if idx >= cs.size() or typeof(cs[idx]) != TYPE_DICTIONARY:
		return 0.0
	for s in cs[idx].get("streams", []):
		var turns := float(maxi(1, SimDB.turn_of(s.get("until"), sim.state.turn) - maxi(sim.state.turn, SimDB.turn_of(s.get("from"), sim.state.turn)) + 1))
		var a := float(s.get("amount", 0))
		match str(s.get("type")):
			"gold": v += a * turns / 20.0
			"standing": v += a * turns * 2.0
			"trust": v += a * turns * 6.0
			"readiness": v += a * minf(turns, 20.0) / 4.0
	return v


static func pick_crisis_response(sim, opts: Array) -> int:
	if sim.state.crisis_decision.get("war_turn", false):
		return pick_war_turn(sim, opts)
	if sim.state.crisis_decision.get("operation", false):
		for id in (["op_full", "op_limited", "op_cover", "standing_forces"] if historical(sim) else ["op_full", "op_cover", "op_limited", "standing_forces"]):
			for i in range(opts.size()):
				if opts[i]["id"] == id and opts[i]["available"]:
					return i
		for i in range(opts.size()):
			if opts[i].get("available", true):
				return i
		return 0
	var order := ["mobilize", "standing_forces"] if historical(sim) else ["mobilize", "civil_defense", "backing", "standing_forces"]
	if not historical(sim) and sim.state.cohesion < 120 and sim.state.gold > 200:
		order = ["civil_defense", "mobilize", "backing", "standing_forces"]
	if str(strategy(sim).get("group", "")) == "security" and sim.state.gold > 120:
		order = ["civil_defense", "mobilize", "backing", "standing_forces"]   # v3: shelters first (halves damage to towns)
	for id in order:
		for i in range(opts.size()):
			if opts[i]["id"] == id and opts[i]["available"]:
				return i
	return opts.size() - 1


static func pick_war_turn(sim, opts: Array) -> int:
	## Commit where the enemy is strongest; full mobilisation when readiness is low and the treasury allows;
	## hold back only when no front is under pressure.
	var best := opts.size() - 1; var bs := 0.5
	for i in range(opts.size()):
		var o: Dictionary = opts[i]
		if not o["available"]: continue
		var s := 0.0
		var id := str(o["id"])
		if id.begins_with("front:") or id.begins_with("dfront:"):
			var n := int(o.get("n", 1))
			s = float(n) * 1.5 + 0.2
		elif id.begins_with("shield:"):
			s = 2.5
		elif id == "mobilize":
			s = 6.0   # the opening of a war: call up the reserves (what Israel did in every major war)
		elif id == "air_first":
			s = 0.0 if historical(sim) else 5.0
		elif id == "full_mobilization":
			s = (3.0 if sim.state.readiness < 45 else 1.0) - (2.0 if sim.state.gold < 150 else 0.0)
			if historical(sim): s += 2.0
			if str(strategy(sim).get("group", "")) == "security" and sim.state.gold >= 150: s += 4.0   # v3: the security strategist mobilises in full
		if s > bs:
			bs = s; best = i
	return best


static func pick_dedication(sim) -> String:
	if historical(sim):
		return ["ingathering", "pioneering", "statecraft", "innovation", "statecraft", "innovation", "innovation", "statecraft"][clampi(sim.state.era - 1, 0, 7)]
	if sim.state.era <= 2: return "pioneering"
	return "innovation"


static func pick_agenda(sim) -> int:
	var ag: Dictionary = sim.state.agenda
	# the varied style differs on forks, event choices and immigration; it runs the budget sensibly
	if str(ag.get("id", "")) == "inflation_emergency":
		var opts: Array = ag.get("options", [])
		for i in range(opts.size()):
			if opts[i].get("fx", {}).has("adopt_policy"): return i
		return 0
	var opts: Array = sim.state.agenda.get("options", [])
	if historical(sim) and sim.state.agenda.get("structural", false):
		for i in range(opts.size()):
			if not opts[i].get("fx", {}).has("econ_action"): return i
	if historical(sim):
		# history borrowed heavily in the 1950s, after 1973 and with the 1990s loan guarantees
		var yb := SimDB.year_of(sim.state.turn)
		if str(ag.get("id", "")) == "budget" and ((yb >= 1949 and yb <= 1956) or (yb >= 1974 and yb <= 1985) or (yb >= 1992 and yb <= 1996)):
			for i in range(opts.size()):
				if opts[i].get("fx", {}).has("borrow"): return i
		for i in range(opts.size()):
			if opts[i].get("default", false): return i
		return 0
	var id := str(sim.state.agenda.get("id", ""))
	match id:
		"fiscal":
			var want := "science"
			if sim.state.gold < 100: want = "gold"
			for i in range(opts.size()):
				if opts[i]["fx"].get("budget_focus", "") == want: return i
		"housing":
			return 0 if sim.state.gold > 120 else 1
		"water":
			return 2 if sim.state.gold > 150 else 0
		"budget":
			for i in range(opts.size()):
				if opts[i].get("default", false): return i
			return 0
		"inflation":
			return 0
		"readiness":
			return 0 if sim.state.gold > 80 else 1
		"immigration":
			return 0
	return 0


# ------------------------------------------------------------------ policies

static func card_value(sim, pid: String) -> float:
	var p: Dictionary = sim.db.policies[pid]
	var v := 0.0
	for e in p.get("effects", []):
		var t := str(e.get("type", ""))
		match t:
			"city_yield": v += float(e.get("amount", 0)) * sim.active_cities().size() * 0.4
			"yield_pct": v += float(e.get("pct", 0)) * (2.0 if e.get("yield") == "science" else 1.2)
			"amenity": v += float(e.get("amount", 0)) * 12.0
			"trust": v += float(e.get("amount", 0)) * 8.0
			"retention": v += float(e.get("pct", 0)) * 1.5
			"inflation": v -= float(e.get("amount", 0)) * (0.5 + 3.0 * log(1.0 + maxf(0.0, sim.state.inflation) / 100.0) + 4.0 * maxf(0.0, sim.inflation_gap()))
			"gold_per_turn": v += float(e.get("amount", 0)) * 1.5
			"gold_per_pop": v += float(e.get("amount", 0)) * 40.0
			"standing_per_turn": v += float(e.get("amount", 0)) * 60.0
			"readiness": v += float(e.get("amount", 0)) * (2.0 if sim.state.crises.size() > 0 else 0.6)
			"unit_strength": v += float(e.get("amount", 0)) * (3.0 if sim.state.crises.size() > 0 else 0.5)
			"prod_pct": v += float(e.get("pct", 0)) * 0.15
			"per_district", "per_building", "per_improvement": v += float(e.get("amount", 0)) * 4.0
			"housing": v += float(e.get("amount", 0)) * 6.0
			"growth_pct": v += float(e.get("pct", 0)) * 1.5
			"trade_gold": v += float(e.get("amount", 0)) * sim.state.trade_routes.size() * 1.5
			"trade_route_capacity": v += 8.0
			"adjacency_pct": v += float(e.get("pct", 0)) * 0.08
			"water_demand_pct": v -= float(e.get("pct", 0)) * (1.5 if float(sim.state.water.get("ratio", 1)) < 1.05 else 0.2)
			"water_supply_pct": v += float(e.get("pct", 0)) * (1.5 if float(sim.state.water.get("ratio", 1)) < 1.05 else 0.2)
			"maintenance_pct": v -= float(e.get("pct", 0)) * 0.6
			"cohesion_per_turn": v += float(e.get("amount", 0)) * 3.0
			_: v += 1.0
	if style(sim) in ["ruin_populist", "ruin_fiscal"]:
		# v3 final round (fix4-econ): the populist (and the borrower) slot every welfare card they can, whatever it costs
		for e2 in p.get("effects", []):
			if str(e2.get("type", "")) in ["gold_per_pop", "amenity", "housing"]: v += 80.0
	if historical(sim):
		v += 0.0
	return v


static func fill_policies(sim) -> bool:
	var changed := false
	var avail: Array = sim.available_policies()
	for i in range(sim.state.policies.size()):
		var slot: Dictionary = sim.state.policies[i]
		if str(slot["id"]) != "":
			continue
		var best := ""; var bv := -1e9
		for pid in avail:
			var p: Dictionary = sim.db.policies[pid]
			if slot["slot"] != "wildcard" and p["slot"] != slot["slot"]:
				continue
			var used := false
			for o in sim.state.policies:
				if o["id"] == pid: used = true
			if used:
				continue
			var v := card_value(sim, pid)
			if v > bv:
				bv = v; best = pid
		if best != "":
			sim.set_policy(i, best)
			changed = true
	return changed


static func _maybe_reslot(sim) -> void:
	## On free-swap turns, replace weak cards with better ones.
	if not sim.state.free_swap:
		return
	for i in range(sim.state.policies.size()):
		var cur := str(sim.state.policies[i]["id"])
		var cv := card_value(sim, cur) if cur != "" and sim.db.policies.has(cur) else -1e9
		var best := cur; var bv := cv
		for pid in sim.available_policies():
			var p: Dictionary = sim.db.policies[pid]
			var slot: Dictionary = sim.state.policies[i]
			if slot["slot"] != "wildcard" and p["slot"] != slot["slot"]:
				continue
			var used := false
			for o in sim.state.policies:
				if o["id"] == pid: used = true
			if used: continue
			var v := card_value(sim, pid)
			if v > bv + 1.0:
				bv = v; best = pid
		if best != cur:
			sim.set_policy(i, best)


# ------------------------------------------------------------------ units

static func _units(sim) -> void:
	for u in sim.state.units.duplicate():
		if u.owner != "player" or not sim.state.units.has(u):
			continue
		match u.type:
			"settler": _settler(sim, u)
			"builder": _builder(sim, u)
			_: _military(sim, u)


static func _settler(sim, u) -> void:
	var targets: Array = sim.settle_targets()
	if targets.is_empty():
		u.orders = "sleep"
		return
	var claimed := {}
	for o in sim.state.units:
		if o != u and o.type == "settler" and o.target.x >= 0:
			claimed[SimHex.key(o.target.x, o.target.y)] = true
	var best = null; var bd := 999
	for t in targets:
		var p := Vector2i(t["q"], t["r"])
		if claimed.has(SimHex.key(p.x, p.y)):
			continue
		var d := SimHex.distance(u.pos(), p) + maxi(0, int(t["historical_turn"]) - sim.state.turn) / 2
		if d < bd:
			bd = d; best = t
	if best == null:
		u.orders = "sleep"
		return
	var goal := Vector2i(best["q"], best["r"])
	if SimHex.distance(u.pos(), goal) <= 1:
		sim.military.unit_action(u.id, "found_city", {"radius": 1})
		return
	sim.military.move_unit(u, goal)
	if SimHex.distance(u.pos(), goal) <= 1 and sim.state.units.has(u):
		sim.military.unit_action(u.id, "found_city", {"radius": 1})
	elif sim.state.units.has(u):
		u.orders = "goto"


static func _builder(sim, u) -> void:
	var best_k := -1; var best_imp := ""; var bs := -1e9
	var econ = sim.econ
	for c in sim.active_cities():
		if SimHex.distance(c.pos(), u.pos()) > 14:
			continue
		for k in econ.city_tile_keys(c):
			var ts: Dictionary = econ.tstate(k)
			if str(ts.get("imp", "")) != "" or str(ts.get("d", "")) != "" or k == SimHex.key(c.q, c.r):
				continue
			if econ.is_water(k):
				continue
			for imp in _imp_candidates(sim, k):
				if sim.military.improvement_ok(imp, k, c) != "":
					continue
				var y: Dictionary = sim.db.improvements[imp].get("yields", {})
				var s := 0.0
				for kk in y: s += float(y[kk])
				s += float(sim.db.improvements[imp].get("housing", 0)) * 2.0
				if imp == "grove": s += 3.0
				if imp == "kibbutz": s += 1.0
				s -= SimHex.distance(SimHex.from_key(k), u.pos()) * 0.25
				if s > bs:
					bs = s; best_k = k; best_imp = imp
	if best_k < 0:
		u.orders = "sleep"
		return
	var goal := SimHex.from_key(best_k)
	if u.pos() != goal:
		sim.military.move_unit(u, goal)
	if u.pos() == goal and sim.state.units.has(u):
		var r: Dictionary = sim.military.unit_action(u.id, "build", {"improvement": best_imp})
		if not r.get("ok", false):
			u.orders = "sleep"
	elif sim.state.units.has(u):
		u.orders = "goto"


static func _imp_candidates(sim, k: int) -> Array:
	var res: String = sim.econ.resource(k)
	var terr: String = sim.econ.terrain(k)
	if res in SimEconomy.GROVE_RES: return ["grove"]
	if res in SimEconomy.MINERAL_RES: return ["mine_minerals"]
	if res in SimEconomy.QUARRY_RES: return ["quarry"]
	if res == "oil": return ["oil_well"]
	if res in SimEconomy.PASTURE_RES: return ["pasture"]
	if terr in ["desert", "desert_hills"]: return ["drip_farm", "solar_field", "kibbutz", "mine"]
	if terr == "hills": return ["farm", "kibbutz", "mine", "forest_planting"]
	if terr == "marsh": return ["fish_ponds", "farm"]
	return ["moshav", "kibbutz", "farm"]


static func _military(sim, u) -> void:
	var mil = sim.military
	var ud: Dictionary = mil.udata(u)
	var cls := str(ud.get("cls", ""))
	if sim.state.crises.is_empty():
		if u.orders == "" or u.orders == "skip":
			u.orders = "sleep"
		return
	if u.orders == "sleep":
		u.orders = ""
	# find nearest hostile
	var nearest = null; var nd := 99
	for h in sim.state.units:
		if h.owner != "player" and mil.is_military(h):
			var d := SimHex.distance(h.pos(), u.pos())
			if d < nd:
				nd = d; nearest = h
	if cls == "defense":
		var big = null
		for c in sim.active_cities():
			if big == null or c.pop() > big.pop(): big = c
		if big != null and u.pos() != big.pos():
			mil.move_unit(u, big.pos())
		u.orders = "fortify"
		return
	if nearest == null:
		u.orders = "fortify"
		return
	var rng_ := int(ud.get("range", 1)) if float(ud.get("rs", 0)) > 0 else 1
	if nd <= rng_:
		var pv: Dictionary = mil.preview(u, nearest.pos())
		if not pv.is_empty() and (pv["ranged"] or pv["delta"] > -8.0 or u.hp > 70):
			mil.attack(u, nearest.pos())
			return
	if cls in SimMilitary.AIR:
		u.orders = "fortify"
		return
	if nd <= 6 and u.moves > 0:
		var goal: Vector2i = nearest.pos()
		var best: Vector2i = u.pos(); var bd: int = nd
		for n in SimHex.neighbors(goal.x, goal.y):
			var dd := SimHex.distance(n, u.pos())
			if mil.passable(cls, SimHex.key(n.x, n.y)) and dd < bd + 3:
				best = n; bd = dd
		mil.move_unit(u, best)
		if sim.state.units.has(u) and SimHex.distance(u.pos(), nearest.pos()) <= rng_ and sim.state.units.has(nearest):
			if u.moves > 0:
				var pv2: Dictionary = mil.preview(u, nearest.pos())
				if not pv2.is_empty() and pv2["delta"] > -6.0:
					mil.attack(u, nearest.pos())
	if sim.state.units.has(u):
		u.orders = "fortify"


# ------------------------------------------------------------------ purchases (Civ VI: buy with gold at 4x, some items with Cohesion at 2x)

static func _purchases(sim) -> void:
	var reserve: float = (300.0 + 100.0 * sim.state.era) if historical(sim) else (150.0 + 60.0 * sim.state.era)
	if not strategy(sim).is_empty() or style(sim) == "varied":
		reserve = maxf(reserve, sim.endgame.reserve() * (2.5 if not strategy(sim).is_empty() else 1.5))   # v3: bank the surplus for national programmes
	elif style(sim) == "recommended" and not sim.endgame.candidates().is_empty():
		reserve = maxf(reserve, sim.endgame.reserve() * 2.0)   # fix-v3a: the Recommended player banks for the programme decision too
	if style(sim) == "ruin_fiscal":
		reserve = -1e9   # spend everything
	elif style(sim) in ["ruin_builder", "ruin_populist"]:
		reserve = 40.0 + 20.0 * sim.state.era   # v3 fix3-econ: the naive builder buys buildings whenever it has a little cash
	elif style(sim).begins_with("ruin_"):
		return
	var stress := fiscal_stress(sim) and not (style(sim) in ["ruin_builder", "ruin_populist"])
	for i in range(6):
		if sim.state.gold <= reserve:
			break
		var best = null; var bc := 1e9
		for c in sim.active_cities():
			if c.queue.is_empty():
				continue
			var it: Dictionary = c.queue[0]
			var cost: int = sim.purchase_cost(c, it["kind"], it["id"], "gold")
			if cost > 0 and cost < bc and sim.state.gold - cost >= reserve:
				bc = cost; best = [c, it]
		if best == null:
			break
		if sim.purchase(best[0].id, best[1]["kind"], best[1]["id"], "gold"):
			_repick(sim, best[0])
	# buy useful buildings outright in the largest cities (not only the current item)
	if sim.state.gold > reserve * 1.5:
		var cities: Array = sim.active_cities()
		cities.sort_custom(func(a, b): return a.pop() > b.pop())
		for c in cities.slice(0, 12):
			if sim.state.gold <= reserve:
				break
			var best_o = null; var bv := 0.0
			for o in sim.buildable(c):
				if not o["available"] or o["kind"] != "building" or o["gold_cost"] <= 0 or o["id"] in ["maabara", "fortifications"]:
					continue
				var bd: Dictionary = sim.db.buildings[o["id"]]
				if stress and float(bd.get("upkeep", 0)) > float(bd.get("yields", {}).get("gold", 0)):
					continue
				var val := 0.0
				for k in bd.get("yields", {}): val += float(bd["yields"][k])
				val += float(bd.get("housing", 0)) * 1.5 + float(bd.get("amenities", 0)) * 2.0
				var score: float = val / float(o["gold_cost"])
				if score > bv and sim.state.gold - float(o["gold_cost"]) >= reserve:
					bv = score; best_o = o
			if best_o != null:
				sim.purchase(c.id, "building", best_o["id"], "gold")
				_repick(sim, c)
	var coh_reserve: float = 80.0 + 20.0 * sim.state.era
	if style(sim) in ["ruin_builder", "ruin_populist"]: coh_reserve = 50.0
	if sim.state.cohesion > coh_reserve * 2.0:
		for c in sim.active_cities():
			if c.queue.is_empty():
				continue
			var it2: Dictionary = c.queue[0]
			var cc: int = sim.purchase_cost(c, it2["kind"], it2["id"], "cohesion")
			if cc > 0 and sim.state.cohesion - cc >= coh_reserve:
				if sim.purchase(c.id, it2["kind"], it2["id"], "cohesion"):
					_repick(sim, c)


static func _replan_city_projects(sim) -> void:
	## v3 final round (fix4-econ): a city whose queue holds only a repeating city project (the fallback when nothing was
	## worth building) looks again once a year, so housing, amenities or water it needs later are still built.
	for c in sim.active_cities():
		if c.queue.size() != 1 or str(c.queue[0].get("kind", "")) != "city_project" or (sim.state.turn + c.id) % 4 != 0:
			continue
		var p := pick_production(sim, c)
		if p.is_empty() or str(p.get("kind", "")) == "city_project":
			continue
		var keep: Array = c.queue.duplicate()
		c.queue.clear()
		if not sim.set_production(c.id, p["kind"], p["id"], int(p.get("tile", -1))):
			c.queue = keep


static func _repick(sim, c) -> void:
	if c.queue.is_empty():
		var p := pick_production(sim, c)
		if p.is_empty() or not sim.set_production(c.id, p["kind"], p["id"], int(p.get("tile", -1))):
			c.queue.append({"kind": "city_project", "id": "infrastructure_bonds", "tile": -1})


# ------------------------------------------------------------------ trade, diplomacy, ministries

static func _trade_and_diplomacy(sim) -> void:
	## v4 (v4-sim-auto): split in three (export routes, the deal screen, delegations) so the casual ministers can run the
	## routes and delegations without taking deals; the v3 autoplayers call all three in the same order as before.
	trade_routes(sim)
	if historical(sim):
		return
	deal_turn(sim)
	delegations(sim)


static func trade_routes(sim) -> void:
	## Fill every free export route from the largest port, airport or business-district cities (Finance's routine).
	var partners: Array = sim.trade_partners()
	if not partners.is_empty():
		var origins: Array = sim.active_cities().filter(func(c): return c.has_district("port") or c.has_district("airport") or c.has_district("business_district"))
		origins.sort_custom(func(a, b): return a.pop() > b.pop())
		var guard := 0
		while sim.state.trade_routes.size() < sim.trade_capacity() and guard < 20 and origins.size() > 0:
			guard += 1
			var o = origins[guard % origins.size()]
			var best := ""; var bg := -1.0
			for p in partners:
				var g: float = sim.trade_route_gold({"from": o.id, "partner": p})
				if g > bg:
					bg = g; best = p
			sim.start_trade_route(o.id, best)


static func deal_turn(sim) -> void:
	## The deal screen: at most one deal a quarter (v3 sim-diplomacy). Always the player's in casual play.
	sim.diplo.ai_turn(style(sim))


static func delegations(sim) -> void:
	## One delegation a quarter when the treasury is comfortable (the Foreign Ministry's routine).
	if sim.state.gold > (200.0 if str(strategy(sim).get("group", "")) == "peace" else 350.0):
		for a in sim.state.diplomacy:
			var st := str(sim.state.diplomacy[a]["status"])
			if st in ["relations_established", "peace", "normalized", "negotiating"]:
				if sim.send_delegation(a):
					break


static func _ministries(sim) -> void:
	## v2: ministers are appointed and promoted through the cabinet-title decision (resolve_one "minister").
	return
	var cs: Array = sim.active_cities()
	if cs.is_empty() or sim.state.ministries.size() >= sim.ministry_titles():
		return
	cs.sort_custom(func(a, b): return a.pop() > b.pop())
	var want := ["absorption", "economy", "education", "housing", "health", "agriculture"]
	for m in want:
		if sim.state.ministries.has(m) or sim.state.ministries.size() >= sim.ministry_titles():
			continue
		var city = cs[0]
		match m:
			"absorption":
				for c in cs:
					if float(c.info.get("transit", 0)) > float(city.info.get("transit", 0)): city = c
			"education":
				for c in cs:
					if c.has_district("university"): city = c; break
			"housing":
				city = cs[mini(1, cs.size() - 1)]
			"health":
				city = cs[mini(2, cs.size() - 1)]
			"agriculture":
				for c in cs:
					if int(c.info.get("farms", 0)) > int(city.info.get("farms", 0)): city = c
		sim.appoint_ministry(m, city.id)


# ------------------------------------------------------------------ ruinous test drivers (fix-v3a, sim_test's collapse report)
# Deliberately bad players that must reach each collapse of the state (v3 item 13):
#  ruin_fiscal: borrows everything lenders will give, spends every coin, indexes and rebates, never restrains prices;
#  ruin_trust: alienates everyone: the options that cost the most Civic Trust, cuts, transit camps, no amenities;
#  ruin_military: ignores the wars: no reserves, no mobilisation, disbands the army, starves the defence budget.

static func fiscal_stress(sim) -> bool:
	## v3 fix3-econ: running costs and debt service above revenue (or the structural-deficit alarm on).
	return sim.state.mode != "historical" and (sim.econ.structural_alarm() or sim.econ.structural_ratio() > 1.0)


static func _fiscal_levers(sim) -> void:
	## v3 fix3-econ: what a careful player does when the structural deficit is reported (the Recommended, varied and
	## strategist autoplayers; history and the ruinous drivers never): mothball the buildings that do least until running
	## costs fit revenue, privatise when the treasury is below zero, and adopt a stabilisation package once inflation runs
	## away or a fiscal collapse is in sight. When the budget is healthy again, the mothballed buildings reopen, best first.
	var st := style(sim)
	if st == "historical" or st.begins_with("ruin_") or sim.state.mode == "historical":
		return
	var fcl: String = sim.collapse.level_of("collapse_fiscal")
	if fiscal_danger(sim, fcl):
		fiscal_levers_danger(sim, fcl)
	else:
		fiscal_levers_healthy(sim)


static func fiscal_danger(sim, fcl := "") -> bool:
	## v4 (v4-sim-auto): the condition of the emergency levers: the structural-deficit alarm, or a fiscal collapse in sight.
	if fcl == "":
		fcl = sim.collapse.level_of("collapse_fiscal")
	return sim.econ.structural_alarm() or fcl in ["warning", "danger"]


static func fiscal_levers_danger(sim, fcl := "") -> void:
	## The emergency half of _fiscal_levers (v4 split, same code). In casual play the player authorises it once through
	## the Treasury-in-danger view (sim.auto.choose_treasury("finance_plan")); Finance then repeats it while the danger lasts.
	var e = sim.econ
	if fcl == "":
		fcl = sim.collapse.level_of("collapse_fiscal")
	var gap: float = e.structural_gap()
	if gap > 0.0:
		e.mothball_many(e.mothball_plan(gap * 1.1, 25))
		sim.state.counters["ai_last_mothball"] = sim.state.turn
	if sim.state.gold < 0.0 and not e.next_privatisation().is_empty():
		e.privatise(str(e.next_privatisation()["id"]))
	if (sim.state.inflation >= 60.0 or fcl == "danger") and e.stabilisation_option()["available"]:
		e.stabilise()
	# v3 final round (fix4-econ, N1): the costly policy cards too, history's own cuts: half strength after a year of
	# the alarm (or at once with the treasury below zero), suspended when a fiscal collapse is in sight
	var since := int(e.structural().get("since", sim.state.turn))
	if (sim.state.turn - since >= 3 or sim.state.gold < 0.0 or fcl in ["warning", "danger"]) and gap > 0.0:
		for pc in e.policy_costs():
			if str(pc["state"]) == "full":
				e.scale_back_policy(str(pc["id"]), "half")
				sim.state.counters["ai_last_policy_cut"] = sim.state.turn
				break
			elif str(pc["state"]) == "half" and fcl == "danger":
				e.scale_back_policy(str(pc["id"]), "suspend")
				sim.state.counters["ai_last_policy_cut"] = sim.state.turn
				break


static func fiscal_levers_healthy(sim) -> void:
	## The healthy half of _fiscal_levers (v4 split, same code): reopen mothballed buildings and restore cut cards once the
	## budget has room. Called only when fiscal_danger() is false (Finance's routine in casual play).
	var e = sim.econ
	if e.structural_ratio() < 0.85 and sim.state.gold > 150.0 + 60.0 * sim.state.era and float(sim.state.counters.get("last_budget", {}).get("net", 0.0)) > 0.0 			and sim.state.turn - int(sim.state.counters.get("ai_last_mothball", -99)) >= 8:   # no reopening within two years of mothballing
		# reopen the most useful mothballed building while there is room in the budget
		var best = null; var bv := -1.0
		for c in sim.active_cities():
			for b in e.mothballed(c):
				var v: float = e.building_value(c, b)
				if v > bv and e.reopen_cost(b) < sim.state.gold * 0.3: bv = v; best = [c, b]
		if best != null:
			e.reopen(best[0], best[1])
		elif sim.state.turn - int(sim.state.counters.get("ai_last_policy_cut", -99)) >= 12:
			# a card cut in a crisis is restored once the budget has room for it again (three years after the cut)
			for pc in e.policy_costs():
				if str(pc["state"]) != "full" and float(pc["full_cost"]) - float(pc["cost"]) < 0.3 * float(sim.state.counters.get("last_budget", {}).get("net", 0.0)):
					e.restore_policy(str(pc["id"]))
					break


static func _history_bonds(sim) -> void:
	## v3 fix3-econ: history's 1949-56 governments covered an overdraft of more than half a year with Independence Bonds and
	## foreign loans (Israel Bonds from 1950); the ghost and the historical-picks player borrow the same way, so the
	## ghost's treasury does not sit below zero for years whenever the agenda's deficit item happens not to come up.
	if not historical(sim):
		# a careful player (Recommended, varied, strategists) refinances an overdraft of more than half a year with a
		# loan instead of running it for years (the healthy-game fiscal indicator stays below "warning")
		var stc := style(sim)
		if stc.begins_with("ruin_") or sim.state.mode == "historical": return
		if sim.state.gold >= -10.0 or int(sim.state.counters.get("neg_turns", 0)) < 3: return
		var amt2 := minf(sim.econ.borrow_room() * 0.5, -sim.state.gold + 30.0 * sim.events.gold_scale())
		if amt2 >= 20.0:
			sim.econ.borrow(amt2, "Development loan to clear the overdraft")
		return
	var y := SimDB.year_of(sim.state.turn)
	if y < 1949 or y > 1956 or sim.state.gold >= -20.0 or int(sim.state.counters.get("neg_turns", 0)) < 2:
		return
	var amt := minf(sim.econ.borrow_room(), -sim.state.gold + 40.0 * sim.events.gold_scale())
	if amt >= 20.0:
		sim.econ.borrow(amt, "Independence Bonds and foreign loans")


static func _builder_pick(sim, c) -> Dictionary:
	## The naive builder (sim_test, v3 fix3-econ): every building it can, the most visible yields first, upkeep ignored,
	## bought with gold and Cohesion whenever it can and with any loan the Cabinet Agenda offers;
	## districts when nothing else is left; units only as the Recommended player would in a war or at low readiness.
	if c.pop() >= 6 and (sim.state.readiness < 45.0 or not sim.state.crises.is_empty()):
		return pick_production(sim, c)
	var opts: Array = sim.buildable(c)
	var best = null; var bv := -1e9
	for o in opts:
		if o["kind"] != "building" or not o["available"] or o["id"] in ["maabara", "fortifications"]:
			continue
		var bd: Dictionary = sim.db.buildings[o["id"]]
		var v := 0.0
		for k in bd.get("yields", {}): v += float(bd["yields"][k])
		v += float(bd.get("housing", 0)) + float(bd.get("amenities", 0)) * 1.5 + float(bd.get("trust", 0)) + float(bd.get("growth_pct", 0)) * 0.1
		if o["id"] in ["school", "clinic", "community_center", "research_institute", "research_library", "hospital", "water_tower", "absorption_center"]: v += 3.0
		v -= float(o["turns"]) * 0.05
		if v > bv: bv = v; best = o
	if best != null:
		return _sel(best)
	return pick_production(sim, c)


static func _ruin_turn(sim) -> void:
	var st := style(sim)
	if st == "ruin_builder" or st == "ruin_populist":
		# the naive builder covers an overdraft with whatever loan it can get, and keeps building
		var room0: float = sim.econ.borrow_room()
		if sim.state.gold < 0.0 and room0 > 20.0:
			sim.econ.borrow(minf(room0, -sim.state.gold + 120.0 * sim.events.gold_scale()), "Borrow abroad")
	if st == "ruin_fiscal":
		var room: float = sim.econ.borrow_room()
		if room > 1.0:
			sim.econ.borrow(room, "Borrow abroad")
	elif st == "ruin_military":
		for u in sim.state.units.duplicate():
			if u.owner == "player" and sim.military.is_military(u):
				sim.unit_action(u.id, "disband", {})


static func _ruin_val(st: String, stat: String, amount: float) -> float:
	## How much a ruinous driver wants an effect (higher = worse for the country on its axis).
	match st:
		"ruin_fiscal":
			if stat in ["gold", "gold_per_turn", "economy"]: return -amount
			if stat == "inflation": return amount * 3.0
			if stat == "borrow": return amount * 2.0
		"ruin_trust":
			if stat in ["trust", "trust_all", "trust_base", "morale", "cohesion", "amenity", "amenity_all"]: return -amount * 10.0
			if stat == "inflation": return amount
		"ruin_military":
			if stat in ["readiness", "readiness_bonus"]: return -amount * 5.0
		"ruin_populist":
			# v3 final round (fix4-econ): money and goodwill now, whatever it costs later; defence comes last
			if stat in ["gold", "gold_per_turn"]: return amount
			if stat in ["trust", "trust_all", "trust_base", "morale", "amenity", "amenity_all"]: return amount * 6.0
			if stat == "borrow": return amount * 2.0
			if stat in ["readiness", "readiness_bonus"]: return -amount
	return 0.0


static func _ruin_fx_score(st: String, fx: Dictionary) -> float:
	var v := 0.0
	for k in fx:
		var a = fx[k]
		if typeof(a) in [TYPE_INT, TYPE_FLOAT]:
			v += _ruin_val(st, str(k), float(a))
	return v


static func _ruin_best(scores: Array) -> int:
	var best := 0
	var bv := -1e18
	for i in range(scores.size()):
		if float(scores[i]) > bv:
			bv = float(scores[i])
			best = i
	return best


static func _ruin_resolve(sim, d: Dictionary) -> int:
	## 1 / 0: handled (ok / failed); -1: not handled here (the Recommended pick).
	var st := style(sim)
	var ty := str(d.get("type", ""))
	if st == "ruin_builder":
		# the naive builder (v3 fix3-econ): builds everything, never borrows and never uses the structural levers
		match ty:
			"choose_production":
				var city = sim.city_by_id(int(d["city"]))
				if city == null: return 0
				var bp := _builder_pick(sim, city)
				if bp.is_empty() or not sim.set_production(city.id, bp["kind"], bp["id"], int(bp.get("tile", -1))):
					city.queue.append({"kind": "city_project", "id": "infrastructure_bonds", "tile": -1})
				return 1
			"agenda":
				var ao: Array = sim.state.agenda.get("options", [])
				if ao.is_empty(): return -1
				for i in range(ao.size()):
					if ao[i].get("fx", {}).has("borrow"):
						return 1 if sim.choose_agenda(i) else 0   # a loan keeps the building going (the critic's naive player borrowed too)
				for i in range(ao.size()):
					if ao[i].get("default", false) and not ao[i].get("fx", {}).has("econ_action"):
						return 1 if sim.choose_agenda(i) else 0
				for i in range(ao.size()):
					if not ao[i].get("fx", {}).has("econ_action") and not ao[i].get("fx", {}).has("borrow"):
						return 1 if sim.choose_agenda(i) else 0
				return -1
			"programme":
				var po2: Array = d.get("options", [])
				for i in range(po2.size()):
					if str(po2[i]["id"]) in ["hold", "defer"]: return 1 if sim.choose_programme(i) else 0
				return -1
		return -1
	match ty:
		"choose_production":
			if st != "ruin_populist" and st != "ruin_fiscal":
				return -1
			var pcity = sim.city_by_id(int(d["city"]))   # the populist builds whatever looks grand (the naive builder's picks)
			if pcity == null: return 0
			var pp := _builder_pick(sim, pcity)
			if pp.is_empty() or not sim.set_production(pcity.id, pp["kind"], pp["id"], int(pp.get("tile", -1))):
				pcity.queue.append({"kind": "city_project", "id": "infrastructure_bonds", "tile": -1})
			return 1
		"agenda":
			var opts: Array = sim.state.agenda.get("options", [])
			if opts.is_empty():
				return -1
			var sc0 := []
			for o in opts:
				var sv := _ruin_fx_score(st, o.get("fx", {}))
				if o.get("fx", {}).has("econ_action"): sv -= 1e6   # the ruinous drivers never take the structural levers (fix4-econ)
				sc0.append(sv)
			return 1 if sim.choose_agenda(_ruin_best(sc0)) else 0
		"fork":
			var f = sim.db.forks.get(str(d.get("fork", "")))
			var opts2: Array = d.get("options", [])
			if f == null or opts2.is_empty():
				return -1
			var best := str(opts2[0]["id"])
			var bv := -1e18
			for o in f["options"]:
				var v := 0.0
				for t in o.get("lasting", []):
					var yrs := maxf(0.25, float(SimDB.turn_of(t.get("until"), 0) - SimDB.turn_of(t.get("from"), 0) + 1) / 4.0)
					v += _ruin_val(st, str(t.get("type", "")), float(t.get("amount", 0.0))) * minf(yrs, 10.0)
				var now = o.get("now", {})
				if typeof(now) == TYPE_DICTIONARY:
					v += _ruin_fx_score(st, now)
				if v > bv:
					bv = v
					best = str(o["id"])
			return 1 if sim.choose_fork(str(d["fork"]), best) else 0
		"event_choice":
			var ev = sim.db.event_by_id.get(d["event"])
			if ev == null:
				return -1
			var sc := []
			for ch in ev.get("choices", []):
				var e: Dictionary = ch.get("effects", {})
				sc.append(_ruin_fx_score(st, e) + _ruin_val(st, "readiness", float(e.get("readiness", 0))))
			if sc.is_empty():
				return -1
			return 1 if sim.choose_event(d["event"], _ruin_best(sc)) else 0
		"crisis_response":
			if st != "ruin_military":
				return -1
			var co: Array = d.get("options", [])
			for want in ["economy_first", "standing_forces", "op_cover", "limited_aims"]:
				for i in range(co.size()):
					if str(co[i].get("id", "")) == want and co[i].get("available", true):
						return 1 if sim.choose_crisis_response(i) else 0
			return 1 if sim.choose_crisis_response(co.size() - 1) else 0
		"budget_review":
			var ro: Array = sim.cabinet.review_options()
			var wants: Dictionary = {"ruin_fiscal": ["war_loan", "index_budget", "tax_rebate", "war_supplement", "supplement", "keep"],
				"ruin_trust": ["cut", "nominal_freeze", "freeze_hiring", "keep"], "ruin_military": ["keep", "cut"],
				"ruin_populist": ["tax_rebate", "index_budget", "supplement", "war_loan", "keep"]}
			for w in wants.get(st, ["keep"]):
				for i in range(ro.size()):
					if str(ro[i]["id"]) == str(w):
						return 1 if sim.choose_budget_review(i) else 0
			return -1
		"state_budget":
			if st == "ruin_fiscal":
				return -1
			var pr: Array = sim.cabinet.budget_presets()
			var bi := 0
			var bv2 := 1e9
			for i in range(pr.size()):
				var sh: Dictionary = pr[i].get("shares", {})
				var v2 := float(sh.get("defence", 0.25)) if st in ["ruin_military", "ruin_populist"] else float(sh.get("absorption", 0.25)) + float(sh.get("development", 0.25))
				if v2 < bv2:
					bv2 = v2
					bi = i
			return 1 if sim.choose_state_budget(bi) else 0
		"immigration":
			if st != "ruin_trust" and st != "ruin_populist":   # the populist houses newcomers in transit camps too (fix4-econ)
				return -1
			var allowed: Array = sim.econ.immigration_options_allowed()
			for o in sim.econ.immigration_options():
				if str(o.get("base", "")) == "camps" and (allowed.is_empty() or str(o["id"]) in allowed or str(o.get("base", "")) in allowed):
					return 1 if sim.choose_immigration(str(o["id"])) else 0
			return -1
		"programme":
			if st != "ruin_fiscal" and st != "ruin_populist":
				return -1
			var po: Array = d.get("options", [])
			for i in range(po.size()):
				if (str(po[i]["id"]).begins_with("launch:") or str(po[i]["id"]).begins_with("expand:")) and sim.choose_programme(i):
					return 1
			return -1
	return -1
