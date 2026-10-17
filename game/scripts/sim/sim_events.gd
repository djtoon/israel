class_name SimEvents
extends RefCounted
## Dated history (events.json), government terms, city-status rails, diplomacy and the Cabinet Agenda.
##
## Effect semantics for events.json:
##  - Rail keys always come from the event's base effects: diplo, territory, city_status, found_city,
##    aliyah, population, displacement, casualties, hostages, prisoners_released, unlock_tech, unlock_civic.
##  - Numeric "free track" keys (morale, intl_standing, gold, gold_per_turn, production, science, culture)
##    come from the base effects when the event has no choices, otherwise from the chosen option only.
##  - Negative effects are scaled by lasting national state: Readiness softens war costs, Standing softens
##    diplomatic losses, Civic Trust softens morale shocks. This is how the player's build shows in crises.

const RAIL_KEYS := ["diplo", "territory", "city_status", "found_city", "aliyah", "population", "displacement", "casualties",
	"hostages", "prisoners_released", "unlock_tech", "unlock_civic"]
const WAR_KINDS := ["war", "military_operation", "security", "terrorism"]
const DEDICATIONS := [
	{"id": "ingathering", "name": "Ingathering", "goal": "+1 Era Score for each 25,000 immigrants housed without transit camps.", "golden": "+5% immigrant retention."},
	{"id": "pioneering", "name": "Pioneering", "goal": "+2 Era Score per town founded; +1 per district in the periphery.", "golden": "+2 Production in towns of 6 population or less."},
	{"id": "innovation", "name": "Innovation", "goal": "+1 Era Score per Eureka and Inspiration.", "golden": "+10% Science."},
	{"id": "statecraft", "name": "Statecraft", "goal": "+1 Era Score per delegation, export route or agreement.", "golden": "+0.1 Standing per turn."},
]

func dedications() -> Array:
	## The dedication menu with era wording: "transit camps" (ma'abarot) only while they existed (v2 fixes B7).
	var out := []
	var yf := SimDB.year_f(S().turn)
	for d in DEDICATIONS:
		var e: Dictionary = d.duplicate()
		if str(e["id"]) == "ingathering" and yf >= 1965.0:
			e["goal"] = "+1 Era Score for each 25,000 immigrants housed without temporary housing (caravan sites or overcrowded flats)." if yf >= 1989.0 and yf < 1997.0 else "+1 Era Score for each 25,000 immigrants housed in permanent homes."
		out.append(e)
	return out


var sim
var _found_by_city := {}
var _agenda_cooldown := {}


func _init(s) -> void:
	sim = s


func S() -> GameState:
	return sim.state


func found_event_for(city_key: String):
	if _found_by_city.is_empty():
		for ev in sim.db.events:
			for k in ev["effects"].get("found_city", []):
				if not _found_by_city.has(str(k)):
					_found_by_city[str(k)] = ev
		_found_by_city["__built"] = true
	return _found_by_city.get(city_key)


# ------------------------------------------------------------------ government and rails

func current_term() -> Dictionary:
	var terms: Array = sim.db.gov.get("terms", [])
	if S().gov_term >= 0 and S().gov_term < terms.size():
		var t: Dictionary = terms[S().gov_term].duplicate()
		t["type_info"] = sim.db.gov.get("types", {}).get(t.get("type", ""), {})
		return t
	return {}


func apply_government(initial: bool) -> void:
	var terms: Array = sim.db.gov.get("terms", [])
	var idx := -1
	for i in range(terms.size()):
		if SimDB.turn_of(terms[i].get("start"), 1) <= S().turn:
			idx = i
	if idx < 0 and terms.size() > 0:
		idx = 0
	if idx == S().gov_term:
		return
	var prev_type := ""
	if S().gov_term >= 0 and S().gov_term < terms.size():
		prev_type = str(terms[S().gov_term].get("type", ""))
	S().gov_term = idx
	S().free_swap = true
	recompute_slots()
	if not initial:
		S().counters["policy_review"] = S().turn
		sim.cabinet.on_new_government()
	if not initial and idx >= 0:
		var t: Dictionary = terms[idx]
		var tname := str(sim.db.gov.get("types", {}).get(t.get("type", ""), {}).get("name", t.get("type", "")))
		sim.notify("government", "New government: %s (%s). Policy slots updated; cards can be changed for free this turn." % [t.get("pm", ""), tname], {"term": idx})


func recompute_slots() -> void:
	var term := current_term()
	var counts: Dictionary = term.get("type_info", {}).get("slots", {"military": 1, "economic": 1, "diplomatic": 0, "wildcard": 1}).duplicate()
	var bonus: Dictionary = sim.db.gov.get("era_bonus_slots", {})
	for e in bonus:
		if S().era >= int(e):
			counts[bonus[e]] = int(counts.get(bonus[e], 0)) + 1
	for c in sim.active_cities():
		for b in c.buildings:
			var ps = sim.db.buildings.get(b, {}).get("policy_slot")
			if ps != null: counts[ps] = int(counts.get(ps, 0)) + 1
	for pid in S().projects:
		for e in sim.db.projects.get(pid, {}).get("effects", []):
			if e.get("type") == "policy_slot": counts[e["slot"]] = int(counts.get(e["slot"], 0)) + 1
	var old: Array = S().policies.map(func(p): return p.get("id", ""))
	var slots := []
	for t in ["military", "economic", "diplomatic", "wildcard"]:
		for i in range(int(counts.get(t, 0))):
			slots.append({"slot": t, "id": ""})
	# keep cards that still fit
	for pid in old:
		if pid == "" or sim.policy_available(pid) != "":
			continue
		var ptype := str(sim.db.policies[pid]["slot"])
		for s in slots:
			if s["id"] == "" and s["slot"] == ptype:
				s["id"] = pid; break
	for pid in old:
		if pid == "" or sim.policy_available(pid) != "" or slots.any(func(s): return s["id"] == pid):
			continue
		for s in slots:
			if s["id"] == "" and s["slot"] == "wildcard":
				s["id"] = pid; break
	S().policies = slots


func apply_rails(initial: bool) -> void:
	var st := S()
	# dated city names
	for c in st.cities:
		var e = sim.db.city_by_id.get(c.key)
		if e != null:
			var nm: String = sim.city_name_at(c.key, str(e.get("name", c.key)))
			if nm != c.name:
				if not initial: sim.notify("city_renamed", "%s is now %s." % [c.name, nm], {"city": c.id})
				c.name = nm
	# capital
	for rl in sim.db.gov.get("rails", []):
		if rl.get("action") == "set_capital" and SimDB.turn_of(rl.get("date"), 1) <= st.turn:
			if sim.city_by_key(str(rl.get("city"))) != null:
				st.capital = str(rl["city"])
	# a fork answer can keep the government where it was (v2 fixes: the UN regime for Jerusalem, 1949)
	var cap_keep: String = sim.forks.capital_override()
	if cap_keep != "" and sim.city_by_key(cap_keep) != null and st.capital != cap_keep:
		st.capital = cap_keep
	# rail civics (fixed-date institutions) arrive by their historical year even if the event data changes
	for cv in sim.db.civic_list:
		if cv.get("rail", false) and not st.civics.has(cv["id"]) and not st.flags.has("blocked_civic:" + str(cv["id"])) and cv.get("year") != null and st.turn >= SimDB.turn_of(str(int(cv["year"]) + 1) + "-01", 99999):
			sim.complete_civic(cv["id"], "history")
	if initial:
		apply_territory_rails(true)


func rails_held() -> String:
	## Outcome rails (lines of control, city status, foundings) wait while this quarter's decision is open, so a
	## question is never asked after its answer is already on the map (critics 1948-85: 1956, 1967, 1973, 1982).
	var st := S()
	if not st.pending_forks.is_empty(): return "fork"
	if not st.pending_events.is_empty(): return "event"
	if not st.crisis_decision.is_empty() and not st.crisis_decision.get("done", false): return "crisis"
	return ""


func apply_territory_rails(initial: bool, force := false) -> void:
	## Lines of control, city joins/evacuations and dated foundings. Called once the quarter's forks, event
	## choices and war decisions are resolved (and at the end of the turn as a fallback).
	var st := S()
	if not initial and not force and rails_held() != "":
		st.counters["rails_held"] = st.turn
		return
	st.counters.erase("rails_held")
	# foundings an event announced while a related fork was still open
	var deferred: Array = st.counters.get("deferred_foundings", [])
	for k in deferred.duplicate():
		if not sim.forks.city_held(str(k)):
			deferred.erase(k)
			var entry = sim.db.city_by_id.get(str(k))
			if entry != null and sim.city_by_key(str(k)) == null:
				sim.found_city(entry, "history")
	st.counters["deferred_foundings"] = deferred
	# border era
	var be: String = sim.db.border_era_at(st.turn)
	if str(st.counters.get("border_era", "")) != be:
		var first := not st.counters.has("border_era")
		st.counters["border_era"] = be
		sim.econ.border_cache_era = ""
		if not first:
			var lost: Array = sim.econ.release_outside_border()
			var label := be
			for e in sim.db.border_eras:
				if str(e.get("id")) == be: label = str(e.get("label", be))
			if lost.size() > 0:
				sim.notify("territory", "Lines of control changed: %s. %d tiles left Israeli control." % [label, lost.size()])
			else:
				sim.notify("territory", "Lines of control changed: %s." % label)
			sim.territory_changed.emit()
	# city status timelines (cities.json): joining, evacuation, rails foundings
	for e in sim.db.cities:
		var key := str(e["id"])
		var c = sim.city_by_key(key)
		var stt: String = sim.db.city_status_at(e, st.turn)
		if c != null:
			if c.active and (stt in Sim.EVACUATED or (stt != "" and not (stt in Sim.PLAYER_STATUSES))):
				sim.deactivate_city(c, "status changed to " + stt.replace("_", " "))
			elif c.active:
				if c.status != stt:
					# a city whose municipal area absorbed a populated area (East Jerusalem, 28 June 1967)
					var j = sim.db.real.get("city_joins", {}).get(key)
					if typeof(j) == TYPE_DICTIONARY and str(j.get("to_status", "")) == stt:
						c.residents += float(j.get("residents", 0))
						sim.notify("city_changed", "%s: %d residents of the annexed area become residents of the city." % [c.name, int(j.get("residents", 0))], {"city": c.id})
				c.status = stt
			continue
		if not sim._entry_active_at(e, st.turn):
			continue
		if sim.forks.city_held(key):
			continue
		var existing: bool = sim._entry_existing_at(e, 1)
		if existing:
			if not initial:
				var nc = sim.found_city(e, "history", -1.0, true)
				sim.notify("city_joined", "%s comes under Israeli administration (%s)." % [nc.name, stt.replace("_", " ")], {"city": nc.id})
			continue
		# new localities: player may found them early; history founds them on (or soon after) the real date
		var ht: int = sim.hist_turn_of(e)
		var grace := 4
		var kind := str(e.get("kind", ""))
		if kind.begins_with("settlement") or kind.begins_with("bedouin") or found_event_for(key) != null:
			grace = 0
		if st.mode == "historical":
			grace = 0
		if st.turn >= ht + grace:
			sim.found_city(e, "history" if grace == 0 else "rails")


# ------------------------------------------------------------------ events

func fire_turn_events() -> void:
	## Fires this quarter's events in date order. After each one, forks that it unlocks are offered; while a
	## fork is pending the remaining events wait, so a decision is always asked before its outcome is shown
	## (e.g. the May 1967 waiting period before the June war). SimForks.choose resumes the queue.
	var st := S()
	for ev in sim.db.events_by_turn.get(st.turn, []):
		if st.fired_events.has(ev["id"]):
			continue
		if not st.pending_forks.is_empty() or sim.military.decision_open():
			# a fork or a war/crisis decision is open: the quarter's later events wait for it (v2: front orders
			# come before the ceasefire and other outcome headlines of the same quarter)
			st.counters["events_held"] = st.turn
			return
		fire(ev)
		sim.forks.offer_due()
	st.counters.erase("events_held")


func events_held() -> bool:
	return int(S().counters.get("events_held", -1)) == S().turn


func consequence_for(ev: Dictionary) -> Dictionary:
	## The event's "consequences" entry that matches the player's earlier answers ({} = history as written).
	## Entry: {"if": {"<fork or event id>": "<option>" | [...]}, "mode": "skip" | "course", "note": text,
	##         "keep": [rail keys kept when skipped], "numeric": bool (course: keep the numeric effects), "crisis": bool}
	for c in ev.get("consequences", []):
		if typeof(c) == TYPE_DICTIONARY and sim.forks.choice_matches(c.get("if", {})):
			return c
	return {}


func _cons_fork(cons: Dictionary) -> String:
	for src in cons.get("if", {}):
		if sim.db.forks.has(str(src)): return str(src)
	return ""


func _apply_course(ev: Dictionary, cons: Dictionary) -> void:
	## v3 fix3-story (A1): a changed outcome carries its own terms. Keys (all optional): "effects" (event-style numeric
	## effects: morale, intl_standing, gold, gold_per_turn, production, science, culture), "now" (fork-style now:
	## gold, standing, trust, readiness, cohesion, inflation), "lasting" (fork-style lasting terms), "relations"
	## ({actor: amount}, remembered causes on the diplomacy screen) and "flags".
	var st := S()
	var reason := "%s (in your Israel)" % str(ev.get("title", ev["id"]))
	if typeof(cons.get("effects")) == TYPE_DICTIONARY and not cons["effects"].is_empty():
		apply_numeric(cons["effects"], ev)
	if typeof(cons.get("now")) == TYPE_DICTIONARY and not cons["now"].is_empty():
		sim.forks.apply_now(cons["now"], reason)
	if typeof(cons.get("lasting")) == TYPE_ARRAY and not cons["lasting"].is_empty():
		sim.forks.add_terms(cons["lasting"], str(ev["id"]), reason)
	var rel = cons.get("relations", {})
	if typeof(rel) == TYPE_DICTIONARY:
		for a in rel:
			sim.diplo.add_mod(str(a), float(rel[a]), str(cons.get("relation_label", reason)), "event", ev.get("source", []))
	for fl in cons.get("flags", []):
		st.flags[str(fl)] = st.turn
	st.counters["consequences_applied"] = int(st.counters.get("consequences_applied", 0)) + 1


func _cons_note(ev: Dictionary, cons: Dictionary, skipped: bool) -> String:
	var note := str(cons.get("note", ""))
	if note != "":
		return note
	S().counters["generic_notes"] = int(S().counters.get("generic_notes", 0)) + 1
	var fid := _cons_fork(cons)
	var lab: String = sim.forks.choice_label(fid, sim.forks._choice_of(fid)) if fid != "" else "your earlier choice"
	if skipped:
		return "Because of your cabinet's choice, \"%s\", this does not happen in your Israel: %s (%s in history)." % [lab, ev.get("title", ev["id"]), ev.get("date", "")]
	return "History took its course: %s (%s). Your cabinet's choice, \"%s\", changes how it lands: its effects follow your choice, not history." % [ev.get("title", ev["id"]), ev.get("date", ""), lab]


func _fire_skipped(ev: Dictionary, cons: Dictionary) -> void:
	## A dated event that a fork answer cancelled (v2 fixes: Osirak postponed, the Jerusalem capital under a UN
	## regime, no Oslo channel...). It counts as fired (chains anchored on it still work) but nothing of it applies,
	## except rails the data keeps ("keep").
	var st := S()
	st.fired_events[ev["id"]] = st.turn
	st.flags["event_skipped:" + str(ev["id"])] = st.turn
	var note := _cons_note(ev, cons, true)
	st.event_log.append({"turn": st.turn, "id": ev["id"], "title": ev.get("title", ""), "kind": ev.get("kind", ""), "date": ev.get("date", ""),
		"skipped": true, "consequence": note, "history_course": note})
	var keep: Array = cons.get("keep", [])
	var eff: Dictionary = ev["effects"]
	if keep.has("diplo") and typeof(eff.get("diplo")) == TYPE_DICTIONARY:
		for a in eff["diplo"]:
			set_status(str(a), str(eff["diplo"][a]))
	if keep.has("found_city"):
		for k in eff.get("found_city", []):
			var entry = sim.db.city_by_id.get(str(k))
			if entry != null and sim.city_by_key(str(k)) == null:
				sim.found_city(entry, "history")
	for cv in eff.get("unlock_civic", []):
		if not keep.has("unlock_civic"):
			st.flags["blocked_civic:" + str(cv)] = st.turn
	_apply_course(ev, cons)   # v3 fix3-story: a skipped event may still carry a cost of its own ("now", "lasting", ...)
	sim.notify("consequence", note, {"event": ev["id"], "fork": _cons_fork(cons), "skipped": true, "title": ev.get("title", "")})


func fire(ev: Dictionary) -> void:
	var st := S()
	var cons := consequence_for(ev)
	var mode := str(cons.get("mode", ""))
	if mode == "skip":
		_fire_skipped(ev, cons)
		return
	st.fired_events[ev["id"]] = st.turn
	var eff: Dictionary = _apply_blocks(ev)
	var fork_id: String = sim.forks.fork_replacing(str(ev["id"]))
	# an event whose effects wait for a fork of the same quarter (data "defer_to_fork"; v2 fixes B3: austerity)
	var dfork := str(ev.get("defer_to_fork", ""))
	if dfork != "" and (not sim.db.forks.has(dfork) or st.fork_choices.has(dfork) or st.flags.has("fork_skipped:" + dfork)):
		dfork = ""
	if mode == "course":
		fork_id = fork_id if fork_id != "" else _cons_fork(cons)
	var has_choices: bool = not ev["choices"].is_empty() and fork_id == "" and mode == "" and dfork == ""
	st.event_log.append({"turn": st.turn, "id": ev["id"], "title": ev.get("title", ""), "kind": ev.get("kind", ""), "date": ev.get("date", "")})
	# rails (a war with its own file sets its enemies to war now; the event's ceasefire statuses land once the
	# quarter's front orders are given, so the diplomacy panel reads "war" while the fronts are open)
	var war_file: bool = sim.db.war_by_event.has(str(ev["id"]))
	var dip = eff.get("diplo", {})
	if mode == "course" and typeof(cons.get("diplo")) == TYPE_DICTIONARY:
		# v3 fix3-story (A3): a changed outcome may leave a status where it was ("") or set another one
		dip = dip.duplicate() if typeof(dip) == TYPE_DICTIONARY else {}
		for a in cons["diplo"]:
			if str(cons["diplo"][a]) == "": dip.erase(a)
			else: dip[a] = str(cons["diplo"][a])
		st.counters["diplo_override:" + str(ev["id"])] = dip
	if typeof(dip) == TYPE_DICTIONARY:
		for a in dip:
			if war_file and str(dip[a]) != "war" and sim.military.war_actor(str(ev["id"]), str(a)):
				continue
			set_status(str(a), str(dip[a]))
	for k in eff.get("found_city", []):
		var entry = sim.db.city_by_id.get(str(k))
		if entry != null and sim.city_by_key(str(k)) == null:
			if sim.forks.city_held(str(k)):
				var df: Array = st.counters.get("deferred_foundings", [])
				if not df.has(str(k)): df.append(str(k))
				st.counters["deferred_foundings"] = df
			else:
				sim.found_city(entry, "history")
	var pop = eff.get("population", {})
	if typeof(pop) == TYPE_DICTIONARY:
		for k in pop:
			var c = sim.city_by_key(str(k))
			if c != null and c.active:
				var n := float(pop[k])
				if n < 0:
					var moved := minf(-n, c.residents * 0.8)
					c.residents -= moved
					c.displaced += moved
					st.displaced.append({"city": c.id, "n": moved, "until": maxi(int(ev["_end_turn"]), st.turn + 2)})
				else:
					c.residents += n
	_ledger(ev)
	for t in eff.get("unlock_tech", []):
		if sim.db.techs.has(str(t)) and not st.techs.has(str(t)):
			sim.boost("tech", str(t), 0.5, "History: " + str(ev.get("title", "")), false)
	var keep_numeric: bool = mode != "course" or bool(cons.get("numeric", false))
	if mode == "course" and not bool(cons.get("civics", false)):
		for cv in eff.get("unlock_civic", []):
			st.flags["blocked_civic:" + str(cv)] = st.turn
	elif dfork != "":
		pass   # civics wait for the fork (on_fork_chosen)
	elif fork_id != "":
		# the question is asked once, as the cabinet fork; the civic history attached to it still arrives, unless
		# the cabinet's answer rules it out (SimForks.CIVIC_FOLLOWS)
		for ch in ev["choices"]:
			if ch.get("historical", false):
				for cv in ch.get("effects", {}).get("unlock_civic", []):
					if sim.db.civics.has(str(cv)) and not st.flags.has("blocked_civic:" + str(cv)): sim.complete_civic(str(cv), "history")
	# civics of an event with choices arrive only with the choice that carries them (never before the pick)
	if not has_choices and fork_id == "" and dfork == "" and mode == "":
		for cv in eff.get("unlock_civic", []):
			# a civic that some event choice grants (e.g. Mamlachtiyut via the Altalena choice) waits for that choice
			if sim.db.civics.has(str(cv)) and not sim.db.choice_civics.has(str(cv)) and not st.flags.has("blocked_civic:" + str(cv)):
				sim.complete_civic(str(cv), "history")
	if ev.get("kind") in ["election"]:
		st.free_swap = true   # the policy review opens when the new government forms (fix-cabinet, V2_FIXES A6)
	# crises: every war with a war file; other "war" events only if Israeli towns are in it or a party is at war
	# with Israel (not e.g. Black September 1970 or the 2007 Hamas-Fatah fighting); one-off operations abroad
	var dip_war: bool = typeof(dip) == TYPE_DICTIONARY and dip.values().has("war")
	var kind := str(ev.get("kind", ""))
	var crisis_ok: bool = mode != "course" or bool(cons.get("crisis", true))
	if crisis_ok and war_file:
		sim.military.start_crisis(ev)
	elif crisis_ok and kind == "war" and (dip_war or _has_player_city(ev)):
		sim.military.start_crisis(ev)
	elif crisis_ok and kind == "military_operation" and dip_war:
		sim.military.start_crisis(ev)
	_history_course(ev, fork_id, cons)
	if mode == "course":
		_apply_course(ev, cons)
	# numeric effects
	if dfork != "":
		var de: Dictionary = st.counters.get("deferred_events", {})
		de[dfork] = str(ev["id"])
		st.counters["deferred_events"] = de
	elif fork_id != "" and mode == "":
		pass   # the fork's options carry the consequences of this decision
	elif not keep_numeric:
		pass   # a changed outcome: the cabinet's answer carries the consequences (its lasting terms)
	elif war_file and crisis_ok and sim.military.defers_numeric(str(ev["id"])):
		pass   # an operation with named options: its effects land with the option chosen (SimMilitary.choose_response)
	elif not has_choices:
		var applied := apply_numeric(eff, ev)
		if eff.size() < ev["effects"].size():
			var names := {"gold_per_turn": "the gold stream", "gold": "the gold", "production": "the production", "intl_standing": "the standing change",
				"morale": "the morale change", "science": "the science", "culture": "the culture", "diplo": "the diplomatic change"}
			var missing: Array = ev["effects"].keys().filter(func(k): return not eff.has(k)).map(func(k): return str(names.get(k, str(k).replace("_", " "))))
			sim.notify("terms", "%s: on your terms, without %s." % [ev.get("title", ev["id"]), ", ".join(missing)], {"event": ev["id"], "applied": applied})
	else:
		st.pending_events.append(ev["id"])
	sim.notify("event", str(ev.get("title", ev["id"])), {"event": ev["id"], "kind": ev.get("kind", ""), "has_choice": has_choices, "fork": fork_id,
		"awaits_fork": dfork})
	sim.event_fired.emit(ev["id"])


func on_fork_chosen(fid: String, oid: String) -> void:
	## A fork of this quarter has been answered: an event that waited for it (data "defer_to_fork") applies its
	## effects and civics now, or its changed outcome when the answer matches one of its "consequences".
	var st := S()
	var de: Dictionary = st.counters.get("deferred_events", {})
	if not de.has(fid):
		return
	var ev = sim.db.event_by_id.get(str(de[fid]))
	de.erase(fid)
	st.counters["deferred_events"] = de
	if ev == null:
		return
	var cons := consequence_for(ev)
	if not cons.is_empty():
		for cv in ev["effects"].get("unlock_civic", []):
			st.flags["blocked_civic:" + str(cv)] = st.turn
		var note := _cons_note(ev, cons, str(cons.get("mode", "")) == "skip")
		for le in st.event_log:
			if le["id"] == ev["id"]:
				le["history_course"] = note
				le["consequence"] = note
		sim.notify("consequence", note, {"event": ev["id"], "fork": fid, "chosen": oid})
		_apply_course(ev, cons)
		if str(cons.get("mode", "")) == "course" and bool(cons.get("numeric", false)):
			apply_numeric(_apply_blocks(ev), ev)
		return
	apply_numeric(_apply_blocks(ev), ev)
	for cv in ev["effects"].get("unlock_civic", []):
		if sim.db.civics.has(str(cv)) and not st.flags.has("blocked_civic:" + str(cv)):
			sim.complete_civic(str(cv), "history")


func _has_player_city(ev: Dictionary) -> bool:
	for pl in ev.get("places", []):
		var c = sim.city_by_key(str(pl))
		if c != null and c.active:
			return true
	return false


func _history_course(ev: Dictionary, fork_id: String, cons := {}) -> void:
	## When the player answered a question differently from history but the rail still happens, say so plainly
	## (a matching "consequences" entry gives its own note: what changed and what still follows history).
	var st := S()
	var linked := []
	if fork_id != "":
		linked.append(fork_id)
	for fid in sim.forks.history_course_forks(str(ev["id"])):
		if not linked.has(fid): linked.append(fid)
	var cfork := _cons_fork(cons)
	if not cons.is_empty():
		var note := _cons_note(ev, cons, false)
		sim.notify("history_course", note, {"event": ev["id"], "fork": cfork, "chosen": sim.forks._choice_of(cfork), "consequence": true})
		st.event_log[st.event_log.size() - 1]["history_course"] = note
		st.event_log[st.event_log.size() - 1]["consequence"] = note
	for fid in linked:
		if not st.fork_choices.has(fid) or fid == cfork:
			continue
		var chosen := str(st.fork_choices[fid])
		var hist: String = sim.forks.historical_option(fid)
		if hist == "" or chosen == hist:
			continue
		# v3 fix3-story (A1): a second matching consequence entry, or the war's own variant, says what changed
		var second := _cons_for_fork(ev, fid)
		if not second.is_empty():
			var n2 := _cons_note(ev, second, false)
			sim.notify("history_course", n2, {"event": ev["id"], "fork": fid, "chosen": chosen, "consequence": true})
			if not st.event_log[st.event_log.size() - 1].has("history_course"):
				st.event_log[st.event_log.size() - 1]["history_course"] = n2
				st.event_log[st.event_log.size() - 1]["consequence"] = n2
			continue
		if _war_variant_for(str(ev["id"]), fid):
			if not st.event_log[st.event_log.size() - 1].has("history_course"):
				st.event_log[st.event_log.size() - 1]["consequence"] = "war variant"
				st.event_log[st.event_log.size() - 1]["history_course"] = "The war's orders follow your cabinet's answer."
			continue
		var lab: String = sim.forks.choice_label(fid, chosen)
		var txt := "History took its course: %s (%s). Your cabinet's choice, \"%s\", does not change this event; its lasting terms still apply." % [ev.get("title", ev["id"]), ev.get("date", ""), lab]
		st.counters["generic_notes"] = int(st.counters.get("generic_notes", 0)) + 1
		sim.notify("history_course", txt, {"event": ev["id"], "fork": fid, "chosen": chosen, "generic": true})
		if not st.event_log[st.event_log.size() - 1].has("history_course"):
			st.event_log[st.event_log.size() - 1]["history_course"] = txt


func _cons_for_fork(ev: Dictionary, fid: String) -> Dictionary:
	## The event's first "consequences" entry that names this fork and matches its answer ({} if none).
	for c in ev.get("consequences", []):
		if typeof(c) == TYPE_DICTIONARY and c.get("if", {}).has(fid) and sim.forks.choice_matches(c.get("if", {})):
			return c
	return {}


func _war_variant_for(eid: String, fid: String) -> bool:
	## True when the war of this event has a variant for the fork's answer (its note explains the change).
	var w = sim.db.war_by_event.get(eid)
	if typeof(w) != TYPE_DICTIONARY:
		return false
	for v in w.get("variants", []):
		if v.get("if_choice", {}).has(fid) and sim.forks.choice_matches(v.get("if_choice", {})):
			return true
	return false


func _ledger(ev: Dictionary) -> void:
	## Humanitarian record for every side, as given by the sourced event (shown in reports, not scored).
	var eff: Dictionary = ev["effects"]
	var cas = eff.get("casualties", {})
	if typeof(cas) == TYPE_DICTIONARY:
		for side in cas:
			var k = cas[side].get("killed") if typeof(cas[side]) == TYPE_DICTIONARY else null
			if typeof(k) == TYPE_ARRAY and k.size() == 2:
				var h: Dictionary = S().humanitarian.get(side, {"killed_low": 0, "killed_high": 0, "displaced_low": 0, "displaced_high": 0})
				h["killed_low"] = float(h["killed_low"]) + float(k[0]); h["killed_high"] = float(h["killed_high"]) + float(k[1])
				S().humanitarian[side] = h
				if str(side).find("israel") >= 0:
					S().war_weariness += float(k[0]) / 4.0 * war_scale()
	var dis = eff.get("displacement", [])
	if typeof(dis) == TYPE_ARRAY:
		for d in dis:
			if typeof(d) != TYPE_DICTIONARY: continue
			var g := str(d.get("group", "unknown"))
			var h2: Dictionary = S().humanitarian.get(g, {"killed_low": 0, "killed_high": 0, "displaced_low": 0, "displaced_high": 0})
			h2["displaced_low"] = float(h2["displaced_low"]) + float(d.get("low", 0)); h2["displaced_high"] = float(h2["displaced_high"]) + float(d.get("high", 0))
			S().humanitarian[g] = h2


func war_scale() -> float:
	## Higher Readiness lowers the cost of fixed-outcome wars.
	return clampf(1.4 - S().readiness / 100.0, 0.6, 1.3)


func standing_scale() -> float:
	return clampf(1.3 - S().standing / 100.0, 0.6, 1.2)


func trust_scale() -> float:
	return clampf(1.4 - sim.score.avg_trust() / 100.0, 0.7, 1.2)


func gold_scale() -> float:
	## Scale for gold amounts in events, forks, the agenda and war costs: the larger of the era scale and the
	## size of the state budget (average gross income per quarter / 45, the 1949 budget), so costs keep their bite.
	var era_s := 1.0 + 0.3 * (S().era - 1)
	var inc := float(S().counters.get("income_avg", 120.0))
	return clampf(maxf(era_s, inc / 120.0), 1.0, 10.0)


func apply_numeric(eff: Dictionary, ev: Dictionary, choice := {}) -> Dictionary:
	## Applies free-track numeric effects; returns what was actually applied (for the UI and logs).
	var st := S()
	var applied := {}
	var warlike: bool = ev.get("kind", "") in WAR_KINDS
	var m := float(eff.get("morale", 0))
	if m != 0:
		if m < 0:
			m *= trust_scale() * (war_scale() if warlike else 1.0)
		if warlike and m > 0:
			m *= 0.5
		for c in sim.active_cities():
			c.trust = clampf(c.trust + m, 0.0, 100.0)
		if not choice.is_empty():
			sim.add_trust_player(m)
		sim.stat_note("trust", m, str(ev.get("title", ev.get("id", "event"))))
		if m > 0:
			st.cohesion += 1.5 * m
			sim.stat_note("cohesion", 1.5 * m, str(ev.get("title", ev.get("id", "event"))))
		applied["trust"] = m
	var s := float(eff.get("intl_standing", 0))
	if s != 0:
		if s < 0:
			s *= standing_scale()
			for te in st.temp_effects:
				if te.get("type") == "standing_shield" and int(te.get("until", 0)) >= st.turn:
					s *= 0.5
					break
		applied["standing"] = sim._change_standing(s, str(ev.get("title", ev.get("id", "event"))), not choice.is_empty())
	var g := float(eff.get("gold", 0))
	if g != 0:
		g *= gold_scale()
		if g < 0 and warlike:
			g *= war_scale()
		st.gold += g
		applied["gold"] = g
	var gpt := float(eff.get("gold_per_turn", 0))
	if gpt != 0:
		gpt *= gold_scale()
		if gpt < 0 and warlike:
			gpt *= war_scale()
		var until := int(ev.get("_end_turn", -1))
		if until < st.turn:
			until = st.turn + 16
		st.gold_mods.append({"amount": gpt, "until": until, "src": ev.get("id", "")})
		applied["gold_per_turn"] = gpt
	var p := float(eff.get("production", 0))
	if p != 0:
		var cap = sim.city_by_key(st.capital)
		var target = cap
		for c in sim.active_cities():
			if not c.queue.is_empty() and (target == null or c.pop() > target.pop()) and c.queue[0]["kind"] != "city_project":
				target = c
		if target != null and not target.queue.is_empty():
			var pk := str(target.queue[0]["kind"]) + ":" + str(target.queue[0]["id"])
			target.progress[pk] = maxf(0.0, float(target.progress.get(pk, 0.0)) + p * gold_scale())
		applied["production"] = p * gold_scale()
	var sci := float(eff.get("science", 0))
	if sci != 0 and st.current_tech != "":
		st.tech_progress[st.current_tech] = maxf(0.0, float(st.tech_progress.get(st.current_tech, 0.0)) + sci * gold_scale())
		applied["science"] = sci * gold_scale()
	var cul := float(eff.get("culture", 0))
	if cul != 0:
		if st.current_civic != "":
			st.civic_progress[st.current_civic] = maxf(0.0, float(st.civic_progress.get(st.current_civic, 0.0)) + cul * gold_scale())
		sim._change_standing(cul / 60.0, str(ev.get("title", ev.get("id", "event"))) + " (culture)")
		applied["culture"] = cul * gold_scale()
	for cv in choice.get("unlock_civic", []):
		if sim.db.civics.has(str(cv)):
			sim.complete_civic(str(cv), "choice")
	return applied


func choice_view(ev: Dictionary) -> Array:
	var out := []
	var i := 0
	for ch in ev.get("choices", []):
		out.append({"index": i, "label": ch.get("label", ""), "effects": _numeric_only(ch.get("effects", {})), "effects_text": effects_text(_numeric_only(ch.get("effects", {}))),
			"effects_struct": effects_struct(_numeric_only(ch.get("effects", {})), str(ev["id"]), i), "note": ch.get("note", ""),
			"historical": ch.get("historical", false), "source": ch.get("source", ev.get("source", [])),
			"terms": terms_text(ev, i)})
		i += 1
	return out


# ------------------------------------------------------------------ choice terms (data/choice_terms.json)

func _choice_terms(ev_id: String, idx: int) -> Dictionary:
	var e = sim.db.choice_terms.get(ev_id)
	if typeof(e) != TYPE_DICTIONARY: return {}
	var cs: Array = e.get("choices", [])
	return cs[idx] if idx >= 0 and idx < cs.size() and typeof(cs[idx]) == TYPE_DICTIONARY else {}


func _stream_text(s: Dictionary) -> String:
	var a := float(s.get("amount", 0))
	var y0 := str(s.get("from", "")).substr(0, 4); var y1 := str(s.get("until", "")).substr(0, 4)
	var ey := SimDB.end_year()   # v3 fix3-story A11: no year after the game's end in a span
	if y1.is_valid_int() and int(y1) > ey: y1 = str(ey)
	var span := y0 if y0 == y1 else "%s-%s" % [y0, y1]
	match str(s.get("type")):
		"gold": return "%+d Gold per turn %s (%s)" % [int(round(a * gold_scale())), span, s.get("label", "")]
		"standing": return "%+.1f Standing per turn %s (%s)" % [a, span, s.get("label", "")]
		"trust": return "%+.2f Trust per turn in every city %s (%s)" % [a, span, s.get("label", "")]
		"readiness": return "%+d Readiness %s (%s)" % [int(a), span, s.get("label", "")]
	return str(s.get("label", ""))


func terms_text(ev: Dictionary, idx: int) -> Array:
	## Lasting consequences of a choice, shown on the choice before the pick and in "Your path" after it.
	var out := []
	var t := _choice_terms(str(ev["id"]), idx)
	for s in SimForks.shown_terms(t.get("streams", [])):
		out.append(_stream_text(s))
	for evid in t.get("blocks", {}).get("events", {}):
		var be = sim.db.event_by_id.get(evid)
		out.append("Later: %s happens without its %s" % [be.get("title", evid) if be != null else evid, ", ".join(t["blocks"]["events"][evid]).replace("_", " ")])
	for cv in _civics_lost(ev, idx) + Array(t.get("blocks", {}).get("civics", [])):
		out.append("Civic %s will not be adopted" % sim.db.civics.get(cv, {}).get("name", cv))
	return out


func _civics_lost(ev: Dictionary, idx: int) -> Array:
	## Civics offered by the other choices of this event but not by this one.
	var chosen: Array = ev["choices"][idx].get("effects", {}).get("unlock_civic", [])
	var lost := []
	for j in range(ev["choices"].size()):
		if j == idx: continue
		for cv in ev["choices"][j].get("effects", {}).get("unlock_civic", []):
			if not (cv in chosen) and not (cv in lost) and not S().civics.has(cv): lost.append(cv)
	return lost


func apply_choice_terms(ev: Dictionary, idx: int) -> Array:
	var st := S()
	var t := _choice_terms(str(ev["id"]), idx)
	for s in t.get("streams", []):
		var a := float(s.get("amount", 0))
		if str(s.get("type")) == "gold": a *= gold_scale()
		st.streams.append({"type": s.get("type"), "amount": a, "from": maxi(st.turn, SimDB.turn_of(s.get("from"), st.turn)),
			"until": SimDB.turn_of(s.get("until"), st.turn + 16), "label": s.get("label", ""), "src": ev["id"]})
	for fl in t.get("flags", []):
		st.flags[str(fl)] = st.turn
	for evid in t.get("blocks", {}).get("events", {}):
		st.flags["block:" + str(evid)] = t["blocks"]["events"][evid]
	for cv in _civics_lost(ev, idx) + Array(t.get("blocks", {}).get("civics", [])):
		st.flags["blocked_civic:" + str(cv)] = st.turn
	return terms_text(ev, idx)


func _apply_blocks(ev: Dictionary) -> Dictionary:
	## The event's effects minus what an earlier choice removed (the event itself still happens).
	var blk = S().flags.get("block:" + str(ev["id"]))
	if typeof(blk) != TYPE_ARRAY:
		return ev["effects"]
	var eff: Dictionary = ev["effects"].duplicate()
	for k in blk:
		eff.erase(str(k))
	return eff


func effects_text(eff: Dictionary) -> Array:
	## Player-facing lines for an effects dictionary (scaled as they will apply).
	var gs := gold_scale()
	var out := []
	var names := {"morale": "Civic Trust", "intl_standing": "Standing", "gold": "Gold", "production": "Production", "science": "Science", "culture": "Culture"}
	for k in eff:
		var v = eff[k]
		if typeof(v) != TYPE_INT and typeof(v) != TYPE_FLOAT:
			continue
		var a := float(v)
		if k in ["gold", "production", "science", "culture"]:
			a *= gs
		if k == "gold_per_turn":
			out.append("%+d Gold per turn for a few years" % int(round(a * gs)))
		elif names.has(k):
			out.append("%s %+d" % [names[k], int(round(a))])
	return out


func effects_struct(eff: Dictionary, ev_id := "", idx := -1) -> Array:
	## Structured effects of an event choice (UI request 18): [{stat, amount, unit, when, good}], scaled as they apply,
	## plus the choice's lasting terms (choice_terms.json) with from/until.
	var gs := gold_scale()
	var out := []
	var stat := {"morale": "trust", "intl_standing": "standing", "gold": "gold", "production": "production", "science": "science", "culture": "culture"}
	for k in eff:
		var v = eff[k]
		if typeof(v) != TYPE_INT and typeof(v) != TYPE_FLOAT:
			continue
		var a := float(v)
		if k in ["gold", "production", "science", "culture", "gold_per_turn"]:
			a *= gs
		if k == "gold_per_turn":
			out.append({"stat": "gold", "amount": snappedf(a, 0.01), "unit": "per turn", "when": "for a few years", "good": a > 0.0})
		elif stat.has(k):
			out.append({"stat": stat[k], "amount": snappedf(a, 0.01), "unit": "points", "when": "now", "good": a > 0.0})
	if ev_id != "":
		for s in _choice_terms(ev_id, idx).get("streams", []):
			var a2 := float(s.get("amount", 0))
			if str(s.get("type")) == "gold": a2 *= gs
			out.append({"stat": str(s.get("type", "")), "amount": snappedf(a2, 0.01), "unit": "per turn" if str(s.get("type")) in ["gold", "standing", "trust"] else "level",
				"when": "%s-%s" % [str(s.get("from", "")).substr(0, 4), str(s.get("until", "")).substr(0, 4)], "label": str(s.get("label", "")), "good": a2 > 0.0})
	return out


func agenda_struct(fx: Dictionary) -> Array:
	## Structured effects of a Cabinet Agenda option: [{stat, amount, unit, when, good}].
	var out := []
	var turns := int(fx.get("turns", 4))
	for k in fx:
		var v = fx[k]
		match k:
			"gold": out.append({"stat": "gold", "amount": snappedf(float(v), 0.01), "unit": "points", "when": "now", "good": float(v) > 0.0})
			"borrow": out.append({"stat": "gold", "amount": snappedf(float(v), 0.01), "unit": "points, borrowed (public debt repaid with interest over 15 years)", "when": "now", "good": true})
			"inflation": out.append({"stat": "inflation", "amount": float(v), "unit": "percentage points", "when": "lasting", "good": float(v) < 0.0})
			"readiness": out.append({"stat": "readiness", "amount": float(v), "unit": "points", "when": "now", "good": float(v) > 0.0})
			"standing": out.append({"stat": "standing", "amount": float(v), "unit": "points", "when": "now", "good": float(v) > 0.0})
			"cohesion": out.append({"stat": "cohesion", "amount": float(v), "unit": "points", "when": "now", "good": float(v) > 0.0})
			"trust_all": out.append({"stat": "trust", "amount": float(v), "unit": "points in every city", "when": "now", "good": float(v) > 0.0})
			"trust_city": out.append({"stat": "trust", "amount": float(v), "unit": "points in the city", "when": "now", "good": float(v) > 0.0})
			"amenity_all": out.append({"stat": "amenity", "amount": float(v), "unit": "in every city", "when": "4 turns", "good": float(v) > 0.0})
			"housing_city": out.append({"stat": "housing", "amount": float(v), "unit": "in the city", "when": "lasting", "good": true})
			"reserve": out.append({"stat": "water", "amount": float(v), "unit": "reserve points", "when": "now", "good": float(v) > 0.0})
			"immigrant_weight_city": out.append({"stat": "population", "amount": float(v), "unit": "% of arrivals to the city", "when": "8 turns"})
			"budget_focus": out.append({"stat": str(v), "amount": 10.0, "unit": "%", "when": "4 turns", "good": true})
			"temp":
				var t: Dictionary = v
				var amt := float(t.get("pct", t.get("amount", 0)))
				var st2 := str(t.get("yield", t.get("type", "")))
				var good := amt > 0.0
				if str(t.get("type", "")) == "water_demand_pct": good = amt < 0.0
				out.append({"stat": st2, "type": str(t.get("type", "")), "amount": amt, "unit": "%" if t.has("pct") else "points", "when": "%d turns" % turns, "good": good})
	return out


func _numeric_only(eff: Dictionary) -> Dictionary:
	var out := {}
	for k in eff:
		if not (k in RAIL_KEYS) or k == "unlock_civic":
			out[k] = eff[k]
	return out


func historical_choice(ev: Dictionary) -> int:
	var i := 0
	for ch in ev.get("choices", []):
		if ch.get("historical", false):
			return i
		i += 1
	return 0


func choose(event_id: String, idx: int) -> bool:
	if not (event_id in S().pending_events):
		return false
	var ev = sim.db.event_by_id.get(event_id)
	if ev == null or idx < 0 or idx >= ev["choices"].size():
		return false
	var ch: Dictionary = ev["choices"][idx]
	var eff: Dictionary = _numeric_only(ch.get("effects", {}))
	var applied := apply_numeric(eff, ev, eff)
	S().pending_events.erase(event_id)
	S().choices_made[event_id] = idx
	var terms := apply_choice_terms(ev, idx)
	var hist := historical_choice(ev)
	for le in S().event_log:
		if le["id"] == event_id:
			le["choice"] = idx
	var hist_ch: Dictionary = ev["choices"][hist]
	sim.notify("what_happened", "What actually happened: %s %s" % [hist_ch.get("label", ""), ("- " + str(hist_ch.get("note", ""))) if hist_ch.get("note", "") != "" else ""],
		{"event": event_id, "chosen": idx, "historical": hist, "applied": applied, "terms": terms})
	if not terms.is_empty():
		sim.notify("terms", "Your path: " + "; ".join(terms), {"event": event_id})
	if idx != hist:
		S().counters["counterfactual_choices"] = int(S().counters.get("counterfactual_choices", 0)) + 1
	sim.refresh()
	return true


func auto_resolve_pending() -> void:
	for eid in S().pending_events.duplicate():
		var ev = sim.db.event_by_id.get(eid)
		if ev != null:
			choose(eid, historical_choice(ev))


func directed_immigration() -> Array:
	var out := []
	for eid in S().fired_events:
		var ev = sim.db.event_by_id.get(eid)
		if ev == null or not ev["effects"].has("aliyah"):
			continue
		var t0: int = ev["_turn"]
		var t1: int = maxi(int(ev["_end_turn"]), t0)
		if S().turn < t0 or S().turn > t1:
			continue
		var qn := float(t1 - t0 + 1)
		var cities := []
		for pl in ev.get("places", []):
			var c = sim.city_by_key(str(pl))
			if c != null and c.active:
				cities.append(c)
		if cities.size() > 0:
			out.append({"cities": cities, "amount": float(ev["effects"]["aliyah"]) / qn * 0.5, "event": eid})
	return out


# ------------------------------------------------------------------ diplomacy

func set_status(actor: String, status: String) -> void:
	var d = S().diplomacy.get(actor)
	if d == null:
		d = {"status": "none", "relation": 0.0, "since": S().turn, "last_delegation": -99}
		S().diplomacy[actor] = d
	if d["status"] == status:
		return
	var base := float(sim.db.actor_meta.get("status_relation", {}).get(status, 0))
	# a quarrel with a state Israel has relations with (e.g. France's 1968 arms embargo, Turkey 2010) lowers
	# the relation; it does not break off relations
	if status == "hostile" and str(d["status"]) in ["relations_established", "peace", "normalized"]:
		d["relation"] = float(d.get("relation", 0.0)) - 30.0
		sim.diplomacy_changed.emit(actor, str(d["status"]))
		return
	var rail := rail_status(actor)
	if rail != "" and not (status in ["war", "ceasefire"]):
		d["relation"] = lerpf(float(d.get("relation", 0.0)), base, 0.4)
		return
	d["status"] = status
	d["since"] = S().turn
	d["relation"] = lerpf(float(d.get("relation", 0.0)), base, 0.6)
	if status in ["peace", "normalized"]:
		sim.add_moment("Agreement with %s: %s" % [sim.db.actors.get(actor, {}).get("name", actor), status], 3, "treaty")
	sim.diplomacy_changed.emit(actor, status)


func rail_status(actor: String) -> String:
	## A legal status that holds over a period whatever single incidents say (actors.json status_rails, each
	## anchored on dated, sourced events): e.g. the 1949 armistice regimes until June 1967.
	for r in sim.db.actor_meta.get("status_rails", []):
		if str(r.get("actor", "")) != actor:
			continue
		# v3 fix3-story (A3): a rail anchored on an event your cabinet's answer cancelled, or ruled out by a flag, does not hold
		if str(r.get("from_event", "")) != "" and S().flags.has("event_skipped:" + str(r["from_event"])):
			continue
		if r.has("unless_flag") and S().flags.has(str(r["unless_flag"])):
			continue
		var t0 := _rail_turn(r, "from")
		var t1 := _rail_turn(r, "to")
		if t0 <= S().turn and S().turn < t1:
			return str(r.get("status", ""))
	return ""


func _rail_turn(r: Dictionary, k: String) -> int:
	var ev = sim.db.event_by_id.get(str(r.get(k + "_event", "")))
	if ev != null:
		return int(ev["_turn"])
	return SimDB.turn_of(r.get(k), 99999 if k == "to" else -99999)


func apply_status_rails() -> void:
	## Called each turn: actors not in an active war crisis sit at their railed status.
	## (v2 fixes B6) An actor counts as in a war only while one of its fronts is still open (Syria's fronts in 1982
	## close with the ceasefire of 11 June, so its ceasefire rail applies from the next quarter). The relation
	## value follows a railed status (USSR 1967-91 "severed" no longer reads +50).
	var in_crisis := {}
	for cr in S().crises:
		if cr.get("active", true):
			for a in sim.military.crisis_live_actors(cr):
				in_crisis[str(a)] = true
	for a in S().diplomacy:
		if in_crisis.has(a):
			continue
		var rs := rail_status(a)
		var d: Dictionary = S().diplomacy[a]
		if rs != "" and str(d["status"]) != rs:
			d["status"] = rs
			d["since"] = S().turn
			sim.diplomacy_changed.emit(a, rs)
		if rs != "":
			# the relation stays within 20 points of what the railed status means (delegations still move it)
			var base := float(sim.db.actor_meta.get("status_relation", {}).get(rs, 0))
			var rel := float(d.get("relation", 0.0))
			if rel > base + 20.0: d["relation"] = lerpf(rel, base + 20.0, 0.35)
			elif rel < base - 20.0: d["relation"] = lerpf(rel, base - 20.0, 0.35)


func actor_visible(a: String) -> bool:
	var meta: Dictionary = sim.db.actors.get(a, {})
	if meta.has("exists_from_event"):
		var ev = sim.db.event_by_id.get(str(meta["exists_from_event"]))
		if ev != null and S().turn < int(ev["_turn"]):
			return false
	if meta.has("exists_from") and S().turn < SimDB.turn_of(meta["exists_from"], 0):
		return false
	return true


func actor_name(a: String) -> String:
	var meta: Dictionary = sim.db.actors.get(a, {"name": a})
	var nm := str(meta.get("name", a))
	for n in meta.get("names", []):
		var ev = sim.db.event_by_id.get(str(n.get("from_event", "")))
		var t := int(ev["_turn"]) if ev != null else SimDB.turn_of(n.get("from"), 99999)
		if S().turn >= t:
			nm = str(n.get("name", nm))
	return nm


func get_diplomacy() -> Array:
	var out := []
	for a in S().diplomacy:
		if not actor_visible(a):
			continue
		var d: Dictionary = S().diplomacy[a]
		var meta: Dictionary = sim.db.actors.get(a, {"name": a}).duplicate()
		meta["name"] = actor_name(a)
		out.append({"id": a, "name": meta.get("name", a), "kind": meta.get("kind", ""), "status": d["status"], "relation": d["relation"],
			"since": SimDB.date_label(int(d.get("since", 1))), "trade_partner": a in sim.trade_partners(),
			"delegation_ready": S().turn - int(d.get("last_delegation", -99)) >= 8})
	return out


# ------------------------------------------------------------------ cabinet agenda (guarantees a meaningful decision every turn)

func generate_agenda() -> void:
	var st := S()
	st.agenda = {}
	# pressing items (budget, inflation, housing, water, readiness, standing) come up alongside other
	# decisions; the routine budget-emphasis item only when nothing else needs the cabinet
	var others: Array = sim.blocking_decisions().filter(func(d): return d["type"] != "agenda" and d["type"] != "diplomacy")   # v3: an envoy never displaces the agenda
	var cands := []
	var worst = null; var worst_share := 0.0
	var recent_h: Dictionary = st.counters.get("housing_agenda_cities", {})
	for c in sim.active_cities():
		var sh: float = c.info.get("transit_share", 0.0)
		if st.turn - int(recent_h.get(str(c.id), -99)) < 16:
			continue   # the same town's housing shortage comes back at most once in four years
		if sh > worst_share:
			worst_share = sh; worst = c
	var sc := gold_scale()
	var yf := SimDB.year_f(st.turn)
	var net := float(st.counters.get("last_budget", {}).get("net", 0.0))
	var flush := st.gold >= 120.0 * sc and net >= 0.0   # the treasury can pay for a capital programme
	if worst != null and worst_share >= 0.05:
		var big_city: bool = worst.residents >= 80000.0 and not sim.econ.is_periphery(worst)
		if yf < 1965.0:
			var popts := [
				{"label": "Emergency prefab construction", "fx": {"gold": -45 * sc, "housing_city": 2, "city": worst.id}, "default": false},
				{"label": "Open a transit camp (ma'abara)", "fx": {"building": "maabara", "city": worst.id}, "default": false},
				{"label": "Steer new arrivals to other towns", "fx": {"immigrant_weight_city": -60, "city": worst.id, "trust_city": -3}, "default": false}]
			# (fix-recpick) the advice follows the town: prefabs when the treasury can pay, a camp for a mass
			# emergency in a town without one, steering arrivals away from a crowded city
			_recommend("housing", popts, [1.0 + (0.9 if flush else -0.6),
				0.4 + worst_share * 8.0 - (2.5 if worst.has_building("maabara") else 0.0),
				0.6 + (1.0 if big_city else 0.0)])
			cands.append({"id": "housing", "severity": worst_share * 10.0, "title": "Housing shortage in " + worst.name,
				"text": "%d residents of %s live in transit camps." % [int(worst.info.get("transit", 0)), worst.name],
				"options": popts})
		else:
			var hopts := [
				{"label": "Public housing tender (state land, fast-track permits)", "fx": {"gold": -45 * sc, "housing_city": 2, "city": worst.id}, "default": true},
				{"label": "Rent support for young couples and new immigrants", "fx": {"gold": -25 * sc, "trust_city": 3, "city": worst.id, "temp": {"type": "housing_city", "city": worst.id, "amount": 1}, "turns": 8}, "default": false},
				{"label": "Grants for moving to periphery towns", "fx": {"gold": -20 * sc, "immigrant_weight_city": -50, "city": worst.id, "temp": {"type": "immigrant_weight", "target": "small_towns", "pct": 40}, "turns": 8}, "default": false}]
			var hsc := [0.9 + (0.3 if flush else 0.0) + (0.6 if worst_share >= 0.10 else 0.0), 0.9 + (0.5 if not flush else 0.0) + (0.5 if worst_share < 0.09 else 0.0),
				0.7 + (1.0 if big_city else -0.4)]
			if yf >= 1990.0 and yf < 1993.0:
				hopts.append({"label": "Caravan sites for new immigrants", "fx": {"city": worst.id, "trust_city": -2, "temp": {"type": "housing_city", "city": worst.id, "amount": 3}, "turns": 12}, "default": false})
				hsc.append(0.6 + (1.8 if sim.econ.expected_arrivals() > 20000.0 else 0.0))
			# (fix-recpick) tenders when the treasury can pay, rent support when it cannot, periphery grants for a
			# crowded central city, caravans in a mass-arrival year
			_recommend("housing", hopts, hsc)
			cands.append({"id": "housing", "severity": worst_share * 10.0, "title": "Housing shortage in " + worst.name,
				"text": "%d residents of %s live in overcrowded or temporary housing; prices and rents are rising." % [int(worst.info.get("transit", 0)), worst.name],
				"options": hopts})
	if float(st.water.get("ratio", 1.0)) < 1.0:
		cands.append({"id": "water", "severity": (1.0 - float(st.water["ratio"])) * 12.0, "title": "Water deficit",
			"text": "Supply %d vs demand %d (million m3/yr); reserve at %d%%." % [int(st.water["supply"]), int(st.water["demand"]), int(st.water.get("reserve", 0))],
			"options": [
				{"label": "Ration water", "fx": {"temp": {"type": "water_demand_pct", "pct": -12}, "turns": 8, "amenity_all": -1}, "default": false},
				{"label": "Pump the aquifers harder", "fx": {"temp": {"type": "water_supply_pct", "pct": 10}, "turns": 8, "reserve": -15}, "default": false},
				{"label": "Fund water-saving equipment", "fx": {"gold": -60 * sc, "temp": {"type": "water_demand_pct", "pct": -6}, "turns": 20}, "default": false}]})
		# (fix-recpick) pump only while the aquifer reserve can take it; ration in a deep deficit; buy equipment
		# when the treasury can pay and the deficit is lasting
		var wres := float(st.water.get("reserve", 70.0)); var wratio := float(st.water["ratio"])
		_recommend("water", cands[-1]["options"], [0.8 + (1.0 - wratio) * 12.0 - (0.3 if wres >= 50.0 else 0.0),
			0.2 + (wres - 40.0) / 30.0,
			1.0 + (0.9 if flush else -0.3) + (0.5 if int(st.water.get("deficit_turns", 0)) >= 8 else 0.0)])
	if net < 0.0 and not sim.cabinet.budget_due() and not sim.cabinet.review_due():
		# fix-cabinet: the deficit item (raise taxes, cut services, or borrow into the public debt) lives in SimEconomy
		var dcand: Dictionary = sim.econ.deficit_agenda(sc, net)
		if not dcand.is_empty():
			cands.append(dcand)
	if st.inflation > 25:
		cands.append({"id": "inflation", "severity": st.inflation / 30.0, "title": "Inflation at %d%%" % int(st.inflation),
			"text": "Prices are rising quickly; purchases cost more and gold yields fall.",
			"options": [
				{"label": "Wage and price freeze", "fx": {"inflation": -12, "trust_all": -3}, "default": false},
				{"label": "Index wages to prices", "fx": {"inflation": 5, "trust_all": 2}, "default": false}]})
		# (fix-recpick) freeze once inflation is high; index wages while it is moderate
		_recommend("inflation", cands[-1]["options"], [0.6 + (st.inflation - 25.0) / 15.0, 1.4])
	if st.readiness < 30 and _hostile_neighbours() > 0:
		cands.append({"id": "readiness", "severity": (30 - st.readiness) / 10.0, "title": "Low military readiness",
			"text": "Readiness %d. Crises will cost more." % int(st.readiness),
			"options": [
				{"label": "Expand reserve training", "fx": {"gold": -50 * sc, "readiness": 6}, "default": true},
				{"label": "Accept the risk; fund civilian projects", "fx": {"gold": 30 * sc, "readiness": -2}, "default": false}]})
	var plan_in := false
	for p in st.policies:
		if str(p.get("id", "")) == "stabilization_plan": plan_in = true
	if st.inflation > 60.0 and not plan_in:
		var opts2 := [
			{"label": "Another 'package deal' with the Histadrut and employers", "fx": {"inflation": -25, "trust_all": -1, "gold": -20 * sc}, "default": false},
			{"label": "Devalue and cut subsidies", "fx": {"inflation": 10, "gold": 60 * sc, "trust_all": -3}, "default": false},
			{"label": "Let indexation carry on", "fx": {"inflation": 15, "trust_all": 1}, "default": false}]
		# (fix-recpick) a package deal while it can hold; devaluation when the treasury is short; the full
		# stabilization plan once inflation is very high or earlier package deals have failed
		var em_seen := int(st.counters.get("agenda_inflation_emergency", 0))
		# indexation, at no cost in trust, once inflation is already falling from the last emergency (15% or more)
		var em_last := float(st.counters.get("infl_emergency_last", 0.0))
		var esc := [1.5 - minf(0.6, maxf(0.0, st.inflation - 60.0) / 200.0), 0.8 + (1.0 if st.gold < 0.0 else 0.0) + (0.3 if net < 0.0 else 0.0),
			0.3 + (1.3 if em_last > 0.0 and st.inflation < 0.85 * em_last else 0.0)]
		if sim.policy_available("stabilization_plan") == "":
			opts2.push_front({"label": "Adopt the Economic Stabilization Plan (budget cuts, wage freeze, fixed exchange rate)", "fx": {"adopt_policy": "stabilization_plan", "trust_all": -3}, "default": false})
			esc.push_front(0.8 + st.inflation / 150.0 + 0.5 * em_seen)
		_recommend("inflation_emergency", opts2, esc)
		cands.append({"id": "inflation_emergency", "severity": 10.0 + st.inflation / 50.0, "title": "Economic emergency: inflation at %d%%" % int(st.inflation),
			"text": "Prices are rising %d%% a year. Wages are indexed, the budget is in deficit (%+d a quarter), and every purchase costs more." % [int(st.inflation), int(net)],
			"options": opts2})
	var spt := float(st.counters.get("standing_per_turn", 0.0))
	if st.standing < 40.0 or (spt < -0.25 and st.standing < 75.0):
		var low := st.standing < 40.0
		cands.append({"id": "standing", "severity": maxf((40.0 - st.standing) / 8.0, -spt * 4.0),
			"title": ("International standing at %d" % int(st.standing)) if low else "International standing is slipping",
			"text": ("Standing is %d and moving %+.1f a quarter. Low standing makes every crisis cost more." % [int(st.standing), spt]) if low else
				("Standing is %d but falling %.1f a quarter. If the slide continues, crises will cost more." % [int(st.standing), -spt]),
			"options": [
				{"label": "Diplomatic campaign and foreign-aid missions", "fx": {"gold": -40 * sc, "standing": 3}, "default": false},
				{"label": "Cultivate the diaspora and friendly governments", "fx": {"gold": -20 * sc, "standing": 1, "cohesion": 10}, "default": true},
				{"label": "Ignore foreign opinion", "fx": {"trust_all": 1}, "default": false}]})
	# caps (critics 02, 1966-85): each kind at most once every 4 turns (standing and inflation prompts every
	# 8), never the same menu twice in a row, and pressing items yield to forks and event choices unless severe
	var cd_map: Dictionary = st.counters.get("agenda_cd", {})
	var last_id := str(st.counters.get("last_agenda_id", ""))
	var big_other := not st.pending_forks.is_empty() or not st.pending_events.is_empty()
	# pressing items at most once per 8 turns; budget and inflation items share one economic slot (no two related
	# economic menus within 8 turns unless it is the inflation emergency)
	var econ_kinds := ["budget", "inflation", "inflation_emergency"]
	var last_econ := -99
	for k in econ_kinds:
		last_econ = maxi(last_econ, int(cd_map.get(k, -99)))
	# a treasury in debt for a year brings the deficit back every 4 turns (and it may repeat), not every 8
	var debt_cd := 4 if int(st.counters.get("neg_turns", 0)) >= 4 else 8
	cands = cands.filter(func(cd): return st.turn - int(cd_map.get(cd["id"], -99)) >= (debt_cd if cd["id"] == "budget" else 8) and (str(cd["id"]) != last_id or (cd["id"] == "budget" and debt_cd == 4)) \
		and (not (cd["id"] in econ_kinds) or st.turn - last_econ >= (debt_cd if cd["id"] == "budget" else 8) or (cd["id"] == "inflation_emergency" and st.turn - int(cd_map.get("inflation_emergency", -99)) >= 8)) \
		and (not big_other or float(cd["severity"]) >= 5.0))
	var pick = null
	for cd in cands:
		if pick == null or cd["severity"] > pick["severity"]:
			pick = cd
	if pick == null and others.size() > 0:
		return
	if pick == null:
		var pool := routine_agendas(yf, sc).filter(func(cd): return st.turn - int(cd_map.get(cd["id"], -99)) >= 8 and str(cd["id"]) != last_id)
		if not pool.is_empty():
			# rotate: the routine item not seen for the longest time
			pool.sort_custom(func(a, b): return int(cd_map.get(a["id"], -99)) < int(cd_map.get(b["id"], -99)))
			pick = pool[0]
	if pick == null:
		# the other routine menu, so the cabinet never sees the identical menu twice in a row
		var sc2 := gold_scale()
		pick = {"id": "priorities", "severity": 0, "title": "Cabinet priorities this quarter",
			"text": "One initiative gets the ministers' time and money this quarter.",
			"options": [
				{"label": "A diplomatic tour of friendly capitals", "fx": {"gold": -25 * sc2, "standing": 1}, "default": false},
				{"label": "A reserve training exercise", "fx": {"gold": -25 * sc2, "readiness": 2}, "default": true},
				{"label": "Community and volunteering programmes", "fx": {"gold": -20 * sc2, "cohesion": 12}, "default": false},
				{"label": "Bank the money", "fx": {"gold": 15 * sc2}, "default": false}]}
	if pick == null:
		var labels := {"science": "Research and universities", "production": "Infrastructure and industry", "culture": "Culture and social services", "gold": "Treasury reserves"}
		var opts := []
		for y in ["science", "production", "culture", "gold"]:
			opts.append({"label": labels[y], "fx": {"budget_focus": y}, "default": y == "production"})
		pick = {"id": "fiscal", "severity": 0, "title": "Budget emphasis for the coming year",
			"text": "Choose which area gets +10% for the next 4 quarters.", "options": opts}
	cd_map[pick["id"]] = st.turn
	st.counters["agenda_cd"] = cd_map
	if str(pick["id"]) == "housing" and worst != null:
		recent_h[str(worst.id)] = st.turn
		st.counters["housing_agenda_cities"] = recent_h
	st.counters["last_agenda_id"] = pick["id"]
	# (fix-recpick) remember the Recommended answer per item, so the next one does not simply repeat it
	var lr: Dictionary = st.counters.get("agenda_last_rec", {})
	var past: Array = lr.get(str(pick["id"]), [])
	for o in pick.get("options", []):
		if o.get("default", false): past = (past + [str(o["label"])]).slice(-2)
	lr[str(pick["id"])] = past
	st.counters["agenda_last_rec"] = lr
	if str(pick["id"]) == "inflation_emergency":
		st.counters["infl_emergency_last"] = st.inflation
	st.agenda = pick
	st.agenda["done"] = false


func _recommend(kind: String, opts: Array, scores: Array) -> void:
	## Marks the Recommended option of an agenda item: the best fit for the situation (scores, one per option),
	## less 0.9 for the answer Recommended the last time this item came up and 0.5 for the time before.
	var past: Array = S().counters.get("agenda_last_rec", {}).get(kind, [])
	var best := 0; var bv := -1e9
	for i in opts.size():
		var v := float(scores[i]) if i < scores.size() else 0.0
		var lbl := str(opts[i]["label"])
		if past.size() >= 1 and str(past[-1]) == lbl: v -= 0.9
		if past.size() >= 2 and str(past[-2]) == lbl: v -= 0.5
		if v > bv:
			bv = v; best = i
	for i in opts.size():
		opts[i]["default"] = i == best


func routine_agendas(yf: float, sc: float) -> Array:
	## Routine cabinet items by era: each a real trade-off, rotated so the same menu rarely returns.
	var out := []
	# (v2) the yearly defence allocation is part of the State Budget decision (SimCabinet), not an agenda item
	out.append({"id": "reserves", "severity": 0, "title": "Reserve duty",
		"text": "Reservists' employers and the army disagree over how many days of reserve duty a year the economy can bear.",
		"options": [
			{"label": "Longer reserve training", "fx": {"gold": -25 * sc, "readiness": 3, "trust_all": -1}, "default": yf < 1985.0},
			{"label": "Keep the present schedule", "fx": {"readiness": 1, "gold": -10 * sc}, "default": yf >= 1985.0},
			{"label": "Shorten reserve duty", "fx": {"gold": 20 * sc, "readiness": -3, "trust_all": 1}, "default": false}]})
	if yf >= 1953.0:
		out.append({"id": "education", "severity": 0, "title": "Schools and universities",
			"text": "Teachers' unions, universities and the Treasury all want a larger share of the education budget.",
			"options": [
				{"label": "Expand the universities and research grants", "fx": {"gold": -35 * sc, "temp": {"type": "yield_pct", "yield": "science", "pct": 10}, "turns": 8}, "default": yf >= 1960.0},
				{"label": "Vocational schools for the new towns", "fx": {"gold": -30 * sc, "temp": {"type": "yield_pct", "yield": "production", "pct": 6}, "turns": 8}, "default": yf < 1960.0},
				{"label": "Freeze the budget this year", "fx": {"gold": 20 * sc, "trust_all": -1}, "default": false}]})
	if yf >= 1955.0:
		out.append({"id": "periphery", "severity": 0, "title": "Investment in the periphery",
			"text": "Development-town mayors ask for factories and roads; the centre wants its own infrastructure.",
			"options": [
				{"label": "Industrial grants for development towns", "fx": {"gold": -35 * sc, "temp": {"type": "trust", "amount": 1, "cond": {"periphery": true}}, "turns": 8}, "default": yf < 1977.0},
				{"label": "Roads and power for the central region", "fx": {"gold": -35 * sc, "temp": {"type": "yield_pct", "yield": "production", "pct": 6}, "turns": 8}, "default": yf >= 1977.0},
				{"label": "Let the market decide", "fx": {"gold": 15 * sc, "temp": {"type": "trust", "amount": -1, "cond": {"periphery": true}}, "turns": 6}, "default": false}]})
	if yf >= 1950.0:
		out.append({"id": "health", "severity": 0, "title": "Health services",
			"text": "Clinics in the new towns are overcrowded and the sick funds are in deficit.",
			"options": [
				{"label": "Fund clinics and mother-and-child centres", "fx": {"gold": -30 * sc, "temp": {"type": "amenity", "amount": 1}, "turns": 6}, "default": true},
				{"label": "Bail out the sick funds' debts", "fx": {"gold": -20 * sc, "trust_all": 1}, "default": false},
				{"label": "Raise user fees", "fx": {"gold": 20 * sc, "trust_all": -2}, "default": false}]})
	if yf >= 1968.0:
		out.append({"id": "exports", "severity": 0, "title": "Export drive",
			"text": "Exporters ask for help with markets abroad and with the exchange rate.",
			"options": [
				{"label": "Trade missions and export credit", "fx": {"gold": -30 * sc, "temp": {"type": "trade_gold", "amount": 2}, "turns": 12}, "default": true},
				{"label": "Devalue the currency", "fx": {"gold": 30 * sc, "inflation": 4}, "default": false},
				{"label": "No special help", "fx": {"gold": 10 * sc}, "default": false}]})
	if yf >= 1960.0:
		out.append({"id": "transport", "severity": 0, "title": "Transport investment",
			"text": "Roads, rail and ports compete for the development budget.",
			"options": [
				{"label": "Highways and rail between the cities", "fx": {"gold": -45 * sc, "temp": {"type": "yield_pct", "yield": "production", "pct": 5}, "turns": 12}, "default": true},
				{"label": "Ports and the airport (exports and tourism)", "fx": {"gold": -40 * sc, "temp": {"type": "trade_gold", "amount": 2}, "turns": 12}, "default": false},
				{"label": "Postpone", "fx": {"gold": 15 * sc}, "default": false}]})
	if yf >= 1977.0:
		out.append({"id": "welfare", "severity": 0, "title": "Welfare and pensions",
			"text": "National Insurance benefits lag behind prices; the Treasury warns about the deficit.",
			"options": [
				{"label": "Raise benefits", "fx": {"gold": -35 * sc, "trust_all": 2, "inflation": 1}, "default": false},
				{"label": "Target benefits to the poorest", "fx": {"gold": -15 * sc, "temp": {"type": "trust", "amount": 1, "cond": {"periphery": true}}, "turns": 8}, "default": true},
				{"label": "Freeze benefits", "fx": {"gold": 25 * sc, "trust_all": -2}, "default": false}]})
	if yf >= 1995.0:
		out.append({"id": "high_tech", "severity": 0, "title": "High-tech and the workforce",
			"text": "Tech firms report shortages of engineers; other sectors ask for the same support.",
			"options": [
				{"label": "Engineering places at universities and colleges", "fx": {"gold": -35 * sc, "temp": {"type": "yield_pct", "yield": "science", "pct": 8}, "turns": 12}, "default": true},
				{"label": "Tax breaks for multinational R&D centres", "fx": {"gold": -20 * sc, "temp": {"type": "yield_pct", "yield": "gold", "pct": 6}, "turns": 12}, "default": false},
				{"label": "Spread support across all industries", "fx": {"gold": -20 * sc, "temp": {"type": "yield_pct", "yield": "production", "pct": 4}, "turns": 12}, "default": false}]})
	return out


func _hostile_neighbours() -> int:
	var n := 0
	for a in S().diplomacy:
		if str(S().diplomacy[a]["status"]) in ["war", "hostile"]:
			n += 1
	return n


func choose_agenda(i: int) -> bool:
	var st := S()
	if st.agenda.is_empty() or st.agenda.get("done", false):
		return false
	var opts: Array = st.agenda.get("options", [])
	if i < 0 or i >= opts.size():
		return false
	var fx: Dictionary = opts[i].get("fx", {})
	var c = sim.city_by_id(int(fx.get("city", 0)))
	var why := "Cabinet: " + str(opts[i].get("label", ""))
	if fx.has("gold"): st.gold += float(fx["gold"])
	if fx.has("borrow"): sim.econ.borrow(float(fx["borrow"]), why)   # fix-cabinet: a loan into the public debt
	if fx.has("inflation"):
		sim.shift_inflation(float(fx["inflation"]))
		sim.stat_note("inflation", float(fx["inflation"]), why)
	if fx.has("readiness"):
		st.readiness_bonus += float(fx["readiness"])
		sim.stat_note("readiness", float(fx["readiness"]), why)
	if fx.has("standing"): sim._change_standing(float(fx["standing"]), why, true)
	if fx.has("trust_all"): sim.stat_note("trust", float(fx["trust_all"]), why)
	if fx.has("cohesion"): sim.stat_note("cohesion", float(fx["cohesion"]), why)
	if fx.has("adopt_policy"):
		var pid := str(fx["adopt_policy"])
		var slot_i := -1
		for j in range(st.policies.size()):
			if st.policies[j]["slot"] == "economic" and slot_i < 0: slot_i = j
		if slot_i < 0:
			for j in range(st.policies.size()):
				if st.policies[j]["slot"] == "wildcard" and slot_i < 0: slot_i = j
		if slot_i >= 0:
			for p in st.policies:
				if str(p.get("id", "")) == pid: p["id"] = ""
			st.policies[slot_i]["id"] = pid
			sim.refresh()
	if fx.has("cohesion"): st.cohesion += float(fx["cohesion"])
	if fx.has("reserve"): st.water["reserve"] = clampf(float(st.water.get("reserve", 70)) + float(fx["reserve"]), 0, 100)
	if fx.has("rural_capacity"): st.counters["rural_base"] = float(st.counters.get("rural_base", 0)) + float(fx["rural_capacity"])
	if fx.has("budget_focus"): st.budget_focus = {"yield": fx["budget_focus"], "until": st.turn + 3}
	if fx.has("temp"):
		var te: Dictionary = fx["temp"].duplicate()
		te["until"] = st.turn + int(fx.get("turns", 4)); te["src"] = "agenda"
		st.temp_effects.append(te)
	if fx.has("amenity_all"):
		st.temp_effects.append({"type": "amenity", "amount": float(fx["amenity_all"]), "until": st.turn + 4, "src": "agenda"})
	if fx.has("trust_all"):
		for cc in sim.active_cities(): cc.trust = clampf(cc.trust + float(fx["trust_all"]), 0, 100)
	if c != null:
		if fx.has("housing_city"): c.legacy_housing += float(fx["housing_city"])
		if fx.has("building") and not c.has_building(fx["building"]): c.buildings.append(fx["building"])
		if fx.has("trust_city"): c.trust = clampf(c.trust + float(fx["trust_city"]), 0, 100)
		if fx.has("immigrant_weight_city"):
			st.temp_effects.append({"type": "immigrant_weight_city", "city": c.id, "pct": float(fx["immigrant_weight_city"]), "until": st.turn + 8, "src": "agenda"})
	st.agenda["done"] = true
	st.agenda["chosen"] = i
	st.counters["agenda_" + str(st.agenda.get("id", ""))] = int(st.counters.get("agenda_" + str(st.agenda.get("id", "")), 0)) + 1
	sim.refresh()
	return true
