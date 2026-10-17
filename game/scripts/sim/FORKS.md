# Fork and war data format

There are two data-driven decision systems:
- **forks**: one-time historical policy decisions;
- **wars**: front-by-front war decisions.

Data agents write the files, the sim loads every file in the folders, and the strict validator rejects anything malformed. Errors appear in `sim_test.gd` output under "Data" and on Godot's console. Run `tools/godot.sh --headless --path /c/civ/game --script res://scripts/sim/sim_test.gd -- --validate-only` to check your files in seconds.

```
game/data/forks/<from>-<to>.json   e.g. forks/1966-1985.json   {"range": "1966-1985", "forks": [ ...fork... ]}
game/data/wars/<id>.json           e.g. wars/war_1973.json     { ...war... }
```

One file per date range for forks, and one file per war. Ids must be unique across all files. Every file must be UTF-8 JSON.

---

## 1. Fork (one-time decision)

| Field | Req | Meaning |
|---|---|---|
| `id` | yes | `fork_<year>_<slug>`, unique. |
| `title` | yes | Short title, player-facing, neutral. |
| `text` | yes | 1–3 sentences of context, player-facing, neutral. Say what is fixed by history ("the arrivals follow history either way") and what is the player's call. |
| `date` | yes | `"YYYY-MM"`: first quarter the fork can be offered. |
| `until` | no | `"YYYY-MM"`: last quarter it can still be offered if its conditions are not yet met (default: same year as `date`, +4 quarters). If the window closes unmet, the fork is skipped silently. |
| `requires` | no | Conditions, all must hold (see below). |
| `source` | yes | Fork-level S-ids (≥1). Must exist in `sources/sources.json` or `sources/sim_sources.json`. |
| `options` | yes | 2–3 options. **Exactly one** has `"historical": true`. |

**`requires`** (all optional):
- `event`: event id that must have fired (from `events.json`; never a deleted id).
- `choice`: `{"<event_or_fork_id>": "<option_id or index>"}`. Offer this fork only if that earlier choice was made. Use this for follow-ups.
- `not_choice`: the same structure; skip the fork if that choice was made.
- `flag` / `not_flag`: a flag set by an earlier option's `flags`.
- `tech` / `civic`: must already be researched or adopted.

**Option**

| Field | Req | Meaning |
|---|---|---|
| `id` | yes | Slug, unique inside the fork. |
| `label` | yes | What the cabinet does, as an imperative ("Abolish military government now"). |
| `historical` | yes | `true` on exactly one option: what the government actually did. |
| `advocate` | yes | Who argued for it at the time (person, party or body). **Required and non-empty on every non-historical option** (CONTRACT), and backed by a cite with a verbatim `quote` that shows the advocacy. The validator fails otherwise. Never invent one. If nobody argued for an option, drop the option. |
| `cite` | yes | ≥1 of `{"source": "S…", "quote": "…", "url": "…"}`. `quote` and `url` are **required** when the source is `not_opened` (or a sim source without a quote). The quote must be verbatim from the opened page. |
| `note` | hist. | On the historical option: one line on what actually happened (shown after the pick as "What actually happened"). |
| `now` | no | Immediate effects (keys below). |
| `lasting` | yes | ≥1 lasting term (stream, below). This is what makes the choice stick to the end of the game (Q3 2023; no term date after 2023-09). |
| `flags` | no | Strings that later forks can require. |

**`now` keys**, all numbers:

| Key | Effect | Scaling |
|---|---|---|
| `gold` | Treasury | Scaled by era. |
| `standing` | Standing points | Player-driven, so it doesn't decay. |
| `trust` | Every city's trust, in points | |
| `readiness` | Readiness | |
| `cohesion` | Cohesion | |
| `inflation` | Percentage points | |
| `production` | Production toward the capital's current build | |
| `science` | Science | |
| `culture` | Culture | |

**Lasting term (stream):** `{"type", "amount", "from": "YYYY-MM", "until": "YYYY-MM", "label", "group"?, "target"?}`. Every lasting term writes a reasoned entry to *Why stats moved* (`get_stat_log`) under its `label`. Write labels as cause phrases: "Refused German reparations".

| type | amount means | track it moves |
|---|---|---|
| `gold` | gold per turn (scaled by era) | economy |
| `standing` | standing per turn | standing |
| `standing_target` | lasting offset of where standing settles (no mean-reversion) | standing |
| `trust` | trust per turn in every city | cohesion |
| `trust_base` | lasting offset of the trust baseline; `group`: `all` (default), `dev_towns`, `arab`, `periphery`, `large_cities` | cohesion |
| `readiness` | flat readiness while active | (crisis costs) |
| `output_pct` | % production and gold | economy |
| `science_pct` | % science | science |
| `growth_pct` | % natural population growth | population |
| `water` | million m³ per year of supply | water |
| `inflation` | lasting percentage points added to inflation | economy, cohesion |
| `cohesion` | cohesion per turn | cohesion |
| `amenity` | amenities in every city (or `group`) | cohesion, population |
| `retention` | % immigrant retention | population |
| `immigrant_weight` | % share of arrivals; `target`: `small_towns` or `large_cities` | population distribution |

Typical sizes: `standing_target` 1–5, `trust_base` 1–6, `readiness` 2–6, `output_pct` 1–5, `science_pct` 2–8, `growth_pct` 0.5–3, `water` 10–60, `inflation` 1–4, `gold` 2–10.

**Balance rule (the validator warns; the critic enforces):** no option may be better than another on every track. Give each option at least one cost and one benefit.

### Worked example: fork

```json
{
 "id": "fork_1959_wadi_salib",
 "date": "1959-09",
 "until": "1960-06",
 "requires": {"event": "evt_1959_wadi_salib"},
 "title": "After Wadi Salib",
 "text": "The Wadi Salib protests in Haifa spread to other towns and put discrimination against immigrants from North Africa on the national agenda. How should the government respond?",
 "source": ["S142"],
 "options": [
  {"id": "order_and_inquiry", "label": "Restore order and look into the complaints", "historical": true, "advocate": "Ben-Gurion's government",
   "cite": [{"source": "S142"}],
   "note": "The protests brought the question of discrimination into national politics.",
   "now": {},
   "lasting": [{"type": "trust_base", "amount": -2, "from": "1959-09", "until": "1977-12", "label": "Grievances left to fester", "group": "dev_towns"}]},
  {"id": "big_programme", "label": "A large programme for immigrant neighbourhoods and development towns", "historical": false, "advocate": "Union of North African Immigrants",
   "cite": [{"source": "S142"}],
   "now": {"gold": -30},
   "lasting": [{"type": "gold", "amount": -8, "from": "1959-09", "until": "1966-12", "label": "Housing, schools and jobs programme"},
               {"type": "trust_base", "amount": 5, "from": "1959-09", "until": "1985-12", "label": "Immigrant towns invested in", "group": "dev_towns"},
               {"type": "growth_pct", "amount": 1, "from": "1960-01", "until": "1975-12", "label": "Better schools and housing"}]},
  {"id": "policing", "label": "Firm policing; no new spending", "historical": false, "advocate": "",
   "cite": [{"source": "S142"}],
   "now": {"gold": 20},
   "lasting": [{"type": "trust_base", "amount": -5, "from": "1959-09", "until": "1985-12", "label": "Protests met only with police", "group": "dev_towns"},
               {"type": "cohesion", "amount": -1, "from": "1959-09", "until": "1966-12", "label": "Bitterness between communities"}],
   "flags": ["wadi_salib_policed"]}
 ]
}
```

---

## 2. War (front decisions)

A war attaches to a dated event in `events.json` whose `kind` is `war` or `military_operation`. When that event fires, the crisis starts:
1. First, a **crisis response** decision (mobilise, civil defence, backing, standing forces, or your own `response_options`).
2. Then, every turn of the war, a **front decision** generated from `fronts`: commit reserves to one named front, mount a full operation on all fronts, or hold.

The outcome of the war is fixed by history. Fronts decide losses, damage to towns, casualties among troops (via war weariness), trust, gold, and the lasting **lessons learned** (readiness, ±1 to ±6, never silently 0).

| Field | Req | Meaning |
|---|---|---|
| `id` | yes | `war_<year>_<slug>`, unique; the file name must equal the id. |
| `event` | yes | id of the triggering event in `events.json` (`kind` war or military_operation). |
| `title` | yes | Player-facing title. |
| `offensive` | no | `true` if Israel opens the campaign (Suez 1956, Lebanon 1982). This changes the response menu: there is no "civil defence for cities"; instead a strike pre-emptively with air superiority, or limited aims. |
| `turns` | no | Number of front turns (default: from the event's `date_end`, minimum 1). |
| `source` | yes | S-ids for the fronts and their facts. |
| `fronts` | yes | 1–5 fronts (below). |
| `response_options` | no | Replace the default crisis-response menu (same option shape as forks, plus `cost`). |
| `lessons` | no | `{"base": n}` adds to the computed lesson; use it for documented post-war reforms (the Agranat commission, for example). |

**Front**

| Field | Req | Meaning |
|---|---|---|
| `id` | yes | Slug. |
| `name` | yes | "Negev", "Jerusalem corridor", "Golan Heights"… |
| `actor` | yes | Diplomacy actor id from `actors.json` (egypt, jordan, syria, lebanon, iraq, plo, hezbollah, hamas, iran…). |
| `region` | yes | List of map `region` names where the enemy formations spawn, outside the lines of control (Negev, Sinai, Gaza Strip, Samaria, Judea, Golan, Syria, Lebanon, Galilee, Jordan, Jordan Valley…). |
| `anchor` | yes | City id (cities.json) or `[q, r]`. This is the town the front threatens or the axis's starting point. |
| `formations` | yes | Hostile formations at the start, 1–6. A front with 0 formations is never offered. |
| `spawn_inside` | no | `true` lets the front's formations spawn inside Israeli-held territory (a front-line belt within 14 tiles of the anchor, in the listed regions). Use it for fronts on land Israel holds, e.g. the Suez Canal and Bar-Lev line 1967–82, when Sinai is inside the lines of control. Default `false`: formations spawn outside the lines. `sim_test` lists any front that never spawned in the full autoplay. |
| `unit_types` | no | Default `["hostile_infantry", "hostile_armor"]`. Allowed: `hostile_infantry`, `hostile_armor`, `hostile_artillery`, `hostile_rockets`. Use `["missile_salvo"]` for a remote actor; no map formations are spawned for it. |
| `from` / `until` | no | `"YYYY-MM"` window in which the front is active. Leave it open for the whole war if unknown. |
| `commit_label` | no | The label for committing to this front ("Open the road to Jerusalem"). |
| `cite` | yes | ≥1 cite (same shape as a fork option). |

The **costs depend on readiness and choices** (computed by the engine, no data needed):
- **A war ends at its `turns`** (counted from the event's quarter) whatever the diplomatic statuses say. A later war event with its own file ends an older crisis with the same actor and starts its own; incidents without a war file merge into the running crisis.
- **Lessons learned** (lasting Readiness, −5 to +5) depend on the share of enemy formations destroyed, interceptions, losses, strikes on towns, front commitments, the opening response (mobilise/air first +1, civil defence +0.5, backing −0.5, limited aims −0.5, standing forces −1) and Readiness going in. Good preparation and active fronts give positive lessons.
- **Committing to a front** costs −15% production this turn. It hits that front's formations with strength 45 + 0.4 × Readiness.
- **A full operation** costs gold (35 × era scale) and −30% production. It hits every front with strength 30 + 0.3 × Readiness.
- **Holding** costs nothing. Enemies then strike the most exposed front town, and trust and weariness costs are scaled by `1.4 − Readiness/100`.
- Choices made earlier, such as fork lasting `readiness`, policies and units, all feed Readiness.

### Worked example: war

```json
{
 "id": "war_1948_independence",
 "event": "evt_1948_arab_invasion",
 "title": "The 1948 war",
 "turns": 4,
 "source": ["S102", "S103", "S1242", "S1244"],
 "fronts": [
  {"id": "negev", "name": "Negev", "actor": "egypt", "region": ["Negev", "Gaza Strip", "Sinai"], "anchor": "negba", "formations": 3,
   "unit_types": ["hostile_infantry", "hostile_armor", "hostile_artillery"], "commit_label": "Reinforce the Negev settlements against the Egyptian army",
   "cite": [{"source": "S1242"}]},
  {"id": "jerusalem", "name": "Jerusalem corridor", "actor": "jordan", "region": ["Judea", "Samaria"], "anchor": "jerusalem", "formations": 3,
   "commit_label": "Open the road to Jerusalem", "cite": [{"source": "S102"}]},
  {"id": "galilee", "name": "Galilee", "actor": "syria", "region": ["Syria", "Golan", "Lebanon"], "anchor": "safed", "formations": 2,
   "until": "1948-11", "commit_label": "Hold the Galilee", "cite": [{"source": "S1244"}]},
  {"id": "jordan_valley", "name": "Jordan Valley", "actor": "syria", "region": ["Golan", "Syria", "Jordan"], "anchor": "degania_alef", "formations": 2,
   "until": "1948-07", "commit_label": "Defend the Jordan Valley kibbutzim", "cite": [{"source": "S103"}]}
 ]
}
```

### War fields added in v2 (sim-v2)

| Field | Req | Meaning |
|---|---|---|
| `kind` | no | `war` (default); `uprising` (a popular uprising, e.g. the Intifadas; front texts speak of centres of the uprising); or `deterrence` (Israel deploys but does not fight, e.g. Black September 1970). Formations of a `deterrence` war never act, and committing to a front is a deployment, not a counter-attack. |
| `phases` | no | 2-4 `{name, cite?}` entries: the stages of the fighting in the war's **opening quarter**. Each phase is its own front decision, in order (1967: Sinai, then Jerusalem and the West Bank, then the Golan). Phase names are shown to the player ("The Six-Day War (1967), phase 2 of 3: ..."), so they must be sourced facts. |
| front `phase` | no | The opening-quarter phase in which this front is offered (1-N). `0` or missing means every phase. In later quarters every live front is offered. |

Timing rules (v2):
- A war's named fronts open in the quarter its event fires, before the outcome rails of that quarter.
- A war that lasts more than one quarter asks for its front orders before the quarter's other events fire.
- Make `turns` match the fighting: Sinai 1956, Six-Day War 1967 and Yom Kippur 1973 are one quarter each (with phases).
- Event kinds a war can attach to: `war`, `military_operation`, `security` (for uprisings).

---

## 3. Rules for data agents
- **Neutral and sourced.** Describe debates, not verdicts. Every option needs an advocate and a cite; never invent an advocate or a quote.
- **No deleted content.** Ids in `tools/history/data/deleted_event_ids.json` (7 Oct 2023 and the Gaza war from 2023) must never be referenced, and their topics must not be recreated.
- **No dominated options.** Every option has a cost and a benefit on different tracks.
- **Lasting effects.** Each option has ≥1 `lasting` term, and the terms should differ between options on at least two tracks.
- **Density.** Write 6–8 forks per decade, spread across the years, and wars for the operations of your range.
- **Check before you hand off.** Run `sim_test.gd -- --validate-only` and fix every error it reports.

### War fields added in the v2 fix round (fix-wars-events)

| Field | Meaning |
|---|---|
| `kind: "operation"` | A one-off operation abroad: no fronts needed; `response_options` (2-5) are the named ways to carry it out: `{id, label, desc, historical?, default?, gold, lesson, standing_mult?, morale_mult?, readiness?, cite}`. |
| `variants` | `[{if_choice: {<fork>: <option> | [..]}, drop_fronts?, turns?, phases?, title?, kind?, offensive?, formations?: {front: n}, roles?: {front: role}, opening?: "air_first", no_mobilize?, strikes?, end_now?, note?}]`: the war follows the cabinet's answer. |
| `continues` | `{from, until, every, cite?}`: after `turns`, orders come every `every` quarters until `until` (low-intensity stage: less strain, no attacks between). |
| `alongside` | War ids this war does not end (they keep running in parallel). |
| `war_actors` | Actors also at war during the opening quarter without a front (Jordan 1973). |
| front `ground` | Battlefield character (`SimMilitary.GROUND`): `open_desert`, `coastal_plain`, `fortified`, `mountain`, `valley_crossing`, `border_villages`, `urban`, `camp`, `tunnels`, `long_range`, `dispersed`. |
| front `civilians` | Sourced line naming the residents in the combat area (shown in the order and preview). |
| front `role` / `area` | Remote missile fronts: `defend` (default) a named `area`, or in offensive wars `strike_launchers` / `strike_target`. |

Events may carry `consequences` and `defer_to_fork` (API.md, "v2 fixes (fix-wars-events)"). `sim_test` checks that no same-subject event fires unchanged after a non-historical fork pick: list the event in the fork's `history_course`, give it a `consequences` entry, or a war `variants` entry.
