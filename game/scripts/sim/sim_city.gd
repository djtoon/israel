class_name SimCity
extends RefCounted
## One player city (an Israeli locality from cities.json). Pure data; rules live in Sim.
## Population points follow MECHANICS.md 29.2: pop = round(sqrt(residents / 1000)), minimum 1.

var id := 0
var key := ""                 # cities.json id
var name := ""
var name_he := ""
var kind := "city"
var q := 0
var r := 0
var residents := 0.0
var legacy_housing := 0.0     # pre-existing housing stock (cities that exist at start or join by status)
var legacy_amenities := 0.0
var founded_turn := 1
var founded_by := "history"   # history | player | rails
var hist_founded_turn := 1    # the real founding / joining turn (baseline)
var buildings: Array = []
var districts := {}           # district id -> tile key
var district_cost := {}       # district id -> locked cost
var queue: Array = []         # [{kind, id, tile}]
var progress := {}            # "kind:id" -> production stored
var focus := ""               # "" | food | production | gold | science | culture
var border_culture := 0.0
var tiles_claimed := 0
var trust := 80.0
var hp := 200.0
var outer_hp := 0.0
var damaged := 0              # turns since last damage (0 = not damaged recently)
var automate := false
var status := "israel"
var active := true
var displaced := 0.0          # residents temporarily away (evacuations)
var camp := 0.0               # residents in transit camps (ma'abarot) until housing is built for them
var immigrants := 0.0         # cumulative immigrants received
var last_built := {}
var locked: Array = []        # tile keys the player locked for citizens (citizen management, v2)
var y := {}                   # yields computed this turn
var info := {}                # derived numbers this turn (housing, amenities, growth ...)


func pop() -> int:
	return maxi(1, int(round(sqrt(maxf(residents, 0.0) / 1000.0))))


func has_building(b: String) -> bool:
	return buildings.has(b)


func has_district(d: String) -> bool:
	return districts.has(d)


func pos() -> Vector2i:
	return Vector2i(q, r)


func to_dict() -> Dictionary:
	return {
		"id": id, "key": key, "name": name, "name_he": name_he, "kind": kind, "q": q, "r": r,
		"residents": residents, "legacy_housing": legacy_housing, "legacy_amenities": legacy_amenities,
		"founded_turn": founded_turn, "founded_by": founded_by, "hist_founded_turn": hist_founded_turn,
		"buildings": buildings, "districts": districts, "district_cost": district_cost, "queue": queue, "progress": progress,
		"focus": focus, "border_culture": border_culture, "tiles_claimed": tiles_claimed, "trust": trust, "hp": hp,
		"outer_hp": outer_hp, "damaged": damaged, "automate": automate, "status": status, "active": active,
		"displaced": displaced, "camp": camp, "immigrants": immigrants, "last_built": last_built, "locked": locked,
	}


static func from_dict(d: Dictionary) -> SimCity:
	var c := SimCity.new()
	for k in d:
		if k in c:
			c.set(k, d[k])
	c.id = int(d.get("id", 0))
	c.q = int(d.get("q", 0)); c.r = int(d.get("r", 0))
	var dd := {}
	for k in c.districts:
		dd[k] = int(c.districts[k])
	c.districts = dd
	c.locked = c.locked.map(func(k): return int(k))
	return c
