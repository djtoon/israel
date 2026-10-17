class_name SimCollapse
extends RefCounted
## v3 item 13 (fix-v3a): soft fail states, the early game-over endings for a collapse of the state.
## Three collapses (data/endings.json, entries with "kind": "collapse"):
##  - collapse_fiscal: the public debt and overdraft stand past the lenders' limit while inflation runs above a
##    hyperinflation line;
##  - collapse_trust: national Civic Trust below a floor while a large share of the population lives in cities in
##    unrest, with repeated government crises;
##  - collapse_military: in a war, Readiness below a breaking point while strikes on towns run far beyond history's.
## Each quarter (after the quarter is played) every collapse's conditions are measured. While all of them hold, its
## strain grows by one quarter; when they do not, it eases (recovery). From `warn_at` quarters of strain the state
## is in danger: the top bar shows it, an advisor card and the notification rail warn once per episode, and the
## Ending outlook shows how close it is. At the difficulty's `quarters` the game ends early with that collapse,
## its own "what went wrong" epilogue and the normal results screen (no memorial: that belongs to 7 October 2023).
## History's ghost never collapses. State: state.counters["collapse"] (saved with the game).

const TRUST_CRISIS_EVERY := 4   # a government crisis at the first warning and then every 4 quarters of strain

var sim


func _init(s) -> void:
	sim = s


func S() -> GameState:
	return sim.state


# ================================================================== data

static func defs() -> Array:
	return SimEndgame.data()["endings"].get("endings", []).filter(func(e): return str(e.get("kind", "")) == "collapse")


static func def(id: String) -> Dictionary:
	for e in defs():
		if str(e.get("id", "")) == id:
			return e
	return {}


static func validate() -> Array:
	## Data errors in the collapse entries of endings.json (sim_test --validate-only).
	var errs := []
	var ids := []
	for e in defs():
		var id := str(e.get("id", ""))
		ids.append(id)
		for k in ["name", "summary", "conditions", "quarters", "warn_at", "advice", "epilogue"]:
			if not e.has(k): errs.append("collapse %s: missing \"%s\"" % [id, k])
		for d in ["easy", "normal", "hard", "historian"]:
			var q := int(e.get("quarters", {}).get(d, 0))
			if q - int(e.get("warn_at", 1)) < 4:
				errs.append("collapse %s: %s gives under 4 quarters of warning" % [id, d])
		for c in e.get("conditions", []):
			if not (c.has("min") or c.has("max")): errs.append("collapse %s condition %s: needs min or max" % [id, c.get("id", "")])
	for want in ["collapse_fiscal", "collapse_trust", "collapse_military"]:
		if not (want in ids): errs.append("endings.json: collapse ending %s missing" % want)
	return errs


# ================================================================== state

func cs() -> Dictionary:
	if not S().counters.has("collapse") or typeof(S().counters["collapse"]) != TYPE_DICTIONARY:
		S().counters["collapse"] = {"strain": {}, "peak": {}, "warned": {}, "episodes": {}, "first_warn": {}, "gov_crises": [], "ended": "", "ended_turn": -1,
			"probe": {}, "log": [], "war_seen": ""}
	return S().counters["collapse"]


func active() -> bool:
	## Collapses apply to the player's game, never to history's ghost.
	return S() != null and S().mode != "historical"


func ended() -> bool:
	return S() != null and str(cs().get("ended", "")) != ""


func ended_id() -> String:
	return str(cs().get("ended", "")) if S() != null else ""


func strain(id: String) -> int:
	return int(cs()["strain"].get(id, 0))


func diff_id() -> String:
	return sim.endgame.difficulty_id() if sim.endgame != null else "normal"


func limit(e: Dictionary) -> int:
	## Quarters of strain that end the game on this difficulty.
	var q: Dictionary = e.get("quarters", {})
	return int(q.get(diff_id(), q.get("normal", 12)))


func target(c: Dictionary) -> float:
	## A condition's threshold on this difficulty (data "difficulty": {easy: x, hard: y, historian: z} overrides).
	var base := float(c.get("min", c.get("max", 0.0)))
	return float(c.get("difficulty", {}).get(diff_id(), base))


# ================================================================== metrics

func war_crisis():
	## The war under way this quarter (main fighting or a quarter with front orders), or null. Operations and
	## shows of force do not count.
	for cr in S().crises:
		if not (cr.get("active", true) and cr.has("war_id")):
			continue
		var k: String = sim.military.crisis_kind(cr)
		if k in ["operation", "deterrence"]:
			continue
		if sim.military.is_order_turn(cr) or S().turn < int(cr.get("end", 0)):
			return cr
	return null


func _ghost_strikes_to_date() -> float:
	var by: Dictionary = sim.db.ghost.get("endgame", {}).get("town_strikes_by_turn", {})
	var g := 0.0
	for k in by:
		if int(k) <= S().turn: g = maxf(g, float(by[k]))
	return g


func unrest_share() -> float:
	## Share of residents living in cities in unrest or revolt (amenities) or alienated from the state (trust under 26).
	var bad := 0.0; var tot := 0.0
	for c in sim.active_cities():
		tot += c.residents
		if str(c.info.get("amenity_state", "")) in ["unrest", "revolt"] or c.trust < 26.0:
			bad += c.residents
	return bad / tot if tot > 0.0 else 0.0


func gov_crises_recent(years := 3) -> int:
	var n := 0
	for t in cs().get("gov_crises", []):
		if int(t) > S().turn - 4 * years: n += 1
	return n


func metric(m: String) -> float:
	match m:
		"debt_over_cap":
			return (sim.econ.debt() + maxf(0.0, -S().gold)) / maxf(1.0, sim.econ.debt_cap())
		"inflation":
			return S().inflation
		"avg_trust":
			return sim.score.avg_trust()
		"unrest_share":
			return unrest_share()
		"gov_crises":
			return float(gov_crises_recent(3))
		"at_war":
			return 1.0 if war_crisis() != null else 0.0
		"readiness":
			return S().readiness
		"town_strikes_excess":
			return float(sim.endgame._town_strikes()) - _ghost_strikes_to_date()
		"town_strikes_ratio":
			return float(sim.endgame._town_strikes()) / maxf(1.0, _ghost_strikes_to_date())
	return 0.0


func _met(c: Dictionary, v: float) -> bool:
	var t := target(c)
	return v >= t if c.has("min") else v <= t


func _metric_text(c: Dictionary, v: float) -> String:
	match str(c.get("unit", "")):
		"x the limit": return "%d%% of the limit" % int(round(v * 100.0))
		"%": return ("%.1f%%" % v) if absf(v) < 10.0 else ("%d%%" % int(round(v)))
		"share": return "%d%%" % int(round(v * 100.0))
		"strikes": return "%+d" % int(round(v))
		"flag": return "yes" if v >= 0.5 else "no"
	return "%d" % int(round(v))


# ================================================================== each quarter

func process_turn() -> void:
	## Called by Sim.end_turn after the quarter is played (before the turn counter moves on).
	if not active() or ended():
		return
	var st := cs()
	_probe()
	for e in defs():
		var id := str(e["id"])
		var conds: Array = e.get("conditions", [])
		var all := true
		for c in conds:
			if c.get("final", false):
				continue   # checked only when the strain reaches the limit (e.g. repeated government crises)
			if not _met(c, metric(str(c["metric"]))):
				all = false
		var s := strain(id)
		var before := s
		if all:
			var imp := _improvement(id)
			if imp >= 2:
				s = maxi(0, s - 1)   # v3 fix3-econ: a real improvement (the budget back in surplus) eases the danger even while the conditions hold
			elif imp == 0:
				s += 1   # a quarter that turns the trend around (debt or inflation falling, trust rising) holds the danger where it is
		else:
			s = maxi(0, s - _recovery(e))
			if id == "collapse_fiscal": st.erase("fiscal_nets")
		st["strain"][id] = s
		st["peak"][id] = maxi(int(st["peak"].get(id, 0)), s)
		var warn := int(e.get("warn_at", 2))
		if s >= warn and before < warn:
			_warn(e, s)
		elif s == 0 and before >= warn:
			var why_r := str(e.get("recovered", "the danger has passed"))
			if id == "collapse_military" and war_crisis() == null and S().readiness < float(e.get("rebuilt_readiness", 50.0)):
				# v3 final round (fix4-econ, m3): the danger passed because the war ended, not because readiness was rebuilt
				why_r = str(e.get("recovered_war_over", "the war has ended, but Readiness is still only %d" % int(S().readiness)))
				if why_r.contains("%d"): why_r = why_r % int(S().readiness)
			sim.notify("collapse", "Recovery: %s. %s is no longer in danger." % [why_r, str(e.get("name", id))], {"collapse": id, "recovered": true})
			st["log"].append([S().turn, id, "recovered"])
		elif s > before and s >= warn:
			var left := limit(e) - s
			if left <= 4 and left > 0:
				sim.notify("collapse", "%s: %d quarter%s left. %s" % [str(e.get("name", id)), left, "" if left == 1 else "s", str(e.get("advice", ""))], {"collapse": id, "quarters_left": left})
		if id == "collapse_trust" and s > before and s >= warn and (s - warn) % TRUST_CRISIS_EVERY == 0:
			_gov_crisis()
		if s >= limit(e) and _final_ok(e):
			_end(e)
			return
	st["last"] = {"debt_over_cap": metric("debt_over_cap"), "inflation": S().inflation, "avg_trust": metric("avg_trust"), "unrest_share": unrest_share(), "readiness": S().readiness,
		"net": float(S().counters.get("last_budget", {}).get("net", 0.0))}


func _improvement(id: String) -> int:
	## 2: the quarter closed the gap (the danger eases by a quarter), 1: it moved the right way (the danger holds), 0: no.
	## Fiscal (v3 fix3-econ): the budget back in surplus eases it; running costs within revenue, net gold better by at least
	## a quarter of the last year's average deficit, or debt or inflation falling hold it. (Easing on a single better
	## quarter let a ruinous budget that swings between deficits escape the countdown.)
	if id == "collapse_fiscal":
		var net := float(S().counters.get("last_budget", {}).get("net", 0.0))
		var hist: Array = cs().get("fiscal_nets", [])
		var avg := 0.0
		for x in hist: avg += float(x)
		avg = avg / float(hist.size()) if not hist.is_empty() else net
		hist.append(net)
		cs()["fiscal_nets"] = hist.slice(maxi(0, hist.size() - 4))
		if net >= 0.0:
			return 2
		if sim.econ.structural_ratio() <= 1.0 or (avg < 0.0 and net - avg >= 0.25 * -avg):
			return 1
	return 1 if _improving(id) else 0


func _improving(id: String) -> bool:
	## The way out while every condition still holds: the quarter's record moved the right way (against the last quarter).
	var l: Dictionary = cs().get("last", {})
	if l.is_empty():
		return false
	match id:
		"collapse_fiscal":
			return metric("debt_over_cap") <= float(l.get("debt_over_cap", 0.0)) - 0.02 or S().inflation <= float(l.get("inflation", 0.0)) - 5.0
		"collapse_trust":
			return metric("avg_trust") >= float(l.get("avg_trust", 0.0)) + 0.5 or unrest_share() <= float(l.get("unrest_share", 0.0)) - 0.03
		"collapse_military":
			return S().readiness >= float(l.get("readiness", 0.0)) + 5.0
	return false


func _recovery(e: Dictionary) -> int:
	## Quarters of strain that ease in a quarter when the conditions do not all hold. A military collapse is about
	## wars: between wars it eases by one a quarter only when Readiness is rebuilt, else one every four quarters.
	if str(e["id"]) == "collapse_military" and war_crisis() == null:
		if S().readiness >= float(e.get("rebuilt_readiness", 50.0)):
			return 1
		return 1 if S().turn % 4 == 0 else 0
	return int(e.get("recover", 2))


func _final_ok(e: Dictionary) -> bool:
	for c in e.get("conditions", []):
		if c.get("final", false) and not _met(c, metric(str(c["metric"]))):
			return false
	return true


func _warn(e: Dictionary, s: int) -> void:
	var id := str(e["id"])
	var st := cs()
	st["episodes"][id] = int(st["episodes"].get(id, 0)) + 1
	st["warned"][id] = S().turn
	if not st["first_warn"].has(id):
		st["first_warn"][id] = S().turn
	st["log"].append([S().turn, id, "warning"])
	var left := limit(e) - s
	var adv := str(e.get("advice", ""))
	if id == "collapse_fiscal":
		adv += " " + sim.econ.upkeep_text(true)   # v3 fix3-econ: name the running costs
	sim.notify("collapse", "Danger: %s. %s If nothing changes, the state collapses in about %d quarters. %s" % [str(e.get("name", id)), str(e.get("warning", "")), left, adv],
		{"collapse": id, "first": true, "quarters_left": left})


func _gov_crisis() -> void:
	var st := cs()
	st["gov_crises"].append(S().turn)
	var n := (st["gov_crises"] as Array).size()
	st["log"].append([S().turn, "collapse_trust", "government crisis"])
	sim.notify("collapse", "Government crisis (%d in the last three years): coalition partners walk out as public trust collapses; the cabinet carries on as a caretaker government until it rebuilds a majority." % gov_crises_recent(3),
		{"collapse": "collapse_trust", "government_crisis": n})


func _end(e: Dictionary) -> void:
	var st := cs()
	st["ended"] = str(e["id"])
	st["ended_turn"] = S().turn
	var cr = war_crisis()
	st["end_record"] = _record(e, cr)
	st["log"].append([S().turn, str(e["id"]), "collapse"])
	sim.notify("collapse", "%s (%s). The game ends early." % [str(e.get("name", "")), sim.date_label()], {"collapse": str(e["id"]), "ended": true})


func _probe() -> void:
	## Closest approach to each condition over the game (sim_test's collapse report and tuning).
	var p: Dictionary = cs()["probe"]
	var put := func(k: String, v: float, hi: bool) -> void:
		if not p.has(k): p[k] = [v, S().turn]
		elif (hi and v > float(p[k][0])) or (not hi and v < float(p[k][0])): p[k] = [v, S().turn]
	put.call("debt_over_cap_max", metric("debt_over_cap"), true)
	put.call("inflation_max", S().inflation, true)
	put.call("trust_min", metric("avg_trust"), false)
	put.call("unrest_max", unrest_share(), true)
	var w = war_crisis()
	if w != null:
		put.call("war_readiness_min", S().readiness, false)
		put.call("war_strikes_excess_max", metric("town_strikes_excess"), true)
		put.call("war_strikes_ratio_max", metric("town_strikes_ratio"), true)
	if metric("debt_over_cap") >= 0.9:
		put.call("inflation_max_near_cap", S().inflation, true)
	if metric("avg_trust") <= 50.0:
		put.call("unrest_max_low_trust", unrest_share(), true)


# ================================================================== views

func status() -> Array:
	## [{id, name, summary, kind: "collapse", strain, limit, warn_at, quarters_left, level: ok|watch|danger, progress (0..1),
	##   conditions: [{id, label, metric, value, target, cmp, met, unit, text, final}], advice, peak}] for the Ending outlook,
	##   the top bar and the advisor.
	var out := []
	for e in defs():
		var id := str(e["id"])
		var s := strain(id)
		var lim := limit(e)
		var conds := []
		var holding := 0
		for c in e.get("conditions", []):
			var v := metric(str(c["metric"]))
			var t := target(c)
			var met := _met(c, v)
			if met and not c.get("final", false): holding += 1
			conds.append({"id": str(c.get("id", "")), "label": str(c.get("label", "")), "metric": str(c["metric"]), "value": snappedf(v, 0.001), "target": t,
				"cmp": ">=" if c.has("min") else "<=", "met": met, "unit": str(c.get("unit", "")), "final": bool(c.get("final", false)),
				"text": "%s: %s (%s %s)" % [str(c.get("label", "")), _metric_text(c, v), "at least" if c.has("min") else "at most", _metric_text(c, t)]})
		var warn := int(e.get("warn_at", 2))
		var level := "ok"
		# v3 fix3-econ: tiered: danger (in the countdown), warning (every condition holds, strain building), watch (all but one hold)
		if s >= warn: level = "danger"
		elif s > 0 or holding >= maxi(1, conds.filter(func(x): return not x["final"]).size()): level = "warning"
		elif holding >= maxi(1, conds.filter(func(x): return not x["final"]).size() - 1): level = "watch"
		var advice := str(e.get("advice", ""))
		if id == "collapse_fiscal" and sim.econ.structural_ratio() > 0.0:
			advice += " " + sim.econ.upkeep_text(true)
		out.append({"id": id, "name": str(e.get("name", "")), "summary": str(e.get("summary", "")), "kind": "collapse", "strain": s, "limit": lim, "warn_at": warn,
			"quarters_left": maxi(0, lim - s), "level": level, "progress": snappedf(clampf(float(s) / float(maxi(1, lim)), 0.0, 1.0), 0.01), "conditions": conds,
			"advice": advice, "warning": str(e.get("warning", "")), "peak": int(cs()["peak"].get(id, 0)), "ended": ended_id() == id})
	return out


func warnings() -> Array:
	## The collapses in danger now (strain at or past the warning), closest first.
	var w := status().filter(func(x): return x["level"] == "danger")
	w.sort_custom(func(a, b): return int(a["quarters_left"]) < int(b["quarters_left"]))
	return w


func level_of(id: String) -> String:
	for x in status():
		if str(x["id"]) == id: return str(x["level"])
	return "ok"


func top_bar() -> Dictionary:
	## {show, level, text, tooltip: [lines]}: the top bar's danger item while any collapse is in danger.
	var w := warnings()
	if w.is_empty():
		return {"show": false, "level": "ok", "text": "", "tooltip": []}
	var first: Dictionary = w[0]
	var lines := []
	for x in w:
		lines.append("%s: %d of %d quarters; the state collapses in %d if nothing changes." % [str(x["name"]), int(x["strain"]), int(x["limit"]), int(x["quarters_left"])])
		for c in x["conditions"]:
			if bool(c["met"]): lines.append("  • " + str(c["text"]))
		lines.append("  " + str(x["advice"]))
	lines.append("Every quarter the conditions do not all hold, the danger eases. See the Ending outlook (O).")
	if w.any(func(x): return str(x["id"]) == "collapse_fiscal"):
		lines.append("A fiscal danger also eases in any quarter the budget is back in surplus.")   # v3 fix3-econ
	return {"show": true, "level": "danger", "text": "%dq" % int(first["quarters_left"]), "name": str(first["name"]), "id": str(first["id"]), "tooltip": lines}


# ================================================================== the collapse ending and its epilogue

func _record(e: Dictionary, cr) -> Dictionary:
	var d: Dictionary = sim.econ.debt_report()
	var r := {"turn": S().turn, "date": sim.date_label(), "strain": strain(str(e["id"])), "first_warn": int(cs()["warned"].get(str(e["id"]), S().turn)),
		"debt": float(d["debt"]), "cap": float(d["cap"]), "overdraft": maxf(0.0, -S().gold), "borrowed": float(d["borrowed_total"]), "loans": int(d["borrow_count"]),
		"interest": float(d["interest_total"]), "deficit_turns": int(d["deficit_turns"]), "inflation": S().inflation,
		"inflation_history": sim.inflation_baseline(SimDB.year_f(S().turn)), "trust": sim.score.avg_trust(), "unrest": unrest_share(),
		"gov_crises": (cs()["gov_crises"] as Array).duplicate(), "readiness": S().readiness, "town_strikes": sim.endgame._town_strikes(),
		"history_strikes": _ghost_strikes_to_date(), "units_lost": S().units_lost, "war": "", "war_start": -1, "uncommitted": 0, "war_lost": 0, "war_hits": 0}
	# v3 fix3-econ: the fiscal drivers with their size (running costs, debt service, borrowing, overdraft quarters)
	var sx: Dictionary = sim.econ.structural()
	var up: Dictionary = S().counters.get("upkeep_parts", {})
	r["revenue"] = float(sx.get("revenue", 0.0)); r["upkeep"] = float(sx.get("upkeep", up.get("total", 0.0))); r["service"] = float(sx.get("service", 0.0))
	r["upkeep_parts"] = {"buildings": float(up.get("buildings", 0.0)), "public": float(up.get("public", 0.0)), "districts": float(up.get("districts", 0.0)), "units": float(up.get("units", 0.0))}
	var nb := 0
	for c in sim.active_cities(): nb += c.buildings.size()
	r["buildings"] = nb
	# quarters with the treasury below zero: the counter, or the quarterly record where the counter is missing or short
	# (a save from before the counter existed read "below zero in 0 quarters" next to an overdraft of 2,143)
	var od := 0
	for h in S().history:
		if float((h.get("v", {}) as Dictionary).get("gold", 0.0)) < 0.0: od += 1
	if S().gold < 0.0 and (S().history.is_empty() or int(S().history[-1].get("t", -1)) != S().turn): od += 1
	r["overdraft_quarters"] = maxi(int(S().counters.get("overdraft_quarters", 0)), od)
	r["structural_first"] = int(sx.get("first", -1))
	r["levers"] = sim.econ.lever_counts()
	if cr != null:
		r["war"] = str(cr.get("title", ""))
		r["war_start"] = int(cr.get("start", S().turn))
		r["uncommitted"] = int(cr.get("uncommitted", 0))
		r["war_lost"] = int(cr.get("player_lost", 0))
		r["war_hits"] = int(cr.get("city_hits", 0))
	# the trust lost to each cause over the last six years (stat log), largest first
	var causes := {}
	for le in S().stat_log:
		if str(le.get("stat", "")) == "trust" and int(le.get("turn", 0)) > S().turn - 24 and float(le.get("amount", 0.0)) < 0.0:
			var k := str(le.get("reason", ""))
			causes[k] = float(causes.get(k, 0.0)) + float(le["amount"])
	var ks := causes.keys()
	ks.sort_custom(func(a, b): return float(causes[a]) < float(causes[b]))
	r["trust_causes"] = ks.slice(0, 3)
	var low: Array = sim.active_cities().duplicate()
	low.sort_custom(func(a, b): return a.trust < b.trust)
	r["lowest_trust"] = low.slice(0, 3).map(func(c): return "%s (%d)" % [c.name, int(round(c.trust))])
	var wars_held := 0
	for cl in S().crisis_log:
		if str(cl.get("response", "")) in ["standing_forces", ""]: wars_held += 1
	r["wars_held_back"] = wars_held
	return r


func ending_view() -> Dictionary:
	## {id, name, summary, also: []} for SimEndgame.final_ending().
	var e := def(ended_id())
	return {"id": ended_id(), "name": str(e.get("name", "")), "summary": str(e.get("summary", "")), "also": [], "collapse": true}


func epilogue_paragraphs() -> Array:
	## "What went wrong", built from the player's record: [{kind, title, text}] that replace the ending's opening.
	var e := def(ended_id())
	var r: Dictionary = cs().get("end_record", {})
	var paras := []
	var when := str(r.get("date", sim.date_label()))
	var open := str(e.get("epilogue", {}).get("open", "")).replace("{date}", when)
	paras.append({"kind": "ending", "title": str(e.get("name", "")), "text": open})
	var fw := int(r.get("first_warn", S().turn))
	var warned := "The first warning came in %s, %d quarter%s before the end." % [SimDB.date_label(fw), int(r.get("turn", S().turn)) - fw, "" if int(r.get("turn", S().turn)) - fw == 1 else "s"]
	var t := ""
	match ended_id():
		"collapse_fiscal":
			t = "For %d quarters the public debt and the treasury's overdraft (%s and %s gold) stood above what foreign lenders would hold (%s), while inflation ran at %s a year (history that year: %s)." % [
				int(r.get("strain", 0)), _fmt(float(r.get("debt", 0))), _fmt(float(r.get("overdraft", 0))), _fmt(float(r.get("cap", 0))),
				_pct(float(r.get("inflation", 0))), _pct(float(r.get("inflation_history", 0)))]
			t += "\n" + _fiscal_drivers_text(r)
		"collapse_trust":
			var gc: Array = r.get("gov_crises", [])
			t = "For %d quarters national Civic Trust stayed at %d or below (at the end: %d), and %d%% of the population lived in cities in unrest or alienated from the state." % [
				int(r.get("strain", 0)), int(round(target(_cond(e, "trust")))), int(round(float(r.get("trust", 0)))), int(round(float(r.get("unrest", 0)) * 100.0))]
			if not gc.is_empty():
				t += "\nGovernments fell or lost their majority %d time%s: %s." % [gc.size(), "" if gc.size() == 1 else "s", ", ".join(gc.map(func(x): return SimDB.date_label(int(x))))]
			var lt: Array = r.get("lowest_trust", [])
			if not lt.is_empty():
				t += "\nLowest trust at the end: %s." % ", ".join(lt)
			var tc: Array = r.get("trust_causes", [])
			if not tc.is_empty():
				t += "\nWhat cost the most trust in the last years: %s." % "; ".join(tc.map(func(x): return str(x).trim_suffix(".")))
		"collapse_military":
			var wn := str(r.get("war", ""))
			if wn.begins_with("The "): wn = "the " + wn.substr(4)
			t = "%s Readiness had fallen to %d, and enemy strikes had hit Israel's towns %d times over the game, against %d in history by that date." % [
				("In %s the fronts gave way." % wn) if wn != "" else "The fronts gave way.", int(round(float(r.get("readiness", 0)))),
				int(r.get("town_strikes", 0)), int(round(float(r.get("history_strikes", 0))))]
			if wn != "":
				t += "\nIn that war: %d strikes on towns, %d units lost, %d quarter%s of holding back the reserves." % [int(r.get("war_hits", 0)), int(r.get("war_lost", 0)),
					int(r.get("uncommitted", 0)), "" if int(r.get("uncommitted", 0)) == 1 else "s"]
			t += "\nUnits lost over the game: %d; earlier wars fought with standing forces only: %d." % [int(r.get("units_lost", 0)), int(r.get("wars_held_back", 0))]
	paras.append({"kind": "what_went_wrong", "title": "What went wrong", "text": t + "\n" + warned})
	paras.append({"kind": "what_might", "title": "What might have changed it", "text": str(e.get("epilogue", {}).get("might", e.get("advice", "")))})
	return paras


func _fiscal_drivers_text(r: Dictionary) -> String:
	## v3 fix3-econ: what drove the fiscal collapse, largest first: running costs against revenue, debt service, borrowing,
	## quarters with the treasury below zero; then the first structural-deficit report and the levers used.
	var rev := float(r.get("revenue", 0.0))
	var up := float(r.get("upkeep", 0.0))
	var svc := float(r.get("service", 0.0))
	var parts: Dictionary = r.get("upkeep_parts", {})
	var lines := []
	if up > 0.0 and rev > 0.0:
		lines.append([up - rev, "Running costs: upkeep of %s gold a quarter (buildings %s in %d buildings, public services %s, districts %s, units %s) against revenue of %s, %d%% of it." % [
			_fmt(up), _fmt(float(parts.get("buildings", 0.0))), int(r.get("buildings", 0)), _fmt(float(parts.get("public", 0.0))), _fmt(float(parts.get("districts", 0.0))),
			_fmt(float(parts.get("units", 0.0))), _fmt(rev), int(round(up / rev * 100.0))]])
	if svc > 0.5:
		lines.append([svc, "Debt service: %s gold a quarter in interest and repayment." % _fmt(svc)])
	if float(r.get("borrowed", 0)) > 0.0:
		lines.append([float(r.get("interest", 0)) / 20.0, "Borrowing: %s gold in %d loans over the game, %s paid in interest." % [_fmt(float(r.get("borrowed", 0))), int(r.get("loans", 0)), _fmt(float(r.get("interest", 0)))]])
	lines.append([float(r.get("overdraft_quarters", 0)) * 2.0, "The treasury stood below zero in %d quarters (money printed to cover it fed inflation), and the budget ran a deficit in %d." % [int(r.get("overdraft_quarters", 0)), int(r.get("deficit_turns", 0))]])
	lines.sort_custom(func(a, b): return float(a[0]) > float(b[0]))
	var t := "What drove it, largest first:\n" + "\n".join(lines.map(func(x): return "- " + str(x[1])))
	var sf := int(r.get("structural_first", -1))
	if sf > 0:
		t += "\nThe structural deficit was first reported in %s." % SimDB.date_label(sf)
	var lv: Dictionary = r.get("levers", {})
	var used := []
	if int(lv.get("mothball", 0)) > 0: used.append("%d buildings mothballed" % int(lv["mothball"]))
	if int(lv.get("close", 0)) > 0: used.append("%d closed" % int(lv["close"]))
	if int(lv.get("privatise", 0)) > 0: used.append("%d privatisations" % int(lv["privatise"]))
	if int(lv.get("stabilise", 0)) > 0: used.append("%d stabilisation package%s" % [int(lv["stabilise"]), "" if int(lv["stabilise"]) == 1 else "s"])
	t += ("\nLevers used: %s." % ", ".join(used)) if not used.is_empty() else "\nNo building was mothballed or closed, no state company was privatised and no stabilisation package was adopted."
	return t


func _cond(e: Dictionary, cid: String) -> Dictionary:
	for c in e.get("conditions", []):
		if str(c.get("id", "")) == cid: return c
	return {}


func close_text() -> String:
	return str(def(ended_id()).get("epilogue", {}).get("close", ""))


static func _fmt(n: float) -> String:
	return SimEndgame._fmt(n)


static func _pct(v: float) -> String:
	return ("%.1f%%" % v) if absf(v) < 10.0 else ("%d%%" % int(round(v)))


# ================================================================== tests and captures

func debug_set(id: String, quarters: int) -> void:
	## Sets a collapse's strain (UI captures and tests only). Reaching the limit ends the game at the next end of turn.
	cs()["strain"][id] = quarters
	cs()["peak"][id] = maxi(int(cs()["peak"].get(id, 0)), quarters)
	if not cs()["first_warn"].has(id):
		cs()["first_warn"][id] = maxi(1, S().turn - maxi(0, quarters - 2))
	if id == "collapse_trust" and gov_crises_recent(3) < 2 and quarters >= 6:
		cs()["gov_crises"] = [S().turn - 4, S().turn]


func debug_end(id: String) -> void:
	## Ends the game now with this collapse (UI captures and tests only).
	var e := def(id)
	if e.is_empty():
		return
	debug_set(id, limit(e))
	_end(e)
