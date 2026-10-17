# Israel: The Birth of a Nation - simulation autoplay report

Run: 2026-10-17T03:39:04, seed 1948, Godot 4.7.1-stable (official)

## Data
techs 47, civics 43, policies 47, districts 15, buildings 53, national projects 10, units 23
cities.json 119 places, events.json 319 events, map 7904 tiles, 16 border eras, SOURCES ids 2011
forks 223 (in game/data/forks/), wars 23 (in game/data/wars/)
fork consequence check: 46 same-subject fork/event pairs; 0 uncovered non-historical answers
generic history-course fallbacks: 0 (fork answer -> event pairs with no specific outcome; at most 5 allowed)
leak scan (nothing dated after Q3 2023 visible): 0 hits; cities 0, trees 0, programmes 0, events 0, wars 0, cabinet and series 0, forks 0, choice terms 0, diplomacy 0, deal end dates 0
deleted-content scan (nothing after Q3 2023 in the data; 64 tombstoned ids): 0 hits; content and helpers 0, load-time scrub 0, data files 0, Hebrew catalogs 0

API smoke test: 24 queries and the main actions OK (Q2 1949)

## Ghost of history (Historical Israel autoplayer)

| Date | Pop (sim) | Pop (CBS, S119) | diff | Ghost pop | Cities | Techs | Civics | Events | Gold (net) | Water S/D | Standing | Trust | Readiness | Inflation (real) | City fit | Ahead | Errors |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Q2 1948 | 0.81M | 0.81M | +0% | 0.81M | 42 | 0 | 1 | 5 | 70 (+0) | 0/0 | 47 | 83 | 40 | 4% (6%) | 0% | 0/6 | 0 |
| Q2 1953 | 1.70M | 1.67M | +2% | 1.70M | 75 | 8 | 10 | 48 | 195 (+11) | 768/876 | 42 | 66 | 71 | 6% (6%) | 11% | 0/6 | 0 |
| Q2 1958 | 2.03M | 2.03M | -0% | 2.03M | 84 | 13 | 15 | 63 | 380 (+9) | 1025/932 | 36 | 74 | 79 | 6% (6%) | 7% | 0/6 | 0 |
| Q2 1963 | 2.39M | 2.43M | -2% | 2.39M | 85 | 15 | 17 | 72 | 610 (-2) | 1450/1425 | 45 | 83 | 78 | 8% (7%) | 9% | 0/6 | 0 |
scenario start 1967 written (data/scenarios/start_1967.json, Q3 1967)
| Q2 1968 | 2.90M | 2.84M | +2% | 2.90M | 90 | 19 | 19 | 93 | 751 (+76) | 1926/1402 | 50 | 84 | 70 | 2% (2%) | 8% | 0/6 | 0 |
| Q2 1973 | 3.40M | 3.34M | +2% | 3.40M | 93 | 23 | 20 | 108 | 963 (+29) | 1999/1739 | 44 | 87 | 88 | 17% (19%) | 13% | 0/6 | 0 |
scenario start 1977 written (data/scenarios/start_1977.json, Q3 1977)
| Q2 1978 | 3.84M | 3.74M | +3% | 3.84M | 96 | 26 | 22 | 133 | 808 (-19) | 2043/1978 | 50 | 88 | 81 | 45% (49%) | 12% | 0/6 | 0 |
| Q2 1983 | 4.21M | 4.12M | +2% | 4.21M | 98 | 29 | 23 | 156 | 939 (-33) | 2298/2053 | 46 | 71 | 95 | 136% (143%) | 11% | 0/6 | 0 |
| Q2 1988 | 4.55M | 4.48M | +2% | 4.55M | 99 | 30 | 26 | 176 | 1028 (+147) | 2206/2194 | 41 | 64 | 91 | 17% (17%) | 8% | 0/6 | 0 |
scenario start 1992 written (data/scenarios/start_1992.json, Q3 1992)
| Q2 1993 | 5.39M | 5.33M | +1% | 5.39M | 100 | 31 | 28 | 190 | 899 (-44) | 2171/2220 | 53 | 78 | 84 | 11% (11%) | 14% | 0/6 | 0 |
| Q2 1998 | 6.17M | 6.04M | +2% | 6.17M | 102 | 34 | 32 | 207 | 1573 (+334) | 2230/2338 | 72 | 83 | 75 | 7% (6%) | 15% | 0/6 | 0 |
| Q2 2003 | 6.86M | 6.60M | +4% | 6.86M | 103 | 37 | 33 | 230 | 623 (+123) | 2587/2327 | 76 | 74 | 92 | 3% (1%) | 15% | 0/6 | 0 |
| Q2 2008 | 7.53M | 7.34M | +3% | 7.53M | 102 | 39 | 35 | 252 | 2051 (+796) | 2730/2577 | 76 | 83 | 95 | 3% (4%) | 12% | 0/6 | 0 |
| Q2 2013 | 8.16M | 8.08M | +1% | 8.16M | 102 | 42 | 39 | 269 | 1385 (+681) | 3137/2591 | 72 | 85 | 90 | 2% (2%) | 13% | 0/6 | 0 |
| Q2 2018 | 8.86M | 8.97M | -1% | 8.86M | 102 | 43 | 41 | 284 | 1941 (+1027) | 3438/2631 | 67 | 89 | 90 | 1% (1%) | 13% | 0/6 | 0 |
| Q2 2023 | 9.65M | 9.79M | -1% | 9.65M | 102 | 44 | 43 | 317 | 2482 (+1391) | 3456/2680 | 76 | 89 | 91 | 4% (4%) | 14% | 0/6 | 0 |
| Q3 2023 | 9.72M | 9.79M | -1% | 9.69M | 102 | 44 | 43 | 319 | 2760 (+1477) | 3456/2704 | 76 | 91 | 91 | 4% (4%) | 14% | 1/6 | 0 |

### Ghost of history vs the census (CBS, real_series.json)
| Year | Ghost population | CBS | Difference | Within 4% |
|---|---|---|---|---|
| 1961 | 2.201M | 2.234M | -1.5% | yes |
| 1972 | 3.288M | 3.226M | +1.9% | yes |
| 1983 | 4.210M | 4.119M | +2.2% | yes |
| 1995 | 5.692M | 5.619M | +1.3% | yes |
| 2000 | 6.478M | 6.290M | +3.0% | yes |
| 2004 | 6.986M | 6.781M | +3.0% | yes |
| 2008 | 7.525M | 7.338M | +2.5% | yes |
| 2015 | 8.431M | 8.462M | -0.4% | yes |
| 2022 | 9.477M | 9.657M | -1.9% | yes |
ghost treasury: longest run below zero 6 turns (to Q2 1985) (V2: at most 8)

### Debt report (ghost of history)
- borrowed 2463 gold in 7 loans; interest paid 1275; repaid early 0.00; peak debt 1259; debt at the end 148.89 (lenders' limit 31521)
- net gold negative in 73 of 302 turns; treasury below zero in 16 turns (longest run 6); final treasury 2760
- peak inflation 365% in 1984 (history that year 373%); lowest economy-health factor 0.98 in 1952; at the end 1.00
- open deficit rails at the end: none
- rail "Post-1973 defence burden and indexed wages": Q1 1974-Q2 1985

historical: every turn offered at least one blocking decision (Next Action never skipped straight to Next Turn).

historical: every war front spawned at least once.
ghost written to game/data/ghost.json (302 turns, 529 milestones)

## Player autoplay (simple AI policy) scored against the ghost

| Date | Pop (sim) | Pop (CBS, S119) | diff | Ghost pop | Cities | Techs | Civics | Events | Gold (net) | Water S/D | Standing | Trust | Readiness | Inflation (real) | City fit | Ahead | Errors |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Q2 1948 | 0.81M | 0.81M | +0% | 0.81M | 42 | 0 | 1 | 5 | 70 (+0) | 0/0 | 47 | 83 | 40 | 4% (6%) | 0% | 0/6 | 0 |
| Q2 1953 | 1.71M | 1.67M | +3% | 1.70M | 74 | 9 | 11 | 48 | 34 (+14) | 787/738 | 49 | 72 | 65 | 3% (6%) | 25% | 4/6 | 0 |
| Q2 1958 | 2.05M | 2.03M | +1% | 2.03M | 84 | 14 | 15 | 63 | 419 (+20) | 908/946 | 48 | 86 | 46 | 3% (6%) | 10% | 5/6 | 0 |
| Q2 1963 | 2.41M | 2.43M | -1% | 2.39M | 86 | 19 | 18 | 72 | 686 (-21) | 1752/976 | 75 | 106 | 39 | 13% (7%) | 13% | 5/6 | 0 |
| Q2 1968 | 2.92M | 2.84M | +3% | 2.90M | 90 | 24 | 20 | 93 | 989 (+79) | 1731/1475 | 78 | 113 | 59 | 11% (2%) | 10% | 5/6 | 0 |
| Q2 1973 | 3.43M | 3.34M | +3% | 3.40M | 93 | 27 | 22 | 108 | 599 (+38) | 1815/1682 | 81 | 117 | 85 | 20% (19%) | 14% | 5/6 | 0 |

save/load round trip at Q1 1978: OK (97 cities, 34 units) - continuing with the loaded game

| Q2 1978 | 3.88M | 3.74M | +4% | 3.84M | 96 | 29 | 23 | 133 | 38 (-45) | 2032/1938 | 84 | 121 | 74 | 48% (49%) | 12% | 5/6 | 0 |
| Q2 1983 | 4.26M | 4.12M | +4% | 4.21M | 97 | 30 | 24 | 156 | 528 (+177) | 2155/2022 | 85 | 109 | 84 | 124% (143%) | 12% | 5/6 | 0 |
| Q2 1988 | 4.65M | 4.48M | +4% | 4.55M | 99 | 32 | 28 | 176 | 1469 (+217) | 1988/2039 | 83 | 111 | 60 | 9% (17%) | 8% | 5/6 | 0 |
| Q2 1993 | 5.48M | 5.33M | +3% | 5.39M | 101 | 33 | 29 | 190 | 1308 (-33) | 2003/2192 | 87 | 126 | 81 | 6% (11%) | 13% | 5/6 | 0 |
| Q2 1998 | 6.22M | 6.04M | +3% | 6.17M | 103 | 37 | 32 | 207 | 687 (+65) | 2094/2187 | 84 | 144 | 88 | 9% (6%) | 15% | 4/6 | 0 |
| Q2 2003 | 6.90M | 6.60M | +5% | 6.86M | 103 | 39 | 33 | 230 | 870 (+184) | 2393/2409 | 85 | 138 | 93 | 4% (1%) | 13% | 4/6 | 0 |
| Q2 2008 | 7.55M | 7.34M | +3% | 7.53M | 102 | 42 | 38 | 252 | 1503 (+318) | 2631/2474 | 87 | 157 | 96 | 4% (4%) | 11% | 5/6 | 0 |
| Q2 2013 | 8.16M | 8.08M | +1% | 8.16M | 102 | 44 | 40 | 269 | 1821 (+632) | 3422/2587 | 81 | 176 | 92 | 0% (2%) | 12% | 5/6 | 0 |
| Q2 2018 | 8.89M | 8.97M | -1% | 8.86M | 102 | 45 | 41 | 284 | 2313 (+784) | 3442/2446 | 83 | 212 | 92 | 0% (1%) | 12% | 5/6 | 0 |
| Q2 2023 | 9.67M | 9.79M | -1% | 9.65M | 102 | 46 | 42 | 317 | 1871 (+1132) | 3507/2692 | 82 | 232 | 95 | 3% (4%) | 15% | 5/6 | 0 |
| Q3 2023 | 9.75M | 9.79M | -1% | 9.69M | 102 | 46 | 42 | 319 | 4434 (+1266) | 3507/2707 | 81 | 236 | 94 | 3% (4%) | 15% | 5/6 | 0 |
player run: 13 same-subject events after non-historical fork picks; 0 without a history-course note or changed outcome
player run: 0 generic history-course notes, 19 specific consequences applied

player: every turn offered at least one blocking decision (Next Action never skipped straight to Next Turn).

player: every war front spawned at least once.

### Final standing vs the ghost (Q3 2023)
- Population: you 9.75M, ghost 9.69M -> 101% (history 9.79M vs you 9.75M residents)
- Economy (output per capita): you 78.44, ghost 66.13 -> 119% (history 36648 vs you 43470 2011 int$ (Maddison Project Database 2023))
- Science: you 82.91, ghost 51.13 -> 162% (history 6.35 vs you 10.30 % of GDP)
- Water security: you 187.85, ghost 137.48 -> 137% (history 277.00 vs you 378.47 m3 freshwater withdrawn per person per year)
- Culture and international standing: you 158.40, ghost 80.70 -> 196%
- Social cohesion (civic trust): you 235.82, ghost 89.89 -> 262%
- Verdict: Outperformed history in 5 of 6 tracks

Itemised reasons:
- [cohesion] +162% vs history: the lasting mark of your cabinet's choices, +54% on this track against history's choices (+29% against -25%)
- [cohesion] +162% vs history: your choice "Fund a larger social budget through defence cuts and higher taxes" at "Answering the tent protests" (history: "Adopt the Trajtenberg report, leaving the defence budget largely intact")
- [standing] +96% vs history: the lasting mark of your cabinet's choices, +27% on this track against history's choices (+33% against +5%)
- [standing] +96% vs history: State Budgets: defence first in 19 of 75 years (history's ghost: 10)
- [science] +62% vs history: the lasting mark of your cabinet's choices, +5% on this track against history's choices (+19% against +14%)
- [science] +62% vs history: your choice "Allon's first version: a Palestinian autonomous region linked to Israel" at "What to do with the territories" (history: "Keep the Jordan Valley, East Jerusalem and the Etzion bloc; leave the populated hills unannexed pending negotiations"), still in force: Open academic and trade links with Europe and the region
- [water] +37% vs history: National programmes: Water independence: desalination, 6 levels done (history's ghost: 2)
- [water] +37% vs history: Seawater Desalination 6 years earlier than history

### Run statistics
cities ever 105 (active 102): 13 founded by player settlers, 81 on historical dates, 11 by rails after the window closed
player-founded towns vs historical date: Or Yehuda +9 turns, Migdal HaEmek +12 turns, Yeruham +2 turns, Or Akiva -1 turns, Kiryat Malakhi -2 turns, Ashdod +5 turns, Netivot +2 turns, Nof HaGalil +5 turns, Nir Oz -3 turns, Arad +4 turns, Hod HaSharon +9 turns, Modi'in-Maccabim-Re'ut +12 turns
techs 46/47, civics 42/43, boosts 30, national projects 8, timeline moments 185
events fired 319/319, event choices made 14 (counterfactual 102), crises 23
units killed 70, units lost 30, rural residents 1984793, immigrants absorbed 3436947, inflation 3.0%
largest cities: Jerusalem 1188k (pop 34; census 1005k), Tel Aviv-Yafo 594k (pop 24; census 492k), Haifa 348k (pop 19; census 289k), Petah Tikva 314k (pop 18; census 264k), Ashdod 272k (pop 17; census 227k), Beersheba 261k (pop 16; census 217k), Rishon LeZion 260k (pop 16; census 252k), Bnei Brak 245k (pop 16; census 216k)

### Pacing (player picks): strategic decisions per turn by decade
| Decade | Turns | Story per turn | Story + agenda per turn | Turns with no story decision | Longest gap (turns) | Agenda share | V2 bar (>=1.5, <=25%, gap <=3) |
|---|---|---|---|---|---|---|---|
| 1948-1955 | 31 | 2.35 | 2.55 | 1 (3%) | 1 | 8% | PASS |
| 1956-1965 | 40 | 2.08 | 2.17 | 0 (0%) | 0 | 5% | PASS |
| 1966-1975 | 40 | 2.48 | 2.58 | 4 (10%) | 1 | 4% | PASS |
| 1976-1985 | 40 | 2.13 | 2.35 | 2 (5%) | 1 | 10% | PASS |
| 1986-1995 | 40 | 2.25 | 2.45 | 1 (3%) | 1 | 8% | PASS |
| 1996-2005 | 40 | 2.27 | 2.40 | 2 (5%) | 1 | 5% | PASS |
| 2006-2015 | 40 | 2.15 | 2.15 | 2 (5%) | 1 | 0% | PASS |
| 2016-2023 | 31 | 2.26 | 2.26 | 5 (16%) | 1 | 0% | PASS |

### Core story pacing (player picks): without minister, budget and review
| Decade | Turns | Core per turn | Turns with no core decision | Longest gap | Minister menus | Turns with 2+ minister menus | Core bar (>=1.2, <=30%) |
|---|---|---|---|---|---|---|---|
| 1948-1955 | 31 | 1.61 | 5 (16%) | 2 | 9 | 0 | PASS |
| 1956-1965 | 40 | 1.35 | 7 (18%) | 2 | 9 | 0 | PASS |
| 1966-1975 | 40 | 1.68 | 8 (20%) | 2 | 12 | 0 | PASS |
| 1976-1985 | 40 | 1.33 | 6 (15%) | 1 | 12 | 0 | PASS |
| 1986-1995 | 40 | 1.45 | 6 (15%) | 1 | 11 | 0 | PASS |
| 1996-2005 | 40 | 1.52 | 8 (20%) | 2 | 10 | 0 | PASS |
| 2006-2015 | 40 | 1.35 | 7 (18%) | 2 | 12 | 0 | PASS |
| 2016-2023 | 31 | 1.42 | 7 (23%) | 1 | 11 | 0 | PASS |
most minister menus in one turn: 1 (V2 bar: 1)

### Recommended-pick shares per recurring decision (V3 bar: no pick Recommended in more than 45% of appearances)
| Decision | Appearances | Distinct recommended picks | Most recommended | Share | Bar |
|---|---|---|---|---|---|
| agenda: Budget deficit | 7 | 3 | Raise taxes | 43% | PASS |
| agenda: Economic emergency: inflation | 3 | 2 | Another 'package deal' with the Histadrut and employers | 67% | PASS |
| agenda: Housing shortage | 15 | 6 | Public housing tender (state land | 40% | PASS |
| agenda: Inflation | 2 | 1 | Wage and price freeze | 100% | PASS |
| agenda: Water deficit | 9 | 3 | Pump the aquifers harder | 44% | PASS |
| budget_review | 75 | 7 | to_defence | 37% | PASS |
| coalition | 21 | 15 | national_religious_party | 24% | PASS |
| immigration | 49 | 11 | direct_absorption | 22% | PASS |
| minister | 86 | 59 | promote:housing:build_your_home | 12% | PASS |
| programme | 84 | 38 | hold | 39% | PASS |
| state_budget | 75 | 6 | absorption | 27% | PASS |

### Diplomacy (player)

Relations by decade (player picks; - = not yet a partner):
| Actor | 1950 | 1960 | 1970 | 1980 | 1990 | 2000 | 2010 | 2020 | end |
|---|---|---|---|---|---|---|---|---|---|
| United States | +41 | +57 | +69 | +72 | +70 | +45 | +39 | +55 | +61 |
| Russia | +27 | +11 | -36 | -30 | -28 | +29 | +32 | +32 | +29 |
| France | +24 | +43 | +37 | +40 | +49 | +52 | +53 | +55 | +49 |
| United Kingdom | +29 | +47 | +56 | +43 | +48 | +40 | +35 | +46 | +40 |
| Germany | -1 | +29 | +60 | +48 | +46 | +51 | +44 | +45 | +40 |
| European Union | - | - | +48 | +54 | +53 | +53 | +53 | +45 | +43 |
| United Nations | +37 | +28 | +38 | +23 | +40 | +31 | +29 | +19 | +21 |
| Egypt | -19 | -28 | -93 | +70 | +64 | +58 | +65 | +74 | +68 |
| Jordan | -15 | -18 | -48 | -35 | -27 | +65 | +45 | +48 | +48 |
| Syria | -4 | -12 | -43 | -27 | -25 | -18 | -27 | -27 | -24 |
| Lebanon | -15 | -15 | -42 | -46 | -44 | +14 | -17 | -20 | +14 |
| Iraq | -47 | -38 | -42 | -36 | -39 | -39 | -36 | -35 | -35 |
| Palestine Liberation Organization | - | - | -72 | -78 | -53 | -34 | -36 | -42 | -40 |
| Palestinian Authority | - | - | - | - | - | -1 | +31 | -36 | -36 |
| Turkey | +25 | +31 | +38 | +30 | +36 | +43 | +13 | +51 | +48 |
| Iran (Islamic Republic) | +25 | +36 | +41 | -18 | -25 | -30 | -28 | -44 | -41 |
| Morocco | - | +0 | +0 | +0 | +7 | +6 | +0 | +0 | +65 |
| Sudan | - | +0 | +0 | +0 | +0 | +0 | +0 | +0 | +42 |
| Saudi Arabia | +0 | +0 | +0 | +0 | +0 | +0 | +7 | +2 | +18 |
| United Arab Emirates | - | - | - | +0 | +0 | +0 | +0 | +0 | +70 |
| Bahrain | - | - | - | +0 | +0 | +0 | +0 | +0 | +57 |
| Qatar | - | - | - | +0 | +0 | +5 | -8 | -2 | -1 |
| China (People's Republic) | +10 | +2 | +1 | +0 | +6 | +60 | +44 | +46 | +48 |
| India | +0 | +2 | +0 | +0 | +0 | +40 | +54 | +53 | +45 |
| Hamas | - | - | - | - | -41 | -36 | -95 | -42 | -37 |
| Hezbollah | - | - | - | - | - | -17 | -20 | -20 | -20 |

player: deals taken 22 (france_arms x1, france_mirage x1, france_mirage5 x1, germany_loans x3, iran_flower x1, usa_arms x3, usa_eximbank x2, usa_grant x2, usa_fms x5, usa_arrow x2, china_arms x3, turkey_military x2, germany_dolphin x3, un_weog x1, india_arms x3, egypt_qiz x1, egypt_gas_import x1, china_trade x2, usa_missile_defence x2, gas_exports x1, russia_deconfliction x1, morocco_defence x1); by kind: { "aid": 9, "arms": 9, "joint": 5, "loan": 5.0, "arms_sale": 7, "un_vote": 1, "trade": 5, "back_channel": 1 }
player: envoy answers: 1949_zaim:meet, 1955_arms_channel:counter, 1958_periphery:accept, 1960_adenauer:accept, 1962_hawk:delay, 1968_phantoms:counter, 1969_chieftain:alternative, 1969_soviet_jewry:alternative, 1975_eec_fta:accept, 1977_morocco:alternative, france_arms:counter, germany_secret_arms:decline, usa_arms:accept, usa_eximbank:accept, 1980_venice:alternative, 1981_mou:decline, 1986_ifrane:accept, 1987_lavi:cancel, 1988_plo_dialogue:welcome, 1990_un_3379:alternative, 1994_jordan_terms:sign, turkey_military:accept, 2000_phalcon:decline, 2002_saudi_plan:embrace, 2003_loan_guarantees:propose_deduction, 2007_mou:accept, 2008_russia_syria:bargain, 2011_turkey_apology:accept, 2013_horizon:delay, 2016_mou:accept, 2019_china_investment:accept, 2020_f35_uae:accept_qme
player: envoy decisions answered 32 (18 not as history did), scripted envoys never offered 2; patrons' leverage that bit: 11; exposure now: france 0.1, iran 0.2, usa 15.1, west_germany 0.1, china 5.8, turkey 0.9, egypt 0.9, ussr 3.0
player: diplomatic decisions 34; Recommended picks by option: { "accept": 12, "meet": 1, "counter": 4, "delay": 2, "decline": 3, "alternative": 5, "cancel": 1, "welcome": 1, "sign": 1, "embrace": 1, "propose_deduction": 1, "bargain": 1, "accept_qme": 1 }; most common 'accept' 35% (V3 bar: at most 45%)
player: statuses against history: 1635 actor-years checked, 0 off the real timeline

### Debt report (player run)
- borrowed 647.39 gold in 5 loans; interest paid 354.21; repaid early 0.00; peak debt 616.58; debt at the end 0.00 (lenders' limit 23477)
- net gold negative in 59 of 302 turns; treasury below zero in 15 turns (longest run 7); final treasury 4434
- peak inflation 316% in 1984 (history that year 373%); lowest economy-health factor 0.96 in 1981; at the end 1.00
- open deficit rails at the end: none
- rail "Post-1973 defence burden and indexed wages": Q1 1974-Q2 1985

### The arc: overall score vs the ghost (player)
| Year | player overall | player tracks (pop/econ/sci/water/stand/coh) |
|---|---|---|
| 1950 | 113% | 1.00/1.09/0.91/1.63/1.17/1.01 |
| 1955 | 116% | 1.01/1.08/1.25/1.26/1.23/1.11 |
| 1960 | 131% | 1.01/1.06/1.17/1.62/1.80/1.18 |
| 1965 | 134% | 1.01/1.05/1.30/1.39/2.04/1.30 |
| 1970 | 127% | 1.01/0.99/1.22/1.04/2.31/1.38 |
| 1975 | 129% | 1.01/0.97/1.28/1.10/2.65/1.36 |
| 1980 | 127% | 1.01/0.97/1.29/0.91/2.15/1.43 |
| 1985 | 140% | 1.02/1.22/1.52/0.98/2.93/1.65 |
| 1990 | 141% | 1.02/1.24/1.59/1.01/3.17/1.58 |
| 1995 | 139% | 1.01/1.17/1.70/0.79/2.21/1.65 |
| 2000 | 138% | 1.01/0.98/1.66/0.92/1.84/1.86 |
| 2005 | 142% | 1.01/1.07/1.59/0.99/2.01/1.86 |
| 2010 | 145% | 1.00/1.00/1.62/1.16/1.98/1.96 |
| 2015 | 154% | 1.00/1.25/1.66/1.31/2.14/2.31 |
| 2020 | 152% | 1.00/1.11/1.68/1.35/2.25/2.44 |
| 2023 | 153% | 1.00/1.19/1.62/1.37/1.99/2.61 |

### Endings reached (recommended)
| Autoplayer | Ending | Also met | Secure | Prosperous | Peace | United | Overall 1965 | Overall at the end | Programme levels (sec/pros/peace/soc) | Treaties |
|---|---|---|---|---|---|---|---|---|---|---|
| recommended | United Society | peace_with_neighbours, nation_ahead | 3/4 (97%) | 4/5 (99%) | 4/4 (100%) MET | 4/4 (100%) MET | 134% | 152% | 12/15/8/7 | 6 |

recommended, criteria at the end:
- Secure State: Readiness at the end: 94 (>= 90) ok; Strikes on towns over the whole game, against history's ghost (no more than a tenth above history's): 126% of history (<= 110% of history) MISSED; Security programmes beyond history's (missile shield, Talpiot, space and cyber: levels and expansions ahead of the ghost; 3 or more): 5 (>= 3) ok; International Standing (allies keep backing you): 81 (>= 60) ok
- Prosperous State: Economy (output per capita) against history: 119% of history (>= 125% of history) MISSED; Science against history: 162% of history (>= 115% of history) ok; Inflation at the end: 3.0% (<= 10.0%) ok; Public debt, in years of revenue: 0.0 years (<= 1.5 years) ok; Prosperity programmes beyond history's (start-ups, desalination, gas: levels and expansions ahead of the ghost; 3 or more): 7 (>= 3); or economy at least 145% of history's: 119% of history (>= 145% of history) ok
- Peace with Neighbours: States at peace or with normal relations (treaties in force; 5 of the 6 history reached): 6 (>= 5) ok; International Standing at the end: 81 (>= 75) ok; Standing against history: 196% of history (>= 130% of history) ok; Peace programmes beyond history's (MASHAV, peace dividends: levels and expansions ahead of the ghost; 3 or more): 4 (>= 3); or standing at least 145% of history's: 196% of history (>= 145% of history) ok
- United Society: Social cohesion (civic trust) against history: >200% of history (>= 125% of history) ok; Lowest civic trust among Arab localities, development towns and the periphery: 85 (>= 75) ok; Residents short of housing: 0.8% (<= 2.0%) ok; Society programmes beyond history's (health, Arab-sector plans: levels and expansions ahead of the ghost; 3 or more): 4 (>= 3); or cohesion at least 140% of history's: >200% of history (>= 140% of history) ok
- A Nation Ahead: Overall score against history's record (after the state's health): 152% (>= 125%) ok; No collapse of the state in sight at the end: 0 (<= 0) ok
epilogue (United Society): By September 2023 your Israel is a United Society. It also met the thresholds of Peace with Neighbours, A Nation Ahead. Overall, your Israel finished at 152% of history's record (ahead on 5 of 6 tracks; difficulty: Norma / Of 218 cabinet decisions, you answered 97 differently from history. Still shaping the country in 2023: What to do with the territories (1967): Aquifer shared with the autonomous area; Olmert's offer to Abbas, or an econo / Your governments led Israel through 23 wars, operations and crises; enemy strikes hit its towns 108 times (history's ghost by then: 86), and 30 units were lost. Readiness at the end: 94.
track gains from programmes at the end: population +0.0%, economy +71.9%, science +42.6%, water +50.3%, standing +53.6%, cohesion +74.6%; gold spent on programmes 66799
lasting mark of the cabinet's choices against history's at the end: economy -14.1, science +5.1, water -5.2, standing +27.2, cohesion +54.4
fiscal indicator: Debt 0.0 yrs = | Inflation 3% = (ok); food: Food +1346 (self-sufficient), imports 0, exports 0 gold a quarter
collapse (recommended, normal): no collapse; fiscal peak 0/12, trust peak 0/12, military peak 0/7; closest: debt/limit 0.52 (Q4 1951), inflation 316% (Q3 1984), trust min 70 (Q4 1950), unrest 0% (Q2 1948), readiness in war 45 (Q2 1967), strikes beyond history in war +27 (Q2 2021)

### The arc per decade: overall score vs the ghost (recommended)
| Autoplayer | 1955 | 1965 | 1975 | 1985 | 1995 | 2005 | 2015 | 2020 | end | end vs 1965 |
|---|---|---|---|---|---|---|---|---|---|---|
| recommended | 116% | 134% | 129% | 140% | 139% | 142% | 154% | 152% | 153% | +18.7 |
strategic decisions 1948-55: 1.35 per turn over 31 turns (8 turns with none); by type: crisis_response 4, event_choice 1, immigration 6, fill_policy 3, choose_research 13, choose_civic 9, agenda 6
net gold per turn 1949-52: min -76, median -40, max +11; placement choices: camps 4, cities 154, dev_towns 35
last budget: income 1874, upkeep 918, imports 0, events 36, policies 0, choices 307, absorption 32, debt 0, food_exports 0, net 1267
readiness: capacity 95 vs requirement 142 (era 8) -> base 49, lessons +9, strain 0; inflation: history 4.2%, player gap -0.01 log points
city sizes vs census paths: weighted mean error 15.1%; largest gaps: Jerusalem 1188k vs 1005k, Tel Aviv-Yafo 594k vs 492k, Beit Shemesh 98k vs 145k, Haifa 348k vs 289k, Petah Tikva 314k vs 264k
crisis The 1948 war Q2 1948-Q2 1949: response mobilize, hostile destroyed 9, units lost 5, city hits 8, intercepts 0, readiness +1
crisis The Sinai Campaign (1956), fought without Britain and France Q4 1956-Q1 1957: response mobilize, hostile destroyed 0, units lost 2, city hits 1, intercepts 0, readiness -2
crisis The Six-Day War (1967) Q2 1967-Q3 1967: response front, hostile destroyed 0, units lost 2, city hits 2, intercepts 0, readiness -2
crisis The Karameh raid (March 1968) Q1 1968-Q2 1968: response mobilize, hostile destroyed 0, units lost 2, city hits 0, intercepts 0, readiness -1
crisis The War of Attrition (1969-70) Q1 1969-Q4 1970: response front, hostile destroyed 11, units lost 1, city hits 16, intercepts 0, readiness +4
crisis Black September: Syrian armour in Jordan (1970) Q3 1970-Q4 1970: response mobilize, hostile destroyed 0, units lost 0, city hits 0, intercepts 0, readiness +1
crisis The Yom Kippur War (1973) Q4 1973-Q1 1974: response front, hostile destroyed 0, units lost 1, city hits 0, intercepts 0, readiness +3
crisis Operation Litani (March 1978) Q1 1978-Q2 1978: response mobilize, hostile destroyed 1, units lost 2, city hits 2, intercepts 0, readiness -1
crisis Operation Opera (June 1981) Q2 1981-Q3 1981: response opx:sunday_strike, hostile destroyed 0, units lost 0, city hits 0, intercepts 0, readiness +1
crisis The Lebanon War (1982) Q2 1982-Q3 1982: response mobilize, hostile destroyed 1, units lost 0, city hits 1, intercepts 0, readiness +2
crisis Operation Wooden Leg (October 1985) Q4 1985-Q1 1986: response opx:long_range, hostile destroyed 0, units lost 0, city hits 0, intercepts 0, readiness +1
crisis The Gulf War: Scuds on Israel (1991) Q1 1991-Q2 1991: response mobilize, hostile destroyed 0, units lost 0, city hits 5, intercepts 1, readiness +1
crisis The First Intifada (1987-93) Q4 1987-Q4 1993: response mobilize, hostile destroyed 12, units lost 5, city hits 17, intercepts 0, readiness +3
crisis Operation Accountability (1993) Q3 1993-Q4 1993: response mobilize, hostile destroyed 0, units lost 0, city hits 3, intercepts 0, readiness +1
crisis Operation Grapes of Wrath (1996) Q2 1996-Q3 1996: response mobilize, hostile destroyed 0, units lost 0, city hits 5, intercepts 0, readiness +1
crisis Operation Defensive Shield (2002) Q1 2002-Q3 2002: response mobilize, hostile destroyed 3, units lost 3, city hits 0, intercepts 0, readiness +1
crisis The Second Intifada (2000-05) Q3 2000-Q1 2005: response mobilize, hostile destroyed 21, units lost 8, city hits 21, intercepts 0, readiness +5
crisis The Second Lebanon War (2006) Q3 2006-Q4 2006: response mobilize, hostile destroyed 2, units lost 0, city hits 5, intercepts 0, readiness +4
crisis Hamas rule in Gaza and the Qassam rockets (2007) Q2 2007-Q1 2008: response mobilize, hostile destroyed 5, units lost 1, city hits 5, intercepts 0, readiness +4
crisis Operation Cast Lead (Gaza, 2008-09) Q4 2008-Q2 2009: response mobilize, hostile destroyed 3, units lost 1, city hits 5, intercepts 0, readiness +2
crisis Operation Pillar of Defense (Gaza, 2012) Q4 2012-Q1 2013: response mobilize, hostile destroyed 0, units lost 0, city hits 3, intercepts 0, readiness +2
crisis Operation Protective Edge (Gaza, 2014) Q3 2014-Q4 2014: response mobilize, hostile destroyed 2, units lost 0, city hits 3, intercepts 0, readiness +3
crisis Operation Guardian of the Walls (Gaza, 2021) Q2 2021-Q3 2021: response mobilize, hostile destroyed 0, units lost 0, city hits 6, intercepts 0, readiness +1
average open decisions per turn 6.9; agenda items chosen: budget 7, housing 15, inflation 2, water 9, inflation_emergency 3

## Collapse report (soft fail states, v3 item 13)

### ruin_fiscal -> collapse_fiscal
- ended Q3 1956 (turn 34); first warning of collapse_fiscal: Q1 1951; quarters of warning: 22; peaks: fiscal 12/12, trust 0/12, military 0/7
- ending: Fiscal Collapse; memorial shown: no; end screen ending id: collapse_fiscal
- recovery test (the Recommended player takes over at the first warning): recovered: the danger cleared in Q3 1951, 1 quarters after the warning (peak strain 2)
  - [ending] Fiscal Collapse: In Q3 1956 the State of Israel could no longer pay its debts. With every lender's limit reached and inflation out of control, the government suspended payments and accepted an outside stabilisation programme. The game ends here. / At that date your Israel stood at 61% of history's record (ahead on 5 of 6 tracks; difficulty: Normal).
  - [what_went_wrong] What went wrong: For 12 quarters the public debt and the treasury's overdraft (1157 and 247 gold) stood above what foreign lenders would hold (1191), while inflation ran at 125% a year (history that year: 6.0%). / What drove it, largest first: / - The treasury stood below zero in 31 quarters (money printed to cover it fed inflation), and the budget ran a deficit in 34. / - Debt service: 39 gold a quarter in interest and repayment. / - Borrowing: 1697 gold in 28 loans over the game, 585 paid in interest. / - Running costs: upkeep of 118 gold a quarter (buildings 41 in 41 buildings, public services 62, districts 4, units 11) against revenue of 154, 77% of it. / The structural deficit was first reported in Q2 1949. / No building was mothballed or closed, no state company was privatised and no stabilisation package was adopted. / The first warning came in Q1 1951, 22 quarters before the end.
  - [what_might] What might have changed it: A state pays every quarter for what it has built: buildings, districts, public services for a growing population and the army. When spending ran above revenue, every quarter added to the overdraft or the debt and pushed prices up. Mothballing the buildings that did least, privatising state companies, scaling back costly policy cards, a stabilisation package once inflation took hold, and taxes or cuts as soon as the structural deficit was reported were the tools the game offered; loans abroad only bought time.
  - [forks] Your choices: Of 31 cabinet decisions, you answered 13 differently from history. Still shaping the country in 1956: Rationing or free market? (1949): Private initiative freed; Direct talks with Germany on reparations (1952): Claims left unpursued; Renewing military administration in the border regions (1953): Jewish border villages anxious about infiltration; The professionals' strike (1956): Pressure for similar raises elsewhere.
  - [wars] Wars and security: Your governments led Israel through 1 wars, operations and crises; enemy strikes hit its towns 8 times (history's ghost by then: 8), and 5 units were lost. Readiness at the end: 61.
  - [budgets] State Budgets: Across 8 Budget Laws your priorities were: balanced in 5, absorption and housing first in 2, education and science first in 1.
  - [diplomacy] Neighbours and allies: Treaties in force at the end: none. International Standing 42. Relations with the United States: 32.
  - [programmes] National programmes: No national programme was completed.
  - [money] Money: The treasury ends at -247 gold; public debt 1157 (2.1 years of revenue); inflation 124.8% (history: 6.0%). Over the game you borrowed 1697 gold and paid 585 in interest.
  - [close] History's Israel met runaway inflation in the early 1980s; the July 1985 Stabilization Plan's budget cuts and price restraint brought it down.
collapse (ruin_fiscal, normal): COLLAPSED: collapse_fiscal in Q3 1956; fiscal peak 12/12, trust peak 0/12, military peak 0/7; closest: debt/limit 1.82 (Q4 1951), inflation 167% (Q1 1953), trust min 72 (Q3 1954), unrest 3% (Q3 1956), readiness in war 66 (Q2 1948), strikes beyond history in war +8 (Q1 1949)

### ruin_trust -> collapse_trust
- ended Q3 1986 (turn 154); first warning of collapse_trust: Q2 1983; quarters of warning: 13; peaks: fiscal 0/12, trust 12/12, military 0/7
- ending: Collapse of Public Trust; memorial shown: no; end screen ending id: collapse_trust
- recovery test (the Recommended player takes over at the first warning): recovered: the danger cleared in Q2 1987, 15 quarters after the warning (peak strain 8)
  - [ending] Collapse of Public Trust: In Q3 1986 the State of Israel's institutions stopped working. After years of falling trust, repeated government crises and unrest in its cities, no coalition could command a majority or govern. The game ends here. / At that date your Israel stood at 64% of history's record (ahead on 3 of 6 tracks; difficulty: Normal).
  - [what_went_wrong] What went wrong: For 12 quarters national Civic Trust stayed at 40 or below (at the end: 33), and 53% of the population lived in cities in unrest or alienated from the state. / Governments fell or lost their majority 3 times: Q2 1983, Q3 1984, Q3 1985. / Lowest trust at the end: Ness Ziona (0), Gedera (0), Kiryat Bialik (0). / What cost the most trust in the last years: Cabinet: Devalue and cut subsidies; IDF headquarters in Tyre destroyed; Cabinet: Cut public services. / The first warning came in Q2 1983, 13 quarters before the end.
  - [what_might] What might have changed it: Trust follows what people live through each quarter: homes and amenities, prices, safety, and whether the state invests in their town. It takes years to rebuild, so the first warnings mattered most: investment where trust was lowest, lower inflation and fewer decisions that cost Civic Trust.
  - [forks] Your choices: Of 124 cabinet decisions, you answered 59 differently from history. Still shaping the country in 1986: Kafr Qasim: sentences and clemency (1958): No real punishment for killing Arab citizens; After the Agranat interim report (1974): Accountability deferred; the 1977 upheaval; Autonomy talks: Israel's guidelines (1979): Fewer new West Bank settlements; Clemency for the Jewish underground (1985): The Knesset seen to override the courts.
  - [wars] Wars and security: Your governments led Israel through 10 wars, operations and crises; enemy strikes hit its towns 25 times (history's ghost by then: 29), and 13 units were lost. Readiness at the end: 81.
  - [budgets] State Budgets: Across 38 Budget Laws your priorities were: defence first in 24, war budgets in 14.
  - [diplomacy] Neighbours and allies: Treaties in force at the end: Egypt. International Standing 72. Relations with the United States: 25.
  - [programmes] National programmes: Completed: MASHAV: international development cooperation (1 level, expanded 5 times); Talpiot: the army's science and technology programme (1 level, expanded 2 times); The start-up economy (1 level); Space and cyber (1 level, expanded 1 times).
  - [money] Money: The treasury ends at -225 gold; public debt 0 (0.0 years of revenue); inflation 60.4% (history: 44.0%).
  - [close] In history Israel's governments changed often and its divisions ran deep, but its institutions kept working; this ending shows what the game's model of trust does when it is pushed much further.
collapse (ruin_trust, normal): COLLAPSED: collapse_trust in Q3 1986; fiscal peak 0/12, trust peak 12/12, military peak 0/7; closest: debt/limit 0.40 (Q1 1952), inflation 547% (Q3 1984), trust min 31 (Q4 1985), unrest 55% (Q3 1985), readiness in war 66 (Q2 1948), strikes beyond history in war +11 (Q3 1969)

### ruin_military -> collapse_military
- ended Q2 1989 (turn 165); first warning of collapse_military: Q4 1987; quarters of warning: 6; peaks: fiscal 0/12, trust 0/12, military 7/7
- ending: Military Collapse; memorial shown: no; end screen ending id: collapse_military
- recovery test (the Recommended player takes over at the first warning): recovered: the danger cleared in Q2 1950, 4 quarters after the warning (peak strain 1)
  - [ending] Military Collapse: In Q2 1989 Israel's army could no longer hold its lines. With Readiness at a breaking point and the enemy striking the towns far more often than in history, the government had to accept a ceasefire it could not shape. The game ends here. / At that date your Israel stood at 96% of history's record (ahead on 5 of 6 tracks; difficulty: Normal).
  - [what_went_wrong] What went wrong: In the First Intifada (1987-93) the fronts gave way. Readiness had fallen to 0, and enemy strikes had hit Israel's towns 98 times over the game, against 29 in history by that date. / In that war: 19 strikes on towns, 0 units lost, 5 quarters of holding back the reserves. / Units lost over the game: 0; earlier wars fought with standing forces only: 9. / The first warning came in Q4 1987, 6 quarters before the end.
  - [what_might] What might have changed it: Readiness is built in peacetime: units, training, defence buildings and the defence envelope of the budget. In a war it rests on the reserves committed to the threatened fronts and on civil defence for the towns. Holding back to keep the economy running saved money each quarter, but it let the enemy keep the initiative.
  - [forks] Your choices: Of 128 cabinet decisions, you answered 55 differently from history. Still shaping the country in 1989: Palestinian refugees at Lausanne (1949): Arab graduates join universities; Ikrit and Baram: return or compensation (1972): Neighbouring Jewish farmers lose land; Defence budget against inflation (1980): Defence R&D projects frozen; The uprising: force or politics? (1988): Hope among Arab citizens.
  - [wars] Wars and security: Your governments led Israel through 10 wars, operations and crises; enemy strikes hit its towns 98 times (history's ghost by then: 29), and 0 units were lost. Readiness at the end: 0.
  - [budgets] State Budgets: Across 41 Budget Laws your priorities were: absorption and housing first in 41.
  - [diplomacy] Neighbours and allies: Treaties in force at the end: Egypt. International Standing 81. Relations with the United States: 69.
  - [programmes] National programmes: Completed: MASHAV: international development cooperation (1 level, expanded 4 times); Talpiot: the army's science and technology programme (1 level, expanded 2 times); The start-up economy (3 levels, expanded 2 times); Space and cyber (1 level, expanded 1 times); Universal health care (1 level).
  - [money] Money: The treasury ends at 231 gold; public debt 0 (0.0 years of revenue); inflation 16.1% (history: 19.8%).
  - [close] These wars cost lives on every side; the record above counts only what the game measures.
collapse (ruin_military, normal): COLLAPSED: collapse_military in Q2 1989; fiscal peak 0/12, trust peak 0/12, military peak 7/7; closest: debt/limit 0.54 (Q4 1951), inflation 369% (Q3 1984), trust min 62 (Q4 1982), unrest 4% (Q2 1952), readiness in war 0 (Q1 1978), strikes beyond history in war +69 (Q4 1988)

### ruin_builder (the naive builder) -> structural deficit
- the builder alone: no collapse (Q3 2023); first structural alarm Q1 1952; first fiscal-collapse warning never
- the alarm: Revenue 141 (taxes 137, aid and transfers 4) against outflows 232, 164% of it: running costs 77 (buildings 12, public services 51, districts 4, units 10); absorption 89; lasting terms 33 (Defence budget and war debts after 1948 15, Ex-Im Bank loan repayments 6, Transit camps and housing for 54,000 more people 6); debt service 33. Highest upkeep: Tel Aviv-Yafo 6, Haifa 5, Jerusalem 3, Rehovot 2, Arraba 0.
collapse (ruin_builder, normal): no collapse; fiscal peak 0/12, trust peak 0/12, military peak 0/7; closest: debt/limit 1.11 (Q4 1951), inflation 354% (Q3 1984), trust min 68 (Q3 2004), unrest 12% (Q1 2005), readiness in war 45 (Q2 1967), strikes beyond history in war +31 (Q2 2021)
- Recommended from the structural alarm (Q1 1952): survived at Q3 2023; fiscal strain peak 0; overall 152.8%; ending united_society; levers used { "mothball": 6, "privatise": 1, "reopen": 6 }

### ruin_populist (the careless populist) -> Recommended from the first structural alarm
- the populist alone: no collapse (Q3 1985); first structural alarm Q3 1965 (overall 85% at the end of the run); costly policy cards at the alarm 50 gold a quarter
- the alarm: Revenue 333 (taxes 300, aid and transfers 33) against outflows 397, 119% of it: running costs 238 (buildings 126, public services 97, districts 4, units 11); absorption 16; policy cards 50 (Social Security 50); lasting terms 61 (Housing, schools and jobs programme 14, Indemnities and a contribution to the UN fund 13, Strained German aid and arms trade 8); debt service 33. Highest upkeep: Tel Aviv-Yafo 10, Jerusalem 8, Haifa 7, Migdal HaEmek 5, Nazareth 5.
collapse (ruin_populist, normal): no collapse; fiscal peak 3/12, trust peak 0/12, military peak 0/7; closest: debt/limit 1.16 (Q2 1984), inflation 986% (Q3 1984), trust min 73 (Q3 1948), unrest 0% (Q4 1951), readiness in war 23 (Q2 1967), strikes beyond history in war +21 (Q1 1970)
- Recommended from the populist's first structural alarm (Q3 1965): no collapse at Q3 1985 (80 quarters); strain peaks fiscal 0, trust 0, military 0; structural alarm on in 4 quarters, cleared at the end; overall 128.3%; levers used { "mothball": 57, "reopen": 7 }; cards {  }
collapse (recommended after the populist, normal): no collapse; fiscal peak 0/12, trust peak 0/12, military peak 0/7; closest: debt/limit 0.95 (Q2 1952), inflation 317% (Q3 1984), trust min 73 (Q3 1948), unrest 3% (Q4 1983), readiness in war 38 (Q2 1967), strikes beyond history in war +21 (Q1 1970)

## Result
elapsed 1504.7 s, failures 0
ALL INVARIANTS PASSED
