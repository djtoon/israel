class_name Unlocks
extends RefCounted
## v4 (V4_DESIGN 2.6): the HUD unlock schedule of story mode. Turn 1 shows only the date, four key numbers, the Menu,
## the era goals and the one primary prompt (7 interactive elements). Every other element appears the first time
## its trigger fires, or at once when its ministry is switched to manual, with a one-line introduction shown exactly
## once. Unlocks are saved in GameUI.ui_state().unlocked. They stay, except that handing a ministry back to its
## minister re-locks what only its take-over unlocked (hand_back), and Settings > Gameplay > "Simplify the screen
## again" re-locks what is not in use. Full control unlocks everything (the v3 HUD).

# [id, the one-line introduction (the Cabinet Secretary's strip)]
const ITEMS := [
	["goals", "Prime Minister, these are the era's goals. One decision at a time: the button tells you what needs you now."],
	["report", "Your ministers ran the routine last quarter. Read what they did; the Government menu opens the Cabinet Room."],
	["queue", "More than one decision this quarter: the next ones wait here."],
	["city_view", "Click a city to see how it is doing. Its minister chooses what it builds."],
	["city_card", "You run production now: each city asks when its queue is empty."],
	["budget", "Each year the Knesset passes a budget. Choose the priority; Finance does the rest."],
	["standing", "An envoy is at the door. Standing is how the world sees Israel."],
	["treasury", "The Treasury is under strain: Finance borrows to cover it, as Israel did in 1949–51. Act only if its number turns red: then open Treasury in the Government menu and take Finance's plan."],
	["programmes", "National programmes are long investments. Launch one when the Treasury can carry it."],
	["ghost", "From now on your Israel is measured against history's on six tracks: see the line under your era goals."],
	["coalition", "A new government needs partners: each takes a ministry and has a price."],
	["policies", "The new government's programme sets its policy cards."],
	["research", "You choose research now. Science unlocks buildings and improvements."],
	["units", "You command the units now. Each one with nothing to do will ask for orders."],
	["minimap", "Your government's screens wait in the Government menu; it can also show a small map of the country."],
	["food", "Israel imports food when the farms fall short; it slows growth."],
	["help", "F1 opens How to Play; the Menu (≡) holds it and the Civilopedia."],
	["trade", "Export routes earn gold and goodwill."],
]
const TURN_TRIGGERS := ["report", "city_view", "ghost", "minimap", "help"]   # fire on a date, not on a use


static func ids() -> Array:
	return ITEMS.map(func(x): return str(x[0]))


static func intro(id: String) -> String:
	for x in ITEMS:
		if x[0] == id:
			return str(x[1])
	return ""


static func is_on(ui, id: String) -> bool:
	if ui == null:
		return false
	if ui.full_hud:
		return true
	return (ui.unlocked as Dictionary).has(id)


static func triggered(ui, id: String, pd: Array) -> bool:
	var sim = ui.sim
	var t: int = sim.state.turn
	var floor_t := int(ui.casual.get("simplified_at", -1))
	if floor_t >= 0 and id in TURN_TRIGGERS and t >= floor_t:
		return false   # re-locked by "Simplify the screen again": a dated element waits for the menu
	var has := func(tp: String) -> bool: return pd.any(func(d): return str(d.get("type", "")) == tp)
	match id:
		"goals": return true
		"report": return t >= 2
		"queue": return t >= 2 and pd.size() >= 2
		"city_view": return t >= 3 or not NextStep.is_auto(ui, "production")
		"city_card": return not NextStep.is_auto(ui, "production")
		"budget": return has.call("state_budget")
		"standing": return pd.any(func(d): return V3Adapter.is_diplo_decision(d))
		"treasury":
			if has.call("treasury") or pd.any(func(d): return NextStep.treasury_agenda(d, sim)):
				return true
			if sim.has_method("get_fiscal_indicator") and t >= 3:
				return str(sim.get_fiscal_indicator().get("level", "ok")) in ["watch", "warning", "danger"]
			return false
		"programmes": return has.call("programme")
		"ghost": return t >= GameUI.GHOST_FROM_TURN
		"coalition": return has.call("coalition")
		"policies": return int(sim.state.counters.get("policy_review", -1)) == t or not NextStep.is_auto(ui, "policies")
		"research": return not NextStep.is_auto(ui, "research") or not NextStep.is_auto(ui, "civics")
		"units": return not NextStep.is_auto(ui, "units") or not NextStep.is_auto(ui, "settlement")
		"minimap":
			if t >= 5:
				return true
			var cd: Dictionary = sim.state.crisis_decision
			return not cd.is_empty() and bool(cd.get("war_turn", false)) and not bool(cd.get("first_turn", false))
		"food": return float(V3Adapter.food(sim).get("surplus", 0.0)) < 0.0 or not NextStep.is_auto(ui, "production")
		"help": return t >= 5
		"trade": return not NextStep.is_auto(ui, "trade")
	return false


static func update(ui) -> Array:
	## Unlocks what has triggered; queues each new element's introduction (once per save). Returns the new ids.
	var out := []
	if ui == null or ui.sim == null or ui.full_hud:
		return out
	var pd: Array = NextStep.player_decisions(ui)
	for x in ITEMS:
		var id := str(x[0])
		if (ui.unlocked as Dictionary).has(id):
			continue
		if triggered(ui, id, pd):
			ui.unlocked[id] = ui.sim.state.turn
			out.append(id)
			if not (ui.intros_seen as Dictionary).has(id):
				ui.intros_seen[id] = ui.sim.state.turn
				ui.queue_intro(id, str(x[1]))
	return out


static func unlock_all_silent(ui) -> void:
	## Full control -> story mid-game: the player has seen every element; keep them (no introductions).
	for x in ITEMS:
		ui.unlocked[str(x[0])] = ui.sim.state.turn if ui.sim != null else 0
		ui.intros_seen[str(x[0])] = true


# v4polish (new-player L012): the HUD parts a ministry's take-over unlocks. Handing the ministry back re-locks what only
# that take-over unlocked (another manual ministry, or the part's own trigger, keeps it).
const DOMAIN_PARTS := {"production": ["city_card", "food"], "research": ["research"], "civics": ["research"],
	"units": ["units"], "settlement": ["units"], "trade": ["trade"], "policies": ["policies"]}   # (the minimap follows the units by itself: GameUI.minimap_shown)


static func note_takeover(ui, domain: String, before: Dictionary) -> void:
	## After a ministry went manual: remember which parts this take-over unlocked (saved with the casual state).
	var tk: Dictionary = ui.casual.get("takeover_parts", {}) if ui.casual.get("takeover_parts") is Dictionary else {}
	var got: Array = (tk.get(domain, []) as Array).duplicate() if tk.get(domain) is Array else []
	for k in ui.unlocked:
		if not before.has(k) and str(k) in DOMAIN_PARTS.get(domain, []) and not (str(k) in got):
			got.append(str(k))
	tk[domain] = got
	ui.casual["takeover_parts"] = tk


static func hand_back(ui, domain: String) -> Array:
	## A ministry went back to auto: re-lock the parts its take-over unlocked, unless something else still needs them.
	## Returns the re-locked ids.
	var out := []
	if ui == null or ui.sim == null or ui.full_hud:
		return out
	var tk: Dictionary = ui.casual.get("takeover_parts", {}) if ui.casual.get("takeover_parts") is Dictionary else {}
	var parts: Array = (tk.get(domain, []) as Array).duplicate() if tk.get(domain) is Array else []
	# (a save from before this was recorded: the parts that nothing but a take-over unlocks)
	for p0 in DOMAIN_PARTS.get(domain, []):
		if str(p0) in ["research", "units", "city_card", "trade"] and not (str(p0) in parts):
			parts.append(str(p0))
	tk.erase(domain)
	ui.casual["takeover_parts"] = tk
	var pd: Array = NextStep.player_decisions(ui)
	for p in parts:
		if not (ui.unlocked as Dictionary).has(p):
			continue
		var still := false
		for d2 in tk:
			if p in (tk[d2] as Array) and not NextStep.is_auto(ui, str(d2)):
				still = true
		if not still:
			still = triggered(ui, p, pd)
		if not still:
			(ui.unlocked as Dictionary).erase(p)
			out.append(p)
	return out


static func simplify(ui) -> void:
	## "Simplify the screen again": re-lock what is not in use (the goals and the report stay; a ministry the player
	## runs keeps its parts; a decision-triggered element comes back with its next decision, without its introduction).
	var keep := ["goals", "report"]
	if not NextStep.is_auto(ui, "production"): keep.append_array(["city_view", "city_card", "food"])
	if not NextStep.is_auto(ui, "research") or not NextStep.is_auto(ui, "civics"): keep.append("research")
	if not NextStep.is_auto(ui, "units") or not NextStep.is_auto(ui, "settlement"): keep.append("units")
	if not NextStep.is_auto(ui, "trade"): keep.append("trade")
	if not NextStep.is_auto(ui, "policies"): keep.append("policies")
	var nu := {}
	for k in ui.unlocked:
		if str(k) in keep:
			nu[k] = ui.unlocked[k]
	ui.unlocked = nu
	ui.casual["simplified_at"] = ui.sim.state.turn if ui.sim != null else 0
