# CRITIC_HISTORY_02: blind audit of events.json, cities.json and sources.json

**Critic run:** 2026-10-11, about 18:35–19:05 (+03:00).

**Files audited:**
- `game/data/events.json`: 351 events (snapshot of 18:25).
- `game/data/cities.json`: 117 localities. The builder rewrote it at 18:39 and again at 18:54 while the audit was running; the city rows grade the 18:39 version.
- `sources/sources.json`: rendered to `SOURCES.md`.

No file under `C:\civ` was edited, apart from this report and one line appended to `progress/log.jsonl`.

**Bar:** the published sources themselves. No quote in the data was trusted. Every cited URL in the sample was fetched by the critic, with curl and a browser user-agent: live first, then a raw `id_` snapshot on web.archive.org. Times of Israel pages, which return a Cloudflare 403 to curl, were opened with WebFetch. Each quote was then matched against the page text. Spreadsheets (CBS xls/xlsx) and PDFs (UN resolutions) were parsed directly.

## Method and sample

**Random seed: 7741** (Python `random.Random(7741)`, applied in this order).

**Events.** 12 events were drawn at random from each era (48 in total). None of the sampled events overlaps with another sample.

| Era | Events in era | Sampled events |
|---|---|---|
| 1948–66 | 76 | agnon_nobel, 1955_election, eichmann_trial, military_government_ends, 1949_kiryat_shmona, first_knesset_election, nazareth_illit, reparations_debate, lavon_affair, un_admission, 1965_election, 1951_election |
| 1967–86 | 89 | jerusalem_law, neve_dekalim, 1968_paralympics, pollard, egypt_peace_treaty, peace_now_rally, yamit, lod_airport, operation_litani, kahan_report, 1973_election, osirak |
| 1987–2008 | 79 | operation_accountability, 2000_lebanon_withdrawal, cast_lead, ofek1, first_intifada, palestinian_declaration, fsu_aliyah, hamas_wins_plc, qassam_sderot, 1996_bus_bombings, oslo_i, mirabilis_icq |
| 2009–2026 | 107 | trump_peace_plan, sudan_normalization, huwara_rampage, prawer_begin_shelved, last_hostage_returned, meron_disaster, northern_front, 2019_september_election, october_7_attack, west_bank_toll_since_oct7, nation_state_law, 2025_october_ceasefire |

For each event, the critic checked:
- the date;
- every number in the summary and in `affected_populations`;
- at least 2 cites, chosen to be the ones that carry the numbers and dates. In practice most events had all their cites checked.

**Neutrality.** 15 events were drawn from the 106 that have `affected_populations` and are not in the event sample:

> 2025_war_resumes, 2026_beit_shemesh_strike, 2024_iran_april_attack, 1991_gulf_war_scuds, 2006_second_lebanon_war, 2025_houthi_pm_killed, 2026_lebanon_war, 1982_bashir_assassination, 1970_black_september, 1980_mayors_bombings, 2023_jenin_operation, 2007_gaza_blockade, 1968_karameh, 2005_gaza_disengagement, 2014_protective_edge.

**Choices.** 12 options, each from a different event: 9 non-historical options and 3 historical ones.

**Cities.** 12 cities, stratified as follows:
- 5 Jewish towns or cities: Karmiel, Beit Shean, Arad, Kiryat Bialik, Katzrin. Katzrin is in the Golan, so it also counts as a settlement in the strict sense.
- 3 Arab or Bedouin towns: Sakhnin, Rahat, Abu Ghosh.
- 1 mixed city: Acre.
- 2 Palestinian cities: Qalqilya, Jenin.
- 1 Gaza settlement: Neve Dekalim.

**Automated pre-pass.** The sampled data holds 658 cites across 229 distinct URLs. On the first, unthrottled pass:
- 498 quotes were found verbatim;
- 150 cites were unreachable: web.archive.org returned HTTP 429 or reset the connection, and timesofisrael.com returned 403;
- 10 were reported as NOT-FOUND or PARTIAL. Every one of these 10 turned out to be a tool artifact on manual re-check:
  - CBS spreadsheets the pre-pass did not parse;
  - IDI results tables where the quote is only digits, such as "82.8%";
  - soft hyphens in the text extracted from UN PDFs.

Verifiers then retried the unreachable pages slowly, one at a time, and used WebFetch for Times of Israel.

**Limits.**
- web.archive.org rate-limited the critic heavily. Some archive-only cites could never be opened in this session, and these are graded **UNSUPPORTED (as cited)**. That grade means "nobody could open the cited copy", not "the fact is false"; where the fact is known to be true, the note says so.
- The shared web-search quota was not used. All checks went through the cited URLs or primary sources.

## Verdict totals

| Scope | Checks | CORRECT | WRONG | UNSUPPORTED | QUOTE-NOT-ON-PAGE | BIASED |
|---|---|---|---|---|---|---|
| Events 1948–66 (12) | 51 | 49 | 0 | 2 | 0 | 0 |
| Events 1967–86 (12) | 51 | 46 | 0 | 5 | 0 | 0 |
| Events 1987–2008 (12) | 46 | 35 | 0 | 9 | 0 | 2 |
| Events 2009–2026 (12) | 53 | 50 | 0 | 2 | 0 | 1 |
| **Events total (48)** | **201** | **180** | **0** | **18** | **0** | **3** |
| Neutrality (15 events) | 15 | 11 PASS | 1 (wrong figure) | 2 (unattributed or unsupported bound) | 0 | 1 (+1 missing group, +1 no figures) |
| Choices (12 options) | 12 | 11 | 0 | 1 | 0 | 0 |
| Cities (12) | 54 | 31 | 4 | 18 | 0 | 1 |
| **All checks** | **282** | **233** | **5** | **39** | **0** | **5** |

The neutrality row counts events. 4 of the 15 fail. Their 5 problems are split across the columns in the table, with the missing group and the no-figures failure noted in brackets.

**Reading the totals:**
- **No quote was fabricated.** On every page that opened, every checked quote was found verbatim (after normalising whitespace and typography). Round 2's per-claim citations are real.
- **Event facts are accurate.** None of the 201 event checks was WRONG. The previous critic found 10.
- **The 18 UNSUPPORTED event checks fall into two groups:**
  - **10 are real support gaps.** The page opened, but its quote does not establish the claim:
    - Lavon: "keep British in the Canal Zone";
    - UN admission: "Resolution 69";
    - Egypt: Arab League suspension "1979–1989";
    - Yamit: "urban centre";
    - Lod: "about 80 wounded", where the cite says "over 70";
    - Litani: published tolls left as "not quantified";
    - Osirak: Iraqi dead left as "not quantified";
    - Cast Lead: 248 police, where the opened cite says 245;
    - 7 October: "AFP tally", which the cited France24 page never attributes to AFP;
    - October 2025 ceasefire: the "20-point plan / first phase" wording.
  - **8 are archive-only cites the critic could not open.** These are B'Tselem's First Intifada and Cast Lead statistics, the OHCHR Goldstone copy, the UN Peacemaker PDF of the Declaration of Principles, and the Britannica and NYT pages on the 1988 Palestinian declaration.
- **Cities are the weak spot.** All 5 WRONG verdicts in the whole audit are in cities.json (4 of them) or in a casualty figure (1). Cities also carry 18 UNSUPPORTED, most of them status entries with `cite: []`.

## Failing items (compact)

**Events**
- **evt_1949_un_admission:** "following Security Council Resolution 69". The FRUS cite does not give the resolution number. Cite S/RES/69(1949) instead. UNSUPPORTED.
- **evt_1954_lavon_affair:** "to keep British troops in the Canal Zone". The S135 quote says only "sabotage relations between Egypt and the West". Re-point the cite to S134 (JVL). UNSUPPORTED.
- **evt_1979_egypt_peace_treaty:** "Arab League suspension 1979–1989". Neither cite gives the years. UNSUPPORTED.
- **evt_1975_yamit:** "planned as the urban centre of the Rafah salient". The S1368 quote does not say this. UNSUPPORTED.
- **evt_1972_lod_airport:** "about 80 wounded". S231 says "over 70" and S1331 says "dozens". The 24 killed (S231) against 26 (S1331) is never reconciled. UNSUPPORTED.
- **evt_1978_operation_litani:** every group is marked "not quantified", although published tolls exist: about 1,100–2,000 Lebanese and Palestinian dead, more than 100,000 displaced, and about 20 IDF dead. UNSUPPORTED.
- **evt_1981_osirak:** Iraqi dead are marked "not quantified". The standard reported toll is about 10 Iraqi soldiers, plus 1 French technician (Damien Chaussepied). UNSUPPORTED.
- **evt_2008_cast_lead:**
  - "248 Hamas police": the opened Ynet cite says 245; the B'Tselem source for 248 could not be opened.
  - Several Israeli figures rest only on archive copies that could not be opened.
  - affected_populations leaves out the PCHR figure of 1,434 killed, which is on the same cited Ynet page. BIASED.
  - The Goldstone report's 2011 partial retraction is not mentioned.
- **evt_1993_operation_accountability:** no Hezbollah group in affected_populations. The cited HRW report gives Hezbollah's own count of 17 dead and the IDF's estimate of 50–80. BIASED.
- **evt_1987_first_intifada, evt_1988_palestinian_declaration, evt_1993_oslo_i:** the key cites are archive-only and could not be opened. UNSUPPORTED (as cited).
- **evt_2023_october_7_attack:** "AFP tally" of 1,189. The cited France24 page never mentions AFP. This was carried over from CRITIC_01 and is still unfixed. "331 soldiers" also includes local security officers. UNSUPPORTED.
- **evt_2025_october_ceasefire:** "talks on Trump's 20-point plan … first phase". The cited Times of Israel page says only "signed in Egypt". UNSUPPORTED.
- **evt_2018_nation_state_law:** gives only the critics' voices. The supporters' case (Netanyahu: "a defining moment in the annals of Zionism") is on the same cited page but left out. BIASED.

**Neutrality**
- **evt_2025_houthi_pm_killed:** Yemenis killed is [11,11]. That leaves out the cabinet ministers killed with the PM (Israeli media said 12 ministers were targeted) and the more than 40 killed in the September strikes. Meanwhile the Israeli side counts 22 wounded in Eilat. WRONG and BIASED.
- **evt_1970_black_september:** no group for the Syrian forces, although their incursion is in the summary. The Jordanian 537 has no attribution ("Jordan reports" appears only in the cite). FAIL.
- **evt_1968_karameh:** the IDF upper bound of 33 has no source (the cite says 28), and the figures are unattributed. FAIL.
- **evt_2007_gaza_blockade:** all three groups are notes only, with no figure and no "not quantified". This breaks the contract format. FAIL.
- **Minor:**
  - 2026_lebanon_war: the Lebanese range mixes two as-of dates, and there is no `date_end` for the 16 April truce.
  - 2006 war: Israeli civilian dead given as 19 (CIE) against 43 (HRW/Amnesty), and the gap is not disclosed.
  - 1982 Bashir: only the first-report toll is used.

**Choices**
- **evt_1987_lavi_cancelled, option 1:** the only cite is an archived NYT page that the critic could not open. UNSUPPORTED (as cited).
- **Caveats (graded CORRECT):**
  - Ben-Gvir's "much larger strike" in April 2024 rests on a single post-hoc tweet.
  - Sebastia, historical option: the note's claims that Peres arranged the compromise and that it was an "army camp" are not in the cited Rabin Center page.

**Cities**
- **Qalqilya and Jenin:**
  - Both are `jordanian_administered` from May 1948. Their own S1294 cite (FRUS) shows the Arab Legion took over the Iraqi front only in 1949. WRONG ×2.
  - Defensive Shield control is dated from 29 Mar 2002. Their own S1337 cite gives 1 Apr (Qalqilya) and 3 Apr (Jenin). WRONG ×2.
- **Empty `cite: []` on 11 sampled status entries:**
  - Beit Shean 1948
  - Arad 1961
  - Kiryat Bialik 1948
  - Sakhnin 1966
  - Abu Ghosh 1948
  - Qalqilya 1967 and 1995
  - Jenin 1967 and 1995
  - Katzrin 1977
  - Neve Dekalim 1980

  Across the whole file (18:54 version), 87 of 203 status entries (43%) have no cite, and 72 of 117 cities have no `founded_cite`.
- **Beit Shean:** status rests only on a book landing page (S105, Morris), with no page number.
- **Rahat:** founding and status are sourced to Hebrew Wikipedia (S2003), which breaks the contract's "via Wikipedia" rule.
- **Sakhnin:** the new `arab_held` entry for 1948-05 to 1948-10 cites military-government sources that do not cover it.
- **Acre:** the displacement note cites generic 1948 sources that never mention Acre.
- **Abu Ghosh:** "residents largely remained" is unsourced and leaves out the July 1948 expulsions (Morris).
- **Qalqilya 1967:** the entry leaves out the June 1967 demolition of much of the town and the temporary expulsion of its residents. BIASED.
- **Source hygiene:** S1022 has `url: null`. S1081, S1294, S1337 and S1417 are titled only by their domain.

## Detailed check tables

### 1. Events 1948–66
Every cite in these 12 events was fetched (by curl, live first, then web.archive.org) and its quote matched against the page text. Four archived nobelprize.org URLs returned HTTP 429 from the Wayback Machine. The same quotes were confirmed on the live nobelprize.org pages. The IDI turnout quotes ("82.8%", "83.0%") were confirmed by hand in the IDI results tables; the automated matcher misses quotes that are only digits.

| Event | Claim | Cite (S-id) | Quote on page? | Verdict | Evidence/note |
|---|---|---|---|---|---|
| evt_1966_agnon_nobel | Prize conferred 10 Dec 1966, Stockholm | S1256 | yes (live) | CORRECT | Banquet speech page dated 10 Dec 1966 |
| evt_1966_agnon_nobel | Shared 1966 prize with Nelly Sachs | S152 | yes (live; archived copy 429) | CORRECT | "divided equally between Shmuel Yosef Agnon ... and Nelly Sachs" |
| evt_1966_agnon_nobel | Prize motivation wording, written in Hebrew | S1259 | archived URL 429; same text on live facts page | CORRECT | Motivation quoted verbatim; "Language: Hebrew" |
| evt_1966_agnon_nobel | Agnon's home in Jerusalem | S1258 | archived URL 429; on live ceremony-speech page | CORRECT | "Agnon's home is in Jerusalem" |
| evt_1955_election | Election 26 Jul 1955 | S1104 | yes | CORRECT | IDI table "26.7.1955" |
| evt_1955_election | Mapai 40, Herut 15 | S1104 | yes | CORRECT | IDI table: Mapai 40, Herut 15 |
| evt_1955_election | Turnout 82.8% | S1104 | yes (table) | CORRECT | "Voter Turnout 82.8%" |
| evt_1955_election | Ben-Gurion Defence Minister Feb 1955, PM again Nov 1955 | S1103, S1073 | yes | CORRECT | MOD archive: 21 Feb 1955; JVL: Nov 1955 (sworn in 3 Nov 1955) |
| evt_1955_election | Sharett Foreign Minister until June 1956 | S1073 | yes | CORRECT | JVL Sharett page (he resigned 18 Jun 1956) |
| evt_1961_eichmann_trial | Opened 11 Apr 1961, Jerusalem; panel headed by Landau | S143 | yes | CORRECT | Israel State Archives |
| evt_1961_eichmann_trial | Hausner, the Attorney-General, prosecuted | S143 | yes | CORRECT | ISA |
| evt_1961_eichmann_trial | Sentenced to death 15 Dec 1961 | S143 | yes | CORRECT | ISA |
| evt_1961_eichmann_trial | Hanged at Ramla, night of 31 May–1 Jun 1962 | S143, S1087 | yes | CORRECT | ISA and JVL |
| evt_1961_eichmann_trial | Only civil execution in Israel's history | S1088 | yes | CORRECT | USHMM says "only time Israel has enacted a death sentence", which overstates (Tobianski was executed by a field court-martial in 1948). The summary's "civil" qualifier makes the claim accurate. |
| evt_1966_military_government_ends | Abolished effective 1 Dec 1966 | S150 | yes | CORRECT | JTA 30 Jun 1966: "by December 1, 1966" |
| evt_1966_military_government_ends | Imposed in 1948 under Mandatory (1945) Defence Emergency Regulations | S1255 | yes | CORRECT | ECF |
| evt_1966_military_government_ends | Restricted movement; permits needed | S150 | yes | CORRECT | JTA |
| evt_1966_military_government_ends | Permit powers passed to the police | S150 | yes | CORRECT | JTA: "civilian authorities and regular police" |
| evt_1949_kiryat_shmona | Built on the site of depopulated al-Khalisa, Hula Valley | S160 | yes | CORRECT | JVL/EJ |
| evt_1949_kiryat_shmona | Early settlers were Yemenite immigrants | S160 | yes | CORRECT | The quote says "Yemen and Romania" and refers to 1953 onward, so it supports the claim only loosely. |
| evt_1949_kiryat_shmona | Named for Trumpeldor and 7 others (Tel Hai, 1920) | S160 | yes | CORRECT | EJ |
| evt_1949_kiryat_shmona | Permanent town 1950; local council 1953 | S160 | yes | CORRECT | EJ. Minor: the id says 1949 (the ma'abara year) but the date is 1950-01-01. |
| evt_1949_first_knesset_election | 25 Jan 1949; a Constituent Assembly, renamed the Knesset | S120 | yes | CORRECT | IDI |
| evt_1949_first_knesset_election | Mapai 46/120 | S120 | yes | CORRECT | IDI |
| evt_1949_first_knesset_election | Turnout 87% | S120 | yes | CORRECT | IDI "87.0%" (Knesset site: 86.9%) |
| evt_1949_first_knesset_election | Weizmann chosen as first President | S1021 | yes | CORRECT | True, but the quote describes his May 1948 selection. The Knesset elected him on 16 Feb 1949, so the quote supports the claim only weakly. |
| evt_1949_first_knesset_election | Ben-Gurion formed a coalition | S120 | yes | CORRECT | IDI: 73 MKs, five parties |
| evt_1957_nazareth_illit | Founded c. 1957 | S1075 | yes | CORRECT | Ynet/Reuters 11 Mar 2019: "some 62 years after it was founded" |
| evt_1957_nazareth_illit | Renamed Nof HaGalil in 2019 | S1075 | yes | CORRECT | Ynet |
| evt_1957_nazareth_illit | Forman: purpose was to consolidate state control over Arab Nazareth | S1076 | yes (the title only) | CORRECT | The OpenAlex abstract confirms: "strategies ... to retain state control over the all-Arab city ... establishing the Jewish town of Upper Nazareth" |
| evt_1952_reparations_debate | West Germany offered compensation first | S130 | yes | CORRECT | JVL (Adenauer, Sep 1951) |
| evt_1952_reparations_debate | Three-day Knesset debate | S1054 | yes | CORRECT | bpb.de: "dreitätige Parlamentsdebatte" |
| evt_1952_reparations_debate | Begin's "blood money" rally turned violent outside the Knesset | S1055, S1054 | yes | CORRECT | Begin Center: Zion Square rally; stones thrown at the Knesset |
| evt_1952_reparations_debate | 9 Jan 1952: approved 61–50 | S1054, S130 | yes | CORRECT | bpb and JVL |
| evt_1954_lavon_affair | Operation began 2 Jul 1954 | S134 | yes | CORRECT | JVL |
| evt_1954_lavon_affair | Targets: post offices, US libraries, British-owned cinema | S134, S135 | yes | CORRECT | JVL and MOD archive |
| evt_1954_lavon_affair | Aim: keep British troops in the Canal Zone | S135 | yes | UNSUPPORTED | The cited MOD quote says only "sabotage the relations between Egypt and Western states". The claim is true: the JVL page (S134) says Israel "did not want the British to leave" the Canal Zone. Fix: cite S134. |
| evt_1954_lavon_affair | Two hanged in early 1955 | S134 | yes | CORRECT | Marzouk and Azar, 31 Jan 1955 |
| evt_1954_lavon_affair | Others died in custody or were imprisoned | S134 | yes | CORRECT | JVL |
| evt_1954_lavon_affair | Lavon resigned Feb 1955 | S135 | yes | CORRECT | MOD archive (17 Feb 1955) |
| evt_1949_un_admission | 11 May 1949, GA Res 273 | S1099 | yes | CORRECT | FRUS 1949 VI d647 |
| evt_1949_un_admission | 37–12, 9 abstentions | S1099, S1249 | yes | CORRECT | FRUS and A/PV.207 roll call |
| evt_1949_un_admission | Followed SC Resolution 69 | S1100 | yes | UNSUPPORTED | FRUS d504 confirms the 4 Mar 1949 recommendation (9–1–1) but gives no resolution number, as the builder's own note admits. The claim is true (S/RES/69). Fix: cite the resolution text (documents.un.org S/RES/69(1949)). |
| evt_1949_un_admission | Israel the 59th member | S1249 | yes (OCR text "fifty-ninth Metnber") | CORRECT | A/PV.207, Guatemala's statement |
| evt_1949_un_admission | Arab states voted against | S1249 | yes | CORRECT | True, but incomplete: 6 of the 12 "no" votes were non-Arab (Afghanistan, Burma, Ethiopia, India, Iran, Pakistan). This is noted only in the cite page field, not in the summary. |
| evt_1965_election | 2 Nov 1965: Alignment 45, Gahal 26, Rafi 10 | S1247 | yes | CORRECT | IDI table |
| evt_1965_election | Turnout 83.0% | S1247 | yes (table) | CORRECT | "Voter Turnout 83.0%" |
| evt_1965_election | Eshkol remained PM | S1247 | yes | CORRECT | The quote is about the 1967 unity government, so it supports the claim only weakly. The same page describes Eshkol forming the 1966 coalition. |
| evt_1951_election | 30 Jul 1951: Mapai 45, General Zionists 20 | S1082 | yes | CORRECT | IDI table |
| evt_1951_election | Turnout 75.1% | S1082 | yes | CORRECT | "Voter Turnout 75.1%" |
| evt_1951_election | Ben-Gurion formed a new coalition | S1082 | yes | CORRECT | IDI |

COUNTS: CORRECT=49 WRONG=0 UNSUPPORTED=2 QUOTE-NOT-ON-PAGE=0 BIASED=0

#### Failures
- **evt_1954_lavon_affair**, "aim: keep British troops in the Canal Zone": UNSUPPORTED as cited. The S135 quote does not say this, but S134 (JVL) does. The claim itself is true.
- **evt_1949_un_admission**, "following Security Council Resolution 69": UNSUPPORTED as cited. The FRUS editorial note gives no resolution number. The claim itself is true.

#### Weak but passing
- Three quotes support their claim only weakly:
  - Weizmann: the quote is about 1948, not his 1949 election.
  - Eshkol "remained PM": the quote is about 1967.
  - Kiryat Shmona Yemenite settlers: the quote is about 1953 onward.
- The 1949 UN admission summary attributes the "no" votes to Arab states only.
- The wayback copies of nobelprize.org that the builder chose were unreachable (429). The live URLs work.

### 1. Events 1967–86
Method: each cited URL was fetched with curl (browser UA). In the first pass web.archive.org returned 429s and connection resets, so the 6 archived pages were refetched slowly as `id_` raw snapshots; all of them eventually opened. The UN-resolution PDFs flagged PARTIAL (S/RES/478, 487) are **PDF/OCR extraction artefacts**: "al 20 August", "I. Strongly", and soft hyphens such as "res- olutions" and "seri- ous". Every quoted clause is present on the page. S/RES/497 belongs to another fork's sample.

| Event | Claim | Cite (S-id) | Quote on page? | Verdict | Evidence/note |
|---|---|---|---|---|---|
| evt_1980_jerusalem_law | Basic Law passed 30 July 1980, "Jerusalem, complete and united" | S227 (Knesset, archived) | Yes | CORRECT | Knesset text: "Passed by the Knesset on the 17th Av, 5740 (30th July, 1980)". |
| evt_1980_jerusalem_law | SC res. 478 (20 Aug 1980) censured the law, called it null and void, and called on embassies to withdraw | S1415 (S/RES/478 PDF) | Yes (OCR artefacts only) | CORRECT | Paras 1, 3 and 5(b) are all on the page; adopted 14-0-1 (US abstained). |
| evt_1983_neve_dekalim | Settled from 1980 per CBS | S007 (CBS bycode2004.xls, via city record) / S001 | Yes | CORRECT | bycode2004.xls row 5427 gives founding year 1980.0, and the nonum.xls row also says 1980. The event id says "1983": that is when the first residents counted in the census arrived (16). |
| evt_1983_neve_dekalim | 16 residents in 1983, 1,667 in 1995 | S001 (CBS nonum.xls, archived) | Yes (opened after retry) | CORRECT | Row 5427 ends "... 1980.0 ... 16.0, 1667.0". |
| evt_1983_neve_dekalim | Largest Israeli settlement in Gaza until 2005 | S284 (CNN 2005) | Yes | CORRECT | "evacuation of the largest Jewish settlement in Gaza". |
| evt_1968_paralympics | 4–13 Nov 1968 | S1261 (IPC) | Yes | CORRECT | IPC page: "04 - 13 November". |
| evt_1968_paralympics | Opening in Jerusalem; events in Ramat Gan | S1261 | Yes | CORRECT | Opening at the Hebrew University Stadium; Games held "at Ramat Gan, near Tel Aviv". |
| evt_1968_paralympics | 774 athletes, 28 countries | S1261 | Yes | CORRECT | "774 Para athletes (578 men and 196 women) from 28 countries". |
| evt_1985_pollard | Arrested 21 Nov 1985 outside the Israeli embassy | S1442 (JTA) | Yes | CORRECT | JTA story dated Mon 25 Nov 1985 says he was arrested "last Thursday", i.e. 21 Nov. |
| evt_1985_pollard | Israel apologised and called the operation unauthorised | S1443 (JTA) | Yes | CORRECT | "'rogue' operation, as the Israeli government maintains ... publicly apologized". |
| evt_1985_pollard | Life sentence in 1987 | S1443 | Yes | CORRECT | JTA 13 Mar 1987: "life sentence ... last week" (sentenced 4 Mar 1987). |
| evt_1979_egypt_peace_treaty | Signed in Washington 26 Mar 1979, Carter as witness | S1370 (Britannica, archived) | Yes (opened after retry) | CORRECT | Photo caption: "White House lawn ... March 26, 1979". |
| evt_1979_egypt_peace_treaty | Full Sinai withdrawal within 3 years | S219 (Avalon treaty) | Yes | CORRECT | Art. I(2) / Annex I. |
| evt_1979_egypt_peace_treaty | Ambassadors exchanged after the interim withdrawal | S219 | Yes | CORRECT | Annex III, Art. 1. |
| evt_1979_egypt_peace_treaty | Free passage through Suez and Tiran | S219 | Yes | CORRECT | Art. V. |
| evt_1979_egypt_peace_treaty | Egypt suspended from the Arab League **1979 to 1989** | S1371 (WJC) | Yes, but no dates | UNSUPPORTED | WJC says only "Egypt was suspended from the Arab league", and neither cited page gives 1979–1989. The fact is true (suspended Mar 1979, readmitted May 1989) but uncited. |
| evt_1982_peace_now_rally | Date 25 Sep 1982; protest against the massacre and the lack of an inquiry | S1955 (JTA) | Yes | CORRECT | JTA bulletin of 29 Sep 1982 says "Last Saturday night", i.e. 25 Sep. |
| evt_1982_peace_now_rally | Organisers told the NYT 350,000 | S1954 (NYT, archived) | Yes (opened after retry) | CORRECT | "Organizers of the rally said the crowd numbered 350,000". |
| evt_1982_peace_now_rally | Organisers (Alignment, Shinui, Peace Now) claimed "over 400,000"; police gave no estimate | S1955 | Yes | CORRECT | Quote is verbatim on the page. |
| evt_1982_peace_now_rally | Speakers called for Begin's and Sharon's resignation | S1954 / S1955 | Yes | CORRECT | On both pages. |
| evt_1982_peace_now_rally | Kahan Commission appointed days later | S1429 (JTA) | Yes | CORRECT | Cabinet decision of 28 Sep 1982 (JTA, 29 Sep). |
| evt_1975_yamit | Planned as the urban centre of the Rafah salient | S1368 (Israel Hayom) | Quote yes; claim no | UNSUPPORTED | The quote is about settlers answering "the government's call to settle ... the Rafiah Salient". Nothing on the page says Yamit was planned as the urban centre (true historically, but the cite does not support it). |
| evt_1975_yamit | Building began 17 Jan 1975 (per a garin member) | S1905 (JPost, archived) | Yes (opened after retry) | CORRECT | "We began building Yamit on January 17, 1975," — properly attributed to one founder. |
| evt_1975_yamit | Largest of 14 Sinai settlements, ~600 houses in 1982 | S254 (JVL) | Yes | CORRECT | "fourteen separate Jewish communities ... approximately 600 houses in 1982". |
| evt_1972_lod_airport | 30 May 1972; JRA acting for the PFLP | S231 (State Archives, archived) | Yes (opened after retry) | CORRECT | Quote is verbatim on the archived page. |
| evt_1972_lod_airport | 26 killed: 17 Puerto Rican, 8 Israelis, 1 Canadian | S1331 (Alabama Baptist) | Yes | CORRECT | "A total of 26 people were killed". S231 itself says "24 people had been killed" (the initial toll); the data does not reconcile the two figures. |
| evt_1972_lod_airport | Aharon Katzir among the dead | S231 | Yes | CORRECT | |
| evt_1972_lod_airport | "about 80 wounded" | S231 | Yes, but says "over 70" | UNSUPPORTED | The cite says "over 70 wounded" and S1331 says "dozens". No cited source gives ~80. |
| evt_1972_lod_airport | 2 attackers dead, Okamoto captured | S231 | Yes | CORRECT | |
| evt_1972_lod_airport | affected_populations | — | — | CORRECT | All four groups are present (no wounded field, which is acceptable). |
| evt_1978_operation_litani | Invasion on 14/15 Mar, 3 days after the Coastal Road attack | S1393 (UNIFIL) | Yes | CORRECT | |
| evt_1978_operation_litani | Occupied the south up to the Litani, except Tyre | S1393 + S1447 (JTA) | Yes | CORRECT | UNIFIL: "except for the city of Tyre"; JTA: "south of the Litani River". |
| evt_1978_operation_litani | Lebanon's protest of 15 Mar: no connection with the raid; an undetermined number dead in Tyre; people fleeing | S1956 (S/12600) | Yes | CORRECT | Primary UN document. |
| evt_1978_operation_litani | Res. 425 (19 Mar): withdrawal and UNIFIL | S1394 | Yes | CORRECT | |
| evt_1978_operation_litani | affected_populations: Lebanese/Palestinian killed and displaced "not quantified"; Israeli soldiers "not quantified" | S1956/S1957 | — | UNSUPPORTED | The data says "No opened source gives a death toll", but published figures exist: commonly ~1,100–2,000 Lebanese/Palestinian dead, 100,000–250,000+ displaced, and ~18–21 IDF dead. Both sides are left unquantified, so the entry is neutral but incomplete. |
| evt_1983_kahan_report | Kahan commission found Israel indirectly responsible | S257 (Malone, Utah L. Rev., archived PDF) | Yes (opened after retry) | CORRECT | "concluded that the State of Israel ... were 'indirectly' responsible". |
| evt_1983_kahan_report | Sharon personally responsible; should resign or be removed | S257 + S1960 (JTA) | Yes | CORRECT | Both quotes are on their pages. |
| evt_1983_kahan_report | Report published 8–9 Feb 1983 | S1959 (JTA) + S257 | Yes | CORRECT | JTA bulletin of 9 Feb: "published here this morning"; report released 8 Feb. |
| evt_1983_kahan_report | Cabinet vote 16–1, Sharon the lone vote against | S1960 | Yes | CORRECT | |
| evt_1983_kahan_report | Sharon stayed on as minister without portfolio | S257 | Yes (hyphenated "portfo- lio" in the PDF) | CORRECT | |
| evt_1973_election | Held 31 Dec 1973, postponed by the war | S211 (IDI) | Yes | CORRECT | |
| evt_1973_election | Alignment 51, Likud 39 | S211 | Yes | CORRECT | |
| evt_1973_election | Meir's coalition was short-lived | S211 | Yes | CORRECT | |
| evt_1981_osirak | 7 Jun 1981; F-16s with F-15 cover | S1420 (JTA) | Yes | CORRECT | |
| evt_1981_osirak | Eight F-16s | S1958 (JTA 2006) | Yes | CORRECT | |
| evt_1981_osirak | Israel said the reactor would be operational "within months" | S1421 (JTA 10 Jun 1981) | Yes | CORRECT | Communique: "operational between early July and early September". |
| evt_1981_osirak | Gur: reactor not as close to completion as claimed | S1423 (JTA) | Yes | CORRECT | |
| evt_1981_osirak | French: one technician killed; Israel: none on site | S1421 | Yes | CORRECT | Balanced and attributed. |
| evt_1981_osirak | Res. 487 unanimous | S1422 (S/RES/487 PDF) | Yes (OCR "I. Strongly") | CORRECT | "Adopted unanimously at the 2288th meeting". |
| evt_1981_osirak | US briefly suspended F-16 deliveries | S1420 | Yes | CORRECT | |
| evt_1981_osirak | affected_populations: Iraqi soldiers "not quantified" | — | — | UNSUPPORTED | A widely reported toll exists: 10 Iraqi soldiers killed, plus the French civilian Damien Chaussepied. The entry was marked "not quantified" without searching beyond JTA. |

COUNTS: CORRECT=46 WRONG=0 UNSUPPORTED=5 QUOTE-NOT-ON-PAGE=0 BIASED=0

Failures
- evt_1979_egypt_peace_treaty: "suspended from the Arab League 1979 to 1989". The cited WJC page gives no years (UNSUPPORTED as cited; the fact is true).
- evt_1975_yamit: "planned as the urban centre". The Israel Hayom quote does not say this (UNSUPPORTED as cited).
- evt_1972_lod_airport: "about 80 wounded", but the cite says "over 70". S231 also says 24 killed against the summary's 26, and the data does not reconcile them.
- evt_1978_operation_litani: affected_populations says "not quantified" for Lebanese/Palestinian dead, for the displaced and for IDF dead, although published tolls exist.
- evt_1981_osirak: Iraqi dead marked "not quantified", although ~10 Iraqi soldiers killed is the standard reported toll.
- Process: every quote was eventually found on its page (0 QUOTE-NOT-ON-PAGE). The "PARTIAL" flags on the UN PDFs were OCR artefacts.

### 1. Events 1987–2008
Quote status: "yes (live)" = fetched live by curl and the quote is present verbatim (normalised); "yes (archive)" = found in the cited web.archive.org copy; "no – unreachable" = cited URL could not be opened (live 403/404 and web.archive.org 429 rate-limit after repeated, spaced retries), so quote is not verified.

| Event | Claim | Cite (S-id) | Quote on page? | Verdict | Evidence/note |
|---|---|---|---|---|---|
| evt_1993_operation_accountability | Began 25 July 1993 | S1144 HRW 1996 | yes (live) | CORRECT | "Sunday, July 25, 1993, the Israeli operation began." |
| evt_1993_operation_accountability | Ended by US-brokered understanding 31 July | S1144 | yes (live) | CORRECT | Christopher-brokered ceasefire 6 pm 31 July. |
| evt_1993_operation_accountability | Stated objective: refugee flow toward Beirut (HRW-attributed) | S1144 | yes (live) | CORRECT | Both quotes on page; attributed to HRW. |
| evt_1993_operation_accountability | ~300,000 Lebanese villagers and Palestinian refugees displaced | S1144, S801 | yes (live, both) | CORRECT | HRW 1996 and HRW 2007 both give 300,000. |
| evt_1993_operation_accountability | ~120 Lebanese civilians killed, ~500 injured | S1144, S801 | yes (live) | CORRECT | Same figures in both HRW reports. |
| evt_1993_operation_accountability | 2 Israeli civilians killed (both Kiryat Shmona), 24 injured; ~half of Kiryat Shmona left | S1144 | yes (live) | CORRECT | "two civilians were killed and twenty-four injured"; "two deaths occurred in separate rocket attacks on Sunday evening" in Kiryat Shemona; "about half the city had departed". |
| evt_1993_operation_accountability | affected_populations complete? | S1144 | n/a | BIASED | Lebanese/Hezbollah combatant deaths omitted though the same cited HRW report gives them: Hezbollah claimed 17 fighters killed, IDF estimated 50–80 (fn. 246). No `hezbollah_fighters` group. |
| evt_2000_lebanon_withdrawal | Pullout completed 24 May 2000, ahead of 7 July deadline | S342 CRS RS20566 | yes (live) | CORRECT | Order 23 May, completed next day; cabinet endorsed 5 March for 7 July. |
| evt_2000_lebanon_withdrawal | ~1,500 SLA + dependents (~7,000) fled to Israel | S342 | yes (live) | CORRECT | Verbatim. |
| evt_2000_lebanon_withdrawal | ~half of SLA stayed and surrendered to Hezbollah, Lebanese army or police | S342 | yes (live) | CORRECT | CRS p.4-5: surrendered "to either Hizballah, the Lebanon Armed Forces (LAF), or Lebanese police"; LAF held 1,488 by 27 May. |
| evt_2000_lebanon_withdrawal | Hezbollah, UN and Lebanese police took over zone | S342 | yes (live) | CORRECT | Verbatim. |
| evt_2000_lebanon_withdrawal | Israeli soldiers killed: "none reported" | S342 | n/a | CORRECT | No casualties in the final pullout; consistent with CRS. |
| evt_2008_cast_lead | IDF: 1,166 killed (709 / 295 / 162) | S378 Ynet | yes (live) | CORRECT | All four figures on page. |
| evt_2008_cast_lead | B'Tselem: 1,387 killed, 773 non-participants incl. 320 minors | S378, S834 | S378 yes (live); S834 no – unreachable (archive 429/refused; live btselem 429) | CORRECT | Ynet quotes B'Tselem 1,387/773/320. (B'Tselem's own stats page later revised to 1,391 — not noted.) |
| evt_2008_cast_lead | "some 248 Hamas police" | S834 (press release) / S378 | S378 says **245**; S834 no – unreachable (archive 429/refused; live btselem 429) | UNSUPPORTED | Ynet quote cited for this claim says "245 Palestinian policemen", not 248; 248 rests only on the B'Tselem press release. |
| evt_2008_cast_lead | >5,300 wounded; UN: 20,000 homeless | S834 castlead page, S835 BBC | BBC yes (live) "5,300 injured, according to Palestinian figures"; B'Tselem no – unreachable (archive 429) | CORRECT | BBC supports 5,300 (Palestinian figures). 20,000 homeless rests on B'Tselem page. |
| evt_2008_cast_lead | 13 Israelis killed: 3 civilians + 10 soldiers, 4 by friendly fire; >100 soldiers wounded | S834 | no – unreachable (archive 429) | UNSUPPORTED | As cited only (sole cite unopenable). Figures match B'Tselem's known breakdown (3 civ + 1 SF by rockets, 5 soldiers in Gaza, 4 friendly fire = 13) and standard IDF count. |
| evt_2008_cast_lead | Goldstone mission (Israel refused access) reported Sept 2009, "strong evidence of war crimes and crimes against humanity" | S1385 OHCHR (archive) | no – unreachable (live 404, archive 429) | UNSUPPORTED | Live OHCHR URL is 404. Facts are correct (report presented 29 Sept 2009). Omission: Goldstone's own April 2011 partial retraction (Washington Post) re Israeli intent is not mentioned. |
| evt_2008_cast_lead | affected_populations range 1,166–1,387 | S378 | yes | BIASED | The cited Ynet page also gives the Palestinian Centre for Human Rights figure, 1,434 killed (960 civilians); the range is capped at B'Tselem and omits the Palestinian-source figure. |
| evt_1988_ofek1 | Ofek-1 launched 19 Sept 1988 on Shavit; first Israeli satellite | S307 JVL | yes (live) | CORRECT | Verbatim. |
| evt_1988_ofek1 | Israeli-built Shavit launcher | S307 | yes (live) | CORRECT | "locally built Shavit launch vehicle". |
| evt_1987_first_intifada | Began 9 Dec 1987 after Gaza traffic accident killing 4 Palestinian workers | S1027 B'Tselem tables (archive), S1028 Britannica (archive) | no – unreachable (B'Tselem/Britannica/JPost archive 429; live 403/429) | UNSUPPORTED | Fact correct (accident 8 Dec at Erez/Jabalia; uprising 9 Dec). Britannica live 403. |
| evt_1987_first_intifada | B'Tselem: 1,162 Palestinians killed (1,070 SF incl. 237 minors; 54 civ; GL 17+21) | S1027 | no – unreachable (B'Tselem/Britannica/JPost archive 429; live 403/429) | UNSUPPORTED | Arithmetic of the quoted table rows checks exactly: 22+289+285+125+91+134+124=1,070; minors 237; civ 54; GL 17 & 21; total 1,162. |
| evt_1987_first_intifada | JVL 1,162 Palestinians / 200 Israelis; ~1,000 intra-Palestinian | S1084 JVL | yes (live) | CORRECT | "First Intifada 1987-1993 200 1,162"; "Intrafada 1987-1993 1,000". |
| evt_1987_first_intifada | B'Tselem: 160 Israelis (47+43 OT, 53+17 GL) | S1027 | no – unreachable (B'Tselem/Britannica/JPost archive 429; live 403/429) | UNSUPPORTED | Quoted rows sum correctly to 47/43/53/17 = 160. |
| evt_1987_first_intifada | HRW: 197 killed Jan–Nov 1992 as suspected collaborators | S813 HRW WR93 | yes (live) | CORRECT | Verbatim. |
| evt_1988_palestinian_declaration | 15 Nov 1988, PNC 19th session, Algiers, proclaimed State of Palestine | S309 UNISPAL | archive unreachable; quotes verified on the **live** UNISPAL page | CORRECT | All three quotes present at https://www.un.org/unispal/document/auto-insert-178680/ (live). |
| evt_1988_palestinian_declaration | Text drafted by Mahmoud Darwish | S1135 Britannica (archive) | no – unreachable (live 403, archive 429) | UNSUPPORTED | Fact correct (well established); Britannica live 403. |
| evt_1988_palestinian_declaration | Read by Yasser Arafat | S1136 NYT 1988 (archive) | no – unreachable (archive 429; WebFetch blocked) | UNSUPPORTED | Fact correct; NYT blocked to WebFetch. |
| evt_1989_fsu_aliyah | ~185,000 from USSR in 1990 (Tolts) | S310 Tolts PDF | yes (live) | CORRECT | Table 1: 1990 Israel 185.2 (thousands). |
| evt_1989_fsu_aliyah | ~980,000 in 1989–2006 (Tolts) | S310 | yes (live) | CORRECT | Sum of Table 1 Israel column 1989–2006 = 978.7k. Note: Tolts counts "Jews and their relatives", fine. |
| evt_1989_fsu_aliyah | CBS: 906,500 immigrants 1990–2001, 86% FSU | S311 CBS | yes (live) | CORRECT | Verbatim, CBS 2009 publication p.8. |
| evt_2006_hamas_wins_plc | 74/132 (+4 independents) vs Fatah 45, 25 Jan 2006 | S368 HRW, S1805 Guardian | yes (live, both) | CORRECT | HRW verbatim; Guardian 26 Jan "voted yesterday" fixes 25 Jan. |
| evt_2006_hamas_wins_plc | Haniyeh government two months later | S368 | yes (live) | CORRECT | Verbatim (sworn in 29 March 2006). |
| evt_2001_qassam_sderot | HRW: Qassam developed late 2001, first attack 5 Mar 2002 | S1324 HRW 2007 PDF | yes (live) | CORRECT | Verbatim, attributed to HRW. Event date 2001-01-01 is a year placeholder; HRW's own dating starts late 2001, so "early in the second intifada… 2001" is loose but attributed. |
| evt_2001_qassam_sderot | 15 civilians killed in Israel 2001–May 2009; thousands left Sderot | S837 HRW 2009 | yes (live) | CORRECT | Verbatim. |
| evt_2001_qassam_sderot | Rockets killed 2 Palestinian + 1 Chinese worker June 2005, ≥2 Palestinians by mid-2007, 2 girls later | S1324, S837 | yes (live) | CORRECT | Verbatim in both. |
| evt_2001_qassam_sderot | Ashkelon and Netivot hit in 2008 | S837 | yes (live) | CORRECT | Verbatim. |
| evt_1996_bus_bombings | 26 (bus 18, 25 Feb) + 1 Ashkelon + 19 (3 Mar) + 13–14 Dizengoff; UN toll 61 | S330 UNISPAL (live), S1268 MFA (archive) | UNISPAL yes (live: 19, 26, 14, 61); MFA no – unreachable (live 404/403, archive 429) | CORRECT | UNISPAL live page carries 26/19/14/61. MFA live URLs 404/403. |
| evt_1996_bus_bombings | US State Dept 65 incl. 3 US citizens; 29 leaders at Sharm (UN: 27) | S387 FAS/State, S330 | yes (live) | CORRECT | Both counts on pages. Note: State Dept page gives Dizengoff 20 killed, which the summary silently drops for 13–14 — acceptable since UN/MFA give 13–14. |
| evt_1996_bus_bombings | "Hamas suicide bombings" (all four) | S387 | yes (live) | CORRECT | Minor: State Dept says Hamas **and PIJ** both claimed Dizengoff; summary credits Hamas only. |
| evt_1996_bus_bombings | Revenge for Ayyash; closure barred 22,000 Gaza workers | S330 | yes (live) | CORRECT | Verbatim on live UNISPAL. |
| evt_1993_oslo_i | Signed 13 Sept 1993, White House, after secret Oslo talks; letters of recognition | S1146 history.state.gov | yes (live) | CORRECT | All quotes on page. |
| evt_1993_oslo_i | Interim self-government ≤5 years; permanent issues deferred | S1145 UN Peacemaker PDF (archive) | no – unreachable (live 404, archive 429) | UNSUPPORTED | Live PDF 404. Text correct per DOP Art. I, V. |
| evt_1998_mirabilis_icq | AOL buys Mirabilis (ICQ), $287m cash + up to $120m, announced 8 June 1998 | S381 NYT (archive) | yes (archive) | CORRECT | All quotes present in the archived NYT 9 June 1998 article. |
| evt_1998_mirabilis_icq | Founded 1996 by four young Israelis, Tel Aviv | S381 | yes (archive) | CORRECT | "founded two years ago by four Israelis in their early 20's"; Tel Aviv subsidiary. Cite's own `claim` text says "five young Israelis" — internal typo contradicting its quote and the summary. |

UNSUPPORTED here = the claim is (to my knowledge) true but its only cite(s) could not be opened by me, so it fails the "someone actually opened it" bar as cited. None of these were QUOTE-NOT-ON-PAGE: every quote on a page that did open was found verbatim (normalised).

COUNTS: CORRECT=35 WRONG=0 UNSUPPORTED=9 QUOTE-NOT-ON-PAGE=0 BIASED=2

Failures:
- Cast Lead "some 248 Hamas police": the opened cite (Ynet, S378) says 245; the 248 source (B'Tselem press release S834) unreachable.
- Cast Lead: 13 Israeli dead / >100 soldiers wounded / 20,000 homeless / Goldstone findings rest only on B'Tselem castlead page (S834/S1384) and OHCHR (S1385) archive copies that could not be opened; facts believed correct. Goldstone's 2011 partial retraction not mentioned.
- Cast Lead affected_populations BIASED: range 1,166–1,387 omits the Palestinian (PCHR) figure 1,434 that sits on the same cited Ynet page.
- Operation Accountability affected_populations BIASED: no Hezbollah/Lebanese combatant group although the cited HRW report gives Hezbollah's 17 and the IDF's 50–80 estimate.
- First Intifada: start date/accident and all B'Tselem figures (1,162; 1,070/237/54/17/21; 160) depend on S1027/S1028/S1029 archive copies that were unopenable; quoted table rows are arithmetically consistent.
- 1988 declaration: Darwish authorship (S1135 Britannica) and Arafat reading (S1136 NYT) unverifiable as cited.
- Oslo I: DOP text quotes (S1145 UN Peacemaker PDF) unverifiable (live 404, archive 429).
- Minor: Mirabilis cite `claim` says "five young Israelis" while its quote and the summary say four; 1996 summary credits Dizengoff to Hamas only (State Dept: Hamas and PIJ both claimed).

### 1. Events 2009–2026
Method: every cite's quote was machine-checked against the live page (curl) or the archive. Times of Israel pages (blocked by Cloudflare for curl) were opened with WebFetch and each phrase was confirmed verbatim. Each claim below was then read in context.

| Event | Claim | Cite (S-id) | Quote on page? | Verdict | Evidence/note |
|---|---|---|---|---|---|
| evt_2020_trump_peace_plan | Presented 28 Jan 2020 | S709 | yes (live) | CORRECT | WH fact sheet dated January 28, 2020 |
| evt_2020_trump_peace_plan | Demilitarised Palestinian state; Jerusalem undivided capital, Palestinian capital in parts of E. Jerusalem | S709 | yes | CORRECT | fact-sheet wording matches |
| evt_2020_trump_peace_plan | Sovereignty over settlements and Jordan Valley; Netanyahu and Gantz agreed to negotiate on its basis | S710, S709 | yes | CORRECT | NPR + WH |
| evt_2020_trump_peace_plan | PLO: about 15% of "historic Palestine"; Abbas and Hamas rejected it | S711 | yes | CORRECT | BBC, 29 Jan 2020 |
| evt_2020_trump_peace_plan | Day of rage the next day; 3 injured by live fire near Ramallah (MoH) | S711 | yes | CORRECT | BBC dated 29 Jan 2020 ("Wednesday") |
| evt_2020_trump_peace_plan | Netanyahu's Jordan Valley pledge, Sept 2019 | S712 | yes | CORRECT | BBC, 10 Sep 2019 |
| evt_2020_sudan_normalization | Agreed 23 Oct 2020, Trump-brokered | S1166 | yes | CORRECT | NBC dateline "Oct. 23, 2020"; the quote itself has no date, but the page has one |
| evt_2020_sudan_normalization | Sudan later signed the Abraham Accords Declaration | S1606 | yes (PDF) | CORRECT | State Dept PDF has a Sudan signature block. The PDF has no date (it was signed 6 Jan 2021), so "later" is not dated on the page |
| evt_2020_sudan_normalization | Bilateral agreement remained unratified | S1167 | yes | CORRECT | WINEP, 2023. True as of the article; no as-of date is given in the summary |
| evt_2023_huwara_rampage | Yaniv brothers Hillel (22) and Yagel (20) shot on Road 60 in Huwara, 26 Feb | S1715, S1717 | yes | CORRECT | OCHA POC 14–27 Feb 2023; BBC |
| evt_2023_huwara_rampage | Hundreds of settlers; Palestinian official estimated ~400 | S1716 | yes | CORRECT | Guardian (Ghassan Douglas) |
| evt_2023_huwara_rampage | 37 houses damaged, 55 cars + 1,200 scrapped vehicles burned, 8 households displaced (AP: 8–13 households) | S1715 | yes | CORRECT | OCHA: 8 households fully displaced plus "part of another five" (so 8–13 is right) |
| evt_2023_huwara_rampage | Sameh Aqtash (37) killed in Za'tara; shooter disputed; >100 injured (MoH), mostly tear gas | S1715, S1717, S1716 | yes | CORRECT | OCHA "either Israeli settlers or Israeli forces"; BBC; Guardian (95 treated for tear gas) |
| evt_2023_huwara_rampage | Soldier injured (per Israeli forces); firefighter injured | S1715 | yes | CORRECT | OCHA |
| evt_2023_huwara_rampage | Regional commander called it a "pogrom"; Smotrich on 1 March: Huwara "needs to be wiped out" | S1718 | yes (WebFetch, ToI) | CORRECT | ToI, 1 Mar 2023 15:21, quote verbatim. (Smotrich's later retraction is not mentioned; minor) |
| evt_2013_prawer_begin_shelved | Would move ~40,000 Bedouin (Al Jazeera); 40,000–70,000 (Independent) | S702, S704 | yes | CORRECT | |
| evt_2013_prawer_begin_shelved | Government rationale, $340m; HRW/Adalah criticism; Adalah counts 70,000 | S702, S701 | yes | CORRECT | balanced framing |
| evt_2013_prawer_begin_shelved | First reading 43–40, June 2013 | S703 | yes | CORRECT | Adalah release 25/06/2013 "This evening… 43 votes for and 40 against" |
| evt_2013_prawer_begin_shelved | Hura protest 30 Nov; Begin shelved the bill 12 Dec 2013 ("no majority"); Netanyahu approved | S701, S702 | yes | CORRECT | Al Jazeera, 12 Dec 2013: "a suggestion immediately approved by Netanyahu" |
| evt_2026_last_hostage_returned | Remains recovered Monday 26 Jan 2026 from a Gaza City cemetery | S1045 | yes (WebFetch, ToI) | CORRECT | ToI, 26 Jan 2026: al-Batash cemetery, Shejaiya; "843 days after" |
| evt_2026_last_hostage_returned | Killed at Kibbutz Alumim; last of the 251 | S494, S1045 | yes | CORRECT | Ynet + ToI |
| evt_2026_last_hostage_returned | Unit: Yasam (ToI) vs Border Police (Ynet) | S1045, S494 | yes | CORRECT | both pages confirmed; the disagreement is honestly flagged |
| evt_2026_last_hostage_returned | Israel made his return a precondition for Phase 2 and for reopening Rafah | S494 | yes | CORRECT | Ynet: "Israel set Gvili's return as a precondition for moving to Phase 2". (ToI says Phase 2 had been inaugurated the week before; the sources are in tension, but the summary's past perfect holds) |
| evt_2021_meron_disaster | 30 Apr 2021; 45 killed, ~150 injured, 20 critically | S436 | yes | CORRECT | JNS |
| evt_2021_meron_disaster | Mostly Haredi; steep, narrow ramp | S1183 | yes (WebFetch, ToI 3 May 2021) | CORRECT | |
| evt_2021_meron_disaster | Deadliest civilian disaster | S436 | yes | CORRECT | "worst civilian disaster in Israel's history" |
| evt_2021_meron_disaster | Commission (March 2024): Netanyahu personally responsible; Shabtai, Ohana blamed; Shabtai to step down | S436, S1184 | yes | CORRECT | JNS dated March 6, 2024; ToI 6 Mar 2024 |
| evt_2023_northern_front | Hezbollah fire from 8 Oct 2023 "in support of Hamas" | S1289 | yes (WebFetch, ToI 9 Oct 2023) | CORRECT | "in solidarity with the Hamas attack" |
| evt_2023_northern_front | 68,000 northerners displaced; evacuation cost 8.64bn shekels (Sept 2024) | S455 | yes | CORRECT | TPS (government figure, Sunday 29 Sep 2024) |
| evt_2023_northern_front | ~1.2 million displaced in Lebanon by the ceasefire | S464 | yes | CORRECT | Africanews/AP 27 Nov 2024 |
| evt_2023_northern_front | Lebanese MoPH: ≥3,961 killed, 16,520 injured, 8 Oct 2023–26 Nov 2024 (AP 3,760+) | S456, S464 | yes | CORRECT | as-of dates given; combatant/civilian split not given (stated) |
| evt_2023_northern_front | >80 soldiers and 47 civilians killed in Israel | S464 | yes | CORRECT | AP via Africanews |
| evt_2023_northern_front | Metula evacuated (most of ~2,200 residents) | S1852 | yes (WebFetch, ToI 21 Nov 2024) | CORRECT | |
| evt_2019_september_election | Held 17 Sept 2019 | S859 | yes (WebFetch, ToI 25 Sep 2019) | CORRECT | |
| evt_2019_september_election | Blue and White 33, Likud 32 | S1031, S859 | yes | CORRECT | Globes final results |
| evt_2019_september_election | Neither could form a coalition; third election March 2020 | S1032 | yes (WebFetch) | CORRECT | Jewish News/PA 12 Dec 2019: "March 2 date" |
| evt_2023_october_7_attack | ~1,200 killed (official), mostly civilians; 251 taken hostage | S448, S449 | yes | CORRECT | NPR 11 Nov 2023 (MFA "around 1,200"); KTVU/AP |
| evt_2023_october_7_attack | "an AFP tally of official Israeli figures, October 2024: 1,189, including 815 civilians" | S1279 | yes (WebFetch, France24 7 Oct 2024) | UNSUPPORTED | The figure is on the page, but the page does not name AFP or say how it was compiled, so the "AFP tally" attribution is not supported by the cite (CRITIC_01 flagged the same thing) |
| evt_2023_october_7_attack | Deadliest day in Israel's history; Be'eri, Kfar Aza, Nir Oz, Nahal Oz | S1279 | yes | CORRECT | France24 headline and body |
| evt_2023_october_7_attack | ~331 soldiers and 58 police killed on the Gaza border | S864 | yes (WebFetch, ToI running list, updated 25 Sep 2026) | CORRECT | the 331 come from an IDF list that includes local security officers. AP note says so; the summary's "331 soldiers" is slightly loose |
| evt_2023_october_7_attack | ~1,600 attackers killed inside Israel (IDF) | S452 | yes (WebFetch, ToI 29 Jan 2026) | CORRECT | attributed to the IDF |
| evt_2023_west_bank_toll_since_oct7 | OHCHR: 1,061 Palestinians incl. 231 children killed, 7 Oct 2023–3 Mar 2026 | S1700 | yes | CORRECT | ReliefWeb bulletin |
| evt_2023_west_bank_toll_since_oct7 | OCHA to Oct 2025: 999 killed (967 forces / 20 settlers / 12 unknown), ~half in Jenin and Tulkarm; >10,000 displaced | S1721 | yes | CORRECT | OCHA update 330 |
| evt_2023_west_bank_toll_since_oct7 | 41 Israelis (22 forces) killed in the WB plus 17 in Israel | S1721 | yes | CORRECT | |
| evt_2023_west_bank_toll_since_oct7 | Yearly: 548 / 504 / 241 / 45 (to 5 May 2026); 17 Israelis killed in WB in 2025 | S1387, S1722 | yes | CORRECT | ochaopt.org homepage "Until 5 May 2026"; update 352: 2025 = 240 Palestinians, 17 Israelis. The as-of date is given |
| evt_2018_nation_state_law | Passed 19 Jul 2018, 62–55 | S1190 | yes | CORRECT | Al Jazeera, 19 Jul 2018 |
| evt_2018_nation_state_law | Self-determination "exclusive to the Jewish People"; Arabic downgraded to "special status" | S1191, S1190 | yes | CORRECT | Knesset English PDF |
| evt_2018_nation_state_law | Jewish-only communities clause dropped after objections from the president and AG | S1190 | yes | CORRECT | |
| evt_2018_nation_state_law | Framing: only critics quoted (Arab/Druze citizens, AJC) | S1190 | — | BIASED | The summary gives the critics but none of the supporters' case. The same cited page has Netanyahu: "a defining moment in the annals of Zionism…" and "the majority also has rights". Add the proponents' rationale |
| evt_2025_october_ceasefire | Talks in Egypt on Trump's "20-point plan" produced a first phase | S1274 | yes (WebFetch, ToI 10 Oct 2025) | UNSUPPORTED | The page confirms "signed in Egypt by Israel, Hamas and mediators", but not "20-point plan" or "first phase". True historically, but not backed by the cite |
| evt_2025_october_ceasefire | 10 Oct: IDF pulled back to agreed lines, keeping ~53% of the Strip | S479 | yes (WebFetch) | CORRECT | ToI 10 Oct 2025 09:53 |
| evt_2025_october_ceasefire | 13 Oct: all 20 living hostages released; remains of 28 dead still in Gaza | S476 | yes (WebFetch; the quote was cut mid-sentence and given a full stop) | CORRECT | ToI 13 Oct 2025 |
| evt_2025_october_ceasefire | Israel released ~2,000 prisoners/detainees and returned >100 bodies, most unidentified | S1275 | yes | CORRECT | Al Jazeera 18 Oct 2025 has both. The bodies figure has no dedicated cite quote, but it is on the page |

COUNTS: CORRECT=50 WRONG=0 UNSUPPORTED=2 QUOTE-NOT-ON-PAGE=0 BIASED=1

Failures:
- evt_2023_october_7_attack: the "AFP tally" attribution for 1,189/815 is UNSUPPORTED. The cited France24 page gives the numbers but never names AFP or its method. This is the same flag as CRITIC_01, and it is still unfixed.
- evt_2025_october_ceasefire: "Trump's 20-point plan… first phase" is UNSUPPORTED by the cited ToI liveblog, which only says "signed in Egypt by Israel, Hamas and mediators".
- evt_2018_nation_state_law: BIASED, because it gives only critics. The government/proponent rationale is on the cited Al Jazeera page but missing from the summary.
- Minor notes (not failures): the Sudan "later signed" has no dated source and "remained unratified" has no as-of date. "331 soldiers" on 7 Oct includes local security officers. ToI and Ynet disagree on whether Phase 2 had already begun when Gvili was returned.

### 2–3. Neutrality and choices
Sample: seed 7741 (neutral.json = 15 casualty/displacement events not in the era sample; choices.json = 9 non-historical + 3 historical options, one per event).
Quote status is from my own fetch (curl with a browser user-agent, cached in scratchpad/pages). Times of Israel pages were checked with WebFetch, since curl hits a Cloudflare 403 there. Every web.archive.org request returned HTTP 429 (rate-limited) for the whole session, so archive-only cites are marked "unreachable".

#### A. Neutrality: 15 events

| Event | Groups present | Missing/problem | Attribution | As-of | Verdict | Note |
|---|---|---|---|---|---|---|
| evt_2025_war_resumes | gazans 404 killed / 562 wounded; israeli_hostages n.q.; israeli_civilians none | Gaza displacement (renewed evacuation orders) not listed | PA MoH (Al Jazeera), on page | "first day" | PASS (minor) | 404/562 found verbatim on the Al Jazeera page. |
| evt_2026_beit_shemesh_strike | israeli_civilians 9/28; iranians n.q. | none for a single strike | MDA via Al Jazeera | single day | PASS | "nine people were killed and 28 … two … serious" found verbatim. |
| evt_2024_iran_april_attack | negev_bedouin 1 wounded; israeli_civilians 8 minor; iranians none | 1 Apr Damascus consulate strike deaths (the trigger) not counted (outside the date range: acceptable); Jordan intercepts not mentioned | ToI / Soroka | 14 Apr 2024 | PASS | All ToI quotes confirmed via WebFetch (14 Apr 2024). The quote "99% were intercepted" is stitched: the page reads "99% of the 300 or so projectiles … were intercepted". |
| evt_1991_gulf_war_scuds | israeli_civilians 2–74; WB Palestinians 1.7M under curfew; gazans; iraqis none | — | JVL, HRW 1992 | n/a (closed) | PASS (minor) | 74 / 2 / 1.7M all on page. A cited source (israeled.org) says "13 deaths"; that conflicting count is not noted. |
| evt_2006_second_lebanon_war | lebanese 1,109–1,183 killed, 4,054–4,399 wounded, 0.97–1M displaced; hezbollah 250–600; israeli civ 43 / 1,384 / 350–500k displaced; IDF 121 / 1,244 | — | HRW, Amnesty, CIE | n/a | PASS (minor) | All figures found. CIE (cited) says "19 Israeli civilians" against HRW/Amnesty's 43; that divergence is not disclosed. |
| evt_2025_houthi_pm_killed | yemenis [11,11] killed / 92 wounded; israeli_civilians 22 wounded | Yemeni figure omits the ministers killed with al-Rahawi (Israeli media: PM + 12 ministers targeted) and the >40 killed in September strikes, yet the September Eilat drone's 22 Israeli wounded is counted | Houthis / Al Jazeera / NBC | mixed dates | FAIL (WRONG figure + BIASED window) | 11 = 1 PM + 10 killed on 24 Aug. It is internally inconsistent and asymmetric: the Israeli September casualties are counted, the Yemeni September deaths are "not included". |
| evt_2026_lebanon_war | lebanese 1,497–2,089 killed, 4,639 wounded, 1.2M displaced; IDF 13; israeli_civilians 2 (+1 by IDF fire) | the [low,high] range mixes two as-of dates (7 Apr vs 14 Apr), so it is not an estimate range; Hezbollah fighters not separated; Israeli displaced n.q.; no date_end although ToI (16 Apr) reports a truce | Leb. MoPH via Al Jazeera; ToI | 7/14 Apr; ToI 16 Apr 2026 | PASS (caveat) | ToI quote confirmed via WebFetch (16 Apr 2026). The summary's ">9,000 since 2024 (as of 9 Oct 2026)" is found on page. |
| evt_1982_bashir_assassination | lebanese 9 killed / 50 wounded | — | JTA first reports | labelled "first reports" | PASS (caveat) | "Eight other persons were reported dead and at least 50 injured" found. The figure is a first report; the commonly cited final toll is higher, and no later figure was sought. W&M Kahan cite unreachable (archive 429). |
| evt_1970_black_september | palestinians 2,000–4,000; jordanian_soldiers 537; israelis none | **Syrian forces** (armoured incursion of 18–23 Sep, in the summary) have no group; Iraqi force also present | jordanian_soldiers entry has **no note or attribution** (the cite says "Jordan reports") | n/a | FAIL (missing group + unattributed) | 537 and 2,000–4,000 found on israeled.org. |
| evt_1980_mayors_bombings | palestinians 2 wounded; israeli_police 1 wounded | — | named individuals (JTA) | n/a | PASS | Sapper injury on page (JTA 4 Jun 1984). |
| evt_2023_jenin_operation | WB Palestinians 13 / 143 / 3,500 displaced; IDF 1 | no combatant/civilian split, and Israel's claim that the dead were militants is absent (minor) | PA MoH via OCHA; Israeli officials | 5 Jul 2023 | PASS (minor) | 143 and 3,500 found on ReliefWeb/OCHA. |
| evt_2007_gaza_blockade | gazans, israeli_civilians, egyptians: **notes only, no figure field** | no killed/displaced/affected value and no "not quantified"; "egyptians" listed as an affected population is odd | OCHA 2022; MFA; Palmer | OCHA 2022 | FAIL (format: no figures) | The MFA communiqué and the UN Palmer report (9 cites) are unreachable (archive 429; the live un.org PDF returns 404), so ">5,000 rockets" and ">25 deaths" are unverified. |
| evt_1968_karameh | IDF 28–33; Jordanian soldiers 86; palestinian_fighters n.q.; camp residents n.q. | Palestinian fighters left "not quantified" even though figures exist; Jordanian wounded (108, in the quote) not used | **israeli_soldiers entry has no attribution**; the upper bound **33 has no cite** (Village Voice says 28) | n/a | FAIL (unattributed + unsupported bound) | Both cites for 86 are unreachable (archive 429; jordantimes.com 403). |
| evt_2005_gaza_disengagement | settlers 8,500; gazans none; Arab citizens 4/13; WB Palestinians 3–4 / 2 | the Shfaram attacker, killed by the crowd, is omitted; the 4 northern-WB settlements' residents are n.q. | CRS, Guardian | n/a | PASS (minor) | 8,500, 4/13 and "shot 4" found on CRS. |
| evt_2014_protective_edge | gazans 2,125–2,251 / 11,231 / 500k; IDF 67; israeli_civ 6, displaced n.q. | the 1,600 Israeli injured appear only in the note, not in a wounded field | UN COI via OCHA; IDF | "at peak" | PASS | OCHA figures all found. The IDF 2,125/936/761 PDF is unreachable (archive 429). |

COUNTS (A): 15 events: PASS 11 (5 with minor or caveat notes), FAIL 4 (houthi_pm_killed WRONG/BIASED; black_september missing group + unattributed; gaza_blockade no figures; karameh unattributed + unsupported bound).

#### B. Choices: 12 options

| Event/option | Advocate | Cite | Quote on page? | Verdict | Note |
|---|---|---|---|---|---|
| 2020_annexation_suspended #1, apply sovereignty over Jordan Valley + settlements (non-hist) | Netanyahu (real) | BBC 49655226; Guardian 29 Jun 2020 | yes / yes | CORRECT | BBC: Jordan Valley pledge, and "would annex all Jewish settlements". |
| 1985_security_zone #1, much deeper zone (non-hist) | Arens, Sharon (real) | CSM 22 Apr 1985 | yes | CORRECT | Page also confirms both "opposing the withdrawal" (18-3 vote, with Weizman). |
| 2024_iran_april_attack #2, retaliate much larger (non-hist) | Ben-Gvir (real) | JTA 18 Apr 2024; The National | yes / yes | CORRECT (weak) | The only evidence is the post-hoc "Lame" tweet; JTA adds "some in Israel had hoped for a more significant attack". No quote of him proposing a larger strike. |
| 2014_protective_edge #1, air/naval only + Egyptian track (non-hist) | Obama administration (real body) | JTA 17 Jul 2014 | yes | CORRECT | A foreign government, not an Israeli advocate; the option is acceptable as "a body that proposed it". |
| 1948_altalena #1, arms to Irgun battalions (non-hist) | Begin (real) | JVL Altalena | yes | CORRECT | — |
| 2023_judicial_overhaul_crisis #1, press ahead (non-hist) | Smotrich, Levin (real) | JTA 27 Mar 2023 (×2) | yes / yes | CORRECT | — |
| 1987_lavi_cancelled #1, continue Lavi (non-hist) | Shamir + Likud ministers, Arens | NYT 31 Aug 1987 (archive only) | **unreachable** (archive 429; nytimes.com 403) | UNSUPPORTED (as cited) | The claim matches the well-known record, but the cite could not be opened. |
| 1982_lebanon_war #1, openly launch broad war / install ally (non-hist) | Sharon, per Schiff & Ya'ari (real) | CSM 7 Jan 1985 | yes | CORRECT (caveat) | The source describes a covert aim, not an option Sharon openly proposed. The "openly" framing is the game's, and the note discloses it. |
| 2011_social_protests #1, negotiate directly with protest leaders (non-hist) | protest leaders (real body) | JTA 7 Aug 2011 | yes | CORRECT | Protest leaders "looking for direct dialogue with Netanyahu". |
| 1991_gulf_war_scuds #0, hold fire + Patriots (hist) | Shamir | israeled; PBS Baker | yes / yes | CORRECT | — |
| 1975_sebastia #0, Kadum compromise (hist) | Rabin; Peres | rabincenter ?p=8990 | yes | CORRECT (note partly UNSUPPORTED) | The page supports only Rabin approving Kadum after hesitation. "Peres arranged the compromise" and "army camp" are not on the page. |
| 2025_january_ceasefire #0, approve phased deal (hist) | security cabinet 9-2 | ToI 17 Jan 2025 (archive URL) | archive 429; **live ToI confirmed via WebFetch** | CORRECT | Both quotes are verbatim on the live page. The "then by the government" step is not in the cite. |

COUNTS (B): 12 options: CORRECT 11 (3 with caveats: Ben-Gvir weak, Sharon "openly" framing, Sebastia note partly unsupported), UNSUPPORTED 1 (Lavi, cite unreachable), WRONG 0, QUOTE-NOT-ON-PAGE 0, BIASED 0.

#### Failures
- evt_2025_houthi_pm_killed: yemenis killed [11,11] is WRONG and BIASED. It omits the ministers killed with al-Rahawi and the >40 Yemenis killed in September, yet counts the September Eilat drone's 22 Israeli wounded.
- evt_1970_black_september: the Syrian forces (incursion in the summary) are missing as a group, and jordanian_soldiers 537 has no attribution in affected_populations.
- evt_1968_karameh: israeli_soldiers [28,33] is unattributed, and 33 has no cite (Village Voice says 28). The Jordanian 86 is unverifiable: both cites are unreachable.
- evt_2007_gaza_blockade: all three groups are notes with no figure, "not quantified" or "none reported" (contract format). The MFA and UN Palmer cites (9 claims, incl. ">5,000 rockets", ">25 deaths") are unreachable.
- Minor:
  - 2026_lebanon_war: the range mixes two as-of dates, and there is no date_end despite the 16 Apr truce.
  - 2024_iran_april_attack: the quote "99% were intercepted" is stitched, not verbatim.
  - 1987_lavi choice: the only cite is an unreachable archived NYT page (UNSUPPORTED as cited).
  - 1975_sebastia note: "Peres arranged" is unsupported.
  - 2006 Lebanon: CIE's 19-civilian count against HRW/Amnesty's 43 is undisclosed.

### 4. Cities
The builder rewrote cities.json at 18:39:00 while this audit was running. Acre, Beit Shean, Sakhnin, Abu Ghosh, Qalqilya and Jenin changed. The rows below grade the **post-18:39 file**.

All four CBS spreadsheets were downloaded and parsed directly with openpyxl/xlrd: bycode2022.xlsx (S004), the 2022 Census-estimate xlsx (S003), bycode2008.xls (S002) and bycode2004.xls (S007). The automated quote checker reported "NOTFOUND" on the founding-year quotes, but that was an artifact: the checker did not parse spreadsheets. Every row it quoted is in the file.

Some pages were blocked when fetched directly: the web.archive.org copies of Britannica and JPS (HTTP 429), and the live Britannica and JPS pages (403). On retry with spacing, the Wayback copies loaded (`id_` snapshots 20241005, 20240129 and 20241231).

| City | Field | Data value | Cite | Quote on page? | Verdict | Note |
|---|---|---|---|---|---|---|
| karmiel | founded | 1964 | S004 bycode2022 row 1139 | yes (parsed xlsx: שנת ייסוד=1964) | CORRECT | |
| karmiel | status 1964→ israel | "inhabited since 1964" | S1022 Britannica (archive) | yes | CORRECT | S1022's entry in sources.json has url null and a citation string that is just the URL (no title or author). |
| karmiel | status note: Bet Kerem valley | | S1022 | yes | CORRECT | |
| karmiel | pop 2022 | 47,450 | S003 | 47,449.6 | CORRECT | |
| acre | founded | pre-1948 | none | n/a | CORRECT | Trivially true; CBS gives 1948. |
| acre | status 1948-05-14→05-17 arab_held | | S2052 JPS abstract (Abbasi) | yes (archive 20240129) | CORRECT | |
| acre | status 1948-05-17 israel (date) | 17 May 1948 | S2052 | yes: "Yet on 17 May 1948 … fell to the Haganah forces" | CORRECT | IPS/PalQuest gives 16 May. The earlier version noted this; the new one dropped it. |
| acre | status note: "much of its Arab population fled or was displaced; Old City remained largely Arab" | | S103 Britannica, S102 OoH, S1081 FRUS | quotes are on the pages, but none mentions Acre | UNSUPPORTED | These are generic 1948-war cites used as padding. |
| acre | pop 2022 | 50,555 | S003 | 50,555.4 | CORRECT | |
| beit_shean | founded | 1948 | no founded_cite | n/a | UNSUPPORTED | Matches CBS bycode2022 (1948). |
| beit_shean | status 1948-05-14 israel; "captured by Haganah, inhabitants fled or were expelled" | | S105 (Morris book landing page, no page number), cite [] | n/a | UNSUPPORTED | The fact is right: Haganah took it on 12 May 1948. The pre-18:39 file had Britannica and PalQuest cites; the new file removed them. |
| beit_shean | pop 2022 | 19,825 | S003 | 19,824.7 | CORRECT | |
| arad | founded | 1961 | S004 row 2560 | yes | CORRECT | |
| arad | status 1961→ israel | | S164, S004; cite [] | n/a | UNSUPPORTED | The S164 JVL page does say "Arad was founded in 1961", but there is no cite entry. |
| arad | pop 2008 | 23,403 | S002 | 23,403 | CORRECT | |
| kiryat_bialik | founded | 1934 | no founded_cite | n/a | UNSUPPORTED | CBS bycode2022 confirms 1934. |
| kiryat_bialik | status 1948-05-14 israel | | S100; cite [] | n/a | UNSUPPORTED | Trivially true. |
| kiryat_bialik | pop 2008 | 37,162 | S002 | 37,162 | CORRECT | |
| sakhnin | founded | pre-1948 | none | n/a | CORRECT | Trivial. |
| sakhnin | status 1948-05-14→1948-10 arab_held ("outside Israeli control until Hiram") | | S150 JTA, S1255 ECF | the quotes are on the pages but are about military rule 1948–66 | UNSUPPORTED | New entry added at 18:39. Its cites do not address the claim. |
| sakhnin | status 1948-10 Israeli control (Op. Hiram) | late Oct 1948 | S1244 FRUS 1948 v5 d728 | yes | CORRECT | The cite covers the general Galilee offensive; Sakhnin is not named. |
| sakhnin | military government until 1966-12-01 | | S150 JTA | yes ("by December 1, 1966") | CORRECT | |
| sakhnin | status 1966-12-01→ israel | | S150; cite [] | n/a | UNSUPPORTED | The fact is correct per S150. |
| sakhnin | pop 2022 | 32,354 | S003 | 32,354.5 | CORRECT | |
| rahat | founded | 1972-05-25 (cornerstone) | S2003 **Hebrew Wikipedia** | yes | UNSUPPORTED | Wikipedia is not a published source under the bar, and CBS gives no founding year. 1972 is very likely right. |
| rahat | status 1972-05-25 israel; "city status 1994" | | S2003 Wikipedia | yes (1972 quote only) | UNSUPPORTED | Wikipedia-only; the 1994 city status has no cite. |
| rahat | pop 2008 | 49,982 | S002 | 49,982 | CORRECT | Note: the 2022 figure (71,355) uses S003; bycode2022 gives 79,064. The data uses S003 consistently. |
| abu_ghosh | founded note: "residents largely remained in 1948" | | none | n/a | UNSUPPORTED | It also omits the partial expulsion of the villagers in July 1948 (Morris), which is a neutrality concern. |
| abu_ghosh | status 1948-05-14 israel | | S100 (Declaration); cite [] | n/a | UNSUPPORTED | Nothing sources Israeli control of the village on 14 May 1948. |
| abu_ghosh | founded | pre-1948 | none | n/a | CORRECT | Trivial. |
| abu_ghosh | pop 2008 | 5,830 | S002 | 5,830 | CORRECT | |
| qalqilya | founded | pre-1948 | none | n/a | CORRECT | Trivial. |
| qalqilya | status 1948-05→1967-06 **jordanian_administered** | | S1294 FRUS 1949 v6 d554 | yes ("Israel agrees to taking over by Arab Legion on Iraqi front", 24 Mar 1949) | WRONG | Its own cite shows the Arab Legion took over only in spring 1949. From May 1948 to 1949 the town was Iraqi-held (the note even says so), so the status value is wrong for about a year. |
| qalqilya | status 1967-06 israeli_occupied | | S200; cite [] | n/a | UNSUPPORTED | The fact is correct. |
| qalqilya | 1967 status note | | | | BIASED | Omission. The note does not mention the June 1967 demolition of a large part of the town or the temporary expulsion of its residents (Segev, *1967*; Dayan). |
| qalqilya | status 1995-12-16 pa_area_a | | S013, S328; cite [] | n/a | UNSUPPORTED | The S013 UNISPAL Dec-1995 page does say "16 December Israeli troops withdrew from … Qalqilya" (verified), but there is no cite entry. |
| qalqilya | status from 2002-03-29 (Defensive Shield re-entry) | 29 Mar 2002 | S1337 UN SG/2077 (archive) | yes | WRONG | Its own quote says "entry into Tulkarm and Qalqilya on 1 April". |
| qalqilya | pop 2017 | 51,683 | S011 citypopulation (PCBS) | yes | CORRECT | |
| jenin | founded | pre-1948 | none | n/a | CORRECT | Trivial. |
| jenin | status 1948-05→1967-06 jordanian_administered | | S1294 | yes | WRONG | Same problem: Iraqi-held (from the battle of 1–3 June 1948) until the Arab Legion took over in 1949. |
| jenin | status 1967-06 israeli_occupied | | S200; cite [] | n/a | UNSUPPORTED | |
| jenin | status 1995-11 pa_area_a | | S014, S328; cite [] | n/a | UNSUPPORTED | J. Weekly (via WebFetch): Arafat visited "a week after Israel completed its withdrawal". The fact is correct (13 Nov 1995). |
| jenin | status from 2002-03-29 | 29 Mar 2002 | S1337 | yes | WRONG | Its own quote says "Jenin and Nablus on 3 April". |
| jenin | status 2025-01-21 Iron Wall, largest displacement since 1967 | | S1295 OCHA PDF | yes ×3 | CORRECT | |
| jenin | pop 1967 | 13,365 | S009 Levy Inst. PDF (live) | figure present; the table layout is garbled | CORRECT | |
| katzrin | founded | 1977 | S004 row 4100 | yes | CORRECT | |
| katzrin | status 1977→1981 israeli_occupied | | S004, S200; cite [] | n/a | UNSUPPORTED | |
| katzrin | status 1981-12-14 law applied (63–21) | | S1416 JTA | yes | CORRECT | |
| katzrin | UNSC 497 "null and void", unanimous | | S1417 UN PDF | yes (OCR noise: "I. Decides", "unanimou.rlv") | CORRECT | |
| katzrin | pop 2022 | 7,633 | S003 | 7,632.8 | CORRECT | |
| neve_dekalim | founded | 1980 | S007 bycode2004.xls row 5427 | yes (parsed: שנת ייסוד=1980.0) | CORRECT | |
| neve_dekalim | status 1980→2005-08 israeli_settlement | | S007; cite [] | n/a | UNSUPPORTED | |
| neve_dekalim | status 2005-08 evacuated | | S833 CRS RS22000 | yes; the page also gives Gaza evacuation 17–22 Aug 2005 | CORRECT | |
| neve_dekalim | pop 2004 | 2,636 | S007 | 2,636 | CORRECT | |

COUNTS: 54 checks: CORRECT 31, WRONG 4, UNSUPPORTED 18, QUOTE-NOT-ON-PAGE 0, BIASED 1.

All 12 population spot-checks match CBS, PCBS or Levy.

Across the full file, 110 of 194 status entries have `cite: []`, and 72 of 117 cities have no `founded_cite`. These counts come from the pre-18:39 file.

#### Failures
- **WRONG:** Qalqilya and Jenin are marked `jordanian_administered` from May 1948. They were Iraqi-held until the Arab Legion took over in spring 1949, which their own S1294 cite (24 Mar 1949) shows.
- **WRONG:** Qalqilya and Jenin Defensive Shield control dates are 2002-03-29. Their own S1337 quote gives 1 April (Qalqilya) and 3 April (Jenin).
- **UNSUPPORTED (empty `cite`):** 11 status entries:
  - Beit Shean 1948
  - Arad 1961
  - Kiryat Bialik 1948
  - Sakhnin 1966
  - Abu Ghosh 1948
  - Qalqilya 1967 and 1995
  - Jenin 1967 and 1995
  - Katzrin 1977
  - Neve Dekalim 1980

  For several of these, the listed source does contain the fact (S164, S013, S014), so only the cite entry is missing.
- **UNSUPPORTED:** Beit Shean's Britannica and PalQuest cites were *removed* in the 18:39 rewrite, leaving only a book landing page (S105) with no page number.
- **UNSUPPORTED:** the founding years of Beit Shean and Kiryat Bialik have no founded_cite. Both are correct per CBS.
- **UNSUPPORTED:** Rahat's founding and status rest only on Hebrew Wikipedia (S2003), which fails the bar's "via Wikipedia" rule.
- **UNSUPPORTED:** Sakhnin's new 1948-05→1948-10 `arab_held` entry cites military-government sources that don't address it.
- **UNSUPPORTED:** Acre's displacement note relies on generic 1948-war cites (S103/S102/S1081) that never mention Acre.
- **UNSUPPORTED:** Abu Ghosh's "residents largely remained" note and its 14 May 1948 Israeli status are unsourced. The note omits the July 1948 expulsions.
- **BIASED:** Qalqilya's 1967 entry omits the town's partial demolition and the temporary expulsion of its residents.
- **Source hygiene:** auto-generated source entries (S1022 with url null; S1081, S1294, S1337, S1417 titled only by domain) have no title, author or date.


## 5. Top 10 omissions that remain

All 10 omissions listed by CRITIC_01 are now in the data:
- West Bank 2022–26;
- the Gaza blockade;
- al-Dawayima;
- the Yemenite children affair;
- the 2009 election;
- the Houthi war;
- the Negev Bedouin and Prawer;
- the Trump plan and the Golan recognition;
- the holy-site flashpoints;
- the JCPOA.

The list below comes from a keyword scan of all 351 titles and summaries; none of these items appears anywhere in events.json.

| # | Missing | Why it matters | Primary source to cite |
|---|---|---|---|
| 1 | **2022, the "lost year":** the March–May 2022 attack wave (Beersheba, Hadera, Bnei Brak, Tel Aviv, Elad: about 19 killed in Israel), Operation Break the Wave, the killing of journalist Shireen Abu Akleh in Jenin (11 May 2022), and Operation Breaking Dawn in Gaza (Aug 2022, 49 Palestinians killed). | The only 2022 events are the maritime deal and the election. This year set up the 2023 West Bank escalation, and both Israeli and Palestinian victims are missing. | UN OHCHR, 24 Jun 2022 (Abu Akleh findings) (Geneva press briefing); OCHA "Protection of Civilians" 2022 |
| 2 | **Gaza aid-seeking mass-casualty incidents, 2024–25:** the "flour massacre" (29 Feb 2024, 100+ killed), the World Central Kitchen convoy strike (1 Apr 2024, 7 aid workers), and the killings near Gaza Humanitarian Foundation sites (OHCHR: more than 1,000 killed by July 2025). | These are central to the famine and ICJ narrative. The famine event exists, but the incidents that drove the international response do not. | OHCHR press briefing 15 Jul 2025; WCK statement 2 Apr 2024 |
| 3 | **Nuseirat hostage rescue (8 Jun 2024):** 4 hostages freed; the Gaza MoH reported 274 Palestinians killed. | This is the war's defining hostage-versus-civilian-cost trade-off. A natural two-population event. | IDF/Times of Israel 8 Jun 2024; UN OCHA flash update |
| 4 | **The six hostages executed in Rafah (Aug 2024) and the 1 Sep 2024 Histadrut general strike.** | This was the largest domestic protest of the war and the high point of the hostage-deal debate. It is the obvious "choice" event, with named advocates on both sides. | Histadrut / Times of Israel 1 Sep 2024 |
| 5 | **UNRWA ban laws (28 Oct 2024)** | They ended UNRWA's operations in Israeli territory and contacts with Israeli officials. The data has UNRWA's creation in 1949 but not its end. | Knesset press release 28 Oct 2024; UN SG letter 9 Oct 2024 |
| 6 | **Haredi conscription before 2026:** Ben-Gurion's 1948 Torato Umanuto exemption, the Tal Law (2002) and its striking-down (2012), and the HCJ ruling of 25 Jun 2024 ordering Haredi conscription. | The 2026 Torah Study Basic Law appears with no history behind it. This is one of Israel's core social cleavages. | IDI, "Haredi draft" timeline; HCJ 6198/23 ruling (25 Jun 2024) |
| 7 | **Mughrabi (Moroccan) Quarter demolished, 10–11 Jun 1967.** About 100–135 families were displaced to create the Western Wall plaza. | This is a 1967 displacement inside Jerusalem. The 1967 displacement event covers only the West Bank, Gaza and the Golan. | Jerusalem Quarterly / Institute for Palestine Studies; Meron Benvenisti (print) |
| 8 | **Fall of the Jewish Quarter (28 May 1948), the battles of Latrun (May–Jul 1948) and the "Burma Road".** | Jerusalem's 1948 outcome appears only as a line in the 1949 armistice. The Jewish Quarter's residents (about 1,300–1,500) were expelled and the Quarter held by Jordan until 1967. | JVL / Israel State Archives; Morris, *1948* (Yale 2008), ch. 5 |
| 9 | **Lausanne Conference (Apr–Sep 1949), including the "100,000 refugees" offer.** | This was the first refugee-return and borders negotiation. It belongs with UNGA 194 and UNRWA. | UNISPAL A/1367/Rev.1 (Conciliation Commission progress report); FRUS 1949 vol. VI |
| 10 | **Duma arson (31 Jul 2015, the Dawabsheh family) and the 2015 Jerusalem Pride stabbing (Shira Banki).** | These are the defining Jewish-extremist attacks of the 2010s. The 2015 stabbing-wave event covers only Palestinian attacks. | Times of Israel 31 Jul 2015; Shin Bet indictment Jan 2016 (Amiram Ben-Uliel, convicted 2020) |

**Honourable mentions:**
- the 1966–67 recession;
- Israel joining the OECD (2010);
- Druze conscription (1956);
- the USS Liberty (1967);
- Avivim (1970) and Bahr el-Baqar (1970). Bahr el-Baqar appears in the War of Attrition summary, but not as an event of its own;
- the 2016 Elor Azaria shooting and trial;
- the 2017 Settlement Regulation Law;
- the Masafer Yatta firing-zone ruling (2022);
- the Ma'ale Akrabim bus attack (1954).

## 6. SINGLE BIGGEST GAP

**The places layer (cities.json) has not reached the citation standard the events now meet.**

Round 2 brought events close to the bar:
- No event checks were WRONG, and no checked quote was missing from its page.
- Every claim has its own cite.

The control timeline in cities.json still does not meet the bar. That timeline is what the game uses to decide who holds each town at each turn:
- **43% of status entries have no cite at all.** That is 87 of 203 entries in the 18:54 file, and 11 of the 27 sampled.
- **62% of cities have no `founded_cite`.** That is 72 of 117.
- **Every WRONG verdict on dates or places in this audit is in this layer:**
  - Qalqilya and Jenin are shown as Jordanian from May 1948. They were Iraqi-held until the Arab Legion took over in 1949.
  - Defensive Shield re-entry is dated 29 Mar instead of 1 and 3 Apr. In both cases the city's own cite contradicts the date.
- **Where cites do exist, many are generic.** Acre's 1948 note cites war-wide sources that never name Acre. Beit Shean rests on a book landing page with no page number. Rahat rests on Hebrew Wikipedia.
- **Displacement inside towns is under-reported:**
  - Abu Ghosh: the July 1948 expulsions are missing.
  - Qalqilya: the June 1967 demolitions are missing.
  - Acre: no figures.

  The neutrality rule is enforced on events but not on cities.
- **`check_sources.py` passes regardless**, because it only checks status cites that exist. An empty `cite: []` is never flagged.

**Concrete fix (one builder round):**
1. **Make the checker fail on gaps.** Make `check_sources.py` fail when:
   - any `status[]` entry has `cite: []`;
   - a city lacks `founded_cite`;
   - any status, founded or cite entry relies only on a source marked Wikipedia (S2003);
   - a status cite's quote names neither the town nor the transfer it supports. Test: the quote must contain the city's `name`, `name_he` or an alias.
2. **Fill the status cites from one primary source per transfer type.** Each source below covers dozens of towns in one fetch:
   - **1948 capture dates:** Morris, *Birth … Revisited*, Map 1 and the village list with page numbers. This replaces the S105 landing page.
   - **1949 Iraqi-to-Jordanian handover:** Israel–Jordan Armistice Agreement, Art. VI, UN document S/1302/Rev.1 (on UNISPAL or UN Peacemaker). Mark the West Bank towns `iraqi_held` from 1948-05 to 1949-04 rather than Jordanian.
   - **1967:** the UN Secretary-General's and UNTSO reports of June 1967 on documents.un.org, and the IDF entry dates for each town.
   - **1995 Oslo II redeployments:** use the UNISPAL S/1995/... progress reports, or the Oslo II annex map dates (Jenin 13 Nov 1995, Qalqilya 16 Dec 1995). S013 and S014 already contain these dates; only the cite entries are missing.
   - **2002 Defensive Shield entries:** use the UN SG report A/ES-10/186 (30 Jul 2002), which dates each town's entry.
   - **2005 disengagement:** use the Knesset Disengagement Plan Implementation Law and the IDF completion dates.
3. **Add displacement to the status notes**, with both populations and an as-of date. For example: Acre, Arab population before and after May 1948 per Morris; Abu Ghosh, July 1948; Qalqilya, June 1967.
4. **Report coverage in the checker's summary**, e.g. `status entries cited: n/203`. Treat anything below 100% as a failure, the same rule as event cites.

**Second-biggest gap:** 365 of 2,732 event cites point only at web.archive.org, and 14 events cite nothing else. Those cites cannot be checked whenever the Wayback Machine rate-limits, as it did throughout this audit, and the builder's own `--net` run skipped 149 unreachable URLs without failing. **Fix:** for every number-bearing claim, require one live primary URL alongside the archive copy (UNISPAL, OCHA, B'Tselem live statistics, IDI, CBS), and have `--net` fail when neither copy is reachable.
