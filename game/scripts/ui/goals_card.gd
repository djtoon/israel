class_name GoalsCard
extends PanelContainer
## v4 (V4_DESIGN 2.5): the era goals on the HUD. The current era's 2-3 goals, each with a progress bar for its
## progress condition ("Readiness 40 / 60"), its deadline, and on hover history's line and the reward. A met goal
## turns gold with a check mark and the reward; a missed one grey with the setback and "History: ...". Reads
## sim.goals.view() (v4-goals); until the sim has it, the goals of data/era_goals.json with what the UI can measure.

const GOALS_JSON := "res://data/era_goals.json"

var ui
var opened := true
var head_btn: Button
var hist_lbl: Label           # v4 fix round: story mode's VS. HISTORY, one line under the header (no chip on the map)
var list: VBoxContainer
var last_view: Dictionary = {}
static var _data_cache: Dictionary = {}


func _init() -> void:
	add_theme_stylebox_override("panel", UITheme.sb(Color(0.03, 0.07, 0.15, 0.93), UIKit.GOLD, 1, 6, 8))
	mouse_filter = Control.MOUSE_FILTER_STOP
	name = "GoalsCard"
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	add_child(v)
	head_btn = UITheme.button("", func(): opened = not opened; refresh(), 15)
	head_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	head_btn.name = "goals_toggle"
	v.add_child(head_btn)
	hist_lbl = UITheme.label("", 14, UIKit.TEXT)
	hist_lbl.name = "goals_vs_history"
	hist_lbl.mouse_filter = Control.MOUSE_FILTER_PASS   # (a tooltip; not a control)
	hist_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hist_lbl.visible = false
	v.add_child(hist_lbl)
	list = VBoxContainer.new()
	list.add_theme_constant_override("separation", 4)
	v.add_child(list)


func refresh() -> void:
	if ui == null or ui.sim == null:
		return
	var gv := view(ui.sim)
	last_view = gv
	var goals: Array = gv.get("goals", [])
	var met := goals.filter(func(g): return str(g.get("status", "")) == "met").size()
	head_btn.text = "%s  ERA GOALS  %s%s" % ["▾" if opened else "▸", str(gv.get("span", "")), ("  ·  %d of %d met" % [met, goals.size()]) if not goals.is_empty() else ""]
	head_btn.tooltip_text = "%s\n%s" % [L10n.t(str(gv.get("era_name", ""))), L10n.t(str(gv.get("era_note", "")))]
	_history_line()
	for c in list.get_children():
		list.remove_child(c)
		c.queue_free()
	list.visible = opened
	if not opened:
		return
	if goals.is_empty():
		var l := UITheme.label("This era's goals arrive with its briefing.", 14, UIKit.TEXT_DIM)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(380, 0)
		list.add_child(l)
		return
	for g in goals:
		list.add_child(_row(g))


func _history_line() -> void:
	## Story mode, once VS. HISTORY unlocks: "Against history: 3 up, 2 level, 1 down" (green when ahead, amber when
	## behind); the six tracks are in the Government menu.
	var on: bool = ui.is_story() and Unlocks.is_on(ui, "ghost")
	hist_lbl.visible = on
	if not on:
		return
	var g: Dictionary = ui.ghost_summary()
	hist_lbl.text = "Against history: %s" % str(g.get("text", ""))
	var na := int(g.get("ahead", 0))
	var nb := int(g.get("behind", 0))
	hist_lbl.add_theme_color_override("font_color", UIKit.GREEN if na > nb else (UIKit.WARN if nb > na else UIKit.TEXT))
	var tip := ["Your Israel against history's on the six tracks (population, economy, science, water, standing, cohesion).", "The Government menu opens the details."]
	var hf := float(g.get("health", 1.0))
	if hf < 0.995 and str(g.get("health_text", "")) != "":
		tip.append(str(g["health_text"]))
		if hf < 0.85:
			hist_lbl.text += "\n" + "State's health %d%%: hover for why." % int(round(hf * 100.0))
			hist_lbl.add_theme_color_override("font_color", UIKit.BAD)
	hist_lbl.tooltip_text = "\n".join(tip)


func _row(g: Dictionary) -> Control:
	var st := str(g.get("status", "active"))
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UITheme.sb(Color(0.20, 0.15, 0.04, 0.92) if st == "met" else (Color(0.10, 0.10, 0.12, 0.92) if st == "missed" else Color(0.06, 0.11, 0.21, 0.92)),
		UIKit.GOLD_LIGHT if st == "met" else Color(0.32, 0.34, 0.40), 1, 4, 6))
	p.mouse_filter = Control.MOUSE_FILTER_PASS
	var tip := []
	if str(g.get("text", "")) != "": tip.append(str(g["text"]))
	if str(g.get("history", "")) != "": tip.append("History: " + str(g["history"]))
	if str(g.get("reward_text", "")) != "": tip.append("Reward: " + str(g["reward_text"]))
	if str(g.get("setback_text", "")) != "": tip.append("If missed: " + str(g["setback_text"]))
	if bool(g.get("history_missed", false)): tip.append("History itself fell short of this goal.")
	p.tooltip_text = "\n".join(tip)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 2)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(v)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 6)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(h)
	var glyph: String = {"met": "✓", "missed": "✗"}.get(st, "○")
	var gl := UITheme.label(glyph, 17, UIKit.GOLD_LIGHT if st == "met" else (UIKit.TEXT_DIM if st == "missed" else UIKit.TEXT), "body_bold")
	gl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(gl)
	var tl := UITheme.label(str(g.get("title", "")), 16, UIKit.GOLD_LIGHT if st == "met" else (UIKit.TEXT_DIM if st == "missed" else UIKit.TEXT), "body_bold")
	tl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tl.custom_minimum_size = Vector2(220, 0)
	tl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(tl)
	var dl := UITheme.label(str(g.get("deadline_label", "")), 14, UIKit.GOLD)
	dl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(dl)
	if st == "active":
		var bh := HBoxContainer.new()
		bh.add_theme_constant_override("separation", 8)
		bh.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_child(bh)
		bh.add_child(_bar(clampf(float(g.get("progress", 0.0)), 0.0, 1.0)))
		var pl := UITheme.label(str(g.get("progress_label", "")), 14, UIKit.TEXT_DIM)
		pl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bh.add_child(pl)
	else:
		var line := str(g.get("reward_text", "")) if st == "met" else str(g.get("setback_text", ""))
		if line != "":
			var ll := UITheme.label(("Reward: " if st == "met" else "Setback: ") + line, 14, UIKit.GOLD if st == "met" else UIKit.TEXT_DIM)
			ll.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			ll.custom_minimum_size = Vector2(300, 0)
			ll.mouse_filter = Control.MOUSE_FILTER_IGNORE
			v.add_child(ll)
	return p


func _bar(f: float) -> Control:
	## A drawn progress bar (not a Range: it is not a control the player can use). Fills from the right in Hebrew.
	var back := ColorRect.new()
	back.color = Color(0.12, 0.16, 0.26)
	back.custom_minimum_size = Vector2(150, 8)
	back.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fill := ColorRect.new()
	fill.color = UIKit.GOLD_LIGHT
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if L10n.rtl:
		fill.anchor_left = 1.0 - f
		fill.anchor_right = 1.0
	else:
		fill.anchor_left = 0.0
		fill.anchor_right = f
	fill.anchor_top = 0.0
	fill.anchor_bottom = 1.0
	back.add_child(fill)
	back.set_meta("progress", f)
	return back


# ================================================================== the view

static func shown(sim) -> bool:
	## The card shows unless the era goals are switched off (ProjectSettings civ/era_goals = false: sim.goals.view()
	## then lists none in any era).
	var g = sim.get("goals") if sim != null else null
	if g is Object and (g as Object).has_method("enabled"):
		return bool(g.enabled())
	return true


static func view(sim, era := -1) -> Dictionary:
	## sim.goals.view() (v4-goals) or the fallback; always with "span" ("1948-1957") and "era_name".
	var out := {}
	var g = sim.get("goals") if sim != null else null
	if g is Object and (g as Object).has_method("view"):
		var v = g.view(era) if era >= 0 else g.view()
		if v is Dictionary:
			out = (v as Dictionary).duplicate()
	if out.is_empty():
		out = _fallback(sim)
	if not out.has("span"):
		out["span"] = _span(sim)
	if str(out.get("era_name", "")) == "" and sim != null:
		out["era_name"] = str(sim.get_date().get("era_name", ""))
	return out


static func _span(sim) -> String:
	if sim == null:
		return ""
	var eras: Array = sim.db.eras
	var cur: Dictionary = sim.db.era_at(sim.state.turn)
	var y0 := int(str(cur.get("start", "1948")).substr(0, 4))
	var y1 := 2023
	for i in eras.size():
		if str(eras[i].get("id", "")) == str(cur.get("id", "")) and i + 1 < eras.size():
			y1 = int(str(eras[i + 1].get("start", "2023")).substr(0, 4))
	return "%d–%d" % [y0, y1]


static func _goal_data() -> Dictionary:
	if _data_cache.is_empty() and FileAccess.file_exists(GOALS_JSON):
		var d = JSON.parse_string(FileAccess.get_file_as_string(GOALS_JSON))
		if d is Dictionary:
			_data_cache = d
	return _data_cache


static func _fallback(sim) -> Dictionary:
	if sim == null:
		return {"goals": []}
	var era: Dictionary = sim.db.era_at(sim.state.turn)
	var out := {"era": str(era.get("id", "")), "era_name": str(era.get("name", "")), "era_note": str(era.get("note", "")), "goals": []}
	var gd := _goal_data()
	for g in gd.get("goals", []):
		if str(g.get("era", "")) != str(era.get("id", "")):
			continue
		var dl_turn := _turn_of(str(g.get("at", g.get("by", ""))))
		var pr := _progress(sim, g)
		var status := "active"
		if str(g.get("check", "")) == "by" and float(pr[0]) >= 1.0:
			status = "met"
		elif dl_turn > 0 and sim.state.turn > dl_turn:
			status = "met" if float(pr[0]) >= 1.0 else "missed"
		out["goals"].append({"id": g.get("id", ""), "title": str(g.get("title", "")), "text": str(g.get("text", "")), "history": str(g.get("history", "")),
			"source": g.get("source", []), "status": status, "progress": pr[0], "progress_label": pr[1], "deadline": dl_turn,
			"deadline_label": (("at %s" if str(g.get("check", "")) == "at" else "by %s") % SimDB.date_label(dl_turn)) if dl_turn > 0 else "",
			"reward_text": str(g.get("reward", {}).get("text", "")), "setback_text": str(g.get("setback", {}).get("label", "")), "history_missed": bool(g.get("history_missed", false))})
	return out


static func _turn_of(ym: String) -> int:
	## "1949-07" -> its quarter's turn (Q2 1948 = turn 1).
	if ym.length() < 4:
		return -1
	var y := int(ym.substr(0, 4))
	var m := int(ym.substr(5, 2)) if ym.length() >= 7 else 1
	return (y - 1948) * 4 + int((m - 1) / 3)


static func _progress(sim, g: Dictionary) -> Array:
	## [ratio 0..1, label] for the goal's progress condition, for the metrics the UI can read.
	var conds: Array = g.get("all", g.get("any", []))
	var pid := str(g.get("progress", ""))
	var c := {}
	for x in conds:
		if str(x.get("metric", "")) == pid or c.is_empty():
			c = x
	if c.is_empty():
		return [0.0, ""]
	var m := str(c.get("metric", ""))
	var v := -1.0
	match m:
		"readiness": v = float(sim.state.readiness)
		"standing": v = float(sim.state.standing)
		"cities": v = float(sim.active_cities().size())
		"population": v = float(sim.total_residents())
		"inflation": v = float(sim.state.inflation)
	if v < 0.0:
		return [0.0, str(c.get("label", ""))]
	var lab := str(c.get("label", m.capitalize()))
	if c.has("min"):
		var mn := float(c["min"])
		return [clampf(v / maxf(mn, 0.001), 0.0, 1.0), "%s %s / %s" % [lab, _n(v), _n(mn)]]
	if c.has("max"):
		var mx := float(c["max"])
		return [1.0 if v <= mx else clampf(mx / maxf(v, 0.001), 0.0, 1.0), "%s %s / %s" % [lab, _n(v), _n(mx)]]
	return [0.0, lab]


static func _n(v: float) -> String:
	if v >= 100000.0:
		return "%.2fM" % (v / 1e6)
	return str(int(round(v)))
