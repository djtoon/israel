class_name SimAdapter
extends RefCounted
## Thin layer between the UI and the v2 sim APIs (citizen locks, combat and front previews, district sites).
## Each call uses the sim's own method as soon as it exists (progress/INTEGRATION_REQUESTS.md "## v2") and
## otherwise falls back to a UI-side reading of the sim state, so the screens work before the sim lands.

static var _ui_locks := {}    # city id -> [tile keys] (fallback only: shown, but the sim does not use them yet)


# ================================================================== citizens (feature 2)

static func locks_live(sim) -> bool:
	return sim != null and (sim.has_method("set_tile_locked") or sim.has_method("set_citizen_lock"))


static func _set_lock(sim, city_id: int, q: int, r: int, on: bool) -> bool:
	if sim.has_method("set_tile_locked"):
		return bool(sim.set_tile_locked(city_id, q, r, on))
	return bool(sim.set_citizen_lock(city_id, q, r, on))


static func citizens(sim, city_id: int) -> Dictionary:
	## {tiles: [{q, r, key, yields, worked, locked, workable, district, centre}], specialists, unemployed, pop, live}
	if sim.has_method("get_worked_tiles"):
		# sim v2: [{q, r, yields, worked, locked, workable, centre, district, improvement, score}]
		var cd: Dictionary = sim.get_city(city_id)
		if cd.is_empty():
			return {}
		var inf: Dictionary = cd.get("info", {})
		var tl2: Array = []
		var nw := 0
		for t in sim.get_worked_tiles(city_id):
			var t3: Dictionary = (t as Dictionary).duplicate()
			t3["key"] = SimHex.key(int(t3["q"]), int(t3["r"]))
			if not t3.has("terrain"):
				var gt: Dictionary = sim.get_tile(int(t3["q"]), int(t3["r"]))
				t3["terrain"] = gt.get("terrain", ""); t3["feature"] = gt.get("feature", "")
				if not t3.has("improvement"): t3["improvement"] = gt.get("improvement", "")
			if bool(t3.get("centre", false)):
				t3["workable"] = false
				t3["worked"] = false   # the centre is always worked for free: not a citizen
			if bool(t3.get("worked", false)): nw += 1
			tl2.append(t3)
		return {"tiles": tl2, "specialists": int(inf.get("specialists", 0)), "unemployed": maxi(0, int(cd.get("pop", 0)) - nw),
			"pop": int(cd.get("pop", 0)), "live": true}
	if sim.has_method("get_citizens"):
		var d: Dictionary = sim.get_citizens(city_id)
		var out := d.duplicate()
		var tl: Array = []
		var c0 = sim.city_by_id(city_id)
		for t in d.get("tiles", []):
			var t2: Dictionary = (t as Dictionary).duplicate()
			t2["key"] = SimHex.key(int(t2["q"]), int(t2["r"]))
			t2["centre"] = c0 != null and int(t2["q"]) == c0.q and int(t2["r"]) == c0.r
			tl.append(t2)
		out["tiles"] = tl
		out["live"] = true
		return out
	var c := sim.get_city(city_id) as Dictionary
	if c.is_empty():
		return {}
	var cobj = sim.city_by_id(city_id)
	var info: Dictionary = c.get("info", {})
	var worked := {}
	for k in info.get("worked", []):
		worked[int(k)] = true
	var locked := {}
	for k in info.get("locked", _ui_locks.get(city_id, [])):
		locked[int(k)] = true
	var tiles := []
	for qr in c.get("tiles", []):
		var q := int(qr[0]); var r := int(qr[1])
		var k := SimHex.key(q, r)
		var t: Dictionary = sim.get_tile(q, r)
		if t.is_empty():
			continue
		var centre: bool = cobj != null and q == cobj.q and r == cobj.r
		var dist := str(t.get("district", ""))
		var workable: bool = not centre and dist == "" and str(t.get("terrain", "")) != "mountains"
		tiles.append({"q": q, "r": r, "key": k, "yields": t.get("yields", {}), "worked": worked.has(k), "locked": locked.has(k),
			"workable": workable, "district": dist, "centre": centre, "terrain": t.get("terrain", ""), "feature": t.get("feature", ""),
			"improvement": t.get("improvement", "")})
	return {"tiles": tiles, "specialists": int(info.get("specialists", 0)), "unemployed": maxi(0, int(c.get("pop", 0)) - worked.size()),
		"pop": int(c.get("pop", 0)), "live": false}


static func toggle_lock(sim, city_id: int, q: int, r: int) -> Dictionary:
	## Lock or unlock a citizen on (q, r). -> {ok, locked, live, reason}
	var k := SimHex.key(q, r)
	var cur := false
	var cz := citizens(sim, city_id)
	var tile := {}
	for t in cz.get("tiles", []):
		if int(t["key"]) == k:
			tile = t
	if tile.is_empty():
		return {"ok": false, "reason": "That tile does not belong to this city."}
	if not bool(tile.get("workable", false)):
		return {"ok": false, "reason": "City centres, districts and mountains cannot be worked."}
	cur = bool(tile.get("locked", false))
	if locks_live(sim):
		var ok := _set_lock(sim, city_id, q, r, not cur)
		return {"ok": ok, "locked": not cur if ok else cur, "live": true,
			"reason": "" if ok else "That tile cannot be worked."}
	var arr: Array = _ui_locks.get(city_id, [])
	if cur:
		arr.erase(k)
	else:
		if arr.size() >= int(cz.get("pop", 0)):
			return {"ok": false, "reason": "Every citizen is already locked: unlock a tile first."}
		arr.append(k)
	_ui_locks[city_id] = arr
	return {"ok": true, "locked": not cur, "live": false}


static func clear_locks(sim, city_id: int) -> void:
	if sim != null and sim.has_method("clear_citizen_locks"):
		sim.clear_citizen_locks(city_id)
	elif locks_live(sim):
		for t in citizens(sim, city_id).get("tiles", []):
			if bool(t.get("locked", false)):
				_set_lock(sim, city_id, int(t["q"]), int(t["r"]), false)
	_ui_locks.erase(city_id)


static func reset_fallback() -> void:
	_ui_locks.clear()


# ================================================================== unit combat preview (feature 3)

static func unit_preview(sim, unit_id: int, q: int, r: int) -> Dictionary:
	## sim.combat_preview plus win odds, the HP both sides are expected to keep and the main modifiers.
	var p: Dictionary = sim.combat_preview(unit_id, q, r)
	if p.is_empty():
		return {}
	var out := p.duplicate()
	var att = sim.unit_by_id(unit_id)
	var def = null
	for u in sim.state.units:
		if u.q == q and u.r == r and u.owner != (att.owner if att else "player"):
			def = u
			break
	var city = sim.city_at(Vector2i(q, r)) if def == null else null
	out["attacker_name"] = _unit_name(sim, att)
	out["defender_name"] = _unit_name(sim, def) if def != null else (str(city.name) if city != null else "target")
	out["attacker_hp"] = float(p.get("attacker_hp", att.hp if att else 100.0))
	out["defender_hp"] = float(p.get("defender_hp", def.hp if def != null else 100.0))
	var delta := float(p.get("delta", 0.0))
	var ranged := bool(p.get("ranged", false))
	var lo := SimMilitary.COMBAT_BASE * exp(SimMilitary.COMBAT_SCALE * delta)
	var hi := (SimMilitary.COMBAT_BASE + SimMilitary.COMBAT_EXTRA) * exp(SimMilitary.COMBAT_SCALE * delta)
	var blo := 0.0 if ranged else SimMilitary.COMBAT_BASE * exp(-SimMilitary.COMBAT_SCALE * delta)
	var bhi := 0.0 if ranged else (SimMilitary.COMBAT_BASE + SimMilitary.COMBAT_EXTRA) * exp(-SimMilitary.COMBAT_SCALE * delta)
	out["dealt_range"] = p.get("damage_dealt_range", [lo, hi])
	out["taken_range"] = p.get("damage_taken_range", [blo, bhi])
	lo = float(out["dealt_range"][0]); hi = float(out["dealt_range"][1])
	blo = float(out["taken_range"][0]); bhi = float(out["taken_range"][1])
	if not p.has("kill_chance"):
		out["kill_chance"] = _p_at_least(lo, hi, float(out["defender_hp"]))
	if not p.has("win_odds"):
		# a "win": the defender ends with less HP left than the attacker (Civ VI's "decisive" reading),
		# integrating over both uniform damage rolls (20 x 20 grid)
		var wins := 0.0
		for i in 20:
			var dd := lerpf(lo, hi, (i + 0.5) / 20.0)
			for j in 20:
				var tk := lerpf(blo, bhi, (j + 0.5) / 20.0)
				var dleft := float(out["defender_hp"]) - dd
				var aleft := float(out["attacker_hp"]) - tk
				if dleft <= 0.0 and aleft > 0.0 or (aleft > 0.0 and dleft < aleft):
					wins += 1.0
				elif absf(dleft - aleft) < 0.01:
					wins += 0.5
		out["win_odds"] = wins / 400.0
	if not p.has("modifiers"):
		out["modifiers"] = _modifiers(sim, att, def, city, ranged)
	return out


static func _p_at_least(lo: float, hi: float, need: float) -> float:
	if need <= lo:
		return 1.0
	if need >= hi:
		return 0.0
	return (hi - need) / maxf(0.001, hi - lo)


static func _unit_name(sim, u) -> String:
	if u == null:
		return "-"
	return str(sim.db.units.get(u.type, {}).get("name", UITheme.pretty(str(u.type))))


static func _modifiers(sim, att, def, city, ranged: bool) -> Array:
	## The main terms of SimMilitary.strength(), each with its sign (attacker side then defender side).
	var out := []
	var m = sim.military
	if att != null:
		var ud: Dictionary = sim.db.units.get(att.type, {})
		out.append({"side": "attacker", "label": "%s strength" % ("Ranged" if ranged else "Combat"), "amount": float(ud.get("rs", 0)) if ranged else m.cs_of(att), "base": true})
		var dmg := -roundf(10.0 - att.hp / 10.0)
		if dmg != 0: out.append({"side": "attacker", "label": "Damaged (%d HP)" % int(att.hp), "amount": dmg})
		if att.level > 0: out.append({"side": "attacker", "label": "Promotions (level %d)" % att.level, "amount": 5.0 * att.level})
		if att.owner == "player":
			var pol: float = sim.econ.mod_sum("unit_strength")
			if pol != 0: out.append({"side": "attacker", "label": "Policies", "amount": pol})
			var rd: float = (sim.state.readiness - 50.0) / 10.0
			if absf(rd) >= 0.05: out.append({"side": "attacker", "label": "Readiness %d" % int(sim.state.readiness), "amount": rd})
			for cr in sim.state.crises:
				if cr.get("response", "") == "mobilize" and cr.get("active", true):
					out.append({"side": "attacker", "label": "Reserves mobilised", "amount": 2.0})
					break
	if def != null:
		var dd: Dictionary = sim.db.units.get(def.type, {})
		out.append({"side": "defender", "label": "Combat strength", "amount": m.cs_of(def), "base": true})
		var ddmg := -roundf(10.0 - def.hp / 10.0)
		if ddmg != 0: out.append({"side": "defender", "label": "Damaged (%d HP)" % int(def.hp), "amount": ddmg})
		if def.level > 0: out.append({"side": "defender", "label": "Promotions", "amount": 5.0 * def.level})
		var k := SimHex.key(def.q, def.r)
		var terr: String = sim.econ.terrain(k)
		if terr in ["hills", "desert_hills"]: out.append({"side": "defender", "label": "Hills", "amount": 3.0})
		if sim.econ.feature(k) == "forest": out.append({"side": "defender", "label": "Forest", "amount": 3.0})
		if terr == "marsh": out.append({"side": "defender", "label": "Marsh", "amount": -2.0})
		if def.fortify >= 2: out.append({"side": "defender", "label": "Fortified", "amount": 6.0})
		elif def.fortify == 1: out.append({"side": "defender", "label": "Fortifying", "amount": 3.0})
		var sup := 0
		for n in SimHex.neighbors(def.q, def.r):
			for o in sim.state.units:
				if o.q == n.x and o.r == n.y and o.owner == def.owner and m.is_military(o) and o != def:
					sup += 1
		if sup > 0: out.append({"side": "defender", "label": "Support (%d adjacent)" % sup, "amount": 2.0 * sup})
		if dd.is_empty():
			pass
	elif city != null:
		out.append({"side": "defender", "label": "City defences (%s)" % city.name, "amount": m.city_strength(city), "base": true})
	return out


# ================================================================== war-front preview (feature 3)

static func front_preview(sim, opt: Dictionary) -> Dictionary:
	## For one war-turn crisis option: {win_odds, enemy: {formations, destroyed, hp}, ours: [text], town_strike, modifiers, estimate}
	var id := str(opt.get("id", ""))
	var est := _front_estimate(sim, opt)
	var sp: Dictionary = opt.get("preview", {}) if typeof(opt.get("preview")) == TYPE_DICTIONARY else {}
	if sp.is_empty() and sim.has_method("front_preview"):
		var opts: Array = sim.state.crisis_decision.get("options", [])
		for i in opts.size():
			if str(opts[i].get("id", "")) == id:
				sp = sim.front_preview(i)
	var near := _front_towns(sim, opt)
	if sp.is_empty():
		est["protects"] = near
		return est
	# sim v2 forecast (deterministic): expected formations destroyed, strikes on towns, units lost, lesson
	var out := {"estimate": false, "modifiers": est.get("modifiers", []), "ours": [], "town_strike": float(sp.get("expected_town_strikes", 0)) > 0.0}
	var n := int(sp.get("targets", 0))
	if n > 0:
		# headline: the share of the targeted formations' strength the order is expected to take away
		var en: Dictionary = est.get("enemy", {})
		var share := float(en.get("dealt", 0)) / maxf(1.0, float(en.get("hp", 0)))
		if en.is_empty():
			share = float(sp.get("expected_destroyed", 0)) / float(n)
		out["win_odds"] = clampf(share, 0.0, 1.0)
		out["enemy"] = {"formations": n, "destroyed": float(sp.get("expected_destroyed", 0)), "hp_share": clampf(share, 0.0, 1.0)}
	else:
		out["win_odds"] = -1.0
		out["verdict"] = {"economy_first": "No counter-attack", "standing_forces": "No counter-attack", "mobilize": "Campaign order",
			"limited_aims": "Campaign order"}.get(id, "Defensive order")
	if float(sp.get("gold", 0)) > 0:
		out["ours"].append("%s Gold" % UITheme.fmt_num(float(sp["gold"])))
	if float(sp.get("cohesion", 0)) > 0:
		out["ours"].append("%s Cohesion" % UITheme.fmt_num(float(sp["cohesion"])))
	if float(sp.get("expected_units_lost", 0)) >= 0.05:
		out["ours"].append("about %s unit%s lost" % [str(snappedf(float(sp["expected_units_lost"]), 0.1)), "" if absf(float(sp["expected_units_lost"]) - 1.0) < 0.05 else "s"])
	if float(sp.get("expected_town_strikes", 0)) >= 0.05:
		out["ours"].append("about %s strike%s on towns" % [str(snappedf(float(sp["expected_town_strikes"]), 0.1)), "" if absf(float(sp["expected_town_strikes"]) - 1.0) < 0.05 else "s"])
	out["left"] = {"formations": int(sp.get("enemy_formations", 0)), "left": float(sp.get("expected_left", 0))}
	# the front's own stake (headline): formations pinned down there, towns covered, strikes expected on towns
	out["front"] = str(sp.get("front", opt.get("front", "")))
	out["targets"] = n
	out["pinned"] = clampf(float(sp.get("expected_suppressed", 0)) + float(sp.get("expected_destroyed", 0)), 0.0, float(maxi(n, 0)))
	out["strikes"] = float(sp.get("expected_town_strikes", 0))
	out["residents_at_risk"] = int(sp.get("residents_at_risk", 0))
	out["strikes_by_front"] = sp.get("strikes_by_front", {})
	for k in ["stake", "strikes_avoided", "populations_at_risk", "affected", "other_populations", "note"]:   # fix-wars additions, when present
		if sp.has(k):
			out[k] = sp[k]
	# what the order protects and which towns are at risk (sim keys when present, else the towns near the front)
	out["protects"] = sp.get("protects", near)
	if sp.has("towns_at_risk"):
		out["at_risk"] = sp["towns_at_risk"]
	var les := float(sp.get("lesson_effect", 0))
	if absf(les) > 0.01:
		out["modifiers"] = (out["modifiers"] as Array) + [{"label": "Readiness lesson after the war", "amount": les}]
	return out


static func _front_towns(sim, opt: Dictionary) -> Array:
	## Names of the largest Israeli towns within 4 tiles of the front this option commits to (its anchor first).
	var id := str(opt.get("id", ""))
	var cr := _crisis_of(sim, opt)
	var pos := Vector2i(-999, -999)
	if id.begins_with("dfront:") or id.begins_with("shield:"):
		for fr in cr.get("data_fronts", []):
			if str(fr["id"]) == id.substr(id.find(":") + 1):
				pos = Vector2i(int(fr["pos"][0]), int(fr["pos"][1]))
	elif id.begins_with("front:"):
		var xy := id.substr(6).split(",")
		pos = Vector2i(int(xy[0]), int(xy[1]))
	if pos.x == -999:
		return []
	var cs := []
	for c in sim.active_cities():
		var dd := SimHex.distance(pos, c.pos())
		if dd <= 4:
			cs.append([dd * 1000000 - c.residents, c.name])
	cs.sort_custom(func(a, b): return a[0] < b[0])
	return cs.slice(0, 3).map(func(x): return str(x[1]))


static func _front_estimate(sim, opt: Dictionary) -> Dictionary:
	## UI-side estimate (before the sim's forecast existed): mirrors SimMilitary._apply_war_turn.
	var id := str(opt.get("id", ""))
	var st = sim.state
	var cr := _crisis_of(sim, opt)
	var out := {"estimate": true, "modifiers": [], "ours": [], "town_strike": false}
	var cost: Dictionary = opt.get("cost", {})
	var prod := float(sim.get_national_summary().get("production", 0))
	if cost.has("production_pct"):
		out["ours"].append("−%d%% production this quarter (about %d)" % [int(cost["production_pct"]), int(round(prod * float(cost["production_pct"]) / 100.0))])
	if float(cost.get("gold", 0)) > 0:
		out["ours"].append("%s Gold" % UITheme.fmt_num(float(cost["gold"])))
	if float(cost.get("cohesion", 0)) > 0:
		out["ours"].append("%s Cohesion" % UITheme.fmt_num(float(cost["cohesion"])))
	var targets := []
	var hit := 0.0
	if id.begins_with("dfront:") and not cr.is_empty():
		var fid := id.substr(7)
		for fr in cr.get("data_fronts", []):
			if str(fr["id"]) == fid:
				for uid in sim.military._front_alive(fr):
					var hu = sim.unit_by_id(int(uid))
					if hu != null: targets.append(hu)
		hit = 45.0 + 0.4 * float(st.readiness)
		out["modifiers"].append({"label": "Counter-attack (45 + 0.4 x Readiness %d)" % int(st.readiness), "amount": hit, "base": true})
		out["ours"].append("1 reserve brigade committed to the front")
	elif id.begins_with("front:") and not cr.is_empty():
		var xy := id.substr(6).split(",")
		targets = sim.military._hostiles_near(cr, Vector2i(int(xy[0]), int(xy[1])), 5)
		hit = 45.0 + 0.4 * float(st.readiness)
		out["modifiers"].append({"label": "Counter-attack (45 + 0.4 x Readiness %d)" % int(st.readiness), "amount": hit, "base": true})
		out["ours"].append("1 reserve brigade committed to the front")
	elif id == "full_mobilization":
		for c in _crises_of(sim, opt):
			for u in st.units:
				if u.owner != "player" and u.crisis == c["id"]:
					targets.append(u)
		hit = 30.0 + 0.3 * float(st.readiness)
		out["modifiers"].append({"label": "Strike on every front (30 + 0.3 x Readiness %d)" % int(st.readiness), "amount": hit, "base": true})
	elif id.begins_with("shield:"):
		out["modifiers"].append({"label": "Interceptors and shelters concentrated", "amount": 0.0})
		out["ours"].append("half damage to towns within 4 tiles of the front this quarter")
		out["win_odds"] = -1.0
	elif id in ["economy_first", "standing_forces"] and not cr.is_empty() and not cr.get("offensive", false):
		out["town_strike"] = true
		var fronts: Array = sim.military._front_names(cr)
		var town := ""
		if not fronts.is_empty():
			var c2 = sim.city_at(fronts[0]["pos"])
			if c2 != null:
				town = str(c2.name)
		out["ours"].append("the enemy keeps the initiative and strikes %s (strength %d)" % [town if town != "" else "a front town", int(40 + 2 * int(st.era))])
		out["modifiers"].append({"label": "No counter-attack", "amount": 0.0})
		out["win_odds"] = 0.0
	if hit > 0.0:
		var kills := 0.0
		var hp := 0.0
		var dealt := 0.0
		for u in targets:
			hp += float(u.hp)
			dealt += minf(float(u.hp), hit)
			kills += _p_at_least(hit * 0.8, hit * 1.2, float(u.hp))
		out["enemy"] = {"formations": targets.size(), "destroyed": kills, "hp": hp, "dealt": dealt, "hp_share": dealt / maxf(1.0, hp)}
		out["win_odds"] = dealt / maxf(1.0, hp) if targets.size() > 0 else 0.0
		var rd := (float(st.readiness) - 50.0)
		if absf(rd) >= 1.0:
			out["modifiers"].append({"label": "Readiness %d (%s 50)" % [int(st.readiness), "above" if rd > 0 else "below"], "amount": 0.4 * rd if hit > 40.0 else 0.3 * rd})
		for c in st.crises:
			if c.get("response", "") == "mobilize" and c.get("active", true):
				out["modifiers"].append({"label": "Reserves mobilised (units +2)", "amount": 2.0})
				break
	return out


static func _crises_of(sim, opt: Dictionary) -> Array:
	var cd: Dictionary = sim.state.crisis_decision
	var ids: Array = cd.get("crises", [cd.get("crisis", "")])
	return sim.state.crises.filter(func(c): return c["id"] in ids)


static func _crisis_of(sim, opt: Dictionary) -> Dictionary:
	var cid := str(opt.get("crisis", sim.state.crisis_decision.get("crisis", "")))
	for c in sim.state.crises:
		if str(c["id"]) == cid:
			return c
	return {}


# ================================================================== district sites (feature 1)

static func district_sites(sim, city_id: int, did: String) -> Array:
	## [{q, r, adjacency, appeal, parts?}] best first (only the valid tiles).
	if sim.has_method("get_district_lens"):
		var out := []
		for t in sim.get_district_lens(city_id, did):
			if bool(t.get("valid", false)):
				var t2: Dictionary = (t as Dictionary).duplicate()
				var pl := []
				for pp in t2.get("parts", []):
					pl.append({"label": part_label(pp), "amount": float(pp.get("amount", 0))})
				t2["parts"] = pl
				out.append(t2)
		return out
	return sim.get_district_sites(city_id, did)


static func invalid_sites(sim, city_id: int, did: String) -> Dictionary:
	## Vector2i -> reason for the city's tiles where the district cannot go (sim v2 lens only).
	var out := {}
	if sim.has_method("get_district_lens"):
		for t in sim.get_district_lens(city_id, did):
			if not bool(t.get("valid", false)):
				out[Vector2i(int(t["q"]), int(t["r"]))] = str(t.get("reason", ""))
	return out


static func part_label(pp: Dictionary) -> String:
	## One adjacency part {src, id, count, per, amount} as words: "2 Mines", "the river", "3 districts (1 per 2)".
	var n := int(pp.get("count", 0))
	var id := str(pp.get("id", ""))
	var per := int(pp.get("per", 1))
	var nm := ""
	match str(pp.get("src", "")):
		"district":
			nm = str(SimDB.get_db().districts.get(id, {}).get("name", UITheme.pretty(id)))
		"improvement":
			nm = str(SimDB.get_db().improvements.get(id, {}).get("name", UITheme.pretty(id)))
		"terrain", "feature":
			nm = UITheme.pretty(id)
		"district_any": nm = "district"
		"city_center": nm = "city centre"
		"river": return "next to a river"
		"sea_resource": nm = "sea resource"
		"natural_wonder": nm = "natural wonder"
		"project": nm = "national project"
		"place_kind": nm = "heritage or holy site"
		"government_complex": return "next to the Government Complex"
		_: nm = UITheme.pretty(str(pp.get("src", "")))
	var plural := nm if n == 1 else (nm + "s" if not nm.ends_with("s") else nm)
	return "%d %s%s" % [n, plural, (" (1 per %d)" % per) if per > 1 else ""]


static func adjacency_parts(sim, city_id: int, did: String, q: int, r: int) -> Array:
	## Tooltip lines for one site: [{label, amount}] per adjacency rule that applies (sim parts when provided).
	var d: Dictionary = sim.db.districts.get(did, {})
	var out := []
	var c = sim.city_by_id(city_id)
	if c == null:
		return out
	var k := SimHex.key(q, r)
	var saved = sim.db.districts[did]
	var tmp: Dictionary = saved.duplicate()
	sim.db.districts[did] = tmp
	tmp["adjacency"] = []
	var base: float = sim.econ.adjacency(c, did, k)   # terms outside the rules (Government Complex next door)
	for rule in d.get("adjacency", []):
		tmp["adjacency"] = [rule]
		var v: float = sim.econ.adjacency(c, did, k) - base
		if absf(v) > 0.001:
			out.append({"label": CityScreen._adj_text(rule), "amount": v})
	sim.db.districts[did] = saved
	if absf(base) > 0.001:
		out.append({"label": "next to the Government Complex", "amount": base})
	return out
