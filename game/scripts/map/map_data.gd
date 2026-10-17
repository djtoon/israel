class_name MapData
extends RefCounted
## Loads game/data/map.json (falls back to the renderer's temporary stand-in) plus game/data/cities.json
## and derives per-hex render data for a given in-game date: which localities exist, their names,
## who controls them, their size, the border era, urban tiles and the hex data textures.

const REAL_PATH := "res://data/map.json"
const STANDIN_PATH := "res://scripts/map/standin_map.json"
const CITIES_PATH := "res://data/cities.json"

var src_path := ""
var cols := 0
var rows := 0
var hex_km := 5.0
var tiles: Array = []
var grid := {}            # Vector2i(q,r) -> tile dict
var places: Array = []
var raw_cities: Array = []  # records from cities.json (or the stand-in list)
var cities: Array = []    # localities that exist at `date` (see _city_at)
var borders := {}
var border_eras: Array = []
var border_era := ""
var urban := {}           # Vector2i -> 1 (town/city core) or 2 (big-city fabric that fills the whole hex)
var tm := TerrainMath.new()
var lat0 := 33.45
var lon0 := 34.15
var km_lat := 110.86
var km_lon := 94.97
var date := "1948-05-15"
var year := 1948
var epoch_key := ""
var jaffa_hex := Vector2i(-1, -1)
var old_city_hex := Vector2i(-1, -1)   # Jerusalem Old City (map.json place)
var military_control := {}             # era id -> [[q, r]]: held only militarily / de facto (subset of borders[era])
var natural_wonders: Array = []        # [{id, name, name_he, hexes, kind, source}]
var hist_tiles: Array = []             # tiles with historical_change (Hula drainage, Dead Sea southern basin)
var forced := {}                       # id -> true: localities founded early by the player (MapView.force_city)
var city_info := {}                   # id -> {display_pop, name, badge}: overrides from gameplay (MapView.set_city_info)
var urban_owner := {}                 # Vector2i -> city dict whose fabric fills the hex
var district := {}                     # Vector2i -> "old" etc. renderer district overrides

# Renderer-only fallback list if game/data/cities.json is missing: [name, lat, lon, pop, kind]
const FALLBACK_CITIES := [
	["Tel Aviv-Yafo", 32.0853, 34.7818, 400000, "city"], ["Jerusalem", 31.7780, 35.2200, 500000, "city"],
	["Haifa", 32.7940, 34.9896, 250000, "city"], ["Beersheba", 31.2520, 34.7915, 150000, "city"],
	["Gaza City", 31.5017, 34.4668, 300000, "palestinian_city"], ["Nablus", 32.2211, 35.2544, 100000, "palestinian_city"],
]

# Status ids in cities.json -> controlling party shown on the banner badge.
const CONTROL := {
	"israel": "israel", "israel_west_only": "israel", "israel_with_annexed_east": "israel",
	"israel_military_government": "israel", "israeli_law_applied": "israel",
	"israeli_occupied": "israel_occupied", "israeli_settlement": "israel_occupied", "divided_h1_h2": "israel_occupied",
	"jordanian_administered": "jordan", "egyptian_administered": "egypt", "syria": "syria", "syria_un_buffer": "syria",
	"palestinian_authority": "palestine", "pa_area_a": "palestine", "hamas_controlled": "hamas",
	"pa_area_a_idf_operations": "palestine", "egyptian_held": "egypt", "jordanian_held": "jordan",
	"israeli_controlled": "israel", "syrian_held": "syria", "lebanese_held": "lebanon", "iraqi_held": "iraq", "hamas_de_facto": "hamas",
	# before a 1948-49 capture or armistice transfer: shown, but not Israeli and not playable
	"contested": "contested", "arab_held": "contested", "israeli_forces_present": "contested",
}

# Renderer-side naming by date (cities.json carries the modern name). Tel Aviv and Jaffa merged on 24 Apr 1950.
const GOV_PATH := "res://data/governments.json"   # city_names: dated names, shared with the sim (Sim.city_name_at)
var city_names: Array = []


static func real_map_exists() -> bool:
	return FileAccess.file_exists(REAL_PATH)


static func norm_date(s) -> String:
	if s == null:
		return ""
	var t := str(s)
	if t.length() == 4: return t + "-01-01"
	if t.length() == 7: return t + "-01"
	return t.substr(0, 10)


static func turn_to_date(turn: int) -> String:
	## turn 1 = Q2 1948 (State declared 14 May 1948); a turn is one quarter. Date = middle month, 15th.
	var m0 := 3 + (turn - 1) * 3            # months after Jan 1948 of the quarter start
	var y := 1948 + m0 / 12
	var mon := m0 % 12 + 2                  # middle month of the quarter (1-based)
	return "%04d-%02d-15" % [y, mon]


func latlon_to_offset(lat: float, lon: float) -> Vector2i:
	var r := int(round((lat0 - lat) * km_lat / (hex_km * sqrt(3.0) / 2.0)))
	var q := int(round((lon - lon0) * km_lon / hex_km - 0.5 * (r & 1)))
	return Vector2i(q, r)


func latlon_to_world(lat: float, lon: float) -> Vector2:
	var s := TerrainMath.SQ3 / hex_km
	return Vector2((lon - lon0) * km_lon * s, (lat0 - lat) * km_lat * s)


func load_map() -> bool:
	src_path = REAL_PATH if FileAccess.file_exists(REAL_PATH) else STANDIN_PATH
	var d = JSON.parse_string(FileAccess.get_file_as_string(src_path))
	if typeof(d) != TYPE_DICTIONARY:
		push_error("map: failed to parse " + src_path)
		return false
	cols = int(d.get("cols", 0)); rows = int(d.get("rows", 0))
	hex_km = float(d.get("hex_km", 5.0))
	tiles = d.get("tiles", [])
	for t in tiles:
		var k := Vector2i(int(t["q"]), int(t["r"]))
		grid[k] = t
		cols = maxi(cols, k.x + 1); rows = maxi(rows, k.y + 1)
	places = d.get("places", [])
	var mc = d.get("military_control", {})
	military_control = mc if typeof(mc) == TYPE_DICTIONARY else {}
	var nw = d.get("natural_wonders", [])
	natural_wonders = nw if typeof(nw) == TYPE_ARRAY else []
	_landform_overrides()
	_carmel_override()
	for t in tiles:
		if t.get("historical_change") != null:
			t["_terrain0"] = t["terrain"]
			hist_tiles.append(t)
	borders = d.get("borders", {})
	var be = d.get("border_eras", [])
	border_eras = be if typeof(be) == TYPE_ARRAY else []
	var o = d.get("origin", {})
	var pr = d.get("projection", {})
	if typeof(o) == TYPE_DICTIONARY:
		lat0 = float(o.get("lat", lat0)); lon0 = float(o.get("lon", lon0))
	if typeof(pr) == TYPE_DICTIONARY:
		km_lat = float(pr.get("km_per_deg_lat", km_lat)); km_lon = float(pr.get("km_per_deg_lon", km_lon))
	_load_raw_cities()
	if FileAccess.file_exists(GOV_PATH):
		var g = JSON.parse_string(FileAccess.get_file_as_string(GOV_PATH))
		if typeof(g) == TYPE_DICTIONARY and typeof(g.get("city_names")) == TYPE_ARRAY:
			city_names = g["city_names"]
	jaffa_hex = latlon_to_offset(32.0505, 34.7550)
	var oc := find_place("Jerusalem Old City")
	if not oc.is_empty():
		old_city_hex = Vector2i(int(oc["q"]), int(oc["r"]))
	set_date(date, true)
	print("map: loaded ", src_path, " ", cols, "x", rows, " tiles=", tiles.size(), " places=", places.size(), " localities=", raw_cities.size())
	return true


func _load_raw_cities() -> void:
	raw_cities.clear()
	if FileAccess.file_exists(CITIES_PATH):
		var arr = JSON.parse_string(FileAccess.get_file_as_string(CITIES_PATH))
		if typeof(arr) == TYPE_ARRAY:
			raw_cities = arr
	if raw_cities.is_empty():
		for c in FALLBACK_CITIES:
			raw_cities.append({"id": c[0].to_snake_case(), "name": c[0], "lat": c[1], "lon": c[2], "kind": c[4],
				"population": {"2022": c[3]}, "status": []})
	# Jaffa as its own place until the April 1950 merger (renderer-side; cities.json only has Tel Aviv-Yafo)
	var has_jaffa := false
	for c in raw_cities:
		if str(c.get("id", "")) == "jaffa":
			has_jaffa = true
	if not has_jaffa:
		raw_cities.append({"id": "jaffa", "name": "Jaffa", "name_he": "יפו", "kind": "city", "lat": 32.0505, "lon": 34.7550,
			"founded": null, "status": [{"from": "1948-05-14", "to": "1950-04-24", "status": "israel"}],
			"population": {}, "renderer_note": "Merged into Tel Aviv-Yafo on 24 April 1950"})


# ------------------------------------------------------------------ date

func set_date(d: String, force := false) -> bool:
	## returns true if anything visible on the map changed (cities / borders)
	date = norm_date(d)
	year = int(date.substr(0, 4))
	var era := _border_era_at(date)
	var list := []
	for c in raw_cities:
		var e := _city_at(c, date)
		if e.is_empty() and forced.has(str(c.get("id", ""))):
			e = _city_at(c, date, true)
		if not e.is_empty():
			list.append(e)
	# Divided Jerusalem 1948-67: West Jerusalem (Israel) and the Old City / East Jerusalem (Jordan)
	for i in list.size():
		var c: Dictionary = list[i]
		if c["id"] == "jerusalem" and c["status"] == "israel_west_only" and old_city_hex.x >= 0:
			var west := old_city_hex + Vector2i(-1, 0)
			if Vector2i(c["q"], c["r"]) == old_city_hex or not owner_at_date(Vector2i(c["q"], c["r"]), era):
				c["q"] = west.x; c["r"] = west.y
				c["pos"] = TerrainMath.offset_center(west.x, west.y)
			break
	# several localities can fall on one hex: keep the largest
	list.sort_custom(func(a, b): return a["pop"] > b["pop"])
	var seen := {}
	var new_cities := []
	for c in list:
		var k := Vector2i(c["q"], c["r"])
		if seen.has(k):
			continue
		seen[k] = true
		new_cities.append(c)
	# the key holds everything that changes the 3D map; banner-only changes update the dicts in place
	var hist := _apply_historical_terrain()
	var key := era + "|" + hist + "|" + str(int(year / 4))
	for c in new_cities:
		var pb := int(c["pop"] / 8000) if c["pop"] < 40000 else 5 + int(c["pop"] / 27500)
		key += "|%s:%d:%s:%s" % [c["id"], pb, c["control"], c["name"]]
	if key == epoch_key and not force:
		var by_id := {}
		for c in new_cities:
			by_id[c["id"]] = c
		for c in cities:
			var n: Dictionary = by_id.get(c["id"], {})
			for f in ["pop", "size", "display_pop", "status", "status_note"]:
				if n.has(f):
					c[f] = n[f]
		apply_city_info()
		return false
	cities = new_cities
	epoch_key = key
	border_era = era
	apply_city_info()
	_compute_urban()
	_build_math()
	return true


func _apply_historical_terrain() -> String:
	## terrain that changed during 1948-2023 (map.json historical_change): switch at the date
	var sig := ""
	for t in hist_tiles:
		var hc: Dictionary = t["historical_change"]
		var after := date >= norm_date(hc.get("date", "9999"))
		t["terrain"] = str(hc.get("to_terrain", t["_terrain0"])) if after else str(t["_terrain0"])
		sig += "1" if after else "0"
	return sig


var elev_override := {}   # Vector2i -> metres used for rendering only (crater floors / rims read as landforms)


func _landform_overrides() -> void:
	## Makhteshim are carved analytically (TerrainMath.crater_carve + the same code in hexcommon.gdshaderinc);
	## hex means can't hold a 500 m deep, cliff-walled oval. Here we fit the oval to the wonder's hexes.
	tm.craters.clear()
	for w in natural_wonders:
		if str(w.get("kind", "")) != "crater" or tm.craters.size() >= 3:
			continue
		var pts: Array[Vector2] = []
		var c := Vector2.ZERO
		for qr in w.get("hexes", []):
			var p := TerrainMath.offset_center(int(qr[0]), int(qr[1]))
			pts.append(p); c += p
		if pts.is_empty():
			continue
		c /= pts.size()
		var cxx := 0.0; var cxz := 0.0; var czz := 0.0
		for p in pts:
			var d := p - c
			cxx += d.x * d.x; cxz += d.x * d.y; czz += d.y * d.y
		var ang := 0.5 * atan2(2.0 * cxz, cxx - czz) if pts.size() > 2 else 0.0
		var ax := Vector2(cos(ang), sin(ang))
		var ext := 0.0
		for p in pts:
			ext = maxf(ext, absf((p - c).dot(ax)))
		var L := maxf(ext + 0.9, 1.5)
		var W := maxf(L * 0.25, 0.7)
		var rim := base_height({"terrain": "desert", "elevation_m": 1150.0 if L > 5.0 else 800.0, "q": -1, "r": -1})
		var flo := base_height({"terrain": "desert", "elevation_m": 300.0 if L > 5.0 else 250.0, "q": -1, "r": -1})
		tm.craters.append({"c": c, "ax": ax, "L": L, "W": W, "rim": rim, "floor": flo})


func _carmel_override() -> void:
	## Mount Carmel rises ~500 m straight behind Haifa; hex means flatten it, so exaggerate it locally
	for t in tiles:
		if str(t.get("region", "")) == "Carmel" and not (t["terrain"] in ["ocean", "coast", "lake"]):
			var k := Vector2i(int(t["q"]), int(t["r"]))
			var e := float(t.get("elevation_m", 0.0))
			elev_override[k] = e * 1.9 + 120.0


func resource_visible(t: Dictionary) -> bool:
	## resources with resource_reveal (gas, oil) are hidden before the discovery date
	var rr = t.get("resource_reveal")
	return rr == null or date >= norm_date(rr)


func owner_at_date(k: Vector2i, era: String) -> bool:
	if era == "" or not borders.has(era):
		return true
	for qr in borders[era]:
		if int(qr[0]) == k.x and int(qr[1]) == k.y:
			return true
	return false


func _border_era_at(d: String) -> String:
	if border_eras.is_empty():
		if borders.has("1949_armistice"):
			return "1949_armistice"
		var keys := borders.keys(); keys.sort()
		return keys[0] if keys.size() > 0 else ""
	var best := ""
	for e in border_eras:
		var s := norm_date(e.get("start", ""))
		var en := norm_date(e.get("end"))
		if s <= d and (en == "" or d < en):
			return str(e["id"])
		if s <= d:
			best = str(e["id"])
	# before the first era starts (the 1948 war, before the 1949 armistice lines) use the first era
	if best == "" and border_eras.size() > 0:
		best = str(border_eras[0]["id"])
	return best if borders.has(best) else ""


func _status_at(c: Dictionary, d: String) -> Dictionary:
	var st = c.get("status", [])
	if typeof(st) != TYPE_ARRAY:
		return {}
	for s in st:
		var f := norm_date(s.get("from"))
		var t := norm_date(s.get("to"))
		if (f == "" or f <= d) and (t == "" or d < t):
			return s
	return {}


func _pop_at(c: Dictionary, y: float) -> int:
	var pops = c.get("population", {})
	if typeof(pops) != TYPE_DICTIONARY or pops.is_empty():
		return -1
	var pts := []
	for k in pops:
		if pops[k] != null:
			pts.append([float(str(k).substr(0, 4)), float(pops[k])])
	if pts.is_empty():
		return -1
	pts.sort_custom(func(a, b): return a[0] < b[0])
	if y <= pts[0][0]:
		return int(pts[0][1]) if y > pts[0][0] - 15 else -1
	for i in range(1, pts.size()):
		if y <= pts[i][0]:
			var t: float = (y - pts[i - 1][0]) / (pts[i][0] - pts[i - 1][0])
			return int(exp(lerpf(log(maxf(pts[i - 1][1], 1.0)), log(maxf(pts[i][1], 1.0)), t)))
	return int(pts[pts.size() - 1][1])


func _city_at(c: Dictionary, d: String, ignore_dates := false) -> Dictionary:
	var founded := norm_date(c.get("founded"))
	if not ignore_dates and founded != "" and founded > d and int(founded.substr(0, 4)) > 1948:
		return {}
	var st := _status_at(c, d)
	var sts = c.get("status", [])
	if st.is_empty() and typeof(sts) == TYPE_ARRAY and sts.size() > 0:
		if not ignore_dates:
			return {}   # not yet founded / no longer exists at this date
		st = sts[0]
	var status := str(st.get("status", "israel"))
	if status == "evacuated" or status.begins_with("merged_into"):
		return {}
	var k: Vector2i
	var pos: Vector2
	if c.get("lat") != null and c.get("lon") != null:
		k = latlon_to_offset(float(c["lat"]), float(c["lon"]))
		pos = latlon_to_world(float(c["lat"]), float(c["lon"]))
	elif c.get("q") != null and c.get("r") != null:
		k = Vector2i(int(c["q"]), int(c["r"]))
		pos = TerrainMath.offset_center(k.x, k.y)
	else:
		return {}
	if not grid.has(k):
		return {}
	var kind := str(c.get("kind", "city"))
	var y := float(year) + float(d.substr(5, 2)) / 12.0
	var pop := _pop_at(c, y)
	var p := maxi(pop, 0)
	var size := 3 if p >= 200000 else (2 if p >= 80000 else (1 if p >= 20000 else 0))
	if kind in ["kibbutz", "moshav", "druze_village"]:
		size = 0
	var name := str(c.get("name", "?"))
	var id := str(c.get("id", name.to_snake_case()))
	for n in city_names:
		if str(n.get("city", "")) == id and d < norm_date(n.get("until")):
			name = str(n.get("name", name))
			break
	# the badge follows the status timeline in cities.json (no per-country lists in the renderer)
	var civ: String = CONTROL.get(status, "contested")
	var disp := clampi(int(round(sqrt(p / 1000.0) * 0.8)), 1, 40) if pop > 0 else -1
	return {"id": id, "name": name, "name_he": c.get("name_he", ""), "q": k.x, "r": k.y, "pos": pos, "size": size,
		"pop": p, "kind": kind, "control": civ, "civ": civ, "status": status, "status_note": str(st.get("note", "")),
		"display_pop": disp, "founded": founded}


const RELIEF := 0.9    # world units per 1000 m (1 world unit = 2.02 km, so ~1.8x vertical exaggeration)
const PEOPLE_PER_HEX := 55000.0   # urban hexes a city covers ~ population / this (1 hex = 10.6 km²)
const MAX_CITY_HEXES := 7


func _compute_urban() -> void:
	## Urban extent comes from the population at the current date: a city covers about
	## pop / PEOPLE_PER_HEX hexes, grown outward from its centre over the nearest land hexes.
	urban.clear()
	district.clear()
	urban_owner.clear()
	for c in cities:
		if c["id"] in ["tel_aviv", "jaffa"] and is_land(jaffa_hex):
			urban[jaffa_hex] = 2
			district[jaffa_hex] = "old"
			urban_owner[jaffa_hex] = c
		if c["id"] in ["jerusalem", "east_jerusalem"] and is_land(old_city_hex):
			urban[old_city_hex] = 2
			district[old_city_hex] = "old_city"
			urban_owner[old_city_hex] = c
	var order := cities.duplicate()
	order.sort_custom(func(a, b): return a["pop"] > b["pop"])
	for c in order:
		var k := Vector2i(c["q"], c["r"])
		if not is_land(k):
			continue
		var pop := float(c["pop"])
		var n := clampi(int(round(pop / PEOPLE_PER_HEX)), 1, MAX_CITY_HEXES)
		if not urban_owner.has(k) or urban_owner[k]["pop"] < c["pop"]:
			urban[k] = 2 if pop >= 40000 else 1
			urban_owner[k] = c
		if n <= 1:
			continue
		var cpos: Vector2 = c["pos"]
		var cand := []
		for nb in TerrainMath.offset_neighbors(k):
			cand.append(nb)
			for nb2 in TerrainMath.offset_neighbors(nb):
				if not cand.has(nb2) and nb2 != k:
					cand.append(nb2)
		cand = cand.filter(func(h): return is_land(h) and not urban.has(h))
		# Haifa climbs the Carmel: prefer Carmel-region hexes (terraced neighbourhoods on the slope)
		var bias := func(h: Vector2i) -> float:
			var d := TerrainMath.offset_center(h.x, h.y).distance_to(cpos)
			if c["id"] == "haifa" and str(tile_at(h).get("region", "")) == "Carmel":
				d -= 1.2
			return d
		cand.sort_custom(func(a, b): return bias.call(a) < bias.call(b))
		for i in mini(n - 1, cand.size()):
			var h: Vector2i = cand[i]
			if TerrainMath.offset_center(h.x, h.y).distance_to(cpos) > 3.6:
				break
			urban[h] = 2
			urban_owner[h] = c
	_compute_core()


# ------------------------------------------------------------------ tiles

func is_land(k: Vector2i) -> bool:
	var t = grid.get(k)
	if t == null:
		return false
	return not (t["terrain"] in ["ocean", "coast", "lake"])


func terrain_id(t: Dictionary) -> int:
	var i := TerrainMath.TERRAINS.find(t.get("terrain", "plains"))
	return 4 if i < 0 else i


func feature_id(t: Dictionary) -> int:
	var i := TerrainMath.FEATURES.find(t.get("feature", "none"))
	return 0 if i < 0 else i


func base_height(t: Dictionary) -> float:
	var ter: String = t.get("terrain", "plains")
	var e := float(t.get("elevation_m", 0.0))
	var ko := Vector2i(int(t["q"]), int(t["r"]))
	if elev_override.has(ko):
		e = elev_override[ko]
	match ter:
		"ocean": return -0.55
		"coast": return -0.2
		"lake": return -0.16
		"marsh": return 0.04
	# ~2x vertical exaggeration (1 world unit = 2.02 km horizontally)
	var h := 0.085 + clampf(e, 0.0, 2200.0) / 1000.0 * RELIEF
	if ter == "hills" or ter == "desert_hills":
		h += 0.08
	elif ter == "mountains":
		h += 0.16
	if t.get("coast", false):
		h = minf(h, 0.06 + maxf(e, 0.0) / 1000.0 * RELIEF * 0.9)
	return h


func _build_math() -> void:
	tm.cols = cols; tm.rows = rows
	if tm.cliff.size() != cols * rows:
		tm.cliff = cliff_bits()
	tm.terr.resize(cols * rows); tm.base.resize(cols * rows); tm.urb.resize(cols * rows)
	tm.terr.fill(0); tm.base.fill(-0.55); tm.urb.fill(0)
	for t in tiles:
		var i := int(t["r"]) * cols + int(t["q"])
		tm.terr[i] = terrain_id(t)
		tm.base[i] = base_height(t)
	for k in urban:
		tm.urb[k.y * cols + k.x] = 1


func owner_map() -> Dictionary:
	var own := {}
	if border_era != "" and borders.has(border_era):
		for qr in borders[border_era]:
			own[Vector2i(int(qr[0]), int(qr[1]))] = 1
	_fix_lakes(own)
	# 2 = held only militarily / de facto (not sovereign, Israeli law not applied)
	for qr in military_control.get(border_era, []):
		var k := Vector2i(int(qr[0]), int(qr[1]))
		if own.has(k):
			own[k] = 2
	return own


func _fix_lakes(own: Dictionary) -> void:
	## Hex-sampled borders can leave single lake hexes outside a lake that is otherwise inside
	## (e.g. the Kinneret, wholly on the Israeli side of the 1949 lines). Resolve each lake by majority.
	var done := {}
	for t in tiles:
		var k := Vector2i(int(t["q"]), int(t["r"]))
		if t["terrain"] != "lake" or done.has(k):
			continue
		var comp := [k]; var stack := [k]; done[k] = true
		while stack.size() > 0:
			var c: Vector2i = stack.pop_back()
			for n in TerrainMath.offset_neighbors(c):
				if not done.has(n) and tile_at(n).get("terrain", "") == "lake":
					done[n] = true; comp.append(n); stack.append(n)
		var n_own := 0
		for c in comp:
			if own.has(c): n_own += 1
		var frac := float(n_own) / comp.size()
		if frac >= 0.75:
			for c in comp: own[c] = 1
		elif frac <= 0.25:
			for c in comp: own.erase(c)


func data_image() -> Image:
	var img := Image.create(cols, rows, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var own := owner_map()
	for t in tiles:
		var k := Vector2i(int(t["q"]), int(t["r"]))
		var flags := 0
		if t.get("coast", false): flags |= 1
		if t.get("river", false):
			flags |= 2
			flags |= (_flow_dir(k) + 1) << 3
		if urban.has(k):
			flags |= 4
			if int(urban[k]) >= 2:
				flags |= 64
			if district.get(k, "") in ["old", "old_city"]:
				flags |= 128
		img.set_pixel(k.x, k.y, Color8(terrain_id(t), feature_id(t), int(own.get(k, 0)), flags))
	return img


const DIR_OPP := [3, 4, 5, 0, 1, 2]


var _data2_base: Image
var core := {}           # Vector2i -> true: dense urban core (paved ground, packed lots)


func _compute_core() -> void:
	core.clear()
	for c in cities:
		var p := float(c["pop"])
		if p < 60000:
			continue
		var k := Vector2i(c["q"], c["r"])
		core[k] = true
		if p >= 250000:
			var cpos: Vector2 = c["pos"]
			var own := []
			for h in urban:
				if urban_owner.get(h, {}).get("id", "") == c["id"] and h != k:
					own.append(h)
			own.sort_custom(func(a, b): return TerrainMath.offset_center(a.x, a.y).distance_to(cpos) < TerrainMath.offset_center(b.x, b.y).distance_to(cpos))
			for i in mini(2, own.size()):
				core[own[i]] = true


func data2_dated() -> Image:
	## data2 plus date-dependent alpha: bit0 urban core (paved), bit1 held by Jordan (1948-67 East Jerusalem)
	if _data2_base == null:
		_data2_base = data2_image()
	var img := _data2_base.duplicate() as Image
	for k in urban:
		var a := 0
		if core.has(k):
			a |= 1
		if str(urban_owner.get(k, {}).get("control", "")) == "jordan":
			a |= 2
		var c := img.get_pixelv(k)
		c.a = a / 255.0
		img.set_pixelv(k, c)
	return img


func data2_image() -> Image:
	## R: cliff edge bits 0-5 (edge index = AX_DIRS index: E, NE, NW, W, SW, SE), bit 6 natural wonder
	## G: stream link bits 0-5, bit 6 stream present.  B: base terrain id of hills/mountains (+1, 0 = none)
	var img := Image.create(cols, rows, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var wonder := {}
	for w in natural_wonders:
		if str(w.get("kind", "")) in ["crater", "canyon", "mountain", "sea_cave", "oasis"]:
			for qr in w.get("hexes", []):
				wonder[Vector2i(int(qr[0]), int(qr[1]))] = true
	var links := {}
	for t in tiles:
		var sname = t.get("stream")
		if sname == null:
			continue
		var k := Vector2i(int(t["q"]), int(t["r"]))
		var a := TerrainMath.offset_to_axial(k)
		var e := float(t.get("elevation_m", 0))
		var best := -1
		var best_e := e
		var water := -1
		for d in 6:
			var n := tile_at(TerrainMath.axial_to_offset(a + TerrainMath.AX_DIRS[d]))
			if n.is_empty():
				continue
			if n.get("stream") == sname and float(n.get("elevation_m", 0)) < best_e:
				best_e = float(n.get("elevation_m", 0)); best = d
			elif water < 0 and (n["terrain"] in ["ocean", "coast", "lake"] or n.get("river", false)):
				water = d
		if best < 0:
			best = water
		links[k] = int(links.get(k, 0)) | 64
		if best >= 0:
			links[k] = int(links[k]) | (1 << best)
			var nk := TerrainMath.axial_to_offset(a + TerrainMath.AX_DIRS[best])
			if tile_at(nk).get("stream") == sname:
				links[nk] = int(links.get(nk, 64)) | (1 << DIR_OPP[best]) | 64
	for t in tiles:
		var k := Vector2i(int(t["q"]), int(t["r"]))
		var cl := 0
		var ce = t.get("cliff_edges", [])
		if typeof(ce) == TYPE_ARRAY:
			for e in ce:
				cl |= 1 << int(e)
		if wonder.has(k):
			cl |= 64
		var base_id := 0
		if t.get("base") != null:
			base_id = TerrainMath.TERRAINS.find(str(t["base"])) + 1
		img.set_pixel(k.x, k.y, Color8(cl, int(links.get(k, 0)), maxi(base_id, 0), 0))
	return img


func cliff_bits() -> PackedByteArray:
	var out := PackedByteArray(); out.resize(cols * rows); out.fill(0)
	for t in tiles:
		var ce = t.get("cliff_edges", [])
		if typeof(ce) == TYPE_ARRAY:
			var cl := 0
			for e in ce:
				cl |= 1 << int(e)
			out[int(t["r"]) * cols + int(t["q"])] = cl
	return out


func height_image() -> Image:
	var himg := Image.create(cols, rows, false, Image.FORMAT_RF)
	himg.fill(Color(-0.55, 0, 0))
	for t in tiles:
		himg.set_pixel(int(t["q"]), int(t["r"]), Color(base_height(t), 0, 0))
	return himg


func make_textures() -> Array:
	return [ImageTexture.create_from_image(data_image()), ImageTexture.create_from_image(height_image())]


func _flow_dir(k: Vector2i) -> int:
	## index into TerrainMath.AX_DIRS of the downstream neighbour (river or water), or -1
	var a := TerrainMath.offset_to_axial(k)
	var best := -1
	var best_e := float(tile_at(k).get("elevation_m", 0.0)) + 1.0
	for d in 6:
		var n := TerrainMath.axial_to_offset(a + TerrainMath.AX_DIRS[d])
		var t := tile_at(n)
		if t.is_empty():
			continue
		var e := float(t.get("elevation_m", 0.0))
		if t.get("terrain", "") in ["ocean", "coast", "lake"]:
			e = -10000.0
		elif not t.get("river", false):
			continue
		if e < best_e:
			best_e = e; best = d
	return best


func tile_at(k: Vector2i) -> Dictionary:
	return grid.get(k, {})


func world_size() -> Vector2:
	return Vector2(TerrainMath.SQ3 * (cols + 0.5), 1.5 * (rows - 1) + 2.0)


func find_place(name: String) -> Dictionary:
	for c in cities:
		if c["name"] == name:
			return c
	for p in places:
		if p.get("name", "") == name:
			return p
	return {}


func apply_city_info() -> void:
	for c in cities:
		var o: Dictionary = city_info.get(c["id"], {})
		for f in o:
			c[f] = o[f]


func find_city(id: String) -> Dictionary:
	for c in cities:
		if c["id"] == id:
			return c
	return {}
