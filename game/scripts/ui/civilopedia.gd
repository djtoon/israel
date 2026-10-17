class_name Civilopedia
extends UIWindow
## Civ VI-style Civilopedia: tabbed, searchable reference built from game/data (techs, civics, buildings,
## districts, units, cities, events, wars, governments, policies). Every entry lists its source ids (with the
## citation and URL when the source registry has them). Links inside articles ([url=pedia:kind:id]) jump
## between entries; GameUI.open_pedia(kind, id) opens any entry from elsewhere in the UI.
## Content the user permanently deleted (7 Oct 2023 / the 2023 Gaza war) is never listed (SimDB tombstones
## plus a phrase guard).

const TABS := [["tech", "Technologies"], ["civic", "Civics"], ["building", "Buildings"], ["district", "Districts"], ["unit", "Units"],
	["city", "Cities"], ["event", "Events"], ["war", "Wars"], ["government", "Governments"], ["policy", "Policies"]]
const KIND_NAME := {"tech": "Technology", "civic": "Civic", "building": "Building", "project": "National project", "city_project": "City project",
	"improvement": "Improvement", "district": "District", "unit": "Unit", "city": "Locality", "event": "Event", "war": "War",
	"government": "Government", "term": "Government", "policy": "Policy card"}
const TAB_OF := {"project": "building", "city_project": "building", "improvement": "building", "term": "government"}
const ERA_NAMES := ["", "Independence and Austerity", "Statehood Consolidation", "Expansion and Crisis", "Upheaval and Reform", "Peace and Uprising", "Start-up Nation", "Regional Realignment"]

var tab := "tech"
var cur_kind := ""
var cur_id := ""
var search: LineEdit
var list_box: VBoxContainer
var article: RichTextLabel
var illus: TextureRect      # v3: the entry's illustration (event art, a prime minister's portrait), art-2d
var count_label: Label
var _tab_btns := {}
var _index := []        # [{kind, id, name, sub, text}]
var _by_key := {}       # "kind:id" -> entry
var _ban: RegEx
var _date7: RegEx
var _tag_re: RegEx
var _history: Array = []


func _init() -> void:
	super._init("Civilopedia")
	_date7 = RegEx.new()
	_date7.compile("(?i)\\b7 oct(ober)?\\.? 2023\\b")
	_ban = RegEx.new()
	_ban.compile("(?i)(7 october 2023|october 7,? 2023|7 oct(ober)? 2023|swords of iron|israel[-–]hamas war|2023[-–]2[0-9] gaza war|gaza war \\(2023|war in gaza \\(2023|october 7 attack)")


func _ready() -> void:
	_build()


func _build() -> void:
	clear_body()
	var tb := HFlowContainer.new()
	tb.add_theme_constant_override("h_separation", 4)
	tb.add_theme_constant_override("v_separation", 4)
	body.add_child(tb)
	for t in TABS:
		var k: String = t[0]
		var b := UITheme.button(t[1], func(): set_tab(k), 15)
		_tab_btns[k] = b
		tb.add_child(b)
	var sh := HBoxContainer.new()
	sh.add_theme_constant_override("separation", 8)
	body.add_child(sh)
	search = LineEdit.new()
	search.placeholder_text = "Search every tab (name or text)..."
	search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	search.clear_button_enabled = true
	search.add_theme_font_size_override("font_size", 17)
	search.add_theme_stylebox_override("normal", UITheme.sb(Color(0.02, 0.05, 0.11, 0.95), UIKit.GOLD_DARK, 1, 5, 8))
	search.add_theme_stylebox_override("focus", UITheme.sb(Color(0.03, 0.07, 0.15, 0.98), UIKit.GOLD_LIGHT, 1, 5, 8))
	search.text_changed.connect(func(_t): _fill_list())
	sh.add_child(search)
	count_label = UITheme.label("", 15, UIKit.TEXT_DIM)
	sh.add_child(count_label)
	var back := UITheme.button("Back", func(): go_back(), 15)
	back.tooltip_text = "Previous entry"
	sh.add_child(back)
	var split := HBoxContainer.new()
	split.add_theme_constant_override("separation", 10)
	split.custom_minimum_size = Vector2(0, 640)
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(split)
	var sc := ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.custom_minimum_size = Vector2(330, 0)
	split.add_child(sc)
	list_box = VBoxContainer.new()
	list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_box.add_theme_constant_override("separation", 2)
	sc.add_child(list_box)
	var ap := PanelContainer.new()
	ap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ap.add_theme_stylebox_override("panel", UITheme.sb(Color(0.02, 0.045, 0.10, 0.92), UIKit.GOLD_DARK, 1, 6, 14))
	split.add_child(ap)
	var av := VBoxContainer.new()
	av.add_theme_constant_override("separation", 8)
	ap.add_child(av)
	illus = TextureRect.new()
	illus.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	illus.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	illus.custom_minimum_size = Vector2(0, 230)
	illus.clip_contents = true
	illus.visible = false
	illus.mouse_filter = Control.MOUSE_FILTER_IGNORE
	av.add_child(illus)
	article = UITheme.rich("", 17, false)
	article.scroll_active = true
	article.size_flags_vertical = Control.SIZE_EXPAND_FILL
	article.meta_clicked.connect(_on_meta)
	article.selection_enabled = false
	av.add_child(article)


# ------------------------------------------------------------------ public

func open(kind := "", id := "") -> void:
	if _index.is_empty():
		_build_index()
	visible = true
	if kind != "" and id != "":
		show_entry(kind, id)
	else:
		set_tab(tab)


func set_tab(t: String) -> void:
	tab = t
	if search and search.text != "":
		search.text = ""
	for k in _tab_btns:
		var b: Button = _tab_btns[k]
		if k == t:
			b.add_theme_stylebox_override("normal", UITheme.sb(Color(0.18, 0.34, 0.66), UIKit.GOLD_LIGHT, 2, 5, 8))
		else:
			b.remove_theme_stylebox_override("normal")
	_fill_list()
	var first := _visible_entries()
	if first.size() > 0 and (cur_kind == "" or TAB_OF.get(cur_kind, cur_kind) != t):
		show_entry(first[0]["kind"], first[0]["id"], false)


func show_entry(kind: String, id: String, push := true) -> void:
	if _index.is_empty():
		_build_index()
	var key := "%s:%s" % [kind, id]
	if not _by_key.has(key):
		article.text = UITheme.pal("[color=#a8b0c4]No Civilopedia entry for %s.[/color]" % UITheme.pretty(id))
		return
	if push and cur_kind != "" and "%s:%s" % [cur_kind, cur_id] != key:
		_history.append([cur_kind, cur_id])
	cur_kind = kind
	cur_id = id
	var t: String = TAB_OF.get(kind, kind)
	if t != tab and (search == null or search.text == ""):
		tab = t
		for k in _tab_btns:
			var b: Button = _tab_btns[k]
			if k == t:
				b.add_theme_stylebox_override("normal", UITheme.sb(Color(0.18, 0.34, 0.66), UIKit.GOLD_LIGHT, 2, 5, 8))
			else:
				b.remove_theme_stylebox_override("normal")
		_fill_list()
	article.text = UITheme.pal(article_text(kind, id))
	article.scroll_to_line(0)
	_show_illustration(kind, id)
	_mark_selected()


func _show_illustration(kind: String, id: String) -> void:
	var t: Texture2D = null
	var h := 230.0
	var d := SimDB.get_db()
	match kind:
		"event":
			t = UIArt.event_art(id, false)
		"war":
			var w: Dictionary = d.wars.get(id, {})
			t = UIArt.event_art(str(w.get("event", "")), false)
		"term":
			var terms: Array = d.gov.get("terms", [])
			var i := int(id)
			if i >= 0 and i < terms.size():
				t = UIArt.pm_portrait(str(terms[i].get("pm", "")))
				h = 300.0
	illus.texture = t
	illus.custom_minimum_size = Vector2(0, h)
	illus.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED if kind != "term" else TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	illus.visible = t != null


func go_back() -> void:
	if _history.is_empty():
		return
	var h: Array = _history.pop_back()
	show_entry(h[0], h[1], false)


func has_entry(kind: String, id: String) -> bool:
	if _index.is_empty():
		_build_index()
	return _by_key.has("%s:%s" % [kind, id])


func entries(kind := "") -> Array:
	if _index.is_empty():
		_build_index()
	return _index.filter(func(e): return kind == "" or e["kind"] == kind or TAB_OF.get(e["kind"], e["kind"]) == kind)


static func link(kind: String, id: String, name: String) -> String:
	## BBCode link other panels can embed (their RichTextLabel must forward meta_clicked to GameUI.on_pedia_meta).
	return "[url=pedia:%s:%s][color=#f7dc8f]%s[/color][/url]" % [kind, id, name]


# ------------------------------------------------------------------ index

func banned(text: String) -> bool:
	return _ban.search(text) != null


func _build_index() -> void:
	_index.clear()
	_by_key.clear()
	var d := SimDB.get_db()
	for t in d.tech_list:
		_add("tech", t["id"], t["name"], "Era %d, %s" % [int(t.get("era", 0)), _year(t)], str(t.get("description", "")))
	for c in d.civic_list:
		_add("civic", c["id"], c["name"], "Era %d, %s" % [int(c.get("era", 0)), _year(c)], str(c.get("description", "")))
	for id in d.buildings:
		var b: Dictionary = d.buildings[id]
		_add("building", id, b.get("name", id), "Building" + ((" (%s)" % _dname(str(b["district"]))) if b.has("district") else ""), str(b.get("desc", "")))
	for id in d.projects:
		_add("project", id, d.projects[id].get("name", id), "National project", str(d.projects[id].get("desc", "")))
	for id in d.city_projects:
		_add("city_project", id, d.city_projects[id].get("name", id), "City project", str(d.city_projects[id].get("desc", "")))
	for id in d.improvements:
		_add("improvement", id, d.improvements[id].get("name", id), "Tile improvement", "")
	for id in d.districts:
		_add("district", id, d.districts[id].get("name", id), "District", str(d.districts[id].get("desc", "")))
	for id in d.units:
		var u: Dictionary = d.units[id]
		if str(u.get("cls", "")) == "" or str(id).begins_with("hostile_") or id == "missile_salvo":
			_add("unit", id, u.get("name", id), "Opposing force", str(u.get("desc", "")))
		else:
			_add("unit", id, u.get("name", id), UITheme.pretty(str(u.get("cls", ""))), str(u.get("desc", "")))
	for c in d.cities:
		_add("city", str(c["id"]), str(c.get("name", c["id"])), UITheme.pretty(str(c.get("kind", "locality"))), str(c.get("founded_note", "")) + " " + str(c.get("name_he", "")))
	for ev in d.events:
		var eid := str(ev.get("id", ""))
		if d.deleted_ids.has(eid) or not d.event_shown(ev):
			continue   # nothing dated after the configured end of the game (Q3 2023) is listed
		_add("event", eid, str(ev.get("title", eid)), str(ev.get("date", "")), str(ev.get("summary", "")))
	for wid in d.wars:
		var w: Dictionary = d.wars[wid]
		if not d.war_shown(w):
			continue   # wars after the end of the game stay in the data, unlisted
		var wev = d.event_by_id.get(str(w.get("event", "")), {})
		_add("war", wid, str(w.get("title", wid)), str(wev.get("date", "")) if wev != null else "", " ".join((w.get("fronts", []) as Array).map(func(f): return str(f.get("name", "")))))
	for gid in d.gov.get("types", {}):
		var g: Dictionary = d.gov["types"][gid]
		_add("government", gid, str(g.get("name", gid)), "Coalition type", str(g.get("desc", "")))
	var i := 0
	for tm in d.gov.get("terms", []):
		_add("term", str(i), "%s (%s)" % [str(tm.get("pm", "")), str(tm.get("start", "")).substr(0, 4)], "Government from " + str(tm.get("start", "")), str(tm.get("type", "")))
		i += 1
	for pid in d.policies:
		var p: Dictionary = d.policies[pid]
		_add("policy", pid, str(p.get("name", pid)), UITheme.pretty(str(p.get("slot", ""))) + " policy", str(p.get("description", "")))
	_index.sort_custom(func(a, b): return _sort_key(a) < _sort_key(b))


func _sort_key(e: Dictionary) -> String:
	match str(e["kind"]):
		"event", "term", "war":
			return "%s|%s" % [e["kind"], e["sub"]]
		"tech", "civic":
			return "%s|%s|%s" % [e["kind"], e["sub"], e["name"]]
	return "%s|%s" % [e["kind"], str(e["name"]).to_lower()]


func _add(kind: String, id: String, name: String, sub: String, text: String) -> void:
	if banned(name) or banned(text):
		return
	var e := {"kind": kind, "id": id, "name": name, "sub": sub, "text": (name + " " + id + " " + sub + " " + text).to_lower()}
	_index.append(e)
	_by_key["%s:%s" % [kind, id]] = e


static func _year(t: Dictionary) -> String:
	return ("history %d" % int(t["year"])) if t.get("year") != null else "no fixed date"


func _visible_entries() -> Array:
	var q := search.text.strip_edges().to_lower() if search else ""
	if q != "":
		var words := q.split(" ", false)
		return _index.filter(func(e):
			for w in words:
				if not str(e["text"]).contains(w):
					return false
			return true)
	return _index.filter(func(e): return TAB_OF.get(e["kind"], e["kind"]) == tab)


func _fill_list() -> void:
	if list_box == null:
		return
	for c in list_box.get_children():
		list_box.remove_child(c)
		c.queue_free()
	var es := _visible_entries()
	var searching := search.text.strip_edges() != ""
	count_label.text = "%d %s" % [es.size(), "results" if searching else "entries"]
	var last_sub := ""
	var shown := 0
	for e in es:
		if shown >= 400:
			list_box.add_child(UITheme.label("... refine the search to see more", 14, UIKit.TEXT_DIM))
			break
		var grp := ""
		if searching:
			grp = KIND_NAME.get(e["kind"], "")
		elif e["kind"] in ["tech", "civic"]:
			grp = "Era %s" % str(e["sub"]).get_slice(",", 0).trim_prefix("Era ")
		elif e["kind"] in ["project", "city_project", "improvement"]:
			grp = KIND_NAME[e["kind"]] + "s"
		elif e["kind"] == "building":
			grp = "Buildings"
		elif e["kind"] == "event":
			grp = str(e["sub"]).substr(0, 3) + "0s"
		elif e["kind"] == "term":
			grp = "Governments by date"
		elif e["kind"] == "government":
			grp = "Coalition types"
		if grp != last_sub and grp != "":
			var gl := UITheme.label(grp.to_upper(), 13, UIKit.GOLD, "title")
			list_box.add_child(gl)
			last_sub = grp
		var b := Button.new()
		b.text = str(e["name"])
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.clip_text = true
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_font_size_override("font_size", 16)
		b.add_theme_font_override("font", UIKit.font("body"))
		b.tooltip_text = "%s  %s" % [KIND_NAME.get(e["kind"], ""), str(e["sub"])]
		b.set_meta("key", "%s:%s" % [e["kind"], e["id"]])
		var k: String = e["kind"]; var id: String = e["id"]
		b.pressed.connect(func(): show_entry(k, id))
		list_box.add_child(b)
		shown += 1
	_mark_selected()


func _mark_selected() -> void:
	if list_box == null:
		return
	var key := "%s:%s" % [cur_kind, cur_id]
	for b in list_box.get_children():
		if b is Button:
			if str(b.get_meta("key", "")) == key:
				b.add_theme_stylebox_override("normal", UITheme.sb(Color(0.16, 0.30, 0.58), UIKit.GOLD_LIGHT, 1, 5, 8))
			else:
				b.remove_theme_stylebox_override("normal")


func _on_meta(meta) -> void:
	var s := str(meta)
	if s.begins_with("pedia:"):
		var p := s.substr(6).split(":")
		if p.size() >= 2:
			show_entry(p[0], p[1])
	elif s.begins_with("http"):
		OS.shell_open(s)


# ------------------------------------------------------------------ articles

func _l(kind: String, id: String) -> String:
	var e = _by_key.get("%s:%s" % [kind, id])
	var nm: String = str(e["name"]) if e != null else UITheme.pretty(id)
	return link(kind, id, nm) if e != null else nm


func _dname(id: String) -> String:
	return str(SimDB.get_db().districts.get(id, {}).get("name", UITheme.pretty(id)))


func _h(t: String) -> String:
	return "\n[b][color=#e6c76e]%s[/color][/b]\n" % t


func _yields(y: Dictionary) -> String:
	var parts := []
	for k in y:
		var v := float(y[k])
		parts.append("[color=%s]%s %s[/color]" % ["#9fe07a" if v >= 0 else "#ff8f7a", UITheme.fmt_signed(v, 0 if v == roundf(v) else 1), str(k).capitalize()])
	return ", ".join(parts)


func _unlock_from(u) -> String:
	if typeof(u) != TYPE_DICTIONARY or (u as Dictionary).is_empty():
		return "Available from the start"
	var parts := []
	if u.has("tech"): parts.append("Technology: " + _l("tech", str(u["tech"])))
	if u.has("civic"): parts.append("Civic: " + _l("civic", str(u["civic"])))
	if u.has("year"): parts.append("from %d" % int(u["year"]))
	for k in u:
		if not k in ["tech", "civic", "year"]:
			parts.append("%s: %s" % [UITheme.pretty(str(k)), UITheme.humanise(str(u[k]))])
	return ", ".join(parts)


func _unlock_list(u: Dictionary) -> String:
	var map := {"districts": "district", "buildings": "building", "units": "unit", "policies": "policy", "improvements": "improvement", "projects": "project", "city_projects": "city_project"}
	var lines := []
	for k in u:
		var arr = u[k]
		if typeof(arr) != TYPE_ARRAY:
			continue
		var names := []
		for x in arr:
			names.append(_l(map.get(k, str(k)), str(x)))
		if names.size() > 0:
			lines.append("%s: %s" % [UITheme.pretty(str(k)), ", ".join(names)])
	return "\n".join(lines)


func _sources(src) -> String:
	var ids := []
	if typeof(src) == TYPE_ARRAY:
		for s in src:
			if typeof(s) == TYPE_DICTIONARY:
				if str(s.get("source", "")) != "": ids.append(str(s["source"]))
			else:
				ids.append(str(s))
	elif src != null and str(src) != "":
		ids.append(str(src))
	var uniq := []
	for s in ids:
		if not s in uniq:
			uniq.append(s)
	if uniq.is_empty():
		return _h("Sources") + "[color=#a8b0c4]Gameplay rule: no historical source needed.[/color]\n"
	var meta: Dictionary = SimDB.get_db().source_meta
	var out := _h("Sources (%s)" % ", ".join(uniq))
	for s in uniq:
		var m: Dictionary = meta.get(s, {})
		var cit := L10n.mark_verbatim(L10n.ltr(str(m.get("citation", ""))))   # citations stay as published, isolated left to right in Hebrew
		var url := str(m.get("url", ""))
		var line := "[color=#f3d98f]%s[/color]" % s
		if cit != "":
			line += "  " + cit
		if url != "":
			line += "  [url=%s][color=#8fb8ff]link[/color][/url]" % url
		out += line + "\n"
	return out


func article_text(kind: String, id: String) -> String:
	var d := SimDB.get_db()
	var e: Dictionary = _by_key.get("%s:%s" % [kind, id], {})
	var sub := str(e.get("sub", ""))
	if RegEx.create_from_string("^\\d{4}-\\d{2}(-\\d{2})?$").search(sub) != null:
		sub = DecisionPopup._date_text(sub)   # "1967-06-05" -> "5 June 1967" (her minor 4: the war header showed the ISO date)
	var s := "[font_size=26][b][color=#f7dc8f]%s[/color][/b][/font_size]\n[color=#a8b0c4]%s  ·  %s[/color]\n" % [str(e.get("name", id)), KIND_NAME.get(kind, kind), sub]
	match kind:
		"tech", "civic":
			var t: Dictionary = (d.techs if kind == "tech" else d.civics).get(id, {})
			if str(t.get("description", "")) != "":
				s += "\n" + str(t["description"]) + "\n"
			s += _h("Cost and timing")
			s += "Base cost %s. %s.\n" % [UITheme.fmt_num(float(t.get("cost", 0))), ("Historically %s" % str(t.get("date", t.get("year", "")))) if t.get("year") != null else "No fixed historical date"]
			if t.get("rail", false):
				s += "Arrives with history (on its real date), not by research.\n"
			var pre: Array = t.get("prereqs", [])
			s += "Requires: %s\n" % (", ".join(pre.map(func(p): return _l(kind, str(p)))) if pre.size() > 0 else "nothing")
			var boost: Dictionary = t.get("eureka" if kind == "tech" else "inspiration", {})
			if str(boost.get("text", "")) != "":
				s += "%s: %s\n" % ["Eureka" if kind == "tech" else "Inspiration", str(boost["text"])]
			var un := _unlock_list(t.get("unlocks", {}))
			if un != "":
				s += _h("Unlocks") + un + "\n"
			var leads := []
			for o in (d.tech_list if kind == "tech" else d.civic_list):
				if id in o.get("prereqs", []):
					leads.append(_l(kind, str(o["id"])))
			if leads.size() > 0:
				s += _h("Leads to") + ", ".join(leads) + "\n"
			s += _sources(t.get("source", []))
		"building", "project", "city_project", "improvement":
			var tbl: Dictionary = {"building": d.buildings, "project": d.projects, "city_project": d.city_projects, "improvement": d.improvements}[kind]
			var b: Dictionary = tbl.get(id, {})
			if str(b.get("desc", b.get("description", ""))) != "":
				s += "\n" + UITheme.humanise(str(b.get("desc", b.get("description", "")))) + "\n"
			s += _h("Effects")
			var parts := []
			if (b.get("yields", {}) as Dictionary).size() > 0: parts.append(_yields(b["yields"]))
			if float(b.get("housing", 0)) != 0: parts.append("%s Housing" % UITheme.fmt_signed(float(b["housing"]), 1).replace(".0", ""))
			if float(b.get("amenities", 0)) != 0: parts.append("%s Amenities" % UITheme.fmt_signed(float(b["amenities"]), 1).replace(".0", ""))
			for ef in b.get("effects", []):
				if typeof(ef) == TYPE_DICTIONARY:
					parts.append(UITheme.color_effects("%s %s" % [UITheme.fmt_signed(float(ef.get("amount", 0))), UITheme.pretty(str(ef.get("type", "")))]))
			if b.has("terrain"): parts.append("on " + ", ".join((b["terrain"] as Array).map(func(x): return UITheme.pretty(str(x)))))
			if int(b.get("water_demand", 0)) > 0: parts.append("[color=#ff8f7a]water demand %d[/color]" % int(b["water_demand"]))
			s += (", ".join(parts) if parts.size() > 0 else "none listed") + "\n"
			s += _h("Requirements")
			if b.has("cost"): s += "Cost %s production%s.\n" % [UITheme.fmt_num(float(b["cost"])), (", upkeep %d Gold" % int(b["upkeep"])) if int(b.get("upkeep", 0)) > 0 else ""]
			if b.has("district"): s += "District: %s\n" % _l("district", str(b["district"]))
			s += "Unlocked by: %s\n" % _unlock_from(b.get("unlock", {}))
			if b.has("year"): s += "Historically %d.\n" % int(b["year"])
			s += _sources(b.get("source", []))
		"district":
			var dd: Dictionary = d.districts.get(id, {})
			if str(dd.get("desc", dd.get("description", ""))) != "":
				s += "\n" + UITheme.humanise(str(dd.get("desc", dd.get("description", "")))) + "\n"
			s += _h("Adjacency bonus")
			if str(dd.get("yield_type", "")) != "":
				s += "Yields %s:\n" % str(dd["yield_type"]).capitalize()
			var adj: Array = dd.get("adjacency", [])
			for a in adj:
				s += "  • %s\n" % CityScreen._adj_text(a)
			if adj.is_empty():
				s += "none\n"
			if typeof(dd.get("specialist")) == TYPE_DICTIONARY:
				s += "Specialists: %s each\n" % _yields(dd["specialist"])
			if float(dd.get("housing", 0)) > 0: s += "+%s Housing\n" % str(dd["housing"])
			if int(dd.get("appeal", 0)) != 0: s += "Appeal of neighbouring tiles %s\n" % UITheme.fmt_signed(float(dd["appeal"]))
			var bl: Array = dd.get("buildings", [])
			if bl.size() > 0:
				s += _h("Buildings") + ", ".join(bl.map(func(x): return _l("building", str(x)))) + "\n"
			s += _h("Requirements") + "Base cost %s. Unlocked by: %s\n" % [UITheme.fmt_num(float(dd.get("base_cost", 0))), _unlock_from(dd.get("unlock", {}))]
			s += _sources(dd.get("source", []))
		"unit":
			var u: Dictionary = d.units.get(id, {})
			if str(u.get("desc", "")) != "":
				s += "\n" + UITheme.humanise(str(u["desc"])) + "\n"
			s += _h("Stats")
			s += "Class %s.  Combat strength %d.%s  Movement %d.\n" % [UITheme.pretty(str(u.get("cls", ""))), int(u.get("cs", 0)), ("  Ranged strength %d, range %d." % [int(u["rs"]), int(u.get("range", 0))]) if int(u.get("rs", 0)) > 0 else "", int(u.get("mp", 0))]
			if u.has("cost"): s += "Cost %s production%s.\n" % [UITheme.fmt_num(float(u["cost"])), (", upkeep %d Gold" % int(u["upkeep"])) if int(u.get("upkeep", 0)) > 0 else ""]
			s += "Unlocked by: %s\n" % _unlock_from(u.get("unlock", {}))
			if str(u.get("obsolete_by", "")) != "": s += "Replaced by: %s\n" % _l("unit", str(u["obsolete_by"]))
			s += _sources(u.get("source", []))
		"city":
			var c: Dictionary = d.city_by_id.get(id, {})
			var sub2 := []
			if str(c.get("name_he", "")) != "": sub2.append(str(c["name_he"]))
			sub2.append("founded %s" % str(c.get("founded", "?")))
			if c.get("cbs_code") != null: sub2.append("CBS code %s" % str(c["cbs_code"]))
			s += "%s\n" % "  ·  ".join(sub2)
			if str(c.get("founded_note", "")) != "": s += "\n" + str(c["founded_note"]) + "\n"
			var pop: Dictionary = c.get("population", {}) if typeof(c.get("population")) == TYPE_DICTIONARY else {}
			if pop.size() > 0:
				s += _h("Population (census)")
				var ks := pop.keys(); ks.sort()
				s += "   ".join(ks.map(func(y): return "%s: [b]%s[/b]" % [y, UITheme.fmt_num(float(pop[y]))])) + "\n"
			var stl: Array = c.get("status", [])
			if stl.size() > 0:
				s += _h("Status over time")
				for st in stl:
					s += "[color=#f3d98f]%s - %s[/color]  %s%s\n" % [str(st.get("from", "")), str(st.get("to", "now")) if st.get("to") != null else "now", UITheme.pretty(str(st.get("status", ""))),
						(": " + str(st["note"])) if str(st.get("note", "")) != "" else ""]
			var srcs: Array = []
			for k2 in ["source", "founded_source", "population_source"]:
				var v = c.get(k2)
				if typeof(v) == TYPE_ARRAY: srcs.append_array(v)
				elif v != null and str(v) != "": srcs.append(str(v))
			for st in stl:
				srcs.append_array(st.get("source", []))
			s += _sources(srcs)
		"event":
			var ev = d.event_by_id.get(id, {})
			s += "%s%s\n" % [DecisionPopup._date_text(str(ev.get("date", ""))), ("   " + str(ev["title_he"])) if str(ev.get("title_he", "")) != "" else ""]
			s += "\n" + str(ev.get("summary", "")) + "\n"
			var aff: Array = ev.get("affected_populations", []) if typeof(ev.get("affected_populations")) == TYPE_ARRAY else []
			if aff.size() > 0:
				s += _h("Affected populations")
				for a in aff:
					if typeof(a) != TYPE_DICTIONARY: continue
					var nums := []
					for k3 in a:
						if k3 in ["group", "note"]: continue
						var v = a[k3]
						if typeof(v) == TYPE_ARRAY and v.size() == 2:
							nums.append("%s %s–%s" % [k3, UITheme.fmt_num(float(v[0])), UITheme.fmt_num(float(v[1]))])
						else:
							nums.append("%s: %s" % [k3, str(v)])
					s += "  • [b]%s[/b]: %s%s\n" % [UITheme.pretty(str(a.get("group", ""))), ", ".join(nums), ("  [color=#a8b0c4](%s)[/color]" % str(a["note"])) if str(a.get("note", "")) != "" else ""]
			var ch: Array = ev.get("choices", [])
			if ch.size() > 0:
				s += _h("Choices offered")
				for c2 in ch:
					s += "  • %s%s\n" % [str(c2.get("label", "")), "  [color=#a8b0c4](historical)[/color]" if c2.get("historical", false) else ""]
			var w = d.war_by_event.get(id)
			if w != null:
				s += "\nWar: %s\n" % _l("war", str(w["id"]))
			s += _sources(ev.get("source", []))
		"war":
			var w2: Dictionary = d.wars.get(id, {})
			if str(w2.get("event", "")) != "":
				s += "Begins with: %s\n" % _l("event", str(w2["event"]))
			s += "%s war, about %d quarter%s of fighting in game.\n" % ["An offensive" if w2.get("offensive", false) else "A defensive", int(w2.get("turns", 1)), "" if int(w2.get("turns", 1)) == 1 else "s"]
			s += _h("Fronts")
			for f in w2.get("fronts", []):
				s += "  • [b]%s[/b] (%s, %d formation%s)%s\n" % [str(f.get("name", "")), str(d.actors.get(str(f.get("actor", "")), {}).get("name", UITheme.pretty(str(f.get("actor", ""))))),
					int(f.get("formations", 0)), "" if int(f.get("formations", 0)) == 1 else "s", ("\n    Order: " + str(f["commit_label"])) if str(f.get("commit_label", "")) != "" else ""]
			var srcw: Array = (w2.get("source", []) as Array).duplicate()
			for f in w2.get("fronts", []):
				for c4 in f.get("cite", []):
					srcw.append(c4)
			s += _sources(srcw)
		"government":
			var g: Dictionary = d.gov.get("types", {}).get(id, {})
			s += "\n" + str(g.get("desc", "")) + "\n"
			s += _h("Policy slots")
			var names: Dictionary = d.gov.get("slot_names", {})
			var sl: Dictionary = g.get("slots", {})
			s += ", ".join(sl.keys().map(func(k): return "%d %s" % [int(sl[k]), str(names.get(k, k))])) + "\n"
			var terms := []
			var i := 0
			for tm in d.gov.get("terms", []):
				if str(tm.get("type", "")) == id:
					terms.append(_l("term", str(i)))
				i += 1
			if terms.size() > 0:
				s += _h("Governments of this type") + ", ".join(terms) + "\n"
			s += _sources(g.get("source", []))
		"term":
			var tm2: Dictionary = d.gov.get("terms", [])[int(id)]
			s += "Prime Minister [b]%s[/b], from %s.\n" % [str(tm2.get("pm", "")), DecisionPopup._date_text(str(tm2.get("start", "")))]
			s += "Coalition type: %s\n" % _l("government", str(tm2.get("type", "")))
			s += _sources(tm2.get("source", []))
		"policy":
			var p: Dictionary = d.policies.get(id, {})
			s += "\n" + UITheme.humanise(str(p.get("description", ""))) + "\n"
			s += _h("Slot") + "%s\n" % str(d.gov.get("slot_names", {}).get(str(p.get("slot", "")), UITheme.pretty(str(p.get("slot", "")))))
			s += "Unlocked by: %s\n" % _unlock_from(p.get("unlock", {}))
			s += _sources(p.get("source", []))
	return clean(_readable(s))


func _readable(s: String) -> String:
	## Data notes sometimes carry raw ids ("merged into tel_aviv"): name them, outside BBCode tags, the header line
	## (which shows the id on purpose) and the verbatim source citations.
	var head_end := s.find("\n", s.find("\n") + 1)
	var src_at := s.find("[b][color=#e6c76e]Sources")
	if head_end < 0:
		return s
	if src_at < 0:
		src_at = s.length()
	var mid := s.substr(head_end, src_at - head_end)
	if _tag_re == null:
		_tag_re = RegEx.new()
		_tag_re.compile("\\[[^\\]]*\\]")
	var out := ""
	var pos := 0
	for m in _tag_re.search_all(mid):
		out += UITheme.humanise(mid.substr(pos, m.get_start() - pos)) + m.get_string()
		pos = m.get_end()
	out += UITheme.humanise(mid.substr(pos))
	return s.substr(0, head_end) + out + s.substr(src_at)


func clean(t: String) -> String:
	## Kept entries (e.g. the West Bank toll) date ranges from "7 Oct 2023": shown as "October 2023".
	return _date7.sub(t, "October 2023", true)
