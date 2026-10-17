class_name PolicyPanel
extends UIWindow
## Government and policies, Civ VI card-and-slot style: your government's slots on the left (grouped by type),
## the policy cards you can slot on the right. Click a card to slot it (into the selected slot, else the first
## free slot of its type), or drag it onto a slot. Click a slotted card to select its slot; right-click empties it.

const TYPES := ["military", "economic", "diplomatic", "wildcard"]
const CARD := Vector2(150, 176)

var sel_slot := -1
var filter := ""
var _slots: Array = []


func _init() -> void:
	super._init("Government and Policies")


static func slot_col(s: String) -> Color:
	match s:
		"military": return Color(0.95, 0.45, 0.40)
		"economic": return Color(0.98, 0.82, 0.35)
		"diplomatic": return Color(0.45, 0.85, 0.65)
	return Color(0.75, 0.6, 1.0)


static func _card_bg(s: String) -> Array:
	match s:
		"military": return [Color(0.42, 0.10, 0.09), Color(0.20, 0.04, 0.04)]
		"economic": return [Color(0.46, 0.33, 0.08), Color(0.22, 0.14, 0.03)]
		"diplomatic": return [Color(0.08, 0.36, 0.26), Color(0.03, 0.16, 0.12)]
	return [Color(0.30, 0.16, 0.46), Color(0.13, 0.06, 0.22)]


func refresh() -> void:
	clear_body()
	var sim: Sim = ui.sim
	var ps: Dictionary = sim.get_policy_state()
	var db: SimDB = ui.db()
	_slots = ps.get("slots", [])
	if sel_slot >= _slots.size():
		sel_slot = -1
	var gov: Dictionary = ps.get("government", {})
	var ti: Dictionary = gov.get("type_info", {})
	var counts := {}
	for s in _slots:
		counts[str(s["slot"])] = int(counts.get(str(s["slot"]), 0)) + 1
	var layout := []
	for t in TYPES:
		if counts.has(t):
			layout.append("%d %s" % [int(counts[t]), t])
	var gl := UITheme.rich("[b][color=#f7dc8f]%s[/color][/b]   Prime Minister %s, since %s.   [color=#a8b0c4]Slots: %s.[/color]\n[color=#a8b0c4]%s[/color]" % [ti.get("name", "Government"), gov.get("pm", "?"), DecisionPopup._date_text(str(gov.get("start", "?"))), ", ".join(layout) if layout.size() > 0 else "none", ti.get("desc", "")], 16)
	var pmt := UIArt.pm_portrait(str(gov.get("pm", "")))   # v3: the prime minister's portrait (art-2d)
	if pmt != null:
		var gh := HBoxContainer.new()
		gh.add_theme_constant_override("separation", 12)
		gh.add_child(CabinetPanel.portrait_box(pmt, 64, str(gov.get("pm", ""))))
		gl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		gh.add_child(gl)
		body.add_child(gh)
	else:
		body.add_child(gl)
	if ui.policy_review_pending():
		var rb := HBoxContainer.new()
		rb.add_theme_constant_override("separation", 12)
		var rl := UITheme.rich("[b][color=#f7dc8f]A new government has taken office.[/color][/b] Review its policy cards (changes are free this turn), then confirm.", 16)
		rl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		rb.add_child(rl)
		var cb := UITheme.button("Confirm policies", ui.confirm_policies, 17)
		cb.add_theme_stylebox_override("normal", UITheme.sb(Color(0.62, 0.40, 0.08), UIKit.GOLD_LIGHT, 2, 5, 10))
		rb.add_child(cb)
		body.add_child(rb)
		if ui.sim.has_method("policy_proposals"):
			# v2: the coalition's programmes (each changes up to two cards), or keep the outgoing cards
			var props: Array = ui.sim.policy_proposals()
			var pf := HFlowContainer.new()
			pf.add_theme_constant_override("h_separation", 6)
			pf.add_theme_constant_override("v_separation", 4)
			for i in props.size():
				var pr: Dictionary = props[i]
				var idx := i
				var pb := UITheme.button("%s: %s" % [str(pr.get("label", "")), UITheme.humanise(str(pr.get("summary", ""))).replace(" -> ", " → ")], func(): ui.choose_policy_proposal(idx), 15)
				pb.tooltip_text = "Adopt this programme and confirm (free this turn)."
				pf.add_child(pb)
			body.add_child(pf)
	var free: bool = ps.get("free_swap", false)
	var swap := "[color=#9fe07a]Changes are free this turn.[/color]" if free else "[color=#e6c76e]Replacing or removing a card costs %d Gold this turn (free after elections, new civics and new eras). Filling an empty slot is always free.[/color]" % int(ps.get("swap_cost", 0))
	body.add_child(UITheme.rich(swap, 15))
	var rails: Array = ui.sim.get_national_summary().get("deficit_streams", [])
	if rails.size() > 0:
		# burdens that end with a specific card (critic M6: the post-1973 deficit waits for the stabilisation plan)
		var rs := []
		for r in rails.slice(0, 3):
			rs.append("%s, [color=#ff8f7a]%s Gold a quarter[/color]: %s" % [str(r.get("label", "")), UITheme.fmt_signed(float(r.get("amount", 0))), str(r.get("ends", ""))])
		body.add_child(UITheme.rich("[color=#e6c76e]Standing deficits:[/color] " + "; ".join(rs), 15))
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 14)
	body.add_child(h)
	# ---- left: the government's slots
	var left := ScrollContainer.new()
	left.custom_minimum_size = Vector2(520, 470 if ui.policy_review_pending() else 560)
	left.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	h.add_child(left)
	var lv := VBoxContainer.new()
	lv.add_theme_constant_override("separation", 6)
	lv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_child(lv)
	for t in TYPES:
		if not counts.has(t):
			continue
		var sec := PanelContainer.new()
		sec.add_theme_stylebox_override("panel", UITheme.sb(Color(0.05, 0.10, 0.22, 0.9), Color(slot_col(t), 0.6), 1, 6, 8))
		lv.add_child(sec)
		var sv := VBoxContainer.new()
		sec.add_child(sv)
		var lab := UITheme.title("%s POLICIES" % t.to_upper(), 15, slot_col(t))
		lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sv.add_child(lab)
		var row := HFlowContainer.new()
		row.alignment = FlowContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("h_separation", 8)
		sv.add_child(row)
		for i in _slots.size():
			if str(_slots[i]["slot"]) == t:
				row.add_child(_slot_box(i, db))
	if _slots.is_empty():
		lv.add_child(UITheme.label("This government has no policy slots yet.", 16, UIKit.TEXT_DIM))
	# ---- right: cards you can slot
	var rv := VBoxContainer.new()
	rv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(rv)
	var fh := HBoxContainer.new()
	fh.add_theme_constant_override("separation", 4)
	rv.add_child(fh)
	var ct := UITheme.title("CHOOSE POLICIES", 17, UIKit.GOLD_LIGHT)
	ct.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fh.add_child(ct)
	for f in ["", "military", "economic", "diplomatic"]:
		var b := UITheme.button("All" if f == "" else f.capitalize(), _set_filter.bind(f), 14)
		if filter == f:
			b.add_theme_stylebox_override("normal", UITheme.sb(Color(0.16, 0.30, 0.55), UIKit.GOLD_LIGHT, 2, 5, 8))
		fh.add_child(b)
	var hint := "Click a card to slot it%s, or drag it onto a slot." % ((" into the selected %s slot" % str(_slots[sel_slot]["slot"])) if sel_slot >= 0 else "")
	rv.add_child(UITheme.label(hint, 14, UIKit.TEXT_DIM))
	var sc := ScrollContainer.new()
	sc.custom_minimum_size = Vector2(0, 430 if ui.policy_review_pending() else 520)
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rv.add_child(sc)
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	sc.add_child(grid)
	var used := {}
	for s in _slots:
		if str(s.get("id", "")) != "":
			used[str(s["id"])] = true
	var n := 0
	for pid in ps.get("available", []):
		if used.has(pid):
			continue
		var p: Dictionary = db.policies.get(pid, {})
		if filter != "" and str(p.get("slot", "")) != filter:
			continue
		grid.add_child(_card(str(pid), p, true))
		n += 1
	if n == 0:
		grid.add_child(UITheme.label("No other cards available.", 15, UIKit.TEXT_DIM))
	if _slots.any(func(s): return str(s.get("id", "")) == ""):
		var ab := UITheme.button("Fill empty slots with the recommended cards", _assign_all, 15)
		rv.add_child(ab)


func _set_filter(f: String) -> void:
	filter = f
	refresh()


func _card(pid: String, p: Dictionary, draggable: bool) -> Control:
	var st := str(p.get("slot", "wildcard"))
	var cols := _card_bg(st)
	var c := PanelContainer.new()
	c.custom_minimum_size = CARD
	var sb := UITheme.sb(cols[0], slot_col(st), 2, 8, 8)
	sb.bg_color = cols[0]
	c.add_theme_stylebox_override("panel", sb)
	c.mouse_filter = Control.MOUSE_FILTER_STOP
	c.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	c.tooltip_text = "%s (%s): %s" % [p.get("name", pid), st, p.get("description", "")]
	c.set_meta("pid", pid)
	var v := VBoxContainer.new()
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_theme_constant_override("separation", 2)
	c.add_child(v)
	var nm := UITheme.label(str(p.get("name", pid)), 15, Color.WHITE, "body_bold")
	nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nm.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(nm)
	var gem := Control.new()
	gem.custom_minimum_size = Vector2(0, 30)
	gem.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var gc := slot_col(st)
	gem.draw.connect(func():
		var m := Vector2(gem.size.x * 0.5, 15)
		gem.draw_colored_polygon(PackedVector2Array([m + Vector2(0, -13), m + Vector2(18, -3), m + Vector2(0, 14), m + Vector2(-18, -3)]), Color(gc, 0.85))
		gem.draw_polyline(PackedVector2Array([m + Vector2(0, -13), m + Vector2(18, -3), m + Vector2(0, 14), m + Vector2(-18, -3), m + Vector2(0, -13)]), Color(1, 1, 1, 0.7), 1.2, true))
	v.add_child(gem)
	var d := UITheme.label(UITheme.humanise(str(p.get("description", ""))), 13, Color(0.95, 0.93, 0.88))
	d.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	d.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(d)
	if draggable:
		c.gui_input.connect(func(e):
			if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
				pick_card(pid))
		c.set_drag_forwarding(func(_at): return _drag_card(pid, p), Callable(), Callable())
	return c


func _drag_card(pid: String, p: Dictionary):
	var prev := _card(pid, p, false)
	prev.modulate = Color(1, 1, 1, 0.85)
	var holder := Control.new()
	holder.add_child(prev)
	prev.position = -CARD * 0.5
	set_drag_preview(holder)
	return {"policy": pid}


func _slot_box(i: int, db: SimDB) -> Control:
	var s: Dictionary = _slots[i]
	var st := str(s["slot"])
	var pid := str(s.get("id", ""))
	var box: Control
	if pid != "":
		box = _card(pid, db.policies.get(pid, {}), false)
		# v3 final (fix4-econ's lever): a card scaled back or suspended in the Treasury says so on its slot
		var cut := str((ui.sim.state.counters.get("policy_cuts", {}) as Dictionary).get(pid, "")) if ui.sim != null else ""
		if cut != "":
			var tag := UITheme.label("HALF STRENGTH" if cut == "half" else "SUSPENDED", 16, Color(1.0, 0.75, 0.4), "body_bold")
			tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
			(box.get_child(0) as VBoxContainer).add_child(tag)
			box.tooltip_text += "\n" + ("Scaled back in the Treasury: half its cost and half its benefits." if cut == "half" else "Suspended in the Treasury: no cost and no benefits; it keeps its slot.")
	else:
		box = PanelContainer.new()
		box.custom_minimum_size = CARD
		box.add_theme_stylebox_override("panel", UITheme.sb(Color(0.03, 0.06, 0.14, 0.7), Color(slot_col(st), 0.55), 1, 8, 8))
		var l := UITheme.label("Empty %s slot\n\nclick a card on the right, or drag one here" % st, 14, Color(slot_col(st), 0.9))
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(l)
		box.mouse_filter = Control.MOUSE_FILTER_STOP
	if i == sel_slot:
		box.add_theme_stylebox_override("panel", UITheme.sb(_card_bg(st)[0] if pid != "" else Color(0.10, 0.18, 0.36), Color.WHITE, 3, 8, 8))
	box.tooltip_text = ("%s\nClick to select this slot; right-click to empty it." % box.tooltip_text) if pid != "" else "Empty %s slot. Click to select it, then click a card." % st
	box.gui_input.connect(func(e):
		if e is InputEventMouseButton and e.pressed:
			if e.button_index == MOUSE_BUTTON_LEFT:
				sel_slot = -1 if sel_slot == i else i
				refresh()
			elif e.button_index == MOUSE_BUTTON_RIGHT and pid != "":
				ui.set_policy(i, ""))
	box.set_drag_forwarding(Callable(), func(_at, data): return _can_drop(i, data), func(_at, data): _drop(i, data))
	return box


func _fits(i: int, pid: String) -> bool:
	var st := str(_slots[i]["slot"])
	return st == "wildcard" or str(ui.db().policies.get(pid, {}).get("slot", "")) == st


func _can_drop(i: int, data) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.has("policy") and _fits(i, str(data["policy"]))


func _drop(i: int, data) -> void:
	sel_slot = -1
	ui.set_policy(i, str(data["policy"]))


func pick_card(pid: String) -> void:
	## Click on a card: the selected slot if it fits, else the first empty slot of its type (then wildcard),
	## else the first slot of its type (replacing a card, which may cost Gold).
	var target := -1
	if sel_slot >= 0 and _fits(sel_slot, pid):
		target = sel_slot
	if target < 0:
		for pass_n in 3:
			for i in _slots.size():
				var st := str(_slots[i]["slot"])
				var empty := str(_slots[i].get("id", "")) == ""
				var ok := (pass_n == 0 and empty and st != "wildcard" and _fits(i, pid)) or (pass_n == 1 and empty and st == "wildcard") or (pass_n == 2 and _fits(i, pid))
				if ok:
					target = i
					break
			if target >= 0:
				break
	if target < 0:
		ui.show_toast("Your government has no %s slot for this card." % str(ui.db().policies.get(pid, {}).get("slot", "")))
		return
	sel_slot = -1
	ui.set_policy(target, pid)


func _assign_all() -> void:
	SimAI.fill_policies(ui.sim)
	ui.sim.refresh()
	refresh()
	ui._refresh_hud()
