class_name SimEconomy
extends RefCounted
## City and national economy rules (Civ VI-derived, MECHANICS.md 3-7 and 29):
## tile yields, worked tiles, specialists, districts and adjacency, housing, amenities,
## civic trust, growth, immigration, water and borders.

const TERRAIN_YIELD := {
	"grassland": {"food": 2}, "plains": {"food": 1, "production": 1}, "hills": {"food": 1, "production": 2},
	"mountains": {}, "desert": {}, "desert_hills": {"production": 1}, "marsh": {"food": 2},
	"coast": {"food": 1, "gold": 1}, "lake": {"food": 1, "gold": 1}, "ocean": {"food": 1},
}
const FEATURE_YIELD := {
	"forest": {"production": 1}, "orchard": {"food": 1, "gold": 1}, "wadi": {"food": 1},
	"oasis": {"food": 3, "gold": 1}, "reef": {"food": 1, "production": 1},
}
const RESOURCE_YIELD := {
	"citrus": {"food": 2}, "olives": {"production": 1, "gold": 1}, "dates": {"food": 1, "gold": 1},
	"grapes": {"food": 1, "gold": 1}, "wheat": {"food": 1}, "fish": {"food": 1}, "sheep": {"food": 1},
	"cattle": {"food": 1}, "potash": {"production": 1}, "phosphates": {"production": 1}, "copper": {"gold": 2},
	"camels": {"food": 1}, "limestone": {"production": 1}, "clay": {"production": 1},
	"tobacco": {"cohesion": 1}, "gypsum": {"production": 1, "gold": 1}, "salt": {"food": 1, "gold": 1},
}
const LUXURIES := ["citrus", "olives", "dates", "grapes", "tobacco", "gypsum", "salt"]
const QUARRY_RES := ["limestone", "clay"]
const MINERAL_RES := ["potash", "phosphates", "copper", "gypsum", "salt"]
const PASTURE_RES := ["sheep", "cattle", "camels"]
const GROVE_RES := ["citrus", "olives", "grapes", "dates", "tobacco"]
const HILL_BASE := {"grassland": {"food": 2, "production": 1}, "plains": {"food": 1, "production": 2}, "desert": {"production": 1}}
## Natural wonder yields (Civ VI style), by map kind
const WONDER_YIELD := {"crater": {"science": 2, "culture": 1}, "mountain": {"culture": 1, "science": 1}, "sea_cave": {"culture": 2, "gold": 2},
	"oasis": {"food": 2, "culture": 2}, "lake": {"gold": 1, "culture": 1}, "valley": {"culture": 2, "production": 1}}
const FARM_TYPES := ["farm", "kibbutz", "moshav", "grove", "fish_ponds", "drip_farm", "pasture"]
const WATER_TERRAIN := ["coast", "lake", "ocean"]
const PERIPHERY := ["Negev", "Arava", "Galilee", "Golan", "Dead Sea", "Judean Desert", "Jordan Valley", "Hula Valley", "Upper Galilee", "Lower Galilee"]
const YIELDS := ["food", "production", "gold", "science", "culture", "cohesion"]
## Amenity states (GS table, MECHANICS 3.3): [min balance, name, non-food yield %, growth %, trust per turn]
const AMENITY_STATES := [
	[5, "ecstatic", 20, 20, 6], [3, "happy", 10, 10, 3], [0, "content", 0, 0, 0], [-2, "displeased", -10, -15, -3],
	[-4, "unhappy", -20, -30, -6], [-6, "unrest", -30, -100, -9], [-999, "revolt", -40, -100, -12],
]

var sim
var mods: Array = []          # national modifier effects this turn
var city_tiles := {}          # city id -> [tile key]
var tiles_dirty := true
var border_cache_era := ""
var border := {}
var natural_rate := {}        # year -> annual net natural increase (calibrated)
var emitters: Array = []      # region-effect buildings [{pos, id, yields, radius, amen}]
var food_ratio := 1.0
var nat_food_surplus := 0.0


func _init(s) -> void:
	sim = s


func S() -> GameState:
	return sim.state


func db() -> SimDB:
	return sim.db


# ------------------------------------------------------------------ calibration

func calibrate() -> void:
	## Net natural increase per year so that history-like play tracks S119 given S276 immigration.
	## r(y) = (P(y+1) - P(y) - I_may_to_may(y)) / P(y), smoothed and clamped; model parameter, not a claim.
	var pops: Dictionary = db().real.get("population", {}).get("values", {})
	var raw := {}
	for y in range(1948, SimDB.end_year()):
		var p0 := float(pops.get(str(y), 0)); var p1 := float(pops.get(str(y + 1), 0))
		if p0 <= 0 or p1 <= 0:
			continue
		var imm := 0.62 * db().immigration_in_year(y) + 0.38 * db().immigration_in_year(y + 1)
		if y == 1948:
			imm = db().immigration_in_year(1948) + 0.38 * db().immigration_in_year(1949)
		raw[y] = clampf((p1 - p0 - imm) / p0, 0.006, 0.04)
	for y in range(1948, SimDB.end_year() + 1):
		var acc := 0.0; var n := 0
		for dy in range(-2, 3):
			if raw.has(y + dy):
				acc += raw[y + dy]; n += 1
		natural_rate[y] = acc / n if n > 0 else 0.014


## The growth multiplier at which a city grows at the calibrated natural rate. Calibrated (v2) so that the
## Historical Israel autoplayer (the ghost) tracks the CBS series within a few percent at the census years.
const GROWTH_REF := 1.13   # v3 recalibration (sim-endgame): v3 trust, budget and programme gains raised the ghost above CBS by 2000-08


func nat_rate(year: int) -> float:
	return float(natural_rate.get(clampi(year, 1948, SimDB.end_year()), 0.014))


# ------------------------------------------------------------------ tiles

func tstate(k: int) -> Dictionary:
	var ts = S().tiles.get(k)
	if ts == null:
		ts = {"o": 0, "imp": "", "d": "", "f": ""}
		S().tiles[k] = ts
	return ts


func terrain(k: int) -> String:
	var t = db().tiles.get(k)
	if t == null:
		return "ocean"
	var hc = t.get("historical_change")
	if typeof(hc) == TYPE_DICTIONARY and S().turn >= SimDB.turn_of(hc.get("date"), 99999):
		return str(hc.get("to_terrain", t["terrain"]))
	return str(t["terrain"])


func feature(k: int) -> String:
	var ts = S().tiles.get(k)
	if ts != null and str(ts.get("f", "")) != "":
		return str(ts["f"])
	var t = db().tiles.get(k)
	return "none" if t == null else str(t.get("feature", "none"))


func resource(k: int) -> String:
	var t = db().tiles.get(k)
	if t == null or t.get("resource") == null:
		return ""
	if t.get("resource_reveal") != null and S().turn < SimDB.turn_of(t["resource_reveal"], 0):
		return ""
	return str(t["resource"])


func is_water(k: int) -> bool:
	return terrain(k) in WATER_TERRAIN


func region(k: int) -> String:
	var t = db().tiles.get(k)
	return "" if t == null else str(t.get("region", ""))


func in_border(k: int) -> bool:
	_refresh_border()
	return border.has(k)


func _refresh_border() -> void:
	var e := db().border_era_at(S().turn)
	if e != border_cache_era:
		border_cache_era = e
		border = db().borders.get(e, {})
		if border.is_empty():
			# No border data: allow everything within 3 tiles of a city.
			for c in S().cities:
				for p in SimHex.within(c.q, c.r, 3):
					border[SimHex.key(p.x, p.y)] = true


func is_military_control(k: int) -> bool:
	return db().military_set(S().turn).has(k)


func military_tiles_owned() -> int:
	var ms: Dictionary = db().military_set(S().turn)
	if ms.is_empty():
		return 0
	var n := 0
	for k in S().tiles:
		if int(S().tiles[k].get("o", 0)) > 0 and ms.has(k):
			n += 1
	return n


func has_fresh_water(k: int) -> bool:
	var t = db().tiles.get(k)
	if t == null:
		return false
	if t.get("river", false) or feature(k) == "oasis":
		return true
	var p := SimHex.from_key(k)
	for n in SimHex.neighbors(p.x, p.y):
		var nk := SimHex.key(n.x, n.y)
		var nt = db().tiles.get(nk)
		if nt != null and (terrain(nk) == "lake" or nt.get("river", false) or feature(nk) == "oasis"):
			return true
	return false


func is_coastal(k: int) -> bool:
	var p := SimHex.from_key(k)
	for n in SimHex.neighbors(p.x, p.y):
		var nk := SimHex.key(n.x, n.y)
		if terrain(nk) in ["coast", "ocean"]:
			return true
	return false


func city_tile_keys(c: SimCity) -> Array:
	if tiles_dirty:
		_rebuild_city_tiles()
	return city_tiles.get(c.id, [])


func _rebuild_city_tiles() -> void:
	city_tiles.clear()
	for k in S().tiles:
		var o := int(S().tiles[k].get("o", 0))
		if o > 0:
			if not city_tiles.has(o):
				city_tiles[o] = []
			city_tiles[o].append(k)
	tiles_dirty = false


func claim(c: SimCity, k: int) -> bool:
	if not db().tiles.has(k) or not in_border(k):
		return false
	var ts := tstate(k)
	if int(ts.get("o", 0)) != 0:
		return false
	ts["o"] = c.id
	tiles_dirty = true
	return true


func release_outside_border() -> Array:
	## Border era changed: tiles outside the new border lose owner, improvement and district.
	_refresh_border()
	var lost := []
	for k in S().tiles.keys():
		var ts: Dictionary = S().tiles[k]
		if int(ts.get("o", 0)) != 0 and not border.has(k):
			var c = sim.city_by_id(int(ts["o"]))
			if c != null and str(ts.get("d", "")) != "":
				c.districts.erase(ts["d"])
			ts["o"] = 0; ts["imp"] = ""; ts["d"] = ""
			lost.append(k)
	tiles_dirty = true
	return lost


func initial_claim(c: SimCity) -> void:
	var p := c.pop()
	var rad := 1
	if p >= 6: rad = 2
	if p >= 12: rad = 3
	claim(c, SimHex.key(c.q, c.r))
	tstate(SimHex.key(c.q, c.r))["o"] = c.id
	for rr in range(1, rad + 1):
		for n in SimHex.ring(c.q, c.r, rr):
			claim(c, SimHex.key(n.x, n.y))
	c.tiles_claimed = city_tile_keys(c).size()


func claim_extra(c: SimCity, n: int) -> void:
	## A completed national project grants free tiles (Civ VI wonders: +2 tiles).
	for i in range(n):
		c.border_culture += border_cost(c.tiles_claimed) + 1.0
		if grow_border(c, 0.0) < 0:
			break


func border_cost(n: int) -> float:
	return 0.65 * (10.0 + pow(6.0 * maxf(0, n - 6), 1.3))


func grow_border(c: SimCity, culture: float) -> int:
	c.border_culture += culture
	var cost := border_cost(c.tiles_claimed)
	if c.border_culture < cost:
		return -1
	var best := -1; var best_s := -1.0
	var owned := {}
	for k in city_tile_keys(c):
		owned[k] = true
	for k in owned:
		var p := SimHex.from_key(k)
		for n in SimHex.neighbors(p.x, p.y):
			var nk := SimHex.key(n.x, n.y)
			if owned.has(nk) or not db().tiles.has(nk) or SimHex.distance(n, c.pos()) > 3:
				continue
			if int(tstate(nk).get("o", 0)) != 0 or not in_border(nk):
				continue
			var s := _tile_score(tile_yield(nk, c), "") + (2.0 if resource(nk) != "" else 0.0)
			if s > best_s:
				best_s = s; best = nk
	if best < 0:
		c.border_culture = minf(c.border_culture, cost)
		return -1
	c.border_culture -= cost
	claim(c, best)
	c.tiles_claimed += 1
	return best


func buy_tile_cost(c: SimCity, k: int) -> int:
	var d := SimHex.distance(c.pos(), SimHex.from_key(k))
	var base: float = 50.0 * 0.65 * (1.0 + 4.0 * sim.progress_fraction())
	return int(round(base * (1.0 + 0.25 * maxi(0, d - 1)) / 5.0) * 5)


func buyable_tiles(c: SimCity) -> Array:
	var out := []
	var owned := {}
	for k in city_tile_keys(c):
		owned[k] = true
	var seen := {}
	for k in owned:
		var p := SimHex.from_key(k)
		for n in SimHex.neighbors(p.x, p.y):
			var nk := SimHex.key(n.x, n.y)
			if seen.has(nk) or owned.has(nk) or not db().tiles.has(nk):
				continue
			seen[nk] = true
			if SimHex.distance(n, c.pos()) <= 3 and int(tstate(nk).get("o", 0)) == 0 and in_border(nk):
				out.append({"q": n.x, "r": n.y, "cost": buy_tile_cost(c, nk)})
	return out


# ------------------------------------------------------------------ modifiers

func rebuild_mods() -> void:
	mods.clear()
	var S_ := S()
	var cuts: Dictionary = S_.counters.get("policy_cuts", {})   # v3 final round (fix4-econ, N1): cards scaled back or suspended
	var slotted := {}
	for slot in S_.policies:
		var pid := str(slot.get("id", ""))
		if pid != "" and db().policies.has(pid):
			slotted[pid] = true
			var cut := str(cuts.get(pid, ""))
			if cut == "suspend":
				continue   # the card keeps its slot but does nothing and costs nothing
			for e in db().policies[pid].get("effects", []):
				var ee: Dictionary = e.duplicate(); ee["src"] = "policy:" + pid
				if cut == "half":
					for fk in ["amount", "pct"]:   # half its cost and half its benefits
						if ee.has(fk): ee[fk] = float(ee[fk]) * 0.5
				mods.append(ee)
	for k in cuts.keys():
		if not slotted.has(k): cuts.erase(k)   # a card taken out of its slot comes back at full strength
	for tid in S_.techs:
		var t = db().techs.get(tid)
		if t != null:
			for e in t.get("effects", []):
				var ee2: Dictionary = e.duplicate(); ee2["src"] = "tech:" + tid
				mods.append(ee2)
	for pid in S_.projects:
		var pr = db().projects.get(pid)
		if pr != null:
			for e in pr.get("effects", []):
				var ee3: Dictionary = e.duplicate(); ee3["src"] = "project:" + pid; ee3["pcity"] = S_.projects[pid].get("city", 0)
				mods.append(ee3)
	for e in S_.temp_effects:
		if int(e.get("until", 0)) >= S_.turn:
			mods.append(e)
	if S_.budget_focus.has("yield") and int(S_.budget_focus.get("until", 0)) >= S_.turn:
		mods.append({"type": "yield_pct", "yield": S_.budget_focus["yield"], "pct": 10, "src": "budget"})
	if S_.age == "golden":
		mods.append({"type": "trust", "amount": 1, "src": "age"})
		match S_.dedication:
			"innovation": mods.append({"type": "yield_pct", "yield": "science", "pct": 10, "src": "dedication"})
			"ingathering": mods.append({"type": "retention", "pct": 5, "src": "dedication"})
			"pioneering": mods.append({"type": "city_yield", "yield": "production", "amount": 2, "cond": {"max_pop": 6}, "src": "dedication"})
			"statecraft": mods.append({"type": "standing_per_turn", "amount": 0.1, "src": "dedication"})
	elif S_.age == "dark":
		mods.append({"type": "trust", "amount": -1, "src": "age"})
	# lasting terms of forks and choices (streams) become modifiers while active
	for s in S_.streams:
		if not sim._stream_active(s):
			continue
		var a := float(s.get("amount", 0))
		var lbl := "term:" + str(s.get("label", ""))
		match str(s.get("type")):
			"output_pct":
				mods.append({"type": "yield_pct", "yield": "production", "pct": a, "src": lbl})
				mods.append({"type": "yield_pct", "yield": "gold", "pct": a, "src": lbl})
			"science_pct": mods.append({"type": "yield_pct", "yield": "science", "pct": a, "src": lbl})
			"growth_pct": mods.append({"type": "growth_pct", "pct": a, "src": lbl})
			"water": mods.append({"type": "water_supply", "amount": a, "src": lbl})
			"cohesion": mods.append({"type": "cohesion_per_turn", "amount": a, "src": lbl})
			"amenity": mods.append({"type": "amenity", "amount": a, "cond": {"group": str(s.get("group", "all"))}, "src": lbl})
			"retention": mods.append({"type": "retention", "pct": a, "src": lbl})
			"immigrant_weight": mods.append({"type": "immigrant_weight", "target": str(s.get("target", "small_towns")), "pct": a, "src": lbl})
	# v2 cabinet: the state budget in force, ministers' seats and promotions, coalition terms (SimCabinet)
	if sim.cabinet != null:
		for e in sim.cabinet.active_mods():
			mods.append(e)


func cond_ok(cond, c) -> bool:
	if typeof(cond) != TYPE_DICTIONARY or cond.is_empty():
		return true
	if c == null:
		return not (cond.has("min_pop") or cond.has("max_pop") or cond.has("has_building") or cond.has("lacks_building") or cond.has("has_district") or cond.has("periphery"))
	if cond.has("min_pop") and c.pop() < int(cond["min_pop"]): return false
	if cond.has("max_pop") and c.pop() > int(cond["max_pop"]): return false
	if cond.has("has_building") and not c.has_building(str(cond["has_building"])): return false
	if cond.has("lacks_building") and c.has_building(str(cond["lacks_building"])): return false
	if cond.has("has_district") and not c.has_district(str(cond["has_district"])): return false
	if cond.has("periphery") and bool(cond["periphery"]) != is_periphery(c): return false
	if cond.has("group") and not in_group(c, str(cond["group"])): return false
	return true


func in_group(c: SimCity, group: String) -> bool:
	## Groups used by lasting terms (FORKS.md): all, dev_towns, arab, periphery, large_cities.
	match group:
		"all", "": return true
		"arab": return c.kind in NON_JEWISH_KINDS
		"periphery": return is_periphery(c)
		"large_cities": return c.pop() >= 12
		"dev_towns": return not (c.kind in NON_JEWISH_KINDS) and c.kind in ["city", "town"] and c.hist_founded_turn > 1
	return false


func trust_base_offset(c: SimCity) -> float:
	var t := 0.0
	for s in S().streams:
		if str(s.get("type")) == "trust_base" and sim._stream_active(s) and in_group(c, str(s.get("group", "all"))):
			t += float(s.get("amount", 0))
	return t


func is_periphery(c: SimCity) -> bool:
	var reg := region(SimHex.key(c.q, c.r))
	for p in PERIPHERY:
		if reg.find(p) >= 0:
			return true
	return c.r >= 80   # south of Beersheba's latitude band


func mod_sum(type_: String, field := "amount", match_key := "", match_val = null, c = null) -> float:
	var s := 0.0
	for e in mods:
		if e.get("type") != type_:
			continue
		if match_key != "" and e.get(match_key) != match_val:
			continue
		if e.has("city") and (c == null or int(e["city"]) != c.id):
			continue
		if not cond_ok(e.get("cond"), c):
			continue
		s += float(e.get(field, 0))
	return s


# ------------------------------------------------------------------ yields

func tile_yield(k: int, c = null) -> Dictionary:
	var y := {}
	var terr := terrain(k)
	var base = db().tiles.get(k, {}).get("base")
	if terr in ["hills", "desert_hills"] and base != null and HILL_BASE.has(str(base)):
		for kk in HILL_BASE[str(base)]:
			y[kk] = float(HILL_BASE[str(base)][kk])
	else:
		for kk in TERRAIN_YIELD.get(terr, {}):
			y[kk] = float(TERRAIN_YIELD[terr][kk])
	var w = db().wonder_at.get(k)
	if w != null:
		var wy: Dictionary = WONDER_YIELD.get(str(w.get("kind", "")), {"culture": 1})
		for kk in wy:
			y[kk] = y.get(kk, 0.0) + float(wy[kk])
	var f := feature(k)
	for kk in FEATURE_YIELD.get(f, {}):
		y[kk] = y.get(kk, 0.0) + FEATURE_YIELD[f][kk]
	var res := resource(k)
	for kk in RESOURCE_YIELD.get(res, {}):
		y[kk] = y.get(kk, 0.0) + RESOURCE_YIELD[res][kk]
	var ts = S().tiles.get(k)
	if ts != null and str(ts.get("imp", "")) != "":
		var imp = db().improvements.get(ts["imp"])
		if imp != null:
			for kk in imp.get("yields", {}):
				y[kk] = y.get(kk, 0.0) + float(imp["yields"][kk])
			if c != null:
				for e in mods:
					if e.get("type") == "tile_yield_city" and int(e.get("city", 0)) == c.id and ts["imp"] in e.get("improvement", []):
						y[e["yield"]] = y.get(e["yield"], 0.0) + float(e.get("amount", 0))
				if ts["imp"] in FARM_TYPES and S().water.get("ratio", 1.0) < 1.0:
					y["food"] = y.get("food", 0.0) * maxf(0.5, float(S().water["ratio"]))
	return y


func worked_tiles(c: SimCity) -> Array:
	## Citizen management view: every tile of the city with its yields and whether it is worked or locked.
	var out := []
	var worked: Array = c.info.get("worked", [])
	var ck := SimHex.key(c.q, c.r)
	for k in city_tile_keys(c):
		var p := SimHex.from_key(k)
		var ty := tile_yield(k, c)
		var dist := str(tstate(k).get("d", ""))
		var workable: bool = k != ck and dist == "" and terrain(k) != "mountains"
		out.append({"q": p.x, "r": p.y, "yields": ty, "worked": worked.has(k) or k == ck, "locked": c.locked.has(k), "workable": workable,
			"centre": k == ck, "district": dist, "improvement": str(tstate(k).get("imp", "")), "score": snappedf(_tile_score(ty, c.focus), 0.01)})
	return out


func _tile_score(y: Dictionary, focus: String) -> float:
	var w := {"food": 1.25, "production": 1.0, "gold": 0.8, "science": 1.0, "culture": 0.8}
	if focus != "" and w.has(focus):
		w[focus] = w[focus] * 2.0
	var s := 0.0
	for kk in y:
		s += float(y[kk]) * float(w.get(kk, 0.5))
	return s


func urban_worker_yield() -> Dictionary:
	## Citizens not working a tile hold urban jobs; productivity rises with the era.
	var era := S().era
	return {"production": 0.8 + 0.1 * era, "gold": 0.4 + 0.06 * era}


func specialty_count(c: SimCity) -> int:
	var n := 0
	for d in c.districts:
		if db().districts.get(d, {}).get("specialty", false):
			n += 1
	return n


func district_cap(c: SimCity) -> int:
	return 1 + int((c.pop() - 1) / 3)


func adjacency(c: SimCity, did: String, k: int) -> float:
	var d = db().districts.get(did)
	if d == null:
		return 0.0
	var p := SimHex.from_key(k)
	var nbrs := SimHex.neighbors(p.x, p.y)
	var total := 0.0
	for rule in d.get("adjacency", []):
		var cnt := _rule_count(c, rule, k, p, nbrs)
		var per := int(rule.get("per", 1))
		total += float(int(cnt / per)) * float(rule.get("amount", 1))
	for n in nbrs:
		if str(tstate(SimHex.key(n.x, n.y)).get("d", "")) == "government_complex" and d.get("specialty", false):
			total += 1.0
	var pct := mod_sum("adjacency_pct", "pct", "district", did)
	return total * (1.0 + pct / 100.0)


func _rule_count(c: SimCity, rule: Dictionary, k: int, p: Vector2i, nbrs: Array) -> int:
	var cnt := 0
	match str(rule.get("src", "")):
		"terrain":
			for n in nbrs: if terrain(SimHex.key(n.x, n.y)) == rule.get("id"): cnt += 1
		"feature":
			for n in nbrs: if feature(SimHex.key(n.x, n.y)) == rule.get("id"): cnt += 1
		"district":
			for n in nbrs: if str(tstate(SimHex.key(n.x, n.y)).get("d", "")) == rule.get("id"): cnt += 1
		"district_any":
			for n in nbrs:
				var nk := SimHex.key(n.x, n.y)
				if str(tstate(nk).get("d", "")) != "" or sim.city_at(n) != null: cnt += 1
		"city_center":
			for n in nbrs: if sim.city_at(n) != null: cnt += 1
		"river":
			var t = db().tiles.get(k)
			if t != null and t.get("river", false): cnt = 1
		"sea_resource":
			for n in nbrs:
				var nk2 := SimHex.key(n.x, n.y)
				if is_water(nk2) and resource(nk2) != "": cnt += 1
		"improvement":
			for n in nbrs: if str(tstate(SimHex.key(n.x, n.y)).get("imp", "")) == rule.get("id"): cnt += 1
		"place_kind":
			var kinds = rule.get("id", [])
			for pl in db().places:
				if pl.get("kind") in kinds and SimHex.distance(Vector2i(int(pl.get("q", -99)), int(pl.get("r", -99))), p) <= 1: cnt += 1
		"natural_wonder":
			for n in nbrs:
				if db().wonder_at.has(SimHex.key(n.x, n.y)): cnt += 1
		"project":
			for pid in S().projects:
				if int(S().projects[pid].get("city", 0)) == c.id: cnt += 1
			cnt = mini(cnt, 2)
	return cnt


func adjacency_parts(c: SimCity, did: String, k: int) -> Array:
	## The adjacency bonus at k broken down by source (for the placement lens): [{src, id, count, amount}].
	var d = db().districts.get(did)
	if d == null:
		return []
	var p := SimHex.from_key(k)
	var nbrs := SimHex.neighbors(p.x, p.y)
	var out := []
	for rule in d.get("adjacency", []):
		var cnt := _rule_count(c, rule, k, p, nbrs)
		var per := int(rule.get("per", 1))
		var amt := float(int(cnt / per)) * float(rule.get("amount", 1))
		if amt != 0.0:
			out.append({"src": str(rule.get("src", "")), "id": rule.get("id", ""), "count": cnt, "per": per, "amount": amt})
	var gc := 0
	for n in nbrs:
		if str(tstate(SimHex.key(n.x, n.y)).get("d", "")) == "government_complex" and d.get("specialty", false):
			gc += 1
	if gc > 0:
		out.append({"src": "district", "id": "government_complex", "count": gc, "per": 1, "amount": float(gc)})
	var pct := mod_sum("adjacency_pct", "pct", "district", did)
	if pct != 0.0:
		out.append({"src": "policies", "id": "adjacency_pct", "pct": pct})
	return out


func district_lens(c: SimCity, did: String) -> Array:
	## Every tile of the city for the placement lens: [{q, r, valid, reason, adjacency, parts, appeal, terrain}].
	## Read-only: no state changes.
	var out := []
	for k in city_tile_keys(c):
		var p := SimHex.from_key(k)
		var why := district_ok(c, did, k)
		var row := {"q": p.x, "r": p.y, "valid": why == "", "reason": why, "appeal": appeal(k), "terrain": terrain(k), "feature": feature(k)}
		if why == "":
			row["adjacency"] = adjacency(c, did, k)
			row["parts"] = adjacency_parts(c, did, k)
		else:
			row["adjacency"] = 0.0
			row["parts"] = []
		out.append(row)
	out.sort_custom(func(a, b): return float(a["adjacency"]) > float(b["adjacency"]))
	return out


func district_ok(c: SimCity, did: String, k: int) -> String:
	## "" when the district can be placed at k, otherwise a reason.
	var d = db().districts.get(did)
	if d == null: return "unknown district"
	if c.has_district(did): return "already built"
	if db().wonder_at.has(k): return "natural wonder"
	if is_military_control(k): return "held under military control (no districts)"
	if d.get("one_per_empire", false):
		for cc in S().cities:
			if cc.has_district(did): return "one per nation"
			if cc != c:
				for qi in cc.queue:
					if qi["kind"] == "district" and qi["id"] == did: return "already being built in " + cc.name
	if d.get("specialty", false) and specialty_count(c) >= district_cap(c):
		return "district limit (population %d allows %d)" % [c.pop(), district_cap(c)]
	var ts := tstate(k)
	if int(ts.get("o", 0)) != c.id: return "tile not owned by city"
	if str(ts.get("d", "")) != "": return "tile has a district"
	if k == SimHex.key(c.q, c.r): return "city centre"
	var p := SimHex.from_key(k)
	if SimHex.distance(p, c.pos()) > 3: return "too far from centre"
	var terr := terrain(k)
	var pl: Dictionary = d.get("placement", {})
	if pl.get("water", false):
		if not (terr in ["coast", "ocean"]): return "must be on sea coast (no ports on lakes)"
		var near_land := false
		for n in SimHex.neighbors(p.x, p.y):
			if int(tstate(SimHex.key(n.x, n.y)).get("o", 0)) == c.id and not is_water(SimHex.key(n.x, n.y)): near_land = true
		if not near_land: return "must touch the city's land"
	else:
		if is_water(k) or terr == "mountains": return "needs a land tile"
	if resource(k) in LUXURIES or resource(k) in ["potash", "phosphates", "oil", "natural_gas", "copper"]:
		return "tile has a resource"
	var adj_cc := SimHex.distance(p, c.pos()) == 1
	if pl.get("adjacent_city_center", false) and not adj_cc: return "must be next to the city centre"
	if pl.get("not_adjacent_city_center", false) and adj_cc: return "cannot be next to the city centre"
	if pl.get("coastal_land", false) and not is_coastal(k): return "must be on the coast"
	if pl.get("flat", false) and terr in ["hills", "desert_hills"]: return "needs flat land"
	return ""


func district_sites(c: SimCity, did: String) -> Array:
	var out := []
	for k in city_tile_keys(c):
		if district_ok(c, did, k) == "":
			var p := SimHex.from_key(k)
			out.append({"q": p.x, "r": p.y, "adjacency": adjacency(c, did, k), "appeal": appeal(k)})
	out.sort_custom(func(a, b): return a["adjacency"] > b["adjacency"])
	return out


func appeal(k: int) -> int:
	var a := 0
	var p := SimHex.from_key(k)
	for n in SimHex.neighbors(p.x, p.y):
		var nk := SimHex.key(n.x, n.y)
		var terr := terrain(nk)
		if terr in ["mountains", "coast", "lake"] or feature(nk) == "forest": a += 1
		if db().wonder_at.has(nk): a += 2
		if terr == "marsh": a -= 1
		var dd := str(tstate(nk).get("d", ""))
		if dd != "" and int(db().districts.get(dd, {}).get("appeal", 0)) < 0: a -= 1
		var imp := str(tstate(nk).get("imp", ""))
		if imp != "" and int(db().improvements.get(imp, {}).get("appeal", 0)) < 0: a -= 1
	var t = db().tiles.get(k)
	if t != null and t.get("river", false): a += 1
	return a


func appeal_housing(k: int) -> float:
	var a := appeal(k)
	if a >= 4: return 6.0
	if a >= 2: return 5.0
	if a >= -1: return 4.0
	if a >= -3: return 3.0
	return 2.0


func compute_emitters() -> void:
	emitters.clear()
	for c in S().cities:
		if not c.active: continue
		for b in c.buildings:
			var bd = db().buildings.get(b)
			if bd == null: continue
			if bd.has("region_effect") or bd.has("region_amenity"):
				emitters.append({"pos": c.pos(), "id": b, "re": bd.get("region_effect", {}), "ra": bd.get("region_amenity", {}), "city": c.id})


func compute_city(c: SimCity) -> void:
	## Raw yields, housing and base amenities. Luxury and weariness allocation happen afterwards.
	var P := c.pop()
	var info := {}
	var y := {"food": 0.0, "production": 0.0, "gold": 0.0, "science": 0.0, "culture": 0.0, "cohesion": 0.0}
	var ck := SimHex.key(c.q, c.r)
	# city centre tile
	var cy := tile_yield(ck, c)
	cy["food"] = maxf(2.0, cy.get("food", 0.0)); cy["production"] = maxf(1.0, cy.get("production", 0.0))
	for kk in cy: y[kk] = y.get(kk, 0.0) + cy[kk]
	# worked tiles
	var cands := []
	var focus := c.focus
	for k in city_tile_keys(c):
		if k == ck or str(tstate(k).get("d", "")) != "" or terrain(k) == "mountains":
			continue
		var ty := tile_yield(k, c)
		cands.append([_tile_score(ty, focus), k, ty])
	cands.sort_custom(func(a, b): return a[0] > b[0])
	var uw := urban_worker_yield()
	var uw_score := _tile_score(uw, focus)
	var worked := []
	var food_need := 2.0 * P
	# citizen management (v2): tiles the player locked are worked first (Civ VI lock), then the governor's picks
	var locked_ok := []
	for cand in cands:
		if c.locked.has(cand[1]) and locked_ok.size() < P:
			locked_ok.append(cand[1])
			worked.append(cand[1])
			for kk in cand[2]: y[kk] = y.get(kk, 0.0) + cand[2][kk]
	for cand in cands:
		if worked.size() >= P:
			break
		if locked_ok.has(cand[1]):
			continue
		var s: float = cand[0]
		var fneeded: bool = y["food"] < food_need
		if s < uw_score and not (fneeded and cand[2].get("food", 0.0) >= 2.0):
			continue
		worked.append(cand[1])
		for kk in cand[2]: y[kk] = y.get(kk, 0.0) + cand[2][kk]
	var unemployed := P - worked.size()
	# specialists
	var spec_slots := 0
	var spec_y := {}
	for did in c.districts:
		var d = db().districts.get(did)
		if d == null or d.get("specialist") == null: continue
		var nb := 0
		for b in c.buildings:
			if db().buildings.get(b, {}).get("district") == did: nb += 1
		var slots := mini(3, nb)
		var use := mini(slots, unemployed - spec_slots)
		if use > 0:
			for kk in d["specialist"]:
				spec_y[kk] = spec_y.get(kk, 0.0) + float(d["specialist"][kk]) * use
			spec_slots += use
	for kk in spec_y: y[kk] = y.get(kk, 0.0) + spec_y[kk]
	var urban := unemployed - spec_slots
	for kk in uw: y[kk] = y.get(kk, 0.0) + uw[kk] * urban
	# per population
	y["science"] += 0.5 * P
	y["culture"] += 0.3 * P
	# buildings
	var housing := 0.0
	var amen := c.legacy_amenities
	var growth_pct := 0.0
	var trust_b := 0.0
	var water_local := 0.0
	var defense := 0.0
	for b in c.buildings:
		var bd = db().buildings.get(b)
		if bd == null: continue
		for kk in bd.get("yields", {}): y[kk] = y.get(kk, 0.0) + float(bd["yields"][kk])
		housing += float(bd.get("housing", 0)); amen += float(bd.get("amenities", 0))
		growth_pct += float(bd.get("growth_pct", 0)); trust_b += float(bd.get("trust", 0))
		water_local += float(bd.get("water_supply", 0)); defense += float(bd.get("defense", 0))
	# districts
	for did in c.districts:
		var d = db().districts.get(did)
		if d == null: continue
		var yt := str(d.get("yield_type", ""))
		if yt in YIELDS:
			y[yt] = y.get(yt, 0.0) + adjacency(c, did, int(c.districts[did]))
		if did == "housing_project":
			housing += appeal_housing(int(c.districts[did]))
		housing += float(d.get("housing", 0))
		y["science"] += float(d.get("science", 0))
		water_local += float(d.get("water_supply", 0))
		if d.get("specialty", false): defense += 2.0
	# water housing
	var fresh := has_fresh_water(ck)
	var base_h := 5.0 if fresh else (3.0 if is_coastal(ck) else 2.0)
	if c.has_district("water_connection"):
		base_h = base_h + 2.0 if fresh else 6.0
	housing += base_h + c.legacy_housing
	# improvements on city tiles
	var farm_n := 0
	for k in city_tile_keys(c):
		var imp := str(tstate(k).get("imp", ""))
		if imp != "":
			housing += float(db().improvements.get(imp, {}).get("housing", 0))
			if imp in FARM_TYPES: farm_n += 1
	info["farms"] = farm_n
	# capital (palace)
	if c.key == S().capital:
		y["production"] += 2; y["science"] += 2; y["culture"] += 1; y["gold"] += 5
		housing += 1; amen += 2
		defense += 3
	# region effects (factory / power: strongest one of each type within radius)
	var best_re := {}
	for e in emitters:
		var re: Dictionary = e["re"]
		if not re.is_empty() and SimHex.distance(e["pos"], c.pos()) <= int(re.get("radius", 6)):
			var cur: float = best_re.get(e["id"], -1.0)
			if cur < 0: best_re[e["id"]] = 1.0
		var ra: Dictionary = e["ra"]
		if not ra.is_empty() and SimHex.distance(e["pos"], c.pos()) <= int(ra.get("radius", 6)):
			best_re["amen:" + str(e["id"])] = float(ra.get("amount", 1))
	for bid in best_re:
		if str(bid).begins_with("amen:"):
			amen += best_re[bid]
		else:
			for kk in db().buildings[bid]["region_effect"].get("yields", {}):
				if not c.has_building(bid):
					y[kk] = y.get(kk, 0.0) + float(db().buildings[bid]["region_effect"]["yields"][kk])
	# national projects located here
	for pid in S().projects:
		if int(S().projects[pid].get("city", 0)) == c.id:
			for e in db().projects.get(pid, {}).get("effects", []):
				if e.get("type") == "city_yield_here":
					y[e["yield"]] = y.get(e["yield"], 0.0) + float(e.get("amount", 0))
	# policy / ministry flat effects
	for e in mods:
		var ty := str(e.get("type", ""))
		if e.has("city") and int(e["city"]) != c.id: continue
		if not cond_ok(e.get("cond"), c): continue
		match ty:
			"city_yield": y[e["yield"]] = y.get(e["yield"], 0.0) + float(e.get("amount", 0))
			"per_building":
				if c.has_building(str(e.get("building"))): y[e["yield"]] = y.get(e["yield"], 0.0) + float(e.get("amount", 0))
			"per_district":
				if c.has_district(str(e.get("district"))): y[e["yield"]] = y.get(e["yield"], 0.0) + float(e.get("amount", 0))
			"per_improvement":
				for k in city_tile_keys(c):
					if str(tstate(k).get("imp", "")) == e.get("improvement"): y[e["yield"]] = y.get(e["yield"], 0.0) + float(e.get("amount", 0))
			"housing", "housing_city": housing += float(e.get("amount", 0))
			"amenity", "amenity_city", "amenity_national": amen += float(e.get("amount", 0))
			"growth_pct", "growth_pct_city": growth_pct += float(e.get("pct", 0))
			"trust": trust_b += float(e.get("amount", 0))
			"city_defense": defense += float(e.get("amount", 0))
	# kibbutz cohesion
	for k in city_tile_keys(c):
		var imp2 := str(tstate(k).get("imp", ""))
		if imp2 != "":
			y["cohesion"] += float(db().improvements.get(imp2, {}).get("cohesion", 0))
	# trade routes from this city
	for tr in S().trade_routes:
		if int(tr.get("from", 0)) == c.id:
			y["gold"] += sim.trade_route_gold(tr)
	# transit camps (residents beyond housing capacity)
	var cap := housing * housing * 1000.0
	var transit := maxf(maxf(0.0, c.residents - cap), minf(c.camp, c.residents))
	var tshare := transit / maxf(1.0, c.residents)
	amen -= minf(3.0, floor(tshare / 0.08))
	info["housing"] = housing
	info["transit"] = transit
	info["shortfall_label"] = "in transit camps (ma'abarot)" if SimDB.year_f(S().turn) < 1965.0 else ("in caravan sites and temporary housing" if SimDB.year_f(S().turn) >= 1990.0 and SimDB.year_f(S().turn) < 1997.0 else "in overcrowded or temporary housing")
	info["transit_share"] = tshare
	info["amen_sources"] = amen
	info["amen_required"] = ceil(P / 2.0)
	info["growth_pct"] = growth_pct
	info["trust_b"] = trust_b
	info["water_local"] = water_local
	info["defense"] = defense
	info["worked"] = worked
	info["locked"] = locked_ok
	info["urban"] = urban
	info["specialists"] = spec_slots
	info["fresh"] = fresh
	c.y = y
	c.info = info


func allocate_amenities() -> void:
	## Luxuries (+1 to up to 4 cities each, MECHANICS 3.3) and empire-wide war weariness
	## (-1 per 400 points, largest and nearest-front cities first, capped at 2 per city).
	var lux := {}
	for c in S().cities:
		if not c.active: continue
		for k in city_tile_keys(c):
			var res := resource(k)
			if res in LUXURIES and str(tstate(k).get("imp", "")) in ["grove", "mine_minerals"]:
				lux[res] = true
	var cities_sorted: Array = S().cities.filter(func(c): return c.active)
	for res in lux:
		cities_sorted.sort_custom(func(a, b): return (a.info["amen_sources"] - a.info["amen_required"]) < (b.info["amen_sources"] - b.info["amen_required"]))
		for i in range(mini(4, cities_sorted.size())):
			cities_sorted[i].info["amen_sources"] += 1.0
	var ww := int(floor(S().war_weariness * (1.0 + sim.econ.mod_sum("war_weariness_pct", "pct") / 100.0) / 400.0))
	if ww > 0:
		var fronts: Array = sim.military.front_positions()
		var order: Array = S().cities.filter(func(c): return c.active)
		order.sort_custom(func(a, b): return _ww_score(a, fronts) > _ww_score(b, fronts))
		var given := {}
		var i := 0
		while ww > 0 and order.size() > 0 and i < order.size() * 2:
			var c = order[i % order.size()]
			if int(given.get(c.id, 0)) < 2:
				given[c.id] = int(given.get(c.id, 0)) + 1
				c.info["amen_sources"] -= 1.0
				c.info["weariness"] = given[c.id]
				ww -= 1
			i += 1
	var gold_pen := 1.0 if S().gold < 0 else 0.0
	var water_pen := 1.0 if float(S().water.get("ratio", 1.0)) < 0.85 else 0.0
	if float(S().water.get("reserve", 70.0)) < 20.0: water_pen += 1.0
	var infl_pen := 1.0 if S().inflation > 50.0 else 0.0
	for c in S().cities:
		if not c.active: continue
		c.info["amen_sources"] -= gold_pen + water_pen + infl_pen
		var bal: float = c.info["amen_sources"] - c.info["amen_required"]
		c.info["amenity_balance"] = bal
		var st: Array = AMENITY_STATES[AMENITY_STATES.size() - 1]
		for s in AMENITY_STATES:
			if bal >= s[0]:
				st = s; break
		c.info["amenity_state"] = st[1]
		c.info["amenity_yield_pct"] = st[2]
		c.info["amenity_growth_pct"] = st[3]
		c.info["amenity_trust"] = st[4]


func _ww_score(c: SimCity, fronts: Array) -> float:
	var d := 50.0
	for f in fronts:
		d = minf(d, SimHex.distance(c.pos(), f))
	return c.pop() - 0.3 * d


func trust_band(t: float) -> Array:
	## Civic Trust bands (approved design: Civ VI loyalty bands). [name, yield %, growth %]
	if t >= 76: return ["confident", 0, 0]
	if t >= 51: return ["wavering", -25, -10]
	if t >= 26: return ["distrustful", -50, -40]
	return ["alienated", -75, -100]


func finalize_city(c: SimCity) -> void:
	## Apply amenity and trust percentage modifiers to non-food yields.
	var band := trust_band(c.trust)
	c.info["trust_band"] = band[0]
	var pct := float(c.info.get("amenity_yield_pct", 0)) + float(band[1])
	for kk in ["production", "gold", "science", "culture", "cohesion"]:
		var local_pct := pct
		for e in mods:
			if e.get("type") in ["yield_pct_city"] and int(e.get("city", -1)) == c.id and e.get("yield") == kk:
				local_pct += float(e.get("pct", 0))
			if e.get("type") == "prod_pct_city" and kk == "production" and cond_ok(e.get("cond"), c):
				local_pct += float(e.get("pct", 0))
		c.y[kk] = maxf(0.0, c.y[kk] * (1.0 + local_pct / 100.0))
	if c.damaged > 0:
		c.y["production"] *= 0.6
	c.info["yield_pct"] = pct


# ------------------------------------------------------------------ trust

const TRUST_BASELINE := 80.0   # where trust settles with no investment and no pressure (just "confident")


func trust_pressure() -> float:
	## National pressure on every city's trust: inflation, ongoing crises and war weariness.
	var p := -clampf(1.2 * log(1.0 + maxf(0.0, S().inflation) / 100.0) - 0.15, 0.0, 2.0)
	for cr in S().crises:
		if cr.get("active", true): p -= 0.8
	p -= minf(2.0, S().war_weariness / 600.0)
	p += sim.stream_sum("trust")
	return p


func update_trust(c: SimCity) -> void:
	## Trust drifts back to a baseline. Gains (amenities, services, ministries) shrink as trust nears 100,
	## so it takes continued investment to stay "confident"; losses apply in full.
	var pos := 0.0; var neg := 0.0
	var am := float(c.info.get("amenity_trust", 0)) * 0.5
	var tb := float(c.info.get("trust_b", 0))
	for v in [am, tb]:
		if v > 0: pos += v
		else: neg += v
	for mid in S().ministries:
		if int(S().ministries[mid].get("city", 0)) == c.id:
			pos += 4.0
	var ts: float = c.info.get("transit_share", 0.0)
	neg -= minf(4.0, floor(ts / 0.05) * 0.5)
	if c.damaged > 0:
		neg -= 2.0
	if c.has_building("maabara"):
		neg -= 2.0
	# equality of investment: buildings per population vs national average
	var avg: float = sim.avg_buildings_per_pop
	if avg > 0 and float(c.buildings.size()) / c.pop() < avg * 0.4 and c.pop() >= 3:
		neg -= 1.0
	var base := TRUST_BASELINE + trust_base_offset(c) + float(S().counters.get("trust_player", 0.0))
	var pos_eff := pos * clampf((100.0 - c.trust) / 30.0, 0.0, 1.5)
	var press := trust_pressure()
	var pull := (base - c.trust) * 0.07
	var d := pos_eff + neg + press + pull
	var neg_label := "transit camps, damage and unequal investment" if SimDB.year_f(S().turn) < 1965.0 else "overcrowded housing, damage and unequal investment"
	c.info["trust_parts"] = {"services, amenities and ministries": pos_eff, neg_label: neg,
		"national pressure (inflation, crises, war weariness, per-turn terms)": press, "return toward the baseline (incl. your lasting terms)": pull}
	c.trust = clampf(c.trust + clampf(d, -10.0, 10.0), 0.0, 100.0)
	c.info["trust_delta"] = d


# ------------------------------------------------------------------ growth

func housing_factor(c: SimCity) -> float:
	var pf := sqrt(maxf(c.residents, 0.0) / 1000.0)
	var diff: float = c.info.get("housing", pf) - pf
	if diff >= 2.0: return 1.0
	if diff >= 1.0: return 0.85
	if diff >= -4.0: return 0.7
	return 0.5


func growth_multiplier(c: SimCity) -> float:
	var m := housing_factor(c)
	m *= 1.0 + float(c.info.get("amenity_growth_pct", 0)) / 100.0
	m *= 1.0 + float(trust_band(c.trust)[2]) / 100.0
	m *= 1.0 + float(c.info.get("growth_pct", 0)) / 100.0
	var ff := 1.0
	if food_ratio < 1.0:
		ff = 0.6 + 0.4 * food_ratio
	else:
		var surplus: float = c.y.get("food", 0.0) - 2.0 * c.pop()
		ff = 1.0 + clampf(surplus / maxf(1.0, c.pop()) * 0.05, 0.0, 0.1)
	m *= ff
	if c.damaged > 0:
		m *= 0.5
	return clampf(m, 0.0, 1.2)


func grow_city(c: SimCity) -> float:
	var year := SimDB.year_of(S().turn)
	var m := growth_multiplier(c)
	c.info["growth_mult"] = m
	var d := c.residents * nat_rate(year) / 4.0 * m / GROWTH_REF
	c.residents = maxf(300.0, c.residents + d)
	return d


func turns_to_grow(c: SimCity) -> int:
	var next := pow(c.pop() + 0.5, 2) * 1000.0
	var rate := c.residents * nat_rate(SimDB.year_of(S().turn)) / 4.0 * float(c.info.get("growth_mult", 1.0)) / GROWTH_REF
	if rate <= 0.0:
		return -1
	return int(ceil((next - c.residents) / rate))


func rural_capacity() -> float:
	var cap := float(S().counters.get("rural_base", 150000.0))
	for k in S().tiles:
		var imp := str(S().tiles[k].get("imp", ""))
		if imp != "":
			cap += float(db().improvements.get(imp, {}).get("rural_capacity", 0))
			if imp in ["farm", "drip_farm"]: cap += 400.0
	return cap


func grow_rural(avg_mult: float) -> float:
	var d := S().rural * nat_rate(SimDB.year_of(S().turn)) / 4.0 * avg_mult / GROWTH_REF
	var cap := rural_capacity()
	if S().rural > cap:
		d *= 0.5
	S().rural += d
	return d


# ------------------------------------------------------------------ immigration (fixed rails: CBS totals arrive; placement is the player's)

func retention() -> float:
	var r := 0.97 + mod_sum("retention", "pct") / 100.0
	var tot := 0.0; var tr := 0.0
	for c in S().cities:
		if c.active:
			tot += c.residents; tr += float(c.info.get("transit", 0.0))
	if tot > 0:
		r -= 0.4 * (tr / tot)
	return clampf(r, 0.8, 1.0)


# ------------------------------------------------------------------ immigration placement (a decision each heavy quarter)
# The national total is a rail (CBS, S276). Where the arrivals go is the player's choice, with costs:
#   cities    - the large cities (population 10+): jobs at hand, moderate absorption cost; needs housing there
#   dev_towns - development towns (small towns): absorption grants and new infrastructure; few jobs at first
#   villages  - new moshavim and kibbutzim: land, water and farm credit; feeds the country, uses water
#   camps     - transit camps (ma'abarot) wherever there is room: cheapest now, but residents beyond
#               housing leave a lasting transit-camp share that costs trust and growth until housing is built

const IMM_THRESHOLD := 10000.0  # arrivals per quarter that make placement a decision (the mass-immigration waves)
const ABSORPTION_QUARTERS := 8  # newcomers draw on welfare and services for about two years
const ABSORPTION_UPKEEP := 0.13 # gold per quarter per 1,000 newcomers of the last two years
const IMM_OPTIONS := ["cities", "dev_towns", "villages", "camps"]
const IMM_COST := {"cities": 1.0, "dev_towns": 1.8, "villages": 2.6, "camps": 0.3, "": 1.0}   # gold per 1,000 arrivals


func expected_arrivals() -> float:
	var year := SimDB.year_of(S().turn)
	var quarters := 3.0 if year == 1948 else 4.0
	var total := db().immigration_in_year(mini(year, SimDB.end_year())) / quarters
	return total * retention()


func _imm_group(c: SimCity, option: String) -> bool:
	if not c.active or c.kind in ["kibbutz", "moshav"] or c.kind in NON_JEWISH_KINDS:
		return false
	match option:
		"cities": return c.pop() >= 10
		"dev_towns": return c.pop() <= 9
	return true


func _housing_room(c: SimCity) -> float:
	var h := float(c.info.get("housing", 0.0))
	return maxf(0.0, h * h * 1000.0 - c.residents)


func _housing_room_net(c: SimCity) -> float:
	## Housing room not already promised to camp residents.
	var h := float(c.info.get("housing", 0.0))
	return maxf(0.0, h * h * 1000.0 - (c.residents - c.camp))


## Placement options vary by era and by wave (fix-cabinet, V2_FIXES A4). Each variant places arrivals through one
## of four base patterns (cities, dev_towns, villages, camps; see immigration_quarter) and may add its own terms
## for the plan's four quarters (temp effects). "hist" gives the years in which it was what the governments of
## the day did (the "historical" tag); "wave" restricts a variant to a named wave (substring of its title).
const IMM_VARIANTS := [
	{"id": "cities", "base": "cities", "from": 1948, "until": 1952, "hist": [1948, 1949],
		"label": "Settle them in the large cities", "text": "Jobs are at hand; housing is the limit.", "eff": "output grows fastest"},
	{"id": "camps", "base": "camps", "from": 1948, "until": 1964, "hist": [1950, 1952],
		"label": "House them in transit camps (ma'abarot)", "text": "Tents and tin huts next to existing towns: cheapest now, but families stay in the camps until housing is built, costing trust and growth.", "eff": "lasting transit-camp share"},
	{"id": "villages", "base": "villages", "from": 1948, "until": 1957, "hist": [1953, 1957],
		"label": "From the ship to a village: new moshavim", "text": "Families go straight from the port to new farming villages with land, water and farm credit. More food, more water demand.", "eff": "more food, more water demand"},
	{"id": "dev_towns", "base": "dev_towns", "from": 1953, "until": 1967, "hist": [1954, 1967],
		"label": "Development towns in the Negev and the Galilee", "text": "New towns with absorption grants and new infrastructure; jobs come later.", "eff": "Readiness +1 (population dispersal); periphery trust at risk"},
	{"id": "planned_region", "base": "dev_towns", "from": 1954, "until": 1964,
		"label": "A planned region: villages around a new rural town", "text": "A regional town with schools, clinics and packing plants serves the new villages around it.", "eff": "periphery growth +2% for a year",
		"terms": [{"type": "growth_pct", "pct": 2, "cond": {"periphery": true}}], "cost": 2.1},
	{"id": "cities_b", "base": "cities", "from": 1953, "until": 1967,
		"label": "Let them settle in the large cities", "text": "Most newcomers want the centre, where the jobs are.", "eff": "output grows fastest"},
	{"id": "youth_kibbutz", "base": "villages", "from": 1958, "until": 1988,
		"label": "Young immigrants to kibbutzim and youth villages", "text": "Teenagers and young adults study and work in kibbutzim and youth villages; families follow to the towns.", "eff": "+0.3 Cohesion per turn for a year",
		"terms": [{"type": "cohesion_per_turn", "amount": 0.3}], "cost": 2.0},
	{"id": "absorption_centres", "base": "cities", "from": 1968, "until": 1988, "hist": [1968, 1988],
		"label": "Absorption centres in the cities", "text": "Six months of housing, Hebrew classes and job placement in the large cities.", "eff": "+1% retention for a year",
		"terms": [{"type": "retention", "pct": 1}], "cost": 1.3},
	{"id": "periphery_grants", "base": "dev_towns", "from": 1968, "until": 2023,
		"label": "Housing grants for the Negev and the Galilee", "text": "Cheap mortgages and rent help for newcomers who settle in the periphery towns.", "eff": "+0.5 Civic Trust in the periphery for a year; periphery trust at risk where there are no jobs",
		"terms": [{"type": "trust", "amount": 0.5, "cond": {"periphery": true}}]},
	{"id": "community_villages", "base": "villages", "from": 1968, "until": 2023,
		"label": "Community villages and moshavim", "text": "Small hilltop and valley communities with land for houses; a minority of newcomers choose them.", "eff": "more food, more water demand"},
	{"id": "professionals", "base": "cities", "from": 1970, "until": 1988,
		"label": "A programme for immigrant engineers and scientists", "text": "Retraining, licences and research posts for academics among the newcomers.", "eff": "+3% Science for a year",
		"terms": [{"type": "yield_pct", "yield": "science", "pct": 3}], "cost": 1.7},
	{"id": "absorption_sites", "base": "camps", "from": 1984, "until": 1993, "wave": ["Moses", "Solomon", "Ethiopia"],
		"label": "Long stays in absorption centres and mobile-home sites", "text": "Families stay together in absorption centres and caravan sites while housing is found; quick, but it keeps them apart for years.", "eff": "lasting caravan-site share"},
	{"id": "caravans", "base": "camps", "from": 1990, "until": 1994, "hist": [1990, 1991],
		"label": "Caravan sites until permanent housing is built", "text": "Mobile homes on the edge of towns: quick and cheap, but families live in caravans for years.", "eff": "lasting caravan-site share"},
	{"id": "direct_absorption", "base": "cities", "from": 1989, "until": 2023, "hist": [1989, 2023],
		"label": "Direct absorption: an absorption basket, families choose", "text": "Each family gets a basket of grants and chooses where to live; most choose the centre.", "eff": "output grows fastest"},
	{"id": "scientists", "base": "cities", "from": 1989, "until": 1999,
		"label": "Research posts for immigrant scientists", "text": "State-funded posts in universities and incubators for the scientists and engineers of the wave.", "eff": "+4% Science for a year",
		"terms": [{"type": "yield_pct", "yield": "science", "pct": 4}], "cost": 1.8},
	{"id": "employment_first", "base": "cities", "from": 2000, "until": 2023,
		"label": "Jobs first: placement in their professions", "text": "Employers are paid to hire newcomers in their own professions from the first year.", "eff": "+2% Production and +1% retention for a year",
		"terms": [{"type": "yield_pct", "yield": "production", "pct": 2}, {"type": "retention", "pct": 1}], "cost": 1.5},
]


func _variant(id: String) -> Dictionary:
	for v in IMM_VARIANTS:
		if str(v["id"]) == id:
			return v
	return {}


func _fmt_n(n: float) -> String:
	var s := str(int(round(absf(n))))
	var out := ""
	while s.length() > 3:
		out = "," + s.substr(s.length() - 3) + out
		s = s.substr(0, s.length() - 3)
	return ("-" if n < -0.5 else "") + s + out


func immigration_options_allowed() -> Array:
	## Variant ids on offer this year (era, and named waves for the wave-only variants).
	var y := SimDB.year_of(S().turn)
	var wave := immigration_wave()
	var out := []
	for v in IMM_VARIANTS:
		if y < int(v["from"]) or y > int(v["until"]):
			continue
		if v.has("wave"):
			var hit := false
			for w in v["wave"]:
				if wave.contains(str(w)): hit = true
			if not hit: continue
		out.append(str(v["id"]))
	return out


func immigration_options() -> Array:
	## Placement options for this year's arrivals with their visible costs (for the UI and the AI).
	var a := expected_arrivals()
	var out := []
	var hist := historical_immigration_choice()
	for vid in immigration_options_allowed():
		var v := _variant(vid)
		var o := str(v["base"])
		var room := 0.0; var n := 0; var no_jobs := 0
		for c in S().cities:
			if _imm_group(c, o if o != "camps" else ""):
				room += _housing_room(c); n += 1
				if o == "dev_towns" and not (c.has_district("industrial_park") or c.has_district("port")): no_jobs += 1
		var placed := a * (0.35 if o == "villages" else 1.0)
		var gold := -a / 1000.0 * float(v.get("cost", IMM_COST[o]))
		var in_camps := placed * 0.9 if o == "camps" else maxf(0.0, placed - room)
		var d := {"id": vid, "base": o, "gold": int(round(gold)), "arrivals": int(a), "towns": n, "housing_room": int(room),
			"camp_residents": int(in_camps), "label": str(v["label"]), "historical": vid == hist, "default": false}
		var htxt := ""
		if o == "camps":
			htxt = " About %s people will live in temporary housing until homes are built." % _fmt_n(in_camps)
		elif room >= placed * 4.0:
			htxt = " Housing is not the constraint: there is room for this year's arrivals."
		elif room >= placed:
			htxt = " Housing room is tight but enough for this year's arrivals."
		else:
			htxt = " Housing room for about %s of the %s arrivals a quarter; the rest crowd into temporary housing." % [_fmt_n(room), _fmt_n(placed)]
		var extra := ""
		if o == "dev_towns" and no_jobs > 0:
			extra = " %d of the %d towns have no industrial district yet: trust there falls until jobs arrive." % [no_jobs, n]
		d["text"] = str(v["text"]) + htxt + extra
		d["effects"] = "Gold %s now; %s" % [_fmt_n(d["gold"]), str(v.get("eff", ""))]
		var terms: Array = v.get("terms", [])
		d["terms"] = terms
		d["effects_list"] = [{"stat": "gold", "amount": d["gold"], "unit": "gold", "label": "%s Gold now" % _fmt_n(d["gold"]), "good": false}] + (sim.cabinet.effect_lines(terms) if sim.cabinet != null else [])
		out.append(d)
	var rec := recommended_immigration(out)
	for d2 in out:
		d2["default"] = str(d2["id"]) == rec
	return out


func recommended_immigration(opts: Array = []) -> String:
	## The Recommended placement: weighs cost against the treasury, people left in camps, readiness and the
	## periphery, food and water, science against history, and what the last plans already did.
	if opts.is_empty():
		opts = immigration_options()
	var st := S()
	var gold: float = st.gold
	var net := float(st.counters.get("last_budget", {}).get("net", 0.0))
	var recent: Array = st.counters.get("imm_recent", [])
	var nat: Dictionary = sim.national()
	var food_need := float(nat.get("food_need", 0.0)) - float(nat.get("food", 0.0))
	var sci_ratio: float = sim.cabinet._science_ratio() if sim.cabinet != null else 1.0
	var best := ""; var bs := -1e9
	for o in opts:
		var cost := -float(o["gold"])
		var s := -cost * (2.0 if gold - cost < 50.0 or net < 0.0 else 0.6)
		s -= float(o["camp_residents"]) / 1000.0 * 2.5
		match str(o["base"]):
			"dev_towns": s += 8.0 if st.readiness < 60 else 3.0
			"villages":
				s += (10.0 if food_need > 0 else 2.0)
				if float(st.water.get("ratio", 1.0)) < 1.05: s -= 12.0
			"cities": s += 6.0
		for e in o.get("terms", []):
			match str(e.get("type", "")):
				"yield_pct": s += float(e.get("pct", 0)) * (2.5 if sci_ratio < 1.0 and str(e.get("yield", "")) == "science" else 1.2)
				"retention": s += float(e.get("pct", 0)) * 2.0
				"trust", "cohesion_per_turn": s += float(e.get("amount", 0)) * 6.0
				"growth_pct": s += float(e.get("pct", 0)) * 1.5
		s -= 4.0 * float(recent.count(str(o["id"])))
		if s > bs:
			bs = s; best = str(o["id"])
	return best



const IMM_YEARLY_MIN := 5500.0   # arrivals per quarter below which placement is left to the market (no question asked)

func immigration_decision_due() -> bool:
	## Once a year (the plan holds for 4 quarters), or again when a named immigration wave begins.
	var st := S()
	var last := int(st.immigration_plan.get("turn", -99))
	if last == st.turn or expected_arrivals() < IMM_YEARLY_MIN:
		return false
	if st.turn - last >= 4:
		return true
	# a named wave re-opens the plan, but not one or two quarters after the yearly plan (e.g. Q1 1991 plan,
	# then Operation Solomon in Q2 1991): the wave is folded into the plan already made
	if st.turn - last < 3:
		if immigration_wave() != "": st.immigration_plan["wave"] = immigration_wave()
		return false
	return immigration_wave() != "" and str(st.immigration_plan.get("wave", "")) != immigration_wave()


func immigration_wave() -> String:
	## The title of a named immigration event active this quarter ("" if none).
	for eid in S().fired_events:
		var ev = db().event_by_id.get(eid)
		if ev == null or not ev["effects"].has("aliyah"):
			continue
		var t0: int = ev["_turn"]
		var t1: int = maxi(int(ev["_end_turn"]), t0)
		if S().turn >= t0 and S().turn <= t1 and S().turn - t0 < 8:
			return str(ev.get("title", eid))
	return ""


func historical_immigration_choice() -> String:
	## What the governments of the day did (ma'abarot 1950-52, "from ship to village" 1953-57, development
	## towns 1954-67, absorption centres from 1968, direct absorption and caravan sites in the 1990s).
	var y := SimDB.year_of(S().turn)
	var allowed := immigration_options_allowed()
	for v in IMM_VARIANTS:
		if not v.has("hist") or not (str(v["id"]) in allowed):
			continue
		if y >= int(v["hist"][0]) and y <= int(v["hist"][1]):
			if str(v["id"]) == "villages" and y >= 1954 and y % 2 == 0 and "dev_towns" in allowed:
				return "dev_towns"   # 1953-57 alternated between the villages and the new towns
			return str(v["id"])
	return allowed[0] if not allowed.is_empty() else "cities"


func choose_immigration(option: String) -> bool:
	var allowed := immigration_options_allowed()
	if not (option in allowed):
		# a base pattern id (older callers): the first variant of that pattern on offer
		var found := ""
		for vid in allowed:
			if str(_variant(vid).get("base", "")) == option and found == "": found = vid
		if found == "":
			return false
		option = found
	var v := _variant(option)
	var st := S()
	var rec_now := recommended_immigration()
	st.immigration_plan = {"turn": st.turn, "option": str(v["base"]), "variant": option, "wave": immigration_wave()}
	for e in v.get("terms", []):
		var te: Dictionary = e.duplicate()
		te["until"] = st.turn + 3
		te["src"] = "immigration:" + option
		st.temp_effects.append(te)
	var recent: Array = st.counters.get("imm_recent", [])
	recent.append(option)
	st.counters["imm_recent"] = recent.slice(maxi(0, recent.size() - 3))
	var ih: Array = st.counters.get("imm_history", [])
	ih.append({"turn": st.turn, "id": option, "base": str(v["base"]), "recommended": rec_now, "historical": historical_immigration_choice()})
	st.counters["imm_history"] = ih
	st.counters["imm_variant_" + option] = int(st.counters.get("imm_variant_" + option, 0)) + 1
	return true


func immigration_quarter(directed: Array) -> Dictionary:
	## directed: [{cities:[SimCity], amount}] from aliyah events this quarter.
	var year := SimDB.year_of(S().turn)
	var q := S().turn
	var quarters := 3.0 if year == 1948 else 4.0
	var total := db().immigration_in_year(year) / quarters
	if year > SimDB.end_year():
		total = db().immigration_in_year(SimDB.end_year()) / 4.0
	var ret := retention()
	var arriving := total * ret
	var placed := 0.0
	var dir_total := 0.0
	for d in directed:
		dir_total += float(d["amount"])
	var scale := 1.0 if dir_total <= arriving * 0.85 else arriving * 0.85 / maxf(1.0, dir_total)
	var report := {"total": total, "retention": ret, "arrived": arriving, "to_cities": {}, "rural": 0.0}
	for d in directed:
		var cs: Array = d["cities"]
		if cs.is_empty(): continue
		var each := float(d["amount"]) * scale / cs.size()
		for c in cs:
			c.residents += each; c.immigrants += each; placed += each
			report["to_cities"][c.key] = report["to_cities"].get(c.key, 0.0) + each
	var plan := str(S().immigration_plan.get("option", "")) if S().turn - int(S().immigration_plan.get("turn", -99)) < 4 else ""
	report["plan"] = plan
	report["absorption_cost"] = (arriving / 1000.0) * float(_variant(str(S().immigration_plan.get("variant", ""))).get("cost", IMM_COST.get(plan, 1.0))) if plan != "" else (arriving / 1000.0) * float(IMM_COST.get(plan, 1.0))
	# camps empty slowly as housing room appears (and a few families find their own way)
	for c in S().cities:
		if c.active and c.camp > 0.0:
			c.camp = maxf(0.0, c.camp - _housing_room_net(c) * 0.5 - c.camp * 0.03)
	var rest := maxf(0.0, arriving - placed)
	if plan == "villages":
		var vil := rest * 0.65
		S().rural += vil
		S().counters["rural_base"] = float(S().counters.get("rural_base", 0.0)) + vil * 0.9
		report["rural"] = vil
		rest -= vil
	elif plan == "dev_towns":
		S().counters["dispersal_readiness"] = minf(8.0, float(S().counters.get("dispersal_readiness", 0.0)) + 1.0)
	# internal migration: a share of transit-camp residents move on to places with housing
	var moved := 0.0
	for c in S().cities:
		if c.active and float(c.info.get("transit", 0.0)) > 0.0:
			var m := float(c.info["transit"]) * 0.10
			c.residents -= m
			moved += m
	for c in S().cities:
		if not c.active:
			continue
		var land := 0
		for k in city_tile_keys(c):
			if not is_water(k): land += 1
		var land_cap := 60000.0 + 32000.0 * land
		var ct := census_target(c, SimDB.year_f(S().turn))
		if c.residents > land_cap and ct <= 0.0:
			var mv: float = (c.residents - land_cap) * 0.04
			c.residents -= mv
			moved += mv
		elif ct > 0.0 and c.residents > ct * 1.1:
			# suburbanisation: a built-up city whose census population stopped growing (Tel Aviv from the 1960s)
			# sends households to the towns around it
			var mv2: float = (c.residents - ct * 1.1) * 0.08
			c.residents -= mv2
			moved += mv2
	rest += moved
	report["internal_migration"] = moved
	# rural share (moshavim and other villages)
	if plan == "":
		var cap := rural_capacity()
		var rshare := clampf((cap - S().rural) / maxf(1.0, cap) * 1.5, 0.03, 0.35)
		var to_rural := rest * rshare
		S().rural += to_rural
		report["rural"] = to_rural
		rest -= to_rural
	var weights := {}
	var wsum := 0.0
	var small_w := mod_sum("immigrant_weight", "pct", "target", "small_towns")
	var large_w := mod_sum("immigrant_weight", "pct", "target", "large_cities")
	var yf := SimDB.year_f(S().turn)
	for c in S().cities:
		if not c.active or c.kind in ["kibbutz", "moshav"] or c.kind in NON_JEWISH_KINDS:
			continue
		# historical share: where the census says the country grew next year, scaled by local conditions
		if plan in ["cities", "dev_towns"] and not _imm_group(c, plan):
			continue
		var tg := census_target(c, yf)
		var w := 0.0
		if plan == "camps":
			w = sqrt(c.residents) * 100.0   # camps went up beside towns all over the country
		elif tg > 0.0:
			w = (maxf(0.0, census_target(c, yf + 1.0) - tg) + 0.01 * tg) * attract_factor(c)
		else:
			w = 0.01 * c.residents * attract_factor(c)
		var cw := 0.0
		for b in c.buildings:
			cw += float(db().buildings.get(b, {}).get("immigrant_weight", 0))
		for e in mods:
			if e.get("type") == "immigrant_weight_city" and int(e.get("city", 0)) == c.id: cw += float(e.get("pct", 0))
		if c.pop() <= 6: cw += small_w
		if c.pop() >= 12: cw += large_w
		w *= 1.0 + cw / 100.0
		weights[c.id] = maxf(0.01, w)
		wsum += weights[c.id]
	# placement by weight; what a town cannot absorb this quarter (6% of its residents) goes to the
	# other towns by weight, then to the countryside
	var room := {}
	for c in S().cities:
		if weights.has(c.id):
			room[c.id] = maxf(2500.0, c.residents * (0.15 if plan == "camps" else (0.10 if plan in ["cities", "dev_towns"] else 0.06)))
	var left := rest
	for _pass in range(3):
		if left <= 1.0 or wsum <= 0.0: break
		var ws := 0.0
		for id in weights:
			if float(room[id]) > 1.0: ws += float(weights[id])
		if ws <= 0.0: break
		var placed_now := 0.0
		for c in S().cities:
			if not weights.has(c.id) or float(room[c.id]) <= 1.0: continue
			var n: float = minf(left * float(weights[c.id]) / ws, float(room[c.id]))
			room[c.id] = float(room[c.id]) - n
			c.residents += n; c.immigrants += n; placed_now += n
			if plan == "camps": c.camp += n * 0.9
			if plan == "dev_towns" and n > 500.0 and not (c.has_district("industrial_park") or c.has_district("port")):
				c.trust = maxf(0.0, c.trust - minf(3.0, n / 2000.0))   # arrivals without jobs
			report["to_cities"][c.key] = report["to_cities"].get(c.key, 0.0) + n
		left -= placed_now
	if left > 1.0:
		S().rural += left
		report["rural"] = float(report["rural"]) + left
	# newcomers draw on welfare, food subsidies and services for about two years
	var recent: Array = S().counters.get("recent_arrivals", [])
	recent.append(arriving)
	if recent.size() > ABSORPTION_QUARTERS: recent = recent.slice(recent.size() - ABSORPTION_QUARTERS)
	S().counters["recent_arrivals"] = recent
	var rsum := 0.0
	for x in recent: rsum += float(x)
	report["absorption_upkeep"] = rsum / 1000.0 * ABSORPTION_UPKEEP
	if plan != "":
		S().counters["imm_plan_" + plan] = int(S().counters.get("imm_plan_" + plan, 0)) + 1
	S().immigration_year[str(year)] = float(S().immigration_year.get(str(year), 0.0)) + arriving
	S().counters["immigrants_absorbed"] = float(S().counters.get("immigrants_absorbed", 0.0)) + arriving
	return report


# ------------------------------------------------------------------ census paths (per-city calibration)
# Each locality with CBS census points (cities.json) has a census path. Immigrant placement follows the
# historical growth of that path, and a slow internal migration pulls city shares back towards it.
# The player's housing, amenities and trust move each city's target by about -15% to +12%.

const NON_JEWISH_KINDS := ["arab_city", "arab_town", "bedouin_city", "bedouin_town", "druze_town", "druze_village",
	"palestinian_city", "syrian_city"]
const CENSUS_PULL := 0.08   # share of the gap closed per quarter (half-life about two years)


func census_target(c: SimCity, year: float) -> float:
	## Census-path residents at `year`; 0 when the locality has no usable path yet.
	var e: Dictionary = db().city_by_id.get(c.key, {})
	var pop: Dictionary = e.get("population", {})
	var first := 9999
	for y in pop:
		if pop[y] != null: first = mini(first, int(y))
	if first == 9999:
		return 0.0
	var t := 0.0
	if year < first + 0.5:
		if not sim._entry_existing_at(e, 1):
			return 0.0
		t = float(pop[str(first)]) / pow(1.03, first + 0.5 - year)
	else:
		t = db().city_pop_at(e, year)
	# a locality that absorbed a populated area (East Jerusalem, June 1967): the census points after
	# the join include it, so remove it from the path before the join date
	var j = db().real.get("city_joins", {}).get(c.key)
	if typeof(j) == TYPE_DICTIONARY:
		var jy := SimDB.year_f(SimDB.turn_of(j.get("date"), 1))
		if year < jy:
			var prev := 1948.5
			for y in pop:
				if pop[y] != null and float(y) + 0.5 <= jy: prev = maxf(prev, float(y) + 0.5)
			t -= float(j.get("residents", 0)) * clampf((year - prev) / maxf(0.1, jy - prev), 0.0, 1.0)
	return maxf(0.0, t)


func attract_factor(c: SimCity) -> float:
	## How much more (or less) a city attracts than history did: housing headroom, amenities, trust.
	var pf := sqrt(maxf(c.residents, 0.0) / 1000.0)
	var f := 1.0 + clampf((float(c.info.get("housing", pf)) - pf) * 0.02, -0.08, 0.06)
	f += clampf(float(c.info.get("amenity_balance", 0)) * 0.015, -0.04, 0.03)
	f += clampf((c.trust - 70.0) / 500.0, -0.06, 0.03)
	return clampf(f, 0.85, 1.12)


func census_pull() -> Dictionary:
	## Internal migration towards the census paths. Jewish-sector localities exchange residents with the
	## countryside (the hundreds of localities not modelled as cities), so the national total is kept and
	## the split between cities and the rest follows the census. Arab, Druze and Bedouin localities follow
	## their own paths (natural growth; they receive no aliyah).
	var yf := SimDB.year_f(S().turn)
	var moved := 0.0; var to_rural := 0.0
	var total := S().rural
	for c in S().cities:
		if c.active: total += c.residents
	var rural_floor := 0.08 * total
	for c in S().cities:
		if not c.active: continue
		var t := census_target(c, yf)
		if t <= 0.0: continue
		var d: float = (t * attract_factor(c) - c.residents) * CENSUS_PULL
		if c.kind in NON_JEWISH_KINDS:
			c.residents = maxf(300.0, c.residents + d)
			moved += absf(d)
			continue
		if d > 0.0:
			d = minf(d, maxf(0.0, S().rural - rural_floor))
		c.residents = maxf(300.0, c.residents + d)
		S().rural -= d
		to_rural -= d
		moved += absf(d)
	return {"moved": moved, "to_rural": to_rural}


func census_fit(year: float) -> Dictionary:
	## Residents-weighted mean absolute error of city sizes against their census paths.
	var err := 0.0; var w := 0.0; var worst := []
	for c in S().cities:
		if not c.active: continue
		var t := census_target(c, year)
		if t < 5000.0: continue
		var e: float = absf(c.residents - t) / t
		err += e * t; w += t
		worst.append({"name": c.name, "res": c.residents, "census": t, "err": (c.residents - t) / t})
	worst.sort_custom(func(a, b): return absf(a["err"]) * sqrt(a["census"]) > absf(b["err"]) * sqrt(b["census"]))
	return {"mae": err / maxf(1.0, w), "worst": worst.slice(0, 5)}


# ------------------------------------------------------------------ water (signature system, MECHANICS 29.2)

func update_water() -> void:
	var supply := 230.0   # national groundwater base, MCM/yr (calibration constant)
	var demand := 0.0
	var year := SimDB.year_of(S().turn)
	var per_cap := (70.0 + 0.4 * (year - 1948)) / 1.0e6
	var farms := 0.0
	var tot_res := S().rural
	for c in S().cities:
		if not c.active: continue
		tot_res += c.residents
		var ck := SimHex.key(c.q, c.r)
		var t = db().tiles.get(ck, {})
		var rain := float(t.get("rain_mm", 400))
		var rf := 1.0 if rain >= 400 else (0.7 if rain >= 200 else 0.4)
		var local := (10.0 if c.info.get("fresh", false) else (5.0 if is_coastal(ck) else 2.0)) * rf
		supply += local + float(c.info.get("water_local", 0.0))
		var dom: float = c.residents * per_cap
		demand += dom
		for b in c.buildings:
			var rp := float(db().buildings.get(b, {}).get("water_reuse_pct", 0))
			if rp > 0: supply += dom * rp / 100.0
		if c.has_district("industrial_park"): demand += 5.0
		for k in city_tile_keys(c):
			var imp := str(tstate(k).get("imp", ""))
			if imp != "":
				var wd := float(db().improvements.get(imp, {}).get("water_demand", 0)) * 1.7 * maxf(0.55, 1.0 - 0.005 * (year - 1948))
				if S().techs.has("drip_irrigation") and imp != "drip_farm": wd *= 0.7
				demand += wd
				if imp in FARM_TYPES: farms += 1
	demand += S().rural * per_cap
	demand += S().rural / 1000.0 * 0.8 * maxf(0.35, 1.0 - 0.008 * (year - 1948))   # rural agriculture outside modelled tiles
	# drought years: a deterministic weather pattern shared by the ghost and the player (variance, not history)
	var h := ((year * 2654435761) >> 7) % 100
	if h < 14:
		supply *= 0.86
		S().water["drought"] = year
	else:
		S().water.erase("drought")
	for e in mods:
		if e.get("type") == "water_supply": supply += float(e.get("amount", 0))
	supply *= 1.0 + mod_sum("water_supply_pct", "pct") / 100.0
	demand *= 1.0 + mod_sum("water_demand_pct", "pct") / 100.0
	for e in S().temp_effects:
		if e.get("type") == "drought" and int(e.get("until", 0)) >= S().turn:
			supply *= 1.0 - float(e.get("pct", 15)) / 100.0
	var ratio := supply / maxf(1.0, demand)
	var w := S().water
	w["supply"] = supply; w["demand"] = demand; w["ratio"] = ratio
	w["per_capita"] = supply * 1.0e6 / maxf(1.0, tot_res)
	if ratio < 1.0:
		w["deficit_turns"] = int(w.get("deficit_turns", 0)) + 1
		w["deficit_total"] = int(w.get("deficit_total", 0)) + 1
		w["reserve"] = maxf(0.0, float(w.get("reserve", 70.0)) - (1.0 - ratio) * 12.0)
	else:
		w["deficit_turns"] = 0
		w["reserve"] = minf(100.0, float(w.get("reserve", 70.0)) + minf(2.0, (ratio - 1.0) * 10.0))
	w["farms"] = farms


# ------------------------------------------------------------------ national food balance (v3, sim-endgame)
# National food = what the cities' worked tiles, farms and buildings produce plus the rural localities; the population
# eats 2 per population point. A shortfall is imported at 0.5 gold each (Sim._process_turn) and slows growth in every
# city; a surplus is exported at FOOD_EXPORT gold each (citrus, vegetables and flowers) and speeds growth in the cities
# that grow it. SimEndgame.food_balance() explains the figure for the top bar. Calibration constant, not data.

const FOOD_EXPORT := 0.0   # off: exports moved the ghost's treasury and growth off the census (sim-endgame calibration)


func food_exports(nat: Dictionary) -> float:
	return maxf(0.0, float(nat.get("food", 0.0)) - float(nat.get("food_need", 0.0))) * FOOD_EXPORT


# ------------------------------------------------------------------ public debt (fix-cabinet; V2 full-game blocker B3)
# Borrowing is a stock with a cost: every loan joins the public debt, which pays interest each quarter and is repaid
# over fifteen years. Lenders cap it by the size of the economy and Israel's standing. A treasury overdraft (negative
# gold) pays interest too. Inflation above history's path and a heavy debt burden lower output per capita (the
# score's economy track, economy_health()).

const DEBT_TERM_Q := 60          # loans (bonds, foreign credit) are repaid over fifteen years
const DEBT_RATE_Q := 0.009       # interest a quarter (about 3.6% a year); rises as the debt nears the lenders' limit
const OVERDRAFT_RATE_Q := 0.01   # interest on a negative treasury (central-bank credit)


func debt() -> float:
	return float(S().counters.get("debt", 0.0))


func debt_cap() -> float:
	## What lenders will hold: about three years of revenue, more with a good international standing.
	var inc := maxf(30.0, float(S().counters.get("income_avg", 45.0)))
	return inc * 12.0 * clampf(0.3 + S().standing / 100.0, 0.5, 1.3)


func borrow_room() -> float:
	return maxf(0.0, debt_cap() - debt())


func borrow(amount: float, why: String, rate_mult := 1.0) -> float:
	## Adds a loan to the public debt (capped by borrow_room()); the gold goes to the treasury. Returns the amount lent.
	var st := S()
	var a := minf(amount, borrow_room())
	if a <= 0.5:
		return 0.0
	var d := debt()
	var r := (float(st.counters.get("debt_rate", DEBT_RATE_Q)) * d + DEBT_RATE_Q * rate_mult * a) / maxf(1.0, d + a)
	st.counters["debt"] = d + a
	st.counters["debt_rate"] = r
	st.gold += a
	st.counters["borrowed_total"] = float(st.counters.get("borrowed_total", 0.0)) + a
	st.counters["borrow_count"] = int(st.counters.get("borrow_count", 0)) + 1
	st.counters["debt_peak"] = maxf(float(st.counters.get("debt_peak", 0.0)), d + a)
	st.stat_log.append({"turn": st.turn, "stat": "gold", "amount": a, "reason": "%s: +%s gold, public debt now %s (repaid over fifteen years with interest)" % [why, _fmt_n(a), _fmt_n(d + a)], "lasting": true})
	sim.notify("budget", "%s: %s gold borrowed. Public debt %s; it is repaid with interest over fifteen years." % [why, _fmt_n(a), _fmt_n(d + a)], {"debt": d + a})
	return a


func repay(amount: float) -> float:
	## Early repayment (debt buy-back) from the treasury.
	var st := S()
	var a := minf(amount, debt())
	if a <= 0.0:
		return 0.0
	st.gold -= a
	st.counters["debt"] = debt() - a
	st.counters["repaid_early"] = float(st.counters.get("repaid_early", 0.0)) + a
	st.stat_log.append({"turn": st.turn, "stat": "gold", "amount": -a, "reason": "Debt repaid early: %s (public debt now %s)" % [_fmt_n(a), _fmt_n(debt())], "lasting": true})
	return a


func service_debt() -> float:
	## Once a quarter, from the national budget: interest and repayment on the public debt, interest on a negative
	## treasury. Returns the gold paid. Also ends rails tied to inflation staying high (the post-1973 deficit).
	var st := S()
	_rail_ends()
	var d := debt()
	var cap := debt_cap()
	var interest := 0.0
	var principal := 0.0
	if d > 0.01:
		var rate := float(st.counters.get("debt_rate", DEBT_RATE_Q)) * (1.0 + 2.0 * maxf(0.0, d / maxf(1.0, cap) - 0.7))
		interest = d * rate
		principal = minf(d, maxf(d / float(DEBT_TERM_Q), 1.0))
		st.counters["debt"] = d - principal
	var overdraft := maxf(0.0, -st.gold) * OVERDRAFT_RATE_Q
	var tot := interest + principal + overdraft
	st.counters["last_debt"] = {"interest": interest, "repayment": principal, "overdraft": overdraft, "total": tot, "debt": debt(), "cap": cap}
	st.counters["debt_interest_total"] = float(st.counters.get("debt_interest_total", 0.0)) + interest + overdraft
	return tot


func note_deficit(net: float) -> void:
	if net < 0.0:
		S().counters["deficit_turns"] = int(S().counters.get("deficit_turns", 0)) + 1


func _rail_ends() -> void:
	## A rail with "ends_with_inflation_below" ends once inflation has stayed under that level for a year: the
	## post-1973 deficit came from wage indexation, so it closes when inflation does, plan or no plan.
	var st := S()
	for s in st.streams:
		if not s.has("ends_with_inflation_below") or int(s.get("from", 0)) > st.turn or int(s.get("until", 0)) < st.turn:
			continue
		if SimDB.year_f(st.turn) < float(s.get("ends_with_inflation_from", 0.0)):
			continue   # the indexation deficit only closes this way once disinflation is under way (history: from mid-1985)
		var key := "low_infl_q:" + str(s.get("label", ""))
		if st.inflation < float(s["ends_with_inflation_below"]):
			st.counters[key] = int(st.counters.get(key, 0)) + 1
		else:
			st.counters[key] = 0
		if int(st.counters[key]) >= 4:
			s["until"] = st.turn
			s["end_notified"] = true
			sim.notify("stream", "%s ends: inflation has stayed below %d%% for a year, and the budget recovers %d gold a turn." % [str(s.get("label", "")), int(s["ends_with_inflation_below"]), int(absf(float(s.get("amount", 0))))], {"label": s.get("label", "")})


func open_deficit_rails() -> Array:
	## Active negative gold rails with an end condition, for the deficit agenda and the policy panel:
	## [{label, amount, ends}].
	var st := S()
	var out := []
	for s in st.streams:
		if str(s.get("type", "")) != "gold" or float(s.get("amount", 0)) >= 0.0 or str(s.get("src", "")) != "rail":
			continue
		if not sim._stream_active(s):
			continue
		var ends := ""
		if s.has("ends_with_policy"):
			var pname := str(db().policies.get(str(s["ends_with_policy"]), {}).get("name", s["ends_with_policy"]))
			ends = "ends when the %s card is slotted" % pname
			if s.has("ends_with_inflation_below"):
				ends += " or inflation stays below %d%% for a year" % int(s["ends_with_inflation_below"])
		elif s.has("ends_with_inflation_below"):
			ends = "ends when inflation stays below %d%% for a year" % int(s["ends_with_inflation_below"])
		else:
			ends = "lasts until %s" % SimDB.date_label(int(s.get("until", 0)))
		out.append({"label": str(s.get("label", "")), "amount": float(s.get("amount", 0)), "ends": ends})
	return out


func economy_health() -> float:
	## Output per capita kept despite inflation above history's path (the player's inflation gap, in log points) and
	## a heavy debt burden (debt plus twice any overdraft, beyond two years of revenue). 1.0 = no loss. The score's
	## economy track is multiplied by it.
	var st := S()
	var gap := maxf(0.0, sim.inflation_gap())
	var inc := maxf(30.0, float(st.counters.get("income_avg", 45.0)))
	var burden := maxf(0.0, debt() + 2.0 * maxf(0.0, -st.gold) - 8.0 * inc) / (4.0 * inc)
	return exp(-0.45 * gap) / (1.0 + 0.2 * burden)


func debt_report() -> Dictionary:
	var st := S()
	var ld: Dictionary = st.counters.get("last_debt", {})
	return {"debt": debt(), "cap": debt_cap(), "room": borrow_room(), "borrowed_total": float(st.counters.get("borrowed_total", 0.0)),
		"borrow_count": int(st.counters.get("borrow_count", 0)), "interest_total": float(st.counters.get("debt_interest_total", 0.0)),
		"repaid_early": float(st.counters.get("repaid_early", 0.0)), "debt_peak": float(st.counters.get("debt_peak", 0.0)),
		"service": float(ld.get("total", 0.0)), "interest": float(ld.get("interest", 0.0)) + float(ld.get("overdraft", 0.0)),
		"health": economy_health(), "deficit_turns": int(st.counters.get("deficit_turns", 0)), "open_rails": open_deficit_rails()}


func _avg_trust_all() -> float:
	var t := 0.0
	var w := 0.0
	for c in sim.active_cities():
		t += c.trust * c.residents
		w += c.residents
	return t / w if w > 0.0 else 75.0


func deficit_agenda(sc: float, net: float) -> Dictionary:
	## The Cabinet Agenda's deficit item (called by SimEvents.generate_agenda): raise taxes, cut services or borrow.
	## Borrowing adds to the public debt (interest and ten-year repayment), is capped by the lenders' limit and is
	## never the Recommended pick. The text names the open deficit rails and what ends them.
	var st := S()
	if net >= 0.0:
		return {}
	if structural_alarm() and st.mode != "historical":
		return structural_agenda(net)   # v3 fix3-econ: upkeep above revenue for a year: the structural levers
	var in_debt := int(st.counters.get("neg_turns", 0))
	var need := maxf(maxf(140.0 * sc, -6.0 * net), 40.0 * sc - st.gold)
	var amt := roundf(minf(need, borrow_room()))
	# cuts when cash is needed at once (a deep overdraft) and trust can bear it, or to fight high inflation; a tax
	# rise otherwise (it takes two years to work but costs only amenities)
	var inc := maxf(30.0, float(st.counters.get("income_avg", 45.0)))
	var tax_on := false
	for te in st.temp_effects:
		if str(te.get("src", "")) == "agenda" and str(te.get("type", "")) == "yield_pct" and str(te.get("yield", "")) == "gold" and int(te.get("until", 0)) >= st.turn:
			tax_on = true   # a tax rise is already working: the next answer is cuts
	# rotate between the three answers from one deficit item to the next (agenda_budget counts the answers given);
	# not a tax rise while one is still working, and no cuts or wage freeze when trust cannot bear them
	var rot := int(st.counters.get("agenda_budget", 0)) % 3
	if tax_on and rot == 0: rot = 1
	if _avg_trust_all() < 66.0: rot = 0
	var opts := [
		{"label": "Raise taxes", "fx": {"temp": {"type": "yield_pct", "yield": "gold", "pct": 15}, "turns": 8, "amenity_all": -1}, "default": rot == 0},
		{"label": "Cut public services", "fx": {"gold": 90 * sc, "trust_all": -4}, "default": rot == 1},
		{"label": "Freeze public-sector wages for a year", "fx": {"gold": 50 * sc, "inflation": -3, "trust_all": -2}, "default": rot == 2}]
	var txt := "Treasury %s, net %+d per quarter. Public debt %s of a %s limit (repayment and interest %s a quarter)." % [_fmt_n(st.gold), int(net), _fmt_n(debt()), _fmt_n(debt_cap()),
		_fmt_n(float(st.counters.get("last_debt", {}).get("total", 0.0)))]
	if structural_ratio() > 0.9:
		txt = upkeep_text(true) + "\n" + txt   # v3 fix3-econ: name the running costs, not only the debt
	if amt >= 20.0 * sc:
		var svc := amt / float(DEBT_TERM_Q) + amt * DEBT_RATE_Q
		opts.append({"label": "Borrow abroad: +%s gold now, repaid with interest over fifteen years (about %s a quarter)" % [_fmt_n(amt), _fmt_n(svc)],
			"fx": {"borrow": amt, "inflation": 4}, "default": false})
	else:
		txt += " Foreign lenders will not lend more until the debt comes down."
	for r in open_deficit_rails():
		txt += " Still open: %s (%d a quarter; it %s)." % [str(r["label"]), int(r["amount"]), str(r["ends"])]
	return {"id": "budget", "severity": (6.0 if in_debt >= 2 else 3.0) if st.gold < 0 else 1.5, "title": "Budget deficit", "text": txt, "options": opts}


# ------------------------------------------------------------------ v3 fix round (fix3-econ): upkeep, the structural deficit, the fiscal levers
# Running costs (building upkeep, specialty districts, public services that grow with the population, units) are measured
# against revenue every quarter. Upkeep plus debt service above data/fiscal.json "structural.ratio" (110%) of revenue for
# "quarters" (4) in a row raises the structural-deficit alarm: a `fiscal` notification (advisor card), a Cabinet Agenda item
# that names the upkeep, and the fiscal indicator's "warning" tier. It clears after two quarters at or below 100%.
# The levers (each also callable from the UI):
#  - mothball a building: it stops working and keeps 20% of its upkeep until it is reopened (six quarters of its upkeep);
#    or close it for good (no upkeep; a closed service building costs that city's Civic Trust);
#  - privatise state companies (data/fiscal.json "privatisations", each once from its date: one-off gold of 1.2-2 quarters
#    of income, upkeep -3% to -5% for ten years, sometimes +1-2% output; Civic Trust -1 to -3);
#  - an emergency stabilisation package (from 40% inflation, with the alarm on or a fiscal collapse in sight; once a
#    decade): upkeep -15% for three years, the inflation gap cut to a quarter and anchored for two years, at -5 Civic Trust,
#    -1 amenity for a year and -6% production for a year. Its name and advocate follow the era (1949, 1962/66, 1985).

const FISCAL_PATH := "res://data/fiscal.json"
static var _fiscal := {}


static func fiscal_data() -> Dictionary:
	if _fiscal.is_empty():
		var d = JSON.parse_string(FileAccess.get_file_as_string(FISCAL_PATH)) if FileAccess.file_exists(FISCAL_PATH) else {}
		_fiscal = d if typeof(d) == TYPE_DICTIONARY else {}
	return _fiscal


static func validate_fiscal(dbx: SimDB) -> Array:
	## Data errors in data/fiscal.json (sim_test --validate-only): every lever has a name, an advocate and a cite whose
	## source id exists.
	var errs := []
	var f := fiscal_data()
	if f.is_empty():
		return ["fiscal.json missing or unreadable"]
	var levers: Array = f.get("privatisations", []).duplicate()
	levers.append_array(f.get("stabilisation", {}).get("versions", []))
	levers.append_array(f.get("policy_cuts", {}).get("versions", []))   # v3 final round (fix4-econ)
	for l in levers:
		var id := str(l.get("id", ""))
		for k in ["id", "name", "desc", "historical", "advocate", "cite", "source"]:
			if not l.has(k): errs.append("fiscal.json %s: missing \"%s\"" % [id, k])
		for c in l.get("cite", []):
			if str(c.get("quote", "")) == "" or str(c.get("url", "")) == "": errs.append("fiscal.json %s: a cite without a quote or url" % id)
			if dbx != null and not dbx.sources.has(str(c.get("source", ""))): errs.append("fiscal.json %s: unknown source %s" % [id, c.get("source", "")])
		for s in l.get("source", []):
			if dbx != null and not dbx.sources.has(str(s)): errs.append("fiscal.json %s: unknown source %s" % [id, s])
	return errs


func upkeep_parts() -> Dictionary:
	## The quarter's running costs by category (Sim._maintenance returns "total"): {buildings, districts, public, units,
	## mothballed, pct (maintenance_pct mods, %), total, by_building: {id: gold}, cities: [{id, name, upkeep, buildings}] (largest first)}.
	## Category figures include the maintenance_pct mods (policies, privatisation, a stabilisation package).
	var st := S()
	var keep := float(fiscal_data().get("mothball", {}).get("keep_upkeep", 0.2))
	var b_up := 0.0; var d_up := 0.0; var mb := 0.0
	var by := {}
	var cities := []
	for c in sim.active_cities():
		var cu := 0.0
		for b in c.buildings:
			var u := float(db().buildings.get(b, {}).get("upkeep", 0))
			b_up += u; cu += u
			if u > 0.0: by[b] = float(by.get(b, 0.0)) + u
		for d in c.districts:
			if db().districts.get(d, {}).get("specialty", false):
				d_up += 1.0; cu += 1.0
		for b2 in mothballed(c):
			var u2 := float(db().buildings.get(b2, {}).get("upkeep", 0)) * keep
			mb += u2; cu += u2
		cities.append({"id": c.id, "name": c.name, "upkeep": cu, "buildings": c.buildings.size()})
	var unit_m := 0.0
	var red := mod_sum("unit_upkeep")
	for u in st.units:
		if u.owner == "player":
			var up := float(db().units.get(u.type, {}).get("upkeep", 0))
			if up > 0: unit_m += maxf(0.0, up + red)
	# public services scale with population (schools, clinics, administration)
	var pub := 0.25 * float(sim.national().get("pop", 0)) * (1.0 + 0.08 * st.era)
	var pct := mod_sum("maintenance_pct", "pct")
	var mult := maxf(0.0, 1.0 + pct / 100.0)
	for k in by: by[k] = float(by[k]) * mult
	for cc in cities: cc["upkeep"] = snappedf(float(cc["upkeep"]) * mult, 0.1)
	cities.sort_custom(func(a, b): return float(a["upkeep"]) > float(b["upkeep"]))
	var ru := readiness_upkeep()   # v3 final round (fix4-econ, item 2): holding the forces at high readiness costs gold
	var total := (b_up + d_up + pub + mb) * mult + unit_m + ru
	return {"buildings": b_up * mult, "districts": d_up * mult, "public": pub * mult, "units": unit_m, "mothballed": mb * mult, "pct": pct,
		"readiness": ru, "total": total, "by_building": by, "cities": cities}


func readiness_upkeep() -> float:
	## v3 final round (fix4-econ, item 2): training, reserve duty and munitions stocks. Nothing up to Readiness 60, then
	## rising steeply to 6% of the average quarterly income at Readiness 100 (data/fiscal.json "readiness").
	var f: Dictionary = fiscal_data().get("readiness", {})
	var from := float(f.get("from", 60.0))
	var x := clampf((S().readiness - from) / maxf(1.0, 100.0 - from), 0.0, 1.0)
	if x <= 0.0:
		return 0.0
	var inc := maxf(30.0, float(S().counters.get("income_avg", 45.0)))
	return inc * float(f.get("share_at_100", 0.06)) * pow(x, float(f.get("power", 1.5)))


func note_structural(income: float, extra: float, upkeep: float, debt_pay: float, budget := {}) -> void:
	## Called by Sim._process_turn after the budget: measures every recurring outflow against gross revenue and raises
	## or clears the structural-deficit alarm. v3 final round (fix4-econ, N1): `budget` = {imports, absorption,
	## food_exports}; the outflows are running costs, readiness, absorption, policy cards, negative lasting terms and
	## rails, event costs, food imports and debt service; revenue is income plus every positive transfer (aid,
	## reparations, terms) and exports. Without `budget` (old callers) the old measure (running costs and debt service
	## against income and net positive transfers) is used. The alarm threshold is 110%, or history's own ratio at that
	## date plus 10 points when history ran a deeper deficit (1949-52 absorption): history's own deficits never alarm.
	var st := S()
	var f: Dictionary = fiscal_data().get("structural", {})
	var revenue := income + maxf(0.0, extra)
	var outflow := upkeep + debt_pay
	var bl := {}
	if not budget.is_empty():
		bl = budget_lines(income, upkeep, debt_pay, budget)
		revenue = float(bl["revenue"])
		outflow = float(bl["outflow"])
	st.counters["budget_lines"] = bl
	var ratio := outflow / maxf(1.0, revenue)
	var hist_r := history_ratio()
	var lim := maxf(float(f.get("ratio", 1.1)), hist_r + float(f.get("history_margin", 0.1)))
	var clear_lim := maxf(float(f.get("clear_ratio", 1.0)), hist_r)
	var s: Dictionary = st.counters.get("structural", {})
	if s.is_empty():
		s = {"q": 0, "ok_q": 0, "alarm": false, "since": -1, "first": -1, "episodes": 0, "alarm_turns": 0, "peak": 0.0}
	s["ratio"] = ratio; s["revenue"] = revenue; s["upkeep"] = upkeep; s["service"] = debt_pay
	s["outflow"] = outflow; s["limit"] = lim; s["hist_ratio"] = hist_r
	s["ratio_running"] = (upkeep + debt_pay) / maxf(1.0, revenue)
	s["peak"] = maxf(float(s.get("peak", 0.0)), ratio)
	if ratio > lim:
		s["q"] = int(s["q"]) + 1
		s["ok_q"] = 0
	else:
		s["q"] = 0
		s["ok_q"] = int(s["ok_q"]) + 1 if ratio <= clear_lim else 0
	var hist := st.mode == "historical"
	if not bool(s["alarm"]) and int(s["q"]) >= int(f.get("quarters", 4)):
		s["alarm"] = true
		s["since"] = st.turn
		s["episodes"] = int(s["episodes"]) + 1
		if int(s["first"]) < 0: s["first"] = st.turn
		st.counters["structural"] = s
		if not hist: _structural_notice()
	elif bool(s["alarm"]) and int(s["ok_q"]) >= int(f.get("clear_quarters", 2)):
		s["alarm"] = false
		if not hist:
			sim.notify("fiscal", "The structural deficit has closed: the state's outflows are back within revenue (%d%% of it)." % int(round(ratio * 100.0)), {"structural": false, "recovered": true})
	if bool(s["alarm"]): s["alarm_turns"] = int(s["alarm_turns"]) + 1
	st.counters["structural"] = s
	if st.gold < 0.0:
		st.counters["overdraft_quarters"] = int(st.counters.get("overdraft_quarters", 0)) + 1


func structural() -> Dictionary:
	return S().counters.get("structural", {})


func structural_alarm() -> bool:
	return bool(structural().get("alarm", false))


func structural_ratio() -> float:
	return float(structural().get("ratio", 0.0))


func history_ratio() -> float:
	## History's own outflow-to-revenue ratio about this date (ghost.json rows "sr", the six quarters around now); 0 for
	## the ghost itself or an old ghost file.
	var st := S()
	if st.mode == "historical" or sim.score == null:
		return 0.0
	var t := 0.0
	var n := 0
	for k in range(st.turn - 3, st.turn + 3):
		var g: Dictionary = sim.score.ghost_at(maxi(1, k))
		if float(g.get("sr", 0.0)) > 0.0:   # the first quarter has no budget yet
			t += float(g["sr"]); n += 1
	return t / float(n) if n > 0 else 0.0


func _src_label(src: String, fallback := "") -> String:
	var parts := src.split(":", true, 1)
	var id := parts[1] if parts.size() > 1 else ""
	match parts[0]:
		"policy": return str(db().policies.get(id, {}).get("name", id))
		"tech": return str(db().techs.get(id, {}).get("name", id))
		"civic": return str(db().civics.get(id, {}).get("name", id))
		"project": return str(db().projects.get(id, {}).get("name", id))
		"budget": return "State Budget"
		"term": return id
		"agenda": return "Cabinet Agenda"
		"coalition": return "Coalition agreement"
	return fallback if fallback != "" else src


func transfer_items() -> Array:
	## The quarter's gold transfers item by item, the same sums Sim._process_turn books as "events", "policies" and
	## "choices": [{label, amount, kind: "event"|"policy"|"term"|"rail"|"other", src}].
	var st := S()
	var out := []
	for gm in st.gold_mods:
		if int(gm.get("until", 0)) >= st.turn and absf(float(gm.get("amount", 0))) > 0.0:
			var src := str(gm.get("src", ""))
			var ev = db().event_by_id.get(src)
			out.append({"label": str(ev.get("title", src)) if ev != null else (src if src != "" else "Event"), "amount": float(gm["amount"]), "kind": "event", "src": src})
	var pop := float(sim.national().get("pop", 0))
	for e in mods:
		var ty := str(e.get("type", ""))
		if ty != "gold_per_turn" and ty != "gold_per_pop":
			continue
		if e.has("city") or not cond_ok(e.get("cond"), null):
			continue
		var a := float(e.get("amount", 0)) * (pop if ty == "gold_per_pop" else 1.0)
		if absf(a) < 0.001:
			continue
		var src2 := str(e.get("src", ""))
		out.append({"label": _src_label(src2, "Other"), "amount": a, "kind": "policy" if src2.begins_with("policy:") else "other", "src": src2})
	for s in st.streams:
		if str(s.get("type")) == "gold" and sim._stream_active(s) and absf(float(s.get("amount", 0))) > 0.0:
			var src3 := str(s.get("src", ""))
			out.append({"label": str(s.get("label", src3)), "amount": float(s.get("amount", 0)), "kind": "rail" if src3 == "rail" else "term", "src": src3})
	return out


func _items_by_label(items: Array, sign_: float) -> Array:
	## [{label, amount}] of the items on one side (sign_ 1: positive, -1: negative), merged by label, largest first.
	var by := {}
	for x in items:
		var a := float(x["amount"])
		if a * sign_ <= 0.0: continue
		by[str(x["label"])] = float(by.get(str(x["label"]), 0.0)) + a
	var out := []
	for k in by: out.append({"label": k, "amount": snappedf(float(by[k]), 0.1)})
	out.sort_custom(func(a, b): return absf(float(a["amount"])) > absf(float(b["amount"])))
	return out


func _sum_amounts(arr: Array) -> float:
	var t := 0.0
	for x in arr: t += float(x["amount"])
	return t


func budget_lines(income: float, upkeep: float, debt_pay: float, b: Dictionary) -> Dictionary:
	## v3 final round (fix4-econ, N1): the quarter's whole budget as Treasury lines that add up to the net:
	## {revenue, outflow, net, lines: [{id, label, amount, kind: revenue|outflow, items: [{label, amount}]}]}.
	var items := transfer_items()
	var p: Dictionary = S().counters.get("upkeep_parts", {})
	var ru := float(p.get("readiness", 0.0))
	var pos := _items_by_label(items, 1.0)
	var pol := _items_by_label(items.filter(func(x): return str(x["kind"]) == "policy"), -1.0)
	var terms := _items_by_label(items.filter(func(x): return str(x["kind"]) in ["term", "rail", "other"]), -1.0)
	var evs := _items_by_label(items.filter(func(x): return str(x["kind"]) == "event"), -1.0)
	var run_items := []
	for k in [["buildings", "buildings"], ["public", "public services"], ["districts", "districts"], ["units", "units"], ["mothballed", "mothballed buildings"]]:
		if float(p.get(k[0], 0.0)) >= 0.05: run_items.append({"label": k[1], "amount": -snappedf(float(p[k[0]]), 0.1)})
	var exports := float(b.get("food_exports", 0.0))
	var lines := [{"id": "income", "label": "Taxes and the economy's yields", "amount": income, "kind": "revenue", "items": []},
		{"id": "transfers_in", "label": "Aid, transfers and lasting terms", "amount": _sum_amounts(pos), "kind": "revenue", "items": pos}]
	if exports > 0.0: lines.append({"id": "food_exports", "label": "Food exports", "amount": exports, "kind": "revenue", "items": []})
	lines.append({"id": "running", "label": "Running costs", "amount": -(upkeep - ru), "kind": "outflow", "items": run_items})
	lines.append({"id": "readiness", "label": "Readiness (training, reserve duty and stocks)", "amount": -ru, "kind": "outflow", "items": []})
	lines.append({"id": "absorption", "label": "Absorbing newcomers", "amount": -float(b.get("absorption", 0.0)), "kind": "outflow", "items": []})
	lines.append({"id": "policies", "label": "Policy cards", "amount": _sum_amounts(pol), "kind": "outflow", "items": pol})
	lines.append({"id": "terms_out", "label": "Lasting terms and rails", "amount": _sum_amounts(terms), "kind": "outflow", "items": terms})
	lines.append({"id": "events_out", "label": "Event costs", "amount": _sum_amounts(evs), "kind": "outflow", "items": evs})
	lines.append({"id": "imports", "label": "Food imports", "amount": -float(b.get("imports", 0.0)), "kind": "outflow", "items": []})
	lines.append({"id": "debt_service", "label": "Debt service", "amount": -debt_pay, "kind": "outflow", "items": []})
	var rev := 0.0
	var out := 0.0
	for l in lines:
		l["amount"] = snappedf(float(l["amount"]), 0.01)
		if str(l["kind"]) == "revenue": rev += float(l["amount"])
		else: out -= float(l["amount"])
	return {"revenue": rev, "outflow": out, "net": rev - out, "lines": lines}


func upkeep_text(short := false) -> String:
	## v3 final round (fix4-econ, N1): every line of the budget, e.g. "Revenue 228 (taxes 209, aid and transfers 19)
	## against outflows 337, 148% of it: running costs 247 (buildings 159, public services 74, districts 6, units 8),
	## absorption 32, policy cards 38 (Social Security 23, Universal Health Coverage 15), debt service 11." The long form
	## adds the cities with the highest upkeep.
	var p: Dictionary = S().counters.get("upkeep_parts", {})
	var s := structural()
	var bl: Dictionary = S().counters.get("budget_lines", {})
	var parts := []
	for k in [["buildings", "buildings"], ["public", "public services"], ["districts", "districts"], ["units", "units"], ["mothballed", "mothballed buildings"]]:
		if float(p.get(k[0], 0.0)) >= 0.5: parts.append("%s %d" % [k[1], int(round(float(p[k[0]])))])
	var t := ""
	if bl.is_empty():
		t = "Upkeep %d (%s) and debt service %d against revenue %d a quarter" % [int(round(float(s.get("upkeep", p.get("total", 0.0))))), ", ".join(parts),
			int(round(float(s.get("service", 0.0)))), int(round(float(s.get("revenue", 0.0))))]
	else:
		var L := {}
		for l in bl.get("lines", []): L[str(l["id"])] = l
		var rin := []
		rin.append("taxes %d" % int(round(float(L.get("income", {}).get("amount", 0.0)))))
		if float(L.get("transfers_in", {}).get("amount", 0.0)) >= 0.5: rin.append("aid and transfers %d" % int(round(float(L["transfers_in"]["amount"]))))
		if float(L.get("food_exports", {}).get("amount", 0.0)) >= 0.5: rin.append("food exports %d" % int(round(float(L["food_exports"]["amount"]))))
		var outs := ["running costs %d (%s)" % [int(round(-float(L.get("running", {}).get("amount", 0.0)))), ", ".join(parts)]]
		var named := func(id: String, what: String) -> void:
			var a := -float(L.get(id, {}).get("amount", 0.0))
			if a < 0.5: return
			var its: Array = L[id].get("items", [])
			var sub := ""
			if not its.is_empty():
				sub = " (%s)" % ", ".join(its.slice(0, 3).map(func(x): return "%s %d" % [str(x["label"]), int(round(-float(x["amount"])))]))
			outs.append("%s %d%s" % [what, int(round(a)), sub])
		named.call("readiness", "readiness")
		named.call("absorption", "absorption")
		named.call("policies", "policy cards")
		named.call("terms_out", "lasting terms")
		named.call("events_out", "event costs")
		named.call("imports", "food imports")
		named.call("debt_service", "debt service")
		t = "Revenue %d (%s) against outflows %d, %d%% of it: %s" % [int(round(float(bl["revenue"]))), ", ".join(rin), int(round(float(bl["outflow"]))),
			int(round(float(bl["outflow"]) / maxf(1.0, float(bl["revenue"])) * 100.0)), "; ".join(outs)]
	if short:
		return t + "."
	var cs: Array = p.get("cities", [])
	if not cs.is_empty():
		t += ". Highest upkeep: " + ", ".join(cs.slice(0, 5).map(func(x): return "%s %d" % [str(x["name"]), int(round(float(x["upkeep"])))]))
	return t + "."


func _structural_notice() -> void:
	var s := structural()
	sim.notify("fiscal", "Structural deficit: the state spends more than it takes in, quarter after quarter (%d%% of revenue for %d quarters). %s\nThe way out: mothball or close little-used buildings (City screen), scale back costly policy cards, privatise state companies, or an emergency stabilisation package; taxes and cuts help for a while." % [
		int(round(float(s.get("ratio", 0.0)) * 100.0)), int(s.get("q", 0)), upkeep_text()], {"structural": true, "first": int(s.get("episodes", 1)) == 1, "ratio": float(s.get("ratio", 0.0))})


# ---- mothballing and closing buildings

func mothballed(c) -> Array:
	var m: Dictionary = S().counters.get("mothballed", {})
	return m.get(str(c.id), [])


func is_mothballed(c, bid: String) -> bool:
	return bid in mothballed(c)


func is_service_building(bid: String) -> bool:
	var bd: Dictionary = db().buildings.get(bid, {})
	return float(bd.get("amenities", 0)) > 0.0 or float(bd.get("housing", 0)) > 0.0 or float(bd.get("trust", 0)) > 0.0 or float(bd.get("growth_pct", 0)) > 0.0


func reopen_cost(bid: String) -> int:
	var up := float(db().buildings.get(bid, {}).get("upkeep", 0))
	return int(round(maxf(1.0, up) * float(fiscal_data().get("mothball", {}).get("reopen_upkeep_quarters", 6)) * sim.events.gold_scale()))


func mothball(c: SimCity, bid: String) -> String:
	## Stops a building (no yields or effects) and cuts its upkeep to 20%. "" on success, else why not.
	if c == null or not c.has_building(bid):
		return "no such building in this city"
	if float(db().buildings.get(bid, {}).get("upkeep", 0)) <= 0.0:
		return "it has no upkeep to save"
	var st := S()
	c.buildings.erase(bid)
	var m: Dictionary = st.counters.get("mothballed", {})
	var lst: Array = m.get(str(c.id), [])
	lst.append(bid)
	m[str(c.id)] = lst
	st.counters["mothballed"] = m
	if is_service_building(bid):
		c.trust = clampf(c.trust + float(fiscal_data().get("mothball", {}).get("mothball_trust", -1)), 0.0, 100.0)
	_lever_log("mothball", "%s: %s" % [c.name, str(db().buildings.get(bid, {}).get("name", bid))])
	sim.refresh()
	return ""


func reopen(c: SimCity, bid: String) -> String:
	if c == null or not (bid in mothballed(c)):
		return "not mothballed here"
	var cost := reopen_cost(bid)
	var st := S()
	if st.gold < cost:
		return "needs %d gold" % cost
	st.gold -= cost
	var m: Dictionary = st.counters.get("mothballed", {})
	var lst: Array = m.get(str(c.id), [])
	lst.erase(bid)
	m[str(c.id)] = lst
	if not c.has_building(bid): c.buildings.append(bid)
	_lever_log("reopen", "%s: %s (%d gold)" % [c.name, str(db().buildings.get(bid, {}).get("name", bid)), cost])
	sim.refresh()
	return ""


func close_building(c: SimCity, bid: String) -> String:
	## Closes a building (or a mothballed one) for good: no upkeep; a service building costs the city's trust.
	if c == null:
		return "no city"
	var st := S()
	if bid in mothballed(c):
		var m: Dictionary = st.counters.get("mothballed", {})
		var lst: Array = m.get(str(c.id), [])
		lst.erase(bid)
		m[str(c.id)] = lst
	elif c.has_building(bid):
		c.buildings.erase(bid)
		if is_service_building(bid):
			c.trust = clampf(c.trust + float(fiscal_data().get("mothball", {}).get("close_trust", -2)), 0.0, 100.0)
	else:
		return "no such building in this city"
	_lever_log("close", "%s: %s" % [c.name, str(db().buildings.get(bid, {}).get("name", bid))])
	sim.refresh()
	return ""


func building_value(c: SimCity, bid: String) -> float:
	## How much a building does for its city now (for the mothball plan: least value per gold of upkeep first).
	var bd: Dictionary = db().buildings.get(bid, {})
	var v := 0.0
	var w := {"gold": 1.6, "production": 1.0, "science": 1.0, "culture": 0.6, "food": 0.8, "cohesion": 0.8}
	for k in bd.get("yields", {}):
		v += float(bd["yields"][k]) * float(w.get(k, 0.5))
	var am := float(bd.get("amenities", 0))
	if am > 0.0: v += am * (3.0 if float(c.info.get("amenity_balance", 0.0)) - am < 0.0 else 0.7)
	var ho := float(bd.get("housing", 0))
	if ho > 0.0: v += ho * (3.0 if float(c.info.get("transit", 0.0)) > 0.0 or housing_factor(c) < 1.0 else 0.5)
	v += float(bd.get("trust", 0)) * 1.5
	v += float(bd.get("readiness", 0)) * (2.0 if S().readiness < 70.0 else 0.8)
	v += float(bd.get("water_supply", 0)) * (0.2 if float(S().water.get("ratio", 1.0)) < 1.1 else 0.03)
	v += float(bd.get("defense", 0)) * 0.3 + float(bd.get("growth_pct", 0)) * 0.08 + float(bd.get("standing_per_turn", 0)) * 30.0
	# v3 final round (fix4-econ, item 3): a building's worth no longer drops in a small town (the only clinic of a
	# periphery or Arab town serves all of it); a building that serves residents counts a little more where many use it
	if is_service_building(bid) and c.pop() >= 8: v *= 1.15
	return v


func mothball_plan(target := 0.0, max_n := 40) -> Array:
	## Buildings to mothball, least value per gold of upkeep first, until the savings reach `target` gold a quarter (or
	## the gap of the structural deficit): [{city, city_name, building, name, upkeep, saves, value, service}].
	## v3 final round (fix4-econ, item 3): the plan keeps track of its own picks. At most one building that serves
	## residents (amenities, housing, trust: schools, clinics, public housing) and two buildings in all from any one
	## city; never a city below zero amenities or short of housing; a town's last building of a kind it needs is kept.
	## Ties go to the larger city (more alternatives nearby).
	var keep := float(fiscal_data().get("mothball", {}).get("keep_upkeep", 0.2))
	var mult := maxf(0.0, 1.0 + mod_sum("maintenance_pct", "pct") / 100.0)
	var mf: Dictionary = fiscal_data().get("mothball", {})
	var max_city := int(mf.get("plan_max_per_city", 2))
	var max_service := int(mf.get("plan_max_service_per_city", 1))
	if target <= 0.0:
		target = structural_gap() * 1.1
	var cands := []
	var pops := {}
	for c in sim.active_cities():
		pops[c.id] = c.pop()
		for b in c.buildings:
			var up := float(db().buildings.get(b, {}).get("upkeep", 0))
			if up <= 0.0: continue
			var v := building_value(c, b)
			cands.append({"city": c.id, "city_name": c.name, "building": str(b), "name": str(db().buildings.get(b, {}).get("name", b)), "upkeep": up * mult,
				"saves": snappedf(up * (1.0 - keep) * mult, 0.1), "value": snappedf(v, 0.01), "ratio": v / up, "service": is_service_building(str(b))})
	cands.sort_custom(func(a, b): return float(a["ratio"]) < float(b["ratio"]) - 0.001 or (absf(float(a["ratio"]) - float(b["ratio"])) <= 0.001 and int(pops[a["city"]]) > int(pops[b["city"]])))
	var out := []
	var saved := 0.0
	var picked := {}   # city id -> {n, service, amen, room}
	for x in cands:
		if saved >= target or out.size() >= max_n: break
		if float(x["ratio"]) > 4.0: break   # nothing worth stopping is left
		var c = sim.city_by_id(int(x["city"]))
		if c == null: continue
		var pc: Dictionary = picked.get(c.id, {"n": 0, "service": 0, "amen": float(c.info.get("amenity_balance", 0.0)), "h": float(c.info.get("housing", 0.0))})
		if int(pc["n"]) >= max_city: continue
		var bd: Dictionary = db().buildings.get(str(x["building"]), {})
		if bool(x["service"]):
			if int(pc["service"]) >= max_service: continue
			var am := float(bd.get("amenities", 0))
			if am > 0.0 and float(pc["amen"]) - am < 0.0: continue   # never a city below zero amenities
			var ho := float(bd.get("housing", 0))
			if ho > 0.0 and pow(maxf(0.0, float(pc["h"]) - ho), 2.0) * 1000.0 < c.residents: continue   # never a city short of housing
			pc["amen"] = float(pc["amen"]) - am
			pc["h"] = float(pc["h"]) - ho
			pc["service"] = int(pc["service"]) + 1
		pc["n"] = int(pc["n"]) + 1
		picked[c.id] = pc
		out.append(x)
		saved += float(x["saves"])
	return out


func mothball_many(plan: Array) -> float:
	## Applies a mothball plan; returns the gold a quarter saved.
	var saved := 0.0
	for x in plan:
		var c = sim.city_by_id(int(x["city"]))
		if c != null and mothball(c, str(x["building"])) == "":
			saved += float(x["saves"])
	if not plan.is_empty():
		sim.notify("budget", "%d buildings mothballed to save about %d gold a quarter: %s." % [plan.size(), int(round(saved)),
			", ".join(plan.slice(0, 6).map(func(x): return "%s in %s" % [str(x["name"]), str(x["city_name"])])) + (" and %d more" % (plan.size() - 6) if plan.size() > 6 else "")],
			{"mothballed": plan.size(), "saves": saved})
	return saved


func structural_gap() -> float:
	## Gold a quarter by which the outflows exceed revenue (0 when within it). v3 final round: every outflow (N1).
	var s := structural()
	var outflow := float(s.get("outflow", float(s.get("upkeep", 0.0)) + float(s.get("service", 0.0))))
	return maxf(0.0, outflow - float(s.get("revenue", 0.0)))


func _lever_log(kind: String, what: String) -> void:
	var lg: Array = S().counters.get("fiscal_levers", [])
	lg.append([S().turn, kind, what])
	S().counters["fiscal_levers"] = lg.slice(maxi(0, lg.size() - 200))


func lever_counts() -> Dictionary:
	var out := {}
	for e in S().counters.get("fiscal_levers", []):
		out[str(e[1])] = int(out.get(str(e[1]), 0)) + 1
	return out


# ---- privatisation

func privatisation_options() -> Array:
	## [{id, name, desc, available, reason, done, historical (history sold it about now), hist_label, advocate, cite, source,
	##   gold, upkeep_pct, output_pct, years, trust, effects_text: [str]}] (data/fiscal.json "privatisations").
	var st := S()
	var y := SimDB.year_of(st.turn)
	var done: Array = st.counters.get("privatised", [])
	var inc := maxf(30.0, float(st.counters.get("income_avg", 45.0)))
	var out := []
	for p in fiscal_data().get("privatisations", []):
		var id := str(p["id"])
		var gold := int(round(float(p.get("gold_quarters", 1.0)) * inc))
		var why := ""
		if id in done: why = "already sold"
		elif y < int(p.get("from", 1948)): why = "not before %d" % int(p.get("from", 1948))
		var eff := ["+%d Gold now" % gold, "Upkeep %d%% for %d years" % [int(p.get("upkeep_pct", 0)), int(p.get("years", 10))]]
		if float(p.get("output_pct", 0)) != 0.0: eff.append("%+d%% Production and Gold for %d years" % [int(p.get("output_pct", 0)), int(p.get("years", 10))])
		if float(p.get("trust", 0)) != 0.0: eff.append("%+d Civic Trust in every city (workers and unions oppose the sale)" % int(p.get("trust", 0)))
		out.append({"id": id, "name": str(p.get("name", id)), "desc": str(p.get("desc", "")), "available": why == "", "reason": why, "done": id in done,
			"historical": absi(y - int(p.get("historical", 0))) <= 1, "hist_label": str(p.get("hist_label", "")), "advocate": str(p.get("advocate", "")),
			"cite": p.get("cite", []), "source": p.get("source", []), "gold": gold, "upkeep_pct": float(p.get("upkeep_pct", 0)),
			"output_pct": float(p.get("output_pct", 0)), "years": int(p.get("years", 10)), "trust": float(p.get("trust", 0)), "effects_text": eff})
	return out


func next_privatisation() -> Dictionary:
	for o in privatisation_options():
		if o["available"]: return o
	return {}


func privatise(id: String) -> bool:
	var st := S()
	var o := {}
	for x in privatisation_options():
		if str(x["id"]) == id: o = x
	if o.is_empty() or not o["available"]:
		return false
	var until := st.turn + 4 * int(o["years"]) - 1
	st.gold += float(o["gold"])
	st.temp_effects.append({"type": "maintenance_pct", "pct": float(o["upkeep_pct"]), "until": until, "src": "privatise:" + id})
	if float(o["output_pct"]) != 0.0:
		st.streams.append({"type": "output_pct", "amount": float(o["output_pct"]), "from": st.turn, "until": until, "label": "Privatisation: " + str(o["name"]), "src": "privatise:" + id})
	if float(o["trust"]) != 0.0:
		for c in sim.active_cities(): c.trust = clampf(c.trust + float(o["trust"]), 0.0, 100.0)
		sim.stat_note("trust", float(o["trust"]), "Privatisation: " + str(o["name"]))
	var done: Array = st.counters.get("privatised", [])
	done.append(id)
	st.counters["privatised"] = done
	st.stat_log.append({"turn": st.turn, "stat": "gold", "amount": float(o["gold"]), "reason": "Privatisation: %s (+%d gold; upkeep %d%% until %s)" % [str(o["name"]), int(o["gold"]), int(o["upkeep_pct"]), SimDB.date_label(mini(until, Sim.full_last_turn()))], "lasting": true})
	_lever_log("privatise", str(o["name"]))
	sim.notify("budget", "Privatisation: %s. +%d gold now; upkeep %d%% for %d years." % [str(o["name"]), int(o["gold"]), int(o["upkeep_pct"]), int(o["years"])], {"privatised": id})
	sim.refresh()
	return true


# ---- the emergency stabilisation package

func _stab_version() -> Dictionary:
	var y := SimDB.year_of(S().turn)
	for v in fiscal_data().get("stabilisation", {}).get("versions", []):
		if y <= int(v.get("until", 2100)): return v
	return {}


func stabilised() -> bool:
	## The inflation anchor of a stabilisation package (wage agreement, fixed exchange rate): deficits push inflation far less.
	return S().turn <= int(S().counters.get("stab_anchor_until", -1))


func stabilisation_option() -> Dictionary:
	## {id, name, desc, available, reason, historical, hist_year, advocate, cite, source, effects_text, last, cooldown_left}
	var st := S()
	var f: Dictionary = fiscal_data().get("stabilisation", {})
	var v := _stab_version()
	var last := int(st.counters.get("stabilised_turn", -999))
	var cd := last + 4 * int(f.get("cooldown_years", 10)) - st.turn
	var fcl: String = sim.collapse.level_of("collapse_fiscal") if sim.collapse != null else "ok"
	var why := ""
	if cd > 0: why = "a package was adopted in %s; another is possible from %s" % [SimDB.date_label(last), SimDB.date_label(st.turn + cd)]
	elif st.inflation < float(f.get("min_inflation", 40)) and not structural_alarm() and fcl == "ok":
		why = "only in a crisis: inflation from %d%%, a structural deficit or a fiscal collapse in sight" % int(f.get("min_inflation", 40))
	var eff := ["Upkeep %d%% for %d years" % [int(f.get("upkeep_pct", -15)), int(f.get("upkeep_quarters", 12)) / 4],
		("Inflation brought back to history's rate (now %.0f%%) and anchored for %s years" % [st.inflation, str(snappedf(float(f.get("anchor_quarters", 8)) / 4.0, 0.5))]) if float(f.get("gap_keep", 0.25)) <= 0.0 else ("Inflation brought down: the gap above history's rate cut to a quarter (now %.0f%%), and held for %d years" % [st.inflation, int(f.get("anchor_quarters", 8)) / 4]),
		"%+d Civic Trust in every city (wage freeze and cuts)" % int(f.get("trust_all", -5)),
		"%+d amenity in every city and %d%% Production for a year (a recession)" % [int(f.get("amenity_all", -1)), int(f.get("production_pct", -6))]]
	return {"id": str(v.get("id", "")), "name": str(v.get("name", "")), "desc": str(v.get("desc", "")), "available": why == "", "reason": why,
		"historical": SimDB.year_of(st.turn) == int(v.get("historical", 0)), "hist_year": int(v.get("historical", 0)), "advocate": str(v.get("advocate", "")),
		"cite": v.get("cite", []), "source": v.get("source", []), "effects_text": eff, "last": last, "cooldown_left": maxi(0, cd)}


func stabilise() -> bool:
	var st := S()
	var o := stabilisation_option()
	if not o["available"]:
		return false
	var f: Dictionary = fiscal_data().get("stabilisation", {})
	st.counters["stabilised_turn"] = st.turn
	st.counters["stab_anchor_until"] = st.turn + int(f.get("anchor_quarters", 8))
	st.temp_effects.append({"type": "maintenance_pct", "pct": float(f.get("upkeep_pct", -15)), "until": st.turn + int(f.get("upkeep_quarters", 12)) - 1, "src": "stabilisation"})
	st.temp_effects.append({"type": "amenity", "amount": float(f.get("amenity_all", -1)), "until": st.turn + int(f.get("amenity_quarters", 4)) - 1, "src": "stabilisation"})
	st.temp_effects.append({"type": "yield_pct", "yield": "production", "pct": float(f.get("production_pct", -6)), "until": st.turn + int(f.get("production_quarters", 4)) - 1, "src": "stabilisation"})
	var before := st.inflation
	var gap: float = sim.inflation_gap() * float(f.get("gap_keep", 0.25))
	st.counters["inflation_gap"] = gap
	var base: float = sim.inflation_baseline(SimDB.year_f(st.turn)) + sim.inflation_terms()
	st.inflation = clampf((exp(log(1.0 + base / 100.0) + gap) - 1.0) * 100.0, -5.0, 2000.0)
	sim.stat_note("inflation", st.inflation - before, "Stabilisation package: " + str(o["name"]))
	var ta := float(f.get("trust_all", -5))
	for c in sim.active_cities(): c.trust = clampf(c.trust + ta, 0.0, 100.0)
	sim.stat_note("trust", ta, "Stabilisation package: wage freeze and cuts")
	_lever_log("stabilise", str(o["name"]))
	sim.notify("budget", "Stabilisation package: %s. Upkeep %d%% for %d years; inflation down from %.0f%% to %.0f%%; Civic Trust %+d everywhere." % [str(o["name"]),
		int(f.get("upkeep_pct", -15)), int(f.get("upkeep_quarters", 12)) / 4, before, st.inflation, int(ta)], {"stabilisation": str(o["id"])})
	sim.refresh()
	return true


# ---- v3 final round (fix4-econ, N1): scale back or suspend a costly policy card
# History's own cuts are the model: the 1985 stabilisation plan cut government spending deeply, and the 2002-03 budgets
# cut allowances and social services (data/fiscal.json "policy_cuts"). A card at half strength costs half and gives
# half its benefits; a suspended card keeps its slot and does nothing. Each costs Civic Trust (and Cohesion when
# suspended); restoring is free. Unslotting the card ends the cut.

func policy_card_cost(pid: String, full := true) -> float:
	## Gold a quarter the slotted card costs (gold_per_pop at today's population plus negative gold_per_turn); at full
	## strength when `full`, else as it runs now.
	var pd: Dictionary = db().policies.get(pid, {})
	var pop := float(sim.national().get("pop", 0))
	var c := 0.0
	for e in pd.get("effects", []):
		var a := float(e.get("amount", 0))
		var ty := str(e.get("type", ""))
		if a < 0.0 and ty == "gold_per_pop": c += -a * pop
		elif a < 0.0 and ty == "gold_per_turn": c += -a
	if not full:
		match str(S().counters.get("policy_cuts", {}).get(pid, "")):
			"half": c *= 0.5
			"suspend": c = 0.0
	return c


func _cut_version() -> Dictionary:
	var y := SimDB.year_of(S().turn)
	for v in fiscal_data().get("policy_cuts", {}).get("versions", []):
		if y <= int(v.get("until", 2100)): return v
	return {}


func policy_costs() -> Array:
	## sim.get_policy_costs(): [{id, name, cost, full_cost, state: full|half|suspended, saves_half, saves_suspend,
	##   options: [{mode: half|suspend|restore, label, desc, saves, effects_text, advocate, cite, source, historical, hist_label,
	##   available, reason}]}], costliest first. Only slotted cards that cost gold.
	var st := S()
	var f: Dictionary = fiscal_data().get("policy_cuts", {})
	var v := _cut_version()
	var cuts: Dictionary = st.counters.get("policy_cuts", {})
	var min_cost := float(f.get("min_cost", 2.0))
	var out := []
	for slot in st.policies:
		var pid := str(slot.get("id", ""))
		if pid == "" or not db().policies.has(pid):
			continue
		var full := policy_card_cost(pid, true)
		if full < min_cost:
			continue
		var nm := str(db().policies[pid].get("name", pid))
		var state: String = {"half": "half", "suspend": "suspended"}.get(str(cuts.get(pid, "")), "full")
		var hist: bool = absi(SimDB.year_of(st.turn) - int(v.get("historical", 0))) <= 1
		var opts := []
		var hf: Dictionary = f.get("half", {})
		var sf: Dictionary = f.get("suspend", {})
		if state == "full":
			opts.append({"mode": "half", "label": "Scale back %s: half its cost and half its benefits" % nm, "desc": str(v.get("desc", "")), "saves": snappedf(full * 0.5, 0.1),
				"effects_text": ["+%d Gold a quarter (half the card's cost)" % int(round(full * 0.5)), "Half the card's benefits", "%+d Civic Trust in every city" % int(hf.get("trust_all", -2))]})
		if state != "suspended":
			var sv := full * (1.0 if state == "full" else 0.5)
			var eff := ["+%d Gold a quarter (no cost)" % int(round(sv)), "None of the card's benefits; it keeps its slot", "%+d Civic Trust in every city" % int(sf.get("trust_all", -4))]
			if float(sf.get("cohesion", 0)) != 0.0: eff.append("%+d Cohesion" % int(sf.get("cohesion", 0)))
			opts.append({"mode": "suspend", "label": "Suspend %s" % nm, "desc": str(v.get("desc", "")), "saves": snappedf(sv, 0.1), "effects_text": eff})
		if state != "full":
			opts.append({"mode": "restore", "label": "Restore %s in full" % nm, "desc": "", "saves": -snappedf(full - policy_card_cost(pid, false), 0.1),
				"effects_text": ["%d Gold a quarter (the card's full cost)" % -int(round(full - policy_card_cost(pid, false))), "The card's full benefits"]})
		for o in opts:
			o["available"] = true
			o["reason"] = ""
			if str(o["mode"]) != "restore":
				o["advocate"] = str(v.get("advocate", "")); o["cite"] = v.get("cite", []); o["source"] = v.get("source", [])
				o["historical"] = hist; o["hist_label"] = str(v.get("hist_label", ""))
			else:
				o["advocate"] = ""; o["cite"] = []; o["source"] = []; o["historical"] = false; o["hist_label"] = ""
		out.append({"id": pid, "name": nm, "cost": snappedf(policy_card_cost(pid, false), 0.1), "full_cost": snappedf(full, 0.1), "state": state,
			"saves_half": snappedf(full * 0.5, 0.1) if state == "full" else 0.0, "saves_suspend": snappedf(policy_card_cost(pid, false), 0.1), "options": opts})
	out.sort_custom(func(a, b): return float(a["cost"]) > float(b["cost"]))
	return out


func scale_back_policy(pid: String, mode: String) -> String:
	## mode "half" | "suspend": "" on success, else why not.
	var st := S()
	var f: Dictionary = fiscal_data().get("policy_cuts", {})
	if not (mode in ["half", "suspend"]):
		return "unknown mode"
	var slotted := false
	for slot in st.policies:
		if str(slot.get("id", "")) == pid: slotted = true
	if not slotted:
		return "the card is not in a slot"
	if policy_card_cost(pid, true) < float(f.get("min_cost", 2.0)):
		return "the card costs no gold"
	var cuts: Dictionary = st.counters.get("policy_cuts", {})
	var cur := str(cuts.get(pid, ""))
	if cur == mode or cur == "suspend":
		return "already " + ("suspended" if cur == "suspend" else "at half strength")
	var saved := policy_card_cost(pid, false)
	cuts[pid] = mode
	st.counters["policy_cuts"] = cuts
	saved -= policy_card_cost(pid, false)
	var cfg: Dictionary = f.get(mode, {})
	var ta := float(cfg.get("trust_all", -2.0 if mode == "half" else -4.0))
	var nm := str(db().policies.get(pid, {}).get("name", pid))
	for c in sim.active_cities(): c.trust = clampf(c.trust + ta, 0.0, 100.0)
	sim.stat_note("trust", ta, ("Scaled back: " if mode == "half" else "Suspended: ") + nm)
	var coh := float(cfg.get("cohesion", 0.0))
	if coh != 0.0:
		st.cohesion = maxf(0.0, st.cohesion + coh)
		sim.stat_note("cohesion", coh, "Suspended: " + nm)
	_lever_log("policy_cut", "%s (%s)" % [nm, mode])
	sim.notify("budget", "%s %s: about %d gold a quarter saved; Civic Trust %+d everywhere." % [nm, "runs at half strength" if mode == "half" else "is suspended", int(round(saved)), int(ta)],
		{"policy_cut": pid, "mode": mode, "saves": saved})
	sim.refresh()
	return ""


func restore_policy(pid: String) -> String:
	var st := S()
	var cuts: Dictionary = st.counters.get("policy_cuts", {})
	if not cuts.has(pid):
		return "the card runs in full"
	cuts.erase(pid)
	st.counters["policy_cuts"] = cuts
	_lever_log("policy_restore", str(db().policies.get(pid, {}).get("name", pid)))
	sim.notify("budget", "%s is restored in full." % str(db().policies.get(pid, {}).get("name", pid)), {"policy_restored": pid})
	sim.refresh()
	return ""


# ---- the structural-deficit agenda item and the reports for the UI

func structural_agenda(net: float) -> Dictionary:
	## The Cabinet Agenda item while the structural-deficit alarm is on (from deficit_agenda): mothball, privatise, a
	## stabilisation package, or a tax rise. It names the upkeep. The Recommended pick follows the situation.
	var st := S()
	var gap := structural_gap()
	var plan := mothball_plan(gap * 1.1)
	var pl_save := 0.0
	for x in plan: pl_save += float(x["saves"])
	var opts := []
	var scores := []
	if not plan.is_empty():
		opts.append({"label": "Mothball %d little-used buildings (saves about %d gold a quarter)" % [plan.size(), int(round(pl_save))],
			"fx": {"econ_action": "mothball_plan", "target": gap * 1.1}, "default": false,
			"desc": "Stops the buildings that do least for their towns per gold of upkeep: " + ", ".join(plan.slice(0, 5).map(func(x): return "%s in %s" % [str(x["name"]), str(x["city_name"])])) + (" and %d more" % (plan.size() - 5) if plan.size() > 5 else "") + ". They can be reopened later.",
			"effects_extra": [{"stat": "gold", "amount": snappedf(pl_save, 0.1), "unit": "per turn (upkeep saved)", "when": "lasting", "good": true},
				{"stat": "amenity", "amount": -1.0, "unit": "where a service building stops", "when": "while mothballed", "good": false}]})
		scores.append(1.2 + minf(1.0, pl_save / maxf(1.0, gap)) - 0.15 * float(plan.size()) / 10.0)
	var pv := next_privatisation()
	if not pv.is_empty():
		opts.append({"label": "Privatise: %s (+%d gold now, upkeep %d%% for %d years)" % [str(pv["name"]), int(pv["gold"]), int(pv["upkeep_pct"]), int(pv["years"])],
			"fx": {"econ_action": "privatise", "id": str(pv["id"])}, "default": false, "desc": str(pv["desc"]), "advocate": str(pv["advocate"]), "cite": pv["cite"], "historical": pv["historical"],
			"effects_extra": [{"stat": "gold", "amount": float(pv["gold"]), "unit": "points", "when": "now", "good": true},
				{"stat": "upkeep", "amount": float(pv["upkeep_pct"]), "unit": "%", "when": "%d years" % int(pv["years"]), "good": true},
				{"stat": "trust", "amount": float(pv["trust"]), "unit": "points in every city", "when": "now", "good": false}]})
		scores.append(1.0 + (0.8 if st.gold < 0.0 else 0.0) + (0.4 if pv["historical"] else 0.0))
	var pcs := policy_costs().filter(func(x): return str(x["state"]) == "full")
	if not pcs.is_empty():
		# v3 final round (fix4-econ, N1): the costliest policy card at half strength (history's own cuts)
		var pc: Dictionary = pcs[0]
		var po: Dictionary = pc["options"][0]
		opts.append({"label": "%s (saves about %d gold a quarter)" % [str(po["label"]), int(round(float(pc["saves_half"])))],
			"fx": {"econ_action": "scale_back_policy", "id": str(pc["id"]), "mode": "half"}, "default": false, "desc": str(po["desc"]), "advocate": str(po["advocate"]),
			"cite": po["cite"], "historical": po["historical"],
			"effects_extra": [{"stat": "gold", "amount": float(pc["saves_half"]), "unit": "per turn (card cost saved)", "when": "lasting", "good": true},
				{"stat": "trust", "amount": float(fiscal_data().get("policy_cuts", {}).get("half", {}).get("trust_all", -2)), "unit": "points in every city", "when": "now", "good": false}]})
		scores.append(1.1 + minf(1.0, float(pc["saves_half"]) / maxf(1.0, gap)) + (0.3 if po["historical"] else 0.0) - (0.6 if _avg_trust_all() < 62.0 else 0.0))
	var so := stabilisation_option()
	if so["available"]:
		var f: Dictionary = fiscal_data().get("stabilisation", {})
		opts.append({"label": "%s: upkeep %d%% for 3 years and inflation brought down, at a cost in trust" % [str(so["name"]), int(f.get("upkeep_pct", -15))],
			"fx": {"econ_action": "stabilise"}, "default": false, "desc": str(so["desc"]), "advocate": str(so["advocate"]), "cite": so["cite"], "historical": so["historical"],
			"effects_extra": [{"stat": "upkeep", "amount": float(f.get("upkeep_pct", -15)), "unit": "%", "when": "3 years", "good": true},
				{"stat": "inflation", "amount": -roundf(st.inflation * 0.6), "unit": "percentage points (about)", "when": "now", "good": true},
				{"stat": "trust", "amount": float(f.get("trust_all", -5)), "unit": "points in every city", "when": "now", "good": false}]})
		var fcl: String = sim.collapse.level_of("collapse_fiscal") if sim.collapse != null else "ok"
		scores.append(0.8 + st.inflation / 80.0 + (1.5 if fcl == "danger" else 0.0) - (1.0 if _avg_trust_all() < 60.0 else 0.0))
	opts.append({"label": "Raise taxes", "fx": {"temp": {"type": "yield_pct", "yield": "gold", "pct": 15}, "turns": 8, "amenity_all": -1}, "default": false})
	scores.append(0.9 + (0.6 if gap < 0.25 * float(structural().get("revenue", 1.0)) else 0.0))
	# v3 final round (fix4-econ): borrowing is on the table too, as it was for every government, but it only postpones
	# the deficit (never the Recommended pick)
	var sc := float(sim.events.gold_scale())
	var bamt := roundf(minf(maxf(140.0 * sc, gap * 6.0), borrow_room()))
	if bamt >= 20.0 * sc:
		var bsvc := bamt / float(DEBT_TERM_Q) + bamt * DEBT_RATE_Q
		opts.append({"label": "Borrow abroad to cover the gap: +%s gold now, repaid with interest over fifteen years (about %s a quarter); it only postpones the deficit" % [_fmt_n(bamt), _fmt_n(bsvc)],
			"fx": {"borrow": bamt, "inflation": 4}, "default": false})
		scores.append(-9.0)
	# no pick is Recommended every time: the last Recommended answer scores lower the next time
	var last := str(st.counters.get("struct_last_rec", ""))
	var best := 0
	for i in range(opts.size()):
		if str(opts[i]["fx"].get("econ_action", "tax")) == last: scores[i] = float(scores[i]) - 0.7
		if float(scores[i]) > float(scores[best]): best = i
	opts[best]["default"] = true
	st.counters["struct_last_rec"] = str(opts[best]["fx"].get("econ_action", "tax"))
	var txt := "%s\nThe budget cannot carry this for long: every such quarter adds to the overdraft or the debt and pushes prices up. Treasury %s, net %+d a quarter." % [upkeep_text(), _fmt_n(S().gold), int(net)]
	return {"id": "budget", "severity": 7.5, "title": "Structural deficit", "text": txt, "options": opts, "structural": true}


func agenda_action(fx: Dictionary) -> void:
	## Sim.choose_agenda: the structural-deficit levers chosen at the Cabinet Agenda.
	match str(fx.get("econ_action", "")):
		"mothball_plan": mothball_many(mothball_plan(float(fx.get("target", 0.0))))
		"privatise": privatise(str(fx.get("id", "")))
		"stabilise": stabilise()
		"scale_back_policy": scale_back_policy(str(fx.get("id", "")), str(fx.get("mode", "half")))


func fiscal_report() -> Dictionary:
	## Everything the UI needs for the fiscal levers (sim.get_fiscal_report()): {revenue, upkeep, parts: {buildings, public,
	## districts, units, mothballed, pct}, debt_service, ratio, alarm, quarters_over, since, gap, text, top_cities: [{id, name, upkeep, buildings}],
	## mothballed: [{city, city_name, building, name, reopen_cost}], mothball_plan: [...], privatisations: [...], stabilisation: {...},
	## levers_used: {mothball, reopen, close, privatise, stabilise}}.
	var p: Dictionary = S().counters.get("upkeep_parts", {})
	var s := structural()
	var mb := []
	for c in sim.active_cities():
		for b in mothballed(c):
			mb.append({"city": c.id, "city_name": c.name, "building": str(b), "name": str(db().buildings.get(b, {}).get("name", b)), "reopen_cost": reopen_cost(str(b))})
	# v3 final round (fix4-econ, N1): every line of the budget; the lines (without the programmes) add up to the net
	var bl: Dictionary = S().counters.get("budget_lines", {})
	var lines: Array = (bl.get("lines", []) as Array).duplicate(true)
	var prog := float(S().counters.get("last_budget", {}).get("programmes", 0.0))
	if prog < 0.0:
		lines.append({"id": "programmes", "label": "National programmes (investment, paid from the surplus)", "amount": snappedf(prog, 0.01), "kind": "investment", "items": []})
	return {"revenue": float(s.get("revenue", 0.0)), "upkeep": float(p.get("total", 0.0)),
		"parts": {"buildings": float(p.get("buildings", 0.0)), "public": float(p.get("public", 0.0)), "districts": float(p.get("districts", 0.0)),
			"units": float(p.get("units", 0.0)), "mothballed": float(p.get("mothballed", 0.0)), "readiness": float(p.get("readiness", 0.0)), "pct": float(p.get("pct", 0.0))},
		"debt_service": float(s.get("service", 0.0)), "ratio": float(s.get("ratio", 0.0)), "ratio_running": float(s.get("ratio_running", s.get("ratio", 0.0))),
		"outflow": float(s.get("outflow", float(p.get("total", 0.0)) + float(s.get("service", 0.0)))), "net": float(bl.get("net", S().counters.get("last_budget", {}).get("net", 0.0))),
		"limit": float(s.get("limit", fiscal_data().get("structural", {}).get("ratio", 1.1))), "lines": lines,
		"alarm": structural_alarm(), "quarters_over": int(s.get("q", 0)),
		"since": int(s.get("since", -1)), "gap": structural_gap(), "text": upkeep_text(), "top_cities": (p.get("cities", []) as Array).slice(0, 5),
		"mothballed": mb, "mothball_plan": mothball_plan(), "privatisations": privatisation_options(), "stabilisation": stabilisation_option(),
		"policy_cards": policy_costs(), "levers_used": lever_counts()}


func city_upkeep(c: SimCity) -> Dictionary:
	## The city screen's "Treasury: upkeep" line: {total, buildings: [{id, name, upkeep, value, service}], mothballed: [{id, name, reopen_cost}]}.
	var mult := maxf(0.0, 1.0 + mod_sum("maintenance_pct", "pct") / 100.0)
	var keep := float(fiscal_data().get("mothball", {}).get("keep_upkeep", 0.2))
	var rows := []
	var tot := 0.0
	for b in c.buildings:
		var up := float(db().buildings.get(b, {}).get("upkeep", 0)) * mult
		tot += up
		if up > 0.0:
			rows.append({"id": str(b), "name": str(db().buildings.get(b, {}).get("name", b)), "upkeep": snappedf(up, 0.1), "value": snappedf(building_value(c, b), 0.01), "service": is_service_building(b)})
	for d in c.districts:
		if db().districts.get(d, {}).get("specialty", false): tot += mult
	var mrows := []
	for b2 in mothballed(c):
		tot += float(db().buildings.get(b2, {}).get("upkeep", 0)) * keep * mult
		mrows.append({"id": str(b2), "name": str(db().buildings.get(b2, {}).get("name", b2)), "reopen_cost": reopen_cost(str(b2))})
	return {"total": snappedf(tot, 0.1), "buildings": rows, "mothballed": mrows}
