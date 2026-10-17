class_name DiplomacyScreen
extends UIWindow
## Civ VI-style diplomacy screen (V3 item 4): a ribbon of partners on the left (portrait, relation, status), the
## selected partner's intel report in the middle (status and since when, the relation with every cause itemised,
## the leader's agenda, dependence and leverage risks, recent dealings) with its deals at the bottom ("Make Deal"),
## and the leader's portrait on the right. A deal opens a deal screen (what Israel gives, what it gets, the lasting
## terms, the risks) with "Make the deal" / "Back". The recurring envoy decision (type "diplomacy") opens here too:
## "<Leader> says", then the options with their effects, relation changes and advocates.
## Data: V3Adapter.diplo_rows / actor / propose / diplo_decision (sim-diplomacy, with a fallback to get_diplomacy()).

const W_LEFT := 270.0
const W_MID := 590.0
const W_RIGHT := 400.0
const H_BODY := 700.0

var selected := ""
var mode := "overview"    # overview | deal | envoy | result
var deal := {}
var decision := {}
var _result_title := ""
var _result_text := ""
var _rows: Array = []
var _actor := {}
var _mid: VBoxContainer
var _list: VBoxContainer
var _portrait: TextureRect
var _plate: Label
var _plate2: Label
var _initials: Label


func _init() -> void:
	super._init("Diplomacy")


func open(actor := "", d := {}) -> void:
	decision = d if not d.is_empty() else V3Adapter.diplo_decision(ui.sim)
	if not d.is_empty():
		mode = "envoy"
		selected = str(d.get("actor", actor))
	else:
		mode = "overview"
		if actor != "":
			selected = actor
	refresh()
	visible = true


func open_envoy() -> void:
	var d := V3Adapter.diplo_decision(ui.sim)
	if d.is_empty():
		open()
	else:
		open(str(d.get("actor", "")), d)


func refresh() -> void:
	if ui == null or ui.sim == null:
		return
	clear_body()
	_rows = V3Adapter.diplo_rows(ui.sim)
	if decision.is_empty() or mode != "envoy":
		decision = V3Adapter.diplo_decision(ui.sim)
	if selected == "" or not _rows.any(func(r): return str(r.get("id", "")) == selected):
		selected = str(decision.get("actor", "")) if not decision.is_empty() else (str(_rows[0].get("id", "")) if _rows.size() > 0 else "")
	_actor = V3Adapter.actor(ui.sim, selected) if selected != "" else {}
	var n: Dictionary = ui.sim.get_national_summary()
	title_label.text = "DIPLOMACY: %s" % ui.sim.date_label().to_upper()
	var head := UITheme.rich("[color=#a8b0c4]Standing[/color] [b]%d[/b]    [color=#a8b0c4]Readiness[/color] [b]%d[/b]    [color=#a8b0c4]Treasury[/color] [b]%s[/b] Gold    [color=#a8b0c4]Export routes[/color] [b]%d / %d[/b]%s" % [
		int(n.get("standing", 0)), int(n.get("readiness", 0)), UITheme.fmt_num(float(n.get("gold_treasury", 0))), ui.sim.state.trade_routes.size(), ui.sim.trade_capacity(),
		"" if V3Adapter.relations_live(ui.sim) else "    [color=#a8b0c4](relations follow the dated statuses)[/color]"], 16)
	body.add_child(head)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	body.add_child(h)
	h.add_child(_left())
	h.add_child(_vsep())
	var mid_sc := ScrollContainer.new()
	mid_sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	mid_sc.custom_minimum_size = Vector2(W_MID, H_BODY)
	h.add_child(mid_sc)
	_mid = VBoxContainer.new()
	_mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_mid.add_theme_constant_override("separation", 6)
	mid_sc.add_child(_mid)
	match mode:
		"deal": _deal_view()
		"envoy": _envoy_view()
		"result": _result_view()
		_: _overview()
	h.add_child(_right())


func _vsep() -> VSeparator:
	var s := VSeparator.new()
	var st := StyleBoxLine.new()
	st.color = Color(UIKit.GOLD_DARK, 0.9)
	st.vertical = true
	s.add_theme_stylebox_override("separator", st)
	return s


# ------------------------------------------------------------------ left: the partners

func _left() -> Control:
	var v := VBoxContainer.new()
	v.custom_minimum_size = Vector2(W_LEFT, H_BODY)
	v.add_theme_constant_override("separation", 4)
	v.add_child(UITheme.title("PARTNERS (%d)" % _rows.size(), 16, UIKit.GOLD))
	var sc := ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(sc)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 4)
	sc.add_child(_list)
	var year: int = ui.sim.year()
	for r in _rows:
		var id := str(r.get("id", ""))
		var row := UIRow.new(true, id == selected)
		var hr := row.hrow()
		hr.add_child(_avatar(id, str(r.get("name", "")), str(r.get("portrait", "")), year, 46))
		var tv := VBoxContainer.new()
		tv.add_theme_constant_override("separation", 0)
		tv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var nm := UITheme.label(str(r.get("name", "")), 17, UIKit.GOLD_LIGHT, "body_bold")
		nm.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		nm.clip_text = true
		nm.custom_minimum_size = Vector2(150, 0)
		tv.add_child(nm)
		var rel := float(r.get("relation", 0))
		tv.add_child(UITheme.label("%s %s" % [str(r.get("relation_label", "")), UITheme.fmt_signed(rel)], 16, _rel_col(rel)))
		var st := UITheme.label(str(r.get("status_label", "")), 16, UIKit.TEXT_DIM)
		st.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		st.clip_text = true
		st.custom_minimum_size = Vector2(150, 0)
		tv.add_child(st)
		hr.add_child(tv)
		var badge := ""
		if not decision.is_empty() and str(decision.get("actor", "")) == id:
			badge = "!"
		elif int(r.get("deals_ready", 0)) > 0:
			badge = str(int(r["deals_ready"]))
		if badge != "":
			var b := UITheme.label(badge, 16, Color.WHITE, "body_bold")
			b.add_theme_stylebox_override("normal", UITheme.sb(Color(0.70, 0.45, 0.10) if badge == "!" else Color(0.14, 0.32, 0.62), UIKit.GOLD_LIGHT, 1, 9, 4))
			b.tooltip_text = "An envoy awaits your answer." if badge == "!" else "%s deal%s you can make now." % [badge, "" if badge == "1" else "s"]
			hr.add_child(b)
		row.tooltip_text = "%s: %s, relation %s (%s)" % [str(r.get("name", "")), str(r.get("status_label", "")), UITheme.fmt_signed(rel), str(r.get("relation_label", ""))]
		row.pressed.connect(func(_s): select(id))
		_list.add_child(row)
	if _rows.is_empty():
		_list.add_child(UITheme.label("No foreign partners yet.", 16, UIKit.TEXT_DIM))
	return v


func select(id: String) -> void:
	selected = id
	if mode != "envoy" or str(decision.get("actor", "")) != id:
		mode = "overview"
	deal = {}
	UIAudio.click()
	refresh()


func _avatar(id: String, name: String, portrait_id: String, year: int, sz: int) -> Control:
	var t := _portrait_tex(id, portrait_id, year, "")
	var p := PanelContainer.new()
	p.custom_minimum_size = Vector2(sz, sz)
	p.add_theme_stylebox_override("panel", UITheme.sb(Color(0.05, 0.09, 0.18), UIKit.GOLD, 1, int(sz * 0.5), 0))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if t != null:
		var tr := TextureRect.new()
		tr.texture = t
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		tr.custom_minimum_size = Vector2(sz - 4, sz - 4)
		tr.clip_contents = true
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		p.add_child(tr)
	else:   # no leader portrait for this year: the partner's flag of that date (never cut initials)
		p.add_child(UIFlags.make(id, year, name, Vector2(sz - 4, sz - 4), true))
	return p


static func _initials_of(name: String) -> String:
	return UIFlags.initials(name)


func _portrait_tex(id: String, portrait_id: String, year: int, leader_name: String) -> Texture2D:
	var lead := UIArt.leader(id, year, leader_name)
	if lead.get("tex") != null:
		return lead["tex"]
	if portrait_id != "":
		var t := UIArt.portrait(portrait_id)
		if t != null:
			return t
	return null


static func _rel_col(v: float) -> Color:
	if v >= 20.0:
		return UIKit.GREEN
	if v <= -20.0:
		return UIKit.BAD
	return UIKit.TEXT


# ------------------------------------------------------------------ right: the leader

func _right() -> Control:
	var p := PanelContainer.new()
	p.custom_minimum_size = Vector2(W_RIGHT, H_BODY)
	p.add_theme_stylebox_override("panel", UITheme.sb(Color(0.02, 0.03, 0.07, 0.98), UIKit.GOLD_DARK, 1, 6, 0))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	p.add_child(v)
	var year: int = ui.sim.year()
	var lname := str(_actor.get("leader_name", ""))
	var row := {}
	for r in _rows:
		if str(r.get("id", "")) == selected:
			row = r
	var t := UIArt.texture(str(_actor.get("leader_portrait", "")))
	if t == null and str(_actor.get("leader_id", "")) != "":
		t = UIArt.portrait(str(_actor["leader_id"]))
	if t == null:
		t = _portrait_tex(selected, str(row.get("portrait", _actor.get("portrait", ""))), year, lname)
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(W_RIGHT - 4, H_BODY - 92)
	holder.clip_contents = true
	v.add_child(holder)
	_portrait = TextureRect.new()
	_portrait.texture = t
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_portrait.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(_portrait)
	_initials = UITheme.label(_initials_of(str(_actor.get("name", ""))), 96, Color(UIKit.GOLD_LIGHT, 0.55), "title")
	_initials.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_initials.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_initials.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_initials.visible = false   # V3 fixes B6: the flag of the date stands in for a missing portrait
	holder.add_child(_initials)
	if t == null:
		var big: UIFlags = UIFlags.make(selected, year, str(_actor.get("name", "")), Vector2(300, 204), false)
		big.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		big.offset_left = -150; big.offset_right = 150; big.offset_top = -102; big.offset_bottom = 102
		holder.add_child(big)
	var plate := PanelContainer.new()
	plate.add_theme_stylebox_override("panel", UITheme.sb(Color(0.04, 0.07, 0.15, 0.98), UIKit.GOLD, 1, 0, 10))
	v.add_child(plate)
	var pv := VBoxContainer.new()
	pv.add_theme_constant_override("separation", 0)
	plate.add_child(pv)
	_plate = UITheme.title(lname.to_upper() if lname != "" else str(_actor.get("name", "")).to_upper(), 19, UIKit.GOLD_LIGHT)
	_plate.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_plate.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pv.add_child(_plate)
	var ltitle := str(_actor.get("leader_title", ""))
	_plate2 = UITheme.label((("%s, %s" % [ltitle, str(_actor.get("name", ""))]) if ltitle != "" else str(_actor.get("name", ""))) if lname != "" else str(_actor.get("status_label", "")), 17, UIKit.TEXT)
	_plate2.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_plate2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pv.add_child(_plate2)
	return p


# ------------------------------------------------------------------ middle: the intel report

func _section(t: String) -> void:
	_mid.add_child(UITheme.section(t))


func _kv(k: String, v: String) -> void:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	var kl := UITheme.label(k, 17, UIKit.GOLD, "body_bold")
	kl.custom_minimum_size = Vector2(150, 0)
	h.add_child(kl)
	var vl := UITheme.rich(v, 17)
	vl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(vl)
	_mid.add_child(h)


func _overview() -> void:
	if _actor.is_empty():
		_mid.add_child(UITheme.label("Choose a partner on the left.", 17, UIKit.TEXT_DIM))
		return
	if not decision.is_empty():
		var bar := PanelContainer.new()
		bar.add_theme_stylebox_override("panel", UITheme.sb(Color(0.45, 0.28, 0.06, 0.95), UIKit.GOLD_LIGHT, 2, 6, 10))
		var bh := HBoxContainer.new()
		bar.add_child(bh)
		var bl := UITheme.rich("[b]An envoy awaits your answer:[/b] %s" % UITheme.humanise(str(decision.get("title", decision.get("label", "")))), 16)
		bl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bh.add_child(bl)
		bh.add_child(UITheme.button("Answer", func(): open(str(decision.get("actor", "")), decision), 16))
		_mid.add_child(bar)
	var nm := str(_actor.get("name", ""))
	_mid.add_child(_wrap(UITheme.title(nm.to_upper(), 24, UIKit.GOLD_LIGHT)))
	var lname := str(_actor.get("leader_name", ""))
	var lt := str(_actor.get("leader_title", ""))
	var era: Dictionary = _actor.get("era", {}) if _actor.get("era") is Dictionary else {}
	var sub := ("%s: %s" % [lt, lname] if lt != "" else "Led by %s" % lname) if lname != "" else UITheme.pretty(str(_actor.get("kind", "")))
	if str(era.get("from", "")) != "" or str(era.get("until", "")) != "":
		sub += "   [color=#8a93a8](a partner %s)[/color]" % _era_text(era)
	_mid.add_child(UITheme.rich("[color=#c8ccd6]%s[/color]" % sub, 16))
	_section("INTEL REPORT")
	var since := str(_actor.get("since", ""))
	if since.length() >= 7 and since[4] == "-" and since.substr(0, 4).is_valid_int():
		since = DecisionPopup._date_text(since)   # a long date ("10 March 1949", Hebrew "10 במרץ 1949"), not ISO
	_kv("Status", "[b]%s[/b]%s" % [str(_actor.get("status_label", "")), ("  [color=#a8b0c4]since %s[/color]" % since) if since != "" else ""])
	var rel := float(_actor.get("relation", 0))
	var colh := UITheme.GOOD_HEX if rel >= 20 else (UITheme.BAD_HEX if rel <= -20 else "#dfe3ec")
	_kv("Our relationship", "[color=%s][b]%s %s[/b][/color]  [color=#a8b0c4](scale −100 to +100)[/color]" % [colh, str(_actor.get("relation_label", "")), UITheme.fmt_signed(rel)])
	_mid.add_child(_rel_bar(rel))
	var ag = _actor.get("agenda", {})
	if ag is Dictionary and str(ag.get("text", "")) != "":
		var src: Array = ag.get("source", [])
		_kv("Agenda", UITheme.humanise(str(ag["text"])) + (("  [color=#8a93a8][%s][/color]" % ", ".join(src)) if src.size() > 0 else ""))
	var ph = _actor.get("phase", {})
	if ph is Dictionary and str(ph.get("label", ph.get("text", ""))) != "":
		_kv("In history", UITheme.humanise(str(ph.get("label", ph.get("text", "")))))
	var ex = _actor.get("exposure", {})
	if ex is Dictionary and float(ex.get("value", 0)) > 0.05:
		var risks: Array = ex.get("risks", [])
		_kv("Dependence", "[color=#ffbf66]%s[/color]%s" % [_exposure_word(float(ex["value"])), (": " + "; ".join(risks.slice(0, 2).map(func(x): return UITheme.humanise(str(x.get("title", x)) if x is Dictionary else str(x))))) if risks.size() > 0 else ""])
	# causes
	var causes: Array = _actor.get("causes", [])
	_section("WHY THE RELATION IS %s" % UITheme.fmt_signed(rel))
	if causes.is_empty():
		_mid.add_child(UITheme.label("No itemised causes yet: the relation follows the legal status.", 16, UIKit.TEXT_DIM))
	for c in causes.slice(0, 9):
		var a := float(c.get("amount", 0.0))
		var line := ""
		if c.has("amount"):
			line = "[color=%s][b]%s[/b][/color]  " % [UITheme.GOOD_HEX if a > 0 else (UITheme.BAD_HEX if a < 0 else "#dfe3ec"), UITheme.fmt_signed(a, 0 if absf(a - roundf(a)) < 0.05 else 1)]
		line += UITheme.humanise(str(c.get("label", "")))
		var cs := str(c.get("since", ""))
		if cs != "":
			line += "  [color=#8a93a8](%s%s)[/color]" % [cs, ", fading" if bool(c.get("fading", false)) else ""]
		_mid.add_child(UITheme.rich(line, 16))
	if causes.size() > 9:
		_mid.add_child(UITheme.label("... and %d smaller causes." % (causes.size() - 9), 16, UIKit.TEXT_DIM))
	# v3 final (fix4-diplo's M-A): the deals' terms still running, with their end clipped to the game's last quarter
	var act: Array = _actor.get("active_terms", []) if _actor.get("active_terms") is Array else []
	if act.is_empty() and ui.sim.has_method("get_relations"):
		for r in ui.sim.get_relations():
			if str(r.get("id", "")) == selected and r.get("active_terms") is Array:
				act = r["active_terms"]
	if not act.is_empty():
		_section("TERMS IN FORCE (%d)" % act.size())
		for x in act.slice(0, 8):
			if x is Dictionary:
				_mid.add_child(UITheme.rich("[color=#f3d98f]•[/color] %s  [color=#a8b0c4](until %s)[/color]" % [UITheme.clean_terms(str(x.get("label", ""))), str(x.get("until", ""))], 16))
	# deals
	var deals: Array = _actor.get("deals", [])
	_section("MAKE A DEAL (%d)" % deals.filter(func(x): return bool(x.get("available", false)) and bool(x.get("acceptable", true))).size())
	for dl in deals:
		_mid.add_child(_deal_button(dl))
	# recent dealings
	var hist: Array = _actor.get("history", [])
	if hist.size() > 0:
		_section("RECENT DEALINGS")
		for e in hist.slice(maxi(0, hist.size() - 5)):
			var t := int(e.get("turn", 0))
			_mid.add_child(UITheme.rich("[color=#8a93a8]%s[/color]  %s" % [SimDB.date_label(t) if t > 0 else "", UITheme.humanise(str(e.get("text", e.get("label", ""))))], 16))


static func _wrap(l: Label) -> Label:
	## Long titles wrap inside the middle column instead of widening the window.
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(W_MID - 30.0, 0)
	return l


static func _era_text(era: Dictionary) -> String:
	var f := str(era.get("from", "")).substr(0, 4)
	var u := str(era.get("until", "")).substr(0, 4)
	if f != "" and u != "":
		return "%s–%s" % [f, u]
	if f != "":
		return "from %s" % f
	return "until %s" % u


static func _exposure_word(v: float) -> String:
	if v >= 6.0: return "Heavy dependence"
	if v >= 3.0: return "Some dependence"
	return "Slight dependence"


func _rel_bar(rel: float) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, 16)
	c.draw.connect(func():
		var r := Rect2(Vector2(160, 3), Vector2(maxf(40.0, c.size.x - 170), 10))
		c.draw_rect(r, Color(0.0, 0.02, 0.06, 0.85))
		var mid := r.position.x + r.size.x * 0.5
		c.draw_line(Vector2(mid, r.position.y - 2), Vector2(mid, r.end.y + 2), Color(1, 1, 1, 0.5), 1.0)
		var x := r.position.x + r.size.x * clampf((rel + 100.0) / 200.0, 0, 1)
		var col := _rel_col(rel)
		if x >= mid:
			c.draw_rect(Rect2(mid, r.position.y, x - mid, r.size.y), col)
		else:
			c.draw_rect(Rect2(x, r.position.y, mid - x, r.size.y), col)
		c.draw_rect(r, Color(UIKit.GOLD_DARK, 0.8), false, 1.0))
	return c


func _deal_button(dl: Dictionary) -> Control:
	var ok := bool(dl.get("available", false)) and bool(dl.get("acceptable", true))
	var r := UIRow.new(true)
	var hr := r.hrow()
	var tl := UITheme.label(UITheme.humanise(str(dl.get("title", ""))), 18, UIKit.GOLD_LIGHT if ok else UIKit.TEXT_DIM, "body_bold")
	tl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hr.add_child(tl)
	var kl := str(dl.get("kind_label", ""))
	if kl != "":
		hr.add_child(UITheme.label(kl, 16, Color(0.75, 0.72, 0.62)))
	var parts := []
	var give: Array = dl.get("give", [])
	var get_: Array = dl.get("get", [])
	if get_.size() > 0:
		parts.append("[color=#a8b0c4]you get[/color] " + ", ".join(get_.slice(0, 2)))
	if give.size() > 0:
		parts.append("[color=#a8b0c4]you give[/color] " + ", ".join(give.slice(0, 2)))
	if not ok and str(dl.get("reason", "")) != "":
		parts.append("[color=#ffbf66]%s[/color]" % _cap(UITheme.humanise(str(dl["reason"]))))
	if parts.size() > 0:
		r.add(UITheme.rich("   ".join(parts), 16))
	r.pressed.connect(func(_s): open_deal(dl))
	return r


static func _cap(s: String) -> String:
	return s.substr(0, 1).to_upper() + s.substr(1) if s != "" else s


func open_deal(dl: Dictionary) -> void:
	deal = dl
	mode = "deal"
	refresh()


# ------------------------------------------------------------------ the deal screen

func _deal_view() -> void:
	var nm := str(_actor.get("name", ""))
	_mid.add_child(_wrap(UITheme.title(UITheme.humanise(str(deal.get("title", ""))).to_upper(), 21, UIKit.GOLD_LIGHT)))
	var sub := "%s%s" % [str(deal.get("kind_label", "Deal")), ("   [color=#8a93a8]offered %s[/color]" % str(deal.get("years", ""))) if str(deal.get("years", "")) not in ["", "-"] else ""]
	_mid.add_child(UITheme.rich("[color=#c8ccd6]With %s: %s[/color]" % [nm, sub], 16))
	if str(deal.get("text", "")) != "":
		_mid.add_child(UITheme.rich(UITheme.humanise(str(deal["text"])), 17))
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 10)
	_mid.add_child(cols)
	cols.add_child(_offer_col("ISRAEL GIVES", deal.get("give", []), "Nothing beyond the agreement itself."))
	cols.add_child(_offer_col("ISRAEL GETS", deal.get("get", []), "No direct gain on the tracks."))
	var lasting: Array = deal.get("lasting", [])
	if lasting.size() > 0:
		_section("LASTING TERMS")
		for t in lasting:
			if not UITheme.is_zero_term(str(t)):
				_mid.add_child(UITheme.rich("[color=#f3d98f]•[/color] " + UITheme.clean_terms(str(t)), 16))
	var risks: Array = deal.get("risks", [])
	if risks.size() > 0:
		_section("RISKS")
		for rk in risks:
			_mid.add_child(UITheme.rich("[color=#ffbf66]•[/color] " + UITheme.humanise(str(rk)), 16))
	if not bool(deal.get("historical", true)) and str(deal.get("advocate", "")) != "":
		_mid.add_child(UITheme.rich("[color=#a8b0c4]Not taken in history; proposed by[/color] %s" % str(deal["advocate"]), 16))
	var src: Array = deal.get("source", [])
	if src.size() > 0:
		_mid.add_child(UITheme.rich("[color=#8a93a8]Sources: %s[/color]" % ", ".join(src), 16))
	var ok := bool(deal.get("available", false)) and bool(deal.get("acceptable", true))
	if not ok and str(deal.get("reason", "")) != "":
		_mid.add_child(UITheme.rich("[color=#ffbf66]%s[/color]" % _cap(UITheme.humanise(str(deal["reason"]))) + ".", 17))
	var co: Dictionary = deal.get("counter", {}) if deal.get("counter") is Dictionary else {}
	if not co.is_empty():   # v3 fix3-story (A6): a sourced counter-offer, where history had one
		_section("COUNTER-OFFER: " + UITheme.humanise(str(co.get("label", "Press for better terms"))).to_upper())
		if bool(co.get("historical", false)):   # fix4-diplo: the counter is what Israel did
			_mid.add_child(UITheme.rich("[color=#9fe07a][b]HISTORICAL[/b][/color]  [color=#a8b0c4]these are the terms Israel took[/color]", 15))
		if str(co.get("note", "")) != "":
			_mid.add_child(UITheme.rich("[color=#c8ccd6]%s[/color]" % UITheme.humanise(str(co["note"])), 16))
		var cl: Array = []
		for x in co.get("now", []):
			cl.append(UITheme.clean_terms(str(x)))
		for x in co.get("lasting", []):
			if not UITheme.is_zero_term(str(x)):
				cl.append(UITheme.clean_terms(str(x)))
		for x in cl:
			_mid.add_child(UITheme.rich("[color=#f3d98f]•[/color] " + x, 16))
		var rl := []
		for rr in co.get("relation", []):
			if rr is Dictionary:
				rl.append("%s %s" % [str(rr.get("name", "")), UITheme.fmt_signed(float(rr.get("amount", 0)), 0)])
		if rl.size() > 0:
			_mid.add_child(UITheme.rich("[color=#a8b0c4]Relations:[/color] " + ", ".join(rl), 16))
		var who := str(co.get("advocate", ""))
		if bool(co.get("historical", false)):
			_mid.add_child(UITheme.rich("[color=#a8b0c4]History's terms%s[/color]" % ((": " + who) if who != "" else ""), 16))
		elif who != "":
			_mid.add_child(UITheme.rich("[color=#a8b0c4]Not taken in history; proposed by[/color] %s" % who, 16))
		var cs := []
		for c in co.get("cite", []):
			if c is Dictionary and str(c.get("source", "")) != "":
				cs.append(str(c["source"]))
			elif c is String:
				cs.append(c)
		if cs.size() > 0:
			_mid.add_child(UITheme.rich("[color=#8a93a8]Sources: %s[/color]" % ", ".join(cs), 16))
	var bh := HBoxContainer.new()
	bh.add_theme_constant_override("separation", 10)
	bh.alignment = BoxContainer.ALIGNMENT_CENTER
	var mk := UITheme.button("Make the deal", func(): ui.propose_deal(selected, deal), 19)
	mk.disabled = not ok
	mk.add_theme_stylebox_override("normal", UITheme.sb(Color(0.08, 0.38, 0.30) if ok else Color(0.05, 0.07, 0.12, 0.85), UIKit.GOLD_LIGHT, 2, 6, 12))
	bh.add_child(mk)
	if not co.is_empty():
		var cb := UITheme.button("Counter-offer: " + UITheme.humanise(str(co.get("label", "Press for better terms"))), func(): ui.propose_deal(selected, deal, "counter"), 18)
		cb.disabled = not ok
		cb.tooltip_text = "Make the deal on these terms instead: more of the gain, less of the goodwill."
		bh.add_child(cb)
	bh.add_child(UITheme.button("Back", func(): mode = "overview"; refresh(), 18))
	_mid.add_child(bh)


func _offer_col(title: String, lines: Array, empty: String) -> Control:
	var p := PanelContainer.new()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p.add_theme_stylebox_override("panel", UITheme.sb(Color(0.05, 0.09, 0.18, 0.95), UIKit.GOLD_DARK, 1, 5, 10))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	p.add_child(v)
	var t := UITheme.title(title, 16, UIKit.GOLD)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(t)
	if lines.is_empty():
		v.add_child(UITheme.label(empty, 16, UIKit.TEXT_DIM))
	for l in lines:
		v.add_child(UITheme.rich(str(l), 16))
	return p


# ------------------------------------------------------------------ the envoy decision

func _envoy_view() -> void:
	if decision.is_empty():
		mode = "overview"
		_overview()
		return
	var who := str(_actor.get("leader_name", ""))
	if who == "":
		who = str(decision.get("actor_name", _actor.get("name", "")))
	var quote := PanelContainer.new()
	quote.add_theme_stylebox_override("panel", UITheme.sb(Color(0.03, 0.05, 0.11, 0.98), UIKit.GOLD_LIGHT, 2, 8, 14))
	var qv := VBoxContainer.new()
	qv.add_theme_constant_override("separation", 4)
	quote.add_child(qv)
	qv.add_child(UITheme.title("%s SAYS:" % who.to_upper(), 16, UIKit.GOLD))
	qv.add_child(_wrap(UITheme.label(UITheme.humanise(str(decision.get("title", ""))), 20, UIKit.GOLD_LIGHT, "body_bold")))
	var txt := UITheme.rich("[i]%s[/i]" % UITheme.humanise(str(decision.get("text", ""))), 17)
	qv.add_child(txt)
	var src: Array = decision.get("source", [])
	if src.size() > 0:
		qv.add_child(UITheme.rich("[color=#8a93a8]Sources: %s[/color]" % ", ".join(src), 16))
	_mid.add_child(quote)
	_mid.add_child(UITheme.title("YOUR ANSWER", 16, UIKit.GOLD))
	var hints := V3Adapter.hints(ui.sim)
	var i := 0
	for o in decision.get("options", []):
		var r := UIRow.new(bool(o.get("available", true)))
		var hr := r.hrow()
		var l := UITheme.label(UITheme.humanise(str(o.get("label", ""))), 18, UIKit.GOLD_LIGHT, "body_bold")
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hr.add_child(l)
		if hints and bool(o.get("default", false)):
			hr.add_child(UITheme.label("Recommended", 16, UIKit.GREEN, "body_bold"))
		var fx := []
		for e in o.get("effects", []):
			var s := V3Adapter._fx_one(e)
			if s != "":
				fx.append(s)
		if fx.is_empty():
			for t in o.get("now", []):
				fx.append(UITheme.color_effects(str(t)))
		for rr in o.get("relation", []):
			var a := float(rr.get("amount", 0))
			fx.append("[color=%s]%s relation with %s[/color]" % [UITheme.GOOD_HEX if a > 0 else UITheme.BAD_HEX, UITheme.fmt_signed(a), str(rr.get("name", ""))])
		for ex in o.get("exposure", []):
			fx.append("[color=#ffbf66]more dependence on %s[/color]" % str(ex.get("name", "")))
		if fx.size() > 0:
			r.add(UITheme.rich(", ".join(fx), 16))
		if str(o.get("advocate", "")) != "" and not bool(o.get("historical", false)):
			r.add(UITheme.rich("[color=#a8b0c4]Advocated by[/color] %s" % str(o["advocate"]), 16))
		var idx := i
		r.pressed.connect(func(_s): ui.choose_diplomacy(idx))
		_mid.add_child(r)
		i += 1
	_mid.add_child(UITheme.rich("[color=#a8b0c4]What Israel actually did is shown after you answer. You can close this screen and answer later this turn; the end-turn button brings you back.[/color]", 16))


func show_result(title: String, text: String) -> void:
	_result_title = title
	_result_text = text
	mode = "result"
	decision = {}
	refresh()
	visible = true


func _result_view() -> void:
	_mid.add_child(_wrap(UITheme.title(_result_title.to_upper(), 20, UIKit.GOLD_LIGHT)))
	_mid.add_child(UITheme.rich(_result_text, 17))
	var bh := HBoxContainer.new()
	bh.alignment = BoxContainer.ALIGNMENT_CENTER
	bh.add_theme_constant_override("separation", 10)
	bh.add_child(UITheme.button("Continue", func(): close(), 18))
	bh.add_child(UITheme.button("Back to %s" % str(_actor.get("name", "the partner")), func(): mode = "overview"; refresh(), 18))
	_mid.add_child(bh)
