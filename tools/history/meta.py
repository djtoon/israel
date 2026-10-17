# -*- coding: utf-8 -*-
# Per-city metadata for cities.json. cbs = CBS locality code (None if not an Israeli CBS locality).
# status entries: (from, to, status, note, [sources]); dates 'YYYY', 'YYYY-MM' or 'YYYY-MM-DD'.
# Tags like '@B:xyz' are resolved at build time to source ids from the era forks (by keyword search).

ISR = ("1948-05-14", None, "israel", "Within the State of Israel from its establishment.", ["S100"])

def isr_from(date, note, src):
    return (date, None, "israel", note, src)

MILGOV_NOTE = "Arab localities in Israel were placed under military government (movement permits under emergency regulations) until it was abolished on 1 December 1966."

def arab_town(captured, cap_note, cap_src, milgov=True):
    st = [(captured, "1966-12-01" if milgov else None, "israel_military_government" if milgov else "israel", cap_note + (" " + MILGOV_NOTE if milgov else ""), cap_src + (["S150", "S166"] if milgov else []))]
    if milgov:
        st.append(("1966-12-01", None, "israel", "Military government abolished; residents are Arab citizens of Israel.", ["S150"]))
    return st

TRIANGLE = ("1949-05", "Came under Israeli control in spring 1949 when, under Article VI of the Israel-Jordan General Armistice Agreement (Rhodes, 3 April 1949), Jordanian forces replaced Iraqi forces and the armistice line in the Wadi Ara / Baqa-Jaljulia area was redrawn; residents kept rights of residence and property and became Israeli citizens.", ["S112"])

WB_JOR = ("1948-05", "1967-06", "jordanian_administered", "Held by Jordan's Arab Legion from the 1948 war; annexed by Jordan in April 1950 (recognised by few states).", ["S112", "S122"])
WB_OCC = ("1967-06", None, "israeli_occupied", "Captured by Israel in the Six-Day War (June 1967) and placed under Israeli military administration.", ["@B:six_day"])
GAZA_EG = ("1948-05", "1967-06", "egyptian_administered", "Held by Egypt from the 1948 war; the 24 Feb 1949 Egypt-Israel armistice left the Gaza Strip under Egyptian administration.", ["S110"])
GAZA_OCC = ("1967-06", "1994-05", "israeli_occupied", "Captured by Israel in the Six-Day War and placed under military administration.", ["@B:six_day"])
GAZA_PA = ("1994-05", "2007-06-14", "palestinian_authority", "Under the Gaza-Jericho Agreement (4 May 1994) the Palestinian Authority took over most of the Gaza Strip; Israeli settlements and military zones remained until the 2005 disengagement (completed 12 September 2005).", ["S323", "S365"])
GAZA_HAMAS = ("2007-06-14", None, "hamas_controlled", "Hamas took control of the Gaza Strip in June 2007 after fighting with Fatah; Israel then imposed a land, sea and air blockade, citing security, with Egypt also restricting its crossing (see the 2007 blockade event). After the Hamas-led attack of 7 October 2023 the Strip became the main theatre of the Israel-Hamas war, with most of its population displaced.", ["S374"], [{"claim": "Israel intensified restrictions into a blockade after the June 2007 takeover", "url": "https://www.ochaopt.org/content/gaza-strip-humanitarian-impact-15-years-blockade-june-2022", "quote": "In June 2007, following the military takeover of Gaza by Hamas, the Israeli authorities significantly intensified existing movement restrictions"}, {"claim": "Land, sea and air blockade", "url": "https://www.ochaopt.org/content/gaza-strip-humanitarian-impact-15-years-blockade-june-2022", "quote": "This land, sea and air blockade has significantly exacerbated previous restrictions"}])

def wb_city(handover, h_prec_note, h_src, extra=None):
    st = [WB_JOR, (WB_OCC[0], handover, WB_OCC[2], WB_OCC[3], WB_OCC[4]),
          (handover, None, "pa_area_a", "Transferred to Palestinian Authority civil and security control (Area A) under the Oslo II Interim Agreement. " + h_prec_note, h_src + ["S328"])]
    if extra:
        st += extra
    return st

REOCC_2002 = ("2002-03-29", None, "pa_area_a_idf_operations", "Israeli forces re-entered Area A cities during Operation Defensive Shield (from 29 March 2002) and have since conducted operations there while the PA retains civil administration.", ["@C:defensive_shield"])


WB_IRAQ = ("1948-05", "1967-06", "jordanian_administered", "Held by Iraqi forces in 1948-49; under the 1949 armistice arrangements Jordan's Arab Legion took over the Iraqi front, and Jordan annexed the West Bank in April 1950 (recognised by few states).", ["S112", "S122"], [{"claim": "Israel agreed to the Arab Legion taking over the Iraqi front (1949)", "url": "https://history.state.gov/historicaldocuments/frus1949v06/d554", "quote": "Israel agrees to taking over by Arab Legion on Iraqi front."}])
IRON_WALL = ("2025-01-21", None, "pa_area_a_idf_operations", "Israel's 'Iron Wall' operation from 21 January 2025 centred on the Jenin, Tulkarm and Nur Shams refugee camps, causing what OCHA called the longest and largest displacement crisis in the West Bank since 1967.", [], [{"claim": "Iron Wall launched 21 January 2025", "url": "https://www.ochaopt.org/sites/default/files/Northern_West_Bank_Humanitarian_Response_Update_April_2025.pdf", "quote": "Israeli forces launched on 21 January a major militarized operation in the West Bank, dubbed \"Iron Wall\""}, {"claim": "Jenin, Tulkarm and Nur Shams camps at the centre", "url": "https://www.ochaopt.org/sites/default/files/Northern_West_Bank_Humanitarian_Response_Update_April_2025.pdf", "quote": "the refugee camps of Jenin, Tulkarm and Nur Shams being at the centre of operations"}, {"claim": "Largest displacement crisis since 1967", "url": "https://www.ochaopt.org/sites/default/files/Northern_West_Bank_Humanitarian_Response_Update_April_2025.pdf", "quote": "the longest and largest displacement crisis in the West Bank since 1967"}])
REOCC = ("2002-03-29", None, "pa_area_a_idf_operations", "Israeli forces re-entered the Area A cities in Operation Defensive Shield (from 29 March 2002) and have conducted operations there since, while the Palestinian Authority keeps civil administration.", ["@C:defensive_shield"])
def wb_city2(handover, note, src, iraq=False, iron=False):
    st = wb_city(handover, note, src)
    if iraq: st[0] = WB_IRAQ
    st[-1] = (st[-1][0], "2002-03-29") + st[-1][2:]
    if iron:
        st.append(("2002-03-29", "2025-01-21") + REOCC[2:])
        st.append(IRON_WALL)
    else:
        st.append(REOCC)
    return st

GAZA_CITY = [GAZA_EG, GAZA_OCC, GAZA_PA, GAZA_HAMAS]

CITIES = [
 # ---------- Major Jewish / mixed cities ----------
 dict(id="jerusalem", name="Jerusalem", he="ירושלים", kind="city", cbs=3000, founded=None, founded_note="Ancient city. CBS lists it as a 'veteran' (pre-state) locality.",
      status=[("1948-05-14", "1967-06", "israel_west_only", "Divided city: West Jerusalem held by Israel, the Old City and East Jerusalem held by Jordan under the 3 April 1949 armistice. Israel's Knesset declared Jerusalem its capital in December 1949-January 1950.", ["S112", "S123"]),
              ("1967-06", None, "israel_with_annexed_east", "East Jerusalem captured in June 1967; Israeli law and municipal boundaries were extended to it on 28 June 1967 and the 1980 Jerusalem Law declared the city Israel's capital. The UN Security Council (Res. 478, 1980) and most states do not recognise the annexation; the US recognised Jerusalem as Israel's capital in December 2017.", ["@B:jerusalem_1967", "@B:jerusalem_law", "@D:us_jerusalem"])],
      notes="Population figures before 1967 cover only Israeli-held West Jerusalem; from 1972 they include East Jerusalem (CBS municipal boundaries)."),
 dict(id="tel_aviv", name="Tel Aviv-Yafo", he="תל אביב-יפו", kind="city", cbs=5000, founded="1909", founded_note="Tel Aviv founded 1909 (CBS); ancient Jaffa was merged with it to form Tel Aviv-Yafo in 1950.",
      status=[("1948-05-14", None, "israel", "Within Israel from its establishment; Arab Jaffa surrendered on 13 May 1948 and most of its Arab population had fled or left during the fighting, a few thousand remaining.", ["S100", "S105"])]),
 dict(id="haifa", name="Haifa", he="חיפה", kind="city", cbs=4000, founded=None, founded_note="Pre-state 'veteran' city (CBS); modern town founded in the 1760s.", status=[("1948-05-14", None, "israel", "Within Israel from its establishment; most of Haifa's Arab population left or was displaced after the Haganah took the city on 21-22 April 1948.", ["S100", "S105"])],
      notes="Mixed Jewish-Arab city; most of its Arab population left or was displaced during April-May 1948."),
 dict(id="rishon_lezion", name="Rishon LeZion", he="ראשון לציון", kind="city", cbs=8300, founded="1882", status=[ISR]),
 dict(id="petah_tikva", name="Petah Tikva", he="פתח תקווה", kind="city", cbs=7900, founded="1878", status=[ISR]),
 dict(id="ashdod", name="Ashdod", he="אשדוד", kind="city", cbs=70, founded="1956", founded_note="CBS gives 1955 as the settlement year; the modern city's first residents arrived in 1956 and its port opened in 1965.", status=[("1956", None, "israel", "Planned development city and port.", ["S157"])]),
 dict(id="netanya", name="Netanya", he="נתניה", kind="city", cbs=7400, founded="1929", status=[ISR]),
 dict(id="beersheba", name="Beersheba", he="באר שבע", kind="city", cbs=9000, founded="1948", founded_note="Ottoman administrative town founded c.1900; captured by Israel on 21 October 1948 (Operation Yoav), its Arab inhabitants having left; CBS dates the Israeli locality to 1948.",
      status=[isr_from("1948-10-21", "Captured in Operation Yoav; resettled by Jewish immigrants and developed as the capital of the Negev.", ["S158", "S104"])]),
 dict(id="bnei_brak", name="Bnei Brak", he="בני ברק", kind="city", cbs=6100, founded="1924", status=[ISR]),
 dict(id="holon", name="Holon", he="חולון", kind="city", cbs=6600, founded="1933", founded_note="CBS 1995 list gives settlement year 1933; the 2022 locality file gives 1940 (municipal incorporation).", status=[ISR]),
 dict(id="ramat_gan", name="Ramat Gan", he="רמת גן", kind="city", cbs=8600, founded="1921", status=[ISR]),
 dict(id="rehovot", name="Rehovot", he="רחובות", kind="city", cbs=8400, founded="1890", status=[ISR]),
 dict(id="ashkelon", name="Ashkelon", he="אשקלון", kind="city", cbs=7100, founded="1948", founded_note="Built on and around the Arab town of al-Majdal, captured 5 November 1948; most remaining Arab residents were transferred to the Gaza Strip in 1950.",
      status=[isr_from("1948-11-05", "Al-Majdal captured by Israel; about 2,700 Arab residents remained, most of whom were moved to Gaza in 1950. Resettled by Jewish immigrants as Migdal Gad / Ashkelon.", ["S169", "S104"])]),
 dict(id="bat_yam", name="Bat Yam", he="בת ים", kind="city", cbs=6200, founded="1926", status=[ISR]),
 dict(id="beit_shemesh", name="Beit Shemesh", he="בית שמש", kind="city", cbs=2610, founded="1950", status=[("1950", None, "israel", "Development town for new immigrants in the Jerusalem corridor.", ["S004", "S168"])]),
 dict(id="kfar_saba", name="Kfar Saba", he="כפר סבא", kind="city", cbs=6900, founded="1903", status=[ISR]),
 dict(id="herzliya", name="Herzliya", he="הרצליה", kind="city", cbs=6400, founded="1924", status=[ISR]),
 dict(id="hadera", name="Hadera", he="חדרה", kind="city", cbs=6500, founded="1890", status=[ISR]),
 dict(id="modiin", name="Modi'in-Maccabim-Re'ut", he="מודיעין-מכבים-רעות", kind="city", cbs=1200, founded="1986", founded_note="Maccabim-Re'ut founded 1986 (CBS year); the planned city of Modi'in received its first residents in the 1990s and merged with Maccabim-Re'ut in 2003.", status=[("1986", None, "israel", "Planned city between Tel Aviv and Jerusalem.", ["S004"])]),
 dict(id="lod", name="Lod", he="לוד", kind="city", cbs=7000, founded="1948", founded_note="Ancient town (Lydda); CBS dates the Israeli locality to 1948.",
      status=[isr_from("1948-07-11", "Captured in Operation Dani on 11-12 July 1948; most of its Arab inhabitants were expelled on 12-13 July. A minority of Arab residents remained; the town was resettled by Jewish immigrants and is today a mixed city.", ["S116", "S117", "S104"])]),
 dict(id="ramla", name="Ramla", he="רמלה", kind="city", cbs=8500, founded="1948", founded_note="Founded in the 8th century; CBS dates the Israeli locality to 1948.",
      status=[isr_from("1948-07-12", "Surrendered to Israeli forces on 12 July 1948 (Operation Dani); most Arab inhabitants were expelled or fled. Today a mixed city.", ["S116", "S117", "S104"])]),
 dict(id="raanana", name="Ra'anana", he="רעננה", kind="city", cbs=8700, founded="1921", status=[ISR]),
 dict(id="rosh_haayin", name="Rosh HaAyin", he="ראש העין", kind="city", cbs=2640, founded="1950", founded_note="Founded as a transit camp for Yemenite immigrants of Operation Magic Carpet.", status=[("1950", None, "israel", "Immigrant settlement founded near the Yarkon springs.", ["S004"])]),
 dict(id="hod_hasharon", name="Hod HaSharon", he="הוד השרון", kind="city", cbs=9700, founded="1924", founded_note="Formed in 1964 by merging four moshavot, the oldest dating from 1924 (CBS year).", status=[ISR]),
 dict(id="nahariya", name="Nahariya", he="נהריה", kind="city", cbs=9100, founded="1934", status=[ISR]),
 dict(id="kiryat_gat", name="Kiryat Gat", he="קריית גת", kind="city", cbs=2630, founded="1954", status=[("1954", None, "israel", "Development town and regional centre of the Lakhish settlement project.", ["S167", "S004"])]),
 dict(id="givatayim", name="Givatayim", he="גבעתיים", kind="city", cbs=6300, founded="1922", status=[ISR]),
 dict(id="kiryat_ata", name="Kiryat Ata", he="קריית אתא", kind="city", cbs=6800, founded="1925", status=[ISR]),
 dict(id="acre", name="Acre", he="עכו", kind="city", cbs=7600, founded="1948", founded_note="Ancient port city; CBS dates the Israeli locality to 1948.",
      status=[isr_from("1948-05-17", "Captured by Israeli forces on 17-18 May 1948; much of its Arab population fled or was displaced, and the Old City remained largely Arab. Today a mixed city.", ["S104"])]),
 dict(id="eilat", name="Eilat", he="אילת", kind="city", cbs=2600, founded="1951", founded_note="IDF reached Umm Rashrash on 10 March 1949; a civilian camp was set up in December 1949 and CBS dates the town to 1951.",
      status=[isr_from("1949-03-10", "Southern Negev secured in Operation Uvda; developed as Israel's Red Sea port, dependent on passage through the Straits of Tiran.", ["S159", "S174"])]),
 dict(id="afula", name="Afula", he="עפולה", kind="city", cbs=7700, founded="1925", status=[ISR]),
 dict(id="karmiel", name="Karmiel", he="כרמיאל", kind="city", cbs=1139, founded="1964", status=[("1964", None, "israel", "Planned town in the central Galilee.", ["S004", "S168"])]),
 dict(id="nof_hagalil", name="Nof HaGalil", he="נוף הגליל", kind="city", cbs=1061, founded="1957", founded_note="Founded as Nazareth Illit; renamed Nof HaGalil in 2019.", status=[("1957", None, "israel", "Jewish town built on the hills above Arab Nazareth.", ["S166", "S004"])]),
 dict(id="tiberias", name="Tiberias", he="טבריה", kind="city", cbs=6700, founded=None, founded_note="Ancient city (founded c. 20 CE).", status=[("1948-05-14", None, "israel", "Within Israel from its establishment; its Arab residents left in April 1948 after fighting, evacuated with British help.", ["S100", "S105"])]),
 dict(id="safed", name="Safed", he="צפת", kind="city", cbs=8000, founded=None, founded_note="Ancient city.", status=[("1948-05-14", None, "israel", "Within Israel from its establishment; its Arab majority fled during the battle for the town in early May 1948.", ["S100", "S105"])]),
 dict(id="dimona", name="Dimona", he="דימונה", kind="city", cbs=2200, founded="1955", status=[("1955", None, "israel", "Negev development town; the nearby nuclear research centre was built from 1958.", ["S156", "S144"])]),
 dict(id="arad", name="Arad", he="ערד", kind="city", cbs=2560, founded="1961", founded_note="CBS gives 1961; the town was formally inaugurated in 1962.", status=[("1961", None, "israel", "Planned Negev town.", ["S164", "S004"])]),
 dict(id="kiryat_shmona", name="Kiryat Shmona", he="קריית שמונה", kind="city", cbs=2800, founded="1950", founded_note="First settlers July 1949 on the site of the depopulated village of al-Khalisa; CBS year 1950.", status=[("1949-07", None, "israel", "Development town near the Lebanese border, repeatedly hit by cross-border fire.", ["S160", "S004", "S106"])]),
 dict(id="sderot", name="Sderot", he="שדרות", kind="city", cbs=1031, founded="1951", status=[("1951", None, "israel", "Development town near the Gaza Strip; heavily targeted by rocket fire from 2001.", ["S161", "S004"])]),
 dict(id="netivot", name="Netivot", he="נתיבות", kind="city", cbs=246, founded="1956", status=[("1956", None, "israel", "Development town in the north-western Negev.", ["S163", "S004"])]),
 dict(id="ofakim", name="Ofakim", he="אופקים", kind="city", cbs=31, founded="1955", status=[("1955", None, "israel", "Development town in the north-western Negev.", ["S162", "S004"])]),
 dict(id="yeruham", name="Yeruham", he="ירוחם", kind="town", cbs=831, founded="1951", status=[("1951", None, "israel", "Development town in the central Negev.", ["S004"])]),
 dict(id="mitzpe_ramon", name="Mitzpe Ramon", he="מצפה רמון", kind="town", cbs=99, founded="1954", founded_note="Workers' camp from 1951; CBS settlement year 1954.", status=[("1954", None, "israel", "Town on the rim of the Ramon crater.", ["S004", "S168"])]),
 dict(id="kiryat_malakhi", name="Kiryat Malakhi", he="קריית מלאכי", kind="city", cbs=1034, founded="1951", status=[("1951", None, "israel", "Immigrant town built on the lands of the depopulated village of Qastina.", ["S004", "S106"])]),
 dict(id="migdal_haemek", name="Migdal HaEmek", he="מגדל העמק", kind="city", cbs=874, founded="1952", status=[("1952", None, "israel", "Development town in the Jezreel Valley.", ["S004"])]),
 dict(id="beit_shean", name="Beit She'an", he="בית שאן", kind="city", cbs=9200, founded="1948", founded_note="Ancient town (Baysan); CBS dates the Israeli locality to 1948.", status=[("1948-05-14", None, "israel", "Captured by the Haganah in May 1948; its Arab inhabitants fled or were expelled and the town was resettled by Jewish immigrants.", ["S105"])]),
 dict(id="maalot_tarshiha", name="Ma'alot-Tarshiha", he="מעלות-תרשיחא", kind="city", cbs=1063, founded="1957", founded_note="Jewish town Ma'alot (1957) merged in 1963 with the Arab village of Tarshiha, captured in Operation Hiram (October 1948).", status=[("1948-10", None, "israel", "Tarshiha captured in Operation Hiram; Ma'alot founded 1957 and joined to it in 1963.", ["S174", "S004"])]),
 dict(id="yavne", name="Yavne", he="יבנה", kind="city", cbs=2660, founded="1949", founded_note="Built beside the depopulated Arab town of Yibna.", status=[("1949", None, "israel", "Immigrant town.", ["S004", "S106"])]),
 dict(id="or_yehuda", name="Or Yehuda", he="אור יהודה", kind="city", cbs=2400, founded="1950", status=[("1950", None, "israel", "Founded as a ma'abara (transit camp), largely for immigrants from Iraq.", ["S004", "S126"])]),
 dict(id="nes_ziona", name="Ness Ziona", he="נס ציונה", kind="city", cbs=7200, founded="1883", status=[ISR]),
 dict(id="gedera", name="Gedera", he="גדרה", kind="town", cbs=2550, founded="1884", status=[ISR]),
 dict(id="elad", name="El'ad", he="אלעד", kind="city", cbs=1309, founded="1998", status=[("1998", None, "israel", "Planned city with a mainly Haredi population.", ["S004"])]),
 dict(id="harish", name="Harish", he="חריש", kind="city", cbs=1247, founded="1982", founded_note="Founded 1982 as a Nahal outpost (CBS year); part of the joint locality Katzir-Harish until 2012 and rapidly expanded as a planned city in the 2010s.", status=[("1982", None, "israel", "Town in Wadi Ara.", ["S004", "S002"])]),
 dict(id="zikhron_yaakov", name="Zikhron Ya'akov", he="זכרון יעקב", kind="town", cbs=9300, founded="1882", status=[ISR]),
 dict(id="rosh_pinna", name="Rosh Pinna", he="ראש פינה", kind="town", cbs=26, founded="1882", status=[ISR]),
 dict(id="metula", name="Metula", he="מטולה", kind="town", cbs=43, founded="1896", status=[ISR], notes="Northernmost Israeli town, on the Lebanese border."),
 dict(id="yokneam_illit", name="Yokneam Illit", he="יקנעם עילית", kind="city", cbs=240, founded="1950", status=[("1950", None, "israel", "Development town that became a high-tech centre.", ["S004"])]),
 dict(id="kiryat_bialik", name="Kiryat Bialik", he="קריית ביאליק", kind="city", cbs=9500, founded="1934", status=[ISR]),
 dict(id="kiryat_yam", name="Kiryat Yam", he="קריית ים", kind="city", cbs=9600, founded="1941", status=[ISR]),
 dict(id="tirat_carmel", name="Tirat Carmel", he="טירת כרמל", kind="city", cbs=2100, founded="1949", founded_note="Built on the site of the depopulated Arab village of al-Tira.", status=[("1949", None, "israel", "Immigrant town south of Haifa.", ["S004", "S106"])]),
 dict(id="or_akiva", name="Or Akiva", he="אור עקיבא", kind="city", cbs=1020, founded="1951", status=[("1951", None, "israel", "Development town near Caesarea.", ["S004"])]),
 # ---------- Arab, Druze and Bedouin localities in Israel ----------
 dict(id="nazareth", name="Nazareth", he="נצרת", kind="arab_city", cbs=7300, founded=None, founded_note="Ancient town; largest Arab city in Israel.",
      status=arab_town("1948-07-16", "Surrendered to Israeli forces on 16 July 1948 (Operation Dekel); its population was not expelled and it absorbed many internally displaced Palestinians.", ["S104"])),
 dict(id="sakhnin", name="Sakhnin", he="סח'נין", kind="arab_city", cbs=7500, founded=None, founded_note="Long-established Arab town in the Galilee.",
      status=arab_town("1948-10", "Came under Israeli control during Operation Hiram (late October 1948).", ["S174", "S104"])),
 dict(id="shefaram", name="Shefa-'Amr", he="שפרעם", kind="arab_city", cbs=8800, founded=None, founded_note="Long-established mixed Muslim, Christian and Druze town.",
      status=arab_town("1948-07", "Came under Israeli control in July 1948 (Operation Dekel).", ["S104"])),
 dict(id="umm_al_fahm", name="Umm al-Fahm", he="אום אל-פחם", kind="arab_city", cbs=2710, founded=None, status=arab_town(*TRIANGLE)),
 dict(id="tayibe", name="Tayibe", he="טייבה", kind="arab_city", cbs=2730, founded=None, status=arab_town(*TRIANGLE)),
 dict(id="tira", name="Tira", he="טירה", kind="arab_city", cbs=2720, founded=None, status=arab_town(*TRIANGLE)),
 dict(id="kafr_qasim", name="Kafr Qasim", he="כפר קאסם", kind="arab_city", cbs=634, founded=None, status=arab_town(*TRIANGLE), notes="Site of the Kafr Qasim massacre of 29 October 1956."),
 dict(id="baqa_al_gharbiyye", name="Baqa al-Gharbiyye", he="באקה אל-גרביה", kind="arab_city", cbs=6000, founded=None, status=arab_town(*TRIANGLE), notes="The armistice line divided Baqa; Baqa al-Sharqiyye remained on the Jordanian (West Bank) side."),
 dict(id="tamra", name="Tamra", he="טמרה", kind="arab_city", cbs=8900, founded=None, status=arab_town("1948", "Came under Israeli control during the 1948 war.", ["S104"])),
 dict(id="kafr_kanna", name="Kafr Kanna", he="כפר כנא", kind="arab_town", cbs=509, founded=None, status=arab_town("1948-07", "Came under Israeli control in July 1948 (Operation Dekel).", ["S104"])),
 dict(id="arraba", name="Arraba", he="עראבה", kind="arab_city", cbs=531, founded=None, status=arab_town("1948-10", "Came under Israeli control during Operation Hiram (October 1948).", ["S174", "S104"]), notes="One of the towns of the 30 March 1976 Land Day protests."),
 dict(id="daliyat_al_karmel", name="Daliyat al-Karmel", he="דאלית אל-כרמל", kind="druze_town", cbs=494, founded=None, founded_note="Druze town on Mount Carmel.", status=[ISR]),
 dict(id="abu_ghosh", name="Abu Ghosh", he="אבו גוש", kind="arab_town", cbs=472, founded=None, founded_note="Arab village west of Jerusalem whose residents largely remained in 1948.", status=[ISR]),
 dict(id="jisr_az_zarqa", name="Jisr az-Zarqa", he="ג'סר א-זרקא", kind="arab_town", cbs=541, founded=None, founded_note="Coastal Arab village; one of the few on the coastal plain whose population remained in 1948.", status=[ISR]),
 dict(id="rahat", name="Rahat", he="רהט", kind="bedouin_city", cbs=1161, founded=None, founded_note="Government-planned township for Negev Bedouin; CBS lists no founding year. First enumerated in the 1983 census.", status=[("1983", None, "israel", "Planned Bedouin township (date = first CBS census listing).", ["S001"])]),
 dict(id="hura", name="Hura", he="חורה", kind="bedouin_town", cbs=1303, founded=None, founded_note="Government-planned Bedouin township in the former siyag zone; CBS lists no founding year, and it was first enumerated in the 1995 census.", status=[("1948", None, "israel", "Part of the Negev area where Israel concentrated Bedouin tribes in the siyag (restricted zone) under military rule (1949-1966); the planned township of Hura was built there later and first appears in the 1995 census.", ["S001"], [{"claim": "Bedouin tribes moved into the siyag", "url": "https://www.hrw.org/report/2008/03/30/map/land-and-housing-rights-violations-israels-unrecognized-bedouin-villages", "quote": "authorities forcibly moved 11 of the 19 remaining tribes from land in the area between Beer Sheva and the Israel-Gaza border"}, {"claim": "Military rule 1949-1966", "url": "https://www.hrw.org/report/2008/03/30/map/land-and-housing-rights-violations-israels-unrecognized-bedouin-villages", "quote": "During the period of Israeli military rule over the country's Palestinian Arab population, from 1949 to 1966"}])]),
 dict(id="tel_sheva", name="Tel Sheva", he="תל שבע", kind="bedouin_town", cbs=1054, founded=None, founded_note="The first of the government-planned Bedouin townships; CBS lists no founding year. First enumerated in the 1983 census.", status=[("1983", None, "israel", "Planned Bedouin township (date = first CBS census listing).", ["S001"])]),
 # ---------- Kibbutzim and moshavim ----------
 dict(id="degania_alef", name="Degania Alef", he="דגניה א'", kind="kibbutz", cbs=62, founded="1909", founded_note="CBS settlement year 1909 (the group first settled at Umm Juni in 1909-1910); the first kibbutz. Site of the 20 May 1948 battle of the Deganias.", status=[ISR]),
 dict(id="nahalal", name="Nahalal", he="נהלל", kind="moshav", cbs=80, founded="1921", founded_note="First moshav ovdim (workers' cooperative village).", status=[ISR]),
 dict(id="sde_boker", name="Sde Boker", he="שדה בוקר", kind="kibbutz", cbs=885, founded="1952", founded_note="Negev kibbutz where David Ben-Gurion lived from 1953.", status=[("1952", None, "israel", "", ["S004"])]),
 dict(id="yad_mordechai", name="Yad Mordechai", he="יד מרדכי", kind="kibbutz", cbs=358, founded="1943", founded_note="Held out against the Egyptian army for six days in May 1948 before the survivors withdrew; retaken later in 1948 (Encyclopaedia Judaica gives October 1948).", status=[
      ("1948-05-14", "1948-05", "israel", "Kibbutz within Israel at independence.", ["S100"]),
      ("1948-05", "1948-10", "egyptian_held", "Abandoned to the Egyptian army after a six-day defence in May 1948.", [], [{"claim": "Survivors slipped through the siege in May 1948", "url": "https://www.jewishvirtuallibrary.org/yad-mordekhai", "quote": "The village was by then reduced to ruins and the survivors, carrying their wounded, succeeded in slipping through the ring of siege and reaching Jewish positions miles away (May 1948)."}]),
      ("1948-10", None, "israel", "Retaken by Israeli forces (Encyclopaedia Judaica: October 1948; other accounts give early November).", [], [{"claim": "The site was retaken in October 1948", "url": "https://www.jewishvirtuallibrary.org/yad-mordekhai", "quote": "The site was retaken in October 1948."}])]),
 dict(id="negba", name="Negba", he="נגבה", kind="kibbutz", cbs=315, founded="1939", founded_note="Held out against Egyptian attacks in 1948.", status=[ISR]),
 dict(id="beeri", name="Be'eri", he="בארי", kind="kibbutz", cbs=399, founded="1946", founded_note="One of the 11 Negev points of 6 October 1946 (CBS year 1946). One of the communities attacked on 7 October 2023.", status=[ISR]),
 dict(id="kfar_aza", name="Kfar Aza", he="כפר עזה", kind="kibbutz", cbs=845, founded="1951", status=[("1951", None, "israel", "Kibbutz on the Gaza border; one of the communities attacked on 7 October 2023.", ["S004", "@D:oct7"])]),
 dict(id="nir_oz", name="Nir Oz", he="ניר עוז", kind="kibbutz", cbs=69, founded="1955", status=[("1955", None, "israel", "Kibbutz near the Gaza border; one of the communities attacked on 7 October 2023.", ["S004", "@D:oct7"])]),
 dict(id="nahal_oz", name="Nahal Oz", he="נחל עוז", kind="kibbutz", cbs=844, founded="1951", status=[("1951", None, "israel", "Founded as a Nahal military outpost on the Gaza border.", ["S004"])]),
 dict(id="ein_gedi", name="Ein Gedi", he="עין גדי", kind="kibbutz", cbs=2042, founded="1953", founded_note="Nahal outpost 1953, kibbutz from 1956.", status=[("1953", None, "israel", "", ["S004"])]),
 dict(id="revivim", name="Revivim", he="רביבים", kind="kibbutz", cbs=354, founded="1943", status=[ISR]),
 dict(id="kfar_giladi", name="Kfar Giladi", he="כפר גלעדי", kind="kibbutz", cbs=76, founded="1916", status=[ISR]),
 dict(id="hanita", name="Hanita", he="חניתה", kind="kibbutz", cbs=280, founded="1938", founded_note="Tower-and-stockade settlement on the Lebanese border.", status=[ISR]),
 dict(id="ein_harod", name="Ein Harod", he="עין חרוד", kind="kibbutz", cbs=None, cbs_sum=[89, 82], founded="1921", founded_note="Founded 1921; split in 1952 into Ein Harod (Ihud) and Ein Harod (Meuhad). Populations here are the sum of the two CBS localities.", status=[ISR]),
 dict(id="yotvata", name="Yotvata", he="יטבתה", kind="kibbutz", cbs=866, founded="1951", founded_note="Nahal outpost 1951, kibbutz from 1957.", status=[("1951", None, "israel", "", ["S004"])]),
 # ---------- Golan Heights ----------
 dict(id="katzrin", name="Katzrin", he="קצרין", kind="settlement_town", cbs=4100, founded="1977", status=[
      ("1977", "1981-12-14", "israeli_occupied", "Israeli town founded in the Golan Heights, captured from Syria in 1967.", ["S004", "@B:six_day"]),
      ("1981-12-14", None, "israeli_law_applied", "Israel applied its law to the Golan Heights (Golan Heights Law, 14 Dec 1981); UN Security Council Res. 497 declared the measure null and void.", ["@B:golan_law"])]),
 dict(id="majdal_shams", name="Majdal Shams", he="מג'דל שמס", kind="druze_village", cbs=4201, founded=None, founded_note="Druze village; largest Syrian community remaining in the Israeli-held Golan after 1967.", status=[
      ("1948-05-14", "1967-06", "syria", "Part of Syria.", ["S113"]),
      ("1967-06", "1981-12-14", "israeli_occupied", "Captured by Israel in June 1967; most of the Golan's Syrian population (estimates range from about 80,000 Syrians (Morris) to about 116,000 Syrians and Palestinians (McDowall)) fled or was expelled, while the Druze villages including Majdal Shams remained.", ["@B:six_day", "@B:golan_displace"]),
      ("1981-12-14", None, "israeli_law_applied", "Golan Heights Law; most residents declined Israeli citizenship. On 27 July 2024 a rocket strike on a football pitch killed 12 children.", ["@B:golan_law", "@D:majdal"])]),
 dict(id="quneitra", name="Quneitra", he="קוניטרה", kind="syrian_city", cbs=None, founded=None, founded_note="Syrian administrative centre of the Golan.", status=[
      ("1948-05-14", "1967-06", "syria", "Syrian town.", ["S113"]),
      ("1967-06", "1974-06", "israeli_occupied", "Captured by Israel in June 1967; most of the Golan's Syrian population fled or was expelled (see the 1967 displacement event).", ["@B:six_day"]),
      ("1974-06", "2024-12", "syria_un_buffer", "Returned to Syria under the 31 May 1974 Israel-Syria Disengagement Agreement, in the UNDOF area of separation; the town was not rebuilt.", ["@B:syria_disengagement"], [{"claim": "1974 agreement: Israel withdrew from about 25 km2 including Quneitra", "url": "https://aa.com.tr/en/middle-east/factbox-with-assad-gone-israel-captures-syria-buffer-zone-ends-border-agreement/3418903", "quote": "an area of about 25 square kilometers (9.6 square miles) that included Quneitra and other locations."}]),
      ("2024-12", None, "israeli_forces_present", "After the fall of the Assad government in December 2024 the Israeli army seized the demilitarised buffer zone, including the Quneitra area, and declared the 1974 disengagement agreement collapsed.", ["@D:assad"], [{"claim": "Israeli army seized the demilitarized zone after Assad's ouster", "url": "https://aa.com.tr/en/middle-east/factbox-with-assad-gone-israel-captures-syria-buffer-zone-ends-border-agreement/3418903", "quote": "the Israeli army said it seized control of a demilitarized zone in the Golan Heights after anti-regime groups took over Syria."}, {"claim": "Netanyahu announced collapse of the 1974 agreement", "url": "https://aa.com.tr/en/middle-east/factbox-with-assad-gone-israel-captures-syria-buffer-zone-ends-border-agreement/3418903", "quote": "Israeli Prime Minister Benjamin Netanyahu also announced the collapse of a UN-monitored disengagement agreement"}])],
      notes="No sourced population series."),
 # ---------- West Bank ----------
 dict(id="hebron", name="Hebron", he="חברון", kind="palestinian_city", cbs=None, founded=None, founded_note="Ancient city; site of the Cave of the Patriarchs / Ibrahimi Mosque.",
      status=[WB_JOR, (WB_OCC[0], "1997-01-17", WB_OCC[2], WB_OCC[3], WB_OCC[4]),
              ("1997-01-17", None, "divided_h1_h2", "Under the Hebron Protocol (17 Jan 1997) about 80% of the city (H1) passed to Palestinian Authority control, while Israel kept control of H2, including the Jewish settlement enclaves and the Old City core.", ["S336"])]),
 dict(id="nablus", name="Nablus", he="שכם", kind="palestinian_city", cbs=None, founded=None, founded_note="Ancient city (Shechem / Neapolis); largest city in the northern West Bank.",
      status=wb_city2("1995-12-11", "Israeli troops withdrew on 11-12 December 1995.", ["S013"], iraq=True)),
 dict(id="ramallah", name="Ramallah", he="רמאללה", kind="palestinian_city", cbs=None, founded=None, founded_note="Seat of the Palestinian Authority government.",
      status=wb_city2("1995-12-27", "Israeli troops withdrew on 27 December 1995, the last of the six towns handed over that year.", ["S013"])),
 dict(id="bethlehem", name="Bethlehem", he="בית לחם", kind="palestinian_city", cbs=None, founded=None, founded_note="Ancient town; birthplace of Jesus in Christian tradition.",
      status=wb_city2("1995-12-21", "Israeli forces withdrew on 21 December 1995.", ["S013"])),
 dict(id="jenin", name="Jenin", he="ג'נין", kind="palestinian_city", cbs=None, founded=None,
      status=wb_city2("1995-11", "Jenin was the first town handed over: the pull-out began in late October and was completed in mid-November 1995.", ["S014"], iraq=True, iron=True)),
 dict(id="tulkarm", name="Tulkarm", he="טולכרם", kind="palestinian_city", cbs=None, founded=None,
      status=wb_city2("1995-12-10", "Palestinian police took over after the Israeli withdrawal around 10 December 1995.", ["S013"], iraq=True, iron=True)),
 dict(id="qalqilya", name="Qalqilya", he="קלקיליה", kind="palestinian_city", cbs=None, founded=None,
      status=wb_city2("1995-12-16", "Israeli troops withdrew on 16 December 1995.", ["S013"], iraq=True)),
 dict(id="jericho", name="Jericho", he="יריחו", kind="palestinian_city", cbs=None, founded=None, founded_note="One of the oldest continuously inhabited towns in the world.",
      status=[WB_JOR, (WB_OCC[0], "1994-05", WB_OCC[2], WB_OCC[3], WB_OCC[4]),
              ("1994-05", None, "palestinian_authority", "First West Bank town transferred to the Palestinian Authority, under the Gaza-Jericho Agreement of 4 May 1994.", ["S323"])],
      notes="The Jericho district population fell sharply between 1961 and 1967 because the large refugee camps near Jericho emptied during the 1967 war."),
 dict(id="ariel", name="Ariel", he="אריאל", kind="settlement_city", cbs=3570, founded="1978", status=[("1978", None, "israeli_settlement", "Israeli settlement (city status from 1998) in the occupied West Bank. Most states and the UN Security Council (Res. 2334, 2016) regard the settlements as illegal under international law; Israel disputes this.", ["S004", "@D:unsc2334"])]),
 dict(id="maale_adumim", name="Ma'ale Adumim", he="מעלה אדומים", kind="settlement_city", cbs=3616, founded="1975", status=[("1975", None, "israeli_settlement", "Israeli settlement city east of Jerusalem in the occupied West Bank; see Ariel for its legal status under international law.", ["S004", "@D:unsc2334"])]),
 dict(id="modiin_illit", name="Modi'in Illit", he="מודיעין עילית", kind="settlement_city", cbs=3797, founded="1996", status=[("1996", None, "israeli_settlement", "Haredi Israeli settlement city in the occupied West Bank, west of Ramallah.", ["S004", "@D:unsc2334"])]),
 dict(id="beitar_illit", name="Beitar Illit", he="ביתר עילית", kind="settlement_city", cbs=3780, founded="1985", status=[("1985", None, "israeli_settlement", "Haredi Israeli settlement city in the occupied West Bank, south-west of Jerusalem.", ["S004", "@D:unsc2334"])]),
 dict(id="kiryat_arba", name="Kiryat Arba", he="קריית ארבע", kind="settlement_town", cbs=3611, founded="1972", founded_note="Settlers first established themselves in Hebron in April 1968; Kiryat Arba was built adjacent to Hebron from the early 1970s (CBS year 1972).", status=[("1972", None, "israeli_settlement", "Israeli settlement adjacent to Hebron in the occupied West Bank.", ["S004", "@D:unsc2334"])]),
 dict(id="kfar_etzion", name="Kfar Etzion", he="כפר עציון", kind="kibbutz", cbs=3488, founded="1967", founded_note="Original kibbutz (1943) fell to Arab forces on 13 May 1948, when most of its defenders were killed; re-established in September 1967 as the first Israeli settlement in the West Bank.", status=[
      ("1967-09", None, "israeli_settlement", "Re-established in the occupied West Bank after the Six-Day War.", ["S004", "@B:kfar_etzion"])]),
 # ---------- Gaza Strip ----------
 dict(id="gaza_city", name="Gaza City", he="עזה", kind="palestinian_city", cbs=None, founded=None, founded_note="Ancient city.", status=GAZA_CITY),
 dict(id="khan_yunis", name="Khan Yunis", he="ח'אן יונס", kind="palestinian_city", cbs=None, founded=None, status=GAZA_CITY),
 dict(id="rafah", name="Rafah", he="רפיח", kind="palestinian_city", cbs=None, founded=None, founded_note="Divided by the Egypt-Gaza border drawn after the 1979 peace treaty (implemented 1982).", status=GAZA_CITY),
 dict(id="deir_al_balah", name="Deir al-Balah", he="דיר אל-בלח", kind="palestinian_city", cbs=None, founded=None, status=GAZA_CITY),
 dict(id="jabalia", name="Jabalia", he="ג'באליה", kind="palestinian_city", cbs=None, founded=None, founded_note="Town and adjacent refugee camp (the largest in Gaza); the First Intifada began there in December 1987.", status=GAZA_CITY),
 dict(id="neve_dekalim", name="Neve Dekalim", he="נווה דקלים", kind="settlement_town", cbs=5427, founded="1980", founded_note="CBS settlement year 1980 (residents arrived from 1983); largest settlement of the Gush Katif bloc.", status=[
      ("1980", "2005-08", "israeli_settlement", "Israeli settlement in the occupied Gaza Strip.", ["S007"]),
      ("2005-08", None, "evacuated", "Evacuated and demolished in the August 2005 disengagement from Gaza.", ["S365"])]),
 # ---------- Sinai ----------
 dict(id="yamit", name="Yamit", he="ימית", kind="settlement_town", cbs=None, founded="1975", founded_note="Israeli town in the occupied northern Sinai.", status=[
      ("1975", "1982-04", "israeli_settlement", "Israeli town in Sinai, captured from Egypt in 1967.", ["@B:yamit"]),
      ("1982-04", None, "evacuated", "Evacuated and razed in April 1982 before Sinai was returned to Egypt under the 1979 peace treaty.", ["@B:yamit"])],
      notes="No sourced population series."),
 # ---------- Round 5: localities the renderer needs (Jaffa; Old City / East Jerusalem) ----------
 dict(id="jaffa", name="Jaffa", he="יפו", kind="arab_city", cbs=None, founded="pre-1948", founded_note="Ancient port city (Jaffa / Yafo); the largest Arab city in Mandatory Palestine. Merged into Tel Aviv in 1950 (see tel_aviv).",
      coords=(32.0527, 34.7516), merged_into="tel_aviv",
      status=[("1947-11-29", "1948-05-13", "arab_held", "Arab-majority city; fighting around Jaffa followed the UN partition vote of 29 November 1947. Its Arab defenders capitulated on 13 May 1948.", ["S4100"]),
              ("1948-05-13", "1950", "israeli_controlled", "Fell to Jewish forces on 13 May 1948 (capitulation signed at Tel Aviv Haganah headquarters); most of the Arab population had left, and the city was resettled with Jewish immigrants.", ["S4006", "S4100"]),
              ("1950", None, "merged_into_tel_aviv", "Merged with Tel Aviv in 1950 (formally renamed Tel Aviv-Yafo); continues as the Yafo district of Tel Aviv-Yafo.", ["S4100", "S4101"])],
      notes="Record ends with the 1950 merger; see tel_aviv."),
 dict(id="east_jerusalem", name="East Jerusalem", he="מזרח ירושלים", kind="arab_city", cbs=None, founded="pre-1948", founded_note="The Old City and the Arab neighbourhoods north and east of it; part of ancient Jerusalem.",
      coords=(31.7767, 35.2345),
      status=[("1948-05-14", "1948-05-28", "contested", "Intense fighting in the Old City began on 14 May 1948; Israeli attempts to break through Zion Gate failed.", ["S3035"]),
              ("1948-05-28", "1949-04-03", "jordanian_held", "Jordan's Arab Legion took the Jewish Quarter on 28 May 1948 and the Old City passed to Jordanian control.", ["S3035"]),
              ("1949-04-03", "1967-06-28", "jordanian_administered", "Administered by Jordan under the 1949 armistice (Jordan annexed the West Bank including East Jerusalem in April 1950, recognised by few states).", ["S112", "S1112", "S123"]),
              ("1967-06-28", None, "israeli_law_applied", "Israeli law, jurisdiction and administration extended to East Jerusalem on 27-28 June 1967; Basic Law: Jerusalem (1980). The UN Security Council (Res. 478) held the 1980 law null and void; most states do not recognise the annexation.", ["S1112", "S227", "S1415"])],
      notes="Old City and East Jerusalem. The Jerusalem record covers the city as a whole."),
]

# Palestinian and other non-CBS populations: id -> {year: (value, source, note)}
EXTRA_POP = {
 "hebron": {"1961": (37868, "S009", "Jordanian census"), "1967": (38348, "S009", "Israeli CBS census, autumn 1967"), "1997": (119401, "S011", "PCBS census"), "2007": (163146, "S011", "PCBS census"), "2017": (201063, "S011", "PCBS census")},
 "nablus": {"1961": (45768, "S009", "Jordanian census"), "1967": (44223, "S009", "Israeli CBS census"), "1997": (100231, "S011", "PCBS census"), "2007": (126132, "S011", "PCBS census"), "2017": (156906, "S011", "PCBS census")},
 "ramallah": {"1997": (18017, "S011", "PCBS census"), "2007": (27460, "S011", "PCBS census"), "2017": (38998, "S011", "PCBS census")},
 "bethlehem": {"1997": (21947, "S011", "PCBS census"), "2007": (25266, "S011", "PCBS census"), "2017": (28591, "S011", "PCBS census")},
 "jenin": {"1961": (14402, "S009", "Jordanian census"), "1967": (13365, "S009", "Israeli CBS census"), "1997": (35791, "S011", "PCBS census"), "2007": (49375, "S011", "PCBS census"), "2017": (60325, "S011", "PCBS census")},
 "tulkarm": {"1961": (20690, "S009", "Jordanian census"), "1967": (15275, "S009", "Israeli CBS census"), "1997": (44029, "S011", "PCBS census"), "2007": (61941, "S011", "PCBS census"), "2017": (74463, "S011", "PCBS census")},
 "qalqilya": {"1961": (11401, "S009", "Jordanian census"), "1967": (8926, "S009", "Israeli CBS census"), "1997": (31772, "S011", "PCBS census"), "2007": (41739, "S011", "PCBS census"), "2017": (51683, "S011", "PCBS census")},
 "jericho": {"1961": (10166, "S009", "Jordanian census"), "1967": (6829, "S009", "Israeli CBS census"), "1997": (14744, "S011", "PCBS census"), "2007": (18346, "S011", "PCBS census"), "2017": (20907, "S011", "PCBS census")},
 "gaza_city": {"1967": (118272, "S010", "Israeli CBS census (Egyptian 1966 estimate: 152,776)"), "1997": (353632, "S011", "PCBS census"), "2007": (483869, "S011", "PCBS census"), "2017": (631215, "S011", "PCBS census; citypopulation.de locality definition")},
 "khan_yunis": {"1967": (52997, "S010", "Israeli CBS census (Egyptian 1966 estimate: 75,100)"), "1997": (123175, "S011", "PCBS census"), "2007": (180342, "S011", "PCBS census"), "2017": (246307, "S011", "PCBS census")},
 "rafah": {"1967": (49812, "S010", "Israeli CBS census, incl. southern Rafah (~2,500) (Egyptian 1966 estimate: 66,181)"), "1997": (109174, "S011", "PCBS census"), "2007": (156332, "S011", "PCBS census"), "2017": (208449, "S011", "PCBS census")},
 "deir_al_balah": {"1967": (18118, "S010", "Israeli CBS census (Egyptian 1966 estimate: 15,002)"), "1997": (42870, "S011", "PCBS census"), "2007": (60877, "S011", "PCBS census"), "2017": (82117, "S011", "PCBS census")},
 "jabalia": {"1967": (43604, "S010", "Israeli CBS census (Egyptian 1966 estimate: 49,009)"), "1997": (113901, "S011", "PCBS census"), "2007": (164931, "S011", "PCBS census"), "2017": (222166, "S011", "PCBS census")},
 "jaffa": {"1947": (70000, "S4100", "approx. non-Jewish (Arab) residents of a city of nearly 100,000 in 1946-47 (Jewish Virtual Library)"), "1948": (4000, "S4006", "Arab inhabitants remaining in summer 1948 (Encyclopaedia Judaica: of about 100,000 Arab inhabitants; 2,000 Muslim, 1,500 Christian, rest Armenian and others)")},
 "neve_dekalim": {"2004": (2636, "S007", "CBS end-2004 estimate, the last before the 2005 evacuation")},
}
POP_NOTES_EXTRA = {
 "jaffa": "Sources differ on the pre-war Arab population: the Jewish Virtual Library gives about 70,000 non-Jews in a city of nearly 100,000 (1946-47), while the Encyclopaedia Judaica speaks of 100,000 Arab inhabitants. Both agree that most left in the first half of 1948 (Encyclopaedia Judaica: only about 4,000 remained in summer 1948; Jewish Virtual Library: most abandoned the city by sea after its fall on 13 May 1948). Palestinian and Israeli accounts differ on how far the departure was flight and how far expulsion; these sources give no figure for the number expelled.",
 "baqa_al_gharbiyye": "The 2008 figure is for the merged municipality Baqa-Jatt (CBS name in the 2008 file), which was later split again; it is not comparable with the other years.",
 "daliyat_al_karmel": "The 2008 figure is for the merged 'Carmel City' (Daliyat al-Karmel with Isfiya) as listed in the CBS 2008 file; the merger was later reversed, so it is not comparable with the other years.",
 "jerusalem": "1948 and 1961 figures cover Israeli-held West Jerusalem only; from 1972 the CBS figures include East Jerusalem.",
 "ramallah": "Jordanian 1961 census: Ramallah and al-Bira together 29,269; Israeli 1967 census: 25,171 (S009). Not split by town, so not included in the series.",
 "bethlehem": "Jordanian 1961 census: Bethlehem with Beit Jala, Beit Sahur and Dheisheh camp 35,735; Israeli 1967 census: 31,883 (S009). Not split by town.",
 "gaza_city": "Since October 2023 most of the Gaza Strip's population has been displaced repeatedly; no census-based city figures exist for the war period.",
 "khan_yunis": "See Gaza City note on wartime displacement since October 2023.",
 "rafah": "See Gaza City note on wartime displacement since October 2023.",
 "deir_al_balah": "See Gaza City note on wartime displacement since October 2023.",
 "jabalia": "See Gaza City note on wartime displacement since October 2023.",
 "harish": "1983/1995 CBS figures under code 1247 refer to the earlier locality 'Iron' and are not used; 2008 figure is for the joint locality Katzir-Harish.",
}
