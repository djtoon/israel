class_name SimMilitary
extends RefCounted
## Units, movement, zone of control, Civ VI combat (MECHANICS 16-18) and scripted crises.
## Wars have fixed historical outcomes (no conquest, cities are never captured); how well the player
## is prepared changes losses, damage, weariness, trust and lasting Readiness.

const COMBAT_BASE := 24.0
const COMBAT_EXTRA := 12.0
const COMBAT_SCALE := 0.04
const CIVILIAN := ["civilian"]
const AIR := ["air"]

var sim


func _init(s) -> void:
	sim = s


func S() -> GameState:
	return sim.state


func db() -> SimDB:
	return sim.db


func udata(u: SimUnit) -> Dictionary:
	return db().units.get(u.type, {})


# ------------------------------------------------------------------ war data helpers (v2 fixes)

func war_def(cr: Dictionary) -> Dictionary:
	var w = db().wars.get(str(cr.get("war_id", "")))
	return w if typeof(w) == TYPE_DICTIONARY else {}


func war_variant(cr: Dictionary) -> Dictionary:
	## The war's first "variants" entry whose fork answers match: the war follows the cabinet's answer (v2 fixes B3:
	## Lebanon 1982 limited to 40 km, 2006 without the Litani push...).
	for v in war_def(cr).get("variants", []):
		if typeof(v) == TYPE_DICTIONARY and sim.forks.choice_matches(v.get("if_choice", {})):
			return v
	return {}


func war_actor(event_id: String, actor: String) -> bool:
	## True if the event's war file fights this actor (a front, or "war_actors").
	var w = db().war_by_event.get(event_id)
	if typeof(w) != TYPE_DICTIONARY:
		return false
	if actor in w.get("war_actors", []):
		return true
	for fr in w.get("fronts", []):
		if str(fr.get("actor", "")) == actor:
			return true
	return false


func crisis_live_actors(cr: Dictionary) -> Array:
	## Actors still fighting in this crisis: for data wars, those with a front open this quarter (the 1982 Syrian
	## fronts close with the ceasefire of 11 June); otherwise every actor of the crisis.
	if not cr.has("data_fronts"):
		return cr.get("actors", [])
	var out := []
	for fr in cr["data_fronts"]:
		if S().turn >= int(fr["from"]) and S().turn <= int(fr["until"]) and not out.has(str(fr["actor"])):
			out.append(str(fr["actor"]))
	if S().turn == int(cr.get("start", -1)):
		for a in cr.get("war_actors", []):
			if not out.has(str(a)): out.append(str(a))
	return out


func crisis_kind(cr: Dictionary) -> String:
	return str(war_variant(cr).get("kind", cr.get("kind", "war")))


func is_order_turn(cr: Dictionary) -> bool:
	## Quarters with front orders: every quarter of the main fighting, then (data "continues") a lower cadence,
	## e.g. once a year for the First Intifada to 1993 (v2 fixes B1).
	var t := S().turn
	if t < int(cr.get("main_end", cr.get("end", t + 1))):
		return true
	var every := int(cr.get("every", 0))
	var lf := int(cr.get("later_from", 99999))
	return every > 0 and t >= lf and (t - lf) % every == 0


func in_later_stage(cr: Dictionary) -> bool:
	return cr.has("main_end") and S().turn >= int(cr["main_end"])


func is_military(u: SimUnit) -> bool:
	return str(udata(u).get("cls", "")) in Sim.MILITARY_CLASSES or str(udata(u).get("cls", "")) == "rockets"


func is_hostile(u: SimUnit) -> bool:
	return u.owner != "player"


# ------------------------------------------------------------------ spawning

func spawn_start_units() -> void:
	## Opening forces (gameplay setup, not a historical order of battle).
	var plan := [["infantry_brigade", "jerusalem"], ["infantry_brigade", "tel_aviv"], ["infantry_brigade", "haifa"],
		["infantry_brigade", "negba"], ["infantry_brigade", "kfar_giladi"], ["infantry_brigade", "degania_alef"],
		["artillery_battalion", "tel_aviv"], ["fighter_squadron", "tel_aviv"], ["patrol_boat", "haifa"],
		["builder", "tel_aviv"], ["builder", "haifa"], ["builder", "afula"], ["settler", "tel_aviv"]]
	for p in plan:
		var c = sim.city_by_key(p[1])
		if c == null:
			var cs: Array = sim.active_cities()
			cs.sort_custom(func(a, b): return a.pop() > b.pop())
			c = cs[0] if cs.size() > 0 else null
		if c != null:
			spawn_unit(p[0], "player", c.pos(), c.id)


func _occupied(p: Vector2i, military: bool, owner := "") -> bool:
	for u in S().units:
		if u.q == p.x and u.r == p.y:
			var m := is_military(u)
			if str(udata(u).get("cls", "")) in AIR:
				continue
			if m == military:
				return true
			if owner != "" and u.owner != owner and m:
				return true
	return false


func passable(u_cls: String, k: int) -> bool:
	var terr: String = sim.econ.terrain(k)
	if not db().tiles.has(k):
		return false
	if u_cls == "naval":
		return terr in ["coast", "ocean", "lake"]
	if u_cls in AIR:
		return true
	return not (terr in ["coast", "ocean", "lake", "mountains"])


func spawn_unit(type: String, owner: String, near: Vector2i, home_city := 0, crisis := "") -> SimUnit:
	var ud: Dictionary = db().units.get(type, {})
	if ud.is_empty():
		sim.log_error("unknown unit type " + type)
		return null
	var cls := str(ud.get("cls", ""))
	var mil := cls in Sim.MILITARY_CLASSES or cls == "rockets"
	var spot := Vector2i(-1, -1)
	for rad in range(0, 5):
		var ring := [near] if rad == 0 else SimHex.ring(near.x, near.y, rad)
		for p in ring:
			var k := SimHex.key(p.x, p.y)
			if passable(cls, k) and (cls in AIR or not _occupied(p, mil, owner)):
				if owner != "player" and sim.city_at(p) != null:
					continue
				spot = p; break
		if spot.x >= 0:
			break
	if spot.x < 0:
		return null
	var u := SimUnit.new()
	u.id = sim.new_id()
	u.type = type
	u.owner = owner
	u.q = spot.x; u.r = spot.y
	u.moves = float(ud.get("mp", 2))
	u.charges = int(ud.get("charges", 0))
	u.crisis = crisis
	if owner != "player":
		u.cs_override = _period_cs(ud)
	S().units.append(u)
	sim._units[u.id] = u
	sim.unit_created.emit(u.id)
	return u


func _period_cs(ud: Dictionary) -> int:
	var ec: Dictionary = ud.get("era_cs", {})
	var best := int(ud.get("cs", 40))
	var by := -1
	for y in ec:
		if int(y) <= sim.year() and int(y) > by:
			by = int(y); best = int(ec[y])
	return best


func remove_unit(u: SimUnit) -> void:
	S().units.erase(u)
	sim._units.erase(u.id)
	sim.unit_removed.emit(u.id)


func unit_view(u: SimUnit) -> Dictionary:
	var ud := udata(u)
	return {"id": u.id, "type": u.type, "name": ud.get("name", u.type), "cls": ud.get("cls", ""), "owner": u.owner, "q": u.q, "r": u.r,
		"hp": u.hp, "moves": u.moves, "max_moves": ud.get("mp", 2), "cs": cs_of(u), "rs": ud.get("rs", 0), "range": ud.get("range", 0),
		"charges": u.charges, "orders": u.orders, "level": u.level, "xp": u.xp, "crisis": u.crisis,
		"target": [u.target.x, u.target.y], "needs_orders": u.owner == "player" and u.orders == "" and u.moves > 0 and needs_orders(u)}


func needs_orders(u: SimUnit) -> bool:
	var cls := str(udata(u).get("cls", ""))
	if cls == "civilian":
		if u.type == "builder":
			return u.charges > 0
		return true
	if S().crises.is_empty():
		return false
	return u.fortify == 0 and cls in ["melee", "armor", "siege", "defense"]


# ------------------------------------------------------------------ movement

func move_cost(cls: String, k: int) -> float:
	if cls in AIR or cls == "naval":
		return 1.0
	var terr: String = sim.econ.terrain(k)
	var c := 1.0
	if terr in ["hills", "desert_hills", "marsh"] or sim.econ.feature(k) == "forest":
		c = 2.0
	return c


func in_enemy_zoc(p: Vector2i, owner: String) -> bool:
	for n in SimHex.neighbors(p.x, p.y):
		for u in S().units:
			if u.q == n.x and u.r == n.y and u.owner != owner and is_military(u) and not (str(udata(u).get("cls", "")) in AIR):
				return true
	return false


func path_to(u: SimUnit, goal: Vector2i, max_nodes := 3000) -> Array:
	## Weighted search (Dijkstra) over passable tiles; returns the tile path excluding the start.
	var cls := str(udata(u).get("cls", ""))
	var start := u.pos()
	if start == goal:
		return []
	var dist := {SimHex.key(start.x, start.y): 0.0}
	var prev := {}
	var open := [[0.0, start]]
	var found := false
	var n := 0
	while open.size() > 0 and n < max_nodes:
		n += 1
		var bi := 0
		for i in range(1, open.size()):
			if open[i][0] < open[bi][0]: bi = i
		var cur = open[bi]
		open.remove_at(bi)
		var p: Vector2i = cur[1]
		if p == goal:
			found = true
			break
		var nbs := SimHex.neighbors(p.x, p.y)
		for di in range(6):
			var nb: Vector2i = nbs[di]
			var k := SimHex.key(nb.x, nb.y)
			if not passable(cls, k) and nb != goal:
				continue
			if not (cls in AIR) and cls != "naval" and db().cliff(SimHex.key(p.x, p.y), di):
				continue   # cliffs block movement (Civ VI)
			var nd: float = cur[0] + move_cost(cls, k) + 0.001 * SimHex.distance(nb, goal)
			if nd < float(dist.get(k, 1e9)):
				dist[k] = nd
				prev[k] = p
				open.append([nd, nb])
	if not found:
		return []
	var path := []
	var p2 := goal
	while p2 != start:
		path.push_front(p2)
		p2 = prev[SimHex.key(p2.x, p2.y)]
	return path


func move_unit(u: SimUnit, goal: Vector2i) -> bool:
	## Moves as far as possible along the path this turn; keeps a goto order for later turns.
	if u.moves <= 0:
		u.target = goal
		u.orders = "goto"
		return false
	var cls := str(udata(u).get("cls", ""))
	if cls in AIR:
		return false
	var path := path_to(u, goal)
	if path.is_empty():
		return false
	var mil := is_military(u)
	var moved := false
	for p in path:
		var k := SimHex.key(p.x, p.y)
		var cost := move_cost(cls, k)
		if u.moves < cost and moved:
			break
		if _occupied(p, mil, u.owner) or (mil and _enemy_at(p, u.owner)):
			break
		var from := u.pos()
		u.q = p.x; u.r = p.y
		u.moves = maxf(0.0, u.moves - cost)
		u.fortify = 0
		moved = true
		sim.unit_moved.emit(u.id, from, p)
		if mil and in_enemy_zoc(p, u.owner) and str(udata(u).get("cls", "")) != "armor":
			u.moves = 0
		if u.moves <= 0:
			break
	if u.pos() != goal:
		u.target = goal
		u.orders = "goto"
	else:
		u.target = Vector2i(-1, -1)
		if u.orders == "goto":
			u.orders = ""
	return moved


func _enemy_at(p: Vector2i, owner: String):
	for u in S().units:
		if u.q == p.x and u.r == p.y and u.owner != owner and is_military(u):
			return u
	return null


# ------------------------------------------------------------------ unit actions (UI API)

func unit_action(unit_id: int, action: String, args := {}) -> Dictionary:
	var u = sim.unit_by_id(unit_id)
	if u == null or u.owner != "player":
		return {"ok": false, "reason": "no such unit"}
	match action:
		"move":
			var ok := move_unit(u, Vector2i(int(args.get("q", u.q)), int(args.get("r", u.r))))
			return {"ok": ok}
		"fortify":
			u.orders = "fortify"; u.moves = 0
			return {"ok": true}
		"skip":
			u.orders = "skip"
			return {"ok": true}
		"sleep":
			u.orders = "sleep"
			return {"ok": true}
		"wake":
			u.orders = ""
			return {"ok": true}
		"found_city":
			return _found(u, args)
		"build":
			return _build(u, str(args.get("improvement", "")))
		"attack":
			return attack(u, Vector2i(int(args.get("q", -1)), int(args.get("r", -1))))
		"disband":
			remove_unit(u)
			return {"ok": true}
	return {"ok": false, "reason": "unknown action"}


func _found(u: SimUnit, args: Dictionary) -> Dictionary:
	if u.type != "settler":
		return {"ok": false, "reason": "only Settlement Groups found towns"}
	var t = sim.snap_settle_target(u.pos(), int(args.get("radius", 3)))
	if t == null:
		var near: Array = sim.settle_targets()
		near.sort_custom(func(a, b): return SimHex.distance(u.pos(), Vector2i(a["q"], a["r"])) < SimHex.distance(u.pos(), Vector2i(b["q"], b["r"])))
		return {"ok": false, "reason": "no real locality open for founding within 3 tiles", "nearest": near.slice(0, 3)}
	var entry: Dictionary = db().city_by_id[t["id"]]
	var res := float(udata(u).get("residents", 1000)) + 500.0
	remove_unit(u)
	var c = sim.found_city(entry, "player", res)
	return {"ok": true, "city": c.id, "snapped_to": t["name"], "historical_date": t["historical_date"]}


func improvement_ok(imp: String, k: int, city) -> String:
	var d = db().improvements.get(imp)
	if d == null: return "unknown improvement"
	var why: String = sim._unlock_reason(d.get("unlock", {}))
	if why != "": return why
	var ts: Dictionary = sim.econ.tstate(k)
	if city == null or int(ts.get("o", 0)) != city.id: return "tile not owned by a city"
	if str(ts.get("d", "")) != "" or k == SimHex.key(city.q, city.r): return "district or city centre"
	if db().wonder_at.has(k): return "natural wonder"
	if sim.econ.is_military_control(k): return "held under military control"
	if str(ts.get("imp", "")) == imp: return "already built"
	var terr: String = sim.econ.terrain(k)
	var res: String = sim.econ.resource(k)
	if d.has("resources"):
		if res in d["resources"]:
			pass
		elif d.get("resources_or_terrain", false) and terr in d.get("terrain", []):
			pass
		else:
			return "needs " + ", ".join(d["resources"])
	elif d.has("terrain") and not (terr in d["terrain"]):
		return "wrong terrain"
	if not d.get("water_ok", false) and sim.econ.is_water(k) and not d.get("resources_or_terrain", false):
		return "land only"
	if res in SimEconomy.GROVE_RES and imp != "grove": return "use a Grove on this resource"
	if d.get("not_adjacent_same", false):
		var p := SimHex.from_key(k)
		for n in SimHex.neighbors(p.x, p.y):
			if str(sim.econ.tstate(SimHex.key(n.x, n.y)).get("imp", "")) == imp: return "not next to another " + str(d["name"])
	if d.has("min_rain") and float(db().tiles.get(k, {}).get("rain_mm", 0)) < float(d["min_rain"]): return "too dry"
	return ""


func _build(u: SimUnit, imp: String) -> Dictionary:
	if u.type != "builder" or u.charges <= 0:
		return {"ok": false, "reason": "needs a Public Works Crew with charges"}
	var k := SimHex.key(u.q, u.r)
	var city = sim.city_by_id(int(sim.econ.tstate(k).get("o", 0)))
	var why := improvement_ok(imp, k, city)
	if why != "":
		return {"ok": false, "reason": why}
	var d: Dictionary = db().improvements[imp]
	var ts: Dictionary = sim.econ.tstate(k)
	if d.has("adds_feature"):
		ts["f"] = d["adds_feature"]
		ts["imp"] = ""
	else:
		ts["imp"] = imp
	ts.erase("seed")
	u.charges -= 1
	u.moves = 0
	if u.charges <= 0:
		remove_unit(u)
	if city != null:
		sim.refresh_city(city)
	return {"ok": true}


# ------------------------------------------------------------------ combat (MECHANICS 17)

func cs_of(u: SimUnit) -> float:
	var ud := udata(u)
	var cs := float(u.cs_override) if u.cs_override > 0 else float(ud.get("cs", 10))
	return cs


func strength(u: SimUnit, defending: bool, ranged := false) -> float:
	var ud := udata(u)
	var s := float(ud.get("rs", 0)) if ranged else cs_of(u)
	if u.owner != "player" and ranged:
		s = float(ud.get("rs", 0))
	s -= round(10.0 - u.hp / 10.0)
	s += 5.0 * u.level
	var k := SimHex.key(u.q, u.r)
	if defending:
		var terr: String = sim.econ.terrain(k)
		if terr in ["hills", "desert_hills"]: s += 3.0
		if sim.econ.feature(k) == "forest": s += 3.0
		if terr == "marsh": s -= 2.0
		if u.fortify >= 2: s += 6.0
		elif u.fortify == 1: s += 3.0
		for n in SimHex.neighbors(u.q, u.r):
			for o in S().units:
				if o.q == n.x and o.r == n.y and o.owner == u.owner and is_military(o) and o != u:
					s += 2.0
	if u.owner == "player":
		s += sim.econ.mod_sum("unit_strength")
		s += (S().readiness - 50.0) / 10.0
		for cr in S().crises:
			if cr.get("response", "") == "mobilize" and cr.get("active", true):
				s += 2.0
				break
	elif sim.endgame != null:
		s += sim.endgame.ai_pressure()   # v3 difficulty: stronger (Hard) or weaker (Easy) enemy formations
	return s


func damage(delta: float) -> float:
	return (COMBAT_BASE + sim.rng.randf_range(0.0, COMBAT_EXTRA)) * exp(COMBAT_SCALE * delta)


func city_strength(c: SimCity) -> float:
	var best := 0.0
	var garrison := 0.0
	for u in S().units:
		if u.owner == "player" and is_military(u):
			best = maxf(best, cs_of(u))
			if u.q == c.q and u.r == c.r: garrison = cs_of(u)
	var s := maxf(best - 10.0, garrison)
	s += float(c.info.get("defense", 0.0))
	if sim.econ.terrain(SimHex.key(c.q, c.r)) in ["hills", "desert_hills"]: s += 3.0
	return maxf(15.0, s)


func preview(att: SimUnit, target: Vector2i) -> Dictionary:
	## Combat preview (expected damage both ways), like Civ VI's hover panel.
	var ranged := float(udata(att).get("rs", 0)) > 0 and str(udata(att).get("cls", "")) != "melee"
	var def = _enemy_at(target, att.owner)
	var a := strength(att, false, ranged)
	var dstr := 0.0
	if def != null:
		dstr = strength(def, true)
	else:
		var c = sim.city_at(target)
		if c == null: return {}
		dstr = city_strength(c)
	var delta := a - dstr
	# odds (v2): damage is uniform in [24, 36] x exp(0.04 x delta) each way, so the chances are exact and need no dice
	var mult := exp(COMBAT_SCALE * delta)
	var def_hp := 100.0
	var def_city := false
	if def != null:
		def_hp = def.hp
	else:
		var c2 = sim.city_at(target)
		def_hp = c2.hp + c2.outer_hp
		def_city = true
	var lo := COMBAT_BASE * mult
	var hi := (COMBAT_BASE + COMBAT_EXTRA) * mult
	var p_kill := 0.0 if def_city else kill_chance(def_hp, lo, hi)
	var back_lo := 0.0 if ranged else COMBAT_BASE / mult
	var back_hi := 0.0 if ranged else (COMBAT_BASE + COMBAT_EXTRA) / mult
	var p_die := 0.0 if ranged else kill_chance(att.hp, back_lo, back_hi)
	# win odds (UI request): the defender is destroyed, or survives having lost more HP than the attacker
	var win_odds := p_kill
	if not def_city and p_kill < 1.0:
		var steps := 40
		var acc := 0.0
		for i in range(steps):
			var dv := lo + (hi - lo) * (float(i) + 0.5) / float(steps)
			if dv >= def_hp:
				continue
			var p_t_less := 1.0 if ranged else clampf((minf(dv, att.hp) - back_lo) / maxf(0.001, back_hi - back_lo), 0.0, 1.0)
			acc += p_t_less / float(steps)
		win_odds = p_kill + acc
	var outcome := "decisive victory" if p_kill >= 0.95 and p_die < 0.05 else ("victory" if delta >= 10.0 else ("minor victory" if delta >= 2.0 else ("stalemate" if delta > -2.0 else ("minor defeat" if delta > -10.0 else "defeat"))))
	return {"attacker": a, "defender": dstr, "delta": delta, "damage_dealt": 30.0 * mult,
		"damage_taken": 0.0 if ranged else 30.0 / mult, "ranged": ranged,
		"damage_dealt_range": [lo, hi], "damage_taken_range": [back_lo, back_hi], "defender_hp": def_hp, "attacker_hp": att.hp,
		"win_chance": snappedf(p_kill * (1.0 - p_die), 0.001), "kill_chance": snappedf(p_kill, 0.001), "death_chance": snappedf(p_die, 0.001),
		"expected_hp_lost": snappedf(minf(att.hp, (back_lo + back_hi) / 2.0), 0.1), "expected_hp_dealt": snappedf(minf(def_hp, (lo + hi) / 2.0), 0.1),
		"outcome": outcome, "target_city": def_city, "win_odds": snappedf(clampf(win_odds, 0.0, 1.0), 0.001),
		"modifiers": strength_parts(att, false, ranged) + (strength_parts(def, true) if def != null else [{"side": "defender", "label": "City defences", "amount": dstr}])}


func strength_parts(u: SimUnit, defending: bool, ranged := false) -> Array:
	## The terms of strength() as [{side, label, amount}] for the combat preview (read-only).
	var side := "defender" if defending else "attacker"
	var ud := udata(u)
	var out := []
	var base := float(ud.get("rs", 0)) if ranged else cs_of(u)
	if u.owner != "player" and ranged: base = float(ud.get("rs", 0))
	out.append({"side": side, "label": "%s base strength" % str(ud.get("name", u.type)), "amount": base, "base": true})
	var hp_pen: float = -roundf(10.0 - u.hp / 10.0)
	if hp_pen != 0.0: out.append({"side": side, "label": "damaged (%d HP)" % int(u.hp), "amount": hp_pen})
	if u.level > 0: out.append({"side": side, "label": "promotions (level %d)" % u.level, "amount": 5.0 * u.level})
	if defending:
		var k := SimHex.key(u.q, u.r)
		var terr: String = sim.econ.terrain(k)
		if terr in ["hills", "desert_hills"]: out.append({"side": side, "label": "hills", "amount": 3.0})
		if sim.econ.feature(k) == "forest": out.append({"side": side, "label": "forest", "amount": 3.0})
		if terr == "marsh": out.append({"side": side, "label": "marsh", "amount": -2.0})
		if u.fortify >= 2: out.append({"side": side, "label": "fortified", "amount": 6.0})
		elif u.fortify == 1: out.append({"side": side, "label": "fortifying", "amount": 3.0})
		var sup := 0.0
		for n in SimHex.neighbors(u.q, u.r):
			for o in S().units:
				if o.q == n.x and o.r == n.y and o.owner == u.owner and is_military(o) and o != u:
					sup += 2.0
		if sup > 0.0: out.append({"side": side, "label": "support from adjacent units", "amount": sup})
	if u.owner == "player":
		var ms: float = sim.econ.mod_sum("unit_strength")
		if ms != 0.0: out.append({"side": side, "label": "policies and techs", "amount": ms})
		out.append({"side": side, "label": "Readiness %d" % int(S().readiness), "amount": (S().readiness - 50.0) / 10.0})
		for cr in S().crises:
			if cr.get("response", "") == "mobilize" and cr.get("active", true):
				out.append({"side": side, "label": "reserves mobilised", "amount": 2.0})
				break
	return out


static func kill_chance(hp: float, lo: float, hi: float) -> float:
	## Probability that a hit uniform in [lo, hi] removes hp.
	if hi <= lo:
		return 1.0 if lo >= hp else 0.0
	return clampf((hi - hp) / (hi - lo), 0.0, 1.0)


func _front_units(cr: Dictionary, fr: Dictionary) -> Array:
	var out := []
	for uid in _front_alive(fr):
		var u = sim.unit_by_id(int(uid))
		if u != null: out.append(u)
	return out


func _front_of(cr: Dictionary, fid: String) -> Dictionary:
	for fr in cr.get("data_fronts", []):
		if str(fr["id"]) == fid:
			return fr
	return {}


## The character of a front's battlefield (war data front "ground"): fronts differ by up to about 18 points of
## counter-attack strength, not 2-6 (v2 fixes B2). [modifier, label]
const GROUND := {
	"open_desert": [8.0, "open desert: air power and armour tell"],
	"coastal_plain": [4.0, "the coastal plain: roads and air cover"],
	"fortified": [-6.0, "fortified lines and minefields"],
	"mountain": [-6.0, "mountain ridges and narrow passes"],
	"valley_crossing": [-4.0, "river crossings under enemy fire"],
	"border_villages": [-7.0, "fortified border villages and bunkers"],
	"urban": [-8.0, "dense built-up areas full of civilians"],
	"camp": [-10.0, "a crowded refugee camp"],
	"tunnels": [-10.0, "tunnel networks under built-up areas"],
	"long_range": [-5.0, "targets far behind the lines"],
	"dispersed": [-3.0, "dispersed cells and launch sites"]}


func front_strength(cr: Dictionary, fr: Dictionary, base: float) -> Dictionary:
	## The counter-attack strength at one front (v2): the base (45 + 0.4 x Readiness for a front commitment,
	## 30 + 0.3 x Readiness for a full mobilisation) adjusted for the ground the enemy holds, the distance from
	## the front's base town, the enemy's own strength, and the reserves already mobilised.
	## -> {strength, parts: [{label, amount}]}. Read-only (no dice).
	var st := S()
	var parts := [{"label": "base (Readiness %d)" % int(st.readiness), "amount": snappedf(base, 0.1)}]
	var us := _front_units(cr, fr)
	var anchor := Vector2i(int(fr["pos"][0]), int(fr["pos"][1]))
	if not us.is_empty():
		var terr := 0.0
		var dist := 0.0
		var ecs := 0.0
		for u in us:
			var k := SimHex.key(u.q, u.r)
			var t: String = sim.econ.terrain(k)
			if t in ["hills", "desert_hills"]: terr -= 4.0
			elif t == "mountains": terr -= 6.0
			elif t == "marsh": terr -= 2.0
			elif t in ["desert", "plains"]: terr += 2.0   # open ground: air power and armour tell
			if sim.econ.feature(k) == "forest": terr -= 3.0
			dist += float(SimHex.distance(u.pos(), anchor))
			ecs += cs_of(u)
		var n := float(us.size())
		terr /= n; dist /= n; ecs /= n
		if absf(terr) >= 0.5:
			parts.append({"label": "ground the enemy holds (%s)" % ("hills and towns" if terr < 0.0 else "open ground"), "amount": snappedf(terr, 0.1)})
		var dp := -clampf((dist - 5.0) * 1.0, 0.0, 8.0)
		if dp < 0.0:
			parts.append({"label": "distance from %s (supply lines, %d hexes)" % [_anchor_name(fr), int(round(dist))], "amount": snappedf(dp, 0.1)})
		var ref := 40.0 + 6.0 * float(st.era)
		var ep := clampf((ref - ecs) / 3.0, -8.0, 6.0)
		if absf(ep) >= 0.5:
			parts.append({"label": "enemy strength (%s, about %d)" % [str(db().actors.get(str(fr.get("actor", "")), {}).get("name", fr.get("actor", ""))), int(ecs)], "amount": snappedf(ep, 0.1)})
	var gk := str(fr.get("ground", ""))
	if GROUND.has(gk):
		parts.append({"label": str(GROUND[gk][1]), "amount": float(GROUND[gk][0])})
	if str(cr.get("response", "")) == "mobilize":
		parts.append({"label": "reserves mobilised", "amount": 3.0})
	var prior := 0
	for nm in cr.get("front_log", []):
		if str(nm) == str(fr["name"]): prior += 1
	if prior > 0:
		parts.append({"label": "forces already engaged there", "amount": 2.0 * mini(prior, 2)})
	var s := 0.0
	for p in parts: s += float(p["amount"])
	return {"strength": maxf(10.0, s), "parts": parts}


func _anchor_name(fr: Dictionary) -> String:
	var c = sim.city_at(Vector2i(int(fr["pos"][0]), int(fr["pos"][1])))
	return c.name if c != null else str(fr.get("name", "the front"))


func towns_at_risk(cr: Dictionary, fr: Dictionary) -> Array:
	## Israeli towns a front threatens: within reach of its formations (rocket range, or 6 hexes for ground
	## forces), largest first: [{city, name, residents, distance}].
	var us := _front_units(cr, fr)
	var anchor := Vector2i(int(fr["pos"][0]), int(fr["pos"][1]))
	var out := []
	for c in sim.active_cities():
		var best := 999
		var reach := 6
		for u in us:
			var r := 6
			if udata(u).get("rocket", false): r = int(udata(u).get("range", 6)) + u.range_bonus
			var d := SimHex.distance(u.pos(), c.pos())
			if d <= r and d < best: best = d; reach = r
		if us.is_empty() and fr["unit_types"].has("missile_salvo") and SimHex.distance(anchor, c.pos()) <= 4:
			best = SimHex.distance(anchor, c.pos())
		if best < 999:
			out.append({"city": c.id, "name": c.name, "residents": c.residents, "distance": best})
	out.sort_custom(func(a, b): return float(a["residents"]) > float(b["residents"]))
	return out


func _strike_expectation(cr: Dictionary, fr: Dictionary, survive: Dictionary) -> float:
	## Expected strikes on towns this quarter from one front's formations, given each one's survival chance.
	var e := 0.0
	for u in _front_units(cr, fr):
		var ps := float(survive.get(u.id, 1.0))
		var near := 999
		for c in sim.active_cities():
			near = mini(near, SimHex.distance(u.pos(), c.pos()))
		var p := 0.0
		if udata(u).get("rocket", false):
			p = 1.0 if near <= int(udata(u).get("range", 6)) + u.range_bonus else 0.2
		elif float(udata(u).get("rs", 0)) > 0:
			p = 0.8 if near <= int(udata(u).get("range", 2)) + 1 else 0.25
		else:
			p = 0.7 if near <= 2 else (0.35 if near <= 5 else 0.1)
		e += p * ps
	if fr["unit_types"].has("missile_salvo"):
		e += 0.6 * float(fr.get("formations", 1))
	return e


func front_preview(cr: Dictionary, o: Dictionary) -> Dictionary:
	## Deterministic forecast for one war-turn option, computed from the state without random draws or side
	## effects. Differs by front: the counter-attack strength there (ground, distance, enemy strength), the chance
	## that each formation there is destroyed, the towns that front threatens and the strikes expected on them.
	## -> {front, strength, strength_parts, targets, kill_chances, expected_destroyed, enemy_formations, expected_left,
	##     protects: [{name, residents}], residents_at_risk, expected_town_strikes, strikes_by_front: {front: n},
	##     expected_units_lost, lesson_effect, production_lost, gold, cohesion}
	var st := S()
	var id := str(o.get("id", ""))
	var deterrence := crisis_kind(cr) == "deterrence" and not bool(war_variant(cr).get("strikes", false))
	var survive := {}
	var target_fronts := []
	var strength := 0.0
	var sparts := []
	var chances := []
	var exp_kill := 0.0
	var ntargets := 0
	var hp_removed := 0.0
	var suppressed := 0.0
	if id.begins_with("dfront:"):
		var fr := _front_of(cr, id.substr(7))
		if not fr.is_empty(): target_fronts = [fr]
	elif id == "full_mobilization" or id == "air_first":
		target_fronts = cr.get("data_fronts", [])
	if not deterrence:
		for fr in target_fronts:
			var lo := 35.0; var hi := 35.0
			if id != "air_first":
				var fs := front_strength(cr, fr, (45.0 + 0.4 * st.readiness) if id.begins_with("dfront:") else (30.0 + 0.3 * st.readiness))
				lo = 0.8 * float(fs["strength"]); hi = 1.2 * float(fs["strength"])
				if id.begins_with("dfront:"):
					strength = float(fs["strength"]); sparts = fs["parts"]
			for u in _front_units(cr, fr):
				var p := kill_chance(u.hp, lo, hi)
				var p_sup := 1.0 if lo >= SUPPRESS_HP else clampf((hi - SUPPRESS_HP) / maxf(0.001, hi - lo), 0.0, 1.0)
				survive[u.id] = (1.0 - p) * (1.0 - p_sup)
				hp_removed += minf(u.hp, (lo + hi) / 2.0)
				suppressed += maxf(p_sup - p, 0.0)
				chances.append(snappedf(p, 0.01))
				exp_kill += p
				ntargets += 1
	var all := st.units.filter(func(u): return u.owner != "player" and u.crisis == cr["id"])
	var strikes := 0.0
	var by_front := {}
	for fr in cr.get("data_fronts", []):
		var sf := 0.0 if deterrence else _strike_expectation(cr, fr, survive)
		if id == "shield:" + str(fr["id"]):
			sf *= 0.5
		elif id == "strike:" + str(fr["id"]) and str(fr.get("role", "")) == "strike_launchers":
			sf *= 0.3   # launchers and missile stocks hit: fewer salvos this quarter
		by_front[str(fr["name"])] = snappedf(sf, 0.1)
		strikes += sf
	if id == "economy_first" and not cr.get("offensive", false) and not deterrence:
		strikes += 1.0
	var protects := []
	var at_risk := 0.0
	var prot_fronts: Array = target_fronts if id.begins_with("dfront:") else []
	for fr in prot_fronts:
		for t in towns_at_risk(cr, fr).slice(0, 4):
			protects.append({"name": t["name"], "residents": int(t["residents"])})
			at_risk += float(t["residents"])
	if id.begins_with("shield:"):
		var fr2 := _front_of(cr, id.substr(7))
		if not fr2.is_empty():
			for t in towns_at_risk(cr, fr2).slice(0, 4):
				protects.append({"name": t["name"], "residents": int(t["residents"])})
				at_risk += float(t["residents"])
	var left := maxf(0.0, all.size() - exp_kill)
	# units lost: the formations still standing engage the reserves, weighted by their strength
	var losses := 0.0
	for u in all:
		losses += float(survive.get(u.id, 1.0)) * cs_of(u) / (45.0 + 6.0 * st.era) * 0.12
	losses *= clampf(1.4 - st.readiness / 100.0, 0.6, 1.3)
	if deterrence: losses = 0.0
	var lesson := 0.0
	if id.begins_with("dfront:") or id.begins_with("front:"): lesson = 0.6
	elif id == "full_mobilization": lesson = 1.2
	elif id == "economy_first": lesson = -0.5
	elif id == "mobilize": lesson = 1.0
	elif id == "air_first": lesson = 1.0
	elif id == "limited_aims": lesson = -1.5
	elif id.begins_with("shield:"): lesson = 0.5
	elif id.begins_with("strike:"): lesson = 0.8
	var cost: Dictionary = o.get("cost", {})
	var prod := float(sim.national().get("production", 0.0))
	return {"front": str(o.get("front", "")), "strength": snappedf(strength, 0.1), "strength_parts": sparts, "targets": ntargets, "kill_chances": chances,
		"expected_destroyed": snappedf(exp_kill, 0.01), "expected_suppressed": snappedf(suppressed, 0.01), "expected_hp_removed": snappedf(hp_removed, 0.1),
		"enemy_formations": all.size(), "expected_left": snappedf(left, 0.01),
		"protects": protects, "residents_at_risk": int(at_risk), "expected_town_strikes": snappedf(strikes, 0.1), "strikes_by_front": by_front,
		"expected_units_lost": snappedf(losses, 0.01), "lesson_effect": lesson,
		"production_lost": roundf(prod * float(cost.get("production_pct", 0)) / 100.0), "gold": float(cost.get("gold", 0)), "cohesion": float(cost.get("cohesion", 0)),
		"other_populations": other_populations(cr, _front_of(cr, id.substr(id.find(":") + 1)) if id.find(":") >= 0 else {})}


func other_populations(cr: Dictionary, fr := {}) -> Array:
	## Everyone else the fighting touches (CONTRACT: show every affected population): the front's own sourced
	## "civilians" line, then the non-Israeli groups of the war event's affected_populations (whole-war figures).
	## -> [{group, label, text}]
	var out := []
	if not fr.is_empty() and str(fr.get("civilians", "")) != "":
		out.append({"group": "front", "label": str(fr["civilians"]), "text": str(fr["civilians"])})
	var ev = db().event_by_id.get(str(cr.get("event", "")))
	if ev == null:
		return out
	for ap in ev.get("affected_populations", []):
		var g := str(ap.get("group", ""))
		if g == "" or g.find("israel") >= 0 or g.find("subset") >= 0:
			continue
		var bits := []
		for k in ["killed", "wounded", "displaced"]:
			var v = ap.get(k)
			if typeof(v) == TYPE_ARRAY and v.size() == 2:
				bits.append("%s %s" % [_range_txt(v), k])
		if bits.is_empty():
			bits.append(str(ap.get("killed", ap.get("displaced", "not quantified"))))
		var lab := group_label(g)
		out.append({"group": g, "label": lab, "text": "%s: %s" % [lab, ", ".join(bits)]})
	return out


static func group_label(g: String) -> String:
	var words := []
	for w in g.split("_", false):
		if w in ["and", "of", "in", "by", "the"]: words.append(w)
		elif w == "gazans": words.append("Gaza Strip residents")
		elif w == "us": words.append("US")
		else: words.append(w.capitalize())
	return " ".join(words)


static func _range_txt(v: Array) -> String:
	var a := int(v[0]); var b := int(v[1])
	return SimMilitary._thou(a) if a == b else "%s-%s" % [SimMilitary._thou(a), SimMilitary._thou(b)]


static func _thou(n: int) -> String:
	var s := str(absi(n))
	var out := ""
	while s.length() > 3:
		out = "," + s.substr(s.length() - 3) + out
		s = s.substr(0, s.length() - 3)
	return ("-" if n < 0 else "") + s + out


func _populations_line(cr: Dictionary, fr: Dictionary) -> String:
	var ps := other_populations(cr, fr)
	var out := ""
	var rest := []
	for p in ps:
		if str(p["group"]) == "front":
			out += " In the combat area: %s." % str(p["text"])
		elif rest.size() < 4:
			rest.append(str(p["text"]))
	if not rest.is_empty():
		out += " Also affected (whole-war figures): %s." % "; ".join(rest)
	return out


func attack(att: SimUnit, target: Vector2i) -> Dictionary:
	var ud := udata(att)
	var cls := str(ud.get("cls", ""))
	var ranged := float(ud.get("rs", 0)) > 0 and cls != "melee" and cls != "armor"
	var rng_ := int(ud.get("range", 1)) if ranged else 1
	if SimHex.distance(att.pos(), target) > rng_:
		return {"ok": false, "reason": "out of range"}
	if att.moves <= 0 or att.acted:
		return {"ok": false, "reason": "no moves left"}
	var def = _enemy_at(target, att.owner)
	var result := {"ok": true, "attacker": att.id, "target": [target.x, target.y], "ranged": ranged}
	if def == null:
		var c = sim.city_at(target)
		if c == null or att.owner == "player":
			return {"ok": false, "reason": "no target"}
		return attack_city(att, c)
	var a := strength(att, false, ranged)
	var d := strength(def, true)
	var dmg := damage(a - d)
	def.hp -= dmg
	result["damage_dealt"] = dmg
	if not ranged:
		var back := damage(d - a)
		att.hp -= back
		result["damage_taken"] = back
	att.acted = true
	att.moves = 0
	att.fortify = 0
	_xp(att, d / maxf(1.0, a) * (2.0 if def.hp <= 0 else 1.0) + (2.0 if not ranged else 1.0) + 1.0)
	_xp(def, a / maxf(1.0, d) + 1.0)
	if def.hp <= 0:
		result["killed"] = def.id
		_on_killed(def, att)
		if not ranged and att.hp > 0 and passable(cls, SimHex.key(target.x, target.y)):
			att.q = target.x; att.r = target.y
	if att.hp <= 0:
		result["attacker_killed"] = true
		_on_killed(att, def)
	_weariness_from_combat(att, def, result)
	sim.combat.emit(result)
	return result


func attack_city(att: SimUnit, c: SimCity) -> Dictionary:
	var ud := udata(att)
	var ranged := float(ud.get("rs", 0)) > 0
	var a := strength(att, false, ranged)
	var d := city_strength(c)
	var dmg := damage(a - d)
	if c.has_building("public_shelters") or c.has_building("fortifications"):
		dmg *= 0.5 if not ranged else 0.75
	for cr in S().crises:
		if cr.get("response", "") == "civil_defense" and cr.get("active", true):
			dmg *= 0.5
	if c.outer_hp > 0:
		var take := minf(c.outer_hp, dmg)
		c.outer_hp -= take; dmg -= take
	c.hp = maxf(0.0, c.hp - dmg)
	if not ranged:
		att.hp -= damage(d - a)
	att.acted = true; att.moves = 0
	_city_hit(c, dmg)
	var result := {"ok": true, "attacker": att.id, "city": c.id, "damage_dealt": dmg, "ranged": ranged}
	if att.hp <= 0:
		result["attacker_killed"] = true
		_on_killed(att, null)
	sim.combat.emit(result)
	return result


func _city_hit(c: SimCity, dmg: float) -> void:
	if dmg <= 0:
		return
	c.damaged = 1
	S().counters["cities_damaged"] = int(S().counters.get("cities_damaged", 0)) + 1
	var tr := 1.0 + dmg / 40.0
	c.trust = maxf(0.0, c.trust - tr * (0.7 if c.has_building("public_shelters") else 1.0))
	S().war_weariness += 15.0
	for cr in S().crises:
		if cr.get("active", true):
			cr["city_hits"] = int(cr.get("city_hits", 0)) + 1


func _xp(u: SimUnit, amt: float) -> void:
	u.xp += clampf(amt, 0.0, 8.0)
	while u.xp >= 15.0 * (u.level + 1) and u.level < 4:
		u.xp -= 15.0 * (u.level + 1)
		u.level += 1
		u.hp = minf(100.0, u.hp + 30.0)


func _on_killed(dead: SimUnit, killer) -> void:
	if dead.owner == "player":
		S().units_lost += 1
		S().war_weariness += 120.0
		for cr in S().crises:
			if cr.get("active", true): cr["player_lost"] = int(cr.get("player_lost", 0)) + 1
	else:
		S().unit_kills += 1
		for cr in S().crises:
			if cr.get("id") == dead.crisis: cr["hostile_destroyed"] = int(cr.get("hostile_destroyed", 0)) + 1
	remove_unit(dead)


func _weariness_from_combat(a: SimUnit, d: SimUnit, _r: Dictionary) -> void:
	if a.owner == "player" or d.owner == "player":
		S().war_weariness += 12.0


# ------------------------------------------------------------------ crises

func front_positions() -> Array:
	var out := []
	for u in S().units:
		if u.owner != "player" and is_military(u):
			out.append(u.pos())
	return out


func _actors_for(ev: Dictionary) -> Array:
	var dip = ev["effects"].get("diplo", {})
	var out := []
	if typeof(dip) == TYPE_DICTIONARY:
		for a in dip:
			if ev.get("kind") == "war" or str(dip[a]) == "war":
				if not (str(a) in ["usa", "un", "qatar", "uk", "france"]):
					out.append(str(a))
	return out


func start_crisis(ev: Dictionary) -> void:
	var actors := _actors_for(ev)
	var wd = db().war_by_event.get(str(ev["id"]))
	if wd != null:
		for fr in wd.get("fronts", []):
			if not (str(fr.get("actor", "")) in actors):
				actors.append(str(fr.get("actor", "")))
	if actors.is_empty():
		return
	for cr in S().crises.duplicate():
		if cr.get("active", true):
			var overlap: bool = false
			for a in actors:
				if a in cr["actors"]: overlap = true
			if not overlap:
				continue
			if wd != null and str(cr.get("war_id", "")) == str(wd["id"]):
				return
			if wd != null and str(cr.get("war_id", "")) in wd.get("alongside", []):
				continue   # e.g. Defensive Shield runs alongside the Second Intifada (its orders continue to 2004)
			if wd == null and not cr.has("war_id"):
				cr["end"] = maxi(int(cr["end"]), _end_turn_for(ev))
				return
			if wd == null:
				return   # an incident during a war with its own file: the war's fronts already cover it
			end_crisis(cr)   # a new war with its own file replaces the older crisis
	S().crises = S().crises.filter(func(c): return c.get("active", true))
	var cr := {"id": "crisis_" + str(ev["id"]), "event": ev["id"], "title": ev.get("title", ""), "actors": actors,
		"start": S().turn, "end": _end_turn_for(ev), "active": true, "response": "", "salvos": 0, "war": false,
		"operation": wd == null and str(ev.get("kind", "")) == "military_operation",
		"hostile_destroyed": 0, "player_lost": 0, "city_hits": 0, "intercepts": 0, "fronts": []}
	var fronts := []
	for pl in ev.get("places", []):
		var c = sim.city_by_key(str(pl))
		if c != null and c.active:
			fronts.append([c.q, c.r])
	cr["fronts"] = fronts
	if wd != null:
		cr["war_id"] = wd["id"]
		cr["title"] = str(wd.get("title", cr["title"]))
		cr["war"] = true
		cr["offensive"] = bool(wd.get("offensive", false))
		if wd.has("turns"):
			cr["end"] = S().turn + int(wd["turns"])
		var dfs := []
		for fr in wd.get("fronts", []):
			var an = fr.get("anchor")
			var pos := Vector2i(-1, -1)
			if typeof(an) == TYPE_ARRAY and an.size() == 2:
				pos = Vector2i(int(an[0]), int(an[1]))
			else:
				var c = sim.city_by_key(str(an))
				if c != null:
					pos = c.pos()
				else:
					var e = db().city_by_id.get(str(an))
					if e != null: pos = Vector2i(int(e["q"]), int(e["r"]))
			if pos.x < 0:
				continue
			dfs.append({"id": str(fr["id"]), "name": str(fr.get("name", fr["id"])), "actor": str(fr.get("actor", "")), "pos": [pos.x, pos.y],
				"region": fr.get("region", []), "formations": int(fr.get("formations", 2)), "unit_types": fr.get("unit_types", ["hostile_infantry", "hostile_armor"]),
				"from": SimDB.turn_of(fr.get("from"), -99999), "until": SimDB.turn_of(fr.get("until"), 99999), "spawn_inside": bool(fr.get("spawn_inside", false)),
				"label": str(fr.get("commit_label", "Commit the reserves to the %s front" % fr.get("name", ""))), "units": [],
				"phase": int(fr.get("phase", 0)), "ground": str(fr.get("ground", "")), "civilians": str(fr.get("civilians", "")),
				"role": str(fr.get("role", "")), "area": str(fr.get("area", ""))})
			fronts.append([pos.x, pos.y])
		cr["data_fronts"] = dfs
		cr["fronts"] = fronts
	if wd != null:
		cr["phases"] = wd.get("phases", []).map(func(ph): return str(ph.get("name", "")) if typeof(ph) == TYPE_DICTIONARY else str(ph))
		cr["kind"] = str(wd.get("kind", "war"))
		cr["war_actors"] = wd.get("war_actors", [])
		# a lower cadence after the main fighting (data "continues": {"from", "until", "every"})
		var cont = wd.get("continues")
		if typeof(cont) == TYPE_DICTIONARY:
			cr["main_end"] = int(cr["end"])
			cr["end"] = SimDB.turn_of(cont.get("until"), int(cr["end"])) + 1
			cr["every"] = maxi(1, int(cont.get("every", 4)))
			cr["later_from"] = maxi(int(cr["main_end"]), SimDB.turn_of(cont.get("from"), int(cr["main_end"])))
		if cr["kind"] == "operation":
			# a one-off operation with its own named options (data "response_options"); one quarter
			cr["operation"] = true
			cr["needs_response"] = true
			cr["numeric_deferred"] = true   # the event's standing and morale effects follow the option chosen
			cr["end"] = S().turn + 1
		# enemies are at war while their fronts are open; the event's ceasefire statuses land when the opening
		# quarter's orders are given (one-quarter wars) or when the war ends (v2 fixes B6)
		var after := {}
		var dip = ev["effects"].get("diplo", {})
		if typeof(dip) == TYPE_DICTIONARY:
			for a in dip:
				if str(dip[a]) != "war" and war_actor(str(ev["id"]), str(a)):
					after[str(a)] = str(dip[a])
		if not (cr["kind"] in ["deterrence", "operation", "uprising"]):
			for a in actors + Array(cr["war_actors"]):
				if a in ["usa", "un", "uk", "france", "qatar"]:
					continue
				var prev := str(S().diplomacy.get(a, {}).get("status", ""))
				if prev != "war":
					if not after.has(a) and prev != "": after[a] = prev
					sim.events.set_status(a, "war")
		cr["diplo_after"] = after
		var v := war_variant(cr)
		if not v.is_empty():
			cr["variant"] = true
			for fr in cr.get("data_fronts", []):
				if v.get("formations", {}).has(fr["id"]):
					fr["formations"] = int(v["formations"][fr["id"]])
			if v.has("turns"):
				cr["end"] = mini(int(cr["end"]), S().turn + int(v["turns"]))
				if cr.has("main_end"): cr["main_end"] = mini(int(cr["main_end"]), int(cr["end"]))
			if v.has("offensive"):
				cr["offensive"] = bool(v["offensive"])
			if v.has("title"):
				cr["title"] = str(v["title"])
			if str(v.get("note", "")) != "":
				sim.notify("history_course", str(v["note"]), {"crisis": cr["id"], "war": cr.get("war_id", "")})
	else:
		cr["needs_response"] = true
	S().crises.append(cr)
	if not cr.get("operation", false):
		_spawn_hostiles(cr)
	if wd != null and str(war_variant(cr).get("opening", "")) == "air_first":
		for u in S().units:
			if u.owner != "player" and u.crisis == cr["id"]:
				u.hp -= 35.0
	next_decision()
	sim.notify("crisis", "Crisis: %s" % cr["title"], {"crisis": cr["id"]})
	sim.crisis_started.emit(cr)


func apply_diplo_after(cr: Dictionary) -> void:
	## The war's ceasefire (or pre-war) statuses, once its fighting for the quarter is decided.
	var after: Dictionary = cr.get("diplo_after", {})
	if after.is_empty():
		return
	cr["diplo_after"] = {}
	for a in after:
		sim.events.set_status(str(a), str(after[a]))


func defers_numeric(event_id: String) -> bool:
	## An operation with named options applies its event's numeric effects only when an option is chosen.
	var w = db().war_by_event.get(event_id)
	return typeof(w) == TYPE_DICTIONARY and str(w.get("kind", "")) == "operation"


func decision_open() -> bool:
	return not S().crisis_decision.is_empty() and not S().crisis_decision.get("done", false)


func next_decision() -> void:
	## The crisis slot holds one decision at a time. First any new crisis's response menu, then every war's front
	## decision for this quarter (one per war, never merged, so a second war is not swallowed by the first), and
	## in a war's opening quarter one decision per phase of the fighting (e.g. 5, 7 and 9 June 1967).
	if decision_open():
		return
	for cr in S().crises:
		if cr.get("active", true) and cr.get("needs_response", false):
			cr["needs_response"] = false
			_crisis_decision(cr)
			return
	_war_turn_decision()


func auto_resolve() -> void:
	## End of turn: every open or queued crisis decision takes its last available option (hold / standing forces).
	for i in range(16):
		if not decision_open():
			next_decision()
		if not decision_open():
			return
		var opts: Array = S().crisis_decision.get("options", [])
		var pick := -1
		for j in range(opts.size() - 1, -1, -1):
			if opts[j].get("available", true):
				pick = j; break
		if pick < 0 or not choose_response(pick):
			S().crisis_decision["done"] = true


func phases_now(cr: Dictionary) -> int:
	## Decisions this quarter for a war: one per phase in its opening quarter (data "phases"), otherwise one.
	var ph: Array = phase_names(cr)
	return ph.size() if S().turn == int(cr["start"]) and ph.size() > 1 else 1


func phase_names(cr: Dictionary) -> Array:
	var v := war_variant(cr)
	if v.has("phases"):
		return v["phases"].map(func(ph): return str(ph.get("name", "")) if typeof(ph) == TYPE_DICTIONARY else str(ph))
	return cr.get("phases", [])


func _end_turn_for(ev: Dictionary) -> int:
	## Crises without a war file: one-off operations last their quarter; security crises at most 2 more quarters.
	var e := int(ev.get("_end_turn", -1))
	if str(ev.get("kind", "")) == "military_operation":
		return S().turn
	if e < S().turn:
		e = S().turn
	return mini(e, S().turn + 2)


func _spawn_hostiles(cr: Dictionary) -> void:
	if cr.has("data_fronts"):
		for fr in cr["data_fronts"]:
			var types: Array = fr["unit_types"]
			if types.has("missile_salvo"):
				cr["salvos"] = int(cr.get("salvos", 0)) + int(fr["formations"])
				continue
			_spawn_front(cr, fr, int(fr["formations"]))
			var fs: Dictionary = S().counters.get("front_spawns", {})
			var fkey := "%s:%s" % [cr.get("war_id", ""), fr["id"]]
			fs[fkey] = int(fs.get(fkey, 0)) + fr["units"].size()
			S().counters["front_spawns"] = fs
		return
	var y: int = sim.year()
	for a in cr["actors"]:
		var meta: Dictionary = db().actors.get(a, {})
		if meta.get("remote", false):
			cr["salvos"] = int(cr.get("salvos", 0)) + (2 if y < 2000 else 3)
			continue
		var kind := str(meta.get("kind", "state"))
		var types := []
		if kind == "state":
			types = ["hostile_infantry", "hostile_infantry"]
			if y >= 1956: types.append("hostile_armor")
			if y >= 1967 and a in ["egypt", "syria"]: types.append("hostile_armor")
			types.append("hostile_artillery")
			if y >= 1990: types = ["hostile_infantry", "hostile_rockets"]
		else:
			types = ["hostile_rockets", "hostile_rockets", "hostile_infantry"]
			if y >= 2006: types.append("hostile_rockets")
		var regions: Array = meta.get("region", [])
		if y < 1967 and meta.has("region_until_1967"):
			regions = regions + meta["region_until_1967"]
		var spots := _spawn_spots(regions, cr["fronts"])
		var i := 0
		for t in types:
			if spots.is_empty():
				break
			var p: Vector2i = spots[i % spots.size()]
			spawn_unit(t, a, p, 0, cr["id"])
			i += 1


func _spawn_front(cr: Dictionary, fr: Dictionary, n: int) -> int:
	var types: Array = fr["unit_types"]
	sim.econ._refresh_border()
	var anchor_inside: bool = sim.econ.border.has(SimHex.key(int(fr["pos"][0]), int(fr["pos"][1])))
	var inside: bool = cr.get("offensive", false) or fr.get("spawn_inside", false) or anchor_inside
	var spots := _spawn_spots(fr["region"], [fr["pos"]], inside)
	if spots.is_empty():
		spots = _spawn_spots(fr["region"], [fr["pos"]], inside, 60)
	var made := 0
	for i in range(n):
		if spots.is_empty():
			break
		var u := spawn_unit(str(types[i % types.size()]), str(fr["actor"]), spots[i % spots.size()], 0, cr["id"])
		if u != null:
			fr["units"].append(u.id)
			if udata(u).get("rocket", false):
				var dist := SimHex.distance(u.pos(), Vector2i(int(fr["pos"][0]), int(fr["pos"][1])))
				u.range_bonus = maxi(0, dist + 1 - int(udata(u).get("range", 6)))
			cr["spawned"] = int(cr.get("spawned", 0)) + 1
			made += 1
	return made


func _respawn_uprising(cr: Dictionary) -> void:
	## An uprising flares up again: in a quarter with orders after the first, every centre whose formations were
	## all contained gets new ones (half its strength, at least one), so later quarters keep their named fronts.
	if not (crisis_kind(cr) == "uprising" or in_later_stage(cr)) or S().turn == int(cr["start"]):
		return
	if int(cr.get("respawned_turn", -1)) == S().turn:
		return
	cr["respawned_turn"] = S().turn
	for fr in cr.get("data_fronts", []):
		if fr["unit_types"].has("missile_salvo") or S().turn < int(fr["from"]) or S().turn > int(fr["until"]):
			continue
		if _front_alive(fr).is_empty():
			_spawn_front(cr, fr, maxi(1, int(fr["formations"]) / 2))


func _spawn_spots(regions: Array, fronts: Array, allow_inside := false, radius := 14) -> Array:
	var border: Dictionary = sim.econ.border
	sim.econ._refresh_border()
	border = sim.econ.border
	var cands := []
	var targets := []
	for f in fronts:
		targets.append(Vector2i(int(f[0]), int(f[1])))
	if targets.is_empty():
		for c in sim.active_cities():
			targets.append(c.pos())
	for k in db().tiles:
		var t: Dictionary = db().tiles[k]
		if (border.has(k) and not allow_inside) or not passable("melee", k) or int(sim.econ.tstate(k).get("o", 0)) != 0:
			continue
		var reg := str(t.get("region", ""))
		var ok := false
		for r in regions:
			if reg.find(str(r)) >= 0: ok = true
		if not ok:
			continue
		var p := SimHex.from_key(k)
		var d := 999
		for tg in targets:
			d = mini(d, SimHex.distance(p, tg))
		if d <= radius:
			cands.append([d, p])
	cands.sort_custom(func(a, b): return a[0] < b[0])
	var out := []
	for c in cands.slice(0, 8):
		out.append(c[1])
	return out


# ------------------------------------------------------------------ war turns: where to commit, at what cost
# Every turn of a war after the first asks where the reserves go. History fixes how the war ends; the
# choice changes city damage, casualties, the economic cost of mobilisation and the lessons learned.

func _front_alive(fr: Dictionary) -> Array:
	return fr["units"].filter(func(id): return sim.unit_by_id(int(id)) != null)


func _front_names(cr: Dictionary, phase := 0) -> Array:
	## Live fronts of a crisis. phase > 0 (a war's opening quarter with phases): only that phase's fronts
	## (and fronts without a phase).
	if cr.has("data_fronts"):
		var df := []
		var dropped: Array = war_variant(cr).get("drop_fronts", [])
		for fr in cr["data_fronts"]:
			if dropped.has(str(fr["id"])):
				continue   # the cabinet's answer ruled this front out (war data "variants")
			var alive := _front_alive(fr)
			var remote: bool = fr["unit_types"].has("missile_salvo")
			if S().turn < int(fr["from"]) or S().turn > int(fr["until"]) or (alive.is_empty() and not remote):
				continue
			if phase > 0 and int(fr.get("phase", 0)) != 0 and int(fr.get("phase", 0)) != phase:
				continue
			df.append({"id": fr["id"], "name": fr["name"], "pos": Vector2i(int(fr["pos"][0]), int(fr["pos"][1])), "label": fr["label"], "n": alive.size(), "missile": remote})
		return df
	var out := []
	for f in cr.get("fronts", []):
		var c = sim.city_at(Vector2i(int(f[0]), int(f[1])))
		var nm: String = c.name if c != null else "the front"
		var dup := false
		for o in out:
			if o["name"] == nm: dup = true
		var pos := Vector2i(int(f[0]), int(f[1]))
		var n := _hostiles_near(cr, pos, 5).size()
		if not dup and n > 0:   # never offer a front with no enemy formations near it
			out.append({"name": nm, "pos": pos, "n": n})
	return out.slice(0, 3)


func _hostiles_near(cr: Dictionary, pos: Vector2i, radius: int) -> Array:
	return S().units.filter(func(u): return u.owner != "player" and u.crisis == cr["id"] and SimHex.distance(u.pos(), pos) <= radius)


func _war_turn_decision() -> void:
	## One decision per war per quarter (concurrent wars get their own menus, one after the other). Named fronts
	## are offered from a war's FIRST quarter, before its outcome rails; a war with "phases" asks once per phase in
	## its opening quarter. The opening responses (mobilisation, air strikes, limited aims) sit in the first one.
	var st := S()
	if decision_open():
		return
	var cr = null
	var phase := 1
	for c in st.crises:
		if not (c.get("active", true) and c.has("war_id") and st.turn < int(c["end"])):
			continue
		if str(c.get("kind", "")) == "operation" or not is_order_turn(c):
			continue
		var np := phases_now(c)
		if int(c.get("war_turn_done", -1)) != st.turn:
			cr = c; phase = 1; break
		if int(c.get("war_phase_done", 1)) < np:
			cr = c; phase = int(c.get("war_phase_done", 1)) + 1; break
	if cr == null:
		return
	var nph := phases_now(cr)
	cr["war_turn_done"] = st.turn
	cr["war_phase_done"] = phase
	var gs: float = sim.events.gold_scale()
	var v := war_variant(cr)
	var uprising := crisis_kind(cr) == "uprising"
	var deterrence := crisis_kind(cr) == "deterrence"
	var strikes_ok := bool(v.get("strikes", false))
	if phase == 1:
		_respawn_uprising(cr)
	var opts := []
	var first: bool = st.turn == int(cr["start"]) and phase == 1
	var offensive: bool = cr.get("offensive", false)
	var commit_pp := 15 if nph == 1 else 8
	var full_pp := 30 if nph == 1 else 15
	var shield_pp := 10 if nph == 1 else 5
	var full_gold := int(round(35.0 * gs / float(nph)))
	var hit := int(round(45.0 + 0.4 * st.readiness))
	for f in _front_names(cr, phase if nph > 1 else 0):
		if f.get("missile", false):
			# remote missile fronts (v2 fixes B2): "defend" a named area at home, or (offensive wars) strike the
			# launchers or the target abroad; the text names the place, never "missiles threaten <missiles>"
			var mf := _front_of(cr, str(f["id"]))
			var role := str(v.get("roles", {}).get(str(f["id"]), mf.get("role", "")))
			var area := str(mf.get("area", ""))
			if area == "": area = _anchor_name(mf)
			if role in ["strike_launchers", "strike_target"]:
				var sg := int(round(20.0 * gs / float(nph)))
				var sdesc := ("Air strikes on the launchers and missile stocks firing at %s: about two thirds fewer of their salvos this quarter and larger lessons learned; -%d%% production and gold for sorties." % [area, shield_pp]) if role == "strike_launchers" else 					("Air strikes on %s, deep inside Iran: they do not reduce this quarter's salvos at home, but give larger lessons learned; -%d%% production and gold for sorties." % [area, shield_pp])
				opts.append({"id": "strike:" + str(f["id"]), "crisis": cr["id"], "label": str(f.get("label", "Strike %s" % area)),
					"cost": {"production_pct": shield_pp, "gold": sg}, "available": st.gold >= sg, "default": false, "front": f["name"], "n": 0, "missile": true,
					"desc": sdesc + _populations_line(cr, mf)})
			else:
				var lab := str(f.get("label", ""))
				if lab == "" or lab.begins_with("Commit the reserves") or v.get("roles", {}).has(str(f["id"])):
					lab = "Concentrate interceptors and civil defence over %s" % area
				opts.append({"id": "shield:" + str(f["id"]), "crisis": cr["id"], "label": lab,
					"cost": {"production_pct": shield_pp}, "available": true, "default": false, "front": f["name"], "n": 0, "missile": true,
					"desc": "Missiles fall on %s. Interceptor batteries and shelter teams are concentrated there: more interceptions and half damage to towns within 4 tiles; -%d%% production this quarter (reservists on call).%s" % [area, shield_pp, _populations_line(cr, mf)]})
			continue
		var n := int(f.get("n", 0))
		var oid: String = ("dfront:" + str(f["id"])) if f.has("id") else ("front:%d,%d" % [f["pos"].x, f["pos"].y])
		var fhit := hit
		var risk := ""
		if f.has("id"):
			var frd := _front_of(cr, str(f["id"]))
			if not frd.is_empty():
				fhit = int(round(float(front_strength(cr, frd, 45.0 + 0.4 * st.readiness)["strength"])))
				var tw := towns_at_risk(cr, frd).slice(0, 3).map(func(t): return str(t["name"]))
				if not tw.is_empty(): risk = " Towns at risk: %s." % ", ".join(tw)
				risk += _populations_line(cr, frd)
		var desc := "%s: %d enemy formation%s. A counter-attack with strength %d (Readiness, ground, distance and enemy strength); -%d%% production everywhere this quarter (reservists away from work).%s" % [f["name"], n, "" if n == 1 else "s", fhit, commit_pp, risk]
		if deterrence and strikes_ok:
			desc = "%s: %d Syrian formation%s across the border. Your cabinet chose to strike: an attack with strength %d, larger lessons learned; -%d%% production this quarter (reservists away from work).%s" % [f["name"], n, "" if n == 1 else "s", fhit, commit_pp, risk]
		elif deterrence:
			desc = "%s: %d Syrian formation%s across the border. Deploying there shows Israel is ready to intervene: no fighting, larger lessons learned; -%d%% production this quarter (reservists away from work)." % [f["name"], n, "" if n == 1 else "s", commit_pp]
		elif uprising:
			desc = "%s: %d active centre%s of the uprising. Reinforcements there (strength %d) contain it sooner; -%d%% production this quarter (reservists away from work).%s" % [f["name"], n, "" if n == 1 else "s", fhit, commit_pp, risk]
		opts.append({"id": oid, "crisis": cr["id"], "label": str(f.get("label", "Commit the reserves to the %s front" % f["name"])), "cost": {"production_pct": commit_pp},
			"available": true, "default": false, "front": f["name"], "n": n, "desc": desc})
	if first:
		var trust: float = sim.score.avg_trust()
		var coh_cost := int(round(40.0 * clampf(1.4 - trust / 100.0, 0.6, 1.2) * (1.0 + 0.15 * st.era)))
		opts.append({"id": "mobilize", "label": "Call up reserve battalions for the territories" if uprising else "Mobilise the reserves for the whole campaign", "cost": {"cohesion": coh_cost}, "available": st.cohesion >= coh_cost and not bool(v.get("no_mobilize", false)),
			"default": false, "desc": "Reserve units at every front and +2 strength for all units in this %s. Costs Cohesion (cheaper when Civic Trust is high)." % ("uprising" if uprising else "war")})
		if offensive:
			var air_cost := int(round(45.0 * gs))
			opts.append({"id": "air_first", "label": "Open with air strikes on airfields and columns", "cost": {"gold": air_cost}, "available": st.gold >= air_cost,
				"default": false, "desc": "Every enemy formation starts the campaign weakened (about -35 HP). Gold for sorties and fuel."})
			opts.append({"id": "limited_aims", "label": "Limited aims: a short campaign", "cost": {}, "available": true, "default": false,
				"desc": "One quarter shorter and half the Standing losses, but the enemy is less worn down: smaller lessons learned."})
	opts.append({"id": "full_mobilization", "label": "Reinforce every sector at once" if uprising else "Full mobilisation on every front", "cost": {"gold": full_gold, "production_pct": full_pp},
		"available": st.gold >= full_gold, "default": false,
		"desc": "Strikes every front and shortens the danger to towns; -%d%% production this quarter and gold for fuel and call-ups." % full_pp})
	if deterrence:
		opts[opts.size() - 1]["label"] = "Put the whole northern command on alert"
		opts[opts.size() - 1]["desc"] = "Every sector at once: the largest lessons learned; -%d%% production this quarter and gold for the call-up." % full_pp
		opts.append({"id": "economy_first", "label": "Watch and wait; keep the economy running", "cost": {},
			"available": true, "default": false, "desc": "No cost. Israel stays out of sight: smaller lessons learned."})
	elif uprising:
		opts.append({"id": "economy_first", "label": "Leave it to the forces already deployed; keep the economy running", "cost": {},
			"available": true, "default": false, "desc": "No economic cost. The unrest spreads: more attacks on towns and roads and more casualties."})
	elif not offensive:
		opts.append({"id": "economy_first", "label": "Hold the lines with standing forces; keep the economy running", "cost": {},
			"available": true, "default": false, "desc": "No economic cost. The enemy keeps the initiative: more strikes on towns and more casualties."})
	else:
		opts.append({"id": "economy_first", "label": "Consolidate the positions taken; keep the economy running", "cost": {},
			"available": true, "default": false, "desc": "No economic cost. The remaining enemy formations regroup: smaller lessons learned and more casualties."})
	# Recommended: mobilise in a war's first decision when affordable, otherwise the most threatened front
	var rec := -1
	for i in range(opts.size()):
		if str(opts[i]["id"]) == "mobilize" and opts[i]["available"]: rec = i
	if rec < 0:
		var best_n := 0
		for i in range(opts.size()):
			if int(opts[i].get("n", 0)) > best_n:
				best_n = int(opts[i]["n"]); rec = i
	if rec < 0:
		for i in range(opts.size()):
			if opts[i].get("missile", false):
				rec = i; break
	if rec < 0:
		rec = opts.size() - 1
	opts[rec]["default"] = true
	var title := "%s: turn %d" % [cr["title"], st.turn - int(cr["start"]) + 1]
	if in_later_stage(cr):
		title = "%s: the uprising continues (%s)" % [cr["title"], SimDB.date_label(st.turn)] if uprising else "%s: continuing operations (%s)" % [cr["title"], SimDB.date_label(st.turn)]
	var pname := ""
	if nph > 1:
		pname = str(phase_names(cr)[phase - 1])
		title = "%s, phase %d of %d: %s" % [cr["title"], phase, nph, pname]
	for o in opts:
		o["preview"] = front_preview(cr, o)
	st.crisis_decision = {"crisis": cr["id"], "crises": [cr["id"]], "title": title, "options": opts, "done": false, "war_turn": true,
		"first_turn": first, "phase": phase, "phases": nph, "phase_name": pname, "war": str(cr.get("war_id", ""))}


func _apply_war_turn(cr: Dictionary, o: Dictionary) -> void:
	var st := S()
	var id := str(o["id"])
	var hit := []
	if crisis_kind(cr) == "deterrence" and not bool(war_variant(cr).get("strikes", false)):
		# a show of force, not a battle (Black September 1970: Israel did not attack)
		if id.begins_with("dfront:"):
			cr["committed"] = int(cr.get("committed", 0)) + 1
			for fr in cr.get("data_fronts", []):
				if str(fr["id"]) == id.substr(7):
					cr["front_log"] = cr.get("front_log", []) + [fr["name"]]
					spawn_unit("reserve_brigade", "player", Vector2i(int(fr["pos"][0]), int(fr["pos"][1])), 0, cr["id"])
		elif id == "full_mobilization":
			cr["committed"] = int(cr.get("committed", 0)) + 2
		else:
			cr["uncommitted"] = int(cr.get("uncommitted", 0)) + 1
		return
	if id.begins_with("shield:"):
		var sid := id.substr(7)
		for fr in cr.get("data_fronts", []):
			if str(fr["id"]) == sid:
				cr["shield"] = {"pos": fr["pos"], "turn": st.turn}
				cr["shielded"] = int(cr.get("shielded", 0)) + 1
				cr["front_log"] = cr.get("front_log", []) + [fr["name"]]
	elif id.begins_with("strike:"):
		# air strikes on a remote front: launchers hit means fewer salvos this quarter; a strike on the target abroad
		# (the nuclear sites) teaches more but does not stop this quarter's fire
		var kid := id.substr(7)
		for fr in cr.get("data_fronts", []):
			if str(fr["id"]) == kid:
				var role := str(war_variant(cr).get("roles", {}).get(kid, fr.get("role", "")))
				if role == "strike_launchers":
					cr["salvo_cut"] = {"turn": st.turn, "n": int(ceil(float(fr["formations"]) * 0.66))}
				cr["committed"] = int(cr.get("committed", 0)) + 1
				cr["front_log"] = cr.get("front_log", []) + [fr["name"]]
	elif id.begins_with("dfront:"):
		var fid := id.substr(7)
		for fr in cr.get("data_fronts", []):
			if str(fr["id"]) == fid:
				var pos2 := Vector2i(int(fr["pos"][0]), int(fr["pos"][1]))
				for uid in _front_alive(fr):
					var hu = sim.unit_by_id(int(uid))
					if hu != null: _counter_hit(cr, hu, float(front_strength(cr, fr, 45.0 + 0.4 * st.readiness)["strength"]))
				spawn_unit("reserve_brigade", "player", pos2, 0, cr["id"])
				cr["committed"] = int(cr.get("committed", 0)) + 1
				cr["front_log"] = cr.get("front_log", []) + [fr["name"]]
	elif id.begins_with("front:"):
		var xy := id.substr(6).split(",")
		var pos := Vector2i(int(xy[0]), int(xy[1]))
		hit = _hostiles_near(cr, pos, 5)
		spawn_unit("reserve_brigade", "player", pos, 0, cr["id"])
		for u in hit: _counter_hit(cr, u, 45.0 + 0.4 * st.readiness)
		cr["committed"] = int(cr.get("committed", 0)) + 1
	elif id == "full_mobilization":
		hit = st.units.filter(func(u): return u.owner != "player" and u.crisis == cr["id"])
		for frm in cr.get("data_fronts", []):
			var fsm := float(front_strength(cr, frm, 30.0 + 0.3 * st.readiness)["strength"])
			for hu2 in _front_units(cr, frm):
				hit.erase(hu2)
				_counter_hit(cr, hu2, fsm)
		for u in hit: _counter_hit(cr, u, 30.0 + 0.3 * st.readiness)
		cr["committed"] = int(cr.get("committed", 0)) + 2
	else:
		# the enemy keeps the initiative: an extra strike at the most exposed front town (not in an Israeli offensive)
		var fronts := _front_names(cr)
		if not fronts.is_empty() and not cr.get("offensive", false):
			var c = sim.city_at(fronts[0]["pos"])
			if c != null:
				_rocket_at(c, 40.0 + 2.0 * st.era, cr)
		cr["uncommitted"] = int(cr.get("uncommitted", 0)) + 1
	var cas := 0.0
	for c in st.crises:
		if c == cr: cas = float(cr.get("israeli_casualties", 0.0))
	cr["israeli_casualties"] = cas
	sim.refresh()


const SUPPRESS_HP := 35.0   # a counter-attack hitting a formation this hard pins it down: no strike this quarter


func _war_losses(cr: Dictionary, o: Dictionary) -> void:
	## v3 fix3-econ (M5): the front preview's "expected units lost" is realised. The expected losses of each quarter's
	## orders accumulate on the war; every whole unit is taken from the player's army (the unit nearest the war's fronts,
	## the weakest first; air-defence batteries last), with war weariness as for a unit destroyed in combat. The remainder
	## also wears the units near the fronts down (hit points).
	if S().counters.get("debug_no_losses", false):
		return
	var pv: Dictionary = o.get("preview", {})
	if pv.is_empty():
		pv = front_preview(cr, o)
	var exp_l := float(pv.get("expected_units_lost", 0.0))
	if exp_l <= 0.0:
		return
	var st := S()
	var acc := float(cr.get("loss_acc", 0.0)) + exp_l
	var fronts := []
	for fr in cr.get("data_fronts", []):
		if fr.has("pos"): fronts.append(Vector2i(int(fr["pos"][0]), int(fr["pos"][1])))
	if fronts.is_empty(): fronts = front_positions()
	var dist := func(u) -> int:
		var dm := 99
		for f in fronts: dm = mini(dm, SimHex.distance(u.pos(), f))
		return dm
	while acc >= 1.0:
		var cands: Array = st.units.filter(func(u): return u.owner == "player" and is_military(u))
		if cands.is_empty():
			acc = 0.0
			break
		# the reserves committed to this war take the losses first; with none at the front, the standing army does
		var cid := str(cr.get("id", ""))
		cands.sort_custom(func(a, b):
			var da: int = dist.call(a) + (40 if str(udata(a).get("cls", "")) == "defense" else 0) - (100 if str(a.crisis) == cid else 0)
			var db_: int = dist.call(b) + (40 if str(udata(b).get("cls", "")) == "defense" else 0) - (100 if str(b.crisis) == cid else 0)
			return da < db_ or (da == db_ and a.hp < b.hp))
		var lost = cands[0]
		acc -= 1.0
		st.units_lost += 1
		st.war_weariness += 60.0   # (a combat death costs 120; the reserves lost at the front are spread over the quarter)
		cr["player_lost"] = int(cr.get("player_lost", 0)) + 1
		cr["losses_taken"] = int(cr.get("losses_taken", 0)) + 1
		sim.notify("combat", "%s: a %s was lost in the fighting." % [str(cr.get("title", "")), str(udata(lost).get("name", lost.type))], {"crisis": str(cr.get("id", "")), "unit_lost": true})
		remove_unit(lost)
	cr["loss_acc"] = acc
	# the rest of this quarter's expected losses wears the units nearest the fronts down
	var near: Array = st.units.filter(func(u): return u.owner == "player" and is_military(u) and dist.call(u) <= 6)
	for u in near.slice(0, 3):
		u.hp = maxf(20.0, u.hp - 40.0 * minf(1.0, exp_l))


func _counter_hit(cr: Dictionary, u: SimUnit, dmg: float) -> void:
	var d: float = dmg * (0.8 + 0.4 * sim.rng.randf())
	u.hp -= d
	if d >= SUPPRESS_HP:
		var sup: Dictionary = cr.get("suppressed", {})
		sup[str(u.id)] = S().turn
		cr["suppressed"] = sup
	if u.hp <= 0.0:
		cr["hostile_destroyed"] = int(cr.get("hostile_destroyed", 0)) + 1
		S().unit_kills += 1
		remove_unit(u)


func _crisis_decision(cr: Dictionary) -> void:
	var st := S()
	var wdo := war_def(cr)
	if cr.get("operation", false) and not wdo.get("response_options", []).is_empty():
		# an operation with its own named options (war data "response_options"; v2 fixes B2: Opera, Wooden Leg)
		var gs: float = sim.events.gold_scale()
		var dropped: Array = war_variant(cr).get("drop_options", [])
		var dopts := []
		for ro in wdo["response_options"]:
			if dropped.has(str(ro.get("id", ""))):
				continue
			var g := int(round(float(ro.get("gold", 0)) * gs))
			var avail: bool = st.gold >= g and st.standing >= float(ro.get("min_standing", 0))
			dopts.append({"id": "opx:" + str(ro["id"]), "label": str(ro.get("label", "")), "desc": str(ro.get("desc", "")), "cost": {"gold": g},
				"available": avail, "default": bool(ro.get("default", false)) and avail, "historical": bool(ro.get("historical", false)),
				"standing_mult": float(ro.get("standing_mult", 1.0)), "morale_mult": float(ro.get("morale_mult", 1.0)),
				"lesson": float(ro.get("lesson", 0.0)), "readiness": float(ro.get("readiness", 0.0)), "cite": ro.get("cite", [])})
		if not dopts.any(func(o): return o["available"]):
			dopts[dopts.size() - 1]["available"] = true
		if not dopts.any(func(o): return o["default"]):
			for o in dopts:
				if o["available"]:
					o["default"] = true
					break
		st.crisis_decision = {"crisis": cr["id"], "title": cr["title"], "done": false, "operation": true, "options": dopts}
		return
	if cr.get("operation", false):
		# a one-off operation abroad (Litani, Osirak, Wooden Leg...): how it is carried out, not where to defend
		var op_cost := int(round(30.0 * sim.events.gold_scale()))
		st.crisis_decision = {"crisis": cr["id"], "title": cr["title"], "done": false, "operation": true, "options": [
			{"id": "op_full", "label": "Carry out the operation in full", "cost": {"gold": op_cost}, "available": st.gold >= op_cost, "default": true,
				"desc": "The full plan: better lessons for the forces (Readiness) but a sharper diplomatic cost abroad."},
			{"id": "op_limited", "label": "A limited operation with a narrow target list", "cost": {"gold": int(op_cost / 2)}, "available": st.gold >= op_cost / 2, "default": false,
				"desc": "Smaller footprint: smaller lessons, half the Standing losses."},
			{"id": "op_cover", "label": "Prepare diplomatic cover with allies first", "cost": {}, "available": st.standing >= 45.0, "default": false,
				"desc": "Requires Standing 45+. Allies are briefed in advance: half the Standing losses, Readiness -1 for the delay."},
			{"id": "standing_forces", "label": "Carry it out with the forces already on hand", "cost": {}, "available": true, "default": false,
				"desc": "No extra funding: the operation goes ahead as history records, but the forces learn less (Readiness lesson -1)."}]}
		return
	var trust: float = sim.score.avg_trust()
	var coh_cost := int(round(40.0 * clampf(1.4 - trust / 100.0, 0.6, 1.2) * (1.0 + 0.15 * st.era)))
	var gold_cost := int(round(50.0 * sim.events.gold_scale()))
	if cr.get("offensive", false):
		var air_cost := int(round(45.0 * sim.events.gold_scale()))
		st.crisis_decision = {"crisis": cr["id"], "title": cr["title"], "done": false, "options": [
			{"id": "air_first", "label": "Open with air strikes on the enemy's airfields and columns", "cost": {"gold": air_cost}, "available": st.gold >= air_cost,
				"desc": "Every enemy formation starts the campaign weakened (about -35 HP). Costs gold for sorties and fuel.", "default": false},
			{"id": "mobilize", "label": "Mobilize the reserves for a full campaign", "cost": {"cohesion": coh_cost}, "available": st.cohesion >= coh_cost,
				"desc": "Reserve brigades at the start lines and +2 strength for all units in this campaign. Cheaper when Civic Trust is high.", "default": true},
			{"id": "limited_aims", "label": "Limited aims: a short campaign", "cost": {}, "available": true,
				"desc": "One turn shorter and half the Standing losses, but the enemy is less worn down: smaller lessons learned.", "default": false},
			{"id": "standing_forces", "label": "Use the standing army only", "cost": {}, "available": true, "desc": "No extra cost; no extra strength.", "default": false}]}
		return
	var opts := [
		{"id": "mobilize", "label": "Mobilize the reserves", "cost": {"cohesion": coh_cost}, "available": st.cohesion >= coh_cost,
			"desc": "Calls up reserve brigades at the front and adds +2 strength to all units for this crisis. Cheaper when Civic Trust is high.", "default": true},
		{"id": "civil_defense", "label": "Civil defense and shelters", "cost": {"gold": gold_cost}, "available": st.gold >= gold_cost,
			"desc": "Halves damage to cities in this crisis and softens the trust shock.", "default": false},
		{"id": "backing", "label": "Seek international backing", "cost": {}, "available": st.standing >= 50.0,
			"desc": "Requires Standing 50+. Halves Standing losses in this crisis; Readiness -2 for restraint.", "default": false},
		{"id": "standing_forces", "label": "Rely on standing forces", "cost": {}, "available": true, "desc": "No extra cost; no extra protection.", "default": false},
	]
	st.crisis_decision = {"crisis": cr["id"], "title": cr["title"], "options": opts, "done": false}


func choose_response(i: int) -> bool:
	var st := S()
	var d := st.crisis_decision
	if d.is_empty() or d.get("done", false):
		return false
	var opts: Array = d["options"]
	if i < 0 or i >= opts.size() or not opts[i]["available"]:
		return false
	var o: Dictionary = opts[i]
	st.gold -= float(o["cost"].get("gold", 0))
	st.cohesion -= float(o["cost"].get("cohesion", 0))
	if float(o["cost"].get("cohesion", 0)) > 0:
		sim.stat_note("cohesion", -float(o["cost"]["cohesion"]), "%s: %s" % [d.get("title", ""), o.get("label", "")])
	if d.get("war_turn", false):
		_choose_war_option(d, o)
		d["done"] = true
		d["chosen"] = i
		# a one-quarter war: once its last order of the quarter is given, the ceasefire statuses apply
		for c in st.crises:
			if c["id"] == d.get("crisis") and int(c.get("end", 0)) <= st.turn + 1 and int(c.get("war_phase_done", 1)) >= phases_now(c):
				apply_diplo_after(c)
		var log_: Array = st.counters.get("war_choices", [])
		log_.append([st.turn, str(d.get("crisis", "")), str(o.get("id", ""))])
		st.counters["war_choices"] = log_.slice(maxi(0, log_.size() - 200))
		next_decision()
		_resume_if_held()
		sim.events.apply_territory_rails(false)
		return true
	var cr = null
	for c in st.crises:
		if c["id"] == d["crisis"]: cr = c
	if cr != null:
		cr["response"] = o["id"]
		if str(o["id"]).begins_with("opx:"):
			# a named operation option: its lessons, and the operation event's numeric effects scaled by the choice
			cr["op_lesson"] = float(o.get("lesson", 0.0))
			if float(o.get("readiness", 0.0)) != 0.0:
				st.readiness_bonus += float(o["readiness"])
				sim.stat_note("readiness", float(o["readiness"]), "%s: %s" % [cr["title"], o.get("label", "")])
			var oev = db().event_by_id.get(str(cr.get("event", "")))
			if oev != null and cr.get("numeric_deferred", false):
				cr["numeric_deferred"] = false
				var eff: Dictionary = sim.events._apply_blocks(oev).duplicate()
				if eff.has("intl_standing"): eff["intl_standing"] = float(eff["intl_standing"]) * float(o.get("standing_mult", 1.0))
				if eff.has("morale"): eff["morale"] = float(eff["morale"]) * float(o.get("morale_mult", 1.0))
				sim.events.apply_numeric(eff, oev)
		match o["id"]:
			"mobilize":
				var fronts: Array = cr["fronts"]
				var n := 2 + st.era / 3
				for j in range(n):
					var pos: Vector2i = Vector2i(int(fronts[j % fronts.size()][0]), int(fronts[j % fronts.size()][1])) if fronts.size() > 0 else sim.city_by_key(st.capital).pos()
					spawn_unit("reserve_brigade", "player", pos, 0, cr["id"])
			"air_first":
				for u in st.units:
					if u.owner != "player" and u.crisis == cr["id"]:
						u.hp -= 35.0
			"limited_aims":
				cr["end"] = maxi(st.turn, int(cr["end"]) - 1)
				cr["limited"] = true
				st.temp_effects.append({"type": "standing_shield", "until": int(cr["end"]), "src": cr["id"]})
			"op_limited":
				st.temp_effects.append({"type": "standing_shield", "until": st.turn + 1, "src": cr["id"]})
			"op_cover":
				st.readiness_bonus -= 1.0
				st.temp_effects.append({"type": "standing_shield", "until": st.turn + 1, "src": cr["id"]})
			"backing":
				st.readiness_bonus -= 2.0
				st.temp_effects.append({"type": "standing_shield", "until": int(cr["end"]), "src": cr["id"]})
				if st.diplomacy.has("usa"):
					sim.diplo.add_mod("usa", 5.0, "You sought US backing in a war (%s)" % str(cr.get("title", "")), "crisis", [], 12.0)   # v3
	d["done"] = true
	d["chosen"] = i
	next_decision()
	_resume_if_held()
	sim.events.apply_territory_rails(false)
	return true


func _resume_if_held() -> void:
	## The quarter's events waited for this decision; once no fork or crisis decision is open, history continues.
	if not decision_open() and S().pending_forks.is_empty() and sim.events.events_held():
		sim.resume_turn_events()


func _choose_war_option(d: Dictionary, o: Dictionary) -> void:
	var st := S()
	var ids: Array = d.get("crises", [d.get("crisis", "")])
	var crs := st.crises.filter(func(c): return c.get("active", true) and c["id"] in ids)
	for cr0 in crs:
		if not o.has("crisis") or str(o["crisis"]) == str(cr0["id"]):
			_war_losses(cr0, o)   # v3 fix3-econ (M5): the losses the front preview showed are taken
	var pp := float(o["cost"].get("production_pct", 0))
	if pp > 0:
		st.temp_effects.append({"type": "yield_pct", "yield": "production", "pct": -pp, "until": st.turn, "src": "war"})
	var oid := str(o["id"])
	for cr in crs:
		var first: bool = st.turn == int(cr["start"])
		if o.has("crisis"):
			if str(o["crisis"]) == str(cr["id"]):
				_apply_war_turn(cr, o)
				if first and str(cr.get("response", "")) == "": cr["response"] = "front"
			elif first and str(cr.get("response", "")) == "":
				cr["response"] = "standing_forces"
			continue
		match oid:
			"mobilize":
				if first:
					cr["response"] = "mobilize"
					for fr in cr.get("data_fronts", []):
						if not fr["unit_types"].has("missile_salvo"):
							spawn_unit("reserve_brigade", "player", Vector2i(int(fr["pos"][0]), int(fr["pos"][1])), 0, cr["id"])
					cr["committed"] = int(cr.get("committed", 0)) + 1
			"air_first":
				if first and cr.get("offensive", false):
					cr["response"] = "air_first"
					for u in st.units:
						if u.owner != "player" and u.crisis == cr["id"]:
							u.hp -= 35.0
				elif first:
					cr["response"] = "standing_forces"
			"limited_aims":
				if first and cr.get("offensive", false):
					cr["response"] = "limited_aims"
					cr["end"] = maxi(st.turn + 1, int(cr["end"]) - 1)
					cr["limited"] = true
					st.temp_effects.append({"type": "standing_shield", "until": int(cr["end"]), "src": cr["id"]})
				elif first:
					cr["response"] = "standing_forces"
			"full_mobilization":
				_apply_war_turn(cr, o)
				if first: cr["response"] = "full"
			_:
				_apply_war_turn(cr, o)
				if first: cr["response"] = "standing_forces"


func update_crises() -> void:
	for cr in S().crises:
		if not cr.get("active", true):
			continue
		if cr.has("war_id"):
			# the cabinet's later answer can end or shorten a war (data "variants": "end_now", "turns")
			var v := war_variant(cr)
			if not v.is_empty():
				if v.has("turns"):
					cr["end"] = mini(int(cr["end"]), int(cr["start"]) + int(v["turns"]))
					if cr.has("main_end"): cr["main_end"] = mini(int(cr["main_end"]), int(cr["end"]))
				if bool(v.get("end_now", false)) and int(cr["end"]) > S().turn:
					cr["end"] = S().turn
				if str(v.get("note", "")) != "" and not cr.get("variant_noted", false):
					cr["variant_noted"] = true
					if not cr.get("variant", false):
						sim.notify("history_course", str(v["note"]), {"crisis": cr["id"], "war": cr.get("war_id", "")})
		var still_war := false
		for a in cr["actors"]:
			if str(S().diplomacy.get(a, {}).get("status", "")) == "war":
				still_war = true
		if not cr.get("war", true) or cr.has("war_id"):
			still_war = false
		var over: bool = S().turn >= int(cr["end"]) if cr.has("war_id") else S().turn > int(cr["end"])
		if over and (not still_war or S().turn > int(cr["start"]) + 8):
			end_crisis(cr)
	S().crises = S().crises.filter(func(c): return c.get("active", true))
	if not S().crisis_decision.is_empty():
		var alive := false
		for c in S().crises:
			if c["id"] == S().crisis_decision.get("crisis"): alive = true
		if not alive:
			S().crisis_decision = {}
	next_decision()


func end_crisis(cr: Dictionary) -> void:
	cr["active"] = false
	apply_diplo_after(cr)
	for u in S().units.duplicate():
		if u.crisis == cr["id"]:
			remove_unit(u)
	var spawned := maxf(1.0, float(cr.get("spawned", 0)) + float(cr.get("salvos", 0)) * 0.5)
	var perf := 3.0 * clampf(float(cr.get("hostile_destroyed", 0)) / spawned, 0.0, 1.0) + minf(2.0, float(cr.get("intercepts", 0)) * 0.25) \
		- minf(3.0, float(cr.get("player_lost", 0))) - minf(3.0, 0.15 * float(cr.get("city_hits", 0))) \
		+ 0.6 * float(cr.get("committed", 0)) - 0.5 * float(cr.get("uncommitted", 0))
	perf += 0.5 * float(cr.get("shielded", 0))
	perf += float(cr.get("op_lesson", 0.0))
	perf += {"mobilize": 1.0, "air_first": 1.0, "full": 0.8, "front": 0.5, "civil_defense": 0.5, "backing": -0.5, "limited_aims": -0.5,
		"standing_forces": -1.0, "": -1.0, "op_full": 1.5, "op_limited": 0.5, "op_cover": -0.5}.get(str(cr.get("response", "")), 0.0)
	perf += (S().readiness - 60.0) / 25.0 - 1.0
	var wd = db().wars.get(str(cr.get("war_id", "")))
	if wd != null:
		perf += float(wd.get("lessons", {}).get("base", 0))
	if cr.get("limited", false):
		perf -= 1.0
	var lesson: float = roundf(clampf(perf, -5.0, 5.0))
	if lesson == 0.0:
		lesson = 1.0 if perf >= 0.0 else -1.0   # every campaign teaches something (API: the lesson is never 0)
	S().readiness_bonus += lesson
	var parts := []
	var resp_names := {"mobilize": "reserves mobilised", "air_first": "opened with air strikes", "full": "full mobilisation", "front": "reserves committed to a front",
		"civil_defense": "civil defence", "backing": "international backing", "limited_aims": "limited aims", "standing_forces": "standing forces only",
		"op_full": "operation carried out in full", "op_limited": "limited operation", "op_cover": "diplomatic cover first"}
	if resp_names.has(str(cr.get("response", ""))): parts.append(str(resp_names[str(cr["response"])]))
	if int(cr.get("hostile_destroyed", 0)) > 0: parts.append("%d enemy formations destroyed" % int(cr["hostile_destroyed"]))
	if int(cr.get("player_lost", 0)) > 0: parts.append("%d units lost" % int(cr["player_lost"]))
	if int(cr.get("city_hits", 0)) > 0: parts.append("%d strikes on towns" % int(cr["city_hits"]))
	if int(cr.get("intercepts", 0)) > 0: parts.append("%d interceptions" % int(cr["intercepts"]))
	if int(cr.get("committed", 0)) > 0: parts.append("%d front commitments" % int(cr["committed"]))
	if int(cr.get("shielded", 0)) > 0: parts.append("%d quarters of concentrated air defence" % int(cr["shielded"]))
	if int(cr.get("uncommitted", 0)) > 0: parts.append("%d quarters holding back" % int(cr["uncommitted"]))
	var why := "lessons of %s: %s" % [cr["title"], ", ".join(parts) if not parts.is_empty() else "no engagement"]
	sim.stat_note("readiness", lesson, why, 0.0)
	var standing_d := 0.0
	if cr.get("response", "") == "backing":
		standing_d = 1.0
	if standing_d != 0.0:
		sim._change_standing(standing_d, "US backing in " + str(cr["title"]))
	var rep := {"id": cr["id"], "title": cr["title"], "start": cr["start"], "end": S().turn, "response": cr.get("response", ""),
		"hostile_destroyed": cr.get("hostile_destroyed", 0), "player_lost": cr.get("player_lost", 0), "city_hits": cr.get("city_hits", 0),
		"intercepts": cr.get("intercepts", 0), "readiness_change": lesson}
	S().crisis_log.append(rep)
	if int(cr.get("city_hits", 0)) == 0 and int(cr.get("player_lost", 0)) == 0:
		sim.add_moment("%s: no city damaged and no unit lost" % cr["title"], 3, "crisis")
	sim.notify("crisis_end", "Crisis over: %s. Lessons learned: Readiness %+d." % [cr["title"], int(lesson)], {"report": rep})
	sim.crisis_ended.emit(rep)


# ------------------------------------------------------------------ per-turn processing

func process_turn() -> void:
	var st := S()
	# hostile actions
	for cr in st.crises:
		if not cr.get("active", true):
			continue
		var cut := 0
		if int(cr.get("salvo_cut", {}).get("turn", -1)) == st.turn:
			cut = int(cr["salvo_cut"].get("n", 0))
		for i in range(maxi(0, int(cr.get("salvos", 0)) - cut)):
			_salvo(cr)
	for u in st.units.duplicate():
		if u.owner != "player" and st.units.has(u):
			_hostile_act(u)
	# heal and reset
	for u in st.units:
		if not u.acted and u.moves >= float(udata(u).get("mp", 2)):
			var heal := 15.0 if u.owner == "player" else 10.0
			if sim.city_at(u.pos()) != null: heal = 20.0
			u.hp = minf(100.0, u.hp + heal)
		u.moves = float(udata(u).get("mp", 2))
		u.acted = false
		if u.orders == "fortify":
			u.fortify = mini(2, u.fortify + 1)
		if u.orders == "skip":
			u.orders = ""
	# goto orders continue
	for u in st.units:
		if u.owner == "player" and u.orders == "goto" and u.target.x >= 0:
			move_unit(u, u.target)
	# displaced residents return
	for d in st.displaced.duplicate():
		if st.turn >= int(d["until"]):
			var c = sim.city_by_id(int(d["city"]))
			if c != null and c.active:
				c.residents += float(d["n"])
				c.displaced = maxf(0.0, c.displaced - float(d["n"]))
			st.displaced.erase(d)
	# readiness (lasting national state)
	var strength_sum := 0.0
	for u in st.units:
		if u.owner == "player" and is_military(u):
			strength_sum += cs_of(u) / (45.0 + 6.0 * st.era) * (u.hp / 100.0)
	# capacity (forces, defence buildings, projects, policies) has diminishing returns against a requirement
	# that rises each era as adversaries' capabilities grow; ongoing crises stretch reserves and stocks.
	var cap: float = 10.0 + 3.0 * strength_sum + sim.econ.mod_sum("readiness") + float(st.counters.get("dispersal_readiness", 0.0))
	st.counters["dispersal_readiness"] = float(st.counters.get("dispersal_readiness", 0.0)) * 0.98
	for c in sim.active_cities():
		for b in c.buildings:
			cap += float(db().buildings.get(b, {}).get("readiness", 0))
	for pid in st.projects:
		for e in db().projects.get(pid, {}).get("effects", []):
			if e.get("type") == "readiness": cap += float(e.get("amount", 0))
	var need := readiness_requirement()
	var strain := 0.0
	for cr in st.crises:
		if cr.get("active", true):
			# a low-intensity stage (First Intifada after 1988, Second after 2001) strains less than open war
			strain += 3.0 if in_later_stage(cr) else minf(14.0, 4.0 + 1.0 * float(st.turn - int(cr["start"])))
	var base := 100.0 * (1.0 - exp(-maxf(0.0, cap) / need))
	var prev: Dictionary = st.counters.get("readiness_parts", {})
	# v3 final round (fix4-econ, item 2): the last points of readiness are the dearest, and readiness decays while
	# its upkeep goes unpaid (a treasury below zero beyond history's own overdraft); SimEconomy.readiness_upkeep()
	var rf: Dictionary = SimEconomy.fiscal_data().get("readiness", {})
	var raw: float = base + st.readiness_bonus - strain + sim.stream_sum("readiness")
	var top_from := float(rf.get("top_from", 80.0))
	var top := 0.0
	if raw > top_from:
		var held := top_from + float(rf.get("top_scale", 20.0)) * (1.0 - exp(-(raw - top_from) / float(rf.get("top_scale", 20.0))))
		top = raw - held
		raw = held
	var unpaid := float(st.counters.get("readiness_unpaid", 0.0))
	var ghost_neg: bool = sim.score != null and float(sim.score.ghost_at(st.turn).get("gold", 1.0)) < 0.0
	if st.mode != "historical" and st.gold < 0.0 and int(st.counters.get("neg_turns", 0)) >= 2 and not ghost_neg:
		unpaid = minf(float(rf.get("unpaid_max", 20.0)), unpaid + float(rf.get("unpaid_per_quarter", 2.0)))
	else:
		unpaid = maxf(0.0, unpaid - float(rf.get("unpaid_recover", 4.0)))
	st.counters["readiness_unpaid"] = unpaid
	st.readiness = clampf(raw - unpaid, 0.0, 100.0)
	if not prev.is_empty():
		sim._drift("readiness", "army size, modernisation and defence spending", base - float(prev.get("base", base)))
		sim._drift("readiness", "strain of ongoing crises", -(strain - float(prev.get("strain", strain))))
		sim._drift("readiness", "lasting terms of your choices", sim.stream_sum("readiness") - float(prev.get("terms", sim.stream_sum("readiness"))))
		sim._drift("readiness", "past lessons fading", st.readiness_bonus - float(prev.get("lessons", st.readiness_bonus)))
		sim._drift("readiness", "the last points are the dearest (above 80)", -(top - float(prev.get("top", top))))   # v3 final round (fix4-econ)
		sim._drift("readiness", "training and stocks unpaid (treasury below zero)", -(unpaid - float(prev.get("unpaid", unpaid))))
	st.counters["readiness_parts"] = {"capacity": cap, "requirement": need, "base": base, "lessons": st.readiness_bonus, "strain": strain, "terms": sim.stream_sum("readiness"),
		"top": top, "unpaid": unpaid, "upkeep": sim.econ.readiness_upkeep()}


func readiness_requirement() -> float:
	## Capacity needed for about 63% readiness; grows with each era (rockets, tunnels, drones, missiles), and from 2005
	## by 3 a year (v3 fix3-econ, M5: precision missiles, drones and tunnels kept raising the bar, so readiness is not
	## pinned at 100 late in the game and defence spending still matters).
	return 30.0 + 7.0 * float(S().era) + 3.0 * maxf(0.0, SimDB.year_f(S().turn) - 2005.0)


func _salvo(cr: Dictionary) -> void:
	var cs: Array = sim.active_cities()
	if cs.is_empty():
		return
	cs.sort_custom(func(a, b): return a.pop() > b.pop())
	var c: SimCity = cs[sim.rng.randi_range(0, mini(5, cs.size() - 1))]
	_rocket_at(c, 55.0, cr)


func _rocket_at(c: SimCity, rs: float, cr: Dictionary) -> void:
	var p_none := 1.0
	var shielded := false
	for k in S().crises:
		var sh: Dictionary = k.get("shield", {})
		if k.get("active", true) and int(sh.get("turn", -1)) == S().turn and SimHex.distance(c.pos(), Vector2i(int(sh["pos"][0]), int(sh["pos"][1]))) <= 4:
			shielded = true
	if shielded:
		p_none *= 0.5
	for u in S().units:
		if u.owner == "player":
			var ud := udata(u)
			if float(ud.get("intercept", 0)) > 0 and SimHex.distance(u.pos(), c.pos()) <= int(ud.get("intercept_radius", 4)):
				p_none *= 1.0 - float(ud["intercept"])
	if sim.rng.randf() > p_none:
		cr["intercepts"] = int(cr.get("intercepts", 0)) + 1
		return
	var d := 20.0 + float(c.info.get("defense", 0.0))
	var dmg := damage(rs - d)
	if c.has_building("public_shelters"): dmg *= 0.5
	if cr.get("response", "") == "civil_defense": dmg *= 0.5
	if shielded: dmg *= 0.5
	c.hp = maxf(0.0, c.hp - dmg)
	if dmg > 0.0:
		S().counters["cities_rocketed"] = int(S().counters.get("cities_rocketed", 0)) + 1
	_city_hit(c, dmg)


func _hostile_act(u: SimUnit) -> void:
	for cr0 in S().crises:
		if cr0["id"] == u.crisis and crisis_kind(cr0) == "deterrence":
			return   # forces across the border that never engaged Israel
		if cr0["id"] == u.crisis and int(cr0.get("suppressed", {}).get(str(u.id), -1)) == S().turn:
			return   # pinned down by this quarter's counter-attack
		if cr0["id"] == u.crisis and cr0.has("main_end") and not is_order_turn(cr0):
			return   # a quiet quarter between the yearly flare-ups of a long uprising
	var ud := udata(u)
	var cls := str(ud.get("cls", ""))
	if ud.get("rocket", false):
		var best = null; var bd := 99
		for c in sim.active_cities():
			var d := SimHex.distance(u.pos(), c.pos())
			if d <= int(ud.get("range", 6)) + u.range_bonus and d < bd:
				bd = d; best = c
		if best != null:
			var cr := {}
			for c2 in S().crises:
				if c2["id"] == u.crisis: cr = c2
			_rocket_at(best, float(ud.get("rs", 40)), cr)
		return
	# melee / armor / artillery: attack adjacent player units or cities, else advance
	var rng_ := int(ud.get("range", 1)) if float(ud.get("rs", 0)) > 0 else 1
	var target = null
	for o in S().units:
		if o.owner == "player" and is_military(o) and not (str(udata(o).get("cls", "")) in AIR) and SimHex.distance(o.pos(), u.pos()) <= rng_:
			if target == null or o.hp < target.hp: target = o
	if target != null:
		var pv := preview(u, target.pos())
		if not pv.is_empty() and (pv["delta"] > -12.0 or pv.get("ranged", false)):
			attack(u, target.pos())
		return
	for c in sim.active_cities():
		if SimHex.distance(c.pos(), u.pos()) <= rng_:
			attack_city(u, c)
			return
	var nearest = null; var nd := 99
	for c in sim.active_cities():
		var d2 := SimHex.distance(c.pos(), u.pos())
		if d2 < nd:
			nd = d2; nearest = c
	if nearest != null and nd > 1:
		var best_p := u.pos(); var best_d := nd
		for n in SimHex.neighbors(u.q, u.r):
			var k := SimHex.key(n.x, n.y)
			if passable(cls, k) and not _occupied(n, true, u.owner) and sim.city_at(n) == null:
				var dd := SimHex.distance(n, nearest.pos())
				if dd < best_d:
					best_d = dd; best_p = n
		if best_p != u.pos():
			var from := u.pos()
			u.q = best_p.x; u.r = best_p.y
			sim.unit_moved.emit(u.id, from, best_p)
