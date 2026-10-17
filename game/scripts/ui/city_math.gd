class_name CityMath
extends RefCounted
## UI-side breakdowns of a city's growth, food, housing and amenities (Civ VI City Details tooltips).
## Reads the sim's own formulas (sim_economy.gd) without changing state. Requested as a sim API in
## progress/INTEGRATION_REQUESTS.md (get_city_breakdown); switch to it when it exists.


static func growth(sim, c) -> Dictionary:
	var e = sim.econ
	var info: Dictionary = c.info
	var pf := sqrt(maxf(c.residents, 0.0) / 1000.0)
	var hf: float = e.housing_factor(c)
	var amen_pct := float(info.get("amenity_growth_pct", 0))
	var trust_pct := float(e.trust_band(c.trust)[2])
	var bld_pct := float(info.get("growth_pct", 0))
	var ff := 1.0
	if e.food_ratio < 1.0:
		ff = 0.6 + 0.4 * e.food_ratio
	else:
		var surplus: float = float(c.y.get("food", 0.0)) - 2.0 * c.pop()
		ff = 1.0 + clampf(surplus / maxf(1.0, c.pop()) * 0.05, 0.0, 0.1)
	var m := hf * (1.0 + amen_pct / 100.0) * (1.0 + trust_pct / 100.0) * (1.0 + bld_pct / 100.0) * ff
	if c.damaged > 0:
		m *= 0.5
	m = clampf(m, 0.0, 1.2)
	var nat: float = e.nat_rate(sim.year())
	return {"pf": pf, "housing": float(info.get("housing", pf)), "housing_f": hf, "amen_pct": amen_pct, "trust_pct": trust_pct,
		"bld_pct": bld_pct, "food_f": ff, "damaged": c.damaged > 0, "mult": m, "nat": nat, "gain": c.residents * nat / 4.0 * m / 1.1}


static func food(sim, c) -> Dictionary:
	var tiles := 0.0
	var worked: Array = c.info.get("worked", [])
	for k in worked:
		tiles += float(sim.econ.tile_yield(int(k), c).get("food", 0.0))
	return {"tiles": tiles, "tiles_n": worked.size(), "other": float(c.y.get("food", 0.0)) - tiles}


static func housing(sim, c) -> Dictionary:
	var db = sim.db
	var b := 0.0
	for id in c.buildings:
		b += float(db.buildings.get(id, {}).get("housing", 0))
	var imp := 0.0
	for k in sim.econ.city_tile_keys(c):
		var i := str(sim.econ.tstate(k).get("imp", ""))
		if i != "":
			imp += float(db.improvements.get(i, {}).get("housing", 0))
	var total := float(c.info.get("housing", 0))
	var out := {}
	out["Existing housing stock"] = c.legacy_housing
	if b != 0: out["Buildings"] = b
	if imp != 0: out["Farms and other improvements"] = imp
	out["City size, water, districts and policies"] = total - c.legacy_housing - b - imp
	out["Total"] = total
	return out


static func amenities(sim, c) -> Dictionary:
	var db = sim.db
	var b := 0.0
	for id in c.buildings:
		b += float(db.buildings.get(id, {}).get("amenities", 0))
	var src := {}
	src["Existing services"] = c.legacy_amenities
	if b != 0: src["Buildings"] = b
	var ts := float(c.info.get("transit_share", 0))
	var tp := -minf(3.0, floor(ts / 0.08))
	if tp != 0: src["Transit camps"] = tp
	var ww := -float(c.info.get("weariness", 0))
	if ww != 0: src["War weariness"] = ww
	var nat := 0.0
	if sim.state.gold < 0: nat -= 1.0
	if float(sim.state.water.get("ratio", 1.0)) < 0.85: nat -= 1.0
	if float(sim.state.water.get("reserve", 70.0)) < 20.0: nat -= 1.0
	if sim.state.inflation > 50.0: nat -= 1.0
	if nat != 0: src["National: debt, water, inflation"] = nat
	var total := float(c.info.get("amen_sources", 0))
	var known := 0.0
	for k in src:
		known += float(src[k])
	src["Luxuries, districts, policies and other"] = total - known
	return {"src": src, "total": total}
