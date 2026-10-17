class_name SimForks
extends RefCounted
## One-time "fork" decisions (game/data/forks/*.json, schema in FORKS.md): real policy debates of their time.
## A fork is offered once, inside its date window, when its conditions hold. Each option writes lasting terms
## (streams) that persist to their end date and move the six VS. HISTORY tracks, so choices add up to an
## Israel that is the player's own. Exactly one option is what the government actually did.

## Forks that ask the same question as an event's choices (critics 1966-85 and 2006-26): the fork is kept and the
## event keeps only its rails. A fork can also say so in data with "replaces_event".
const REPLACES := {"fork_1967_waiting_period": "evt_1967_tiran_crisis", "fork_1967_allon_territories": "evt_1967_allon_plan",
	"fork_1973_no_preemption": "evt_1973_yom_kippur_war", "fork_1975_sebastia": "evt_1975_sebastia", "fork_1978_sinai_settlements": "evt_1978_camp_david",
	"fork_1982_lebanon_scope": "evt_1982_lebanon_war", "fork_1991_gulf_restraint": "evt_1991_gulf_war_scuds", "fork_2000_lebanon": "evt_2000_lebanon_withdrawal",
	"fork_2004_disengagement": "evt_2005_gaza_disengagement", "fork_2011_social_budget": "evt_2011_social_protests", "fork_2018_nation_state_law": "evt_2018_nation_state_law",
	"fork_2020_annexation": "evt_2020_annexation_suspended", "fork_2023_judicial_overhaul": "evt_2023_judicial_overhaul_crisis",
	# v2 fixes B4: duplicate questions (the 1984 rotation, the 1985 security zone, and Yamit, the third Sinai-settlements ask)
	"fork_1984_unity_government": "evt_1984_election_rotation", "fork_1985_lebanon_withdrawal": "evt_1985_security_zone",
	"fork_1979_treaty_ratification": "evt_1982_sinai_withdrawal",
	# v3 fix3-story (A2): the 1952 Knesset debate and the 1957 withdrawal were asked twice in the same quarter
	"fork_1952_reparations_talks": "evt_1952_reparations_debate", "fork_1957_gaza_and_sharm": "evt_1957_sinai_withdrawal"}

## Localities whose founding waits for a fork's decision (the fork asks whether/how to settle there).
## Forks may also list them in data as "holds_cities".
const HOLDS_CITIES := {"fork_1968_hebron": ["kiryat_arba"], "fork_1975_sebastia": ["maale_adumim"]}
## Rails that still happen whatever the player chose at a fork: the event gets a "History took its course" line.
## Forks may also list them in data as "history_course".
const HISTORY_COURSE := {"fork_1993_oslo_channel": ["evt_1994_gaza_jericho", "evt_1995_oslo_ii"],
	"fork_1978_sinai_settlements": ["evt_1982_sinai_withdrawal"],
	"fork_2004_disengagement": ["evt_2005_gaza_disengagement"], "fork_1982_lebanon_scope": ["evt_1982_lebanon_war", "evt_1982_sabra_shatila", "evt_1983_israel_lebanon_agreement"],
	"fork_1973_no_preemption": ["evt_1973_yom_kippur_war"],
	# v2 fixes (full-game critic B2): every same-subject event after a non-historical pick says how history went
	"fork_1956_sevres_collusion": ["evt_1956_sinai_campaign"], "fork_1960_eichmann_venue": ["evt_1961_eichmann_trial"],
	"fork_1965_german_relations": ["evt_1965_west_germany_relations"], "fork_1967_waiting_period": ["evt_1967_six_day_war"],
	"fork_1970_black_september": ["evt_1970_black_september"], "fork_1977_sadat_visit": ["evt_1977_sadat_visit"],
	"fork_1978_litani_belt": ["evt_1978_operation_litani"], "fork_1980_jerusalem_basic_law": ["evt_1980_jerusalem_law"],
	"fork_1997_hebron_protocol": ["evt_1997_hebron_protocol"], "fork_2000_camp_david": ["evt_2000_camp_david"],
	"fork_2002_defensive_shield": ["evt_2002_defensive_shield"], "fork_2002_barrier_route": ["evt_2002_separation_barrier", "evt_2004_icj_barrier"],
	"fork_2006_lebanon_ground": ["evt_2006_second_lebanon_war"], "fork_2022_lebanon_maritime": ["evt_2022_lebanon_maritime_deal"],
	"fork_2019_unity_or_third_election": ["evt_2020_unity_government"], "fork_1969_rogers_plan": ["evt_1970_attrition_ceasefire"],
	"fork_1985_lebanon_withdrawal": ["evt_1985_security_zone"], "fork_1984_unity_government": ["evt_1984_election_rotation"],
	"fork_1979_treaty_ratification": ["evt_1979_egypt_peace_treaty"]}

## Same-subject events the id words do not reveal (sim_test consequence checker): the fork's answer must show in them.
const SUBJECT_EVENTS := {"fork_1976_entebbe": ["evt_1976_operation_thunderbolt"], "fork_1968_hebron": ["evt_1971_kiryat_arba"],
	"fork_1993_oslo_channel": ["evt_1993_oslo_i", "evt_1994_gaza_jericho", "evt_1995_oslo_ii"],
	"fork_1982_lebanon_scope": ["evt_1982_lebanon_war", "evt_1982_sabra_shatila"], "fork_1949_capital": ["evt_1950_jerusalem_capital"],
	"fork_1980_jerusalem_basic_law": ["evt_1980_jerusalem_law"],
	"fork_1978_sinai_settlements": ["evt_1982_sinai_withdrawal"], "fork_1973_no_preemption": ["evt_1973_yom_kippur_war"],
	"fork_1969_rogers_plan": ["evt_1970_attrition_ceasefire"], "fork_1956_sevres_collusion": ["evt_1956_sinai_campaign"],
	"fork_1967_waiting_period": ["evt_1967_six_day_war"]}

## Fork/event pairs that share a word in their ids but are not the same subject (sim_test consequence checker).
const NOT_SAME_SUBJECT := {
	"fork_1949_refugee_return>evt_1950_law_of_return": "Palestinian refugees' return vs the Law of Return for Jewish immigrants",
	"fork_1970_black_september>evt_1971_black_panthers": "Black September 1970 vs the Israeli Black Panthers protests"}

## Forks that answer an event of the same quarter (its cause): offered only once that event has fired, so the
## question follows its context (v2 fixes B4: the first coalition after the 1949 election, and the like).
const AFTER_EVENT := {"fork_1949_first_coalition": "evt_1949_first_knesset_election", "fork_1971_black_panthers": "evt_1971_black_panthers",
	"fork_1972_munich_response": "evt_1972_munich", "fork_2020_covid": "evt_2020_covid_first_case"}

## Civics that follow a fork's answer: an option listed here never gets the civic, even from a rail or a replaced
## event (API: an unchosen option's civic is never adopted). V2 fixes B3 (Austerity) and B4 (1984 rotation).
const CIVIC_FOLLOWS := {"fork_1949_austerity": {"loosen_controls": ["austerity_tzena"]},
	"fork_1984_unity_government": {"narrow_labor": ["emergency_government"]},
	"fork_2004_disengagement": {"stay": ["disengagement"]}}

## Rails that move with the answer (v2 fixes): the capital stays in Tel Aviv if the cabinet accepts the UN regime.
const CAPITAL_FOLLOWS := {"fork_1949_capital": {"accept_un_regime": "tel_aviv"}}

const NOW_KEYS := ["gold", "standing", "trust", "readiness", "cohesion", "inflation", "production", "science", "culture"]
const MAX_NEW_PER_TURN := 1

var sim


func _init(s) -> void:
	sim = s


func S() -> GameState:
	return sim.state


func fork_def(id: String):
	return sim.db.forks.get(id)


func fork_replacing(event_id: String) -> String:
	## The fork that carries this event's question, if any ("" when the event keeps its own choices).
	for fid in REPLACES:
		if REPLACES[fid] == event_id and sim.db.forks.has(fid):
			return fid
	for f in sim.db.fork_list:
		var r = f.get("replaces_event")
		if (typeof(r) == TYPE_STRING and r == event_id) or (typeof(r) == TYPE_ARRAY and r.has(event_id)):
			return str(f["id"])
	return ""


func city_held(city_key: String) -> bool:
	## True while a fork that decides about this locality is open or about to open (from 2 years before its date
	## until it is decided or its window closes).
	for f in sim.db.fork_list:
		var fid := str(f["id"])
		var hold: Array = f.get("holds_cities", HOLDS_CITIES.get(fid, []))
		if not hold.has(city_key) or S().fork_choices.has(fid) or S().flags.has("fork_skipped:" + fid):
			continue
		var t0 := SimDB.turn_of(f.get("date"), 99999)
		var t1 := SimDB.turn_of(f.get("until"), t0 + 4)
		if S().turn >= t0 - 8 and S().turn <= t1:
			return true
	return false


func history_course_forks(event_id: String) -> Array:
	var out := []
	for f in sim.db.fork_list:
		var fid := str(f["id"])
		var lst: Array = f.get("history_course", HISTORY_COURSE.get(fid, []))
		if lst.has(event_id):
			out.append(fid)
	return out


# ------------------------------------------------------------------ offering

func requires_ok(f: Dictionary) -> bool:
	var r: Dictionary = f.get("requires", {})
	var st := S()
	if r.has("event") and not st.fired_events.has(str(r["event"])):
		return false
	var after := str(AFTER_EVENT.get(str(f.get("id", "")), ""))
	if after != "" and sim.db.event_by_id.has(after) and not st.fired_events.has(after):
		return false
	if r.has("flag") and not st.flags.has(str(r["flag"])):
		return false
	if r.has("not_flag") and st.flags.has(str(r["not_flag"])):
		return false
	if r.has("tech") and not st.techs.has(str(r["tech"])):
		return false
	if r.has("civic") and not st.civics.has(str(r["civic"])):
		return false
	for key in ["choice", "not_choice"]:
		var want = r.get(key)
		if typeof(want) != TYPE_DICTIONARY:
			continue
		for src in want:
			var made := _choice_of(str(src))
			var match_ := made != "" and (made == str(want[src]))
			if key == "choice" and not match_: return false
			if key == "not_choice" and match_: return false
	return true


func _choice_of(src: String) -> String:
	## The option id chosen at a fork, or the index (as text) chosen at an event; "" if none.
	if S().fork_choices.has(src):
		return str(S().fork_choices[src])
	if S().choices_made.has(src):
		return str(S().choices_made[src])
	return ""


func choice_matches(cond) -> bool:
	## {"<fork or event id>": "<option>" | ["<option>", ...]}: true when every listed decision was answered with one
	## of the given options (data "if_choice" / "if" of event consequences and war variants).
	if typeof(cond) != TYPE_DICTIONARY or cond.is_empty():
		return false
	for src in cond:
		var made := _choice_of(str(src))
		if made == "":
			return false
		var want = cond[src]
		var ok := false
		if typeof(want) == TYPE_ARRAY:
			for w in want:
				if str(w) == made: ok = true
		else:
			ok = str(want) == made
		if not ok:
			return false
	return true


func choice_label(fid: String, oid: String) -> String:
	var f = fork_def(fid)
	if f != null:
		for o in f.get("options", []):
			if str(o["id"]) == oid: return str(o.get("label", oid))
	return oid


func holding_fork(city_key: String) -> String:
	## The fork (if any) that held this locality's founding and was answered differently from history.
	for f in sim.db.fork_list:
		var fid := str(f["id"])
		var hold: Array = f.get("holds_cities", HOLDS_CITIES.get(fid, []))
		if hold.has(city_key) and S().fork_choices.has(fid) and str(S().fork_choices[fid]) != historical_option(fid):
			return fid
	return ""


func capital_override() -> String:
	## A city key the capital stays in because of a fork answer ("" = history's capital rail applies).
	for fid in CAPITAL_FOLLOWS:
		var made := _choice_of(fid)
		if made != "" and CAPITAL_FOLLOWS[fid].has(made):
			return str(CAPITAL_FOLLOWS[fid][made])
	return ""


func offer_due() -> void:
	var st := S()
	var added := 0
	for f in sim.db.fork_list:
		var id := str(f["id"])
		if st.fork_choices.has(id) or id in st.pending_forks or st.flags.has("fork_skipped:" + id):
			continue
		var t0 := SimDB.turn_of(f.get("date"), 99999)
		var t1 := SimDB.turn_of(f.get("until"), t0 + 4)
		if st.turn < t0:
			continue
		if st.turn > t1:
			st.flags["fork_skipped:" + id] = st.turn
			continue
		if added >= MAX_NEW_PER_TURN or not requires_ok(f):
			continue
		st.pending_forks.append(id)
		added += 1
		sim.notify("fork", "Cabinet decision: %s" % f.get("title", id), {"fork": id})


# ------------------------------------------------------------------ views

func option_view(f: Dictionary, o: Dictionary) -> Dictionary:
	return {"id": o["id"], "label": o.get("label", ""), "advocate": o.get("advocate", ""), "historical": o.get("historical", false),
		"now": now_text(o.get("now", {})), "lasting": shown_terms(o.get("lasting", [])).map(func(s): return term_text(s)),
		"effects": now_struct(o.get("now", {})) + shown_terms(o.get("lasting", [])).map(func(s): return term_struct(s)),
		"cite": o.get("cite", []), "note": o.get("note", "")}


static func shown_terms(lasting: Array) -> Array:
	## Lasting terms that can apply in the game: a term that starts after the last turn (Q3 2023) is never shown
	## (v3 fix3-story A11) and never applies.
	return lasting.filter(func(s): return typeof(s) == TYPE_DICTIONARY and not (s.has("from") and typeof(s["from"]) == TYPE_STRING and SimDB.after_end(s["from"])))


const STAT_OF_NOW := {"gold": "gold", "standing": "standing", "trust": "trust", "readiness": "readiness", "cohesion": "cohesion",
	"inflation": "inflation", "production": "production", "science": "science", "culture": "culture"}


func now_struct(now: Dictionary) -> Array:
	## Structured "now" effects (UI request 18): [{stat, amount, unit, when: "now"}], scaled as they will apply.
	var out := []
	for k in NOW_KEYS:
		if now.has(k) and float(now[k]) != 0.0:
			var v := float(now[k])
			if k in ["gold", "production", "science", "culture"]:
				v *= sim.events.gold_scale()
			out.append({"stat": STAT_OF_NOW[k], "amount": snappedf(v, 0.01), "unit": "points" if k != "inflation" else "percentage points", "when": "now", "good": v > 0.0 if k != "inflation" else v < 0.0})
	return out


func term_struct(s: Dictionary) -> Dictionary:
	## Structured lasting term: {stat, amount, unit, from, until, label, group?, good}.
	var t := str(s.get("type", ""))
	var a := float(s.get("amount", 0))
	if t == "gold":
		a *= sim.events.gold_scale()
	var unit: String = {"gold": "per turn", "standing": "per turn", "standing_target": "settling point", "trust": "per turn", "trust_base": "settling point",
		"readiness": "points", "output_pct": "% production and gold", "science_pct": "% science", "growth_pct": "% growth", "water": "million m3/yr",
		"inflation": "percentage points", "cohesion": "per turn", "amenity": "amenities", "retention": "% retention", "immigrant_weight": "% of arrivals"}.get(t, "")
	var until := str(s.get("until", ""))
	if until != "" and SimDB.after_end(until): until = SimDB.date_iso(SimDB.shown_until()).substr(0, 7)   # v3 A11: capped at the game's end
	var out := {"stat": str(TERM_STAT.get(t, t)), "type": t, "amount": snappedf(a, 0.01), "unit": unit, "from": str(s.get("from", "")), "until": until,
		"label": SimDB.scrub_text(str(s.get("label", ""))), "good": a > 0.0 if t != "inflation" else a < 0.0}
	if s.has("group"): out["group"] = s["group"]
	if s.has("target"): out["target"] = s["target"]
	if t == "immigrant_weight": out.erase("good")
	return out


func fork_view(id: String) -> Dictionary:
	var f = fork_def(id)
	if f == null:
		return {}
	return {"fork": id, "title": f.get("title", ""), "text": f.get("text", ""), "date": f.get("date", ""), "source": f.get("source", []),
		"options": f.get("options", []).map(func(o): return option_view(f, o))}


func now_text(now: Dictionary) -> Array:
	var names := {"gold": "Gold", "standing": "Standing", "trust": "Civic Trust in every city", "readiness": "Readiness", "cohesion": "Cohesion",
		"inflation": "Inflation (points)", "production": "Production", "science": "Science", "culture": "Culture"}
	var out := []
	for k in NOW_KEYS:
		if now.has(k) and float(now[k]) != 0.0:
			var v := float(now[k])
			if k in ["gold", "production", "science", "culture"]:
				v = roundf(v * sim.events.gold_scale())   # v3 fix4-diplo: whole gold in option text ("Gold -134 now", not "-133.5")
			out.append("%s %s now" % [names[k], _signed(v)])
	return out


static func _signed(v: float) -> String:
	if absf(v - round(v)) < 0.05:
		return "%+d" % int(round(v))
	return "%+.1f" % v


const GROUP_NAMES := {"dev_towns": "development towns", "arab": "Arab localities", "periphery": "the periphery", "large_cities": "large cities"}


func term_text(s: Dictionary, stored := false) -> String:
	## stored = a stream from the save: turns become years and the amount is already the real (scaled) figure.
	var a := float(s.get("amount", 0))
	var y0 := str(s.get("from", "")).substr(0, 4); var y1 := str(s.get("until", "")).substr(0, 4)
	if stored:
		y0 = str(SimDB.year_of(int(s.get("from", 1)))); y1 = str(SimDB.year_of(int(s.get("until", 1))))
	# v3 fix3-story A11/A9: a span never shows a year after the game's end (Q3 2023)
	var ey := SimDB.end_year()
	if y1.is_valid_int() and int(y1) > ey: y1 = str(ey)
	if y0.is_valid_int() and int(y0) > ey: y0 = str(ey)
	var span := y0 if y0 == y1 else "%s-%s" % [y0, y1]
	var where := ""
	if s.has("group") and str(s["group"]) != "all":
		where = " in " + str(GROUP_NAMES.get(str(s["group"]), s["group"]))
	var lab := SimDB.scrub_text(str(s.get("label", "")))
	match str(s.get("type")):
		"gold": return "%s Gold per turn, %s (%s)" % [_signed(a if stored else a * sim.events.gold_scale()), span, lab]
		"standing": return "%s Standing per turn, %s (%s)" % [_signed(a), span, lab]
		"standing_target": return "Standing settles %s higher, %s (%s)" % [_signed(a), span, lab] if a >= 0 else "Standing settles %s lower, %s (%s)" % [_signed(-a).substr(1), span, lab]
		"trust": return "%s Civic Trust per turn%s, %s (%s)" % [_signed(a), where, span, lab]
		"trust_base": return "Civic Trust settles %s%s, %s (%s)" % [_signed(a), where, span, lab]
		"readiness": return "%s Readiness, %s (%s)" % [_signed(a), span, lab]
		"output_pct": return "%s%% Production and Gold, %s (%s)" % [_signed(a), span, lab]
		"science_pct": return "%s%% Science, %s (%s)" % [_signed(a), span, lab]
		"growth_pct": return "%s%% population growth, %s (%s)" % [_signed(a), span, lab]
		"water": return "%s million m3 water supply a year, %s (%s)" % [_signed(a), span, lab]
		"inflation": return "%s points of inflation, %s (%s)" % [_signed(a), span, lab]
		"cohesion": return "%s Cohesion per turn, %s (%s)" % [_signed(a), span, lab]
		"amenity": return "%s Amenity%s, %s (%s)" % [_signed(a), where, span, lab]
		"retention": return "%s%% immigrant retention, %s (%s)" % [_signed(a), span, lab]
		"immigrant_weight": return "%s%% of new immigrants to %s, %s (%s)" % [_signed(a), "small towns" if str(s.get("target", "")) == "small_towns" else "large cities", span, lab]
	return lab


# ------------------------------------------------------------------ choosing

func choose(id: String, option) -> bool:
	var st := S()
	if not (id in st.pending_forks):
		return false
	var f = fork_def(id)
	if f == null:
		return false
	var o = null
	var i := 0
	for oo in f["options"]:
		if str(oo["id"]) == str(option) or (typeof(option) == TYPE_INT and int(option) == i):
			o = oo
		i += 1
	if o == null:
		return false
	var reason := "%s: %s" % [f.get("title", id), o.get("label", "")]
	apply_now(o.get("now", {}), reason)
	add_terms(o.get("lasting", []), id, reason)
	for fl in o.get("flags", []):
		st.flags[str(fl)] = st.turn
	st.pending_forks.erase(id)
	st.fork_choices[id] = str(o["id"])
	# civics that only the other answers would bring (never adopted by rail or by a replaced event)
	for cv in CIVIC_FOLLOWS.get(id, {}).get(str(o["id"]), []):
		st.flags["blocked_civic:" + str(cv)] = st.turn
	# an event of this quarter that waited for this answer now applies its effects (or its changed outcome)
	sim.events.on_fork_chosen(id, str(o["id"]))
	if st.pending_forks.is_empty() and sim.events.events_held():
		sim.resume_turn_events()
	sim.events.apply_territory_rails(false)
	st.milestones["fork:%s:%s" % [id, o["id"]]] = st.turn
	var hist = null
	for oo in f["options"]:
		if oo.get("historical", false): hist = oo
	if not o.get("historical", false):
		st.counters["counterfactual_choices"] = int(st.counters.get("counterfactual_choices", 0)) + 1
	if hist != null:
		sim.notify("what_happened", "What actually happened: %s%s" % [hist.get("label", ""), (". " + str(hist.get("note", ""))) if str(hist.get("note", "")) != "" else ""],
			{"fork": id, "chosen": o["id"], "historical": hist["id"]})
	sim.refresh()
	return true


func apply_now(now: Dictionary, reason: String) -> void:
	var st := S()
	var gs: float = sim.events.gold_scale()
	if now.has("gold") and float(now["gold"]) != 0.0:
		st.gold += float(now["gold"]) * gs
	if now.has("standing") and float(now["standing"]) != 0.0:
		sim._change_standing(float(now["standing"]), reason, true)
	if now.has("trust") and float(now["trust"]) != 0.0:
		for c in sim.active_cities():
			c.trust = clampf(c.trust + float(now["trust"]), 0.0, 100.0)
		sim.add_trust_player(float(now["trust"]))
		sim.stat_note("trust", float(now["trust"]), reason)
	if now.has("readiness") and float(now["readiness"]) != 0.0:
		st.readiness_bonus += float(now["readiness"])
		sim.stat_note("readiness", float(now["readiness"]), reason)
	if now.has("cohesion") and float(now["cohesion"]) != 0.0:
		st.cohesion += float(now["cohesion"])
		sim.stat_note("cohesion", float(now["cohesion"]), reason)
	if now.has("inflation") and float(now["inflation"]) != 0.0:
		sim.shift_inflation(float(now["inflation"]))
		sim.stat_note("inflation", float(now["inflation"]), reason)
	if now.has("production") and float(now["production"]) != 0.0:
		var cap = sim.city_by_key(st.capital)
		if cap != null and not cap.queue.is_empty():
			var pk := str(cap.queue[0]["kind"]) + ":" + str(cap.queue[0]["id"])
			cap.progress[pk] = maxf(0.0, float(cap.progress.get(pk, 0.0)) + float(now["production"]) * gs)
	if now.has("science") and st.current_tech != "":
		st.tech_progress[st.current_tech] = maxf(0.0, float(st.tech_progress.get(st.current_tech, 0.0)) + float(now["science"]) * gs)
	if now.has("culture") and st.current_civic != "":
		st.civic_progress[st.current_civic] = maxf(0.0, float(st.civic_progress.get(st.current_civic, 0.0)) + float(now["culture"]) * gs)


const TERM_STAT := {"gold": "gold", "standing": "standing", "standing_target": "standing", "trust": "trust", "trust_base": "trust",
	"readiness": "readiness", "output_pct": "economy", "science_pct": "science", "growth_pct": "population", "water": "water",
	"inflation": "inflation", "cohesion": "cohesion", "amenity": "trust", "retention": "population", "immigrant_weight": "population"}


func add_terms(lasting: Array, src: String, reason: String) -> void:
	## Lasting terms become streams; each is logged once (with its span) in "Why stats moved".
	var st := S()
	for s in shown_terms(lasting):
		var a := float(s.get("amount", 0))
		if str(s.get("type")) == "gold":
			a *= sim.events.gold_scale()
		var e := {"type": str(s.get("type")), "amount": a, "from": maxi(st.turn, SimDB.turn_of(s.get("from"), st.turn)),
			"until": SimDB.turn_of(s.get("until"), st.turn + 16), "label": str(s.get("label", "")), "src": src}
		for k in ["group", "target"]:
			if s.has(k): e[k] = s[k]
		st.streams.append(e)
		st.stat_log.append({"turn": st.turn, "stat": str(TERM_STAT.get(e["type"], e["type"])), "amount": snappedf(a, 0.01),
			"reason": "%s - lasting: %s" % [reason, term_text(s)], "lasting": true})


func auto_resolve() -> void:
	for id in S().pending_forks.duplicate():
		var f = fork_def(id)
		if f == null:
			S().pending_forks.erase(id)
			continue
		for o in f["options"]:
			if o.get("historical", false):
				choose(id, o["id"])
				break


func historical_option(id: String) -> String:
	var f = fork_def(id)
	if f != null:
		for o in f["options"]:
			if o.get("historical", false):
				return str(o["id"])
	return ""


# ------------------------------------------------------------------ ledger for the UI ("Your Israel vs history")

func get_path_ledger() -> Array:
	## Every fork and event choice taken, whether it matched history, and the lasting terms it set.
	var out := []
	for id in S().fork_choices:
		var f = fork_def(id)
		if f == null: continue
		var chosen := str(S().fork_choices[id])
		var terms := S().streams.filter(func(s): return str(s.get("src", "")) == id).map(func(s): return term_text(s, true))
		var labels := {}
		for oo in f.get("options", []):
			labels[str(oo["id"])] = str(oo.get("label", oo["id"]))
		out.append({"id": id, "title": f.get("title", ""), "chosen": chosen, "chosen_label": labels.get(chosen, chosen), "historical": historical_option(id),
			"historical_label": labels.get(historical_option(id), ""), "matched_history": chosen == historical_option(id), "terms": terms,
			"turn": int(S().milestones.get("fork:%s:%s" % [id, chosen], 0))})
	out.sort_custom(func(a, b): return a["turn"] < b["turn"])
	return out
