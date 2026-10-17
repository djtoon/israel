# Israel: The Birth of a Nation - simulation autoplay report

Run: 2026-10-16T13:15:15, seed 1948, Godot 4.7.1-stable (official)

## Data
techs 47, civics 43, policies 47, districts 15, buildings 53, national projects 10, units 23
cities.json 119 places, events.json 319 events, map 7904 tiles, 16 border eras, SOURCES ids 2011
forks 223 (in game/data/forks/), wars 23 (in game/data/wars/)
fork consequence check: 46 same-subject fork/event pairs; 0 uncovered non-historical answers
generic history-course fallbacks: 0 (fork answer -> event pairs with no specific outcome; at most 5 allowed)
leak scan (nothing dated after Q3 2023 visible): 0 hits; cities 0, trees 0, programmes 0, events 0, wars 0, cabinet and series 0, forks 0, choice terms 0, diplomacy 0, deal end dates 0
deleted-content scan (nothing after Q3 2023 in the data; 64 tombstoned ids): 0 hits; content and helpers 0, load-time scrub 0, data files 0, Hebrew catalogs 0

API smoke test: 24 queries and the main actions OK (Q2 1949)

## Divergence test (historical picks vs deliberately varied picks, to Q3 2023)

| Track | Historical picks | Varied picks | Difference |
|---|---|---|---|
| Population | 9.72M | 9.75M | +0.3% |
| Economy (output per capita) | 65.98 | 43.50 | -34.1% |
| Science | 59.94 | 77.12 | +28.7% |
| Water security | 145.99 | 208.68 | +42.9% |
| Culture and international standing | 78.46 | 130.60 | +66.4% |
| Social cohesion (civic trust) | 88.42 | 177.38 | +100.6% |
| gold | 3001 | 2582 | |
| readiness | 91.85 | 78.13 | |
| cities | 102.00 | 102.00 | |
| inflation % | 4.0 | 3.7 | |

Forks: historical run 223 taken (0 non-historical); varied run 218 taken (218 non-historical). Event choices counterfactual: 0 vs 232.
Tracks measurably apart (5%; 3% for population): 5 of 6 (V2 needs 4)
Overall score vs the ghost: historical picks 103.2%, varied picks 129.6%: spread +26.4 points

### The arc: overall score vs the ghost (historical, varied)
| Year | historical overall | historical tracks (pop/econ/sci/water/stand/coh) | varied overall | varied tracks (pop/econ/sci/water/stand/coh) |
|---|---|---|---|---|
| 1950 | 98% | 1.00/1.01/0.91/0.97/1.00/1.00 | 106% | 1.00/0.96/0.82/1.43/1.19/0.99 |
| 1955 | 107% | 1.00/1.11/1.20/1.09/1.00/1.00 | 117% | 1.03/1.16/1.10/1.36/1.14/1.23 |
| 1960 | 101% | 1.00/0.95/1.13/1.02/1.00/0.95 | 114% | 1.04/0.91/1.14/0.97/1.62/1.18 |
| 1965 | 104% | 1.00/1.06/1.23/1.08/0.92/0.97 | 130% | 1.03/1.00/1.32/1.18/2.04/1.26 |
| 1970 | 108% | 1.00/1.10/1.21/1.11/1.05/1.05 | 124% | 1.02/0.85/1.23/1.11/2.46/1.25 |
| 1975 | 109% | 1.00/1.10/1.21/1.11/1.10/1.04 | 122% | 1.02/0.83/1.28/1.02/2.64/1.21 |
| 1980 | 104% | 1.00/1.06/1.10/0.99/1.09/1.03 | 118% | 1.01/0.79/1.33/0.92/1.87/1.16 |
| 1985 | 106% | 1.00/1.09/1.11/0.95/1.14/1.07 | 126% | 1.01/0.84/1.37/1.06/2.16/1.28 |
| 1990 | 113% | 1.01/1.24/1.13/1.15/1.10/1.13 | 130% | 1.02/0.92/1.55/1.03/2.29/1.26 |
| 1995 | 108% | 1.01/1.20/1.21/0.94/1.09/1.03 | 118% | 1.02/0.81/1.59/0.75/1.75/1.18 |
| 2000 | 105% | 1.01/1.05/1.17/1.01/1.02/1.02 | 115% | 1.02/0.70/1.59/0.63/1.57/1.40 |
| 2005 | 106% | 1.01/1.10/1.14/1.08/1.01/1.04 | 120% | 1.01/0.67/1.48/0.98/1.60/1.48 |
| 2010 | 103% | 1.00/1.01/1.14/1.04/1.00/0.98 | 124% | 1.00/0.64/1.54/1.09/1.42/1.72 |
| 2015 | 107% | 1.00/1.09/1.17/1.06/1.07/1.03 | 140% | 1.00/0.72/1.59/1.43/1.64/2.00 |
| 2020 | 106% | 1.00/0.98/1.20/1.04/1.13/0.99 | 141% | 1.01/0.65/1.57/1.44/1.78/2.04 |
| 2023 | 103% | 1.00/0.99/1.17/1.06/0.99/0.98 | 138% | 1.00/0.65/1.50/1.52/1.64/1.96 |

### Debt report (historical picks)
- borrowed 1037 gold in 5 loans; interest paid 566.80; repaid early 0.00; peak debt 962.47; debt at the end 0.00 (lenders' limit 27902)
- net gold negative in 49 of 302 turns; treasury below zero in 14 turns (longest run 5); final treasury 3001
- peak inflation 344% in 1984 (history that year 373%); lowest economy-health factor 0.95 in 1979; at the end 1.00
- open deficit rails at the end: none
- rail "Post-1973 defence burden and indexed wages": Q1 1974-Q2 1985

### Debt report (varied picks)
- borrowed 1885 gold in 16 loans; interest paid 991.24; repaid early 201.00; peak debt 1286; debt at the end 45.29 (lenders' limit 15244)
- net gold negative in 103 of 302 turns; treasury below zero in 34 turns (longest run 17); final treasury 2582
- peak inflation 359% in 1984 (history that year 373%); lowest economy-health factor 0.69 in 1952; at the end 1.00
- open deficit rails at the end: none
- rail "Post-1973 defence burden and indexed wages": Q1 1974-Q1 1993

### Recommended-pick shares per recurring decision (V3 bar: no pick Recommended in more than 45% of appearances)
| Decision | Appearances | Distinct recommended picks | Most recommended | Share | Bar |
|---|---|---|---|---|---|
| agenda: Budget deficit | 5 | 3 | Cut public services | 40% | PASS |
| agenda: Economic emergency: inflation | 4 | 2 | Another 'package deal' with the Histadrut and employers | 50% | PASS |
| agenda: Housing shortage | 14 | 5 | Public housing tender (state land | 43% | PASS |
| agenda: Inflation | 2 | 2 | Index wages to prices | 50% | PASS |
| agenda: International standing is slipping | 3 | 1 | Cultivate the diaspora and friendly governments | 100% | PASS |
| agenda: Structural deficit | 5 | 3 | Raise taxes | 80% | over 50% (agenda item) |
| agenda: Water deficit | 10 | 3 | Ration water | 40% | PASS |
| budget_review | 75 | 8 | to_defence | 25% | PASS |
| coalition | 21 | 15 | national_religious_party | 24% | PASS |
| immigration | 49 | 6 | cities_b | 24% | PASS |
| minister | 86 | 33 | promote:agriculture:drip_extension | 23% | PASS |
| programme | 52 | 22 | hold | 33% | PASS |
| state_budget | 75 | 5 | development | 28% | PASS |

### Diplomacy (historical, varied)

Relations by decade (historical picks; - = not yet a partner):
| Actor | 1950 | 1960 | 1970 | 1980 | 1990 | 2000 | 2010 | 2020 | end |
|---|---|---|---|---|---|---|---|---|---|
| United States | +34 | +28 | +46 | +66 | +25 | +43 | +46 | +53 | +59 |
| Russia | +34 | +11 | -49 | -31 | -26 | +31 | +29 | +22 | +23 |
| France | +22 | +46 | +6 | +26 | +22 | +34 | +36 | +34 | +33 |
| United Kingdom | +27 | +35 | +28 | +30 | +21 | +36 | +33 | +33 | +33 |
| Germany | -3 | +2 | +33 | +37 | +26 | +39 | +34 | +34 | +33 |
| European Union | - | - | +29 | +37 | +16 | +35 | +31 | +29 | +30 |
| United Nations | +34 | +27 | +26 | +17 | +23 | +30 | +26 | +18 | +21 |
| Egypt | -19 | -26 | -90 | +70 | +56 | +44 | +45 | +52 | +52 |
| Jordan | -15 | -18 | -48 | -35 | -35 | +57 | +37 | +31 | +34 |
| Syria | -18 | -16 | -43 | -24 | -27 | -29 | -29 | -27 | -24 |
| Lebanon | -15 | -15 | -42 | -46 | -47 | +0 | -18 | -20 | +14 |
| Iraq | -47 | -38 | -42 | -36 | -39 | -39 | -36 | -35 | -35 |
| Palestine Liberation Organization | - | - | -72 | -78 | -66 | +7 | +1 | -7 | -5 |
| Palestinian Authority | - | - | - | - | - | +3 | +22 | -38 | -37 |
| Turkey | +25 | +32 | +27 | +25 | +23 | +36 | +9 | +32 | +38 |
| Iran (Islamic Republic) | +25 | +32 | +27 | -33 | -27 | -26 | -25 | -41 | -39 |
| Morocco | - | +0 | +0 | +7 | +9 | +9 | +1 | +0 | +51 |
| Sudan | - | +0 | +0 | +0 | +0 | +0 | +0 | +0 | +42 |
| Saudi Arabia | +0 | +0 | +0 | +0 | +0 | +0 | +5 | +1 | +18 |
| United Arab Emirates | - | - | - | +0 | +0 | +0 | +0 | +0 | +70 |
| Bahrain | - | - | - | +0 | +0 | +0 | +0 | +0 | +46 |
| Qatar | - | - | - | +0 | +0 | +5 | -8 | -2 | -1 |
| China (People's Republic) | +10 | +2 | +1 | +0 | +6 | +30 | +22 | +22 | +23 |
| India | +0 | +2 | +0 | +0 | +0 | +28 | +26 | +25 | +25 |
| Hamas | - | - | - | - | -41 | -36 | -95 | -42 | -37 |
| Hezbollah | - | - | - | - | - | -17 | -20 | -20 | -20 |

historical: deals taken 6 (usa_eximbank x1, france_arms x2, germany_secret_arms x1, usa_arms x3, germany_loans x1, turkey_military x1); by kind: {  }
historical: envoy answers: usa_eximbank:accept, 1949_zaim:decline, 1955_arms_channel:accept, france_arms:accept, 1958_periphery:accept, 1960_adenauer:accept, 1962_hawk:accept, germany_secret_arms:accept, usa_arms:accept, 1968_phantoms:accept, 1969_soviet_jewry:accept, 1969_chieftain:alternative, 1975_eec_fta:accept, germany_loans:accept, 1977_morocco:accept, 1980_venice:decline, 1981_mou:accept, 1986_ifrane:accept, 1987_lavi:cancel, 1988_plo_dialogue:protest, 1990_un_3379:counter, 1994_jordan_terms:sign, turkey_military:accept, 2000_phalcon:accept, 2002_saudi_plan:explore, 2003_loan_guarantees:propose_deduction, 2007_mou:accept, 2008_russia_syria:warn, 2011_turkey_apology:decline, 2013_horizon:accept, 2016_mou:accept, 2019_china_investment:accept, 2020_f35_uae:accept_qme
historical: envoy decisions answered 33 (0 not as history did), scripted envoys never offered 2; patrons' leverage that bit: 0; exposure now: 
historical: diplomatic decisions 35; Recommended picks by option: { "accept": 14, "meet": 1, "counter": 4, "delay": 2, "decline": 2, "alternative": 5, "cancel": 1, "welcome": 1, "sign": 1, "embrace": 1, "propose_deduction": 1, "bargain": 1, "accept_qme": 1 }; most common 'accept' 40% (V3 bar: at most 45%)
historical: statuses against history: 1635 actor-years checked, 0 off the real timeline

Relations by decade (varied picks; - = not yet a partner):
| Actor | 1950 | 1960 | 1970 | 1980 | 1990 | 2000 | 2010 | 2020 | end |
|---|---|---|---|---|---|---|---|---|---|
| United States | +37 | +31 | +68 | +62 | +45 | +42 | +21 | +57 | +51 |
| Russia | +27 | +17 | -40 | -34 | -28 | +38 | +36 | +42 | +45 |
| France | +24 | +38 | +25 | +34 | +37 | +39 | +39 | +42 | +49 |
| United Kingdom | +29 | +30 | +47 | +37 | +28 | +36 | +33 | +40 | +41 |
| Germany | -1 | +1 | +12 | +14 | +7 | +19 | +9 | +17 | +17 |
| European Union | - | - | +42 | +39 | +26 | +38 | +42 | +34 | +24 |
| United Nations | +37 | +28 | +40 | +22 | +23 | +30 | +29 | +19 | +21 |
| Egypt | -19 | -26 | -88 | +48 | +41 | +52 | +66 | +73 | +68 |
| Jordan | -15 | -18 | -26 | -28 | -26 | +53 | +50 | +48 | +35 |
| Syria | -4 | -16 | -46 | -27 | -25 | -9 | -20 | -26 | -24 |
| Lebanon | -15 | -15 | -42 | -46 | -50 | +12 | -17 | -20 | +14 |
| Iraq | -47 | -38 | -42 | -36 | -35 | -38 | -36 | -35 | -35 |
| Palestine Liberation Organization | - | - | -72 | -78 | -53 | -34 | -36 | -42 | -40 |
| Palestinian Authority | - | - | - | - | - | +4 | +35 | -39 | -38 |
| Turkey | +25 | +28 | +46 | +31 | +23 | +37 | +10 | +33 | +42 |
| Iran (Islamic Republic) | +25 | +37 | +53 | -21 | -25 | -26 | -25 | -44 | -41 |
| Morocco | - | +0 | +0 | +0 | +3 | +5 | +0 | +0 | +9 |
| Sudan | - | +0 | +0 | +0 | +0 | +0 | +0 | +0 | +0 |
| Saudi Arabia | +0 | +0 | +0 | +0 | +0 | +0 | -2 | +0 | +13 |
| United Arab Emirates | - | - | - | +0 | +0 | +0 | +0 | +0 | +3 |
| Bahrain | - | - | - | +0 | +0 | +0 | +0 | +0 | +4 |
| Qatar | - | - | - | +0 | +0 | +5 | -8 | -2 | -1 |
| China (People's Republic) | +10 | +2 | +1 | +0 | +6 | +42 | +38 | +29 | +32 |
| India | +0 | +2 | +0 | +0 | +0 | +28 | +38 | +33 | +30 |
| Hamas | - | - | - | - | -41 | -36 | -95 | -42 | -37 |
| Hezbollah | - | - | - | - | - | -17 | -20 | -20 | -20 |

varied: deals taken 22 (usa_eximbank x2, france_arms x1, periphery x3, germany_loans x3, jordan_channel x4, usa_arms x5, france_mirage x1, iran_flower x1, usa_fta x1, morocco_channel x1, usa_fms x1, china_arms x3, eu_association x4, turkey_military x1, turkey_trade x1, un_weog x1, china_trade x5, india_arms x3, egypt_qiz x1, egypt_gas_import x1, gas_exports x1, russia_deconfliction x1); by kind: { "loan": 5, "arms": 7, "back_channel": 9, "joint": 2, "trade": 14, "aid": 1, "arms_sale": 6, "un_vote": 1 }
varied: envoy answers: usa_eximbank:counter, 1949_zaim:meet, 1955_arms_channel:counter, france_arms:counter, 1958_periphery:decline, 1960_adenauer:decline, 1962_hawk:delay, germany_secret_arms:decline, usa_arms:counter, 1968_phantoms:counter, 1969_soviet_jewry:alternative, 1969_chieftain:counter, 1975_eec_fta:counter, 1977_morocco:alternative, 1980_venice:alternative, 1981_mou:decline, 1986_ifrane:decline, 1987_lavi:build, 1988_plo_dialogue:welcome, 1990_un_3379:alternative, 1994_jordan_terms:reservations, turkey_military:decline, 2000_phalcon:decline, 2002_saudi_plan:embrace, 2003_loan_guarantees:contest, 2007_mou:oppose, 2008_russia_syria:bargain, 2011_turkey_apology:accept, 2013_horizon:delay, 2016_mou:delay, 2019_china_investment:alternative
varied: envoy decisions answered 31 (33 not as history did), scripted envoys never offered 3; patrons' leverage that bit: 11; exposure now: usa 1.8, france 0.0, iran 0.2, west_germany 0.1, china 10.9, turkey 0.4, egypt 0.9, ussr 3.0
varied: diplomatic decisions 33; Recommended picks by option: { "accept": 13, "meet": 1, "counter": 4, "decline": 3, "alternative": 5, "cancel": 1, "welcome": 1, "sign": 1, "embrace": 1, "contest": 1, "bargain": 1, "delay": 1 }; most common 'accept' 39% (V3 bar: at most 45%)
varied: statuses against history: 1636 actor-years checked, 0 off the real timeline

What made the difference (varied picks):
- [cohesion] +97% vs history: the lasting mark of your cabinet's choices, +18% on this track against history's choices (-7% against -25%)
- [cohesion] +97% vs history: your choice "Fund a larger social budget through defence cuts and higher taxes" at "Answering the tent protests" (history: "Adopt the Trajtenberg report, leaving the defence budget largely intact")
- [standing] +62% vs history: your choice "Build the barrier along or close to the Green Line" at "A barrier in the West Bank: where?" (history: "Build a continuous barrier that bulges east to include settlement blocs such as Ariel"), still in force: Settlement blocs and Jerusalem suburbs outside the line need extra cover
- [standing] +62% vs history: National programmes: Water independence: desalination, 6 levels done (history's ghost: 2)
- [water] +52% vs history: your choice "Seek an agreed basin-sharing scheme on the Johnston Plan quotas first" at "Finishing the National Water Carrier" (history: "Finish it at full scale, pumping from the Sea of Galilee"), still in force: Smaller but agreed allocation
- [water] +52% vs history: your choice "Authorise settlement throughout the West Bank" at "Sebastia: the Gush Emunim settlers" (history: "Compromise: allow about 25 families into the Kadum army camp"), still in force: Settlements tap the mountain aquifer
- [science] +51% vs history: your choice "Buy the Northrop Grumman laser system (Nautilus)" at "What shield for the rocket towns?" (history: "Fund Rafael's cheap short-range interceptor (Iron Dome)"), still in force: Directed-energy research base
- [science] +51% vs history: your choice "Allon's first version: a Palestinian autonomous region linked to Israel" at "What to do with the territories" (history: "Keep the Jordan Valley, East Jerusalem and the Etzion bloc; leave the populated hills unannexed pending negotiations"), still in force: Open academic and trade links with Europe and the region

Why they differ (lasting terms in the varied run's stat log):
- Q2 1967 cohesion: New government: 2 ministerial programmes ended
- Q2 1967 standing: The waiting period: Keep waiting for the US-British international flotilla to reopen the Straits - lasting: Standing settles +4 higher, 1967-1985 (Israel seen to have exhausted the international route)
- Q2 1967 economy: The waiting period: Keep waiting for the US-British international flotilla to reopen the Straits - lasting: +3% Production and Gold, 1967-1985 (Western trade, credit and arms ties nurtured)
- Q2 1967 science: The waiting period: Keep waiting for the US-British international flotilla to reopen the Straits - lasting: +2% Science, 1967-1990 (Western academic and research ties deepened)
- Q2 1967 readiness: The waiting period: Keep waiting for the US-British international flotilla to reopen the Straits - lasting: -4 Readiness, 1967-1968 (Egyptian forces left to complete their deployment)
- Q2 1967 economy: The waiting period: Keep waiting for the US-British international flotilla to reopen the Straits - lasting: -3% Production and Gold, 1967 (Open-ended mobilisation)
- Q2 1967 cohesion: The waiting period: Keep waiting for the US-British international flotilla to reopen the Straits - lasting: -2 Cohesion per turn, 1967-1973 (Public anxiety, then doubt about a hesitant leadership)
- Q2 1967 trust: The waiting period: Keep waiting for the US-British international flotilla to reopen the Straits - lasting: Civic Trust settles -3, 1967-1985 (Public lost confidence in a hesitant leadership)
- Q2 1967 population: The waiting period: Keep waiting for the US-British international flotilla to reopen the Straits - lasting: -1% immigrant retention, 1967-1985 (Weeks of dread dent confidence to stay)
- Q2 1967 cohesion: Coalition agreement: Bring in Rafi (Moshe Dayan) (+0.4 Cohesion per turn; +2.0 Readiness; -2.0% Gold; -7 Gold per turn (sector budget); Price: the Defence portfolio)
- Q2 1967 cohesion: Minister promoted: Minister of Construction and Housing, Build-your-own-home plots (+1.0 Housing in the periphery; +0.5 Civic Trust in the periphery)
- Q2 1967 cohesion: Minister promoted: Minister of Health, Emergency medicine and trauma units (-15% war weariness; +0.5 Amenity in the periphery)
- Q3 1967 readiness: Iran (the Shah): The periphery: secret cooperation with Iran and Turkey - lasting: +1 Readiness, 1967-1972 (Periphery intelligence ties)
- Q3 1967 standing: Iran (the Shah): The periphery: secret cooperation with Iran and Turkey - lasting: Standing settles +1 higher, 1967-1971 (Partners beyond the Arab world)

Stat log entries by stat (varied run): { "trust": 558, "readiness": 419, "inflation": 296, "cohesion": 409, "standing": 503, "economy": 145, "science": 28, "population": 37, "water": 3, "gold": 91 }
varied run: 42 same-subject events after non-historical fork picks; 0 without a history-course note or changed outcome
varied run: 0 generic history-course notes, 54 specific consequences applied

Overall: Recommended 151.2%, varied 129.6%, historical picks 103.2%: Recommended ahead of varied by +21.6 points (fix3-econ bar: 15 or more)

### Endings reached (historical, varied, recommended)
| Autoplayer | Ending | Also met | Secure | Prosperous | Peace | United | Overall 1965 | Overall at the end | Programme levels (sec/pros/peace/soc) | Treaties |
|---|---|---|---|---|---|---|---|---|---|---|
| historical | A Mixed Record | - | 3/4 (75%) | 3/5 (90%) | 1/4 (85%) | 1/4 (79%) | 104% | 103% | 7/8/4/3 | 6 |
| varied | A Nation Ahead | - | 2/4 (94%) | 4/5 (91%) | 3/4 (85%) | 3/4 (89%) | 130% | 130% | 12/16/9/7 | 2 |
| recommended | Peace with Neighbours | nation_ahead | 3/4 (97%) | 4/5 (99%) | 4/4 (100%) MET | 3/4 (87%) | 134% | 151% | 12/14/8/7 | 6 |

historical, criteria at the end:
- Secure State: Readiness at the end: 92 (>= 90) ok; Strikes on towns over the whole game, against history's ghost (no more than a tenth above history's): 106% of history (<= 110% of history) ok; Security programmes beyond history's (missile shield, Talpiot, space and cyber: levels and expansions ahead of the ghost; 3 or more): 0 (>= 3) MISSED; International Standing (allies keep backing you): 75 (>= 60) ok
- Prosperous State: Economy (output per capita) against history: 100% of history (>= 125% of history) MISSED; Science against history: 117% of history (>= 115% of history) ok; Inflation at the end: 4.0% (<= 10.0%) ok; Public debt, in years of revenue: 0.0 years (<= 1.5 years) ok; Prosperity programmes beyond history's (start-ups, desalination, gas: levels and expansions ahead of the ghost; 3 or more): 0 (>= 3); or economy at least 145% of history's: 100% of history (>= 145% of history) MISSED
- Peace with Neighbours: States at peace or with normal relations (treaties in force; 5 of the 6 history reached): 6 (>= 5) ok; International Standing at the end: 75 (>= 75) MISSED; Standing against history: 97% of history (>= 130% of history) MISSED; Peace programmes beyond history's (MASHAV, peace dividends: levels and expansions ahead of the ghost; 3 or more): 0 (>= 3); or standing at least 145% of history's: 97% of history (>= 145% of history) MISSED
- United Society: Social cohesion (civic trust) against history: 98% of history (>= 125% of history) MISSED; Lowest civic trust among Arab localities, development towns and the periphery: 81 (>= 75) ok; Residents short of housing: 2.9% (<= 2.0%) MISSED; Society programmes beyond history's (health, Arab-sector plans: levels and expansions ahead of the ghost; 3 or more): 0 (>= 3); or cohesion at least 140% of history's: 98% of history (>= 140% of history) MISSED
- A Nation Ahead: Overall score against history's record (after the state's health): 103% (>= 125%) MISSED; No collapse of the state in sight at the end: 0 (<= 0) ok
epilogue (A Mixed Record): By September 2023 your Israel has a mixed record. Overall, your Israel finished at 103% of history's record (ahead on 2 of 6 tracks; difficulty: Normal). / Of 223 cabinet decisions, you answered 0 differently from history. / Your governments led Israel through 23 wars, operations and crises; enemy strikes hit its towns 91 times (history's ghost by then: 86), and 29 units were lost. Readiness at the end: 92.
track gains from programmes at the end: population +0.0%, economy +13.5%, science +7.0%, water +5.0%, standing +5.0%, cohesion +4.7%; gold spent on programmes 21084
lasting mark of the cabinet's choices against history's at the end: economy +0.0, science -0.0, water -0.0, standing +0.0, cohesion -0.0
fiscal indicator: Debt 0.0 yrs = | Inflation 4% = (ok); food: Food +1289 (self-sufficient), imports 0, exports 0 gold a quarter
collapse (historical, normal): no collapse; fiscal peak 0/12, trust peak 0/12, military peak 0/7; closest: debt/limit 0.95 (Q2 1952), inflation 344% (Q3 1984), trust min 63 (Q1 1952), unrest 47% (Q2 1951), readiness in war 66 (Q2 1948), strikes beyond history in war +15 (Q1 1991)

varied, criteria at the end:
- Secure State: Readiness at the end: 78 (>= 90) MISSED; Strikes on towns over the whole game, against history's ghost (no more than a tenth above history's): 124% of history (<= 110% of history) MISSED; Security programmes beyond history's (missile shield, Talpiot, space and cyber: levels and expansions ahead of the ghost; 3 or more): 5 (>= 3) ok; International Standing (allies keep backing you): 79 (>= 60) ok
- Prosperous State: Economy (output per capita) against history: 66% of history (>= 125% of history) MISSED; Science against history: 151% of history (>= 115% of history) ok; Inflation at the end: 3.7% (<= 10.0%) ok; Public debt, in years of revenue: 0.0 years (<= 1.5 years) ok; Prosperity programmes beyond history's (start-ups, desalination, gas: levels and expansions ahead of the ghost; 3 or more): 8 (>= 3); or economy at least 145% of history's: 66% of history (>= 145% of history) ok
- Peace with Neighbours: States at peace or with normal relations (treaties in force; 5 of the 6 history reached): 2 (>= 5) MISSED; International Standing at the end: 79 (>= 75) ok; Standing against history: 162% of history (>= 130% of history) ok; Peace programmes beyond history's (MASHAV, peace dividends: levels and expansions ahead of the ghost; 3 or more): 5 (>= 3); or standing at least 145% of history's: 162% of history (>= 145% of history) ok
- United Society: Social cohesion (civic trust) against history: 197% of history (>= 125% of history) ok; Lowest civic trust among Arab localities, development towns and the periphery: 83 (>= 75) ok; Residents short of housing: 3.7% (<= 2.0%) MISSED; Society programmes beyond history's (health, Arab-sector plans: levels and expansions ahead of the ghost; 3 or more): 4 (>= 3); or cohesion at least 140% of history's: 197% of history (>= 140% of history) ok
- A Nation Ahead: Overall score against history's record (after the state's health): 130% (>= 125%) ok; No collapse of the state in sight at the end: 0 (<= 0) ok
epilogue (A Nation Ahead): By September 2023 your Israel is A Nation Ahead: well ahead of history's record, though no single path was carried to its end. Overall, your Israel finished at 130% of history's record (ahead on 4 of 6 tracks; difficulty / Of 218 cabinet decisions, you answered 218 differently from history. Still shaping the country in 2023: The Hula: drain it all? (1955): The wetland filters the Jordan's water; Who gets the gas money? (2011): 'Giveaway' a / Your governments led Israel through 22 wars, operations and crises; enemy strikes hit its towns 107 times (history's ghost by then: 86), and 39 units were lost. Readiness at the end: 78.
track gains from programmes at the end: population +0.0%, economy +79.0%, science +43.7%, water +50.0%, standing +79.9%, cohesion +77.6%; gold spent on programmes 59620
lasting mark of the cabinet's choices against history's at the end: economy -22.1, science -1.9, water -1.1, standing -8.1, cohesion +18.0
state's health at the end: State's health 94%: far behind history's record (Economy 66%) -6%.
fiscal indicator: Debt 0.0 yrs = | Inflation 4% = (ok); food: Food +1335 (self-sufficient), imports 0, exports 0 gold a quarter
collapse (varied, normal): no collapse; fiscal peak 0/12, trust peak 0/12, military peak 0/7; closest: debt/limit 1.27 (Q4 1951), inflation 359% (Q3 1984), trust min 69 (Q1 2003), unrest 3% (Q1 1978), readiness in war 39 (Q1 1988), strikes beyond history in war +26 (Q2 2021)

recommended, criteria at the end:
- Secure State: Readiness at the end: 95 (>= 90) ok; Strikes on towns over the whole game, against history's ghost (no more than a tenth above history's): 126% of history (<= 110% of history) MISSED; Security programmes beyond history's (missile shield, Talpiot, space and cyber: levels and expansions ahead of the ghost; 3 or more): 5 (>= 3) ok; International Standing (allies keep backing you): 81 (>= 60) ok
- Prosperous State: Economy (output per capita) against history: 120% of history (>= 125% of history) MISSED; Science against history: 162% of history (>= 115% of history) ok; Inflation at the end: 2.9% (<= 10.0%) ok; Public debt, in years of revenue: 0.0 years (<= 1.5 years) ok; Prosperity programmes beyond history's (start-ups, desalination, gas: levels and expansions ahead of the ghost; 3 or more): 6 (>= 3); or economy at least 145% of history's: 120% of history (>= 145% of history) ok
- Peace with Neighbours: States at peace or with normal relations (treaties in force; 5 of the 6 history reached): 6 (>= 5) ok; International Standing at the end: 81 (>= 75) ok; Standing against history: 197% of history (>= 130% of history) ok; Peace programmes beyond history's (MASHAV, peace dividends: levels and expansions ahead of the ghost; 3 or more): 4 (>= 3); or standing at least 145% of history's: 197% of history (>= 145% of history) ok
- United Society: Social cohesion (civic trust) against history: >200% of history (>= 125% of history) ok; Lowest civic trust among Arab localities, development towns and the periphery: 85 (>= 75) ok; Residents short of housing: 4.3% (<= 2.0%) MISSED; Society programmes beyond history's (health, Arab-sector plans: levels and expansions ahead of the ghost; 3 or more): 4 (>= 3); or cohesion at least 140% of history's: >200% of history (>= 140% of history) ok
- A Nation Ahead: Overall score against history's record (after the state's health): 151% (>= 125%) ok; No collapse of the state in sight at the end: 0 (<= 0) ok
epilogue (Peace with Neighbours): By September 2023 your Israel is at Peace with its Neighbours: its treaties hold, and its standing abroad is far above history's. It also met the thresholds of A Nation Ahead. Overall, your Israel finished at 151% of his / Of 218 cabinet decisions, you answered 97 differently from history. Still shaping the country in 2023: What to do with the territories (1967): Aquifer shared with the autonomous area; Olmert's offer to Abbas, or an econo / Your governments led Israel through 23 wars, operations and crises; enemy strikes hit its towns 108 times (history's ghost by then: 86), and 31 units were lost. Readiness at the end: 95.
track gains from programmes at the end: population +0.0%, economy +74.8%, science +42.6%, water +38.8%, standing +53.4%, cohesion +77.7%; gold spent on programmes 66205
lasting mark of the cabinet's choices against history's at the end: economy -13.3, science +5.1, water -5.2, standing +27.2, cohesion +54.4
fiscal indicator: Debt 0.0 yrs = | Inflation 3% = (ok); food: Food +1341 (self-sufficient), imports 0, exports 0 gold a quarter
collapse (recommended, normal): no collapse; fiscal peak 0/12, trust peak 0/12, military peak 0/7; closest: debt/limit 0.52 (Q4 1951), inflation 316% (Q3 1984), trust min 70 (Q4 1950), unrest 0% (Q3 2004), readiness in war 45 (Q2 1967), strikes beyond history in war +27 (Q2 2021)

### The arc per decade: overall score vs the ghost (historical, varied, recommended)
| Autoplayer | 1955 | 1965 | 1975 | 1985 | 1995 | 2005 | 2015 | 2020 | end | end vs 1965 |
|---|---|---|---|---|---|---|---|---|---|---|
| historical | 107% | 104% | 109% | 106% | 108% | 106% | 107% | 106% | 103% | -1.3 |
| varied | 117% | 130% | 122% | 126% | 118% | 120% | 140% | 141% | 138% | +8.2 |
| recommended | 116% | 134% | 129% | 140% | 138% | 140% | 153% | 151% | 152% | +17.6 |

### Fiscal indicator tiers (quarters at each level)
- historical: { "ok": 292, "watch": 10, "warning": 0, "danger": 0 } of 302 quarters; structural-deficit alarm in 0 quarters (first never, peak ratio 1.73); levers used {  }
  - varied warning/danger quarters: Q2 1949 warning (structural deficit, inflation above history's, treasury below zero for 3 quarters); Q3 1949 warning (structural deficit, treasury below zero for 4 quarters); Q4 1949 warning (structural deficit, treasury below zero for 5 quarters); Q1 1950 warning (structural deficit, treasury below zero for 6 quarters); Q2 1950 warning (structural deficit, treasury below zero for 7 quarters); Q3 1950 warning (structural deficit, treasury below zero for 8 quarters, debt near the lenders' limit); Q4 1950 warning (structural deficit, treasury below zero for 9 quarters, debt near the lenders' limit); Q1 1951 warning (structural deficit, treasury below zero for 10 quarters, debt near the lenders' limit)
- varied: { "ok": 265, "watch": 13, "warning": 24, "danger": 0 } of 302 quarters; structural-deficit alarm in 23 quarters (first Q1 1949, peak ratio 2.99); levers used { "stabilise": 1, "mothball": 132, "privatise": 2, "reopen": 42, "policy_cut": 1 }
- recommended: { "ok": 294, "watch": 8, "warning": 0, "danger": 0 } of 302 quarters; structural-deficit alarm in 0 quarters (first never, peak ratio 1.72); levers used {  }

### Inflation with history's choices against history's CPI
- Q2 1967 2.0% (history 2.5%); Q4 1967 0.2% (history 1.8%); Q2 1968 0.4% (history 2.0%); Q1 1984 228.0% (history 288.0%); Q3 1984 325.2% (history 365.0%); Q1 1985 325.2% (history 332.0%); Q2 1985 302.2% (history 315.5%)
