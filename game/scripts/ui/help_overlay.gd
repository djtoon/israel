class_name HelpOverlay
extends UIWindow
## How to Play (the "?" button and F1): one page per system, chosen from the list on the left.

const PAGES := [
	["Start here: story mode", """[b][color=#f7dc8f]Your goal[/color][/b]
You lead the State of Israel from 14 May 1948 to {END_Q}. The big moments of history come on their real dates; you decide how the country answers them.

[b][color=#f7dc8f]A turn in three steps[/color][/b]
1. Look at the [b]NOW[/b] box at the bottom right. It names the one thing that needs you.
2. Press [b]Decide[/b], pick an option on the card and read what happened.
3. When the box says [b]END TURN[/b], press it. A quarter of a year passes and your ministers report.

[b][color=#f7dc8f]What you do not have to do[/color][/b]
Your ministers run the routine for you: research, what the cities build, the army, the policy cards and the yearly paperwork. You can take any of it over at any time (see Your ministers).

[b][color=#f7dc8f]Quiet quarters[/color][/b]
When nothing needs you, the turn can end by itself after a moment. Any click or key stops it. You can turn this off in Settings.

[b][color=#f7dc8f]The tutorial[/color][/b]
The first ten turns come with short cards from the Cabinet Secretary. [b]Skip tutorial[/b] stops them at once, and the last page of this window shows any card again."""],
	["One decision at a time", """[b][color=#f7dc8f]The NOW box[/color][/b]
It always shows the one decision that matters most right now, and a button that takes you to it. If more than one decision is waiting, the others sit above it as small buttons. Click one when you want it first. [b]Enter[/b] works like the big button.

[b][color=#f7dc8f]The decision card[/color][/b]
Each card says what is at stake and what the Cabinet Secretary recommends. It shows at most three options, each with what it will cost and what it will change. History's own choice is always among them. [b]More options[/b] lists the rest, and [b]Details[/b] opens the full screen with the people who argued for each option, the sources and the lasting terms.

[b][color=#f7dc8f]See what happened[/color][/b]
One click takes the option. The card then shows the result in plain words, and the next decision follows in the same card. When the last one is done it offers END TURN.

[b][color=#f7dc8f]Always yours[/color][/b]
Wars and crises, big cabinet decisions, coalition talks, the State Budget priority, envoys, national programmes and the great waves of immigration are never taken out of your hands."""],
	["Your ministers", """[b][color=#f7dc8f]Who runs what[/color][/b]
Your ministers take the Recommended choice in every routine job: research, civics, what each city builds, units, settlement and public works, the yearly immigration plan, policy cards, cabinet appointments, budget reviews, export routes and delegations.

[b][color=#f7dc8f]The brief[/color][/b]
In the second quarter the Cabinet Secretary asks what your ministers should put first: [b]Balanced[/b], [b]Security[/b], [b]Prosperity[/b], [b]Peace[/b] or [b]Society[/b]. The brief tilts their routine choices towards that path to a strong ending. You can change it at any time in the Cabinet Room.

[b][color=#f7dc8f]The ministers' report[/color][/b]
On the left, [b]Your ministers did[/b] lists what they did last quarter, with the quarter's headlines from history. Click it to open or close it.

[b][color=#f7dc8f]Taking over a ministry[/color][/b]
Open the [b]Cabinet Room[/b] (the button on the report, or the game menu). Each ministry has a switch: [b]Minister decides[/b] or [b]You decide[/b]. Switch one to You decide and its decisions come to the NOW box, and its screens appear on the map (for example Research, or the cities). Switch it back and the minister carries on from there."""],
	["Era goals", """[b][color=#f7dc8f]Two or three goals in every era[/color][/b]
The card at the top left shows the goals of the era you are in, each with a bar and a date. Some are due [b]by[/b] a date, others must hold [b]at[/b] that date.

[b][color=#f7dc8f]What they do[/color][/b]
A goal you meet pays a reward. A goal you miss costs a small setback. It never ends the game: goals are a nudge, and the endings still decide how it all went. Each goal is a real aim of its time, with its sources.

[b][color=#f7dc8f]Using them[/color][/b]
Click the card's title to fold it away. When a new era begins, a new set of goals takes its place. The Ending outlook (O) shows how the endings stand."""],
	["Full control", """[b][color=#f7dc8f]The whole game, by hand[/color][/b]
Full control is the original game: every decision is yours, including every city's production and every unit's orders, and every screen is on the screen from the start. Choose it on the New Game screen, or switch at any time in the Cabinet Room (How do you play?) or in Settings, in either direction, in the middle of a game.

[b][color=#f7dc8f]In between[/color][/b]
You do not have to choose all or nothing: take over one ministry in the Cabinet Room and leave the others to the ministers.

[b][color=#f7dc8f]A simpler screen again[/color][/b]
In story mode, [b]Settings, Simplify the screen again[/b] hides what you are not using. It comes back when it matters.

[b][color=#f7dc8f]The reference pages[/color][/b]
The pages after this one describe every system in full: the turn, cabinet decisions, the budget, wars, money, cities, diplomacy and more. They are the reference for Full control, and the same rules run under story mode."""],
	["Reference: the basics", """[b][color=#f7dc8f]Your goal[/color][/b]
You lead the State of Israel from 14 May 1948 to {END_Q}. Each turn is one quarter (Q2 1948 to {END_Q}). Wars, elections, treaties, immigration totals and borders happen on their real dates; how the state is built is yours.
Reach one of the [b]endings[/b] by {END_Q}: a Secure State, a Prosperous State, Peace with Neighbours, a United Society, or A Nation Ahead of history overall (see Endings, and the Ending outlook, [b]O[/b]). Keep clear of the three [b]collapses of the state[/b] (fiscal, public trust, military), which end the game early (see Risks and collapse). Everything is measured against the [b]ghost of history[/b], a recorded run of what really happened, on six tracks: population, economy, science, water, standing and cohesion.

[b][color=#f7dc8f]The tutorial in Full control[/color][/b]
New Game, then [b]Tutorial[/b] with Full control chosen, plays the real game from 14 May 1948 and introduces one system at a time: the war, events, immigration, research, cities, the first war-front orders, the first cabinet decision, civics, money, the first State Budget, towns and crews. Decisions it has not covered yet are taken for you with the Recommended choice. [b]Skip tutorial[/b] on the advisor card switches to the full game at any point. After the tutorial (and in every game for the war, cabinet decisions and the cabinet screens) the Cabinet Secretary explains each new situation once, beside the screen it is about; [b]Turn off tips[/b] stops the cards.

[b][color=#f7dc8f]The big button[/color][/b]
The button at the bottom right always names the next decision that needs you. Click it (or press [b]Enter[/b]) to jump there; the round buttons to its left are the other decisions waiting (hover for the name). When nothing is left it reads [b]NEXT TURN[/b]. [b]Shift+Enter[/b] forces the turn to end: open events take the historical choice."""],
	["The turn", """[b][color=#f7dc8f]Decisions, in the order the button takes them[/color][/b]
1. [b]Event decisions[/b]: dated events that ask you to choose. The option the government actually took is tagged [i]historical[/i]; the others were proposed by named people at the time.
2. [b]Cabinet decisions[/b] (forks): one-time choices with lasting terms. See Cabinet decisions.
3. [b]Crisis response and war-front orders[/b]. See Wars and crises.
4. [b]Coalition talks[/b] and the [b]policy review[/b] of a new government. See Ministers and coalitions.
5. [b]The State Budget[/b] and its [b]mid-year review[/b]. See The State Budget.
6. [b]Immigration[/b]: where the year's arrivals are settled.
7. [b]Ministers[/b], [b]dedications[/b] in a new era, empty [b]policy slots[/b].
8. [b]Research[/b], [b]civic[/b], each city's [b]production[/b] and [b]units[/b] that need orders.
9. [b]The Cabinet Agenda[/b]: the quarter's most pressing issue (housing, the deficit, inflation, water, readiness...).

Effects are coloured by what they do for you: [color=#9fe07a]green helps[/color], [color=#ff8f7a]red hurts[/color]. Things that hurt when they rise (inflation, debt, war weariness, casualties, water demand) are green when they fall."""],
	["Cabinet decisions", """[b][color=#f7dc8f]Forks: decisions that shape the country[/color][/b]
Some decisions are taken once and shape the country for decades: one army or a separate Palmach, the capital, German reparations, the territories, Osirak, Oslo. Each option names who argued for it at the time and the source, what happens [b]now[/b] and its [b]lasting terms[/b]: years of gold, standing, trust, growth or science.

What history chose is revealed after you decide. History's dated events still happen; where an event follows that your choice went against, a note says history took its course, and your lasting terms still apply.

Every choice is listed under [b]Your path[/b] in the ghost of history window (G), and the terms still running are under [b]Ongoing terms[/b]. At the end the game compares your path with history's, choice by choice."""],
	["The State Budget", """[b][color=#f7dc8f]The annual Budget Law[/color][/b]
Every fiscal year the Finance Ministry puts a Budget Law to the Knesset: in Q1 for the April-March years 1949/50 to 1990/91, and in Q4 for the calendar years 1992 to {END_YEAR}. Revenue sets the total; you decide how it is split between four envelopes:
• [b]Defence[/b]: Readiness and staying power in war (less war weariness);
• [b]Immigrant absorption and housing[/b]: housing in every city, immigrant retention, trust in development towns;
• [b]Development and water[/b]: production, water supply, trust in the periphery;
• [b]Education and science[/b]: science and culture.

An envelope at 25% gives nothing extra. Above it gains, below it loses, with diminishing returns: a specialised budget buys a large gain on one track for smaller losses on three. Pick a preset (one is Recommended for the situation: war, deficit, a wave of immigrants...) or drag the sliders (10-55% each); the effects update as you move them. During a war a war budget is offered.

[b][color=#f7dc8f]The mid-year review[/color][/b]
Two quarters later the Finance Ministry reports. The options depend on the year: keep the budget, pass a supplementary budget for the neediest envelope, cut across the board (gold back, some trust lost) or, in wartime, move money to defence."""],
	["Ministers and coalitions", """[b][color=#f7dc8f]The cabinet (K)[/color][/b]
Seven ministers (Defence, Finance, Absorption, Housing, Agriculture, Education, Health) work like regional governors. A new government forms its cabinet on one screen: each portfolio gets its seat city, where a local effect starts after two quarters. Promotions are national programmes (two at tier 1, two at tier 2, a tier-3 capstone); they are offered at most once a year. A new government brings new ministers: seats stay, promotions end. Press [b]K[/b] to see the cabinet and the budget in force; moving a minister's seat is free.

[b][color=#f7dc8f]Coalition talks[/color][/b]
After each election or change of government the prime minister needs partners for a Knesset majority. Each partner was a real party of the day: it brings its programme, takes one portfolio (that minister cannot be promoted this term) and a budget for its voters. A narrow coalition keeps every portfolio but costs cohesion. The terms last for the government's term and show under Ongoing terms (G).

[b][color=#f7dc8f]Policy cards[/color][/b]
Civics unlock policy cards, slotted into your government (P). The coalition type sets the slots. A new government, a new civic or a new era makes swapping free; otherwise a swap costs gold. A new government asks you to review its cards."""],
	["Wars and crises", """[b][color=#f7dc8f]The first response[/color][/b]
When a war or crisis begins you choose the state's response: mobilise the reserves, civil defence, international backing or the standing forces. Each option's price depends on what you have built: mobilisation is cheaper when Civic Trust is high, backing needs Standing 50 or more, and Readiness makes every blow harder.

[b][color=#f7dc8f]Orders for the front[/color][/b]
Each later quarter of a war you decide where the reserves go: commit them to a named front (a counter-attack there; some production lost), mobilise fully (every front; gold and more production), or hold with the standing forces (no cost, but the enemy keeps the initiative and strikes towns). Wars with several phases in one quarter (1967, 1973) ask for each phase in turn, and concurrent wars each get their own orders.

[b][color=#f7dc8f]Reading a front preview[/color][/b]
Each order leads with [b]that front's stake[/b]: the towns it covers and their residents, how many enemy formations there it pins down this quarter (a formation hit hard does not strike), and the strikes on towns it spares compared with holding. Below: the share of the enemy's strength it takes away, our cost, the other populations at risk, and the modifiers (ground, distance, enemy strength, Readiness).

How a war ends is history; what it costs is yours. Cities are never captured, but they can be damaged. After a war the readiness lessons learned depend on how it was fought."""],
	["Money: debt and inflation", """[b][color=#f7dc8f]The Treasury[/color][/b]
The number after the Treasury in the top bar is its change per quarter: taxes and trade in; building upkeep, public services, absorption of newcomers and imports out. A deficit eats the Treasury; below zero it is [b]debt[/b]: every city loses an amenity and inflation rises. Loans abroad cover a hole, but they must be serviced and repaid, and the amount you can borrow depends on the economy and your standing.

[b][color=#f7dc8f]Inflation[/color][/b]
Prices follow history's path as a backdrop (the 1950s austerity, the 1980s hyperinflation, the 1985 stabilisation plan). Your deficits, debt, surpluses and policies move a lasting gap above or below it. High inflation erodes your income, makes buying dearer, presses Civic Trust down and holds the economy back.

[b][color=#f7dc8f]What digs you out[/color][/b]
Austerity and the budget agenda, export routes, gold buildings, lower upkeep, and the right policy cards. Some burdens wait for a specific policy: the post-1973 defence burden and indexed wages, for example, last until a stabilisation programme is adopted. Ongoing terms (G) lists every stream still running, and the Why stats moved tab says what moved inflation, trust, standing and readiness each quarter.

[b][color=#f7dc8f]Running costs and the fiscal levers[/color][/b]
Every building, district, public service and unit costs upkeep each quarter. When running costs and debt service stay above revenue quarter after quarter, the state has a [b]structural deficit[/b]: the alarm names what the upkeep is, and loans only postpone it. Click the Treasury or the debt-and-inflation coin on the top bar for the running costs and three levers:
• [b]Mothball or close buildings[/b]: a mothballed building stops working and keeps a fifth of its upkeep until you reopen it; a closed one costs nothing, for good. Each city's buildings are in its City screen, tab Upkeep, least used first; the levers window offers a plan for the whole country.
• [b]Privatise state companies[/b]: gold now and lower upkeep for years, at some cost in trust; each sale is history's, on its date, or proposed at the time by a named advocate.
• [b]An emergency stabilisation package[/b]: deep cuts, a wage freeze and an anchor for inflation, as in 1949, 1966 and 1985; it costs trust, amenities and a year of output, and is possible only in a crisis."""],
	["Immigration", """[b][color=#f7dc8f]Placing the immigrants[/color][/b]
The number of immigrants follows history (CBS figures); where they go is yours. Once a year, and again when a named wave begins, you choose a plan for the coming four quarters:
• [b]the large cities[/b]: jobs at hand, little housing;
• [b]development towns[/b]: grow the periphery, trust falls until jobs arrive;
• [b]moshavim and kibbutzim[/b] (before 1980): more food, more water demand;
• [b]transit camps[/b] (ma'abarot before 1965; caravan sites in 1990-93): cheapest now, but people in camps cost trust and growth until housing is built.

Each option shows its gold cost, the housing room and how many people end up in camps. Newcomers draw absorption costs for two years."""],
	["Cities and units", """[b][color=#f7dc8f]Cities[/color][/b]
Click a city (its tile or its banner) to open the city screen: population, food and housing, yields, the tiles it works, and the production list with turns. Click an item to build it now, Shift+click to queue it, or buy it with Gold or Cohesion. Districts open a placement view: the number on each tile is its adjacency bonus and the star marks the best. Tabs: Production, Citizens (lock the tiles a city works), Purchase, Details. Small towns start on [i]Automate[/i]; untick it to manage them yourself.

[b][color=#f7dc8f]Units[/color][/b]
Click a unit's tile to select it; highlighted tiles show where it can go. [b]Settlement Groups[/b] found real localities: gold tiles are the places open for founding, from six years before their real date; move there and press [b]Found Town[/b] (B). [b]Public Works Crews[/b] improve tiles: green tiles are valid. Military units: [b]F[/b] fortify, [b]Space[/b] skip; hovering an enemy shows the combat preview with the odds."""],
	["Diplomacy", """[b][color=#f7dc8f]The diplomacy screen (I)[/color][/b]
The partners of the date run down the left: neighbouring states, the powers, the UN and, in their eras, the European Community, the Gulf states, the PLO and the Palestinian Authority. Names follow the date (the USSR becomes Russia in 1991, West Germany becomes Germany in 1990). Each has a [b]relation[/b] from -100 to 100, shown as a level from Hostile to Strategic partner, with its trend.

[b][color=#f7dc8f]Why a relation is what it is[/color][/b]
The legal status (war, armistice, treaty, relations...) follows history and sets a baseline. On top of it come live causes (Standing for the Western powers, export routes) and remembered ones that fade over about five years: historical events, your cabinet decisions, deals, envoy answers and delegations. The screen itemises every cause, with its source.

[b][color=#f7dc8f]Deals, envoys and delegations[/color][/b]
• [b]Deals[/b]: each partner offers the deals of its era (aid, loans, arms, trade, reparations, back channels...). The deal screen shows what Israel gives and gets, now and for years, how third parties react, and why a deal is not acceptable yet.
• [b]Envoys[/b]: every few quarters a partner sends an envoy, makes a request or offers a deal. Each answer names who argued for it at the time; what Israel actually did is shown after you answer.
• [b]Delegations[/b]: send one to improve a relation for a while (Gold, every two years per partner).
• [b]Dependence[/b]: arms and aid from one patron make Israel depend on it. When that patron historically used its leverage (France in 1967, the 1975 reassessment...), the dependence costs you."""],
	["National programmes", """[b][color=#f7dc8f]The late-game projects of a state[/color][/b]
Ten programmes, each a chain of real levels: MASHAV, Talpiot, the start-up economy, space and cyber, the missile shield, desalination, the gas fields, the peace dividends, the Arab-sector plans and national health insurance. Some levels are history's, on their real dates; others are proposals history did not carry out, each with its named advocate and source. After the last level a programme can be expanded again and again.

[b][color=#f7dc8f]How they work[/color][/b]
A level opens up to eight years before history's date once its technology, civic or diplomatic condition holds (a little dearer for each year early). It is paid in quarterly instalments; a quarter the Treasury cannot pay pauses it, and cancelling loses what was paid. Once complete it adds lasting terms and a gain on one or more of the six tracks that grows over four years.

The ghost of history takes the historical levels on their real dates, so the gain comes from launching early, from the levels history never built and from expansions. Programmes ahead of history's are also thresholds of the endings. When a level opens, or when the Treasury holds a large surplus, a [b]National programme[/b] decision asks what to fund; the National programmes panel (in the game menu, the ≡ button at the top right) lists every programme at any time."""],
	["Difficulty and scenarios", """[b][color=#f7dc8f]Difficulty (New Game)[/color][/b]
• [b]Easy[/b]: history is a softer benchmark (its record counts 6% lower), a larger 1948 treasury, inflation that answers slowly to deficits, weaker enemy formations and cheaper programmes. For learning the systems.
• [b]Normal[/b]: history's record as it was. The intended game.
• [b]Hard[/b]: history counts 6% higher, a thinner treasury, deficits feed inflation faster, stronger enemy formations, dearer programmes.
• [b]Historian[/b]: Hard's benchmark and pressures (history counts 10% higher), with no Recommended badges and history's own choice hidden until after you decide.
The difficulty also sets how long a collapse of the state takes. The ghost of history always plays as it really happened.

[b][color=#f7dc8f]Scenarios[/color][/b]
Besides 14 May 1948, New Game can start in [b]1967[/b], [b]1977[/b] or [b]1992[/b]: the state as history left it at that date (cities, borders, technologies, treasury, debt, diplomacy and lasting terms), level with the ghost, with a short briefing on the moment. Every decision from then on is yours."""],
	["Measured against history", """[b][color=#f7dc8f]The ghost of history (G)[/color][/b]
VS. HISTORY compares your Israel with the ghost on six tracks from Q2 1950, once your choices have had time to matter. Each track shows the real-world figure for the date (CBS population, GDP per capita, R&D share, water use). Tabs list itemised reasons, Your path (your choices against history's), Ongoing terms (lasting streams) and Why stats moved.

[b][color=#f7dc8f]The end[/color][/b]
After {END_Q} the game fades to black and shows the memorial text for 7 October 2023, in its author's own words. The end screen follows: the ending you reached and its epilogue, the thresholds of every ending, the six tracks against history, what made the difference, the key stats over time and your whole path, choice by choice. After a collapse of the state the game ends at that date instead, with no memorial. You can keep viewing the map afterwards."""],
	["Endings", """[b][color=#f7dc8f]Five endings, judged on the last quarter[/color][/b]
Each ending has three to five thresholds, and every one must hold in {END_Q}:
• [b]Secure State[/b]: high Readiness, no more strikes on towns than history saw, security programmes ahead of history's (the missile shield, Talpiot, space and cyber) and allies' backing (Standing).
• [b]Prosperous State[/b]: economy and science ahead of history, inflation and public debt under control, and prosperity programmes ahead of history's (start-ups, desalination, gas).
• [b]Peace with Neighbours[/b]: treaties in force with neighbouring states, high Standing, and peace programmes ahead of history's (MASHAV, the peace dividends).
• [b]United Society[/b]: cohesion ahead of history, no group left far behind (the lowest Civic Trust among Arab localities, development towns and the periphery), few residents short of housing, and society programmes ahead of history's.
• [b]A Nation Ahead[/b]: no single path carried through, but an overall score well ahead of history's record (after the state's health) with no collapse in sight.
If several are met, the one with the widest margin is the headline and the others are listed as also reached. If none is met, the game ends with [b]A Mixed Record[/b].

[b][color=#f7dc8f]The Ending outlook (O)[/color][/b]
The Ending outlook tab of the ghost of history window shows every ending with its thresholds, where you stand on each now and which ending you are closest to. The risks to the state are listed below them. History's own run usually ends as a Mixed Record: getting ahead of it takes choices history did not make."""],
	["Risks and collapse", """[b][color=#f7dc8f]Three ways the game ends early[/color][/b]
• [b]Fiscal Collapse[/b]: public debt and the overdraft far past what lenders will carry, with runaway inflation.
• [b]Collapse of Public Trust[/b]: national Civic Trust very low, a large share of residents in cities in unrest or alienated from the state, and repeated government crises.
• [b]Military Collapse[/b]: a war under way with Readiness very low and enemy strikes on towns far beyond history's by that date.
A collapse does not come at once. Each quarter its conditions all hold, its strain grows by one; each quarter they do not, or the trend turns (debt or inflation falling, trust rising, readiness rebuilt), it eases. On Normal a collapse needs about three years of strain (a military one less), and the first warning comes quarters before the end.

[b][color=#f7dc8f]How you are warned[/color][/b]
The top bar colours Civic Trust and the coin of debt and inflation: [color=#ffc75c]amber[/color] means watch it, [color=#ff8f7a]red[/color] means act now; hover them for the reasons. The debt-and-inflation indicator has four tiers: ok, watch, warning and danger. When a collapse is in danger a red triangle with the quarters left joins the top bar, the advisor explains what is wrong and how to recover (with or without tips), and the Ending outlook (O) lists each condition. A collapse ends the game at once, without the memorial; the end screen says what went wrong and what might have changed it.

[b][color=#f7dc8f]What turns it around[/color][/b]
Money: cut building upkeep, answer the budget agenda, raise exports, borrow less, and adopt a stabilisation programme when inflation runs away (see Money). Civic Trust: housing, the periphery and the development towns, fewer camps, the right coalition and policies. War: the defence envelope of the State Budget, the war budget and full mobilisation."""],
	["Saves and the Civilopedia", """[b][color=#f7dc8f]Civilopedia[/color][/b]
The book button at the top right opens the reference: every technology, civic, building, district, unit, locality, event, war, government and policy card, searchable, with its sources. Right-click a node in the tech tree, or press a [b]?[/b] button beside a name, to jump to its entry. Every event and choice lists its source ids; the sources themselves are in the Civilopedia.

[b][color=#f7dc8f]Saves[/color][/b]
[b]Ctrl+S[/b] and [b]Ctrl+L[/b] open the Save and Load windows with named slots. The game autosaves every 4 turns and keeps the last 3. [b]F5[/b] quick-saves and [b]F9[/b] quick-loads. On the title screen, [b]Continue[/b] loads your newest save of any kind; a finished game opens on its end screen."""],
	["Keys", """Enter: next decision   |   Shift+Enter: force end of turn
R research   |   T tech tree   |   C civics   |   P policies   |   K cabinet   |   I diplomacy   |   G ghost of history   |   O ending outlook   |   L event log
. next unit   |   F fortify   |   Space skip   |   B found a town
F5 quick-save   |   F9 quick-load   |   Ctrl+S save   |   Ctrl+L load   |   F1 this help   |   F2 Civilopedia   |   F10 settings   |   Esc close   |   F11 fullscreen
Every key can be changed in Settings, Controls.
Camera: drag with the mouse, wheel to zoom, WASD / arrows or the screen edges to pan, Q / E to rotate."""],
]

var page := 0
const STORY_PAGES := 5          # the story-mode pages at the head of PAGES; the rest is the reference
const BODY_SIZE := 18           # v4polish: a larger body text (was 16)
var ref_open := false           # story mode: the reference pages are unfolded


func _init() -> void:
	super._init("How to Play")


static func all_text() -> String:
	var t := ""
	for p in PAGES:
		t += str(p[0]) + "\n" + V3Adapter.endify(str(p[1])) + "\n\n"
	return t


func show_page(i: int) -> void:
	page = clampi(i, 0, PAGES.size())
	refresh()


func refresh() -> void:
	clear_body()
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	body.add_child(h)
	var tabs := VBoxContainer.new()
	tabs.add_theme_constant_override("separation", 4)
	tabs.custom_minimum_size = Vector2(230, 0)
	h.add_child(tabs)
	# v4polish (new-player help.png): in story mode the five story pages come first and the reference pages fold under
	# one "Reference" heading (open while a reference page is shown); Full control lists every page
	var story: bool = ui != null and ui.has_method("is_story") and ui.is_story()
	if page >= STORY_PAGES and page < PAGES.size():
		ref_open = true
	for i in PAGES.size() + 1:
		if story and i == STORY_PAGES:
			var rb := UITheme.button(("▾ " if ref_open else "▸ ") + "Reference (%d pages)" % (PAGES.size() - STORY_PAGES), func(): ref_open = not ref_open; refresh(), 16)
			rb.name = "help_reference"
			rb.alignment = HORIZONTAL_ALIGNMENT_LEFT
			rb.add_theme_color_override("font_color", UIKit.GOLD)
			tabs.add_child(rb)
		if story and i >= STORY_PAGES and i < PAGES.size() and not ref_open:
			continue
		var nm: String = str(PAGES[i][0]) if i < PAGES.size() else "Tutorial cards"
		var idx := i
		var b := UITheme.button(("   " if story and i >= STORY_PAGES and i < PAGES.size() else "") + nm, func(): show_page(idx), 16)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if i == page:
			b.add_theme_color_override("font_color", UIKit.GOLD_LIGHT)
			b.add_theme_stylebox_override("normal", UITheme.sb(Color(0.13, 0.22, 0.42, 0.98), UIKit.GOLD_LIGHT, 1, 5, 10))
		tabs.add_child(b)
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.custom_minimum_size = Vector2(640, 560)
	h.add_child(right)
	if page < PAGES.size():
		right.add_child(UITheme.title(str(PAGES[page][0]).to_upper(), 20, UIKit.GOLD_LIGHT))
		var r := UITheme.rich(V3Adapter.endify(str(PAGES[page][1])), BODY_SIZE, false)
		r.size_flags_vertical = Control.SIZE_EXPAND_FILL
		r.scroll_active = true
		right.add_child(r)
	else:
		right.add_child(UITheme.title("TUTORIAL CARDS", 20, UIKit.GOLD_LIGHT))
		right.add_child(UITheme.rich("Show any tutorial card again (it does not change your progress).", 16))
		var fl := HFlowContainer.new()
		fl.add_theme_constant_override("h_separation", 4)
		fl.add_theme_constant_override("v_separation", 4)
		if ui and ui.tutorial:
			for i in int(ui.tutorial.steps.size()):
				var idx2 := i
				fl.add_child(UITheme.button("%d. %s" % [i + 1, ui.tutorial.steps[i]["title"]], func(): close(); ui.tutorial.replay(idx2), 16))
		right.add_child(fl)
	var bh := HBoxContainer.new()
	bh.add_theme_constant_override("separation", 8)
	var pb := UITheme.button("Civilopedia", func(): close(); ui.open_pedia(), 18)
	pb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bh.add_child(pb)
	var gb := UITheme.button("Got it", func(): close(), 18)
	gb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bh.add_child(gb)
	body.add_child(bh)
