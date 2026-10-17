# Israel: The Birth of a Nation - simulation autoplay report

Run: 2026-10-14T23:30:43, seed 1948, Godot 4.7.1-stable (official)

## Data
techs 47, civics 43, policies 47, districts 15, buildings 53, national projects 10, units 23
cities.json 119 places, events.json 319 events, map 7904 tiles, 16 border eras, SOURCES ids 2009
forks 223 (in game/data/forks/), wars 23 (in game/data/wars/)
fork consequence check: 46 same-subject fork/event pairs; 0 uncovered non-historical answers
generic history-course fallbacks: 0 (fork answer -> event pairs with no specific outcome; at most 5 allowed)
leak scan (nothing dated after Q3 2023 visible): 0 hits; cities 0, trees 0, programmes 0, events 0, wars 0, cabinet and series 0, forks 0, choice terms 0, diplomacy 0, deal end dates 0
deleted-content scan (nothing after Q3 2023 in the data; 64 tombstoned ids): 0 hits; content and helpers 0, load-time scrub 0, data files 0, Hebrew catalogs 0

API smoke test: 24 queries and the main actions OK (Q2 1949)

## Collapse report (soft fail states, v3 item 13)

### ruin_fiscal -> no collapse
- ended Q3 2023 (turn 302); first warning of collapse_fiscal: Q2 1958; quarters of warning: 261; peaks: fiscal 4/12, trust 0/12, military 0/7
- ending: A Mixed Record; memorial shown: yes; end screen ending id: mixed_record
- recovery test (the Recommended player takes over at the first warning): recovered: the danger cleared in Q4 1951, 1 quarters after the warning (peak strain 2)
  - [ending] A Mixed Record: By September 2023 your Israel has a mixed record. Overall, your Israel finished at 96% of history's record (ahead on 4 of 6 tracks; difficulty: Normal).
  - [forks] Your choices: Of 221 cabinet decisions, you answered 85 differently from history. Still shaping the country in 2023: The Hula: drain it all? (1955): The wetland filters the Jordan's water; Answering the tent protests (2011): Higher taxes dampen investment and hiring; Rules of fire on the Gaza fence (2018): Tighter rules at the fence leave less room to deter breaches; The Red Line on Shabbat (2023): Seven-day ridership.
  - [wars] Wars and security: Your governments led Israel through 23 wars, operations and crises; enemy strikes hit its towns 105 times (history's ghost by then: 86), and 36 units were lost. Readiness at the end: 74.
  - [budgets] State Budgets: Across 75 Budget Laws your priorities were: balanced in 26, development and water first in 16, absorption and housing first in 12.
  - [diplomacy] Neighbours and allies: Treaties in force at the end: Bahrain, Egypt, Jordan, Morocco, Sudan, United Arab Emirates. International Standing 79. Relations with the United States: 69.
  - [programmes] National programmes: Completed: MASHAV: international development cooperation (1 level, expanded 1 times); Talpiot: the army's science and technology programme (1 level); The start-up economy (3 levels); Space and cyber (3 levels); The missile shield (1 level); Water independence: desalination (4 levels); The gas fields (3 levels); Peace dividends (3 levels); Development plans for Arab localities (2 levels, expanded 1 times); Universal health care (1 level).
  - [money] Money: The treasury ends at 780 gold; public debt 21k (3.2 years of revenue); inflation 9.5% (history: 4.2%). Over the game you borrowed 60k gold and paid 34k in interest.
  - [close] Each named ending was within reach of a different set of choices; the progress lines below show how close each came.
collapse (ruin_fiscal, normal): no collapse; fiscal peak 4/12, trust peak 0/12, military peak 0/7; closest: debt/limit 1.75 (Q4 1951), inflation 557% (Q3 1984), trust min 54 (Q4 2004), unrest 36% (Q2 1951), readiness in war 54 (Q2 1967), strikes beyond history in war +24 (Q2 2021)
FAIL: collapse report: ruin_fiscal should reach collapse_fiscal, got no collapse (Q3 2023)
FAIL: collapse report: the 7 October memorial is attached to a collapse ending (ruin_fiscal)

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
- the populist alone: no collapse (Q1 1970); first structural alarm Q1 1950 (overall 112% at the end of the run); costly policy cards at the alarm 0 gold a quarter
- the alarm: Revenue 100 (taxes 100) against outflows 183, 182% of it: running costs 61 (buildings 4, public services 44, districts 4, units 9); absorption 100; lasting terms 15 (Defence budget and war debts after 1948 15); debt service 7. Highest upkeep: Rehovot 2, Haifa 2, Tel Aviv 2, Jerusalem 2, Degania Alef 0.
collapse (ruin_populist, normal): no collapse; fiscal peak 0/12, trust peak 0/12, military peak 0/7; closest: debt/limit 1.26 (Q4 1951), inflation 45% (Q3 1969), trust min 74 (Q3 1948), unrest 0% (Q2 1948), readiness in war 37 (Q2 1967), strikes beyond history in war +18 (Q4 1969)
- Recommended from the populist's first structural alarm (Q1 1950): no collapse at Q1 1970 (80 quarters); strain peaks fiscal 0, trust 0, military 0; structural alarm on in 8 quarters, cleared at the end; overall 129.1%; levers used { "mothball": 4, "privatise": 1, "stabilise": 1, "reopen": 4 }; cards {  }
collapse (recommended after the populist, normal): no collapse; fiscal peak 0/12, trust peak 0/12, military peak 0/7; closest: debt/limit 0.73 (Q4 1951), inflation 20% (Q3 1966), trust min 72 (Q4 1950), unrest 0% (Q2 1948), readiness in war 46 (Q4 1948), strikes beyond history in war +16 (Q4 1969)

## Result
elapsed 1555.4 s, failures 2
- collapse report: ruin_fiscal should reach collapse_fiscal, got no collapse (Q3 2023)
- collapse report: the 7 October memorial is attached to a collapse ending (ruin_fiscal)
