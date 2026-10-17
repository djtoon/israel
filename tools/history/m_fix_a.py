# -*- coding: utf-8 -*-
# Critic fixes and affected_populations for events dated 1948-1986.
NQ, NR = "not quantified", "none reported"
JVL_CAS = "https://www.jewishvirtuallibrary.org/military-casualties-in-arab-israeli-wars"
ZO_BS = "https://zochrot.org/publication_articles/view/49869/en"
ZO_DAW = "https://www.zochrot.org/villages/village_details/49115/en"
NAJD = "https://web.archive.org/web/2026/https://www.palestineremembered.com/Gaza/Najd/index.html"
CONV = "https://theconversation.com/remembering-the-palestinians-murdered-at-kafr-qasim-six-decades-ago-67880"
PALQ = "https://www.palquest.org/en/overallchronology?nid=14334"
UNRWA56 = "https://web.archive.org/web/20131104160006/http://unispal.un.org/UNISPAL.NSF/0/6558F61D3DB6BD4505256593006B06BE"
UNEF = "https://peacekeeping.un.org/mission/past/unef1backgr2.html"
DNE = "https://www.dailynewsegypt.com/2025/04/08/bahr-al-baqar-when-israel-massacred-egyptian-children/"
CSM85 = "https://www.csmonitor.com/1985/0107/dbisra-f.html"
HRW96 = "https://www.hrw.org/reports/1996/Israel.htm"

def ap(group, killed=None, wounded=None, displaced=None, note=None):
    d = {"group": group}
    if killed is not None: d["killed"] = killed
    if wounded is not None: d["wounded"] = wounded
    if displaced is not None: d["displaced"] = displaced
    if note: d["note"] = note
    return d

P = {}
def patch(eid, **kw): P.setdefault(eid, {}).update(kw)

# ---- critic WRONG / UNSUPPORTED / BIASED fixes ----
patch("evt_1948_arab_invasion",
  set={"summary": "The day after the declaration, forces of Egypt, Transjordan, Syria, Iraq and Lebanon entered the former Mandate territory; Transjordan's Arab Legion operated mainly in areas allotted to the Arab state and in the Jerusalem zone. The IDF/JVL table of military casualties gives Israel's losses in the 1948-49 war as 6,373; historians' estimates of dead among the Arab armies range from about 3,700 to 7,000, and of Palestinian Arab dead (fighters and civilians) from about 3,000 to 13,000."},
  cite=[{"claim": "Israel's losses in 1948-49: 6,373 (IDF/JVL military casualties table)", "url": JVL_CAS, "quote": "Israel 1948 1949 140,000 6,373"}])
patch("evt_1948_operation_yoav",
  set={"summary": "Israel broke the Egyptian lines in the northern Negev in Operation Yoav (also called the Ten Plagues). Beersheba was captured on 20-21 October 1948 after aerial bombardment; most residents had fled, and according to Zochrot the remaining men were sent to prisoner-of-war camps and others were trucked to Gaza (see the separate Beersheba and al-Dawayima events). Egyptian forces at Faluja were encircled."},
  cite=[{"claim": "Beersheba conquered 20-21 Oct 1948 with aerial bombardment", "url": ZO_BS, "quote": "Beersheba was conquered on 20-21 October 1948 with the use of aerial bombardment."},
        {"claim": "Remaining men later transferred to POW camps", "url": ZO_BS, "quote": "Some of the men remained for a short time afterward to help the IDF clear the city; later they were transferred to prisoner of war camps."},
        {"claim": "Testimony: residents put on trucks to Gaza", "url": ZO_BS, "quote": "They started putting people on trucks and sending them to Gaza."},
        {"claim": "Al-Dawayima massacre on 29 Oct 1948 during Operation Yoav", "url": ZO_DAW, "quote": "A large, but little known, massacre was carried out on the site of al-Dawayima on 29 October 1948, during the Israeli army's Operation Yo'av"}],
  set_ap=[ap("egyptian_soldiers", killed=NQ), ap("israeli_soldiers", killed=NQ),
          ap("palestinian_arabs", killed=NQ, displaced=NQ, note="Residents of Beersheba and nearby villages fled or were removed; the al-Dawayima massacre (estimates 80-100 to several hundred killed) is a separate event.")])
patch("evt_1951_sderot_mitzpe_ramon",
  cite=[{"claim": "Sderot was built on lands of the village of Najd, whose residents were expelled on 13 May 1948 (Palestine Remembered, drawing on W. Khalidi)", "url": NAJD, "quote": "The villagers of Najd were expelled on 13 May 1948, just before the establishment of the state of Israel."},
        {"claim": "Sderot and Or HaNer on Najd's lands", "url": NAJD, "quote": "Exculsive Jewish Colonies That Usurped Village Lands Sderot and Or ha-Ner"}],
  append_summary=" Sderot was built on lands of the Arab village of Najd, whose residents were expelled on 13 May 1948.")
patch("evt_1956_kafr_qasim",
  append_summary=" The sentences were later reduced on appeal and by pardon, and by 1960 all the convicted men had been released; Brigade commander Issachar Shadmi, tried separately, was fined one hundredth of an Israeli lira.",
  cite=[{"claim": "All convicted soldiers released by 1960 after reductions or pardons", "url": PALQ, "quote": "By 1960, all the soldiers had been released from prison after their sentences were reduced or they had received pardons."},
        {"claim": "Shadmi fined one hundredth of a lira", "url": CONV, "quote": "Shadmi, meanwhile, was tried separately and was ultimately fined one hundredth of an Israeli Lira"},
        {"claim": "Curfew brought forward from 9pm to 5pm by Shadmi", "url": CONV, "quote": "decided to that the regular nightly curfew on the Palestinian villages that usually started at 9pm would commence at 5pm."},
        {"claim": "Eight of 11 defendants given long sentences", "url": CONV, "quote": "Of the 11 defendants accused of taking part in the massacre, eight were given long sentences."},
        {"claim": "Trials established the duty to defy blatantly illegal orders", "url": CONV, "quote": "the trials did establish a legal precedent that Israeli soldiers are obliged to defy “blatantly illegal orders”"}],
  set_ap=[ap("arab_citizens_of_israel", killed=[47, 49], note="Residents of Kafr Qasim; 49 is the most cited figure.")])
patch("evt_1956_sinai_campaign",
  append_summary=" During the occupation of the Gaza Strip, UNRWA received lists naming 275 people allegedly killed in Khan Yunis on 3 November and 111 at Rafah camp on 12 November; Israel stated there had been resistance, which refugees denied.",
  cite=[{"claim": "UNRWA: 275 allegedly killed at Khan Yunis on 3 Nov 1956", "url": UNRWA56, "quote": "lists of names of persons allegedly killed on 3 November, numbering 275 individuals, of whom 140 were refugees and 135 local residents of Khan Yunis."},
        {"claim": "UNRWA: 111 allegedly killed at Rafah on 12 Nov 1956", "url": UNRWA56, "quote": "lists of names of persons allegedly killed at Rafah on 12 November, numbering 111, of whom 103 were refugees, seven local residents, and one an Egyptian."},
        {"claim": "Israeli authorities said there was resistance; refugees deny it", "url": UNRWA56, "quote": "The Israel authorities in Gaza state that the attitude of the refugees in Rafah camp was hostile and that there was some resistance to the screening operation"}],
  effects={"casualties": {"israel": {"killed": [172, 189]}, "egypt": {"killed": [1000, 3000]}, "palestinians": {"killed": [386, 386]}}},
  set_ap=[ap("israeli_soldiers", killed=[172, 189]), ap("egyptians", killed=[1000, 3000]),
          ap("gazans", killed=[386, 386], note="UNRWA lists of persons allegedly killed at Khan Yunis (275, 3 Nov) and Rafah (111, 12 Nov); other estimates are higher.")])
patch("evt_1957_sinai_withdrawal",
  effects={"diplo": {"egypt": "armistice"}},
  set={"summary": "Under US pressure and UN General Assembly resolutions 1124 and 1125 of 2 February 1957, Israel announced on 1 March that it would withdraw. It left the Gaza Strip on 6-7 March and Sharm el-Sheikh on 8-12 March 1957. UNEF deployed along the armistice line and at Sharm el-Sheikh, where it kept the Strait of Tiran under observation; its stationing there required Egyptian consent and it had no mandate to guarantee navigation, for which Israel relied on assurances from the US and other maritime powers."},
  cite=[{"claim": "Withdrawal dates from Gaza and Sharm el-Sheikh", "url": UNEF, "quote": "The withdrawal from the Gaza Strip took place on 6 and 7 March 1957 and that from the Sharm el Sheikh area from 8 to 12 March."},
        {"claim": "UNEF detachment at Sharm el-Sheikh watched the Strait of Tiran", "url": UNEF, "quote": "This detachment maintained an observation post and kept the Strait of Tiran under constant watch."},
        {"claim": "Stationing UNEF at Sharm el-Sheikh required Egyptian consent", "url": UNEF, "quote": "the stationing of the United Nations Emergency Force at Sharm el Sheikh would require Egyptian consent."},
        {"claim": "GA resolution 1125 called for scrupulous observance of the armistice after full withdrawal", "url": UNEF, "quote": "By resolution 1125 (XI), the Assembly, recognizing that withdrawal by Israel must be followed by action which would assure progress"}])
patch("evt_1969_war_of_attrition",
  append_summary=" Civilians were also killed: Israeli deep-penetration raids in early 1970 hit a factory at Abu Zaabal (89 workers killed) and a school at Bahr el-Baqar (30 children killed, per Egyptian reports; Israel said it had targeted military installations).",
  cite=[{"claim": "Abu Zaabal factory bombing killed 89 workers", "url": DNE, "quote": "the bombing of the Abu Zaabal factory, a civilian site where 89 workers were killed."},
        {"claim": "Bahr el-Baqar: 30 children killed", "url": DNE, "quote": "Thirty children perished, and over fifty more were wounded or permanently disfigured"},
        {"claim": "Israel said it targeted military installations", "url": DNE, "quote": "Tel Aviv claimed its jets had targeted only military installations during the raid on Egyptian territory."}],
  set_ap=[ap("israeli_soldiers", killed=[694, 1424]), ap("israeli_civilians", killed=NQ, note="Israeli civilians were also killed; no figure in the sources cited here."),
          ap("egyptians", killed=[2882, 10000], note="Upper estimate (Morris) includes civilians."),
          ap("egyptian_civilians", killed=[119, 119], note="Abu Zaabal (89) and Bahr el-Baqar (30) raids only, per Daily News Egypt.")])
patch("evt_1970_black_september",
  effects={"casualties": {"palestinians": {"killed": [2000, 3400]}, "jordan": {"killed": [537, 537]}}},
  set_ap=[ap("palestinians", killed=[2000, 3400], note="Guerrillas and refugee-camp civilians; Arafat claimed far more."),
          ap("jordanian_soldiers", killed=[537, 537]), ap("israelis", killed=NR, note="Israel mobilised but did not fight.")])
patch("evt_1982_lebanon_war",
  set={"summary": "After the attempted assassination of Ambassador Shlomo Argov in London by the Abu Nidal group, Israel invaded Lebanon on 6 June 1982. The cabinet had approved an operation to push the PLO about 40 km from the border; according to Schiff and Ya'ari, Defence Minister Sharon expanded it step by step, fighting Syrian forces and besieging West Beirut until PLO fighters were evacuated in August-September. Lebanese tallies of the dead for June-August 1982 range from 17,285 (An-Nahar) to 19,085 (Lebanese authorities), many of them civilians. Israel lost 368 soldiers by October 1982 and 654 by June 1985."},
  cite=[{"claim": "Cabinet thought it approved a 40 km incursion", "url": CSM85, "quote": "The Israeli Cabinet thought it was approving an incursion 40 kilometers north of its border"},
        {"claim": "Sharon moved troops forward into Beirut while telling ministers moves were dictated by events", "url": CSM85, "quote": "bringing Israeli forces into Beirut, while continually telling the ministers that his moves were dictated by the situation on the ground."}],
  set_ap=[ap("israeli_soldiers", killed=[368, 654]), ap("lebanese_and_palestinians", killed=[17285, 19085], displaced=NQ, note="Lebanese tallies may already include PLO and Syrian dead."),
          ap("syrian_soldiers", killed=[1200, 1200])])
patch("evt_1985_security_zone",
  append_summary=" The zone's Lebanese residents lived under the control of the SLA and the IDF, and human-rights groups documented shelling of villages around it.",
  cite=[{"claim": "SLA headquarters at Marjayoun controlled access in the Israeli-occupied area", "url": HRW96, "quote": "requested permission from the SLA's headquarters in Marja'iyoun in the Israeli-occupied area to evacuate civilians from villages"},
        {"claim": "Israel shelled population centres in response to attacks on its forces in the zone", "url": HRW96, "quote": "Israel, in particular, has responded to attacks on its forces in the occupied zone with shelling barrages on civilian population centers in southern Lebanon."}],
  set_ap=[ap("israeli_soldiers", killed=[654, 654], note="Losses since June 1982."), ap("lebanese_in_security_zone", killed=NQ, note="Lebanese residents under SLA/IDF control.")])

# ---- affected_populations for the remaining 1948-1986 casualty/displacement events ----
AP = {
 "evt_1948_palestinian_displacement": [ap("palestinian_arabs", displaced=[520000, 935000], note="Israeli government 520-600k; Morris c.700k; UNCCP 711k; Abu-Sitta 935k."),
     ap("israelis", displaced=NQ, note="Displacement of Jewish communities in 1948 is not covered by the sources cited for this event.")],
 "evt_1948_arab_invasion": [ap("israelis", killed=[6373, 6373], note="IDF/JVL table."), ap("arab_armies", killed=[3700, 7000]), ap("palestinian_arabs", killed=[3000, 13000])],
 "evt_1948_lydda_ramle": [ap("palestinian_arabs", killed=[400, 400], displaced=[50000, 70000], note="Palestinian sources: more than 400 killed in Lydda; Morris 50-60k, IPS ~70k expelled."), ap("israeli_soldiers", killed=NQ)],
 "evt_1948_bernadotte": [ap("un_personnel", killed=[2, 2], note="Count Folke Bernadotte and Colonel André Sérot."), ap("israelis", killed=NR)],
 "evt_1948_operation_hiram": [ap("palestinian_arabs", killed=NQ, displaced=NQ, note="Morris documents killings at Safsaf, Jish and other villages and flight/expulsion to Lebanon."), ap("arab_liberation_army", killed=NQ), ap("israeli_soldiers", killed=NQ)],
 "evt_1948_operation_horev": [ap("egyptian_soldiers", killed=NQ), ap("israeli_soldiers", killed=NQ)],
 "evt_1949_operation_uvda": [ap("israeli_soldiers", killed=NQ), ap("jordanian_soldiers", killed=NQ)],
 "evt_1950_majdal_transfer": [ap("palestinian_arabs", displaced=[2000, 2700]), ap("israelis", displaced=NR)],
 "evt_1953_qibya": [ap("palestinians", killed=[69, 69], note="Villagers of Qibya (Jordanian-held West Bank)."), ap("israeli_civilians", killed=[3, 3], note="Mother and two children killed at Yehud before the raid.")],
 "evt_1955_gaza_raid": [ap("egyptian_soldiers", killed=[37, 38]), ap("israeli_soldiers", killed=[8, 8])],
 "evt_1966_samu": [ap("jordanians", killed=[16, 16], wounded=[54, 54]), ap("israeli_soldiers", killed=[1, 1]), ap("samu_villagers", killed=NQ, note="Dozens of houses demolished.")],
 "evt_1967_displacement": [ap("palestinian_arabs", displaced=[245000, 325000]), ap("syrians_golan", displaced=[80000, 116000]), ap("israelis", displaced=NR)],
 "evt_1967_six_day_war": [ap("israelis", killed=[776, 983]), ap("egyptians", killed=[9800, 15000]), ap("jordanians", killed=[696, 800]), ap("syrians", killed=[1000, 2500]), ap("palestinian_civilians", killed=NQ)],
 "evt_1967_eilat_sinking": [ap("israeli_sailors", killed=[47, 47]), ap("egyptians", killed=NQ, note="Casualties of the Israeli shelling of Port Suez refineries.")],
 "evt_1968_dakar_lost": [ap("israeli_sailors", killed=[69, 69])],
 "evt_1968_karameh": [ap("israeli_soldiers", killed=[28, 33]), ap("jordanian_soldiers", killed=[40, 84]), ap("palestinian_fighters", killed=[100, 200])],
 "evt_1968_beirut_airport_raid": [ap("lebanese", killed=NR), ap("israelis", killed=NR)],
 "evt_1972_lod_airport": [ap("israelis", killed=[8, 8]), ap("puerto_rican_pilgrims", killed=[17, 17]), ap("canadian", killed=[1, 1]), ap("attackers", killed=[2, 2])],
 "evt_1972_munich": [ap("israelis", killed=[11, 11]), ap("west_german_police", killed=[1, 1]), ap("attackers", killed=[5, 5])],
 "evt_1973_libyan_114": [ap("aircraft_passengers_and_crew", killed=[108, 108]), ap("israelis", killed=NR)],
 "evt_1973_spring_of_youth": [ap("israeli_soldiers", killed=[2, 2]), ap("palestinians", killed=NQ, note="Three senior PLO figures among the dead."), ap("lebanese", killed=NQ, note="Lebanon reported policemen and civilians killed.")],
 "evt_1973_yom_kippur_war": [ap("israelis", killed=[2520, 2800]), ap("egyptians", killed=[5000, 15000]), ap("syrians", killed=[3000, 3500]), ap("iraqis", killed=[125, 125]), ap("jordanians", killed=[23, 23])],
 "evt_1974_kiryat_shmona": [ap("israeli_civilians", killed=[18, 18]), ap("attackers", killed=[3, 3])],
 "evt_1974_maalot": [ap("israeli_civilians", killed=[25, 31]), ap("attackers", killed=[3, 3])],
 "evt_1976_land_day": [ap("arab_citizens_of_israel", killed=[6, 6], wounded=[100, 100])],
 "evt_1976_entebbe": [ap("israeli_soldiers", killed=[1, 1]), ap("hostages", killed=[4, 4], note="Three in the raid; Dora Bloch murdered in Uganda."), ap("hijackers", killed=[7, 7]), ap("ugandan_soldiers", killed=[45, 45])],
 "evt_1978_coastal_road": [ap("israeli_civilians", killed=[38, 38], wounded=[70, 70]), ap("attackers", killed=[9, 9])],
 "evt_1978_operation_litani": [ap("lebanese_and_palestinians", killed=[1100, 1100], displaced=NQ, note="Norton: about 1,100, mostly civilians."), ap("israeli_soldiers", killed=NQ)],
 "evt_1980_mayors_bombings": [ap("palestinians", wounded=[2, 2], note="Mayors Bassam Shakaa and Karim Khalaf."), ap("israelis", killed=NR)],
 "evt_1981_osirak": [ap("iraqi_soldiers", killed=[10, 10]), ap("french_technician", killed=[1, 1]), ap("israelis", killed=NR)],
 "evt_1981_sadat_assassinated": [ap("egyptians", killed=NQ, note="Sadat and others at the parade."), ap("israelis", killed=NR)],
 "evt_1982_bashir_assassination": [ap("lebanese", killed=[27, 27], note="Gemayel and about 26 others.")],
 "evt_1982_sabra_shatila": [ap("palestinian_and_lebanese_civilians", killed=[460, 3500]), ap("israelis", killed=NR)],
 "evt_1982_tyre_hq": [ap("israelis", killed=[104, 104], note="76 in 1982 and 28 in 1983."), ap("lebanese_detainees", killed=[47, 59])],
 "evt_1985_wooden_leg": [ap("plo_members_and_tunisians", killed=[47, 71]), ap("israeli_civilians", killed=[3, 3], note="Three Israelis killed in Larnaca before the raid.")],
}
for k, v in AP.items():
    P.setdefault(k, {})["set_ap"] = v
