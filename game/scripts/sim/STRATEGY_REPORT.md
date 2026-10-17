# Israel: The Birth of a Nation - simulation autoplay report

Run: 2026-10-16T13:50:40, seed 1948, Godot 4.7.1-stable (official)

## Data
techs 47, civics 43, policies 47, districts 15, buildings 53, national projects 10, units 23
cities.json 119 places, events.json 319 events, map 7904 tiles, 16 border eras, SOURCES ids 2011
forks 223 (in game/data/forks/), wars 23 (in game/data/wars/)
fork consequence check: 46 same-subject fork/event pairs; 0 uncovered non-historical answers
generic history-course fallbacks: 0 (fork answer -> event pairs with no specific outcome; at most 5 allowed)
leak scan (nothing dated after Q3 2023 visible): 0 hits; cities 0, trees 0, programmes 0, events 0, wars 0, cabinet and series 0, forks 0, choice terms 0, diplomacy 0, deal end dates 0
deleted-content scan (nothing after Q3 2023 in the data; 64 tombstoned ids): 0 hits; content and helpers 0, load-time scrub 0, data files 0, Hebrew catalogs 0

API smoke test: 24 queries and the main actions OK (Q2 1949)

## Strategy report (historical, varied and four strategists, to Q3 2023)
- historical: overall 103.2% at Q3 2023, ending A Mixed Record (0 errors)
- varied: overall 129.6% at Q3 2023, ending A Nation Ahead (0 errors)
- strategist_security: overall 146.8% at Q3 2023, ending Secure State (0 errors)
- strategist_prosperity: overall 138.8% at Q3 2023, ending Prosperous State (0 errors)
- strategist_peace: overall 139.1% at Q3 2023, ending Peace with Neighbours (0 errors)
- strategist_society: overall 121.5% at Q3 2023, ending United Society (0 errors)

### Final tracks vs the ghost
| Autoplayer | Overall | population | economy | science | water | standing | cohesion |
|---|---|---|---|---|---|---|---|
| historical | 103.2% | 1.00 | 1.00 | 1.17 | 1.06 | 0.97 | 0.98 |
| varied | 129.6% | 1.01 | 0.66 | 1.51 | 1.52 | 1.62 | 1.97 |
| strategist_security | 146.8% | 1.00 | 1.16 | 1.82 | 1.25 | 1.58 | 2.09 |
| strategist_prosperity | 138.8% | 0.97 | 1.52 | 1.51 | 1.63 | 1.66 | 1.03 |
| strategist_peace | 139.1% | 0.99 | 1.03 | 1.33 | 1.23 | 2.60 | 1.76 |
| strategist_society | 121.5% | 1.06 | 0.83 | 1.19 | 1.14 | 1.19 | 3.24 |

### Endings reached (historical, varied, strategist_security, strategist_prosperity, strategist_peace, strategist_society)
| Autoplayer | Ending | Also met | Secure | Prosperous | Peace | United | Overall 1965 | Overall at the end | Programme levels (sec/pros/peace/soc) | Treaties |
|---|---|---|---|---|---|---|---|---|---|---|
| historical | A Mixed Record | - | 3/4 (75%) | 3/5 (90%) | 1/4 (85%) | 1/4 (79%) | 104% | 103% | 7/8/4/3 | 6 |
| varied | A Nation Ahead | - | 2/4 (94%) | 4/5 (91%) | 3/4 (85%) | 3/4 (89%) | 130% | 130% | 12/16/9/7 | 2 |
| strategist_security | Secure State | peace_with_neighbours, united_society, nation_ahead | 4/4 (100%) MET | 4/5 (99%) | 4/4 (100%) MET | 4/4 (100%) MET | 128% | 147% | 15/13/5/5 | 6 |
| strategist_prosperity | Prosperous State | peace_with_neighbours, nation_ahead | 1/4 (87%) | 5/5 (100%) MET | 4/4 (100%) MET | 1/4 (80%) | 128% | 139% | 9/19/5/4 | 6 |
| strategist_peace | Peace with Neighbours | nation_ahead | 1/4 (89%) | 4/5 (96%) | 4/4 (100%) MET | 3/4 (92%) | 134% | 139% | 9/12/12/5 | 6 |
| strategist_society | United Society | - | 1/4 (81%) | 4/5 (93%) | 2/4 (93%) | 4/4 (100%) MET | 116% | 122% | 8/11/5/10 | 6 |

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

strategist_security, criteria at the end:
- Secure State: Readiness at the end: 98 (>= 90) ok; Strikes on towns over the whole game, against history's ghost (no more than a tenth above history's): 73% of history (<= 110% of history) ok; Security programmes beyond history's (missile shield, Talpiot, space and cyber: levels and expansions ahead of the ghost; 3 or more): 8 (>= 3) ok; International Standing (allies keep backing you): 82 (>= 60) ok
- Prosperous State: Economy (output per capita) against history: 116% of history (>= 125% of history) MISSED; Science against history: 182% of history (>= 115% of history) ok; Inflation at the end: 3.1% (<= 10.0%) ok; Public debt, in years of revenue: 0.0 years (<= 1.5 years) ok; Prosperity programmes beyond history's (start-ups, desalination, gas: levels and expansions ahead of the ghost; 3 or more): 5 (>= 3); or economy at least 145% of history's: 116% of history (>= 145% of history) ok
- Peace with Neighbours: States at peace or with normal relations (treaties in force; 5 of the 6 history reached): 6 (>= 5) ok; International Standing at the end: 82 (>= 75) ok; Standing against history: 158% of history (>= 130% of history) ok; Peace programmes beyond history's (MASHAV, peace dividends: levels and expansions ahead of the ghost; 3 or more): 1 (>= 3); or standing at least 145% of history's: 158% of history (>= 145% of history) ok
- United Society: Social cohesion (civic trust) against history: >200% of history (>= 125% of history) ok; Lowest civic trust among Arab localities, development towns and the periphery: 85 (>= 75) ok; Residents short of housing: 1.6% (<= 2.0%) ok; Society programmes beyond history's (health, Arab-sector plans: levels and expansions ahead of the ghost; 3 or more): 2 (>= 3); or cohesion at least 140% of history's: >200% of history (>= 140% of history) ok
- A Nation Ahead: Overall score against history's record (after the state's health): 147% (>= 125%) ok; No collapse of the state in sight at the end: 0 (<= 0) ok
epilogue (Secure State): By September 2023 your Israel is a Secure State. It also met the thresholds of Peace with Neighbours, United Society, A Nation Ahead. Overall, your Israel finished at 147% of history's record (ahead on 5 of 6 tracks; dif / Of 218 cabinet decisions, you answered 93 differently from history. Still shaping the country in 2023: What to do with the territories (1967): Aquifer shared with the autonomous area; Olmert's offer to Abbas, or an econo / Your governments led Israel through 23 wars, operations and crises; enemy strikes hit its towns 63 times (history's ghost by then: 86), and 21 units were lost. Readiness at the end: 98.
track gains from programmes at the end: population +0.0%, economy +57.8%, science +55.7%, water +35.7%, standing +22.5%, cohesion +58.9%; gold spent on programmes 70357
lasting mark of the cabinet's choices against history's at the end: economy -12.2, science +6.0, water -7.2, standing +27.7, cohesion +39.2
fiscal indicator: Debt 0.0 yrs = | Inflation 3% = (ok); food: Food +1301 (self-sufficient), imports 0, exports 0 gold a quarter
collapse (strategist_security, normal): no collapse; fiscal peak 0/12, trust peak 0/12, military peak 0/7; closest: debt/limit 0.52 (Q4 1951), inflation 330% (Q3 1984), trust min 69 (Q4 1952), unrest 3% (Q2 1984), readiness in war 66 (Q2 1948), strikes beyond history in war +8 (Q1 1949)

strategist_prosperity, criteria at the end:
- Secure State: Readiness at the end: 83 (>= 90) MISSED; Strikes on towns over the whole game, against history's ghost (no more than a tenth above history's): 121% of history (<= 110% of history) MISSED; Security programmes beyond history's (missile shield, Talpiot, space and cyber: levels and expansions ahead of the ghost; 3 or more): 2 (>= 3) MISSED; International Standing (allies keep backing you): 81 (>= 60) ok
- Prosperous State: Economy (output per capita) against history: 152% of history (>= 125% of history) ok; Science against history: 151% of history (>= 115% of history) ok; Inflation at the end: 3.2% (<= 10.0%) ok; Public debt, in years of revenue: 0.0 years (<= 1.5 years) ok; Prosperity programmes beyond history's (start-ups, desalination, gas: levels and expansions ahead of the ghost; 3 or more): 11 (>= 3); or economy at least 145% of history's: 152% of history (>= 145% of history) ok
- Peace with Neighbours: States at peace or with normal relations (treaties in force; 5 of the 6 history reached): 6 (>= 5) ok; International Standing at the end: 81 (>= 75) ok; Standing against history: 166% of history (>= 130% of history) ok; Peace programmes beyond history's (MASHAV, peace dividends: levels and expansions ahead of the ghost; 3 or more): 1 (>= 3); or standing at least 145% of history's: 166% of history (>= 145% of history) ok
- United Society: Social cohesion (civic trust) against history: 103% of history (>= 125% of history) MISSED; Lowest civic trust among Arab localities, development towns and the periphery: 82 (>= 75) ok; Residents short of housing: 3.1% (<= 2.0%) MISSED; Society programmes beyond history's (health, Arab-sector plans: levels and expansions ahead of the ghost; 3 or more): 1 (>= 3); or cohesion at least 140% of history's: 103% of history (>= 140% of history) MISSED
- A Nation Ahead: Overall score against history's record (after the state's health): 139% (>= 125%) ok; No collapse of the state in sight at the end: 0 (<= 0) ok
epilogue (Prosperous State): By September 2023 your Israel is a Prosperous State. It also met the thresholds of Peace with Neighbours, A Nation Ahead. Overall, your Israel finished at 139% of history's record (ahead on 5 of 6 tracks; difficulty: Nor / Of 221 cabinet decisions, you answered 94 differently from history. Still shaping the country in 2023: What to do with the territories (1967): Aquifer shared with the autonomous area; Who investigates the flotilla raid?  / Your governments led Israel through 22 wars, operations and crises; enemy strikes hit its towns 104 times (history's ghost by then: 86), and 35 units were lost. Readiness at the end: 83.
track gains from programmes at the end: population +0.0%, economy +77.6%, science +31.4%, water +61.9%, standing +28.9%, cohesion +24.6%; gold spent on programmes 77828
lasting mark of the cabinet's choices against history's at the end: economy +7.5, science +6.7, water -3.6, standing +28.1, cohesion -7.6
fiscal indicator: Debt 0.0 yrs = | Inflation 3% = (ok); food: Food +1185 (self-sufficient), imports 0, exports 0 gold a quarter
collapse (strategist_prosperity, normal): no collapse; fiscal peak 0/12, trust peak 0/12, military peak 0/7; closest: debt/limit 0.45 (Q4 1951), inflation 290% (Q3 1984), trust min 63 (Q4 1985), unrest 7% (Q4 2004), readiness in war 57 (Q2 1967), strikes beyond history in war +24 (Q1 2009)

strategist_peace, criteria at the end:
- Secure State: Readiness at the end: 86 (>= 90) MISSED; Strikes on towns over the whole game, against history's ghost (no more than a tenth above history's): 115% of history (<= 110% of history) MISSED; Security programmes beyond history's (missile shield, Talpiot, space and cyber: levels and expansions ahead of the ghost; 3 or more): 2 (>= 3) MISSED; International Standing (allies keep backing you): 85 (>= 60) ok
- Prosperous State: Economy (output per capita) against history: 103% of history (>= 125% of history) MISSED; Science against history: 133% of history (>= 115% of history) ok; Inflation at the end: 3.7% (<= 10.0%) ok; Public debt, in years of revenue: 0.0 years (<= 1.5 years) ok; Prosperity programmes beyond history's (start-ups, desalination, gas: levels and expansions ahead of the ghost; 3 or more): 4 (>= 3); or economy at least 145% of history's: 103% of history (>= 145% of history) ok
- Peace with Neighbours: States at peace or with normal relations (treaties in force; 5 of the 6 history reached): 6 (>= 5) ok; International Standing at the end: 85 (>= 75) ok; Standing against history: >200% of history (>= 130% of history) ok; Peace programmes beyond history's (MASHAV, peace dividends: levels and expansions ahead of the ghost; 3 or more): 8 (>= 3); or standing at least 145% of history's: >200% of history (>= 145% of history) ok
- United Society: Social cohesion (civic trust) against history: 176% of history (>= 125% of history) ok; Lowest civic trust among Arab localities, development towns and the periphery: 84 (>= 75) ok; Residents short of housing: 3.0% (<= 2.0%) MISSED; Society programmes beyond history's (health, Arab-sector plans: levels and expansions ahead of the ghost; 3 or more): 2 (>= 3); or cohesion at least 140% of history's: 176% of history (>= 140% of history) ok
- A Nation Ahead: Overall score against history's record (after the state's health): 139% (>= 125%) ok; No collapse of the state in sight at the end: 0 (<= 0) ok
epilogue (Peace with Neighbours): By September 2023 your Israel is at Peace with its Neighbours: its treaties hold, and its standing abroad is far above history's. It also met the thresholds of A Nation Ahead. Overall, your Israel finished at 139% of his / Of 217 cabinet decisions, you answered 125 differently from history. Still shaping the country in 2023: Finishing the National Water Carrier (1959): Smaller but agreed allocation; Answering the Goldstone report (2009): P / Your governments led Israel through 22 wars, operations and crises; enemy strikes hit its towns 99 times (history's ghost by then: 86), and 37 units were lost. Readiness at the end: 86.
track gains from programmes at the end: population +0.0%, economy +36.3%, science +17.4%, water +35.7%, standing +91.4%, cohesion +40.2%; gold spent on programmes 70246
lasting mark of the cabinet's choices against history's at the end: economy -9.2, science +5.1, water -8.6, standing +29.3, cohesion +30.9
fiscal indicator: Debt 0.0 yrs = | Inflation 4% = (ok); food: Food +1307 (self-sufficient), imports 0, exports 0 gold a quarter
collapse (strategist_peace, normal): no collapse; fiscal peak 0/12, trust peak 0/12, military peak 0/7; closest: debt/limit 0.48 (Q4 1951), inflation 308% (Q3 1984), trust min 68 (Q4 2004), unrest 7% (Q4 2004), readiness in war 36 (Q2 1967), strikes beyond history in war +18 (Q2 2021)

strategist_society, criteria at the end:
- Secure State: Readiness at the end: 90 (>= 90) MISSED; Strikes on towns over the whole game, against history's ghost (no more than a tenth above history's): 122% of history (<= 110% of history) MISSED; Security programmes beyond history's (missile shield, Talpiot, space and cyber: levels and expansions ahead of the ghost; 3 or more): 1 (>= 3) MISSED; International Standing (allies keep backing you): 80 (>= 60) ok
- Prosperous State: Economy (output per capita) against history: 83% of history (>= 125% of history) MISSED; Science against history: 119% of history (>= 115% of history) ok; Inflation at the end: 6.0% (<= 10.0%) ok; Public debt, in years of revenue: 0.0 years (<= 1.5 years) ok; Prosperity programmes beyond history's (start-ups, desalination, gas: levels and expansions ahead of the ghost; 3 or more): 3 (>= 3); or economy at least 145% of history's: 83% of history (>= 145% of history) ok
- Peace with Neighbours: States at peace or with normal relations (treaties in force; 5 of the 6 history reached): 6 (>= 5) ok; International Standing at the end: 80 (>= 75) ok; Standing against history: 119% of history (>= 130% of history) MISSED; Peace programmes beyond history's (MASHAV, peace dividends: levels and expansions ahead of the ghost; 3 or more): 1 (>= 3); or standing at least 145% of history's: 119% of history (>= 145% of history) MISSED
- United Society: Social cohesion (civic trust) against history: >200% of history (>= 125% of history) ok; Lowest civic trust among Arab localities, development towns and the periphery: 98 (>= 75) ok; Residents short of housing: 0.8% (<= 2.0%) ok; Society programmes beyond history's (health, Arab-sector plans: levels and expansions ahead of the ghost; 3 or more): 7 (>= 3); or cohesion at least 140% of history's: >200% of history (>= 140% of history) ok
- A Nation Ahead: Overall score against history's record (after the state's health): 122% (>= 125%) MISSED; No collapse of the state in sight at the end: 0 (<= 0) ok
epilogue (United Society): By September 2023 your Israel is a United Society. Overall, your Israel finished at 122% of history's record (ahead on 5 of 6 tracks; difficulty: Normal). / Of 218 cabinet decisions, you answered 124 differently from history. Still shaping the country in 2023: What to do with the territories (1967): Aquifer shared with the autonomous area; Answering the Goldstone report (200 / Your governments led Israel through 23 wars, operations and crises; enemy strikes hit its towns 105 times (history's ghost by then: 86), and 31 units were lost. Readiness at the end: 90.
track gains from programmes at the end: population +0.0%, economy +31.0%, science +7.0%, water +17.5%, standing +22.3%, cohesion +87.0%; gold spent on programmes 72197
lasting mark of the cabinet's choices against history's at the end: economy -32.7, science -4.3, water -5.2, standing -1.9, cohesion +60.2
state's health at the end: State's health 98%: far behind history's record (Economy 83%) -2%.
fiscal indicator: Debt 0.0 yrs = | Inflation 6% = (ok); food: Food +1316 (self-sufficient), imports 0, exports 0 gold a quarter
collapse (strategist_society, normal): no collapse; fiscal peak 0/12, trust peak 0/12, military peak 0/7; closest: debt/limit 0.56 (Q1 1952), inflation 355% (Q3 1984), trust min 72 (Q4 1950), unrest 4% (Q3 1961), readiness in war 48 (Q2 1967), strikes beyond history in war +24 (Q2 2021)

### The arc per decade: overall score vs the ghost (historical, varied, strategist_security, strategist_prosperity, strategist_peace, strategist_society)
| Autoplayer | 1955 | 1965 | 1975 | 1985 | 1995 | 2005 | 2015 | 2020 | end | end vs 1965 |
|---|---|---|---|---|---|---|---|---|---|---|
| historical | 107% | 104% | 109% | 106% | 108% | 106% | 107% | 106% | 103% | -1.3 |
| varied | 117% | 130% | 122% | 126% | 118% | 120% | 140% | 141% | 138% | +8.2 |
| strategist_security | 116% | 128% | 124% | 133% | 139% | 137% | 149% | 148% | 147% | +19.5 |
| strategist_prosperity | 117% | 128% | 125% | 125% | 129% | 120% | 139% | 139% | 139% | +11.5 |
| strategist_peace | 122% | 134% | 124% | 125% | 126% | 124% | 139% | 138% | 139% | +5.2 |
| strategist_society | 114% | 116% | 120% | 132% | 125% | 117% | 127% | 126% | 124% | +7.5 |

Overall spread: historical 103.2 vs varied 129.6 (+26.4); widest strategist_security 146.8 vs historical 103.2 (+43.7)
strategist_security: 1965 128%, at the end 147% (+19.5)
strategist_prosperity: 1965 128%, at the end 139% (+11.5)
strategist_peace: 1965 134%, at the end 139% (+5.2)
strategist_society: 1965 116%, at the end 124% (+7.5)
endings reached: historical=mixed_record, varied=nation_ahead, strategist_security=secure_state, strategist_prosperity=prosperous_state, strategist_peace=peace_with_neighbours, strategist_society=united_society (6 distinct)
historical: best on 0 of 6 tracks; reaches no ending
varied: best on 0 of 6 tracks; reaches nation_ahead
strategist_security: best on 1 of 6 tracks; reaches secure_state, peace_with_neighbours, united_society, nation_ahead
strategist_prosperity: best on 2 of 6 tracks; reaches prosperous_state, peace_with_neighbours, nation_ahead
strategist_peace: best on 1 of 6 tracks; reaches peace_with_neighbours, nation_ahead
strategist_society: best on 2 of 6 tracks; reaches united_society

## Result
elapsed 2283.9 s, failures 0
ALL INVARIANTS PASSED
