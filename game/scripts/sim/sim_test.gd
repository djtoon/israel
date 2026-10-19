extends SceneTree
## Headless autoplay test for the simulation.
##   "$G" --headless --path game --script res://scripts/sim/sim_test.gd [-- --skip-ghost --turns=N --seed=S]
## 1. validates data (sources exist for every dated item, cross-references resolve)
## 2. runs the Historical Israel autoplayer and writes game/data/ghost.json (the ghost of history)
## 3. plays the full game (1948 to Sim.last_playable_turn(), Q3 2023) with the simple player AI, scored against that ghost
## 4. prints per-decade summaries, asserts invariants, writes scripts/sim/AUTOPLAY_REPORT.md

var out_lines: Array = []
var failures: Array = []
var t0 := 0


func say(s: String) -> void:
	print(s)
	out_lines.append(s)


func fail(s: String) -> void:
	failures.append(s)
	say("FAIL: " + s)


func _init() -> void:
	t0 = Time.get_ticks_msec()
	var args := OS.get_cmdline_user_args()
	var skip_ghost := "--skip-ghost" in args
	var max_turn := Sim.last_playable_turn()
	var seed := 1948
	for a in args:
		if a.begins_with("--turns="): max_turn = int(a.substr(8))
		if a.begins_with("--seed="): seed = int(a.substr(7))
	say("# Israel - simulation autoplay report")
	say("")
	say("Run: %s, seed %d, Godot %s" % [Time.get_datetime_string_from_system(), seed, Engine.get_version_info().get("string", "")])
	var db := SimDB.get_db()
	say("")
	say("## Data")
	say("techs %d, civics %d, policies %d, districts %d, buildings %d, national projects %d, units %d" % [db.tech_list.size(), db.civic_list.size(), db.policy_list.size(), db.districts.size(), db.buildings.size(), db.projects.size(), db.units.size()])
	say("cities.json %d places, events.json %d events, map %d tiles, %d border eras, SOURCES ids %d" % [db.cities.size(), db.events.size(), db.tiles.size(), db.border_eras.size(), db.sources.size()])
	for w in db.warnings:
		say("data warning: " + str(w))
	for p in db.validate_sources():
		fail("source check: " + p)
	for p in db.validate_refs():
		fail("reference check: " + p)
	say("forks %d (in game/data/forks/), wars %d (in game/data/wars/)" % [db.fork_list.size(), db.wars.size()])
	for e in db.data_errors:
		fail("fork/war data: " + str(e))
	for w2 in db.data_warnings:
		say("fork/war warning: " + str(w2))
	_consequence_check(db)
	_leak_scan(db)
	_purge_scan(db)
	for e in SimDiplomacy.validate(db):
		fail("diplomacy data: " + str(e))
	for e in SimEndgame.validate(db):
		fail("endgame data (projects/endings/difficulty): " + str(e))
	for e in SimEconomy.validate_fiscal(db):
		fail("fiscal levers data (data/fiscal.json): " + str(e))   # v3 fix3-econ
	if "--validate-only" in args:
		say("")
		say("VALIDATION %s: %d errors, %d warnings" % ["PASSED" if failures.is_empty() else "FAILED", failures.size(), db.data_warnings.size()])
		quit(0 if failures.is_empty() else 1)
		return
	_api_smoke()
	if _eg_modes(args, seed, max_turn):   # v3 (sim-endgame): --strategies, --difficulty, --scenario-test
		return
	for a in args:
		if a.begins_with("--divergence"):
			var dt := max_turn
			_divergence(seed, dt)
			_write_report("res://scripts/sim/DIVERGENCE_REPORT.md")
			quit(0 if failures.is_empty() else 1)
			return
	if not skip_ghost:
		say("")
		say("## Ghost of history (Historical Israel autoplayer)")
		var g := _play("historical", seed, max_turn, true)
		if g == null or g.econ == null:
			_write_report()
			quit(2)
			return
		var gp := "res://data/ghost.json"
		var err: Error = OK
		if max_turn < Sim.last_playable_turn():
			say("(partial ghost run: ghost.json not written)")
		else:
			err = g.score.export_ghost(gp)
		if err != OK:
			fail("could not write ghost.json: %s" % err)
		else:
			say("ghost written to game/data/ghost.json (%d turns, %d milestones)" % [g.state.history.size(), g.state.milestones.size()])
		if "--ghost-only" in args:
			_final(g)
			_write_report()
			quit(0 if failures.is_empty() else 1)
			return
		g.dispose()
		SimDB.reload_db()
	say("")
	say("## Player autoplay (simple AI policy) scored against the ghost")
	var s := _play("player", seed, max_turn, false)
	if s == null or s.econ == null:
		_write_report()
		quit(2)
		return
	_final(s)
	if max_turn >= Sim.last_playable_turn() and not ("--no-collapse" in args):
		_collapse_report(seed, max_turn)   # v3 item 13 (fix-v3a)
	say("")
	say("## Result")
	say("elapsed %.1f s, failures %d" % [(Time.get_ticks_msec() - t0) / 1000.0, failures.size()])
	for f in failures.slice(0, 40):
		say("- " + f)
	if failures.is_empty():
		say("ALL INVARIANTS PASSED")
	if failures.is_empty() and max_turn < Sim.last_playable_turn():
		say("(partial run: --turns=%d)" % max_turn)
	_write_report()
	if s != null:
		s.dispose()
	quit(0 if failures.is_empty() else 1)


func _api_smoke() -> void:
	## Calls every UI-facing query/action once on a fresh game (catches API breakage the AI never touches).
	var sim := Sim.new()
	if sim.econ == null:
		fail("API smoke: Sim did not construct")
		return
	sim.new_game({"mode": "player", "seed": 7})
	var n := 0
	var checks := {
		"get_date": sim.get_date(), "national": sim.get_national_summary(), "cities": sim.get_cities(), "techs": sim.get_techs(),
		"civics": sim.get_civics(), "policies": sim.get_policy_state(), "units": sim.get_units("player"), "all_units": sim.get_units(""),
		"pending": sim.get_pending_decisions(), "next": sim.next_action(), "events": sim.get_pending_events(), "score": sim.get_score(),
		"diplomacy": sim.get_diplomacy(), "upcoming": sim.get_upcoming_events(12), "foreign": sim.get_foreign_places(),
		"timeline": sim.get_timeline(), "history": sim.get_history(), "settle": sim.get_settle_targets(), "crises": sim.get_crises(),
		"log": sim.get_event_log(5), "notes": sim.get_notifications()}
	for k in checks:
		if checks[k] == null:
			fail("API smoke: %s returned null" % k)
		n += 1
	var c: Dictionary = sim.get_cities()[0]
	var cd := sim.get_city(int(c["id"]))
	if cd.is_empty() or not cd.has("yields") or not cd.has("info"):
		fail("API smoke: get_city incomplete")
	var opts := sim.get_buildable(int(c["id"]))
	var avail := opts.filter(func(o): return o["available"])
	if avail.is_empty():
		fail("API smoke: no buildable item in " + str(c["name"]))
	else:
		var o: Dictionary = avail[0]
		if not sim.set_production(int(c["id"]), o["kind"], o["id"]):
			fail("API smoke: set_production failed for %s" % o["id"])
	sim.get_district_sites(int(c["id"]), "university")
	sim.get_buyable_tiles(int(c["id"]))
	sim.get_purchase_cost(int(c["id"]), "unit", "builder", "gold")
	sim.get_tile(int(c["q"]), int(c["r"]))
	var t := SimAI.pick_research(sim)
	if t == "" or not sim.set_research(t):
		fail("API smoke: set_research failed")
	var cv := SimAI.pick_civic(sim)
	if cv != "" and not sim.set_civic(cv):
		fail("API smoke: set_civic failed")
	for u in sim.get_units("player"):
		if u["type"] == "builder":
			var r: Dictionary = sim.unit_action(int(u["id"]), "move", {"q": int(u["q"]) + 1, "r": int(u["r"])})
			sim.reachable_path(int(u["id"]), int(u["q"]) + 2, int(u["r"]))
			n += 1
		if u["type"] == "settler":
			var fr: Dictionary = sim.unit_action(int(u["id"]), "found_city", {})
			if fr.get("ok", false) == false and not fr.has("reason"):
				fail("API smoke: found_city gave no reason")
	for d in sim.get_pending_events():
		sim.choose_event(d["event"], 0)
	var before := sim.state.turn
	for i in range(4):
		SimAI.play_turn(sim)
	if sim.state.turn != before + 4:
		fail("API smoke: turns did not advance")
	var path := "user://api_smoke.json"
	if not sim.save_game(path) or not Sim.new().load_game(path):
		fail("API smoke: save/load")
	say("")
	say("API smoke test: %d queries and the main actions OK (%s)" % [n, sim.date_label()])
	sim.dispose()


func _run_style(style: String, seed: int, max_turn: int, difficulty := "normal") -> Sim:
	var sim := Sim.new()
	sim.new_game({"mode": "player", "seed": seed, "difficulty": difficulty})
	sim.state.counters["ai_style"] = style
	sim.set_meta("decision_log", [])
	sim.set_meta("fc_turns", [])
	while not sim.state.game_over and sim.state.turn <= max_turn:
		SimAI.play_turn(sim)
		var fi: Dictionary = sim.get_fiscal_indicator()
		sim.get_meta("fc_turns").append([sim.state.turn, float(sim.state.counters.get("last_budget", {}).get("net", 0.0)), sim.state.inflation, sim.econ.economy_health(),
			str(fi.get("level", "ok")), ", ".join(fi.get("why", []))])
	return sim


func _divergence(seed: int, max_turn: int) -> void:
	## V1: a historical-choices run and a deliberately non-historical run must end measurably apart on >= 3 tracks,
	## with the stat log explaining why.
	say("")
	say("## Divergence test (historical picks vs deliberately varied picks, to %s)" % SimDB.date_label(mini(max_turn, Sim.last_playable_turn())))
	var h := _run_style("historical", seed, max_turn)
	var v := _run_style("varied", seed, max_turn)
	var hv := h.score.values(); var vv := v.score.values()
	say("")
	say("| Track | Historical picks | Varied picks | Difference |")
	say("|---|---|---|---|")
	var apart := 0
	for t in SimScore.TRACKS:
		var id: String = t["id"]
		var a := float(hv.get(id, 0.0)); var b := float(vv.get(id, 0.0))
		var d := (b / a - 1.0) * 100.0 if absf(a) > 0.001 else 0.0
		# population totals are fixed by the immigration rails (S276), so 3% (about 300,000 people) is a large gap there
		if absf(d) >= (3.0 if id == "population" else 5.0): apart += 1
		say("| %s | %s | %s | %+.1f%% |" % [t["name"], _n(a), _n(b), d])
	for k in ["gold", "readiness", "cities"]:
		say("| %s | %s | %s | |" % [k, _n(float(hv.get(k, 0))), _n(float(vv.get(k, 0)))])
	say("| inflation %% | %.1f | %.1f | |" % [h.state.inflation, v.state.inflation])
	say("")
	say("Forks: historical run %d taken (%d non-historical); varied run %d taken (%d non-historical). Event choices counterfactual: %d vs %d." % [
		h.state.fork_choices.size(), _nonhist(h), v.state.fork_choices.size(), _nonhist(v),
		int(h.state.counters.get("counterfactual_choices", 0)), int(v.state.counters.get("counterfactual_choices", 0))])
	say("Tracks measurably apart (5%%; 3%% for population): %d of 6 (V2 needs 4)" % apart)
	var ho := float(h.score.current()["overall"]); var vo := float(v.score.current()["overall"])
	say("Overall score vs the ghost: historical picks %.1f%%, varied picks %.1f%%: spread %+.1f points" % [ho, vo, vo - ho])
	_fc_arc([h, v], ["historical", "varied"])
	_fc_debt(h, "historical picks")
	_fc_debt(v, "varied picks")
	_fc_pick_shares(v)
	_diplo_report([h, v], ["historical", "varied"])
	say("")
	say("What made the difference (varied picks):")
	for r in v.score.final_summary()["reasons"]:
		say("- [%s] %s" % [r["track"], r["text"]])
	if apart < 4:
		fail("divergence: only %d of 6 tracks differ by 5%% or more (V2 needs 4)" % apart)
	say("")
	say("Why they differ (lasting terms in the varied run's stat log):")
	var lasting := v.get_stat_log().filter(func(e): return e.get("lasting", false))
	for e in lasting.slice(0, 14):
		say("- %s %s: %s" % [SimDB.date_label(int(e["turn"])), e["stat"], e["reason"]])
	var stats := {}
	for e in v.get_stat_log():
		stats[e["stat"]] = int(stats.get(e["stat"], 0)) + 1
	say("")
	say("Stat log entries by stat (varied run): %s" % str(stats))
	for e2 in v.state.errors.slice(0, 10):
		fail("varied sim error: " + str(e2))
	for e3 in h.state.errors.slice(0, 10):
		fail("historical sim error: " + str(e3))
	_consequence_run_check(v, "varied")
	# v3 fix3-econ (A7): choices change the outcome: the varied (non-historical) cabinet ends 15+ points below Recommended
	var r := _run_style("recommended", seed, max_turn)
	var ro := float(r.score.current()["overall"])
	say("")
	say("Overall: Recommended %.1f%%, varied %.1f%%, historical picks %.1f%%: Recommended ahead of varied by %+.1f points (fix3-econ bar: 15 or more)" % [ro, vo, ho, ro - vo])
	_eg_endings_report([h, v, r], ["historical", "varied", "recommended"])
	_fc_indicator_tiers([h, v, r], ["historical", "varied", "recommended"])
	_inflation_path(h)
	if absf(vo - ho) < 10.0:
		fail("divergence: opposite strategies end only %.1f points apart overall (V3 needs 10)" % absf(vo - ho))
	if max_turn >= Sim.last_playable_turn() and ro - vo < 15.0:
		fail("divergence: the varied cabinet ends only %.1f points below Recommended (fix3-econ: 15 or more)" % (ro - vo))
	h.dispose(); v.dispose(); r.dispose()


const SUBJECT_STOP := ["israel", "israeli", "government", "election", "operation", "crisis", "agreement", "accord", "peace", "knesset",
	"policy", "national", "south", "north", "first", "second", "third", "state", "basic", "plan", "talks", "response", "relations", "front",
	"after", "against", "under", "inquiry", "budget", "reform", "coalition", "programme", "program", "minister", "unity"]


static func _subject_words(slug: String) -> Array:
	var out := []
	for w in slug.to_lower().split("_", false):
		if w.length() >= 5 and not w.is_valid_int() and not (w in SUBJECT_STOP):
			out.append(w)
	return out


func _fork_event_covered(db: SimDB, f: Dictionary, ev: Dictionary, oid: String) -> bool:
	## True if the event, firing after this non-historical answer, says how it relates to it (or is replaced by it).
	var fid := str(f["id"]); var eid := str(ev["id"])
	if str(SimForks.REPLACES.get(fid, "")) == eid:
		return true
	var r = f.get("replaces_event")
	if (typeof(r) == TYPE_STRING and r == eid) or (typeof(r) == TYPE_ARRAY and r.has(eid)):
		return true
	if Array(f.get("history_course", SimForks.HISTORY_COURSE.get(fid, []))).has(eid):
		return true
	for c in ev.get("consequences", []):
		var want = c.get("if", {}).get(fid)
		if (typeof(want) == TYPE_STRING and want == oid) or (typeof(want) == TYPE_ARRAY and want.has(oid)):
			return true
	for w in db.wars.values():
		if str(w.get("event", "")) == eid:
			for v in w.get("variants", []):
				var want2 = v.get("if_choice", {}).get(fid)
				if (typeof(want2) == TYPE_STRING and want2 == oid) or (typeof(want2) == TYPE_ARRAY and want2.has(oid)):
					return true
	return false


func _same_subject_pairs(db: SimDB) -> Array:
	## [fork, event] pairs whose ids share a distinctive word and where the event fires inside the fork's window or up
	## to 8 turns after it, not counting the event that causes the fork (requires.event / SimForks.AFTER_EVENT) and
	## pairs listed in SimForks.NOT_SAME_SUBJECT.
	var out := []
	for f in db.fork_list:
		var fid := str(f["id"])
		var t0 := SimDB.turn_of(f.get("date"), 99999)
		var t1 := SimDB.turn_of(f.get("until"), t0 + 4)
		var fw := _subject_words(fid.substr(10))
		var req = f.get("requires", {})
		var cause := str(req.get("event", "")) if typeof(req) == TYPE_DICTIONARY else ""
		var after := str(SimForks.AFTER_EVENT.get(fid, ""))
		for ev in db.events:
			var t := int(ev["_turn"])
			var eid := str(ev["id"])
			if Array(SimForks.SUBJECT_EVENTS.get(fid, [])).has(eid) and eid != cause and eid != after:
				out.append([f, ev])
				continue
			if t < t0 or t > t1 + 8 or eid == cause or eid == after or SimForks.NOT_SAME_SUBJECT.has(fid + ">" + eid):
				continue
			var shared := false
			for w in _subject_words(eid.substr(9)):
				if w in fw: shared = true
			if shared:
				out.append([f, ev])
	return out


func _consequence_check(db: SimDB) -> void:
	## V2 fixes (full-game critic B2): no same-subject event may fire unchanged after a non-historical fork pick.
	## Every non-historical option of every fork must be covered for each same-subject event that can follow it:
	## the fork replaces the event's question, or the event carries a history-course note, a "consequences" entry
	## (skipped or changed outcome) or a war variant for that answer.
	var pairs := _same_subject_pairs(db)
	var bad := []
	for p in pairs:
		var f: Dictionary = p[0]
		var ev: Dictionary = p[1]
		for o in f.get("options", []):
			if o.get("historical", false):
				continue
			if not _fork_event_covered(db, f, ev, str(o["id"])):
				bad.append("%s -> %s (%s) after option '%s'" % [f["id"], ev["id"], ev.get("date", ""), o["id"]])
	say("fork consequence check: %d same-subject fork/event pairs; %d uncovered non-historical answers" % [pairs.size(), bad.size()])
	for b in bad:
		fail("fork consequence: same-subject event fires unchanged after a non-historical pick: " + b)
	_generic_note_check(db)


## v3 fix3-story (A11, BLOCKER): keys whose values are bibliography, ids or internal fields, not shown text
const LEAK_SKIP := ["url", "archived_url", "quote", "page", "accessed", "file", "file_small", "generated", "cbs_code", "id", "source", "sources",
	"_hist_year", "_hist", "event", "from_event", "to_event", "fork", "requires", "if", "unless", "if_choice", "subject_fork", "deal",
	"elevation_m", "by", "by_fix3", "turn", "_turn", "_end_turn", "unlock_tech", "unlock_civic", "found_city", "kind", "type", "group",
	"citation", "provenance", "art", "image", "img", "portrait"]
const LEAK_YEAR_KEYS := ["year", "until", "from", "hist", "date", "date_end", "to"]


func _leak_walk(where: String, x, hits: Array, key := "") -> void:
	if key in LEAK_SKIP or key.ends_with("_until_end") or key.ends_with("_id") or key.ends_with("_event"):
		return
	match typeof(x):
		TYPE_DICTIONARY:
			for k in x:
				_leak_walk(where, x[k], hits, str(k))
		TYPE_ARRAY:
			for v in x:
				_leak_walk(where, v, hits, key)
		TYPE_STRING:
			if not SimDB.years_after_end(str(x)).is_empty() and hits.size() < 400:
				hits.append("%s.%s: %s" % [where, key, str(x).substr(0, 110)])
		TYPE_INT, TYPE_FLOAT:
			if key in LEAK_YEAR_KEYS and float(x) > SimDB.end_year() and float(x) < 2100.0 and hits.size() < 400:
				hits.append("%s.%s = %s" % [where, key, str(x)])


func _leak_scan(db: SimDB) -> void:
	## v3 fix3-story (A11, BLOCKER): nothing dated after the game's end (Q3 2023) is visible anywhere: city status
	## timelines, the trees (techs, civics, buildings, units, projects, policies), the eras, the national programmes,
	## every event, fork, war, deal, envoy and diplomacy timeline shown, their lasting-term texts, the cabinet's
	## programmes and coalition partners, and the real-series notes.
	var cats := {}
	var hits := []
	var n0 := 0
	for c in db.cities: _leak_walk("city:" + str(c["id"]), c, hits)
	cats["cities"] = hits.size() - n0; n0 = hits.size()
	for coll in [db.techs, db.civics, db.buildings, db.units, db.projects, db.policies, db.districts, db.city_projects, db.improvements]:
		for id in coll: _leak_walk("item:" + str(id), coll[id], hits)
	_leak_walk("eras", db.eras, hits)
	cats["trees"] = hits.size() - n0; n0 = hits.size()
	for pr in SimEndgame.programme_defs(): _leak_walk("programme:" + str(pr.get("id", "")), pr, hits)
	cats["programmes"] = hits.size() - n0; n0 = hits.size()
	for ev in db.events:
		if db.event_shown(ev): _leak_walk("event:" + str(ev["id"]), ev, hits)
	cats["events"] = hits.size() - n0; n0 = hits.size()
	for w in db.wars.values():
		if db.war_shown(w): _leak_walk("war:" + str(w.get("id", "")), w, hits)
	cats["wars"] = hits.size() - n0; n0 = hits.size()
	_leak_walk("governments", {"ministries": db.gov.get("ministries", []), "coalition_partners": db.gov.get("coalition_partners", [])}, hits)
	for k in db.real:
		if typeof(db.real[k]) == TYPE_DICTIONARY: _leak_walk("real:" + str(k), {"note": db.real[k].get("note", "")}, hits)
	cats["cabinet and series"] = hits.size() - n0; n0 = hits.size()
	# what a game shows: fork option views (with their lasting-term spans), event choice terms, the diplomacy screen
	var sim := Sim.new()
	sim.new_game({"mode": "player", "seed": 11})
	for f in db.fork_list:
		if not db.fork_shown(f): continue
		var fv: Dictionary = sim.forks.fork_view(str(f["id"]))
		var raw: Dictionary = f.duplicate(true)
		for o in raw.get("options", []): o.erase("lasting")
		_leak_walk("fork:" + str(f["id"]), raw, hits)
		for o in fv.get("options", []): _leak_walk("fork view:" + str(f["id"]), {"lasting": o.get("lasting", []), "effects": o.get("effects", [])}, hits)
	cats["forks"] = hits.size() - n0; n0 = hits.size()
	for ev in db.events:
		if not db.event_shown(ev) or ev.get("choices", []).is_empty(): continue
		for i in range(ev["choices"].size()): _leak_walk("choice terms:" + str(ev["id"]), sim.events.terms_text(ev, i), hits)
	cats["choice terms"] = hits.size() - n0; n0 = hits.size()
	var dd := SimDiplomacy.data()
	for x in dd.get("envoys", []):
		var r: Dictionary = x.duplicate(true)
		for o in r.get("options", []):
			for s2 in sim.diplo._abs_terms(o.get("lasting", [])): _leak_walk("envoy terms:" + str(x.get("id", "")), sim.forks.term_text(s2), hits)
			o.erase("lasting")
		for k in ["until", "date"]: r.erase(k)
		_leak_walk("envoy:" + str(x.get("id", "")), r, hits)
	for x in dd.get("deals", []):
		var r2: Dictionary = x.duplicate(true)
		for s3 in sim.diplo._abs_terms(x.get("lasting", [])): _leak_walk("deal terms:" + str(x.get("id", "")), sim.forks.term_text(s3), hits)
		for k in ["until", "from", "lasting"]: r2.erase(k)
		for e in r2.get("offer_eras", []): e.erase("until"); e.erase("from")
		_leak_walk("deal:" + str(x.get("id", "")), r2, hits)
	sim.state.turn = Sim.full_last_turn()
	for a in sim.state.diplomacy:
		var ga: Dictionary = sim.diplo.get_actor(str(a))
		_leak_walk("diplomacy screen:" + str(a), {"timeline": ga.get("timeline", []), "phase": ga.get("phase", {}), "deals": ga.get("deals", []).map(func(d): return {"text": d.get("text", ""), "risks": d.get("risks", []), "lasting": d.get("lasting", [])}), "exposure": ga.get("exposure", {}), "agenda": ga.get("agenda", {})}, hits)
	cats["diplomacy"] = hits.size() - n0; n0 = hits.size()
	# v3 fix4-diplo (M-A): deal end dates. Each deal is made in the last quarter it can be (its terms then run past
	# the game's end): the running terms on the diplomacy screen, the deal views and the deal log show no later quarter.
	for x in dd.get("deals", []):
		sim.state.turn = clampi(SimDB.turn_of(x.get("until"), Sim.full_last_turn()), 1, Sim.full_last_turn())
		sim.diplo._take_deal(str(x["id"]), 1.0, 1.0, {}, "")
		for r3 in sim.diplo.get_relations():
			if str(r3.get("id", "")) != str(x.get("actor", "")): continue
			_leak_walk("deal end:" + str(x.get("id", "")), {"active_terms": r3.get("active_terms", []), "deals": r3.get("deals", []).map(func(d): return {"lasting": d.get("lasting", []), "counter": d.get("counter", {})})}, hits)
	_leak_walk("diplomacy log", sim.diplo.D()["log"], hits)
	cats["deal end dates"] = hits.size() - n0; n0 = hits.size()
	sim.dispose()
	say("leak scan (nothing dated after %s visible): %d hits; %s" % [SimDB.date_label(SimDB.shown_until()), hits.size(), ", ".join(cats.keys().map(func(k): return "%s %d" % [k, cats[k]]))])
	for h in hits.slice(0, 40):
		fail("leak past the game's end: " + h)


## v3 integration (2026-10-14, the user: "we dont need them after oct 7"): everything dated after Q3 2023 is deleted
## from the data (tools/purge_after_end.py) and tombstoned. This scan reads the raw files, not what the game shows:
## no event, fork or war dated after the end; no tombstoned id anywhere; no date or year after the end in the data,
## the Hebrew data catalogs or the UI catalogs (bibliography - URLs, quotes, access dates - is not content); and the
## runtime safety net (SimDB.event_shown/war_shown/fork_shown and the load-time scrub) hides nothing.
## Whitelisted: the memorial (data/ending_oct7.json), the ghost and scenario saves (numbers), portrait eras in
## art_manifest.json (portraits stay as made), map tile/border coordinates.
const PURGE_BIB := ["url", "archived_url", "quote", "accessed", "page", "generated", "citation", "provenance", "file", "file_small",
	"cbs_code", "elevation_m", "_meta", "credit", "credits", "license", "prompt", "model"]
const PURGE_DATE_KEYS := ["year", "until", "from", "hist", "date", "date_end", "to", "start", "end", "turn"]


var _purge_deleted := {}


func _purge_walk(where: String, x, hits: Array, key := "") -> void:
	if hits.size() >= 400 or key in PURGE_BIB:
		return
	match typeof(x):
		TYPE_DICTIONARY:
			for k in x:
				if _purge_deleted.has(str(k)): hits.append("%s: deleted id %s used as a key" % [where, k])
				_purge_walk(where, x[k], hits, str(k))
		TYPE_ARRAY:
			for v in x:
				_purge_walk(where, v, hits, key)
		TYPE_STRING:
			var sx := str(x)
			if _purge_deleted.has(sx):
				hits.append("%s.%s: deleted id %s" % [where, key, sx])
			elif key in ["source", "sources", "id"]:
				pass   # S-ids and record ids are not years
			elif key == "turn" and sx.is_valid_int() and int(sx) > Sim.full_last_turn():
				hits.append("%s.%s = %s (turn after the end)" % [where, key, sx])
			elif key in PURGE_DATE_KEYS and SimDB.after_end(sx):
				hits.append("%s.%s = %s (date after the end)" % [where, key, sx])
			elif not SimDB.years_after_end(sx).is_empty():
				hits.append("%s.%s: %s" % [where, key, sx.substr(0, 110)])
		TYPE_INT, TYPE_FLOAT:
			if key == "turn" and int(x) > Sim.full_last_turn():
				hits.append("%s.%s = %s (turn after the end)" % [where, key, str(x)])
			elif key in PURGE_DATE_KEYS and key != "turn" and float(x) > SimDB.end_year() and float(x) < 2100.0:
				hits.append("%s.%s = %s (year after the end)" % [where, key, str(x)])


func _purge_files(dir: String, rec := false) -> Array:
	var out := []
	if not DirAccess.dir_exists_absolute(dir): return out
	for fn in DirAccess.get_files_at(dir):
		if fn.ends_with(".json"): out.append(dir.path_join(fn))
	if rec:
		for sd in DirAccess.get_directories_at(dir):
			out.append_array(_purge_files(dir.path_join(sd), true))
	out.sort()
	return out


func _purge_scan(db: SimDB) -> void:
	_purge_deleted = db.deleted_ids
	var hits := []
	var cats := {}
	var n0 := 0
	var end_t := Sim.full_last_turn()
	# 1. no content dated after the end, and nothing for the runtime helpers to hide
	for ev in db.events:
		if int(ev.get("_turn", 0)) > end_t: hits.append("event %s dated %s, after the end" % [ev["id"], ev.get("date", "")])
		elif not db.event_shown(ev): hits.append("event %s hidden by SimDB.event_shown" % ev["id"])
	for w in db.wars.values():
		if not db.war_shown(w): hits.append("war %s hidden by SimDB.war_shown (its event is after the end or missing)" % w.get("id", ""))
	for f in db.fork_list:
		if not db.fork_shown(f): hits.append("fork %s dated %s hidden by SimDB.fork_shown" % [f["id"], f.get("date", "")])
	for id in db.deleted_ids:
		if db.event_by_id.has(id) or db.forks.has(id) or db.wars.has(id): hits.append("tombstoned id %s is back in the data" % id)
	cats["content and helpers"] = hits.size() - n0; n0 = hits.size()
	SimEndgame.programme_defs()   # loads data/projects.json through the scrub
	for x in SimDB.scrub_log: hits.append("the load-time scrub changed: " + str(x))
	cats["load-time scrub"] = hits.size() - n0; n0 = hits.size()
	# 2. the raw files
	for p in _purge_files("res://data", true):
		var fn: String = p.get_file()
		if fn in ["ghost.json", "ending_oct7.json"] or p.contains("/scenarios/") or p.contains("/i18n/"): continue
		var d = JSON.parse_string(FileAccess.get_file_as_string(p))
		if d == null: continue
		if fn == "map.json":
			d = {"border_eras": d.get("border_eras", []), "places": d.get("places", []), "natural_wonders": d.get("natural_wonders", []),
				"field_notes": d.get("field_notes", {}), "borders": d.get("borders", {}).keys(), "military_control": d.get("military_control", {}).keys(), "areas": d.get("areas", {}).keys()}
		if fn == "art_manifest.json":
			var pr: Dictionary = d.get("portraits", {}).duplicate(true)
			for k in pr:
				if typeof(pr[k]) == TYPE_DICTIONARY: pr[k].erase("era_to"); pr[k].erase("era_from")
			d["portraits"] = pr
		_purge_walk(p.trim_prefix("res://"), d, hits)
	cats["data files"] = hits.size() - n0; n0 = hits.size()
	for p in _purge_files("res://data/i18n/he"):
		var d2 = JSON.parse_string(FileAccess.get_file_as_string(p))
		if typeof(d2) != TYPE_DICTIONARY: continue
		d2.erase("_meta")
		_purge_walk(p.trim_prefix("res://"), d2, hits)
	for p in _purge_files("res://i18n/he"):
		var d3 = JSON.parse_string(FileAccess.get_file_as_string(p))
		if typeof(d3) != TYPE_DICTIONARY: continue
		for k in d3:
			if str(k).begins_with("_"): continue
			_purge_walk(p.trim_prefix("res://") + " " + str(k).substr(0, 40), {"en": str(k), "he": str(d3[k])}, hits)
	cats["Hebrew catalogs"] = hits.size() - n0; n0 = hits.size()
	say("deleted-content scan (nothing after %s in the data; %d tombstoned ids): %d hits; %s" % [SimDB.date_label(end_t), db.deleted_ids.size(), hits.size(),
		", ".join(cats.keys().map(func(k): return "%s %d" % [k, cats[k]]))])
	for h in hits.slice(0, 40):
		fail("content after the end: " + h)


const GENERIC_MAX := 5   # v3 fix3-story (A1): refusals get specific outcomes; at most a handful of generic notes


func _generic_note_check(db: SimDB) -> void:
	## v3 fix3-story (A1), stricter: every (fork, non-historical answer, event) that would print the generic "History
	## took its course ... does not change this event" line is counted and listed. An event is linked to a fork by the
	## fork's history_course list or by SimForks.REPLACES / replaces_event, when the fork can be answered before it
	## (not its cause). It is specific when a "consequences" entry or a war variant names that answer.
	var generic := []
	for f in db.fork_list:
		var fid := str(f["id"])
		var lst: Array = Array(f.get("history_course", SimForks.HISTORY_COURSE.get(fid, []))).duplicate()
		var r = f.get("replaces_event", SimForks.REPLACES.get(fid, ""))
		if typeof(r) == TYPE_STRING and r != "": lst.append(r)
		elif typeof(r) == TYPE_ARRAY: lst.append_array(r)
		var req = f.get("requires", {})
		var cause := str(req.get("event", "")) if typeof(req) == TYPE_DICTIONARY else ""
		for eid in lst:
			var ev = db.event_by_id.get(str(eid))
			if ev == null or str(eid) == cause or str(SimForks.AFTER_EVENT.get(fid, "")) == str(eid) or not db.event_shown(ev):
				continue
			if int(ev["_turn"]) < SimDB.turn_of(f.get("date"), 99999):
				continue
			for o in f.get("options", []):
				if o.get("historical", false): continue
				var oid := str(o["id"])
				var ok := false
				for c in ev.get("consequences", []):
					var want = c.get("if", {}).get(fid)
					if (typeof(want) == TYPE_STRING and want == oid) or (typeof(want) == TYPE_ARRAY and want.has(oid)): ok = true
				var w = db.war_by_event.get(str(eid))
				if typeof(w) == TYPE_DICTIONARY:
					for v in w.get("variants", []):
						var w2 = v.get("if_choice", {}).get(fid)
						if (typeof(w2) == TYPE_STRING and w2 == oid) or (typeof(w2) == TYPE_ARRAY and w2.has(oid)): ok = true
				if not ok:
					generic.append("%s:%s -> %s (%s)" % [fid, oid, eid, ev.get("date", "")])
	say("generic history-course fallbacks: %d (fork answer -> event pairs with no specific outcome; at most %d allowed)" % [generic.size(), GENERIC_MAX])
	for g in generic:
		say("  generic: " + g)
	if generic.size() > GENERIC_MAX:
		fail("consequences: %d refused-fork answers fall back to the generic history-course note (max %d)" % [generic.size(), GENERIC_MAX])


func _consequence_run_check(sim: Sim, label: String) -> void:
	## The same rule on a played game: after each non-historical fork pick, every same-subject event logged in the
	## next 8 turns carries a history-course note or a changed outcome (or is the fork's own replaced question).
	var picked := {}
	for k in sim.state.milestones:
		var ks := str(k)
		if ks.begins_with("fork:"):
			var parts := ks.split(":")
			if parts.size() >= 3:
				picked[parts[1]] = [parts[2], int(sim.state.milestones[k])]
	var n := 0
	var bad := []
	for p in _same_subject_pairs(sim.db):
		var fid := str(p[0]["id"])
		var eid := str(p[1]["id"])
		if not picked.has(fid) or str(picked[fid][0]) == sim.forks.historical_option(fid):
			continue
		for le in sim.state.event_log:
			if str(le["id"]) != eid or int(le["turn"]) < int(picked[fid][1]) or int(le["turn"]) > int(picked[fid][1]) + 8:
				continue
			n += 1
			if not (le.has("history_course") or le.has("consequence")) and str(SimForks.REPLACES.get(fid, "")) != eid:
				bad.append("%s (%s) -> %s, %s" % [fid, picked[fid][0], eid, SimDB.date_label(int(le["turn"]))])
	say("%s run: %d same-subject events after non-historical fork picks; %d without a history-course note or changed outcome" % [label, n, bad.size()])
	var gen := sim.state.notifications.filter(func(x): return bool(x.get("generic", false)))
	say("%s run: %d generic history-course notes, %d specific consequences applied" % [label, gen.size(), int(sim.state.counters.get("consequences_applied", 0))])
	for g in gen.slice(0, 12):
		say("  generic note %s: %s" % [SimDB.date_label(int(g.get("turn", 0))), str(g.get("text", "")).substr(0, 140)])
	for b in bad:
		fail("%s run: event unchanged after a non-historical fork pick: %s" % [label, b])



func _nonhist(sim: Sim) -> int:
	var n := 0
	for id in sim.state.fork_choices:
		if str(sim.state.fork_choices[id]) != sim.forks.historical_option(id): n += 1
	return n


func _play(mode: String, seed: int, max_turn: int, is_ghost: bool) -> Sim:
	var sim := Sim.new()
	if sim.econ == null or not (SimAI is GDScript) or not SimAI.new().has_method("play_turn"):
		fail("Sim failed to construct (script errors above)")
		_write_report()
		quit(2)
		return sim
	sim.new_game({"mode": mode, "seed": seed})
	sim.set_meta("decision_log", [])
	sim.set_meta("budget_log", [])
	sim.set_meta("fc_turns", [])
	say("")
	say("| Date | Pop (sim) | Pop (CBS, S119) | diff | Ghost pop | Cities | Techs | Civics | Events | Gold (net) | Water S/D | Standing | Trust | Readiness | Inflation (real) | City fit | Ahead | Errors |")
	say("|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|")
	var no_decision_turns := 0
	var loaded := false
	while not sim.state.game_over and sim.state.turn <= max_turn:
		var t := sim.state.turn
		_check_turn(sim, mode)
		var dec := int(sim.state.counters.get("decisions_" + str(t), 0))
		var blocking := sim.state.last_decisions.filter(func(d): return d.get("blocking", false)).size()
		if blocking < 1:
			no_decision_turns += 1
		if (SimDB.quarter_of(t) == 2 and (SimDB.year_of(t) % 5 == 3 or t == 1 or t == Sim.last_playable_turn())) or ("--yearly" in OS.get_cmdline_user_args() and SimDB.quarter_of(t) == 4):
			_row(sim)
		if is_ghost and max_turn >= Sim.last_playable_turn():
			for sc in SimEndgame.SCENARIOS:
				if t == SimEndgame.scenario_turn(str(sc["id"])) and SimEndgame.save_scenario_snapshot(sim, str(sc["id"])) == OK:
					say("scenario start %s written (data/scenarios/start_%s.json, %s)" % [sc["id"], sc["id"], sim.date_label()])
		if not is_ghost and t == 120 and not loaded:
			sim = _roundtrip(sim)
			loaded = true
		SimAI.play_turn(sim)
		sim.get_meta("budget_log").append([t, float(sim.state.counters.get("last_budget", {}).get("net", 0.0))])
		sim.get_meta("fc_turns").append([t, float(sim.state.counters.get("last_budget", {}).get("net", 0.0)), sim.state.inflation, sim.econ.economy_health()])
	_row(sim)
	if is_ghost:
		_ghost_calibration(sim)
		_fc_debt(sim, "ghost of history")
	else:
		_consequence_run_check(sim, mode)
	if no_decision_turns > 0:
		fail("%s: %d turns offered no blocking decision" % [mode, no_decision_turns])
	else:
		say("")
		say("%s: every turn offered at least one blocking decision (Next Action never skipped straight to Next Turn)." % mode)
	if not sim.state.game_over and max_turn >= Sim.last_playable_turn():
		fail("%s: game did not reach %s (stopped at turn %d)" % [mode, SimDB.date_label(Sim.last_playable_turn()), sim.state.turn])
	var fs: Dictionary = sim.state.counters.get("front_spawns", {})
	var never := []
	for wid in sim.db.wars:
		var w: Dictionary = sim.db.wars[wid]
		if not sim.state.fired_events.has(str(w.get("event", ""))):
			continue
		for fr in w.get("fronts", []):
			if int(fs.get("%s:%s" % [wid, fr["id"]], 0)) <= 0 and not fr.get("unit_types", []).has("missile_salvo"):
				never.append("%s:%s" % [wid, fr["id"]])
	say("")
	if never.is_empty():
		say("%s: every war front spawned at least once." % mode)
	else:
		say("%s: war fronts that never spawned (%d): %s" % [mode, never.size(), ", ".join(never)])
	for e in sim.state.errors.slice(0, 15):
		fail("%s sim error: %s" % [mode, e])
	return sim


func _ghost_calibration(sim: Sim) -> void:
	## V2: the ghost's population within 4% of the census years, and its treasury never negative for more than 8
	## consecutive turns.
	say("")
	say("### Ghost of history vs the census (CBS, real_series.json)")
	say("| Year | Ghost population | CBS | Difference | Within 4% |")
	say("|---|---|---|---|---|")
	var bad := 0
	for y in [1961, 1972, 1983, 1995, 2000, 2004, 2008, 2015, 2022]:
		var t := SimDB.turn_of("%d-05" % y, 1)
		if t > sim.state.history.size(): continue
		var gp := float(sim.state.history[t - 1]["v"].get("population", 0.0))
		var real := sim.db.real_value("population", SimDB.year_f(t))
		var d := (gp / maxf(1.0, real) - 1.0) * 100.0
		if absf(d) > 4.0: bad += 1
		say("| %d | %.3fM | %.3fM | %+.1f%% | %s |" % [y, gp / 1e6, real / 1e6, d, "yes" if absf(d) <= 4.0 else "NO"])
	var run := 0; var worst := 0; var worst_end := 0
	for h in sim.state.history:
		if float(h["v"].get("gold", 0.0)) < 0.0:
			run += 1
			if run > worst: worst = run; worst_end = int(h["t"])
		else:
			run = 0
	say("ghost treasury: longest run below zero %d turns%s (V2: at most 8)" % [worst, (" (to %s)" % SimDB.date_label(worst_end)) if worst > 0 else ""])
	if bad > 0:
		fail("ghost population more than 4%% off the census in %d of 9 check years" % bad)
	if worst > 8:
		fail("ghost treasury negative for %d consecutive turns (V2: at most 8)" % worst)


func _pacing(sim: Sim) -> void:
	## Pacing report: strategic decisions per turn for each decade under this run's (recommended) picks,
	## with and without the Cabinet Agenda. "Story" = event choices, forks, crisis/front responses,
	## policy reviews, immigration plans, dedications and (v2) the State Budget, its mid-year review, minister
	## titles and coalition deals; routine production/research/unit prompts are excluded.
	const STORY := ["event_choice", "fork", "crisis_response", "policy_review", "immigration", "dedication", "state_budget", "budget_review", "minister", "coalition", "diplomacy"]
	var decades := [[1948, 1955], [1956, 1965], [1966, 1975], [1976, 1985], [1986, 1995], [1996, 2005], [2006, 2015], [2016, 2023]]
	var per_turn := {}
	for e in sim.get_meta("decision_log"):
		var t := int(e[0]); var ty := str(e[1])
		if not per_turn.has(t): per_turn[t] = {"story": 0, "agenda": 0}
		if ty in STORY: per_turn[t]["story"] += 1
		elif ty == "agenda": per_turn[t]["agenda"] += 1
	say("")
	say("### Pacing (%s picks): strategic decisions per turn by decade" % str(sim.state.counters.get("ai_style", sim.state.mode)))
	say("| Decade | Turns | Story per turn | Story + agenda per turn | Turns with no story decision | Longest gap (turns) | Agenda share | V2 bar (>=1.5, <=25%, gap <=3) |")
	say("|---|---|---|---|---|---|---|---|")
	for dc in decades:
		var t0 := maxi(1, SimDB.turn_of("%d-01" % dc[0], 1)); var t1 := mini(sim.state.turn, SimDB.turn_of("%d-12" % dc[1], Sim.last_playable_turn()))
		if t1 < t0: continue
		var n := t1 - t0 + 1
		var st_ := 0; var ag := 0; var none := 0; var gap := 0; var run := 0
		for t in range(t0, t1 + 1):
			var r: Dictionary = per_turn.get(t, {"story": 0, "agenda": 0})
			st_ += int(r["story"]); ag += int(r["agenda"])
			if int(r["story"]) == 0:
				none += 1; run += 1; gap = maxi(gap, run)
			else:
				run = 0
		var ok := float(st_) / n >= 1.5 and float(none) / n <= 0.25 and gap <= 3
		say("| %d-%d | %d | %.2f | %.2f | %d (%.0f%%) | %d | %.0f%% | %s |" % [dc[0], dc[1], n, float(st_) / n, float(st_ + ag) / n, none, 100.0 * none / n, gap, 100.0 * ag / maxf(1, st_ + ag), "PASS" if ok else "FAIL"])


func _row(sim: Sim) -> void:
	var v := sim.score.values()
	var real := sim.db.real_value("population", SimDB.year_f(sim.state.turn))
	var g := sim.score.ghost_at(sim.state.turn)
	var cur := sim.score.current()
	var diff := "" if real <= 0 else "%+.0f%%" % ((v["population"] / real - 1.0) * 100.0)
	var infl_real := sim.inflation_baseline(SimDB.year_f(sim.state.turn))
	var fit: Dictionary = sim.econ.census_fit(SimDB.year_f(sim.state.turn))
	say("| %s | %s | %s | %s | %s | %d | %d | %d | %d | %s | %s | %.0f | %.0f | %.0f | %s | %s | %s | %d |" % [sim.date_label(), _m(v["population"]), _m(real) if real > 0 else "-", diff,
		_m(float(g.get("population", 0))) if not g.is_empty() else "-", v["cities"], sim.state.techs.size(), sim.state.civics.size(),
		sim.state.fired_events.size(), "%d (%+d)" % [int(sim.state.gold), int(sim.state.counters.get("last_budget", {}).get("net", 0))], "%d/%d" % [int(sim.state.water.get("supply", 0)), int(sim.state.water.get("demand", 0))], sim.state.standing, v["cohesion"], sim.state.readiness,
		"%.0f%% (%.0f%%)" % [sim.state.inflation, infl_real], "%.0f%%" % (fit["mae"] * 100.0),
		("%d/6" % cur["ahead"]) if cur["has_ghost"] else "-", sim.state.errors.size()])


func _n(x: float) -> String:
	if absf(x) >= 1.0e6: return "%.2fM" % (x / 1.0e6)
	if absf(x) >= 1000.0: return "%.0f" % x
	return "%.2f" % x


func _m(x: float) -> String:
	return "%.2fM" % (x / 1.0e6)


func _check_turn(sim: Sim, mode: String) -> void:
	var st := sim.state
	if is_nan(st.gold) or is_inf(st.gold):
		fail("%s T%d gold is not finite" % [mode, st.turn])
	var border: Dictionary = sim.db.border_set(st.turn)
	for c in sim.active_cities():
		if is_nan(c.residents) or c.residents <= 0:
			fail("%s T%d %s has residents %s" % [mode, st.turn, c.name, c.residents])
		if c.trust < 0 or c.trust > 100:
			fail("%s T%d %s trust out of range" % [mode, st.turn, c.name])
	if st.turn % 20 == 0 and not border.is_empty():
		for k in st.tiles:
			if int(st.tiles[k].get("o", 0)) > 0 and not border.has(k) and sim.city_at(SimHex.from_key(k)) == null:
				fail("%s T%d tile %s owned outside the lines of control" % [mode, st.turn, SimHex.from_key(k)])
				break
	if st.turn % 40 == 0:
		var tot := sim.total_residents()
		var real := sim.db.real_value("population", SimDB.year_f(st.turn))
		if real > 0 and absf(tot / real - 1.0) > 0.35:
			fail("%s T%d population %.2fM is more than 35%% off the CBS figure %.2fM" % [mode, st.turn, tot / 1e6, real / 1e6])


func _roundtrip(sim: Sim) -> Sim:
	var path := "user://sim_test_save.json"
	if not sim.save_game(path):
		fail("save failed")
		return sim
	var s2 := Sim.new()
	if not s2.load_game(path):
		fail("load failed")
		return sim
	var a := sim.score.values(); var b := s2.score.values()
	for k in ["population", "science", "standing", "cities"]:
		if absf(float(a[k]) - float(b[k])) > 0.01 * maxf(1.0, absf(float(a[k]))):
			fail("save/load mismatch on %s: %s vs %s" % [k, a[k], b[k]])
	for m in ["decision_log", "budget_log", "fc_turns"]:
		if sim.has_meta(m): s2.set_meta(m, sim.get_meta(m))
	if s2.state.cities.size() != sim.state.cities.size() or s2.state.units.size() != sim.state.units.size():
		fail("save/load mismatch on cities/units")
	say("")
	say("save/load round trip at %s: OK (%d cities, %d units) - continuing with the loaded game" % [sim.date_label(), s2.state.cities.size(), s2.state.units.size()])
	say("")
	sim.dispose()
	return s2


func _final(sim: Sim) -> void:
	var st := sim.state
	var sm := sim.score.final_summary()
	say("")
	say("### Final standing vs the ghost (%s)" % sm["date"])
	for t in sm["tracks"]:
		var lab: Dictionary = t["label"]
		var ls := ""
		if not lab.is_empty():
			ls = " (history %s vs you %s %s)" % [_n(lab["history"]), _n(lab["player"]), lab["unit"]]
		say("- %s: you %s, ghost %s -> %.0f%%%s" % [t["name"], _n(t["player"]), _n(t["ghost"]), t["ratio"] * 100.0, ls])
	say("- Verdict: " + str(sm["verdict"]))
	say("")
	say("Itemised reasons:")
	for r in sm["reasons"]:
		say("- [%s] %s" % [r["track"], r["text"]])
	say("")
	say("### Run statistics")
	var pf := 0; var hf := 0; var rf := 0
	for c in st.cities:
		if c.founded_by == "player": pf += 1
		elif c.founded_by == "rails": rf += 1
		else: hf += 1
	say("cities ever %d (active %d): %d founded by player settlers, %d on historical dates, %d by rails after the window closed" % [st.cities.size(), sim.active_cities().size(), pf, hf, rf])
	var early := []
	for c in st.cities:
		if c.founded_by == "player":
			early.append("%s %+d turns" % [c.name, c.hist_founded_turn - c.founded_turn])
	if early.size() > 0:
		say("player-founded towns vs historical date: " + ", ".join(early.slice(0, 12)))
	say("techs %d/%d, civics %d/%d, boosts %d, national projects %d, timeline moments %d" % [st.techs.size(), sim.db.tech_list.size(), st.civics.size(), sim.db.civic_list.size(), st.boosts.size(), st.projects.size(), st.timeline.size()])
	say("events fired %d/%d, event choices made %d (counterfactual %d), crises %d" % [st.fired_events.size(), sim.db.events.size(), st.choices_made.size(), int(st.counters.get("counterfactual_choices", 0)), st.crisis_log.size()])
	say("units killed %d, units lost %d, rural residents %.0f, immigrants absorbed %.0f, inflation %.1f%%" % [st.unit_kills, st.units_lost, st.rural, float(st.counters.get("immigrants_absorbed", 0)), st.inflation])
	var biggest := sim.active_cities()
	biggest.sort_custom(func(a, b): return a.residents > b.residents)
	var bl := []
	for c in biggest.slice(0, 8):
		var real := sim.db.city_pop_at(sim.db.city_by_id.get(c.key, {}), SimDB.year_f(st.turn))
		bl.append("%s %dk (pop %d; census %dk)" % [c.name, int(c.residents / 1000), c.pop(), int(real / 1000)])
	say("largest cities: " + ", ".join(bl))
	if sim.has_meta("decision_log"):
		_pacing(sim)
		_fc_pacing_core(sim)
		_fc_pick_shares(sim)
		_diplo_report([sim], ["ghost" if sim.state.mode == "historical" else str(sim.state.counters.get("ai_style", "player"))])
		_fc_debt(sim, "player run")
		_fc_arc([sim], ["player"])
		_eg_endings_report([sim], [str(sim.state.counters.get("ai_style", "recommended"))])
		var strategic := ["event_choice", "crisis_response", "immigration", "dedication", "fill_policy", "choose_research", "choose_civic", "agenda"]
		var per := {}; var by := {}; var turns := 0
		for e in sim.get_meta("decision_log"):
			if SimDB.year_of(int(e[0])) <= 1955 and str(e[1]) in strategic:
				per[int(e[0])] = int(per.get(int(e[0]), 0)) + 1
				by[str(e[1])] = int(by.get(str(e[1]), 0)) + 1
		for t in range(1, SimDB.turn_of("1955-12", 31) + 1):
			if t <= st.turn: turns += 1
		var none := 0
		for t in range(1, turns + 1):
			if int(per.get(t, 0)) == 0: none += 1
		var tot := 0
		for k in by: tot += int(by[k])
		say("strategic decisions 1948-55: %.2f per turn over %d turns (%d turns with none); by type: %s" % [float(tot) / maxf(1, turns), turns, none, ", ".join(by.keys().map(func(k): return "%s %d" % [k, by[k]]))])
		var nets := []
		for h in sim.get_meta("budget_log"):
			if SimDB.year_of(int(h[0])) >= 1949 and SimDB.year_of(int(h[0])) <= 1952: nets.append(float(h[1]))
		if nets.size() > 0:
			nets.sort()
			say("net gold per turn 1949-52: min %+.0f, median %+.0f, max %+.0f; placement choices: %s" % [nets[0], nets[nets.size() / 2], nets[nets.size() - 1],
				", ".join(st.counters.keys().filter(func(k): return str(k).begins_with("imm_plan_")).map(func(k): return "%s %d" % [str(k).substr(9), st.counters[k]]))])
			var lb: Dictionary = st.counters.get("last_budget", {})
			say("last budget: " + ", ".join(lb.keys().map(func(k): return "%s %.0f" % [k, float(lb[k])])))
	var rp: Dictionary = st.counters.get("readiness_parts", {})
	var ip: Dictionary = st.counters.get("inflation_parts", {})
	say("readiness: capacity %.0f vs requirement %.0f (era %d) -> base %.0f, lessons %+.0f, strain %.0f; inflation: history %.1f%%, player gap %+.2f log points" % [float(rp.get("capacity", 0)), float(rp.get("requirement", 0)), st.era, float(rp.get("base", 0)), float(rp.get("lessons", 0)), float(rp.get("strain", 0)), float(ip.get("history", 0)), float(ip.get("gap", 0))])
	var fit: Dictionary = sim.econ.census_fit(SimDB.year_f(st.turn))
	say("city sizes vs census paths: weighted mean error %.1f%%; largest gaps: %s" % [fit["mae"] * 100.0, ", ".join(fit["worst"].map(func(w): return "%s %dk vs %dk" % [w["name"], int(w["res"] / 1000), int(w["census"] / 1000)]))])
	for cr in st.crisis_log.slice(0, 30):
		say("crisis %s %s-%s: response %s, hostile destroyed %d, units lost %d, city hits %d, intercepts %d, readiness %+d" % [cr["title"], SimDB.date_label(int(cr["start"])), SimDB.date_label(int(cr["end"])), cr["response"], cr["hostile_destroyed"], cr["player_lost"], cr["city_hits"], cr["intercepts"], int(cr["readiness_change"])])
	var avg_dec := 0.0
	var n := 0
	for k in st.counters:
		if str(k).begins_with("decisions_"):
			avg_dec += float(st.counters[k]); n += 1
	say("average open decisions per turn %.1f; agenda items chosen: %s" % [avg_dec / maxf(1, n), ", ".join(st.counters.keys().filter(func(k): return str(k).begins_with("agenda_") and typeof(st.counters[k]) in [TYPE_INT, TYPE_FLOAT]).map(func(k): return "%s %d" % [str(k).substr(7), int(st.counters[k])]))])
	if not st.game_over:
		return
	var pop := sim.total_residents()
	if pop < 7.0e6 or pop > 13.0e6:
		fail("final population %.2fM is implausible against the CBS 2023 figure (9.80M)" % (pop / 1e6))
	if st.techs.size() < 30:
		fail("only %d techs by the end" % st.techs.size())
	var due_events := sim.db.events.filter(func(e): return int(e["_turn"]) <= Sim.last_playable_turn()).size()   # events dated before the game's end
	if st.fired_events.size() < due_events - 5:
		fail("only %d of %d events (dated up to %s) fired" % [st.fired_events.size(), due_events, SimDB.date_label(Sim.last_playable_turn())])
	if sim.active_cities().size() < 60:
		fail("only %d active cities" % sim.active_cities().size())


func _write_report(res_path := "res://scripts/sim/AUTOPLAY_REPORT.md") -> void:
	var p := ProjectSettings.globalize_path(res_path)
	var f := FileAccess.open(p, FileAccess.WRITE)
	if f != null:
		f.store_string("\n".join(out_lines) + "\n")


# ------------------------------------------------------------------ fix-cabinet reports (v2 fixes)

const FC_RECURRING := ["state_budget", "budget_review", "immigration", "minister", "coalition", "programme"]


func _fc_pacing_core(sim: Sim) -> void:
	## Core story pacing (V2 bar: >= 1.2 per turn, <= 30% empty, per decade): forks, choice events, crises and war
	## fronts, immigration, policy reviews, coalition, dedications - NOT minister, state budget or budget review.
	## Also the minister menu count per turn (V2 bar: at most one).
	const CORE := ["event_choice", "fork", "crisis_response", "policy_review", "immigration", "dedication", "coalition", "diplomacy"]
	var decades := [[1948, 1955], [1956, 1965], [1966, 1975], [1976, 1985], [1986, 1995], [1996, 2005], [2006, 2015], [2016, 2023]]
	var per_turn := {}
	var mins := {}
	for e in sim.get_meta("decision_log"):
		var t := int(e[0]); var ty := str(e[1])
		if ty in CORE: per_turn[t] = int(per_turn.get(t, 0)) + 1
		if ty == "minister": mins[t] = int(mins.get(t, 0)) + 1
	say("")
	say("### Core story pacing (%s picks): without minister, budget and review" % str(sim.state.counters.get("ai_style", sim.state.mode)))
	say("| Decade | Turns | Core per turn | Turns with no core decision | Longest gap | Minister menus | Turns with 2+ minister menus | Core bar (>=1.2, <=30%) |")
	say("|---|---|---|---|---|---|---|---|")
	var worst_min := 0
	for dc in decades:
		var a := maxi(1, SimDB.turn_of("%d-01" % dc[0], 1)); var b := mini(sim.state.turn, SimDB.turn_of("%d-12" % dc[1], Sim.last_playable_turn()))
		if b < a: continue
		var n := b - a + 1
		var tot := 0; var none := 0; var gap := 0; var run := 0; var mn := 0; var multi := 0
		for t in range(a, b + 1):
			var k := int(per_turn.get(t, 0))
			tot += k
			if k == 0:
				none += 1; run += 1; gap = maxi(gap, run)
			else:
				run = 0
			mn += int(mins.get(t, 0))
			if int(mins.get(t, 0)) > 1: multi += 1
			worst_min = maxi(worst_min, int(mins.get(t, 0)))
		var ok := float(tot) / n >= 1.2 and float(none) / n <= 0.30
		say("| %d-%d | %d | %.2f | %d (%.0f%%) | %d | %d | %d | %s |" % [dc[0], dc[1], n, float(tot) / n, none, 100.0 * none / n, gap, mn, multi, "PASS" if ok else "below bar"])
	say("most minister menus in one turn: %d (V2 bar: 1)" % worst_min)
	if worst_min > 1:
		fail("the minister menu opened %d times in one turn (V2: at most once)" % worst_min)


func _fc_pick_shares(sim: Sim) -> void:
	## V2 bar: no recurring decision has the same Recommended pick in more than 50% of its appearances.
	var by := {}
	for e in sim.get_meta("decision_log"):
		if e.size() < 3: continue
		var ty := str(e[1])
		var key := str(e[2])
		if ty == "agenda":
			var parts := key.split(" -> ")
			ty = "agenda: " + parts[0]
			key = parts[1] if parts.size() > 1 else ""
		elif not (ty in FC_RECURRING):
			continue
		if not by.has(ty): by[ty] = {"n": 0, "keys": {}}
		by[ty]["n"] += 1
		for k in key.split(","):
			if k == "": continue
			by[ty]["keys"][k] = int(by[ty]["keys"].get(k, 0)) + 1
	say("")
	say("### Recommended-pick shares per recurring decision (V3 bar: no pick Recommended in more than 45% of appearances)")
	say("| Decision | Appearances | Distinct recommended picks | Most recommended | Share | Bar |")
	say("|---|---|---|---|---|---|")
	var keys := by.keys()
	keys.sort()
	for ty in keys:
		var r: Dictionary = by[ty]
		var top := ""; var tn := 0
		for k in r["keys"]:
			if int(r["keys"][k]) > tn: tn = int(r["keys"][k]); top = str(k)
		var share := float(tn) / maxf(1.0, float(r["n"]))
		var mine: bool = str(ty) in FC_RECURRING or str(ty) == "agenda: Budget deficit"
		var ok := share <= (0.45 if str(ty) in FC_RECURRING else 0.5) or int(r["n"]) < 4
		say("| %s | %d | %d | %s | %.0f%% | %s |" % [ty, r["n"], r["keys"].size(), top, share * 100.0, "PASS" if ok else ("FAIL" if mine else "over 50% (agenda item)")])
		if not ok and mine:
			fail("recurring decision %s: '%s' Recommended in %.0f%% of %d appearances (V3: at most 45%%)" % [ty, top, share * 100.0, r["n"]])


func _fc_debt(sim: Sim, label: String) -> void:
	var d: Dictionary = sim.get_debt()
	var neg := 0; var run := 0; var worst := 0; var infl_max := 0.0; var infl_y := 0; var health_min := 1.0; var hy := 0
	var deficits := 0
	for h in sim.state.history:
		if float(h["v"].get("gold", 0.0)) < 0.0:
			neg += 1; run += 1; worst = maxi(worst, run)
		else:
			run = 0
	for e in sim.get_meta("fc_turns", []):
		if float(e[2]) > infl_max: infl_max = float(e[2]); infl_y = SimDB.year_of(int(e[0]))
		if float(e[3]) < health_min: health_min = float(e[3]); hy = SimDB.year_of(int(e[0]))
		if float(e[1]) < 0.0: deficits += 1
	say("")
	say("### Debt report (%s)" % label)
	say("- borrowed %s gold in %d loans; interest paid %s; repaid early %s; peak debt %s; debt at the end %s (lenders' limit %s)" % [_n(float(d["borrowed_total"])), int(d["borrow_count"]),
		_n(float(d["interest_total"])), _n(float(d["repaid_early"])), _n(float(d["debt_peak"])), _n(float(d["debt"])), _n(float(d["cap"]))])
	say("- net gold negative in %d of %d turns; treasury below zero in %d turns (longest run %d); final treasury %s" % [deficits, sim.get_meta("fc_turns", []).size(), neg, worst, _n(sim.state.gold)])
	say("- peak inflation %.0f%% in %d (history that year %.0f%%); lowest economy-health factor %.2f in %d; at the end %.2f" % [infl_max, infl_y,
		sim.inflation_baseline(float(infl_y) + 0.5), health_min, hy, float(d["health"])])
	var rails: Array = d.get("open_rails", [])
	say("- open deficit rails at the end: %s" % (", ".join(rails.map(func(r): return "%s (%d/turn; %s)" % [r["label"], int(r["amount"]), r["ends"]])) if not rails.is_empty() else "none"))
	for s in sim.state.streams:
		if s.has("ends_with_policy"):
			say("- rail \"%s\": %s-%s" % [s.get("label", ""), SimDB.date_label(int(s.get("from", 0))), SimDB.date_label(mini(int(s.get("until", 0)), Sim.last_playable_turn()))])


static func _fc_overall(h: Dictionary) -> float:
	## Overall score at a history sample: mean of 100 x player/ghost per track, clamped 0-200 (as SimScore.current).
	if not h.has("g"): return 100.0
	var tot := 0.0
	for t in SimScore.TRACKS:
		var gv := float(h["g"].get(t["id"], 0.0))
		var pv := float(h["v"].get(t["id"], 0.0))
		tot += clampf(100.0 * pv / gv, 0.0, 200.0) if gv > 0.0 else 100.0
	return tot / SimScore.TRACKS.size()


func _fc_arc(sims: Array, names: Array) -> void:
	## The arc: overall score against the ghost every five years (V2 fixes: a climax, not a slide from the 1960s).
	say("")
	say("### The arc: overall score vs the ghost (%s)" % ", ".join(names))
	var head := "| Year |"
	var sep := "|---|"
	for n in names:
		head += " %s overall | %s tracks (pop/econ/sci/water/stand/coh) |" % [n, n]
		sep += "---|---|"
	say(head)
	say(sep)
	for y in [1950, 1955, 1960, 1965, 1970, 1975, 1980, 1985, 1990, 1995, 2000, 2005, 2010, 2015, 2020, AT_END]:
		var t := SimDB.turn_of("%d-05" % y, 1) if y < AT_END else Sim.last_playable_turn()
		if y < AT_END and t > Sim.last_playable_turn(): continue
		var row := "| %d |" % (y if y < AT_END else SimDB.year_of(t))
		for s in sims:
			if t > s.state.history.size():
				row += " - | - |"
				continue
			var h: Dictionary = s.state.history[t - 1]
			var rs := []
			for tr in SimScore.TRACKS:
				var gv := float(h.get("g", {}).get(tr["id"], 0.0))
				rs.append("%.2f" % (float(h["v"].get(tr["id"], 0.0)) / gv if gv > 0.0 else 1.0))
			row += " %.0f%% | %s |" % [_fc_overall(h), "/".join(rs)]
		say(row)


# ------------------------------------------------------------------ v3 diplomacy report (sim-diplomacy)

func _diplo_report(sims: Array, names: Array) -> void:
	## Relations per actor per decade, deals taken, envoy decisions and their Recommended picks (V3 bar: no pick
	## above 45%), patrons' leverage, and each actor's legal status against its real timeline.
	say("")
	say("### Diplomacy (%s)" % ", ".join(names))
	var decs := ["1950", "1960", "1970", "1980", "1990", "2000", "2010", "2020", "end"]
	for i in range(sims.size()):
		var sm: Sim = sims[i]
		var dd: Dictionary = sm.state.diplo
		var samples: Dictionary = dd.get("samples", {})
		say("")
		say("Relations by decade (%s picks; - = not yet a partner):" % names[i])
		say("| Actor | " + " | ".join(decs) + " |")
		say("|---|" + "---|".repeat(decs.size()))
		var actors: Array = SimDiplomacy.data().get("order", sm.state.diplomacy.keys())
		for a in actors:
			if not sm.state.diplomacy.has(a): continue
			var row := []
			for y in decs:
				var smp: Dictionary = samples.get(y, {})
				row.append("%+d" % int(round(float(smp[a]))) if smp.has(a) else "-")
			say("| %s | %s |" % [sm.diplo.actor_name(a), " | ".join(row)])
		var deals: Dictionary = dd.get("deals", {})
		var dl := []
		for id in deals:
			dl.append("%s x%d" % [id, (deals[id] as Array).size()])
		say("")
		say("%s: deals taken %d (%s); by kind: %s" % [names[i], dl.size(), ", ".join(dl) if dl.size() > 0 else "none", str(dd.get("counts", {}))])
		var env: Dictionary = dd.get("envoys", {})
		var answered := 0; var skipped := 0; var nonhist := 0
		for k in env:
			if str(env[k]) == "skipped": skipped += 1
			else: answered += 1
		nonhist = int(sm.state.counters.get("diplo_counterfactual", 0))
		var ans := []
		for k in env:
			if str(env[k]) != "skipped": ans.append("%s:%s" % [k, env[k]])
		say("%s: envoy answers: %s" % [names[i], ", ".join(ans)])
		say("%s: envoy decisions answered %d (%d not as history did), scripted envoys never offered %d; patrons' leverage that bit: %d; exposure now: %s" % [
			names[i], answered, nonhist, skipped, int(sm.state.counters.get("diplo_leverage_hits", 0)),
			", ".join(dd.get("exposure", {}).keys().map(func(a): return "%s %.1f" % [a, sm.diplo.exposure(a)]))])
		if sm.state.errors.size() == 0 and answered == 0 and sm.state.game_over:
			fail("%s: no diplomatic decision was ever offered" % names[i])
		# the recurring decision's Recommended picks
		if sm.has_meta("decision_log"):
			var by := {}; var n := 0
			for e in sm.get_meta("decision_log"):
				if str(e[1]) != "diplomacy" or e.size() < 3: continue
				n += 1
				by[str(e[2])] = int(by.get(str(e[2]), 0)) + 1
			var top := ""; var tn := 0
			for k in by:
				if int(by[k]) > tn: tn = int(by[k]); top = str(k)
			var share := float(tn) / maxf(1.0, float(n))
			say("%s: diplomatic decisions %d; Recommended picks by option: %s; most common '%s' %.0f%% (V3 bar: at most 45%%)" % [names[i], n, str(by), top, share * 100.0])
			# the bar is about the Recommended badge in play: checked on the player (Recommended) and varied runs
			if n >= 8 and share > 0.45 and not (names[i] in ["ghost", "historical"]):
				fail("%s: the diplomatic decision recommends '%s' in %.0f%% of %d appearances (V3: at most 45%%)" % [names[i], top, share * 100.0, n])
		# legal statuses against the real timelines
		var pc: Dictionary = dd.get("phase_check", {})
		var bad := []
		var checked := 0; var mism := 0
		for a in pc:
			checked += int(pc[a]["n"]); mism += int(pc[a]["bad"])
			if int(pc[a]["bad"]) > 0:
				bad.append("%s %d/%d (%s)" % [a, pc[a]["bad"], pc[a]["n"], "; ".join(pc[a]["ex"])])
		say("%s: statuses against history: %d actor-years checked, %d off the real timeline%s" % [names[i], checked, mism, (": " + ", ".join(bad)) if bad.size() > 0 else ""])
		for a in pc:
			# only the historical-picks run must follow the real timelines (a player's forks can change them)
			if names[i] == "historical" and int(pc[a]["n"]) >= 4 and float(pc[a]["bad"]) / float(pc[a]["n"]) > 0.10:
				fail("%s: %s's legal status is off its real timeline in %d of %d years (%s)" % [names[i], a, pc[a]["bad"], pc[a]["n"], "; ".join(pc[a]["ex"])])


# ------------------------------------------------------------------ v3 reports (sim-endgame): endings, strategies, difficulty, scenarios

const AT_END := 9999   # "the end": the last turn played (Q3 2023 by default)
const EG_DECADES := [1955, 1965, 1975, 1985, 1995, 2005, 2015, 2020, AT_END]
const EG_STRATEGISTS := ["strategist_security", "strategist_prosperity", "strategist_peace", "strategist_society"]


func _eg_modes(args: Array, seed: int, max_turn: int) -> bool:
	## Extra sim_test modes (each writes its own report and quits):
	##   --strategies     historical, varied and the four strategists: endings, arcs, spread, no dominant strategy
	##   --difficulty     the Recommended player at Easy, Normal, Hard and Historian
	##   --scenario-test  each scenario start (1967, 1977, 1992) loads and plays 6 turns
	var mode := ""
	for a in args:
		if a in ["--strategies", "--difficulty", "--scenario-test", "--collapse", "--goals", "--casual"]: mode = a
	if mode == "":
		return false
	match mode:
		"--casual":
			_casual_suite(seed, max_turn, args)   # V4 (v4-sim-auto): story mode, ministers on auto
			_write_report("res://scripts/sim/CASUAL_REPORT.md")
		"--strategies":
			_eg_strategies(seed, max_turn)
			_write_report("res://scripts/sim/STRATEGY_REPORT.md")
		"--difficulty":
			_eg_difficulty(seed, max_turn)
			_write_report("res://scripts/sim/DIFFICULTY_REPORT.md")
		"--scenario-test":
			_eg_scenarios()
			_write_report("res://scripts/sim/SCENARIO_REPORT.md")
		"--collapse":
			_collapse_report(seed, max_turn)
			_write_report("res://scripts/sim/COLLAPSE_REPORT.md")
		"--goals":
			SimTestGoals.run(self, seed, max_turn, args)   # V4 (v4-goals): sim_test_goals.gd
			_write_report("res://scripts/sim/GOALS_REPORT.md")
	say("")
	say("## Result")
	say("elapsed %.1f s, failures %d" % [(Time.get_ticks_msec() - t0) / 1000.0, failures.size()])
	for f in failures.slice(0, 40):
		say("- " + f)
	if failures.is_empty():
		say("ALL INVARIANTS PASSED")
	_write_report({"--strategies": "res://scripts/sim/STRATEGY_REPORT.md", "--difficulty": "res://scripts/sim/DIFFICULTY_REPORT.md", "--scenario-test": "res://scripts/sim/SCENARIO_REPORT.md", "--collapse": "res://scripts/sim/COLLAPSE_REPORT.md", "--goals": "res://scripts/sim/GOALS_REPORT.md", "--casual": "res://scripts/sim/CASUAL_REPORT.md"}[mode])
	quit(0 if failures.is_empty() else 1)
	return true


func _eg_overall_at(sim: Sim, year: int) -> float:
	var t := SimDB.turn_of("%d-05" % year, 1) if year < AT_END else sim.state.history.size()
	if year == 2023: t = SimDB.turn_of("2023-08", 1)
	if t > sim.state.history.size() or t < 1:
		return -1.0
	return _fc_overall(sim.state.history[t - 1])


func _eg_endings_report(sims: Array, names: Array) -> void:
	## Which ending each autoplayer reaches, every ending's progress, and the arc per decade.
	say("")
	say("### Endings reached (%s)" % ", ".join(names))
	say("| Autoplayer | Ending | Also met | Secure | Prosperous | Peace | United | Overall 1965 | Overall at the end | Programme levels (sec/pros/peace/soc) | Treaties |")
	say("|---|---|---|---|---|---|---|---|---|---|---|")
	for i in range(sims.size()):
		var sm: Sim = sims[i]
		var en: Dictionary = sm.get_endings()
		var pr := {}
		for e in en["endings"]:
			pr[e["id"]] = "%d/%d (%.0f%%)%s" % [int(e["criteria_met"]), e["criteria"].size(), float(e["progress"]) * 100.0, " MET" if e["met"] else ""]
		var fe: Dictionary = sm.endgame.final_ending()
		var gl := []
		for g in ["security", "prosperity", "peace", "society"]: gl.append(str(sm.endgame.group_levels(g)))
		say("| %s | %s | %s | %s | %s | %s | %s | %.0f%% | %.0f%% | %s | %d |" % [names[i], fe["name"], ", ".join(fe["also"]) if not fe["also"].is_empty() else "-",
			pr.get("secure_state", "-"), pr.get("prosperous_state", "-"), pr.get("peace_with_neighbours", "-"), pr.get("united_society", "-"),
			_eg_overall_at(sm, 1965), float(sm.score.current()["overall"]), "/".join(gl), sm.endgame.treaties().size()])
	for i in range(sims.size()):
		var sm2: Sim = sims[i]
		var en2: Dictionary = sm2.get_endings()
		say("")
		say("%s, criteria at the end:" % names[i])
		for e in en2["endings"]:
			say("- %s: %s" % [e["name"], "; ".join(e["criteria"].map(func(c): return "%s%s" % [c["text"], " ok" if c["met"] else " MISSED"]))])
		var ep: Dictionary = sm2.get_epilogue()
		say("epilogue (%s): %s" % [ep["name"], " / ".join(ep["paragraphs"].slice(0, 3).map(func(p): return str(p["text"]).substr(0, 220)))])
		var lg: Dictionary = sm2.endgame.legacy()
		say("track gains from programmes at the end: %s; gold spent on programmes %.0f" % [", ".join(lg.keys().map(func(k): return "%s %+.1f%%" % [k, float(lg[k])])), float(sm2.endgame.eg().get("spent", 0.0))])
		var clg: Dictionary = sm2.endgame.choice_legacy_vs_history()   # v3 fix3-econ (A7)
		say("lasting mark of the cabinet's choices against history's at the end: %s" % ", ".join(clg.keys().map(func(k): return "%s %+.1f" % [k, float(clg[k])])))
		var hp: Dictionary = sm2.score.health()   # v3 fix3-econ: what weighs the headline overall
		if not hp["parts"].is_empty(): say("state's health at the end: " + str(hp["text"]))
		var fi: Dictionary = sm2.get_fiscal_indicator()
		var fb: Dictionary = sm2.get_food_balance()
		say("fiscal indicator: %s (%s); food: %s, imports %.0f, exports %.0f gold a quarter" % [fi["label"], fi["level"], fb["label"], float(fb["imports_gold"]), float(fb["exports_gold"])])
		_collapse_line(sm2, str(names[i]))
	_eg_arc(sims, names)


func _eg_arc(sims: Array, names: Array) -> void:
	say("")
	say("### The arc per decade: overall score vs the ghost (%s)" % ", ".join(names))
	var head := "| Autoplayer |"
	var sep := "|---|"
	for y in EG_DECADES:
		head += (" %d |" % y) if y < AT_END else " end |"
		sep += "---|"
	say(head + " end vs 1965 |")
	say(sep + "---|")
	for i in range(sims.size()):
		var row := "| %s |" % names[i]
		for y in EG_DECADES:
			row += " %.0f%% |" % _eg_overall_at(sims[i], y)
		row += " %+.1f |" % (_eg_overall_at(sims[i], AT_END) - _eg_overall_at(sims[i], 1965))
		say(row)


func _eg_strategies(seed: int, max_turn: int) -> void:
	## V3 items 2 and 5: the strategists (one per ending) against history's picks and the varied cabinet.
	## Bars: a player who plays well ends above its 1965 lead; opposite strategies end >= 10 points apart overall;
	## no single dominant strategy (none is best on 5+ of the 6 tracks AND reaches every other strategist's ending).
	say("")
	say("## Strategy report (historical, varied and four strategists, to %s)" % SimDB.date_label(mini(max_turn, Sim.last_playable_turn())))
	var names := ["historical", "varied"] + EG_STRATEGISTS
	var sims := []
	for n in names:
		var sm := _run_style(n, seed, max_turn)
		sims.append(sm)
		say("- %s: overall %.1f%% at %s, ending %s (%d errors)" % [n, float(sm.score.current()["overall"]), sm.date_label(), sm.endgame.final_ending()["name"], sm.state.errors.size()])
		for e in sm.state.errors.slice(0, 5):
			fail("%s sim error: %s" % [n, e])
	say("")
	say("### Final tracks vs the ghost")
	say("| Autoplayer | Overall | " + " | ".join(SimScore.TRACKS.map(func(t): return str(t["id"]))) + " |")
	say("|---|---|" + "---|".repeat(SimScore.TRACKS.size()))
	var ratios := []
	for i in range(sims.size()):
		var r: Dictionary = sims[i].score.current_ratios()
		ratios.append(r)
		say("| %s | %.1f%% | %s |" % [names[i], float(sims[i].score.current()["overall"]), " | ".join(SimScore.TRACKS.map(func(t): return "%.2f" % float(r[t["id"]])))])
	_eg_endings_report(sims, names)
	# spread between opposite strategies
	var ov := sims.map(func(sm): return float(sm.score.current()["overall"]))
	var lo := 1e9; var hi := -1e9; var lo_n := ""; var hi_n := ""
	for i in range(sims.size()):
		if ov[i] < lo: lo = ov[i]; lo_n = names[i]
		if ov[i] > hi: hi = ov[i]; hi_n = names[i]
	say("")
	say("Overall spread: historical %.1f vs varied %.1f (%+.1f); widest %s %.1f vs %s %.1f (%+.1f)" % [ov[0], ov[1], ov[1] - ov[0], hi_n, hi, lo_n, lo, hi - lo])
	if hi - lo < 10.0:
		fail("strategies: the widest spread between strategies is %.1f points (V3 needs 10)" % (hi - lo))
	# a player who plays well ends above its 1965 lead
	var best_gain := -1e9; var best_n := ""
	for i in range(2, sims.size()):
		var gain := _eg_overall_at(sims[i], AT_END) - _eg_overall_at(sims[i], 1965)
		say("%s: 1965 %.0f%%, at the end %.0f%% (%+.1f)" % [names[i], _eg_overall_at(sims[i], 1965), _eg_overall_at(sims[i], AT_END), gain])
		if gain > best_gain: best_gain = gain; best_n = names[i]
	if best_gain <= 0.0:
		fail("climax: no strategist ends above its 1965 overall (best %s %+.1f)" % [best_n, best_gain])
	# no dominant strategy
	var endings := sims.map(func(sm): return str(sm.endgame.final_ending()["id"]))
	var distinct := {}
	for e in endings: distinct[e] = true
	say("endings reached: %s (%d distinct)" % [", ".join(range(sims.size()).map(func(i): return "%s=%s" % [names[i], endings[i]])), distinct.size()])
	for i in range(sims.size()):
		var best_on := 0
		for t in SimScore.TRACKS:
			var mine := float(ratios[i][t["id"]])
			var top := true
			for j in range(sims.size()):
				if j != i and float(ratios[j][t["id"]]) > mine: top = false
			if top: best_on += 1
		var reach: Array = sims[i].get_endings()["reached"]
		var covers := true
		for j in range(2, sims.size()):
			if j != i and endings[j] != "mixed_record" and not reach.has(endings[j]): covers = false
		say("%s: best on %d of 6 tracks; reaches %s" % [names[i], best_on, ", ".join(reach) if not reach.is_empty() else "no ending"])
		if best_on >= 5 and covers:
			fail("strategies: %s dominates (best on %d of 6 tracks and reaches every other strategist's ending)" % [names[i], best_on])
	if distinct.size() < 3:
		fail("strategies: only %d distinct endings reached by the six autoplayers (V3: the endings must differ by strategy)" % distinct.size())
	var sdist := {}
	for i in range(names.size()):
		if str(names[i]).begins_with("strategist_"): sdist[str(endings[i])] = true
	if sdist.size() < EG_STRATEGISTS.size():
		fail("strategies: the four strategists reach only %d distinct endings (fix3-econ: each keeps its own)" % sdist.size())
	for sm in sims:
		sm.dispose()


func _eg_difficulty(seed: int, max_turn: int) -> void:
	## V3 item 5: the Recommended player at each difficulty.
	say("")
	say("## Difficulty report (the Recommended player, to %s)" % SimDB.date_label(mini(max_turn, Sim.last_playable_turn())))
	say("| Difficulty | Overall 1965 | Overall at the end | Ahead | Ending | Treasury at the end | Peak inflation | Units lost | Town strikes |")
	say("|---|---|---|---|---|---|---|---|---|")
	var res := {}
	for lv in SimEndgame.difficulty_levels():
		var id := str(lv["id"])
		var sm := _run_style("recommended", seed, max_turn, id)
		var peak := 0.0
		for h in sm.state.history: peak = maxf(peak, float(h.get("infl", 0.0)))
		var ov := float(sm.score.current()["overall"])
		res[id] = ov
		say("| %s | %.0f%% | %.1f%% | %d/6 | %s | %.0f | %.0f%% | %d | %d |" % [lv["name"], _eg_overall_at(sm, 1965), ov, int(sm.score.current()["ahead"]), sm.endgame.final_ending()["name"],
			sm.state.gold, peak, sm.state.units_lost, sm.endgame._town_strikes()])
		_collapse_line(sm, "recommended")
		for e in sm.state.errors.slice(0, 5):
			fail("%s sim error: %s" % [id, e])
		sm.dispose()
	if res.has("easy") and res.has("normal") and res.has("hard") and not (float(res["easy"]) > float(res["normal"]) and float(res["normal"]) > float(res["hard"])):
		fail("difficulty: overall should fall from Easy to Normal to Hard (%s)" % str(res))


func _eg_scenarios() -> void:
	## Round 2 preparation: each scenario start loads as a valid player game and plays six quarters.
	say("")
	say("## Scenario starts (seeded from the historical run)")
	for sc in SimEndgame.scenario_list():
		if not sc["available"]:
			fail("scenario %s: %s missing (run the full sim_test to write it)" % [sc["id"], sc["file"]])
			continue
		var sm := Sim.new()
		sm.new_game({"scenario": sc["id"], "difficulty": "normal"})
		var ok: bool = sm.state.mode == "player" and sm.state.turn == int(sc["turn"])
		var start := sm.date_label()
		var n0 := sm.active_cities().size()
		var g0 := sm.state.gold
		var nt := sm.state.techs.size()
		var dip := sm.get_diplomacy().filter(func(d): return str(d.get("status", "")) != "none").size()
		var next0: Dictionary = sm.next_action()
		for i in range(6):
			SimAI.play_turn(sm)
		var path := "user://scenario_%s_test.json" % sc["id"]
		var saved := sm.save_game(path)
		var s2 := Sim.new()
		var loaded := s2.load_game(path)
		say("- %s %s: starts %s (turn %d), %d cities, %d techs, %d civics, treasury %.0f, %d diplomatic relations, first decision %s; after 6 quarters %s, %d errors; save/load %s" % [
			sc["id"], sc["title"], start, int(sc["turn"]), n0, nt, sm.state.civics.size(), g0, dip, str(next0.get("type", "")), sm.date_label(), sm.state.errors.size(),
			"OK" if saved and loaded else "FAILED"])
		if not ok: fail("scenario %s: did not start as a player game at %s" % [sc["id"], sc["label"]])
		if n0 < 60: fail("scenario %s: only %d cities" % [sc["id"], n0])
		if sm.state.turn != int(sc["turn"]) + 6: fail("scenario %s: turns did not advance" % sc["id"])
		if not (saved and loaded): fail("scenario %s: save/load failed" % sc["id"])
		for e in sm.state.errors.slice(0, 5):
			fail("scenario %s sim error: %s" % [sc["id"], e])
		sm.dispose(); s2.dispose()


# ------------------------------------------------------------------ v3 item 13 (fix-v3a): soft fail states

const COLLAPSE_DRIVERS := {"ruin_fiscal": "collapse_fiscal", "ruin_trust": "collapse_trust", "ruin_military": "collapse_military"}


func _collapse_line(sm: Sim, name: String) -> void:
	## One line per autoplayer: how close each collapse came (peak strain against the limit) and the closest approach
	## to each condition. An ordinary autoplayer must never collapse on Easy or Normal.
	var cst: Array = sm.get_collapse_status()
	var pr: Dictionary = sm.collapse.cs().get("probe", {})
	var parts := cst.map(func(c): return "%s peak %d/%d" % [str(c["id"]).trim_prefix("collapse_"), int(c["peak"]), int(c["limit"])])
	var pv := func(k: String, fmt: String, mult := 1.0) -> String:
		return (fmt % (float(pr[k][0]) * mult)) + " (%s)" % SimDB.date_label(int(pr[k][1])) if pr.has(k) else "-"
	say("collapse (%s, %s): %s; %s; closest: debt/limit %s, inflation %s, trust min %s, unrest %s, readiness in war %s, strikes beyond history in war %s" % [
		name, sm.endgame.difficulty_id(), "COLLAPSED: " + sm.collapse.ended_id() + " in " + sm.date_label() if sm.collapse.ended() else "no collapse", ", ".join(parts),
		pv.call("debt_over_cap_max", "%.2f"), pv.call("inflation_max", "%.0f%%"), pv.call("trust_min", "%.0f"), pv.call("unrest_max", "%.0f%%", 100.0),
		pv.call("war_readiness_min", "%.0f"), pv.call("war_strikes_excess_max", "%+.0f")])
	if sm.collapse.ended() and not name.begins_with("ruin_") and sm.endgame.difficulty_id() in ["easy", "normal"]:
		fail("collapse: the %s autoplayer collapsed (%s, %s) on %s" % [name, sm.collapse.ended_id(), sm.date_label(), sm.endgame.difficulty_id()])


func _collapse_report(seed: int, max_turn: int) -> void:
	## The collapse report: three deliberately ruinous drivers (borrow everything, alienate everyone, ignore the wars)
	## must each reach their own collapse, with at least four quarters of warning first, a "what went wrong" epilogue and
	## no memorial. At the first warning a copy of the game is handed to the Recommended player, which must recover.
	## Also writes user://collapse_<id>_warn.json and _end.json (for screenshots).
	say("")
	say("## Collapse report (soft fail states, v3 item 13)")
	for drv in COLLAPSE_DRIVERS:
		var want: String = COLLAPSE_DRIVERS[drv]
		var sm := Sim.new()
		sm.new_game({"mode": "player", "seed": seed, "difficulty": "normal"})
		sm.state.counters["ai_style"] = drv
		var warn_turn := -1
		var warn_path := "user://collapse_%s_warn.json" % want.trim_prefix("collapse_")
		var rec := ""
		while not sm.state.game_over and sm.state.turn <= max_turn:
			SimAI.play_turn(sm)
			var ep_turn := int(sm.collapse.cs()["warned"].get(want, -1))
			if ep_turn > 0 and ep_turn != warn_turn and not sm.state.game_over:
				sm.save_game(warn_path)   # the warning of the latest episode (for the screenshot)
				if warn_turn < 0:
					rec = _collapse_recovery(warn_path, want)   # the first warning: can the Recommended player recover?
				warn_turn = ep_turn
		var ended := sm.collapse.ended_id()
		var ep: Dictionary = sm.get_epilogue()
		var es: Dictionary = sm.get_end_summary()
		var fw := int(sm.collapse.cs()["warned"].get(want, -1))   # the last episode's first warning
		var warned_q := sm.state.turn - fw if fw > 0 else -1
		say("")
		say("### %s -> %s" % [drv, ended if ended != "" else "no collapse"])
		say("- ended %s (turn %d); first warning of %s: %s; quarters of warning: %d; peaks: %s" % [sm.date_label(), sm.state.turn, want,
			SimDB.date_label(fw) if fw > 0 else "never", warned_q, ", ".join(sm.get_collapse_status().map(func(c): return "%s %d/%d" % [str(c["id"]).trim_prefix("collapse_"), int(c["peak"]), int(c["limit"])]))])
		say("- ending: %s; memorial shown: %s; end screen ending id: %s" % [str(ep.get("name", "")), "yes" if not (es.get("memorial", {}) as Dictionary).is_empty() else "no", str(es.get("ending", {}).get("id", ""))])
		say("- recovery test (the Recommended player takes over at the first warning): %s" % rec)
		for p in ep.get("paragraphs", []):
			say("  - [%s] %s%s" % [str(p.get("kind", "")), (str(p.get("title", "")) + ": ") if str(p.get("title", "")) != "" else "", str(p.get("text", "")).replace("\n", " / ")])
		_collapse_line(sm, drv)
		if ended != want:
			fail("collapse report: %s should reach %s, got %s (%s)" % [drv, want, ended if ended != "" else "no collapse", sm.date_label()])
		if ended != "" and warned_q < 4:
			fail("collapse report: %s collapsed after only %d quarters of warning (needs 4+)" % [drv, warned_q])
		if not (es.get("memorial", {}) as Dictionary).is_empty():
			fail("collapse report: the 7 October memorial is attached to a collapse ending (%s)" % drv)
		if ended != "" and not ep.get("paragraphs", []).any(func(p): return str(p.get("kind", "")) == "what_went_wrong"):
			fail("collapse report: %s has no \"what went wrong\" epilogue" % drv)
		if rec.begins_with("FAILED"):
			fail("collapse report: %s: %s" % [drv, rec])
		if ended != "":
			sm.save_game("user://collapse_%s_end.json" % want.trim_prefix("collapse_"))
		for e in sm.state.errors.slice(0, 5):
			fail("%s sim error: %s" % [drv, e])
		sm.dispose()
	_naive_builder_case(seed, max_turn)   # v3 fix3-econ
	_populist_case(seed, max_turn)   # v3 final round (fix4-econ, fullr N1)


func _fc_indicator_tiers(sims: Array, names: Array) -> void:
	## v3 fix3-econ: how often each autoplayer's fiscal indicator left "ok" (watch / warning / danger quarters). A healthy
	## Recommended game must show no warning or danger and "watch" in at most 10% of its quarters.
	say("")
	say("### Fiscal indicator tiers (quarters at each level)")
	for i in range(sims.size()):
		var sm: Sim = sims[i]
		var cnt := {"ok": 0, "watch": 0, "warning": 0, "danger": 0}
		var n := 0
		for e in sm.get_meta("fc_turns", []):
			if e.size() < 5: continue
			cnt[str(e[4])] = int(cnt.get(str(e[4]), 0)) + 1
			n += 1
		var sx: Dictionary = sm.econ.structural()
		var wq := []   # v3 fix3-econ: the quarters at warning or danger and why
		for e2 in sm.get_meta("fc_turns", []):
			if e2.size() >= 6 and str(e2[4]) in ["warning", "danger"]: wq.append("%s %s (%s)" % [SimDB.date_label(int(e2[0])), str(e2[4]), str(e2[5])])
		if not wq.is_empty(): say("  - %s warning/danger quarters: %s" % [names[i], "; ".join(wq.slice(0, 8))])
		say("- %s: %s of %d quarters; structural-deficit alarm in %d quarters (first %s, peak ratio %.2f); levers used %s" % [names[i], str(cnt), n,
			int(sx.get("alarm_turns", 0)), SimDB.date_label(int(sx.get("first", -1))) if int(sx.get("first", -1)) > 0 else "never", float(sx.get("peak", 0.0)), str(sm.econ.lever_counts())])
		if str(names[i]) == "recommended" and n > 0:
			if int(cnt["warning"]) + int(cnt["danger"]) > 0:
				fail("fiscal indicator: the healthy Recommended game shows warning or danger in %d quarters" % (int(cnt["warning"]) + int(cnt["danger"])))
			if float(cnt["watch"]) / float(n) > 0.10:
				fail("fiscal indicator: the healthy Recommended game shows \"watch\" in %d of %d quarters (fix3-econ: at most 10%%)" % [int(cnt["watch"]), n])


func _inflation_path(h: Sim) -> void:
	## v3 fix3-econ (A8): a player making history's choices tracks history's inflation (1967-68 and 1984-85).
	say("")
	say("### Inflation with history's choices against history's CPI")
	var rows := []
	for d in ["1967-05", "1967-11", "1968-05", "1984-02", "1984-08", "1985-02", "1985-05"]:
		var t := SimDB.turn_of(d, 1)
		if t > h.state.history.size(): continue
		var mine := float(h.state.history[t - 1].get("infl", 0.0))
		var hist: float = h.inflation_baseline(SimDB.year_f(t))
		rows.append("%s %.1f%% (history %.1f%%)" % [SimDB.date_label(t), mine, hist])
		var bad := absf(mine - hist) > 4.0 if hist < 20.0 else (mine / maxf(1.0, hist) < 0.7 or mine / maxf(1.0, hist) > 1.4)
		if bad:
			fail("inflation: with history's choices %s reads %.1f%% against history's %.1f%%" % [SimDB.date_label(t), mine, hist])
	say("- " + "; ".join(rows))


func _naive_builder_case(seed: int, max_turn: int) -> void:
	## v3 fix3-econ (full-game critic B1): the naive builder builds every building it can (upkeep ignored), buys with gold
	## and Cohesion, never borrows and never uses the structural levers. The structural-deficit alarm must name the upkeep
	## and come at least 4 quarters before any fiscal-collapse warning. From the first warning (the alarm) the Recommended
	## player takes over and must not collapse to the end; from a fiscal-collapse warning too, if the builder reaches one.
	say("")
	say("### ruin_builder (the naive builder) -> structural deficit")
	var sm := Sim.new()
	sm.new_game({"mode": "player", "seed": seed, "difficulty": "normal"})
	sm.state.counters["ai_style"] = "ruin_builder"
	var alarm_path := "user://naive_builder_alarm.json"
	var warn_path := "user://naive_builder_warn.json"
	var alarm_t := -1
	var warn_t := -1
	var alarm_text := ""
	while not sm.state.game_over and sm.state.turn <= max_turn:
		SimAI.play_turn(sm)
		if sm.state.game_over: break
		if alarm_t < 0 and sm.econ.structural_alarm():
			alarm_t = sm.state.turn
			alarm_text = sm.econ.upkeep_text()
			sm.save_game(alarm_path)
		if warn_t < 0 and int(sm.collapse.cs()["warned"].get("collapse_fiscal", -1)) > 0:
			warn_t = sm.state.turn
			sm.save_game(warn_path)
	var ep: Dictionary = sm.get_epilogue()
	say("- the builder alone: %s (%s); first structural alarm %s; first fiscal-collapse warning %s" % [("COLLAPSED: " + sm.collapse.ended_id()) if sm.collapse.ended() else "no collapse",
		sm.date_label(), SimDB.date_label(alarm_t) if alarm_t > 0 else "never", SimDB.date_label(warn_t) if warn_t > 0 else "never"])
	say("- the alarm: " + alarm_text)
	if sm.collapse.ended():
		for p in ep.get("paragraphs", []):
			if str(p.get("kind", "")) == "what_went_wrong": say("  - [what went wrong] " + str(p.get("text", "")).replace("\n", " / "))
	_collapse_line(sm, "ruin_builder")
	if alarm_t < 0:
		fail("naive builder: no structural-deficit alarm in the whole game")
	elif not alarm_text.contains("running costs"):
		fail("naive builder: the structural-deficit alarm does not name the running costs")
	if warn_t > 0 and alarm_t > 0 and warn_t - alarm_t < 4:
		fail("naive builder: the structural alarm came only %d quarters before the collapse warning (needs 4+)" % (warn_t - alarm_t))
	for path in [alarm_path, warn_path]:
		if (path == alarm_path and alarm_t < 0) or (path == warn_path and warn_t < 0): continue
		var s2 := Sim.new()
		if not s2.load_game(path):
			fail("naive builder: could not load " + path)
			continue
		s2.state.counters["ai_style"] = "recommended"
		var tw := s2.state.turn
		var peak := 0
		while not s2.state.game_over and s2.state.turn <= max_turn:
			SimAI.play_turn(s2)
			peak = maxi(peak, s2.collapse.strain("collapse_fiscal"))
		var en: Dictionary = s2.get_endings()
		say("- Recommended from the %s (%s): %s at %s; fiscal strain peak %d; overall %.1f%%; ending %s; levers used %s" % ["structural alarm" if path == alarm_path else "collapse warning",
			SimDB.date_label(tw), ("COLLAPSED: " + s2.collapse.ended_id()) if s2.collapse.ended() else "survived", s2.date_label(), peak, float(s2.score.current()["overall"]),
			str(en["primary"]), str(s2.econ.lever_counts())])
		if s2.collapse.ended():
			fail("naive builder: the Recommended player taking over at the %s (%s) collapsed anyway (%s, %s)" % ["structural alarm" if path == alarm_path else "collapse warning",
				SimDB.date_label(tw), s2.collapse.ended_id(), s2.date_label()])
		for e in s2.state.errors.slice(0, 5):
			fail("naive builder recovery sim error: %s" % e)
		s2.dispose()
	for e in sm.state.errors.slice(0, 5):
		fail("ruin_builder sim error: %s" % e)
	sm.dispose()


func _populist_case(seed: int, max_turn: int) -> void:
	## v3 final round (fix4-econ, full-game critic N1): the careless populist (SimAI style ruin_populist: borrows whenever
	## offered, tax rebates and indexing, every welfare policy card, grand buildings, defence starved, never a fiscal
	## lever). At its FIRST structural-deficit alarm the Recommended player takes over a copy and must avoid every
	## collapse of the state for 20 years (80 quarters, or to the end). The alarm must name the policy cards' cost, and
	## the Treasury lines must add up to the quarter's net every quarter.
	say("")
	say("### ruin_populist (the careless populist) -> Recommended from the first structural alarm")
	var sm := Sim.new()
	sm.new_game({"mode": "player", "seed": seed, "difficulty": "normal"})
	sm.state.counters["ai_style"] = "ruin_populist"
	var alarm_path := "user://populist_alarm.json"
	var alarm_t := -1
	var alarm_text := ""
	var alarm_cards := 0.0
	var mism := 0
	var mism_t := ""
	while not sm.state.game_over and sm.state.turn <= max_turn:
		SimAI.play_turn(sm)
		if sm.state.game_over: break
		var bl: Dictionary = sm.state.counters.get("budget_lines", {})
		if not bl.is_empty() and absf(float(bl["net"]) - float(sm.state.counters.get("last_budget", {}).get("net", 0.0))) > 1.0:
			mism += 1
			if mism_t == "": mism_t = "%s: lines %.1f, budget %.1f" % [sm.date_label(), float(bl["net"]), float(sm.state.counters["last_budget"].get("net", 0.0))]
		if alarm_t < 0 and sm.econ.structural_alarm():
			alarm_t = sm.state.turn
			alarm_text = sm.econ.upkeep_text()
			for pc in sm.econ.policy_costs(): alarm_cards += float(pc["cost"])
			sm.save_game(alarm_path)
		if alarm_t > 0 and sm.state.turn >= alarm_t + 80: break
	var sc: Dictionary = sm.score.current()
	say("- the populist alone: %s (%s); first structural alarm %s (overall %.0f%% at the end of the run); costly policy cards at the alarm %.0f gold a quarter" % [
		("COLLAPSED: " + sm.collapse.ended_id()) if sm.collapse.ended() else "no collapse", sm.date_label(), SimDB.date_label(alarm_t) if alarm_t > 0 else "never",
		float(sc.get("overall", 0.0)), alarm_cards])
	say("- the alarm: " + alarm_text)
	_collapse_line(sm, "ruin_populist")
	if mism > 0:
		fail("populist: the Treasury lines do not add up to the net in %d quarters (first %s)" % [mism, mism_t])
	if alarm_t < 0:
		fail("populist: no structural-deficit alarm in the whole game")
	elif alarm_cards >= 1.0 and not alarm_text.contains("policy cards"):
		fail("populist: the structural-deficit alarm does not name the policy cards (%.0f gold a quarter)" % alarm_cards)
	for e in sm.state.errors.slice(0, 5):
		fail("ruin_populist sim error: %s" % e)
	sm.dispose()
	if alarm_t < 0:
		return
	var s2 := Sim.new()
	if not s2.load_game(alarm_path):
		fail("populist: could not load " + alarm_path)
		return
	s2.state.counters["ai_style"] = "recommended"
	var tw := s2.state.turn
	var peaks := {}
	var ratio_peak := 0.0
	var alarm_q := 0
	while not s2.state.game_over and s2.state.turn <= max_turn and s2.state.turn < tw + 80:
		SimAI.play_turn(s2)
		for cid in ["collapse_fiscal", "collapse_trust", "collapse_military"]:
			peaks[cid] = maxi(int(peaks.get(cid, 0)), s2.collapse.strain(cid))
		ratio_peak = maxf(ratio_peak, s2.econ.structural_ratio())
		if s2.econ.structural_alarm(): alarm_q += 1
	var cleared: bool = not s2.econ.structural_alarm()
	say("- Recommended from the populist's first structural alarm (%s): %s at %s (%d quarters); strain peaks fiscal %d, trust %d, military %d; structural alarm on in %d quarters, %s at the end; overall %.1f%%; levers used %s; cards %s" % [
		SimDB.date_label(tw), ("COLLAPSED: " + s2.collapse.ended_id()) if s2.collapse.ended() else "no collapse", s2.date_label(), s2.state.turn - tw,
		int(peaks.get("collapse_fiscal", 0)), int(peaks.get("collapse_trust", 0)), int(peaks.get("collapse_military", 0)), alarm_q, "cleared" if cleared else "still on",
		float(s2.score.current()["overall"]), str(s2.econ.lever_counts()), str(s2.state.counters.get("policy_cuts", {}))])
	_collapse_line(s2, "recommended after the populist")
	if s2.collapse.ended():
		fail("populist: the Recommended player taking over at the first structural alarm (%s) collapsed within 20 years (%s, %s)" % [SimDB.date_label(tw), s2.collapse.ended_id(), s2.date_label()])
	for e in s2.state.errors.slice(0, 5):
		fail("populist recovery sim error: %s" % e)
	s2.dispose()


func _collapse_recovery(path: String, want: String) -> String:
	## Loads the game at the first warning and plays it on with the Recommended player for up to 6 years.
	var s2 := Sim.new()
	if not s2.load_game(path):
		return "FAILED: could not load " + path
	s2.state.counters["ai_style"] = "recommended"
	var t0w := s2.state.turn
	var peak := s2.collapse.strain(want)
	var cleared := -1
	for i in range(24):
		if s2.state.game_over: break
		SimAI.play_turn(s2)
		peak = maxi(peak, s2.collapse.strain(want))
		if cleared < 0 and s2.collapse.strain(want) == 0: cleared = s2.state.turn
	var out := ""
	if s2.collapse.ended():
		out = "FAILED: collapsed anyway (%s, %s)" % [s2.collapse.ended_id(), s2.date_label()]
	elif cleared > 0:
		out = "recovered: the danger cleared in %s, %d quarters after the warning (peak strain %d)" % [SimDB.date_label(cleared), cleared - t0w, peak]
	else:
		out = "no collapse in %d quarters, strain %d at %s (peak %d)" % [s2.state.turn - t0w, s2.collapse.strain(want), s2.date_label(), peak]
	s2.dispose()
	return out


# ------------------------------------------------------------------ V4 (v4-sim-auto): --casual, story mode with the ministers on auto

const CASUAL_CORE := ["event_choice", "fork", "crisis_response", "coalition", "diplomacy", "dedication"]   # + immigration in a named wave
const V3_CORE := ["event_choice", "fork", "crisis_response", "policy_review", "immigration", "dedication", "coalition", "diplomacy"]   # _fc_pacing_core
const CASUAL_DECADES := [[1948, 1955], [1956, 1965], [1966, 1975], [1976, 1985], [1986, 1995], [1996, 2005], [2006, 2015], [2016, 2023]]
const CASUAL_RUNS := [["historical", "balanced"], ["varied", "balanced"], ["strategist_security", "security"], ["strategist_prosperity", "prosperity"],
	["strategist_peace", "peace"], ["strategist_society", "society"], ["ruin_populist", "society"]]
# v4 fix round: the careless populist of the veteran critic (borrow-and-spend story picks, "Not now" on every Treasury card).
# It is checked for the decision load, the cards (M1-M3) and the report, not for the balance and density bars.
const CASUAL_BAD := ["ruin_populist"]
var _cgoals := ""


func _casual_routine(sim: Sim, d: Dictionary) -> bool:
	## A routine decision type that must never reach the player with every ministry on auto (V4 box 1).
	var t := str(d.get("type", ""))
	if t in SimAuto.ROUTINE_TYPES:
		return true
	if t == "immigration" and str(d.get("wave", "")) == "":
		return true
	if t == "agenda" and sim.auto.owner(d) != "":
		return true
	return false


func _casual_answer(sim: Sim, d: Dictionary, brief: String, refuse := false) -> int:
	## The story player: the run's style answers each player decision (Recommended pickers for its style), the brief
	## once, and Finance's plan whenever the Treasury is in danger ("Not now" for the refusing populist).
	## Returns how many decisions the card took (v4 fix round: the budget card's surplus half and the agenda card's
	## Treasury half count as decisions of their own, as the veteran critic counted them); 0 when it could not be answered.
	var tre := "hold" if refuse else "finance_plan"
	match str(d.get("type", "")):
		"brief":
			return 1 if sim.auto.set_brief(brief) else 0
		"treasury":
			return 1 if sim.auto.choose_treasury(tre) else 0
	if not SimAI.resolve_one(sim, d):
		return 0
	var n := 1
	if d.has("surplus"):
		for p in sim.blocking_decisions():
			if str(p["type"]) == "programme" and SimAI.resolve_one(sim, p):
				n += 1
	if d.has("treasury") and not sim.auto.treasury_view().is_empty():
		if sim.auto.choose_treasury(tre):
			n += 1
	return n


func _casual_card_check(sim: Sim, d: Dictionary, res: Dictionary) -> void:
	## story_view: at most 3 options, history's option among them, one or two consequence lines each.
	var sv: Dictionary = sim.auto.story_view(d)
	var opts: Array = sv.get("options", [])
	var bad := ""
	if opts.is_empty() and not (sim.auto._options_of(d) as Array).is_empty():
		bad = "no option shown"
	elif opts.size() > 3:
		bad = "%d options shown" % opts.size()
	var hist: int = sim.auto._history_index(d)
	if bad == "" and hist >= 0 and not opts.any(func(o): return int(o["index"]) == hist):
		bad = "history's option %d hidden" % hist
	for o in opts:
		var c: Array = o.get("consequence", [])
		if c.is_empty() or c.size() > 2 or str(c[0]).strip_edges() == "":
			bad = "option %d consequence %s" % [int(o["index"]), str(c)]
	if opts.size() + (sv.get("more", []) as Array).size() != int(sv.get("n_options", 0)):
		bad = "options + more != n_options"
	res["cards"] = int(res["cards"]) + 1
	if bad != "":
		res["card_bad"] = int(res["card_bad"]) + 1
		if (res["card_ex"] as Array).size() < 6:
			res["card_ex"].append("%s %s: %s" % [SimDB.date_label(sim.state.turn), str(d["type"]), bad])
	_casual_fix_checks(sim, d, sv, res)
	for k in ["surplus", "treasury"]:
		if sv.get(k) is Dictionary and not (sv[k] as Dictionary).is_empty():
			var half: Dictionary = d.get(k, {})
			if not half.is_empty():
				_casual_fix_checks(sim, half, sv[k], res)


func _cfx(res: Dictionary, what: String, sim: Sim, d: Dictionary, msg: String) -> void:
	res[what] = int(res.get(what, 0)) + 1
	var ex: Array = res.get(what + "_ex", [])
	if ex.size() < 4:
		ex.append("%s %s: %s" % [SimDB.date_label(sim.state.turn), str(d.get("type", "")), msg])
	res[what + "_ex"] = ex


func _casual_fix_checks(sim: Sim, d: Dictionary, sv: Dictionary, res: Dictionary) -> void:
	## v4 fix round (v4fix-sim): the veteran critic's M1-M3 and the plain-language consequence lines, on every story card.
	var t := str(d.get("type", ""))
	var opts: Array = sv.get("options", [])
	var raw: Array = sim.auto._options_of(d)
	var rec: Dictionary = sv.get("recommended", {})
	var ro := {}
	for o in opts:
		if not rec.is_empty() and int(o["index"]) == int(rec.get("index", -1)): ro = o
		if not bool(o.get("available", true)) and str(o.get("reason", "")) == "":
			_cfx(res, "m2_bad", sim, d, "option %d unavailable without a reason" % int(o["index"]))
		for line in o.get("consequence", []):
			var s := str(line)
			if s.contains("-0 gold") or s.contains("-0 Gold") or s.contains("expected") or (s.begins_with("Now:") and s.to_lower().ends_with(" now.")):
				_cfx(res, "words_bad", sim, d, s)
	# M2: never an option that cannot be taken now
	if not rec.is_empty():
		if ro.is_empty():
			if int(rec.get("index", -1)) >= 0 and int(rec["index"]) < raw.size() and sim.auto._unavailable_reason(d, raw[int(rec["index"])]) != "":
				_cfx(res, "m2_bad", sim, d, "the Recommended option (hidden) cannot be taken now")
		elif not bool(ro.get("available", true)):
			_cfx(res, "m2_bad", sim, d, "the Recommended option cannot be taken now: " + str(ro.get("reason", "")))
	if t == "programme":
		for i in range(raw.size()):
			var oid := str(raw[i].get("id", ""))
			if not (oid.begins_with("launch:") or oid.begins_with("expand:")):
				continue
			var r: String = sim.auto._unavailable_reason(d, raw[i])
			var short: bool = r.contains("gold")
			var parts := oid.split(":")
			var live_inst: float = (float(sim.endgame.level_cost(parts[1], int(parts[2]))) / maxf(1.0, float(sim.endgame.level_def(parts[1], int(parts[2])).get("turns", 4)))) if oid.begins_with("launch:") \
				else (float(sim.endgame.expand_cost(parts[1])) / maxf(1.0, float(sim.endgame.expand_def(parts[1]).get("turns", 4))))
			if sim.state.gold < live_inst and r == "" and not sim.endgame._historical():   # (history's own player launches on its dates)
				_cfx(res, "m2_bad", sim, d, "%s needs gold but reads as available" % oid)
			if short and int(res.get("m2_refused", 0)) < 50:
				# a refused click: the sim says no, and the card has a reason to show
				var before: float = sim.state.gold
				if sim.choose_programme(i):
					_cfx(res, "m2_bad", sim, d, "%s was launched without the gold for its first instalment" % oid)
				elif sim.auto.refusal_text(d, i) == "" or sim.auto.why_refused(d, i) == "" or sim.state.gold != before:
					_cfx(res, "m2_bad", sim, d, "a refused %s gave no reason" % oid)
				res["m2_refused"] = int(res.get("m2_refused", 0)) + 1
	# M3: the reason agrees with the numbers on the card
	if not rec.is_empty():
		var why := str(rec.get("why", ""))
		res["m3_cards"] = int(res.get("m3_cards", 0)) + 1
		if why == "" or why.contains("soundest"):
			_cfx(res, "m3_bad", sim, d, "reason '%s'" % why)
		var kind := str(rec.get("why_kind", ""))
		if kind == "best" and not ro.is_empty():
			var st := str(rec.get("why_stat", ""))
			var mine := float(ro.get("shown", {}).get(st, 0.0))
			if not (ro.get("shown", {}) as Dictionary).has(st):
				_cfx(res, "m3_bad", sim, d, "'%s' but its lines do not show %s" % [why, st])
			for o in opts:
				if int(o["index"]) != int(ro["index"]) and float(o.get("shown", {}).get(st, 0.0)) > mine + 1e-6:
					_cfx(res, "m3_bad", sim, d, "'%s' but option %d shows more (%s %.2f against %.2f)" % [why, int(o["index"]), st, float(o["shown"][st]), mine])
			res["m3_best"] = int(res.get("m3_best", 0)) + 1
		if kind == "tradeoff" and not ro.is_empty():
			var txt := " ".join(ro.get("consequence", []))
			if not (txt.begins_with("Now:") and txt.contains("For years:")):
				_cfx(res, "m3_bad", sim, d, "'%s' but the lines are %s" % [why, txt])
		if t == "crisis_response" and str(ro.get("id", "")) == "mobilize" and bool(sim.state.crisis_decision.get("war_turn", false)):
			res["m3_mobilise"] = int(res.get("m3_mobilise", 0)) + 1
			if not " ".join(ro.get("consequence", [])).contains("+2 strength") or not why.contains("stronger"):
				_cfx(res, "m3_bad", sim, d, "mobilisation: '%s' / %s" % [why, str(ro.get("consequence", []))])
	# M1: the immigration card names the people the plan leaves in camps or temporary housing
	if t == "immigration":
		for o in opts:
			var x: Dictionary = raw[int(o["index"])]
			if int(x.get("camp_residents", 0)) >= 1000:
				res["m1_opts"] = int(res.get("m1_opts", 0)) + 1
				var txt2 := " ".join(o.get("consequence", []))
				if not txt2.contains("people left in") or not txt2.contains("Civic Trust and growth"):
					_cfx(res, "m1_bad", sim, d, "%s (%d in camps): %s" % [str(x.get("id", "")), int(x["camp_residents"]), txt2])


func _casual_play(story: String, brief: String, seed: int, max_turn: int) -> Dictionary:
	## One whole game in story mode: the ministers run the routine, `story` answers the player's decisions.
	var sim := Sim.new()
	var ng := {"mode": "player", "seed": seed, "difficulty": "normal", "play_style": "story"}
	if _cgoals != "":
		ng["goals"] = _cgoals   # --casual-goals=on|off (diagnostics; the default is story mode's: on)
	sim.new_game(ng)
	sim.state.counters["ai_style"] = story
	var res := {"sim": sim, "story": story, "brief": brief, "per": {}, "war": {}, "core": {}, "types": {}, "viol": 0, "viol_ex": [], "stuck": 0,
		"cards": 0, "card_bad": 0, "card_ex": [], "bad_lines": 0, "bad_line_ex": [], "treasury": 0, "ms": 0}
	var t0c := Time.get_ticks_msec()
	var refuse: bool = story in CASUAL_BAD   # the careless populist answers "Not now" on every Treasury card
	var rx_plural := RegEx.create_from_string("(^|\\D)1 (units|attacks|improvements|settlement groups|mothballed buildings)")
	while not sim.state.game_over and sim.state.turn <= max_turn:
		var t := sim.state.turn
		res["war"][t] = not sim.state.crises.is_empty()
		var seen_keys := {}
		for l in sim.auto.report()["lines"]:
			if str(l.get("key", "")) == "" or not SimAuto.TEMPLATES.has(str(l["key"])) or str(l.get("text", "")) == "" or str(l.get("text", "")).contains("{"):
				res["bad_lines"] = int(res["bad_lines"]) + 1
				if (res["bad_line_ex"] as Array).size() < 4: res["bad_line_ex"].append(str(l))
			# v4 fix round: the report's wording (plurals, the prefix of a unit begun in a city, no repeated counted line, no -0)
			var tx := str(l.get("text", ""))
			var base := str(l.get("key", "")).trim_suffix(".one")
			var wb := ""
			if rx_plural.search(tx) != null: wb = "plural"
			if tx.contains("-0 gold") or tx.contains(" 0 gold"): wb = "zero gold"
			if base == "auto.production.set" and str(l.get("args", {}).get("kind", "")) == "unit":
				# v4final (vet N6): settlement groups and crews under Agriculture, the army's units under Defence
				var civ_unit := str(sim.db.units.get(str(l.get("args", {}).get("item_id", "")), {}).get("cls", "")) == "civilian"
				if not tx.begins_with("Agriculture:" if civ_unit else "Defence:"): wb = "unit under " + tx.get_slice(":", 0)
			if tx.contains("(repeatable)"): wb = "(repeatable) in the report"
			if base in SimAuto.MERGE_KEYS:
				var mk := str(l.get("domain", "")) + "|" + base
				if seen_keys.has(mk): wb = "repeated line"
				seen_keys[mk] = true
			if wb != "":
				res["report_bad"] = int(res.get("report_bad", 0)) + 1
				var rex: Array = res.get("report_bad_ex", [])
				if rex.size() < 4: rex.append("%s (%s)" % [tx, wb])
				res["report_bad_ex"] = rex
		if t >= Sim.last_playable_turn():
			for x in sim.auto.player_decisions():
				if (str(x.get("type", "")) == "programme" and str(x.get("kind", "")) == "surplus") or x.has("surplus"):
					res["last_surplus"] = int(res.get("last_surplus", 0)) + 1
		if not SimAI.historical(sim):
			SimAI.deal_turn(sim)   # the deal screen stays the player's
		for _r in range(4):
			for i in range(60):
				var pd: Array = sim.auto.player_decisions()
				for x in pd:
					if _casual_routine(sim, x):
						res["viol"] = int(res["viol"]) + 1
						if (res["viol_ex"] as Array).size() < 6: res["viol_ex"].append("%s %s" % [SimDB.date_label(t), str(x["type"])])
				if pd.is_empty():
					break
				var d: Dictionary = pd[0]
				_casual_card_check(sim, d, res)
				var ty := str(d["type"])
				var took := _casual_answer(sim, d, brief, refuse)
				if took <= 0:
					res["stuck"] = int(res["stuck"]) + 1
					break
				res["per"][t] = int(res["per"].get(t, 0)) + took
				var pt: Dictionary = res.get("ptypes", {})
				pt[t] = (pt.get(t, []) as Array) + [ty + ("+half" if took > 1 else "")]
				res["ptypes"] = pt
				res["types"][ty] = int(res["types"].get(ty, 0)) + 1
				if ty == "crisis_response": res["war"][t] = true
				if ty == "treasury" or d.has("treasury"): res["treasury"] = int(res["treasury"]) + 1
				if ty in CASUAL_CORE or (ty == "immigration" and str(d.get("wave", "")) != ""):
					res["core"][t] = int(res["core"].get(t, 0)) + 1
			if _r == 0:
				SimAI._programmes(sim)   # strategists and varied fund programmes from the Programmes panel (the player's)
			if sim.end_turn():
				break
			if _r == 3:
				res["stuck"] = int(res["stuck"]) + 1
				sim.end_turn(true)
	res["ms"] = Time.get_ticks_msec() - t0c
	return res


func _casual_decades(sim: Sim, per_turn: Dictionary) -> Array:
	var out := []
	for dc in CASUAL_DECADES:
		var a := maxi(1, SimDB.turn_of("%d-01" % dc[0], 1)); var b := mini(sim.state.turn, SimDB.turn_of("%d-12" % dc[1], Sim.last_playable_turn()))
		if b < a:
			out.append(-1.0)
			continue
		var tot := 0
		for t in range(a, b + 1):
			tot += int(per_turn.get(t, 0))
		out.append(float(tot) / float(b - a + 1))
	return out


func _casual_flip(seed: int) -> void:
	## Every ministry flips to manual mid-game and back: its v3 prompts appear while manual and vanish on hand-back.
	say("")
	say("### Every ministry flips mid-game (research manual from Q1 1958, all manual from Q2 1958, all back to auto at Q4 1962)")
	var sim := Sim.new()
	sim.new_game({"mode": "player", "seed": seed, "difficulty": "normal", "play_style": "story"})
	sim.state.counters["ai_style"] = "historical"
	var seen := {}
	var after := {}
	var custom_ok := false
	var full_ok := false
	var routes_manual := -1
	var deleg_manual := 0
	var reload_ok := ""
	while not sim.state.game_over and sim.state.turn <= 62:
		var t := sim.state.turn
		if t == 40:
			sim.auto.set_auto("research", false)
			custom_ok = sim.auto.style() == "custom"
		if t == 41:
			for dm in Sim.domains():
				sim.auto.set_auto(str(dm["id"]), false)
			full_ok = sim.auto.style() == "full" and sim.next_action().get("type", "") != "brief"
			routes_manual = sim.state.trade_routes.size()
		if t == 45:
			var p := "user://v4_casual_flip.json"
			sim.save_game(p)
			var s2 := Sim.new()
			if not s2.load_game(p): reload_ok = "load failed"
			elif s2.auto.style() != "full" or s2.auto.brief() != sim.auto.brief(): reload_ok = "style %s brief %s after reload" % [s2.auto.style(), s2.auto.brief()]
			s2.dispose()
		if t == 60:
			for dm in Sim.domains():
				var id := str(dm["id"])
				sim.auto.set_auto(id, true)
				after[id] = sim.auto.player_decisions().filter(func(x): return sim.auto.owner(x) == id).size()
			if sim.auto.style() != "story": after["style"] = 1
		if t >= 42 and t <= 60:   # (the turn-41 start was still the Foreign Ministry's)
			for a in sim.state.diplomacy:
				if int(sim.state.diplomacy[a].get("last_delegation", -99)) == t: deleg_manual += 1
		if not SimAI.historical(sim):
			SimAI.deal_turn(sim)
		for i in range(80):
			var pd: Array = sim.auto.player_decisions()
			if pd.is_empty(): break
			var d: Dictionary = pd[0]
			var o := sim.auto.owner(d)
			if o == "" and str(d["type"]) == "unit_orders": o = "units"
			if t >= 40 and t < 60 and o != "":
				seen[o] = int(seen.get(o, 0)) + 1
			if _casual_answer(sim, d, "balanced") <= 0:
				if str(d["type"]) == "unit_orders":
					var uu = sim.unit_by_id(int(d["unit"]))
					if uu != null: uu.orders = "sleep"
					continue
				break
		if t >= 41 and t < 60 and sim.state.trade_routes.size() > routes_manual and routes_manual >= 0:
			seen["trade_violation"] = 1
		if not sim.end_turn():
			for d2 in sim.blocking_decisions():
				if str(d2["type"]) == "unit_orders":
					var u2 = sim.unit_by_id(int(d2["unit"]))
					if u2 != null: u2.orders = "sleep"
			if not sim.end_turn():
				sim.end_turn(true)
	say("| Ministry | Its prompts while manual (Q1 1958-Q3 1962) | Left after hand-back |")
	say("|---|---|---|")
	var must := ["production", "research", "civics", "settlement", "immigration", "cabinet", "budget"]
	for dm in Sim.domains():
		var id := str(dm["id"])
		var n := int(seen.get(id, 0))
		var note := str(n)
		if id == "trade": note = "routes stay as they were (%d); the notice returns" % maxi(0, routes_manual)
		if id == "delegations": note = "no automatic delegation (%d sent)" % deleg_manual
		say("| %s | %s | %d |" % [str(dm["name"]), note, int(after.get(id, 0))])
		if id in must and n == 0:
			fail("casual flip: the %s ministry on manual never asked the player (Q1 1958-Q3 1962)" % id)
		if int(after.get(id, 0)) > 0:
			fail("casual flip: %d %s decisions still waited for the player after handing the ministry back" % [int(after.get(id, 0)), id])
	if not custom_ok: fail("casual flip: one ministry on manual did not read as the custom style")
	if not full_ok: fail("casual flip: every ministry on manual did not read as Full control")
	if after.has("style"): fail("casual flip: handing every ministry back did not restore story mode")
	if seen.has("trade_violation"): fail("casual flip: export routes opened while Finance's trade was on manual")
	if deleg_manual > 0: fail("casual flip: %d delegations were sent while the Foreign Ministry was on manual" % deleg_manual)
	if reload_ok != "": fail("casual flip: save/load of counters.auto: " + reload_ok)
	for v in sim.auto.player_decisions():
		if _casual_routine(sim, v): fail("casual flip: a routine %s waited for the player after the hand-back" % str(v["type"]))
	say("custom style with one ministry manual: %s; Full control with all manual: %s; save/load: %s" % [custom_ok, full_ok, "OK" if reload_ok == "" else reload_ok])
	sim.dispose()


func _casual_suite(seed: int, max_turn: int, args: Array) -> void:
	## V4 box 1, 2 (sim side) and 3 (decision counts and story density) in story mode: ministers on auto, story picks by
	## history, varied and the four strategists (each with its own brief); compared with the v3 historical run.
	say("")
	say("## V4 casual layer: story mode, the ministers on auto (sim_test --casual)")
	say("Story decisions by each style; routine by the ministers (plain Recommended, or the strategist's brief). The deal screen and")
	say("the Programmes panel stay with the story style; the Treasury in danger is answered with Finance's plan. Seed %d, Normal." % seed)
	var only := ""
	for a in args:
		if str(a).begins_with("--casual-runs="): only = str(a).substr(14)
		if str(a).begins_with("--casual-goals="): _cgoals = str(a).substr(15)
	say("")
	say("### v3 reference: history's picks for everything (Full control)")
	var v3 := _run_style("historical", seed, max_turn)
	var v3o := float(v3.score.current()["overall"])
	var v3core := {}
	for e in v3.get_meta("decision_log"):
		if str(e[1]) in V3_CORE: v3core[int(e[0])] = int(v3core.get(int(e[0]), 0)) + 1
	var v3dec := _casual_decades(v3, v3core)
	say("v3 historical picks: overall %.1f%%, ending %s" % [v3o, str(v3.get_endings().get("primary", ""))])
	var runs := {}
	var run_list: Array = CASUAL_RUNS.duplicate()
	if only.split(",").has("recommended"):
		run_list.append(["recommended", "balanced"])   # (on request: the Recommended story player, for the veteran's m7 gap)
	for r in run_list:
		if only != "" and not (str(r[0]) in only.split(",")):
			continue
		var res := _casual_play(str(r[0]), str(r[1]), seed, max_turn)
		runs[str(r[0])] = res
		var sm: Sim = res["sim"]
		say("casual %s (brief %s): overall %.1f%%, ending %s, %s, %.0f s" % [str(r[0]), str(r[1]), float(sm.score.current()["overall"]),
			str(sm.get_endings().get("primary", "")), sm.date_label(), float(res["ms"]) / 1000.0])
		for e in sm.state.errors.slice(0, 8):
			fail("casual %s sim error: %s" % [str(r[0]), str(e)])
	# --- results table
	say("")
	say("### Results")
	say("| Run | Brief | Overall vs the ghost | Ending | Player decisions | Outside war: avg / max | War quarters: avg / max | Quiet quarters | Treasury prompts | Routine items seen by the player | Stuck turns |")
	say("|---|---|---|---|---|---|---|---|---|---|---|")
	say("| v3 historical (Full control) | - | %.1f%% | %s | - | - | - | - | - | - | - |" % [v3o, str(v3.get_endings().get("primary", ""))])
	var endings := {}
	for k in runs:
		var res: Dictionary = runs[k]
		var sm: Sim = res["sim"]
		var nw := []; var ww := []
		var quiet := 0
		for t in range(1, sm.state.turn + 1):
			var n := int(res["per"].get(t, 0))
			if n == 0: quiet += 1
			if bool(res["war"].get(t, false)): ww.append(n)
			else: nw.append(n)
		var nwa := float(nw.reduce(func(a, b): return a + b, 0)) / maxf(1.0, nw.size())
		var nwm: int = nw.max() if not nw.is_empty() else 0
		var wwa := float(ww.reduce(func(a, b): return a + b, 0)) / maxf(1.0, ww.size())
		var wwm: int = ww.max() if not ww.is_empty() else 0
		var tot := 0
		for t2 in res["per"]: tot += int(res["per"][t2])
		res["nwa"] = nwa; res["nwm"] = nwm
		var en := str(sm.get_endings().get("primary", ""))
		say("| casual %s | %s | %.1f%% | %s | %d | %.2f / %d | %.2f / %d | %d | %d | %d | %d |" % [k, str(res["brief"]), float(sm.score.current()["overall"]), en, tot,
			nwa, nwm, wwa, wwm, quiet, int(res["treasury"]), int(res["viol"]), int(res["stuck"])])
		if k.begins_with("strategist_"): endings[en] = int(endings.get(en, 0)) + 1
		if nwa > 2.0: fail("casual %s: %.2f player decisions a quarter outside war (V4 box 3: at most 2 on average)" % [k, nwa])
		if nwm > 4: fail("casual %s: a quarter outside war needed %d player decisions (V4 box 3: at most 4)" % [k, nwm])
		if int(res["viol"]) > 0: fail("casual %s: routine decisions reached the player %d times, e.g. %s (V4 box 1)" % [k, int(res["viol"]), str(res["viol_ex"])])
		if int(res["stuck"]) > 0: fail("casual %s: %d quarters could not end normally" % [k, int(res["stuck"])])
		if int(res["card_bad"]) > 0: fail("casual %s: %d of %d story cards broke the 3-option / history / consequence rules, e.g. %s" % [k, int(res["card_bad"]), int(res["cards"]), str(res["card_ex"])])
		if int(res["bad_lines"]) > 0: fail("casual %s: %d report lines without a valid key or text, e.g. %s" % [k, int(res["bad_lines"]), str(res["bad_line_ex"])])
		var st: Dictionary = sm.auto.stats()
		if int(st["actions"]) != int(st["covered"]) or int(st["lines"]) == 0:
			fail("casual %s: %d automatic actions but %d covered by report lines (%d lines)" % [k, int(st["actions"]), int(st["covered"]), int(st["lines"])])
		res["st"] = st
		# v4 fix round (v4fix-sim): the veteran critic's M1-M3, the report's wording and the last quarter
		for chk in [["m1_bad", "the immigration card hides the people left in camps (M1)"], ["m2_bad", "an option that cannot be taken is recommended, or says no reason (M2)"],
				["m3_bad", "the Recommended reason disagrees with the card's numbers (M3)"], ["words_bad", "consequence lines with jargon or a -0 / doubled 'now'"],
				["report_bad", "report lines with a wrong plural, prefix, repeat or -0 gold"], ["last_surplus", "an 'invest the surplus' prompt in the last quarter"]]:
			if int(res.get(chk[0], 0)) > 0:
				fail("casual %s: %d times %s, e.g. %s" % [k, int(res[chk[0]]), chk[1], str(res.get(chk[0] + "_ex", []))])
	say("")
	say("A war quarter (V4 box 3's exception) is one with a crisis open at its start OR with front orders answered in it (V4_DESIGN analyze.py):")
	say("a war that breaks out during the quarter (the Six-Day War, Q2 1967) counts as a war quarter although no crisis is open when the quarter starts.")
	for k in runs:
		var busy := []
		var rs: Dictionary = runs[k]
		for t3 in range(1, (rs["sim"] as Sim).state.turn + 1):
			if int(rs["per"].get(t3, 0)) >= 5:
				busy.append("%s %d%s [%s]" % [SimDB.date_label(t3), int(rs["per"][t3]), " (war)" if bool(rs["war"].get(t3, false)) else " (NOT war)", ", ".join(rs.get("ptypes", {}).get(t3, []))])
		say("- %s: quarters with 5+ player decisions: %s" % [k, ", ".join(busy) if not busy.is_empty() else "none"])
	say("")
	say("Decision types answered by the player (casual historical): %s" % (str(runs["historical"]["types"]) if runs.has("historical") else "-"))
	for k in runs:
		var st2: Dictionary = runs[k]["st"]
		say("- %s: %d automatic actions by the ministers, all %d covered by %d report lines; %d story cards checked" % [k, int(st2["actions"]), int(st2["covered"]), int(st2["lines"]), int(runs[k]["cards"])])
	say("")
	say("v4 fix round checks on every card (v4fix-sim): M1 = immigration options with 1,000+ people in camps that say so; M2 = refused clicks on")
	say("unaffordable programmes that gave a reason; M3 = cards whose Recommended reason was checked against the numbers shown.")
	say("| Run | M1 options named / failures | M2 refused clicks with a reason / failures | M3 reasons checked (numeric, mobilisation) / failures | Line wording failures | Report wording failures | Last-quarter surplus prompts |")
	say("|---|---|---|---|---|---|---|")
	for k in runs:
		var r: Dictionary = runs[k]
		say("| %s | %d / %d | %d / %d | %d (%d, %d) / %d | %d | %d | %d |" % [k, int(r.get("m1_opts", 0)), int(r.get("m1_bad", 0)), int(r.get("m2_refused", 0)), int(r.get("m2_bad", 0)),
			int(r.get("m3_cards", 0)), int(r.get("m3_best", 0)), int(r.get("m3_mobilise", 0)), int(r.get("m3_bad", 0)), int(r.get("words_bad", 0)), int(r.get("report_bad", 0)), int(r.get("last_surplus", 0))])
	if runs.has("historical") and int(runs["historical"].get("m1_opts", 0)) == 0:
		fail("casual historical: no immigration card with transit camps was checked (M1)")
	if runs.has("historical") and int(runs["historical"].get("m3_mobilise", 0)) == 0:
		fail("casual historical: no war card recommending mobilisation was checked (M3)")
	# --- balance bars (V4 box 1 and 2)
	say("")
	say("### Balance bars")
	if runs.has("historical"):
		var ho := float((runs["historical"]["sim"] as Sim).score.current()["overall"])
		say("- casual historical %.1f%% against v3 historical %.1f%%: %+.1f points (bar: within 5)" % [ho, v3o, ho - v3o])
		if absf(ho - v3o) > 5.0: fail("casual historical ends %.1f points from v3's historical run (V4 box 1: within 5)" % (ho - v3o))
		if runs.has("varied"):
			var vs: Sim = runs["varied"]["sim"]
			var hs: Sim = runs["historical"]["sim"]
			var vo := float(vs.score.current()["overall"])
			say("- casual varied %.1f%%: %+.1f points above casual historical (bar: 10 or more)" % [vo, vo - ho])
			if vo - ho < 10.0: fail("casual varied ends only %.1f points above casual historical (V4 box 2: 10 or more)" % (vo - ho))
			var hv := hs.score.values(); var vv := vs.score.values()
			var apart := 0
			var cells := []
			for tr in SimScore.TRACKS:
				var id: String = tr["id"]
				var a := float(hv.get(id, 0.0)); var b := float(vv.get(id, 0.0))
				var dd := (b / a - 1.0) * 100.0 if absf(a) > 0.001 else 0.0
				if absf(dd) >= (3.0 if id == "population" else 5.0): apart += 1
				cells.append("%s %+.1f%%" % [id, dd])
			say("- divergence, casual varied against casual historical: %d of 6 tracks apart (bar: 5) (%s)" % [apart, ", ".join(cells)])
			if apart < 5: fail("casual divergence: only %d of 6 tracks apart (V4 box 2: 5)" % apart)
	var nstrat := 0
	for k in runs:
		if str(k).begins_with("strategist_"): nstrat += 1
	if nstrat == 4:
		say("- the four casual strategists reach %d distinct endings: %s (bar: 4)" % [endings.size(), str(endings.keys())])
		if endings.size() < 4: fail("casual strategists reach only %d distinct endings (V4 box 2: 4)" % endings.size())
	# --- story density (V4 box 3)
	say("")
	say("### Casual core story density per quarter, by decade (forks, event choices, war and front orders, coalition, envoys, dedication, named immigration waves)")
	var hdr := "| Decade | v3 historical core |"
	var sep := "|---|---|"
	var dens_runs := runs.keys().filter(func(k): return not (str(k) in CASUAL_BAD))
	for k in dens_runs:
		hdr += " casual %s | %% of v3 |" % k
		sep += "---|---|"
	say(hdr)
	say(sep)
	var dec := {}
	for k in dens_runs:
		dec[k] = _casual_decades(runs[k]["sim"], runs[k]["core"])
	for i in range(CASUAL_DECADES.size()):
		var row := "| %d-%d | %.2f |" % [CASUAL_DECADES[i][0], CASUAL_DECADES[i][1], float(v3dec[i])]
		for k in dens_runs:
			var c := float(dec[k][i])
			var pct := c / float(v3dec[i]) * 100.0 if float(v3dec[i]) > 0.0 else 100.0
			row += " %.2f | %.0f%% |" % [c, pct]
			if c >= 0.0 and float(v3dec[i]) > 0.0:
				if c < 1.0: fail("casual %s: core story density %.2f a quarter in %d-%d (V4 box 3: at least 1.0)" % [k, c, CASUAL_DECADES[i][0], CASUAL_DECADES[i][1]])
				if pct < 70.0: fail("casual %s: core story density in %d-%d is %.0f%% of v3's (V4 box 3: at least 70%%)" % [k, CASUAL_DECADES[i][0], CASUAL_DECADES[i][1], pct])
		say(row)
	# --- the ministers' report, a sample
	if runs.has("historical"):
		var hs2: Sim = runs["historical"]["sim"]
		say("")
		say("### The ministers' report, last quarter of the casual historical run (%s)" % SimDB.date_label(int(hs2.auto.report()["turn"])))
		for l in (hs2.auto.report()["lines"] as Array).slice(0, 12):
			say("- `%s` %s" % [str(l["key"]), str(l["text"])])
		var dl: Array = hs2.auto.S().get("deferred", [])
		say("Programme decisions deferred to a quieter quarter: %d; surplus prompts a year at most %d." % [dl.size(), _max_val(hs2.auto.S().get("surplus_year", {}))])
	for k in runs:
		say("- %s: surplus decisions Finance held without asking the player (yearly quota %d, full quarters, the last quarters): %d" % [k, SimAuto.SURPLUS_QUOTA, int((runs[k]["sim"] as Sim).auto.S().get("held", 0))])
	# --- the flip test
	_casual_flip(seed)
	v3.dispose()
	for k in runs:
		(runs[k]["sim"] as Sim).dispose()


static func _max_val(d: Dictionary) -> int:
	var m := 0
	for k in d:
		m = maxi(m, int(d[k]))
	return m
