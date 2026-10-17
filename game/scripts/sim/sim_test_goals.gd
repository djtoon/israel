class_name SimTestGoals
extends RefCounted
## V4 (v4-goals): sim_test --goals calibration of the era goals (called from sim_test.gd's _eg_modes; owner: v4-goals).
##   "$G" --headless --path game --script res://scripts/sim/sim_test.gd -- --goals [--only=a,b] [--collect] [--regen-ghost] [--seed=S] [--turns=N]
## A full game takes ~4 minutes, so the runs can be split over two processes:
##   --goals --only=ghost,historical       plays those runs and stores progress/v4goals/runs/<name>.json (statuses + the metric trace)
##   --goals --collect                     reads every stored run, prints the table, checks the bars, writes GOALS_REPORT.md
##   --goals                               plays every run, then collects
##   --goals --regen-ghost                 rewrites data/ghost.json from the historical run (Full control, goals off: v3's ghost), then stops
## Bars: history meets 50-80% of the goals; good play meets more than history; ruinous play misses many; no goal ever ends the
## game; goal status survives a save and load; civ/era_goals=false leaves no trace (the v3 regression). The v3 bars with goals on
## are the existing --divergence and --strategies runs.

const BAD := ["ruin_builder", "ruin_populist"]
const GOOD := ["recommended", "strategist_security", "strategist_prosperity", "strategist_peace", "strategist_society"]
const RUNS := ["ghost", "historical", "varied", "recommended", "strategist_security", "strategist_prosperity", "strategist_peace", "strategist_society", "ruin_builder", "ruin_populist", "switch_off"]


static func runs_dir() -> String:
	return ProjectSettings.globalize_path("res://").path_join("../progress/v4goals/runs")


static func _count_rec(rec: Dictionary) -> Array:
	var met := 0
	var judged := 0
	for id in rec["st"]:
		var s := str(rec["st"][id].get("s", ""))
		if s == "met": met += 1
		if s == "met" or s == "missed": judged += 1
	return [met, judged]


const EXTRA := ["readiness", "standing", "inflation", "debt_years", "treaties", "town_strikes_ratio", "min_group_trust", "housing_shortfall",
	"track_ratio:population", "track_ratio:economy", "track_ratio:science", "track_ratio:water", "track_ratio:standing", "track_ratio:cohesion",
	"avg_trust", "population", "cities", "overall", "collapse_danger", "trust:arab", "trust:dev_towns", "trust:periphery", "trust:large_cities",
	"programme_levels:peace", "programme_levels:prosperity", "programme_levels:security", "programme_levels:society",
	"programme_level:mashav", "programme_level:talpiot", "programme_level:innovation", "programme_level:space_cyber", "programme_level:missile_shield",
	"programme_level:desalination", "programme_level:gas", "programme_level:peace_economy", "programme_level:arab_development", "programme_level:health",
	"project:national_water_carrier", "project:ashkelon_desalination", "project:sorek_desalination"]
const EXTRA_STATUS := ["egypt", "jordan", "uae", "saudi_arabia", "lebanon", "syria", "palestinians", "usa", "germany"]


static func _metrics() -> Dictionary:
	var out := {}
	for m in EXTRA:
		out[m] = {"metric": m}
	for a in EXTRA_STATUS:
		out["status:" + a] = {"metric": "status:" + a, "in": []}
	for g in SimGoals.goal_defs():
		for c in g.get("all", g.get("any", [])):
			out[str(c["metric"])] = c
	return out


static func _trace_value(sm: Sim, m: String, c: Dictionary):
	if c.has("in"):
		return str(sm.state.diplomacy.get(m.substr(7), {}).get("status", "none"))
	return snappedf(sm.goals.metric(m), 0.0001)


static func _play_run(t, name: String, seed: int, max_turn: int) -> Dictionary:
	var sm := Sim.new()
	var off: bool = name == "switch_off"
	if off:
		ProjectSettings.set_setting("civ/era_goals", false)
		max_turn = mini(max_turn, 160)
	# v4 fix round: goals are off by default in Full control (v3); the calibration plays Full control with them switched on
	sm.new_game({"mode": "historical" if name == "ghost" else "player", "seed": seed, "difficulty": "normal", "goals": true})
	sm.state.counters["ai_style"] = "historical" if name == "ghost" else ("recommended" if off else name)
	var rec := {"name": name, "trace": {}, "notes": 0, "bad": 0, "roundtrip": "", "leaked": 0}
	var mets := _metrics()
	for m in mets:
		rec["trace"][m] = []
	var watcher := {"n": 0, "bad": 0}
	sm.notification.connect(func(x):
		if str(x.get("kind", "")) == "goal":
			watcher["n"] += 1
			if sm.state.game_over:
				watcher["bad"] += 1)
	sm.turn_ended.connect(func(_tn):
		if off:
			return
		for m in mets:
			rec["trace"][m].append(_trace_value(sm, m, mets[m])))
	var loaded := false
	while not sm.state.game_over and sm.state.turn <= max_turn:
		if name == "recommended" and sm.state.turn == 120 and not loaded:
			loaded = true
			rec["roundtrip"] = _roundtrip(sm)
		SimAI.play_turn(sm)
	rec["notes"] = watcher["n"]
	rec["bad"] = watcher["bad"]
	rec["date"] = sm.date_label()
	rec["collapse"] = sm.collapse.ended_id() if sm.collapse.ended() else ""
	rec["errors"] = sm.state.errors.slice(0, 5)
	rec["st"] = sm.state.counters.get("goals", {}).get("st", {}).duplicate(true)
	var es: Dictionary = sm.get_end_summary().get("goals", {})
	rec["end_summary"] = es
	rec["view1"] = sm.goals.view(1)["goals"].size()
	rec["all8"] = sm.goals.all().size()
	if off:
		var streams_goal := sm.state.streams.filter(func(s): return str(s.get("src", "")) == "goal").size()
		rec["off_clean"] = watcher["n"] == 0 and streams_goal == 0 and sm.goals.track_bonus().is_empty() and sm.goals.discount("gas", 2) == 1.0 \
			and sm.goals.view(1)["goals"].is_empty() and es.is_empty()
		ProjectSettings.set_setting("civ/era_goals", true)
	var overall := sm.score.current()
	rec["overall"] = snappedf(float(overall.get("overall", 0.0)), 0.1)
	sm.dispose()
	return rec


static func _roundtrip(sm: Sim) -> String:
	var before: Dictionary = sm.state.counters["goals"]["st"].duplicate(true)
	var path := "user://goals_roundtrip.json"
	sm.save_game(path)
	var s2 := Sim.new()
	if not s2.load_game(path):
		return "could not reload the save"
	var after: Dictionary = s2.state.counters["goals"]["st"]
	var same := before.size() == after.size()
	for k in before:
		if not after.has(k) or str(after[k].get("s")) != str(before[k].get("s")):
			same = false
	# the reloaded game goes on judging goals
	var guard := 0
	var t0: int = s2.state.turn
	while not s2.state.game_over and s2.state.turn < t0 + 12 and guard < 40:
		SimAI.play_turn(s2)
		guard += 1
	var more: bool = s2.state.counters["goals"]["st"].size() >= after.size()
	s2.dispose()
	return "ok (%d statuses kept)" % after.size() if same and more else "goal status changed across save and load"


static func _store(rec: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(runs_dir())
	var f := FileAccess.open(runs_dir().path_join(str(rec["name"]) + ".json"), FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(rec))


static func _load_rec(name: String) -> Dictionary:
	var p := runs_dir().path_join(name + ".json")
	if not FileAccess.file_exists(p):
		return {}
	var d = JSON.parse_string(FileAccess.get_file_as_string(p))
	return d if typeof(d) == TYPE_DICTIONARY else {}


static func _regen_ghost(t, seed: int, max_turn: int) -> void:
	## v4 fix round: the ghost is history's Full-control run with the goals OFF (v3's ghost; the full sim_test writes the same).
	t.say("Regenerating the ghost of history (Full control, era goals off, two passes)...")
	for pass_i in range(2):
		var g := Sim.new()
		g.new_game({"mode": "historical", "seed": seed, "goals": false})
		g.state.counters["ai_style"] = "historical"
		while not g.state.game_over and g.state.turn <= max_turn:
			SimAI.play_turn(g)
		var err: Error = g.score.export_ghost("res://data/ghost.json")
		if err != OK:
			t.fail("goals: could not write ghost.json (%s)" % err)
		g.dispose()
		SimDB.reload_db()
	t.say("ghost.json rewritten (era goals off)")


static func run(t, seed: int, max_turn: int, args: Array) -> void:
	t.say("")
	t.say("## Era goals calibration (V4, to %s)" % SimDB.date_label(mini(max_turn, Sim.last_playable_turn())))
	var full: bool = max_turn >= Sim.last_playable_turn()
	_data_checks(t)
	_style_checks(t, seed)
	if "--regen-ghost" in args:
		_regen_ghost(t, seed, max_turn)
		return
	var only := []
	for a in args:
		if a.begins_with("--only="):
			only = a.substr(7).split(",", false)
	if not ("--collect" in args):
		for n in (only if not only.is_empty() else RUNS):
			t.say("running %s ..." % n)
			var rec := _play_run(t, str(n), seed, max_turn)
			_store(rec)
			t.say("  %s: %s, met %d of %d judged%s" % [n, rec["date"], _count_rec(rec)[0], _count_rec(rec)[1], (" COLLAPSE " + str(rec["collapse"])) if rec["collapse"] != "" else ""])
		if not only.is_empty():
			return
	_collect(t, full)


static func _style_checks(t, seed: int) -> void:
	## v4 fix round: the goals follow the play style (on in story mode, off in Full control) and the setting overrides both.
	var cases := [[{}, false, "Full control (default)"], [{"play_style": "story"}, true, "story mode"], [{"play_style": "full", "goals": true}, true, "Full control with goals on"],
		[{"play_style": "story", "goals": false}, false, "story mode with goals off"]]
	var cells := []
	for c in cases:
		var sm := Sim.new()
		var o: Dictionary = (c[0] as Dictionary).duplicate()
		o["seed"] = seed
		sm.new_game(o)
		var on: bool = sm.goals.enabled()
		cells.append("%s: %s" % [c[2], "on" if on else "off"])
		if on != bool(c[1]):
			t.fail("goals: %s has the era goals %s (want %s)" % [c[2], "on" if on else "off", "on" if c[1] else "off"])
		if c[2] == "story mode":
			sm.goals.set_enabled(false)
			if sm.goals.enabled() or not sm.goals.view(1)["goals"].is_empty():
				t.fail("goals: set_enabled(false) mid-game did not switch the goals off")
		sm.dispose()
	t.say("goals by play style: " + "; ".join(cells))


static func _data_checks(t) -> void:
	var defs := SimGoals.goal_defs()
	if defs.size() != 24:
		t.fail("goals: %d goals in era_goals.json (V4 design: 24, three per era)" % defs.size())
	var per_era := {}
	var kinds := ["track_bonus", "programme_discount", "stream", "story_beat", "none"]
	var db := SimDB.get_db()
	for g in defs:
		per_era[str(g["era"])] = int(per_era.get(str(g["era"]), 0)) + 1
		for k in ["reward", "setback"]:
			var e: Dictionary = g.get(k, {})
			if not (str(e.get("kind", "")) in kinds):
				t.fail("goals: %s %s has kind '%s' (only %s: a goal never ends the game)" % [g["id"], k, e.get("kind", ""), ", ".join(kinds)])
			if str(e.get("kind", "")) == "stream" and (absf(float(e.get("amount", 0))) > 15.0 or int(e.get("quarters", 0)) > 40):
				t.fail("goals: %s %s stream is not small (%s)" % [g["id"], k, str(e)])
			if str(e.get("desc", "")) == "":
				t.fail("goals: %s %s has no desc" % [g["id"], k])
		for k in ["title", "text", "history", "source"]:
			if (typeof(g.get(k)) == TYPE_STRING and str(g.get(k)) == "") or (typeof(g.get(k)) == TYPE_ARRAY and g.get(k).is_empty()):
				t.fail("goals: %s has no %s" % [g["id"], k])
		for sid in g.get("source", []):
			if not db.sources.has(str(sid)):
				t.say("goals note: %s cites %s, which the sim catalog does not list (check_sources.py validates the ids)" % [g["id"], sid])
	for i in range(1, 9):
		if int(per_era.get("era%d" % i, 0)) != 3:
			t.fail("goals: era%d has %d goals (needs 3)" % [i, int(per_era.get("era%d" % i, 0))])


static func _collect(t, full: bool) -> void:
	var defs := SimGoals.goal_defs()
	var recs := {}
	for n in RUNS:
		var r := _load_rec(n)
		if r.is_empty():
			t.fail("goals: no stored run '%s' (play it first with --only=%s)" % [n, n])
		else:
			recs[n] = r
	if recs.size() < RUNS.size():
		return
	var names := RUNS.filter(func(n): return n != "switch_off")
	t.say("")
	t.say("| Goal | " + " | ".join(names) + " |")
	t.say("|---|" + "---|".repeat(names.size()))
	for g in defs:
		var id := str(g["id"])
		var row := "| %s%s |" % [id, " (history missed)" if g.get("history_missed", false) else ""]
		for n in names:
			var s := str(recs[n]["st"].get(id, {}).get("s", "..."))
			row += " %s |" % {"met": "met", "missed": "-", "skipped": "skip"}.get(s, s)
		t.say(row)
	t.say("")
	t.say("| Run | goals met | judged | share | overall | ended | ending |")
	t.say("|---|---|---|---|---|---|---|")
	var share := {}
	for n in names:
		var c := _count_rec(recs[n])
		share[n] = float(c[0]) / float(defs.size())   # goals met out of all 24 (a collapse leaves the later goals unmet)
		t.say("| %s | %d | %d | %.0f%% | %s | %s | %s |" % [n, c[0], c[1], 100.0 * share[n], str(recs[n].get("overall", "")), recs[n]["date"],
			("COLLAPSE " + str(recs[n]["collapse"])) if recs[n]["collapse"] != "" else "-"])
	t.say("")
	t.say("Progress at judgement (ghost / historical / recommended):")
	for g in defs:
		var id := str(g["id"])
		var cells := []
		for n in ["ghost", "historical", "recommended"]:
			var r: Dictionary = recs[n]["st"].get(id, {})
			cells.append("%s %s (%s)" % [n, str(r.get("s", "?")), str(r.get("l", ""))])
		t.say("- %s: %s" % [id, "; ".join(cells)])
	var hs: float = share["ghost"]
	var hp: float = share["historical"]
	if full:
		for pair in [["ghost", hs], ["historical (player mode, history's picks)", hp]]:
			if float(pair[1]) < 0.5 or float(pair[1]) > 0.8:
				t.fail("goals: %s meets %.0f%% of the goals (bar 50-80%%)" % [pair[0], 100.0 * float(pair[1])])
		var best := 0.0
		var best_n := ""
		for n in GOOD:
			if recs[n]["collapse"] != "":
				continue
			if share[n] > best:
				best = share[n]; best_n = n
		if best <= maxf(hs, hp):
			t.fail("goals: good play (best %s %.0f%%) does not meet more goals than history (%.0f%% / %.0f%%)" % [best_n, 100.0 * best, 100.0 * hs, 100.0 * hp])
		if share["recommended"] < minf(hs, hp) - 0.0001:
			t.fail("goals: Recommended play (%.0f%%) meets fewer goals than history (%.0f%%)" % [100.0 * share["recommended"], 100.0 * minf(hs, hp)])
		for n in BAD:
			if share[n] > 0.5:
				t.fail("goals: the ruinous driver %s still meets %.0f%% of the goals (bar: at most 50%%)" % [n, 100.0 * share[n]])
		var bad_avg: float = (float(share[BAD[0]]) + float(share[BAD[1]])) / 2.0
		t.say("")
		t.say("History %.0f%% / %.0f%%, best good play %s %.0f%%, ruinous drivers average %.0f%%" % [100.0 * hs, 100.0 * hp, best_n, 100.0 * best, 100.0 * bad_avg])
		if bad_avg > hs - 0.15:
			t.fail("goals: bad play (%.0f%%) is not clearly below history (%.0f%%)" % [100.0 * bad_avg, 100.0 * hs])
	for n in names:
		if int(recs[n]["bad"]) > 0:
			t.fail("goals: run %s: a goal notification arrived with the game already over" % n)
		if n != "ghost" and n not in BAD and recs[n]["collapse"] != "" and full:
			t.fail("goals: %s collapsed with the goals on (%s)" % [n, recs[n]["collapse"]])
		for e in recs[n]["errors"]:
			t.fail("goals run %s sim error: %s" % [n, e])
	var rt := str(recs["recommended"].get("roundtrip", ""))
	if not rt.begins_with("ok"):
		t.fail("goals: save/load: " + rt)
	else:
		t.say("save/load at turn 120: " + rt)
	var es: Dictionary = recs["recommended"].get("end_summary", {})
	if es.is_empty() or int(es.get("total", 0)) != 24:
		t.fail("goals: get_end_summary() has no Goals section")
	else:
		t.say("End summary (Recommended): met %d, missed %d of %d judged; like history %d, ahead of history %d, behind history %d" % [
			es["met"], es["missed"], es["judged"], es["met_like_history"], es["ahead_of_history"], es["behind_history"]])
	if int(recs["recommended"]["view1"]) != 3 or int(recs["recommended"]["all8"]) != 8:
		t.fail("goals: view(1) is not three goals, or all() is not 8 eras")
	if not bool(recs["switch_off"].get("off_clean", false)):
		t.fail("goals: civ/era_goals=false left a trace (notification, stream, bonus, discount, view or summary)")
	else:
		t.say("civ/era_goals=false: no goal notification, stream, bonus, discount, view or summary (the v3 numbers)")
	# ghost_meets for the data generator
	var gm := {}
	for g in defs:
		gm[str(g["id"])] = str(recs["ghost"]["st"].get(str(g["id"]), {}).get("s", "")) == "met"
	var f := FileAccess.open(ProjectSettings.globalize_path("res://").path_join("../progress/v4goals/ghost_meets.json"), FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(gm, "\t"))
