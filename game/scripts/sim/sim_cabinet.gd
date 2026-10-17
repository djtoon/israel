class_name SimCabinet
extends RefCounted
## v2 recurring cabinet decisions, Civ VI-style systems built on real Israeli institutions (data in governments.json):
##
##  1. The State Budget. Each fiscal year the government puts a Budget Law to the Knesset (April-March years
##     until 1991, calendar years from 1992). The player splits it between four envelopes - defence; immigrant
##     absorption and housing; development and water; education and science - and two quarters later holds a
##     mid-year review whose options depend on the year's fiscal state (deficit, war, inflation, surplus).
##     Each envelope's effect follows sqrt(share / 25%) - 1, so a specialised budget buys a large gain on one
##     track for smaller losses on the other three, and a balanced one gains nothing but restrains prices.
##  2. Ministers (Civ VI governors). Seven portfolios. Each new government opens ONE cabinet screen where every
##     title is spent at once (appoint ministers to seat cities, or buy their promotions: national programmes of
##     the era, favoured by the governing bloc). Once a year, the quarter after the Budget Law passes, the cabinet
##     gets one more title (the year's ministerial programme). A new government of the same party (or a rotation)
##     keeps its ministers' programmes; a change of party ends them.
##  3. Coalition deals. After every election and change of government the prime minister negotiates with the
##     real partners of that government (governments.json terms[].partners, each with its leader and a cite),
##     or with a party that negotiated and stayed out; a partner takes its real portfolios and a sector budget.
##
## Decisions (get_pending_decisions): state_budget, budget_review, minister, coalition. See API.md "v2" and "v2 fixes".

const ENVELOPES := ["defence", "absorption", "development", "education"]
const FY_CALENDAR_FROM := 1992      # the budget year became the calendar year (until then April-March)
const FIRST_BUDGET_YEAR := 1949
const TITLE_EVERY := 4              # quarters between the yearly ministerial titles (one a year, after the Budget Law)
const TITLE_CAP := 4                # unspent titles stop accruing above this
const CABINET_TITLES := 3           # a new governing party's cabinet sets three priorities
const CABINET_TITLES_SAME := 2      # the same party (or a rotation) re-forming keeps its programmes, sets two more
const SHARE_MIN := 0.10
const SHARE_MAX := 0.55
const PARTY_BLOC := {"Mapai": "labour", "Alignment": "labour", "Labor": "labour", "One Israel": "labour",
	"Likud": "right", "Yamina": "right", "Kadima": "centre", "Yesh Atid": "centre"}

var sim


func _init(s) -> void:
	sim = s


func S() -> GameState:
	return sim.state


func gov() -> Dictionary:
	return sim.db.gov


func _fmt(n: float) -> String:
	## 12345 -> "12,345"
	var s := str(int(round(absf(n))))
	var out := ""
	while s.length() > 3:
		out = "," + s.substr(s.length() - 3) + out
		s = s.substr(0, s.length() - 3)
	return ("-" if n < -0.5 else "") + s + out


# ================================================================== state budget

func envelope_defs() -> Array:
	return gov().get("budget", {}).get("envelopes", [])


func envelope_def(id: String) -> Dictionary:
	for e in envelope_defs():
		if str(e.get("id", "")) == id:
			return e
	return {}


static func share_mult(share: float) -> float:
	## Effect multiplier of an envelope at this share of the budget (0 at an even 25% split, concave).
	return sqrt(maxf(0.0, share) / 0.25) - 1.0


func budget_label_for(turn: int) -> String:
	## The fiscal year a budget decided in this quarter is for ("" if no budget is due this quarter).
	var y := SimDB.year_of(turn)
	var q := SimDB.quarter_of(turn)
	if q == 1 and y >= FIRST_BUDGET_YEAR and y < FY_CALENDAR_FROM:
		return "%d/%02d" % [y, (y + 1) % 100]
	if q == 4 and y + 1 >= FY_CALENDAR_FROM and y + 1 <= SimDB.year_of(SimDB.LAST_TURN):
		return str(y + 1)
	return ""


func next_budget_turn(after: int) -> int:
	for t in range(after + 1, SimDB.LAST_TURN + 1):
		if budget_label_for(t) != "":
			return t
	return SimDB.LAST_TURN + 1


func budget_due() -> bool:
	var st := S()
	return budget_label_for(st.turn) != "" and int(st.budget.get("turn", -1)) != st.turn


func review_due() -> bool:
	var st := S()
	var bt := int(st.budget.get("turn", -99))
	return bt > 0 and st.turn == bt + 2 and not st.budget.get("reviewed", false) and int(st.budget.get("until", 0)) >= st.turn


func _war_recent() -> bool:
	for cr in S().crises:
		if cr.get("active", true) and cr.has("war_id"):
			return true
	for r in S().crisis_log:
		if S().turn - int(r.get("end", -99)) <= 4 and str(r.get("id", "")).begins_with("crisis_"):
			return true
	return false


func _war_now() -> bool:
	for cr in S().crises:
		if cr.get("active", true) and cr.has("war_id"):
			return true
	return false


func budget_presets() -> Array:
	var out := []
	for p in gov().get("budget", {}).get("presets", []):
		if p.get("war_only", false) and not _war_recent():
			continue
		out.append(p)
	return out


func _scaled(e: Dictionary, m: float) -> Dictionary:
	var o: Dictionary = e.duplicate()
	for k in ["amount", "pct"]:
		if o.has(k):
			o[k] = float(o[k]) * m
	return o


func budget_effects(shares: Dictionary, extra := {}) -> Array:
	## Modifiers for a split: [{type, ..., src: "budget:<envelope>"}]. extra = {envelope: added multiplier}.
	var out := []
	for env in envelope_defs():
		var id := str(env["id"])
		var m := share_mult(float(shares.get(id, 0.25))) + float(extra.get(id, 0.0))
		if absf(m) < 0.001:
			continue
		for e in env.get("effects", []):
			var se := _scaled(e, m)
			se["src"] = "budget:" + id
			out.append(se)
	return out


func _preset_extra(preset: String) -> Array:
	## Preset-level terms beyond the envelopes (governments.json presets[].extra_effects), e.g. a balanced budget
	## restrains prices because no ministry gets a big increase.
	for p in gov().get("budget", {}).get("presets", []):
		if str(p.get("id", "")) == preset:
			var out := []
			for e in p.get("extra_effects", []):
				var ee: Dictionary = e.duplicate()
				ee["src"] = "budget:" + preset
				out.append(ee)
			return out
	return []


func effect_lines(effects: Array) -> Array:
	## Structured effects [{stat, amount, unit, label}] (UI request 18) for a list of modifiers.
	var out := []
	for e in effects:
		var t := str(e.get("type", ""))
		var a := float(e.get("amount", e.get("pct", 0.0)))
		if absf(a) < 0.005:
			continue
		var grp := ""
		var cond: Dictionary = e.get("cond", {}) if typeof(e.get("cond", {})) == TYPE_DICTIONARY else {}
		if cond.has("group"): grp = " in " + str(SimForks.GROUP_NAMES.get(str(cond["group"]), cond["group"]))
		elif cond.get("periphery", false): grp = " in the periphery"
		elif cond.has("min_pop"): grp = " in cities of population %d+" % int(cond["min_pop"])
		elif cond.has("max_pop"): grp = " in towns of population %d or less" % int(cond["max_pop"])
		var here := " in the seat city" if e.has("city") else ""
		match t:
			"readiness": out.append({"stat": "readiness", "amount": a, "unit": "points", "label": "%+.1f Readiness" % a, "good": a > 0})
			"yield_pct": out.append({"stat": str(e.get("yield", "")), "amount": a, "unit": "%", "label": "%+.1f%% %s" % [a, str(e.get("yield", "")).capitalize()], "good": a > 0})
			"yield_pct_city": out.append({"stat": str(e.get("yield", "")), "amount": a, "unit": "% (seat city)", "label": "%+.0f%% %s%s" % [a, str(e.get("yield", "")).capitalize(), here], "good": a > 0})
			"housing", "housing_city": out.append({"stat": "housing", "amount": a, "unit": "housing", "label": "%+.1f Housing%s" % [a, grp if grp != "" else (here if here != "" else " in every city")], "good": a > 0})
			"amenity", "amenity_city": out.append({"stat": "amenity", "amount": a, "unit": "amenities", "label": "%+.1f Amenity%s" % [a, grp if grp != "" else (here if here != "" else " in every city")], "good": a > 0})
			"growth_pct", "growth_pct_city": out.append({"stat": "population", "amount": a, "unit": "% growth", "label": "%+.1f%% population growth%s" % [a, grp if grp != "" else here], "good": a > 0})
			"retention": out.append({"stat": "population", "amount": a, "unit": "% retention", "label": "%+.1f%% immigrant retention" % a, "good": a > 0})
			"trust": out.append({"stat": "trust", "amount": a, "unit": "trust/turn", "label": "%+.1f Civic Trust%s" % [a, grp if grp != "" else " everywhere"], "good": a > 0})
			"water_supply": out.append({"stat": "water", "amount": a, "unit": "million m3/yr", "label": "%+.0f million m3 of water a year" % a, "good": a > 0})
			"water_supply_pct": out.append({"stat": "water", "amount": a, "unit": "% supply", "label": "%+.1f%% water supply" % a, "good": a > 0})
			"water_demand_pct": out.append({"stat": "water", "amount": -a, "unit": "% demand", "label": "%+.1f%% water demand" % a, "good": a < 0})
			"cohesion_per_turn": out.append({"stat": "cohesion", "amount": a, "unit": "per turn", "label": "%+.1f Cohesion per turn" % a, "good": a > 0})
			"standing_per_turn": out.append({"stat": "standing", "amount": a, "unit": "per turn", "label": "%+.2f Standing per turn" % a, "good": a > 0})
			"trade_route_capacity": out.append({"stat": "economy", "amount": a, "unit": "routes", "label": "%+d export route" % int(a), "good": a > 0})
			"war_weariness_pct": out.append({"stat": "trust", "amount": -a, "unit": "% war weariness", "label": "%+.0f%% war weariness" % a, "good": a < 0})
			"inflation": out.append({"stat": "inflation", "amount": a, "unit": "policy points", "label": "%+.0f inflation pressure" % a, "good": a < 0})
			"city_defense": out.append({"stat": "readiness", "amount": a, "unit": "defence", "label": "%+.0f city defence%s" % [a, here], "good": a > 0})
			"city_yield": out.append({"stat": str(e.get("yield", "food")), "amount": a, "unit": "per town", "label": "%+.0f %s%s" % [a, str(e.get("yield", "food")).capitalize(), grp if grp != "" else " in every town"], "good": a > 0})
			"immigrant_weight_city": out.append({"stat": "population", "amount": float(e.get("pct", 0)), "unit": "% arrivals", "label": "%+.0f%% of arrivals to the seat city" % float(e.get("pct", 0))})
			"transit_conversion_city": out.append({"stat": "population", "amount": float(e.get("pct", 0)), "unit": "% rehousing", "label": "temporary housing cleared %+.0f%% faster in the seat city" % float(e.get("pct", 0)), "good": true})
			"prod_pct_city_target": out.append({"stat": "production", "amount": float(e.get("pct", 0)), "unit": "%", "label": "%+.0f%% Production toward %s in the seat city" % [float(e.get("pct", 0)), str(e.get("target", ""))], "good": true})
			"tile_yield_city": out.append({"stat": str(e.get("yield", "food")), "amount": a, "unit": "per farm", "label": "%+.0f %s on farms of the seat city" % [a, str(e.get("yield", "food")).capitalize()], "good": a > 0})
			_: out.append({"stat": t, "amount": a, "unit": "", "label": "%s %+.1f" % [t.replace("_", " ").capitalize(), a]})
	return out


func preset_view(p: Dictionary) -> Dictionary:
	var shares: Dictionary = p.get("shares", {})
	var eff := budget_effects(shares) + _preset_extra(str(p["id"]))
	var lines := effect_lines(eff)
	var fx := {}
	for e in eff:
		if str(e.get("type")) == "readiness": fx["readiness"] = snappedf(float(fx.get("readiness", 0.0)) + float(e["amount"]), 0.1)
	var desc := ", ".join(ENVELOPES.map(func(k): return "%s %d%%" % [str(envelope_def(k).get("short", k)), int(round(float(shares.get(k, 0.25)) * 100.0))]))
	return {"id": str(p["id"]), "label": str(p.get("label", p["id"])), "desc": "%s. %s" % [desc, str(p.get("desc", ""))],
		"shares": shares.duplicate(), "effects": lines, "effects_text": lines.map(func(l): return l["label"]), "fx": fx, "default": false}


func budget_decision() -> Dictionary:
	var st := S()
	var opts := []
	for p in budget_presets():
		opts.append(preset_view(p))
	var rec := recommended_preset()
	for o in opts:
		o["default"] = str(o["id"]) == rec
	var fy := budget_label_for(st.turn)
	var envs := []
	for e in envelope_defs():
		envs.append({"id": e["id"], "name": e.get("name", e["id"]), "short": e.get("short", e["id"]), "desc": e.get("desc", ""),
			"current_share": float(st.budget.get("shares", {}).get(e["id"], 0.25)),
			"effects_at_40": effect_lines(budget_effects({e["id"]: 0.40}).filter(func(x): return str(x["src"]) == "budget:" + str(e["id"]))).map(func(l): return l["label"])})
	var why := str(budget_reason(rec))
	return {"type": "state_budget", "blocking": true, "label": "STATE BUDGET %s: SPLIT THE BUDGET" % fy, "fiscal_year": fy,
		"explain": "Every year the Knesset votes the State Budget. Split it between defence, absorption and housing, development and water, and education and science: a big share buys a big gain on one track, at a cost to the others.",
		"text": "The Finance Ministry presents the Budget Law for %s to the cabinet before the Knesset vote. The total is set by revenue; you decide how it is split between the four envelopes. A specialised budget buys a large gain on one track at a smaller cost on the other three; an even split gains nothing but restrains prices. Choose a preset or set your own shares (10-55%% each).%s" % [("the fiscal year " + fy if fy.contains("/") else fy), (" The Treasury's advice this year: " + why) if why != "" else ""],
		"envelopes": envs, "options": opts, "recommended": rec, "recommended_why": why, "share_min": SHARE_MIN, "share_max": SHARE_MAX, "source": gov().get("budget", {}).get("source", [])}


func _years_since_preset(preset: String) -> float:
	var hist: Array = S().counters.get("budget_history", [])
	for i in range(hist.size() - 1, -1, -1):
		if str(hist[i].get("preset", "")) == preset:
			return float(hist.size() - 1 - i)
	return 6.0


func _science_ratio() -> float:
	var g: Dictionary = sim.score.ghost_at(S().turn)
	if g.is_empty() or float(g.get("science", 0.0)) <= 0.0:
		return 1.0
	return float(S().techs.size()) / float(g["science"])


func preset_needs() -> Dictionary:
	## How much the country needs each budget emphasis this year (the Recommended pick is the largest). It reads
	## the situation (war and readiness, immigration and camps, water, science against history, inflation and the
	## deficit) and how long since an envelope last led, so the advice follows the year rather than one formula.
	var st := S()
	var ids := budget_presets().map(func(p): return str(p["id"]))
	var net := float(st.counters.get("last_budget", {}).get("net", 0.0))
	var inc := maxf(30.0, float(st.counters.get("income_avg", 45.0)))
	var hostile := 0
	for a in st.diplomacy:
		if str(st.diplomacy[a].get("status", "")) in ["war", "hostile"]: hostile += 1
	var n := {}
	n["defence"] = (68.0 - st.readiness) / 10.0 + (1.6 if _war_recent() else 0.0) + 0.12 * hostile
	n["absorption"] = sim.econ.expected_arrivals() / 14000.0 + _transit_share() * 45.0 - 0.3
	var periph_t := 0.0; var pw := 0.0
	for c in sim.active_cities():
		if sim.econ.is_periphery(c): periph_t += c.trust * c.residents; pw += c.residents
	periph_t = periph_t / pw if pw > 0.0 else 75.0
	# (fix-recpick) a water surplus or contented periphery lowers the need only a little, not by 10+ points
	n["development"] = clampf((1.0 - float(st.water.get("ratio", 1.0))) * 18.0, -1.0, 6.0) + clampf((72.0 - periph_t) / 8.0, -1.5, 2.0) + 0.7
	n["education"] = 0.7 + (1.0 - _science_ratio()) * 6.0 + (0.4 if SimDB.year_of(st.turn) >= 1990 else 0.0)
	n["balanced"] = (st.inflation - 25.0) / 30.0 + (0.8 if net < -0.15 * inc else 0.0) + (0.6 if st.gold < 0.0 else 0.0)
	# (fix-recpick) the tracks each envelope feeds, against the ghost of history: the further behind, the more it needs
	var lag := _track_lags()
	n["absorption"] = float(n["absorption"]) + 1.5 * float(lag.get("population", 0.0)) + 0.5 * float(lag.get("cohesion", 0.0))
	n["development"] = float(n["development"]) + 0.8 * float(lag.get("water", 0.0)) + 0.8 * float(lag.get("economy", 0.0))
	n["defence"] = float(n["defence"]) + 0.5 * float(lag.get("standing", 0.0))
	var recent := _recent_preset_counts(4)
	for k in ["defence", "absorption", "development", "education"]:
		n[k] = float(n[k]) + 0.35 * minf(4.0, _years_since_preset(k)) - (0.9 if _years_since_preset(k) == 0.0 else 0.0)
		# (fix-recpick) an envelope that led most of the last four budgets has had its turn: the others catch up
		n[k] = float(n[k]) - 0.8 * float(recent.get(k, 0))
	if "war" in ids:
		n["war"] = float(n["defence"]) + (1.2 if _war_now() else 0.2) + (55.0 - st.readiness) / 10.0
	var out := {}
	for k in n:
		if k in ids: out[k] = snappedf(float(n[k]), 0.01)
	return out


func _track_lags() -> Dictionary:
	## Each score track's shortfall against the ghost of history, 0 when level or ahead, up to 2 when far behind.
	var out := {}
	var cur: Dictionary = sim.score.current()
	if not bool(cur.get("has_ghost", false)):
		return out
	for t in cur.get("tracks", []):
		out[str(t["id"])] = clampf((1.0 - float(t.get("ratio", 1.0))) * 6.0, 0.0, 2.0)
	return out


func _recent_preset_counts(years: int) -> Dictionary:
	## How many of the last `years` State Budgets each preset led.
	var hist: Array = S().counters.get("budget_history", [])
	var out := {}
	for i in range(maxi(0, hist.size() - years), hist.size()):
		var p := str(hist[i].get("preset", ""))
		out[p] = int(out.get(p, 0)) + 1
	return out


func recommended_preset() -> String:
	## The autoplayer's pick (also the "Recommended" badge): the emphasis the year needs most (preset_needs).
	var nd := preset_needs()
	var best := "balanced"; var bv := -1e9
	for k in nd:
		if float(nd[k]) > bv:
			bv = float(nd[k]); best = str(k)
	return best


func budget_reason(preset: String) -> String:
	var st := S()
	match preset:
		"war": return "a war budget while the fighting lasts and readiness is %d." % int(st.readiness)
		"defence": return "defence first: readiness is %d%s." % [int(st.readiness), " after a war" if _war_recent() else ""]
		"absorption": return "absorption first: about %s immigrants a quarter%s." % [_fmt(sim.econ.expected_arrivals()), (", %.0f%% of residents in temporary housing" % (_transit_share() * 100.0)) if _transit_share() > 0.01 else ""]
		"development": return "development and water first: water supply covers %.0f%% of demand and the periphery needs investment." % (float(st.water.get("ratio", 1.0)) * 100.0)
		"education": return "education and science first: science is at %.0f%% of history's pace." % (_science_ratio() * 100.0)
		"balanced": return "a balanced budget: inflation is %.0f%% and the deficit needs restraint." % st.inflation
	return ""


func _transit_share() -> float:
	var t := 0.0; var r := 0.0
	for c in sim.active_cities():
		t += float(c.info.get("transit", 0.0)); r += c.residents
	return t / maxf(1.0, r)


func _valid_shares(shares: Dictionary) -> Dictionary:
	var out := {}
	var tot := 0.0
	for k in ENVELOPES:
		var v := clampf(float(shares.get(k, 0.25)), SHARE_MIN, SHARE_MAX)
		out[k] = v; tot += v
	for k in ENVELOPES:
		out[k] = snappedf(out[k] / tot, 0.001)
	return out


func set_budget(shares: Dictionary, preset := "custom") -> bool:
	## Passes this year's budget with the given split (each envelope 10-55%; normalised to 100%).
	var st := S()
	if not budget_due():
		return false
	var sh := _valid_shares(shares)
	var fy := budget_label_for(st.turn)
	var until := next_budget_turn(st.turn) - 1
	st.budget = {"fy": fy, "turn": st.turn, "until": until, "shares": sh, "preset": preset, "extra": {}, "reviewed": false,
		"recommended": recommended_preset()}
	var hist: Array = st.counters.get("budget_history", [])
	hist.append({"turn": st.turn, "fy": fy, "preset": preset, "shares": sh})
	st.counters["budget_history"] = hist
	var name := preset
	for p in gov().get("budget", {}).get("presets", []):
		if str(p["id"]) == preset: name = str(p.get("label", preset))
	var lines := effect_lines(budget_effects(sh) + _preset_extra(preset))
	st.stat_log.append({"turn": st.turn, "stat": "economy", "amount": 0.0, "reason": "State Budget %s: %s (%s)" % [fy, name, "; ".join(lines.map(func(l): return l["label"]))], "lasting": true})
	sim.notify("budget", "The Knesset passes the State Budget %s: %s." % [fy, name], {"fy": fy, "shares": sh})
	sim.refresh()
	return true


func choose_state_budget(index: int) -> bool:
	var ps := budget_presets()
	if index < 0 or index >= ps.size():
		return false
	return set_budget(ps[index].get("shares", {}), str(ps[index]["id"]))


func _need_envelope() -> String:
	var st := S()
	if _war_recent() or st.readiness < 50.0: return "defence"
	if float(st.water.get("ratio", 1.0)) < 1.0: return "development"
	if _transit_share() > 0.04 or sim.econ.expected_arrivals() > 20000.0: return "absorption"
	if _science_ratio() < 1.0: return "education"
	# otherwise the envelope the budget starved most
	var sh: Dictionary = st.budget.get("shares", {})
	var low := "education"; var lv := 9.0
	for k in ENVELOPES:
		if float(sh.get(k, 0.25)) < lv: lv = float(sh.get(k, 0.25)); low = k
	return low


func fiscal_state() -> String:
	## The year's state at the mid-year review: war, deficit, inflation, surplus or normal.
	var st := S()
	var net := float(st.counters.get("last_budget", {}).get("net", 0.0))
	var inc := maxf(30.0, float(st.counters.get("income_avg", 45.0)))
	if _war_recent():
		return "war"
	if st.gold < 0.0 or net < -0.05 * inc:
		return "deficit"
	if st.inflation > 30.0:
		return "inflation"
	if st.gold > 5.0 * inc and net >= 0.0:
		return "surplus"
	return "normal"


func _opt(id: String, label: String, desc: String, gold: int, effects: Array, extra := {}) -> Dictionary:
	var o := {"id": id, "label": label, "desc": desc, "gold": gold, "effects": effects, "effects_text": effects.map(func(l): return l["label"]),
		"fx": {"gold": gold} if gold != 0 else {}, "default": false}
	for k in extra: o[k] = extra[k]
	return o


func _g(n: int) -> Array:
	return [{"stat": "gold", "amount": n, "unit": "gold", "label": "%+d Gold now" % n, "good": n > 0}] if n != 0 else []


func review_options() -> Array:
	## The mid-year review's menu follows the fiscal state (fiscal_state()): in a deficit, cuts, a temporary surtax
	## or a hiring freeze; in war, money moved to defence, a defence supplement or a war loan; in high inflation, a
	## spending freeze or indexing the budget; with a surplus, a supplement, early debt repayment, a tax rebate or
	## a reserve fund. "Keep the budget as passed" is always there.
	var st := S()
	var gs: float = sim.events.gold_scale()
	var need := _need_envelope()
	var nd := envelope_def(need)
	var fs := fiscal_state()
	var sup_gold := int(round(30.0 * gs))
	var cut_gold := int(round(40.0 * gs))
	var debt: float = sim.econ.debt()
	var out := []
	var keep_desc := "No change: the ministries spend what the Knesset approved."
	match fs:
		"deficit": keep_desc = "No change: the deficit runs on (it pushes inflation up and the treasury down)."
		"inflation": keep_desc = "No change: the nominal budget is eroded by inflation of %.0f%% a year." % st.inflation
		"surplus": keep_desc = "No change: the surplus stays in the treasury."
	out.append(_opt("keep", "Keep the budget as passed", keep_desc, 0, [{"stat": "gold", "amount": 0, "unit": "", "label": "No change"}]))
	var cut_extra := {}
	for k in ENVELOPES: cut_extra[k] = -0.06
	var sup_line := effect_lines(budget_effects({}, {need: 0.15}).filter(func(x): return str(x["src"]) == "budget:" + need))
	match fs:
		"deficit":
			out.append(_opt("cut", "Across-the-board cuts", "+%d gold now; every envelope is trimmed until the year ends; -1 Civic Trust in every city." % cut_gold, cut_gold,
				effect_lines(budget_effects({}, cut_extra)) + _g(cut_gold) + [{"stat": "trust", "amount": -1, "unit": "trust", "label": "-1 Civic Trust in every city", "good": false}]))
			out.append(_opt("surtax", "A temporary income surtax", "+15% Gold for 4 quarters; -1 Amenity in every city meanwhile; the envelopes keep their money.", 0,
				[{"stat": "gold", "amount": 15, "unit": "%", "label": "+15% Gold for 4 quarters", "good": true}, {"stat": "amenity", "amount": -1, "unit": "amenities", "label": "-1 Amenity in every city for 4 quarters", "good": false}]))
			var fz := {}
			for k in ENVELOPES: fz[k] = -0.03
			out.append(_opt("freeze_hiring", "Freeze hiring and new programmes", "+%d gold now; every envelope is trimmed a little; no one's benefits are cut." % int(round(cut_gold * 0.5)), int(round(cut_gold * 0.5)),
				effect_lines(budget_effects({}, fz)) + _g(int(round(cut_gold * 0.5)))))
		"war":
			var mv := {"defence": 0.12, "absorption": -0.05, "development": -0.05, "education": -0.05}
			out.append(_opt("to_defence", "Move money from the civilian ministries to defence", "No new money: defence gains, the other three envelopes lose a little until the year ends.", 0, effect_lines(budget_effects({}, mv))))
			var wsg := int(round(45.0 * gs))
			out.append(_opt("war_supplement", "A defence supplement on top of the budget", "%d gold now; the defence envelope works as if it had about 10 points more of the budget until the year ends." % wsg, -wsg,
				effect_lines(budget_effects({}, {"defence": 0.25}).filter(func(x): return str(x["src"]) == "budget:defence")) + _g(-wsg)))
			var wl := int(round(minf(60.0 * gs, sim.econ.borrow_room())))
			if wl >= int(10.0 * gs):
				out.append(_opt("war_loan", "A war loan: bonds for the public and the diaspora", "+%d gold now, added to the public debt (repaid with interest over fifteen years)." % wl, 0,
					[{"stat": "gold", "amount": wl, "unit": "gold (a loan)", "label": "+%d Gold now, as debt repaid over 15 years with interest" % wl, "good": true}], {"borrow": wl}))
		"inflation":
			var frz := {}
			for k in ENVELOPES: frz[k] = -0.05
			out.append(_opt("nominal_freeze", "Freeze spending in shekels (let inflation shrink it)", "Every envelope loses a little real money; inflation pressure falls.", 0,
				effect_lines(budget_effects({}, frz)) + [{"stat": "inflation", "amount": -6, "unit": "percentage points", "label": "-6 points of inflation", "good": true}]))
			out.append(_opt("index_budget", "Index the budget to prices", "The ministries keep their real budgets: +1 Civic Trust everywhere, but inflation rises.", 0,
				[{"stat": "trust", "amount": 1, "unit": "trust", "label": "+1 Civic Trust in every city", "good": true}, {"stat": "inflation", "amount": 4, "unit": "percentage points", "label": "+4 points of inflation", "good": false}]))
			out.append(_opt("cut", "Across-the-board cuts", "+%d gold now; every envelope is trimmed until the year ends; -1 Civic Trust in every city." % cut_gold, cut_gold,
				effect_lines(budget_effects({}, cut_extra)) + _g(cut_gold) + [{"stat": "trust", "amount": -1, "unit": "trust", "label": "-1 Civic Trust in every city", "good": false}]))
		"surplus":
			var big := int(round(maxf(float(sup_gold) * 2.0, st.gold * 0.25)))
			out.append(_opt("supplement", "Supplementary budget for %s" % str(nd.get("name", need)).to_lower(), "%d gold now; the %s envelope works as if it had about 10 points more of the budget until the year ends." % [big, str(nd.get("short", need)).to_lower()], -big,
				effect_lines(budget_effects({}, {need: 0.25}).filter(func(x): return str(x["src"]) == "budget:" + need)) + _g(-big), {"envelope": need, "boost": 0.25}))
			if debt > 1.0:
				var rp := int(round(minf(debt, maxf(float(sup_gold) * 2.0, st.gold * 0.4))))
				out.append(_opt("repay_debt", "Repay foreign debt early", "%d gold now buys back debt: less interest and repayment every quarter from now on (debt %s)." % [rp, _fmt(debt)], -rp,
					_g(-rp) + [{"stat": "economy", "amount": rp, "unit": "debt", "label": "-%s public debt (lower interest from next quarter)" % _fmt(rp), "good": true}], {"repay": rp}))
			var reb := int(round(maxf(float(sup_gold) * 1.5, st.gold * 0.2)))
			out.append(_opt("tax_rebate", "Return the surplus in lower taxes", "%d gold now; +2 Civic Trust in every city and +3%% Production for 4 quarters." % reb, -reb,
				_g(-reb) + [{"stat": "trust", "amount": 2, "unit": "trust", "label": "+2 Civic Trust in every city", "good": true}, {"stat": "production", "amount": 3, "unit": "%", "label": "+3% Production for 4 quarters", "good": true}]))
			var fund := int(round(maxf(float(sup_gold) * 2.0, st.gold * 0.3)))
			out.append(_opt("reserve_fund", "Put it in a reserve fund", "%d gold now into a fund that returns about %d gold a quarter for three years." % [fund, int(round(fund * 1.25 / 12.0))], -fund,
				_g(-fund) + [{"stat": "gold", "amount": round(fund * 1.25 / 12.0), "unit": "gold/turn", "label": "+%d Gold per turn for 3 years" % int(round(fund * 1.25 / 12.0)), "good": true}], {"fund": fund}))
		_:
			out.append(_opt("supplement", "Supplementary budget for %s" % str(nd.get("name", need)).to_lower(), "%d gold now; the %s envelope works as if it had about 6 points more of the budget until the year ends." % [sup_gold, str(nd.get("short", need)).to_lower()], -sup_gold,
				sup_line + _g(-sup_gold), {"envelope": need, "boost": 0.15}))
			out.append(_opt("cut", "Across-the-board cuts", "+%d gold now; every envelope is trimmed until the year ends; -1 Civic Trust in every city." % cut_gold, cut_gold,
				effect_lines(budget_effects({}, cut_extra)) + _g(cut_gold) + [{"stat": "trust", "amount": -1, "unit": "trust", "label": "-1 Civic Trust in every city", "good": false}]))
	var rec := _review_rec(out, fs)
	for o in out:
		o["default"] = str(o["id"]) == rec
		o["fiscal_state"] = fs
	return out


func _avg_trust() -> float:
	var t := 0.0; var w := 0.0
	for c in sim.active_cities():
		t += c.trust * c.residents; w += c.residents
	return t / w if w > 0.0 else 75.0


func _review_rec(opts: Array, fs: String) -> String:
	var st := S()
	var ids := opts.map(func(o): return str(o["id"]))
	var gold_ok := func(o_id: String) -> bool:
		for o in opts:
			if str(o["id"]) == o_id: return st.gold + float(o.get("gold", 0)) > 0.0
		return false
	match fs:
		"deficit":
			if _avg_trust() >= 74.0 and "cut" in ids: return "cut"
			if st.inflation > 25.0 and "freeze_hiring" in ids: return "freeze_hiring"
			return "surtax"
		"war":
			if st.readiness < 70.0 and "war_supplement" in ids and gold_ok.call("war_supplement"): return "war_supplement"
			if st.readiness < 70.0 and "war_loan" in ids: return "war_loan"
			return "to_defence"
		"inflation":
			return "nominal_freeze" if st.inflation > 45.0 or _avg_trust() >= 70.0 else "index_budget"
		"surplus":
			if "repay_debt" in ids and sim.econ.debt() > 2.0 * maxf(30.0, float(st.counters.get("income_avg", 45.0))): return "repay_debt"
			if _avg_trust() < 72.0: return "tax_rebate"
			if _science_ratio() < 1.0 or float(st.water.get("ratio", 1.0)) < 1.0 or _transit_share() > 0.02: return "supplement"
			return "reserve_fund" if int(st.counters.get("review_fund_n", 0)) <= int(st.counters.get("review_sup_n", 0)) else "supplement"
	var needy := _science_ratio() < 1.0 or float(st.water.get("ratio", 1.0)) < 1.0 or _transit_share() > 0.02 or st.readiness < 55.0
	if st.gold > 4.0 * absf(float(opts[1].get("gold", 30))) and needy and "supplement" in ids: return "supplement"
	return "keep" if st.gold >= 0.0 else "cut"


func review_decision() -> Dictionary:
	var st := S()
	var fs := fiscal_state()
	var head := {"deficit": "The year is running a deficit (net %+d a quarter, treasury %s)." % [int(float(st.counters.get("last_budget", {}).get("net", 0.0))), _fmt(st.gold)],
		"war": "The country is at war or just out of one; the defence ministry asks for more.",
		"inflation": "Inflation is %.0f%% a year and eating the budget." % st.inflation,
		"surplus": "Revenue is ahead of plan: the treasury holds %s." % _fmt(st.gold),
		"normal": "Spending is on plan."}
	return {"type": "budget_review", "blocking": true, "label": "MID-YEAR BUDGET REVIEW %s" % str(st.budget.get("fy", "")), "fiscal_year": str(st.budget.get("fy", "")),
		"explain": "Half-way through the budget year the options depend on how the year is going: a deficit, a war, high inflation or a surplus.",
		"text": "Half-way through the budget year the Finance Ministry reports. %s" % str(head.get(fs, "")), "fiscal_state": fs,
		"options": review_options(), "budget": get_budget()}


func choose_budget_review(index: int) -> bool:
	var st := S()
	if not review_due():
		return false
	var opts := review_options()
	if index < 0 or index >= opts.size():
		return false
	var o: Dictionary = opts[index]
	var extra: Dictionary = st.budget.get("extra", {})
	var why := "Mid-year budget review: " + str(o["label"])
	match str(o["id"]):
		"supplement":
			var env := str(o.get("envelope", "education"))
			extra[env] = float(extra.get(env, 0.0)) + float(o.get("boost", 0.15))
			st.gold += float(o.get("gold", 0))
			st.counters["review_sup_n"] = int(st.counters.get("review_sup_n", 0)) + 1
		"cut":
			for k in ENVELOPES:
				extra[k] = float(extra.get(k, 0.0)) - 0.06
			st.gold += float(o.get("gold", 0))
			for c in sim.active_cities():
				c.trust = clampf(c.trust - 1.0, 0.0, 100.0)
			sim.stat_note("trust", -1.0, "Mid-year budget cuts")
		"freeze_hiring":
			for k in ENVELOPES:
				extra[k] = float(extra.get(k, 0.0)) - 0.03
			st.gold += float(o.get("gold", 0))
		"surtax":
			st.temp_effects.append({"type": "yield_pct", "yield": "gold", "pct": 15.0, "until": st.turn + 3, "src": "budget_review"})
			st.temp_effects.append({"type": "amenity", "amount": -1.0, "until": st.turn + 3, "src": "budget_review"})
		"to_defence":
			extra["defence"] = float(extra.get("defence", 0.0)) + 0.12
			for k in ["absorption", "development", "education"]:
				extra[k] = float(extra.get(k, 0.0)) - 0.05
		"war_supplement":
			extra["defence"] = float(extra.get("defence", 0.0)) + 0.25
			st.gold += float(o.get("gold", 0))
		"war_loan":
			sim.econ.borrow(float(o.get("borrow", 0)), "War loan (bonds)", 0.8)
		"nominal_freeze":
			for k in ENVELOPES:
				extra[k] = float(extra.get(k, 0.0)) - 0.05
			sim.shift_inflation(-6.0)
			sim.stat_note("inflation", -6.0, why)
		"index_budget":
			for c in sim.active_cities():
				c.trust = clampf(c.trust + 1.0, 0.0, 100.0)
			sim.shift_inflation(4.0)
			sim.stat_note("inflation", 4.0, why)
		"repay_debt":
			sim.econ.repay(float(o.get("repay", 0)))
		"tax_rebate":
			st.gold += float(o.get("gold", 0))
			for c in sim.active_cities():
				c.trust = clampf(c.trust + 2.0, 0.0, 100.0)
			st.temp_effects.append({"type": "yield_pct", "yield": "production", "pct": 3.0, "until": st.turn + 3, "src": "budget_review"})
			sim.stat_note("trust", 2.0, why)
		"reserve_fund":
			var f := float(o.get("fund", 0))
			st.gold -= f
			st.streams.append({"type": "gold", "amount": snappedf(f * 1.25 / 12.0, 0.1), "from": st.turn + 1, "until": st.turn + 12,
				"label": "Reserve fund returns", "src": "budget_review", "unscaled": true})
			st.counters["review_fund_n"] = int(st.counters.get("review_fund_n", 0)) + 1
	st.budget["extra"] = extra
	st.budget["reviewed"] = true
	st.budget["review"] = str(o["id"])
	var rh: Array = st.counters.get("review_history", [])
	rh.append({"turn": st.turn, "fy": str(st.budget.get("fy", "")), "id": str(o["id"]), "state": str(o.get("fiscal_state", ""))})
	st.counters["review_history"] = rh
	sim.notify("budget", "Mid-year budget review %s: %s." % [str(st.budget.get("fy", "")), str(o["label"])], {"review": o["id"]})
	sim.refresh()
	return true


func get_budget() -> Dictionary:
	## The budget in force: {fy, turn, until, preset, shares, extra, envelopes:[{id,name,share,mult,effects}], next_budget_turn, review_turn, reviewed}.
	var st := S()
	var envs := []
	var sh: Dictionary = st.budget.get("shares", {})
	var ex: Dictionary = st.budget.get("extra", {})
	for e in envelope_defs():
		var id := str(e["id"])
		var m := share_mult(float(sh.get(id, 0.25))) + float(ex.get(id, 0.0)) if not sh.is_empty() else 0.0
		envs.append({"id": id, "name": e.get("name", id), "share": float(sh.get(id, 0.25)), "mult": snappedf(m, 0.001),
			"effects": effect_lines(budget_effects({}, {id: m}).filter(func(x): return str(x["src"]) == "budget:" + id)).map(func(l): return l["label"])})
	return {"fy": st.budget.get("fy", ""), "turn": int(st.budget.get("turn", -1)), "until": int(st.budget.get("until", -1)), "preset": st.budget.get("preset", ""),
		"shares": sh.duplicate(), "extra": ex.duplicate(), "envelopes": envs, "next_budget_turn": next_budget_turn(st.turn - 1 if budget_due() else st.turn),
		"review_turn": int(st.budget.get("turn", -99)) + 2, "reviewed": st.budget.get("reviewed", false), "history": st.counters.get("budget_history", []).slice(-12)}


# ================================================================== ministers (Civ VI governors)

func minister_defs() -> Array:
	var y := SimDB.year_of(S().turn)
	return gov().get("ministries", []).filter(func(m): return y >= int(m.get("from", 0)))


func minister_def(id: String) -> Dictionary:
	for m in gov().get("ministries", []):
		if str(m.get("id", "")) == id:
			return m
	return {}


func minister_title(id: String) -> String:
	## The title as it was at the time (governments.json ministries[].title_eras: [{until, title}]).
	var md := minister_def(id)
	var y := SimDB.year_of(S().turn)
	for te in md.get("title_eras", []):
		if y <= int(te.get("until", 0)):
			return str(te.get("title", md.get("title", id)))
	return str(md.get("title", md.get("name", id)))


func titles() -> int:
	return int(S().counters.get("cabinet_titles", 0))


func next_title_in() -> int:
	## Quarters until the next yearly title (the quarter after the next Budget Law).
	var st := S()
	return maxi(1, next_budget_turn(st.turn) + 1 - st.turn)


func current_bloc() -> String:
	var t: Dictionary = sim.events.current_term()
	return str(PARTY_BLOC.get(str(t.get("party", "")), "labour"))


func accrue() -> void:
	## Called at the start of each turn. Turn 1: the provisional government's cabinet screen waits until turn 2
	## (turn 1 is the war). Each year the quarter after the Budget Law passes brings one title (the year's
	## ministerial programme), unless a government formed in the last three quarters.
	var st := S()
	if st.turn == 1 and not st.counters.has("cabinet_titles"):
		st.counters["cabinet_titles"] = CABINET_TITLES
		st.counters["minister_due"] = 2
		st.counters["minister_mode"] = "cabinet"
		st.counters["gov_party"] = str(sim.events.current_term().get("party", ""))
		return
	var bt := int(st.budget.get("turn", -99))
	if bt == st.turn - 1 and st.turn - int(st.counters.get("gov_turn", -99)) >= 3:
		var before := titles()
		st.counters["cabinet_titles"] = mini(TITLE_CAP, before + 1)
		st.counters["minister_due"] = st.turn
		st.counters["minister_mode"] = "promotion"
		if titles() > before:
			sim.notify("cabinet", "A cabinet title is available: the year's ministerial programme.", {"titles": titles()})


## Forks that already ask who forms the coalition (the coalition decision is skipped around them)
const COALITION_FORKS := ["fork_1949_first_coalition", "fork_1952_broad_coalition", "fork_1970_us_initiative_gahal", "fork_1984_unity_government",
	"fork_1999_barak_coalition", "fork_2013_equal_burden_coalition", "fork_2021_raam_coalition",
	# v3 fix3-story (A2): the v3 coalition forks (critic 1948-85: T47, T55, T84, T117, T134) and the later ones
	"fork_1959_collective_responsibility", "fork_1961_narrow_or_wider_coalition", "fork_1965_sabbath_and_coalition", "fork_1969_eshkol_successor",
	"fork_1977_aguda_terms", "fork_1981_religious_coalition_terms", "fork_1988_who_is_a_jew", "fork_2009_netanyahu_coalition"]


func on_new_government() -> void:
	## A new government brings new ministers. A change of governing party ends the outgoing ministers' programmes
	## (seats stay) and the cabinet sets three priorities; the same party re-forming (or a rotation) keeps them and
	## sets two more. Programmes whose era has passed end either way. Opens the cabinet screen this quarter.
	var st := S()
	var t: Dictionary = sim.events.current_term()
	var party := str(t.get("party", ""))
	var keep := party == str(st.counters.get("gov_party", "")) or str(t.get("how", "")) == "rotation"
	var y := SimDB.year_of(st.turn)
	var ended := 0
	var prev := []
	for mid in st.ministries:
		var kept := []
		for pid in st.ministries[mid].get("promotions", []):
			var p := promo_def(str(mid), str(pid))
			if keep and y <= int(p.get("until", 9999)):
				kept.append(pid)
			else:
				ended += 1
				prev.append("%s:%s" % [mid, pid])
		st.ministries[mid]["promotions"] = kept
		st.ministries[mid]["partner"] = ""
	st.counters["prev_promotions"] = prev
	if ended > 0:
		sim.notify("cabinet", ("The new government's ministers take office: %d programmes of the outgoing ministers end." if not keep else "The re-formed government keeps its ministers' programmes; %d that have run their course end.") % ended, {"ended": ended})
		st.stat_log.append({"turn": st.turn, "stat": "cohesion", "amount": 0.0, "reason": "New government: %d ministerial programmes ended" % ended, "lasting": true})
	st.counters["cabinet_titles"] = mini(TITLE_CAP, maxi(titles(), CABINET_TITLES_SAME if keep else CABINET_TITLES))
	st.counters["minister_due"] = st.turn
	st.counters["minister_mode"] = "cabinet"
	st.counters["gov_turn"] = st.turn
	st.counters["gov_party"] = party
	st.counters["gov_keep"] = keep
	var tn := st.turn
	for fid in COALITION_FORKS:
		var f = sim.db.forks.get(fid)
		if f != null and absi(SimDB.turn_of(f.get("date"), -99) - tn) <= 2:
			return   # the fork is this government's coalition decision
	st.counters["coalition_due"] = tn


func promo_def(mid: String, pid: String) -> Dictionary:
	for p in minister_def(mid).get("promotions", []):
		if str(p.get("id", "")) == pid:
			return p
	return {}


func promotion_available(mid: String, pid: String) -> String:
	var m = S().ministries.get(mid)
	if m == null: return "not appointed"
	var p := promo_def(mid, pid)
	if p.is_empty(): return "unknown"
	var taken: Array = m.get("promotions", [])
	if taken.has(pid): return "taken"
	if str(m.get("partner", "")) != "": return "held by a coalition partner this term"
	var y := SimDB.year_of(S().turn)
	if y < int(p.get("from", 0)): return "from %d" % int(p.get("from", 0))
	if y > int(p.get("until", 9999)): return "a programme of an earlier era"
	var tier := int(p.get("tier", 1))
	if tier > 1:
		var lower := false
		for q in taken:
			if int(promo_def(mid, str(q)).get("tier", 1)) == tier - 1: lower = true
		if not lower: return "needs a tier %d promotion" % (tier - 1)
	return ""


func best_seat(mid: String):
	## The autoplayer's seat city for a minister (as SimAI did for ministries).
	var cs: Array = sim.active_cities().filter(func(c): return not (c.kind in ["kibbutz", "moshav"]))
	if cs.is_empty(): return null
	cs.sort_custom(func(a, b): return a.pop() > b.pop())
	var city = cs[0]
	match mid:
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
		"defence":
			var best := 999
			for c in cs:
				if c.pop() >= 3:
					var d := 999
					for fp in sim.military.front_positions(): d = mini(d, SimHex.distance(c.pos(), fp))
					if d < best: best = d; city = c
	return city


func _effect_value(e: Dictionary) -> float:
	var st := S()
	var t := str(e.get("type", ""))
	var a := float(e.get("amount", e.get("pct", 0.0)))
	var water_need := 2.0 if float(st.water.get("ratio", 1.0)) < 1.0 else 1.0
	var ready_need := 1.6 if st.readiness < 50.0 else (0.5 if st.readiness > 90.0 else 1.0)
	var imm_need := 1.6 if sim.econ.expected_arrivals() > 15000.0 else 1.0
	match t:
		"readiness": return a * 0.8 * ready_need
		"yield_pct":
			var yv := float({"science": 1.2, "production": 1.0, "gold": 0.9, "culture": 0.7}.get(str(e.get("yield", "")), 0.6))
			if str(e.get("yield", "")) == "gold" and st.gold < 0.0: yv *= 3.0
			if str(e.get("yield", "")) == "science" and _science_ratio() < 0.95: yv *= 1.4
			return a * yv
		"yield_pct_city": return a * 0.12
		"housing": return a * 3.0 * imm_need * (1.0 + 25.0 * _transit_share())
		"housing_city": return a * 0.6
		"amenity": return a * 3.0
		"amenity_city": return a * 0.6
		"growth_pct": return a * 1.2
		"growth_pct_city": return a * 0.1
		"retention": return a * 2.0 * imm_need
		"trust": return a * 3.0 * (1.4 if _avg_trust() < 70.0 else 1.0)
		"water_supply": return a * 0.05 * water_need
		"water_supply_pct": return a * 0.8 * water_need
		"water_demand_pct": return -a * 0.8 * water_need
		"cohesion_per_turn": return a * 3.0
		"standing_per_turn": return a * 30.0
		"trade_route_capacity": return a * 3.0
		"war_weariness_pct": return -a * (0.12 if _war_recent() else 0.05)
		"inflation": return -a * (1.0 if st.inflation > 20.0 else 0.4)
		"city_defense": return a * 0.2
		"city_yield": return a * 2.0
	return 0.5


func _effects_value(effects: Array) -> float:
	var v := 0.0
	for e in effects:
		v += _effect_value(e)
	return v


func _promo_effects(mid: String, pid: String) -> Array:
	var out := []
	var seat := int(S().ministries.get(mid, {}).get("city", 0))
	for e in promo_def(mid, pid).get("effects", []):
		var ee: Dictionary = e.duplicate()
		if str(ee.get("type", "")).ends_with("_city"): ee["city"] = seat
		out.append(ee)
	return out


func _base_effects(mid: String, seat: int) -> Array:
	var out := []
	for e in minister_def(mid).get("effects", []):
		var ee: Dictionary = e.duplicate()
		ee["city"] = seat
		out.append(ee)
	return out


func minister_options() -> Array:
	## Every way to spend a cabinet title now: appoint an unappointed minister (to the recommended seat) or buy an
	## available promotion of this era. Value includes the governing bloc's programme (a Labour cabinet favours
	## development towns and public housing, a Likud cabinet privatisation and urban renewal...) and a discount on
	## what the outgoing government had done. Best value first.
	var st := S()
	var bloc := current_bloc()
	var prev: Array = st.counters.get("prev_promotions", [])
	var out := []
	for m in minister_defs():
		var mid := str(m["id"])
		var title := minister_title(mid)
		if not st.ministries.has(mid):
			var seat = best_seat(mid)
			if seat == null: continue
			var eff := _base_effects(mid, seat.id)
			var lines := effect_lines(eff)
			out.append({"id": "appoint:" + mid, "kind": "appoint", "minister": mid, "city": seat.id, "label": "Appoint a %s (seat: %s)" % [title, seat.name],
				"desc": "%s %s" % [str(m.get("desc", "")), "Reassign the seat later for free (2 quarters to settle in)."], "effects": lines,
				"effects_text": lines.map(func(l): return l["label"]), "value": _effects_value(eff) + 6.0, "fx": {}})
		else:
			for p in m.get("promotions", []):
				var pid := str(p["id"])
				if promotion_available(mid, pid) != "": continue
				var eff2 := _promo_effects(mid, pid)
				var lines2 := effect_lines(eff2)
				var v := _effects_value(eff2)
				var tags: Array = p.get("tags", [])
				if bloc in tags: v = v * 1.3 + 1.5
				if prev.has("%s:%s" % [mid, pid]): v *= 0.75
				out.append({"id": "promote:%s:%s" % [mid, pid], "kind": "promote", "minister": mid, "promotion": pid, "tier": int(p.get("tier", 1)),
					"label": "%s: %s" % [title, str(p.get("name", pid))], "desc": str(p.get("desc", "")), "programme_of": tags,
					"effects": lines2, "effects_text": lines2.map(func(l): return l["label"]), "value": snappedf(v, 0.01), "fx": {}})
	out.sort_custom(func(a, b): return float(a["value"]) > float(b["value"]))
	var rec := recommended_set(out, picks())
	for o in out:
		o["default"] = rec.has(str(o["id"]))
	return out


func recommended_set(opts: Array, n: int) -> Array:
	## The Recommended picks for n titles: the best options, at most one per minister (a cabinet spreads its
	## priorities across ministries).
	var out := []
	var used := {}
	for o in opts:
		if out.size() >= n: break
		if used.has(str(o["minister"])): continue
		used[str(o["minister"])] = true
		out.append(str(o["id"]))
	return out


func picks() -> int:
	return maxi(1, titles())


func minister_due() -> bool:
	## A title is waiting (and not before its screen is due: turn 1's cabinet waits for turn 2).
	return titles() > 0 and S().turn >= int(S().counters.get("minister_due", 0)) and not _raw_options_empty()


func _raw_options_empty() -> bool:
	var st := S()
	for m in minister_defs():
		var mid := str(m["id"])
		if not st.ministries.has(mid): return false
		for p in m.get("promotions", []):
			if promotion_available(mid, str(p["id"])) == "": return false
	return true


func minister_blocking(_other_story := false) -> bool:
	## The cabinet screen blocks once: in the quarter a government forms (or the yearly title arrives), until the
	## titles are spent or one pick is made. Titles left unspent wait in the cabinet panel (non-blocking); the
	## menu never blocks just to fill a quiet quarter.
	var st := S()
	return int(st.counters.get("minister_due", -1)) == st.turn and int(st.counters.get("minister_done", -1)) != st.turn


func minister_decision(blocking: bool) -> Dictionary:
	var st := S()
	var n := titles()
	var mode := str(st.counters.get("minister_mode", "promotion")) if int(st.counters.get("minister_due", -1)) == st.turn else "spare"
	var t: Dictionary = sim.events.current_term()
	var pm := str(t.get("pm", "the prime minister"))
	var label := "CABINET: APPOINT OR PROMOTE A MINISTER (%d title%s)" % [n, "" if n == 1 else "s"]
	var text := "A cabinet title is available. Appoint a minister to a seat city (a local effect, like a Civ VI governor) or promote one (a national programme of the era)."
	if mode == "cabinet":
		label = "CABINET: %s'S MINISTERS TAKE OFFICE (%d title%s)" % [pm.to_upper(), n, "" if n == 1 else "s"]
		text = "%s's government takes office. Choose up to %d priorities in one go: appoint ministers to seat cities or launch their programmes. %s" % [pm, n,
			"The same party carries on, so the outgoing ministers' programmes continue." if bool(st.counters.get("gov_keep", false)) else "Programmes of the era are listed; the governing party favours its own (marked)."]
	elif mode == "promotion":
		label = "CABINET: THE YEAR'S MINISTERIAL PROGRAMME (%d title%s)" % [n, "" if n == 1 else "s"]
		text = "With the Budget Law passed, the cabinet can fund one more ministerial programme this year, or appoint a minister."
	var opts := minister_options()
	return {"type": "minister", "blocking": blocking, "label": label, "mode": mode, "picks": n, "titles": n,
		"recommended": opts.filter(func(o): return o.get("default", false)).map(func(o): return str(o["id"])),
		"explain": "Ministers work like Civ VI governors: a title appoints one to a seat city or buys a promotion (a national programme of the era). Each new government sets its priorities on one screen; once a year the cabinet funds one more programme.",
		"text": text, "options": opts, "ministers": get_ministers(), "government": t}


func _apply_option(o: Dictionary) -> bool:
	if str(o["kind"]) == "appoint":
		return appoint(str(o["minister"]), int(o["city"]))
	return promote(str(o["minister"]), str(o["promotion"]))


func choose_minister(index: int) -> bool:
	## Spends one title on option `index`. The minister screen then stops blocking for this quarter (spend the rest
	## with choose_ministers, or later in the cabinet panel).
	var opts := minister_options()
	if index < 0 or index >= opts.size():
		return false
	var ok := _apply_option(opts[index])
	if ok:
		S().counters["minister_done"] = S().turn
		_log_minister([str(opts[index]["id"])], opts)
	return ok


func choose_ministers(picks_in: Array) -> bool:
	## The cabinet multi-pick: option indices (into minister_options() as offered) or option ids, up to the titles
	## waiting. Applied appointments first, then promotions by tier (a tier-2 pick may build on a tier-1 pick made
	## in the same screen). Returns true if at least one was applied; the screen is then done for this quarter.
	var opts := minister_options()
	var ids := []
	for p in picks_in:
		if typeof(p) == TYPE_INT or typeof(p) == TYPE_FLOAT:
			var i := int(p)
			if i >= 0 and i < opts.size(): ids.append(str(opts[i]["id"]))
		else:
			ids.append(str(p))
	ids.sort_custom(func(a, b): return _id_order(a) < _id_order(b))
	var done := []
	for id in ids:
		if titles() < 1: break
		for o in minister_options():
			if str(o["id"]) == id:
				if _apply_option(o): done.append(id)
				break
	if done.is_empty():
		return false
	S().counters["minister_done"] = S().turn
	_log_minister(done, opts)
	return true


func _id_order(id: String) -> int:
	if id.begins_with("appoint:"): return 0
	var parts := id.split(":")
	if parts.size() >= 3: return int(promo_def(parts[1], parts[2]).get("tier", 1))
	return 5


func _log_minister(ids: Array, opts: Array) -> void:
	## Recommended-pick bookkeeping for the pacing report (how often the Recommended pick was a given option).
	var st := S()
	var rec := opts.filter(func(o): return o.get("default", false)).map(func(o): return str(o["id"]))
	var mh: Array = st.counters.get("minister_history", [])
	mh.append({"turn": st.turn, "picked": ids, "recommended": rec})
	st.counters["minister_history"] = mh.slice(maxi(0, mh.size() - 120))


func appoint(mid: String, city_id: int) -> bool:
	## Appoints a minister (spends a title) or, if already appointed, moves the seat (free; 2 quarters to settle).
	var st := S()
	var c = sim.city_by_id(city_id)
	if c == null or not c.active or minister_def(mid).is_empty():
		return false
	if SimDB.year_of(st.turn) < int(minister_def(mid).get("from", 0)):
		return false
	if st.ministries.has(mid):
		if int(st.ministries[mid].get("city", 0)) == city_id:
			return false
		st.ministries[mid]["city"] = city_id
		st.ministries[mid]["since"] = st.turn
		sim.refresh()
		return true
	if titles() < 1:
		return false
	st.counters["cabinet_titles"] = titles() - 1
	st.ministries[mid] = {"city": city_id, "since": st.turn, "promotions": [], "appointed": st.turn}
	sim.notify("cabinet", "%s appointed, seated in %s." % [minister_title(mid), c.name], {"minister": mid, "city": city_id})
	sim.refresh()
	return true


func promote(mid: String, pid: String) -> bool:
	var st := S()
	if titles() < 1 or promotion_available(mid, pid) != "":
		return false
	st.counters["cabinet_titles"] = titles() - 1
	var m: Dictionary = st.ministries[mid]
	var pr: Array = m.get("promotions", [])
	pr.append(pid)
	m["promotions"] = pr
	var p := promo_def(mid, pid)
	sim.notify("cabinet", "%s: %s." % [minister_title(mid), str(p.get("name", pid))], {"minister": mid, "promotion": pid})
	st.stat_log.append({"turn": st.turn, "stat": "cohesion", "amount": 0.0, "reason": "Minister promoted: %s, %s (%s)" % [minister_title(mid), str(p.get("name", pid)),
		"; ".join(effect_lines(_promo_effects(mid, pid)).map(func(l): return l["label"]))], "lasting": true})
	sim.refresh()
	return true


func get_ministers() -> Array:
	## The cabinet for the governor screen: [{id, name, title, appointed, city, city_name, established, partner,
	##   base:[effects], promotions:[{id, name, tier, desc, taken, available, reason, effects, from, until, programme_of}]}].
	var st := S()
	var out := []
	for m in minister_defs():
		var mid := str(m["id"])
		var cur = st.ministries.get(mid)
		var seat := int(cur.get("city", 0)) if cur != null else 0
		var c = sim.city_by_id(seat)
		var promos := []
		var y := SimDB.year_of(st.turn)
		for p in m.get("promotions", []):
			var pid := str(p["id"])
			var why := promotion_available(mid, pid)
			if why != "taken" and (y < int(p.get("from", 0)) or y > int(p.get("until", 9999))):
				continue   # other eras' programmes are not listed
			var ef := []
			for e in p.get("effects", []): ef.append(e)
			promos.append({"id": pid, "name": p.get("name", pid), "tier": int(p.get("tier", 1)), "desc": p.get("desc", ""), "taken": why == "taken",
				"available": why == "", "reason": why, "effects": effect_lines(ef).map(func(l): return l["label"]),
				"from": int(p.get("from", 0)), "until": int(p.get("until", 9999)), "programme_of": p.get("tags", [])})
		out.append({"id": mid, "name": m.get("name", mid), "title": minister_title(mid), "appointed": cur != null,
			"city": seat, "city_name": c.name if c != null else "", "established": cur != null and st.turn - int(cur.get("since", 0)) >= 2,
			"partner": str(cur.get("partner", "")) if cur != null else "", "base": effect_lines(minister_def(mid).get("effects", [])).map(func(l): return l["label"]),
			"desc": m.get("desc", ""), "promotions": promos, "source": m.get("source", [])})
	return out


func active_mods() -> Array:
	## Modifiers from the budget in force and from ministers (seat effects once established, promotions at once).
	var st := S()
	var out := []
	if not st.budget.is_empty() and int(st.budget.get("until", -1)) >= st.turn and int(st.budget.get("turn", 99999)) <= st.turn:
		for e in budget_effects(st.budget.get("shares", {}), st.budget.get("extra", {})):
			out.append(e)
		for e in _preset_extra(str(st.budget.get("preset", ""))):
			out.append(e)
	for mid in st.ministries:
		var m: Dictionary = st.ministries[mid]
		var seat := int(m.get("city", 0))
		if st.turn - int(m.get("since", 0)) >= 2:
			for e in _base_effects(str(mid), seat):
				e["src"] = "ministry:" + str(mid)
				out.append(e)
		for pid in m.get("promotions", []):
			for e2 in _promo_effects(str(mid), str(pid)):
				e2["src"] = "minister:%s:%s" % [mid, pid]
				out.append(e2)
	for cd in st.counters.get("coalition_terms", []):
		if int(cd.get("until", 0)) >= st.turn:
			for e3 in cd.get("effects", []):
				var ee: Dictionary = e3.duplicate(); ee["src"] = "coalition:" + str(cd.get("partner", ""))
				out.append(ee)
	return out


# ================================================================== coalition deals

func coalition_due() -> bool:
	var st := S()
	return int(st.counters.get("coalition_due", -1)) == st.turn and not coalition_partners().is_empty()


func coalition_partners() -> Array:
	## The partners of this government (governments.json terms[].partners: the parties that joined, with their
	## leader and a cite; terms[].declined: parties that negotiated and stayed out). Each entry is normalised to
	## {id, label, party, bloc, advocate, ministries, portfolios, effects, gold_per_turn, source, cite, historical, desc}.
	## Falls back to the era's generic blocs (coalition_partners) only where a term has no partner data.
	var st := S()
	var t: Dictionary = sim.events.current_term()
	var blocs: Dictionary = gov().get("coalition_blocs", {})
	var out := []
	var first := true
	for key in ["partners", "declined"]:
		for p in t.get(key, []):
			var b: Dictionary = blocs.get(str(p.get("bloc", "")), {})
			var e := {"id": str(p.get("id", p.get("party", "partner"))), "party": str(p.get("party", "")), "bloc": str(p.get("bloc", "")),
				"advocate": str(p.get("advocate", "")), "ministries": p.get("ministries", []), "portfolios": p.get("portfolios", []),
				"effects": p.get("effects", b.get("effects", [])), "gold_per_turn": float(p.get("gold_per_turn", b.get("gold_per_turn", -3))),
				"source": p.get("source", []), "cite": p.get("cite", []), "historical": key == "partners", "main": key == "partners" and first,
				"note": str(p.get("note", "")), "desc": str(p.get("desc", b.get("desc", "")))}
			e["label"] = str(p.get("label", ("Bring in %s (%s)" % [e["party"], e["advocate"]]) if key == "partners" else ("Court %s instead (%s)" % [e["party"], e["advocate"]])))
			if key == "partners": first = false
			out.append(e)
	if not out.is_empty():
		return out
	var y := SimDB.year_of(st.turn)
	for p in gov().get("coalition_partners", []):
		if y < int(p.get("from", 0)) or y > int(p.get("until", 9999)):
			continue
		var e2: Dictionary = p.duplicate()
		e2["ministries"] = [str(p.get("portfolio", ""))] if str(p.get("portfolio", "")) != "" else []
		e2["historical"] = false
		out.append(e2)
	return out


func _price_text(p: Dictionary) -> Array:
	## [text, promotions lost]
	var st := S()
	var mins: Array = p.get("ministries", [])
	var lost := 0
	var names := []
	for mid in mins:
		if minister_def(str(mid)).is_empty(): continue
		names.append(minister_title(str(mid)).replace("Minister of ", ""))
		if st.ministries.has(str(mid)):
			lost += st.ministries[str(mid)].get("promotions", []).size()
	var real: Array = p.get("portfolios", [])
	var txt := ""
	if names.is_empty():
		txt = "Price: %s (outside the cabinet's seven programme ministries) and a sector budget" % (", ".join(real) if not real.is_empty() else "minor portfolios")
	else:
		txt = "Price: the %s portfolio%s%s" % [" and ".join(names), "" if names.size() == 1 else "s", (" (%d programme%s lost)" % [lost, "" if lost == 1 else "s"]) if lost > 0 else ""]
		var others := real.filter(func(x): return not _maps_to_ours(str(x)))
		if not others.is_empty(): txt += ", plus " + ", ".join(others)
	return [txt, lost]


func _maps_to_ours(portfolio: String) -> bool:
	var p := portfolio.to_lower()
	for k in ["defence", "defense", "finance", "absorption", "housing", "agriculture", "education", "health"]:
		if p.contains(k): return true
	return false


func coalition_options() -> Array:
	var gs: float = sim.events.gold_scale()
	var out := []
	var parts := coalition_partners()
	for p in parts:
		var pr := _price_text(p)
		var eff: Array = p.get("effects", [])
		var lines := effect_lines(eff)
		var gold := int(round(float(p.get("gold_per_turn", 0)) * gs))
		if gold != 0:
			lines.append({"stat": "gold", "amount": gold, "unit": "gold/turn", "label": "%+d Gold per turn (sector budget)" % gold, "good": gold > 0})
		var hist_note := "" if p.get("historical", false) else " (history: this party stayed out)"
		out.append({"id": str(p["id"]), "label": str(p.get("label", p["id"])), "desc": "%s %s.%s" % [str(p.get("desc", "")), str(pr[0]), hist_note],
			"party": str(p.get("party", "")), "portfolio": ",".join(p.get("ministries", [])), "ministries": p.get("ministries", []), "portfolios": p.get("portfolios", []),
			"promotions_lost": int(pr[1]), "effects": lines, "effects_text": lines.map(func(l): return l["label"]) + [str(pr[0])], "advocate": str(p.get("advocate", "")),
			"historical": bool(p.get("historical", false)), "fx": {}, "gold_per_turn": gold, "source": p.get("source", []), "cite": p.get("cite", []), "note": str(p.get("note", "")), "default": false})
	# recommended: the partner whose terms are worth most against the programmes it costs
	var best := 0; var bv := -1e9
	for i in range(out.size()):
		var v := _effects_value(parts[i].get("effects", [])) * 2.0 - 2.5 * float(out[i]["promotions_lost"]) + float(parts[i].get("gold_per_turn", 0)) * 0.3
		if v > bv: bv = v; best = i
	if not out.is_empty():
		out[best]["default"] = true
	return out


func _how_text(t: Dictionary) -> Array:
	## [explain, text] worded for how the government formed (election, succession, rotation, unity, reformed).
	var pm := str(t.get("pm", "the prime minister"))
	var party := str(t.get("party", ""))
	var el := str(t.get("election", ""))
	match str(t.get("how", "election")):
		"succession":
			return ["A new prime minister without an election inherits the coalition and must renew its deals.",
				"%s takes over as prime minister without an election and must hold the coalition together. Which partner's demands come first in the new government?" % pm]
		"rotation":
			return ["Under a rotation agreement the premiership changes hands and the partners renegotiate.",
				"Under the rotation agreement %s becomes prime minister. The partners renegotiate their portfolios and budgets." % pm]
		"unity":
			return ["The opposition joins a national unity government without an election.",
				"%s brings the opposition into a national unity government. Who joins, and at what price?" % pm]
		"reformed":
			return ["The coalition broke up; the prime minister rebuilds it without an election.",
				"The coalition has broken up. %s rebuilds a majority without an election: which partner is brought in?" % pm]
	return ["After an election the prime minister needs partners. Each asks for portfolios and a budget for its voters.",
		"After the election%s, %s%s needs partners for a Knesset majority. Each partner asks for portfolios and a budget for its voters." % [(" of " + SimDB.date_label(SimDB.turn_of(el, 1))) if el != "" else "", pm, (" (%s)" % party) if party != "" else ""]]


func coalition_decision() -> Dictionary:
	var t: Dictionary = sim.events.current_term()
	var ht := _how_text(t)
	return {"type": "coalition", "blocking": true, "label": "COALITION TALKS: %s FORMS A GOVERNMENT" % str(t.get("pm", "")).to_upper(),
		"explain": ht[0], "text": ht[1], "how": str(t.get("how", "election")),
		"options": coalition_options(), "government": t}


func choose_coalition(index: int) -> bool:
	var st := S()
	if not coalition_due():
		return false
	var opts := coalition_options()
	if index < 0 or index >= opts.size():
		return false
	var o: Dictionary = opts[index]
	var until := _term_end_turn()
	var terms: Array = st.counters.get("coalition_terms", [])
	if str(o["id"]) == "narrow":
		st.counters["cabinet_titles"] = maxi(0, titles() - 1)
		terms.append({"partner": "narrow", "from": st.turn, "until": until, "effects": [{"type": "cohesion_per_turn", "amount": -0.5}]})
	else:
		var p: Dictionary = {}
		for pp in coalition_partners():
			if str(pp["id"]) == str(o["id"]): p = pp
		for mid in p.get("ministries", []):
			if st.ministries.has(str(mid)):
				st.ministries[str(mid)]["promotions"] = []
				st.ministries[str(mid)]["partner"] = str(p.get("party", p.get("label", p["id"])))
				st.ministries[str(mid)]["since"] = st.turn
		terms.append({"partner": str(p["id"]), "from": st.turn, "until": until, "effects": p.get("effects", [])})
		if int(o.get("gold_per_turn", 0)) != 0:
			st.streams.append({"type": "gold", "amount": float(o["gold_per_turn"]), "from": st.turn, "until": until, "label": "Coalition agreement: " + str(p.get("party", p.get("label", p["id"]))), "src": "coalition", "unscaled": true})
	st.counters["coalition_terms"] = terms.slice(maxi(0, terms.size() - 12))
	st.counters["coalition_due"] = -1
	var hist: Array = st.counters.get("coalition_history", [])
	var rec := ""
	for oo in opts:
		if oo.get("default", false): rec = str(oo["id"])
	hist.append({"turn": st.turn, "partner": str(o["id"]), "label": str(o["label"]), "pm": str(sim.events.current_term().get("pm", "")),
		"historical": bool(o.get("historical", false)), "recommended": rec})
	st.counters["coalition_history"] = hist
	st.stat_log.append({"turn": st.turn, "stat": "cohesion", "amount": 0.0, "reason": "Coalition agreement: %s (%s)" % [str(o["label"]), "; ".join(o["effects_text"])], "lasting": true})
	sim.notify("cabinet", "Coalition agreement: %s." % str(o["label"]), {"partner": o["id"]})
	sim.refresh()
	return true


func _term_end_turn() -> int:
	var terms: Array = gov().get("terms", [])
	var i := S().gov_term
	if i >= 0 and i + 1 < terms.size():
		return SimDB.turn_of(terms[i + 1].get("start"), SimDB.LAST_TURN) - 1
	return SimDB.LAST_TURN


# ================================================================== decisions and resolution

func decisions(other_story := false) -> Array:
	var out := []
	if coalition_due():
		out.append(coalition_decision())
	if budget_due():
		out.append(budget_decision())
	if review_due():
		out.append(review_decision())
	if minister_due():
		out.append(minister_decision(minister_blocking(other_story)))
	# v3 (sim-endgame): national programmes (a programme opens, or the yearly "invest the surplus")
	if sim.endgame != null and sim.endgame.decision_due():
		out.append(sim.endgame.programme_decision())
	return out


func auto_resolve() -> void:
	## Forced end of turn: the recommended picks.
	if sim.endgame != null:
		sim.endgame.auto_resolve()
	if coalition_due():
		var co := coalition_options()
		for i in range(co.size()):
			if co[i].get("default", false): choose_coalition(i); break
		if coalition_due(): S().counters["coalition_due"] = -1
	if budget_due():
		var ps := budget_presets()
		var rec := recommended_preset()
		var done := false
		for i in range(ps.size()):
			if str(ps[i]["id"]) == rec: done = choose_state_budget(i); break
		if not done: set_budget({}, "balanced")
	if review_due():
		var ro := review_options()
		for i in range(ro.size()):
			if ro[i].get("default", false): choose_budget_review(i); break
		if review_due(): S().budget["reviewed"] = true
