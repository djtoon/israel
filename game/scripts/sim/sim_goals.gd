class_name SimGoals
extends RefCounted
## V4 (v4-goals): era goals. Three real achievements per era (data/era_goals.json), each with a measurable condition,
## a deadline, a small reward and a small setback. Missing a goal is never a game over: a setback is a short lasting
## term or just the missed reward. ProjectSettings civ/era_goals = false switches the whole layer off (the v3 numbers).
##
## API (the goals card and the end screen read these):
##   sim.goals.view(era := -1) -> {era, era_name, era_note, goals: [{id, title, text, history, source, status: active|met|missed,
##       progress, progress_label, deadline, deadline_label, reward_text, setback_text, history_missed, ...}]}
##   sim.goals.all() -> [view of every era]
##   sim.goals.process_turn()   # once per quarter, at its end: evaluates, applies the reward or setback, notifies "goal" {goal, met}
##   sim.goals.start_turn()     # cheap; refreshes nothing the sim depends on
##   sim.goals.end_summary()    # the "Goals" section of get_end_summary()
## State lives in state.counters["goals"] (saved and loaded with the game).

const DATA_PATH := "res://data/era_goals.json"
const RAMP_Q := 16.0

static var _data := {}

var sim: Sim


func _init(s: Sim = null) -> void:
	sim = s


# ------------------------------------------------------------------ data and switch

static var _cli_off := -1


static func globally_enabled() -> bool:
	## The global switch: civ/era_goals (default true); the command-line flag --no-goals (sim_test) switches it off too.
	if _cli_off < 0:
		_cli_off = 1 if "--no-goals" in OS.get_cmdline_user_args() else 0
	if _cli_off == 1:
		return false
	return bool(ProjectSettings.get_setting("civ/era_goals", true))


func enabled() -> bool:
	## v4 fix round (v4fix-sim): the era goals follow the play style. Each game carries its own setting,
	## state.counters["goals_on"]: ON by default in story mode, OFF by default in Full control (so Full control is v3
	## exactly), and either way through Sim.new_game({"goals": true | false}) or set_enabled() mid-game. The global switch
	## (civ/era_goals = false, --no-goals) turns every game off.
	if not globally_enabled():
		return false
	if sim == null or sim.state == null:
		return true
	var c: Dictionary = sim.state.counters
	if c.has("goals_on"):
		return bool(c["goals_on"])
	# a save from before the setting: a v4 game that already judged goals keeps them; a v3 save has none
	return typeof(c.get("goals")) == TYPE_DICTIONARY and not (c["goals"].get("st", {}) as Dictionary).is_empty()


func on_new_game(opts: Dictionary) -> void:
	## Sim.new_game(): opts "goals" true / false (or "on" / "off"); absent or "auto" = on in story mode, off in Full control.
	if sim == null or sim.state == null:
		return
	var g = opts.get("goals", "auto")
	var on := str(opts.get("play_style", "full")) == "story"
	if typeof(g) == TYPE_BOOL:
		on = bool(g)
	elif str(g) in ["on", "true", "1"]:
		on = true
	elif str(g) in ["off", "false", "0"]:
		on = false
	sim.state.counters["goals_on"] = on


func set_enabled(on: bool) -> void:
	## The Settings switch, live on any turn. Rewards already earned stay; nothing is judged while it is off.
	if sim != null and sim.state != null:
		sim.state.counters["goals_on"] = on
		if sim.endgame != null:
			sim.endgame._legacy_turn = -1


static func data() -> Dictionary:
	if _data.is_empty():
		var txt := FileAccess.get_file_as_string(DATA_PATH)
		var d = JSON.parse_string(txt)
		_data = d if typeof(d) == TYPE_DICTIONARY else {"goals": []}
	return _data


static func reload() -> void:
	_data = {}


static func goal_defs() -> Array:
	return data().get("goals", [])


static func goal_def(id: String) -> Dictionary:
	for g in goal_defs():
		if str(g["id"]) == id:
			return g
	return {}


static func goal_turn(g: Dictionary) -> int:
	## The turn of the goal's date: the evaluation quarter ("at") or the deadline ("by").
	return SimDB.turn_of(str(g.get("at", g.get("by", ""))), 1)


func _gs() -> Dictionary:
	var c: Dictionary = sim.state.counters
	if typeof(c.get("goals")) != TYPE_DICTIONARY:
		c["goals"] = {"st": {}, "bonus": [], "disc": [], "last": 0}
	return c["goals"]


func status_of(id: String) -> String:
	var st: Dictionary = _gs()["st"]
	return str(st.get(id, {}).get("s", "active"))


# ------------------------------------------------------------------ conditions

func metric(m: String) -> float:
	var S: GameState = sim.state
	if m == "population":
		return sim.total_residents()
	if m == "cities":
		return float(sim.active_cities().size())
	if m == "avg_trust":
		return sim.score.avg_trust()
	if m.begins_with("trust:"):
		return sim.endgame._group_trust(m.substr(6))   # residents-weighted Civic Trust of a group: arab, dev_towns, periphery, large_cities
	if m.begins_with("project:"):
		return 1.0 if S.projects.has(m.substr(8)) else 0.0
	if m.begins_with("programme_level:"):
		return float(sim.endgame.levels_done(m.substr(16)))
	if m.begins_with("crisis_over:"):
		var wid := m.substr(12)   # a crisis id, or a war id (its crisis is "crisis_" + the war's event)
		var cid: String = "crisis_" + str(sim.db.wars.get(wid, {}).get("event", wid))
		for cr in S.crisis_log:
			if str(cr.get("id", "")) == wid or str(cr.get("id", "")) == cid:
				return 1.0
		return 0.0
	if m.begins_with("status:"):
		return 1.0 if str(S.diplomacy.get(m.substr(7), {}).get("status", "none")) != "none" else 0.0
	return sim.endgame.metric(m)


func _cond_value(c: Dictionary) -> float:
	var m := str(c["metric"])
	if c.has("in"):
		var actor := m.substr(7) if m.begins_with("status:") else m
		return 1.0 if str(sim.state.diplomacy.get(actor, {}).get("status", "none")) in c["in"] else 0.0
	return metric(m)


func _cond_ok(c: Dictionary, v: float) -> bool:
	if c.has("in"):
		return v >= 1.0
	if c.has("min"):
		return v >= float(c["min"])
	return v <= float(c.get("max", 0.0))


func _cond_progress(c: Dictionary, v: float) -> float:
	if c.has("in"):
		return 1.0 if v >= 1.0 else 0.0
	if c.has("min"):
		var t := float(c["min"])
		return clampf(v / t, 0.0, 1.0) if t > 0.0 else (1.0 if v >= t else 0.0)
	var mx := float(c.get("max", 0.0))
	if v <= mx:
		return 1.0
	return clampf(mx / maxf(0.0001, v), 0.0, 1.0)


static func _fmt(v: float, unit: String) -> String:
	match unit:
		"share": return "%.1f%%" % (v * 100.0)
		"ratio": return "%.2f" % v
		"millions": return "%.2fM" % (v / 1000000.0)
		"pct": return "%.0f%%" % v
		"level": return "level %d" % int(round(v))
	return "%d" % int(round(v)) if absf(v) >= 10.0 else "%.1f" % v


func _conds(g: Dictionary) -> Array:
	return g.get("all", g.get("any", []))


func evaluate(g: Dictionary) -> Dictionary:
	## {met, progress (0..1), label, values: [..]} for the goal's condition right now.
	var conds := _conds(g)
	var is_any: bool = g.has("any")
	var ok_all := true
	var ok_any := false
	var best := 0.0
	var worst := 1.0
	var rows := []
	var prog_c: Dictionary = {}
	var prog_v := 0.0
	var prog_p := -1.0
	for c in conds:
		var v := _cond_value(c)
		var p := _cond_progress(c, v)
		var ok := _cond_ok(c, v)
		ok_all = ok_all and ok
		ok_any = ok_any or ok
		best = maxf(best, p)
		worst = minf(worst, p)
		rows.append({"label": str(c.get("label", "")), "value": snappedf(v, 0.001), "target": float(c.get("min", c.get("max", 1.0))), "cmp": "in" if c.has("in") else (">=" if c.has("min") else "<="),
			"unit": str(c.get("unit", "")), "met": ok, "text": _fmt(v, str(c.get("unit", ""))) + (" / " + _fmt(float(c.get("min", c.get("max", 0.0))), str(c.get("unit", ""))) if not c.has("in") else "")})
		if prog_c.is_empty() and (not g.has("progress") or str(c["metric"]) == str(g["progress"])):
			prog_c = c; prog_v = v; prog_p = p
	if prog_c.is_empty() and not conds.is_empty():
		prog_c = conds[0]; prog_v = _cond_value(prog_c); prog_p = _cond_progress(prog_c, prog_v)
	if is_any and conds.size() > 1:
		# v4 fix round (veteran m5): an "any" goal shows the condition that met it (or the one closest to it), so a goal met
		# through the Ashkelon plant never reads "desalination level 0 / level 1"
		var bp := -1.0
		for c2 in conds:
			var v2 := _cond_value(c2)
			var p2 := 2.0 if _cond_ok(c2, v2) else _cond_progress(c2, v2)
			if p2 > bp:
				bp = p2; prog_c = c2; prog_v = v2; prog_p = p2
	var met := ok_any if is_any else ok_all
	var label := ""
	if not prog_c.is_empty():
		var unit := str(prog_c.get("unit", ""))
		if prog_c.has("in"):
			label = "%s: %s" % [str(prog_c.get("label", "")), "yes" if prog_v >= 1.0 else "not yet"]
		else:
			var tgt := float(prog_c.get("min", prog_c.get("max", 0.0)))
			label = "%s %s / %s%s" % [str(prog_c.get("label", "")), _fmt(prog_v, unit), "" if prog_c.has("min") else "max ", _fmt(tgt, unit)]
	var prog := (best if is_any else worst) if not conds.is_empty() else 0.0
	return {"met": met, "progress": snappedf(1.0 if met else prog, 0.01), "label": label, "conditions": rows}


# ------------------------------------------------------------------ the quarter

func start_turn() -> void:
	## Nothing the sim depends on; kept so the sim can call both hooks (SimGoals evaluates once per quarter, in process_turn).
	pass


func process_turn() -> void:
	if not enabled() or sim == null or sim.state == null:
		return
	var gs := _gs()
	var t: int = sim.state.turn
	if int(gs.get("last", 0)) >= t:
		return   # already evaluated this quarter (both hooks may call)
	gs["last"] = t
	var st: Dictionary = gs["st"]
	for g in goal_defs():
		var id := str(g["id"])
		if st.has(id):
			continue
		var at_t := goal_turn(g)
		if at_t < t and not st.has(id):
			# a scenario start (or an old save) past this goal's date: nothing to judge
			st[id] = {"s": "skipped", "t": t}
			continue
		var is_at: bool = str(g.get("check", "by")) == "at"
		var ev := evaluate(g)
		if is_at:
			if t == at_t:
				_resolve(g, bool(ev["met"]), ev)
		else:
			if bool(ev["met"]):
				_resolve(g, true, ev)
			elif t >= at_t:
				_resolve(g, false, ev)


func _resolve(g: Dictionary, met: bool, ev: Dictionary) -> void:
	var id := str(g["id"])
	var gs := _gs()
	gs["st"][id] = {"s": "met" if met else "missed", "t": sim.state.turn, "p": float(ev.get("progress", 0.0)), "l": str(ev.get("label", ""))}
	var eff: Dictionary = g.get("reward", {}) if met else g.get("setback", {})
	_apply(g, eff, met)
	var txt := ("Goal met: %s." % g.get("title", id)) if met else ("Goal missed: %s." % g.get("title", id))
	sim.notify("goal", txt, {"goal": id, "met": met})


func _apply(g: Dictionary, eff: Dictionary, met: bool) -> void:
	var S: GameState = sim.state
	var t: int = S.turn
	var gs := _gs()
	var kind := str(eff.get("kind", "none"))
	var why: String = "Goal: " + str(g.get("title", g["id"]))
	match kind:
		"track_bonus":
			gs["bonus"].append({"track": str(eff["track"]), "pct": float(eff["pct"]), "t": t})
			sim.endgame._legacy_turn = -1
		"programme_discount":
			gs["disc"].append({"programme": str(eff["programme"]), "pct": float(eff["pct"]), "levels": eff.get("levels", [])})
		"stream":
			var amount := float(eff.get("amount", 0.0))
			if str(eff["type"]) == "gold" and eff.has("income_pct"):
				amount = float(eff["income_pct"]) / 100.0 * float(S.counters.get("income_avg", 45.0))
			var s := {"type": str(eff["type"]), "amount": amount, "from": t + 1, "until": t + int(eff.get("quarters", 4)),
				"label": str(eff.get("label", g.get("title", ""))), "src": "goal"}
			if eff.has("group"):
				s["group"] = str(eff["group"])
			S.streams.append(s)
		"story_beat":
			if str(eff.get("text", "")) != "":
				sim.add_moment(str(eff.get("text", g.get("title", ""))), int(eff.get("era_score", 2)), "goal")
	var now: Dictionary = eff.get("now", {})
	for k in now:
		var a := float(now[k])
		match str(k):
			"standing": sim._change_standing(a, why, true)
			"readiness": S.readiness_bonus += a
			"trust": sim.add_trust_player(a)


# ------------------------------------------------------------------ effects read by SimEndgame

func track_bonus() -> Dictionary:
	## {track: percent}: reward bonuses, each growing to full over RAMP_Q quarters (added to SimEndgame.legacy()).
	var out := {}
	if not enabled() or sim == null or sim.state == null:
		return out
	for b in _gs()["bonus"]:
		var ramp := clampf(float(sim.state.turn - int(b["t"])) / RAMP_Q, 0.0, 1.0)
		out[str(b["track"])] = float(out.get(str(b["track"]), 0.0)) + float(b["pct"]) * ramp
	return out


func discount(pid: String, lv: int) -> float:
	## Cost multiplier for one programme level (1.0 = no discount).
	var m := 1.0
	if not enabled() or sim == null or sim.state == null:
		return m
	for d in _gs()["disc"]:
		if str(d["programme"]) != pid:
			continue
		var lvls: Array = d.get("levels", [])
		if lvls.is_empty() or lvls.has(lv) or lvls.has(float(lv)):
			m *= 1.0 - float(d["pct"]) / 100.0
	return m


# ------------------------------------------------------------------ views

func _quarter_label(turn: int) -> String:
	return SimDB.date_label(turn)


func goal_view(g: Dictionary) -> Dictionary:
	var id := str(g["id"])
	var stt := status_of(id)
	var ev := evaluate(g)
	var dt := goal_turn(g)
	var is_at: bool = str(g.get("check", "by")) == "at"
	var shown := "missed" if stt == "skipped" else stt
	var prog: float = 1.0 if stt == "met" else float(ev["progress"])
	var plabel := str(ev["label"])
	var judged: Dictionary = _gs()["st"].get(id, {})
	if stt == "missed" and judged.has("p"):   # v4final (vet N3): a missed goal keeps the value it was judged on, not today's (a full bar)
		prog = float(judged["p"])
		plabel = str(judged.get("l", plabel))
	return {"id": id, "title": str(g.get("title", "")), "text": str(g.get("text", "")), "history": str(g.get("history", "")),
		"source": g.get("source", []), "status": shown, "skipped": stt == "skipped", "progress": prog,
		"progress_label": plabel, "conditions": ev["conditions"], "deadline": dt, "deadline_year": SimDB.year_of(dt), "deadline_quarter": SimDB.quarter_of(dt), "deadline_label": ("at " if is_at else "by ") + _quarter_label(dt),
		"reward_text": str(g.get("reward", {}).get("desc", "")), "setback_text": str(g.get("setback", {}).get("desc", "")),
		"history_missed": bool(g.get("history_missed", false)), "check": str(g.get("check", "by")), "era": str(g.get("era", "")),
		"milestone": bool(g.get("milestone", false)),   # v4 fix round: a step on history's own path (the title says "Milestone: ...")
		"met_turn": int(_gs()["st"].get(id, {}).get("t", -1)) if stt in ["met", "missed"] else -1}


func view(era := -1) -> Dictionary:
	var db: SimDB = sim.db
	var idx: int = era if era > 0 else int(db.era_at(sim.state.turn).get("index", 1))
	var e: Dictionary = db.eras[clampi(idx - 1, 0, db.eras.size() - 1)] if db.eras.size() > 0 else {}
	var out := {"era": idx, "era_name": str(e.get("name", "")), "era_note": str(e.get("note", "")), "goals": []}
	if not enabled():
		return out
	var gl := goal_defs().filter(func(g): return str(g.get("era", "")) == "era%d" % idx)
	gl.sort_custom(func(a, b): return int(a.get("order", 0)) < int(b.get("order", 0)))
	for g in gl:
		out["goals"].append(goal_view(g))
	return out


func all() -> Array:
	var out := []
	var n: int = sim.db.eras.size()
	for i in range(1, n + 1):
		out.append(view(i))
	return out


func counts() -> Dictionary:
	var met := 0
	var missed := 0
	var judged := 0
	for g in goal_defs():
		match status_of(str(g["id"])):
			"met": met += 1; judged += 1
			"missed": missed += 1; judged += 1
	return {"met": met, "missed": missed, "judged": judged, "total": goal_defs().size()}


func end_summary() -> Dictionary:
	## The "Goals" section of get_end_summary(): met, missed and how each stands against history.
	if not enabled() or sim == null:
		return {}
	var list := []
	var both := 0
	var ahead := 0
	var behind := 0
	for g in goal_defs():
		var id := str(g["id"])
		var stt := status_of(id)
		if stt == "skipped" or stt == "active":
			continue
		var hm: bool = bool(g.get("ghost_meets", true)) and not bool(g.get("history_missed", false))
		var met := stt == "met"
		if met and hm: both += 1
		elif met and not hm: ahead += 1
		elif not met and hm: behind += 1
		list.append({"id": id, "title": str(g.get("title", "")), "era": str(g.get("era", "")), "status": stt, "history_met": hm,
			"history_missed": bool(g.get("history_missed", false)), "history": str(g.get("history", ""))})
	var c := counts()
	return {"met": c["met"], "missed": c["missed"], "judged": c["judged"], "total": c["total"], "met_like_history": both,
		"ahead_of_history": ahead, "behind_history": behind, "goals": list}
