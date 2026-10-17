class_name Sim
extends RefCounted
## Israel: The Birth of a Nation - headless turn engine and the API the UI calls.
##
## Fixed rails, free tracks (MECHANICS.md 29): dated history (wars, elections, treaties, immigration
## totals, borders, foundings) always happens; the player decides how the country is built.
##
## Typical UI use:
##   var sim := Sim.new(); sim.new_game()
##   sim.turn_started.connect(...); sim.get_pending_decisions(); sim.next_action()
##   sim.set_research(id) / sim.set_production(city_id, "building", id) / sim.choose_event(id, i) ...
##   sim.end_turn()      # returns false (and does nothing) while a blocking decision is open; end_turn(true) forces.

signal turn_started(turn: int, date: String)
signal turn_ended(turn: int)
signal notification(n: Dictionary)
signal city_founded(city_id: int)
signal city_changed(city_id: int)
signal city_removed(city_id: int)
signal production_completed(city_id: int, kind: String, item: String)
signal tech_completed(id: String)
signal civic_completed(id: String)
signal boost_triggered(kind: String, id: String, text: String)
signal event_fired(event_id: String)
signal crisis_started(crisis: Dictionary)
signal crisis_ended(crisis: Dictionary)
signal unit_created(unit_id: int)
signal unit_moved(unit_id: int, from: Vector2i, to: Vector2i)
signal unit_removed(unit_id: int)
signal combat(result: Dictionary)
signal diplomacy_changed(actor: String, status: String)
signal era_changed(era: int, age: String)
signal historic_moment(m: Dictionary)
signal territory_changed()
signal game_over(summary: Dictionary)

const PLAYER_STATUSES := ["israel", "israel_west_only", "israel_with_annexed_east", "israel_military_government",
	"israeli_law_applied", "israeli_settlement", "israeli_settlement_west_bank", "israeli_settlement_gaza",
	"israeli_settlement_sinai", "israeli_settlement_golan", "israeli_controlled", "israeli_occupied",
	"israeli_law_applied_druze_residents", "state_of_emergency"]
const FOREIGN_KINDS := ["palestinian_city", "syrian_city", "jordanian_city", "egyptian_city", "lebanese_city"]
const EVACUATED := ["evacuated", "evacuated_and_demolished"]
const MILITARY_CLASSES := ["melee", "siege", "armor", "air", "naval", "defense"]

var db: SimDB
var state: GameState
var econ: SimEconomy
var events: SimEvents
var military: SimMilitary
var score: SimScore
var forks: SimForks
var cabinet: SimCabinet
var endgame: SimEndgame       # v3 (sim-endgame): difficulty, national programmes, endings, fiscal indicator, scenarios
var diplo: SimDiplomacy       # v3 (sim-diplomacy): relations with causes, status timelines, deals, envoys
var goals: SimGoals           # V4 (v4-goals): era goals (data/era_goals.json); civ/era_goals=false is the v3 regression
var collapse: SimCollapse     # v3 item 13 (fix-v3a): soft fail states (early game-over endings for a collapse of the state)
var auto: SimAuto             # V4 (v4-sim-auto): the casual layer (story mode: ministers run the routine); Full control = v3
var rng := RandomNumberGenerator.new()
var avg_buildings_per_pop := 0.0
var stats := {}               # per-turn counters for boosts (rebuilt each turn)
var _cities := {}             # id -> SimCity
var _city_pos := {}           # tile key -> SimCity
var _units := {}              # id -> SimUnit
var _national := {}           # national yields this turn
var _in_process := false      # V4: inside _process_turn (the ministers do not act while the quarter is being processed)


func _init() -> void:
	db = SimDB.get_db()
	econ = SimEconomy.new(self)
	events = SimEvents.new(self)
	military = SimMilitary.new(self)
	score = SimScore.new(self)
	forks = SimForks.new(self)
	cabinet = SimCabinet.new(self)
	endgame = SimEndgame.new(self)
	diplo = SimDiplomacy.new(self)
	collapse = SimCollapse.new(self)
	goals = SimGoals.new(self)
	auto = SimAuto.new(self)


# ================================================================== lifecycle

func new_game(opts := {}) -> void:
	if str(opts.get("scenario", "")) != "" and endgame.start_scenario(opts):
		# v3: a scenario start (1967, 1977, 1992) seeded from the historical run (SimEndgame.scenario_list())
		auto.on_new_game(opts)   # V4: play_style ("story" | "full", default "full")
		goals.on_new_game(opts)  # v4 fix round: era goals on in story mode, off in Full control (opts "goals" overrides)
		if not auto.is_full():
			auto.settle()
			state.last_decisions = get_pending_decisions()
		return
	state = GameState.new()
	state.mode = str(opts.get("mode", "player"))
	state.rng_seed = int(opts.get("seed", 1948))
	rng.seed = state.rng_seed
	econ.calibrate()
	econ.tiles_dirty = true
	econ.border_cache_era = ""
	_reindex()
	for a in db.actors:
		state.diplomacy[a] = {"status": "none", "relation": 0.0, "since": 1, "last_delegation": -99}
	for c in db.civic_list:
		if c.get("start_known", false):
			state.civics[c["id"]] = 0
	state.capital = "tel_aviv"
	var res_total := 0.0
	for entry in db.cities:
		if _entry_active_at(entry, 1) and _entry_existing_at(entry, 1):
			var c := _create_city(entry, "history", 1)
			res_total += c.residents
	var real0 := db.real_value("population", SimDB.year_f(1))
	if real0 <= 0: real0 = 806000.0
	state.rural = maxf(50000.0, real0 - res_total)
	state.counters["rural_base"] = state.rural * 1.15
	_apply_start_assets()
	var sb := {}
	for c in state.cities:
		for b in c.buildings:
			sb[b] = int(sb.get(b, 0)) + 1
	state.counters["start_buildings"] = sb
	refresh()
	for c in state.cities:
		_settle_legacy(c)
	_seed_start_milestones()
	_seed_improvements()
	military.spawn_start_units()
	# rail: the 1948 war left a defence budget and war debts that dominated the austerity years
	state.streams.append({"type": "gold", "amount": -15.0, "from": SimDB.turn_of("1949-01", 3), "until": SimDB.turn_of("1952-12", 19),
		"label": "Defence budget and war debts after 1948", "src": "rail"})
	state.streams.append({"type": "gold", "amount": -15.0, "from": SimDB.turn_of("1953-01", 20), "until": SimDB.turn_of("1955-12", 31),
		"label": "Defence budget and war debts after 1948", "src": "rail"})
	# rail: after 1973 defence spending and economy-wide wage indexation opened a deficit that fed the
	# 1979-85 inflation; it lasts until a stabilization programme is adopted (history: 1 July 1985, S577, S584)
	state.streams.append({"type": "gold", "amount": -45.0, "from": SimDB.turn_of("1974-01", 103), "until": SimDB.LAST_TURN,
		"label": "Post-1973 defence burden and indexed wages", "src": "rail", "ends_with_policy": "stabilization_plan", "ends_with_inflation_below": 30.0, "ends_with_inflation_from": 1985.5,
		"start_text": "After the Yom Kippur War, defence spending and wages indexed to prices open a deficit of about 45 gold a turn. It feeds inflation and lasts until a stabilization programme is adopted (history: July 1985: the Stabilization Plan policy card) or, after mid-1985, once inflation has stayed below 30% for a year."})
	events.apply_government(true)
	events.apply_rails(true)
	endgame.on_new_game(opts)   # v3: difficulty (opts.difficulty) and its 1948 treasury
	auto.on_new_game(opts)      # V4: play_style "story" (ministers on auto) or "full" (default: v3, no casual state)
	goals.on_new_game(opts)     # v4 fix round: era goals on in story mode, off in Full control (opts "goals" overrides)
	refresh()
	_start_turn()


func load_game(path: String) -> bool:
	var s := GameState.load_json(path)
	if s == null:
		return false
	state = s
	rng.seed = state.rng_seed
	rng.state = state.rng_state
	econ.calibrate()
	econ.tiles_dirty = true
	econ.border_cache_era = ""
	_reindex()
	refresh()
	if not state.counters.has("difficulty"): state.counters["difficulty"] = "normal"   # v2 saves
	if state.turn > Sim.full_last_turn():
		# v3 fix3-econ (A12): an old save played past the game's end (Q4 2026) reads as the real end, Q3 2023
		state.turn = Sim.full_last_turn()
		state.game_over = true
	return true


static func peek_save(path: String) -> Dictionary:
	## Save-slot header without loading the game: {turn, label, era_name, mode, game_over} ({} if unreadable).
	if not FileAccess.file_exists(path):
		return {}
	var data = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(data) != TYPE_DICTIONARY:
		return {}
	var t := int(data.get("turn", 1))
	return {"turn": t, "label": SimDB.date_label(t), "era_name": SimDB.get_db().era_at(t).get("name", ""), "mode": str(data.get("mode", "player")),
		"game_over": bool(data.get("game_over", false))}


func save_game(path: String) -> bool:
	state.rng_state = rng.state
	return state.save_json(path) == OK


func dispose() -> void:
	## Break helper reference cycles when discarding a Sim.
	econ.sim = null; events.sim = null; military.sim = null; score.sim = null; forks.sim = null; cabinet.sim = null; endgame.sim = null; diplo.sim = null; collapse.sim = null; goals.sim = null; auto.sim = null


# ================================================================== indexes

func _reindex() -> void:
	_cities.clear(); _city_pos.clear(); _units.clear()
	for c in state.cities:
		_cities[c.id] = c
		if c.active:
			_city_pos[SimHex.key(c.q, c.r)] = c
	for u in state.units:
		_units[u.id] = u


func city_by_id(id: int):
	return _cities.get(id)


func city_by_key(key: String):
	for c in state.cities:
		if c.key == key:
			return c
	return null


func city_at(p: Vector2i):
	return _city_pos.get(SimHex.key(p.x, p.y))


func unit_by_id(id: int):
	return _units.get(id)


func active_cities() -> Array:
	return state.cities.filter(func(c): return c.active)


func new_id() -> int:
	state.next_id += 1
	return state.next_id


func notify(kind: String, text: String, extra := {}) -> void:
	var n := {"turn": state.turn, "kind": kind, "text": text}
	n.merge(extra)
	state.notifications.append(n)
	notification.emit(n)


func log_error(msg: String) -> void:
	state.errors.append("T%d %s" % [state.turn, msg])
	push_warning("sim: " + msg)


func year() -> int:
	return SimDB.year_of(state.turn)


func date_label() -> String:
	return SimDB.date_label(state.turn)


# ================================================================== cities

func _entry_active_at(entry: Dictionary, turn: int) -> bool:
	if str(entry.get("kind", "")) in FOREIGN_KINDS:
		return false
	var st := db.city_status_at(entry, turn)
	return st in PLAYER_STATUSES


func _entry_existing_at(entry: Dictionary, turn: int) -> bool:
	## True for localities that already exist (pre-1948 or with a 1948 census figure).
	var pop: Dictionary = entry.get("population", {})
	if pop.has("1948") and pop["1948"] != null:
		return true
	var f = entry.get("founded")
	if f == null:
		return true
	return SimDB.turn_of(f, 0) <= 0 or int(str(f).substr(0, 4)) < 1948


func _create_city(entry: Dictionary, by: String, turn: int, residents := -1.0) -> SimCity:
	var c := SimCity.new()
	c.id = new_id()
	c.key = str(entry["id"])
	c.name = city_name_at(c.key, str(entry.get("name", c.key)))
	c.name_he = str(entry.get("name_he", ""))
	c.kind = str(entry.get("kind", "city"))
	c.q = int(entry["q"]); c.r = int(entry["r"])
	c.founded_turn = turn
	c.founded_by = by
	c.hist_founded_turn = hist_turn_of(entry)
	c.status = db.city_status_at(entry, turn)
	if residents < 0:
		residents = start_residents(entry, turn)
	c.residents = residents
	c.trust = 80.0
	c.automate = c.kind in ["kibbutz", "moshav"]   # villages run themselves (less click load; toggle with set_city_automated)
	state.cities.append(c)
	_cities[c.id] = c
	_city_pos[SimHex.key(c.q, c.r)] = c
	var ck := SimHex.key(c.q, c.r)
	econ.tstate(ck)["o"] = 0
	econ.tstate(ck)["imp"] = ""
	econ.initial_claim(c)
	return c


func hist_turn_of(entry: Dictionary) -> int:
	## Real founding/joining turn: the earlier of the founding date and the first Israeli status.
	var t := 1
	var f = entry.get("founded")
	if f != null and int(str(f).substr(0, 4)) >= 1948:
		t = SimDB.turn_of(f, 1)
	for s in entry.get("status", []):
		if str(s.get("status")) in PLAYER_STATUSES:
			t = maxi(t, SimDB.turn_of(s.get("from"), 1))
			break
	var ev = events.found_event_for(str(entry["id"]))
	if ev != null:
		t = mini(t, int(ev["_turn"])) if t > 1 else int(ev["_turn"])
	return maxi(1, t)


func start_residents(entry: Dictionary, turn: int) -> float:
	var y := SimDB.year_f(turn)
	var pop: Dictionary = entry.get("population", {})
	var first_year := 9999
	for k in pop:
		if pop[k] != null:
			first_year = mini(first_year, int(k))
	if first_year == 9999:
		return 1500.0
	var first_pop := float(pop[str(first_year)])
	if y >= first_year + 0.5 or pop.has("1948"):
		return maxf(minf(300.0, first_pop), db.city_pop_at(entry, y))
	if _entry_existing_at(entry, 1):
		# pre-existing locality without an early census: back-extrapolate at 3% a year
		return maxf(minf(500.0, first_pop), first_pop / pow(1.03, first_year + 0.5 - y))
	# a new locality founded before its first census (fix-cabinet, V2_FIXES C2): seeded from that census, growing
	# from its founding group (a kibbutz of 59 starts with 59, not 1,500; a new town starts small)
	var fy := float(str(entry.get("founded", str(first_year))).substr(0, 4))
	var f := clampf((y - fy + 1.0) / maxf(1.0, first_year + 0.5 - fy + 1.0), 0.0, 1.0)
	return maxf(minf(first_pop, 300.0), first_pop * f)


func _settle_legacy(c: SimCity) -> void:
	## Cities that exist at start (or join later) bring their housing stock and services with them.
	var P := c.pop()
	c.legacy_housing = maxf(0.0, P + 1.0 - (float(c.info.get("housing", 0.0)) - c.legacy_housing))
	var need := float(c.info.get("amen_required", 0)) - (float(c.info.get("amen_sources", 0)) - c.legacy_amenities)
	c.legacy_amenities = maxf(0.0, need)


func _apply_start_assets() -> void:
	for a in db.gov.get("start_assets", []):
		var c = city_by_key(str(a.get("city", "")))
		if c == null:
			continue
		var did := str(a.get("district", ""))
		if did != "" and not c.has_district(did):
			var sites := econ.district_sites(c, did)
			if sites.size() > 0:
				_place_district(c, did, SimHex.key(int(sites[0]["q"]), int(sites[0]["r"])))
		for b in a.get("buildings", []):
			if not c.has_building(b):
				c.buildings.append(b)


func _seed_improvements() -> void:
	## Farms and groves that already existed in 1948 around agricultural localities (deterministic).
	for c in state.cities:
		for k in econ.city_tile_keys(c):
			if k == SimHex.key(c.q, c.r):
				continue
			var t = db.tiles.get(k)
			if t == null:
				continue
			var res := econ.resource(k)
			var terr := econ.terrain(k)
			var h := SimHex.from_key(k)
			var roll := float((h.x * 73 + h.y * 151) % 100) / 100.0
			econ.tstate(k)["seed"] = true
			if res in SimEconomy.LUXURIES:
				econ.tstate(k)["imp"] = "grove"
			elif c.kind in ["kibbutz", "moshav"] and SimHex.distance(h, c.pos()) == 1 and terr in ["grassland", "plains", "hills", "desert"] and _no_adjacent_imp(k, "kibbutz"):
				econ.tstate(k)["imp"] = "kibbutz" if c.kind == "kibbutz" else "farm"
			elif terr in ["grassland", "plains"] and float(t.get("rain_mm", 300)) >= 350 and roll < 0.45 and c.pop() <= 8:
				econ.tstate(k)["imp"] = "farm"


func _no_adjacent_imp(k: int, imp: String) -> bool:
	var p := SimHex.from_key(k)
	for n in SimHex.neighbors(p.x, p.y):
		if str(econ.tstate(SimHex.key(n.x, n.y)).get("imp", "")) == imp:
			return false
	return true


func found_city(entry: Dictionary, by: String, residents := -1.0, quiet := false) -> SimCity:
	## Founds (or reactivates) a city at a real locality from cities.json.
	var existing = city_by_key(str(entry["id"]))
	if existing != null:
		return existing
	var c := _create_city(entry, by, state.turn, residents)
	refresh_city(c)
	if by != "player":
		_settle_legacy(c)
	else:
		c.legacy_housing = 2.0
	state.milestones["town:" + c.key] = state.turn
	if by == "player":
		state.counters["towns_founded"] = int(state.counters.get("towns_founded", 0)) + 1
		var desert := econ.terrain(SimHex.key(c.q, c.r)) in ["desert", "desert_hills"]
		var early := c.hist_founded_turn - state.turn
		add_moment("Founded %s%s" % [c.name, (" (%d turns before the historical date)" % early) if early > 0 else ""], 2 if desert else 1, "town")
	if not quiet:
		notify("city_founded", "%s founded (%s)." % [c.name, "by your settlers" if by == "player" else "historical date"], {"city": c.id})
	city_founded.emit(c.id)
	territory_changed.emit()
	return c


func deactivate_city(c: SimCity, reason: String) -> void:
	## Evacuation (e.g. Yamit 1982, Gush Katif 2005): residents move to the nearest cities; tiles are released.
	if not c.active:
		return
	c.active = false
	var moved := c.residents
	var near: Array = active_cities()
	near.sort_custom(func(a, b): return SimHex.distance(a.pos(), c.pos()) < SimHex.distance(b.pos(), c.pos()))
	for i in range(mini(3, near.size())):
		near[i].residents += moved / mini(3, near.size())
	c.residents = 0.0
	for k in econ.city_tile_keys(c):
		var ts := econ.tstate(k)
		ts["o"] = 0; ts["d"] = ""; ts["imp"] = ""
	econ.tiles_dirty = true
	_city_pos.erase(SimHex.key(c.q, c.r))
	notify("city_removed", "%s: %s. %d residents relocated." % [c.name, reason, int(moved)], {"city": c.id})
	city_removed.emit(c.id)
	territory_changed.emit()


func refresh_city(c: SimCity) -> void:
	econ.compute_city(c)
	c.info["amen_sources"] = c.info.get("amen_sources", 0.0)
	var bal: float = c.info["amen_sources"] - c.info["amen_required"]
	c.info["amenity_balance"] = bal


func refresh() -> void:
	## Recompute every city's yields, housing, amenities (no side effects). Call after any change.
	econ.rebuild_mods()
	econ.compute_emitters()
	var nb := 0.0; var np := 0.0
	for c in state.cities:
		if c.active:
			econ.compute_city(c)
			nb += c.buildings.size(); np += c.pop()
	avg_buildings_per_pop = nb / maxf(1.0, np)
	econ.allocate_amenities()
	for c in state.cities:
		if c.active:
			econ.finalize_city(c)
	_compute_national()


func _compute_national() -> void:
	var n := {"food": 0.0, "production": 0.0, "gold": 0.0, "science": 0.0, "culture": 0.0, "cohesion": 0.0, "pop": 0, "residents": 0.0}
	for c in active_cities():
		for k in ["food", "production", "gold", "science", "culture", "cohesion"]:
			n[k] += float(c.y.get(k, 0.0))
		n["pop"] += c.pop()
		n["residents"] += c.residents
	n["residents"] += state.rural
	n["rural_food"] = state.rural / 1000.0 * 0.6
	n["food"] += n["rural_food"]
	n["rural_gold"] = state.rural / 1000.0 * 0.08
	n["gold"] += n["rural_gold"]
	for yk in ["science", "culture", "gold", "production"]:
		var pct := econ.mod_sum("yield_pct", "pct", "yield", yk)
		if yk == "gold" and state.inflation > 10.0:
			pct -= minf(25.0, 8.0 * log(1.0 + state.inflation / 100.0))
		n[yk + "_pct"] = pct
		n[yk] *= 1.0 + pct / 100.0
	var consumption: float = 2.0 * n["pop"]
	n["food_need"] = consumption
	econ.food_ratio = n["food"] / maxf(1.0, consumption)
	n["food_ratio"] = econ.food_ratio
	n["cohesion"] += econ.mod_sum("cohesion_per_turn")
	_national = n


func national() -> Dictionary:
	return _national


func total_residents() -> float:
	var t := state.rural
	for c in active_cities():
		t += c.residents
	return t


func progress_fraction() -> float:
	var tf := float(state.techs.size()) / maxf(1.0, db.tech_list.size())
	var cf := float(state.civics.size()) / maxf(1.0, db.civic_list.size())
	return clampf(maxf(tf, cf), 0.0, 1.0)


# ================================================================== turn engine

const GAME_END_TURN := 302    # Q3 2023: the game ends on 7 October 2023 (the user's decision, 2026-10-13)


static func last_playable_turn() -> int:
	## The last playable turn. Project setting `civ/last_turn` (default 302 = Q3 2023; after it the memorial screen,
	## data/ending_oct7.json, then the results). The demo build also sets `civ/demo_last_turn` (e.g. 78 = Q3 1967) and
	## ends there. SimDB.LAST_TURN (302) is the last turn the data covers (nothing after Q3 2023 is in it).
	var full := clampi(int(ProjectSettings.get_setting("civ/last_turn", GAME_END_TURN)), 1, SimDB.LAST_TURN)
	var d := int(ProjectSettings.get_setting("civ/demo_last_turn", 0))
	return d if d > 0 and d < full else full


static func full_last_turn() -> int:
	## The full game's last turn (civ/last_turn, default 302), ignoring the demo limit.
	return clampi(int(ProjectSettings.get_setting("civ/last_turn", GAME_END_TURN)), 1, SimDB.LAST_TURN)


func get_last_turn() -> int:
	## The last turn of THIS game (V3Adapter.last_turn): the last playable turn, or the quarter a collapse of the state
	## ended it early (v3 fix3-econ: the Ending outlook then reads 0 quarters to go).
	if collapse != null and collapse.ended():
		return mini(state.turn, last_playable_turn())
	return last_playable_turn()


static func is_demo() -> bool:
	return last_playable_turn() < full_last_turn()


func end_turn(force := false) -> bool:
	if state.game_over:
		return false
	var casual := not auto.is_full()
	if casual:
		auto.before_end_turn(force)   # V4: the ministers' late routine and last answers (story mode only)
	if not force:
		var b := blocking_decisions()
		if casual:
			b = b.filter(func(d): return not auto.auto_owned(d))   # a minister's stuck routine item never blocks the player
		if b.size() > 0:
			notify("blocked", "Cannot end turn: " + str(b[0].get("label", b[0]["type"])))
			return false
	_in_process = true
	_process_turn()
	_in_process = false
	turn_ended.emit(state.turn)
	if goals != null: goals.process_turn()   # V4 (v4-goals): the quarter's era goals are judged
	collapse.process_turn()   # v3 item 13: a collapse of the state ends the game early (no memorial)
	if collapse.ended():
		state.game_over = true
		game_over.emit(score.final_summary())
		return true
	state.turn += 1
	var last := Sim.last_playable_turn()
	if state.turn > last:
		state.game_over = true
		state.turn = last
		var summary := score.final_summary()
		game_over.emit(summary)
		return true
	_start_turn()
	return true


func _process_turn() -> void:
	# forced end of turn: everything still open takes the historical / holding option (resolving one decision can
	# release held events that open another, so loop until the quarter is clear)
	diplo.end_turn()   # v3: an open envoy takes the historical answer
	for _i in range(6):
		events.auto_resolve_pending()
		forks.auto_resolve()
		military.auto_resolve()
		cabinet.auto_resolve()
		if events.events_held() and state.pending_forks.is_empty() and not military.decision_open():
			resume_turn_events()
		if state.pending_events.is_empty() and state.pending_forks.is_empty() and not military.decision_open() and not events.events_held():
			break
	if state.pending_dedication:
		choose_dedication("innovation")
	if econ.immigration_decision_due():
		econ.choose_immigration(econ.historical_immigration_choice())
	events.apply_territory_rails(false, true)   # anything still held this quarter lands now
	refresh()
	var nat := _national
	# --- cities: production, borders, trust, growth
	var mult_sum := 0.0; var res_sum := 0.0
	var trust_parts := {}
	var trust_w := 0.0
	for c in active_cities():
		_produce(c)
		var b := econ.grow_border(c, float(c.y.get("culture", 0.0)) * 0.5)
		if b >= 0:
			territory_changed.emit()
		econ.update_trust(c)
		var tp: Dictionary = c.info.get("trust_parts", {})
		for k in tp:
			trust_parts[k] = float(trust_parts.get(k, 0.0)) + float(tp[k]) * c.residents
		trust_w += c.residents
		var before: int = c.pop()
		econ.grow_city(c)
		mult_sum += float(c.info.get("growth_mult", 1.0)) * c.residents
		res_sum += c.residents
		if c.damaged > 0:
			c.damaged += 1
			if c.damaged > 4: c.damaged = 0
		c.hp = minf(200.0, c.hp + 20.0)
		if c.pop() > before:
			_check_pop_moment(c)
			city_changed.emit(c.id)
	econ.grow_rural(mult_sum / maxf(1.0, res_sum))
	for k in trust_parts:
		_drift("trust", k, float(trust_parts[k]) / maxf(1.0, trust_w))
	# --- immigration (fixed national totals, S276; placement by conditions and policy)
	var rep := econ.immigration_quarter(events.directed_immigration())
	state.counters["last_immigration"] = rep
	# --- internal migration towards the census paths (cities.json)
	state.counters["last_census_pull"] = econ.census_pull()
	# --- national budget
	var income: float = nat["gold"]
	var upkeep := _maintenance()
	var imports := maxf(0.0, nat["food_need"] - nat["food"]) * 0.5
	var food_exports: float = econ.food_exports(nat)   # v3: a national food surplus is exported (SimEconomy.FOOD_EXPORT)
	var mods_gold := 0.0
	for gm in state.gold_mods:
		if int(gm.get("until", 0)) >= state.turn:
			mods_gold += float(gm.get("amount", 0))
	mods_gold += econ.mod_sum("gold_per_turn")
	var per_pop: float = econ.mod_sum("gold_per_pop") * nat["pop"]
	var streams_gold := stream_sum("gold")
	var absorb := float(rep.get("absorption_cost", 0.0)) + float(rep.get("absorption_upkeep", 0.0))
	var debt_pay: float = econ.service_debt()   # public debt: interest and ten-year repayment (fix-cabinet)
	var net: float = income - upkeep - imports + food_exports + mods_gold + per_pop + streams_gold - absorb - debt_pay
	econ.note_deficit(net)
	state.gold += net
	econ.note_structural(income, mods_gold + per_pop + streams_gold, upkeep, debt_pay, {"imports": imports, "absorption": absorb, "food_exports": food_exports})   # v3 fix3-econ / fix4-econ: the structural-deficit alarm over every outflow
	state.counters["neg_turns"] = int(state.counters.get("neg_turns", 0)) + 1 if state.gold < 0.0 else 0
	state.counters["last_budget"] = {"income": income, "upkeep": upkeep, "imports": imports, "events": mods_gold, "policies": per_pop,
		"choices": streams_gold, "absorption": absorb, "debt": debt_pay, "food_exports": food_exports, "net": net}
	# inflation: the historical CPI arc is the backdrop; the player's fiscal record moves a gap on top of it
	_update_inflation(income, net)
	state.counters["income_avg"] = lerpf(float(state.counters.get("income_avg", maxf(45.0, income))), maxf(1.0, income), 0.15)
	endgame.process_turn()   # v3: national programme instalments and completions; the fiscal indicator's history
	# --- research and civics
	_research(nat["science"])
	_civic_progress(nat["culture"])
	# --- cohesion, standing, readiness, weariness
	state.cohesion += nat["cohesion"]
	_drift("cohesion", "community institutions, kibbutzim and lasting terms", float(nat["cohesion"]))
	var sp := econ.mod_sum("standing_per_turn") + 0.02 * state.trade_routes.size()
	for c in active_cities():
		for b in c.buildings:
			sp += float(db.buildings.get(b, {}).get("standing_per_turn", 0))
		for d in c.districts:
			sp += float(db.districts.get(d, {}).get("standing_per_turn", 0))
	var cult_pp: float = nat["culture"] / maxf(1.0, nat["pop"])
	sp += clampf((cult_pp - 0.55) * 0.2, -0.05, 0.05)
	var mil := -0.0005 * econ.military_tiles_owned()   # holding territory under military control weighs on standing
	var cult := clampf((cult_pp - 0.55) * 0.2, -0.05, 0.05)
	var parts := {"policies, buildings and export routes": (sp - cult) * 0.15, "cultural reach": cult,
		"territory held under military control": mil}
	parts["drift toward %d (the world's default view, shifted by your choices)" % int(round(standing_anchor()))] = (standing_anchor() - state.standing) * 0.02
	for s in state.streams:
		if str(s["type"]) == "standing" and _stream_active(s):
			parts[str(s["label"])] = float(parts.get(str(s["label"]), 0.0)) + float(s["amount"])
	if state.standing > 75.0:
		parts["fatigue at the top (allies take a high standing for granted)"] = -0.06 * (state.standing - 75.0) / 5.0
	var total := 0.0
	for k in parts:
		var v := float(parts[k])
		if v > 0.0:
			v *= standing_headroom()
		total += v
		_drift("standing", k, v)
	state.standing = clampf(state.standing + total, 0.0, 100.0)
	state.counters["standing_per_turn"] = total
	# what the player's past choices did to standing fades slowly (half-life ~20 years), so recent choices weigh most
	state.counters["standing_player"] = float(state.counters.get("standing_player", 0.0)) * 0.996
	# the same slow memory for Civic Trust: what the player's own choices did shifts where trust settles
	state.counters["trust_player"] = float(state.counters.get("trust_player", 0.0)) * 0.996
	state.counters["standing_parts"] = parts
	state.readiness_bonus *= 0.98
	state.war_weariness = maxf(0.0, state.war_weariness - (50.0 if state.crises.size() > 0 else 200.0))
	# --- water
	econ.update_water()
	# --- units and crises
	military.process_turn()
	# --- trade routes
	for tr in state.trade_routes.duplicate():
		tr["turns"] = int(tr["turns"]) - 1
		if int(tr["turns"]) <= 0:
			state.trade_routes.erase(tr)
			notify("trade_route", "An export route from %s has expired." % _city_name(int(tr["from"])))
	state.free_swap = false
	_report_quarter()
	if SimDB.quarter_of(state.turn) == 4:
		_report_drift()
	state.notifications = state.notifications.filter(func(n): return int(n.get("turn", 0)) >= state.turn - 1)


# ------------------------------------------------------------------ lasting changes: reasons, streams, yearly drift

const STAT_NAMES := {"standing": "Standing", "trust": "Civic Trust", "readiness": "Readiness", "inflation": "Inflation", "cohesion": "Cohesion",
	"economy": "Economy", "science": "Science", "population": "Population", "water": "Water", "gold": "Gold"}


func stat_note(stat: String, amount: float, reason: String, notify_min := 0.5) -> void:
	## Every lasting-stat change is logged with its reason (history log); larger ones are notified.
	if absf(amount) < 0.01:
		return
	state.stat_log.append({"turn": state.turn, "stat": stat, "amount": snappedf(amount, 0.01), "reason": reason})
	if state.stat_log.size() > 2600:
		state.stat_log = state.stat_log.slice(state.stat_log.size() - 2200)
	if absf(amount) >= notify_min:
		notify("stat", "%s %+.1f: %s" % [STAT_NAMES.get(stat, stat), amount, reason], {"stat": stat, "amount": amount})


func standing_headroom() -> float:
	## Diminishing returns: gains shrink as standing approaches 100 (full effect up to 65, a fifth at 95).
	return clampf((100.0 - state.standing) / 35.0, 0.15, 1.0)


func _change_standing(amount: float, reason: String, player := false) -> float:
	## player = true for changes the player chose (event choices, forks, cabinet); those do not mean-revert.
	if amount > 0.0:
		amount *= standing_headroom()
	var before := state.standing
	state.standing = clampf(state.standing + amount, 0.0, 100.0)
	stat_note("standing", state.standing - before, reason)
	if player:
		state.counters["standing_player"] = float(state.counters.get("standing_player", 0.0)) + state.standing - before
	return state.standing - before


func add_trust_player(amount: float) -> void:
	## Player-chosen trust changes (forks, event choices) move the settling point of every city's trust,
	## instead of being pulled back to the baseline within a few years. Fades with a ~43-year half-life.
	state.counters["trust_player"] = clampf(float(state.counters.get("trust_player", 0.0)) + amount, -20.0, 20.0)


func standing_anchor() -> float:
	## Where standing settles: the world's default view (50) shifted by the player's own choices and lasting terms.
	return clampf(50.0 + float(state.counters.get("standing_player", 0.0)) + stream_sum("standing_target"), 10.0, 90.0)


func _drift(stat: String, label: String, amount: float) -> void:
	var d: Dictionary = state.counters.get("drift", {})
	var sd: Dictionary = d.get(stat, {})
	sd[label] = float(sd.get(label, 0.0)) + amount
	d[stat] = sd
	state.counters["drift"] = d
	var dq: Dictionary = state.counters.get("drift_q", {})
	var sq: Dictionary = dq.get(stat, {})
	sq[label] = float(sq.get(label, 0.0)) + amount
	dq[stat] = sq
	state.counters["drift_q"] = dq


const ITEMISED_STATS := ["trust", "readiness", "inflation"]


func _report_quarter() -> void:
	## Itemised quarterly entries for Civic Trust, Readiness and Inflation (UI request 16): one stat-log entry per
	## stat per quarter, {turn, stat, amount, reason, parts: {cause: amount}, quarterly: true}.
	var dq: Dictionary = state.counters.get("drift_q", {})
	for stat in ITEMISED_STATS:
		var sq: Dictionary = dq.get(stat, {})
		var tot := 0.0
		var parts := {}
		for k in sq:
			var v := float(sq[k])
			if absf(v) >= 0.01:
				parts[k] = snappedf(v, 0.01)
				tot += v
		if parts.is_empty() or absf(tot) < 0.01 and parts.size() < 2:
			continue
		var keys := parts.keys()
		keys.sort_custom(func(x, y): return absf(float(parts[x])) > absf(float(parts[y])))
		var why := ", ".join(keys.slice(0, 4).map(func(k): return "%s %+.2f" % [k, float(parts[k])]))
		state.stat_log.append({"turn": state.turn, "stat": stat, "amount": snappedf(tot, 0.01), "reason": "this quarter: " + why, "parts": parts, "quarterly": true})
	state.counters["drift_q"] = {}
	if state.stat_log.size() > 2600:
		state.stat_log = state.stat_log.slice(state.stat_log.size() - 2200)


func _report_drift() -> void:
	## Once a year: what moved the slow national stats, with the reasons (no silent erosion).
	var d: Dictionary = state.counters.get("drift", {})
	for stat in d:
		var sd: Dictionary = d[stat]
		var tot := 0.0
		for k in sd: tot += float(sd[k])
		var keys := sd.keys().filter(func(k): return absf(float(sd[k])) >= 0.1)
		keys.sort_custom(func(a, b): return absf(float(sd[a])) > absf(float(sd[b])))
		var why := ", ".join(keys.slice(0, 4).map(func(k): return "%s %+.1f" % [k, float(sd[k])]))
		if absf(tot) >= 0.05:
			state.stat_log.append({"turn": state.turn, "stat": stat, "amount": snappedf(tot, 0.01), "reason": "over the past year: " + why})
		if absf(tot) >= 1.0:
			notify("stat", "%s %+.1f over the past year: %s." % [STAT_NAMES.get(stat, stat), tot, why], {"stat": stat, "amount": tot})
	state.counters["drift"] = {}


func _stream_active(s: Dictionary) -> bool:
	if s.has("ends_with_policy") and int(s.get("from", 0)) <= state.turn:
		for p in state.policies:
			if str(p.get("id", "")) == str(s["ends_with_policy"]):
				s["until"] = mini(int(s["until"]), state.turn - 1)
				break
	return int(s.get("from", 0)) <= state.turn and state.turn <= int(s.get("until", 0))


func _stream_notices() -> void:
	for s in state.streams:
		if int(s.get("from", -1)) == state.turn and s.has("start_text"):
			notify("stream", str(s["start_text"]), {"label": s.get("label", "")})
		if s.has("ends_with_policy") and int(s.get("until", 0)) == state.turn - 1 and not s.get("end_notified", false) and state.turn > int(s.get("from", 0)):
			s["end_notified"] = true
			notify("stream", "%s ends: the budget recovers %d gold a turn." % [s.get("label", ""), int(absf(float(s.get("amount", 0))))], {"label": s.get("label", "")})


func stream_sum(type: String) -> float:
	## Sum of the active multi-year terms of one type ("gold" per turn, "readiness" level, "trust" per turn).
	var t := 0.0
	for s in state.streams:
		if str(s.get("type")) == type and _stream_active(s):
			t += float(s.get("amount", 0))
	return t


func get_streams() -> Array:
	## Active and future terms set by choices: [{type, amount, from, until, label, src, active}].
	var out := []
	for s in state.streams:
		if int(s.get("until", 0)) >= state.turn:
			var o: Dictionary = s.duplicate()
			o["active"] = _stream_active(s)
			o["until"] = mini(int(s.get("until", 0)), Sim.full_last_turn())   # v3 fix3-econ (A9): no span shown past Q3 2023
			o["to_end"] = int(s.get("until", 0)) >= Sim.full_last_turn()
			out.append(o)
	return out


func get_stat_log(stat := "") -> Array:
	## Lasting-stat changes with reasons: [{turn, stat, amount, reason}] (standing, readiness, inflation...).
	## v2: every quarter also has one itemised entry each for trust, readiness and inflation:
	##   {turn, stat, amount, reason: "this quarter: cause +x, ...", parts: {cause: amount}, quarterly: true}.
	return state.stat_log.filter(func(e): return stat == "" or e["stat"] == stat)


# ------------------------------------------------------------------ inflation
# The historical CPI arc (real_series "inflation", World Bank / CBS) is the backdrop every government faced:
# oil shocks, war spending and economy-wide indexation in the 1970s-80s, the July 1985 Stabilization Plan,
# then low inflation. The player's own record moves a lasting gap (in log points) on top of it: deficits and
# debt push it up, surpluses pull it down, and the stabilising policy history adopted matters (dropping the
# 1985 plan keeps inflation high). Agenda choices (indexation, price freezes) also move the gap.

const INFLATION_PRE_DATA := 6.0   # % a year before the series starts (1948-59); calibration constant, not data


func inflation_baseline(yf: float) -> float:
	if yf < 1960.0 or db.real.get("inflation") == null:
		return INFLATION_PRE_DATA
	return db.real_value("inflation", minf(yf, float(SimDB.end_year()) + 0.5))


func _hist_policy_inflation(yf: float) -> float:
	## Sum of the "inflation" policy effects historical governments had in force (stabilization plan from 1985).
	return -12.0 if yf >= 1985.5 else 0.0


func inflation_gap_limit(yf: float) -> float:
	## How far (in log points) the player's record can move inflation off the historical path: wide in the
	## indexation era, narrow once an independent central bank targets inflation (from 1986, tighter from 1992).
	if yf < 1986.0: return 0.9
	# v3 item 13: with the debt and overdraft past the lenders' limit the deficit is financed by printing money,
	# and no inflation target holds (the road to the fiscal collapse)
	if state != null and state.mode != "historical" and collapse != null and collapse.metric("debt_over_cap") >= 1.0: return 0.9
	if yf < 1992.0: return 0.15
	return 0.05


func inflation_terms() -> float:
	## v3 fix3-econ (A8): the lasting inflation terms of the player's choices, measured against history's own (the CPI
	## path already contains them): the ghost of history follows the CPI, and history's choices add nothing on top.
	if state.mode == "historical":
		return 0.0
	var own := stream_sum("inflation")
	if score == null: return own
	var g: Dictionary = score.ghost_at(state.turn + 1)   # the ghost's row for the next turn holds this quarter's choices
	return own - float(g.get("infs", 0.0))


func inflation_gap() -> float:
	return float(state.counters.get("inflation_gap", 0.0))


func shift_inflation(points: float) -> void:
	## An immediate change of `points` percentage points to the current rate, carried by the gap.
	var cur := state.inflation
	var target := maxf(-2.0, cur + points)
	var lim := inflation_gap_limit(SimDB.year_f(state.turn))
	# v3 fix3-econ (A8): the running sum of these shifts (history's own are in the CPI path; ghost.json rows carry "infsh")
	state.counters["infl_shift_sum"] = float(state.counters.get("infl_shift_sum", 0.0)) + log((1.0 + target / 100.0) / maxf(0.01, 1.0 + cur / 100.0))
	state.counters["inflation_gap"] = clampf(inflation_gap() + log((1.0 + target / 100.0) / maxf(0.01, 1.0 + cur / 100.0)), -lim, lim)
	target = (exp(log(1.0 + (inflation_baseline(SimDB.year_f(state.turn)) + inflation_terms()) / 100.0) + float(state.counters["inflation_gap"])) - 1.0) * 100.0
	state.inflation = target


static func fiscal_push(net: float, income: float, gold: float) -> float:
	## How a quarter's budget record pushes inflation off its path: deficits and a negative treasury up, surpluses down.
	var push := 0.0
	var inc := maxf(10.0, income)
	if net < 0.0:
		push += 0.3 * minf(2.0, -net / inc)
	else:
		push -= 0.08 * minf(1.0, net / inc)
	if gold < 0.0:
		push += 0.15 * minf(1.5, -gold / maxf(50.0, inc * 4.0))
	return push


func _update_inflation(income: float, net: float) -> void:
	var yf := SimDB.year_f(state.turn)
	var push := fiscal_push(net, income, state.gold)
	if state.gold < 0.0:
		# inflation erodes debt fixed in money terms (the "inflation tax" that financed 1970s-80s deficits)
		state.gold *= 1.0 - minf(0.5, log(1.0 + maxf(0.0, state.inflation) / 100.0)) / 4.0
	# v3 fix3-econ (A8): history's own deficits are already in the CPI path, so only the difference from the ghost's budget
	# record that quarter moves the gap (a player who runs history's budget tracks history's inflation)
	var hist_shift := 0.0
	var hist_mods := _hist_policy_inflation(yf)
	if state.mode != "historical" and score != null:
		var g: Dictionary = score.ghost_at(state.turn + 1)   # the ghost's row for the next turn holds this quarter's budget
		if g.has("net"):
			push -= fiscal_push(float(g["net"]), float(g.get("inc", income)), float(g.get("gold", 0.0)))
		# v3 fix3-econ (A8): history's own price policies and emergency measures are in the CPI path too; only the
		# player's difference from them moves the gap
		if g.has("infm"): hist_mods = float(g["infm"])
		var g0: Dictionary = score.ghost_at(state.turn)
		if g.has("infsh") and g0.has("infsh") and state.turn + 1 <= score.ghost_turns():
			hist_shift = float(g["infsh"]) - float(g0["infsh"])
	push += 0.006 * (econ.mod_sum("inflation") - hist_mods)
	var anchored: bool = econ.stabilised()   # v3 fix3-econ: a stabilisation package anchors prices (wage agreement, fixed rate)
	if anchored and push > 0.0:
		push *= 0.35
	var gap := inflation_gap()
	var lim := inflation_gap_limit(yf)
	gap = clampf(gap - hist_shift + push * 0.25 * endgame.inflation_drift() - gap * (0.15 if anchored else 0.08), -lim, lim)   # v3: difficulty's inflation drift
	if state.mode == "historical":
		gap = 0.0   # the ghost of history has history's inflation
	var base := inflation_baseline(yf) + inflation_terms()
	# v3 fix3-econ (A8): surpluses lower inflation below history's but do not turn a low-inflation year into deflation
	var floor_i := minf(base, 0.4 * base - 0.5)
	if (exp(log(1.0 + base / 100.0) + gap) - 1.0) * 100.0 < floor_i:
		gap = log((1.0 + floor_i / 100.0) / maxf(0.01, 1.0 + base / 100.0))
	state.counters["inflation_gap"] = gap
	var before_infl := state.inflation
	state.inflation = clampf((exp(log(1.0 + base / 100.0) + gap) - 1.0) * 100.0, -5.0, 2000.0)
	var d_hist := inflation_baseline(yf) - inflation_baseline(yf - 0.25)
	_drift("inflation", "the historical backdrop (world prices, wars, indexation)", d_hist)
	_drift("inflation", "lasting terms of your choices", inflation_terms() - float(state.counters.get("last_infl_terms", 0.0)))
	state.counters["last_infl_terms"] = inflation_terms()
	_drift("inflation", "your budget record (deficits and debt push it up, surpluses pull it down)", state.inflation - before_infl - d_hist)
	state.counters["inflation_parts"] = {"history": base, "gap": gap, "push": push}


func _start_turn() -> void:
	var t := state.turn
	_in_process = true   # V4: the ministers act once the quarter's decisions are all known (settle_start below)
	_stream_notices()
	cabinet.accrue()
	events.apply_rails(false)
	events.apply_government(false)
	forks.offer_due()
	military.update_crises()   # wars already under way ask for this quarter's front orders before its events fire
	events.fire_turn_events()
	forks.offer_due()
	events.apply_status_rails()
	military.update_crises()
	events.apply_territory_rails(false)   # outcome rails only once this quarter's decisions are made
	_check_era()
	refresh()
	_rebuild_stats()
	_check_boosts()
	_auto_select()
	endgame.start_turn()   # v3: history's programmes on their dates; the player's programme decision
	diplo.start_turn()     # v3: relation causes from this quarter's history, patrons' leverage, the envoy decision
	if goals != null: goals.start_turn()   # V4 (v4-goals hook; judged in end_turn via goals.process_turn)
	score.sample()
	# a "busy" quarter already has a story decision; then a single cabinet title may wait (non-blocking)
	var pend := get_pending_decisions()
	state.counters["busy_turn"] = t if pend.any(func(d): return str(d["type"]) in STORY_TYPES and str(d["type"]) != "minister") else -1
	events.generate_agenda()
	_in_process = false
	if not auto.is_full():
		auto.settle_start()   # V4: the ministers answer the quarter's routine (story mode only)
	state.last_decisions = get_pending_decisions()
	state.counters["decisions_" + str(t)] = state.last_decisions.size()
	turn_started.emit(t, date_label())


func resume_turn_events() -> void:
	## A pending fork held this quarter's later events; it has been decided, so history continues.
	events.fire_turn_events()
	forks.offer_due()
	events.apply_status_rails()
	military.update_crises()
	events.apply_territory_rails(false)
	diplo.sync()
	refresh()
	_after_decision()   # V4: released events may open routine decisions (settle is re-entry safe)


func _after_decision() -> void:
	## V4 (v4-sim-auto): after every public decision method, the ministers answer whatever it opened (story mode only;
	## a no-op in Full control and while the ministers themselves are deciding).
	if auto != null and not _in_process and not auto.is_full():
		auto.settle()


func _auto_select() -> void:
	## Cities on automation pick their own production (also keeps empty queues sensible).
	for c in active_cities():
		if c.automate and c.queue.is_empty():
			var pick: Dictionary = SimAI.pick_production(self, c)
			if not pick.is_empty():
				set_production(c.id, pick["kind"], pick["id"], pick.get("tile", -1))


func _city_name(id: int) -> String:
	var c = city_by_id(id)
	return "?" if c == null else c.name


func _seed_start_milestones() -> void:
	## What the country already had in May 1948 counts as reached at turn 1 (no moments, no ghost gaps).
	for c in state.cities:
		for th in [10, 15, 20, 25, 30]:
			if c.pop() >= th: state.milestones["pop%d" % th] = 1
		for d in c.districts:
			state.milestones["district:" + str(d)] = 1
		for b in c.buildings:
			state.milestones["building:" + str(b)] = 1


func city_name_at(key: String, default_name: String) -> String:
	## Dated names (governments.json city_names), e.g. Tel Aviv until it became Tel Aviv-Yafo in August 1950.
	for n in db.gov.get("city_names", []):
		if str(n.get("city")) == key and state.turn < SimDB.turn_of(n.get("until"), 0):
			return str(n.get("name", default_name))
	return default_name


func _check_pop_moment(c: SimCity) -> void:
	for th in [10, 15, 20, 25, 30]:
		if c.pop() >= th and not state.milestones.has("pop%d" % th):
			state.milestones["pop%d" % th] = state.turn
			add_moment("%s is the first city to reach population %d" % [c.name, th], 2, "growth")


func add_moment(text: String, era_score: int, kind := "moment") -> void:
	var m := {"turn": state.turn, "date": date_label(), "text": text, "score": era_score, "kind": kind}
	state.timeline.append(m)
	state.era_score += era_score
	historic_moment.emit(m)


func _check_era() -> void:
	var e := db.era_at(state.turn)
	var idx := int(e.get("index", 1))
	if idx <= state.era:
		return
	var ncity := active_cities().size()
	var golden_n := state.ages.filter(func(a): return a.get("age") == "golden").size()
	var dark_th := 8 + ncity / 12
	var gold_th := 18 + ncity / 12 + 4 * golden_n
	var prev_age := state.age
	var new_age := "normal"
	if state.era_score >= gold_th:
		new_age = "golden"
	elif state.era_score < dark_th:
		new_age = "dark"
	if prev_age == "dark" and state.era_score >= gold_th:
		new_age = "golden"   # heroic age
	state.ages.append({"era": state.era, "score": state.era_score, "age": new_age, "dark_th": dark_th, "golden_th": gold_th})
	state.era = idx
	state.age = new_age
	state.era_score = 0
	state.dedication = ""
	state.pending_dedication = true
	state.free_swap = true
	events.recompute_slots()
	add_moment("A new era begins: %s (%s age)" % [e.get("name", "Era %d" % idx), new_age], 0, "era")
	era_changed.emit(idx, new_age)


# ================================================================== production

func item_cost(c: SimCity, kind: String, id: String) -> float:
	var cost := 0.0
	var target_tags := []
	match kind:
		"building":
			var b = db.buildings.get(id, {})
			cost = float(b.get("cost", 100))
			target_tags = [b.get("district", "")]
			if id in ["shikun_blocks", "maabara"]: target_tags.append("housing")
		"district":
			if c.district_cost.has(id):
				cost = float(c.district_cost[id])
			else:
				var d = db.districts.get(id, {})
				cost = float(d.get("base_cost", 35))
				if not d.get("fixed_cost", false):
					cost *= 3.0 + 7.0 * progress_fraction()
			target_tags = [id]
			if id == "housing_project": target_tags.append("housing")
		"unit":
			var u = db.units.get(id, {})
			cost = float(u.get("cost", 100)) + float(u.get("cost_step", 0)) * int(state.unit_builds.get(id, 0))
			target_tags = [id]
			if u.get("cls", "") in MILITARY_CLASSES: target_tags.append("military")
		"project":
			cost = float(db.projects.get(id, {}).get("cost", 500))
			var py = db.projects.get(id, {}).get("year")
			if py != null and year() < int(py):
				cost *= 1.0 + 0.05 * (int(py) - year())   # earlier than history costs more
		"city_project":
			var cp = db.city_projects.get(id, {})
			cost = float(cp.get("cost", 60)) * ((1.0 + 2.0 * progress_fraction()) if cp.get("scale", false) else 1.0)
	var pct := 0.0
	for e in econ.mods:
		if e.get("type") == "prod_pct" and str(e.get("target", "")) in target_tags:
			pct += float(e.get("pct", 0))
		if e.get("type") == "prod_pct_city_target" and int(e.get("city", 0)) == c.id and str(e.get("target", "")) in target_tags:
			pct += float(e.get("pct", 0))
	return maxf(10.0, round(cost / (1.0 + pct / 100.0)))


func _produce(c: SimCity) -> void:
	var prod := float(c.y.get("production", 0.0))
	if c.queue.is_empty():
		c.progress["_stock"] = minf(float(c.progress.get("_stock", 0.0)) + prod, prod * 2.0 + 10.0)
		return
	var item: Dictionary = c.queue[0]
	if item["kind"] == "project":
		prod += 0.12 * float(_national.get("production", 0.0))   # national projects draw on the state budget
	var pk := str(item["kind"]) + ":" + str(item["id"])
	var stock := float(c.progress.get("_stock", 0.0))
	c.progress.erase("_stock")
	c.progress[pk] = float(c.progress.get(pk, 0.0)) + prod + stock
	var cost := item_cost(c, item["kind"], item["id"])
	if float(c.progress[pk]) >= cost:
		var over: float = c.progress[pk] - cost
		c.progress.erase(pk)
		c.queue.pop_front()
		_complete(c, item)
		if over > 0:
			c.progress["_stock"] = over


func _complete(c: SimCity, item: Dictionary) -> void:
	var kind := str(item["kind"]); var id := str(item["id"])
	match kind:
		"building":
			if not c.has_building(id):
				c.buildings.append(id)
				var b = db.buildings.get(id, {})
				c.outer_hp += float(b.get("outer_hp", 0))
				if not state.milestones.has("building:" + id):
					state.milestones["building:" + id] = state.turn
		"district":
			var k := int(item.get("tile", -1))
			if k < 0 or econ.district_ok(c, id, k) != "":
				var sites: Array = econ.district_sites(c, id)
				if sites.is_empty():
					c.progress["_stock"] = float(c.progress.get("_stock", 0.0)) + item_cost(c, kind, id) * 0.5
					notify("district_blocked", "%s: the %s could not be placed (no valid tile); half its production is kept." % [c.name, db.districts.get(id, {}).get("name", id)], {"city": c.id})
					return
				k = SimHex.key(int(sites[0]["q"]), int(sites[0]["r"]))
			_place_district(c, id, k)
			if not state.milestones.has("district:" + id):
				state.milestones["district:" + id] = state.turn
				add_moment("First %s built in %s" % [db.districts.get(id, {}).get("name", id), c.name], 2, "district")
			if econ.adjacency(c, id, k) >= 3.0 and db.districts.get(id, {}).get("specialty", false):
				add_moment("Splendid %s in %s (adjacency +%d)" % [db.districts[id]["name"], c.name, int(econ.adjacency(c, id, k))], 1, "district")
		"unit":
			var u := military.spawn_unit(id, "player", c.pos(), c.id)
			state.unit_builds[id] = int(state.unit_builds.get(id, 0)) + 1
			var ud = db.units.get(id, {})
			if int(ud.get("residents", 0)) > 0:
				c.residents = maxf(1000.0, c.residents - float(ud["residents"]))
			if u == null:
				log_error("could not place unit %s at %s" % [id, c.name])
		"project":
			state.projects[id] = {"city": c.id, "turn": state.turn}
			var p = db.projects.get(id, {})
			_change_standing(float(p.get("standing", 0)), "%s completed" % p.get("name", id))
			state.milestones["project:" + id] = state.turn
			var hy = p.get("year")
			var diff := (SimDB.turn_of(str(hy), state.turn) - state.turn) if hy != null else 0
			add_moment("%s completed in %s%s" % [p.get("name", id), c.name, (" (%d turns ahead of history)" % diff) if diff > 0 else ""], int(p.get("era_score", 4)), "project")
			econ.claim_extra(c, 2)
		"city_project":
			var cp = db.city_projects.get(id, {})
			var rw: Dictionary = cp.get("reward", {})
			state.gold += float(rw.get("gold", 0))
			state.cohesion += float(rw.get("cohesion", 0))
			state.readiness_bonus += float(rw.get("readiness", 0))
			if rw.has("science"): _research(float(rw["science"]))
			if rw.has("culture"): _civic_progress(float(rw["culture"]))
			if rw.has("trust"): c.trust = minf(100.0, c.trust + float(rw["trust"]))
			if rw.has("rehouse"):
				pass   # conversion happens through housing; absorption drive grants temporary housing
			if cp.get("repeatable", false) and c.queue.is_empty():
				c.queue.append({"kind": "city_project", "id": id, "tile": -1})
	c.last_built = {"kind": kind, "id": id, "turn": state.turn}
	production_completed.emit(c.id, kind, id)
	city_changed.emit(c.id)
	refresh_city(c)


func _place_district(c: SimCity, did: String, k: int) -> void:
	var ts := econ.tstate(k)
	ts["d"] = did
	ts["imp"] = ""
	if econ.feature(k) in ["forest", "orchard"]:
		ts["f"] = "none"
	c.districts[did] = k


func buildable(c: SimCity, only_kind := "", only_id := "") -> Array:
	## Everything the city could produce now, with cost, turns and lock reasons (production panel).
	## only_kind/only_id restrict the scan to one item (used for validation).
	var out := []
	var prod := maxf(1.0, float(c.y.get("production", 1.0)))
	for did in db.districts:
		if did == "city_center": continue
		if only_id != "" and (only_kind != "district" or only_id != did): continue
		var d: Dictionary = db.districts[did]
		var why := _unlock_reason(d.get("unlock", {}))
		if why == "" and c.has_district(did): continue
		if why == "" and _queued(c, "district", did): continue
		var sites := econ.district_sites(c, did) if why == "" else []
		if why == "" and sites.is_empty():
			why = "no valid tile"
			if d.get("specialty", false) and econ.specialty_count(c) >= econ.district_cap(c):
				why = "district limit (population %d)" % c.pop()
		_add_option(out, c, "district", did, d.get("name", did), why, prod, {"sites": sites})
	for bid in db.buildings:
		if only_id != "" and (only_kind != "building" or only_id != bid): continue
		var b: Dictionary = db.buildings[bid]
		if c.has_building(bid) or _queued(c, "building", bid) or econ.is_mothballed(c, bid): continue   # v3 fix3-econ: a mothballed building is reopened, not rebuilt
		if bid == "maabara" and SimDB.year_f(state.turn) >= 1965.0: continue   # transit camps belong to the 1950s
		var why2 := _unlock_reason(b.get("unlock", {}))
		var dist := str(b.get("district", "city_center"))
		if why2 == "" and dist != "city_center" and not c.has_district(dist):
			why2 = "needs %s" % db.districts.get(dist, {}).get("name", dist)
		if why2 == "" and b.has("requires_building") and not c.has_building(str(b["requires_building"])):
			why2 = "needs %s" % db.buildings.get(b["requires_building"], {}).get("name", b["requires_building"])
		if why2 == "":
			for ex in b.get("exclusive_with", []):
				if c.has_building(ex): why2 = "exclusive with %s" % ex
			if b.has("requires_region") and not (econ.region(SimHex.key(c.q, c.r)) in b["requires_region"]):
				why2 = "needs a city in %s" % ", ".join(b["requires_region"])
			if int(b.get("tier", 1)) >= 2 and dist != "city_center" and not b.has("requires_building"):
				var lower := false
				for ob in c.buildings:
					if db.buildings.get(ob, {}).get("district") == dist: lower = true
				if not lower and int(b.get("tier", 1)) >= 2: why2 = "needs a tier-1 building in the district"
		_add_option(out, c, "building", bid, b.get("name", bid), why2, prod, {})
	for uid in db.units:
		if only_id != "" and (only_kind != "unit" or only_id != uid): continue
		var u: Dictionary = db.units[uid]
		if u.get("hostile", false) or u.get("temporary", false): continue
		var why3 := _unlock_reason(u.get("unlock", {}))
		if why3 == "" and u.has("obsolete_by") and _unlocked(db.units.get(u["obsolete_by"], {}).get("unlock", {})):
			continue
		if why3 == "" and uid == "settler":
			if c.residents < 4000: why3 = "city needs 4,000 residents"
			elif settle_targets().is_empty(): why3 = "no locality open for founding"
		if why3 == "" and u.get("cls") == "naval" and not econ.is_coastal(SimHex.key(c.q, c.r)): why3 = "coastal city only"
		_add_option(out, c, "unit", uid, u.get("name", uid), why3, prod, {})
	for pid in db.projects:
		if only_id != "" and (only_kind != "project" or only_id != pid): continue
		if state.projects.has(pid) or _project_in_progress(pid, c): continue
		var p: Dictionary = db.projects[pid]
		var why4 := _unlock_reason(p.get("unlock", {}))
		if why4 == "": why4 = project_placement_reason(c, pid)
		if why4 == "" and p.get("year") != null and year() < int(p["year"]) - 8:
			why4 = "not before %d" % (int(p["year"]) - 8)
		# national projects also draw 12% of national production (see _produce)
		_add_option(out, c, "project", pid, p.get("name", pid), why4, prod + 0.12 * float(_national.get("production", 0.0)), {"national": true})
	for cpid in db.city_projects:
		if only_id != "" and (only_kind != "city_project" or only_id != cpid): continue
		var cp: Dictionary = db.city_projects[cpid]
		var why5 := ""
		if cp.has("requires_district") and not c.has_district(cp["requires_district"]): why5 = "needs district"
		if cp.has("requires_building") and not c.has_building(cp["requires_building"]): why5 = "needs building"
		_add_option(out, c, "city_project", cpid, cp.get("name", cpid), why5, prod, {})
	return out


func _add_option(out: Array, c: SimCity, kind: String, id: String, name: String, why: String, prod: float, extra: Dictionary) -> void:
	var cost := item_cost(c, kind, id)
	var done := float(c.progress.get(kind + ":" + id, 0.0))
	var o := {"kind": kind, "id": id, "name": name, "cost": cost, "progress": done,
		"turns": int(ceil(maxf(0.0, cost - done) / prod)), "available": why == "", "reason": why,
		"gold_cost": purchase_cost(c, kind, id, "gold"), "cohesion_cost": purchase_cost(c, kind, id, "cohesion")}
	o.merge(extra)
	out.append(o)


func _queued(c: SimCity, kind: String, id: String) -> bool:
	for q in c.queue:
		if q["kind"] == kind and q["id"] == id:
			return true
	return false


func _project_in_progress(pid: String, except_city) -> bool:
	for c in state.cities:
		if c != except_city and _queued(c, "project", pid):
			return true
	return false


func project_placement_reason(c: SimCity, pid: String) -> String:
	var p = db.projects.get(pid, {})
	var pl: Dictionary = p.get("placement", {})
	if pl.has("city") and not (c.key in pl["city"]):
		return "only in " + ", ".join(pl["city"])
	if pl.has("requires_district") and not c.has_district(pl["requires_district"]):
		return "needs " + str(db.districts.get(pl["requires_district"], {}).get("name", pl["requires_district"]))
	if pl.has("near_place"):
		var pp = db.places_by_name.get(pl["near_place"])
		if pp == null or SimHex.distance(c.pos(), Vector2i(int(pp["q"]), int(pp["r"]))) > int(pl.get("radius", 6)):
			return "must be within %d tiles of %s" % [int(pl.get("radius", 6)), pl["near_place"]]
	if pl.has("near_resource"):
		var ok := false
		for k in SimHex.within(c.q, c.r, int(pl.get("radius", 6))):
			if db.tiles.has(SimHex.key(k.x, k.y)) and str(db.tiles[SimHex.key(k.x, k.y)].get("resource", "")) in pl["near_resource"]:
				ok = true; break
		if not ok:
			return "must be near " + ", ".join(pl["near_resource"])
	return ""


func _unlocked(u: Dictionary) -> bool:
	return _unlock_reason(u) == ""


func _unlock_reason(u: Dictionary) -> String:
	if u.has("tech") and not state.techs.has(u["tech"]):
		return "needs " + str(db.techs.get(u["tech"], {}).get("name", u["tech"]))
	if u.has("civic") and not state.civics.has(u["civic"]):
		return "needs " + str(db.civics.get(u["civic"], {}).get("name", u["civic"]))
	if u.has("year") and year() < int(u["year"]):
		return "from %d" % int(u["year"])
	return ""


func set_production(city_id: int, kind: String, id: String, tile := -1) -> bool:
	## Replace the current production (progress on the old item is kept, as in Civ VI).
	var c = city_by_id(city_id)
	if c == null:
		return false
	var why := _can_produce(c, kind, id, tile)
	if why != "":
		notify("invalid", "%s cannot produce %s: %s" % [c.name, id, why])
		return false
	var item := {"kind": kind, "id": id, "tile": tile}
	if kind == "district":
		if tile < 0:
			var sites := econ.district_sites(c, id)
			item["tile"] = SimHex.key(int(sites[0]["q"]), int(sites[0]["r"]))
		c.district_cost[id] = item_cost(c, "district", id)
	if c.queue.size() > 0:
		c.queue[0] = item
	else:
		c.queue.append(item)
	city_changed.emit(c.id)
	_after_decision()
	return true


func enqueue(city_id: int, kind: String, id: String, tile := -1) -> bool:
	var c = city_by_id(city_id)
	if c == null or c.queue.size() >= 8:
		return false
	if _can_produce(c, kind, id, tile) != "":
		return false
	if c.queue.is_empty():
		return set_production(city_id, kind, id, tile)
	c.queue.append({"kind": kind, "id": id, "tile": tile})
	return true


func clear_queue(city_id: int) -> void:
	var c = city_by_id(city_id)
	if c != null:
		c.queue.clear()


func _can_produce(c: SimCity, kind: String, id: String, tile: int) -> String:
	for o in buildable(c, kind, id):
		if o["kind"] == kind and o["id"] == id:
			if not o["available"]:
				return o["reason"]
			if kind == "district" and tile >= 0 and econ.district_ok(c, id, tile) != "":
				return econ.district_ok(c, id, tile)
			return ""
	return "not buildable here"


func purchase_cost(c: SimCity, kind: String, id: String, currency: String) -> int:
	if kind in ["district", "project", "city_project"]:
		return -1   # Civ VI: districts and wonders cannot be bought
	var remaining := item_cost(c, kind, id) - float(c.progress.get(kind + ":" + id, 0.0))
	if currency == "cohesion":
		var ok := false
		if kind == "building" and db.buildings.get(id, {}).get("cohesion_buy", false): ok = true
		if kind == "unit" and id in ["settler", "builder"]: ok = true
		return int(round(remaining * 2.0 / 5.0) * 5) if ok else -1
	return int(round(remaining * 4.0 * (1.0 + 0.25 * log(1.0 + maxf(0.0, state.inflation) / 100.0)) / 5.0) * 5)


func purchase(city_id: int, kind: String, id: String, currency := "gold") -> bool:
	var c = city_by_id(city_id)
	if c == null:
		return false
	if purchase_reason(c, kind, id) != "":
		return false
	var cost := purchase_cost(c, kind, id, currency)
	if cost < 0:
		return false
	if currency == "gold":
		if state.gold < cost: return false
		state.gold -= cost
	else:
		if state.cohesion < cost: return false
		state.cohesion -= cost
	c.progress.erase(kind + ":" + id)
	for q in c.queue.duplicate():
		if q["kind"] == kind and q["id"] == id:
			c.queue.erase(q)
	_complete(c, {"kind": kind, "id": id, "tile": -1})
	return true


func purchase_reason(c: SimCity, kind: String, id: String) -> String:
	## Why an item cannot be bought; "" if it can. Items already in production or queued can be bought
	## (Civ VI: buy the current build).
	var saved: Array = c.queue.duplicate()
	c.queue = c.queue.filter(func(q): return not (q["kind"] == kind and q["id"] == id))
	var why := _can_produce(c, kind, id, -1)
	c.queue = saved
	return why


func current_purchase(city_id: int) -> Dictionary:
	## Buy button for the "Producing:" line: {kind, id, gold_cost, cohesion_cost, reason}.
	var c = city_by_id(city_id)
	if c == null or c.queue.is_empty():
		return {}
	var it: Dictionary = c.queue[0]
	return {"kind": it["kind"], "id": it["id"], "gold_cost": purchase_cost(c, it["kind"], it["id"], "gold"),
		"cohesion_cost": purchase_cost(c, it["kind"], it["id"], "cohesion"), "reason": purchase_reason(c, it["kind"], it["id"])}


func buy_tile(city_id: int, q: int, r: int) -> bool:
	var c = city_by_id(city_id)
	if c == null:
		return false
	for t in econ.buyable_tiles(c):
		if int(t["q"]) == q and int(t["r"]) == r:
			if state.gold < float(t["cost"]):
				return false
			state.gold -= float(t["cost"])
			econ.claim(c, SimHex.key(q, r))
			c.tiles_claimed += 1
			territory_changed.emit()
			refresh_city(c)
			return true
	return false


func _maintenance() -> float:
	## Buildings, specialty districts, public services (by population and era), units and mothballed buildings
	## (v3 fix3-econ: SimEconomy.upkeep_parts(), the parts kept in counters "upkeep_parts" for the structural alarm).
	var p: Dictionary = econ.upkeep_parts()
	state.counters["unit_upkeep"] = float(p["units"])
	state.counters["upkeep_parts"] = p
	return float(p["total"])


func trade_route_gold(tr: Dictionary) -> float:
	var g := 3.0 + 0.5 * state.era
	var st := str(state.diplomacy.get(tr.get("partner", ""), {}).get("status", "none"))
	if st == "peace": g += 1.0
	if st == "normalized": g += 2.0
	for e in econ.mods:
		if e.get("type") == "trade_gold":
			var cond = e.get("cond", {})
			if typeof(cond) == TYPE_DICTIONARY and cond.has("partner_status"):
				if st in cond["partner_status"]: g += float(e.get("amount", 0))
			else:
				g += float(e.get("amount", 0))
	var c = city_by_id(int(tr.get("from", 0)))
	if c != null:
		if c.has_building("container_terminal"): g += 1.0
		if c.has_building("cargo_terminal"): g += 1.0
	return g


# ================================================================== research and civics

const EARLY_WINDOW := 8.0    # techs and civics open up to 8 years before history (at +4% cost per year early) ...
const MIN_OPTIONS := 3        # ... widened only as far as needed to keep 3 real options open,
const MAX_WINDOW := 12.0      # but never beyond 12 years (repeatable programmes keep the list non-empty)


func early_window(kind: String) -> float:
	## Years ahead of history an item may be started. 8, or more when fewer than 3 items (prereqs met,
	## not yet done) would be open: then up to the year of the 3rd-earliest candidate. Cached per turn.
	var key := "window_" + kind
	var cache: Dictionary = get_meta(key) if has_meta(key) else {}
	var done_n := state.techs.size() if kind == "tech" else state.civics.size()
	if int(cache.get("turn", -1)) == state.turn and int(cache.get("done", -1)) == done_n:
		return float(cache["w"])
	var years := []
	var lst: Array = db.tech_list if kind == "tech" else db.civic_list
	var have: Dictionary = state.techs if kind == "tech" else state.civics
	for t in lst:
		if t.get("repeatable", false) or t.get("rail", false) or have.has(t["id"]) or t.get("year") == null: continue
		var ok := true
		for p in t.get("prereqs", []):
			if not have.has(p): ok = false
		if ok: years.append(float(t["year"]))
	years.sort()
	var now := SimDB.year_f(state.turn)
	# civics are policy eras: keep them closer to their dates than techs (critic 02: 1963 offered 1975-77 civics)
	var w := EARLY_WINDOW if kind == "tech" else 6.0
	var min_opts := MIN_OPTIONS if kind == "tech" else 2
	if years.size() >= min_opts:
		w = maxf(w, years[min_opts - 1] - now)
	elif not years.is_empty():
		w = maxf(w, years[years.size() - 1] - now)
	w = minf(w, MAX_WINDOW if kind == "tech" else 8.0)   # beyond this the repeatable programmes fill the list
	set_meta(key, {"turn": state.turn, "done": done_n, "w": w})
	return w


func tech_available(id: String) -> String:
	var t = db.techs.get(id)
	if t == null: return "unknown"
	if state.techs.has(id) and not t.get("repeatable", false): return "researched"
	if t.has("replaced_by_tech") and state.techs.has(str(t["replaced_by_tech"])): return "replaced by a later programme"
	for p in t.get("prereqs", []):
		if not state.techs.has(p): return "needs " + str(db.techs.get(p, {}).get("name", p))
	var ty = SimDB.hist_year(t)   # v3 fix3-story A11: a tech dated after the game's end shows no history year
	if ty != null and SimDB.year_f(state.turn) < float(ty) - early_window("tech"):
		if t.get("year") == null:
			return "not before %d (not reached in history by the game's end)" % int(ceil(float(ty) - early_window("tech")))
		return "not before %d (history: %d)" % [int(ceil(float(t["year"]) - early_window("tech"))), int(t["year"])]
	return ""


func tech_cost(id: String) -> float:
	var t = db.techs.get(id, {})
	var cost := float(t.get("cost", 500))
	if SimDB.hist_year(t) != null:
		var early := float(SimDB.hist_year(t)) - SimDB.year_f(state.turn)
		if early > 0:
			cost *= 1.0 + 0.07 * early      # bounded divergence: earlier than history costs more
		elif early < -2.0:
			cost *= 0.8                     # catch-up (Civ VI R&F world era rule)
	if t.get("repeatable", false):
		cost *= 1.0 + 0.15 * int(state.repeat_count.get(id, 0))
	return round(cost)


func civic_available(id: String) -> String:
	var c = db.civics.get(id)
	if c == null: return "unknown"
	if state.civics.has(id) and not c.get("repeatable", false): return "adopted"
	if c.get("rail", false): return "arrives with history (%s)" % str(c.get("year", ""))
	for p in c.get("prereqs", []):
		if not state.civics.has(p): return "needs " + str(db.civics.get(p, {}).get("name", p))
	if c.get("year") != null and SimDB.year_f(state.turn) < float(c["year"]) - early_window("civic"):
		return "not before %d (history: %d)" % [int(ceil(float(c["year"]) - early_window("civic"))), int(c["year"])]
	return ""


func civic_cost(id: String) -> float:
	var c = db.civics.get(id, {})
	var cost := float(c.get("cost", 400))
	if c.get("year") != null:
		var early := float(c["year"]) - SimDB.year_f(state.turn)
		if early > 0: cost *= 1.0 + 0.07 * early
		elif early < -2.0: cost *= 0.8
	if c.get("repeatable", false):
		cost *= 1.0 + 0.2 * int(state.repeat_count.get("civic:" + id, 0))
	return round(cost)


func set_research(id: String) -> bool:
	if tech_available(id) != "":
		return false
	state.current_tech = id
	_spend_unspent("science_unspent", state.tech_progress, id, tech_cost(id))
	_after_decision()
	return true


func set_civic(id: String) -> bool:
	if civic_available(id) != "":
		return false
	state.current_civic = id
	_spend_unspent("culture_unspent", state.civic_progress, id, civic_cost(id))
	_after_decision()
	return true


func _spend_unspent(counter: String, progress: Dictionary, id: String, cost: float) -> void:
	## Science or culture earned while nothing was selected is kept and goes to the next choice
	## (up to one point short of completion, so the completion still happens on a turn boundary).
	var u := float(state.counters.get(counter, 0.0))
	if u <= 0.0: return
	var room := maxf(0.0, cost - 1.0 - float(progress.get(id, 0.0)))
	var used := minf(u, room)
	progress[id] = float(progress.get(id, 0.0)) + used
	state.counters[counter] = u - used


const COMPLETE_AHEAD_MAX := 6.0   # a tech or civic can be finished at most 6 years before its real date


func earliest_completion(item: Dictionary) -> float:
	## Year from which the item may complete: its real year for the Historical Israel ghost,
	## otherwise at most COMPLETE_AHEAD_MAX years earlier (bounded divergence; research can start earlier).
	var iy = SimDB.hist_year(item)
	if iy == null or item.get("repeatable", false):
		return -1.0
	if state.mode == "historical":
		return float(iy)
	return float(iy) - COMPLETE_AHEAD_MAX


func _hold_for_history(item: Dictionary) -> bool:
	return SimDB.year_f(state.turn) < earliest_completion(item)


func _held(kind: String, id: String, progress: Dictionary, cost: float) -> void:
	## Completion is not yet allowed: keep the item one point short, bank the surplus for the next choice.
	var over := float(progress[id]) - (cost - 1.0)
	progress[id] = cost - 1.0
	var counter := "science_unspent" if kind == "tech" else "culture_unspent"
	state.counters[counter] = float(state.counters.get(counter, 0.0)) + maxf(0.0, over)
	var key := "held_note_" + kind + id
	if not state.counters.has(key):
		state.counters[key] = state.turn
		var item: Dictionary = db.techs.get(id, {}) if kind == "tech" else db.civics.get(id, {})
		if item.get("year") == null:   # v3 fix3-story A11: dated after the game's end, so no history year is shown
			notify(kind + "_held", "%s is ready but cannot be completed before %d (not reached in history by the game's end). Surplus %s is kept for your next choice." %
				[item.get("name", id), int(ceil(earliest_completion(item))), "science" if kind == "tech" else "culture"], {"id": id})
		else:
			notify(kind + "_held", "%s is ready but cannot be completed before %d (history: %d). Surplus %s is kept for your next choice." %
				[item.get("name", id), int(ceil(earliest_completion(item))), int(item.get("year", 0)), "science" if kind == "tech" else "culture"], {"id": id})


func _research(sci: float) -> void:
	var id := state.current_tech
	if id == "" or tech_available(id) != "":
		state.counters["science_unspent"] = float(state.counters.get("science_unspent", 0.0)) + sci
		state.current_tech = ""
		return
	state.tech_progress[id] = float(state.tech_progress.get(id, 0.0)) + sci
	var cost := tech_cost(id)
	if state.tech_progress[id] >= cost:
		if _hold_for_history(db.techs[id]):
			_held("tech", id, state.tech_progress, cost)
			return
		var over: float = state.tech_progress[id] - cost
		complete_tech(id, "research")
		var nxt := state.current_tech
		if nxt != "":
			state.tech_progress[nxt] = float(state.tech_progress.get(nxt, 0.0)) + over


func complete_tech(id: String, how: String) -> void:
	var t = db.techs.get(id)
	if t == null:
		return
	if t.get("repeatable", false):
		state.repeat_count[id] = int(state.repeat_count.get(id, 0)) + 1
		state.tech_progress[id] = 0.0
		if state.current_tech == id:
			state.current_tech = ""   # choose again: a real technology may have opened
		_change_standing(1.0, "%s completed" % t["name"])
		state.techs[id] = state.turn
		notify("tech", "%s completed (%d)." % [t["name"], state.repeat_count[id]])
		return
	state.techs[id] = state.turn
	state.tech_progress.erase(id)
	state.milestones["tech:" + id] = state.turn
	if state.current_tech == id:
		state.current_tech = ""
	var era_first := true
	for o in state.techs:
		if o != id and int(db.techs.get(o, {}).get("era", 0)) == int(t.get("era", 0)): era_first = false
	if era_first:
		add_moment("First technology of a new era: %s" % t["name"], 1, "tech")
	if t.get("year") != null:
		var ahead := int(t["year"]) - year()
		if ahead >= 3:
			add_moment("%s researched %d years before history" % [t["name"], ahead], 1, "tech")
	notify("tech", "Research completed: %s" % t["name"], {"id": id, "how": how})
	tech_completed.emit(id)


func _civic_progress(cul: float) -> void:
	var id := state.current_civic
	if id == "" or civic_available(id) != "":
		state.counters["culture_unspent"] = float(state.counters.get("culture_unspent", 0.0)) + cul
		state.current_civic = ""
		return
	state.civic_progress[id] = float(state.civic_progress.get(id, 0.0)) + cul
	var cost := civic_cost(id)
	if state.civic_progress[id] >= cost:
		if _hold_for_history(db.civics[id]):
			_held("civic", id, state.civic_progress, cost)
			return
		var over: float = state.civic_progress[id] - cost
		complete_civic(id, "culture")
		if state.current_civic != "":
			state.civic_progress[state.current_civic] = float(state.civic_progress.get(state.current_civic, 0.0)) + over


func complete_civic(id: String, how: String) -> void:
	var c = db.civics.get(id)
	if c == null:
		return
	if c.get("repeatable", false):
		var rk := "civic:" + id
		state.repeat_count[rk] = int(state.repeat_count.get(rk, 0)) + 1
		state.civic_progress[id] = 0.0
		state.civics[id] = state.turn
		if state.current_civic == id: state.current_civic = ""
		var st_gain := float(c.get("standing_per_completion", 1.0))
		_change_standing(st_gain, "%s completed" % c["name"])
		state.cohesion += float(c.get("cohesion_per_completion", 10.0))
		notify("civic", "%s completed (%d): +%d Standing, +%d Cohesion." % [c["name"], state.repeat_count[rk], int(st_gain), int(c.get("cohesion_per_completion", 10.0))], {"id": id, "how": how})
		civic_completed.emit(id)
		return
	if state.civics.has(id):
		return
	if how == "history" and state.flags.has("blocked_civic:" + id):
		return   # an earlier choice took the country down another path
	state.civics[id] = state.turn
	state.civic_progress.erase(id)
	state.milestones["civic:" + id] = state.turn
	if state.current_civic == id:
		state.current_civic = ""
	state.free_swap = true
	notify("civic", "Civic adopted: %s" % c["name"], {"id": id, "how": how})
	civic_completed.emit(id)


func boost(kind: String, id: String, fraction: float, text: String, counts_as_eureka := true) -> void:
	var key := kind + ":" + id
	if counts_as_eureka and state.boosts.has(key):
		return
	if kind == "tech":
		if state.techs.has(id) and not db.techs.get(id, {}).get("repeatable", false): return
		var cost := tech_cost(id)
		state.tech_progress[id] = minf(cost, float(state.tech_progress.get(id, 0.0)) + cost * fraction)
		if state.tech_progress[id] >= cost and tech_available(id) == "" and not _hold_for_history(db.techs[id]):
			complete_tech(id, "boost")
	else:
		if state.civics.has(id): return
		var cc := civic_cost(id)
		state.civic_progress[id] = minf(cc, float(state.civic_progress.get(id, 0.0)) + cc * fraction)
		if state.civic_progress[id] >= cc and civic_available(id) == "" and not _hold_for_history(db.civics[id]):
			complete_civic(id, "boost")
	if counts_as_eureka:
		state.boosts[key] = state.turn
		state.milestones["boost:" + key] = state.turn
		add_moment("%s: %s" % ["Eureka" if kind == "tech" else "Inspiration", text], 1, "boost")
		if state.dedication == "innovation" and state.age != "golden":
			state.era_score += 1
	boost_triggered.emit(kind, id, text)


func _rebuild_stats() -> void:
	var s := {"buildings": {}, "districts": {}, "imps": [], "units": {}, "unit_cls": {}, "max_pop": 0, "transit": 0.0}
	for c in active_cities():
		for b in c.buildings: s["buildings"][b] = int(s["buildings"].get(b, 0)) + 1
		for d in c.districts: s["districts"][d] = int(s["districts"].get(d, 0)) + 1
		s["max_pop"] = maxi(s["max_pop"], c.pop())
		s["transit"] += float(c.info.get("transit", 0.0))
	var sb: Dictionary = state.counters.get("start_buildings", {})
	for b in sb:
		if s["buildings"].has(b): s["buildings"][b] = maxi(0, int(s["buildings"][b]) - int(sb[b]))
	for k in state.tiles:
		var imp := str(state.tiles[k].get("imp", ""))
		if imp != "" and int(state.tiles[k].get("o", 0)) > 0 and not state.tiles[k].get("seed", false):
			s["imps"].append([imp, econ.terrain(k)])
	for u in state.units:
		if u.owner == "player":
			s["units"][u.type] = int(s["units"].get(u.type, 0)) + 1
			var cls := str(db.units.get(u.type, {}).get("cls", ""))
			s["unit_cls"][cls] = int(s["unit_cls"].get(cls, 0)) + 1
			if cls in MILITARY_CLASSES:
				s["unit_cls"]["military"] = int(s["unit_cls"].get("military", 0)) + 1
	stats = s


func trigger_met(tr: Dictionary) -> bool:
	match str(tr.get("type", "none")):
		"building_count": return int(stats["buildings"].get(tr.get("building"), 0)) >= int(tr.get("count", 1))
		"district_count": return int(stats["districts"].get(tr.get("district"), 0)) >= int(tr.get("count", 1))
		"improvement_count", "improvement_total":
			var n := 0
			for it in stats["imps"]:
				if tr.has("improvement") and not (it[0] in tr["improvement"]): continue
				if tr.has("terrain") and not (it[1] in tr["terrain"]): continue
				n += 1
			return n >= int(tr.get("count", 1))
		"units_count":
			if tr.has("unit"): return int(stats["units"].get(tr["unit"], 0)) >= int(tr.get("count", 1))
			return int(stats["unit_cls"].get(tr.get("unit_class", ""), 0)) >= int(tr.get("count", 1))
		"water_deficit_turns": return int(state.water.get("deficit_turns", 0)) >= int(tr.get("turns", 4))
		"transit_residents": return float(stats.get("transit", 0.0)) >= float(tr.get("count", 1))
		"immigrants_absorbed": return float(state.counters.get("immigrants_absorbed", 0.0)) >= float(tr.get("count", 1))
		"towns_founded": return int(state.counters.get("towns_founded", 0)) >= int(tr.get("count", 1))
		"tech": return state.techs.has(tr.get("tech", ""))
		"civic": return state.civics.has(tr.get("civic", ""))
		"treasury": return state.gold >= float(tr.get("gold", 0))
		"standing": return state.standing >= float(tr.get("amount", 0))
		"trade_routes": return state.trade_routes.size() >= int(tr.get("count", 1))
		"combat_wins": return state.unit_kills >= int(tr.get("count", 1))
		"city_damaged": return int(state.counters.get("cities_rocketed", 0)) >= int(tr.get("count", 1))
		"city_pop": return int(stats["max_pop"]) >= int(tr.get("pop", 10))
		"cities_terrain":
			var n2 := 0
			for c in active_cities():
				if econ.terrain(SimHex.key(c.q, c.r)) in tr.get("terrain", []): n2 += 1
			return n2 >= int(tr.get("count", 1))
		"city_near_resource":
			for c in active_cities():
				for p in SimHex.within(c.q, c.r, int(tr.get("radius", 4))):
					var t = db.tiles.get(SimHex.key(p.x, p.y))
					if t != null and str(t.get("resource", "")) in tr.get("resource", []): return true
			return false
		"district_in_region":
			for c in active_cities():
				if c.has_district(str(tr.get("district"))):
					var reg := econ.region(int(c.districts[tr["district"]]))
					for rr in tr.get("region", []):
						if reg.find(rr) >= 0: return true
			return false
		"district_adjacent":
			for c in active_cities():
				if c.has_district(str(tr.get("district"))):
					var p := SimHex.from_key(int(c.districts[tr["district"]]))
					for n in SimHex.neighbors(p.x, p.y):
						if str(econ.tstate(SimHex.key(n.x, n.y)).get("d", "")) == tr.get("adjacent"): return true
			return false
	return false


func _check_boosts() -> void:
	for t in db.tech_list:
		var key := "tech:" + str(t["id"])
		if state.boosts.has(key) or state.techs.has(t["id"]): continue
		if t.get("year") != null and SimDB.year_f(state.turn) < float(t["year"]) - early_window("tech"): continue
		var eu: Dictionary = t.get("eureka", {})
		if eu.get("type", "none") != "none" and trigger_met(eu):
			boost("tech", t["id"], 0.4, "%s (%s)" % [t["name"], str(eu.get("text", ""))])
	for c in db.civic_list:
		var key2 := "civic:" + str(c["id"])
		if state.boosts.has(key2) or state.civics.has(c["id"]) or c.get("rail", false): continue
		if c.get("year") != null and SimDB.year_f(state.turn) < float(c["year"]) - early_window("civic"): continue
		var ins: Dictionary = c.get("inspiration", {})
		if ins.get("type", "none") != "none" and trigger_met(ins):
			boost("civic", c["id"], 0.4, "%s (%s)" % [c["name"], str(ins.get("text", ""))])


# ================================================================== policies

func policy_slots() -> Array:
	return state.policies.map(func(p): return p["slot"])


func policy_available(pid: String) -> String:
	var p = db.policies.get(pid)
	if p == null: return "unknown"
	var why := _unlock_reason(p.get("unlock", {}))
	if why != "": return why
	if p.has("obsolete_by") and state.civics.has(p["obsolete_by"]): return "obsolete"
	if p.has("available_until") and year() > int(p["available_until"]): return "no longer available (%d)" % int(p["available_until"])
	return ""


func available_policies() -> Array:
	var out := []
	for p in db.policy_list:
		if policy_available(p["id"]) == "":
			out.append(p["id"])
	return out


func policy_swap_cost() -> int:
	return 0 if state.free_swap else int(round((60.0 + 300.0 * progress_fraction()) / 5.0) * 5)


func set_policy(slot_index: int, pid: String) -> bool:
	if slot_index < 0 or slot_index >= state.policies.size():
		return false
	var slot: Dictionary = state.policies[slot_index]
	if pid != "":
		if policy_available(pid) != "": return false
		var p = db.policies[pid]
		if slot["slot"] != "wildcard" and p["slot"] != slot["slot"]: return false
		for o in state.policies:
			if o["id"] == pid and o != slot: return false
	if str(slot.get("id", "")) != "" and str(slot["id"]) != pid:
		var cost := policy_swap_cost()
		if state.gold < cost: return false
		state.gold -= cost
	slot["id"] = pid
	refresh()
	return true


# ================================================================== decisions ("Next Action")

const DECISION_ORDER := ["event_choice", "fork", "coalition", "crisis_response", "policy_review", "state_budget", "budget_review", "immigration", "diplomacy", "programme", "minister", "dedication", "fill_policy", "choose_research", "choose_civic", "choose_production", "unit_orders", "agenda"]
const STORY_TYPES := ["event_choice", "fork", "crisis_response", "policy_review", "immigration", "dedication", "state_budget", "budget_review", "minister", "coalition", "programme"]   # (v3: the envoy decision does not make a quarter "busy", so it never shifts the cabinet's timing)


func get_pending_decisions() -> Array:
	## Every open decision this turn. Blocking ones gate end_turn(); order follows Civ VI's end-turn button.
	var out := []
	for eid in state.pending_events:
		var ev = db.event_by_id.get(eid)
		if ev != null:
			out.append({"type": "event_choice", "blocking": true, "label": "EVENT: " + str(ev.get("title", eid)), "event": eid,
				"choices": events.choice_view(ev)})
	for fid in state.pending_forks:
		var fv: Dictionary = forks.fork_view(fid)
		if not fv.is_empty():
			out.append({"type": "fork", "blocking": true, "label": "CABINET DECISION: " + str(fv["title"]), "fork": fid, "title": fv["title"],
				"text": fv["text"], "options": fv["options"], "source": fv["source"]})
	if not state.crisis_decision.is_empty() and not state.crisis_decision.get("done", false):
		out.append({"type": "crisis_response", "blocking": true, "label": "CRISIS RESPONSE: " + str(state.crisis_decision.get("title", "")),
			"options": state.crisis_decision.get("options", []), "war_turn": bool(state.crisis_decision.get("war_turn", false)),
			"crisis": state.crisis_decision.get("crisis", ""), "title": state.crisis_decision.get("title", ""),
			"phase": int(state.crisis_decision.get("phase", 1)), "phases": int(state.crisis_decision.get("phases", 1)),
			"phase_name": str(state.crisis_decision.get("phase_name", "")), "war": str(state.crisis_decision.get("war", ""))})
	if int(state.counters.get("policy_review", -1)) == state.turn:
		out.append({"type": "policy_review", "blocking": true, "label": "NEW GOVERNMENT: REVIEW POLICY CARDS", "government": events.current_term(),
			"slots": state.policies.duplicate(true), "available": available_policies(), "free_swap": true, "proposals": policy_proposals()})
	if econ.immigration_decision_due():
		var wave: String = econ.immigration_wave()
		out.append({"type": "immigration", "blocking": true, "label": ("PLACE IMMIGRANTS: %s, about %s a quarter for the coming year" % [wave, econ._fmt_n(econ.expected_arrivals())]) if wave != "" else ("PLACE IMMIGRANTS: about %s a quarter for the coming year" % econ._fmt_n(econ.expected_arrivals())),
			"wave": wave,
			"options": econ.immigration_options(), "historical": econ.historical_immigration_choice()})
	var dipd: Dictionary = diplo.decision()   # v3: the envoy decision (SimDiplomacy)
	if not dipd.is_empty():
		out.append(dipd)
	out.append_array(cabinet.decisions(int(state.counters.get("busy_turn", -1)) == state.turn))
	if state.pending_dedication:
		out.append({"type": "dedication", "blocking": true, "label": "CHOOSE DEDICATION", "options": events.dedications()})
	var avail := available_policies()
	var slotted := state.policies.map(func(p): return p["id"])
	for i in range(state.policies.size()):
		if str(state.policies[i]["id"]) == "":
			for pid in avail:
				var p = db.policies[pid]
				if not (pid in slotted) and (state.policies[i]["slot"] == "wildcard" or p["slot"] == state.policies[i]["slot"]):
					out.append({"type": "fill_policy", "blocking": true, "label": "FILL POLICY SLOT", "slot": i, "slot_type": state.policies[i]["slot"]})
					break
	if state.current_tech == "" and _any_tech_available():
		out.append({"type": "choose_research", "blocking": true, "label": "CHOOSE RESEARCH"})
	if state.current_civic == "" and _any_civic_available():
		out.append({"type": "choose_civic", "blocking": true, "label": "CHOOSE CIVIC"})
	for c in active_cities():
		if c.queue.is_empty():
			out.append({"type": "choose_production", "blocking": true, "label": "CHOOSE PRODUCTION: " + c.name, "city": c.id})
	for u in state.units:
		if u.owner == "player" and u.orders == "" and u.moves > 0 and military.needs_orders(u):
			out.append({"type": "unit_orders", "blocking": true, "label": "UNIT NEEDS ORDERS: " + str(db.units.get(u.type, {}).get("name", u.type)), "unit": u.id})
	if not state.agenda.is_empty() and not state.agenda.get("done", false):
		var aopts := []
		for o in state.agenda.get("options", []):
			var oo: Dictionary = o.duplicate()
			oo["effects"] = events.agenda_struct(o.get("fx", {})) + o.get("effects_extra", [])   # v3 fix3-econ: lever effects
			aopts.append(oo)
		out.append({"type": "agenda", "blocking": true, "label": "CABINET AGENDA: " + str(state.agenda.get("title", "")), "options": aopts,
			"text": state.agenda.get("text", "")})
	# non-blocking prompts
	if state.trade_routes.size() < trade_capacity() and trade_partners().size() > 0:
		out.append({"type": "trade_route", "blocking": false, "label": "EXPORT ROUTE AVAILABLE"})
	return out


func blocking_decisions() -> Array:
	return get_pending_decisions().filter(func(d): return d.get("blocking", false))


static func domains() -> Array:
	## V4 (v4-sim-auto): the 11 routine domains the ministers can run: [{id, name, short, minister, label, types, desc}].
	return SimAuto.domains_static()


func next_action() -> Dictionary:
	## What the Next Action button should do: the first blocking decision, or end_turn.
	## V4: outside Full control, the one primary prompt (sim.auto.primary(): the first player-owned decision).
	if not auto.is_full():
		return auto.primary()
	var b := blocking_decisions()
	for t in DECISION_ORDER:
		for d in b:
			if d["type"] == t:
				return d
	return {"type": "end_turn", "blocking": false, "label": "NEXT TURN"}


func _any_tech_available() -> bool:
	for t in db.tech_list:
		if tech_available(t["id"]) == "":
			return true
	return false


func _any_civic_available() -> bool:
	for c in db.civic_list:
		if civic_available(c["id"]) == "":
			return true
	return false


func choose_event(event_id: String, choice_index: int) -> bool:
	var ok: bool = events.choose(event_id, choice_index)
	if ok:
		events.apply_territory_rails(false)
	_after_decision()
	return ok


func choose_immigration(option_id: String) -> bool:
	## Where this quarter's immigrants go: "cities", "dev_towns", "villages" or "camps" (see get_pending_decisions).
	var ok: bool = econ.choose_immigration(option_id)
	_after_decision()
	return ok


func choose_fork(fork_id: String, option) -> bool:
	## option: the option id (String) or its index (int).
	var ok: bool = forks.choose(fork_id, option)
	_after_decision()
	return ok


func get_fork(fork_id: String) -> Dictionary:
	return forks.fork_view(fork_id)


func get_end_summary() -> Dictionary:
	## Everything the end screen needs: six-track table vs the ghost (with real-world labels), overall score,
	## verdict, itemised reasons, the path ledger, crises and the timeline highlights.
	var cur := score.final_summary()
	cur["ledger"] = get_path_ledger()
	cur["ledger_summary"] = endgame.choice_counts()   # v3 final round (fix4-econ): one source, sim.forks.get_path_ledger() (envoys apart)
	cur["counterfactual_choices"] = int(cur["ledger_summary"]["differed"])
	cur["crises"] = state.crisis_log.duplicate(true)
	cur["timeline_highlights"] = state.timeline.filter(func(m): return int(m.get("score", 0)) >= 3).slice(0, 40)
	cur["game_over"] = state.game_over
	cur["final_date"] = date_label()
	# v3 (sim-endgame): the ending reached, every ending's thresholds and the epilogue built from the record
	cur["ending"] = endgame.ending_summary()
	cur["endings"] = endgame.get_endings()
	cur["epilogue"] = endgame.get_epilogue()
	cur["difficulty"] = endgame.difficulty_id()
	cur["memorial"] = endgame.memorial() if not collapse.ended() else {}   # data/ending_oct7.json, shown verbatim before the results (never after a collapse)
	cur["collapse"] = collapse.ended_id()   # v3 item 13: "" or the collapse that ended the game early
	cur["goals"] = goals.end_summary() if goals != null else {}   # V4 (v4-goals): met, missed and against history
	return cur


# ------------------------------------------------------------------ v3 (sim-endgame): programmes, endings, difficulty, fiscal, scenarios

func get_programmes() -> Array:
	return endgame.get_programmes()


func fund_programme(programme_id: String) -> bool:
	## Launch the next level of a national programme (paid in quarterly instalments).
	return endgame.launch(programme_id)


func expand_programme(programme_id: String) -> bool:
	return endgame.expand(programme_id)


func cancel_programme(programme_id: String) -> bool:
	return endgame.cancel(programme_id)


func choose_programme(index: int) -> bool:
	var ok: bool = endgame.choose_programme(index)
	_after_decision()
	return ok


func get_endings() -> Dictionary:
	return endgame.get_endings()


func get_epilogue() -> Dictionary:
	return endgame.get_epilogue()


func get_difficulty() -> Dictionary:
	return endgame.get_difficulty()


static func difficulty_levels() -> Array:
	return SimEndgame.difficulty_levels()


func hints_enabled() -> bool:
	## false on Historian: hide Recommended badges and history's choice until after the pick.
	return endgame.hints()


func get_fiscal_indicator() -> Dictionary:
	return endgame.fiscal_indicator()


func get_food_balance() -> Dictionary:
	return endgame.food_balance()


func get_ending_memorial() -> Dictionary:
	## The memorial text shown on a black screen after the last turn (data/ending_oct7.json, verbatim).
	return endgame.memorial()


static func scenario_starts() -> Array:
	return SimEndgame.scenario_list()


# names asked for by ui-v3 (INTEGRATION_REQUESTS "## v3", items 1-6)
func get_economy_indicator() -> Dictionary:
	return endgame.economy_indicator()


func get_food_report() -> Dictionary:
	return endgame.food_report()


static func get_difficulties() -> Array:
	return SimEndgame.difficulties_view()


static func get_scenarios() -> Array:
	return SimEndgame.scenarios_view()


func get_ending_outlook() -> Array:
	return endgame.ending_outlook()


func get_collapse_status() -> Array:
	## v3 item 13 (fix-v3a): [{id, name, summary, strain, limit, quarters_left, level: ok|watch|danger, progress, conditions, advice}]
	return collapse.status()


func get_collapse_warnings() -> Array:
	## The collapses in danger now (closest first); [] when none.
	return collapse.warnings()


func get_collapse_top_bar() -> Dictionary:
	## {show, level, text, name, id, tooltip: [lines]}: the top bar's danger item.
	return collapse.top_bar()


func get_path_ledger() -> Array:
	## "Your Israel vs history": every cabinet decision taken, whether it matched history, and its lasting terms.
	## v3: diplomatic decisions (envoys) follow, with "kind": "diplomacy".
	var out: Array = forks.get_path_ledger()
	out.append_array(diplo.ledger())
	out.sort_custom(func(a, b): return int(a.get("turn", 0)) < int(b.get("turn", 0)))
	return out


func resolve_recommended(decision: Dictionary) -> bool:
	## Resolves one decision (from get_pending_decisions / next_action) with the Recommended pick (same logic as SimAI).
	## V4: also the casual layer's "treasury" (Finance's plan) and "brief" (Balanced) items.
	return SimAI.resolve_one(self, decision)


func policy_proposals() -> Array:
	## Concrete coalition programmes for a new government (each changes up to two slots), so the review is a
	## real choice: the prime minister's programme (best for your tracks), the partners' demands (social and
	## diplomatic cards) or keeping the outgoing cards. choose_policy_proposal(i) applies one.
	var out := []
	var cur: Array = state.policies.map(func(p): return str(p.get("id", "")))
	var avail := available_policies()
	var modes := [["programme", "The new prime minister's programme"], ["partners", "The coalition partners' demands"]]
	for m in modes:
		var gains := []
		for i in range(state.policies.size()):
			var slot: Dictionary = state.policies[i]
			var cv := _proposal_value(m[0], cur[i])
			var best := ""; var bg := -1e9
			for pid in avail:
				if cur.has(pid): continue
				if slot["slot"] != "wildcard" and str(db.policies[pid]["slot"]) != str(slot["slot"]): continue
				var g := _proposal_value(m[0], pid) - cv
				if g > bg: bg = g; best = pid
			if best != "" and (bg > 0.0 or m[0] == "partners"):
				gains.append([bg, i, best])
		gains.sort_custom(func(a, b): return a[0] > b[0])
		var changes := []
		var used := {}
		for g in gains:
			if changes.size() >= 2 or used.has(g[2]): continue
			used[g[2]] = true
			changes.append({"slot": g[1], "slot_type": state.policies[g[1]]["slot"], "from": cur[g[1]], "to": g[2],
				"from_name": str(db.policies.get(cur[g[1]], {}).get("name", "(empty)")), "to_name": str(db.policies[g[2]].get("name", g[2]))})
		if changes.is_empty(): continue
		var dup := false
		for o in out:
			if JSON.stringify(o["changes"]) == JSON.stringify(changes): dup = true
		if dup: continue
		out.append({"id": m[0], "label": m[1], "changes": changes,
			"summary": "; ".join(changes.map(func(c): return "%s -> %s" % [c["from_name"], c["to_name"]]))})
	out.append({"id": "keep", "label": "Keep the outgoing government's cards", "changes": [], "summary": "No change"})
	return out


func _proposal_value(mode: String, pid: String) -> float:
	if pid == "" or not db.policies.has(pid):
		return 0.0
	if mode == "programme":
		return SimAI.card_value(self, pid)
	var v := 0.0
	for e in db.policies[pid].get("effects", []):
		match str(e.get("type", "")):
			"trust", "amenity": v += 10.0 * float(e.get("amount", 0))
			"cohesion_per_turn": v += 6.0 * float(e.get("amount", 0))
			"standing_per_turn": v += 80.0 * float(e.get("amount", 0))
			"retention", "growth_pct": v += 2.0 * float(e.get("pct", 0))
			"gold_per_pop", "gold_per_turn": v += 0.5
			_: v += 0.5
	return v


func choose_policy_proposal(index: int) -> bool:
	## Applies one of the review's proposals (free this turn) and closes the review.
	if int(state.counters.get("policy_review", -1)) != state.turn:
		return false
	var props := policy_proposals()
	if index < 0 or index >= props.size():
		return false
	state.free_swap = true
	for ch in props[index]["changes"]:
		set_policy(int(ch["slot"]), str(ch["to"]))
	state.counters["policy_proposal"] = str(props[index]["id"])
	return confirm_policies()


func confirm_policies() -> bool:
	## Closes the new-government policy review (after any set_policy calls, which are free this turn).
	if int(state.counters.get("policy_review", -1)) != state.turn:
		return false
	state.counters["policy_review"] = -1
	_after_decision()
	return true


func choose_agenda(option_index: int) -> bool:
	var fx: Dictionary = {}
	var ao: Array = state.agenda.get("options", [])
	if not state.agenda.get("done", false) and option_index >= 0 and option_index < ao.size():
		fx = ao[option_index].get("fx", {})
	var ok: bool = events.choose_agenda(option_index)
	if ok and fx.has("econ_action"):
		econ.agenda_action(fx)   # v3 fix3-econ: the structural-deficit levers (mothball, privatise, stabilise)
	_after_decision()
	return ok


func choose_crisis_response(option_index: int) -> bool:
	var ok: bool = military.choose_response(option_index)
	_after_decision()
	return ok


func choose_dedication(id: String) -> bool:
	for d in SimEvents.DEDICATIONS:
		if d["id"] == id:
			state.dedication = id
			state.pending_dedication = false
			refresh()
			_after_decision()
			return true
	return false


# ================================================================== trade, diplomacy, ministries

func trade_capacity() -> int:
	var n := 0
	for c in active_cities():
		if c.has_district("port") or c.has_district("airport") or c.has_district("business_district"):
			n += 1
	return maxi(1, mini(n, 3 + state.era * 2) + int(econ.mod_sum("trade_route_capacity")))


func trade_partners() -> Array:
	var out := []
	var tradeable: Array = db.actor_meta.get("tradeable", ["relations_established", "peace", "normalized"])
	for a in db.actors:
		var meta: Dictionary = db.actors[a]
		var st := str(state.diplomacy.get(a, {}).get("status", "none"))
		var ok := st in tradeable
		if meta.get("partner", false) and st != "war" and st != "hostile":
			ok = true
		if meta.has("joins_by_civic") and not state.civics.has(meta["joins_by_civic"]):
			ok = false
		if not ok and st != "war" and st != "hostile" and diplo.trade_partner_extra(a):
			ok = true   # v3: a liaison or trade office opened by a deal
		if ok:
			out.append(a)
	return out


func start_trade_route(city_id: int, partner: String) -> bool:
	var c = city_by_id(city_id)
	if c == null or state.trade_routes.size() >= trade_capacity() or not (partner in trade_partners()):
		return false
	for tr in state.trade_routes:
		if int(tr["from"]) == city_id and tr["partner"] == partner:
			return false
	state.trade_routes.append({"from": city_id, "partner": partner, "turns": 14})
	diplo.recompute(partner)   # v3: export routes are a live cause of the relation (+3 each)
	refresh_city(c)
	return true


func send_delegation(actor: String) -> bool:
	var d = state.diplomacy.get(actor)
	if d == null:
		return false
	var cost := int(round(25.0 * (1.0 + 2.0 * progress_fraction())))
	if state.gold < cost or state.turn - int(d.get("last_delegation", -99)) < 8:
		return false
	if str(d.get("status", "")) in ["war"]:
		return false
	state.gold -= cost
	d["last_delegation"] = state.turn
	diplo.send_delegation_mod(actor)   # v3: +8, a remembered cause that fades (half-life 3 years)
	_change_standing(0.3, "Delegation to " + str(db.actors.get(actor, {}).get("name", actor)))
	if state.dedication == "statecraft" and state.age != "golden":
		state.era_score += 1
	return true


func ministry_titles() -> int:
	## v2: ministers are appointed with cabinet titles (see SimCabinet); kept for older callers.
	return state.ministries.size() + cabinet.titles()


func appoint_ministry(ministry: String, city_id: int) -> bool:
	## Appoints a minister with a cabinet title, or moves an appointed minister's seat (free; 2 quarters to settle).
	return cabinet.appoint(ministry, city_id)


# ------------------------------------------------------------------ v2 cabinet: state budget, ministers, coalitions (SimCabinet)

func get_budget() -> Dictionary:
	return cabinet.get_budget()


func choose_state_budget(index: int) -> bool:
	var ok: bool = cabinet.choose_state_budget(index)
	_after_decision()
	return ok


func set_budget_shares(shares: Dictionary) -> bool:
	## A custom split while the State Budget decision is open: {defence, absorption, development, education} (10-55% each).
	return cabinet.set_budget(shares, "custom")


func choose_budget_review(index: int) -> bool:
	var ok: bool = cabinet.choose_budget_review(index)
	_after_decision()
	return ok


func get_ministers() -> Array:
	return cabinet.get_ministers()


func get_cabinet() -> Dictionary:
	return {"titles": cabinet.titles(), "next_title_in": cabinet.next_title_in(),
		"ministers": cabinet.get_ministers(), "options": cabinet.minister_options(), "coalitions": state.counters.get("coalition_history", [])}


func choose_minister(index: int) -> bool:
	var ok: bool = cabinet.choose_minister(index)
	_after_decision()
	return ok


func choose_ministers(picks: Array) -> bool:
	## The cabinet multi-pick (fix-cabinet): option indices or ids from the minister decision, up to its `picks`.
	var ok: bool = cabinet.choose_ministers(picks)
	_after_decision()
	return ok


func get_fiscal_report() -> Dictionary:
	## v3 fix3-econ: running costs against revenue, the structural-deficit alarm and the levers (see API.md).
	return econ.fiscal_report()


func get_city_upkeep(city_id: int) -> Dictionary:
	var c = city_by_id(city_id)
	return econ.city_upkeep(c) if c != null else {}


func mothball_building(city_id: int, building_id: String) -> String:
	## "" on success, else the reason. The building stops working and keeps 20% of its upkeep until reopened.
	return econ.mothball(city_by_id(city_id), building_id)


func reopen_building(city_id: int, building_id: String) -> String:
	return econ.reopen(city_by_id(city_id), building_id)


func close_building(city_id: int, building_id: String) -> String:
	return econ.close_building(city_by_id(city_id), building_id)


func get_privatisations() -> Array:
	return econ.privatisation_options()


func privatise(privatisation_id: String) -> bool:
	return econ.privatise(privatisation_id)


func get_stabilisation() -> Dictionary:
	return econ.stabilisation_option()


func stabilise() -> bool:
	return econ.stabilise()


func get_policy_costs() -> Array:
	## v3 final round (fix4-econ): the slotted policy cards that cost gold, and the levers to scale them back (API.md).
	return econ.policy_costs()


func scale_back_policy(policy_id: String, mode := "half") -> String:
	return econ.scale_back_policy(policy_id, mode)


func restore_policy(policy_id: String) -> String:
	return econ.restore_policy(policy_id)


func get_debt() -> Dictionary:
	## Public debt (fix-cabinet): {debt, cap, room, borrowed_total, borrow_count, interest_total, repaid_early, debt_peak,
	##  service (this quarter), interest, health (economy-track factor), deficit_turns, open_rails: [{label, amount, ends}]}.
	return econ.debt_report()


func appoint_minister(minister: String, city_id: int) -> bool:
	return cabinet.appoint(minister, city_id)


func promote_minister(minister: String, promotion: String) -> bool:
	return cabinet.promote(minister, promotion)


func choose_coalition(index: int) -> bool:
	var ok: bool = cabinet.choose_coalition(index)
	_after_decision()
	return ok


func set_city_focus(city_id: int, focus: String) -> void:
	var c = city_by_id(city_id)
	if c != null:
		c.focus = focus
		refresh()


func set_city_automated(city_id: int, on: bool) -> void:
	var c = city_by_id(city_id)
	if c != null:
		c.automate = on


# ================================================================== settlers (real localities only)

func settle_targets() -> Array:
	## Localities in cities.json the player may found now: inside the 1949 armistice lines, not yet founded,
	## within 3 years before their real founding and before history founds them. Post-1967 localities
	## beyond the Green Line are never player-founded; they appear on their historical dates.
	var out := []
	var green: Dictionary = db.borders.get("1949_armistice", {})
	for e in db.cities:
		if city_by_key(str(e["id"])) != null: continue
		if str(e.get("kind", "")) in FOREIGN_KINDS or str(e.get("kind", "")).begins_with("bedouin") or str(e.get("kind", "")).begins_with("settlement"): continue
		if _entry_existing_at(e, 1): continue
		var k := SimHex.key(int(e["q"]), int(e["r"]))
		if not green.is_empty() and not green.has(k): continue
		if not econ.in_border(k): continue
		var ht := hist_turn_of(e)
		if state.turn < ht - 12: continue   # at most 3 years before the real founding
		if state.mode == "historical" and state.turn < ht: continue
		out.append({"id": e["id"], "name": e.get("name", e["id"]), "q": int(e["q"]), "r": int(e["r"]), "historical_turn": ht,
			"historical_date": SimDB.date_label(ht), "kind": e.get("kind", "")})
	return out


func snap_settle_target(p: Vector2i, radius := 4):
	var best = null; var bd := 999
	for t in settle_targets():
		var d := SimHex.distance(p, Vector2i(t["q"], t["r"]))
		if d <= radius and d < bd:
			bd = d; best = t
	return best


# ================================================================== queries for the UI

func get_date() -> Dictionary:
	return {"turn": state.turn, "label": date_label(), "year": year(), "quarter": SimDB.quarter_of(state.turn), "last_turn": last_playable_turn(),
		"era": state.era, "era_name": db.era_at(state.turn).get("name", ""), "age": state.age}


func get_national_summary() -> Dictionary:
	var n := _national.duplicate()
	n["gold_treasury"] = state.gold
	n["gold_net"] = state.counters.get("last_budget", {}).get("net", 0.0)
	n["inflation"] = state.inflation
	n["cohesion_treasury"] = state.cohesion
	n["standing"] = state.standing
	n["readiness"] = state.readiness
	n["war_weariness"] = state.war_weariness
	n["water"] = state.water.duplicate()
	n["residents"] = total_residents()
	n["rural"] = state.rural
	n["cities"] = active_cities().size()
	n["techs"] = state.techs.size()
	n["civics"] = state.civics.size()
	n["current_tech"] = state.current_tech
	n["current_civic"] = state.current_civic
	n["avg_trust"] = score.avg_trust()
	n["government"] = events.current_term()
	# public debt (fix-cabinet): the stock, this quarter's interest and repayment, the lenders' limit, open deficit rails
	n["debt"] = econ.debt()
	n["debt_service"] = float(state.counters.get("last_debt", {}).get("total", 0.0))
	n["borrow_cap"] = econ.debt_cap()
	n["deficit_streams"] = econ.open_deficit_rails()
	n["economy_health"] = econ.economy_health()
	n["fiscal"] = endgame.fiscal_indicator()   # v3: top-bar debt and inflation indicator
	n["food_balance"] = endgame.food_balance()   # v3: the national food figure explained
	return n


func get_city(city_id: int) -> Dictionary:
	var c = city_by_id(city_id)
	if c == null:
		return {}
	var d: Dictionary = c.to_dict()
	d["pop"] = c.pop()
	d["yields"] = c.y.duplicate()
	d["info"] = c.info.duplicate()
	d["turns_to_grow"] = econ.turns_to_grow(c)
	d["capital"] = c.key == state.capital
	d["district_cap"] = econ.district_cap(c)
	d["tiles"] = econ.city_tile_keys(c).map(func(k): return [SimHex.from_key(k).x, SimHex.from_key(k).y])
	d["ghost_residents"] = db.city_pop_at(db.city_by_id.get(c.key, {}), SimDB.year_f(state.turn))
	d["upkeep"] = econ.city_upkeep(c)   # v3 fix3-econ: the city's "Treasury: upkeep" line, buildings and mothballed ones
	d["mothballed"] = econ.mothballed(c).duplicate()
	if not c.queue.is_empty():
		var it: Dictionary = c.queue[0]
		var cost := item_cost(c, it["kind"], it["id"])
		d["producing"] = {"kind": it["kind"], "id": it["id"], "cost": cost, "progress": float(c.progress.get(str(it["kind"]) + ":" + str(it["id"]), 0.0)),
			"turns": int(ceil(maxf(0.0, cost - float(c.progress.get(str(it["kind"]) + ":" + str(it["id"]), 0.0))) / maxf(1.0, float(c.y.get("production", 1.0)))))}
	return d


func get_cities() -> Array:
	return active_cities().map(func(c): return {"id": c.id, "key": c.key, "name": c.name, "q": c.q, "r": c.r, "pop": c.pop(), "residents": c.residents,
		"capital": c.key == state.capital, "trust": c.trust, "producing": (c.queue[0]["id"] if not c.queue.is_empty() else ""), "kind": c.kind})


func get_tile(q: int, r: int) -> Dictionary:
	var k := SimHex.key(q, r)
	var t = db.tiles.get(k)
	if t == null:
		return {}
	var ts := econ.tstate(k)
	var owner = city_by_id(int(ts.get("o", 0)))
	return {"q": q, "r": r, "terrain": econ.terrain(k), "feature": econ.feature(k), "resource": econ.resource(k), "region": t.get("region", ""),
		"owner": owner.id if owner != null else 0, "owner_name": owner.name if owner != null else "", "improvement": ts.get("imp", ""),
		"district": ts.get("d", ""), "yields": econ.tile_yield(k, owner), "in_border": econ.in_border(k), "appeal": econ.appeal(k),
		"river": t.get("river", false), "units": state.units.filter(func(u): return u.q == q and u.r == r).map(func(u): return u.id)}


func get_techs() -> Array:
	return db.tech_list.map(func(t): return {"id": t["id"], "name": t["name"], "era": t["era"], "year": t.get("year"), "cost": tech_cost(t["id"]),
		"progress": float(state.tech_progress.get(t["id"], 0.0)), "done": state.techs.has(t["id"]), "available": tech_available(t["id"]) == "",
		"reason": tech_available(t["id"]), "earliest_completion": earliest_completion(t), "boosted": state.boosts.has("tech:" + t["id"]), "boost_text": t.get("eureka", {}).get("text", ""),
		"unlocks": t.get("unlocks", {}), "prereqs": t.get("prereqs", []), "source": t.get("source", []), "description": t.get("description", "")})


func get_civics() -> Array:
	return db.civic_list.map(func(c): return {"id": c["id"], "name": c["name"], "era": c["era"], "year": c.get("year"), "cost": civic_cost(c["id"]),
		"progress": float(state.civic_progress.get(c["id"], 0.0)), "done": state.civics.has(c["id"]) and not c.get("repeatable", false), "repeatable": c.get("repeatable", false), "available": civic_available(c["id"]) == "",
		"reason": civic_available(c["id"]), "rail": c.get("rail", false), "boosted": state.boosts.has("civic:" + c["id"]),
		"boost_text": c.get("inspiration", {}).get("text", ""), "unlocks": c.get("unlocks", {}), "prereqs": c.get("prereqs", []), "source": c.get("source", [])})


func get_policy_state() -> Dictionary:
	return {"slots": state.policies.duplicate(true), "available": available_policies(), "free_swap": state.free_swap,
		"swap_cost": policy_swap_cost(), "government": events.current_term()}


func get_units(owner := "player") -> Array:
	return state.units.filter(func(u): return owner == "" or u.owner == owner).map(func(u): return military.unit_view(u))


func unit_action(unit_id: int, action: String, args := {}) -> Dictionary:
	## Actions: move {q,r}, attack {q,r}, fortify, skip, sleep, wake, found_city {radius}, build {improvement}, disband.
	var r: Dictionary = military.unit_action(unit_id, action, args)
	_after_decision()
	return r


func combat_preview(unit_id: int, q: int, r: int) -> Dictionary:
	## {attacker, defender, delta, damage_dealt, damage_taken, ranged} plus (v2) exact odds: win_chance, kill_chance,
	## death_chance, damage ranges, expected_hp_dealt / expected_hp_lost and an outcome label. Read-only, no dice.
	var u = unit_by_id(unit_id)
	return {} if u == null else military.preview(u, Vector2i(q, r))


func reachable_path(unit_id: int, q: int, r: int) -> Array:
	var u = unit_by_id(unit_id)
	return [] if u == null else military.path_to(u, Vector2i(q, r))


func get_diplomacy() -> Array:
	## v3 adds relation_level, status_label, phase, active, top_causes, deals_ready, exposure (API.md "v3 (sim-diplomacy)").
	return diplo.decorate(events.get_diplomacy())


func get_diplomacy_screen() -> Dictionary:
	return diplo.get_screen()


func get_actor_diplomacy(actor: String) -> Dictionary:
	return diplo.get_actor(actor)


func get_deals(actor: String) -> Array:
	return diplo.deals_for(actor)


func get_relations() -> Array:
	## v3: actors in their era with relation, trend, itemised causes, leader, deals (ui-v3 request 7).
	return diplo.get_relations()


func preview_deal(a: String, b := "") -> Dictionary:
	## preview_deal(deal_id) or preview_deal(actor_id, deal_id).
	return diplo.deal_view(b if b != "" else a)


func propose_deal(a: String, b := "", variant := "") -> Dictionary:
	## propose_deal(deal_id) or propose_deal(actor_id, deal_id) -> {ok, accepted, reason, text, effects_text, deal}.
	## variant "counter" (v3 fix3-story A6): the deal on its sourced counter-terms (preview_deal(...).counter).
	var r: Dictionary = diplo.propose(b if b != "" else a, variant)
	r["accepted"] = r["ok"]
	r["text"] = ("Deal concluded: %s" % r["deal"].get("title", "")) if r["ok"] else str(r["reason"])
	r["effects_text"] = r["deal"].get("effects_text", [])
	return r


func choose_diplomacy(option) -> bool:
	## The envoy decision (type "diplomacy"): option index or id.
	var ok: bool = diplo.choose(option)
	_after_decision()
	return ok


func get_crises() -> Array:
	return state.crises.duplicate(true)


func get_timeline() -> Array:
	return state.timeline.duplicate(true)


func get_history() -> Array:
	## Per-turn samples {t, v: player tracks, g: ghost tracks, real_pop} for charts.
	return state.history


func get_buildable(city_id: int) -> Array:
	## Production panel rows for a city: {kind, id, name, cost, progress, turns, available, reason, gold_cost, cohesion_cost, sites?}.
	var c = city_by_id(city_id)
	return [] if c == null else buildable(c)


func get_district_sites(city_id: int, district_id: String) -> Array:
	## Valid tiles for a district with the adjacency bonus each would get: [{q, r, adjacency, appeal}].
	var c = city_by_id(city_id)
	return [] if c == null else econ.district_sites(c, district_id)


func get_district_lens(city_id: int, district_id: String) -> Array:
	## v2 placement lens: every tile of the city with valid/reason, the adjacency bonus there and its breakdown
	## [{q, r, valid, reason, adjacency, parts:[{src, id, count, per, amount}], appeal, terrain, feature}], best first.
	## Read-only.
	var c = city_by_id(city_id)
	return [] if c == null else econ.district_lens(c, district_id)


func get_worked_tiles(city_id: int) -> Array:
	## v2 citizen management: [{q, r, yields, worked, locked, workable, centre, district, improvement, score}]. Read-only.
	var c = city_by_id(city_id)
	return [] if c == null else econ.worked_tiles(c)


func set_tile_locked(city_id: int, q: int, r: int, locked: bool) -> bool:
	## Locks (or unlocks) a tile for the city's citizens: locked tiles are worked first, up to the population.
	## Yields are recomputed at once; locks are saved with the city. false if the tile cannot be worked.
	var c = city_by_id(city_id)
	if c == null:
		return false
	var k := SimHex.key(q, r)
	if not econ.city_tile_keys(c).has(k) or k == SimHex.key(c.q, c.r) or str(econ.tstate(k).get("d", "")) != "" or econ.terrain(k) == "mountains":
		return false
	if locked:
		if c.locked.has(k):
			return true
		if c.locked.size() >= c.pop():
			c.locked.pop_front()   # Civ VI: locking past the population frees the oldest lock
		c.locked.append(k)
	else:
		c.locked.erase(k)
	refresh()
	city_changed.emit(c.id)
	return true


func clear_citizen_locks(city_id: int) -> void:
	## Unlocks every tile of the city (citizen management).
	var c = city_by_id(city_id)
	if c != null and not c.locked.is_empty():
		c.locked = []
		refresh()
		city_changed.emit(c.id)


func front_preview(option_index: int) -> Dictionary:
	## v2 combat preview for the open war-turn decision: expected enemy formations destroyed (with the chance for
	## each), formations left, expected strikes on towns, expected units lost, the lesson effect and the costs.
	## Deterministic and side-effect free (the same numbers are in each option's "preview").
	var d := state.crisis_decision
	if d.is_empty() or d.get("done", false) or not d.get("war_turn", false):
		return {}
	var opts: Array = d.get("options", [])
	if option_index < 0 or option_index >= opts.size():
		return {}
	for cr in state.crises:
		if cr["id"] == d.get("crisis"):
			return military.front_preview(cr, opts[option_index])
	return {}


func get_buyable_tiles(city_id: int) -> Array:
	var c = city_by_id(city_id)
	return [] if c == null else econ.buyable_tiles(c)


func get_purchase_cost(city_id: int, kind: String, id: String, currency := "gold") -> int:
	var c = city_by_id(city_id)
	return -1 if c == null else purchase_cost(c, kind, id, currency)


func get_settle_targets() -> Array:
	return settle_targets()


func get_pending_events() -> Array:
	## Fired events still waiting for a choice: [{event, title, summary, date, source, choices:[{index,label,effects,note,historical,source}]}].
	var out := []
	for eid in state.pending_events:
		var ev = db.event_by_id.get(eid)
		if ev != null:
			out.append({"event": eid, "title": ev.get("title", ""), "title_he": ev.get("title_he", ""), "summary": ev.get("summary", ""),
				"date": ev.get("date", ""), "kind": ev.get("kind", ""), "source": ev.get("source", []), "choices": events.choice_view(ev)})
	return out


func get_event_log(last_n := 20) -> Array:
	return state.event_log.slice(maxi(0, state.event_log.size() - last_n))


func get_notifications() -> Array:
	return state.notifications.duplicate(true)


func get_score() -> Dictionary:
	return score.current()


func get_upcoming_events(turns := 8) -> Array:
	## The dated horizon strip (MECHANICS 29.6): titles of fixed events in the next N turns (never past the last turn).
	var out := []
	for t in range(state.turn + 1, mini(Sim.last_playable_turn(), state.turn + turns) + 1):
		for ev in db.events_by_turn.get(t, []):
			out.append({"turn": t, "date": ev.get("date"), "title": ev.get("title"), "kind": ev.get("kind"), "id": ev["id"]})
	return out


func get_foreign_places() -> Array:
	## Places in cities.json that are not player cities this turn (e.g. Palestinian cities), with their sourced populations.
	var out := []
	for e in db.cities:
		if city_by_key(str(e["id"])) != null and city_by_key(str(e["id"])).active: continue
		var st := db.city_status_at(e, state.turn)
		if st == "": continue
		out.append({"id": e["id"], "name": e.get("name"), "q": e["q"], "r": e["r"], "status": st, "kind": e.get("kind"),
			"population": db.city_pop_at(e, SimDB.year_f(state.turn)), "source": e.get("source", [])})
	return out
