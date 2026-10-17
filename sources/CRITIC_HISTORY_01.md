# CRITIC_HISTORY_01 — audit of events.json, cities.json and SOURCES.md

Critic run on 2026-10-11. Files audited: `game/data/events.json` (320 events), `game/data/cities.json` (117 localities) and `sources/SOURCES.md` (370 sources). No data files were edited.

**The bar:** the published sources themselves. Each claim was checked against the cited URL where it could be opened, and otherwise against an equivalent authoritative source (UN/OCHA, CBS archived files, IDI, Nobel, HRW, JVL, Avalon, ToI/Globes/AP/Al Jazeera, CFR, and so on). English Wikipedia was used only to cross-check or to find the underlying source.

## Method

**Event sample.** 52 events were drawn by stratified, weighted random selection (seed 20261011):

| Era | Events sampled |
|---|---|
| 1948–66 | 11 |
| 1967–86 | 11 |
| 1987–2008 | 12 |
| 2009–2026 | 18 |

Selection weight rose with the number of figures in the summary (×1 to ×5), was multiplied by 1.6 for 2018 and later, and by a further 1.4 for 2023 and later. Each event was checked on date, places, every number, the summary wording, whether the cited source supports it, and neutrality.

**City sample.** 15 localities were drawn at random (seed 1511), stratified as:

- 7 Jewish towns, cities or kibbutzim
- 4 Arab, Bedouin or Syrian localities
- 2 Palestinian cities
- 2 settlements

Each was checked on lat/lon (against an independent point), founding date, census figures (all CBS years, opened via web.archive.org copies of the cited xls/xlsx files) and the status timeline.

**Choices.** 16 of the 43 events with choices were sampled at random (seed 77), giving 38 options, 22 of them non-historical.

**Omissions.** The whole of events.json was scanned for keywords covering about 60 candidate events.

**Limits.** The verifiers shared one web-search quota, which ran out partway through. The rest of the checking was done by fetching pages directly. Some cited pages could not be fetched (403 errors or paywalls); these are graded UNSUPPORTED *as cited*, and the table says when the claim itself was confirmed elsewhere.

## Verdict totals

| Scope | Checks | CORRECT | WRONG | UNSUPPORTED | BIASED |
|---|---|---|---|---|---|
| Events (52) | 311 | 258 | 10 | 29 | 14 |
| Cities (15) | 79 (+2 n/a) | 71 | 6 | 0 | 2 |
| Choice options (38) | 38 | 30 (15 real-debated + 15 historical accurate) | 1 (historical option mislabelled) | 7 (plausible but unsourced) | 1 (+1 false either/or noted) |
| **Total** | **428** | **359** | **17** | **36** | **17** |

**What the event UNSUPPORTED count is made of.** Of the 29, only 6 are claims that no source supports, or that are overstated:

- the 1948 split of 4,000 soldiers and 2,400 civilians;
- "UNEF guaranteeing passage" through Tiran in 1957;
- ">14,000 PLO fighters" evacuated in 1982;
- ">150 killed" in Operation Accountability, 1993;
- "Shamgar found no conspiracy", 1995;
- the AFP tally of 1,218 for 7 October.

The other 23 are citation failures: the claim is true, but the cited source is dead, cannot be opened, or does not contain it.

**How many events have problems.**

- 23 of the 52 sampled events (44%) have at least one cited source that does not back the claim as cited.
- 14 of the 52 (27%) have a neutrality problem. Almost every one omits casualties or displacement suffered by the *other* party, in both directions:
  - **Arab or Palestinian victims omitted:** 1956 Gaza civilians, Kafr Qasim accountability, Najd/Sderot, Abu Jihad bystanders, the Or Commission's discrimination finding, vaccine access for Palestinians.
  - **Israeli victims omitted:** War of Attrition civilians, Accountability 1993 rocket deaths, the 2006 displacement of 300–500k northern Israelis, the Bedouin girl wounded in April 2024.

## Compact list of WRONG / UNSUPPORTED (claim-level) / BIASED

### WRONG

| # | Item | Problem |
|---|---|---|
| 1 | evt_1957_sinai_withdrawal | effects `diplo.un: relations_established`. Israel has been a UN member since 11 May 1949. |
| 2 | evt_1980_egypt_ambassadors | Full relations were established on 26 Jan 1980, not February. Only the ambassadors were exchanged in February. |
| 3 | evt_1998_mirabilis_icq | "Five young Israelis": there were four young founders, plus Yossi Vardi as investor. |
| 4 | evt_2018_great_march_of_return | date_end 2019-03-31 is OCHA's reporting cut-off. The weekly protests ran until 27 Dec 2019. |
| 5 | evt_2020_vaccination_campaign | "Pfizer and Moderna doses": the campaign launched on Pfizer only. Moderna arrived on 7 Jan 2021 and was used marginally. |
| 6 | evt_2021_bennett_lapid_government | Ra'am was the "first *independent* Arab party" in a coalition, not the first Arab party. Mapai-affiliated Arab lists sat in 1950s–70s coalitions. |
| 7 | evt_2026_last_hostage_returned | Ran Gvili is called a "Border Police officer". Most reporting places him in the Negev Yasam police unit; the sources conflict. |
| 8 | evt_2026_iran_war | effects `israel_civilians` killed [20,24]: the upper bound adds 4 West Bank Palestinians. |
| 9 | evt_2026_iran_war | effects `iran` killed [1701,1701]: that is HRANA's civilian-only count. Total Iranian dead were about 3,500–3,700. |
| 10 | evt_2026_lebanon_war | effects `diplo.lebanon: war`. The Lebanese state condemned Hezbollah, banned its armed activity and opened direct talks with Israel; it was not a belligerent. |
| 11 | cities: yad_mordechai | The status timeline omits Egyptian control from 24 May to 5 Nov 1948. |
| 12 | cities: hura | `founded: null`, but the township was established in 1989. |
| 13 | cities: hura | Status "israel from 1995" uses the census-listing date, not the date of control or founding. |
| 14 | cities: quneitra | Status is still `syria_un_buffer` although Israeli forces have held the area since Dec 2024 (mentioned only in a note). |
| 15 | cities: tulkarm | 1948–49 is attributed to the Arab Legion; the Iraqi army held it until the spring 1949 handover. |
| 16 | cities: tulkarm | The open-ended "Area A" status omits the 2002 reoccupation and Operation Iron Wall (2025–, camps emptied). |
| 17 | choices: evt_1982_lebanon_war | The 40 km operation the cabinet approved is marked `historical:false`, and "broad invasion to Beirut" is marked as the decision. The dataset's own note says 40 km was "the aim the cabinet approved". This erases the war's central controversy, Sharon's step-by-step expansion. |

### UNSUPPORTED (claim-level)

| # | Item | Problem |
|---|---|---|
| 1 | evt_1948_arab_invasion | The split of "about 4,000 soldiers and 2,400 civilians" was transcribed from a Wikipedia infobox and pinned to Morris 2008 pp. 404–406 (S104 admits this). Morris's own toll is about 5,700–5,800, and JVL calls the 6,373 military deaths. |
| 2 | evt_1957_sinai_withdrawal | "UNEF guaranteeing passage through Tiran": UNEF had no navigation mandate. |
| 3 | evt_1982_lebanon_war | ">14,000 PLO fighters evacuated": about 11,000 PLO; 14k+ appears to include Syrian/PLA troops. |
| 4 | evt_1993_operation_accountability | ">150 killed (State Dept)": the cited Refworld copy is 403, so the figure could not be confirmed. |
| 5 | evt_1995_rabin_assassination | "Shamgar Commission found no conspiracy": not in the cited source. Hagai Amir and Dror Adani were convicted of conspiracy. |
| 6 | evt_2023_october_7_attack | "AFP tally 1,218" is not in cited S449. AFP's running total varied. |
| 7–13 | 7 non-historical choice options | A named advocate could not be found: Altalena (20%-only), Munich (strikes only), Yamit (delay), Lebanon 1982 (air strikes only), 1985 (full withdrawal), 2005 (negotiated withdrawal), 2011 (hold the budget). |

**All 56 non-historical options lack a source.** None of them in events.json has its own `source`. Some notes cite source IDs (S244, S246) that are not attached to the event, and one note cites S209 for a claim S209 does not contain.

### UNSUPPORTED (as cited, claim true elsewhere)

These 23 citations fail on their own terms:

- **Dead or unreachable URLs:** S103, S125, S139, S167, S230, S286, S305, S320, S331, S381, S383, S462, S495.
- **Source does not contain the claim:**
  - S137, S273: partial; they lack key details.
  - S372: gives 19 Israeli civilians and ">1,000" Lebanese dead, not the figures cited.
  - S429: links the **April** 2019 results article for the September election.
  - S434: links a Feb 2020 "first case" story for the Dec 2020 vaccination campaign.
- **Print or paywalled, not checkable:** S133, S242, S246, S255, S256, S266. S266 also gives the wrong publisher.

### BIASED

| # | Item | Problem |
|---|---|---|
| 1 | evt_1951_sderot_mitzpe_ramon | Omits that Sderot was built on the lands of Najd (422 residents expelled, May 1948). The Kiryat Shmona and Kiryat Gat entries do mention their villages. |
| 2 | evt_1956_kafr_qasim | Stops at the 1958 sentences. All the convicted were free by 1959, and Shadmi was fined 10 prutot. |
| 3 | evt_1956_sinai_campaign | Omits the 447–550 Palestinian civilians killed in Gaza (Khan Yunis, 3 Nov; Rafah, 12 Nov; UNRWA A/3212/Add.1), although both towns are listed as places. |
| 4 | evt_1969_war_of_attrition | Gives military dead only. Omits Israeli civilian dead (227) and Egyptian civilians killed in the deep raids. |
| 5 | evt_1970_black_september | Palestinian dead, including camp civilians, are coded as `plo` combatants. |
| 6 | evt_1985_security_zone | Omits the Lebanese living under SLA rule and the Khiam detention centre. |
| 7 | evt_1988_abu_jihad | Omits the bodyguards and Tunisian gardener killed, and the UNSC 611 condemnation. |
| 8 | evt_1993_operation_accountability | "Warning civilians to leave" hides that pushing refugees toward Beirut was a stated aim. Also omits 2 Israeli civilians killed by rockets. |
| 9 | evt_2000_october_events | Omits the Jewish citizen killed (Bachor Jan) and the Jewish counter-riots. |
| 10 | evt_2003_or_commission | Drops the core finding of state "prejudice and neglect" and the sanctions recommended, while keeping the criticism of Arab leaders. |
| 11 | evt_2006_second_lebanon_war | The displacement effect lists Lebanese only; 300–500k northern Israelis are missing. |
| 12 | evt_2020_vaccination_campaign | Omits the dispute over vaccine access in the West Bank and Gaza. |
| 13 | evt_2024_iran_april_attack | Omits the only serious casualty, a 7-year-old Bedouin girl near Arad. |
| 14 | evt_2025_palestine_recognitions | Gives only the Israeli and US reaction. Leaves out the recognising states' reasons, the Palestinian reaction, and the other 22-Sep recognisers. |
| 15 | cities: quneitra | "Largely depopulated" and "in ruins" omit the expulsion of the civilians and the UN finding of deliberate destruction (UNGA, 29 Nov 1974). |
| 16 | cities: jabalia | "Tightened restrictions" understates the blockade. Omits Jabalia's own 2023–25 sieges and destruction. |
| 17 | choices: evt_2024_lebanon_ceasefire | The historical option presents Israel's "freedom to act" as a term of the deal. It is Israel's reading of a mutual self-defence clause, and Lebanon disputes it. |

**Choices also noted but not counted:**

- **Munich:** a false either/or. The "non-historical" conventional strikes on Syria and Lebanon actually happened (8 Sep 1972).
- **1985:** the alternative that was really debated (a deeper zone or no withdrawal: Shamir, Arens, Sharon) is missing.
- **2014:** the options imply Israel could choose an early ceasefire alone. It accepted Egypt's 15 July ceasefire, which Hamas rejected.

### Additional out-of-sample findings by the lead critic

1. **evt_1948_operation_yoav (BIASED):** "Its Arab inhabitants had left and the town was empty" erases the expulsion of the remaining residents of Beersheba. The al-Dawayima massacre (29 Oct 1948, during Yoav; Morris: hundreds killed) appears nowhere in the dataset.
2. **evt_2023_gaza_war (stale figure):** the event carries Palestinian deaths to January 2026 but Israeli soldier deaths only to April 2024 ("604 ... with more later"). The two sides are counted to different dates.
3. **Provenance in SOURCES.md:**
   - 94 sources are marked `accessed: n/a`.
   - About 100 sources are explicitly "not opened directly", "pointer only" or "transcribed via en.wikipedia".
   - **119 of 320 events (37%)** cite *only* such sources. For 1967–86, **55 of 89 events (62%)** rest entirely on sources marked as never opened.

## Choices verdict (item 3)

The non-historical options are mostly real. Of 22 sampled:

- **15 were genuinely debated** by named actors, with sources. Examples: Begin's arms demand at Altalena, Elazar's pre-emptive strike in 1973, Begin's December 1977 plan to keep Yamit, the narrow coalitions tried in 1984, the Likud referendum and ministerial resignations of 2005, the Shalit-deal opponents, and the cabinet votes against the 2024 and 2025 ceasefires.
- **7 are plausible but unsourced.**
- **None is invented.**

The problems are of a different kind:

- No option carries a source, which breaks the project rule.
- One historical/non-historical label is reversed in substance (Lebanon 1982).
- Some options rest on false dichotomies (Munich, 2014) or one-sided framing (2024 Lebanon ceasefire).
- One note contains design text ("casualty figures here are illustrative game values").

## Top 10 omissions (item 4)

| # | Missing | Why it matters / source |
|---|---|---|
| 1 | **West Bank 2022–2026** | Operation Iron Wall (from Jan 2025; 30–40k refugees displaced from the Jenin, Tulkarm and Nur Shams camps); the 2023 Huwara rampage; settler violence; more than 1,000 Palestinians killed in the West Bank since Oct 2023 (OHCHR: 1,061 by 3 Mar 2026). Only one 2022+ event mentions the West Bank at all. Sources: https://www.ochaopt.org/sites/default/files/Northern_West_Bank_Humanitarian_Response_Update_April_2025.pdf ; https://reliefweb.int/report/occupied-palestinian-territory/palestine-human-rights-bulletin-reporting-period-28-february-3-march-2026-enar |
| 2 | **Gaza blockade imposed, June 2007** | The defining condition of Gaza for 16 years. It is mentioned only in passing (Mavi Marmara, Great March of Return); evt_2007_hamas_takeover_gaza never mentions the closure. Source: https://www.ochaopt.org/content/gaza-strip-humanitarian-impact-15-years-blockade-june-2022 |
| 3 | **Al-Dawayima massacre and the Beersheba expulsions (Oct 1948)** | One of the largest killings of 1948. Yoav is described with "the town was empty". Source: Morris, *The Birth of the Palestinian Refugee Problem Revisited* (2004); https://www.zochrot.org/villages/village_details/49115/en |
| 4 | **Yemenite, Mizrahi and Balkan children affair (1948–54)** | More than 1,000 families' claims; three state commissions; 200,000 pages declassified in 2016. A core Mizrahi grievance that is completely absent. Source: https://www.jta.org/2016/12/28/israel/israel-declassifies-200000-documents-from-probe-into-alleged-kidnapping-of-yemenite-babies |
| 5 | **2009 Knesset election (10 Feb 2009)** | Netanyahu's return, which began 12 years in office. Every other election has an event; this one does not. Source: https://en.idi.org.il/israeli-elections-and-parties/elections/2009/ |
| 6 | **Houthi–Israel war, 2023–2025** | Missiles and drones on Eilat and Tel Aviv (the July 2024 Tel Aviv drone death); Israeli strikes on Hodeidah and Sanaa; the Houthi PM killed in Aug 2025. Source: https://www.npr.org/2025/08/30/nx-s1-5522932/houthi-prime-minister-dead-yemen-israel-airstrike |
| 7 | **Negev Bedouin** | 1950s concentration in the *siyag*, unrecognised villages, the Prawer Plan (2011–13). "Bedouin" appears in one event in the whole file. Source: https://www.hrw.org/report/2008/03/30/map/land-and-housing-rights-violations-israels-unrecognized-bedouin-villages |
| 8 | **Trump "Peace to Prosperity" plan (Jan 2020), the shelved West Bank annexation, and US recognition of the Golan (Mar 2019)** | The annexation pledge that the Abraham Accords suspended. Source: https://trumpwhitehouse.archives.gov/peacetoprosperity/ |
| 9 | **Jerusalem holy-site flashpoints** | The 8 Oct 1990 Temple Mount/Haram killings (about 20 Palestinians; UNSC Res. 672), the 2017 metal-detector crisis, Sheikh Jarrah 2021 (only "tension in Jerusalem" in the 2021 event). Source: https://undocs.org/S/RES/672(1990) |
| 10 | **Iran nuclear deal (JCPOA, 2015) and Netanyahu's 2015 Congress speech** | The central Israel–US policy clash of the decade, and the prelude to the 2025 and 2026 Iran wars, which are included. Source: https://www.un.org/securitycouncil/content/2231/background |

**Honourable mentions:** USS Liberty (1967); Druze conscription (1956); Avivim (1970); the Duma arson (2015); the killing of Shireen Abu Akleh (2022); the UNRWA ban laws (Oct 2024); Israel joining the OECD (2010); the 1966–67 recession.

## SINGLE BIGGEST GAP (item 5)

**Citations are not verified provenance.** The facts are mostly right: only 10 of 311 sampled event checks were WRONG, and most of those were minor. But the dataset does not meet the bar that every claim is backed by a published source someone actually opened:

- **37% of events rest only on unopened sources.** 119 of 320 events (and 62% of 1967–86) cite only sources that SOURCES.md itself marks `accessed: n/a`, "not opened directly" or "transcribed via en.wikipedia".
- **Figures are laundered through Wikipedia.** They were copied from Wikipedia infoboxes and pinned to print page numbers that were never checked (S104, Morris pp. 404–406, carries a figure Morris does not give).
- **Live citations often fail too.** In the sample, 44% of events had at least one cited source that was dead or that does not contain the claim: S429 is the wrong election, S434 the wrong story, S372 gives different numbers.
- **Choices have no sources at all.** 0 of 56 non-historical options carry a source.

Because of this, the "unsourced doesn't ship" rule cannot currently be enforced. Nobody can tell which claims are really backed.

**Concrete fix:**

1. **Claim-level citations.** Replace event-level `source: [ids]` with per-claim citations. Every number, date and choice option gets `{source, locator}`, where the locator is a page number, a quoted sentence of 15 words or fewer, or an archived URL with a web.archive.org snapshot.
2. **A CI script that fails the build when:**
   - a cited URL is dead or has no archive snapshot;
   - the quoted text is not found in the fetched or archived page;
   - a source is `accessed: n/a` or "via Wikipedia" without a page locator from someone who opened the book.
3. **Re-verify all 119 events that rest on unopened sources, starting with 1967–86.** Either open the book (archive.org lending, library) or swap in an open authoritative source (UN document, CBS, IDI, FRUS, Knesset).
4. **A neutrality checklist on every casualty event.** Every affected population gets a casualty/displacement entry, or an explicit "none reported". This fixes the 14 sampled BIASED omissions, which almost all leave out the other side's civilians.

## Full check tables

Below are the per-check tables from each verifier: id | field | claimed | actual | source URL | verdict.


### Events 1948-66

### Fact-check results: pack_A (11 events)

Note: the session's web-search budget ran out partway through the Kiryat Gat check. Everything after that was verified by fetching URLs directly (WebFetch). Where no source could be fetched, the row says so.

| id | field | claimed | actual | source URL | verdict |
|---|---|---|---|---|---|
| evt_1948_arab_invasion | date | 1948-05-15 | Arab armies entered 15 May 1948, the day after the 14 May declaration | https://history.state.gov/milestones/1945-1952/arab-israeli-war | CORRECT |
| evt_1948_arab_invasion | places | Tel Aviv, Jerusalem, Negev, Galilee, West Bank, Gaza | Matches the fronts: Egyptian air raids on Tel Aviv, the Legion in Jerusalem and the West Bank, Egypt in Gaza/Negev, Syria/Lebanon/ALA in Galilee | history.state.gov (above) | CORRECT |
| evt_1948_arab_invasion | summary: invading states and Legion zone | Egypt, Transjordan, Syria, Iraq, Lebanon; the Legion mainly in Arab-state areas and the Jerusalem zone | State Dept agrees (Lebanon, Syria, Iraq, Egypt invaded; Transjordan limited to Arab-state areas and Jerusalem). It also notes a Saudi contingent; the Arab Liberation Army is not mentioned. Lebanon's role was marginal. | history.state.gov (above) | CORRECT (minor omissions) |
| evt_1948_arab_invasion | Israel killed 6,373 | 6,373 | 6,373 is the standard Israeli count (JVL / IDF table). Morris's own estimate is about 5,700-5,800. | https://www.jewishvirtuallibrary.org/military-casualties-in-arab-israeli-wars | CORRECT |
| evt_1948_arab_invasion | "about 4,000 soldiers and 2,400 civilians" | 4,000 + 2,400 | Only source found is the en.wikipedia infobox (ref "politics", not Morris). JVL lists 6,373 as military/battle deaths, which conflicts with the split. | https://en.wikipedia.org/wiki/1948_Arab%E2%80%93Israeli_War ; JVL (above) | UNSUPPORTED |
| evt_1948_arab_invasion | Arab armies killed | 3,700-7,000 | al-Aref (1958) gives 3,700; another estimate gives 7,000. The en.wikipedia body cites both. | en.wikipedia 1948 war (above) | CORRECT |
| evt_1948_arab_invasion | Palestinian Arab killed | 3,000-13,000 | Laurens gives 13,000; the infobox range is 3,000-13,000. A wide but recognized range. | en.wikipedia 1948 war (above) | CORRECT |
| evt_1948_arab_invasion | source S104 (Morris pp. 404-406) | Morris supports 6,373 and the 4,000/2,400 split | The SOURCES entry admits the figures were copied from the Wikipedia infobox, whose ref for 6,373 is not Morris. Morris's own figure is about 5,700-5,800. The page citation was never checked. | n/a (print) | UNSUPPORTED |
| evt_1948_arab_invasion | source S103 Britannica | 15 May entry, five states | URL returns 403; could not verify | https://www.britannica.com/event/Arab-Israeli-wars | UNSUPPORTED (inaccessible) |
| evt_1948_arab_invasion | neutrality | Israeli, Arab army and Palestinian dead all given | Balanced on deaths. It does not mention that roughly 700,000 Palestinians were displaced, though this may be covered by another event. | — | CORRECT (check that displacement is covered elsewhere) |
| evt_1949_kiryat_shmona | date | 1949-07-18 | The first 14 Yemenite settlers arrived 18 July 1949 (Goldstein 2016, via en.wikipedia). EJ gives 1950 for the permanent town, which the summary also states. | https://en.wikipedia.org/wiki/Kiryat_Shmona | CORRECT |
| evt_1949_kiryat_shmona | places | Kiryat Shmona, Galilee (Hula Valley) | Correct | same | CORRECT |
| evt_1949_kiryat_shmona | summary: al-Khalisa, naming, 1953 status | Depopulated al-Khalisa; named for Trumpeldor + 7 (Tel Hai 1920); local council 1953 | EJ/JVL confirms Khalisa, the naming and "municipal council status" in 1953. Wikipedia: first called Kiryat Yosef, renamed June 1950. | https://www.jewishvirtuallibrary.org/kiryat-shemonah | CORRECT |
| evt_1949_kiryat_shmona | sources S160/S168 | — | Both contain the claims they are cited for | as above | CORRECT |
| evt_1949_kiryat_shmona | neutrality | Notes the depopulated Arab village | Acceptable (the villagers fled in May 1948 after Safed fell) | — | CORRECT |
| evt_1950_absentees_property_law | date | 1950-03-20 | Published in Sefer HaChukim no. 37, 20 Mar 1950, p. 86 (NRC memo). The Knesset vote was a few days earlier. | https://www.nrc.no/globalassets/pdf/legal-opinions/absentee_law_memo.pdf | CORRECT |
| evt_1950_absentees_property_law | summary: definition, Custodian, Development Authority, present absentees | As stated | Matches the NRC memo, Ir Amim and UN documents. The legal definition is broader (it covers citizens of or visitors to Arab states, and anyone who left their residence for areas held by hostile forces) but is fairly summarized. The Development Authority was created by a separate 1950 law. | NRC memo (above); https://old.ir-amim.org.il/sites/default/files/Absentees_against_their_will.pdf | CORRECT |
| evt_1950_absentees_property_law | source S125 UNISPAL | Law text | The page loads only as a stub/listing; the law text could not be confirmed there. The NRC memo it also names does support the claims. | https://www.un.org/unispal/?p=209845 | UNSUPPORTED (URL); claims supported elsewhere |
| evt_1950_absentees_property_law | neutrality | Critics' view is attributed | The dispossession framing is properly attributed. The Israeli state rationale (wartime enemy property, reciprocity for Jewish property in Arab states) is not given, a minor imbalance. | — | CORRECT (minor) |
| evt_1951_sderot_mitzpe_ramon | date | 1951 (year precision, stored as 06-01) | Both founded 1951. Mitzpe Ramon's permanent families came from 1956. | https://www.jewishvirtuallibrary.org/sderot ; https://en.wikipedia.org/wiki/Mitzpe_Ramon | CORRECT |
| evt_1951_sderot_mitzpe_ramon | summary: Sderot | Beside the Gevim-Dorot camp; Kurdish and Persian immigrants; tents/shacks until 1954 | JVL confirms each point. en.wikipedia says it was itself the transit camp (spelled "Gabim Dorot"), with 80 families. | JVL Sderot (above) | CORRECT |
| evt_1951_sderot_mitzpe_ramon | summary: Mitzpe Ramon | Workers' camp for the road to Eilat | Workers' camp for Highway 40 (JPost 2021 via Wikipedia) | en.wikipedia Mitzpe Ramon | CORRECT |
| evt_1951_sderot_mitzpe_ramon | neutrality | No Arab villages mentioned | Sderot stands on/near the lands of Najd, whose 422 residents were expelled in May 1948 (Morris 2004, p. 258). Kiryat Shmona and Kiryat Gat do get this note, so the omission is inconsistent. | https://en.wikipedia.org/wiki/Sderot | BIASED (omission) |
| evt_1951_election | date | 1951-07-30 | 30 July 1951 | https://en.idi.org.il/israeli-elections-and-parties/elections/1951/ | CORRECT |
| evt_1951_election | seats | Mapai 45, General Zionists 20 | 45 and 20 | IDI 1951 | CORRECT |
| evt_1951_election | turnout | 75.1% | 75.1% | IDI 1951 | CORRECT |
| evt_1951_election | summary / source | Ben-Gurion formed a new coalition | IDI: Mapai, religious parties, Progressives and the Arab satellite lists | IDI 1951 | CORRECT |
| evt_1951_mass_immigration | population | 806,000 (1948) to 1,578,000 (end 1951) | JVL/CBS give 806,000 (at founding, May 1948) and 1,578,000 (1951). The end-1948 figure was about 872,700, so "in 1948" should say May 1948. | https://www.jewishvirtuallibrary.org/population-of-israel-1948-present | CORRECT (clarify May 1948) |
| evt_1951_mass_immigration | "over 260,000" from Arab/Muslim countries by 1951 | >260,000 | Total 1948-51 immigration was about 687,600. The Jewish Agency's yearly Asia/Africa shares (14.4%, 47.3%, 49.6%, 71.0%) imply about 335,000. Literally true but understated for "Arab and Muslim countries". It may be Hacohen's figure for Arab countries only, but the print source was not checked. | https://archive.jewishagency.org/society-and-politics/content/36566 | CORRECT (understated; source UNSUPPORTED) |
| evt_1951_mass_immigration | summary wording | Departures "amid hostility and legal pressure"; strain on absorption | Defensible (e.g. Iraq's 1950 denaturalization law, the 1945/48 riots in Libya). It leaves out the organized airlifts and Zionist emigration activity, and the hardship and discrimination in the ma'abarot. | — | CORRECT (minor) |
| evt_1954_kiryat_gat | date / origin | 1954 ma'abara; 1955 Lachish centre; Moroccan families | en.wikipedia: 1954 ma'abara, 1955 development town (18 Moroccan families). he.wikipedia: Lachish regional centre planned 1954-55, cornerstone laid 1956. | https://en.wikipedia.org/wiki/Kiryat_Gat ; https://he.wikipedia.org/wiki/קריית_גת | CORRECT |
| evt_1954_kiryat_gat | places / neutrality | Near depopulated Iraq al-Manshiyya | Built on the lands of Iraq al-Manshiyya and al-Faluja. Residents left after the 1949 armistice despite guarantees; he.wikipedia says 2,000-3,000 fled. Mentioning only one village is minor. | he.wikipedia (above) | CORRECT |
| evt_1954_kiryat_gat | source S167 JUF | Partnership page | The URL 301-redirects to a generic JUF page; the cited content is gone (dead link) | https://www.juf.org/p2g/kiryat_gat.aspx | UNSUPPORTED (dead) |
| evt_1956_kafr_qasim | date / place | 29 Oct 1956, Kafr Qasim | Correct | https://en.wikipedia.org/wiki/Kafr_Qasim_massacre | CORRECT |
| evt_1956_kafr_qasim | toll | 47-49 (49 most cited) | 49 including an unborn child (48 born: 19 men, 6 women, 23 children). JPost gives 49. | Wikipedia (above); https://www.jpost.com/israel-news/article-713447 | CORRECT |
| evt_1956_kafr_qasim | curfew / Border Police | Curfew brought forward without warning | Curfew moved from 21:00 to 17:00 (Shadmi); Border Police platoon under Dahan | JPost (above) | CORRECT |
| evt_1956_kafr_qasim | 1958 sentences / doctrine | 7-17 years; "manifestly unlawful order" | 16 Oct 1958: 8 of 11 defendants convicted, 7-17 years; Halevy's "black flag" doctrine | Wikipedia (above) | CORRECT |
| evt_1956_kafr_qasim | wording (omission) | Ends at the sentences | Leaves out that sentences were cut on appeal, by the Chief of Staff and by presidential pardon, and that all were free by Nov 1959. Brigade commander Shadmi was fined 10 prutot. This makes accountability look stronger than it was. | Wikipedia (above) | BIASED (omission) |
| evt_1956_kafr_qasim | source S137 JPost | Curfew, toll, 1958 sentences, doctrine | The JPost article (29 Jul 2022) covers the curfew change and 49 dead. It does not give the 1958 sentences, the doctrine, or women and children. The HUJI CRIS paper was not checked. | JPost (above) | UNSUPPORTED (partial) |
| evt_1956_sinai_campaign | dates | 29 Oct - 8 Nov 1956; ultimatum; ceasefire 7-8 Nov | UN: attack 29 Oct, ultimatum 30 Oct, bombing 31 Oct, ceasefire midnight GMT 7/8 Nov | https://peacekeeping.un.org/mission/past/unef1backgr2.html | CORRECT |
| evt_1956_sinai_campaign | Israeli killed | 172-189 | 172 (AP via Wikipedia); 189 (EBSCO). JVL/IDF table gives 231, outside the range. | https://www.ebsco.com/research-starters/military-history-and-science/battle-sinai ; JVL military casualties (above) | CORRECT (range omits 231) |
| evt_1956_sinai_campaign | Egyptian killed | 1,000-3,000 | EBSCO about 1,030; Varble 1,650-3,000 military (+1,000 civilians); JVL 3,000 | EBSCO; https://en.wikipedia.org/wiki/Suez_Crisis | CORRECT |
| evt_1956_sinai_campaign | choices / notes | Sèvres 22-24 Oct; Sharett left office June 1956 | Consistent with the standard account (Sharett left as Foreign Minister in June 1956) | Shlaim (print, not checked) | CORRECT |
| evt_1956_sinai_campaign | neutrality | No Palestinian civilian deaths; Rafah/Khan Yunis listed only as places | UN estimate: 447-550 Palestinian civilians killed in Gaza during the occupation. UNRWA report A/3212/Add.1 lists 275 killed in Khan Yunis on 3 Nov, with further killings in Rafah on 12 Nov. | https://en.wikipedia.org/wiki/Khan_Yunis_massacre ; Suez Crisis (above) | BIASED (omission) |
| evt_1956_sinai_campaign | source S139 LA Times | 172 | The latimes.com URL could not be fetched; the figure is relayed via Wikipedia | https://www.latimes.com/archives/la-xpm-1991-03-08-mn-2592-story.html | UNSUPPORTED (inaccessible) |
| evt_1957_sinai_withdrawal | dates | Announced 1 Mar; Gaza 6-8 Mar; Sharm el-Sheikh by 12 Mar | Exactly as in the UN record | UNEF background (above) | CORRECT |
| evt_1957_sinai_withdrawal | GA resolutions | 1124 and 1125 | Adopted 2 Feb 1957 | UNEF background | CORRECT |
| evt_1957_sinai_withdrawal | "UNEF ... guaranteeing passage through the Straits of Tiran" | UNEF guaranteed passage | UNEF had no mandate to guarantee navigation. Its presence kept passage open in practice; Israel relied on US and maritime-power assurances. Overstated. | UNEF background | UNSUPPORTED (overstated) |
| evt_1957_sinai_withdrawal | effect diplo un: "relations_established" | New UN relationship in 1957 | Israel joined the UN on 11 May 1949 | (GA res. 273, 1949) | WRONG |
| evt_1957_sinai_withdrawal | choice note | Jan-Feb 1957: Israel held only Gaza and Sharm | Consistent with the UN record | UNEF background | CORRECT |
| evt_1965_election | date / seats / turnout | 2 Nov 1965; Alignment 45, Gahal 26, Rafi 10; 83.0% | Exactly per IDI | https://en.idi.org.il/israeli-elections-and-parties/elections/1965/ | CORRECT |
| evt_1965_election | summary | Eshkol remained PM; Rafi a Ben-Gurion breakaway | IDI confirms Eshkol | IDI 1965 | CORRECT |

#### Non-CORRECT findings

- **evt_1948_arab_invasion (4,000 soldiers / 2,400 civilians):** The split traces only to a Wikipedia ref. JVL lists 6,373 as military battle deaths, so the civilian share is uncertain.
- **evt_1948_arab_invasion (S104 Morris pp. 404-406):** The figures were copied from Wikipedia and pinned to Morris pages nobody checked. Morris's own Israeli toll is about 5,700-5,800, not 6,373.
- **evt_1948_arab_invasion (S103 Britannica):** Returns 403, so it could not be verified.
- **evt_1950_absentees_property_law (S125 URL):** The UNISPAL page loads only as a stub. The claims are supported by the NRC memo instead.
- **evt_1951_sderot_mitzpe_ramon (neutrality):** It leaves out the 422 expelled villagers of Najd, on whose land Sderot was built, while sibling founding events do mention depopulated villages.
- **evt_1951_mass_immigration ("over 260,000"):** Technically true but understated. Jewish Agency data imply about 335,000 from Asia/Africa in 1948-51. The Hacohen print source was not checked.
- **evt_1954_kiryat_gat (S167 JUF):** Dead link (redirects to a generic page). The claims are supported by en/he Wikipedia.
- **evt_1956_kafr_qasim (wording):** It leaves out the commuted sentences (all free by Nov 1959) and Shadmi's 10-prutot fine, which overstates accountability.
- **evt_1956_kafr_qasim (S137 JPost):** The article does not contain the 1958 sentences, the "manifestly unlawful" doctrine or the women-and-children detail.
- **evt_1956_sinai_campaign (neutrality):** It leaves out the 447-550 Palestinian civilians killed in Gaza (UN), including 275 in Khan Yunis on 3 Nov (UNRWA A/3212/Add.1), although Rafah and Khan Yunis are listed as places.
- **evt_1956_sinai_campaign (S139 LA Times):** Could not be fetched. Also, the Israeli range of 172-189 leaves out the 231 in the JVL/IDF table.
- **evt_1957_sinai_withdrawal ("guaranteeing passage"):** UNEF had no mandate to guarantee navigation, so this is overstated.
- **evt_1957_sinai_withdrawal (effect `un: relations_established`):** Wrong. Israel has been a UN member since May 1949.


### Events 1967-86

### Fact-check results: pack B

Method note: the session's WebSearch budget ran out partway through. Later checks used WebFetch on specific pages: Wikipedia, JVL, IDI, CIE, Avalon, archive.org and Google Books. Britannica (403), Telegraph (blocked), SAGE (403) and JSTOR (JS wall) could not be opened.

| id | field | claimed | actual | source URL | verdict |
|---|---|---|---|---|---|
| evt_1967_six_day_war | date | 5-10 Jun 1967 | 5 Jun strikes; 10 Jun ceasefire | https://www.jewishvirtuallibrary.org/background-and-overview-six-day-war | CORRECT |
| evt_1967_six_day_war | places | Sinai, Gaza, WB, E. Jerusalem, Golan, Quneitra | all captured by 10 Jun | https://en.wikipedia.org/wiki/Six-Day_War | CORRECT |
| evt_1967_six_day_war | Israel killed | 776-983 | 776-983 (Gawrych/infobox); JVL 777 | https://en.wikipedia.org/wiki/Six-Day_War | CORRECT |
| evt_1967_six_day_war | Israel wounded | 2,586-4,517 | JVL 2,586; infobox 4,517 | same + JVL | CORRECT |
| evt_1967_six_day_war | Egypt killed | 9,800-15,000 | 9,800-15,000 killed or missing; JVL-S201 11,500 | https://en.wikipedia.org/wiki/Six-Day_War | CORRECT |
| evt_1967_six_day_war | Jordan killed | 696-800 ("700-800" in summary) | 696-700 (Gawrych), 800 (JVL); cited S201 gives 6,094 (Jordanian official, likely killed+missing) | https://www.jewishvirtuallibrary.org/military-casualties-in-arab-israeli-wars | CORRECT (note: S201 conflicts) |
| evt_1967_six_day_war | Syria killed | 1,000-2,500 | 1,000-2,500 | https://en.wikipedia.org/wiki/Six-Day_War | CORRECT |
| evt_1967_six_day_war | Palestinians governed | >750,000 | JVL wording matches; Sept 1967 census totals were about 1 million (from memory, not re-verified) | JVL S200 | CORRECT (understated) |
| evt_1967_six_day_war | wording | "pre-emptive air strikes" | standard description; some scholars prefer "preventive" | JVL; Wikipedia | CORRECT |
| evt_1967_six_day_war | cited sources | S200, S201, S202, S205 | S200/S201 open and support; S201 Jordan 6,094 is not in the game's range; S202 is print; S205 archive.org restricted | see URLs | CORRECT (S205 unverifiable) |
| evt_1967_six_day_war | neutrality | soldier deaths; Palestinians under occupation | balanced; displacement in separate event; Iraq omitted (minor) | - | CORRECT |
| evt_1967_displacement | date | Jun-Dec 1967 | consistent with McDowall's "by Dec 1967" | https://en.wikipedia.org/wiki/1967_Palestinian_exodus | CORRECT |
| evt_1967_displacement | places | WB, Gaza, Golan, Jordan, Syria | Egypt also a destination (11,000), not listed | same | CORRECT (minor omission) |
| evt_1967_displacement | 245,000 to Jordan; 11,000 Gaza to Egypt | McDowall | matches McDowall as cited | same | CORRECT |
| evt_1967_displacement | 280,000-325,000 | Bowker | matches (Bowker p.81); JVL also says 325,000 fled the WB | same; JVL S200 | CORRECT |
| evt_1967_displacement | Golan 80,000-116,000 | Morris 80k; McDowall 116k | Wikipedia Golan: 80,000-131,000 (Morris low; upper about 130k); Six-Day War article says 100,000 | https://en.wikipedia.org/wiki/Golan_Heights | CORRECT (range understates the high end) |
| evt_1967_displacement | "Few were allowed to return" | few | JVL says >60,000 returned eventually; the Aug 1967 return scheme was small | JVL S200 | CORRECT (contested) |
| evt_1967_displacement | cited sources | S203, S204, S205, S200 | S203/S204 are print, located via Wikipedia (figures match); S205 restricted; S200 supports 325k only | - | CORRECT (mostly unverifiable directly) |
| evt_1967_displacement | neutrality | "left or was expelled" | balanced; Golan Druze who remained (about 7,000) not mentioned; razed villages (Latrun, Mughrabi Qtr) omitted | - | CORRECT |
| evt_1969_war_of_attrition | date | 8 Mar 1969 - 7 Aug 1970 | Nasser's official launch 8 Mar 1969; ceasefire 7 Aug 1970 | https://en.wikipedia.org/wiki/War_of_Attrition | CORRECT |
| evt_1969_war_of_attrition | places | Suez Canal, Sinai, Egypt | correct (Jordan/Syria fronts omitted) | same | CORRECT |
| evt_1969_war_of_attrition | Israel killed | 694-1,424 | Schiff 694 to Lorch/MFA 1,424 soldiers | same; JVL S201 | CORRECT |
| evt_1969_war_of_attrition | Egypt killed | 2,882-10,000 | el-Shazly 2,882 to Morris 10,000 (soldiers and civilians) | same | CORRECT |
| evt_1969_war_of_attrition | Soviet deployment | Soviet air defence in Egypt | 10,700-15,000 personnel | same | CORRECT |
| evt_1969_war_of_attrition | cited source S286 | MFA URL | URL dead (ECONNRESET; old mfa.gov.il path) | http://www.mfa.gov.il/MFA/History/... | UNSUPPORTED (dead link; figures corroborated via Wikipedia) |
| evt_1969_war_of_attrition | neutrality | deep air strikes | omits civilian dead on both sides: Schiff counts 227 Israeli civilians; Egyptian civilians died in the deep raids | same | BIASED (minor omission) |
| evt_1970_black_september | date | 16 Sep 1970 - 23 Jul 1971 | martial law 16 Sep, offensive 17 Sep; end 23 Jul 1971 | https://en.wikipedia.org/wiki/Black_September | CORRECT |
| evt_1970_black_september | places | Jordan, Amman, Lebanon | correct | same | CORRECT |
| evt_1970_black_september | Dawson's Field dates | 6-12 Sep 1970 | hijackings from 6 Sep; planes blown up 12 Sep | same | CORRECT |
| evt_1970_black_september | Palestinian dead | 2,000-3,400 | 2,000-3,400 (Arafat claimed 25,000) | same | CORRECT |
| evt_1970_black_september | Jordanian army dead | 537 | 537 | same | CORRECT |
| evt_1970_black_september | Syrian incursion; Israel readied forces | yes | yes; Israel mobilised by 22 Sep | same | CORRECT |
| evt_1970_black_september | cited source S230 | archive.org Massad | URL returns 404 | https://archive.org/details/colonialeffectsm00mass_429 | UNSUPPORTED (dead link; figures corroborated) |
| evt_1970_black_september | neutrality | effects key "plo" | the estimates cover Palestinians generally, incl. camp civilians, but are coded as PLO combatants | - | BIASED (minor labelling) |
| evt_1971_black_panthers | date | 18 May 1971 | Night of the Panthers, 18 May 1971 | https://en.wikipedia.org/wiki/Israeli_Black_Panthers | CORRECT |
| evt_1971_black_panthers | place | Jerusalem (Musrara) | correct | same | CORRECT |
| evt_1971_black_panthers | crowd / arrests | 5,000-7,000; >100 arrests | 5,000-7,000; >100 arrested; CIE says 6,000 | same; israeled.org | CORRECT |
| evt_1971_black_panthers | Meir meeting / "not nice" | April; "not nice" | 13 Apr 1971; "not nice people" | both | CORRECT |
| evt_1971_black_panthers | committee / welfare | gaps acknowledged; spending rose | public committee acknowledged gaps; welfare funding rose | Wikipedia | CORRECT |
| evt_1971_black_panthers | cited source S273 | CIE URL | page lacks Musrara, the 18 May date, arrests and the committee; Frankel article not opened | https://israeled.org/israeli-black-panthers/ | UNSUPPORTED (partial; corroborated by Wikipedia) |
| evt_1971_black_panthers | neutrality | Mizrahi protest | fair | - | CORRECT |
| evt_1976_entebbe | date | 27 Jun - 4 Jul 1976 | hijack 27 Jun; raid night of 3-4 Jul | https://en.wikipedia.org/wiki/Operation_Entebbe | CORRECT |
| evt_1976_entebbe | places | Entebbe | correct | same | CORRECT |
| evt_1976_entebbe | hostages | 102 of 106 rescued; 3 killed + Dora Bloch | same | same | CORRECT |
| evt_1976_entebbe | other deaths | 1 IDF, 7 hijackers, ~45 Ugandan | same | same | CORRECT |
| evt_1976_entebbe | choices | cabinet 3 Jul; Rabin leaned to negotiate | approval 3 Jul 18:30; Rabin favoured meeting demands, Peres opposed | same | CORRECT |
| evt_1976_entebbe | cited source S242 | Telegraph URL | could not fetch (domain blocked); print book | telegraph.co.uk/... | UNSUPPORTED (unverifiable; claims corroborated) |
| evt_1976_entebbe | neutrality | Ugandan dead counted | fair | - | CORRECT |
| evt_1980_egypt_ambassadors | date | Feb 1980 | ambassadors exchanged 26 Feb 1980; but full relations established 26 Jan 1980 | https://en.wikipedia.org/wiki/Egypt-Israel_relations | CORRECT (wording imprecise) |
| evt_1980_egypt_ambassadors | "relations established ... in Feb" | Feb 1980 | relations established 26 Jan 1980 | same | WRONG (minor) |
| evt_1980_egypt_ambassadors | flights | regular flights next month | Wikipedia: March 1980; one secondary source: April 1980 | same | CORRECT |
| evt_1980_egypt_ambassadors | treaty basis | ambassadors exchanged on interim withdrawal | Annex III Art. 1 confirms | https://avalon.law.yale.edu/20th_century/isregypt.asp | CORRECT |
| evt_1980_egypt_ambassadors | cited sources | S133 (print), S219 | S219 supports the mechanism, not the date; S133 not checkable | - | CORRECT |
| evt_1982_lebanon_war | date | 6 Jun - 29 Sep 1982 | invasion 6 Jun; W. Beirut withdrawal 29 Sep | https://en.wikipedia.org/wiki/1982_Lebanon_War | CORRECT |
| evt_1982_lebanon_war | Argov / Abu Nidal | yes | shot 3 Jun 1982 by Abu Nidal Org. | same | CORRECT |
| evt_1982_lebanon_war | 40 km aim | yes | stated aim 40 km | same | CORRECT |
| evt_1982_lebanon_war | PLO evacuated | >14,000 | Lebanon War article ">14,000 PLO combatants"; Siege of Beirut article about 11,000 (8,500 by sea + 2,500 overland); 14k total likely includes Syrian/PLA troops | https://en.wikipedia.org/wiki/Siege_of_Beirut | UNSUPPORTED (disputed; likely overstated) |
| evt_1982_lebanon_war | Lebanese dead | 17,285-19,085 | An-Nahar 17,285 (6 Jun-31 Aug); Lebanese authorities 19,085 | 1982 Lebanon War (WP) | CORRECT |
| evt_1982_lebanon_war | civilians | Gabriel 5,000-8,000 | matches | same | CORRECT |
| evt_1982_lebanon_war | Israel killed | 368 (to Oct 82); 654 (to Jun 85) | 368 (6 Jun-10 Oct); 654 (1982-85) | same | CORRECT |
| evt_1982_lebanon_war | Syria killed | 1,200 | 1,200 (Pollack) | same | CORRECT |
| evt_1982_lebanon_war | effects coding | lebanese_and_palestinians 17,285-19,085 + syria 1,200 | Lebanese totals likely already include PLO and Syrian dead, so possible double count | - | CORRECT (note) |
| evt_1982_lebanon_war | choices | cabinet 5 Jun approved 40 km; air strikes 4-5 Jun | consistent | same | CORRECT |
| evt_1982_lebanon_war | cited sources | S255 archive.org; S256 DOI | both exist but are access-restricted (archive.org restricted; SAGE 403) | see pack | UNSUPPORTED (unverifiable directly; corroborated) |
| evt_1982_lebanon_war | neutrality | "many of them civilians" | Lebanese authorities: 84% of Beirut dead were civilians; Sabra-Shatila (16-18 Sep, within event span) not mentioned | same | CORRECT (check separate Sabra-Shatila event exists) |
| evt_1984_election_rotation | date | 23 Jul 1984 | 23 Jul 1984 | https://en.idi.org.il/israeli-elections-and-parties/elections/1984/ | CORRECT |
| evt_1984_election_rotation | seats | Alignment 44, Likud 41 | 44 / 41 | same | CORRECT |
| evt_1984_election_rotation | govt formed | 13 Sep 1984 | 13 Sep 1984 (21st govt) | https://en.wikipedia.org/wiki/1984_Israeli_legislative_election | CORRECT |
| evt_1984_election_rotation | rotation / Rabin | Peres 2y, Shamir 2y; Rabin defence | confirmed by IDI | IDI | CORRECT |
| evt_1984_election_rotation | cited sources | S214, S215 | S214 supports | IDI | CORRECT |
| evt_1984_election_rotation | neutrality | - | fine | - | CORRECT |
| evt_1985_jibril_exchange | date | 21 May 1985 | 21 May 1985 | https://en.wikipedia.org/wiki/Jibril_Agreement | CORRECT |
| evt_1985_jibril_exchange | prisoners | 1,150 incl. Okamoto, Yassin | same | same | CORRECT |
| evt_1985_jibril_exchange | soldiers | 3 held by PFLP-GC | Grof, Salem, Shai (captured 1982) | same | CORRECT |
| evt_1985_jibril_exchange | cabinet vote | all except Navon | same | same | CORRECT |
| evt_1985_jibril_exchange | cited source S266 | Arens, Brookings 2018, pp.118-119 | Google Books lists Rowman & Littlefield 2018; p.119 text not visible | https://books.google.co.il/books?id=CmIMDgAAQBAJ&pg=PA119 | UNSUPPORTED (page unverifiable; publisher metadata off) |
| evt_1985_jibril_exchange | neutrality | - | fine | - | CORRECT |
| evt_1985_security_zone | date | 5 Jun 1985 | WP 1982 war: 5 Jun 1985; WP 1985-2000 conflict: 10 Jun | 1982 Lebanon War (WP) | CORRECT (date varies by source) |
| evt_1985_security_zone | Jan 1985 decision | yes | cabinet decision 14 Jan 1985 (Shlaim, print; date from memory); phased pullout from Feb | https://en.wikipedia.org/wiki/South_Lebanon_conflict_(1985-2000) | CORRECT |
| evt_1985_security_zone | 654 killed | 654 | 654 (1982-85) | 1982 Lebanon War (WP) | CORRECT |
| evt_1985_security_zone | SLA | held with SLA | yes | same | CORRECT |
| evt_1985_security_zone | cited sources | S133, S246, S256 | print / JSTOR (inaccessible) / SAGE 403 | - | UNSUPPORTED (unverifiable directly; corroborated) |
| evt_1985_security_zone | neutrality | Israeli losses only | omits the Lebanese residents of the occupied zone (SLA rule, Khiam detention, Lebanese casualties) | same | BIASED (minor omission) |

#### Non-CORRECT findings and caveats

- **evt_1980_egypt_ambassadors, wording (WRONG, minor):** Full diplomatic relations were set up on 26 Jan 1980; only the ambassadors were exchanged in February (26 Feb). The summary puts both in February.
- **evt_1982_lebanon_war, ">14,000 PLO fighters evacuated" (UNSUPPORTED/disputed):** The Siege of Beirut sources give about 11,000 PLO fighters. The 14,000+ total probably includes Syrian and PLA troops. Suggest "about 11,000 PLO fighters (with Syrian troops, over 14,000)".
- **evt_1969_war_of_attrition, neutrality (BIASED, minor):** Only military deaths are given. Israeli civilian deaths (227 per Schiff) and Egyptian civilians killed in the deep-penetration raids are left out.
- **evt_1970_black_september, effects label (BIASED, minor):** The 2,000-3,400 Palestinian dead include refugee-camp civilians, but the effects code them all as "plo" killed.
- **evt_1985_security_zone, neutrality (BIASED, minor):** The summary gives only Israeli losses. It leaves out the Lebanese civilians living under the zone (SLA rule, Khiam detention).
- **evt_1969_war_of_attrition, S286 (UNSUPPORTED):** The MFA URL is dead. The figures are corroborated elsewhere.
- **evt_1970_black_september, S230 (UNSUPPORTED):** The archive.org link to Massad returns 404.
- **evt_1971_black_panthers, S273 (UNSUPPORTED, partial):** The CIE page backs only the 13 Apr meeting, the "not nice" quote and a crowd of about 6,000. It lacks Musrara, the 18 May date, the arrests and the committee; Wikipedia corroborates those.
- **evt_1976_entebbe, S242 (UNSUPPORTED):** The Telegraph URL could not be fetched. Every claim is corroborated by the Operation Entebbe article.
- **evt_1982_lebanon_war, S255/S256 (UNSUPPORTED):** The archive.org and SAGE copies are access-restricted. The figures match the secondary summaries.
- **evt_1985_security_zone, S246/S256 (UNSUPPORTED):** The JSTOR and SAGE copies could not be opened.
- **evt_1985_jibril_exchange, S266 (UNSUPPORTED):** Google Books gives the publisher as Rowman & Littlefield, not Brookings, and pp.118-119 are not visible.
- **Caveats on CORRECT rows:**
  - **evt_1967_six_day_war:** The cited S201 gives Jordan 6,094 dead, which the game's 696-800 range leaves out. ">750,000 Palestinians" is technically true but low; my figure of about 1 million is from memory and was not re-checked.
  - **evt_1967_displacement:** The Golan range of 80k-116k leaves out higher estimates of about 130k. Egypt is missing from the places list.
  - **evt_1982_lebanon_war:** The Lebanese totals plus the separate Syrian 1,200 may double-count. Sabra-Shatila falls within the event's dates but is not mentioned; confirm it has its own event.


### Events 1987-2008

### Fact-check results: pack_C (12 events)

Method note: the WebSearch budget for the session was already used up when this audit began, so no searches were run. Every check below comes from fetching the cited URLs directly (curl/WebFetch) or from known primary or authoritative URLs: nobelprize.org, HRW 1996 "Civilian Pawns", the State Dept PGT 1996 (FAS), the UN DPR chronology, IDI, BBC, PBS, the JVL Or Commission summary and Al-Monitor. English Wikipedia articles (wp:) were used only as a cross-check.

| id | field | claimed | actual | source URL | verdict |
|---|---|---|---|---|---|
| evt_1988_abu_jihad | date | 1988-04-16 | 16 Apr 1988 | https://en.wikipedia.org/wiki/Khalil_al-Wazir | CORRECT |
| evt_1988_abu_jihad | place | Tunis | His home in Tunis (Sidi Bou Said suburb) | same | CORRECT |
| evt_1988_abu_jihad | summary: role | Deputy to Arafat; senior intifada organiser | Arafat's No. 2; PLO commander for the territories; built networks used in the 1st Intifada | same | CORRECT |
| evt_1988_abu_jihad | summary: 2012 acknowledgment | Unacknowledged until a 2012 press report (Mossad plan, Sayeret Matkal) | Nov 2012: censor cleared Yedioth (Bergman) interview with Nahum Lev. Israel confirmed it *unofficially*; there was never an official claim | same; TOI 1 Nov 2012 | CORRECT (note: unofficial) |
| evt_1988_abu_jihad | source S305 | Ahram/AFP supports | URL returns HTTP 403, so it could not be opened. Claims are backed by equivalent reporting (TOI, wp) | https://english.ahram.org.eg/News/56915.aspx | UNSUPPORTED (cited URL inaccessible; claim OK) |
| evt_1988_abu_jihad | neutrality | Only al-Wazir's death mentioned | Raid also killed two bodyguards and the family's (Tunisian) gardener. UNSC Res. 611 condemned the aggression against Tunisia | wp Khalil_al-Wazir | BIASED (minor omission) |
| evt_1993_operation_accountability | date | 25–31 Jul 1993 | 25–31 Jul 1993; understanding took effect 31 Jul | https://www.hrw.org/reports/1996/Israel.htm | CORRECT |
| evt_1993_operation_accountability | places | south_lebanon, kiryat_shmona | South Lebanon; Hezbollah rockets hit northern Israel incl. Kiryat Shmona | same | CORRECT |
| evt_1993_operation_accountability | killed 118 (Lebanese official, civilians) | 118 | HRW: "some 120" civilians; wp: 118 civilians | same; wp Operation_Accountability | CORRECT |
| evt_1993_operation_accountability | killed >150 (US State Dept) | 150 | Not verifiable: refworld 403. Consistent with ~120–140 civilians plus combatants | https://www.refworld.org/node/25230 | UNSUPPORTED (unverified, plausible) |
| evt_1993_operation_accountability | wounded 500 | 500 | HRW: "close to 500" | HRW 1996 | CORRECT |
| evt_1993_operation_accountability | displaced 300,000 | 300,000 for ~1 week | HRW: ~300,000 temporarily displaced (wp: 300–400k) | HRW 1996 | CORRECT |
| evt_1993_operation_accountability | source S320 | State Dept 1993 report | Refworld returns 403. "118 civilians" comes from secondary sources, as the packet admits | refworld | UNSUPPORTED (inaccessible) |
| evt_1993_operation_accountability | source S383 | IDF mini-site | Page returns an empty JS shell (952 bytes) with no content to check | https://www.idf.il/en/mini-sites/wars-and-operations/operation-accountability/ | UNSUPPORTED (no retrievable content) |
| evt_1993_operation_accountability | neutrality | "warning civilians in the south to leave" | HRW/Rabin: driving refugees toward Beirut to pressure the government was a stated aim. 2 Israeli civilians were killed and 24 wounded by Hezbollah rockets, which is missing from summary and effects | HRW 1996 | BIASED |
| evt_1994_nobel_peace | date | 1994-10-14 | Press release "Oslo, October 14, 1994" | https://www.nobelprize.org/prizes/peace/1994/press-release/ | CORRECT |
| evt_1994_nobel_peace | summary / place | Joint prize "for their efforts to create peace in the Middle East"; presented Oslo 10 Dec | Verbatim motivation; Oslo City Hall, 10 Dec 1994 | nobelprize.org summary + ceremony-speech | CORRECT |
| evt_1994_nobel_peace | source S326 | Supports | Supports (WebFetch 403, curl OK) | https://www.nobelprize.org/prizes/peace/1994/summary/ | CORRECT |
| evt_1994_nobel_peace | neutrality | — | Neutral | — | CORRECT |
| evt_1995_rabin_assassination | date / place | 4 Nov 1995, Kings of Israel Sq, Tel Aviv | Same | https://www.jewishvirtuallibrary.org/the-assassination-of-yitzhak-rabin | CORRECT |
| evt_1995_rabin_assassination | assassin / successor / sentence | Yigal Amir; Peres; life, Mar 1996 | Same (life + 6 yrs, Mar 1996) | same | CORRECT |
| evt_1995_rabin_assassination | Shamgar finding "no conspiracy" | Serious lapses, no conspiracy | Shamgar (report 28 Mar 1996) criticised Shin Bet for security failures. Neither JVL nor wp says it found "no conspiracy", and Hagai Amir and Dror Adani were convicted of conspiracy to murder | JVL; wp Shamgar_Commission | UNSUPPORTED / misleading |
| evt_1995_rabin_assassination | neutrality | — | Neutral | — | CORRECT |
| evt_1996_bus_bombings | dates | 25 Feb–4 Mar 1996 | Same | https://www.un.org/unispal/document/auto-insert-196309 | CORRECT |
| evt_1996_bus_bombings | 26 killed bus 18 (25 Feb) | 26 | 26 (State Dept, UN) | https://irp.fas.org/threat/terror_96/middle.html | CORRECT |
| evt_1996_bus_bombings | 1 killed Ashkelon | 1 | State Dept says "two persons" (likely incl. bomber); MFA says 1 victim | FAS | CORRECT (note) |
| evt_1996_bus_bombings | 19 killed bus 18 (3 Mar) | 19 | 19 | UN DPR; FAS | CORRECT |
| evt_1996_bus_bombings | 13–14 Dizengoff | 13–14 | UN/NYT 14; 13 victims excluding bomber (wp); State Dept says 20 | UN; FAS | CORRECT (range) |
| evt_1996_bus_bombings | total 59–61 | ~60, UN 61 | UN 61; victim sum 59; State Dept says 65. "israel" bucket includes 3 US citizens | UN; FAS | CORRECT (note) |
| evt_1996_bus_bombings | Hamas / Ayyash revenge | Hamas; revenge for Ayyash | Supported by UN. Dizengoff was claimed by Hamas *and* PIJ (State Dept) | UN; FAS | CORRECT (minor nuance) |
| evt_1996_bus_bombings | Summit: 29 countries, 13 Mar | 29 | State Dept: "29 world leaders"; UN chronology: "27 nations" | FAS; UN | CORRECT (sources differ) |
| evt_1996_bus_bombings | source S331 | MFA list | Cited URL returns 404 (dead) | embassies.gov.il MFA page | UNSUPPORTED (dead link; figures supported elsewhere) |
| evt_1996_bus_bombings | neutrality | — | Neutral | — | CORRECT |
| evt_1998_mirabilis_icq | date | 1998-06-08 | 8 Jun 1998 | https://en.wikipedia.org/wiki/ICQ (cites NYT) | CORRECT |
| evt_1998_mirabilis_icq | $287M + up to $120M | Same | $287M upfront + $120M performance over 3 yrs | same | CORRECT |
| evt_1998_mirabilis_icq | "founded 1996 by five young Israelis" | 5 young | Four young developers (Vardi, Goldfinger, Vigiser, Amir), and some sources count Arik's father Yossi Vardi (b. 1942) as the fifth. He was an investor, not "young" | wp Mirabilis_(company); wp ICQ | WRONG (minor wording) |
| evt_1998_mirabilis_icq | place | tel_aviv | Tel Aviv-based | wp Mirabilis | CORRECT |
| evt_1998_mirabilis_icq | source S381 | NYT | NYT blocks fetch (403/blocked). Claim matches NYT headline and wp | nytimes.com URL | UNSUPPORTED (inaccessible; claim OK) |
| evt_2000_october_events | dates | 1–8 Oct 2000 | 1–8 Oct 2000 | wp October_2000_events | CORRECT |
| evt_2000_october_events | killed 12 citizens + 1 Gaza resident | 12 + 1 | Same | https://www.972mag.com/thirteen-killed-no-one-punished-remembering-october-2000/ | CORRECT |
| evt_2000_october_events | Or Commission dates/findings, no indictments | Appointed Nov 2000; report Sep 2003; fire unjustified; snipers illegal; no indictment | Report 1–2 Sep 2003. Live fire found unjustified. Sniper fire was "in direct contravention of police orders" ("illegal" is Adalah's wording). No indictments (2005/2008) | JVL Or summary; +972 | CORRECT (note "illegal") |
| evt_2000_october_events | places | galilee | Also Wadi Ara/Umm al-Fahm (3 killed there) and Jaffa | wp | CORRECT (incomplete) |
| evt_2000_october_events | source S346 | +972 supports | WebFetch OK (curl 403). Supports the 13 and no indictments, but gives no appointment date or sniper finding | +972 | CORRECT (partial) |
| evt_2000_october_events | neutrality | Arab deaths only | A Jewish citizen, Bachor Jan, was killed by a stone near Jisr az-Zarqa on 2 Oct (link to protests unclear). Jewish counter-riots are also omitted | wp; wp Or_Commission | BIASED (minor omission) |
| evt_2003_or_commission | date | 2003-09-01 | Released 1 Sep 2003 (some sources say 2 Sep) | NYT 1 Sep 2003 via wp; JVL | CORRECT |
| evt_2003_or_commission | findings | Live fire unjustified; snipers illegal; criticised Arab leaders; no charges | All present in report summary | https://www.jewishvirtuallibrary.org/the-official-summation-of-the-or-commission-report-september-2003 | CORRECT |
| evt_2003_or_commission | places | jerusalem, nazareth, umm_al_fahm | Reasonable | — | CORRECT |
| evt_2003_or_commission | neutrality | Mentions criticism of Arab leaders only | Omits the core finding of long-standing state "prejudice and neglect"/discrimination toward Arab citizens, and that it recommended removing Minister Ben-Ami and censured police chiefs | wp Or_Commission; JVL | BIASED |
| evt_2004_yassin_rantisi | dates | 22 Mar & 17 Apr 2004 | Same | https://www.pbs.org/newshour/politics/middle_east-jan-june04-mideast_04-19 | CORRECT |
| evt_2004_yassin_rantisi | place / method | Gaza City, helicopter missiles | Same | PBS; wp | CORRECT |
| evt_2004_yassin_rantisi | bodyguards & bystanders | Yes | Yassin strike killed ~9 others; Rantisi strike killed his son and a bodyguard | wp Assassination_of_Ahmed_Yassin | CORRECT |
| evt_2004_yassin_rantisi | "days after Bush endorsed" | Days after | Bush endorsement 14 Apr; PBS: "last week" | PBS | CORRECT |
| evt_2004_yassin_rantisi | neutrality | — | Acknowledges bystander deaths | — | CORRECT |
| evt_2004_arafat_death | date / place | 11 Nov 2004, French mil. hospital near Paris | Percy hospital, Clamart, 11 Nov 2004 | https://news.bbc.co.uk/2/hi/middle_east/4005027.stm | CORRECT |
| evt_2004_arafat_death | funeral/burial | Cairo funeral; Muqata'a burial | Same | BBC | CORRECT |
| evt_2004_arafat_death | "sudden illness" | sudden | BBC: "weeks of mystery stomach pains"; illness began 12 Oct ("short illness" is more precise) | BBC; wp | CORRECT (minor wording) |
| evt_2004_arafat_death | neutrality | — | Neutral | — | CORRECT |
| evt_2006_election | date / seats | 28 Mar 2006; 29/19/12/12/11/7 | Same | https://en.idi.org.il/israeli-elections-and-parties/elections/2006/ | CORRECT |
| evt_2006_election | coalition 67 | Kadima, Labor, Shas, Gil = 67 | Same (initial; Yisrael Beitenu joined Oct 2006 → 78) | IDI | CORRECT |
| evt_2006_election | neutrality | — | Neutral (party list partial, e.g. NU-NRP 9 omitted) | — | CORRECT |
| evt_2006_second_lebanon_war | dates | 12 Jul–14 Aug 2006 | Same; UNSC 1701 adopted 11 Aug | https://israeled.org/second-lebanon-war-begins/ | CORRECT |
| evt_2006_second_lebanon_war | trigger | Soldiers killed, 2 captured | 3 killed, 2 captured (plus 5 killed in pursuit) | CIE | CORRECT |
| evt_2006_second_lebanon_war | Lebanese killed 1,109–1,191 | 1,109 (HRW) – 1,191 (Lebanese) | HRW "at least 1,109"; Lebanese HRC/Amnesty 1,191; some estimates up to ~1,300 | https://www.hrw.org/reports/2007/lebanon0907/ ; wp | CORRECT (HRW figure is a floor) |
| evt_2006_second_lebanon_war | Israeli killed 164–165 | 121 soldiers + 43–44 civ. | HRW 43 civ.; MFA/wp 44; 121 IDF | HRW; wp | CORRECT |
| evt_2006_second_lebanon_war | displaced ~1M Lebanese | 1,000,000 | HRW "an estimated 1 million" | HRW | CORRECT |
| evt_2006_second_lebanon_war | source S372 (CIE) | 43–44 Israeli civ.; 1,191 Lebanese | CIE gives **19** Israeli civilians and ">1,000" Lebanese. Al-Monitor gives ~1,200 / ~160 | CIE; https://www.al-monitor.com/originals/2024/10/israel-hezbollah-war-what-un-resolution-1701 | UNSUPPORTED (cited source doesn't contain the figures) |
| evt_2006_second_lebanon_war | choice note (Winograd) | Alternatives not adequately examined | Winograd: no serious discussion of options; went to war without choosing among them | wp Winograd_Commission | CORRECT |
| evt_2006_second_lebanon_war | neutrality | Displacement lists Lebanese only | 300,000–500,000 Israelis also displaced from the north (HRW: >350,000 evacuated) | wp; HRW | BIASED (omission in effects) |

#### Non-CORRECT findings

- **evt_1988_abu_jihad / neutrality (BIASED, minor):** The raid also killed two bodyguards and a Tunisian gardener, and the UN condemned it (Res. 611). The summary leaves both out.
- **evt_1988_abu_jihad / S305 (UNSUPPORTED):** The Ahram URL returns 403. The facts are supported elsewhere, but note that Israel's 2012 confirmation was unofficial (a censor-cleared interview).
- **evt_1993_operation_accountability / ">150 killed" and S320 (UNSUPPORTED):** Refworld returns 403, so the State Dept figure couldn't be checked. It is plausible next to HRW's ~120 civilians.
- **evt_1993_operation_accountability / S383 (UNSUPPORTED):** The IDF page has no retrievable content.
- **evt_1993_operation_accountability / neutrality (BIASED):** "Warning civilians to leave" leaves out that displacing civilians to pressure Beirut was a stated aim. The 2 Israeli civilians killed and 24 wounded by rockets are also missing.
- **evt_1995_rabin_assassination / Shamgar "no conspiracy" (UNSUPPORTED/misleading):** The cited source does not say this, and two accomplices were convicted of conspiracy. The Commission addressed security failures.
- **evt_1996_bus_bombings / S331 (UNSUPPORTED):** The MFA URL is dead (404). The figures are supported by the UN chronology and the State Dept.
- **evt_1998_mirabilis_icq / "five young Israelis" (WRONG, minor):** The founders were four young developers. The fifth, sometimes counted, was investor Yossi Vardi, then about 54.
- **evt_1998_mirabilis_icq / S381 (UNSUPPORTED):** The NYT can't be fetched. The claim matches the NYT headline and Wikipedia.
- **evt_2000_october_events / neutrality (BIASED, minor):** The Jewish civilian Bachor Jan, killed by a stone on 2 Oct, and the Jewish counter-riots are omitted. Places also leave out Wadi Ara/Umm al-Fahm, though the summary names Wadi Ara.
- **evt_2003_or_commission / neutrality (BIASED):** The summary reports the criticism of Arab leaders but drops the Commission's central finding of state discrimination and neglect. It also drops the sanctions recommended against Minister Ben-Ami and police commanders.
- **evt_2006_second_lebanon_war / S372 (UNSUPPORTED):** The CIE page gives 19 Israeli civilians and does not give 1,191. HRW and Israeli MFA/Lebanese government figures support the claims instead.
- **evt_2006_second_lebanon_war / displacement (BIASED, omission):** The 300,000–500,000 displaced Israeli civilians are missing from the displacement effects.

Minor notes, still graded CORRECT:
- "Snipers illegal" is Adalah's word; the Commission said the sniper fire contravened police orders.
- The summit size is 29 per the State Dept and 27 per the UN.
- The HRW 1,109 is a minimum.
- "Sudden illness" for Arafat would be better as "short illness".
- The coalition was 67 seats only at formation.


### Events 2009-2026 (part 1)

### Fact-check results: pack D1

| id | field | claimed | actual | source URL | verdict |
|---|---|---|---|---|---|
| evt_2013_nobel_levitt_warshel | date | 2013-10-09 | Announced 9 Oct 2013 | https://www.nobelprize.org/prizes/chemistry/2013/summary/ (403 to fetcher; confirmed via search snippet + https://en.globes.co.il/en/article-1000884333) | CORRECT |
| evt_2013_nobel_levitt_warshel | place | rehovot | Weizmann Institute is in Rehovot; the laureates' collaboration began there in the late 1960s | https://embassies.gov.il/MFA/InnovativeIsrael/ScienceTech/Pages/2013-Nobel-Prize-in-Chemistry.aspx | CORRECT |
| evt_2013_nobel_levitt_warshel | laureates/citation | Karplus, Levitt, Warshel; "multiscale models..." | Matches the Nobel citation | nobelprize.org (see above) | CORRECT |
| evt_2013_nobel_levitt_warshel | nationality | Warshel Israeli-born; Levitt Israeli-American-British | Warshel b. Kibbutz Sde Nahum; Levitt b. Pretoria, holds US/UK/Israeli citizenship | https://dornsife.usc.edu/news/stories/a-nobel-victory/ ; https://www2.mrc-lmb.cam.ac.uk/?p=5737 | CORRECT |
| evt_2013_nobel_levitt_warshel | wording "begun in the 1970s partly at Weizmann" | 1970s, partly Weizmann | The collaboration (Lifson lab, Golem computer) began in the late 1960s at Weizmann. The prize-cited QM/MM work (1972-76) was done mostly at Harvard and the MRC-LMB in Cambridge. "Partly" makes the wording defensible | https://embassies.gov.il/MFA/InnovativeIsrael/ScienceTech/Pages/2013-Nobel-Prize-in-Chemistry.aspx | CORRECT (imprecise) |
| evt_2013_nobel_levitt_warshel | cited source S411 | supports claims | URL is valid but returned 403 to the fetcher. Laureates and citation are confirmed through search. The Weizmann detail comes from the Israeli MFA and LMB pages, not checked on the Nobel page | nobelprize.org | CORRECT (not opened) |
| evt_2013_nobel_levitt_warshel | neutrality | n/a | No issue | - | CORRECT |
| evt_2018_great_march_of_return | date (start) | 2018-03-30 | 30 Mar 2018 | https://www.ochaopt.org/content/overview-march-2019 | CORRECT |
| evt_2018_great_march_of_return | date_end | 2019-03-31 | Weekly protests went on until 27 Dec 2019, then were paused until 30 Mar 2020. 31 Mar 2019 is only OCHA's reporting cutoff | https://www.timesofisrael.com/low-turnout-in-last-gaza-border-protest-until-march-2020/ ; https://www.jpost.com/middle-east/gazas-weekly-protests-suspended-for-3-months-612212 | WRONG |
| evt_2018_great_march_of_return | places | gaza_strip, nahal_oz, kfar_aza, beeri | Gaza fence plus Israeli border communities hit by incendiary kites. Plausible | (general reporting) | CORRECT |
| evt_2018_great_march_of_return | OCHA 199 killed by 31 Mar 2019 | 199 | 199 killed (43 children), ~30,300 injured | https://www.ochaopt.org/content/overview-march-2019 | CORRECT |
| evt_2018_great_march_of_return | COI 189 killed by end-2018, 183 by live ammunition | 189 / 183 | COI (A/HRC/40/74): 189 killed 30 Mar-31 Dec 2018, 183 by live ammunition | https://www.un.org/unispal/?p=175830 ; https://en.wikipedia.org/wiki/United_Nations_Independent_Commission_on_the_2018_Gaza_border_protests | CORRECT |
| evt_2018_great_march_of_return | possible crimes against humanity; Israel rejected | yes | COI cited possible war crimes or crimes against humanity. Israel "utterly rejected" the report (FM Katz) | https://amp.cnn.com/cnn/2019/02/28/middleeast/israel-gaza-un-intl ; https://voanews.com/a/4807774.html | CORRECT |
| evt_2018_great_march_of_return | Israel killed 1 | 1 soldier killed outside protest sites | The COI says the same (Sgt. Aviv Levi, 20 Jul 2018) | https://www.jurist.org/news/2019/02/un-finds-israel-may-have-committed-crimes-against-humanity-during-gaza-protests | CORRECT |
| evt_2018_great_march_of_return | casualties range | 189-199 | Within the 31 Mar 2019 cutoff. The full protest period ran past it: OCHA counted 210 by Oct 2019. The range understates the full event | https://www.un.org/unispal/wp-content/uploads/2019/10/OCHAPoC_181019.pdf | CORRECT (incomplete) |
| evt_2018_great_march_of_return | cited sources S424/S425 | support | OCHA page supports 199/43. JURIST supports 189, the soldier and crimes against humanity, but has no "183 live ammunition" and no Israeli rejection (both come from the COI press release and CNN/VOA) | ochaopt.org ; jurist.org | CORRECT (S425 partial) |
| evt_2018_great_march_of_return | neutrality | n/a | Gives both unarmed protesters and violent acts, Palestinian deaths, the Israeli death and Israel's rejection. Balanced | - | CORRECT |
| evt_2018_netta_eurovision | date/place in summary | 12 May 2018, Lisbon | Correct | https://eurovisionworld.com/esc/israel-wins-eurovision-song-contest-2018 | CORRECT |
| evt_2018_netta_eurovision | numbers | 529 pts; 1st televote, 3rd jury; 4th Israeli win | 529 = 317 televote (1st) + 212 jury (3rd). Israel's 4th win (1978, 1979, 1998, 2018) | https://en.wikipedia.org/wiki/Toy_(song) ; https://escinsight.com/2018/05/16/eurovision-2018-and-momentum-a-follow-up/ | CORRECT |
| evt_2018_netta_eurovision | places field | tel_aviv | The contest was in Lisbon. Tel Aviv was the 2019 host and the site of the homecoming celebration. Defensible, but "abroad" would be more accurate | - | CORRECT (note) |
| evt_2018_netta_eurovision | cited source S427 | CBC | 403 to fetcher. The claims are confirmed by other outlets | cbc.ca | CORRECT (not opened) |
| evt_2018_netta_eurovision | neutrality | n/a | No issue | - | CORRECT |
| evt_2018_us_embassy_jerusalem | date | 2018-05-14 | 14 May 2018 | https://www.axios.com/palestinian-protestors-killed-gaza-strip-israel-us-embassy-jerusalem-17010ca9-4d1f-4e3e-b062-f65595a5fbff.html | CORRECT |
| evt_2018_us_embassy_jerusalem | "Israel's 70th anniversary" | 70th anniversary | 70th Gregorian anniversary of the 14 May 1948 declaration. Israel's official (Hebrew-calendar) Independence Day 2018 was 19 April | - | CORRECT (note) |
| evt_2018_us_embassy_jerusalem | killed/wounded | >=58 killed, >2,700 wounded; range 58-60 | Day-of reports: 58-60 killed, 2,700+ wounded (Gaza MoH). Later tolls: 60-62 (some outlets 63). Hamas official claimed 50 of 62 were Hamas members; the IDF said at least 24 were militants | https://thejc.com/news/world/senior-hamas-figure-says-50-of-62-gaza-border-deaths-were-its-own-members-sj7reufe ; https://english.ahram.org.eg/News/299523.aspx | CORRECT (upper bound should be ~62) |
| evt_2018_us_embassy_jerusalem | "deadliest since 2014" | yes | Widely reported as the deadliest day since the 2014 war | https://globalnews.ca/news/4208798/palestinians-bury-dead-israel-troops-gaza-2014 | CORRECT |
| evt_2018_us_embassy_jerusalem | places | jerusalem, gaza_strip | Correct | - | CORRECT |
| evt_2018_us_embassy_jerusalem | cited source S423 | Gazette/AP | 403 to fetcher. The AP figures (58 killed, 2,700 wounded) match syndicated reporting | gazette.com | CORRECT (not opened) |
| evt_2018_us_embassy_jerusalem | neutrality | n/a | States the casualties plainly. It leaves out Israel's account (breach attempts, militants among the dead), but this does not exclude any population. Minor context gap | - | CORRECT |
| evt_2018_jerusalem_tel_aviv_railway | date | 2018-09-25 | Regular Jerusalem (Yitzhak Navon)-Ben Gurion service began Tue 25 Sep 2018 | https://www.timesofisrael.com/jerusalems-new-high-speed-train-starts-regular-trips-to-ben-gurion-airport/ | CORRECT |
| evt_2018_jerusalem_tel_aviv_railway | through service to Tel Aviv | Dec 2019, ~32 min | Through trains started 21 Dec 2019 to Tel Aviv HaHagana, ~30-34 min | https://en.globes.co.il/en/article-jerusalem-tel-aviv-fast-rail-link-finally-begins-operations-1001311940 | CORRECT |
| evt_2018_jerusalem_tel_aviv_railway | "deep-level", electrified | yes | Station ~80 m underground, line electrified | same Globes article | CORRECT |
| evt_2018_jerusalem_tel_aviv_railway | places | jerusalem, tel_aviv, modiin | The line passes near Modi'in but does not serve Modi'in station. It also crosses the Green Line (Canada Park area), which is not mentioned. Acceptable | - | CORRECT (note) |
| evt_2018_jerusalem_tel_aviv_railway | cited source S446 | Globes + ToI | The cited Globes URL is the Dec 2019 article (supports Tel Aviv, 80 m, 32 min). The Sep 2018 opening is supported by the ToI article, which is named but not linked | en.globes.co.il | CORRECT |
| evt_2018_jerusalem_tel_aviv_railway | neutrality | n/a | No issue | - | CORRECT |
| evt_2019_september_election | date | 2019-09-17 | 17 Sep 2019 | https://www.timesofisrael.com/checked-and-double-checked-elections-committee-publishes-final-results/ | CORRECT |
| evt_2019_september_election | seats | B&W 33, Likud 32 | Final CEC results (25 Sep 2019): B&W 33, Likud 32 | https://en.globes.co.il/en/article-1001301966 ; https://israelhayom.com/2019/09/25/final-election-results-see-likud-up-to-32-knesset-seats | CORRECT |
| evt_2019_september_election | outcome | no coalition, third election Mar 2020 | Third election held 2 Mar 2020 | (general) | CORRECT |
| evt_2019_september_election | cited source S429 | ToI | The cited URL is the APRIL 2019 results article (Likud 36 / B&W 35 final). It does not contain the Sept figures. The S429 note says "each 35", which does not match the 36/35 on that same URL | https://www.timesofisrael.com/4335320-ballots-cast-who-got-what/ | UNSUPPORTED (wrong URL; claim true per other ToI article) |
| evt_2019_september_election | neutrality | n/a | Omits the Joint List's 13 seats (third largest). Not a bias issue for a 1-line summary | - | CORRECT |
| evt_2020_unity_government | date | 2020-04-20 (month) | Agreement signed 20 Apr 2020. Government sworn in 17 May 2020 | https://en.globes.co.il/en/article-netanyahu-gantz-agree-unity-government-1001325957 | CORRECT |
| evt_2020_unity_government | rotation 18 months; Gantz defence minister | yes | Globes: Netanyahu 18 mo then Gantz 18 mo. Gantz alternate/deputy PM and defence minister | same | CORRECT |
| evt_2020_unity_government | collapse; dissolution; election date | budget failure; Dec 2020; 23 Mar 2021 | Knesset dissolved automatically at midnight 22/23 Dec 2020 over the budget. Election 23 Mar 2021 | https://en.globes.co.il/en/article-knesset-dissolves-after-budget-fails-to-pass-1001354047 ; https://en.idi.org.il/articles/36549 | CORRECT |
| evt_2020_unity_government | cited source S431 | Globes + Israel Hayom | The Globes URL supports the agreement terms. The dissolution part comes from the Israel Hayom piece, which is not linked | en.globes.co.il | CORRECT |
| evt_2020_unity_government | neutrality | n/a | No issue | - | CORRECT |
| evt_2020_sudan_normalization | date | 2020-10-23 | Normalization agreed 23 Oct 2020 (US-Israel-Sudan joint statement) | https://www.aljazeera.com/news/2021/1/6/sudan-says-it-signed-abraham-accords-with-us | CORRECT |
| evt_2020_sudan_normalization | 6 Jan 2021 Khartoum signing | yes | Justice Minister Abdulbari signed the Abraham Accords Declaration with Mnuchin in Khartoum, 6 Jan 2021 | same | CORRECT |
| evt_2020_sudan_normalization | "bilateral agreement unratified" | yes | Text "finalized" Feb 2023, signing deferred. Not signed or ratified as of the latest reporting found (war since Apr 2023). 2026 status could not be re-checked live (search budget exhausted) | https://en.wikipedia.org/wiki/Abraham_Accords ; https://newarab.com/news/sudan-unhappy-israel-normalisation-developments | CORRECT |
| evt_2020_sudan_normalization | places | abroad | OK | - | CORRECT |
| evt_2020_sudan_normalization | cited source S435 | MEI explainer | 403 to fetcher. The claims are confirmed by Al Jazeera and Gulf News | mei.edu | CORRECT (not opened) |
| evt_2020_sudan_normalization | neutrality | n/a | Could mention it was tied to US removing Sudan from the terror-sponsor list. Not a bias issue | - | CORRECT |
| evt_2020_vaccination_campaign | date | 2020-12-20 | AP: drive began Sun 20 Dec 2020. Netanyahu vaccinated the evening of 19 Dec | https://www.clickondetroit.com/news/world/2020/12/20/israel-begins-virus-inoculation-drive-as-infections-surge/ | CORRECT |
| evt_2020_vaccination_campaign | priority groups; "one of world's fastest" | health workers, elderly, high-risk | AP confirms the priority order. ~20% of population got a first dose in about 3 weeks | same ; https://en.wikipedia.org/wiki/COVID-19_vaccination_in_Israel | CORRECT |
| evt_2020_vaccination_campaign | "using Pfizer and Moderna doses" | both | The campaign launched with Pfizer only. The first Moderna batch (~100-120k) arrived 7 Jan 2021 and was used marginally. Overstated | https://www.timesofisrael.com/first-batch-of-moderna-vaccines-arrives-in-israel/ | WRONG (minor; overstated) |
| evt_2020_vaccination_campaign | "secured for most of its population" | most | Pfizer 8M doses (~4M people) + Moderna 6M (~3M) of ~9.3M | https://lbc.co.uk/world-news/7dc69c4395e34a8192fd1770dd48611e | CORRECT |
| evt_2020_vaccination_campaign | places | tel_aviv, jerusalem | Nationwide. Acceptable | - | CORRECT |
| evt_2020_vaccination_campaign | cited source S434 | Gulf News | The cited URL is the 21 Feb 2020 first-case article. It does not mention the vaccine campaign. The Deccan Herald/AP item is named but not linked | https://gulfnews.com/world/mena/israel-confirms-first-coronavirus-case-in-cruise-ship-returnee-1.1582291738259 | UNSUPPORTED (by cited URL; claim true per AP) |
| evt_2020_vaccination_campaign | neutrality | n/a | Omits Palestinians in the West Bank/Gaza: vaccine access was a major international controversy (UN experts, Amnesty, HRW). Arab citizens and East Jerusalem residents were included in the campaign | https://fortune.com/2021/01/05/covid-19-israel-vaccines-moderna-lockdown-palestine | BIASED (omission) |

#### Non-CORRECT findings

- **evt_2018_great_march_of_return / date_end (WRONG):** The protests did not end on 31 Mar 2019. Weekly marches went on until 27 Dec 2019, and 31 Mar 2019 is only OCHA's reporting cutoff. Either set date_end to 2019-12-27, or say in the text that the figures run to Mar 2019. OCHA's count reached 210 by Oct 2019.
- **evt_2019_september_election / cited source (UNSUPPORTED):** The S429 URL is ToI's April 2019 results article, which shows Likud 36 / B&W 35 and does not contain the Sept 2019 results. The S429 note "each 35" is also wrong for April: the final result was Likud 36 (35 on election night). The Sept claim itself is true. Link the ToI "checked-and-double-checked" article instead.
- **evt_2020_vaccination_campaign / "Pfizer and Moderna doses" (WRONG, minor):** The campaign ran on Pfizer. Moderna doses arrived only on 7 Jan 2021, in small numbers. Suggested wording: "mainly Pfizer doses, with additional Moderna supply".
- **evt_2020_vaccination_campaign / cited source (UNSUPPORTED):** The S434 URL is the Feb 2020 first-case story and says nothing about vaccination. Link the AP 20 Dec 2020 story instead.
- **evt_2020_vaccination_campaign / neutrality (BIASED, omission):** The summary leaves out the dispute over vaccine access for Palestinians in the West Bank and Gaza, which was a prominent part of international coverage of the campaign.

Minor notes (no change in verdict):
- **evt_2018_us_embassy_jerusalem:** Later death tolls are 60-62, so a range of 58-62 would be better. "70th anniversary" is the Gregorian date; Yom Ha'atzmaut 2018 was 19 April.
- **evt_2018_netta_eurovision:** The places field lists tel_aviv, but the win was in Lisbon.
- **evt_2018_great_march_of_return:** JURIST (S425) has neither the "183 live ammunition" figure nor Israel's rejection. Both are supported by UNISPAL/COI and CNN/VOA.

Several cited URLs returned HTTP 403 to the fetcher (nobelprize.org, CBC, gazette.com, mei.edu). For those, the claims were checked against equivalent sources. The web search budget ran out before every claim could be re-checked live; the last one affected was the 2026 status of the Sudan ratification.


### Events 2009-2026 (part 2)

### Fact-check results: pack D2

Method: I opened the cited URLs with WebFetch where they loaded, and checked them against Wikipedia's articles and their sources. The session's shared WebSearch budget ran out early in this audit, so a few items (the AFP 1,218 figure, Gvili's unit) could not be checked again with a live search. They are marked accordingly.

| id | field | claimed | actual | source URL | verdict |
|---|---|---|---|---|---|
| evt_2021_bennett_lapid_government | date | 2021-06-13 | Knesset vote / swearing-in 13 Jun 2021 | https://en.globes.co.il/en/article-naftali-bennett-sworn-in-as-israels-13th-prime-minister-1001374311 | CORRECT |
| evt_2021_bennett_lapid_government | vote 60-59; 8 parties | 60-59, 8 parties | 60-59 (1 Ra'am abstention); 8 parties | https://en.wikipedia.org/wiki/Thirty-sixth_government_of_Israel | CORRECT |
| evt_2021_bennett_lapid_government | "Netanyahu's 12 consecutive years" | 12 yrs | Mar 2009 to Jun 2021 = 12 yrs. Globes (S439) does not say this | Wikipedia (above) | CORRECT (S439 doesn't support it) |
| evt_2021_bennett_lapid_government | Ra'am "first Arab party to join a governing coalition" | first Arab party | "first **independent** Arab party". Mapai-affiliated Arab lists sat in coalitions in the 1950s-70s. Globes doesn't say this | Wikipedia (above) | WRONG (minor overstatement) |
| evt_2021_bennett_lapid_government | coalition fall / Lapid PM / election | Jun 2022; 1 Jul 2022; 1 Nov | Announced 20 Jun 2022; Lapid PM at midnight 30 Jun-1 Jul; election 1 Nov 2022 | https://www.timesofisrael.com/yair-lapid-takes-over-as-israels-14th-prime-minister/ | CORRECT |
| evt_2021_bennett_lapid_government | places / neutrality | jerusalem, rahat | Rahat stands in for Ra'am's Negev Bedouin base, which is reasonable. Wording is neutral | n/a | CORRECT |
| evt_2023_october_7_attack | date / places | 2023-10-07; Be'eri, Kfar Aza, Nir Oz, Nahal Oz, Sderot, Ofakim | Correct; Nova festival near Re'im | https://en.wikipedia.org/wiki/October_7_attacks | CORRECT |
| evt_2023_october_7_attack | killed ~1,200 | about 1,200 | Israel revised its toll to about 1,200 (Nov 2023). Wikipedia: 1,195 (828 civilians, 367 security forces) | NPR S448 (timed out); https://en.wikipedia.org/wiki/October_7_attacks | CORRECT |
| evt_2023_october_7_attack | AFP tally 1,218 | 1,218 | Cited S449 (KTVU/AP) does **not** contain 1,218 or any AFP figure, only "around 1,200". AFP has used several running totals (1,163, 1,189, 1,206, 1,218/1,219/1,221). 1,218 is plausible for one point in time but could not be confirmed | https://www.ktvu.com/news/israel-hamas-war-two-years-later | UNSUPPORTED (cited source lacks it) |
| evt_2023_october_7_attack | "most of them civilians"; "deadliest day" | yes | 828 of 1,195 were civilians; widely described as the deadliest day in Israel's history | Wikipedia (above) | CORRECT |
| evt_2023_october_7_attack | hostages 251 | 251 | 251 | KTVU S449; Wikipedia | CORRECT |
| evt_2023_october_7_attack | ~1,600 attackers killed in Israel (IDF) | 1,600 | ToI: IDF says "another 1,600 terrorists inside Israel". Wikipedia infobox gives about 1,200 per Israel. Attributed to the IDF, so defensible | https://www.timesofisrael.com/idf-believes-70000-gazans-killed-in-war-as-claimed-by-hamas/ | CORRECT (attributed IDF figure) |
| evt_2023_october_7_attack | neutrality | n/a | Factual and attributed. Gaza deaths belong to other events | n/a | CORRECT |
| evt_2024_iran_april_attack | dates | 1 Apr Damascus; 13-14 Apr; 19 Apr | All correct | https://www.thenationalnews.com/news/mena/2024/04/19/israel-attacks-isfahan-military-base-in-iran/ | CORRECT |
| evt_2024_iran_april_attack | >300 drones and missiles | >300 | IDF: about 170 drones, 30 cruise and 120 ballistic missiles (about 320) | https://en.wikipedia.org/wiki/April_2024_Iranian_strikes_on_Israel | CORRECT |
| evt_2024_iran_april_attack | interceptors: US, UK, France, Jordan | 4 partners | Confirmed by Wikipedia. The cited National article names only the US | Wikipedia (above) | CORRECT (S458 supports it only partly) |
| evt_2024_iran_april_attack | 19 Apr "air-defence site near Isfahan"; Iran downplayed | yes | Strike near Isfahan / 8th Shekari air base; Iran played it down (drones "shot down"). S458 doesn't name the air-defence (S-300 radar) target | S458; Wikipedia | CORRECT |
| evt_2024_iran_april_attack | neutrality / casualties | no casualties mentioned; place "negev" | Omits the one serious casualty: a 7-year-old Bedouin girl (Amina al-Hasouni) critically injured near Arad. Nevatim was also hit | Wikipedia (above) | BIASED (minor omission) |
| evt_2024_iran_october_strikes | date 26 Oct; ~180 missiles 1 Oct | 26 Oct; 180 | Correct (the IDF figure was about 180) | https://en.wikipedia.org/wiki/October_2024_Israeli_strikes_on_Iran | CORRECT |
| evt_2024_iran_october_strikes | targets | air defences, solid-fuel missile production | S-300 sites; 12 planetary mixers at Parchin/Khojir (Tehran province) | Wikipedia (above) | CORRECT |
| evt_2024_iran_october_strikes | Iran said 4 servicemen killed | 4 | Iran's first statement: 4 soldiers. Later total 5 (4 army plus 1 security guard/civilian) | Wikipedia (above) | CORRECT (could add the 5th) |
| evt_2024_iran_october_strikes | US pressure to avoid nuclear/oil | yes | Confirmed | Wikipedia (above) | CORRECT |
| evt_2024_iran_october_strikes | cited source S462 | FDD | FDD URL returns HTTP 403, so it could not be checked | https://www.fdd.org/analysis/2024/10/26/israel-retaliates-against-iran-regime-with-precision-strikes/ | UNSUPPORTED (source not reachable; claims verified elsewhere) |
| evt_2025_palestine_recognitions | 21 Sep UK, Canada, Australia, Portugal; France 22 Sep | yes | Confirmed. Belgium, Luxembourg, Malta, Monaco and Andorra also recognised on 22 Sep and are omitted | https://www.aljazeera.com/news/2025/9/22/israel-palestine-two-state-solution-summit-to-be-held-as-recognitions-surge | CORRECT |
| evt_2025_palestine_recognitions | Israel/US boycott; Danon "circus" | yes | Confirmed | S474 | CORRECT |
| evt_2025_palestine_recognitions | Danon "rewarded terrorism" | quoted as Danon's | Al Jazeera presents "reward terrorism" as Israel's general line (Netanyahu said it too), not a direct Danon quote | S474 | CORRECT (minor attribution looseness) |
| evt_2025_palestine_recognitions | neutrality | only Israel's reaction | Gives Israel's/US framing only. Leaves out the recognising states' reasons (Gaza war, two-state solution) and the Palestinian/PA reaction | n/a | BIASED (minor, one-sided framing) |
| evt_2026_last_hostage_returned | date 26 Jan 2026; Gaza City cemetery | yes | IDF announced 26 Jan 2026; cemetery between Shujaiya and Daraj-Tuffah, Gaza City; buried 28 Jan | https://www.ynetnews.com/article/byi00z11elzg ; https://en.wikipedia.org/wiki/Ran_Gvili | CORRECT |
| evt_2026_last_hostage_returned | "Border Police officer" | Border Police | Ynet (S494) says Border Police. Wikipedia: Israel Police **Negev Yasam** unit (not Magav/Border Police). Sources conflict; Yasam appears more accurate | Ynet; Wikipedia | WRONG (likely; minor, unit mislabelled) |
| evt_2026_last_hostage_returned | killed defending Alumim; last of the 251 | yes | Confirmed | Ynet; Wikipedia | CORRECT |
| evt_2026_last_hostage_returned | precondition for Phase 2 and Rafah | yes | Ynet confirms both | Ynet | CORRECT |
| evt_2026_last_hostage_returned | cited S495 BBC | BBC | Not fetchable by this tool. The claim is confirmed by Ynet and Wikipedia | https://www.bbc.com/news/articles/c5ydvz7nz4mo | UNSUPPORTED (unverifiable source; claim OK) |
| evt_2026_iran_war | date 28 Feb; Roaring Lion / Epic Fury | yes | Confirmed | https://www.timesofisrael.com/us-and-israel-launch-major-joint-assault-on-iran-trump-indicates-goal-is-to-topple-regime/ | CORRECT |
| evt_2026_iran_war | Khamenei killed; Mojtaba succeeded | yes | Confirmed (Mojtaba designated 8 Mar). The S483 ToI day-one article does not confirm the killing; CFR does | https://www.cfr.org/global-conflict-tracker/conflict/confrontation-between-united-states-and-iran | CORRECT |
| evt_2026_iran_war | ~650 ballistic missiles; "many" cluster | 650; many | About 650 by 8 Apr; "more than half" carried cluster warheads | https://www.timesofisrael.com/650-iranian-missiles-fired-24-killed-and-10800-israeli-strikes-the-war-in-numbers/ | CORRECT |
| evt_2026_iran_war | Hormuz closed; struck US bases / Gulf | yes | Confirmed | CFR | CORRECT |
| evt_2026_iran_war | 24 killed (20 Israel + 4 WB Palestinians); 7,000+ injured | yes | Confirmed as of 8 Apr. At least one West Bank death (Beit Awwa) is disputed: possibly an errant Israeli interceptor | ToI S484; https://en.wikipedia.org/wiki/2026_Iran_war | CORRECT |
| evt_2026_iran_war | effects casualties.israel_civilians killed [20,24] | 20-24 "Israel civilians" | The upper bound counts 4 West Bank Palestinians as "israel_civilians". Wikipedia's later total is 31 civilians in Israel (whole war) | ToI; Wikipedia | WRONG (mislabelled category) |
| evt_2026_iran_war | HRANA 1,701 civilian deaths | 1,701 | CFR: HRANA documented 1,701 civilians. Later HRANA figures: 1,721 civilians, 3,684 total | CFR; Wikipedia | CORRECT (summary) |
| evt_2026_iran_war | effects casualties.iran killed [1701,1701] | 1,701 total Iranian dead | That is the civilian-only count. Total Iranian dead: 3,528 (Iranian government) or 3,684 (HRANA incl. 1,249 military); US/Israel claim 6,000+ military | Wikipedia (above) | WRONG (understates total; should be labelled civilians or use about 3,500-3,700) |
| evt_2026_iran_war | up to 3.2 million displaced | 3.2M (low = high) | CFR says "up to 3.2 million", citing UNHCR. The data sets low = high at the ceiling | CFR | CORRECT (low bound should be lower; note says CFR but the origin is UNHCR) |
| evt_2026_iran_war | ceasefire 7-8 Apr; Pakistan MOU 14 Jun; no durable settlement as of Oct 2026 | yes | Agreed 7 Apr, in effect 8 Apr. MOU signed 14 Jun, formally signed by Trump and Pezeshkian 17 Jun. CFR (Oct 2026) status: "Worsening" | CFR; Wikipedia | CORRECT |
| evt_2026_iran_war | effects diplo usa "relations_established" | n/a | Odd mechanic (the US-Israel relationship already exists), not a factual claim | n/a | n/a |
| evt_2026_iran_war | neutrality | n/a | Includes Iranian civilians, displaced people, Palestinians and Israelis. Balanced | n/a | CORRECT |
| evt_2026_beit_shemesh_strike | date / place / 9 killed, 28 injured (MDA) | yes | Confirmed: 1 Mar 2026, at least 9 killed, 28 injured (2 seriously) | https://www.aljazeera.com/news/2026/3/1/at-least-nine-killed-after-iranian-strike-on-israels-beit-shemesh | CORRECT |
| evt_2026_beit_shemesh_strike | "highest single-day toll in the war's opening days" | single-day | Al Jazeera: "highest casualty count" since the attacks began. It was a single-strike toll, not a daily total. The final toll could not be checked | S485 | CORRECT (wording slightly loose) |
| evt_2026_lebanon_war | date 2 Mar; Hezbollah fired after Khamenei's killing | yes | Fighting resumed 2 Mar, two days after the killing. Hezbollah said its fire was "unrelated to the Iran war". S486 doesn't state the trigger | https://en.wikipedia.org/wiki/2026_Lebanon_war | CORRECT (trigger is attributed causation; Hezbollah disputes it) |
| evt_2026_lebanon_war | evacuation orders ~14%; Katz on occupation | yes | NRC: 1,470+ sq km, about 14%. Katz: occupation continues / security zone up to the Litani | https://www.aljazeera.com/news/2026/4/7/how-israels-invasion-of-southern-lebanon-created-a-humanitarian-crisis | CORRECT |
| evt_2026_lebanon_war | 2,089 killed incl. 165 children "(Lebanese health ministry)" by mid-April; 1.2M displaced | yes | S487 gives 2,089 incl. 165 children and 1.2M+ displaced, but does not attribute them to the health ministry. S486: 1,497 by early April (health ministry) | https://www.aljazeera.com/news/2026/4/14/israel-lebanon-direct-talks-in-the-us-all-to-know | CORRECT (attribution UNSUPPORTED in S487) |
| evt_2026_lebanon_war | effects diplo lebanon "war" | Lebanon state at war | The Lebanese government condemned Hezbollah's fire (PM Salam) and banned its military activity, then held direct talks with Israel on 14 Apr. The state was not a belligerent | S487; Wikipedia | WRONG (game effect misstates Lebanon's position) |
| evt_2026_lebanon_war | neutrality | n/a | Covers Lebanese deaths, children and displacement, and Hezbollah fire on northern Israel. Gives no Israeli casualty figures (about 40 soldiers, 3 civilians). Balanced overall | Wikipedia | CORRECT |

#### Findings that are not CORRECT

- **evt_2021_bennett_lapid_government:** "First Arab party to join a governing coalition" overstates it. Ra'am was the first *independent* Arab party; Mapai-affiliated Arab lists sat in earlier coalitions. S439 (Globes) also doesn't support this point or the "12 years" claim.
- **evt_2023_october_7_attack:** The AFP figure of 1,218 is not in the cited S449 (KTVU/AP), which says only "around 1,200". AFP's running total has changed over time, so the exact figure is unsupported as cited.
- **evt_2024_iran_april_attack:** Neutrality: leaves out the only serious casualty, a 7-year-old Bedouin girl critically injured near Arad (Negev).
- **evt_2024_iran_october_strikes:** The cited FDD page returns 403. The claims are confirmed through other sources, but the citation itself can't be checked.
- **evt_2025_palestine_recognitions:** Neutrality: gives only the Israeli/US reaction, with no Palestinian reaction and no reasons from the recognising states. "Rewarded terrorism" was Israel's general line rather than a direct Danon quote. Other states that recognised on 22 Sep (Belgium, Luxembourg, Malta and others) are omitted.
- **evt_2026_last_hostage_returned:** Gvili is called a "Border Police officer". Wikipedia and other reporting place him in the Israel Police's Negev Yasam unit; the cited Ynet says Border Police. The BBC citation (S495) couldn't be checked.
- **evt_2026_iran_war, casualties.israel_civilians:** The upper bound of 24 includes 4 West Bank Palestinians under "israel_civilians". One of those deaths (Beit Awwa) is disputed as possibly caused by an Israeli interceptor.
- **evt_2026_iran_war, casualties.iran killed = 1,701:** This is HRANA's civilian-only count used as the total Iranian dead. The actual total is about 3,500-3,700 (Iranian government 3,528; HRANA 3,684 incl. 1,249 military). The displacement range also sets low = high at "up to 3.2M".
- **evt_2026_lebanon_war, diplo lebanon "war":** The Lebanese state wasn't a belligerent. It condemned Hezbollah, banned its military activity and held direct talks with Israel. The health-ministry attribution for 2,089 isn't in S487, though the number is.


### Cities (15)

### Fact-check: pack_cities.md (15 localities)

Source keys used in table:
- **N95** = CBS nonum.xls (1995-census locality list), archived: https://web.archive.org/web/20120413142708/http://www.cbs.gov.il/mifkad/tables/more_tabeles/pirsom3/nonum.xls (opened; parsed)
- **BC08** = CBS bycode2008.xls, archived: https://web.archive.org/web/20241203161239/https://www.cbs.gov.il/he/publications/doclib/2019/ishuvim/bycode2008.xls (opened; the cbs.gov.il direct URL reset the connection)
- **BC22** = CBS bycode2022.xlsx, archived: https://web.archive.org/web/20250116230038/https://www.cbs.gov.il/he/publications/doclib/2019/ishuvim/bycode2022.xlsx (opened; ITM coords converted with pyproj EPSG:2039 to 4326)
- **P22** = CBS "Population and households by locality - 2022 Census estimate", archived: http://web.archive.org/web/20260213233625/https://www.cbs.gov.il/he/publications/LochutTlushim/2025/Population%20and%20households%20by%20locality%20-%202022%20Census%20estimate.xlsx (opened)
- **LevyI / LevyJ** = https://www.levyinstitute.org/levy-files/pubs/1967_census/vol_1_intro_tab_i.pdf / ..._tab_j.pdf (opened; columns realigned by hand)
- **CP** = https://www.citypopulation.de/en/palestine/cities/
- **WP** = en.wikipedia.org coordinates (via API) / article text; **WD** = Wikidata P625; **OSM** = Nominatim

Coordinate check: for the 11 CBS localities the dataset coordinates match the BC22 ITM point exactly (0.00 km). Distances below are to an independent WP/WD/OSM point.

| id | field | claimed | actual | source URL | verdict |
|---|---|---|---|---|---|
| hod_hasharon | lat/lon | 32.15221, 34.89416 | BC22 same; WP 32.1500, 34.8833 (1.05 km) | BC22; https://en.wikipedia.org/wiki/Hod_HaSharon | CORRECT |
| hod_hasharon | founded | 1924 (1964 merger) | N95, BC08 and BC22 all give 1924 | N95; BC22 | CORRECT |
| hod_hasharon | pop 1961 | 11,576 | 11,576 | N95 | CORRECT |
| hod_hasharon | pop 2022 | 65,020 | 65,020.1 | P22 | CORRECT |
| hod_hasharon | status | Israel from 14 May 1948 | consistent | S100 | CORRECT |
| gedera | lat/lon | 31.81215, 34.78011 | WD 31.8139, 34.7783 (0.26 km) | BC22; https://www.wikidata.org/wiki/Q921505 | CORRECT |
| gedera | founded | 1884 | 1884 | N95; BC22 | CORRECT |
| gedera | pop 1961 | 4,561 | 4,561 | N95 | CORRECT |
| gedera | pop 2022 | 29,260 | 29,260 | P22 | CORRECT |
| gedera | status | Israel from 14 May 1948 | consistent | S100 | CORRECT |
| yad_mordechai | lat/lon | 31.58896, 34.55842 | WP 31.5886, 34.5583 (0.04 km) | BC22; WP | CORRECT |
| yad_mordechai | founded | 1943 (+ May/Nov 1948 note) | CBS 1943 (moved to the site in 1943; founded 1936 elsewhere). Battle 19-24 May 1948; IDF retook it 5 Nov 1948 | N95; https://en.wikipedia.org/wiki/Battle_of_Yad_Mordechai | CORRECT |
| yad_mordechai | pop 1948 | 298 | 298 | N95 | CORRECT |
| yad_mordechai | pop 2022 | 917 | 917.4 | P22 | CORRECT |
| yad_mordechai | status | Israel from 14 May 1948 (single entry) | Egyptian-held from 24 May to 5 Nov 1948 | WP Battle of Yad Mordechai | WRONG (minor) |
| petah_tikva | lat/lon | 32.08505, 34.88633 | WP 32.0889, 34.8864 (0.43 km) | BC22; WP | CORRECT |
| petah_tikva | founded | 1878 | 1878 | N95; BC22 | CORRECT |
| petah_tikva | pop 1961 | 55,554 | 55,554 | N95 | CORRECT |
| petah_tikva | pop 2022 | 264,046 | 264,046.2 | P22 | CORRECT |
| petah_tikva | status | Israel from 14 May 1948 | consistent | S100 | CORRECT |
| safed | lat/lon | 32.96419, 35.50531 | WP 32.9658, 35.4983 (0.68 km) | BC22; WP | CORRECT |
| safed | founded | null, "ancient" | CBS "ותיק" (veteran) | N95; BC22 | CORRECT |
| safed | pop 1948 | 2,317 | 2,317 | N95 | CORRECT |
| safed | pop 2022 | 37,801 | 37,800.8 | P22 | CORRECT |
| safed | status/wording | Israel from 14 May 1948; Arab majority fled in early May 1948 | captured 10-11 May 1948; flight of Arab majority well documented (Morris) | S105 | CORRECT |
| holon | lat/lon | 32.01651, 34.77891 | WP 32.0167, 34.7667 (1.15 km) | BC22; WP | CORRECT |
| holon | founded | 1933 (note: 2022 file says 1940) | N95 and BC08 say 1933; BC22 says 1940. Note is accurate | N95; BC08; BC22 | CORRECT |
| holon | pop 1961 | 48,970 | 48,970 | N95 | CORRECT |
| holon | pop 2022 | 192,655 | 192,655.3 | P22 | CORRECT |
| holon | status | Israel from 14 May 1948 | consistent | S100 | CORRECT |
| jerusalem | lat/lon | 31.78379, 35.22049 | WP 31.7789, 35.2256 (0.73 km) | BC22; WP | CORRECT |
| jerusalem | founded | null, ancient / CBS "veteran" | CBS "ותיק" | N95; BC22 | CORRECT |
| jerusalem | pop 1961 | 167,435 (West only) | 167,435 | N95 | CORRECT |
| jerusalem | pop 2022 | 1,005,919 | 1,005,919.1 | P22 | CORRECT |
| jerusalem | status 1948-67 | divided; armistice 3 Apr 1949; Knesset Dec 1949-Jan 1950 | matches (Ben-Gurion statement 13 Dec 1949; Knesset proclamation 23 Jan 1950) | S112; S123 | CORRECT |
| jerusalem | status 1967- | law extended 28 Jun 1967; 1980 Basic Law; UNSC 478; US Dec 2017 | all dates correct (Knesset law 27 Jun, orders 28 Jun 1967; Basic Law 30 Jul 1980; UNSC 478 20 Aug 1980; US 6 Dec 2017) | S226; S227; S223; S422 | CORRECT |
| jerusalem | wording | neutral; notes non-recognition | Neutral. Does not mention the residency status of East Jerusalem Palestinians or the 1948 displacements (Jewish Quarter, Arab West Jerusalem neighbourhoods) | - | CORRECT (minor omission) |
| hura | lat/lon | 31.29728, 34.93613 | WD 31.2942, 34.9311 (0.59 km) | BC22; https://www.wikidata.org/wiki/Q1638374 | CORRECT |
| hura | founded | null ("CBS lists none; first enumerated 1995") | CBS gives no year (true), but the township was established in 1989 (local council 1996; FOTW gives Feb 1991) | BC22; https://en.wikipedia.org/wiki/Hura | WRONG (founding year is known) |
| hura | pop 1995 | 2,532 | 2,532 | N95 | CORRECT |
| hura | pop 2022 | 20,670 | 20,670.5 (census est.). BC22 registry end-2022 figure is 24,822 | P22; BC22 | CORRECT (sources differ) |
| hura | status | Israel "from 1995" | Area under Israel since 1948-49 (Negev Bedouin under military government until 1966); town established 1989. The 1995 start date only reflects the first census listing | WP Hura | WRONG |
| quneitra | lat/lon | 33.12556, 35.82389 | WD identical; ruined old town (OSM's top hit is the governorate) | https://www.wikidata.org/wiki/Q576368 | CORRECT |
| quneitra | founded | null; Syrian admin centre | Ottoman-era town (Circassians from 1873) | https://en.wikipedia.org/wiki/Quneitra | CORRECT |
| quneitra | population | none given | no series (acknowledged). WP: more than 20,000 before 1967 | WP Quneitra | n/a (gap) |
| quneitra | status 1948-74 | Syria; captured Jun 1967; returned Jun 1974 | dates correct (captured 10 Jun 1967; 31 May 1974 agreement) | S217; WP | CORRECT |
| quneitra | wording | "largely depopulated"; "returned ... in ruins" | WP: civilians other than the Druze were expelled. A UN inquiry found deliberate destruction before the withdrawal; UNGA condemned it 29 Nov 1974 (93-8-74); Israel disputes this | WP Quneitra | BIASED (by omission) |
| quneitra | status Dec 2024- | still "syria_un_buffer", with only a note | Israeli forces entered Quneitra in Dec 2024 and have held the area since | S466; WP | WRONG (needs a new entry) |
| kafr_kanna | lat/lon | 32.74607, 35.3421 | OSM 32.7460, 35.3398 (0.2 km); WP 32.75, 35.35 (0.86 km) | BC22; OSM; WP | CORRECT |
| kafr_kanna | founded | null (no note) | ancient village (Cana tradition; mentioned in the Amarna letters) | https://en.wikipedia.org/wiki/Kafr_Kanna | CORRECT |
| kafr_kanna | pop 1961 | 3,549 | 3,549 | N95 | CORRECT |
| kafr_kanna | pop 2022 | 24,262 | 24,261.9 | P22 | CORRECT |
| kafr_kanna | status | Jul 1948 (Dekel); military government to 1 Dec 1966 | captured in Operation Dekel 15-18 Jul 1948, surrendered 22 Jul; military government abolished Dec 1966 | WP; S150 | CORRECT |
| sakhnin | lat/lon | 32.86465, 35.29917 | WP 32.8667, 35.30 (0.24 km) | BC22; WP | CORRECT |
| sakhnin | founded | null; long-established | consistent | WP | CORRECT |
| sakhnin | pop 1961 | 5,150 | 5,150 | N95 | CORRECT |
| sakhnin | pop 2022 | 32,354 | 32,354.5 | P22 | CORRECT |
| sakhnin | status | Oct 1948 (Hiram); military government to 1966 | fell 29-31 Oct 1948 (had briefly surrendered 18 Jul 1948 and was then retaken by Arab forces) | https://en.wikipedia.org/wiki/Sakhnin | CORRECT |
| tulkarm | lat/lon | 32.31111, 35.03083 | WP 32.3125, 35.0267 (0.42 km); OSM 32.3111, 35.0276 (0.31 km) | https://en.wikipedia.org/wiki/Tulkarm | CORRECT |
| tulkarm | founded | null | ancient town | WP | CORRECT |
| tulkarm | pop 1961 | 20,690 | 20,690 (Jordanian census) | LevyI | CORRECT |
| tulkarm | pop 2017 | 74,463 | 74,463 ("incl. camp") | CP | CORRECT (secondary source compiling PCBS) |
| tulkarm | status 1948-67 | "Held by Jordan's Arab Legion from the 1948 war" | WP: occupied by the Iraqi Army in 1948. The Arab Legion took over the Iraqi front under the spring 1949 arrangement (FRUS 1949). Annexation 24 Apr 1950 is correct | WP; https://history.state.gov/historicaldocuments/frus1949v06/d554 | WRONG (minor) |
| tulkarm | status 1967 / 1995 | captured Jun 1967; Area A 10 Dec 1995 | WP: handed to the PA on 10 Dec 1995 | WP; S013 | CORRECT |
| tulkarm | status after 1995 | Area A to present, nothing further | Omits the 2002 reoccupation and Operation Iron Wall (from 27 Jan 2025: Tulkarm and Nur Shams camps emptied and IDF held there for months; more than 30,000 displaced across the northern camps) | https://en.wikipedia.org/wiki/Operation_Iron_Wall | WRONG (incomplete) |
| jabalia | lat/lon | 31.52806, 34.48306 | WP identical; OSM 31.5282, 34.4832 (0.01 km) | WP; OSM | CORRECT |
| jabalia | founded note | First Intifada began there Dec 1987 | widely documented (Jabalia camp, 8-9 Dec 1987) | general reference (Britannica "intifada") | CORRECT |
| jabalia | pop 1967 | 43,604 (Egyptian 1966 est. 49,009) | 43,604 / 49,009 | LevyJ | CORRECT |
| jabalia | pop 2017 | 222,166 | 222,166 ("incl. camp") | CP | CORRECT |
| jabalia | status dates | Egypt 1948-67; occupied 1967; PA May 1994; Hamas 14 Jun 2007 | all correct; disengagement completed 12 Sep 2005 is correct | S110; S323; S365; S374 | CORRECT |
| jabalia | wording 2007- | "tightened restrictions"; Strip "main theatre" from Oct 2023 | Euphemistic for the blockade. Omits the 7 Oct attack, which cited S448 is about, and Jabalia's own 2023-25 sieges and destruction (WP: about 70% of the camp destroyed by May 2024; reinvaded Oct 2024) and displacement. S448 does not support the note's text | https://en.wikipedia.org/wiki/Jabalia | BIASED (by omission) |
| beitar_illit | lat/lon | 31.69482, 35.1125 | WP 31.6978, 35.1156 (0.44 km) | BC22; https://en.wikipedia.org/wiki/Beitar_Illit | CORRECT |
| beitar_illit | founded | 1985 | CBS 1985; WP: established 1985, first residents 1990 | BC22; WP | CORRECT |
| beitar_illit | pop 1995 | 5,326 | 5,326 | N95 | CORRECT |
| beitar_illit | pop 2022 | 65,660 | 65,659.9 | P22 | CORRECT |
| beitar_illit | status/wording | Haredi settlement city in occupied West Bank, from 1985 | Correct and neutral. Omits the international-law status in cited S420 (UNSCR 2334) and the land taken from Husan and Nahalin | WP; S420 | CORRECT (minor omission) |
| yamit | lat/lon | 31.27556, 34.16722 | WP/WD identical; OSM 31.2740, 34.1680 (0.19 km) | https://en.wikipedia.org/wiki/Yamit | CORRECT |
| yamit | founded | 1975 | approved Sep 1973; construction Jan 1975; first residents Aug 1975 | WP Yamit | CORRECT |
| yamit | population | none | no series (acknowledged) | - | n/a (gap) |
| yamit | status | settlement 1975 to Apr 1982; evacuated and razed Apr 1982 | evacuated 23 Apr 1982; Sinai returned 25 Apr 1982 | S254; WP | CORRECT |
| yamit | wording | lists Israeli settlers only | Omits the Jan 1972 expulsion of Rafah-Plain Bedouin for the settlement bloc (4,950 by IDF count, 20,000 by the sheikhs' claim) | WP Yamit | CORRECT (minor omission) |

Additional verification: every other CBS population value in the 11 CBS localities (1948, 1972, 1983, 1995 from N95; 2008 from BC08) matches the source cell exactly. The Tulkarm 1967 (15,275) and 1997/2007 figures and the Jabalia 1997/2007 figures also match LevyI and CP.

#### Non-CORRECT findings
- **yad_mordechai / status (WRONG, minor):** the single "Israel from 14 May 1948" entry ignores Egyptian control from 24 May to 5 Nov 1948. The founded_note mentions it, but the timeline should have a separate entry.
- **hura / founded (WRONG):** null is defensible only as "CBS gives no year". The township was established in 1989 (Wikipedia; local council 1996).
- **hura / status (WRONG):** the start date "1995" is a census-listing artefact. The area has been under Israeli control since 1948-49, Negev Bedouin were under military government until 1966, and the town dates from 1989.
- **quneitra / wording (BIASED by omission):** "largely depopulated" and "in ruins" hide the expulsion of about 20,000 civilians (all but the Druze) and the UN finding of deliberate destruction before the 1974 withdrawal (UNGA condemnation, 1974). Israel's dissent should also be noted.
- **quneitra / status (WRONG):** since Dec 2024 Israeli forces have held Quneitra and the buffer zone. This needs a new timeline entry, not just a note on "syria_un_buffer".
- **tulkarm / 1948-67 (WRONG, minor):** Tulkarm was held by the Iraqi army in 1948-49, not the Arab Legion. Jordan took over the Iraqi front under the 1949 armistice arrangements.
- **tulkarm / after 1995 (WRONG, incomplete):** the open-ended "Area A" entry omits the 2002 reoccupation and the 2025 "Iron Wall" operation: the Tulkarm and Nur Shams camps were emptied, the IDF stayed for months and tens of thousands were displaced across the northern camps.
- **jabalia / wording (BIASED by omission):** "tightened restrictions" understates the blockade. The note says nothing about 7 Oct or Jabalia's own 2023-25 sieges, destruction and displacement, and cited S448 (7 Oct death toll) does not support the note's text.
- **quneitra and yamit / population (gap):** no population series, which the dataset itself acknowledges. A pre-1967 Quneitra figure (over 20,000) is available.
- **Minor omissions graded CORRECT:** Jerusalem (residency status of East Jerusalem Palestinians, 1948 displacements), Beitar Illit (international-law status in cited S420, land from Husan and Nahalin), Yamit (1972 Rafah-Plain Bedouin expulsion).
- **Note on hura 2022:** the census estimate (20,670) is far below the registry figure in BC22 (24,822). The dataset consistently uses the census estimate, which is fine, but the gap is large.
- **Process note:** cbs.gov.il reset direct connections, so all CBS checks used web.archive.org copies of the exact cited files. Web search quota ran out partway through. The First Intifada start date is graded on standard reference knowledge rather than a fetched page.


### Choices (16 events, 38 options)

### Audit of decision choices (pack_choices.md): 16 events, 38 options

Method: WebSearch and WebFetch against Wikipedia (used only to find the scholarly citation), the Jewish Virtual Library, the CS Monitor and JTA archives, MERIP, the Times of Israel, the Begin Center and the Rabin Center. **Limit:** the shared WebSearch budget ran out partway through the audit (200 calls across the session). The checks for 2005, 2011, 2014, 2024 and 2025 used direct WebFetch of known pages only. Some PLAUSIBLE-BUT-UNSOURCED grades below could be upgraded with more searching.

Grades: REAL-DEBATED / PLAUSIBLE-BUT-UNSOURCED / INVENTED / WRONG. Historical options are graded ACCURATE, ACCURATE-WITH-CAVEAT or MISLEADING.

| event id | option (short) | historical? | verdict | evidence / who proposed | source URL |
|---|---|---|---|---|---|
| evt_1948_altalena | IDF seizes the ship by force | HIST | ACCURATE | Ben-Gurion ordered the shelling off Tel Aviv on 22 June. Note: fighting had already taken place at Kfar Vitkin on 20-21 June. | https://www.jewishvirtuallibrary.org/the-altalena-affair ; https://en.wikipedia.org/wiki/Altalena_Affair |
| evt_1948_altalena | Accept the Irgun demand: remaining arms go to Irgun battalions | NON | REAL-DEBATED | This was Begin's own demand: after the 20% for Jerusalem, the rest should equip the Irgun battalions in the IDF ("a question of honor"). The government rejected it as an "army within an army". | https://www.jewishvirtuallibrary.org/the-altalena-affair |
| evt_1948_altalena | Allow only the agreed 20% and keep negotiating | NON | PLAUSIBLE-BUT-UNSOURCED | Talks did continue (Begin in Netanya; Meridor and Even at Kfar Vitkin reached a local ceasefire and handed over the landed arms). No source shows any actor proposing "20% only, keep talking" as a policy. | https://en.wikipedia.org/wiki/Altalena_Affair |
| evt_1972_munich | Authorise the covert campaign (Committee X) | HIST | ACCURATE-WITH-CAVEAT | Meir and Dayan headed Committee X; Yariv and Zamir directed it; Meir authorised it "reluctantly". Caveat: the conventional air strikes in the other option **also happened** (on 8 Sept), so the two choices are not exclusive. | https://en.wikipedia.org/wiki/Operation_Wrath_of_God |
| evt_1972_munich | Limit the response to conventional strikes on bases in Syria and Lebanon | NON | PLAUSIBLE-BUT-UNSOURCED | No named actor is found advocating "strikes only". Closest: Meir's pre-Munich ban on Mossad killings in friendly European states (Bergman); Bar-Zohar says "Golda really hesitated". The strikes themselves were carried out, so as a counterfactual this option is only the restraint part. | https://www.pbs.org/newshour/show/the-inside-story-of-israels-campaign-of-assassination ; https://www.timesofisrael.com/wrath-o |
| evt_1973_yom_kippur_war | Large mobilisation, no pre-emptive strike | HIST | ACCURATE-WITH-CAVEAT | Meir took Elazar's mobilisation plan and refused pre-emption. Caveats: (a) Dayan also opposed pre-emption, not only Meir; (b) the size of the call-up is reported differently (JVL: "partial call-up"; other accounts: a 100,000 compromise). | https://www.jewishvirtuallibrary.org/background-and-overview-yom-kippur-war ; https://en.wikipedia.org/wiki/Yom_Kippur_War |
| evt_1973_yom_kippur_war | Pre-emptive air strike on Syria (Elazar) | NON | REAL-DEBATED | Elazar proposed it on the morning of 6 Oct (Syrian airfields at noon, missiles at 15:00, ground forces at 17:00). Meir and Dayan refused. | https://www.jewishvirtuallibrary.org/background-and-overview-yom-kippur-war ; https://en.wikipedia.org/wiki/Yom_Kippur_War (cites Rabinovich 2004) |
| evt_1973_yom_kippur_war | Call up only the air force and two armoured divisions (Dayan) | NON | REAL-DEBATED (citation mismatch) | Dayan proposed the air force plus two armoured divisions (about 70,000) against Elazar's four divisions (100-120k). **S209 (JVL), which the note cites, does not contain this.** The correct source is Rabinovich, *The Yom Kippur War* (2004), p. 89, as cited on Wikipedia. | https://en.wikipedia.org/wiki/Yom_Kippur_War |
| evt_1975_sebastia | Compromise: settlers moved into the Kadum camp | HIST | ACCURATE | The compromise was reached around 7 Dec 1975, after which about 25 families were allowed into Kadum (Akevot gives about 30). Rabin approved it after hesitating. | https://www.rabincenter.org.il/en/?p=8990 ; https://www.akevot.org.il/en/article/a-story-of-two-roads-and-disrupted-lives/?full |
| evt_1975_sebastia | Keep removing the settlers by force | NON | REAL-DEBATED | This was the government's formal position: a 1975 cabinet resolution (17-2, 3 abstentions) declared the settlement illegal, and the IDF had evicted the group repeatedly. Rabin opposed settling in Arab population centres. | https://en.wikipedia.org/wiki/Kedumim ; https://www.rabincenter.org.il/en/?p=8990 |
| evt_1975_sebastia | Authorise a settlement at Sebastia itself | NON | REAL-DEBATED | This was the demand of Gush Emunim and Elon Moreh. Defence Minister Peres "made no secret of his support of the Gush demands for free Jewish settlement" (1976 report). | https://digital.bentley.umich.edu/djnews/djn.1976.04.30.001/8 |
| evt_1978_camp_david | Full Sinai withdrawal including settlements | HIST | ACCURATE-WITH-CAVEAT | The framework set out full withdrawal. At Camp David Begin agreed only to put the settlements question to the Knesset, so the label slightly overstates what he agreed; the note gets it right. | https://avalon.law.yale.edu/20th_century/campdav.asp |
| evt_1978_camp_david | Keep the Rafah-salient settlements such as Yamit | NON | REAL-DEBATED (citation gap) | Begin's Dec 1977 Ismailia and Knesset plan: settlements stay under Israeli jurisdiction and protection, with a UN zone around Yamit. **The note cites S244, which is not among the event's sources.** | https://db.begincenter.org.il/en/article/my-plan-for-peace ; https://www.nybooks.com/articles/1979/05/31/begin-vs-begin/ |
| evt_1982_sinai_withdrawal | Evacuate on schedule | HIST | ACCURATE | Begin pledged to keep the treaty commitments and the cabinet gave the final go-ahead in April 1982. | https://csmonitor.com/1982/0416/041664.html |
| evt_1982_sinai_withdrawal | Delay the final withdrawal and renegotiate the Rafah salient | NON | PLAUSIBLE-BUT-UNSOURCED | The Movement to Stop the Withdrawal (backed by Tehiya: Geula Cohen, Hanan Porat) wanted to **stop** the withdrawal, not delay and renegotiate it. Sharon and Shamir "hinted" at not withdrawing, and Shamir spoke of having to "reconsider" the terms. The Rafah issue in April 1982 was a border-marker dispute, not a renegotiation. No source found for this exact framing. | https://www.csmonitor.com/1981/1104/110447.html ; https://cojs.org/background_report_the_sinai_withdrawal_issue-_jta-_jan-_11-_1982/ |
| evt_1982_lebanon_war | Launch a broad invasion that extends to Beirut | HIST | MISLEADING | The cabinet **never chose** a Beirut invasion. It approved a 40 km operation, and Sharon expanded it step by step. Ministers later said they were misled; Begin was asked repeatedly whether Beirut was the goal and Sharon said no. Calling this a single decision the government took misstates who decided what. | https://www.csmonitor.com/1985/0107/dbisra-f.html ; https://www.jewishvirtuallibrary.org/prime-minister-begin-exchange-of-letters-with-u-s-president-reagan-june-1982 |
| evt_1982_lebanon_war | Limit the operation to a 40 km zone | NON | REAL-DEBATED (really the actual cabinet decision) | This is what the cabinet voted for on 5-6 June. Begin's letter to Reagan: the army was told to push the terrorists back "forty kilometers". Labelling it NON-HISTORICAL is questionable. | same as above |
| evt_1982_lebanon_war | Respond to the Argov shooting with air strikes only | NON | PLAUSIBLE-BUT-UNSOURCED | Air strikes were carried out on 4-5 June. No source found naming a minister who argued to stop at air strikes. Reports mention two cabinet abstentions but do not name them. | https://www.begincenter.org.il/timeline/operation-peace-for-galilee/?lang=en |
| evt_1984_election_rotation | National unity government with rotation | HIST | ACCURATE | Peres for two years, then Shamir; formed 13 Sept 1984. | https://en.idi.org.il/israeli-elections-and-parties/elections/1984/ |
| evt_1984_election_rotation | Narrow Alignment-led coalition | NON | REAL-DEBATED | Peres first tried a centre-left coalition and failed. It would have needed the NRP and relied on the Arab-supported lists. | https://www.merip.org/1985/01/israels-national-unity.md |
| evt_1984_election_rotation | Narrow Likud-led coalition | NON | REAL-DEBATED | Likud tried. Weizman (Yahad) refused to join Likud despite Sharon's pressure, which blocked a narrow Likud government. | https://www.merip.org/1985/01/israels-national-unity.md |
| evt_1985_security_zone | Withdraw to a security zone held with the SLA | HIST | ACCURATE | Cabinet decision of 14 Jan 1985 (16-6): in phase C the IDF deploys on the border while the SLA holds a zone with IDF backing. | https://www.jewishvirtuallibrary.org/cabinet-communique-on-the-withdrawal-from-lebanon |
| evt_1985_security_zone | Withdraw completely to the international border | NON | PLAUSIBLE-BUT-UNSOURCED (citation gap) | No minister found proposing a full pullout. Closest: Weizman voted no in April 1985 over Rabin's continued patrols. **The alternative that was actually argued, a deeper zone or no withdrawal (Shamir, Arens, Sharon), is missing from the choices.** The note cites S244, which is not among the event's sources. | https://www.csmonitor.com/1985/0422/ojune.html ; https://www.jewishvirtuallibrary.org/remarks-by-prime-minister-peres-vice-premier-and-foreign-minister-shamir-and-defense-minister-rabin-on-the-cabinet-decision-to-withdraw-the-i-d-f-from-lebanon |
| evt_2000_lebanon_withdrawal | Unilateral withdrawal to the border | HIST | ACCURATE | Barak's deadline was July; the pullout was completed on 24 May 2000. | https://www.everycrsreport.com/reports/RS20566.html |
| evt_2000_lebanon_withdrawal | Stay until an agreement with Syria | NON | REAL-DEBATED | Netanyahu (1998): troops stay "until an arrangement" guarantees security in the north. JTA analysis said withdrawal after a Syria deal was preferable. **The note contains stray text ("casualty figures here are illustrative game values") that does not belong in a historical note.** | https://www.tribuneindia.com/1998/98dec01/world.htm ; https://www.jta.org/?p=405558 |
| evt_2005_gaza_disengagement | Unilateral disengagement | HIST | ACCURATE-WITH-CAVEAT | Presented as unilateral. Recent HUJI archival research argues there was hidden coordination with the PA, the US, Egypt and others. | https://europeanfriends.huji.ac.il/node/3198265 |
| evt_2005_gaza_disengagement | Withdraw only within a negotiated agreement with the PA | NON | PLAUSIBLE-BUT-UNSOURCED | Likud opponents argued for reciprocity, and Ya'alon warned of a new intifada unless negotiations moved forward. No source found for a named actor proposing "coordinate with Abbas" (search budget ran out). | https://jta.org/?p=413066 |
| evt_2005_gaza_disengagement | Keep the Gaza settlements | NON | REAL-DEBATED | Likud members voted 65% against in the 2004 referendum; NRP ministers Eitam and Levi resigned; National Union ministers Lieberman and Elon were dismissed; Netanyahu resigned in Aug 2005. | https://en.wikipedia.org/wiki/Israeli_disengagement_from_Gaza |
| evt_2011_social_protests | Trajtenberg committee | HIST | ACCURATE | Appointed by Netanyahu on 8 Aug 2011. | https://en.wikipedia.org/wiki/2011_Israeli_social_justice_protests |
| evt_2011_social_protests | Hold the line on the budget and ride out the protests | NON | PLAUSIBLE-BUT-UNSOURCED | Herzog blamed "the resistance of the Israeli Finance ministry", and there were reports of "no new budget expected for 2012". No named minister found advocating "ride it out". The note's phrase "against which the protests were directed" is editorial. | https://en.wikipedia.org/wiki/2011_Israeli_social_justice_protests |
| evt_2011_shalit_exchange | Accept the 1,027-for-1 deal | HIST | ACCURATE | Cabinet vote 26-3. | https://en.wikipedia.org/wiki/Gilad_Shalit_prisoner_exchange |
| evt_2011_shalit_exchange | Refuse to release murderers and keep negotiating | NON | REAL-DEBATED | Ministers Lieberman, Ya'alon and Landau voted against ("a triumph for terror"), as did the victims' group Almagor and bereaved families (e.g., Ze'ev Rapp). | https://en.wikipedia.org/wiki/Gilad_Shalit_prisoner_exchange |
| evt_2014_protective_edge | Ground operation against tunnels | HIST | ACCURATE-WITH-CAVEAT | The ground phase began on 17 July, **after** Israel accepted the Egyptian ceasefire of 15 July and Hamas rejected it. The option leaves out that sequence. | https://en.wikipedia.org/wiki/2014_Gaza_War |
| evt_2014_protective_edge | Air and naval strikes only, plus an early Egyptian ceasefire | NON | REAL-DEBATED (framing flag) | Israel actually **accepted** the Egyptian proposal on 15 July and paused fire; Hamas rejected it "in its current form". Presenting an early ceasefire as Israel's choice alone leaves out the other party's role. Event source S417 does not support any part of the decision. | https://en.wikipedia.org/wiki/2014_Gaza_War |
| evt_2024_lebanon_ceasefire | Accept the ceasefire with freedom to act against violations | HIST | ACCURATE-WITH-CAVEAT (non-neutral) | Security cabinet vote 10-1. The text of the agreement gives **both** sides a right of self-defence. "Freedom to act" is Netanyahu's reading, which Lebanon disputes, but the option states it as part of the deal. | https://en.wikipedia.org/wiki/2024_Israel%E2%80%93Hezbollah_ceasefire_agreement |
| evt_2024_lebanon_ceasefire | Continue the ground campaign deeper into Lebanon | NON | REAL-DEBATED (loosely) | Ben Gvir was the only vote against. He objected that there was no "security belt" and no return of northern residents. That is close to, but not exactly, "go deeper". | same as above |
| evt_2025_january_ceasefire | Approve the phased hostage deal | HIST | ACCURATE | Security cabinet 9-2, then the full government. | https://www.timesofisrael.com/security-cabinet-approves-hostage-ceasefire-deal-full-cabinet-convenes-to-review-vote/ |
| evt_2025_january_ceasefire | Reject the deal and keep up military pressure | NON | REAL-DEBATED | Smotrich and Ben Gvir voted against. Ben Gvir: "stop this deal". Smotrich demanded a return to fighting after phase one. | same as above |

#### Summary counts

**Non-historical options (22):**
- 15 are REAL-DEBATED.
  - 2 of these have a wrong or missing citation in the note: Yom Kippur/Dayan and Camp David.
  - 1 is really the historical decision mislabelled: Lebanon 1982, the 40 km option.
- 7 are PLAUSIBLE-BUT-UNSOURCED: Altalena (20% only), Munich (strikes only), Yamit (delay), Lebanon 1982 (air strikes only), 1985 (full withdrawal), 2005 (negotiated), 2011 (hold the budget).
- 0 are INVENTED.

**Historical options (16):**
- 8 are ACCURATE.
- 7 are ACCURATE-WITH-CAVEAT.
- 1 is MISLEADING (Lebanon 1982).

#### Worst examples

1. **evt_1982_lebanon_war.** The labels are reversed in substance.
   - The "HISTORICAL" option ("Launch a broad invasion that extends to Beirut") was never a decision taken by the government. The cabinet approved the 40 km operation, which the game marks NON-HISTORICAL, and Sharon expanded it in stages amid charges that he misled the cabinet.
   - As written, the choice presents Beirut as a policy Israel chose openly, and it erases the main historical controversy.
2. **evt_1985_security_zone.** The only alternative offered (full withdrawal) has no named advocate. The real debate leaves out the hawks (Shamir, Arens, Sharon), who wanted a deeper zone or no withdrawal, and Shamir's 6 votes against in January. The note also cites S244, which is not attached to the event.
3. **evt_1972_munich.** The "non-historical" option (conventional strikes on Syria and Lebanon) actually happened on 8 Sept 1972. The real question was whether to add covert killings in Europe. As framed, the choice is a false either/or.
4. **evt_2024_lebanon_ceasefire (historical option).** "Freedom to act against violations" is stated as part of the deal. The text only has a mutual self-defence clause; the broad reading is Netanyahu's claim, which Lebanon rejects. That is one side's interpretation presented as fact.
5. **evt_2014_protective_edge.** The alternative implies Israel could simply choose an early ceasefire. Israel did accept Egypt's 15 July proposal and Hamas rejected it. The event's only source (S417, casualty figures) supports nothing in the decision.
6. **Citation problems:**
   - Several notes cite sources that are not attached to the event: S244 for Camp David and 1985, S246 for 1985.
   - S209 is cited for Dayan's two-division position, which S209 does not contain (it comes from Rabinovich 2004).
   - The 2000 note contains game-design text about "illustrative game values".
   - No option has its own source field, so the project's every-claim-sourced rule is not met at option level.
7. **evt_1982_sinai_withdrawal.** "Delay and renegotiate the Rafah salient" softens what was actually demanded: the Tehiya and Gush Emunim movement wanted to **stop** the withdrawal. Ministers' remarks were hints, not proposals.
