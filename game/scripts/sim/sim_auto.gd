class_name SimAuto
extends RefCounted
## v4 (v4-sim-auto): the casual layer, "story mode" (progress/V4_DESIGN.md 2.1-2.4; API in scripts/sim/API.md "v4").
## The simulation is unchanged; this only decides WHO answers each decision. Eleven routine domains ("ministries") are
## each on auto (the ministers answer with the same SimAI code that makes the Recommended badges) or manual (the v3
## prompts come back). The player keeps the story: forks, event choices, war and front orders, the coalition, the State
## Budget priority, envoys, programmes, the era dedication, named immigration waves, the Treasury in danger and the
## ministers' brief (asked once, on turn 2).
## State: state.counters["auto"] (saved with the game). No state, or every domain manual, is Full control = v3 exactly.

var sim
var _busy := false        # settle() is running (decision methods called from inside it do not settle again)
var _at_start := false    # the turn-start settle: its report lines belong to the quarter that just ended
var _tcache := {}         # treasury condition cache {turn, gold, alarm_key, val}

const VERSION := 1
const BRIEFS := ["balanced", "security", "prosperity", "peace", "society"]
const REPORT_KEEP := 8    # quarters of "your ministers did" lines kept in the save
# Surplus prompts a calendar year beyond the budget card's own (V4_DESIGN 2.4 rule 2 said one; v4 fix round, veteran m7:
# two, so a Recommended story player invests about as often as Full control's and the ministers bank less).
const SURPLUS_QUOTA := 2
const LAST_KEEP := 6      # lines per domain in domain_view().last

# The 11 routine domains (V4_DESIGN 2.2). "minister" is the governments.json ministry whose title of the day names it.
const DOMAINS := [
	{"id": "production", "name": "City production", "short": "Construction", "minister": "housing", "label": "Minister of Construction and Housing",
		"types": ["choose_production"], "desc": "What every city builds (housing, services, districts) and where the national projects go."},
	{"id": "research", "name": "Research", "short": "Education", "minister": "education", "label": "Minister of Education",
		"types": ["choose_research"], "desc": "The next technology when the current one is done."},
	{"id": "civics", "name": "Civics", "short": "Education", "minister": "education", "label": "Minister of Education",
		"types": ["choose_civic"], "desc": "The next civic (laws and institutions) when the current one is done."},
	{"id": "policies", "name": "Policy cards", "short": "Cabinet Secretary", "minister": "", "label": "Prime Minister's Office (Cabinet Secretary)",
		"types": ["fill_policy", "policy_review"], "desc": "Empty policy slots, a new government's programme and the free swaps."},
	{"id": "units", "name": "Military units", "short": "Defence", "minister": "defence", "label": "Minister of Defence",
		"types": ["unit_orders"], "desc": "Moves, attacks and positions of the army's units (the front orders stay yours)."},
	{"id": "settlement", "name": "Settlement and public works", "short": "Agriculture", "minister": "agriculture", "label": "Minister of Agriculture",
		"types": ["unit_orders"], "desc": "Settlement groups found towns; public-works crews build farms, groves and kibbutzim."},
	{"id": "immigration", "name": "The yearly immigration plan", "short": "Absorption", "minister": "absorption", "label": "Minister of Immigrant Absorption",
		"types": ["immigration"], "desc": "Where a normal year's newcomers go. A named wave of immigration is always yours."},
	{"id": "cabinet", "name": "Cabinet appointments", "short": "Prime Minister's Office", "minister": "", "label": "Prime Minister's Office",
		"types": ["minister"], "desc": "Ministers' seats and promotions when a cabinet forms and each year after the budget."},
	{"id": "budget", "name": "Budget reviews and purchases", "short": "Finance", "minister": "economy", "label": "Minister of Finance",
		"types": ["budget_review", "agenda", "programme"], "desc": "The mid-year review, routine agenda items, purchases, refinancing an overdraft and reopening buildings. The budget priority and the Treasury in danger stay yours."},
	{"id": "trade", "name": "Export routes", "short": "Finance", "minister": "economy", "label": "Minister of Finance",
		"types": ["trade_route"], "desc": "Opens every free export route from the port, airport and business cities."},
	{"id": "delegations", "name": "Delegations abroad", "short": "Foreign Ministry", "minister": "", "label": "Foreign Ministry",
		"types": [], "desc": "A delegation when the treasury is comfortable. Deals and envoys are always yours."},
]

# Decision types that are routine (never a player decision with every ministry on auto; sim_test --casual checks it).
const ROUTINE_TYPES := ["choose_production", "choose_research", "choose_civic", "fill_policy", "policy_review", "unit_orders", "minister", "budget_review"]

# The player's order (V4_DESIGN 2.4): v3's DECISION_ORDER filtered, with the Treasury in danger between the war and the
# budget, then the ministers' brief. Manual-domain routine types follow in v3's own order.
const PLAYER_ORDER := ["event_choice", "fork", "coalition", "crisis_response", "agenda", "treasury", "state_budget", "immigration", "diplomacy", "programme", "dedication", "brief"]

const HOLD_IDS := ["hold", "defer"]
const STAND_DOWN_IDS := ["economy_first", "standing_forces", "limited_aims", "op_cover"]

# "Your ministers did" templates. key -> English template ({arg} placeholders, args in the line). The UI renders
# L10n.t(domain short label) + ": " + L10n.t(key).format(args); the sim's own `text` is that line in English.
const TEMPLATES := {
	"auto.production.set": "{city} began {item}.",
	"auto.production.project": "{city} started the national project {item}.",
	"auto.production.replan": "{city} changed its plans: now {item}.",
	"auto.research.set": "next research: {item}.",
	"auto.civics.set": "next civic: {item}.",
	"auto.policies.fill": "adopted the {item} policy.",
	"auto.policies.review": "the new government's programme: {item}.",
	"auto.policies.reslot": "switched to the {item} policy.",
	"auto.units.attacks": "{n} attacks on enemy forces.",
	"auto.units.moved": "{n} units took up new positions.",
	"auto.units.orders": "{n} units kept to their posts.",
	"auto.units.stand_down": "{n} units stood down for the quarter.",
	"auto.settlement.found": "settlers founded the new town of {city}.",
	"auto.settlement.build": "work crews built {n} farms, roads or water works.",
	"auto.settlement.moved": "{n} groups of settlers and work crews moved to where they are needed.",
	"auto.settlement.orders": "{n} groups of settlers and work crews waited for work.",
	"auto.immigration.plan": "this year's newcomers: {item}.",
	"auto.cabinet.ministers": "the cabinet's priorities: {item}.",
	"auto.budget.review": "the mid-year budget review: {item}.",
	"auto.budget.agenda": "{title}: {item}.",
	"auto.budget.purchase": "bought {item} in {city}.",
	"auto.budget.spent": "purchases this quarter: {gold} gold.",
	"auto.budget.loan": "took a loan of {gold} gold to cover the overdraft.",
	"auto.budget.reopen": "reopened {n} buildings it had closed to save money, now that the budget has room.",
	"auto.budget.restore": "restored the {item} card to full strength.",
	"auto.budget.hold_surplus": "kept the surplus; the programmes come up again at the budget.",
	"auto.budget.defer": "{item} waits for a quieter quarter.",
	"auto.budget.levers": "the emergency plan: {item}.",
	"auto.budget.plan_end": "the treasury is out of danger; the emergency plan ends.",
	"auto.trade.route": "new export route {city} to {partner}.",
	"auto.delegations.sent": "a delegation to {actor} ({gold} gold).",
	# v4 fix round (v4fix-sim): nothing is offered that could not finish before the end of the game
	"auto.budget.hold_last": "kept the surplus: no programme could be finished before the end.",
	# v4polish-ui (new-player: "a wall of jargon"): the lines use plain words; the keys and args are unchanged.
# v4 fix round: the singular of every counted line ("1 unit", not "1 units"); _line picks "<key>.one" when n is 1
	"auto.units.attacks.one": "1 attack on an enemy force.",
	"auto.units.moved.one": "1 unit took up a new position.",
	"auto.units.orders.one": "1 unit kept to its post.",
	"auto.units.stand_down.one": "1 unit stood down for the quarter.",
	"auto.settlement.build.one": "work crews built 1 farm, road or water work.",
	"auto.settlement.moved.one": "1 group of settlers or work crew moved to where it is needed.",
	"auto.settlement.orders.one": "1 group of settlers or work crew waited for work.",
	"auto.budget.reopen.one": "reopened 1 building it had closed to save money, now that the budget has room.",
}

# v4 fix round: counted lines are merged into one line per ministry and quarter (the turn-start and end-of-quarter passes
# of the units used to give two "Defence: N attacks" lines); "auto.budget.spent" adds up its gold.
const MERGE_KEYS := ["auto.units.attacks", "auto.units.moved", "auto.units.orders", "auto.units.stand_down", "auto.settlement.build",
	"auto.settlement.moved", "auto.settlement.orders", "auto.budget.reopen", "auto.budget.spent"]

const STAT_NAMES := {"gold": "Treasury", "standing": "Standing", "trust": "Civic Trust", "morale": "Civic Trust", "cohesion": "Cohesion",
	"readiness": "Readiness", "inflation": "Inflation", "production": "Production", "science": "Science", "culture": "Culture",
	"population": "Population", "housing": "Housing", "water": "Water", "amenity": "Amenities", "upkeep": "Upkeep", "intl_standing": "Standing",
	"water_supply_pct": "Water supply", "water_demand_pct": "Water demand", "economy": "Economy"}
const STAT_SCALE := {"gold": 25.0, "production": 15.0, "science": 15.0, "culture": 20.0, "standing": 1.0, "trust": 1.0, "morale": 1.0,
	"cohesion": 1.0, "readiness": 2.0, "inflation": 2.0, "population": 1.0, "housing": 0.5, "water": 5.0, "amenity": 0.5, "upkeep": 5.0}
const STAT_TRACK := {"population": "population", "housing": "population", "gold": "economy", "production": "economy", "upkeep": "economy",
	"inflation": "economy", "economy": "economy", "science": "science", "water": "water", "water_supply_pct": "water", "water_demand_pct": "water",
	"standing": "standing", "intl_standing": "standing", "culture": "standing", "trust": "cohesion", "morale": "cohesion", "cohesion": "cohesion", "amenity": "cohesion"}
const TRACK_NAMES := {"population": "Population", "economy": "Economy", "science": "Science", "water": "Water", "standing": "Standing", "cohesion": "Cohesion"}


func _init(s) -> void:
	sim = s


# ================================================================== state

static func domains_static() -> Array:
	return DOMAINS.duplicate(true)


func _has() -> bool:
	return sim != null and sim.state != null and sim.state.counters.has("auto")


func _default_state() -> Dictionary:
	var dm := {}
	for d in DOMAINS:
		dm[str(d["id"])] = false
	return {"v": VERSION, "domains": dm, "brief": "balanced", "brief_asked": false, "report": [], "last": {}, "turn": -1, "seen": {},
		"failed": {}, "prog": {}, "surplus_year": {}, "budget_turn": -99, "h_start": -99, "h_end": -99, "deferred": [],
		"treasury": {"mandate": false, "since": -99, "declined": -99, "answered": -99, "levers": -99}, "stats": {"actions": 0, "covered": 0, "lines": 0}}


func S() -> Dictionary:
	## The casual layer's saved state (created on first use; created in Full control = every domain manual).
	if not sim.state.counters.has("auto"):
		sim.state.counters["auto"] = _default_state()
	var a: Dictionary = sim.state.counters["auto"]
	if int(a.get("v", 0)) != VERSION:
		var d := _default_state()
		for k in d:
			if not a.has(k): a[k] = d[k]
		a["v"] = VERSION
	return a


func on_new_game(opts: Dictionary) -> void:
	## Sim.new_game({... "play_style": "story" | "full"}) before the first quarter starts. Default "full" (no state: v3).
	sim.state.counters.erase("auto")
	_tcache = {}
	if str(opts.get("play_style", "full")) == "story":
		var a := S()
		for d in DOMAINS:
			a["domains"][str(d["id"])] = true


func _any_auto() -> bool:
	if not _has():
		return false
	var dm: Dictionary = sim.state.counters["auto"].get("domains", {})
	for k in dm:
		if bool(dm[k]): return true
	return false


func is_full() -> bool:
	## Full control (every ministry manual): the v3 game, exactly.
	return not _any_auto()


func style() -> String:
	## "story" (every ministry on auto), "full" (every ministry manual) or "custom" (some of each).
	if not _has():
		return "full"
	var on := 0
	var dm: Dictionary = S()["domains"]
	for d in DOMAINS:
		if bool(dm.get(str(d["id"]), false)): on += 1
	if on == 0: return "full"
	if on == DOMAINS.size(): return "story"
	return "custom"


func set_style(s: String) -> bool:
	if s == "story":
		set_all(true)
		return true
	if s == "full":
		set_all(false)
		return true
	return false


func set_all(on: bool) -> void:
	if not on and not _has():
		return   # already Full control (keep a v3 game free of casual state)
	var a := S()
	for d in DOMAINS:
		a["domains"][str(d["id"])] = on
	if on:
		settle()


func is_auto(domain: String) -> bool:
	if not _has():
		return false
	return bool(sim.state.counters["auto"].get("domains", {}).get(domain, false))


func set_auto(domain: String, on: bool) -> bool:
	## Flip one ministry at any time; handing it back to the minister settles its open decisions at once.
	var ok := false
	for d in DOMAINS:
		if str(d["id"]) == domain: ok = true
	if not ok:
		return false
	if not on and not _has():
		return true
	S()["domains"][domain] = on
	if on:
		settle()
	return true


func brief() -> String:
	if not _has():
		return "balanced"
	return str(S().get("brief", "balanced"))


func set_brief(mode: String) -> bool:
	## The ministers' brief (V4_DESIGN 2.2): "balanced" (plain Recommended) or one strategist's routine settings.
	if not (mode in BRIEFS):
		return false
	var a := S()
	a["brief"] = mode
	a["brief_asked"] = true
	if not _busy:
		settle()
	return true


func _mstyle() -> String:
	## The AI style the ministers play with: plain Recommended, or the strategist of the brief (routine settings only).
	var b := brief()
	return "recommended" if b == "balanced" else "strategist_" + b


func _with_style(st: String, f: Callable) -> Variant:
	var c: Dictionary = sim.state.counters
	var had := c.has("ai_style")
	var old = c.get("ai_style")
	c["ai_style"] = st
	var r = f.call()
	if had:
		c["ai_style"] = old
	else:
		c.erase("ai_style")
	return r


func _turn() -> int:
	return int(sim.state.turn)


func _new_turn() -> void:
	var a := S()
	if int(a.get("turn", -1)) != _turn():
		a["turn"] = _turn()
		a["seen"] = {}
		a["failed"] = {}


# ================================================================== who answers

func owner(d: Dictionary) -> String:
	## The domain whose minister answers this decision, or "" when it is the player's (V4_DESIGN 2.3).
	match str(d.get("type", "")):
		"choose_production": return "production"
		"choose_research": return "research"
		"choose_civic": return "civics"
		"fill_policy", "policy_review": return "policies"
		"unit_orders":
			var u = sim.unit_by_id(int(d.get("unit", -1)))
			if u != null and u.type in ["settler", "builder"]:
				return "settlement"
			return "units"
		"immigration":
			return "" if str(d.get("wave", "")) != "" else "immigration"
		"minister": return "cabinet"
		"budget_review": return "budget"
		"agenda":
			return "" if _agenda_is_treasury() else "budget"
		"programme":
			var pr: Dictionary = S().get("prog", {}) if _has() else {}
			if int(pr.get("turn", -1)) == _turn():
				return str(pr.get("owner", ""))
			return ""
		"trade_route": return "trade"
	return ""


func auto_owned(d: Dictionary) -> bool:
	var o := owner(d)
	return o != "" and is_auto(o)


func _agenda_is_treasury() -> bool:
	## The agenda's structural-deficit and inflation-emergency items are the Treasury in danger: the player's.
	var ag: Dictionary = sim.state.agenda
	return bool(ag.get("structural", false)) or str(ag.get("id", "")) == "inflation_emergency"


func _key(d: Dictionary) -> String:
	var t := str(d.get("type", ""))
	for k in ["event", "fork", "city", "unit", "slot", "crisis", "actor", "kind", "wave"]:
		if d.has(k):
			return "%s:%s:%s" % [t, k, str(d[k])]
	return t


# ================================================================== settle: the ministers act

func settle_start() -> void:
	## Called at the end of Sim._start_turn (before the quarter's decision snapshot).
	_at_start = true
	settle()
	_at_start = false


func settle() -> int:
	## Resolves every open decision of an auto domain with the minister's pick (Recommended, or the brief's strategist),
	## in DECISION_ORDER, at most 80 a pass; runs the quarter's routine start helpers once. Returns how many it answered.
	if _busy or not _any_auto() or sim.state.game_over:
		return 0
	_busy = true
	_new_turn()
	var n := 0
	var st := _mstyle()
	var a := S()
	if int(a.get("h_start", -99)) != _turn():
		a["h_start"] = _turn()
		_with_style(st, _start_helpers)
	for _pass in range(4):
		_programme_rules()   # (first: the budget card's surplus half is held before the player is shown it)
		_update_seen()
		var k: int = _with_style(st, _resolve_loop)
		n += k
		if k == 0:
			break
	_update_seen()
	_busy = false
	return n


func before_end_turn(force: bool) -> void:
	## Called at the top of Sim.end_turn: the quarter's late routine (projects, swaps, Finance, units), then the last
	## settle. When the quarter will end, the brief and the Treasury view (non-blocking) take their defaults.
	if not _any_auto() or sim.state.game_over:
		return
	settle()
	var a := S()
	var st := _mstyle()
	if int(a.get("h_end", -99)) != _turn():
		a["h_end"] = _turn()
		_busy = true
		_with_style(st, _end_helpers)
		_busy = false
		settle()
	# a unit still without orders stands down for the quarter (as SimAI.play_turn does)
	_busy = true
	var down := {"units": 0, "settlement": 0}
	for d in sim.blocking_decisions():
		if str(d["type"]) == "unit_orders" and auto_owned(d):
			var uu = sim.unit_by_id(int(d["unit"]))
			if uu != null:
				uu.orders = "sleep"
				var dom := owner(d)
				down[dom] = int(down[dom]) + 1
				_act(1)
	if int(down["units"]) > 0: _line("units", "auto.units.stand_down", {"n": int(down["units"])}, {"kind": "panel", "id": "units"}, int(down["units"]))
	if int(down["settlement"]) > 0: _line("settlement", "auto.settlement.orders", {"n": int(down["settlement"])}, {"kind": "panel", "id": "units"}, int(down["settlement"]))
	_busy = false
	if force or _player_blocking().is_empty():
		# (an item that waited for a quieter quarter was never shown: it comes up again next quarter)
		if _brief_due() and a["seen"].has("brief"):
			a["brief_asked"] = true   # End Turn keeps the default brief (Balanced)
		if _treasury_due() and a["seen"].has("treasury"):
			a["treasury"]["declined"] = _turn()   # End Turn: Finance holds; asked again in a year


func _player_blocking() -> Array:
	return sim.blocking_decisions().filter(func(d): return not auto_owned(d))


func _resolve_loop() -> int:
	var n := 0
	var a := S()
	var uo := {"units": 0, "settlement": 0}
	for _i in range(80):
		var b: Array = sim.blocking_decisions()
		var pick := {}
		for t in Sim.DECISION_ORDER:
			for d in b:
				if str(d["type"]) == t and auto_owned(d) and not a["failed"].has(_key(d)):
					pick = d
					break
			if not pick.is_empty():
				break
		if pick.is_empty():
			break
		var k := _key(pick)
		var r := _resolve_auto(pick, uo)
		if r > 0:
			n += 1
		# a decision answered stays answered; one that cannot be (or was a no-op) is not tried again this quarter
		if r <= 0 or str(pick["type"]) in ["fill_policy"]:
			a["failed"][k] = _turn()
	for s in sim.state.policies:
		if str(s["id"]) == "__none":
			s["id"] = ""
	if int(uo["units"]) > 0: _line("units", "auto.units.orders", {"n": int(uo["units"])}, {"kind": "panel", "id": "units"}, int(uo["units"]))
	if int(uo["settlement"]) > 0: _line("settlement", "auto.settlement.orders", {"n": int(uo["settlement"])}, {"kind": "panel", "id": "units"}, int(uo["settlement"]))
	return n


func _resolve_auto(d: Dictionary, uo: Dictionary) -> int:
	## One minister's answer: 1 = done (with its report line), 0 = nothing to change, -1 = could not.
	var t := str(d["type"])
	match t:
		"choose_production":
			var c = sim.city_by_id(int(d.get("city", -1)))
			if c == null:
				return -1
			SimAI.resolve_one(sim, d)
			if c.queue.is_empty():
				return -1
			var it: Dictionary = c.queue[0]
			_act(1)
			_line("production", "auto.production.set", {"city": c.name, "city_id": c.id, "item": _item_name(str(it["kind"]), str(it["id"])), "item_id": str(it["id"]), "kind": str(it["kind"])},
				{"kind": "city", "id": c.id}, 1, _unit_prefix(str(it["id"])) if str(it["kind"]) == "unit" else "")
			return 1
		"choose_research":
			if not SimAI.resolve_one(sim, d):
				return -1
			var tid := str(sim.state.current_tech)
			_act(1)
			_line("research", "auto.research.set", {"item": str(sim.db.techs.get(tid, {}).get("name", tid)).trim_suffix(" (repeatable)"), "item_id": tid}, {"kind": "tech", "id": tid})
			return 1
		"choose_civic":
			if not SimAI.resolve_one(sim, d):
				return -1
			var cid := str(sim.state.current_civic)
			_act(1)
			_line("civics", "auto.civics.set", {"item": str(sim.db.civics.get(cid, {}).get("name", cid)).trim_suffix(" (repeatable)"), "item_id": cid}, {"kind": "civic", "id": cid})
			return 1
		"fill_policy":
			var before: Array = sim.state.policies.map(func(p): return str(p["id"]))
			SimAI.resolve_one(sim, d)
			var changed := 0
			for i in range(sim.state.policies.size()):
				var pid := str(sim.state.policies[i]["id"])
				if i < before.size() and pid != str(before[i]) and pid != "__none" and pid != "":
					changed += 1
					_act(1)
					_line("policies", "auto.policies.fill", {"item": str(sim.db.policies.get(pid, {}).get("name", pid)), "item_id": pid, "slot": i}, {"kind": "policy", "id": pid})
			return 1 if changed > 0 else 0
		"policy_review":
			var props: Array = d.get("proposals", [])
			if not SimAI.resolve_one(sim, d):
				return -1
			var chosen := str(sim.state.counters.get("policy_proposal", "keep")) if not props.is_empty() else "keep"
			var txt := "keeps the outgoing cards"
			for p in props:
				if str(p.get("id", "")) == chosen:
					txt = str(p.get("summary", p.get("label", "")))
			_act(1)
			_line("policies", "auto.policies.review", {"item": txt, "proposal": chosen}, {"kind": "panel", "id": "policies"})
			return 1
		"unit_orders":
			if not SimAI.resolve_one(sim, d):
				return -1
			var dom := owner(d)
			uo[dom] = int(uo.get(dom, 0)) + 1
			_act(1)
			return 1
		"immigration":
			var io := SimAI.pick_immigration(sim)
			if not SimAI.resolve_one(sim, d):
				return -1
			var plan_id := str(sim.state.immigration_plan.get("option", io))
			var lbl := plan_id
			for o in d.get("options", []):
				if str(o.get("id", "")) == plan_id: lbl = str(o.get("label", plan_id))
			_act(1)
			_line("immigration", "auto.immigration.plan", {"item": lbl, "option": plan_id}, {"kind": "panel", "id": "immigration"})
			return 1
		"minister":
			var picks: Array = sim.cabinet.minister_options().filter(func(o): return o.get("default", false)).map(func(o): return str(o.get("label", o["id"])))
			if not SimAI.resolve_one(sim, d):
				return -1
			_act(1)
			_line("cabinet", "auto.cabinet.ministers", {"item": "; ".join(picks), "n": picks.size()}, {"kind": "panel", "id": "cabinet"})
			return 1
		"budget_review":
			var ro: Array = sim.cabinet.review_options()
			var ri := SimAI.pick_option(sim, ro, false, ["supplement", "keep"])
			var rl := str(ro[ri].get("label", "")) if ri >= 0 and ri < ro.size() else ""
			if not SimAI.resolve_one(sim, d):
				return -1
			_act(1)
			_line("budget", "auto.budget.review", {"item": rl}, {"kind": "panel", "id": "budget"})
			return 1
		"agenda":
			var ao: Array = sim.state.agenda.get("options", [])
			var ai := SimAI.pick_agenda(sim)
			var al := str(ao[ai].get("label", "")) if ai >= 0 and ai < ao.size() else ""
			var title := str(sim.state.agenda.get("title", "The cabinet agenda"))
			if not SimAI.resolve_one(sim, d):
				return -1
			_act(1)
			_line("budget", "auto.budget.agenda", {"title": title, "item": al}, {"kind": "panel", "id": "budget"})
			return 1
		"programme":
			return _finance_programme(d)
	return -1


func _finance_programme(d: Dictionary) -> int:
	## Finance answers a programme decision only under the queue rules of V4_DESIGN 2.4: a surplus beyond the one a year
	## (hold), or any programme in a quarter that already holds 3 player decisions (hold, or "not now" with the level
	## offered again next quarter).
	var pr: Dictionary = S().get("prog", {})
	var why := str(pr.get("why", ""))
	var kind := str(d.get("kind", ""))
	var opts: Array = d.get("options", [])
	var first := str(opts[0].get("label", "the programme")) if not opts.is_empty() else "the programme"
	if why == "crowded" and kind in ["open", "due"]:
		if not sim.endgame.defer_to_next_quarter():
			return -1
		var dl: Array = S().get("deferred", [])
		dl.append({"turn": _turn(), "kind": kind, "option": str(opts[0].get("id", "")) if not opts.is_empty() else ""})
		S()["deferred"] = dl.slice(maxi(0, dl.size() - 20))
		_act(1)
		_line("budget", "auto.budget.defer", {"item": first}, {"kind": "panel", "id": "programmes"})
		return 1
	var hi := -1
	for i in range(opts.size()):
		if str(opts[i].get("id", "")) in HOLD_IDS: hi = i
	if hi < 0 or not sim.choose_programme(hi):
		return -1
	_act(1)
	if kind == "surplus":
		S()["held"] = int(S().get("held", 0)) + 1   # (sim_test --casual reports it)
	var hk := "auto.budget.defer"
	if why == "late":
		hk = "auto.budget.hold_last"
	elif kind == "surplus":
		hk = "auto.budget.hold_surplus"
	_line("budget", hk, {"item": first}, {"kind": "panel", "id": "programmes"})
	return 1


func _update_seen() -> void:
	## Remembers every player decision met this quarter (the deferral rule counts them).
	var a := S()
	var seen: Dictionary = a["seen"]
	for d in player_decisions():
		var t := str(d.get("type", ""))
		if t == "state_budget":
			a["budget_turn"] = _turn()
		if d.get("surplus") is Dictionary and not (d["surplus"] as Dictionary).is_empty():
			seen["surplus"] = true   # the budget card's second half is a decision too (v4 fix round)
		if d.get("treasury") is Dictionary and not (d["treasury"] as Dictionary).is_empty():
			seen["treasury"] = true
		if t == "programme":
			continue
		seen[_key(d)] = true


func _seen_others() -> int:
	return S()["seen"].size()


func _quarter_load(exclude: Array) -> int:
	## v4 fix round (veteran m1): the player decisions of this quarter, met or still open (programmes aside), without the
	## keys in `exclude`. The deferrable items (the Treasury in danger, the brief, the budget card's surplus half) wait for
	## a quieter quarter when the load is already 3 (or 4 with the budget), so a quarter outside war stays at 4 or fewer.
	var keys := {}
	if _has():
		for k in S()["seen"]:
			keys[k] = true
	for d in sim.blocking_decisions():
		if str(d["type"]) == "programme" or auto_owned(d):
			continue
		keys[_key(d)] = true
	for k in exclude:
		keys.erase(k)
	return keys.size()


func _treasury_slot() -> bool:
	## The Treasury in danger shows this quarter (it was already shown, or the quarter has room for it).
	return S()["seen"].has("treasury") or _quarter_load(["treasury"]) < 3


func _budget_quarter() -> bool:
	if int(S().get("budget_turn", -99)) == _turn():
		return true
	for d in sim.blocking_decisions():
		if str(d["type"]) == "state_budget": return true
	return false


func _programme_rules() -> void:
	## V4_DESIGN 2.4 queue rules for the programme decision (only while Finance is on auto).
	if sim.endgame == null or not sim.endgame.decision_due():
		return
	var a := S()
	var pd: Dictionary = sim.endgame.programme_decision()
	var kind := str(pd.get("kind", ""))
	var pr: Dictionary = a.get("prog", {})
	var t := _turn()
	var merged := kind == "surplus" and _budget_quarter()
	if int(pr.get("turn", -1)) != t:
		pr = {"turn": t, "owner": "", "why": "", "quota": false}
		if is_auto("budget") and kind == "surplus" and not merged:
			var y := str(SimDB.year_of(t))
			var sy: Dictionary = a["surplus_year"]
			if int(sy.get(y, 0)) >= SURPLUS_QUOTA:
				pr["owner"] = "budget"; pr["why"] = "quota"
			else:
				sy[y] = int(sy.get(y, 0)) + 1
				pr["quota"] = true
		a["prog"] = pr
	if str(pr.get("owner", "")) == "" and is_auto("budget") and not merged and _quarter_load([]) >= 3:
		pr["owner"] = "budget"; pr["why"] = "crowded"
		if bool(pr.get("quota", false)):
			var y2 := str(SimDB.year_of(t))
			a["surplus_year"][y2] = maxi(0, int(a["surplus_year"].get(y2, 1)) - 1)   # the player never saw it
			pr["quota"] = false
	# v4 fix round (veteran m1): the budget card's surplus half also waits when the quarter is full (budget + 3 others)
	if str(pr.get("owner", "")) == "" and is_auto("budget") and merged and not a["seen"].has("surplus") and _quarter_load(["surplus"]) >= 4:
		pr["owner"] = "budget"; pr["why"] = "crowded"
	# v4 fix round (veteran m9): nothing is offered that could not be finished before the end of the game
	if str(pr.get("owner", "")) == "" and is_auto("budget") and _cannot_finish(pd):
		pr["owner"] = "budget"; pr["why"] = "late"


func _cannot_finish(pd: Dictionary) -> bool:
	## No launch or expansion on the card would complete by the last playable quarter.
	var t := _turn()
	var last := Sim.last_playable_turn()
	var any := false
	for o in pd.get("options", []):
		var id := str(o.get("id", ""))
		if not (id.begins_with("launch:") or id.begins_with("expand:")):
			continue
		any = true
		if t + maxi(1, int(o.get("turns", 4))) - 1 < last:
			return false
	return any or t >= last


# ------------------------------------------------------------------ routine helpers (once a quarter)

func _start_helpers() -> int:
	_units_pass()
	if is_auto("trade"):
		_trade()
	if is_auto("delegations"):
		_delegations()
	return 0


func _end_helpers() -> int:
	if is_auto("production"):
		_projects()
		if brief() == "society":
			_replan()
	if is_auto("policies"):
		_reslot()
	_treasury_quarter()
	if is_auto("budget"):
		if not SimAI.fiscal_danger(sim):
			_healthy_levers()
		_bonds()
		_purchases()
	_units_pass()
	return 0


func _units_pass() -> void:
	## SimAI._units, split by ministry: Defence moves the army, Agriculture the settlement groups and crews.
	var mil := is_auto("units")
	var setl := is_auto("settlement")
	if not mil and not setl:
		return
	var hits := [0]
	var moved := {}
	var founded := []
	var cb1 := func(_r): hits[0] = int(hits[0]) + 1
	var cb2 := func(uid, _f, _t): moved[int(uid)] = true
	var cb3 := func(cid): founded.append(int(cid))
	sim.combat.connect(cb1)
	sim.unit_moved.connect(cb2)
	sim.city_founded.connect(cb3)
	var charges := {}
	for u in sim.state.units:
		if u.owner == "player" and u.type == "builder":
			charges[u.id] = int(u.charges)
	for u in sim.state.units.duplicate():
		if u.owner != "player" or not sim.state.units.has(u):
			continue
		match u.type:
			"settler":
				if setl: SimAI._settler(sim, u)
			"builder":
				if setl: SimAI._builder(sim, u)
			_:
				if mil: SimAI._military(sim, u)
	sim.combat.disconnect(cb1)
	sim.unit_moved.disconnect(cb2)
	sim.city_founded.disconnect(cb3)
	var builds := 0
	for uid in charges:
		var uu = sim.unit_by_id(int(uid))
		builds += int(charges[uid]) - (int(uu.charges) if uu != null else 0)
	var mil_moved := 0
	var set_moved := 0
	for uid in moved:
		var u2 = sim.unit_by_id(int(uid))
		if u2 == null or u2.owner != "player":
			continue
		if u2.type in ["settler", "builder"]: set_moved += 1
		else: mil_moved += 1
	if int(hits[0]) > 0:
		_act(int(hits[0]))
		_line("units", "auto.units.attacks", {"n": int(hits[0])}, {"kind": "panel", "id": "units"}, int(hits[0]))
	if mil_moved > 0:
		_act(mil_moved)
		_line("units", "auto.units.moved", {"n": mil_moved}, {"kind": "panel", "id": "units"}, mil_moved)
	for cid in founded:
		var c = sim.city_by_id(int(cid))
		_act(1)
		_line("settlement", "auto.settlement.found", {"city": c.name if c != null else "?", "city_id": int(cid)}, {"kind": "city", "id": int(cid)})
	if builds > 0:
		_act(builds)
		_line("settlement", "auto.settlement.build", {"n": builds}, {"kind": "panel", "id": "units"}, builds)
	if set_moved > 0:
		_act(set_moved)
		_line("settlement", "auto.settlement.moved", {"n": set_moved}, {"kind": "panel", "id": "units"}, set_moved)


func _trade() -> void:
	var before: int = sim.state.trade_routes.size()
	SimAI.trade_routes(sim)
	var rs: Array = sim.state.trade_routes
	for i in range(before, rs.size()):
		var r: Dictionary = rs[i]
		var c = sim.city_by_id(int(r.get("from", -1)))
		var p := str(r.get("partner", ""))
		_act(1)
		_line("trade", "auto.trade.route", {"city": c.name if c != null else "?", "city_id": int(r.get("from", -1)), "partner": _actor_name(p), "partner_id": p}, {"kind": "actor", "id": p})


func _delegations() -> void:
	var before := {}
	for a in sim.state.diplomacy:
		before[a] = int(sim.state.diplomacy[a].get("last_delegation", -99))
	var g0: float = sim.state.gold
	SimAI.delegations(sim)
	for a in sim.state.diplomacy:
		if int(sim.state.diplomacy[a].get("last_delegation", -99)) != int(before.get(a, -99)):
			_act(1)
			_line("delegations", "auto.delegations.sent", {"actor": _actor_name(str(a)), "actor_id": str(a), "gold": int(round(g0 - sim.state.gold))}, {"kind": "actor", "id": str(a)})


func _queue_heads() -> Dictionary:
	var h := {}
	for c in sim.active_cities():
		h[c.id] = ("" if c.queue.is_empty() else "%s:%s" % [str(c.queue[0]["kind"]), str(c.queue[0]["id"])])
	return h


func _projects() -> void:
	var before := _queue_heads()
	SimAI._start_projects(sim)
	for c in sim.active_cities():
		if c.queue.is_empty() or str(c.queue[0]["kind"]) != "project":
			continue
		if str(before.get(c.id, "")) != "project:" + str(c.queue[0]["id"]):
			_act(1)
			_line("production", "auto.production.project", {"city": c.name, "city_id": c.id, "item": _item_name("project", str(c.queue[0]["id"])), "item_id": str(c.queue[0]["id"])}, {"kind": "city", "id": c.id})


func _replan() -> void:
	var before := _queue_heads()
	SimAI._replan_city_projects(sim)
	for c in sim.active_cities():
		if c.queue.is_empty():
			continue
		var now := "%s:%s" % [str(c.queue[0]["kind"]), str(c.queue[0]["id"])]
		if before.has(c.id) and str(before[c.id]) != now:
			_act(1)
			_line("production", "auto.production.replan", {"city": c.name, "city_id": c.id, "item": _item_name(str(c.queue[0]["kind"]), str(c.queue[0]["id"])), "item_id": str(c.queue[0]["id"])}, {"kind": "city", "id": c.id})


func _reslot() -> void:
	var before: Array = sim.state.policies.map(func(p): return str(p["id"]))
	SimAI._maybe_reslot(sim)
	for i in range(sim.state.policies.size()):
		var pid := str(sim.state.policies[i]["id"])
		if i < before.size() and pid != str(before[i]) and pid != "":
			_act(1)
			_line("policies", "auto.policies.reslot", {"item": str(sim.db.policies.get(pid, {}).get("name", pid)), "item_id": pid, "slot": i}, {"kind": "policy", "id": pid})


func _purchases() -> void:
	var bought := []
	var cb := func(cid, kind, item): bought.append([int(cid), str(kind), str(item)])
	var g0: float = sim.state.gold
	sim.production_completed.connect(cb)
	SimAI._purchases(sim)
	sim.production_completed.disconnect(cb)
	for b in bought:
		var c = sim.city_by_id(int(b[0]))
		_act(1)
		_line("budget", "auto.budget.purchase", {"item": _item_name(str(b[1]), str(b[2])), "item_id": str(b[2]), "kind": str(b[1]), "city": c.name if c != null else "?", "city_id": int(b[0])}, {"kind": "city", "id": int(b[0])})
	if not bought.is_empty() and g0 - sim.state.gold >= 1.0:
		_line("budget", "auto.budget.spent", {"gold": int(round(g0 - sim.state.gold))}, {"kind": "panel", "id": "treasury"}, 0)


func _bonds() -> void:
	var d0: float = sim.econ.debt()
	SimAI._history_bonds(sim)
	var dd: float = sim.econ.debt() - d0
	if dd >= 1.0:
		_act(1)
		_line("budget", "auto.budget.loan", {"gold": int(round(dd))}, {"kind": "panel", "id": "treasury"})


func _mothballed_n() -> int:
	var n := 0
	for c in sim.active_cities():
		n += (sim.econ.mothballed(c) as Array).size()
	return n


func _policy_states() -> Dictionary:
	var out := {}
	for pc in sim.econ.policy_costs():
		out[str(pc["id"])] = str(pc["state"])
	return out


func _healthy_levers() -> void:
	var m0 := _mothballed_n()
	var p0 := _policy_states()
	SimAI.fiscal_levers_healthy(sim)
	var m1 := _mothballed_n()
	if m1 < m0:
		_act(1)
		_line("budget", "auto.budget.reopen", {"n": m0 - m1}, {"kind": "panel", "id": "treasury"})
	var p1 := _policy_states()
	for pid in p1:
		if str(p1[pid]) == "full" and p0.has(pid) and str(p0[pid]) != "full":
			_act(1)
			_line("budget", "auto.budget.restore", {"item": str(sim.db.policies.get(pid, {}).get("name", pid)), "item_id": pid}, {"kind": "policy", "id": pid})


# ================================================================== the Treasury in danger (player view; V4_DESIGN 2.3)

func _treasury_condition() -> bool:
	var key := "%d:%d" % [_turn(), int(round(sim.state.gold))]
	if str(_tcache.get("key", "")) == key and _tcache.get("state") == sim.state:
		return bool(_tcache["val"])
	var v: bool = SimAI.fiscal_danger(sim) or str(sim.get_fiscal_indicator().get("level", "ok")) == "danger"
	_tcache = {"key": key, "state": sim.state, "val": v}
	return v


func _treasury_due() -> bool:
	if not _any_auto() or sim.state.mode == "historical":
		return false
	var tr: Dictionary = S()["treasury"]
	if bool(tr.get("mandate", false)) or int(tr.get("answered", -99)) == _turn() or _turn() - int(tr.get("declined", -99)) < 4:
		return false
	return _treasury_condition()


func _levers_plan() -> Array:
	## What SimAI.fiscal_levers_danger would do now, in words (Finance's plan).
	var e = sim.econ
	var parts := []
	var gap: float = e.structural_gap()
	if gap > 0.0:
		var plan: Array = e.mothball_plan(gap * 1.1, 25)
		if not plan.is_empty():
			parts.append("mothball %d little-used buildings" % plan.size())
	if sim.state.gold < 0.0 and not e.next_privatisation().is_empty():
		parts.append("privatise %s" % str(e.next_privatisation().get("name", "a state company")))
	var fcl: String = sim.collapse.level_of("collapse_fiscal")
	if (sim.state.inflation >= 60.0 or fcl == "danger") and e.stabilisation_option()["available"]:
		parts.append("adopt %s" % str(e.stabilisation_option().get("name", "a stabilisation package")))
	if gap > 0.0:
		for pc in e.policy_costs():
			if str(pc["state"]) == "full":
				parts.append("halve %s" % str(sim.db.policies.get(str(pc["id"]), {}).get("name", pc["id"])))
				break
	return parts


func treasury_view() -> Dictionary:
	## {} or {level, title, text, options: [{id, label, consequence: [str], recommended, available}]}: the Treasury in danger.
	if not _treasury_due():
		return {}
	var fi: Dictionary = sim.get_fiscal_indicator()
	var level := str(fi.get("level", "warning"))
	if level in ["ok", "watch"]:
		level = "warning"
	var plan := _levers_plan()
	var hints: bool = sim.hints_enabled()
	var opts := []
	var plan_txt := ("Finance's plan: " + ", ".join(plan)) if not plan.is_empty() else "Finance's plan: watch the deficit and act as soon as running costs pass revenue"
	opts.append({"id": "finance_plan", "label": plan_txt, "recommended": hints, "available": true,
		"consequence": ["Now: running costs brought back towards revenue.", "Finance repeats the plan each quarter until the treasury is out of danger."]})
	var so: Dictionary = sim.econ.stabilisation_option()
	if bool(so.get("available", false)):
		opts.append({"id": "stabilise", "label": "Adopt %s" % str(so.get("name", "a stabilisation package")), "recommended": false, "available": true,
			"consequence": ["Now: inflation brought down and upkeep cut for 3 years.", "Now: Civic Trust falls in every city."]})
	var gs: float = sim.events.gold_scale()
	var room: float = sim.econ.borrow_room()
	var bamt := roundf(minf(maxf(140.0 * gs, sim.econ.structural_gap() * 6.0), room))
	if bamt >= 20.0 * gs:
		opts.append({"id": "borrow", "label": "Borrow abroad: +%d gold now" % int(bamt), "amount": bamt, "recommended": false, "available": true,
			"consequence": ["Now: +%d gold." % int(bamt), "For years: the loan is repaid with interest; the deficit stays."]})
	opts.append({"id": "hold", "label": "Not now", "recommended": false, "available": true,
		"consequence": ["Nothing changes now.", "Finance asks again in a year if the danger lasts."]})
	var why: Array = fi.get("why", [])
	var txt := "The Treasury is in danger: %s. Finance proposes a plan; borrowing only postpones the deficit." % (", ".join(why) if not why.is_empty() else "running costs and debt service are above revenue")
	return {"type": "treasury", "level": level, "title": "The Treasury in danger", "label": "TREASURY IN DANGER", "text": txt, "options": opts,
		"explain": "When running costs, debt service or inflation run away, the state can fail. Finance's plan is what a careful treasury does now."}


func choose_treasury(option_id: String) -> bool:
	## Answers the Treasury-in-danger view. "finance_plan" authorises Finance's emergency plan (run now, and again each
	## quarter while the danger lasts); "stabilise", "borrow" or "hold" (asked again in a year).
	if treasury_view().is_empty():
		return false
	var tr: Dictionary = S()["treasury"]
	var ok := true
	_busy = true
	match option_id:
		"finance_plan":
			tr["mandate"] = true
			tr["since"] = _turn()
			_with_style(_mstyle(), _run_levers)
		"stabilise":
			ok = sim.econ.stabilise()
			tr["declined"] = _turn()
		"borrow":
			var gs: float = sim.events.gold_scale()
			var amt := roundf(minf(maxf(140.0 * gs, sim.econ.structural_gap() * 6.0), sim.econ.borrow_room()))
			ok = amt >= 20.0 * gs and sim.econ.borrow(amt, "Borrow abroad") > 0.0
			tr["declined"] = _turn()
		"hold":
			tr["declined"] = _turn()
		_:
			ok = false
	_busy = false
	if ok:
		tr["answered"] = _turn()
		_tcache = {}
		settle()
	return ok


func _run_levers() -> int:
	var tr: Dictionary = S()["treasury"]
	tr["levers"] = _turn()
	var e = sim.econ
	var m0 := _mothballed_n()
	var p0 := _policy_states()
	var st0 := int(sim.state.counters.get("stabilised_turn", -999))
	var g0: float = sim.state.gold
	var pv0: Dictionary = e.next_privatisation()
	SimAI.fiscal_levers_danger(sim)
	var parts := []
	var m1 := _mothballed_n()
	if m1 > m0: parts.append("mothballed %d buildings" % (m1 - m0))
	var p1 := _policy_states()
	for pid in p1:
		if p0.has(pid) and str(p1[pid]) != str(p0[pid]):
			parts.append("%s %s" % [str(sim.db.policies.get(pid, {}).get("name", pid)), "suspended" if str(p1[pid]) == "suspend" or str(p1[pid]) == "suspended" else "at half strength"])
	if not pv0.is_empty() and str(e.next_privatisation().get("id", "")) != str(pv0.get("id", "")) and sim.state.gold > g0:
		parts.append("privatised %s" % str(pv0.get("name", "")))
	if int(sim.state.counters.get("stabilised_turn", -999)) != st0:
		parts.append("adopted the stabilisation package")
	if not parts.is_empty():
		_act(1)
		_line("budget", "auto.budget.levers", {"item": "; ".join(parts)}, {"kind": "panel", "id": "treasury"})
	return 0


func _treasury_quarter() -> void:
	var tr: Dictionary = S()["treasury"]
	if not bool(tr.get("mandate", false)):
		return
	if not SimAI.fiscal_danger(sim):
		tr["mandate"] = false
		_act(1)
		_line("budget", "auto.budget.plan_end", {}, {"kind": "panel", "id": "treasury"})
		return
	if int(tr.get("levers", -99)) != _turn():
		_run_levers()


# ================================================================== the player's queue

func _brief_due() -> bool:
	return _any_auto() and not bool(S().get("brief_asked", false)) and _turn() >= 2 and sim.state.mode != "historical"


func _brief_decision() -> Dictionary:
	var opts := []
	var descs := {"balanced": "The ministers follow the Treasury's Recommended picks: history's pace, no single priority.",
		"security": "Defence first: shelters, reserves and the readiness of the army (the security strategist's routine).",
		"prosperity": "Growth first: newcomers to the big cities, money banked for national programmes.",
		"peace": "Diplomacy first: delegations whenever the treasury allows.",
		"society": "Housing and trust first: every last transit-camp family housed, stuck cities replanned each year."}
	var names := {"balanced": "Balanced", "security": "Security", "prosperity": "Prosperity", "peace": "Peace", "society": "Society"}
	for b in BRIEFS:
		opts.append({"id": b, "label": names[b], "desc": descs[b], "default": b == "balanced",
			"consequence": [descs[b], "You can change the brief any time in the Cabinet Room."]})
	return {"type": "brief", "blocking": false, "label": "YOUR MINISTERS' BRIEF", "title": "What should your ministers put first?",
		"text": "Your ministers run the routine: production, research, civics, policy cards, units, the yearly immigration plan, appointments, the budget review, export routes and delegations. Tell them once what to put first.",
		"explain": "The brief changes only the ministers' routine choices; every story decision stays yours.", "options": opts, "current": brief()}


func player_decisions() -> Array:
	## The open decisions that are the player's, in the order of V4_DESIGN 2.4 (in Full control: every blocking decision,
	## in v3's DECISION_ORDER). Includes the casual layer's own items: "treasury" and "brief" (non-blocking).
	var b: Array = sim.blocking_decisions()
	var out := []
	if not _any_auto():
		for t in Sim.DECISION_ORDER:
			for d in b:
				if str(d["type"]) == t: out.append(d)
		return out
	var mine: Array = b.filter(func(d): return not auto_owned(d))
	var tv := treasury_view() if _treasury_slot() else {}
	var budget_open := false
	var prog := {}
	var ag_player := false
	for d in mine:
		match str(d["type"]):
			"state_budget": budget_open = true
			"programme": prog = d
			"agenda":
				if owner(d) == "":
					ag_player = true
	for t in PLAYER_ORDER:
		match t:
			"treasury":
				if not tv.is_empty() and not ag_player:
					var td := tv.duplicate(true)
					td["blocking"] = false
					out.append(td)
			"brief":
				if _brief_due() and (S()["seen"].has("brief") or _quarter_load(["brief"]) < 3):
					out.append(_brief_decision())
			_:
				for d in mine:
					if str(d["type"]) != t or owner(d) != "":
						continue
					var dd: Dictionary = d.duplicate()
					if t == "programme" and str(d.get("kind", "")) == "surplus":
						if budget_open:
							continue   # rule 1: the surplus is the second half of the budget card
						if int(S().get("budget_turn", -99)) == _turn():
							dd["merged"] = true
					if t == "state_budget" and not prog.is_empty() and str(prog.get("kind", "")) == "surplus" and owner(prog) == "":
						dd["surplus"] = prog
					if t == "agenda" and not tv.is_empty():
						dd["treasury"] = tv
					out.append(dd)
	for t in Sim.DECISION_ORDER:
		for d in mine:
			if str(d["type"]) == t and owner(d) != "":
				out.append(d)
	return out


func primary() -> Dictionary:
	## The one primary prompt: the first player decision, or End Turn with one sub-line.
	var pd := player_decisions()
	if not pd.is_empty():
		return pd[0]
	var t := _turn()
	var nxt := SimDB.date_label(t + 1) if t < Sim.last_playable_turn() else ""
	var hint := "Nothing needs you this quarter"
	var hk := "auto.end.quiet"
	var hargs := {}
	if sim.cabinet != null:
		var bt: int = sim.cabinet.next_budget_turn(t)
		if bt > t and bt - t <= 4:
			hint = "Next: the State Budget in %s" % SimDB.date_label(bt)
			hk = "auto.end.next_budget"
			hargs = {"date": SimDB.date_label(bt), "turn": bt}
	return {"type": "end_turn", "blocking": false, "label": ("END TURN: %s" % nxt) if nxt != "" else "END TURN", "next_date": nxt,
		"next_hint": hint, "key": "auto.end.label", "args": {"date": nxt}, "hint_key": hk, "hint_args": hargs}


func quiet() -> bool:
	return player_decisions().is_empty()


# ================================================================== the ministers' report

func _act(n: int) -> void:
	if n <= 0:
		return
	var s: Dictionary = S()["stats"]
	s["actions"] = int(s.get("actions", 0)) + n


func _domain(id: String) -> Dictionary:
	for d in DOMAINS:
		if str(d["id"]) == id: return d
	return {}


func _render(domain: String, key: String, args: Dictionary, prefix := "") -> Dictionary:
	## {key, short, text}: the singular template when the count is 1, and the line's prefix (the ministry's short name, or
	## the prefix given: a unit begun in a city reads "Defence: ...", not "Construction: ...").
	var k := key.trim_suffix(".one")
	if args.has("n") and int(args["n"]) == 1 and TEMPLATES.has(k + ".one"):
		k += ".one"
	var sh := prefix if prefix != "" else str(_domain(domain).get("short", domain))
	return {"key": k, "short": sh, "text": "%s: %s" % [sh, str(TEMPLATES.get(k, k)).format(args)]}


func _line(domain: String, key: String, args: Dictionary, ref := {}, n := 1, prefix := "") -> void:
	var a := S()
	var lt := _turn() - (1 if _at_start else 0)
	var rep: Array = a["report"]
	if rep.is_empty() or int(rep[-1].get("turn", -1)) != lt:
		rep.append({"turn": lt, "lines": []})
		while rep.size() > REPORT_KEEP:
			rep.pop_front()
	var base := key.trim_suffix(".one")
	if base in MERGE_KEYS:
		for old in rep[-1]["lines"]:
			if str(old.get("domain", "")) == domain and str(old.get("key", "")).trim_suffix(".one") == base:
				var oa: Dictionary = old["args"]
				if base == "auto.budget.spent":
					oa["gold"] = int(oa.get("gold", 0)) + int(args.get("gold", 0))
				else:
					oa["n"] = int(oa.get("n", 0)) + int(args.get("n", 0))
				var r0 := _render(domain, base, oa, str(old.get("short", "")))
				old["key"] = r0["key"]
				old["text"] = r0["text"]
				old["n"] = int(old.get("n", 0)) + n
				var s0: Dictionary = a["stats"]
				s0["covered"] = int(s0.get("covered", 0)) + n
				return
	var r := _render(domain, key, args, prefix)
	var line := {"domain": domain, "key": str(r["key"]), "args": args, "text": str(r["text"]), "short": str(r["short"]), "ref": ref, "n": n, "turn": lt}
	rep[-1]["lines"].append(line)
	var last: Dictionary = a["last"]
	var ld: Dictionary = last.get(domain, {})
	if int(ld.get("turn", -99)) != lt:
		ld = {"turn": lt, "lines": []}
	var ll: Array = ld["lines"]
	ll.append(line)
	if ll.size() > LAST_KEEP:
		ld["lines"] = ll.slice(ll.size() - LAST_KEEP)
	last[domain] = ld
	var s: Dictionary = a["stats"]
	s["covered"] = int(s.get("covered", 0)) + n
	s["lines"] = int(s.get("lines", 0)) + 1


func report(turn := -1) -> Dictionary:
	## {turn, lines: [{domain, key, args, text, ref: {kind, id}, n}]}. turn -1 = the quarter that just ended (the turn-start
	## actions of this quarter are included there); report(sim.state.turn) = what the ministers did so far this quarter.
	var t := turn if turn >= 0 else _turn() - 1
	if not _has():
		return {"turn": t, "lines": []}
	for r in S()["report"]:
		if int(r.get("turn", -1)) == t:
			var lines: Array = (r["lines"] as Array).duplicate(true)
			for l in lines:
				var args: Dictionary = l.get("args", {})
				for k in args:   # a loaded save stores numbers as floats: keep whole numbers whole for format()
					if typeof(args[k]) == TYPE_FLOAT and is_equal_approx(float(args[k]), roundf(float(args[k]))):
						args[k] = int(roundf(float(args[k])))
			return {"turn": t, "lines": lines}
	return {"turn": t, "lines": []}


func stats() -> Dictionary:
	## {actions, covered, lines}: every automatic action is counted where it happens; covered = actions named by a line.
	if not _has():
		return {"actions": 0, "covered": 0, "lines": 0}
	return (S()["stats"] as Dictionary).duplicate()


func minister_name(domain: String) -> String:
	var d := _domain(domain)
	var m := str(d.get("minister", ""))
	if m == "absorption" and SimDB.year_of(_turn()) < 1968:
		return "The Jewish Agency (absorption)"
	if m != "" and sim.cabinet != null:
		var t: String = sim.cabinet.minister_title(m)
		if t != "" and t != m:
			return t
	return str(d.get("label", domain))


func domain_view() -> Array:
	## [{id, name, short, minister_name, desc, auto, last: [line], pending_manual: n}] for the Cabinet Room and Settings.
	var out := []
	var pend := {}
	if _has():
		for d in sim.blocking_decisions():
			var o := owner(d)
			if o != "" and not is_auto(o): pend[o] = int(pend.get(o, 0)) + 1
	for d in DOMAINS:
		var id := str(d["id"])
		var last: Array = []
		if _has():
			last = (S()["last"].get(id, {}).get("lines", []) as Array).duplicate(true)
		out.append({"id": id, "name": str(d["name"]), "short": str(d["short"]), "minister_name": minister_name(id), "desc": str(d["desc"]),
			"types": d["types"], "auto": is_auto(id), "last": last, "pending_manual": int(pend.get(id, 0))})
	return out


# ================================================================== the story card (V4_DESIGN 2.3)

func _options_of(d: Dictionary) -> Array:
	if d.has("choices"):
		return d["choices"]
	return d.get("options", [])


func _opt_label(o: Dictionary, i: int) -> String:
	for k in ["label", "name", "title"]:
		if str(o.get(k, "")) != "":
			return str(o[k])
	return str(o.get("id", i))


func _rec_index(d: Dictionary) -> int:
	## The Recommended option (same pickers as resolve_recommended), with the style forced to plain Recommended.
	## v4 fix round (veteran M2): never an option that cannot be taken now (a programme the treasury cannot start falls
	## back to "not now" / "hold", which is what resolve_recommended does when the launch is refused).
	var i := int(_with_style("recommended", func(): return _rec_index_now(d)))
	var opts := _options_of(d)
	if i < 0 or i >= opts.size() or typeof(opts[i]) != TYPE_DICTIONARY or _unavailable_reason(d, opts[i]) == "":
		return i
	if str(d.get("type", "")) == "programme":
		for j in range(opts.size()):
			if str(opts[j].get("id", "")) in HOLD_IDS: return j
	for j in range(opts.size()):
		if typeof(opts[j]) == TYPE_DICTIONARY and bool(opts[j].get("default", false)) and _unavailable_reason(d, opts[j]) == "": return j
	for j in range(opts.size()):
		if typeof(opts[j]) == TYPE_DICTIONARY and _unavailable_reason(d, opts[j]) == "": return j
	return i


func _rec_index_now(d: Dictionary) -> int:
	var opts := _options_of(d)
	match str(d.get("type", "")):
		"fork":
			return _index_of_id(opts, SimAI.pick_fork(sim, d))
		"event_choice":
			return SimAI.pick_event_choice(sim, sim.db.event_by_id.get(d.get("event", ""), null))
		"crisis_response":
			return SimAI.pick_crisis_response(sim, opts)
		"coalition":
			return SimAI.pick_option(sim, opts, true)
		"diplomacy":
			return sim.diplo.ai_pick("recommended")
		"programme":
			return SimAI.pick_programme(sim, d)
		"dedication":
			return _index_of_id(opts, SimAI.pick_dedication(sim))
		"immigration":
			var io := SimAI.pick_immigration(sim)
			var allowed: Array = sim.econ.immigration_options_allowed()
			if not (io in allowed) and not allowed.is_empty():
				io = str(allowed[0])
			return _index_of_id(opts, io)
		"agenda":
			return SimAI.pick_agenda(sim)
		"budget_review":
			return SimAI.pick_option(sim, opts, false, ["supplement", "keep"])
		"treasury", "brief":
			return 0
	for i in range(opts.size()):
		if typeof(opts[i]) == TYPE_DICTIONARY and opts[i].get("default", false): return i
	return 0 if not opts.is_empty() else -1


func _history_index(d: Dictionary) -> int:
	## History's own answer (kept among the visible options so the historical corridor stays one click away).
	var opts := _options_of(d)
	var t := str(d.get("type", ""))
	match t:
		"fork", "event_choice", "coalition":
			for i in range(opts.size()):
				if opts[i].get("historical", false): return i
			return -1
		"immigration":
			return _index_of_id(opts, str(d.get("historical", "")))
		"diplomacy":
			return sim.diplo.ai_pick("historical")
		"crisis_response":
			return int(_with_style("historical", func(): return SimAI.pick_crisis_response(sim, opts)))
		"programme":
			return int(_with_style("historical", func(): return SimAI.pick_programme(sim, d)))
		"dedication":
			return int(_with_style("historical", func(): return _index_of_id(opts, SimAI.pick_dedication(sim))))
		"agenda":
			return int(_with_style("historical", func(): return SimAI.pick_agenda(sim)))
	return -1


func _index_of_id(opts: Array, id: String) -> int:
	for i in range(opts.size()):
		if typeof(opts[i]) == TYPE_DICTIONARY and str(opts[i].get("id", "")) == id: return i
	return -1


func recommend(d: Dictionary) -> Dictionary:
	## {index, id, why, why_stat, why_kind}: the Cabinet Secretary's recommendation (plain Recommended, whatever the
	## brief), never an option that cannot be taken now; {} on Historian.
	if not sim.hints_enabled():
		return {}
	var i := _rec_index(d)
	var opts := _options_of(d)
	if i < 0 or i >= opts.size():
		return {}
	var o: Dictionary = opts[i]
	var wi := _why_info(d, i, _visible(d, opts, i, _history_index(d)))
	return {"index": i, "id": str(o.get("id", o.get("index", i))), "why": str(wi["why"]), "why_stat": str(wi["why_stat"]), "why_kind": str(wi["why_kind"])}


# v4 fix round (veteran M3): the reason for the Recommended pick says WHY in plain words and agrees with the numbers on the
# card. why_kind "best": the pick leads every other option shown on why_stat (sim_test --casual checks it on every card);
# "tradeoff": it costs something now and gains for years (both are on its lines); "cheapest"; "judgement": the picker
# weighs more than the two lines show (every term is under Details).
const JUDGEMENT := {"fork": "the largest gain overall when every lasting term is added up (all of them are under Details)",
	"event_choice": "the largest gain overall when every effect is added up (all of them are under Details)",
	"diplomacy": "the largest gain overall for Israel's standing and treaties (every term is under Details)",
	"programme": "the best value for its cost that the treasury can carry",
	"dedication": "the dedication that suits this era best",
	"coalition": "the Cabinet Secretary's choice for a working majority (the partners' demands are under Details)",
	"agenda": "what a careful treasury does with this item (the figures are under Details)",
	"immigration": "it weighs the cost against housing, readiness, food and water (the figures are under Details)",
	"crisis_response": "the Cabinet Secretary's reading of the fighting (the full forecast is under Details)"}


func _why(d: Dictionary, o: Dictionary) -> String:
	## (kept for callers of the v4 API) the reason for option o when it is the pick.
	var opts := _options_of(d)
	var i := opts.find(o)
	if i < 0:
		return str(JUDGEMENT.get(str(d.get("type", "")), "the Cabinet Secretary's advice (see Details)"))
	return str(_why_info(d, i, _visible(d, opts, i, _history_index(d)))["why"])


func _why_info(d: Dictionary, rec: int, vis: Array) -> Dictionary:
	var t := str(d.get("type", ""))
	var opts := _options_of(d)
	var o: Dictionary = opts[rec] if typeof(opts[rec]) == TYPE_DICTIONARY else {}
	var oid := str(o.get("id", ""))
	var judge := {"why": str(JUDGEMENT.get(t, "the Cabinet Secretary's advice (see Details)")), "why_stat": "", "why_kind": "judgement"}
	if t == "state_budget" and str(d.get("recommended_why", "")) != "":
		return {"why": str(d["recommended_why"]), "why_stat": "", "why_kind": "judgement"}
	if t == "treasury":
		return {"why": "closes the gap without new debt", "why_stat": "", "why_kind": "judgement"}
	if t == "brief":
		return {"why": "keeps the ministers on history's pace; every story decision stays yours", "why_stat": "", "why_kind": "judgement"}
	if t == "programme":
		if oid in HOLD_IDS:
			for x in opts:
				if typeof(x) == TYPE_DICTIONARY and _unavailable_reason(d, x).contains("gold"):
					return {"why": "the treasury cannot pay a first instalment now: keep the money in hand", "why_stat": "", "why_kind": "judgement"}
			return {"why": "keeps the reserve in hand for emergencies and purchases", "why_stat": "", "why_kind": "judgement"}
		if oid == "repay_debt":
			return {"why": "public debt is above a year of revenue: repaying it early cuts the interest", "why_stat": "", "why_kind": "judgement"}
	var war: bool = t == "crisis_response" and bool(sim.state.crisis_decision.get("war_turn", false))
	if war and oid == "mobilize":
		return {"why": "it costs unity now, but every front fights stronger for the whole war", "why_stat": "war_strength", "why_kind": "best"}
	var sv := {}
	for i in vis:
		sv[i] = _shown_values(d, opts[i] if typeof(opts[i]) == TYPE_DICTIONARY else {})
	var mine: Dictionary = sv.get(rec, {})
	if t in ["crisis_response", "immigration"]:
		# lower-is-better figures: the pick must lead (or tie) every other option shown, and beat at least one
		var texts := {"enemy_hit": "hits the most enemy formations of the options shown", "towns": "the fewest towns hit of the options shown",
			"camps": "leaves the fewest people in temporary housing of the options shown", "gold": "the cheapest of the options shown",
			"cost": "the lowest cost of the options shown"}
		for stat in ["enemy_hit", "towns", "camps", "gold", "cost"]:
			if not mine.has(stat) or (stat == "enemy_hit" and float(mine[stat]) <= 0.0):
				continue
			var lead := true
			var beats := false
			for i in vis:
				if i == rec: continue
				var ov := float(sv[i].get(stat, 0.0))
				if ov > float(mine[stat]) + 1e-6: lead = false
				if ov < float(mine[stat]) - 1e-6: beats = true
			if lead and beats:
				return {"why": str(texts[stat]), "why_stat": stat, "why_kind": "best"}
		return judge
	# the stat where the pick leads the other options shown by the most
	var best_stat := ""
	var best_adv := 0.0
	for stat in mine:
		var v := float(mine[stat])
		if v <= 0.0:
			continue
		var mx := 0.0
		var first := true
		for i in vis:
			if i == rec: continue
			var ov := float(sv[i].get(stat, 0.0))
			mx = ov if first else maxf(mx, ov)
			first = false
		var adv := v - (mx if not first else 0.0)
		if adv > best_adv + 1e-6:
			best_adv = adv; best_stat = stat
	if best_stat != "":
		var nm := str(STAT_NAMES.get(best_stat, best_stat.capitalize()))
		var tr := str(STAT_TRACK.get(best_stat, ""))
		var txt := ("best for %s, where you trail history" % nm) if tr != "" and tr == _trailing_track() else ("best for %s" % nm)
		return {"why": txt, "why_stat": best_stat, "why_kind": "best"}
	var ps := _pick_shown(o)
	var pn: Dictionary = ps["now"]
	var pl: Dictionary = ps["last"]
	if not pn.is_empty() and not pl.is_empty() and not bool(pn["good"]) and bool(pl["good"]):
		return {"why": "it costs %s now, but adds %s for years" % [_stat_name(pn), _stat_name(pl)], "why_stat": "", "why_kind": "tradeoff"}
	# every figure shown is a cost: the pick costs least
	var tot := func(x: Dictionary) -> float:
		var s := 0.0
		for k in x: s += float(x[k])
		return s
	var all_cost := not mine.is_empty()
	for k in mine:
		if float(mine[k]) > 0.0: all_cost = false
	if all_cost and vis.size() > 1:
		var least := true
		var beats := false
		for i in vis:
			if i == rec: continue
			var ot: float = tot.call(sv[i])
			if ot > float(tot.call(mine)) + 1e-6: least = false
			if ot < float(tot.call(mine)) - 1e-6: beats = true
		if least and beats:
			return {"why": "the smallest cost of the options shown", "why_stat": "", "why_kind": "cheapest"}
	return judge


func _stat_name(e: Dictionary) -> String:
	return str(STAT_NAMES.get(str(e["stat"]), str(e["stat"]).capitalize()))


func _shown_values(d: Dictionary, o: Dictionary) -> Dictionary:
	## {stat: value} of the figures an option's card lines show, signed so that higher is better (v4 fix round, M3).
	var t := str(d.get("type", ""))
	var out := {}
	if t == "crisis_response":
		var pv = o.get("preview", {})
		var id := str(o.get("id", ""))
		var war := bool(sim.state.crisis_decision.get("war_turn", false))
		if typeof(pv) == TYPE_DICTIONARY and (pv as Dictionary).has("expected_town_strikes") and (id != "mobilize" or war) and _crisis_shows_preview(id, war):
			out["towns"] = -roundf(float(pv["expected_town_strikes"]))
			if id != "mobilize":
				out["enemy_hit"] = roundf(float(pv.get("expected_suppressed", 0.0)) + float(pv.get("expected_destroyed", 0.0)))
		if war and id == "mobilize":
			out["war_strength"] = 2.0
		var c = o.get("cost", {})
		if typeof(c) == TYPE_DICTIONARY:
			out["cost"] = -(float(c.get("gold", 0.0)) / 25.0 + float(c.get("production_pct", 0.0)) / 10.0 + float(c.get("cohesion", 0.0)) / 10.0)
		return out
	if t == "immigration":
		out["gold"] = float(o.get("gold", 0)) / 25.0
		var cr := int(o.get("camp_residents", 0))
		out["camps"] = -float(_about(cr)) / 1000.0 if cr >= CAMPS_SHOWN else 0.0
		return out
	var ps := _pick_shown(o)
	for k in ["now", "last"]:
		var e: Dictionary = ps[k]
		if e.is_empty():
			continue
		var s := str(e["stat"])
		out[s] = float(out.get(s, 0.0)) + _norm(e) * (1.0 if bool(e["good"]) else -1.0)
	return out


func _unavailable_reason(d: Dictionary, o: Dictionary) -> String:
	## "" when the option can be taken now, else why not in plain words, e.g. "needs 153 gold now (the treasury has 147)"
	## (v4 fix round, veteran M2: the treasury is checked live, not when the card was drawn up).
	var t := str(d.get("type", ""))
	var gold: float = sim.state.gold
	if t == "programme" and sim.endgame != null:
		var id := str(o.get("id", ""))
		if id.begins_with("launch:") or id.begins_with("expand:"):
			var parts := id.split(":")
			var r := ""
			if id.begins_with("launch:") and parts.size() >= 3:
				r = sim.endgame.level_reason(parts[1], int(parts[2]))
			elif parts.size() >= 2:
				r = sim.endgame.expand_reason(parts[1])
			if r != "":
				return r
			# the live cost (it falls as history's date nears, and with an era-goal discount), as launch() checks it
			var inst := float(o.get("instalment", 0.0))
			if id.begins_with("launch:") and parts.size() >= 3:
				inst = float(sim.endgame.level_cost(parts[1], int(parts[2]))) / maxf(1.0, float(maxi(1, int(sim.endgame.level_def(parts[1], int(parts[2])).get("turns", 4)))))
			elif parts.size() >= 2:
				inst = float(sim.endgame.expand_cost(parts[1])) / maxf(1.0, float(maxi(1, int(sim.endgame.expand_def(parts[1]).get("turns", 4)))))
			if not sim.endgame._historical() and gold < inst:   # (history's own player launches on its dates, as launch() allows)
				return "needs %d gold now for the first instalment (the treasury has %d)" % [int(ceil(inst)), int(floor(maxf(0.0, gold)))]
		return ""
	if t == "crisis_response" and not bool(o.get("available", true)):
		var c = o.get("cost", {})
		if typeof(c) == TYPE_DICTIONARY:
			if float(c.get("gold", 0.0)) > gold:
				return "needs %d gold (the treasury has %d)" % [int(ceil(float(c["gold"]))), int(floor(maxf(0.0, gold)))]
			if float(c.get("cohesion", 0.0)) > sim.state.cohesion:
				return "needs %d Cohesion (you have %d)" % [int(ceil(float(c["cohesion"]))), int(floor(sim.state.cohesion))]
		return "not possible in this war"
	if typeof(o) == TYPE_DICTIONARY and not bool(o.get("available", true)):
		for k in ["reason", "unavailable", "why_not"]:
			if str(o.get(k, "")) != "":
				return str(o[k])
		return "not available now"
	return ""


func why_refused(d: Dictionary, index: int) -> String:
	## Why option `index` of decision d cannot be taken now, in one plain sentence; "" when it can.
	var opts := _options_of(d)
	if index < 0 or index >= opts.size():
		return "That option is no longer on the table."
	var r := _unavailable_reason(d, opts[index] if typeof(opts[index]) == TYPE_DICTIONARY else {})
	return (r.substr(0, 1).to_upper() + r.substr(1) + ".") if r != "" else ""


func refusal_text(d: Dictionary, index: int) -> String:
	## The feedback for a click the sim refused: the specific reason, or a plain fallback (never empty).
	var r := why_refused(d, index)
	if r != "":
		return r
	return "This option cannot be taken now. Choose another one, or End Turn to let the quarter pass."


func _trailing_track() -> String:
	var worst := ""
	var wv := 1.0
	var sc: Dictionary = sim.score.current()
	for tr in sc.get("tracks", []):
		var r := float(tr.get("ratio", 1.0))
		if r < wv:
			wv = r; worst = str(tr.get("id", ""))
	return worst


func _effects_of(o: Dictionary) -> Array:
	## [{stat, amount, label, lasting, span, good}] from any of the option shapes (effects_struct, effects, effects_list).
	var src: Array = []
	if o.get("effects_struct") is Array:
		src = o["effects_struct"]
	elif o.get("effects") is Array:
		src = o["effects"]
	elif o.get("effects_list") is Array:
		src = o["effects_list"]
	var out := []
	for e in src:
		if typeof(e) != TYPE_DICTIONARY or not e.has("amount"):
			continue
		var amt := float(e["amount"])
		if amt == 0.0:
			continue
		var when := str(e.get("when", ""))
		var span := ""
		var lasting := false
		if e.has("from") or e.has("until"):
			lasting = true
			var y0 := str(e.get("from", "")).substr(0, 4)
			var y1 := str(e.get("until", "")).substr(0, 4)
			var ey := SimDB.end_year()
			if y1.is_valid_int() and int(y1) > ey: y1 = str(ey)
			span = y0 if y0 == y1 or y1 == "" else ("%s-%s" % [y0, y1] if y0 != "" else "to " + y1)
		elif when != "" and when != "now":
			lasting = true
			span = when
		out.append({"stat": str(e.get("stat", e.get("type", ""))), "amount": amt, "label": str(e.get("label", "")), "unit": str(e.get("unit", "")),
			"lasting": lasting, "span": span, "good": bool(e.get("good", amt > 0.0))})
	return out


func _norm(e: Dictionary) -> float:
	var s := str(e["stat"])
	var sc := float(STAT_SCALE.get(s, 1.0))
	if str(e.get("unit", "")).begins_with("%"):
		sc = 5.0
	return absf(float(e["amount"])) / maxf(0.01, sc)


func _fmt_effect(e: Dictionary) -> String:
	var lbl := str(e.get("label", ""))
	if lbl != "" and (lbl.begins_with("+") or lbl.begins_with("-") or lbl.left(1).is_valid_int()):
		# the line already says "Now:" (v4 fix round: no "Now: -13 Gold now.")
		for suf in [" now", " this quarter"]:
			if lbl.to_lower().ends_with(suf):
				lbl = lbl.substr(0, lbl.length() - suf.length())
		return lbl
	var a := float(e["amount"])
	var num := ("%+d" % int(round(a))) if absf(a - round(a)) < 0.05 else ("%+.1f" % a)
	var unit := str(e.get("unit", ""))
	var nm := str(STAT_NAMES.get(str(e["stat"]), str(e["stat"]).capitalize()))
	if unit.begins_with("%"):
		num += "%"
	var s := "%s %s" % [num, nm]
	if lbl != "" and lbl.length() <= 48:
		s += " (%s)" % lbl
	return s


static func _first_sentence(s: String, max_len := 140) -> String:
	var t := s.strip_edges()
	var i := t.find(". ")
	if i > 0:
		t = t.substr(0, i + 1)
	if t.length() > max_len:
		t = t.substr(0, max_len - 3).strip_edges() + "..."
	return t


func _cost_text(cost) -> String:
	if typeof(cost) != TYPE_DICTIONARY or (cost as Dictionary).is_empty():
		return "No cost now."
	var parts := []
	for k in cost:
		var v := int(round(float(cost[k]))) if typeof(cost[k]) in [TYPE_INT, TYPE_FLOAT] else 0
		if typeof(cost[k]) in [TYPE_INT, TYPE_FLOAT] and v == 0:
			continue   # v4 fix round: never "Now: -0 gold."
		match str(k):
			"production_pct": parts.append("-%d%% production this quarter" % v)
			"gold": parts.append("-%d gold" % v)
			"cohesion": parts.append("-%d Cohesion" % v)
			_: parts.append("%s %s" % [str(cost[k]), str(k)])
	if parts.is_empty():
		return "No cost now."
	return "Now: " + ", ".join(parts) + "."


const CAMPS_SHOWN := 500   # people left in camps or temporary housing from which the immigration card says so (M1)


static func _cap(s: String) -> String:
	return s.substr(0, 1).to_upper() + s.substr(1) if s != "" else s


static func _thousands(n: int) -> String:
	var s := str(absi(n))
	var out := ""
	while s.length() > 3:
		out = "," + s.substr(s.length() - 3) + out
		s = s.substr(0, s.length() - 3)
	return ("-" if n < 0 else "") + s + out


static func _about(n: int) -> int:
	## A plain round figure: 38,376 -> 38,000; 4,860 -> 4,900; 730 -> 730.
	var a := absi(n)
	var step := 1000 if a >= 10000 else (100 if a >= 1000 else 10)
	return int(round(float(n) / step)) * step


static func _towns_phrase(x: float) -> String:
	var n := int(round(x))
	if n <= 0: return "no towns hit"
	return "about 1 town hit" if n == 1 else "about %d towns hit" % n


static func _hits_phrase(x: float) -> String:
	var n := int(round(x))
	if n <= 0: return "no enemy formation hit"
	return "about 1 enemy formation hit" if n == 1 else "about %d enemy formations hit" % n


static func _crisis_shows_preview(id: String, war: bool) -> bool:
	## The war-turn options whose first line is the quarter's forecast (towns hit, enemy formations hit).
	return war and (id.begins_with("front:") or id.begins_with("dfront:") or id.begins_with("shield:") or id.begins_with("strike:") \
		or id in ["full_mobilization", "economy_first", "mobilize"])


func _crisis_consequence(_d: Dictionary, o: Dictionary) -> Array:
	## v4 fix round (new player N4, veteran M3): plain figures ("about 5 towns hit") and what mobilisation really buys.
	var id := str(o.get("id", ""))
	var pv = o.get("preview", {})
	var cost := _cost_text(o.get("cost", {}))
	var war := bool(sim.state.crisis_decision.get("war_turn", false))
	var has_pv := typeof(pv) == TYPE_DICTIONARY and (pv as Dictionary).has("expected_town_strikes")
	if war and id == "mobilize":
		var what := "uprising" if str(o.get("label", "")).begins_with("Call up") else "war"
		var l2 := cost
		if has_pv:
			l2 = cost.trim_suffix(".") + ". This quarter: " + _towns_phrase(float(pv["expected_town_strikes"])) + "."
		return ["For the whole %s: reserve brigades at every front and +2 strength for every unit." % what, l2]
	if has_pv and _crisis_shows_preview(id, war):
		var hits := float(pv.get("expected_suppressed", 0.0)) + float(pv.get("expected_destroyed", 0.0))
		return [_cap("%s; %s." % [_towns_phrase(float(pv["expected_town_strikes"])), _hits_phrase(hits)]), cost]
	var out := []
	if str(o.get("desc", "")) != "":
		out.append(_first_sentence(str(o["desc"])))
	elif has_pv:
		out.append(_cap(_towns_phrase(float(pv["expected_town_strikes"])) + " this quarter."))
	out.append(cost)
	return out.slice(0, 2)


func _immigration_consequence(o: Dictionary) -> Array:
	## v4 fix round (veteran M1): the card names what the transit camps cost, not only the gold.
	var g := int(o.get("gold", 0))
	var cr := int(o.get("camp_residents", 0))
	var vid := str(o.get("id", ""))
	var where := "temporary housing"
	match vid:
		"camps": where = "transit camps (ma'abarot)"
		"absorption_sites": where = "absorption centres and caravan sites"
		"caravans": where = "caravan sites"
	var l1 := "Now: %s" % ("%+d gold" % g if g != 0 else "no cost")
	if cr >= CAMPS_SHOWN:
		l1 += "; about %s people left in %s." % [_thousands(_about(cr)), where]
		return [l1, "For years: crowded camps mean fewer amenities, so Civic Trust and growth fall in those towns until homes are built."]
	l1 += "."
	var ps := _pick_shown(o)
	var pl: Dictionary = ps["last"]
	if not pl.is_empty():
		return [l1, "For a year: %s." % _fmt_effect(pl)]
	var eff := str(o.get("effects", ""))
	var i := eff.find("; ")
	var rest := eff.substr(i + 2) if i >= 0 else ""
	if rest != "" and not rest.contains("share"):
		return [l1, _cap(rest) + "."]
	return [l1]


func _rounds_to_zero(e: Dictionary) -> bool:
	var lbl := str(e.get("label", ""))
	return absf(float(e["amount"])) < 0.05 or lbl.begins_with("-0 ") or lbl.begins_with("+0 ")


func _pick_shown(o: Dictionary) -> Dictionary:
	## {now, last}: the two effects a card shows, the largest "now" effect and the largest lasting term.
	var now := {}
	var last := {}
	for e in _effects_of(o):
		if _rounds_to_zero(e):
			continue
		if bool(e["lasting"]):
			if last.is_empty() or _norm(e) > _norm(last): last = e
		else:
			if now.is_empty() or _norm(e) > _norm(now): now = e
	return {"now": now, "last": last}


func _consequence(d: Dictionary, o: Dictionary) -> Array:
	## At most two plain lines: the largest "now" effect and the largest lasting term, with sign and span.
	var t := str(d.get("type", ""))
	if o.get("consequence") is Array:
		return (o["consequence"] as Array).slice(0, 2)
	if t == "crisis_response":
		return _crisis_consequence(d, o)
	if t == "immigration":
		return _immigration_consequence(o)
	if t == "dedication":
		return [str(o.get("goal", "")), "Golden age: " + str(o.get("golden", ""))]
	var ps := _pick_shown(o)
	var now: Dictionary = ps["now"]
	var last: Dictionary = ps["last"]
	var lines := []
	if not now.is_empty():
		lines.append("Now: %s." % _fmt_effect(now))
	if not last.is_empty():
		lines.append("For years: %s%s." % [_fmt_effect(last), (" (%s)" % str(last["span"])) if str(last["span"]) != "" else ""])
	if lines.is_empty():
		var et = o.get("effects_text", [])
		if et is Array and not (et as Array).is_empty():
			lines.append(str(et[0]))
		elif typeof(o.get("effects")) == TYPE_STRING and str(o["effects"]) != "":
			lines.append(str(o["effects"]))
		elif str(o.get("desc", "")) != "":
			lines.append(_first_sentence(str(o["desc"])))
		elif str(o.get("text", "")) != "":
			lines.append(_first_sentence(str(o["text"])))
		else:
			lines.append("No change.")
	return lines.slice(0, 2)


func _signature(o: Dictionary) -> Dictionary:
	var v := {}
	for e in _effects_of(o):
		var s := str(e["stat"])
		v[s] = float(v.get(s, 0.0)) + signf(float(e["amount"])) * minf(3.0, _norm(e))
	return v


func _distance(a: Dictionary, b: Dictionary) -> float:
	var sa := _signature(a)
	var sb := _signature(b)
	var dsum := 0.0
	for k in sa: dsum += absf(float(sa[k]) - float(sb.get(k, 0.0)))
	for k in sb:
		if not sa.has(k): dsum += absf(float(sb[k]))
	if str(a.get("stance", a.get("id", "x"))) != str(b.get("stance", b.get("id", "y"))): dsum += 0.25
	return dsum


func _visible(d: Dictionary, opts: Array, rec: int, hist: int) -> Array:
	var n := opts.size()
	var vis := []
	if rec >= 0 and rec < n:
		vis.append(rec)
	var t := str(d.get("type", ""))
	var avail := func(i): return typeof(opts[i]) == TYPE_DICTIONARY and _unavailable_reason(d, opts[i]) == ""
	if n <= 3:
		for i in range(n):
			if not (i in vis): vis.append(i)
	else:
		match t:
			"crisis_response":
				# the Recommended front, the next most threatened front, and standing down
				var bf := -1; var bn := -1.0
				for i in range(n):
					var oid := str(opts[i].get("id", ""))
					if i in vis or not avail.call(i) or not (oid.begins_with("front:") or oid.begins_with("dfront:")): continue
					var pvw = opts[i].get("preview", {})
					var thr := float(opts[i].get("n", 0)) + (float(pvw.get("expected_town_strikes", 0.0)) if typeof(pvw) == TYPE_DICTIONARY else 0.0)
					if thr > bn: bn = thr; bf = i
				if bf >= 0: vis.append(bf)
				for i in range(n):
					if str(opts[i].get("id", "")) in STAND_DOWN_IDS and not (i in vis):
						vis.append(i)
						break
			"programme":
				for want in ["repay_debt", "hold", "defer"]:
					for i in range(n):
						if str(opts[i].get("id", "")) == want and not (i in vis) and vis.size() < 3: vis.append(i)
			"state_budget":
				var last := str(sim.state.budget.get("preset", ""))
				for want in ["balanced", last]:
					for i in range(n):
						if str(opts[i].get("id", "")) == want and not (i in vis) and vis.size() < 3: vis.append(i)
			"coalition":
				for i in range(n):
					if opts[i].get("historical", false) and not (i in vis) and vis.size() < 3: vis.append(i)
				for i in range(n):
					if not opts[i].get("historical", false) and not (i in vis) and vis.size() < 3: vis.append(i)
		# the rest by how much they differ from the Recommended option
		if vis.size() < 3:
			var cand := []
			for i in range(n):
				if not (i in vis) and avail.call(i):
					cand.append([_distance(opts[i], opts[rec]) if rec >= 0 else 0.0, i])
			cand.sort_custom(func(x, y): return float(x[0]) > float(y[0]) or (float(x[0]) == float(y[0]) and int(x[1]) < int(y[1])))
			for c in cand:
				if vis.size() >= 3: break
				vis.append(int(c[1]))
		for i in range(n):
			if vis.size() >= 3: break
			if not (i in vis): vis.append(i)
	# history's option is never hidden by the rule
	if hist >= 0 and hist < n and not (hist in vis):
		if vis.size() < 3: vis.append(hist)
		else: vis[2] = hist
	return vis.slice(0, 3)


func story_view(d: Dictionary) -> Dictionary:
	## The story card: {type, title, stake, recommended: {index, why} ({} on Historian), options: [{index, id, label,
	## consequence: [<=2 lines], recommended, historical, historical_hidden, available}] (at most 3), more: [indices],
	## details_ref: {type, id}}; plus "surplus" (the budget card's second half), "treasury" or "brief_line" where they apply.
	var t := str(d.get("type", ""))
	var opts := _options_of(d)
	var hints: bool = sim.hints_enabled()
	var rec := _rec_index(d)
	var hist := _history_index(d)
	var vis := _visible(d, opts, rec, hist)
	var title := str(d.get("title", ""))
	var stake := ""
	if t == "event_choice":
		var ev = sim.db.event_by_id.get(str(d.get("event", "")), {})
		if title == "": title = str(ev.get("title", ""))
		stake = _first_sentence(str(ev.get("summary", "")))
	if title == "":
		title = str(d.get("label", t)).get_slice(": ", 1) if str(d.get("label", "")).contains(": ") else str(d.get("label", t))
	if stake == "":
		for k in ["explain", "text"]:
			if str(d.get(k, "")) != "":
				stake = _first_sentence(str(d[k]))
				break
	var ov := []
	for i in vis:
		var o: Dictionary = opts[i] if typeof(opts[i]) == TYPE_DICTIONARY else {}
		var cons := _consequence(d, o)
		var why_not := _unavailable_reason(d, o)
		ov.append({"index": i, "id": str(o.get("id", o.get("index", i))), "label": _opt_label(o, i), "consequence": cons,
			"recommended": hints and i == rec, "historical": hints and i == hist, "historical_hidden": (not hints) and i == hist,
			"available": why_not == "", "reason": _cap(why_not), "shown": _shown_values(d, o)})
	var more := []
	for i in range(opts.size()):
		if not (i in vis): more.append(i)
	var ref := {"type": t}
	for k in ["event", "fork", "crisis", "actor", "kind", "wave"]:
		if d.has(k):
			ref["id"] = d[k]
			break
	var recd := {}
	if hints and rec >= 0 and rec < opts.size():
		var wi := _why_info(d, rec, vis)
		recd = {"index": rec, "why": str(wi["why"]), "why_stat": str(wi["why_stat"]), "why_kind": str(wi["why_kind"])}
	var more_reasons := {}   # the hidden options that cannot be taken now: {index: "Needs 153 gold now ..."}
	for i in more:
		var r2 := _unavailable_reason(d, opts[i] if typeof(opts[i]) == TYPE_DICTIONARY else {})
		if r2 != "": more_reasons[i] = _cap(r2)
	var out := {"type": t, "title": title, "stake": stake, "advisor": "Cabinet Secretary", "recommended": recd,
		"options": ov, "more": more, "more_reasons": more_reasons, "n_options": opts.size(), "details_ref": ref}
	if t == "coalition" and _any_auto():
		out["brief_line"] = "The new government keeps the ministers' brief: %s" % brief().capitalize()
	if d.get("surplus") is Dictionary and not (d["surplus"] as Dictionary).is_empty():
		out["surplus"] = story_view(d["surplus"])
	if d.get("treasury") is Dictionary and not (d["treasury"] as Dictionary).is_empty():
		out["treasury"] = story_view(d["treasury"])
	return out


func resolve_pseudo(d: Dictionary) -> bool:
	## resolve_recommended for the casual layer's own items: the brief (Balanced, or the strategist's own) and the
	## Treasury in danger (Finance's plan).
	match str(d.get("type", "")):
		"brief":
			var sg: Dictionary = SimAI.strategy(sim)
			return set_brief(str(sg.get("group", "balanced")) if not sg.is_empty() else "balanced")
		"treasury":
			return choose_treasury("finance_plan")
	return false


# ================================================================== small helpers

func _unit_prefix(unit_id: String) -> String:
	## v4final (vet N6): a unit begun in a city is reported by the ministry that runs it: settlement groups and
	## public-works crews (civilian units) by Agriculture, the army's units by Defence.
	var u = sim.db.units.get(unit_id, {})
	if typeof(u) == TYPE_DICTIONARY and str(u.get("cls", "")) == "civilian":
		return "Agriculture"
	return "Defence"


func _item_name(kind: String, id: String) -> String:
	var tbl := {}
	match kind:
		"building": tbl = sim.db.buildings
		"district": tbl = sim.db.districts
		"unit": tbl = sim.db.units
		"project": tbl = sim.db.projects
		"city_project": tbl = sim.db.city_projects
	var e = tbl.get(id, {})
	if typeof(e) == TYPE_DICTIONARY and str(e.get("name", "")) != "":
		return str(e["name"])
	return id.replace("_", " ")


func _actor_name(a: String) -> String:
	var e = sim.db.actors.get(a, {})
	if typeof(e) == TYPE_DICTIONARY and str(e.get("name", "")) != "":
		return str(e["name"])
	return a.capitalize()
