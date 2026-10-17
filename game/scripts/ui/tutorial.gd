class_name Tutorial
extends Control
## Skippable opening tutorial (Civ VI onboarding, MECHANICS 27): the real game from 14 May 1948 with a gentle ramp.
## One system per step, shown on an advisor card with an arrow to the relevant UI element. Every blocking decision
## that has not been introduced yet is resolved quietly with the sim's own Recommended pick (SimAI), so the player
## only ever sees the decision the current step is about. "Skip tutorial" switches to the full game at once.

const SIDE := "user://quicksave_tutorial.json"
const ADVISOR := "Cabinet Secretary"
const PORTRAIT := "res://assets/ui/advisor_secretary.png"

var ui
var active := false
var step := 0
var done := {}              # step id -> true
var introduced := {}        # decision types the player now handles
var base := {}              # counters captured when a step starts (towns founded, crew charges)
var replaying := -1
var snooze_turn := -1       # "Carry on" card dismissed for this turn
var _gating := false
var _check_t := 0.0
var _fail := {}             # decision key -> attempts (stops the gate looping on a decision it cannot resolve)
var steps: Array = STEPS    # the step list in use: STEPS (Full control, v3) or STEPS_STORY (v4 story mode)
var story_tut := false      # the story-mode tutorial: informational cards, no gating of decisions
var advisor := false        # contextual tips after the tutorial (on if the tutorial was taken)
var advised := {}           # tip id -> true (each shown once)
var tip := ""               # tip currently on the card
var gov_seen := -2          # government term the player last saw
var tip_turn := -1          # at most one advisor card per turn (urgent war cards excepted)
var tips_off := false       # "Turn off tips" on an advisor card
const NEW_SYSTEM_TIPS := ["state_budget", "budget_review", "minister", "coalition", "diplomacy", "programme"]   # v2/v3: first-time cards in every game
const ALWAYS_TIPS := ["crisis", "front", "fork", "state_budget", "budget_review", "minister", "coalition", "diplomacy", "programme", "risk"]   # shown with or without the tutorial

var card: PanelContainer
var _portrait: TextureRect
var _name: Label
var _title: Label
var _text: RichTextLabel
var _count: Label
var _primary: Button
var _show: Button
var _skip: Button

# Each step: id, turn (earliest turn), title, text, todo (what to do), keep (decision types reserved for it),
# target (what the arrow points at), show (what "Show me" opens), introduces (types the player handles afterwards).
const AUTO_DONE := ["research", "event", "city", "next", "immigration", "settler", "crew", "war", "front", "agenda", "fork", "state_budget"]   # completed by doing them

const STEPS := [
	{"id": "welcome", "turn": 1, "title": "Welcome, Prime Minister",
		"text": "You lead the State of Israel from 14 May 1948 to {END_Q}. Wars, elections and treaties happen on their real dates; how well you build the country is up to you. [b]Your goal:[/b] reach one of the endings by {END_Q} (a Secure State, a Prosperous State, Peace with Neighbours, a United Society, or A Nation Ahead of history overall) and keep clear of the three collapses of the state that end the game early. You are measured against the ghost of history, a recorded run of what really happened, on six tracks: population, economy, science, water, standing and cohesion. Press O at any time for the Ending outlook.",
		"todo": "Drag the map to look around, scroll to zoom, Q / E to rotate.", "target": ""},
	{"id": "topbar", "turn": 1, "title": "The national ledger",
		"text": "The top bar shows the Treasury and its change per turn, Science, Culture, the food balance, Civic Trust and the population. Each turn is one quarter of a year.",
		"todo": "", "target": "topbar"},
	{"id": "war", "turn": 1, "title": "The 1948 war", "keep": ["crisis_response:first"], "needs": "crisis_response:first",
		"text": "Five Arab armies have entered the former Mandate territory. How the war ends is history; what it costs is yours. Your first decision is the state's response: each option's price depends on the Civic Trust, Standing and Readiness you have built.",
		"todo": "Choose the state's response.", "wait": "The war will need your orders.", "target": "war", "show": "crisis_response"},
	{"id": "event", "turn": 1, "title": "A historical decision", "keep": ["event_choice"], "introduces": ["event_choice"], "needs": "event_choice",
		"text": "Dated events arrive as they happened, and some ask you to decide. The option the government actually took is tagged historical; the others were proposed by named people at the time. Lasting terms and source ids are listed with each choice.",
		"todo": "Read the event and make your choice.", "wait": "Another dated event will ask for your decision soon.", "target": "event", "show": "event"},
	{"id": "immigration", "turn": 1, "title": "Place the immigrants", "keep": ["immigration"], "introduces": ["immigration"], "needs": "immigration",
		"text": "Hundreds of thousands of immigrants arrive in 1948-51; the totals follow history. You decide where they go. Big cities have work but little housing, towns and villages grow the periphery, and transit camps are cheap but cost trust and growth.",
		"todo": "Choose where this quarter's arrivals are settled.", "wait": "The next large wave of immigrants is on its way.",
		"target": "immigration", "show": "immigration"},
	{"id": "research", "turn": 1, "title": "Choose research", "keep": ["choose_research"], "introduces": ["choose_research"],
		"text": "Science unlocks buildings, districts and land improvements. Each row shows the cost, the turns it will take and what it unlocks. The Recommended one is a safe start.",
		"todo": "Open Research and pick a technology.", "target": "research", "show": "research"},
	{"id": "city", "turn": 1, "title": "Your cities", "keep": ["choose_production:capital"], "introduces": ["choose_production"],
		"text": "Tel Aviv-Yafo is your largest city. Food grows its population and housing caps it; the tiles it works are highlighted on the map. Small towns build on their own until you take them over.",
		"todo": "Open Tel Aviv-Yafo and choose what it builds.", "target": "city", "show": "city"},
	{"id": "next", "turn": 1, "title": "The decision button",
		"text": "The big button names your next decision and takes you there. When nothing is left it reads NEXT TURN and ends the quarter.",
		"todo": "Press NEXT TURN.", "target": "next"},
	{"id": "front", "turn": 2, "title": "Orders for the front", "keep": ["crisis_response:war"], "introduces": ["crisis_response"], "needs": "crisis_response:war",
		"text": "Each quarter of a war you decide where the reserves go: commit them to a named front (a counter-attack there, some production lost), mobilise fully (every front; Gold and more production), or hold with the standing forces (no cost, but the enemy strikes a front town). Higher Readiness makes every counter-attack hit harder.",
		"todo": "Give this quarter's orders.", "wait": "The war continues next quarter.", "target": "war", "show": "crisis_response"},
	{"id": "fork", "turn": 2, "title": "A cabinet decision", "keep": ["fork"], "introduces": ["fork"], "needs": "fork",
		"text": "Some decisions are taken once and shape the country for decades: the army, the capital, reparations, the territories. Each option names who argued for it at the time, what happens now and its lasting terms (years of gold, standing or trust). What history chose is revealed after you decide; when history's events still follow, a note says so. Your choices are listed under Your path (G).",
		"todo": "Read the options and choose.", "wait": "The cabinet will soon face a lasting decision.", "target": "event", "show": "fork"},
	{"id": "civics", "turn": 2, "title": "Civics and policies", "keep": ["choose_civic", "fill_policy"], "introduces": ["choose_civic", "fill_policy"],
		"text": "Culture advances civics, the way Science advances technology. Civics unlock policy cards, which you slot into your government. Elections, new civics and new eras let you swap cards for free.",
		"todo": "Look at the civics, then press P for Government and Policies.", "target": "civic", "show": "civic"},
	{"id": "budget", "turn": 3, "title": "Money, debt and inflation",
		"text": "The number after the Treasury is its change per quarter: taxes and trade in, building upkeep, public services and imports out. Below zero the Treasury is debt: every city loses an amenity and inflation rises, which makes buying dearer and erodes your income. Loans abroad cover a hole but must be serviced and repaid. War and mass immigration make 1948-52 hard; austerity, export routes and gold buildings dig you out.",
		"todo": "", "target": "gold"},
	{"id": "state_budget", "turn": 4, "title": "The State Budget", "keep": ["state_budget"], "introduces": ["state_budget"], "needs": "state_budget",
		"text": "Every fiscal year the government puts a Budget Law to the Knesset. Revenue sets the total; you split it between four envelopes: defence, immigrant absorption and housing, development and water, education and science. Favouring one buys a large gain there for smaller losses on the other three; an even split is safe but gains nothing. Pick a preset or drag the sliders: the effects update as you move them. Half-way through the year a review lets you top up or cut.",
		"todo": "Pass this year's budget.", "wait": "The first budget comes with the fiscal year in spring.", "target": "next", "show": "cabinet"},
	{"id": "settler", "turn": 3, "title": "Found a town", "keep": ["unit_orders:settler"],
		"text": "Settlement groups found real localities. Gold tiles are places open for founding, from six years before their real date. A town you found early grows sooner.",
		"todo": "Select the settlement group, click a gold tile, then press Found.", "target": "settler", "show": "settler"},
	{"id": "agenda", "turn": 3, "title": "The Cabinet Agenda", "keep": ["agenda"], "introduces": ["agenda"], "needs": "agenda",
		"text": "Each quarter the cabinet raises the most pressing issue: housing, the budget, inflation, water or readiness. Effects in [color=#9fe07a]green[/color] help and in [color=#ff8f7a]red[/color] hurt; some last for years.",
		"todo": "Answer the cabinet.", "wait": "The cabinet will meet soon.", "target": "agenda", "show": "agenda"},
	{"id": "crew", "turn": 4, "title": "Improve the land", "keep": ["unit_orders:builder"],
		"text": "Public works crews build farms, kibbutzim, groves and more. Green tiles can be improved by a crew. Each crew has a few charges.",
		"todo": "Select a crew, move it to a green tile and build an improvement.", "target": "crew", "show": "builder"},
	{"id": "history", "turn": 5, "title": "Measured against history",
		"text": "VS. HISTORY compares your Israel with the ghost on the six tracks; the comparison starts in Q2 1950, once your choices have had time to matter. The Why stats moved tab lists what changed your standing, trust, readiness, inflation and gold, quarter by quarter.",
		"todo": "", "target": "ghost", "show": "ghost_stats"},
	{"id": "outlook", "turn": 5, "title": "Endings and risks",
		"text": "The game ends after {END_Q} with one of five endings, judged on that last quarter: a [b]Secure State[/b], a [b]Prosperous State[/b], [b]Peace with Neighbours[/b], a [b]United Society[/b], or [b]A Nation Ahead[/b] (well ahead of history overall); otherwise [b]A Mixed Record[/b]. Each ending lists its thresholds and how close you are now. Below them are the three [b]risks to the state[/b]: a fiscal collapse, a collapse of public trust and a military collapse. Each warns you quarters ahead on the top bar and on an advisor card, eases when you turn the trend around, and if it runs its course the game ends early.",
		"todo": "Open the Ending outlook (O).", "target": "ghost", "show": "outlook"},
	{"id": "finish", "turn": 5, "title": "You're on your own now",
		"text": "From now on every decision is yours, including every city's production and military orders. I will still explain each new situation the first time it comes up: a new crisis, a new government, a deficit, the first envoy, the first national programme and the first warning of a risk to the state. F1 shows all these cards again, and How to Play (F1) has a page for every system.",
		"todo": "", "target": "", "final": true},
]

# v4 story-mode tutorial (V4_DESIGN 3.1 piece 4): 10 turns teaching decide -> see the consequence -> end turn. It never
# takes a decision away from the sim or the ministers (no gating); each card points at the real story UI. Plain words,
# at most two sentences a card (text + todo). Keys: turn (earliest), cond (what must be on screen), done (what completes
# it besides "Got it"), target (arrow), show ("Show me"), grace (turns it may wait for its cond before it is dropped).
const COVERED_INTROS := ["goals", "report", "queue", "city_view", "budget", "standing", "minimap", "help", "ghost"]   # unlock strips the story tutorial's cards already say
const STEPS_STORY := [
	{"id": "s_welcome", "turn": 1, "title": "Welcome, Prime Minister", "target": "goals", "done": "card_open",
		"text": "These are your era's goals. Your ministers run the routine; you make the big calls, one at a time.", "todo": ""},
	{"id": "s_now", "turn": 1, "title": "One decision at a time", "target": "now", "done": "card_open",
		"text": "This button always says what needs you now.", "todo": "Press Decide."},
	{"id": "s_pick", "turn": 1, "title": "Choose, then see what happened", "cond": "card", "done": "picked",
		"text": "Pick one option. The card then tells you what it cost and what changed.", "todo": ""},
	{"id": "s_end", "turn": 1, "title": "End the turn", "cond": "end_ready", "target": "now", "done": "turn2",
		"text": "When nothing else needs you, the button says END TURN.", "todo": "Press it: a quarter passes and your ministers report."},
	{"id": "s_report", "turn": 2, "title": "Your ministers' report", "cond": "report", "target": "report", "done": "report_open",
		"text": "This lists what your ministers did last quarter.", "todo": "Click it to read the lines."},
	{"id": "s_room", "turn": 2, "title": "The Cabinet Room", "cond": "report", "show": "room", "done": "room",
		"text": "In the Cabinet Room you can take over any ministry, and hand it back whenever you like.", "todo": ""},
	{"id": "s_queue", "turn": 2, "title": "The next decisions wait here", "cond": "queue", "target": "chips", "grace": 3,
		"text": "When there is more than one decision, the next ones are listed under the button.", "todo": "They follow on the same card, one at a time."},
	{"id": "s_goal", "turn": 3, "title": "Watch your goals", "target": "goals",
		"text": "The bars show how close each goal is. Reach one before its date for a reward; miss it and it costs you a little.", "todo": ""},
	{"id": "s_city", "turn": 3, "title": "Look at a city", "cond": "city_view",
		"text": "Click any city to see how it is doing.", "todo": "Its minister chooses what it builds."},
	{"id": "s_budget", "turn": 4, "title": "The State Budget", "cond": "budget", "done": "budget_done", "grace": 5,
		"text": "Once a year you choose what the budget puts first.", "todo": "Finance does the rest."},
	{"id": "s_envoy", "turn": 4, "title": "Your first envoy", "cond": "envoy", "done": "envoy_done", "grace": 10,
		"text": "A foreign envoy has come with a request.", "todo": "Your answer changes how the world sees Israel."},
	{"id": "s_map", "turn": 5, "title": "The Government menu", "cond": "minimap", "target": "gov",
		"text": "Your government's screens wait in this one button: the Cabinet Room, the Treasury, diplomacy and a small map.", "todo": ""},
	{"id": "s_help", "turn": 5, "title": "Need a reminder?", "show": "help",
		"text": "How to Play (F1) explains everything again, in plain words.", "todo": ""},
	{"id": "s_try", "turn": 6, "title": "Try a ministry (optional)", "show": "room",
		"text": "In the Cabinet Room, switch Research to You decide, then hand it back.", "todo": "Skip this if you like."},
	{"id": "s_echo", "turn": 7, "title": "Choices keep working", "show": "ghost_path",
		"text": "A choice from 1948 can still cost or pay years later.", "todo": "Your path lists every choice and what it still does."},
	{"id": "s_history", "turn": 9, "title": "Measured against history", "cond": "ghost", "target": "ghost", "show": "ghost_tracks",
		"text": "The line under your era goals compares your Israel with the real one on six tracks.", "todo": "Open it to see where you are ahead."},
	{"id": "s_quiet", "turn": 10, "title": "Quiet quarters", "show": "settings",
		"text": "When nothing needs you, the turn can end by itself.", "todo": "Turn this on or off in Settings."},
	{"id": "s_final", "turn": 10, "title": "You're on your own now", "final": true,
		"text": "Decide, see what it did, end the turn. F1 explains anything you forget.", "todo": ""},
]

# Contextual advisor (after the tutorial, if it was taken): one card the first time each situation appears.
const TIPS := {
	"crisis": {"title": "A new crisis", "show": "crisis_response",
		"text": "A war or crisis has begun. Choose the state's first response: its cost depends on the Civic Trust, Standing and Readiness you have built. Hostile forces appear outside the lines; cities are never captured, but they can be damaged."},
	"front": {"title": "Orders for the front", "show": "crisis_response",
		"text": "Each quarter of a war, decide where the reserves go: commit them to a named front, mobilise fully (Gold and production), or hold with the standing forces (no cost, but the enemy strikes a front town)."},
	"agenda": {"title": "The Cabinet Agenda", "show": "agenda",
		"text": "The cabinet raises the quarter's most pressing issue. Effects in [color=#9fe07a]green[/color] help and in [color=#ff8f7a]red[/color] hurt; some last for years. It must be answered before the turn ends."},
	"fork": {"title": "A cabinet decision", "show": "fork",
		"text": "Some decisions are taken once and shape the country for decades. Each option names who advocated it, what happens now and its lasting terms; what history chose is revealed after you decide. Your choices are listed under Your path (G)."},
	"election": {"title": "A new government", "show": "policy",
		"text": "A new government has taken office. Its coalition decides which policy slots you have, and swapping cards is free this turn. Review your policies (P)."},
	"state_budget": {"title": "The State Budget", "show": "cabinet",
		"text": "Every fiscal year the government puts a Budget Law to the Knesset. You split it between four envelopes: defence, immigrant absorption and housing, development and water, education and science. Favouring one buys a large gain there for smaller losses on the other three; an even split is safe but gains nothing. Pick a preset or drag the sliders, and watch the effects update."},
	"budget_review": {"title": "The mid-year review", "show": "cabinet",
		"text": "Half-way through the budget year the Finance Ministry reports. Keep the budget, pass a supplementary budget for the most pressing need (Gold now), cut across the board (Gold back, a little trust lost), or in wartime move money to defence."},
	"minister": {"title": "Ministers", "show": "cabinet",
		"text": "Each cabinet title appoints a minister to a seat city (a local effect once settled in, after two quarters) or buys one of their promotions, a national programme. Titles come every two quarters and with each new government. Press K for the cabinet at any time."},
	"coalition": {"title": "Coalition talks", "show": "cabinet",
		"text": "After an election the prime minister needs partners for a Knesset majority. Each partner brings its programme and asks for a portfolio (that minister's promotions start again) and a budget for its voters. A narrow coalition keeps every portfolio but costs a cabinet title and some cohesion."},
	"diplomacy": {"title": "An envoy", "show": "diplomacy",
		"text": "Every few quarters a foreign government sends an envoy, asks for something or offers one of its era's deals. Your answer moves the relation (each cause is itemised on the diplomacy screen), can give or cost Gold, Standing and the other tracks for years, and can make Israel dependent on a patron who may use that leverage later. Each answer names who argued for it at the time; what Israel actually did is shown after you answer. Press I for the diplomacy screen at any time: partners, relations and their causes, the deals of the era and delegations."},
	"programme": {"title": "National programmes", "show": "programmes",
		"text": "National programmes are the late-game projects of a state: high-tech incentives, desalination, the gas fields, space and cyber, the missile shield, peace dividends. Each is paid in quarterly instalments and, once complete, leaves lasting terms and a gain on the six tracks. History's ghost takes the historical ones on their real dates; launching early, or building what history did not, is where you get ahead."},
	"risk": {"title": "A first warning", "show": "outlook",
		"text": "One of the risks to the state has moved off [i]ok[/i] for the first time. The top bar's coin (debt and inflation) and Civic Trust change colour as things worsen: [color=#ffc75c]amber[/color] means watch it, [color=#ff8f7a]red[/color] means act now. Hover them for the reasons. Nothing ends the game yet: a collapse needs its conditions to hold quarter after quarter, and every quarter the trend turns, the danger eases. The Ending outlook (O) lists the three risks with what would clear each one."},
	"deficit": {"title": "The treasury is in deficit", "show": "fiscal",
		"text": "The Treasury is below zero or about to be. Debt costs an amenity in every city and pushes inflation up, which makes buying dearer and erodes your income; loans abroad cover the hole but must be serviced. Answer the budget agenda, open export routes, build gold buildings, or cut upkeep: every building costs upkeep each quarter, and a little-used one can be mothballed or closed (click the Treasury on the top bar for the running costs and the levers)."},
}

var _tips_dyn := {}        # v3 item 13: the collapse warning card (built from the sim's warning)
var _collapse_seen := {}   # "<collapse id>:<turn of the warning>" -> true (one card per episode)


func _tipdef(id: String) -> Dictionary:
	return _tips_dyn[id] if _tips_dyn.has(id) else TIPS.get(id, {"title": "", "text": ""})


func _collapse_card() -> bool:
	## v3 item 13 (fix-v3a): the first warning of a collapse of the state gets an advisor card, with or without the
	## tutorial and even with tips turned off (it is the one card that warns the game may end early).
	if tip == "collapse" or replaying >= 0 or active or ui == null or ui.sim == null or not ui.sim.has_method("get_collapse_warnings") or ui.sim.state.game_over:
		return false
	for w in ui.sim.get_collapse_warnings():
		var key := "%s:%d" % [str(w["id"]), int(ui.sim.collapse.cs()["warned"].get(str(w["id"]), 0))]
		if _collapse_seen.has(key):
			continue
		_collapse_seen[key] = true
		if tip != "":
			advised.erase(tip)   # the warning comes first; the ordinary first-time card shows again later
		var lines := []
		for c in w.get("conditions", []):
			if bool(c.get("met", false)): lines.append("• " + str(c.get("text", "")))
		_tips_dyn["collapse"] = {"title": "Danger: %s" % str(w["name"]), "show": "outlook",
			"text": "%s\n%s\n[color=#ff8f7a]If nothing changes, the game ends early in about %d quarters.[/color] Each quarter the conditions do not all hold, the danger eases.\n%s" % [
				str(w.get("warning", "")), "\n".join(lines), int(w.get("quarters_left", 0)), str(w.get("advice", ""))]}
		tip = "collapse"
		tip_turn = ui.sim.state.turn
		_render_tip()
		return true
	return false


func _structural_card() -> bool:
	## v3 fix3-econ: the structural-deficit alarm (a `fiscal` notification with structural: true) gets an advisor card,
	## with or without the tutorial and tips, once per episode; "Show me" opens the running costs and the levers.
	if tip in ["collapse", "structural"] or replaying >= 0 or active or ui == null or ui.sim == null or ui.sim.state.game_over:
		return false
	var ns: Array = ui.sim.state.notifications
	var t := int(ui.sim.state.turn)
	var k := ns.size() - 1
	while k >= 0 and k >= ns.size() - 60:
		var n: Dictionary = ns[k]
		k -= 1
		if int(n.get("turn", -1)) < t - 1:
			break
		if str(n.get("kind", "")) != "fiscal" or not bool(n.get("structural", false)):
			continue
		var key := "structural:%d" % int(n.get("turn", 0))
		if _collapse_seen.has(key):
			return false
		_collapse_seen[key] = true
		if tip != "":
			advised.erase(tip)
		_tips_dyn["structural"] = {"title": "Structural deficit" if not bool(n.get("first", false)) else "A structural deficit", "show": "fiscal",
			"text": "%s\n[color=#a8b0c4]Loans only postpone it. Show me opens the running costs and the three levers: mothball or close little-used buildings, privatise a state company, or an emergency stabilisation package.[/color]" % UITheme.humanise(str(n.get("text", "")))}
		advised["deficit"] = true   # this card says more than the plain deficit card
		tip = "structural"
		tip_turn = t
		_render_tip()
		return true
	return false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme = UITheme.get_theme()
	card = PanelContainer.new()
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.custom_minimum_size = Vector2(400, 0)
	var st := UITheme.sb(Color(0.035, 0.065, 0.14, 0.98), UIKit.GOLD_LIGHT, 2, 10, 14)
	st.shadow_color = Color(0, 0, 0, 0.5); st.shadow_size = 12
	card.add_theme_stylebox_override("panel", st)
	add_child(card)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	card.add_child(h)
	var pv := VBoxContainer.new()
	h.add_child(pv)
	_portrait = TextureRect.new()
	_portrait.custom_minimum_size = Vector2(84, 84)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_portrait.texture = _load_portrait()
	pv.add_child(_portrait)
	_count = UITheme.label("", 13, UIKit.TEXT_DIM)
	_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pv.add_child(_count)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	v.custom_minimum_size = Vector2(250, 0)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(v)
	_name = UITheme.label(ADVISOR.to_upper(), 13, UIKit.GOLD, "title")
	v.add_child(_name)
	_title = UITheme.title("", 20, UIKit.GOLD_LIGHT)
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(_title)
	_text = UITheme.rich("", 16)
	v.add_child(_text)
	var bh := HFlowContainer.new()   # wraps when the card is narrow (docked beside a wide window)
	bh.add_theme_constant_override("h_separation", 6)
	bh.add_theme_constant_override("v_separation", 6)
	v.add_child(bh)
	_primary = UITheme.button("Got it", _on_primary, 16)
	bh.add_child(_primary)
	_show = UITheme.button("Show me", _on_show, 16)
	bh.add_child(_show)
	_skip = UITheme.button("Skip tutorial", _on_skip, 14)
	_skip.tooltip_text = "Switch to the full game now."
	bh.add_child(_skip)
	card.visible = false


func _load_portrait() -> Texture2D:
	var art := UIArt.advisor()   # v3: the art-2d advisor portrait when present
	if art != null:
		return art
	var t := UIKit.tex(PORTRAIT)
	if t:
		return t
	var img := Image.load_from_file(ProjectSettings.globalize_path(PORTRAIT))
	return ImageTexture.create_from_image(img) if img else null


# ================================================================== lifecycle

func use_story(on: bool) -> void:
	## Picks the step list by play style (story mode teaches the casual flow; Full control keeps the v3 steps).
	story_tut = on
	steps = STEPS_STORY if on else STEPS


func begin(story := false) -> void:
	use_story(story)
	active = true
	advisor = true
	advised.clear()
	tip = ""
	gov_seen = ui.sim.state.gov_term if ui and ui.sim else -2
	done.clear()
	introduced.clear()
	base.clear()
	_fail.clear()
	step = _pick_step()
	_enter()


func jump_to_step(id: String) -> void:
	## Harness: mark every earlier step done and show this one.
	for i in steps.size():
		if str(steps[i]["id"]) == id:
			for j in i:
				done[str(steps[j]["id"])] = true
				for t in steps[j].get("introduces", []):
					introduced[str(t)] = true
			step = i
			_enter()
			return


func finish() -> void:
	## Switch to the full game: stop gating; everything is the player's from now on.
	active = false
	replaying = -1
	if ui and ui.sim:
		gov_seen = ui.sim.state.gov_term
	for pair in [["war", "crisis"], ["front", "front"], ["agenda", "agenda"]]:
		if done.has(pair[0]):
			advised[pair[1]] = true
	card.visible = false
	queue_redraw()
	if ui and ui.sim:
		ui._refresh_all()
		if story_tut:
			ui.show_toast("Tutorial finished. F1 shows the cards again.", 4.0)
		else:
			ui.show_toast("Full game: every decision is yours. F1 shows the tutorial cards again.", 5.0)


func save() -> void:
	var f := FileAccess.open(SIDE, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"active": active, "step": step, "done": done.keys(), "introduced": introduced.keys(), "base": base,
			"advisor": advisor, "advised": advised.keys(), "gov_seen": gov_seen, "story": story_tut}))


func load_state() -> void:
	active = false
	card.visible = false
	if not FileAccess.file_exists(SIDE):
		return
	var d = JSON.parse_string(FileAccess.get_file_as_string(SIDE))
	if typeof(d) != TYPE_DICTIONARY:
		return
	advisor = bool(d.get("advisor", false))
	advised.clear()
	for k in d.get("advised", []): advised[str(k)] = true
	gov_seen = int(d.get("gov_seen", -2))
	tip = ""
	if not bool(d.get("active", false)):
		return
	active = true
	use_story(bool(d.get("story", false)))
	step = int(d.get("step", 0))
	done.clear(); introduced.clear()
	for k in d.get("done", []): done[str(k)] = true
	for k in d.get("introduced", []): introduced[str(k)] = true
	base = d.get("base", {})
	step = _pick_step()
	_enter()


static func clear_save() -> void:
	if FileAccess.file_exists(SIDE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SIDE))


func cur() -> Dictionary:
	return steps[clampi(step, 0, steps.size() - 1)]


func _enter() -> void:
	var s := cur()
	match str(s["id"]):
		"settler":
			base["towns"] = int(ui.sim.state.counters.get("towns_founded", 0))
		"crew":
			base["charges"] = _crew_charges()
	_render()


func _pick_step() -> int:
	## The first unfinished step that can run now (its turn has come and what it needs is on screen);
	## if none can, the first unfinished one (its card says what to wait for).
	var waiting := -1
	for i in steps.size():
		var s: Dictionary = steps[i]
		if done.has(str(s["id"])):
			continue
		if s.get("final", false):
			var others := false
			for o in steps:
				if not o.get("final", false) and not done.has(str(o["id"])) and not story_tut:   # (story: a card whose screen never came is dropped)
					others = true
			if others:
				continue
		if _ready_now(s):
			return i
		if waiting < 0:
			waiting = i
	return waiting if waiting >= 0 else steps.size() - 1


func _advance() -> void:
	var s := cur()
	done[str(s["id"])] = true
	for t in s.get("introduces", []):
		introduced[str(t)] = true
	if s.get("final", false):
		finish()
		return
	step = _pick_step()
	_enter()
	if ui:
		ui._refresh_hud()


# ================================================================== the card

func _render() -> void:
	if tip != "" and replaying < 0:
		_render_tip()
		return
	var s: Dictionary = steps[replaying] if replaying >= 0 else cur()
	if story_tut:
		_render_story(s)
		return
	var waiting := replaying < 0 and not _ready_now(s)
	var later: bool = waiting and ui.sim.state.turn < int(s.get("turn", 1))
	_title.text = "Carry on" if later else str(s["title"])
	var body := ("Next: %s." % str(s["title"])) if later else str(s["text"])
	var todo := str(s.get("todo", ""))
	if waiting:
		todo = str(s.get("wait", ""))
		var left: bool = ui.sim.blocking_decisions().size() > 0
		todo = (todo + " " if todo != "" else "") + ("Finish this turn's decisions with the big button, then press NEXT TURN." if left else "Press NEXT TURN to continue.")
	if todo != "":
		body += "\n[color=#f7dc8f][b]%s[/b][/color]" % todo
	_text.text = UITheme.pal(V3Adapter.endify(body))
	_count.text = "Step %d of %d" % [(replaying if replaying >= 0 else step) + 1, steps.size()]
	var action_step := str(s["id"]) in AUTO_DONE
	_primary.text = "Close" if replaying >= 0 else ("Start the full game" if s.get("final", false) else ("Skip this step" if action_step else "Got it"))
	if later:
		_primary.text = "OK"
	_show.visible = replaying < 0 and s.has("show") and not waiting
	_skip.visible = replaying < 0 and not s.get("final", false)
	card.visible = not (later and snooze_turn == ui.sim.state.turn)
	_place_card()
	move_to_front()
	queue_redraw()


func _render_story(s: Dictionary) -> void:
	## The story tutorial's card: short, friendly, one at a time; hidden until its moment (no "carry on" card).
	var ready: bool = replaying >= 0 or _ready_now(s)
	var body := str(s["text"])
	var todo := str(s.get("todo", ""))
	if todo != "":
		body += "\n[color=#f7dc8f][b]%s[/b][/color]" % todo
	_title.text = str(s["title"])
	_text.text = UITheme.pal(V3Adapter.endify(body))
	_count.text = "Step %d of %d" % [(replaying if replaying >= 0 else step) + 1, steps.size()]
	_primary.text = "Close" if replaying >= 0 else ("Finish tutorial" if s.get("final", false) else "Got it")
	_show.visible = s.has("show") and ready
	_skip.visible = replaying < 0 and not s.get("final", false)
	_skip.text = "Skip tutorial"
	_skip.tooltip_text = "Stop the tutorial. The game goes on as it is."
	card.visible = ready
	_place_card()
	move_to_front()
	queue_redraw()


func _render_tip() -> void:
	var t: Dictionary = _tipdef(tip)
	_title.text = str(t["title"])
	_text.text = UITheme.pal(str(t["text"]))
	_count.text = "Advisor"
	_primary.text = "Got it"
	_show.visible = str(t.get("show", "")) != ""
	_skip.visible = true
	_skip.text = "Turn off tips"
	card.visible = _tip_screen_ok()
	_show.visible = _show.visible and _home_window() == null
	_place_card()
	move_to_front()
	queue_redraw()


func _tip_check() -> void:
	## First appearance of each untaught situation after the tutorial: one dismissable card.
	if tip != "" or tips_off or active or ui == null or ui.sim == null or ui.popup == null:
		return
	var sim: Sim = ui.sim
	var found := ""
	var calm := tip_turn == sim.state.turn   # a card was already shown this turn: only war cards may follow
	# only the decision the player is looking at (an open decision screen), else the one the big button names:
	# so turn 1 opens on the war, and a card never explains a screen that is not there
	var looking := []
	var open_d := _open_decision()
	if not open_d.is_empty():
		looking.append(open_d)
	elif _windows().is_empty():
		var na: Dictionary = sim.next_action()
		if str(na.get("type", "end_turn")) != "end_turn":
			looking.append(na)
	for d in looking:
		var t := str(d["type"])
		if calm and t != "crisis_response":
			continue
		if t == "crisis_response":
			var k := "front" if _is_front_turn(d) else "crisis"
			if not advised.has(k):
				found = k
		elif t == "agenda" and not advised.has("agenda"):
			found = "agenda"
		elif t == "fork" and not advised.has("fork"):
			found = "fork"
		elif t in NEW_SYSTEM_TIPS and not advised.has(t):
			found = t
		elif V3Adapter.is_diplo_decision(d) and not advised.has("diplomacy"):
			found = "diplomacy"
		if not advisor and not found in ALWAYS_TIPS:
			found = ""   # without the tutorial, only the war and the v2 systems get a first-time card
		elif t in ["fill_policy", "policy_review"] and not advised.has("election"):
			found = "election"
		if found != "":
			break
	if found == "" and advisor and not calm and not advised.has("election") and gov_seen != -2 and sim.state.gov_term != gov_seen:
		found = "election"
	if found == "" and not calm and not advised.has("risk") and _first_risk(sim):
		found = "risk"   # v3 onboarding: the first time a risk to the state is above "watch" (the danger card itself is _collapse_card)
	if found == "" and advisor and not calm and not advised.has("deficit"):
		var net := float(sim.state.counters.get("last_budget", {}).get("net", 0.0))
		if sim.state.gold < 0 or (net < 0 and sim.state.gold + 4.0 * net < 0):
			found = "deficit"
	if found != "":
		tip = found
		tip_turn = sim.state.turn
		advised[found] = true
		gov_seen = sim.state.gov_term
		_render_tip()


func _first_risk(sim) -> bool:
	## A risk to the state at "warning" or worse: a collapse whose conditions all hold (or strain building), or the
	## fiscal indicator's warning / danger tier (fix3-econ). The game's first turns (the 1948 war budget) are spared.
	if sim.state.turn < 6 or sim.state.game_over:
		return false
	if sim.has_method("get_collapse_status"):
		for c in sim.get_collapse_status():
			if str(c.get("level", "ok")) in ["warning", "danger"]:
				return true
	if sim.has_method("get_fiscal_indicator"):
		return str(sim.get_fiscal_indicator().get("level", "ok")) in ["warning", "danger"]
	return false


func _open_decision() -> Dictionary:
	## The decision dict on screen, if a decision window is open.
	if ui.popup.visible and str(ui.popup.mode) in ["crisis_response", "agenda", "fork", "immigration", "event", "dedication"]:
		var d: Dictionary = (ui.popup.data as Dictionary).duplicate()
		d["type"] = {"event": "event_choice"}.get(str(ui.popup.mode), str(ui.popup.mode))
		if str(ui.popup.mode) == "crisis_response":
			d["war_turn"] = bool(d.get("war_turn", false)) or bool(ui.sim.state.crisis_decision.get("war_turn", false))
		return d
	if ui.cabinet_p.visible and str(ui.cabinet_p.mode) != "view":
		var d2: Dictionary = (ui.cabinet_p.data as Dictionary).duplicate()
		d2["type"] = {"budget": "state_budget", "review": "budget_review", "minister": "minister", "coalition": "coalition"}.get(str(ui.cabinet_p.mode), "")
		return d2
	if ui.policy_p.visible and ui.policy_review_pending():
		return {"type": "policy_review"}
	if ui.diplo_w != null and ui.diplo_w.visible and str(ui.diplo_w.mode) == "envoy":
		return {"type": "diplomacy"}
	if ui.prog_w != null and ui.prog_w.visible and not (ui.prog_w.data as Dictionary).is_empty():
		return {"type": "programme"}
	return {}


func _close_tip() -> void:
	tip = ""
	_unshift()
	_skip.text = "Skip tutorial"
	card.visible = false
	queue_redraw()


func replay(i: int) -> void:
	## F1 help: show any step's card again (does not change progress).
	replaying = clampi(i, 0, steps.size() - 1)
	_render()


func _on_primary() -> void:
	if tip != "" and replaying < 0:
		_close_tip()
		return
	if replaying >= 0:
		replaying = -1
		if active:
			_render()
		else:
			card.visible = false
			queue_redraw()
		return
	if not _ready_now(cur()) and ui.sim.state.turn < int(cur().get("turn", 1)):
		snooze_turn = ui.sim.state.turn   # "Carry on": hide until the next turn
		card.visible = false
		queue_redraw()
		return
	_advance()


func _on_show() -> void:
	var s := cur()
	var what := str(s.get("show", ""))
	if tip != "" and replaying < 0:
		what = str(_tipdef(tip).get("show", ""))
	match what:
		"crisis_response", "agenda", "fork": ui.open_panel(what)
		"cabinet": ui.open_panel("cabinet")
		"policy": ui.open_panel("policy")
		"research": ui.open_panel("research")
		"civic": ui.open_panel("civic")
		"event": ui.open_panel("event")
		"immigration": ui.open_panel("immigration")
		"ghost_stats": ui.open_ghost_tab("stats")
		"ghost_path": ui.open_ghost_tab("path")
		"ghost_tracks": ui.open_ghost_tab("tracks")
		"room": ui.open_cabinet_room()
		"help": ui.show_help()
		"settings": ui.open_settings()
		"city":
			var c = ui.sim.city_by_key(ui.sim.state.capital)
			if c != null:
				ui.city_s.tab = "production"
				ui.open_city(c.id, true)
		"settler": ui.open_panel("settler")
		"builder": ui.open_panel("builder")
		"diplomacy": ui.open_panel("envoy")
		"programmes": ui.open_panel("programmes")
		"outlook": ui.open_ghost_tab("endings")
		"fiscal": ui.open_fiscal()
	move_to_front()


func _on_skip() -> void:
	if tip != "" and replaying < 0:
		advisor = false
		tips_off = true
		_close_tip()
		ui.show_toast("Advisor tips are off.")
		return
	done[str(cur()["id"])] = true
	finish()


const CARD_W := 400.0          # with the portrait
const CARD_W_NARROW := 300.0   # beside a wide window: no portrait
var _shifted: UIWindow = null  # a centred window nudged sideways to make room for the card
var _hidden_for := ""          # tip waiting for its own screen (an unrelated window is open)


func _windows() -> Array:
	## Every big window that can be on screen, in the order a card should prefer to explain them.
	if ui == null:
		return []
	return [ui.story_c, ui.room_w, ui.cabinet_p, ui.popup, ui.diplo_w, ui.prog_w, ui.policy_p, ui.research_p, ui.civic_p, ui.city_s, ui.ghost_p, ui.pedia, ui.save_w,
		ui.help, ui.info_p, ui.end_s, ui.tree_w, ui.unit_p, ui.settings_w, ui.credits_w, ui.fiscal_w].filter(func(w): return w != null and (w as Control).visible)   # Credits too: a card never pokes out behind it


func _home_window() -> Control:
	## The window the card explains, if it is open: a tip's decision screen, or the tutorial step's panel.
	if ui == null:
		return null
	if tip != "" and replaying < 0:
		match tip:
			"crisis", "front":
				return ui.popup if ui.popup.visible and str(ui.popup.mode) == "crisis_response" else null
			"agenda", "fork":
				return ui.popup if ui.popup.visible and str(ui.popup.mode) == tip else null
			"state_budget", "budget_review", "minister", "coalition":
				var m: String = {"state_budget": "budget", "budget_review": "review", "minister": "minister", "coalition": "coalition"}[tip]
				return ui.cabinet_p if ui.cabinet_p.visible and str(ui.cabinet_p.mode) == m else null
			"election":
				return ui.policy_p if ui.policy_p.visible else null
			"diplomacy":
				return ui.diplo_w if ui.diplo_w != null and ui.diplo_w.visible else null
			"collapse", "risk":
				return ui.ghost_p if ui.ghost_p.visible else null
			"deficit", "structural":
				return ui.fiscal_w if ui.fiscal_w != null and ui.fiscal_w.visible else null
			"programme":
				return ui.prog_w if ui.prog_w != null and ui.prog_w.visible else null
		return null
	var ws := _windows()
	if story_tut and ws.size() > 1:
		# several windows can be open (the story card under the Cabinet Room): the card explains the top-most one
		var top: Control = ws[0]
		for w in ws:
			if (w as Control).get_index() > top.get_index():
				top = w
		return top
	return ws[0] if ws.size() > 0 else null


func _tip_screen_ok() -> bool:
	## A tip shows over its own screen, or with no window open (pointing at the decision button). Over an unrelated
	## window (the city screen, the Civilopedia...) it waits until that window closes.
	if tip == "" or replaying >= 0:
		return true
	if _home_window() != null:
		return true
	return _windows().is_empty()


func _set_narrow(on: bool) -> void:
	_portrait.get_parent().visible = not on
	card.custom_minimum_size = Vector2(CARD_W_NARROW if on else CARD_W, 0)


func _unshift() -> void:
	if _shifted != null and is_instance_valid(_shifted):
		_shifted.shift_x = 0.0
	_shifted = null


func _place_card() -> void:
	if ui == null:
		return
	var vw := size.x if size.x > 10 else 1672.0
	var vh := size.y if size.y > 10 else 941.0
	var home := _home_window()
	if home != null:
		_dock_beside(home, vw, vh)
		return
	_unshift()
	_set_narrow(false)
	var sz := card.get_combined_minimum_size()
	var w := maxf(CARD_W, sz.x)
	# the spots beside the HUD's parts are in its 1672x941 units at its scale (layout-audit: on a 16:10 or 4:3 screen the
	# HUD is drawn larger; at 270 from the right edge the card's corner already sat on the minimap's toolbar at 16:9)
	var k: float = ui.hud._ref_scale() if ui.hud != null else 1.0
	var pos := Vector2(vw - w - 290 * k, vh - 190 * k - sz.y)   # no window open: beside the decision button, left of the minimap
	if tip == "deficit":
		pos = Vector2(320, 56) * k                      # under the Treasury in the top bar
	elif replaying >= 0:
		pos = Vector2((vw - w) * 0.5, 120 * k)
	elif tip == "" and active and story_tut:
		var np := Vector2(vw - w - 20 * k, vh - 470 * k)
		var left_edge := 0.0
		for lw in [ui.goals_w, ui.report_w]:
			if lw != null and (lw as Control).is_visible_in_tree():
				left_edge = maxf(left_edge, (lw as Control).get_global_rect().end.x + 14.0)   # right of the goals and the report
		if left_edge <= 0.0:
			left_edge = 458.0 * k
		if ui.next_w != null and ui.next_w.is_visible_in_tree():
			var cr: Rect2 = ui.next_w.card.get_global_rect()
			np = Vector2(cr.end.x - w, vh + ui.next_w.top_y() * k - sz.y - 12.0)   # right above the NOW box and its queue (top_y: HUD units)
		match str(cur().get("target", "")):   # beside the real element, never over it
			"goals", "report": pos = Vector2(left_edge, 70 * k)
			"now", "chips": pos = np
			"minimap": pos = Vector2(vw - w - 20 * k, vh - 470 * k)
			"ghost": pos = Vector2(vw - w - 20 * k, 110 * k)
			_: pos = Vector2(maxf((vw - w) * 0.5, left_edge), 70 * k)
	elif tip == "" and active and not _ready_now(cur()):
		pos = Vector2((vw - w) * 0.5, vh - 300 * k)          # "carry on": out of the way, above the action bar
	elif tip == "":
		match str(cur()["target"]):
			"topbar": pos = Vector2((vw - w) * 0.5, 80 * k)
			"research", "civic", "ghost": pos = Vector2(330, 110) * k
			"city": pos = Vector2(410, 470) * k
			"settler", "crew": pos = Vector2((vw - w) * 0.5, 90 * k)
			"": pos = Vector2((vw - w) * 0.5, 200 * k)
	card.position = Vector2(clampf(pos.x, 6, vw - w - 6), clampf(pos.y, 52 * k, vh - sz.y - 6))
	card.size = Vector2(w, sz.y)


func _dock_beside(win: Control, vw: float, vh: float) -> void:
	## Dock the card beside the window it explains, never over it: to its right (or left), narrowing the card or
	## nudging a centred window sideways if there is not room on either side.
	var r := win.get_global_rect()
	if win is UIWindow and (win as UIWindow).centered:
		r.position.x -= (win as UIWindow).shift_x   # where it sits unshifted
	var gap := 10.0
	var right_room := vw - r.end.x - gap - 6
	var left_room := r.position.x - gap - 6
	var narrow := maxf(right_room, left_room) < CARD_W
	_set_narrow(narrow)
	var w := CARD_W_NARROW if narrow else CARD_W
	var shift := 0.0
	var side := 1   # 1 = right of the window, -1 = left
	if right_room >= w:
		side = 1
	elif left_room >= w:
		side = -1
	elif win is UIWindow and (win as UIWindow).centered:
		shift = maxf(-(r.position.x - 6.0), -(w - right_room))   # move the window left to make room on its right
		side = 1
	else:
		side = 1 if right_room >= left_room else -1
	if win is UIWindow and (win as UIWindow).centered:
		if _shifted != win:
			_unshift()
		(win as UIWindow).shift_x = shift
		_shifted = win if absf(shift) > 0.5 else null
	elif _shifted != null:
		_unshift()
	r.position.x += shift
	var sz := card.get_combined_minimum_size()
	var x := r.end.x + gap if side == 1 else r.position.x - gap - w
	var tb: float = 52.0 * (ui.hud._ref_scale() if ui.hud != null else 1.0)   # (below the top bar at the HUD's scale)
	var y := clampf(r.position.y, tb, maxf(tb, vh - sz.y - 6.0))
	card.position = Vector2(clampf(x, 4.0, vw - w - 4.0), y)
	card.size = Vector2(w, sz.y)


# ================================================================== progress and the gate

func _process(delta: float) -> void:
	if card and tip != "" and replaying < 0 and ui != null and ui.sim != null:
		# a tip follows its screen: shown over its own decision screen or the bare map, hidden over unrelated windows
		var ok := _tip_screen_ok()
		if card.visible != ok:
			card.visible = ok
		if ok:
			_show.visible = str(_tipdef(tip).get("show", "")) != "" and _home_window() == null   # already on its screen: no "Show me"
	if card and card.visible:
		_place_card()
	elif _shifted != null:
		_unshift()
	if card and card.visible:
		# shrink the card to its content once the text has wrapped at the card's width (it is measured narrow at first)
		var mh := card.get_combined_minimum_size().y
		if absf(card.size.y - mh) > 1.0:
			card.size = Vector2(card.size.x, mh)
	if ui == null or ui.sim == null:
		return
	if not active:
		_ccheck_t += delta
		if _ccheck_t > 0.5:
			_ccheck_t = 0.0
			if not _collapse_card():
				_structural_card()
		if advisor or not tips_off:
			_check_t += delta
			if _check_t > 0.4:
				_check_t = 0.0
				_tip_check()
			if card.visible:
				queue_redraw()
		return
	_check_t += delta
	if _check_t > 0.25:
		_check_t = 0.0
		tick()
		if get_index() != get_parent().get_child_count() - 1:
			move_to_front()
	queue_redraw()


var _ticking := false
var _ccheck_t := 0.0


func tick() -> void:
	## Advance when the current step's action is done; switch to whichever step can run now. Also called after every
	## UI refresh, so the card follows the player's actions at once.
	if not active or replaying >= 0 or _ticking or ui == null or ui.sim == null:
		return
	_ticking = true
	for i in 6:
		_expire()
		note_seen()
		if _complete(cur()):
			_advance()
			if not active:
				break
			continue
		var ns := _pick_step()
		if ns != step:
			step = ns
			_enter()
		else:
			_render()
		break
	_ticking = false


func _ready_now(s: Dictionary) -> bool:
	if ui == null or ui.sim == null:
		return true
	if ui.sim.state.turn < int(s.get("turn", 1)):
		return false
	if story_tut:
		return _story_cond(str(s.get("cond", "")))
	if s.has("needs"):
		return ui.sim.blocking_decisions().any(func(d): return _matches(d, str(s["needs"])))
	return true


func _is_war_turn(d: Dictionary) -> bool:
	return bool(d.get("war_turn", false)) or bool(ui.sim.state.crisis_decision.get("war_turn", false))


func _is_front_turn(d: Dictionary) -> bool:
	## A later quarter of a war (front orders), not its opening decision (the state's first response, which
	## the sim marks first_turn on a war_turn decision).
	if not _is_war_turn(d):
		return false
	var cd: Dictionary = ui.sim.state.crisis_decision
	return not (bool(d.get("first_turn", false)) or bool(cd.get("first_turn", false)))


func _matches(d: Dictionary, spec: String) -> bool:
	## spec: "type" or "type:qualifier" (crisis_response:first | crisis_response:war)
	var p := spec.split(":")
	if str(d["type"]) != p[0]:
		return false
	if p.size() == 1:
		return true
	match p[1]:
		"first": return str(d["type"]) == "crisis_response" and not _is_front_turn(d)
		"war": return str(d["type"]) == "crisis_response" and _is_front_turn(d)
	return true


func _story_cond(c: String) -> bool:
	## Story mode: is what the card is about on screen now?
	if c == "":
		return true
	var pd := NextStep.player_decisions(ui)
	match c:
		"card":
			return ui.story_c.visible
		"end_ready":
			return str(NextStep.primary(ui).get("type", "")) == "end_turn" or (ui.story_c.visible and str(ui.story_c.deco.get("type", "")) == "end_turn")
		"report":
			return Unlocks.is_on(ui, "report") and ui.report_w.visible
		"queue":
			return Unlocks.is_on(ui, "queue") and ui.next_w.chip_count() > 0
		"city_view":
			return Unlocks.is_on(ui, "city_view")
		"budget":
			return pd.any(func(d): return str(d.get("type", "")) == "state_budget")
		"envoy":
			return pd.any(func(d): return V3Adapter.is_diplo_decision(d))
		"minimap":
			return Unlocks.is_on(ui, "minimap")
		"ghost":
			return Unlocks.is_on(ui, "ghost")
	return true


func _story_done(s: Dictionary) -> bool:
	## Story mode: has the player done what the card asked (besides pressing Got it)?
	var id := str(s["id"])
	match str(s.get("done", "")):
		"card_open":
			return ui.story_c.visible
		"picked":
			return ui.story_c.picks_this_turn > 0 or ui.sim.state.turn > int(s["turn"])
		"turn2":
			return ui.sim.state.turn >= int(s["turn"]) + 1
		"report_open":
			return ui.report_w.opened
		"room":
			return bool(base.get("room_" + id, false)) and not ui.room_w.visible
		"budget_done", "envoy_done":
			return bool(base.get("seen_" + id, false)) and not _story_cond(str(s.get("cond", "")))
	return false


func _complete(s: Dictionary) -> bool:
	var sim: Sim = ui.sim
	if story_tut:
		return str(s.get("done", "")) != "" and _story_done(s)
	if s.has("needs"):
		return bool(base.get("seen_" + str(s["id"]), false)) and not _ready_now(s)
	match str(s["id"]):
		"research":
			return sim.state.current_tech != ""
		"event":
			return sim.get_pending_events().is_empty()
		"city":
			var c = sim.city_by_key(sim.state.capital)
			return c != null and not c.queue.is_empty()
		"next":
			return sim.state.turn >= 2
		"settler":
			return int(sim.state.counters.get("towns_founded", 0)) > int(base.get("towns", 0)) or not _has_unit("settler")
		"crew":
			return _crew_charges() < int(base.get("charges", 0)) or not _has_unit("builder")
	return false


func _expire() -> void:
	## A step waiting for something that has not come within 4 turns of its turn is dropped.
	for s in steps:
		if story_tut:
			# a card whose moment passed (its screen never showed within its grace turns) is dropped, never the last one
			if not s.get("final", false) and not done.has(str(s["id"])) and ui.sim.state.turn > int(s["turn"]) + int(s.get("grace", 2)) and not _ready_now(s):
				done[str(s["id"])] = true
			continue
		if s.has("needs") and not done.has(str(s["id"])) and ui.sim.state.turn > int(s["turn"]) + 4 and not _ready_now(s):
			done[str(s["id"])] = true
			for t in s.get("introduces", []):
				introduced[str(t)] = true


func note_seen() -> void:
	## Called each refresh: remembers that the waited-for decision has appeared (so its resolution completes the step).
	if story_tut:
		if active and replaying < 0 and _ready_now(cur()):
			base["seen_" + str(cur()["id"])] = true
			if ui.room_w.visible:
				base["room_" + str(cur()["id"])] = true
		return
	if active and cur().has("needs") and _ready_now(cur()):
		base["seen_" + str(cur()["id"])] = true


func _has_unit(t: String) -> bool:
	return ui.sim.get_units("player").any(func(u): return str(u["type"]) == t)


func _crew_charges() -> int:
	var n := 0
	for u in ui.sim.get_units("player"):
		if str(u["type"]) == "builder":
			n += int(u.get("charges", 0))
	return n


func reserved() -> Array:
	## Decision specs kept for the player now: what the not-yet-done steps of this turn are about.
	var out := []
	if not active or story_tut:
		return out
	for i in range(steps.size()):
		var s: Dictionary = steps[i]
		if int(s.get("turn", 1)) <= ui.sim.state.turn and not done.has(str(s["id"])):
			out.append_array(s.get("keep", []))
	return out


func allowed(d: Dictionary) -> bool:
	if not active or story_tut:
		return true   # story mode: the ministers and the story card handle every decision; the tutorial only explains
	var t := str(d["type"])
	if introduced.has(t):
		return true
	for spec in reserved():
		var p: PackedStringArray = str(spec).split(":")
		if p[0] != t:
			continue
		if p.size() == 1:
			return true
		match p[1]:
			"first", "war":
				if _matches(d, str(spec)):
					return true
			"capital":
				var c = ui.sim.city_by_key(ui.sim.state.capital)
				if c != null and int(d.get("city", -1)) == c.id:
					return true
			"settler", "builder":
				var u = ui.sim.unit_by_id(int(d.get("unit", -1)))
				if u != null and u.type == p[1]:
					return true
	return false


func gate() -> void:
	## Resolve, with the sim's Recommended picks, every blocker the tutorial has not introduced yet.
	if not active or story_tut or _gating or ui == null or ui.sim == null:
		return
	_gating = true
	var sim: Sim = ui.sim
	for i in 80:
		var target := {}
		for d in sim.blocking_decisions():
			if not allowed(d):
				var key := "%d:%s:%s" % [sim.state.turn, d["type"], str(d.get("event", d.get("city", d.get("unit", d.get("slot", "")))))]
				if int(_fail.get(key, 0)) >= 3:
					continue
				_fail[key] = int(_fail.get(key, 0)) + 1
				target = d
				break
		if target.is_empty():
			break
		_resolve(sim, target)
	_gating = false
	note_seen()


static func _resolve(sim: Sim, d: Dictionary) -> void:
	match str(d["type"]):
		"event_choice":
			var ev = sim.db.event_by_id.get(d["event"])
			sim.choose_event(str(d["event"]), SimAI.pick_event_choice(sim, ev))
		"crisis_response":
			sim.choose_crisis_response(SimAI.pick_crisis_response(sim, d["options"]))
		"dedication":
			sim.choose_dedication(SimAI.pick_dedication(sim))
		"fill_policy":
			if not SimAI.fill_policies(sim):
				sim.state.policies[int(d["slot"])]["id"] = ""
		"choose_research":
			var t := SimAI.pick_research(sim)
			if t != "": sim.set_research(t)
		"choose_civic":
			var c := SimAI.pick_civic(sim)
			if c != "": sim.set_civic(c)
		"choose_production":
			var city = sim.city_by_id(int(d["city"]))
			if city != null:
				var p: Dictionary = SimAI.pick_production(sim, city)
				if p.is_empty() or not sim.set_production(city.id, p["kind"], p["id"], int(p.get("tile", -1))):
					sim.set_city_automated(city.id, true)
		"unit_orders":
			var u = sim.unit_by_id(int(d["unit"]))
			if u != null:
				if sim.military.is_military(u):
					sim.unit_action(u.id, "fortify")
				else:
					u.orders = "skip"    # civilians wait (not sleep), so they come back for their own step
		"agenda":
			sim.choose_agenda(SimAI.pick_agenda(sim))
		"immigration":
			sim.choose_immigration(SimAI.pick_immigration(sim))
		"policy_review":
			SimAI.fill_policies(sim)
			if sim.has_method("confirm_policies"):
				sim.confirm_policies()
		_:
			if sim.has_method("resolve_recommended") and sim.resolve_recommended(d):
				return
			var m := "choose_" + str(d["type"])
			if sim.has_method(m):
				sim.call(m, 0)


# ================================================================== arrow and highlight

func _target_rect() -> Rect2:
	if replaying >= 0 or not active:
		return Rect2()
	var s := cur()
	if story_tut:
		return _story_target(str(s.get("target", "")))
	if not _ready_now(s):
		return _hud_rect(HUD.R_NEXT, true)
	var vw := size.x
	match str(s["target"]):
		"topbar":
			var hk: float = ui.hud._ref_scale()
			return Rect2(256 * hk, 2 * hk, maxf(200.0 * hk, vw - (256 + 560) * hk), 44 * hk)
		"research":
			if ui.research_p.visible:
				return _row_rect(ui.research_p, "Recommended")
			return _hud_rect(HUD.R_RESEARCH)
		"civic":
			if ui.civic_p.visible:
				return _row_rect(ui.civic_p, "Recommended")
			if ui.policy_p.visible:
				return Rect2()
			return _hud_rect(HUD.R_CIVIC)
		"event":
			return Rect2() if ui.popup.visible else _hud_rect(HUD.R_NEXT, true)
		"immigration":
			return Rect2() if ui.popup.visible else _hud_rect(HUD.R_NEXT, true)
		"city":
			if ui.city_s.visible:
				var rr := _row_rect(ui.city_s, "Recommended")
				if rr.size.x <= 0:
					for r in ui.city_s.find_children("*", "UIRow", true, false):
						if (r as UIRow).enabled and (r as Control).is_visible_in_tree():
							return (r as Control).get_global_rect()
				return rr
			return _hud_rect(HUD.R_NEXT, true)
		"next":
			return _hud_rect(HUD.R_NEXT, true)
		"settler", "crew":
			var t := "settler" if str(s["target"]) == "settler" else "builder"
			if ui.unit_p.visible and ui.selected_unit >= 0:
				var b := _button_rect(ui.unit_p, "Found" if t == "settler" else "Build ")
				if b.size.x > 0:
					return b
				return Rect2()
			return _unit_rect(t)
		"ghost":
			if ui.ghost_p.visible:
				return _button_rect(ui.ghost_p, "Why stats moved")
			return _hud_rect(HUD.R_GHOST)
	return Rect2()


func _story_target(t: String) -> Rect2:
	## The real story-mode element a card points at (nothing when it is not on screen or a window covers it).
	var c: Control = null
	match t:
		"goals": c = ui.goals_w
		"now": c = ui.next_w.go_btn
		"report": c = ui.report_w
		"chips": c = ui.next_w.queue_lbl
		"minimap": return _hud_rect(HUD.R_MINIMAP, true) if ui.hud.story_show.has("minimap") else Rect2()
		"ghost": c = ui.goals_w   # (v4 fix round: VS. HISTORY is a line on the era goals card in story mode)
		"gov": c = ui.gov_btn
	if c == null or not c.is_visible_in_tree() or not _windows().is_empty():
		return Rect2()
	return c.get_global_rect()


func _hud_rect(r: Rect2, right := false) -> Rect2:
	var s: float = ui.hud._ref_scale()
	var p := r.position
	if right:
		p.x = ui.hud._xr(p.x)
	return Rect2(p * s, r.size * s)


func _row_rect(root: Node, label: String) -> Rect2:
	for r in root.find_children("*", "UIRow", true, false):
		for l in (r as Node).find_children("*", "Label", true, false):
			if (l as Label).text == label and (r as Control).is_visible_in_tree():
				var gr := (r as Control).get_global_rect()
				if gr.end.y > 0 and gr.position.y < size.y:
					return gr
	return Rect2()


func _button_rect(root: Node, prefix: String) -> Rect2:
	for b in root.find_children("*", "Button", true, false):
		if (b as Button).text.begins_with(prefix) and (b as Button).is_visible_in_tree():
			return (b as Control).get_global_rect()
	return Rect2()


func _unit_rect(t: String) -> Rect2:
	var cam: Camera3D = ui.game.rig.cam
	for u in ui.sim.get_units("player"):
		if str(u["type"]) == t:
			var wp: Vector3 = ui.mv.tile_world(int(u["q"]), int(u["r"])) + Vector3(-0.35, 0.62, 0.3)
			if cam.is_position_behind(wp):
				return Rect2()
			var sp := cam.unproject_position(wp)
			return Rect2(sp - Vector2(18, 18), Vector2(36, 36))
	return Rect2()


func _draw() -> void:
	if not card.visible:
		return
	var tr := _target_rect()
	if tr.size.x <= 0:
		return
	var t := Time.get_ticks_msec() / 1000.0
	var pulse := 0.5 + 0.5 * sin(t * 4.0)
	var g := tr.grow(4 + 3 * pulse)
	var pts := UIKit.rrect_points(g, 8.0)
	pts.append(pts[0])
	draw_polyline(pts, Color(1.0, 0.85, 0.35, 0.55 + 0.4 * pulse), 3.0, true)
	# arrow from the card to the target
	var cr := Rect2(card.position, card.size)
	var a := cr.get_center()
	var b := g.get_center()
	if cr.intersects(g):
		return
	a = _edge(cr, b)
	b = _edge(g, a)
	var dir := (b - a).normalized()
	var tip := b - dir * 4.0
	draw_line(a, tip - dir * 14.0, Color(1.0, 0.85, 0.35, 0.95), 4.0, true)
	var n := Vector2(-dir.y, dir.x)
	draw_colored_polygon(PackedVector2Array([tip, tip - dir * 22.0 + n * 11.0, tip - dir * 22.0 - n * 11.0]), Color(1.0, 0.85, 0.35, 0.95))


static func _edge(r: Rect2, toward: Vector2) -> Vector2:
	## Point on the rectangle's border along the line from its centre toward `toward`.
	var c := r.get_center()
	var d := toward - c
	if d.length() < 0.001:
		return c
	var tx := (r.size.x * 0.5) / maxf(absf(d.x), 0.0001)
	var ty := (r.size.y * 0.5) / maxf(absf(d.y), 0.0001)
	return c + d * minf(minf(tx, ty), 1.0)
