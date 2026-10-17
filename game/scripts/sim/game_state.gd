class_name GameState
extends RefCounted
## All mutable simulation state. Serialises to JSON (save/load). Rules live in Sim.

const VERSION := 1
const FIELDS := [
	"version", "mode", "rng_seed", "rng_state", "turn", "game_over",
	"gold", "inflation", "cohesion", "standing", "readiness_bonus", "readiness", "war_weariness",
	"techs", "civics", "tech_progress", "civic_progress", "current_tech", "current_civic", "boosts", "repeat_count",
	"policies", "free_swap", "gov_term", "capital", "next_id", "tiles", "rural",
	"diplomacy", "trade_routes", "fired_events", "pending_events", "event_log", "choices_made", "crises", "crisis_log",
	"gold_mods", "temp_effects", "water", "era", "era_score", "age", "dedication", "ages", "timeline", "counters",
	"ministries", "agenda", "budget_focus", "history", "notifications", "errors", "milestones", "projects",
	"unit_builds", "displaced", "immigration_year", "humanitarian", "pending_dedication", "crisis_decision",
	"last_decisions", "unit_kills", "units_lost", "stat_log", "streams", "flags", "immigration_plan", "pending_forks", "fork_choices",
	"budget", "diplo",
]

var version := VERSION
var mode := "player"          # "player" | "historical" (the ghost-of-history autoplayer)
var rng_seed := 0
var rng_state := 0
var turn := 1
var game_over := false
var gold := 120.0
var inflation := 4.0          # % per year (period mechanic, MECHANICS 29.2)
var cohesion := 30.0          # replaces Faith (spendable)
var standing := 50.0          # International Standing index
var readiness_bonus := 0.0    # lasting readiness earned or lost in crises
var readiness := 40.0
var war_weariness := 0.0
var techs := {}               # id -> turn completed
var civics := {}
var tech_progress := {}
var civic_progress := {}
var current_tech := ""
var current_civic := ""
var boosts := {}              # "tech:id" / "civic:id" -> turn
var repeat_count := {}
var policies: Array = []      # [{slot, id}]
var free_swap := true
var gov_term := -1
var capital := ""             # city key
var next_id := 1
var tiles := {}               # tile key -> {o: city id, imp, d (district), f (feature override), pil}
var rural := 0.0              # residents of localities not modelled as cities
var diplomacy := {}           # actor -> {status, relation, since, last_delegation}
var trade_routes: Array = []  # [{from, partner, turns}]
var fired_events := {}        # id -> turn
var pending_events: Array = []# [event id] awaiting a choice
var event_log: Array = []     # [{turn, id, title, kind, choice}]
var choices_made := {}        # event id -> choice index
var crises: Array = []        # active scripted crises
var crisis_log: Array = []
var gold_mods: Array = []     # [{amount, until, src}]
var temp_effects: Array = []  # [{type, ..., until}]
var stat_log: Array = []      # [{turn, stat, amount, reason}] lasting-stat changes with their reason
var streams: Array = []       # multi-year terms set by choices [{type, amount, from, until, label, src}]
var flags := {}               # choice flags -> turn set (e.g. "refused_reparations")
var pending_forks: Array = []  # fork ids offered this turn and not yet decided
var fork_choices := {}         # fork id -> chosen option id
var immigration_plan := {}    # {turn, option, amount} placement decision for the coming quarter
var water := {"supply": 0.0, "demand": 0.0, "ratio": 1.0, "deficit_turns": 0, "reserve": 70.0}
var era := 1
var era_score := 0
var age := "normal"
var dedication := ""
var ages: Array = []
var timeline: Array = []      # historic moments [{turn, text, score, kind}]
var counters := {}
var ministries := {}          # minister (portfolio) id -> {city, since, promotions:[ids], appointed, partner}
var diplo := {}               # v3 diplomacy (SimDiplomacy): {applied, deals, exposure, envoys, pending, log, ...}
var budget := {}              # state budget in force: {fy, turn, until, shares:{envelope: share}, preset, extra, reviewed}
var agenda := {}              # the generated cabinet agenda decision for this turn
var budget_focus := {}        # {yield, until}
var history: Array = []       # per-turn track samples
var notifications: Array = []
var errors: Array = []
var milestones := {}          # "tech:x" -> turn etc. (compared against the ghost)
var projects := {}            # national project id -> {city, turn}
var unit_builds := {}         # unit type -> count built (cost progression)
var displaced: Array = []     # [{city, n, until}]
var immigration_year := {}    # year -> immigrants placed
var humanitarian := {}        # side -> {killed_low, killed_high, displaced_low, displaced_high}
var pending_dedication := false
var crisis_decision := {}     # current crisis-response decision
var last_decisions: Array = []
var unit_kills := 0
var units_lost := 0

var cities: Array = []        # [SimCity]
var units: Array = []         # [SimUnit]


func to_dict() -> Dictionary:
	var d := {}
	for f in FIELDS:
		d[f] = get(f)
	d["cities"] = cities.map(func(c): return c.to_dict())
	d["units"] = units.map(func(u): return u.to_dict())
	return d


static func from_dict(d: Dictionary) -> GameState:
	var s := GameState.new()
	for f in FIELDS:
		if d.has(f):
			s.set(f, d[f])
	s.turn = int(s.turn); s.next_id = int(s.next_id); s.era = int(s.era); s.era_score = int(s.era_score)
	s.gov_term = int(s.gov_term); s.rng_seed = int(s.rng_seed); s.rng_state = int(s.rng_state)
	var t := {}
	for k in s.tiles:
		t[int(k)] = s.tiles[k]
	s.tiles = t
	for k in s.techs: s.techs[k] = int(s.techs[k])
	for k in s.civics: s.civics[k] = int(s.civics[k])
	s.cities = []
	for c in d.get("cities", []):
		s.cities.append(SimCity.from_dict(c))
	s.units = []
	for u in d.get("units", []):
		s.units.append(SimUnit.from_dict(u))
	return s


func save_json(path: String) -> Error:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return FileAccess.get_open_error()
	f.store_string(JSON.stringify(to_dict()))
	return OK


static func load_json(path: String) -> GameState:
	if not FileAccess.file_exists(path):
		return null
	var data = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(data) != TYPE_DICTIONARY:
		return null
	return from_dict(data)
