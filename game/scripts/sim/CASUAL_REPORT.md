# Israel: The Birth of a Nation - simulation autoplay report

Run: 2026-10-16T16:58:59, seed 1948, Godot 4.7.1-stable (official)

## Data
techs 47, civics 43, policies 47, districts 15, buildings 53, national projects 10, units 23
cities.json 119 places, events.json 319 events, map 7904 tiles, 16 border eras, SOURCES ids 2011
forks 223 (in game/data/forks/), wars 23 (in game/data/wars/)
fork consequence check: 46 same-subject fork/event pairs; 0 uncovered non-historical answers
generic history-course fallbacks: 0 (fork answer -> event pairs with no specific outcome; at most 5 allowed)
leak scan (nothing dated after Q3 2023 visible): 0 hits; cities 0, trees 0, programmes 0, events 0, wars 0, cabinet and series 0, forks 0, choice terms 0, diplomacy 0, deal end dates 0
deleted-content scan (nothing after Q3 2023 in the data; 64 tombstoned ids): 0 hits; content and helpers 0, load-time scrub 0, data files 0, Hebrew catalogs 0

API smoke test: 24 queries and the main actions OK (Q2 1949)

## V4 casual layer: story mode, the ministers on auto (sim_test --casual)
Story decisions by each style; routine by the ministers (plain Recommended, or the strategist's brief). The deal screen and
the Programmes panel stay with the story style; the Treasury in danger is answered with Finance's plan. Seed 1948, Normal.

### v3 reference: history's picks for everything (Full control)
v3 historical picks: overall 103.2%, ending mixed_record
casual historical (brief balanced): overall 103.4%, ending mixed_record, Q3 2023, 307 s
casual varied (brief balanced): overall 132.5%, ending nation_ahead, Q3 2023, 462 s
casual strategist_security (brief security): overall 148.1%, ending secure_state, Q3 2023, 327 s
casual strategist_prosperity (brief prosperity): overall 144.9%, ending prosperous_state, Q3 2023, 391 s
casual strategist_peace (brief peace): overall 141.1%, ending peace_with_neighbours, Q3 2023, 330 s
casual strategist_society (brief society): overall 124.7%, ending united_society, Q3 2023, 465 s
casual ruin_populist (brief society): overall 60.7%, ending collapse_fiscal, Q4 1983, 106 s

### Results
| Run | Brief | Overall vs the ghost | Ending | Player decisions | Outside war: avg / max | War quarters: avg / max | Quiet quarters | Treasury prompts | Routine items seen by the player | Stuck turns |
|---|---|---|---|---|---|---|---|---|---|---|
| v3 historical (Full control) | - | 103.2% | mixed_record | - | - | - | - | - | - | - |
| casual historical | balanced | 103.4% | mixed_record | 595 | 1.77 / 4 | 2.63 / 6 | 21 | 0 | 0 | 0 |
| casual varied | balanced | 132.5% | nation_ahead | 495 | 1.44 / 4 | 2.30 / 6 | 40 | 2 | 0 | 0 |
| casual strategist_security | security | 148.1% | secure_state | 541 | 1.61 / 4 | 2.39 / 6 | 30 | 0 | 0 | 0 |
| casual strategist_prosperity | prosperity | 144.9% | prosperous_state | 551 | 1.66 / 4 | 2.39 / 6 | 25 | 1 | 0 | 0 |
| casual strategist_peace | peace | 141.1% | peace_with_neighbours | 520 | 1.54 / 4 | 2.34 / 6 | 35 | 0 | 0 | 0 |
| casual strategist_society | society | 124.7% | united_society | 525 | 1.57 / 4 | 2.30 / 6 | 32 | 2 | 0 | 0 |
| casual ruin_populist | society | 60.7% | collapse_fiscal | 260 | 1.62 / 4 | 3.22 / 6 | 13 | 20 | 0 | 0 |

A war quarter (V4 box 3's exception) is one with a crisis open at its start OR with front orders answered in it (V4_DESIGN analyze.py):
a war that breaks out during the quarter (the Six-Day War, Q2 1967) counts as a war quarter although no crisis is open when the quarter starts.
- historical: quarters with 5+ player decisions: Q2 1967 6 (war) [fork, coalition, crisis_response, crisis_response, crisis_response, dedication], Q1 1991 5 (war) [fork, crisis_response, crisis_response, state_budget+half], Q4 1992 5 (war) [fork, crisis_response, fork, state_budget+half]
- varied: quarters with 5+ player decisions: Q2 1967 6 (war) [fork, coalition, crisis_response, crisis_response, crisis_response, dedication]
- strategist_security: quarters with 5+ player decisions: Q2 1967 6 (war) [fork, coalition, crisis_response, crisis_response, crisis_response, dedication], Q1 1978 5 (war) [fork, crisis_response, crisis_response, agenda, state_budget]
- strategist_prosperity: quarters with 5+ player decisions: Q2 1967 6 (war) [fork, coalition, crisis_response, crisis_response, crisis_response, dedication]
- strategist_peace: quarters with 5+ player decisions: Q2 1967 6 (war) [fork, coalition, crisis_response, crisis_response, crisis_response, dedication], Q4 1992 5 (war) [fork, crisis_response, fork, state_budget+half]
- strategist_society: quarters with 5+ player decisions: Q2 1967 6 (war) [fork, coalition, crisis_response, crisis_response, crisis_response, dedication]
- ruin_populist: quarters with 5+ player decisions: Q2 1967 6 (war) [fork, coalition, crisis_response, crisis_response, crisis_response, dedication]

Decision types answered by the player (casual historical): { "crisis_response": 65, "event_choice": 15, "fork": 223, "brief": 1, "state_budget": 75, "diplomacy": 35, "programme": 104, "immigration": 8, "coalition": 21, "dedication": 7, "agenda": 3 }
- historical: 3664 automatic actions by the ministers, all 3664 covered by 2685 report lines; 557 story cards checked
- varied: 2701 automatic actions by the ministers, all 2701 covered by 2034 report lines; 489 story cards checked
- strategist_security: 3331 automatic actions by the ministers, all 3331 covered by 2368 report lines; 522 story cards checked
- strategist_prosperity: 3009 automatic actions by the ministers, all 3009 covered by 2322 report lines; 542 story cards checked
- strategist_peace: 3267 automatic actions by the ministers, all 3267 covered by 2355 report lines; 505 story cards checked
- strategist_society: 4763 automatic actions by the ministers, all 4763 covered by 3423 report lines; 511 story cards checked
- ruin_populist: 1853 automatic actions by the ministers, all 1853 covered by 1240 report lines; 258 story cards checked

v4 fix round checks on every card (v4fix-sim): M1 = immigration options with 1,000+ people in camps that say so; M2 = refused clicks on
unaffordable programmes that gave a reason; M3 = cards whose Recommended reason was checked against the numbers shown.
| Run | M1 options named / failures | M2 refused clicks with a reason / failures | M3 reasons checked (numeric, mobilisation) / failures | Line wording failures | Report wording failures | Last-quarter surplus prompts |
|---|---|---|---|---|---|---|
| historical | 5 / 0 | 0 / 0 | 595 (378, 18) / 0 | 0 | 0 | 0 |
| varied | 4 / 0 | 11 / 0 | 495 (267, 17) / 0 | 0 | 0 | 0 |
| strategist_security | 5 / 0 | 11 / 0 | 541 (301, 18) / 0 | 0 | 0 | 0 |
| strategist_prosperity | 6 / 0 | 4 / 0 | 551 (322, 17) / 0 | 0 | 0 | 0 |
| strategist_peace | 5 / 0 | 6 / 0 | 520 (279, 18) / 0 | 0 | 0 | 0 |
| strategist_society | 6 / 0 | 16 / 0 | 525 (262, 18) / 0 | 0 | 0 | 0 |
| ruin_populist | 4 / 0 | 3 / 0 | 260 (140, 6) / 0 | 0 | 0 | 0 |

### Balance bars
- casual historical 103.4% against v3 historical 103.2%: +0.2 points (bar: within 5)
- casual varied 132.5%: +29.1 points above casual historical (bar: 10 or more)
- divergence, casual varied against casual historical: 5 of 6 tracks apart (bar: 5) (population -2.5%, economy -28.9%, science +32.5%, water +51.9%, standing +53.2%, cohesion +103.2%)
- the four casual strategists reach 4 distinct endings: ["secure_state", "prosperous_state", "peace_with_neighbours", "united_society"] (bar: 4)

### Casual core story density per quarter, by decade (forks, event choices, war and front orders, coalition, envoys, dedication, named immigration waves)
| Decade | v3 historical core | casual historical | % of v3 | casual varied | % of v3 | casual strategist_security | % of v3 | casual strategist_prosperity | % of v3 | casual strategist_peace | % of v3 | casual strategist_society | % of v3 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1948-1955 | 1.61 | 1.39 | 86% | 1.39 | 86% | 1.39 | 86% | 1.39 | 86% | 1.39 | 86% | 1.39 | 86% |
| 1956-1965 | 1.40 | 1.10 | 79% | 1.02 | 73% | 1.08 | 77% | 1.08 | 77% | 1.00 | 71% | 1.05 | 75% |
| 1966-1975 | 1.68 | 1.38 | 82% | 1.27 | 76% | 1.38 | 82% | 1.27 | 76% | 1.30 | 78% | 1.38 | 82% |
| 1976-1985 | 1.43 | 1.27 | 89% | 1.23 | 86% | 1.18 | 82% | 1.23 | 86% | 1.15 | 81% | 1.18 | 82% |
| 1986-1995 | 1.50 | 1.25 | 83% | 1.20 | 80% | 1.20 | 80% | 1.25 | 83% | 1.20 | 80% | 1.20 | 80% |
| 1996-2005 | 1.52 | 1.23 | 80% | 1.20 | 79% | 1.23 | 80% | 1.23 | 80% | 1.23 | 80% | 1.23 | 80% |
| 2006-2015 | 1.35 | 1.20 | 89% | 1.20 | 89% | 1.20 | 89% | 1.20 | 89% | 1.20 | 89% | 1.20 | 89% |
| 2016-2023 | 1.45 | 1.10 | 76% | 1.03 | 71% | 1.06 | 73% | 1.06 | 73% | 1.06 | 73% | 1.06 | 73% |

### The ministers' report, last quarter of the casual historical run (Q2 2023)
- `auto.budget.purchase` Finance: bought School in Ashdod.
- `auto.budget.spent` Finance: purchases this quarter: 160 gold.
- `auto.trade.route` Finance: new export route Rishon LeZion to Egypt.
- `auto.delegations.sent` Foreign Ministry: a delegation to United States (75 gold).
Programme decisions deferred to a quieter quarter: 0; surplus prompts a year at most 2.
- historical: surplus decisions Finance held without asking the player (yearly quota 2, full quarters, the last quarters): 11
- varied: surplus decisions Finance held without asking the player (yearly quota 2, full quarters, the last quarters): 0
- strategist_security: surplus decisions Finance held without asking the player (yearly quota 2, full quarters, the last quarters): 5
- strategist_prosperity: surplus decisions Finance held without asking the player (yearly quota 2, full quarters, the last quarters): 12
- strategist_peace: surplus decisions Finance held without asking the player (yearly quota 2, full quarters, the last quarters): 7
- strategist_society: surplus decisions Finance held without asking the player (yearly quota 2, full quarters, the last quarters): 3
- ruin_populist: surplus decisions Finance held without asking the player (yearly quota 2, full quarters, the last quarters): 0

### Every ministry flips mid-game (research manual from Q1 1958, all manual from Q2 1958, all back to auto at Q4 1962)
| Ministry | Its prompts while manual (Q1 1958-Q3 1962) | Left after hand-back |
|---|---|---|
| City production | 75 | 0 |
| Research | 6 | 0 |
| Civics | 3 | 0 |
| Policy cards | 2 | 0 |
| Military units | 0 | 0 |
| Settlement and public works | 17 | 0 |
| The yearly immigration plan | 3 | 0 |
| Cabinet appointments | 4 | 0 |
| Budget reviews and purchases | 5 | 0 |
| Export routes | routes stay as they were (0); the notice returns | 0 |
| Delegations abroad | no automatic delegation (0 sent) | 0 |
custom style with one ministry manual: true; Full control with all manual: true; save/load: OK

## Result
elapsed 2661.3 s, failures 0
ALL INVARIANTS PASSED
