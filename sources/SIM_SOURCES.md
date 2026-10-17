# Sources - Civilization: Israel (gameplay / simulation data)

Rendered from `sources/sim_sources.json` by `python tools/merge_pending_sources.py`. Do not hand-edit.

- S500-S699, S750-S799, S900-S999 and S5000-S5999 are reserved for gameplay sources (techs, civics, policies, governments, buildings, forks, wars, label series).
- Gameplay data also cites history sources (`sources.json`) by their permanent ids.

Provenance: `opened` = opened and the quoted claim checked; `not_opened` = reference only - cite it with a verbatim quote from an opened URL.

**[S500]** Bolt, Jutta and Jan Luiten van Zanden, 'Maddison style estimates of the evolution of the world economy: A new 2023 update', Journal of Economic Surveys, 2024; Maddison Project Database 2023, GDP per capita (2011 int$), via Our World in Data grapher 'gdp-per-capita-maddison-project-database' — https://ourworldindata.org/grapher/gdp-per-capita-maddison-project-database — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data.
  - Supports:
    - Israel GDP per capita 1950-2022 (e.g. 1950 4,490; 1973 15,374; 2000 26,058; 2022 36,648), used only as real-world labels on the economy track

**[S501]** World Bank, World Development Indicators ER.H2O.FWTL.K3 (annual freshwater withdrawals, from FAO AQUASTAT), and Our World in Data 'water-withdrawals-per-capita' — https://ourworldindata.org/grapher/water-withdrawals-per-capita — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data.
  - Supports:
    - Israel freshwater withdrawals per capita 1970-2023 (546 m3 in 1970, 397 in 1990, 262 in 2010, 277 in 2023); excludes desalinated and reclaimed water. Used only as labels on the water track

**[S502]** UNESCO Institute for Statistics, gross domestic expenditure on R&D as a share of GDP, via Our World in Data 'research-spending-gdp' — https://ourworldindata.org/grapher/research-spending-gdp — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data.
  - Supports:
    - Israel R&D spending 2.48% of GDP (1996), 3.81% (2000), 4.30% (2015), 6.35% (2023); used only as labels on the science track

**[S503]** Wikipedia, 'Water supply and sanitation in Israel' (history sections); also Wikipedia, 'National Water Carrier of Israel' — https://en.wikipedia.org/wiki/Water_supply_and_sanitation_in_Israel — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext (Mekorot 1937, Negev pipeline 1955, Shafdan 1969, Mekorot operates Shafdan). The 1964 National Water Carrier date is from Wikipedia 'National Water Carrier of Israel' ('completed in June 1964 ... constructed by Mekorot'); the water-supply article itself gives 1965 for the first transfers. Mekorot's own site (mekorot.co.il) is JS-only and was not readable.
  - Quote: "In 1937 the national water company Mekorot was created, more than a decade before the creation of the state of Israel. Among its achievements was the Shiloach Pipeline along the Burma Road to Jerusalem built during the 1948 Arab–Israeli War and a first pipeline to the Negev in 1955. ... In 1969, the Shafdan wastewater treatment plant south of Tel Aviv was completed to treat approximately 130 million cubic meters of wastewater per year for reuse in agriculture."
  - Supports:
    - Mekorot founded 1937; wells and regional pipelines drawing on the coastal and mountain aquifers in the 1950s; operation of the National Water Carrier from 1964; the Shafdan wastewater reclamation scheme for the Dan region

**[S504]** Wikipedia, 'Netafim' (company timeline) — https://en.wikipedia.org/wiki/Netafim — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext; netafim.com 'about' page is JS-rendered and held no history text.
  - Quote: "1960–1965 – Water engineer and inventor Simcha Blass carries out tests on the world's first dripper device. [...] 1965 – Kibbutz Hatzerim signs agreement with Blass to establish Netafim"
  - Supports:
    - Netafim founded in 1965 at Kibbutz Hatzerim to commercialise Simcha Blass's drip-irrigation emitter

**[S505]** IEEE History Center, 'Milestones: WEIZAC Computer, 1955', Engineering and Technology History Wiki (milestone dedicated 2006) — https://ethw.org/Milestones:WEIZAC_Computer,_1955 — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 on the ETHW milestone page (dedicated 2006-12-05). The page calls WEIZAC the first digital electronic computer built in the Middle East and 'one of the world's first electronic computers'; operational October 1955.
  - Quote: "The Weizmann Institute of Science in Rehovot, Israel, built the Weizmann Automatic Computer (WEIZAC) during 1954-1955 ... The machine was the first digital electronic computer constructed in the Middle East ... in October 1955 the WEIZAC was put into operation."
  - Supports:
    - WEIZAC, built at the Weizmann Institute of Science, became operational in 1955 as one of the first stored-program computers in a small country

**[S506]** Wikipedia, 'Solar power in Israel' (solar water heating section) — https://en.wikipedia.org/wiki/Solar_power_in_Israel — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext (Levi Yissar, NerYah 1953; 1980 law). The same facts appear in Wikipedia 'Solar water heating'. Replaces the unopened print citation (Perlin, Let It Shine, 2013).
  - Quote: "He built a prototype in his home, and in 1953 he started NerYah Company, Israel's first commercial manufacturer of solar water heaters. ... After the energy crisis in the 1970s, in 1980 the Israeli Knesset passed a law requiring the installation of solar water heaters in all new homes except high towers with insufficient roof area."
  - Supports:
    - Levi Yissar's solar water heaters sold from 1953; the 1980 requirement for solar water heaters in new residential buildings

**[S507]** Wikipedia, 'Uzi' — https://en.wikipedia.org/wiki/Uzi — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext (designer Uziel Gal; IDF service from 1954, general issue c. 1956). Replaces the unopened print citation (Ezell, Small Arms of the World).
  - Quote: "The Uzi prototype was finished in 1950. It was first introduced to Israel Defense Forces (IDF) special forces in 1954, and the weapon was placed into general issue two years later. ... Over its service lifetime, it has been manufactured by Israel Military Industries, FN Herstal, and other manufacturers."
  - Supports:
    - The Uzi submachine gun, designed by Uziel Gal, adopted by the IDF in 1954 and produced by Israel Military Industries

**[S508]** Wikipedia, 'Silicon Wadi' (history sections); also Wikipedia, 'Intel 8088' — https://en.wikipedia.org/wiki/Silicon_Wadi — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext. Intel's first Israeli office was in Haifa in 1974 (Wikipedia 'Intel': 'founded the Israeli branch of the company in 1974 in a small office in Haifa'); 'The 8088 was designed at Intel's laboratory in Haifa, Israel ... The 8088 was used in the original IBM PC' (Wikipedia 'Intel 8088'). Replaces the unopened print citation (Senor and Singer, Start-up Nation).
  - Quote: "In the 1970s, Intel and IBM both opened offices in Israel, IBM opened in 1972 and Intel opened in 1974. ... In 1998, Mirabilis, an Israeli company that developed the ICQ instant messaging program ... was purchased by America Online (AOL) for $407 million in cash ... a $100 million government initiative in 1993 named the Yozma program."
  - Supports:
    - Intel's Haifa design centre (1974) and the 8088 processor designed in Israel and used in the IBM PC (1981); the Yozma programme (1993); the sale of Mirabilis/ICQ to AOL (1998)

**[S509]** Wikipedia, 'Yozma' (programme description and table of initial funds); bibliographic details of Avnimelech and Teubal, Research Policy 35(10), 2006, pp. 1477-1498, confirmed via Crossref — https://en.wikipedia.org/wiki/Yozma — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11. The article's 'Yozma Initial Funds' table lists ten private funds (Eurofund, Gemini, Inventech, JVP, Medica, Nitzanim, Polaris, Star, Vertex, Walden) plus Yozma's own fund. The Research Policy article itself is paywalled (abstract not available); its title, volume, issue and pages were confirmed via api.crossref.org.
  - Quote: "Yozma, Yozma Program, or Yozma Fund was a venture capital organization in Israel that initially started out as a government funded program in 1993 to help kick start venture capital, angel investing, and private equity in Israel's economy. $20 million of government subsidies went to the Yozma Fund, the other $80 million the government provided went to match other foreign and domestic firms, at 40%, to create their own venture capital funds in Israel."
  - Supports:
    - The government Yozma programme launched in 1993 with $100 million, seeding ten private venture-capital funds

**[S510]** Wikipedia, 'Check Point' and 'Gil Shwed' — https://en.wikipedia.org/wiki/Check_Point — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11. FireWall-1 release year from Wikipedia 'Gil Shwed': 'stateful inspection, which was the basis for the first version of the company's renowned FireWall-1, released in 1994.' checkpoint.com 'about us' confirms '1993 Founded' but has no product history.
  - Quote: "Check Point was established in Ramat Gan, Israel in 1993 by Gil Shwed, Marius Nacht and Shlomo Kramer. [...] Shwed had the initial idea for the company's core technology known as stateful inspection, which became the foundation for the company's first product, FireWall-1"
  - Supports:
    - Check Point founded in 1993 in Ramat Gan; FireWall-1 released in 1994

**[S512]** Iddan, Gavriel, Gavriel Meron, Arkady Glukhovsky and Paul Swain, 'Wireless capsule endoscopy', Nature 405, 417 (published 25 May 2000); FDA clearance date from Wikipedia, 'Given Imaging' — https://doi.org/10.1038/35013140 — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 on the nature.com landing page (abstract; published 25 May 2000). US clearance from Wikipedia 'Given Imaging': 'received it CE marking in May 2001 and in August 2001 was cleared by the US Food and Drug Administration (FDA) for visualization of abnormalities of the small intestine.'.
  - Quote: "We have developed a new type of endoscopy, which for the first time allows painless endoscopic imaging of the whole of the small bowel. This procedure involves a wireless capsule endoscope and we describe here its successful testing in humans."
  - Supports:
    - Given Imaging's swallowable camera capsule, described in 2000 and cleared for US use in 2001

**[S513]** Wikipedia, 'Mobileye' — https://en.wikipedia.org/wiki/Mobileye — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext (infobox: founded 13 May 1999 in Jerusalem). Replaces the generic sec.gov link to the 2014 Form F-1, which was not opened.
  - Quote: "Mobileye was founded on May 13, 1999 by Hebrew University professor Amnon Shashua. He evolved his academic research into a vision system that could detect vehicles using a camera and software."
  - Supports:
    - Mobileye founded in Jerusalem in 1999 to develop camera-based driver-assistance systems

**[S514]** Google, The Keyword (formerly Official Google Blog), 'Google Maps and Waze, outsmarting traffic together', Brian McClendon, 11 June 2013; founding year from Wikipedia, 'Waze' — https://blog.google/products-and-platforms/products/maps/google-maps-and-waze-outsmarting/ — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11; the googleblog.blogspot.com URL redirects to blog.google (post dated Jun 11, 2013). Founding: Wikipedia 'Waze': 'In 2008, Shabtai formed a company called Waze to commercialize the initial project' (the FreeMap Israel project began in 2006).
  - Quote: "To help you outsmart traffic, today we're excited to announce we've closed the acquisition of Waze. ... The Waze product development team will remain in Israel and operate separately for now."
  - Supports:
    - Waze, the Israeli crowd-sourced navigation company founded in 2008, acquired by Google in June 2013

**[S515]** Wikipedia, 'Merkava' — https://en.wikipedia.org/wiki/Merkava — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext. The Jewish Virtual Library page returned only a bot-check stub and could not be read.
  - Quote: "Development began in 1970, [...] and its first generation, the Merkava Mark 1, entered official service in 1979. [...] Four main variants have been deployed. As of 2023, Merkava Mark 4 Barak [...] is the latest version. The Merkava was first used extensively in the 1982 Lebanon War"
  - Supports:
    - First Merkava Mk 1 tanks delivered to the IDF in 1979; designed under Israel Tal

**[S516]** Israel Aerospace Industries, 'IAI and the Security of Israel' (history timeline) — https://www.iai.co.il/about/history/ — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 on the IAI history page (also lists the 1969 Arava as the first fully indigenous design).
  - Quote: "Established in 1953 as Bedek Aviation Company – a governmental institute for aviation ... 1970 The first fighter aircraft manufactured in Israel, the Nesher, takes flight. ... 1975 Israel's first home-grown fighter bomber, the Kfir, developed and manufactured by IAI, enters service with the Israeli Air Force."
  - Supports:
    - IAI founded in 1953 as Bedek Aviation; licence-built and later indigenous jet aircraft; the Kfir entered service in 1975

**[S517]** Wikipedia, 'IAI Scout' (operational history); also Wikipedia, 'Tadiran Mastiff' — https://en.wikipedia.org/wiki/IAI_Scout — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext (Mastiff first flew 1973). Replaces the unopened print citation (Zaloga, Unmanned Aerial Vehicles, Osprey 2008).
  - Quote: "During the 1982 Lebanon War, the Israelis were confronted by Syrian surface-to-air missiles (SAMs), which were heavily sited in Lebanon's Bekaa Valley. All 28 SAM sites in the Bekaa were destroyed, however, partly through the use of Samson decoys to get them to reveal their presence, and partly through reconnaissance information obtained by the Mastiff and Scout UAVs."
  - Supports:
    - Israeli Scout and Mastiff reconnaissance UAVs used operationally in 1982

**[S518]** Congressional Research Service, 'U.S. Foreign Aid to Israel', report RL33222 (version of 1 March 2023), via EveryCRSReport.com — https://www.everycrsreport.com/files/2023-03-01_RL33222_7ba4408ea8cf4a56fc01dbcb3d6b1154f8868dc3.html — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 on the EveryCRSReport mirror, 1 March 2023 edition (crsreports.congress.gov returned a bot-check page). Both claims confirmed: Arrow operational 2000; US Iron Dome funding from FY2011. Co-development since 1988 under a 1986 SDI agreement.
  - Quote: "The total U.S. financial contribution (for all Arrow systems) has exceeded $4.5 billion (see Table 3). The system became operational in 2000 in Israel and has been tested successfully. ... As the United States began financially supporting Israel's development of Iron Dome in FY2011, U.S. interest in ultimately becoming a partner in its co-production grew."
  - Supports:
    - US-Israel co-development of the Arrow interceptor, operational from 2000; US funding for Iron Dome from 2011

**[S520]** U.S. Food and Drug Administration, Drugs@FDA, NDA 020622 (Copaxone, glatiramer acetate; Teva), approval history; Weizmann origin from Wikipedia, 'Glatiramer acetate' — https://www.accessdata.fda.gov/scripts/cder/daf/index.cfm?event=overview.process&ApplNo=020622 — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 on Drugs@FDA (original approval 20 December 1996). Wikipedia 'Glatiramer acetate': 'Glatiramer acetate was originally discovered at the Weizmann Institute of Science.'.
  - Quote: "New Drug Application (NDA): 020622 Company: TEVA PHARMS USA ... COPAXONE GLATIRAMER ACETATE ... 12/20/1996 ORIG-1 Approval Type 1 - New Molecular Entity STANDARD; Orphan"
  - Supports:
    - Copaxone, developed at the Weizmann Institute and marketed by Teva, approved in the United States in 1996

**[S521]** Wikipedia, 'Israel National Cyber Directorate'; CyberSpark from Wikipedia, 'Science and technology in Israel' — https://en.wikipedia.org/wiki/Israel_National_Cyber_Directorate — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext. CyberSpark: 'In January 2014, the prime minister launched CyberSpark, Israel's cyber innovation park ... Located in the city of Beer-Sheva' (Wikipedia 'Science and technology in Israel'). gov.il and the archived pmo.gov.il pages did not return readable text.
  - Quote: "Following that, in August 2011 the Israeli government passed a resolution to establish the Israeli National Cyber Bureau (INCB), designated to assist the prime minister, the government and its committees in forging a National Cyber Policy ... the Israeli National Cyber Bureau (established in 2012)."
  - Supports:
    - National Cyber Bureau established by government resolution in 2011 and operating from 2012; the CyberSpark industry park in Be'er Sheva announced in 2014

**[S522]** Wikipedia, 'Ashalim power station' — https://en.wikipedia.org/wiki/Ashalim_power_station — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext (infobox: construction began 2014, commissioned 2019). The NREL SolarPACES database did not respond to a direct request.
  - Quote: "The Ashalim Plot B (Megalim) hosts a solar power tower. It has an installed capacity of 121 megawatts, [...] concentrating 50,600 computer-controlled heliostats enough to power 120,000 homes. Electricity production commenced in September 2019, [...] producing 320 GWhr of energy per year"
  - Supports:
    - The Ashalim solar power stations in the Negev (Plot B tower plant, 121 MW) entered commercial operation in 2019

**[S523]** RETIRED (no longer cited; cited only by content dated after Q3 2023, deleted 2026-10-14 (the game ends 7 Oct 2023)) — Rafael Advanced Defense Systems and Israel Ministry of Defense, 'RAFAEL & Israel MOD: IRON BEAM 450 Development Completed, Delivery to IDF Soon', press release, 17 September 2025; with Jerusalem Post, Yonah Jeremy Bob, 'Defense Ministry rolls out Iron Beam laser air defense system across Israel', 28 December 2025 (https://www.jpost.com/defense-and-tech/article-881595) — https://www.rafael.co.il/news/rafael-israel-mod-iron-beam-450-development-completed-delivery-to-idf-soon/

**[S525]** Hebrew Wikipedia, 'חוק לימוד חובה' (Compulsory Education Law, 5709-1949) — https://he.wikipedia.org/wiki/חוק_לימוד_חובה — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Hebrew Wikipedia wikitext. Translation: 'This is one of the first laws enacted by the First Knesset, in September 1949, and the first of the state's education laws.' The infobox gives the enactment date as 18 September 1949 (Sefer HaHukim 26, p. 287), and the article describes the state's duty to provide free education. Replaces the unopened print citation (Laws of the State of Israel vol. 3).
  - Quote: "זהו אחד החוקים הראשונים שנחקקו בכנסת הראשונה, בספטמבר 1949 והראשון בחוקי החינוך במדינה."
  - Supports:
    - Free compulsory education enacted by the First Knesset in September 1949

**[S526]** Wikipedia, 'Stream system in Israeli education' (history and abolition); also Hebrew Wikipedia, 'חוק חינוך ממלכתי' — https://en.wikipedia.org/wiki/Stream_system_in_Israeli_education — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext. Hebrew Wikipedia confirms: passed by the Knesset on 12 August 1953 (39 for, 36 against), law dated 20 August 1953, intended to abolish the stream system and move to state education. Replaces the unopened print citation (Laws of the State of Israel vol. 7).
  - Quote: "This system emerged in the 1920s under the British Mandate and continued until the passage of the State Education Law in 1953, which established a national educational framework. ... The State Education Law passed on 12 August 1953 unified the General and Labor streams, institutionalized the Mizrachi stream as the official state religious stream, and preserved limited autonomy for the Agudat Israel stream."
  - Supports:
    - The 1953 law replacing the party-affiliated school streams with a state system

**[S527]** Wikipedia, 'Conscription in Israel'; also Hebrew Wikipedia, 'חוק שירות ביטחון' — https://en.wikipedia.org/wiki/Conscription_in_Israel — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext. Hebrew Wikipedia notes the current consolidated law (1986) continues the Defence Service Law 5709-1949 and that most reserve provisions moved to the Reserve Service Law in 2008. Replaces the unopened print citation.
  - Quote: "In 1949, after the founding of the State of Israel, the Knesset passed the Defense Service Law which gave the IDF the authority to enlist any citizen over the age of 18. ... Once they have completed their mandatory term of service, all discharged citizens remain eligible to be called up for reserve duty until the age of 40."
  - Supports:
    - Universal conscription and reserve service enacted in 1949

**[S528]** National Insurance Institute of Israel (Bituach Leumi), 'About the National Insurance Institute'; founding date from Wikipedia, 'National Insurance Institute of Israel' — https://www.btl.gov.il/English%20Homepage/About/Pages/default.aspx — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 on the BTL English 'About' page. Wikipedia: 'Bituah Leumi was established in April 1954' (infobox: formed 1 April 1954). Wording refined from 'began paying benefits in 1954' to what the sources state (establishment in April 1954); the year is unchanged.
  - Quote: "The National Insurance of Israel (NII), one of the pillars on which social policy in Israel rests. It acts as a public social security institution and operates under the National Insurance Law, passed by the Knesset (Israeli Parliament) in November 1953."
  - Supports:
    - National Insurance Law passed in November 1953; the institute established and began operating on 1 April 1954

**[S529]** Wikipedia, 'Ulpan' — https://en.wikipedia.org/wiki/Ulpan — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext; the Jewish Virtual Library page returned only a bot-check stub.
  - Quote: "Ulpan Etzion in Jerusalem's Baka neighborhood was established in 1949 by Mordechai Kamerat as a model for Hebrew language education used across Israel. ... Since the establishment of the first ulpan in Jerusalem in 1949, more than 1.3 million new immigrants have graduated from ulpanim."
  - Supports:
    - The first ulpan (intensive Hebrew course for immigrants) opened in Jerusalem in 1949

**[S530]** Hebrew Wikipedia, 'תוכנית שרון (תכנון פיסי בישראל)' (the Sharon Plan, Physical Planning in Israel, 1951); also Wikipedia, 'Development town' — https://he.wikipedia.org/wiki/תוכנית_שרון_(תכנון_פיסי_בישראל) — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Hebrew Wikipedia wikitext. Translation: 'The Sharon Plan (officially: Physical Planning in Israel) was the first national master plan of the State of Israel. The plan was published in 1951 ... its principles were dispersal of the population to the Negev and Galilee and the creation of a hierarchical network of villages, towns and cities.' Wikipedia 'Development town': 'Development towns ... were new settlements built in Israel during the 1950s in order to provide permanent housing for a large influx of Jews'. Replaces the unopened print citations (Sharon 1951; Troen 1995).
  - Quote: "תוכנית שרון (או בשמה הרשמי: תכנון פיסי בישראל) הייתה תוכנית האב הארצית הראשונה של מדינת ישראל. התוכנית פורסמה בשנת 1951 ... העקרונות עליהם התבססה התוכנית היו פיזור האוכלוסייה בנגב והגליל ויצירת רשת היררכית של יישובים, עיירות וערים."
  - Supports:
    - The 1951 national physical plan for population dispersal and the development towns built in the 1950s

**[S531]** Hebrew Wikipedia, 'חוק לעידוד השקעות הון' (Law for the Encouragement of Capital Investments, 5719-1959) — https://he.wikipedia.org/wiki/חוק_לעידוד_השקעות_הון — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Hebrew Wikipedia wikitext (infobox: enacted 16 August 1959 by the Third Knesset). Translation: 'The Law for the Encouragement of Capital Investments, 1959, is a law intended to encourage investment in industry in Israel ... another aim is to encourage businesses in the periphery ... main benefits: grants to an industrial plant under an approved programme ... lower income-tax rates.' Tax rates are lower in National Priority (Development) Area A. Replaces the unopened print citation.
  - Quote: "חוק לעידוד השקעות הון, תשי"ט-1959 הוא חוק שנועד לעודד השקעה בתעשייה בישראל. ... מטרה אחרת היא לעודד קיום עסקים בפריפריה. ... עיקר ההטבות של החוק: אפשרות למפעל תעשייתי לקבל מענקים במסגרת תוכנית מאושרת. ... שיעורים נמוכים יותר של מס הכנסה."
  - Supports:
    - Investment grants and tax benefits for approved enterprises, especially in development areas, from 1959

**[S532]** Wikipedia, 'MASHAV' — https://en.wikipedia.org/wiki/MASHAV — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext (gov.il page is JS-only).
  - Quote: "It was established on Golda Meir's initiative, in 1958, after her visit to Africa."
  - Supports:
    - MASHAV established in 1958 to run Israel's international development cooperation

**[S533]** Hebrew Wikipedia, 'משרד העלייה והקליטה' (Ministry of Aliyah and Integration); also Wikipedia, 'Ministry of Aliyah and Integration' (list of ministers) — https://he.wikipedia.org/wiki/משרד_העלייה_והקליטה — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Hebrew Wikipedia wikitext. Translation: 'The Ministry of Aliyah and Integration (formerly the Ministry of Immigrant Absorption) ... was established in 1968, following the wave of immigration after the Six-Day War.' English Wikipedia lists Yigal Allon as the first Minister of Immigrant Absorption from 1 July 1968 (a separate Ministry of Immigration existed 1948-1951).
  - Quote: "משרד העלייה והקליטה (בעבר: המשרד לקליטת העלייה) הוא משרד ממשלתי המופקד על ביצוע מדיניות הממשלה בתחום עידוד וקליטת העלייה. הוקם ב-1968, בעקבות גל העלייה לאחר מלחמת ששת הימים."
  - Supports:
    - A Ministry of Immigrant Absorption established in 1968

**[S534]** Wikipedia, 'Israel Broadcasting Authority'; also Wikipedia, 'Channel 1 (Israel)' — https://en.wikipedia.org/wiki/Israel_Broadcasting_Authority — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext. Channel 1 article: 'The station's first broadcast was a live broadcast of the IDF parade on Independence Day, which was held in May 1968, in Jerusalem.' Replaces the unopened print citation.
  - Quote: "The law creating the Israel Broadcasting Authority was passed by the Knesset on 6 June 1965. Television broadcasts commenced on 2 May 1968, with color television following on 23 February 1983."
  - Supports:
    - Public television broadcasting in Israel began in 1968 under the Israel Broadcasting Authority

**[S535]** Regulation (EEC) No 1274/75 of the Council of 20 May 1975 concluding the Agreement between the European Economic Community and the State of Israel, OJ L 136, 28.5.1975, pp. 1-2 (EUR-Lex); also Wikipedia, 'Israel–European Union relations' — https://eur-lex.europa.eu/eli/reg/1975/1274/oj/eng — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 on EUR-Lex (signing date and OJ L 136 of 28.5.1975 confirmed). The agreement's free-trade character: Wikipedia 'Israel–European Union relations': 'A first free trade area agreement was signed in 1975.'
  - Quote: "Whereas the Agreement between the European Economic Community and the State of Israel signed at Brussels on 11 May 1975 should be concluded and the Declarations and Exchange of Letters annexed to the Final Act, likewise signed at Brussels on 11 May 1975, should be adopted"
  - Supports:
    - The 1975 EEC-Israel free-trade agreement for industrial goods

**[S536]** Hebrew Wikipedia, 'המהפך הכלכלי' (the 1977 economic liberalisation); also Wikipedia, 'Economy of Israel' and 'Privatization in Israel' — https://he.wikipedia.org/wiki/המהפך_הכלכלי — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext. Translation: 'The economic turnaround is the name given to the economic liberalisation programme presented by Finance Minister Simha Erlich on 29 October 1977'; the article describes the earlier foreign-currency controls and multiple exchange rates it abolished. Wikipedia 'Economy of Israel': 'the successful economic stabilization plan implemented in 1985 and the subsequent introduction of market-oriented structural reforms reinvigorated the economy and paved the way for its rapid growth in the 1990s'. Wikipedia 'Privatization in Israel': about 90 government companies and subsidiaries privatised, with revenue between 1991 and 2003. Replaces the unopened print citation (Ben-Bassat, ed., 2002).
  - Quote: "המהפך הכלכלי הוא השם שניתן לתוכנית הליברליזציה הכלכלית שהציג שר האוצר שמחה ארליך ב-29 באוקטובר 1977"
  - Supports:
    - Foreign-exchange liberalisation of October 1977 as background; privatisation of state-owned companies in the 1990s; liberalisation after the 1985 stabilisation

**[S537]** Wikipedia, 'Research and development' (Israel section) — https://en.wikipedia.org/wiki/Research_and_development — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext. Replaces the unopened print citation (the 1984 law).
  - Quote: "In 1984, a law for Encouragement of Research and Development in Industry encouraged the commercial sector to invest in R&D in Israel as well as empowered the Office of Chief Scientist"
  - Supports:
    - Grants for industrial R&D administered by the Office of the Chief Scientist from 1984

**[S538]** Hebrew Wikipedia, 'חוק ביטוח בריאות ממלכתי' (National Health Insurance Law, 5754-1994) — https://he.wikipedia.org/wiki/חוק_ביטוח_בריאות_ממלכתי — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Hebrew Wikipedia wikitext (infobox: enacted 26 June 1994 by the 13th Knesset, 68-0). Translation: 'The National Health Insurance Law, 1994, establishes compulsory health insurance for residents of Israel and the basket of medical services provided through the health funds. The law came into force on 1 January 1995.' The health.gov.il page returned no content.
  - Quote: "חוק ביטוח בריאות ממלכתי, התשנ"ד-1994 הוא החוק הקובע חובת ביטוח בריאות לתושבי ישראל, ואת סל השירותים הרפואיים שיינתן באמצעות קופות החולים. החוק נכנס לתוקף ב-1 בינואר 1995"
  - Supports:
    - National Health Insurance Law passed in 1994 and in force from 1 January 1995

**[S539]** OECD, 'Israel's accession to the OECD' (oecd.org/israel, archived 24 August 2012) — http://www.oecd.org/israel/israelsaccessiontotheoecd.htm — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 on the archived OECD page (the live oecd.org returns a bot-check page). Both dates confirmed: invitation 10 May 2010; accession 7 September 2010.
  - Quote: "7 September 2010 - In signing the OECD Convention, Israel pledged its full dedication to achieving the Organisation's fundamental aims. ... 29 June 2010 - An Accession Agreement was signed in Paris, France. ... 10 May 2010 - The OECD issued an invitation to Israel to become a member of the OECD."
  - Supports:
    - Israel invited in May 2010 and became an OECD member on 7 September 2010

**[S540]** Wikipedia, 'Trajtenberg Committee' (Committee for Socioeconomic Change; report September 2011) — https://en.wikipedia.org/wiki/Trajtenberg_Committee — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext (the generic gov.il link pointed at no specific page). The article gives September 2011 for the recommendations; the exact day (26 September) in the original citation is not stated there.
  - Quote: "The Trajtenberg Committee (Hebrew: ועדת טרכטנברג) is a commission appointed by the Israeli Prime Minister Benjamin Netanyahu on August 8, 2011, in order to examine and propose solutions to Israel's socioeconomic problems. The committee was established following the 2011 Israeli housing protests. ... The committee's recommendations were published in September 2011."
  - Supports:
    - The committee set up after the summer 2011 cost-of-living protests and its recommendations

**[S541]** Hebrew Wikipedia, 'ועדת ששינסקי (חוק הנפט)' (Sheshinski Committee, oil and gas taxation) — https://he.wikipedia.org/wiki/ועדת_ששינסקי_(חוק_הנפט) — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Hebrew Wikipedia wikitext. Translation: 'The committee recommended raising taxation on oil and gas production profits. To implement the recommendations the Oil Profits Levy Law 5771-2011 was enacted (later renamed the Taxation of Profits from Natural Resources Law). ... On 3 January 2011 the committee published its final recommendations' (levy capped at 50%). Replaces the unopened print citation.
  - Quote: "הוועדה המליצה להעלות את המיסוי על רווחי הפקת נפט וגז. למימוש ההמלצות נחקק חוק היטל רווחי נפט התשע"א-2011 (שבהמשך שונה שמו לחוק מיסוי רווחים ממשאבי טבע). ... ב-3 בינואר 2011 פרסמה הוועדה את המלצותיה הסופיות."
  - Supports:
    - The 2011 tax on oil and gas profits

**[S542]** Wikipedia, 'Israel Innovation Authority' — https://en.wikipedia.org/wiki/Israel_Innovation_Authority — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext (innovationisrael.org.il is JS-rendered).
  - Quote: "The Office of the Chief Scientist was established in 1965. It was renamed the Israel Innovation Authority (IIA) in 2016."
  - Supports:
    - The Office of the Chief Scientist at the Ministry of Economy reorganised as the Israel Innovation Authority in 2016

**[S543]** Hebrew Wikipedia, 'מחיר למשתכן' (Mehir LaMishtaken, history section) — https://he.wikipedia.org/wiki/מחיר_למשתכן — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Hebrew Wikipedia wikitext. Translation: 'With the appointment of Moshe Kahlon as Finance Minister in 2015, the government decided to expand the Mehir LaMishtaken programme and build thousands of housing units under it ... Because of the large gap between demand and supply, buyers were to be selected by lottery.' CORRECTED: the article shows the scheme predates 2015 (late 1990s; about 3,500 flats 2000-2007, about 4,000 in 2008-2012); 2015 is the large lottery-based expansion, not the first launch.
  - Quote: "עם מינויו של משה כחלון לתפקיד שר האוצר בשנת 2015, החליטה ממשלת ישראל להרחיב את תוכנית "מחיר למשתכן" ולבנות במסגרתה אלפי יחידות דיור. ... בשל פער ניכר בין הביקוש להיצע, נקבע כי בחירת הרוכשים תתבצע באמצעות הגרלה."
  - Supports:
    - The Mehir LaMishtaken (Buyer's Price) scheme existed on a small scale from the late 1990s (about 3,500 flats sold 2000-2007 and about 4,000 in 2008-2012); in 2015, with Moshe Kahlon as Finance Minister, the government expanded it to thousands of units, with buyers chosen by lottery

**[S544]** Wikipedia, 'Benjamin Netanyahu', section 'Minister of Finance (2003–2005)' — https://en.wikipedia.org/wiki/Benjamin_Netanyahu — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext (spending cuts, tax reform, welfare-to-work and retirement-age changes from 2003). The Bank of Israel site (boi.org.il) served only a bot-check page, so the 2003 Annual Report itself was not read.
  - Quote: "As finance minister, Netanyahu undertook an economic plan in order to restore Israel's economy from its low point during the Second Intifada. ... He instituted a program to end welfare dependency by requiring people to apply for jobs or training, reduced the size of the public sector, froze government spending for three years, and capped the budget deficit at 1%. The taxation system was streamlined and taxes were cut"
  - Supports:
    - The 2003 economic recovery plan: spending cuts, tax reform and pension and welfare changes

**[S545]** Tal, Alon, 'Seeking Sustainability: Israel's Evolving Water Management Strategy', Science 313(5790), 25 August 2006, pp. 1081-1084 (abstract via PubMed, PMID 16931752) — https://pubmed.ncbi.nlm.nih.gov/16931752/ — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 at abstract level only (PubMed E-utilities; science.org returned a bot-check page). The abstract confirms the overall strategy (water transport, wastewater reuse, desalination, conservation); the specific items (National Water Carrier, Shafdan, drip irrigation, 2000s desalination) are in the full text, which was not read; see S503 and S580 for those dates.
  - Quote: "The water management policies adopted to address Israel's chronic scarcity have not been without environmental consequences. Yet, through a trial-and-error process, a combined strategy of water transport, rainwater harvesting, and wastewater reuse and desalination, along with a variety of water conservation measures, have put the country on a more sustainable path for the future."
  - Supports:
    - Groundwater development, the National Water Carrier, drip irrigation, wastewater reuse (Shafdan) and the move to large-scale seawater desalination in the 2000s

**[S546]** Wikipedia, 'Home Front Command' — https://en.wikipedia.org/wiki/Home_Front_Command — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext (oref.org.il is JS-rendered).
  - Quote: "It was created in February 1992 in response to the lessons of the Gulf War, [...] which was the first war since the 1948 Arab–Israeli War in which centers of civilian population faced significant threat"
  - Supports:
    - The Home Front Command established in February 1992, after the 1991 missile attacks

**[S547]** Wikipedia, 'Nahal' — https://en.wikipedia.org/wiki/Nahal — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext; the Jewish Virtual Library page returned only a bot-check stub.
  - Quote: "In 1948, a gar'in (core group) of Jewish pioneers wrote to Israel's first and then-current Prime Minister David Ben-Gurion, requesting that members be allowed to do their military service as a group rather than being split up into different units at random. In response to this letter, Ben-Gurion created the Nahal program, which combined military service and farming. Some 108 kibbutzim and agricultural settlements were established by the Nahal."
  - Supports:
    - The Nahal programme combining military service with founding agricultural settlements, from 1948

**[S552]** Wikipedia, 'Tel Aviv Stock Exchange' (history and milestones); also Hebrew Wikipedia, 'הבורסה לניירות ערך בתל אביב' — https://en.wikipedia.org/wiki/Tel_Aviv_Stock_Exchange — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext (tase.co.il is JS-rendered). Hebrew Wikipedia: the banks and investment houses 'combined and founded the Tel Aviv Stock Exchange in September 1953'. CORRECTED: the original wording ('an exchange bureau opened in 1953 and the TASE was incorporated in 1983') is not supported; the exchange bureau dates from 1935, the TASE from 1953, and 1983 is the year of the bank-shares crisis. TASE has been a public company listed on its own exchange since 1 August 2019.
  - Quote: "Tel Aviv Stock Exchange was established in 1953."
  - Supports:
    - Securities trading through the 'Exchange Bureau of Securities' at the Anglo-Palestine Bank from 1935; the Tel Aviv Stock Exchange founded by the banks and investment houses in September 1953

**[S553]** Wikipedia, 'Knesset building' — https://en.wikipedia.org/wiki/Knesset_building — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext (knesset.gov.il served only a bot-check page). Givat Ram location and August 1966 inauguration confirmed; formal handover to the Speaker on 22 August 1966.
  - Quote: "The building is situated in Kiryat HaMemshala, a government complex in Jerusalem, and was built between 1958 and 1966. ... After the building's construction, several ceremonies were held to inaugurate the building beginning on 29 August 1966. ... The main inauguration ceremony, held on 30 August 1966, was attended by approximately 5,000 people."
  - Supports:
    - The permanent Knesset building in Givat Ram, Jerusalem, inaugurated in August 1966

**[S554]** Wikipedia, 'Israel Museum' — https://en.wikipedia.org/wiki/Israel_Museum — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext (infobox: established May 1965); imj.org.il served only a bot-check page.
  - Quote: "It was established in 1965 as Israel's largest and foremost cultural institution, and an encyclopedic museum. It is situated on a hill in the Givat Ram neighborhood of Jerusalem"
  - Supports:
    - The Israel Museum opened in Jerusalem in 1965

**[S555]** Hebrew Wikipedia, 'נמל אשדוד' (Port of Ashdod, history); also Wikipedia, 'Port of Ashdod' — https://he.wikipedia.org/wiki/נמל_אשדוד — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Hebrew Wikipedia wikitext. Translation: 'On 25 October 1965 the last ships entered the ports of Jaffa and Tel Aviv, and on 3 November loading and unloading there stopped ... On 21 November [1965] the port operated for the first time for unloading and loading, with the entry of the Swedish ship Vingland.' Construction began April 1961 (cornerstone 31 July 1961) and the port was formally inaugurated in November 1963; English Wikipedia infobox: opened 1965.
  - Quote: "ב-25 באוקטובר 1965 נכנסו האוניות האחרונות לנמל יפו ולנמל תל אביב, וב-3 בנובמבר הופסקה הטעינה והפריקה בהם. ... ב-21 בנובמבר הופעל לראשונה הנמל לפריקה וטעינה, עם כניסתה של האונייה השוודית "וינגלאנד""
  - Supports:
    - The deep-water Port of Ashdod opened in 1965

**[S556]** Wikipedia, 'Ben Gurion Airport' — https://en.wikipedia.org/wiki/Ben_Gurion_Airport — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext (iaa.gov.il is JS-rendered).
  - Quote: "Terminal 3, designed by Skidmore, Owings & Merrill, opened in 2004 and replaced the original Terminal 1, which now handles domestic and low-cost international flights."
  - Supports:
    - Terminal 3 at Ben Gurion Airport opened in 2004

**[S560]** Hebrew Wikipedia, 'עמידר' (Amidar); also Wikipedia, 'Amidar (company)' — https://he.wikipedia.org/wiki/עמידר — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Hebrew Wikipedia wikitext. Translation: 'Amidar, the National Housing Company for Israel ... is a government public-housing company founded in 1949. The company had a historic role in building the country and housing the millions of immigrants who arrived over the years of the State of Israel.' English Wikipedia: 'The company was founded in 1949.' amidar.co.il was not readable.
  - Quote: "עמידר, החברה הלאומית לשיכון בישראל בע"מ ... היא חברה ממשלתית לדיור ציבורי שנוסדה בשנת 1949. לחברה תפקיד היסטורי בבניין הארץ ובשיכון מיליוני העולים שהגיעו במהלך שנות קיום מדינת ישראל"
  - Supports:
    - Amidar founded in 1949 to house new immigrants in public housing (shikunim)

**[S562]** Hebrew Wikipedia, 'מפעלי ים המלח' (Dead Sea Works) and 'פוספטים בנגב' (Negev Phosphates); also Wikipedia, 'Dead Sea Works' — https://he.wikipedia.org/wiki/מפעלי_ים_המלח — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Hebrew Wikipedia wikitext. Translation: 'The company was founded by the State of Israel in 1952 (on the basis of the Palestine Potash Company established in 1929) and produces mainly potash, bromine and its compounds.' English Wikipedia gives nationalisation in 1951 and the name 'Dead Sea Works' from 1953. Oron: Hebrew Wikipedia 'Negev Phosphates' says the company was set up in 1951 and 'the Oron field was the first that was decided to develop', with a plant built there (newspaper reports 1951-1954). The ICL history URL returned 'Page not found'.
  - Quote: "החברה נוסדה על ידי מדינת ישראל ב-1952 (על בסיס חברת האשלג הארץ-ישראלית שהוקמה ב-1929) והיא מפיקה בעיקר אשלג, ברום ותרכובותיו"
  - Supports:
    - Dead Sea Works Ltd. established in 1952; phosphate mining at Oron in the Negev from the early 1950s

**[S563]** Hebrew Wikipedia, 'שדה הנפט חלץ' (Heletz oil field); also Wikipedia, 'Heletz' — https://he.wikipedia.org/wiki/שדה_הנפט_חלץ — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Hebrew Wikipedia wikitext. Translation: 'The Lapidot company began drilling in the Huleikat fields in 1955, and on the morning of Friday 23 September, a few days before Yom Kippur that year, oil gushed from the well from a depth of 1,515 metres.' English Wikipedia 'Heletz': 'the first successful oil well in the country, with extraction beginning in 1955'.
  - Quote: "חברת "לפידות" החלה לקדוח בשדות חוליקאת ב-1955 ובבוקר יום שישי, 23 בספטמבר, ימים ספורים לפני יום כיפור אותה שנה, פרץ נפט מן הקידוח, מעומק של 1,515 מטרים."
  - Supports:
    - The Heletz-1 well (Lapidot) struck oil in September 1955

**[S564]** Wikipedia, 'Jewish National Fund' (State of Israel and forestry sections); Yatir planting date from Wikipedia, 'Yatir Forest' — https://en.wikipedia.org/wiki/Jewish_National_Fund — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext (kkl-jnf.org not readable). Wikipedia 'Yatir Forest': 'The first trees were planted in 1964 by the Jewish National Fund at the initiative of Yosef Weitz' (largest planted forest in Israel, on the edge of the Negev). The JNF article illustrates planting in the Gilboa c. 1960; it does not give a single start year for the post-1948 programme.
  - Quote: "Since its inception, the JNF has planted over 240 million trees in Israel."
  - Supports:
    - Large-scale afforestation of hill and semi-arid land from the 1950s

**[S566]** Wikipedia, 'Israel Diamond Exchange'; also Hebrew Wikipedia, 'בורסת היהלומים הישראלית' — https://en.wikipedia.org/wiki/Israel_Diamond_Exchange — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext (isde.co.il not readable). CORRECTED: 1937 is the year the first diamond-cutting factory opened, not the founding of the exchange (Hebrew Wikipedia agrees: Asher Daskal founded the first factory in Petah Tikva in spring 1937). The 1968 Ramat Gan date is confirmed.
  - Quote: "The first diamond cutting facility was opened in 1937 ( Mandatory Palestine at the time), in Petach Tikva by two cousins Asher Anshel Daskal and Zvi Rosenberg professional diamantaires trained in Antwerp, originally from Romania during the British Mandate. The industry grew over the next seven years, but between 1944 and 1948 it suffered from the increasing lawlessness and in February 1948 closed down completely, with seemingly little chance of recovery. [...]  [...] After a new start and renewed growth, by the 1960s a trade association"
  - Supports:
    - Diamond cutting began in Mandatory Palestine in 1937 (first factory in Petah Tikva); a trade association formed in the 1960s evolved into the Israel Diamond Exchange, whose Ramat Gan complex opened its first building in 1968; the export-oriented polishing industry

**[S568]** Wikipedia, 'Cherbourg Project'; also Wikipedia, 'Battle of Latakia' — https://en.wikipedia.org/wiki/Cherbourg_Project — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext. October 1973 use: Wikipedia 'Battle of Latakia': fought on 7 October 1973, 'the first naval battle in history to see combat between surface-to-surface missile-equipped missile boats'; 'The four Israeli Navy Sa'ar 3-class and one Sa'ar 4-class missile boats headed towards the Syrian port of Latakia', with Syrian Styx missiles having 'twice the range of the Israeli Gabriel anti-ship missiles'. Replaces the unopened print citation (Rabinovich, The Boats of Cherbourg).
  - Quote: "The Cherbourg Project (or Boats of Cherbourg) was an Israeli military operation that took place on 24 December 1969 and involved the escape of five remaining armed Sa'ar 3 class boats from the French port of Cherbourg ... The boats had been paid for by the Israeli government but had not been delivered due to the French arms embargo in 1969."
  - Supports:
    - Sa'ar-class missile boats built in Cherbourg (1960s), the 1969 escape of the last five, and their use with Gabriel missiles in October 1973

**[S569]** Wikipedia, 'Ben-Gurion University of the Negev' — https://en.wikipedia.org/wiki/Ben-Gurion_University_of_the_Negev — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext (bgu.ac.il returned a near-empty page). Arid-zone research: the university hosts the Jacob Blaustein Institutes for Desert Research at Sede Boqer.
  - Quote: "Ben-Gurion University was established in 1969 as the University of the Negev with the aim of promoting the development of the Negev desert, which comprises more than sixty percent of Israel."
  - Supports:
    - The university founded in Be'er Sheva in 1969 (as the University of the Negev) with a focus on arid-zone research

**[S570]** Wikipedia, '2009 Israeli legislative election'; also Wikipedia, 'Thirty-second government of Israel' and Israel Democracy Institute, 'Elections 2009' — https://en.wikipedia.org/wiki/2009_Israeli_legislative_election — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext. The IDI 'Elections 2009' page (en.idi.org.il) was also read: it describes the result (Kadima 28, Likud 27) and the President asking Netanyahu to form the government, but gives no exact dates.
  - Quote: "Legislative elections were held in Israel on 10 February 2009 to elect the 120 members of the eighteenth Knesset. [...] These elections became necessary due to the resignation of Prime Minister Ehud Olmert as leader of the Kadima party, and the failure of his successor, Tzipi Livni, to form a coalition government. Had Olmert remained in office or had Livni formed a coalition government, the elections would have be"
  - Supports:
    - The 10 February 2009 election and the government sworn in on 31 March 2009

**[S571]** Wikipedia, 'Hebrew University of Jerusalem' (history) — https://en.wikipedia.org/wiki/Hebrew_University_of_Jerusalem — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext (huji.ac.il served only a short bot-check page).
  - Quote: "The cornerstone for the university was laid on 24 July 1918. Seven years later, on 1 April 1925, the Hebrew University campus on Mount Scopus was opened at a gala ceremony attended by the leaders of the Jewish world, distinguished scholars and public figures, and British dignitaries"
  - Supports:
    - The Hebrew University opened on Mount Scopus on 1 April 1925; used for the University district present in Jerusalem at game start

**[S572]** Wikipedia, 'Technion – Israel Institute of Technology' (history) — https://en.wikipedia.org/wiki/Technion_–_Israel_Institute_of_Technology — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext (the technion.ac.il history page that was fetched did not contain the founding text).
  - Quote: "Technion's cornerstone was laid in 1912, and studies began 12 years later in 1924."
  - Supports:
    - Teaching at the Technion in Haifa began in 1924; used for the University district present in Haifa at game start

**[S573]** Wikipedia, 'Weizmann Institute of Science' (history) — https://en.wikipedia.org/wiki/Weizmann_Institute_of_Science — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext (weizmann.ac.il history page returned little text).
  - Quote: "The institute was founded in 1934 by Chaim Weizmann and his initial (1st) team, which included Benjamin M. Bloch, as the Daniel Sieff Research Institute. ... On 2 November 1949, in agreement with the Sieff family, the institute was renamed the Weizmann Institute of Science in his honor."
  - Supports:
    - The Daniel Sieff Research Institute opened in Rehovot in 1934 and was renamed the Weizmann Institute of Science in 1949

**[S574]** Wikipedia, 'Port of Haifa' (history) — https://en.wikipedia.org/wiki/Port_of_Haifa — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) builder for techs/civics/policies/governments/buildings data. Verified 2026-10-11 against Wikipedia wikitext (haifaport.co.il not readable).
  - Quote: "The city's deep-water port was developed in this period, [...] with construction beginning in 1922, and the port was officially opened on October 31, 1933, by Lt. Gen. Sir Arthur Wauchope, the British High Commissioner for Palestine"
  - Supports:
    - The modern deep-water port of Haifa opened in 1933; used for the Port district present in Haifa at game start

**[S575]** 'Treaty of Peace Between the Arab Republic of Egypt and the State of Israel', 26 March 1979, The Avalon Project, Yale Law School — https://avalon.law.yale.edu/20th_century/isregypt.asp — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim builder for gameplay data. Verified 2026-10-11 on the Avalon Project page: the treaty text is dated March 26, 1979 and witnessed by President Carter. (Avalon's page heading reads 'Treaty Between Israel and Egypt : 1973', a collection label; the treaty itself is dated 1979.)
  - Quote: "PEACE TREATY BETWEEN ISRAEL AND EGYPT March 26, 1979 The Government of the Arab Republic of Egypt and the Government of the State of Israel; PREAMBLE Convinced of the urgent necessity of the establishment of a just, comprehensive and lasting peace in the Middle East ... For the Government of Israel For the Government of the Arab Republic of Egypt Witnessed by: Jimmy Carter President of the United States of America"
  - Supports:
    - Egypt-Israel peace treaty signed 26 March 1979

**[S576]** Wikipedia, 'Jerusalem Law' (Basic Law: Jerusalem, Capital of Israel) — https://en.wikipedia.org/wiki/Jerusalem_Law — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim builder for gameplay data. Verified 2026-10-11 against Wikipedia wikitext; the Knesset site (main.knesset.gov.il) served only a bot-check page.
  - Quote: "is a common name of Basic Law: Jerusalem, Capital of Israel passed by the Knesset on 30 July 1980."
  - Supports:
    - Basic Law: Jerusalem passed 30 July 1980; part of the series of Basic Laws

**[S577]** Wikipedia, '1985 Israel Economic Stabilization Plan'; also Hebrew Wikipedia, 'תוכנית הייצוב הכלכלית של 1985' and 'המהפך הכלכלי' — https://en.wikipedia.org/wiki/1985_Israel_Economic_Stabilization_Plan — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim builder for gameplay data. Verified 2026-10-11 against Wikipedia wikitext. Hebrew Wikipedia agrees: 'On the morning of Monday, 1 July 1985, the government announced an economic plan with comprehensive and drastic measures.' The 1977 background (Hebrew Wikipedia 'המהפך הכלכלי'): the economic liberalisation programme presented by Finance Minister Simha Erlich on 29 October 1977 (supports the game's 'October 1977' date). Replaces the unopened print citation (Bruno, Crisis, Stabilization, and Economic Reform, 1993).
  - Quote: "By 1984 inflation was reaching an annual rate close to 450% and projected to reach over 1000% by the end of the following year. ... In response, on July 1, 1985, the government of Shimon Peres implemented an economic stabilization plan"
  - Supports:
    - The Economic Stabilization Plan of 1 July 1985 and the high inflation that preceded it; the 1977 exchange liberalisation as background

**[S578]** Office of the United States Trade Representative, 'Israel Free Trade Agreement' and the agreement's final text (Agreement on the Establishment of a Free Trade Area between the Government of Israel and the Government of the United States of America) — https://ustr.gov/sites/default/files/files/agreements/FTA/israel/Israel%20FTA.pdf — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim builder for gameplay data. Verified 2026-10-11. The PDF heading reads 'Entered into Force August 19, 1985'. The USTR overview page (https://ustr.gov/trade-agreements/free-trade-agreements/israel-fta) states: 'The United States-Israel Free Trade Agreement (FTA) entered into force in 1985 and represents the United States' first FTA.' The PDF was read from the Wayback copy because ustr.gov returned 502 for the file.
  - Quote: "Done in duplicate, in the Hebrew and English languages, both equally authentic, at Washington, D.C., this twenty second day of April 1985, which corresponds to this first day of Iyar, 5745."
  - Supports:
    - US-Israel Free Trade Area agreement signed 22 April 1985

**[S579]** Wikipedia, 'Alliance of the periphery' — https://en.wikipedia.org/wiki/Alliance_of_the_periphery — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim builder for gameplay data. Verified 2026-10-11 against Wikipedia wikitext. Replaces the unopened print citation (Parsi, Treacherous Alliance, 2007).
  - Quote: "The original 1958 alliance included Israel, Turkey, the Imperial State of Iran, and the Ethiopian Empire. [...] However, the policy was also applied regarding the Druze, Kurds, Baloch, Berbers, Middle Eastern Christians, and the South Sudanese. [...]  [...]  [...] According to Baruch Uziel, the alliance would overwhelm the Arabs and end their imperialism, bringing peace to non-Arab and non-Muslim communities, and ulti"
  - Supports:
    - Israel's 'periphery doctrine' of ties with non-Arab states such as Iran and Turkey from the late 1950s until 1979

**[S580]** IDE Technologies, 'Ashkelon Desalination Plant (Israel)' (project page) — https://ide-tech.com/en/project/ashkelon-desalination-plant/ — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim builder for gameplay data. Verified 2026-10-11 on the IDE Technologies project page (also: 'Desalination Plant of the Year 2006, Global Water Intelligence').
  - Quote: "Technology: Reverse Osmosis (RO) Water Source: Sea Water Contract Type: BOT for 25 years Location: Ashkelon, Israel Customer: Israel Water Authority ... Usage: Potable Water Commissioning date: 2005"
  - Supports:
    - The Ashkelon seawater reverse-osmosis plant began operating in 2005

**[S581]** Wikipedia, '2006 Israeli legislative election'; also Wikipedia, 'Thirty-first government of Israel' and Israel Democracy Institute, 'Elections 2006' — https://en.wikipedia.org/wiki/2006_Israeli_legislative_election — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim builder for gameplay data. Verified 2026-10-11 against Wikipedia wikitext. Government date from Wikipedia 'Thirty-first government of Israel': 'The thirty-first government of Israel was formed by Ehud Olmert on 4 May 2006, following Kadima's victory in the March elections.' The IDI 'Elections 2006' page was also read (Kadima 29 seats; coalition of Kadima, Labor, Shas and Gil) but gives no exact dates.
  - Quote: "Elections for the 17th Knesset were held in Israel on 28 March 2006. The voting resulted in a plurality of seats for the then-new Kadima party, followed by the Labor Party, and a major loss for the Likud party."
  - Supports:
    - The 28 March 2006 election won by Kadima; Ehud Olmert's government sworn in on 4 May 2006

**[S582]** Wikipedia, 'East Jerusalem' (section on demographics), citing the Israeli census of 1967 — https://en.wikipedia.org/wiki/East_Jerusalem — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim builder for per-city population calibration. Secondary source; the figure is from the 1967 Israeli census.
  - Quote: "In the 1967 census, the Israeli authorities registered 66,000 Palestinian residents (44,000 residing in the area known before the 1967 war as East Jerusalem; and 22,000, in the West Bank area annexed to Jerusalem after the war)."
  - Supports:
    - 66,000 residents of East Jerusalem and the annexed West Bank area added to Jerusalem's municipal population in June 1967 (real_series.json city_joins)

**[S583]** World Bank, World Development Indicators, FP.CPI.TOTL.ZG 'Inflation, consumer prices (annual %)', Israel, 1960-2025 (API, last updated 2026-10-08) — https://api.worldbank.org/v2/country/ISR/indicator/FP.CPI.TOTL.ZG?format=json&per_page=100 — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim builder. Downloaded and read.
  - Supports:
    - Israel annual-average CPI inflation 1960-2025: the backdrop of the inflation mechanic and the real-world label (real_series.json 'inflation')

**[S584]** Wikipedia, '1985 Israel Economic Stabilization Plan', citing Bruno and Minford, 'Sharp Disinflation Strategy: Israel 1985', Economic Policy 1(2), 1986, pp. 379-407 — https://en.wikipedia.org/wiki/1985_Israel_Economic_Stabilization_Plan — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim builder for the inflation mechanic.
  - Quote: "By 1984 inflation was reaching an annual rate close to 450% and projected to reach over 1000% by the end of the following year."
  - Supports:
    - Hyperinflation peaking near 450% (annualised) in 1984; the 1 July 1985 plan brought inflation under 20% within two years

**[S585]** Wikipedia, 'Tel Aviv' (history section), citing Golan (1995) — https://en.wikipedia.org/wiki/Tel_Aviv — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim builder for gameplay data.
  - Quote: "The government voted on the unification of Tel Aviv and Jaffa on 4 October 1949, but the decision was not implemented until 24 April 1950 due to the opposition of Tel Aviv mayor Israel Rokach"
  - Supports:
    - The city is named Tel Aviv until 19 August 1950 and Tel Aviv-Yafo afterwards (governments.json city_names)

**[S586]** Jewish Telegraphic Agency, 'Knesset Proclaims Jerusalem As Israel's Capital; Mapam and Herut Abstain from Voting', Daily Bulletin, 25 January 1950 — https://www.jta.org/archive/knesset-proclaims-jerusalem-as-israels-capital-mapam-and-herut-abstain-from-voting — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim builder for gameplay data. The bulletin is dated 25 January 1950 and reports the vote of the previous night; the vote is commonly dated 23 January 1950.
  - Quote: "A proclamation declaring that Jerusalem became the capital of Israel with the establishment of the Jewish state was adopted last night in the parl[iament]"
  - Supports:
    - The Knesset proclaimed Jerusalem the capital in late January 1950 (capital rail moves from Tel Aviv to Jerusalem on 23 January 1950)

**[S587]** Wikipedia, 'Habima Theatre' — https://en.wikipedia.org/wiki/Habima_Theatre — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim builder for gameplay data.
  - Quote: "The company finally settled in Palestine in 1931. [...] In 1945, it built a theatre in Tel Aviv, which it occupied before completion."
  - Supports:
    - A Cultural Center district with a Theatre in Tel Aviv at game start (Habima, in Tel Aviv from 1931; building 1945)

**[S588]** Jewish Telegraphic Agency, 'Facts About Israel Bonds', 8 June 2000 — https://www.jta.org/archive/facts-about-israel-bonds — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim builder for gameplay data.
  - Quote: "The Knesset voted to launch Israel's first bond issue in February 1951. [...] In March of that year, Ben-Gurion launched a bond drive at Madison Square Garden in New York."
  - Supports:
    - Israel Bonds launched in 1951 (Knesset vote February 1951; Ben-Gurion's drive in New York); used for the diaspora bonds stream after refusing reparations and for the reparations-use fork

**[S589]** Wikipedia, 'Society for the Protection of Nature in Israel' — https://en.wikipedia.org/wiki/Society_for_the_Protection_of_Nature_in_Israel — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim builder for the 1948-1965 forks (advocate evidence).
  - Quote: "in response to plans to drain the Hula Valley"
  - Supports:
    - SPNI founded in 1953 by Azaria Alon and Amotz Zahavi in response to plans to drain the Hula Valley (advocates of keeping the wetland)

**[S590]** Wikipedia, 'Rafi (political party)' — https://en.wikipedia.org/wiki/Rafi_(political_party) — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim builder for the 1948-1965 forks (advocate evidence).
  - Quote: "Ben-Gurion did not agree to declaring Lavon innocent without judicial investigation committee. [...] ran for the 1965 elections on a platform of changing the electoral systems"
  - Supports:
    - Ben-Gurion demanded a judicial inquiry before clearing Lavon
    - Rafi (founded 14 July 1965) campaigned for changing the electoral system

**[S591]** Wikipedia, 'Negev Nuclear Research Center' (section 'Inspections') — https://en.wikipedia.org/wiki/Negev_Nuclear_Research_Center — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim builder for the 1948-1965 forks (advocate evidence).
  - Quote: "the U.S. government requested that Israel agree to international inspections"
  - Supports:
    - The US asked Israel to accept international inspections of Dimona

**[S592]** Wikipedia, 'National Water Carrier of Israel' (Johnston Plan), citing Gat, Britain and the Conflict in the Middle East, 1964-1967 (2003), p. 101 — https://en.wikipedia.org/wiki/National_Water_Carrier_of_Israel — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim builder for the 1948-1965 forks (advocate evidence).
  - Quote: "would be divided between Israel (40%), Jordan (45%) and Syria and Lebanon (15%)"
  - Supports:
    - The Johnston Plan's division of Jordan basin water

**[S593]** Wikipedia, 'Johnston Plan', citing Murakami, Managing Water for Peace in the Middle East, UNU Press, 1995 — https://en.wikipedia.org/wiki/Johnston_Plan — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim builder for the 1948-1965 forks (advocate evidence).
  - Quote: "Eisenhower appointed Eric Johnston as a special ambassador on 16 October 1953"
  - Supports:
    - Eric Johnston's mission (1953-55) to negotiate a unified Jordan Valley water plan

**[S594]** Jewish Virtual Library (AICE), 'International Recognition of Israel' — https://www.jewishvirtuallibrary.org/international-recognition-of-israel — accessed: 2026-10-12 — provenance: opened
  - Note: Used for the diplomacy status rails in game/data/actors.json (relations from these dates).
  - Quote: "Three days later, the USSR granted Israel de-jure recognition."
  - Supports:
    - Recognition dates: Russia (USSR) May 17 [1948]; France January 24 [1949]; Turkey March 28 [1949]; Iran March 14, 1950 (footnote: recognition later rescinded)

**[S595]** Clyde Haberman, 'Israel and Soviets Restore Full Relations', The New York Times, 19 October 1991; Yosef Govrin, Israeli-Soviet Relations, 1953-1967: From Confrontation to Disruption, Frank Cass, 1998, p. 317 — https://www.nytimes.com/1991/10/19/world/israel-and-soviets-restore-full-relations.html — accessed: n/a — provenance: not_opened
  - Note: Located via the citations of the Wikipedia article 'Israel-Russia relations' (notes 25 and 28); not opened by the sim builder (site not fetchable) - verify.
  - Supports:
    - The Soviet Union severed diplomatic relations with Israel in June 1967 (Six-Day War) and restored full relations on 18 October 1991

**[S596]** Herbert L. Matthews, 'British Recognize Regime in Tel Aviv; 4 Other Lands Act - de Facto Move on Israel', The New York Times, 30 January 1949 — https://www.nytimes.com/1949/01/30/archives/british-recognize-regime-in-tel-aviv-4-other-lands-act-de-facto.html — accessed: n/a — provenance: not_opened
  - Note: Located via the citations of the Wikipedia article 'Israel-United Kingdom relations' (note 35); not opened by the sim builder - verify.
  - Supports:
    - The United Kingdom recognised Israel de facto on 29 January 1949

**[S600]** Jewish Telegraphic Agency, 'Dayan Says He Will Not Participate in the Next Cabinet' (Feb 1974) — https://www.jta.org/archive/dayan-says-he-will-not-participate-in-the-next-cabinet — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the forks-1966-1985 data agent; page opened with WebFetch on 2026-10-11.
  - Quote: "tantamount to confessing responsibility"
  - Supports:
    - Dayan said he would not quit the interim government under pressure, as resigning would be tantamount to confessing responsibility for the failures at the start of the Yom Kippur War; Capt. Mordechai (Motti) Ashkenazi staged a solo demonstration demanding Dayan's removal, with several Labor MKs backing it

**[S601]** Christian Science Monitor, "Israel's defense minister: superhawk turned quasi-dove" (profile of Ezer Weizman), 23 Apr 1980 — https://www.csmonitor.com/layout/set/amphtml/1980/0423/042348.html — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the forks-1966-1985 data agent; page opened with WebFetch on 2026-10-11.
  - Quote: "argued for renewal of all-out war against Egypt"
  - Supports:
    - Weizman, as chief of operations during the War of Attrition, argued for renewing all-out war against Egypt and doubted a strategy of digging in on the Bar-Lev Line with the air force alone raiding deep in Egypt

**[S602]** Christian Science Monitor, 'Invasion of Lebanon postponed; Israeli sword lowered - but ready', 20 May 1982 — https://csmonitor.com/1982/0520/052051.html — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the forks-1966-1985 data agent; page opened with WebFetch on 2026-10-11.
  - Quote: "the large minority within the Cabinet opposed to it"
  - Supports:
    - In May 1982 Begin's government postponed a planned invasion of Lebanon partly because of a large cabinet minority opposed to it and the Labor opposition's refusal to back it

**[S603]** Rosa Luxemburg Foundation Israel, 'Greater Israel: From Political Ideology to Territorial Practice' — https://www.rosalux.org.il/eng/politics/greater-israel-from-political-ideology-to-territorial-practice/ — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the forks-1966-1985 data agent; page opened with WebFetch on 2026-10-11.
  - Quote: "we are enjoined to sustain what we have received from it: The Land of Israel"
  - Supports:
    - A signed advertisement of 22 September 1967 (Alterman, Tabenkin, Agnon and others) called on the government to keep the 1967 gains for the long term

**[S604]** Gershom Gorenberg, 'Israel's Tragedy Foretold', The New York Times, 10 March 2006, via History News Network (NYT Roundup) — https://www.historynewsnetwork.org/article/22741 — accessed: 2026-10-12 — provenance: opened
  - Note: Registered by the sim builder from the fork_1968_hebron cite (url and quote supplied by the 1966-1985 data author; quote verified by tools/check_fork_quotes.py).
  - Quote: "My conclusion is that civilian settlement in the administered territories contravenes the explicit provisions"
  - Supports:
    - Theodor Meron, Foreign Ministry legal counsel, advised in 1967 that civilian settlement in the administered territories contravened the Fourth Geneva Convention (quoted by Gorenberg)

**[S630]** Moffett, George D., III, 'Israeli foresees more unrest', The Christian Science Monitor, 9 Feb 1988 (interview with Defence Minister Rabin) — https://www.csmonitor.com/1988/0209/orab.html — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "I brought about a change in policy to use force on a large scale, including hitting to replace the use of firearms."
  - Supports:
    - Rabin's January 1988 shift to force on a large scale to suppress the first intifada

**[S631]** Goldberg, Arthur J., 'The climb toward Mideast peace', The Christian Science Monitor, 4 Oct 1988 — https://www.csmonitor.com/1988/1004/ebank.html — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "Shamir is against the proposed international conference, fearing that such a conference would seek to impose a settlement on Israel. ... His proposal is land for peace, and he supports an international conference."
  - Supports:
    - Shamir (Likud) rejected and Peres (Labor) backed an international conference in 1988

**[S632]** Wayne, E.A., 'Shamir Deals Setback to US Hopes', The Christian Science Monitor, 11 Jul 1989 — https://www.csmonitor.com/1989/0711/aliku.html — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "the Israeli government's earlier proposal for elections in the West Bank and Gaza"
  - Supports:
    - Shamir government's 1989 proposal for elections in the West Bank and Gaza

**[S633]** Israel Hayom, 'The real Yitzhak Shamir' (interview with Moshe Arens), 6 Jul 2012 — https://www.israelhayom.co.il/article/55004 — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "We could have sent IAF planes to western Iraq to spot the missile launchers and destroy them ... Shamir dispatched him to Washington to present President George H.W. Bush with an Israeli plan for a military offensive in western Iraq. ... Moshe Arens, who was defense minister during the Gulf War ... Shamir did veto calls for a military response that were being sounded by IDF brass"
  - Supports:
    - Options debated in the 1991 Gulf War: air strike, joint operation, restraint; Defence Minister Arens's western-Iraq plan; IDF brass called for a military response

**[S634]** 'Israel's Capacity for Restraint', The Christian Science Monitor editorial, 1 Feb 1991 — https://www.csmonitor.com/1991/0201/eis.html — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "We hope Israel continues to withstand pressures to strike back quickly."
  - Supports:
    - Israel had not retaliated for the Scud attacks by 1 Feb 1991 under US pressure

**[S635]** Moffett, George D., III, 'US to Israel: Stop Building Settlements Or Lose Guarantees', The Christian Science Monitor, 27 Jan 1992 — https://csmonitor.com/1992/0127/27092.html — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "Mr. Baker made it clear that Israel cannot have both. ... No force in the world will stop this construction"
  - Supports:
    - Baker tied up to $10 billion in loan guarantees to limits on settlements; Shamir's refusal

**[S636]** Ford, Peter, 'Israelis Signal Quiet Shift On Settlement Activities', The Christian Science Monitor, 10 Feb 1992 — https://proof.csmonitor.com/1992/0210/10062.html — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "The US is insisting on a freeze on settlement building, after the units being constructed have been finished, in return for the loan guarantees."
  - Supports:
    - US terms for loan guarantees, Feb 1992

**[S637]** Sachar, Howard M., 'The Madrid Conference' (excerpt from A History of Israel), My Jewish Learning — https://www.myjewishlearning.com/article/the-madrid-conference/ — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "it would be subsumed in that of the Jordanians, and, at that, would not include PLO members ... He rejected Baker’s persistent appeal for a moratorium on Jewish settlement in the West Bank."
  - Supports:
    - Terms of the Madrid conference and Shamir's refusal of a settlement moratorium

**[S638]** Adams, Paul, 'Shamir's Fragile Coalition Appears Near to Breaking', The Christian Science Monitor, 17 Jan 1992 — https://www.csmonitor.com/1992/0117/17062.html — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "had repeatedly threatened to quit the government if Palestinian autonomy was discussed at the peace talks"
  - Supports:
    - Tehiya and Moledet left Shamir's coalition over the peace talks

**[S639]** Israel State Archives, 'Secret negotiations with the PLO and the signing of the Declaration of Principles in Washington, January-September 1993' (The Road to Oslo) — https://catalog.archives.gov.il/site/en/chapter/secret-negotiations-with-the-plo-and-the-signing-of-the-declaration-of-principles-in-washington-january-september-1993 — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "Rabin was resistant to new ideas and preferred the Washington talks and the Syrian channel sponsored by the US ... Rabin agreed to continue the negotiations in Norway"
  - Supports:
    - Rabin's preference for the Washington and Syrian tracks and his acceptance of the Norway channel

**[S640]** Sachar, Howard M., 'Oslo Negotiations' (excerpt from A History of Israel), My Jewish Learning — https://www.myjewishlearning.com/article/oslo-negotiations/ — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "sensing that the bilateral discussions in Washington had reached a dead end, Beilin brought the proposal to Peres. The foreign minister did not veto it."
  - Supports:
    - Beilin and Peres launched the unofficial Oslo channel

**[S641]** Global Entrepreneurship Network, 'Yozma' (programme atlas entry) — https://www.genglobal.org/atlas/yozma — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "The 40% public share was conditional on attracting at least 60% private capital and a reputable foreign financial partner"
  - Supports:
    - Structure of the 1993 Yozma programme

**[S642]** Bashan, Tsafrir, 'Yigal Erlich, Yozma', Globes, 16 Sep 2001 — https://en.globes.co.il/en/article-522515 — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "The activity that Erlich initiated at the end of 1992 while serving as Chief Scientist at the Industry and Trade Ministry gave birth to ten entrepreneurial funds. ... it was Erlich who established the government incubator program"
  - Supports:
    - Erlich initiated Yozma as Chief Scientist and also created the incubator programme

**[S643]** Ain, Stewart, 'Lebanon Fires Up Campaign', Jewish Telegraphic Agency, 5 Mar 1999 — https://jta.org/?p=1796190 — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "vowed to withdraw Israeli troops from Lebanon by June 2000, within the context of negotiations with Syria"
  - Supports:
    - Barak's 1999 pledge to leave Lebanon by June 2000

**[S644]** 'News Analysis: Barak Faces Internal Dissension in Wake of Latest Peace Obstacles', Jewish Telegraphic Agency, 15 Feb 2000 — https://www.jta.org/archive/news-analysis-barak-faces-internal-dissension-in-wake-of-latest-peace-obstacles — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "Barak got strong support for his strategy from his foreign minister, David Levy, and from Education Minister Yossi Sarid. ... Justice Minister Yossi Beilin, a longtime advocate of a unilateral Israeli withdrawal from Lebanon"
  - Supports:
    - Cabinet debate on Syria-first versus unilateral withdrawal from Lebanon, Feb 2000

**[S645]** 'NRP, Yisrael Ba'aliya and Shas Quit the Government', Yated Ne'eman staff, Dei'ah veDibur, 12 Jul 2000 — https://chareidi.org/archives5760/bolok/acoaltn.htm — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "Shas announced it was withdrawing from the coalition because Barak was unwilling to confide in its leadership about the red lines that will guide him at the summit."
  - Supports:
    - Shas, NRP and Yisrael Ba'aliya (with Minister Sharansky) quit the coalition before Camp David over Barak's red lines

**[S646]** Malley, Robert and Hussein Agha, 'Camp David: The Tragedy of Errors', The New York Review of Books, 9 Aug 2001 — https://www.nybooks.com/articles/2001/08/09/camp-david-the-tragedy-of-errors/ — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "Barak discarded a number of interim steps, even those to which Israel was formally committed by various agreements ... And Arafat got blamed in no uncertain terms. ... there was neither additional preparation before the summit, nor a third redeployment"
  - Supports:
    - Barak's all-or-nothing approach at Camp David; the Palestinian leadership (Arafat) pressed for preparation and interim steps such as a third redeployment

**[S647]** Keinon, Herb, 'How Operation Defensive Shield changed Israel's security reality', The Jerusalem Post, 14 Apr 2022 (interview with Shaul Mofaz) — https://jpost.com/israel-news/article-704238 — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "still believed there was a chance for negotiations and an agreement with the Palestinians"
  - Supports:
    - Defence Minister Ben-Eliezer's reluctance to enter Area A before the Park Hotel attack

**[S648]** 'What to Do About Arafat?', Jewish Journal, 4 Apr 2002 — https://jewishjournal.com/date/2002/04/04/page/2/ — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "when Sharon raised the idea of exile, he was met by a chorus of dissent ... he was adamantly opposed to expelling Arafat, and Labor would leave the government if the step was approved"
  - Supports:
    - Sharon's push to expel Arafat and the cabinet's compromise

**[S649]** 'Yesha Leaders Plan Major Campaign Against "Political" Fence', Israel National News (Arutz Sheva), 13 Jun 2002 — https://www.israelnationalnews.com/news/25124 — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "They are concerned that the planned partition, though ostensibly designed to protect the security of Israelis in pre-1967 Israel, will be built along the Green Line and thus represent a de-facto return to the 1967 borders. ... Defense Minister Binyamin Ben-Eliezer"
  - Supports:
    - Settler-aligned opposition to the barrier along the Green Line ordered by Defence Minister Ben-Eliezer, June 2002

**[S650]** 'Landau Holds Key To Fence, Grassroots Group Believes', Israel National News (Arutz Sheva), 26 Jun 2002 — https://www.israelnationalnews.com/news/25851 — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "plan to fence in the terrorist cities instead of fencing off the entire Judea and Samaria ... rallying around Likud MK Michael Eitan ... The Yesha Council has prepared its own plan"
  - Supports:
    - MK Michael Eitan's and the Yesha Council's alternative of fencing the cities only

**[S651]** 'Winding Fence is a Complex Issue', Israel National News (Arutz Sheva), 2 Oct 2003 — https://www.israelnationalnews.com/news/50585 — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "The fence will be built, in its next stage, east of Ariel and Kedumim"
  - Supports:
    - October 2003 cabinet route including Ariel and Kedumim

**[S652]** Gottlieb, Ori, 'Two cheers for Netanyahu', Globes, 10 Apr 2005 — https://en.globes.co.il/en/article-902980 — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "a plan that was wholly capitalistic ... Netanyahu engaged in a direct confrontation with Histadrut chairman MK Amir Perez (One Nation), and the country's powerful workers committees."
  - Supports:
    - Netanyahu's 2003 recovery plan and the Histadrut confrontation

**[S653]** Associated Press, 'Sharon determined on Gaza pull out plan', The Daily Star (Lebanon), 3 May 2004 — https://archive.thedailystar.net/2004/05/03/d405031301103.htm — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "Sharon argues that this would give Israel defensible borders and reduce friction with the Palestinians in the absence of a final peace deal."
  - Supports:
    - Sharon's rationale for unilateral disengagement

**[S654]** Reuters, 'Gaza pullout vote hangs in the balance', Al Jazeera, 2 May 2004 — https://www.aljazeera.com/news/2004/5/2/gaza-pullout-vote-hangs-in-the-balance — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "Likud has traditionally opposed giving up any land captured in war with Arabs"
  - Supports:
    - Likud and settler opposition to the disengagement plan

**[S655]** Pace, Sonja, 'Palestinians / Peace', Voice of America, 31 Mar 2004 — https://www.globalsecurity.org/military/library/news/2004/03/mil-040331-3ee8456d.htm — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "it should be done in coordination with the Palestinian Authority and as part of broader peace negotiations"
  - Supports:
    - Palestinian PM Qureia's position on Israeli withdrawal from Gaza

**[S656]** Berger, Matthew E., 'The road map', Jewish Journal / JTA, 29 May 2003 — https://jewishjournal.com/?p=7981 — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "it passed in a 12-7 vote, with four abstentions ... We are not planning on making any changes to the road map ... Powell said in Paris May 23"
  - Supports:
    - Israeli cabinet's 12-7 approval of the Road Map with reservations; US Secretary of State Powell's position

**[S657]** GlobalSecurity.org, 'Operation Accountability' — https://www.globalsecurity.org/military/world/war/lebanon-accountability.htm — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "Katyusha rockets launched by Hizballah caused injuries and damage in Kiryat Shmonah"
  - Supports:
    - Background and front geography of Operation Accountability, July 1993

**[S658]** Human Rights Watch, 'Civilian Pawns: Laws of War Violations and the Use of Weapons on the Israel-Lebanon Border', May 1996 — https://www.hrw.org/legacy/reports/1996/Israel.htm — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "Hizballah also violated the laws of war, indiscriminately firing Katyusha rockets into northern Israel and the Israeli-occupied area in southern Lebanon, killing and injuring a number of civilians."
  - Supports:
    - Hezbollah rocket fire on northern Israel and Israeli fire on south Lebanon, 1993-1996

**[S659]** Silver, Eric, 'Israel clears first hurdle, but vast obstacles lie ahead', The Independent, 26 May 2003 (reprinted by Baha'i Library) — https://bahai-library.com/newspapers/2003/030526.html — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the 1986-2005 forks/wars data agent; page opened via curl with a browser user-agent and quote checked against the page text.
  - Quote: "Three of his Likud party ministers - Uzi Landau, Yisrael Katz and the former Soviet dissident Natan Sharansky - voted against the cabinet resolution."
  - Supports:
    - Likud ministers Landau, Katz and Sharansky voted against the Road Map; Netanyahu abstained

**[S660]** Mail & Guardian (Reuters/AP wire), 'Israel to expand Lebanon war', 9 August 2006 — https://mg.co.za/article/2006-08-09-israel-to-expand-lebanon-war — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) data agent for forks 2006-2026; page opened and quote verified.
  - Supports:
    - Security cabinet vote of 9 Aug 2006 to widen the ground offensive toward the Litani: 9 in favour, 3 abstentions
    - Defence Minister Peretz proposed the expansion; Israeli media said Olmert feared heavy casualties

**[S661]** Christian Science Monitor, 'Israel vows to expand its ground offensive', 10 August 2006 — https://csmonitor.com/2006/0810/p25s01-wome.html — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) data agent for forks 2006-2026; page opened and quote verified.
  - Supports:
    - Lebanese PM Siniora's offer of about 15,000 Lebanese Army troops for the south, which Olmert said he was studying (Aug 2006)

**[S662]** Voice of America via GlobalSecurity.org, report on the Israeli security cabinet decision, 9 August 2006 — https://www.globalsecurity.org/military/library/news/2006/08/mil-060809-voa05.htm — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) data agent for forks 2006-2026; page opened and quote verified.
  - Supports:
    - Peretz as proponent of expanding ground operations to the Litani River

**[S663]** Moment Magazine, 'Inside the Iron Dome' — https://momentmag.com/inside-the-iron-dome/ — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) data agent for forks 2006-2026; page opened and quote verified.
  - Supports:
    - Peretz's 2007 backing of Rafael's interceptor over Northrop Grumman's Nautilus laser; General Staff scepticism; July 2007 government approval and 23 Dec 2007 Security Cabinet approval

**[S664]** Attila Somfalvi, 'Cabinet approves Trajtenberg Report', Ynetnews, 9 October 2011 — https://www.ynetnews.com/article/4133108 — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) data agent for forks 2006-2026; page opened and quote verified.
  - Supports:
    - Cabinet vote 21-8 on the Trajtenberg Report; Barak's and Steinitz's positions on the defence budget; Leef's and Shmueli's criticism

**[S665]** Christian Science Monitor, 'Former Israeli spy chief talks down strike on Iran nuclear sites as stupidest idea', 9 March 2012 — https://www.csmonitor.com/World/terrorism-security/2012/0309/Former-Israeli-spy-chief-talks-down-strike-on-Iran-nuclear-sites-as-stupidest-idea — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) data agent for forks 2006-2026; page opened and quote verified.
  - Supports:
    - Meir Dagan's March 2012 CBS interview against a strike on Iran; Netanyahu's Washington visit to seek support for a strike

**[S666]** Human Rights Watch, 'Israel: Drop Detention Policy in Disguise', 18 December 2013 — https://www.hrw.org/news/2013/12/18/israel-drop-detention-policy-disguise — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) data agent for forks 2006-2026; page opened and quote verified.
  - Supports:
    - 2012 amendment allowing detention of 'infiltrators' for up to three years; September 2013 High Court ruling; Holot; asylum claims not processed; interior minister's third-country deportation plan

**[S667]** JTA via St. Louis Jewish Light, 'Boehner invites Netanyahu to address Congress on Iran', January 2015 — https://stljewishlight.org/world-news/boehner-invites-netanyahu-to-address-congress-on-iran — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) data agent for forks 2006-2026; page opened and quote verified.
  - Supports:
    - Speaker Boehner's invitation to Netanyahu to address Congress on Iran; Netanyahu accepted

**[S668]** World Jewish Congress, 'Boehner invitation to Netanyahu to address US Congress causes division with White House', January 2015 — https://www.worldjewishcongress.org/en/news/boehner-invitation-to-netanyahu-to-address-us-congress-causes-division-with-white-house — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) data agent for forks 2006-2026; page opened and quote verified.
  - Supports:
    - Pelosi's and the White House's objections to the timing of Netanyahu's Congress address

**[S669]** Al Jazeera, 'Israeli opposition challenges controversial nation-state law', 8 August 2018 — https://www.aljazeera.com/news/2018/08/israeli-opposition-questions-controversial-nation-state-law-180808193720861.html — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) data agent for forks 2006-2026; page opened and quote verified.
  - Supports:
    - Opposition demand for an equality provision; Livni's wording; Druze protest in Rabin Square

**[S670]** Israel Hayom, 'Ra'am official: We will support a Netanyahu coalition from outside', 31 March 2021 — https://israelhayom.com/2021/03/31/raam-official-we-will-support-a-netanyahu-coalition-from-outside — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) data agent for forks 2006-2026; page opened and quote verified.
  - Supports:
    - Ra'am's position on outside support for a Netanyahu-led coalition; Smotrich's rejection of cooperation with Abbas

**[S671]** i24NEWS via Ynetnews, 'Netanyahu calls Lebanon deal historic surrender', 11 October 2022 — https://www.ynetnews.com/article/b1asrmx7o — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) data agent for forks 2006-2026; page opened and quote verified.
  - Supports:
    - Netanyahu's opposition to the maritime agreement; Interior Minister Shaked's demand for Knesset approval

**[S672]** Labour Friends of Israel, 'In Brief: Lapid refutes Netanyahu criticism of Lebanon maritime deal', October 2022 — https://www.lfi.org.uk/in-brief-lapid-refutes-netanyahu-criticism-of-lebanon-maritime-deal/ — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) data agent for forks 2006-2026; page opened and quote verified.
  - Supports:
    - Lapid's defence of the maritime agreement

**[S673]** JNS, 'Coalition, opposition leaders reject judicial reform compromise', 2023 — https://www.jns.org/israel-news/coalition-leaders-reject-judicial-reform-compromise — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) data agent for forks 2006-2026; page opened and quote verified.
  - Supports:
    - President Herzog's brokered judicial-reform compromise talks; Levin and Ben-Gvir rejections

**[S674]** RETIRED (no longer cited; cited only by content dated after Q3 2023, deleted 2026-10-14 (the game ends 7 Oct 2023)) — JNS, 'Israel's High Court rules government must draft ultra-Orthodox', 25 June 2024 — https://www.jns.org/israel-news/israels-high-court-rules-government-must-draft-ultra-orthodox

**[S675]** RETIRED (no longer cited; cited only by content dated after Q3 2023, deleted 2026-10-14 (the game ends 7 Oct 2023)) — Jewish Virtual Library, 'Prime Minister Netanyahu Announces Operation Roaring Lion' (PMO statement of 28 February 2026) — https://jewishvirtuallibrary.org/prime-minister-netanyahu-announces-operation-roaring-lion

**[S676]** RETIRED (no longer cited; cited only by content dated after Q3 2023, deleted 2026-10-14 (the game ends 7 Oct 2023)) — Israel Hayom, 'Iran FM Araqchi to meet Witkoff in Geneva Thursday', 22 February 2026 — https://www.israelhayom.com/2026/02/22/araqchi-witkoff-geneva-iran-nuclear-talks/

**[S677]** RETIRED (no longer cited; cited only by content dated after Q3 2023, deleted 2026-10-14 (the game ends 7 Oct 2023)) — Reuters via Al-Monitor, 'Israeli opposition leader Lapid backs strikes on Iran, calls for regime change', 28 February 2026 — https://www.al-monitor.com/originals/2026/02/israeli-opposition-leader-lapid-backs-strikes-iran-calls-regime-change

**[S678]** Globes, 'Cabinet approves Sheshinski gas tax hike', January 2011 — https://en.globes.co.il/en/article-1000617432 — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) data agent for forks 2006-2026; page opened and quote verified.
  - Supports:
    - Cabinet approval of the Sheshinski committee's oil and gas tax recommendations; Netanyahu's plan for a fund

**[S679]** Globes, 'Netanyahu to formulate Sheshinski compromise', 2011 — https://en.globes.co.il/en/article-1000614110 — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) data agent for forks 2006-2026; page opened and quote verified.
  - Supports:
    - Netanyahu's plan for a national fund for gas revenues, in line with Governor Fischer's Norwegian-model recommendation

**[S680]** Globes, 'Fischer backs oil, gas tax proposals', 11 November 2010 — https://en.globes.co.il/en/article-1000600450 — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) data agent for forks 2006-2026; page opened and quote verified.
  - Supports:
    - Reactions to the Sheshinski interim report: Fischer, Yacimovich, Gafni and the oil and gas industry association

**[S681]** Globes, 'Politicians thwart Gamzu as Covid-19 cases rise sharply', September 2020 — https://en.globes.co.il/en/article-1001340704 — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the sim (gameplay) data agent for forks 2006-2026; page opened and quote verified.
  - Supports:
    - Gamzu's traffic-light proposal and the Haredi ministers' and MKs' opposition

**[S690]** Jewish Telegraphic Agency, 'Israeli Government Announces Food Rationing: Introduction of Compulsory Saving', 15 May 1949 — https://www.jta.org/archive/israeli-government-announces-food-rationing-introduction-of-compulsory-saving — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the forks-1948-1965 data agent; page opened and quote checked on 2026-10-11.
  - Quote: "Dr. Dov Joseph, Minister of Food and Supply, told representatives of the press that the monthly consumption of food under the new austerity diet will cost about six pounds"
  - Supports:
    - Austerity programme approved by the Knesset in May 1949: daily ration of 360 g bread, 58 g sugar, 25 g meat and 12 eggs a month; Minister of Food and Supply Dov Yosef (Joseph) presented it as improving public health

**[S691]** Jewish Independent (Canada), 'Israel's decade of austerity' (summarising historian Mordechai Naor and Seidman) — https://www.jewishindependent.ca/israels-decade-of-austerity/ — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the forks-1948-1965 data agent; page opened and quote checked on 2026-10-11.
  - Quote: "rightist General Zionists and Herut claimed the program interfered with both private initiative and the middle class"
  - Supports:
    - Mapai coalition backed austerity; Mapam objected that workers' voices were ignored; General Zionists and Herut said it hampered private initiative and the middle class; a black market appeared and a special unit was set up in 1950; Ben-Gurion gradually repealed the plan from 1952 and it ended by 1959

**[S692]** Washington Report on Middle East Affairs, 'Middle East History: 1949 Lausanne Conference Seals Fate of Palestine', April 1996 — https://www.wrmea.org/1996-april/middle-east-history-1949-lausanne-conference-seals-fate-of-palestine.html — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the forks-1948-1965 data agent; page opened and quote checked on 2026-10-11.
  - Quote: "the U.S. government relies upon it to take responsible and positive action concerning Palestine refugees"
  - Supports:
    - In May 1949 President Truman sent Israel a message pressing it to take responsible action on Palestinian refugees; Israel refused to allow return outside a settlement (the article is critical of Israel's stance; used for the US request and the Israeli position)

**[S693]** Economic Cooperation Foundation (ECF), 'Lausanne Conciliation Conference (1949)', Interactive Database — https://ecf.org.il/issues/issue/195 — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the forks-1948-1965 data agent; page opened and quote checked on 2026-10-11.
  - Quote: "calling on Israel to allow the return of Palestinian refugees"
  - Supports:
    - Lausanne conference 27 Apr-12 Sep 1949 opened with a protocol basing talks on UNGA Res 181 and 194 (194 calls on Israel to allow return of refugees); Israel proposed annexing the Gaza Strip; no agreement

**[S694]** Institute for National Security Studies (INSS), Strategic Assessment, 'Debates Surrounding the Conscription of Yeshiva Students in the Early Years Following the Establishment of the State of Israel' — https://www.inss.org.il/strategic_assessment/recruitment-of-yeshiva-students/ — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the forks-1948-1965 data agent; page opened and quote checked on 2026-10-11.
  - Quote: "issued an order to conscript to the army yeshiva students who were not seriously studying at the yeshiva"
  - Supports:
    - In 1954 Defence Minister Lavon ordered conscription of yeshiva students not seriously studying; Chief Rabbi Herzog protested to PM Sharett; Sharett wrote that only students who did not study seriously were affected and set up a ministerial committee; Ben-Gurion wrote that the growing number of students required a change in the system of exemptions

**[S695]** Jewish Telegraphic Agency, 'Israel Ministry of Justice Decides to Hold Eichmann Trial in Jerusalem', 3 June 1960 — https://www.jta.org/archive/israel-ministry-of-justice-decides-to-hold-eichmann-trial-in-jerusalem — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the forks-1948-1965 data agent; page opened and quote checked on 2026-10-11.
  - Quote: "Dr. Nahum Goldmann, president of the World Zionist Organization and of the World Jewish Congress, today modified his suggestion that Eichmann should be tried by an international tribunal"
  - Supports:
    - Ministry of Justice decided the Eichmann trial would be held in Jerusalem; Goldmann had suggested an international tribunal and Ben-Gurion strongly disagreed; Argentina sought an official report on the abduction

**[S696]** Jewish Telegraphic Agency, 'Establishment of Israel-German Diplomatic Relations Announced', 14 May 1965 — https://www.jta.org/archive/establishment-of-israel-german-diplomatic-relations-announced — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the forks-1948-1965 data agent; page opened and quote checked on 2026-10-11.
  - Quote: "The establishment of diplomatic relations between Israel and West Germany was announced simultaneously in Jerusalem and Bonn today."
  - Supports:
    - Diplomatic relations announced 14 May 1965 via letters between Erhard and Eshkol; outstanding arms supplies converted; talks on economic aid within two or three months; German rocket experts expected to leave Egypt

**[S697]** Palestine Question interactive encyclopedia (palquest), 'Palestinians Under Military Rule in Israel, 1948-1966' — https://www.palquest.org/en/highlight/14340/palestinians-under-military-rule-israel-1948-1966 — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the forks-1948-1965 data agent; page opened and quote checked on 2026-10-11.
  - Quote: "Ben-Gurion thwarted all attempts to abolish military rule until 1963"
  - Supports:
    - Opposition parties made two attempts in the Knesset to end military rule (1962 and 1963); the 1963 attempt failed by one vote; Herut and Mapam (partially) joined the opposition; military rule continued to 1966

**[S698]** Israel Democracy Institute, 'Herut' party profile — https://en.idi.org.il/israeli-elections-and-parties/parties/herut/ — accessed: 2026-10-11 — provenance: opened
  - Note: Added by the forks-1948-1965 data agent; page opened and quote checked on 2026-10-11.
  - Quote: "strongly opposed diplomatic relations with Germany"
  - Supports:
    - Herut strongly opposed diplomatic relations with Germany, a stance that culminated in violent demonstrations in Jerusalem during the reparations debates

**[S750]** Pnina Lahav, 'The Suez Crisis of 1956 and Its Aftermath: A Comparative Study of Constitutions, Use of Force, Diplomacy and International Relations', Boston University Law Review 95 (2015) — https://www.bu.edu/bulawreview/files/2015/07/LAHAV.pdf — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-1948-1965 data agent; page opened and quote checked on 2026-10-12.
  - Quote: "Two ministers, both members of the left-wing Mapam Party, dissented, warning the cabinet that it was approving a preventive war the end of which could not be foreseen."
  - Supports:
    - Israel's cabinet approved the Sinai action on 28 October 1956 under the Sevres plan; two Mapam ministers dissented; Sharett, who preferred diplomacy to force, left the foreign ministry in June 1956 and was replaced by Golda Meir, who doubted the plan

**[S751]** US Department of State, Foreign Relations of the United States 1958-1960 vol. XIII, doc. 36, 'Memorandum of a Conversation, Washington, August 5, 1958' (Use of Israel Airspace for Airlift to Jordan) — https://history.state.gov/historicaldocuments/frus1958-60v13/d36 — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-1948-1965 data agent; page opened and quote checked on 2026-10-12.
  - Quote: "Ambassador Eban handed the Acting Secretary a letter from Prime Minister Ben Gurion to the Secretary"
  - Supports:
    - In August 1958 Ben-Gurion consented to resumption of the US airlift to Jordan through Israeli airspace after Israel had asked for it to stop; the Soviet note of 1 August charged that Israel's help to the airlift was aggressive

**[S752]** Jewish Telegraphic Agency, 'Israel Military Tribunal Sentences Eight Policemen for Killing Arabs', 17 October 1958 — https://www.jta.org/archive/israel-military-tribunal-sentences-eight-policemen-for-killing-arabs — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-1948-1965 data agent; page opened and quote checked on 2026-10-12.
  - Quote: "A military tribunal today sentenced eight Israel border policemen to prison terms ranging from seven to 17 years in the killing of 43 Arab villagers two years ago."
  - Supports:
    - Kafr Qasim sentences of 7 to 17 years; the defence pleaded mitigation, a sulha had been held and compensation of over 500,000 pounds paid

**[S753]** Jewish Telegraphic Agency, 'Israel Army Chief Orders Study of Judgment of Kafr Kassem Trial', 21 October 1958 — https://www.jta.org/archive/israel-army-chief-orders-study-of-judgment-of-kafr-kassem-trial — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-1948-1965 data agent; page opened and quote checked on 2026-10-12.
  - Quote: "Army Chief of Staff Chaim Laskov instructed the chief military prosecutor today to study the judgment of the Kafr Kassem trial to determine whether further trials shall be ordered in the killing of 43 Arab citizens of Israel two years ago."
  - Supports:
    - After the Kafr Qasim verdict the chief of staff ordered a study of whether to indict Col. Shadmi; Herut proposed a bill on a soldier's duty regarding orders

**[S754]** Jewish Virtual Library, 'The Suez-Sinai Campaign: Incident at Kfar Kassem' — https://jewishvirtuallibrary.org/incident-at-kfar-kassem-october-1956 — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-1948-1965 data agent; page opened and quote checked on 2026-10-12.
  - Quote: "Those who were imprisoned had their terms reduced; no one served more than three and a half years in jail."
  - Supports:
    - Eleven border policemen charged, eight convicted; terms later reduced, none served more than three and a half years; the brigade commander received a symbolic fine

**[S755]** Jewish Telegraphic Agency, 'Eichmann Hanged; His Plea for Clemency Rejected by Israel's President', 1 June 1962 — https://www.jta.org/1962/06/01/archive/eichmann-hanged-his-plea-for-clemency-rejected-by-israels-president — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-1948-1965 data agent; page opened and quote checked on 2026-10-12.
  - Quote: "President Ben-Zvi received appeals also from a number of Israeli intellectuals, including Professor Martin Buber of the Hebrew University, urging him to spare Eichmann’s life."
  - Supports:
    - President Ben-Zvi rejected Eichmann's clemency appeal on the Justice Minister's recommendation; Buber and other intellectuals urged clemency, while many letters urged standing by the verdict; first hanging in Israel

**[S756]** Jewish Telegraphic Agency, 'Ben Gurion Reopens the Lavon Affair; Submits Charges to Government', 23 October 1964 — https://www.jta.org/archive/ben-gurion-reopens-the-lavon-affair-submits-charges-to-government — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-1948-1965 data agent; page opened and quote checked on 2026-10-12.
  - Quote: "Former Prime Minister David Ben-Gurion renewed officially today his contention that it was Pinhas Lavon who, as Defense Minister, gave the order which led to a disastrous security mishap in 1954."
  - Supports:
    - Ben-Gurion's 'White Book' of 23 October 1964 asked for a government committee to review the Lavon affair

**[S757]** Jewish Telegraphic Agency, 'Rift Between Ben-Gurion and Eshkol Sharpens; Ben-Gurion Defiant', 7 December 1964 — https://www.jta.org/archive/rift-between-ben-gurion-and-eshkol-sharpens-ben-gurion-defiant — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-1948-1965 data agent; page opened and quote checked on 2026-10-12.
  - Quote: "he will pursue his aim of reopening an investigation of the Lavon affair, even if the Cabinet and Parliament oppose such a move"
  - Supports:
    - Ben-Gurion vowed to pursue a new Lavon inquiry against cabinet and Knesset; Golda Meir encouraged Eshkol to hold a firm stand

**[S758]** Jewish Telegraphic Agency, 'Eshkol Resigns; Resents Ben Gurion's Pressure to Reopen Lavon Case', 15 December 1964 — https://www.jta.org/archive/eshkol-resigns-resents-ben-gurions-pressure-to-reopen-lavon-case — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-1948-1965 data agent; page opened and quote checked on 2026-10-12.
  - Quote: "The latter had recommended the adoption of the Ben-Gurion proposal for a new Lavon inquiry."
  - Supports:
    - Eshkol resigned his government on 15 December 1964 over Ben-Gurion's demand; Justice Minister Dov Joseph had recommended Ben-Gurion's proposal

**[S759]** Yuval Elizur, 'Israeli Television and the National Agenda', Jewish Virtual Library (Israel Society & Culture) — https://jewishvirtuallibrary.org/israeli-television-and-the-national-agenda — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-1948-1965 data agent; page opened and quote checked on 2026-10-12.
  - Quote: "In 1955, another public committee again recommended that television be introduced in Israel."
  - Supports:
    - Public committees (1951, 1955) and UNESCO, EBU and CBC experts recommended introducing television; Ben-Gurion and Finance Minister Eshkol opposed it; Orthodox circles opposed it; first Israeli broadcast 1968

**[S765]** Jewish Virtual Library, 'Black September' (Jordan, September 1970) — https://www.jewishvirtuallibrary.org/black-september — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-1966 data agent; page opened with WebFetch on 2026-10-12.
  - Quote: "sending troops to the border with Syria and fighter planes over Syrian tanks in Jordan"
  - Supports:
    - During the Syrian incursion into Jordan Hussein asked for 'immediate physical intervention both air and land'; Kissinger told Meir the US 'would look favorably upon an Israeli air attack'; Israel did not attack but sent troops to the Syrian border and fighter planes over the Syrian tanks

**[S766]** US State Department, FRUS 1969-76 vol. XXIV, doc. 306: telegram from Rogers to the Embassy in Israel, 22 Sep 1970 — https://history.state.gov/historicaldocuments/frus1969-76v24/d306 — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-1966 data agent; page opened with WebFetch on 2026-10-12.
  - Quote: "Pursuant to Sisco's request, Rabin agreed to query Jerusalem re alternative option calling for Israeli move into Syria"
  - Supports:
    - Rabin told Sisco an air strike alone would not deal with 300 Syrian tanks and opposed diversionary moves not aimed at the source of the problem; Sisco asked about an Israeli move into Syria

**[S767]** Jewish Telegraphic Agency, report on the Knesset vote on the Sinai interim agreement (5 Sep 1975) — https://www.jta.org/archive/ouster-of-dayan-for-breaking-discipline-appears-unlikely-but-some-exemplary-action-possible — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-1966 data agent; page opened with WebFetch on 2026-10-12.
  - Quote: "by a vote of 70-43 with seven abstentions"
  - Supports:
    - The Knesset approved the interim agreement with Egypt 70-43 with seven abstentions on 4 Sep 1975; Rimalt of the Likud Liberals, Dayan, Ben Porat and Hadar voted against; Peres argued for it

**[S768]** Jewish Telegraphic Agency, 'Knesset Overwhelmingly Approves Begin's Invitation to Sadat' (16 Nov 1977) — https://jta.org/1977/11/16/archive/knesset-overwhelmingly-approves-begins-invitation-to-sadat — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-1966 data agent; page opened with WebFetch on 2026-10-12.
  - Quote: "Only the three-member Rakah Communist faction abstained in the vote."
  - Supports:
    - The Knesset approved Begin's invitation to Sadat; Chief of Staff Gur warned that Egyptian forces could be turned against Israel; Allon spoke for the Labor opposition

**[S769]** Jewish Telegraphic Agency, 'Allon Denounces Koenig Report' (15 Sep 1976) — https://www.jta.org/archive/allon-denounces-koenig-report — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-1966 data agent; page opened with WebFetch on 2026-10-12.
  - Quote: "He praised Interior Minister Yosef Burg for quietly shelving it"
  - Supports:
    - Allon denounced the Koenig memorandum advocating harsh measures against Israeli Arabs; Kol and Shemtov pressed for a cabinet debate; several ministers and MKs demanded Koenig's dismissal; Rabin kept it off the agenda

**[S770]** Jewish Telegraphic Agency, 'Israel Moves to Annex Golan Heights' (15 Dec 1981) — https://www.jta.org/archive/israel-moves-to-annex-golan-heights — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-1966 data agent; page opened with WebFetch on 2026-10-12.
  - Quote: "Should we wait for years, possibly for five generations, for the Syrians to change their minds?"
  - Supports:
    - Israeli law applied to the Golan from December 1981 over Labor Alignment opposition; Geula Cohen of Tehiya withdrew her Golan bill to move for annexation of the West Bank

**[S771]** Jewish Telegraphic Agency, 'Labor-Likud Talks Inch Forward' (21 Aug 1984) — https://jta.org/1984/08/21/archive/labor-likud-talks-inch-forward — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-1966 data agent; page opened with WebFetch on 2026-10-12.
  - Quote: "prepared to form a narrow-based coalition government"
  - Supports:
    - Labor said it was prepared to form a narrow coalition if the unity talks stalled; disputes over settlements and Jordan talks

**[S772]** Jewish Telegraphic Agency, 'Israel Has Unity Government Headed by Peres; He and Shamir to Rotate As Premier After 25 Months' (14 Sep 1984) — https://www.jta.org/archive/israel-has-unity-government-headed-by-peres-he-and-shamir-to-rotate-as-premier-after-25-months — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-1966 data agent; page opened with WebFetch on 2026-10-12.
  - Quote: "Shamir will replace Peres as Premier, and Peres will replace Shamir as Deputy Premier and Foreign Minister"
  - Supports:
    - A seven-party unity government after 40 days of negotiation; premiership rotates after 25 months

**[S780]** Moffett, George D., III, 'Likud Party to Debate Election Plan', The Christian Science Monitor, 23 Jun 1989 — https://www.csmonitor.com/1989/0623/osham.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the 1986-2005 gap-forks data agent; page opened via curl and quote checked against the page text.
  - Quote: "Mr. Shamir is determined to gain his party's solid backing for his peace initiative that would begin with an election in the occupied territories."
  - Supports:
    - Shamir's election initiative and the Sharon/Levy demands for conditions, June 1989

**[S781]** Wayne, E.A., 'Shamir deals setback to US hopes', The Christian Science Monitor, 11 Jul 1989 — https://www.csmonitor.com/1989/0711/aliku.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the 1986-2005 gap-forks data agent; page opened via curl and quote checked against the page text.
  - Quote: "Prime Minister Yitzak Shamir's hard-line pledges to his Likud Party gave the nascent United States peace process its first body blow."
  - Supports:
    - Shamir's concessions to the Likud central committee, July 1989

**[S782]** Greenberg, Joel, 'Poor Israelis Protest Influx of Soviet Jews', The Christian Science Monitor, 18 Jul 1990 — https://www.csmonitor.com/1990/0718/ojew.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the 1986-2005 gap-forks data agent; page opened via curl and quote checked against the page text.
  - Quote: "Housing Minister Ariel Sharon, already grappling with the acute shortage of apartments for arriving Soviet Jews, has proposed a series of emergency steps to overcome the housing crisis: importing prefabricated homes and trailers, and putting up the immigrants in hotels, youth hostels, and Army barracks."
  - Supports:
    - Sharon's emergency housing steps and the homeless tent-camp protests, July 1990

**[S783]** Frontline (PBS), interview with Benjamin Netanyahu on Oslo, 'Shattered Dreams of Peace' — https://www.pbs.org/wgbh/pages/frontline/shows/oslo/interviews/netanyahu.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the 1986-2005 gap-forks data agent; page opened via curl and quote checked against the page text.
  - Quote: "Well, I was actually approached by Palestinian merchants in the Via Dolorosa who wanted me to open the tunnel wall."
  - Supports:
    - Netanyahu on his September 1996 decision to open the Western Wall tunnel exit and the objections of Defence Minister Mordechai

**[S784]** Prusher, Ilene R., 'Big Stakes, Brinkmanship Hold Up Deal on Hebron', The Christian Science Monitor, 3 Jan 1997 — https://www.csmonitor.com/1997/0103/010397.intl.intl.1.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the 1986-2005 gap-forks data agent; page opened via curl and quote checked against the page text.
  - Quote: "Ministers of the National Religious Party, a major partner in Netanyahu's coalition government, say they will vote against the deal because it doesn't satisfy the security needs of Jewish settlers in Hebron."
  - Supports:
    - Cabinet opposition to the Hebron redeployment, January 1997

**[S785]** Prusher, Ilene R., 'Israel's Netanyahu Does About-Face On Peace Stance', The Christian Science Monitor, 15 Jan 1997 — https://www.csmonitor.com/1997/0115/011597.intl.intl.1.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the 1986-2005 gap-forks data agent; page opened via curl and quote checked against the page text.
  - Quote: "Netanyahu, who wanted to delay the withdrawals by two years so he could use the land transfers as bargaining chips in all-important "final status" talks, is in an even more precarious position."
  - Supports:
    - Hebron deal terms: 80 percent of Hebron, three further redeployments by August 1998, settler red line

**[S786]** Prusher, Ilene R., 'Peace by Percentages in Mideast', The Christian Science Monitor, 11 Jun 1998 — https://www.csmonitor.com/1998/0611/061198.intl.intl.2.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the 1986-2005 gap-forks data agent; page opened via curl and quote checked against the page text.
  - Quote: "The National Religious Party, an important voting block that represents the settlers' interests, says it will not accept one inch more than a 9 percent withdrawal from the West Bank."
  - Supports:
    - US 13 percent proposal, settler and NRP opposition, referendum idea, June 1998

**[S787]** 'The Wye River Memorandum: U.S. Brokers Secret Deals At Wye (October 1998)', Jewish Virtual Library, citing Jerusalem Report, 23 Nov 1998 — https://www.jewishvirtuallibrary.org/jsource/Peace/wyesecret.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the 1986-2005 gap-forks data agent; page opened via curl and quote checked against the page text.
  - Quote: "Israel also agreed to restrict building in settlements in the West Bank in return for a Palestinian pledge to defer their planned declaration of independence beyond May 4, 1999."
  - Supports:
    - Wye side-deals: settlement building limits, aid commitments

**[S788]** Peterson, Scott, "Barak's fast-break diplomacy", The Christian Science Monitor, 15 Jul 1999 — https://www.csmonitor.com/1999/0715/p1s2.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the 1986-2005 gap-forks data agent; page opened via curl and quote checked against the page text.
  - Quote: "Barak has stated he is willing to carry out the Wye accord, possibly with some adjustments."
  - Supports:
    - Barak's position on Wye implementation and Arafat's demand for the 13 percent withdrawal, July 1999

**[S789]** Segal, Naomi, 'Barak testifies to riot panel', Jewish Telegraphic Agency, 20 Aug 2002 — https://www.jta.org/?p=409452 — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the 1986-2005 gap-forks data agent; page opened via curl and quote checked against the page text.
  - Quote: "Barak himself ordered the creation of the Orr Commission after Israeli Arab leaders rejected his initial proposal for a public panel to investigate the events, in which 13 Israeli Arabs were killed by police fire during several days of rioting."
  - Supports:
    - Barak's initial proposal for a public panel versus the Or Commission, Oct-Nov 2000

**[S790]** Lynfield, Ben, 'Israeli Arabs decry inquiry report', The Christian Science Monitor, 2 Sep 2003 — https://csmonitor.com/2003/0902/p07s01-wome.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the 1986-2005 gap-forks data agent; page opened via curl and quote checked against the page text.
  - Quote: "The deaths of the 13 Arabs deepened wounds and distrust between the Jewish majority and the Arab minority, which accounts for 19 percent of Israel's population."
  - Supports:
    - Arab citizens' trust and the Or Commission findings

**[S791]** 'Israel, the US and Targeted Killings', Middle East Report Online (MERIP), Feb 2003 — https://merip.org/2003/02/israel-the-us-and-targeted-killings/ — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the 1986-2005 gap-forks data agent; page opened via curl and quote checked against the page text.
  - Quote: "On February 13, 2001, seven days after the election of Prime Minister Ariel Sharon, Israel resumed assassinations in the Occupied Territories with a helicopter attack on the car of Masoud Ayyad, an officer in Gaza’s security services."
  - Supports:
    - Resumption of targeted killings in February 2001 and US State Department criticism

**[S900]** Jewish Telegraphic Agency, 'Netanyahu would halt Annapolis-launched talks', 11 Nov 2008 — https://www.jta.org/2008/11/11/israel/netanyahu-would-halt-annapolis-launched-talks — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-2006-2026 data agent; page opened with the fetch tool and quote checked on 2026-10-12.
  - Quote: "the Likud leader believes that talks with the Palestinians should focus on economic issues"
  - Supports:
    - Opposition leader Netanyahu's office said he would end the Annapolis talks if elected and focus on economic issues

**[S901]** Middle East Forum, 'Olmert Details His Offer to Abbas' (Olmert interview, The Australian, Nov 2009) — https://www.meforum.org/olmert-details-his-offer-to-abbas — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-2006-2026 data agent; page opened with the fetch tool and quote checked on 2026-10-12.
  - Quote: "On the 16th of September, 2008, I presented him (Abbas) with a comprehensive plan."
  - Supports:
    - Olmert tabled a comprehensive plan to Abbas on 16 Sept 2008 based on the 1967 borders with minor swaps; Abbas did not sign

**[S902]** Globes, 'Netanyahu seen forming coalition without haredim', Feb-Mar 2013 — https://en.globes.co.il/en/article-1000826055 — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-2006-2026 data agent; page opened with the fetch tool and quote checked on 2026-10-12.
  - Quote: "Netanyahu will probably be compelled to forgo the haredi (ultra-orthodox) parties in the next government coalition."
  - Supports:
    - Lapid-Bennett alliance leaves Netanyahu to form a coalition without the Haredi parties

**[S903]** Globes, 'Netanyahu seen forming coalition without haredim', Feb 2013 — https://en.globes.co.il/en/article-1000817531 — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-2006-2026 data agent; page opened with the fetch tool and quote checked on 2026-10-12.
  - Quote: "the conditions set by Yair Lapid for joining the coalition - equal sharing of the military service burden"
  - Supports:
    - Lapid's condition for joining the coalition was an equal sharing of the military service burden, even at the price of foregoing the haredi parties

**[S904]** Israel National News (Arutz Sheva), report on Eli Yishai's Facebook post after the 2013 coalition deal, 10 Mar 2013 — https://www.israelnationalnews.com/news/166039 — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-2006-2026 data agent; page opened with the fetch tool and quote checked on 2026-10-12.
  - Quote: "an entire sector, traditional and religious, was boycotted solely for its beliefs and perceptions"
  - Supports:
    - Shas leader Eli Yishai said the Haredi parties were boycotted out of the coalition

**[S905]** Jewish Weekly (JTA), 'Prisoner release sparks conflict in Netanyahu's coalition', 1 Nov 2013 — https://jweekly.com/2013/11/01/prisoner-release-sparks-conflict-in-netanyahus-coalition/ — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-2006-2026 data agent; page opened with the fetch tool and quote checked on 2026-10-12.
  - Quote: "The goal is to establish a red line once and for all"
  - Supports:
    - Bennett proposed a bill barring future prisoner releases; cabinet rejected it 8-5; Netanyahu called the release one of his toughest decisions

**[S906]** Times of Israel, 'Politicians call for Hebron shooter Azaria to be pardoned', Jan-Feb 2017 — https://www.timesofisrael.com/politicians-call-for-hebron-shooter-azaria-to-be-pardoned/ — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-2006-2026 data agent; page opened with the fetch tool and quote checked on 2026-10-12.
  - Quote: "The security of the citizens of Israel requires an immediate pardon for Elor Azaria, who was sent to protect us."
  - Supports:
    - Education Minister Bennett called for an immediate pardon of Elor Azaria after his sentencing

**[S907]** Fox News (AP), 'Israel trims sentence of soldier who killed wounded attacker', 2017 — https://www.foxnews.com/world/israel-trims-sentence-of-soldier-who-killed-wounded-attacker.amp — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-2006-2026 data agent; page opened with the fetch tool and quote checked on 2026-10-12.
  - Quote: "would not grant a pardon because the soldier "didn't accept responsibility" for his actions"
  - Supports:
    - Chief of Staff Eisenkot cut Azaria's sentence by four months for mercy considerations but refused a pardon

**[S908]** Jerusalem Post via Jerusalem Center Daily Alert, Temple Mount metal detectors, 21 Jul 2017 — https://dailyalert.org/archive/index.php?id=67192 — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-2006-2026 data agent; page opened with the fetch tool and quote checked on 2026-10-12.
  - Quote: "once the red line has been crossed of automatic weapons on the Temple Mount"
  - Supports:
    - Erdan argued the detectors should remain after the 14 July attack

**[S909]** St. Louis Jewish Light (JTA), 'Israel agrees to remove metal detectors at Temple Mount', 25 Jul 2017 — https://stljewishlight.org/world-news/israel-agrees-to-remove-metal-detectors-at-temple-mount — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-2006-2026 data agent; page opened with the fetch tool and quote checked on 2026-10-12.
  - Quote: "accepted the recommendation of all of the security bodies"
  - Supports:
    - Cabinet replaced the detectors with 'smart checks' costing up to NIS 100 million over six months

**[S910]** Times of Israel, 'Removing Temple Mount security hard but necessary choice, PM says', 30 Jul 2017 — https://www.timesofisrael.com/removing-temple-mount-security-hard-but-necessary-choice-pm-says/ — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-2006-2026 data agent; page opened with the fetch tool and quote checked on 2026-10-12.
  - Quote: "I must make decisions coolly and judiciously."
  - Supports:
    - Netanyahu defended removing the detectors as a decision taken from a wide view of threats

**[S911]** Times of Israel, 'Cabinet okays tax-free homes for first-time buyers', 24 Mar 2014 — https://www.timesofisrael.com/cabinet-okays-tax-free-homes-for-first-time-buyers/ — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the gap-2006-2026 data agent; page opened with the fetch tool and quote checked on 2026-10-12.
  - Quote: "The state of Israel decided today that it's going to stop profiting off the children of the middle class."
  - Supports:
    - Lapid's zero-VAT plan for first homes passed a cabinet committee; Bank of Israel Governor Flug warned of a demand spike; Netanyahu backed land tenders

**[S912]** RETIRED (no longer cited; cited only by content dated after Q3 2023, deleted 2026-10-14 (the game ends 7 Oct 2023)) — Naharnet (AFP), 'Al-Sharaa says Syria in talks with Israel on security deal', Aug 2025 — https://cdn.naharnet.com/stories/en/315251-al-sharaa-says-syria-in-talks-with-israel-on-security-deal

**[S5000]** JTA, 'Mapam Asks for State Council Debate on Decision to Dissolve Palmach Headquarters', 2 November 1948 — https://www.jta.org/archive/mapam-asks-for-state-council-debate-on-decision-to-dissolve-palmach-headquarters — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1948-1955 data agent; page opened with curl and quote checked verbatim against the raw page text on 2026-10-12.
  - Quote: "Mapam, the United Workers Party, on the Israeli State Council today demanded a full Council debate on a decision taken by the Army General Staff dissolving the separate headquarters of the Palmach"
  - Supports:
    - The General Staff dissolved the separate Palmach headquarters (approved by the Council's Security Committee); Mapam demanded a full State Council debate

**[S5001]** JTA, 'Histadruth Conference Ratifies Dissolution of Palmach Headquarters by Vote of 69-38', 12 December 1948 — https://www.jta.org/archive/histadruth-conference-ratifies-dissolution-of-palmach-headquarters-by-vote-of-69-38 — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1948-1955 data agent; page opened with curl and quote checked verbatim against the raw page text on 2026-10-12.
  - Quote: "The Histadruth Council conference ratified by a vote of 69 to 38 the dissolution of the separate headquarters of Palmach"
  - Supports:
    - The Histadrut council ratified the dissolution of the Palmach headquarters 69-38; Mapai voted for, Mapam against

**[S5002]** JTA, 'Issue of Palmach Headquarters Dissolution Raised at Labor Conference in Tel Aviv', 9 December 1948 — https://www.jta.org/archive/issue-of-palmach-headquarters-dissolution-raised-at-labor-conference-in-tel-aviv — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1948-1955 data agent; page opened with curl and quote checked verbatim against the raw page text on 2026-10-12.
  - Quote: "The dissolution by the Israeli Government of the separate headquarters of Palmach, striking force within the former Haganah, came up for open discussion today for the first time when leaders of Mapam, the United Workers Party, raised the issue"
  - Supports:
    - The government dissolved the separate Palmach headquarters; Mapam leaders raised the issue at the Histadrut council on 9 December 1948

**[S5003]** JTA, 'Religious Bloc, Progressives Join Mapai in Cabinet; Mapam General Zionists Stay out', 4 March 1949 — https://www.jta.org/archive/religious-bloc-progressives-join-mapai-in-cabinet-mapam-general-zionists-stay-out — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1948-1955 data agent; page opened with curl and quote checked verbatim against the raw page text on 2026-10-12.
  - Quote: "Three have been assigned to the Religious Bloc, one to the Progressive Zionists"
  - Supports:
    - Ben-Gurion's first cabinet (March 1949): Mapai with 3 Religious Bloc and 1 Progressive portfolios; Mapam and the General Zionists declined to join

**[S5004]** JTA, 'Israeli Parliament Discusses Cabinet's Program; Vote of Confidence Expected', 10 March 1949 — https://www.jta.org/archive/israeli-parliament-discusses-cabinets-program-vote-of-confidence-expected — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1948-1955 data agent; page opened with curl and quote checked verbatim against the raw page text on 2026-10-12.
  - Quote: "Opening the debate last night, Meir Yaari, leader of the Mapam, the left-wing minority group, accused the Mapai, the majority right-wing labor faction, of proposing “impossible conditions” governing participation by Mapam in the coalition government"
  - Supports:
    - Mapam leader Meir Yaari said Mapam would join the coalition if a common socialist programme were guaranteed, and criticised giving the Interior Ministry to the religious bloc

**[S5005]** JTA, 'Members of Israel Cabinet Threaten to Resign; Protest Violation of Religious Edicts', 11 January 1950 — https://www.jta.org/archive/members-of-israel-cabinet-threaten-to-resign-protest-violation-of-religious-edicts — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1948-1955 data agent; page opened with curl and quote checked verbatim against the raw page text on 2026-10-12.
  - Quote: "Rabbi Itzhak Moir Lewin, Israel’s Minister of Welfare, who declared in Jerusalem that the members of the Religious Bloc will resign from the coalition government unless children of Orthodox parentage arriving in Israel from Near Eastern countries are given a religious education"
  - Supports:
    - In January 1950 the Religious Bloc, led on this by Welfare Minister Rabbi I. M. Lewin, threatened to leave the coalition unless immigrant-camp children of Orthodox parentage received religious education

**[S5006]** JTA, 'Israel Premier Makes Further Efforts to Broaden Cabinet; Talks with Progressives', 27 February 1950 — https://www.jta.org/archive/israel-premier-makes-further-efforts-to-broaden-cabinet-talks-with-progressives — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1948-1955 data agent; page opened with curl and quote checked verbatim against the raw page text on 2026-10-12.
  - Quote: "a referendum on education will be held in the immigrant camps to permit parents to choose the type of school they wish for their children"
  - Supports:
    - Cabinet decision of early 1950: parents in the immigrant camps to choose among the recognised school systems by referendum; the Progressive Party objected to the multiple system

**[S5007]** JTA, 'Israel Must Contract Immigration Just when Jews May Leave Iron Curtain Countries', 6 June 1950 — https://www.jta.org/archive/israel-must-comtract-immigration-just-when-jews-may-leave-iron-curtain-countries — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1948-1955 data agent; page opened with curl and quote checked verbatim against the raw page text on 2026-10-12.
  - Quote: "the Jewish Agency and the Israel Government are compelled–because of financial reasons–to limit the number of immigrants entering Israel to 12,500 a month"
  - Supports:
    - In June 1950 the joint government-Jewish Agency coordination board limited immigration to 12,500 a month for financial reasons

**[S5008]** JTA, 'Israel Decides to Speed Up the Emigration of Jews from Iraq; Increases Quotas', 31 January 1951 — https://www.jta.org/archive/israel-decides-to-speed-up-the-emigration-of-jews-from-iraq-increases-quotas — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1948-1955 data agent; page opened with curl and quote checked verbatim against the raw page text on 2026-10-12.
  - Quote: "it was decided to increase the monthly quota of Iraq Jewish immigrants to 13,500"
  - Supports:
    - On 31 January 1951 the government and Jewish Agency raised the monthly Iraqi quota to 13,500 to move all registrants (54,000) in four months, despite expected housing and job difficulties

**[S5009]** JTA, 'Arab-Israel Peace Must Precede Defense Pact, Ben Gurion Says', 18 October 1951 — https://www.jta.org/archive/arab-israel-peace-must-precede-defense-pact-ben-gurion-says — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1948-1955 data agent; page opened with curl and quote checked verbatim against the raw page text on 2026-10-12.
  - Quote: "it was indicated by Premier David Ben Gurion when he conferred with American Ambassador Monnet B. Davis this week"
  - Supports:
    - In October 1951 Ben-Gurion told the US ambassador Israel could join a Middle East defence organisation only after an Arab-Israeli peace

**[S5010]** JTA, 'U.S. Aid, Middle East Defense Debated in Israel Parliament', 6 November 1951 — https://www.jta.org/archive/u-s-aid-middle-east-defense-debated-in-israel-parliament — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1948-1955 data agent; page opened with curl and quote checked verbatim against the raw page text on 2026-10-12.
  - Quote: "Mapam’s Jacob Riftin took the floor to criticize the Middle East command"
  - Supports:
    - In the Knesset debate of November 1951 Mapam's Jacob Riftin asked the government to shun the proposed Middle East command

**[S5011]** JTA, 'Service Bill for Women Introduced in Knesset; Passage Expected', 23 July 1953 — https://www.jta.org/archive/service-bill-for-women-introduced-in-knesset-passage-expected — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1948-1955 data agent; page opened with curl and quote checked verbatim against the raw page text on 2026-10-12.
  - Quote: "it was the intent of the government to increase the available labor power by drafting Orthodox young women who were unable to serve in the Army for religious or family reasons for other jobs"
  - Supports:
    - Labour Minister Golda Myerson introduced the National Service Bill in July 1953: two years of non-military service for religiously exempt women, with exemption committees

**[S5012]** JTA, 'Knesset Approves Service Bill for Women by a 59 to 6 Vote', 24 July 1953 — https://www.jta.org/archive/knesset-approves-service-bill-for-women-by-a-59-to-6-vote — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1948-1955 data agent; page opened with curl and quote checked verbatim against the raw page text on 2026-10-12.
  - Quote: "Agudah leader L.M. Lewin declared: “A couple of thousand girls will not solve the manpower problem.”"
  - Supports:
    - The bill passed first reading 59-6; Agudah leader Rabbi I. M. Lewin opposed any compulsory service for religious women

**[S5013]** JTA, 'Israel Decides to Secure Arms to Offset Egyptian Acquisitions', 4 October 1955 — https://www.jta.org/archive/israel-decides-to-secure-arms-to-offset-egyptian-acquisitions — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1948-1955 data agent; page opened with curl and quote checked verbatim against the raw page text on 2026-10-12.
  - Quote: "The Israel Cabinet decided today to acquire whatever arms are needed to maintain a balance of armaments with Egypt"
  - Supports:
    - On 4 October 1955, after the Czech-Egyptian arms deal was announced, the cabinet decided to acquire the arms needed to keep a balance with Egypt

**[S5014]** JTA, 'Arms, Security Guarantee for Israel Urged on Dulles', 31 October 1955 — https://www.jta.org/archive/arms-security-guarantee-for-israel-urged-on-dulles — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1948-1955 data agent; page opened with curl and quote checked verbatim against the raw page text on 2026-10-12.
  - Quote: "a security pact to batten down the status quo in the Middle East, were called for in a statement sent to Secretary of State John Foster Dulles this week-end by Rep. Hugh Scott"
  - Supports:
    - US Representative Hugh Scott urged Washington to give Israel arms and a security pact after the Czech-Egyptian arms deal

**[S5015]** JTA, 'Knesset in Show of Unity Hits Arms Deal, Appeals to West', 26 October 1955 — https://www.jta.org/archive/knesset-in-show-of-unity-hits-arms-deal-appeals-to-west — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1948-1955 data agent; page opened with curl and quote checked verbatim against the raw page text on 2026-10-12.
  - Quote: "The Knesset empowers the government to marshal the people and the state to face these dangers"
  - Supports:
    - Knesset resolution of October 1955 (all but five Communist votes) empowered the government to strengthen the army and demand arms from the powers

**[S5016]** JTA, 'Knesset Debates Draft Exemption Bill Approved by Knesset Unit by 13-12 Vote', 20 July 1978 — https://www.jta.org/archive/knesset-debates-draft-exemption-bill-approved-by-knesset-unit-by-13-12-vote — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1948-1955 data agent; page opened with curl and quote checked verbatim against the raw page text on 2026-10-12.
  - Quote: "The law is frozen for coalition reasons."
  - Supports:
    - By 1978 the compulsory national service law of 1953 for religious women was not being applied, for coalition reasons

**[S5020]** JTA, 'Abolition of Currency Regulations and Other Sweeping Measures Are Introduced to Create a Free Econom', 31 Oct 1977 — https://www.jta.org/archive/abolition-of-currency-regulations-and-other-sweeping-measures-are-introduced-to-create-a-free-econom — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1976-1985 data agent; page fetched with curl and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-12.
  - Quote: "The first move was to establish a free-floating currency."
  - Supports:
    - Finance Minister Ehrlich's plan (drafted in secret since June 1977) floated the pound, abolished currency regulations and cut subsidies; cabinet approved it with one vote against (David Levi, who wanted adequate compensation for the poor) and one abstention; VAT rose from 8 to 12 percent

**[S5021]** JTA, 'Ehrlich Defends His Economic Policy As a Wave of Strikes Hit Israel', 7 Mar 1978 — https://www.jta.org/archive/ehrlich-defends-his-economic-policy-as-a-wave-of-strikes-hit-israel — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1976-1985 data agent; page fetched with curl and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-12.
  - Quote: "Finance Minister Simcha Ehrlich defended his economic policies in the Knesset today"
  - Supports:
    - By March 1978 the pound had been devalued by 48 percent, a wave of wildcat strikes was under way and Labor's Gad Yaacobi charged that inflation had run at 30 percent over three months

**[S5022]** JTA, 'New Economic Plan Sparks Unrest', 1 Nov 1977 — https://www.jta.org/archive/new-economic-plan-sparks-unrest — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1976-1985 data agent; page fetched with curl and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-12.
  - Quote: "Meshel said this morning that Histadrut will demand advanced payment of cost-of-living allowances"
  - Supports:
    - Histadrut leader Yeruham Meshel answered the Ehrlich plan with strikes and a demand for advance cost-of-living payments

**[S5023]** JTA, 'Cabinet Approves Autonomy Plan', 22 May 1979 — https://www.jta.org/archive/cabinet-approves-autonomy-plan — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1976-1985 data agent; page fetched with curl and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-12.
  - Quote: "The plan that emerged from the Cabinet today consisted of 20 points instead of the original 22 submitted by Begin."
  - Supports:
    - Cabinet adopted Begin's 20-point autonomy plan as guidelines (not as a formal position); Weizman called it too hardline and too detailed; Weizman, Dayan, Yadin and Yisrael Katz voted against two points (land control and a sovereignty claim after five years)

**[S5024]** JTA, 'Dayan Says Begin Government Is Pledged to Annex West Bank, Gaza', 29 Oct 1979 — https://www.jta.org/archive/dayan-says-begin-governmentis-pled-ged-to-annex-west-bank-gaza — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1976-1985 data agent; page fetched with curl and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-12.
  - Quote: "led to his resignation from the Cabinet last week"
  - Supports:
    - Dayan resigned in October 1979 over the autonomy policy; he also rejected the Labor Party's territorial compromise with Jordan

**[S5025]** JTA, 'Israel's Supreme Court Rules Elon Moreh in Samaria Must Be Removed', 23 Oct 1979 — https://www.jta.org/archive/israels-supreme-court-rules-elon-moreh-in-samaria-must-be-removed — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1976-1985 data agent; page fetched with curl and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-12.
  - Quote: "ruled unanimously today that the Gush Emunim settlement of Elon Moreh in the Samaria district of the West Bank must be removed"
  - Supports:
    - The Supreme Court (Justice Moshe Landau) ordered Elon Moreh removed from expropriated Arab land and gave the settlers 30 days

**[S5026]** JTA, 'Government to Seek Alternative Site for Elon Moreh, Special Cabinet Session Thursday to Discuss Issue', 29 Oct 1979 — https://www.jta.org/archive/government-to-seek-alternative-site-for-elon-moreh-special-cabinet-session-thursday-to-discuss-issu — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1976-1985 data agent; page fetched with curl and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-12.
  - Quote: "Agriculture Minister Ariel Sharon and Education Minister Zevulun Hammer dissented sharply from Begin"
  - Supports:
    - Cabinet debate: Begin sought an alternative site; Sharon and Hammer (NRP) dissented; Housing Minister David Levy urged implementing the ruling; Sharon voiced the Gush Emunim demand for retroactive legislation

**[S5027]** JTA, 'Elonmoreh Settlers to Leave Voluntarily for Alternative Site', 6 Dec 1979 — https://www.jta.org/archive/elonmoreh-settlers-to-leave-voluntarily-for-alternative-site — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1976-1985 data agent; page fetched with curl and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-12.
  - Quote: "the settlers of Elon Moreh have agreed to leave voluntarily and accept an alternative site offered by the government at Djebel Kebir"
  - Supports:
    - Settlers agreed on 6 December 1979 to move to Djebel Kebir; government policy was to use only State-owned land for West Bank settlement

**[S5028]** JTA, 'Battle over Defense Budget', 23 May 1980 — https://www.jta.org/archive/battle-over-defense-budget — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1976-1985 data agent; page fetched with curl and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-12.
  - Quote: "Defense Minister Ezer Weizman declared that he would resign if"
  - Supports:
    - Finance Minister Hurwitz froze the budget after April 1980 inflation of 10.2 percent; Weizman said he would resign if even one penny were cut from defence; Lavi fighter at risk

**[S5029]** JTA, 'Cabinet Compromises on Defense Budget; Cuts It Only IL 7 Billion', 20 Jun 1980 — https://www.jta.org/archive/cabinet-compromises-on-defense-bud-get-cuts-it-only-il-7-billion — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1976-1985 data agent; page fetched with curl and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-12.
  - Quote: "The Cabinet agreed to slice IL 7 billion (about $150 million) from the Defense Ministry"
  - Supports:
    - After a nine-hour session the cabinet cut IL 7 billion from defence; Hurwitz had demanded IL 15 billion, backed by a majority of the five-man Sharon committee

**[S5030]** JTA, 'Jerusalem Bill Goes to Knesset', 1 Jul 1980 — https://www.jta.org/archive/jerusalem-bill-goes-to-knesset — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1976-1985 data agent; page fetched with curl and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-12.
  - Quote: "was proposed last month by Geula Cohen of the ultranationalist Tehiya faction, as a private member"
  - Supports:
    - Geula Cohen's Jerusalem bill moved to the Knesset floor; it drew an angry response from Cairo and Sadat did not resume the autonomy talks suspended on 8 May; Cairo reports said Begin had assured Sadat it would be buried (denied in Israel)

**[S5031]** JTA, 'Controversial Bill on Jerusalem Will Not Be Rushed Through Knesset', 9 Jul 1980 — https://www.jta.org/archive/controversial-bill-on-jerusalem-will-not-be-rushed-through-knesset — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1976-1985 data agent; page fetched with curl and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-12.
  - Quote: "The government is reportedly eager to bury the bill."
  - Supports:
    - The cabinet declined to support the bill; Transport Minister Haim Landau demanded support; only the NRP in the coalition backed the bill

**[S5032]** JTA, 'Knesset Approves Jerusalem Bill', 31 Jul 1980 — https://www.jta.org/archive/knesset-approves-jerusalem-bill — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1976-1985 data agent; page fetched with curl and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-12.
  - Quote: "by a vote of 69-15 with three abstentions, thus incorporating it into Israel"
  - Supports:
    - Knesset passed the Jerusalem Basic Law 69-15 with three abstentions; the Labor Alignment, with Mayor Teddy Kollek, pushed practical provisions (holy places, an annual grant to the city) into the text

**[S5033]** JTA, 'Israel Says UN Resolution Will Not Affect Jerusalem Status As Capital', 22 Aug 1980 — https://www.jta.org/archive/israel-says-un-resolution-will-not-affect-jerusalems-status-as-capital — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1976-1985 data agent; page fetched with curl and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-12.
  - Quote: "called for the removal of the 11 remaining embassies in the city"
  - Supports:
    - Security Council voted 14-0 (US abstaining) to call for removal of the 11 embassies in Jerusalem; Venezuela, Uruguay and Ecuador announced moves, Chile expected to follow

**[S5034]** JTA, 'Dispute in Cabinet over Its Earlier Decision to Shore Up Sagging Commercial Bank Shares', 13 Oct 1983 — https://www.jta.org/archive/dispute-in-cabinet-over-its-earlier-decision-to-shore-up-sagging-commercial-bank-shares — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1976-1985 data agent; page fetched with curl and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-12.
  - Quote: "The decision was taken despite strenuous opposition by Finance Minister Yoram Aridor"
  - Supports:
    - In the early hours of 11 October 1983 the cabinet backed bank shares at their 6 October value (dollar-linked, redeemable after five years plus 3 percent), persuaded by MK Avraham Shapiro; Aridor opposed; economists put the cost at 140 billion shekels

**[S5035]** JTA, 'Near Panic Dominates Israel Money Market', 11 Oct 1983 — https://www.jta.org/archive/near-panic-dominates-israels-money-market — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1976-1985 data agent; page fetched with curl and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-12.
  - Quote: "Agreement was reached to link bank shares to the U.S. Dollar, in effect a government guarantee of their value."
  - Supports:
    - Banks, Treasury and Bank of Israel agreed to link bank shares to the dollar; bank shares had been considered the safest investment; stock exchange closed

**[S5036]** JTA, 'Bank of Israel Governor Resigns in Wake of Indictment of Banking System', 23 Apr 1986 — https://www.jta.org/archive/bank-of-israel-governor-resigns-in-wake-of-indictment-of-banking-system — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1976-1985 data agent; page fetched with curl and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-12.
  - Quote: "It recommended, among other things, that the Governor of the Bank of Israel and the heads of the five largest commercial banks be made to resign within 30 days."
  - Supports:
    - The Beisky commission on the 1983 bank-share collapse recommended resignations; Governor Mandelbaum resigned

**[S5037]** JTA, 'Proposal for Unilateral IDF Withdrawal from South Lebanon Splits Unity Government Along Party Lines', 14 Jan 1985 — https://www.jta.org/archive/proposal-for-unilateral-idf-withdrawal-from-south-lebanon-splits-unity-government-along-party-lines — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1976-1985 data agent; page fetched with curl and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-12.
  - Quote: "It was strongly opposed by former Defense Minister Moshe Arens of Likud"
  - Supports:
    - Defence Ministry proposed a three-stage unilateral withdrawal over 6-9 months; Peres and Rabin favoured it, Arens opposed, Sharon believed to oppose; Maariv: withdrawal to a line 21-30 km from the border

**[S5038]** JTA, 'Cabinet Decides to Begin Second Stage IDF Withdrawal from South Lebanon', 4 Mar 1985 — https://www.jta.org/archive/cabinet-decides-to-begin-second-stage-idf-withdrawal-from-south-lebanon — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1976-1985 data agent; page fetched with curl and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-12.
  - Quote: "Sharon reportedly urged that the IDF establish a 30-kilometer deep security zone north of the Israeli border"
  - Supports:
    - First stage (Awali, Sidon) completed 16 February 1985; cabinet began the second stage on 4 March; Sharon and Arens did not vote

**[S5039]** JTA, 'New Economic Program to Be Introduced by Aridor', 21 Jan 1981 — https://www.jta.org/archive/new-economic-program-to-be-introduced-by-aridor — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the final-1976-1985 data agent; page fetched with curl and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-12.
  - Quote: "He achieved only limited success and resigned over the issue Jan. 11."
  - Supports:
    - Hurwitz resigned on 11 January 1981 after limited success in cutting government spending; Aridor succeeded him

**[S5100]** Jewish Telegraphic Agency, 'General Zionists May Join Israel Cabinet; Announcement Expected', Daily Bulletin, 15 December 1952 — https://www.jta.org/archive/general-zionists-may-join-israel-cabinet-announcement-expected — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2 1948-1965 data agent; page opened with curl and the quote checked verbatim on 2026-10-12. 
  - Quote: "Apparently the religious parties will be the only ones to suffer if the centrists enter the government"
  - Supports:
    - In December 1952 Mapai was ready to replace its coalition with the religious parties by one with the centrist General Zionists, who demanded four portfolios; the religious parties would lose their fight against a unified school system

**[S5101]** Jewish Telegraphic Agency, 'Mapaiand General Zionists Announce Agreement on Cabinet', Daily Bulletin, 17 December 1952 — https://www.jta.org/archive/mapaiand-general-zionists-announce-agreement-on-cabinet — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2 1948-1965 data agent; page opened with curl and the quote checked verbatim on 2026-10-12. The headline is printed with the typo 'Mapaiand'.
  - Quote: "Economic controls shall be scrapped, except on materials which cannot be produced in the country."
  - Supports:
    - The Mapai-General Zionist agreement of 17 December 1952 ran to the end of the Knesset term (1955) and provided to scrap economic controls, stabilise prices and the pound, and replace party school trends with a secular and a religious system

**[S5102]** Jewish Telegraphic Agency, 'U.S. Suspends Economic Aid to Israel; Notifies Israel Government', Daily Bulletin, 20 October 1953 — https://www.jta.org/archive/u-s-suspends-economic-aid-to-israel-notifies-israel-government — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2 1948-1965 data agent; page opened with curl and the quote checked verbatim on 2026-10-12. 
  - Quote: "The United States has officially notified Israel that economic assistance for the Jewish State is being suspended"
  - Supports:
    - In October 1953 the United States suspended economic aid (about $65 million for fiscal 1954) over Israel's Bnot Yaakov canal project near the Syrian frontier

**[S5103]** Jewish Telegraphic Agency, 'Israel Sends Note to United Nations on Jordan Canal Issue', Daily Bulletin, 20 October 1953 — https://www.jta.org/archive/israel-sends-note-to-united-nations-on-jordan-canal-issue — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2 1948-1965 data agent; page opened with curl and the quote checked verbatim on 2026-10-12. 
  - Quote: "The decision to continue work on the project was taken at a meeting yesterday of the Israel Cabinet."
  - Supports:
    - On 19 October 1953 the Israeli Cabinet decided to continue work on the Bnot Yaakov canal despite the demand of UN truce chief Bennike to halt it; Syria complained to the Security Council

**[S5104]** Jewish Telegraphic Agency, 'U.S. Aid to Israel Restored; Will Get $26,000,000 for Six Months', Daily Bulletin, 29 October 1953 — https://www.jta.org/archive/u-s-aid-to-israel-restored-will-get-26000000-for-six-months — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2 1948-1965 data agent; page opened with curl and the quote checked verbatim on 2026-10-12. 
  - Quote: "agreed that the work started by Israel in the demilitarized zone would be suspended pending urgent examination of the question by the Council"
  - Supports:
    - Israel agreed in the Security Council to suspend the canal work in the demilitarised zone, and the United States resumed a grant of about $26 million for six months (announced 29 October 1953)

**[S5105]** Jewish Telegraphic Agency, 'Israel Cabinet Formally Accepts Ben Gurion As Defense Minister', Daily Bulletin, 21 February 1955 — https://www.jta.org/archive/israel-cabinet-formally-accepts-ben-gurion-as-defense-minister — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2 1948-1965 data agent; page opened with curl and the quote checked verbatim on 2026-10-12. 
  - Quote: "These papers charged that no consideration had been given to the fact that Israel is governed by a coalition"
  - Supports:
    - In February 1955 Lavon resigned after Sharett refused his proposals for changes in the defence set-up; Ben-Gurion returned as Defence Minister without consulting the coalition partners, which General Zionist and Mizrachi papers criticised as a Mapai monopoly

**[S5106]** Jewish Telegraphic Agency, 'Knesset Confirms Ben Gurion's Appointment; Lavon Pays Him Tribute', Daily Bulletin, 23 February 1955 — https://www.jta.org/archive/knesset-confirms-ben-gurions-appointment-lavon-pays-him-tribute — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2 1948-1965 data agent; page opened with curl and the quote checked verbatim on 2026-10-12. The quotation is Prime Minister Sharett's statement to the Knesset as reported.
  - Quote: "I felt convinced that no candidate would have the prospect of discharging the tasks more successfully"
  - Supports:
    - The Knesset confirmed Ben-Gurion as Defence Minister by 74 to 22 on 22 February 1955; Sharett defended the appointment; left-wing, Communist and Herut speakers declared no confidence

**[S5107]** Jewish Telegraphic Agency, 'Israel Cabinet Meets on Crisis Today; Envoy Back from Bonn Mission', Daily Bulletin, 30 December 1957 — https://www.jta.org/archive/israel-cabinet-meets-on-crisis-today-envoy-back-from-bonn-mission — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2 1948-1965 data agent; page opened with curl and the quote checked verbatim on 2026-10-12. 
  - Quote: "Achdut Avoda leaders Itzhak Bar Yehuda and Israel Ben Aharon said that they would not accept partnership in the government"
  - Supports:
    - In December 1957 a cabinet crisis broke over a planned senior mission to West Germany to negotiate arms purchases, leaked by Ahdut HaAvoda, and over Ben-Gurion's demands for secrecy and discipline, which Ahdut HaAvoda and Mapam resisted

**[S5108]** Jewish Telegraphic Agency, 'Ben Gurion Presents Reconstituted Cabinet to Knesset; Wins Approval', Daily Bulletin, 8 January 1958 — https://www.jta.org/archive/ben-gurion-presents-reconstituted-cabinet-to-knesset-wins-approval — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2 1948-1965 data agent; page opened with curl and the quote checked verbatim on 2026-10-12. 
  - Quote: "Ministers bind themselves to preserve complete secrecy in matters of security and foreign policy"
  - Supports:
    - On 8 January 1958 Ben-Gurion presented a reconstituted five-party coalition (Mapai, Mapam, Ahdut HaAvoda, Progressives, religious) with collective responsibility and secrecy rules, and told the Knesset the mission concerned arms purchases in West Germany

**[S5109]** Jewish Telegraphic Agency, 'Israel's Interior Minister Changes 'Who's a Jew' Directives', Daily Bulletin, 4 January 1960 — https://www.jta.org/archive/israels-interior-minister-changes-whos-a-jew-directives — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2 1948-1965 data agent; page opened with curl and the quote checked verbatim on 2026-10-12. The headline uses curly quotation marks in the original.
  - Quote: "only persons with a Jewish mother or persons who undergo religious conversion may be registered as Jews"
  - Supports:
    - In 1958 Interior Minister Israel Bar-Yehuda (Mapam) issued registry rules letting a person register as a Jew on his own declaration, provoking the 'Who is a Jew?' controversy; in January 1960 Minister Moshe Shapira (Mizrachi) cancelled them and required a Jewish mother or conversion

**[S5110]** Jewish Telegraphic Agency, 'Johnson Plan on Solving Arab Refugee Problem Reported in Washington', Daily Bulletin, 3 October 1962 — https://www.jta.org/archive/johnson-plan-on-solving-arab-refugee-problem-reported-in-washington — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2 1948-1965 data agent; page opened with curl and the quote checked verbatim on 2026-10-12. 
  - Quote: "Israel would retain the right to reject individual Arabs as security risks, subject to UN over-all surveillance and review."
  - Supports:
    - The reported Johnson plan of October 1962: individual refugees choose return to Israel, resettlement in Arab countries or elsewhere; no ceiling on returns, Israel keeps a security veto; Israel to pay indemnities and contribute to a UN fund

**[S5111]** Jewish Telegraphic Agency, 'U.S. Supports Johnson's Plan on Settlement of Arab Refugee Problem', Daily Bulletin, 4 October 1962 — https://www.jta.org/archive/u-s-supports-johnsons-plan-on-settlement-of-arab-refugee-problem — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2 1948-1965 data agent; page opened with curl and the quote checked verbatim on 2026-10-12. 
  - Quote: "had “no objections” to the proposals for settlement of the Arab refugee problem advanced by Dr. Joseph E. Johnson"
  - Supports:
    - The US State Department said on 4 October 1962 it had no objections to Dr. Johnson's refugee proposals; France and Turkey were not inclined to support them

**[S5112]** Jewish Telegraphic Agency, 'Republican Party Opposes Dr. Johnson's Plan on Arab Refugees', Daily Bulletin, 12 October 1962 — https://www.jta.org/archive/republican-party-opposes-dr-johnsons-plan-on-arab-refugees — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2 1948-1965 data agent; page opened with curl and the quote checked verbatim on 2026-10-12. 
  - Quote: "a realistic plan upon which both sides can agree and which would not threaten the economic or political viability of the State of Israel, and ensure adequate compensation to those refugees entitled to it"
  - Supports:
    - Republican National Committee chairman William E. Miller opposed the Johnson plan on 12 October 1962, calling instead for a plan both sides can agree on that ensures adequate compensation without threatening Israel's viability

**[S5113]** Jewish Telegraphic Agency, 'Arabs, Israel Reject New, Secret Johnson Plan on Arab Refugees', Daily Bulletin, 18 October 1962 — https://www.jta.org/archive/arabs-israel-reject-new-secret-johnson-plan-on-arab-refugees — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2 1948-1965 data agent; page opened with curl and the quote checked verbatim on 2026-10-12. 
  - Quote: "Mrs. Golda Meir, Israel’s Foreign Minister, rejected the plan on behalf of her Government"
  - Supports:
    - Foreign Minister Golda Meir rejected the Johnson plan for Israel because Israel reserves the absolute right to decide on admissions; Arab states rejected it because it mentioned resettlement

**[S5114]** Jewish Telegraphic Agency, 'Israel Demands Bonn Recall Nuclear Scientists from Egypt', Daily Bulletin, 21 March 1963 — https://www.jta.org/archive/israel-demands-bonn-recall-nuclear-scientists-from-egypt — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2 1948-1965 data agent; page opened with curl and the quote checked verbatim on 2026-10-12. 
  - Quote: "If legislative or other measures are required for that purpose, we demand that such measures be taken at once"
  - Supports:
    - On 20 March 1963 Foreign Minister Meir told the Knesset, in a statement approved by the Cabinet, that Israel demanded Bonn stop German scientists working on weapons for Egypt; the Foreign Ministry had contemplated a White Book

**[S5115]** Jewish Telegraphic Agency, 'Knesset Asks Germany to End Activity of Her Scientists in Egypt', Daily Bulletin, 22 March 1963 — https://www.jta.org/archive/knesset-asks-germany-to-end-activity-of-her-scientists-in-egypt — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2 1948-1965 data agent; page opened with curl and the quote checked verbatim on 2026-10-12. 
  - Quote: "it was the duty of the West German Government to put an immediate end to the"
  - Supports:
    - The Knesset passed a unanimous resolution on 20 March 1963 urging Bonn to end the scientists' work and calling on world opinion to act

**[S5116]** Jewish Telegraphic Agency, 'Israel Will Continue to Seek Recall of German Scientists from Egypt', Daily Bulletin, 2 April 1963 — https://www.jta.org/archive/israel-will-continue-to-seek-recall-of-german-scientists-from-egypt — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2 1948-1965 data agent; page opened with curl and the quote checked verbatim on 2026-10-12. 
  - Quote: "he objected to the fact that the essential factors of the Middle East arms and security balance have not been placed in focus"
  - Supports:
    - Ben-Gurion differed with his former security chief over handling of the scientists case and told the Knesset committee that the Middle East arms and security balance had not been put in focus; Mapam, the Liberals and Herut demanded a session on the security chief's resignation

**[S5117]** Jewish Telegraphic Agency, 'Knesset Rejects Motions to Discuss Role of German Scientists in Egypt', Daily Bulletin, 5 July 1963 — https://www.jta.org/archive/knesset-rejects-motions-to-discuss-role-of-german-scientists-in-egypt — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2 1948-1965 data agent; page opened with curl and the quote checked verbatim on 2026-10-12. 
  - Quote: "The opposition speakers argued that these press reports had sabotaged the campaign to rally world opinion against the German scientists."
  - Supports:
    - On 4 July 1963 the Knesset rejected, 48 to 33, motions from Herut, Mapam, the Liberals and the Communists for a general debate; the opposition said official press leaks sabotaged the world-opinion campaign and Meir said further debate was redundant

**[S5118]** Jewish Telegraphic Agency, 'Israel Cabinet Discusses Results of the Arab Summit Meeting in Cairo', Daily Bulletin, 20 January 1964 — https://www.jta.org/archive/israel-cabinet-discusses-results-of-the-arab-summit-meeting-in-cairo — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2 1948-1965 data agent; page opened with curl and the quote checked verbatim on 2026-10-12. 
  - Quote: "the Israel Government will not let itself be drawn into the orbit of artificial tensions which the Arab states are trying to create"
  - Supports:
    - After the January 1964 Cairo Arab summit, which decided to divert the Jordan headwaters and set up a joint military command, the Israeli cabinet was assumed to warn against aggression but not be drawn into artificial tensions

**[S5119]** Jewish Telegraphic Agency, 'Eshkol Pledges to Use Jordan Waters Within Johnston Allocations', Daily Bulletin, 22 January 1964 — https://www.jta.org/archive/eshkol-pledges-to-use-jordan-waters-within-johnston-allocations — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2 1948-1965 data agent; page opened with curl and the quote checked verbatim on 2026-10-12. 
  - Quote: "Warning that Israel would not be deterred from carrying out its irrigation project by Arab threats, Premier Levi Eshkol declared in Parliament"
  - Supports:
    - Eshkol told the Knesset in January 1964 that Israel would draw from Lake Tiberias only within the Johnston plan quantities and would not be deterred by Arab threats

**[S5120]** Jewish Telegraphic Agency, 'Israel Government Warns Lebanon on Diversion of Jordan River Waters', Daily Bulletin, 16 July 1965 — https://www.jta.org/archive/israel-government-warns-lebanon-on-diversion-of-jordan-river-waters — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2 1948-1965 data agent; page opened with curl and the quote checked verbatim on 2026-10-12. 
  - Quote: "the Israeli army had scored two direct hits on Syrian equipment used for such work"
  - Supports:
    - By July 1965 the Israeli army had twice hit Syrian equipment used for diverting the Jordan headwaters, and Chief of Staff Rabin warned Lebanon it would bear responsibility for the consequences of diversion work

**[S5125]** Jewish Telegraphic Agency, 'Israeli Government Urged to Give Priority to Fight on Unemployment' (1 Sep 1966) — https://www.jta.org/archive/israeli-government-urged-to-give-priority-to-fight-on-unemployment — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1966 data agent; page fetched with curl-style request (browser user-agent) on 2026-10-12 and each fork quote checked verbatim against the raw page text.
  - Quote: "Mapam holds that the Sapir plan bears too heavily on the wage earners."
  - Supports:
    - Coalition split over Sapir's austerity plan: Mapam says it bears too heavily on wage earners and wants a compulsory loan; Mapai's Tel Aviv branch and Histadrut leaders press for action on joblessness (24,000 unemployed, 45,000 projected by January 1967)

**[S5126]** Jewish Telegraphic Agency, 'Israel's New Economic Program Explained by Minister of Finance' (13 Sep 1966) — https://www.jta.org/archive/israels-new-economic-program-explained-by-minister-of-finance — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1966 data agent; page fetched with curl-style request (browser user-agent) on 2026-10-12 and each fork quote checked verbatim against the raw page text.
  - Quote: "Mr. Sapir has been the principal architect of the new economic plan which was adopted by the Cabinet last night"
  - Supports:
    - Cabinet adopted Sapir's three-year 'Outline of Economic Activity' on 12 Sep 1966: wage and price freeze, lower cost-of-living allowances, a capital-gains tax, an export drive, and acknowledged temporary unemployment

**[S5127]** Jewish Telegraphic Agency, 'Israel Seen Giving Serious Consideration to Sadat Proposal to Reopen Suez Canal' (8 Feb 1971) — https://www.jta.org/archive/israel-seen-giving-serious-consideration-to-sadat-proposal-to-reopen-suez-canal — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1966 data agent; page fetched with curl-style request (browser user-agent) on 2026-10-12 and each fork quote checked verbatim against the raw page text.
  - Quote: "Chaim Tzadok, declared today that President Sadat"
  - Supports:
    - Sadat offered to reopen the Canal against a partial Israeli withdrawal and tied further ceasefire extension to a withdrawal timetable; ministers and Knesset committee chairman Chaim Tzadok said the offer should be explored

**[S5128]** Jewish Telegraphic Agency, 'Detailed Proposal for Interim Agreement Reported Ready for Cabinet Meeting' (14 Apr 1971) — https://www.jta.org/archive/detailed-proposal-for-interim-agreement-reported-ready-for-cabinet-meeting — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1966 data agent; page fetched with curl-style request (browser user-agent) on 2026-10-12 and each fork quote checked verbatim against the raw page text.
  - Quote: "consists of Deputy Premier Yigal Allon, Foreign Minister Abba Eban, Defense Minister Moshe Dayan and Minister-Without-Portfolio Israel Galili"
  - Supports:
    - Meir's inner circle (Allon, Eban, Dayan, Galili) prepared an offer to reopen the Canal with an 8 km Israeli pullback if Egypt ended belligerency; Beigin demanded the canal be separated from withdrawal and opposed any retreat

**[S5129]** Jewish Telegraphic Agency, 'Coalition Government on Verge of Breakup; Gahal Decides to Resign if U.S. Plan Accepted' (31 Jul 1970) — https://www.jta.org/archive/coalition-government-on-verge-of-breakup-gahal-decides-to-resign-if-u-s-plan-accepted — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1966 data agent; page fetched with curl-style request (browser user-agent) on 2026-10-12 and each fork quote checked verbatim against the raw page text.
  - Quote: "Menachem Beigin, the 56-year-old co-founder and leader of Herut. said his opposition to the U.S. Initiative was not exaggerated"
  - Supports:
    - Gahal voted 14-9 to quit if the cabinet accepted the US initiative; Labor leaders favoured acceptance; Gahal also rejected Sapir's offer to stay in cabinet while opposing the plan

**[S5130]** Jewish Telegraphic Agency, 'Gahal Quits Cabinet; Beigin Charges U.S. Plan Makes Israel Another Czechoslovakia' (5 Aug 1970) — https://www.jta.org/archive/gahal-quits-cabinet-beigin-charges-u-s-plan-makes-israel-another-czechoslovakia — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1966 data agent; page fetched with curl-style request (browser user-agent) on 2026-10-12 and each fork quote checked verbatim against the raw page text.
  - Supports:
    - Gahal voted 117-112 to leave the national unity government; the coalition kept 72 of 120 seats; Herut's Begin prevailed over the Liberals who wished to stay

**[S5131]** Jewish Telegraphic Agency, 'Government Leaders Cite U.S. Guarantees As Basis for Having Accepted Peace Plan' (6 Aug 1970) — https://www.jta.org/archive/government-leaders-cite-u-s-guarantees-as-basis-for-having-accepted-peace-plan — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1966 data agent; page fetched with curl-style request (browser user-agent) on 2026-10-12 and each fork quote checked verbatim against the raw page text.
  - Quote: "Deputy Premier Yigal Allon and Foreign Minister Abba Eban staunchly defended the government"
  - Supports:
    - Knesset voted 66-28 for acceptance; Allon and Eban defended it citing undisclosed US assurances on withdrawal and arms supply

**[S5132]** Jewish Telegraphic Agency, 'Weizman Favors Early Withdrawal of Israeli Forces from South Lebanon' (23 Mar 1978) — https://www.jta.org/archive/weizman-favors-early-withdrawal-of-israeli-forces-from-south-lebanon — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1966 data agent; page fetched with curl-style request (browser user-agent) on 2026-10-12 and each fork quote checked verbatim against the raw page text.
  - Quote: "Amnon Rubinstein, of the Democratic Movement for Change, Meir Talmi of Mapam, Yossi Sarid of the Labor Party and others blamed Israel"
  - Supports:
    - Weizman wanted early withdrawal to protect the Egyptian track; opposition MKs blamed the widening of the original six-mile belt for the Lebanese refugee problem

**[S5133]** Jewish Telegraphic Agency, 'Begin Announces That Operation in Lebanon Concluded with Israeli Forces in Control of 100-km Security Belt' (16 Mar 1978) — https://www.jta.org/archive/begin-announces-that-operation-in-lebanon-concluded-with-israeli-forces-in-control-of-100-km-securit — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1966 data agent; page fetched with curl-style request (browser user-agent) on 2026-10-12 and each fork quote checked verbatim against the raw page text.
  - Quote: "was effectively concluded with Israeli forces in control of a 100-kilometer security belt along the Lebanese border of an average depth of 10 kilometers"
  - Supports:
    - Israel held a 100 km belt about 10 km deep; Begin said forces would stay or control the area until an arrangement kept terrorists out

**[S5134]** Jewish Telegraphic Agency, 'Cabinet in 11-hour Debate on the Peace Treaty' (25 Oct 1978) — https://www.jta.org/archive/cabinet-in-11-hour-debate-on-the-peace-treaty-indications-are-the-treaty-will-be-approved-by-majori — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1966 data agent; page fetched with curl-style request (browser user-agent) on 2026-10-12 and each fork quote checked verbatim against the raw page text.
  - Quote: "Yehuda Ben-Meir, chairman of the National Religious Party (NRP) Knesset faction"
  - Supports:
    - Cabinet split on the draft treaty with Egypt; the NRP's Ben-Meir objected to the preamble's linkage to a wider settlement

**[S5135]** Jewish Telegraphic Agency, 'Begin Congratulates Sadat ... After Knesset Votes 95-18 to Approve Peace Treaty' (23 Mar 1979) — https://www.jta.org/archive/begin-congratulates-sadat-on-his-peace-move-after-knesset-votes-95-18-to-approve-peace-treaty — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1966 data agent; page fetched with curl-style request (browser user-agent) on 2026-10-12 and each fork quote checked verbatim against the raw page text.
  - Quote: "The Knesset overwhelmingly approved the Israeli-Egyptian peace treaty by a 95-18 majority"
  - Supports:
    - Knesset approved the Israeli-Egyptian treaty 95-18 with 2 abstentions; seven Likud MKs including Geula Cohen and Moshe Arens, four NRP MKs and Rakah voted against

**[S5136]** Jewish Telegraphic Agency, 'Report U.S. Package Deal to Resolve Lebanon Crisis Includes Curtailment of Israeli Air Flights' (14 May 1981) — https://www.jta.org/archive/report-u-s-package-deal-to-resolve-lebanon-crisis-includes-curtailment-of-israeli-air-flights — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1966 data agent; page fetched with curl-style request (browser user-agent) on 2026-10-12 and each fork quote checked verbatim against the raw page text.
  - Quote: "U.S. special envoy Philip Habib left for Damascus today, reportedly with a proposed American package to resolve the crisis between Israel and Syria"
  - Supports:
    - Habib took an American package to Damascus after Syria deployed SAM-6 missiles in the Bekaa; it reportedly included curtailing Israeli operational flights over Lebanon; Peres said diplomacy should be given time

**[S5137]** Jewish Telegraphic Agency, 'Begin Says He's Giving Habib Ample Time to Resolve Missile Crisis with Syria' (19 Jun 1981) — https://www.jta.org/archive/begin-says-hes-giving-habib-ample-time-to-resolve-missile-crisis-with-syria — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1966 data agent; page fetched with curl-style request (browser user-agent) on 2026-10-12 and each fork quote checked verbatim against the raw page text.
  - Quote: "said after a two hour meeting with U.S. special envoy Philip Habib this morning that he would give the American diplomat"
  - Supports:
    - Begin said he would give Habib ample time but that if the missiles are not removed 'we shall see to it that they get out'

**[S5138]** Jewish Telegraphic Agency, 'Israel Will Permit Another Week for U.S. Diplomatic Efforts to Defuse Crisis in Lebanon' (26 May 1981) — https://www.jta.org/archive/israel-will-permit-another-week-for-u-s-diplomatic-efforts-to-defuse-crisis-in-lebanon-before-consi — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1966 data agent; page fetched with curl-style request (browser user-agent) on 2026-10-12 and each fork quote checked verbatim against the raw page text.
  - Supports:
    - Israel allowed more time for US mediation before considering a military option; third Israeli drone shot down; Begin demanded removal of launchers in Lebanon and a pullback inside Syria

**[S5139]** Jewish Telegraphic Agency, 'Cabinet Sidesteps Issue of Inquiry Commission on the Massacre in Refugee Camps' (22 Sep 1982) — https://www.jta.org/archive/cabinet-sidesteps-issue-of-inquiry-commission-on-the-massacre-in-refugee-camps — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1966 data agent; page fetched with curl-style request (browser user-agent) on 2026-10-12 and each fork quote checked verbatim against the raw page text.
  - Supports:
    - Cabinet took no decision on an inquiry after the Sabra and Shatila killings of at least 300 Palestinian civilians by Lebanese Christian forces; President Navon, Labor, the NRP, Tehiya and Tami favoured an inquiry

**[S5140]** Jewish Telegraphic Agency, 'Knesset, by Vote of 48-42, Rejects Motion by Labor to Set Up a Commission of Inquiry' (23 Sep 1982) — https://www.jta.org/archive/knesset-by-vote-of-48-42-rejects-motion-by-labor-to-set-up-a-commission-of-inquiry-into-massacre-o — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1966 data agent; page fetched with curl-style request (browser user-agent) on 2026-10-12 and each fork quote checked verbatim against the raw page text.
  - Quote: "Premier Menachem Begin who strongly opposed an official inquiry on grounds that it would be an admission of Israeli guilt for the blood bath"
  - Supports:
    - Knesset rejected Labor's motion 48-42; Begin opposed an official inquiry as an admission of guilt; Energy Minister Berman and West Bank civil administration head Milson resigned

**[S5141]** Jewish Telegraphic Agency, 'Unanimous Cabinet Decision: a Judicial Commission Will Conduct Full, Formal Inquiry into Massacre' (29 Sep 1982) — https://www.jta.org/archive/unanimous-cabinet-decision-a-judicial-commission-will-conduct-full-formal-inquiry-into-massacre-of — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1966 data agent; page fetched with curl-style request (browser user-agent) on 2026-10-12 and each fork quote checked verbatim against the raw page text.
  - Quote: "Begin himself proposed the judicial commission and it was then unanimously approved"
  - Supports:
    - On 28 Sep 1982 the cabinet unanimously set up a judicial commission with broad terms of reference, no time limit, after reversing its 21 Sep refusal

**[S5142]** Jewish Telegraphic Agency, 'Begin Says He Regards Himself, As the Premier, As Fully Responsible for Beirut Massacre' (30 Sep 1982) — https://www.jta.org/archive/begin-says-he-regards-himself-as-the-premier-as-fully-responsible-for-beirut-massacre — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1966 data agent; page fetched with curl-style request (browser user-agent) on 2026-10-12 and each fork quote checked verbatim against the raw page text.
  - Quote: "Labor Alignment leaders continued to demand the resignation of Begin and Sharon"
  - Supports:
    - Begin accepted responsibility as Prime Minister; Labor Alignment leaders continued to demand that Begin and Sharon resign

**[S5150]** Fisher, Dan, 'Israelis Split Over Mideast Talks: Inner Cabinet Follows Party Lines; Shamir Fears a Trap', Los Angeles Times, 12 May 1987 — https://www.latimes.com/archives/la-xpm-1987-05-12-mn-7760-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1986 data agent; page opened via curl with a browser user-agent and the quote checked as a verbatim substring of the page text.
  - Quote: "Foreign Minister Shimon Peres, who formally presented the proposal to the so-called “inner Cabinet” for the first time Monday, has threatened to pull his centrist Labor Alignment out of the fragile coalition government"
  - Supports:
    - Peres presents the international-conference proposal to the inner cabinet; Shamir, Sharon and Likud oppose it; Rabin proposes a Shultz shuttle; the inner cabinet is evenly split, May 1987

**[S5151]** 'Peres Demands Shamir Quit: Coalition Parties Deadlocked on Peace Talk Plans', Associated Press, Los Angeles Times, 13 May 1987 — https://www.latimes.com/archives/la-xpm-1987-05-13-mn-4317-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1986 data agent; page opened via curl with a browser user-agent and the quote checked as a verbatim substring of the page text.
  - Quote: "Foreign Minister Shimon Peres today demanded that Prime Minister Yitzhak Shamir resign after the coalition government reached a deadlock on a proposed Middle East peace conference."
  - Supports:
    - Peres and Rabin call for new elections; Shamir answers that the national unity government must continue, May 1987

**[S5152]** 'Peace Talks Would End in National Suicide: Shamir', Associated Press, Los Angeles Times, 10 Apr 1987 — https://www.latimes.com/archives/la-xpm-1987-04-10-mn-343-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1986 data agent; page opened via curl with a browser user-agent and the quote checked as a verbatim substring of the page text.
  - Quote: "Shamir said the conference idea, supported by the Soviet Union and Arab states, was a trap designed to force Israel to relinquish territories captured in the 1967 Middle East war, including Jerusalem."
  - Supports:
    - Shamir calls an international conference 'national suicide'; Peres says the remarks could break up the coalition, April 1987

**[S5153]** Parks, Michael, 'Israel Bars Assistance to Deportees', Los Angeles Times, 26 Dec 1992 — https://www.latimes.com/archives/la-xpm-1992-12-26-mn-2255-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1986 data agent; page opened via curl with a browser user-agent and the quote checked as a verbatim substring of the page text.
  - Quote: "After a bitter debate that left Prime Minister Yitzhak Rabin’s government sharply divided, Israel’s Cabinet voted Friday to bar the Red Cross from sending food, water and medicine through Israeli-controlled territory to 415 Palestinians expelled into Lebanon last week."
  - Supports:
    - Cabinet splits 8-6 on Red Cross access for the 415 deportees; Rabin, Deri and Ben-Eliezer against, Peres, Baram and Meretz ministers for, Dec 1992

**[S5154]** Parks, Michael, 'Israel Declares Deportation Crisis Over, Turns to Talks', Los Angeles Times, 14 Feb 1993 — https://www.latimes.com/archives/la-xpm-1993-02-14-mn-437-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1986 data agent; page opened via curl with a browser user-agent and the quote checked as a verbatim substring of the page text.
  - Quote: "Israel declared Saturday that the prolonged crisis over the 415 Palestinians exiled to southern Lebanon eight weeks ago is finished following the U.N. Security Council’s acceptance of Jerusalem’s pledge to return all the men by the end of this year."
  - Supports:
    - Israel pledges to return all 415 deportees by the end of 1993, 101 at once; UN Security Council accepts, Feb 1993

**[S5155]** Miller, Marjorie, 'Bitter Debate in Israel Over Accord', Los Angeles Times, 6 Oct 1995 — https://www.latimes.com/archives/la-xpm-1995-10-06-mn-53770-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1986 data agent; page opened via curl with a browser user-agent and the quote checked as a verbatim substring of the page text.
  - Quote: "Prime Minister Yitzhak Rabin on Thursday urged the Knesset to “give peace a chance” and ratify his agreement with Palestinian leader Yasser Arafat to turn over control of much of the Israeli-occupied West Bank."
  - Supports:
    - Rabin, Netanyahu and Meretz positions in the Knesset debate on the interim agreement; six towns, 450 villages and a partial Hebron redeployment, Oct 1995

**[S5156]** Miller, Marjorie, 'Israel Parliament Ratifies PLO Pact', Los Angeles Times, 6 Oct 1995 — https://www.latimes.com/archives/la-xpm-1995-10-06-mn-53956-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1986 data agent; page opened via curl with a browser user-agent and the quote checked as a verbatim substring of the page text.
  - Quote: "The 61-59 vote that Rabin called a motion of confidence in his center-left coalition government mirrors the deep schism in Israel over the peace agreement with Palestine Liberation Organization Chairman Yasser Arafat."
  - Supports:
    - Knesset ratifies the interim agreement 61-59 on 6 October 1995

**[S5157]** Miller, Marjorie, 'Israeli Party Looks to Election to Kill Peace Pact', Los Angeles Times, 5 Oct 1995 — https://www.latimes.com/archives/la-xpm-1995-10-05-mn-53653-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1986 data agent; page opened via curl with a browser user-agent and the quote checked as a verbatim substring of the page text.
  - Quote: "The right-wing opposition failed to prevent Prime Minister Yitzhak Rabin from signing the interim accord giving Palestinians control over much of the West Bank land that Israel captured in the 1967 Arab-Israeli War"
  - Supports:
    - Netanyahu on opposing the interim agreement and starting 'from scratch', Oct 1995

**[S5158]** Curtius, Mary, 'Peres Weighs Early Vote Amid Party’s Cries of Now or Never', Los Angeles Times, 27 Jan 1996 — https://www.latimes.com/archives/la-xpm-1996-01-27-mn-29243-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1986 data agent; page opened via curl with a browser user-agent and the quote checked as a verbatim substring of the page text.
  - Quote: "Thrilled by public opinion polls that show that 50% of voters would vote for Peres as prime minister if elections were held tomorrow (with only 29% saying they would vote for his Likud rival, Benjamin Netanyahu)"
  - Supports:
    - Peres weighs early elections after Rabin's assassination; Zvilli and Labor urge May; Syria talks at Wye Plantation; first direct election of the PM, Jan 1996

**[S5159]** Curtius, Mary, 'Peres Seizes on Popularity, Calls Early Vote', Los Angeles Times, 12 Feb 1996 — https://www.latimes.com/archives/la-xpm-1996-02-12-mn-35111-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1986 data agent; page opened via curl with a browser user-agent and the quote checked as a verbatim substring of the page text.
  - Quote: "Israeli Prime Minister Shimon Peres told the nation Sunday that parliamentary elections will be moved up from October to late May."
  - Supports:
    - Peres announces on 11 February 1996 that elections will be advanced to late May; Netanyahu's Likud backs an early vote

**[S5160]** Trounson, Rebecca, 'Violence Feared as Israel OKs New Housing', Los Angeles Times, 27 Feb 1997 — https://www.latimes.com/archives/la-xpm-1997-02-27-mn-33009-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1986 data agent; page opened via curl with a browser user-agent and the quote checked as a verbatim substring of the page text.
  - Quote: "Israel gave all-but-final approval Wednesday for a new Jewish neighborhood in East Jerusalem, ignoring international concerns and Palestinian warnings that the construction could set off a fresh round of violence and threaten the fragile peace process."
  - Supports:
    - Approval of Har Homa (2,456 first-phase apartments of 6,500) and 3,015 units for Arabs; King Hussein and the White House object; many Israelis including Labor back the project, Feb 1997

**[S5161]** Abrams, Mitch, 'Construction at Har Homa could begin in two weeks', Jewish Telegraphic Agency (dateline 26 Feb 1997; archive page dated 5 Jun 1997) — https://www.jta.org/1997/06/05/lifestyle/construction-at-har-homa-could-begin-in-two-weeks-2 — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1986 data agent; page opened via curl with a browser user-agent and the quote checked as a verbatim substring of the page text.
  - Quote: "The Har Homa project has been vehemently opposed by Palestinians and just as strongly endorsed by members of Netanyahu’s Likud-led Cabinet as well as several Labor Knesset members."
  - Supports:
    - Netanyahu: 'We will build in all of Jerusalem. We will also build at Har Homa'; Palestinian warnings; 3,000 units for Arabs in ten neighbourhoods, Feb 1997

**[S5162]** Trounson, Rebecca, 'Tension Flares as Israelis Begin Housing Project', Los Angeles Times, 19 Mar 1997 — https://www.latimes.com/archives/la-xpm-1997-03-19-mn-39887-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1986 data agent; page opened via curl with a browser user-agent and the quote checked as a verbatim substring of the page text.
  - Quote: "Bulldozers guarded by hundreds of heavily armed Israeli troops broke ground Tuesday for a new Jewish neighborhood in East Jerusalem"
  - Supports:
    - Groundbreaking at Har Homa on 18 March 1997

**[S5163]** Trounson, Rebecca, 'What to Do About Shas Obsesses Israelis', Los Angeles Times, 25 May 1999 — https://www.latimes.com/archives/la-xpm-1999-may-25-mn-40836-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1986 data agent; page opened via curl with a browser user-agent and the quote checked as a verbatim substring of the page text.
  - Quote: "“Just Not Shas!” was the message on more than 20,000 e-mails that have flooded into Barak’s Tel Aviv office in recent days, staff members said, as voters have appealed to the newly elected Israeli leader to keep Shas in opposition."
  - Supports:
    - Pressure on Barak to exclude Shas, and calls (Avnery) to include it; Shas grew from 10 to 17 seats, May 1999

**[S5164]** Wilkinson, Tracy, 'Israel’s Likud Party Quits Talks With Barak', Los Angeles Times, 29 Jun 1999 — https://www.latimes.com/archives/la-xpm-1999-jun-29-mn-51200-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1986 data agent; page opened via curl with a browser user-agent and the quote checked as a verbatim substring of the page text.
  - Quote: "Likud insists that Israel not withdraw from the Golan Heights, and also wanted veto power over Barak’s peacemaking decisions."
  - Supports:
    - Likud (Sharon) walks out of coalition talks over Golan and a veto; Barak wants as broad a coalition as possible; Meretz threatens to boycott Shas, 29 Jun 1999

**[S5165]** Wilkinson, Tracy, 'Israeli Premier-Elect’s Bid to Form Coalition Government Taking Shape', Los Angeles Times, 28 Jun 1999 — https://www.latimes.com/archives/la-xpm-1999-jun-28-mn-50901-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1986 data agent; page opened via curl with a browser user-agent and the quote checked as a verbatim substring of the page text.
  - Quote: "Rather than seizing immediate momentum, Barak has used the time since his election to engage in torturous negotiations with disparate political parties in a bid to form a broad coalition government."
  - Supports:
    - Barak seeks a 90-seat majority; Meretz, Yisrael Ba'aliya and the NRP sign up; Likud might get the finance portfolio, 28 Jun 1999

**[S5166]** 'With Diverse Coalition, Barak Faces Tough Battle in Getting Major Change', Los Angeles Times, 2 Jul 1999 — https://www.latimes.com/archives/la-xpm-1999-jul-02-mn-52323-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1986 data agent; page opened via curl with a browser user-agent and the quote checked as a verbatim substring of the page text.
  - Quote: "The middle-of-the-road Center Party, with six seats, finally agreed to join Thursday, after much internal debate over how much power it would get."
  - Supports:
    - Barak's 75-seat coalition includes Shas (largest partner after Labor), Meretz (10 seats) and the Center Party, 2 Jul 1999

**[S5167]** Wilkinson, Tracy, 'Sharon Rejects Settlement Curbs', Los Angeles Times, 9 May 2001 — https://www.latimes.com/archives/la-xpm-2001-may-09-mn-61240-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1986 data agent; page opened via curl with a browser user-agent and the quote checked as a verbatim substring of the page text.
  - Quote: "Israeli Prime Minister Ariel Sharon on Tuesday categorically rejected U.S. and international calls to halt the expansion of Jewish settlements in the West Bank and Gaza Strip and instead vowed to continue building new homes on occupied land."
  - Supports:
    - Sharon rejects a settlement freeze on 8 May 2001: no new settlements but existing ones expand; about 200,000 settlers in 140 settlements among about 3 million Palestinians

**[S5168]** 'International Panel Calls for Freeze in Israeli Settlements', Associated Press, Los Angeles Times, 5 May 2001 — https://www.latimes.com/archives/la-xpm-2001-may-05-mn-59667-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1986 data agent; page opened via curl with a browser user-agent and the quote checked as a verbatim substring of the page text.
  - Quote: "Issuing a report on Israeli-Palestinian fighting, a commission led by former U.S. Sen. George J. Mitchell of Maine said Friday that Israel should freeze settlement construction, but it did not recommend sending an international force to the region."
  - Supports:
    - Mitchell committee calls for a freeze on settlement construction, 4 May 2001

**[S5169]** King, Laura, 'Sharon Ejects Main Allied Party From His Coalition', Los Angeles Times, 2 Dec 2004 — https://www.latimes.com/archives/la-xpm-2004-dec-02-fg-ispolitics2-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1986 data agent; page opened via curl with a browser user-agent and the quote checked as a verbatim substring of the page text.
  - Quote: "Prime Minister Ariel Sharon’s ruling coalition was in tatters Wednesday night after he tossed his main political partner out of the government for defying him on a key budget measure."
  - Supports:
    - Sharon ejects Shinui over about $65 million in subsidies routed through United Torah Judaism, Dec 2004

**[S5170]** Ellingwood, Ken, 'Lawmakers Narrowly Back Sharon’s New Government', Los Angeles Times, 11 Jan 2005 — https://www.latimes.com/archives/la-xpm-2005-jan-11-fg-coalition11-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1986 data agent; page opened via curl with a browser user-agent and the quote checked as a verbatim substring of the page text.
  - Quote: "Israeli Prime Minister Ariel Sharon narrowly won parliamentary approval Monday for a new governing alliance with the left-leaning Labor Party and a small religious party"
  - Supports:
    - Likud-Labor-UTJ government approved 58-56 on 10 Jan 2005; Lapid (Shinui) criticises the religious partner, Jan 2005

**[S5171]** Wilkinson, Tracy, 'Israel’s Barak Names Cabinet--After One Key Rejection', Los Angeles Times, 6 Jul 1999 — https://www.latimes.com/archives/la-xpm-1999-jul-06-mn-53394-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-1986 data agent; page opened via curl with a browser user-agent and the quote checked as a verbatim substring of the page text.
  - Quote: "He put together a seven-party ruling coalition holding 75 of 120 Knesset seats, a clear majority."
  - Supports:
    - Barak completes a seven-party, 75-seat coalition and is sworn in on 6 July 1999

**[S5175]** Jewish Journal (Leslie Susser), 'Barak stays after Winograd Report, Olmert survives', 8 Feb 2008 — https://jewishjournal.com/news/worldwide/16086/ — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-2006 data agent; page opened with curl (browser user-agent) and quote checked verbatim on 2026-10-12.
  - Quote: "But on Sunday Barak said he had decided to stay on as defense minister because of the serious security challenges Israel faces from Gaza, Hezbollah, Syria and Iran"
  - Supports:
    - Barak kept Labor in the Olmert coalition after the final Winograd report

**[S5176]** Christian Science Monitor (Ilene R. Prusher), 'Winograd Report revives Israeli anger over Lebanon war', 31 Jan 2008 — https://www.csmonitor.com/World/Middle-East/2008/0131/p07s03-wome.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-2006 data agent; page opened with curl (browser user-agent) and quote checked verbatim on 2026-10-12.
  - Quote: "Many bereaved families have joined together in their grief and are spearheading a movement to try to get Israeli Prime Minister Ehud Olmert to take personal responsibility for the war's failures and resign."
  - Supports:
    - Bereaved families sought Olmert's resignation; Barak had said he would force early elections

**[S5177]** JTA (Leslie Susser), 'Implications of Israeli inquiry into Goldstone present dilemma', 26 Oct 2009 — https://www.jta.org/2009/10/26/israel/implications-of-israeli-inquiry-into-goldstone-present-dilemma — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-2006 data agent; page opened with curl (browser user-agent) and quote checked verbatim on 2026-10-12.
  - Quote: "But Defense Minister Ehud Barak and the Israel Defense Forces are strongly against such an inquiry."
  - Supports:
    - Debate in the cabinet over an independent commission of inquiry into Cast Lead

**[S5178]** JTA (Marcy Oster), 'Israel to form task force on Goldstone report', 26 Oct 2009 — https://www.jta.org/2009/10/26/israel/israel-to-form-task-force-on-goldstone-report — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-2006 data agent; page opened with curl (browser user-agent) and quote checked verbatim on 2026-10-12.
  - Quote: ""No soldiers or officers will be brought before a commission of inquiry," Netanyahu said."
  - Supports:
    - Netanyahu appointed a task force under Justice Minister Neeman and ruled out a commission of inquiry

**[S5179]** JTA (Eric Fingerhut), 'Rabbis group calls for independent probe of Gaza war', 23 Oct 2009 — https://www.jta.org/2009/10/23/united-states/rabbis-group-calls-for-independent-probe-of-gaza-war — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-2006 data agent; page opened with curl (browser user-agent) and quote checked verbatim on 2026-10-12.
  - Quote: "Earlier this week, Israeli Deputy Prime Minister Dan Meridor said Israel should launch a "commission of inquiry or examination" to investigate war crimes charges."
  - Supports:
    - Meridor and Rabbis for Human Rights backed an independent inquiry

**[S5180]** JTA, 'Netanyahu rejects U.N.-proposed panel of inquiry', 6 Jun 2010 — https://www.jta.org/2010/06/06/israel/netanyahu-rejects-u-n-proposed-panel-of-inquiry — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-2006 data agent; page opened with curl (browser user-agent) and quote checked verbatim on 2026-10-12.
  - Quote: "U.N. Secretary-General Ban Ki-moon on Saturday night proposed a commission of inquiry headed by former New Zealand Prime Minister Geoffrey Palmer"
  - Supports:
    - Ban Ki-moon proposed the Palmer commission; Netanyahu rejected it

**[S5181]** JTA, 'Israel approves Gaza flotilla inquiry panel', 14 Jun 2010 — https://www.jta.org/2010/06/14/israel/israel-approves-gaza-flotilla-inquiry-panel — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-2006 data agent; page opened with curl (browser user-agent) and quote checked verbatim on 2026-10-12.
  - Quote: "Israel’s Cabinet unanimously approved a commission of inquiry into the interception of a Gaza-bound flotilla that left nine passengers dead."
  - Supports:
    - Cabinet approved the Turkel Commission with two foreign observers

**[S5182]** JTA (Ben Sales), 'Why are Israelis protesting government plan for natural gas fields?', 8 Dec 2015 — https://www.jta.org/2015/12/08/politics/why-are-israelis-protesting-plan-for-natural-gas-fields — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-2006 data agent; page opened with curl (browser user-agent) and quote checked verbatim on 2026-10-12.
  - Quote: "Netanyahu has proposed the Gas Outline, which would permit Noble-Delek to retain majority control of Leviathan for 10 years after the gas begins flowing in exchange for reducing its holdings in Tamar and two of the smaller fields."
  - Supports:
    - The Gas Outline, the Antitrust Commissioner's break-up warning and the nationalisation protests

**[S5183]** JTA, 'Israel’s Security Cabinet approves Turkey reconciliation deal', 29 Jun 2016 — https://www.jta.org/2016/06/29/israel/israels-security-cabinet-approves-turkey-reconciliation-deal — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-2006 data agent; page opened with curl (browser user-agent) and quote checked verbatim on 2026-10-12.
  - Quote: "with Defense Minister Avigdor Liberman, Education Minister Naftali Bennett and Justice Minister Ayelet Shaked dissenting."
  - Supports:
    - Security Cabinet vote 7-3 on the Turkey agreement

**[S5184]** JTA, 'Israel, Turkey sign reconciliation deal', 28 Jun 2016 — https://www.jta.org/2016/06/28/israel/israel-turkey-sign-reconciliation-deal — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-2006 data agent; page opened with curl (browser user-agent) and quote checked verbatim on 2026-10-12.
  - Quote: "“Israel has made an important strategic agreement in terms of security, regional stability and the Israeli economy,” Israeli Prime Minister Benjamin Netanyahu said Monday afternoon in Rome"
  - Supports:
    - Terms of the Israel-Turkey reconciliation agreement

**[S5185]** JTA, 'Bill legalizing some West Bank outposts, with eye on Amona, passes preliminary reading', 16 Nov 2016 — https://www.jta.org/2016/11/16/israel/bill-legalizing-some-west-bank-outposts-with-eye-on-amona-passes-preliminary-reading — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-2006 data agent; page opened with curl (browser user-agent) and quote checked verbatim on 2026-10-12.
  - Quote: "Jewish Home party leader Naftali Bennett and Justice Minister Ayelet Shaked brought the bill forward over the objections of Prime Minister Benjamin Netanyahu."
  - Supports:
    - Regulation Bill advocates and the attorney general's objection

**[S5186]** JTA, 'Israeli government to ask Supreme Court for 30 extra days to evacuate Amona outpost', 4 Dec 2016 — https://www.jta.org/2016/12/04/israel/israeli-government-to-ask-supreme-court-for-30-extra-days-to-evacuate-amona-outpost — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-2006 data agent; page opened with curl (browser user-agent) and quote checked verbatim on 2026-10-12.
  - Quote: "“We are working overtime to find a responsible solution to the issue of Amona and for similar cases in the future."
  - Supports:
    - Netanyahu's approach: delay, solution for Amona

**[S5187]** JTA (Andrew Tobin), 'Despite losing Amona, Israeli settlers expect to win war for West Bank', 3 Feb 2017 — https://www.jta.org/2017/02/03/israel/despite-losing-amona-israeli-settlers-expect-to-win-war-for-west-bank — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-2006 data agent; page opened with curl (browser user-agent) and quote checked verbatim on 2026-10-12.
  - Quote: "Over two sometimes violent days, security forces evacuated the residents of Amona, along with hundreds of protesters, as ordered by Israel’s High Court of Justice."
  - Supports:
    - Amona was evacuated in February 2017 and the state approved new settlement housing

**[S5188]** JTA (Ben Sales), 'Why Israel will hold a second national election in 2019', 29 May 2019 — https://www.jta.org/2019/05/29/israel/why-israel-could-hold-a-second-national-election-in-2019 — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-2006 data agent; page opened with curl (browser user-agent) and quote checked verbatim on 2026-10-12.
  - Quote: "Yisrael Beiteinu, headed by former Defense Minister Avigdor Liberman, wouldn’t join Netanyahu’s coalition unless the government passed a bill drafting some haredi men."
  - Supports:
    - The draft-bill deadlock that blocked Netanyahu's coalition in 2019

**[S5189]** JTA (Marcy Oster), 'Israel is holding new elections. What comes next?', 30 May 2019 — https://www.jta.org/2019/05/30/israel/israel-is-holding-new-elections-what-comes-next — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the forks-v2-2006 data agent; page opened with curl (browser user-agent) and quote checked verbatim on 2026-10-12.
  - Quote: "Liberman, representing right-wing secularists, wanted the legislation to be voted on as is, putting restrictions in place."
  - Supports:
    - Knesset dissolved; positions of Likud, Liberman and the haredi parties

**[S5190]** RETIRED (no longer cited; cited only by content dated after Q3 2023, deleted 2026-10-14 (the game ends 7 Oct 2023)) — JTA (Grace Gilson), 'Israel approves vast West Bank settlement plan that far-right minister said ‘practically erases the two-state delusion’', 20 Aug 2025 — https://www.jta.org/2025/08/20/israel/israel-approves-vast-west-bank-settlement-plan-that-far-right-minister-said-practically-erases-the-two-state-delusion

**[S5200]** Jewish Virtual Library, 'Basic Laws of Israel: The State Economy (1975, with amendments of 1982 and 1983)' — https://www.jewishvirtuallibrary.org/basic-law-the-state-economy — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the sim-v2 builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "The State Budget shall be prescribed by Law."
  - Supports:
    - The Israeli state budget is set by law, i.e. passed by the Knesset as a Budget Law

**[S5201]** Jewish Telegraphic Agency (JTA archive), 'In Familiar Ritual, Israel Struggles to Pass Budget by End of the Year' (2003-12-30) — https://www.jta.org/archive/in-familiar-ritual-israel-struggles-to-pass-budget-by-end-of-the-year — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the sim-v2 builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "If a budget isn’t passed by Dec. 31, spending continues at the previous year’s level and the new budget invariably is settled by March 31; otherwise, by law, the government falls."
  - Supports:
    - The Knesset must pass the annual budget (by Dec. 31, with a March 31 backstop) or the government falls
    - Israel's budget year is the calendar year in the 2000s

**[S5202]** Jewish Telegraphic Agency (JTA archive), 'Israeli Government Brought to Brink by Small Parties' Conflicting Demands' (1992-01-01) — https://www.jta.org/archive/israeli-government-brought-to-brink-by-small-parties-conflicting-demands — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the sim-v2 builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "But the Knesset was bound by law to pass the state budget by midnight Tuesday, so that it would be in place when the new fiscal year began Jan. 1."
  - Supports:
    - Israel's fiscal year began on 1 January 1992 (calendar-year budget from 1992)
    - The Knesset is bound by law to pass the state budget before the new fiscal year begins

**[S5203]** Jewish Telegraphic Agency (JTA archive), 'Record Il 19.8 Billion National Budget Adopted for 1973-74' (1973-01-09) — https://www.jta.org/archive/record-il-19-8-billion-national-budget-adopted-for-1973-74 — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the sim-v2 builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "If approved, the budget will go into effect April 1, the start of the new fiscal year."
  - Supports:
    - Before 1992 Israel's fiscal year began on 1 April (April-to-March budget year)

**[S5204]** Jewish Telegraphic Agency (JTA archive), 'Finance Minister Submits Record $2.243 Billion Budget, Calls It 'war Budget'' (1969-01-07) — https://www.jta.org/archive/finance-minister-submits-record-2-243-billion-budget-calls-it-war-budget — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the sim-v2 builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "He called it a “war budget” to emphasize that Israel’s number one priority this year is security although only 37 percent is earmarked for direct military expenditures."
  - Supports:
    - Defence/security took a large but not total share of the 1969 budget (37 percent direct military), with immigration the second priority

**[S5205]** Jewish Telegraphic Agency (JTA archive), 'Israel's 1957 Budget of 850,000,000 Pounds Presented to Parliament' (1957-01-15) — https://www.jta.org/archive/israels-1957-budget-of-850000000-pounds-presented-to-parliament — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the sim-v2 builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Mr. Eshkol disclosed that an increase in defense expenditures last year had necessitated a slowdown in development spending."
  - Supports:
    - Defence spending and development spending competed for the same budget in 1957
    - A rise in defence expenditure forced a slowdown in development spending

**[S5206]** Jewish Telegraphic Agency (JTA archive), 'Israel Budget for 1960 Will Total $852,000,000; Same As in 1959' (1959-12-22) — https://www.jta.org/archive/israel-budget-for-1960-will-total-852000000-same-as-in-1959 — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the sim-v2 builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Next year’s budget will include, however, a 15 percent increase for the Ministry of Education, as well as a rise of 100,000,000 pounds ($55,000,000) in government subsidies for exports."
  - Supports:
    - The 1960 budget gave the Ministry of Education a 15 percent increase while holding the total budget flat
    - Education was a named budget envelope in 1960

**[S5207]** Jewish Telegraphic Agency (JTA archive), 'Israel's Budget Presented to Knesset; No Tax Increase Recommended' (1963-01-02) — https://www.jta.org/archive/israels-budget-presented-to-knesset-no-tax-increase-recommended — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the sim-v2 builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "The development budget, totaling 553,000,000 pounds ($181,000,000) will be utilized for agricultural purposes, water development, mining, electricity, industry, transportation, roads and housing."
  - Supports:
    - The early-1960s Israeli budget had a separate development envelope covering agriculture, water development, roads and housing
    - Development spending (water, roads, housing) was a distinct budget envelope in the 1963 budget

**[S5208]** Jewish Telegraphic Agency (JTA archive), 'Israel Parliament Given 1968-69 Budget of $1.7 Billion; Reduction is $35 Million' (1968-01-03) — https://www.jta.org/archive/israel-parliament-given-1968-69-budget-of-1-7-billion-reduction-is-35-million — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the sim-v2 builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Some 34 percent of the budget, Mr. Sapir said, would be allocated to development projects, and the remainder would be used for ordinary, governmental expenditures."
  - Supports:
    - About 34 percent of the 1968-69 budget was allocated to development projects
    - The budget was split between development projects and ordinary governmental expenditure

**[S5209]** Jewish Telegraphic Agency (JTA archive), '$2.8 Billion Budget Presented to Knesset; 56 Percent for Defense and Debt Repayment' (1970-02-17) — https://www.jta.org/archive/2-8-billion-budget-presented-to-knesset-56-percent-for-defense-and-debt-repayment — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the sim-v2 builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "He said social services and education had priority and new development plans such as the road construction, electric power, postal and telephone services and water pipelines would have to be curbed proportionately."
  - Supports:
    - In the 1970 budget, education and social services had priority over development plans (roads, power, water pipelines) because of record defence costs
    - Defence and debt repayment took 56 percent of the 1970 budget

**[S5210]** Jewish Telegraphic Agency (JTA archive), 'Fiscal 1972-73 Budget Set at $3,78b; Defense Costs Account for 33 Percent Gnp Expected to Rise by 7' (1972-02-23) — https://www.jta.org/archive/fiscal-1972-73-budget-set-at-378b-defense-costs-account-for-33-percent-gnp-expected-to-rise-by-7 — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the sim-v2 builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Defense costs account for 33 percent of the new budget, compared with 39.8 percent last year"
  - Supports:
    - Defence took about a third of the 1972-73 budget, down from 39.8 percent the year before

**[S5211]** Jewish Telegraphic Agency (JTA archive), 'New Budget Says Yes to Defense, No to Housing Demands by Sharon' (1991-09-05) — https://www.jta.org/archive/new-budget-says-yes-to-defense-no-to-housing-demands-by-sharon — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the sim-v2 builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "In order to free up some $220 million for the defense budget, the Cabinet cut into the allotment for immigrant absorption."
  - Supports:
    - In the 1992 budget defence and immigrant housing/absorption competed for the same funds during the Soviet aliyah
    - The Cabinet cut immigrant-absorption money to raise the defence budget

**[S5212]** Jewish Telegraphic Agency (JTA archive), ''94 Israel State Budget Anticipates Economic Growth Due to PLO Accord' (1993-10-27) — https://www.jta.org/archive/94-israel-state-budget-anticipates-economic-growth-due-to-plo-accord — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the sim-v2 builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Major outlays called for in the budget include: $11.7 billion for dept servicing and repayments; $6 billion for defense spending; $9.1 billion for social service; and $5.6 billion for spending on domestic programs, which includes a $700 million increase in spending on education."
  - Supports:
    - The 1994 budget split money between debt service, defence, social services and domestic programs including education

**[S5213]** Jewish Telegraphic Agency (JTA archive), 'Israel Girds for Tough Battle over Cuts in Next Year's Budget' (2001-12-19) — https://www.jta.org/archive/israel-girds-for-tough-battle-over-cuts-in-next-years-budget — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the sim-v2 builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Cuts in social services and education also are expected, likely drawing howls of protests from politicians representing the weaker sectors of society."
  - Supports:
    - In the 2002 budget fight, cuts fell on defence, social services and education
    - Education and social services were budget envelopes that politicians fought over in the 2000s

**[S5214]** Jewish Virtual Library, 'Basic Laws of Israel: The Government (2001)' — https://www.jewishvirtuallibrary.org/basic-law-the-government-2001 — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the sim-v2 builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "(a) The Government consists of the Prime Minister and other Ministers."
  - Supports:
    - The Israeli government is made up of the Prime Minister and other ministers

**[S5215]** Israel Ministry of Defense, 'Budget Department' (mod.gov.il, English site) — https://www.mod.gov.il/en/departments/budget-department — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the sim-v2 builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "The Budget Department is responsible for planning and managing the defense establishment's budget."
  - Supports:
    - The Ministry of Defense plans and manages the defence establishment's budget through its Budget Department

**[S5216]** Israel Ministry of Finance, 'About the Ministry of Finance' (financeisrael.mof.gov.il, archived 2010-11-02) — http://www.financeisrael.mof.gov.il/FinanceIsrael/Pages/en/General/ministry.aspx — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the sim-v2 builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "The Ministry prepares the draft State Budget and monitors implementation of the approved budget, manages state revenues and collects direct and indirect taxes, promotes nonresident investments and conducts the Government's economic relations with the Government of the United States, regulates the capital market, savings, and insurance, and maintains auxiliary units for government ministries in motor vehicles, computer services, and printing."
  - Supports:
    - The Ministry of Finance prepares the draft State Budget and monitors its implementation
    - The Ministry of Finance manages state revenue and collects taxes

**[S5217]** Israel Ministry of Immigrant Absorption, 'Fields of Activity' (moia.gov.il English site, archived) — http://www.moia.gov.il/english/about/about1.htm — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the sim-v2 builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "The Ministry of Immigrant Absorption is responsible for providing government assistance to new immigrants and returning residents who have arrived in Israel within the last decade - from their first steps in the country to their integration into every area of life in Israeli society."
  - Supports:
    - The Ministry of Immigrant Absorption (now Aliyah and Integration) provides government assistance to new immigrants

**[S5218]** Jewish Telegraphic Agency (JTA archive), 'Israel Government's Decision to Establish Absorption Ministry Creates Storm' (1968-06-11) — https://www.jta.org/archive/israel-governments-decision-to-establish-absorption-ministry-creates-storm — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the sim-v2 builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "News that the Israeli Government had decided to establish a Ministry of Absorption and to assume responsibility for the absorption of immigrants, a responsibility previously held by the Jewish Agency, created a storm here today in the 27th World Zionist Congress."
  - Supports:
    - The Israeli Government decided in 1968 to establish a Ministry of Absorption, taking over absorption from the Jewish Agency

**[S5219]** Israel Ministry of Construction and Housing, 'About the Ministry of Construction and Housing' (moch.gov.il English site, archived 2013-10-11) — http://www.moch.gov.il/English/about/Pages/about.aspx — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the sim-v2 builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "The Ministry of Construction and Housing is responsible for initiating and implementing government policy in housing and residential construction."
  - Supports:
    - The Ministry of Construction and Housing sets and implements government housing policy

**[S5220]** Israel Ministry of Agriculture and Rural Development, 'Ministry Vision and Goals for 2017' (moag.gov.il English site, archived) — http://www.moag.gov.il/en/About%20the%20Ministry/Pages/Ministry_Vision.aspx — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the sim-v2 builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "The Ministry shall work to develop agriculture in Israel and to consolidate the settlement in the spirit of the Zionist values to safeguard the State lands and its resources, to assure a supply of fresh, high quality food to the inhabitants of the State of Israel and to leverage the relative advantage of Israel’s agriculture"
  - Supports:
    - The Ministry of Agriculture and Rural Development develops agriculture and rural settlement and safeguards state lands and resources
    - The ministry assures a supply of fresh food

**[S5221]** Israel Ministry of Foreign Affairs, 'Education: Primary and Secondary' (mfa.gov.il, archived 2013-06-22) — http://www.mfa.gov.il/mfa/aboutisrael/education/pages/education-%20primary%20and%20secondary.aspx — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the sim-v2 builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "The Ministry of Education is responsible for school curricula, educational standards, supervision of teaching personnel, and construction of school buildings."
  - Supports:
    - The Ministry of Education is responsible for school curricula, standards, teachers and school construction

**[S5222]** Israel Ministry of Health, 'About the Ministry' (health.gov.il English site, archived 2011-11-28) — http://www.health.gov.il/English/About/Pages/default.aspx — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the sim-v2 builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "The Ministry of Health bears national responsibility for ensuring the health of the population of Israel."
  - Supports:
    - The Ministry of Health is responsible for the health of the population of Israel

**[S5223]** Jewish Telegraphic Agency (JTA archive), 'Mapai Offers Four Portfolios to Liberals in Israel Coalition Cabinet' (1961-10-17) — https://www.jta.org/archive/mapai-offers-four-portfolios-to-liberals-in-israel-coalition-cabinet — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the sim-v2 builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "It was also learned today that the National Religious party, which has been assured of three portfolios–the Ministries of Religious Affairs, Interior and Social Welfare–is now demanding a fourth portfolio."
  - Supports:
    - Coalition negotiations allocate ministerial portfolios to partner parties (1961: NRP assured Religious Affairs, Interior and Social Welfare)

**[S5224]** Jewish Telegraphic Agency (JTA archive), 'Shas Emerges As the Winner As Sharon Finalizes His Cabinet' (2001-03-06) — https://www.jta.org/archive/shas-emerges-as-the-winner-as-sharon-finalizes-his-cabinet — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the sim-v2 builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "It will receive five ministerial posts, including the powerful Interior Ministry for Yishai, who also will serve as deputy prime minister."
  - Supports:
    - A coalition partner (Shas, 2001) received five ministerial posts including the Interior Ministry as the price of joining the government

**[S5225]** Jewish Telegraphic Agency (JTA archive), 'After Marathon Discussions, Knesset Approves 1999 Budget' (1999-02-09) — https://www.jta.org/archive/after-marathon-discussions-knesset-approves-1999-budget-2 — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the sim-v2 builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Spending pledges to Netanyahu’s coalition partners included $50 million, primarily in education and housing, for the fervently Orthodox parties, and around $50 million for settlements that include those in the West Bank and Gaza Strip."
  - Supports:
    - Budget money pledged to coalition partners for their sectors was part of passing the 1999 budget (coalition funds)

**[S5226]** Jewish Telegraphic Agency (JTA archive), 'Rivalries Among Smaller Parties Could Topple Shamir Government' (1991-12-27) — https://www.jta.org/archive/rivalries-among-smaller-parties-could-topple-shamir-government — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the sim-v2 builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Moda’i is reported, with Shamir’s concurrence, to have offered the nationalist Tehiya and Moledet parties additional money for settlements in the administered territories if they opposed the bill, which they had originally supported."
  - Supports:
    - Coalition partners' votes were bought with sector-specific budget money (1991)

**[S5227]** Jewish Telegraphic Agency (JTA archive), 'Allon Rebuffs Terms for Education Ministry, Threatens Cabinet-making Negotiations' (1969-12-08) — https://www.jta.org/archive/allon-rebuffs-terms-for-education-ministry-threatens-cabinet-making-negotiations — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the sim-v2 builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Deputy Premier Yigal Allon flatly refused to accept the post of Minister of Education on the terms agreed upon by Mrs. Meir and the Orthodox National Religious Party which demanded that a deputy minister of education be selected from its ranks."
  - Supports:
    - In the 1969 coalition talks the NRP made a deputy education minister the price of joining, threatening cabinet-making
    - Education ministry was a coalition bargaining chip

**[S5228]** Jewish Telegraphic Agency (JTA archive), 'Religious Groups Submit Conditions for Joining Israel Cabinet' (1954-01-14) — https://www.jta.org/archive/religious-groups-submit-conditions-for-joining-israel-cabinet — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the sim-v2 builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "One of the demands stipulates the appointment of a religious Deputy Minister of Education."
  - Supports:
    - In 1954 religious parties made a religious Deputy Minister of Education a condition for joining the Cabinet

**[S5230]** Jewish Telegraphic Agency (JTA archive), 'Ben Gurion's Coalition Government Gets 73 to 45 Vote of Confidence in Israeli Assembly' (1949-03-11) — https://www.jta.org/archive/ben-gurions-coalition-government-gets-73-to-45-vote-of-confidence-in-israeli-assembly — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "The new Israeli Government, headed by David Ben Gurion and including the Mapai, Religious Bloc and the Progressives, today received 73-45 vote of"
  - Supports:
    - Government formation date

**[S5231]** Jewish Telegraphic Agency (JTA archive), 'New 13-member Israel Cabinet Announced in Parliament' (1951-10-08) — https://www.jta.org/archive/new-13-member-israel-cabinet-announced-in-parliament — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Premier David Ben Gurion today presented to the Israel Parliament a list of his newly-formed 13-member cabinet, composed of nine members of the Mapai Party and four members of religious groups."
  - Supports:
    - Government formation date
    - Religious bloc (Mizrachi, Hapoel HaMizrachi, Agudat Israel, Poalei Agudat Israel) joined the coalition
    - General Zionists negotiated but stayed out

**[S5232]** Jewish Telegraphic Agency (JTA archive), 'Sharett Presents New Four-party Coalition Cabinet to Parliament' (1954-01-26) — https://www.jta.org/archive/sharett-presents-new-four-party-coalition-cabinet-to-parliament — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Premier Moshe Sharett presented his new, four-party, sixteen-man Cabinet to Parliament tonight and asked for its confirmation."
  - Supports:
    - Government formation date
    - Mizrachi Labor (Hapoel HaMizrachi) joined the coalition
    - Progressive Party negotiated but stayed out

**[S5233]** Jewish Telegraphic Agency (JTA archive), 'Sharett Continues Attempts to Bring Progressives into Cabinet' (1954-01-29) — https://www.jta.org/archive/sharett-continues-attempts-to-bring-progressives-into-cabinet — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "He met with Israel Rokach, the Minister of the Interior, who is a General Zionist leader, and Dr. Pinhas Rosen, Progressive leader, to work out a formula acceptable to all parties in the coalition."
  - Supports:
    - General Zionists joined the coalition

**[S5234]** Jewish Telegraphic Agency (JTA archive), 'Ben Gurion Presents Cabinet; Offers to Meet for Arabs for Peace Talks' (1955-11-03) — https://www.jta.org/archive/ben-gurion-presents-cabinet-offers-to-meet-for-arabs-for-peace-talks — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "after which he named the 16 members of his new coalition Cabinet which, by a last minute decision of the Mizrachi and Poale Mizrachi, has been expanded to include the religious bloc."
  - Supports:
    - Government formation date

**[S5235]** Jewish Telegraphic Agency (JTA archive), 'Ben Gurion Announces Proposed Distribution of Cabinet Portfolios' (1955-10-10) — https://www.jta.org/archive/ben-gurion-announces-proposed-distribution-of-cabinet-portfolios — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Mapam, 2-Development and Health; Ahdut Avodah, 2-Communications and Interior."
  - Supports:
    - Mapam joined the coalition
    - Ahdut HaAvoda joined the coalition
    - Hapoel HaMizrachi / Mizrachi joined the coalition

**[S5236]** Jewish Telegraphic Agency (JTA archive), 'New Cabinet Formed in Israel; Will Be Presented to Knesset Monday' (1955-10-14) — https://www.jta.org/archive/new-cabinet-formed-in-israel-will-be-presented-to-knesset-monday — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Dr. Pinchas Rosen, Progressive, Minister of Justice, and Moshe Kol, Progressive, Minister without portfolio."
  - Supports:
    - Progressive Party joined the coalition

**[S5237]** Jewish Telegraphic Agency (JTA archive), 'Ben-gurion Forms Five-party Coalition Cabinet; Presents It to Knesset' (1959-12-17) — https://www.jta.org/archive/ben-gurion-forms-five-party-coalition-cabinet-presents-it-to-knesset — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "A five-party coalition Cabinet, mustering 86 of 120 votes in the Knesset, was presented to the Parliament tonight by Prime Minister David Ben-Gurion."
  - Supports:
    - Government formation date
    - National Religious Party joined the coalition
    - Progressive Party joined the coalition
    - Mapam joined the coalition
    - Ahdut HaAvoda joined the coalition

**[S5238]** Jewish Telegraphic Agency (JTA archive), 'Knesset Votes Approval of New Cabinet Program; Vote is 78 to 33' (1959-12-18) — https://www.jta.org/archive/knesset-votes-approval-of-new-cabinet-program-vote-is-78-to-33 — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Rabbi I. M. Levin, explaining why Aguda had not joined the new Government, said that the Mapai rejected two conditions Aguda proposed for joining the coalition."
  - Supports:
    - Agudat Israel negotiated but stayed out

**[S5239]** Jewish Telegraphic Agency (JTA archive), 'Israel Cabinet Formed; Will Be Presented Today to Knesset for Vote' (1961-11-02) — https://www.jta.org/archive/israel-cabinet-formed-will-be-presented-today-to-knesset-for-vote — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "The formation of the new Israel Cabinet was announced here today by Finance Minister Levi Eshkol who for more than 10 weeks conducted the negotiations with the various political parties for the establishment of a coalition government."
  - Supports:
    - Government formation date
    - Poale Agudat Israel joined the coalition
    - Mapam negotiated but stayed out

**[S5240]** Jewish Telegraphic Agency (JTA archive), 'New Israel Cabinet Approved by Knesset; to Be Headed by Ben-gurion' (1961-11-03) — https://www.jta.org/archive/new-israel-cabinet-approved-by-knesset-to-be-headed-by-ben-gurion — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "The three National Religious Party portfolios are Moshe Shapiro, Minister of the Interior and Health, Joseph Burg, Social Welfare, and Zorach Warhaftig, Religious Affairs."
  - Supports:
    - National Religious Party joined the coalition
    - Ahdut HaAvoda joined the coalition

**[S5241]** Jewish Telegraphic Agency (JTA archive), 'New Israel Cabinet Sworn into Office in Knesset; German Issue Raised' (1963-06-27) — https://www.jta.org/archive/new-israel-cabinet-sworn-into-office-in-knesset-german-issue-raised — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Israel's twelfth government in 15 years of statehood was sworn into office today in the Knesset, Israel's Parliament, headed by former Finance Minister Levi Eshkol as Prime Minister."
  - Supports:
    - Government formation date

**[S5242]** Jewish Telegraphic Agency (JTA archive), 'Israel's New Cabinet Formed; Will Follow Line of Last Government' (1963-06-25) — https://www.jta.org/archive/israels-new-cabinet-formed-will-follow-line-of-last-government — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Moshe Shapiro, Interior and Health; Dr. Yosef Burg, Welfare; and Zerach Warhaftig, Religious Affairs-all of the National Religious party;"
  - Supports:
    - National Religious Party joined the coalition
    - Ahdut HaAvoda joined the coalition

**[S5243]** Jewish Telegraphic Agency (JTA archive), 'New Israel Cabinet to Be Sworn in Today in Israel Parliament' (1963-06-26) — https://www.jta.org/archive/new-israel-cabinet-to-be-sworn-in-today-in-israel-parliament — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "He reiterated that Mapam had declined the Achdut Avodah bid to join the new Government because this would have meant implied approval of the deeds of the outgoing Government."
  - Supports:
    - Mapam negotiated but stayed out

**[S5244]** Jewish Telegraphic Agency (JTA archive), 'Knesset Approves New Cabinet Presented by Eshkol; Vote is 71 to 41' (1966-01-13) — https://www.jta.org/archive/knesset-approves-new-cabinet-presented-by-eshkol-vote-is-71-to-41 — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Premier Levi Eshkol's new coalition Government was approved by Parliament today by a vote of 71 to 41."
  - Supports:
    - Government formation date

**[S5245]** Jewish Telegraphic Agency (JTA archive), 'Eshol to Present Cabinet Today to Knesset; Composed of 18 Members' (1966-01-12) — https://www.jta.org/archive/eshol-to-present-cabinet-today-to-knesset-composed-of-18-members — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Moshe Shapiro, of the National Religious Party, continued as Interior Minister. Dr. Yosef Burg, of the National Religious Party, was re-named Welfare Minister. Dr. Zerah Warhaftig, of the National Religious Party, was again named Religious Affairs Minister."
  - Supports:
    - National Religious Party joined the coalition
    - Mapam joined the coalition
    - Independent Liberals joined the coalition

**[S5246]** Jewish Telegraphic Agency (JTA archive), 'Eshkol Invites Mapam to Join New Cabinet; Asks Dissidents to Return' (1965-11-10) — https://www.jta.org/archive/eshkol-invites-mapam-to-join-new-cabinet-asks-dissidents-to-return — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Eshkol made his offer to Mapam at a meeting here today with two of that party's leaders, Meir Yeari and Yaacov Hazan."
  - Supports:
    - Mapam (earlier invitation) negotiated but stayed out

**[S5247]** Jewish Telegraphic Agency (JTA archive), 'Enlarged Israel Cabinet Meets on Crisis; Gen. Dayan Attends As Defense Minister' (1967-06-05) — https://www.jta.org/archive/enlarged-israel-cabinet-meets-on-crisis-gen-dayan-attends-as-defense-minister — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "The Cabinet was an enlarged body today, being attended by the newly-designated Minister of Defense, Moshe Dayan, and by the two non-members of the coalition Government who have been designated as members of the National Unity Cabinet."
  - Supports:
    - Government formation date
    - Gahal (Herut-Liberal) joined the coalition

**[S5248]** Jewish Telegraphic Agency (JTA archive), 'Israel Cabinet Approves Eshkol Plan for a National Unity Government' (1967-06-02) — https://www.jta.org/archive/israel-cabinet-approves-eshkol-plan-for-a-national-unity-government — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "It was reported that the Cabinet approved Premier Eshkol's proposals only on condition that Gen. Moshe Dayan, commander of the forces that routed the Egyptians in the 1956 campaign and now a leader of Rafi, would be offered and would accept a major Cabinet post."
  - Supports:
    - Rafi joined the coalition

**[S5249]** Jewish Telegraphic Agency (JTA archive), 'Mrs. Meir Becomes 4th Premier As Knesset Gives Her a 84-12 Vote of Confidence' (1969-03-18) — https://www.jta.org/archive/mrs-meir-becomes-4th-premier-as-knesset-gives-her-a-84-12-vote-of-confidence — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "The Knesset (Parliament) gave an overwhelming vote of confidence today to the coalition government of Mrs. Golda Meir. who becomes Israel's fourth Premier."
  - Supports:
    - Government formation date
    - National Religious Party joined the coalition
    - Independent Liberals joined the coalition

**[S5250]** Jewish Telegraphic Agency (JTA archive), 'Coalition Formed by Eshkol Appears Certain to Continue As Gahal Gives Assent' (1969-03-06) — https://www.jta.org/archive/coalition-formed-by-eshkol-appears-certain-to-continue-as-gahal-gives-assent — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "The continuity of the national unity government put together by the late Prime Minister Levi Eshkol on the eve of the Six-Day War appeared assured today as its second largest faction, Gahal, announced that it favored preservation of the present coalition line-up."
  - Supports:
    - Gahal (Herut-Liberal) joined the coalition

**[S5251]** Jewish Telegraphic Agency (JTA archive), 'Here is List of Israel's 24 New Cabinet Member' (1969-12-16) — https://www.jta.org/archive/here-is-list-of-israels-24-new-cabinet-member — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Israel's new Cabinet consists of 24 Ministers, six of whom, at present, hold no portfolios."
  - Supports:
    - Government formation date
    - Mapam (portfolios only) negotiated but stayed out

**[S5252]** Jewish Telegraphic Agency (JTA archive), 'Mrs. Meir Will Present 24-cabinet Government to Knesset for Approval Monday' (1969-12-15) — https://www.jta.org/archive/mrs-meir-will-present-24-cabinet-government-to-knesset-for-approval-monday — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Israel's second largest party, which will have six ministers, headed by Menachem Beigin and Joseph Saphir."
  - Supports:
    - Gahal (Herut-Liberal) joined the coalition
    - National Religious Party joined the coalition

**[S5253]** Jewish Telegraphic Agency (JTA archive), 'Mapam Considering Joining Coalition Government As Full Members with Portfolios' (1970-06-19) — https://www.jta.org/archive/mapam-considering-joining-coalition-government-as-full-members-with-portfolios — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Although a member of the Labor Alignment, Mapam has hitherto refused to accept the portfolios of health and immigrant absorption ear-marked for it when Premier Golda Meir formed her coalition government late last year."
  - Supports:
    - Mapam joined the coalition

**[S5254]** Jewish Telegraphic Agency (JTA archive), 'Knesset Approves New Cabinet by Vote of 62-46 with 9 Abstentions-by David Landau' (1974-03-11) — https://www.jta.org/archive/knesset-approves-new-cabinet-by-vote-of-62-46-with-9-abstentions-by-david-landau — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "The Knesset approved Premier Golda Meir's new Cabinet tonight by a vote of 62-46."
  - Supports:
    - Government formation date

**[S5255]** Jewish Telegraphic Agency (JTA archive), 'New Cabinet Set; Nrp Says It Will Join New Gov't.; Its Entry Will Give Mrs Mer Majority with 68 Seat' (1974-03-08) — https://www.jta.org/archive/new-cabinet-set-nrp-says-it-will-join-new-govt-its-entry-will-give-mrs-mer-majority-with-68-seat — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Premier Golda Meir announced the make-up of her new Cabinet last night after receiving assurances from the National Religious Party that it will join the government"
  - Supports:
    - National Religious Party joined the coalition
    - Independent Liberal Party joined the coalition

**[S5256]** Jewish Telegraphic Agency (JTA archive), 'Cabinet Approved by 61-51 Vote Rabin Pledges Step-by-step Cautious Peace Negotiations' (1974-06-04) — https://www.jta.org/archive/cabinet-approved-by-61-51-vote-rabin-pledges-step-by-step-cautious-peace-negotiations — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "A new Israeli government headed by Premier Yitzhak Rabin was sworn into office today after winning a narrow vote of confidence in the Knesset."
  - Supports:
    - Government formation date

**[S5257]** Jewish Telegraphic Agency (JTA archive), 'Rabin Designates New Cabinet' (1974-05-30) — https://www.jta.org/archive/rabin-designates-new-cabinet — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "The Rabin government, based on a narrow coalition of the Labor Alignment, the Independent Liberal Party and the Civil Rights Party, commands only 61 Knesset votes and defections are possible from within Labor Party ranks, either by abstentions or negative ballots."
  - Supports:
    - Independent Liberal Party joined the coalition
    - Civil Rights Movement (Ratz) joined the coalition

**[S5258]** Jewish Telegraphic Agency (JTA archive), 'Nrp Expected to Join Government' (1974-07-08) — https://www.jta.org/archive/nrp-expected-to-join-government — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "The National Religious Party is expected to join Premier Yitzhak Rabin's coalition government, possibly before the end of this week."
  - Supports:
    - National Religious Party negotiated but stayed out

**[S5259]** Jewish Telegraphic Agency (JTA archive), 'Begin Takes Oath of Office After Long Debate in Knesset' (1977-06-22) — https://www.jta.org/archive/begin-takes-oath-of-office-after-long-debate-in-knesset — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "The government of Premier Menachem Begin took the oath of office in the early hours of this morning after nine hours of angry, often bitter debate in the Knesset"
  - Supports:
    - Government formation date
    - Agudat Israel (Aguda bloc) joined the coalition

**[S5260]** Jewish Telegraphic Agency (JTA archive), 'Likud Discloses Probable Composition of New Cabinet' (1977-06-17) — https://www.jta.org/archive/likud-discloses-probable-composition-of-new-cabinet — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "The Interior, Education and Religious Affairs Ministers belong to the NRP."
  - Supports:
    - National Religious Party joined the coalition
    - Democratic Movement for Change (DMC) negotiated but stayed out

**[S5261]** Jewish Telegraphic Agency (JTA archive), 'Coalition Agreement Signed' (1981-08-05) — https://www.jta.org/archive/coalition-agreement-signed — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "The coalition agreement between Premier Menachem Begin and the three religious parties - the National Religious Party, Aguda Israel and Tami - was signed tonight in a brief ceremony and a round of "lehaims.""
  - Supports:
    - Government formation date
    - National Religious Party joined the coalition
    - Tami joined the coalition
    - Agudat Israel joined the coalition

**[S5262]** Jewish Telegraphic Agency (JTA archive), 'Knesset Votes 60-53 to Approve the New Government Headed by Shamir Political Change is Overshadowed' (1983-10-11) — https://www.jta.org/archive/knesset-votes-60-53-to-approve-the-new-government-headed-by-shamir-political-change-is-overshadowed — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "The Knesset voted 60-53 today to approve the new coalition government headed by Premier-designate Yitzhak Shamir."
  - Supports:
    - Government formation date
    - Labor Alignment negotiated but stayed out

**[S5263]** Jewish Telegraphic Agency (JTA archive), 'Likud Leaders Optimistic on Reaching Accord on New Government' (1983-09-08) — https://www.jta.org/archive/likud-leaders-optimistic-on-reaching-accord-on-new-government — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "The outlook brightened following meetings yesterday between the Likud negotiators and leaders of the Tami Party which had threatened to quit the coalition even before Begin announced his intention to resign two weeks ago."
  - Supports:
    - Tami joined the coalition
    - Agudat Israel joined the coalition
    - National Religious Party joined the coalition

**[S5264]** Jewish Telegraphic Agency (JTA archive), 'Shamir to Present His Unity Government to the Knesset Monday for a Vote of Confidence' (1986-10-20) — https://www.jta.org/archive/shamir-to-present-his-unity-government-to-the-knesset-monday-for-a-vote-of-confidence — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Premier-designate Yitzhak Shamir will present his new unity coalition Cabinet to the Knesset for a vote of confidence Monday."
  - Supports:
    - Government formation date
    - Labor Alignment joined the coalition

**[S5265]** Jewish Telegraphic Agency (JTA archive), 'Knesset Approves New Government; More Cabinet Portfolios Named' (1988-12-23) — https://www.jta.org/archive/knesset-approves-new-government-more-cabinet-portfolios-named — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "The Knesset overwhelmingly approved the new Labor-Likud coalition government presented to it Thursday by Prime Minister Yitzhak Shamir."
  - Supports:
    - Government formation date
    - Shas joined the coalition
    - National Religious Party joined the coalition

**[S5266]** Jewish Telegraphic Agency (JTA archive), 'Likud and Labor Agree on Terms for a National Unity Government' (1988-12-20) — https://www.jta.org/archive/likud-and-labor-agree-on-terms-for-a-national-unity-government — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Shimon Peres, the Labor Party leader, already had to relinquish the office of foreign minister, which he has held for the past two years. He will become finance minister in the new government."
  - Supports:
    - Labor Party joined the coalition

**[S5267]** Jewish Telegraphic Agency (JTA archive), 'Alternatives to Likud Government Emerge on Eve of Consultations' (1988-11-07) — https://www.jta.org/archive/alternatives-to-likud-government-emerge-on-eve-of-consultations — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "According to an unconfirmed report, veteran Agudah Knesset member Menahem Porush already has urged the party to join only a Labor-led coalition."
  - Supports:
    - Agudat Yisrael negotiated but stayed out

**[S5268]** Jewish Telegraphic Agency (JTA archive), 'Shamir Government Wins Approval in the Knesset by a Vote of 62-57' (1990-06-12) — https://www.jta.org/archive/shamir-government-wins-approval-in-the-knesset-by-a-vote-of-62-57 — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "The Knesset approved Prime Minister Yitzhak Shamir's new right-wing coalition government late Monday by a vote of 62-57."
  - Supports:
    - Government formation date

**[S5269]** Jewish Telegraphic Agency (JTA archive), 'Shamir Says He Has Now Assembled Government with 62-vote Majority' (1990-06-08) — https://www.jta.org/archive/shamir-says-he-has-now-assembled-government-with-62-vote-majority — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "At the last minute, Likud decided against transferring the strategic agency from the Agriculture Ministry to the Shas-controlled Interior Ministry. Likud offered Shas the Communications Ministry instead."
  - Supports:
    - Shas joined the coalition

**[S5270]** Jewish Telegraphic Agency (JTA archive), 'Latest Snag for Shamir Provides New Hope for a Unity Government' (1990-05-24) — https://www.jta.org/archive/latest-snag-for-shamir-provides-new-hope-for-a-unity-government — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Shamir's lieutenants reportedly have been trying to mollify Ze'evi with the offer of the Transport Ministry."
  - Supports:
    - Moledet negotiated but stayed out

**[S5271]** Jewish Telegraphic Agency (JTA archive), 'The New Israeli Cabinet' (1992-07-14) — https://www.jta.org/archive/the-new-israeli-cabinet-3 — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Following is the Cabinet that Yitzhak Rabin presented Monday at the opening session of the 13th Knesset."
  - Supports:
    - Government formation date
    - Meretz joined the coalition
    - Shas joined the coalition

**[S5272]** Jewish Telegraphic Agency (JTA archive), 'Labor Makes Progress with Shas in Building Coalition Government' (1992-07-07) — https://www.jta.org/archive/labor-makes-progress-with-shas-in-building-coalition-government — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Over the weekend, Rabin told the NRP's Zevulun Hammer, who is the outgoing education minister, to forget any idea of Labor dropping Meretz in favor of an NRP-instigated bloc of right-of-center parties that would include Tsomet and the haredim."
  - Supports:
    - National Religious Party negotiated but stayed out

**[S5273]** Jewish Telegraphic Agency (JTA archive), 'News Analysis: Peres Gives Prominent Roles in Cabinet to Next Generation' (1995-11-22) — https://www.jta.org/archive/news-analysis-peres-gives-prominent-roles-in-cabinet-to-next-generation — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "His new government was overwhelmingly approved by the Knesset on Wednesday. At the same time, Peres was sworn in as Israel's 12th prime minister."
  - Supports:
    - Government formation date
    - Meretz joined the coalition
    - Meimad joined the coalition

**[S5274]** Jewish Telegraphic Agency (JTA archive), 'News Analysis: Tensions Linger in the Cabinet After Sharon Joins Government' (1996-07-10) — https://www.jta.org/archive/news-analysis-tensions-linger-in-the-cabinet-after-sharon-joins-government — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "An earlier threat by Levy, on June 18, the day the coalition was sworn in, forced Netanyahu to pledge to the Knesset that he would set up a new ministry in order to provide Sharon with a portfolio commensurate with his standing and ambitions."
  - Supports:
    - Government formation date

**[S5275]** Jewish Telegraphic Agency (JTA archive), 'Netanyahu Finalizes Deals to Form Right-wing Coalition' (1996-06-18) — https://www.jta.org/archive/netanyahu-finalizes-deals-to-form-right-wing-coalition — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Under its agreement with Likud, Yisrael Ba'Aliyah was slated to get the Absorption Ministry, and the combined Ministries of Trade and Industry."
  - Supports:
    - Yisrael BaAliyah joined the coalition
    - National Religious Party joined the coalition

**[S5276]** Jewish Telegraphic Agency (JTA archive), 'Barak Forges New Government, Will Present Partners Next Week' (1999-07-01) — https://www.jta.org/archive/barak-forges-new-government-will-present-partners-next-week-2 — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Prime Minister-elect Ehud Barak has forged a coalition government that includes at least four parties in addition to his One Israel bloc."
  - Supports:
    - Government formation date
    - Shas joined the coalition

**[S5277]** Jewish Telegraphic Agency (JTA archive), 'Likud Will Likely Stay in Opposition, As Shas Predicted to Join Coalition' (1999-06-29) — https://www.jta.org/archive/likud-will-likely-stay-in-opposition-as-shas-predicted-to-join-coalition-2 — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Education - Meretz. This portfolio was held in the outgoing government by the National Religious Party. Trade and Industry - Meretz."
  - Supports:
    - Meretz joined the coalition
    - Yisrael BaAliyah joined the coalition
    - National Religious Party joined the coalition

**[S5278]** Jewish Telegraphic Agency (JTA archive), 'News Analysis: Barak is Moving Slowly Toward Accepting Shas into His Coalition' (1999-06-09) — https://www.jta.org/archive/news-analysis-barak-is-moving-slowly-toward-accepting-shas-into-his-coalition-3 — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Shas "represents values that are inimical to the rule of law," Shinui leader Yosef "Tommy" Lapid insisted Tuesday."
  - Supports:
    - Shinui negotiated but stayed out

**[S5279]** Jewish Telegraphic Agency (JTA archive), 'News Analysis: Chemistry of Sharon and Peres, Old Friends and Rivals, Will Be Key' (2001-03-07) — https://www.jta.org/archive/news-analysis-chemistry-of-sharon-and-peres-old-friends-and-rivals-will-be-key — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Ariel Sharon's national unity government, which was to be sworn in Wednesday night, will rely on two key factors for stability and longevity."
  - Supports:
    - Government formation date
    - Labor Party joined the coalition
    - Labor dissidents (Beilin, Burg, Ben-Ami) negotiated but stayed out

**[S5280]** Jewish Telegraphic Agency (JTA archive), 'For Shinui, Price of Entering Government May Be Its Ideals' (2003-02-26) — https://www.jta.org/archive/for-shinui-price-of-entering-government-may-be-its-ideals — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Sharon was expected to present his government to the Knesset on Thursday."
  - Supports:
    - Government formation date
    - Shinui joined the coalition
    - National Religious Party joined the coalition
    - National Union joined the coalition
    - Labor Party negotiated but stayed out

**[S5281]** Jewish Telegraphic Agency (JTA archive), 'Surrounded by Domestic Pessimism, Olmert Forms a Coalition Government' (2006-05-02) — https://www.jta.org/archive/surrounded-by-domestic-pessimism-olmert-forms-a-coalition-government — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "The government is to be sworn in Thursday."
  - Supports:
    - Government formation date
    - Shas joined the coalition
    - Yisrael Beiteinu negotiated but stayed out

**[S5282]** Jewish Telegraphic Agency (JTA archive), 'Olmert Divvies Up Ministries As Coalition Talks Wind Down' (2006-04-24) — https://www.jta.org/archive/olmert-divvies-up-ministries-as-coalition-talks-wind-down — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Labor was promised four other ministries - education, agriculture, infrastructure and tourism - as well as two ministries without portfolio."
  - Supports:
    - Labor Party joined the coalition

**[S5283]** Jewish Telegraphic Agency (JTA archive), 'Bibi speaks of 'comprehensive peace' at swearing-in rite' (2009-03-31) — https://www.jta.org/2009/03/31/israel/bibi-speaks-of-comprehensive-peace-at-swearing-in-rite — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Hours later the largest Cabinet in Israeli history - 30 ministers and at least another six deputy ministers - was sworn in Tuesday in the Knesset chamber."
  - Supports:
    - Government formation date

**[S5284]** Jewish Telegraphic Agency (JTA archive), 'Labor joining Bibi: Kosher stamp or fig leaf?' (2009-03-25) — https://www.jta.org/2009/03/25/israel/labor-joining-bibi-kosher-stamp-or-fig-leaf — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "The deal also allows Barak to stay on as defense minister and makes him a full partner in the diplomatic process."
  - Supports:
    - Labor Party joined the coalition
    - Yisrael Beiteinu joined the coalition
    - Shas joined the coalition

**[S5285]** Jewish Telegraphic Agency (JTA archive), 'Can Bibi draw Livni into his government?' (2009-02-24) — https://www.jta.org/2009/02/24/israel/can-bibi-draw-livni-into-his-government — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Livni is demanding that Netanyahu accept the principle of two states for two peoples in negotiations with the Palestinians."
  - Supports:
    - Kadima negotiated but stayed out

**[S5286]** Jewish Telegraphic Agency (JTA archive), 'Netanyahu, with team of rivals, puts together a government' (2013-03-10) — https://www.jta.org/2013/03/11/israel/netanyahu-with-team-of-rivals-puts-together-a-government — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Barring a last-minute surprise, Israel's new governing coalition will be sworn in this week: a center-right grouping of Netanyahu's right-wing Likud-Beiteinu faction, the centrist Yesh Atid party, the religious nationalist Jewish Home party, the center-left Hatnua led by Tzipi Livni and the tiny, centrist Kadima."
  - Supports:
    - Government formation date

**[S5287]** Jewish Telegraphic Agency (JTA archive), 'Are Settlers The Biggest Winners In New Government?' (2013-03-20) — https://www.jta.org/2013/03/20/ny/are-settlers-the-biggest-winners-in-new-government — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Finance Minister Yair Lapid and his Yesh Atid party and Justice Minister Tzipi Livni, who has been put in charge of peace talks with the Palestinians"
  - Supports:
    - Yesh Atid joined the coalition
    - Jewish Home joined the coalition
    - Hatnua joined the coalition

**[S5288]** Jewish Telegraphic Agency (JTA archive), 'Jewish Home party wins major posts in Netanyahu's newly formed coalition' (2015-03-22) — https://www.jta.org/2015/05/06/israel/netanyahu-making-concessions-to-jewish-home-party-forms-coalition-government — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Netanyahu has a week to have the coalition sworn into the Knesset."
  - Supports:
    - Government formation date
    - Jewish Home joined the coalition
    - Zionist Union negotiated but stayed out

**[S5289]** Jewish Telegraphic Agency (JTA archive), '5 reasons Netanyahu's having a hard time building a coalition' (2015-03-18) — https://www.jta.org/2015/05/06/politics/five-reasons-netanyahus-having-a-hard-time-building-a-coalition — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Israel Beiteinu wanted to control the Defense Ministry, Jewish Home the Foreign Ministry, Kulanu the Finance Ministry."
  - Supports:
    - Kulanu joined the coalition
    - Yisrael Beiteinu negotiated but stayed out

**[S5290]** Jewish Telegraphic Agency (JTA archive), 'Israel’s Bloated New Government' (2020-05-19) — https://www.jta.org/2020/05/19/ny/israels-bloated-new-government — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Even as he presented his government on Sunday afternoon, he sprung additional surprise posts, winding up with three more ministers from his bloc than from rival-partner Benny Gantz's, 19-16."
  - Supports:
    - Government formation date

**[S5291]** Jewish Telegraphic Agency (JTA archive), '5 key takeaways about the Gantz-Netanyahu deal and Israel’s new government' (2020-03-02) — https://www.jta.org/2020/04/21/israel/5-key-takeaways-about-the-gantz-netanyahu-deal-and-israels-new-government — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "In the meantime, Gantz will be defense minister and deputy prime minister. His allies will head the Foreign Ministry and Justice Ministry"
  - Supports:
    - Blue and White joined the coalition

**[S5292]** Jewish Telegraphic Agency (JTA archive), 'Everything you need to know about the Israeli government that will replace Benjamin Netanyahu' (2021-06-02) — https://www.jta.org/2021/06/02/israel/everything-you-need-to-know-about-the-israeli-government-that-will-replace-benjamin-netanyahu — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "That legitimized the idea of including Arabs in Israeli coalitions, and now, Raam is set to join Netanyahu's rivals, and give them the slimmest of majorities."
  - Supports:
    - Raam (United Arab List) joined the coalition

**[S5293]** Jewish Telegraphic Agency (JTA archive), 'Naftali Bennett won't run in Israel's upcoming elections' (2022-03-27) — https://www.jta.org/2022/06/29/israel/bennett-wont-seek-re-election-for-prime-minister-as-israels-government-collapses-yet-again — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "He indicated in his final speech to the Knesset that he would continue to support Yair Lapid, his foreign minister who is set to assume the prime ministership on an interim basis this week."
  - Supports:
    - Government formation date
    - Yamina joined the coalition
    - Yamina (Shaked) joined the coalition

**[S5294]** Jewish Telegraphic Agency (JTA archive), 'Netanyahu swears in new government, giving far-right figures key roles' (2022-12-29) — https://www.jta.org/2022/12/29/israel/netanyahu-swears-in-new-government-giving-far-right-figures-key-roles — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Benjamin Netanyahu completed his stunning return to power by swearing into office"
  - Supports:
    - Government formation date
    - Religious Zionism joined the coalition
    - Otzma Yehudit joined the coalition
    - Shas joined the coalition

**[S5295]** Jewish Telegraphic Agency (JTA archive), 'Israel Labor Minister Reports to Knesset on Immigrant Housing' (1960-08-01) — https://www.jta.org/archive/israel-labor-minister-reports-to-knesset-on-immigrant-housing — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-cabinet builder's source helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the raw page text.
  - Quote: "Giora Josephthal, Israel's Labor Minister told the Israel Parliament."
  - Supports:
    - Coalition composition

**[S5300]** Knesset (archived), 'Government 11' (Eshkol government, Fifth Knesset) — https://web.archive.org/web/2016/https://www.knesset.gov.il/govt/eng/GovtByNumber_eng.asp?govt=11 — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "Government 11 26/06/1963 - 22/12/1964"
  - Supports:
    - Levi Eshkol's first government took office on 26 June 1963

**[S5301]** US Department of State, Foreign Relations of the United States 1961-1963, Vol. XVII, Doc. 10: Memorandum of Conversation (US-UK talks), 13 February 1961 — https://history.state.gov/historicaldocuments/frus1961-63v17/d10 — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "We feel that it would be useful to have observers from friendly powers visit the new Israeli reactor. Israel should feel that such inspection is also in its interests."
  - Supports:
    - In early 1961 the US government pressed for inspection visits to the Dimona reactor

**[S5302]** Jewish Virtual Library, 'Israeli Settlements Population in the Gaza Strip (1999-2003)' — https://jewishvirtuallibrary.org/politics-wing/peace-process/other-58/israeli-settlements-population-in-the-gaza-strip — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "Neve Dekalim 2,563 2,470 2,370 2,280 2,230 1982/1983/1980"
  - Supports:
    - The JVL table gives Neve Dekalim's founding year as 1982/1983/1980 (sources differ)

**[S5303]** Jewish Telegraphic Agency, 'How the Rescue Took Place', 6 July 1976 — https://www.jta.org/archive/how-the-rescue-took-place — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "Details of the spectacular rescue of 102 hijack victims from their terrorist captors at Entebbe Airport in Uganda"
  - Supports:
    - 102 hostages rescued at Entebbe (JTA, 1976)
    - Shomron estimated fewer than 20 Ugandan casualties

**[S5304]** Jewish Telegraphic Agency, 'Herzog Says Free World Can Help to Defeat International Terrorism', 20 July 1976 — https://www.jta.org/archive/herzog-says-free-world-can-help-to-defeat-international-terrorism — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "Asked why 20 Ugandan soldiers were killed during the rescue operation, Herzog said they were killed because they guarded the hostages."
  - Supports:
    - Israel's UN ambassador Herzog: 20 Ugandan soldiers killed in the Entebbe raid

**[S5305]** Jewish Virtual Library, 'The Entebbe Rescue Operation' — https://jewishvirtuallibrary.org/the-entebbe-rescue-operation — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "Forty-five Ugandan soldiers were killed."
  - Supports:
    - JVL: 45 Ugandan soldiers killed at Entebbe; 105 Jewish and Israeli hostages and the 12-member crew were held

**[S5306]** Jewish Telegraphic Agency, 'Cease-fire with Syrians Holding; but Fighting with PLO Continues', 14 June 1982 — https://www.jta.org/archive/cease-fire-with-syrians-holding-but-fighting-with-plo-continues — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "a military spokesman said that a cease-fire agreed to with Syrian forces Friday was holding fairly well in the eastern sector of Lebanon"
  - Supports:
    - Israel and Syria agreed a ceasefire in Lebanon on Friday 11 June 1982 (dateline Monday 14 June 1982)

**[S5307]** Jewish Telegraphic Agency, 'Israel Forces Break Through Syrian Forces on Golan Heights', 12 October 1973 — https://www.jta.org/archive/israel-forces-break-through-syrian-forces-on-golan-heights — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "Israel forces launched an offensive this morning at the Golan Heights cease-fire line, broke through enemy defenses and began advancing toward Damascus, the Israeli army spokesman reported tonight."
  - Supports:
    - Israel's counter-offensive into Syria on the Kuneitra-Damascus axis, October 1973

**[S5308]** Jewish Telegraphic Agency, 'Mt. Hermon Positions Recaptured', 23 October 1973 — https://www.jta.org/archive/mt-hermon-positions-recaptured — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "Israel paratroopers and soldiers of the Golani Brigade captured Syrian-held positions on Mt. Hermon in bitter fighting that started last night and continued this morning."
  - Supports:
    - Mount Hermon recaptured by paratroopers and Golani, 21-22 October 1973

**[S5309]** Jewish Telegraphic Agency, 'Israel Scores Major Success in Sinai', 18 October 1973 — https://www.jta.org/archive/israel-scores-major-success-in-sinai — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "He said that Jordanian troops were fighting in Syria and had suffered their first casualties."
  - Supports:
    - Jordanian troops fought on the Syrian front in October 1973

**[S5310]** Encyclopaedia Britannica (archived 2016), 'Six-Day War' — https://web.archive.org/web/2016/https://www.britannica.com/event/Six-Day-War — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "The UN Security Council called for a cease-fire on June 7 that was immediately accepted by Israel and Jordan. Egypt accepted the following day."
  - Supports:
    - Ceasefires of June 1967: Jordan 7 June, Egypt 8 June, Syria 10 June

**[S5311]** Jewish Telegraphic Agency, 'Israeli Units Cross Jordan, Wipe out El Fatah Bases in Twelve-hour Operation', 22 March 1968 — https://www.jta.org/archive/israeli-units-cross-jordan-wipe-out-el-fatah-bases-in-twelve-hour-operation — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "infantry and armored units crossed into Jordan over the Allenby Bridge, near Jericho, and the Damiyah Bridge, several miles to the North, in a pincer movement"
  - Supports:
    - Karameh, 21 March 1968: helicopter-borne paratroops at Karameh, a pincer over the Allenby and Damiya bridges, and a parallel assault south of the Dead Sea

**[S5312]** Jewish Telegraphic Agency, 'Eshkol Tells Knesset Security Council Showed Bias Against Israel', March 1968 — https://www.jta.org/archive/eshkol-tells-knesset-security-council-showed-bias-against-israel — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "Karameh in central Jordan and Safi, in the south, both hit by Israeli troops Thursday, were converted into the main bases against Israel"
  - Supports:
    - Karameh and Safi were the two objectives of the 21 March 1968 operation

**[S5313]** Jewish Telegraphic Agency, 'Israel's Action in Lebanon Strikes at Terrorist Bases', 16 March 1978 — https://www.jta.org/archive/israels-action-in-lebanon-strikes-at-terrorist-bases — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "Israeli forces have pushed into Lebanon to a depth of 7-10 kilometers."
  - Supports:
    - Operation Litani's first aim: a security belt from Ras Nikura on the coast to the slopes of Mt. Hermon over Fatahland, 7-10 km deep

**[S5314]** Jewish Telegraphic Agency, 'Gur Says Israeli Forces in Complete Control of South Lebanon', 21 March 1978 — https://www.jta.org/archive/gur-says-israeli-forces-in-complete-control-of-south-lebanon — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "Israeli forces are in complete control of south Lebanon, up to the banks of the Litani River and including the former terrorist stronghold known as Fatahland."
  - Supports:
    - By 21 March 1978 Israeli forces held south Lebanon up to the Litani except a salient around Tyre

**[S5315]** Jewish Telegraphic Agency, 'Israeli Planes Destroy Iraq Nuclear Reactor: Furore Spreads', 9 June 1981 — https://www.jta.org/archive/israeli-planes-destroy-iraq-nuclear-reactor-furore-spreads — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "According to the government, the raid was planned for Sunday when it was expected that none if any of the 100 to 120 foreign experts working on the reactor would be at the site."
  - Supports:
    - The Osirak strike was timed for a Sunday so that the foreign experts would be away

**[S5316]** Jewish Telegraphic Agency, 'Knesset Unit Approves of Israel's Strike on PLO Hq in Tunisia', 4 October 1985 — https://www.jta.org/archive/knesset-unit-approves-of-israels-strike-on-plo-hq-in-tunisia — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "But Arafat was not there at the time."
  - Supports:
    - Arafat was not at Hammam Chott during the 1 October 1985 raid; Rabin said Israel was not aiming at him specifically

**[S5317]** Jewish Telegraphic Agency, 'Hezbollah Kills Eight, Seizes Two, Opening Second Front Against Israel', 13 July 2006 — https://www.jta.org/archive/hezbollah-kills-eight-seizes-two-opening-second-front-against-israel — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "Israeli forces were quick to respond, as artillery units and warplanes shelled bridges in southern Lebanon"
  - Supports:
    - 12 July 2006: Hezbollah's cross-border raid and Israel's air and artillery response

**[S5318]** Jewish Telegraphic Agency, 'Israel Launches Expanded Assault Leading Up to U.N.-backed Cease-fire', 14 August 2006 — https://www.jta.org/archive/israel-launches-expanded-assault-leading-up-to-u-n-backed-cease-fire — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "Israeli tanks and troops reached all the way to the strategic Litani River"
  - Supports:
    - The expanded ground offensive reached the Litani before the Resolution 1701 ceasefire of 08:00 on 14 August 2006

**[S5319]** Jewish Telegraphic Agency, 'Israel launches Gaza ground operation', 17 July 2014 — https://www.jta.org/2014/07/17/israel/israel-launches-gaza-ground-operation — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "Israel launched a ground incursion into the Gaza Strip to destroy tunnels it says are used for terrorist activities."
  - Supports:
    - 17 July 2014: the ground operation against the Gaza tunnels began

**[S5320]** Jewish Telegraphic Agency, 'Israel Launches Strikes After Rocket Fire', 8 July 2014 — https://www.jta.org/2014/07/08/ny/israel-launches-strikes-after-rocket-fire — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "Israel launched an air and sea assault on terrorist targets in the Gaza Strip shortly before dawn today"
  - Supports:
    - 8 July 2014: Operation Protective Edge opened with an air and sea assault

**[S5321]** Jewish Telegraphic Agency, 'Israel, Palestinians agree to new cease-fire', 26 August 2014 — https://www.jta.org/2014/08/26/israel/israel-palestinians-reportedly-agree-to-new-cease-fire — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "Egypt announced a new cease-fire between Israel and Palestinian groups"
  - Supports:
    - 26 August 2014: the open-ended ceasefire ended the war

**[S5322]** RETIRED (no longer cited; cited only by content dated after Q3 2023, deleted 2026-10-14 (the game ends 7 Oct 2023)) — Jewish Telegraphic Agency, 'Israel strikes Iran's nuclear program and warns Israelis to expect counterattack', 12-13 June 2025 — https://www.jta.org/2025/06/12/israel/israel-strikes-iran-against-trumps-urging-and-warns-israelis-to-expect-counterattack

**[S5323]** RETIRED (no longer cited; cited only by content dated after Q3 2023, deleted 2026-10-14 (the game ends 7 Oct 2023)) — Jewish Telegraphic Agency, 'US bombs 3 sites in Iran, joining Israel's fight against Iranian nuclear program', 21 June 2025 — https://www.jta.org/2025/06/21/united-states/us-bombs-3-sites-in-iran-joining-israels-fight-against-iranian-nuclear-program

**[S5324]** RETIRED (no longer cited; cited only by content dated after Q3 2023, deleted 2026-10-14 (the game ends 7 Oct 2023)) — Jewish Telegraphic Agency, 'Trump announces complete and total ceasefire between Israel and Iran', 23 June 2025 — https://www.jta.org/2025/06/23/israel/trump-announces-complete-and-total-ceasefire-between-israel-and-iran

**[S5325]** Jewish Telegraphic Agency, 'Seven Reported Lightly Wounded in Iraqi Missile Attack on Israel', 18 January 1991 — https://www.jta.org/archive/seven-reported-lightly-wounded-in-iraqi-missile-attack-on-israel — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "early Friday morning, when seven to 10 SCUD missiles hit sites within Israel"
  - Supports:
    - 18 January 1991: the first Iraqi Scud missiles hit Israel

**[S5326]** Jewish Telegraphic Agency, 'Two More Scuds Strike Israel, Causing No Damage or Casualties', 26 February 1991 — https://www.jta.org/archive/two-more-scuds-strike-israel-causing-no-damage-or-casualties — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "They were the 38th and 39th missiles launched at Israel from western Iraq since the Persian Gulf war began five weeks ago"
  - Supports:
    - 25 February 1991: the last Scuds on Israel, 39 in all (JTA)

**[S5327]** Jewish Telegraphic Agency, 'Curfew Blankets Territories on Third Intifada Anniversary', 10 December 1990 — https://www.jta.org/archive/curfew-blankets-territories-on-third-intifada-anniversary — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "712 Palestinians have been killed by Israeli security forces, according to an official count, and 23 Israelis have died"
  - Supports:
    - The intifada continued in December 1990: 712 Palestinians and 23 Israelis killed by then (official count)

**[S5328]** Jewish Telegraphic Agency, 'News Analysis: Peace Talks in Washington Point to Success of 4-year-old Intifada', 11 December 1991 — https://www.jta.org/archive/news-analysis-peace-talks-in-washington-point-to-success-of-4-year-old-intifada — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "More than 1,200 Palestinians have died in the intifada."
  - Supports:
    - The intifada was still going in its fourth year (December 1991)

**[S5329]** Jewish Telegraphic Agency, 'Fifth Anniversary of Intifada Requiring Beefed-up Security', 7 December 1992 — https://www.jta.org/archive/fifth-anniversary-of-intifada-requiring-beefed-up-security — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "Israel is beefing up security forces in Jerusalem and the territories amid weekend disturbances on the eve of the fifth anniversary of the outbreak of the Palestinian uprising known as the intifada."
  - Supports:
    - The intifada reached its fifth anniversary in December 1992

**[S5330]** Jewish Telegraphic Agency, 'Palestinian Terror Attacks Prompt a New Israeli Military Operation', 24 June 2002 — https://www.jta.org/archive/palestinian-terror-attacks-prompt-a-new-israeli-military-operation — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "the army would seize and hold Palestinian areas until the attacks cease."
  - Supports:
    - June 2002: after Defensive Shield the IDF re-entered Nablus, Jenin, Tulkarm, Bethlehem, Ramallah and Kalkilya to hold them

**[S5331]** Jewish Telegraphic Agency, 'Summit raises hopes in Mideast', 8 February 2005 — https://www.jta.org/2005/02/08/lifestyle/summit-raises-hopes-in-mideast — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "the end of four and a half years of bloodletting and despair"
  - Supports:
    - The Sharm el-Sheikh summit of 8 February 2005 is taken as the end of the Second Intifada

**[S5332]** Jewish Telegraphic Agency, 'Begin Sends Reagan Assurances Move into Lebanon is Limited', 7 June 1982 — https://www.jta.org/archive/begin-sends-reagan-assurances-move-into-lebanon-is-limited — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "to push back the terrorists to a distance of 40 kilometers (25 miles) to the north"
  - Supports:
    - June 1982: the announced aim was a 40 km zone

**[S5333]** Jewish Telegraphic Agency, 'Israel Captures Beirut Airport, Link Up with Christian Forces, Palestinians Are Surrounded', 15 June 1982 — https://www.jta.org/archive/israel-captures-beirut-airport-link-up-with-christian-forces-palestinians-are-surrounded — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "Israeli forces captured Beirut international airport at dawn today and seized a crossroad at Khalde south of Beirut, effectively surrounding Palestinian forces still in the city."
  - Supports:
    - 15 June 1982: the IDF reached Beirut and surrounded the PLO in the city

**[S5334]** Jewish Telegraphic Agency, 'Some 1,600 Terrorists Leave Beirut for South Yemen, Tunisia', 24 August 1982 — https://www.jta.org/archive/some-1600-terrorists-leave-beirut-for-south-yemen-tunisia — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "Some 1,600 PLO terrorists left Beirut today for South Yemen and Tunisia."
  - Supports:
    - August 1982: the PLO's evacuation from West Beirut

**[S5335]** Jewish Telegraphic Agency, 'Dayan: Action Was Decided by Military Not Civilian Authorities; Downing of Plane Has No Political Implications', 23 February 1973 — https://www.jta.org/archive/dayan-action-was-decided-by-military-not-civilian-authorities-downing-of-plane-has-no-political-im — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "Asked if Israel would offer compensations he said the question was not raised but private opinion is against it as Israel has nothing to be blamed for and the sole responsibility rests with the captain who disobeyed orders to land as directed."
  - Supports:
    - Defence Minister Dayan opposed paying compensation for Libyan Arab Airlines Flight 114

**[S5336]** Jewish Telegraphic Agency, 'Eban to Address Knesset on Proposal by Nasser That Dr. Goldmann Meet with Him', 7 April 1970 — https://www.jta.org/archive/eban-to-address-knesset-on-proposal-by-nasser-that-dr-goldmann-meet-with-him — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "The idea was rejected by the Israeli Cabinet."
  - Supports:
    - April 1970: the Cabinet rejected a meeting between Nahum Goldmann and Nasser; Goldmann said he would have gone as a private citizen

**[S5337]** Jewish Telegraphic Agency, 'Eban Defends Government Veto of Goldmann-Nasser Meeting; Opposition to Veto Mounts', 8 April 1970 — https://www.jta.org/archive/eban-defends-government-veto-of-goldmann-nasser-meeting-opposition-to-veto-mounts — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "But Israel cannot agree that the other side should dictate who should represent her and what views would be stated on her behalf."
  - Supports:
    - Foreign Minister Eban defended the veto; Gideon Hausner (Independent Liberals) urged readiness for new initiatives

**[S5338]** Jewish Telegraphic Agency, 'Knesset Approves by Vote of 65-5 Cabinet's Rejection of Goldmann-Nasser Meeting', 9 April 1970 — https://www.jta.org/archive/knesset-approves-by-vote-of-65-5-cabinets-rejection-of-goldmann-nasser-meeting — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "The vote was 65-5 to endorse Foreign Minister Abba Eban"
  - Supports:
    - The Knesset endorsed the veto 65-5 on 8-9 April 1970

**[S5339]** Jewish Telegraphic Agency, 'Police Disperse Students Protesting Hebron Policy and Goldmann-Nasser Decision', 13 April 1970 — https://www.jta.org/archive/police-disperse-students-protesting-hebron-policy-and-goldmann-nasser-decision — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "Eight students were arrested and four of them, including a girl, were treated for minor injuries after a small group of demonstrators scaled the wall surrounding Premier Golda Meir"
  - Supports:
    - Student protests against the Goldmann decision, April 1970

**[S5340]** Jewish Telegraphic Agency, 'Carnage in Galilee Town: Terrorists Strike Again', 16 May 1974 — https://www.jta.org/archive/carnage-in-galilee-town-terrorists-strike-again — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "The Israeli government, meeting in tense emergency session this morning, agreed to the terrorist demands."
  - Supports:
    - Ma'alot, 15 May 1974: the cabinet agreed to exchange 20 prisoners for the children, then troops stormed the school at 5:30 p.m.

**[S5341]** Jewish Telegraphic Agency, 'Dayan: No Surrender to Terrorists Holding Hostages of Any Age', 11 July 1974 — https://www.jta.org/archive/dayan-no-surrender-to-terrorists-holding-hostages-of-any-age — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "Their decision, which he said he opposed, was to agree to a simultaneous exchange of prisoners for hostages"
  - Supports:
    - Defence Minister Dayan opposed the cabinet's decision to negotiate at Ma'alot

**[S5342]** Jewish Telegraphic Agency, 'Horev Committee Absolves Army, Police, School Officials of Blame for Deaths of Maalot Children', 11 July 1974 — https://www.jta.org/archive/horev-committee-absolves-army-police-school-officials-of-blame-for-deaths-of-maalot-children — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-wars-events builder; page opened (curl with a browser user-agent) and the quote checked verbatim on 2026-10-12.
  - Quote: "absolved the army, police and school authorities of blame for the deaths of 21 Israeli high school students, three members of the Cohen family and a soldier at the hands of terrorists in the Maalot schoolhouse last May 15."
  - Supports:
    - Horev committee: 21 students, three members of the Cohen family and a soldier were killed at Ma'alot

**[S5400]** Jewish Telegraphic Agency, 'Knesset Votes Compromise on Adoption of Constitution; Will Develop Basic Legislation', Daily Bulletin, 14 June 1950 — https://www.jta.org/archive/knesset-votes-compromise-on-adoption-of-constitution-will-develop-basic-legislation — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-1948 data agent; page opened with curl and a browser user-agent and the quote checked verbatim in the raw text on 2026-10-12.
  - Quote: "a compromise offered by the Mapai, Sephardim, Progressives and WIZO"
  - Supports:
    - On 13 June 1950 the Knesset adopted, 50 to 0 with 13 abstentions, a compromise to build a constitution gradually out of basic legislation; the Religious Bloc had supported postponing a constitution indefinitely, 37 members wanted one drafted immediately, and Mapam (Dr. Moshe Sneh) said it would fight the arrangement.

**[S5401]** Jewish Telegraphic Agency, 'Israel Parliament Debates Government's Approval of U.N. Resolution on Korea', Daily Bulletin, 5 July 1950 — https://www.jta.org/archive/israel-parliament-debates-governments-approval-of-u-n-resolution-on-korea — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-1948 data agent; page opened with curl and a browser user-agent and the quote checked verbatim in the raw text on 2026-10-12.
  - Quote: "remains one of non-identification with any side"
  - Supports:
    - On 5 July 1950 Foreign Minister Sharett told the Knesset that Israel's policy remained non-identification but did not mean escaping international responsibilities; Mapam's Ben-Aharon attacked the cabinet's support for the Security Council Korea resolution, and Herut and the Communists tabled motions against it.

**[S5402]** Jewish Telegraphic Agency, 'Israel Parliament Votes Approval of Cabinet Stand on U.N. Resolution to Aid Korea', Daily Bulletin, 6 July 1950 — https://www.jta.org/archive/israel-parliament-votes-approval-of-cabinet-stand-on-u-n-resolution-to-aid-korea — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-1948 data agent; page opened with curl and a browser user-agent and the quote checked verbatim in the raw text on 2026-10-12.
  - Quote: "a Mapam motion for a vote of no confidence was defeated by 79 to 19"
  - Supports:
    - The Knesset upheld the cabinet's support for the UN Security Council resolution on Korea by 68 to 20 with 8 abstentions; Ben-Gurion closed the debate for the government.

**[S5403]** Jewish Telegraphic Agency, 'Israel Advised by Friendly Nations to Test Egypt on Suez Passage', Daily Bulletin, 29 April 1957 — https://www.jta.org/archive/israel-advised-by-friendly-nations-to-test-egypt-on-suez-passage — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-1948 data agent; page opened with curl and a browser user-agent and the quote checked verbatim in the raw text on 2026-10-12.
  - Quote: "would be for Israel to test the issue by sending a ship, or at least Israel-bound cargo through the Canal"
  - Supports:
    - In April 1957 UN delegations friendly to Israel advised that the only way to learn whether Egypt would allow free passage was to send an Israeli ship or at least Israel-bound cargo through the Suez Canal.

**[S5404]** Jewish Telegraphic Agency, 'Canal Users' Decision on Suez Frees Israel's Hand, Aide Says', Daily Bulletin, 14 May 1957 — https://www.jta.org/archive/canal-users-decision-on-suez-frees-israels-hand-aide-says — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-1948 data agent; page opened with curl and a browser user-agent and the quote checked verbatim in the raw text on 2026-10-12.
  - Quote: "an Israeli ship would be sent to the Suez Canal"
  - Supports:
    - On 14 May 1957 an Israeli Foreign Ministry spokesman said an Israeli ship would be sent through the Suez Canal 'at a suitable time' and that stopping it would be 'an act of war'.

**[S5405]** Jewish Telegraphic Agency, 'Israel's Decision on Sending Test Ship Through Suez Hinges on France', Daily Bulletin, 4 June 1957 — https://www.jta.org/archive/israels-decision-on-sending-test-ship-through-suez-hinges-on-france — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-1948 data agent; page opened with curl and a browser user-agent and the quote checked verbatim in the raw text on 2026-10-12.
  - Quote: "Israel has not promised the United States not to use force to push a ship through the canal"
  - Supports:
    - In June 1957 Israel held up its decision on a Suez test ship pending France's intentions, had not promised the US to refrain from force, and opposed taking the question to the Hague Court.

**[S5406]** Jewish Telegraphic Agency, 'Israel Awaits France's Action on Suez Shipping; Will Follow Lead', Daily Bulletin, 10 June 1957 — https://www.jta.org/archive/israel-awaits-frances-action-on-suez-shipping-will-follow-lead — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-1948 data agent; page opened with curl and a browser user-agent and the quote checked verbatim in the raw text on 2026-10-12.
  - Quote: "Israel will make no effort to send cargoes through the Suez Canal unless France agrees to authorise its shippers to use the canal"
  - Supports:
    - On 10 June 1957 the Foreign Ministry said Israel would send no cargoes through the canal unless France led; Ben-Gurion told Hebrew editors Israel would first test Egypt with cargoes in foreign ships and was determined to send an Israeli ship at the appropriate time.

**[S5407]** Jewish Telegraphic Agency, 'Continued Anti-Israel Blockade of Suez May Force Israel into Action', Daily Bulletin, 27 March 1959 — https://www.jta.org/archive/continued-anti-israel-blockade-of-suez-may-force-israel-into-action — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-1948 data agent; page opened with curl and a browser user-agent and the quote checked verbatim in the raw text on 2026-10-12.
  - Quote: "The third ship from which the Egyptian authorities took off Israel cargo at the Suez Canal was the Greek freighter Nicolas Karis"
  - Supports:
    - By March 1959 Egypt had seized Israeli cargo from three foreign ships at the Suez Canal and Israel prepared to take its complaint to the Security Council.

**[S5408]** Jewish Telegraphic Agency, 'Israel Cabinet Discusses Action Against Egypt in Suez Dispute', Daily Bulletin, 15 June 1959 — https://www.jta.org/archive/israel-cabinet-discusses-action-against-egypt-in-suez-dispute — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-1948 data agent; page opened with curl and a browser user-agent and the quote checked verbatim in the raw text on 2026-10-12.
  - Quote: "the refusal by the United Arab Republic to permit the passage through the Suez Canal of the Danish freighter Inge Toft"
  - Supports:
    - In June 1959 Egypt held the Danish freighter Inge Toft, carrying Israeli cargo, at the canal entrance for more than three weeks; the cabinet discussed steps but expected little beyond UN action.

**[S5409]** Jewish Telegraphic Agency, 'First Israeli-flag Vessel Navigates the Suez Canal', Daily Bulletin, 1 May 1979 — https://www.jta.org/archive/first-israeli-flag-vessel-navigates-the-suez-canal — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-1948 data agent; page opened with curl and a browser user-agent and the quote checked verbatim in the raw text on 2026-10-12.
  - Quote: "She became the first Israel-flag vessel ever to navigate the Suez Canal"
  - Supports:
    - The freighter Ashdod on 1 May 1979 became the first Israeli-flag vessel to transit the Suez Canal, ending the Egyptian ban in force since 1948.

**[S5410]** Jewish Telegraphic Agency, 'Knesset Backs Government's Devaluation Policy; Rejects Opposition Move', Daily Bulletin, 20 February 1962 — https://www.jta.org/archive/knesset-backs-governments-devaluation-policy-rejects-opposition-move — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-1948 data agent; page opened with curl and a browser user-agent and the quote checked verbatim in the raw text on 2026-10-12.
  - Quote: "by defeating by a vote of 66 to 43 three non-confidence motions"
  - Supports:
    - The pound was devalued on 9 February 1962 from 1.8 to 3 pounds to the dollar; on 20 February the Knesset defeated Herut, Mapam and Communist no-confidence motions 66 to 43, Ahdut HaAvoda voting with the coalition while demanding relief for farmers' dollar-linked mortgages; the Manufacturers Association agreed to freeze prices for six months.

**[S5411]** Jewish Telegraphic Agency, 'Government Seeks to Delay Knesset Vote on Devaluation Issue', Daily Bulletin, 15 February 1962 — https://www.jta.org/archive/government-seeks-to-delay-knesset-vote-on-devaluation-issue — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-1948 data agent; page opened with curl and a browser user-agent and the quote checked verbatim in the raw text on 2026-10-12.
  - Quote: "which has threatened to defect from the coalition unless additional relief is assured to workers and farmers"
  - Supports:
    - On 15 February 1962 Finance Minister Eshkol delayed a Knesset vote on the devaluation while negotiating with Ahdut HaAvoda, which threatened to leave the coalition unless workers and farmers received relief.

**[S5412]** Jewish Telegraphic Agency, 'Dissension Growing in Israel Labor Ranks over New Economic Policy', Daily Bulletin, 2 March 1962 — https://www.jta.org/archive/dissension-growing-in-israel-labor-ranks-over-new-economic-policy — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-1948 data agent; page opened with curl and a browser user-agent and the quote checked verbatim in the raw text on 2026-10-12.
  - Quote: "The left-wing party had publicly demanded, shortly after devaluation was announced last February 9, that such allowances be immediately increased for workers"
  - Supports:
    - In March 1962 Ahdut HaAvoda demanded an immediate increase in cost-of-living allowances after the devaluation; Eshkol warned that the Mapai and the Histadrut must back the policy and wait for the July adjustment.

**[S5413]** Jewish Telegraphic Agency, 'Ben-Gurion Secures Labor Backing of Govt.'s New Economic Policy', Daily Bulletin, 13 March 1962 — https://www.jta.org/archive/ben-guion-secures-labor-backing-of-govt-s-new-economic-policy — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-1948 data agent; page opened with curl and a browser user-agent and the quote checked verbatim in the raw text on 2026-10-12.
  - Quote: "All the leaders pleaded for the support of the new economic policy"
  - Supports:
    - On 12 March 1962 Ben-Gurion, Eshkol, Dayan and Aharon Becker won the backing of Mapai workers' committees for the new economic policy and for preventing early cost-of-living allowance increases.

**[S5414]** Jewish Telegraphic Agency, 'Israel Government Seeks to Resist Labor Pressure for Wage Increases', Daily Bulletin, 24 April 1962 — https://www.jta.org/archive/israel-government-seeks-to-resist-labor-pressure-for-wage-increases — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-1948 data agent; page opened with curl and a browser user-agent and the quote checked verbatim in the raw text on 2026-10-12.
  - Quote: "Two leftist parties, Mapam and Ahdut Avodah, are demanding a special Cabinet discussion on the subject"
  - Supports:
    - In April 1962 Eshkol and Sapir held out against higher July cost-of-living allowances and proposed paying them in government bonds, while the Histadrut trade-union department called for a higher scale and Mapam and Ahdut HaAvoda demanded a cabinet discussion.

**[S5415]** Jewish Telegraphic Agency, 'Knesset Supports New Economic Policy; Approves Compulsory Savings', Daily Bulletin, 29 May 1962 — https://www.jta.org/archive/knesset-supports-new-economic-policy-approves-compulsory-savings — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-1948 data agent; page opened with curl and a browser user-agent and the quote checked verbatim in the raw text on 2026-10-12.
  - Quote: "Knesset (Parliament) today voted support of the Governments new economic policy"
  - Supports:
    - On 29 May 1962 the Knesset voted 56 to 39 to support the new economic policy, including Eshkol's compulsory savings plan refundable after three years.

**[S5416]** Jewish Telegraphic Agency, 'Israel's Oil Pipeline from Red Sea to Mediterranean Completed', Daily Bulletin, 14 November 1960 — https://www.jta.org/archive/israels-oil-pipeline-from-red-sea-to-mediterranean-completed — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-1948 data agent; page opened with curl and a browser user-agent and the quote checked verbatim in the raw text on 2026-10-12.
  - Quote: "a pipeline for the transfer of oil from the Red Sea to the Mediterranean, was completed here today"
  - Supports:
    - On 14 November 1960 Israel completed an oil pipeline carrying crude from the Gulf of Aqaba port of Eilat to Haifa, an 'overland Suez Canal'.

**[S5425]** Jewish Telegraphic Agency, 'Controversial Koenig Report Continues to Generate Controversy' (24 Sep 1976) — https://www.jta.org/archive/controversial-koenig-report-continues-to-generate-controversy — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-1966 data agent; page fetched with curl and a browser user-agent on 2026-10-12 and the quote checked verbatim against the raw page text.
  - Quote: "drew praise from Likud quarters and from the religious parties"
  - Supports:
    - Likud and the religious parties praised the Koenig memorandum's ideas; Burg praised Koenig and rejected demands for his dismissal; Rabin called it an internal communication of little consequence

**[S5426]** Jewish Telegraphic Agency, 'Cabinet Bars Return of Arabs to Border Villages Evacuated in '48' (24 Jul 1972) — https://www.jta.org/archive/cabinet-bars-return-of-arabs-to-border-villages-evacuated-in-48 — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-1966 data agent; page fetched with curl and a browser user-agent on 2026-10-12 and the quote checked verbatim against the raw page text.
  - Quote: "The Cabinet ruled by a majority decision today not to permit the former residents of Ikrit and Baram villages to return"
  - Supports:
    - Cabinet majority barred the return of the Ikrit and Baram villagers on 23 July 1972, upholding the army's security grounds and offering compensation and relocation; Archbishop Raya backed the claim

**[S5427]** Jewish Telegraphic Agency, 'Mapam Demands Cabinet Meet Again on Issue; Archbishop Publicly Challenges Mrs. Meir on Ban on Village Return' (10 Aug 1972) — https://www.jta.org/archive/mapam-demands-cabinet-meet-again-on-issue-archbishop-publicly-challenges-mrs-meir-on-ban-on-village — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-1966 data agent; page fetched with curl and a browser user-agent on 2026-10-12 and the quote checked verbatim against the raw page text.
  - Quote: "voted against that decision, along with Deputy Premier Yigal Allon and Tourism Minister Moshe Kol"
  - Supports:
    - Mapam ministers Peled and Shemtov, Deputy Premier Allon and Minister Kol voted against the 23 July 1972 decision; Archbishop Raya's open letter; Meir feared a precedent for 20 other evacuated villages

**[S5428]** Jewish Telegraphic Agency, 'Report to Cabinet: Eban Says Will Bring Issue of Soviet Charges Before UN General Assembly and UNESCO' (28 Aug 1972) — https://www.jta.org/archive/report-to-cabinet-eban-says-will-bring-issue-of-soviet-charges-before-un-general-assembly-and-unesco — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-1966 data agent; page fetched with curl and a browser user-agent on 2026-10-12 and the quote checked verbatim against the raw page text.
  - Quote: "American officials prefer quiet diplomacy to bring pressure on the Soviets"
  - Supports:
    - Eban told the cabinet he would raise the Soviet exit charges at the UN General Assembly and UNESCO, while US officials preferred quiet diplomacy

**[S5429]** Jewish Telegraphic Agency, 'Unanimous Stand Taken at Extraordinary Session: Knesset Calls on Soviets to Cancel Huge Exit Charges' (24 Aug 1972) — https://www.jta.org/archive/unanimous-stand-taken-at-extraordinary-session-knesset-calls-on-soviets-to-cancel-huge-exit-charges — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-1966 data agent; page fetched with curl and a browser user-agent on 2026-10-12 and the quote checked verbatim against the raw page text.
  - Quote: "Israel’s Knesset adopted unanimously today a resolution calling on the Soviet government to repeal the huge new charges"
  - Supports:
    - Extraordinary Knesset session, led by Premier Meir, unanimously called on the USSR to repeal the exit charges on Jewish academics

**[S5430]** Jewish Telegraphic Agency, 'Nixon Asks Broad Authority to Grant U.S. Trade Benefits to Any Countries Including USSR' (11 Apr 1973) — https://www.jta.org/archive/nixon-asks-broad-authority-to-grant-u-s-trade-benefits-to-any-countries-including-ussr — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-1966 data agent; page fetched with curl and a browser user-agent on 2026-10-12 and the quote checked verbatim against the raw page text.
  - Quote: "would withhold most favored nation status from any country that denies its citizens the right to emigrate"
  - Supports:
    - Senator Jackson's amendment linking most-favoured-nation status to free emigration, with Javits in support, against Nixon's quiet diplomacy

**[S5431]** Jewish Telegraphic Agency, 'Death Penalty Urged for Terrorists' (13 Sep 1972) — https://www.jta.org/archive/death-penalty-urged-for-terrorists — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-1966 data agent; page fetched with curl and a browser user-agent on 2026-10-12 and the quote checked verbatim against the raw page text.
  - Quote: "made a strong plea for the death penalty"
  - Supports:
    - After Meir's Munich report, Beigin, Harari and Hausner urged the death penalty for terrorists; the Knesset resolved to act with perseverance against the terrorist organizations

**[S5432]** Jewish Telegraphic Agency, 'Cabinet Briefed on Munich Security' (12 Sep 1972) — https://www.jta.org/archive/cabinet-briefed-on-munich-security — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-1966 data agent; page fetched with curl and a browser user-agent on 2026-10-12 and the quote checked verbatim against the raw page text.
  - Quote: "Israel was making a major diplomatic effort to get European governments to step up their measures against terrorist activities within their borders"
  - Supports:
    - Foreign Minister Eban told the cabinet of a diplomatic drive for practical steps by European governments against terrorism after Munich

**[S5433]** Jewish Telegraphic Agency, 'Mossad Reprisal for '72 Massacre Confirmed in Israel TV Interview' (24 Nov 1993) — https://www.jta.org/archive/mossad-reprisal-for-72-massacre-confirmed-in-israel-tv-interview — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-1966 data agent; page fetched with curl and a browser user-agent on 2026-10-12 and the quote checked verbatim against the raw page text.
  - Quote: "approved the assassination of 10 to 15 terrorists"
  - Supports:
    - Aharon Yariv, Meir's adviser on terrorism, confirmed that the government approved the Mossad's killing of 10 to 15 Black September figures after Munich

**[S5434]** Jewish Telegraphic Agency, 'Israeli Army Chief Hints More Commando Raids Unless Lebanon Denies Facilities to Terrorists' (11 Apr 1973) — https://www.jta.org/archive/israeli-army-chief-hints-more-commando-raids-unless-lebanon-denies-facilities-to-terrorists — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-1966 data agent; page fetched with curl and a browser user-agent on 2026-10-12 and the quote checked verbatim against the raw page text.
  - Quote: "the three Fatah leaders were involved in the preparation of the massacre last Sept. 5"
  - Supports:
    - Chief of Staff Elazar said the Beirut raid of April 1973 killed Fatah leaders involved in preparing Munich; Meir praised the raid

**[S5435]** Jewish Telegraphic Agency, 'Labor Party Secretariat Overwhelmingly Approves Dayan Plan' (5 Sep 1973) — https://www.jta.org/archive/labor-party-secretariat-overwhelmingly-approves-dayan-plan — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-1966 data agent; page fetched with curl and a browser user-agent on 2026-10-12 and the quote checked verbatim against the raw page text.
  - Quote: "The various facets of the plan originated with Dayan and were drafted into document form by Minister-Without-Portfolio Israel Galili"
  - Supports:
    - Labor Secretariat approved the Dayan-Galili settlement plan 78-0; Meir backed it, Sapir opposed parts, Mapam opposed it; Carmel's proposal for further discussion lost 65-13

**[S5436]** Jewish Telegraphic Agency, 'Elements in the Dayan Plan' (5 Sep 1973) — https://www.jta.org/archive/elements-in-the-dayan-plan — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-1966 data agent; page fetched with curl and a browser user-agent on 2026-10-12 and the quote checked verbatim against the raw page text.
  - Quote: "The plan calls for the establishment of a buffer zone in the Rafiah area between the Gaza Strip and Sinai"
  - Supports:
    - Contents of the Dayan plan: lifting the ban on private land purchases in the territories, a Rafiah buffer zone, the coastal city of Yamit, and aid to Gaza refugees

**[S5450]** Los Angeles Times, "Shin Bet Affair Revives Israeli Dispute of Security Needs Versus the Law", 27 Jun 1986 — https://www.latimes.com/archives/la-xpm-1986-06-27-mn-20445-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-forks 1986-2005 agent; page opened via curl with a browser user-agent and every cited quote checked verbatim against the page text.
  - Quote: "Herzog’s decision, combined with the resignation of Shin Bet chief Avraham Shalom, effectively sidetracked a full-scale public inquiry into the scandal"
  - Supports:
    - Herzog's pardon of Shin Bet chief Shalom and three aides; inner cabinet approval; calls for an inquiry (Weizman, Shahal), 25-27 Jun 1986

**[S5451]** Los Angeles Times, "Israeli Official Who Pushed Cover-up Probe Is Replaced", 2 Jun 1986 — https://www.latimes.com/archives/la-xpm-1986-06-02-mn-8351-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-forks 1986-2005 agent; page opened via curl with a browser user-agent and every cited quote checked verbatim against the page text.
  - Quote: "the search for Zamir’s successor was accelerated only after the attorney general decided to order a police investigation of the security scandal"
  - Supports:
    - Attorney General Zamir's police investigation of the Shin Bet cover-up and his replacement, Jun 1986

**[S5452]** Los Angeles Times, "Shamir Accused of Cover-up Involvement", 29 Jun 1986 — https://www.latimes.com/archives/la-xpm-1986-06-29-mn-393-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-forks 1986-2005 agent; page opened via curl with a browser user-agent and every cited quote checked verbatim against the page text.
  - Quote: "Government leaders had opposed an official investigation, warning that it would damage the top-secret counterterrorism agency"
  - Supports:
    - Cabinet and Knesset reaction to the pardon; government leaders opposed an official investigation, 29 Jun 1986

**[S5453]** Los Angeles Times, "Religious Parties Choose Shamir: Votes of 2 Groups Open Way for Him to Form Israeli Government", 14 Nov 1988 — https://www.latimes.com/archives/la-xpm-1988-11-14-mn-53-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-forks 1986-2005 agent; page opened via curl with a browser user-agent and every cited quote checked verbatim against the page text.
  - Quote: "The price that Likud paid the religious parties includes support for a controversial law that would grant Orthodox rabbis authority over Jewish conversions."
  - Supports:
    - Shas and Agudat Israel back Likud; Law of Return conversion amendment as the price, 14 Nov 1988

**[S5454]** Los Angeles Times, "Likud, Labor Join in Israel Coalition: Accord Keeps Shamir as Premier, Assigns Finance Ministry to Peres", 20 Dec 1988 — https://www.latimes.com/archives/la-xpm-1988-12-20-mn-596-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-forks 1986-2005 agent; page opened via curl with a browser user-agent and every cited quote checked verbatim against the page text.
  - Quote: "In the new Likud-Labor agreement, the pledge is dropped in favor of maintaining the status quo"
  - Supports:
    - Likud-Labor coalition agreement drops the Law of Return pledge, 20 Dec 1988

**[S5455]** Los Angeles Times, "Shamir Presents His Coalition Cabinet, Says It's Needed to Prevent Palestine State", 22 Dec 1988 — https://www.latimes.com/archives/la-xpm-1988-12-22-mn-1084-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-forks 1986-2005 agent; page opened via curl with a browser user-agent and every cited quote checked verbatim against the page text.
  - Quote: "Shamir said he could have formed a narrow coalition government with small religious and right-wing parties but preferred to share power with Labor"
  - Supports:
    - Shamir preferred a coalition with Labor over a narrow religious-right government, 22 Dec 1988

**[S5456]** Los Angeles Times, "Rabin Offers Plan for Partial Golan Pullback", 9 Sep 1994 — https://www.latimes.com/archives/la-xpm-1994-09-09-mn-36419-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-forks 1986-2005 agent; page opened via curl with a browser user-agent and every cited quote checked verbatim against the page text.
  - Quote: "Rabin said Israel would then want, as part of that test, a three-year period to develop diplomatic relations and other ties before proceeding with a more substantial but phased withdrawal from the region."
  - Supports:
    - Rabin's phased Golan offer; Syrian reaction; Labor MKs' referendum bill, Sep 1994

**[S5457]** Los Angeles Times, "Next Step: Standing Their Ground in Golan", 4 Oct 1994 — https://www.latimes.com/archives/la-xpm-1994-10-04-wr-46151-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-forks 1986-2005 agent; page opened via curl with a browser user-agent and every cited quote checked verbatim against the page text.
  - Quote: "the estimated 16,000 Israelis living in 33 settlements on the Golan Heights"
  - Supports:
    - About 16,000 Israelis in 33 Golan settlements; settler reaction to the Rabin offer, Oct 1994

**[S5458]** Los Angeles Times, "Rabin Backs Seizure of Palestinian Land in E. Jerusalem", 1 May 1995 — https://www.latimes.com/archives/la-xpm-1995-05-01-mn-61025-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-forks 1986-2005 agent; page opened via curl with a browser user-agent and every cited quote checked verbatim against the page text.
  - Quote: "the first in East Jerusalem since 1981"
  - Supports:
    - East Jerusalem land expropriation, first since 1981, and Har Homa plans, 1 May 1995

**[S5459]** Los Angeles Times, "Rabin Puts Lid on Land Takeovers", 15 May 1995 — https://www.latimes.com/archives/la-xpm-1995-05-15-mn-883-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-forks 1986-2005 agent; page opened via curl with a browser user-agent and every cited quote checked verbatim against the page text.
  - Quote: "The four Meretz Cabinet ministers had demanded that the government freeze or cancel its order to confiscate the land"
  - Supports:
    - Cabinet vote on the Jerusalem confiscation; Meretz demand to freeze or cancel; Peres: no retreat, 14-15 May 1995

**[S5460]** Los Angeles Times, "Israeli Arabs Emboldened by Victory", 24 May 1995 — https://www.latimes.com/archives/la-xpm-1995-05-24-mn-5495-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-forks 1986-2005 agent; page opened via curl with a browser user-agent and every cited quote checked verbatim against the page text.
  - Quote: "The day after they forced Israel’s government to back down from its plan to confiscate Palestinian-owned property here"
  - Supports:
    - The government backs down after a no-confidence motion by Arab parties, 22-24 May 1995

**[S5461]** Los Angeles Times (Associated Press), "Deal OKd to Give Egypt Control of Gaza Border", 1 Sep 2005 — https://www.latimes.com/archives/la-xpm-2005-sep-01-fg-gaza1-story.html — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fix-forks 1986-2005 agent; page opened via curl with a browser user-agent and every cited quote checked verbatim against the page text.
  - Quote: "Netanyahu insisted on Israeli control of the Egypt-Gaza border, the Gaza seacoast and airspace."
  - Supports:
    - Knesset approves Egyptian border police on the Gaza frontier 53-28; Netanyahu demands Israeli control, 31 Aug-1 Sep 2005

**[S5475]** Jewish Telegraphic Agency, 'Deaths on Gaza border hand Hamas a PR victory and Israel an angry internal debate', 2 Apr 2018 — https://www.jta.org/2018/04/02/israel/deaths-gaza-border-hand-hamas-pr-victory-israel-angry-internal-debate — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-2006 data agent; page opened with curl (browser user-agent) and quote checked verbatim on 2026-10-12.
  - Quote: "Lt. Gen. Gadi Eisenkot, said in interviews that his soldiers were prepared to use live fire to quell violent rioting and that 100 Israeli snipers would be put into place around the border"
  - Supports:
    - Eisenkot's live-fire and sniper plan, Liberman's rejection of an international inquiry, Zandberg's call for a probe of the rules of engagement

**[S5476]** Jewish Telegraphic Agency, 'Netanyahu reaches out to form a government with his rival and gets rejected', 19 Sep 2019 — https://www.jta.org/2019/09/19/israel/netanyahu-reaches-out-to-form-a-government-with-his-rival-and-gets-rejected — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-2006 data agent; page opened with curl (browser user-agent) and quote checked verbatim on 2026-10-12.
  - Quote: "asking him to form a “broad unity government.”"
  - Supports:
    - Netanyahu's unity-government offer and Gantz's liberal-coalition position, Sept 2019

**[S5477]** Jewish Telegraphic Agency (Gabe Friedman and Ron Kampeas), 'A 5th Israeli election in 3 years? Here is how we got here and what happens next', 23 Jun 2022 — https://www.jta.org/2022/06/23/israel/a-5th-israeli-election-in-3-years-heres-how-we-got-here-and-what-happens-next — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-2006 data agent; page opened with curl (browser user-agent) and quote checked verbatim on 2026-10-12.
  - Quote: "announced that they will help fast-track a bill to dissolve the Knesset"
  - Supports:
    - Bennett and Lapid's dissolution bill and the House Committee delay allowing Netanyahu to try an alternative government

**[S5478]** Center for American Progress, 'Backgrounder on the Palestinians Bid For Statehood at the United Nations', 21 Sep 2011 — https://www.americanprogress.org/article/backgrounder-on-the-palestinians-bid-for-statehood-at-the-united-nations/ — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the fixforks-2006 data agent; page opened with curl (browser user-agent) and quote checked verbatim on 2026-10-12.
  - Quote: "Lieberman hinted that Israel would declare the Oslo Accords void"
  - Supports:
    - Lieberman's hint that Israel would void Oslo; Netanyahu's call to Abbas to negotiate

**[S5500]** JTA, 'Israel Votes 2003: Some Familiar Faces Resign After Their Parties Fare Poorly in Elections' (2003-01-30) — https://www.jta.org/archive/israel-votes-2003-some-familiar-faces-resign-after-their-parties-fare-poorly-in-elections — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the coalition-fix helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the page text.
  - Quote: "whose new leader, Effi Eitam, failed to draw additional Knesset seats to the party"
  - Supports:
    - Names the party advocate/leader used in a coalition-government (governments.json) entry

**[S5501]** JTA, 'News Analysis: Battle with Shas leaves bad blood, but Barak still needs party's support' (1999-09-28) — https://www.jta.org/1999/09/28/lifestyle/news-analysis-battle-with-shas-leaves-bad-blood-but-barak-still-needs-partys-support — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the coalition-fix helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the page text.
  - Quote: "Prime Minister Ehud Barak, Education Minister Yossi Sarid and Shas leader Eli Yishai"
  - Supports:
    - Names the party advocate/leader used in a coalition-government (governments.json) entry

**[S5502]** JTA, 'If Annapolis fails, what then?' (2007-11-19) — https://www.jta.org/2007/11/19/israel/if-annapolis-fails-what-then — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the coalition-fix helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the page text.
  - Quote: "Avigdor Lieberman and Eli Yishai, leaders of the right-wing Yisrael Beiteinu and Shas parties, threatened to bolt the coalition"
  - Supports:
    - Names the party advocate/leader used in a coalition-government (governments.json) entry

**[S5503]** JTA, 'Israeli election campaign heats up' (2009-01-27) — https://www.jta.org/2009/01/27/israel/israeli-election-campaign-heats-up — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the coalition-fix helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the page text.
  - Quote: "Shas leader Eli Yishai said."
  - Supports:
    - Names the party advocate/leader used in a coalition-government (governments.json) entry

**[S5504]** JTA, 'News Analysis: Dismantlement of settlements will test Barak and peace process' (1999-10-12) — https://www.jta.org/1999/10/12/lifestyle/news-analysis-dismantlement-of-settlements-will-test-barak-and-peace-process — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the coalition-fix helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the page text.
  - Quote: "Housing Minister Yitzhak Levy of the National Religious Party"
  - Supports:
    - Names the party advocate/leader used in a coalition-government (governments.json) entry

**[S5505]** JTA, 'Agudat Israel Decides Not to Introduce who is a Jew Amendment for a Knesset Vote' (1982-04-01) — https://www.jta.org/archive/agudat-israel-decides-not-to-introduce-who-is-a-jew-amendment-for-a-knesset-vote — accessed: 2026-10-12 — provenance: opened
  - Note: Added by the coalition-fix helper; page fetched with curl (browser user-agent) on 2026-10-12 and the quote checked verbatim in the page text.
  - Quote: "Another Aguda MK, Menachem Porush, vowed that his party would"
  - Supports:
    - Names the party advocate/leader used in a coalition-government (governments.json) entry

**[S5506]** MASHAV (Israel's Agency for International Development Cooperation, Ministry of Foreign Affairs), 'About Us', mashav.mfa.gov.il, archived 2024 — http://mashav.mfa.gov.il/ — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-endgame's source helper; page fetched via the web.archive.org copy with curl (browser user-agent) on 2026-10-13 and the quote checked verbatim in the page text.
  - Quote: "MASHAV, Israel’s Agency for International Development Cooperation at Israel’s Ministry of Foreign Affairs, was established in 1958 following the vision of then Foreign Minister Golda Meir and Prime Minister David Ben Gurion"
  - Supports:
    - MASHAV, Israel's development-cooperation agency, was established in 1958 under Golda Meir and Ben-Gurion

**[S5507]** Stacy Perman, 'Spies Inc.: Business Innovation from Israel's Masters of Espionage' (Pearson, 2004), excerpt Part II, posted 22 Nov 2004 (800ceoread.com) — http://800ceoread.com/excerpts/archives/cat_spies_inc_by_stacy_perman.html — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-endgame's source helper; page fetched via the web.archive.org copy with curl (browser user-agent) on 2026-10-13 and the quote checked verbatim in the page text.
  - Quote: "In 1979, Eitan took that leap and green-lighted Talpiot, although initially he gave it one year."
  - Supports:
    - The IDF Talpiot elite science-and-technology training programme was approved in 1979 (Chief of Staff Eitan)

**[S5508]** FBC Lawyers, 'Underlying legal and regulatory framework of the Office of the Chief Scientist of the Israeli Ministry of the Economy' — http://www.fbclawyers.com/news/underlying-legal-and-regulatory-framework-of-office-of-the-chief-scientist-of-the-israeli-ministry-of-the-economy/ — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-endgame's source helper; page fetched with curl (browser user-agent) on 2026-10-13 and the quote checked verbatim in the page text.
  - Quote: "Pursuant to the Encouragement of Industrial Research and Development Law, 1984 and the regulations promulgated thereunder"
  - Supports:
    - The Law for the Encouragement of Industrial Research and Development (1984) is the basis of Israeli government R&D grants (Office of the Chief Scientist, later the Innovation Authority)

**[S5509]** Tabansky and Ben Israel, 'Cybersecurity in Israel', SpringerBriefs in Cybersecurity (2015), chapter abstract, Springer Nature Link — https://link.springer.com/chapter/10.1007/978-3-319-18986-4_7 — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-endgame's source helper; page fetched with curl (browser user-agent) on 2026-10-13 and the quote checked verbatim in the page text.
  - Quote: "The current National cyber-strategy of Israel stemmed from the National Cyber Initiative and was declared in the Government Resolution 3611 ‘Advancing the national capacity in cyberspace’."
  - Supports:
    - Israel's national cyber strategy was declared in Government Resolution 3611 (2011) and the Israel National Cyber Bureau established to implement it

**[S5510]** Israel Space Agency (Ministry of Innovation, Science and Technology), 'The Israel Space Agency', space.gov.il — http://space.gov.il/en — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-endgame's source helper; page fetched with curl (browser user-agent) on 2026-10-13 and the quote checked verbatim in the page text.
  - Quote: "The Israel Space Agency, founded following a government decision in 1983, is a national agency operating under the auspices of the Ministry of Science and Technology."
  - Supports:
    - The Israel Space Agency was established in 1983

**[S5511]** Jewish Telegraphic Agency, 'NASA: Mideast drought the worst in 900 years', 4 March 2016 — https://www.jta.org/2016/03/04/israel/nasa-mideast-drought-the-worst-in-900-years — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-endgame's source helper; page fetched with curl (browser user-agent) on 2026-10-13 and the quote checked verbatim in the page text.
  - Quote: "According to a government decision, by 2020 the desalination plants should reach a capacity of 750 million cubic meters."
  - Supports:
    - Official national desalination target of 750 million m3 a year by 2020
    - Six desalination plants provided about 70 percent of Israel's drinking water (2016)

**[S5512]** Jewish Telegraphic Agency, 'Drought poses tough choices for Israel', 20 August 2008 — https://www.jta.org/2008/08/20/israel/drought-poses-tough-choices-for-israel — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-endgame's source helper; page fetched with curl (browser user-agent) on 2026-10-13 and the quote checked verbatim in the page text.
  - Quote: "The Israeli government approved their construction as far back as 2002"
  - Supports:
    - Israeli government approved construction of large seawater desalination plants in 2002

**[S5513]** The Hill, 'Israel, Jordan, UAE sign pivotal deal to swap solar energy for desalinated water', 22 November 2021 — https://thehill.com/policy/equilibrium-sustainability/582750-israel-jordan-uae-sign-pivotal-deal-to-swap-solar-energy/ — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-endgame's source helper; page fetched via the web.archive.org copy with curl (browser user-agent) on 2026-10-13 and the quote checked verbatim in the page text.
  - Quote: "Jordan would export about 600 megawatts of electricity generated from solar energy, while Israel would evaluate the export of up to 200 million cubic meters of desalinated water to Jordan"
  - Supports:
    - Project Prosperity water-for-energy declaration (Israel, Jordan, UAE, Nov 2021): ~600 MW solar from Jordan, up to 200 million m3 desalinated water from Israel

**[S5514]** Times of Israel, 'Leviathan group in push to boost gas output, updates reservoir value to $12.5b' — https://www.timesofisrael.com/leviathan-group-in-push-to-boost-gas-output-updates-reservoir-value-to-12-5b/ — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-endgame's source helper; page fetched via the web.archive.org copy with curl (browser user-agent) on 2026-10-13 and the quote checked verbatim in the page text.
  - Quote: "Natural gas from Leviathan started to flow to the Israeli domestic market in December 2019."
  - Supports:
    - Leviathan gas field began production in December 2019

**[S5515]** Al Jazeera, 'Israel begins exporting natural gas to Egypt', 15 January 2020 — https://www.aljazeera.com/economy/2020/1/15/israel-begins-exporting-natural-gas-to-egypt — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-endgame's source helper; page fetched with curl (browser user-agent) on 2026-10-13 and the quote checked verbatim in the page text.
  - Quote: "Egypt started importing natural gas from Israel ‘s largest offshore gas field Leviathan on Wednesday"
  - Supports:
    - Israeli natural gas exports to Egypt began in January 2020 (15 Jan 2020)

**[S5516]** Al Jazeera, 'Greece, Israel, Cyprus, move to build East Med gas pipeline', 2 January 2020 — https://www.aljazeera.com/news/2020/01/greece-israel-cyprus-move-build-east-med-gas-pipeline-200102181235607.html — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-endgame's source helper; page fetched with curl (browser user-agent) on 2026-10-13 and the quote checked verbatim in the page text.
  - Quote: "The governments of Greece , Israel and Cyprus have signed an agreement to build a pipeline that could supply Europe with 4 percent of its annual gas needs by the middle of the decade."
  - Supports:
    - EastMed gas pipeline agreement signed by Israel, Greece and Cyprus in Athens on 2 January 2020

**[S5517]** Globes, 'Israel launches sovereign wealth fund' — https://en.globes.co.il/en/article-israel-launches-sovereign-wealth-fund-1001413719 — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-endgame's source helper; page fetched with curl (browser user-agent) on 2026-10-13 and the quote checked verbatim in the page text.
  - Quote: "The law establishing the sovereign wealth fund was enacted in 2014."
  - Supports:
    - 2014 law creating the sovereign wealth fund (Israeli Citizens' Fund) for natural-gas revenues

**[S5518]** Congressional Research Service, 'Qualifying Industrial Zones in Jordan and Egypt' (RS22002), via EveryCRSReport.com — https://www.everycrsreport.com/reports/RS22002.html — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-endgame's source helper; page fetched with curl (browser user-agent) on 2026-10-13 and the quote checked verbatim in the page text.
  - Quote: "In 1996, Congress authorized the creation of Qualifying Industrial Zones (QIZs), thereby entitling goods jointly produced by Israel and either Jordan or Egypt to enter the United States duty free."
  - Supports:
    - US-Jordan-Israel QIZ authorised 1996
    - Egypt QIZ: first three designated by USTR in December 2004

**[S5519]** Times of Israel, 'Cabinet okays NIS 32 billion to develop Arab Israeli economy, fight crime', 24 October 2021 — https://www.timesofisrael.com/cabinet-okays-over-nis-32-billion-to-develop-arab-israeli-economy-fight-crime/ — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-endgame's source helper; page fetched via the web.archive.org copy with curl (browser user-agent) on 2026-10-13 and the quote checked verbatim in the page text.
  - Quote: "A similar push to end persistent gaps between Arab and Jewish Israelis in 2015, known as 922, allocated around NIS 10 billion — and only 62 percent was ultimately spent, according to official statistics."
  - Supports:
    - Government Resolution 922 (2015) Arab-sector five-year plan, about NIS 10 billion
    - Oct 2021 follow-up plans (Resolution 550) worth over NIS 32 billion

**[S5520]** National Insurance Institute of Israel (Bituach Leumi), 'What is the State Health Insurance Law?' — http://www.btl.gov.il/English%20Homepage/Insurance/Health%20Insurance/Pages/HealthInsuranceLaw.aspx — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-endgame's source helper; page fetched with curl (browser user-agent) on 2026-10-13 and the quote checked verbatim in the page text.
  - Quote: "Under the State Health Insurance Law, effective from January 1, 1995, every Israeli resident"
  - Supports:
    - National Health Insurance Law in force 1 January 1995, universal coverage

**[S5521]** Conference report on the National Health Insurance Law, PubMed Central (PMC7784017) — https://pmc.ncbi.nlm.nih.gov/articles/PMC7784017/ — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-endgame's source helper; page fetched with curl (browser user-agent) on 2026-10-13 and the quote checked verbatim in the page text.
  - Quote: "In June 1994, the Israeli parliament passed the National Health Insurance Law (NHIL), a turning point in the history of the Israeli healthcare system."
  - Supports:
    - National Health Insurance Law passed June 1994

**[S5522]** Jewish Telegraphic Agency, 'David's Sling missile defense system enters service in Israel', 2 April 2017 — https://www.jta.org/2017/04/02/israel/davids-sling-missile-defense-system-enters-service-in-israel — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-endgame's source helper; page fetched with curl (browser user-agent) on 2026-10-13 and the quote checked verbatim in the page text.
  - Quote: "The David’s Sling missile defense system, which is designed to stop medium-range rockets, drones and cruise missiles, became operational in Israel."
  - Supports:
    - David's Sling operational April 2017

**[S5523]** Jewish Telegraphic Agency, 'Iron Dome intercepts first missiles from Gaza', 7 April 2011 — https://www.jta.org/2011/04/07/israel/iron-dome-intercepts-first-missiles-from-gaza — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-endgame's source helper; page fetched with curl (browser user-agent) on 2026-10-13 and the quote checked verbatim in the page text.
  - Quote: "Israel’s Iron Dome missile defense system for the first time intercepted rockets fired from Gaza."
  - Supports:
    - Iron Dome first operational interception, 7 April 2011

**[S5524]** Jerusalem Post, 'Defense Ministry rolls out Iron Beam laser air defense system across Israel', 28 December 2025 — https://www.jpost.com/defense-and-tech/article-881595 — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-endgame's source helper; page fetched with curl (browser user-agent) on 2026-10-13 and the quote checked verbatim in the page text.
  - Quote: "In mid-September, the Defense Ministry announced that Iron Beam was operational"
  - Supports:
    - Iron Beam laser air defence declared operational Sept 2025 and deployed Dec 2025

**[S5525]** RETIRED (no longer cited; cited only by content dated after Q3 2023, deleted 2026-10-14 (the game ends 7 Oct 2023)) — Jewish Telegraphic Agency, 'US to send troops to Israel as Hezbollah ramps up its attack', 13 October 2024 — https://www.jta.org/2024/10/13/israel/us-to-send-troops-to-israel-as-hezbollah-ramps-up-its-attack

**[S5530]** U.S. Dept of State, Foreign Relations of the United States 1961-63 vol. XVIII, Doc. 23, Message from Bundy to President Kennedy, 19 Aug 1962 — https://history.state.gov/historicaldocuments/frus1961-63v18/d23 — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "he should not go beyond indicating that the path to a sale of Hawks is now open in principle, subject to the possibility of arms control arrangements in the area"
  - Supports:
    - Aug 1962: US told envoy Feldman the path to a Hawk sale to Israel was open in principle

**[S5531]** U.S. Dept of State, FRUS 1961-63 vol. XVII, Doc. 290, Memorandum from Talbot to Rusk, 7 Jun 1962 — https://history.state.gov/historicaldocuments/frus1961-63v17/d290 — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "We prefer that decision on the sale of the Hawk to Israel be deferred for about two years"
  - Supports:
    - By June 1962 Israel had bought Mirage III aircraft, some already delivered
    - State Dept NEA (Talbot) preferred to defer the Hawk decision about two years (June 1962)

**[S5532]** Jewish Telegraphic Agency, 'Israeli Knesseth Votes Acceptance of $100,000,000 American Loan After Plea by Kaplan', 18 Mar 1949 — https://www.jta.org/archive/israeli-knesseth-votes-acceptance-of-100000000-american-loan-after-plea-by-kaplan — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "The Israeli Knesseth today voted to accept the terms of the $100,000,000 American loan. The vote was 85 to three, with 19 abstentions."
  - Supports:
    - Knesset accepted the $100m US loan 85-3, 19 abstentions (18 Mar 1949)
    - Mapam demanded loans from countries other than the US, free of political/economic conditions

**[S5533]** Jewish Virtual Library, 'History & Overview of U.S. Foreign Aid to Israel' — https://www.jewishvirtuallibrary.org/history-and-overview-of-u-s-foreign-aid-to-israel — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "President Truman responded by approving a $135 million Export-Import Bank loan and the sale of surplus commodities to Israel."
  - Supports:
    - 1951 Congress voted aid for refugee absorption
    - Israel began buying US arms in 1962
    - Truman approved Export-Import Bank loan (JVL gives $135 million total) and surplus commodity sales
    - US economic grants ended 1959; later aid mostly loans and surplus commodities

**[S5534]** Jewish Telegraphic Agency, 'Israel Extends Recognition to Chinese Communist Government and Indonesian Republic', 10 Jan 1950 — https://www.jta.org/archive/israel-extends-recognition-to-chinese-communist-government-and-indonesian-republic — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "Full recognition of the Chinese Communist Government at Peiping, as well as the new Indonesian Republic, was extended today by Israel, a spokesman of the Foreign Ministry announced."
  - Supports:
    - Israel extended full recognition to the Peiping government (JTA dateline 10 Jan 1950)

**[S5535]** Jewish Telegraphic Agency, 'Moscow and Israel Announce Resumption of Diplomatic Relations', 21 Jul 1953 — https://www.jta.org/archive/moscow-and-israel-announce-resumption-of-diplomatic-relations — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "Relations were broken off by Moscow last February after the explosion of a bomb in the garden of the Soviet Legation in Tel Aviv."
  - Supports:
    - Molotov cited Israel assurances to apprehend and punish bombers and its apology
    - Relations broken off by Moscow Feb 1953 after the legation bomb
    - Resumption announced simultaneously in Israel and Moscow, 21 Jul 1953

**[S5536]** U.S. Dept of State, FRUS 1955-57 vol. XV, Doc. 245, Telegram from the Embassy in Israel (Sharett meeting), 5 Apr 1956 — https://history.state.gov/historicaldocuments/frus1955-57v15/d245 — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "It was a French gift, not one for which US could claim major credit."
  - Supports:
    - Sharett (Foreign Ministry) said the Mystere deal was a French gift, not a US achievement (Apr 1956)
    - Sharett complained of 5 months of Washington indecision: Israel no longer to suffer the indignity of begging

**[S5537]** U.S. Dept of State, FRUS 1955-57 vol. XIV, Doc. 425, Telegram from the Embassy in Israel, 23 Nov 1955 — https://history.state.gov/historicaldocuments/frus1955-57v14/d425 — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "Dayan, on recent trip Paris, obtained support French Minister of Defense"
  - Supports:
    - Dayan won the French Defence Minister's support for Mystere IV deliveries against Quai d'Orsay opposition (Nov 1955)

**[S5538]** U.S. Dept of State, FRUS 1958-60 vol. XIII, Doc. 131, Memorandum of conversation Eisenhower-Ben-Gurion, 10 Mar 1960 — https://history.state.gov/historicaldocuments/frus1958-60v13/d131 — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "As far as Iran is concerned, the Prime Minister said that Israel had good relations with Iran"
  - Supports:
    - Ben-Gurion told Eisenhower Israel had good relations with Iran (Mar 1960)
    - Israeli experts sent to Iran at the Shah's request

**[S5539]** Jewish Telegraphic Agency, 'Knesset Rejects Motion Against Ben-Gurion for Meeting Adenauer', 17 Mar 1960 — https://www.jta.org/archive/knesset-rejects-motion-against-ben-gurion-for-meeting-adenauer — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "because of his meeting in New York this week with Chancellor Konrad Adenauer of West Germany"
  - Supports:
    - Achdut Avodah and Mapam opposed the Adenauer meeting from the start
    - Ben-Gurion met Adenauer in New York in March 1960
    - Herut and the Communists attacked Ben-Gurion for meeting Adenauer

**[S5540]** Jewish Telegraphic Agency, 'Trade Fact Between Euromart Lands and Israel Signed in Brussels', 5 Jun 1964 — https://www.jta.org/archive/trade-fact-between-euromart-lands-and-israel-signed-in-brussels — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "The signing of the trade agreement between Israel and the European Economic Community, which provides tariff concessions for a number of Israel’s exports to the six-nation European Common Market, took place today"
  - Supports:
    - Israel-EEC trade agreement signed in Brussels (JTA 5 Jun 1964), tariff concessions

**[S5541]** Jewish Telegraphic Agency, 'Establishment of Israel-German Diplomatic Relations Announced', 14 May 1965 — https://www.jta.org/archive/establishment-of-israel-german-diplomatic-relations-announced — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "The establishment of diplomatic relations between Israel and West Germany was announced simultaneously in Jerusalem and Bonn today."
  - Supports:
    - Chancellor abruptly suspended weapons shipments under Arab boycott threats
    - Israel-West Germany diplomatic relations announced 14 May 1965 (letters exchanged 13 May)

**[S5542]** Jewish Telegraphic Agency, 'Britain Sold Arms to Israel in 59 to Mend Ties After Suez Campaign', 4 Jan 1990 (reporting released UK Foreign Office papers) — https://www.jta.org/archive/britain-sold-arms-to-israel-in-59-to-mend-ties-after-suez-campaign — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "The British sought to patch up relations with Israel by arms sales in 1959."
  - Supports:
    - British Foreign Office: sale of two submarines was a public sign of reconciliation
    - Tanks offered to Meir Sep 1958; contract for 60 tanks with option for 30
    - UK sold arms to Israel in 1959 to mend ties after Suez; kept quiet

**[S5543]** Jewish Telegraphic Agency, 'Behind the Headlines: This Week's Rabin-Hussein Summit Will Cap Decades of Secret Talks', 1994 — https://www.jta.org/archive/behind-the-headlines-this-weeks-rabin-hussein-summit-will-cap-decades-of-secret-talks — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "In September 1963, the king met with Prime Minister David Ben-Gurion’s personal representative, Ya’akov Herzog, in London."
  - Supports:
    - Sept 1963 King Hussein met Ben-Gurion's representative Herzog in London

**[S5544]** Jewish Telegraphic Agency, 'State Department Fears Israel May Resume Development Project', 17 Oct 1955 — https://www.jta.org/archive/state-department-fears-israel-may-resume-development-project — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "Israel ceased work at Bnot Yaacov when Syria brought about United Nations intercession highlighted by a temporary American suspension of economic aid as a punitive measure against Israel."
  - Supports:
    - Israel ceased work at Bnot Yaacov amid temporary US suspension of economic aid

**[S5545]** Jewish Telegraphic Agency, 'India Announces It Will Establish Full Diplomatic Ties with Israel', 30 Jan 1992 — https://www.jta.org/archive/india-announces-it-will-establish-full-diplomatic-ties-with-israel — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "India has agreed to upgrade diplomatic relations with Israel to the ambassadorial level."
  - Supports:
    - India upgraded to ambassadorial relations with Israel, announced Jan 1992
    - Israel kept a consulate in Bombay with no reciprocal Indian mission

**[S5546]** U.S. Dept of State, FRUS 1948 vol. V part 2, Doc. 707 (Marshall-Bevin conversation, Oct 1948) — https://history.state.gov/historicaldocuments/frus1948v05p2/d707 — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "we were fully aware of the fact that Israel was obtaining arms from Czechoslovakia"
  - Supports:
    - Bevin: Jews violated the truce arms provision with impunity, receiving planes from Czechoslovakia
    - Oct 1948 US Secretary of State Marshall: aware Israel was obtaining arms from Czechoslovakia

**[S5547]** US Dept of State, Office of the Historian, FRUS 1964-68 vol. XX, Arab-Israeli Dispute 1967-68, docs 288, 295, 311, 317 (Oct-Nov 1968 F-4 / NPT talks); each cite gives its document URL — https://history.state.gov/historicaldocuments/frus1964-68v20/d311 — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13. Grouped id: several pages from the same collection share this id; each cite carries its own page URL.
  - Quote: "The President apparently said that he had promised the F-4s without any conditions, and that was his position."
  - Supports:
    - Rusk asked Israel to join NPT (22 Oct 1968)
    - Warnke: Phantoms contingent on assurances
    - Johnson promised F-4s without conditions
    - final compromise reaffirmations, no NPT

**[S5548]** Jewish Telegraphic Agency archive, 1967-1969 arms-supply articles (Mirage embargo, Skyhawks, Phantoms, Chieftain, Cherbourg boats); each cite gives its article URL — https://www.jta.org/archive/israel-says-it-will-not-accept-refund-for-50-mirage-jets-france-has-embargoed — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13. Grouped id: several pages from the same collection share this id; each cite carries its own page URL.
  - Quote: "Israel is firmly opposed to accepting any refund from France for the 50 Mirage V jet fighter bombers that were embargoed by the De Gaulle regime although Israel has paid for them in full."
  - Supports:
    - Mirage V paid/embargoed
    - 1966 Skyhawk contract
    - Johnson 10 Oct 1968 instruction
    - French total embargo
    - Cherbourg boats
    - Chieftain withdrawal

**[S5549]** Jewish Telegraphic Agency archive, 1969-1974 Soviet Jewry articles (Knesset 20 Nov 1969, Tekoah at UN 12 Nov 1969, Rush 21 Feb 1974); each cite gives its article URL — https://www.jta.org/archive/knesset-calls-upon-worlds-parliaments-to-help-obtain-freedom-for-soviet-jews — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13. Grouped id: several pages from the same collection share this id; each cite carries its own page URL.
  - Quote: "She described a letter received from the heads of 18 Jewish families in the Soviet Georgian Republic appealing for aid to emigrate to Israel"
  - Supports:
    - Georgian families letter / Knesset
    - Israel first formal UN approach
    - quiet diplomacy

**[S5550]** Jewish Telegraphic Agency archive, 1974-1975 articles (EEC agreement 12 May 1975, EEC talks 3 Oct 1974, Ford reassessment 25 Mar and 7 May 1975); each cite gives its article URL — https://www.jta.org/archive/israel-eec-sign-trade-accord — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13. Grouped id: several pages from the same collection share this id; each cite carries its own page URL.
  - Quote: "The agreement provides for the complete abolition of all customs duties and other forms of taxation on Israeli exports, industrial and agricultural, to the Community."
  - Supports:
    - EEC FTA terms
    - Israeli concerns
    - Ford reassessment

**[S5551]** Jewish Telegraphic Agency archive, Iran-Israel articles (Eilat-Ashkelon pipeline 14 Dec 1970; Iran upheaval 18 Jan 1979); each cite gives its article URL — https://www.jta.org/archive/report-iranian-oil-to-east-europe-pumped-through-israels-eilat-ashkelon-pipeline — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13. Grouped id: several pages from the same collection share this id; each cite carries its own page URL.
  - Quote: "The Eilat-Ashkelon pipeline bypasses the closed Suez Canal, saving a three-week, 12,000 mile voyage from Mideastern oil fields to Europe via the Cape of Good Hope."
  - Supports:
    - pipeline carried Iranian oil
    - oil cut after revolution

**[S5552]** Shyam Bhatia, New Indian Express, 'Secret missile project that once united Israel, Iran', 14 Mar 2026 (secondary; quotes RAND) — https://www.newindianexpress.com/opinion/columns/2026/Mar/14/secret-missile-project-that-once-united-israel-iran — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "The test was part of a secret joint programme known as Project Flower, an ambitious effort to develop advanced missile systems."
  - Supports:
    - Project Flower 1977
    - Iran funding
    - ended by revolution

**[S5553]** Jewish Telegraphic Agency archive, 1977 articles (Dayan-Tahami report 16 Dec 1977; US-Soviet statement text 3 Oct 1977; US-Israel joint statement 6 Oct 1977); each cite gives its article URL — https://www.jta.org/archive/knesset-committee-members-say-they-are-being-kept-in-the-dark-about-diplomatic-events-in-mideast — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13. Grouped id: several pages from the same collection share this id; each cite carries its own page URL.
  - Quote: "According to Shiff, the talks were arranged with the blessings of Morocco"
  - Supports:
    - Dayan-Tuhami Morocco report
    - US-USSR joint statement
    - Geneva

**[S5554]** Jewish Telegraphic Agency archive, Venice Declaration reaction (16 Jun 1980) and Peres European tour (26 Jan 1981); each cite gives its article URL — https://www.jta.org/archive/israel-rejects-eec-declaration-begin-calls-it-2nd-munich — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13. Grouped id: several pages from the same collection share this id; each cite carries its own page URL.
  - Quote: "The Cabinet today angrily rejected the declaration on the Middle East by the Prime Ministers of the nine European Economic Community (EEC) nations at the close of their two-day summit meeting in Venice Friday."
  - Supports:
    - Cabinet rejection / Begin Munich
    - Peres engagement with Europe

**[S5555]** Jewish Telegraphic Agency archive, US-Israel memorandum of understanding (4 Dec 1981; 21 Dec 1981 suspension); each cite gives its article URL — https://www.jta.org/archive/israel-denounces-the-u-s-for-suspending-its-cooperation-accord — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13. Grouped id: several pages from the same collection share this id; each cite carries its own page URL.
  - Quote: "On Friday, the State Department announced suspension of the memorandum of understanding signed November 30 by Defense Secretary Caspar Weinberger and Sharon."
  - Supports:
    - MOU signed 30 Nov 1981
    - suspended after Golan law

**[S5556]** Jewish Telegraphic Agency archive, 'Britain Lifting Ban on Arms Sales to Israel', 31 May 1994 — https://www.jta.org/archive/britain-lifting-ban-on-arms-sales-to-israel — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "The United Kingdom has lifted a 12-year-old ban on arms sales to Israel."
  - Supports:
    - UK embargo imposed June 1982, lifted 1994

**[S5558]** Congressional Research Service, 'U.S. Foreign Aid to Israel' RL33222 (EveryCRSReport copy, updated 28 May 2025) — https://www.everycrsreport.com/reports/RL33222.html — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "Congress appropriated $2.2 billion for Israel in P.L. 93-199 , the Emergency Security Assistance Act of 1973."
  - Supports:
    - $2.2bn 1973
    - grant aid
    - ESF

**[S5561]** Jewish Telegraphic Agency archive, 'Israel regrets Turkey's move at downgrading diplomatic ties', 4 Dec 1980 — https://www.jta.org/archive/israel-regrets-turkeys-move-at-downgrading-diplomatic-ties — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "The Foreign Ministry confirmed reports from Ankara that the military government there decided to lower the rank of its senior representative in Tel Aviv from Minister to Second Secretary and has asked Israel to do likewise."
  - Supports:
    - Turkey lowers rank

**[S5563]** Jewish Telegraphic Agency archive, 'Dr. Mordecai Eliash, Israel Envoy to Britain, Dies; Burial to Take Place in Jerusalem' (obituary, 1950) — https://www.jta.org/archive/dr-mordecai-eliash-israel-envoy-to-britain-dies-burial-to-take-place-in-jerusalem — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy; page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "When Britain gave Israel de facto recognition, Dr. Eliash returned to London as the first Israeli diplomatic representative there, April 5, 1949."
  - Supports:
    - After Britain's de facto recognition, Israel's first diplomatic representative arrived in London on 5 April 1949

**[S5564]** CRS, 'Israel: U.S. Foreign Assistance' (RL33222), 25 Apr 2007 (EveryCRSReport archive copy) — https://www.everycrsreport.com/files/20070425_RL33222_ee97f8a100b2abd96b43a0f4d0cc6848e74efb26.html — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "Since 1988, Israel and the United States have been developing the Arrow Anti-Missile System, a weapon with a theater ballistic missile defense capability."
  - Supports:
    - US-Israel joint development of the Arrow anti-missile system since 1988
    - Netanyahu told Congress 10 Jul 1996 Israel would begin reducing US economic aid
    - 1998 Israeli proposal: eliminate $1.2bn economic aid, raise military aid over 10 years
    - Rep. Callahan sought to withhold $250m in aid
    - US suspended Israel from JSF over Harpy upgrade, 2005

**[S5565]** JTA (Michael J. Jordan), 'Lobbyists relieved after Israel cancels China sale', 13 Jul 2000 — https://www.jta.org/2000/07/13/lifestyle/lobbyists-relieved-after-israel-cancels-china-sale — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "Israel has canceled a $250 million sale of military technology to China, a move that is seen as an effort to soothe U.S. criticism during Middle East peace talks at Camp David."
  - Supports:
    - Israel cancelled the $250m Phalcon sale to China (12 Jul 2000), seen as soothing US criticism
    - Pressure from Israeli defence contractors to proceed

**[S5566]** JTA (Sharon Samber), 'Congress urged not to link Israel aid to China arms', 13 Jun 2000 — https://www.jta.org/2000/06/13/lifestyle/congress-urged-not-to-link-israel-aid-to-china-arms — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "Israeli officials have repeatedly said they wish to honor their Phalcon contract with China, though they acknowledge the U.S. concerns."
  - Supports:
    - Proceed with the sale: Israeli officials said they wished to honour the contract
    - Callahan would block the cost of the sale from military aid

**[S5568]** JTA (Dan Baron), 'Sharon goes to the subcontinent', 4 Sep 2003 — https://www.jta.org/2003/09/04/lifestyle/sharon-goes-to-the-subcontinent — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "approved the Phalcon sale in May after ascertaining that India and Pakistan had backed down from the nuclear standoff they reached last summer."
  - Supports:
    - US approved the Phalcon sale to India in May 2003
    - India Phalcon deal valued $1.2-1.3bn
    - India-Israel full diplomatic relations only in 1992

**[S5569]** JTA, 'State-of-the-art submarines added to Israel's naval arsenal', 28 Jul 1999 — https://www.jta.org/1999/07/28/default/state-of-the-art-submarines-added-to-israels-naval-arsenal — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "built at a cost of some $300 million apiece by Germany, which offered them to Israel in return for Israel complying with an international request not to respond to Iraqi Scud attacks on the Jewish state during the 1991 Gulf War."
  - Supports:
    - Dolphin subs built by Germany, offered after 1991 Gulf War restraint; first arrived Jul 1999

**[S5570]** New York Jewish Week/JTA (James Besser), 'At Last, Israel In At UN', 2 Jun 2000 — https://www.jta.org/2000/06/02/ny/at-last-israel-in-at-un — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "Israel was officially invited to join the group in a letter from Dutch Ambassador Peter van Walsum, who currently chairs the panel."
  - Supports:
    - Israel invited to join WEOG, May 2000
    - WEOG participation initially limited to UN headquarters in New York

**[S5571]** JTA (Marcy Oster), 'Egypt cancels gas agreement with Israel', 22 Apr 2012 — https://www.jta.org/2012/04/22/israel/egypt-cancels-gas-agreement-with-israel — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "Egypt canceled its natural gas agreement with Israel, reportedly abrogating the original Egypt-Israel peace treaty of 1979."
  - Supports:
    - Egypt cancelled April 2012
    - JTA: 20 years, 7 bcm, option to double

**[S5572]** Jewish Virtual Library, 'Israel and Egypt Sign Natural Gas Deal (July 1, 2005)' — https://www.jewishvirtuallibrary.org/israel-and-egypt-sign-natural-gas-deal — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "On July 1, 2005, Israel and Egypt signed a $2.5 billion gas deal in Cairo, after years of postponement due to tense relations."
  - Supports:
    - Gas deal signed 1 Jul 2005, $2.5bn
    - 15 years, 25 bcm, extendable five years

**[S5573]** Jewish Virtual Library, 'Morocco Virtual Jewish History Tour' — https://www.jewishvirtuallibrary.org/morocco-virtual-jewish-history-tour — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "the Israeli-Palestinian Oslo Accord of 1993 that led to the establishment of liaison offices in Rabat and Tel Aviv"
  - Supports:
    - Morocco-Israel liaison offices in Rabat and Tel Aviv after Oslo
    - Morocco closed its Tel Aviv liaison office in 2000

**[S5574]** Jewish Virtual Library, 'Israel-China Relations' — https://www.jewishvirtuallibrary.org/israel-china-relations — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "Israel and China first established diplomatic relations in January 1992."
  - Supports:
    - China-Israel diplomatic relations established January 1992
    - Pre-1992 Israeli liaison office in Beijing (opened June 1990)

**[S5575]** Jewish Virtual Library, 'Russia Virtual Jewish History Tour' — https://www.jewishvirtuallibrary.org/russia-virtual-jewish-history-tour — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "In 1967, the Soviet Union cut diplomatic ties with Israel and were only re-established on October 18, 1991."
  - Supports:
    - Soviet-Israeli ties severed 1967, re-established 18 Oct 1991

**[S5576]** JTA (Gil Troy), 'Bush Fought For Israel At The UN', 4 Dec 2018 — https://www.jta.org/2018/12/04/ny/bush-fought-for-israel-at-the-un — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "Israel demanded reversing Resolution 3379 as a condition for granting the UN observer status at the conference"
  - Supports:
    - Israel demanded repeal of 3379 as a condition for UN role at Madrid
    - GA voted to repeal on 16 Dec 1991 (111 in favour)
    - Repeal earlier, in 1990: John Bolton wanted to mark the 15th anniversary with repeal
    - Sen. Moynihan urged the administration to be aggressive on repeal

**[S5577]** JTA, 'Behind the Headlines: Israeli-Turkish relations solid despite political crisis in Ankara', 25 Jun 1997 — https://www.jta.org/1997/06/25/lifestyle/behind-the-headlines-israeli-turkish-relations-solid-despite-political-crisis-in-ankara-2 — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "which was signed in February 1996, the first such agreement the Jewish state ever reached with an Islamic country."
  - Supports:
    - Turkey-Israel military agreement signed Feb 1996
    - Second pact (Aug 1996) lets Israel modify Turkish Phantom jets
    - Named critic: Erbakan opposed the military pact

**[S5578]** JTA, 'Behind the Headlines: Turkey's Islamist premier shifts attitude toward ties with Israel', 5 Jun 1997 (dateline 15 Apr 1997) — https://www.jta.org/1997/06/05/lifestyle/behind-the-headlines-turkeys-islamist-premier-shifts-attitude-toward-ties-with-israel — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "In an effort to boost trade with Israel, the Turkish Parliament ratified a free-trade agreement with the Jewish state only days before Levy met with Erbakan."
  - Supports:
    - Turkish parliament ratified FTA with Israel in April 1997
    - Erbakan, a strong critic of Israel, refused to respond to Netanyahu's messages

**[S5579]** EEAS, 'The European Union and Israel' — https://www.eeas.europa.eu/israel/european-union-and-israel_en — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "The legal basis for relations is the EU-Israel Association Agreement that entered force in 2000."
  - Supports:
    - EU-Israel Association Agreement in force 2000
    - Israel associated to EU research Framework Programmes since 1996

**[S5580]** CRS, 'Egypt: Background and U.S. Relations' (RL33003), EveryCRSReport — https://www.everycrsreport.com/reports/RL33003.html — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "Since 2004, Egypt has participated in the Qualified Industrial Zone (QIZ) program"
  - Supports:
    - Egypt in US QIZ program since 2004

**[S5581]** Jewish Telegraphic Agency, 'Syria, Israel relaunching peace bid', 21 May 2008 — https://www.jta.org/2008/05/21/politics/syria-israel-relaunching-peace-bid — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "representatives of the two governments have been meeting this week in Ankara to discuss restarting peace talks under Turkish auspices"
  - Supports:
    - Israel-Syria indirect talks under Turkish auspices announced 21 May 2008
    - Shas leader Eli Yishai and the right wing objected

**[S5582]** Jewish Telegraphic Agency, 'Netanyahu rejecting apology to Turkey for now', 24 Feb 2013 — https://www.jta.org/2013/02/24/israel/netanyahu-rejecting-apology-to-turkey-for-now — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "Defense Minister Ehud Barak, who has advocated for such an apology since the May 2010 incident"
  - Supports:
    - Barak advocated an apology; FM Liberman opposed it

**[S5583]** Al Jazeera, 'Israel PM apologises for flotilla deaths', 22 Mar 2013 — https://www.aljazeera.com/news/2013/3/22/israel-pm-apologises-for-flotilla-deaths — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "two men agreed to restore normalisation between Israel and Turkey, including the dispatch of ambassadors and the cancellation of legal steps against IDF soldiers"
  - Supports:
    - Netanyahu apologised to Erdogan by phone on 22 March 2013, Obama-brokered

**[S5584]** Jewish Telegraphic Agency, 'Israel will not sign EU agreements with settlement guidelines', 8 Aug 2013 — https://www.jta.org/2013/08/08/israel/israel-will-not-sign-eu-agreements-with-settlement-guidelines — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "The European Commission last month announced new guidelines making Israeli entities and activities in the West Bank, eastern Jerusalem and the Golan Heights ineligible for EU grants and prizes."
  - Supports:
    - July 2013 EU guidelines; Netanyahu-convened meeting decided to condition signing Horizon 2020 on rewording

**[S5585]** Jewish Telegraphic Agency, 'Israel joins EU's Horizons 2020 research project', 9 Jun 2014 — https://www.jta.org/2014/06/09/israel/israel-joins-eus-horizons-2020-research-project — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "Israel signed an agreement with the European Union to join the Horizon 2020 research and development project despite a dispute over EU guidelines on Jewish settlements."
  - Supports:
    - Israel signed Horizon 2020 despite guidelines, adding a clause

**[S5586]** Al Jazeera (with Reuters), 'Russia to coordinate Syria military actions with Israel', 22 Sep 2015 — https://www.aljazeera.com/news/2015/9/22/russia-to-coordinate-syria-military-actions-with-israel — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "Israel and Russia have agreed to coordinate military actions over Syria in order to avoid accidentally trading fire"
  - Supports:
    - Netanyahu and Putin agreed on a mechanism to avoid clashes over Syria (Moscow, 21 Sep 2015)

**[S5587]** Jewish Telegraphic Agency, 'Israel protests EU labeling policy by quitting some talks', 12 Nov 2015 — https://www.jta.org/2015/11/12/israel/israel-protests-eu-labeling-policy-by-quitting-some-talks — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "Israel’s Foreign Ministry suspended dialogue with the European Union to protest the EU’s decision to label products from West Bank settlements separately"
  - Supports:
    - EU settlement-product labelling; Israeli Foreign Ministry suspended some EU dialogues

**[S5588]** Congressional Research Service (via EveryCRSReport), 'U.S. Foreign Aid to Israel' (RL33222), MOU section — https://www.everycrsreport.com/reports/RL33222.html — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "On September 14, 2016, U.S. and Israeli government representatives signed another 10-year MOU on military aid covering FY2019 to FY2028."
  - Supports:
    - 14 Sep 2016 MOU: $38bn FY2019-2028 incl. $5bn missile defence; off-shore procurement phased out
    - US support for Iron Dome from FY2011; $500m annual missile-defence pledge

**[S5589]** Jewish Telegraphic Agency, 'Israel says it's ready to sign 10-year security assistance deal soon with US', 25 Jul 2016 — https://www.jta.org/2016/07/25/israel/israel-says-ready-to-sign-10-year-security-assistance-deal-soon-with-us — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "Netanyahu had walked back earlier comments saying he was willing to wait until a change in U.S. administration to take place in January."
  - Supports:
    - Netanyahu had earlier said he could wait for the next US administration

**[S5590]** Al Jazeera, 'Netanyahu rejects shameful UN vote on settlements', 24 Dec 2016 — https://www.aljazeera.com/news/2016/12/24/netanyahu-rejects-shameful-un-vote-on-settlements — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "The resolution was adopted with 14 votes in favour"
  - Supports:
    - UNSC 2334 adopted 14 votes, US abstained
    - Israel recalled ambassadors to NZ and Senegal; Israel and Trump pressed Egypt to withdraw

**[S5591]** Al Jazeera, 'Russia to send S-300 missile defence systems to Syria', 24 Sep 2018 — https://www.aljazeera.com/news/2018/9/24/russia-to-send-s-300-missile-defence-systems-to-syria — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "Moscow will bolster Syria’s air defence following the downing of a Russian plane last week by sending a modern S-300 system to the Syrian army within two weeks"
  - Supports:
    - Il-20 downed; Russia blamed Israel; S-300 to Syria

**[S5592]** Jewish Telegraphic Agency (Ron Kampeas), 'Breaking China: A rupture looms between Israel and the United States', 2 Jun 2020 — https://www.jta.org/2020/06/02/politics/breaking-china-a-rupture-looms-between-israel-and-the-united-states — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "A Chinese company, SIPG, is building a major port in Haifa and will control it for 25 years."
  - Supports:
    - SIPG Haifa port; US pressure; Israeli investment-review committee was a 2019 Cabinet decision

**[S5593]** Al Jazeera, 'Hundreds protest in Amman against water-energy deal with Israel', 26 Nov 2021 — https://www.aljazeera.com/news/2021/11/26/hundreds-protest-in-amman-against-water-energy-deal-with-israel — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "Jordan would receive 200 million cubic metres (7.06 billion cubic feet) of desalinated water from Israel, in return for 600 megawatts of electricity generated from a UAE-funded solar energy plant in Jordan."
  - Supports:
    - Jordan-UAE-Israel declaration of intent signed Monday 22 Nov 2021 in Dubai; 200 million m3 water for 600 MW solar

**[S5594]** Al Jazeera, 'Israel signs major trade deal with UAE', 31 May 2022 — https://www.aljazeera.com/economy/2022/5/31/israel-signs-major-trade-deal-with-uae — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "The pact was signed in Dubai by Israel’s Minister of Economy and Industry Orna Barbivai and her counterpart, UAE Minister of Economy Abdulla bin Touq al-Marri"
  - Supports:
    - Israel-UAE CEPA signed 31 May 2022

**[S5595]** Al Jazeera, 'Turkey, Israel to restore full diplomatic relations', 17 Aug 2022 — https://www.aljazeera.com/news/2022/8/17/turkey-israel-to-restore-full-diplomatic-relations — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "Turkey and Israel have agreed to restore full diplomatic relations and will return ambassadors to each other’s countries"
  - Supports:
    - Israel and Turkey restore ambassadors, 17 Aug 2022

**[S5596]** Al Jazeera, 'Israel begins exporting natural gas to Egypt', 15 Jan 2020 — https://www.aljazeera.com/economy/2020/1/15/israel-begins-exporting-natural-gas-to-egypt — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "Egypt started importing natural gas from Israel"
  - Supports:
    - Leviathan gas flows to Egypt from 15 Jan 2020; 85 bcm over 15 years

**[S5597]** Jewish Telegraphic Agency (Cnaan Liphshiz), 'Israeli PM Bennett meets with Putin in Moscow to discuss Ukraine, then phones Zelensky', 5 Mar 2022 — https://www.jta.org/2022/03/05/global/israeli-pm-bennett-meets-with-putin-in-moscow-to-discuss-ukraine-then-phones-zelensky — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "starting with an unexpected meeting in Moscow with Russian President Vladimir Putin"
  - Supports:
    - Bennett in Moscow 5 Mar 2022; no weapons; UNGA vote

**[S5598]** Al Jazeera, 'Blinken and Arab foreign ministers meet at Negev summit', 28 Mar 2022 — https://www.aljazeera.com/news/2022/3/28/blinken-and-arab-foreign-ministers-meet-at-negev-summit — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "Israel hosted the foreign ministers of four Arab nations and the United States"
  - Supports:
    - Negev Summit, southern Negev near Ben-Gurion's tomb, March 2022

**[S5599]** Al Jazeera, 'Morocco, Israel sign first-ever defence agreement in Rabat', 24 Nov 2021 — https://www.aljazeera.com/news/2021/11/24/morocco-israel-sign-first-ever-defence-agreement-in-rabat — accessed: 2026-10-13 — provenance: opened
  - Note: Added by sim-diplomacy (research agent); page opened with curl and a browser user-agent and the quote checked verbatim on 2026-10-13.
  - Quote: "The memorandum of understanding between Israeli Defense Minister Benny Gantz and his Moroccan counterpart Abdellatif Loudiyi was signed on Wednesday in Rabat"
  - Supports:
    - Gantz-Loudiyi defence MoU signed in Rabat 24 Nov 2021

**[S5600]** Jewish Telegraphic Agency, 'Irgunists in Jerusalem Surrender Their Arms to Govt; Dissidents to Join Army Today', Daily Bulletin, 22 September 1948 — https://www.jta.org/archive/irgunists-in-jerusalem-surrender-their-arms-to-govt-dissidents-to-join-army-today — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "a 24-hour ultimatum to the Irgun Zvai Loumi to disband as an organization and order its members to join the army"
  - Supports:
    - On 21-22 September 1948 the Israeli government gave the Irgun in Jerusalem a 24-hour ultimatum to disband and enlist; the Irgunists handed over their arms and joined the army

**[S5601]** Jewish Telegraphic Agency, 'Trial of Stern Group Chiefs Continues; Defendants Plead Not Guilty to Charges', Daily Bulletin, 7 December 1948 — https://www.jta.org/archive/trial-of-stern-group-chiefs-continues-defendants-plead-not-guilty-to-charges — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "were negotiating with the Israeli Government at the same time"
  - Supports:
    - In December 1948 the Stern Group chiefs Nathan Friedmann-Yellin and M. Shmulevitz were tried in Acre for directing a terrorist organisation; the prosecution said the Sternists had negotiated with the government while continuing their activities in Jerusalem

**[S5602]** Jewish Telegraphic Agency, 'Israel Parliament to Vote Today on New Cabinet; Sharett Returns to Lake Success', Daily Bulletin, 1 November 1950 — https://www.jta.org/archive/israel-parliament-to-vote-today-on-new-cabinet-sharett-returns-to-lake-success — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "The new 13-man Cabinet is composed of seven members of the Mapai, three members of the Religious Bloc"
  - Supports:
    - On 31 October-1 November 1950 Ben-Gurion presented a new 13-man coalition with three Religious Bloc ministers to the Knesset

**[S5603]** Jewish Telegraphic Agency, 'Talks on Formation of New Israel Cabinet Continue; Results Expected Tonight', Daily Bulletin, 24 October 1950 — https://www.jta.org/archive/talks-on-formation-of-new-israel-cabinet-continue-results-expected-tonight — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "therefore we have decided to insist upon a general election"
  - Supports:
    - In October 1950 the Religious Bloc demanded Sabbath-law enforcement and a ban on importing non-kosher food as the price of a coalition; Mapai leaders said they would insist on a general election

**[S5604]** Jewish Telegraphic Agency, 'Histadrut Acts to Settle Mapai-mapam Conflict in Ein Harod Colony', Daily Bulletin, 7 May 1953 — https://www.jta.org/archive/histadrut-acts-to-settle-mapai-mapam-conflict-in-ein-harod-colony — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "The Histadrut executive last night decided to finalize the partition of Ein Harod"
  - Supports:
    - In May 1953 the Histadrut executive finalised the partition of Ein Harod between its Mapai members (55 percent) and Mapam members

**[S5605]** Jewish Telegraphic Agency, 'Kibbutz Movement in Israel Splits; Mapai Delegates Walk out of Mapam-Dominated Parley', Daily Bulletin, 23 May 1951 — https://www.jta.org/archive/kibbutz-movement-in-israel-splits-mapai-delegates-walk-out-of-mapam-dominated-parley — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "unsuccessfully offered a resolution recognizing the existence of two political ideologies within the kibbutz movement"
  - Supports:
    - On 22 May 1951 the United Kibbutz Council met at Naan and the kibbutz movement split into Mapai and Mapam factions; Mapai delegates had offered a resolution recognising two ideologies in one movement

**[S5606]** Jewish Telegraphic Agency, 'Israel Parliament Urges Striking Seamen to Return to Work', Daily Bulletin, 12 December 1951 — https://www.jta.org/archive/israel-parliament-urges-striking-seamen-to-return-to-work — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "the Government will not allow the fist to rule in our state"
  - Supports:
    - On 12 December 1951 the Knesset called on the month-old seamen's strike to end; Ben-Gurion said the strikers had been misled and the government would not let the fist rule; the merchant marine employed 1,100 seamen, 882 of them Israelis

**[S5607]** Jewish Telegraphic Agency, 'Lsraeli Seamen Offer to End Strike; Three Vessels Sail', Daily Bulletin, 19 November 1951 — https://www.jta.org/archive/lsraeli-seamen-offer-to-end-strike-three-vessels-sail — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "if the Histadrut would grant the union autonomy within the labor federation set-up for a period of one year"
  - Supports:
    - In the 1951 seamen's strike the union said it would end the strike if the Histadrut granted it one year of autonomy and accepted its seamen's code; the Histadrut meanwhile sailed ships with volunteer crews

**[S5608]** Jewish Telegraphic Agency, 'Knesset Votes Authorization for Israel Negotiations with Germany', Daily Bulletin, 10 January 1952 — https://www.jta.org/archive/knesset-votes-authorization-for-israel-negotiations-with-germany — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "voted to authorize the Government to enter into direct negotiations with Germany for the payment of reparations claims"
  - Supports:
    - On 9-10 January 1952 the Knesset voted 61 to 50 to authorise direct negotiations with Germany on reparations claims of $1.5 billion

**[S5609]** Jewish Telegraphic Agency, 'Israel Will Not Resume Hague Talks Unless Germany Makes Firm Offer', Daily Bulletin, 8 May 1952 — https://www.jta.org/archive/israel-will-not-resume-hague-talks-unless-germany-makes-firm-offer — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "calling for complete boycott of German goods by world Jewry"
  - Supports:
    - In May 1952 Herut leader Menachem Begin, who opposed the reparations talks, called in Paris for a complete boycott of German goods by world Jewry

**[S5610]** Jewish Telegraphic Agency, 'Israel Cabinet Crisis Ended; Former Ministers Return to Posts', Daily Bulletin, 4 June 1953 — https://www.jta.org/archive/israel-cabinet-crisis-ended-former-ministers-return-to-posts — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "prohibiting the hoisting of any flag in schools except the Israel flag"
  - Supports:
    - On 4 June 1953 the four General Zionist ministers returned after the Cabinet promised a state education law and an order barring all flags but the Israeli flag and all hymns but the national anthem in schools

**[S5611]** Jewish Telegraphic Agency, 'Ben Gurion Takes over Ministries of Resigned Cabinet Members', Daily Bulletin, 27 May 1953 — https://www.jta.org/archive/ben-gurion-takes-over-ministries-of-resigned-cabinet-members — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "permit the flying of the red flag, alongside the Israeli flag"
  - Supports:
    - On 26 May 1953 four General Zionist ministers resigned; they would return only if the Mapai central committee withdrew its decision to permit the red flag beside the Israeli flag and the Internationale in schools where most parents asked

**[S5612]** Jewish Telegraphic Agency, 'Knesset Gets Bill Extending Military Rule in Border Areas', Daily Bulletin, 17 December 1953 — https://www.jta.org/archive/knesset-gets-bill-extending-military-rule-in-border-areas — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "The Israel Government moved today to extend for one more year its authority to maintain military administration in the border regions"
  - Supports:
    - On 17 December 1953 Acting Defence Minister Lavon introduced a bill to extend military administration in the border regions by a year; Arab deputies, Mapam and the Communists demanded abolition of military rule in the border zones; Lavon cited 56 Israelis killed in infiltrations in 1953

**[S5613]** Jewish Telegraphic Agency, 'Israel Rejects U.S. Proposal to Use Lake Tiberias As Reservoir', Daily Bulletin, 2 February 1955 — https://www.jta.org/archive/israel-rejects-u-s-proposal-to-use-lake-tiberias-as-reservoir — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "Israel has definitely rejected the proposal by Ambassador Eric Johnston that it permit Lake Tiberias to be used as a storage reservoir"
  - Supports:
    - In February 1955 Israel rejected Eric Johnston's proposal to use Lake Tiberias as a Yarmuk storage reservoir while its Cabinet discussed the Johnston plan; Agriculture Minister Naphtali said Israel could not relinquish a drop of water

**[S5614]** Jewish Telegraphic Agency, 'Eisenhower Outlines Basic Proposals for Development of Jordan Waters', Daily Bulletin, 24 August 1955 — https://www.jta.org/archive/eisenhower-outlines-basic-proposals-for-development-of-jordan-waters — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "A neutral, impartial authority should be created to supervise withdrawals of water from the river system"
  - Supports:
    - In August 1955 President Eisenhower outlined the Johnston plan: an equitable share of the Jordan system for four states, a neutral authority to supervise withdrawals, and relief of the Arab refugees as a main aim

**[S5615]** Jewish Telegraphic Agency, 'Israel Govt. Decides Not to Check Private Traffic on Sabbath', Daily Bulletin, 7 December 1954 — https://www.jta.org/archive/israel-govt-decides-not-to-check-private-traffic-on-sabbath — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "decided last night not to interfere with private traffic on the Sabbath"
  - Supports:
    - On 6 December 1954 the Cabinet decided not to interfere with private Sabbath traffic or license passenger trucks; religious ministers Shapiro and Burg had demanded police curb "private militias" and the removal of a Histadrut club near Mea Shearim

**[S5616]** Jewish Telegraphic Agency, 'Sharett Ousts General Zionists from Cabinet; Forms New Government', Daily Bulletin, 30 June 1955 — https://www.jta.org/archive/sharett-ousts-general-zionists-from-cabinet-forms-new-government — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "the Israel Minister of Justice has ordered the attorney general to appeal to the Supreme Court"
  - Supports:
    - On 30 June 1955 Sharett ousted the General Zionist ministers after they abstained on the Kastner no-confidence motions; the Justice Minister ordered the Attorney General to appeal the Kastner verdict

**[S5617]** Jewish Telegraphic Agency, 'Knesset Defeats Non-confidence Motions on the Kastner Case', Daily Bulletin, 29 June 1955 — https://www.jta.org/archive/knesset-defeats-non-confidence-motions-on-the-kastner-case — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "censuring the government for bringing the case to trial"
  - Supports:
    - On 29 June 1955 the Knesset defeated Herut and Communist no-confidence motions censuring the government for bringing the libel case over Dr Israel Kastner to trial

**[S5618]** Jewish Telegraphic Agency, 'Actions Committee Ends Session with Pledge on North Africa', Daily Bulletin, 2 September 1955 — https://www.jta.org/archive/actions-committee-ends-session-with-pledge-on-north-africa — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "adoption of a resolution calling for the rescue of threatened North African Jewry"
  - Supports:
    - On 1-2 September 1955 the Zionist Actions Committee adopted Eliahu Dobkin's resolution to rescue North African Jewry, with pledges of additional funds from several countries

**[S5619]** Jewish Telegraphic Agency, 'Actions Committee May Get Plan for All-out No. African Immigration', Daily Bulletin, 29 August 1955 — https://www.jta.org/archive/actions-committee-may-get-plan-for-all-out-no-african-immigration — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "Remember that the slaughterer always stands ready with his knife"
  - Supports:
    - In August 1955 Jewish Agency leaders considered an all-out immigration of North African Jews; Finance Minister Eshkol said bringing 100,000 would cost 150 million pounds in initial costs and the funds were lacking, while Zerubavel urged no delay irrespective of cost

**[S5620]** Jewish Telegraphic Agency, 'Israel Cabinet Meets to Consider Two Day Old Strike of Professionals', Daily Bulletin, 9 February 1956 — https://www.jta.org/archive/israel-cabinet-meets-to-consider-two-day-old-strike-of-professionals — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "reversal of a decision to grant the professionals as much of a raise as a government investigating commission had recommended"
  - Supports:
    - In February 1956 state-employed doctors, engineers and other professionals struck; Justice Minister Pinhas Rosen of the Progressive Party quit the coalition over the government's reversal of a decision to give the raise recommended by an investigating commission

**[S5621]** Jewish Telegraphic Agency, 'Bill to Ban Pig Breeding Approved by Knesset in First Reading', Daily Bulletin, 22 December 1961 — https://www.jta.org/archive/bill-to-ban-pig-breeding-approved-by-knesset-in-first-reading — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "The earlier law empowered only local authorities to pass anti-pig breeding laws"
  - Supports:
    - On 21 December 1961 the Knesset passed a first reading (41 to 19) of a bill banning pig breeding and pork sale except around Nazareth; an earlier 1955 law had empowered only local authorities, and 55 of 151 legislated

**[S5622]** Jewish Telegraphic Agency, 'Israel Orthodox Cabinet Members Threaten to Resign over "pork Bill"', Daily Bulletin, 31 May 1956 — https://www.jta.org/archive/israel-orthodox-cabinet-members-threaten-to-resign-over-pork-bill — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "The bill currently proposed in the Cabinet is one which would give the municipalities the right to restrict the raising and sale of pork, but not to ban such activities"
  - Supports:
    - On 31 May 1956 the Mizrachi and Hapoel Hamizrachi ministers told Ben-Gurion they would leave the Cabinet unless the pork bill let municipalities ban pig-raising and pork sales; the draft let them only restrict

**[S5623]** Jewish Telegraphic Agency, 'Israel Withdraws from Gaza and Akaba; Military Chiefs Meet on Details', Daily Bulletin, 5 March 1957 — https://www.jta.org/archive/israel-withdraws-from-gaza-and-akaba-military-chiefs-meet-on-details — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "Agreement on the withdrawal of Israel troops from the Gaza and Akaba areas was reached today"
  - Supports:
    - On 5 March 1957 Dayan and the UN Emergency Force commander agreed the details of Israel's withdrawal from Gaza and the Aqaba area, after Ben-Gurion consulted each coalition party

**[S5624]** Jewish Telegraphic Agency, 'Three Non-confidence Motions Against Ben Gurion Defeated in Knesset', Daily Bulletin, 7 March 1957 — https://www.jta.org/archive/three-non-confidence-motions-against-ben-gurion-defeated-in-knesset — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "A General Zionist resolution which would have required the Government to halt troop withdrawals forthwith"
  - Supports:
    - On 7 March 1957 the Knesset defeated Herut, Communist and General Zionist motions against the withdrawal; the General Zionist motion would have halted the troop withdrawals

**[S5625]** Jewish Telegraphic Agency, 'Ben Gurion Proclaims His Views on Gaza and Akaba Areas in Knesset', Daily Bulletin, 24 January 1957 — https://www.jta.org/archive/ben-gurion-proclaims-his-views-on-gaza-and-akaba-areas-in-knesset — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "Israel was willing to withdraw its troops from the Gaza Strip but must insist on maintaining its administration over the territory"
  - Supports:
    - On 24 January 1957 Ben-Gurion told the Knesset that Israel would withdraw its troops from Gaza but keep its administration there, and would leave Sharm el Sheikh only against guarantees of free passage in the Gulf of Aqaba

**[S5626]** Jewish Telegraphic Agency, 'Ben Gurion Announces Easing of Military Restrictions on Arabs', Daily Bulletin, 31 December 1958 — https://www.jta.org/archive/ben-gurion-announces-easing-of-military-restrictions-on-arabs — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "Easing of military restrictions on Arabs in border areas, and initiation of important development projects in areas largely inhabited by Arabs, were announced here today"
  - Supports:
    - On 31 December 1958 Ben-Gurion announced, after meeting the Arab members of the Knesset, an easing of military restrictions in border areas, irrigation schemes costing over a million pounds and the release of Waqf revenues to local Muslim communities

**[S5627]** Jewish Telegraphic Agency, 'Knesset Welcomes Lifting of Travel Restrictions for Israeli Arabs', Daily Bulletin, 23 October 1963 — https://www.jta.org/archive/knesset-welcomes-lifting-of-travel-restrictions-for-israeli-arabs — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "The demand for total abolition of military government was made by Menahem Beigin of Herut"
  - Supports:
    - On 23 October 1963 Herut, the Liberals and Mapam demanded total abolition of military government over Israeli Arabs as Eshkol announced the end of travel permits in most areas

**[S5628]** Jewish Telegraphic Agency, 'Golda Meir Demands Mapam’s Resignation from Cabinet; Voices Charges', Daily Bulletin, 9 September 1960 — https://www.jta.org/archive/golda-meir-demands-mapams-resignation-from-cabinet-voices-charges — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "approximately 220,000 Arabs living in Israel"
  - Supports:
    - In September 1960 about 220,000 Arabs lived in Israel; Mapam criticised military rule in some Arab-inhabited areas and urged the government to accept the return of some refugees

**[S5629]** Jewish Telegraphic Agency, 'Palestine Economic Corporation Co-sponsors Development of Ashdod', Daily Bulletin, 16 October 1959 — https://www.jta.org/archive/palestine-economic-corporation-co-sponsors-development-of-ashdod — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "decision to construct a deep-water port at Ashdod"
  - Supports:
    - By October 1959 the Israeli government had decided to build a roughly $30 million deep-water port at Ashdod, to relieve Haifa, then the only other deep-sea port, with a 99-year concession for 10,000 adjoining acres

**[S5630]** Jewish Telegraphic Agency, 'Tel Aviv Municipality Gets $81,000,000 Loan to Convertits Its Harbor into Deep Water Port', Daily Bulletin, 28 June 1949 — https://www.jta.org/archive/tel-aviv-municipality-gets-81000000-loan-to-convertits-its-harbor-into-deep-water-port — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "the conversion of its port to a deep water harbor"
  - Supports:
    - In June 1949 Tel Aviv Mayor Israel Rokach announced a municipal loan for converting Tel Aviv's port into a deep-water harbour

**[S5631]** Jewish Telegraphic Agency, 'Knesset Votes Approval of New Cabinet Program; Vote is 78 to 33', Daily Bulletin, 18 December 1959 — https://www.jta.org/archive/knesset-votes-approval-of-new-cabinet-program-vote-is-78-to-33 — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "approval of the new five-party Cabinet"
  - Supports:
    - On 18 December 1959 the Knesset approved Ben-Gurion's new five-party Cabinet, 78 to 33

**[S5632]** Jewish Telegraphic Agency, 'Two Left-wing Parties May Join Israel’s New Coalition Cabinet', Daily Bulletin, 16 December 1959 — https://www.jta.org/archive/two-left-wing-parties-may-join-israels-new-coalition-cabinet — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "that the Premier had the right to dismiss Ministers voting in the Knesset against Government motions"
  - Supports:
    - In December 1959 Ben-Gurion claimed the right to dismiss ministers who voted against the government; a compromise made a minister's vote against a government motion an automatic resignation, which would bring Mapam and Ahdut HaAvoda in

**[S5633]** Jewish Telegraphic Agency, 'Israel Cabinet Decides to Pay No Salary to Teachers During Strike', Daily Bulletin, 22 March 1961 — https://www.jta.org/archive/israel-cabinet-decides-to-pay-no-salary-to-teachers-during-strike — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "will not be paid for the period they are out"
  - Supports:
    - On 22 March 1961 the Cabinet decided secondary teachers on strike since 5 March would not be paid for the strike period; Education Minister Eban called the strike unjustified

**[S5634]** Jewish Telegraphic Agency, 'Israel Government Refuses to Negotiate with Striking Teachers', Daily Bulletin, 31 January 1961 — https://www.jta.org/archive/israel-government-refuses-to-negotiate-with-striking-teachers — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "the teachers believe that the parents of high school students would not mind paying higher fees to meet salary increases"
  - Supports:
    - On 31 January 1961 the government refused to negotiate with high-school teachers who had begun a partial strike for regrading and about 30 percent higher pay, fearing elementary teachers would follow and that parent-paid fees would discriminate against poorer students

**[S5635]** Jewish Telegraphic Agency, 'Mapai and Achdut Reach Agreement; Ben-gurion to Form ’narrow Cabinet’', Daily Bulletin, 30 October 1961 — https://www.jta.org/archive/mapai-and-achdut-reach-agreement-ben-gurion-to-form-narrow-cabinet — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "immediate abolition of Military Government"
  - Supports:
    - On 30 October 1961 Mapai and Ahdut HaAvoda agreed on a small coalition with the National Religious Party and Poale Agudat Israel; Mapam would join only if military government were abolished at once and the Knesset security committee could overrule the Defence Ministry

**[S5636]** Jewish Telegraphic Agency, 'Bill Banning Pig Breeding in Israel Passed in First Knesset Reading', Daily Bulletin, 1 March 1962 — https://www.jta.org/archive/bill-banning-pig-breeding-in-israel-passed-in-first-knesset-reading — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "It was opposed by all Mapam, Achdut Avodah and Communist deputies"
  - Supports:
    - On 28 February 1962 a bill banning pig raising outside a few non-Jewish areas passed its first reading, 39 to 23; two Arab deputies regretted that it did not cover the whole country

**[S5637]** Jewish Telegraphic Agency, 'Bill Banning Pig-Breeding Stirs Debate in Knesset; Passage Assured', Daily Bulletin, 28 February 1962 — https://www.jta.org/archive/bill-banning-pig-breeding-stirs-debate-in-knesset-passage-assured — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "pig meat was the cheapest source of nutrition"
  - Supports:
    - In February 1962 a private members' bill to ban pig breeding, exempting Nazareth and other Christian Arab localities, was debated; Mapam's Yaacov Riftin argued that pork was the cheapest meat and opposed yielding to psychological terror

**[S5638]** Jewish Telegraphic Agency, 'Israel Cabinet Rejects New Road As Solution to Sabbath Rioting Problem', Daily Bulletin, 18 November 1963 — https://www.jta.org/archive/israel-cabinet-rejects-new-road-as-solution-to-sabbath-rioting-problem — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "At present, the police would divert some of the traffic on the Sabbath"
  - Supports:
    - On 17 November 1963 the Cabinet judged a special bypass road from the Mandelbaum Gate around Mea Shearim not feasible, backed municipal roads in northern Jerusalem and had police divert some Sabbath traffic

**[S5639]** Jewish Telegraphic Agency, 'Knesset Discusses Sabbath Demonstrations; Refers Issue to Committee', Daily Bulletin, 31 October 1963 — https://www.jta.org/archive/knesset-discusses-sabbath-demonstrations-refers-issue-to-committee — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "urged more stringent police and government measures against the zealots"
  - Supports:
    - On 30 October 1963 the Knesset debated Sabbath clashes in Jerusalem's Mea Shearim; Eshkol said a ministerial committee was studying an alternate route to the Mandelbaum Gate road; Mapam urged tougher measures, Agudat Israel and Poale Agudat Israel urged police restraint

**[S5640]** Jewish Telegraphic Agency, 'Knesset Approves New Cabinet Presented by Eshkol; Vote is 71 to 41', Daily Bulletin, 13 January 1966 — https://www.jta.org/archive/knesset-approves-new-cabinet-presented-by-eshkol-vote-is-71-to-41 — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "Concessions were made on Sabbath restrictions to the National Religious Party"
  - Supports:
    - On 12 January 1966 the Knesset approved Eshkol's coalition 71 to 41; concessions were made to the National Religious Party on Sabbath restrictions and Ahdut HaAvoda and Mapam were given freedom to abstain on some issues

**[S5641]** Jewish Telegraphic Agency, 'Eshkol Starts Discussions on Formation of New Coalition Cabinet', Daily Bulletin, 19 November 1965 — https://www.jta.org/archive/eshkol-starts-discussions-on-formation-of-new-coalition-cabinet — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "determination to carry into the negotiations with Premier Eshkol its campaign drive against expansion of the"
  - Supports:
    - In November 1965 Mapam entered coalition talks with a campaign against expanding religious influence; the National Religious Party expected to demand a national Sabbath law, a revision of women's conscription and a 5.5-day week

**[S5642]** Jewish Telegraphic Agency, 'Knesset to Discuss German Reparations Today; Tension Mounts', Daily Bulletin, 7 January 1952 — https://www.jta.org/archive/knesset-to-discuss-german-reparations-today-tension-mounts — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "the centrist General Zionists and the leftist Communists and Mapam Party have indicated their vigorous opposition to the government"
  - Supports:
    - On 7 January 1952 Ben-Gurion's government asked the Knesset to authorise direct talks with Germany on $1.5 billion in claims; Herut, the General Zionists, Mapam and the Communists opposed

**[S5643]** Jewish Telegraphic Agency, 'Israel’s Attorney General Lodges Appeal Against Kastner Verdict', Daily Bulletin, 22 August 1955 — https://www.jta.org/archive/israels-attorney-general-lodges-appeal-against-kastner-verdict — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "Haim Cohen, today lodged an appeal with the Supreme Court"
  - Supports:
    - On 22 August 1955 Attorney General Haim Cohen lodged the state's appeal against the Jerusalem District Court verdict in the Kastner-Gruenwald case

**[S5644]** Jewish Telegraphic Agency, 'Rabbis in Israel Ask Government Action Against Haifa Municipality', Daily Bulletin, 3 May 1956 — https://www.jta.org/archive/rabbis-in-israel-ask-government-action-against-haifa-municipality — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "municipal laws prohibiting the sale of pork were unconstitutional"
  - Supports:
    - In May 1956 the Chief Rabbinate noted a Supreme Court ruling that municipal bans on pork sales were unconstitutional (a matter for the Knesset alone) and asked the religious parties' ministers to raise it with Ben-Gurion

**[S5645]** Jewish Telegraphic Agency, 'Israel Govt. Settles Salary Dispute with High School Teachers', Daily Bulletin, 18 January 1962 — https://www.jta.org/archive/israel-govt-settles-salary-dispute-with-high-school-teachers — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "finally settled here today"
  - Supports:
    - On 18 January 1962 the government and the high-school teachers initialled a settlement of a three-year pay dispute, with raises of 25 to 60 pounds a month, a study fund and sabbaticals

**[S5646]** Jewish Telegraphic Agency, 'Eshkol’s Efforts to Form New Cabinet Hampered by Religious Bloc', Daily Bulletin, 28 December 1965 — https://www.jta.org/archive/eshkols-efforts-to-form-new-cabinet-hampered-by-religious-bloc — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1948 data agent; page opened with curl and the quote checked verbatim in the raw text on 2026-10-13.
  - Quote: "insistence by the religious group upon banning of all operations in the new port of Ashdod on the Sabbath"
  - Supports:
    - On 27 December 1965 the National Religious Party told Eshkol there was no basis yet for joining his coalition; the main dispute was its demand that all work at the new port of Ashdod stop on the Sabbath

**[S5680]** JTA, 'Motion to Abolish Military Rule in Arab Areas Defeated in Knesset', 21 February 1963 — https://www.jta.org/archive/motion-to-abolish-military-rule-in-arab-areas-defeated-in-knesset — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-story builder (A10 density); page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "Balloting was preceded by a one-hour speech by Prime Minister David Ben-Gurion who strongly defended the military rule."
  - Supports:
    - February 1963: the Knesset kept the military government by 57 to 56 after Ben-Gurion defended it

**[S5681]** JTA, 'Knesset Rejects Motion to Abolish Military Rule in Arab Areas', 15 November 1962 — https://www.jta.org/archive/knesset-rejects-motion-to-abolish-military-rule-in-arab-areas — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-story builder (A10 density); page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "Dr, Rosen, who last February sustained a narrow 58 to 55 defeat in the Knesset in a previous fight for cancelation of the military rule"
  - Supports:
    - Pinhas Rosen (Liberals) moved to amend the British 1945 emergency regulations behind the military rule

**[S5682]** The Guardian (AFP), 'Israeli ambassador to New Zealand recalled in protest at UN vote role', 24 December 2016 — https://www.theguardian.com/world/2016/dec/24/israeli-ambassador-to-new-zealand-recalled-in-protest-at-un-vote-role — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-story builder (A10 density); page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "Ofir Gendelman, a spokesman for the Israeli prime minister Benjamin Netanyahu, tweeted that their ambassadors to New Zealand and Senegal were to return to Israel immediately."
  - Supports:
    - Netanyahu recalled the ambassadors to New Zealand and Senegal after Resolution 2334

**[S5683]** Times of Israel, 'Israel permanently downgrades its ties to New Zealand, Senegal', 10 February 2017 (web.archive.org copy) — https://web.archive.org/web/2017/https://www.timesofisrael.com/israel-said-to-permanently-downgrade-ties-to-new-zealand-senegal/ — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-story builder (A10 density); page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "Netanyahu summoned a dozen ambassadors for dressing-downs, canceled foreign aid to Senegal and Angola, disinvited the Ukrainian prime minister"
  - Supports:
    - Netanyahu's measures after Resolution 2334, and the Foreign Ministry's statement that there was no decision to downgrade relations

**[S5684]** Jerusalem Post, 'Gov't approves state committee of inquiry into Meron disaster', 20 June 2021 — https://www.jpost.com/israel-news/govt-approves-state-committee-of-inquiry-into-meron-disaster-671531 — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-story builder (A10 density); page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "The government passed a resolution to establish a state committee of inquiry into the Meron disaster"
  - Supports:
    - 20 June 2021: the Bennett-Lapid government set up a state commission of inquiry; Shas and UTJ resisted it

**[S5700]** JTA, '6 Arabs Killed, 35 Israeli Soldiers and Policemen Injured, 200 Arabs Jailed During Arab General Stri', March 31, 1976 — https://www.jta.org/archive/6-arabs-killed-35-israeli-soldiers-and-policemen-injured-200-arabs-jailed-during-arab-general-stri — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "called by the pro-Moscow Rakah Communist Party to protest the government"
  - Supports:
    - 30 March 1976 general strike of Israel's Arab citizens called by Rakah against planned Galilee land expropriation: six Arabs killed, over 35 soldiers and police injured, over 200 arrests; Police Minister Hillel blamed incitement by a subversive minority

**[S5701]** JTA, 'Cabinet Postpones for 2 Weeks Decision on Yadlin's Appointment', October 18, 1976 — https://www.jta.org/archive/cabinet-postpones-for-2-weeks-decision-on-yadlins-appointment — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "it would be better to revoke"
  - Supports:
    - 18 Oct 1976: the cabinet deferred two weeks, on Justice Minister Zadok's proposal, the decision on revoking Asher Yadlin's appointment as Bank of Israel governor; Independent Liberal ministers Kol and Hausner urged revocation

**[S5702]** JTA, 'Yadlin Arrested; Jailed for 15 Days', October 20, 1976 — https://www.jta.org/archive/yadlin-arrested-jailed-for-15-days — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "was remanded to Jail for 15 days this afternoon"
  - Supports:
    - 20 Oct 1976: Yadlin arrested on suspicion of bribery and remanded for 15 days; the cabinet had to select a new governor

**[S5703]** JTA, 'Rabin Resigns Following Probe into Illegal Bank Accounts Held by Him and His Wife in Washington', April 8, 1977 — https://www.jta.org/archive/rabin-resigns-following-probe-into-illegal-bank-accounts-held-by-him-and-his-wife-in-washington — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "Premier Yitzhak Rabin announced tonight that he was resigning following an investigation into illegal bank accounts"
  - Supports:
    - 8 Apr 1977: the Rabins' Washington accounts; a Finance Ministry penalty committee fined them IL150,000; Likud MK Flumin called for a police file

**[S5704]** JTA, 'Israeli Doctors Protest Concession on Autopsies', June 10, 1977 — https://www.jta.org/archive/israeli-doctors-protest-concession-on-autopsies — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "Likud has acquiesced to these demands."
  - Supports:
    - 10 Jun 1977: Aguda Israel's coalition demands (curbs on abortion, no autopsies without family consent); the Medical Association and Social Workers Union object

**[S5705]** JTA, 'The Issue of Autopsies', November 29, 1979 — https://www.jta.org/archive/the-issue-of-autopsies — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "It would permit autopsies only if the deceased person had agreed prior to death or if the family of the deceased consented afterwards."
  - Supports:
    - 29 Nov 1979: the cabinet approved an autopsy amendment to placate Aguda after an anti-abortion measure was defeated

**[S5706]** JTA, 'Knesset Adopts Bill Restricting Doctors' Rights on Autopsies: Law Was Demanded by Aguda Bloc', December 3, 1980 — https://www.jta.org/archive/knesset-adopts-bill-restricting-doctors-rights-on-autopsies-law-was-demanded-by-aguda-bloc — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "A bill severely restricting the right of doctors to perform autopsies was adopted by the Knesset early this morning by a vote of 57-53 with three abstentions."
  - Supports:
    - 3 Dec 1980: the Knesset passed the autopsy restriction demanded by Aguda

**[S5707]** JTA, 'Begin: Settlement Policy Determined by the Government, Not Ministers', September 14, 1977 — https://www.jta.org/archive/begin-settlement-policy-determined-by-the-government-not-ministers — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "the settlement program will be carried out only according to government decisions"
  - Supports:
    - 14 Sep 1977: Begin told Gush Emunim and ministers that settlement follows government decisions; the Gush complained the government had put a brake on settlement; US criticism

**[S5708]** JTA, 'Special to the JTA Dulzin Vows to Use All Means to End Phenomenon of Dropouts', April 26, 1978 — https://www.jta.org/archive/special-to-the-jta-dulzin-vows-to-use-all-means-to-end-phenomenon-of-dropouts — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "Leon Dulzin, chairman of the World Zionist Organization Executive vowed to use all ways and means to end the phenomenon of dropouts"
  - Supports:
    - 26 Apr 1978: Dulzin on dropout rate of 50.7 percent in Vienna (37.2 percent in 1975, under 5 percent in 1973)

**[S5709]** JTA, 'Various Problems Cited As Reasons for Increasing Rate of Dropouts', December 13, 1976 — https://www.jta.org/archive/various-problems-cited-as-reasons-for-increasing-rate-of-dropouts — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "afraid to go to Israel since the October, 1973 war"
  - Supports:
    - 13 Dec 1976: Joint and UIA officials on reasons for the rising dropout rate

**[S5710]** JTA, 'Tsur Chides U.S. Jewish Leaders for Ignoring Aliya and 'neshira'', March 19, 1987 — https://www.jta.org/archive/tsur-chides-u-s-jewish-leaders-for-ignoring-aliya-and-neshira — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "He was rebuffed by the Reagan Administration on grounds of freedom of choice."
  - Supports:
    - 19 Mar 1987: Minister Tsur and Premier Shamir sought direct flights and an end to automatic refugee status; Washington rebuffed it on freedom-of-choice grounds

**[S5711]** JTA, 'Dispute Flares over Project Renewal', January 26, 1979 — https://www.jta.org/archive/dispute-flares-over-project-renewal — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "Levy insisted that the operative execution of the project must be in the hands of his Housing Ministry"
  - Supports:
    - 26 Jan 1979: Housing Minister Levy versus Jewish Agency chairman Dulzin and UJA leaders over who runs Project Renewal (160 slum areas, 45,000 families)

**[S5712]** JTA, 'Behind the Headlines Renewing Neighborhoods and Lives', September 14, 1984 — https://www.jta.org/archive/behind-the-headlines-renewing-neighborhoods-and-lives — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "Project Renewal represents a partnership between diaspora Jewish communities, the government of Israel and the residents of the country"
  - Supports:
    - 14 Sep 1984: Project Renewal as a partnership with twinned Diaspora communities, created in 1978 after Begin's housing renovation proposal

**[S5713]** JTA, 'Project Renewal Towns Targeted', June 23, 1983 — https://www.jta.org/archive/project-renewal-towns-targeted — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "67 towns are targeted for assistance and 13 slum neighbor hoods are about to begin receiving aid"
  - Supports:
    - 23 Jun 1983: 67 towns and 13 slum neighbourhoods targeted under Project Renewal since 1979

**[S5714]** JTA, 'Cabinet Grants Teachers' Wage Demands', March 18, 1980 — https://www.jta.org/archive/cabinet-grants-teachers-wage-demands — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "The Cabinet decided yesterday to grant the wage demands of striking teachers in compliance with the order of a district labor court."
  - Supports:
    - 18 Mar 1980: the cabinet granted striking teachers' demands on a labour court order, Finance Minister Hurwitz objecting; ministries' budgets cut 1.5 percent; engineers demanded the same

**[S5715]** JTA, 'Hurwitz Resigns: Early Elections Loom As Resignation of Begins Government Appears Inevitable', January 12, 1981 — https://www.jta.org/archive/hurwitz-resigns-early-elections-loom-as-resignation-of-begins-government-appears-inevitable — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "He expressed hope that his successor would be able to maintain the present wage agreements"
  - Supports:
    - 12 Jan 1981: Hurwitz resigned over teachers' pay, saying it would trigger new pay demands and collapse his efforts to contain inflation

**[S5716]** JTA, 'Aridor Announces Price Hikes on Some Goods, Reductions on Others', February 3, 1981 — https://www.jta.org/archive/aridor-announces-price-hikes-on-some-goods-reductions-on-others — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "Aridor was helping the rich while harming the poor"
  - Supports:
    - 3 Feb 1981: Aridor raised prices of dairy, bread, meat, electricity and fuel and cut sales tax on colour TVs, refrigerators and some cars; Histadrut's Meshel objected

**[S5717]** JTA, 'New Economic Program to Be Introduced by Aridor', January 21, 1981 — https://www.jta.org/archive/new-economic-program-to-be-introduced-by-aridor — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "reduce the annual inflation rate, now at a record 130 percent-plus"
  - Supports:
    - 21 Jan 1981: Aridor's planned programme: foreign-currency savings, cost-of-living increments at 100 percent of the price index, lower fuel tax

**[S5718]** JTA, 'Religious Parties Seen Joining Begin Government Even if He Refuses to Meet Their Demands on the 'who', July 13, 1981 — https://www.jta.org/archive/religious-parties-seen-joining-begin-government-even-if-he-refuses-to-meet-their-demands-on-the-who — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "gave notice over the weekend that he and his party were not prepared to support the proposed amendment"
  - Supports:
    - 13 Jul 1981: NRP and Aguda seek an iron-clad guarantee on the Who-is-a-Jew amendment; Liberal Party wing and Chief Rabbis Goren and Yosef take opposite positions

**[S5719]** JTA, 'Coalition Agreement Signed', August 5, 1981 — https://www.jta.org/archive/coalition-agreement-signed — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "The coalition agreement between Premier Menachem Begin and the three religious parties"
  - Supports:
    - 5 Aug 1981: Begin's coalition agreement with NRP, Aguda Israel and Tami signed

**[S5720]** JTA, ''who is a Jew' Bill Passes Its First Reading in the Knesset', July 27, 1978 — https://www.jta.org/archive/who-is-a-jew-bill-passes-its-first-reading-in-the-knesset — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "promised that the Law of Return would be amended according to halacha"
  - Supports:
    - 27 Jul 1978: the 1977 coalition agreement promised the Law of Return would be amended according to halacha; the bill passed first reading and was expected to be defeated

**[S5721]** JTA, 'Israeli Troops Seal off Four Druze Villages on Golan Heights', February 26, 1982 — https://www.jta.org/archive/israeli-troops-seal-off-four-druze-villages-on-golan-heights — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "Armed troops sealed off four Druze villages on the Golan Heights last night"
  - Supports:
    - 26 Feb 1982: a 12-day Druze general strike against the Golan Law; troops sealed four villages; Interior Minister Koenig promised no forced service or citizenship

**[S5722]** JTA, 'Druze Leaders Vow to Continue Strike', March 30, 1982 — https://www.jta.org/archive/druze-leaders-vow-to-continue-strike — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "All but a handful of the 14,000 Golan Druze refused to accept Israeli identity cards"
  - Supports:
    - 30 Mar 1982: the Golan Druze strike enters its seventh week; the army promised to end the blockade on 1 April and not force identity cards

**[S5723]** JTA, 'Cabinet Reaffirms Previous Decision to Halt El Al Sabbath Flights', August 23, 1982 — https://www.jta.org/archive/cabinet-reaffirms-previous-decision-to-halt-el-al-sabbath-flights — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "The workers complained that the ban would lead to a slow death of El Al."
  - Supports:
    - 23 Aug 1982: the cabinet reaffirmed its decision to halt El Al Saturday flights; workers' committees and Agudat Israel argue the economics

**[S5724]** JTA, 'Knesset Finance Committee Makes It Final: El Al Sabbath Flights Are Grounded', August 26, 1982 — https://www.jta.org/archive/knesset-finance-committee-makes-it-final-el-al-sabbath-flights-are-grounded — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "voted 11-10 to halt the flights"
  - Supports:
    - 26 Aug 1982: Knesset Finance Committee voted 11-10 to halt El Al's Sabbath and holiday flights from 1 September; Gad Yaacobi called it religious coercion

**[S5725]** JTA, 'El Al Suspends Sabbath Flights', February 1, 1983 — https://www.jta.org/archive/el-al-suspends-sabbath-flights — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "the airline today announced that it has suspended all flights on the Sabbath and Jewish holidays worldwide"
  - Supports:
    - 1 Feb 1983: El Al suspended all Sabbath and holiday flights worldwide as part of a labour agreement

**[S5726]** JTA, 'Army Colonel Dismissed', August 2, 1982 — https://www.jta.org/archive/army-colonel-dismissed — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "has been dismissed from the army"
  - Supports:
    - 2 Aug 1982: Col. Eli Geva dismissed after asking to be relieved of command over a possible attack on west Beirut

**[S5727]** JTA, 'Soldiers, Reservists Call for Withdrawal of IDF from Lebanon', October 1, 1982 — https://www.jta.org/archive/soldiers-reservists-call-for-withdrawal-of-idf-from-lebanon — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "A group of anti-war reserve officers and soldiers calling themselves the Yesh Gvul"
  - Supports:
    - 1 Oct 1982: Yesh Gvul petition of 1,000 signatures, 150 officers, asks Begin and Sharon to withdraw from Lebanon

**[S5728]** JTA, '2 More Army Reserve Officers Jailed for Refusing to Serve in Lebanon', February 25, 1983 — https://www.jta.org/archive/2-more-army-reserve-officers-jailed-for-refusing-to-serve-in-lebanon — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "was sentenced by a military court here this week to 28 days in prison for refusing to serve in Lebanon"
  - Supports:
    - 25 Feb 1983: reservists sentenced to 28 days for refusing to serve in Lebanon; six Yesh Gvul members in prison

**[S5729]** JTA, 'Knesset Begins Debate on Israel-Lebanon Pact: Shamir Says It Paves the Way to 'Peace and Coexistenc', May 12, 1983 — https://www.jta.org/archive/knesset-begins-debate-on-israel-lebanon-pact-shamir-says-it-paves-the-way-to-peace-and-coexistenc — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "The alternative of a long Israeli occupation of south Lebanon is impossible"
  - Supports:
    - 12 May 1983: Shamir defends the Israel-Lebanon agreement; the cabinet accepted it in principle 18-2; Peres criticises

**[S5730]** JTA, 'Knesset Approves Pact with Lebanon', May 17, 1983 — https://www.jta.org/archive/knesset-approves-pact-with-lebanon — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "both of whom opposed the agreement in the Cabinet"
  - Supports:
    - 17 May 1983: Knesset voted 55-8 with 46 abstentions; Sharon and Neeman opposed it in cabinet; Tehiya voted against

**[S5731]** JTA, 'Mk Says Israel is Making Every Effort, Including Use of Diplomatic Channels, to Rescue Ethiopian Jew', March 14, 1984 — https://www.jta.org/archive/mk-says-israel-is-making-every-effort-including-use-of-diplomatic-channels-to-rescue-ethiopian-jew — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "Israel was making every possible effort, including the use of diplomatic channels"
  - Supports:
    - 14 Mar 1984: MK Ben Porat, chairman of the inter-ministerial committee on Ethiopian Jews, says rescue is best left to the government; 5,500 Falashas had arrived, most in 1983

**[S5732]** JTA, 'Govt. Challenged on Falashas', November 12, 1982 — https://www.jta.org/archive/govt-challenged-on-falashas — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "The government was challenged yesterday to implement measures on behalf of the Falashas"
  - Supports:
    - 12 Nov 1982: Labor MK Moshe Shahal's urgent Knesset motion on 25,000 Falashas confined to camps

**[S5733]** JTA, 'Plight of Falashas to Be Publicized', November 7, 1979 — https://www.jta.org/archive/plight-of-falashas-to-be-publicized — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "Abraham Yadai, chairman of the Israel Falashas"
  - Supports:
    - 7 Nov 1979: after Falasha demonstrations the Jewish Agency reversed its quiet-diplomacy policy to publicise their plight

**[S5734]** JTA, 'Airlift of Ethiopian Jews Has Been Halted, Apparently Because of Its Premature Disclosure', January 7, 1985 — https://www.jta.org/archive/airlift-of-ethiopian-jews-has-been-halted-apparently-because-of-its-premature-disclosure — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "There were 35 flights since last November"
  - Supports:
    - 7 Jan 1985: the airlift via Sudan was halted apparently because of premature disclosure; the operation had been under military censorship

**[S5735]** JTA, 'Three Jewish Underground Members Sentenced to Life Imprisonment; Twelve Other Members Sentenced from', July 23, 1985 — https://www.jta.org/archive/three-jewish-underground-members-sentenced-to-life-imprisonment-twelve-other-members-sentenced-from — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "Haim Kaufman, chairman of the Likud Knesset faction, wants to avoid the clemency process."
  - Supports:
    - 23 Jul 1985: Livni, Sharbat and Nir sentenced to life for the Islamic College attack that killed three Palestinian students; 12 others sentenced; Kaufman seeks a special law; Herzog considers individual appeals only

**[S5736]** JTA, 'Herzog Rapped for Reducing Sentences of 3 Members of Jewish Underground', March 30, 1987 — https://www.jta.org/archive/herzog-rapped-for-reducing-sentences-of-3-members-of-jewish-underground — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "said it would fight against pardons for members of the underground by every legal, parliamentary and public means"
  - Supports:
    - 30 Mar 1987: Herzog commuted the three life sentences to 24 years; Kaufman wanted pardons; the Citizens Rights Movement opposed any pardon

**[S5737]** JTA, 'Jewish Terrorist Suspects Named; Most Linked with Gush Leadership', June 20, 1984 — https://www.jta.org/archive/jewish-terrorist-suspects-named-most-linked-with-gush-leadership — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "in which three Arab students were killed and 33 wounded"
  - Supports:
    - 20 Jun 1984: the underground's attacks: the Islamic College in Hebron (3 killed, 33 wounded), the 1980 car bombings that maimed two Arab mayors, the Temple Mount plot, and the April 1984 bus sabotage

**[S5738]** JTA, 'Labor Party Adopts Education Reform Bill Realigning Primary, Secondary Schools', July 30, 1968 — https://www.jta.org/archive/labor-party-adopts-education-reform-bill-realigning-primary-secondary-schools — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "setting up a six-year primary school system followed by three years of junior high school and three years of senior high school"
  - Supports:
    - 30 Jul 1968: Labor adopted the school reform bill 69 to 3 with 18 abstentions; primary teachers struck for a day against it; the NRP feared for religious schools

**[S5739]** JTA, 'Labor Ministers Propose Golda Meir As Prime Minister in 'caretaker' Government', March 4, 1969 — https://www.jta.org/archive/labor-ministers-propose-golda-meir-as-prime-minister-in-caretaker-government — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "Nomination of Mrs. Meir was decided upon at a meeting of the Labor members of the Cabinet under the chairmanship of Acting Prime Minister Yigal Allon."
  - Supports:
    - 4 Mar 1969: Labor ministers nominate Meir as caretaker Prime Minister; only Dayan abstained; the Rafi group named Dayan

**[S5740]** JTA, 'Shazar Will Ask Knesset Leaders to Form Government After Mourning Period', February 27, 1969 — https://www.jta.org/archive/shazar-will-ask-knesset-leaders-to-form-government-after-mourning-period — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "He is clearly the most popular candidate for the Premiership."
  - Supports:
    - 27 Feb 1969: after Eshkol's death, candidates for Prime Minister: Dayan, Allon, Eban, Meir, Sapir

**[S5741]** JTA, 'Knesset Rejects Non-confidence Vote on Issue of 7-day-a-week Television', May 20, 1969 — https://www.jta.org/archive/knesset-rejects-non-confidence-vote-on-issue-of-7-day-a-week-television — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "Speaking for the resolution, Moshe Unna of the National Religious Party charged that the decision to begin TV broadcasting on the Sabbath was an unnecessary affront to Orthodox Jews."
  - Supports:
    - 20 May 1969: Knesset rejected 69-3 (19 abstentions) Agudat Israel's no-confidence motion over seven-day television; Meir defends it

**[S5742]** JTA, 'Compromise Reached by Israel Cabinet on Who is Jewish; Seek Law of Return Change', January 30, 1970 — https://www.jta.org/archive/compromise-reached-by-israel-cabinet-on-who-is-jewish-seek-law-of-return-change — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "The formula to meet the problem by amending the Law of Return was proposed by Minister of Justice Yaacov Shimshon Shapiro"
  - Supports:
    - 30 Jan 1970: the cabinet chose to amend the Law of Return rather than the registration law after the Shalit ruling

**[S5743]** JTA, 'Cabinet Declines to Rule on 'nationality' Issue, Leaves It to Supreme Court', November 26, 1968 — https://www.jta.org/archive/cabinet-declines-to-rule-on-nationality-issue-leaves-it-to-supreme-court — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "Justice Shimon Agranat, Supreme Court president, proposed legislation deleting"
  - Supports:
    - 26 Nov 1968: Supreme Court president Agranat proposed deleting nationality from the registry; the cabinet declined; Burg threatened an NRP walkout

**[S5744]** JTA, 'Shalit Children Registered As Jews; Controversy over Cabinet Ruling Mounts', February 2, 1970 — https://www.jta.org/archive/shalit-children-registered-as-jews-controversy-over-cabinet-ruling-mounts — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "was opposed by the two-man Haolam Hazeh faction"
  - Supports:
    - 2 Feb 1970: the Shalit children registered as Jews; Haolam Hazeh opposed the cabinet's decision to amend the Law of Return

**[S5745]** JTA, 'Mrs. Meir Signs Regulations Ordering Doctors Back to Work', August 10, 1971 — https://www.jta.org/archive/mrs-meir-signs-regulations-ordering-doctors-back-to-work — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "Premier Golda Meir signed tonight emergency regulations ordering striking doctors to return to their posts in government hospitals."
  - Supports:
    - 10 Aug 1971: Meir signed back-to-work regulations for 2,000 striking hospital doctors after Health Minister Shemtov and Mapam refused

**[S5746]** JTA, 'Knesset Holds Session on Hospital Strike; Doctors Bitter About Back-to-work Order', August 11, 1971 — https://www.jta.org/archive/knesset-holds-session-on-hospital-strike-doctors-bitter-about-back-to-work-order — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "The doctors who returned to work today were bitter over the back-to-work orders."
  - Supports:
    - 11 Aug 1971: Knesset session on the hospital strike; doctors bitter

**[S5747]** JTA, 'Mapam to Stay in Government to Preserve Unity', September 2, 1971 — https://www.jta.org/archive/mapam-to-stay-in-government-to-preserve-unity — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "Time proved Mapam Health Minister Victor Shemtov"
  - Supports:
    - 2 Sep 1971: Deputy Health Minister Zuabi on Mapam's objection to the back-to-work orders

**[S5748]** JTA, 'Mrs. Meir Defends Disengagement Accord; Beigin, Sharon Denounce It As Capitulation-gruelling 10-hou', January 23, 1974 — https://www.jta.org/archive/mrs-meir-defends-disengagement-accord-beigin-sharon-denounce-it-as-capitulation-gruelling-10-hou — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "declaring that the only alternative was a resumption of war"
  - Supports:
    - 23 Jan 1974: Meir defends the disengagement accord with Egypt; Begin and Sharon denounce it; Knesset voted 76-35

**[S5749]** JTA, 'Israeli Government is Seeking to Convince the Public That the Accord with Lebanon is the Best Possib', May 10, 1983 — https://www.jta.org/archive/israeli-government-is-seeking-to-convince-the-public-that-the-accord-with-lebanon-is-the-best-possib — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the content-1966 v3 data agent; page fetched with curl-equivalent and a browser user-agent and the quote checked verbatim in the raw page text on 2026-10-13.
  - Quote: "is approaching the 500 mark and almost 2,650 have been wounded"
  - Supports:
    - 10 May 1983: the government defends the Lebanon accord; Israeli dead in Lebanon approaching 500 and almost 2,650 wounded; Labor faction voted 40-10 against

**[S5780]** JTA, 'Mitterrand Tells Knesset That Israel Has a Right to Live, but This Right Cannot Be Denied to the Palestinians', 5 March 1982 — https://www.jta.org/archive/mitterrand-tells-knesset-that-israel-has-a-right-to-live-but-this-right-cannot-be-denied-to-the-pal — accessed: 2026-10-14 — provenance: opened
  - Note: Added by fix4-diplo; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "He came to Israel to end the coolness, often bordering on hostility, which had characterized France-Israeli relations during the administrations of Charles de Gaulle and his successors."
  - Supports:
    - March 1982: the first state visit of a French president to Israel, to end the chill of the de Gaulle years

**[S5781]** JTA, 'Sarkozy salutes Israel at Knesset', 23 June 2008 — https://www.jta.org/2008/06/23/default/sarkozy-salutes-israel-at-knesset — accessed: 2026-10-14 — provenance: opened
  - Note: Added by fix4-diplo; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "France is ready to help Israel achieve peace but wants concessions toward the Palestinians, Nicolas Sarkozy told the Knesset."
  - Supports:
    - June 2008: Sarkozy's state visit and Knesset speech, friendship and a call for concessions to the Palestinians

**[S5782]** JTA, 'Netanyahu welcomes Egyptian military reassurances', 13 February 2011 — https://www.jta.org/2011/02/13/israel/netanyahu-welcomes-egyptian-military-reassurances — accessed: 2026-10-14 — provenance: opened
  - Note: Added by fix4-diplo; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "Netanyahu said Saturday night in his first comments since Egyptian President Hosni Mubarak resigned on Feb. 11, ceding power to the military."
  - Supports:
    - Mubarak resigned on 11 Feb 2011; the Egyptian army said it would honour the peace treaty

**[S5783]** JTA, 'Israeli diplomats return to Cairo embassy', 19 September 2011 — https://www.jta.org/2011/09/19/israel/israeli-diplomats-return-to-cairo-embassy — accessed: 2026-10-14 — provenance: opened
  - Note: Added by fix4-diplo; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "necessitating the emergency rescue of its staff by Egyptian commandos."
  - Supports:
    - September 2011: rioters stormed Israel's embassy in Cairo; a skeleton staff returned

**[S5784]** BBC News, 'Iran leader's comments attacked', 27 October 2005 — http://news.bbc.co.uk/2/hi/middle_east/4378948.stm — accessed: 2026-10-14 — provenance: opened
  - Note: Added by fix4-diplo; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "The European Union and Russia have joined condemnation of the Iranian president's public call for Israel to be "wiped off the map"."
  - Supports:
    - October 2005: President Ahmadinejad's call against Israel, condemned by the EU and Russia

**[S5785]** JTA, 'Israeli finance minister moves to phase out U.S. economic aid', 12 February 1999 — https://www.jta.org/1999/02/12/lifestyle/israeli-finance-minister-moves-to-phase-out-u-s-economic-aid — accessed: 2026-10-14 — provenance: opened
  - Note: Added by fix4-diplo; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "At the end of the process, which as proposed would take 10 years, the United States would provide Israel annually with about $2.5 billion in military aid in place of the combined $3 billion in economic and military assistance, sources said."
  - Supports:
    - 1998-99: a ten-year plan to phase out US economic aid to Israel and raise military aid

**[S5786]** JTA, 'Peres Signs Trade Accord with Qatar During Gulf Tour', 2 April 1996 — https://www.jta.org/archive/peres-signs-trade-accord-with-qatar-during-gulf-tour — accessed: 2026-10-14 — provenance: opened
  - Note: Added by fix4-diplo; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "Israel and Qatar have signed an agreement to establish low-level economic ties, the second such accord between Israel and a Persian Gulf state."
  - Supports:
    - April 1996: Israel and Qatar agree to open trade offices

**[S5787]** JTA, 'Arab countries end Israel relations', October 2000 — https://www.jta.org/archive/arab-countries-end-israel-relations — accessed: 2026-10-14 — provenance: opened
  - Note: Added by fix4-diplo; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "A Qatar bureau remains open in Israel, but may close soon."
  - Supports:
    - October 2000: Arab League call to close offices in Israel; Qatar's bureau stays open for now

**[S5788]** BBC News, 'Qatar profile - Timeline' — https://www.bbc.com/news/world-middle-east-14702609 — accessed: 2026-10-14 — provenance: opened
  - Note: Added by fix4-diplo; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "Qatar cuts trade ties with Israel over Gaza offensive. Was sole Gulf state to have trade ties with Israel."
  - Supports:
    - January 2009: Qatar cuts its trade ties with Israel over the Gaza offensive

**[S5789]** JTA, 'In Qatar, Livni Asks Moderates for Help on Peace Process', 16 April 2008 — https://www.jta.org/archive/in-qatar-livni-asks-moderates-for-help-on-peace-process — accessed: 2026-10-14 — provenance: opened
  - Note: Added by fix4-diplo; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "Israeli Foreign Minister Tzipi Livni flew to the Qatari capital of Doha in the Persian Gulf this week with an ambitious goal: changing moderate Arab attitudes toward Israel."
  - Supports:
    - April 2008: Foreign Minister Livni at the Doha forum

**[S5790]** JTA, 'Saudi Arabia opens airspace to Israeli flights', 15 July 2022 — https://www.jta.org/2022/07/15/global/saudi-arabia-opens-airspace-to-israeli-flights — accessed: 2026-10-14 — provenance: opened
  - Note: Added by fix4-diplo; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "The move saves time for flights to Asia but also points to warming relations between the two countries."
  - Supports:
    - July 2022: Saudi Arabia opens its airspace to Israeli flights

**[S5791]** JTA, 'Saudi Arabia appoints first Palestinian envoy as Saudi-Israel normalization talks continue', 15 August 2023 — https://www.jta.org/2023/08/15/israel/saudi-arabia-appoints-first-palestinian-envoy-as-saudi-israel-normalization-talks-continue — accessed: 2026-10-14 — provenance: opened
  - Note: Added by fix4-diplo; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "Saudi Arabia and Israel have been in U.S.-brokered discussions for months about the potential for Saudi Arabia to join some of its other Arab neighbors in formally recognizing Israel and establishing diplomatic relations with Jerusalem."
  - Supports:
    - 2023: US-brokered talks on Saudi-Israeli normalisation

**[S5792]** JTA, 'Israel, U.S. Welcome Saudi Plan, but First Want to See More Details', 27 February 2002 — https://www.jta.org/archive/israel-u-s-welcome-saudi-plan-but-first-want-to-see-more-details — accessed: 2026-10-14 — provenance: opened
  - Note: Added by fix4-diplo; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "Israel Radio reported that Sharon was making inquiries through several channels, including the United States."
  - Supports:
    - February 2002: Israel's cautious answer to Crown Prince Abdullah's plan; Katsav and Peres more open

**[S5793]** JTA, 'As Punishment for Settlements, U.S. to Chop $290 Million from Guarantees', 26 November 2003 — https://www.jta.org/archive/as-punishment-for-settlements-u-s-to-chop-290-million-from-guarantees — accessed: 2026-10-14 — provenance: opened
  - Note: Added by fix4-diplo; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "suggested that the U.S. deduct the agreed sum of $289.5 million dollars from the $3 billion in loan guarantees currently available"
  - Supports:
    - November 2003: Israel itself proposed the $289.5 million deduction from the loan guarantees; ZOA and House members opposed any deduction

**[S5794]** JTA, 'Tough questions for Bush on Saudi deal', 31 July 2007 — https://www.jta.org/2007/07/31/united-states/tough-questions-for-bush-on-saudi-deal — accessed: 2026-10-14 — provenance: opened
  - Note: Added by fix4-diplo; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "Israeli Prime Minister Ehud Olmert publicly endorsed the plan as a means to deter Iran."
  - Supports:
    - July 2007: the $30 billion aid pledge alongside the Saudi arms package; Olmert endorsed it, Wexler and Cardin opposed

**[S5795]** JTA, 'Newly Emboldened Russia Worries Israel on Arms Sales', 27 August 2008 — https://www.jta.org/archive/newly-emboldened-russia-worries-israel-on-arms-sales — accessed: 2026-10-14 — provenance: opened
  - Note: Added by fix4-diplo; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "Barak proposed that the United States give up its planned missile defenses in Eastern Europe in return for a clear-cut Russian commitment on Iran."
  - Supports:
    - August 2008: after the Georgia war Israel presses Moscow not to sell strategic arms to Syria; Barak's proposed bargain on Iran

**[S5796]** FRUS 1964-1968, vol. XVIII, doc. 218: Letter from President Johnson to Prime Minister Eshkol, 21 May 1965 — https://history.state.gov/historicaldocuments/frus1964-68v18/d218 — accessed: 2026-10-14 — provenance: opened
  - Note: Added by fix4-diplo; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "A preferable alternative to these bilateral arrangements would be for Israel to place the Dimona reactor and all other nuclear facilities under IAEA controls"
  - Supports:
    - May 1965: Johnson presses for regular US visits to Dimona or IAEA controls

**[S5800]** Jewish Telegraphic Agency, 'Inner Cabinet Agrees in Principle to Settle Taba Dispute with Egypt' (14 Jan 1986) — https://www.jta.org/archive/inner-cabinet-agrees-in-principle-to-settle-taba-dispute-with-egypt — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "was vigorously pressed by Premier Shimon Peres"
  - Supports:
    - Inner Cabinet agreed in principle to binding arbitration of Taba, with conciliation attempted first; Peres pressed it against Likud reservations, Jan 1986

**[S5801]** Jewish Telegraphic Agency, 'Taba Dispute Continues to Simmer' (13 Jan 1986) — https://www.jta.org/archive/taba-dispute-continues-to-simmer — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "the Likud document requires that Egypt eject the Palestine Liberation Organization presence from Cairo"
  - Supports:
    - Likud ministers' conditions before arbitration (PLO presence in Cairo, Ras Burka report, compensation), 13 Jan 1986

**[S5802]** Jewish Telegraphic Agency, 'Inner Cabinet Splits on Party Lines to Reject Peres' Request for Arbitration of Taba Dispute' (18 Jun 1985) — https://www.jta.org/archive/inner-cabinet-splits-on-party-lines-to-reject-peres-request-for-arbitration-of-taba-dispute — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "The Likud ministers, headed by Deputy Premier and Foreign Minister Yitzhak Shamir, insist that conciliation be tried first to resolve the Taba dispute before going to binding arbitration."
  - Supports:
    - Shamir and the Likud ministers insisted on conciliation before binding arbitration at Taba, Jun 1985

**[S5803]** Jewish Telegraphic Agency, 'Cabinet Ministers, Press Demand Full-scale Israeli Probe into Pollard's Espionage in U.S.' (9 Mar 1987) — https://www.jta.org/archive/cabinet-ministers-press-demand-full-scale-israeli-probe-into-pollards-espionage-in-u-s — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "One of the Ministers demanding an inquiry was Ezer Weizman"
  - Supports:
    - Weizman, Rubinstein and Katzav demanded an inquiry into the Pollard affair; Shamir, Peres and Rabin had resisted a probe, Mar 1987

**[S5804]** Jewish Telegraphic Agency, 'Inner Cabinet Decides to Establish 'Clarification Committee' to Examine Israel's Handling of Pollard Case' (12 Mar 1987) — https://www.jta.org/archive/inner-cabinet-decides-to-establish-clarirification-committee-to-examine-israels-handling-of-polla — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "the two-man committee is less than the full-scale government or judicial commission of inquiry demanded by several Ministers, Knesset members and a growing body of public opinion"
  - Supports:
    - Inner Cabinet chose a non-ministerial two-man clarification committee and retroactively accepted a Knesset subcommittee probe, 11 Mar 1987

**[S5805]** Jewish Telegraphic Agency, 'Program Proposed to Encourage Soviet Engineers to Stay in Israel' (22 Nov 1990) — https://www.jta.org/archive/program-proposed-to-encourage-soviet-engineers-to-stay-in-israel — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "The Association of Engineers and Architects in Israel is proposing a $100 million program to establish jobs for the estimated 120,000 engineers expected to immigrate here from the Soviet Union."
  - Supports:
    - Engineers' association proposal for a $100m jobs programme and engineering centres, chairman Shmuel Sorek, Nov 1990

**[S5806]** Jewish Telegraphic Agency, 'Study Says Israel Must Adapt Economy to Provide Jobs for Immigrant Talent' (28 Aug 1991) — https://www.jta.org/archive/study-says-israel-must-adapt-economy-to-provide-jobs-for-immigrant-talent — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "It was prepared by Hebrew University Professor Gur Offer and two Bank of Israel researchers, Drs. Karnit Flug and Nitza Kassir."
  - Supports:
    - Bank of Israel report (Offer, Flug, Kassir) favouring tailoring jobs to immigrants' skills with about $13bn of investment, Aug 1991

**[S5807]** Jewish Telegraphic Agency, 'With Subsidies over and Jobs Scarce, Soviet Olim Are Suddenly in a Pinch' (17 May 1991) — https://www.jta.org/archive/with-subsidies-over-and-jobs-scarce-soviet-olim-are-suddenly-in-a-pinch — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "Yolanda Straus, an official of the Absorption Ministry who organizes training courses for immigrants, said that immigrants who fail to find work in their profession through the state Employment Service are eligible for unemployment compensation from the ministry."
  - Supports:
    - Absorption Ministry training courses and unemployment grants for Soviet immigrants; unemployment among arrivals, May 1991

**[S5808]** Jewish Telegraphic Agency, 'Ethiopians to Leave Absorption Centers Within a Year Under Jewish Agency Plan' (4 Jun 1991) — https://www.jta.org/archive/ethiopians-to-leave-absorption-centers-within-a-year-under-jewish-agency-plan — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "gave its approval Monday to a detailed plan aimed at settling every Ethiopian immigrant in permanent housing by this time next year"
  - Supports:
    - Ministerial committee approved the Jewish Agency plan to house Ethiopian arrivals permanently within a year, 3 Jun 1991; 23,600 Ethiopian immigrants in 69 centres

**[S5809]** Jewish Telegraphic Agency, 'Behind the Headlines; One Year After Airlift, Ethiopians Mainly Still in Temporary Housing' (27 May 1992) — https://www.jta.org/archive/behind-the-headlines-one-year-after-airlift-ethiopians-mainly-still-in-temporary-housing — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "the ministry would like to rent out 13,000 brand-new apartments"
  - Supports:
    - Housing Ministry wished to rent 13,000 new apartments to Ethiopians, the Treasury refused; 1,145 rental and 506 purchase moves by May 1992

**[S5810]** Jewish Telegraphic Agency, 'As Baker Arrives in Israel, Settlement Policy is Scrapped' (20 Jul 1992) — https://www.jta.org/archive/as-baker-arrives-in-israel-settlement-policy-is-scrapped — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "suspended all previous decisions approving settlement building"
  - Supports:
    - Rabin cabinet suspended earlier settlement approvals on 19 Jul 1992; the political/security settlement distinction; Palestinians' demand to include East Jerusalem

**[S5811]** Jewish Telegraphic Agency, 'New Finance Minister Pledges to Cut Spending on Settlements' (21 Jul 1992) — https://www.jta.org/archive/new-finance-minister-pledges-to-cut-spending-on-settlements — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "shift spending away from settlements in the territories toward the creation of jobs"
  - Supports:
    - Finance Minister Shohat's pledge to move money from settlements to jobs; 14,000 units under construction, Jul 1992

**[S5812]** Jewish Telegraphic Agency, 'Israel Suspends Building Starts, Cancels 5,000 Housing Contracts' (17 Jul 1992) — https://www.jta.org/archive/israel-suspends-building-starts-cancels-5000-housing-contracts — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "The Council of Jewish Settlements in Judea, Samaria and Gaza issued a statement decrying the decision"
  - Supports:
    - Settlers' council condemned the housing freeze; Rabin said the freeze of political settlements would be less than total, Jul 1992

**[S5813]** Jewish Telegraphic Agency, 'Israel May Invite Foreign Workers to Replace the Absent Palestinians' (29 Apr 1993) — https://www.jta.org/archive/israel-may-invite-foreign-workers-to-replace-the-absent-palestinians — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "Bowing to pressure from building contractors, the government is now ready to allow foreign construction workers into Israel to replace Palestinian laborers who have been banned during the ongoing closure of the administered territories."
  - Supports:
    - Contractors' pressure for foreign workers; Labour Minister Ora Namir's reluctant agreement to a smaller number, Apr 1993

**[S5814]** Jewish Telegraphic Agency, 'Dovish Politicians Ask Government to Reduce Hardships in Territories' (28 Apr 1993) — https://www.jta.org/archive/dovish-politicians-ask-government-to-reduce-hardships-in-territories — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "proposed that unemployment allowances be paid to those who had lost their means of livelihood"
  - Supports:
    - Meretz ministers and Uzi Baram urged unemployment allowances for Palestinians; 120,000 Palestinian daily workers, contractors' demand for 10,000 foreign workers, Apr 1993

**[S5815]** Jewish Telegraphic Agency, 'News Analysis: Closure of the Territories Has Had Negative Economic Impact on Israel' (2 Jun 1993) — https://www.jta.org/archive/news-analysis-closure-of-the-territories-has-had-negative-economic-impact-on-israel — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "The government has partially coped with the labor shortage by approving the import of some 6,000 workers from Romania, Poland and Thailand."
  - Supports:
    - Costs of the 1993 closure, 6,000 foreign workers approved, 70,000 permit holders, 40,000 transient workers, 150,000 unemployed Israelis, Jun 1993

**[S5816]** Jewish Telegraphic Agency, 'Knesset Passes Landmark Health Plan That Provides Coverage to All Citizens' (16 Jun 1994) — https://www.jta.org/archive/knesset-passes-landmark-health-plan-that-provides-coverage-to-all-citizens — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "The Cabinet at that time had not wanted to break the link between the Histadrut trade union federation and the Kupat Holim Clalit, or General Sick Fund"
  - Supports:
    - National Health Insurance Law passed 68-0 on 15 Jun 1994 after Ramon resigned as health minister when the Cabinet rejected his bill in January; Kupat Holim insured about 70% of Israelis

**[S5817]** Jewish Telegraphic Agency, 'Netanyahu Announces Plan to Sell Government Companies' (24 Jan 1997) — https://www.jta.org/archive/netanyahu-announces-plan-to-sell-government-companies-2 — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "some 13 state firms, including the Bezek telephone company, Israel Chemicals and Zim shipping would be sold by the end of 1997"
  - Supports:
    - Netanyahu government privatisation plan for 13 state firms in 1997; Moshe Leon: speed over price

**[S5818]** Jewish Telegraphic Agency, 'Nationwide Strike Disrupts Public Services Across Israel' (23 Jul 1997) — https://www.jta.org/archive/nationwide-strike-disrupts-public-services-across-israel-2 — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "Bezek workers demanded that proceeds from the sale go to implementing wage, severance and pensions agreements with the government."
  - Supports:
    - Histadrut general strike in sympathy with Bezeq workers over the Merrill Lynch stake sale, Jul 1997; Amir Peretz sought a meeting with Netanyahu

**[S5819]** Jewish Telegraphic Agency, 'Sell-off of Bank Hapoalim Marks Israel's Biggest Privatization Act' (17 Sep 1997) — https://www.jta.org/archive/sell-off-of-bank-hapoalim-marks-israels-biggest-privatization-act-2 — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "has acquired a 43 percent stake in Bank Hapoalim"
  - Supports:
    - Arison group bought 43% of Bank Hapoalim (nationalised after the 1983 capital market crisis) for about $1.4bn, Sep 1997

**[S5820]** Jewish Telegraphic Agency, 'Israeli Legislators Form Group to Urge Lebanon Withdrawal' (10 Nov 1997) — https://www.jta.org/archive/israeli-legislators-form-group-to-urge-lebanon-withdrawal-2 — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "Israel should declare its intent to redeploy along the international border with Lebanon and set up an electronic fence along the border to ensure the safety of the northern settlements"
  - Supports:
    - Beilin, Ramon, Zvilli, Hazan, Zucker, Weinberg movement merged with the Four Mothers; more than 40 Israelis dead in Lebanon in 1997, Nov 1997

**[S5821]** Jewish Telegraphic Agency, 'News Analysis: Could Top Talk on Lebanon Lead to Israeli Withdrawal?' (18 Mar 1998) — https://www.jta.org/archive/news-analysis-could-top-talk-on-lebanon-lead-to-israeli-withdrawal-2 — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "Mordechai and Netanyahu still insist that there must be a linkage between an Israeli pullback and a southern redeployment of the Lebanese army to keep control."
  - Supports:
    - Mordechai's UN 425 offer, Sharon's phased unilateral withdrawal plan, 39 soldiers killed in the zone in 1997, Mar 1998

**[S5822]** Jewish Telegraphic Agency, 'Identity Card Compromise Could Stem Conversion Crisis' (26 Jan 1998) — https://www.jta.org/archive/identity-card-compromise-could-stem-conversion-crisis-2 — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "called for the Conservative and Reform movements to participate along with Orthodox representatives in conversion classes, but granted the Orthodox the sole right to carry out the conversions"
  - Supports:
    - Ne'eman Committee report to Netanyahu (23 Jan 1998) and Avraham Burg's identity-card alternative, Jan 1998

**[S5823]** Jewish Telegraphic Agency, 'News Analysis: Religious Pluralism Battle Erupts Anew on Two Fronts' (6 Jan 1999) — https://www.jta.org/archive/news-analysis-religious-pluralism-battle-erupts-anew-on-two-fronts-2 — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "Orthodox parties in the Knesset are attempting to revive the conversion bill"
  - Supports:
    - Orthodox parties' conversion bill to codify Orthodox monopoly; the Ne'eman compromise not accepted by the Chief Rabbinate, Jan 1999

**[S5824]** Jewish Telegraphic Agency, 'News Analysis: Dismantlement of Settlements Will Test Barak and Peace Process' (13 Oct 1999) — https://www.jta.org/archive/news-analysis-dismantlement-of-settlements-will-test-barak-and-peace-process-3 — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "The Cabinet on Sunday empowered Barak to decide how many of the 42 outposts will be dismantled."
  - Supports:
    - 42 hilltop outposts, Sneh's plan to remove 14 (seven illegal), Barak's preference for removal by the settlers themselves, Oct 1999

**[S5825]** Jewish Telegraphic Agency, 'News Analysis: Disturbing Images of Jew Vs. Jew Emerge from Eviction on West Bank' (11 Nov 1999) — https://www.jta.org/archive/news-analysis-disturbing-images-of-jew-vs-jew-emerge-from-eviction-on-west-bank — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "some 300 settlers were forcibly removed Wednesday by Israeli troops from an illegal hilltop outpost"
  - Supports:
    - Troops evicted about 300 settlers from the Havat Maon outpost on 10 Nov 1999; Katzover and Women in Green objections

**[S5826]** Jewish Telegraphic Agency, 'Israel's High Court Upholds Draft Deferments Arrangement' (21 Feb 2002) — https://www.jta.org/archive/israels-high-court-upholds-draft-deferments-arrangement — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "In April 2000, the Tal Commission put forward a plan to allow yeshiva students to decide for themselves whether to serve in the army."
  - Supports:
    - Tal Commission plan (Apr 2000); Shas's provisional extension law; petitioners Paritzky, Chazan and the Awakening Movement; about 30,000 deferments versus 400 in 1954, Feb 2002

**[S5827]** Jewish Telegraphic Agency, 'Some Religious Leaders Open to Discuss Military Deferments' (18 May 1998) — https://www.jta.org/archive/some-religious-leaders-open-to-discuss-military-deferments-2 — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "opposition leader Ehud Barak presented to the speaker of the Knesset a bill to draft yeshiva students"
  - Supports:
    - Barak's May 1998 bill capping yeshiva deferrals at 700 a year; Netanyahu's creation of the Tal committee; UTJ's Porush and Ravitz reactions

**[S5828]** Jewish Telegraphic Agency, 'Draft Deferrals for Yeshiva Students Sparking Secular-religious Tensions' (23 Jul 2002) — https://www.jta.org/archive/draft-deferrals-for-yeshiva-students-sparking-secular-religious-tensions — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "The bill calls for granting yeshiva students draft deferrals until age 22, when they will be given the opportunity to take a year off from studies to work without being drafted."
  - Supports:
    - Terms of the Tal Bill and the Katz Civil Guard amendment, Jul 2002

**[S5829]** Jewish Telegraphic Agency, 'Israeli Cabinet Oks Mass Aliyah for 18,000 Falash Mura in Ethiopia' (19 Feb 2003) — https://www.jta.org/archive/israeli-cabinet-oks-mass-aliyah-for-18000-falash-mura-in-ethiopia — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "On Sunday, the Cabinet approved a plan to immediately bring to Israel some 18,000 to 20,000 Falash Mura"
  - Supports:
    - Cabinet plan initiated by Interior Minister Eli Yishai (Shas), up to $2bn; Absorption Minister Edelstein opposed, Feb 2003

**[S5830]** Jewish Telegraphic Agency, 'Israelis and Jewish Groups Talk Numbers and Dollars on Falash Mura' (27 Nov 2003) — https://www.jta.org/archive/israelis-and-jewish-groups-talk-numbers-and-dollars-on-falash-mura — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "Poraz at the Knesset discussion capped the list of Falash Mura slated for emigration at 22,000, the amount counted by a census taken five years ago."
  - Supports:
    - Interior Minister Poraz's cap and timetable; NACOEJ and advocates asking for speed; about 2,500 arrivals a year, Nov 2003

**[S5831]** Jewish Telegraphic Agency, 'Unrecognized by Israel, Bedouin Villages in Negev Lack Resources' (4 Oct 2004) — https://www.jta.org/archive/unrecognized-by-israel-bedouin-villages-in-negev-lack-resources — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "The other half of Negev Bedouin live in the seven towns built for them by the government starting in 1966"
  - Supports:
    - About 130,000 Negev Bedouin, half in unrecognised villages; the government's recognition of nine villages; Prime Minister's Office and Interior Ministry views; Meir, Abu Rass and Abu Hani, Oct 2004

**[S5832]** Jewish Telegraphic Agency, 'Focus on Issues: Ethiopian Anger over Blood Bank Reveals Community's Deep Agony' (29 Jan 1996) — https://www.jta.org/archive/focus-on-issues-ethiopian-anger-over-blood-bank-reveals-communitys-deep-agony — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-1986 agent; page fetched with curl and a browser user-agent on 2026-10-13 and every cited quote checked verbatim against the page text.
  - Quote: "Israeli Health Minister Ephraim Sneh said last week that his ministry would continue its policy about blood donations from high-risk groups in order to protect public health."
  - Supports:
    - Magen David Adom discarded Ethiopian-donated blood; Health Ministry stance; Peres's apology and committee; Dr Maayan and Adiso Masala; 60,000 Ethiopian olim, 520 HIV-positive, Jan 1996

**[S5900]** JTA, 'With Moves on Hamas, Olmert Searches for Elusive Middle Ground', 21 Feb 2006 — https://www.jta.org/archive/with-moves-on-hamas-olmert-searches-for-elusive-middle-ground — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "freezing the transfer of tax moneys Israel collects for the Palestinians"
  - Supports:
    - Interim PM Olmert froze transfer of tax money to the Hamas-led Authority in Feb 2006; Shin Bet chief Diskin and national security adviser Eiland argued opposite lines

**[S5901]** JTA, 'If Annapolis fails, what then?', 19 Nov 2007 — https://www.jta.org/2007/11/19/israel/if-annapolis-fails-what-then — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "negotiations over a permanent peace deal will take place"
  - Supports:
    - Lieberman and Yishai threatened to leave the coalition if core issues were discussed at Annapolis; the process opened permanent-status talks

**[S5902]** JTA, 'Syria, Israel relaunching peace bid', 21 May 2008 — https://www.jta.org/2008/05/21/politics/syria-israel-relaunching-peace-bid — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "announced that they are resuming peace talks"
  - Supports:
    - Israel and Syria announced Turkish-mediated indirect talks in May 2008; Shas leader Yishai objected

**[S5903]** JTA, 'Syria, Israel edging closer to deal', 29 Apr 2008 — https://www.jta.org/2008/04/29/politics/syria-israel-edging-closer-to-deal — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "We could reach an Israel-Syria bilateral deal relatively quickly"
  - Supports:
    - Alon Liel of the Israel-Syria peace lobby argued a bilateral deal was reachable quickly with US help

**[S5904]** JTA, 'Labor joining Bibi: Kosher stamp or fig leaf?', 25 Mar 2009 — https://www.jta.org/2009/03/25/israel/labor-joining-bibi-kosher-stamp-or-fig-leaf — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "members voted 680-507 to join the coalition"
  - Supports:
    - Labor central committee voted 680-507 on 24 Mar 2009 to join Netanyahu's coalition; Livni set terms for Kadima

**[S5905]** JTA, 'U.S. Jewish right muted ahead of possible extension of settlement freeze', 14 Sep 2010 — https://www.jta.org/2010/09/14/united-states/u-s-jewish-right-muted-ahead-of-possible-extension-of-settlement-freeze — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "We can use the political leverage we have within the political system to make the extension of the moratorium impossible"
  - Supports:
    - Yesha Council chairman Danny Dayan and ZOA's Morton Klein opposed extending the freeze; Abbas threatened to quit talks

**[S5906]** JTA, 'In ad, J Street presses Bibi on freeze', 23 Sep 2010 — https://www.jta.org/2010/09/23/united-states/in-ad-j-street-presses-bibi-on-freeze — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "President Obama on Sept. 23 reiterated his call on Netanyahu to extend a 10-month partial freeze"
  - Supports:
    - Obama and J Street urged extension of the 10-month partial freeze expiring 26 Sep 2010

**[S5907]** JTA, 'U.S. Drops Settlement-Freeze Push', 7 Dec 2010 — https://www.jta.org/2010/12/07/ny/u-s-drops-settlement-freeze-push — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "The Obama administration prepared an offer of security incentives to entice Netanyahu into extending the freeze"
  - Supports:
    - US offer of about $3bn in security incentives for a freeze extension; Netanyahu balked; US dropped the push Dec 2010

**[S5908]** JTA, 'After Israel's deadly fire, mourning, vows to rebuild and finger pointing', 6 Dec 2010 — https://www.jta.org/2010/12/06/israel/after-israels-deadly-fire-mourning-vows-to-rebuild-and-finger-pointing — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "echoing a call for a state commission of inquiry to examine who bears responsibility for the failures of the Israeli fire service"
  - Supports:
    - Haaretz editorial and others called for a state commission after the Carmel fire; Interior Minister Yishai blamed under-funding

**[S5909]** JTA, 'Report: Fire services are Israel's weak link', 8 Dec 2010 — https://www.jta.org/2010/12/08/israel/report-fire-services-are-israels-weak-link — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "to establish a national fire and rescue authority"
  - Supports:
    - State Comptroller Lindenstrauss called on the government to carry out its decision to set up a national fire and rescue authority

**[S5910]** JTA, 'Report on Carmel Forest fire blames government officials', 20 Jun 2012 — https://www.jta.org/2012/06/20/israel/report-on-carmel-forest-fire-blames-government-officials — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "A special report by Israel's state comptroller on the 2010 Carmel Forest fire blamed several government officials"
  - Supports:
    - State Comptroller report of June 2012 on the Carmel fire; 44 died

**[S5911]** JTA, 'Cottage cheese becomes symbol of Israeli frustration with rising food prices', 20 Jun 2011 — https://www.jta.org/2011/06/20/israel/cottage-cheese-becomes-symbol-of-israeli-frustration-with-rising-food-prices — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "for the government to reinstitute price controls"
  - Supports:
    - Knesset Economic Affairs Committee urged price controls; Finance Minister Steinitz threatened to break the dairy monopoly; cottage cheese prices up nearly 40 percent in three years

**[S5912]** JTA, 'Boycott spurs Tnuva to drop cottage cheese prices', 29 Jun 2011 — https://www.jta.org/2011/06/29/israel/boycott-spurs-tnuva-to-drop-cottage-cheese-prices — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "agreed to lower cottage cheese prices by about 20 percent following a nationwide boycott"
  - Supports:
    - Tnuva cut cottage cheese prices about 20 percent on 29 Jun 2011 after a boycott

**[S5913]** JTA, 'Israeli Cabinet OKs exporting 40 percent of newly found natural gas', 23 Jun 2013 — https://www.jta.org/2013/06/23/israel/israeli-cabinet-oks-exporting-40-percent-of-newly-found-natural-gas — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "agreed to retain 540 billion cubic meters for Israeli consumption"
  - Supports:
    - Cabinet kept 540 bcm for domestic use (about 40 percent exportable), 13 percent less export than the Tzemach Commission proposed; Yachimovich threatened a court petition

**[S5914]** Globes, 'Tzemach committee to recommend allowing gas exports', 2011 — https://en.globes.co.il/en/article-1000734721 — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "permitting exports will encourage the entry of additional suppliers and develop competition"
  - Supports:
    - Tzemach committee accepted the Finance Ministry's export argument; Energy Ministry wanted about 400 bcm retained

**[S5915]** JTA, 'Israel formally suspends talks with Palestinians', 24 Apr 2014 — https://www.jta.org/2014/04/24/united-states/israel-formally-suspends-talks-with-palestinians — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "Israel will not negotiate with a Palestinian government backed by Hamas"
  - Supports:
    - Cabinet unanimously suspended talks on 24 Apr 2014 after the Fatah-Hamas accord

**[S5916]** JTA, 'With peace talks stalled, Israelis and Palestinians resort to old moves', 28 Apr 2014 — https://www.jta.org/2014/04/28/politics/with-peace-talks-stalled-israelis-and-palestinians-resort-to-old-moves — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "Bennett has encouraged Netanyahu to annex all areas of the West Bank that contain Jewish settlements"
  - Supports:
    - Bennett urged annexation of settled areas after the talks collapsed

**[S5917]** JTA, 'Palestinian official: Reconciliation hinges on Hamas recognizing Israel', 25 Apr 2014 — https://www.jta.org/2014/04/25/israel/palestinian-official-reconciliation-hinges-on-hamas-recognizing-israel — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "urged Israel and the Palestinians to make the compromises needed to forge ahead with peace talks"
  - Supports:
    - Secretary of State Kerry urged both sides to continue the talks

**[S5918]** JTA, 'Israel Facing Agonizing Choice On Iran Deal', 15 Jul 2015 — https://www.jta.org/2015/07/15/ny/israel-facing-agonizing-choice-on-iran-deal — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "employ all diplomatic means to prevent the confirmation of the agreement"
  - Supports:
    - Deputy FM Hotovely vowed all diplomatic means; Yadlin and Pinkas urged a side agreement and a quiet security-aid package

**[S5919]** JTA, 'Netanyahu's office defends vote to freeze Western Wall agreement', 26 Jun 2017 — https://www.jta.org/2017/06/26/israel/netanyahus-office-defends-vote-to-freeze-western-wall-agreement — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "the Cabinet voted to freeze an agreement that would have made a permanent space there for women and men to pray as they wish"
  - Supports:
    - Cabinet froze the Jan 2016 Western Wall compromise on 25 Jun 2017; Liberman and one other minister voted against

**[S5920]** JTA, 'Suspension of Western Wall deal leaves Jewish leaders feeling betrayed', 25 Jun 2017 — https://www.jta.org/2017/06/25/united-states/suspension-of-western-wall-deal-leaves-jewish-leaders-feeling-betrayed — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "The suspension is a result of pressure from Netanyahu's haredi Orthodox partners"
  - Supports:
    - The suspension followed haredi coalition pressure; Jewish Federations of North America and Reform leaders protested

**[S5921]** JTA, 'Israeli Knesset passes law that will keep supermarkets, businesses closed on Shabbat', 9 Jan 2018 — https://www.jta.org/2018/01/09/israel/israeli-knesset-passes-law-that-will-keep-supermarkets-businesses-closed-on-shabbat — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "approved a bill that will keep supermarkets and other businesses closed on the Sabbath"
  - Supports:
    - Mini-markets bill passed 58-57 on 9 Jan 2018; Deri defended it; Meretz's Galon petitioned the Supreme Court

**[S5922]** JTA, 'Hours After Announcing It, Netanyahu Suspends Deal To Let 16,000 Migrants Stay', 2 Apr 2018 — https://www.jta.org/2018/04/02/ny/hours-after-announcing-it-netanyahu-suspends-deal-to-let-16000-migrants-stay — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "This agreement will allow for the departure from Israel of 16,250 migrants to developed countries"
  - Supports:
    - UNHCR deal announced and suspended on 2 Apr 2018: 16,250 to leave for Western states, a similar number to stay; south Tel Aviv residents objected

**[S5923]** JTA, 'Israel Scraps Deportations Of All African Asylum Seekers, Extends Visas', 24 Apr 2018 — https://www.jta.org/2018/04/24/ny/israel-scraps-deportations-of-all-african-asylum-seekers-extends-visas — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "there is no possibility of implementing involuntary deportations to a third country"
  - Supports:
    - State told the High Court on 24 Apr 2018 it had scrapped the deportation plan

**[S5924]** JTA, 'Cabinet affirms demolition of Bedouin village, but grants extension for negotiations with residents', 21 Oct 2018 — https://www.jta.org/2018/10/21/israel/cabinet-affirms-demolition-bedouin-village-grants-extension-negotiations-residents — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "Khan al-Ahmar will be evacuated"
  - Supports:
    - Security Cabinet affirmed the demolition of Khan al-Ahmar (180 residents) but granted time to negotiate; Liberman and Jewish Home objected to the delay

**[S5925]** JTA, 'Netanyahu condemns violence in Arab sector and pledges more police to fight it', 6 Oct 2019 — https://www.jta.org/quick-reads/netanyahu-condemns-violence-in-arab-sector-and-pledges-more-police-to-fight-it — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "pledged to allocate additional police manpower to fight against the phenomenon"
  - Supports:
    - Netanyahu pledged more police after Arab-sector strikes; Joint List's Odeh demanded a plan of action; at least 71 Arab citizens killed in 2019 to that date

**[S5926]** JTA, 'As most Israeli adults get vaccinated from COVID, some wonder when life will go back to normal', 12 Feb 2021 — https://www.jta.org/2021/02/12/israel/as-most-israeli-adults-get-vaccinated-from-covid-some-wonder-when-life-will-go-back-to-normal — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "The government is considering a series of regulations that will limit entry to places like gyms, concerts and museums"
  - Supports:
    - Green-passport rules and a retailers' revolt in Feb 2021; vaccination 70 percent among haredim over 60 and 64 percent among Arab Israelis

**[S5927]** JTA, 'Israel to join UN condemnation of Russian invasion as Ukraine evacuation and aid efforts continue', 28 Feb 2022 — https://www.jta.org/2022/02/28/israel/israel-to-join-un-condemnation-of-russian-invasion-as-ukraine-evacuation-and-aid-efforts-continue — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "has pushed for sharp condemnation of Russia"
  - Supports:
    - Lapid pushed for sharp condemnation of Russia while Bennett was more hesitant; Bennett rejected Zelensky's request for military supplies

**[S5928]** JTA, 'Israeli PM Bennett meets with Putin in Moscow to discuss Ukraine, then phones Zelensky', 5 Mar 2022 — https://www.jta.org/2022/03/05/global/israeli-pm-bennett-meets-with-putin-in-moscow-to-discuss-ukraine-then-phones-zelensky — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "declined to follow Western countries in sending weaponry to aid Ukraine"
  - Supports:
    - Bennett mediated between Putin and Zelensky without sending weapons; Russia's military presence in Syria constrains Israel

**[S5929]** JTA, 'Tel Aviv's long-awaited light rail system is finally opening - but not on Shabbat', 17 Aug 2023 — https://www.jta.org/2023/08/17/israel/tel-avivs-long-awaited-light-rail-system-is-finally-opening-but-not-on-shabbat — accessed: 2026-10-13 — provenance: opened
  - Note: Added by the v3 content-2006 data agent; page opened with a browser user-agent and the quote checked on 2026-10-13.
  - Quote: "We will uphold the status quo, according to which the train will not operate on Shabbat"
  - Supports:
    - Transport Minister Regev reversed Michaeli's Shabbat-service promise; Huldai boycotted the opening; Bnei Brak protested the earlier promise

**[S5940]** JTA, 'U.S. Pledges to Help Israel Find Alternative to Discontinued Lavi', 1 September 1987 — https://www.jta.org/archive/u-s-pledges-to-help-israel-find-alternative-to-discontinued-lavi — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-story builder; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "The Cabinet vote culminated months of bitter debate and came under pressure from the United States, the Israel Finance and Defense ministries and many Israeli military officers."
  - Supports:
    - 30 Aug 1987: the cabinet voted 12-11 to discontinue the Lavi under US, Finance and Defence Ministry pressure; the US offered F-16 co-production and help with the costs

**[S5941]** JTA, 'The Lavi Fighter Plane Project Remains a Contentious Political Issue', 7 October 1987 — https://www.jta.org/archive/the-lavi-fighter-plane-project-remains-a-contentious-political-issue — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-story builder; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "Moshe Arens, a Likud-Herut Minister-Without-Portfolio who resigned from the government in protest against the Lavi decision"
  - Supports:
    - Likud was determined to preserve the Lavi; Moshe Arens resigned in protest at its cancellation; about 3,000 IAI employees faced dismissal

**[S5942]** JTA, 'Bonn Authorizes 140 Million Mark Development Loan for Israel', 5 December 1983 — https://www.jta.org/archive/bonn-authorizes-140-million-mark-development-loan-for-israel — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-story builder; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "In 1976, the then Israeli Foreign Minister, Yigal Allon, sought to have repayment on the loans extended beyond the annual terms because of the burden on Israel’s economy."
  - Supports:
    - West German development loans to Israel began in 1965 with diplomatic relations; Allon's 1976 request to stretch repayments was refused; Schmidt extended the terms in 1979

**[S5943]** JTA, 'New Major Mideast Peace Initiative: Peres is Meeting with Hassan', 23 July 1986 — https://www.jta.org/archive/new-major-mideast-peace-initiative-peres-is-meeting-with-hassan — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-story builder; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "MK Geula Cohen of the Tehiya Party declared Tuesday, “Shimon Peres must be stopped before it is too late."
  - Supports:
    - July 1986: Peres met King Hassan II at Ifrane; Syria broke relations with Morocco; Tehiya's Geula Cohen opposed the trip

**[S5944]** JTA, 'U.S. Move Divides Israelis; New Elections Are Possible', 16 December 1988 — https://www.jta.org/archive/u-s-move-divides-israelis-new-elections-are-possible — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-story builder; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "Ezer Weizman, a Laborite minister without portfolio, called the American move “a new beginning (that) could lead to a happy ending.”"
  - Supports:
    - Dec 1988: Israel expressed regret at the US decision to open a dialogue with the PLO; Shamir's spokesman: no dealings with the PLO; Weizman welcomed it

**[S5945]** JTA, 'After US assurances, Netanyahu and Gantz drop objections to military sales to UAE', 23 October 2020 — https://www.jta.org/2020/10/23/united-states/amid-middle-east-peace-deals-israel-and-the-us-reassert-commitment-to-israels-qualitative-military-edge — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-story builder; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "Gantz alluded to the underlying reason for the appearance: Israel is opposed to the sale of F-35 stealth fighters to the United Arab Emirates"
  - Supports:
    - Oct 2020: after a US-Israel declaration on Israel's qualitative military edge, Netanyahu and Gantz said they would not oppose the F-35 sale to the UAE

**[S5946]** JTA, 'Knesset Votes Overwhelmingly to Ratify Treaty with Jordan', October 1994 (archive page dated 1 January 1994) — https://www.jta.org/archive/knesset-votes-overwhelmingly-to-ratify-treaty-with-jordan — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-story builder; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "Likud faction leader Moshe Katzav welcomed the peace with Jordan, but raised several reservations about the treaty."
  - Supports:
    - The Knesset approved the Jordan treaty 105-3 with 6 abstentions; Netanyahu supported it; Katzav objected that it did not oblige Jordan to outlaw Hamas and to its clause on Jordan's role at Muslim holy sites in Jerusalem

**[S5947]** Foreign Relations of the United States, 1949, Vol. VI, doc. 671: The Minister in Syria (Keeley) to the Secretary of State, Damascus, 19 May 1949 — https://history.state.gov/historicaldocuments/frus1949v06/d671 — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-story builder; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "Prime Minister Ben-Gurion’s uncompromising refusal (Tel Aviv Embtel 342 May 9 to Department)"
  - Supports:
    - May 1949: Syrian leader Husni al-Za'im had volunteered to meet Ben-Gurion; Ben-Gurion refused Bunche's invitation to meet him

**[S5948]** Foreign Relations of the United States, 1949, Vol. VI, doc. 690: The United States Representative at the United Nations (Austin) to the Secretary of State, New York, 25 May 1949 — https://history.state.gov/historicaldocuments/frus1949v06/d690 — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-story builder; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "he will address a renewed appeal to Ben-Gurion and Zaim to negotiate the armistice agreement personally, offering UN assistance for this purpose"
  - Supports:
    - May 1949: UN mediator Ralph Bunche planned to appeal to Ben-Gurion and Za'im to negotiate the Syrian armistice personally

**[S5949]** JTA, 'Ford: U.S. Will Supply Israel with "Substantial Amounts" of Arms; No U.S. Commitments for Pershings', 17 September 1975 — https://www.jta.org/archive/ford-u-s-will-supply-israel-with-substantial-amounts-of-arms-no-u-s-commitments-for-pershigs — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-story builder; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "They are on the shopping list between the U.S. and Israel and they will be discussed with representatives of the Israel government."
  - Supports:
    - Sept 1975: Ford promised substantial US arms after Sinai II; Pershing missiles and F-16s were on Israel's shopping list but not firm commitments; Defence Minister Peres came for arms talks

**[S5950]** UN Human Rights Council, Independent International Commission of Inquiry on the Occupied Palestinian Territory, including East Jerusalem, and Israel, 'Detailed findings on the attacks of 7 October 2023 and ensuing violations', A/HRC/56/CRP.3, June 2024 — https://www.ohchr.org/sites/default/files/documents/hrbodies/hrcouncil/sessions-regular/session56/a-hrc-56-crp-3.pdf — accessed: 2026-10-13 — provenance: opened
  - Note: Added for the 7 October memorial ending (ending_oct7.json). Page fetched with curl and a browser user-agent on 2026-10-13; every quote checked verbatim against the raw page text (HTML tags stripped, or pdftotext for PDFs).
  - Quote: "at 06:30 on Saturday 7 October, Palestinian armed groups launched a heavy barrage of rockets and mortar fire at Israel"
  - Supports:
    - Date: Saturday 7 October 2023; the rocket barrage began at 06:30 that day
    - Hamas named the offensive 'Operation Al-Aqsa Flood'
    - Rockets: early IDF count of 2,200 by 10:26 (barrage began 06:30)
    - About 3,000 militants planned for the infiltration (plus 1,500 in support)
    - Bulldozers widened gaps in the fence
    - Motorbikes and pick-up trucks
    - Infiltration by boats (rubber boats at Zikim)
    - Kerem Shalom and Erez Crossing positions were among the sites attacked
    - The fence was breached in many places (at least 29 per the COI)
    - Kibbutzim occupied; homes burned; people killed and abducted
    - Hostages taken from kibbutz Nir Oz, ages 9 months to 85 years
    - Nova festival: COI figure, 379 killed at the site, near Re'im or adjacent; at least 364 attendees
    - Hostages included women, children, older people and soldiers

**[S5951]** UN Office of the Special Representative of the Secretary-General on Sexual Violence in Conflict (Pramila Patten), 'Mission report: Official visit to Israel and the occupied West Bank, 29 January - 14 February 2024', 4 March 2024 — https://www.un.org/sexualviolenceinconflict/wp-content/uploads/2024/03/report/mission-report-official-visit-of-the-office-of-the-srsg-svc-to-israel-and-the-occupied-west-bank-29-january-14-february-2024/20240304-Israel-oWB-CRSV-report.pdf — accessed: 2026-10-13 — provenance: opened
  - Note: Added for the 7 October memorial ending (ending_oct7.json). Page fetched with curl and a browser user-agent on 2026-10-13; every quote checked verbatim against the raw page text (HTML tags stripped, or pdftotext for PDFs).
  - Quote: "burnt alive in their homes as they tried to hide in their safe rooms"
  - Supports:
    - Victims burnt alive in their homes
    - Kibbutz Be'eri: rows of houses burnt
    - Mutilation of corpses, sexual violence, abduction of hostages
    - Sexual violence: reasonable grounds to believe, incl. rape and gang rape, in at least three locations
    - Sexual violence and sexualized torture against hostages
    - Mutilation of bodies (widespread, incl. attempted decapitation)
    - Caveat: specific genital-mutilation claims could not be verified by the mission

**[S5952]** JTA, 'Hundreds of Israelis dead, wounded as Hamas launches major attack; We are at war, Netanyahu says', 7 Oct 2023 — https://www.jta.org/2023/10/07/israel/israelis-dead-wounded-as-hamas-launches-major-attack-we-are-at-war-netanyahu-says — accessed: 2026-10-13 — provenance: opened
  - Note: Added for the 7 October memorial ending (ending_oct7.json). Page fetched with curl and a browser user-agent on 2026-10-13; every quote checked verbatim against the raw page text (HTML tags stripped, or pdftotext for PDFs).
  - Quote: "a dramatic surge of violence that began while Israelis were celebrating the Simchat Torah holiday and Shabbat"
  - Supports:
    - It fell on Shabbat and the festival of Simchat Torah

**[S5953]** Times of Israel liveblog, 'Oct. 7: Hamas terrorists burst through border, slaughter Israelis in their homes', 7 Oct 2023 — https://www.timesofisrael.com/liveblog-october-7-2023/ — accessed: 2026-10-13 — provenance: opened
  - Note: Added for the 7 October memorial ending (ending_oct7.json). Page fetched with curl and a browser user-agent on 2026-10-13; every quote checked verbatim against the raw page text (HTML tags stripped, or pdftotext for PDFs).
  - Quote: "Hamas says it has launched 5,000 rockets at Israel in an early morning surprise attack it calls “Operation Al-Aqsa Flood.”"
  - Supports:
    - Hamas named the offensive 'Operation Al-Aqsa Flood' (contemporaneous report of the Deif statement)
    - Rockets in the opening barrage: Hamas claimed over 5,000

**[S5954]** Times of Israel, 'Nova families gather to mourn loved ones killed when festival became a bloodbath' — https://www.timesofisrael.com/nova-families-gather-to-mourn-loved-ones-killed-when-festival-became-a-bloodbath/ — accessed: 2026-10-13 — provenance: opened
  - Note: Added for the 7 October memorial ending (ending_oct7.json). Page fetched with curl and a browser user-agent on 2026-10-13; every quote checked verbatim against the raw page text (HTML tags stripped, or pdftotext for PDFs).
  - Quote: "Israeli authorities say at least 364 people were killed at the Nova festival alone"
  - Supports:
    - Nova festival: Israeli authorities' current figure, at least 364 killed

**[S5955]** Times of Israel, '3 years of war: Data shows IDF hit 100,000 targets as 31,500 projectiles fired at Israel', Oct 2026 — https://www.timesofisrael.com/3-years-of-war-data-shows-idf-hit-100000-targets-as-31500-projectiles-fired-at-israel/ — accessed: 2026-10-13 — provenance: opened
  - Note: Added for the 7 October memorial ending (ending_oct7.json). Page fetched with curl and a browser user-agent on 2026-10-13; every quote checked verbatim against the raw page text (HTML tags stripped, or pdftotext for PDFs).
  - Quote: "at least 5,000 on October 7 alone"
  - Supports:
    - Rockets: IDF later figure of at least 5,000 fired from Gaza on 7 October

**[S5956]** Ynetnews, 'IDF meta-investigation finds six major failures behind Oct. 7 attack' — https://www.ynetnews.com/article/rkt4boyxwl — accessed: 2026-10-13 — provenance: opened
  - Note: Added for the 7 October memorial ending (ending_oct7.json). Page fetched with curl and a browser user-agent on 2026-10-13; every quote checked verbatim against the raw page text (HTML tags stripped, or pdftotext for PDFs).
  - Quote: "did not prepare adequate defenses against low-altitude threats such as drones and motorized paragliders — and in the navy, which failed to defend the coastline as Hamas terrorists infiltrated by sea"
  - Supports:
    - Motorized paragliders and infiltration by sea

**[S5957]** Times of Israel / JTA, 'Jews around the world rethink joyous Simhat Torah holiday on mournful anniversary' — https://www.timesofisrael.com/jews-around-the-world-rethink-joyous-simhat-torah-holiday-on-mournful-anniversary/ — accessed: 2026-10-13 — provenance: opened
  - Note: Added for the 7 October memorial ending (ending_oct7.json). Page fetched with curl and a browser user-agent on 2026-10-13; every quote checked verbatim against the raw page text (HTML tags stripped, or pdftotext for PDFs).
  - Quote: "Shemini Atzeret — which falls on the first day, when the massacre occurred"
  - Supports:
    - It fell on Shemini Atzeret (observed on the same day as Simchat Torah in Israel)

**[S5958]** Human Rights Watch, 'October 7 Crimes Against Humanity, War Crimes by Hamas-led Groups', 17 Jul 2024 — https://www.hrw.org/news/2024/07/17/october-7-crimes-against-humanity-war-crimes-hamas-led-groups — accessed: 2026-10-13 — provenance: opened
  - Note: Added for the 7 October memorial ending (ending_oct7.json). Page fetched with curl and a browser user-agent on 2026-10-13; every quote checked verbatim against the raw page text (HTML tags stripped, or pdftotext for PDFs).
  - Quote: "The armed groups took as hostages 251 civilians and Israeli security force personnel and took them to Gaza."
  - Supports:
    - 251 hostages taken to Gaza

**[S5959]** Ynetnews, 'Nova music festival massacre probe: IDF missed warning signs, one cop saved hundreds' — https://www.ynetnews.com/article/by00khoqpkg — accessed: 2026-10-13 — provenance: opened
  - Note: Added for the 7 October memorial ending (ending_oct7.json). Page fetched with curl and a browser user-agent on 2026-10-13; every quote checked verbatim against the raw page text (HTML tags stripped, or pdftotext for PDFs).
  - Quote: "In total, 378 people—civilians, police officers and soldiers—were killed in and around the Nova site, and 44 others were abducted into Gaza."
  - Supports:
    - Nova festival: IDF probe counts 378 killed in and around the site

**[S5960]** Jerusalem Post (Yonah Jeremy Bob, Elliot Kaufman), 'No contact for hours: Behind Netanyahu, IDF's failure to stop Hamas's Oct. 7 massacre', 10 Feb 2026 — https://www.jpost.com/israel-news/politics-and-diplomacy/article-886242 — accessed: 2026-10-13 — provenance: opened
  - Note: Added for the 7 October memorial ending (ending_oct7.json). Page fetched with curl and a browser user-agent on 2026-10-13; every quote checked verbatim against the raw page text (HTML tags stripped, or pdftotext for PDFs).
  - Quote: "When Hamas fired some 3,700 rockets, and its invasion force of around 5,600 men penetrated Israel's border at 119 different spots"
  - Supports:
    - Rockets: later Israeli analysis puts the barrage at about 3,700

**[S5961]** BBC News, 'What is Hamas and why is it fighting with Israel in Gaza?' — https://www.bbc.com/news/world-middle-east-67039975 — accessed: 2026-10-13 — provenance: opened
  - Note: Added for the 7 October memorial ending (ending_oct7.json). Page fetched with curl and a browser user-agent on 2026-10-13; every quote checked verbatim against the raw page text (HTML tags stripped, or pdftotext for PDFs).
  - Quote: "killing about 1,200 people and taking 251 hostages"
  - Supports:
    - 251 hostages (BBC)

**[S5962]** JTA, 'Dayan: Israel Will Continue to Oppose U.S. Package Plane Deal', 26 April 1978 — https://www.jta.org/archive/dayan-israel-will-continue-to-oppose-u-s-package-plane-deal — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-story builder; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "Foreign Minister Moshe Dayan who left for talks in Washington today, declared prior to his departure that Israel will continue to oppose the Carter Administration’s proposed aircraft package deal linking the sale of advanced warplanes to Israel with similar sales to Egypt and Saudi Arabia."
  - Supports:
    - April 1978: Israel opposed Carter's package linking F-15/F-16 sales to Israel with sales to Egypt and Saudi Arabia

**[S5963]** JTA, 'Laser beams, Saudis and the "Jewish Olympics": A preview of Biden's Israel trip', 11 July 2022 — https://www.jta.org/2022/07/11/politics/laser-beams-saudis-and-the-jewish-olympics-a-preview-of-bidens-israel-trip — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-story builder; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "Israel will introduce Biden to its still-developing “Iron Beam” system, which in testing has shown that it will likely be able to down missiles with laser beams"
  - Supports:
    - July 2022: Iron Beam was still in development; tests suggested it could down missiles with lasers

**[S5964]** JTA, 'In appeal to Israel, Zelensky invokes the "final solution"', 20 March 2022 — https://www.jta.org/2022/03/20/politics/in-appeal-to-israel-zelensky-invokes-the-final-solution-you-cannot-mediate-between-good-and-evil — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-story builder; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "called on it to deliver to Ukraine batteries of its Iron Dome anti-missile system"
  - Supports:
    - 20 Mar 2022: Zelensky asked the Knesset for Iron Dome batteries and criticised Israel's mediation without picking a side

**[S5965]** JTA, 'Egypt Stipulates Three Conditions for Returning Its Envoy to Israel', 9 August 1984 — https://www.jta.org/archive/egypt-stipulates-three-conditions-for-returning-its-envoy-to-israel — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-story builder; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "The Egyptian Ambassador in Israel was recalled to Cairo in September 1982 after the Sabra and Shatila massacres."
  - Supports:
    - Egypt recalled its ambassador from Israel in September 1982 and set conditions (Lebanon withdrawal, Palestinian progress, Taba) for his return

**[S5966]** JTA, 'Solid Achievement at the Summit: Improved Bilateral Israeli-Egyptian Relations and Egyptian Ambassador', 15 September 1986 — https://www.jta.org/archive/solid-achievement-at-the-summit-improved-bilateral-israeli-egyptian-relations-and-egyptian-ambassad — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-story builder; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "Egypt will have an Ambassador in Tel Aviv for the first time since 1982."
  - Supports:
    - Sept 1986: after the Peres-Mubarak Alexandria summit Egypt appointed Mohammed Bassiouny ambassador to Israel

**[S5967]** JTA, 'Clinton-Assad Summit Fails, No New Peace Talks Scheduled', 27 March 2000 — https://www.jta.org/archive/clinton-assad-summit-fails-no-new-peace-talks-scheduled — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-story builder; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "It does not appear that Israeli-Syrian negotiations will resume any time soon."
  - Supports:
    - 26 Mar 2000: the Clinton-Assad summit in Geneva failed; no date for resuming Israeli-Syrian talks

**[S5968]** JTA (Ami Eden), 'Davos faceoff: Peres vs. Erdogan', 30 January 2009 — https://www.jta.org/2009/01/30/culture/davos-faceoff-peres-vs-erdogan-updated — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-story builder; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "the Turkish prime minister made news by walking off the stage near the end"
  - Supports:
    - 29 Jan 2009: Turkish Prime Minister Erdogan walked off the Davos stage after a clash with Israeli President Peres

**[S5969]** JTA, 'Burgas attack a sign of Hezbollah's potency, but could Syria's problems hinder its future?', 24 July 2012 — https://www.jta.org/2012/07/23/israel/burgas-attack-a-sign-of-hezbollahs-potency-but-could-syrias-problems-hinder-its-future — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-story builder; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "the countries technically remain in a state of war — but the Syrian regime has kept its border with Israel mostly quiet for nearly 40 years"
  - Supports:
    - 2012: Israel and Syria technically remained at war, with a mostly quiet border for nearly 40 years, while the Assad regime faced a serious revolt

**[S5970]** JTA, 'Begin Defends Decision to Legalize 3 Settlements on West Bank; Regrets Rebuke by Vance; Says West Ba', July 28, 1977 — https://www.jta.org/archive/begin-defends-decision-to-legalize-3-settlements-on-west-bank-regrets-rebuke-by-vance-says-west-ba — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-content builder; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "Carter told reporters that he backed the State Department's condemnation of Israel's action on the settlements."
  - Supports:
    - 28 Jul 1977: Begin defended legalising Ofra, Maale Edumim and Elon Moreh after Vance's rebuke; Carter backed the State Department condemnation

**[S5971]** JTA, 'Civil Marriages Bill Postponed; Meir Warns Cabinet Would Resign If Alignment Discipline Is Violated', June 22, 1972 — https://www.jta.org/archive/civil-marriages-bill-postponed-meir-warns-cabinet-would-resign-if-alignment-discipline-is-violated — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-content builder; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "Mrs. Meir replied that the bill was a "clear violation" of the status quo."
  - Supports:
    - 22 Jun 1972: Hausner introduced the limited civil marriage bill with Mapam support; Meir threatened to resign; the vote was postponed at Mapam's request

**[S5972]** JTA, 'State List to Present Civil Marriage Bill; ILP Postpones Its Bill for a Year', December 5, 1972 — https://www.jta.org/archive/state-list-to-present-civil-marriage-bill-ilp-postpones-its-bill-for-a-year — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-content builder; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "The announcement followed a decision by the Independent Liberal Party last week to postpone Knesset action on the controversial Hausner civil marriages bill for one year"
  - Supports:
    - Dec 1972: the Independent Liberal convention voted 240-160 to give Chief Rabbi Goren a year to find halachic solutions

**[S5973]** JTA, 'Debate on Palestinian Question Continues in Knesset; Dayan Proposes 4 Principles on West Bank', July 24, 1974 — https://www.jta.org/archive/debate-on-palestinian-question-continues-in-knesset-dayan-proposes-4-principles-on-west-bank — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-content builder; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "Allon stated further that Israel could no longer be accused by its critics of ignoring the Palestinian problem"
  - Supports:
    - 24 Jul 1974: four Knesset motions against the Cabinet statement on the Palestinian question; Allon, Dayan, Eliad, Tamir and Raphael positions

**[S5974]** JTA, 'Israel Designates 6 Palestinian Rights Groups as Terrorist Organizations, Irking US and Human Rights Orgs', October 24, 2021 — https://www.jta.org/2021/10/24/israel/israel-designates-6-palestinian-rights-groups-as-terrorist-organizations-irking-us-and-human-rights-orgs — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-content builder; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "Israeli Defense Minister Benny Gantz announced that Israel's government will consider six leading Palestinian rights organizations operating in the West Bank as terrorist groups"
  - Supports:
    - 22-24 Oct 2021: Gantz designated six Palestinian groups; the US State Department asked Israel to clarify; Human Rights Watch, Amnesty and the New Israel Fund condemned it; NGO Monitor welcomed it

**[S5975]** JTA, 'Biden Administration: Israel Has Yet to Justify Shuttering of Palestinian Human Rights Groups', August 18, 2022 — https://www.jta.org/2022/08/18/united-states/biden-administration-israel-has-yet-to-justify-shuttering-of-palestinian-human-rights-groups — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-content builder; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "Israel has yet to show sufficient cause for its plans, the U.S. State Department said Thursday."
  - Supports:
    - 18 Aug 2022: Israeli troops raided seven of the groups' offices in Ramallah; the US said Israel had not substantiated its allegations

**[S5979]** JTA, 'Netanyahu Defends His Pending Far-Right Coalition: Two Hands Firmly on the Steering Wheel', December 15, 2022 — https://www.jta.org/2022/12/15/israel/netanyahu-defends-his-pending-far-right-coalition-two-hands-firmly-on-the-steering-wheel — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-content builder; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "Netanyahu said he granted Ben-Gvir the role of head of police because "the erosion of internal security in Israel" is "a big, big issue""
  - Supports:
    - 15 Dec 2022: Netanyahu defended making Ben-Gvir national security minister; former ministers and police chiefs warned of a "police state"

**[S5980]** JTA, 'Israeli Coalition Deal Gives Far-Right's Ben-Gvir Control Over the Police, Including in the West Bank', November 25, 2022 — https://www.jta.org/2022/11/25/israel/israeli-coalition-deal-gives-far-rights-ben-gvir-control-over-the-police-including-in-the-west-bank — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-content builder; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "The deal would expand the ministry of internal security, the old name of the cabinet position in charge of the police, into the ministry of national security"
  - Supports:
    - 25 Nov 2022: Likud-Otzma Yehudit deal expands the internal security ministry into a national security ministry with authority over the Border Police in the West Bank

**[S5981]** JTA, 'Liberals Decide to Force Issue of Limited Civil Marriage in Israel', June 28, 1972 — https://www.jta.org/archive/liberals-decide-to-force-issue-of-limited-civil-marriage-in-israel — accessed: 2026-10-14 — provenance: opened
  - Note: Added by the fix3-content builder; page fetched with curl and a browser user-agent and the quote checked verbatim in the page text on 2026-10-14.
  - Quote: "It is bitterly opposed by the religious parties whose position is backed by Premier Meir."
  - Supports:
    - 28 Jun 1972: Independent Liberals decide to force a Knesset vote on the Hausner bill; the religious parties and Meir oppose it

**[S5990]** Hebrew Wikipedia, 'הפרטה בישראל' (Privatisation in Israel), revision of 2026 — https://he.wikipedia.org/wiki/%D7%94%D7%A4%D7%A8%D7%98%D7%94_%D7%91%D7%99%D7%A9%D7%A8%D7%90%D7%9C — accessed: 2026-10-14 — provenance: opened
  - Note: Added by fix3-econ (v3 fix round) for the privatisation lever (data/fiscal.json). Page fetched with curl on 2026-10-14; every quote used in fiscal.json was checked verbatim against the page text (progress/fix3_econ/src/he_hafrata.txt).
  - Quote: "בין השנים 1962–1977 נמכרו 64 חברות, 25 חברות נסגרו"
  - Supports:
    - State companies were sold from the 1960s: 64 companies were sold between 1962 and 1977 (among them the state's holdings in Otzar HaHayal, Swiss-Israel Bank, Hachsharat HaYishuv and the Caesarea Development Company)
    - On 5 March 1978 the ministerial committee on economic affairs decided to sell 47 government companies to reduce the government's role in the economy (Finance Minister Simcha Ehrlich)
    - Privatisation intensified from 1986; El Al, Israel Chemicals, Paz and Bezeq are among the companies privatised

**[S5991]** Wikipedia, 'Privatization in Israel', revision of 14 February 2026 — https://en.wikipedia.org/wiki/Privatization_in_Israel — accessed: 2026-10-14 — provenance: opened
  - Note: Added by fix3-econ (v3 fix round) for the privatisation lever (data/fiscal.json). Page fetched with curl on 2026-10-14; quotes checked verbatim against the page text (progress/fix3_econ/src/en_priv.txt).
  - Quote: "The privatization processes in Israel intensified in 1986 following the intensified privatization in Britain in the 1980s."
  - Supports:
    - Privatisation in Israel intensified from 1986; about 90 government companies and subsidiaries were privatised, including ZIM, Israel Shipyards, Israel Chemicals and partial sales of Bank Leumi and Israel Discount Bank

**[S5992]** Wikipedia, '1985 Israel Economic Stabilization Plan', revision of 2026 (the plan's authors and measures) — https://en.wikipedia.org/wiki/1985_Israel_Economic_Stabilization_Plan — accessed: 2026-10-14 — provenance: opened
  - Note: Added by fix3-econ (v3 fix round) for the emergency stabilisation package (data/fiscal.json). S577 and S584 cite the same page for the inflation figures; this entry carries the quotes on the plan's authors and measures. Page fetched with curl on 2026-10-14; quotes checked verbatim (progress/fix3_econ/src/en_1985.txt).
  - Quote: "The plan was devised by Yitzhak Moda'i and Michael Bruno."
  - Supports:
    - The July 1985 plan was devised by Finance Minister Yitzhak Moda'i and Michael Bruno; it combined wage controls agreed with the Histadrut, temporary price controls, a sharp devaluation followed by a fixed exchange rate, and limits on the Bank of Israel printing money to cover deficits

**[S5993]** Encyclopaedia Britannica, 'Israel: Economy' (archived 2021) — https://web.archive.org/web/20210125215109/https://www.britannica.com/place/Israel/Economy — accessed: 2026-10-15 — provenance: opened
  - Note: v4-goals: history source for era goal g5_growth_years. Page fetched via the web.archive.org copy and the quote checked verbatim in the page text.
  - Quote: "The large influx of well-trained and Western-educated European and North American immigrants contributed greatly to a rapid rise in Israel’s gross national product (GNP) after 1948."
  - Supports:
    - Israel's gross national product rose rapidly after 1948 (the growth years of the 1950s-60s)

**[S5994]** Wikipedia, 'Research and development in Israel' (statistics of scientists and technicians; context for the R&D-intensity goal) — https://en.wikipedia.org/wiki/Research_and_development_in_Israel — accessed: 2026-10-15 — provenance: opened
  - Note: v4-goals: page fetched and the quote checked verbatim in the page text on 2026-10-15; a Wikipedia source is a stopgap, a better one is requested in sources/requests.jsonl.
  - Quote: "Israel counts 140 scientists and technicians per 10,000 employees, one of the highest ratios in the world."
  - Supports:
    - Israel has one of the highest ratios of scientists and technicians to employees in the world
