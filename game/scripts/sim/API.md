# Simulation API (for the UI)

The sim is headless and has no rendering code. Everything goes through one object, `Sim` (`scripts/sim/sim.gd`, a `RefCounted` with signals). These signatures are **stable**: additions are allowed, but renames and removals go through the lead.

Ids are as follows:
- **Cities** are `int` (`city.id`); the cities.json id is `key`.
- **Units** are `int`.
- **Techs, civics, buildings, districts, policies, events and actors** are the string ids used in `game/data/*.json`.
- **Map positions** are offset `(q, r)`, the same as map.json.

Dictionaries returned by `get_*` are copies or views; never mutate them. All changes go through the methods.

## 1. Create, load, save

```gdscript
var sim := Sim.new()
sim.new_game({"mode": "player", "seed": 1948})   # mode "historical" = the ghost autoplayer
sim.save_game("user://save1.json")   # -> bool
sim.load_game("user://save1.json")   # -> bool (replaces state; connect signals before or after, either works)
sim.dispose()                        # optional: break helper cycles when discarding a Sim
```
`new_game` leaves you at the start of turn 1 (Q2 1948) with `turn_started` already emitted. Signals emitted during `new_game` fire before you can connect, so read the state with the queries below.

## 2. The turn loop and "Next Action"

```gdscript
sim.get_date()               # {turn, label:"Q2 1948", year, quarter, last_turn:315, era, era_name, age}
sim.next_action()            # {type, blocking, label, ...} first blocking decision, or {type:"end_turn", label:"NEXT TURN"}
sim.get_pending_decisions()  # every open decision this turn (blocking and non-blocking)
sim.blocking_decisions()     # just the blocking ones
sim.end_turn()               # -> bool. false (and nothing happens) while a blocking decision is open
sim.end_turn(true)           # force (Shift+Enter): unresolved events take the historical choice
```
Decision `type` values follow the Civ VI end-turn button order. Labels are ready to display.

| type | blocking | extra keys | resolve with |
|---|---|---|---|
| `event_choice` | yes | `event`, `choices` | `choose_event(event_id, index)` |
| `crisis_response` | yes | `options` [{id,label,cost,available,desc}]; `war_turn` true on the per-turn front decision | `choose_crisis_response(index)` |
| `immigration` | yes | `options` [{id,label,text,effects,gold,arrivals,housing_room,camp_residents,towns}], `historical` (option id) | `choose_immigration(option_id)` |
| `dedication` | yes | `options` [{id,name,goal,golden}] | `choose_dedication(id)` |
| `fill_policy` | yes | `slot`, `slot_type` | `set_policy(slot, policy_id)` |
| `choose_research` | yes | | `set_research(tech_id)` |
| `choose_civic` | yes | | `set_civic(civic_id)` |
| `choose_production` | yes | `city` | `set_production(city_id, kind, id[, tile])` |
| `unit_orders` | yes | `unit` | `unit_action(unit_id, ...)` |
| `agenda` (Cabinet Agenda) | yes | `options` [{label, fx}], `text` | `choose_agenda(index)` |
| `trade_route` | no | | `start_trade_route(city_id, partner)` |
| `ministry` | no | | `appoint_ministry(ministry, city_id)` |

Every turn has at least one blocking decision.
- **Cabinet Agenda.** Pressing items (budget deficit, inflation, housing shortage, water deficit, low readiness, falling standing) come up *alongside* other decisions. The routine yearly budget emphasis comes only when nothing else blocks.
- **Immigration placement (`immigration`).** In every quarter with 10,000+ arrivals (the national total is a rail, CBS S276), the player decides where they go:
  - `cities`: the large cities;
  - `dev_towns`: development towns;
  - `villages`: new moshavim and kibbutzim;
  - `camps`: transit camps (ma'abarot).

  Each option shows its gold cost, the housing room and how many people end up in camps. Camp residents stay until housing is built (`city.camp`, shown in `info.transit`), and cost trust and growth meanwhile. Newcomers also draw absorption upkeep for two years (in `last_budget.absorption`).

## 3. National state

```gdscript
sim.get_national_summary()
# {food, production, gold, science, culture, cohesion (per turn), pop, residents, rural,
#  gold_treasury, gold_net, inflation, cohesion_treasury, standing, readiness, war_weariness,
#  water:{supply,demand,ratio,reserve,deficit_turns,per_capita}, cities, techs, civics,
#  current_tech, current_civic, avg_trust, government:{start,pm,type,type_info:{name,slots}}}
sim.get_upcoming_events(8)   # dated horizon strip: [{turn, date, title, kind, id}]
sim.get_event_log(20)        # [{turn, id, title, kind, date, choice?}]
sim.get_notifications()      # this and last turn's notifications [{turn, kind, text, ...}]
sim.get_timeline()           # historic moments [{turn, date, text, score, kind}]
sim.get_diplomacy()          # [{id, name, kind, status, relation, since, trade_partner, delegation_ready}]
sim.get_crises()             # active scripted crises
sim.get_foreign_places()     # non-player places (e.g. Palestinian cities) with sourced population and status
```

## 4. Cities and production

```gdscript
sim.get_cities()            # [{id, key, name, q, r, pop, residents, capital, trust, producing, kind}]
sim.get_city(city_id)       # everything for the city screen:
#   pop, residents, yields{food,production,gold,science,culture,cohesion}, turns_to_grow,
#   info{housing, transit (residents in transit camps), amenity_balance, amenity_state, trust_band,
#        growth_mult, worked, specialists, defense, ...}, buildings[], districts{id: tile_key},
#   queue[], producing{kind,id,cost,progress,turns}, tiles[[q,r]], district_cap, ghost_residents (census)
sim.get_buildable(city_id)  # production panel rows: {kind, id, name, cost, progress, turns, available, reason,
#                             gold_cost, cohesion_cost, sites?}   kind in building|district|unit|project|city_project
sim.get_district_sites(city_id, district_id)   # [{q, r, adjacency, appeal}], best first (placement lens)
sim.set_production(city_id, kind, id, tile := -1)  # tile = SimHex.key(q, r) for districts (-1 picks the best)
sim.enqueue(city_id, kind, id, tile := -1)
sim.clear_queue(city_id)
sim.purchase(city_id, kind, id, "gold" | "cohesion")   # Civ VI: 4x gold, 2x cohesion; districts and projects cannot be bought
sim.get_purchase_cost(city_id, kind, id, currency)     # -1 if not purchasable
sim.get_buyable_tiles(city_id) / sim.buy_tile(city_id, q, r)
sim.set_city_focus(city_id, "" | "food" | "production" | "gold" | "science" | "culture")
sim.set_city_automated(city_id, true)   # the city picks its own production
sim.get_tile(q, r)          # {terrain, feature, resource, region, owner, owner_name, improvement, district, yields, in_border, appeal, river, units}
```

## 5. Research, civics, policies, government

```gdscript
sim.get_techs()   # [{id, name, era, year, cost, progress, done, available, reason, boosted, boost_text, unlocks, prereqs, source, description}]
sim.get_civics()  # same, plus rail: true for civics that arrive only on their historical date
sim.set_research(tech_id) -> bool
sim.set_civic(civic_id) -> bool
sim.get_policy_state()   # {slots:[{slot:"military|economic|diplomatic|wildcard", id}], available:[ids], free_swap, swap_cost, government}
sim.set_policy(slot_index, policy_id) -> bool   # "" empties; changing a filled slot costs gold unless free_swap
```
Elections and changes of government fall on their real dates (`governments.json`). The coalition type sets the slot layout, and `free_swap` is true that turn. Completing a civic, an election event and a new era also grant a free swap. Empty slots raise `fill_policy`.

## 6. Events and crises

```gdscript
sim.get_pending_events()   # [{event, title, title_he, summary, date, kind, source, choices:[{index,label,effects,note,historical,source}]}]
sim.choose_event(event_id, index) -> bool
```
After a choice, a `notification` of kind `what_happened` names the historical option. Rails (diplomacy, territory, city status, foundings, immigration totals) always follow history, but **their terms follow the choice**.
- **Multi-year terms.** `game/data/choice_terms.json` gives choices streams: per-turn gold, standing or trust, or a readiness level, between two dates. It also gives blocks: later rail-event effects that will not apply.
  - Example: refusing German reparations removes the 1953-65 reparations stream, and the Luxembourg agreement then fires without its gold.
- **Civics.** A civic offered by an option you did not take is never adopted by rail. Civics of an event with choices arrive only with the choice, never before the pick.
- **What the UI shows:**
  - each choice in `choices[]` has `terms` (ready-to-show strings);
  - after the pick, a `terms` notification says "Your path: ...".

```gdscript
sim.get_streams()          # [{type, amount, from, until, label, src, active, group?, target?}] lasting terms of choices and forks
                           #   type: gold|standing|standing_target|trust|trust_base|readiness|output_pct|science_pct|growth_pct|
                           #         water|inflation|cohesion|amenity|retention|immigrant_weight (see FORKS.md)
sim.get_stat_log(stat="")  # [{turn, stat, amount, reason, lasting?}]: every change of standing, trust, readiness, inflation and
                           #   cohesion with its reason, lasting terms when chosen (lasting: true), and yearly drift summaries by cause
```
Every one-off change of International Standing is notified (kind `stat`) with its reason. Each Q4 a `stat` notification sums the year's drift by cause, e.g. "International Standing -2.1 over the past year: territory held under military control -1.4, ...".

Wars are a few turns of decisions.
- **Turn 1:** the `crisis_response` choice (mobilise / civil defence / backing / standing forces).
- **Each later turn of a war:** a `crisis_response` with `war_turn: true`. Commit the reserves to a named front (counter-attack there; -15% production that turn), full mobilisation (all fronts; gold and -30% production), or hold with standing forces (no cost; the enemy keeps the initiative and strikes a front town).

How the war ends is fixed. City damage, enemy losses, trust, war weariness and the readiness lesson depend on the choices.

Wars start a crisis. The `crisis_response` decision options depend on lasting national state: mobilization costs less when trust is high, and backing requires Standing 50 or more. Hostile units appear outside the lines; cities are never captured. Readiness, Standing and Civic Trust scale the costs of every later crisis.

## 7. Units

```gdscript
sim.get_units("player")   # [{id, type, name, cls, owner, q, r, hp, moves, max_moves, cs, rs, range, charges, orders, level, xp, crisis, target, needs_orders}]
sim.get_units("")         # all units, including hostile forces in a crisis (owner = actor id)
sim.reachable_path(unit_id, q, r)    # [Vector2i] path the unit would take
sim.combat_preview(unit_id, q, r)    # {attacker, defender, delta, damage_dealt, damage_taken, ranged}
sim.unit_action(unit_id, "move", {"q": q, "r": r})     # moves as far as possible; keeps a goto order
sim.unit_action(unit_id, "attack", {"q": q, "r": r})
sim.unit_action(unit_id, "fortify" | "skip" | "sleep" | "wake" | "disband")
sim.unit_action(unit_id, "found_city", {"radius": 3})  # Settlement Group: snaps to the nearest real locality
#   -> {ok, city, snapped_to, historical_date} or {ok:false, reason, nearest:[targets]}
sim.unit_action(unit_id, "build", {"improvement": "farm"})   # Public Works Crew on its own tile
sim.get_settle_targets()  # [{id, name, q, r, historical_turn, historical_date, kind}] localities open for founding now
```
Settlers may found only real localities from cities.json inside the 1949 armistice lines, from 6 years before their real founding date. If the player hasn't founded a locality by its real date (plus a 4-turn grace), history founds it. Post-1967 localities beyond the Green Line appear only on their historical dates.

Improvement ids are `farm`, `kibbutz`, `moshav`, `grove`, `fish_ponds`, `pasture`, `mine`, `mine_minerals`, `quarry`, `forest_planting`, `drip_farm`, `oil_well`, `gas_platform` and `solar_field`.

## 8. Score versus the ghost of history

```gdscript
sim.get_score()
# {turn, date, has_ghost, ahead, even, behind, summary ("Ahead in 2, level in 3, behind in 1"), overall,
#  tracks:[{id, name, player, ghost, ratio, ahead, status: ahead|even|behind (within 1% = even), points,
#   label:{history, player, unit, source}}], reasons:[{track, turns, text}]}
sim.get_history()   # per-turn samples [{t, v:{population, economy, science, water, standing, cohesion, ...}, g:{ghost...}, real_pop}]
```
The ghost is `game/data/ghost.json`, a recorded run of the Historical Israel autoplayer (`sim_test.gd` regenerates it). Tracks are in game units. `label` carries the real-world figure for the date (CBS population S119, Maddison GDP per capita S500, FAO water S501, R&D share S502) and the player's equivalent on that scale. `reasons` are itemised, for example "Seawater Desalination 8 turns earlier than history".

## 9. Signals

```
turn_started(turn: int, date: String)         turn_ended(turn: int)
notification(n: Dictionary)                   game_over(summary: Dictionary)
city_founded(city_id) city_changed(city_id) city_removed(city_id)
production_completed(city_id, kind, item)     territory_changed()
tech_completed(id) civic_completed(id)        boost_triggered(kind: "tech"|"civic", id, text)
event_fired(event_id)                         crisis_started(crisis) crisis_ended(report)
unit_created(unit_id) unit_moved(unit_id, from: Vector2i, to: Vector2i) unit_removed(unit_id)
combat(result: Dictionary)                    diplomacy_changed(actor, status)
era_changed(era: int, age: String)            historic_moment(m: Dictionary)
```

## 10. Other actions

```gdscript
sim.choose_agenda(index) / sim.choose_dedication(id) / sim.choose_crisis_response(index)
sim.trade_partners() / sim.trade_capacity() / sim.start_trade_route(city_id, partner_actor_id)
sim.send_delegation(actor_id)        # gold -> relation and standing (every 8 turns per actor)
sim.ministry_titles() / sim.appoint_ministry("absorption"|"agriculture"|"housing"|"education"|"health"|"economy", city_id)
```

## Helpers

- `SimHex.key(q, r)` / `SimHex.from_key(k)`: tile keys used in `districts` and `tile` arguments.
- `SimHex.neighbors(q, r)` and `SimHex.distance(a, b)`.
- `SimDB.get_db()`: static data (`techs`, `civics`, `buildings`, `districts`, `units`, `policies`, `events`, `cities`, `tiles`). `SimDB.date_label(turn)` formats a turn.
- Recommendations ("Recommended" badges): `SimAI.pick_research(sim)`, `SimAI.pick_civic(sim)` and `SimAI.pick_production(sim, sim.city_by_id(id))` return what the autoplayer would pick.


## Round-2 additions (sim)

- **Buying the current build:**
  - `sim.purchase(city_id, kind, id)` now works for the item in production or in the queue (Civ VI "buy the current build").
  - `sim.current_purchase(city_id)` returns `{kind, id, gold_cost, cohesion_cost, reason}` for the "Producing:" line's Buy button.
- **Research and civic window:**
  - Techs and civics open up to 15 years before history, at +4% cost per year early.
  - The repeatable civic `national_programmes` (+Standing, +Cohesion) is always available.
  - Science and culture earned while nothing is selected carry over into the next choice (`counters.science_unspent` / `culture_unspent`).
- **National projects:**
  - Project rows in `get_buildable` count the 12% national-production contribution in `turns`.
  - `SimAI.plan_projects(sim)` returns `{city_id: project_id}`, the recommended city for each project now. `pick_production` uses it.
- **City sizes:**
  - Cities follow their CBS census paths (cities.json): placement uses the historical growth, and a slow internal migration pulls each city back.
  - The player's housing, amenities and trust move a city by -15%..+12%.
  - Jerusalem gains East Jerusalem's 66,000 residents in June 1967 (real_series.json `city_joins`, S582).
  - `sim.econ.census_target(city, year)` and `sim.econ.census_fit(year)` expose the paths.
- **Lasting stats:**
  - Civic Trust drifts to 80, and gains shrink near 100. Inflation, active crises, war weariness and choice streams press it down.
  - Readiness is `100*(1-exp(-capacity/requirement))`, plus lessons, minus crisis strain, plus streams. The requirement grows each era. `counters.readiness_parts` has the breakdown.
- **Inflation:**
  - The historical CPI arc (World Bank S583; ~450% annualised in 1984, S584; the 1985 plan) is the backdrop.
  - The player's deficits, debt, surpluses and policies move a lasting gap: `counters.inflation_parts`, `sim.inflation_baseline(year)`, `sim.inflation_gap()`. The ghost has history's inflation exactly.
  - Debt is eroded by inflation.
- **Names and milestones:**
  - Dated city names (`governments.json` `city_names`): Tel Aviv until 19 Aug 1950, then Tel Aviv-Yafo (S585). The capital moves to Jerusalem on 23 Jan 1950 (S586).
  - Pre-1948 institutions are milestones at turn 1, so no "first University 1951" reason appears. Tel Aviv starts with a Cultural Center and Theatre (Habima, S587).
  - Population milestones count cities that start above a threshold.
- **Boosts:**
  - A boost names its tech or civic.
  - Boosts for items more than 15 years ahead of history do not trigger.
  - "Rocket fire" boosts count only rocket hits.
- **Data files:** `game/data/actors.json` and `game/data/real_series.json` moved from `scripts/sim/data/`. The new `game/data/choice_terms.json` holds the choice terms.


## Round-4 additions (sim): forks, war fronts, recommended picks

Fork decisions are one-time cabinet decisions that come from `game/data/forks/*.json` (the schema is in `scripts/sim/FORKS.md`).
- **Decision.** It appears in `get_pending_decisions()` as `{type: "fork", blocking: true, label: "CABINET DECISION: <title>", fork, title, text, source, options}`. It sits right after `event_choice` in `next_action()` order.
- **Option.** Each option is `{id, label, advocate, historical, now: [text], lasting: [text], cite: [{source, quote?, url?}], note}`. `historical` marks the real choice; the UI may hide it until after the pick, as with events.

```gdscript
sim.choose_fork(fork_id, option_id_or_index) -> bool  # applies "now" effects; lasting terms become streams to their end date
sim.get_fork(fork_id) -> Dictionary                   # same view as the decision
sim.get_path_ledger() -> Array                        # "Your Israel vs history": [{id, title, chosen, historical, terms: [text], turn}]
sim.resolve_recommended(decision) -> bool             # resolve one decision with the Recommended pick (same code as SimAI; for the tutorial)
```

War fronts come from `game/data/wars/*.json`:
- **Front turns.** A war's `crisis_response` turn decisions offer one option per named front with live enemy formations, plus `full_mobilization` and `economy_first`.
- **Option ids.** Front options have id `dfront:<front id>`, a `front` name, and a `desc` with the formation count and the strike strength (45 + 0.4 × Readiness).
- **Offensive wars** (Suez 1956, for example) have their own response menu: `air_first`, `mobilize`, `limited_aims`, `standing_forces`.
- **Crisis report.** `crisis_ended(report)` carries `readiness_change` (lessons learned, never 0). The reason also goes to `get_stat_log("readiness")`.

Two behaviour changes:
- **Standing settles** at `50 + your choices + lasting standing_target terms`, not at 50. Player-chosen standing changes don't mean-revert.
- **Trust settles** at its baseline plus `trust_base` terms for the city's group. Groups are: all, dev_towns, arab, periphery and large_cities.

## Round-5 additions (sim)

All changes are additive except the ledger's `historical` field.

- **Decisions:**
  - `policy_review` (blocking) opens on every election and change of government, with `{government, slots, available, free_swap: true}`. Call `set_policy(...)` as needed (free this turn), then `sim.confirm_policies()`.
  - `crisis_response` decisions now carry `war_turn: bool` and `crisis`. Follow-up war turns are `war_turn: true`. Their front options (`dfront:<id>`) carry `n`, the enemy formations at that front, and the strongest front is `default`.
  - `immigration` is now a yearly decision (the plan holds 4 quarters), and it comes up again when a named wave begins. It carries `wave` (the event title, or ""). Options depend on the era:
    - `camps`: transit camps before 1965, caravan sites in 1990–93;
    - `villages`: before 1980;
    - `cities`: absorption centres, or direct absorption from 1989;
    - `dev_towns`.
  - The Cabinet Agenda rotates era-specific routine items:
    - `defense_budget`, `education`, `periphery`, `health`, `exports`, `transport`, `welfare`, `high_tech`;
    - each kind at most once every 4 turns (8 for routine, standing and inflation items);
    - never the same menu twice in a row;
    - the housing item uses ma'abarot wording before 1965, then public-housing and rent options.
- **Ordering:** forks are offered before the quarter's events. When a fork is pending, the quarter's remaining events wait until it is decided, so a decision is always asked before its outcome is shown. `sim.events.events_held()` is true while that happens.
- **Duplicates:** when a fork asks an event's question, the event fires with its rails only (`notification` carries `fork`). See `SimForks.REPLACES`; a fork can also declare `replaces_event`.
- **Event choices:** `choices[i].effects_text` gives player-facing lines (no raw keys such as gold_per_turn).
- **Ledger:** `get_path_ledger()` entries are `{id, title, chosen, chosen_label, historical, historical_label, matched_history, terms, turn}`.
  - Breaking change: `historical` is now the historical **option id**. The boolean moved to `matched_history`.
  - Term spans are years, and gold figures are the real per-turn amounts (no hidden multiplier).
- **End screen:** `sim.get_end_summary()` returns `{date, tracks (six-track table with real-world labels), ahead, overall, verdict, reasons, ledger, ledger_summary, crises, timeline_highlights, game_over, final_date}`.
- **Diplomacy:** `get_diplomacy()` hides Hamas (until Dec 1987), the PA (May 1994), the PLO (May 1964) and Hezbollah (first event, 1993) until they exist. Names follow the date ("Syria (transitional government after Assad)" from Dec 2024).
  - Legal statuses follow `actors.json` `status_rails`: the 1949 armistices until June 1967; Iraq hostile, not at war, outside its wars.
  - A "hostile" event against a state Israel has relations with lowers the relation rather than breaking relations off.
- **City info:** `info.shortfall_label` gives an era-appropriate wording for `info.transit` (residents short of housing): "in transit camps (ma'abarot)" before 1965, then caravan sites (1990–96) or overcrowded/temporary housing.
- **Scaling:** gold amounts in events, forks, the agenda and war costs follow `sim.events.gold_scale()`, which is the larger of the era scale and the budget size (average gross income per quarter / 45).


## v2 additions (sim-v2)

All additive; nothing was renamed or removed. Every new decision type has options with `label`, `desc`, `effects`
(structured, below), `effects_text` (ready-to-show strings), `fx` (the subset the generic popup already colours) and
`default` (the Recommended pick). Each is resolved by `sim.choose_<type>(index)`, so the generic `open_generic` /
`choose_generic` path works until the dedicated screens exist. `sim.resolve_recommended(decision)` handles all of them
(tutorial gate, UI tests).

**Structured effects** (UI request 18), everywhere: `[{stat, amount, unit, label?, when?, good?}]`.
- `stat` is one of `readiness, standing, trust, cohesion, gold, inflation, population, water, science, production, culture,
  economy, housing, amenity, food`.
- `good` gives the sign for colouring; it is missing when the effect is neutral.
- Event choices: `choices[i].effects_struct`. It also includes the lasting terms from choice_terms.json, with `when: "YYYY-YYYY"`.
- Fork options: `options[i].effects` holds the now effects (`when: "now"`) and the lasting terms (`type, from, until, label, group?`).
- Cabinet Agenda options: `options[i].effects`.

### New decision types

Next Action order: event_choice, fork, crisis_response, coalition, policy_review, state_budget, budget_review, immigration,
minister, dedication, fill_policy, research, civic, production, units, agenda.

| type | blocking | when | resolve with |
|---|---|---|---|
| `state_budget` | yes | Each fiscal year: Q1 for the April-March years 1949/50 to 1990/91, Q4 for the calendar years 1992 to 2026. | `choose_state_budget(index)` or `set_budget_shares({defence, absorption, development, education})` |
| `budget_review` | yes | Two quarters after each budget. | `choose_budget_review(index)` |
| `minister` | Yes in a quarter with no other story decision, or with 2+ titles waiting; otherwise no. | A cabinet title is waiting: one every 2 quarters, two per new government. | `choose_minister(index)`, or `appoint_minister(id, city_id)` / `promote_minister(id, promotion_id)` |
| `coalition` | yes | The first quarter of each new government. Skipped where a fork already asks who joins the coalition. | `choose_coalition(index)` |

#### `state_budget`: the annual Budget Law (sources S5200-S5213)

```
{type: "state_budget", blocking: true, label: "STATE BUDGET 1953/54: SPLIT THE BUDGET", fiscal_year: "1953/54" | "1995",
 text, share_min: 0.10, share_max: 0.55, recommended: "<preset id>", source: [S-ids],
 envelopes: [{id: "defence"|"absorption"|"development"|"education", name, short, desc, current_share, effects_at_40: [text]}],
 options: [{id: "balanced"|"defence"|"absorption"|"development"|"education"|"war", label, desc ("Defence 40%, ..."),
            shares: {defence, absorption, development, education}, effects: [...], effects_text: [...], fx, default}]}
```
- Revenue sets the total, so no gold is spent. The split decides the year's modifiers.
- An envelope's effect is `full_effect x (sqrt(share / 0.25) - 1)`: 0 at 25%, +27% of the full effect at 40%, -11% at 20%,
  +48% at 55%. A specialised budget buys a big gain on one track for smaller losses on three, so no split dominates another.
- Full effects (governments.json `budget.envelopes`):
  - defence: Readiness +12, war weariness -40%;
  - absorption and housing: +4 Housing in every city, +8% retention, +2 trust in development towns;
  - development and water: +8% Production, +12% water supply, +2 trust in the periphery;
  - education and science: +16% Science, +12% Culture.
- `war` (55% defence) is offered only during a war or within a year after one.
- `set_budget_shares(shares)` passes a custom split while the decision is open. Each share is clamped to 10-55% and the total is normalised.
- The budget holds until the next one. `sim.get_budget()` returns
  `{fy, turn, until, preset, shares, extra, envelopes: [{id, name, share, mult, effects: [text]}], next_budget_turn, review_turn, reviewed, history}`.

#### `budget_review`: the mid-year review

```
{type: "budget_review", blocking: true, label: "MID-YEAR BUDGET REVIEW 1953/54", fiscal_year, text, budget: get_budget(),
 options: [{id: "keep"|"supplement"|"cut"|"to_defence", label, desc, envelope? (supplement), gold, effects, effects_text, fx, default}]}
```
- `supplement`: gold now; the neediest envelope works as if it had about 6 points more share until the year ends.
- `cut`: gold now; every envelope is trimmed; -1 trust everywhere.
- `to_defence` (wartime only): defence goes up and the other three go down; no gold changes hands.

#### `minister`: Civ VI governors (ministries S5214-S5222)

```
{type: "minister", blocking: bool, label: "CABINET: APPOINT OR PROMOTE A MINISTER (1 title)", titles: n, text,
 ministers: get_ministers(),
 options: [{id: "appoint:<minister>" | "promote:<minister>:<promotion>", kind: "appoint"|"promote", minister, city? (seat for appoint),
            promotion?, tier?, label, desc, effects, effects_text, value, fx: {}, default}]}
```
- There are seven ministers: `defence`, `economy` (Finance), `absorption`, `housing`, `agriculture`, `education` and `health`.
- An appointed minister has a seat city. Its local effects start after 2 quarters, like a governor establishing.
- Each minister has up to five promotions: two at tier 1, two at tier 2 (each needs a tier-1 promotion) and a tier-3 capstone.
  Promotions are national programmes and act at once.
- A new government brings new ministers. Seats stay, every promotion ends, and the new cabinet gets two titles to set its priorities.
- `appoint_minister(id, city_id)` on an appointed minister moves the seat. This is free and takes 2 quarters to settle in.
- Titles: 2 at the start, +1 every 2 quarters, +2 per new government, at most 4 waiting.
- `sim.get_ministers()` returns `[{id, name, title, appointed, city, city_name, established, partner, base: [text], desc, source,
   promotions: [{id, name, tier, desc, taken, available, reason, effects: [text]}]}]`.
- `sim.get_cabinet()` returns `{titles, next_title_in, ministers, options, coalitions: [{turn, partner, label, pm}]}`.

#### `coalition`: coalition agreements (sources S5223-S5228)

```
{type: "coalition", blocking: true, label: "COALITION TALKS: <PM> FORMS A GOVERNMENT", text, government,
 options: [{id: "religious"|"centre"|"settlement"|"unity"|"narrow", label, desc, portfolio, promotions_lost, gold_per_turn,
            effects, effects_text, advocate, source, fx: {}, default}]}
```
- A partner takes one portfolio. That minister is "held by a coalition partner this term" and cannot be promoted.
- The partner's terms last for the government's term: modifiers plus a gold-per-turn sector budget, shown in `get_streams()` as "Coalition agreement: ...".
- `narrow` keeps every portfolio, but gives no extra cabinet title from this election and -0.5 Cohesion per turn this term.

### War fronts (task "fronts on time")

- Concurrent wars no longer share one menu. Each war gets its own `crisis_response` (`war_turn: true`) every quarter, one after
  the other.
- A war's opening quarter can have several **phases** (data `phases`), each its own decision with that phase's fronts. Example
  for 1967: 5 June (Sinai), then Jerusalem and the West Bank, then the Golan.
  - New decision keys: `phase`, `phases`, `phase_name`, `war` and `title` ("The Six-Day War (1967), phase 2 of 3: ...").
  - The opening options (mobilise, air strikes, limited aims) are in phase 1.
- Wars already under way ask for this quarter's front orders before the quarter's events fire. The quarter's later events wait
  while a crisis decision is open (as for forks), so ceasefires and outcome rails come after the orders.
- Every war-turn option carries `preview` (the combat preview below).
- New kinds:
  - `uprising` (First and Second Intifada): front texts speak of centres of the uprising.
  - `deterrence` (Black September 1970): deployments only, with no fighting.

### Combat preview

- `sim.combat_preview(unit_id, q, r)` keeps its keys and adds exact odds. Damage is uniform in [24, 36] x exp(0.04 x delta), so no dice are needed.
  - `win_chance` (the defender is destroyed and the attacker survives), `kill_chance`, `death_chance`;
  - `damage_dealt_range`, `damage_taken_range`, `expected_hp_dealt`, `expected_hp_lost`, `defender_hp`, `attacker_hp`;
  - `outcome` ("decisive victory" ... "defeat") and `target_city`;
  - `win_odds` (the defender dies, or survives having lost more HP than the attacker) and
    `modifiers: [{side, label, amount, base?}]` (every term of both strengths: base, damage, promotions, hills, forest,
    fortified, adjacent support, Readiness, policies, mobilised; a city's defences).
- `sim.front_preview(option_index)` covers the open war-turn decision (the same data as `options[i].preview`):
  `{front, strength, strength_parts: [{label, amount}], targets, kill_chances: [p], expected_destroyed, expected_suppressed,
    expected_hp_removed, enemy_formations, expected_left, protects: [{name, residents}], residents_at_risk,
    expected_town_strikes, strikes_by_front: {front name: n}, expected_units_lost, lesson_effect, production_lost, gold, cohesion}`.
  It is deterministic and side-effect free.
- Fronts now differ (the war-turn resolution uses the same model):
  - the counter-attack strength at a front is the base (45 + 0.4 x Readiness) adjusted for the ground the enemy holds
    (hills and towns -4, mountains -6, forest -3, open ground +2), the distance from the front's base town (supply lines,
    -1 per hex beyond 5, at most -8), the enemy's own strength, reserves mobilised (+3) and forces already engaged there (+2 each);
  - a formation hit for 35 HP or more is pinned down and does not strike this quarter, so committing to a front protects
    the towns that front threatens (`protects`, `strikes_by_front`);
  - each option's `desc` names the towns at risk.

### District placement lens

- `sim.get_district_lens(city_id, district_id)` returns every tile of the city, best first:
  `[{q, r, valid, reason, adjacency, parts: [{src, id, count, per, amount}], appeal, terrain, feature}]`.
  `reason` is "" on valid tiles, and `parts` itemises the adjacency bonus. `get_district_sites` is unchanged. Read-only.

### Citizen management

- `sim.clear_citizen_locks(city_id)` unlocks every tile of the city.
- `sim.get_worked_tiles(city_id)` returns `[{q, r, yields, worked, locked, workable, centre, district, improvement, score}]`. Read-only.
- `sim.set_tile_locked(city_id, q, r, locked: bool) -> bool`:
  - Locked tiles are worked first, up to the population. Locking one more tile than the population frees the oldest lock.
  - Yields are recomputed at once.
  - Locks are saved with the city (`city.locked`) and shown in `get_city().info.locked`.

### First-time cards and saves

- Every new decision dict carries `explain`: one player-facing sentence for the first-time advisor card.
- `Sim.peek_save(path) -> {turn, label, era_name, mode, game_over}` (static) reads a save's header for the slot list.

### Stat log and ghost reasons

- `get_stat_log(stat)` now has one itemised entry per quarter for `trust`, `readiness` and `inflation` (UI request 16):
  `{turn, stat, amount, reason: "this quarter: <cause> +x, ...", parts: {cause: amount}, quarterly: true}`.
  Budget, minister and coalition decisions are logged as `lasting: true` entries.
- Score `reasons` (and the end screen's "What made the difference") now lead with the player's decisions, then milestones:
  - forks and event choices answered differently from history, weighted by their lasting terms;
  - the budget emphasis.
  Each reason has `kind: "choice" | "milestone"`. A civic the player blocked reads "refused by your earlier choice" (UI request 17).

### Agenda

- The yearly "budget emphasis" and "defence budget" items are gone; the State Budget replaces them.
- A "Reserve duty" item joins the routine rotation.
- The same town's housing shortage comes back at most once in four years.
- The deficit item is not asked in a budget quarter.
- A treasury in debt brings the deficit item back every 4 turns, and its loan covers the hole.


## v2 fixes (fix-cabinet): cabinet, recurring decisions, debt, score

All additive except where marked **changed**. Nothing was renamed or removed.

### `minister`: one cabinet screen per government, one programme a year (changed)

```
{type: "minister", blocking, mode: "cabinet" | "promotion" | "spare", picks: n, titles: n, label, text, explain,
 recommended: [option ids], government: current_term(), ministers: get_ministers(),
 options: [{id: "appoint:<minister>" | "promote:<minister>:<promotion>", kind, minister, city?, promotion?, tier?,
            label, desc, effects, effects_text, value, programme_of: ["labour"|"right"|"centre"], fx: {}, default}]}
```
- **mode "cabinet"**: a new government takes office (and turn 2 for the provisional government; turn 1 has no
  minister decision). Spend every title in ONE multi-pick: `sim.choose_ministers([option ids or indices])`
  (up to `picks`; appointments are applied first, then promotions by tier, so a tier-2 pick may build on a tier-1
  pick made on the same screen). `recommended` / `default` mark the Recommended set (at most one per minister).
- **mode "promotion"**: once a year, the quarter after the Budget Law passes (skipped within 3 quarters of a new
  government): one title.
- **mode "spare"**: titles left unspent from an earlier screen; never blocking (spend them in the cabinet panel).
- **Blocking**: only in the quarter the screen is due, and only until one pick is made. `choose_minister(index)` still
  works (spends one title) and ends the blocking for that quarter; the rest stay as spare titles. The minister
  menu therefore opens at most once per turn and never just to fill a quiet quarter.
- **Titles**: a new governing party's cabinet gets 3; the same party re-forming (or a rotation) keeps its ministers'
  programmes and gets 2; +1 a year; at most 4 waiting. `get_cabinet().next_title_in` counts to the next yearly title.
- **Promotions by era and government**: each promotion has `from`/`until` years (3 eras: 1948-66, 1967-91,
  1992-2026, some spanning two) and `programme_of` tags; the governing bloc (`PARTY_BLOC` of `current_term().party`)
  values its own programmes higher, and what the outgoing government had done is discounted, so recommendations
  differ by era and government. Programmes of other eras are not listed in `get_ministers()`; their `promotions[]`
  now carry `from`, `until`, `programme_of`.
- The Minister of Immigrant Absorption is offered from 1968 (the ministry was set up then, S5218); before that only
  six ministers. `get_ministers()[].title` is the title of the day.

### `coalition`: real partners per government (changed)

```
{type: "coalition", blocking, label, text, explain, how: "election"|"succession"|"rotation"|"unity"|"reformed", government,
 options: [{id, label, party, advocate, historical, desc, ministries: [our minister ids], portfolios: [real portfolio names],
            portfolio (comma-joined ministries), promotions_lost, gold_per_turn, effects, effects_text, source, cite, note, default}]}
```
- Fires after every real election and change of government (`governments.json` terms now include 1951, 1959, 1961,
  1965/66, 1969 (Dec), 1974 (Mar), 1981, 1988, 2013 and 2015). Skipped where a fork asks the same question
  (1949, 1952, 1970 Gahal, 1984, 1999 Barak, 2013, 2021).
- Options are the parties that actually joined that government (`historical: true`, the first is the main partner),
  each with its leader as `advocate` and a `cite`, plus parties that negotiated and stayed out (`historical: false`).
  The price is the real portfolios: those among the seven programme ministries become partner-held (programmes
  lost); others (Interior, Religious Affairs...) are listed in the text.
- The text follows `how`: "After the election of ...", "takes over as prime minister without an election",
  "Under the rotation agreement", "national unity government", "rebuilds a majority without an election".
- **Order changed**: `coalition` now comes before `crisis_response` in `next_action()` (the 1967 unity government
  formed before the war).
- `current_term()` carries `how`, `party` and `election` (date) from governments.json.

### `policy_review` (changed)

Opens only when a new government forms (`apply_government`), no longer on election events with no new government
(2019-22 elections, the 1973 and 1981 elections before the cabinets formed, the Q3 2026 dissolution). Elections still
give a free swap.

### `state_budget`, `budget_review`

- `state_budget` adds `recommended_why` (one sentence, also appended to `text`). The Recommended preset follows the
  year (`SimCabinet.preset_needs()`: readiness and wars, arrivals and camps, water and the periphery, science against
  history, inflation and the deficit, and how long since an envelope last led). The balanced preset now restrains
  prices (`extra_effects`: -3 inflation pressure).
- `budget_review` adds `fiscal_state`: "war" | "deficit" | "inflation" | "surplus" | "normal", and its options follow it:
  - deficit: `cut`, `surtax` (+15% Gold for 4 quarters, -1 Amenity), `freeze_hiring`;
  - war: `to_defence`, `war_supplement` (gold for a bigger defence envelope), `war_loan` (a loan into the public debt);
  - inflation: `nominal_freeze` (-6 points of inflation, envelopes trimmed), `index_budget` (+1 trust, +4 inflation), `cut`;
  - surplus: `supplement` (a big one), `repay_debt` (early repayment), `tax_rebate` (+2 trust, +3% Production),
    `reserve_fund` (gold now returns 125% over three years);
  - normal: `supplement`, `cut`; `keep` is always offered.

### `immigration` (changed)

Options vary by era and wave. Each option: `{id, base: "cities"|"dev_towns"|"villages"|"camps", label, text, effects (string),
effects_list (structured), terms (temp effects for the plan's year), gold, arrivals, towns, housing_room, camp_residents,
historical, default}`. `id` is now a variant id (for example `absorption_centres`, `direct_absorption`, `scientists`,
`periphery_grants`, `youth_kibbutz`, `absorption_sites` for the Ethiopian waves); `choose_immigration` also still accepts
a base id (the first variant of that pattern). The texts no longer show raw housing numbers ("Housing room for about
12,000 of the 15,000 arrivals a quarter"). The label reads "PLACE IMMIGRANTS: <wave>, about 12,345 a quarter".

### Public debt (new)

- Borrowing (the deficit agenda's "Borrow abroad", the war loan) adds to `sim.econ.debt()`: interest each quarter
  (about 5% a year, more near the limit) and repayment over fifteen years come out of the budget
  (`counters.last_budget.debt`). A negative treasury pays interest too. Lenders cap the debt at about six quarters
  of revenue, scaled by standing (`borrow_cap`); "Borrow abroad" is never Recommended and is not offered at the cap.
- `sim.get_debt()` -> `{debt, cap, room, borrowed_total, borrow_count, interest_total, repaid_early, debt_peak, service,
  interest, health, deficit_turns, open_rails: [{label, amount, ends}]}`.
- `get_national_summary()` adds `debt`, `debt_service`, `borrow_cap`, `deficit_streams` (= open_rails), `economy_health`.
- The deficit agenda's text names the debt, its service and every open deficit rail with what ends it. Its fx key
  `borrow` (agenda_struct shows it as gold borrowed).
- The post-1973 rail ("Post-1973 defence burden and indexed wages", -45/turn) now also ends once inflation has stayed
  below 30% for a year (stream key `ends_with_inflation_below`), not only when the Stabilization Plan card is slotted.
- **Score**: the economy track is multiplied by `econ.economy_health()`: inflation above history's path (the player's
  inflation gap) and a debt burden above 30% of a year's revenue lower output per capita.

### Score reasons: "What made the difference" (changed)

`get_score().reasons` and `get_end_summary().reasons` are now each track's gap with history attributed to its drivers:
`[{track, gap, kind: "choice"|"budget"|"immigration"|"deficit"|"rail"|"milestone"|"pace", weight, good, turns: 0, text, headline, line}]`.
Tracks with the biggest gaps come first, up to two drivers each, only drivers that push the same way as the gap.
Forks and choices are weighted by how much of their terms are still in force; budget splits and immigration plans are
compared with the ghost's (`ghost.json` adds `budget_counts`, `imm_counts`, `deficit_turns`, `borrowed_total`);
milestones count only within the last 20 years or when a national project or water item is still missing.
`text` / `headline` read "+34% vs history: State Budgets: development and water first in 30 of 78 years (history's ghost: 9)".

### New localities

A locality founded before its first census is seeded from that census (Nir Oz starts with 59, not 1,500); a new town
starts small and grows toward its census path.


## v2 fixes (fix-wars-events): consequences, wars, diplomacy

All additive.

**Forks honour their answers.**
- An event can carry `consequences` (events.json): `[{if: {<fork id>: <option> | [options]}, mode: "skip" | "course", note, keep?, numeric?, crisis?}]`.
  - `skip`: the event does not happen in the player's Israel (it still counts as fired). A `notification` of the new kind `consequence` carries `{event, fork, skipped: true, title}` and the note. Examples: Osirak postponed, the UN regime for Jerusalem, Basic Law: Jerusalem left to lapse, no Oslo channel, the tunnel kept sealed.
  - `course`: the rails still happen, but the event's numeric effects and civics follow the fork; a `history_course` notification gives the data note (Entebbe after "negotiate", Kiryat Arba after "evict", Oslo II without Oslo, the 2026 Iran war after the Geneva talks).
  - `get_event_log()` entries gain `history_course` (text), `consequence` (text) and `skipped` (bool).
- `defer_to_fork` (events.json): the event's numeric effects and civics wait for that fork in the same quarter (the 1949 Austerity: `loosen_controls` adopts no civic and costs no trust). Its `event` notification carries `awaits_fork`.
- The capital stays in Tel Aviv after "accept the UN regime" (1949).
- Forks that answer an event of their quarter wait for it (`SimForks.AFTER_EVENT`): the first coalition after the 1949 election, the Black Panthers, Munich, COVID.
- Duplicate questions dropped: the 1984 rotation, the 1985 security zone and the Yamit evacuation now fire with rails only (`SimForks.REPLACES`).

**Wars** (data in FORKS.md, "War fields added in the v2 fix round"):
- War `variants` follow fork answers: fronts dropped, turns shortened, phases renamed, a pre-emptive opening, no mobilisation, strikes in a deterrence war, or the war ended early. A `history_course` notification gives the variant's note.
- `continues`: front orders at a lower cadence after the main fighting (First Intifada once a year to 1993; Second Intifada every two quarters to 2004). Decision titles read "...: the uprising continues (Q4 1990)". Quiet quarters between have no orders and no attacks.
- `alongside`: a war that does not end another (Defensive Shield runs alongside the Second Intifada).
- `kind: "operation"` with `response_options`: the crisis menu offers named options `opx:<id>` with `cost`, `desc`, `historical`, `standing_mult`, `morale_mult`, `lesson`, `readiness`, `cite` (Opera 1981, Wooden Leg 1985). The event's standing and morale land with the option chosen.
- New front options for remote missile fronts: `strike:<front id>` (offensive wars: strike the launchers, fewer salvos this quarter; or strike a target abroad). `shield:<front id>` labels now name the place defended (`area`), never "Missiles threaten <missiles>".
- Front strength has a new part, the front's `ground` (`SimMilitary.GROUND`: open desert +8 ... tunnels -10), so fronts differ by up to ~18 points.
- Front texts and `front_preview()` list the other affected populations: `preview.other_populations: [{group, label, text}]` (the front's own `civilians` line, then the war event's sourced non-Israeli `affected_populations`); option `desc` ends with "In the combat area: ..." and "Also affected (whole-war figures): ...".
- War lengths: 2006 Lebanon, Protective Edge, the Twelve-Day War and Grapes of Wrath take one quarter (with phases where the fighting had stages); the Scuds one quarter; the Bekaa front closes with the 11 June 1982 ceasefire; 1973 phase 2 is the counter-offensive into Syria and Mount Hermon.

**Diplomacy.**
- Enemies read `war` while a war's fronts are open; the war event's ceasefire statuses land once the opening quarter's orders are given (1967) or when the war ends. Jordan reads `war` during the 1973 orders (`war_actors`).
- An actor counts as at war only while it has an open front (`SimMilitary.crisis_live_actors`): Syria moves to `ceasefire` from Q3 1982 (status rail, S5306).
- A railed status keeps the `relation` within 20 points of its meaning (USSR "severed" 1967-91 no longer shows +50).

**Other.**
- `dedication` options: the Ingathering goal no longer says "transit camps" after 1965 (`events.dedications()`).
- The West Bank toll event id is now `evt_2023_west_bank_toll_2023_26`.
- `sim_test` runs a fork consequence checker (data and played runs).


## v3 (sim-endgame)

Module `scripts/sim/sim_endgame.gd` (`sim.endgame`). Data: `data/projects.json` (national programmes), `data/endings.json`,
`data/difficulty.json`, `data/scenarios/start_<id>.json` (written by the full sim_test). All state lives in
`state.counters["eg"]` and `state.counters["difficulty"]` (saved with the game; v2 saves load as Normal). All additive.

### The end of the game (changed 2026-10-13, the user's decision)

- `Sim.last_playable_turn()` is the last turn: project setting `civ/last_turn`, default `Sim.GAME_END_TURN` = 302 (Q3 2023);
  `civ/demo_last_turn` (demo builds) still ends earlier. `Sim.full_last_turn()` ignores the demo limit; `is_demo()` compares
  with it. `get_date().last_turn` is the last playable turn. `SimDB.LAST_TURN` (315) stays the last turn the data covers.
- After the last turn `game_over` fires; the UI shows the memorial, then the results.
  `sim.get_ending_memorial()` -> `{id, date, turn_after, paragraphs: [text], closing, cite}` read verbatim from
  `data/ending_oct7.json` (never edited by the sim); also `get_end_summary().memorial`.
- Endings and the epilogue cover 1948-2023: ending texts read "By September 2023 ..." (`endgame.end_label()`); there is no
  gap note any more. Events and programme levels dated after the end never fire (the ghost never takes them; a player may
  still launch a level early within its window, e.g. Iron Beam). Everything dated after Q3 2023, including the Iran
  October 2024 operation file, was deleted on 2026-10-14 (see "v3 integration" at the end).

### Difficulty (New Game)

```gdscript
Sim.get_difficulties()   # static: [{id, name, desc, effects: [text], default, hints}]   (easy, normal, hard, historian)
Sim.difficulty_levels()  # static: the raw rows {id, name, desc, ghost_strength, start_gold, inflation_drift, ai_pressure, programme_cost, ending_margin, hints}
sim.new_game({"mode": "player", "seed": 1948, "difficulty": "hard"})
sim.get_difficulty()     # {id, name, desc, ghost_strength, ..., levels: [...]}
sim.hints_enabled()      # false on Historian: hide Recommended badges and history's choice until after the pick
```
- `ghost_strength` multiplies history's track values (population by its square root): Easy 0.94, Hard 1.06, Historian 1.10.
- `start_gold` is added to the 1948 treasury; `inflation_drift` scales how fast deficits move inflation off history's path;
  `ai_pressure` adds to hostile formations' strength (`SimMilitary.strength`); `programme_cost` scales programme costs;
  `ending_margin` raises the ratio thresholds of the endings.
- The ghost (mode "historical") is always Normal.

### National programmes (late-game goals and projects)

Ten programmes, each a chain of real levels with history's date (the ghost launches them then) or a real proposal history
did not carry out (named `advocate` and verbatim `cite`), plus a repeatable expansion (a gold sink for late surpluses):
MASHAV, Talpiot, the start-up economy (R&D law, incubators, Yozma), space and cyber (Space Agency, Cyber Bureau, Cyber
Security Authority), the missile shield (Arrow, Iron Dome, David's Sling, Iron Beam), desalination (the 2002 plants, 70% of
drinking water, the 750 million m3 target, water for Jordan), the gas fields (Tamar, the wealth fund, Leviathan and
exports, EastMed), peace dividends (QIZ Jordan, QIZ Egypt, Abraham Accords trade), the Arab-sector plans (922, the 2021
plans) and national health insurance. New sources S5506-S5525 (`sources/pending/sim_sources_v3_endgame.json`).

- A level opens up to 8 years before history (+4% cost a year early) once its `requires` hold (tech, civic, diplomatic
  status, the previous level). It is paid in quarterly instalments (`cost` x `events.gold_scale()` x difficulty); a quarter
  the treasury cannot pay pauses it.
- On completion it adds lasting terms (streams, `src: "programme:<id>"`, to 2026; shown in `get_streams()`) and a **track
  gain** (`legacy`, % of a score track, growing to full over four years). `SimScore.values()` multiplies each track by
  `1 + gain/100`; the ghost carries history's own gains, so only earlier, non-historical and expanded levels put you ahead.
- Score reasons gain `kind: "programme"` ("National programmes: The gas fields, 4 levels done (history's ghost: 3)").

```gdscript
sim.get_programmes()   # [{id, name, groups: [security|prosperity|peace|society], desc, source,
                       #   levels: [{level, name, desc, hist, hist_label, historical, advocate, status: done|active|available|locked,
                       #             reason, cost, turns, done_turn, effects: [text], legacy: {track: %}, cite}],
                       #   levels_done, active: {kind: level|expand, level, quarters_left, instalment, cost} | {},
                       #   expand: {name, desc, count, max, cost, turns, reason, legacy, effects} | {},
                       #   legacy_now: {track: %}, history_level (levels history had done by this date)}]
sim.fund_programme(id) -> bool     # launch the next level
sim.expand_programme(id) -> bool   # the next expansion (after the last level)
sim.cancel_programme(id) -> bool   # stop the level under way (paid instalments are lost)
```

**Decision `programme`** (blocking; Next Action order after `immigration`, before `minister`): when a level first opens
(`kind: "open"`: launch now / not now) and at most twice a year when the treasury can carry two instalments (one quarter of
income) (`kind: "surplus"`: up to three launches or expansions, repay debt early, hold the reserve).
`{type: "programme", blocking, label: "NATIONAL PROGRAMME: ..." | "NATIONAL PROGRAMMES: INVEST THE SURPLUS", kind, text, explain,
  options: [{id: "launch:<pid>:<level>"|"expand:<pid>"|"repay_debt"|"hold"|"defer", label, desc, cost, turns, instalment,
  historical, hist_label, advocate, cite, available, value, effects (structured), effects_text, fx: {}, default}]}`.
Resolve with `sim.choose_programme(index)` (the generic popup works) or `resolve_recommended`.

### Endings

```gdscript
sim.get_endings()        # {turn, final, difficulty, endings: [{id, name, summary, met, progress (0..1), criteria_met,
                         #   criteria: [{id, label, metric, value, target, cmp: ">="|"<=", met, progress, unit, text}]}],
                         #   reached: [ids], primary (the headline ending, or "mixed_record"), leading (closest now)}
sim.get_ending_outlook() # ui-v3 shape: [{id, name, desc, thresholds (= criteria), progress, met, likely}] incl. the mixed record
sim.get_epilogue()       # {ending, name, summary, also, paragraphs: [{kind, title, text}], record: {...}}
sim.get_end_summary()    # adds ending: {id, name, title, summary, also, verdict, epilogue: [plain paragraphs],
                         #   sections: [{kind, title, text}], thresholds, record}, endings (get_endings()), epilogue, difficulty
```
- Endings (data/endings.json; every criterion must hold on the last turn; when several are met, the largest average margin is the
  headline): **Secure State** (readiness, strikes on towns vs history, security programmes beyond history's, standing),
  **Prosperous State** (economy and science vs history, inflation, debt in years of revenue, prosperity programmes),
  **Peace with Neighbours** (treaties in force, standing, standing vs history, peace programmes), **United Society**
  (cohesion vs history, the lowest trust among Arab localities, development towns and the periphery, housing shortfall,
  society programmes), else **A Mixed Record**. Progress shows during play.
- Metrics (`sim.endgame.metric(id)`): `readiness`, `standing`, `inflation`, `debt_years`, `treaties`
  (`sim.treaties_in_force()` if sim-diplomacy provides it, else statuses peace/normalized), `town_strikes_ratio` (yours /
  history's to date), `min_group_trust`, `housing_shortfall`, `track_ratio:<track>`, `programme_lead:<group>` (your
  levels and expansions minus history's on the same date).
- Epilogue paragraphs (`kind`): `ending`, `forks` (decisions answered differently, those still in force), `wars`
  (crises, strikes on towns vs history, units lost, readiness), `budgets` (State Budget priorities), `diplomacy`
  (treaties in force, standing, US relation), `programmes`, `money` (treasury, debt, inflation, borrowing), `close`
  (the ending's closing line and the endings missed by one criterion).
  Plain text; the UI adds formatting.

### Top bar: debt and inflation; the food figure

```gdscript
sim.get_fiscal_indicator()   # {debt, debt_years, debt_trend, debt_dir: up|down|flat, inflation, inflation_trend, inflation_dir,
                             #  inflation_history, inflation_gap, treasury, net, deficit_quarters (last 4), level: ok|watch|danger,
                             #  label "Debt 0.4 yrs = | Inflation 12% v", tooltip (one paragraph)}
sim.get_economy_indicator()  # the same plus ui-v3's keys: revenue_year, debt_ratio, cap, service, inflation_history_baseline,
                             #  health, tooltip: [lines], text
sim.get_food_balance()       # {produced, rural, needed, balance, ratio, self_sufficiency_pct, imports_gold, exports_gold,
                             #  growth_effect_pct, label, text}
sim.get_food_report()        # the same plus ui-v3's keys: consumed, surplus, imports, import_cost
get_national_summary()       # adds fiscal (= get_fiscal_indicator()) and food_balance
```
- Trends compare with four quarters ago. Level `danger`: inflation above 50%, debt above 2.5 years of revenue or a treasury
  below zero for 4+ quarters; `watch`: inflation above 15%, debt above 1.5 years, 3+ deficit quarters in the last 4 or a
  negative treasury.
- **The food figure** is national: cities' worked tiles, farms and buildings plus the rural localities, against 2 per
  population point. A shortfall is imported (0.5 gold each a quarter) and slows growth everywhere; **new in v3**, a surplus
  is exported at `SimEconomy.FOOD_EXPORT` gold each (`last_budget.food_exports`); **the rate is 0.0 (off) since the
  sim-endgame calibration** (exports moved the ghost's treasury and growth off the census), so a surplus only speeds growth. A city's own figure (city screen)
  can be negative: large cities live on the national pool.

### Iran, October 2024

Deleted on 2026-10-14 with everything dated after Q3 2023 (the game ends on 7 October 2023). The `operation` war kind and
its `opx:` options stay in the code for any future operation file.

### Scenario starts (for round 2)

```gdscript
Sim.scenario_starts()   # static: [{id: "1967"|"1977"|"1992", date, turn, label, title, briefing, file, available}]
Sim.get_scenarios()     # ui-v3 shape: [{id ("" = 1948), name, year, desc, available, label?, turn?}]
sim.new_game({"scenario": "1967", "difficulty": "normal"})   # loads the seeded state and hands it to the player
SimEndgame.save_scenario_snapshot(sim, id)                    # used by sim_test's ghost run (start of Q3 1967/1977/1992)
```
The snapshot is the historical run's whole state at the start of that quarter (cities, borders, techs, civics, treasury,
debt, diplomacy, streams, ministers, budget, and the score history, level with the ghost). `new_game` with a scenario
switches it to a player game, emits `turn_started` and posts a `scenario` notification with the briefing. With no file,
`new_game` falls back to 1948.

### AI and tests

- `SimAI` styles add `strategist_security`, `strategist_prosperity`, `strategist_peace` and `strategist_society` (track
  weights, budget emphasis, immigration pattern, programme group); varied and strategist styles also fund programmes
  directly. `SimAI.pick_programme(sim, decision)` is the programme pick.
- `sim_test`: the full run validates projects/endings/difficulty data, writes the scenario snapshots and prints an
  endings report with the arc per decade. `--divergence` adds the endings report and fails under a 10-point overall
  spread. `--strategies` writes STRATEGY_REPORT.md (endings, arcs, spread, dominance), `--difficulty` writes
  DIFFICULTY_REPORT.md and `--scenario-test` writes SCENARIO_REPORT.md.

## v3 (sim-diplomacy)

Diplomacy as a system (V3.md item 4). Code `scripts/sim/sim_diplomacy.gd` (`sim.diplo`), data `data/diplomacy.json`
(built from opened, verbatim-quoted sources by `progress/sim_diplo_tools/build_diplomacy.py`), era gates, dated names
and rails in `data/actors.json`. Legal statuses stay on the rails of events.json/actors.json; relations, deals and
envoy answers are the player's. Sources: existing S-ids and S5530-S5599 (`sources/pending/sim_sources_v3_diplomacy.json`).

### Model
- **Relation** (-100..100) = the legal status's baseline (`actors.json status_relation`) + live causes (International
  Standing for the US, UK, France, Germany and the EU: (standing - 50) x 0.3; export routes: +3 each, at most +9) + remembered
  causes that fade with a half-life of 20 quarters (historical events with their sources, your fork answers, deals,
  envoy answers, delegations +8, US backing in a war +5). Remembered causes add at most +/-35 on top of the status.
  `causes` always sums to `relation`.
- **Relation levels**: Hostile < -50 <= Unfriendly < -20 <= Neutral < 20 <= Friendly < 45 <= Close partner < 70 <= Strategic partner.
- **Timeline**: each actor's real phases (`war | ceasefire | armistice | treaty | no_relations | relations | alliance | embargo`),
  each with its sources. `phase` is the current one.
- **Era**: an actor is listed only in its era (`active`): the UAE from Dec 1971, the EEC from the 1964 agreement, the PA
  from 1994, China from 1949 (relations 1992), etc. Names follow the date (USSR -> Russia 1991, Germany 1990, EU 1993,
  Iran (the Shah) -> Iran (Islamic Republic) Feb 1979).
- **Exposure**: some deals make you depend on a patron (`exposure`, fades with a half-life of 40 quarters). When that
  patron historically used its leverage (France 1967/1969, the 1953 US aid freeze, Bonn 1965, Britain 1969/1982, the
  1975 reassessment, Iran 1979, the 1981 suspension, China-related US pressure 2000/2005, Turkey 2011, Egypt's gas
  2012, Russia 2018), you pay `per10 x exposure/10` (x1.25 if the relation is below 10, x0.75 above 40) and the
  exposure halves. The ghost of history takes no deals and carries none.

### Calls
```
sim.get_diplomacy() -> [row]              # v2 rows plus the v3 keys below (all actors that exist at the date)
sim.get_relations() -> [row+]             # the shape ui-v3 asked for: only actors in their era
sim.get_actor_diplomacy(actor_id) -> actor   # the full card for the diplomacy screen
sim.get_diplomacy_screen() -> screen
sim.get_deals(actor_id) -> [deal]         # the actor's deals of this era (also in actor.deals)
sim.preview_deal(deal_id) | preview_deal(actor_id, deal_id) -> deal
sim.propose_deal(deal_id) | propose_deal(actor_id, deal_id) -> {ok, accepted, reason, text, effects_text: [str], deal}
sim.send_delegation(actor_id) -> bool     # unchanged (25 gold x era, every 8 turns): +8 relation, fading
sim.choose_diplomacy(option_index | option_id) -> bool   # the envoy decision
sim.resolve_recommended(decision)         # works for type "diplomacy" (SimAI -> sim.diplo.ai_pick)
```

`row` (get_diplomacy):
```
{id, name, kind, status, relation, since, trade_partner, delegation_ready,          # v2
 relation_level: {id, label}, status_label, phase: phase, active: bool,
 top_causes: [cause] (3), deals_ready: int, exposure: float, portrait: "", region: "<group id>"}
```
`row+` (get_relations) = row plus `{trend (relation change over 4 quarters), causes: [cause],
leader: {id, name, title, portrait} | {}, deals: [deal], active_terms: [{label, until}], war: bool}`.
The leader and portrait come from art-2d's `data/art_manifest.json` by actor and year.

`cause`: `{label, amount, kind: status|standing|trade|event|fork|deal|envoy|delegation|crisis|legacy|cap, since: "Q1 1967" | "", source: [S-ids], fading: bool}`

`phase`: `{kind, label, from, from_turn, to_turn, from_label, source: [S-ids], note}`; in `actor.timeline` also `current: bool, past: bool`.

`actor` (get_actor_diplomacy):
```
{id, name, kind, active, era: {from, until}, group, leader: {...} | {}, trend,
 agenda: {text, source: [S-ids]}, status, status_label, since, phase, timeline: [phase],
 relation, relation_level, causes: [cause], exposure: {value, risks: [{title, source}]},
 deals: [deal], history: [log entry] (last 12 with this actor), trade_partner,
 delegation: {ready, cost, relation: 8}}
```

`deal`:
```
{id, actor, actor_name, kind: aid|loan|arms|arms_sale|trade|reparations|back_channel|recognition|joint|un_vote|sanctions,
 kind_label, title, text, years: "1954-1958", available: bool, acceptable: bool, reason: "" | why not,
 cooldown_left, times_taken, give: [effect] (costs), get: [effect] (gains), now: [str], lasting: [str], effects: [effect],
 relation: [{actor, name, amount}] (this actor and third parties), exposure: float, risk_text, risks: [str],
 historical: bool, advocate, cite: [{claim, source, quote, url}], source: [S-ids], relation_min,
 label, desc, cost: {stat: amount}, effects_text: [str], tradeoffs: [str], cooldown}       # aliases for ui-v3
```
`available` = in its era, conditions met and off cooldown; `acceptable` = the partner's `relation_min` is met and you
can pay (else `reason`, Civ VI's "what would make this work?"). Deals outside their era are not listed (a deal that
opens within a year shows with its reason). `effect` is the fork effect struct: `{stat, amount, unit, when: "now", good}`
or `{stat, type, amount, unit, from, until, label, good, group?}`.

`screen` (get_diplomacy_screen):
```
{date, actors: [row] (active, in data order), pending: decision | {}, log: [log entry] (last 20),
 groups: [{id, label}], deals_taken: {kind: n}, levels: [{below, id, label}]}
```
`log entry`: `{turn, date, actor, kind: deal|envoy|leverage, text, deal?|envoy?, option?, historical?, leverage?, exposure?}`

### The envoy decision (type `diplomacy`, blocking, a CORE story decision)
Offered at most every 2 quarters, and only when a real opportunity is open: a dated envoy, request or crisis of that
moment (`envoys` in diplomacy.json), or a partner proposing one of its era's deals (`offer`). It prefers quarters with
no other core decision; an open opportunity is offered anyway after 6 quarters or in its last quarter. A forced end
of turn takes the historical answer. In `get_pending_decisions()` / `next_action()` (order: after `immigration`):
```
{type: "diplomacy", blocking: true, label: "ENVOY: <title>", envoy: id, kind: envoy|request|crisis|offer,
 actor, actor_name, title, text, explain, date, source: [S-ids], relation, relation_level, status, phase, leader,
 options: [{id: accept|counter|delay|decline|alternative (the answer's stance), label, advocate, historical, default (Recommended), now: [str], lasting: [str],
            effects: [effect], relation: [{actor, name, amount}], exposure: [{actor, name, amount, risks: [str]}],
            cite, note, deal, desc, effects_text: [str], fx: {stat: amount}, actor}]}
```
Exactly one option is historical; every other one names its advocate with a verbatim cite. Choosing a non-historical
option sends a `what_happened` notification (`{envoy, chosen, historical}`). The Recommended pick weighs the tracks
where you trail the ghost, an empty treasury, a coming war (readiness), poor relations and exposure to a patron whose
leverage is near; sim_test fails if one stance is Recommended in more than 45% of appearances (player and varied runs).
The envoy decision does not make a quarter "busy" (minister titles keep their timing) and never displaces the agenda. With no dedicated
screen yet the generic options popup resolves it through `choose_diplomacy(index)`.
Decisions also appear in `get_path_ledger()` / `get_end_summary().ledger` with `kind: "diplomacy"`, `id: "dip:<id>"`.

### Notifications and AI
- `notification` kind `diplomacy`: a deal concluded, an envoy arriving, a patron's leverage biting (`{actor, deal?|leverage?}`).
- Autoplayers: `SimAI` takes at most one deal a quarter (`sim.diplo.ai_turn(style)`; the historical style and the
  ghost take none) and answers envoys by style (historical / varied = best non-historical / recommended).
- `sim_test` adds "### Diplomacy": relations per actor per decade, deals taken, envoy answers, Recommended shares,
  leverage hits and every actor's legal status against its real timeline (the historical-picks run must match).


## v3 fix round (fix-v3a): soft fail states, Recommended investing, content past the end

### Collapses of the state (V3 item 13)
Module `scripts/sim/sim_collapse.gd` (`sim.collapse`), data: the `kind: "collapse"` entries of `data/endings.json`
(`collapse_fiscal`, `collapse_trust`, `collapse_military`). State in `state.counters["collapse"]` (saved). Never in the
ghost (mode "historical").
- Each quarter, after it is played (`Sim.end_turn`), every collapse's `conditions` are measured (thresholds per
  difficulty in each condition's `difficulty`). While all hold (except `final` ones), its strain grows by one quarter,
  unless the quarter turned the trend around (debt or inflation falling, trust rising, readiness rebuilt); otherwise
  it eases by `recover` (2) quarters (a military strain between wars: 1 a quarter with Readiness >= 50, else 1 a year).
- From `warn_at` the collapse is in danger: a `notification` of kind `collapse` (`{collapse, first: true, quarters_left}`)
  at the first warning of each episode, again with 4 or fewer quarters left, `{recovered: true}` when it clears;
  government crises for the trust collapse (`{government_crisis: n}`).
- At the difficulty's `quarters` (Normal 12 / 12 / 7, at least 4 quarters after the warning) the game ends:
  `state.game_over`, `game_over` is emitted with the turn not advanced. `get_end_summary()` has `collapse` (id),
  `memorial: {}` (no memorial after a collapse), `ending` = the collapse (with `collapse: true`), and the epilogue
  paragraphs `ending`, `what_went_wrong`, `what_might`, then the usual forks/wars/budgets/diplomacy/programmes/money and `close`.
  `get_endings()` adds `collapse: [status]` and `collapsed` (id); `primary` is the collapse id after one.
- Conditions (Normal): fiscal: (debt + overdraft) / lenders' limit >= 1.1 and inflation >= 100%; trust: national Civic
  Trust <= 40 and >= 25% of residents in cities in unrest/revolt or with trust under 26, plus >= 2 government crises in
  three years (final); military: a war under way, Readiness <= 25, strikes on towns >= 15 more than history's by that date.
  With the debt and overdraft past the limit, the inflation gap limit widens to 0.9 log points in every era.
```gdscript
sim.get_collapse_status()   # [{id, name, summary, kind: "collapse", strain, limit, warn_at, quarters_left, level: ok|watch|danger,
                            #   progress, conditions: [{id, label, metric, value, target, cmp, met, unit, final, text}], advice, warning, peak, ended}]
sim.get_collapse_warnings() # the ones in danger, closest first
sim.get_collapse_top_bar()  # {show, level, text ("6q"), name, id, tooltip: [lines]}
sim.get_ending_outlook()    # adds the collapses with collapse: true, level, strain, limit, quarters_left, advice
get_fiscal_indicator()      # level "danger" while the fiscal collapse is in danger; key collapse: ok|watch|danger
sim.collapse.debug_set(id, quarters) / debug_end(id)   # captures and tests only
```
- `sim_test` (full run and `--collapse`, which writes COLLAPSE_REPORT.md): ruinous drivers `ruin_fiscal`, `ruin_trust`,
  `ruin_military` (SimAI styles) must each reach their collapse with 4+ quarters of warning, a "what went wrong"
  epilogue and no memorial; at the first warning the Recommended player takes over a copy and must recover. Every
  autoplayer line in the endings report shows how close each collapse came; a collapse on Easy or Normal fails.
  They write `user://collapse_<fiscal|trust|military>_warn.json` / `_end.json`.

### Recommended investing
- The Recommended autoplayer keeps two quarters of income in the treasury while a national programme is on offer
  (purchases no longer eat the surplus), and the programme decision's "invest the surplus" comes every quarter while
  the treasury holds four times the reserve. sim_test's Recommended-share bar is now 45% (programme decisions included).

### Content past the end of the game
- `SimDB.shown_until()` (= `Sim.full_last_turn()`), `db.event_shown(ev)`, `db.war_shown(w)`, `db.fork_shown(f)`,
  `db.event_id_shown(id)`: the Civilopedia lists no event or war dated after it; `get_upcoming_events()` stops at the
  last playable turn. The data stays in place.


## v3 fix round (fix3-econ): fiscal levers, structural deficit, endings, score health, war losses

### Running costs and the structural-deficit alarm
- `last_budget.upkeep` is now `SimEconomy.upkeep_parts()["total"]`; the parts are in `state.counters["upkeep_parts"]`
  (`buildings, districts, public, units, mothballed, pct, by_building, cities`).
- Each quarter `econ.note_structural()` measures (upkeep + debt service) / revenue (income + net positive transfers).
  Above 110% for 4 quarters: the alarm (`counters["structural"].alarm`), a `notification` of kind `fiscal`
  `{structural: true, first, ratio}` whose text names the upkeep by category and the top-5 cities (advisor card), and a
  Cabinet Agenda item titled "Structural deficit" (`agenda.structural: true`) in place of the plain deficit item. It
  clears after 2 quarters at or below 100% (`{structural: false, recovered: true}`). Data: `data/fiscal.json`.
```gdscript
sim.get_fiscal_report()        # {revenue, upkeep, parts:{buildings,public,districts,units,mothballed,pct}, debt_service, ratio, alarm,
                               #  quarters_over, since, gap, text, top_cities:[{id,name,upkeep,buildings}], mothballed:[{city,city_name,building,name,reopen_cost}],
                               #  mothball_plan:[{city,city_name,building,name,upkeep,saves,value}], privatisations:[...], stabilisation:{...}, levers_used}
sim.get_city_upkeep(city_id)   # {total, buildings:[{id,name,upkeep,value,service}], mothballed:[{id,name,reopen_cost}]}  (also get_city().upkeep / .mothballed)
sim.mothball_building(city_id, building_id) -> String   # "" ok, else why. The building stops; it keeps 20% of its upkeep
sim.reopen_building(city_id, building_id) -> String     # costs 6 quarters of its upkeep x the gold scale
sim.close_building(city_id, building_id) -> String      # for good; a service building costs the city -2 trust
sim.get_privatisations() -> Array   # [{id, name, desc, available, reason, done, historical, hist_label, advocate, cite, source, gold, upkeep_pct, output_pct, years, trust, effects_text}]
sim.privatise(id) -> bool           # one-off gold (1.2-2 quarters of income), upkeep -3..-5% for 10-12 years, Civic Trust -1..-3
sim.get_stabilisation() -> Dict     # {id, name, desc, available, reason, historical, hist_year, advocate, cite, source, effects_text, cooldown_left}
sim.stabilise() -> bool             # from 40% inflation, the alarm or a fiscal collapse in sight; once a decade: upkeep -15% for 3 years,
                                    # inflation gap x0.25 and anchored for 2 years; trust -5, amenity -1 and production -6% for a year
```
- The structural agenda options carry `fx.econ_action` (applied by `Sim.choose_agenda`) and `effects_extra` (merged into
  the decision's `effects`), plus `desc`, `advocate`, `cite`, `historical`.
- A mothballed building is not offered in `get_buildable` (it is reopened instead).
- Sources: S5990-S5992 (`sources/pending/sim_sources_v3_fix_econ.json`) and existing S-ids (S5101, S536, S5817-S5819,
  S690, S1074, S5415, S5126, S5125, S577).

### Tiered fiscal indicator
`get_fiscal_indicator().level` is now `ok | watch | warning | danger` (`levels` lists them), measured against history's
path. Watch: running costs above 110% for 2 quarters, an inflation gap over 0.2 log points, 2+ quarters below zero, debt
over 2.5 years of revenue, or debt plus overdraft at 80% of the lenders' limit. Warning: the structural alarm, a gap over
0.5, a year below zero still in deficit, the lenders' limit reached, or every fiscal-collapse condition holding. Danger:
the collapse countdown. New keys: `structural`, `structural_ratio`, `upkeep_text`, and `why` (resumed 2026-10-14: an
Array of short English reasons for the tier, e.g. `"treasury below zero for 5 quarters"`, `"inflation above history's"`;
empty when `ok`; good for the tooltip). An overdraft history itself ran at that date (the ghost's treasury below zero,
1949-52) is `watch`, not `warning`. The collapse `status().level` also gains `warning` (every condition holds).

### A recoverable fiscal collapse
While every fiscal condition holds, a quarter with the budget in surplus now EASES the strain by 1; running costs within
revenue, net gold better by a quarter of the last year's average deficit, or falling debt or inflation HOLD it (resumed
2026-10-14: easing on a single better quarter let a ruinous budget swinging between deficits escape the countdown). The
advice, the warning and the epilogue name the upkeep; "What went wrong" lists the drivers by size and the levers used.

### Inflation (A8)
History's CPI path already contains history's own choices, so only the player's DIFFERENCE from the ghost moves
inflation: the budget record (ghost.json rows carry `net`, `inc`), the lasting inflation terms (`sim.inflation_terms()`
= own `stream_sum("inflation")` minus the ghost's `infs`; the ghost itself adds none), price policies in force (`infm`)
and emergency price measures (`infsh`, the running sum of `shift_inflation` in log points). With history's choices the
game now reads 0.8-3.0% in 1967-68 (history 1.8-2.5%) and 357-368% at the 1984-85 peak (history 332-365%). A stabilisation package
anchors it. Surpluses cannot push a low-inflation year below `min(base, 0.4 * base - 0.5)`.

### Endings and score
- A criterion may carry `or` (an alternative threshold; `criteria[].or` in get_endings). The programme criteria are now
  3 levels ahead of history, or a second track threshold.
- New ending `nation_ahead` ("A Nation Ahead", `headline_fallback`): overall at least 125% (health-weighted) and no
  collapse in danger. It is the headline only when no named ending is met. A Mixed Record's summary is written from the
  real track balance (`endgame.mixed_text()`).
- `get_score()` / `score.current()`: `overall` is now multiplied by the state's health (`health`, `health_parts`,
  `health_text`, `overall_raw`): collapse strain up to -25% (-30% after a collapse), inflation above history's up to
  -8%, a treasury below zero up to -6%. `score.overall_now()` is the cheap version.
- **Choices leave a lasting mark (A7, resumed 2026-10-14).** `sim.endgame.choice_legacy()` -> `{track: percent}`: a share
  of every lasting term set by a cabinet decision (forks, event choices, envoys, deals; not programmes, privatisations,
  rails or coalition money) stays as the term runs and after it ends (`CHOICE_LEGACY_K` = 0.8% of the track per typical
  term per 8 years, at most 3 x 8 years, group terms half, softly capped at +-35%; population left out). Ghost rows carry
  history's own mark (`clg`); the player's economy, science, water, standing and cohesion tracks are multiplied by
  `1 + (mine - history's) / 100` (`choice_legacy_vs_history()`), so history's choices score exactly as history and a
  path's upsides and downsides against history's compound to the end. "What made the difference" gains entries of kind
  `legacy` ("the lasting mark of your cabinet's choices, -24% on this track against history's choices (+2% against +26%)").
- **A track left far behind weighs the health (A7, resumed 2026-10-14).** `health` also takes a quarter percent of the
  overall for every point a track sits below 90% of history's (up to -20%; part label "far behind history's record
  (Economy 71%)"), so a cabinet that loses ground on one track is not hidden by gains on the others. `score.health(ratios)`
  accepts the {track: ratio} map a caller already has.

### War losses and readiness (M5)
The chosen front order's previewed `expected_units_lost` is realised (`SimMilitary._war_losses`). Fractions accumulate
per war; each whole unit is taken (this war's reserves first, then the standing army nearest the fronts), with +60 war
weariness, `crisis.player_lost` and a `combat` notification `{unit_lost: true}`. The readiness requirement grows by 3 a
year from 2005.

### Other
- `get_streams()` caps `until` at the last turn (`to_end: true`); old saves past the end load at Q3 2023 (game over).
- AI: style `ruin_builder` (the naive builder, sim_test). The Recommended, varied and strategist players mothball,
  privatise and stabilise when the alarm is on and reopen when healthy (not within 2 years of mothballing), add no upkeep
  under fiscal stress, and refinance an overdraft of 3+ quarters with a loan. The historical styles borrow (Independence
  Bonds) when below zero for 2+ quarters in 1949-56.
- AI: the `varied` style now answers forks and event choices with a non-historical option taken without weighing its
  terms (deterministic per fork and seed), as the full-game critic's run did; it still runs the budget and programmes
  competently. Recommended weighs every option, so the two runs end apart (sim_test `--divergence`: 15+ points).
- `SimEconomy.FOOD_EXPORT` stays 0.0 (exports off since the sim-endgame calibration); the API text above is corrected.
- Hebrew: `data/i18n/he/fiscal.json` (new skeleton source in `tools/i18n/make_skeletons.py`, which also gained
  `--only <sources>`) and `i18n/he/sim_zzz_fix3_econ.json` (the sim's new fiscal, score, ending and war-loss strings).

## v3 fix round (fix3-story)

### Consequences of refused forks (A1)
- Event `consequences` entries (`mode: "course" | "skip"`) may now carry their own terms, applied when they match:
  `effects` (event-style numeric: morale, intl_standing, gold, gold_per_turn, production, science, culture), `now` (fork-style:
  gold, standing, trust, readiness, cohesion, inflation), `lasting` (fork-style terms), `relations` ({actor: amount} remembered
  causes, label `relation_label`), `flags`, and `diplo` ({actor: status}; `""` leaves the status where it was). A skipped event
  may carry `now`/`lasting` too. 59 new entries (tag `"by": "fix3-story"`) cover every refused answer whose event still fires;
  wars use `variants` (1956 Sevres declined, 1967 strike now / wait for the flotilla, 1982 postpone).
- When a second fork links to the same event, its own matching entry (or the war's variant) gives the note; the generic
  "does not change this event" line is the last resort, carries `{"generic": true}` and is counted in `counters.generic_notes`.
- Notifications: `history_course` / `consequence` as before. `counters.consequences_applied` counts specific outcomes.
- Forks gated by cancelled events: `fork_1962_eichmann_sentence` (not after an international tribunal), `fork_1982_beirut_inquiry`
  and `fork_1983_kahan` (`not_flag: event_skipped:<id>`).

### No duplicate questions (A2)
- `SimForks.REPLACES` adds `fork_1952_reparations_talks -> evt_1952_reparations_debate`, `fork_1957_gaza_and_sharm -> evt_1957_sinai_withdrawal`.
- `SimCabinet.COALITION_FORKS` adds the 1959, 1961, 1965, 1969, 1977, 1981, 1988 and 2009 coalition forks (no coalition screen within 2 quarters).
- Envoys: `subject_fork` (id or list) — the envoy is not offered while that fork is open, answered, or within 2 quarters of its
  window (`SimDiplomacy.fork_asks_same(envoy)`): `2008_syria`, `2022_ukraine`.

### Diplomacy follows the forks (A3, A4)
- Timeline phases (diplomacy.json) may have `if` / `unless` ({fork: option}), `if_flag` / `unless_flag`, and `if_skipped: true`
  (shown only when its `from_event` was cancelled). A phase whose `from_event` was cancelled, or that starts after Q3 2023, is
  not shown (`SimDiplomacy.phase_applies(p)`). Refusing Oslo: the PLO reads "No recognition", the PA "Self-rule on the map, but no
  agreements with your government", Jordan's treaty "signed without a Palestinian track"; the PA status is `none`.
- `actors.json status_rails`: a rail whose `from_event` was cancelled, or with a set `unless_flag`, does not hold. New rails:
  PLO negotiating after Oslo; Egypt `peace` (no ambassadors) Sept 1982 - Sept 1986; Syria ceasefire 2000-08, negotiating May-Dec
  2008, ceasefire after; Lebanon `none` 2000-06.
- New sourced phases: US FTA 1985, Arrow 1988, MOU 2007; Egypt's cold peace 1982-86 and 1986; Syria (Madrid track to 2000,
  Geneva 2000, Turkish talks 2008, revolt 2011); Lebanon security zone 1985, withdrawal 2000; Turkey Davos 2009.
  `dated_relations` may have `unless_flag`. A cancelled event leaves no relation memory.

### Envoys and deals (A5, A6)
- A deal may have `offer_eras`: [{from, until, title, text, accept_label, accept_historical?, accept_cite?, terms?, decline?,
  delay?, requires?}]. It proposes itself once per era with that era's text and options (`SimDiplomacy.offer_era(dl)`,
  `offer_of(dl)`); `usa_arms` (1962-66 with the Dimona-visit counter only then; Ford 1975-76; Carter 1978) and `germany_loans`
  (Adenauer 1960-63; Schmidt 1976 with Allon's counter). The pending decision stores `era`.
- Offers may have a `delay` option ({label, advocate, cite, relation, now, lasting}).
- Deal risks: only leverage due within 15 years (`RISK_WINDOW` = 60 quarters) of the deal's start or now, and never after Q3 2023
  (the 1948 Czech arms no longer list the 2018 Il-20 risk). Exposure risks in the envoy view and `get_actor().exposure.risks` too.
- `preview_deal(...).counter` = the deal's sourced counter-offer ({label, advocate, cite, note, now, lasting, effects, relation}) or
  {}; `propose_deal(actor, deal, "counter")` takes it.
- New envoys (sources S5940-S5949, S5962-S5969 in `sources/pending/sim_sources_v3_fix_story.json`): `1949_zaim` (Syria),
  `1986_ifrane` (Morocco), `1987_lavi`, `1988_plo_dialogue`, `1994_jordan_terms`, `2020_f35_uae` (after the Abraham Accords).
  `1969_soviet_jewry` now Q4 1969 only (it always lost to the Chieftain envoy). `2022_ukraine` option ids `mediate` / `arm_ukraine`.

### Nothing after Q3 2023 is shown (A11)
- `SimDB.end_year()`, `after_end(date)`, `years_after_end(text)`, `scrub_text(text)` (caps "2017-2026" to "2017-2023", drops
  sentences about later years), `hist_year(item)`. At load SimDB drops city status entries starting after the end (a later `to`
  reads "now"), scrubs notes/descriptions/cites, and moves a tech/civic/building/unit year after the end to `_hist_year` (no
  "History: 2025"; the sim still gates by it). Items may give `<field>_until_end` replacements (Laser Interception: description,
  source, cite). `SimDB.scrub_programmes()` (called by SimEndgame) removes post-end `hist` dates (Iron Beam opens as a level
  history had not reached). Governments' spans are capped at 2023.
- Lasting-term spans never show a year after 2023; a term starting after the end is never shown nor applied (`SimForks.shown_terms`).
- Bibliography (citations, URLs, a source's publication date) is not content and is not scanned.
- sim_test `--validate-only` runs `_leak_scan` (cities, trees, eras, programmes, shown events/forks/wars, fork option views,
  choice terms, envoys, deals, the diplomacy screen at the last turn, cabinet spans) and `_generic_note_check` (max 5).
  ui_test scans every Civilopedia article (before its Sources section).

### Density: four new choice events (A10, resumed run)
- Event choices (type `event_choice`, same shape as before) on `evt_1966_military_government_ends` (Q4 1966: Eshkol abolishes /
  Ben-Gurion keeps / Pinhas Rosen also repeals the 1945 regulations), `evt_1967_eilat_sinking` (Q4 1967: the Suez refineries /
  the security cabinet's first idea, the Egyptian air force), `evt_2016_unscr_2334` (Q4 2016: Netanyahu's measures against the
  sponsors / the Foreign Ministry's no-downgrade line) and `evt_2021_meron_disaster` (Q2 2021: a state commission / Shas and
  UTJ's no). Each has `choice_terms.json` streams; sources S5680-S5684 (pending file `sim_sources_v3_fix_story.json`).
- The 1966 event's morale and standing moved into its choices (the event itself now has no numeric effect).
- More phases: the PA's 2005 phase has an Oslo-refused variant ("Abbas elected (2005); still no agreements with your
  government"); Jordan and Lebanon get a Madrid phase (1991). Phase lists stay in date order, so `timeline.N` i18n keys shifted
  (catalog repaired).
- Era offers: a candidate offer's `until` is its era's end (made on that quarter even on a busy turn); `usa_arms` cooldown 12 -> 8
  quarters so the 1978 Carter package is not blocked by the 1975 Ford offer.

## v3 integration (2026-10-14): nothing after Q3 2023 is in the data

The user, 2026-10-14: "we dont need them after oct 7". Everything dated after Q3 2023 was deleted at the source by
`tools/purge_after_end.py` (load-modify-save, idempotent): 34 events, 4 forks (`fork_2024_haredi_draft`,
`fork_2025_syria_south`, `fork_2025_e1_plan`, `fork_2026_iran_war`), 6 wars (`war_2023_northern_front`, `war_2024_*`,
`war_2025_twelve_day`, `war_2026_*`), their choice terms and art, Syria's post-Assad name, the 2024 map era, 3 city status
entries, lasting terms starting after the end (1) and the dated tails of terms ending after it (capped at 2023-09),
history dates after 2023 (Iron Beam: no history year, `hist_after_end: true`; the programme level opens from Q3 2017
as one history had not reached), government spans (capped at 2023), real-series points for 2024-25 and the sources
cited only by these (retired). The memorial (`data/ending_oct7.json`) is untouched and is the only 7 Oct content.
- `SimDB.LAST_TURN` is 302 (the data ends with the game). `_check_date` refuses any data date after 2023.
- Tombstones: every deleted event, fork and war id is in `tools/history/data/deleted_event_ids.json` (SimDB
  `deleted_ids`; `_scan_deleted` refuses them in forks and wars; `check_sources.py` and `tools/history/apply.py` refuse
  them in events).
- The runtime helpers stay as a safety net and hide nothing: `SimDB.event_shown/war_shown/fork_shown` and the load-time
  scrub (`_filter_after_end`, `scrub_programmes`), which now logs any change in `SimDB.scrub_log`. A cite is scrubbed
  only for its claim or note: a verbatim quote is bibliography (Ein Gedi's CBS table row with locality code 2042 is not
  a year, and its founding cite is shown again).
- `SimDB.hist_year(item)` is `end_year() + 2` for an item with `hist_after_end` (gated as before, shown as "not reached
  in history by the game's end").
- Deleted-content scans: sim_test `_purge_scan` (raw data files, the Hebrew data and UI catalogs, the helpers and the
  scrub log; part of `--validate-only`), `check_sources.py` `after_end_scan` (the same over game/data and the catalogs),
  ui_test (the Civilopedia check fails if the data holds anything past the end or the scrub changed anything).
  Whitelisted: the memorial, ghost.json and the scenario saves, portrait `era_from`/`era_to` in art_manifest.json,
  bibliography keys (url, quote, accessed, citation...).
- Score display: `SimScore.ratio_text(ratio)` / `ratio_delta_text(ratio)`: a track counts up to 200% of history's in the
  score, so a larger ratio reads ">200%" (">+100%" as a difference) on the VS. HISTORY panel, the end screen, the Ending
  outlook (`_metric_text`, `V3Adapter._fmt_metric`) and the epilogue's mixed record. L10n's `{#0}` accepts a leading ">".
- Event order: SimDB sorts events by date with a stable tie-break (the order in events.json; `Array.sort_custom` is not
  stable). events.json keeps the same-date order the game used before the purge, so the historical run (the ghost)
  and the autoplayers follow the same course as before the purge (the collapse drivers collapse on the same dates).


## v3 final round (fix4-econ): every outflow, the policy-card lever, readiness upkeep, endings

### The whole budget, line by line (full-game critic N1)
- `SimEconomy.note_structural(income, extra, upkeep, debt_pay, budget)` now measures EVERY recurring outflow against
  gross revenue. Outflows: running costs, the new readiness upkeep, absorption, policy cards, negative lasting terms
  and rails (war burdens included), event costs, food imports, debt service. Revenue: taxes and yields, every positive
  transfer (aid, reparations, positive terms) and food exports. `ratio` = outflow / revenue, so 100% means a balanced
  budget and the percentage shown is the real one. National programme instalments are investment, paid only from a
  surplus: listed, but outside the ratio.
- The alarm: above 110% for 4 quarters, or above history's own ratio at that date + 10 points when history ran a deeper
  deficit (1949-52 absorption; ghost.json rows carry `sr`); it clears after 2 quarters at or below 100% (or history's).
  `structural()` adds `outflow`, `limit`, `hist_ratio`, `ratio_running` (the old running costs + debt service figure).
- `counters["budget_lines"]` = `econ.budget_lines(...)`: `{revenue, outflow, net, lines}`; the lines add up to
  `last_budget.net` exactly (sim_test checks it every quarter in the populist case).
```gdscript
sim.get_fiscal_report()   # adds: lines: [{id, label, amount (+ revenue, - outflow), kind: revenue|outflow|investment, items: [{label, amount}]}],
                          #   revenue, outflow, net, ratio (outflow / revenue: the one to show), ratio_running, limit,
                          #   parts.readiness, policy_cards (= get_policy_costs())
                          # line ids: income, transfers_in, food_exports | running, readiness, absorption, policies, terms_out,
                          #   events_out, imports, debt_service | programmes
sim.econ.upkeep_text()    # "Revenue 228 (taxes 209, aid and transfers 19) against outflows 337, 148% of it: running costs 247
                          #  (buildings 159, ...); absorption 32; policy cards 38 (Social Security 23, ...); debt service 11."
sim.econ.transfer_items() # [{label, amount, kind: event|policy|term|rail|other, src}] (the quarter's transfers item by item)
```
- The structural-deficit notification, the agenda item, the fiscal indicator's tooltip and `upkeep_text` all use
  these lines. The indicator's `why` reads "spending above revenue" (was "running costs above revenue").

### Scale back or suspend a costly policy card (N1)
```gdscript
sim.get_policy_costs()    # [{id, name, cost (gold a quarter now), full_cost, state: "full"|"half"|"suspended", saves_half, saves_suspend,
                          #   options: [{mode: "half"|"suspend"|"restore", label, desc, saves, effects_text, advocate, cite, source,
                          #   historical, hist_label, available, reason}]}]   costliest first; slotted cards costing 2+ gold
sim.scale_back_policy(id, "half"|"suspend") -> String   # "" ok, else why
sim.restore_policy(id) -> String
```
- Half strength: every effect of the card x0.5 (half its cost, half its benefits), Civic Trust -2 in every city.
  Suspended: the card keeps its slot and does nothing, Civic Trust -4, Cohesion -15. Restoring is free; unslotting the
  card ends the cut (`counters["policy_cuts"]` = {policy id: "half"|"suspend"}). Data: `data/fiscal.json`
  `policy_cuts` (versions: the 1985 plan's spending cut, Moda'i and Bruno, S5992; the 2002-03 cuts, Netanyahu, S544
  and S5213).
- The structural agenda offers the costliest full card at half strength (`fx.econ_action: "scale_back_policy"`, `id`,
  `mode`). Recommended, varied and the strategists scale back a card after 3 quarters of the alarm (at once with the
  treasury below zero or a fiscal collapse in sight), suspend a halved card in a collapse countdown, and restore it 3
  years later when the budget has room.

### Stabilisation package
- `fiscal.json stabilisation.gap_keep` 0.0 and `anchor_quarters` 14: the package now brings inflation back to history's
  rate (the gap reset in full) and anchors it for 3.5 years. `effects_text` says so.

### Readiness costs upkeep and decays (item 2)
- `SimEconomy.readiness_upkeep()`: nothing up to Readiness 60, then up to 6% of the average quarterly income at 100
  (`fiscal.json readiness`); part of the running costs (`upkeep_parts().readiness`, the Treasury line `readiness`).
- Above 80 each further point is dearer: held = 80 + 20 x (1 - e^(-(raw - 80)/20)) (raw 100 -> 93, raw 110 -> 95).
- While the treasury is below zero for 2+ quarters (beyond history's own overdraft) Readiness decays 2 a quarter, to
  -20 at most, and recovers 4 a quarter once paid. `counters.readiness_parts` adds `top`, `unpaid`, `upkeep`; the
  quarterly readiness reasons add "the last points are the dearest (above 80)" and "training and stocks unpaid".
- The military collapse's recovery note says "the war has ended, but Readiness is still only N" when the danger passed
  only because the war ended (`endings.json collapse_military.recovered_war_over`).

### The mothball plan (item 3)
- `building_value` no longer marks buildings in small towns down; a service building in a city of 8+ counts x1.15.
- `mothball_plan` keeps track of its picks: at most 2 buildings, and at most 1 that serves residents (schools, clinics,
  public housing, absorption centres), from any one city; never a city below zero amenities or short of housing; ties go
  to the larger city (`fiscal.json mothball.plan_max_per_city`, `plan_max_service_per_city`). Plan rows add `service`.

### Endings and the end screen (items 4 and 5)
- Secure State: strikes on towns at most 110% of history's (a replay of history's choices lands at 104-109%), and 3+
  security programme levels ahead of history with no "or" (the strikes alternative made it free for a builder who
  never funded the shield). Peace with Neighbours: 5 of the 6 treaties history reached.
- A criterion's `or.label` no longer starts with "or:"; the criterion `text` reads "...; or <alternative>".
- `get_endings().leading` = the unmet ending with the most thresholds met, then the most progress: the same ending the
  mixed record's "Closest" names.
- Epilogue: "Within reach" only when the one missed threshold has progress >= 0.9 (`SimEndgame.NEAR_PROGRESS`); "Still
  shaping the country" lists up to 4 choices spread over the whole game (the latest one included); the mixed record's
  close no longer says "four endings".
- One count of decisions: `sim.endgame.choice_counts()` -> `{decisions, matched_history, differed, envoys,
  envoys_differed}` from `sim.forks.get_path_ledger()`. `get_end_summary().ledger_summary` is that dictionary and
  `get_end_summary().counterfactual_choices` = `differed` (`counterfactual_choices_all` keeps the old counter).

### AI and tests
- New SimAI style `ruin_populist` (the full-game critic's careless populist): borrows whenever offered, tax rebates
  and indexing at the budget review, every welfare card, the naive builder's grand buildings, the least defence
  budget, launches programmes it cannot pay for, never a fiscal lever.
- sim_test (full run and `--collapse`): `_populist_case`. The populist must reach a structural alarm that names the
  policy cards; the Treasury lines must add up to the net every quarter; Recommended taking over a copy at the FIRST
  alarm must avoid every collapse for 20 years.
- Hebrew: `i18n/he/sim_zzz_fix4_econ.json`; `data/i18n/he/fiscal.json` and `endings.json` updated (load-modify-save).

## v3 final round (fix4-diplo): deal end dates, phases, envoys, counters
- `get_relations()[i].active_terms[j]` = `{label, until, until_turn, to_end}`. `until` is "the end of the game" when the
  term runs past the last shown quarter (Q3 2023), else a quarter label; `until_turn` is clipped to the last turn.
  sim_test's leak scan now makes every deal in its last possible quarter and scans these terms and the deal log.
- `SimDiplomacy.phase_view(actor)`: the phase shown by `get_actor()`, `get_relations()` and the envoy decision. If the
  game's legal status no longer fits the phase kind (`PHASE_OK`), the label gets " (today: <status>)" and
  `status_differs: true`. `phase(actor)` stays the raw historical phase (the statuses-against-history check).
- New phases (sourced) for France (1982, 2008), Egypt (2005, 2011 x2, 2012, 2020), Iran (2005, 2015, 2018), Hezbollah
  (1996, 2000, 2006 war, UNSCR 1701), the US (1991, 1999), Saudi Arabia (2022, 2023), Qatar (1996, 2000, 2009) and a
  Jordan treaty phase for the 1994 hold-out (flag `jordan_treaty_holdout`, set by envoy `1994_jordan_terms:reservations`).
- New envoys: `2002_saudi_plan`, `2003_loan_guarantees`, `2007_mou`, `2008_russia_syria`. A dated envoy in its last
  quarter is offered even within `MIN_GAP` of the last diplomatic decision (so 1977_morocco comes in Q3 1977 and
  1988_plo_dialogue in Q4 1988).
- `offer_eras[i].propose: false`: the era's counter-offer shows on the deal screen (`deal_view().counter`) but the
  partner does not propose the deal as an envoy decision. Used by germany_dolphin (1991-92), eec_trade (1974-75) and
  eu_research (2013-14). A counter may be `historical: true` (it is what Israel did).
- `now_text` and `deal_view().cost` give gold, production, science and culture in whole numbers.
- The structural agenda also offers "Borrow abroad to cover the gap" (`fx.borrow`, never Recommended): borrowing was
  on every government's table, and the ruinous drivers take it. The ruinous drivers never take a structural lever
  (`fx.econ_action`); `ruin_fiscal` also slots every welfare card and builds whatever it can (it collapses in the
  1950s now, with 20+ quarters of warning); `ruin_populist` houses newcomers in transit camps (its first structural
  alarm comes in the mid-1960s, as in the critic's run, not in the 1949-52 absorption years).
- The society strategist builds housing from a 1% transit share (others 3%) and re-plans, once a year, any city stuck
  on a repeating city project (`SimAI._replan_city_projects`), so the last transit residents are housed.

## v4 (v4-sim-auto)

The casual layer, "story mode" (`progress/V4_DESIGN.md` 2.1-2.4). The simulation is unchanged: `SimAuto`
(`scripts/sim/sim_auto.gd`, `sim.auto`) only decides who answers each decision. State: `state.counters["auto"]`
(saved with the game). A game without it (every v3 save, and `new_game()` without `play_style`) is Full control,
which is v3 exactly: `sim_test`, the ghost and every autoplayer are unchanged.

### Starting and switching
- `Sim.new_game({..., "play_style": "story" | "full"})`: default `"full"`. The UI passes `"story"` by default.
  Scenario starts take `play_style` too.
- `Sim.domains() -> [{id, name, short, minister, label, types: [decision types], desc}]` (static). The 11 ids:
  `production, research, civics, policies, units, settlement, immigration, cabinet, budget, trade, delegations`.
  `short` is the report prefix ("Housing", "Education", "Cabinet Secretary", "Defence", "Agriculture", "Absorption",
  "Prime Minister's Office", "Finance", "Foreign Ministry").
- `sim.auto.style() -> "story" | "full" | "custom"`; `set_style("story" | "full") -> bool`; `set_all(on: bool)`.
- `sim.auto.is_auto(domain) -> bool`; `set_auto(domain, on) -> bool`: live on any turn. Turning a domain back to
  auto settles it at once (empty queues filled, research picked and so on). Turning it manual brings back its v3
  prompts.
- `sim.auto.brief() -> "balanced" | "security" | "prosperity" | "peace" | "society"`; `set_brief(mode) -> bool`.
  The brief changes only the ministers' routine settings (V4_DESIGN 2.2). Balanced = plain Recommended.

### The player's queue
- `sim.auto.player_decisions() -> Array`: the open decisions that are the player's, in the order of 2.4:
  `event_choice, fork, coalition, crisis_response, agenda (Treasury items only), treasury, state_budget,
  immigration (named waves), diplomacy, programme, dedication, brief`, then any manual domain's routine decisions in
  v3's `DECISION_ORDER`. In Full control: every blocking decision in v3's order.
  - Each entry is the v3 decision dictionary (the same fields as `get_pending_decisions()`), plus:
    - `state_budget` may carry `"surplus"`: the quarter's "invest the surplus" programme decision. It is the second
      half of the budget card (rule 1) and is NOT listed separately; answer it with `sim.choose_programme(i)`.
    - a `programme` with `"merged": true` is a surplus left after the budget was answered this quarter (show it as
      the budget card's second half too).
    - `agenda` (only the structural-deficit and inflation-emergency items are the player's) may carry `"treasury"`:
      the Treasury view below, on the same card.
  - Two items exist only in the casual layer, both `"blocking": false` (End Turn takes their default):
    - `{type: "brief", label, title, text, explain, current, options: [{id, label, desc, default, consequence}]}`:
      asked once, on turn 2 (or the first story-mode turn after it). Answer with `sim.auto.set_brief(id)`.
    - `{type: "treasury", level, title, label, text, explain, options: [{id, label, consequence, recommended,
      available}]}`: the Treasury in danger. Answer with `sim.auto.choose_treasury(id)`.
- `sim.next_action()` returns `sim.auto.primary()` whenever the style is not "full" (v3 otherwise).
- `sim.auto.primary() -> Dictionary`: `player_decisions()[0]`, or `{type: "end_turn", blocking: false,
  label: "END TURN: Q3 1948", next_date, next_hint ("Nothing needs you this quarter" or "Next: the State Budget in
  Q1 1950"), key: "auto.end.label", args: {date}, hint_key: "auto.end.quiet" | "auto.end.next_budget", hint_args}`.
- `sim.auto.quiet() -> bool`: no player decision this quarter (End Turn is the only action).
- `sim.end_turn()`: in story mode the ministers' end-of-quarter routine runs first, and a minister's stuck routine item
  never blocks the turn. `sim.resolve_recommended(d)` also takes the `brief` and `treasury` items.
- `sim.auto.owner(decision) -> String`: the domain id that answers it, or `""` when it is the player's.
  `sim.auto.auto_owned(decision) -> bool`: its owner is a domain on auto now.
- `sim.auto.settle() -> int`: the ministers answer every open decision of an auto domain (Recommended, or the brief's
  strategist). The sim calls it itself (end of `_start_turn`, after every public decision method, at the top of
  `end_turn`), so the UI never needs to.

### Programme queue rules (2.4), while Finance (`budget`) is on auto
1. In a State Budget quarter the surplus decision is merged into the budget card (`state_budget.surplus`).
2. At most one more surplus prompt a calendar year; Finance holds the later ones (report line "kept the surplus").
3. A quarter that already holds 3 player decisions defers its programme decision. Finance holds a surplus, or answers
   "not now" to a level that opened or fell due; `SimEndgame.defer_to_next_quarter()` offers that level again next
   quarter (logged in `counters.auto.deferred`).

### The Treasury in danger
- `sim.auto.treasury_view() -> {} | {type: "treasury", level: "warning" | "danger", title, label, text, explain,
  options}`. It shows when the structural-deficit alarm is on, a fiscal collapse is in sight, or the fiscal indicator
  reads danger, and no emergency plan is running. After "Not now" (or End Turn) it is asked again a year later.
- Options: `finance_plan` (Recommended; what `SimAI.fiscal_levers_danger` would do now, named, e.g. "Finance's plan:
  mothball 6 little-used buildings, halve Social Security"), `stabilise` (when available), `borrow` (never
  Recommended) and `hold` ("Not now").
- `sim.auto.choose_treasury(option_id) -> bool`. `finance_plan` runs the plan now, and Finance repeats it each quarter
  until the danger is over (report line "the emergency plan ends").

### The ministers' report
- `sim.auto.report(turn := -1) -> {turn, lines: [{domain, key, args, text, ref: {kind, id}, n, turn}]}`.
  `-1` = the quarter that just ended (the turn-start actions of this quarter belong to it). `report(sim.state.turn)`
  = what the ministers did so far this quarter. The last 8 quarters are kept.
  - `key` is a stable template id and `args` its values (`city, city_id, item, item_id, kind, n, gold, actor,
    partner, title`, as the key needs). `text` is the English line: `short + ": " + template.format(args)`.
    Hebrew: `L10n.t(domain short) + ": " + L10n.t(key).format(args)`. The templates are `SimAuto.TEMPLATES`.
  - `ref.kind` is `city` (id = city id), `tech`, `civic`, `policy`, `actor`, or `panel` (id = `units`, `policies`,
    `immigration`, `cabinet`, `budget`, `treasury`, `programmes`): the screen the line links to.
  - `n`: how many automatic actions the line covers (unit orders are summed into one line per ministry).
- `sim.auto.domain_view() -> [{id, name, short, minister_name, desc, types, auto, last: [line], pending_manual: n}]`:
  the rows of the Cabinet Room and Settings. `minister_name` is the title of the day (Labour before 1961, the Jewish
  Agency for absorption before 1968, and so on). `pending_manual`: the open decisions of a manual domain.
- `sim.auto.stats() -> {actions, covered, lines}` (for tests: every automatic action is covered by a line).

### The story card (2.3)
- `sim.auto.recommend(decision) -> {index, id, why}`: the Cabinet Secretary's pick (always plain Recommended, with
  the same pickers as `resolve_recommended`). `why` reads e.g. "best for Readiness" or "best for Cohesion, where you
  trail history"; the State Budget uses its own `recommended_why`. It is `{}` on Historian (`sim.hints_enabled()`).
- `sim.auto.story_view(decision) -> {type, title, stake, advisor, recommended: {index, why} | {}, options: [{index,
  id, label, consequence: [<= 2 lines], recommended, historical, historical_hidden, available}], more: [indices],
  n_options, details_ref: {type, id}}`.
  - At most 3 options: Recommended first, then the two that differ most from it (war fronts: the next most
    threatened front and standing down; the budget: Balanced and last year's preset; a coalition: history's partner
    and one that stayed out). History's option is never hidden: it takes the third place if needed.
  - `historical` (show the tag) is true only when hints are on. `historical_hidden` marks history's option on
    Historian (no tag until after the pick, as in v3).
  - `consequence` lines read "Now: +3 Readiness." and "For years: -1 Cohesion (label) (1948-1965)."; war fronts read
    "Strikes on towns expected 2.0; enemy formations hit 3.0." plus the cost line.
  - `more`: the other option indices, for the "More options (N)" link (`options[i]` of the decision itself).
  - Extra keys where they apply: `surplus` (the story_view of the merged surplus), `treasury` (the story_view of the
    Treasury item on a structural agenda card), `brief_line` on a coalition card ("The new government keeps the
    ministers' brief: Society").

### SimAI (no behaviour change for the v3 play_turn)
- `_trade_and_diplomacy` = `trade_routes(sim)`, then (not history) `deal_turn(sim)` and `delegations(sim)`, in the
  same order as before.
- `_fiscal_levers` = `fiscal_levers_danger(sim)` when `fiscal_danger(sim)`, else `fiscal_levers_healthy(sim)`: the
  same code.
- `resolve_one` also answers the casual layer's `treasury` and `brief` items.

### Era goals hooks (v4-goals)
- `sim.goals` (`SimGoals`): `goals.start_turn()` runs in `_start_turn` after `diplo.start_turn()`, before the score
  sample; `goals.process_turn()` runs in `end_turn` after `turn_ended`, before the collapse check. Both are guarded
  with `if goals != null`.

## v4 fix round (v4fix-sim, 2026-10-16)

### Era goals follow the play style (V4_FIXES B5)
- `Sim.new_game({..., "goals": true | false})`. Absent (or `"auto"`): ON in story mode, OFF in Full control, so a Full
  control game (and every autoplayer of `sim_test`, the ghost included) is v3 exactly. Saved as `state.counters.goals_on`;
  a save from before the setting keeps goals on if it already judged one.
- `sim.goals.enabled() -> bool` is now per game (an instance method). `sim.goals.set_enabled(on)`: the Settings switch,
  live on any turn (rewards already earned stay; nothing is judged while off). `ProjectSettings civ/era_goals = false` and
  `--no-goals` still switch every game off (`SimGoals.globally_enabled()`).
- `goals.view()` goals carry `milestone: true` for the seven steps every strategy met on history's own path (their titles
  read "Milestone: ..."). An `any` goal's `progress_label` shows the condition that met it (or the closest one).
- Data changes (`data/era_goals.json`, `progress/v4fix_sim/goals_fix.py`): g01 "Win the war and build the army" (Readiness
  58), g06 Readiness 63, g10 and g14 also need Standing at least 95% of history's, plainer trust labels.

### The story card (V4_FIXES B1-B3)
- `story_view(d).options[i]`: `available` is checked live (`launch()`'s own test for programmes: the live first
  instalment against the treasury), `reason` = why not, capitalised and plain ("Needs 153 gold now for the first instalment
  (the treasury has 147)"; "" when available), `shown` = {stat: value} of the figures its two lines show (higher is
  better). `story_view(d).more_reasons = {index: reason}` for the hidden options that cannot be taken.
- `recommend(d)` / `story_view(d).recommended = {index, why, why_stat, why_kind}`. The pick is never an option that
  cannot be taken now (a programme falls back to "Not now" / "Hold"). `why_kind`: `best` (the pick leads every other
  option shown on `why_stat`; e.g. "best for Readiness", "the fewest towns hit of the options shown"), `tradeoff` ("it
  costs Cohesion now, but adds Standing for years"), `cheapest`, or `judgement` (the picker weighs more than two lines
  show, said in words: "the largest gain overall when every lasting term is added up (all of them are under Details)").
  A war's first card recommending mobilisation says "it costs unity now, but every front fights stronger for the whole war".
- `sim.auto.why_refused(d, index) -> String` ("" when the option can be taken) and `sim.auto.refusal_text(d, index) ->
  String` (never empty): the feedback for a click the sim refused.
- Consequence lines are plain: war fronts "About 5 towns hit; about 3 enemy formations hit." (whole numbers), mobilisation
  "For the whole war: reserve brigades at every front and +2 strength for every unit." + "Now: -28 Cohesion. This quarter:
  about 6 towns hit.", immigration plans that leave 500+ people in camps "Now: -13 gold; about 38,000 people left in transit
  camps (ma'abarot)." + "For years: crowded camps mean fewer amenities, so Civic Trust and growth fall in those towns until
  homes are built." No "-0 gold" and no "Now: ... now.".

### The ministers' report (B4)
- The production ministry's `short` is "Construction" (was "Housing"); a unit begun in a city is prefixed "Defence". Each line
  has `short` (the prefix used). A count of 1 uses the singular template `<key>.one` (in `SimAuto.TEMPLATES`); counted lines
  (`SimAuto.MERGE_KEYS`) are merged into one per ministry and quarter. Research and civics read "next research: X." /
  "next civic: X.". New key: `auto.budget.hold_last` ("kept the surplus: no programme could be finished before the end.").

### Decision load (B6)
- The Treasury in danger and the brief wait for a quieter quarter when the quarter already holds 3 player decisions; the
  State Budget card's surplus half is held when the quarter holds the budget and 3 others. An item that waited is asked
  next quarter (it is not "declined").
- At most TWO surplus prompts a calendar year beyond the budget card's own (`SimAuto.SURPLUS_QUOTA`, was one): Finance holds
  the later ones (`counters.auto.held` counts every surplus Finance held). Finance never invests on its own: programmes stay
  the player's, so history's story player holds as v3 does.
- While Finance is on auto, no programme decision whose launches could not finish by Q3 2023 is shown (Finance answers "not
  now" / holds the surplus: `auto.budget.hold_last`).
- `sim_test --casual` counts the budget card's surplus half and the agenda card's Treasury half as decisions of their own,
  plays a seventh run (the careless populist of the veteran critic, "Not now" on every Treasury card) and checks M1-M3 and
  the report wording on every card.
