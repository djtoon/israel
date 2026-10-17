class_name UIArt
extends RefCounted
## Portraits and event illustrations from data/art_manifest.json (the art-2d piece), with a file fallback
## (assets/images/portraits/<id>.png, assets/images/events/<event id>[_768].png). Anything missing returns null,
## so every screen works without art. Accepted manifest shapes:
##   {"portraits": {id: {path, ...}} | [{id, path, ...}], "events": {...} | [...]}   or   [{id, kind, path, ...}]
## Entry keys used: path (res:// or relative to res://), thumb / path_768 (smaller variant), name, title, actor,
## from / until (years, for leaders), credit, alt.

const MANIFEST := "res://data/art_manifest.json"
const PORTRAIT_DIR := "res://assets/images/portraits/"
const EVENT_DIR := "res://assets/images/events/"

static var _loaded := false
static var portraits := {}     # id -> entry
static var events := {}        # event id -> entry
static var _tex := {}          # path -> Texture2D (or null)


static func reload() -> void:
	_loaded = false
	portraits.clear()
	events.clear()
	_tex.clear()


static func _load() -> void:
	if _loaded:
		return
	_loaded = true
	if not FileAccess.file_exists(MANIFEST):
		return
	var d = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST))
	if typeof(d) == TYPE_ARRAY:
		for e in d:
			if typeof(e) == TYPE_DICTIONARY:
				var k := str(e.get("kind", e.get("type", "")))
				(events if k.begins_with("event") else portraits)[str(e.get("id", ""))] = e
		return
	if typeof(d) != TYPE_DICTIONARY:
		return
	for sec in [["portraits", portraits], ["leaders", portraits], ["ministers", portraits], ["events", events], ["illustrations", events]]:
		var v = d.get(sec[0])
		if typeof(v) == TYPE_DICTIONARY:
			for id in v:
				var e = v[id]
				if typeof(e) == TYPE_STRING:
					e = {"path": e}
				if typeof(e) == TYPE_DICTIONARY:
					var e2: Dictionary = (e as Dictionary).duplicate()
					e2["id"] = str(e2.get("id", id))
					(sec[1] as Dictionary)[str(id)] = e2
		elif typeof(v) == TYPE_ARRAY:
			for e in v:
				if typeof(e) == TYPE_DICTIONARY:
					(sec[1] as Dictionary)[str(e.get("id", e.get("event", "")))] = e


static func _res(p: String) -> String:
	if p == "":
		return ""
	if p.begins_with("res://") or p.begins_with("user://"):
		return p
	p = p.trim_prefix("game/").trim_prefix("/")
	return "res://" + p


static func texture(path: String) -> Texture2D:
	path = _res(path)
	if path == "":
		return null
	if _tex.has(path):
		return _tex[path]
	var t: Texture2D = null
	if ResourceLoader.exists(path):
		t = load(path) as Texture2D
	elif FileAccess.file_exists(path):
		var img := Image.load_from_file(ProjectSettings.globalize_path(path))
		if img != null and not img.is_empty():
			t = ImageTexture.create_from_image(img)
	_tex[path] = t
	return t


static func _entry_tex(e: Dictionary, small: bool) -> Texture2D:
	var keys := ["file_small", "thumb", "path_768", "small", "file", "path"] if small else ["file", "path", "file_small", "path_768", "thumb"]
	for k in keys:
		var t := texture(str(e.get(k, "")))
		if t != null:
			return t
	return null


static func portrait(id: String) -> Texture2D:
	_load()
	if id == "":
		return null
	if portraits.has(id):
		var t := _entry_tex(portraits[id], false)
		if t != null:
			return t
	return texture(PORTRAIT_DIR + id + ".png")


static func portrait_entry(id: String) -> Dictionary:
	_load()
	return portraits.get(id, {})


static func event_art(eid: String, small := true) -> Texture2D:
	_load()
	if eid == "":
		return null
	if events.has(eid):
		var t := _entry_tex(events[eid], small)
		if t != null:
			return t
	for p in ([EVENT_DIR + eid + "_768.png", EVENT_DIR + eid + ".png"] if small else [EVENT_DIR + eid + ".png", EVENT_DIR + eid + "_768.png"]):
		var t2 := texture(p)
		if t2 != null:
			return t2
	return null


static func event_entry(eid: String) -> Dictionary:
	_load()
	return events.get(eid, {})


static func name_id(person: String) -> String:
	## "David Ben-Gurion" -> "ben_gurion", "Golda Meir" -> "meir" (the art-2d file naming).
	var p := person.strip_edges().split(" (")[0]
	var words := p.split(" ", false)
	if words.is_empty():
		return ""
	return words[words.size() - 1].to_lower().replace("-", "_").replace("'", "").replace(".", "")


static func pm_portrait(pm_name: String) -> Texture2D:
	if pm_name == "":
		return null
	_load()
	for id in portraits:
		var e: Dictionary = portraits[id]
		if str(e.get("name", "")) == pm_name and (str(id).begins_with("pm_") or str(e.get("role", "")) == "pm"):
			var t := _entry_tex(e, false)
			if t != null:
				return t
	return portrait("pm_" + name_id(pm_name))


const ACTOR_PREFIX := {"usa": "us", "us": "us", "egypt": "eg", "jordan": "jo", "syria": "sy", "lebanon": "lb", "ussr": "ru", "russia": "ru",
	"france": "fr", "uk": "uk", "britain": "uk", "germany": "de", "west_germany": "de", "turkey": "tr", "iran": "ir", "iraq": "iq",
	"plo": "plo", "pa": "pa", "palestinian_authority": "pa", "uae": "ae", "gulf": "ae", "saudi_arabia": "sa", "eu": "eu", "europe": "eu", "un": "un"}


const ACTOR_ALIAS := {"usa": ["us"], "ussr": ["russia"], "russia": ["ussr"], "west_germany": ["germany"], "eec_eu": ["eu"], "uk": ["britain"],
	"palestinian_authority": ["pa"], "pa": ["palestinian_authority"]}


static func leader(actor: String, year: int, leader_name := "") -> Dictionary:
	## {tex, name, title, id} for the actor's leader in that year: a manifest entry with actor == id and
	## from <= year <= until; else a file named <prefix>_<surname> when the sim names the leader.
	_load()
	var best := {}
	var aliases: Array = [actor, ACTOR_PREFIX.get(actor, actor)] + ACTOR_ALIAS.get(actor, [])
	for id in portraits:
		var e: Dictionary = portraits[id]
		if not str(e.get("actor", "")) in aliases:
			continue
		var f := int(e.get("from", e.get("era_from", -9999))); var u := int(e.get("until", e.get("era_to", 9999)))
		if year >= f and year <= u:
			if best.is_empty() or f > int(best.get("from", best.get("era_from", -9999))):
				best = e
	if not best.is_empty():
		var t := _entry_tex(best, false)
		return {"tex": t, "name": str(best.get("name", "")), "title": str(best.get("title", "")), "id": str(best.get("id", ""))}
	if leader_name != "":
		var pre: String = ACTOR_PREFIX.get(actor, actor)
		var t2 := portrait("%s_%s" % [pre, name_id(leader_name)])
		if t2 != null:
			return {"tex": t2, "name": leader_name, "title": "", "id": ""}
	return {}


static func minister_portrait(mid: String, year: int) -> Texture2D:
	_load()
	var best := {}
	for id in portraits:
		var e: Dictionary = portraits[id]
		if str(id).begins_with("minister_" + mid) or (str(e.get("minister", "")) == mid):
			var f := int(e.get("from", e.get("era_from", -9999))); var u := int(e.get("until", e.get("era_to", 9999)))
			if year >= f and year <= u and (best.is_empty() or f > int(best.get("from", best.get("era_from", -9999)))):
				best = e
	if not best.is_empty():
		return _entry_tex(best, false)
	var t := portrait("minister_" + mid)
	if t != null:
		return t
	# the art-2d generic minister set: min_<m|f><decade> by era (two of the seven portfolios drawn as women).
	# v3 final (fix4-ui, var N7): a portfolio's own generic portrait for the era, min_<m|f><decade>_<ministry>, when that
	# art exists (manifest entry or file); else the era's shared one (the Cabinet mirrors repeats so the cards differ)
	var g := "f" if mid in ["education", "absorption"] else "m"
	for id in portraits:
		var e2: Dictionary = portraits[id]
		if str(id).begins_with("min_" + g) and not str(id).trim_prefix("min_").contains("_") and year >= int(e2.get("era_from", -9999)) and year <= int(e2.get("era_to", 9999)):
			var own := portrait("%s_%s" % [str(id), mid])
			if own != null:
				return own
			return _entry_tex(e2, true)
	return null


static func advisor() -> Texture2D:
	var t := portrait("advisor")
	if t == null:
		t = portrait("advisor_secretary")
	return t
