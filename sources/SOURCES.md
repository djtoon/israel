# Sources — Civilization: Israel (history data)

Generated from `sources/sources.json` by `python tools/check_sources.py --render`. Do not hand-edit.

Each entry: **[Sxxx]** Author/Org, *Title*, Publisher, Year — URL — archived URL — accessed date — provenance.
Provenance: `opened` = the page/file was opened and the quoted claims checked; `not_opened` / `snippet` = listed for reference only — such a source may be cited only through a `cite` entry that carries a verbatim quote from an opened URL (original or web.archive.org) or a print page number. Per-claim quotes live in the `cite` lists of `game/data/events.json`.

**[S001]** Israel Central Bureau of Statistics (CBS), 'List of Localities, Their Population and Codes' (1995 Census of Population and Housing publication; data file nonum.xls), CBS, Jerusalem, 2002-2003; archived copy — https://web.archive.org/web/20120413142708/http://www.cbs.gov.il/mifkad/tables/more_tabeles/pirsom3/nonum.xls — archived: https://web.archive.org/web/20120413142708/http://www.cbs.gov.il/mifkad/tables/more_tabeles/pirsom3/nonum.xls — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Population of every Israeli locality at the censuses of 8 Nov 1948, 22 May 1961, 20 May 1972, 4 Jun 1983 and 4 Nov 1995 (columns 'אוכלוסיה 48'..'אוכלסייה 95'); '..' = not enumerated separately, '-' = locality did not exist
    - Year of settlement of each locality (e.g. Degania Alef 1909, Ashdod 1955, Neve Dekalim 1980, Hura first listed 1995, Tel Sheva first listed 1983)
    - Used for all cities.json population keys 1948-1995 marked S001
    - Neve Dekalim was founded in 1983
    - settled from 1980 (CBS); 16 residents in 1983, 1,667 in 1995

**[S002]** Israel Central Bureau of Statistics, Localities file 2008 'יישובים 2008 לאחר מפקד 2008' (bycode2008.xls), CBS, 2009 — https://www.cbs.gov.il/he/publications/doclib/2019/ishuvim/bycode2008.xls — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - End-2008 population of each locality following the 2008 census
    - Locality names in 2008 including merged municipalities Baqa-Jatt, Carmel City (Daliyat al-Karmel + Isfiya) and Katzir-Harish

**[S003]** Israel Central Bureau of Statistics, 'Population and households by locality - 2022 Census estimate' (xlsx), CBS, 2025 — https://www.cbs.gov.il/he/publications/LochutTlushim/2025/Population%20and%20households%20by%20locality%20-%202022%20Census%20estimate.xlsx — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 2022 census population estimate for every locality (used for all cities.json '2022' values), including West Bank settlements and Golan localities enumerated by CBS

**[S004]** Israel Central Bureau of Statistics, Localities file 2022 'קובץ יישובים 2022' (bycode2022.xlsx), CBS, 2023 — https://www.cbs.gov.il/he/publications/doclib/2019/ishuvim/bycode2022.xlsx — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Founding year ('שנת ייסוד') of each locality, e.g. Tel Aviv-Yafo 1909, Ashdod 1955, Beersheba 1948, Eilat 1951, Karmiel 1964, Dimona 1955, Arad 1961, Modi'in-Maccabim-Re'ut 1986, El'ad 1998, Harish 1982, Ariel 1978, Ma'ale Adumim 1975, Modi'in Illit 1996, Beitar Illit 1985, Kiryat Arba 1972, Kfar Etzion 1967, Katzrin 1977; 'ותיק' (veteran) for Jerusalem, Haifa, Tiberias, Safed
    - ITM grid coordinates of each locality (converted to WGS84 lat/lon for cities.json)
    - Municipal status and district of each locality
    - Katzrin was established in 1977 (places: katzrin, golan_heights)
    - Kiryat Arba founding year per official locality register
    - founded 1955
    - founded 1950
    - CBS founding year 1986 (Maccabim-Re'ut)
    - founded 1954
    - founded 1964
    - founded 1957
    - founded 1961
    - founded 1951
    - founded 1956
    - founded 1952
    - founded 1998
    - founded 1982
    - founded 1953
    - founded 1977
    - founded 1978
    - founded 1975
    - founded 1996
    - founded 1985
    - founded 1972
    - founded 1967
    - founded 1949
    - CBS founding year 1957 (Ma'alot)
    - CBS founding year 1924
    - CBS locality register gives founding year 1909
    - Listed in the CBS 2022 locality register as a locality of Israel (municipal status and founding year)
    - CBS locality register gives founding year 1882
    - CBS locality register gives founding year 1878
    - CBS locality register gives founding year 1929
    - CBS locality register gives founding year 1924
    - CBS locality register gives founding year 1933
    - CBS locality register gives founding year 1921
    - CBS locality register gives founding year 1890
    - CBS locality register gives founding year 1926
    - CBS locality register gives founding year 1903
    - CBS locality register gives founding year 1934

**[S005]** Israel Central Bureau of Statistics, Statistical Abstract of Israel No. 14 (1963), Table 11 'Population in Settlements Numbering above 5,000 Inhabitants on 31 XII 1962 (1948-1962)' — https://www.cbs.gov.il/he/publications/DocLib/shnaton_saruk/shnaton1963_num14.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Cross-check of 8 Nov 1948 and 22 May 1961 census populations of towns (e.g. Haifa 98,618 and 183,021; Tel Aviv-Yafo 248,459 and 386,070; Beersheba 1949 1,800 and 1961 43,516)

**[S006]** Israel Central Bureau of Statistics, Statistical Abstract of Israel No. 36 (1985), Table II/14 'Population in localities numbering above 5,000 inhabitants on 31 XII 1984' — https://www.cbs.gov.il/he/publications/DocLib/shnaton_saruk/shnaton1985_num36.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Cross-check of 4 Jun 1983 census populations (e.g. Beersheba 110.8 thousand, Majdal Shams 5.6 thousand, Arad 12.4 thousand)

**[S007]** Israel Central Bureau of Statistics, Localities file 2004 (bycode2004.xls), CBS, 2005 — https://www.cbs.gov.il/he/publications/doclib/2019/ishuvim/bycode2004.xls — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Neve Dekalim (Gaza Strip, code 5427): end-2004 population 2,636; founding year 1980
    - founded 1980
    - Neve Dekalim founded 1980 (CBS locality register)

**[S008]** Israel Central Bureau of Statistics, 'Population Census 2022' (survey page) — https://www.cbs.gov.il/en/Surveys/Pages/Population-Census.aspx — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - The 2022 census was Israel's seventh and took place between 3 April and 31 December 2022

**[S009]** Levy Economics Institute of Bard College, 'The 1967 Census of the West Bank and Gaza Strip: A Digitized Version' (ed. Joel Perlmann), Vol. 1, Table I 'West Bank population according to 1967 census and Jordanian 1961 census' — https://www.levyinstitute.org/levy-files/pubs/1967_census/vol_1_intro_tab_i.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - West Bank 1967 (Israeli CBS) and 1961 (Jordanian census) populations: Hebron 38,348 / 37,868; Nablus 44,223 / 45,768; Jenin 13,365 / 14,402; Tulkarm 15,275 / 20,690; Qalqiliya 8,926 / 11,401; Jericho 6,829 / 10,166; Ramallah and Bira 25,171 / 29,269; Bethlehem with Beit Jala, Beit Sahur and Dheisheh 31,883 / 35,735
    - West Bank total (excl. East Jerusalem) 598,637 in 1967 vs 729,804 in 1961; Jericho district fell from 63,980 to 9,078

**[S010]** Levy Economics Institute of Bard College, 'The 1967 Census of the West Bank and Gaza Strip: A Digitized Version', Vol. 1, Table J 'Gaza Strip population according to 1967 census and Egyptian estimate for 1966' — https://www.levyinstitute.org/levy-files/pubs/1967_census/vol_1_intro_tab_j.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Gaza Strip 1967 census total 356,261 (Egyptian 1966 estimate 454,960)
    - Gaza 118,272; Khan Yunis 52,997; Rafah 49,812 (incl. ~2,500 in southern Rafah); Jabaliya 43,604; Deir el-Balah 18,118

**[S011]** Thomas Brinkhoff, 'Palestine: Governorates, Cities and Localities' (citypopulation.de), compiling Palestinian Central Bureau of Statistics census results 1997, 2007, 2017 — https://www.citypopulation.de/en/palestine/cities/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - PCBS census populations (10 Dec 1997 / 1 Dec 2007 / 1 Dec 2017): Hebron 119,401/163,146/201,063; Nablus 100,231/126,132/156,906; Ramallah 18,017/27,460/38,998; Bethlehem 21,947/25,266/28,591; Jenin 35,791/49,375/60,325; Tulkarm 44,029/61,941/74,463; Qalqilya 31,772/41,739/51,683; Jericho 14,744/18,346/20,907; Gaza 353,632/483,869/631,215; Khan Yunis 123,175/180,342/246,307; Rafah 109,174/156,332/208,449; Deir al-Balah 42,870/60,877/82,117; Jabalia 113,901/164,931/222,166
    - Figures include Arab residents of East Jerusalem in the relevant governorate and exclude Israeli settlers

**[S012]** Thomas Brinkhoff, 'Israel: Districts, Cities and Urban Localities' (citypopulation.de), compiling CBS census results 1983, 1995, 2008 — https://www.citypopulation.de/en/israel/cities/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Independent cross-check of CBS 1983, 1995 and 2008 census populations of cities (e.g. Ariel 1,222 / 12,754 / 17,500; Ma'ale Adumim 3,504 / 17,691 / 33,600)

**[S013]** United Nations, Division for Palestinian Rights, 'Chronological Review of Events / December 1995' — https://www.un.org/unispal/?p=203224 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Palestinian police took over Tulkarm after the Israeli withdrawal (entry of ~10 Dec 1995)
    - Israeli soldiers withdrew from Nablus a day ahead of schedule (11 Dec 1995)
    - 16 Dec 1995: Israeli troops withdrew from Qalqilya, the fourth town handed over
    - 21 Dec 1995: Israel withdrew from Bethlehem and handed control to the PA
    - 27 Dec 1995: Israeli troops began withdrawing from Ramallah, the last town to be handed over
    - UN chronology (16 December 1995): Israeli troops withdrew from Qalqilya and handed it to the Palestinian Authority
    - UN chronology (entry placed under 9 December 1995): Palestinian police took control of Tulkarm after the Israeli troop withdrawal
    - UN chronology (21 December 1995): Israel withdrew from Bethlehem and handed control to the Palestinian Authority
    - UN chronology (11 December 1995 entry, citing The New York Times): Israeli soldiers withdrew from Nablus and Palestinian police took over
    - UN chronology (27 December 1995): Israeli troops began to withdraw from Ramallah, the last town handed over

**[S014]** J. The Jewish News of Northern California, 'Arafat visits Jenin, calls for support of elections', 24 November 1995; JTA, 'Efforts under way to hand over Jenin' (Nov 1995) — https://jweekly.com/1995/11/24/arafat-visits-jenin-calls-for-support-of-elections/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel completed its withdrawal from Jenin in November 1995, about a week before Arafat's visit; Jenin was the first West Bank town handed over under Oslo II (withdrawal began 25 Oct 1995)
    - J. (Jewish News of Northern California), 24 Nov 1995: Israel completed its withdrawal from Jenin
    - Jenin was the first of seven West Bank towns to come under Palestinian self-rule

**[S015]** Wikidata, coordinate (P625) statements for localities not covered by CBS locality files (Palestinian cities, Quneitra, Yamit, Neve Dekalim) - used for map placement only — https://www.wikidata.org/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Approximate latitude/longitude of Hebron, Nablus, Ramallah, Bethlehem, Jenin, Tulkarm, Qalqilya, Jericho, Gaza City, Khan Yunis, Rafah, Deir al-Balah, Jabalia, Neve Dekalim, Quneitra and Yamit

**[S100]** Israel Ministry of Foreign Affairs, Declaration of Establishment of State of Israel, gov.il, 1948 (text) — https://embassies.gov.il/MFA/AboutIsrael/history/Pages/Declaration of Establishment of State of Israel.aspx — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Declaration read in Tel Aviv on 14 May 1948
    - US recognised the state that night; USSR three days later

**[S101]** Jewish Virtual Library (AICE), The Declaration of the Establishment of the State of Israel, 2026 — https://www.jewishvirtuallibrary.org/the-declaration-of-the-establishment-of-the-state-of-israel — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Full text of the 14 May 1948 Declaration
    - place: declaration read at the Tel Aviv Museum
    - hours before the British Mandate ended
    - The Soviet Union recognised the state three days later

**[S102]** U.S. Department of State, Office of the Historian, The Arab-Israeli War of 1948 (Milestones 1945-1952) — https://history.state.gov/milestones/1945-1952/arab-israeli-war — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel declared independence 14 May 1948
    - Armies of Lebanon, Syria, Iraq and Egypt invaded; Transjordan intervened in areas allotted to the Arab state / Jerusalem zone
    - Two UN-brokered ceasefires
    - Armistice lines held until 1967; Egypt kept Gaza, Jordan the West Bank
    - The United States extended de facto recognition that night
    - fighting had begun after the UN partition vote of November 1947 and now became an interstate war
    - Egypt kept the Gaza Strip (places: gaza_strip; territory gaza_strip egyptian_administered)
    - the West Bank remained under Jordanian control (places: west_bank)
    - forces of Egypt, Transjordan, Syria, Iraq and Lebanon
    - Transjordan's Arab Legion operated mainly in areas allotted to the Arab state and in the Jerusalem zone
    - the last of the four armistices (Egypt, Lebanon, Transjordan, Syria)

**[S103]** Encyclopaedia Britannica, Arab-Israeli wars — https://www.britannica.com/event/Arab-Israeli-wars — archived: https://web.archive.org/web/20241231174330/https://www.britannica.com/event/Arab-Israeli-wars — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Forces of Egypt, Transjordan, Iraq, Syria and Lebanon entered on 15 May 1948
    - Armistice agreements February-July 1949; no peace treaties
    - Israel ended the war holding about 50% more territory than allotted by the partition plan
    - hours before the British Mandate ended (independent reference)
    - For Palestinian Arabs the period is remembered as the Nakba
    - the IDF drove Egyptian forces out of most of the Negev (places: negev)
    - Between late 1947 and 1949 large numbers of Palestinian Arabs fled or were expelled (the Nakba)
    - date 1948-05-15: the day after the declaration, Arab armies entered the former Mandate territory

**[S104]** RETIRED (no longer cited) — Benny Morris, 1948: A History of the First Arab-Israeli War, Yale University Press, 2008 — no URL

**[S105]** Benny Morris, The Birth of the Palestinian Refugee Problem Revisited, Cambridge University Press, 2004 — https://www.cambridge.org/core/books/birth-of-the-palestinian-refugee-problem-revisited/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - About 700,000 Palestinian Arabs left their homes and became refugees in 1947-49
    - Killings during Operation Hiram at Safsaf, Jish and elsewhere (pp. 473-474)

**[S106]** Walid Khalidi (ed.), All That Remains: The Palestinian Villages Occupied and Depopulated by Israel in 1948, Institute for Palestine Studies, 1992 — https://www.palestine-studies.org/ar/node/34551 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 418 Palestinian villages depopulated and destroyed in 1948 (Khalidi's criteria exclude towns and unbuilt sites)
    - Morris's earlier count was 369 localities; other compilations reach 531

**[S107]** United Nations General Assembly, Resolution 194 (III), 11 December 1948 (UNISPAL) — https://unispal.un.org/pdfs/5D56C86AA25FA732852568BF007860CC.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Paragraph 11: refugees wishing to return and live at peace should be permitted to do so at the earliest practicable date; compensation for those choosing not to return
    - Established the UN Conciliation Commission for Palestine
    - date 1948-12-11: UN General Assembly Resolution 194 (III)
    - Israel's position was that return could only be addressed in a peace settlement
    - the resolution remains central to Palestinian/Arab claims

**[S108]** RETIRED (no longer cited) — UN Conciliation Commission for Palestine, General Progress Report and Supplementary Report (A/1367/Rev.1), 23 October 1950; UN Economic Survey Mission Final Report, 1949; UNRWA Director's report 1950 — no URL

**[S109]** RETIRED (no longer cited) — en.wikipedia, List of estimates of the 1948 Palestinian expulsion and flight (used only as pointer to the estimates it cites: Israeli government estimate per E. Karsh 550,000-600,000; S. Abu-Sitta 935,000) — https://en.wikipedia.org/wiki/List_of_estimates_of_the_1948_Palestinian_expulsion_and_flight

**[S110]** Egyptian-Israeli General Armistice Agreement, 24 February 1949 (Avalon Project, Yale Law School) — https://avalon.law.yale.edu/20th_century/arm01.asp — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Signed at Rhodes 24 February 1949
    - date: signed 24 February 1949
    - signed at Rhodes (places: rhodes)
    - signed in the presence of the UN Acting Mediator
    - Gaza-Rafah armistice demarcation line (Gaza Strip on Egyptian side; places: negev)
    - the encircled Egyptian brigade at Faluja was evacuated
    - Egyptian forces at Faluja were encircled

**[S111]** Lebanese-Israeli General Armistice Agreement, 23 March 1949 (Avalon Project); UN cablegram S/1296 — https://avalon.law.yale.edu/20th_century/arm02.asp — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Signed at Ras en Naqura 23 March 1949; armistice line follows the Mandate-era international border
    - date: signed 23 March 1949
    - signed at Ras en Naqura (Rosh Hanikra) (places: south_lebanon)
    - the armistice line followed the Mandate-era international border
    - Israel withdrew from the villages it had taken in southern Lebanon (withdrawal of forces to the border line)

**[S112]** Jordanian-Israeli General Armistice Agreement, 3 April 1949 (Avalon Project) — https://avalon.law.yale.edu/20th_century/arm03.asp — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Signed at Rhodes 3 April 1949 in the presence of the UN Acting Mediator
    - date: signed 3 April 1949
    - signed at Rhodes
    - Jerusalem was divided along the existing cease-fire lines
    - the 'Little Triangle' of Arab villages (including Umm al-Fahm/Wadi Ara and Kafr Qasim area) passed to Israel
    - residents of the transferred villages kept their rights and became Israeli citizens
    - Iraq signed no armistice; its forces withdrew and Jordan took over their sector
    - Rhodes armistice: Jordanian forces replace Iraqi forces in their sector
    - Jordan accepts responsibility for the Iraqi forces
    - Armistice Art. VI: Jordanian forces to replace the Iraqi forces in the sector they held
    - Israel-Jordan armistice signed at Rhodes on 3 April 1949
    - Armistice Art. VI: Jordanian forces to replace Iraqi forces in the sector they held
    - Armistice Art. VI(3): handover of the Triangle/Wadi Ara strips to Israel
    - Israel-Jordan armistice Art. VI: Jordanian forces replace Iraqi forces in the Iraqi-held sector
    - Israel-Jordan armistice Art. VI: the line in the Iraqi sector (Jordanian forces replacing Iraqi forces) gave Israel the road between Tulkarem and Qalqiliya, with compensation to Jordan
    - Israel-Jordan armistice Art. V(c) fixes the Armistice Demarcation Line in the Hebron-Dead Sea sector
    - Armistice lines in the Jerusalem sector follow the 30 Nov 1948 cease-fire lines

**[S113]** UN Security Council document S/1353, Israeli-Syrian General Armistice Agreement, 20 July 1949 (UNISPAL) — https://www.un.org/unispal/document/auto-insert-177464 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Signed at Hill 232 near Mahanayim on 20 July 1949
    - Created demilitarized zones

**[S114]** Yehuda Lapidot, The Altalena Affair (June 20, 1948), Jewish Virtual Library — https://www.jewishvirtuallibrary.org/the-altalena-affair — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - First truce began 11 June 1948
    - c. 940 fighters aboard; sailed from Port-de-Bouc
    - Ben-Gurion agreed to Begin's request that 20% of the arms go to the Jerusalem Battalion; dispute over the rest
    - 16 Irgun fighters and 3 IDF soldiers killed (Kfar Vitkin and Tel Aviv beach)
    - Begin ordered no retaliation
    - Irgun members absorbed into the IDF in the following weeks
    - date 1948-06-20: Altalena arrived (at Kfar Vitkin) during the truce
    - carrying about 940 volunteers and a large arms cargo
    - Ben-Gurion had accepted Begin's request that 20% of the arms go to the Jerusalem Battalion; deadlock over the rest
    - the government ordered the IDF to take the ship
    - date 1948-06-22: shelled and burned off Tel Aviv
    - Sixteen Irgun fighters and three IDF soldiers were killed
    - the Irgun was disbanded into the IDF
    - choice (historical): Order the IDF to seize the ship and its arms by force
    - choice proposed: remaining arms to go to Irgun battalions (Begin's position)
    - choice proposed: allow only the agreed 20% for Jerusalem and keep negotiating
    - Ben-Gurion ordered the ship taken by force
    - Begin asked that the rest of the arms equip the Irgun battalions; the government rejected it

**[S115]** Israel Ministry of Defense Archives, The establishment of the IDF (exhibition: David Ben-Gurion and the IDF) — https://archives.mod.gov.il/sites/English/Exhibitions/David_Ben_Gurion_and_the_IDF/Pages/The-establishment-of-the-IDF.aspx — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel Defense Forces Ordinance No. 4 signed 26 May 1948; banned other armed forces
    - date 1948-05-26: Ben-Gurion signed the Israel Defense Forces Ordinance

**[S116]** RETIRED (no longer cited) — Benny Morris, 'Operation Dani and the Palestinian Exodus from Lydda and Ramle in 1948', Middle East Journal 40:1 (1986) — no URL

**[S117]** Institute for Palestine Studies, PalQuest: 'Lydda, 9-13 July 1948' — https://www.palquest.org/en/highlight/24073/lydda-9-13-july-1948 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - About 70,000 expelled from Lydda, Ramla and neighbouring villages
    - More than 400 killed in Lydda incl. 80-176 at the Dahmash mosque (IPS estimate)
    - Expulsion order issued under Operation Dani 12-13 July; hundreds died on the march toward Ramallah
    - dates 9-18 July 1948: the 'Ten Days' between the truces
    - Operation Dani captured Lydda, Ramle and the airfield
    - On 12-13 July the remaining inhabitants were expelled toward Arab Legion lines
    - Institute for Palestine Studies: about 70,000 including neighbouring villages
    - many died of thirst and exhaustion on the march
    - Palestinian sources put those killed in Lydda at more than 400, including at the Dahmash mosque
    - casualties effect: palestinians killed [400,400]
    - neutrality: Israeli military casualties at Lydda not listed
    - Operation Dani captured the area around Lydda in the 'Ten Days' from 9 July 1948
    - 12-13 July 1948 expulsion of Lydda and Ramla residents
    - date: assault on 11 July; Israeli forces entered the city that evening

**[S118]** Jewish Virtual Library, The Assassination of Count Bernadotte (September 17, 1948) — https://www.jewishvirtuallibrary.org/the-assassination-of-count-bernadotte — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - UN mediator Folke Bernadotte killed in Jerusalem by Lehi members, 17 September 1948
    - Lehi opposed his plan to modify the partition borders
    - date 1948-06-11: a UN-brokered truce took effect under mediator Folke Bernadotte
    - fighting resumed on 8 July 1948
    - date 1948-07-18: a second UN truce took effect
    - French observer Colonel André Sérot was also killed
    - killed by members of Lehi in Jerusalem
    - Lehi's motive included preventing internationalisation of Jerusalem

**[S119]** Jewish Virtual Library, Vital Statistics: Population of Israel (1948-present), from Israel CBS — https://www.jewishvirtuallibrary.org/population-of-israel-1948-present — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Population 806,000 (1948), 1,370,000 (1950), 1,578,000 (1951), 2,234,000 (1961), 2,657,000 (1966)
    - Israel's population was 806,000 in 1948
    - Population reached 1,578,000 at the end of 1951

**[S120]** Israel Democracy Institute, Elections and Parties: election results 1949, 1951, 1955, 1959, 1961, 1965 — https://en.idi.org.il/israeli-elections-and-parties/elections/1949/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Election dates 25.1.1949, 30.7.1951, 26.7.1955, 3.11.1959, 15.8.1961, 2.11.1965
    - Seats: Mapai 46 (1949), 45 (1951), 40 (1955), 47 (1959), 42 (1961); Alignment 45 and Gahal 26 (1965)
    - Turnout 87.0% (1949), 75.1% (1951), 82.8% (1955), 81.6% (1959, 1961), 83.0% (1965)
    - Pages for each year at /elections/<year>/
    - date: election held 25 January 1949
    - election was for a Constituent Assembly that renamed itself the Knesset
    - Mapai won 46 of 120 seats
    - turnout was 87%
    - Ben-Gurion formed a coalition government

**[S121]** RETIRED (no longer cited) — Jewish Virtual Library, UN General Assembly Resolution 273 (III), May 1949 — https://www.jewishvirtuallibrary.org/un-general-assembly-resolution-273-iii-may-1949

**[S122]** Jewish Virtual Library, Jordanian Annexation of the West Bank (April 1950) — https://www.jewishvirtuallibrary.org/jordanian-annexation-of-the-west-bank-april-1950 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Jordanian parliament approved annexation 24 April 1950
    - Only Britain and Pakistan recognised it
    - A joint session of Jordan's parliament approved the annexation, including East Jerusalem
    - West Bank residents had been given Jordanian citizenship

**[S123]** Bundeszentrale fuer politische Bildung (bpb), 'Vor 70 Jahren: Knesset erklaert Jerusalem zur Hauptstadt Israels', 2020 — https://www.bpb.de/kurz-knapp/hintergrund-aktuell/303456/vor-70-jahren-knesset-erklaert-jerusalem-zur-hauptstadt-israels/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Knesset proclaimed Jerusalem the capital on 23 January 1950
    - UNGA Res 303 (9 Dec 1949) had reaffirmed internationalisation; Ben-Gurion rejected it in the Knesset on 13 Dec 1949
    - date 1950-01-23: the Knesset declared Jerusalem the capital (place: Jerusalem)
    - The UN General Assembly reaffirmed internationalisation of Jerusalem on 9 December 1949
    - Most states did not recognise Jerusalem as capital
    - Most states kept their embassies in Tel Aviv
    - East Jerusalem remained under Jordan
    - Jordan held the Old City and East Jerusalem (places: jerusalem, east_jerusalem)
    - Ostteil (East Jerusalem) incl. Altstadt was Jordanian-controlled after the war

**[S124]** RETIRED (no longer cited) — Law of Return 5710-1950 (text), Jewish Virtual Library — https://jewishvirtuallibrary.org/jsource/Immigration/Text_of_Law_of_Return.html

**[S125]** RETIRED (no longer cited) — Absentees' Property Law 5710-1950 (text, UNISPAL) and Norwegian Refugee Council legal memo — https://www.un.org/unispal/?p=209845

**[S126]** Jewish Virtual Library, Ma'abarot — https://www.jewishvirtuallibrary.org/ma-abarot — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Ma'abarot were immigrant absorption camps in the 1950s
    - Declined from 1952; largely became development towns; last closed c. 1963
    - Ma'abarot were immigrant transit camps set up in the 1950s (event date 1950-05, end 1963)
    - Many ma'abarot became development towns
    - The last ma'abara closed around 1963

**[S127]** RETIRED (no longer cited) — Dvora Hacohen, Immigrants in Turmoil: Mass Immigration to Israel and Its Repercussions in the 1950s and After, Syracuse University Press, 2003 — no URL

**[S128]** RETIRED (no longer cited) — Alaska Airlines, 'Operation Magic Carpet' (company history page) — https://www.alaskaair.com/content/about-us/history/magic-carpet.aspx

**[S129]** Jewish Virtual Library, Operation Ezra & Nehemia - The Airlift of Iraqi Jews (1951-1952) — https://jewishvirtuallibrary.org/operation-ezra-and-nehemia-the-airlift-of-iraqi-jews — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Airlift of more than 120,000 (elsewhere 'some 130,000') Iraqi Jews 1951-1952
    - Emigrants had to liquidate property; $140 and 66 lb luggage limit
    - Communities in Iraq, Yemen, Libya left amid hostility and legal pressure
    - Emigration was conditioned on liquidating property
    - More than 120,000 (by some counts about 130,000) Iraqi Jews were flown to Israel (effects aliyah 120,000)
    - Mostly in 1951 and early 1952 (date 1951, date_end 1952-03-31)
    - About 6,000 Jews were left in Iraq
    - Emigrants could take $140 and 30 kg of luggage

**[S130]** Jewish Virtual Library, Holocaust Restitution: German Reparations — https://www.jewishvirtuallibrary.org/german-holocaust-reparations — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Sharett's March 1951 note claimed $1.5bn via the four Allied powers
    - Knesset debate early January 1952; resolution for direct negotiations passed 61-50 on 9 January
    - Begin/Herut opposed as 'blood money'; violent rally outside the Knesset
    - Agreement signed in Luxembourg 10 September 1952
    - West Germany offered to negotiate compensation before the debate
    - Choice 1 (historical): Ben-Gurion's government authorised direct negotiations, approved 61-50 on 9 January 1952
    - Choice 2 proposed at the time: refuse any direct dealings with Germany - position of Herut under Begin and others in the opposition who called the payments 'blood money'
    - Choice 3 proposed at the time: claims via the four Allied powers - Sharett's note of 12 March 1951 claimed $1.5 billion
    - Entered into force in March 1953
    - After the Knesset approved the resolution, delegations met at The Hague
    - Begin and Herut opposed the reparations as blood money

**[S131]** RETIRED (no longer cited) — National Library of Israel blog, 'The Reparations Agreement of 1952 and the response in Israel' — https://blog.nli.org.il/en/?p=95369

**[S132]** Jewish Virtual Library, Israeli Attack on Qibya (October 13, 1953) — https://www.jewishvirtuallibrary.org/qibya-october-1953 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Unit 101 under Ariel Sharon destroyed c. 45-50 homes, killing 69 villagers
    - Followed killing of a mother and two children at Yehud (Tirat Yehuda) by infiltrators
    - UNSC Resolution 101 (24 Nov 1953) censured the raid
    - Raid carried out by IDF Unit 101 under Ariel Sharon
    - 69 villagers killed
    - International condemnation (US State Department and others)

**[S133]** RETIRED (no longer cited) — Avi Shlaim, The Iron Wall: Israel and the Arab World, W. W. Norton, 2000 (updated 2014) — no URL

**[S134]** Jewish Virtual Library, The Lavon Affair — https://www.jewishvirtuallibrary.org/the-lavon-affair — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israeli military-intelligence cells in Egypt went into action 2 July 1954; network arrested
    - Two members hanged early 1955
    - 1960 commission found Lavon had not authorised the operation
    - Date: operation began 2 July 1954
    - Targets: post offices and US information libraries in Alexandria and Cairo
    - Two members were hanged in early 1955
    - Others died in custody or were imprisoned
    - Whether Lavon gave the order became a scandal that resurfaced in 1960-61
    - Israeli view: Israel did not want the British to leave the Canal Zone (Jewish Virtual Library account)
    - Operations meant to show Egypt's new rulers as unreliable custodians of the Suez Canal

**[S135]** Israel Ministry of Defense Archives, The 'Unfortunate Business' or the Lavon affair — https://archives.mod.gov.il/sites/English/Exhibitions/Pages/The-Lavon-affair.aspx — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Operation Susannah bombings in Egypt, 1954; dispute between Lavon and military-intelligence chief Gibli
    - An Israeli military-intelligence cell of Egyptian Jews
    - Target: a British-owned cinema
    - Aim: to keep British troops in the Canal Zone
    - The network was caught
    - Defence Minister Pinhas Lavon resigned in February 1955
    - MoD Archives: operations meant to sabotage Egypt's relations with Western states

**[S136]** Bank of Israel, About the Bank of Israel — https://boi.org.il/en/bank-of-israel/about-the-bank-of-israel/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Bank of Israel Law took effect and Bank established 1 December 1954
    - David Horowitz first governor 1954-1971
    - Bank of Israel Law passed 24 Aug 1954, effective 1 Dec 1954

**[S137]** RETIRED (no longer cited) — Jerusalem Post, report on declassified IDF archive documents on Kafr Qasim (article 713447); Hebrew University CRIS, 'Black flag at a crossroads: The Kafr Qasim political trial (1957-58)' — https://m.jpost.com/israel-news/article-713447

**[S138]** United Nations Peacekeeping, First United Nations Emergency Force (UNEF I) - Background — https://peacekeeping.un.org/mission/past/unef1backgr2.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel attacked Egypt 29 Oct 1956; Anglo-French ultimatum 30 Oct and bombing 31 Oct
    - GA resolutions 997-1002 (ES-I); UNEF created 5 Nov; ceasefire 7/8 Nov
    - Israeli withdrawal from Gaza 6-8 March 1957 and Sharm el-Sheikh 8-12 March 1957; UNEF posted to watch the Strait of Tiran
    - GA resolutions 1124 and 1125 (2 Feb 1957)
    - date 1956-10-29: Israel invaded Sinai on 29 October 1956
    - Britain and France issued an ultimatum
    - Britain and France attacked the Canal Zone (place: suez_canal)
    - ceasefire took effect on 7-8 November under UN General Assembly resolutions
    - General Assembly resolutions 1124 and 1125
    - date 1957-03-01: Israel announced on 1 March 1957 that it would withdraw (confirmed 4 March)
    - UNEF entered Gaza on 6-8 March (place: gaza_strip)
    - date_end 1957-03-12: UNEF took over Sharm el-Sheikh by 12 March (place: sharm_el_sheikh)
    - wording: UNEF 'guaranteeing' passage through the Straits of Tiran to Eilat until 1967 (places: straits_of_tiran, eilat)
    - choice 1 (historical): withdraw fully in exchange for UNEF at Sharm el-Sheikh and freedom of navigation; announced 1-4 March 1957 after GA resolutions 1124/1125
    - choice 2: keep holding Gaza and Sharm el-Sheikh was Israel's position Jan-Feb 1957 (withdrew from rest of Sinai but retained these two areas)
    - disputes over the DMZs fed clashes until 1967
    - Withdrawal dates from Gaza and Sharm el-Sheikh
    - UNEF detachment at Sharm el-Sheikh watched the Strait of Tiran
    - Stationing UNEF at Sharm el-Sheikh required Egyptian consent
    - GA resolution 1125 called for scrupulous observance of the armistice after full withdrawal
    - Israel withdrew from Gaza and Sharm el-Sheikh in March 1957
    - Israel held on to Gaza and Sharm el-Sheikh after 22 January 1957

**[S139]** Associated Press, 'Casualties of Mideast Wars', Los Angeles Times, 8 March 1991 — https://www.latimes.com/archives/la-xpm-1991-03-08-mn-2592-story.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel: 172 killed in the 1956 war (figure transcribed via en.wikipedia 'Suez Crisis', which cites this article)
    - Israeli dead 172 (AP)
    - Egyptian dead roughly 1,000 to 3,000
    - neutrality: casualties omit British and French dead

**[S140]** Derek Varble, The Suez Crisis 1956, Osprey, 2003; EBSCO Research Starters 'Battle of Sinai' — https://www.ebsco.com/research-starters/military-history-and-science/battle-sinai — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Egyptian killed estimated 1,650 (Varble) to 3,000; EBSCO gives c. 1,030 Egyptian and 189 Israeli killed
    - Israel took all of Sinai to Sharm el-Sheikh within days (places: sinai, sharm_el_sheikh)
    - Israeli dead 189 (EBSCO)

**[S141]** Jewish Virtual Library (Encyclopaedia Judaica), Kasztner, Rezso Rudolf — https://www.jewishvirtuallibrary.org/jsource/judaica/ejud_0002_0011_0_10816.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Libel trial verdict of Judge Halevi 22 June 1955
    - Kasztner shot March 1957, died days later
    - Supreme Court largely reversed the verdict 17 January 1958
    - Libel case brought by the state on behalf of government official Rudolf Kasztner
    - Verdict on 22 June 1955 by Judge Benjamin Halevi
    - Halevi found Kasztner had 'sold his soul to the devil'
    - The ruling shook Mapai/the government before the election
    - Kasztner was shot in March 1957 and died days later
    - In January 1958 the Supreme Court largely overturned the verdict

**[S142]** Moshe Naor, 'The Children of Wadi Salib and the 1959 Moroccan Jewish Protest in Haifa', International Journal of Middle East Studies, 2024 — https://www.cambridge.org/core/journals/international-journal-of-middle-east-studies/article/children-of-wadi-salib-and-the-1959-moroccan-jewish-protest-in-haifa/8BF94637194343BCD19E90866E9B7373 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Police shot and wounded Akiva Yaakov Elkrif on 8 July 1959, triggering protests led by the Union of North African Immigrants
    - Protests framed as having an ethnic character ('Revolt of the Moroccans')
    - date 1959-07-08: police shot and wounded Moroccan-born Akiva Elkrif in Wadi Salib
    - Wadi Salib a former Arab quarter of Haifa housing North African immigrants in poor conditions (place: haifa)
    - protests led by the Union of North African Immigrants
    - protests spread to other towns (place: beersheba)
    - brought discrimination against Mizrahi Jews into national politics

**[S143]** Israel State Archives, 'Behind the scenes at the Eichmann Trial' (special publication) — https://catalog.archives.gov.il/site/en/chapter/behind-scenes-eichmann-trial — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Eichmann seized in Buenos Aires 11 May 1960; Ben-Gurion announced capture to the Knesset 23 May 1960
    - Trial opened 11 April 1961 before a special District Court panel headed by Moshe Landau; prosecutor Gideon Hausner
    - Sentenced to death 15 December 1961; executed night of 31 May-1 June 1962
    - Mossad agents seized Eichmann and flew him secretly to Israel
    - Eichmann a principal organiser of the Holocaust
    - Ben-Gurion announced the capture to the Knesset on 23 May 1960 (place: jerusalem)
    - Argentina protested the violation of its sovereignty at the UN Security Council
    - date 1961-04-11: trial opened in Jerusalem before a special panel headed by Judge Moshe Landau (place: jerusalem)
    - Attorney-General Gideon Hausner prosecuting
    - sentenced to death on 15 December 1961
    - date_end 1962-06-01: hanged on the night of 31 May-1 June 1962

**[S144]** Jewish Virtual Library, Israel's Nuclear Arsenal: Background & Overview — https://www.jewishvirtuallibrary.org/background-and-overview-of-israel-s-nuclear-arsenal — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - France and Israel signed a revised agreement 3 Oct 1957 for a 24 MWt reactor at Dimona, built in secret
    - Reactor went critical in 1964
    - date 1957-10-03: Franco-Israeli agreement; France to build a 24-megawatt reactor
    - near Dimona, constructed in secret outside IAEA inspection (places: dimona, negev)
    - Ben-Gurion acknowledged the reactor publicly in December 1960, describing it as for peaceful purposes
    - the reactor went critical in 1964
    - Israel maintains a policy of nuclear ambiguity
    - US U-2 overflights captured construction of the Dimona facility in 1958

**[S145]** Foreign Relations of the United States 1961-1963, vol. XVII, doc. 5 (Rusk to Kennedy) — https://history.state.gov/historicaldocuments/frus1961-63v17/d5 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Ben-Gurion gave categoric assurances, with public statements, that Israel had no plans for nuclear weapons
    - Ben-Gurion gave the US assurances to that effect

**[S146]** RETIRED (no longer cited) — ISRAEL21c, 'Did you know Israel sent a rocket into space in 1961?' — https://www.israel21c.org/?p=96034

**[S147]** Jewish Virtual Library, Levi Eshkol — https://www.jewishvirtuallibrary.org/levi-eshkol — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Eshkol helped found Mekorot in 1937
    - Finance Minister 1952-1963; Prime Minister from June 1963
    - Died in office 26 Feb 1969
    - Levi Eshkol was Finance Minister
    - Eshkol was a founder of the Mekorot water company
    - Eshkol formed a government later that month (June 1963)

**[S148]** Israel's Economic Cooperation Foundation (ECF), 'Establishment of the PLO (1964)' document collection — https://ecf.org.il/issues/issue/98 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Palestinian conference in East Jerusalem 27-28 May 1964 proclaimed the PLO under Ahmad Shuqeiri, initiated by the Arab League
    - date: 28 May 1964
    - at the Arab League's initiative
    - a Palestinian congress in Jordanian-held East Jerusalem proclaimed the PLO
    - adopted a National Charter

**[S149]** Bundeszentrale fuer politische Bildung, 'Annaeherung im Schatten der Hallstein-Doktrin' (APuZ) — https://www.bpb.de/shop/zeitschriften/apuz/199902/annaeherung-im-schatten-der-hallstein-doktrin/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel and West Germany established diplomatic relations by exchange of notes 12 May 1965
    - Most Arab states broke relations with Bonn in response
    - date: diplomatic relations established May 1965
    - most Arab League states broke relations with Bonn in response

**[S150]** Jewish Telegraphic Agency archive, 'Israel to abolish military rule in areas inhabited by Arabs' (1966); ECF 'Abolition of the Military Governance of Arab-Populated Areas in Israel (1966)' — https://jta.org/archive/israel-to-abolish-military-rule-in-areas-inhabited-by-arabs — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Military government imposed since 1948 under the 1945 Defence (Emergency) Regulations; abolished effective 1 December 1966
    - Permit powers passed to the police; earlier abolition bills (1963) and a 1958 committee recommendation
    - date: abolished effective 1 December 1966
    - restricted movement and required permits
    - permit powers passed to the police
    - places: nazareth, umm_al_fahm, tayibe, sakhnin, kafr_qasim, galilee (areas under military government)
    - choice (non-historical): Keep the military government in place - policy until 1966
    - Military governorships of Arab-populated areas (JTA, 30 June 1966)
    - Israel announced (30 June 1966) it would abolish the military governorships in Arab-inhabited areas by 1 December 1966

**[S151]** UN Security Council Resolution 228 (1966), 25 November 1966 (UNISPAL) — https://www.un.org/unispal/?p=187180 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Censured Israel for the large-scale military action at Samu on 13 November 1966
    - Adopted 14-0 with New Zealand abstaining
    - date: 13 November 1966
    - large daytime raid
    - The Security Council censured Israel in Resolution 228

**[S152]** Nobel Prize Outreach, The Nobel Prize in Literature 1966 — https://www.nobelprize.org/prizes/literature/1966/summary/ — archived: https://web.archive.org/web/2024/https://www.nobelprize.org/prizes/literature/1966/summary/ — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Prize divided equally between Shmuel Yosef Agnon and Nelly Sachs
    - Shmuel Yosef Agnon shared the 1966 Nobel Prize in Literature with Nelly Sachs
    - 1966 prize divided equally between Agnon and Nelly Sachs

**[S153]** KKL-JNF, Rehabilitation of the Hula Valley — https://kkl-jnf.org/our_work/climate_action/water-for-israel/water_activity_hula_valley_rehabilitation/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - KKL-JNF began draining Lake Hula and its swamps in 1951
    - Later environmental damage led to partial re-flooding in the 1990s
    - Purpose: to create farmland
    - Drainage caused sinking soils and harm to Sea of Galilee water quality

**[S154]** Jewish Virtual Library, Hula Valley — https://www.jewishvirtuallibrary.org/hula-valley — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Drainage of Lake Hula in the 1950s
    - In 1948 there were 12 Jewish and 23 Arab settlements in the valley; Arab inhabitants left during the 1948 war
    - Work completed in 1957-58 (date_end 1958-12-31)
    - Purpose: to reduce malaria
    - The valley's Arab villages had been depopulated in 1948
    - Partial re-flooding in the 1990s

**[S155]** Israel Education (israeled.org), 'Operation Yachin begins bringing Jews from Morocco' (28 Nov 1961) — https://israeled.org/operation-yachin-begins-bringing-jews-from-morocco — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Operation Yachin began 28 Nov 1961; c. 97,000 Moroccan Jews left by spring 1964 (some settled in France, Canada, USA)
    - Other estimates 80,000-100,000; followed the Egoz sinking (44 dead) in 1961
    - date: operation began 28 November 1961
    - emigration from Morocco had been banned since 1959
    - arrangement with the Moroccan government
    - financed via HIAS payments
    - about 97,000 Jews left by spring 1964
    - most went to Israel, some to France, Canada or the US

**[S156]** Encyclopaedia Judaica via Jewish Virtual Library, Dimona — https://www.jewishvirtuallibrary.org/dimona — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - First residents moved in 1 August 1955; c. 300 people in 1955
    - date 1955-08-01: first residents moved to Dimona on 1 August 1955
    - Dimona was a new town for workers of the Dead Sea Works and nearby phosphate fields (place: dimona, negev)
    - Dimona settled mainly by immigrants from North Africa
    - places: dimona (destination of North African immigrants)
    - First Israelis moved to Dimona 1 August 1955
    - Dimona founded to house Sodom Dead Sea Works employees

**[S157]** Encyclopaedia Judaica via Jewish Virtual Library, Ashdod — https://www.jewishvirtuallibrary.org/ashdod — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Arab inhabitants left with Egyptian forces in Oct 1948
    - Modern city founded 1956; port opened 1965
    - date 1956: modern Ashdod founded in 1956 at the mouth of Nahal Lachish (place: ashdod)
    - Ashdod founded near the site of the Arab town of Isdud
    - Isdud's inhabitants had left with retreating Egyptian forces in 1948
    - Ashdod's port opened in 1965
    - places: Egyptian forces near Ashdod (Isdud) cut off; local Arab inhabitants left with them
    - Modern city founded 1956 at the mouth of Nahal Lachish; port opened 1965

**[S158]** Jewish Virtual Library, Beersheba — https://www.jewishvirtuallibrary.org/beersheba — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israeli forces took Beersheba on 21 October 1948; the town was abandoned by its inhabitants
    - Ben-Gurion joined Kibbutz Sde Boker in 1953
    - also called the Ten Plagues
    - Beersheba taken on 21 October 1948
    - its Arab inhabitants had left and the town was empty
    - Beersheba held by the Egyptians in the war; conquered 21 October 1948
    - after the declaration of independence the invading Egyptian army made Beersheba its headquarters

**[S159]** Encyclopaedia Judaica via Jewish Virtual Library, Eilat — https://www.jewishvirtuallibrary.org/eilat — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Um-Rashrash taken in Operation Uvda (EJ gives 13 March 1949)
    - Kibbutz ha-Me'uhad members set up a temporary camp in Dec 1949
    - some sources give 13 March
    - in December 1949 a group from the Kibbutz ha-Me'uhad movement set up a temporary camp there, nucleus of Eilat
    - civilian camp December 1949

**[S160]** Encyclopaedia Judaica via Jewish Virtual Library, Kiryat Shemonah — https://www.jewishvirtuallibrary.org/kiryat-shemonah — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Founded 1950 when a ma'abara became permanent, on the site of the Arab village of Khalisa
    - Municipal council 1953
    - camp was at the depopulated Arab village of al-Khalisa in the Hula Valley (places: kiryat_shmona, galilee)
    - Kiryat Shmona is in the Hula Valley
    - early settlers were Yemenite immigrants
    - named for Joseph Trumpeldor and seven others killed at Tel Hai in 1920
    - Encyclopaedia Judaica dates its foundation as a permanent town to 1950
    - received local-council status in 1953
    - founded 1950 when the ma'abara became permanent
    - Kiryat Shemonah on site of Khalisa village; founded 1950
    - Kiryat Shemonah on the site of the village of Khalisa, which stood until 1948
    - Declared a development town in 1953
    - Exposed to rocket fire from Lebanon and Syria after 1968 (EJ)

**[S161]** Jewish Virtual Library, Geography of Israel: Sderot — https://www.jewishvirtuallibrary.org/sderot — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Founded 1951 beside the Gevim-Dorot transit camp; first residents Kurdish and Persian Jews
    - Local council 1958
    - Sderot was established beside the Gevim-Dorot transit camp in the northwestern Negev
    - First housing Kurdish and Persian Jewish immigrants who lived in tents and shacks until 1954
    - Founded 1951 next to the Gevim-Dorot transit camp
    - Sderot founded 1951
    - Rocket fire from Gaza since 2001, many aimed at Sderot (JVL)

**[S162]** Encyclopaedia Judaica via Jewish Virtual Library, Ofakim — https://www.jewishvirtuallibrary.org/ofakim — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Founded 1955 as regional centre of the Merhavim development region
    - Ofakim founded the same year (1955) as the centre of the Merhavim development region (place: ofakim)
    - Ofakim settled mainly by immigrants from North Africa
    - Founded 1955 as regional centre
    - Ofakim founded 1955

**[S163]** Encyclopaedia Judaica via Jewish Virtual Library, Netivot — https://www.jewishvirtuallibrary.org/netivot — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Founded 1956; population 1,231 in 1957
    - Netivot founded in 1956 in the northwestern Negev (place: netivot)
    - Netivot settled mainly by immigrants from Tunisia and Morocco
    - Founded 1956
    - Netivot founded 1956 under regional settlement policy

**[S164]** Encyclopaedia Judaica via Jewish Virtual Library, Arad — https://www.jewishvirtuallibrary.org/arad — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Modern Arad founded 1961 in an area formerly used by Bedouin tribes
    - date 1961: Arad founded in 1961 in an area formerly used by Bedouin tribes (places: arad, negev)
    - Arad was a planned desert town in the eastern Negev
    - area formerly used by Bedouin tribes (places: arad, negev)
    - Arad founded 1961 in an area formerly inhabited by nomadic Bedouin tribes
    - Arad founded 1961

**[S165]** RETIRED (no longer cited) — Shimshon Livni, in Y. Gardus & A. Shmuel (eds.), The Land of the Negev, Ministry of Defense Publishing, 1994, p. 588 (Hebrew) — no URL

**[S166]** RETIRED (no longer cited) — Geremy Forman, 'Military Rule, Political Manipulation, and Jewish Settlement: Israeli Mechanisms for Controlling Nazareth in the 1950s', Journal of Israeli History, 2006, pp. 349-350 — no URL

**[S167]** RETIRED (no longer cited) — Jewish United Fund, Partnership 2000: Kiryat Gat — https://www.juf.org/p2g/kiryat_gat.aspx

**[S168]** RETIRED (no longer cited) — en.wikipedia articles 'Mitzpe Ramon', 'Karmiel', 'Beit Shemesh' (pointer only; underlying: National Library of Israel 'Ma'abarot' page for Beit Shemesh) — https://en.wikipedia.org/wiki/Mitzpe_Ramon

**[S169]** RETIRED (no longer cited) — Benny Morris, 'The Transfer of Al Majdal's Remaining Palestinians to Gaza, 1950', in 1948 and After: Israel and the Palestinians, Oxford University Press, 1990; Orna Cohen, 'Transferred to Gaza of Their Own Accord', Truman Institute — no URL

**[S170]** RETIRED (no longer cited) — Tom Segev, 1949: The First Israelis, Free Press, 1986 — no URL

**[S171]** Jewish Virtual Library, David Ben-Gurion; Moshe Sharett; Chaim Weizmann (biographies) — https://www.jewishvirtuallibrary.org/david-ben-gurion — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Ben-Gurion retired to Sde Boker late 1953 and returned after the 1955 elections (PM Nov 1955)
    - Sharett PM from January 1954
    - Ben-Gurion resigned 16 June 1963; founded Rafi June 1965
    - Weizmann served as president until his death on 9 November 1952
    - date: Ben-Gurion resigned on 16 June 1963
    - citing personal reasons
    - In 1965 Ben-Gurion split from Mapai to found Rafi
    - Ben-Gurion left the government at the end of 1953 (dated December 1953) and joined Kibbutz Sde Boker in the Negev
    - Move was a symbol of settling the desert

**[S172]** UN Relief and Works Agency (UNRWA) organisation profile, ReliefWeb — https://reliefweb.int/organization/unrwa — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - UNRWA established by UNGA resolution 302 (IV) of 8 December 1949; began operations 1 May 1950
    - Responded to c. 750,000 Palestine refugees in 1950
    - the refugees and their descendants became UNRWA's caseload (c. 750,000 in 1950)
    - effects note: UNRWA registered 957k in 1950
    - date: established by General Assembly Resolution 302 (IV) of 8 December 1949
    - began operations on 1 May 1950
    - serving about 750,000 refugees

**[S173]** RETIRED (no longer cited) — en.wikipedia, 'Operation Black Arrow' (pointer only; underlying: Shlaim 2000, Morris 'Israel's Border Wars' 1993) — https://en.wikipedia.org/wiki/Operation_Black_Arrow

**[S174]** RETIRED (no longer cited) — en.wikipedia 'Operation Hiram', 'Operation Horev', 'Operation Uvda', 'Operation Yoav' (pointer only; underlying Morris 2008, 2004) — https://en.wikipedia.org/wiki/Operation_Hiram

**[S175]** Israel Ministry of Defense Archives / Times of Israel / National Library of Israel coverage of the Altalena (see S114); World Jewish Congress 'This week in Jewish history: Altalena' — https://www.worldjewishcongress.org/en/news/this-week-in-jewish-history--altalena-affair-leaves-nearly-two-dozen-jewish-soldiers-dead — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Total Jewish dead given as nearly two dozen in some accounts
    - a single national army created from the Haganah (pre-state militias merged into the IDF)
    - sources disagree on the 20% allocation
    - Begin ordered his men not to retaliate

**[S176]** RETIRED (no longer cited) — Center for Online Judaic Studies, 'Operation Magic Carpet, 1949-1950' — https://cojs.org/operation-magic-carpet-1949-1950/

**[S177]** RETIRED (no longer cited) — en.wikipedia, '1966 attack on Samu' (pointer only; casualty figures from UN Secretary-General report S/7593) — https://en.wikipedia.org/wiki/1966_attack_on_Samu

**[S178]** RETIRED (no longer cited) — en.wikipedia, 'National Water Carrier of Israel' and 'War over Water (Jordan River)' (pointer only) — https://en.wikipedia.org/wiki/National_Water_Carrier_of_Israel

**[S200]** Jewish Virtual Library (AICE), 'The Six-Day War: Background & Overview', Jewish Virtual Library, n.d. — https://www.jewishvirtuallibrary.org/background-and-overview-six-day-war — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Egyptian troops moved into Sinai 15 May 1967; Nasser ordered UNEF withdrawal 18 May; Straits of Tiran closed to Israeli shipping 23 May 1967
    - Israeli cabinet voted 4 June 1967 to let the defence establishment decide timing; air strike (Operation Moked) 5 June 1967
    - Old City of Jerusalem entered 7 June 1967; ceasefire accepted 10 June 1967
    - Israeli cabinet secretly decided 19 June 1967 to offer Sinai and Golan in exchange for peace with Egypt and Syria
    - Israeli losses 777 dead and 2,586 wounded; Arab dead given as about 15,000 Egyptians, 2,500 Syrians and 800 Jordanians
    - Egypt moved troops into Sinai from 15 May 1967 (place: sinai)
    - Nasser ordered the UN Emergency Force out on 18 May
    - date 1967-05-23: Egypt closed the Straits of Tiran to Israeli shipping on 23 May (places: straits_of_tiran, eilat)
    - reservists were mobilised during the waiting period
    - on 4 June the cabinet authorised military action (historical choice note: cabinet authorised the defence establishment to decide timing on 4 June; air strike on 5 June)
    - other historians estimate 280,000-325,000 Palestinians displaced overall
    - date 1967-06-05 to 1967-06-10; Israel launched pre-emptive air strikes on Egypt on 5 June
    - Egyptian fatality estimates roughly 9,800-15,000
    - Syrian fatalities 1,000-2,500
    - Egyptian deaths estimated at 2,882-10,000
    - Rabin argued Israel could not afford to wait
    - Johnson tried to organise an international flotilla
    - JVL: about 325,000 Palestinians fled the West Bank
    - Egyptian dead and missing roughly 10,000-15,000 (upper: JVL)
    - Egyptian dead about 5,000

**[S201]** Jewish Virtual Library (AICE), 'Israel Defense Forces: Military Casualties in Arab-Israeli Wars' (compiled from Israel MFA, Government Press Office, IDF and other sources), n.d. — https://www.jewishvirtuallibrary.org/military-casualties-in-arab-israeli-wars — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Six-Day War losses: Israel 776; Egypt 11,500; Jordan 6,094; Syria 1,000; Iraq 2,000 (Arab figures are estimates and may include non-fatal casualties)
    - War of Attrition: Israeli losses 1,424
    - Yom Kippur War losses: Israel 2,688; Egypt 15,000; Syria 3,500; Iraq 125; Jordan 23
    - Israeli deaths given as 776-983
    - Jordanian fatalities about 700-800
    - neutrality: omits Iraqi military losses
    - Egyptian estimates from about 5,000 to 15,000
    - neutrality: omits other Arab states' losses (Iraq, Jordan, Saudi Arabia, Morocco)
    - Israel's losses in 1948-49: 6,373 (IDF/JVL military casualties table)
    - Jordanian losses about 800 (JVL overview) to 6,094 (JVL table)
    - Egypt 11,500 in JVL casualty table

**[S202]** RETIRED (no longer cited) — Gawrych, George W., The Albatross of Decisive Victory: War and Policy Between Egypt and Israel in the 1967 and 1973 Arab-Israeli Wars, Greenwood Press, 2000 [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — no URL

**[S203]** RETIRED (no longer cited) — Bowker, Robert, Palestinian Refugees: Mythology, Identity, and the Search for Peace, Lynne Rienner, 2003, p. 81 [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — no URL

**[S204]** RETIRED (no longer cited) — McDowall, David, Palestine and Israel: The Uprising and Beyond, I.B. Tauris / University of California Press, 1989, p. 84 [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — no URL

**[S205]** RETIRED (no longer cited) — Morris, Benny, Righteous Victims: A History of the Zionist-Arab Conflict, 1881-2001, Vintage Books, 2001 (orig. Knopf 1999) — https://archive.org/details/righteousvictims00morr_0

**[S206]** United Nations Security Council, Resolution 242 (1967), S/RES/242, adopted 22 November 1967 — https://peacemaker.un.org/sites/default/files/document/files/2024/05/scres24228196729.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Adopted unanimously 22 November 1967 at the 1382nd meeting
    - Emphasises inadmissibility of acquisition of territory by war; calls for withdrawal of Israel armed forces from territories occupied in the recent conflict and termination of all claims or states of belligerency
    - Calls for freedom of navigation and a just settlement of the refugee problem; English and French texts were read differently by the parties (UNISPAL record)
    - date 1967-11-22: Security Council unanimously adopted resolution 242
    - emphasising the inadmissibility of acquiring territory by war
    - calling for 'withdrawal of Israel armed forces from territories occupied in the recent conflict' with end to belligerency and right to live within secure and recognised boundaries (places: sinai, west_bank, gaza_strip, golan_heights)
    - freedom of navigation and a just settlement of the refugee problem

**[S207]** Arab League summit, 'The Khartoum Resolutions', 1 September 1967, The Avalon Project, Yale Law School — https://avalon.law.yale.edu/20th_century/khartoum.asp — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Dated 1 September 1967; paragraph 3: 'no peace with Israel, no recognition of Israel, no negotiations with it'
    - date 1967-09-01: Arab League summit in Khartoum resolved 'no peace with Israel, no recognition of Israel, no negotiations with it' (places: egypt, jordan, syria)
    - the summit pledged to work to remove the effects of the June war
    - wording completeness: summary omits the fourth principle in the same sentence

**[S208]** United Nations Security Council, Resolution 338 (1973), S/RES/338, adopted 22 October 1973 — https://peacemaker.un.org/sites/default/files/document/files/2024/05/scr33828197329.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Adopted 22 October 1973 by 14-0 (China not participating); ceasefire within 12 hours in positions then held
    - Calls for implementation of resolution 242 and for negotiations; Israel accepted immediately; resolution 339 followed on 23 October as fighting continued
    - date 1973-10-22: the Council called for a ceasefire within 12 hours in the positions then held
    - implementation of resolution 242 and negotiations between the parties

**[S209]** Jewish Virtual Library (AICE), 'The Yom Kippur War: Background & Overview', n.d. — https://www.jewishvirtuallibrary.org/background-and-overview-yom-kippur-war — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Egypt and Syria attacked 6 October 1973; ceasefire under resolution 338 on 22 October; war ended 25 October 1973
    - On the morning of 6 October Chief of Staff Elazar recommended full mobilisation and a pre-emptive air strike; Meir refused the strike and approved a reserve call-up
    - Israel lost 2,688 soldiers; about 7,700 Egyptian and 3,500 Syrian combat deaths
    - US airlift ordered 12 October; Agranat Commission chaired by Shimon Agranat blamed intelligence failures; Elazar resigned
    - date 1973-10-06: Egypt and Syria launched a coordinated surprise attack on Yom Kippur (places: sinai, suez_canal, golan_heights, syria, egypt)
    - Israel stopped the Syrian advance and counter-attacked toward Damascus
    - date_end 1973-10-25: fighting ended on 24-25 October after resolution 338
    - Israeli dead about 2,520-2,800
    - Syrian estimates from 3,000 to 3,500
    - choice (historical): Meir approved large-scale mobilisation but refused a pre-emptive strike so Israel would not be blamed and could count on US help
    - A partial call-up was approved; Meir refused pre-emptive action
    - Elazar recommended full mobilisation and a pre-emptive strike

**[S210]** Israel Democracy Institute, 'Elections for the Seventh Knesset (1969)', IDI Israeli Elections and Parties — https://en.idi.org.il/israeli-elections-and-parties/elections/1969/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Election 28 October 1969; Alignment 56 seats (46.2%), Gahal 26, NRP 12; national unity coalition continued
    - date 1969-10-28: election to the Seventh Knesset
    - the Alignment led by Golda Meir won 56 of 120 seats, the most any list had won
    - Gahal 26 seats and the National Religious Party 12
    - the national unity coalition continued

**[S211]** Israel Democracy Institute, 'Elections for the Eighth Knesset (1973)', IDI Israeli Elections and Parties — https://en.idi.org.il/israeli-elections-and-parties/elections/1973/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Election held 31 December 1973, delayed by the Yom Kippur War; Alignment 51, Likud 39, NRP 10
    - After the Agranat Commission interim report (April 1974) Meir, Dayan and the Chief of Staff resigned; Rabin formed a government in June 1974
    - date 1973-12-31: held on 31 December 1973 after being postponed by the war
    - Alignment 51 seats and the newly formed Likud 39
    - Meir formed a new coalition, which proved short-lived
    - Golda Meir and Defence Minister Dayan resigned following the Agranat interim report

**[S212]** Israel Democracy Institute, 'Elections for the Ninth Knesset (1977)', IDI Israeli Elections and Parties — https://en.idi.org.il/israeli-elections-and-parties/elections/1977/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Election 17 May 1977; turnout 79.2%; Likud 43 (33.4%), Alignment 32 (24.6%), Dash 15, NRP 12
    - First transfer of power to the right-wing bloc led by Menachem Begin; Dash joined about four months later (77 MKs)
    - date 1977-05-17: election of 17 May 1977
    - Likud won 43 seats, Alignment fell to 32, Democratic Movement for Change (Dash) 15
    - first transfer of power from the Labour movement

**[S213]** Israel Democracy Institute, 'Elections for the Tenth Knesset (1981)', IDI Israeli Elections and Parties — https://en.idi.org.il/israeli-elections-and-parties/elections/1981/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Election 30 June 1981; Likud 48 (37.1%), Alignment 47 (36.6%), NRP 6; turnout 78.5%
    - Begin formed a narrow 61-MK coalition of Likud, NRP, Tami and Agudat Yisrael
    - date 1981-06-30: Likud won 48 seats to the Alignment's 47
    - Begin formed a narrow 61-member coalition with the NRP, Tami and Agudat Yisrael

**[S214]** Israel Democracy Institute, 'Elections for the Eleventh Knesset (1984)', IDI Israeli Elections and Parties — https://en.idi.org.il/israeli-elections-and-parties/elections/1984/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Election 23 July 1984; Alignment 44, Likud 41, Tehiya 5; turnout 78.8%
    - Numerical deadlock produced a national unity government with rotation: Peres PM for two years, then Shamir; Rabin Defence Minister throughout
    - date 1984-07-23: the Alignment won 44 seats and Likud 41
    - neither bloc could form a government; a national unity government with rotating premiership (Peres two years, then Shamir), Rabin defence minister throughout
    - choices (narrow Alignment-led / narrow Likud-led coalition) were genuinely attempted options amid deadlock
    - the exchange closed for 18 days
    - the exchange closed for about two weeks

**[S215]** RETIRED (no longer cited) — Jewish Virtual Library (AICE), 'Israel Government Cabinet & Ministers' index and pages for the 17th, 19th, 21st and 22nd Governments — https://jewishvirtuallibrary.org/jsource/Politics/govtoc.html

**[S216]** RETIRED (no longer cited) — Prime Minister's Office (Israel), 'Past Governments', gov.il [content seen via search-result excerpt; page blocks automated fetching] — https://www.gov.il/apps/pmo/history/historyGovernmentsEn.html

**[S217]** 'Separation of Forces Agreement Between Israel and Syria', 31 May 1974, and UN Security Council Resolution 350 (31 May 1974), The Avalon Project, Yale Law School — https://avalon.law.yale.edu/subject_menus/mideast.asp — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel-Syria Separation of Forces Agreement dated 31 May 1974
    - UNSC resolution 350 of 31 May 1974 (establishing UNDOF)

**[S218]** 'The Camp David Accords', 17 September 1978, The Avalon Project, Yale Law School — https://avalon.law.yale.edu/20th_century/campdav.asp — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Camp David Accords dated 17 September 1978 (framework for peace in the Middle East and for an Egypt-Israel treaty)
    - date 1978-09-17: after 13 days of talks hosted by US President Carter, Begin and Sadat signed two frameworks on 17 September 1978 (places: camp_david, washington)
    - one framework for an Egypt-Israel peace treaty based on full Israeli withdrawal from Sinai (place: sinai)
    - one framework for Palestinian autonomy in the West Bank and Gaza
    - Framework: full Egyptian sovereignty and Israeli withdrawal from Sinai

**[S219]** 'Treaty of Peace Between the Arab Republic of Egypt and the State of Israel', 26 March 1979, The Avalon Project, Yale Law School — https://avalon.law.yale.edu/20th_century/isregypt.asp — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Signed 26 March 1979, witnessed by US President Carter
    - Interim withdrawal within nine months and full withdrawal behind the international boundary within three years of ratification
    - Normal relations, exchange of ambassadors and end of boycotts upon interim withdrawal
    - Free passage through the Suez Canal; Strait of Tiran and Gulf of Aqaba international waterways
    - Israel would withdraw from all of Sinai within three years
    - normal relations and an exchange of ambassadors would follow the interim withdrawal
    - Israeli shipping gained free passage through the Suez Canal and the Strait of Tiran
    - following the interim withdrawal in Sinai

**[S220]** RETIRED (no longer cited) — United Nations Security Council, Resolution 425 (1978), 19 March 1978 (Avalon Project text; UN Digital Library record) — https://digitallibrary.un.org/record/71622?ln=en

**[S221]** RETIRED (no longer cited) — United Nations Security Council, Resolution 487 (1981), 19 June 1981 (Avalon Project text) — https://avalon.law.yale.edu/20th_century/un487.asp

**[S222]** United Nations, UNISPAL records on Security Council Resolution 497 (1981) of 17 December 1981 — https://www.un.org/unispal/document/auto-insert-179120/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Adopted unanimously 17 December 1981; declared Israel's decision of 14 December 1981 to impose its laws, jurisdiction and administration in the occupied Syrian Golan 'null and void and without international legal effect'
    - Israel did not comply; a later enforcement draft failed in 1982 after a US veto

**[S223]** United Nations Security Council, Resolution 478 (1980), 20 August 1980, UNISPAL record — https://www.un.org/unispal/document/auto-insert-187506/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Adopted 20 August 1980 in response to Israel's 'basic law' on Jerusalem; censured the enactment, declared the measures null and void, called on states with diplomatic missions in Jerusalem to withdraw them

**[S224]** RETIRED (no longer cited) — UN General Assembly resolution 3379 (XXX) of 10 November 1975 and resolution 46/86 of 16 December 1991 (UN Digital Library record and World Jewish Congress summary) — https://digitallibrary.un.org/record/135193

**[S225]** Pedatzur, Reuven, 'The Jordanian option: the plan that refuses to die', Haaretz, 2007 (archived) — https://web.archive.org/web/20100918104416/http://www.haaretz.com/print-edition/features/the-jordanian-option-the-plan-that-refuses-to-die-1.226164 — archived: https://web.archive.org/web/20100918104416/http://www.haaretz.com/print-edition/features/the-jordanian-option-the-plan-that-refuses-to-die-1.226164 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Yigal Allon presented his plan on 27 July 1967; the initial version (Palestinian autonomy) was rejected by most ministers on 30 July 1967
    - The plan (annex Jordan Valley, East Jerusalem, Etzion bloc; return populated hill areas) was never officially endorsed but most ministers backed it as a basis of policy in 1968
    - date 1967-07-27: Allon put his plan before the cabinet on 27 July 1967
    - Israel would keep the Jordan Valley, East Jerusalem and the Etzion bloc (places: jericho, kfar_etzion, west_bank)
    - an initial version based on Palestinian autonomy was rejected by most ministers on 30 July 1967
    - in 1968 most ministers treated it as the basis of settlement policy
    - choice (non-historical): Allon's original version with Palestinian autonomy was genuinely proposed and rejected 30 July 1967
    - choice (non-historical): 'Jordanian option' proposed by Allon in early 1968
    - Alignment governments 1967-77 adopted the Jordanian option
    - Allon's map kept the Jordan Valley, Gush Etzion and Jerusalem
    - Allon's original plan proposed Palestinian autonomy
    - April 1968: most participants in the Alignment's diplomatic committee, except Dayan and Peres, backed the Allon plan as the basis of policy
    - Dayan and Peres dissented

**[S226]** RETIRED (no longer cited) — UN General Assembly resolution 2253 (ES-V), 4 July 1967, and Lustick, Ian S., 'Has Israel Annexed East Jerusalem?', Middle East Policy 5(1), 1997 [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — https://undocs.org/en/A/RES/2253(ES-V)

**[S227]** Knesset, 'Basic Law: Jerusalem, the Capital of Israel' (5740-1980), official English translation [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — https://www.knesset.gov.il/laws/special/eng/basic10_eng.htm — archived: https://web.archive.org/web/20090203034246/http://knesset.gov.il/laws/special/eng/basic10_eng.htm — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Passed 30 July 1980; 'Jerusalem, complete and united, is the capital of Israel'; seat of President, Knesset, Government and Supreme Court
    - date 1980-07-30: the Knesset passed a Basic Law declaring 'Jerusalem, complete and united' the capital of Israel (places: jerusalem, east_jerusalem)
    - Basic Law: Jerusalem, Capital of Israel (30 July 1980)

**[S228]** RETIRED (no longer cited) — Rabinovich, Abraham, The Boats of Cherbourg, Henry Holt, 1988; and 'Middle East: A Bitter Exchange', Time, 3 November 1967 [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — no URL

**[S229]** RETIRED (no longer cited) — Herzog, Chaim, The Arab-Israeli Wars, Random House 1982 (rev. ed. with Shlomo Gazit, Vintage 2005) — https://archive.org/details/arabisraeliwarsw0000herz

**[S230]** RETIRED (no longer cited) — Massad, Joseph A., Colonial Effects: The Making of National Identity in Jordan, Columbia University Press, 2001; and Jordan Armed Forces, 'Duty Martyrs' list [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — https://archive.org/details/colonialeffectsm00mass_429

**[S231]** Israel State Archives, 'The Terrorist Attack on Lod Airport: 40 Years After' (2012, archived) [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — https://web.archive.org/web/20141227112810/http://www.archives.gov.il/NR/exeres/A1B1717E-45BA-475D-9613-541C4B566C6E%2Cframeless.htm?NRMODE=Published — archived: https://web.archive.org/web/20141227112810/http://www.archives.gov.il/NR/exeres/A1B1717E-45BA-475D-9613-541C4B566C6E%2Cframeless.htm?NRMODE=Published — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 30 May 1972 attack at Lod Airport by three Japanese Red Army members acting for the PFLP: 26 killed (17 Puerto Rican pilgrims, 8 Israelis incl. Aharon Katzir, 1 Canadian), about 80 wounded; two attackers died, Kozo Okamoto captured
    - date 1972-05-30: three members of the Japanese Red Army, acting for the PFLP, opened fire in the arrivals hall at Lod Airport (places: lod, tel_aviv)
    - Israeli dead included biophysicist Aharon Katzir
    - about 80 wounded
    - two attackers died; Kozo Okamoto was captured
    - Israel State Archives: 24 killed and over 70 wounded at the scene

**[S232]** RETIRED (no longer cited) — Reeve, Simon, One Day in September: The Full Story of the 1972 Munich Olympics Massacre, Arcade Publishing, 2000 — no URL

**[S233]** RETIRED (no longer cited) — Bergman, Ronen, Rise and Kill First: The Secret History of Israel's Targeted Assassinations, Random House, 2018 — no URL

**[S234]** Jewish Virtual Library (AICE), 'Operation Spring of Youth (1973)' — https://www.jewishvirtuallibrary.org/operation-spring-of-youth-1973 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Raid in Beirut on 9 April 1973 killed three senior PLO leaders targeted; two IDF soldiers killed in the paratroop raid on a PFLP building
    - date 1973-04-09 to 1973-04-10: Israeli commandos landed in Beirut on the night of 9-10 April 1973 (places: beirut, lebanon)
    - and attacked other PLO targets
    - two Israeli soldiers were killed

**[S235]** RETIRED (no longer cited) — Lozowick, Yaacov, 'When Israel Shot Down a Libyan Passenger Plane, but Refused to Take Responsibility', Haaretz, 18 March 2023 (archived); Aviation Safety Network, 5A-DAH final report [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — https://asn.flightsafety.org/reports/1973/19730221_B722_5A-DAH.pdf

**[S236]** Israel Ministry of Defense Archives, 'The Agranat Commission Report' [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — https://archives.mod.gov.il/sites/English/docs/agranat/Pages/AgranatReport.aspx — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Agranat Commission established 21 November 1973; interim report 1 April 1974 recommended dismissal of intelligence chief Zeira and others and found Chief of Staff Elazar responsible; did not rule on Dayan
    - The Meir government's resignation followed nine days after the interim report
    - its interim report on 1 April 1974

**[S237]** Jewish Telegraphic Agency, 'Massacre of 18 in Kiryat Shemona Continues to Provoke Indignation', 18 April 1974 — https://www.jta.org/1974/04/18/archive/massacre-of-18-in-kiryat-shemona-continues-to-provoke-indignation — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Attack in Kiryat Shmona on Thursday 11 April 1974 killed 18 people, about half of them children; 15 injured
    - 18 people killed, about half of them children
    - neutrality: omits Israel's reprisal raid into southern Lebanon
    - Israel raided southern Lebanon the next day (Friday 12 April 1974) in reprisal

**[S238]** RETIRED (no longer cited) — Schmid, Alex P., Albert J. Jongman and Michael Stohl, Political Terrorism, Transaction / Routledge, 2005 (rev. ed.), p. 639 [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — no URL

**[S239]** Lustick, Ian S., For the Land and the Lord: Jewish Fundamentalism in Israel, Council on Foreign Relations, 1988 — http://www.sas.upenn.edu/penncip/lustick/lustick13.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Gush Emunim founded February 1974 by students of Rabbi Zvi Yehuda Kook
    - Garin Elon Moreh made eight attempts to settle at the old Sebastia railway station and was removed by the IDF seven times; a compromise placed about 25 families in the Kadum army camp (later Kedumim) (pp. 45-46)
    - date February 1974: students of Rabbi Zvi Yehuda Kook founded Gush Emunim ('Bloc of the Faithful')
    - to promote Jewish settlement throughout the West Bank, Gaza and Golan (place: west_bank)
    - it became the main organiser of settlement attempts in the following years
    - Garin Elon Moreh, linked to Gush Emunim, made eight attempts to settle near Nablus and was removed by the army seven times (places: nablus, west_bank)
    - date December 1975 (late 1975): the Rabin government agreed to let the settlers stay in the nearby Kadum army camp
    - choice notes: compromise (historical), continued forcible removal (army had evicted seven times), settlement at Sebastia itself (settlers' aim)
    - choice (non-historical): delay the withdrawal and renegotiate the Rafah salient — demanded by opponents of the withdrawal

**[S240]** Knesset, 'Interim Agreement between Israel and Egypt' (Sinai II), 4 September 1975, text; Meital, Yoram, Egypt's Struggle for Peace, University Press of Florida, 1997 [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — https://www.knesset.gov.il/process/docs/egypt_interim_eng.htm — archived: https://web.archive.org/web/20081007085616/http://www.knesset.gov.il/process/docs/egypt_interim_eng.htm — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Signed 4 September 1975 in Geneva; conflicts to be resolved by peaceful means; further Israeli withdrawal in Sinai and a new UN buffer zone
    - the agreement committed Israel and Egypt to resolve their conflict by peaceful means
    - deepened US involvement as mediator

**[S241]** RETIRED (no longer cited) — Khoury, Jack and Yoav Stern, Haaretz, 31 March 2008, and Israel State Judicial Authority, Or Commission report (Hebrew) [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — https://www.haaretz.com/2008-03-31/ty-article/top-israeli-arab-leader-well-fight-the-rising-fascism/0000017f-e2e7-df7c-a5ff-e2ff17050000

**[S242]** RETIRED (no longer cited) — David, Saul, Operation Thunderbolt: Flight 139 and the Raid on Entebbe Airport, Little, Brown / Back Bay, 2015-2017; and David, Saul, 'Israel's raid on Entebbe was almost a disaster', The Daily Telegraph, 27 June 2015 [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — https://www.telegraph.co.uk/news/worldnews/middleeast/israel/11701064/Israels-raid-on-Entebbe-was-almost-a-disaster.html

**[S243]** FIBA Europe, 1976-77 FIBA European Champions Cup results [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — http://www.fibaeurope.com/pageID_DzSpICIYIPoSLB9FW6ZQt0.compID_,Uz02qBnJiADOq5VntEf53.season_1977.html — archived: https://web.archive.org/web/20220710013141/http://www.fibaeurope.com/pageID_DzSpICIYIPoSLB9FW6ZQt0.compID_,Uz02qBnJiADOq5VntEf53.season_1977.html — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Maccabi Tel Aviv beat Mobilgirgi Varese 78-77 in the final in Belgrade on 7 April 1977, its first European title
    - the 1976-77 European Champions Cup final was played in Belgrade, with Maccabi (Tel Aviv) and Varese among the competing teams (place: tel_aviv)

**[S245]** RETIRED (no longer cited) — Begin, Menachem, statement to the press, 12 March 1978, Israel Ministry of Foreign Affairs, Israel's Foreign Relations: Selected Documents 1977-1979, doc. 133 [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — http://www.mfa.gov.il/MFA/Foreign%20Relations/Israels%20Foreign%20Relations%20since%201947/1977-1979/133%20Statement%20to%20the%20press%20by%20Prime%20Minister%20Begin

**[S246]** RETIRED (no longer cited) — Norton, Augustus Richard and Jillian Schwedler, '(In)security Zones in South Lebanon', Journal of Palestine Studies 23(1), 1993 — https://doi.org/10.1525/jps.1993.23.1.00p0030t

**[S247]** European Broadcasting Union, 'Paris 1978' scoreboard, eurovision.tv (archived)  [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — https://eurovision.tv/event/paris-1978/final — archived: https://web.archive.org/web/20230924033250/https://eurovision.tv/event/paris-1978/final — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Eurovision 1978, Paris, 22 April 1978: Israel won with 'A-Ba-Ni-Bi' by Izhar Cohen and the Alphabeta, 157 points
    - with 157 points

**[S248]** European Broadcasting Union, 'Jerusalem 1979' scoreboard, eurovision.tv (archived) [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — https://eurovision.tv/event/jerusalem-1979/final — archived: https://web.archive.org/web/20240203090756/https://eurovision.tv/event/jerusalem-1979/final — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Eurovision 1979 held in Jerusalem 31 March 1979; Israel won with 'Hallelujah' by Milk and Honey with Gali Atari, 125 points
    - scoring 125 points

**[S249]** Nobel Foundation, 'The Nobel Peace Prize 1978' [fetch blocked (HTTP 403); award corroborated by multiple secondary sources] — https://www.nobelprize.org/prizes/peace/1978/summary/ — archived: https://web.archive.org/web/20241231201444/https://www.nobelprize.org/prizes/peace/1978/summary/ — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - The 1978 Nobel Peace Prize was awarded jointly to Mohamed Anwar al-Sadat and Menachem Begin
    - the 1978 Nobel Peace Prize was awarded jointly to Begin and Sadat for the Camp David agreements (date October 1978)

**[S250]** RETIRED (no longer cited) — Bank of Israel, banknote and coin catalogue (Israeli currency history) [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — https://www.bankisrael.gov.il/catal/cataloge.htm

**[S251]** RETIRED (no longer cited) — Perlmutter, Amos, Michael Handel and Uri Bar-Joseph, Two Minutes over Baghdad, Frank Cass / Routledge, 2003 (2nd ed.) — no URL

**[S252]** Jewish Telegraphic Agency, 'Golan Druze Residents in a 3-day Strike to Protest Israel's Action', 17 December 1981 — https://www.jta.org/archive/golan-druze-residents-in-a-3-day-strike-to-protest-israels-action — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Knesset applied Israeli law, jurisdiction and administration to the Golan on Monday 14 December 1981
    - Most of the Golan's nearly 14,000 Druze residents began a three-day strike; about 7,000 Jews in 30 villages welcomed the move; Israeli ID cards available but not compulsory
    - most of the Golan's roughly 14,000 Druze residents struck in protest (place: majdal_shams)

**[S253]** RETIRED (no longer cited) — Gwertzman, Bernard, 'U.S. Suspends Strategic Pact and Arms Deal With Israel Over Annexation of Golan', The New York Times, 19 December 1981; Russell, George, 'Middle East: Begin's Brash Blitz', Time, 28 December 1981 [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — https://www.nytimes.com/1981/12/19/world/us-suspends-strategic-pact-and-arms-deal-with-israel-over-annexation-of-golan.html

**[S254]** Persin, Stephanie, 'The Yamit Evacuation', Jewish Virtual Library — http://www.jewishvirtuallibrary.org/jsource/Peace/yamit.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Yamit was the largest of 14 Sinai settlements (about 600 houses in 1982), built with government encouragement as a security buffer
    - Official evacuation began 23 April 1982; some protesters resisted; the army then demolished most buildings in the Sinai settlements
    - largest of 14 Sinai settlements (about 600 houses by 1982)
    - date 1982-04-23: under the peace treaty Israel evacuated its Sinai settlements; official evacuation of Yamit began on 23 April 1982 against resistance (places: yamit, sinai)
    - the army demolished most of the buildings
    - Evacuation date for Yamit set for 23 April 1982

**[S255]** RETIRED (no longer cited) — Schiff, Ze'ev and Ehud Ya'ari, Israel's Lebanon War, Simon & Schuster, 1984 — https://archive.org/details/israelslebanonwa0000schi/page/n6/mode/1up

**[S256]** RETIRED (no longer cited) — Gabriel, Richard A., Operation Peace for Galilee: The Israeli-PLO War in Lebanon, Hill & Wang, 1984; and 'The 1982 Israeli invasion of Lebanon: the casualties', Race & Class 24(4), 1983 [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — https://doi.org/10.1177/030639688302400404

**[S257]** Malone, Linda A., 'The Kahan Report, Ariel Sharon and the Sabra-Shatilla Massacres in Lebanon', Utah Law Review, 1985 — http://scholarship.law.wm.edu/cgi/viewcontent.cgi?article=1606&context=facpubs — archived: https://web.archive.org/web/20240315013035id_/http://scholarship.law.wm.edu/cgi/viewcontent.cgi?article=1606&context=facpubs — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Kahan Commission (report February 1983) found Israel indirectly responsible and Defence Minister Sharon personally responsible for disregarding the danger of bloodshed; recommended his removal; he left the defence post but stayed in cabinet
    - date 1982-09-14: killed by a bomb at Phalange headquarters
    - date 16-18 September 1982: Lebanese Phalangist militiamen, admitted by the IDF into Sabra and Shatila in Israeli-controlled West Beirut, killed civilians (places: beirut, lebanon)
    - victims were Palestinian and Lebanese Shia civilians
    - death-toll estimates range from 460 (Lebanese army prosecutor) and 700-800 (Israeli intelligence) to more than 2,000 (Palestinian Red Crescent) and 3,000-3,500 (Kapeliouk; al-Hout)
    - date 1983-02-08: Kahan Commission report
    - the commission headed by Supreme Court President Yitzhak Kahan found Israel indirectly responsible (place: jerusalem)
    - found Defence Minister Sharon personally responsible for disregarding the danger of bloodshed and recommended his removal
    - Sharon left the defence ministry but remained in the cabinet as minister without portfolio
    - victims were mainly Palestinians and Lebanese, also Iranians, Syrians, Pakistanis and Algerians; the Red Cross burial counted 328 bodies
    - estimates range from roughly 300 to 3,000
    - the IDF estimated 700-800 killed; other estimates about 1,000; one Israeli source 3,000
    - date: Malone dates the commission's conclusions 9 February 1983

**[S258]** RETIRED (no longer cited) — al-Hout, Bayan Nuwayhed, Sabra and Shatila: September 1982, Pluto Press, 2004 — no URL

**[S259]** RETIRED (no longer cited) — Kapeliouk, Amnon, Sabra et Chatila: enquête sur un massacre, Seuil, 1982 — no URL

**[S260]** Peace Now, 'Who We Are' [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — http://peacenow.org.il/eng/content/who-we-are — archived: https://web.archive.org/web/20120801115712/http://peacenow.org.il/eng/content/who-we-are — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Peace Now founded in 1978
    - Mass rally in Tel Aviv on 25 September 1982 demanding an inquiry into Sabra and Shatila; organisers' estimate about 400,000
    - Peace Now was founded in 1978 during the negotiations with Egypt to press for a peace agreement (places: tel_aviv, jerusalem)
    - became a leading Israeli movement advocating territorial compromise and a two-state solution

**[S261]** IDF, Conclusions of the supplementary investigation committee led by Brig. Gen. (res.) Amir Abulafia into the 1982 Tyre disaster, 3 July 2024; Israel MFA 'Highlights of Main Events 1982-1984'; Time, 14 November 1983 [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — https://idfanc.activetrail.biz/ANC03072024324322 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 11 November 1982 explosion destroyed the IDF headquarters in Tyre: 76 Israeli soldiers, Shin Bet agents and Border Police and 15 Lebanese detainees killed (2024 figures); Israel long attributed it to gas, the 2024 inquiry found a car bomb 'highly probable'
    - 4 November 1983 suicide truck bombing of the Shin Bet building in Tyre killed 28 Israelis and 32 Lebanese prisoners
    - date 1982-11-11: an explosion destroyed the Israeli military headquarters in Tyre, killing 76 Israeli soldiers, Shin Bet agents and Border Police and 15 Lebanese detainees (2024 figures) (place: south_lebanon)
    - Israel long attributed the blast to gas cylinders; a 2024 IDF inquiry found a car bomb 'highly probable'

**[S262]** RETIRED (no longer cited) — Blass, Asher A. and Richard S. Grossman, 'A Harmful Guarantee? The 1983 Israel Bank Shares Crisis Revisited', Bank of Israel Discussion Paper 96.03, 1996 [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — http://www.boi.gov.il/en/Research/DiscussionPapers1/dp9603e.pdf

**[S263]** RETIRED (no longer cited) — Sprinzak, Ehud, The Ascendance of Israel's Radical Right, Oxford University Press, 1991 — no URL

**[S264]** RETIRED (no longer cited) — Weitz, Gidi, 'Newly released papers reveal how Shin Bet tried to hide Bus 300 killings', Haaretz, 27 September 2011 (archived) [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — https://web.archive.org/web/20110928001255/http://www.haaretz.com/print-edition/news/newly-released-papers-reveal-how-shin-bet-tried-to-hide-bus-300-killings-1.386889

**[S265]** RETIRED (no longer cited) — Kaplan, Steven and Hagar Salamon, 'Ethiopian Jews in Israel: A Part of the People or Apart from the People?', in Rebhun & Waxman (eds.), Jews in Israel, Brandeis University Press, 2004; Israel Ministry of Aliyah and Integration, 'Operation Moses' [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — https://archive.org/details/jewsinisraelcont0000unse/page/

**[S266]** RETIRED (no longer cited) — Arens, Moshe, In Defense of Israel: A Memoir of a Political Life, Brookings Institution Press, 2018, pp. 118-119 [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — https://books.google.com/books?id=CmIMDgAAQBAJ&pg=PA119

**[S267]** RETIRED (no longer cited) — Bruno, Michael, Crisis, Stabilization, and Economic Reform: Therapy by Consensus, Oxford University Press, 1993 — no URL

**[S268]** RETIRED (no longer cited) — United Nations Security Council, Resolution 573 (1985), 4 October 1985 [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — https://undocs.org/en/S/RES/573(1985)

**[S269]** RETIRED (no longer cited) — Blitzer, Wolf, Territory of Lies: The Exclusive Story of Jonathan Jay Pollard, Harper & Row, 1989 — no URL

**[S270]** RETIRED (no longer cited) — The Sunday Times (London), 'Revealed: the secrets of Israel's nuclear arsenal', 5 October 1986; Cohen, Avner, Israel and the Bomb, Columbia University Press, 1998 — no URL

**[S271]** Deurenberg, Rudolph, 'The Lavi', Jewish Virtual Library; Friedman, Thomas, 'Israelis Decide Not to Construct Lavi Jet Fighter', The New York Times, 31 August 1987 [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — http://www.jewishvirtuallibrary.org/jsource/Society_&_Culture/lavi.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Lavi fighter programme launched 1980 by Israel Aircraft Industries with US funding
    - First prototype flew on 31 December 1986
    - Cabinet cancelled the programme 30 August 1987 by 12-11 with one abstention
    - the Lavi, developed by Israel Aircraft Industries from 1980
    - date 1986-12-31: the first prototype flew on 31 December 1986 (place: lod)
    - with US funding

**[S272]** RETIRED (no longer cited) — International Paralympic Committee, 'Tel Aviv 1968 Paralympic Games' and Summer Paralympic Games overview [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — https://www.paralympic.org/paralympic-games/summer-overview

**[S273]** Frankel, Oz, 'What's in a name? The Black Panthers in Israel', The Sixties 1(1), 2008; Center for Israel Education, 'Israeli Black Panthers Meet with Prime Minister Meir' — https://israeled.org/israeli-black-panthers/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israeli Black Panthers founded early 1971 in Musrara, Jerusalem, by young Mizrahi (mostly Moroccan-origin) Jews protesting discrimination and poverty
    - Golda Meir met representatives on 13 April 1971 and later called them 'not nice'; 'Night of the Panthers' demonstration 18 May 1971 drew about 5,000-7,000 and ended in clashes and over 100 arrests
    - A public committee acknowledged ethnic and socioeconomic gaps; welfare spending rose before the 1973 war shifted priorities
    - Prime Minister Meir met them in April 1971
    - after meeting them in April, Meir called them 'not nice'
    - date 1971-05-18: 'Night of the Panthers' rally drew 5,000-7,000 people and ended in clashes
    - after the May 1971 clashes Meir called the Panthers 'not nice'

**[S274]** RETIRED (no longer cited) — Jewish Telegraphic Agency, 'All Crew Members of Submarine Dakar Officially Declared Dead', 2 March 1981; Jourdan, David W., Never Forgotten: The Search for and Discovery of Israel's Lost Submarine Dakar, Naval Institute Press, 2009 [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — https://www.jta.org/1981/03/02/archive/all-crew-members-of-submarine-dakar-officially-declared-dead-chief-rabbi-says-wives-of-crew-members

**[S275]** Jewish Virtual Library, 'Operation Gift'; UN Security Council Resolution 262 (31 December 1968); JTA on the French arms embargo [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — https://www.jewishvirtuallibrary.org/operation-gift — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 28 December 1968 Israeli commando raid on Beirut airport after the PFLP attack on an El Al plane in Athens; 13-14 civilian aircraft destroyed, no casualties reported
    - Security Council resolution 262 condemned the raid; France imposed an arms embargo
    - after a PFLP attack on an El Al airliner in Athens
    - date 1968-12-28: Israeli commandos raided Beirut International Airport (places: beirut, lebanon)
    - destroyed 13-14 Lebanese civilian aircraft
    - no casualties were reported

**[S276]** Jewish Virtual Library, 'Total Immigration to Israel by Year' (source: Israel Central Bureau of Statistics) — https://www.jewishvirtuallibrary.org/total-immigration-to-israel-by-year — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Immigrants to Israel: 1967 14,469; 1968 20,703; 1969 38,111; 1970 36,750; 1971 41,930; 1972 55,888; 1973 54,886; 1974 31,979; 1975 20,028; 1976 19,754; 1977 21,429; 1978 26,394; 1979 37,222; 1980 20,428; 1981 12,599; 1982 13,723; 1983 16,906; 1984 19,981; 1985 10,642; 1986 9,505
    - total immigration to Israel from all countries peaked at 55,888 in 1972

**[S277]** RETIRED (no longer cited) — Tolts, Mark, 'Post-Soviet Aliyah and Jewish Demographic Transformation', 15th World Congress of Jewish Studies, 2009; Lazin, Fred, 'Refugee Resettlement and Freedom of Choice: The Case of Soviet Jewry', Center for Immigration Studies, 2005 [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — https://www.bjpa.org/search-results/publication/11924

**[S278]** Office of the United States Trade Representative, 'Israel Free Trade Agreement' — https://ustr.gov/trade-agreements/free-trade-agreements/israel-fta — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - US-Israel Free Trade Agreement signed 22 April 1985, the first US free trade agreement; all eligible Israeli products duty-free from 1 January 1995
    - Israel and the United States signed the first US free-trade agreement (place: washington)

**[S279]** RETIRED (no longer cited) — Gorenberg, Gershom, The Accidental Empire: Israel and the Birth of the Settlements, 1967-1977, Times Books, 2006 — https://books.google.com/books?id=ZpYvMW4PYuMC

**[S280]** Berger, Yotam, 'Secret 1970 Document Confirms First West Bank Settlements Built on a Lie', Haaretz, 28 July 2016; Feige, Michael, Settling in the Hearts, Wayne State UP, 2009 [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — https://www.haaretz.com/israel-news/2016-07-28/ty-article/.premium/document-confirms-first-settlements-built-on-a-lie/0000017f-ea04-da9b-a1ff-ee6ff9080000 — archived: https://web.archive.org/web/20240928133343/https://www.haaretz.com/israel-news/2016-07-28/ty-article/.premium/document-confirms-first-settlements-built-on-a-lie/0000017f-ea04-da9b-a1ff-ee6ff9080000 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Kiryat Arba established 1968-1971 on land requisitioned 'for military purposes' (minutes of a July 1970 meeting in Defence Minister Dayan's office); local council 1979
    - on land requisitioned 'for military purposes', according to minutes of a July 1970 meeting in Defence Minister Dayan's office
    - land expropriated for ostensibly military purposes, per minutes of a 1970 meeting in Defence Minister Dayan's office

**[S281]** RETIRED (no longer cited) — McCarthy, Rory, 'West Bank settlements', The Guardian, 24 August 2009; Ma'ale Adumim municipal history [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — https://www.theguardian.com/world/2009/aug/24/west-bank-settlements-israel

**[S282]** RETIRED (no longer cited) — B'Tselem, 'Facts on the Settlement of Ariel', 30 August 2010 [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — https://www.btselem.org/settlements/20100830_facts_on_the_settlement_of_ariel

**[S283]** RETIRED (no longer cited) — Haaretz, 'The Golan Heights come down to earth', 20 September 2013 [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — https://www.haaretz.com/2013-09-20/ty-article/.premium/the-golan-heights-come-down-to-earth/0000017f-e84c-dc7e-adff-f8ed03380000

**[S284]** BBC News, 'Settlements seen across the divide', 20 June 2005; CNN, 'Largest Gaza settlement evacuated, Israel says', 18 August 2005 [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — http://www.cnn.com/2005/WORLD/meast/08/18/gaza.pullout/index.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Neve Dekalim, founded 1983, became the largest Israeli settlement in the Gaza Strip; evacuated 15-18 August 2005
    - in the Gush Katif bloc of the southern Gaza Strip; became the largest Israeli settlement there until the 2005 disengagement (places: neve_dekalim, gaza_strip, khan_yunis)

**[S285]** RETIRED (no longer cited) — Parsi, Trita, Treacherous Alliance: The Secret Dealings of Israel, Iran, and the United States, Yale University Press, 2007 — no URL

**[S286]** RETIRED (no longer cited) — Lorch, Netanel, 'The Arab-Israeli Wars', Israel Ministry of Foreign Affairs, 2003; Schiff, Zeev, A History of the Israeli Army, Straight Arrow, 1974 [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — http://www.mfa.gov.il/MFA/History/Modern+History/Centenary+of+Zionism/The+Arab-Israeli+Wars.htm

**[S287]** RETIRED (no longer cited) — UN Security Council letter from the Permanent Representative of Lebanon, S/10911, 11 April 1973 [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — https://web.archive.org/web/20151209182449/http://dag.un.org/bitstream/handle/11176/73004/S_10911-EN.pdf?sequence=2&isAllowed=y

**[S288]** RETIRED (no longer cited) — United States Department of State, Foreign Relations of the United States 1964-1968, Vol. XX, documents on Allon Plan and Israeli positions — https://history.state.gov/historicaldocuments/frus1964-68v20/d353

**[S289]** RETIRED (no longer cited) — Oren, Michael B., Six Days of War: June 1967 and the Making of the Modern Middle East, Oxford University Press, 2002 — no URL

**[S290]** RETIRED (no longer cited) — Claiborne, William, 'General Strike by Druze Paralyzes Golan', The Washington Post, 22 February 1982 [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — https://www.washingtonpost.com/archive/politics/1982/02/22/general-strike-by-druze-paralyzes-golan/d634d1d8-1168-4779-a380-01c75271fe69/

**[S291]** RETIRED (no longer cited) — Pollack, Kenneth M., Arabs at War: Military Effectiveness, 1948-1991, University of Nebraska Press, 2002 [Located via the Wikipedia article on the topic, which cites it; not opened directly.] — no URL

**[S300]** RETIRED (no longer cited) — B'Tselem, 'Palestinians killed in the Occupied Territories (including East Jerusalem)' / First Intifada fatality tables, B'Tselem – The Israeli Information Center for Human Rights in the Occupied Territories, n.d. — https://www.btselem.org/node/206391

**[S301]** RETIRED (no longer cited) — Nasrallah, Rami, 'The First and Second Palestinian Intifadas', in Newman, D. & Peters, J. (eds.), Routledge Handbook on the Israeli–Palestinian Conflict, Routledge, 2013, p. 61 — https://books.google.com/books?id=kftqQdNNDWAC&pg=PA61

**[S302]** RETIRED (no longer cited) — Encyclopaedia Britannica, 'Hamas' (summary) and 'intifada' — https://www.britannica.com/summary/Hamas

**[S303]** Introvigne, Massimo, 'The Origins of Hamas 4: 1987, Hamas Is Founded', Bitter Winter, 2023 — https://bitterwinter.org/the-origins-of-hamas-4-1987-hamas-is-founded/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Hamas literature dates its founding to 8 December 1987; Introvigne argues the founding meeting was 9 December 1987
    - Founded in Gaza (places gaza_strip, gaza_city)
    - Hamas literature dates its founding to 8 December 1987
    - Some historians place the founding meeting on 9 December (event date 1987-12-09)

**[S304]** Friedman, Thomas L., 'Israelis Decide Not to Construct Lavi Jet Fighter', The New York Times, 31 August 1987 — https://www.nytimes.com/1987/08/31/world/israelis-decide-not-to-construct-lavi-jet-fighter.html — archived: https://web.archive.org/web/20241203020405/https://www.nytimes.com/1987/08/31/world/israelis-decide-not-to-construct-lavi-jet-fighter.html — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israeli cabinet decided on 30 August 1987 not to build the Lavi fighter
    - Cabinet vote 12–11 with one abstention (per Haglund, The Defence Industrial Base and the West, Routledge 1989, p. 213, as cited alongside)
    - Note: URL and vote attribution taken from Wikipedia 'IAI Lavi' references
    - Date: cabinet voted on 30 August 1987 (NYT of 31 Aug reports vote 'today', dateline 30 Aug)
    - Vote was 12 to 11
    - With one abstention
    - Decision taken by Israel's national-unity cabinet
    - The Lavi was then in flight testing (prototypes flying)
    - IAI (Israel Aircraft Industries) was the developer
    - Cost was the main argument against continuing
    - Choice 'Cancel the Lavi and buy more F-16s' was the adopted (historical) option
    - Choice 'Continue building the Lavi' was genuinely proposed, led in cabinet by Moshe Arens
    - Cabinet adopted Peres's plan to scrap the Lavi 12-11
    - Finance Minister Nissim backed halting the Lavi
    - Most Likud ministers led by Shamir voted to continue the Lavi
    - Arens was the staunchest advocate of the Lavi

**[S305]** Ahram Online / AFP, 'Israel admits 1988 murder of PLO number-two Abu Jihad', 1 Nov 2012 — https://english.ahram.org.eg/News/56915.aspx — archived: https://web.archive.org/web/20130718042427/http://english.ahram.org.eg/News/56915.aspx — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Khalil al-Wazir (Abu Jihad) killed at his home in Tunis on 16 April 1988 by Israeli commandos
    - Israel did not acknowledge the killing until a 2012 Yedioth Ahronoth report (Mossad-planned, Sayeret Matkal-executed)
    - Date: killed 16 April 1988
    - Place: Tunis
    - Khalil al-Wazir (Abu Jihad) was deputy to PLO chairman Yasser Arafat
    - A senior organiser of the intifada
    - Shot dead at his home by Israeli commandos
    - Israel did not acknowledge it until a 2012 Israeli press report describing it as Mossad-planned and carried out by Sayeret Matkal
    - Neutrality: other people killed in the raid are not mentioned

**[S306]** RETIRED (no longer cited) — United Nations (UNISPAL), 'Address to the Nation by His Majesty King Hussein' (Jordan's disengagement from the West Bank), 31 July 1988 — https://www.un.org/unispal/?p=202739

**[S307]** Jewish Virtual Library, 'Israel Science & Technology: Space Research & Development' — https://www.jewishvirtuallibrary.org/israeli-space-research-and-development — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel launched its first satellite, Ofek-1, on 19 September 1988 on an Israeli-built Shavit launcher
    - Date: 19 September 1988
    - Ofek-1 was Israel's first satellite
    - Launched aboard the Israeli-built Shavit launcher

**[S308]** Israel Democracy Institute, 'Elections 1988' (12th Knesset) — https://en.idi.org.il/israeli-elections-and-parties/elections/1988/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Election held 1 November 1988; Likud 40 seats, Alignment 39
    - Shamir formed a national unity government with Peres without rotation; it collapsed in March 1990; in June 1990 Shamir formed a narrow right-wing/religious government
    - Date: election to the 12th Knesset on 1 November 1988
    - Likud won 40 seats and the Alignment 39
    - 65-seat right-wing and religious bloc
    - Coalition talks foundered on religious-legislation demands
    - Shamir formed another national-unity government with Peres, without rotation of the premiership
    - The Shamir-Peres unity government formed after 1988 collapsed in March 1990
    - In June 1990 Shamir formed a narrow government of right-wing and religious parties

**[S309]** United Nations (UNISPAL), 'Declaration of Independence' (Palestine National Council, Algiers, 15 November 1988), UN translation — https://www.un.org/unispal/document/auto-insert-178680/ — archived: https://web.archive.org/web/20241220033106/https://www.un.org/unispal/document/auto-insert-178680/ — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Palestinian National Council proclaimed a State of Palestine in Algiers on 15 November 1988; text drafted by Mahmoud Darwish and read by Yasser Arafat
    - Note: URL taken from Wikipedia 'Palestinian Declaration of Independence' references
    - Date: 15 November 1988
    - At its 19th session in Algiers (place abroad)
    - The Palestine National Council proclaimed a State of Palestine

**[S310]** Tolts, Mark, 'A Half Century of Jewish Emigration from the Former Soviet Union: Demographic Aspects', Davis Center, Harvard University, 2019 — https://daviscenter.fas.harvard.edu/sites/default/files/files/2021-04/Tolts%20M.%20A%20Half%20Century%20of%20Jewish%20Emigration%20from%20the%20Former%20Soviet%20Union%20-%20Harvard4%20_0.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 1990: about 205,000 Jews and relatives left the (F)SU, 185,200 of them to Israel
    - Annual FSU arrivals in Israel 1989–2006 (12.9k in 1989; 147.8k in 1991; ~979k total 1989–2006, as tabulated from Tolts/Demoscope in the Wikipedia article on the 1990s post-Soviet aliyah)
    - Date/start: mass immigration from the USSR began in 1989
    - About 185,000 immigrants from the USSR arrived in 1990 alone (Tolts)
    - Roughly 980,000 between 1989 and 2006 (Tolts)
    - about 149,000 Soviet Jews and relatives came to Israel 1970-1979 (Tolts Table 1, thousands: 1970 1.0, 1971 13.0, 1972 31.4, 1973 33.3, 1974 16.7, 1975 8.3, 1976 7.3, 1977 8.3, 1978 12.0, 1979 17.3)
    - Tolts Table 1 rows 1971-1974 (Israel, thousands)
    - Tolts Table 1 rows 1975-1979 (Israel, thousands)
    - by 1979 only one-third arrived in Israel

**[S311]** Israel Central Bureau of Statistics, 'Immigration to Israel' (Publication 1365), CBS, 2009 — https://www.cbs.gov.il/he/publications/DocLib/2009/1365/pdf/e_print.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 906,500 immigrants arrived 1990–2001, about 86% from the former USSR
    - Close to 200,000 immigrants in 1990 and over 175,000 in 1991
    - Immigrants 1948–2006 totalled 3,012,288, of whom 1,182,804 (39.3%) were born in the former USSR
    - Note: text seen via search-result extracts; cbs.gov.il resets automated connections
    - CBS: 906,500 immigrants of all origins in 1990-2001, 86% from the former USSR
    - After Soviet emigration restrictions were lifted

**[S312]** Center for Israel Education, 'Iraqi Scuds Strike Israel' — https://israeled.org/iraqi-scuds-strike-israel — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Iraq fired 39 Scud missiles at Israel in January–February 1991 hoping to draw Israel into the war
    - Israel held its fire at US request; the US rushed Patriot batteries to Israel
    - Place: iraq (missiles fired from Iraq)
    - Aim was to draw Israel into the war and split the US-led coalition
    - At US request Israel did not retaliate; US deployed Patriot batteries in Israel
    - Choice 'Launch a retaliatory air operation in western Iraq' was genuinely pressed for at the time
    - Shamir-led cabinet did not strike back
    - US sent Patriot batteries

**[S313]** National Jewish Outreach Program (NJOP), 'The Scud War' — https://njop.org/the-scud-war/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 39 Scuds fell on Israel in 19 attacks; first attack 18 January 1991 on Tel Aviv and Haifa; ground war began 24 Feb, victory declared 28 Feb
    - Direct casualties were 'in the single digits'; Israel's security cabinet reserved the right to retaliate but kept the air force grounded to avoid fracturing the coalition
    - Date: first Scud attack 18 January 1991
    - In 19 attacks, between 18 January and late February 1991
    - Residents sheltered in sealed rooms with gas masks
    - Choice 'Hold fire at US request' was Shamir's decision, to avoid fracturing the coalition which included Arab states

**[S314]** American Jewish Joint Distribution Committee (JDC), 'Operation Solomon' — https://www.JDC.org/operation-solomon/ — archived: https://web.archive.org/web/20250104055836/https://www.jdc.org/operation-solomon/ — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Operation Solomon airlifted just over 14,000 Ethiopian Jews to Israel on 24–25 May 1991 in about 36 hours as rebel forces neared Addis Ababa
    - Other accounts (Israel Forever Foundation, eJewishPhilanthropy) give 14,325 people
    - As rebel forces closed in on Addis Ababa
    - JDC: just over 14,000 Ethiopian Jews airlifted
    - Places: abroad (Addis Ababa) and jerusalem (destination Israel)
    - Operation planned in secret

**[S315]** Jewish Virtual Library, 'The Madrid Conference: Overview' — https://www.jewishvirtuallibrary.org/the-madrid-conference-overview — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Madrid Conference 30 October – 4 November 1991, co-sponsored by the US and USSR; Israel, Syria, Lebanon, Egypt and a joint Jordanian-Palestinian delegation attended
    - Bilateral Washington talks were deadlocked by 1993, leading to the Oslo channel and the Israel–Jordan treaty
    - Dates: 30 October - 4 November 1991

**[S316]** RETIRED (no longer cited) — Knesset, 'Basic Law: Human Dignity and Liberty' (English text) and 'Basic Laws of the State of Israel' — https://www.knesset.gov.il/laws/special/eng/basic3_eng.htm

**[S317]** Supreme Court of Israel, CA 6821/93 United Mizrahi Bank v. Migdal Cooperative Village, 49(4) P.D. 221 (9 Nov 1995), English translation, Versa – Cardozo Law School — https://versa.cardozo.yu.edu/opinions/united-mizrahi-bank-v-migdal-cooperative-village — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Decided 9 November 1995; the Court held the 1992 Basic Laws have constitutional status and that the courts may set aside conflicting ordinary legislation (judicial review) – the 'constitutional revolution'
    - Date: 9 November 1995
    - Case: United Mizrahi Bank v. Migdal Cooperative Village (CA 6821/93)
    - Nine-justice Supreme Court panel led by Aharon Barak
    - Held that the 1992 Basic Laws have constitutional (supra-legislative) status
    - Courts may set aside ordinary legislation conflicting with them (judicial review)
    - Called the 'constitutional revolution'

**[S318]** RETIRED (no longer cited) — Jewish Virtual Library, 'Elections to the 13th Knesset (June 1992)'; Israel Democracy Institute, 'Elections 1992' — https://www.jewishvirtuallibrary.org/elections-to-the-13th-knesset-june-1992

**[S319]** United Nations, 'Report submitted to the Security Council by the Secretary-General' on the deportation of Palestinians (UNSCR 799), January 1993 — https://www.un.org/unispal/document/auto-insert-180990 — archived: https://web.archive.org/web/20231214131851/https://www.un.org/unispal/document/auto-insert-180990/ — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel deported 415 Palestinians to south Lebanon on 17 December 1992 after the kidnapping and killing of Border Policeman Nissim Toledano
    - The High Court of Justice allowed the expulsions by 5–2; Lebanon refused entry, leaving deportees at Marj al-Zuhur
    - Security Council resolution 799 (18 Dec 1992) condemned the deportation; Israel agreed with the US in Feb 1993 to an early return
    - Date: deportation on 17 December 1992
    - 415 Palestinians deported
    - After the kidnapping and killing by Hamas of a Border Police officer
    - Places gaza_strip, west_bank (deportees came from the occupied territories)
    - Security Council resolution 799 condemned the deportation
    - Kidnapping and murder of an Israeli border policeman

**[S320]** RETIRED (no longer cited) — US Department of State, 'Country Report on Human Rights Practices 1993 – Lebanon' (via Refworld) — https://www.refworld.org/node/25230

**[S321]** RETIRED (no longer cited) — UN Peacemaker, 'Declaration of Principles on Interim Self-Government Arrangements' (Oslo Accords), 13 September 1993 (A/48/486–S/26560) — https://peacemaker.un.org/sites/peacemaker.un.org/files/IL PS_930913_DeclarationPrinciplesnterimSelf-Government(Oslo Accords).pdf

**[S322]** Israel State Archives, 'Chapter 3: The Massacre in Hebron and its Aftermath' — https://catalog.archives.gov.il/site/en/chapter/chapter-3-the-massacre-in-hebron-and-its-aftermath — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - On 25 February 1994 (Purim) Baruch Goldstein of Kiryat Arba, a Kach activist, shot Muslim worshippers in the Cave of the Patriarchs, killing 29 and injuring about 125–129
    - The government appointed the Shamgar Commission, which found he acted alone and faulted security coordination
    - Date: 25 February 1994, on Purim
    - Baruch Goldstein, a physician from Kiryat Arba and Kach activist (place kiryat_arba)
    - Opened fire on Muslim worshippers at prayer in the Cave of the Patriarchs in Hebron (place hebron)
    - Killing 29 and wounding about 125-129
    - He was overpowered and killed
    - The government appointed the Shamgar Commission
    - Neutrality: Palestinians killed by the IDF in the riots that followed are omitted
    - 29 killed and 129 injured
    - Goldstein disarmed and killed by worshippers
    - Riots followed; more killed and wounded by IDF soldiers
    - Commission headed by Shamgar

**[S323]** Israel Ministry of Foreign Affairs, 'Agreement on the Gaza Strip and the Jericho Area' (4 May 1994); Hedges, C., 'Rabin and Arafat Sign Accord Ending Israel's 27-Year Hold on Jericho and the Gaza Strip', New York Times, 5 May 1994 — https://www.nytimes.com/1994/05/05/world/mideast-accord-overview-rabin-arafat-sign-accord-ending-israel-s-27-year-hold.html — archived: https://web.archive.org/web/20241231011227/https://www.nytimes.com/1994/05/05/world/mideast-accord-overview-rabin-arafat-sign-accord-ending-israel-s-27-year-hold.html — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Signed in Cairo on 4 May 1994 by Rabin and Arafat
    - Israel to withdraw from most of the Gaza Strip and the Jericho area; transfer of authority to a Palestinian Authority; Paris economic protocol annexed
    - Note: URLs taken from Wikipedia 'Gaza–Jericho Agreement' references (MFA text: mfa.gov.il Guide to the Peace Process)
    - Rabin and Arafat signed the agreement in Cairo (place cairo), 4 May 1994
    - Agreement implementing the first stage of Oslo
    - Israeli forces withdrew from most of the Gaza Strip and the Jericho area within weeks (places gaza_city, khan_yunis, rafah, jericho)
    - Authority passed to the new Palestinian Authority
    - Israeli settlements and military locations in Gaza remained under Israeli control

**[S324]** RETIRED (no longer cited) — United Nations (UNISPAL), 'Attack in Tel Aviv – Letter from Israel' (A/49/…, October 1994); Jewish Virtual Library, 'The Dizengoff Street Bus Bombing' — https://www.un.org/unispal/?p=177253

**[S325]** RETIRED (no longer cited) — United Nations (UNISPAL), 'Treaty of Peace between the State of Israel and the Hashemite Kingdom of Jordan' (letter of 9 January 1995) — https://www.un.org/unispal/?p=179122

**[S326]** Nobel Foundation, 'The Nobel Peace Prize 1994' — https://www.nobelprize.org/prizes/peace/1994/summary/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Peace Prize 1994 awarded jointly to Yasser Arafat, Shimon Peres and Yitzhak Rabin 'for their efforts to create peace in the Middle East'; announced 14 October 1994, presented 10 December 1994
    - Awarded jointly to Rabin, Peres and Arafat for their efforts to create peace in the Middle East

**[S327]** Fanack Chronicle of the Middle East and North Africa, 'The Oslo Accords' — https://fanack.com/palestine/history-of-palestine/the-oslo-accords/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Oslo II (Interim Agreement) signed 28 September 1995 divided the West Bank into Areas A, B and C
    - After later modifications Area A came to 18.2 percent of the territory
    - Area A: full Palestinian civil and security control, including the main Palestinian towns
    - Area B: Palestinian civil, joint (Israeli) security control
    - After later redeployments Area A reached about 18%
    - Area C about 60% (Fanack)

**[S328]** Just Vision, Glossary: 'Areas A, B, C' — https://justvision.org/glossary/areas-b-c — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Initial Oslo II division: roughly 3% Area A (full PA civil and security control), 24% Area B, 73% Area C (Israeli control)

**[S329]** Jewish Virtual Library, 'The Assassination of Yitzhak Rabin'; Center for Israel Education, 'Shamgar Commission' — https://www.jewishvirtuallibrary.org/the-assassination-of-yitzhak-rabin — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Rabin shot by Yigal Amir on 4 November 1995 after a peace rally at Kings of Israel Square, Tel Aviv
    - Amir convicted and sentenced to life imprisonment in March 1996; the Shamgar Commission found security lapses by police and Shin Bet and no conspiracy
    - Date: 4 November 1995
    - Shot dead by Yigal Amir as he left a peace rally at Kings of Israel Square in Tel Aviv (place tel_aviv)
    - Amir was a Jewish Israeli opponent of the Oslo process
    - Shimon Peres succeeded him
    - Amir sentenced to life imprisonment in March 1996
    - Shamgar Commission found serious security lapses
    - Shamgar Commission found no conspiracy
    - Rabin at peace rally, Kings of Israel Square, 4 Nov 1995
    - Guard Yoram Rubin slightly wounded
    - Life plus six years
    - Hagai Amir convicted of conspiracy
    - Shamgar report 28 Mar 1996
    - Shamgar criticised Shin Bet
    - Peres succeeded Rabin

**[S330]** United Nations, Division for Palestinian Rights, 'Chronological Review of Events' (March 1996) — https://www.un.org/unispal/document/auto-insert-196309 — archived: https://web.archive.org/web/20240819234941/https://www.un.org/unispal/document/auto-insert-196309/ — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 3 March 1996 bus bombing in Jerusalem killed 19; 4 March Dizengoff Center bombing killed 14 (UN count), bringing the nine-day toll to 61
    - Hamas claimed the attacks as retaliation for the January 1996 killing of Yahya Ayyash
    - Date: wave began 25 February 1996 (nine days to 4 March)
    - About 60 killed in nine days (UN tally 61)
    - Hamas presented them as revenge for Israel's January killing of Yahya Ayyash
    - UN: 3 March bus, 19 killed
    - UN: 26 killed on the same line a week earlier
    - UN: Hamas retaliation for Ayyash
    - UN: Dizengoff 14 killed, toll 61
    - UN: 27 nations at summit 13 March
    - Closure barred 22,000 Gaza workers

**[S331]** RETIRED (no longer cited) — Israel Ministry of Foreign Affairs, 'Suicide and Other Bombing Attacks in Israel Since the Declaration of Principles (Sept 1993)' — https://embassies.gov.il/MFA/FOREIGNPOLICY/Terrorism/Palestinian/Pages/Suicide and Other Bombing Attacks in Israel Since.aspx

**[S332]** RETIRED (no longer cited) — United Nations Security Council, Letter dated 7 May 1996 from the Secretary-General (S/1996/337), report of Maj.-Gen. Franklin van Kappen on the shelling of the UNIFIL compound at Qana — https://www.un.org/unispal/?p=187312

**[S333]** RETIRED (no longer cited) — Human Rights Watch, 'Israel/Lebanon: Unlawful Killings During Operation Grapes of Wrath', July 1997 (via Refworld) — https://www.refworld.org/docid/3ae6a98f14.html

**[S334]** Israel Democracy Institute, 'Elections 1996'; Jewish Virtual Library, 'Elections to the 14th Knesset' — https://en.idi.org.il/israeli-elections-and-parties/elections/1996/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Election 29 May 1996, first direct election of the prime minister: Netanyahu 1,501,023 (50.5%) vs Peres 1,471,566 (49.5%) (JVL: https://www.jewishvirtuallibrary.org/jsource/Politics/knesset96.html)
    - Labor 34 seats; Likud–Gesher–Tzomet 32
    - Date: 29 May 1996
    - First election held under the direct-election system
    - Netanyahu defeated Peres by about 30,000 votes
    - Vote shares 50.5% to 49.5%
    - Labor won 34 seats, Likud-Gesher-Tzomet 32

**[S335]** Jewish Telegraphic Agency, 'Controversial Old City tunnel among stops for Sukkot visitors', Oct 1996; UN letter of 26 September 1996 (UNISPAL) — https://jta.org/archive/controversial-old-city-tunnel-among-stops-for-sukkot-visitors — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Clashes followed the government's opening of the northern exit of the Western Wall tunnel (24 Sept 1996)
    - By early October the toll was 15 Israelis and 57 Palestinians killed (JTA); an early UN letter of 26 Sept cited 40 Palestinians and 11 Israelis
    - The government's opening of a new northern exit to the Western Wall tunnel in Jerusalem's Old City (place jerusalem)
    - Set off Palestinian protests and armed clashes across the West Bank and Gaza (places west bank towns, gaza_strip)
    - By early October 15 Israelis and at least 57 Palestinians had been killed
    - Death toll 15 Israelis and 57 Palestinians
    - Government's decision to open the northern entrance sparked the violence

**[S336]** RETIRED (no longer cited) — UN Peacemaker, 'Protocol Concerning the Redeployment in Hebron', 17 January 1997 — https://peacemaker.un.org/sites/peacemaker.un.org/files/IL%20PS_970117_Protocol%20Concerning%20the%20Redeployment%20in%20Hebron.pdf

**[S337]** Israel Ministry of Defense Archives, 'The 1997 Helicopter Disaster' (exhibition) — https://archives.mod.gov.il/sites/English/Exhibitions/Pages/The-1997-Helicopter-Disaster.aspx — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - On 4 February 1997 two IAF Yas'ur transport helicopters collided over She'ar Yashuv in northern Israel, killing all 73 soldiers aboard, en route to south Lebanon
    - Date: 4 February 1997
    - Two IAF CH-53 'Yas'ur' transport helicopters carrying troops to the south Lebanon security zone
    - Collided over She'ar Yashuv in the Upper Galilee (places galilee, kiryat_shmona)
    - Killing all 73 soldiers and aircrew aboard
    - All 73 Israeli military personnel aboard killed

**[S338]** Jewish Virtual Library, 'Israel Intelligence & Security: Report on the Mashal Affair' (Ciechanover Commission) — https://www.jewishvirtuallibrary.org/jsource/Society_&_Culture/mashal.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Failed Mossad attempt to poison Hamas leader Khaled Mashal in Amman on 25 September 1997; agents captured
    - Israel provided the antidote after King Hussein's demand and US intervention, and released Sheikh Ahmed Yassin in exchange for the agents
    - Date: 25 September 1997; Mossad agents tried to kill Hamas political leader Khaled Mashal in Amman (place amman)
    - Mashal was Hamas political leader
    - Two agents were caught
    - Israel supplied the antidote
    - Israel freed Sheikh Ahmed Yassin in exchange for the agents
    - A crisis in relations with Jordan three years after the peace treaty
    - Choice 'Supply the antidote and release Sheikh Yassin' was Netanyahu's decision
    - Agents injured Mashal using a lethal substance
    - Antidote saved his life

**[S339]** European Broadcasting Union, Eurovision Song Contest, 'Birmingham 1998' — https://www.eurovision.com/eurovision-song-contest/birmingham-1998/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Dana International won Eurovision 1998 in Birmingham for Israel with 'Diva' (172 points); first transgender winner; first contest decided by televote
    - Dana International won the Eurovision Song Contest in Birmingham for Israel with 'Diva'
    - First contest decided entirely by televote
    - She was the contest's first transgender winner
    - First contest with televoting as the standard method; Hungary, Romania and Turkey still used juries

**[S340]** Avalon Project, Yale Law School, 'The Wye River Memorandum', 23 October 1998 — https://avalon.law.yale.edu/20th_century/wyeriv.asp — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Signed 23 October 1998; further redeployment transferring 13% from Area C (1% to A, 12% to B) and 14.2% from Area B to Area A
    - Date: 23 October 1998 (place washington)
    - 13% of territory to move out of Area C (place west_bank)
    - 14.2% from Area B to Area A
    - Linked to Palestinian security commitments

**[S341]** Israel Democracy Institute, 'Elections 1999' — https://en.idi.org.il/israeli-elections-and-parties/elections/1999/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Election 17 May 1999; Ehud Barak elected prime minister by a convincing margin; One Israel 26 seats, Likud 19, Shas 17
    - Date: 17 May 1999
    - Ehud Barak of One Israel defeated Netanyahu by a wide margin in the direct prime-ministerial vote
    - Knesset fragmented: One Israel 26, Likud 19, Shas 17
    - Election for prime minister only (no Knesset election)

**[S342]** Congressional Research Service, 'The South Lebanon Army (SLA): History, Collapse, Post-Withdrawal Status' (RS20566), 2000; Christian Science Monitor, 'Fallout from pullout: mistrust', 24 May 2000 — https://www.everycrsreport.com/reports/RS20566.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel withdrew from its south Lebanon security zone in May 2000 (completed 24 May), ahead of the July 2000 deadline set by Barak's cabinet
    - The SLA collapsed; some members fled to Israel, others surrendered to Hezbollah
    - The IDF withdrew from the south Lebanon security zone, completing the pullout on 24 May 2000 (place south_lebanon)
    - Ahead of the July deadline set by Barak's cabinet
    - The Israeli-allied South Lebanon Army collapsed
    - Some SLA members and their families fled to Israel
    - Others surrendered to Hezbollah, which took over the area
    - Choice 'Withdraw unilaterally' was Barak's cabinet decision with a July 2000 deadline
    - Order 23 May, withdrawal completed the next day
    - Cabinet endorsed withdrawal by 7 July 2000
    - About 7,000 fled to Israel
    - About half of SLA members remained
    - Surrendered SLA members handed to Lebanese authorities
    - One Lebanese Christian allegedly killed 29 May
    - Control passed to Hezbollah, UN peacekeepers and Lebanese police
    - Cabinet endorsed Barak's plan to withdraw by 7 July 2000

**[S343]** Jewish Virtual Library, '2000 Camp David Summit: Background & Overview' — https://www.jewishvirtuallibrary.org/background-and-overview-of-2000-camp-david-summit — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Camp David summit (11–25 July 2000) of Clinton, Barak and Arafat ended without agreement; Jerusalem and the Temple Mount/Haram al-Sharif and refugees were central disputes
    - Accounts of blame differ (Ross, Ben-Ami vs. Malley, Erekat)
    - Date: began 11 July 2000; Clinton hosted Barak and Arafat at Camp David (place camp_david)
    - The summit ended on 25 July without agreement
    - Dennis Ross and Shlomo Ben-Ami largely blamed Arafat
    - Robert Malley argued Israel's offer was less generous than portrayed
    - Summit held 11-24 July 2000 (date_end)
    - Palestinian Authority's account: only a fragmented state of cantons was offered (supported by Malley, Agha and the PA)
    - Revisionist account supported by Malley, Agha and the Palestinian Authority itself

**[S344]** Sharm el-Sheikh Fact-Finding Committee (Mitchell Report), 30 April 2001 (Jewish Virtual Library text) — https://jewishvirtuallibrary.org/the-mitchell-report-may-2001 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Ariel Sharon visited the Temple Mount/Haram al-Sharif on 28 September 2000; the committee found the visit did not cause the 'Al-Aqsa Intifada' but was poorly timed
    - On 29 September Israeli police used lethal means against Palestinian demonstrators; the report blamed both sides' lack of restraint
    - Date: Sharon visited the Temple Mount/Haram al-Sharif on 28 September 2000 (place jerusalem)
    - Followed the next day by protests in which Israeli police used lethal force
    - Mitchell Report found the visit did not cause the intifada but was poorly timed
    - Mitchell Report faulted both sides

**[S345]** B'Tselem, press release 27 September 2010: fatalities since the outbreak of the second intifada — https://www.btselem.org/press_releases/20100927 — archived: https://web.archive.org/web/20160109184037/http://www.btselem.org/press_releases/20100927 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - From 29 Sept 2000 to 26 Sept 2010 Israeli security forces killed 6,371 Palestinians (1,317 minors; at least 2,996 not participating in hostilities)
    - Palestinians killed 1,083 Israelis (741 civilians incl. 124 minors; 342 security-force members)
    - Note: figures from search-result extracts; direct fetch rate-limited
    - B'Tselem: 6,371 Palestinians killed by Israeli security forces, Sept 2000 - Sept 2010 (places west_bank, gaza_strip)
    - At least 2,996 of them not taking part in hostilities
    - 1,083 Israelis killed by Palestinians (741 civilians)
    - B'Tselem: 6,371 Palestinians killed by Israeli security forces
    - At least 2,996 not participating in hostilities
    - 1,083 Israelis killed, 741 civilians

**[S346]** +972 Magazine, 'Thirteen killed, no one punished: Remembering October 2000'; Adalah, 'October 2000 – Law and Politics before the Or Commission' — https://www.972mag.com/thirteen-killed-no-one-punished-remembering-october-2000/ — archived: https://web.archive.org/web/20241223181207/https://www.972mag.com/thirteen-killed-no-one-punished-remembering-october-2000/ — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 13 Palestinian Arabs (12 citizens of Israel and one resident of Gaza) killed by police in October 2000
    - Or Commission appointed 8 November 2000, report published 1 September 2003; found police gunfire unjustified and sniper use illegal; no one was indicted
    - Date: early October 2000 (first deaths 1 October)
    - Protests by Arab citizens in the Galilee and Wadi Ara (place galilee)
    - Police killed 13 Palestinian Arabs, 12 citizens of Israel and one resident of Gaza
    - Or Commission found police gunfire unjustified
    - Or Commission appointed November 2000, reported September 2003
    - No officer was indicted
    - Neutrality: injured/arrested and any Jewish casualties omitted
    - The state commission of inquiry into the October 2000 killings published its report (2003)
    - Found police use of live fire unjustified
    - No criminal charges followed
    - Places jerusalem, nazareth, umm_al_fahm
    - 13 killed: 12 citizens and one Gaza resident
    - Victims in Umm al-Fahm, Nazareth, Jatt, Mu'awiya (1 Oct)
    - Victims in Arrabe, Sakhnin, Kafr Kanna
    - More than 1,000 protesters wounded
    - Commission found no justification for live or rubber bullets
    - Report released 2003
    - Mahash 2005 no indictments; AG closed 2007

**[S347]** Jewish Virtual Library, 'Israeli Electoral History: Sharon Elected Israeli Prime Minister' — https://www.jewishvirtuallibrary.org/jsource/Politics/sharonwin.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Special prime-ministerial election of 6 February 2001: Sharon 62.5%, Barak 37.5%
    - Date: 6 February 2001; special election for prime minister only
    - Sharon (Likud) defeated incumbent Barak 62.5% to 37.5%

**[S348]** Human Rights Watch, 'Erased in a Moment: Suicide Bombing Attacks Against Israeli Civilians', October 2002 — https://www.hrw.org/reports/2002/isrl-pa/ISRAELPA1002-08.htm — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Dolphinarium bombing in Tel Aviv on 1 June 2001 killed 21; Islamic Jihad first claimed it, later Hamas said it was responsible
    - Park Hotel (Netanya) Passover bombing, 27 March 2002 (HRW gives 29 killed)
    - Date: 1 June 2001
    - Killing 21
    - Islamic Jihad first claimed the attack; Hamas later said it was responsible
    - Killing 30 civilians (Israeli MFA; HRW gives 29)
    - 21 killed and at least 120 injured at the Dolphinarium, 1 June 2001
    - HRW: 29 killed, more than 100 injured

**[S349]** Globes, 'Minister of Tourism Rehavam Zeevi assassinated at point-blank range in Jerusalem Hyatt', 17 October 2001 — https://en.globes.co.il/en/article-528286 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Tourism Minister Rehavam Ze'evi shot dead at the Hyatt hotel, Jerusalem, on 17 October 2001; claimed by the PFLP as retaliation for Israel's killing of its leader Abu Ali Mustafa (Aug 2001)
    - Tourism Minister Rehavam Ze'evi shot dead in the Hyatt hotel in Jerusalem (place jerusalem)
    - By a Popular Front for the Liberation of Palestine cell
    - Ze'evi shot dead at the Jerusalem Hyatt

**[S350]** Jewish Virtual Library, 'IDF Seizes PA Weapons Ship: The Karine A Affair' — https://www.jewishvirtuallibrary.org/idf-seizes-pa-weapons-ship-the-karine-a-affair — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israeli naval commandos seized the Karine A in the Red Sea on 3 January 2002 carrying about 50 tons of weapons (rockets, anti-tank missiles, explosives); the PA denied involvement
    - Date: 3 January 2002
    - Israeli naval commandos boarded the Karine A in the Red Sea without a shot (places abroad, eilat)
    - About 50 tons of weapons
    - Including Katyusha rockets, anti-tank missiles and explosives
    - Israel said the Iranian-supplied cargo was bound for the PA
    - The Palestinian Authority denied involvement

**[S351]** RETIRED (no longer cited) — Israel Ministry of Foreign Affairs, 'Terrorist involved in Passover 2002 Netanya Park Hotel arrested', 26 March 2008 — https://embassies.gov.il/MFA/FOREIGNPOLICY/Terrorism/Palestinian/Pages/Terrorist involved in Passover 2002 Netanya Park Hotel arrested 26-Mar-2008.aspx

**[S352]** League of Arab States, 'The Arab Peace Initiative', Beirut Summit, 28 March 2002 (official translation) — https://unmee.unmissions.org/sites/default/files/api.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Adopted at the Beirut summit 27–28 March 2002: full Israeli withdrawal from territories occupied since June 1967, a Palestinian state with East Jerusalem as capital, a just solution to the refugee problem per UNGA 194, in return for normal relations
    - Date: 28 March 2002; Arab League summit in Beirut (place beirut)
    - Saudi-inspired plan
    - Offering normal relations with Israel in the context of a comprehensive peace
    - In return for full withdrawal from territories occupied since June 1967
    - A Palestinian state with East Jerusalem as its capital
    - A 'just solution' to the refugee problem in accordance with UNGA resolution 194

**[S353]** Human Rights Watch, 'Jenin: IDF Military Operations' (Vol. 14, No. 3(E), May 2002) and press release 3 May 2002 — https://www.hrw.org/legacy/press/2002/05/jenin0503.htm — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - At least 52 Palestinians killed in the Jenin refugee camp operation, of whom 22 were civilians
    - No evidence of a massacre of hundreds, but evidence of unlawful killings, use of human shields and disproportionate force
    - HRW: 52 Palestinians killed in Jenin, 22 civilians
    - HRW documented human shields and excessive force

**[S354]** RETIRED (no longer cited) — United Nations, Report of the Secretary-General on recent events in Jenin and other Palestinian cities (A/ES-10/186), 30 July 2002; Reuters report on its release — https://press.un.org/en/2002/SG2077.doc.htm

**[S355]** UN OCHA oPt, 'The Humanitarian Impact of the West Bank Barrier on Palestinian Communities', July 2009 — https://unispal.un.org/pdfs/BarrierRpt_0709.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - The first phase of the barrier was approved by Israeli Government Decision 2077 on 23 June 2002
    - Date: cabinet approved the first phase on 23 June 2002 (Government Decision 2077)
    - A barrier of fences, walls and patrol roads
    - Presented as a means to stop suicide bombers
    - Much of its route ran inside the West Bank, around settlement blocs and East Jerusalem (places west_bank, jerusalem)
    - Separating many Palestinian communities from land and services
    - Places qalqilya, tulkarm (first-phase northern West Bank route)

**[S356]** American Society of International Law, 'The World Court Rules that Israel's West Bank Barrier Violates International Law', ASIL Insights vol. 8 issue 17, July 2004 — https://www.asil.org/insights/volume/8/issue/17/world-court-rules-israels-west-bank-barrier-violates-international-law — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - ICJ advisory opinion of 9 July 2004: by 14 votes to 1 (Judge Buergenthal dissenting) construction of the wall in occupied territory is contrary to international law; Israel should cease construction, dismantle it and make reparation; Israel did not take part in oral proceedings
    - Date: 9 July 2004
    - By 14 votes to 1, US judge Thomas Buergenthal dissenting
    - Construction of the wall in occupied Palestinian territory, including around East Jerusalem, contrary to international law (places west_bank, east_jerusalem)
    - Israel should stop building it, dismantle it there and make reparation
    - Israel did not take part in the oral proceedings

**[S357]** Israel Democracy Institute, 'Elections 2003' — https://en.idi.org.il/israeli-elections-and-parties/elections/2003/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Election 28 January 2003: Likud 38 seats, Labor 19, Shinui 15; Sharon continued as PM
    - Date: 28 January 2003
    - Sharon's Likud won 38 seats, Labor 19 and the secularist Shinui 15
    - Sharon remained prime minister

**[S358]** Hayadan, 'Air Force announcement, 1 February 2003 – Col. Ilan Ramon perished in the crash of Columbia' — https://en.hayadan.org.il/halutz-anouncement-on-the-columbia-disaster-01012031 — archived: https://web.archive.org/web/2026id_/https://en.hayadan.org.il/halutz-anouncement-on-the-columbia-disaster-01012031 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Col. Ilan Ramon, Israel's first astronaut, was killed with six crewmates when Space Shuttle Columbia (STS-107) broke up on re-entry on 1 February 2003
    - Colonel Ilan Ramon, an Israeli Air Force pilot
    - IAF: Ramon and his six fellow astronauts did not return

**[S359]** RETIRED (no longer cited) — Institute for Palestine Studies, 'The Road Map'; UN, Statement of the Middle East Quartet, 20 December 2002 — https://www.palestine-studies.org/en/node/41344

**[S360]** PBS NewsHour, 'Israel kills Hamas leader Rantisi' (Middle East coverage, 19 April 2004) — https://www.pbs.org/newshour/politics/middle_east-jan-june04-mideast_04-19 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Abdel Aziz al-Rantisi killed by an Israeli helicopter missile strike in Gaza City on 17 April 2004, less than a month after Israel killed Hamas founder Sheikh Ahmed Yassin (22 March 2004)
    - Strike came three days after President Bush endorsed Sharon's Gaza withdrawal plan
    - Israeli missile strike killed Hamas founder Sheikh Ahmed Yassin on 22 March 2004
    - Abdel Aziz al-Rantisi, his successor in Gaza, killed by helicopter missile strike on 17 April 2004 (place gaza_city)
    - The second strike came days after President Bush endorsed Sharon's plan to withdraw from Gaza
    - Yassin killed 22 March 2004

**[S361]** Nobel Foundation, 'The Nobel Prize in Chemistry 2004' press release — https://www.nobelprize.org/prizes/chemistry/2004/press-release/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Chemistry 2004 awarded jointly to Aaron Ciechanover, Avram Hershko (both Technion, Israel) and Irwin Rose for the discovery of ubiquitin-mediated protein degradation
    - Date: announced 6 October 2004
    - Ciechanover and Hershko shared the 2004 Chemistry prize with Irwin Rose for discovering ubiquitin-mediated protein degradation
    - Technion researchers (place haifa)

**[S362]** Nobel Foundation, 'The Sveriges Riksbank Prize in Economic Sciences 2005' — https://www.nobelprize.org/prizes/economic-sciences/2005/summary/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 2005 prize awarded jointly to Robert J. Aumann (Hebrew University) and Thomas C. Schelling for enhancing understanding of conflict and cooperation through game-theory analysis
    - Shared the 2005 economics prize with Thomas Schelling for enhancing understanding of conflict and cooperation through game-theory analysis

**[S363]** RETIRED (no longer cited) — Hebrew University of Jerusalem (CRIS), 'The Sveriges Riksbank Prize in Economic Sciences in Memory of Alfred Nobel' (Kahneman, 2002) — https://cris.huji.ac.il/en/prizes/the-sveriges-riksbank-prize-in-economic-sciences-in-memory-of-alf/

**[S364]** BBC News, 'Arafat's funeral held in Cairo', 12 November 2004 — https://news.bbc.co.uk/2/hi/middle_east/4005027.stm — archived: https://web.archive.org/web/20250703060254/http://news.bbc.co.uk/2/hi/middle_east/4005027.stm — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Yasser Arafat died in a French military hospital near Paris (11 November 2004) after admission on 29 October; state funeral in Cairo and burial at the Muqata'a in Ramallah
    - Note: URL taken from Wikipedia 'Death of Yasser Arafat' references
    - Date: died 11 November 2004 (Thursday before the 12 Nov funeral)
    - Died in a French military hospital near Paris after a sudden illness (place abroad)
    - Funeral in Cairo
    - Buried at his Muqata'a compound in Ramallah (place ramallah)

**[S365]** United Nations, Division for Palestinian Rights, 'Gaza Disengagement' review (2005); CRS report RS22000 'Israel's Disengagement from Gaza' (Sept 2005); ADL backgrounder 'Disengagement' — https://www.un.org/unispal/?p=207840 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Evacuations of all 21 settlements in the Gaza Strip and 4 in the northern West Bank completed 22–23 August 2005 (UN, CRS)
    - Over 8,000 residents evacuated (ADL); the plan was unilateral; IDF officially left Gaza on 12 September 2005 (ADL: https://www.adl.org/resources/glossary-term/disengagement)
    - A Palestinian chronology gives about 8,500 Gaza settlers
    - OCHA: Palestinian homes occupied as observation posts

**[S366]** IDE Technologies, 'Ashkelon Desalination Plant (Israel)'; WaterWorld, 'World's largest desalination plant begins operations in Israel with Dow membranes', 2005 — https://ide-tech.com/en/project/ashkelon-desalination-plant — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Ashkelon reverse-osmosis plant began supplying the national grid in mid-August 2005, then the world's largest SWRO plant: two units of 165,000 m3/day (330,000 m3/day), ~100 million m3/year contracted; expanded ~20% in 2010 (396,000 m3/day)
    - Ashkelon seawater reverse-osmosis plant began operating in 2005 (place ashkelon)
    - Then the largest in the world
    - 330,000 m³ a day
    - One of the world's largest membrane-based plants when completed
    - Expanded by nearly 20% in 2010 to 396,000 m3/day

**[S367]** Al Jazeera, 'Israeli cabinet ends Sharon era', 11 April 2006; Encyclopaedia Britannica, 'Kadima' — https://www.aljazeera.com/news/2006/4/11/israeli-cabinet-ends-sharon-era — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Sharon left Likud on 21 November 2005 to found Kadima (party established 24 November 2005)
    - Sharon suffered a massive stroke on 4 January 2006; Olmert became acting PM; cabinet declared Sharon permanently incapacitated in April 2006
    - Date: Sharon suffered a stroke on 4 January 2006 and never regained consciousness
    - The cabinet declared Sharon permanently incapacitated in April 2006

**[S368]** Human Rights Watch, 'Internal Fight: Palestinian Abuses in Gaza and the West Bank', July 2008, chapter 3 (background) — https://www.hrw.org/reports/2008/iopt0708/3.htm — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - In the 25 January 2006 PLC election Hamas won 74 of 132 seats (plus four Hamas-supported independents), Fatah 45; Haniyeh formed a government 29 March 2006
    - June 2007: Hamas took control of Gaza; on 14 June Abbas declared a state of emergency, dismissed the Haniyeh government and appointed Salam Fayyad; legality of the Fayyad government questioned by some PLC members
    - Date: January 2006 (25 January) Palestinian legislative election (places gaza_strip, west_bank)
    - Hamas won 74 of 132 seats (plus four allied independents) to Fatah's 45
    - Ismail Haniyeh formed a Hamas government on 29 March 2006
    - After days of fighting between Hamas and Fatah forces, Hamas took control of the Gaza Strip (places gaza_strip, gaza_city)
    - Date: 14 June 2007; Abbas declared a state of emergency, dismissed the Haniyeh unity government and appointed Salam Fayyad to head an emergency government (place ramallah)
    - Splitting Palestinian rule between Gaza and the West Bank
    - Neutrality: casualties of the fighting omitted
    - 161 Palestinians died incl. 41 civilians (PCHR via HRW)
    - At least 700 wounded
    - Clashes peaked mid-June 2007 when Hamas seized Gaza's security facilities
    - Haniyeh-led Hamas government formed two months later

**[S369]** Israel Democracy Institute, 'Elections 2006' — https://en.idi.org.il/israeli-elections-and-parties/elections/2006/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Election 28 March 2006: Kadima 29, Labor 19, Shas 12, Likud 12, Yisrael Beitenu 11, Gil 7; Olmert coalition of Kadima, Labor, Shas and Gil (67 MKs)
    - Choice 'Keep the Gaza settlements': opposition of Likud rebels (supplementary)
    - After clashes within Likud over disengagement, Sharon left the party and founded the centrist Kadima
    - Date: 21 November 2005
    - Ehud Olmert became acting prime minister and Kadima leader
    - Date: 28 March 2006
    - Kadima 29, Labor 19, Shas and Likud 12 each, Yisrael Beitenu 11, Gil 7
    - Olmert formed a coalition of Kadima, Labor, Shas and Gil with 67 seats

**[S370]** Jewish Virtual Library, 'Gilad Shalit'; Christian Science Monitor, 'Gilad Shalit: Why does he matter so much? How was he captured', 12 Oct 2011 — https://www.jewishvirtuallibrary.org/gilad-shalit — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - On 25 June 2006 militants from Gaza entered Israel through a tunnel near Kerem Shalom, killed Lt. Hanan Barak and Staff Sgt. Pavel Slutsker and captured Cpl. Gilad Shalit
    - Israel launched Operation Summer Rains on 27 June 2006; Shalit was released on 18 October 2011 in a prisoner exchange
    - Date: 25 June 2006; captured near Kerem Shalom
    - Militants from Hamas and allied groups tunnelled from Gaza into Israel
    - Killed two soldiers (Lt. Hanan Barak and Staff Sgt. Pavel Slutsker) and abducted Cpl. Gilad Shalit to Gaza
    - Israel launched Operation Summer Rains in Gaza on 27 June
    - Shalit held until an October 2011 prisoner exchange
    - Neutrality: attackers killed and other casualties omitted
    - IDF: officer and soldier killed, one kidnapped, four injured
    - Killed soldiers Pavel Slutsker and Chanan Barak
    - At least two attackers killed
    - Operation Summer Rains launched
    - Infiltration through a tunnel near Kerem Shalom and Sufa
    - Released in a prisoner exchange

**[S371]** Human Rights Watch, 'Why They Died: Civilian Casualties in Lebanon during the 2006 War', September 2007; HRW, 'Civilians under Assault: Hezbollah's Rocket Attacks on Israel in the 2006 War', August 2007 — https://www.hrw.org/reports/2007/lebanon0907/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - At least 1,109 Lebanese deaths, the vast majority civilians, 4,399 injured, about 1 million displaced
    - Hezbollah rocket attacks killed 43 Israeli civilians and 12 IDF soldiers
    - War lasted 12 July - 14 August 2006
    - Raid killed three IDF soldiers and captured two
    - HRW: at least 1,109 Lebanese deaths, 4,399 injured, ~1 million displaced
    - HRW: ~860 civilians and ~250 combatants among 1,109
    - HRW: rockets killed 43 Israeli civilians

**[S372]** Center for Israel Education, 'Second Lebanon War Begins' (12 July 2006); Al-Monitor, 'Israel-Hezbollah war: What is UN resolution 1701?', Oct 2024 — https://israeled.org/second-lebanon-war-begins/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - War began 12 July 2006 with Hezbollah's cross-border raid; UN-brokered cease-fire took effect 14 August 2006
    - 121 IDF soldiers and (by this count) 43–44 Israeli civilians killed; about 1,191 Lebanese killed (Lebanese count)
    - UNSC resolution 1701 adopted unanimously 11 August 2006: Hezbollah disarmament south of the Litani, IDF withdrawal, Lebanese army and enlarged UNIFIL deployment (al-monitor.com/originals/2024/10/israel-hezbollah-war-what-un-resolution-1701)
    - Date: began 12 July 2006 after a Hezbollah cross-border raid in which Israeli soldiers were killed and two captured
    - UN-brokered cease-fire under UNSC resolution 1701 took effect on 14 August
    - 121 IDF soldiers killed
    - 121 IDF soldiers killed (CIE; CIE's civilian figure of 19 is not used)
    - Wounded: 1,384 civilians and 1,244 soldiers (CIE)
    - Hezbollah losses estimated 500-600 (CIE)

**[S373]** Jewish Virtual Library, 'Winograd Commission: Final Report' (30 January 2008) — https://jewishvirtuallibrary.org/winograd-commission-final-report-january-2008 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Final report released 30 January 2008: war a 'missed opportunity' ending without clear military victory; serious failings in decision-making, preparedness and strategic planning and in protecting civilians; interim report April 2007
    - Defence Minister Peretz and Chief of Staff Halutz stepped down; Olmert resigned in 2008 amid the report and corruption investigations
    - Choice 'Broad air campaign then ground operations' was the Olmert cabinet decision of 12 July; Winograd found serious failings
    - Choice 'Limited retaliatory strikes and diplomatic pressure' was among options Winograd found not adequately examined
    - Date: final report 30 January 2008
    - Called the 2006 war a missed opportunity that ended without a clear military victory
    - Serious failings in decision-making, military preparedness, strategy and civil defence
    - Government-appointed commission (place jerusalem)

**[S374]** Voice of America (via GlobalSecurity), 'Fighting Ends in Gaza as Hamas Takes Control', 15 June 2007 — https://www.globalsecurity.org/military/library/news/2007/06/mil-070615-voa02.htm — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Fatah–Hamas fighting in Gaza ended mid-June 2007 with Hamas in control of the Gaza Strip

**[S375]** NATO CCDCOE, International Cyber Law: Interactive Toolkit, 'Operation Orchard/Outside the Box (2007)' — https://cyberlaw.ccdcoe.org/wiki/Operation_Orchard/Outside_the_Box_(2007) — archived: https://web.archive.org/web/20250224014251/https://cyberlaw.ccdcoe.org/wiki/Operation_Orchard/Outside_the_Box_(2007) — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israeli airstrike just after midnight on 6 September 2007 destroyed a suspected nuclear reactor at al-Kibar, Deir ez-Zor, Syria
    - Israel officially acknowledged the operation on 21 March 2018; a 2009 IAEA investigation found uranium traces and features resembling an undeclared reactor
    - Date: 6 September 2007; Israeli aircraft destroyed the facility
    - A suspected plutonium-production reactor under construction at al-Kibar near Deir ez-Zor in Syria (place syria)
    - Israel kept silent until officially acknowledging the strike in March 2018
    - Syria claimed the building was an unused conventional military installation
    - IAEA: Al-Kibar 'very likely' a nuclear reactor

**[S376]** RETIRED (no longer cited) — Peace Agreements Database (University of Edinburgh), 'Annapolis Conference Joint Understanding on Negotiations', 27 November 2007 — https://www.peaceagreements.org/view/1072/

**[S377]** RETIRED (no longer cited) — Israel Ministry of Foreign Affairs, 'Terror shooting at Mercaz Harav Yeshiva in Jerusalem', 6 March 2008; Jewish Virtual Library — https://embassies.gov.il/MFA/FOREIGNPOLICY/Terrorism/Palestinian/Pages/Terror-shooting-at-Mercaz-Harav-Yeshiva-in-Jerusalem-6-Mar-2008.aspx

**[S378]** Ynetnews, 'B'Tselem: 773 of Palestinians killed in Cast Lead were civilians', September 2009 — https://www.ynetnews.com/article/3774217 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - B'Tselem: 1,387 Palestinians killed in Operation Cast Lead (27 Dec 2008 – 18 Jan 2009), 773 of whom did not take part in hostilities (incl. 320 minors)
    - IDF count: 1,166 Palestinians killed – 709 combatants, 295 civilians, 162 unclassified; dispute centred on ~248 Hamas police
    - IDF estimate 1,166 Palestinians killed (709 combatants, 295 civilians, 162 unclassified)
    - B'Tselem 1,387 killed (773 not taking part in hostilities, including 320 minors)
    - Dispute centres partly on some 248 Hamas police
    - IDF: 1,166 killed, 295 civilians
    - IDF: 709 involved in hostilities
    - PCHR: 1,434 Palestinians killed (reported by Ynet)
    - B'Tselem per Ynet: 330 combatants, 245 policemen, 38 undetermined
    - PCHR treated all 239 police as non-combatants; ICT disputed this
    - Israeli dead per B'Tselem via Ynet: nine by Palestinian fire, four by friendly fire

**[S379]** RETIRED (no longer cited) — Minority Rights Group International, 'State of the World's Minorities and Indigenous Peoples 2010 – Israel and the OPT' (via Refworld) — https://www.refworld.org/node/74156

**[S380]** RETIRED (no longer cited) — Harvard Law School Case Studies, 'Reputation, Credibility, and the Goldstone Report'; My Jewish Learning, 'The Goldstone Report' — https://casestudies.law.harvard.edu/reputation-credibility-and-the-goldstone-report-b/

**[S381]** Hansell, Saul, 'America Online to Buy Internet Chat Service for $287 Million', The New York Times, 9 June 1998 — https://www.nytimes.com/1998/06/09/business/america-online-to-buy-internet-chat-service-for-287-million.html — archived: https://web.archive.org/web/20240719004301/https://www.nytimes.com/1998/06/09/business/america-online-to-buy-internet-chat-service-for-287-million.html — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - AOL agreed on 8 June 1998 to buy Mirabilis, the Israeli developer of ICQ (founded 1996), for $287 million plus up to $120 million in performance payments
    - Note: URL taken from Wikipedia 'ICQ' references
    - Date: 8 June 1998 (announced the day before the NYT 9 June report)
    - AOL agreed to buy Mirabilis, creator of ICQ
    - $287 million plus up to $120 million in performance payments
    - Start-up founded in 1996 by five young Israelis
    - Place tel_aviv
    - Founded two years earlier by four Israelis in their early 20s
    - $287 million up front plus up to $120 million

**[S382]** RETIRED (no longer cited) — Haaretz, '2 Israelis lightly wounded as 33 rockets slam in western Negev' (2008) — https://www.haaretz.com/news/2-israelis-lightly-wounded-as-33-rockets-slam-in-western-negev-1.240446

**[S383]** RETIRED (no longer cited) — IDF, 'Operation Accountability' (Wars and Operations mini-site) — https://www.idf.il/en/mini-sites/wars-and-operations/operation-accountability/

**[S384]** BBC News, 'Abbas achieves landslide poll win', 10 January 2005 — https://news.bbc.co.uk/2/hi/middle_east/4160171.stm — archived: https://web.archive.org/web/20250213015730/http://news.bbc.co.uk/2/hi/middle_east/4160171.stm — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Mahmoud Abbas won the 9 January 2005 Palestinian presidential election with about 62–67% of the vote (67.4% of valid votes per the Central Elections Commission)
    - Note: URL taken from Wikipedia references
    - Date: 9 January 2005 (Sunday's presidential election)
    - Mahmoud Abbas (Fatah) won the Palestinian presidential election (places ramallah, gaza_strip, west_bank)
    - With about 62-67% of the vote
    - Preliminary official results: Abbas 62.3%, turnout about 66%

**[S385]** Israel State Archives, 'Negotiating peace between Israel and Jordan, September 1993 – November 1994' — https://catalog.archives.gov.il/site/en/chapter/negotiating-peace-between-israel-and-jordan-september-1993-november-1994 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Treaty ceremony in the Arava near Eilat on 26 October 1994; crossing later named the Yitzhak Rabin crossing
    - With an annexed protocol on economic relations (Paris Protocol)
    - At the Arava/Araba crossing north of Eilat (places arava, eilat)

**[S386]** Center for Israel Education, 'Prime Minister Rabin deports 415 Palestinians to South Lebanon' (17 December 1992) — https://israeled.org/timeline/prime-minister-rabin-deports-415-palestinians-to-south-lebanon/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 415 Hamas and Islamic Jihad activists deported to south Lebanon on 17 December 1992
    - Identified as Hamas and Islamic Jihad activists
    - Rabin government deported them to south Lebanon (place south_lebanon)
    - Several deportees, including Abdel Aziz al-Rantisi, later led Hamas
    - Rantisi and Zahar later led Hamas

**[S387]** US Department of State, 'Patterns of Global Terrorism 1996: Middle East Overview' (via FAS) — https://irp.fas.org/threat/terror_96/middle.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - After the February–March 1996 bombings, leaders of 29 countries met at the 'Summit of the Peacemakers' in Sharm el-Sheikh (13 March 1996) and pledged action against terrorism
    - Hamas suicide bombings
    - Leaders of 29 countries met at the 'Summit of the Peacemakers' in Sharm el-Sheikh on 13 March
    - 25 Feb Jerusalem bus: 26 killed incl. 3 US citizens, 80 injured
    - 3 Mar bus: 19 killed, 6 injured (State Dept)
    - 4 Mar Dizengoff: 20 killed, 75 wounded (State Dept)
    - State Dept total 65 incl. three US citizens
    - 29 world leaders at Sharm summit (State Dept)

**[S388]** UNESCO World Heritage Centre, 'White City of Tel-Aviv – the Modern Movement' (inscribed 2003) — https://whc.unesco.org/en/list/1096 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Tel Aviv's White City, a concentration of Modern Movement (Bauhaus/International Style) buildings from the 1930s–1950s, inscribed on the World Heritage List in 2003
    - Note: page returned HTTP 403 to automated fetch; listing number and year from UNESCO list
    - UNESCO inscribed 'White City of Tel-Aviv – the Modern Movement' on the World Heritage List in 2003 (place tel_aviv)
    - Buildings from the 1930s to the 1950s
    - A concentration of Bauhaus and International Style buildings

**[S400]** Center for Israel Education (IsraelEd), "June 14, 2009: Netanyahu speech on a demilitarized Palestinian state", israeled.org — https://israeled.org/netanyahu-speech-demilitarized-palestinian-state — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Netanyahu's Bar-Ilan University policy speech, 14 June 2009
    - Conditional acceptance of a demilitarized Palestinian state, recognition of Israel as Jewish state demanded
    - Palestinian negotiator Saeb Erekat rejected the speech
    - Date 14 June 2009; place Bar-Ilan University
    - Netanyahu accepted a demilitarized Palestinian state
    - Conditional on recognition of Israel as the Jewish state and security guarantees
    - Accepted a Palestinian state 'for the first time'

**[S401]** RETIRED (no longer cited) — ABC News, "Israel Offers 10-Month Settlement Freeze", 25 Nov 2009 — https://abcnews.go.com/International/israel-offers-10-month-settlement-freeze/story?id=9173847

**[S402]** NBC News / Associated Press, "Settlement freeze has barely slowed construction", Sept 2010 — https://www.nbcnews.com/news/amp/wbna39332756 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Moratorium formally ended 26 Sept 2010
    - Housing units under construction fell from 2,955 (end 2009) to 2,517 (early 2010)
    - Palestinians threatened to quit direct talks if it ended
    - Excluding East Jerusalem
    - Excluding projects already under way
    - Moratorium expired 26 Sept 2010
    - Choice (non-historical): reject any freeze — position of settler leaders who protested the halt

**[S403]** Noble Energy Inc., Annual Report (Form 10-K) for fiscal year 2010, U.S. Securities and Exchange Commission, 2011 — https://www.sec.gov/Archives/edgar/data/0000072207/000114036111007888/form10k.htm — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Tamar gas field discovered offshore Israel in 2009
    - Leviathan discovery announced December 2010, largest in Noble's history
    - One of the largest offshore finds of the decade
    - Date: Noble announced Leviathan in December 2010 (event 2010-12-29, month precision)
    - Largest discovery in Noble's history
    - Off Israel's coast (place tag haifa)

**[S404]** Times of Israel, "Natural gas from Tamar field reaches Israel", 30 Mar 2013 — https://www.timesofisrael.com/natural-gas-from-tamar-field-reaches-israel/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Tamar gas began flowing to Israel in 2013
    - Gas from Tamar reached Israel in March 2013
    - Roughly double the size of Tamar by contemporary estimates (Leviathan 16-18 Tcf vs Tamar 8.5 Tcf, ToI 31 Mar 2013)
    - Tamar size for comparison
    - The two fields turned Israel into a prospective gas exporter

**[S405]** Al Jazeera, "Turkey downgrades ties with Israel", 2 Sept 2011 — https://www.aljazeera.com/news/2011/9/2/turkey-downgrades-ties-with-israel — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israeli commandos boarded the Mavi Marmara 31 May 2010; nine activists killed (eight Turkish nationals, one Turkish-American)
    - UN Palmer report: blockade lawful, force 'excessive and unreasonable'
    - Turkey expelled Israeli ambassador / downgraded ties Sept 2011
    - Date 31 May 2010, Mavi Marmara boarded by Israeli commandos
    - Nine activists killed: eight Turkish nationals and a Turkish-American
    - UN Palmer inquiry (2011) found the blockade lawful
    - Palmer inquiry found Israel's force 'excessive and unreasonable'
    - Turkey downgraded relations (Sept 2011)
    - Eight Turkish nationals and a Turkish-American died

**[S406]** JTA, "Monument to Carmel fire victims unveiled at memorial", 19 Dec 2011; Israel Hayom, "Israel marks 6 years since Carmel wildfire disaster", 2016 — https://www.jta.org/2011/12/19/israel/monument-to-carmel-fire-victims-unveiled-at-memorial — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Mount Carmel forest fire began 2 Dec 2010; 44 killed, most of them Israel Prison Service cadets on a bus sent to evacuate a prison
    - More than 17,000 evacuated; c. 50,000 dunams burned
    - Led to creation of an aerial firefighting squadron
    - Date: fire trapped bus 2 Dec 2010; burned about four days (to 5 Dec)
    - 44 people killed
    - Most of them Israel Prison Service cadets whose bus was trapped en route to evacuate a prison
    - Victims included firefighters
    - 44 killed
    - Thirty-six cadets, a commander and a driver died in the bus

**[S407]** JTA, "Hundreds of thousands of Israelis demonstrate for social justice", 4 Sept 2011 — https://www.jta.org/2011/09/04/lifestyle/hundreds-of-thousands-of-israelis-demonstrate-for-social-justice — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 3 Sept 2011 'March of the Million' rallies; estimates 400,000-500,000 participants
    - Protest began with tents on Rothschild Boulevard, Tel Aviv (Daphni Leef), July 2011
    - Government set up Trajtenberg committee on cost of living
    - Tents on Tel Aviv's Rothschild Boulevard over housing costs
    - Protest was over housing costs
    - Peak 3 Sept 2011 with an estimated 400,000-500,000 nationwide (JTA 4 Sept 2011)
    - Largest demonstrations in Israel's history
    - Places: Tel Aviv (300,000), Jerusalem, Haifa
    - Government formed the Trajtenberg committee on the cost of living
    - Choice (historical): appoint Trajtenberg expert committee, August 2011

**[S408]** Ynet, "Iron Dome intercepts first rocket", 7 Apr 2011; Britannica, "Iron Dome" — https://www.ynetnews.com/article/4053837 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - First operational Iron Dome interception, a Grad rocket fired from Gaza toward Ashkelon, 7 Apr 2011
    - Date 7 April 2011: Iron Dome's first combat interception
    - Grad rocket fired from Gaza toward Ashkelon
    - System deployed days earlier near Ashkelon and Beersheba
    - Ashkelon battery deployed days earlier
    - First operational interception of a short-range rocket

**[S409]** Al Jazeera, "Hamas and Israel exchange prisoners", 18 Oct 2011 — https://www.aljazeera.com/news/2011/10/18/hamas-and-israel-exchange-prisoners — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Gilad Shalit, held in Gaza since June 2006, released 18 Oct 2011 via Egypt
    - Israel to release 1,027 Palestinian prisoners (477 on 18 Oct, 550 in December), many convicted of deadly attacks
    - Deal mediated by Egypt (and Germany), signed 11 Oct 2011
    - Date 18 Oct 2011: Shalit released
    - Released via Egypt (places: gaza_strip, rafah)
    - Captured in a cross-border raid from Gaza in June 2006; more than five years in Hamas captivity
    - Israel released 1,027 Palestinian prisoners
    - 477 released on 18 October

**[S410]** RETIRED (no longer cited) — NobelPrize.org, "The Nobel Prize in Chemistry 2011" (summary and press release), Nobel Prize Outreach — https://www.nobelprize.org/prizes/chemistry/2011/summary/

**[S411]** RETIRED (no longer cited) — NobelPrize.org, "The Nobel Prize in Chemistry 2013" (summary and press release), Nobel Prize Outreach — https://www.nobelprize.org/prizes/chemistry/2013/summary/

**[S412]** RETIRED (no longer cited) — B'Tselem, "Gaza Strip: Operation Pillar of Defense, November 2012" — https://www.btselem.org/gaza_strip/gaza_nov_2012_operation

**[S413]** JTA, "Operation Pillar of Defense: lessons learned", 21 Nov 2012 — https://www.jta.org/2012/11/21/israel/operation-pillar-of-defense-lessons-learned — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Operation began 14 Nov 2012 with killing of Hamas military chief Ahmed Jabari; ceasefire 21 Nov
    - Five or six Israelis killed (sources differ), most of them civilians
    - Iron Dome used extensively
    - Used extensively in later Gaza conflicts (e.g. Nov 2012: IDF said Iron Dome downed 421 rockets)
    - Many intercepted by Iron Dome (IDF: 421)
    - Ceasefire brokered by Egypt

**[S414]** RETIRED (no longer cited) — Jewish Virtual Library, "UN General Assembly Resolution 67/19" (text and vote), 29 Nov 2012 — https://www.jewishvirtuallibrary.org/un-general-assembly-resolution-67-19-november-2012

**[S415]** RETIRED (no longer cited) — Inter-Parliamentary Union, Parline: Israel Knesset election 17 March 2015; Israel MFA, "Israel votes 17 March 2015" — https://data.ipu.org/parliament/IL/IL-LC01/election/IL-LC01-E20150317

**[S416]** Ynet, "Polls: Netanyahu reelected, Lapid surprises with 19 mandates", 22 Jan 2013; Wikipedia used only as a pointer — https://www.ynet.co.il/articles/mobile/0,7340,L-4335746,00.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 22 Jan 2013 election: Likud-Yisrael Beiteinu joint list 31 seats; Yesh Atid (Yair Lapid) 19 seats
    - Date 22 Jan 2013: election to the 19th Knesset
    - Likud-Yisrael Beiteinu won 31 seats (NOTE: opened source gives exit-poll projection of 22 Jan 2013; official CEC/Knesset results pages could not be opened)
    - Yesh Atid (Yair Lapid, new party) second with 19 seats (exit-poll projection in opened source)

**[S417]** UN OCHA oPt, "Key figures on the 2014 hostilities"; UN Independent Commission of Inquiry on the 2014 Gaza Conflict, report of 22 June 2015 (A/HRC/29/52) — https://www.ochaopt.org/content/key-figures-2014-hostilities — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 8 Jul-26 Aug 2014 (51 days)
    - UN COI: 2,251 Palestinians killed incl. 1,462 civilians (551 children, 299 women)
    - 67 IDF soldiers and 6 civilians in Israel killed; up to 1,600 Israelis injured
    - Figures from UN, Israel, Palestinian authorities and NGOs differ
    - 'A 51-day war'
    - UN Commission of Inquiry: 2,251 Palestinians killed, 1,462 civilians, 551 children (COI report June 2015)
    - 67 Israeli soldiers and 6 civilians in Israel killed
    - Neutrality: summary omits displacement in Gaza
    - COI: 2,251 Palestinians killed incl. 1,462 civilians
    - 11,231 Palestinians injured
    - About 500,000 displaced at the height of hostilities
    - 18,000 housing units destroyed or damaged
    - Six civilians in Israel and 67 soldiers killed
    - Up to 1,600 Israelis injured
    - 4,881 rockets and 1,753 mortars fired toward Israel
    - IDF found 32 tunnels, 14 extending into Israel

**[S418]** Jewish Virtual Library, "Operation Protective Edge: Kidnappings" — https://www.jewishvirtuallibrary.org/operation-protective-edge-kidnappings — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Eyal Yifrach, Gilad Shaer and Naftali Fraenkel kidnapped near Alon Shvut/Gush Etzion 12 June 2014; bodies found 30 June near Hebron
    - Mohammed Abu Khdeir, 16, abducted and burned to death by Israeli Jews in Jerusalem 2 July 2014; perpetrators convicted
    - Names Eyal Yifrach, Gilad Shaer, Naftali Fraenkel
    - Killed by Hamas members
    - Large West Bank search and arrest operation
    - Abu Khdeir was burned to death
    - Killed by Israeli Jews, later convicted
    - Unrest and rocket fire escalated toward the July Gaza war
    - Search operation left eight dead (two of heart attacks), 120 wounded, 566 arrested
    - Three teens killed; Hamas claimed responsibility
    - Abu Khdeir burned alive; killed by Jewish extremists

**[S419]** Egyptian Streets, "Knife intifada in numbers: dozens killed, hundreds displaced in Palestine-Israel", 14 Mar 2016 (citing Israel MFA figures) — https://egyptianstreets.com/2016/03/14/knife-intifada-in-numbers-dozens-killed-hundreds-displaced-in-palestine-israel/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Oct 2015-Mar 2016: c. 203 stabbing/attempted stabbings, 82 shootings, 41 car rammings; 34 killed by Palestinian attackers (Israel MFA)
    - Around 200 Palestinians killed by Israeli forces in the same period, many while carrying out or allegedly carrying out attacks
    - Wave began in October 2015 (date 2015-10-01, month precision)
    - By March 2016 Israel's foreign ministry counted 34 people killed (MFA figures as of 9 Mar 2016)
    - Some 200 stabbings (MFA, as of March 2016)
    - 82 shootings and 41 rammings (MFA, as of March 2016)
    - Around 200 Palestinians killed in the same period (as of mid-March 2016)
    - Many Palestinians killed while carrying out or allegedly carrying out attacks
    - Neutrality: displacement of Palestinians by home demolitions in the same period not mentioned
    - Injured: summary omits injuries to Israelis
    - 34 killed and 394 injured by Palestinian attackers
    - 191 Palestinians killed incl. 42 minors (Middle East Monitor)
    - 104 attackers killed
    - 400 Palestinians displaced by home demolitions in early 2016

**[S420]** RETIRED (no longer cited) — Rethinking Foreign Policy, "Understanding the UN settlements resolution", 27 Dec 2016 (summarising UNSC S/RES/2334) — https://rethinkingforeignpolicy.org/2016/12/27/understanding-the-un-settlements-resolution/

**[S421]** TechCrunch, "Intel buys Mobileye in $15.3B deal, moves its automotive unit to Israel", 13 Mar 2017 — https://techcrunch.com/2017/03/13/reports-intel-buying-mobileye-for-up-to-16b-to-expand-in-self-driving-tech — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Intel agreed 13 Mar 2017 to buy Mobileye for ~$15.3bn equity value ($63.54/share), the largest acquisition of an Israeli tech company
    - Date 2017-03-13: Intel agreed to acquire Mobileye
    - About $15.3 billion in equity value
    - Largest acquisition of an Israeli technology company to that date
    - Intel moved its automotive unit to Israel

**[S422]** Military.com (Associated Press), "Trump Officially Recognizes Jerusalem as Israel's Capital", 6 Dec 2017 — https://www.military.com/daily-news/2017/12/06/trump-officially-recognizes-jerusalem-israels-capital.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - US President Trump recognized Jerusalem as Israel's capital 6 Dec 2017 and ordered embassy move
    - Arab and European leaders warned of violence; Palestinians cut ties with administration
    - Palestinian warning (Abbas)

**[S423]** RETIRED (no longer cited) — The Gazette (Associated Press), "Deadly Gaza protests cloud US Embassy opening in Jerusalem", 14 May 2018 — https://gazette.com/2018/05/14/deadly-gaza-protests-cloud-us-embassy-opening-in-jerusalem-b22377b4-3944-5890-b830-a7b4bbaf960e/

**[S424]** UN OCHA oPt, "Overview: March 2019" — https://www.ochaopt.org/content/overview-march-2019 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - From start of 'Great March of Return' (30 Mar 2018) to 31 Mar 2019, 199 Palestinians incl. 43 children killed by Israeli forces in the protest context
    - OCHA: 199 Palestinians killed by 31 Mar 2019
    - Neutrality: Palestinian injuries omitted
    - OCHA: 199 killed, ~30,300 injured by 31 Mar 2019

**[S425]** RETIRED (no longer cited) — JURIST, "UN finds Israel may have committed crimes against humanity during Gaza protests", Feb 2019 (UN Commission of Inquiry on the 2018 protests) — https://www.jurist.org/news/2019/02/un-finds-israel-may-have-committed-crimes-against-humanity-during-gaza-protests

**[S426]** RETIRED (no longer cited) — Jewish Press, "Basic Law: Israel as the Nation-State of the Jewish People approved by Knesset 62-55", 19 July 2018; AJC statement 18 July 2018 — https://www.jewishpress.com/news/israel/the-knesset/basic-law-israel-as-the-nation-state-of-the-jewish-people-approved-by-knesset-62-55/2018/07/19

**[S427]** RETIRED (no longer cited) — CBC News, "Israel's Netta Barzilai wins Eurovision 2018", 12 May 2018 — https://www.cbc.ca/news/entertainment/eurovision-song-contest-2018-portugal-1.4660776

**[S428]** MIT Technology Review, "Israel's lunar lander has crashed into the moon", 11 Apr 2019 — https://www.technologyreview.com/the-download/613306/israels-lunar-lander-has-crashed-into-the-moon/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - SpaceIL/IAI Beresheet lander crashed during landing attempt 11 Apr 2019 after main-engine failure
    - First privately funded lunar landing attempt; Israel's first lunar mission
    - Crashed during descent after a main-engine failure
    - XPRIZE nonetheless awarded the team $1 million
    - Place: 'abroad' (the Moon) — mission controlled from Israel

**[S429]** Times of Israel, "Full election results: No party except Likud and Blue and White won more than 6%" (April 2019) and "Checked and double-checked: elections committee publishes final results" (Sept 2019) — https://www.timesofisrael.com/4335320-ballots-cast-who-got-what/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 9 Apr 2019: Likud and Blue and White each 35 seats; Netanyahu failed to form a coalition and Knesset dissolved
    - 17 Sept 2019: Blue and White 33, Likud 32
    - Election date 2019-04-09
    - Blue and White (led by Benny Gantz) won 35 seats

**[S430]** Jewish Virtual Library, "Israeli Electoral History: 2020 Election to the 23rd Knesset"; IFES ElectionGuide — https://www.jewishvirtuallibrary.org/israeli-electoral-history-2010-elections-to-the-23rd-knesset — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 2 Mar 2020: Likud 36, Blue and White 33, Joint List 15
    - Date: election held 2 March 2020, the third within a year
    - Joint List won 15 seats (cross-check)

**[S431]** Globes, "Netanyahu, Gantz agree unity government", Apr 2020; Israel Hayom, "Knesset edges closer to dissolution after Gantz sides with opposition", 1 Dec 2020 — https://en.globes.co.il/en/article-netanyahu-gantz-agree-unity-government-1001325957 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Netanyahu-Gantz unity government with rotation after 18 months
    - Government collapsed over the budget; Knesset dissolved Dec 2020; election set for 23 Mar 2021
    - Date: Netanyahu and Gantz signed the unity agreement on 20 April 2020
    - Rotation of the premiership after 18 months
    - Gantz as defence minister

**[S432]** Ynet, "AG indicts Netanyahu for bribery, fraud and breach of trust", 21 Nov 2019; Globes, "Netanyahu trial begins", 24 May 2020 — https://www.ynetnews.com/article/5629718 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - AG Avichai Mandelblit announced indictment 21 Nov 2019 in Cases 1000, 2000 (fraud, breach of trust) and 4000 (bribery)
    - First sitting Israeli PM to face criminal trial; trial opened 24 May 2020 in Jerusalem District Court
    - Date: indictment announced 21 Nov 2019 (a Thursday)
    - Attorney General Avichai Mandelblit announced the charges
    - Fraud and breach of trust in Cases 1000 and 2000
    - Bribery in Case 4000
    - Case 4000: favourable regulation for Bezeq in exchange for coverage on Walla
    - Netanyahu denied wrongdoing

**[S433]** RETIRED (no longer cited) — GlobalSecurity.org (Sputnik), "Coalitions Fail to Secure Majority in Israel's Parliamentary Elections - Final Ballot", 25 Mar 2021 — https://www.globalsecurity.org/wmd/library/news/israel/2021/israel-210325-sputnik01.htm

**[S434]** Gulf News, "Israel confirms first coronavirus case in cruise ship returnee", 21 Feb 2020; Deccan Herald (AP), "Israel to inoculate a quarter of its population within month: PM", Dec 2020 — https://gulfnews.com/world/mena/israel-confirms-first-coronavirus-case-in-cruise-ship-returnee-1.1582291738259 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - First Israeli COVID-19 case 21 Feb 2020, a Diamond Princess returnee
    - Distancing rules from 11 Mar 2020; borders sealed and lockdowns in spring 2020
    - Vaccination campaign began 20 Dec 2020 with Pfizer and Moderna doses
    - Date: Israel confirmed its first COVID-19 case on 21 Feb 2020
    - First case was a passenger returning from the Diamond Princess cruise ship

**[S435]** RETIRED (no longer cited) — Middle East Institute, "The Abraham Accords" (explainer); Arab News, "Arab, Israeli signatories celebrate first anniversary of Abraham Accords", Sept 2021 — https://www.mei.edu/publications/abraham-accords

**[S436]** JNS, "Meron commission holds Israeli officials responsible", 6 Mar 2024 — https://www.jns.org/meron-commission-holds-israeli-officials-responsible/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 45 people crushed to death, c. 150 injured at Mount Meron Lag BaOmer pilgrimage 30 Apr 2021
    - State commission (Mar 2024) held Netanyahu and 15 other officials personally responsible; recommended police chief Shabtai's removal
    - Date: 30 April 2021, during the Lag BaOmer pilgrimage at Mount Meron
    - About 150 injured
    - Israel's deadliest civilian disaster
    - Recommended removing the police chief
    - 45 crushed to death, 150 injured, 20 critically
    - Commission found Netanyahu personally responsible
    - Also blamed Shabtai, Ohana and other officials
    - Recommended Shabtai step down

**[S437]** UN OCHA oPt, "Response to the escalation in the oPt, Situation Report No. 10 (September 2021)" — https://www.ochaopt.org/content/response-escalation-opt-situation-report-no-10-september-2021 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 10-21 May 2021 escalation: 261 Palestinians killed incl. 67 children (OHCHR); c. 2,210 injured
    - 13 people in Israel, incl. one soldier, killed by rocket fire
    - Ceasefire took effect 21 May 2021
    - OHCHR/OCHA counted 261 Palestinians killed in Gaza, including 67 children (as of Sept 2021)
    - Civilian/combatant breakdown of Palestinian dead (not stated in summary)
    - 13 people in Israel, including one soldier, were killed by rocket fire
    - Neutrality: displacement and injuries in Gaza omitted
    - 261 Palestinians killed incl. 67 children (OHCHR)
    - 130 civilians, 64 armed-group members, 67 undetermined
    - Over 2,210 Palestinians injured
    - 113,000 IDPs at the height of the escalation
    - 13 people in Israel incl. one soldier killed

**[S438]** J. The Jewish News of Northern California (JTA), "Death toll rises to 6 Israelis, 55 Palestinians in escalating fighting while Arab protesters torch synagogue", 12 May 2021 — https://jweekly.com/2021/05/12/death-toll-rises-to-6-israelis-55-palestinians-in-escalating-fighting-while-arab-protesters-torch-synagogue/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - State of emergency declared in Lod after synagogue, shops and cars burned
    - Arab Israeli man shot dead in Lod, allegedly by a Jewish Israeli
    - Unrest in other mixed cities incl. Haifa
    - Hamas fired >1,000 rockets in first days
    - Following weeks of tension and clashes in Jerusalem
    - In Lod Arab rioters burned a synagogue, shops and cars
    - Unrest and protests also spread to other cities including Haifa

**[S439]** Globes, "Naftali Bennett sworn in as Israel's 13th Prime Minister", 13 June 2021 — https://en.globes.co.il/en/article-naftali-bennett-sworn-in-as-israels-13th-prime-minister-1001374311 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Knesset approved Bennett-Lapid government 60-59 on 13 June 2021, ending 12 years of Netanyahu rule
    - Coalition included Ra'am (United Arab List), first Arab party in a governing coalition
    - Rotation: Lapid to become PM
    - Date: Knesset approved the government 13 June 2021
    - Bennett PM under a rotation agreement with Lapid

**[S440]** RETIRED (no longer cited) — Times of Israel, "Lebanon, Israel set to sign maritime deal Thursday, US envoy confirms", Oct 2022; AP via News4Jax, "Lebanon delivers signed sea border deal to US mediator", 27 Oct 2022 — https://www.timesofisrael.com/lebanon-israel-set-to-sign-maritime-deal-thursday-us-envoy-confirms/

**[S441]** JNS, "Decisive victory: Netanyahu's bloc secures 64 mandates", Nov 2022 — https://www.jns.org/decisive-victory-netanyahus-bloc-secures-64-mandates/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 1 Nov 2022 election: Likud 32, Religious Zionism 14; Netanyahu bloc 64 of 120
    - Meretz and Balad fell below 3.25% threshold
    - Likud won 32 seats
    - Religious Zionism list won 14
    - With the Haredi parties Netanyahu's bloc took 64 of 120 seats

**[S442]** PBS NewsHour (AP), "Netanyahu fires Israel's defense minister for urging halt to judicial overhaul", 26 Mar 2023; Al-Monitor, "General strike in Israel, Netanyahu under pressure to freeze judicial overhaul", 27 Mar 2023 — https://www.pbs.org/newshour/world/netanyahu-fires-israels-defense-minister-for-urging-halt-to-judicial-overhaul — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Justice Minister Yariv Levin spearheaded the judicial overhaul
    - Netanyahu dismissed Defense Minister Yoav Gallant 26 Mar 2023 after he urged a pause
    - Mass protests and general strike; Netanyahu paused the legislation 27 Mar 2023; Gallant's dismissal was later not carried out
    - Justice Minister Yariv Levin's plan
    - Plan to curb the Supreme Court and change judicial appointments
    - Warnings from reservists
    - Warnings from security chiefs
    - Gallant urged a pause and Netanyahu fired him on 26 March 2023

**[S443]** RETIRED (no longer cited) — Times of Israel, "In historic ruling, High Court strikes down key judicial overhaul legislation", 1 Jan 2024 — https://www.timesofisrael.com/in-historic-ruling-high-court-strikes-down-key-judicial-overhaul-legislation/

**[S444]** Times of Israel, "After endless delays, first Tel Aviv light rail line set to open August 18", 2023; JNS, "Tel Aviv light rail to open to the public Friday" — https://www.timesofisrael.com/after-endless-delays-first-tel-aviv-light-rail-line-set-to-open-august-18/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Red Line, first Tel Aviv light-rail line, 24 km Petah Tikva-Bat Yam via Bnei Brak, Ramat Gan and Tel Aviv, opened 18 Aug 2023 after delays (planned Oct 2021)
    - After years of delays
    - 24 km route from Petah Tikva to Bat Yam

**[S445]** RETIRED (no longer cited) — European Investment Bank, "Sorek alleviates Israel's water shortage", Jan 2015; Times of Israel, "Israel rides out drought with desalination" — https://eib.org/en/infocentre/stories/all/2015-january-01/sorek-alleviates-israels-water-shortage.htm

**[S446]** Globes, "Jerusalem - Tel Aviv fast rail link finally begins operations"; Times of Israel, "Jerusalem's new high-speed train starts regular trips to Ben Gurion Airport", Sept 2018 — https://en.globes.co.il/en/article-jerusalem-tel-aviv-fast-rail-link-finally-begins-operations-1001311940 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Electrified Jerusalem (Yitzhak Navon station, c. 80 m underground)-Ben Gurion Airport line began service 25 Sept 2018
    - Through service to Tel Aviv HaHagana followed in December 2019; journey c. 32 minutes
    - Through trains to Tel Aviv followed in December 2019
    - Journey to Tel Aviv about 32 minutes

**[S447]** Times of Israel, "Yair Lapid takes over as Israel's 14th prime minister", 1 July 2022 — https://www.timesofisrael.com/yair-lapid-takes-over-as-israels-14th-prime-minister/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Lapid became prime minister at midnight 30 June-1 July 2022, heading a caretaker government
    - Elections set for 1 November 2022
    - Coalition announced in June 2022 it would fall
    - Lapid became caretaker PM on 1 July 2022 ahead of elections on 1 November

**[S448]** NPR, "Israel revises down its death toll from the Oct. 7 Hamas attacks to about 1,200", 11 Nov 2023 — https://www.npr.org/2023/11/11/1212458974/israel-revises-down-its-death-toll-hamas-attacks-oct-7 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel MFA revised the 7 Oct 2023 death toll from 1,400 to 'around 1,200'

**[S450]** RETIRED (no longer cited) — ABC15 / Associated Press, "Israel orders the evacuation of 1.1 million people from northern part of Gaza, the UN says", 13 Oct 2023 — https://www.abc15.com/news/national/israel-orders-the-evacuation-of-1-1-million-people-from-northern-part-of-gaza-the-un-says

**[S453]** RETIRED (no longer cited) — Times of Israel, "Six months of war: IDF data shows 604 soldiers killed, more than 9,000 rockets fired by Hamas", 7 Apr 2024 — https://www.timesofisrael.com/liveblog_entry/six-months-of-war-idf-data-shows-604-soldiers-killed-more-than-9000-rockets-fired-by-hamas/

**[S455]** RETIRED (no longer cited) — TPS Israel News, "As Lebanon ground war looms, Israel says 68,000 northern residents displaced from homes", Sept 2024 — https://tps.co.il/articles/as-lebanon-ground-war-looms-israel-says-68000-northern-residents-displaced-from-homes/

**[S456]** RETIRED (no longer cited) — Al Jazeera, "How many people has Israel killed in Lebanon since the ceasefire?", 28 Jan 2025 — https://www.aljazeera.com/news/2025/1/28/how-many-people-has-israel-killed-in-lebanon-since-the-ceasefire

**[S457]** RETIRED (no longer cited) — UN (UNISPAL), ICJ press release: "Application of the Genocide Convention in the Gaza Strip (South Africa v. Israel) - The Court indicates provisional measures", 26 Jan 2024 — https://un.org/unispal/document/application-of-the-convention-on-the-prevention-and-punishment-of-the-crime-of-genocide-in-the-gaza-strip-south-africa-v-israel-the-court-indicates-provisional-measures-icj-press-release-26jan2024

**[S458]** RETIRED (no longer cited) — The National (UAE), "Israel attacks Isfahan military base in Iran", 19 Apr 2024 — https://www.thenationalnews.com/news/mena/2024/04/19/israel-attacks-isfahan-military-base-in-iran/

**[S459]** Al Jazeera, "Hezbollah says top commander Fuad Shukr killed in Israel strike on Beirut", 31 Jul 2024; Arab News, 31 Jul 2024 — https://www.aljazeera.com/news/2024/7/31/hezbollahsays-top-commander-fuad-shukr-killed-in-israel-strike-on-beirut — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Rocket hit football pitch in Druze town of Majdal Shams 27 Jul 2024, killing 12 children and youths; Israel blamed Hezbollah, which denied it
    - Israeli strike in Beirut's Haret Hreik 30 Jul 2024 killed Fuad Shukr and civilians incl. two children
    - Hamas political leader Ismail Haniyeh killed in Tehran 31 Jul 2024
    - Date: 27 July 2024
    - Killed 12 children and youths
    - On 30 July an Israeli strike in Beirut killed Fuad Shukr along with civilians
    - Neutrality: number of civilians killed in the Beirut strike not stated
    - On 31 July Hamas political leader Ismail Haniyeh was killed in Tehran
    - Beirut strike: three killed incl. two children, 74 wounded (Lebanese health ministry)
    - Israel said Shukr was responsible for the Majdal Shams strike
    - Haniyeh killed in Tehran

**[S460]** RETIRED (no longer cited) — The Tribune (India), "Day after walkie-talkies explode in Lebanon, 14 killed, over 450 injured", 19 Sept 2024; NBC News, "More pager explosions in Lebanon", Sept 2024 — https://www.tribuneindia.com/news/world/day-after-walkie-talkies-explode-in-lebanon-14-killed-over-450-injured

**[S461]** RETIRED (no longer cited) — ABC News (Associated Press), "Israel's military says Hezbollah leader Hassan Nasrallah was killed in Beirut strike", 28 Sept 2024 — https://abcnews.go.com/US/wireStory/israels-military-hezbollah-leader-hassan-nasrallah-killed-beirut-114310407

**[S462]** RETIRED (no longer cited) — Foundation for Defense of Democracies, "Israel retaliates against Iran regime with precision strikes", 26 Oct 2024; Gulf News / Al-Monitor analysis, Nov 2024 — https://www.fdd.org/analysis/2024/10/26/israel-retaliates-against-iran-regime-with-precision-strikes/

**[S464]** RETIRED (no longer cited) — Africanews, "Ceasefire deal between Israel and Hezbollah comes into effect", 27 Nov 2024 — https://www.africanews.com/amp/2024/11/27/ceasefire-deal-between-israel-and-hezbollah-comes-into-effect/

**[S466]** Anadolu Agency, "Factbox: With Assad gone, Israel captures Syria buffer zone, ends border agreement", Dec 2024; Times of Israel, "Syria urges IDF withdrawal from buffer zone in talks with UN observers" — https://aa.com.tr/en/middle-east/factbox-with-assad-gone-israel-captures-syria-buffer-zone-ends-border-agreement/3418903 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Assad regime fell 8 Dec 2024; IDF entered the UN-monitored buffer zone and took the Syrian side of Mount Hermon
    - Netanyahu declared the 1974 disengagement agreement collapsed; UN said the advance violated it
    - Israel described the deployment as temporary; Defence Minister Katz later said troops would stay indefinitely
    - Date 8 December 2024: rebels took Damascus and Assad fled
    - Israel declared the 1974 disengagement agreement collapsed
    - Troops moved into the UN-monitored buffer zone
    - Took the Syrian side of Mount Hermon
    - Residents of five Syrian villages warned to remain in their homes
    - Villages named incl. Quneitra
    - 1974 agreement: Israel withdrew from about 25 km2 including Quneitra
    - Israeli army seized the demilitarized zone after Assad's ouster
    - Netanyahu announced collapse of the 1974 agreement
    - Anadolu (9 Dec 2024): Israeli army warned residents of Quneitra and four other villages amid its military actions
    - Anadolu: the 1974 disengagement area (the demilitarised zone Israel entered in Dec 2024) included Quneitra

**[S469]** RETIRED (no longer cited) — Times of Israel, "Medical officials say 28 people were killed, over 3,000 wounded by Iranian missiles during conflict", 24 June 2025 — https://www.timesofisrael.com/liveblog_entry/medical-officials-say-28-people-were-killed-over-3000-wounded-by-iranian-missiles-during-conflict/

**[S470]** RETIRED (no longer cited) — Al Jazeera, live blog "US joins Israel in attacking Iran, strikes Fordow, Isfahan, Natanz sites", 22 June 2025 — https://www.aljazeera.com/news/liveblog/2025/6/22/live-us-joins-israels-attacks-on-iran-bombs-three-nuclear-sites

**[S471]** RETIRED (no longer cited) — Associated Press, "Iran's government says at least 1,060 people were killed in the war with Israel", 8 July 2025 — https://apnews.com/article/iran-israel-war-death-toll-569128effa8aafd9d9bd04efe5c0de75

**[S474]** RETIRED (no longer cited) — Al Jazeera, "Israel-Palestine two-state solution summit to be held as recognitions surge", 22 Sept 2025 — https://www.aljazeera.com/news/2025/9/22/israel-palestine-two-state-solution-summit-to-be-held-as-recognitions-surge

**[S475]** RETIRED (no longer cited) — Times of Israel, "Trump, after securing deal: 'This is more than Gaza. This is peace in the Middle East'", 9 Oct 2025 — https://www.timesofisrael.com/trump-after-securing-deal-this-is-more-than-gaza-this-is-peace-in-the-middle-east/

**[S478]** RETIRED (no longer cited) — Times of Israel, "Israel's Noam Bettan finishes second at Eurovision as Bulgaria takes the win", 17 May 2026; Eurovision.tv, "Yuval Raphael will represent Israel in Basel", 22 Jan 2025 — https://www.timesofisrael.com/israels-noam-bettan-finishes-second-at-eurovision-as-bulgaria-takes-the-win/

**[S480]** Al Jazeera, "Israel headed for October election as parliament dissolved", 17 July 2026 — https://www.aljazeera.com/news/2026/7/17/israel-headed-for-october-election-as-parliament-dissolved — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 25th Knesset dissolved 17 July 2026; election 27 Oct 2026
    - First Knesset to complete its full term since 1988
    - Netanyahu's coalition described as the most nationalist in Israel's history; trailing in polls behind opposition incl. Gadi Eisenkot's Yashar party
    - Date: 25th Knesset dissolved 17 July 2026
    - Final session passed a package of contested laws
    - First Knesset to serve its full term since 1988
    - Elections set for 27 October 2026
    - Coalition trailing; opposition led in polls by Gadi Eisenkot's party
    - Coalition later widely described as the most nationalist in Israel's history

**[S481]** RETIRED (no longer cited) — Library of Congress, In Custodia Legis, "FALQs: Israel's Upcoming Election on October 27, 2026", Oct 2026 — https://blogs.loc.gov/law/2026/10/falqs-israels-upcoming-election-on-october-27-2026/

**[S482]** RETIRED (no longer cited) — Council on Foreign Relations, Global Conflict Tracker, "Confrontation Between the United States and Iran" (updated Sept-Oct 2026) — https://www.cfr.org/global-conflict-tracker/conflict/confrontation-between-united-states-and-iran

**[S483]** RETIRED (no longer cited) — Times of Israel, "US and Israel launch major joint assault on Iran; Trump indicates goal is to topple regime", 28 Feb 2026 — https://www.timesofisrael.com/us-and-israel-launch-major-joint-assault-on-iran-trump-indicates-goal-is-to-topple-regime/

**[S484]** RETIRED (no longer cited) — Times of Israel, "650 Iranian missiles fired, 24 killed and 10,800 Israeli strikes: The war in numbers", 10 Apr 2026 — https://www.timesofisrael.com/650-iranian-missiles-fired-24-killed-and-10800-israeli-strikes-the-war-in-numbers/

**[S485]** RETIRED (no longer cited) — Al Jazeera, "At least nine killed after Iranian strike on Israel's Beit Shemesh", 1 Mar 2026 — https://www.aljazeera.com/news/2026/3/1/at-least-nine-killed-after-iranian-strike-on-israels-beit-shemesh

**[S486]** RETIRED (no longer cited) — Al Jazeera, "How Israel's invasion of southern Lebanon created a humanitarian crisis", 7 Apr 2026 — https://www.aljazeera.com/news/2026/4/7/how-israels-invasion-of-southern-lebanon-created-a-humanitarian-crisis

**[S487]** RETIRED (no longer cited) — Al Jazeera, "Israel-Lebanon direct talks in the US: All to know", 14 Apr 2026 — https://www.aljazeera.com/news/2026/4/14/israel-lebanon-direct-talks-in-the-us-all-to-know

**[S488]** RETIRED (no longer cited) — Times of Israel, liveblog "US announces 45-day extension of porous Lebanon ceasefire after 3rd round of Beirut-J'lem talks", 15 May 2026 — https://www.timesofisrael.com/liveblog_entry/us-announces-45-day-extension-of-porous-lebanon-ceasefire-after-3rd-round-of-beirut-jlem-talks/

**[S490]** RETIRED (no longer cited) — Times of Israel, "Knesset passes contentious Basic Law declaring Torah study a constitutional value", 13 July 2026 — https://www.timesofisrael.com/knesset-passes-contentious-basic-law-declaring-torah-study-a-constitutional-value/

**[S491]** RETIRED (no longer cited) — Times of Israel, "Jerusalem Light Rail unveils largest extension in 15 years, with new 'Green Line'", 21 Aug 2026 — https://www.timesofisrael.com/jerusalem-light-rail-unveils-largest-extension-in-15-years-with-new-green-line/

**[S492]** RETIRED (no longer cited) — Times of Israel, liveblog "High Court lets Arab parties run in election, reversing Central Election Committee ban", 2 Oct 2026 — https://www.timesofisrael.com/liveblog_entry/high-court-lets-arab-parties-run-in-election-reversing-central-election-committee-ban/

**[S493]** RETIRED (no longer cited) — Times of Israel, "Arab, Jewish protesters turn out in record numbers for Tel Aviv anti-crime protest", 1 Feb 2026 — https://www.timesofisrael.com/arab-jewish-protesters-turn-out-in-record-numbers-for-tel-aviv-anti-crime-protest/

**[S495]** RETIRED (no longer cited) — BBC News, "Israel says it has retrieved remains of final Gaza hostage Ran Gvili", 26 Jan 2026 — https://www.bbc.com/news/articles/c5ydvz7nz4mo

**[S700]** Human Rights Watch, Off the Map: Land and Housing Rights Violations in Israel's Unrecognized Bedouin Villages, HRW, 30 Mar 2008 — https://www.hrw.org/report/2008/03/30/map/land-and-housing-rights-violations-israels-unrecognized-bedouin-villages — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - ~11,000 of 65,000-95,000 pre-1948 Negev Bedouin remained
    - 11 of 19 tribes moved into the Siyag under military rule
    - removal into Siyag completed by 1 April 1952
    - 39 unrecognized villages; no utilities
    - Israeli officials say they enforce zoning and building codes
    - About 11,000 of 65,000-95,000 Negev Bedouin remained after 1948
    - 11 of 19 tribes forcibly moved to the Siyag
    - Told the move was temporary
    - Military rule 1949-1966
    - Removal completed by 1 April 1952
    - Siyag location east and southeast of Beersheba
    - Land outside Siyag registered as state land
    - About 50 Jewish settlements built in early 1950s
    - Two-thirds of 1955 Siyag residents displaced from western Negev
    - 39 unrecognised villages (HRW 2008)
    - Israeli officials say they enforce zoning codes

**[S701]** Adalah (republished by FIDH), Adalah: The government's decision to cancel the Prawer Plan bill is a major achievement, FIDH, 17 Dec 2013 — https://www.fidh.org/en/region/north-africa-middle-east/israel-palestine/14402-adalah-the-government-s-decision-to-cancel-the-prawer-plan-bill-is-a-major — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Begin announced withdrawal of Prawer-Begin bill on 12 Dec 2013
    - 70,000 residents of unrecognized villages (Adalah)
    - 30 Nov 2013 protests in Hura and Haifa
    - Adalah demand to recognise villages
    - 70,000 residents of unrecognised villages (Adalah)
    - Protests in Hura and Haifa on 30 Nov 2013
    - Begin announced withdrawal on 12 Dec 2013
    - Adalah demand

**[S702]** Al Jazeera, Israel scraps plan to uproot Bedouin, Al Jazeera, 12 Dec 2013 — https://www.aljazeera.com/news/2013/12/12/israel-scraps-plan-to-uproot-bedouin — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Prawer-Begin bill shelved; Netanyahu approved
    - 40,000 Bedouin to be moved
    - government rationale: modernise, $340m
    - no majority in coalition
    - Move into government townships
    - Plan would evacuate 40,000 Bedouin
    - Official name of the bill
    - Government rationale and $340m budget
    - Rights groups: plan failed to recognise land claims
    - HRW criticism
    - No majority in coalition
    - Right-wing opposition in committee
    - Begin recommended shelving; Netanyahu approved

**[S703]** Adalah, Knesset approves forced displacement of Arab Bedouin (Prawer-Begin Bill first reading), Adalah, 25 Jun 2013 — https://www.adalah.org/en/content/view/8176 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Knesset first reading 43-40
    - government approved the bill
    - Adalah release dated June 2013
    - Government bill passed first reading 43-40

**[S704]** Alistair Dawber, 'This is our land': Protests at plan to remove Bedouins from ancestral villages, The Independent, 7 Aug 2013 — https://www.independent.co.uk/news/world/middle-east/this-is-our-land-protests-at-plan-to-remove-bedouins-from-ancestral-villages-8748966.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 40,000-70,000 estimate
    - approved by ministers
    - Israel's stated rationale: recognised villages with modern infrastructure
    - Estimates of 40,000-70,000
    - Israel's argument: recognised villages with modern infrastructure; approved by ministers

**[S705]** Harriet Sherwood, Bedouin's plight: 'We want to maintain our traditions. But it's a dream here', The Guardian, 3 Nov 2011 — https://www.theguardian.com/world/2011/nov/03/bedouin-plight-traditions-threat-israel — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Goldberg commission; Prawer committee proposals
    - demolition of 35 unrecognised villages proposed
    - Prawer committee to implement Goldberg recommendations; demolition of 35 unrecognised villages proposed
    - Plan proposed demolition of 35 unrecognised villages

**[S706]** The White House (Trump administration archive), Proclamation on Recognizing the Golan Heights as Part of the State of Israel, 25 Mar 2019 — https://trumpwhitehouse.archives.gov/presidential-actions/proclamation-recognizing-golan-heights-part-state-israel/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - US recognition of Golan as part of Israel, 25 Mar 2019
    - stated security rationale
    - Proclamation text
    - Date 25 March 2019
    - Stated rationale

**[S707]** Al Jazeera, Trump formally recognises Israeli sovereignty over Golan Heights, Al Jazeera, 25 Mar 2019 — https://www.aljazeera.com/news/2019/3/25/trump-formally-recognises-israeli-sovereignty-over-golan-heights — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - international non-recognition of 1981 annexation
    - UN: status unchanged; UNSC 1981 null and void
    - Syria, Turkey, Arab League, Qatar rejected
    - Netanyahu at White House
    - 1981 annexation never recognised internationally
    - UNSC 1981 null and void
    - UN: status has not changed
    - Syria condemned
    - Turkey rejected
    - Arab League rejected
    - Qatar rejected

**[S708]** The White House (Trump administration archive), Peace to Prosperity overview page — https://trumpwhitehouse.archives.gov/peacetoprosperity/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - plan title and framing
    - Plan title

**[S709]** The White House (Trump administration archive), President Donald J. Trump's Vision for Peace, Prosperity, and a Brighter Future for Israel and the Palestinian People, 28 Jan 2020 — https://trumpwhitehouse.archives.gov/briefings-statements/president-donald-j-trumps-vision-peace-prosperity-brighter-future-israel-palestinian-people/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - issued 28 Jan 2020
    - demilitarized Palestinian state
    - Jerusalem capital of Israel; Palestinian capital in East Jerusalem areas
    - Netanyahu and Gantz agreed to use it as basis
    - Issued 28 Jan 2020
    - Demilitarized Palestinian state
    - Jerusalem provisions

**[S710]** NPR, Trump Says His Mideast Peace Plan Provides A 'Realistic Two-State Solution', NPR, 28 Jan 2020 — https://www.npr.org/2020/01/28/800296507/white-house-to-unveil-mideast-peace-plan-despite-palestinian-rejection — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - plan allows Israel to declare sovereignty over settlements and Jordan Valley
    - Abbas: 'smack of the century'
    - Netanyahu agreed to negotiate on basis of plan
    - Sovereignty over settlements and Jordan Valley
    - Netanyahu agreed to negotiate

**[S711]** BBC News, Palestinians reject Trump's Middle East peace plan, BBC, 29 Jan 2020 — https://www.bbc.com/news/world-middle-east-51292865 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Abbas: Jerusalem 'not for sale'
    - Hamas rejected
    - three injured by live fire near Ramallah
    - PLO: 15% of historic Palestine
    - Abbas: Jerusalem not for sale
    - Day of rage protests on Wednesday
    - Three injured near Ramallah

**[S712]** BBC News, Netanyahu pledges to annex occupied Jordan Valley, BBC, 10 Sep 2019 — https://www.bbc.com/news/world-middle-east-49655226 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Netanyahu pledge to apply sovereignty over Jordan Valley and northern Dead Sea
    - BBC pledge report dated 10 Sep 2019
    - Netanyahu Sept 2019 Jordan Valley pledge
    - Jordan Valley pledge background
    - Netanyahu pledge

**[S713]** Oliver Holmes/Peter Beaumont, Netanyahu's annexation plan in disarray as Gantz calls for delay, The Guardian, 29 Jun 2020 — https://www.theguardian.com/world/2020/jun/29/netanyahus-annexation-plan-in-disarray-as-gantz-calls-for-delay — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 1 July 2020 target date
    - Gantz urged delay
    - UN, EU, Arab states opposed annexation
    - 1 July target; Gantz not sacred
    - International opposition
    - Jordan and Palestinian leadership regard annexation as illegal
    - UAE ambassador warning
    - 1 July plan
    - Gantz call for delay

**[S714]** The White House (Trump administration archive), Joint Statement of the United States, the State of Israel, and the United Arab Emirates, 13 Aug 2020 — https://trumpwhitehouse.archives.gov/briefings-statements/joint-statement-united-states-state-israel-united-arab-emirates/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel will suspend declaring sovereignty
    - full normalization agreed
    - Vision for Peace presented 28 Jan 2020
    - Full normalisation agreed
    - Suspension of sovereignty declaration
    - Date 13 Aug 2020
    - Suspension in joint statement

**[S715]** UN Security Council, Background: Resolution 2231 (2015), un.org — https://www.un.org/securitycouncil/content/2231/background — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - JCPOA concluded 14 Jul 2015 by E3/EU+3 and Iran
    - UNSC 2231 adopted unanimously 20 Jul 2015
    - Implementation Day 16 Jan 2016
    - sanctions re-applied 27 Sep 2025
    - JCPOA concluded 14 July 2015 by E3/EU+3 and Iran
    - UNSC 2231 adopted unanimously 20 July 2015
    - UN sanctions re-applied 27 Sep 2025

**[S716]** BBC News, Obama says Netanyahu's Iran speech contains 'nothing new', BBC, 3-4 Mar 2015 — https://www.bbc.co.uk/news/world-middle-east-31722493 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Netanyahu: deal could 'pave Iran's path to the bomb'
    - Speaker invited him without consulting White House
    - election two weeks away
    - Path to the bomb
    - Election in two weeks
    - Netanyahu campaigned against the deal

**[S717]** Voice of America, Obama: Nothing New in Netanyahu Speech, VOA, 3 Mar 2015 — https://www.voanews.com/a/nothing-new-netanyahu-speech-obama/2666542.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - speech date 3 Mar 2015
    - Boehner invitation; breach of protocol per White House
    - Obama: no viable alternatives
    - Date of speech
    - Invited by Boehner without consulting administration
    - White House: breach of protocol
    - Obama response

**[S718]** CNN Politics, Democrats skipping Netanyahu's speech (whip list), CNN, 26 Feb 2015 (updated 3 Mar 2015) — https://www.cnn.com/2015/02/26/politics/democrats-missing-netanyahu-whip-list — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - at least 50 House Democrats and 8 senators said they would not attend
    - Democrats skipped

**[S719]** The White House (Trump administration archive), President Donald J. Trump is Ending United States Participation in an Unacceptable Iran Deal, 8 May 2018 — https://trumpwhitehouse.archives.gov/briefings-statements/president-donald-j-trump-ending-united-states-participation-unacceptable-iran-deal/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - US terminates JCPOA participation, 8 May 2018
    - re-imposes sanctions on energy, petrochemical, financial sectors
    - US terminating participation; re-imposing sanctions
    - Date 8 May 2018
    - Targeted sectors
    - Worst deal quote

**[S720]** ynet, מהיר ולא חף מטעויות: הכביש ששינה את הרגלי הנסיעה של הישראלים (Highway 6 at 20), ynet, 5 Jun 2022 — https://www.ynet.co.il/news/article/bj11g7qidc — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Highway 6 opened 4 Aug 2002 (20th anniversary on 4 Aug 2022)
    - ~200 km length
    - periphery-to-centre aim; Modiin, Harish, Kiryat Gat
    - Opened 4 August 2002 (20th anniversary 4 Aug 2022)
    - Privately built and operated; first toll road (ynet article dated 5 June 2022)
    - Aim: connect periphery to centre
    - Population dispersal to Modiin, Harish, Kiryat Gat

**[S721]** TheMarker, כביש חוצה ישראל הוא כבר חלק מהנוף, TheMarker, 29 Sep 2010 — https://www.themarker.com/misc/2010-09-29/ty-article/0000017f-e14a-d38f-a57f-e75a1cf40000 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - central 87 km section opened in stages 2002 - Jan 2004
    - construction began Nov 1999
    - ~130,000 vehicles/day in 2010
    - Construction began Nov 1999
    - Central 87 km section opened in stages 2002-Jan 2004
    - About 130,000 vehicles a day (2010)

**[S722]** RETIRED (no longer cited) — Haaretz, Over 10 Million People Live in Israel, West Bank Settlements on 77th Independence Day, Haaretz, 29 Apr 2025 — https://www.haaretz.com/israel-news/2025-04-29/ty-article/.premium/over-10-million-citizens-live-in-israel-west-bank-settlements-on-77th-independence-day/00000196-814d-d099-a3d7-93edc5d90000

**[S723]** Eurovisionworld, Eurovision Song Contest 2019: Tel Aviv (event page) — https://eurovisionworld.com/eurovision/2019/event — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - dates 14/16/18 May 2019
    - Expo Tel Aviv Pavilion 2
    - 41 countries
    - hosts
    - Semi-final 1 date
    - Grand final date
    - Semi-final 2 date
    - Venue Expo Tel Aviv
    - Held after Netta's win

**[S724]** Eurovisionworld, Eurovision Song Contest 2019 results — https://eurovisionworld.com/eurovision/2019 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Netherlands won with 'Arcade', 498 points
    - Netherlands won
    - Eurovision 2019 held at Expo Tel Aviv, Israel, with Israel as host
    - Israel hosted the 2019 contest in Tel Aviv

**[S725]** Daniel Estrin, Eurovision 2019's Israel Location Draws Controversy, NPR, 19 May 2019 — https://www.npr.org/2019/05/19/724851322/eurovision-2019s-israel-location-draws-controversy — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - pro-Palestinian boycott calls; none of the contestants boycotted
    - Madonna dancers with Israeli and Palestinian flags
    - Hatari Palestinian flags
    - Palestinian alternative concert
    - Boycott calls; no contestant boycotted
    - Pro-Palestinian boycott and alternative concert
    - Madonna's flags

**[S726]** The Observer/Guardian, Madonna makes call for Israel-Palestine unity at Eurovision, 18 May 2019 — https://www.theguardian.com/music/2019/may/18/madonna-makes-call-for-israel-palestine-unity-at-eurovision — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Madonna performance with flags
    - Waters and Eno opposed staging in Israel
    - Madonna performance described

**[S727]** CNN, Iceland's Eurovision entry Hatari holds up Palestinian flag during contest, CNN, 18 May 2019 — https://www.cnn.com/2019/05/18/europe/iceland-eurovision-palestine-intl/index.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Hatari raised Palestinian flags
    - Waters, Eno, Loach, Leigh called for boycott
    - Celebrity boycott calls
    - Hatari flags

**[S728]** Amy Spiro, Madonna to perform at Eurovision in Tel Aviv, Jerusalem Post, 8 Apr 2019 — https://www.jpost.com/israel-news/culture/madonna-to-perform-at-eurovision-in-tel-aviv-586120 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Sylvan Adams to cover Madonna costs
    - Madonna costs covered by Sylvan Adams

**[S801]** Human Rights Watch, 'Civilians under Assault: Hezbollah's Rocket Attacks on Israel in the 2006 War', ch. 'Historical Background', August 2007 — https://www.hrw.org/reports/2007/iopt0807/9.htm — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Grapes of Wrath (11-27 April 1996): 154 Lebanese civilian deaths and 351 injured
    - No Israeli civilian deaths; 62 Israeli civilians injured (IDF figures)
    - Accountability 1993: some 120 Lebanese civilians killed, close to 500 injured, about 300,000 displaced
    - HRW 2007 restates the toll
    - No Israeli civilian deaths; 62 injured (IDF)
    - Operation 11-27 April; 154 deaths, 351 injured
    - Ceasefire Understanding of 26 April 1996

**[S803]** Michal Shmulovich, '24 years later, Israel acknowledges top-secret operation that killed Fatah terror chief', Times of Israel, 1 Nov 2012 — https://www.timesofisrael.com/israel-admits-to-top-secret-operation-that-killed-top-fatah-commander-abu-jihad-in-1988/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Abu Jihad killed at his home in Tunis in April 1988
    - Two bodyguards and the household gardener were also killed
    - Interview with commander Nahum Lev cleared by the military censor in 2012; Israel 'essentially confirmed' the operation
    - A bodyguard was shot in his car
    - A second bodyguard was killed
    - The gardener was also killed
    - Interview cleared by the military censor in 2012
    - Publication amounted to an unofficial confirmation

**[S804]** UN Security Council, Resolution 611 (1988), 25 April 1988 (text via UNSCR.com) — http://unscr.com/en/resolutions/611 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Resolution 611 of 25 April 1988 on Tunisia's complaint against Israel
    - The aggression of 16 April 1988 at Sidi Bou Said caused loss of life incl. assassination of Khalil al-Wazir
    - Adopted 14-0-1
    - UNSC Res. 611; raid at Sidi Bou Said on 16 April 1988 killed al-Wazir
    - Res. 611 dated 25 April 1988
    - Council called it an act of aggression

**[S805]** Clyde Haberman, 'Attack in Israel: The Overview; 20 Killed in Terrorist Bombing of Bus in Tel Aviv; 48 Are Hurt', New York Times, 20 Oct 1994 — https://www.nytimes.com/1994/10/20/world/attack-israel-overview-20-killed-terrorist-bombing-bus-tel-aviv-48-are-hurt.html — archived: https://web.archive.org/web/20250926225537/https://www.nytimes.com/1994/10/20/world/attack-israel-overview-20-killed-terrorist-bombing-bus-tel-aviv-48-are-hurt.html — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - At least 20 killed and 48 wounded in Tel Aviv bus bombing; initial reports said 22
    - Hamas claimed responsibility
    - Army sealed off Gaza and the West Bank, keeping Palestinian laborers from jobs
    - Early report: at least 20 killed, 48 wounded
    - Army sealed off Gaza and West Bank

**[S806]** 'Israeli Army Says Security Was Lax at Massacre Site', New York Times, 9 Mar 1994 — http://www.nytimes.com/1994/03/09/world/israeli-army-says-security-was-lax-at-massacre-site.html — archived: https://web.archive.org/web/20161009154216/http://www.nytimes.com/1994/03/09/world/israeli-army-says-security-was-lax-at-massacre-site.html — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Goldstein killed 29 Palestinians; 3 trampled to death; 5 Palestinians later killed by soldiers in Hebron street battles
    - Preliminary army finding that Goldstein acted alone
    - Army: 29 killed by Goldstein; 3 trampled
    - 5 Palestinians later killed by soldiers in Hebron
    - Preliminary army finding: Goldstein acted alone

**[S808]** Human Rights Watch, World Report 1992: 'West Bank and Gaza Strip' — https://www.hrw.org/reports/1992/WR92/MEW1-04.htm — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Blanket curfew on the West Bank and Gaza on the eve of the Gulf war, confining 1.7 million Palestinians for a month
    - Curfew confined 1.7 million Palestinians for a month
    - HRW: most severe act of collective punishment of the occupation

**[S809]** Human Rights Watch, World Report 1994: 'Israeli-Occupied West Bank and Gaza Strip' — https://www.hrw.org/reports/1994/WR94/Middle-06.htm — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Rabin summarily expelled 415 suspected Islamist activists on 17 December 1992, the largest single deportation since 1967
    - Deportees camped on a hilltop near the border through much of 1993; Israel and Lebanon obstructed aid
    - Israel's Supreme Court upheld the deportations in January 1993; on 1 February Rabin announced 100 could return immediately
    - Five Israeli soldiers and policemen were killed in the preceding week in attacks claimed by Hamas
    - 415 deported on 17 December 1992
    - Largest single deportation since 1967
    - Five soldiers and policemen killed in one week incl. kidnapped border policeman
    - Camped on a hilltop near the border through much of 1993
    - Israel and Lebanon obstructed aid
    - Supreme Court upheld the deportations in January
    - 1 February: 100 to return immediately, rest in stages
    - 181 returned in September 1993
    - Under US and UN pressure Rabin announced on 1 February that 100 could return immediately and the rest in stages

**[S810]** UN Security Council, Resolution 799 (1992), 18 December 1992 (text via UNSCR.com) — http://unscr.com/en/resolutions/799 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Strongly condemns Israel's deportation of hundreds of Palestinian civilians to Lebanon on 17 December 1992
    - UNSC 799 strongly condemns

**[S811]** UN Security Council, Resolution 1073 (1996), 28 September 1996 (text via UNSCR.com) — http://unscr.com/en/resolutions/1073 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel's opening of an entrance to a tunnel near Al-Aqsa led to deadly events in Jerusalem, Nablus, Ramallah, Bethlehem and the Gaza Strip
    - Clashes between the Israeli army and Palestinian police caused casualties on both sides
    - UNSC 1073: tunnel entrance near Al-Aqsa; events in Jerusalem, Nablus, Ramallah, Bethlehem, Gaza
    - Clashes between army and Palestinian police, casualties on both sides

**[S812]** Jewish Virtual Library, 'Israeli Arabs: The Official Summation of the Or Commission Report' (2 September 2003) — https://www.jewishvirtuallibrary.org/the-official-summation-of-the-or-commission-report-september-2003 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 12 Arab citizens, one Jewish citizen and one Gaza resident were killed in the October 2000 events
    - In the second wave of events some places saw retaliatory Jewish riots against Arabs
    - Sniper fire at the Umm al-Fahm junction on 2 October was unjustified and against police regulations
    - Or Commission: government handling of the Arab sector primarily neglectful and discriminatory
    - Recommendation that Ben-Ami not again be public-security minister
    - 12 Arab citizens, one Jewish citizen and one Gaza resident killed in October 2000
    - 12 Arab citizens, one Jewish citizen and one Gaza resident killed
    - Retaliatory Jewish riots against Arabs
    - Sniper use unjustified and against police regulations
    - Unjustified sniper fire at Umm al-Fahm junction
    - Stone-throwing and other means used against security forces and civilians
    - Roads blocked; stone-throwing
    - Commission headed by Justice Theodore Or investigated October 2000
    - 12 Arab citizens, one Jewish citizen, one Gaza resident killed
    - Core finding: government handling of Arab sector neglectful and discriminatory
    - Unjustified use of live fire by police commanders
    - Sniper fire at Umm al-Fahm ordered in contravention of police orders
    - Recommendation: Ben-Ami not to be minister of public security again
    - Criticism of Arab leadership
    - Date: report summary published September 2003 (JVL dates the official summation 2 September 2003)

**[S813]** Human Rights Watch, World Report 1993: 'Israeli-Occupied West Bank and Gaza Strip' — https://www.hrw.org/reports/1993/WR93/Mew-05.htm — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - According to AP, 197 Palestinians were killed by other Palestinians January-November 1992 on suspicion of collaboration
    - HRW: 197 killed Jan-Nov 1992 on suspicion of collaboration

**[S825]** Amnesty International, 'Israel/Lebanon: Under fire: Hizbullah's attacks on northern Israel' (AI Index MDE 02/025/2006), September 2006 — https://www.amnesty.org/en/wp-content/uploads/2021/08/mde020252006en.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Between 350,000 and 500,000 people in northern Israel fled their homes in 2006
    - Hizbullah rockets killed 43 Israeli civilians
    - About one million Lebanese civilians displaced
    - Amnesty: 350,000-500,000 fled their homes in northern Israel
    - Amnesty: several hundred thousand Israelis and ~1 million Lebanese displaced
    - Amnesty: Hizbullah rockets killed 43 civilians

**[S826]** Amnesty International, 'Israel/Lebanon: Deliberate destruction or collateral damage? Israeli attacks on civilian infrastructure' (AI Index MDE 18/007/2006), August 2006 — https://www.amnesty.org/en/wp-content/uploads/2021/08/mde180072006en.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Estimated 1,183 Lebanese fatalities, 4,054 injured, 970,000 displaced in the 2006 war
    - Amnesty: ~1,183 Lebanese fatalities
    - Amnesty: 4,054 injured, 970,000 Lebanese displaced

**[S828]** United Nations, Report of the Secretary-General prepared pursuant to General Assembly resolution ES-10/10 (A/ES-10/186), 30 July 2002 — https://documents.un.org/doc/undoc/gen/n02/499/57/pdf/n0249957.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 497 Palestinians killed 1 Mar-7 May 2002 IDF reoccupation of Area A
    - Jenin: at least 52 Palestinians (up to half civilians) and 23 Israeli soldiers dead
    - About 1,447 Palestinians wounded
    - UN: up to half of the Jenin dead may have been civilians
    - UN: 23 Israeli fatalities in Jenin
    - UN: 497 Palestinians killed in the reoccupation of Area A, 1 Mar - 7 May 2002
    - UN: about 1,447 Palestinians wounded

**[S829]** Israel Ministry of Foreign Affairs, 'Passover suicide bombing at Park Hotel in Netanya', 27 March 2002 (archived) — http://www.mfa.gov.il/mfa/mfaarchive/2000_2009/2002/3/passover+suicide+bombing+at+park+hotel+in+netanya.htm — archived: https://web.archive.org/web/20090612102025/http://www.mfa.gov.il/mfa/mfaarchive/2000_2009/2002/3/passover%2Bsuicide%2Bbombing%2Bat%2Bpark%2Bhotel%2Bin%2Bnetanya.htm — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 30 killed and 140 injured at the Park Hotel seder with 250 guests; Hamas claimed responsibility
    - MFA: 30 killed, 140 injured at the Park Hotel
    - Seder with 250 guests
    - Hamas claimed; bomber identified

**[S830]** BBC News, 'Eight killed at Jerusalem school', 7 March 2008 — https://news.bbc.co.uk/1/hi/world/middle_east/7282269.stm — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Eight killed and nine wounded at Mercaz Harav; gunman from East Jerusalem shot dead
    - Eight killed and nine wounded
    - Gunman, an East Jerusalem resident, shot dead

**[S831]** Haaretz (Lis, Ettinger, Harel), 'Terrorist opens fire in library at Jerusalem yeshiva', 7 March 2008 (archived) — http://www.haaretz.com/hasen/spages/961696.html — archived: https://web.archive.org/web/20080310023320/http://www.haaretz.com/hasen/spages/961696.html — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Eight killed and nine wounded at Mercaz Harav yeshiva
    - Haaretz: eight killed, nine wounded in the library

**[S832]** Suzanne Goldenberg, The Guardian, report on the Tel Aviv Dolphinarium bombing, 2 June 2001 — https://www.theguardian.com/world/2001/jun/02/israel1 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Dolphinarium patrons mostly Russian immigrants, many aged 16-17; bomber blew himself up
    - Most patrons were Russian immigrants
    - Bomber blew himself up among people waiting to enter

**[S833]** Congressional Research Service, 'Israel's Disengagement from Gaza' (RS22000), September 2005, via EveryCRSReport — https://www.everycrsreport.com/reports/RS22000.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Gaza had approx. 8,500 Israeli settlers and 1,325,000 Palestinians
    - Settler evacuation 17-23 August 2005
    - Killings by opponents of disengagement: 4 Israeli Arabs (4 Aug), 4 Palestinians shot at Shiloh (17 Aug)
    - Under Sharon's unilateral disengagement plan
    - Israel evacuated all 21 settlements in Gaza and four in the northern West Bank (places gaza_strip, west_bank)
    - Removing more than 8,000 residents (estimates up to about 8,500 for Gaza)
    - Date: evacuations began 17 August (event date 15 August) and were completed on 22-23 August 2005
    - The last IDF troops left Gaza on 12 September 2005
    - Choice 'Carry out unilateral disengagement' was Sharon's unilateral plan, not negotiated with the PA
    - Choice 'Keep the Gaza settlements': position of the settler movement and Likud rebels
    - Neutrality: related killings by opponents of disengagement omitted

**[S834]** B'Tselem, press release on complete fatality figures from Operation Cast Lead, 9 September 2009 (archived) — https://www.btselem.org/press_releases/20090909 — archived: https://web.archive.org/web/2026id_/https://www.btselem.org/press_releases/20090909 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 1,387 Palestinians killed, 773 not taking part in hostilities incl. 320 minors; 248 police
    - 13 Israelis killed incl. 3 civilians, 4 soldiers by friendly fire
    - B'Tselem: 1,387 Palestinians killed
    - 773 non-participants incl. 320 minors and 109 women
    - 248 Palestinian police officers
    - Israelis killed: 3 civilians, 1 security-force member, 5 soldiers
    - 4 soldiers killed by friendly fire
    - Palestinians fired rockets and mortar shells at Israel during the operation
    - More than 5,300 Palestinians wounded
    - UN: 20,000 left homeless
    - Rockets wounded dozens of Israelis
    - More than 100 soldiers wounded
    - Report's main recommendation: Israel and Hamas must both investigate
    - Israel condemned the report as biased

**[S835]** BBC News, 'Gaza: Humanitarian situation', 2009 — https://news.bbc.co.uk/2/hi/middle_east/7845428.stm — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 5,300 injured (Palestinian figures)
    - 55,000 sheltering in UN schools; at least 66,000 not returned home a week after ceasefire
    - 5,300 injured per Palestinian figures
    - 55,000 sheltering in UN schools
    - At least 66,000 not returned home a week after ceasefire

**[S836]** NASA, 'STS-107' mission page — https://www.nasa.gov/mission/sts-107/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Columbia carried seven crew including the first Israeli astronaut; lost during re-entry 1 Feb 2003
    - Columbia carried seven crew including the first Israeli astronaut
    - Columbia and crew lost during re-entry
    - Date: 1 February 2003; Columbia broke apart during re-entry at the end of STS-107 (place abroad)
    - Ilan Ramon was Israel's first astronaut and died with his six crewmates

**[S837]** Human Rights Watch, 'Rockets from Gaza: Harm to Civilians from Palestinian Armed Groups' Rocket Attacks', 6 August 2009 — https://www.hrw.org/report/2009/08/06/rockets-gaza/harm-civilians-palestinian-armed-groups-rocket-attacks — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Rockets since 2001 killed 15 civilians inside Israel
    - Thousands moved away from Sderot
    - Rockets falling short killed two girls in Gaza
    - Rockets since 2001 killed 15 civilians inside Israel (to May 2009)
    - Rockets hit mainly Sderot; in 2008 also Ashkelon and Netivot
    - Rocket fire began in 2001
    - Rockets struck Ashkelon and Netivot in 2008 (places ashkelon, netivot)

**[S838]** The Guardian, 'The Wrap: Palestinians vow revenge', 23 March 2004 — https://www.theguardian.com/news/2004/mar/23/wrap.rostaylor — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - At least six other people, some bodyguards, killed with Yassin
    - At least six others killed with Yassin

**[S839]** The Guardian (Nikki Knewstub), report on the killing of Abdel-Aziz al-Rantissi, 18 April 2004 — https://www.theguardian.com/world/2004/apr/18/israel — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Rantisi's son Mohammed and a bodyguard also died; five pedestrians wounded
    - Rantisi's son and a bodyguard also died; five pedestrians wounded

**[S850]** UN OHCHR, 'Report of the United Nations High Commissioner for Human Rights on the implementation of Human Rights Council resolutions S-9/1 and S-12/1. Addendum: Concerns related to adherence to international human rights and international humanitarian law in the context of the escalation between the State of Israel, the de facto authorities in Gaza and Palestinian armed groups in Gaza that occurred from 14 to 21 November 2012', A/HRC/22/35/Add.1, 4 July 2013 — https://documents.un.org/doc/undoc/gen/g13/154/84/pdf/g1315484.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 174 Palestinians killed in Gaza 14-21 Nov 2012, at least 168 by Israeli action, 101 believed civilians
    - 6 Israelis killed (4 civilians), 239 injured (219 civilians)
    - IDF estimate 177 killed incl. ~120 combatants; Gaza MoH 189 killed, 1,526 injured
    - OHCHR: 174 Palestinians killed in Gaza during the 14-21 Nov 2012 crisis
    - At least 168 killed by Israeli action, 101 believed civilians incl. 33 children
    - Up to six Palestinian civilians may have been killed by Palestinian rockets landing in Gaza
    - IDF estimate 177 killed incl. ~120 combatants, ~900 injured
    - Gaza MoH: 189 killed, 1,526 injured
    - Six Israelis killed incl. four civilians; 239 injured incl. 219 civilians
    - Over 1,500 rockets and mortar shells fired at Israel
    - Some rockets reached Tel Aviv and Jerusalem
    - Dates 14-21 Nov 2012
    - Opened with the killing of Hamas military commander Ahmed Jabari in an airstrike
    - Eight-day air campaign
    - Hamas and other groups fired well over a thousand rockets
    - Rockets fired toward Tel Aviv and Jerusalem
    - B'Tselem counted 167 Palestinians killed (others c. 160), over half not taking part in hostilities
    - Five or six Israelis killed (sources differ), most of them civilians
    - Neutrality: add Palestinian civilians possibly killed by misfired Palestinian rockets
    - Egyptian-brokered ceasefire took hold on 21 Nov

**[S851]** UN OCHA oPt, 'Occupied Palestinian Territory: Gaza Emergency Situation Report', 28 August 2014 — https://www.ochaopt.org/sites/default/files/ocha_opt_sitrep_28_08_2014.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - As many as 70% of the 40,000 residents of Israeli communities near Gaza had left their homes (some sources)
    - Many residents of Israeli communities near Gaza left their homes
    - Egyptian-brokered open-ended ceasefire began 26 Aug 2014 (a Tuesday)
    - Neutrality: summary omits displacement and injuries in Israel

**[S852]** Israel Ministry of Foreign Affairs, 'Palestinian Fatalities in the 2014 Gaza Conflict' (chapter of The 2014 Gaza Conflict: Factual and Legal Aspects), June 2015; Wayback Machine copy — no URL (print) — archived: https://web.archive.org/web/20150622200823id_/http://mfa.gov.il/ProtectiveEdge/Documents/PalestinianFatalities.pdf — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - IDF preliminary analysis: 2,125 Palestinians killed in 2014; at least 936 militants, 761 civilians, 428 unclassified
    - IDF preliminary analysis: 2,125 Palestinians killed
    - IDF: at least 936 militants, 761 civilians

**[S853]** UN Human Rights Council, 'Report of the independent international Commission of Inquiry on the protests in the Occupied Palestinian Territory', A/HRC/40/74, 25 February 2019 — https://www.ohchr.org/Documents/HRBodies/HRCouncil/CoIOPT/A_HRC_40_74.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 189 Palestinians killed at demonstration sites 30 Mar-31 Dec 2018, 183 by live ammunition
    - 60 demonstrators killed on 14 May 2018; at least 1,162 shot with live ammunition; one Israeli soldier lightly wounded
    - One Israeli soldier killed outside the protest sites; four soldiers injured during the demonstrations (Israeli sources)
    - OCHA: 23,313 Palestinians injured in the context of the demonstrations in 2018
    - COI: 189 killed, 183 by live ammunition
    - OCHA: 23,313 injured in 2018
    - One Israeli soldier killed outside protest sites
    - Four Israeli soldiers injured (Israeli sources)
    - Incendiary kites damaged Israeli property incl. farmland
    - Minority of demonstrators burned tyres, threw stones, flew incendiary kites, cut wire
    - COI: Israeli forces killed 60 demonstrators on 14 May, highest one-day toll since 2014
    - COI: at least 1,162 shot with live ammunition
    - One Israeli soldier lightly wounded
    - Protests timed for the embassy opening and the Nakba anniversary
    - Start date 2018-03-30, weekly protests along the Gaza-Israel fence
    - Demands: return of 1948 refugees and end to the blockade
    - Included unarmed demonstrators and attempts to breach the fence, incendiary kites and explosives
    - UN COI: 189 killed by end-2018, 183 by live ammunition
    - COI found possible crimes against humanity
    - One Israeli soldier killed outside the protest sites
    - At least 58 Palestinians killed by Israeli fire at the Gaza fence that day
    - Deadliest day of cross-border violence since 2014
    - Neutrality: Israeli casualties that day not stated

**[S854]** Times of Israel (TOI staff and agencies), 'Low turnout in last planned Gaza border protest until March 2020', 27 December 2019; Wayback Machine copy — no URL (print) — archived: https://web.archive.org/web/20200402222201/https://www.timesofisrael.com/low-turnout-in-last-gaza-border-protest-until-march-2020/ — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Last planned weekly Great March of Return protest held 27 Dec 2019; protests to be monthly from 30 Mar 2020
    - Weekly protests: last planned mass protest 27 Dec 2019
    - 27 Dec 2019 was the last of the planned weekly protests until March 2020
    - Protests to become monthly from 30 Mar 2020

**[S855]** CNN, 'UN says Israel may have committed war crimes in Gaza protests', 28 February 2019 — https://amp.cnn.com/cnn/2019/02/28/middleeast/israel-gaza-un-intl — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel 'utterly rejected' the UN Commission of Inquiry report; acting FM Yisrael Katz called it 'theater of the absurd'
    - Israel 'utterly rejected' the COI report

**[S856]** Voice of America, UN Commission of Inquiry on Gaza protests report (Israel rejects report), 28 February 2019 — https://www.voanews.com/a/4807774.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel rejected the COI report as 'hostile, false and biased'
    - Israel rejected the report as hostile, false and biased

**[S857]** UN OCHA oPt, 'Protection of Civilians Report, 1-14 October 2019' (via UNISPAL) — https://www.un.org/unispal/wp-content/uploads/2019/10/OCHAPoC_181019.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 210 Palestinians, including 46 children, killed in the Great March of Return protests since March 2018 (as of Oct 2019)
    - OCHA: 210 killed by Oct 2019

**[S858]** The Jewish Chronicle, 'Senior Hamas figure says 50 of 62 Gaza border deaths were its own members', May 2018 — https://thejc.com/news/world/senior-hamas-figure-says-50-of-62-gaza-border-deaths-were-its-own-members-sj7reufe — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Hamas official Salah al-Bardawil: 62 killed in the round of confrontations of 14-15 May 2018, 50 of them Hamas members
    - Hamas official: 50 of 62 killed were Hamas members

**[S859]** Times of Israel, 'Checked and double-checked, elections committee publishes final results', 25 September 2019 — https://www.timesofisrael.com/checked-and-double-checked-elections-committee-publishes-final-results/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Final results of the 17 Sept 2019 election: Blue and White 33, Likud 32
    - Final results: Likud 32 seats
    - Likud a seat behind Blue and White (33)
    - Election held 17 September 2019

**[S860]** Associated Press (via ClickOnDetroit/WDIV), 'Israel begins virus inoculation drive as infections surge', 20 December 2020 — https://www.clickondetroit.com/news/world/2020/12/20/israel-begins-virus-inoculation-drive-as-infections-surge/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel began its coronavirus vaccination drive on Sunday 20 Dec 2020
    - Priority: health workers, then the elderly, high-risk Israelis and over-60s
    - Agreement with Pfizer for 8 million doses
    - Campaign began Sunday 20 Dec 2020
    - Priority groups
    - Pfizer agreement for 8 million doses

**[S861]** Times of Israel, 'First batch of Moderna vaccines arrives in Israel', 7 January 2021 — https://www.timesofisrael.com/first-batch-of-moderna-vaccines-arrives-in-israel/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - First Moderna batch (some 100,000 doses) arrived in Israel on 7 Jan 2021
    - First Moderna batch arrived 7 Jan 2021
    - Moderna batch ~100,000 doses

**[S862]** Fortune, 'Israel's COVID vaccine campaign gets Moderna boost as lockdown tightens', 5 January 2021 — https://fortune.com/2021/01/05/covid-19-israel-vaccines-moderna-lockdown-palestine — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Palestinians in the West Bank and Gaza left out of the initial rollout; Israeli officials said it was the Palestinians' responsibility
    - Palestinians in West Bank and Gaza left out; Israeli officials say it is the Palestinians' responsibility

**[S863]** Aaron Boxerman, Times of Israel, 'History made as Arab Israeli Ra'am party joins Bennett-Lapid coalition', 3 June 2021; Wayback Machine copy — no URL (print) — archived: https://web.archive.org/web/20260917040815/https://www.timesofisrael.com/arab-israeli-raam-party-makes-history-by-joining-bennett-lapid-coalition/ — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Ra'am 'the first Arab party to join a government in decades'
    - In the 1950s a one-member Arab faction, effectively a franchise of Mapai, entered a coalition
    - Ra'am the first Arab party to join a government in decades
    - 1950s one-member Arab faction entered a coalition
    - 1950s Arab faction in coalition was not independent (Mapai franchise)
    - Ra'am became the first Arab party to join a governing coalition

**[S875]** RETIRED (no longer cited) — Renee Ghert-Zand, 'Young girl seriously hurt in Iran attack remains in life-threatening condition', The Times of Israel, Apr 2024 — https://www.timesofisrael.com/young-girl-seriously-hurt-in-iran-attack-remains-in-life-threatening-condition/

**[S876]** Emanuel Fabian, '12 killed, mostly children, dozens hurt as Hezbollah rocket hits Majdal Shams soccer field', The Times of Israel, 27 Jul 2024 — https://www.timesofisrael.com/11-killed-mostly-children-dozens-more-hurt-as-rocket-hits-soccer-field-in-majdal-shams — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 12 children aged 10-20 killed in Majdal Shams
    - Ziv Medical Center admitted 32 wounded
    - Hezbollah denial
    - 12 children killed, dozens wounded
    - All 12 fatalities aged 10-20
    - Druze town of Majdal Shams in the Golan
    - Hezbollah denied responsibility
    - Rocket struck a football pitch in the Druze town of Majdal Shams, Golan Heights
    - Deadliest single strike on Israeli-controlled territory since the northern fighting began
    - Israel blamed Hezbollah, which denied responsibility

**[S877]** RETIRED (no longer cited) — David Brennan and Nadine El-Bawab, '20 more dead, 450 injured as new round of explosions rocks Lebanon: Health officials', ABC News, 18 Sep 2024 — https://abcnews.go.com/International/hezbollah-vows-reckoning-after-thousands-lebanon-injured-exploding/story?id=113798347

**[S878]** RETIRED (no longer cited) — Scott Neuman, 'The world welcomes the Israel-Hezbollah ceasefire, but worries remain', NPR, 27 Nov 2024 — https://www.npr.org/2024/11/27/g-s1-36024/israel-lebanon-ceasefire-reaction

**[S879]** RETIRED (no longer cited) — NBC News, 'U.K., Canada and Australia formally recognize a Palestinian state, breaking with the U.S.', 21 Sep 2025 — https://www.nbcnews.com/world/middle-east/uk-canada-australia-formally-recognize-palestine-state-rcna232588

**[S880]** RETIRED (no longer cited) — Government of Luxembourg, 'Luxembourg formally recognises the State of Palestine', press release, 22 Sep 2025 — https://gouvernement.lu/en/actualites/toutes_actualites/communiques/2025/09-septembre/22-frieden-ny-palestine.html

**[S881]** RETIRED (no longer cited) — Radio Monaco, 'Monaco reconnaît l'État de Palestine', Sep 2025 — https://radio-monaco.com/politique-monaco-reconnait-letat-de-palestine/

**[S882]** RETIRED (no longer cited) — Ynet News, 'Andorra recognizes Palestinian state: Demilitarized and without Hamas in government', 23 Sep 2025 — https://www.ynetnews.com/article/t9r80gnkw

**[S883]** RETIRED (no longer cited) — HRANA, 'Day 13 of the U.S.-Israeli War on Iran: More Than Three Million Displaced', 12 Mar 2026 — https://www.en-hrana.org/day-thirteen-of-the-u-s-israeli-war-on-iran-more-than-three-million-displaced/

**[S884]** RETIRED (no longer cited) — L'Orient-Le Jour, '« Rébellion » et « pure folie » : au Liban, les responsables condamnent en bloc les tirs du Hezbollah sur Israël', 2 Mar 2026 — https://www.lorientlejour.com/article/1496805/tirs-du-hezbollah-aoun-avertit-contre-lutilisation-du-liban-comme-plateforme-pour-des-guerres-de-so

**[S885]** RETIRED (no longer cited) — The Times of Israel, 'Opposition, northern mayors decry imposed ceasefires as Lebanon truce declared', 16 Apr 2026 — https://www.timesofisrael.com/opposition-northern-mayors-decry-imposed-ceasefires-as-lebanon-truce-declared/

**[S1000]** archive.israel21c.org, 'https://archive.israel21c.org/?p=96034' — https://archive.israel21c.org/?p=96034 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date: launched 5 July 1961
    - Israel's first rocket; two-stage
    - launched from the Mediterranean coast
    - places: rehovot
    - its meteorological aims were not met
    - publicised as a technological milestone

**[S1001]** bu.edu, 'Statement to the Knesset by Prime Minister Ben-Gurion, 13 December 1949:' — https://www.bu.edu/mzank/Jerusalem/tx/isrgovmovetojlem.htm — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Ben-Gurion told the Knesset on 13 December 1949 that government institutions would move to Jerusalem

**[S1002]** history.state.gov, 'Milestones in the History of U.S. Foreign Relations - Office of the Historian' — https://history.state.gov/milestones/1945-1952/creation-israel — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1948-05-14: Ben-Gurion proclaimed the State of Israel

**[S1003]** britannica.com, 'Ashdod | Israel, Map, & History | Britannica' — no URL (print) — archived: https://web.archive.org/web/2024/https://www.britannica.com/place/Ashdod — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - wording: Ashdod's port described as 'deep-water'

**[S1004]** en.idi.org.il, '1961 - The Israel Democracy Institute' — https://en.idi.org.il/israeli-elections-and-parties/elections/1961/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date: 15 August 1961
    - held early after the Lavon affair re-erupted
    - Mapai cut to 42 seats
    - turnout 81.6%
    - Ben-Gurion formed his last government

**[S1005]** myjewishlearning.com, 'The Mass Migration to Israel of the 1950s | My Jewish Learning' — https://www.myjewishlearning.com/article/the-mass-migration-of-the-1950s/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Growth was mostly through immigration, including Holocaust survivors from Europe
    - Mass immigration doubled the population (title)
    - Over 260,000 Jews from Arab and Muslim countries had arrived by 1951
    - Absorption strained housing, food supplies and the budget

**[S1006]** jewishvirtuallibrary.org, 'Morocco Virtual Jewish History Tour' — https://www.jewishvirtuallibrary.org/morocco-virtual-jewish-history-tour — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date_end: spring 1964 (1964-04-30)
    - the clandestine boat Egoz sank in January 1961
    - Egoz sank with 44 aboard
    - a Mossad-run arrangement
    - estimates range from 80,000 to 100,000

**[S1007]** jewishvirtuallibrary.org, 'Operation “Horev” (December 1948 - January 1949) | Jewish Virtual Library' — https://www.jewishvirtuallibrary.org/jsource/History/horev.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date: operation began 22 December 1948 and ended 7 January 1949

**[S1008]** history.state.gov, 'Historical Documents - Office of the Historian' — https://history.state.gov/historicaldocuments/frus1949v06/d362 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - operation ended 7 January 1949 (cease-fire effective that day)

**[S1009]** history.state.gov, 'Historical Documents - Office of the Historian' — https://history.state.gov/historicaldocuments/frus1948v05p2/d857 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israeli forces crossed into Sinai toward El Arish (places: sinai)
    - Britain threatened to intervene under its treaty with Egypt

**[S1010]** history.state.gov, 'Historical Documents - Office of the Historian' — https://history.state.gov/historicaldocuments/frus1949v06/d351 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel withdrew from Sinai

**[S1011]** history.state.gov, 'Historical Documents - Office of the Historian' — https://history.state.gov/historicaldocuments/frus1949v06/d354 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Egypt agreed to armistice talks

**[S1012]** un.org, 'Absentee property/Israel law - Text/Non-UN document - Question of Palestine' — https://www.un.org/unispal/document/auto-insert-209845/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1950-03-20 for the Absentees' Property Law
    - The law applied to property of persons who after 29 November 1947 were in Arab states or Arab-held parts of Palestine
    - Absentees' property vested in a Custodian of Absentees' Property

**[S1013]** geocities.com, 'Development Authority Law (1950)' — no URL (print) — archived: https://web.archive.org/web/20091028101641/http://geocities.com/savepalestinenow/israellaws/fulltext/devauthoritylaw.htm — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - The Custodian transferred land to a Development Authority and on to state and Jewish settlement use (legal mechanism)

**[S1014]** badil.org, 'http://www.badil.org/phocadownload/Badil_docs/Working_Papers/Palestinian.IDPs.pdf' — http://www.badil.org/phocadownload/Badil_docs/Working_Papers/Palestinian.IDPs.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - It also applied to many Arab citizens displaced within Israel ('present absentees')
    - Palestinian refugees had no equivalent right of return

**[S1015]** adalah.org, 'Absentees’ Property Law - Adalah' — https://www.adalah.org/en/law/view/538 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Palestinian and human-rights groups regard it as the legal basis of large-scale dispossession

**[S1016]** haaretz.com, 'President Peres apologizes for Kafr Qasem massacre of 1956 - Haaretz Daily Newspaper | Israel News' — no URL (print) — archived: https://web.archive.org/web/20110522202709/http://www.haaretz.com/news/president-peres-apologizes-for-kafr-qasem-massacre-of-1956-1.235632 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1956-10-29, on the first evening/day of the Sinai war, at Kafr Qasim (place: kafr_qasim)
    - Border Police enforcing a curfew shot dead Arab citizens returning from work
    - toll given as 47 (low end of 47-49)

**[S1017]** jpost.com, 'IDF releases court documents from Kafr Kassem massacre | The Jerusalem Post' — https://www.jpost.com/israel-news/article-713447 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - curfew brought forward without warning
    - toll given as 49 (high end; 'most often cited')

**[S1018]** timesofisrael.com, 'https://www.timesofisrael.com/rivlin-to-address-ceremony-marking-kfar-kassem-massacre/' — https://www.timesofisrael.com/rivlin-to-address-ceremony-marking-kfar-kassem-massacre/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - curfew without warning: villagers had not been notified
    - victims included women and children
    - military court sentenced the convicted officers and policemen to 7-17 years
    - completeness: summary omits wounded and the later reduction/pardons of the sentences

**[S1019]** haaretz.com, 'https://web.archive.org/web/20061109041310/http://www.haaretz.com/hasen/spages/780898.html' — no URL (print) — archived: https://web.archive.org/web/20061109041310/http://www.haaretz.com/hasen/spages/780898.html — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the court established that a 'manifestly unlawful order' must be refused

**[S1020]** britannica.com, 'Levi Eshkol | Israeli leader, statesman, politician | Britannica' — no URL (print) — archived: https://web.archive.org/web/2024/https://www.britannica.com/biography/Levi-Eshkol — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Eshkol succeeded Ben-Gurion as prime minister in 1963

**[S1021]** jewishvirtuallibrary.org, 'Chaim Weizmann' — https://www.jewishvirtuallibrary.org/chaim-weizmann — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Chaim Weizmann was chosen as the first President
    - Chaim Weizmann, Israel's first president, died in office on 9 November 1952
    - Weizmann was a chemist

**[S1022]** britannica.com, 'https://web.archive.org/web/2024/https://www.britannica.com/place/Karmiel' — no URL (print) — archived: https://web.archive.org/web/2024/https://www.britannica.com/place/Karmiel — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date: founded 1964
    - located in the Beit HaKerem Valley (Galilee)
    - a planned development town
    - part of a policy to increase the Jewish population of the Galilee

**[S1023]** britannica.com, 'https://web.archive.org/web/2024/https://www.britannica.com/place/West-Bank' — no URL (print) — archived: https://web.archive.org/web/2024/https://www.britannica.com/place/West-Bank — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1950-04-24: Jordan annexed the West Bank
    - Only Britain and Pakistan are generally recorded as recognising the annexation
    - places: west_bank, east_jerusalem, amman

**[S1024]** history.state.gov, 'Milestones in the History of U.S. Foreign Relations - Office of the Historian' — https://history.state.gov/milestones/1961-1968/arab-israeli-war-1967 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Nasser's closure announcement (context for 23 May date)
    - Foreign Minister Abba Eban sought Western diplomatic support during the waiting period
    - a proposed international flotilla to reopen the straits was part of the diplomatic track
    - the flotilla plan failed to gain backing (context for choice 2)
    - Jordan and Syria entered the fighting; by the ceasefire of 10 June Israel held Sinai, Gaza Strip, West Bank incl. East Jerusalem and the Golan Heights (places: sinai, gaza_strip, west_bank, east_jerusalem, golan_heights, jerusalem)
    - differing interpretations (neutral official source)

**[S1025]** knesset.gov.il, 'https://web.archive.org/web/20160522175237/https://www.knesset.gov.il/govt/eng/GovtByNumber_eng.asp?govt=13' — no URL (print) — archived: https://web.archive.org/web/20160522175237/https://www.knesset.gov.il/govt/eng/GovtByNumber_eng.asp?govt=13 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - a national unity government was formed on 1 June 1967 with Moshe Dayan as defence minister
    - Allon is described as 'Deputy Prime Minister' when he proposed the plan in July 1967
    - Prime Minister Levi Eshkol died on 26 February 1969
    - Knesset record dates Dayan's term as defence minister and Begin's entry into the government from 5 June 1967
    - Knesset record: Dayan defence minister from 5 June 1967
    - Allon was Labour Minister in July 1967 and Deputy Prime Minister from 1 July 1968
    - Allon Minister of Labour until 1 July 1968

**[S1026]** history.state.gov, 'Historical Documents - Office of the Historian' — https://history.state.gov/historicaldocuments/frus1964-68v19/d102 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - choice (non-historical) 'keep waiting for a US-British international flotilla' was a genuinely proposed option at the time

**[S1027]** btselem.org, 'Fatalities in the first Intifada | B'Tselem' — no URL (print) — archived: https://web.archive.org/web/20241230115433/https://www.btselem.org/statistics/first_intifada_tables — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: began 9 December 1987
    - B'Tselem: 1,070 Palestinians killed by Israeli security forces 9 Dec 1987 - 13 Sep 1993 (22+289+285+125+91+134+124)
    - 237 of them minors (5+48+78+23+24+23+36)
    - 54 Palestinians killed by Israeli civilians (0+15+17+9+6+2+5)
    - Israeli deaths about 160-180 per B'Tselem
    - B'Tselem: inside the Green Line, 17 Palestinians killed by Israeli security forces and 21 by Israeli civilians, 9 Dec 1987 - 13 Sep 1993 (0+1+1+1+5+2+7; 0+5+2+10+2+0+2)
    - B'Tselem: 1,070 by security forces (237 minors) and 54 by civilians in the occupied territories, 9 Dec 1987 - 13 Sep 1993 (full rows incl. 1993)
    - B'Tselem: Israelis killed in the occupied territories 9 Dec 1987 - 13 Sep 1993: 47 civilians, 43 security forces
    - B'Tselem: Israelis killed inside the Green Line 9 Dec 1987 - 13 Sep 1993: 53 civilians, 17 security forces (total with OT table = 160)
    - End date 13 September 1993 (Declaration of Principles)

**[S1028]** britannica.com, 'https://web.archive.org/web/20241231175041/https://www.britannica.com/topic/intifada' — no URL (print) — archived: https://web.archive.org/web/20241231175041/https://www.britannica.com/topic/intifada — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Popular uprising against Israeli rule in the West Bank and Gaza Strip (places west_bank, gaza_strip)
    - Broke out after a traffic accident in Gaza involving an Israeli truck
    - Lasted until the Oslo Declaration of September 1993
    - Israeli vehicle killed four Palestinian workers

**[S1029]** jpost.com, 'https://web.archive.org/web/20160303222441/http://www.jpost.com/Features/In-Thespotlight/The-accident-that-sparked-an-Intifada' — no URL (print) — archived: https://web.archive.org/web/20160303222441/http://www.jpost.com/Features/In-Thespotlight/The-accident-that-sparked-an-Intifada — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Place jabalia: accident and first riots at Jabalia refugee camp

**[S1030]** spaceflightnow.com, 'Israeli probe crashes in attempt to become first privately-funded moon lander – Spaceflight Now' — https://spaceflightnow.com/2019/04/11/israeli-probe-crashes-in-attempt-to-become-first-privately-funded-moon-lander/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: Beresheet crashed on 11 April 2019
    - Built by the non-profit SpaceIL
    - Built with Israel Aerospace Industries
    - First privately funded attempt at a lunar landing

**[S1031]** en.globes.co.il, 'Likud handed extra seat in final election results - Globes' — https://en.globes.co.il/en/article-1001301966 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: repeat election held 17 Sept 2019; final results published 25 Sept 2019
    - Blue and White won 33 seats and Likud 32

**[S1032]** jewishnews.co.uk, 'https://www.jewishnews.co.uk/knesset-paves-way-for-third-election-in-12-months/amp/' — https://www.jewishnews.co.uk/knesset-paves-way-for-third-election-in-12-months/amp/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Neither Netanyahu nor Gantz could form a coalition
    - Leading to a third election in March 2020

**[S1033]** mrclmb.ac.uk, 'LMB Alumni awarded Nobel Prize for Chemistry, 2013 | MRC Laboratory of Molecular Biology' — https://mrclmb.ac.uk/?p=4200 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date 2013-10-09: 2013 Nobel Prize in Chemistry announced to Levitt, Warshel and Karplus (LMB congratulation published 09/10/2013)
    - Work begun in the 1970s partly at the Weizmann Institute

**[S1034]** timesofisrael.com, 'Israeli professors awarded Nobel Prize in Stockholm | The Times of Israel' — https://www.timesofisrael.com/israeli-professors-awarded-nobel-prize-in-stockholm/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Prize shared with Martin Karplus for multiscale computer models of chemical systems
    - Arieh Warshel is Israeli-born
    - Michael Levitt described as 'Israeli-American-British'
    - Place: Rehovot (Weizmann Institute)

**[S1035]** en.globes.co.il, 'Major gas find at Tamar-1 - Globes' — https://en.globes.co.il/en/article-1000417340 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: Tamar discovery announced January 2009 (event date 2009-01-17, month precision)
    - Noble Energy and its Israeli partners announced the discovery
    - Place: Tamar about 90 km off Haifa

**[S1036]** sec.gov, 'https://www.sec.gov/Archives/edgar/data/0000072207/000007220710000006/form10-k.htm' — https://www.sec.gov/Archives/edgar/data/0000072207/000007220710000006/form10-k.htm — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date cross-check: Noble Energy announced the Tamar discovery in January 2009

**[S1040]** jns.org, 'Court rules Netanyahu exempt from appearance at next hearing - Israel & Jewish News - JNS' — https://www.jns.org/court-rules-netanyahu-exempt-from-appearance-at-next-hearing/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Trial opened in the Jerusalem District Court on 24 May 2020

**[S1041]** timesofisrael.com, 'Netanyahu’s trial delayed by over 2 months as court activity limited over virus | The Times of Israel' — https://www.timesofisrael.com/netanyahus-trial-delayed-by-over-2-months-as-court-activity-limited-over-virus/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Trial date 24 May 2020 after postponement (cross-check)
    - The first criminal trial of a sitting Israeli prime minister

**[S1042]** timesofisrael.com, 'https://www.timesofisrael.com/bodies-of-three-kidnapped-teens-found' — https://www.timesofisrael.com/bodies-of-three-kidnapped-teens-found — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date 2014-06-12: three teens abducted on the night of 12 June 2014
    - Abducted while hitchhiking in Gush Etzion (place kfar_etzion)
    - Bodies found near Hebron on 30 June 2014

**[S1043]** timesofisrael.com, 'https://www.timesofisrael.com/palestinian-teen-said-found-dead-in-jerusalem-forest/' — https://www.timesofisrael.com/palestinian-teen-said-found-dead-in-jerusalem-forest/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Mohammed Abu Khdeir, 16, abducted in East Jerusalem on 2 July 2014

**[S1044]** timesofisrael.com, 'https://www.timesofisrael.com/palestinians-murdered-arab-teenager-was-burned-alive/' — https://www.timesofisrael.com/palestinians-murdered-arab-teenager-was-burned-alive/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Abu Khdeir burned alive (Palestinian autopsy finding, attributed)

**[S1046]** jpost.com, 'Israel limits gatherings to 100 people as coronavirus cases climb to 97 | The Jerusalem Post' — https://www.jpost.com/Israel-News/Coronavirus-cases-climb-to-77-second-case-of-unknown-origin-confirmed-620578 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - From 11 March the government imposed distancing rules

**[S1047]** en.globes.co.il, 'Israel's cabinet approves three-week lockdown - Globes' — https://en.globes.co.il/en/article-israels-cabinet-approves-three-week-lockdown-1001342554 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - In the following months ordered repeated national lockdowns

**[S1048]** abcnews.com, 'Israel Offers 10-Month Settlement Freeze - ABC News' — https://abcnews.com/International/israel-offers-10-month-settlement-freeze/story?id=9173847 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date 25 Nov 2009: security cabinet approved the moratorium
    - 10-month halt to new housing starts in West Bank settlements
    - Under US pressure to restart talks
    - Mitchell: less than a full freeze but more than any previous Israeli government had done
    - Palestinians called it insufficient
    - Choice (historical): approve limited 10-month moratorium, security cabinet 25 Nov 2009
    - Choice (non-historical): full freeze incl. East Jerusalem as Palestinians/US demanded
    - Netanyahu offered a 10-month moratorium
    - Approved by the security cabinet
    - Palestinians refused talks until a full freeze
    - Mitchell: offer falls short of a full freeze

**[S1049]** timesofisrael.com, 'https://www.timesofisrael.com/final-results-confirm-likud-with-36-seats-right-short-of-majority-with-58/' — https://www.timesofisrael.com/final-results-confirm-likud-with-36-seats-right-short-of-majority-with-58/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Likud won 36 seats
    - Blue and White won 33 seats
    - Joint List's 15 seats were 'a record'
    - Joint List's best result

**[S1050]** timesofisrael.com, 'https://www.timesofisrael.com/liveblog_entry/liberman-backs-gantz-hopes-for-emergency-government/' — https://www.timesofisrael.com/liveblog_entry/liberman-backs-gantz-hopes-for-emergency-government/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Framed as an 'emergency' unity government amid the pandemic

**[S1051]** israelnationalnews.com, '23rd Knesset dissolved, Israel going to elections | Israel National News' — https://www.israelnationalnews.com/News/News.aspx/293568 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Coalition collapsed over failure to pass a budget; Knesset dissolved automatically in December 2020

**[S1052]** timesofisrael.com, 'Knesset officially dissolves, Israel heads to new elections | The Times of Israel' — https://www.timesofisrael.com/liveblog_entry/knesset-officially-dissolves-israel-heads-to-new-elections/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Fourth election set for 23 March 2021
    - Date 23 March 2021; the fourth election in two years

**[S1053]** britannica.com, 'Palestine Liberation Organization (PLO) | Leaders, History, Mission, & Relations with Hamas | Britannica' — no URL (print) — archived: https://web.archive.org/web/2024/https://www.britannica.com/topic/Palestine-Liberation-Organization — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Ahmad Shuqeiri as chairman

**[S1054]** bpb.de, 'Vor 70 Jahren: Der Deutsche Bundestag stimmt "Luxemburger Abkommen" zu | Hintergrund aktuell | bpb.de' — https://www.bpb.de/kurz-knapp/hintergrund-aktuell/519239/vor-70-jahren-der-deutsche-bundestag-stimmt-luxemburger-abkommen-zu/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - The Knesset debated direct talks for three days, 7-9 January 1952
    - Begin called the payments 'blood money'
    - On 9 January 1952 the Knesset approved negotiations by 61 to 50
    - Paid largely in goods and services
    - Industrial equipment among deliveries

**[S1055]** begincenter.org.il, 'opposing the reparations program - מרכז מורשת מנחם בגין' — https://www.begincenter.org.il/timeline/%d7%94%d7%aa%d7%a0%d7%92%d7%93%d7%95%d7%aa%d7%95-%d7%a9%d7%9c-%d7%91%d7%92%d7%99%d7%9f-%d7%9c%d7%aa%d7%9b%d7%a0%d7%99%d7%aa-%d7%94%d7%a9%d7%99%d7%9c%d7%95%d7%9e%d7%99%d7%9d/?lang=en — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Menachem Begin led a mass rally against reparations near the Knesset
    - The rally turned violent outside the Knesset

**[S1056]** germanhistorydocs.org, 'https://germanhistorydocs.org/en/occupation-and-the-emergence-of-two-states-1945-1961/communique-regarding-restitution-for-israel-and-the-jews-september-10-1952.pdf' — https://germanhistorydocs.org/en/occupation-and-the-emergence-of-two-states-1945-1961/communique-regarding-restitution-for-israel-and-the-jews-september-10-1952.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Agreement signed in Luxembourg on 10 September 1952 by Moshe Sharett and Konrad Adenauer

**[S1057]** bundestag.de, '18. März 1953: Bundestag ratifiziert deutsch-israelisches Wiedergutmachungsabkommen - Deutscher Bundestag' — https://www.bundestag.de/dokumente/textarchiv/1953-03-18-wiedergutmachung-israel-937558 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - West Germany would pay Israel 3 billion marks
    - Plus 450 million marks to the Claims Conference
    - Paid over 12-14 years

**[S1058]** worldjewishcongress.org, 'This week in Jewish history | Germany signs reparations agreements with Israel and the Jewish People - World Jewish Congress' — https://www.worldjewishcongress.org/en/news/this-week-in-jewish-history--germany-signs-reparations-agreements-with-israel-and-the-jewish-people-9-4-2020 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Financed ships and rail

**[S1059]** jta.org, 'Felix Shinnar Dead at 80 - Jewish Telegraphic Agency' — https://jta.org/archive/felix-shinnar-dead-at-80 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Financed power and industrial equipment

**[S1060]** jewishvirtuallibrary.org, 'Rehovot, Israel' — https://www.jewishvirtuallibrary.org/rehovot — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Place: Rehovot
    - Established 1890
    - Rehovot in the 1948 war

**[S1061]** jta.org, 'Itzhak Ben Zvi Elected President of Israel; Inauguration Tomorrow - Jewish Telegraphic Agency' — https://www.jta.org/archive/itzhak-ben-zvi-elected-president-of-israel-inauguration-tomorrow — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - The Knesset elected Yitzhak Ben-Zvi to succeed him

**[S1062]** knesset.gov.il, 'The Law of Return' — no URL (print) — archived: https://web.archive.org/web/2015/http://www.knesset.gov.il/laws/special/eng/return.htm — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1950-07-05: the Knesset enacted the Law of Return (place: Jerusalem)
    - The law gives every Jew the right to immigrate to Israel as an oleh

**[S1063]** britannica.com, 'Law of Return | Israel [1950] | Britannica' — no URL (print) — archived: https://web.archive.org/web/2024/https://www.britannica.com/topic/Law-of-Return — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - It became the legal foundation for later aliyah waves

**[S1064]** nobelprize.org, 'Ralph Bunche – Biographical - NobelPrize.org' — no URL (print) — archived: https://web.archive.org/web/2024/https://www.nobelprize.org/prizes/peace/1950/bunche/biographical/ — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - signed under UN mediator Ralph Bunche (Acting Mediator)

**[S1065]** haaretz.com, 'Periphery without a center - Haaretz Daily Newspaper | Israel News' — no URL (print) — archived: https://web.archive.org/web/20110513170300/http://www.haaretz.com/general/periphery-without-a-center-1.107172 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - In 1950 most of the remaining Arab residents of Majdal were moved to the Egyptian-held Gaza Strip (displacement 2,000-2,700)
    - The move was officially presented as voluntary, while historians describe pressure and coercion
    - The town was resettled by Jewish immigrants and became Ashkelon

**[S1066]** jewishvirtuallibrary.org, 'Operation Uvda' — https://www.jewishvirtuallibrary.org/operation-uvda — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date: operation ran 5-10 March 1949
    - last operation of the war, securing the southern Negev (places: negev, arava)
    - IDF units reached the Gulf of Aqaba at Umm Rashrash on 10 March 1949 (places: eilat)
    - soldiers raised the improvised 'Ink Flag'

**[S1067]** documents.un.org, 'https://documents.un.org/api/symbol/access?s=S/RES/101(1953)&l=en&t=pdf' — https://documents.un.org/api/symbol/access?s=S/RES/101(1953)&l=en&t=pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: raid on the night of 14-15 October 1953
    - Qibya was a Jordanian-held village (West Bank)
    - Condemned internationally, including by UN Security Council Resolution 101

**[S1068]** documents.un.org, 'https://documents.un.org/api/symbol/access?s=S/PV.630&l=en&t=pdf' — https://documents.un.org/api/symbol/access?s=S/PV.630&l=en&t=pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Infiltrators from the West Bank killed a mother and her two children at Yehud
    - Some 45-50 houses blown up
    - Death toll: sources differ (contemporary UN figures lower than 69)
    - Many victims were hiding inside the houses
    - Neutrality: casualty record lists only Palestinian dead; the Israeli victims of the Yehud attack named in the summary are omitted

**[S1069]** users.ox.ac.uk, 'https://web.archive.org/web/2015/http://users.ox.ac.uk/~ssfc0005/The%20Protocol%20of%20Sevres%201956%20Anatomy%20of%20a%20War%20Plot.html' — no URL (print) — archived: https://web.archive.org/web/2015/http://users.ox.ac.uk/~ssfc0005/The%20Protocol%20of%20Sevres%201956%20Anatomy%20of%20a%20War%20Plot.html — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - secret Sèvres protocol with Britain and France
    - choice 1 (historical): Ben-Gurion, Dayan and Peres agreed the Sèvres protocol of 22-24 October 1956

**[S1070]** unispal.un.org, 'A/3212/Add.1 of 15 December 1956' — no URL (print) — archived: https://web.archive.org/web/20131104160006/http://unispal.un.org/UNISPAL.NSF/0/6558F61D3DB6BD4505256593006B06BE — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel took the Gaza Strip, incl. Khan Yunis (3 Nov) and Rafah (places: gaza_strip, khan_yunis, rafah)
    - neutrality: summary/casualties omit Palestinian civilians killed in the Gaza Strip during the occupation (Khan Yunis, Rafah)
    - UNRWA: 275 allegedly killed at Khan Yunis on 3 Nov 1956
    - UNRWA: 111 allegedly killed at Rafah on 12 Nov 1956
    - Israeli authorities said there was resistance; refugees deny it

**[S1071]** users.ox.ac.uk, 'https://web.archive.org/web/2016/http://users.ox.ac.uk/~ssfc0005/Israel%20between%20East%20and%20West%201948-56.html' — no URL (print) — archived: https://web.archive.org/web/2016/http://users.ox.ac.uk/~ssfc0005/Israel%20between%20East%20and%20West%201948-56.html — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - choice 2: continuing limited reprisal raids without a full war was a genuine pre-war policy (Shlaim)
    - choice 3: 'Seek arms and a security guarantee from France without going to war', associated with Sharett

**[S1072]** jewishvirtuallibrary.org, 'Iraq Virtual Jewish History Tour' — https://www.jewishvirtuallibrary.org/iraq-virtual-jewish-history-tour — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Iraq allowed Jews to emigrate on condition of giving up citizenship

**[S1073]** jewishvirtuallibrary.org, 'Moshe Sharett' — https://www.jewishvirtuallibrary.org/moshe-sharett — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Foreign Minister Moshe Sharett became Prime Minister in January 1954
    - Ben-Gurion again became Prime Minister in November 1955
    - Sharett remained Foreign Minister until June 1956

**[S1074]** gould.usc.edu, 'https://gould.usc.edu/why/students/orgs/ilj/assets/docs/18-1%20Seidman.pdf' — https://gould.usc.edu/why/students/orgs/ilj/assets/docs/18-1%20Seidman.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date: austerity introduced April 1949 (plan presented to Knesset 26 April 1949)
    - context: mass immigration and economic/foreign-currency crisis
    - Dov Yosef was Minister of Rationing and Supply (Seidman translates the title as 'Rationing and Provision')
    - rationing of food, clothing and furniture
    - austerity lasted, in diminishing form, through the 1950s
    - a black market flourished

**[S1075]** ynetnews.com, 'Nazareth Illit changes name to differentiate from biblical Nazareth' — https://www.ynetnews.com/articles/0,7340,L-5477002,00.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1957: Jewish town above Nazareth founded c. 1957 (places: nof_hagalil, nazareth)
    - renamed Nof HaGalil in 2019

**[S1076]** api.openalex.org, 'https://api.openalex.org/works/doi:10.1080/13531040600810292' — https://api.openalex.org/works/doi:10.1080/13531040600810292 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Historian Geremy Forman describes its purpose as consolidating state control over the Arab city

**[S1077]** encyclopedia.com, 'Kiryat Gat | Encyclopedia.com' — https://www.encyclopedia.com/religion/encyclopedias-almanacs-transcripts-and-maps/kiryat-gat — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Kiryat Gat began in 1954 as a ma'abara (event dated 1954)
    - Established in 1955 as the centre of the Lachish development region
    - Near the depopulated village of Iraq al-Manshiyya
    - Initially settled by families from Morocco

**[S1078]** presidency.ucsb.edu, 'Radio and Television Address to the American People on the Situation in the Middle East. | The American Presidency Project' — https://www.presidency.ucsb.edu/documents/radio-and-television-address-the-american-people-the-situation-the-middle-east — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - under US pressure Israel withdrew

**[S1079]** cbs.gov.il, 'https://web.archive.org/web/2025id_/https://www.cbs.gov.il/he/publications/DocLib/2019/ishuvim/bycode2024.xlsx' — no URL (print) — archived: https://web.archive.org/web/2025id_/https://www.cbs.gov.il/he/publications/DocLib/2019/ishuvim/bycode2024.xlsx — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Yeruham founded in 1951 (event date 1951-01-09)
    - Sderot founded in 1951
    - Mitzpe Ramon founded in 1951 (same-year event)
    - Beit Shemesh founded in 1950 (event date 1950-12-06)
    - founded 1950
    - founded 1954

**[S1080]** haaretz.com, 'Israel Seized Land From Arab Citizens Based on Temporary 1948 Cease-Fire Line - Israel News' — https://www.haaretz.com/israel-news/2022-03-15/ty-article/.premium/israel-seized-land-from-arab-citizens-based-on-temporary-1948-cease-fire-line/00000180-5bd0-dee0-afd6-7bdda6f10000 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Tayibe is among the Little Triangle Arab towns inside Israel (places: tayibe)

**[S1081]** history.state.gov, 'Historical Documents - Office of the Historian' — https://history.state.gov/historicaldocuments/frus1949v06/d674 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel barred return (made repatriation conditional on a peace settlement)

**[S1082]** en.idi.org.il, '1951 - The Israel Democracy Institute' — https://en.idi.org.il/israeli-elections-and-parties/elections/1951/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Second Knesset election held 1951-07-30
    - Mapai won 45 seats
    - General Zionists rose to 20 seats
    - Turnout was 75.1%
    - Ben-Gurion formed a new coalition

**[S1083]** en.idi.org.il, '1959 - The Israel Democracy Institute' — https://en.idi.org.il/israeli-elections-and-parties/elections/1959/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1959-11-03: Fourth Knesset election
    - Mapai won its best result, 47 seats
    - Herut took 17 seats
    - turnout 81.6%

**[S1084]** jewishvirtuallibrary.org, 'Total Casualties, Arab-Israeli Conflict' — https://www.jewishvirtuallibrary.org/total-casualties-arab-israeli-conflict — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel's official count is 6,373 dead over the 1947-49 war
    - JVL: First Intifada 200 Israelis and 1,162 Palestinians killed
    - JVL: Palestinians killed by Palestinians 1987-1993 about 1,000
    - JVL 2000-2005: 1,100 Israelis killed, 8,000 wounded; 4,907 Palestinians killed, 8,611 wounded
    - JVL table: 1948 war, Israel 6,373 killed, about 10,000 Arabs killed

**[S1085]** timesofisrael.com, 'The growing pains of Beit Shemesh | The Times of Israel' — https://www.timesofisrael.com/the-growing-pains-of-beit-shemesh/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Early immigrants from Iran, Iraq and Morocco

**[S1086]** encyclopedia.com, 'Horowitz, David | Encyclopedia.com' — https://www.encyclopedia.com/religion/encyclopedias-almanacs-transcripts-and-maps/horowitz-david — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Bank of Israel established in 1954 as the central bank
    - David Horowitz was its first governor, serving until 1971

**[S1087]** jewishvirtuallibrary.org, 'Adolf Eichmann' — https://www.jewishvirtuallibrary.org/adolf-eichmann — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1960-05-11: Eichmann seized near his home in Buenos Aires (place: abroad)
    - hanged at Ramla (place: ramla)

**[S1088]** encyclopedia.ushmm.org, 'Eichmann Trial | Holocaust Encyclopedia' — https://encyclopedia.ushmm.org/content/en/article/eichmann-trial — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - testimony from survivors made the Holocaust central to Israeli and world awareness
    - the only civil execution in Israel's history

**[S1089]** mekorot-int.com, 'Our History | Mekorot' — no URL (print) — archived: https://web.archive.org/web/20230903141533/https://www.mekorot-int.com/our-history/ — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - built by Mekorot
    - places: tiberias (Sea of Galilee intake), negev

**[S1090]** britannica.com, 'https://web.archive.org/web/2024/https://www.britannica.com/place/Sea-of-Galilee' — no URL (print) — archived: https://web.archive.org/web/2024/https://www.britannica.com/place/Sea-of-Galilee — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - pumping water from the Sea of Galilee to the centre and the northern Negev

**[S1091]** history.state.gov, 'Historical Documents - Office of the Historian' — https://history.state.gov/historicaldocuments/frus1964-68v18/d9 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Arab states saw it as diverting Jordan basin water

**[S1092]** history.state.gov, 'Historical Documents - Office of the Historian' — https://history.state.gov/historicaldocuments/frus1964-68v18/d129 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the Arab League launched a headwaters diversion plan

**[S1093]** history.state.gov, 'Historical Documents - Office of the Historian' — https://history.state.gov/historicaldocuments/frus1964-68v18/d222 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israeli-Syrian clashes over the works followed in 1964-67

**[S1094]** he.wikisource.org, 'פקודת צבא-הגנה לישראל – ויקיטקסט' — https://he.wikisource.org/wiki/%D7%A4%D7%A7%D7%95%D7%93%D7%AA_%D7%A6%D7%91%D7%90-%D7%94%D7%92%D7%A0%D7%94_%D7%9C%D7%99%D7%A9%D7%A8%D7%90%D7%9C — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the ordinance banned other armed forces

**[S1095]** documents.un.org, 'https://documents.un.org/api/symbol/access?s=S/3373&l=en&t=pdf' — https://documents.un.org/api/symbol/access?s=S/3373&l=en&t=pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: night of 28 February - 1 March 1955
    - Israeli paratroopers attacked an Egyptian army base near Gaza City
    - Reprisal for fedayeen infiltrations
    - 37-38 Egyptian soldiers killed
    - Neutrality: civilian casualties in Gaza omitted from the casualty record
    - 8 Israeli dead

**[S1096]** documents.un.org, 'https://documents.un.org/api/symbol/access?s=S/RES/106(1955)&l=en&t=pdf' — https://documents.un.org/api/symbol/access?s=S/RES/106(1955)&l=en&t=pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - UN condemnation (context, not in summary): Security Council Resolution 106 condemned the attack

**[S1097]** avalon.law.yale.edu, 'The Avalon Project : United Nations Security Council Resolution 54; July 15, 1948' — https://avalon.law.yale.edu/20th_century/scres054.asp — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - truce date 11 June 1948 (UN primary)
    - Arab states declined to extend the truce (context for resumption)
    - the truce was ordered by the Security Council without time limit

**[S1098]** avalon.law.yale.edu, 'The Avalon Project : United Nations Security Council Resolution 50; May 29, 1948' — https://avalon.law.yale.edu/20th_century/scres050.asp — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - four-week truce, with an arms embargo

**[S1099]** history.state.gov, 'Historical Documents - Office of the Historian' — https://history.state.gov/historicaldocuments/frus1949v06/d647 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date: admitted 11 May 1949 by General Assembly Resolution 273
    - vote was 37 to 12 with 9 abstentions

**[S1100]** RETIRED (no longer cited) — history.state.gov, 'Historical Documents - Office of the Historian' — https://history.state.gov/historicaldocuments/frus1949v06/d504

**[S1101]** avalon.law.yale.edu, 'The Avalon Project : United Nations Security Council Resolution 61; November 4, 1948' — https://avalon.law.yale.edu/20th_century/scres061.asp — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - lasted, with breaches, until Israel's October offensives (Negev)

**[S1102]** avalon.law.yale.edu, 'Avalon Project - A Decade of American Foreign Policy 1941-1949 - Conclusions From Progress Report of the United Nations Mediator on Palestine, September 16, 1948' — https://avalon.law.yale.edu/20th_century/decad170.asp — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - breaches during the second truce
    - Lehi opposed his proposals to modify the partition borders and to internationalise Jerusalem

**[S1103]** archives.mod.gov.il, 'The security portfolio was imposed on me…' — https://archives.mod.gov.il/sites/English/Exhibitions/David_Ben_Gurion_and_the_IDF/Pages/The-security-portfolio.aspx — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: December 1953 (month precision)
    - Ben-Gurion was back in the cabinet as Defence Minister after Lavon's resignation (before the election)

**[S1104]** en.idi.org.il, '1955 - The Israel Democracy Institute' — https://en.idi.org.il/israeli-elections-and-parties/elections/1955/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Third Knesset election held on 26 July 1955
    - Mapai fell to 40 seats
    - Herut rose to 15 seats
    - Turnout was 82.8%

**[S1105]** avalon.law.yale.edu, 'The Avalon Project : United Nations Security Council Resolution 59; October 19, 1948' — https://avalon.law.yale.edu/20th_century/scres059.asp — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1948-09-17: Bernadotte shot dead in Jerusalem

**[S1106]** avalon.law.yale.edu, 'The Avalon Project : United Nations Security Council Resolution 57; September 18, 1948' — https://avalon.law.yale.edu/20th_century/scres057.asp — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - The killing drew international condemnation

**[S1107]** news.alaskaair.com, 'From the archives: How Alaska Airlines evacuated 49,000 Yemenite Jews to Israel 'on the wings of eagles' - Alaska Airlines, Hawaiian Airlines and Horizon Air' — https://news.alaskaair.com/alaska-airlines/on-eagles-wings/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - some 49,000 Jews were flown to Israel

**[S1108]** archives.jdc.org, 'James Wooten’s Home Movies | JDC Archives' — https://archives.jdc.org/james-wootens-home-movies/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - nearly all were from Yemen (places: yemen)
    - flown from a JDC transit camp in Aden
    - in about 380 flights
    - dates: June 1949 to September 1950 (date_end 1950-09-24)
    - date_end: airlift ended 19 September 1950 (JDC also counts it from December 1948)

**[S1109]** jewishvirtuallibrary.org, 'Yemen' — https://www.jewishvirtuallibrary.org/yemen-2 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - transit camp at Aden (Camp Ge'ullah)
    - many arrivals were placed in immigrant camps

**[S1110]** documents.un.org, 'https://documents.un.org/api/symbol/access?s=A/6797&l=en&t=pdf' — https://documents.un.org/api/symbol/access?s=A/6797&l=en&t=pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1967-06-05 to 1967-12-31: displacement during and after the June 1967 hostilities (places: west_bank, gaza_strip, golan_heights, jordan, syria)
    - a large part of the population of the newly occupied areas left or was expelled
    - by December 1967 about 245,000 people crossed from the West Bank and Gaza Strip to Jordan and about 11,000 from Gaza to Egypt (Bowker)
    - from the Golan Heights, estimates of Syrians who fled or were expelled range from about 80,000 (Morris) to about 116,000 including Palestinians (McDowall)
    - few were allowed to return
    - neutrality: omits Egyptian civilians displaced from Sinai (e.g. East Kantara)
    - place: quneitra (captured on the Golan)
    - Israel now governed more than three-quarters of a million Palestinians in the occupied territories
    - UN report: about 200,000 moved from the West Bank to the East Bank (93,000 UNRWA refugees); about 35,000 crossed the Suez Canal from Gaza or Sinai
    - about 35,000 crossed the Suez Canal from the Gaza Strip or Sinai (places: gaza_strip, sinai, egypt)
    - Golan: about 110,000 (Syrian sources) to not more than 85,000 (Israeli sources), incl. about 17,000 Palestinian refugees
    - East Kantara (Sinai): only 1,116 of about 15,000 inhabitants remained (place: sinai)
    - UN Special Representative: Qalqilya's pre-war population was some 13,000 to 14,000
    - Mayor's account (UN report): remaining population taken to Azun, then Nablus
    - UN report: about 850 of some 2,000 dwellings demolished, per the mayor's account
    - UN report: Israeli military governor attributed the destruction partly to tanks, partly to dynamite
    - UN Special Representative's report (A/6797, September 1967) on the West Bank under Israeli military authorities after the June 1967 war: Special Representative visited Qalqiliya among the main West Bank towns
    - UN Special Representative's report (A/6797, September 1967) on the West Bank under Israeli military authorities after the June 1967 war: post offices reopened in Hebron, Bethlehem, Ramallah, Jericho, Nablus and Tulkarm
    - UN Special Representative's report (A/6797, September 1967) on the West Bank under Israeli military authorities after the June 1967 war: Special Representative visited Hebron, Bethlehem, Nablus and Qalqiliya
    - UN Special Representative visited Bethlehem on 11 August 1967 and reported on the municipality under Israeli occupation
    - UN Special Representative's report (A/6797, September 1967) on the West Bank under Israeli military authorities after the June 1967 war: the post office in Jenin reopened, bringing the West Bank total to six
    - UN Special Representative's report (A/6797, September 1967) on the West Bank under Israeli military authorities after the June 1967 war: Special Representative visited Hebron, Bethlehem, Nablus and Qalqiliya in August 1967 and describes Israeli measures there
    - UN Special Representative (1967): Kuneitra had an original population of 20 to 30,000
    - UN Special Representative's mission to the Israeli-held Golan (Aug 1967): in Kuneitra only some 200 of an original 20 to 30,000 civilians remained
    - UN report: population of the occupied Golan reduced to some 6,000 Druzes and 250 other civilians, mainly in Kuneitra
    - UN Special Representative (1967): Israeli authorities in the Gaza Strip opened welfare bureaus in Khan Yunis and Rafah

**[S1111]** bura.brunel.ac.uk, 'Brunel University Research Archive: The 1967 ‘Six Day’ Arab-Israeli War' — https://bura.brunel.ac.uk/handle/2438/12122?mode=full — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israeli deaths upper figure 983
    - Egyptian losses over 10,000 killed and missing; 6,000 for Jordan

**[S1112]** pij.org, 'PIJ.ORG: Israeli Policy in Jerusalem after 1967 By Sufyan Abu-Zayda' — https://pij.org/articles/1047/israeli-policy-in-jerusalem-after-1967 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 27-28 June 1967: Israel applied Israeli law and administration and extended the Jerusalem municipal boundary (places: jerusalem, east_jerusalem)
    - the extension took in East Jerusalem and about 70 km2 of surrounding West Bank land
    - the extension took in about 70 km2 (71,000 dunams): about 6 km2 of East Jerusalem and land of some 28 surrounding villages
    - rest of the land taken from some 28 villages
    - Palestine-Israel Journal: 27-28 June 1967 Israeli law extended and new Jerusalem municipal boundaries proclaimed
    - Parts of Jerusalem including the Old City were under Jordanian rule 1948-67
    - 27-28 June 1967: Israeli law extended and new municipal boundaries proclaimed, incorporating the Old City
    - Israel's aim since occupying East Jerusalem in June 1967 was sovereignty over the whole city

**[S1113]** bu.edu, 'JERUSALEM AND THE HOLY PLACES' — https://www.bu.edu/mzank/Jerusalem/tx/UN2253-1967.htm — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - UN General Assembly resolution 2253 of 4 July 1967 considered the measures invalid and called on Israel to rescind them

**[S1114]** britannica.com, 'Yigal Allon | Labor leader, Knesset member, General | Britannica' — no URL (print) — archived: https://web.archive.org/web/20241228020917/https://www.britannica.com/biography/Yigal-Allon — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the densely populated hill areas would return to Jordan or to Palestinian self-rule
    - the plan was never formally adopted
    - choice (historical): plan formally unadopted but used as informal guide (Jordan Valley, Etzion bloc settlement)

**[S1115]** israeled.org, 'https://israeled.org/wp-content/uploads/2017/02/1967.6.19-Peace-Plan.pdf' — https://israeled.org/wp-content/uploads/2017/02/1967.6.19-Peace-Plan.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - on 19 June 1967 the cabinet secretly decided to offer Sinai and the Golan for peace with Egypt and Syria

**[S1116]** issforum.org, 'https://issforum.org/reviews/PDF/AR414.pdf' — https://issforum.org/reviews/PDF/AR414.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 19 June decision as an 'offer' (scholarly disagreement on whether it was conveyed)

**[S1117]** jewishvirtuallibrary.org, 'Geography of Israel: The Etzion Bloc (Gush Etzion)' — https://www.jewishvirtuallibrary.org/the-etzion-bloc-gush-etzion — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date September 1967 (month precision): Kfar Etzion re-established (places: kfar_etzion, west_bank)

**[S1118]** idekel.co.il, 'https://idekel.co.il/Books/israels_cradle/files/basic-html/page276.html' — https://idekel.co.il/Books/israels_cradle/files/basic-html/page276.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the group was led by Hanan Porat

**[S1119]** jewishvirtuallibrary.org, 'Kefar Eẓyon' — https://www.jewishvirtuallibrary.org/kefar-e-x1e93-yon — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the group included children of the kibbutz's 1948 defenders

**[S1120]** haimwatzman.com, 'Settlement and Occupation – Historical Documents – South Jerusalem' — no URL (print) — archived: https://web.archive.org/web/20250115223632/https://haimwatzman.com/settlement-and-occupation-historical-documents/ — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - re-established with cabinet approval

**[S1121]** haimwatzman.com, 'https://web.archive.org/web/20260119030137/https://haimwatzman.com/tag/etzion-bloc/' — no URL (print) — archived: https://web.archive.org/web/20260119030137/https://haimwatzman.com/tag/etzion-bloc/ — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - despite legal advice that civilian settlement in occupied territory would contravene the Fourth Geneva Convention
    - generally regarded as the first Israeli settlement in the West Bank after 1967

**[S1122]** usni.org, 'https://web.archive.org/web/20250525044356/https://www.usni.org/magazines/naval-history-magazine/2008/october/cruise-missile-comes-age' — no URL (print) — archived: https://web.archive.org/web/20250525044356/https://www.usni.org/magazines/naval-history-magazine/2008/october/cruise-missile-comes-age — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1967-10-21: destroyer Eilat attacked off Port Said (places: sinai, suez_canal)
    - Egyptian Komar-class missile boats fired Soviet-made Styx missiles and sank the Eilat
    - 47 of its 199 crew were killed or missing

**[S1123]** catalog.archives.gov.il, 'https://catalog.archives.gov.il/site/en/chapter/summary4' — https://catalog.archives.gov.il/site/en/chapter/summary4 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel retaliated by shelling the oil refineries at Port Suez

**[S1124]** notoleranceforantisemitism.adl.org, 'United Nations Security Council Resolution 242/338 | No Tolerance for Antisemitism' — https://notoleranceforantisemitism.adl.org/resources/backgrounder/united-nations-security-council-resolution-242338 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Arab states read it as requiring withdrawal from all territories; Israel read it as linked to negotiated borders

**[S1125]** archives.mod.gov.il, 'INS Dakar' — https://archives.mod.gov.il/sites/English/Exhibitions/Pages/DAKAR.aspx — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - submarine Dakar was newly acquired from Britain and lost on its delivery voyage (place: abroad)
    - lost with all 69 crew (official)
    - wreck located between Crete and Cyprus in May 1999

**[S1126]** nauticos.com, 'https://nauticos.com/ocean-discovery/dakar/' — https://nauticos.com/ocean-discovery/dakar/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1968-01-25: last signal 25 January 1968; lost with all 69 crew

**[S1127]** learnpalestine.qeh.ox.ac.uk, 'Teach the Revolution' — https://learnpalestine.qeh.ox.ac.uk/teach/week/7 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1968-03-21: Israeli forces raided the Fatah base at Karameh in the Jordan Valley (places: jordan, jericho)
    - neutrality: omits Palestinian civilian/property losses in Karameh camp
    - most of Karameh camp was destroyed and 175 homes razed

**[S1128]** villagevoice.com, 'Yasir Arafat, 1929–2004 - The Village Voice' — https://www.villagevoice.com/2004/11/09/yasir-arafat-19292004/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - raid was in response to guerrilla attacks; Jordanian army units joined the fighting
    - Israeli dead given as 28-33
    - Palestinian fighters killed about 100-200
    - Israel withdrew the same day
    - Fatah presented the battle as a victory and recruitment to Palestinian guerrilla groups rose sharply
    - up to half of the several hundred Palestinian fighters were killed
    - Israeli dead 28, wounded 70 (Village Voice)

**[S1129]** jordantimes.com, 'Kingdom marks 51st anniversary of Karameh Battle | Jordan Times' — no URL (print) — archived: https://web.archive.org/web/20190321211710/http://jordantimes.com/node/318290 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Jordanian dead about 40-84
    - Jordanian government figure: 86 Jordanians killed

**[S1130]** britannica.com, 'Hamas | Definition, History, Ideology, & Facts | Britannica' — no URL (print) — archived: https://web.archive.org/web/20250101213732/https://www.britannica.com/topic/Hamas — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Hamas founded in December 1987 at the start of the first intifada
    - Organised in part by members of the Muslim Brotherhood
    - Under Sheikh Ahmed Yassin

**[S1131]** kinghussein.gov.jo, 'Address to the Nation' — http://www.kinghussein.gov.jo/88_july31.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: announced 31 July 1988
    - Place: amman (address delivered from Amman)

**[S1132]** un.org, 'Dismantling legal and administrative links with West Bank - King Hussein of Jordan address to the nation - Non-UN document - Question of Palestine' — no URL (print) — archived: https://web.archive.org/web/20231214011031/https://www.un.org/unispal/document/auto-insert-202739/ — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - King Hussein announced Jordan was severing legal and administrative ties with the West Bank
    - After 38 years of union of the two banks
    - Deferring to the PLO as representative of the Palestinians

**[S1133]** knesset.gov.il, 'Governments of Israel' — no URL (print) — archived: https://web.archive.org/web/20160522174808/https://www.knesset.gov.il/govt/eng/GovtByNumber_eng.asp?govt=23 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Government (23rd) with Shamir PM and Peres in cabinet took office 22 Dec 1988
    - Date: 15 March 1990

**[S1134]** knesset.gov.il, 'https://web.archive.org/web/20160605004721/http://www.knesset.gov.il/govt/eng/GovtByNumber_eng.asp?govt=24' — no URL (print) — archived: https://web.archive.org/web/20160605004721/http://www.knesset.gov.il/govt/eng/GovtByNumber_eng.asp?govt=24 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - New government took office 11 June 1990

**[S1135]** britannica.com, 'https://web.archive.org/web/20241224001822/https://www.britannica.com/biography/Mahmoud-Darwish' — no URL (print) — archived: https://web.archive.org/web/20241224001822/https://www.britannica.com/biography/Mahmoud-Darwish — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Text drafted by poet Mahmoud Darwish

**[S1136]** nytimes.com, 'https://web.archive.org/web/20250110125724/https://www.nytimes.com/1988/11/15/world/plo-proclaims-palestine-to-be-an-independent-state-hints-at-recognizing-israel.html' — no URL (print) — archived: https://web.archive.org/web/20250110125724/https://www.nytimes.com/1988/11/15/world/plo-proclaims-palestine-to-be-an-independent-state-hints-at-recognizing-israel.html — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Read by Yasser Arafat
    - Places west_bank, gaza_strip (territory of the envisaged state)

**[S1137]** jewishvirtuallibrary.org, 'The Arab/Muslim World: The Gulf War' — https://www.jewishvirtuallibrary.org/the-gulf-war — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Iraq fired 39 Scud missiles at Israel
    - Mainly at Tel Aviv and Haifa (places tel_aviv, haifa)
    - Direct deaths were in the single digits; accounts including indirect deaths give higher totals
    - Iraq fired 39 Scuds at Israeli population centres
    - 74 deaths attributed, 2 by direct hits
    - Israel did not retaliate at US request

**[S1138]** jewishvirtuallibrary.org, 'Operation Solomon' — https://www.jewishvirtuallibrary.org/operation-solomon — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: 24-25 May 1991
    - Using Israeli Air Force and El Al aircraft
    - IDF: nearly 15,000 airlifted in 41 sorties

**[S1139]** israeled.org, 'https://israeled.org/operation-solomon-rescues-ethiopian-jews/' — https://israeled.org/operation-solomon-rescues-ethiopian-jews/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - In about 36 hours

**[S1140]** history.state.gov, 'Milestones in the History of U.S. Foreign Relations - Office of the Historian' — https://history.state.gov/milestones/1989-1992/madrid-conference — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Convened by the US and USSR, in Madrid
    - Israel sat for the first time at the same table with Syria, Lebanon, Egypt and a joint Jordanian-Palestinian delegation
    - Launched bilateral and multilateral tracks
    - The bilateral Washington talks had stalled by 1993
    - That government went on to negotiate with the PLO and Jordan
    - Choice 'Keep to the Madrid-format Washington talks without the PLO' was the existing official track (Jordanian-Palestinian delegation), stalled by 1993

**[S1141]** knesset.gov.il, 'Basic Laws - Summaries' — no URL (print) — archived: https://web.archive.org/web/20101227160037id_/http://www.knesset.gov.il/description/eng/eng_mimshal_yesod2.htm — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Basic Law: Human Dignity and Liberty passed 17 March 1992 by the 12th Knesset
    - The first Basic Laws protecting individual rights
    - The same Knesset enacted direct election of the prime minister (Basic Law: The Government 1992)
    - Direct election first used in 1996
    - Under the restored parliamentary system (direct PM election repealed)

**[S1142]** knesset.gov.il, 'https://web.archive.org/web/20110101121604id_/http://www.knesset.gov.il/description/eng/eng_mimshal_yesod1.htm' — no URL (print) — archived: https://web.archive.org/web/20110101121604id_/http://www.knesset.gov.il/description/eng/eng_mimshal_yesod1.htm — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Basic Law: Freedom of Occupation also passed by the 12th Knesset in 1992

**[S1143]** en.idi.org.il, '1992 - The Israel Democracy Institute' — https://en.idi.org.il/israeli-elections-and-parties/elections/1992/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: 23 June 1992
    - Labor under Rabin won 44 seats to Likud's 32
    - Threshold had been raised to 1.5%
    - Rabin formed a Labor-led government

**[S1144]** hrw.org, 'Israel' — https://www.hrw.org/reports/1996/Israel.htm — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: began 25 July 1993
    - After Hezbollah attacks on Israeli forces and rocket fire on northern Israel
    - Week-long air and artillery campaign in south Lebanon (place south_lebanon)
    - IDF warned civilians in the south to leave
    - Some 300,000 people displaced for about a week
    - A US-brokered understanding ended it on 31 July
    - Neutrality: Israeli casualties omitted
    - Some 120 Lebanese civilians killed, close to 500 injured
    - Some 300,000 temporarily displaced
    - Two Israeli civilians killed and 24 injured by Hezbollah rockets
    - Stated Israeli objective: refugee flow to pressure the Lebanese government
    - Refugee flow aimed toward Beirut
    - US-brokered understanding took effect 31 July 1993
    - Katyusha attack on Kiryat Shmona killed two civilians (place kiryat_shmona)
    - Warnings designed to displace upwards of 400,000
    - Qana: more than 100 displaced civilians killed
    - SLA headquarters at Marjayoun controlled access in the Israeli-occupied area
    - Israel shelled population centres in response to attacks on its forces in the zone
    - Both Israeli deaths were in Kiryat Shmona on 25 July, first day of Operation Accountability (place kiryat_shmona)
    - About half of Kiryat Shmona left during the operation
    - Hezbollah's own count: seventeen of its fighters killed (as of Oct 1993 interview)
    - IDF estimate (May 1994): fifty to eighty guerrillas killed
    - Lebanese PM Hariri: one soldier, eight Hezbollah fighters, 118 civilians killed

**[S1145]** peacemaker.un.org, 'Wayback Machine' — no URL (print) — archived: https://web.archive.org/web/20240114213738/https://peacemaker.un.org/sites/peacemaker.un.org/files/IL%20PS_930913_DeclarationPrinciplesnterimSelf-Government%28Oslo%20Accords%29.pdf — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: signed 13 September 1993 in Washington (place washington)
    - Provided for an elected Palestinian interim self-government in the West Bank and Gaza for a transitional period of up to five years
    - Permanent-status issues (Jerusalem, refugees, settlements, borders) left to later negotiation

**[S1146]** history.state.gov, 'Milestones in the History of U.S. Foreign Relations - Office of the Historian' — https://history.state.gov/milestones/1993-2000/oslo — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Signed on the White House lawn
    - After secret talks in Norway (place oslo)
    - Israel and the PLO had exchanged letters of recognition
    - Choice 'Recognise the PLO and sign' was the historical decision of Rabin's government
    - Divided the West Bank into Areas A, B and C
    - US-hosted summit at Wye River, Maryland, between Netanyahu and Arafat
    - For final-status talks
    - Jerusalem/Temple Mount and Palestinian refugees the central disputes
    - Ended without a settlement; disputes over borders, Jerusalem and refugees' right of return

**[S1147]** nobelprize.org, 'Press release - The Nobel Peace Prize 1994 - NobelPrize.org' — https://www.nobelprize.org/prizes/peace/1994/press-release/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: announced 14 October 1994 by the Norwegian Nobel Committee

**[S1148]** nobelprize.org, 'The Nobel Peace Prize 1994 - Presentation Speech - NobelPrize.org' — https://www.nobelprize.org/prizes/peace/1994/ceremony-speech/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Presented in Oslo on 10 December 1994 (place oslo)

**[S1149]** jewishvirtuallibrary.org, 'The Dizengoff Street Bus Bombing' — https://www.jewishvirtuallibrary.org/the-dizengoff-street-bus-bombing — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: 19 October 1994
    - Killing 22 people (21 Israelis and a Dutch national)
    - At the time it was the deadliest suicide bombing in Israel
    - 21 Israelis and one Dutch national killed
    - Deadliest at the time

**[S1150]** un.org, 'https://web.archive.org/web/20231214235156/https://www.un.org/unispal/document/auto-insert-177253/' — no URL (print) — archived: https://web.archive.org/web/20231214235156/https://www.un.org/unispal/document/auto-insert-177253/ — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - No. 5 Dan bus on Dizengoff Street in Tel Aviv (place tel_aviv)
    - A Hamas suicide bomber
    - Injuring dozens
    - 22 killed, 48 injured (Israel's letter to the UN)
    - Hamas claimed responsibility

**[S1151]** jewishvirtuallibrary.org, 'Operation Protective Edge: Background & Overview' — https://www.jewishvirtuallibrary.org/background-and-overview-of-operation-protective-edge — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Start date 2014-07-08

**[S1152]** RETIRED (no longer cited; superseded by S851) — ochaopt.org, 'https://www.ochaopt.org/sites/default/files/ocha_opt_sitrep_28_08_2014.pdf' — https://www.ochaopt.org/sites/default/files/ocha_opt_sitrep_28_08_2014.pdf

**[S1153]** france24.com, 'Repatriated flotilla activists challenge Israeli version of deadly raid' — https://www.france24.com/en/20100601-repatriated-flotilla-activists-challenge-israeli-version-deadly-raid-israel-gaza — archived: https://web.archive.org/web/2026id_/https://www.france24.com/en/20100601-repatriated-flotilla-activists-challenge-israeli-version-deadly-raid-israel-gaza — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Several commandos injured (as of 1 June 2010, Israeli officials: seven troops wounded)
    - Israeli officials: nine activists killed, seven troops wounded
    - Some 30 wounded activists in hospital

**[S1154]** algemeiner.com, 'Israeli Ministers Officially Approve Reconciliation Deal with Turkey | Algemeiner.com' — https://www.algemeiner.com/2016/06/29/israeli-ministers-officially-approve-reconciliation-deal-with-turkey/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Compensation deal finalised in 2016

**[S1155]** haaretz.com, 'Haifa Police Chief Ahuva Tomer Dies of Injuries From Carmel Fire - Haaretz Com' — https://www.haaretz.com/news/national/haifa-police-chief-ahuva-tomer-dies-of-injuries-from-carmel-fire-1.329156 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Place: Mount Carmel near Haifa
    - Victims included police officers

**[S1156]** ynetnews.com, 'Aerial firefighting squadron becomes operational' — https://www.ynetnews.com/articles/0,7340,L-4067958,00.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - More than 17,000 people evacuated
    - Firefighting services reorganised and given an aerial firefighting squadron
    - Nearly 17,000 evacuated, 44 lives

**[S1157]** ynetnews.com, 'Yishai, Steinitz found liable for Carmel disaster' — https://www.ynetnews.com/articles/0,7340,L-4244642,00.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - State Comptroller report criticised the firefighting services

**[S1158]** en.idi.org.il, '2015 - The Israel Democracy Institute' — https://en.idi.org.il/israeli-elections-and-parties/elections/2015/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Election date 2015-03-17
    - Likud won 30 seats
    - Zionist Union (Labor-Hatnuah) won 24 seats
    - Joint List of Arab parties third with 13 seats
    - Turnout about 72%

**[S1159]** ynetnews.com, '71.8% voter turnout in Israel elections' — http://www.ynetnews.com/articles/0,7340,L-4637591,00.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Turnout about 72% (cross-check, election-night estimate)

**[S1160]** RETIRED (no longer cited) — aljazeera.com, 'How October 7 changed Lebanon and Hezbollah’s political reality | Israel attacks Lebanon News | Al Jazeera' — https://www.aljazeera.com/news-analysis/2026/10/9/how-october-7-changed-lebanon-and-hezbollahs-political-reality

**[S1161]** press.un.org, 'Client Challenge' — https://press.un.org/en/2016/sc12657.doc.htm — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date 2016-12-23
    - Adopted 14-0 with the US abstaining instead of vetoing
    - US abstention (not veto)
    - Settlements in territory occupied since 1967, including East Jerusalem, have 'no legal validity' and are a 'flagrant violation' of international law
    - Covers territory occupied since 1967 including East Jerusalem
    - Israel rejected the resolution

**[S1162]** RETIRED (no longer cited) — aljazeera.com, 'Why have US-Iran strikes resumed and what does it mean for peace? | US-Israel war on Iran News | Al Jazeera' — https://www.aljazeera.com/news/2026/7/8/why-have-us-iran-strikes-resumed-and-what-does-it-mean-for-peace-talks

**[S1163]** ynet.co.il, 'המחאה מתפשטת: אוהלים בבאר שבע ובצפון' — http://www.ynet.co.il/articles/0,7340,L-4096185,00.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Start date 14 July 2011 with tents on Rothschild Boulevard (Ynet 17 July 2011: camp up 'three days', 'first weekend')

**[S1164]** ynetnews.com, ''Trajtenberg vote fiasco prelude to elections'' — https://www.ynetnews.com/articles/0,7340,L-4130744,00.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Trajtenberg recommendations issued in December 2011
    - Recommendations rejected by protest leaders as insufficient
    - Trajtenberg recommendations before the cabinet by early October 2011 (Ynet, 3 Oct 2011)

**[S1165]** mobileye.com, 'About Mobileye | Our Vision, History, and Milestones' — https://www.mobileye.com/about/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Mobileye makes camera-based driver-assistance and autonomous-driving systems

**[S1166]** nbcnews.com, 'Sudan formally recognizes Israel in U.S.-brokered deal' — https://www.nbcnews.com/news/world/sudan-formally-recognizes-israel-u-s-brokered-deal-n1240839 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date/place: signed at the White House on 15 Sept 2020
    - First Arab states to establish relations with Israel since Jordan in 1994
    - Date: Israel and Sudan agreed to normalize relations on 23 Oct 2020 in a joint statement
    - Mediated by the Trump administration

**[S1167]** washingtoninstitute.org, 'The Fighting in Sudan Threatens Peace Efforts with Israel | The Washington Institute' — https://www.washingtoninstitute.org/policy-analysis/fighting-sudan-threatens-peace-efforts-israel — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - A formal bilateral agreement remained unratified

**[S1168]** nobelprize.org, 'Press release: The Nobel Prize in Chemistry 2011 - NobelPrize.org' — https://www.nobelprize.org/prizes/chemistry/2011/press-release/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: prize announced 5 October 2011
    - Technion professor (place: Haifa)
    - For the discovery of quasicrystals
    - First observed in April 1982
    - Long rejected by many peers

**[S1169]** trumpwhitehouse.archives.gov, 'Statement by President Trump on Jerusalem – The White House' — https://trumpwhitehouse.archives.gov/briefings-statements/statement-president-trump-jerusalem/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date 2017-12-06: Trump announced recognition of Jerusalem as Israel's capital
    - Ordered the embassy moved from Tel Aviv
    - Said the step did not prejudge final borders

**[S1170]** pmc.ncbi.nlm.nih.gov, 'Checking your browser - reCAPTCHA' — https://pmc.ncbi.nlm.nih.gov/articles/PMC7835664 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: Israel began its national vaccination campaign on 20 Dec 2020
    - One of the world's fastest national vaccination campaigns
    - Starting with health workers, the elderly and high-risk groups
    - Using Pfizer doses secured for most of its population
    - Using Moderna doses as well
    - Places: tel_aviv, jerusalem

**[S1171]** ynetnews.com, '2nd phase of Shalit deal underway' — http://www.ynetnews.com/articles/0,7340,L-4162961,00.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 550 released in December 2011

**[S1172]** ynetnews.com, 'Cabinet approves Shalit deal' — http://www.ynetnews.com/articles/0,7340,L-4134408,00.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Many of them convicted of deadly attacks
    - Choice (historical): approved by the Israeli government in October 2011 (vote 26-3)
    - Choice (non-historical): refuse to release prisoners convicted of murder — stance of critics of the deal (ministers Landau, Lieberman, Yaalon voted against)

**[S1173]** aljazeera.com, 'Israel, Morocco agree to normalise relations in US-brokered deal | News | Al Jazeera' — https://www.aljazeera.com/news/2020/12/10/israel-morocco-agree-to-normalise-relations-in-us-brokered-deal — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel and Morocco agreed to normalise relations (announced 10 Dec 2020)
    - Linked to US recognition of Moroccan sovereignty claims over Western Sahara
    - Neutrality: affected parties' reactions (Polisario Front, Palestinians) not mentioned
    - Polisario reaction
    - PLO official condemned the deal

**[S1174]** text.npr.org, 'Morocco Agrees To Join Trump Administration's Abraham Accords' — https://text.npr.org/945136662 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Cross-check: Morocco will normalize ties under the US-brokered deal

**[S1175]** RETIRED (no longer cited; superseded by S853) — ohchr.org, 'https://www.ohchr.org/Documents/HRBodies/HRCouncil/CoIOPT/A_HRC_40_74.pdf' — https://www.ohchr.org/Documents/HRBodies/HRCouncil/CoIOPT/A_HRC_40_74.pdf

**[S1176]** RETIRED (no longer cited; superseded by S850) — documents.un.org, 'https://documents.un.org/doc/undoc/gen/g13/154/84/pdf/g1315484.pdf' — https://documents.un.org/doc/undoc/gen/g13/154/84/pdf/g1315484.pdf

**[S1177]** RETIRED (no longer cited) — timesofisrael.com, 'https://www.timesofisrael.com/on-day-of-nasrallah-funeral-idf-publishes-videos-of-strike-that-killed-him/' — https://www.timesofisrael.com/on-day-of-nasrallah-funeral-idf-publishes-videos-of-strike-that-killed-him/

**[S1178]** RETIRED (no longer cited) — nbcnews.com, 'Israel-Hezbollah: Israel says strike in Beirut targeted Hezbollah leader Hassan Nasrallah' — https://www.nbcnews.com/news/world/live-blog/israel-hezbollah-live-updates-health-workers-killed-lebanon-rcna172975

**[S1179]** RETIRED (no longer cited) — jpost.com, 'IRGC deputy commander killed in Israeli strikes on Beirut, Lebanon | The Jerusalem Post' — https://www.jpost.com/breaking-news/article-822221

**[S1180]** RETIRED (no longer cited) — timesofisrael.com, 'Iran fires 181 missiles at Israel; PM: They made a 'big mistake' and 'will pay for it' | The Times of Israel' — https://www.timesofisrael.com/israel-warns-of-consequences-after-iran-launches-181-missiles-in-major-attack/

**[S1181]** news.un.org, 'General Assembly grants Palestine non-member observer State status at UN | UN News' — https://news.un.org/en/story/2012/11/427052 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date 29 Nov 2012: UNGA accorded Palestine non-member observer state status
    - Vote 138-9 with 41 abstentions
    - Israel voted against

**[S1182]** eurovision.com, 'Lisbon 2018' — https://www.eurovision.com/eurovision-song-contest/lisbon-2018/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date 2018-05-12 (Grand Final)
    - Netta Barzilai won with 'Toy' in Lisbon

**[S1183]** timesofisrael.com, 'https://www.timesofisrael.com/a-steep-slippery-ramp-uneven-stairs-walking-the-route-of-the-meron-disaster/' — https://www.timesofisrael.com/a-steep-slippery-ramp-uneven-stairs-walking-the-route-of-the-meron-disaster/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 45 people killed
    - Victims mostly Haredi men and boys
    - In an overcrowded, sloping passageway
    - Places: safed, galilee (Mount Meron, Upper Galilee)

**[S1184]** timesofisrael.com, 'https://www.timesofisrael.com/state-inquiry-blames-netanyahu-but-does-not-sanction-him-for-deadly-2021-meron-crush/' — https://www.timesofisrael.com/state-inquiry-blames-netanyahu-but-does-not-sanction-him-for-deadly-2021-meron-crush/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - State commission of inquiry (2024) held Netanyahu personally responsible
    - Commission held Netanyahu and other officials personally responsible and recommended removing the police chief [parent second pass]

**[S1186]** trumpwhitehouse.archives.gov, 'President Donald J. Trump Keeps His Promise To Open U.S. Embassy In Jerusalem, Israel – The White House' — https://trumpwhitehouse.archives.gov/briefings-statements/president-donald-j-trump-keeps-promise-open-u-s-embassy-jerusalem-israel/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - US embassy formally opened in Jerusalem on 14 May 2018
    - On Israel's 70th anniversary

**[S1187]** RETIRED (no longer cited) — aljazeera.com, 'Iran says four soldiers killed, radar systems hit in Israeli strikes | Israel attacks Lebanon News | Al Jazeera' — https://www.aljazeera.com/news/2024/10/26/iran-says-israeli-strikes-on-military-bases-caused-limited-damage

**[S1188]** RETIRED (no longer cited) — timesofisrael.com, 'https://www.timesofisrael.com/iran-says-it-has-duty-to-defend-itself-after-israeli-strikes-2-soldiers-killed/' — https://www.timesofisrael.com/iran-says-it-has-duty-to-defend-itself-after-israeli-strikes-2-soldiers-killed/

**[S1189]** ochaopt.org, 'Response to the escalation in the oPt | Situation Report No. 1 (21-27 May 2021) | United Nations Office for the Coordination of Humanitarian Affairs - Occupied Palestinian Territory' — https://www.ochaopt.org/content/response-escalation-opt-situation-report-no-1-21-27-may-2021 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Dates: hostilities began 10 May 2021; ceasefire took effect 21 May 2021
    - Hamas and other Gaza groups fired rockets toward Jerusalem and central Israel from 10 May; 11-day Israeli air campaign
    - Earlier count attributed to OHCHR
    - Earlier count: 256 killed by 27 May

**[S1190]** aljazeera.com, 'Israel passes controversial ‘Jewish nation-state’ law | News | Al Jazeera' — https://www.aljazeera.com/news/2018/7/19/israel-passes-controversial-jewish-nation-state-law — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date 2018-07-19; Knesset passed the law 62-55
    - Downgrading Arabic from an official language to one with 'special status'
    - Critics included Arab and Druze citizens
    - Jewish organisations such as the AJC objected
    - Clause permitting Jewish-only communities dropped after objections from the president and attorney general
    - Choice (non-historical): pass original draft with Jewish-only communities clause - genuinely proposed
    - Choice (non-historical): shelve the bill - position of the 55 MKs who voted against
    - Supporters: Netanyahu called the passage a defining moment in the annals of Zionism
    - Supporters' stated rationale: the majority also has rights and the majority decides
    - Supporters' stated rationale: ensure the state's Jewish character
    - Supporters' stated rationale (continued): Jewish character for generations
    - Critics: Ayman Odeh (Joint List) called it a law of Jewish supremacy
    - Critics: Adalah said the law features key elements of apartheid

**[S1191]** main.knesset.gov.il, 'https://main.knesset.gov.il/EN/activity/documents/BasicLawsPDF/BasicLawNationState.pdf' — https://main.knesset.gov.il/EN/activity/documents/BasicLawsPDF/BasicLawNationState.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Right to national self-determination in Israel 'unique to the Jewish people'
    - Choice (historical): pass the law with the softened settlement clause

**[S1193]** timesofisrael.com, 'https://www.timesofisrael.com/liveblog_entry/bennett-lapid-government-wins-knesset-majority-netanyahu-is-out-after-12-years/' — https://www.timesofisrael.com/liveblog_entry/bennett-lapid-government-wins-knesset-majority-netanyahu-is-out-after-12-years/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Vote 60-59
    - Ended Netanyahu's 12 consecutive years in office

**[S1194]** timesofisrael.com, 'https://www.timesofisrael.com/liveblog_entry/document-signed-by-8-parties-in-intended-new-government/' — https://www.timesofisrael.com/liveblog_entry/document-signed-by-8-parties-in-intended-new-government/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Broad coalition of eight parties

**[S1195]** RETIRED (no longer cited; superseded by S863) — timesofisrael.com, 'https://www.timesofisrael.com/arab-israeli-raam-party-makes-history-by-joining-bennett-lapid-coalition/' — https://www.timesofisrael.com/arab-israeli-raam-party-makes-history-by-joining-bennett-lapid-coalition/

**[S1196]** ide-tech.com, 'Sorek I Desalination Plant (Israel) | IDE Tech' — https://ide-tech.com/en/project/sorek-desalination-plant/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Sorek began operating in 2013 (event date 2013-10, month precision)
    - Place: south of Tel Aviv (rishon_lezion)
    - Capacity about 150 million cubic metres a year
    - Then the largest of its kind in the world

**[S1197]** timesofisrael.com, 'How Israel beat the drought | The Times of Israel' — https://www.timesofisrael.com/how-israel-beat-the-drought/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Other plants at Ashkelon, Palmachim and Hadera

**[S1198]** timesofisrael.com, 'https://www.timesofisrael.com/jerusalems-new-high-speed-train-starts-regular-trips-to-ben-gurion-airport/' — https://www.timesofisrael.com/jerusalems-new-high-speed-train-starts-regular-trips-to-ben-gurion-airport/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Passenger service Jerusalem-Ben Gurion Airport began 2018-09-25
    - Electrified railway
    - From Jerusalem's deep-level Yitzhak Navon station

**[S1199]** timesofisrael.com, 'https://www.timesofisrael.com/liveblog_entry/netanyahu-declares-state-of-emergency-in-lod/' — https://www.timesofisrael.com/liveblog_entry/netanyahu-declares-state-of-emergency-in-lod/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: 11 May 2021, state of emergency declared in Lod during the Gaza fighting

**[S1200]** timesofisrael.com, 'https://www.timesofisrael.com/prosecutors-clear-suspects-in-deadly-shooting-of-arab-lod-man-during-may-riots/' — https://www.timesofisrael.com/prosecutors-clear-suspects-in-deadly-shooting-of-arab-lod-man-during-may-riots/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - An Arab man was shot dead, allegedly by a Jewish resident

**[S1201]** timesofisrael.com, 'https://www.timesofisrael.com/israeli-seriously-hurt-in-lod-violence-dies-of-wounds/' — https://www.timesofisrael.com/israeli-seriously-hurt-in-lod-violence-dies-of-wounds/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Neutrality: Jewish fatality in Lod omitted

**[S1202]** timesofisrael.com, 'Soldier viciously beaten in Jaffa, synagogue burned in Lod, as rioting deepens | The Times of Israel' — https://www.timesofisrael.com/soldier-viciously-beaten-in-jaffa-synagogue-burned-in-lod-as-rioting-renews/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Neutrality: attacks by Jewish far-right rioters omitted
    - Places: ramla, acre

**[S1203]** timesofisrael.com, 'https://www.timesofisrael.com/liveblog-november-03-2022/' — https://www.timesofisrael.com/liveblog-november-03-2022/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: election 1 November 2022
    - Meretz and Balad fell below the 3.25% threshold

**[S1204]** timesofisrael.com, 'https://www.timesofisrael.com/netanyahu-announces-his-sixth-government-israels-most-hardline-yet/' — https://www.timesofisrael.com/netanyahu-announces-his-sixth-government-israels-most-hardline-yet/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Netanyahu formed his sixth government

**[S1205]** RETIRED (no longer cited) — timesofisrael.com, 'https://www.timesofisrael.com/idf-opens-fire-as-lebanese-return-to-southern-villages-where-troops-still-deployed/' — https://www.timesofisrael.com/idf-opens-fire-as-lebanese-return-to-southern-villages-where-troops-still-deployed/

**[S1206]** RETIRED (no longer cited) — bidenwhitehouse.archives.gov, 'Joint Statement from President Biden of the United States and President Macron of France Announcing a Cessation of Hostilities | The White House' — https://bidenwhitehouse.archives.gov/briefing-room/statements-releases/2024/11/26/joint-statement-from-president-biden-of-the-united-states-and-president-macron-of-france-announcing-a-cessation-of-hostilities/

**[S1207]** RETIRED (no longer cited) — timesofisrael.com, 'https://www.timesofisrael.com/liveblog_entry/security-cabinet-votes-10-1-to-approve-lebanon-ceasefire-deal/' — https://www.timesofisrael.com/liveblog_entry/security-cabinet-votes-10-1-to-approve-lebanon-ceasefire-deal/

**[S1208]** news4jax.com, 'Lebanon and Israel sign sea border deal' — https://www.news4jax.com/news/world/2022/10/27/lebanon-delivers-signed-sea-border-deal-to-us-mediator/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: 27 October 2022
    - Israel and Lebanon have no diplomatic relations
    - Separately signed the agreement at the UN post in Naqoura
    - US-mediated

**[S1209]** aljazeera.com, 'Lebanon, Israel reach ‘historic agreement’ on maritime borders | News | Al Jazeera' — https://www.aljazeera.com/news/2022/10/11/israel-lebanon-agree-on-draft-deal-on-maritime-borders — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Karish gas field lies on Israel's side
    - Lebanon may develop the Qana prospect through TotalEnergies

**[S1210]** RETIRED (no longer cited) — jpost.com, 'Israel launches Operation Rising Lion to target Iran's nuclear threat | The Jerusalem Post' — https://www.jpost.com/israel-news/defense-news/article-857577

**[S1211]** RETIRED (no longer cited) — timesofisrael.com, 'https://www.timesofisrael.com/liveblog_entry/idf-reveals-that-it-killed-six-top-iranian-military-commanders-and-nine-nuclear-scientists/' — https://www.timesofisrael.com/liveblog_entry/idf-reveals-that-it-killed-six-top-iranian-military-commanders-and-nine-nuclear-scientists/

**[S1212]** RETIRED (no longer cited) — timesofisrael.com, 'https://www.timesofisrael.com/4-killed-in-beersheba-as-iran-fires-multiple-missile-salvos-just-before-ceasefire/' — https://www.timesofisrael.com/4-killed-in-beersheba-as-iran-fires-multiple-missile-salvos-just-before-ceasefire/

**[S1213]** RETIRED (no longer cited) — aljazeera.com, 'US joins Israel in attacking Iran, strikes Fordow, Isfahan, Natanz sites | US-Israel war on Iran News | Al Jazeera' — https://www.aljazeera.com/news/2025/6/22/us-joins-israel-in-attacks-against-iran-strikes-key-nuclear-sites

**[S1214]** RETIRED (no longer cited) — en-hrana.org, 'Twelve Days Under Fire: A Comprehensive Report on the Iran-Israel War - Hrana' — https://www.en-hrana.org/twelve-days-under-fire-a-comprehensive-report-on-the-iran-israel-war/

**[S1215]** RETIRED (no longer cited) — timesofisrael.com, 'https://www.timesofisrael.com/un-slams-violation-of-1974-disengagement-deal-as-israel-acts-in-syria-buffer-zone/' — https://www.timesofisrael.com/un-slams-violation-of-1974-disengagement-deal-as-israel-acts-in-syria-buffer-zone/

**[S1216]** RETIRED (no longer cited) — jpost.com, 'Syria in negotiations with Israel, says Ahmed al-Sharaa | The Jerusalem Post' — https://www.jpost.com/middle-east/article-873546

**[S1218]** timesofisrael.com, '56 top int'l economists warn Netanyahu that legal overhaul will hurt economic growth | The Times of Israel' — https://www.timesofisrael.com/56-top-intl-economists-warn-netanyahu-that-legal-overhaul-will-hurt-economic-growth/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Warnings from economists

**[S1219]** timesofisrael.com, 'https://www.timesofisrael.com/histadrut-labor-chief-to-make-special-announcement-amid-growing-calls-for-strike/' — https://www.timesofisrael.com/histadrut-labor-chief-to-make-special-announcement-amid-growing-calls-for-strike/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Spontaneous mass demonstrations and a general strike

**[S1220]** timesofisrael.com, ''There can be no civil war': Full text of Netanyahu's announcement on overhaul pause | The Times of Israel' — https://www.timesofisrael.com/there-can-be-no-civil-war-full-text-of-netanyahus-announcement-on-overhaul-pause/ — archived: https://web.archive.org/web/2026/https://www.timesofisrael.com/there-can-be-no-civil-war-full-text-of-netanyahus-announcement-on-overhaul-pause/ — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Next day (27 March) Netanyahu paused the legislation
    - Choice (historical): pause the legislation for negotiations
    - Netanyahu took a time-out for dialogue
    - Netanyahu announced a time-out for dialogue on the judicial overhaul

**[S1221]** jpost.com, 'Benjamin Netanyahu fires Israel's Defense Minister Yoav Gallant | The Jerusalem Post' — https://www.jpost.com/breaking-news/article-827716 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Gallant's dismissal was not carried out

**[S1222]** timesofisrael.com, 'https://www.timesofisrael.com/mass-rally-at-knesset-as-pm-delays-planned-speech-right-plans-large-counter-protest/' — https://www.timesofisrael.com/mass-rally-at-knesset-as-pm-delays-planned-speech-right-plans-large-counter-protest/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Choice (non-historical): press ahead with final readings - position of coalition hardliners and Levin

**[S1223]** RETIRED (no longer cited) — france24.com, 'https://www.france24.com/en/middle-east/20250923-who-recognises-the-state-of-palestine-and-why-it-matters' — https://www.france24.com/en/middle-east/20250923-who-recognises-the-state-of-palestine-and-why-it-matters

**[S1224]** RETIRED (no longer cited) — timesofisrael.com, 'https://www.timesofisrael.com/israels-yuval-raphael-tops-eurovision-public-vote-finishes-in-2nd-place-as-austria-wins/' — https://www.timesofisrael.com/israels-yuval-raphael-tops-eurovision-public-vote-finishes-in-2nd-place-as-austria-wins/

**[S1225]** jns.org, 'Tel Aviv light rail to open to the public on Aug. 18 - Israel & Jewish News - JNS' — https://www.jns.org/tel-aviv-light-rail-to-open-to-the-public-friday/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: opened 18 August 2023
    - Through Bnei Brak, Ramat Gan and Tel Aviv
    - Partly underground

**[S1226]** timesofisrael.com, 'https://www.timesofisrael.com/israel-and-turkey-to-restore-ambassadors-in-full-renewal-of-diplomatic-ties/' — https://www.timesofisrael.com/israel-and-turkey-to-restore-ambassadors-in-full-renewal-of-diplomatic-ties/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Netanyahu apologised (2013) [parent second pass; partially rescues earlier drop]
    - Nine activists killed

**[S1227]** jpost.com, 'Israel goes back to elections as Benjamin Netanyahu fails to form coalition | The Jerusalem Post' — https://www.jpost.com/Israel-News/Elections-set-for-Sept-17-after-coalition-talks-fail-591044 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Netanyahu tasked with forming a government but failed to assemble 61 seats
    - Knesset voted to dissolve itself, triggering a repeat election (17 Sept 2019)

**[S1228]** zochrot.org, 'Zochrot - Remembering Bir al-Saba'' — https://zochrot.org/publication_articles/view/49869/en — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Beersheba conquered 20-21 Oct 1948 with aerial bombardment
    - Remaining men later transferred to POW camps
    - Testimony: residents put on trucks to Gaza
    - Beersheba conquered 20-21 October 1948 in Operation Yoav with aerial bombardment
    - remaining men transferred to POW camps
    - no remaining refugees from the city living within Israel
    - refugee testimony: people put on trucks and sent to Gaza
    - Beersheba conquered 20-21 Oct 1948 in Operation Yoav with aerial bombardment
    - Operation Yoav headed by Yigal Allon; part of conquest of Beersheba
    - No refugees from the city known to remain in Israel
    - Refugee testimony: residents put on trucks and sent to Gaza
    - Mixed population of Beersheba

**[S1229]** zochrot.org, 'Zochrot - al-Dawayima' — https://www.zochrot.org/villages/village_details/49115/en — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Al-Dawayima massacre on 29 Oct 1948 during Operation Yoav
    - al-Dawayima occupied 29 Oct 1948 by the 8th Brigade
    - 1948 population 4,300
    - Morris quotes a participant: 80 to 100 killed incl. women and children
    - massacre during Operation Yoav caused massive flight
    - investigations ineffectual; some soldiers disciplined
    - 89th Battalion responsible
    - Amatzya founded on village ruins in 1955
    - Occupied 29 Oct 1948 by the 8th Brigade
    - Occupying unit 8th Brigade
    - Massacre on 29 Oct 1948 during Operation Yoav caused mass flight
    - Morris quotes participant: 80-100 killed incl. women and children
    - Village 18 km from Hebron
    - 89th Battalion responsible (per Zochrot/Morris)
    - Investigations ineffectual; some soldiers disciplined

**[S1230]** palestineremembered.com, 'Najd - Gaza - نجد (נג'ד) - Palestine Remembered' — no URL (print) — archived: https://web.archive.org/web/2026/https://www.palestineremembered.com/Gaza/Najd/index.html — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Sderot was built on lands of the village of Najd, whose residents were expelled on 13 May 1948 (Palestine Remembered, drawing on W. Khalidi)
    - Sderot and Or HaNer on Najd's lands

**[S1231]** palquest.org, 'interactive encyclopedia of the palestine question – palquest | overall chronology' — https://www.palquest.org/en/overallchronology?nid=14334 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - All convicted soldiers released by 1960 after reductions or pardons

**[S1232]** theconversation.com, 'Remembering the Palestinians murdered at Kafr Qasim six decades ago' — https://theconversation.com/remembering-the-palestinians-murdered-at-kafr-qasim-six-decades-ago-67880 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Shadmi fined one hundredth of a lira
    - Curfew brought forward from 9pm to 5pm by Shadmi
    - Eight of 11 defendants given long sentences
    - Trials established the duty to defy blatantly illegal orders

**[S1233]** dailynewsegypt.com, 'Bahr Al-Baqar: When Israel Massacred Egyptian Children – Dailynewsegypt' — https://www.dailynewsegypt.com/2025/04/08/bahr-al-baqar-when-israel-massacred-egyptian-children/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Abu Zaabal factory bombing killed 89 workers
    - Bahr el-Baqar: 30 children killed
    - Israel said it targeted military installations

**[S1234]** csmonitor.com, 'A disturbing study of the man behind Israel's war in Lebanon - CSMonitor.com' — https://www.csmonitor.com/1985/0107/dbisra-f.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Cabinet thought it approved a 40 km incursion
    - Sharon moved troops forward into Beirut while telling ministers moves were dictated by events
    - The cabinet approved a 40 km incursion
    - Sharon moved forces forward into Beirut while telling ministers it was dictated by events
    - Sharon pursued a grander design: oust the PLO, install a Christian ally

**[S1235]** jewishvirtuallibrary.org, 'Cabinet Communique on the Withdrawal from Lebanon' — https://www.jewishvirtuallibrary.org/cabinet-communique-on-the-withdrawal-from-lebanon — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Phase C: IDF on the border with an SLA-held zone

**[S1236]** csmonitor.com, 'Israel plans Lebanon pullout by June 1. Cabinet decides that no Israeli troops will remain in security zone - CSMonitor.com' — https://www.csmonitor.com/1985/0422/ojune.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Arens and Sharon argued for a much deeper security zone

**[S1237]** rabincenter.org.il, '1974 - מרכז רבין' — https://www.rabincenter.org.il/en/?p=8990 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Rabin approved the Kadum settlement after hesitation

**[S1238]** digital.bentley.umich.edu, 'https://web.archive.org/web/2026/https://digital.bentley.umich.edu/djnews/djn.1976.04.30.001/8' — no URL (print) — archived: https://web.archive.org/web/2026/https://digital.bentley.umich.edu/djnews/djn.1976.04.30.001/8 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Peres supported the Gush demands for free settlement

**[S1239]** db.begincenter.org.il, 'My Plan for Peace - begincenter' — https://db.begincenter.org.il/en/article/my-plan-for-peace — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Begin proposed that Sinai settlements continue to exist in UN zones

**[S1240]** csmonitor.com, 'Resisting exodus from the land of Exodus - CSMonitor.com' — https://www.csmonitor.com/1981/1104/110447.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - The movement to stop the withdrawal was backed by Tehiya and Gush Emunim

**[S1241]** merip.org, 'Israel's "National Unity" - MERIP' — https://www.merip.org/1985/01/israels-national-unity — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Peres and Shamir both needed the national unity arrangement
    - Weizman's move blocked a narrow Likud government

**[S1242]** history.state.gov, 'Historical Documents - Office of the Historian' — https://history.state.gov/historicaldocuments/frus1948v05p2/d705 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel broke the Egyptian lines in the northern Negev; the offensive began after the 14 October truce positions (start 15 Oct)
    - end date 22 October 1948 (ceasefire)

**[S1243]** mfa.gov.il, 'VII THE RIVER JORDAN- INTRODUCTION' — no URL (print) — archived: https://web.archive.org/web/2016/http://www.mfa.gov.il/MFA/ForeignPolicy/MFADocuments/Yearbook1/Pages/VII%20THE%20RIVER%20JORDAN-%20INTRODUCTION.aspx — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date: month June 1964 (carrier completed/operational)
    - Arab League headwaters diversion plan (Cairo summit, January 1964)
    - Israeli-Syrian clashes over the works followed in 1964-67

**[S1244]** history.state.gov, 'Historical Documents - Office of the Historian' — https://history.state.gov/historicaldocuments/frus1948v05p2/d728 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the IDF took the Upper Galilee from the Arab Liberation Army (Qawuqji) at the end of October 1948
    - pushed into southern Lebanon
    - flight or expulsion of many villagers north to Lebanon
    - neutrality: displaced Palestinian population not quantified

**[S1245]** jewishvirtuallibrary.org, 'Germany Virtual Jewish History Tour' — https://www.jewishvirtuallibrary.org/israel-germany-relations — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel and the Federal Republic of Germany established (full) diplomatic relations

**[S1246]** avalon.law.yale.edu, 'The Avalon Project : Israeli-Syrian General Armistice Agreement, July 20, 1949' — https://avalon.law.yale.edu/20th_century/arm04.asp — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date: signed 20 July 1949
    - signed at Hill 232 near Mahanayim (places: galilee)
    - areas Syria held west of the international border became demilitarized zones from which forces withdrew (places: golan_heights)
    - withdrawal of forces from the DMZ

**[S1247]** en.idi.org.il, '1965 - The Israel Democracy Institute' — https://en.idi.org.il/israeli-elections-and-parties/elections/1965/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date: 2 November 1965
    - Mapai-led Alignment won 45 seats
    - new Gahal bloc of Herut and the Liberals won 26
    - Ben-Gurion's breakaway Rafi won 10
    - turnout 83.0%
    - Eshkol remained Prime Minister

**[S1248]** avalon.law.yale.edu, 'Avalon Project - A Decade of American Foreign Policy 1941-1949 - Creation of a Conciliation Commission for Palestine - Resolution of the General Assembly, December 11, 1948' — https://avalon.law.yale.edu/20th_century/decad171.asp — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - refugees wishing to return to their homes and live at peace with their neighbours should be permitted to do so at the earliest practicable date, with compensation for those choosing not to return
    - created the UN Conciliation Commission for Palestine

**[S1249]** documents.un.org, 'https://documents.un.org/api/symbol/access?s=A/PV.207&l=en&t=pdf' — https://documents.un.org/api/symbol/access?s=A/PV.207&l=en&t=pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel became the 59th member
    - vote 37-12-9 and formal admission (roll-call)
    - Arab states voted against

**[S1250]** documents.un.org, 'https://documents.un.org/api/symbol/access?s=S/7593&l=en&t=pdf' — https://documents.un.org/api/symbol/access?s=S/7593&l=en&t=pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - places: hebron area, west_bank (Jordanian-held village of as-Samu)
    - demolishing dozens of houses
    - fighting Jordanian troops
    - Jordanian casualties reported as 16 killed and 54 wounded
    - neutrality: Palestinian civilian casualties of as-Samu omitted

**[S1251]** history.state.gov, 'Historical Documents - Office of the Historian' — https://history.state.gov/historicaldocuments/frus1964-68v18/d333 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - in response to Fatah attacks launched from the West Bank

**[S1252]** history.state.gov, 'Historical Documents - Office of the Historian' — https://history.state.gov/historicaldocuments/frus1964-68v18/d346 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - unrest in the West Bank against King Hussein followed

**[S1253]** documents.un.org, 'https://documents.un.org/api/symbol/access?s=A/1451&l=en&t=pdf' — https://documents.un.org/api/symbol/access?s=A/1451&l=en&t=pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the Gaza Strip was now crowded with refugees
    - UNRWA served refugees in Gaza, the West Bank, Jordan, Lebanon and Syria (places)

**[S1254]** documents.un.org, 'https://documents.un.org/api/symbol/access?s=S/RES/93(1951)&l=en&t=pdf' — https://documents.un.org/api/symbol/access?s=S/RES/93(1951)&l=en&t=pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - disputes over water/land projects in the DMZs fed clashes (e.g. 1951 Hula drainage dispute)

**[S1255]** ecf.org.il, 'ECF - Economic Cooperation Foundation: Abolition of the Military Governance of Arab-Populated Areas in Israel (1966)' — https://ecf.org.il/issues/issue/88 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - military government imposed in 1948 on Arab-populated areas
    - under British-era emergency regulations
    - choice (historical): Abolish military government from 1 December 1966 - Eshkol's decision, announced to the Knesset in November 1966
    - Eshkol notice to the Knesset on abolition of military governance of Arab-populated areas (1966)

**[S1256]** nobelprize.org, 'Shmuel Agnon – Banquet speech - NobelPrize.org' — https://www.nobelprize.org/prizes/literature/1966/agnon/speech/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date: 10 December 1966 (prize conferred in Stockholm)

**[S1257]** nobelprize.org, 'Nelly Sachs – Facts - NobelPrize.org' — https://www.nobelprize.org/prizes/literature/1966/sachs/facts/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Nelly Sachs was a German-Jewish poet

**[S1258]** nobelprize.org, 'https://web.archive.org/web/2024/https://www.nobelprize.org/prizes/literature/1966/ceremony-speech/' — no URL (print) — archived: https://web.archive.org/web/2024/https://www.nobelprize.org/prizes/literature/1966/ceremony-speech/ — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - places: jerusalem (Agnon's home)

**[S1259]** nobelprize.org, 'https://web.archive.org/web/2024/https://www.nobelprize.org/prizes/literature/1966/agnon/facts/' — no URL (print) — archived: https://web.archive.org/web/2024/https://www.nobelprize.org/prizes/literature/1966/agnon/facts/ — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Agnon wrote in Hebrew; resident of Israel at time of award

**[S1260]** colinshindler.com, 'Passover in Hebron 1968 - Colin Shindler' — https://www.colinshindler.com/articles/passover-in-hebron-1968/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date April 1968: a group led by Rabbi Moshe Levinger held a Passover seder at the Park Hotel in Hebron (places: hebron, west_bank)
    - the group refused to leave
    - the government later moved them to a military compound
    - in 1970-71 the government built Kiryat Arba on the city's edge (place: kiryat_arba)

**[S1261]** paralympic.org, 'Tel Aviv 1968' — https://www.paralympic.org/tel-aviv-1968 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1968-11-04 to 1968-11-13: Israel hosted the third Summer Paralympic Games
    - opening in Jerusalem (place: jerusalem)
    - events in Ramat Gan (places: ramat_gan, tel_aviv)
    - about 750 athletes from 28-29 nations took part
    - 774 athletes from 28 countries took part

**[S1262]** documents.un.org, 'https://documents.un.org/api/symbol/access?s=S/RES/262(1968)&l=en&t=pdf' — https://documents.un.org/api/symbol/access?s=S/RES/262(1968)&l=en&t=pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the Security Council condemned the raid in resolution 262

**[S1263]** jta.org, 'See French Embargo on War Materiel As Move to Weaken Israel, Win Arab Favor - Jewish Telegraphic Agency' — https://www.jta.org/archive/see-french-embargo-on-war-materiel-as-move-to-weaken-israel-win-arab-favor — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - France imposed an arms embargo on Israel

**[S1264]** policyarchive.org, 'https://policyarchive.org/download/9732' — https://policyarchive.org/download/9732 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - after years of restriction, emigration of Soviet Jews grew from 1969 (date 1969-01-01 to 1979-12-31)
    - about 163,000 Soviet Jews settled in Israel in the late 1960s and 1970s
    - most of them arrived in 1969-1973
    - from the mid-1970s a growing share chose the United States instead (47% in 1976)
    - in 1976, 49% of Soviet Jewish emigrants went elsewhere than Israel
    - by 1976 only about half of Soviet Jewish emigrants made aliyah

**[S1265]** jewishvirtuallibrary.org, 'The War of Attrition: Background & Overview' — https://jewishvirtuallibrary.org/background-and-overview-of-the-war-of-attrition — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1969-03-08: Nasser declared a war of attrition in March 1969 after clashes under way since 1967 (places: suez_canal, sinai, egypt)
    - Israel answered with commando raids and deep air strikes
    - Soviet air-defence personnel deployed in Egypt
    - date_end 1970-08-07: a US-brokered ceasefire took effect on 7-8 August 1970
    - Israeli military deaths about 694-1,424 depending on period counted
    - neutrality: omits Egyptian civilian displacement from the canal cities
    - date 1970-08-07: a US-brokered ceasefire took effect on the night of 7-8 August 1970, ending the War of Attrition (places: suez_canal, sinai)
    - the ceasefire was US-brokered
    - Israel: 1,424 soldiers and more than 100 civilians killed between 15 June 1967 and 8 August 1970
    - canal cities destroyed; about a million inhabitants evacuated

**[S1266]** un.org, 'Israel-Jordan peace treaty - Question of Palestine' — https://www.un.org/unispal/document/auto-insert-179122/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: signed 26 October 1994
    - Signed by prime ministers Yitzhak Rabin and Abdelsalam al-Majali
    - Witnessed by the United States and Russia
    - Ending the state of war
    - Fixing the international border
    - Setting water-sharing arrangements for the Jordan and Yarmuk rivers

**[S1267]** peacemaker.un.org, 'https://web.archive.org/web/20240827071615id_/https://peacemaker.un.org/sites/peacemaker.un.org/files/IL%20PS_950928_InterimAgreementWestBankGazaStrip%28OsloII%29.pdf' — no URL (print) — archived: https://web.archive.org/web/20240827071615id_/https://peacemaker.un.org/sites/peacemaker.un.org/files/IL%20PS_950928_InterimAgreementWestBankGazaStrip%28OsloII%29.pdf — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: 28 September 1995; signed in Washington (place washington)
    - Signed by Israel and the PLO
    - Provided for Palestinian elections

**[S1268]** embassies.gov.il, 'Suicide and Other Bombing Attacks in Israel Since the Declaration of Principles (Sept 1993)' — no URL (print) — archived: https://web.archive.org/web/20241113063603/https://embassies.gov.il/MFA/FOREIGNPOLICY/Terrorism/Palestinian/Pages/Suicide%20and%20Other%20Bombing%20Attacks%20in%20Israel%20Since.aspx — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 26 killed on Jerusalem bus 18 on 25 February (place jerusalem)
    - One killed at an Ashkelon junction on 25 February (place ashkelon)
    - 19 killed on another bus 18 on 3 March
    - 13-14 killed at Tel Aviv's Dizengoff Center on 4 March (place tel_aviv)
    - Suicide bomber in a queue of young people outside the Dolphinarium discotheque on the Tel Aviv seafront (place tel_aviv)
    - Date: 27 March 2002; Hamas suicide bomber at the Park Hotel in Netanya during a Passover seder (place netanya)
    - About 250 guests
    - Injuring 143
    - Date: 6 March 2008; gunman opened fire in the Mercaz HaRav yeshiva in Jerusalem (place jerusalem)
    - Killing eight students and wounding 11
    - A Palestinian gunman from Jabel Mukaber in East Jerusalem
    - Before he was shot dead
    - About 80 people, mostly teenagers, in the library; eight students killed

**[S1269]** hrw.org, 'ISRAEL/LEBANON' — https://www.hrw.org/reports/1997/isrleb/Isrleb-01.htm — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: launched 11 April 1996
    - Following Hezbollah rocket fire on northern Israel
    - Places south_lebanon and beirut (Israeli strikes reached Beirut)
    - Again seeking to displace civilians from the south

**[S1270]** hrw.org, 'ISRAEL/LEBANON' — https://www.hrw.org/reports/1997/isrleb/Isrleb.htm — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - A 16-day air and artillery campaign
    - Neutrality: total Lebanese casualties, displacement figure and Israeli casualties omitted
    - Place kiryat_shmona (hit by Hezbollah rockets)
    - Some 154 Lebanese civilians killed and 351 injured
    - 639 Katyushas fired into Israel

**[S1271]** un.org, 'Mideast situation/Lebanon - Report on Qana - SecGen report - Question of Palestine' — https://www.un.org/unispal/document/auto-insert-187312/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - On 18 April Israeli shells struck the UNIFIL Fijian battalion compound at Qana
    - About 800 civilians sheltered there
    - Killing more than 100 (commonly given as 106)
    - UN military adviser found it unlikely that the shelling resulted from technical or procedural error; IDF attributed it to operational mistakes

**[S1272]** jewishvirtuallibrary.org, 'Protocol Concerning the Redeployment in Hebron' — https://www.jewishvirtuallibrary.org/protocol-concerning-the-redeployment-in-hebron — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: 17 January 1997
    - Netanyahu and Arafat concluded the Protocol Concerning the Redeployment in Hebron
    - About 80% of the city (H-1) passed to Palestinian control
    - Hebron Protocol dated 17 January 1997
    - Hebron Protocol: IDF withdrawal from 80% of Hebron within ten days

**[S1273]** avalon.law.yale.edu, 'The Avalon Project : Protocol on redeployment in Hebron; January 15, 1997' — https://avalon.law.yale.edu/20th_century/hebron.asp — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - H-1 under Palestinian police; H-2 remained under Israeli control
    - H-2 includes the Jewish settler enclaves and the Cave of the Patriarchs

**[S1274]** RETIRED (no longer cited) — timesofisrael.com, 'https://www.timesofisrael.com/liveblog_entry/signed-deal-for-comprehensive-end-of-gaza-war-says-all-hostages-will-be-freed-72-hours-after-idf-withdrawal/' — https://www.timesofisrael.com/liveblog_entry/signed-deal-for-comprehensive-end-of-gaza-war-says-all-hostages-will-be-freed-72-hours-after-idf-withdrawal/

**[S1277]** state.gov, 'https://www.state.gov/wp-content/uploads/2021/01/Joint-Declaration-US-Morrocco-Israel.pdf' — https://www.state.gov/wp-content/uploads/2021/01/Joint-Declaration-US-Morrocco-Israel.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: Israel and Morocco signed an agreement on 22 Dec 2020 [parent second pass; supersedes earlier drop]
    - Linked to US recognition of Moroccan sovereignty over Western Sahara [parent second pass]

**[S1278]** timesofisrael.com, 'https://www.timesofisrael.com/netanyahu-secures-most-nominations-for-premiership-after-new-hope-abstains/' — https://www.timesofisrael.com/netanyahu-secures-most-nominations-for-premiership-after-new-hope-abstains/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Neither the pro- nor the anti-Netanyahu bloc won a majority [parent second pass; supersedes earlier drop]
    - Likud remained the largest party with 30 seats [parent second pass; supersedes earlier drop]

**[S1281]** timesofisrael.com, 'https://www.timesofisrael.com/sweden-wins-2023-eurovision-while-israels-noa-kirel-finishes-in-3rd-place/' — https://www.timesofisrael.com/sweden-wins-2023-eurovision-while-israels-noa-kirel-finishes-in-3rd-place/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel's fourth win [parent second pass; supersedes earlier drop]

**[S1282]** aljazeera.com, 'Arab League condemns US Jerusalem move | Conflict News | Al Jazeera' — http://www.aljazeera.com/news/2017/12/arab-league-condemns-move-dangerous-illegal-171209185754563.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Arab and European governments warned it would inflame tensions [parent second pass; partially rescues earlier drop]
    - Arab League condemned the US move
    - Egypt's foreign minister at the UN Security Council: 'region on the verge of explosion'

**[S1283]** timesofisrael.com, 'https://www.timesofisrael.com/us-closes-jerusalem-consulate-demoting-palestinian-mission/' — https://www.timesofisrael.com/us-closes-jerusalem-consulate-demoting-palestinian-mission/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Palestinian leadership cut contacts with the US administration [parent second pass; supersedes earlier drop]

**[S1285]** nbcnews.com, 'Israel calls it a humanitarian corridor, but for fleeing Palestinians, it’s forced displacement' — https://www.nbcnews.com/news/world/israel-calls-humanitarian-corridor-fleeing-palestinians-s-forced-displ-rcna125376 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Displacing most of the Strip's population

**[S1287]** RETIRED (no longer cited; superseded by S864) — timesofisrael.com, 'https://www.timesofisrael.com/authorities-name-44-soldiers-30-police-officers-killed-in-hamas-attack/' — https://www.timesofisrael.com/authorities-name-44-soldiers-30-police-officers-killed-in-hamas-attack/

**[S1288]** timesofisrael.com, 'https://www.timesofisrael.com/mobileye-founder-shashua-to-hand-over-reins-as-ceo-after-almost-three-decades/' — https://www.timesofisrael.com/mobileye-founder-shashua-to-hand-over-reins-as-ceo-after-almost-three-decades/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Mobileye is Jerusalem-based (place: jerusalem) [parent second pass; supersedes earlier drop]
    - 5.3 billion; largest acquisition of an Israeli tech company to that date [parent second pass, cross-check]

**[S1289]** RETIRED (no longer cited) — timesofisrael.com, 'https://www.timesofisrael.com/mortars-fired-from-lebanon-infiltrators-killed-as-6-israelis-hurt-in-gunfight/' — https://www.timesofisrael.com/mortars-fired-from-lebanon-infiltrators-killed-as-6-israelis-hurt-in-gunfight/

**[S1290]** RETIRED (no longer cited) — aljazeera.com, 'Mapping 10,000 cross-border attacks between Israel and Lebanon | Interactive News | Al Jazeera' — https://www.aljazeera.com/news/2024/9/25/mapping-10000-cross-border-attacks-between-israel-and-lebanon

**[S1291]** RETIRED (no longer cited) — ynetnews.com, 'Around one million Lebanese displaced by Israeli attacks, official says' — https://www.ynetnews.com/article/hy2hmkl0r

**[S1292]** hrw.org, 'Off the Map: Land and Housing Rights Violations in Israel’s Unrecognized Bedouin Villages | HRW' — https://www.hrw.org/report/2008/03/30/map/land-and-housing-rights-violations-israels-unrecognized-bedouin-villages — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Bedouin tribes moved into the siyag
    - Military rule 1949-1966
    - Rahat established in 1971 (HRW 2008, note 22)
    - established in 1971 (HRW 2008, note 22)
    - Tel Sheva established in 1969 (HRW 2008, note 22)
    - established in 1969 (HRW 2008, note 22)
    - Hura established in 1989 (HRW 2008, note 22)
    - established in 1989 (HRW 2008, note 22)
    - Seven government-planned Bedouin townships in the Negev, including Hura, Rahat and Tel Sheva (constructed post-1968)
    - Quarter 9 of the town of Hura: Israeli Ministry of Justice letter to HRW

**[S1293]** jewishvirtuallibrary.org, 'Yad Mordekhai' — https://www.jewishvirtuallibrary.org/yad-mordekhai — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Survivors slipped through the siege in May 1948
    - The site was retaken in October 1948
    - Founded 1943 by a group from Poland
    - Encyclopaedia Judaica: after six days' siege the survivors slipped through to Jewish positions (May 1948)
    - Encyclopaedia Judaica: retaken October 1948

**[S1294]** history.state.gov, 'Historical Documents - Office of the Historian' — https://history.state.gov/historicaldocuments/frus1949v06/d554 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel agreed to the Arab Legion taking over the Iraqi front (1949)
    - Israel agrees to Arab Legion taking over from Iraqis on the Iraqi front (FRUS 1949)
    - FRUS: March 1949 Israel-Transjordan agreement (Arab Legion takes over the Iraqi front) provides compensation for the road lost between Tulkarm and Qalqiliya

**[S1295]** ochaopt.org, 'https://www.ochaopt.org/sites/default/files/Northern_West_Bank_Humanitarian_Response_Update_April_2025.pdf' — https://www.ochaopt.org/sites/default/files/Northern_West_Bank_Humanitarian_Response_Update_April_2025.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Iron Wall launched 21 January 2025
    - Jenin, Tulkarm and Nur Shams camps at the centre
    - Largest displacement crisis since 1967

**[S1296]** ochaopt.org, 'Gaza Strip | The humanitarian impact of 15 years of the blockade - June 2022 | United Nations Office for the Coordination of Humanitarian Affairs - Occupied Palestinian Territory' — https://www.ochaopt.org/content/gaza-strip-humanitarian-impact-15-years-blockade-june-2022 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - OCHA: 78% of piped water in Gaza unfit for human consumption (2022)
    - June 2007 Israel intensified restrictions after Hamas takeover; land, sea and air blockade
    - 2.1 million Palestinians 'locked in'
    - 62% require food assistance; Q1 2022 unemployment 46.6%
    - restrictions imposed citing security
    - June 2007 Israel intensified restrictions after Hamas takeover
    - Land, sea and air blockade
    - Restrictions imposed citing security
    - 2.1 million locked in
    - 62% require food assistance
    - Unemployment 46.6% in Q1 2022
    - Concern about collective punishment
    - Israel intensified restrictions into a blockade after the June 2007 takeover

**[S1297]** knesset.gov.il, 'Governments of Israel' — no URL (print) — archived: https://web.archive.org/web/20160522174916/https://www.knesset.gov.il/govt/eng/GovtByNumber_eng.asp?govt=14 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1969-03-17: Golda Meir formed the Fourteenth Government on 17 March 1969, continuing the national unity coalition (place: jerusalem)

**[S1298]** knesset.gov.il, 'Governments of Israel' — no URL (print) — archived: https://web.archive.org/web/20160522174751/https://www.knesset.gov.il/govt/eng/GovtByNumber_eng.asp?govt=16 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Meir's government ended and Dayan left the Defence Ministry on 3 June 1974

**[S1299]** knesset.gov.il, 'Governments of Israel' — no URL (print) — archived: https://web.archive.org/web/20160522174753/https://www.knesset.gov.il/govt/eng/GovtByNumber_eng.asp?govt=17 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1974-06-03: Yitzhak Rabin formed the Seventeenth Government on 3 June 1974 (place: jerusalem)

**[S1300]** knesset.gov.il, 'Governments of Israel' — no URL (print) — archived: https://web.archive.org/web/20160522174756/https://www.knesset.gov.il/govt/eng/GovtByNumber_eng.asp?govt=18 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Menachem Begin formed a government on 20 June 1977

**[S1301]** knesset.gov.il, 'Governments of Israel' — no URL (print) — archived: https://web.archive.org/web/20160522174758/https://www.knesset.gov.il/govt/eng/GovtByNumber_eng.asp?govt=19 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the coalition was sworn in on 5 August 1981

**[S1302]** jewishvirtuallibrary.org, 'Menachem Begin' — https://www.jewishvirtuallibrary.org/menachem-begin — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Begin had withdrawn after his wife's death in November 1982 and amid the Lebanon war, and resigned in 1983

**[S1303]** knesset.gov.il, 'https://web.archive.org/web/20160522174801/https://www.knesset.gov.il/govt/eng/GovtByNumber_eng.asp?govt=20' — no URL (print) — archived: https://web.archive.org/web/20160522174801/https://www.knesset.gov.il/govt/eng/GovtByNumber_eng.asp?govt=20 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1983-10-10: Yitzhak Shamir formed the Twentieth Government on 10 October 1983

**[S1304]** knesset.gov.il, 'https://web.archive.org/web/20160522174803/https://www.knesset.gov.il/govt/eng/GovtByNumber_eng.asp?govt=21' — no URL (print) — archived: https://web.archive.org/web/20160522174803/https://www.knesset.gov.il/govt/eng/GovtByNumber_eng.asp?govt=21 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the national unity government was formed on 13 September 1984

**[S1305]** knesset.gov.il, 'https://web.archive.org/web/20160522174805/https://www.knesset.gov.il/govt/eng/GovtByNumber_eng.asp?govt=22' — no URL (print) — archived: https://web.archive.org/web/20160522174805/https://www.knesset.gov.il/govt/eng/GovtByNumber_eng.asp?govt=22 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1986-10-20: under the 1984 agreement Peres and Shamir exchanged posts; Shamir's Twenty-Second Government took office on 20 October 1986

**[S1306]** history.state.gov, 'Milestones in the History of U.S. Foreign Relations - Office of the Historian' — https://history.state.gov/milestones/1969-1976/arab-israeli-war-1973 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel crossed the canal; a US airlift resupplied Israel from mid-October
    - fighting continued and resolution 339 followed on 23 October (places: suez_canal, golan_heights)

**[S1307]** runi.ac.il, 'https://runi.ac.il/media/iv0hkrl1/fom-groupthink-to-polythink-in-the-yom-kippur-decisions-of-1973.pdf' — https://runi.ac.il/media/iv0hkrl1/fom-groupthink-to-polythink-in-the-yom-kippur-decisions-of-1973.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - choice (non-historical): pre-emptive air strike on Syria proposed by Chief of Staff Elazar on the morning of 6 October
    - choice (non-historical): Dayan's narrower position — call up the air force and two armoured divisions

**[S1308]** jewishvirtuallibrary.org, 'Black September' — https://www.jewishvirtuallibrary.org/black-september — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - after the PFLP's Dawson's Field hijackings (6-12 September 1970)
    - date 1970-09-16: the Jordanian army moved against Palestinian guerrilla organisations (places: jordan, amman)
    - a Syrian armoured incursion was turned back
    - Israel readied forces as Jordan asked Western governments for help
    - neutrality: Palestinian civilians and displacement to Syria and Lebanon
    - thousands of Palestinians sought refuge in Syria and Lebanon

**[S1309]** israeled.org, 'https://israeled.org/jordans-army-moves-to-drive-out-plo/' — https://israeled.org/jordans-army-moves-to-drive-out-plo/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - estimates of Palestinian dead range from about 2,000 to 3,400 (Arafat claimed far more)
    - the Jordanian army lost 537 killed
    - date_end 1971-07-23: fighting ended in July 1971 and the PLO relocated to Lebanon (place: lebanon)
    - 2,000-4,000 Palestinian militants plus an unknown number of civilians killed; Arafat claimed 25,000
    - Iraqi force of 20,000 occupied eastern Jordan

**[S1310]** eurovision.tv, 'Birmingham 1998 - Eurovision Song Contest' — no URL (print) — archived: https://web.archive.org/web/20210102233542/https://eurovision.tv/event/birmingham-1998 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: 9 May 1998

**[S1311]** eurovision.tv, 'Final of Birmingham 1998 - Eurovision Song Contest' — no URL (print) — archived: https://web.archive.org/web/20201020121127/https://eurovision.tv/event/birmingham-1998/final — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Scoring 172 points

**[S1312]** RETIRED (no longer cited) — timesofisrael.com, 'https://www.timesofisrael.com/liveblog-april-16-2026/' — https://www.timesofisrael.com/liveblog-april-16-2026/

**[S1315]** RETIRED (no longer cited) — france24.com, 'https://www.france24.com/en/middle-east/20240101-israel-s-top-court-strikes-down-key-legal-reform-in-blow-to-netanyahu' — https://www.france24.com/en/middle-east/20240101-israel-s-top-court-strikes-down-key-legal-reform-in-blow-to-netanyahu

**[S1316]** documents.un.org, 'https://documents.un.org/api/symbol/access?s=A/HRC/29/52&l=en&t=pdf' — https://documents.un.org/api/symbol/access?s=A/HRC/29/52&l=en&t=pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Ground operation against cross-border tunnels [parent second pass; supersedes earlier drop]
    - Choice (historical): expand into a ground operation against cross-border tunnels [parent second pass; supersedes earlier drop]
    - 2,251 Palestinians killed incl. 1,462 civilians (551 children); 67 soldiers and 6 civilians in Israel killed [parent cross-check]
    - Date: start 8 July vs 7 July [parent cross-check]
    - COI: operation commenced 7 July 2014; ground operation launched 17 July

**[S1317]** documents.un.org, 'https://documents.un.org/api/symbol/access?s=A/67/PV.44&l=en&t=pdf' — https://documents.un.org/api/symbol/access?s=A/67/PV.44&l=en&t=pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - The United States, Canada and the Czech Republic were among those voting against [parent second pass; supersedes earlier drop]

**[S1321]** un.org, 'About the Nakba - Question of Palestine' — https://www.un.org/unispal/about-the-nakba/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - UN: permanent displacement of more than half of the Palestinian population

**[S1322]** jewishvirtuallibrary.org, 'Myths & Facts - The Refugees' — https://www.jewishvirtuallibrary.org/myths-and-facts-the-refugees — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - UN Mediator's estimate: 472,000 refugees

**[S1323]** documents.un.org, 'https://documents.un.org/doc/undoc/gen/nl5/107/33/pdf/nl510733.pdf' — https://documents.un.org/doc/undoc/gen/nl5/107/33/pdf/nl510733.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - UNCCP statistical expert: about 711,000 refugees from Israel-controlled territory (A/1367/Rev.1, para. 15)

**[S1324]** hrw.org, 'https://www.hrw.org/reports/2007/iopt0707/iopt0707web.pdf' — https://www.hrw.org/reports/2007/iopt0707/iopt0707web.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - From 2001, early in the second intifada, militants in Gaza began firing home-made Qassam rockets at Sderot
    - Neutrality: other victims of the rockets omitted
    - Places sderot, gaza_strip
    - HRW: Qassams developed late 2001, first attack on Israel 5 March 2002

**[S1325]** RETIRED (no longer cited) — timesofisrael.com, 'https://www.timesofisrael.com/liveblog_entry/idf-99-of-the-300-or-so-projectiles-fired-by-iran-at-israel-overnight-were-intercepted/' — https://www.timesofisrael.com/liveblog_entry/idf-99-of-the-300-or-so-projectiles-fired-by-iran-at-israel-overnight-were-intercepted/

**[S1326]** RETIRED (no longer cited) — jpost.com, 'IDF Chief of Staff Halevi thanks UK Defense Chief Radakin for efforts | The Jerusalem Post' — https://www.jpost.com/breaking-news/article-797376

**[S1327]** RETIRED (no longer cited) — timesofisrael.com, 'https://www.timesofisrael.com/liveblog_entry/satellite-photo-seen-by-toi-shows-damage-to-radar-system-near-irans-isfahan-airport-after-alleged-idf-strike/' — https://www.timesofisrael.com/liveblog_entry/satellite-photo-seen-by-toi-shows-damage-to-radar-system-near-irans-isfahan-airport-after-alleged-idf-strike/

**[S1328]** RETIRED (no longer cited; superseded by S875) — timesofisrael.com, 'https://www.timesofisrael.com/young-girl-seriously-hurt-in-iran-attack-remains-in-life-threatening-condition/' — https://www.timesofisrael.com/young-girl-seriously-hurt-in-iran-attack-remains-in-life-threatening-condition/

**[S1329]** posenlibrary.com, 'The Israeli Black Panthers | Posen Library' — https://www.posenlibrary.com/node/10609 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - young Mizrahi Jews, mostly of Moroccan origin, from Jerusalem's Musrara neighbourhood formed the Black Panthers in early 1971 to protest poverty and discrimination (place: jerusalem)

**[S1330]** unpacked.media, 'https://unpacked.media/the-surprising-history-of-israels-black-panthers/' — https://unpacked.media/the-surprising-history-of-israels-black-panthers/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - a public committee acknowledged ethnic and socio-economic gaps and welfare spending rose
    - the violent protest led Meir to call them 'not nice'
    - three days after the first demonstration the cabinet released extra funds for social programmes

**[S1331]** thealabamabaptist.org, 'May 30 marks 40 years since deadly attack in Israel | The Alabama Baptist' — https://thealabamabaptist.org/may-30-marks-40-years-since-deadly-attack-in-israel/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 26 killed: 17 Puerto Rican Christian pilgrims, 8 Israelis and a Canadian

**[S1332]** britannica.com, 'Munich massacre | Facts, Victims, Terrorism, Olympics, & History | Britannica' — no URL (print) — archived: https://web.archive.org/web/20241229224832/https://www.britannica.com/event/Munich-Massacre — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1972-09-05: eight Black September militants seized members of the Israeli Olympic team in Munich (places: munich, abroad)
    - two were killed in the village and nine more during the failed West German rescue at Fürstenfeldbruck - 11 in all
    - a West German police officer was killed; five attackers were killed

**[S1333]** jta.org, 'Israel Incensed at Release of 3 Arab Terrorists by the West German Gov't. - Jewish Telegraphic Agency' — https://www.jta.org/archive/israel-incensed-at-release-of-3-arab-terrorists-by-the-west-german-govt — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the three survivors were freed in October after the hijacking of a Lufthansa airliner

**[S1334]** documents.un.org, 'https://documents.un.org/api/symbol/access?s=S/10790&l=en&t=pdf' — https://documents.un.org/api/symbol/access?s=S/10790&l=en&t=pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel responded with air strikes on bases in Syria and Lebanon (choice note: 8 September 1972)
    - choice (non-historical): limit response to conventional strikes on guerrilla bases in Syria and Lebanon (strikes carried out 8 September 1972)

**[S1335]** britannica.com, 'Black September | Organization, Attacks, & Facts | Britannica' — no URL (print) — archived: https://web.archive.org/web/20241228225942/https://www.britannica.com/topic/Black-September-political-organization-Palestine — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel responded with a covert campaign against those it held responsible

**[S1336]** jewishvirtuallibrary.org, 'Rehavam Ze’evi' — https://www.jewishvirtuallibrary.org/rehavam-ze-evi — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: 17 October 2001

**[S1337]** un.org:80, 'REPORT OF SECRETARY-GENERAL ON RECENT EVENTSIN JENIN, OTHER PALESTINIAN CITIES' — no URL (print) — archived: https://web.archive.org/web/20140916014017/http://www.un.org:80/News/Press/docs/2002/SG2077.doc.htm — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: launched 29 March 2002, two days after the Netanya bombing
    - Re-entering cities Ramallah, Nablus, Bethlehem, Tulkarm, Qalqilya and Jenin (places)
    - A major West Bank operation
    - Up to half civilians according to the UN; and 23 Israeli soldiers
    - Palestinian officials' claims of a massacre of hundreds were not borne out by HRW or the UN
    - The IDF declared the operation over on 21 April
    - Neutrality: overall casualties and displacement of the operation omitted (only Jenin given)
    - Israeli MFA: IDF lost 30 soldiers in Operation Defensive Shield
    - Nablus: 70-80 Palestinians killed, about 50 civilians
    - More than 17,000 homeless or needing shelter rehabilitation
    - Curfews affected an estimated 1 million people
    - Dates of entry into each city

**[S1338]** hrw.org, 'Israel/Occupied Territories: Jenin War Crimes Investigation Needed | Human Rights Watch' — https://www.hrw.org/news/2002/05/02/israel/occupied-territories-jenin-war-crimes-investigation-needed — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Jenin camp: 52-53 Palestinians killed
    - At least 22 of them civilians according to HRW
    - HRW documented unlawful killings and use of human shields

**[S1339]** nobelprize.org, 'The Prize in Economic Sciences 2002 - Press release - NobelPrize.org' — https://www.nobelprize.org/prizes/economic-sciences/2002/press-release/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: announced 9 October 2002
    - Israeli-American psychologist

**[S1340]** nobelprize.org, 'The Sveriges Riksbank Prize in Economic Sciences in Memory of Alfred Nobel 2002 - NobelPrize.org' — https://www.nobelprize.org/prizes/economic-sciences/2002/summary/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Kahneman shared the 2002 economics prize with Vernon Smith
    - For integrating psychological research on judgement and decision-making into economics

**[S1341]** nobelprize.org, 'Daniel Kahneman – Facts - NobelPrize.org' — https://www.nobelprize.org/prizes/economic-sciences/2002/kahneman/facts/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Place jerusalem

**[S1342]** RETIRED (no longer cited; superseded by S836) — nasa.gov, 'STS-107 - NASA' — https://www.nasa.gov/mission/sts-107/

**[S1343]** 2001-2009.state.gov, 'Technical Difficulties' — https://2001-2009.state.gov/r/pa/prs/ps/2003/20062.htm — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: 30 April 2003 (place washington, State Dept release)
    - The Quartet (US, EU, UN, Russia) presented a performance-based plan
    - Three-phase plan toward a permanent two-state settlement by 2005
    - Requiring an end to Palestinian violence
    - And a freeze on settlement activity

**[S1344]** whc.unesco.org, 'https://whc.unesco.org/en/sessions/27com/' — https://whc.unesco.org/en/sessions/27com/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: 1 July 2003 (27th Committee session)

**[S1345]** RETIRED (no longer cited; superseded by S876) — timesofisrael.com, 'https://www.timesofisrael.com/11-killed-mostly-children-dozens-more-hurt-as-rocket-hits-soccer-field-in-majdal-shams' — https://www.timesofisrael.com/11-killed-mostly-children-dozens-more-hurt-as-rocket-hits-soccer-field-in-majdal-shams

**[S1346]** RETIRED (no longer cited) — aljazeera.com, 'Second wave of blasts hits Lebanon as Israel declares ‘new phase’ of war | Hezbollah News | Al Jazeera' — https://www.aljazeera.com/news/2024/9/18/multiple-explosions-heard-in-lebanon-a-day-after-hezbollah-pager-blasts

**[S1347]** bbc.com, 'Coronavirus: Israel to bring in 14-day quarantine for all arrivals' — https://www.bbc.com/news/world-middle-east-51809818 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - From 11 March the government sealed the borders [parent second pass; supersedes earlier drop]

**[S1348]** haaretz.com, 'When Israel Shot Down a Libyan Passenger Plane, but Refused to Take Responsibility - Israel News - Haaretz.com' — no URL (print) — archived: https://web.archive.org/web/20241225031916/https://www.haaretz.com/israel-news/2023-03-18/ty-article-magazine/.highlight/when-israel-shot-down-a-libyan-passenger-plane-but-refused-to-take-responsibility/00000186-f186-dd8e-a7d7-f7ef464e0000 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1973-02-21: a Libyan Boeing 727 that strayed over Israeli-held Sinai in a sandstorm was shot down (place: sinai)
    - 108 of the 113 people aboard were killed
    - declassified cabinet minutes show ministers decided to deny responsibility and refuse an official inquiry

**[S1349]** jta.org, 'Israel Downs Libyan Passenger Plane; 70 Killed, 13 Survive; Bad Weather May Have Caused Plane to Str - Jewish Telegraphic Agency' — https://www.jta.org/archive/israel-downs-libyan-passenger-plane-70-killed-13-survive-bad-weather-may-have-caused-plane-to-str — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - shot down by Israeli F-4 fighters after failing to respond to interception signals
    - shot down by Israeli fighter jets after ignoring interception signals (Israeli army account)

**[S1350]** jta.org, 'Israel to Pay Families of Those Who Died in Libyan Plane Crash; Word 'compensation' is Not Mentioned - Jewish Telegraphic Agency' — https://www.jta.org/archive/israel-to-pay-families-of-those-who-died-in-libyan-plane-crash-word-compensation-is-not-mentioned — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - refused an official inquiry (contemporary record)
    - Israel later paid compensation to victims' families

**[S1351]** documents.un.org, 'https://documents.un.org/api/symbol/access?s=S/10911&l=en&t=pdf' — https://documents.un.org/api/symbol/access?s=S/10911&l=en&t=pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - killed three senior PLO figures: Muhammad Yusuf al-Najjar, Kamal Adwan and Kamal Nasser
    - Lebanon's complaint to the UN reported Lebanese policemen and civilians among the dead
    - neutrality: summary gives no figures for non-Israeli dead

**[S1352]** jewishvirtuallibrary.org, 'The Agranat Commission' — https://www.jewishvirtuallibrary.org/the-agranat-commission — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1973-11-21: a state commission chaired by Supreme Court President Shimon Agranat was set up on 21 November 1973 (place: jerusalem)
    - recommended removing the head of Military Intelligence and other officers
    - found Chief of Staff David Elazar responsible, but declined to rule on the ministers
    - Prime Minister Meir's government resigned about ten days later

**[S1353]** history.state.gov, 'Milestones in the History of U.S. Foreign Relations - Office of the Historian' — https://history.state.gov/milestones/1969-1976/shuttle-diplomacy — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1974-01-18: under US mediation Israel and Egypt agreed in January 1974 to separate their forces
    - Israel withdrew from the west bank of the Suez Canal to lines in western Sinai, with a UN buffer zone between the armies (places: suez_canal, sinai)
    - after months of artillery exchanges on the Golan, Israel and Syria signed a separation of forces agreement on 31 May 1974
    - date 1975-09-04: Sinai Interim Agreement signed 4 September 1975
    - provided for a further Israeli withdrawal in Sinai and a new UN buffer zone (place: sinai)

**[S1354]** avalon.law.yale.edu, 'The Avalon Project : Separation of Forces Agreement Between Israel and Syria; May 31, 1974' — https://avalon.law.yale.edu/20th_century/pal04.asp — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel withdrew from the salient captured in 1973 and from a strip including Quneitra, which returned to Syrian civil administration (places: golan_heights, quneitra, syria)

**[S1355]** avalon.law.yale.edu, 'The Avalon Project : United Nations Security Council Resolution 350' — https://avalon.law.yale.edu/20th_century/un350.asp — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the Security Council established UNDOF the same day

**[S1356]** RETIRED (no longer cited; superseded by S833) — everycrsreport.com, 'Israel's Disengagement from Gaza - EveryCRSReport.com' — https://www.everycrsreport.com/reports/RS22000.html

**[S1357]** nobelprize.org, 'The Prize in Economic Sciences 2005 - Press release - NobelPrize.org' — https://www.nobelprize.org/prizes/economic-sciences/2005/press-release/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: announced 10 October 2005
    - Hebrew University game theorist Robert J. Aumann (place jerusalem)
    - Including the first full formal analysis of infinitely repeated games

**[S1358]** hrw.org, 'Why They Died: Civilian Casualties in Lebanon during the 2006 War with Israel | HRW' — https://www.hrw.org/report/2007/09/05/why-they-died/civilian-casualties-lebanon-during-2006-war — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel launched air, naval and later ground operations in Lebanon (places south_lebanon, beirut)
    - Lebanese deaths about 1,109 (HRW, mostly civilians)
    - About one million Lebanese displaced
    - 43-44 Israeli civilians killed

**[S1359]** hrw.org, 'Civilians under Assault: Hezbollah’s Rocket Attacks on Israel in the 2006 War | HRW' — https://www.hrw.org/report/2007/08/28/civilians-under-assault/hezbollahs-rocket-attacks-israel-2006-war — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Hezbollah fired thousands of rockets at northern Israel
    - Places haifa, kiryat_shmona, nahariya, safed (hit by rockets)
    - Neutrality: Israeli displacement/injuries and Hezbollah fighter deaths omitted

**[S1360]** knesset.gov.il, 'Governments of Israel' — no URL (print) — archived: https://web.archive.org/web/20160107112310/http://knesset.gov.il/govt/eng/GovtByNumber_eng.asp?govt=31 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Defence Minister Amir Peretz had already left office

**[S1361]** iaea.org, 'https://www.iaea.org/sites/default/files/documents/gov2011-30.pdf' — https://www.iaea.org/sites/default/files/documents/gov2011-30.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - A 2009 IAEA investigation found uranium traces and features resembling an undeclared reactor

**[S1362]** documents.un.org, 'https://documents.un.org/api/symbol/access?s=A/RES/3379(XXX)&l=en&t=pdf' — https://documents.un.org/api/symbol/access?s=A/RES/3379(XXX)&l=en&t=pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1975-11-10: the General Assembly adopted resolution 3379 determining that 'zionism is a form of racism and racial discrimination' (place: abroad)

**[S1363]** worldjewishcongress.org, 'This week in Jewish history | UNGA rescinds ‘Zionism is racism’ resolution - World Jewish Congress' — https://www.worldjewishcongress.org/en/news/this-week-in-jewish-history--unga-rescinds-zionism-is-racism-resolution-12-3-2020 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - adopted by 72 votes to 35 with 32 abstentions
    - Israel and its allies rejected it
    - the Assembly revoked it in December 1991 (resolution 46/86)

**[S1364]** jta.org, 'Tekoah: Israel Holds Lebanon Responsible for Terrorist Massacre - Jewish Telegraphic Agency' — https://www.jta.org/archive/tekoah-israel-holds-lebanon-responsible-for-terrorist-massacre — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1974-04-11: militants who crossed from Lebanon attacked Kiryat Shmona (place: kiryat_shmona)

**[S1365]** jta.org, 'Elaborate Security Measures Introduced to Protect Border Towns from Terrorist Outrages - Jewish Telegraphic Agency' — https://jta.org/1974/04/17/archive/elaborate-security-measures-introduced-to-protect-border-towns-from-terrorist-outrages — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - claimed by the PFLP-General Command

**[S1366]** jewishvirtuallibrary.org, 'Ma’alot Massacre' — https://jewishvirtuallibrary.org/ma-alot-massacre — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1974-05-15: three DFLP militants from Lebanon took hostages in a school in Ma'alot (places: maalot_tarshiha, safed)
    - killed residents of Ma'alot before the siege
    - took more than 100 people, mostly teenage students on a school trip from Safed, hostage
    - during the storming of the building 22 students and several adults were killed; total Israeli deaths usually given as 25-31
    - neutrality: omits Israel's retaliatory strikes in Lebanon

**[S1367]** jewishvirtuallibrary.org, 'Ma'ale Adumim | Jewish Virtual Library' — https://www.jewishvirtuallibrary.org/jsource/Society_&_Culture/geo/maale.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1975 (year precision): Ma'ale Adumim settlement begun on a ridge east of Jerusalem (places: maale_adumim, west_bank, jerusalem)
    - became a local council in 1979 and a city in 1991

**[S1368]** israelhayom.co.il, 'https://www.israelhayom.co.il/article/54472' — https://www.israelhayom.co.il/article/54472 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - planned as the urban centre of Israeli settlement in the Rafah salient of north-eastern Sinai (places: yamit, sinai)
    - settlement in the Rafah salient was encouraged by the government after 1971

**[S1369]** jewishvirtuallibrary.org, 'Ariel, Israel' — https://www.jewishvirtuallibrary.org/ariel — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Ariel was established in 1978 in the central West Bank (places: ariel, west_bank)

**[S1370]** britannica.com, 'Anwar Sadat | Biography, History, & Assassination | Britannica' — no URL (print) — archived: https://web.archive.org/web/20241231201442/https://www.britannica.com/biography/Anwar-Sadat — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1977-11-19 to 1977-11-21: Sadat arrived in Israel on 19 November 1977 and addressed the Knesset on 20 November (place: jerusalem)
    - date 1979-03-26: Begin and Sadat signed the peace treaty in Washington, witnessed by President Carter (places: washington, sinai, cairo)
    - date 1981-10-06: Sadat was killed by members of Egyptian Islamic Jihad during a military parade (places: cairo, egypt)

**[S1371]** worldjewishcongress.org, 'This week in Jewish history | Egyptian President Anwar Sadat calls for peace in landmark address to Knesset - World Jewish Congress' — https://www.worldjewishcongress.org/en/news/this-week-in-jewish-history--egyptian-president-anwar-sadat-calls-for-peace-in-landmark-address-to-knesset — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the first visit by an Arab head of state
    - Prime Minister Begin replied in the same session
    - Egypt was suspended from the Arab League from 1979 to 1989
    - his successor Hosni Mubarak maintained the peace treaty

**[S1372]** israeled.org, 'https://israeled.org/sadat-addresses-the-knesset/' — https://israeled.org/sadat-addresses-the-knesset/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - calling for peace based on Israeli withdrawal and Palestinian rights

**[S1373]** history.state.gov, 'Milestones in the History of U.S. Foreign Relations - Office of the Historian' — https://history.state.gov/milestones/1977-1980/camp-david — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the visit opened direct Egyptian-Israeli negotiations

**[S1374]** jewishvirtuallibrary.org, 'Camp David Negotiations: Exchange of Letters Regarding Framework for Middle East Peace' — https://jewishvirtuallibrary.org/exchange-of-letters-regarding-framework-for-middle-east-peace — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Begin agreed to let the Knesset decide on evacuating the Sinai settlements (historical choice note)

**[S1375]** ibiblio.org, 'Negotiations -- Gathering Gloom' — https://www.ibiblio.org/sullivan/Negotiations-3.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - choice (non-historical): insist on keeping the Rafah-salient settlements such as Yamit — Begin's opening position

**[S1376]** palquest.org, 'interactive encyclopedia of the palestine question – palquest | overall chronology' — https://www.palquest.org/en/overallchronology?nid=14509 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1976-03-30: Arab citizens of Israel held a general strike and demonstrations (places: sakhnin, arraba, galilee)
    - against a government plan, published on 11 March, to expropriate about 20,000 dunams in the Galilee between Sakhnin and Arraba
    - choice (historical): proceed with expropriation and deploy police and army against the strike
    - choice (non-historical): suspend the expropriation — demand of the Arab committee that called the strike
    - government decision of 29 February 1976 to confiscate 20,000 dunams in Galilee
    - protests centred on Sakhnin, Arraba and Deir Hanna (places: sakhnin, arraba, galilee)

**[S1377]** aljazeera.com, 'Land Day: What happened in Palestine on March 30, 1976? | Israel-Palestine conflict News | Al Jazeera' — https://www.aljazeera.com/news/2026/3/30/land-day-what-happened-in-palestine-on-march-30-1976 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - six Arab citizens were killed by security forces and about 100 were wounded
    - commemorated annually by Palestinians in Israel and the occupied territories

**[S1378]** britannica.com, 'Entebbe raid | Summary & Facts | Britannica' — no URL (print) — archived: https://web.archive.org/web/20241224163621/https://www.britannica.com/event/Entebbe-raid — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1976-06-27: Air France Flight 139 from Tel Aviv was hijacked by Palestinian and German militants and flown to Entebbe, Uganda (places: entebbe, abroad)
    - Israeli and Jewish passengers were held
    - on the night of 3-4 July Israeli commandos rescued 102 of 106 hostages; three hostages were killed in the raid
    - choice (historical): cabinet approved the raid on 3 July 1976
    - about 103 hostages rescued on 3-4 July; three hostages killed
    - Britannica: rescue of 103 hostages

**[S1379]** jta.org, 'Idi Amin and Israel: First Love, then Hate - Jewish Telegraphic Agency' — https://jta.org/2003/08/20/archive/idi-amin-and-israel-first-love-then-hate — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - a fourth hostage, Dora Bloch, was later murdered in Uganda

**[S1380]** israeled.org, 'https://israeled.org/entebbe/' — https://israeled.org/entebbe/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the unit commander Yonatan Netanyahu and all seven hijackers were killed
    - about 45 Ugandan soldiers were killed
    - choice (non-historical): negotiate a prisoner release — cabinet reportedly prepared to negotiate
    - 20 Ugandan soldiers killed (CIE)

**[S1381]** eurovision.tv, 'Paris 1978' — no URL (print) — archived: https://web.archive.org/web/20231230202033/https://eurovision.tv/event/paris-1978 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1978-04-22: 'A-Ba-Ni-Bi' by Izhar Cohen and the Alphabeta won the Eurovision Song Contest in Paris, Israel's first win
    - place tel_aviv (event placed in Tel Aviv although the contest was in Paris)
    - contest held in Paris (place: abroad)
    - Jordan's broadcaster stopped the live broadcast

**[S1382]** eurovision.tv, 'Jerusalem 1979' — no URL (print) — archived: https://web.archive.org/web/20231202140727/https://eurovision.tv/event/jerusalem-1979 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1979-03-31: hosting the contest in Jerusalem, Israel won again with 'Hallelujah' by Milk and Honey (place: jerusalem)

**[S1383]** peaceagreements.org, 'Annapolis Conference Joint Understanding on Negotiations | PA-X' — https://www.peaceagreements.org/agreements/1072/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date: 27 November 2007
    - US-hosted conference in Annapolis, Maryland; Olmert and Abbas issued a joint understanding (place washington)
    - To launch negotiations on all core issues
    - Aiming at a peace treaty before the end of 2008

**[S1384]** RETIRED (no longer cited) — btselem.org, 'Operation Cast Lead, 27 Dec. '08 to 18 Jan. '09 | B'Tselem' — no URL

**[S1385]** RETIRED (no longer cited) — www2.ohchr.org, 'United Nations Fact Finding Mission on the Gaza conflict' — no URL

**[S1386]** theguardian.com, 'Israel launches airstrikes on Gaza Strip after Hamas rocket attacks | Israel | The Guardian' — https://www.theguardian.com/world/2021/may/10/hamas-fires-rockets-into-israel-in-dispute-over-jerusalem-mosque — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Gaza health ministry: 20 killed incl. nine children on 10 May
    - More than 500 Palestinians and 21 police injured
    - Israeli infant injured
    - Israel struck Gaza after the rockets
    - Palestinians threw stones
    - Hamas ultimatum and rocket fire

**[S1387]** RETIRED (no longer cited) — ochaopt.org, 'United Nations Office for the Coordination of Humanitarian Affairs - Occupied Palestinian Territory' — https://www.ochaopt.org/

**[S1388]** RETIRED (no longer cited) — npr.org, 'Israeli airstrike kill Houthi rebel prime minister in Yemen : NPR' — https://www.npr.org/2025/08/30/nx-s1-5522932/houthi-prime-minister-dead-yemen-israel-airstrike

**[S1389]** RETIRED (no longer cited) — theguardian.com, 'Israel strikes Yemen port after Houthi rebels attack Tel Aviv | Yemen | The Guardian' — https://www.theguardian.com/world/article/2024/jul/20/airstrikes-hit-yemens-hodeidah-port-after-israel-vows-revenge-for-houthi-attack

**[S1390]** RETIRED (no longer cited) — abcnews.com, 'Israel PM says Houthis threaten the 'whole world' after strike near Tel Aviv airport - ABC News' — https://abcnews.com/International/houthi-missile-strikes-tel-avivs-ben-gurion-airport/story?id=121443287

**[S1391]** RETIRED (no longer cited) — aljazeera.com, 'Israel’s Netanyahu vows response to Iran after Houthi attack on airport | Israel-Palestine conflict News | Al Jazeera' — https://www.aljazeera.com/news/2025/5/4/missile-launched-from-yemen-hits-israels-ben-gurion-airport-in-tel-aviv

**[S1392]** mfa.gov.il, '133 Statement to the press by Prime Minister Begin on the massacre of Israelis on the Haifa-Tel Aviv Road- 12 March 1978' — no URL (print) — archived: https://web.archive.org/web/20151122093403/http://www.mfa.gov.il/mfa/foreignpolicy/mfadocuments/yearbook3/pages/133%20statement%20to%20the%20press%20by%20prime%20minister%20begin.aspx — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1978-03-11: Fatah gunmen who landed by boat hijacked a bus on the coastal highway (places: tel_aviv, hadera)
    - 38 Israeli civilians, including 13 children, were killed and more than 70 wounded
    - Begin: 37 Israelis killed and 76 wounded

**[S1393]** unifil.unmissions.org, 'Background | UNIFIL' — https://unifil.unmissions.org/en/background — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1978-03-14 to 1978-03-21: three days after the Coastal Road attack Israel invaded southern Lebanon against PLO bases (places: south_lebanon, lebanon)
    - up to the Litani River
    - neutrality: Lebanon's position
    - forces fought Syria and besieged West Beirut (place: beirut)
    - the IDF withdrew in stages from most of Lebanon in 1985, keeping a 'security zone' held with the South Lebanon Army (places: south_lebanon, lebanon)

**[S1394]** documents.un.org, 'https://documents.un.org/api/symbol/access?s=S/RES/425(1978)&l=en&t=pdf' — https://documents.un.org/api/symbol/access?s=S/RES/425(1978)&l=en&t=pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - on 19 March the Security Council (resolution 425) called on Israel to withdraw and created UNIFIL

**[S1395]** jta.org, 'Cooperation Between Israel and Iran Officially Ended; Last 33 Israelis Return Home from Teheran - Jewish Telegraphic Agency' — https://www.jta.org/archive/cooperation-between-israel-and-iran-officially-ended-last-33-israelis-return-home-from-teheran — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date February 1979: after the Islamic Revolution Iran cut its ties with Israel and handed the Israeli mission in Tehran to the PLO (places: tehran, iran)

**[S1396]** jta.org, 'Israel's Supply of Arms to Iran Assessed by Two Former Chiefs of Israel's Military Intelligence - Jewish Telegraphic Agency' — https://www.jta.org/archive/israels-supply-of-arms-to-iran-assessed-by-two-former-chiefs-of-israels-military-intelligence — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israeli-Iranian contacts continued covertly, including arms sales during the Iran-Iraq war

**[S1397]** jta.org, 'Israelis Egyptians Exchange Credentials in Colorful Ceremony - Jewish Telegraphic Agency' — https://www.jta.org/archive/israelis-egyptians-exchange-credentials-in-colorful-ceremony — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date February 1980: Israel and Egypt exchanged ambassadors (places: cairo, tel_aviv)

**[S1398]** jta.org, 'Shekel Replaces Pound As Legal Tender in Israel; New Measures Aimed at Tax Dodgers Announced - Jewish Telegraphic Agency' — https://www.jta.org/archive/shekel-replaces-pound-as-legal-tender-in-israel-new-measures-aimed-at-tax-dodgers-announced — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1980-02-24: the shekel replaced the Israeli pound at ten pounds to one shekel (place: jerusalem)

**[S1399]** jta.org, 'Inflation Was Iii. 4 Percent in 1979 - Jewish Telegraphic Agency' — https://www.jta.org/archive/inflation-was-iii-4-percent-in-1979 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - amid triple-digit inflation

**[S1400]** jta.org, 'Economic Crisis Grips Israel; Program of Severe Austerity Announced - Jewish Telegraphic Agency' — https://www.jta.org/archive/economic-crisis-grips-israel-program-of-severe-austerity-announced — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - banks had propped up their own share prices; when shares collapsed the Tel Aviv Stock Exchange closed from 6 October 1983 (place: tel_aviv)

**[S1401]** jta.org, 'Dispute in Cabinet over Its Earlier Decision to Shore Up Sagging Commercial Bank Shares - Jewish Telegraphic Agency' — https://www.jta.org/archive/dispute-in-cabinet-over-its-earlier-decision-to-shore-up-sagging-commercial-bank-shares — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the government undertook to buy bank shares from the public, effectively nationalising the main banks (historical choice 'the arrangement')
    - choice (non-historical): let bank share prices fall without a state guarantee — opposed at the time by the Finance Minister

**[S1402]** jta.org, 'Israel's Financial Institutions Reeling Following Scathing Criticism - Jewish Telegraphic Agency' — https://www.jta.org/archive/israels-financial-institutions-reeling-following-scathing-criticism — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the Bejski Commission reported on the affair in April 1986

**[S1403]** jta.org, 'Cabinet Adopts Economic Program, Histadrut Calls 24-hour Strike - Jewish Telegraphic Agency' — https://www.jta.org/archive/cabinet-adopts-economic-program-histadrut-calls-24-hour-strike — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1985-07-01: the unity government adopted an emergency stabilisation plan (places: jerusalem, tel_aviv)
    - a sharp devaluation, deep budget cuts, temporary price controls

**[S1404]** jta.org, 'Agreement on Emergency Economic Program Averts a General Strike - Jewish Telegraphic Agency' — https://www.jta.org/archive/agreement-on-emergency-economic-program-averts-a-general-strike — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - a wage agreement with the Histadrut

**[S1405]** jta.org, 'Inflation Rate in Israel is Lowest Since 1976 - Jewish Telegraphic Agency' — https://www.jta.org/archive/inflation-rate-in-israel-is-lowest-since-1976 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - with inflation at about 445% in 1984
    - inflation of 380.75% in the twelve months to June 1985

**[S1406]** jta.org, 'Behind the Headlines Israel's Economic Outlook for 1987 - Jewish Telegraphic Agency' — https://www.jta.org/archive/behind-the-headlines-israels-economic-outlook-for-1987 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - inflation fell to around 20% within about two years

**[S1407]** jta.org, 'Aridor Resigns As Finance Minister Hours After Floating a Plan to Link the Shekel Exclusively to the - Jewish Telegraphic Agency' — https://www.jta.org/archive/aridor-resigns-as-finance-minister-hours-after-floating-a-plan-to-link-the-shekel-exclusively-to-the — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - choice (non-historical): dollarisation proposed by Finance Minister Aridor in 1983 and rejected

**[S1408]** jta.org, 'Next Phase of Israel Economic Package Deal is Under Debate - Jewish Telegraphic Agency' — https://www.jta.org/archive/next-phase-of-israel-economic-package-deal-is-under-debate — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - choice (non-historical): continue short-term wage-price 'package deals' (1984-85 package deals)

**[S1409]** jta.org, 'New Shekel Note to Appear Soon - Jewish Telegraphic Agency' — https://www.jta.org/archive/new-shekel-note-to-appear-soon — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - new shekel introduced at 1,000 old shekels to one new shekel

**[S1410]** jta.org, 'Thousands of Nablus Residents Welcome Mayor Shaka Home - Jewish Telegraphic Agency' — https://www.jta.org/archive/thousands-of-nablus-residents-welcome-mayor-shaka-home — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1980-06-02: car bombs maimed the mayors of Nablus, Bassam Shakaa, who lost both legs, and Ramallah, Karim Khalaf (places: nablus, ramallah, west_bank)

**[S1411]** jta.org, 'Court Names 2 Army Officers Held in Bombing of Arab Mayors' Cars; Officers Must Remain in Custody - Jewish Telegraphic Agency' — https://www.jta.org/archive/court-names-2-army-officers-held-in-bombing-of-arab-mayors-cars-officers-must-remain-in-custody — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - bombs planted by members of a Jewish settler underground; perpetrators identified only in 1984
    - neutrality: omits the injured police sapper and the context of the Hebron killing of six yeshiva students
    - the group was responsible for the 1980 car bombings of West Bank mayors

**[S1412]** jta.org, 'Attempted Mass Sabotage of Arab Owned Buses Shocks Israelis - Jewish Telegraphic Agency' — https://www.jta.org/archive/attempted-mass-sabotage-of-arab-owned-buses-shocks-israelis — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date late April 1984: the security services arrested members of a settler underground after they planted bombs on Arab buses in East Jerusalem (places: jerusalem)

**[S1413]** jta.org, '25 Suspected Jewish Terrorists Charged - Jewish Telegraphic Agency' — https://www.jta.org/archive/25-suspected-jewish-terrorists-charged — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - and the July 1983 attack on the Islamic College in Hebron that killed three students (places: hebron, kiryat_arba)
    - and had planned to blow up the Dome of the Rock

**[S1414]** jta.org, 'Masked Gunmen Kill Three Arab Students and Injure 30 in Hebron - Jewish Telegraphic Agency' — https://www.jta.org/archive/masked-gunmen-kill-three-arab-students-and-injure-30-in-hebron — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - neutrality: casualties of the Islamic College attack

**[S1415]** documents.un.org, 'https://documents.un.org/api/symbol/access?s=S/RES/478(1980)&l=en&t=pdf' — https://documents.un.org/api/symbol/access?s=S/RES/478(1980)&l=en&t=pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Security Council resolution 478 (20 August 1980) censured the law, declared it null and void and called on states with embassies in Jerusalem to withdraw them
    - UN Security Council Res. 478 (1980) censured the Basic Law as null and void

**[S1416]** jta.org, 'Jewish Settlers on Golan Are Euphoric over Israel's Move - Jewish Telegraphic Agency' — https://www.jta.org/archive/jewish-settlers-on-golan-are-euphoric-over-israels-move — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1981-12-14: the Knesset voted 63-21 to apply Israeli law, jurisdiction and administration to the Golan Heights (places: golan_heights, katzrin)
    - choice (historical): apply Israeli law, passed 63-21
    - choice (non-historical): keep military administration pending negotiations — preferred by the bill's opponents

**[S1417]** documents.un.org, 'https://documents.un.org/api/symbol/access?s=S/RES/497(1981)&l=en&t=pdf' — https://documents.un.org/api/symbol/access?s=S/RES/497(1981)&l=en&t=pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the Security Council unanimously declared the decision 'null and void and without international legal effect' (resolution 497)

**[S1418]** jta.org, 'Israel Denounces the U.S. for Suspending Its Cooperation Accord - Jewish Telegraphic Agency' — https://www.jta.org/archive/israel-denounces-the-u-s-for-suspending-its-cooperation-accord — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the United States suspended a newly signed strategic-cooperation memorandum

**[S1419]** jta.org, 'Golan Druze in 6th Week of Strike - Jewish Telegraphic Agency' — https://www.jta.org/archive/golan-druze-in-6th-week-of-strike — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - a longer strike followed in 1982

**[S1420]** jta.org, 'Congress, White House Reviewing Israeli Strike at Iraqi Reactor - Jewish Telegraphic Agency' — https://www.jta.org/archive/congress-white-house-reviewing-israeli-strike-at-iraqi-reactor — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1981-06-07: Israeli F-16s escorted by F-15s destroyed the Osirak (Tammuz) research reactor near Baghdad (places: iraq, abroad)
    - the United States briefly suspended F-16 deliveries

**[S1421]** jta.org, 'Israel Planning Protest to U.S. over 'hasty' Charge over Raid on Iraq A-plant - Jewish Telegraphic Agency' — https://www.jta.org/archive/israel-planning-protest-to-u-s-over-hasty-charge-over-raid-on-iraq-a-plant — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the reactor was nearly completed
    - ten Iraqi soldiers and a French technician were killed
    - the reactor was under construction by French technicians; Israel said it would be operational between July and September
    - French sources: one French technician killed; Israel said no technicians were on site

**[S1422]** documents.un.org, 'https://documents.un.org/api/symbol/access?s=S/RES/487(1981)&l=en&t=pdf' — https://documents.un.org/api/symbol/access?s=S/RES/487(1981)&l=en&t=pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the Security Council unanimously condemned the attack in resolution 487

**[S1423]** jta.org, 'Israel Raid Becomes Tangled in Election Campaign Politics - Jewish Telegraphic Agency' — https://www.jta.org/archive/israel-raid-becomes-tangled-in-election-campaign-politics — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - choice (non-historical): rely on covert sabotage and diplomacy with France — favoured by Saguy; Dayan, Weizman and Yadin opposed a strike
    - Gur argued the reactor was not as close to completion as Begin suggested

**[S1424]** jta.org, 'Highlights of the Year 5742 - Jewish Telegraphic Agency' — https://www.jta.org/archive/highlights-of-the-year-5742 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the withdrawal from Sinai was completed on 25 April 1982
    - date 1982-06-06: Israel invaded Lebanon with a declared aim of pushing the PLO 40 km north (places: south_lebanon, lebanon)
    - more than 14,000 PLO fighters were evacuated in August-September
    - choice (historical): the war expanded beyond the declared 40 km aim
    - choice (non-historical): limit the operation to a 40 km zone — the aim the cabinet approved
    - the autonomy negotiations were still deadlocked in 1982

**[S1425]** jta.org, 'Three Sentenced in Shooting of Israel's Envoy to Britain - Jewish Telegraphic Agency' — https://www.jta.org/archive/three-sentenced-in-shooting-of-israels-envoy-to-britain — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - after the attempted assassination of Ambassador Shlomo Argov in London by the Abu Nidal group

**[S1426]** jta.org, 'Israeli Casualties in Lebanon - Jewish Telegraphic Agency' — https://www.jta.org/archive/israeli-casualties-in-lebanon — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel lost 368 soldiers by October 1982 and 654 by June 1985
    - Israel Radio count: 478 Israelis killed in Lebanon by May 1983

**[S1427]** jta.org, 'Backgrounder Israel's Current Fighting in Lebanon Only Latest Problems with Its Neighbor - Jewish Telegraphic Agency' — https://www.jta.org/archive/backgrounder-israels-current-fighting-in-lebanon-only-latest-problems-with-its-neighbor — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Bashir Gemayel, elected president of Lebanon with Israeli backing, was assassinated (places: beirut, lebanon)
    - choice (non-historical): withdraw completely to the international border — carried out only in 2000

**[S1428]** jta.org, 'Highlights of the Year 5743 - Jewish Telegraphic Agency' — https://www.jta.org/archive/highlights-of-the-year-5743 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the IDF entered West Beirut the next day
    - earlier counts of detainees varied

**[S1429]** jta.org, 'Unanimous Cabinet Decision: a Judicial Commission Will Conduct Full, Formal Inquiry into Massacre of - Jewish Telegraphic Agency' — https://www.jta.org/archive/unanimous-cabinet-decision-a-judicial-commission-will-conduct-full-formal-inquiry-into-massacre-of — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the killings caused a political crisis in Israel
    - the government appointed the Kahan Commission days later

**[S1430]** jta.org, 'Israeli Jets Destroy Bases Used for Attacks on Tyre Hq and on U.S. Marines in Beirut - Jewish Telegraphic Agency' — https://www.jta.org/archive/israeli-jets-destroy-bases-used-for-attacks-on-tyre-hq-and-on-u-s-marines-in-beirut — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - a suicide truck bomb at the Shin Bet building in Tyre on 4 November 1983 killed 28 Israelis and 32 Lebanese prisoners
    - a truck bomb at the Israeli headquarters in Tyre on 4 November 1983 killed 29 Israeli service personnel and 31 Lebanese

**[S1431]** jta.org, 'News Brief - Jewish Telegraphic Agency' — https://www.jta.org/archive/lebanon-formerly-abrogates-its-may-17-1983-withdrawal — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1983-05-17: US-mediated agreement ending the state of war and providing for Israeli withdrawal (places: beirut, lebanon)

**[S1432]** jta.org, 'Bitter Reactions in Israel over Lebanon's Formal Abrogation of the May 17 Agreement - Jewish Telegraphic Agency' — https://www.jta.org/archive/bitter-reactions-in-israel-over-lebanons-formal-abrogation-of-the-may-17-agreement — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - under Syrian pressure Lebanon abrogated it in March 1984

**[S1433]** jta.org, 'Two Mks Demand Probe into the Killing of Four Terrorists Who Hijacked a Telaviv-ashkelon Bus - Jewish Telegraphic Agency' — https://www.jta.org/archive/two-mks-demand-probe-into-the-killing-of-four-terrorists-who-hijacked-a-telaviv-ashkelon-bus — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1984-04-12: four Palestinians hijacked a bus (Tel Aviv-Ashkelon) on 12 April 1984 (places: tel_aviv, gaza_strip)
    - in the rescue the next morning two were killed and two captured alive
    - a press photograph exposed the cover-up
    - neutrality: omits the Israeli soldier killed and passengers wounded

**[S1434]** jta.org, 'High Court Upholds Presidential Pardons of Shin Bet Officials - Jewish Telegraphic Agency' — https://www.jta.org/archive/high-court-upholds-presidential-pardons-of-shin-bet-officials — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the two captured were killed on the orders of Shin Bet chief Avraham Shalom
    - Shalom and other officers received presidential pardons in 1986

**[S1435]** jta.org, 'Israel Marks 10th Year of Airlift As Debate over Jewish Identity Goes on - Jewish Telegraphic Agency' — https://www.jta.org/archive/israel-marks-10th-year-of-airlift-as-debate-over-jewish-identity-goes-on — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1984-11-21 to 1985-01-05: about 8,000 Ethiopian Jews who had trekked to camps in Sudan were airlifted to Israel (places: abroad)
    - about 500 more were brought out in the US-led Operation Joshua in 1985
    - about 7,600 airlifted over 45 days
    - the United States brought about 600 Jews out of the Sudanese camps (Weizman)

**[S1436]** jta.org, 'Airlift of Ethiopian Jews Has Been Halted, Apparently Because of Its Premature Disclosure - Jewish Telegraphic Agency' — https://www.jta.org/archive/airlift-of-ethiopian-jews-has-been-halted-apparently-because-of-its-premature-disclosure — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the airlift stopped after it became public

**[S1437]** cbp.gov, 'Israel Free Trade Agreement (ILFTA) | U.S. Customs and Border Protection' — no URL (print) — archived: https://web.archive.org/web/20230101065434/https://www.cbp.gov/trade/free-trade-agreements/Israel — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1985-04-22: signed on 22 April 1985
    - took effect on 1 September 1985

**[S1438]** jta.org, '1,100 Palestinian and Other Prisoners Exchanged for 3 Israelis - Jewish Telegraphic Agency' — https://www.jta.org/archive/1100-palestinian-and-other-prisoners-exchanged-for-3-israelis — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1985-05-21: the unity government released prisoners in exchange for three soldiers held by Ahmed Jibril's PFLP-General Command (place: abroad)
    - 1,150 prisoners released
    - including Lod attacker Kozo Okamoto
    - the deal drew heavy public criticism
    - about 1,100 released on the day (JTA 1985)

**[S1439]** jta.org, 'Navon, Rabin Argue over Whether Terrorist Exchange Sparked Hijacking - Jewish Telegraphic Agency' — https://www.jta.org/archive/navon-rabin-argue-over-whether-terrorist-exchange-sparked-hijacking — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - choice note: approved by all ministers except Yitzhak Navon; critics' position to refuse a deal

**[S1440]** jta.org, 'Israel Air Force Jets Blast PLO Headquarters in Tunisia - Jewish Telegraphic Agency' — https://www.jta.org/archive/israel-air-force-jets-blast-plo-headquarters-in-tunisia — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - days after three Israelis were killed on a yacht in Larnaca, Cyprus
    - date 1985-10-01: Israeli aircraft bombed PLO headquarters at Hammam Chott near Tunis (places: tunis, abroad)
    - reported deaths range from 47 to about 71, including PLO members and Tunisian civilians
    - first reports: at least 15 (Tunis) and 30-50 (IDF chief of staff Levy)

**[S1441]** documents.un.org, 'https://documents.un.org/api/symbol/access?s=S/RES/573(1985)&l=en&t=pdf' — https://documents.un.org/api/symbol/access?s=S/RES/573(1985)&l=en&t=pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the Security Council condemned the raid in resolution 573, with the United States abstaining

**[S1442]** jta.org, 'Israel to Investigate Allegations That a U.S. Navy Employe Gave Israel Secret Defense Documents - Jewish Telegraphic Agency' — https://www.jta.org/archive/israel-to-investigate-allegations-that-a-u-s-navy-employe-gave-israel-secret-defense-documents — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date 1985-11-21: US Navy intelligence analyst Jonathan Pollard was arrested outside the Israeli embassy in Washington for passing classified material to Israel (place: washington)

**[S1443]** jta.org, 'Behind the Headlines U.S. Jewish Leaders View the Implications of the Pollard Case - Jewish Telegraphic Agency' — https://www.jta.org/archive/behind-the-headlines-u-s-jewish-leaders-view-the-implications-of-the-pollard-case — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel apologised and initially described the operation as unauthorised
    - Pollard was sentenced to life imprisonment in 1987

**[S1444]** jta.org, 'Vanunu Sentenced to 18 Years for Treason, Espionage - Jewish Telegraphic Agency' — https://www.jta.org/archive/vanunu-sentenced-to-18-years-for-treason-espionage — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - former Dimona technician Mordechai Vanunu gave The Sunday Times details and photographs of the nuclear centre (places: dimona, abroad)
    - he had been lured to Rome and abducted by Mossad on 30 September
    - date 1986-09-30: reported missing from London; he said he was lured to Rome and kidnapped by Israeli agents

**[S1445]** jta.org, 'Court Convicts Vanunu of Treason, Espionage and Assisting Enemy - Jewish Telegraphic Agency' — https://www.jta.org/archive/court-convicts-vanunu-of-treason-espionage-and-assisting-enemy — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - convicted in a closed trial in 1988 and sentenced to 18 years

**[S1446]** jta.org, 'U.S. Pledges to Help Israel Find Alternative to Discontinued Lavi - Jewish Telegraphic Agency' — https://www.jta.org/archive/u-s-pledges-to-help-israel-find-alternative-to-discontinued-lavi — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the cabinet cancelled the programme on 30 August 1987 by 12 votes to 11

**[S1447]** jta.org, 'Timeline of Israel's Presence in Lebanon - Jewish Telegraphic Agency' — https://www.jta.org/archive/timeline-of-israels-presence-in-lebanon — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel invaded southern Lebanon up to the Litani River against PLO bases
    - security zone established in 1985 after withdrawing most troops

**[S1448]** jewishvirtuallibrary.org, 'Immigrants to Israel: 1948-1952' — https://www.jewishvirtuallibrary.org/immigrants-to-israel-1948-1952 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel State Archives table: 377,251 immigrants from Muslim countries, May 1948-end 1952

**[S1453]** jta.org, 'Israel Starts Testing Its Huge Water Project; Water Flowing to Negev - Jewish Telegraphic Agency' — https://www.jta.org/archive/israel-starts-testing-its-huge-water-project-water-flowing-to-negev — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Government announced water flowing from Lake Tiberias to the Negev for several days in the first test (JTA, 7 May 1964)
    - Full operations to start in the summer if no major repairs were needed

**[S1454]** jta.org, 'Establishment of Israel-german Diplomatic Relations Announced - Jewish Telegraphic Agency' — https://www.jta.org/archive/establishment-of-israel-german-diplomatic-relations-announced — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Establishment of relations announced simultaneously in Jerusalem and Bonn (JTA bulletin, 14 May 1965)
    - The Erhard-Eshkol letters were formally exchanged the day before the announcement

**[S1455]** jta.org, 'Israeli Forces Reported Near Litani - Jewish Telegraphic Agency' — https://www.jta.org/archive/israeli-forces-reported-near-litani — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 18 Israeli soldiers killed since the start of the operation (IDF spokesman, JTA 20 Mar 1978)
    - Two Israeli civilians killed by shelling/rockets in the Galilee
    - Gur estimated about 300 guerrillas killed, excluding air, artillery and naval attacks

**[S1456]** jta.org, 'Eshkol Tells Cabinet Thrust Wrecked Fatah Plans for Massive Terror Raids - Jewish Telegraphic Agency' — https://www.jta.org/archive/eshkol-tells-cabinet-thrust-wrecked-fatah-plans-for-massive-terror-raids — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israeli military estimate of about 100 Jordanian army dead (JTA, 25 Mar 1968)
    - Over 80 of the prisoners taken at Karameh identified as Fatah members
    - Early Israeli report: 23 soldiers killed (funerals, 25 Mar 1968)
    - King Hussein: about 60 civilians dead in the Jordan Valley
    - King Hussein claimed Israeli casualties exceeded 200

**[S1457]** documents.un.org, 'United Nations Security Council, Resolution 69 (1949), 4 March 1949 (Admission of Israel), Resolutions and Decisions of the Security Council 1949, documents.un.org' — https://documents.un.org/api/symbol/access?s=S/RES/69(1949)&l=en&t=pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Security Council Resolution 69 (4 March 1949) recommended that the General Assembly admit Israel
    - Resolution 69 adopted by 9 votes to 1 (Egypt), 1 abstention (United Kingdom)

**[S1458]** britannica.com, 'Encyclopaedia Britannica, 'Arab League'' — https://www.britannica.com/topic/Arab-League — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Arab League members voted to suspend Egypt's membership after the treaty (1979)
    - Egypt reinstated in the Arab League in 1989 (suspension 1979-1989)

**[S1459]** adst.org, 'Association for Diplomatic Studies and Training (ADST), 'Lod Airport massacre' entry' — https://adst.org/?p=3625 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 26 killed in later counts: 17 US citizens from Puerto Rico, one Canadian, eight Israelis (ADST)

**[S1460]** puertoricoreport.com, 'Puerto Rico Report, 'Memorial commemorates Puerto Rican lives lost to Palestinian violence in 1972'' — https://puertoricoreport.com/memorial-commemorates-puerto-rican-lives-lost-to-palestinian-violence-in-1972/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 78 wounded, 26 killed per Puerto Rican memorial text

**[S1461]** cambridge.org, 'Cambridge University Press, 'Undeclared Wars with Israel', chapter 'Palestinian terrorism in 1972: Lod Airport, the Munich Olympics and responses'' — https://www.cambridge.org/core/books/abs/undeclared-wars-with-israel/palestinian-terrorism-in-1972-lod-airport-the-munich-olympics-and-responses/123B7F2003F446D1E3C3E50A5BBE125C — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Cambridge chapter: 25 killed and 78 wounded (differs from 24 and 26 elsewhere)

**[S1462]** rebellionresearch.com, 'Rebellion Research, 'Syrian incursion into Jordan, September 20-23, 1970'' — https://www.rebellionresearch.com/syrian-incursion-into-jordan-september-20-23-1970 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Syrian losses: Jordanian claims 70-75 tanks destroyed; later account 135 tanks and 1,500 casualties
    - Israeli assessment: Syria lost 120 tanks
    - Jordan's own losses: 16 tanks, 112 casualties
    - Iraqi force remained uncommitted

**[S1463]** RETIRED (no longer cited) — qatar-tribune.com, 'dpa via Qatar Tribune, 'Houthis hold funeral for cabinet officials killed in Israeli strike', 2 Sep 2025' — https://www.qatar-tribune.com/article/192192/world/houthis-hold-funeral-for-cabinet-officials-killed-in-israeli-strike

**[S1464]** RETIRED (no longer cited) — ynetnews.com, 'Lior Ben Ari, Ynet News, 'Yemen: Crowds gather for funeral of Houthi prime minister and other ministers killed by Israel', Sep 2025' — https://www.ynetnews.com/article/99xn1ehpr

**[S1465]** RETIRED (no longer cited) — timeslive.co.za, 'Reuters via TimesLIVE, 'Death toll rises to 46 in Israeli raids on Yemen', 12 Sep 2025' — https://www.timeslive.co.za/news/world/2025-09-12-death-toll-rises-to-46-in-israeli-raids-on-yemen/

**[S1466]** israeled.org, 'Center for Israel Education, 'Cabinet Halts Lavi Production', 30 Aug 1987 (Today in Israeli History)' — https://israeled.org/cabinet-halts-lavi-production/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Cabinet voted 12-11 on 30 August 1987 to end Lavi production (live page)
    - Cabinet voted 12-11 to end Lavi production
    - Peres's Labor Party led the push to cancel the Lavi as unfeasible, with Finance Minister Nissim's support
    - Arens, minister without portfolio, fought in cabinet to save the Lavi

**[S1467]** timesofisrael.com, 'Haviv Rettig Gur, The Times of Israel, 'Moshe Arens, former defense minister and envoy to Washington, dead at 93', 7 Jan 2019' — https://www.timesofisrael.com/moshe-arens-former-defense-minister-and-envoy-to-washington-dead-at-93/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Arens pushed for Lavi development
    - Arens's case for the Lavi (2013 op-ed as reported): IAI's potential

**[S1468]** RETIRED (no longer cited) — nbcnews.com, 'Yemen's Houthi rebels signal that they've stopped attacks on Israel and Red Sea shipping' — https://www.nbcnews.com/world/middle-east/yemens-houthi-rebels-signal-stopped-attacks-israel-red-sea-shipping-rcna243165

**[S1469]** RETIRED (no longer cited) — jewishvirtuallibrary.org, 'Jewish Virtual Library, 'Geography of Israel: Zichron Ya'acov'' — https://jewishvirtuallibrary.org/zichron-ya-rsquo-acov

**[S1470]** RETIRED (no longer cited) — jewishvirtuallibrary.org, 'Jewish Virtual Library, 'Rosh Pina'' — https://jewishvirtuallibrary.org/rosh-pina

**[S1471]** RETIRED (no longer cited) — jewishvirtuallibrary.org, 'Encyclopaedia Judaica via Jewish Virtual Library, 'Metullah'' — https://jewishvirtuallibrary.org/metullah

**[S1472]** jewishvirtuallibrary.org, 'Encyclopaedia Judaica via Jewish Virtual Library, 'Kfar Giladi'' — https://jewishvirtuallibrary.org/kefar-giladi — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Founded 1916 by Hashomer
    - Kfar Giladi an existing kibbutz continuing after 1948 (joined Ihud ha-Kevutzot ve-ha-Kibbutzim 1952)

**[S1473]** jewishvirtuallibrary.org, 'Encyclopaedia Judaica via Jewish Virtual Library, 'Revivim'' — https://jewishvirtuallibrary.org/revivim — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Founded 1943 as southernmost Negev observation outpost
    - Revivim cut off by the Egyptian army, held out until Operation Yo'av (Dec 1948)

**[S1474]** jewishvirtuallibrary.org, 'Encyclopaedia Judaica via Jewish Virtual Library, 'Be'eri'' — https://jewishvirtuallibrary.org/be-eri — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Be'eri founded 6 October 1946 among 11 Negev settlements
    - Be'eri an existing kibbutz (founded 1946) in the NW Negev

**[S1475]** jewishvirtuallibrary.org, 'Encyclopaedia Judaica via Jewish Virtual Library, 'Degania'' — https://jewishvirtuallibrary.org/deganyah — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Degania Alef founded 1909 on JNF land
    - Syrian attack on Degania repulsed 20 May 1948

**[S1476]** jewishvirtuallibrary.org, 'Jewish Virtual Library, 'Israel Society & Culture: Hashomer Hatzair' (source: The Kibbutz Artzi Federation)' — https://jewishvirtuallibrary.org/hashomer-hatzair — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Kibbutz Yad Mordechai among those blocking the Egyptian advance (Kibbutz Artzi account)
    - Kibbutz Negba among Kibbutz Artzi kibbutzim on the Egyptian front, 1948
    - Kibbutz Artzi account: Kibbutz Negba blocked the Egyptian army's path

**[S1477]** jewishvirtuallibrary.org, 'Jewish Virtual Library, 'Jewish Defense Organizations: The Evolution of Armed Jewish Defense in Palestine' (quotes Ben-Gurion's Order of the Establishment of the IDF, 31 May 1948)' — https://jewishvirtuallibrary.org/the-evolution-of-armed-jewish-defense-in-palestine — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Ben-Gurion's Order of the Establishment of the IDF, 31 May 1948, names Zikhron Ya'akov among the Jewish settlements founded under Haganah protection
    - Ben-Gurion's Order of the Establishment of the IDF, 31 May 1948, names Rosh Pina among the Jewish settlements founded under Haganah protection
    - Ben-Gurion's Order of the Establishment of the IDF, 31 May 1948, names Metulla among the Jewish settlements founded under Haganah protection

**[S1478]** jewishvirtuallibrary.org, 'Jewish Virtual Library, 'The War of Independence: Operation Yiftach' (April 1948)' — https://jewishvirtuallibrary.org/operation-ldquo-yiftach-rdquo-april-1948 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Haganah occupied the Rosh Pinah police fortress on 28 April 1948, before statehood

**[S1479]** jewishvirtuallibrary.org, 'Jewish Virtual Library, 'Israel Studies Anthology: Jewish Settlement in the Land of Israel/Palestine'' — https://jewishvirtuallibrary.org/israel-studies-an-anthology-jewish-settlement-in-israel — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Nahalal, prototype moshav, established 1921
    - Nahalal an existing moshav (est. 1921) in the Jezreel Valley

**[S1480]** jewishvirtuallibrary.org, 'Jewish Virtual Library, 'Geography of Israel: The Jezreel Valley'' — https://jewishvirtuallibrary.org/jsource/Society_&_Culture/geo/Jezreel.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Kibbutz Ein Harod established September 1921
    - Ein Harod an existing kibbutz (est. 1921) in the Jezreel Valley

**[S1481]** jewishvirtuallibrary.org, 'Jewish Virtual Library, 'Haifa: History & Overview' (Encyclopaedia Judaica-derived)' — https://jewishvirtuallibrary.org/history-and-overview-of-haifa — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Kiryat Bialik among the residential Kerayot of the Haifa Bay built from 1930
    - Kiryat Bialik among the Haifa Bay Kerayot; Haifa area under Haganah/Jewish control from April 1948
    - Kiryat Yam among the residential Kerayot of the Haifa Bay built from 1930
    - Kiryat Yam among the Haifa Bay Kerayot
    - Haifa mentioned in sources of the Persian period
    - Haifa a city of about 150,000 at the end of the Mandate
    - Encyclopaedia Judaica (JVL): Haganah took Haifa 21-22 April 1948; this account attributes the Arab departure to Arab High Command orders
    - Late 1948 population 97,544, 96% Jewish

**[S1482]** jta.org, 'Jewish Telegraphic Agency, 'State of Emergency Decreed in Israel; Jewish Planes Attack Arab Troop Concentrations', daily bulletin, 21 May 1948' — https://www.jta.org/archive/state-of-emergency-decreed-in-israel-jewish-planes-attack-arab-troop-concentrations — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - JTA 21 May 1948: Yad Mordechai under Egyptian artillery shelling for 48 hours

**[S1483]** jta.org, 'Jewish Telegraphic Agency, 'Haganah Breaks Through Encircled Old City of Jerusalem; Captures Sarafand', daily bulletin, 20 May 1948' — https://www.jta.org/archive/haganah-breaks-through-encircled-old-city-of-jerusalem-captures-sarafand — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - JTA 20 May 1948: Negba raided by planes

**[S1484]** jta.org, 'Jewish Telegraphic Agency, 'Report Israelis in Nazareth; Jewish Villages Shelled in South; Egyptians Lose 500 Men', daily bulletin, July 1948' — https://www.jta.org/archive/report-israelis-in-nazareth-jewish-villages-shelled-in-south-egyptians-lose-500-men — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - JTA July 1948: after six days of fighting the Arabs were dispersed from in front of Negba

**[S1485]** jta.org, 'Jewish Telegraphic Agency, 'Arabs Surrender Control of Haifa to Jews; Accept Truce Terms Unconditionally', 23 April 1948' — https://www.jta.org/archive/arabs-surrender-control-of-haifa-to-jews-accept-truce-terms-unconditionally — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - JTA, 23 April 1948: Arab leadership surrendered Haifa to the Haganah after more than 24 hours of fighting

**[S1486]** sightseeinginisrael.com, 'Sightseeing in Israel, 'Exploring the Northern Negev' (Yad Mordechai section)' — https://sightseeinginisrael.com/exploring-the-northern-negev/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Survivors withdrew after the Egyptian assault; kibbutz occupied by Egyptians (Sightseeing in Israel; Encyclopaedia Judaica gives May 1948)
    - Kibbutz Yad Mordechai liberated by the IDF on 5 November 1948 (Sightseeing in Israel); Encyclopaedia Judaica says October 1948

**[S1487]** zochrot.org, 'Zochrot, 'al-Tira (Haifa)' village page (citing Khalidi, All That Remains)' — https://www.zochrot.org/villages/village_details/49200/en — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Tirat Karmel built on the site of the Arab village al-Tira (Haifa) in 1949 (Zochrot, citing Khalidi)

**[S1488]** RETIRED (no longer cited) — ynetnews.com, 'Ynetnews (Matan Tzuri), 'A quarter of the residents of Nir Oz are either dead or missing', October 2023' — https://www.ynetnews.com/article/s1isvvtba

**[S1489]** jpost.com, 'The Jerusalem Post, 'Kibbutz Hanita: A secluded Israeli getaway'' — https://jpost.com/israel-news/article-721929 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Hanita formed 1938 as a Tower and Stockade settlement
    - Hanita an existing kibbutz (formed 1938)

**[S1491]** nsarchive.gwu.edu, 'National Security Archive, GWU, 'Osirak: Israel's Strike on Iraq's Nuclear Reactor, 40 Years Later', 7 June 2021' — https://nsarchive.gwu.edu/briefing-book/iraq-nuclear-vault/2021-06-07/osirak-israels-strike-iraqs-nuclear-reactor-40-years-later — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - National Security Archive: ten Iraqi soldiers and one French engineer killed

**[S1492]** dornsife.usc.edu, 'USC Dornsife, 'Israel bombed an Iraqi nuclear reactor and pushed program underground', 2021' — https://dornsife.usc.edu/news/stories/israel-bombed-an-iraqi-nuclear-reactor-and-pushed-program-underground/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - USC Dornsife: attack killed 10 Iraqi soldiers and a French civilian

**[S1493]** middleeasteye.net, 'Middle East Eye, 'A history of Israel's invasions of Lebanon'' — https://www.middleeasteye.net/explainers/history-israel-invasions-lebanon — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Around 1,000 Lebanese and Palestinians killed, most civilians, and 18 Israeli soldiers (Middle East Eye)

**[S1494]** jewishcurrents.org, 'Jewish Currents, 'Israel's Operation Litani'' — https://jewishcurrents.org/israels-operation-litani — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Jewish Currents: 1,000 to 2,000 Lebanese and Palestinians killed, some 200,000 displaced; 300 PLO fighters

**[S1495]** merip.org, 'MERIP, 'Israel in Lebanon, 1975-1982', Sept 1982' — https://www.merip.org/1982/09/israel-in-lebanon-1975-1982/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - MERIP: about 100 Palestinian guerrillas killed
    - MERIP: over 2,000 Lebanese and Palestinian civilian deaths and over 200,000 refugees

**[S1496]** un.org, 'Lebanon, 'Lebanon and the Fiftieth Anniversary of the Universal Declaration of Human Rights', UN General Assembly document annex, 1998' — https://www.un.org/unispal/document/auto-insert-180386/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Lebanese government (UN document, 1998): 1,168 killed in seven days

**[S1497]** jewishvirtuallibrary.org, 'Jewish Virtual Library, 'Operation Cast Lead: Background & Overview'' — https://www.jewishvirtuallibrary.org/background-and-overview-of-operation-cast-lead — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Operation began 27 December 2008 and ended 18 January 2009 (Jewish Virtual Library)

**[S1498]** ohchr.org, 'OHCHR, 'United Nations Fact Finding Mission on the Gaza conflict'' — https://www.ohchr.org/en/hr-bodies/hrc/special-sessions/session9/fact-finding-mission — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Goldstone mission headline finding, 15 Sept 2009 (OHCHR)
    - Mission refused access to Israel and the West Bank (OHCHR)

**[S1499]** jewishvirtuallibrary.org, 'Jewish Virtual Library, 'Justice Goldstone Refutes Goldstone Report Findings', 3 April 2011 (quoting Goldstone, Washington Post, 1 April 2011)' — https://www.jewishvirtuallibrary.org/justice-goldstone-refutes-goldstone-report-findings-april-2011 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Goldstone Washington Post article of 1 April 2011
    - Goldstone: report would have been a different document
    - Goldstone: would probably have influenced findings on intentionality and war crimes

**[S1550]** PBS Frontline, 'The Gulf War: Oral History - James Baker' (interview transcript), WGBH/PBS, 1996 — https://www.pbs.org/wgbh/pages/frontline/gulf/oral/baker/1.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Shamir held back from retaliating in 1991 despite pressure
    - Defence Minister Arens favoured retaliation
    - Baker credits Shamir with the restraint
    - Arens felt Shamir was wrong not to retaliate

**[S1551]** Jewish Telegraphic Agency, 'Knesset Approves Accord with PLO, in Major Boost to Rabin Government', September 1993 — https://www.jta.org/archive/knesset-approves-accord-with-plo-in-major-boost-to-rabin-government — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Knesset approved the Israel-PLO accord 61-50
    - Likud leader Netanyahu called on his party to stand firm against the accord
    - Rabin welcomed the margin and moved to implement
    - Netanyahu urged Likud to stand firm against the accord

**[S1552]** The Tribune (India) / DPA, 'Netanyahu rejects calls for Lebanon pullout', 1 December 1998 — https://www.tribuneindia.com/1998/98dec01/world.htm — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Netanyahu said troops would stay in south Lebanon until a security arrangement was found
    - Netanyahu: troops stay until an arrangement guarantees security

**[S1553]** Jewish Telegraphic Agency, 'Barak ponders when to withdraw from Lebanon', February 2000 — https://www.jta.org/?p=405558 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Barak vowed to withdraw by July 2000 with or without a Syria deal
    - a withdrawal after a Syria agreement was seen as preferable from the Israeli standpoint
    - Barak vowed to withdraw by July regardless of a Syria deal
    - A withdrawal after a Syria agreement was seen as preferable

**[S1554]** Jewish Telegraphic Agency, 'Sharon wins Knesset vote', 26 October 2004 — https://www.jta.org/2004/10/26/lifestyle/sharon-wins-knesset-vote — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Knesset approved Sharon's disengagement plan 67-45
    - Netanyahu, Livnat, Katz and Naveh demanded a referendum
    - NRP opposed disengagement
    - Knesset approved Sharon's plan to withdraw from Gaza
    - Vote 67-45
    - Netanyahu and three Likud ministers sought a referendum commitment
    - NRP ultimatum: hold a referendum
    - Almost half of Likud's Knesset faction opposed it

**[S1555]** Jewish Telegraphic Agency, 'Settler leaders defiant in meeting with Netanyahu', 3 December 2009 — https://www.jta.org/2009/12/03/israel/settler-leaders-defiant-in-meeting-with-netanyahu — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Settler leaders told Netanyahu they would continue to oppose the building freeze
    - Settler leaders vowed to oppose the freeze

**[S1556]** Jewish Telegraphic Agency, 'Panel set up to review demands following mass Israeli protest', 7 August 2011 — https://www.jta.org/2011/08/07/israel/panel-set-up-to-review-demands-following-mass-israeli-protest — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Netanyahu established a committee to examine the protest movement's demands
    - protest leaders sought direct dialogue with Netanyahu
    - Netanyahu established a committee on the protest demands
    - Protest leaders decried the committee and sought direct dialogue

**[S1557]** Jewish Telegraphic Agency, 'Shalit release deal with Hamas approved', 12 October 2011 — https://www.jta.org/2011/10/12/israel/shalit-release-deal-with-hamas-approved — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Cabinet approved the Shalit deal 26-3
    - Lieberman, Landau and Ya'alon voted against
    - Cabinet approved the deal 26-3

**[S1558]** Jewish Telegraphic Agency, 'Rockets from Gaza still striking Israel after it accepts cease-fire', 15 July 2014 — https://www.jta.org/2014/07/15/israel/rockets-from-gaza-continue-to-strike-israel-after-it-accepts-cease-fire — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel's security cabinet accepted the Egyptian ceasefire proposal on 15 July 2014
    - Hamas reportedly rejected it
    - Security cabinet accepted the Egyptian proposal

**[S1559]** Jewish Telegraphic Agency, 'Israel launches Gaza ground operation', 17 July 2014 — https://www.jta.org/2014/07/17/israel/israel-launches-gaza-ground-operation — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Netanyahu and Ya'alon ordered a ground operation against tunnels on 17 July 2014
    - the Obama administration said it would oppose a ground incursion
    - Netanyahu and Ya'alon ordered the ground operation against tunnels
    - Obama administration would oppose a ground incursion

**[S1560]** Times of Israel, 'Knesset votes contentious Jewish nation-state bill into law', 19 July 2018 (archived) — https://web.archive.org/web/2018/https://www.timesofisrael.com/knesset-votes-contentious-jewish-nation-state-bill-into-law/ — archived: https://web.archive.org/web/2018/https://www.timesofisrael.com/knesset-votes-contentious-jewish-nation-state-bill-into-law/ — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Knesset passed the nation-state law 62-55
    - Netanyahu and Bennett agreed to cut the exclusive-communities clause
    - Rivlin, Mandelblit and others opposed the earlier text
    - Netanyahu and Bennett agreed to cut the clause
    - Passed 62-55
    - Rivlin warned against the earlier text

**[S1561]** Jonathan Lis, 'Israel passes controversial nation-state bill...', Haaretz, 19 July 2018 (archived) — https://web.archive.org/web/20180719003610/https://www.haaretz.com/israel-news/israel-passes-controversial-nation-state-bill-1.6291048 — archived: https://web.archive.org/web/20180719003610/https://www.haaretz.com/israel-news/israel-passes-controversial-nation-state-bill-1.6291048 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 62 MKs voted for the nation-state law and 55 opposed it
    - 55 MKs opposed it

**[S1562]** RETIRED (no longer cited; superseded by S1220) — Times of Israel, ''There can be no civil war': Full text of Netanyahu's announcement on overhaul pause', 28 March 2023 (archived) — https://web.archive.org/web/2026/https://www.timesofisrael.com/there-can-be-no-civil-war-full-text-of-netanyahus-announcement-on-overhaul-pause/

**[S1563]** Jewish Telegraphic Agency, 'Netanyahu announces pause on judiciary reform, in significant victory for protesters', 27 March 2023 — https://www.jta.org/2023/03/27/israel/there-must-not-be-a-civil-war-netanyahu-gives-in-to-calls-to-postpone-judiciary-reform-in-significant-victory-for-protesters — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Netanyahu postponed the second and third readings
    - Smotrich pressed for quick passage until the announcement
    - He postponed the second and third readings
    - Smotrich pressed for quick passage

**[S1564]** Jewish Telegraphic Agency, 'A historic day in Israel ends with a political compromise - and big questions about the future', 27 March 2023 — https://www.jta.org/2023/03/27/israel/a-historic-day-in-israel-ends-with-a-political-compromise-and-big-questions-about-the-future — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the justice minister had threatened to quit if the vote was delayed
    - Levin threatened to quit over a delay

**[S1565]** RETIRED (no longer cited) — Eliyahu Freedman, 'Israel protesters vow to continue until judicial reform gone', Al Jazeera, 28 March 2023 — https://www.aljazeera.com/news/2023/3/28/israel-protesters-vow-to-continue-until-judicial-reform-gone

**[S1567]** RETIRED (no longer cited) — The Hill, 'US pressuring Israel to avoid major ground offensive: Washington Post', October 2023 (archived) — https://web.archive.org/web/20231031050139/https://thehill.com/policy/defense/4280011-us-pressuring-israel-to-avoid-major-ground-offensive-report/

**[S1570]** RETIRED (no longer cited) — Jewish Telegraphic Agency, 'Israel reportedly strikes in Iran days after fending off Iranian missile attack', 18-19 April 2024 — https://www.jta.org/2024/04/18/global/israel-reportedly-strikes-in-iran-days-after-fending-off-iranian-missile-attack

**[S1571]** RETIRED (no longer cited) — Jewish Telegraphic Agency, 'In a change, the Biden administration is now signaling that it backs an Israeli strike against Iran', 11 October 2024 — https://www.jta.org/2024/10/11/politics/in-a-change-the-biden-administration-is-now-signaling-that-it-backs-an-israeli-strike-against-iran

**[S1572]** RETIRED (no longer cited) — Times of Israel liveblog, 'Bennett: Now the time for Israel to destroy Iran's nuclear program', 1 October 2024 (archived) — https://web.archive.org/web/20241001222255/https://www.timesofisrael.com/liveblog_entry/bennett-now-the-time-for-israel-to-destroy-irans-nuclear-program/

**[S1573]** RETIRED (no longer cited) — Times of Israel, 'US, UK urge Tehran to cease attacks after Israel strikes military targets in Iran', 26 October 2024 (archived) — https://web.archive.org/web/2024/https://www.timesofisrael.com/us-uk-urge-tehran-to-cease-attacks-after-israel-strikes-military-targets-in-iran/

**[S1574]** RETIRED (no longer cited; superseded by S1207) — Times of Israel liveblog, 'Security cabinet votes 10-1 to approve Lebanon ceasefire deal', 26 November 2024 (archived) — https://web.archive.org/web/2024/https://www.timesofisrael.com/liveblog_entry/security-cabinet-votes-10-1-to-approve-lebanon-ceasefire-deal/

**[S1575]** RETIRED (no longer cited) — BBC News, report on the Israel-Hezbollah ceasefire terms, November 2024 — https://www.bbc.com/news/articles/cx2d3gj9ewxo

**[S1600]** Central Elections Committee, Official final national results, elections to the 21st Knesset (April 2019), votes21.bechirot.gov.il (Internet Archive snapshot) — https://web.archive.org/web/2020id_/https://votes21.bechirot.gov.il/ — archived: https://web.archive.org/web/2020id_/https://votes21.bechirot.gov.il/ — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Official final results: Likud 35 seats (26.46%), Blue and White 35 seats (26.13%)
    - Likud won 35 seats (certified final results)

**[S1601]** RETIRED (no longer cited) — Al Jazeera, 'Is Trump signalling a return to war with Iran after the midterms?', 9 Oct 2026 — https://www.aljazeera.com/news/2026/10/9/is-trump-signalling-a-return-to-war-with-iran-after-the-midterms

**[S1602]** Eurovisionworld, 'Eurovision 2018 Results: Voting & Points' — https://eurovisionworld.com/eurovision/2018 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel won Eurovision 2018 with 'Toy' by Netta with 529 points
    - Final held 12 May 2018 in Lisbon
    - Netta won with 'Toy' and 529 points

**[S1603]** RETIRED (no longer cited; superseded by S724) — Eurovisionworld, 'Eurovision 2019 Results: Voting & Points' — https://eurovisionworld.com/eurovision/2019

**[S1604]** US Department of State, 'Abraham Accords Peace Agreement: Treaty of Peace, Diplomatic Relations and Full Normalization between the UAE and the State of Israel', 15 Sept 2020 (PDF) — https://www.state.gov/wp-content/uploads/2020/09/UAE_Israel-treaty-signed-FINAL-15-Sept-2020-508.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel-UAE instrument is a treaty of peace and full normalization
    - UAE instrument: treaty of peace, diplomatic relations and full normalization

**[S1605]** US Department of State, 'Abraham Accords: Declaration of Peace, Cooperation, and Constructive Diplomatic and Friendly Relations' (Israel-Bahrain), 15 Sept 2020 (PDF) — https://www.state.gov/wp-content/uploads/2020/09/Bahrain_Israel-Agreement-signed-FINAL-15-Sept-2020-508.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel-Bahrain instrument is a declaration of peace announced 15 Sept 2020
    - Declaration refers to efforts toward resolution of the Israeli-Palestinian conflict
    - Bahrain instrument: declaration of peace, 15 September 2020
    - Declaration refers to resolving the Israeli-Palestinian conflict

**[S1606]** US Department of State, 'The Abraham Accords Declaration' signed for the Republic of Sudan (PDF, posted January 2021) — https://www.state.gov/wp-content/uploads/2021/01/Sudan-AA.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Sudan signed the Abraham Accords Declaration
    - Signature block for Sudan

**[S1700]** RETIRED (no longer cited) — UN OHCHR OPT, Palestine: Human Rights Bulletin (Reporting period: 28 February - 3 March 2026), ReliefWeb, 4 Mar 2026 — https://reliefweb.int/report/occupied-palestinian-territory/palestine-human-rights-bulletin-reporting-period-28-february-3-march-2026-enar

**[S1701]** RETIRED (no longer cited; superseded by S1388) — The Associated Press, Houthi rebels say Israeli airstrike killed their prime minister in Yemen's capital, NPR, 30 Aug 2025 — https://www.npr.org/2025/08/30/nx-s1-5522932/houthi-prime-minister-dead-yemen-israel-airstrike

**[S1702]** UN Security Council, Resolutions 672 (1990) of 12 October 1990 and 673 (1990) of 24 October 1990, UN Official Documents System — https://documents.un.org/doc/resolution/gen/nr0/575/22/pdf/nr057522.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Clashes on 8 October at Haram al-Sharif; UNSC alarm
    - UNSC: over twenty Palestinian deaths and over 150 injured
    - UNSC condemned Israeli security forces
    - Resolution 672 adopted unanimously
    - UNSC deplored Israel's refusal to receive the SG's mission
    - UNSC welcomed and requested the SG mission

**[S1703]** UN Secretary-General, Report submitted to the Security Council in accordance with resolution 672 (1990), S/21919, 31 Oct 1990 — https://documents.un.org/doc/undoc/gen/n90/287/66/pdf/n9028766.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - SG: 17 to 21 Palestinians killed, over 150 wounded
    - SG: more than 20 Israelis wounded
    - Israel appointed its own commission of inquiry

**[S1704]** B'Tselem, The Temple Mount Events (preliminary report), reproduced in UN doc S/21919/Add.1, 1990 — https://documents.un.org/doc/undoc/gen/n90/291/44/pdf/n9029144.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - B'Tselem: at least 17 shot dead on the Mount
    - Planned Temple Mount Faithful cornerstone ceremony

**[S1705]** Permanent Mission of Israel to the UN, Summary of the Report of the Commission of Investigation into Events on the Temple Mount - October 8, 1990, UN doc S/21919/Add.3, 1 Nov 1990 — https://documents.un.org/doc/undoc/gen/n90/291/52/pdf/n9029152.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - High Court refused the Temple Mount Faithful petition
    - Stones and objects thrown at police
    - Injuries at Western Wall Plaza
    - Police used gas, rubber bullets, live ammunition
    - Commission justified live fire
    - Commission criticised senior police command
    - Police had advance warning

**[S1706]** UN OCHA oPt, Protection of Civilians Report | 4 - 17 July 2017, ReliefWeb, 2017 — https://reliefweb.int/report/occupied-palestinian-territory/protection-civilians-report-4-17-july-2017 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 14 July attack killed two policemen at a compound entrance
    - Compound closed for first time since 1969
    - Reopened 16 July with metal detectors
    - Waqf protest
    - Early injuries

**[S1707]** UN OCHA oPt, Protection of Civilians Weekly Report | 18 - 31 July 2017, ReliefWeb, 2017 — https://reliefweb.int/report/occupied-palestinian-territory/protection-civilians-weekly-report-18-31-july-2017 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Five Palestinians killed, 1,015 injured in East Jerusalem clashes
    - Street prayers in protest
    - Two Israeli policemen injured 18-31 July
    - Halamish attack 21 July
    - Halamish location
    - Detectors removed 24 July

**[S1708]** Ynetnews, Two policemen killed in terror attack at Lions' Gate in Jerusalem, attackers dead, 14 Jul 2017 — http://www.ynetnews.com/articles/0,7340,L-4989180,00.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Officers named
    - Satawi from Maghar
    - Shnaan from Hurfeish
    - Attackers from Umm al-Fahm
    - Third policeman lightly hurt

**[S1709]** CNN, 3 Israelis killed in stabbing; 3 Palestinians killed in clashes, 21 Jul 2017 — http://www.cnn.com/2017/07/21/middleeast/old-city-prayer-restrictions-imposed/index.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Restriction on male worshippers under 50

**[S1710]** Al Jazeera, Abbas suspends contact with Israel over al-Aqsa measures (Palestinians killed as Jerusalem protests rage), 22 Jul 2017 — http://www.aljazeera.com/news/2017/07/cloneofal-aqsa-palestinian-killed-jerusalem-prot-170721194023575.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Abbas suspended contacts
    - Muslim leaders' allegation and Israeli denial

**[S1711]** Al Jazeera, What is happening in occupied East Jerusalem's Sheikh Jarrah?, 1 May 2021 — https://www.aljazeera.com/news/2021/5/1/what-is-happening-in-occupied-east-jerusalems-sheikh-jarrah — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Court ordered six families to leave
    - 58 people incl. 17 children faced displacement (Al Jazeera)
    - 1972 lawsuit by settler organisations
    - Families were 1948 refugees from Jaffa and Haifa settled in 1956
    - Jordan-UNRWA housing agreement

**[S1712]** Oliver Holmes and Peter Beaumont, Israeli police storm al-Aqsa mosque ahead of Jerusalem Day march, The Guardian, 10 May 2021 — https://www.theguardian.com/world/2021/may/10/dozens-injured-in-clashes-over-israeli-settlements-ahead-of-jerusalem-day-march — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Police stormed compound on 10 May
    - PRCS: 305 injured
    - Flag march rerouted after security chiefs' appeal

**[S1713]** RETIRED (no longer cited; superseded by S1386) — Oliver Holmes and Peter Beaumont, Israel launches airstrikes on Gaza Strip after Hamas rocket attacks, The Guardian, 10 May 2021 — https://www.theguardian.com/world/2021/may/10/hamas-fires-rockets-into-israel-in-dispute-over-jerusalem-mosque

**[S1714]** Oliver Holmes, What has caused Jerusalem's worst violence in years?, The Guardian, 11 May 2021 — https://www.theguardian.com/world/2021/may/11/what-has-caused-jerusalem-worst-violence-in-years-israel-palestine — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Jewish claim to pre-1948 land
    - Asymmetric property law
    - Ramadan police restrictions
    - Far-right march
    - Court date delayed, march rerouted

**[S1715]** UN OCHA oPt, Protection of Civilians Report | 14-27 February 2023, ReliefWeb, 2023 — https://reliefweb.int/report/occupied-palestinian-territory/occupied-palestinian-territory-protection-civilians-report-14-27-february-2023 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Two Israeli brothers shot on Road 60 in Huwara
    - 37 houses damaged, displacement
    - Vehicles burned
    - Man killed in Za'tara
    - Shooter disputed
    - Nine injured by settlers
    - Soldier injured by settlers (Israeli forces)
    - Firefighter injured when settlers attacked a fire truck

**[S1716]** Bethan McKernan, Israeli settlers rampage after Palestinian gunman kills two, The Guardian, 27 Feb 2023 — https://www.theguardian.com/world/2023/feb/27/israeli-settlers-rampage-after-palestinian-gunman-kills-two-west-bank — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Finance Minister Smotrich
    - 95 treated for tear gas
    - Hundreds of settlers rampaged
    - About 400 settlers (Palestinian official)
    - Netanyahu appeal

**[S1717]** BBC News, Israeli settlers attack Palestinian villages after two settlers shot dead (Hawara), 27 Feb 2023 — https://www.bbc.com/news/world-middle-east-64784053 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Names and ages of brothers
    - Sameh Aqtash, 37
    - Brother says army fired
    - More than 100 injured (MoH)

**[S1718]** Times of Israel, Israel should 'wipe out' Palestinian town of Huwara, says senior minister Smotrich, 1 Mar 2023 — https://www.timesofisrael.com/israel-should-wipe-out-palestinian-town-of-huwara-says-senior-minister-smotrich/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Smotrich 'wipe out' remark
    - Smotrich spoke 1 March 2023
    - General called it a pogrom

**[S1719]** UN OCHA, Israeli forces' operation in Jenin | Situation Report #1 as of 17:00, 6 July 2023, ReliefWeb — https://reliefweb.int/report/occupied-palestinian-territory/israeli-forces-operation-jenin-situation-report-1-1700-6-july-2023 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Operation began 3 July with drone strikes
    - Withdrawal overnight 4-5 July
    - 12 killed incl. 4 children
    - 143 injured
    - One Israeli soldier killed
    - Deadliest since 2005
    - 3,500 displaced
    - Water cut

**[S1720]** UN OCHA oPt, Protection of Civilians Report | 13 June - 4 July 2023, ReliefWeb — https://reliefweb.int/report/occupied-palestinian-territory/occupied-palestinian-territory-protection-civilians-report-13-june-4-july-2023-enarhe — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - One killed in Ramallah protest

**[S1721]** RETIRED (no longer cited) — UN OCHA oPt, Humanitarian Situation Update #330 | West Bank, Oct 2025 — https://www.ochaopt.org/content/humanitarian-situation-update-330-west-bank

**[S1722]** RETIRED (no longer cited) — UN OCHA oPt, Humanitarian Situation Update #352 | West Bank, 20 Jan 2026 — https://www.ochaopt.org/content/humanitarian-situation-update-352-west-bank

**[S1723]** RETIRED (no longer cited) — UN OCHA oPt, West Bank | Monthly Snapshot: Casualties, Property Damage and Displacement, as of 31 August 2026 (PDF) — https://www.ochaopt.org/sites/default/files/West%20Bank_info-graphic_14_September_2026.pdf

**[S1724]** RETIRED (no longer cited) — UN OCHA oPt, Northern West Bank Humanitarian Response Update, 21 January - 30 April 2025 (PDF) — https://www.ochaopt.org/sites/default/files/Northern_West_Bank_Humanitarian_Response_Update_April_2025.pdf

**[S1725]** RETIRED (no longer cited) — Times of Israel (liveblog), Soldier killed in Jenin gunbattle amid West Bank crackdown, 30 Jan 2025 — https://www.timesofisrael.com/liveblog_entry/soldier-killed-in-jenin-gunbattle-amid-west-bank-crackdown/

**[S1726]** RETIRED (no longer cited) — Ramiz Alakbarov (UN Deputy Special Coordinator), Report of the Secretary-General on implementation of UNSC resolution 2334 (2016), 24 Mar 2026, ReliefWeb — https://reliefweb.int/report/occupied-palestinian-territory/report-secretary-general-implementation-un-security-council-resolution-2334-2016-delivered-ramiz-alakbarov-deputy-special-coordinator-middle-east-peace-process-24-march-2026

**[S1727]** RETIRED (no longer cited) — UN OCHA oPt, Humanitarian Situation Update #358 | West Bank, 16 Feb 2026 — https://www.ochaopt.org/content/humanitarian-situation-update-358-west-bank

**[S1728]** RETIRED (no longer cited) — UN Human Rights in the OPT, E1 settlement plan, another unlawful step to consolidate the annexation of the occupied West Bank, including East Jerusalem, ReliefWeb, 21 Aug 2025 — https://reliefweb.int/report/occupied-palestinian-territory/un-human-rights-occupied-palestinian-territory-e1-settlement-plan-another-unlawful-step-consolidate-annexation-occupied-west-bank-including-east-jerusalem-enar

**[S1729]** RETIRED (no longer cited) — Human Rights Watch, West Bank: Illegal E1 Settlement Tender Opens Bids, ReliefWeb, 19 Aug 2026 — https://reliefweb.int/report/occupied-palestinian-territory/west-bank-illegal-e1-settlement-tender-opens-bids

**[S1730]** RETIRED (no longer cited) — Ramiz Alakbarov (UN Acting Special Coordinator), Report of the Secretary-General on implementation of UNSC resolution 2334 (2016), 28 Sep 2026, ReliefWeb — https://reliefweb.int/report/occupied-palestinian-territory/report-secretary-general-implementation-un-security-council-resolution-2334-2016-delivered-ramiz-alakbarov-acting-special-coordinator-middle-east-peace-process-28-september-2026

**[S1731]** RETIRED (no longer cited) — UN OCHA oPt, Humanitarian Situation Report, 2 October 2026 — https://www.ochaopt.org/content/humanitarian-situation-report-2-october-2026

**[S1732]** RETIRED (no longer cited) — BBC News, Japan condemns Houthi hijacking of cargo ship Galaxy Leader in Red Sea, 20 Nov 2023 — https://www.bbc.com/news/world-middle-east-67470711

**[S1733]** RETIRED (no longer cited) — Michael Jansen, Israel's Red Sea port of Eilat halts operations due to Yemeni-Houthi blockade, The Irish Times, 20 Jul 2025 — https://www.irishtimes.com/world/middle-east/2025/07/20/israels-red-sea-port-of-eilat-halts-operations-due-to-yemeni-houthi-blockade/

**[S1734]** RETIRED (no longer cited; superseded by S1468) — Associated Press via NBC News, Yemen's Houthi rebels signal that they've stopped attacks on Israel and Red Sea shipping, 11 Nov 2025 — https://www.nbcnews.com/world/middle-east/yemens-houthi-rebels-signal-stopped-attacks-israel-red-sea-shipping-rcna243165

**[S1735]** RETIRED (no longer cited) — Al Jazeera, Drone attack on Israel's Tel Aviv leaves one dead, at least 10 injured, 19 Jul 2024 — https://www.aljazeera.com/news/2024/7/19/drone-attack-on-israels-tel-aviv-leaves-one-dead-at-least-10-injured

**[S1736]** RETIRED (no longer cited; superseded by S1389) — Ruth Michaelson et al., Israel strikes Yemen port after Houthi rebels attack Tel Aviv, The Guardian, 20 Jul 2024 — https://www.theguardian.com/world/article/2024/jul/20/airstrikes-hit-yemens-hodeidah-port-after-israel-vows-revenge-for-houthi-attack

**[S1737]** RETIRED (no longer cited) — CNN, At least 6 killed, Houthis say, as Israeli airstrikes hit Yemen day after Tel Aviv drone attack, 20 Jul 2024 — https://www.cnn.com/2024/07/20/middleeast/yemen-israel-strikes-hodeidah-intl/index.html

**[S1738]** RETIRED (no longer cited) — CNN, Missile fired from Yemen hits Tel Aviv after failed interception, 21 Dec 2024 — https://edition.cnn.com/2024/12/20/middleeast/tel-aviv-hit-by-projectile-from-yemen-intl-hnk/index.html

**[S1739]** RETIRED (no longer cited) — Al Jazeera, Israel strikes Yemen's Sanaa airport, Hodeidah power plant, 26 Dec 2024 — https://www.aljazeera.com/news/2024/12/26/israel-strikes-yemens-sanaa-airport-other-key-sites-reports

**[S1740]** RETIRED (no longer cited) — BBC News, Israel strikes Houthi targets in Yemen a day after missile attack near airport, 5 May 2025 — https://www.bbc.com/news/articles/c4g9njjrek2o

**[S1741]** RETIRED (no longer cited) — Al Jazeera, Yemen's Houthis vow retaliation after Israeli attacks on Sanaa, 6 May 2025 — https://www.aljazeera.com/news/2025/5/6/israeli-strikes-rock-yemens-sanaa-including-international-airport

**[S1742]** RETIRED (no longer cited) — The Guardian, US agrees ceasefire with Houthis in Yemen after dozens killed in airstrikes, 6 May 2025 — https://www.theguardian.com/world/2025/may/06/us-to-halt-bombing-campaign-against-houthis-in-yemen-trump-says

**[S1743]** RETIRED (no longer cited) — Al Jazeera (Newsfeed), Israeli airstrikes rock Yemen after Tel Aviv airport attack, 5 May 2025 — https://www.aljazeera.com/program/newsfeed/2025/5/5/israeli-airstrikes-rock-yemen-after-tel-aviv-airport-attack

**[S1744]** RETIRED (no longer cited) — Al Jazeera, Yemen's Houthis confirm prime minister killed in Israeli strike on Sanaa, 30 Aug 2025 — https://www.aljazeera.com/news/2025/8/30/yemens-houthis-confirm-israeli-airstrike-killed-the-groups-prime-minister

**[S1745]** RETIRED (no longer cited) — Al Jazeera, Israeli bombardment kills 10 in Yemen's Sanaa after Houthi attacks, 24 Aug 2025 — https://www.aljazeera.com/news/2025/8/24/israeli-military-targets-yemens-sanaa-after-houthi-attacks

**[S1746]** Al Jazeera, Israeli strikes pound Yemen's capital as Houthi leader decries Gaza war, 25 Sep 2025 — https://www.aljazeera.com/news/2025/9/25/israeli-strikes-pound-yemens-capital-as-houthi-leader-decries-gaza-war — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - September strikes killed 40+

**[S1750]** RETIRED (no longer cited; superseded by S1229) — Zochrot, al-Dawayima (village page, Nakba Map; background text from W. Khalidi (ed.), All That Remains, 1992), zochrot.org — https://www.zochrot.org/villages/village_details/49115/en

**[S1751]** Jonathan Ofir (Mondoweiss), 'Barbarism by an educated and cultured people' - Dawayima massacre was worse than Deir Yassin, republished by Zochrot, 5 Feb 2016 — https://www.zochrot.org/publication_articles/view/56175/en?Barbarism_by_an_educated_and_cultured_people__Dawayima_massacre_was_worse_than_Deir_Yassin — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Haaretz published (5 Feb 2016) historian Yair Auron's article with an Israeli soldier's letter: 80 to 100 killed
    - Benny Morris in 2004 Haaretz interview called it a massacre of 'hundreds'
    - Soldier's letter: no resistance; 80-100 killed
    - Morris in 2004 called it a massacre of 'hundreds'

**[S1752]** Jonathan Ofir, The Mukhtar's sworn testimony: More on the Dawaymeh massacre, Mondoweiss, 12 Feb 2016 (includes transcript of UN Conciliation Commission for Palestine, Technical Committee, Com.Tech/W.3, 14 June 1949, report submitted by the Arab Refugee Congress of Ramallah) — https://mondoweiss.net/2016/02/the-mukhtars-sworn-testimony-more-on-the-dawaymeh-massacre/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - mukhtar Hassan Mahmoud Ihdeib's sworn statement: ~60 bodies in mosque, 85 at Iraq El Zagh cave
    - mukhtar census: 455 missing (280 men, rest women and children)
    - village population 6,000 plus some 4,000 refugees
    - no call to surrender and no resistance (per mukhtar)
    - results of Israeli investigations remain classified (per Auron/Ofir)
    - Mukhtar: about 60 bodies in the mosque
    - Mukhtar: 85 bodies at the cave
    - Mukhtar census: 455 missing
    - Population 6,000 plus about 4,000 refugees (Arab Refugee Congress)
    - Mukhtar: no call to surrender and no resistance
    - State Attorney inquiry conclusions never published

**[S1753]** Provisional Government of Israel (Aubrey S. Eban), Letter dated 8 November 1948 addressed to the President of the Security Council (S/1073), UNISPAL, United Nations — https://www.un.org/unispal/document/auto-insert-210480/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel told the Security Council that Dawayma had been completely abandoned by its civilian population before it was occupied
    - Israeli letter to the Security Council dated 8 Nov 1948
    - Israel told the Security Council the village was abandoned before capture (8 Nov 1948)

**[S1754]** RETIRED (no longer cited; superseded by S1228) — Zochrot, Remembering Bir al-Saba' (booklet, prepared for a visit on 8 July 2006), zochrot.org — https://zochrot.org/publication_articles/view/49869/en

**[S1755]** Zochrot, Bir Saba' (Beersheba) (village page, Nakba Map), zochrot.org — https://www.zochrot.org/villages/village_details/49062/en — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Beersheba 1948 population 6,460
    - occupation date 21/10/1948
    - 1948 population 6,460
    - Occupation date 21 Oct 1948
    - Zochrot: Beersheba occupation date 21/10/1948

**[S1756]** JTA, Israel declassifies 200,000 documents from probe into alleged kidnapping of Yemenite babies, Jewish Telegraphic Agency, 28 Dec 2016 — https://www.jta.org/2016/12/28/israel/israel-declassifies-200000-documents-from-probe-into-alleged-kidnapping-of-yemenite-babies — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - online database of ~200,000 pages launched 28 Dec 2016
    - more than 1,000 families alleged kidnapping since the 1950s
    - three committees concluded most children died in hospital
    - database covers 1948-1954
    - More than 1,000 families alleged kidnapping since the 1950s
    - Three committees: most children died in hospital and buried without informing families
    - Database launched with ~200,000 pages (JTA)
    - Database covers 1948-1954

**[S1757]** Times of Israel, Israel opens database with 400,000 declassified documents on Yemenite Children Affair, 28 Dec 2016 — https://www.timesofisrael.com/israel-opens-database-with-200000-declassified-documents-on-painful-yemenite-children-affair/ — archived: https://web.archive.org/web/20250106150342/https://www.timesofisrael.com/israel-opens-database-with-200000-declassified-documents-on-painful-yemenite-children-affair/ — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - ToI put the database at some 400,000 pages
    - last panel (2001) sealed testimonies for 70 years
    - families from Yemenite and North African communities allege systematic kidnapping
    - ToI: database of some 400,000 pages, 28 Dec 2016
    - Date of launch 28 Dec 2016 at PMO in Jerusalem
    - Testimonies sealed 70 years

**[S1758]** Times of Israel (ToI Staff), Government expresses 'regret,' will compensate for disappeared Yemenite children, 22 Feb 2021 — https://www.timesofisrael.com/government-set-to-express-regret-compensate-for-disappeared-yemenite-children/ — archived: https://web.archive.org/web/20240929170825/https://www.timesofisrael.com/government-set-to-express-regret-compensate-for-disappeared-yemenite-children/ — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - NIS 162 million compensation plan approved 22 Feb 2021
    - NIS 150,000 / NIS 200,000 per child
    - over 1,000 families incl. dozens from the Balkans and North Africa
    - Cohen-Kedmi 2001: no systematic effort; 69 children disappeared without a trace
    - regret but no official apology; Amram Association criticism
    - Over 1,000 families, mostly Yemen, also Balkans, North Africa; adoption sometimes abroad
    - Alleged kidnapping from hospitals and adoption, sometimes abroad
    - Cohen-Kedmi: no systematic effort; 69 disappeared without a trace
    - Cohen-Kedmi report dated 2001
    - 69 children disappeared without a trace
    - Families argue it reflected policy
    - 2021: NIS 162 million plan approved
    - Announcement on Monday 22 Feb 2021
    - Payments NIS 150,000 / 200,000 per child
    - Regret but no official apology
    - Amram: missing an official apology

**[S1759]** Haaretz, A mystery that defies solution (reprinted by the Jewish Agency for Israel, 'Yemenite children'), Nov 2001 — http://www.jewishagency.org/JewishAgency/English/Jewish+Education/Compelling+Content/Eye+on+Israel/Current+Issues/Society+and+Politics/Yemenite+children.htm — archived: https://web.archive.org/web/20080904234930/http://www.jewishagency.org/JewishAgency/English/Jewish%2BEducation/Compelling%2BContent/Eye%2Bon%2BIsrael/Current%2BIssues/Society%2Band%2BPolitics/Yemenite%2Bchildren.htm — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - first committee 1967
    - second commission found no evidence of criminal activity
    - third commission established 1995 under Judge Yehuda Cohen, later Judge Yaacov Kedmi
    - report published Nov 4: documentation for 972 of 1,033 cases; 5 alive; 56 unresolved
    - First committee in 1967
    - Second commission found no evidence of criminal activity
    - Third commission established 1995 under Cohen, later Kedmi
    - 2001 commission: documentation for 972 of 1,033; 5 alive; 56 unresolved
    - Five found alive, 56 unresolved
    - Possible adoption by individual social workers, not official policy
    - Disappearances from immigrant camps, clinics and hospitals (1967 claims, 1949-52)

**[S1760]** Moshe Reinfeld, State Commission: Missing Yemenite Babies Not Kidnapped, Haaretz, 4 Nov 2001 — https://www.haaretz.com/2001-11-04/ty-article/state-commission-missing-yemenite-babies-not-kidnapped/0000017f-f713-d5bd-a17f-f73b830f0000 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 2001 state commission found no basis to kidnapping claims; most children died
    - 2001 commission: no basis for kidnapping claims; most died

**[S1761]** Ehud Ein-Gil, Decades Later, Disappearance of 1,000 Children in Israel Remains a Mystery, Haaretz, 9 Jun 2016 — https://www.haaretz.com/israel-news/.premium.MAGAZINE-disappearance-of-1-000-mizrahi-children-still-a-mystery-1.5393945 — archived: https://web.archive.org/web/20190803140138/https://www.haaretz.com/israel-news/.premium.MAGAZINE-disappearance-of-1-000-mizrahi-children-still-a-mystery-1.5393945 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Shalgi Commission established in 1988

**[S1762]** Yolande Knell, Missing babies: Israel's Yemenite children affair, BBC News, 20 Jun 2017 — https://www.bbc.com/news/magazine-40342143 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - three government inquiries since the 1960s concluded most children died of diseases
    - Knesset committee heard testimony on medical experiments
    - Inquiries since the 1960s: most died of diseases
    - Parents told children had died
    - Clinic in Tel Aviv (case example)

**[S1763]** Jonathan Cook, The shocking story of Israel's disappeared babies, Al Jazeera, 5 Aug 2016 — https://www.aljazeera.com/news/2016/8/5/the-shocking-story-of-israels-disappeared-babies — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Kedmi inquiry found as many as 5,000 children may have disappeared, examined 1,000 cases
    - missing children also from Iraq, Morocco, Tunisia and the Balkans
    - families/activists allege children were taken and given to Ashkenazi families
    - Al Jazeera: Kedmi said up to 5,000 may have disappeared; examined 1,000
    - Also children from Iraq, Morocco, Tunisia and the Balkans

**[S1764]** RETIRED (no longer cited; superseded by S1296) — UN OCHA oPt, Gaza Strip: The humanitarian impact of 15 years of the blockade - June 2022 — https://www.ochaopt.org/content/gaza-strip-humanitarian-impact-15-years-blockade-june-2022

**[S1765]** Israel Ministry of Foreign Affairs (PM's Media Adviser), Security Cabinet declares Gaza hostile territory, 19 Sep 2007 — http://www.mfa.gov.il/MFA/Government/Communiques/2007/Security+Cabinet+declares+Gaza+hostile+territory+19-Sep-2007.htm — archived: https://web.archive.org/web/20101227021816/http://www.mfa.gov.il/MFA/Government/Communiques/2007/Security+Cabinet+declares+Gaza+hostile+territory+19-Sep-2007.htm — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 19 Sep 2007 Security Cabinet declared Gaza hostile territory
    - rationale: Kassam rocket fire at Sderot
    - sanctions restricting goods, fuel, electricity and movement
    - 19 Sep 2007 Security Cabinet meeting citing Kassam fire on Sderot
    - Rationale: Kassam rocket fire at Sderot
    - Gaza declared hostile territory
    - Sanctions on goods, fuel, electricity, movement

**[S1766]** United Nations, Report of the Secretary-General's Panel of Inquiry on the 31 May 2010 Flotilla Incident (Palmer report), Sep 2011 — http://www.un.org/News/dh/infocus/middle_east/Gaza_Flotilla_Panel_Report.pdf — archived: https://web.archive.org/web/20160102054657/http://www.un.org/News/dh/infocus/middle_east/Gaza_Flotilla_Panel_Report.pdf — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - tightening of Gaza border controls after Hamas takeover June 2007
    - more than 5,000 rockets/mortars fired 2005-Jan 2009
    - naval blockade (Jan 2009) a legitimate security measure to prevent weapons entering by sea
    - humanitarian situation unsustainable
    - Border controls tightened after June 2007 takeover; naval blockade Jan 2009
    - More than 5,000 rockets/mortars 2005-Jan 2009
    - Rocket attacks caused more than 25 deaths since 2001
    - Panel: naval blockade legitimate security measure
    - Panel: humanitarian situation unsustainable

**[S1767]** Associated Press, Egypt to reopen Gaza strip crossing for first time since 2007, The Guardian, 25 May 2011 — https://www.theguardian.com/world/2011/may/25/egypt-to-reopen-gaza-strip-crossing — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel and Egypt closed their crossings in 2007 when Hamas seized control
    - Israel charges Hamas used tunnels to import weapons including rockets
    - Israel and Egypt closed crossings in 2007 when Hamas seized control
    - Israel's rationale: tunnels used to import weapons incl. rockets
    - Egypt to reopen Rafah (May 2011)
    - Article dated 25 May 2011

**[S1768]** Israel Democracy Institute, Elections for the 18th Knesset (2009), en.idi.org.il — https://en.idi.org.il/israeli-elections-and-parties/elections/2009/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - election 10.2.2009
    - Kadima 28, Likud 27, Yisrael Beitenu 15, Labor 13, Shas 11
    - turnout 64.8%
    - President called on Netanyahu; coalition of six groups, 74 MKs
    - Election date 10.2.2009 (18th Knesset)
    - Turnout 64.8%
    - Kadima 28 over Likud 27
    - Labor 13 seats
    - Yisrael Beytenu 15; Arab parties 11
    - Shas 11 seats
    - Olmert resigned; Livni failed; early elections
    - President called on Netanyahu
    - Coalition of six groups, 74 MKs
    - 74 MKs

**[S1769]** Knesset, Eighteenth Knesset: Government 32, knesset.gov.il — https://knesset.gov.il/govt/eng/GovtByNumber_eng.asp?govt=32 — archived: https://web.archive.org/web/20160110180253/https://www.knesset.gov.il/govt/eng/GovtByNumber_eng.asp?govt=32 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Government 32 headed by Benjamin Netanyahu, 31/03/2009 - 18/03/2013
    - Government 32 headed by Netanyahu from 31/03/2009

**[S1800]** Encyclopaedia Britannica, 'Oslo Accords' (Internet Archive snapshot, 2024) — https://www.britannica.com/topic/Oslo-Accords — archived: https://web.archive.org/web/2024/https://www.britannica.com/topic/Oslo-Accords — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Oslo II provided for redeployment of Israeli forces from Jenin, Nablus, Tulkarm, Qalqilya, Ramallah and Bethlehem and some 440 villages before Palestinian elections
    - Oslo II divided the West Bank and Gaza into Areas A, B and C
    - Redeployment from Jenin, Nablus, Tulkarm, Qalqilya, Ramallah, Bethlehem and some 440 villages before elections (places)

**[S1801]** Israel Ministry of Foreign Affairs, 'The Israeli-Palestinian Interim Agreement' (full text, 28 Sept 1995; Internet Archive snapshot of mfa.gov.il) — http://www.mfa.gov.il/MFA/Peace+Process/Guide+to+the+Peace+Process/THE+ISRAELI-PALESTINIAN+INTERIM+AGREEMENT.htm — archived: http://web.archive.org/web/2012/http://www.mfa.gov.il/MFA/Peace+Process/Guide+to+the+Peace+Process/THE+ISRAELI-PALESTINIAN+INTERIM+AGREEMENT.htm — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Art. XI(3): definitions of Areas A, B (by map) and C (rest of the West Bank, to be gradually transferred)
    - Art. XIII: Council internal security in Area A; Area B public order for Palestinians with Israeli overriding security responsibility
    - Agreement text defines Area A and B by map and Area C as the rest of the West Bank, to be gradually transferred
    - Area A: Council assumes internal security and public order
    - Area B: Council public order for Palestinians; Israel overriding security responsibility

**[S1802]** Human Rights Watch, World Report 1997: Israel, the Occupied West Bank and Gaza Strip, and Palestinian Authority Territories — https://www.hrw.org/reports/1997/WR97/ME-06.htm — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - September 1996 decision to open a new tunnel entrance triggered protests throughout the West Bank and Gaza
    - Palestinian police and armed civilians exchanged fire with Israeli soldiers
    - Al-Aqsa compound incident on 27 September 1996
    - Decision to open the tunnel entrance in September 1996 triggered protests and clashes, incl. Palestinian police exchanging fire with soldiers
    - Date: late September 1996 (HRW: decision of 25 September; clashes to 27 September)
    - date_end 27 September: Al-Aqsa compound clash

**[S1803]** The Guardian, 'Minister's death stuns Israel', 17 October 2001 — https://www.theguardian.com/world/2001/oct/17/israel3 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - PFLP claimed the killing of Rehavam Ze'evi as retaliation for Israel's killing of its leader Abu Ali Mustafa on 27 August 2001 in Ramallah
    - PFLP presented it as retaliation for Israel's killing of PFLP leader Abu Ali Mustafa in August 2001

**[S1804]** The Guardian, 'Pain and protest as troops clear settlers', 18 August 2005 — https://www.theguardian.com/world/2005/aug/18/israel4 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Neve Dekalim, the largest Gaza settlement, cleared during the evacuation
    - Shilo shooting: three Palestinians killed, two wounded (17 Aug 2005)
    - Army deserter killed a bus driver and three passengers, all Arabs (Aug 2005)
    - Neve Dekalim, the largest Gaza settlement, evacuated (place neve_dekalim)
    - Shilo: three Palestinians killed, two wounded
    - Shilo: two shot dead first

**[S1805]** Chris McGreal, 'Hamas makes gains against Fatah, but fails to win power', The Guardian, Thu 26 January 2006 — https://www.theguardian.com/world/2006/jan/26/israel — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Palestinian legislative election voting took place on 25 January 2006 ('voted yesterday' in the 26 Jan edition)
    - Date: polling on 25 January 2006 (Guardian of Thursday 26 January: 'voted yesterday')

**[S1850]** Josef Federman and Ilan Ben Zion, The Associated Press, 'Netanyahu delays judicial overhaul after mass protests' (CityNews Toronto syndication), 28 March 2023 — https://toronto.citynews.ca/2023/03/28/israel-strike-union-netanyahu-overhaul-judiciary/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Protest leader Shikma Bressler said the campaign would continue until the legislation is canceled (after Netanyahu's 27 March 2023 pause)
    - Protest leader Shikma Bressler: campaign to continue until the legislation is cancelled

**[S1851]** RETIRED (no longer cited) — Ashley Wong, 'Israel orders evacuation of more than 20,000 Kiryat Shmona residents', JURIST, 22 October 2023 — https://www.jurist.org/news/2023/10/israel-orders-evacuation-of-more-than-20000-kiryat-shmona-residents/

**[S1852]** RETIRED (no longer cited) — Times of Israel (AFP), "'We live in darkness': Bombed-out Metula's last few residents hope to rebuild", December 2024 (Israel at war day 433) — https://www.timesofisrael.com/we-live-in-darkness-bombed-out-metulas-last-few-residents-hope-to-rebuild/

**[S1900]** Encyclopaedia Britannica, "Moshe Dayan" (Internet Archive snapshot, 2024) — https://www.britannica.com/biography/Moshe-Dayan — archived: https://web.archive.org/web/2024/https://www.britannica.com/biography/Moshe-Dayan — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Dayan appointed minister of defense on 1 June 1967
    - Dayan appointed defence minister on 1 June 1967

**[S1901]** Encyclopaedia Britannica, "Six-Day War" (last updated 17 Dec 2024; Internet Archive snapshot 2 Jan 2025) — https://www.britannica.com/event/Six-Day-War — archived: https://web.archive.org/web/20250102060126/https://www.britannica.com/event/Six-Day-War — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Egypt's casualties more than 11,000, with 6,000 for Jordan and 1,000 for Syria
    - Britannica: Egyptian casualties more than 11,000, 6,000 for Jordan

**[S1902]** UN Security Council, S/12126: Letter dated 6 July 1976 from the Assistant Executive Secretary of the OAU (telegram of the OAU Current Chairman) — https://documents.un.org/api/symbol/access?s=S/12126&l=en&t=pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Over 100 members of the Ugandan Army reportedly killed (information from Uganda's President)
    - over 100 Ugandan soldiers reportedly killed (Uganda's information, OAU telegram)

**[S1903]** UN General Assembly/Security Council, A/9515-S/11259: Letter dated 11 April 1974 from the Permanent Representative of Israel — https://documents.un.org/api/symbol/access?s=S/11259&l=en&t=pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Attackers seized an apartment building in Kiryat Shmona; 18 inhabitants killed including 8 children
    - attackers seized an apartment building in Kiryat Shmona (Israel letter to the UN)

**[S1904]** UN Security Council, S/11263: Letter from the Permanent Representative of Lebanon replying to A/9515-S/11259 (April 1974) — https://documents.un.org/api/symbol/access?s=S/11263&l=en&t=pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Lebanon denied the attackers came from Lebanon; the attackers themselves died
    - the attackers were also killed (as summarised in Lebanon's letter to the UN)
    - Lebanon: PLO and PFLP declared the perpetrators came from the occupied territories, not from outside

**[S1905]** Jerusalem Post, "Personal Encounter: The meatman of Yamit" (Internet Archive snapshot) — https://www.jpost.com/Features/Personal-Encounter-The-meatman-of-Yamit — archived: https://web.archive.org/web/20190825100804/https://www.jpost.com/Features/Personal-Encounter-The-meatman-of-Yamit — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Founding garin member: "We began building Yamit on January 17, 1975"
    - date 1975-01-17: the founding garin began building Yamit on 17 January 1975 (places: yamit, sinai)
    - founded 1975 (building began 17 January 1975)

**[S1906]** Jordan Times, "UJ celebrates 47th anniversary of Karameh battle" (2015; opened via Internet Archive) — https://www.jordantimes.com/news/local/uj-celebrates-47th-anniversary-karameh-battle — archived: https://web.archive.org/web/2026/https://www.jordantimes.com/news/local/uj-celebrates-47th-anniversary-karameh-battle — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 86 Jordanian soldiers killed and 108 wounded at Karameh (Jordanian account)
    - Jordanian figure: 86 Jordanian soldiers killed (second source)
    - Jordanian claim: 250 Israeli soldiers killed, 450 wounded

**[S1950]** John Yemma, "New figures emerge on the cost in lives of Israel's war in Lebanon", The Christian Science Monitor, 21 Dec 1982 — https://www.csmonitor.com/1982/1221/122162.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Lebanese police: 19,085 killed and 30,302 wounded 4 June-31 Aug 1982
    - Israeli army: 446 soldiers killed by 19 Nov 1982
    - 328 killed in the September camp massacres, 991 missing
    - Lebanese police figures: 19,085 killed and 30,302 wounded between 4 June and 31 August 1982
    - in Beirut 84 percent of the 6,775 dead were civilians; fighters included in the toll
    - toll includes Palestinian, Syrian and Lebanese fighters
    - Israeli army: 446 soldiers killed by 19 November 1982

**[S1951]** JTA Daily Bulletin, "Israeli Casualty Figures", 30 June 1982 — https://www.jta.org/archive/israeli-casualty-figures — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israel: 269 soldiers killed in the first 20 days of fighting in Lebanon
    - Israeli army: 269 soldiers killed in the first 20 days

**[S1952]** JTA Daily Bulletin, "Sharon: Israel Did Not Wage War Against Palestinian People but Against the PLO Terrorists", 30 Aug 1982 — https://www.jta.org/archive/sharon-israel-did-not-wage-war-against-palestinian-people-but-against-the-plo-terrorists — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Sharon: some 2,000 civilian casualties in Lebanon; 350 Israeli soldiers killed during the operation
    - Sharon: some 2,000 civilian casualties; 350 Israeli soldiers killed in the operation
    - Sharon disputed media casualty figures

**[S1953]** Institute for Palestine Studies, The Palestine Chronology, "Friday, September 24, 1982" — https://chronology.palestine-studies.org/chronology/1982-sep-24 — archived: https://web.archive.org/web/2026id_/https://chronology.palestine-studies.org/chronology/1982-sep-24 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - ICRC total 317 bodies; Lebanese Prosecutor General: 597 bodies found, 2,000 missing (Sabra and Shatila)
    - Lebanon's prosecutor general reported 597 bodies found and 2,000 people missing

**[S1954]** "Israelis, at Huge Rally in Tel Aviv, Demand Begin and Sharon Resign", The New York Times, 26 Sep 1982 (Internet Archive snapshot) — https://www.nytimes.com/1982/09/26/world/israelis-at-huge-rally-in-tel-aviv-demand-begin-and-sharon-resign.html — archived: https://web.archive.org/web/20251001200143id_/https://www.nytimes.com/1982/09/26/world/israelis-at-huge-rally-in-tel-aviv-demand-begin-and-sharon-resign.html — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - organisers put the crowd at 350,000
    - speakers called on Begin and Sharon to resign and for an independent judicial inquiry
    - organisers told the New York Times the crowd numbered 350,000
    - speakers called for Begin's and Sharon's resignation and an independent judicial inquiry

**[S1955]** JTA Daily Bulletin, "400,000 People at Protest Rally", 29 Sep 1982 — https://www.jta.org/archive/400000-people-at-protest-rally — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - organisers (Labor Alignment, Shinui, Peace Now) claimed over 400,000; police gave no estimate
    - date 1982-09-25 (Saturday night): rally against the massacre and the refusal to set up an independent inquiry (place: tel_aviv)
    - speakers called for the resignations of Begin and Sharon

**[S1956]** UN Security Council, S/12600: Letter dated 15 March 1978 from the Permanent Representative of Lebanon to the President of the Security Council — https://documents.un.org/api/symbol/access?s=S/12600&l=en&t=pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israeli forces entered south Lebanon on the night of 14/15 March 1978
    - an undetermined number of Lebanese citizens were killed, notably in Tyre
    - large numbers of people leaving the south for the north
    - Lebanon had no connection with the Haifa-Tel Aviv road attack
    - Lebanon reported an undetermined number of Lebanese citizens killed, notably in Tyre, and large numbers fleeing the south
    - Lebanon protested that it had no connection with the commando raid

**[S1957]** UN Security Council, S/12620: Report of the Secretary-General on the implementation of Security Council resolution 425 (1978) — https://documents.un.org/api/symbol/access?s=S/12620&l=en&t=pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - arrangements to facilitate the return of displaced persons who fled southern Lebanon during the military operation
    - people displaced from southern Lebanon

**[S1958]** JTA, "Israel Celebrates Quarter-century Since Strike on Iraqi Nuke Facilities", 8 June 2006 — https://www.jta.org/archive/israel-celebrates-quarter-century-since-strike-on-iraqi-nuke-facilities — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - eight Israeli F-16s struck the Osirak reactor on 7 June 1981
    - eight F-16s

**[S1959]** JTA Daily Bulletin, "Commission of Inquiry Makes Public Its Report, Recommends Sharon Resign or Be Dismissed by Begin", 9 Feb 1983 — https://www.jta.org/archive/commission-of-inquiry-makes-public-its-report-recommends-sharon-resign-or-be-dismissed-by-begin-fau — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the Kahan Commission report was published (dispatch dated 9 Feb 1983: 'this morning')
    - it recommended Sharon resign or be dismissed
    - date: the report was made public on 8-9 February 1983 (JTA bulletin of 9 February: published 'this morning')

**[S1960]** JTA Daily Bulletin, "Cabinet Votes 16-1 to Accept in Full Inquiry Panel's Recommendations", 11 Feb 1983 — https://www.jta.org/archive/cabinet-votes-16-1-to-accept-in-full-inquiry-panels-recommendations — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the cabinet voted 16-1 to accept the commission's report and recommendations; Sharon cast the lone dissenting vote
    - recommended that Sharon resign or be dismissed
    - the cabinet voted 16-1 to accept the recommendations, Sharon casting the only vote against

**[S1961]** JTA Daily Bulletin, "Terrorist Carnage: 37 Israeli Civilians Dead; 82 Injured; Curfew Imposed on Tel Aviv Area, Begin Says", 13 Mar 1978 — https://www.jta.org/archive/terrorist-carnage-37-israeli-civilians-dead-82-injured-curfew-imposed-on-tel-aviv-area-begin-says — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Begin: 37 Israeli civilians died and 76 were injured; a later report put the injured at 82
    - a later report put the wounded at 82

**[S1962]** JTA Daily Bulletin, "Terrorists' Trial Opens", 10 Aug 1979 — https://www.jta.org/archive/terrorists-trial-opens — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the two captured attackers were the only survivors of the 11-member raiding party; the others were killed in a shootout
    - eleven attackers; two captured and tried, the other nine killed

**[S1963]** JTA Daily Bulletin, "Israel Troops Enter West Beirut Following Gemayel's Assassination", 16 Sep 1982 — https://www.jta.org/archive/israel-troops-enter-west-beirut-following-gemayels-assassination — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Gemayel killed when a bomb destroyed Phalangist headquarters in east Beirut; eight others reported dead and at least 50 injured
    - killed by a bomb that destroyed the Phalangist headquarters in east Beirut; eight others reported dead and at least 50 injured

**[S1964]** JTA Daily Bulletin, "Background Report: Speculation That Gemayel's Links to Israel and Leanings Toward a Peace Treaty Led...", 16 Sep 1982 — https://www.jta.org/archive/background-report-speculation-that-gemayels-links-to-israel-and-leanings-toward-a-peace-treaty-led — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Gemayel was elected on 23 August 1982
    - elected president on 23 August 1982

**[S1965]** JTA Daily Bulletin, "No Comment Available on Reports That Some 2,000 Ethiopian Jews Have Died in Refugee Camps in Eastern Sudan", 22 Jan 1985 — https://www.jta.org/archive/no-comment-available-on-reports-that-some-2000-ethiopian-jews-have-died-in-refugee-camps-in-eastern — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - NYT reports quoting Sudanese officials and relief workers: at least 2,000 Ethiopian Jews died in Sudanese refugee camps; nearly 1,800 of 7,000 at Umm Rekuba
    - reports said at least 2,000 Ethiopian Jews died in the Sudanese camps
    - nearly 1,800 of 7,000 died at Umm Rekuba; reports quoted Sudanese officials and relief workers

**[S1966]** JTA, "Prisoner-swap Deal with Hezbollah Not First Time Israel's Paid the Price", 27 Jan 2004 — https://www.jta.org/archive/prisoner-swap-deal-with-hezbollah-not-first-time-israels-paid-the-price — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Jibril deal, May 1985: some 1,150 Palestinians traded for three Israeli soldiers held by the PFLP-GC
    - some 1,150 Palestinians traded for three soldiers (JTA 2004)

**[S1967]** JTA, "Backgrounder: Over the Years, Sheik Yassin Grew in Status, Violence and Radicalism", 23 Mar 2004 — https://www.jta.org/archive/backgrounder-over-the-years-sheik-yassin-grew-in-status-violence-and-radicalism — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Ahmed Yassin, sentenced in 1984, was released in the prisoner exchange with Ahmed Jibril's organisation
    - including Gaza cleric Ahmed Yassin

**[S1968]** JTA Daily Bulletin, "'Operation Peace for Galilee' Ends on Third Anniversary Without Any Announcement, Security Belt Remains", 7 June 1985 — https://www.jta.org/archive/operation-peace-for-galilee-ends-on-third-anniversary-without-any-announcement-security-belt-rema — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the war ended on the third anniversary (June 1985); it cost 654 soldiers and other security personnel dead and nearly 6,000 wounded
    - security belt held by the SLA with IDF liaison officers
    - date: the war ended on the third anniversary in June 1985 without an announcement
    - Israel had lost 654 soldiers and security personnel in Lebanon since June 1982

**[S1969]** JTA Daily Bulletin, "Late News Development: Cabinet Approves IDF Withdrawal", 15 Jan 1985 — https://www.jta.org/archive/late-news-development-cabinet-approves-idf-withdrawal — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the cabinet voted 16-6 to approve a three-stage withdrawal from south Lebanon
    - on 14 January 1985 the cabinet voted 16-6 for a three-stage withdrawal

**[S1970]** JTA Daily Bulletin, "Cabinet Votes to Get IDF out of Lebanon by Beginning of June", 22 Apr 1985 — https://www.jta.org/archive/cabinet-votes-to-get-idf-out-of-lebanon-by-beginning-of-june — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the three-stage withdrawal plan was approved by the cabinet on 14 January 1985
    - the plan was approved on 14 January 1985

**[S1971]** JTA Daily Bulletin, "Cabinet Approves FTA Accord with U.S.", 19 Aug 1985 — https://www.jta.org/archive/cabinet-approves-fta-accord-with-u-s — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the FTA was signed in April 1985 by Industry Minister Ariel Sharon and US Trade Representative William Brock
    - date April 1985: signed by Sharon and US Trade Representative Brock

**[S1972]** JTA Daily Bulletin, "Israeli Official Assesses Impact of Free Trade Accord with U.S.", 9 Aug 1985 — https://www.jta.org/archive/israeli-official-assesses-impact-of-free-trade-accord-with-u-s — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - FTA scheduled to take effect 1 September 1985
    - goal: all trade duty-free by 1995; duties phased down, duty-free by 1989 or 1995
    - duties phased down, with all trade to be duty-free by 1995
    - phase-down of duties to duty-free by 1989 or 1995

**[S1973]** JTA Daily Bulletin, "Israeli Official Sees Economic Prospects Improving for Rest of 1985", Aug 1985 — https://www.jta.org/archive/israeli-official-sees-economic-prospects-improving-for-rest-of-1985 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - in July 1985 the government printed no new money and absorbed about $170 million from the public
    - price-wage linkage eliminated
    - in July 1985 the government printed no new money

**[S1974]** JTA Daily Bulletin, "Shekel to Undergo Technical Change", 26 Aug 1985 — https://www.jta.org/archive/shekel-to-undergo-technical-change — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - cabinet approved removing three zeros from the shekel; new notes and coins into circulation that Wednesday; old and new valid until 1 January
    - date August 1985: cabinet approved removing three zeros; new notes and coins into circulation that week; both valid until 1 January
    - Modai called the change purely technical

**[S1975]** UN Security Council, S/17509: Letter dated 1 October 1985 from the Permanent Representative of Tunisia to the President of the Security Council — https://documents.un.org/api/symbol/access?s=S/17509&l=en&t=pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - toll more than 50 dead and nearly 100 wounded (Tunisia, 1 Oct 1985)
    - Tunisia (1 Oct): more than 50 dead and nearly 100 wounded

**[S1976]** UN Security Council, S/PV.2610: provisional verbatim record of the 2610th meeting, 2 October 1985 — https://documents.un.org/api/symbol/access?s=S/PV.2610&l=en&t=pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Tunisian FM Caid Essebsi: initial estimates more than 60 dead and more than 100 injured; residential area home of Tunisian families and Palestinian civilians
    - Tunisian FM at the Security Council: more than 60 dead and more than 100 injured
    - Tunisia: the area was residential, home to Tunisian families and Palestinian civilians

**[S1977]** JTA Daily Bulletin, "Israel, Egypt in Transport Pact", 3 Apr 1980 — https://www.jta.org/archive/israel-egypt-in-transport-pact — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - an Israel-Egypt air-transportation agreement went into effect in March 1980
    - an air-transport agreement took effect in March 1980

**[S1978]** JTA, "News Analysis: Warming Signals from Syria Elicit Hot Demonstrations from the Golan" (Rabin era, 1990s) — https://www.jta.org/archive/news-analysis-warming-signals-from-syria-elicit-hot-demonstrations-from-the-golan — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Katzrin described as the so-called capital of the Golan Heights
    - Katzrin became the so-called capital of the Golan Heights

**[S1979]** JTA Daily Bulletin, "Rabin Postponed Announcement to Avoid Pre-empting Basketball Game in Europe Where Israel Won", 11 Apr 1977 — https://www.jta.org/archive/rabin-postponed-announcement-to-avoid-pre-empting-basketball-game-in-europe-where-israel-won — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Maccabi Tel Aviv beat Varese 78-77 in the European Cup championship game in Belgrade on Thursday night (7 April 1977)
    - date 1977-04-07 (Thursday night): Maccabi beat Varese 78-77 in the European Cup championship game in Belgrade

**[S1980]** JTA Daily Bulletin, "Israel Wins Eurovision Song Contest", 2 Apr 1979 — https://www.jta.org/archive/israel-wins-eurovision-song-contest — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 'Hallelujah' sung by Gali Atari accompanied by Milk and Honey
    - Milk and Honey with Gali Atari

**[S1981]** JTA Daily Bulletin, "Father of Missing Dimona Nuclear Facility Technician Disowns His Son", 4 Nov 1986 — https://www.jta.org/archive/father-of-missing-dimona-nuclear-facility-technician-disowns-his-son — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Vanunu told British newspapers that Israel has a substantial nuclear arsenal; reported missing in London on 1 October 1986
    - he told British newspapers Israel had a substantial nuclear arsenal

**[S2000]** RETIRED (no longer cited) — Hebrew Wikipedia, 'הוד השרון' (Hod HaSharon), accessed 2026-10-11 — https://he.wikipedia.org/wiki/%D7%94%D7%95%D7%93_%D7%94%D7%A9%D7%A8%D7%95%D7%9F

**[S2001]** RETIRED (no longer cited) — Hebrew Wikipedia, 'מעלות-תרשיחא' (Ma'alot-Tarshiha), accessed 2026-10-11 — https://he.wikipedia.org/wiki/%D7%9E%D7%A2%D7%9C%D7%95%D7%AA-%D7%AA%D7%A8%D7%A9%D7%99%D7%97%D7%90

**[S2002]** RETIRED (no longer cited) — Hebrew Wikipedia, 'מודיעין-מכבים-רעות' (Modi'in-Maccabim-Re'ut), accessed 2026-10-11 — https://he.wikipedia.org/wiki/%D7%9E%D7%95%D7%93%D7%99%D7%A2%D7%99%D7%9F-%D7%9E%D7%9B%D7%91%D7%99%D7%9D-%D7%A8%D7%A2%D7%95%D7%AA

**[S2003]** RETIRED (no longer cited) — Hebrew Wikipedia, 'רהט' (Rahat), accessed 2026-10-11 — https://he.wikipedia.org/wiki/%D7%A8%D7%94%D7%98

**[S2004]** RETIRED (no longer cited) — Hebrew Wikipedia, 'תל שבע' (Tel Sheva), accessed 2026-10-11 — https://he.wikipedia.org/wiki/%D7%AA%D7%9C_%D7%A9%D7%91%D7%A2

**[S2005]** RETIRED (no longer cited) — Hebrew Wikipedia, 'חורה' (Hura), accessed 2026-10-11 — https://he.wikipedia.org/wiki/%D7%97%D7%95%D7%A8%D7%94

**[S2006]** RETIRED (no longer cited) — Hebrew Wikipedia, 'טירת כרמל' (Tirat Carmel), accessed 2026-10-11 — https://he.wikipedia.org/wiki/%D7%98%D7%99%D7%A8%D7%AA_%D7%9B%D7%A8%D7%9E%D7%9C

**[S2007]** Encyclopaedia Judaica via Jewish Virtual Library, 'Yavneh' — https://www.jewishvirtuallibrary.org/yavneh — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Haganah forces occupied Yibna in May 1948; from the end of 1948 Jewish immigrants were housed in the abandoned village
    - Jewish immigrants housed in abandoned Yibna from the end of 1948
    - Yavneh: Haganah occupied Yibna in May 1948; from the end of 1948 Jewish immigrants were housed there

**[S2050]** Jewish Virtual Library, 'The War of Independence: Operation Dekel (July 9-18, 1948)' — https://www.jewishvirtuallibrary.org/operation-dekel-july-1948 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Shefa-'Amr attacked and taken 14 July 1948
    - Nazareth surrendered on the eve of 16 July 1948
    - Shefa-'Amr attacked and taken on 14 July 1948

**[S2051]** Institute for Palestine Studies, PalQuest, 'Operation Dekel' (8-18 July 1948) — https://www.palquest.org/node/25285 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Operation Dekel ran 8-18 July 1948 in Lower and western Galilee
    - Operation Dekel began on the night of 8 July 1948 (ended 18 July)

**[S2052]** Mustafa Abbasi, 'The Fall of Acre in the 1948 Palestine War', Journal of Palestine Studies (abstract page) — https://digitalprojects.palestine-studies.org/jps/abstract/42335 — archived: https://web.archive.org/web/2026/https://digitalprojects.palestine-studies.org/jps/abstract/42335 — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Acre fell to Haganah forces on 17 May 1948

**[S2053]** Zochrot, 'al-Majdal (Gaza)' village page — https://www.zochrot.org/villages/village_details/49283/en — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - al-Majdal occupation date 4 November 1948; remaining residents deported to Gaza by June 1950
    - al-Majdal occupation date 4 November 1948
    - Majdal occupied in early November 1948; remaining residents deported to Gaza by June 1950

**[S2060]** Maher Charif, 'The Nakba' (highlight), Interactive Encyclopedia of the Palestine Question (PalQuest), Institute for Palestine Studies — https://www.palquest.org/en/highlight/160/nakba — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Tiberias fell 18 April 1948; attacks on Haifa from 21 April; Safad emptied by early May; Baysan occupied 12 May; Acre 16 May (IPS dating)
    - only al-Faradis and Jisr al-Zarqa remained of the coastal villages between Tel Aviv and Haifa
    - Haganah offensive on Haifa from 21 April 1948 (before statehood)
    - Tiberias fell on 18 April 1948 (before statehood)
    - Safed taken between mid-April and early May 1948 (before statehood)
    - Baysan occupied on 12 May
    - IPS dates the fall of Acre to 16 May
    - Haganah offensive on Haifa from 21 April 1948; PalQuest/IPS (Palestinian) account of the exodus

**[S2061]** Encyclopaedia Britannica, 'Acre' (Israel), britannica.com (Wayback Machine copy) — https://web.archive.org/web/2024/https://www.britannica.com/place/Acre-Israel — archived: https://web.archive.org/web/2024/https://www.britannica.com/place/Acre-Israel — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Acre was occupied by regular Israeli troops on 17 May 1948; about 3,000 Arab inhabitants remained
    - Acre was held by Arab forces until occupied by regular Israeli troops on 17 May 1948
    - date: 17 May 1948; about 3,000 Arabs remained

**[S2062]** Encyclopaedia Britannica, 'Lod', britannica.com (Wayback Machine copy) — https://web.archive.org/web/2024/https://www.britannica.com/place/Lod — archived: https://web.archive.org/web/2024/https://www.britannica.com/place/Lod — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Lod was occupied by the invading Arab Legion of Jordan
    - the IDF captured the city on 12 July 1948
    - Lod was held with Transjordan's Arab Legion

**[S2063]** Encyclopaedia Britannica, 'Ramla', britannica.com (Wayback Machine copy) — https://web.archive.org/web/2024/https://www.britannica.com/place/Ramla — archived: https://web.archive.org/web/2024/https://www.britannica.com/place/Ramla — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Ramla and its environs were invaded by Transjordan's Arab Legion
    - the Israelis took the city on 12 July 1948
    - Ramla was held with Transjordan's Arab Legion
    - date: the Israelis took the city on 12 July 1948

**[S2064]** Encyclopaedia Britannica, 'Bet She'an', britannica.com (Wayback Machine copy) — https://web.archive.org/web/2024/https://www.britannica.com/place/Bet-Shean — archived: https://web.archive.org/web/2024/https://www.britannica.com/place/Bet-Shean — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - taken by the Haganah on 12 May 1948, three days before the proclamation of statehood
    - taken by the Haganah on 12 May 1948, three days before statehood

**[S2065]** Jewish Telegraphic Agency, 'Report Israelis in Nazareth; Jewish Villages Shelled in South; Egyptians Lose 500 Men', Daily Bulletin, 16 July 1948 — https://www.jta.org/archive/report-israelis-in-nazareth-jewish-villages-shelled-in-south-egyptians-lose-500-men — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Israeli forces entered the outskirts of Nazareth
    - Shafa Amr already captured; Iblin taken
    - Israeli forces reached the outskirts of Nazareth (JTA bulletin of 16 July 1948)
    - Shafa Amr already in Israeli hands when the push on Nazareth began (JTA bulletin of 16 July 1948)

**[S2066]** Jewish Telegraphic Agency, 'Israeli Troops Capture Nazareth As Guerrilla Units Flee; Tel Aviv Bombed Again', Daily Bulletin, 18 July 1948 — https://www.jta.org/archive/israeli-troops-capture-nazareth-as-guerrilla-units-flee-tel-aviv-bombed-again — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - capture of Nazareth officially announced; the city had been a major base of Qawuqji's Liberation Army
    - Nazareth was a major base of Qawuqji's Arab Liberation Army

**[S2067]** Jewish Telegraphic Agency, 'Egyptians Retreat from Majdal Area; Entire Coastal Strip North of Gaza in Israeli Hand', Daily Bulletin, 7 November 1948 — https://www.jta.org/archive/egyptians-retreat-from-majdal-area-entire-coastal-strip-north-of-gaza-in-israeli-hand — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Egyptian troops withdrew from the Majdal pocket; Israeli forces marched into the Majdal area
    - Egyptian troops withdrew from the Majdal pocket
    - Israeli forces entered al-Majdal

**[S2068]** FRUS 1948 vol. V part 2, doc. 736: The Special Representative of the United States in Israel (McDonald) to the Acting Secretary of State, 5 November 1948 — https://history.state.gov/historicaldocuments/frus1948v05p2/d736 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Egyptians voluntarily withdrew from Isdud and Majdal (reported 5 Nov 1948)
    - Egyptian withdrawal from Majdal reported on 5 November 1948

**[S2069]** Jewish Telegraphic Agency, 'Ramleh Surrenders to Jews; Israeli Forces Fan out in Major Drive in Central Palestine', Daily Bulletin, 13 July 1948 — https://www.jta.org/archive/ramleh-surrenders-to-jews-israeli-forces-fan-out-in-major-drive-in-central-palestine — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Ramleh surrendered to Israeli forces
    - Arab Legion and other troops held the Lydda-Ramleh pocket
    - Tulkarm and Jenin anchored the Iraqi-held 'triangle'
    - Arab Legion and other troops in the Lydda-Ramleh pocket (July 1948)
    - Ramleh surrendered (JTA bulletin of 13 July 1948)

**[S2070]** Jewish Telegraphic Agency, 'U.N. Cease-fire in Effect on Palestine's Northern Front, Kaukaji's Forces Smashed', Daily Bulletin, 1 November 1948 — https://www.jta.org/archive/u-n-cease-fire-in-effect-on-palestines-northern-front-kaukajis-forces-smashed — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - cease-fire on the northern Galilee front after Qawuqji's forces were beaten (end of October 1948)
    - Qawuqji's forces beaten; cease-fire on the northern front (JTA bulletin of 1 November 1948)

**[S2071]** Jewish Telegraphic Agency, 'Security Council Gets Report from Mediator Reviewing Fighting in North Palestine Area', Daily Bulletin, 8 November 1948 — https://www.jta.org/archive/security-council-gets-report-from-mediator-reviewing-fighting-in-north-palestine-area — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Bunche report: Israeli forces occupied the area in Galilee formerly controlled by Qawuqji's forces (events 21 Oct - 1 Nov 1948)
    - the Galilee pocket was held by Qawuqji's forces until Israeli forces occupied it (Bunche report on 21 Oct - 1 Nov 1948)

**[S2072]** Jewish Telegraphic Agency, 'Over 100 Egyptians Killed in Enemy Attack in Negev; U.N. Announces Israeli-Iraqi Pact', Daily Bulletin, 9 December 1948 — https://www.jta.org/archive/over-100-egyptians-killed-in-enemy-attack-in-negev-u-n-announces-israeli-iraqi-pact — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - cease-fire with Iraqi units covering the entire Iraqi front from Ras el Ain to Beisan
    - the Triangle front was held by Iraqi forces in 1948
    - Israel-Iraq agreement covers the entire Iraqi front, from Ras el Ain to Beisan (JTA)

**[S2073]** FRUS 1948 vol. V part 2, doc. 486: Report by the Central Intelligence Agency, 27 July 1948 — https://history.state.gov/historicaldocuments/frus1948v05p2/d486 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - between the truces (9-18 July 1948) Israeli forces captured Lydda and Ramle and took Nazareth
    - Lydda and Ramle captured between the truces
    - Israeli forces took Nazareth between the truces (9-18 July)

**[S2074]** Zochrot, al-Ruways (village page, Nakba Map; background text after W. Khalidi (ed.), All That Remains, 1992), zochrot.org — https://www.zochrot.org/villages/village_details/49476/en — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Nazareth occupied 16 July 1948; Seventh Brigade then took Acre-district villages and moved towards Sakhnin
    - date: Nazareth occupied on 16 July 1948

**[S2075]** Zochrot, al-Mujaydil (village page, Nakba Map; background text after W. Khalidi (ed.), All That Remains, 1992), zochrot.org — https://www.zochrot.org/villages/village_details/49285/en — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - the assault on Nazareth (14-16 July 1948) was launched from the previously occupied town of Shafa 'Amr
    - the assault on Nazareth came from the previously occupied town of Shafa 'Amr

**[S2076]** Institute for Palestine Studies, PalQuest, 'Operation Hiram' (28-31 October 1948) — https://www.palquest.org/node/25291 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Operation Hiram 28-31 October 1948 against the last Arab-held pocket in Galilee
    - Operation Hiram targeted the last Arab-held pocket in Galilee
    - Operation Hiram, 28-31 October 1948

**[S2077]** Institute for Palestine Studies, PalQuest, 'Operation Yoav' (15 October - 4 November 1948) — https://www.palquest.org/node/25299 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Egyptian units controlled the coastal strip as far north as Isdud
    - Egyptian units held the coastal strip as far north as Isdud

**[S2078]** Institute for Palestine Studies, PalQuest, 'IV. The Palestine War and the Nakba, 1947-1950' (highlight) — https://www.palquest.org/en/highlight/31109/iv-palestine-war-and-nakba — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Egyptian forces controlled Gaza while Jordanian and Iraqi troops held the West Bank and East Jerusalem
    - Egyptian forces held Gaza; Jordanian and Iraqi troops held the West Bank (1948 war)

**[S2079]** Jewish Telegraphic Agency, 'Israeli Cabinet Hears Report on Evacuation of Arab Troops from "Bloody Triangle"', Daily Bulletin, 8 May 1949 — https://www.jta.org/archive/israeli-cabinet-hears-re-port-on-evacuation-of-arab-troops-from-bloody-triangle — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Arab Legion began evacuating forward positions in the triangle on 8 May 1949, in stages over three days
    - the Arab Legion began evacuating its forward positions in the triangle on 8 May 1949, in stages over three days

**[S2080]** Jewish Telegraphic Agency, 'Arab Legion Troops Evacuate Another Portion of Territory Ceded to Israel by Rhodes Pact', Daily Bulletin, 10 May 1949 — https://www.jta.org/archive/arab-legion-troops-evacuate-another-portion-of-territory-ceded-to-israel-by-rhodes-pact — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - four withdrawals in the triangle completed; most villagers stayed
    - most villagers in the evacuated Triangle areas stayed

**[S2081]** Jewish Telegraphic Agency, 'Israel Highway Between Haderah and Afula Reopened Following Arab Legion Evacuation', Daily Bulletin, 22 May 1949 — https://www.jta.org/archive/israel-highway-between-haderah-and-afula-reopened-following-arab-legion-evacuation — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Arab Legion withdrew from its positions at Umm al-Fahm; Hadera-Afula road open
    - the Arab Legion withdrew from its positions at Umm al-Fahm (JTA bulletin of 22 May 1949)

**[S2082]** Jewish Telegraphic Agency, 'Arab Legion Forces Evacuate Additional Strip of Territory in Central Palestine Area', Daily Bulletin, 23 May 1949 — https://www.jta.org/archive/arab-legion-forces-evacuate-additional-strip-of-territory-in-centpal-palestine-area — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - evacuation of the strip from Umm al-Fahm to Jatt
    - evacuation of the strip from Umm al-Fahm to Jatt (JTA bulletin of 23 May 1949)

**[S2083]** Encyclopaedia Judaica via Jewish Virtual Library, 'Abu Ghosh' — https://jewishvirtuallibrary.org/abu-ghosh — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - relations between Abu Ghosh villagers and Jews remained friendly in the War of Independence; some villagers cooperated with the Haganah and Lehi
    - villagers' relations with Jews stayed friendly in the War of Independence; some cooperated with the Haganah and Lehi

**[S3000]** UN News, 'Abu Akleh shooting: fatal shot came from Israeli forces, says OHCHR', 24 June 2022 — https://news.un.org/en/story/2022/06/1121252 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date and circumstances of the killing
    - OHCHR finding
    - No Israeli criminal investigation as of 24 June 2022 (OHCHR)
    - Israeli mission's response

**[S3001]** Committee to Protect Journalists, profile page 'Shireen Abu Akleh' — https://cpj.org/data/people/shireen-abu-akleh/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Producer Ali Samoudi was wounded
    - IDF said she was probably hit accidentally by IDF fire aimed at armed gunmen

**[S3002]** JURIST, 'Israel investigation finds high possibility Palestinian-American journalist was shot by Israeli soldiers', 6 September 2022 — https://www.jurist.org/news/2022/09/israel-investigation-finds-high-possibility-palestinian-american-journalist-was-shot-by-israeli-soldiers — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - IDF conclusion of 5 September 2022
    - Family's reaction

**[S3003]** US Department of State, Country Report on Terrorism 2022, Chapter 1: Israel (ecoi.net copy) — https://www.ecoi.net/en/document/2101565.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Mirror/digest of: US Department of State (Country Reports on Terrorism 2022)
  - Supports:
    - Operation Break the Wave followed 21 Israelis killed from March to May 2022
    - Beersheba, March 2022: four killed, attacker inspired by ISIS per Israeli authorities
    - Hadera, March 2022: two Border Police officers killed, ten civilians injured
    - Bnei Brak, March 2022: five killed by a West Bank Palestinian
    - Tel Aviv, April 2022: three killed
    - Elad, May 2022: four killed, attackers from Jenin
    - Israel's stated rationale
    - State Dept: no Israeli casualties from PIJ rocket fire

**[S3004]** Associated Press via NBC News, 'Gunman kills 5 in mass shooting spree in central Israel', 29 March 2022 — https://www.nbcnews.com/news/world/gunman-kills-5-mass-shooting-spree-central-israel-rcna22102 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - The Bnei Brak shooting was the third such street attack in a week (29 March 2022)
    - Prime Minister Bennett's characterisation

**[S3005]** Washington Post via Stars and Stripes, '2022 was deadliest year for West Bank Palestinians in nearly 2 decades', 29 December 2022 — https://www.stripes.com/theaters/middle_east/2022-12-29/west-bank-palestinians-deadliest-year-8578207.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Palestinians killed by Israeli security forces in 2022 (UN figures, year total, through 19 December)
    - Year 2022 ranked deadliest since UN recording began in 2005

**[S3006]** UN OCHA oPt, 'Escalation in the Gaza Strip and Israel, Flash Update #2 as of 18:00, 8 August 2022' — https://www.ochaopt.org/content/escalation-gaza-strip-and-israel-flash-update-2-august-2022 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Start of escalation on 5 August 2022
    - Mansour killed in Rafah on 7 August
    - Ceasefire time
    - Rocket fire at Israel, with ~200 falling short (Israeli sources)
    - Jabalia explosion: Palestinian account
    - Jabalia explosion: Israeli army account
    - Israeli injuries

**[S3007]** Intelligence and Terrorism Information Center (Israel), 'Escalation in the Gaza Strip: Summary of Operation Breaking Dawn (August 5-7, 2022)' — https://www.terrorism-info.org.il/en/escalation-in-the-gaza-strip-summary-of-operation-breaking-dawn-august-5-7-2022/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Gaza health ministry figure as reported by ITIC: 44 killed, 360 wounded
    - Israeli-side claim that some deaths came from misfired rockets

**[S3008]** Boston Globe (AP), 'Israel, Gaza militants agree to cease-fire after weekend violence leaves 43 dead', 7 August 2022 — https://www.bostonglobe.com/2022/08/07/world/israel-gaza-militants-agree-cease-fire-after-weekend-violence-leaves-43-dead — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Jabari's killing started the fighting

**[S3009]** UN Information System on the Question of Palestine (UNISPAL), 11 August 2022 OHCHR statement on Gaza hostilities — https://www.un.org/unispal/?p=280245 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - OHCHR confirmed 48 killed including 17 children

**[S3025]** Israel Democracy Institute (Mirit Lavi), 'The Ultra-Orthodox Exemption from IDF Service: a short history, 1948 to today' (timeline) — https://en.idi.org.il/articles/53301 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Pre-state order not to conscript yeshiva students on approved lists
    - Ben-Gurion approved exempting 400 yeshiva students at Agudat Yisrael's request
    - 1958 arrangement with yeshiva heads
    - 1967 cap of 800 a year
    - 1977 removal of limits
    - 1998 High Court ruling on the defence minister's authority
    - First statutory regulation of deferral
    - 2006 High Court did not invalidate it
    - IDI summary of the reasoning

**[S3026]** GlobalSecurity.org, 'Haredim in the IDF' (history of yeshiva-student deferments, with 1958 Ben-Gurion correspondence) — https://www.globalsecurity.org/military/world/israel/jew-haredi-idf.htm — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Mirror/digest of: GlobalSecurity.org compilation (original outlets not identified)
  - Supports:
    - Rationale given in 1948
    - Initial quota of about 400 a year
    - Rabbi Herzog's argument to Ben-Gurion (1958)
    - Ben-Gurion's reply (1958)

**[S3027]** iCenter / Center for Israel Education, 'Knesset Enacts Tal Law', 23 July 2002 (Today in Israeli History) — https://israeled.org/knesset-enacts-tal-law/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date and vote
    - Based on the Tal Committee formed in 1999

**[S3028]** Jewish Week editorial via JTA, 'Narrowing The Religious-Secular Gap', 28 February 2012 — https://www.jta.org/?p=1799767 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Only about 400 such students; Ben-Gurion expected the number to shrink
    - Number of exempted yeshiva students in 2012

**[S3029]** Times of Israel (Ilan Ben Zion), 'High Court rules law on ultra-Orthodox army deferrals unconstitutional', 21 February 2012 (Wayback copy) — https://web.archive.org/web/2012/https://www.timesofisrael.com/supreme-court-tal-law-unconstitutional/ — archived: https://web.archive.org/web/2012/https://www.timesofisrael.com/supreme-court-tal-law-unconstitutional/ — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date of the ruling
    - Struck down by a 6-3 vote; could not be renewed
    - Majority reasoning
    - Deferral acted as an exemption

**[S3030]** JTA (Philissa Cramer), 'In landmark ruling, Israel's top court rules that haredi Orthodox Jews must serve in the army', 25 June 2024 — https://www.jta.org/2024/06/25/israel/in-landmark-ruling-israels-top-court-rules-that-haredi-orthodox-jews-must-serve-in-the-army — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Haredi leaders' position (as reported by JTA in 2024)
    - Unanimous ruling announced Tuesday, 25 June 2024
    - Date of the JTA report
    - Draft and yeshiva funding
    - Background: expired exemption law
    - Petitioner's statement
    - Haredi leaders' position
    - Gafni's reaction
    - Coalition haredi parties opposed
    - Gradual conscription language

**[S3031]** Jerusalem Center for Public Affairs, 'The creation of the Western Wall plaza in 1967 was necessary and legal' — https://jcpa.org/article/creation-western-wall-plaza-1967-necessary-legal — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date and number evicted (JCPA)
    - Order to demolish (JCPA)
    - JCPA's legal and public-safety argument
    - Shavuot pilgrimage as the stated need (JCPA)
    - JCPA on compensation
    - The 2017 articles' characterisation as a war crime (as described by JCPA)

**[S3032]** MERIP (Joost Hiltermann), 'Teddy Kollek and the Native Question', 26 May 1993 — https://merip.org/1993/05/teddy-kollek-and-the-native-question/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Three-hour notice to more than 100 families (MERIP)
    - Kollek's own account (1978 autobiography, quoted by MERIP)
    - Kollek's own account, continued

**[S3033]** Israel Hayom, 'The secret of the disappearing Wall', 6 March 2016 — https://www.israelhayom.co.il/article/386561 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Work completed overnight; 108 families removed (Israel Hayom)

**[S3034]** AFP via Aaj News, 'Book sheds light on Israel role in destruction of Jerusalem Mughrabi quarter' (on Vincent Lemire's book) — https://english.aaj.tv/news/30277180/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Lemire: minutes of a 9 June meeting
    - Lemire's claim of premeditation

**[S3035]** Israel National News, article on the fall of the Jewish Quarter, 28 May 1948 — https://www.israelnationalnews.com/news/123053 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date the Quarter fell
    - Residents gathered and surrender papers signed
    - Evacuees and prisoners
    - Fighting in the Old City of Jerusalem from 14 May 1948
    - Intense fighting in the Old City began on 14 May 1948; Israeli forces failed to take it
    - Jewish Quarter fell to Jordan's Arab Legion on 28 May 1948
    - Surrender papers signed, giving Jerusalem over to Jordanian control

**[S3036]** US Department of State, Foreign Relations of the United States 1948 vol. V part 2, doc. 345 (Vice Consul Burdett, Jerusalem, to the Secretary of State, 29 May 1948) — https://history.state.gov/historicaldocuments/frus1948v05p2/d345 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Time of the unconditional surrender
    - Surrender terms as telegraphed on 29 May
    - UN observer's view of the evacuation
    - Jewish Agency official's complaint

**[S3037]** Jewish Virtual Library, 'Latrun Fort' — https://www.jewishvirtuallibrary.org/latrun-fort — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Arab Legion took the fort and used it against traffic
    - First assault, 24-25 May, failed
    - Second assault, 1 June, failed
    - Official casualty figure for both battles
    - Burma Road first used 1 June

**[S3038]** iCenter / Center for Israel Education, 'First Battle for Latrun Takes Place' — https://israeled.org/?p=4982 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Arab Legion took control on 14 May 1948
    - Siege of the roughly 100,000 Jews of Jerusalem
    - Ben-Gurion's view of Latrun
    - About 75 killed in the first attack
    - Many of the dead were recent immigrants
    - Later attacks also failed; Latrun taken in 1967

**[S3039]** Jewish Press, "Israel's Burma Road" — https://jewishpress.com/israels-burma-road/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Burma Road upgraded by 10 June

**[S3040]** Jewish Virtual Library, 'The Protocol of Lausanne (May 12, 1949)' — https://www.jewishvirtuallibrary.org/the-protocol-of-lausanne — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Separate identical Protocols signed on 12 May 1949
    - Working document was the partition map
    - Arab interpretation
    - Israeli interpretation

**[S3041]** UN Conciliation Commission for Palestine, Third Progress Report (UNISPAL copy) — https://www.un.org/unispal/?p=176855 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - First Lausanne meeting, 27 April 1949
    - Arab delegations' position on repatriation
    - Israel's proposal on Gaza
    - Israel declined to give numbers otherwise
    - Arab proposal for immediate return

**[S3042]** UNCCP 39th meeting, summary record of meeting with the Israeli delegation, Lausanne, 12 September 1949 (UNISPAL copy) — https://www.un.org/unispal/?p=211501 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - 12 September 1949: last meeting before adjournment
    - UNISPAL summary of the 12 September record

**[S3043]** NPR (Eyder Peralta), 'Arson attack that killed toddler in West Bank is called terrorism', 31 July 2015 — https://www.npr.org/sections/thetwo-way/2015/07/31/428082639/arson-attack-that-killed-toddler-in-west-bank-is-called-terrorism — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date and time of the attack (NPR, 31 July 2015)
    - NPR dateline
    - Casualties reported at the time
    - Graffiti
    - Netanyahu's characterisation
    - PLO's attribution of responsibility

**[S3044]** Reuters via Algemeiner, 'Israeli settler sentenced to life in jail for deadly 2015 Duma arson attack', 14 September 2020 — https://www.algemeiner.com/2020/09/14/israeli-settler-sentenced-to-life-in-jail-for-deadly-2015-duma-arson-attack/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Three members of the family died
    - Surviving child
    - Court finding on graffiti and the second dwelling
    - Sentence
    - Shin Bet's characterisation

**[S3045]** Al Jazeera, 'Jewish settler convicted in arson attack that killed Palestinians', 18 May 2020 — https://www.aljazeera.com/news/2020/05/jewish-settler-convicted-arson-killed-palestinian-200518075142356.html — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Conviction in May 2020
    - Second defendant's plea deal
    - Defendant's position

**[S3046]** Al Jazeera, 'Man goes on stabbing spree at Jerusalem gay parade', 30 July 2015 — https://www.aljazeera.com/news/2015/7/30/man-goes-on-stabbing-spree-at-jerusalem-gay-parade — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Emergency service report of injuries
    - Attacker's earlier conviction and arrest at the scene

**[S3047]** Christian Science Monitor (AP/Reuters), 'Six hurt in stabbing at gay pride parade in Jerusalem', 30 July 2015 — https://csmonitor.com/World/Global-News/2015/0730/Six-hurt-in-stabbing-at-gay-pride-parade-in-Jerusalem — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Date and number stabbed
    - Released three weeks earlier

**[S3048]** CBC News, 'Jerusalem pride stabbing: victim Shira Banki, 16, dies of her injuries', 2 August 2015 — https://www.cbc.ca/lite/story/1.3177420 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Shira Banki died on Sunday
    - Banki's age and hospital

**[S3049]** JTA report on the murder conviction of Yishai Schlissel for the Jerusalem Pride stabbing (2016; refers to 'the parade last July') — https://jta.org/?p=1178360 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Conviction (JTA)
    - Schlissel refused counsel and rejected the court

**[S3050]** JTA (Marcy Oster) via St. Louis Jewish Light, 'Jerusalem gay pride parade stabber sentenced to life in prison', 26 June 2016 — https://stljewishlight.org/world-news/jerusalem-gay-pride-parade-stabber-sentenced-to-life-in-prison — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Life sentence

**[S4002]** yplus.ps, 'Benny Morris, 'The Birth of the Palestinian Refugee Problem Revisited', Cambridge University Press, 2004 (full text opened as a PDF copy; page numbers are those of the printed edition)' — https://yplus.ps/wp-content/uploads/2021/01/Morris-Benny-The-Birth-of-the-Palestinian-Refugee-Problem-Revisited.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Lydda was a town of Arab inhabitants in July 1948 (population of Lydda and Ramle)
    - Lydda and Ramle: Ben-Gurion wanted them 'destroyed'; Arab Legion troops present in July 1948
    - Population of Lydda and Ramle together in July 1948 (Morris's estimate)
    - Operation Dani HQ order (12 July 1948) to expel the inhabitants of Lydda; a similar order for Ramle
    - In Lydda the expulsion order was not immediately implemented on 12 July 1948
    - A Palmah report cited about 45,000 displaced from Ramle and Lydda
    - About 2,000 Arabs back in Lydda and Ramle by mid-October 1948; towns resettled with immigrants
    - Ramle was a town in July 1948
    - Thousands of Ramle's inhabitants left on 12 July 1948
    - Acre was a populated Arab town in 1948
    - Acre swollen by refugees from Haifa; one inhabitant's letter put the population at 50,000 (26 April 1948)
    - British estimate of Acre's population by 5-7 May 1948
    - Acre fell 17-18 May 1948 (Operation Ben-Ami)
    - About 5,000 inhabitants remained after the fall of Acre, many non-local; no expulsion orders
    - Refugees about two-thirds of Acre's inhabitants; an Israeli intelligence officer recommended expelling them
    - Beisan (pop. 5,000); Allon's 22 April recommendation to conquer it and harass its population into flight
    - Beisan surrender on 12 May 1948; Israeli troops moved in next day; 1,000-1,200 inhabitants initially remained
    - Most of the remaining inhabitants apparently expelled around 15 May across the Jordan
    - Tiberias mixed town in 1948: 6,000 Jews, 4,000 Arabs
    - 18 April 1948: truce, British-escorted transport of Tiberias's Arab inhabitants to Nazareth
    - Safad: 10,000-12,000 Arabs and 1,500 Jews before the 1948 attack (Morris)
    - Safad fell 10-11 May 1948; about 100 elderly Muslims expelled to Lebanon, 34-36 Christians remained
    - Nazareth occupied 16 July 1948 by Golani and 7th brigades; ALA units fled
    - Expulsion proposed 17 July, vetoed by Ben-Gurion: the inhabitants of Nazareth were not expelled
    - Laskov appointed a military governor of Nazareth
    - Villagers who fled to Nazareth (from Shafa 'Amr, Kafr Kanna, Dabburiyya etc.) were allowed to return
    - Shafa 'Amr: 7th Brigade entered 14 July 1948 and found the town almost empty of Muslims
    - Villagers of Tamra told the IDF on 17 July 1948 they were ready to surrender
    - 7th Brigade captured Tamra and other villages in Dekel's second stage (15-18 July)
    - Tamra occupied without a fight on 19 July 1948 (Operation Dekel)
    - Golani occupied Kafr Kanna on 18 July 1948
    - Kafr Kanna (Muslim and Christian) among villages around Nazareth captured in Dekel
    - Sakhnin surrendered 20 July 1948 to an IDF patrol, then ALA troops retook it
    - Operation Hiram (from 28 October 1948) conquered the Upper Galilee pocket, whose southern edge included Deir Hanna and Sakhnin
    - Sakhnin and 'Arraba listed among villages that surrendered in Hiram; population left in place (only 'Alma expelled)
    - Many Muslims in Deir Hanna, 'Arraba, Sakhnin and Majd al Kurum stayed put and were allowed to stay
    - Deir Hanna and 'Arraba also sought to surrender in July 1948, were not occupied, and remained in Arab hands until Operation Hiram
    - Non-resisting Muslims stayed put in 'Arraba and Deir Hanna
    - Tira's remaining inhabitants forbidden by the ALA to leave (spring 1948)
    - Iraqi-held village of Tira attacked by the IDF on 2-3 January 1949

**[S4003]** kafr-qasim-massacre.akevot.org.il, 'Akevot Institute, 'The Kafr Qasim Massacre' (documentary website, English)' — https://kafr-qasim-massacre.akevot.org.il/index-en.php — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Military Government covered the entire Galilee, the Negev and (after the 1949 armistice) the Triangle until its abolition in 1966
    - Kafr Qasim lies in the Small Triangle transferred from Jordanian to Israeli rule under the April 1949 armistice
    - Kafr Qasim residents helped Arab fighters in the 1948 war
    - Military Government abolished in 1966 by Prime Minister Eshkol (Kafr Qasim documentary site)
    - Central Region military governor visiting Umm al-Faham in 1955

**[S4004]** israelnationalnews.com, 'Israel National News, article on Ahmad Abu Ghaush (Abu Ghosh), 2016' — https://www.israelnationalnews.com/news/216746 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Abu Ghosh residents received eviction notices after 1948, but most were allowed to resettle by 1950 after public protest

**[S4005]** 972mag.com, 'Samah Salaime, 'No, there is nothing Israeli about Jordan's gold medal olympian', +972 Magazine, 24 August 2016 (opinion)' — https://www.972mag.com/no-there-is-nothing-israeli-about-jordans-gold-medal-olympian/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - A large number of Abu Ghosh families became refugees in 1948 and lived in Jordan (opinion piece by Samah Salaime)

**[S4006]** encyclopedia.com, 'Encyclopaedia Judaica (2nd ed.), 'Tel Aviv-Jaffa', via encyclopedia.com' — https://www.encyclopedia.com/religion/encyclopedias-almanacs-transcripts-and-maps/tel-aviv-jaffa — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Tel Aviv founded 1909; 11 April 1909 regarded as founding day
    - Jaffa capitulated in the Tel Aviv Haganah headquarters on 13 May 1948; the Arab inhabitants fled (EJ)
    - Per EJ about 4,000 of Jaffa's 100,000 Arab inhabitants remained in summer 1948
    - About 4,000 of Jaffa's 100,000 Arab inhabitants remained in summer 1948 (EJ)
    - Capitulation signed 13 May 1948 (EJ, Tel Aviv-Jaffa entry)

**[S4007]** avalon.law.yale.edu, 'Avalon Project, Declaration of the Establishment of the State of Israel, 14 May 1948' — https://avalon.law.yale.edu/20th_century/israel.asp — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Declaration of the State issued at Tel Aviv, 14 May 1948

**[S4008]** palquest.palestine-studies.org, 'Institute for Palestine Studies, PalQuest, 'Qastina' (after Khalidi, All That Remains)' — https://palquest.palestine-studies.org/en/place/17115/qastina — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Avigdor founded 1950 and Qiryat Mal'akhi 1951, both on lands of the depopulated village of Qastina (Palestine Studies)
    - Qastina occupied about 9 July 1948 by the Giv'ati Brigade

**[S4009]** jewishvirtuallibrary.org, 'Rishon Le-Zion' — https://www.jewishvirtuallibrary.org/rishon-le-zion — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Founded 1882 by ten pioneers from Russia
    - Rishon le-Zion had 10,500 inhabitants by 1948

**[S4010]** RETIRED (no longer cited) — jewishvirtuallibrary.org, 'Geography of Israel: Petah Tikvah' — https://www.jewishvirtuallibrary.org/petah-tikvah

**[S4011]** encyclopedia.com, 'Peta? Tikvah | Encyclopedia.com' — https://www.encyclopedia.com/religion/encyclopedias-almanacs-transcripts-and-maps/petah-tikvah — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Petah Tikvah's expansion after 1948 (existing city)

**[S4012]** encyclopedia.com, 'Netanyah | Encyclopedia.com' — https://www.encyclopedia.com/religion/encyclopedias-almanacs-transcripts-and-maps/netanyah — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Founded 1929 as a moshavah
    - Netanyah had 8,500 inhabitants in 1948

**[S4013]** jewishvirtuallibrary.org, 'Geography of Israel: Bnei Brak' — https://www.jewishvirtuallibrary.org/bnei-brak — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Founded 13 June 1924
    - Bnei Brak achieved city status in 1950

**[S4014]** encyclopedia.com, 'Bene-Berak | Encyclopedia.com' — https://www.encyclopedia.com/religion/encyclopedias-almanacs-transcripts-and-maps/bene-berak — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Bene-Berak had 8,800 inhabitants in 1948; local council 1936-49, township from 1950

**[S4015]** encyclopedia.com, '?olon | Encyclopedia.com' — https://www.encyclopedia.com/religion/encyclopedias-almanacs-transcripts-and-maps/holon-0 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - EJ: area of Holon first settled in 1925
    - EJ: Holon was isolated early in the 1948 war; link to Tel Aviv opened with the fall of Jaffa; population 7,000 by 1948

**[S4016]** jewishvirtuallibrary.org, 'Geography of Israel: Ramat Gan' — https://www.jewishvirtuallibrary.org/ramat-gan — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Established 1921-1923 as Ir Ganim
    - Ramat Gan population 12,000 in 1946; city status 1950

**[S4017]** encyclopedia.com, 'Ramat Gan | Encyclopedia.com' — https://www.encyclopedia.com/religion/encyclopedias-almanacs-transcripts-and-maps/ramat-gan — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - EJ: population 19,000 in 1948

**[S4018]** encyclopedia.com, 'Re?ovot | Encyclopedia.com' — https://www.encyclopedia.com/religion/encyclopedias-almanacs-transcripts-and-maps/rehovot — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Rehovot had 9,000 inhabitants in 1948, city status two years later

**[S4019]** jewishvirtuallibrary.org, 'Bat Yam, Israel' — https://www.jewishvirtuallibrary.org/bat-yam — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Founded 1926 by 24 religious families
    - EJ: in the 1948 war the town of about 1,000 inhabitants defended itself against Arab attacks
    - EJ: city status 1958

**[S4020]** jewishvirtuallibrary.org, 'Geography of Israel: Kfar Saba' — https://www.jewishvirtuallibrary.org/kfar-saba — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Lands sold in 1903 to farmers from Petah Tikvah
    - Kfar Saba population over 5,500 by the War of Independence

**[S4021]** encyclopedia.com, 'Herzliyyah | Encyclopedia.com' — https://www.encyclopedia.com/religion/encyclopedias-almanacs-transcripts-and-maps/herzliyyah — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - First founded as a moshavah in 1924
    - EJ: Herzliyyah population 5,300 by 1948

**[S4022]** jewishvirtuallibrary.org, 'Herzliya' — https://www.jewishvirtuallibrary.org/herzliya — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Herzliya is a resort city north of Tel Aviv, named after Herzl

**[S4023]** jewishvirtuallibrary.org, 'Geography of Israel: Hadera' — https://www.jewishvirtuallibrary.org/hadera — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Established in 1891 (CBS gives 1890)
    - Hadera had 2,002 residents in 1931

**[S4024]** jewishvirtuallibrary.org, 'Ra'anana' — https://www.jewishvirtuallibrary.org/ra-anannah — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - EJ: established 1922 as a moshavah by American Jews (CBS gives 1921)
    - Ra'anana had 3,800 inhabitants in 1947 and grew after the 1948 war

**[S4025]** encyclopedia.com, 'Hod Ha-Sharon | Encyclopedia.com' — https://www.encyclopedia.com/religion/encyclopedias-almanacs-transcripts-and-maps/hod-ha-sharon — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Magdi'el, one of the four villages that merged into Hod HaSharon, founded 1924
    - EJ: four villages absorbed newcomers after 1948; merged into Hod ha-Sharon in 1964

**[S4026]** jewishvirtuallibrary.org, 'Nahariya & Ma’alot' — https://www.jewishvirtuallibrary.org/nahariya-and-ma-alot — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Nahariya founded by German Jews in 1934 (JVL)
    - Nahariya founded by German Jews in 1934
    - Ma'alot, an immigrant town, was founded in 1957
    - Ma'alot merged with Tarshiha in 1963 to form a single municipality (before that the Arab village Tarshiha stood alone)

**[S4027]** encyclopedia.com, 'Nahariyyah | Encyclopedia.com' — https://www.encyclopedia.com/religion/encyclopedias-almanacs-transcripts-and-maps/nahariyyah — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Founded 1934 as a moshavah by immigrants from Germany
    - Nahariyyah cut off by Arab Acre during the 1948 war

**[S4028]** encyclopedia.com, 'Givatayim | Encyclopedia.com' — https://www.encyclopedia.com/religion/encyclopedias-almanacs-transcripts-and-maps/givatayim — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Founded 1922 as a workers' suburb; united with four other quarters in 1942 as Givatayim
    - Givatayim united 1942; population 7,000 in 1947

**[S4029]** encyclopedia.com, 'Kiryat Ata | Encyclopedia.com' — https://www.encyclopedia.com/religion/encyclopedias-almanacs-transcripts-and-maps/kiryat-ata — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Founded 1925 as a rural settlement
    - Kiryat Ata had 2,300 inhabitants in 1948

**[S4030]** encyclopedia.com, 'Afulah | Encyclopedia.com' — https://www.encyclopedia.com/religion/encyclopedias-almanacs-transcripts-and-maps/afulah — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Founded 1925 by the American Zion Commonwealth
    - Afulah had 2,500 inhabitants in 1948

**[S4031]** jewishvirtuallibrary.org, 'Ness Ziona' — https://www.jewishvirtuallibrary.org/nes-x1e92-iyyonah — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Founded 1883
    - EJ: until 1948 Ness Ziona was a mixed Arab-Jewish village
    - EJ: 9,500 inhabitants in 1953

**[S4032]** encyclopedia.com, 'Gederah | Encyclopedia.com' — https://www.encyclopedia.com/religion/encyclopedias-almanacs-transcripts-and-maps/gederah — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Founded 1884 by Bilu members
    - Gederah municipal council status since 1949; neighbouring Arab village abandoned since 1948

**[S4033]** encyclopedia.com, 'Rosh Ha-Ayin | Encyclopedia.com' — https://www.encyclopedia.com/religion/encyclopedias-almanacs-transcripts-and-maps/rosh-ha-ayin — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Camp converted to ma'barah in 1950; permanent settlement 1951
    - Springs occupied by Israeli forces July 1948; ma'barah 1950 for Yemenite immigrants; permanent 1951

**[S4034]** encyclopedia.com, 'Karmi'el | Encyclopedia.com' — https://www.encyclopedia.com/religion/encyclopedias-almanacs-transcripts-and-maps/karmiel — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Construction began 1963; first inhabitants 1964
    - Karmi'el had 1,740 inhabitants in 1969
    - Karmi'el intended as an urban centre for existing Arab villages and future Jewish villages

**[S4035]** encyclopedia.com, 'Kiryat Malakhi | Encyclopedia.com' — https://www.encyclopedia.com/religion/encyclopedias-almanacs-transcripts-and-maps/kiryat-malakhi — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Founded 1950 as a ma'barah (EJ); 1951 per Palestine Studies
    - EJ: Kiryat Malakhi municipal council status 1965; city 1998

**[S4036]** jewishvirtuallibrary.org, 'Migdal Ha-Emek' — https://www.jewishvirtuallibrary.org/migdal-ha-emek — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Founded 1952 to absorb inhabitants of transitory immigrant camps
    - EJ: Migdal ha-Emek founded 1952 to absorb camp inhabitants

**[S4037]** encyclopedia.com, 'Or Yehudah | Encyclopedia.com' — https://www.encyclopedia.com/religion/encyclopedias-almanacs-transcripts-and-maps/or-yehudah — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Ma'barot set up 1950 and 1951 mainly for immigrants from Iraq and Romania
    - Arab villages Saqiyya and Kafr Ana abandoned before being taken by Israeli forces in June 1948
    - Ma'barot 1950-51 for newcomers from Iraq and Romania

**[S4038]** jewishvirtuallibrary.org, 'Elad' — https://www.jewishvirtuallibrary.org/elad — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - First settlers arrived 1998
    - Elad geared to an ultra-Orthodox population; first settlers 1998

**[S4039]** documents.un.org, 'UN Secretary-General, 'Report of the Secretary-General prepared pursuant to General Assembly resolution ES-10/10' (events in Jenin and other Palestinian cities), A/ES-10/186, 30 July 2002' — https://documents.un.org/api/symbol/access?s=A/ES-10/186&l=en&t=pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - UN Secretary-General's report: Defensive Shield began 29 March 2002 in Ramallah, then Tulkarm and Qalqilya on 1 April, Bethlehem on 2 April, Jenin and Nablus on 3 April 2002

**[S4040]** explaininghistory.org, 'Explaining History, 'Arab States and the 1948 War: Causes and Consequences', 17 November 2025' — https://explaininghistory.org/2025/11/17/arab-states-and-the-1948-war-motives-campaigns-and-consequences/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Iraqi forces moved into the Jenin-Tulkarm-Nablus triangle in 1948
    - Explaining History: by October 1948 the Arab Legion controlled Bethlehem, Hebron and other West Bank areas (sources differ on Nablus and Jenin, where Iraqi forces were deployed)

**[S4041]** jaf.mil.jo, 'Jordan Armed Forces General Command, 'The War of 1948' (official Jordanian account), jaf.mil.jo' — https://www.jaf.mil.jo/ContentstemplateC/war_of_1948.aspx — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Jordan Armed Forces account: on 1 June 1948 the Iraqi forces were on the line Jenin-Qalqilya-Tulkarm
    - Jordan Armed Forces account: Arab Legion took over the defence of Hebron from Egyptian forces on 22 October 1948

**[S4042]** un.org, 'UN Division for Palestinian Rights, 'Chronological Review of Events relating to the Question of Palestine, September 2005'' — https://www.un.org/unispal/document/auto-insert-196496/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - UN chronology (September 2005): Hamas parade in Gaza City celebrating the Israeli withdrawal from the Gaza Strip
    - UN chronology (September 2005): protesters marched through Khan Yunis towards the evacuated Gush Katif settlements
    - UN chronology (September 2005): PA security services investigated a blast at a Hamas parade in Jabalia

**[S4043]** un.org, 'UN OCHA, 'Gaza disengagement - Situation report (12 September 2005)'' — https://www.un.org/unispal/document/auto-insert-203265/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - OCHA situation report, 12 September 2005: Rafah terminal closed after disengagement

**[S4044]** unispal.un.org, 'UN OCHA, 'Special Focus: The Gaza Strip after disengagement', Humanitarian Update, December 2005' — https://unispal.un.org/pdfs/HU11_1205.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - OCHA (Dec 2005): after Israel's disengagement Palestinian sea access improved; Deir al Balah is one of four fishing wharves

**[S4045]** un.org, 'UN OCHA, 'Gaza disengagement - Situation report (19-21 August 2005)'' — https://www.un.org/unispal/document/auto-insert-207840/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - OCHA disengagement situation report (19-21 August 2005): Neve Dekalim evacuated on Thursday 18 August 2005

**[S4046]** researchbriefings.files.parliament.uk, 'House of Commons Library, 'Hamas and the seizure of Gaza', Research Paper 07/60, 6 July 2007' — https://researchbriefings.files.parliament.uk/documents/RP07-60/RP07-60.pdf — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - House of Commons Library: on 14 June 2007 Hamas seized Fatah security headquarters and the presidential compound in Gaza City and gained control of Rafah

**[S4047]** nbcnews.com, 'Associated Press via NBC News, 'Hamas seizes Fatah headquarters in Gaza', 11 June 2007' — https://www.nbcnews.com/id/wbna19168118 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - AP (11 June 2007): Hamas gunmen exchanged fire with Fatah forces at the security headquarters in Khan Younis during the takeover

**[S4048]** hrw.org, 'Human Rights Watch, 'Internal Fight: Palestinian Abuses in Gaza and the West Bank', 29 July 2008' — https://www.hrw.org/report/2008/07/29/internal-fight/palestinian-abuses-gaza-and-west-bank — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Human Rights Watch (2008): a witness describes the Hamas-run police in Deir al-Balah as 'the de facto power'
    - HRW lists a Jabaliyya resident among those treated for beatings after a November 2007 demonstration; HRW says Hamas security forces then arrested scores of Fatah members

**[S4049]** jewishvirtuallibrary.org, 'Bethlehem' — https://www.jewishvirtuallibrary.org/bethlehem — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Jewish Virtual Library (Encyclopaedia Judaica text): since December 1995 the PA is responsible for civil affairs and security in Bethlehem

**[S4050]** jewishvirtuallibrary.org, 'Jenin' — https://www.jewishvirtuallibrary.org/jenin — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Encyclopaedia Judaica (JVL): in 1967 Jenin was a forward Jordanian position, i.e. under Jordanian control before the war
    - Encyclopaedia Judaica (JVL): Jenin fell to Israeli columns on 6 June 1967

**[S4051]** encyclopedia.com, 'Nablus | Encyclopedia.com' — https://www.encyclopedia.com/places/asia/west-bank-and-gaza-political-geography/nablus — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Nablus under the Jordanian regime 1948-67
    - Encyclopaedia Judaica (via Encyclopedia.com): Nablus taken by an Israeli column on 7 June 1967
    - Encyclopaedia Judaica: Israeli troops withdrew from Nablus after the 1995 Oslo II agreement

**[S4052]** encyclopedia.com, 'Ramallah | Encyclopedia.com' — https://www.encyclopedia.com/places/asia/west-bank-and-gaza-political-geography/ramallah — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Encyclopedia.com: Jordan annexed the West Bank in 1950 and Ramallah became part of the Jerusalem governorate
    - Encyclopaedia Judaica (via Encyclopedia.com): Ramallah taken by Israeli forces in the Six-Day War

**[S4053]** encyclopedia.com, 'Hebron | Encyclopedia.com' — https://www.encyclopedia.com/places/asia/west-bank-and-gaza-political-geography/hebron — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Encyclopaedia Judaica (via Encyclopedia.com): Hebron incorporated into the kingdom of Jordan in 1948
    - Encyclopaedia Judaica (via Encyclopedia.com): Hebron captured by the Israeli army in June 1967

**[S4054]** jewishvirtuallibrary.org, 'Jericho' — https://www.jewishvirtuallibrary.org/jericho — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Jewish Virtual Library: after the 1948 war Jericho was controlled by Jordan
    - Jewish Virtual Library: Jericho was the first territory given to the Palestinians in 1994

**[S4055]** jewishvirtuallibrary.org, 'Kuneitra' — https://www.jewishvirtuallibrary.org/kuneitra — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Jewish Virtual Library: Kuneitra was the capital of the Syrian-held front-line region before 1967

**[S4056]** slow-journalism.com, 'Inside Quneitra – the Golan’s shattered ghost town | Delayed Gratification' — https://www.slow-journalism.com/from-the-archive/inside-quneitra-the-golans-shattered-ghost-town — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Delayed Gratification: Israel pulled out of Quneitra in 1974; the town was destroyed (Israel denied responsibility; the UN condemned the destruction)

**[S4057]** timesofisrael.com, 'https://www.timesofisrael.com/in-war-struck-majdal-shams-assads-fall-sparks-hope-for-israels-druze/' — https://www.timesofisrael.com/in-war-struck-majdal-shams-assads-fall-sparks-hope-for-israels-druze/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Times of Israel: Majdal Shams is part of the Golan plateau captured from Syria in 1967 (i.e. held by Syria until then)
    - Times of Israel: Majdal Shams lies on the Golan plateau captured from Syria in 1967
    - Times of Israel: Majdal Shams on the Golan plateau, effectively annexed by Israel in 1981

**[S4058]** theconversation.com, 'Arab Druze community in mourning after tragic rocket strike on Golan Heights soccer field − highlighting challenges for Druze within Israel and the region' — https://theconversation.com/arab-druze-community-in-mourning-after-tragic-rocket-strike-on-golan-heights-soccer-field-highlighting-challenges-for-druze-within-israel-and-the-region-235832 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - The Conversation: Golan Heights, including Majdal Shams, captured by Israel in 1967 and annexed in 1981

**[S4059]** jta.org, 'Mixed feelings in the Golan about the price of peace - Jewish Telegraphic Agency' — https://www.jta.org/1999/12/10/lifestyle/mixed-feelings-in-the-golan-about-the-price-of-peace — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - JTA (1999): Katzrin is the Golan's largest town
    - JTA (1999): the Golan is a plateau Israel captured from Syria in the 1967 war
    - JTA (1999): a resident became a founding member of Katzrin in 1978 (CBS lists 1977)

**[S4060]** jewishvirtuallibrary.org, 'Golan Heights: History & Overview' — https://jewishvirtuallibrary.org/history-and-overview-of-the-golan-heights — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Jewish Virtual Library: Katzrin is a town on the Golan Heights, to which the Knesset extended Israeli law on 14 December 1981

**[S4061]** jewishvirtuallibrary.org, 'Geography of Israel: Kiryat Arba' — https://www.jewishvirtuallibrary.org/kiryat-arba — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Jewish Virtual Library gives 1968 as the establishment year (CBS: 1972; Shindler: authorised 1970, first residents 1971)

**[S4062]** jewishvirtuallibrary.org, 'Israeli Settlements: Ultra-Orthodox Settlements in the West Bank' — https://jewishvirtuallibrary.org/ultra-orthodox-settlements-in-the-west-bank — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Jewish Virtual Library: Beitar Illit founded 1985 in the West Bank, classified by Israel as a city
    - Jewish Virtual Library: Modi'in Illit (Kiryat Sefer) established 1996, east of the Green Line

**[S4063]** peacenow.org.il, 'https://peacenow.org.il/en/settlements/settlement22-en' — https://peacenow.org.il/en/settlements/settlement22-en — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Peace Now settlement database: Beitar Illit established 1985

**[S4064]** britannica.com, 'https://www.britannica.com/place/Gaza-city-Gaza-Strip' — https://www.britannica.com/place/Gaza-city-Gaza-Strip — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Britannica: Egypt held Gaza from 1948 and at the February 1949 armistice
    - Britannica: Gaza reoccupied by Israel in June 1967, under Israeli military administration until 1994

**[S4065]** encyclopedia.com, 'Gaza Strip | Encyclopedia.com' — https://www.encyclopedia.com/places/asia/west-bank-and-gaza-political-geography/gaza-strip — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Encyclopaedia Judaica (via Encyclopedia.com): the Gaza Strip was ruled by Egypt after 1948; its largest cities are Gaza City, Khan Yunis and Rafah
    - Encyclopaedia Judaica (via Encyclopedia.com): at the end of the June 1967 war Israel held the Gaza Strip, whose largest cities are Gaza City, Khan Yunis and Rafah
    - Encyclopaedia Judaica (via Encyclopedia.com): the Gaza Strip was ruled by Egypt
    - Encyclopaedia Judaica (via Encyclopedia.com): Israel held the Gaza Strip after the June 1967 war
    - The Palestinian Authority became the governing regime in the Strip and received areas with civilian and security authority
    - Arafat set up Palestinian Authority headquarters in the city of Gaza after 1994
    - Khan Yunis is one of the Gaza Strip's largest cities
    - Rafah is one of the Gaza Strip's largest cities

**[S4066]** jewishvirtuallibrary.org, 'UN Relief & Works Agency (UNRWA): Gaza Strip Refugee Camp Profiles' — https://jewishvirtuallibrary.org/gaza-strip-refugee-camp-profiles — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - UNRWA profile (via JVL): Deir al-Balah, a town and refugee camp in the central Gaza Strip
    - UNRWA profile (via JVL): Jabalia camp, Gaza Strip, settled by 35,000 refugees after 1948
    - Deir el-Balah is a town in central Gaza Strip
    - Jabalia is in the Gaza Strip

**[S4071]** palquest.org, 'interactive encyclopedia of the palestine question – palquest | operation hiram' — https://www.palquest.org/node/25291 — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - date: the first village (Safsaf) fell before dawn on 29 October 1948, the first day of the fighting (Palquest's infobox gives a 28 October launch)
    - date_end: operation ended on 30-31 October 1948 as units extended control along the Lebanese border

**[S4100]** Jewish Virtual Library, 'Geography of Israel: Jaffa' — https://www.jewishvirtuallibrary.org/jaffa — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - Jaffa described as the largest Arab city in the country before 1948
    - Before 1948 Jaffa was a largely Arab city (about 70,000 of nearly 100,000 non-Jews, 1946-47)
    - On May 13, 1948 Jaffa fell to Jewish forces and most of its inhabitants left by sea (JVL)
    - Jaffa and Tel Aviv combined into one city in 1950
    - Government decision of 4 Oct 1949 to amalgamate Tel Aviv with Jaffa; renamed a year later

**[S4101]** University of Haifa research portal, 'The demarcation of Tel Aviv-Jaffa's municipal boundaries following the 1948 war: Political conflicts and spatial outcome' (abstract) — https://cris.haifa.ac.il/en/publications/the-demarcation-of-tel-aviv-jaffas-municipal-boundaries-following/ — archived: n/a — accessed: 2026-10-11 — provenance: opened
  - Supports:
    - In 1950, following the repopulation of Jaffa, the two cities were united

**[S4130]** History.com, 'Rabin and Arafat sign accord for Palestinian self-rule' (4 May 1994 Gaza-Jericho agreement) — https://www.history.com/this-day-in-history/may-4/rabin-and-arafat-sign-accord-for-palestinian-self-rule — archived: n/a — accessed: 2026-10-12 — provenance: opened
  - Supports:
    - Gaza-Jericho Agreement (signed 4 May 1994): Israeli military withdrawal from about 60 percent of the Gaza Strip, which covers Gaza City
    - The agreement transferred authority from the Israeli Civil Administration to the new Palestinian Authority
    - Gaza-Jericho Agreement (signed 4 May 1994): Israeli military withdrawal from about 60 percent of the Gaza Strip, which covers Khan Yunis
    - Gaza-Jericho Agreement (signed 4 May 1994): Israeli military withdrawal from about 60 percent of the Gaza Strip, which covers Rafah
    - Gaza-Jericho Agreement (signed 4 May 1994): Israeli military withdrawal from about 60 percent of the Gaza Strip, which covers Deir al-Balah
    - Gaza-Jericho Agreement (signed 4 May 1994): Israeli military withdrawal from about 60 percent of the Gaza Strip, which covers Jabalia

**[S4131]** Tazpit Press Service (TPS-IL), 'Nazareth Illit Officially Renamed Nof HaGalil', 26 June 2019 — https://tps.co.il/news/nazareth-illit-officially-renamed-nof-hagalil/ — archived: n/a — accessed: 2026-10-12 — provenance: opened
  - Supports:
    - Nazareth Illit was officially renamed Nof HaGalil by the Interior Minister's order of 26 June 2019

**[S4132]** Flags of the World (flagspot.net), 'Hod HaSharon (Israel)' — https://flagspot.net/FLAGS/il-hodsr.html — archived: n/a — accessed: 2026-10-12 — provenance: opened
  - Supports:
    - Hod HaSharon was established in 1964 by uniting the local councils of Magdiel, Ramat Hadar and Hadar Ramatayim
    - Hod HaSharon came into being in 1964 through the union of the local councils

**[S4133]** Jewish Film Center (jfc.org.il), 'Arad' film record (Israel Film Service, 1963) — https://jfc.org.il/en/news_journal/58668-2/ — archived: n/a — accessed: 2026-10-12 — provenance: opened
  - Supports:
    - date: film record traces the construction of Arad during 1962
    - Film record traces the construction of Arad during 1962

**[S4134]** Wikivoyage, 'Arad (Israel)' (travel guide; not Wikipedia) — https://en.wikivoyage.org/wiki/Arad_(Israel) — archived: n/a — accessed: 2026-10-12 — provenance: opened
  - Supports:
    - date: modern Arad was founded in 1962 (an older reference work gives 1961)
    - Modern Arad was founded in 1962
    - Arad founded in 1962 as a planned Negev town

**[S4135]** 'The History of Karmiel', Karmiel community history page (karmiel.livejournal.com), with milestones table — https://karmiel.livejournal.com/1266.html — archived: n/a — accessed: 2026-10-12 — provenance: opened
  - Supports:
    - date: the establishment of the city was announced at a ceremony on 29 October 1964
    - Ceremony announcing the establishment of the city on 29 October 1964
    - Karmiel was dedicated on 29 October 1964

**[S4136]** Encyclopaedia Judaica, 'Modi'in' (City of Modi'in section), via encyclopedia.com — https://encyclopedia.com/religion/encyclopedias-almanacs-transcripts-and-maps/modiin — archived: n/a — accessed: 2026-10-12 — provenance: opened
  - Supports:
    - The modern city of Modi'in was officially established in 1993
    - In 2003 the municipality was united with Maccabim-Re'ut
    - Modi'in officially established in 1993 and united with Maccabim-Re'ut in 2003

**[S4137]** Jewish Virtual Library, 'Operation Magic Carpet - Airlift of Yemenite Jews (1949)' — https://www.jewishvirtuallibrary.org/operation-magic-carpet-airlift-of-yemenite-jews — archived: n/a — accessed: 2026-10-12 — provenance: opened
  - Supports:
    - date: the operation was launched in May 1949, after the Imam of Yemen agreed to let the Jews leave
