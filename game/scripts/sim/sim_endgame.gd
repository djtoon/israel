class_name SimEndgame
extends RefCounted
## v3 (sim-endgame): the late-game climax and the end of the game.
##  - Difficulty (data/difficulty.json): ghost strength, 1948 treasury, inflation drift, enemy pressure, programme costs.
##  - National programmes (data/projects.json): real late-game programmes (start-ups, space and cyber, the missile
##    shield, desalination, the gas fields, peace dividends, health and Arab-sector development). Each level is paid
##    from the treasury in quarterly instalments; on completion it sets lasting terms (streams) and a track gain
##    (legacy, % of the track, growing over four years). History's ghost takes the historical levels on their real
##    dates; earlier launches, the non-historical levels and expansions are where a player gets ahead late.
##  - Endings (data/endings.json): four end states plus a mixed record, with thresholds shown during play, and an
##    epilogue built from the player's record.
##  - The top-bar fiscal indicator (debt, inflation and their trends) and the national food balance.
##  - Scenario starts (Q3 1967, Q3 1977, Q3 1992) seeded from the historical run (data/scenarios/).
## All state lives in state.counters["eg"] (saved with the game). Read-only for other modules.

const PROJECTS_PATH := "res://data/projects.json"
const ENDINGS_PATH := "res://data/endings.json"
const DIFFICULTY_PATH := "res://data/difficulty.json"
const SCENARIO_DIR := "res://data/scenarios/"
const SCENARIOS := [
	{"id": "1967", "date": "1967-07", "title": "After the Six-Day War", "briefing": "July 1967. The war of June has ended with Israel holding Sinai, Gaza, the West Bank, East Jerusalem and the Golan Heights. A national unity government under Levi Eshkol must decide what to do with the territories and their people, how to pay for a larger army, and how to answer the Arab League's summit in Khartoum."},
	{"id": "1977", "date": "1977-07", "title": "The upheaval", "briefing": "July 1977. For the first time since 1948 Labour is out of power: Menachem Begin's Likud has won the election. Inflation is above 30% and rising, and within months President Sadat of Egypt will announce he is ready to come to Jerusalem."},
	{"id": "1992", "date": "1992-07", "title": "The Oslo era", "briefing": "July 1992. Yitzhak Rabin's Labour government takes office promising a settlement within a year. The Madrid talks are under way, hundreds of thousands of immigrants from the former Soviet Union need homes and jobs, and the high-technology economy is about to take off."},
]
const EARLY_YEARS := 8.0        # a historical programme level can be launched up to 8 years before history ...
const EARLY_COST_PER_YEAR := 0.04   # ... at +4% cost per year early (as techs and civics)
const RAMP_Q := 16              # a completed level's track gain grows to its full size over four years
const EXPAND_DECAY := 0.8       # each further expansion of a programme gives 20% less ...
const EXPAND_GROWTH := 1.0      # ... and costs as much again as the first (x2, x3, x4)
const SURPLUS_EVERY := 2        # the "invest the surplus" decision comes at most twice a year
const TRACKS := ["population", "economy", "science", "water", "standing", "cohesion"]
const GROUP_NAMES := {"security": "security", "prosperity": "prosperity", "peace": "peace", "society": "society"}

static var _data := {}

var sim
var _legacy_cache := {}
var _legacy_turn := -1
var _legacy_state = null


func _init(s) -> void:
	sim = s


func S() -> GameState:
	return sim.state


# ================================================================== data

static func data() -> Dictionary:
	if _data.is_empty():
		_data = {"projects": _load_json(PROJECTS_PATH), "endings": _load_json(ENDINGS_PATH), "difficulty": _load_json(DIFFICULTY_PATH)}
		SimDB.scrub_programmes(_data["projects"])   # v3 fix3-story A11: no level dated after the game's end shows its date
		var by := {}
		for p in _data["projects"].get("programmes", []):
			by[str(p["id"])] = p
		_data["programme_by_id"] = by
	return _data


static func reload() -> void:
	_data = {}


static func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var d = JSON.parse_string(FileAccess.get_file_as_string(path))
	return d if typeof(d) == TYPE_DICTIONARY else {}


static func programme_defs() -> Array:
	if "--no-programmes" in OS.get_cmdline_user_args():
		return []   # sim_test switch: measure a run without national programmes
	return data()["projects"].get("programmes", [])


static func programme_def(pid: String) -> Dictionary:
	return data()["programme_by_id"].get(pid, {})


static func difficulty_levels() -> Array:
	## For the New Game screen: [{id, name, desc, ghost_strength, start_gold, inflation_drift, ai_pressure, programme_cost, ending_margin, hints}].
	return data()["difficulty"].get("levels", [])


static func validate(db: SimDB) -> Array:
	## Data errors in projects.json, endings.json and difficulty.json (sim_test --validate-only).
	var errs := []
	var d := data()
	if d["projects"].is_empty(): errs.append("data/projects.json missing or not an object")
	if d["endings"].is_empty(): errs.append("data/endings.json missing or not an object")
	if d["difficulty"].is_empty(): errs.append("data/difficulty.json missing or not an object")
	var ids := {}
	for p in programme_defs():
		var pid := str(p.get("id", ""))
		var w := "programme " + pid
		if pid == "" or ids.has(pid): errs.append(w + ": needs a unique id")
		ids[pid] = true
		for k in ["name", "desc", "groups", "levels", "source"]:
			if not p.has(k): errs.append("%s: missing \"%s\"" % [w, k])
		for g in p.get("groups", []):
			if not GROUP_NAMES.has(str(g)): errs.append("%s: unknown group %s" % [w, g])
		for sid in p.get("source", []):
			if not db.sources.has(str(sid)): errs.append("%s: source %s not found" % [w, sid])
		var n := 0
		for lv in p.get("levels", []):
			n += 1
			var lw := "%s level %d" % [w, n]
			if int(lv.get("level", 0)) != n: errs.append(lw + ": levels must be numbered 1, 2, 3 ...")
			var hist: bool = lv.get("hist") != null
			if hist and SimDB.turn_of(lv.get("hist"), -1) < 1: errs.append(lw + ": bad \"hist\" date")
			if not hist and SimDB.turn_of(lv.get("from"), -1) < 1: errs.append(lw + ": a non-historical level needs a \"from\" date")
			if not hist and str(lv.get("advocate", "")).strip_edges() == "": errs.append(lw + ": a non-historical level needs a named \"advocate\" (CONTRACT)")
			if float(lv.get("cost", 0)) <= 0.0 or int(lv.get("turns", 0)) < 1: errs.append(lw + ": needs cost > 0 and turns >= 1")
			var cites = lv.get("cite", [])
			if typeof(cites) != TYPE_ARRAY or cites.is_empty():
				errs.append(lw + ": needs a non-empty \"cite\" [{source, quote, url}]")
			else:
				for c in cites:
					var sid := str(c.get("source", ""))
					if not db.sources.has(sid):
						errs.append("%s: cite source %s not found" % [lw, sid])
						continue
					var meta: Dictionary = db.source_meta.get(sid, {"provenance": "opened", "quote": "x"})
					var needs: bool = meta.get("provenance", "opened") != "opened" or (meta.get("file", "") != "sources.json" and str(meta.get("quote", "")) == "")
					if needs and (str(c.get("quote", "")) == "" or not str(c.get("url", "")).begins_with("http")):
						errs.append("%s: cite %s needs a verbatim quote and an opened url" % [lw, sid])
					if str(c.get("url", "")).contains("wikipedia.org"):
						errs.append("%s: cite %s: no Wikipedia for new gameplay sources" % [lw, sid])
			for e in lv.get("effects", []):
				if not (str(e.get("type", "")) in SimDB.TERM_TYPES): errs.append("%s: effect type %s is not a stream type" % [lw, e.get("type", "")])
			for t in lv.get("legacy", {}):
				if not (str(t) in TRACKS): errs.append("%s: legacy track %s unknown" % [lw, t])
	var eids := {}
	var fb := 0
	errs.append_array(SimCollapse.validate())   # v3 item 13 (fix-v3a): the collapse endings
	for e in d["endings"].get("endings", []):
		var eid := str(e.get("id", ""))
		if eid == "" or eids.has(eid): errs.append("ending: needs a unique id")
		eids[eid] = true
		if e.get("fallback", false): fb += 1
		for c in e.get("criteria", []):
			if not (c.has("min") or c.has("max")): errs.append("ending %s criterion %s: needs min or max" % [eid, c.get("id", "")])
	if eids.size() < 5 or fb != 1: errs.append("endings.json: needs at least 4 endings plus exactly one fallback (mixed record)")
	var dl := 0
	for lvd in difficulty_levels():
		dl += 1
		for k in ["id", "name", "ghost_strength", "start_gold", "inflation_drift", "ai_pressure", "programme_cost"]:
			if not lvd.has(k): errs.append("difficulty %s: missing %s" % [lvd.get("id", "?"), k])
	if dl < 3: errs.append("difficulty.json: needs at least Easy, Normal and Hard")
	# the deleted 7 Oct 2023 / 2023- Gaza war content must never come back (tombstones)
	var blob := JSON.stringify(d["projects"]) + JSON.stringify(d["endings"])
	for did in db.deleted_ids:
		if blob.contains(str(did)): errs.append("deleted event id %s referenced in projects/endings data" % did)
	return errs


# ================================================================== state

func eg() -> Dictionary:
	if not S().counters.has("eg") or typeof(S().counters["eg"]) != TYPE_DICTIONARY:
		S().counters["eg"] = {"prog": {}, "offered": {}, "decision": {}, "fiscal": [], "spent": 0.0}
	return S().counters["eg"]


func pstate(pid: String) -> Dictionary:
	var pr: Dictionary = eg()["prog"]
	if not pr.has(pid):
		pr[pid] = {"done": {}, "active": {}, "expand": 0, "expand_turns": []}
	return pr[pid]


func _historical() -> bool:
	return SimAI.historical(sim)


# ================================================================== difficulty

func difficulty_id() -> String:
	return str(S().counters.get("difficulty", data()["difficulty"].get("default", "normal")))


func difficulty() -> Dictionary:
	var id := difficulty_id()
	for l in difficulty_levels():
		if str(l.get("id", "")) == id:
			return l
	return {"id": "normal", "name": "Normal", "ghost_strength": 1.0, "start_gold": 0, "inflation_drift": 1.0, "ai_pressure": 0, "programme_cost": 1.0, "ending_margin": 0.0, "hints": true}


func ghost_strength(track: String) -> float:
	if S().mode == "historical":
		return 1.0
	var g := float(difficulty().get("ghost_strength", 1.0))
	return sqrt(g) if track == "population" else g


func inflation_drift() -> float:
	return 1.0 if S().mode == "historical" else float(difficulty().get("inflation_drift", 1.0))


func ai_pressure() -> float:
	return 0.0 if S().mode == "historical" else float(difficulty().get("ai_pressure", 0.0))


func hints() -> bool:
	return bool(difficulty().get("hints", true))


func on_new_game(opts: Dictionary) -> void:
	## Called by Sim.new_game before the first turn starts: the chosen difficulty and its 1948 treasury.
	var d := str(opts.get("difficulty", data()["difficulty"].get("default", "normal")))
	var ok := false
	for l in difficulty_levels():
		if str(l.get("id", "")) == d: ok = true
	S().counters["difficulty"] = d if ok else "normal"
	eg()
	if S().mode != "historical":
		S().gold += float(difficulty().get("start_gold", 0))


func get_difficulty() -> Dictionary:
	var d := difficulty().duplicate()
	d["levels"] = difficulty_levels()
	return d


# ================================================================== national programmes

func _gs() -> float:
	return float(sim.events.gold_scale()) if sim.events != null else 1.0


func level_def(pid: String, lv: int) -> Dictionary:
	var p := programme_def(pid)
	var levels: Array = p.get("levels", [])
	if lv < 1 or lv > levels.size():
		return {}
	return levels[lv - 1]


func levels_done(pid: String) -> int:
	return pstate(pid)["done"].size()


func level_open_turn(pid: String, lv: int) -> int:
	## First turn the level may be launched (before requirements).
	var l := level_def(pid, lv)
	if l.is_empty():
		return 1 << 30
	if l.get("hist") != null:
		var ht := SimDB.turn_of(l["hist"], 1)
		var early := SimDB.turn_of(l.get("from"), ht - int(EARLY_YEARS * 4.0)) if l.has("from") else ht - int(EARLY_YEARS * 4.0)
		return maxi(1, early)
	return maxi(1, SimDB.turn_of(l.get("from"), 1))


func _requires_ok(req: Dictionary) -> String:
	## "" or the reason a requirement is unmet. Keys: tech, civic, status {actor: status|[...]}, programme {pid: level}.
	if req.has("tech") and not S().techs.has(str(req["tech"])):
		return "needs %s" % str(sim.db.techs.get(str(req["tech"]), {}).get("name", req["tech"]))
	if req.has("civic") and not S().civics.has(str(req["civic"])):
		return "needs the %s civic" % str(sim.db.civics.get(str(req["civic"]), {}).get("name", req["civic"]))
	var stq = req.get("status", {})
	if typeof(stq) == TYPE_DICTIONARY:
		for a in stq:
			var want = stq[a]
			var have := str(S().diplomacy.get(str(a), {}).get("status", ""))
			var wl: Array = want if typeof(want) == TYPE_ARRAY else [want]
			if not (have in wl):
				return "needs %s with %s" % [" or ".join(wl.map(func(x): return str(x).replace("_", " "))), sim.events.actor_name(str(a)) if sim.events != null else str(a)]
	var pq = req.get("programme", {})
	if typeof(pq) == TYPE_DICTIONARY:
		for p2 in pq:
			if levels_done(str(p2)) < int(pq[p2]):
				return "needs %s (level %d)" % [str(programme_def(str(p2)).get("name", p2)), int(pq[p2])]
	return ""


func level_reason(pid: String, lv: int) -> String:
	## "" if the level can be launched now (gold aside), else why not.
	var p := programme_def(pid)
	var l := level_def(pid, lv)
	if p.is_empty() or l.is_empty():
		return "no such programme level"
	var ps := pstate(pid)
	if ps["done"].has(str(lv)):
		return "completed"
	if not ps["active"].is_empty():
		return "a level of this programme is under way"
	if levels_done(pid) != lv - 1:
		return "needs level %d first" % (lv - 1)
	var ot := level_open_turn(pid, lv)
	if S().turn < ot:
		return "not before %s" % SimDB.date_label(ot)
	if l.has("until") and S().turn > SimDB.turn_of(l["until"], 1 << 30):
		return "the window closed in %s" % str(l["until"]).substr(0, 4)
	var r := _requires_ok(p.get("requires", {}))
	if r != "": return r
	return _requires_ok(l.get("requires", {}))


func level_cost(pid: String, lv: int) -> int:
	var l := level_def(pid, lv)
	if l.is_empty():
		return 0
	var c := float(l.get("cost", 100)) * _gs() * float(difficulty().get("programme_cost", 1.0))
	if l.get("hist") != null:
		var yrs := (SimDB.turn_of(l["hist"], S().turn) - S().turn) / 4.0
		if yrs > 0.0:
			c *= 1.0 + EARLY_COST_PER_YEAR * yrs
	if sim.goals != null: c *= sim.goals.discount(pid, lv)   # V4 (v4-goals): era-goal reward discounts
	return int(round(c))


func expand_def(pid: String) -> Dictionary:
	return programme_def(pid).get("expand", {})


func expand_reason(pid: String) -> String:
	var e := expand_def(pid)
	if e.is_empty():
		return "this programme cannot be expanded"
	var ps := pstate(pid)
	if not ps["active"].is_empty():
		return "a level of this programme is under way"
	if levels_done(pid) < int(e.get("after_level", programme_def(pid).get("levels", []).size())):
		return "complete level %d first" % int(e.get("after_level", programme_def(pid).get("levels", []).size()))
	if int(ps["expand"]) >= int(e.get("max", 3)):
		return "fully expanded"
	if e.has("from") and S().turn < SimDB.turn_of(e["from"], 1):
		return "not before %s" % str(e["from"]).substr(0, 4)
	return ""


func expand_cost(pid: String) -> int:
	var e := expand_def(pid)
	var n := int(pstate(pid)["expand"])
	return int(round(float(e.get("cost", 100)) * (1.0 + EXPAND_GROWTH * n) * _gs() * float(difficulty().get("programme_cost", 1.0))))


func _expand_legacy(pid: String, n: int) -> Dictionary:
	## Track gain of the n-th expansion (1-based).
	var out := {}
	var e := expand_def(pid)
	for t in e.get("legacy", {}):
		out[t] = float(e["legacy"][t]) * pow(EXPAND_DECAY, n - 1)
	return out


func launch(pid: String, lv := -1) -> bool:
	## Starts the next level of a programme (or level lv): paid in quarterly instalments, completes after its turns.
	if lv < 0:
		lv = levels_done(pid) + 1
	if level_reason(pid, lv) != "":
		return false
	var l := level_def(pid, lv)
	var cost := level_cost(pid, lv)
	var turns := maxi(1, int(l.get("turns", 4)))
	if not _historical() and S().gold < float(cost) / turns:
		return false
	pstate(pid)["active"] = {"kind": "level", "level": lv, "from": S().turn, "turns": turns, "paid_q": 0, "cost": cost, "instalment": float(cost) / turns}
	sim.notify("programme", "%s: %s launched (%s gold over %d quarters)." % [programme_def(pid).get("name", pid), l.get("name", ""), _fmt(cost), turns], {"programme": pid, "level": lv})
	_legacy_turn = -1
	return true


func expand(pid: String) -> bool:
	if expand_reason(pid) != "":
		return false
	var e := expand_def(pid)
	var cost := expand_cost(pid)
	var turns := maxi(1, int(e.get("turns", 4)))
	if S().gold < float(cost) / turns:
		return false
	pstate(pid)["active"] = {"kind": "expand", "level": int(pstate(pid)["expand"]) + 1, "from": S().turn, "turns": turns, "paid_q": 0, "cost": cost, "instalment": float(cost) / turns}
	sim.notify("programme", "%s: %s (%s gold over %d quarters)." % [programme_def(pid).get("name", pid), e.get("name", "expansion"), _fmt(cost), turns], {"programme": pid, "expand": true})
	return true


func cancel(pid: String) -> bool:
	## Stops the level under way; instalments already paid are lost.
	var ps := pstate(pid)
	if ps["active"].is_empty():
		return false
	ps["active"] = {}
	return true


func _complete(pid: String, act: Dictionary) -> void:
	var ps := pstate(pid)
	var p := programme_def(pid)
	var effs: Array
	var name: String
	if str(act.get("kind", "level")) == "expand":
		ps["expand"] = int(ps["expand"]) + 1
		ps["expand_turns"].append(S().turn)
		effs = expand_def(pid).get("effects", [])
		name = str(expand_def(pid).get("name", "expansion"))
	else:
		var lv := int(act["level"])
		ps["done"][str(lv)] = S().turn
		effs = level_def(pid, lv).get("effects", [])
		name = str(level_def(pid, lv).get("name", ""))
		S().milestones["programme:%s:%d" % [pid, lv]] = S().turn
	ps["active"] = {}
	for e in effs:
		var a := float(e.get("amount", 0))
		if str(e.get("type", "")) == "gold":
			a *= _gs()
		var s := {"type": str(e["type"]), "amount": a, "from": S().turn + 1, "until": SimDB.turn_of(e.get("until"), SimDB.LAST_TURN),
			"label": "%s: %s" % [p.get("name", pid), name], "src": "programme:" + pid}
		if e.has("group"): s["group"] = e["group"]
		S().streams.append(s)
	sim.econ.rebuild_mods()
	_legacy_turn = -1
	var lg := []
	var leg: Dictionary = _expand_legacy(pid, int(ps["expand"])) if str(act.get("kind", "level")) == "expand" else level_def(pid, int(act["level"])).get("legacy", {})
	for t in leg:
		lg.append("%s %+.0f%%" % [str(t).capitalize(), float(leg[t])])
	sim.notify("programme", "%s completed: %s.%s" % [p.get("name", pid), name, (" Track gains (over four years): " + ", ".join(lg) + ".") if not lg.is_empty() else ""], {"programme": pid})
	sim.add_moment("%s: %s" % [p.get("name", pid), name], 2 if str(act.get("kind", "")) == "expand" else 3, "programme")


func process_turn() -> void:
	## Once a quarter, after the budget: instalments of the levels under way, completions.
	var spent := 0.0
	for p in programme_defs():
		var pid := str(p["id"])
		var ps := pstate(pid)
		var act: Dictionary = ps["active"]
		if act.is_empty():
			continue
		var inst := float(act.get("instalment", 0.0))
		if S().gold >= inst or _historical():
			S().gold -= inst
			spent += inst
			act["paid_q"] = int(act.get("paid_q", 0)) + 1
		elif not act.get("stalled_noted", false):
			act["stalled_noted"] = true
			sim.notify("programme", "%s is paused: the treasury cannot pay this quarter's instalment (%s gold)." % [p.get("name", pid), _fmt(inst)], {"programme": pid})
		if int(act.get("paid_q", 0)) >= int(act.get("turns", 1)):
			_complete(pid, act)
	eg()["spent"] = float(eg().get("spent", 0.0)) + spent
	if spent > 0.0:
		var lb: Dictionary = S().counters.get("last_budget", {})
		lb["programmes"] = -spent
		S().counters["last_budget"] = lb
	_note_fiscal()


func start_turn() -> void:
	## Each quarter (before the score sample): history launches its own programmes on their dates; the player gets
	## the quarter's programme decision.
	if _historical():
		for p in programme_defs():
			var pid := str(p["id"])
			var lv := levels_done(pid) + 1
			var l := level_def(pid, lv)
			if l.is_empty() or l.get("hist") == null or not pstate(pid)["active"].is_empty():
				continue
			if S().turn >= SimDB.turn_of(l["hist"], 1 << 30) and level_reason(pid, lv) == "":
				launch(pid, lv)
	if S().mode != "historical":
		_make_decision()


func legacy() -> Dictionary:
	## Track gains from completed programmes: {track: percent}, each growing to full over RAMP_Q quarters.
	if _legacy_turn == S().turn and _legacy_state == S() and not _legacy_cache.is_empty():
		return _legacy_cache
	var out := {}
	for t in TRACKS: out[t] = 0.0
	for p in programme_defs():
		var pid := str(p["id"])
		var ps := pstate(pid)
		for k in ps["done"]:
			var ramp := clampf(float(S().turn - int(ps["done"][k])) / RAMP_Q, 0.0, 1.0)
			var leg: Dictionary = level_def(pid, int(k)).get("legacy", {})
			for t in leg:
				out[t] = float(out.get(t, 0.0)) + float(leg[t]) * ramp
		var n := 0
		for et in ps["expand_turns"]:
			n += 1
			var ramp2 := clampf(float(S().turn - int(et)) / RAMP_Q, 0.0, 1.0)
			var leg2 := _expand_legacy(pid, n)
			for t in leg2:
				out[t] = float(out.get(t, 0.0)) + float(leg2[t]) * ramp2
	if sim.goals != null:   # V4 (v4-goals): era-goal reward bonuses
		var gb: Dictionary = sim.goals.track_bonus()
		for t in gb: out[t] = float(out.get(t, 0.0)) + float(gb[t])
	_legacy_cache = out
	_legacy_turn = S().turn
	_legacy_state = S()
	return out


# v3 fix3-econ (A7): choices leave a lasting mark. A share of every lasting term a cabinet decision set (forks, event
# choices, envoys and deals) stays as the term runs and after it ends. SimScore weighs the player's tracks by the
# DIFFERENCE between this mark and the one history's own choices left by the same date (ghost.json rows, "clg"), so a
# path's upsides and downsides against history's compound to the end of the game instead of vanishing when the terms
# expire. CHOICE_LEGACY_K percent of the track per "typical" term (SimDB.TERM_TYPICAL) per 8 years of its run (at most
# 3 x 8 years); group terms count half; softly capped at CHOICE_LEGACY_CAP. Population is left out (it stays the
# residents count that the census check compares).
const CHOICE_LEGACY_K := 0.8
const CHOICE_LEGACY_CAP := 35.0
const CHOICE_LEGACY_TRACK := {"output_pct": "economy", "inflation": "economy", "standing": "standing", "standing_target": "standing",
	"trust": "cohesion", "trust_base": "cohesion", "cohesion": "cohesion", "amenity": "cohesion", "science_pct": "science",
	"water": "water"}
var _clegacy_cache := {}
var _clegacy_turn := -1
var _clegacy_state = null


static func is_choice_term(s: Dictionary) -> bool:
	var src := str(s.get("src", ""))
	return src != "" and not (src.begins_with("programme:") or src.begins_with("privatise:") or src in ["coalition", "stabilisation", "cabinet", "rail", "budget_review", "goal"])


func choice_legacy() -> Dictionary:
	## {track: percent}: the lasting mark the lasting terms of the cabinet's decisions have left so far.
	if _clegacy_turn == S().turn and _clegacy_state == S() and not _clegacy_cache.is_empty():
		return _clegacy_cache
	var out := {}
	for t in ["economy", "science", "water", "standing", "cohesion"]: out[t] = 0.0
	var now := S().turn
	for s in S().streams:
		var ty := str(s.get("type", ""))
		if not CHOICE_LEGACY_TRACK.has(ty) or not is_choice_term(s): continue
		var f := int(s.get("from", 0))
		if f > now: continue
		var yrs := float(mini(now, int(s.get("until", 0))) - f + 1) / 4.0
		if yrs <= 0.0: continue
		var v := float(s.get("amount", 0.0)) / float(SimDB.TERM_TYPICAL.get(ty, 1.0)) * clampf(yrs / 8.0, 0.0, 3.0)
		if ty == "inflation": v = -v
		if str(s.get("group", "all")) != "all": v *= 0.5
		var tr: String = CHOICE_LEGACY_TRACK[ty]
		out[tr] = float(out[tr]) + v * CHOICE_LEGACY_K
	for t2 in out: out[t2] = CHOICE_LEGACY_CAP * tanh(float(out[t2]) / CHOICE_LEGACY_CAP)
	_clegacy_cache = out
	_clegacy_turn = now
	_clegacy_state = S()
	return out


func choice_legacy_vs_history() -> Dictionary:
	## {track: percentage points} the player's mark minus history's by this date ({} for history's ghost or an old ghost).
	if S().mode == "historical" or sim.score == null: return {}
	var g: Dictionary = sim.score.ghost_at(S().turn)
	if not g.has("clg"): return {}
	var gl: Dictionary = g["clg"]
	var mine := choice_legacy()
	var out := {}
	for t in mine: out[t] = float(mine[t]) - float(gl.get(t, 0.0))
	return out


func group_levels(group: String) -> int:
	## Completed levels and expansions of the programmes in a group (endings).
	var n := 0
	for p in programme_defs():
		if not (group in p.get("groups", [])): continue
		var ps := pstate(str(p["id"]))
		n += ps["done"].size() + int(ps["expand"])
	return n


func ghost_group_levels(group: String) -> int:
	## Levels history's ghost had completed in a group by this date (ghost.json milestones "programme:<id>:<level>").
	var gm: Dictionary = sim.db.ghost.get("milestones", {})
	var n := 0
	for p in programme_defs():
		if not (group in p.get("groups", [])): continue
		for l in p.get("levels", []):
			var k := "programme:%s:%d" % [str(p["id"]), int(l["level"])]
			if gm.has(k) and int(gm[k]) <= S().turn: n += 1
	return n


func _effects_text(effs: Array) -> Array:
	var out := []
	for e in effs:
		var a := float(e.get("amount", 0))
		var grp := str(e.get("group", ""))
		var gname: String = {"arab": " in Arab localities", "dev_towns": " in development towns", "periphery": " in the periphery", "large_cities": " in the large cities"}.get(grp, "")
		match str(e.get("type", "")):
			"gold": out.append("%+d Gold per turn" % int(round(a * _gs())))
			"standing_target": out.append("Standing settles %+.0f higher" % a)
			"trust_base": out.append("Civic Trust settles %+.1f%s" % [a, gname])
			"readiness": out.append("%+.0f Readiness" % a)
			"output_pct": out.append("%+.0f%% Production and Gold" % a)
			"science_pct": out.append("%+.0f%% Science" % a)
			"growth_pct": out.append("%+.1f%% population growth" % a)
			"water": out.append("%+.0f million m3 of water a year" % a)
			"cohesion": out.append("%+.1f Cohesion per turn" % a)
			"inflation": out.append("%+.1f points of inflation" % a)
			"trust": out.append("%+.1f Civic Trust per turn" % a)
			"amenity": out.append("%+.0f Amenity%s" % [a, gname])
			"retention": out.append("%+.0f%% immigrant retention" % a)
			_: out.append("%s %+.1f" % [str(e.get("type", "")), a])
	return out


func _legacy_text(leg: Dictionary) -> Array:
	var out := []
	for t in leg:
		out.append("%s track %+.1f%% (grows over four years)" % [sim.score.TRACK_SHORT.get(t, str(t)), float(leg[t])])
	return out


func _struct(effs: Array, leg: Dictionary, cost: int, turns: int) -> Array:
	## Structured effects (API v2 format) for the decision popup.
	var out := [{"stat": "gold", "amount": -cost, "unit": "gold", "label": "%s gold over %d quarters" % [_fmt(cost), turns], "good": false}]
	var st := {"gold": "gold", "standing_target": "standing", "trust_base": "trust", "readiness": "readiness", "output_pct": "production",
		"science_pct": "science", "growth_pct": "population", "water": "water", "cohesion": "cohesion", "inflation": "inflation", "trust": "trust", "amenity": "amenity", "retention": "population"}
	var lines := _effects_text(effs)
	for i in range(effs.size()):
		var t := str(effs[i].get("type", ""))
		var a := float(effs[i].get("amount", 0))
		out.append({"stat": st.get(t, t), "amount": a, "unit": t, "label": lines[i], "when": "from completion to the end of the game", "good": (a < 0.0) if t == "inflation" else (a > 0.0)})
	for t in leg:
		out.append({"stat": {"population": "population", "economy": "economy", "science": "science", "water": "water", "standing": "standing", "cohesion": "trust"}.get(t, t),
			"amount": float(leg[t]), "unit": "% track", "label": "%s track %+.1f%%" % [sim.score.TRACK_SHORT.get(t, str(t)), float(leg[t])], "when": "grows over four years", "good": float(leg[t]) > 0.0})
	return out


func get_programmes() -> Array:
	## The Programmes panel: [{id, name, groups, desc, source, levels: [{level, name, desc, hist, hist_label, historical,
	##   advocate, status: done|active|available|locked, reason, cost, turns, done_turn, effects: [text], legacy: {track: %},
	##   cite}], active: {kind, level, quarters_left, instalment} | {}, expand: {name, desc, count, max, cost, reason, legacy},
	##   legacy_now: {track: %}, history_level (levels history had completed by now)}].
	var out := []
	var gm: Dictionary = sim.db.ghost.get("milestones", {})
	for p in programme_defs():
		var pid := str(p["id"])
		var ps := pstate(pid)
		var lvs := []
		var hist_now := 0
		for l in p.get("levels", []):
			var lv := int(l["level"])
			var status := "locked"
			var why := level_reason(pid, lv)
			if ps["done"].has(str(lv)): status = "done"
			elif not ps["active"].is_empty() and str(ps["active"].get("kind", "")) == "level" and int(ps["active"].get("level", 0)) == lv: status = "active"
			elif why == "": status = "available"
			if gm.has("programme:%s:%d" % [pid, lv]) and int(gm["programme:%s:%d" % [pid, lv]]) <= S().turn: hist_now = lv
			lvs.append({"level": lv, "name": str(l.get("name", "")), "desc": str(l.get("desc", "")), "hist": l.get("hist"),
				"hist_label": SimDB.date_label(SimDB.turn_of(l["hist"], 1)) if l.get("hist") != null else "",
				"historical": l.get("hist") != null, "advocate": str(l.get("advocate", "")), "status": status, "reason": why if status == "locked" else "",
				"cost": level_cost(pid, lv), "turns": int(l.get("turns", 4)), "done_turn": int(ps["done"].get(str(lv), 0)),
				"effects": _effects_text(l.get("effects", [])) + _legacy_text(l.get("legacy", {})), "legacy": l.get("legacy", {}), "cite": l.get("cite", [])})
		var act: Dictionary = ps["active"]
		var av := {}
		if not act.is_empty():
			av = {"kind": act.get("kind", "level"), "level": int(act.get("level", 0)), "quarters_left": int(act.get("turns", 1)) - int(act.get("paid_q", 0)),
				"instalment": float(act.get("instalment", 0.0)), "cost": int(act.get("cost", 0))}
		var e := expand_def(pid)
		var ev := {}
		if not e.is_empty():
			ev = {"name": str(e.get("name", "")), "desc": str(e.get("desc", "")), "count": int(ps["expand"]), "max": int(e.get("max", 3)),
				"cost": expand_cost(pid), "turns": int(e.get("turns", 4)), "reason": expand_reason(pid), "legacy": _expand_legacy(pid, int(ps["expand"]) + 1),
				"effects": _effects_text(e.get("effects", [])) + _legacy_text(_expand_legacy(pid, int(ps["expand"]) + 1))}
		var lnow := {}
		for k in ps["done"]:
			var ramp := clampf(float(S().turn - int(ps["done"][k])) / RAMP_Q, 0.0, 1.0)
			var leg: Dictionary = level_def(pid, int(k)).get("legacy", {})
			for t in leg: lnow[t] = float(lnow.get(t, 0.0)) + float(leg[t]) * ramp
		out.append({"id": pid, "name": str(p.get("name", pid)), "groups": p.get("groups", []), "desc": str(p.get("desc", "")), "source": p.get("source", []),
			"levels": lvs, "levels_done": ps["done"].size(), "active": av, "expand": ev, "legacy_now": lnow, "history_level": hist_now})
	return out


# ------------------------------------------------------------------ the programme decision

func _value(leg: Dictionary, effs: Array, weights: Dictionary) -> float:
	var v := 0.0
	for t in leg:
		v += float(leg[t]) * float(weights.get(t, 1.0))
	for e in effs:
		var t := str(e.get("type", ""))
		var a := float(e.get("amount", 0)) / float(SimDB.TERM_TYPICAL.get(t, 1.0))
		if t == "inflation": a = -a
		v += a * 0.8 * float(weights.get(str(SimDB.TERM_TRACK.get(t, "economy")), 1.0))
	return v


func track_weights() -> Dictionary:
	## How much each track's gain is worth now: tracks behind history count more (Recommended picks).
	var w := {}
	var cur: Dictionary = sim.score.current_ratios()
	for t in TRACKS:
		w[t] = clampf(1.0 + 2.0 * (1.0 - float(cur.get(t, 1.0))), 0.6, 2.0)
	w["readiness"] = 0.5 if S().readiness > 85.0 else 1.0
	return w


func candidates(weights := {}) -> Array:
	## Every programme action available now: [{id, kind: "launch"|"expand", programme, level, label, desc, cost, turns,
	##   instalment, effects, legacy, value, affordable, historical, hist_label}] (best value per gold first).
	if weights.is_empty():
		weights = track_weights()
	var out := []
	for p in programme_defs():
		var pid := str(p["id"])
		var lv := levels_done(pid) + 1
		var l := level_def(pid, lv)
		if not l.is_empty() and level_reason(pid, lv) == "":
			var c := level_cost(pid, lv)
			var t := int(l.get("turns", 4))
			out.append({"id": "launch:%s:%d" % [pid, lv], "kind": "launch", "programme": pid, "level": lv, "groups": p.get("groups", []),
				"label": "%s: %s" % [p.get("name", pid), l.get("name", "")], "desc": str(l.get("desc", "")), "cost": c, "turns": t,
				"instalment": float(c) / t, "effects": l.get("effects", []), "legacy": l.get("legacy", {}), "historical": l.get("hist") != null,
				"hist_label": str(l["hist"]).substr(0, 4) if l.get("hist") != null else "", "advocate": str(l.get("advocate", "")), "cite": l.get("cite", []),
				"value": _value(l.get("legacy", {}), l.get("effects", []), weights), "affordable": S().gold >= float(c) / t})
		elif expand_reason(pid) == "":
			var e := expand_def(pid)
			var c2 := expand_cost(pid)
			var t2 := int(e.get("turns", 4))
			var leg := _expand_legacy(pid, int(pstate(pid)["expand"]) + 1)
			out.append({"id": "expand:%s" % pid, "kind": "expand", "programme": pid, "level": int(pstate(pid)["expand"]) + 1, "groups": p.get("groups", []),
				"label": "%s: %s (%d of %d)" % [p.get("name", pid), e.get("name", "expand"), int(pstate(pid)["expand"]) + 1, int(e.get("max", 3))],
				"desc": str(e.get("desc", "")), "cost": c2, "turns": t2, "instalment": float(c2) / t2, "effects": e.get("effects", []), "legacy": leg,
				"historical": false, "hist_label": "", "advocate": "", "cite": [],
				"value": _value(leg, e.get("effects", []), weights), "affordable": S().gold >= float(c2) / t2})
	for o in out:
		o["value_per_gold"] = float(o["value"]) / maxf(1.0, float(o["cost"]) / maxf(1.0, _gs()))
	out.sort_custom(func(a, b): return float(a["value_per_gold"]) > float(b["value_per_gold"]))
	return out


func reserve() -> float:
	## The treasury the Recommended pick keeps in hand after an instalment (one quarter of gross income).
	return maxf(45.0, float(S().counters.get("income_avg", 45.0)))


func _can_carry(c: Dictionary) -> bool:
	## Recommended test: two instalments and half a quarter's income stay covered.
	return S().gold - 2.0 * float(c["instalment"]) >= 0.5 * reserve()


func _make_decision() -> void:
	var d: Dictionary = eg().get("decision", {})
	if int(d.get("turn", -1)) == S().turn:
		return
	eg()["decision"] = {}
	var cands := candidates()
	if cands.is_empty():
		return
	var offered: Dictionary = eg()["offered"]
	var kind := ""
	var picks := []
	# 1. a level opens (first quarter it can be launched)
	var fresh := cands.filter(func(c): return c["kind"] == "launch" and not offered.has("%s:%d" % [c["programme"], c["level"]]))
	# 2. history's date for a level the player has not launched
	var due := cands.filter(func(c): return c["kind"] == "launch" and c["historical"] and not offered.has("due:%s:%d" % [c["programme"], c["level"]]) 		and S().turn >= SimDB.turn_of(level_def(str(c["programme"]), int(c["level"])).get("hist"), 1 << 30))
	if not fresh.is_empty():
		kind = "open"
		fresh.sort_custom(func(a, b): return level_open_turn(str(a["programme"]), int(a["level"])) < level_open_turn(str(b["programme"]), int(b["level"])))
		picks = [fresh[0]]
		offered["%s:%d" % [fresh[0]["programme"], fresh[0]["level"]]] = S().turn
	elif not due.is_empty():
		kind = "due"
		picks = [due[0]]
		offered["due:%s:%d" % [due[0]["programme"], due[0]["level"]]] = S().turn
	elif S().turn - int(eg().get("last_surplus", -99)) >= SURPLUS_EVERY or S().gold >= 4.0 * reserve():   # fix-v3a: a large surplus is offered every quarter
		var af := cands.filter(func(c): return c["affordable"] and S().gold >= 2.0 * float(c["instalment"]))
		if af.is_empty():
			return
		kind = "surplus"
		picks = af.slice(0, 3)
		eg()["last_surplus"] = S().turn
	else:
		return
	var opts := []
	for c in picks:
		opts.append(_option_from(c))
	if kind != "surplus":
		opts.append({"id": "defer", "label": "Not now: keep it on the national agenda", "desc": "The programme stays open in the Programmes list; it can be launched in any later quarter.",
			"effects": [], "effects_text": ["No cost now"], "fx": {}, "default": false})
	else:
		if sim.econ.debt() > 1.0:
			var rp := int(round(minf(sim.econ.debt(), maxf(0.0, S().gold - reserve()) * 0.6)))
			if rp > 0:
				opts.append({"id": "repay_debt", "label": "Repay public debt early: %s gold" % _fmt(rp), "desc": "Buy back debt: lower interest from next quarter and a healthier economy track.",
					"amount": rp, "effects": [{"stat": "gold", "amount": -rp, "unit": "gold", "label": "%s gold to the lenders" % _fmt(rp), "good": false}],
					"effects_text": ["-%s gold now; public debt -%s" % [_fmt(rp), _fmt(rp)]], "fx": {}, "default": false})
		opts.append({"id": "hold", "label": "Hold the reserve", "desc": "Keep the surplus in the treasury for emergencies and purchases.", "effects": [], "effects_text": ["No cost"], "fx": {}, "default": false})
	# Recommended: the best option the treasury can carry; a debt above a year of revenue is repaid first; else defer / hold
	var rec := opts.size() - 1
	for i in range(picks.size()):
		# fix-v3a: a level that opens (or falls due) is Recommended when the treasury can pay its first instalment and
		# keep a quarter of the reserve (a paused instalment is not lost); a surplus investment keeps the stricter test
		if _can_carry(picks[i]) or (kind != "surplus" and S().gold - float(picks[i]["instalment"]) >= 0.25 * reserve()):
			rec = i
			break
	if kind == "surplus" and metric("debt_years") > 1.0:
		for i in range(opts.size()):
			if str(opts[i]["id"]) == "repay_debt": rec = i
	opts[rec]["default"] = true
	var first: Dictionary = picks[0]
	var title := "NATIONAL PROGRAMMES: INVEST THE SURPLUS"
	var text := ""
	if kind != "surplus":
		title = "NATIONAL PROGRAMME: %s" % str(first["label"])
		var hl := ("History launched it in %s." % first["hist_label"]) if first["historical"] else ("Not done in history: proposed by %s." % first.get("advocate", ""))
		if kind == "due": hl = "History launched it this year (%s); you have not yet." % first["hist_label"]
		text = "%s %s" % [str(first["desc"]), hl]
	else:
		text = "The treasury holds %s gold. National programmes turn a surplus into lasting gains on the six tracks; each is paid in quarterly instalments, and the Recommended pick keeps half a quarter's income in hand." % _fmt(S().gold)
	eg()["decision"] = {"turn": S().turn, "kind": kind, "title": title, "text": text, "options": opts, "done": false}


func _option_from(c: Dictionary) -> Dictionary:
	var lines := _effects_text(c["effects"]) + _legacy_text(c["legacy"])
	var head := "%s gold over %d quarters (%s a quarter)" % [_fmt(int(c["cost"])), int(c["turns"]), _fmt(float(c["instalment"]))]
	var hist := ""
	if c["kind"] == "launch":
		hist = (" History: %s." % c["hist_label"]) if c["historical"] else (" Not done in history; proposed by %s." % c.get("advocate", ""))
	return {"id": str(c["id"]), "label": "%s (%s gold)" % [str(c["label"]), _fmt(int(c["cost"]))], "desc": "%s. %s.%s" % [str(c["desc"]).trim_suffix("."), head, hist],
		"cost": int(c["cost"]), "turns": int(c["turns"]), "instalment": float(c["instalment"]), "historical": bool(c["historical"]), "hist_label": str(c["hist_label"]),
		"effects": _struct(c["effects"], c["legacy"], int(c["cost"]), int(c["turns"])), "effects_text": [head] + lines, "fx": {}, "cite": c.get("cite", []),
		"advocate": str(c.get("advocate", "")), "available": bool(c["affordable"]), "default": false, "value": float(c["value"])}


func decision_due() -> bool:
	var d: Dictionary = eg().get("decision", {})
	return not d.is_empty() and int(d.get("turn", -1)) == S().turn and not d.get("done", false)


func programme_decision() -> Dictionary:
	var d: Dictionary = eg().get("decision", {})
	return {"type": "programme", "blocking": true, "label": str(d.get("title", "NATIONAL PROGRAMMES")), "kind": str(d.get("kind", "")),
		"text": str(d.get("text", "")), "options": d.get("options", []), "programmes": "see get_programmes()",
		"explain": "National programmes are the late-game projects of a state: you pay for them from the treasury in quarterly instalments, and once complete they leave lasting terms and a gain on one or more of the six tracks. History's ghost takes the historical ones on their real dates."}


func choose_programme(index: int) -> bool:
	if not decision_due():
		return false
	var d: Dictionary = eg()["decision"]
	var opts: Array = d.get("options", [])
	if index < 0 or index >= opts.size():
		return false
	var o: Dictionary = opts[index]
	var id := str(o["id"])
	var ok := true
	if id.begins_with("launch:"):
		var parts := id.split(":")
		ok = launch(parts[1], int(parts[2]))
	elif id.begins_with("expand:"):
		ok = expand(id.substr(7))
	elif id == "repay_debt":
		sim.econ.repay(float(o.get("amount", 0)))
	if not ok:
		return false
	d["done"] = true
	d["chosen"] = index
	var log_: Array = eg().get("log", [])
	log_.append([S().turn, id])
	eg()["log"] = log_.slice(maxi(0, log_.size() - 300))
	return true


func defer_to_next_quarter() -> bool:
	## v4 (v4-sim-auto, V4_DESIGN 2.4 rule 3): the casual layer's Finance answers "not now" to a programme decision in a
	## quarter that already holds three player decisions; a level that opened (or fell due) is offered again next quarter,
	## so no opening is lost. A surplus is simply held. Never called in a v3 (Full control) game.
	if not decision_due():
		return false
	var d: Dictionary = eg()["decision"]
	var opts: Array = d.get("options", [])
	var kind := str(d.get("kind", ""))
	var hold := -1
	for i in range(opts.size()):
		if str(opts[i].get("id", "")) in ["defer", "hold"]: hold = i
	if hold < 0:
		return false
	if kind in ["open", "due"]:
		var offered: Dictionary = eg()["offered"]
		for o in opts:
			var oid := str(o.get("id", ""))
			if oid.begins_with("launch:"):
				var parts := oid.split(":")
				offered.erase(("%s:%s" if kind == "open" else "due:%s:%s") % [parts[1], parts[2]])
				break
	return choose_programme(hold)


func auto_resolve() -> void:
	## Forced end of turn: history's choice (launch a historical level once its date has come), else defer / hold.
	if not decision_due():
		return
	var opts: Array = eg()["decision"].get("options", [])
	for i in range(opts.size()):
		var o: Dictionary = opts[i]
		if str(o["id"]).begins_with("launch:") and o.get("historical", false) and S().turn >= SimDB.turn_of(str(o.get("hist_label", "9999")) + "-01", 1 << 30) and choose_programme(i):
			return
	for i in range(opts.size()):
		if str(opts[i]["id"]) in ["defer", "hold"]:
			choose_programme(i)
			return
	eg()["decision"]["done"] = true


# ================================================================== endings

func _ratio(track: String) -> float:
	return float(sim.score.current_ratios().get(track, 1.0))


func _town_strikes() -> int:
	var n := 0
	for cr in S().crisis_log:
		n += int(cr.get("city_hits", 0))
	for cr in S().crises:
		if cr.get("active", true): n += int(cr.get("city_hits", 0))
	return n


func treaties() -> Array:
	## Actors at peace or in normal relations with Israel (treaties in force). sim-diplomacy may refine this
	## (SimDiplomacy.treaties_in_force()); the endings read whichever exists.
	if sim.has_method("treaties_in_force"):
		return sim.call("treaties_in_force")
	var out := []
	for a in S().diplomacy:
		var st := str(S().diplomacy[a].get("status", ""))
		if st in ["peace", "normalized"] and not (a in ["usa", "uk", "france", "west_germany", "ussr", "turkey", "eec_eu", "un"]):
			out.append(str(a))
	out.sort()
	return out


func _group_trust(group: String) -> float:
	var t := 0.0; var w := 0.0
	for c in sim.active_cities():
		if sim.econ.in_group(c, group):
			t += c.trust * c.residents; w += c.residents
	return t / w if w > 0.0 else 100.0


func metric(m: String) -> float:
	if m.begins_with("track_ratio:"):
		return _ratio(m.substr(12))
	if m.begins_with("programme_levels:"):
		return float(group_levels(m.substr(17)))
	if m.begins_with("programme_lead:"):
		return float(group_levels(m.substr(15)) - ghost_group_levels(m.substr(15)))
	match m:
		"readiness": return S().readiness
		"overall": return float(sim.score.overall_now()["overall"])   # v3 fix3-econ: the health-weighted overall (A Nation Ahead)
		"collapse_danger":
			var n := 0
			if sim.collapse != null:
				for c in sim.collapse.status():
					if str(c["level"]) == "danger": n += 1
			return float(n)
		"standing": return S().standing
		"inflation": return S().inflation
		"debt_years": return sim.econ.debt() / maxf(1.0, 4.0 * float(S().counters.get("income_avg", 45.0)))
		"treaties": return float(treaties().size())
		"town_strikes_ratio":
			var g := float(sim.db.ghost.get("endgame", {}).get("town_strikes", 0.0))
			var mine := float(_town_strikes())
			if g <= 0.0: return 0.0 if mine <= 0.0 else 2.0
			# compare like with like: history's strikes up to this date (the ghost records them per decade)
			var by: Dictionary = sim.db.ghost.get("endgame", {}).get("town_strikes_by_turn", {})
			var gnow := g
			if not by.is_empty():
				gnow = 0.0
				for k in by:
					if int(k) <= S().turn: gnow = maxf(gnow, float(by[k]))
			return mine / maxf(1.0, gnow)
		"min_group_trust":
			return minf(_group_trust("arab"), minf(_group_trust("dev_towns"), _group_trust("periphery")))
		"housing_shortfall":
			var tr := 0.0
			for c in sim.active_cities(): tr += float(c.info.get("transit", 0.0))
			return tr / maxf(1.0, sim.total_residents())
	return 0.0


func _criterion(c: Dictionary, margin: float) -> Dictionary:
	## One ending threshold: {value, target, cmp, met, progress (0..1), margin, text}.
	var v := metric(str(c["metric"]))
	var is_min: bool = c.has("min")
	var target := float(c.get("min", c.get("max", 0.0)))
	if c.get("ratio", false): target += margin
	var met := v >= target if is_min else v <= target
	var p := 0.0
	var m := 0.0
	if is_min:
		p = clampf(v / target, 0.0, 1.0) if target > 0.0 else (1.0 if met else 0.0)
		m = (v - target) / maxf(0.01, absf(target))
	else:
		p = 1.0 if v <= target else clampf(target / maxf(0.0001, v), 0.0, 1.0)
		m = (target - v) / maxf(0.01, absf(target))
	return {"value": v, "target": target, "cmp": ">=" if is_min else "<=", "met": met, "progress": p, "margin": m,
		"text": "%s: %s (%s %s)" % [str(c.get("label", "")), _metric_text(str(c["metric"]), v, str(c.get("unit", ""))), ">=" if is_min else "<=", _metric_text(str(c["metric"]), target, str(c.get("unit", "")))]}


func get_endings() -> Dictionary:
	## Progress towards every ending, for play and the end screen:
	## {turn, final, difficulty, endings: [{id, name, summary, met, progress, criteria: [{id, label, metric, value, target, cmp: ">="|"<=",
	##   met, progress, unit, text}]}], reached: [ids], primary: id, leading: id (closest unmet, or the primary)}.
	var margin := float(difficulty().get("ending_margin", 0.0))
	var out := []
	var reached := []
	var best := ""; var bestm := -1e9
	var lead := ""; var leadp := -1.0
	var strong := ""
	for e in data()["endings"].get("endings", []):
		if e.get("fallback", false) or str(e.get("kind", "")) == "collapse":
			continue   # the collapse endings (fix-v3a) are measured every quarter by SimCollapse
		var crit := []
		var all_met := true
		var prog := 0.0
		var marg := 0.0
		for c in e.get("criteria", []):
			var ev := _criterion(c, margin)
			var met: bool = ev["met"]
			var p: float = ev["progress"]
			var cm: float = ev["margin"]
			var row := {"id": str(c.get("id", "")), "label": str(c.get("label", "")), "metric": str(c["metric"]), "value": snappedf(float(ev["value"]), 0.001), "target": float(ev["target"]),
				"cmp": ev["cmp"], "met": met, "progress": snappedf(p, 0.01), "unit": str(c.get("unit", "")), "text": str(ev["text"])}
			if c.has("or"):
				# v3 fix3-econ: an alternative threshold that also meets the criterion (e.g. programmes ahead of history, or a second track)
				var alt := _criterion(c["or"], margin)
				row["or"] = {"label": str(c["or"].get("label", "")), "metric": str(c["or"].get("metric", "")), "value": snappedf(float(alt["value"]), 0.001), "target": float(alt["target"]),
					"cmp": alt["cmp"], "met": alt["met"], "progress": snappedf(float(alt["progress"]), 0.01), "unit": str(c["or"].get("unit", "")), "text": str(alt["text"])}
				row["text"] = str(ev["text"]) + "; or " + str(alt["text"])   # v3 final round: the alternative's label no longer starts with "or:"
				if bool(alt["met"]) and not met:
					met = true
					row["met"] = true
				p = maxf(p, float(alt["progress"]))
				cm = maxf(cm, float(alt["margin"]))
				row["progress"] = snappedf(p, 0.01)
			marg += cm
			if not met: all_met = false
			prog += p
			crit.append(row)
		var n := maxi(1, crit.size())
		var pr := prog / n
		var hf: bool = e.get("headline_fallback", false)
		out.append({"id": str(e["id"]), "name": str(e.get("name", "")), "summary": str(e.get("summary", "")), "met": all_met, "progress": snappedf(pr, 0.01),
			"criteria_met": crit.filter(func(x): return x["met"]).size(), "criteria": crit, "headline_fallback": hf})
		if all_met:
			reached.append(str(e["id"]))
			if hf:
				if strong == "": strong = str(e["id"])   # v3 fix3-econ: A Nation Ahead is the headline only when no named ending is met
			elif marg / n > bestm: bestm = marg / n; best = str(e["id"])
		# v3 final round (fix4-econ, 1986r m-4): "leading" is the unmet ending with the most thresholds met, then the
		# most progress: the same rule as the mixed record's "Closest" (mixed_text)
		var lk := float(crit.filter(func(x): return x["met"]).size()) * 10.0 + pr
		if lk > leadp and not hf and not all_met: leadp = lk; lead = str(e["id"])
	var fb := ""
	for e in data()["endings"].get("endings", []):
		if e.get("fallback", false): fb = str(e["id"])
	if best == "" and strong != "": best = strong
	var res := {"turn": S().turn, "final": S().game_over, "difficulty": difficulty_id(), "endings": out, "reached": reached,
		"primary": best if best != "" else fb, "leading": best if best != "" else lead}
	if sim.collapse != null:   # v3 item 13 (fix-v3a): how close each collapse of the state is; a collapse ends the game early
		res["collapse"] = sim.collapse.status()
		res["collapsed"] = sim.collapse.ended_id()
		if sim.collapse.ended():
			res["primary"] = sim.collapse.ended_id()
			res["leading"] = sim.collapse.ended_id()
			res["reached"] = []
	return res


func _metric_text(m: String, v: float, unit: String) -> String:
	if m.begins_with("track_ratio:") or unit == "x history":
		return "%s of history" % SimScore.ratio_text(v)   # capped like the score: ">200% of history"
	if unit == "share":
		return "%.1f%%" % (v * 100.0)
	if unit == "%":
		return "%.1f%%" % v
	if unit == "years":
		return "%.1f years" % v
	if m == "overall":
		return "%.0f%%" % v
	if m.begins_with("programme_levels:") or m.begins_with("programme_lead:") or m == "treaties":
		return "%d" % int(round(v))
	return "%.0f" % v


func ending_def(id: String) -> Dictionary:
	for e in data()["endings"].get("endings", []):
		if str(e.get("id", "")) == id: return e
	return {}


func final_ending() -> Dictionary:
	if sim.collapse != null and sim.collapse.ended():
		return sim.collapse.ending_view()
	var en := get_endings()
	var d := ending_def(str(en["primary"]))
	var summ := str(d.get("summary", ""))
	if d.get("fallback", false):
		summ = mixed_text(en)   # v3 fix3-econ: the mixed record written from the real track balance
	return {"id": str(en["primary"]), "name": str(d.get("name", "")), "summary": summ, "also": en["reached"].filter(func(x): return x != en["primary"])}


const NEAR_PROGRESS := 0.9   # v3 final round: a missed threshold counts as "within reach" from 90% of the way there


func choice_counts(ledger = null) -> Dictionary:
	## v3 final round (fix4-econ, fullr m7 / 1986r m-4): the one count of cabinet decisions used by the end screen, the
	## epilogue and get_end_summary(): sim.forks.get_path_ledger() (forks and event choices; envoys apart).
	## {decisions, matched_history, differed, envoys, envoys_differed}.
	var l: Array = ledger if ledger != null else sim.forks.get_path_ledger()
	var m := l.filter(func(x): return x.get("matched_history", false)).size()
	var dl: Array = sim.diplo.ledger() if sim.diplo != null and sim.diplo.has_method("ledger") else []
	return {"decisions": l.size(), "matched_history": m, "differed": l.size() - m, "envoys": dl.size(),
		"envoys_differed": dl.filter(func(x): return not x.get("matched_history", false)).size()}


func mixed_text(en := {}) -> String:
	## "No ending's thresholds were all met. Against history's record: ahead on 5 tracks (...), level on 1 (...), behind on none. Closest: ..."
	if en.is_empty(): en = get_endings()
	var sc: Dictionary = sim.score.current()
	var ahead := []; var level := []; var behind := []
	for t in sc.get("tracks", []):
		var lbl := "%s %s" % [str(SimScore.TRACK_SHORT.get(str(t["id"]), t["name"])), SimScore.ratio_delta_text(float(t["ratio"]))]
		match str(t["status"]):
			"ahead": ahead.append(lbl)
			"behind": behind.append(lbl)
			_: level.append(str(SimScore.TRACK_SHORT.get(str(t["id"]), t["name"])))
	var parts := []
	if not ahead.is_empty(): parts.append("ahead on %d track%s (%s)" % [ahead.size(), "" if ahead.size() == 1 else "s", ", ".join(ahead)])
	if not level.is_empty(): parts.append("level on %d (%s)" % [level.size(), ", ".join(level)])
	parts.append(("behind on %d (%s)" % [behind.size(), ", ".join(behind)]) if not behind.is_empty() else "behind on none")
	var t := "No ending's thresholds were all met. Against history's record your Israel is %s." % ", ".join(parts)
	var best = null
	for e in en.get("endings", []):
		if str(e["id"]) == str(en.get("leading", "")) and not e["met"]: best = e   # the ending get_endings() calls "leading"
	if best != null:
		var miss: Array = best["criteria"].filter(func(c): return not c["met"])
		t += " Closest: %s, %d of %d thresholds (missing: %s)." % [str(best["name"]), int(best["criteria_met"]), (best["criteria"] as Array).size(),
			"; ".join(miss.map(func(c): return str(c["label"]).to_lower()))]
	return t


func end_label() -> String:
	## "September 2023": the end of the last playable quarter.
	var t := Sim.last_playable_turn()
	return "%s %d" % [["March", "June", "September", "December"][SimDB.quarter_of(t) - 1], SimDB.year_of(t)]


func memorial() -> Dictionary:
	## The memorial screen after the last turn: data/ending_oct7.json as written (verbatim; never edited here).
	var d := _load_json("res://data/ending_oct7.json")
	return {"id": str(d.get("id", "")), "date": str(d.get("date", "")), "turn_after": int(d.get("turn_after", Sim.last_playable_turn())),
		"paragraphs": d.get("paragraphs", []), "closing": str(d.get("closing", "")), "cite": d.get("cite", [])}


func get_epilogue() -> Dictionary:
	## The epilogue for the end screen, built from the player's record: {ending, name, paragraphs: [{kind, title, text}],
	## record: {...the numbers used...}}. Neutral wording; no deleted 2023- content.
	var st := S()
	var en := get_endings()
	var fe := final_ending()
	var ed := ending_def(str(fe["id"]))
	var sc: Dictionary = sim.score.current()
	var paras := []
	var collapsed: bool = sim.collapse != null and sim.collapse.ended()
	var open := str(ed.get("epilogue", {}).get("open", "")).replace("{end}", end_label())
	var also: Array = fe["also"]
	if not also.is_empty():
		open += " It also met the thresholds of %s." % ", ".join(also.map(func(x): return str(ending_def(str(x)).get("name", x))))
	if collapsed:
		# v3 item 13 (fix-v3a): a collapse of the state: what happened, what went wrong and what might have changed it
		paras.append_array(sim.collapse.epilogue_paragraphs())
		paras[0]["text"] = str(paras[0]["text"]) + ("\nAt that date your Israel stood at %.0f%% of history's record (ahead on %d of 6 tracks; difficulty: %s)." % [float(sc["overall"]), int(sc["ahead"]), str(difficulty().get("name", "Normal"))])
	else:
		open += " Overall, your Israel finished at %.0f%% of history's record (ahead on %d of 6 tracks; difficulty: %s)." % [float(sc["overall"]), int(sc["ahead"]), str(difficulty().get("name", "Normal"))]
		paras.append({"kind": "ending", "title": str(fe["name"]), "text": open})
	# forks and choices still in force
	var live := {}
	for s in st.streams:
		var src := str(s.get("src", ""))
		if src.begins_with("fork_") and sim._stream_active(s):
			live[src] = str(s.get("label", ""))
	var ledger: Array = sim.forks.get_path_ledger()
	var shown := []
	for e in ledger:
		if live.has(str(e["id"])) and not e.get("matched_history", true):
			shown.append("%s (%s): %s" % [str(e.get("title", "")), SimDB.date_label(int(e.get("turn", 0))).substr(3), str(live[str(e["id"])]).trim_suffix(".")])
	var cc := choice_counts(ledger)   # v3 final round (fix4-econ): one count of the decisions everywhere
	var differ := int(cc["differed"])
	var ft := "Of %d cabinet decisions, you answered %d differently from history." % [int(cc["decisions"]), differ]
	if not shown.is_empty():
		# v3 final round (fix4-econ, 1986r m-4): choices from the whole game, not only the earliest: the latest one
		# and others spread evenly over the years (the ledger is in date order)
		var pick := []
		var n := shown.size()
		var k := mini(4, n)
		for i in range(k):
			var idx := n - 1 - int(round(float(i) * float(n - 1) / float(maxi(1, k - 1)))) if k > 1 else n - 1
			if not (shown[idx] in pick): pick.append(shown[idx])
		pick.reverse()
		ft += (" Still shaping the country in %d: " % mini(SimDB.year_of(S().turn), SimDB.end_year())) + "; ".join(pick) + "."
	paras.append({"kind": "forks", "title": "Your choices", "text": ft})
	# wars
	var wars := st.crisis_log.size()
	var hits := _town_strikes()
	var gh := int(sim.db.ghost.get("endgame", {}).get("town_strikes", -1))
	# fix3-ui: like with like, history's strikes up to the same date (a collapse ends early; the ghost records them by turn)
	var gby: Dictionary = sim.db.ghost.get("endgame", {}).get("town_strikes_by_turn", {})
	if gh >= 0 and not gby.is_empty():
		var gnow := 0.0
		for k in gby:
			if int(k) <= S().turn: gnow = maxf(gnow, float(gby[k]))
		gh = int(round(gnow))
	var wt := "Your governments led Israel through %d wars, operations and crises; enemy strikes hit its towns %d times%s, and %d units were lost." % [wars, hits,
		(" (history's ghost by then: %d)" % gh) if gh >= 0 else "", st.units_lost]
	wt += " Readiness at the end: %.0f." % st.readiness
	paras.append({"kind": "wars", "title": "Wars and security", "text": wt})
	# budgets
	var bh: Array = st.counters.get("budget_history", [])
	if not bh.is_empty():
		var cnt := {}
		for b in bh: cnt[str(b.get("preset", ""))] = int(cnt.get(str(b.get("preset", "")), 0)) + 1
		var keys := cnt.keys()
		keys.sort_custom(func(a, b): return int(cnt[a]) > int(cnt[b]))
		var parts := keys.slice(0, 3).map(func(k): return "%s in %d" % [str(sim.score.ENVELOPE_NAME.get(k, k)), int(cnt[k])])
		paras.append({"kind": "budgets", "title": "State Budgets", "text": "Across %d Budget Laws your priorities were: %s." % [bh.size(), ", ".join(parts)]})
	# diplomacy
	var tr := treaties()
	var dt := "Treaties in force at the end: %s." % (", ".join(tr.map(func(a): return sim.events.actor_name(str(a)))) if not tr.is_empty() else "none")
	dt += " International Standing %.0f." % st.standing
	if st.diplomacy.has("usa"):
		dt += " Relations with the United States: %.0f." % float(st.diplomacy["usa"].get("relation", 0.0))
	paras.append({"kind": "diplomacy", "title": "Neighbours and allies", "text": dt})
	# programmes
	var done := []
	for p in programme_defs():
		var ps := pstate(str(p["id"]))
		if ps["done"].size() + int(ps["expand"]) > 0:
			done.append("%s (%d level%s%s)" % [p.get("name", ""), ps["done"].size(), "" if ps["done"].size() == 1 else "s", (", expanded %d times" % int(ps["expand"])) if int(ps["expand"]) > 0 else ""])
	paras.append({"kind": "programmes", "title": "National programmes", "text": ("Completed: " + "; ".join(done) + ".") if not done.is_empty() else "No national programme was completed."})
	# money
	var d: Dictionary = sim.econ.debt_report()
	var mt := "The treasury ends at %s gold; public debt %s (%.1f years of revenue); inflation %.1f%% (history: %.1f%%)." % [_fmt(st.gold), _fmt(float(d["debt"])),
		metric("debt_years"), st.inflation, sim.inflation_baseline(SimDB.year_f(st.turn))]
	if float(d["borrowed_total"]) > 0.0:
		mt += " Over the game you borrowed %s gold and paid %s in interest." % [_fmt(float(d["borrowed_total"])), _fmt(float(d["interest_total"]))]
	paras.append({"kind": "money", "title": "Money", "text": mt})
	# the closest other endings
	var near := []
	for e2 in en["endings"]:
		if e2["met"]: continue
		var miss: Array = e2["criteria"].filter(func(c): return not c["met"])
		# v3 final round (fix4-econ, m5): "within reach" only when the one missed threshold is within about a tenth
		if miss.size() == 1 and float(miss[0].get("progress", 0.0)) >= NEAR_PROGRESS:
			near.append("%s (missed only: %s)" % [e2["name"], str(miss[0]["label"]).to_lower()])
	var close := str(ed.get("epilogue", {}).get("close", ""))
	if collapsed:
		close = sim.collapse.close_text()
	elif not near.is_empty():
		close += " Within reach: " + "; ".join(near) + "."
	paras.append({"kind": "close", "title": "", "text": close})
	var gn: Dictionary = data()["endings"].get("gap_note", {})   # removed: the game now ends in Q3 2023
	if not gn.is_empty():
		paras.append({"kind": "gap_note", "title": str(gn.get("title", "")), "text": str(gn.get("text", ""))})
	return {"ending": str(fe["id"]), "name": str(fe["name"]), "summary": str(fe["summary"]), "also": also, "paragraphs": paras,
		"record": {"overall": float(sc["overall"]), "ahead": int(sc["ahead"]), "wars": wars, "town_strikes": hits, "history_town_strikes": gh, "units_lost": st.units_lost,
			"treaties": tr, "forks_differ": differ, "forks": ledger.size(), "programmes_done": done.size(), "debt": float(d["debt"]), "inflation": st.inflation,
			"difficulty": difficulty_id(), "collapse": sim.collapse.ended_id() if sim.collapse != null else "",
			"collapse_record": sim.collapse.cs().get("end_record", {}) if collapsed else {}}}


# ================================================================== fiscal indicator and food

func _note_fiscal() -> void:
	var f: Array = eg().get("fiscal", [])
	f.append([S().turn, snappedf(sim.econ.debt(), 0.1), snappedf(metric("debt_years"), 0.001), snappedf(S().inflation, 0.01), snappedf(S().gold, 0.1),
		snappedf(float(S().counters.get("last_budget", {}).get("net", 0.0)), 0.1)])
	eg()["fiscal"] = f.slice(maxi(0, f.size() - 12))


func fiscal_indicator() -> Dictionary:
	## The top-bar debt and inflation indicator: {debt, debt_years, debt_trend, debt_dir, inflation, inflation_trend,
	## inflation_dir, inflation_history, inflation_gap, treasury, net, deficit_quarters (last 4), level: ok|watch|danger,
	## label (short), tooltip (one paragraph)}. Trends compare with four quarters ago.
	var f: Array = eg().get("fiscal", [])
	var dy := metric("debt_years")
	var infl := S().inflation
	var old: Array = f[maxi(0, f.size() - 5)] if f.size() >= 2 else [S().turn, sim.econ.debt(), dy, infl, S().gold, 0.0]
	var d_tr := dy - float(old[2])
	var i_tr := infl - float(old[3])
	var deficits := 0
	for r in f.slice(maxi(0, f.size() - 4)):
		if float(r[5]) < 0.0: deficits += 1
	var neg_turns := int(S().counters.get("neg_turns", 0))
	# v3 fix3-econ: four tiers, measured against history's own path so a healthy game stays "ok":
	#  watch   - running costs above 110% of revenue for 2 quarters, inflation 20% (log) above history's, 2+ quarters below
	#            zero, debt over 2.5 years of revenue, or debt and overdraft at 80% of the lenders' limit;
	#  warning - the structural-deficit alarm, inflation 50% above history's, a year below zero still in deficit, the
	#            lenders' limit reached, or every fiscal-collapse condition holding;
	#  danger  - a fiscal collapse in its countdown.
	var level := "ok"
	var gap: float = sim.inflation_gap() if S().mode != "historical" else 0.0
	var sx: Dictionary = sim.econ.structural()
	var dcap: float = (sim.econ.debt() + maxf(0.0, -S().gold)) / maxf(1.0, sim.econ.debt_cap())
	var net_now := float(S().counters.get("last_budget", {}).get("net", 0.0))
	if int(sx.get("q", 0)) >= 2 or gap > 0.2 or neg_turns >= 2 or dy > 2.5 or dcap >= 0.8: level = "watch"
	var fcl: String = sim.collapse.level_of("collapse_fiscal") if sim.collapse != null else "ok"
	# an overdraft history itself ran at the time (1949-52: the ghost's treasury below zero too) is "watch", not "warning"
	var ghost_neg := S().mode != "historical" and sim.score != null and float(sim.score.ghost_at(S().turn).get("gold", 1.0)) < 0.0
	if bool(sx.get("alarm", false)) or gap > 0.5 or (neg_turns >= 4 and net_now < 0.0 and not ghost_neg) or dcap >= 1.0 or fcl == "warning": level = "warning"
	if fcl == "danger": level = "danger"   # v3 item 13: a fiscal collapse is in sight
	var why := []   # what set the tier (tooltip and tests)
	if level != "ok":
		if bool(sx.get("alarm", false)): why.append("structural deficit")
		elif int(sx.get("q", 0)) >= 2: why.append("spending above revenue")   # v3 final round: every outflow (fix4-econ)
		if gap > 0.2: why.append("inflation above history's")
		if neg_turns >= 2: why.append("treasury below zero for %d quarters" % neg_turns)
		if dy > 2.5: why.append("debt over 2.5 years of revenue")
		if dcap >= 0.8: why.append("debt near the lenders' limit")
		if fcl in ["warning", "danger"]: why.append("fiscal collapse " + ("countdown" if fcl == "danger" else "conditions"))
	var hist: float = sim.inflation_baseline(SimDB.year_f(S().turn))
	var arrow := func(x: float, eps: float) -> String: return "up" if x > eps else ("down" if x < -eps else "flat")
	var label := "Debt %.1f yrs %s | Inflation %.0f%% %s" % [dy, {"up": "^", "down": "v", "flat": "="}[arrow.call(d_tr, 0.05)], infl, {"up": "^", "down": "v", "flat": "="}[arrow.call(i_tr, 1.0)]]
	var tip := "Public debt %s gold, %.1f years of revenue (%s%.2f on a year ago); lenders' limit %s. Inflation %.1f%% a year (%s%.1f points on a year ago; history %.1f%%). %d of the last 4 quarters ran a deficit." % [
		_fmt(sim.econ.debt()), dy, "+" if d_tr >= 0 else "", d_tr, _fmt(sim.econ.debt_cap()), infl, "+" if i_tr >= 0 else "", i_tr, hist, deficits]
	if not sx.is_empty():
		tip += "\n" + sim.econ.upkeep_text(true)   # v3 fix3-econ: running costs against revenue
	if bool(sx.get("alarm", false)):
		tip += "\nStructural deficit since %s: mothball or close buildings, privatise or adopt a stabilisation package." % SimDB.date_label(int(sx.get("since", S().turn)))
	return {"debt": sim.econ.debt(), "debt_years": dy, "debt_trend": d_tr, "debt_dir": arrow.call(d_tr, 0.05), "inflation": infl, "inflation_trend": i_tr,
		"inflation_dir": arrow.call(i_tr, 1.0), "inflation_history": hist, "inflation_gap": infl - hist, "treasury": S().gold,
		"net": float(S().counters.get("last_budget", {}).get("net", 0.0)), "deficit_quarters": deficits, "level": level, "label": label, "tooltip": tip, "collapse": fcl,
		"structural": bool(sx.get("alarm", false)), "structural_ratio": float(sx.get("ratio", 0.0)), "upkeep_text": sim.econ.upkeep_text(true) if not sx.is_empty() else "",
		"levels": ["ok", "watch", "warning", "danger"], "why": why}


func food_balance() -> Dictionary:
	## The national food figure explained: produced (cities' worked tiles and farms plus rural localities) against what
	## the population eats (2 per population point). A shortfall is imported (0.5 gold each, every quarter) and slows
	## growth in every city; a surplus (exported at SimEconomy.FOOD_EXPORT gold each, now 0) adds up to +10% growth in the
	## cities that produce it. City screens show each city's own surplus, which can be negative in a large city fed by the
	## national pool.
	var n: Dictionary = sim.national()
	var food := float(n.get("food", 0.0))
	var need := float(n.get("food_need", 0.0))
	var bal := food - need
	var ratio := food / maxf(1.0, need)
	var imports := maxf(0.0, -bal) * 0.5
	var exports := maxf(0.0, bal) * SimEconomy.FOOD_EXPORT
	var growth := (0.6 + 0.4 * ratio - 1.0) * 100.0 if ratio < 1.0 else 0.0
	var label := "Food %+.0f (%s)" % [bal, "self-sufficient" if bal >= 0.0 else "imports"]
	var text := ("The country produces %.0f food a quarter and eats %.0f: a surplus of %.0f, so nothing is imported, and the cities that grow it gain up to +10%% growth." % [food, need, bal]) if bal >= 0.0 \
		else ("The country produces %.0f food a quarter and eats %.0f: %.0f is imported for about %.0f gold, and growth slows by %.0f%% everywhere." % [food, need, -bal, imports, -growth])
	text += " Farms, kibbutzim and moshavim, drip irrigation and fish ponds raise it; a large city lives on the national pool, so its own figure can be negative."
	return {"produced": food, "rural": float(n.get("rural_food", 0.0)), "needed": need, "balance": bal, "ratio": ratio, "self_sufficiency_pct": ratio * 100.0,
		"imports_gold": imports, "exports_gold": exports, "growth_effect_pct": growth, "label": label, "text": text}


# ================================================================== scenario starts (round 2)

static func scenario_list() -> Array:
	## [{id, date, turn, label, title, briefing, file, available}] for the New Game screen.
	var out := []
	for s in SCENARIOS:
		var t := SimDB.turn_of(s["date"], 1)
		var p := SCENARIO_DIR + "start_%s.json" % s["id"]
		out.append({"id": s["id"], "date": s["date"], "turn": t, "label": SimDB.date_label(t), "title": s["title"], "briefing": s["briefing"],
			"file": p, "available": FileAccess.file_exists(p)})
	return out


static func scenario_turn(id: String) -> int:
	for s in SCENARIOS:
		if str(s["id"]) == id: return SimDB.turn_of(s["date"], -1)
	return -1


static func save_scenario_snapshot(s, id: String) -> Error:
	## Writes the historical run's state at the start of the scenario's quarter (called by sim_test's ghost run, at the
	## start of that turn, before its decisions). The history samples are kept (the score arc starts level with history).
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SCENARIO_DIR))
	s.state.rng_state = s.rng.state
	var d: Dictionary = s.state.to_dict()
	d["scenario"] = id
	d["notifications"] = []
	d["stat_log"] = d["stat_log"].slice(maxi(0, d["stat_log"].size() - 400))
	var f := FileAccess.open(SCENARIO_DIR + "start_%s.json" % id, FileAccess.WRITE)
	if f == null:
		return FileAccess.get_open_error()
	f.store_string(JSON.stringify(d))
	return OK


func start_scenario(opts: Dictionary) -> bool:
	## new_game({"scenario": "1967"|"1977"|"1992", "difficulty": ...}): load the seeded state, hand it to the player.
	var id := str(opts.get("scenario", ""))
	var p := SCENARIO_DIR + "start_%s.json" % id
	if not FileAccess.file_exists(p):
		return false
	var st := GameState.load_json(p)
	if st == null:
		return false
	sim.state = st
	st.mode = "player"
	st.counters.erase("ai_style")
	st.counters["scenario"] = id
	var d := str(opts.get("difficulty", "normal"))
	st.counters["difficulty"] = d
	sim.rng.seed = st.rng_seed
	sim.rng.state = st.rng_state
	sim.econ.calibrate()
	sim.econ.tiles_dirty = true
	sim.econ.border_cache_era = ""
	sim._reindex()
	sim.refresh()
	# the quarter's decisions were generated for history's autoplayer; regenerate the player's view
	eg()["decision"] = {}
	_make_decision()
	sim.state.last_decisions = sim.get_pending_decisions()
	for s in SCENARIOS:
		if str(s["id"]) == id:
			sim.notify("scenario", "%s (%s). %s" % [s["title"], sim.date_label(), s["briefing"]], {"scenario": id})
	sim.turn_started.emit(st.turn, sim.date_label())
	return true


static func _fmt(n: float) -> String:
	var a := absf(n)
	var s := ""
	if a >= 1.0e6: s = "%.1fM" % (a / 1.0e6)
	elif a >= 10000.0: s = "%dk" % int(round(a / 1000.0))
	else: s = "%d" % int(round(a))
	return ("-" if n < 0.0 else "") + s


# ================================================================== views in the shapes ui-v3 asked for (INTEGRATION_REQUESTS v3)

func economy_indicator() -> Dictionary:
	## Top-bar indicator: fiscal_indicator() plus {revenue_year, debt_ratio, cap, service, inflation_history_baseline,
	## health, tooltip: [lines], text (one paragraph)}.
	var f := fiscal_indicator()
	var inc := maxf(30.0, float(S().counters.get("income_avg", 45.0)))
	f["revenue_year"] = 4.0 * inc
	f["debt_ratio"] = f["debt_years"]
	f["cap"] = sim.econ.debt_cap()
	f["service"] = float(S().counters.get("last_debt", {}).get("total", 0.0))
	f["inflation_history_baseline"] = f["inflation_history"]
	f["health"] = sim.econ.economy_health()
	f["text"] = f["tooltip"]
	f["tooltip"] = [
		"Public debt: %s gold = %.1f years of revenue (%s on a year ago); lenders' limit %s." % [_fmt(sim.econ.debt()), float(f["debt_years"]), ("%+.2f" % float(f["debt_trend"])), _fmt(float(f["cap"]))],
		"Debt service this quarter: %s gold." % _fmt(float(f["service"])),
		"Inflation: %.1f%% a year (%+.1f points on a year ago); history this year %.1f%%." % [float(f["inflation"]), float(f["inflation_trend"]), float(f["inflation_history"])],
		"Economy health %.0f%% (inflation above history's and a heavy debt lower output per person)." % (float(f["health"]) * 100.0),
		"%d of the last 4 quarters ran a deficit." % int(f["deficit_quarters"])]
	return f


func food_report() -> Dictionary:
	var fb := food_balance()
	fb["consumed"] = fb["needed"]
	fb["surplus"] = fb["balance"]
	fb["imports"] = maxf(0.0, -float(fb["balance"]))
	fb["import_cost"] = fb["imports_gold"]
	return fb


static func difficulties_view() -> Array:
	var out := []
	var dflt := str(data()["difficulty"].get("default", "normal"))
	for l in difficulty_levels():
		var eff := []
		var g := float(l.get("ghost_strength", 1.0))
		if not is_equal_approx(g, 1.0): eff.append("History's record counts %+.0f%%" % ((g - 1.0) * 100.0))
		if int(l.get("start_gold", 0)) != 0: eff.append("%+d gold in the 1948 treasury" % int(l["start_gold"]))
		if not is_equal_approx(float(l.get("inflation_drift", 1.0)), 1.0): eff.append("Deficits move inflation %s" % ("%.0f%% faster" % ((float(l["inflation_drift"]) - 1.0) * 100.0) if float(l["inflation_drift"]) > 1.0 else "%.0f%% slower" % ((1.0 - float(l["inflation_drift"])) * 100.0)))
		if int(l.get("ai_pressure", 0)) != 0: eff.append("Enemy formations %+d strength" % int(l["ai_pressure"]))
		if not is_equal_approx(float(l.get("programme_cost", 1.0)), 1.0): eff.append("National programmes cost %+.0f%%" % ((float(l["programme_cost"]) - 1.0) * 100.0))
		if not is_equal_approx(float(l.get("ending_margin", 0.0)), 0.0): eff.append("Ending thresholds %+.0f points against history" % (float(l["ending_margin"]) * 100.0))
		if not l.get("hints", true): eff.append("No Recommended badges; history's choice shown only after you decide")
		if eff.is_empty(): eff.append("History's record as it was")
		out.append({"id": str(l["id"]), "name": str(l["name"]), "desc": str(l.get("desc", "")), "effects": eff, "default": str(l["id"]) == dflt, "hints": bool(l.get("hints", true))})
	return out


static func scenarios_view() -> Array:
	var out := [{"id": "", "name": "Independence (May 1948)", "year": 1948, "desc": "The full game, from the declaration of the state to October 2023.", "available": true}]
	for s in scenario_list():
		out.append({"id": s["id"], "name": s["title"], "year": int(str(s["date"]).substr(0, 4)), "desc": s["briefing"], "available": s["available"], "label": s["label"], "turn": s["turn"]})
	return out


func ending_outlook() -> Array:
	## One entry per ending plus the mixed record: {id, name, desc, thresholds: [{label, value, target, unit, met, text}],
	## progress (0..1), met, likely (the one you are closest to)}.
	var en := get_endings()
	var out := []
	for e in en["endings"]:
		out.append({"id": e["id"], "name": e["name"], "desc": e["summary"], "thresholds": e["criteria"], "progress": e["progress"], "met": e["met"],
			"likely": str(e["id"]) == str(en["leading"])})
	for d in data()["endings"].get("endings", []):
		if d.get("fallback", false):
			out.append({"id": str(d["id"]), "name": str(d.get("name", "")), "desc": str(d.get("summary", "")), "thresholds": [], "progress": 1.0 if en["reached"].is_empty() else 0.0,
				"met": en["reached"].is_empty(), "likely": str(en["leading"]) == str(d["id"])})
	for c in en.get("collapse", []):   # v3 item 13 (fix-v3a): the collapses of the state, with how close each is
		out.append({"id": c["id"], "name": c["name"], "desc": c["summary"], "thresholds": c["conditions"], "progress": c["progress"], "met": c["ended"],
			"likely": false, "collapse": true, "level": c["level"], "strain": c["strain"], "limit": c["limit"], "quarters_left": c["quarters_left"], "advice": c["advice"]})
	return out


func ending_summary() -> Dictionary:
	## get_end_summary()["ending"]: {id, name, title, verdict, summary, also, epilogue: [plain-text paragraphs],
	## sections: [{title, text, kind}], thresholds (the ending's criteria)}.
	var fe := final_ending()
	var ep := get_epilogue()
	var thr := []
	for e in get_endings()["endings"]:
		if str(e["id"]) == str(fe["id"]): thr = e["criteria"]
	if sim.collapse != null and sim.collapse.ended():
		for c in sim.collapse.status():
			if str(c["id"]) == str(fe["id"]): thr = c["conditions"]
	return {"id": fe["id"], "name": fe["name"], "title": fe["name"], "summary": fe["summary"], "also": fe["also"], "collapse": bool(fe.get("collapse", false)),
		"verdict": str(ep["paragraphs"][0]["text"]) if not ep["paragraphs"].is_empty() else "",
		"epilogue": ep["paragraphs"].map(func(p): return str(p["text"])), "sections": ep["paragraphs"], "thresholds": thr, "record": ep["record"]}
