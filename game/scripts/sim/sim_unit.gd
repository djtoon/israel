class_name SimUnit
extends RefCounted
## A unit on the map. owner is "player" or an actor id (hostile forces in scripted crises).

var id := 0
var type := ""
var owner := "player"
var q := 0
var r := 0
var hp := 100.0
var moves := 0.0
var xp := 0.0
var level := 0
var charges := 0
var fortify := 0              # turns fortified
var orders := ""              # "" | fortify | sleep | skip | goto
var target := Vector2i(-1, -1)
var crisis := ""              # crisis id for hostile / reserve units
var acted := false
var cs_override := 0          # period strength for hostile units
var range_bonus := 0          # long-range rocket fronts (war files) reach their anchor city


func pos() -> Vector2i:
	return Vector2i(q, r)


func to_dict() -> Dictionary:
	return {"id": id, "type": type, "owner": owner, "q": q, "r": r, "hp": hp, "moves": moves, "xp": xp, "level": level,
		"charges": charges, "fortify": fortify, "orders": orders, "target": [target.x, target.y], "crisis": crisis,
		"acted": acted, "cs_override": cs_override, "range_bonus": range_bonus}


static func from_dict(d: Dictionary) -> SimUnit:
	var u := SimUnit.new()
	for k in d:
		if k == "target":
			var t = d[k]
			u.target = Vector2i(int(t[0]), int(t[1])) if typeof(t) == TYPE_ARRAY and t.size() == 2 else Vector2i(-1, -1)
		elif k in u:
			u.set(k, d[k])
	u.id = int(d.get("id", 0)); u.q = int(d.get("q", 0)); u.r = int(d.get("r", 0))
	u.level = int(d.get("level", 0)); u.charges = int(d.get("charges", 0)); u.fortify = int(d.get("fortify", 0))
	u.cs_override = int(d.get("cs_override", 0))
	u.range_bonus = int(d.get("range_bonus", 0))
	return u
