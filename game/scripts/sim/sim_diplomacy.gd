class_name SimDiplomacy
extends RefCounted
## v3 diplomacy as a system (V3.md item 4; data in game/data/diplomacy.json, API in API.md "## v3 (sim-diplomacy)").
##
## - Relations (Civ VI opinion modifiers): an actor's relation is the sum of itemised causes: the legal status
##   (actors.json statuses and rails), live causes (International Standing for Western governments, export routes)
##   and dated memories (historical events and their sources, your forks, deals, envoy answers and delegations) that
##   fade with a half-life. get_actor() lists every cause, so the relation always adds up (like "Why stats moved").
## - Each actor has a dated status timeline of real history (war, ceasefire, armistice, treaty, no relations,
##   relations, alliance, embargo), sourced; the legal status itself stays on the rails of events.json/actors.json.
## - Deals ("Make Deal"): real deal types of each actor's era (aid, loans, arms purchases and sales, trade agreements,
##   joint projects, back channels, liaison offices, UN campaigns). Each gives and costs on the six tracks (through the
##   fork terms machinery), moves relations (also with third parties) and may add EXPOSURE to a patron: when that
##   patron historically used its leverage (France's 1967-69 embargo, the 1953 US aid freeze, Iran 1979, ...), the
##   exposed player pays in proportion. The ghost of history takes no deals, so it carries no exposure.
## - Envoys: a recurring CORE decision (type "diplomacy") offered every few quarters when a real opportunity exists:
##   an envoy, a request or a crisis of that date, or a partner proposing one of its era's deals. Exactly one option
##   is what Israel did; every other option names its advocate with a verbatim cite.

const DATA := "res://data/diplomacy.json"
const HALF_LIFE := 20.0         # quarters for a remembered cause to fade to half (5 years)
const MOD_CAP := 35.0           # what dealings and incidents can add on top of the legal status
const MIN_GAP := 2              # quarters between two diplomatic decisions
const MAX_GAP := 6              # after this many quarters an open opportunity is offered even on a busy turn
const OFFER_ACTOR_GAP := 10     # quarters before the same partner proposes a deal again
const EXPOSURE_HALF_LIFE := 40.0
const RISK_WINDOW := 60          # v3 fix3-story (A6): a deal lists only the leverage risks of the next 15 years
const CORE := ["event_choice", "fork", "crisis_response", "policy_review", "immigration", "dedication", "coalition"]
const WESTERN := ["usa", "uk", "france", "west_germany", "eec_eu"]
const LEVELS := [[-50.0, "hostile", "Hostile"], [-20.0, "unfriendly", "Unfriendly"], [20.0, "neutral", "Neutral"],
	[45.0, "friendly", "Friendly"], [70.0, "close", "Close partner"], [1000.0, "strategic", "Strategic partner"]]
const STATUS_LABEL := {"war": "War", "hostile": "Hostile", "severed": "Relations severed", "ceasefire": "Ceasefire",
	"armistice": "Armistice", "negotiating": "Negotiating", "none": "No relations", "relations_established": "Diplomatic relations",
	"peace": "Peace treaty", "normalized": "Peace and normal relations"}
const PHASE_KINDS := ["war", "ceasefire", "armistice", "treaty", "no_relations", "relations", "alliance", "embargo"]
const PHASE_LABEL := {"war": "War", "ceasefire": "Ceasefire", "armistice": "Armistice", "treaty": "Peace treaty",
	"no_relations": "No relations", "relations": "Relations", "alliance": "Alliance", "embargo": "Embargo"}
## which legal statuses are consistent with a phase of the historical timeline (sim_test "statuses against history")
const PHASE_OK := {"war": ["war", "ceasefire", "hostile", "negotiating", "armistice"], "ceasefire": ["ceasefire", "war", "hostile", "negotiating", "armistice"],
	"armistice": ["armistice", "hostile", "negotiating", "ceasefire"], "treaty": ["peace", "normalized"],
	"no_relations": ["none", "hostile", "severed", "negotiating", "ceasefire", "armistice", "war"],
	"relations": ["relations_established", "peace", "normalized", "negotiating"], "alliance": ["relations_established", "peace", "normalized"],
	"embargo": ["relations_established", "peace", "normalized", "hostile", "severed", "negotiating"]}
## the memory an incident leaves (on top of the legal status) when a dated event moves an actor's status
const EVENT_MEMORY := {"war": -12.0, "hostile": -8.0, "severed": -12.0, "ceasefire": 3.0, "armistice": 5.0, "negotiating": 8.0,
	"relations_established": 10.0, "peace": 15.0, "normalized": 10.0}
const KIND_LABEL := {"aid": "Economic aid", "loan": "Loan", "arms": "Arms purchase", "arms_sale": "Arms sale", "trade": "Trade agreement",
	"reparations": "Reparations", "back_channel": "Back channel", "recognition": "Recognition and liaison", "joint": "Joint project",
	"un_vote": "UN vote", "sanctions": "Sanctions", "delegation": "Delegation"}
const NOW_KEYS := ["gold", "standing", "trust", "readiness", "cohesion", "inflation", "production", "science", "culture"]

static var _cache := {}
## Debug A/B switch: "--no-diplomacy" on the command line turns the v3 system off (sim_test comparisons only).
static var OFF: bool = "--no-diplomacy" in OS.get_cmdline_user_args()

var sim


func _init(s) -> void:
	sim = s


func S() -> GameState:
	return sim.state


# ================================================================== data

static func data() -> Dictionary:
	if _cache.is_empty():
		var d := {}
		if FileAccess.file_exists(DATA):
			var p = JSON.parse_string(FileAccess.get_file_as_string(DATA))
			if typeof(p) == TYPE_DICTIONARY:
				d = p
		d["_deals"] = {}
		for x in d.get("deals", []):
			d["_deals"][str(x.get("id", ""))] = x
		d["_envoys"] = {}
		for x in d.get("envoys", []):
			d["_envoys"][str(x.get("id", ""))] = x
		d["_ev_rel"] = {}
		for x in d.get("event_relations", []):
			var k := str(x.get("event", ""))
			if not d["_ev_rel"].has(k): d["_ev_rel"][k] = []
			d["_ev_rel"][k].append(x)
		d["_fork_rel"] = {}
		for x in d.get("fork_relations", []):
			var k2 := str(x.get("fork", ""))
			if not d["_fork_rel"].has(k2): d["_fork_rel"][k2] = []
			d["_fork_rel"][k2].append(x)
		_cache = d
	return _cache


static func reload() -> void:
	_cache = {}


func D() -> Dictionary:
	var d: Dictionary = S().diplo
	for k in ["applied", "deals", "exposure", "envoys", "pending", "last_offer_actor", "counts"]:
		if not d.has(k): d[k] = {}
	if not d.has("log"): d["log"] = []
	if not d.has("last_offer"): d["last_offer"] = -99
	return d


func actor_def(a: String) -> Dictionary:
	return data().get("actors", {}).get(a, {})


func actor_name(a: String) -> String:
	return sim.events.actor_name(a)


func _src(x) -> Array:
	if typeof(x) == TYPE_ARRAY: return x.duplicate()
	if typeof(x) == TYPE_STRING and str(x) != "": return [x]
	return []


func _t(date, default_turn := -1) -> int:
	return SimDB.turn_of(date, default_turn)


# ================================================================== era

func active(a: String, turn := -1) -> bool:
	## The actor exists and Israel deals with it at this date (its real era: the UAE from Dec 1971, the PA from 1994, ...).
	if turn < 0: turn = S().turn
	if not S().diplomacy.has(a):
		return false
	var ad := actor_def(a)
	if ad.has("from") and turn < _t(ad["from"], 0): return false
	if ad.has("until") and turn > _t(ad["until"], 99999): return false
	var meta: Dictionary = sim.db.actors.get(a, {})
	if meta.has("exists_from_event"):
		var ev = sim.db.event_by_id.get(str(meta["exists_from_event"]))
		if ev != null and turn < int(ev["_turn"]): return false
	if meta.has("exists_from") and turn < _t(meta["exists_from"], 0): return false
	return true


func timeline(a: String) -> Array:
	## The real status timeline (diplomacy.json actors.<id>.timeline), with each phase's turn span and sources.
	var out := []
	var tl: Array = actor_def(a).get("timeline", []).filter(func(p): return phase_applies(p))
	for i in range(tl.size()):
		var p: Dictionary = tl[i]
		var t0 := _phase_turn(p, "from", -99999)
		var t1 := _phase_turn(p, "to", 99999)
		if t1 == 99999 and i + 1 < tl.size():
			t1 = _phase_turn(tl[i + 1], "from", 99999) - 1
		var src := _src(p.get("source", []))
		var ev = sim.db.event_by_id.get(str(p.get("from_event", "")))
		if src.is_empty() and ev != null:
			src = _src(ev.get("source", []))
		out.append({"kind": str(p.get("kind", "")), "label": str(p.get("label", PHASE_LABEL.get(str(p.get("kind", "")), ""))),
			"from": str(p.get("from", ev.get("date", "") if ev != null else "")), "from_turn": t0, "to_turn": t1,
			"from_label": SimDB.date_label(maxi(1, t0)) if t0 > -99999 else "", "source": src, "note": str(p.get("note", ""))})
	return out


func phase_applies(p: Dictionary) -> bool:
	## v3 fix3-story (A3, A11): a phase of the real timeline shows only if it can be true in this game: its opening
	## event was not cancelled by a fork answer ("event_skipped:<id>"), its "if" answers match ("unless" ones do not),
	## and it starts by the game's last shown quarter (Q3 2023).
	if typeof(p) != TYPE_DICTIONARY: return false
	var fe := str(p.get("from_event", ""))
	if fe != "":
		# "if_skipped": an alternative phase shown only when the cabinet's answer cancelled its event
		if S().flags.has("event_skipped:" + fe) != bool(p.get("if_skipped", false)): return false
		var ev = sim.db.event_by_id.get(fe)
		if ev != null and int(ev["_turn"]) > SimDB.shown_until(): return false
	elif p.has("from") and SimDB.after_end(p["from"]):
		return false
	if p.has("if") and not sim.forks.choice_matches(p["if"]): return false
	if p.has("unless") and sim.forks.choice_matches(p["unless"]): return false
	if p.has("if_flag") and not S().flags.has(str(p["if_flag"])): return false
	if p.has("unless_flag") and S().flags.has(str(p["unless_flag"])): return false
	return true


func _phase_turn(p: Dictionary, k: String, dflt: int) -> int:
	var ev = sim.db.event_by_id.get(str(p.get(k + "_event", "")))
	if ev != null:
		return int(ev["_turn"])
	if p.has(k):
		var t := _t(p[k], dflt)
		return t
	return dflt


func phase(a: String, turn := -1) -> Dictionary:
	if turn < 0: turn = S().turn
	var cur := {}
	for p in timeline(a):
		if int(p["from_turn"]) <= turn and turn <= int(p["to_turn"]):
			cur = p
	return cur


# ================================================================== relations

func _entry(a: String) -> Dictionary:
	if not S().diplomacy.has(a):
		S().diplomacy[a] = {"status": "none", "relation": 0.0, "since": S().turn, "last_delegation": -99}
	var e: Dictionary = S().diplomacy[a]
	if not e.has("mods"):
		e["mods"] = []
		# a game saved before v3: what the old relation held beyond its legal status becomes one remembered cause
		var legacy := float(e.get("relation", 0.0)) - status_base(a)
		if S().turn > 1 and absf(legacy) >= 1.0:
			e["mods"].append({"label": "Earlier relations (before this record began)", "amount": legacy, "turn": S().turn, "hl": 40.0, "kind": "legacy", "source": []})
	return e


func status_base(a: String) -> float:
	var st := str(S().diplomacy.get(a, {}).get("status", "none"))
	return float(sim.db.actor_meta.get("status_relation", {}).get(st, 0))


func _mod_now(m: Dictionary, turn := -1) -> float:
	if turn < 0: turn = S().turn
	var hl := float(m.get("hl", HALF_LIFE))
	if hl <= 0.0:
		return float(m.get("amount", 0.0))
	return float(m.get("amount", 0.0)) * pow(0.5, float(maxi(0, turn - int(m.get("turn", turn)))) / hl)


func add_mod(a: String, amount: float, label: String, kind := "event", source := [], half_life := HALF_LIFE) -> void:
	## A remembered cause of the relation (fades with half_life quarters; 0 = permanent).
	if absf(amount) < 0.05 or not S().diplomacy.has(a):
		return
	var e := _entry(a)
	e["mods"].append({"label": label, "amount": snappedf(amount, 0.01), "turn": S().turn, "hl": half_life, "kind": kind, "source": _src(source)})
	recompute(a)


func live_parts(a: String) -> Array:
	var out := []
	var st := str(S().diplomacy.get(a, {}).get("status", "none"))
	out.append({"label": "Legal status: %s" % STATUS_LABEL.get(st, st), "amount": status_base(a), "kind": "status", "source": _status_source(a)})
	if a in WESTERN:
		var sv := (S().standing - 50.0) * 0.3
		if absf(sv) >= 0.5:
			out.append({"label": "Your International Standing (%d): Western governments weigh world opinion" % int(round(S().standing)), "amount": sv, "kind": "standing", "source": []})
	var n := 0
	for tr in S().trade_routes:
		if str(tr.get("partner", "")) == a: n += 1
	if n > 0:
		out.append({"label": "Export routes with them (%d)" % n, "amount": minf(9.0, 3.0 * n), "kind": "trade", "source": []})
	return out


func _status_source(a: String) -> Array:
	for r in sim.db.actor_meta.get("status_rails", []):
		if str(r.get("actor", "")) == a and sim.events.rail_status(a) == str(r.get("status", "")):
			var s := _src(r.get("source", []))
			if s.is_empty():
				var ev = sim.db.event_by_id.get(str(r.get("from_event", "")))
				if ev != null: s = _src(ev.get("source", []))
			return s
	var p := phase(a)
	return _src(p.get("source", []))


func recompute(a: String) -> void:
	if not S().diplomacy.has(a):
		return
	var e := _entry(a)
	var tot := 0.0
	for p in live_parts(a):
		tot += float(p["amount"])
	var ms := 0.0
	for m in e["mods"]:
		ms += _mod_now(m)
	tot += clampf(ms, -MOD_CAP, MOD_CAP)
	e["relation"] = snappedf(clampf(tot, -100.0, 100.0), 0.1)


func recompute_all() -> void:
	for a in S().diplomacy:
		recompute(a)


func causes(a: String) -> Array:
	## Every cause of the relation, itemised: [{label, amount, kind, since, source, fading}] (sums to the relation).
	var out := []
	for p in live_parts(a):
		var q: Dictionary = p.duplicate()
		q["amount"] = snappedf(float(q["amount"]), 0.1); q["since"] = ""; q["fading"] = false
		out.append(q)
	var e := _entry(a)
	var groups := {}
	var order := []
	var ms := 0.0
	for m in e["mods"]:
		var v := _mod_now(m)
		ms += v
		var key := str(m.get("label", ""))
		if not groups.has(key):
			groups[key] = {"label": key, "amount": 0.0, "kind": str(m.get("kind", "")), "since": SimDB.date_label(int(m.get("turn", 1))), "source": _src(m.get("source", [])),
				"fading": float(m.get("hl", HALF_LIFE)) > 0.0, "n": 0}
			order.append(key)
		groups[key]["amount"] = float(groups[key]["amount"]) + v
		groups[key]["n"] = int(groups[key]["n"]) + 1
	var items := []
	for k in order:
		var g: Dictionary = groups[k]
		if absf(float(g["amount"])) < 0.05: continue
		if int(g["n"]) > 1: g["label"] = "%s (x%d)" % [g["label"], g["n"]]
		g.erase("n")
		g["amount"] = snappedf(float(g["amount"]), 0.1)
		items.append(g)
	items.sort_custom(func(x, y): return absf(float(x["amount"])) > absf(float(y["amount"])))
	out.append_array(items)
	var capped := clampf(ms, -MOD_CAP, MOD_CAP)
	if absf(capped - ms) >= 0.05:
		out.append({"label": "Most that dealings can add on top of the legal status (%+d)" % int(MOD_CAP if ms > 0 else -MOD_CAP), "amount": snappedf(capped - ms, 0.1),
			"kind": "cap", "since": "", "source": [], "fading": false})
	var tot := 0.0
	for c in out: tot += float(c["amount"])
	var rel := float(e.get("relation", 0.0))
	if absf(rel - tot) >= 0.15:
		out.append({"label": "Limit of the scale (-100 to +100)", "amount": snappedf(rel - tot, 0.1), "kind": "cap", "since": "", "source": [], "fading": false})
	return out


static func relation_level(v: float) -> Dictionary:
	for l in LEVELS:
		if v < float(l[0]):
			return {"id": l[1], "label": l[2]}
	return {"id": "strategic", "label": "Strategic partner"}


func _prune() -> void:
	for a in S().diplomacy:
		var e := _entry(a)
		e["mods"] = e["mods"].filter(func(m): return float(m.get("hl", HALF_LIFE)) <= 0.0 or absf(_mod_now(m)) >= 0.3)


# ================================================================== exposure (dependence on a patron)

func exposure(a: String) -> float:
	var x: Dictionary = D()["exposure"].get(a, {})
	if x.is_empty(): return 0.0
	return float(x.get("v", 0.0)) * pow(0.5, float(maxi(0, S().turn - int(x.get("turn", S().turn)))) / EXPOSURE_HALF_LIFE)


func add_exposure(a: String, amount: float) -> void:
	if absf(amount) < 0.01: return
	D()["exposure"][a] = {"v": maxf(0.0, exposure(a) + amount), "turn": S().turn}


func upcoming_leverage(a: String, within := 40) -> Array:
	var out := []
	for lv in data().get("leverage", []):
		if str(lv.get("actor", "")) != a or D()["applied"].has("lv:" + str(lv["id"])): continue
		var t := _leverage_turn(lv)
		if t >= S().turn and t <= S().turn + within and t <= SimDB.shown_until():
			out.append(lv)
	return out


func _leverage_turn(lv: Dictionary) -> int:
	var ev = sim.db.event_by_id.get(str(lv.get("event", "")))
	if ev != null: return int(ev["_turn"])
	return _t(lv.get("date"), 99999)


# ================================================================== turn hooks

func start_turn() -> void:
	## Called from Sim._start_turn after this quarter's events, forks and status rails.
	if OFF:
		return
	sync()
	_prune()
	recompute_all()
	_sample()
	_check_history()
	_expire_envoys()
	_offer()


func sync() -> void:
	## Applies, once each, the relation causes of events that fired, forks that were answered and patrons' leverage.
	var st := S()
	var ap: Dictionary = D()["applied"]
	if not D().has("init"):
		D()["init"] = st.turn
		for a in st.diplomacy: _entry(a)
	var dd := data()
	for eid in st.fired_events:
		var k := "ev:" + str(eid)
		if ap.has(k): continue
		ap[k] = st.turn
		var ev = sim.db.event_by_id.get(str(eid))
		if ev == null: continue
		var src := _src(ev.get("source", []))
		var title := "%s (%s)" % [ev.get("title", eid), str(ev.get("date", "")).substr(0, 4)]
		if st.flags.has("event_skipped:" + str(eid)):
			continue   # v3 fix3-story (A3): an event your cabinet's answer cancelled leaves no relation memory
		var dip = st.counters.get("diplo_override:" + str(eid), ev.get("effects", {}).get("diplo", {}))
		var explicit := {}
		for r in dd["_ev_rel"].get(str(eid), []):
			explicit[str(r.get("actor", ""))] = true
		if typeof(dip) == TYPE_DICTIONARY:
			for a in dip:
				if explicit.has(str(a)) or not st.diplomacy.has(str(a)): continue
				var amt := float(EVENT_MEMORY.get(str(dip[a]), 0.0))
				if str(dip[a]) == "hostile" and str(st.diplomacy[a].get("status", "")) in ["relations_established", "peace", "normalized"]:
					amt = -25.0   # a quarrel with a state Israel has relations with (France 1968, Turkey 2010)
				add_mod(str(a), amt, title, "event", src)
		for r in dd["_ev_rel"].get(str(eid), []):
			add_mod(str(r["actor"]), float(r.get("amount", 0)), str(r.get("label", title)), "event", _src(r.get("source", src)) if r.has("source") else src, float(r.get("hl", HALF_LIFE)))
	for fid in st.fork_choices:
		var k2 := "fork:" + str(fid)
		if ap.has(k2): continue
		ap[k2] = st.turn
		var f = sim.db.forks.get(str(fid))
		var opt := str(st.fork_choices[fid])
		for r in dd["_fork_rel"].get(str(fid), []):
			if str(r.get("option", "*")) != "*" and str(r.get("option", "")) != opt: continue
			var fs := _src(r.get("source", f.get("source", []) if f != null else []))
			add_mod(str(r["actor"]), float(r.get("amount", 0)), str(r.get("label", "Your decision: %s" % (f.get("title", fid) if f != null else fid))), "fork", fs, float(r.get("hl", HALF_LIFE)))
	for dr in dd.get("dated_relations", []):
		var k4 := "dr:" + str(dr.get("id", ""))
		if ap.has(k4) or st.turn < _t(dr.get("date"), 99999): continue
		ap[k4] = st.turn
		if dr.has("unless_flag") and st.flags.has(str(dr["unless_flag"])): continue   # v3 fix3-story: a cause your answers removed
		for a in dr.get("actors", {}):
			add_mod(str(a), float(dr["actors"][a]), str(dr.get("label", "")), "event", _src(dr.get("source", [])), float(dr.get("hl", HALF_LIFE)))
	for lv in dd.get("leverage", []):
		var k3 := "lv:" + str(lv.get("id", ""))
		if ap.has(k3): continue
		var lt := _leverage_turn(lv)
		if st.turn < lt or lt == 99999: continue
		ap[k3] = st.turn
		_apply_leverage(lv)


func _apply_leverage(lv: Dictionary) -> void:
	var a := str(lv.get("actor", ""))
	var x := exposure(a)
	var src := _src(lv.get("source", []))
	if lv.has("relation"):
		add_mod(a, float(lv["relation"]), str(lv.get("title", "")), "event", src)
	if x < 1.0 or lv.get("per10", {}).is_empty():
		_log(a, "leverage", "%s%s" % [lv.get("title", ""), "" if lv.get("per10", {}).is_empty() else " (you had no dependence to lose)"], {"leverage": lv["id"]})
		return
	var mult := clampf(x / 10.0, 0.0, 2.0)
	var rel := float(S().diplomacy.get(a, {}).get("relation", 0.0))
	if rel < 10.0: mult *= 1.25
	elif rel > 40.0: mult *= 0.75
	var now := {}
	var per: Dictionary = lv.get("per10", {})
	for k in per:
		now[k] = float(per[k]) * mult
	var reason := "%s: your dependence on %s (exposure %.0f) made it bite" % [lv.get("title", ""), actor_name(a), x]
	sim.forks.apply_now(now, reason)
	add_exposure(a, -x * 0.5)
	var txt := "%s. %s" % [lv.get("title", ""), ", ".join(sim.forks.now_text(now))]
	_log(a, "leverage", txt, {"leverage": lv["id"], "exposure": snappedf(x, 0.1)})
	sim.notify("diplomacy", "%s Because you rely on %s, it costs you: %s." % [str(lv.get("text", lv.get("title", ""))), actor_name(a), ", ".join(sim.forks.now_text(now))], {"actor": a, "leverage": lv["id"]})
	S().counters["diplo_leverage_hits"] = int(S().counters.get("diplo_leverage_hits", 0)) + 1


func _sample() -> void:
	if not D().has("rel_hist"): D()["rel_hist"] = {}
	var h: Dictionary = D()["rel_hist"]
	for a in S().diplomacy:
		if not h.has(a): h[a] = []
		var arr: Array = h[a]
		if not arr.is_empty() and int(arr[arr.size() - 1][0]) == S().turn:
			arr[arr.size() - 1] = [S().turn, float(S().diplomacy[a].get("relation", 0.0))]
		else:
			arr.append([S().turn, float(S().diplomacy[a].get("relation", 0.0))])
		if arr.size() > 9: h[a] = arr.slice(arr.size() - 9)


func _check_history() -> void:
	## Once a year (Q2): the legal status of each actor in its era against its real timeline (sim_test report), and
	## the relation of each actor at the start of every decade.
	var t := S().turn
	var last: int = sim.last_playable_turn()   # the game ends after Q3 2023 (user decision), or earlier in the demo
	if SimDB.quarter_of(t) != 2 and t < last: return
	if not D().has("phase_check"): D()["phase_check"] = {}
	if not D().has("samples"): D()["samples"] = {}
	var y := SimDB.year_of(t)
	var sample := {}
	for a in S().diplomacy:
		if not active(a): continue
		sample[a] = snappedf(float(S().diplomacy[a].get("relation", 0.0)), 0.1)
		var p := phase(a)
		# a phase that opens this quarter may wait for an event held behind a decision: checked from next year
		if p.is_empty() or SimDB.quarter_of(t) != 2 or int(p.get("from_turn", 0)) >= t - 1: continue
		var st := str(S().diplomacy[a].get("status", ""))
		var pc: Dictionary = D()["phase_check"].get(a, {"n": 0, "bad": 0, "ex": []})
		pc["n"] = int(pc["n"]) + 1
		if not (st in PHASE_OK.get(str(p["kind"]), [])):
			pc["bad"] = int(pc["bad"]) + 1
			if pc["ex"].size() < 4: pc["ex"].append("%d: status %s vs history %s (%s)" % [y, st, p["kind"], p.get("label", "")])
		D()["phase_check"][a] = pc
	if y % 10 == 0 and SimDB.quarter_of(t) == 2:
		D()["samples"][str(y)] = sample
	if t >= last:
		D()["samples"]["end"] = sample


func trend(a: String) -> float:
	## Relation change over the last year (4 quarters).
	var arr: Array = D().get("rel_hist", {}).get(a, [])
	if arr.is_empty(): return 0.0
	var now := float(S().diplomacy.get(a, {}).get("relation", 0.0))
	for i in range(arr.size() - 1, -1, -1):
		if int(arr[i][0]) <= S().turn - 4:
			return snappedf(now - float(arr[i][0 + 1]), 0.1)
	return snappedf(now - float(arr[0][1]), 0.1)


func _log(a: String, kind: String, text: String, extra := {}) -> void:
	var e := {"turn": S().turn, "date": SimDB.date_label(S().turn), "actor": a, "kind": kind, "text": text}
	e.merge(extra)
	D()["log"].append(e)
	if D()["log"].size() > 400:
		D()["log"] = D()["log"].slice(D()["log"].size() - 350)


func end_turn() -> void:
	## A forced end of turn takes the historical answer to an open envoy.
	if not D()["pending"].is_empty():
		var h := _historical_index(D()["pending"])
		choose(h)


# ================================================================== deals

func deal_def(id: String) -> Dictionary:
	return data()["_deals"].get(id, {})


func _requires_ok(r: Dictionary, a: String) -> String:
	## "" when the conditions hold, else the reason (shown on the deal screen).
	var st := S()
	var status := str(st.diplomacy.get(a, {}).get("status", "none"))
	if r.has("status_in") and not (status in r["status_in"]):
		return "needs %s (now: %s)" % [" or ".join(r["status_in"].map(func(x): return str(STATUS_LABEL.get(x, x)).to_lower())), str(STATUS_LABEL.get(status, status)).to_lower()]
	if r.has("not_status") and status in r["not_status"]:
		return "not while %s" % str(STATUS_LABEL.get(status, status)).to_lower()
	if r.has("event") and not st.fired_events.has(str(r["event"])):
		var ev = sim.db.event_by_id.get(str(r["event"]))
		return "after %s" % (ev.get("title", r["event"]) if ev != null else r["event"])
	if r.has("not_event") and st.fired_events.has(str(r["not_event"])):
		return "no longer possible"
	if r.has("flag") and not st.flags.has(str(r["flag"])):
		return "needs an earlier step"
	if r.has("not_flag") and st.flags.has(str(r["not_flag"])):
		return "ruled out by an earlier choice"
	if r.has("tech") and not st.techs.has(str(r["tech"])):
		return "needs the technology %s" % sim.db.techs.get(str(r["tech"]), {}).get("name", r["tech"])
	if r.has("civic") and not st.civics.has(str(r["civic"])):
		return "needs the civic %s" % sim.db.civics.get(str(r["civic"]), {}).get("name", r["civic"])
	if r.has("deal") and not D()["deals"].has(str(r["deal"])):
		return "needs the deal \"%s\" first" % deal_def(str(r["deal"])).get("title", r["deal"])
	if r.has("choice") and not sim.forks.choice_matches(r["choice"]):
		return "needs an earlier decision"
	return ""


func _scaled_gold(now: Dictionary) -> float:
	return float(now.get("gold", 0.0)) * sim.events.gold_scale()


func deal_status(id: String) -> Dictionary:
	## {available, acceptable, reason, cooldown_left, times}
	var dl := deal_def(id)
	if dl.is_empty():
		return {"available": false, "acceptable": false, "reason": "unknown deal", "cooldown_left": 0, "times": 0}
	var a := str(dl.get("actor", ""))
	var t := S().turn
	var taken: Array = D()["deals"].get(id, [])
	var out := {"available": true, "acceptable": true, "reason": "", "cooldown_left": 0, "times": taken.size()}
	if not active(a):
		out["available"] = false; out["reason"] = "%s is not a partner at this date" % actor_name(a)
	elif t < _t(dl.get("from"), 0) or t > _t(dl.get("until"), 99999):
		out["available"] = false; out["reason"] = "only %s-%s" % [str(dl.get("from", "")).substr(0, 4), str(dl.get("until", "")).substr(0, 4)]
	elif taken.size() >= int(dl.get("max_times", 99)):
		out["available"] = false; out["reason"] = "already concluded"
	elif not taken.is_empty() and t - int(taken[taken.size() - 1]) < int(dl.get("cooldown", 12)):
		out["available"] = false
		out["cooldown_left"] = int(dl.get("cooldown", 12)) - (t - int(taken[taken.size() - 1]))
		out["reason"] = "again in %d quarters" % out["cooldown_left"]
	else:
		var why := _requires_ok(dl.get("requires", {}), a)
		if why != "":
			out["available"] = false; out["reason"] = why
	if out["available"]:
		var rel := float(S().diplomacy.get(a, {}).get("relation", 0.0))
		var need := float(dl.get("relation_min", -100))
		if rel < need:
			out["acceptable"] = false
			out["reason"] = "%s wants a relation of %d or better (now %d)" % [actor_name(a), int(need), int(round(rel))]
		var cost := -_scaled_gold(dl.get("now", {}))
		if cost > 0.0 and S().gold < cost:
			out["acceptable"] = false
			out["reason"] = "costs %d gold (treasury %d)" % [int(round(cost)), int(S().gold)]
	return out


func _abs_terms(lasting: Array) -> Array:
	## Deal terms may be relative ("years": N from now) or dated (fork-style "from"/"until").
	var out := []
	for s in lasting:
		var q: Dictionary = s.duplicate()
		if q.has("years"):
			var t0 := S().turn + int(q.get("delay", 0))
			q["from"] = SimDB.date_iso(t0)
			q["until"] = SimDB.date_iso(t0 + maxi(1, int(round(float(q["years"]) * 4.0))) - 1)
			q.erase("years"); q.erase("delay")
		out.append(q)
	return SimForks.shown_terms(out)   # v3 fix3-story A11: a term starting after the game's end never shows or applies


func _effects_view(now: Dictionary, lasting: Array) -> Dictionary:
	var lt := _abs_terms(lasting)
	return {"now": sim.forks.now_text(now), "lasting": lt.map(func(s): return sim.forks.term_text(s)),
		"effects": sim.forks.now_struct(now) + lt.map(func(s): return sim.forks.term_struct(s))}


func _rel_list(main_actor: String, main_amount: float, others: Dictionary) -> Array:
	var out := []
	if main_actor != "" and absf(main_amount) > 0.0:
		out.append({"actor": main_actor, "name": actor_name(main_actor), "amount": main_amount})
	for o in others:
		if S().diplomacy.has(str(o)):
			out.append({"actor": str(o), "name": actor_name(str(o)), "amount": float(others[o])})
	return out


func deal_view(id: String) -> Dictionary:
	var dl := deal_def(id)
	if dl.is_empty(): return {}
	var a := str(dl.get("actor", ""))
	var stt := deal_status(id)
	var fx := _effects_view(dl.get("now", {}), dl.get("lasting", []))
	var give: Array = fx["effects"].filter(func(e): return not e.get("good", true))
	var get_: Array = fx["effects"].filter(func(e): return e.get("good", true))
	var exp_amt := float(dl.get("exposure", 0.0))
	var risks := []
	if exp_amt > 0.0:
		for lv in data().get("leverage", []):
			if str(lv.get("actor", "")) == a and not D()["applied"].has("lv:" + str(lv["id"])) and _leverage_turn(lv) >= S().turn \
					and _leverage_turn(lv) <= maxi(S().turn, _t(dl.get("from"), S().turn)) + RISK_WINDOW and _leverage_turn(lv) <= SimDB.shown_until():
				risks.append(str(lv.get("risk", lv.get("title", ""))))
	return {"id": id, "actor": a, "actor_name": actor_name(a), "kind": str(dl.get("kind", "")), "kind_label": str(KIND_LABEL.get(str(dl.get("kind", "")), dl.get("kind", ""))),
		"title": str(dl.get("title", id)), "text": str(dl.get("text", "")), "years": "%s-%s" % [str(dl.get("from", "")).substr(0, 4), str(dl.get("until", "")).substr(0, 4)],
		"available": stt["available"], "acceptable": stt["acceptable"], "reason": stt["reason"], "cooldown_left": stt["cooldown_left"], "times_taken": stt["times"],
		"give": give, "get": get_, "now": fx["now"], "lasting": fx["lasting"], "effects": fx["effects"],
		"relation": _rel_list(a, float(dl.get("relation", 0.0)), dl.get("others", {})), "exposure": exp_amt,
		"risk_text": str(dl.get("risk_text", "")) if exp_amt > 0.0 else "", "risks": risks,
		"historical": bool(dl.get("historical", true)), "advocate": str(dl.get("advocate", "")), "cite": dl.get("cite", []), "source": _src(dl.get("source", [])),
		"relation_min": int(dl.get("relation_min", -100)),
		# aliases in the shape ui-v3 asked for (INTEGRATION_REQUESTS v3 item 8)
		"label": str(dl.get("title", id)), "desc": str(dl.get("text", "")), "cost": _cost_of(dl), "effects_text": fx["now"] + fx["lasting"],
		"tradeoffs": _tradeoffs(dl, a), "cooldown": stt["cooldown_left"], "counter": counter_view(dl)}


func _cost_of(dl: Dictionary) -> Dictionary:
	var c := {}
	var now: Dictionary = dl.get("now", {})
	for k in now:
		var v := float(now[k])
		if k in ["gold", "production", "science", "culture"]: v *= sim.events.gold_scale()
		if (k == "inflation" and v > 0.0) or (k != "inflation" and v < 0.0):
			c[k] = snappedf(absf(v), 1.0 if k in ["gold", "production", "science", "culture"] else 0.1)   # v3 fix4-diplo: whole gold
	return c


func _tradeoffs(dl: Dictionary, a: String) -> Array:
	var out := []
	var others: Dictionary = dl.get("others", {})
	for o in others:
		if S().diplomacy.has(str(o)):
			out.append("%s %s%d relation" % [actor_name(str(o)), "+" if float(others[o]) >= 0 else "", int(round(float(others[o])))])
	if float(dl.get("exposure", 0.0)) > 0.0:
		out.append("Dependence on %s +%d: %s" % [actor_name(a), int(round(float(dl["exposure"]))), str(dl.get("risk_text", "if they use their leverage, you pay in proportion"))])
	return out


func deals_for(a: String, include_unavailable := true) -> Array:
	var out := []
	for dl in data().get("deals", []):
		if str(dl.get("actor", "")) != a: continue
		var t := S().turn
		# a deal outside its era is not listed at all; inside its era it shows with the reason it cannot be made yet
		if t < _t(dl.get("from"), 0) - 4 or t > _t(dl.get("until"), 99999): continue
		var v := deal_view(str(dl["id"]))
		if include_unavailable or v["available"]:
			out.append(v)
	return out


func propose(id: String, variant := "") -> Dictionary:
	## The player makes the deal (Civ VI "Make Deal" -> "Accept Deal"). Returns {ok, reason, deal}.
	## v3 fix3-story (A6): variant "counter" proposes the deal on the sourced counter-terms of its era (deal_view
	## "counter"), where history had one: more of the gain, less of the goodwill.
	var stt := deal_status(id)
	if not stt["available"] or not stt["acceptable"]:
		return {"ok": false, "reason": stt["reason"], "deal": deal_view(id)}
	if variant == "counter":
		var tm: Dictionary = offer_of(deal_def(id)).get("terms", {})
		if tm.is_empty():
			return {"ok": false, "reason": "no counter-offer for this deal", "deal": deal_view(id)}
		_take_deal(id, float(tm.get("gain_mult", 1.3)), float(tm.get("rel_mult", 0.3)), tm.get("now", {}), "on better terms")
		return {"ok": true, "reason": "", "deal": deal_view(id)}
	_take_deal(id, 1.0, 1.0, {}, "")
	return {"ok": true, "reason": "", "deal": deal_view(id)}


func counter_view(dl: Dictionary) -> Dictionary:
	## The deal's sourced counter-offer as the deal screen shows it ({} if none): {label, advocate, cite, note, now, lasting, effects, relation}.
	var tm: Dictionary = offer_of(dl).get("terms", {})
	if tm.is_empty() or (not bool(tm.get("historical", false)) and (str(tm.get("advocate", "")) == "" or tm.get("cite", []).is_empty())):
		return {}
	var gm := float(tm.get("gain_mult", 1.3))
	var now: Dictionary = dl.get("now", {}).duplicate()
	var lasting := _abs_terms(dl.get("lasting", []))
	for k in now:
		if float(now[k]) > 0.0 and k != "inflation": now[k] = float(now[k]) * gm
	for st in lasting:
		if float(st.get("amount", 0)) > 0.0 and str(st.get("type", "")) != "inflation": st["amount"] = float(st["amount"]) * gm
	for k in tm.get("now", {}):
		now[k] = float(now.get(k, 0.0)) + float(tm["now"][k])
	var fx := _effects_view(now, [])
	return {"id": "counter", "label": str(tm.get("label", "Press for better terms")), "advocate": str(tm.get("advocate", "")), "historical": bool(tm.get("historical", false)),
		"cite": tm.get("cite", []), "note": str(tm.get("note", "")), "now": fx["now"], "lasting": lasting.map(func(x): return sim.forks.term_text(x)),
		"effects": fx["effects"] + lasting.map(func(x): return sim.forks.term_struct(x)),
		"relation": _rel_list(str(dl.get("actor", "")), float(dl.get("relation", 0.0)) * float(tm.get("rel_mult", 0.3)), dl.get("others", {}))}


func _take_deal(id: String, gain_mult: float, rel_mult: float, extra_now: Dictionary, via: String) -> void:
	var dl := deal_def(id)
	var a := str(dl.get("actor", ""))
	var reason := "%s: %s" % [actor_name(a), dl.get("title", id)]
	var now: Dictionary = dl.get("now", {}).duplicate()
	for k in extra_now:
		now[k] = float(now.get(k, 0.0)) + float(extra_now[k])
	var lasting := _abs_terms(dl.get("lasting", []))
	if gain_mult != 1.0:
		for k in now:
			if float(now[k]) > 0.0 and k != "inflation": now[k] = float(now[k]) * gain_mult
		for s in lasting:
			if float(s.get("amount", 0)) > 0.0 and str(s.get("type", "")) != "inflation": s["amount"] = float(s["amount"]) * gain_mult
	sim.forks.apply_now(now, reason)
	sim.forks.add_terms(lasting, "dip:" + id, reason)
	for fl in dl.get("flags", []):
		S().flags[str(fl)] = S().turn
	add_mod(a, float(dl.get("relation", 0.0)) * rel_mult, "%s: %s" % [KIND_LABEL.get(str(dl.get("kind", "")), "Deal"), dl.get("title", id)], "deal", _src(dl.get("source", [])))
	var others: Dictionary = dl.get("others", {})
	for o in others:
		add_mod(str(o), float(others[o]), "%s's deal with %s: %s" % ["Israel", actor_name(a), dl.get("title", id)], "deal", _src(dl.get("source", [])))
	add_exposure(a, float(dl.get("exposure", 0.0)))
	if not D()["deals"].has(id): D()["deals"][id] = []
	D()["deals"][id].append(S().turn)
	var c: Dictionary = D()["counts"]
	c[str(dl.get("kind", ""))] = int(c.get(str(dl.get("kind", "")), 0)) + 1
	_log(a, "deal", "%s%s" % [dl.get("title", id), (" (" + via + ")") if via != "" else ""], {"deal": id})
	sim.notify("diplomacy", "Deal with %s: %s" % [actor_name(a), dl.get("title", id)], {"actor": a, "deal": id})
	if str(dl.get("moment", "")) != "":
		sim.add_moment(str(dl["moment"]), 1, "diplomacy")
	sim.refresh()


func send_delegation_mod(a: String) -> void:
	add_mod(a, 8.0, "Delegations", "delegation", [], 12.0)


func trade_partner_extra(a: String) -> bool:
	## A liaison or trade office opened by a deal makes the actor an export-route partner before full relations.
	return S().flags.has("liaison:" + a) and active(a)


# ================================================================== envoys (the recurring decision)

func envoy_def(id: String) -> Dictionary:
	return data()["_envoys"].get(id, {})


func _envoy_ok(ev: Dictionary) -> bool:
	var id := str(ev.get("id", ""))
	if D()["envoys"].has(id): return false
	var t := S().turn
	if t < _t(ev.get("date"), 99999) or t > _t(ev.get("until"), _t(ev.get("date"), 0) + 4): return false
	var a := str(ev.get("actor", ""))
	if not active(a): return false
	if _requires_ok(ev.get("requires", {}), a) != "": return false
	if fork_asks_same(ev) != "": return false
	var opts := _envoy_options(ev)
	return opts.size() >= 2


func fork_asks_same(ev: Dictionary) -> String:
	## v3 fix3-story (A2): an envoy whose question a cabinet fork asks within 2 quarters is not offered (data
	## "subject_fork": fork id or list). Returns the fork id, or "".
	var sf = ev.get("subject_fork", [])
	var lst: Array = sf if typeof(sf) == TYPE_ARRAY else [sf]
	for fid in lst:
		var f = sim.db.forks.get(str(fid))
		if f == null or S().flags.has("fork_skipped:" + str(fid)): continue
		var ft := SimDB.turn_of(f.get("date"), -99)
		var fu := SimDB.turn_of(f.get("until"), ft + 4)
		if S().fork_choices.has(str(fid)) or str(fid) in S().pending_forks or (S().turn >= ft - 2 and S().turn <= fu + 2):
			return str(fid)
	return ""


func _expire_envoys() -> void:
	var t := S().turn
	for ev in data().get("envoys", []):
		var id := str(ev.get("id", ""))
		if D()["envoys"].has(id): continue
		if t > _t(ev.get("until"), _t(ev.get("date"), 0) + 4) and str(D()["pending"].get("envoy", "")) != id:
			D()["envoys"][id] = "skipped"


func offer_era(dl: Dictionary) -> int:
	## v3 fix3-story (A5): a deal with "offer_eras" proposes itself once per era, with that era's text, cites and
	## options. Returns the open era's index (-1: none open or already offered; -2: the deal has no eras).
	var eras = dl.get("offer_eras", [])
	if typeof(eras) != TYPE_ARRAY or eras.is_empty(): return -2
	var t := S().turn
	var done: Dictionary = D().get("offer_eras_done", {})
	for i in range(eras.size()):
		var e: Dictionary = eras[i]
		if t >= _t(e.get("from"), 0) and t <= _t(e.get("until"), 99999) and not done.has("%s:%d" % [dl.get("id", ""), i]):
			if typeof(e.get("requires")) == TYPE_DICTIONARY and _requires_ok(e["requires"], str(dl.get("actor", ""))) != "":
				continue
			return i
	return -1


func offer_of(dl: Dictionary) -> Dictionary:
	## The proposal as it stands now: the pending era's offer, the open era's offer, or the deal's single "offer".
	var p: Dictionary = D()["pending"]
	var i := -1
	if not p.is_empty() and str(p.get("kind", "")) == "offer" and str(p.get("id", "")) == str(dl.get("id", "")) and p.has("era"):
		i = int(p["era"])
	elif dl.has("offer_eras"):
		i = offer_era(dl)
	var eras = dl.get("offer_eras", [])
	if i >= 0 and typeof(eras) == TYPE_ARRAY and i < eras.size():
		var m: Dictionary = dl.get("offer", {}).duplicate(true)
		for k in eras[i]:
			if not (k in ["from", "until"]): m[k] = eras[i][k]
		if not eras[i].has("terms"): m.erase("terms")
		if not eras[i].has("decline"): m.erase("decline")
		return m
	return dl.get("offer", {})


func _deal_offer_ok(dl: Dictionary) -> bool:
	if not dl.has("offer") and not dl.has("offer_eras"): return false
	if offer_era(dl) == -1: return false
	if not bool(offer_of(dl).get("propose", true)): return false   # v3 fix4-diplo: a counter-offer era shown on the deal screen only
	var id := str(dl.get("id", ""))
	var a := str(dl.get("actor", ""))
	if S().turn - int(D()["last_offer_actor"].get(a, -99)) < OFFER_ACTOR_GAP: return false
	var stt := deal_status(id)
	if not stt["available"]: return false
	# the partner proposes only what it would accept; the treasury check is the player's problem (they may decline)
	var rel := float(S().diplomacy.get(a, {}).get("relation", 0.0))
	if rel < float(dl.get("relation_min", -100)): return false
	return _deal_offer_options(dl).size() >= 2


func candidates() -> Array:
	var out := []
	for ev in data().get("envoys", []):
		if _envoy_ok(ev):
			out.append({"kind": "envoy", "id": str(ev["id"]), "until": _t(ev.get("until"), _t(ev.get("date"), 0) + 4), "def": ev})
	if out.is_empty():
		for dl in data().get("deals", []):
			if _deal_offer_ok(dl):
				# an era offer (A5) closes with its era, so on its last quarter it is made even on a busy turn
				var ei := offer_era(dl)
				var eu: int = _t(dl["offer_eras"][ei].get("until"), 99999) if ei >= 0 else 99999
				out.append({"kind": "offer", "id": str(dl["id"]), "until": eu, "def": dl})
	out.sort_custom(func(x, y): return int(x["until"]) < int(y["until"]))
	return out


func _busy() -> bool:
	for d in sim.get_pending_decisions():
		if str(d.get("type", "")) in CORE:
			return true
	return false


func _offer() -> void:
	var dd := D()
	if not dd["pending"].is_empty():
		return
	var t := S().turn
	var cands := candidates()
	if cands.is_empty():
		return
	var c: Dictionary = cands[0]
	var must := int(c["until"]) <= t
	# v3 fix4-diplo: a dated envoy in its last quarter (the Hassan channel, the US-PLO dialogue) is offered even
	# right after another diplomatic decision, so it never comes a quarter late
	if t - int(dd["last_offer"]) < MIN_GAP and not (must and c["kind"] == "envoy" and int(dd["last_offer"]) < t):
		return
	if not must and t - int(dd["last_offer"]) < MAX_GAP and _busy():
		return
	if c["kind"] == "offer":
		# deal offers rotate between partners (oldest proposal first) and come at most every other opening
		var offers := cands.filter(func(x): return x["kind"] == "offer")
		offers.sort_custom(func(x, y): return int(dd["last_offer_actor"].get(str(x["def"].get("actor", "")), -99)) < int(dd["last_offer_actor"].get(str(y["def"].get("actor", "")), -99)))
		c = offers[(t / 2) % mini(2, offers.size())]
	dd["pending"] = {"kind": c["kind"], "id": c["id"], "turn": t}
	if c["kind"] == "offer":
		var era := offer_era(c["def"])
		if era >= 0:
			dd["pending"]["era"] = era
			if not dd.has("offer_eras_done"): dd["offer_eras_done"] = {}
			dd["offer_eras_done"]["%s:%d" % [c["id"], era]] = t
	dd["last_offer"] = t
	var a := str(c["def"].get("actor", ""))
	dd["last_offer_actor"][a] = t
	sim.notify("diplomacy", "Envoy from %s: %s" % [actor_name(a), _decision_title(c["kind"], c["def"])], {"actor": a})


func _decision_title(kind: String, d: Dictionary) -> String:
	if kind == "offer":
		return str(offer_of(d).get("title", "%s proposes: %s" % [actor_name(str(d.get("actor", ""))), d.get("title", "")]))
	return str(d.get("title", ""))


func _envoy_options(ev: Dictionary) -> Array:
	## Options that may be shown: the historical one, and each other one only with a named advocate and a cite.
	var out := []
	for o in ev.get("options", []):
		if o.get("historical", false) or (str(o.get("advocate", "")) != "" and not o.get("cite", []).is_empty()):
			if o.has("deal") and not deal_status(str(o["deal"]))["available"]:
				continue
			out.append(o)
	return out


func _deal_offer_options(dl: Dictionary) -> Array:
	## A partner's proposal: accept as offered, press for better terms, or decline (each sourced in the deal's "offer").
	var of: Dictionary = offer_of(dl)
	var hist_accept := bool(of.get("accept_historical", dl.get("historical", true)))
	var out := []
	var acc := {"id": "accept", "label": str(of.get("accept_label", "Accept: " + str(dl.get("title", "")))), "historical": hist_accept, "deal": str(dl["id"]),
		"advocate": str(of.get("accept_advocate", dl.get("advocate", ""))), "cite": of.get("accept_cite", dl.get("cite", [])), "note": str(of.get("accept_note", ""))}
	out.append(acc)
	if of.has("terms"):
		var tm: Dictionary = of["terms"]
		out.append({"id": "counter", "label": str(tm.get("label", "Press for better terms")), "historical": bool(tm.get("historical", false)), "deal": str(dl["id"]),
			"gain_mult": float(tm.get("gain_mult", 1.3)), "rel_mult": float(tm.get("rel_mult", 0.3)), "now_extra": tm.get("now", {}),
			"advocate": str(tm.get("advocate", "")), "cite": tm.get("cite", []), "note": str(tm.get("note", ""))})
	if of.has("delay"):
		var dy: Dictionary = of["delay"]
		out.append({"id": "delay", "label": str(dy.get("label", "Ask for time")), "historical": bool(dy.get("historical", false)),
			"relation": float(dy.get("relation", -2.0)), "now": dy.get("now", {}), "lasting": dy.get("lasting", []),
			"advocate": str(dy.get("advocate", "")), "cite": dy.get("cite", []), "note": str(dy.get("note", ""))})
	if of.has("decline"):
		var dc: Dictionary = of["decline"]
		out.append({"id": "decline", "label": str(dc.get("label", "Decline politely")), "historical": bool(dc.get("historical", not hist_accept)),
			"relation": float(dc.get("relation", -4.0)), "now": dc.get("now", {}), "lasting": dc.get("lasting", []),
			"advocate": str(dc.get("advocate", "")), "cite": dc.get("cite", []), "note": str(dc.get("note", ""))})
	return out.filter(func(o): return o.get("historical", false) or (str(o.get("advocate", "")) != "" and not o.get("cite", []).is_empty()))


func _pending_def() -> Dictionary:
	var p: Dictionary = D()["pending"]
	if p.is_empty(): return {}
	return deal_def(str(p["id"])) if str(p["kind"]) == "offer" else envoy_def(str(p["id"]))


func _pending_options() -> Array:
	var p: Dictionary = D()["pending"]
	if p.is_empty(): return []
	var d := _pending_def()
	return _deal_offer_options(d) if str(p["kind"]) == "offer" else _envoy_options(d)


func _option_effects(o: Dictionary) -> Dictionary:
	## {now, lasting, relation{actor: amount}, exposure{actor: amount}, actor} of an option as it would apply.
	var a := str(_pending_def().get("actor", ""))
	var now := {}
	var lasting := []
	var rel := {}
	var expo := {}
	if o.has("deal"):
		var dl := deal_def(str(o["deal"]))
		a = str(dl.get("actor", a))
		now = dl.get("now", {}).duplicate()
		lasting = _abs_terms(dl.get("lasting", []))
		var gm := float(o.get("gain_mult", 1.0))
		if gm != 1.0:
			for k in now:
				if float(now[k]) > 0.0 and k != "inflation": now[k] = float(now[k]) * gm
			for s in lasting:
				if float(s.get("amount", 0)) > 0.0 and str(s.get("type", "")) != "inflation": s["amount"] = float(s["amount"]) * gm
		for k in o.get("now_extra", {}):
			now[k] = float(now.get(k, 0.0)) + float(o["now_extra"][k])
		rel[a] = float(dl.get("relation", 0.0)) * float(o.get("rel_mult", 1.0))
		for x in dl.get("others", {}):
			rel[str(x)] = float(rel.get(str(x), 0.0)) + float(dl["others"][x])
		if float(dl.get("exposure", 0.0)) > 0.0: expo[a] = float(dl["exposure"])
	for k in o.get("now", {}):
		now[k] = float(now.get(k, 0.0)) + float(o["now"][k])
	lasting.append_array(_abs_terms(o.get("lasting", [])))
	if o.has("relation"):
		var r = o["relation"]
		if typeof(r) == TYPE_DICTIONARY:
			for x in r: rel[str(x)] = float(rel.get(str(x), 0.0)) + float(r[x])
		else:
			rel[a] = float(rel.get(a, 0.0)) + float(r)
	for x in o.get("exposure", {}):
		expo[str(x)] = float(expo.get(str(x), 0.0)) + float(o["exposure"][x])
	return {"now": now, "lasting": lasting, "relation": rel, "exposure": expo, "actor": a}


func decision() -> Dictionary:
	## The open diplomatic decision (get_pending_decisions type "diplomacy"), or {}.
	var p: Dictionary = D()["pending"]
	if p.is_empty(): return {}
	var d := _pending_def()
	if d.is_empty():
		D()["pending"] = {}
		return {}
	var a := str(d.get("actor", ""))
	var opts := _pending_options()
	var views := []
	for o in opts:
		var fx := _option_effects(o)
		var ev := {"now": sim.forks.now_text(fx["now"]), "lasting": fx["lasting"].map(func(s): return sim.forks.term_text(s)),
			"effects": sim.forks.now_struct(fx["now"]) + fx["lasting"].map(func(s): return sim.forks.term_struct(s))}
		var rl := []
		for x in fx["relation"]:
			if absf(float(fx["relation"][x])) >= 0.5:
				rl.append({"actor": x, "name": actor_name(x), "amount": snappedf(float(fx["relation"][x]), 0.1)})
		var ex := []
		for x in fx["exposure"]:
			ex.append({"actor": x, "name": actor_name(x), "amount": snappedf(float(fx["exposure"][x]), 0.1), "risks": upcoming_leverage(x, RISK_WINDOW).map(func(l): return str(l.get("risk", l.get("title", ""))))})
		views.append({"id": str(o["id"]), "label": str(o.get("label", "")), "advocate": str(o.get("advocate", "")), "historical": bool(o.get("historical", false)),
			"now": ev["now"], "lasting": ev["lasting"], "effects": ev["effects"], "relation": rl, "exposure": ex,
			"cite": o.get("cite", []), "note": str(o.get("note", "")), "deal": str(o.get("deal", "")), "default": false,
			"desc": str(o.get("note", "")), "effects_text": ev["now"] + ev["lasting"], "fx": fx["now"], "actor": str(fx["actor"])})
	var rec := recommended_index(opts)
	if rec >= 0 and rec < views.size(): views[rec]["default"] = true
	var kind := str(p["kind"])
	var text := str(d.get("text", "")) if kind == "envoy" else str(offer_of(d).get("text", d.get("text", "")))
	var rel := float(S().diplomacy.get(a, {}).get("relation", 0.0))
	return {"type": "diplomacy", "blocking": true, "label": "ENVOY: " + _decision_title(kind, d), "envoy": str(p["id"]),
		"kind": str(d.get("kind", "envoy")) if kind == "envoy" else "offer", "actor": a, "actor_name": actor_name(a),
		"title": _decision_title(kind, d), "text": text, "date": SimDB.date_label(S().turn), "options": views,
		"source": _src(d.get("source", [])), "relation": rel, "relation_level": relation_level(rel), "status": str(S().diplomacy.get(a, {}).get("status", "none")),
		"phase": phase_view(a), "leader": leader(a),
		"explain": "A diplomatic opportunity of this date. History stays on its rails; what you answer moves your relations, your dependence on patrons and your six tracks. The option marked historical is what Israel did; every other option names who argued for it at the time."}


func _historical_index(_p := {}) -> int:
	var opts := _pending_options()
	for i in range(opts.size()):
		if opts[i].get("historical", false): return i
	return 0


func choose(option) -> bool:
	## option: index (int) or option id (String).
	var p: Dictionary = D()["pending"]
	if p.is_empty(): return false
	var d := _pending_def()
	var opts := _pending_options()
	var idx := -1
	for i in range(opts.size()):
		if (typeof(option) == TYPE_INT and int(option) == i) or (typeof(option) == TYPE_STRING and str(opts[i]["id"]) == str(option)):
			idx = i
	if idx < 0: return false
	var o: Dictionary = opts[idx]
	var a := str(d.get("actor", ""))
	var title := _decision_title(str(p["kind"]), d)
	var key := str(p["id"])
	D()["pending"] = {}
	# the ghost of history (and the historical-picks autoplayer) IS history's baseline: its historical answers move
	# relations only, so the ghost's six tracks and its calibration do not change; everyone else gets the terms
	var baseline: bool = bool(o.get("historical", false)) and SimAI.historical(sim)
	if baseline:
		var rb = o.get("relation", 0.0)
		if o.has("deal"):
			var dl0 := deal_def(str(o["deal"]))
			if not D()["deals"].has(str(o["deal"])): D()["deals"][str(o["deal"])] = []
			D()["deals"][str(o["deal"])].append(S().turn)   # concluded (history's baseline): on cooldown like any deal
			add_mod(str(dl0.get("actor", a)), float(dl0.get("relation", 0.0)), "%s: %s" % [KIND_LABEL.get(str(dl0.get("kind", "")), "Deal"), dl0.get("title", "")], "deal", _src(dl0.get("source", [])))
		if typeof(rb) == TYPE_DICTIONARY:
			for x in rb: add_mod(str(x), float(rb[x]), title, "envoy", _src(d.get("source", [])))
		elif absf(float(rb)) > 0.0:
			add_mod(a, float(rb), title, "envoy", _src(d.get("source", [])))
		D()["envoys"][key] = str(o["id"])
		S().milestones["dip:%s:%s" % [key, o["id"]]] = S().turn
		_log(a, "envoy", "%s: %s" % [title, o.get("label", "")], {"envoy": key, "option": str(o["id"]), "historical": true})
		recompute_all()
		return true
	if o.has("deal"):
		var gm := float(o.get("gain_mult", 1.0))
		_take_deal(str(o["deal"]), gm, float(o.get("rel_mult", 1.0)), o.get("now_extra", {}), "envoy" if gm == 1.0 else "on better terms")
	var reason := "%s: %s" % [title, o.get("label", "")]
	sim.forks.apply_now(o.get("now", {}), reason)
	sim.forks.add_terms(_abs_terms(o.get("lasting", [])), "dip:" + key, reason)
	var r = o.get("relation", 0.0)
	if typeof(r) == TYPE_DICTIONARY:
		for x in r: add_mod(str(x), float(r[x]), title, "envoy", _src(d.get("source", [])))
	elif absf(float(r)) > 0.0:
		add_mod(a, float(r), title, "envoy", _src(d.get("source", [])))
	for x in o.get("exposure", {}):
		add_exposure(str(x), float(o["exposure"][x]))
	for fl in o.get("flags", []):
		S().flags[str(fl)] = S().turn
	D()["envoys"][key] = str(o["id"])
	S().milestones["dip:%s:%s" % [key, o["id"]]] = S().turn
	var hist := {}
	for oo in opts:
		if oo.get("historical", false): hist = oo
	if not o.get("historical", false):
		S().counters["diplo_counterfactual"] = int(S().counters.get("diplo_counterfactual", 0)) + 1
	_log(a, "envoy", "%s: %s" % [title, o.get("label", "")], {"envoy": key, "option": str(o["id"]), "historical": bool(o.get("historical", false))})
	if not hist.is_empty() and str(hist.get("id", "")) != str(o["id"]):
		sim.notify("what_happened", "What actually happened: %s%s" % [hist.get("label", ""), (". " + str(hist.get("note", ""))) if str(hist.get("note", "")) != "" else ""],
			{"envoy": key, "chosen": o["id"], "historical": hist.get("id", "")})
	recompute_all()
	sim.refresh()
	return true


# ================================================================== recommended picks and the autoplayers

func _track_weights() -> Dictionary:
	## Tracks where the player trails the ghost weigh more; an empty treasury makes gold urgent; a war on the
	## horizon makes readiness urgent.
	var w := {"economy": 1.0, "standing": 1.0, "cohesion": 1.0, "science": 1.0, "water": 1.0, "population": 1.0, "readiness": 0.8}
	var v: Dictionary = sim.score.values()
	var g: Dictionary = sim.score.ghost_at(S().turn)
	for tr in w.keys():
		if g.has(tr) and float(g[tr]) > 0.0 and v.has(tr):
			w[tr] = float(w[tr]) + 2.0 * clampf(1.0 - float(v[tr]) / float(g[tr]), 0.0, 0.5)
	var gs: float = sim.events.gold_scale()
	if S().gold < 80.0 * gs: w["economy"] = float(w["economy"]) + 0.8
	elif S().gold > 400.0 * gs: w["economy"] = float(w["economy"]) - 0.4
	if S().readiness < 45.0: w["readiness"] = float(w["readiness"]) + 0.6
	for ev in sim.get_upcoming_events(8):
		if str(ev.get("kind", "")) in ["war"]:
			w["readiness"] = float(w["readiness"]) + 0.8
			break
	if S().standing < 45.0: w["standing"] = float(w["standing"]) + 0.5
	return w


const NOW_TRACK := {"gold": ["economy", 40.0], "standing": ["standing", 2.0], "trust": ["cohesion", 2.0], "readiness": ["readiness", 6.0],
	"cohesion": ["cohesion", 8.0], "inflation": ["economy", -2.0], "production": ["economy", 60.0], "science": ["science", 40.0], "culture": ["standing", 60.0]}


func value_of(fx: Dictionary, w: Dictionary) -> float:
	var v := 0.0
	var now: Dictionary = fx.get("now", {})
	for k in now:
		var m: Array = NOW_TRACK.get(k, ["economy", 50.0])
		v += float(now[k]) / float(m[1]) * float(w.get(m[0], 1.0))
	for s in fx.get("lasting", []):
		var t := str(s.get("type", ""))
		var val := float(s.get("amount", 0)) / float(SimDB.TERM_TYPICAL.get(t, 1.0))
		if t == "inflation": val = -val
		if t == "immigrant_weight": val = 0.0
		var yrs := maxf(0.25, float(SimDB.turn_of(s.get("until"), 0) - SimDB.turn_of(s.get("from"), 0) + 1) / 4.0)
		var tr := str(SimDB.TERM_TRACK.get(t, "economy")).replace("economy_neg", "economy")
		v += val * clampf(yrs / 8.0, 0.25, 3.0) * float(w.get(tr, 1.0))
	for a in fx.get("relation", {}):
		# relations matter most where they are poor; a close partner's extra goodwill is worth less
		var cur := float(S().diplomacy.get(str(a), {}).get("relation", 0.0))
		var k := 1.5 if cur < 0.0 else (1.0 if cur < 50.0 else 0.5)
		v += float(fx["relation"][a]) * (0.025 if sim.db.actors.get(str(a), {}).get("partner", false) else 0.012) * k
	for a in fx.get("exposure", {}):
		var soon := upcoming_leverage(str(a), 60).size() > 0
		# more dependence on a patron you already lean on is worth less (diversify suppliers and donors)
		v -= float(fx["exposure"][a]) * (0.06 if soon else 0.015) * (1.0 + exposure(str(a)) / 10.0)
	return v


func option_values(opts: Array) -> Array:
	var w := _track_weights()
	var out := []
	for o in opts:
		out.append(value_of(_option_effects(o), w))
	return out


func recommended_index(opts: Array) -> int:
	if opts.is_empty(): return -1
	var vals := option_values(opts)
	var best := 0; var bv := -1e9
	for i in range(opts.size()):
		var v := float(vals[i]) + (0.05 if opts[i].get("historical", false) else 0.0)
		if v > bv: bv = v; best = i
	return best


func ai_pick(style: String) -> int:
	var opts := _pending_options()
	if opts.is_empty(): return -1
	if style == "historical":
		return _historical_index()
	if style == "varied":
		var vals := option_values(opts)
		var best := -1; var bv := -1e9
		for i in range(opts.size()):
			if opts[i].get("historical", false): continue
			if float(vals[i]) > bv: bv = float(vals[i]); best = i
		return best if best >= 0 else _historical_index()
	return recommended_index(opts)


const VARIED_KINDS := ["trade", "joint", "back_channel", "recognition", "un_vote"]


func ai_turn(style: String) -> void:
	## The autoplayers' use of the deal screen (at most one deal a quarter). The ghost of history makes none.
	if OFF:
		return
	if style == "historical" or S().mode == "historical":
		return
	var w := _track_weights()
	var best := ""; var bv := 0.35
	var gs: float = sim.events.gold_scale()
	for dl in data().get("deals", []):
		var id := str(dl["id"])
		var stt := deal_status(id)
		if not stt["available"] or not stt["acceptable"]: continue
		var cost := -_scaled_gold(dl.get("now", {}))
		if cost > 0.0 and S().gold - cost < 120.0 * gs: continue
		var fx := {"now": dl.get("now", {}), "lasting": _abs_terms(dl.get("lasting", [])), "relation": {str(dl["actor"]): float(dl.get("relation", 0.0))}, "exposure": {}}
		for x in dl.get("others", {}): fx["relation"][str(x)] = float(dl["others"][x])
		if float(dl.get("exposure", 0.0)) > 0.0: fx["exposure"][str(dl["actor"])] = float(dl["exposure"])
		var v := value_of(fx, w)
		if style == "varied":
			v += 0.25 if str(dl.get("kind", "")) in VARIED_KINDS else -0.25
		if v > bv:
			bv = v; best = id
	if best != "":
		_take_deal(best, 1.0, 1.0, {}, "")


# ================================================================== views for the UI

func decorate(list: Array) -> Array:
	## Adds v3 fields to Sim.get_diplomacy() rows (additive).
	for r in list:
		var a := str(r.get("id", ""))
		var rel := float(r.get("relation", 0.0))
		r["relation"] = snappedf(rel, 0.1)
		r["relation_level"] = relation_level(rel)
		r["status_label"] = str(STATUS_LABEL.get(str(r.get("status", "")), r.get("status", "")))
		r["phase"] = phase_view(a)
		r["active"] = active(a)
		var top := causes(a).slice(0, 3)
		r["top_causes"] = top
		var n := 0
		for dl in data().get("deals", []):
			if str(dl.get("actor", "")) == a:
				var s := deal_status(str(dl["id"]))
				if s["available"] and s["acceptable"]: n += 1
		r["deals_ready"] = n
		r["exposure"] = snappedf(exposure(a), 0.1)
		r["portrait"] = str(actor_def(a).get("portrait", ""))
		r["region"] = str(actor_def(a).get("group", ""))
	return list


func get_actor(a: String) -> Dictionary:
	## Everything the diplomacy screen shows for one actor (see API.md "## v3 (sim-diplomacy)").
	if not S().diplomacy.has(a): return {}
	var e := _entry(a)
	var ad := actor_def(a)
	var rel := float(e.get("relation", 0.0))
	var st := str(e.get("status", "none"))
	var hist: Array = D()["log"].filter(func(x): return str(x.get("actor", "")) == a)
	var tl := timeline(a)
	for p in tl:
		p["current"] = int(p["from_turn"]) <= S().turn and S().turn <= int(p["to_turn"])
		p["past"] = int(p["to_turn"]) < S().turn
	var risks := upcoming_leverage(a, RISK_WINDOW).map(func(l): return {"title": str(l.get("risk", l.get("title", ""))), "source": _src(l.get("source", []))})
	return {"id": a, "name": actor_name(a), "kind": str(sim.db.actors.get(a, {}).get("kind", "")), "active": active(a),
		"era": {"from": str(ad.get("from", "")), "until": str(ad.get("until", ""))}, "group": str(ad.get("group", "")),
		"leader": leader(a), "trend": trend(a), "agenda": {"text": str(ad.get("agenda", "")), "source": _src(ad.get("agenda_source", []))},
		"status": st, "status_label": str(STATUS_LABEL.get(st, st)), "since": SimDB.date_label(int(e.get("since", 1))),
		"phase": phase_view(a), "timeline": tl,
		"relation": snappedf(rel, 0.1), "relation_level": relation_level(rel), "causes": causes(a),
		"exposure": {"value": snappedf(exposure(a), 0.1), "risks": risks},
		"deals": deals_for(a), "history": hist.slice(maxi(0, hist.size() - 12)),
		"trade_partner": a in sim.trade_partners(),
		"delegation": {"ready": S().turn - int(e.get("last_delegation", -99)) >= 8 and str(e.get("status", "")) != "war",
			"cost": int(round(25.0 * (1.0 + 2.0 * sim.progress_fraction()))), "relation": 8}}


const ART_ACTOR := {"us": "usa", "pa": "palestinian_authority", "germany": "west_germany", "russia": "ussr"}
static var _art := {}


func leader(a: String) -> Dictionary:
	## The actor's leader at this date, from art-2d's portraits (data/art_manifest.json): {id, name, portrait} or {}.
	if _art.is_empty():
		_art = {"_": true}
		var p := "res://data/art_manifest.json"
		if FileAccess.file_exists(p):
			var m = JSON.parse_string(FileAccess.get_file_as_string(p))
			if typeof(m) == TYPE_DICTIONARY:
				var ps = m.get("portraits", {})
				if typeof(ps) == TYPE_DICTIONARY:
					for k in ps:
						var v: Dictionary = ps[k]
						var act := str(ART_ACTOR.get(str(v.get("actor", "")), v.get("actor", "")))
						if act == "" or act == "israel": continue
						if not _art.has(act): _art[act] = []
						_art[act].append({"id": str(k), "name": str(v.get("name", "")), "portrait": str(v.get("file_small", v.get("file", ""))),
							"from": int(v.get("era_from", 0)), "to": int(v.get("era_to", 9999))})
	var y := SimDB.year_of(S().turn)
	var best := {}
	for l in _art.get(a, []):
		if int(l["from"]) <= y and y <= int(l["to"]):
			if best.is_empty() or int(l["from"]) > int(best["from"]): best = l
	if best.is_empty(): return {}
	return {"id": best["id"], "name": best["name"], "title": "", "portrait": best["portrait"]}


func get_relations() -> Array:
	## The shape ui-v3 asked for (INTEGRATION_REQUESTS v3 item 7): actors in their era with relation, causes, leader, deals.
	var out := []
	for r in decorate(sim.events.get_diplomacy()):
		var a := str(r["id"])
		if not r.get("active", true): continue
		var st := str(r.get("status", ""))
		var act := []
		var listed := {}
		for x in D()["log"]:
			if str(x.get("actor", "")) == a and str(x.get("kind", "")) == "deal" and not listed.has(str(x.get("deal", ""))):
				listed[str(x.get("deal", ""))] = true   # v3 fix4-diplo: each deal's running terms once, however often it was made
				var dl := deal_def(str(x.get("deal", "")))
				for s2 in S().streams:
					if str(s2.get("src", "")) == "dip:" + str(x.get("deal", "")) and int(s2.get("until", 0)) >= S().turn:
						act.append(active_term(dl, s2))
		r["trend"] = trend(a)
		r["causes"] = causes(a)
		r["leader"] = leader(a)
		r["deals"] = deals_for(a)
		r["active_terms"] = act
		r["war"] = st == "war"
		out.append(r)
	return out


func active_term(dl: Dictionary, s2: Dictionary) -> Dictionary:
	## v3 fix4-diplo (M-A): a deal's running term as shown. A term that runs past the game's last quarter (Q3 2023)
	## reads "to the end of the game" and never shows a later quarter.
	var u := int(s2.get("until", 0))
	var to_end := u >= SimDB.shown_until()
	return {"label": "%s: %s" % [dl.get("title", ""), s2.get("label", "")], "until": "the end of the game" if to_end else SimDB.date_label(u),
		"until_turn": mini(u, SimDB.shown_until()), "to_end": to_end}


func phase_view(a: String) -> Dictionary:
	## v3 fix4-diplo (M-B): the historical phase as the screens show it. Should the legal status of this game no
	## longer fit the phase (a counterfactual path), the label also gives the status today.
	var p := phase(a)
	if p.is_empty():
		return p
	var q: Dictionary = p.duplicate()
	var st := str(S().diplomacy.get(a, {}).get("status", ""))
	if st != "" and not (st in PHASE_OK.get(str(p.get("kind", "")), [st])):
		q["label"] = "%s (today: %s)" % [str(p.get("label", "")), str(STATUS_LABEL.get(st, st)).to_lower()]
		q["status_differs"] = true
	return q


func get_screen() -> Dictionary:
	## The diplomacy screen: actors in their era (grouped), the open envoy, recent dealings.
	var rows: Array = decorate(sim.events.get_diplomacy()).filter(func(r): return r.get("active", true))
	var order: Array = data().get("order", [])
	rows.sort_custom(func(x, y): return order.find(str(x["id"])) < order.find(str(y["id"])) if order.has(str(x["id"])) and order.has(str(y["id"])) else str(x["id"]) < str(y["id"]))
	var lg: Array = D()["log"]
	return {"date": SimDB.date_label(S().turn), "actors": rows, "pending": decision(), "log": lg.slice(maxi(0, lg.size() - 20)),
		"groups": data().get("groups", []), "deals_taken": D()["counts"].duplicate(), "levels": LEVELS.map(func(l): return {"below": l[0], "id": l[1], "label": l[2]})}


func ledger() -> Array:
	## Diplomatic decisions in the path ledger shape (Sim.get_path_ledger appends them, kind "diplomacy").
	var out := []
	for key in D()["envoys"]:
		var oid := str(D()["envoys"][key])
		if oid == "skipped": continue
		var d := envoy_def(key)
		var kind := "envoy"
		var opts := []
		if d.is_empty():
			d = deal_def(key); kind = "offer"
			if d.is_empty(): continue
			opts = _deal_offer_options(d)
		else:
			opts = d.get("options", [])
		var labels := {}
		var hist := ""
		for o in opts:
			labels[str(o["id"])] = str(o.get("label", o["id"]))
			if o.get("historical", false): hist = str(o["id"])
		var terms := S().streams.filter(func(s): return str(s.get("src", "")) == "dip:" + key).map(func(s): return sim.forks.term_text(s, true))
		out.append({"id": "dip:" + key, "kind": "diplomacy", "title": _decision_title(kind, d), "chosen": oid, "chosen_label": labels.get(oid, oid),
			"historical": hist, "historical_label": labels.get(hist, ""), "matched_history": oid == hist, "terms": terms,
			"turn": int(S().milestones.get("dip:%s:%s" % [key, oid], 0)), "actor": str(d.get("actor", ""))})
	out.sort_custom(func(x, y): return int(x["turn"]) < int(y["turn"]))
	return out


# ================================================================== validation (sim_test --validate-only)

static func validate(db) -> Array:
	## Data errors in diplomacy.json: unknown actors/events/forks, missing sources, options without advocate + cite,
	## cites without url + verbatim quote, deleted content.
	var errs := []
	var dd := data()
	if dd.get("actors", {}).is_empty():
		errs.append("diplomacy.json: missing or empty")
		return errs
	var ids := {}
	for s in db.sources:
		ids[str(s)] = true
	var deleted: Dictionary = db.deleted_ids
	var chk_src := func(where: String, src) -> void:
		for s in (src if typeof(src) == TYPE_ARRAY else [src]):
			if not db.sources.has(str(s)):
				errs.append("%s: unknown source %s" % [where, s])
	var chk_cite := func(where: String, cites) -> void:
		if typeof(cites) != TYPE_ARRAY or cites.is_empty():
			errs.append("%s: needs a cite (url + verbatim quote)" % where)
			return
		for c in cites:
			if str(c.get("url", "")) == "" or str(c.get("quote", "")).strip_edges().length() < 12:
				errs.append("%s: a cite needs a url and a verbatim quote" % where)
			if not db.sources.has(str(c.get("source", ""))):
				errs.append("%s: cite source %s is not a known S-id" % [where, c.get("source", "")])
	for a in dd["actors"]:
		if not db.actors.has(str(a)):
			errs.append("diplomacy.json actor %s is not in actors.json" % a)
		for p in dd["actors"][a].get("timeline", []):
			if not (str(p.get("kind", "")) in PHASE_KINDS):
				errs.append("diplomacy.json %s timeline: unknown kind %s" % [a, p.get("kind", "")])
			if p.has("from_event") and not db.event_by_id.has(str(p["from_event"])):
				errs.append("diplomacy.json %s timeline: unknown event %s" % [a, p["from_event"]])
			if not p.has("from_event"):
				if _src_static(p.get("source", [])).is_empty():
					errs.append("diplomacy.json %s timeline %s: needs a source" % [a, p.get("from", "")])
				chk_src.call("diplomacy.json %s timeline" % a, p.get("source", []))
	for dl in dd.get("deals", []):
		var w := "deal %s" % dl.get("id", "")
		if not db.actors.has(str(dl.get("actor", ""))): errs.append(w + ": unknown actor")
		if not (str(dl.get("kind", "")) in KIND_LABEL): errs.append(w + ": unknown kind %s" % dl.get("kind", ""))
		chk_src.call(w, dl.get("source", []))
		chk_cite.call(w, dl.get("cite", []))
		if not dl.get("historical", true) and str(dl.get("advocate", "")) == "":
			errs.append(w + ": a non-historical deal needs a named advocate")
		var ofs := [dl.get("offer", {})]
		for e in dl.get("offer_eras", []):
			ofs.append(e)
			if SimDB.turn_of(e.get("from"), -1) < 1 or SimDB.turn_of(e.get("until"), -1) < 1: errs.append(w + ": an offer era needs from/until dates")
			if str(e.get("title", "")) == "" or str(e.get("text", "")) == "": errs.append(w + ": an offer era needs a title and a text")
			if e.has("accept_cite"): chk_cite.call(w + " offer era accept", e["accept_cite"])
		for of in ofs:
			for k in ["terms", "decline", "delay"]:
				if of.has(k):
					var o: Dictionary = of[k]
					if not o.get("historical", false):
						if str(o.get("advocate", "")) == "": errs.append("%s offer.%s: needs a named advocate" % [w, k])
						chk_cite.call("%s offer.%s" % [w, k], o.get("cite", []))
		errs.append_array(_check_terms_static(w, dl.get("lasting", [])))
	for ev in dd.get("envoys", []):
		var w2 := "envoy %s" % ev.get("id", "")
		if not db.actors.has(str(ev.get("actor", ""))): errs.append(w2 + ": unknown actor")
		if SimDB.turn_of(ev.get("date"), -1) < 1: errs.append(w2 + ": bad date")
		chk_src.call(w2, ev.get("source", []))
		var nh := 0
		for o in ev.get("options", []):
			if o.get("historical", false): nh += 1
			else:
				if str(o.get("advocate", "")) == "": errs.append("%s option %s: needs a named advocate" % [w2, o.get("id", "")])
				chk_cite.call("%s option %s" % [w2, o.get("id", "")], o.get("cite", []))
			if o.has("deal") and not dd["_deals"].has(str(o["deal"])): errs.append("%s option %s: unknown deal" % [w2, o.get("id", "")])
		if nh != 1: errs.append(w2 + ": needs exactly one historical option (has %d)" % nh)
		var sfl = ev.get("subject_fork", [])
		for sf in (sfl if typeof(sfl) == TYPE_ARRAY else [sfl]):
			if not db.forks.has(str(sf)): errs.append("%s: subject_fork %s is not a fork" % [w2, sf])
		if ev.get("options", []).size() < 2: errs.append(w2 + ": needs at least two options")
	for r in dd.get("event_relations", []):
		if not db.event_by_id.has(str(r.get("event", ""))): errs.append("event_relations: unknown event %s" % r.get("event", ""))
		if not db.actors.has(str(r.get("actor", ""))): errs.append("event_relations: unknown actor %s" % r.get("actor", ""))
		if r.has("source"): chk_src.call("event_relations %s" % r.get("event", ""), r["source"])
	for r in dd.get("fork_relations", []):
		if not db.forks.has(str(r.get("fork", ""))): errs.append("fork_relations: unknown fork %s" % r.get("fork", ""))
		if not db.actors.has(str(r.get("actor", ""))): errs.append("fork_relations: unknown actor %s" % r.get("actor", ""))
	for dr in dd.get("dated_relations", []):
		var w4 := "dated_relations %s" % dr.get("id", "")
		if SimDB.turn_of(dr.get("date"), -1) < 1: errs.append(w4 + ": bad date")
		for x in dr.get("actors", {}):
			if not db.actors.has(str(x)): errs.append(w4 + ": unknown actor %s" % x)
		if _src_static(dr.get("source", [])).is_empty(): errs.append(w4 + ": needs a source")
		chk_src.call(w4, dr.get("source", []))
	for lv in dd.get("leverage", []):
		var w3 := "leverage %s" % lv.get("id", "")
		if lv.has("event") and not db.event_by_id.has(str(lv["event"])): errs.append(w3 + ": unknown event")
		if not lv.has("event") and SimDB.turn_of(lv.get("date"), -1) < 1: errs.append(w3 + ": needs an event or a date")
		chk_src.call(w3, lv.get("source", []))
		if _src_static(lv.get("source", [])).is_empty(): errs.append(w3 + ": needs a source")
	# the deleted subject never returns
	var blob := JSON.stringify(dd).to_lower()
	for did in deleted:
		if blob.contains(str(did).to_lower()):
			errs.append("diplomacy.json references deleted event %s" % did)
	for word in ["october 7", "7 october 2023", "oct. 7", "gaza war"]:
		if blob.contains(word):
			errs.append("diplomacy.json mentions deleted content (\"%s\")" % word)
	return errs


static func _check_terms_static(where: String, terms) -> Array:
	var errs := []
	if typeof(terms) != TYPE_ARRAY:
		return [where + ": \"lasting\" must be a list"]
	for i in range(terms.size()):
		var s = terms[i]
		if typeof(s) != TYPE_DICTIONARY or not (str(s.get("type", "")) in SimDB.TERM_TYPES):
			errs.append("%s lasting[%d]: unknown term type" % [where, i])
			continue
		if float(s.get("amount", 0)) == 0.0: errs.append("%s lasting[%d]: amount must be non-zero" % [where, i])
		if str(s.get("label", "")).strip_edges() == "": errs.append("%s lasting[%d]: needs a label" % [where, i])
		if not s.has("years") and (SimDB.turn_of(s.get("from"), -1) < 0 or SimDB.turn_of(s.get("until"), -1) < 0):
			errs.append("%s lasting[%d]: needs \"years\" or \"from\"/\"until\" dates" % [where, i])
	return errs


static func _src_static(x) -> Array:
	if typeof(x) == TYPE_ARRAY: return x
	if typeof(x) == TYPE_STRING and str(x) != "": return [x]
	return []


static func _abs_static(lasting: Array) -> Array:
	var out := []
	for s in lasting:
		var q: Dictionary = s.duplicate()
		if q.has("years"):
			q["from"] = "1950-01"; q["until"] = "%d-12" % (1950 + maxi(0, int(ceil(float(q["years"]))) - 1))
			q.erase("years"); q.erase("delay")
		out.append(q)
	return out
