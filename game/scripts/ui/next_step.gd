class_name NextStep
extends Control
## v4 story mode (V4_DESIGN 2.4): the ONE primary prompt ("NOW: <decision> · Decide ▸", or END TURN when nothing is
## pending), a queue of at most 3 chips (then "+N"), and the optional auto-advance of quiet quarters.
##
## It is also the decision-ownership adapter the story UI reads: `sim.auto` (v4-sim-auto, V4_DESIGN 3.1) when the sim
## has it, otherwise the UI's own fallback (GameUI.casual: the domain toggles; MinistersPanel.settle resolves the
## routine with the Recommended picks), so the UI never errors while the sim side is being built.

signal primary_pressed
signal chip_pressed(d: Dictionary)
signal auto_stopped

# the player's decisions in story mode, in the sim's own DECISION_ORDER filtered (2.4); "treasury" = Treasury in danger
const PLAYER_ORDER := ["event_choice", "fork", "coalition", "crisis_response", "treasury", "state_budget", "immigration", "diplomacy", "programme", "dedication", "brief"]
const ROUTINE_ORDER := ["policy_review", "budget_review", "minister", "fill_policy", "choose_research", "choose_civic", "choose_production", "unit_orders", "agenda"]
# [id, domain name, minister (label), decision types, what the minister decides]
const DOMAINS := [
	["production", "Production", "Minister of Labour", ["choose_production"], "What each city builds, its queue and the national projects."],
	["research", "Research", "Minister of Education", ["choose_research"], "The next technology."],
	["civics", "Civics", "Minister of Education", ["choose_civic"], "The next civic."],
	["policies", "Policy cards", "Prime Minister's Office", ["fill_policy", "policy_review"], "The policy cards of each new government."],
	["units", "Military units", "Minister of Defence", ["unit_orders"], "Orders for the brigades, squadrons and boats."],
	["settlement", "Settlement and public works", "Minister of Agriculture", ["unit_orders"], "Settlement groups found towns; public-works crews improve the land."],
	["immigration", "Yearly immigration plan", "Minister of Absorption", ["immigration"], "Where each year's newcomers are settled (a named wave is always yours)."],
	["cabinet", "Ministers' appointments", "Prime Minister's Office", ["minister"], "Cabinet titles: seat cities and ministerial programmes."],
	["budget", "Budget reviews and the routine agenda", "Minister of Finance", ["budget_review", "agenda"], "The mid-year review and the routine cabinet agenda (the budget priority and a Treasury in danger stay yours)."],
	["trade", "Export routes", "Minister of Finance", ["trade_route"], "Export routes from the ports."],
	["delegations", "Delegations", "Foreign Ministry", [], "Goodwill delegations when the Treasury is comfortable (deals and envoys stay yours)."],
]
const BRIEFS := [["balanced", "Balanced", "The Recommended choice in every ministry."], ["security", "Security", "Defence and readiness first."],
	["prosperity", "Prosperity", "Growth, science and the cities first."], ["peace", "Peace", "Standing and the neighbours first; delegations sooner."],
	["society", "Society", "Housing and the newcomers first."]]

var ui
var card: PanelContainer
var badge: Label
var head: Label
var sub: Label
var go_btn: Button
var chips: HBoxContainer
var queue_lbl: Label               # "Then: Budget 1951/52 · Programme" (the queue, as text)
var auto_bar: PanelContainer
var auto_label: Label
var auto_stop: Button
var cur: Dictionary = {}           # the primary decision shown (or {type: end_turn})
var queue_items: Array = []        # the decisions behind it (chips)
var chips_on := false              # the queue chips are unlocked (Unlocks "queue")
var auto_left := -1.0              # auto-advance countdown in seconds (-1 = off)
var _right_edge := 10.0            # free space right of the card (the minimap when it is shown)


func _init() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	name = "NextStep"
	card = PanelContainer.new()
	card.add_theme_stylebox_override("panel", UITheme.sb(Color(0.03, 0.07, 0.16, 0.96), UIKit.GOLD_LIGHT, 2, 8, 12))
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(card)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	card.add_child(v)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	v.add_child(h)
	badge = UITheme.title("NOW", 17, Color(1.0, 0.80, 0.40))
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(badge)
	head = UITheme.label("", 19, UIKit.GOLD_LIGHT, "body_bold")
	head.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	head.custom_minimum_size = Vector2(170, 0)   # (room for a long END TURN → Q3 1948 inside the card's 500)
	h.add_child(head)
	go_btn = UITheme.button("Decide ▸", func(): primary_pressed.emit(), 19)
	go_btn.name = "next_step_go"
	go_btn.custom_minimum_size = Vector2(150, 46)
	go_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(go_btn)
	sub = UITheme.label("", 16, Color(0.86, 0.87, 0.90))
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(sub)
	# v4 fix round (new-player N3): the decisions waiting behind this one are a line of text, not more buttons; they
	# follow on the same card, one at a time
	queue_lbl = UITheme.label("", 15, Color(1.0, 0.80, 0.40), "body_bold")
	queue_lbl.name = "next_step_queue"
	queue_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	queue_lbl.visible = false
	v.add_child(queue_lbl)
	chips = HBoxContainer.new()
	chips.add_theme_constant_override("separation", 6)
	chips.alignment = BoxContainer.ALIGNMENT_END
	chips.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(chips)
	auto_bar = PanelContainer.new()
	auto_bar.add_theme_stylebox_override("panel", UITheme.sb(Color(0.05, 0.10, 0.20, 0.95), UIKit.GOLD, 1, 6, 8))
	auto_bar.visible = false
	add_child(auto_bar)
	var ah := HBoxContainer.new()
	ah.add_theme_constant_override("separation", 10)
	auto_bar.add_child(ah)
	auto_label = UITheme.label("", 16, UIKit.TEXT)
	auto_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ah.add_child(auto_label)
	auto_stop = UITheme.button("Stop", stop_auto, 16)
	ah.add_child(auto_stop)


func _style_go(end_turn: bool) -> void:
	var top := Color(0.20, 0.42, 0.92) if end_turn else Color(0.92, 0.64, 0.18)
	var hov := Color(0.28, 0.52, 1.0) if end_turn else Color(1.0, 0.74, 0.28)
	go_btn.add_theme_stylebox_override("normal", UITheme.sb(top, UIKit.GOLD_LIGHT, 2, 6, 10))
	go_btn.add_theme_stylebox_override("hover", UITheme.sb(hov, Color.WHITE, 2, 6, 10))
	go_btn.add_theme_stylebox_override("pressed", UITheme.sb(top.darkened(0.2), Color.WHITE, 2, 6, 10))
	go_btn.add_theme_color_override("font_color", Color.WHITE)


func set_right_edge(px: float) -> void:
	_right_edge = px
	_layout()


func _layout() -> void:
	# v4polish (new-player t01d: "END TURN → Q3 194" was cut at the right edge): a card wider or taller than its
	# rect grows left and up, never off the screen
	card.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	card.grow_vertical = Control.GROW_DIRECTION_BEGIN
	var w := maxf(500.0, card.get_combined_minimum_size().x)
	var ch := card.get_combined_minimum_size().y
	card.anchor_left = 1.0; card.anchor_right = 1.0; card.anchor_top = 1.0; card.anchor_bottom = 1.0
	card.offset_right = -_right_edge
	card.offset_left = -_right_edge - w
	card.offset_bottom = -18.0
	card.offset_top = -18.0 - ch
	chips.anchor_left = 1.0; chips.anchor_right = 1.0; chips.anchor_top = 1.0; chips.anchor_bottom = 1.0
	chips.offset_right = -_right_edge
	chips.offset_left = -_right_edge - w
	chips.offset_bottom = card.offset_top - 6.0
	chips.offset_top = chips.offset_bottom - 40.0
	auto_bar.anchor_left = 1.0; auto_bar.anchor_right = 1.0; auto_bar.anchor_top = 1.0; auto_bar.anchor_bottom = 1.0
	auto_bar.offset_right = -_right_edge
	auto_bar.offset_left = -_right_edge - w
	var top_of := chips.offset_top if chips.get_child_count() > 0 else card.offset_top
	auto_bar.offset_bottom = top_of - 6.0
	auto_bar.offset_top = auto_bar.offset_bottom - 44.0


func top_y() -> float:
	## The top of the prompt and its chips / strip, in the root's units from the bottom (for the intro strip above it).
	var y := card.offset_top
	if chips.get_child_count() > 0:
		y = chips.offset_top
	if auto_bar.visible:
		y = auto_bar.offset_top
	return y


func show_for(sim, pd: Array) -> void:
	## pd: the player's decisions now (NextStep.player_decisions); the first is the primary prompt, the rest the queue.
	visible = true
	if sim == null:
		return
	if pd.is_empty() or sim.state.game_over:
		cur = {"type": "end_turn"}
		queue_items = []
		var nxt := SimDB.date_label(sim.state.turn + 1)
		badge.text = "QUIET" if not sim.state.game_over else "THE END"
		head.text = "Nothing needs you this quarter." if not sim.state.game_over else "The game is over."
		sub.text = next_hint(sim)
		go_btn.text = ("END TURN → %s" % nxt) if not sim.state.game_over else "Results"
		_style_go(true)
	else:
		cur = pd[0]
		queue_items = pd.slice(1)
		badge.text = "NOW"
		head.text = title_of(sim, cur)
		var st := stake_of(sim, cur)
		var more := ""
		if not chips_on and queue_items.size() > 0:
			more = ("  (+%d more)" % queue_items.size())
		sub.text = st + more
		go_btn.text = "Decide ▸"
		_style_go(false)
	go_btn.tooltip_text = "Key: %s" % GameSettings.binding_text("end_turn")
	_build_chips(sim)
	_layout.call_deferred()


func _build_chips(sim) -> void:
	for c in chips.get_children():
		chips.remove_child(c)
		c.queue_free()
	queue_names = []
	queue_lbl.visible = false
	if not chips_on or queue_items.is_empty():
		return
	for i in mini(queue_items.size(), 3):
		queue_names.append(L10n.t(chip_label(sim, queue_items[i])))
	var tx := L10n.t("Then:") + " " + " · ".join(queue_names)
	if queue_items.size() > 3:
		tx += "  +%d" % (queue_items.size() - 3)
	queue_lbl.text = tx
	queue_lbl.tooltip_text = "\n".join(queue_items.map(func(d): return L10n.t(title_of(sim, d))))
	queue_lbl.mouse_filter = Control.MOUSE_FILTER_PASS
	queue_lbl.visible = true


var queue_names: Array = []        # the waiting decisions named on the queue line (at most 3)


func chip_count() -> int:
	## The waiting decisions named on the queue line (at most 3).
	return queue_names.size()


# ------------------------------------------------------------------ auto-advance quiet quarters

func start_auto(secs := 2.0) -> void:
	auto_left = secs
	auto_bar.visible = true
	_auto_text()
	_layout()


func stop_auto() -> void:
	if auto_left < 0.0 and not auto_bar.visible:
		return
	auto_left = -1.0
	auto_bar.visible = false
	_layout()
	auto_stopped.emit()


func auto_running() -> bool:
	return auto_left >= 0.0


func _auto_text() -> void:
	auto_label.text = "A quiet quarter: continuing in %d s" % int(ceil(maxf(auto_left, 0.0)))


func _process(delta: float) -> void:
	if auto_left < 0.0:
		return
	auto_left -= delta
	if auto_left <= 0.0:
		auto_left = -1.0
		auto_bar.visible = false
		_layout()
		if ui != null and ui.has_method("auto_advance_now"):
			ui.auto_advance_now()
		return
	_auto_text()


# ================================================================== labels

static func next_hint(sim) -> String:
	## One dated line for a quiet quarter: the next fixed event, or the next State Budget.
	if sim == null:
		return ""
	if has_api(sim, "primary"):
		var p = auto_api(sim).primary()
		if p is Dictionary and str(p.get("type", "")) == "end_turn" and str(p.get("next_hint", "")) != "":
			return str(p["next_hint"]) + ("" if str(p["next_hint"]).ends_with(".") else ".")
	var up: Array = sim.get_upcoming_events(8)
	if not up.is_empty():
		return "Next: %s (%s)." % [str(up[0].get("title", "")), SimDB.date_label(int(up[0].get("turn", sim.state.turn + 1)))]
	return "Your ministers carry on with the routine."


static func title_of(sim, d: Dictionary) -> String:
	var t := str(d.get("type", ""))
	match t:
		"event_choice":
			var ev = sim.db.event_by_id.get(str(d.get("event", "")))
			return str(ev.get("title", "An event")) if ev != null else UITheme.humanise(str(d.get("label", "")))
		"fork":
			return str(d.get("title", "A cabinet decision"))
		"crisis_response":
			var ct := RegEx.create_from_string("(?i):? turn \\d+$").sub(str(d.get("title", "")), "").strip_edges()
			if bool(d.get("war_turn", false)) and not bool(sim.state.crisis_decision.get("first_turn", false)):
				return "%s: the front this quarter" % ct if ct != "" else "The front this quarter"
			return "%s: the state's response" % ct if ct != "" else "The state's response"
		"coalition":
			return "Coalition talks: %s forms a government" % str(d.get("government", {}).get("pm", ""))
		"state_budget":
			return "State Budget %s: the priority" % str(d.get("fiscal_year", ""))
		"treasury", "agenda":
			return str(d.get("title", "")) if str(d.get("title", "")) != "" else "The Treasury in danger"
		"immigration":
			return "Immigration: %s" % str(d.get("wave", "")) if str(d.get("wave", "")) != "" else "The year's immigration plan"
		"diplomacy":
			return "Envoy: %s" % str(d.get("title", d.get("actor_name", "")))
		"programme":
			return "National programme: %s" % str(d.get("label", "")).capitalize() if str(d.get("kind", "")) == "open" else "National programmes: the surplus"
		"dedication":
			return "A new era: its dedication"
		"brief":
			return "What should your ministers put first?"
		"choose_production":
			return "Production: %s" % _city_n(sim, int(d.get("city", -1)))
		"choose_research":
			return "Choose research"
		"choose_civic":
			return "Choose a civic"
		"fill_policy":
			return "Fill a policy slot"
		"policy_review":
			return "A new government: its policy cards"
		"unit_orders":
			var u = sim.unit_by_id(int(d.get("unit", -1)))
			return "Orders: %s" % (str(sim.db.units.get(u.type, {}).get("name", u.type)) if u != null else "a unit")
		"minister":
			return "The cabinet's titles"
		"budget_review":
			return "The mid-year budget review"
	return UITheme.humanise(str(d.get("label", t))).capitalize()


static func _city_n(sim, id: int) -> String:
	var c = sim.city_by_id(id)
	return "?" if c == null else str(c.name)


static func stake_of(sim, d: Dictionary, maxlen := 240) -> String:
	## One plain sentence on what is at stake (the decision's explain, else the first sentence of its text). The card
	## shows the whole sentence; the NOW prompt cuts only a very long one (v4 fix round: no "..." mid-thought).
	var t := str(d.get("type", ""))
	if t == "crisis_response":
		return "How the war ends is history; what it costs is yours."
	if t == "brief":
		return "Your ministers run the routine. Tell them once what matters most; you can change it at any time."
	var s := str(d.get("stake", d.get("explain", "")))
	if s == "":
		s = str(d.get("text", d.get("summary", "")))
	if s == "" and t == "event_choice":
		var ev = sim.db.event_by_id.get(str(d.get("event", "")))
		if ev != null:
			s = str(ev.get("summary", ""))
	# the whole text is translated first (data and catalog texts are keys as a whole), then cut to its first sentence
	return first_sentence(L10n.t(UITheme.humanise(s)), maxlen)


static func first_sentence(s: String, maxlen := 150) -> String:
	s = s.strip_edges()
	var re := RegEx.create_from_string("^(.+?[.!?])(\\s|$)")
	var m := re.search(s)
	var out := m.get_string(1) if m != null else s
	if out.length() > maxlen:
		var cut := out.substr(0, maxlen)
		var sp := cut.rfind(" ")
		out = (cut.substr(0, sp) if sp > 40 else cut).strip_edges().trim_suffix(",") + "…"
	return out


static func chip_label(sim, d: Dictionary) -> String:
	match str(d.get("type", "")):
		"event_choice": return "Event"
		"fork": return "Decision"
		"coalition": return "Coalition"
		"crisis_response": return "War" if bool(d.get("war_turn", false)) else "Crisis"
		"treasury", "agenda": return "Treasury"
		"state_budget": return "Budget %s" % str(d.get("fiscal_year", ""))
		"immigration": return "Immigration"
		"diplomacy": return "Envoy · %s" % str(d.get("actor_name", "")) if str(d.get("actor_name", "")) != "" else "Envoy"
		"programme": return "Programme"
		"dedication": return "Dedication"
		"brief": return "Ministers' brief"
		"choose_production": return "Production · %s" % _city_n(sim, int(d.get("city", -1)))
		"choose_research": return "Research"
		"choose_civic": return "Civic"
		"fill_policy", "policy_review": return "Policy"
		"unit_orders": return "Unit orders"
		"minister": return "Ministers"
		"budget_review": return "Budget review"
	return "Decision"


static func chip_icon(d: Dictionary) -> String:
	return {"event_choice": "star", "fork": "unlock_policy", "coalition": "diplomacy", "crisis_response": "diplomacy", "treasury": "gold", "agenda": "gold",
		"state_budget": "gold", "immigration": "housing", "diplomacy": "diplomacy", "programme": "unlock_project", "dedication": "star", "brief": "civics_columns",
		"choose_production": "production", "choose_research": "science", "choose_civic": "culture", "fill_policy": "civics_columns", "policy_review": "civics_columns",
		"unit_orders": "cities", "minister": "unlock_policy", "budget_review": "gold"}.get(str(d.get("type", "")), "star")


# ================================================================== the adapter: who answers each decision

static func auto_api(sim) -> Object:
	## sim.auto (v4-sim-auto), or null while the sim does not have it.
	if sim == null:
		return null
	var a = sim.get("auto")
	return a if a is Object else null


static func has_api(sim, m: String) -> bool:
	var a := auto_api(sim)
	return a != null and a.has_method(m)


static func domains(sim = null) -> Array:
	## [{id, name, minister, types, desc}] (Sim.domains() when the sim has it).
	var s: Script = Sim
	if V3Adapter._static_has(s, "domains"):
		var out = s.call("domains")
		if out is Array and not (out as Array).is_empty():
			return out
	var fb := []
	for d in DOMAINS:
		fb.append({"id": d[0], "name": d[1], "minister": d[2], "types": d[3], "desc": d[4]})
	return fb


static func minister_label(sim, id: String) -> String:
	## The ministry of the day (labels only): Labour before 1977, then Construction and Housing; the Jewish Agency
	## settles the newcomers before the Absorption ministry (1968).
	if has_api(sim, "minister_name"):
		var mn := str(auto_api(sim).minister_name(id))
		if mn != "":
			return mn
	var y: int = sim.year() if sim != null else 1948
	match id:
		"production": return "Minister of Labour" if y < 1977 else "Minister of Construction and Housing"
		"immigration": return "The Jewish Agency" if y < 1968 else "Minister of Absorption"
	for d in DOMAINS:
		if d[0] == id:
			return str(d[2])
	return id


static func is_auto(ui, domain: String) -> bool:
	if ui == null or ui.sim == null:
		return false
	if has_api(ui.sim, "is_auto"):
		return bool(auto_api(ui.sim).is_auto(domain))
	return bool((ui.casual.get("auto", {}) as Dictionary).get(domain, false))


static func set_auto(ui, domain: String, on: bool) -> void:
	if ui == null or ui.sim == null:
		return
	if has_api(ui.sim, "set_auto"):
		auto_api(ui.sim).set_auto(domain, on)
	else:
		if not ui.casual.has("auto"):
			ui.casual["auto"] = {}
		ui.casual["auto"][domain] = on
		if domain == "production":
			_cities_automate(ui, on)   # (sim.auto runs the cities itself)


static func set_all(ui, on: bool) -> void:
	if ui == null or ui.sim == null:
		return
	if has_api(ui.sim, "set_all"):
		auto_api(ui.sim).set_all(on)
		return
	for d in DOMAINS:
		set_auto(ui, str(d[0]), on)


static func _cities_automate(ui, on: bool) -> void:
	## Production on auto: every city runs itself. Back to manual: v3's rule (the larger cities ask; towns of 3 or fewer
	## and the villages keep their automation).
	for c in ui.sim.active_cities():
		if on:
			ui.sim.set_city_automated(c.id, true)
		elif c.pop() > GameUI.SMALL_TOWN_POP or c.key == ui.sim.state.capital:
			if not (str(c.kind) in ["kibbutz", "moshav"]):
				ui.sim.set_city_automated(c.id, false)


static func style(ui) -> String:
	## "story" | "full" | "custom" (the play style as the Settings and the Cabinet Room show it).
	if ui == null or ui.sim == null:
		return "story"
	if ui.full_hud:
		return "full"
	var n_on := 0
	for d in DOMAINS:
		if is_auto(ui, str(d[0])):
			n_on += 1
	return "story" if n_on == DOMAINS.size() else "custom"


static func treasury_agenda(d: Dictionary, sim) -> bool:
	## The agenda's structural-deficit and inflation-emergency items: the Treasury in danger (the player's).
	if str(d.get("type", "")) != "agenda" or sim == null:
		return false
	var aid := str(sim.state.agenda.get("id", ""))
	return aid.contains("emergency") or (aid == "budget" and bool(sim.state.agenda.get("structural", false)))


static func domain_of(sim, d: Dictionary) -> String:
	## The routine domain a decision belongs to, or "" when it is always the player's (2.3).
	match str(d.get("type", "")):
		"choose_production": return "production"
		"choose_research": return "research"
		"choose_civic": return "civics"
		"fill_policy", "policy_review": return "policies"
		"unit_orders":
			var u = sim.unit_by_id(int(d.get("unit", -1)))
			return "settlement" if u != null and str(u.type) in ["settler", "builder"] else "units"
		"immigration": return "" if str(d.get("wave", "")) != "" else "immigration"
		"minister": return "cabinet"
		"budget_review": return "budget"
		"agenda": return "" if treasury_agenda(d, sim) else "budget"
		"trade_route": return "trade"
	return ""


static func owner_of(ui, d: Dictionary) -> String:
	## The domain whose minister answers this decision, or "" when it is the player's.
	if ui == null or ui.sim == null:
		return ""
	if has_api(ui.sim, "owner"):
		return str(auto_api(ui.sim).owner(d))
	var dom := domain_of(ui.sim, d)
	if dom == "" or not is_auto(ui, dom):
		return ""
	return dom


static func order_key(d: Dictionary, sim) -> int:
	var t := str(d.get("type", ""))
	if treasury_agenda(d, sim):
		t = "treasury"
	var i := PLAYER_ORDER.find(t)
	if i >= 0:
		return i
	var j := ROUTINE_ORDER.find(t)
	return 100 + (j if j >= 0 else 50)


static func player_decisions(ui) -> Array:
	## Blocking, player-owned, in the 2.4 order (story mode); the v3 blockers in v3's order in Full control.
	if ui == null or ui.sim == null or ui.sim.state.game_over:
		return []
	var sim = ui.sim
	var out: Array = []
	if ui.full_hud:
		var b: Array = sim.blocking_decisions()
		for t in Sim.DECISION_ORDER:
			for d in b:
				if str(d["type"]) == t:
					out.append(d)
		return out
	if has_api(sim, "player_decisions"):
		return (auto_api(sim).player_decisions() as Array).duplicate()   # (the brief and the Treasury items included)
	for d in sim.blocking_decisions():
		if owner_of(ui, d) == "":
			out.append(d)
	out.sort_custom(func(a, b): return order_key(a, sim) < order_key(b, sim))
	if brief_due(ui):
		out.append(brief_decision(ui))
	return out


static func blocking_left(ui) -> Array:
	## The player's decisions that hold the turn (the brief and the Treasury items are not blocking: End Turn takes
	## their default).
	return player_decisions(ui).filter(func(d): return bool(d.get("blocking", true)))


static func primary(ui) -> Dictionary:
	var pd := player_decisions(ui)
	return pd[0] if not pd.is_empty() else {"type": "end_turn", "blocking": false, "label": "END TURN"}


static func quiet(ui) -> bool:
	return player_decisions(ui).is_empty()


# ------------------------------------------------------------------ the ministers' brief (asked once, turn 2)

static func brief(ui) -> String:
	if ui == null or ui.sim == null:
		return "balanced"
	if has_api(ui.sim, "brief"):
		return str(auto_api(ui.sim).brief())
	return str(ui.casual.get("brief", "balanced"))


static func set_brief(ui, mode: String) -> void:
	if has_api(ui.sim, "set_brief"):
		auto_api(ui.sim).set_brief(mode)
	ui.casual["brief"] = mode
	ui.casual["brief_asked"] = true


static func brief_due(ui) -> bool:
	if has_api(ui.sim, "player_decisions"):
		return false   # sim.auto asks the brief itself
	return not ui.full_hud and not bool(ui.casual.get("brief_asked", false)) and ui.sim.state.turn >= 2 and ui.sim.state.turn <= 12 and not ui.sim.state.game_over


static func brief_decision(ui) -> Dictionary:
	var opts := []
	for b in BRIEFS:
		opts.append({"id": b[0], "label": b[1], "desc": b[2], "default": b[0] == "balanced"})
	return {"type": "brief", "blocking": true, "label": "THE MINISTERS' BRIEF", "title": "What should your ministers put first?", "options": opts,
		"text": "Your ministers run the routine with the Recommended choices. A brief tilts that routine towards one of the four paths to a strong ending; Balanced leaves it neutral."}
