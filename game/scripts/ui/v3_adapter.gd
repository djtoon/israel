class_name V3Adapter
extends RefCounted
## The UI's view of the v3 sim APIs (progress/INTEGRATION_REQUESTS.md "## v3"): economy indicator, national food,
## difficulty, scenarios, the ending outlook and the ending reached, relations, deals and diplomatic decisions.
## Each call uses the sim's own method when it exists (sim-endgame: get_fiscal_indicator, get_food_balance,
## difficulty_levels, scenario_starts, get_endings, get_epilogue, hints_enabled; sim-diplomacy: get_relations,
## propose_deal, the diplomacy decision) and otherwise reads today's state, so the screens work either way.

static var _seen := {}   # turn -> {debt, inflation}: the trend fallback


static func reset() -> void:
	_seen.clear()


static func last_turn(sim = null) -> int:
	## The last playable turn as the sim configures it (the demo ends in 1967).
	if sim != null and sim.has_method("get_last_turn"):
		return int(sim.get_last_turn())
	return Sim.last_playable_turn()   # Q3 2023 (turn 302), or the demo's 1967


static func end_label(sim = null) -> String:
	return SimDB.date_label(last_turn(sim))


static func end_year(sim = null) -> int:
	return SimDB.year_of(last_turn(sim))


static func endify(t: String) -> String:
	## Player-facing text written with {END_Q} ("Q3 2023") and {END_YEAR}: the sim's configured last turn.
	if not t.contains("{END"):
		return t
	return t.replace("{END_Q}", end_label()).replace("{END_YEAR}", str(end_year()))


static func _json(path: String) -> Dictionary:
	if FileAccess.file_exists(path):
		var d = JSON.parse_string(FileAccess.get_file_as_string(path))
		if d is Dictionary:
			return d
	return {}


static func _static_has(s: Script, m: String) -> bool:
	if s == null:
		return false
	for md in s.get_script_method_list():
		if str(md.get("name", "")) == m:
			return true
	return false


# ================================================================== top bar: debt and inflation (item 7)

static func economy(sim) -> Dictionary:
	## {debt, debt_ratio (years of revenue), cap, service, inflation, baseline, trend, debt_trend, health, level, tooltip: [lines]}
	var out := {}
	if sim.has_method("get_fiscal_indicator"):   # sim-endgame v3
		var fi: Dictionary = sim.get_fiscal_indicator()
		out["inflation"] = float(fi.get("inflation", 0.0))
		out["trend"] = float(fi.get("inflation_trend", 0.0))
		out["baseline"] = float(fi.get("inflation_history", 0.0))
		out["debt"] = float(fi.get("debt", 0.0))
		out["debt_ratio"] = float(fi.get("debt_years", 0.0))
		out["debt_trend_years"] = float(fi.get("debt_trend", 0.0))
		out["level"] = str(fi.get("level", "ok"))
		out["deficit_quarters"] = int(fi.get("deficit_quarters", 0))
		out["structural"] = bool(fi.get("structural", false))         # fix3-econ: the structural-deficit alarm
		out["structural_ratio"] = float(fi.get("structural_ratio", 0.0))
		out["upkeep_text"] = str(fi.get("upkeep_text", ""))
	var n: Dictionary = sim.get_national_summary()
	var yf := SimDB.year_f(sim.state.turn)
	var rev_q := maxf(1.0, float(n.get("gold", 0.0)))
	if not out.has("debt"): out["debt"] = float(n.get("debt", 0.0))
	out["service"] = float(n.get("debt_service", 0.0))
	out["cap"] = float(n.get("borrow_cap", 0.0))
	if not out.has("debt_ratio"): out["debt_ratio"] = float(out["debt"]) / maxf(1.0, rev_q * 4.0)
	if not out.has("inflation"): out["inflation"] = float(n.get("inflation", sim.state.inflation))
	if not out.has("baseline") and sim.has_method("inflation_baseline"):
		out["baseline"] = float(sim.inflation_baseline(yf))
	out["health"] = float(n.get("economy_health", 1.0))
	_seen[int(sim.state.turn)] = {"debt": float(out["debt"]), "inflation": float(out["inflation"])}
	var old = _seen.get(int(sim.state.turn) - 4, _seen.get(int(sim.state.turn) - 1))
	if not out.has("trend"):
		var tr := 0.0
		var any := false
		for e in sim.get_stat_log("inflation"):
			if int(e.get("turn", 0)) > sim.state.turn - 4:
				tr += float(e.get("amount", 0.0))
				any = true
		if not any and old != null:
			tr = float(out["inflation"]) - float(old["inflation"])
		out["trend"] = tr
	out["debt_trend"] = float(out["debt"]) - float(old["debt"]) if old != null else 0.0
	if not out.has("level"):
		var infl := float(out["inflation"])
		out["level"] = "danger" if infl > 50.0 or float(out["debt_ratio"]) > 2.5 else ("watch" if infl > 15.0 or float(out["debt_ratio"]) > 1.5 else "ok")
	out["tooltip"] = _econ_tooltip(sim, out, n)
	return out


const LEVEL_TEXT := {"ok": "", "watch": "Fiscal indicator: watch. Running costs, inflation or debt are drifting off history's path.",
	"warning": "Fiscal indicator: warning. A structural deficit, runaway inflation or the lenders' limit: act now.",
	"danger": "Fiscal indicator: DANGER. A fiscal collapse is in sight (see the Ending outlook, O)."}


static func _econ_tooltip(sim, e: Dictionary, n: Dictionary) -> Array:
	var lines := []
	var lt := str(LEVEL_TEXT.get(str(e.get("level", "ok")), ""))
	if lt != "":
		lines.append(lt)
	var inf := float(e["inflation"])
	var tr := float(e["trend"])
	lines.append("Inflation: %s a year%s" % [_pct(inf), (" (%s on a year ago)" % _signed_pts(tr)) if absf(tr) >= 0.5 else ", about the same as a year ago"])
	if e.has("baseline"):
		var gap := inf - float(e["baseline"])
		lines.append("History in %d: %s%s" % [sim.year(), _pct(float(e["baseline"])),
			"" if absf(gap) < 0.5 else ("; yours is %s %s" % [_pts(absf(gap)), "higher" if gap > 0 else "lower"])])
	var debt := float(e["debt"])
	if debt <= 0.5:
		lines.append("Public debt: none")
	else:
		lines.append("Public debt: %s Gold, %s of revenue (lenders' limit %s)" % [UITheme.fmt_num(debt), years_text(float(e["debt_ratio"])), UITheme.fmt_num(float(e["cap"]))])
		lines.append("Debt service: %s Gold a quarter (interest and repayment)" % UITheme.fmt_num(float(e["service"])))
		if e.has("debt_trend_years") and absf(float(e["debt_trend_years"])) >= 0.05:
			lines.append("Debt %s by %s of revenue on a year ago" % ["up" if float(e["debt_trend_years"]) > 0 else "down", years_text(absf(float(e["debt_trend_years"])))])
		elif absf(float(e.get("debt_trend", 0.0))) >= 1.0:
			var dt := float(e["debt_trend"])
			lines.append("Debt %s by %s Gold recently" % ["up" if dt > 0 else "down", UITheme.fmt_num(absf(dt))])
	if int(e.get("deficit_quarters", 0)) > 0:
		lines.append("%d of the last 4 quarters ran a deficit" % int(e["deficit_quarters"]))
	var h := float(e.get("health", 1.0))
	if h < 0.995:
		lines.append("Inflation above history's and the debt burden cut output per person by %d%% (Economy track)" % int(round((1.0 - h) * 100.0)))
	for r in n.get("deficit_streams", []):
		lines.append("Standing deficit: %s, %s Gold a quarter (%s)" % [str(r.get("label", "")), UITheme.fmt_signed(float(r.get("amount", 0))), str(r.get("ends", ""))])
	if str(e.get("upkeep_text", "")) != "":
		lines.append(str(e["upkeep_text"]))
	if bool(e.get("structural", false)):
		lines.append("Structural deficit: running costs are above revenue quarter after quarter. Mothball or close buildings, privatise, or adopt a stabilisation package.")
	lines.append("High inflation makes buying dearer and erodes income; debt costs interest every quarter. Click for the running costs and the fiscal levers.")
	return lines


static func years_text(y: float) -> String:
	## Debt in years of revenue: "0.4 years", "1 year", "2.5 years".
	if absf(y - 1.0) < 0.05:
		return "1 year"
	return "%.1f years" % y


static func _pct(v: float) -> String:
	return ("%d%%" % int(round(v))) if absf(v) >= 10.0 else ("%.1f%%" % v)


static func _pts(v: float) -> String:
	return ("%d points" % int(round(v))) if absf(v) >= 10.0 else ("%.1f points" % v)


static func _signed_pts(v: float) -> String:
	return ("+" if v >= 0 else "−") + _pts(absf(v))


# ================================================================== national food (item 7)

static func food(sim) -> Dictionary:
	## {produced, consumed, surplus, ratio, import_cost, export_gold, rural, growth_effect, tooltip: [lines]}
	var out := {}
	if sim.has_method("get_food_balance"):   # sim-endgame v3
		var fb: Dictionary = sim.get_food_balance()
		out = {"produced": float(fb.get("produced", 0.0)), "consumed": float(fb.get("needed", 0.0)), "surplus": float(fb.get("balance", 0.0)),
			"ratio": float(fb.get("ratio", 1.0)), "import_cost": float(fb.get("imports_gold", 0.0)), "export_gold": float(fb.get("exports_gold", 0.0)),
			"rural": float(fb.get("rural", 0.0)), "growth_effect": float(fb.get("growth_effect_pct", 0.0)), "sim_text": str(fb.get("text", ""))}
	var n: Dictionary = sim.get_national_summary()
	if not out.has("produced"): out["produced"] = float(n.get("food", 0.0))
	if not out.has("consumed"): out["consumed"] = float(n.get("food_need", 0.0))
	if not out.has("surplus"): out["surplus"] = float(out["produced"]) - float(out["consumed"])
	if not out.has("ratio"): out["ratio"] = float(out["produced"]) / maxf(1.0, float(out["consumed"]))
	if not out.has("import_cost"): out["import_cost"] = maxf(0.0, -float(out["surplus"])) * 0.5
	if not out.has("rural"): out["rural"] = float(n.get("rural_food", 0.0))
	var t := []
	var s := float(out["surplus"])
	t.append("National food: %s produced, %s eaten a quarter (2 per population point): %s, %d%% of what the country eats." % [
		UITheme.fmt_num(float(out["produced"])), UITheme.fmt_num(float(out["consumed"])), ("surplus " + UITheme.fmt_signed(s)) if s >= 0 else ("shortfall " + UITheme.fmt_num(absf(s))),
		int(round(float(out["ratio"]) * 100.0))])
	if s >= 0:
		t.append("The country feeds itself%s. A large city eats more than its own tiles grow and is fed from this national pool, so its own figure can be negative." % (
			(" and exports the rest for about %s Gold" % UITheme.fmt_num(float(out["export_gold"]))) if float(out.get("export_gold", 0.0)) >= 1.0 else ""))
	else:
		t.append("The shortfall is imported for about %s Gold a quarter%s." % [UITheme.fmt_num(float(out["import_cost"])),
			(", and growth slows by %d%% everywhere" % int(round(absf(float(out["growth_effect"]))))) if absf(float(out.get("growth_effect", 0.0))) >= 0.5 else ""])
	if float(out["rural"]) > 0.5:
		t.append("Includes %s from villages and farms outside the cities." % UITheme.fmt_num(float(out["rural"])))
	t.append("Farms, kibbutzim and moshavim, drip irrigation and fish ponds raise it.")
	out["tooltip"] = t
	return out


# ================================================================== difficulty and scenarios (items 5, 6)

const FALLBACK_DIFFICULTIES := [
	{"id": "easy", "name": "Easy", "desc": "A softer benchmark and a larger 1948 treasury. For learning the systems."},
	{"id": "normal", "name": "Normal", "desc": "History's record as it was. The intended game.", "default": true},
	{"id": "hard", "name": "Hard", "desc": "History's record counts higher, budgets are tighter and crises cost more."},
	{"id": "historian", "name": "Historian", "desc": "Hard, with no Recommended badges and history's own choice hidden until after you decide."},
]


static func difficulties() -> Array:
	var s: Script = Sim
	for m in ["difficulty_levels", "get_difficulties"]:
		if _static_has(s, m):
			var d = s.call(m)
			if d is Array and (d as Array).size() > 0:
				var out := []
				var def := str(_json("res://data/difficulty.json").get("default", "normal"))
				for x in d:
					var e: Dictionary = (x as Dictionary).duplicate()
					if not e.has("default"):
						e["default"] = str(e.get("id", "")) == def
					out.append(e)
				return out
	return FALLBACK_DIFFICULTIES


static func default_difficulty() -> String:
	for d in difficulties():
		if bool(d.get("default", false)):
			return str(d.get("id", "normal"))
	return "normal"


static func difficulty_name(sim) -> String:
	if sim == null:
		return ""
	if sim.has_method("get_difficulty"):
		var d = sim.get_difficulty()
		if d is Dictionary:
			return str(d.get("name", UITheme.pretty(str(d.get("id", "normal")))))
		return UITheme.pretty(str(d))
	return ""


static func hints(sim) -> bool:
	## Historian difficulty: no Recommended badges and history's choice hidden until after the pick.
	if sim != null and sim.has_method("hints_enabled"):
		return bool(sim.hints_enabled())
	return true


const FALLBACK_SCENARIOS := [
	{"id": "", "name": "14 May 1948: Independence", "year": 1948, "available": true,
		"desc": "The full game: the declaration of independence, the 1948 war, mass immigration and every decade after."},
	{"id": "1967", "name": "Q3 1967: After the Six-Day War", "year": 1967, "available": false,
		"desc": "Start with the territories taken in June 1967 and the Khartoum summit ahead."},
	{"id": "1977", "name": "Q3 1977: The upheaval", "year": 1977, "available": false,
		"desc": "Likud wins its first election; Sadat's visit and the inflation crisis lie ahead."},
	{"id": "1992", "name": "Q3 1992: The Oslo era", "year": 1992, "available": false,
		"desc": "The Soviet aliyah, the Madrid talks and the high-tech economy."},
]


static func scenarios() -> Array:
	## [{id ("" = 1948), name, year, desc, available}]: 1948 first, then the sim's scenario starts.
	var s: Script = Sim
	for m in ["scenario_starts", "get_scenarios"]:
		if _static_has(s, m):
			var d = s.call(m)
			if d is Array and (d as Array).size() > 0:
				var out := [FALLBACK_SCENARIOS[0]]
				for x in d:
					var e: Dictionary = x
					var yr := int(str(e.get("date", "0")).substr(0, 4))
					out.append({"id": str(e.get("id", "")), "name": "%s: %s" % [str(e.get("label", yr)), str(e.get("title", ""))], "year": yr,
						"desc": str(e.get("briefing", e.get("desc", ""))), "available": bool(e.get("available", false))})
				return out
	return FALLBACK_SCENARIOS


# ================================================================== endings (item 3)

static func outlook_live(sim) -> bool:
	return sim != null and (sim.has_method("get_ending_outlook") or sim.has_method("get_endings"))


static func outlook(sim) -> Array:
	## [{id, name, desc, thresholds: [{label, value, target, unit, met, progress, more_is_better, text}], progress, met, likely, primary, mixed?}]
	if sim.has_method("get_endings"):
		var o2 = sim.get_endings()
		if o2 is Array:
			return o2
		if o2 is Dictionary and o2.has("endings"):
			return _from_endgame(o2)
	return _outlook_fallback(sim)


static func _from_endgame(en: Dictionary) -> Array:
	## sim-endgame's get_endings() -> the panel's shape (criteria become thresholds), plus the mixed record.
	var out := []
	var lead := str(en.get("leading", ""))
	var reached: Array = en.get("reached", [])
	for e in en.get("endings", []):
		var th := []
		for c in e.get("criteria", []):
			th.append({"label": str(c.get("label", "")), "value": float(c.get("value", 0)), "target": float(c.get("target", 0)), "unit": str(c.get("unit", "")),
				"met": bool(c.get("met", false)), "progress": float(c.get("progress", 0)), "more_is_better": str(c.get("cmp", ">=")) == ">=",
				"text": str(c.get("text", "")), "metric": str(c.get("metric", ""))})
			var alt = c.get("or")   # v3 fix3-econ: an alternative threshold that also meets the criterion ("or ...")
			if alt is Dictionary and not (alt as Dictionary).is_empty():
				th[th.size() - 1]["or"] = {"label": str(alt.get("label", "")), "value": float(alt.get("value", 0)), "target": float(alt.get("target", 0)),
					"unit": str(alt.get("unit", "")), "met": bool(alt.get("met", false)), "more_is_better": str(alt.get("cmp", ">=")) == ">=", "text": str(alt.get("text", ""))}
		out.append({"id": str(e.get("id", "")), "name": str(e.get("name", "")), "desc": str(e.get("summary", "")), "thresholds": th,
			"progress": float(e.get("progress", 0)), "met": bool(e.get("met", false)), "likely": str(e.get("id", "")) == lead,
			"primary": str(e.get("id", "")) == str(en.get("primary", ""))})
	var fb := _fallback_ending()
	if not fb.is_empty():
		out.append({"id": str(fb.get("id", "mixed_record")), "name": str(fb.get("name", "A Mixed Record")), "desc": str(fb.get("summary", "")),
			"thresholds": [], "progress": 0.0, "met": reached.is_empty(), "mixed": true, "primary": reached.is_empty()})
	for c in en.get("collapse", []):   # v3 item 13 (fix-v3a): the collapses of the state and how close each is
		var cth := []
		for k in c.get("conditions", []):
			cth.append({"label": str(k.get("label", "")), "value": float(k.get("value", 0)), "target": float(k.get("target", 0)), "unit": str(k.get("unit", "")),
				"met": bool(k.get("met", false)), "more_is_better": str(k.get("cmp", ">=")) == ">=", "text": str(k.get("text", "")), "metric": str(k.get("metric", "")),
				"final": bool(k.get("final", false))})
		out.append({"id": str(c.get("id", "")), "name": str(c.get("name", "")), "desc": str(c.get("summary", "")), "thresholds": cth, "collapse": true,
			"level": str(c.get("level", "ok")), "strain": int(c.get("strain", 0)), "limit": int(c.get("limit", 1)), "quarters_left": int(c.get("quarters_left", 0)),
			"progress": float(c.get("progress", 0)), "met": bool(c.get("ended", false)), "advice": str(c.get("advice", "")), "warn_at": int(c.get("warn_at", 2))})
	return out


static func collapse_bar(sim) -> Dictionary:
	## The top bar's danger item: {show, text, name, tooltip: [lines]} (sim.get_collapse_top_bar()), or show false.
	if sim != null and sim.has_method("get_collapse_top_bar"):
		var d = sim.get_collapse_top_bar()
		if d is Dictionary:
			return d
	return {"show": false}


static func threshold_text_collapse(th: Dictionary) -> String:
	## "Readiness 24 / at most 30", "Inflation 140% / at least 100%".
	var u := str(th.get("unit", ""))
	var v := float(th.get("value", 0)); var t := float(th.get("target", 0))
	var f := func(x: float) -> String:
		match u:
			"x the limit": return "%d%% of the limit" % int(round(x * 100.0))
			"share": return "%d%%" % int(round(x * 100.0))
			"strikes": return "%+d" % int(round(x))
			"flag": return "yes" if x >= 0.5 else "no"
		return _fmt_metric(x, u)
	if u == "flag":
		return f.call(v)
	return "%s / %s %s" % [f.call(v), "at least" if bool(th.get("more_is_better", true)) else "at most", f.call(t)]


static func _fallback_ending() -> Dictionary:
	for e in _json("res://data/endings.json").get("endings", []):
		if bool(e.get("fallback", false)):
			return e
	return {}


static func gap_note() -> Dictionary:
	return _json("res://data/endings.json").get("gap_note", {})


static func _th(label: String, value: float, target: float, unit := "", more_is_better := true) -> Dictionary:
	var met := value >= target if more_is_better else value <= target
	var prog := clampf(value / maxf(0.001, target), 0.0, 1.0) if more_is_better else clampf(target / maxf(0.001, value), 0.0, 1.0)
	return {"label": label, "value": value, "target": target, "unit": unit, "met": met, "progress": prog, "more_is_better": more_is_better}


static func _outlook_fallback(sim) -> Array:
	## Only for a sim without sim-endgame: four end states read from the six tracks and today's national figures.
	var sc: Dictionary = sim.get_score()
	var ratio := {}
	for t in sc.get("tracks", []):
		ratio[str(t.get("id", ""))] = float(t.get("ratio", 1.0))
	var n: Dictionary = sim.get_national_summary()
	var peace := 0
	for d in sim.get_diplomacy():
		if str(d.get("status", "")) in ["peace", "normalized"]:
			peace += 1
	var out := [
		{"id": "secure_state", "name": "Secure State", "desc": "Strong, ready defences and the standing to keep allies.",
			"thresholds": [_th("Readiness", float(n.get("readiness", 0)), 85.0), _th("Standing", float(n.get("standing", 0)), 60.0)]},
		{"id": "prosperous_state", "name": "Prosperous State", "desc": "Output per person and science ahead of history, with stable prices.",
			"thresholds": [_th("Economy against history", float(ratio.get("economy", 1.0)), 1.12, "x history"), _th("Science against history", float(ratio.get("science", 1.0)), 1.08, "x history"),
				_th("Inflation", float(n.get("inflation", 0)), 6.0, "%", false)]},
		{"id": "peace_with_neighbours", "name": "Peace with Neighbours", "desc": "Peace or normal relations with most of the region.",
			"thresholds": [_th("States at peace or with normal relations", float(peace), 6.0)]},
		{"id": "united_society", "name": "United Society", "desc": "High civic trust and cohesion across every community.",
			"thresholds": [_th("Civic Trust", float(n.get("avg_trust", 0)), 75.0, "%"), _th("Cohesion against history", float(ratio.get("cohesion", 1.0)), 1.05, "x history")]},
	]
	var best := -1.0
	var best_i := -1
	for i in out.size():
		var e: Dictionary = out[i]
		var p := 0.0
		var all_met := true
		for th in e["thresholds"]:
			p += float(th["progress"])
			all_met = all_met and bool(th["met"])
		e["progress"] = p / maxf(1.0, (e["thresholds"] as Array).size())
		e["met"] = all_met
		if e["progress"] > best:
			best = e["progress"]; best_i = i
	if best_i >= 0:
		out[best_i]["likely"] = true
	out.append({"id": "mixed_record", "name": "A Mixed Record", "desc": "If no end state's thresholds are all met at the end, the game ends with a mixed record.",
		"thresholds": [], "progress": 0.0, "met": not out.any(func(x): return bool(x.get("met", false))), "mixed": true})
	return out


static func threshold_text(th: Dictionary) -> String:
	## "Readiness 72 / at least 85", "Inflation 4.1% / at most 6%", "Economy 108% of history / at least 112%".
	var u := str(th.get("unit", ""))
	var v := float(th.get("value", 0)); var t := float(th.get("target", 0))
	var fv := _fmt_metric(v, u); var ft := _fmt_metric(t, u)
	return "%s / %s %s" % [fv, "at least" if bool(th.get("more_is_better", true)) else "at most", ft]


static func _fmt_metric(v: float, unit: String) -> String:
	match unit:
		"x history": return "%s of history" % SimScore.ratio_text(v)
		"share": return "%.1f%%" % (v * 100.0)
		"%": return ("%.1f%%" % v) if absf(v) < 10.0 else ("%d%%" % int(round(v)))
		"years": return years_text(v)
		"levels": return "%d level%s" % [int(round(v)), "" if int(round(v)) == 1 else "s"]
	if absf(v - roundf(v)) < 0.01 or absf(v) >= 10.0:
		return str(int(round(v)))
	return "%.1f" % v


static func ending(sim, summary: Dictionary) -> Dictionary:
	## The ending reached: {id, name, summary, also, sections: [{kind, title, text}], record}, or {} without sim-endgame.
	var e = summary.get("ending")
	if e is Dictionary and not (e as Dictionary).is_empty():
		var out: Dictionary = (e as Dictionary).duplicate()
		var ep = summary.get("epilogue")
		if ep == null and sim.has_method("get_epilogue"):
			ep = sim.get_epilogue()
		if ep is Dictionary:
			out["sections"] = ep.get("paragraphs", [])
			out["record"] = ep.get("record", {})
			if not out.has("also"):
				out["also"] = ep.get("also", [])
		return out
	if sim.has_method("get_ending"):
		var e2 = sim.get_ending()
		if e2 is Dictionary:
			return e2
	return {}


static func epilogue_paragraphs(e: Dictionary) -> Array:
	## [{kind, title, text}] (sim-endgame paragraphs), or plain strings for a text epilogue.
	if e.get("sections") is Array and not (e["sections"] as Array).is_empty():
		return e["sections"]
	var ep = e.get("epilogue", e.get("text", ""))
	if ep is Array:
		return ep
	var out := []
	for p in str(ep).split("\n\n", false):
		if p.strip_edges() != "":
			out.append(p.strip_edges())
	return out


static func ending_name(sim, id: String) -> String:
	for e in outlook(sim):
		if str(e.get("id", "")) == id:
			return str(e.get("name", id))
	return UITheme.pretty(id)


# ================================================================== diplomacy (item 4)

static func relations_live(sim) -> bool:
	return sim != null and sim.has_method("get_actor_diplomacy")


static func diplo_rows(sim) -> Array:
	## The actors on the screen (in their era), each {id, name, status, status_label, relation, relation_label, since,
	## top_causes, deals_ready, war, portrait, region}. sim-diplomacy: get_diplomacy_screen().actors.
	var rows: Array = []
	if sim.has_method("get_diplomacy_screen"):
		rows = (sim.get_diplomacy_screen() as Dictionary).get("actors", [])
	else:
		rows = sim.get_diplomacy()
	var out := []
	for r in rows:
		var d: Dictionary = (r as Dictionary).duplicate()
		if not bool(d.get("active", true)):
			continue
		if not d.has("status_label"):
			d["status_label"] = status_label(str(d.get("status", "")))
		var rl = d.get("relation_level")
		d["relation_label"] = str(rl.get("label", "")) if rl is Dictionary else relation_word(float(d.get("relation", 0)))
		d["war"] = str(d.get("status", "")) == "war"
		out.append(d)
	return out


static func actor(sim, id: String) -> Dictionary:
	## Everything for one actor card: {id, name, leader, agenda, status_label, since, relation, relation_label, causes:
	## [{label, amount, since, fading}], deals: [deal], exposure, history, timeline, delegation, trade_partner}.
	var d := {}
	if sim.has_method("get_actor_diplomacy"):
		d = (sim.get_actor_diplomacy(id) as Dictionary).duplicate()
	if d.is_empty():
		for r in sim.get_diplomacy():
			if str(r.get("id", "")) == id:
				d = (r as Dictionary).duplicate()
		if d.is_empty():
			return {}
		d["causes"] = _causes_fallback(sim, id)
		d["deals"] = []
		d["delegation"] = {"ready": bool(d.get("delegation_ready", false)) and str(d.get("status", "")) != "war", "cost": int(round(_delegation_cost(sim))), "relation": 8}
	if not d.has("status_label"):
		d["status_label"] = status_label(str(d.get("status", "")))
	var rl = d.get("relation_level")
	d["relation_label"] = str(rl.get("label", "")) if rl is Dictionary else relation_word(float(d.get("relation", 0)))
	# the leader: a name (older sims) or {id, name, title, portrait}
	var ld = d.get("leader", "")
	if ld is Dictionary:
		d["leader_name"] = str(ld.get("name", ""))
		d["leader_title"] = str(ld.get("title", ""))
		d["leader_portrait"] = str(ld.get("portrait", ""))
		d["leader_id"] = str(ld.get("id", ""))
	else:
		d["leader_name"] = str(ld)
	# deals: the sim's era deals, then the always-available delegation and export route
	var deals: Array = []
	for x in d.get("deals", []):
		deals.append(_deal_norm(x))
	var dg: Dictionary = d.get("delegation", {})
	var gold := float(sim.state.gold)
	var dcost := float(dg.get("cost", _delegation_cost(sim)))
	deals.append({"id": "delegation", "kind_label": "Delegation", "title": "Send a delegation",
		"text": "Envoys and talks: the relation improves (+%d, fading over a few years) and Standing rises. Once every 8 quarters per partner." % int(dg.get("relation", 8)),
		"give": ["[color=#ff8f7a]−%s Gold[/color]" % UITheme.fmt_num(dcost)], "get": ["[color=#9fe07a]+%d relation[/color]" % int(dg.get("relation", 8)), "[color=#9fe07a]Standing up[/color]"],
		"available": bool(dg.get("ready", false)), "acceptable": gold >= dcost,
		"reason": ("Not enough Gold." if gold < dcost else "") if bool(dg.get("ready", false)) else ("Not while at war." if str(d.get("status", "")) == "war" else "A delegation was sent less than 8 quarters ago."),
		"historical": true, "builtin": true})
	if bool(d.get("trade_partner", false)):
		var cap_ok: bool = sim.state.trade_routes.size() < sim.trade_capacity()
		deals.append({"id": "trade_route", "kind_label": "Export route", "title": "Open an export route",
			"text": "A trade route from the capital to this partner earns Gold for 14 quarters and counts as a live cause of the relation.",
			"give": ["One of your trade routes (%d of %d in use)" % [sim.state.trade_routes.size(), sim.trade_capacity()]], "get": ["[color=#9fe07a]Gold every quarter for 14 quarters[/color]", "[color=#9fe07a]Better relations[/color]"],
			"available": cap_ok, "acceptable": cap_ok, "reason": "" if cap_ok else "Every trade route is in use.", "historical": true, "builtin": true})
	d["deals"] = deals
	return d


static func _deal_norm(x: Dictionary) -> Dictionary:
	## sim-diplomacy deal_view -> the deal screen: give / get as coloured lines (structured effects and relation changes).
	var d: Dictionary = x.duplicate()
	var give := []
	var get_ := []
	for e in x.get("give", []):
		give.append(_fx_one(e))
	for e in x.get("get", []):
		get_.append(_fx_one(e))
	for r in x.get("relation", []):
		var a := float(r.get("amount", 0))
		if absf(a) >= 0.5:
			(get_ if a > 0 else give).append("[color=%s]%s relation with %s[/color]" % ["#9fe07a" if a > 0 else "#ff8f7a", UITheme.fmt_signed(a), str(r.get("name", ""))])
	if float(x.get("exposure", 0)) > 0.0:
		var rt := str(x.get("risk_text", ""))
		give.append("[color=#ffbf66]Dependence on %s%s[/color]" % [str(x.get("actor_name", "")), (": " + rt) if rt != "" else " (it may use its leverage later)"])
	d["give"] = give.filter(func(t): return str(t) != "")
	d["get"] = get_.filter(func(t): return str(t) != "")
	return d


static func _fx_one(e) -> String:
	if typeof(e) == TYPE_DICTIONARY:
		var lab := CabinetPanel.fx_label(str(e.get("label", "")))
		if lab == "" or UITheme.is_zero_term(lab):
			return ""
		var w := str(e.get("when", ""))
		if w != "" and w != "now" and not lab.contains(w):
			lab += " (%s)" % w
		return "[color=%s]%s[/color]" % ["#9fe07a" if UITheme.fx_good(e) else "#ff8f7a", lab]
	return UITheme.color_effects(CabinetPanel.fx_label(str(e)))


static func _delegation_cost(sim) -> float:
	if sim.has_method("delegation_cost"):
		return float(sim.delegation_cost())
	return 25.0 * (1.0 + 2.0 * (float(sim.progress_fraction()) if sim.has_method("progress_fraction") else 0.0))


static func _causes_fallback(sim, actor_id: String) -> Array:
	## Without sim-diplomacy: recent events naming this actor's diplomacy, newest first (no amounts).
	var out := []
	var dbi := SimDB.get_db()
	var log: Array = sim.get_event_log(400)
	for i in range(log.size() - 1, -1, -1):
		var le: Dictionary = log[i]
		var ev = dbi.event_by_id.get(str(le.get("id", "")))
		if ev == null:
			continue
		var eff: Dictionary = ev.get("effects", {})
		var dip = eff.get("diplomacy", eff.get("relations"))
		if dip is Dictionary and (dip as Dictionary).has(actor_id):
			out.append({"label": str(le.get("title", "")), "since": SimDB.date_label(int(le.get("turn", 0)))})
		if out.size() >= 4:
			break
	return out


const STATUS_LABELS := {"war": "At war", "hostile": "Hostile", "severed": "Relations severed", "ceasefire": "Ceasefire", "armistice": "Armistice",
	"negotiating": "Negotiating", "none": "No relations", "relations_established": "Diplomatic relations", "peace": "Peace treaty", "normalized": "Peace and normal relations"}


static func status_label(s: String) -> String:
	return STATUS_LABELS.get(s, UITheme.pretty(s))


static func relation_word(v: float) -> String:
	if v >= 70: return "Close partner"
	if v >= 45: return "Friendly"
	if v >= -20: return "Neutral"
	if v >= -50: return "Unfriendly"
	return "Hostile"


static func propose(sim, actor_id: String, deal: Dictionary, variant := "") -> Dictionary:
	## -> {ok, text}
	var id := str(deal.get("id", ""))
	match id:
		"delegation":
			var ok: bool = sim.send_delegation(actor_id)
			return {"ok": ok, "text": "The delegation was received: relations and Standing improve." if ok else "Not possible now (cost, cooldown or war)."}
		"trade_route":
			var cap = sim.city_by_key(sim.state.capital)
			var ok2: bool = cap != null and sim.start_trade_route(cap.id, actor_id)
			return {"ok": ok2, "text": ("Export route opened from %s." % str(cap.name)) if ok2 else "Not possible (capacity or an existing route)."}
	if sim.has_method("propose_deal"):
		var r = sim.propose_deal(id) if variant == "" else sim.propose_deal(actor_id, id, variant)
		if r is Dictionary:
			var ok3 := bool(r.get("ok", false))
			var why := UITheme.humanise(str(r.get("reason", "not possible now")))
			var agreed := ("Agreed: %s." % str(deal.get("title", ""))) if variant == "" else ("Agreed on your counter-terms: %s." % str(deal.get("title", "")))
			return {"ok": ok3, "text": agreed if ok3 else (why.substr(0, 1).to_upper() + why.substr(1) + ".")}
		return {"ok": bool(r), "text": ""}
	return {"ok": false, "text": "This deal is not available."}


const DIPLO_TYPES := ["diplomacy", "diplomatic", "diplomatic_decision", "diplomacy_decision", "diplomatic_offer"]


static func is_diplo_decision(d: Dictionary) -> bool:
	var t := str(d.get("type", ""))
	return t in DIPLO_TYPES or t.begins_with("diplom")


static func diplo_decision(sim) -> Dictionary:
	if sim == null:
		return {}
	for d in sim.get_pending_decisions():
		if is_diplo_decision(d):
			return d
	return {}


static func choose_diplo(sim, d: Dictionary, i: int) -> bool:
	var t := str(d.get("type", "diplomacy"))
	for m in ["choose_" + t, "choose_diplomacy"]:
		if sim.has_method(m):
			return bool(sim.call(m, i))
	if sim.has_method("resolve_decision"):
		return bool(sim.call("resolve_decision", t, i))
	return false
