# Israel: The Birth of a Nation - simulation autoplay report

Run: 2026-10-16T14:53:10, seed 1948, Godot 4.7.1-stable (official)

## Data
techs 47, civics 43, policies 47, districts 15, buildings 53, national projects 10, units 23
cities.json 119 places, events.json 319 events, map 7904 tiles, 16 border eras, SOURCES ids 2011
forks 223 (in game/data/forks/), wars 23 (in game/data/wars/)
fork consequence check: 46 same-subject fork/event pairs; 0 uncovered non-historical answers
generic history-course fallbacks: 0 (fork answer -> event pairs with no specific outcome; at most 5 allowed)
leak scan (nothing dated after Q3 2023 visible): 0 hits; cities 0, trees 0, programmes 0, events 0, wars 0, cabinet and series 0, forks 0, choice terms 0, diplomacy 0, deal end dates 0
deleted-content scan (nothing after Q3 2023 in the data; 64 tombstoned ids): 0 hits; content and helpers 0, load-time scrub 0, data files 0, Hebrew catalogs 0

API smoke test: 24 queries and the main actions OK (Q2 1949)

## Era goals calibration (V4, to Q3 2023)
goals by play style: Full control (default): off; story mode: on; Full control with goals on: on; story mode with goals off: off
running ghost ...
  ghost: Q3 2023, met 17 of 24 judged
running historical ...
  historical: Q3 2023, met 19 of 24 judged
running varied ...
  varied: Q3 2023, met 13 of 24 judged
running recommended ...
  recommended: Q3 2023, met 18 of 24 judged
running strategist_security ...
  strategist_security: Q3 2023, met 24 of 24 judged
running strategist_prosperity ...
  strategist_prosperity: Q3 2023, met 17 of 24 judged
running strategist_peace ...
  strategist_peace: Q3 2023, met 21 of 24 judged
running strategist_society ...
  strategist_society: Q3 2023, met 18 of 24 judged
running ruin_builder ...
  ruin_builder: Q3 2023, met 11 of 24 judged
running ruin_populist ...
  ruin_populist: Q3 2004, met 7 of 16 judged COLLAPSE collapse_fiscal
running switch_off ...
  switch_off: Q2 1988, met 0 of 0 judged

| Goal | ghost | historical | varied | recommended | strategist_security | strategist_prosperity | strategist_peace | strategist_society | ruin_builder | ruin_populist |
|---|---|---|---|---|---|---|---|---|---|---|
| g01_war_of_independence | met | met | - | met | met | - | met | met | - | - |
| g02_mass_immigration | - | met | met | met | met | met | met | met | met | met |
| g03_development_towns | met | met | met | met | met | met | met | met | met | met |
| g04_water_carrier | met | met | met | met | met | met | met | met | met | met |
| g05_growth_years | met | met | - | met | met | met | met | - | met | - |
| g06_ready_1967 | met | met | - | - | met | - | - | - | - | - |
| g07_attrition | met | met | - | - | met | met | met | - | - | - |
| g08_october_1973 (history missed) | - | met | - | - | met | - | - | - | - | - |
| g09_aliyah_1970s | - | - | - | met | met | - | met | met | met | met |
| g10_peace_egypt | met | met | met | met | met | met | met | met | met | met |
| g11_hyperinflation (history missed) | - | - | - | met | met | met | met | - | - | - |
| g12_lebanon | met | met | - | met | met | met | met | met | met | - |
| g13_million | - | - | - | - | met | - | met | met | met | - |
| g14_peace_jordan | met | met | met | met | met | met | met | met | met | met |
| g15_yozma | met | met | met | met | met | met | met | met | - | - |
| g16_rd | - | - | met | met | met | met | met | - | - | ... |
| g17_intifada | met | met | - | - | met | - | - | met | - | ... |
| g18_ashkelon | met | met | met | met | met | met | met | met | met | met |
| g19_iron_dome | met | met | met | met | met | met | met | met | - | ... |
| g20_tamar | met | met | met | - | met | met | met | met | - | ... |
| g21_sorek | met | met | met | met | met | met | met | met | - | ... |
| g22_gulf | met | met | - | met | met | met | met | met | met | ... |
| g23_vaccinate | - | - | met | met | met | - | met | met | - | ... |
| g24_arab_plans | met | met | met | met | met | met | met | met | - | ... |

| Run | goals met | judged | share | overall | ended | ending |
|---|---|---|---|---|---|---|
| ghost | 17 | 24 | 71% | 100.7 | Q3 2023 | - |
| historical | 19 | 24 | 79% | 104.2 | Q3 2023 | - |
| varied | 13 | 24 | 54% | 130.2 | Q3 2023 | - |
| recommended | 18 | 24 | 75% | 153.5 | Q3 2023 | - |
| strategist_security | 24 | 24 | 100% | 153.6 | Q3 2023 | - |
| strategist_prosperity | 17 | 24 | 71% | 144.5 | Q3 2023 | - |
| strategist_peace | 21 | 24 | 88% | 145.3 | Q3 2023 | - |
| strategist_society | 18 | 24 | 75% | 129.9 | Q3 2023 | - |
| ruin_builder | 11 | 24 | 46% | 100.4 | Q3 2023 | - |
| ruin_populist | 7 | 16 | 29% | 47.9 | Q3 2004 | COLLAPSE collapse_fiscal |

Progress at judgement (ghost / historical / recommended):
- g01_war_of_independence: ghost met (Readiness 66 / 58); historical met (Readiness 68 / 58); recommended met (Readiness 61 / 58)
- g02_mass_immigration: ghost missed (Lowest Civic Trust of any group of towns 62 / 65); historical met (Lowest Civic Trust of any group of towns 67 / 65); recommended met (Lowest Civic Trust of any group of towns 70 / 65)
- g03_development_towns: ghost met (Localities 83 / 83); historical met (Localities 83 / 83); recommended met (Localities 83 / 83)
- g04_water_carrier: ghost met (National Water Carrier level 1 / level 1); historical met (National Water Carrier level 1 / level 1); recommended met (National Water Carrier level 1 / level 1)
- g05_growth_years: ghost met (Economy, against history 1.05 / 1.03); historical met (Economy, against history 1.21 / 1.03); recommended met (Economy, against history 1.07 / 1.03)
- g06_ready_1967: ghost met (Readiness 64 / 63); historical met (Readiness 70 / 63); recommended missed (Readiness 43 / 63)
- g07_attrition: ghost met (Strikes on towns, against history's 1.00 / max 1.10); historical met (Strikes on towns, against history's 1.00 / max 1.10); recommended missed (Strikes on towns, against history's 1.17 / max 1.10)
- g08_october_1973: ghost missed (Readiness 83 / 88); historical met (Readiness 88 / 88); recommended missed (Readiness 68 / 88)
- g09_aliyah_1970s: ghost missed (Civic Trust 89 / 92); historical missed (Civic Trust 91 / 92); recommended met (Civic Trust 97 / 92)
- g10_peace_egypt: ghost met (Standing, against history 1.18 / 0.95); historical met (Standing, against history 1.33 / 0.95); recommended met (Standing, against history 2.42 / 0.95)
- g11_hyperinflation: ghost missed (Inflation 18% / max 10%); historical missed (Inflation 14% / max 10%); recommended met (Inflation 7% / max 10%)
- g12_lebanon: ghost met (Strikes on towns, against history's 1.00 / max 1.10); historical met (Strikes on towns, against history's 0.93 / max 1.10); recommended met (Strikes on towns, against history's 1.03 / max 1.10)
- g13_million: ghost missed (Lowest Civic Trust of any group of towns 79 / 82); historical missed (Lowest Civic Trust of any group of towns 82 / 82); recommended missed (Lowest Civic Trust of any group of towns 90 / 82)
- g14_peace_jordan: ghost met (Standing, against history 1.10 / 0.95); historical met (Standing, against history 1.23 / 0.95); recommended met (Standing, against history 2.22 / 0.95)
- g15_yozma: ghost met (The start-up economy level 3 / level 3); historical met (The start-up economy level 3 / level 3); recommended met (The start-up economy level 3 / level 3)
- g16_rd: ghost missed (Science, against history 1.00 / 1.25); historical missed (Science, against history 1.19 / 1.25); recommended met (Science, against history 1.69 / 1.25)
- g17_intifada: ghost met (Strikes on towns, against history's 1.03 / max 1.10); historical met (Strikes on towns, against history's 0.87 / max 1.10); recommended missed (Strikes on towns, against history's 1.17 / max 1.10)
- g18_ashkelon: ghost met (Water independence: desalination level 1 / level 1); historical met (Water independence: desalination level 1 / level 1); recommended met (Water independence: desalination level 1 / level 1)
- g19_iron_dome: ghost met (The missile shield level 2 / level 2); historical met (The missile shield level 2 / level 2); recommended met (The missile shield level 2 / level 2)
- g20_tamar: ghost met (The gas fields level 1 / level 1); historical met (The gas fields level 1 / level 1); recommended missed (The gas fields level 0 / level 1)
- g21_sorek: ghost met (Water independence: desalination level 2 / level 2); historical met (Water independence: desalination level 2 / level 2); recommended met (Water independence: desalination level 2 / level 2)
- g22_gulf: ghost met (Relations with the UAE: yes); historical met (Relations with the UAE: yes); recommended met (Relations with the UAE: yes)
- g23_vaccinate: ghost missed (Cohesion, against history 0.96 / 1.40); historical missed (Cohesion, against history 0.96 / 1.40); recommended met (Cohesion, against history 2.53 / 1.40)
- g24_arab_plans: ghost met (Development plans for Arab localities level 2 / level 2); historical met (Development plans for Arab localities level 2 / level 2); recommended met (Development plans for Arab localities level 2 / level 2)

History 71% / 79%, best good play strategist_security 100%, ruinous drivers average 38%
save/load at turn 120: ok (10 statuses kept)
End summary (Recommended): met 18, missed 6 of 24 judged; like history 17, ahead of history 1, behind history 5
civ/era_goals=false: no goal notification, stream, bonus, discount, view or summary (the v3 numbers)

## Result
elapsed 3299.1 s, failures 0
ALL INVARIANTS PASSED
