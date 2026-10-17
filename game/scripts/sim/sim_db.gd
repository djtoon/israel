class_name SimDB
extends RefCounted
## Static game data for the simulation: map, cities, events, trees, buildings, units.
## Loads defensively: any file may be missing or partial; problems go to `warnings`.
## Use SimDB.get_db() for the shared instance.

const DATA := "res://data/"
const BASE_ABS_Q := 7792          # turn = year*4 + quarter_index - BASE_ABS_Q  (turn 1 = Q2 1948)
const LAST_TURN := 302            # Q3 2023: the data ends with the game (content after 7 Oct 2023 deleted, 2026-10-14)
const START_DATE := "1948-05-14"

static var _shared: SimDB = null

var warnings: Array = []
# map
var cols := 0
var rows := 0
var hex_km := 3.5
var lat0 := 33.45
var lon0 := 34.15
var km_lat := 110.86
var km_lon := 94.9666
var tiles := {}            # key -> tile dict
var places: Array = []
var places_by_name := {}
var border_eras: Array = []   # [{id,start,end,label}]
var borders := {}             # era id -> {key: true}
var areas := {}               # area id -> {key:true}
var natural_wonders: Array = []
var wonder_at := {}           # tile key -> natural wonder dict
var military := {}            # border era id -> {key: true} (held militarily, not sovereign)
# content
var cities: Array = []        # cities.json entries (+ q, r computed)
var city_by_id := {}
var events: Array = []        # sorted by date, + "_turn", "_end_turn"
var event_by_id := {}
var events_by_turn := {}      # turn -> [event]
var eras: Array = []
var techs := {}
var tech_list: Array = []
var civics := {}
var civic_list: Array = []
var policies := {}
var policy_list: Array = []
var gov := {}
var districts := {}
var buildings := {}
var projects := {}
var city_projects := {}
var improvements := {}
var units := {}
var actors := {}
var actor_meta := {}
var real := {}
var choice_terms := {}          # data/choice_terms.json: event id -> {choices: [{streams, flags, blocks}]}
var ghost := {}
var sources := {}             # S-id -> true (history, sim and pending gameplay sources)
var source_meta := {}         # S-id -> {provenance, quote, url, file}
var forks := {}               # fork id -> fork (data/forks/*.json, schema in scripts/sim/FORKS.md)
var fork_list: Array = []     # sorted by date
var wars := {}                # war id -> war (data/wars/*.json)
var war_by_event := {}        # event id -> war
var data_errors: Array = []   # strict validation errors for forks and wars (other agents write this data)
var data_warnings: Array = []
var deleted_ids := {}         # tombstoned event ids (tools/history/data/deleted_event_ids.json)
var choice_civics := {}       # civics granted by some event choice: never granted by a no-choice event first
var dated_count_by_turn := {} # cumulative historical tech count by turn (filled lazily)


static func get_db() -> SimDB:
	if _shared == null:
		_shared = SimDB.new()
		_shared.load_all()
	return _shared


static func reload_db() -> SimDB:
	_shared = null
	return get_db()


# ------------------------------------------------------------------ dates

static func parse_date(s) -> Dictionary:
	## Accepts "YYYY", "YYYY-MM", "YYYY-MM-DD", ints. Year-only dates resolve to 1 July.
	if s == null:
		return {}
	var txt := str(s).strip_edges()
	if txt == "" or txt == "null":
		return {}
	var parts := txt.split("-")
	var y := int(parts[0])
	if y < 1000:
		return {}
	var m := 7
	var d := 1
	if parts.size() >= 2:
		m = clampi(int(parts[1]), 1, 12)
	if parts.size() >= 3:
		d = clampi(int(parts[2]), 1, 31)
	return {"y": y, "m": m, "d": d}


static func turn_of(s, default_turn := -1) -> int:
	var p := parse_date(s)
	if p.is_empty():
		return default_turn
	return p["y"] * 4 + (p["m"] - 1) / 3 - BASE_ABS_Q


static func abs_q(turn: int) -> int:
	return turn + BASE_ABS_Q


static func year_of(turn: int) -> int:
	return abs_q(turn) / 4


static func quarter_of(turn: int) -> int:
	return abs_q(turn) % 4 + 1


static func year_f(turn: int) -> float:
	return float(abs_q(turn)) / 4.0 + 0.125


static func date_label(turn: int) -> String:
	return "Q%d %d" % [quarter_of(turn), year_of(turn)]


static func date_iso(turn: int) -> String:
	return "%04d-%02d-01" % [year_of(turn), (quarter_of(turn) - 1) * 3 + 1]


# ------------------------------------------------------------------ loading

func _read_json(path: String):
	if not FileAccess.file_exists(path):
		warnings.append("missing data file " + path)
		return null
	var txt := FileAccess.get_file_as_string(path)
	var j := JSON.new()
	if j.parse(txt) != OK:
		warnings.append("JSON parse error in %s line %d: %s" % [path, j.get_error_line(), j.get_error_message()])
		return null
	return j.data


func load_all() -> void:
	warnings.clear()
	_load_map()
	_load_content()
	_load_cities()
	_load_events()
	_load_sources()
	_load_deleted()
	_load_forks()
	_load_wars()
	_filter_after_end()
	for ev in events:
		for ch in ev.get("choices", []):
			if typeof(ch) == TYPE_DICTIONARY:
				for cv in ch.get("effects", {}).get("unlock_civic", []):
					choice_civics[str(cv)] = ev["id"]
	var g = _read_json(DATA + "ghost.json") if FileAccess.file_exists(DATA + "ghost.json") else null
	ghost = g if typeof(g) == TYPE_DICTIONARY else {}


func _load_map() -> void:
	var m = _read_json(DATA + "map.json")
	if typeof(m) != TYPE_DICTIONARY:
		return
	cols = int(m.get("cols", 0)); rows = int(m.get("rows", 0))
	hex_km = float(m.get("hex_km", 3.5))
	var o = m.get("origin", {})
	if typeof(o) == TYPE_DICTIONARY:
		lat0 = float(o.get("lat", lat0)); lon0 = float(o.get("lon", lon0))
	var pr = m.get("projection", {})
	if typeof(pr) == TYPE_DICTIONARY:
		km_lat = float(pr.get("km_per_deg_lat", km_lat)); km_lon = float(pr.get("km_per_deg_lon", km_lon))
	for t in m.get("tiles", []):
		if typeof(t) != TYPE_DICTIONARY or not t.has("q") or not t.has("r"):
			continue
		var tt: Dictionary = t
		if tt.get("feature") == null: tt["feature"] = "none"
		if not tt.has("terrain") or tt["terrain"] == null: tt["terrain"] = "plains"
		tiles[SimHex.key(int(tt["q"]), int(tt["r"]))] = tt
	places = m.get("places", [])
	for p in places:
		places_by_name[str(p.get("name", ""))] = p
	var be = m.get("border_eras", [])
	if typeof(be) == TYPE_ARRAY:
		border_eras = be
	var b = m.get("borders", {})
	if typeof(b) == TYPE_DICTIONARY:
		for era_id in b:
			var s := {}
			for qr in b[era_id]:
				s[SimHex.key(int(qr[0]), int(qr[1]))] = true
			borders[era_id] = s
	var a = m.get("areas", {})
	if typeof(a) == TYPE_DICTIONARY:
		for aid in a:
			var s2 := {}
			if typeof(a[aid]) == TYPE_ARRAY:
				for qr in a[aid]:
					if typeof(qr) == TYPE_ARRAY and qr.size() >= 2:
						s2[SimHex.key(int(qr[0]), int(qr[1]))] = true
			areas[aid] = s2
	var nw = m.get("natural_wonders", [])
	if typeof(nw) == TYPE_ARRAY:
		natural_wonders = nw
		for w in nw:
			for qr in w.get("hexes", []):
				wonder_at[SimHex.key(int(qr[0]), int(qr[1]))] = w
	var mc = m.get("military_control", {})
	if typeof(mc) == TYPE_DICTIONARY:
		for era_id in mc:
			var s3 := {}
			if typeof(mc[era_id]) == TYPE_ARRAY:
				for qr in mc[era_id]:
					s3[SimHex.key(int(qr[0]), int(qr[1]))] = true
			military[era_id] = s3
	if border_eras.is_empty() and not borders.is_empty():
		for k in borders.keys():
			border_eras.append({"id": k, "start": "1948-05-14", "end": null})


func _index(arr, into: Dictionary, what: String) -> Array:
	var out := []
	if typeof(arr) != TYPE_ARRAY:
		warnings.append("no %s list" % what)
		return out
	for x in arr:
		if typeof(x) == TYPE_DICTIONARY and x.has("id"):
			into[str(x["id"])] = x
			out.append(x)
	return out


func _load_content() -> void:
	var t = _read_json(DATA + "techs.json")
	if typeof(t) == TYPE_DICTIONARY:
		eras = t.get("eras", [])
		tech_list = _index(t.get("techs", []), techs, "techs")
	var c = _read_json(DATA + "civics.json")
	if typeof(c) == TYPE_DICTIONARY:
		civic_list = _index(c.get("civics", []), civics, "civics")
	var p = _read_json(DATA + "policies.json")
	if typeof(p) == TYPE_DICTIONARY:
		policy_list = _index(p.get("policies", []), policies, "policies")
	var g = _read_json(DATA + "governments.json")
	gov = g if typeof(g) == TYPE_DICTIONARY else {"types": {}, "terms": [], "rails": [], "ministries": []}
	var d = _read_json(DATA + "districts.json")
	if typeof(d) == TYPE_DICTIONARY:
		_index(d.get("districts", []), districts, "districts")
	var b = _read_json(DATA + "buildings.json")
	if typeof(b) == TYPE_DICTIONARY:
		_index(b.get("buildings", []), buildings, "buildings")
		_index(b.get("projects", []), projects, "projects")
		_index(b.get("city_projects", []), city_projects, "city projects")
		_index(b.get("improvements", []), improvements, "improvements")
	var u = _read_json(DATA + "units.json")
	if typeof(u) == TYPE_DICTIONARY:
		_index(u.get("units", []), units, "units")
	var a = _read_json(DATA + "actors.json")
	if typeof(a) == TYPE_DICTIONARY:
		actor_meta = a
		_index(a.get("actors", []), actors, "actors")
	var r = _read_json(DATA + "real_series.json")
	real = r if typeof(r) == TYPE_DICTIONARY else {}
	var ct = _read_json(DATA + "choice_terms.json")
	choice_terms = ct.get("events", {}) if typeof(ct) == TYPE_DICTIONARY else {}
	if eras.is_empty():
		eras = [{"id": "era1", "index": 1, "name": "Era 1", "start": START_DATE}]


func latlon_to_offset(lat: float, lon: float) -> Vector2i:
	var r := int(round((lat0 - lat) * km_lat / (hex_km * sqrt(3.0) / 2.0)))
	var q := int(round((lon - lon0) * km_lon / hex_km - 0.5 * (r & 1)))
	return Vector2i(q, r)


func _load_cities() -> void:
	var arr = _read_json(DATA + "cities.json")
	if typeof(arr) == TYPE_DICTIONARY:
		arr = arr.get("cities", [])
	if typeof(arr) != TYPE_ARRAY:
		return
	var used := {}
	for c in arr:
		if typeof(c) != TYPE_DICTIONARY or not c.has("id"):
			continue
		var e: Dictionary = c.duplicate(true)
		var q = e.get("q"); var r = e.get("r")
		if q == null or r == null:
			if e.get("lat") == null or e.get("lon") == null:
				warnings.append("city %s has no position" % e["id"])
				continue
			var off := latlon_to_offset(float(e["lat"]), float(e["lon"]))
			q = off.x; r = off.y
		var pos := _snap_land(Vector2i(int(q), int(r)), used)
		e["q"] = pos.x; e["r"] = pos.y
		used[SimHex.key(pos.x, pos.y)] = e["id"]
		if typeof(e.get("population")) != TYPE_DICTIONARY:
			e["population"] = {}
		if typeof(e.get("status")) != TYPE_ARRAY:
			e["status"] = []
		cities.append(e)
		city_by_id[str(e["id"])] = e


func is_land(k: int) -> bool:
	var t = tiles.get(k)
	return t != null and not (t["terrain"] in ["ocean", "coast", "lake"])


func _snap_land(p: Vector2i, used: Dictionary) -> Vector2i:
	if tiles.is_empty():
		return p
	if is_land(SimHex.key(p.x, p.y)) and not used.has(SimHex.key(p.x, p.y)):
		return p
	for rad in range(1, 4):
		var best := Vector2i(-1, -1)
		for n in SimHex.ring(p.x, p.y, rad):
			var k := SimHex.key(n.x, n.y)
			if is_land(k) and not used.has(k) and tiles[k]["terrain"] != "mountains":
				best = n
				break
		if best.x >= 0:
			return best
	return p


func _load_events() -> void:
	var arr = _read_json(DATA + "events.json")
	if typeof(arr) == TYPE_DICTIONARY:
		arr = arr.get("events", [])
	if typeof(arr) != TYPE_ARRAY:
		return
	for e in arr:
		if typeof(e) != TYPE_DICTIONARY or not e.has("id"):
			continue
		var ev: Dictionary = e
		var t := turn_of(ev.get("date"))
		if t < 0:
			warnings.append("event %s has a bad date" % ev["id"])
			continue
		ev["_turn"] = clampi(t, 1, LAST_TURN)
		if ev.has("turn") and ev["turn"] != null and int(ev["turn"]) != t:
			pass   # history builder's turn field may lag; the date is authoritative
		ev["_end_turn"] = turn_of(ev.get("date_end"), -1)
		if typeof(ev.get("effects")) != TYPE_DICTIONARY:
			ev["effects"] = {}
		if typeof(ev.get("choices")) != TYPE_ARRAY:
			ev["choices"] = []
		if typeof(ev.get("places")) != TYPE_ARRAY:
			ev["places"] = []
		ev["_order"] = events.size()
		events.append(ev)
	# a stable sort (Array.sort_custom is not): events of the same date keep their order in events.json, so deleting or
	# adding an unrelated event never reshuffles the ones that fire together (v3 integration, 2026-10-14)
	events.sort_custom(func(a, b): return str(a.get("date")) < str(b.get("date")) or (str(a.get("date")) == str(b.get("date")) and int(a["_order"]) < int(b["_order"])))
	for ev in events:
		event_by_id[ev["id"]] = ev
		var tt: int = ev["_turn"]
		if not events_by_turn.has(tt):
			events_by_turn[tt] = []
		events_by_turn[tt].append(ev)


func sources_path() -> String:
	return ProjectSettings.globalize_path("res://").path_join("../sources/SOURCES.md").simplify_path()


func _load_sources() -> void:
	## History sources (SOURCES.md, rendered by the history pipeline) and gameplay sources
	## (SIM_SOURCES.md from sources/sim_sources.json, gameplay ids S500-S699, S750-S799, S900-S999, S5000-S5999).
	## Also reads sources/sources.json, sources/sim_sources.json and sources/pending/*.json (data agents' new
	## gameplay sources awaiting merge) so cites can be checked for provenance and quotes.
	var rx := RegEx.new()
	rx.compile("\\*\\*\\[(S\\d+)\\]\\*\\*")
	for p in [sources_path(), sources_path().get_base_dir().path_join("SIM_SOURCES.md")]:
		if not FileAccess.file_exists(p):
			continue
		for m in rx.search_all(FileAccess.get_file_as_string(p)):
			sources[m.get_string(1)] = true
	var dir := sources_path().get_base_dir()
	var files := [dir.path_join("sources.json"), dir.path_join("sim_sources.json")]
	var pd := dir.path_join("pending")
	if DirAccess.dir_exists_absolute(pd):
		for fn in DirAccess.get_files_at(pd):
			if fn.ends_with(".json"):
				files.append(pd.path_join(fn))
	for p in files:
		if not FileAccess.file_exists(p):
			continue
		var j := JSON.new()
		if j.parse(FileAccess.get_file_as_string(p)) != OK:
			data_errors.append("%s: JSON error line %d: %s" % [p.get_file(), j.get_error_line(), j.get_error_message()])
			continue
		var arr = j.data
		if typeof(arr) == TYPE_DICTIONARY:
			arr = arr.get("sources", [])
		if typeof(arr) != TYPE_ARRAY:
			data_errors.append("%s: expected a list of sources (or {\"sources\": [...]})" % p.get_file())
			continue
		for s in arr:
			if typeof(s) != TYPE_DICTIONARY or not s.has("id"):
				data_errors.append("%s: a source entry has no id" % p.get_file())
				continue
			var sid := str(s["id"])
			if p.get_base_dir() == pd and source_meta.has(sid) and str(source_meta[sid].get("file", "")) != p.get_file():
				# already merged into sim_sources.json by tools/merge_pending_sources.py: fine unless it is a different source
				if str(source_meta[sid].get("citation", "")) != str(s.get("citation", "")):
					data_errors.append("%s: source %s conflicts with a different source of the same id in %s" % [p.get_file(), sid, source_meta[sid].get("file", "")])
				continue
			sources[sid] = true
			var sup_txt := str(s.get("quote", "")) + " " + str(s.get("citation", ""))
			var sup = s.get("supports", [])
			if typeof(sup) == TYPE_ARRAY:
				for x in sup: sup_txt += " " + str(x)
			elif sup != null:
				sup_txt += " " + str(sup)
			source_meta[sid] = {"citation": str(s.get("citation", "")), "text": sup_txt, "provenance": str(s.get("provenance", "opened" if s.get("opened", false) else "not_opened")),
				"quote": str(s.get("quote", "")) if s.get("quote") != null else "", "url": str(s.get("url", "")) if s.get("url") != null else "", "file": p.get_file()}


func _load_deleted() -> void:
	var p := sources_path().get_base_dir().path_join("../tools/history/data/deleted_event_ids.json").simplify_path()
	if not FileAccess.file_exists(p):
		return
	var d = JSON.parse_string(FileAccess.get_file_as_string(p))
	var arr = d if typeof(d) == TYPE_ARRAY else (d.get("ids", []) if typeof(d) == TYPE_DICTIONARY else [])
	for x in arr:
		deleted_ids[str(x)] = true


# ------------------------------------------------------------------ forks and wars (data agents write these; validate strictly)

const FORK_REQUIRES := ["event", "choice", "not_choice", "flag", "not_flag", "tech", "civic"]
const FORK_NOW := ["gold", "standing", "trust", "readiness", "cohesion", "inflation", "production", "science", "culture"]
const TERM_TYPES := ["gold", "standing", "standing_target", "trust", "trust_base", "readiness", "output_pct", "science_pct", "growth_pct",
	"water", "inflation", "cohesion", "amenity", "retention", "immigrant_weight"]
const TERM_TYPICAL := {"gold": 5.0, "output_pct": 3.0, "inflation": 2.0, "standing": 0.2, "standing_target": 3.0, "trust": 0.3, "trust_base": 3.0,
	"cohesion": 1.0, "amenity": 1.0, "readiness": 4.0, "science_pct": 5.0, "growth_pct": 1.5, "retention": 3.0, "water": 30.0, "immigrant_weight": 40.0}
const TERM_GROUPS := ["all", "dev_towns", "arab", "periphery", "large_cities"]
const WAR_UNITS := ["hostile_infantry", "hostile_armor", "hostile_artillery", "hostile_rockets", "missile_salvo"]
## Which VS. HISTORY track each lasting term moves (for the dominance check).
const TERM_TRACK := {"gold": "economy", "output_pct": "economy", "inflation": "economy_neg", "standing": "standing", "standing_target": "standing",
	"trust": "cohesion", "trust_base": "cohesion", "cohesion": "cohesion", "amenity": "cohesion", "readiness": "readiness",
	"science_pct": "science", "growth_pct": "population", "retention": "population", "water": "water", "immigrant_weight": "distribution"}


func _data_dir_files(sub: String) -> Array:
	var d := DATA + sub
	var out := []
	if not DirAccess.dir_exists_absolute(d):
		return out
	for fn in DirAccess.get_files_at(d):
		if fn.ends_with(".json"):
			out.append(d.path_join(fn))
	out.sort()
	return out


func _err(where: String, msg: String) -> void:
	data_errors.append("%s: %s" % [where, msg])


func _check_date(where: String, v, required: bool) -> bool:
	if v == null:
		if required: _err(where, "missing date (\"YYYY-MM\")")
		return not required
	if typeof(v) != TYPE_STRING or parse_date(v).is_empty() or int(str(v).substr(0, 4)) < 1948 or int(str(v).substr(0, 4)) > year_of(LAST_TURN):
		_err(where, "bad date %s (use \"YYYY-MM\" between 1948 and %d; nothing after Q3 2023)" % [str(v), year_of(LAST_TURN)])
		return false
	return true


func _check_cites(where: String, cites) -> void:
	if typeof(cites) != TYPE_ARRAY or cites.is_empty():
		_err(where, "needs a non-empty \"cite\" list of {source, quote, url}")
		return
	for c in cites:
		if typeof(c) != TYPE_DICTIONARY or not c.has("source"):
			_err(where, "each cite needs a \"source\" S-id")
			continue
		var sid := str(c["source"])
		if not sources.has(sid):
			_err(where, "cite source %s not found in sources.json, sim_sources.json or sources/pending/*.json" % sid)
			continue
		var meta: Dictionary = source_meta.get(sid, {"provenance": "opened", "quote": "x"})
		var needs_quote: bool = meta.get("provenance", "opened") != "opened" or (meta.get("file", "") != "sources.json" and str(meta.get("quote", "")) == "")
		if needs_quote and (str(c.get("quote", "")) == "" or not str(c.get("url", "")).begins_with("http")):
			_err(where, "cite %s is %s: give a verbatim \"quote\" and an opened \"url\" in the cite" % [sid, "not opened" if meta.get("provenance", "") != "opened" else "a gameplay source without a quote"])


func _check_terms(where: String, terms) -> Dictionary:
	## Validates lasting terms; returns {track: summed effect sign} for the dominance check.
	var tracks := {}
	if typeof(terms) != TYPE_ARRAY or terms.is_empty():
		_err(where, "needs at least one \"lasting\" term")
		return tracks
	for i in range(terms.size()):
		var s = terms[i]
		var w := "%s lasting[%d]" % [where, i]
		if typeof(s) != TYPE_DICTIONARY:
			_err(w, "must be an object")
			continue
		var t := str(s.get("type", ""))
		if not (t in TERM_TYPES):
			_err(w, "unknown type \"%s\" (allowed: %s)" % [t, ", ".join(TERM_TYPES)])
			continue
		if not (typeof(s.get("amount")) in [TYPE_INT, TYPE_FLOAT]) or float(s.get("amount", 0)) == 0.0:
			_err(w, "\"amount\" must be a non-zero number")
		if str(s.get("label", "")).strip_edges() == "":
			_err(w, "needs a \"label\" (shown in Why stats moved)")
		var ok0 := _check_date(w + " from", s.get("from"), true)
		var ok1 := _check_date(w + " until", s.get("until"), true)
		if ok0 and ok1 and turn_of(s["until"]) < turn_of(s["from"]):
			_err(w, "\"until\" is before \"from\"")
		if s.has("group") and not (str(s["group"]) in TERM_GROUPS):
			_err(w, "unknown group \"%s\" (allowed: %s)" % [s["group"], ", ".join(TERM_GROUPS)])
		if t == "immigrant_weight" and not (str(s.get("target", "")) in ["small_towns", "large_cities"]):
			_err(w, "immigrant_weight needs \"target\": \"small_towns\" or \"large_cities\"")
		var tr := str(TERM_TRACK.get(t, t))
		# value in "typical units" x duration, so the dominance check weighs magnitudes, not just signs
		var years := 1.0
		if ok0 and ok1:
			years = maxf(0.25, float(turn_of(s["until"]) - turn_of(s["from"]) + 1) / 4.0)
		var val := float(s.get("amount", 0)) / float(TERM_TYPICAL.get(t, 1.0)) * clampf(years / 8.0, 0.25, 3.0)
		if tr == "economy_neg":
			tr = "economy"; val = -val
		if tr != "distribution":
			tracks[tr] = float(tracks.get(tr, 0.0)) + val
	return tracks


func _scan_deleted(where: String, x) -> void:
	if typeof(x) == TYPE_STRING:
		if deleted_ids.has(x):
			_err(where, "references deleted event %s (tombstoned; never re-add)" % x)
	elif typeof(x) == TYPE_DICTIONARY:
		for k in x:
			_scan_deleted(where, k); _scan_deleted(where, x[k])
	elif typeof(x) == TYPE_ARRAY:
		for v in x:
			_scan_deleted(where, v)


func _load_forks() -> void:
	var seen := {}
	for p in _data_dir_files("forks"):
		var fname: String = p.get_file()
		var j := JSON.new()
		if j.parse(FileAccess.get_file_as_string(p)) != OK:
			_err(fname, "JSON error line %d: %s" % [j.get_error_line(), j.get_error_message()])
			continue
		var data = j.data
		var arr = data.get("forks") if typeof(data) == TYPE_DICTIONARY else data
		if typeof(arr) != TYPE_ARRAY:
			_err(fname, "expected {\"range\": ..., \"forks\": [...]}")
			continue
		for f in arr:
			if typeof(f) != TYPE_DICTIONARY:
				_err(fname, "a fork is not an object")
				continue
			var id := str(f.get("id", ""))
			var w := "%s %s" % [fname, id if id != "" else "(fork without id)"]
			if id == "" or not id.begins_with("fork_"):
				_err(w, "\"id\" must start with fork_")
			if seen.has(id):
				_err(w, "duplicate fork id (also in %s)" % seen[id])
				continue
			seen[id] = fname
			_scan_deleted(w, f)
			for k in ["title", "text"]:
				if str(f.get(k, "")).strip_edges() == "":
					_err(w, "missing \"%s\"" % k)
			var okd := _check_date(w + " date", f.get("date"), true)
			if f.has("until") and _check_date(w + " until", f.get("until"), false) and okd and turn_of(f["until"]) < turn_of(f["date"]):
				_err(w, "\"until\" is before \"date\"")
			var src = f.get("source", [])
			if typeof(src) != TYPE_ARRAY or src.is_empty():
				_err(w, "needs a non-empty \"source\" list")
			else:
				for sid in src:
					if not sources.has(str(sid)): _err(w, "source %s not found" % sid)
			var req = f.get("requires", {})
			if typeof(req) != TYPE_DICTIONARY:
				_err(w, "\"requires\" must be an object")
				req = {}
			for k in req:
				if not (k in FORK_REQUIRES):
					_err(w, "unknown requires key \"%s\" (allowed: %s)" % [k, ", ".join(FORK_REQUIRES)])
			if req.has("event") and not event_by_id.has(str(req["event"])):
				_err(w, "requires.event %s is not in events.json" % req["event"])
			var opts = f.get("options", [])
			if typeof(opts) != TYPE_ARRAY or opts.size() < 2 or opts.size() > 3:
				_err(w, "needs 2-3 options")
				continue
			var hist := 0
			var oids := {}
			var vecs := []
			for o in opts:
				if typeof(o) != TYPE_DICTIONARY:
					_err(w, "an option is not an object")
					continue
				var ow := "%s option %s" % [w, o.get("id", "?")]
				var oid := str(o.get("id", ""))
				if oid == "" or oids.has(oid):
					_err(ow, "needs a unique \"id\"")
				oids[oid] = true
				if str(o.get("label", "")).strip_edges() == "":
					_err(ow, "missing \"label\"")
				if typeof(o.get("historical")) != TYPE_BOOL:
					_err(ow, "\"historical\" must be true or false")
				elif o["historical"]:
					hist += 1
					if str(o.get("note", "")).strip_edges() == "":
						data_warnings.append("%s: historical option has no \"note\" (what actually happened)" % ow)
				if not o.has("advocate") or typeof(o.get("advocate")) != TYPE_STRING:
					_err(ow, "needs \"advocate\" (the person, party or body that argued for it)")
				elif typeof(o.get("historical")) == TYPE_BOOL and not o["historical"]:
					# CONTRACT: every non-historical choice names who argued for it, with evidence
					if str(o["advocate"]).strip_edges() == "":
						_err(ow, "non-historical option needs a named \"advocate\" (who argued for it at the time)")
					# evidence: a cite with a verbatim quote, or a cited source whose recorded quote/supports names the advocate
					var has_quote := false
					var tokens := []
					for wd in str(o["advocate"]).replace(",", " ").replace("'s", "").replace("(", " ").replace(")", " ").split(" ", false):
						if wd.length() >= 4 and wd[0] == wd[0].to_upper() and not (wd in ["Prime", "Minister", "Defence", "Defense", "Finance", "Government", "Party", "Israeli", "Israel"]):
							tokens.append(wd.to_lower())
					if typeof(o.get("cite")) == TYPE_ARRAY:
						for c in o["cite"]:
							if typeof(c) != TYPE_DICTIONARY: continue
							if str(c.get("quote", "")).strip_edges() != "":
								has_quote = true
							var txt := str(source_meta.get(str(c.get("source", "")), {}).get("text", "")).to_lower()
							for tk in tokens:
								if txt.find(tk) >= 0: has_quote = true
					if not has_quote:
						var who := "the advocate" if str(o["advocate"]) == "" else str(o["advocate"])
						_err(ow, "non-historical option: no cite supports the advocacy - add a cite with a verbatim quote and url showing that " + who + " argued for it (or cite a source whose quote/supports names them)")
				_check_cites(ow, o.get("cite"))
				var now = o.get("now", {})
				if typeof(now) != TYPE_DICTIONARY:
					_err(ow, "\"now\" must be an object")
					now = {}
				for k in now:
					if not (k in FORK_NOW):
						_err(ow, "unknown now key \"%s\" (allowed: %s)" % [k, ", ".join(FORK_NOW)])
					elif not (typeof(now[k]) in [TYPE_INT, TYPE_FLOAT]):
						_err(ow, "now.%s must be a number" % k)
				var v := _check_terms(ow, o.get("lasting"))
				for k in now:
					if k in ["gold", "standing", "trust", "readiness", "cohesion"] and typeof(now[k]) in [TYPE_INT, TYPE_FLOAT]:
						var tk: String = {"gold": "economy", "standing": "standing", "trust": "cohesion", "readiness": "readiness", "cohesion": "cohesion"}[k]
						var typ: float = {"gold": 60.0, "standing": 3.0, "trust": 3.0, "readiness": 4.0, "cohesion": 15.0}[k]
						v[tk] = float(v.get(tk, 0.0)) + 0.5 * float(now[k]) / typ
				vecs.append([oid, v])
			if hist != 1:
				_err(w, "exactly one option must have \"historical\": true (found %d)" % hist)
			# dominance: an option at least as good on every track and better on one
			for a in vecs:
				for b in vecs:
					if a[0] == b[0]: continue
					var keys := {}
					for k in a[1]: keys[k] = true
					for k in b[1]: keys[k] = true
					var ge := true; var gt := false
					for k in keys:
						var da := float(a[1].get(k, 0.0)); var dbv := float(b[1].get(k, 0.0))
						if da < dbv - 0.05: ge = false
						if da > dbv + 0.3: gt = true
					if ge and gt:
						data_warnings.append("%s: option %s looks strictly better than %s on every track - give it a cost" % [w, a[0], b[0]])
			fork_list.append(f)
			forks[id] = f
	# second pass: references to other forks
	for f in fork_list:
		var req: Dictionary = f.get("requires", {}) if typeof(f.get("requires", {})) == TYPE_DICTIONARY else {}
		for key in ["choice", "not_choice"]:
			if req.has(key):
				if typeof(req[key]) != TYPE_DICTIONARY:
					_err(str(f["id"]), "requires.%s must be {\"<fork or event id>\": \"<option id or index>\"}" % key)
					continue
				for src in req[key]:
					if not forks.has(str(src)) and not event_by_id.has(str(src)):
						_err(str(f["id"]), "requires.%s refers to unknown fork/event %s" % [key, src])
	fork_list.sort_custom(func(a, b): return str(a.get("date", "")) < str(b.get("date", "")))


func _load_wars() -> void:
	for p in _data_dir_files("wars"):
		var fname: String = p.get_file()
		var j := JSON.new()
		if j.parse(FileAccess.get_file_as_string(p)) != OK:
			_err(fname, "JSON error line %d: %s" % [j.get_error_line(), j.get_error_message()])
			continue
		var w = j.data
		if typeof(w) != TYPE_DICTIONARY:
			_err(fname, "a war file must be one object")
			continue
		var id := str(w.get("id", ""))
		var where := "%s %s" % [fname, id]
		if id == "" or fname.get_basename() != id:
			_err(where, "\"id\" must equal the file name (%s)" % fname.get_basename())
		if wars.has(id):
			_err(where, "duplicate war id")
			continue
		_scan_deleted(where, w)
		var evid := str(w.get("event", ""))
		var ev = event_by_id.get(evid)
		if ev == null:
			_err(where, "event %s is not in events.json" % evid)
		elif not (str(ev.get("kind", "")) in ["war", "military_operation", "security"]):
			_err(where, "event %s has kind %s; wars attach to kind war, military_operation or security (uprisings)" % [evid, ev.get("kind", "")])
		if w.has("kind") and not (str(w["kind"]) in ["war", "uprising", "deterrence", "operation"]):
			_err(where, "\"kind\" must be war, uprising, deterrence or operation")
		# v2 fixes: variants (the war follows fork answers), a later low-cadence stage, wars run alongside others
		for vr in w.get("variants", []):
			if typeof(vr) != TYPE_DICTIONARY or typeof(vr.get("if_choice")) != TYPE_DICTIONARY or vr["if_choice"].is_empty():
				_err(where, "each variant needs \"if_choice\": {\"<fork id>\": \"<option>\" | [...]}")
				continue
			for src in vr["if_choice"]:
				if not forks.has(str(src)) and not event_by_id.has(str(src)): _err(where, "variant refers to unknown fork/event %s" % src)
			if vr.has("kind") and not (str(vr["kind"]) in ["war", "uprising", "deterrence"]): _err(where, "variant kind must be war, uprising or deterrence")
			if vr.has("turns") and int(vr["turns"]) < 1: _err(where, "variant turns must be >= 1")
		if w.has("continues"):
			var ct = w["continues"]
			if typeof(ct) != TYPE_DICTIONARY or not ct.has("until") or not _check_date(where + " continues.until", ct["until"], false):
				_err(where, "\"continues\" needs {\"until\": \"YYYY-MM\", \"every\": n, \"from\"?}")
		var nphases := 0
		if w.has("phases"):
			var phs = w["phases"]
			if typeof(phs) != TYPE_ARRAY or phs.size() < 2 or phs.size() > 4:
				_err(where, "\"phases\" must list 2-4 phases of the opening quarter")
			else:
				nphases = phs.size()
				for ph in phs:
					if typeof(ph) != TYPE_DICTIONARY or str(ph.get("name", "")).strip_edges() == "":
						_err(where, "each phase needs a \"name\"")
					elif ph.has("cite"):
						_check_cites(where + " phase", ph["cite"])
		if war_by_event.has(evid):
			_err(where, "event %s already has a war (%s)" % [evid, war_by_event[evid]["id"]])
		if str(w.get("title", "")).strip_edges() == "":
			_err(where, "missing \"title\"")
		var src = w.get("source", [])
		if typeof(src) != TYPE_ARRAY or src.is_empty():
			_err(where, "needs a non-empty \"source\" list")
		else:
			for sid in src:
				if not sources.has(str(sid)): _err(where, "source %s not found" % sid)
		if w.has("turns") and (typeof(w["turns"]) != TYPE_FLOAT and typeof(w["turns"]) != TYPE_INT or int(w["turns"]) < 1 or int(w["turns"]) > 12):
			_err(where, "\"turns\" must be 1-12")
		var fronts = w.get("fronts", [])
		var is_op := str(w.get("kind", "")) == "operation"
		if is_op and (typeof(w.get("response_options")) != TYPE_ARRAY or w["response_options"].size() < 2):
			_err(where, "an operation needs 2-5 \"response_options\"")
		if typeof(fronts) != TYPE_ARRAY or (fronts.is_empty() and not is_op) or fronts.size() > 5:
			_err(where, "needs 1-5 fronts")
			continue
		var fids := {}
		for fr in fronts:
			if typeof(fr) != TYPE_DICTIONARY:
				_err(where, "a front is not an object")
				continue
			var fw := "%s front %s" % [where, fr.get("id", "?")]
			var fid := str(fr.get("id", ""))
			if fid == "" or fids.has(fid): _err(fw, "needs a unique \"id\"")
			fids[fid] = true
			if str(fr.get("name", "")).strip_edges() == "": _err(fw, "missing \"name\"")
			if not actors.has(str(fr.get("actor", ""))):
				_err(fw, "actor \"%s\" is not in actors.json (%s)" % [fr.get("actor", ""), ", ".join(actors.keys())])
			var reg = fr.get("region", [])
			if typeof(reg) != TYPE_ARRAY or reg.is_empty():
				_err(fw, "\"region\" must be a non-empty list of map region names")
			else:
				for r in reg:
					var found := false
					for k in tiles:
						if str(tiles[k].get("region", "")).find(str(r)) >= 0:
							found = true; break
					if not found: _err(fw, "region \"%s\" does not occur in map.json" % r)
			var an = fr.get("anchor")
			if typeof(an) == TYPE_STRING:
				if not city_by_id.has(an): _err(fw, "anchor city \"%s\" is not in cities.json" % an)
			elif typeof(an) == TYPE_ARRAY:
				if an.size() != 2 or not tiles.has(SimHex.key(int(an[0]), int(an[1]))): _err(fw, "anchor [q, r] is not a map tile")
			else:
				_err(fw, "\"anchor\" must be a city id or [q, r]")
			var n = fr.get("formations")
			if not (typeof(n) in [TYPE_INT, TYPE_FLOAT]) or int(n) < 1 or int(n) > 6:
				_err(fw, "\"formations\" must be 1-6")
			for ut in fr.get("unit_types", []):
				if not (str(ut) in WAR_UNITS): _err(fw, "unit type \"%s\" not allowed (%s)" % [ut, ", ".join(WAR_UNITS)])
			for k in ["from", "until"]:
				if fr.has(k): _check_date(fw + " " + k, fr[k], false)
			if fr.has("phase") and (not (typeof(fr["phase"]) in [TYPE_INT, TYPE_FLOAT]) or int(fr["phase"]) < 0 or int(fr["phase"]) > nphases):
				_err(fw, "\"phase\" must be 0 (every phase) or 1-%d" % nphases)
			if fr.has("ground") and not (str(fr["ground"]) in SimMilitary.GROUND):
				_err(fw, "\"ground\" must be one of %s" % ", ".join(SimMilitary.GROUND.keys()))
			if fr.has("role") and not (str(fr["role"]) in ["defend", "strike_launchers", "strike_target"]):
				_err(fw, "\"role\" must be defend, strike_launchers or strike_target")
			if fr.has("spawn_inside") and typeof(fr["spawn_inside"]) != TYPE_BOOL:
				_err(fw, "\"spawn_inside\" must be true or false")
			_check_cites(fw, fr.get("cite"))
		for o in w.get("response_options", []):
			if typeof(o) != TYPE_DICTIONARY or str(o.get("id", "")) == "" or str(o.get("label", "")) == "":
				_err(where, "each response option needs id and label")
			elif is_op:
				_check_cites(where + " option " + str(o["id"]), o.get("cite"))
		wars[id] = w
		if ev != null:
			war_by_event[evid] = w


func validate_forks_and_wars() -> Array:
	return data_errors


# ------------------------------------------------------------------ queries

func tile(q: int, r: int):
	return tiles.get(SimHex.key(q, r))


func border_era_at(turn: int) -> String:
	## The border era in force at a turn (latest whose start <= date).
	var best := ""
	var best_t := -99999
	for e in border_eras:
		var st := turn_of(e.get("start"), 1)
		if st <= turn and st > best_t and borders.has(e.get("id")):
			best = e["id"]; best_t = st
	if best == "" and border_eras.size() > 0:
		best = border_eras[0].get("id", "")
	return best


func border_set(turn: int) -> Dictionary:
	return borders.get(border_era_at(turn), {})


func military_set(turn: int) -> Dictionary:
	return military.get(border_era_at(turn), {})


func cliff(k: int, dir: int) -> bool:
	var t = tiles.get(k)
	if t == null:
		return false
	var ce = t.get("cliff_edges")
	return typeof(ce) == TYPE_ARRAY and ce.has(dir)


func era_at(turn: int) -> Dictionary:
	var cur: Dictionary = eras[0] if eras.size() > 0 else {}
	for e in eras:
		if turn_of(e.get("start"), 1) <= turn:
			cur = e
	return cur


func city_status_at(c: Dictionary, turn: int) -> String:
	var st := ""
	for s in c.get("status", []):
		var a := turn_of(s.get("from"), 1)
		var b := turn_of(s.get("to"), 99999)
		if a <= turn and turn < b:
			st = str(s.get("status", ""))
	return st


func city_pop_at(c: Dictionary, year: float) -> float:
	## Interpolated census population (0 if no data). Extrapolates flat beyond the last point.
	var pts := []
	var pop: Dictionary = c.get("population", {})
	for y in pop:
		if pop[y] != null:
			pts.append(Vector2(float(y) + 0.5, float(pop[y])))
	if pts.is_empty():
		return 0.0
	pts.sort_custom(func(a, b): return a.x < b.x)
	if year <= pts[0].x:
		return pts[0].y
	for i in range(pts.size() - 1):
		if year <= pts[i + 1].x:
			var f: float = (year - pts[i].x) / maxf(0.01, pts[i + 1].x - pts[i].x)
			return lerpf(pts[i].y, pts[i + 1].y, f)
	return pts[pts.size() - 1].y


func real_value(series: String, year_float: float) -> float:
	## Linear interpolation in real_series.json; -1 when outside the data range.
	var s = real.get(series, {})
	if typeof(s) != TYPE_DICTIONARY:
		return -1.0
	var vals: Dictionary = s.get("values", {})
	var pts := []
	for y in vals:
		pts.append(Vector2(float(y) + (0.37 if series == "population" else 0.5), float(vals[y])))
	if pts.is_empty():
		return -1.0
	pts.sort_custom(func(a, b): return a.x < b.x)
	if year_float < pts[0].x - 0.6 or year_float > pts[pts.size() - 1].x + 1.5:
		return -1.0
	if year_float <= pts[0].x:
		return pts[0].y
	for i in range(pts.size() - 1):
		if year_float <= pts[i + 1].x:
			return lerpf(pts[i].y, pts[i + 1].y, (year_float - pts[i].x) / (pts[i + 1].x - pts[i].x))
	return pts[pts.size() - 1].y


func real_latest(series: String) -> Dictionary:
	## The last data point of a real-world series: {year, value} (empty if none).
	var s = real.get(series, {})
	if typeof(s) != TYPE_DICTIONARY:
		return {}
	var vals: Dictionary = s.get("values", {})
	var by := -1
	for y in vals:
		by = maxi(by, int(y))
	if by < 0:
		return {}
	return {"year": by, "value": float(vals[str(by)])}


func immigration_in_year(y: int) -> float:
	var vals: Dictionary = real.get("immigration", {}).get("values", {})
	return float(vals.get(str(y), vals.get(str(mini(y, year_of(LAST_TURN))), 25000)))


func hist_tech_count(turn: int) -> int:
	var y := year_f(turn)
	var n := 0
	for t in tech_list:
		if t.get("year") != null and float(t["year"]) + 0.5 <= y:
			n += 1
	return n


# ------------------------------------------------------------------ validation (used by sim_test)

func validate_sources() -> Array:
	## Every dated item in sim-owned data must carry at least one source id that exists in SOURCES.md.
	var problems := []
	if sources.is_empty():
		problems.append("SOURCES.md not readable from " + sources_path())
		return problems
	var groups := {"tech": tech_list, "civic": civic_list, "policy": policy_list, "project": projects.values(), "era": eras}
	for g in groups:
		for x in groups[g]:
			var dated: bool = x.get("year") != null or x.get("start") != null or x.get("date") != null
			var src = x.get("source", [])
			if dated and (typeof(src) != TYPE_ARRAY or src.is_empty()):
				problems.append("%s %s is dated but has no source" % [g, x.get("id")])
			if typeof(src) == TYPE_ARRAY:
				for s in src:
					if not sources.has(str(s)):
						problems.append("%s %s cites unknown source %s" % [g, x.get("id"), s])
	for term in gov.get("terms", []):
		for s in term.get("source", []):
			if not sources.has(str(s)):
				problems.append("government term %s cites unknown source %s" % [term.get("start"), s])
		if term.get("source", []).is_empty():
			problems.append("government term %s has no source" % term.get("start"))
	for rl in gov.get("rails", []):
		for s in rl.get("source", []):
			if not sources.has(str(s)):
				problems.append("rail %s cites unknown source %s" % [rl.get("date"), s])
	for key in real:
		if typeof(real[key]) == TYPE_DICTIONARY:
			for s in real[key].get("source", []):
				if not sources.has(str(s)):
					problems.append("real series %s cites unknown source %s" % [key, s])
	return problems


# v3 fix round (fix-v3a): content dated after the configured end of the game (civ/last_turn, Q3 2023) stays in
# the data but is never listed or shown (the Civilopedia, "Coming up", the ghost and history panels, the event log).
static func shown_until() -> int:
	return Sim.full_last_turn()


func event_shown(ev) -> bool:
	if typeof(ev) != TYPE_DICTIONARY or ev.is_empty() or deleted_ids.has(str(ev.get("id", ""))):
		return false
	return int(ev.get("_turn", turn_of(ev.get("date"), LAST_TURN))) <= shown_until()


func war_shown(w) -> bool:
	if typeof(w) != TYPE_DICTIONARY or w.is_empty():
		return false
	return event_shown(event_by_id.get(str(w.get("event", "")), {}))


func fork_shown(f) -> bool:
	if typeof(f) != TYPE_DICTIONARY or f.is_empty():
		return false
	return turn_of(f.get("date"), LAST_TURN) <= shown_until()


func event_id_shown(eid: String) -> bool:
	return event_shown(event_by_id.get(eid, {}))


# v3 fix round (fix3-story, A11 BLOCKER): nothing dated after the game's end (Q3 2023) is ever shown. The data keeps
# what it has; at load SimDB drops city status entries that start after the end, removes sentences that mention a
# later year from displayed text (notes, descriptions, cite claims), caps year ranges ("2017-2026" -> "2017-2023"),
# and moves the real year of a tech/civic/building/unit dated after the end to "_hist_year" (so the UI shows no
# date; the sim still gates it by that year through SimDB.hist_year). Items may give "<field>_until_end"
# replacements (description, source, cite) to show instead.
static var _yr_re: RegEx = null
static var _range_re: RegEx = null


static func end_year() -> int:
	return year_of(shown_until())


static func after_end(date) -> bool:
	## True for a date after the last shown quarter (null/empty dates are not after the end).
	return turn_of(date, -1) > shown_until()


static func hist_year(item):
	## The real year of a tech/civic/building/unit/project, including one dated after the game's end (hidden "_hist_year").
	if typeof(item) != TYPE_DICTIONARY: return null
	if item.get("year") != null: return item["year"]
	if item.get("hist_after_end", false): return end_year() + 2   # not fielded in history by Q3 2023 (Iron Beam): gated as two years after the end
	return item.get("_hist_year")


static func _year_regexes() -> void:
	if _yr_re == null:
		_yr_re = RegEx.new()
		_yr_re.compile("(?<![\\d/.-])(20[2-9]\\d)(?![\\d])")
		_range_re = RegEx.new()
		_range_re.compile("\\b(1[89]\\d\\d|20\\d\\d)(\\s*[-–]\\s*)(20[2-9]\\d)\\b")


static func years_after_end(s: String) -> Array:
	## Years after the game's end mentioned in a text (2024-2099; "Decision 2077"-style numbers are not years).
	_year_regexes()
	var out := []
	var ey := end_year()
	for m in _yr_re.search_all(s):
		var y := int(m.get_string(1))
		var pre := s.substr(maxi(0, m.get_start() - 12), mini(12, m.get_start())).to_lower()
		if pre.ends_with("decision ") or pre.ends_with("resolution ") or pre.ends_with("no. ") or pre.ends_with("code ") or pre.ends_with("החלטת ממשלה ") or pre.ends_with("החלטה "):
			continue
		if y > ey and y < 2100: out.append(y)
	return out


static func scrub_text(s: String) -> String:
	## The text as it may be shown: year ranges capped at the end year, sentences about later years removed.
	if s == "": return s
	_year_regexes()
	var ey := end_year()
	var t := s
	for m in _range_re.search_all(s):
		if int(m.get_string(3)) > ey:
			t = t.replace(m.get_string(), "%s%s%d" % [m.get_string(1), m.get_string(2), ey] if int(m.get_string(1)) < ey else m.get_string(1))
	if years_after_end(t).is_empty():
		return t
	var keep := []
	var sent := RegEx.new()
	sent.compile("[^.!?;]+[.!?;]*\\s*")
	for m in sent.search_all(t):
		var part := m.get_string()
		if years_after_end(part).is_empty():
			keep.append(part)
	return "".join(keep).strip_edges().trim_suffix(";").strip_edges()


func _scrub_cites(cites) -> Array:
	var out := []
	if typeof(cites) != TYPE_ARRAY: return out
	for c in cites:
		if typeof(c) != TYPE_DICTIONARY:
			out.append(c); continue
		var bad := false
		for k in ["claim", "note"]:   # a verbatim quote is bibliography (a CBS table row's locality code 2042 is not a year)
			if not years_after_end(str(c.get(k, ""))).is_empty(): bad = true
		if not bad: out.append(c)
	return out


## v3 integration (2026-10-14): everything dated after Q3 2023 is now deleted from the data at the source
## (tools/purge_after_end.py), so this load-time scrub is only a safety net and should change nothing. Whatever it
## does change is listed in `scrub_log` (sim_test fails on any entry).
static var scrub_log: Array = []


static func _note_scrub(what: String) -> void:
	if scrub_log.size() < 200: scrub_log.append(what)


func _scrub_logged(where: String, s: String) -> String:
	var t := scrub_text(s)
	if t != s: _note_scrub("%s: text mentions a year after the end" % where)
	return t


func _scrub_cites_logged(where: String, cites) -> Array:
	var out := _scrub_cites(cites)
	if typeof(cites) == TYPE_ARRAY and out.size() != (cites as Array).size(): _note_scrub("%s: cite dated after the end" % where)
	return out


func _filter_after_end() -> void:
	scrub_log.clear()
	var ey := end_year()
	# cities: the status timeline ends at the game's end; notes and cites lose what happened later
	for c in cities:
		var cid := "city %s" % str(c.get("id", ""))
		var keep := []
		for st in c.get("status", []):
			if typeof(st) != TYPE_DICTIONARY or after_end(st.get("from")):
				_note_scrub("%s: status from %s" % [cid, str(st.get("from", "")) if typeof(st) == TYPE_DICTIONARY else "?"])
				continue
			if st.get("to") != null and after_end(st.get("to")):
				_note_scrub("%s: status until %s" % [cid, str(st.get("to"))])
				st["to"] = null
			if st.has("note"): st["note"] = _scrub_logged(cid + " status note", str(st["note"]))
			if st.has("cite"): st["cite"] = _scrub_cites_logged(cid + " status", st["cite"])
			keep.append(st)
		c["status"] = keep
		for k in ["founded_note", "note", "description"]:
			if c.has(k): c[k] = _scrub_logged(cid + " " + k, str(c[k]))
		for k in ["founded_cite", "population_cite"]:
			if c.has(k): c[k] = _scrub_cites_logged(cid + " " + k, c[k])
		var pop = c.get("population")
		if typeof(pop) == TYPE_DICTIONARY:
			for y in pop.keys():
				if int(str(y).substr(0, 4)) > ey:
					pop.erase(y)
					_note_scrub("%s: population %s" % [cid, str(y)])
	# trees and items: no date after the end, no text about later years
	for coll in [techs, civics, buildings, units, projects, policies, districts]:
		for id in coll:
			var it = coll[id]
			if typeof(it) != TYPE_DICTIONARY: continue
			var iid := "item %s" % str(id)
			if it.get("year") != null and int(it["year"]) > ey:
				it["_hist_year"] = it["year"]
				it["year"] = null
				it.erase("date")
				_note_scrub("%s: history year %s" % [iid, str(it["_hist_year"])])
			for k in ["description", "desc", "text", "note", "history"]:
				if it.has(k + "_until_end"):
					it[k] = it[k + "_until_end"]
					_note_scrub("%s: %s_until_end used" % [iid, k])
				elif it.has(k) and typeof(it[k]) == TYPE_STRING:
					it[k] = _scrub_logged(iid + " " + k, str(it[k]))
			for k in ["source", "cite"]:
				if it.has(k + "_until_end"):
					it[k] = it[k + "_until_end"]
					_note_scrub("%s: %s_until_end used" % [iid, k])
			if it.has("cite"): it["cite"] = _scrub_cites_logged(iid, it["cite"])
	for e in eras:
		if typeof(e) == TYPE_DICTIONARY:
			for k in ["note", "name", "description"]:
				if e.has(k): e[k] = _scrub_logged("era %s %s" % [str(e.get("id", "")), k], str(e[k]))
	# cabinet programmes and coalition partners: their spans end with the game
	for m in gov.get("ministries", []):
		if typeof(m) != TYPE_DICTIONARY: continue
		for p in m.get("promotions", []):
			if typeof(p) == TYPE_DICTIONARY and p.get("until") != null and int(p["until"]) > ey:
				p["until"] = ey
				_note_scrub("ministry %s: promotion until %s" % [str(m.get("id", "")), str(p["until"])])
	for cp in gov.get("coalition_partners", []):
		if typeof(cp) == TYPE_DICTIONARY and cp.get("until") != null and typeof(cp["until"]) != TYPE_STRING and int(cp["until"]) > ey:
			cp["until"] = ey
			_note_scrub("coalition partner %s: until after the end" % str(cp.get("id", "")))
	for k in real:
		if typeof(real[k]) == TYPE_DICTIONARY and real[k].has("note"):
			real[k]["note"] = _scrub_logged("real series %s note" % str(k), str(real[k]["note"]))


static func scrub_programmes(projects_data: Dictionary) -> void:
	## SimEndgame's programmes (data/projects.json): a level dated after the game's end shows no history date; it
	## opens when it would have (EARLY_YEARS before its real date) as a level history had not reached by Q3 2023.
	## (Safety net since the 2026-10-14 purge: changes are listed in scrub_log.)
	for p in projects_data.get("programmes", []):
		if typeof(p) != TYPE_DICTIONARY: continue
		var pid := "programme %s" % str(p.get("id", ""))
		for k in ["desc", "description"]:
			if p.has(k):
				var t0 := str(p[k]); p[k] = scrub_text(t0)
				if p[k] != t0: _note_scrub(pid + " " + k)
		for l in p.get("levels", []):
			if typeof(l) != TYPE_DICTIONARY: continue
			if l.get("hist") != null and after_end(l["hist"]):
				_note_scrub("%s level %s: history date %s" % [pid, str(l.get("level", "")), str(l["hist"])])
				l["_hist"] = l["hist"]
				if not l.has("from"):
					l["from"] = date_iso(maxi(1, turn_of(l["hist"], 1) - 32))
				l.erase("hist")
				if str(l.get("advocate", "")) == "":
					l["advocate"] = str(l.get("advocate_until_end", "its developers (not yet in service in history by Q3 2023)"))
			for k in ["desc", "cite"]:
				if l.has(k + "_until_end"):
					l[k] = l[k + "_until_end"]
					_note_scrub("%s level %s: %s_until_end used" % [pid, str(l.get("level", "")), k])
			if l.has("desc"):
				var d0 := str(l["desc"]); l["desc"] = scrub_text(d0)
				if l["desc"] != d0: _note_scrub("%s level %s desc" % [pid, str(l.get("level", ""))])
			if l.has("cite") and typeof(l["cite"]) == TYPE_ARRAY:
				var n0: int = l["cite"].size()
				l["cite"] = l["cite"].filter(func(c): return typeof(c) != TYPE_DICTIONARY or (years_after_end(str(c.get("quote", ""))).is_empty() and years_after_end(str(c.get("claim", ""))).is_empty()))
				if l["cite"].size() != n0: _note_scrub("%s level %s: cite dated after the end" % [pid, str(l.get("level", ""))])


func validate_refs() -> Array:
	## Cross-references between data files (unlock ids, prereqs, building districts, event unlock ids).
	var problems := []
	for t in tech_list:
		for p in t.get("prereqs", []):
			if not techs.has(p): problems.append("tech %s prereq %s missing" % [t["id"], p])
		for kind in ["buildings", "districts", "units", "improvements", "projects"]:
			for x in t.get("unlocks", {}).get(kind, []):
				if not _has_kind(kind, x): problems.append("tech %s unlocks unknown %s %s" % [t["id"], kind, x])
	for c in civic_list:
		for p in c.get("prereqs", []):
			if not civics.has(p): problems.append("civic %s prereq %s missing" % [c["id"], p])
		for kind in ["buildings", "districts", "policies"]:
			for x in c.get("unlocks", {}).get(kind, []):
				if not _has_kind(kind, x): problems.append("civic %s unlocks unknown %s %s" % [c["id"], kind, x])
	for b in buildings.values():
		if not districts.has(b.get("district", "")): problems.append("building %s in unknown district" % b["id"])
	for p in policy_list:
		var u: Dictionary = p.get("unlock", {})
		if u.has("civic") and not civics.has(u["civic"]): problems.append("policy %s unlock civic missing" % p["id"])
		if u.has("tech") and not techs.has(u["tech"]): problems.append("policy %s unlock tech missing" % p["id"])
	for ev in events:
		for t in ev["effects"].get("unlock_tech", []):
			if not techs.has(str(t)): problems.append("event %s unlocks unknown tech %s" % [ev["id"], t])
		for c in ev["effects"].get("unlock_civic", []):
			if not civics.has(str(c)): problems.append("event %s unlocks unknown civic %s" % [ev["id"], c])
	return problems


func _has_kind(kind: String, id: String) -> bool:
	match kind:
		"buildings": return buildings.has(id)
		"districts": return districts.has(id)
		"units": return units.has(id)
		"improvements": return improvements.has(id)
		"projects": return projects.has(id)
		"policies": return policies.has(id)
	return false
