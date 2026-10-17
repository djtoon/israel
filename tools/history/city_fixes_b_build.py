# Builds city_fixes_b.json for pre-1948 localities.
# Base = the CURRENT game/data/cities.json (which already contains the lead's first city_fixes_b, built by
# city_fixes_b_build.py with S2050-S2053). This file supersedes that one: it carries every city that version set,
# keeps its statuses/cites, and adds the improvements below. Sources: S2050-S2053 (carried) + S2060-S2083 (new).
# Run: python -I build_b.py ; then python -I verify_b.py
import json, copy, sys, os
sys.stdout.reconfigure(encoding="utf-8")
HERE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data")  # reference only: built from the published cities.json; data/city_fixes_b.json is authoritative
OUT = os.path.join(HERE, "city_fixes_b.json")
C = json.load(open(r"C:\civ\game\data\cities.json", encoding="utf-8"))
D = {c["id"]: c for c in C}
ACC = "2026-10-11"

SOURCES = json.load(open(os.path.join(HERE, "lead_b_sources.json"), encoding="utf-8"))   # S2050-S2053, carried over
def src(i, citation, url, supports):
    SOURCES.append({"id": i, "citation": citation, "url": url, "archived_url": None, "accessed": ACC,
                    "kind": "web", "opened": True, "provenance": "opened", "supports": supports})
    return i

PQN = src("S2060", "Maher Charif, 'The Nakba' (highlight), Interactive Encyclopedia of the Palestine Question (PalQuest), Institute for Palestine Studies",
          "https://www.palquest.org/en/highlight/160/nakba",
          ["Tiberias fell 18 April 1948; attacks on Haifa from 21 April; Safad emptied by early May; Baysan occupied 12 May; Acre 16 May (IPS dating)",
           "only al-Faradis and Jisr al-Zarqa remained of the coastal villages between Tel Aviv and Haifa"])
BR_ACRE = src("S2061", "Encyclopaedia Britannica, 'Acre' (Israel), britannica.com (Wayback Machine copy)",
              "https://web.archive.org/web/2024/https://www.britannica.com/place/Acre-Israel",
              ["Acre was occupied by regular Israeli troops on 17 May 1948; about 3,000 Arab inhabitants remained"])
BR_LOD = src("S2062", "Encyclopaedia Britannica, 'Lod', britannica.com (Wayback Machine copy)",
             "https://web.archive.org/web/2024/https://www.britannica.com/place/Lod",
             ["Lod was occupied by the invading Arab Legion of Jordan", "the IDF captured the city on 12 July 1948"])
BR_RAM = src("S2063", "Encyclopaedia Britannica, 'Ramla', britannica.com (Wayback Machine copy)",
             "https://web.archive.org/web/2024/https://www.britannica.com/place/Ramla",
             ["Ramla and its environs were invaded by Transjordan's Arab Legion", "the Israelis took the city on 12 July 1948"])
BR_BS = src("S2064", "Encyclopaedia Britannica, 'Bet She'an', britannica.com (Wayback Machine copy)",
            "https://web.archive.org/web/2024/https://www.britannica.com/place/Bet-Shean",
            ["taken by the Haganah on 12 May 1948, three days before the proclamation of statehood"])
JTA_NAZ1 = src("S2065", "Jewish Telegraphic Agency, 'Report Israelis in Nazareth; Jewish Villages Shelled in South; Egyptians Lose 500 Men', Daily Bulletin, 16 July 1948",
               "https://www.jta.org/archive/report-israelis-in-nazareth-jewish-villages-shelled-in-south-egyptians-lose-500-men",
               ["Israeli forces entered the outskirts of Nazareth", "Shafa Amr already captured; Iblin taken"])
JTA_NAZ2 = src("S2066", "Jewish Telegraphic Agency, 'Israeli Troops Capture Nazareth As Guerrilla Units Flee; Tel Aviv Bombed Again', Daily Bulletin, 18 July 1948",
               "https://www.jta.org/archive/israeli-troops-capture-nazareth-as-guerrilla-units-flee-tel-aviv-bombed-again",
               ["capture of Nazareth officially announced; the city had been a major base of Qawuqji's Liberation Army"])
JTA_MAJ = src("S2067", "Jewish Telegraphic Agency, 'Egyptians Retreat from Majdal Area; Entire Coastal Strip North of Gaza in Israeli Hand', Daily Bulletin, 7 November 1948",
              "https://www.jta.org/archive/egyptians-retreat-from-majdal-area-entire-coastal-strip-north-of-gaza-in-israeli-hand",
              ["Egyptian troops withdrew from the Majdal pocket; Israeli forces marched into the Majdal area"])
FRUS736 = src("S2068", "FRUS 1948 vol. V part 2, doc. 736: The Special Representative of the United States in Israel (McDonald) to the Acting Secretary of State, 5 November 1948",
              "https://history.state.gov/historicaldocuments/frus1948v05p2/d736",
              ["Egyptians voluntarily withdrew from Isdud and Majdal (reported 5 Nov 1948)"])
JTA_RAM = src("S2069", "Jewish Telegraphic Agency, 'Ramleh Surrenders to Jews; Israeli Forces Fan out in Major Drive in Central Palestine', Daily Bulletin, 13 July 1948",
              "https://www.jta.org/archive/ramleh-surrenders-to-jews-israeli-forces-fan-out-in-major-drive-in-central-palestine",
              ["Ramleh surrendered to Israeli forces", "Arab Legion and other troops held the Lydda-Ramleh pocket", "Tulkarm and Jenin anchored the Iraqi-held 'triangle'"])
JTA_HIR = src("S2070", "Jewish Telegraphic Agency, 'U.N. Cease-fire in Effect on Palestine's Northern Front, Kaukaji's Forces Smashed', Daily Bulletin, 1 November 1948",
              "https://www.jta.org/archive/u-n-cease-fire-in-effect-on-palestines-northern-front-kaukajis-forces-smashed",
              ["cease-fire on the northern Galilee front after Qawuqji's forces were beaten (end of October 1948)"])
JTA_BUN = src("S2071", "Jewish Telegraphic Agency, 'Security Council Gets Report from Mediator Reviewing Fighting in North Palestine Area', Daily Bulletin, 8 November 1948",
              "https://www.jta.org/archive/security-council-gets-report-from-mediator-reviewing-fighting-in-north-palestine-area",
              ["Bunche report: Israeli forces occupied the area in Galilee formerly controlled by Qawuqji's forces (events 21 Oct - 1 Nov 1948)"])
JTA_IRQ = src("S2072", "Jewish Telegraphic Agency, 'Over 100 Egyptians Killed in Enemy Attack in Negev; U.N. Announces Israeli-Iraqi Pact', Daily Bulletin, 9 December 1948",
              "https://www.jta.org/archive/over-100-egyptians-killed-in-enemy-attack-in-negev-u-n-announces-israeli-iraqi-pact",
              ["cease-fire with Iraqi units covering the entire Iraqi front from Ras el Ain to Beisan"])
FRUS486 = src("S2073", "FRUS 1948 vol. V part 2, doc. 486: Report by the Central Intelligence Agency, 27 July 1948",
              "https://history.state.gov/historicaldocuments/frus1948v05p2/d486",
              ["between the truces (9-18 July 1948) Israeli forces captured Lydda and Ramle and took Nazareth"])
ZO_RUW = src("S2074", "Zochrot, al-Ruways (village page, Nakba Map; background text after W. Khalidi (ed.), All That Remains, 1992), zochrot.org",
             "https://www.zochrot.org/villages/village_details/49476/en",
             ["Nazareth occupied 16 July 1948; Seventh Brigade then took Acre-district villages and moved towards Sakhnin"])
ZO_MUJ = src("S2075", "Zochrot, al-Mujaydil (village page, Nakba Map; background text after W. Khalidi (ed.), All That Remains, 1992), zochrot.org",
             "https://www.zochrot.org/villages/village_details/49285/en",
             ["the assault on Nazareth (14-16 July 1948) was launched from the previously occupied town of Shafa 'Amr"])
PQ_HIR = src("S2076", "Institute for Palestine Studies, PalQuest, 'Operation Hiram' (28-31 October 1948)",
             "https://www.palquest.org/node/25291",
             ["Operation Hiram 28-31 October 1948 against the last Arab-held pocket in Galilee"])
PQ_YOAV = src("S2077", "Institute for Palestine Studies, PalQuest, 'Operation Yoav' (15 October - 4 November 1948)",
              "https://www.palquest.org/node/25299",
              ["Egyptian units controlled the coastal strip as far north as Isdud"])
PQ_IV = src("S2078", "Institute for Palestine Studies, PalQuest, 'IV. The Palestine War and the Nakba, 1947-1950' (highlight)",
            "https://www.palquest.org/en/highlight/31109/iv-palestine-war-and-nakba",
            ["Egyptian forces controlled Gaza while Jordanian and Iraqi troops held the West Bank and East Jerusalem"])
JTA_T1 = src("S2079", "Jewish Telegraphic Agency, 'Israeli Cabinet Hears Report on Evacuation of Arab Troops from \"Bloody Triangle\"', Daily Bulletin, 8 May 1949",
             "https://www.jta.org/archive/israeli-cabinet-hears-re-port-on-evacuation-of-arab-troops-from-bloody-triangle",
             ["Arab Legion began evacuating forward positions in the triangle on 8 May 1949, in stages over three days"])
JTA_T2 = src("S2080", "Jewish Telegraphic Agency, 'Arab Legion Troops Evacuate Another Portion of Territory Ceded to Israel by Rhodes Pact', Daily Bulletin, 10 May 1949",
             "https://www.jta.org/archive/arab-legion-troops-evacuate-another-portion-of-territory-ceded-to-israel-by-rhodes-pact",
             ["four withdrawals in the triangle completed; most villagers stayed"])
JTA_T3 = src("S2081", "Jewish Telegraphic Agency, 'Israel Highway Between Haderah and Afula Reopened Following Arab Legion Evacuation', Daily Bulletin, 22 May 1949",
             "https://www.jta.org/archive/israel-highway-between-haderah-and-afula-reopened-following-arab-legion-evacuation",
             ["Arab Legion withdrew from its positions at Umm al-Fahm; Hadera-Afula road open"])
JTA_T4 = src("S2082", "Jewish Telegraphic Agency, 'Arab Legion Forces Evacuate Additional Strip of Territory in Central Palestine Area', Daily Bulletin, 23 May 1949",
             "https://www.jta.org/archive/arab-legion-forces-evacuate-additional-strip-of-territory-in-centpal-palestine-area",
             ["evacuation of the strip from Umm al-Fahm to Jatt"])
JVL_AG = src("S2083", "Encyclopaedia Judaica via Jewish Virtual Library, 'Abu Ghosh'",
             "https://jewishvirtuallibrary.org/abu-ghosh",
             ["relations between Abu Ghosh villagers and Jews remained friendly in the War of Independence; some villagers cooperated with the Haganah and Lehi"])

def U(sid):
    return next(s for s in SOURCES if s["id"] == sid)["url"]

def cite(claim, source, url, quote):
    return {"claim": claim, "source": source, "url": url, "quote": quote}

JVL_BS = "https://www.jewishvirtuallibrary.org/beersheba"
PQ_LYD = "https://www.palquest.org/en/highlight/24073/lydda-9-13-july-1948"
AVALON = "https://avalon.law.yale.edu/20th_century/arm03.asp"

# every city the lead's first city_fixes_b set (must stay in this file, or apply.py would lose the fix)
LEAD_IDS = ["jerusalem", "haifa", "tiberias", "safed", "daliyat_al_karmel", "abu_ghosh", "jisr_az_zarqa", "majdal_shams", "quneitra",
            "hebron", "nablus", "ramallah", "bethlehem", "jenin", "tulkarm", "qalqilya", "jericho",
            "gaza_city", "khan_yunis", "rafah", "deir_al_balah", "jabalia", "beersheba", "ashkelon", "lod", "ramla", "acre",
            "nazareth", "shefaram", "kafr_kanna", "tamra", "sakhnin", "arraba",
            "umm_al_fahm", "tayibe", "tira", "kafr_qasim", "baqa_al_gharbiyye"]

FN = {  # founded_note overrides (current ones empty or thin)
    "jenin": "Ancient town at the edge of the Jezreel Valley; an Arab town of the Mandate's Samaria district.",
    "tulkarm": "Ottoman-era market town on the eastern edge of the Sharon plain.",
    "qalqilya": "Long-established Arab town on the eastern edge of the Sharon plain.",
    "khan_yunis": "Town grown around a 14th-century Mamluk caravanserai (khan) in the southern Gaza Strip.",
    "deir_al_balah": "Ancient town in the central Gaza Strip.",
    "ramallah": "Christian town north of Jerusalem, settled in the 16th century; seat of the Palestinian Authority government.",
    "haifa": "Ottoman-era port city (re-founded in the 1760s); mixed Arab-Jewish city under the Mandate, taken by the Haganah in April 1948.",
    "tiberias": "Ancient city (founded c. 20 CE) on the Sea of Galilee, one of Judaism's four holy cities.",
    "safed": "Ancient hill city, one of Judaism's four holy cities.",
    "beit_shean": "Ancient town (Baysan), taken by the Haganah on 12 May 1948; CBS dates the Israeli locality to 1948.",
}

PATCH, FLAGS = {}, []

def st(cid):
    return copy.deepcopy(D[cid].get("status") or [])

def addcite(entry, *cs):
    have = {(c.get("source"), c.get("quote")) for c in entry.get("cite") or []}
    new = [c for c in cs if (c["source"], c["quote"]) not in have]
    entry["cite"] = list(entry.get("cite") or []) + new
    entry["source"] = list(dict.fromkeys(list(entry.get("source") or []) + [c["source"] for c in cs]))

def dropcites(entry, *sids):
    entry["cite"] = [c for c in entry.get("cite") or [] if c["source"] not in sids]
    entry["source"] = [s for s in entry.get("source") or [] if s not in sids]

def put(cid, status=None):
    c = D[cid]
    d = {"founded": "pre-1948", "founded_note": FN.get(cid) or c.get("founded_note")}
    assert d["founded_note"], cid
    if status is not None:
        d["status"] = status
    PATCH[cid] = d

def pre_first(s):
    assert s[0]["from"] == "1948-05-14", s[0]
    return s[0]

# ---------------------------------------------------------------- West Bank / Gaza: from the game-start day, not "1948-05"
for cid in ("hebron", "nablus", "ramallah", "bethlehem", "jenin", "tulkarm", "qalqilya", "jericho",
            "gaza_city", "khan_yunis", "rafah", "deir_al_balah", "jabalia"):
    s = st(cid)
    if s[0]["from"] == "1948-05":
        s[0]["from"] = "1948-05-14"
    addcite(s[0], cite("Egyptian forces held Gaza; Jordanian and Iraqi troops held the West Bank (1948 war)", PQ_IV, U(PQ_IV),
                       "Of the other 23 percent of Palestine, Egyptian forces controlled Gaza while Jordanian and Iraqi troops held onto the West Bank and East Jerusalem"))
    put(cid, s)

# ---------------------------------------------------------------- taken before statehood: Haifa, Tiberias, Safed, Beit Shean
s = st("haifa"); addcite(s[0], cite("Haganah offensive on Haifa from 21 April 1948 (before statehood)", PQN, U(PQN),
    "Attacks on Haifa beginning on 21 April prompted a mass exodus of the city's 55,000 remaining Palestinians; they sailed to Lebanon."))
s[0]["note"] = "Taken by the Haganah on 21-22 April 1948, before the declaration of independence; most of its Arab population left."
put("haifa", s)
s = st("tiberias"); addcite(s[0], cite("Tiberias fell on 18 April 1948 (before statehood)", PQN, U(PQN),
    "Tiberias, which had 5,000 Arab residents, was the first of these to fall; its inhabitants were expelled on 18 April."))
s[0]["note"] = "Taken by the Haganah in April 1948, before the declaration of independence; its Arab residents left or were expelled on 18 April."
put("tiberias", s)
s = st("safed"); addcite(s[0], cite("Safed taken between mid-April and early May 1948 (before statehood)", PQN, U(PQN),
    "Attacks on Safad, which had about 9,500 Arab inhabitants, from the middle of April until the beginning of May, culminated in the expulsion of all of its residents."))
s[0]["note"] = "Taken by the Palmach in early May 1948, before the declaration of independence; its Arab residents fled or were expelled."
put("safed", s)
s = st("beit_shean")
addcite(s[0], cite("taken by the Haganah on 12 May 1948, three days before statehood", BR_BS, U(BR_BS),
                   "it was taken by the Haganah , the Jewish defense forces, on May 12, 1948, three days before the proclamation of Israel's statehood"),
        cite("Baysan occupied on 12 May", PQN, U(PQN), "Baysan and its surrounding villages were occupied on 12 May"))
put("beit_shean", s)   # founded was "1948" -> "pre-1948"

# ---------------------------------------------------------------- Acre, Lod, Ramla
s = st("acre"); p = pre_first(s)
addcite(p, cite("Acre was held by Arab forces until occupied by regular Israeli troops on 17 May 1948", BR_ACRE, U(BR_ACRE), "Acre was occupied by regular Israeli troops on May 17."),
        cite("IPS dates the fall of Acre to 16 May", PQN, U(PQN), "Baysan and its surrounding villages were occupied on 12 May, followed by the coastal city of Acre on 16 May."))
addcite(s[1], cite("date: 17 May 1948; about 3,000 Arabs remained", BR_ACRE, U(BR_ACRE),
                   "Acre was occupied by regular Israeli troops on May 17. Though most of the city's Arab inhabitants fled during the Israeli takeover, about 3,000 remained"))
put("acre", s)

s = st("lod"); p = pre_first(s)
p["note"] = "Allotted to the Arab state by the 1947 partition plan; held by local defenders with Arab Legion (Transjordan) units until Operation Dani."
addcite(p, cite("Lod was held with Transjordan's Arab Legion", BR_LOD, U(BR_LOD),
                "When the resolution was rejected by the Arab states, Lod was occupied by the invading Arab Legion of Jordan."),
        cite("Arab Legion and other troops in the Lydda-Ramleh pocket (July 1948)", JTA_RAM, U(JTA_RAM),
             "Military observers here believe that several thousand Arab Legion and other troops surrounded and cut off in the Lydda-Ramleh pocket will surrender without a major battle."))
addcite(s[1], cite("date: assault on 11 July; Israeli forces entered the city that evening", "S117", PQ_LYD,
                   "On the morning of 11 July, Israeli aircraft dropped leaflets that called on the people of Lydda to surrender ... They entered the city in the evening and immediately began shooting indiscriminately."),
        cite("Lydda and Ramle captured between the truces", FRUS486, U(FRUS486), "During that period the Jews captured Lydda, Ramie, and Ras el Zin"))
put("lod", s)

s = st("ramla"); p = pre_first(s)
p["note"] = "Allotted to the Arab state by the 1947 partition plan; held by local forces and Transjordan's Arab Legion, blocking the Tel Aviv-Jerusalem road, until it surrendered in Operation Dani."
addcite(p, cite("Ramla was held with Transjordan's Arab Legion", BR_RAM, U(BR_RAM),
                "During the Arab-Israeli War of 1948–49, Ramla and its environs were invaded by Transjordan's Arab Legion"))
addcite(s[1], cite("date: the Israelis took the city on 12 July 1948", BR_RAM, U(BR_RAM), "the legion was attacked by the Israelis, who took the city on July 12, 1948"),
        cite("Ramleh surrendered (JTA bulletin of 13 July 1948)", JTA_RAM, U(JTA_RAM),
             "The Arab town of Ramleh today surrendered to Israeli forces which yesterday fought their way into its streets."))
put("ramla", s)

# ---------------------------------------------------------------- Ashkelon / al-Majdal: Egyptian-held
s = st("ashkelon"); p = pre_first(s)
p["status"] = "egyptian_held"
p["note"] = "Arab town of al-Majdal, held by the Egyptian army (the 'Majdal pocket' on the coastal strip) until the Egyptians withdrew along the beach in early November 1948."
addcite(p, cite("Egyptian units held the coastal strip as far north as Isdud", PQ_YOAV, U(PQ_YOAV), "Egyptian units controlled the coastal strip as far north as Isdud."),
        cite("Egyptian troops withdrew from the Majdal pocket", JTA_MAJ, U(JTA_MAJ),
             "following the withdrawal of Egyptian troops from the Majdal pocket, northeast of Gaza, last night and today"))
addcite(s[1], cite("Egyptian withdrawal from Majdal reported on 5 November 1948", FRUS736, U(FRUS736), "On contrary, Egyptians voluntarily withdrew from Isdud and Majdal."),
        cite("Israeli forces entered al-Majdal", JTA_MAJ, U(JTA_MAJ), "The Jews immediately marched into the entire Majdal area"))
put("ashkelon", s)

# ---------------------------------------------------------------- Beersheba
s = st("beersheba"); p = pre_first(s)
addcite(p, cite("after the declaration of independence the invading Egyptian army made Beersheba its headquarters", "S158", JVL_BS,
                "Following the declaration of independence of the State of Israel , the invading Egyptian army made Beersheba its headquarters."))
put("beersheba", s)

# ---------------------------------------------------------------- Nazareth, Shefa-Amr (Operation Dekel)
s = st("nazareth"); p = pre_first(s)
addcite(p, cite("Nazareth was a major base of Qawuqji's Arab Liberation Army", JTA_NAZ2, U(JTA_NAZ2),
                "The city, which had been converted into a major base by Fawzi el Kaukuji and his \u201cLiberation Army,\u201d was entered by a small detachment of Jewish troops immediately after the outflanked guerrilla units withdrew by the last remaining exit."))
addcite(s[1], cite("date: Nazareth occupied on 16 July 1948", ZO_RUW, U(ZO_RUW), "After occupying Nazareth on 16 July 1948, units of the Israeli army's Seventh Brigade advanced into Western Galilee"),
        cite("Israeli forces reached the outskirts of Nazareth (JTA bulletin of 16 July 1948)", JTA_NAZ1, U(JTA_NAZ1), "Israeli forces today entered the outskirts of the city of Nazareth"),
        cite("Israeli forces took Nazareth between the truces (9-18 July)", FRUS486, U(FRUS486), "In the north they took the strategic Arab-Christian town of Nazareth"))
put("nazareth", s)

s = st("shefaram")
addcite(s[1], cite("Shafa Amr already in Israeli hands when the push on Nazareth began (JTA bulletin of 16 July 1948)", JTA_NAZ1, U(JTA_NAZ1),
                   "Last night the Jews pushed toward from captured Shafa Amr, on Nazareth's northwestern perimeter, and captured nearby Iblin"),
        cite("the assault on Nazareth came from the previously occupied town of Shafa 'Amr", ZO_MUJ, U(ZO_MUJ),
             "the assault on Nazareth proceeded from the northwest, by Israeli units concentrated in the previously occupied town of Shafa 'Amr."))
put("shefaram", s)

# ---------------------------------------------------------------- Sakhnin, Arraba (Operation Hiram): ALA cites instead of the 1966 military-government cites
for cid, nm in (("sakhnin", "Sakhnin"), ("arraba", "Arraba")):
    s = st(cid); p = pre_first(s)
    dropcites(p, "S150", "S1255")
    p["note"] = (f"{nm} lay in the central Galilee pocket held by Fawzi al-Qawuqji's Arab Liberation Army after Operation Dekel (July 1948) "
                 "until Operation Hiram (28-31 October 1948).")
    addcite(p, cite("the Galilee pocket was held by Qawuqji's forces until Israeli forces occupied it (Bunche report on 21 Oct - 1 Nov 1948)", JTA_BUN, U(JTA_BUN),
                    "\u201cIsraeli forces have occupied the area in Galilee formerly controlled by Fawzi el Kaukaji's forces and have crossed the Lebanese frontier,\u201d the report stated."),
            cite("Operation Hiram targeted the last Arab-held pocket in Galilee", PQ_HIR, U(PQ_HIR), "a reference to the last pocket of Arab resistance in Galilee"))
    addcite(s[1], cite("Operation Hiram, 28-31 October 1948", PQ_HIR, U(PQ_HIR), "Start Date 28 October 1948 End Date 31 October 1948"),
            cite("Qawuqji's forces beaten; cease-fire on the northern front (JTA bulletin of 1 November 1948)", JTA_HIR, U(JTA_HIR),
                 "The cease-fire, however, went into effect after the Jews had beaten Fawzi el Kaukaji's forces decisively."))
    put(cid, s)
FLAGS.append("sakhnin, arraba: Israeli status still starts at month level '1948-10' (Operation Hiram, 28-31 Oct 1948). Morris gives 30 October for the surrender of the Sakhnin-Arraba-Deir Hanna pocket, but no opened page names these towns with a day.")
FLAGS.append("tamra, kafr_kanna: kept at month level '1948-07' (Operation Dekel, 8-18 July 1948). Neighbouring al-Damun/al-Ruways fell 15-16 July (Zochrot/PalQuest), but no opened page names Tamra or Kafr Kanna with a day.")

# ---------------------------------------------------------------- Little Triangle: Iraqi-held -> Jordanian-held (Rhodes, 3 Apr 1949) -> Israeli at handover
TRI_IRQ = [cite("the Triangle front was held by Iraqi forces in 1948", JTA_IRQ, U(JTA_IRQ), "The agreement covers the entire Iraqi front, from Ras el Ain to Beisan"),
           cite("Tulkarm and Jenin anchored the Iraqi-held 'triangle'", JTA_RAM, U(JTA_RAM), "anchor points of the Iraqi-held \u201ctriangle\u201d in central Palestine")]
TRI_JOR = [cite("Rhodes armistice: Jordanian forces replace Iraqi forces in their sector", "S112", AVALON,
                "It is agreed that the forces of the Hashemite Jordan Kingdom shall replace the forces of Iraq in the sector now held by the latter forces"),
           cite("Jordan accepts responsibility for the Iraqi forces", "S112", AVALON, "The Hashemite Jordan Kingdom accepts responsibility for all Iraqi forces in Palestine.")]
C_T1 = cite("the Arab Legion began evacuating its forward positions in the triangle on 8 May 1949, in stages over three days", JTA_T1, U(JTA_T1),
            "Arab Legion forces began evacuation today of forward positions in the triangle area and retirement to the new demarcation line fixed in the Israeli-Trans Jordan armistice last month. The operation will take three days and will be carried out in stages.")
C_T3 = cite("the Arab Legion withdrew from its positions at Umm al-Fahm (JTA bulletin of 22 May 1949)", JTA_T3, U(JTA_T3),
            "following withdrawal of Arab Legion forces from their advanced positions at Um E1 Fahm, which dominated the highway")
C_T4 = cite("evacuation of the strip from Umm al-Fahm to Jatt (JTA bulletin of 23 May 1949)", JTA_T4, U(JTA_T4),
            "Evacuation by Arab Legion forces of an additional strip of territory in the so-called Arab triangle–from Urn el Fahm to Jatt–began early today")
C_T2 = cite("most villagers in the evacuated Triangle areas stayed", JTA_T2, U(JTA_T2),
            "Most of the inhabitants in the Arab villages in the evacuated areas, estimated it several thousand, have elected to stay behind.")
HANDOVER = {"kafr_qasim": ("1949-05-08", "a", [C_T1]), "tira": ("1949-05-08", "a", [C_T1]), "tayibe": ("1949-05-08", "a", [C_T1]),
            "umm_al_fahm": ("1949-05-22", "b", [C_T3, C_T4]), "baqa_al_gharbiyye": ("1949-05", "?", [C_T1, C_T4])}
MG = " Arab localities in Israel were placed under military government (movement permits under emergency regulations) until it was abolished on 1 December 1966."
for cid in ("umm_al_fahm", "tayibe", "tira", "kafr_qasim", "baqa_al_gharbiyye"):
    s = st(cid)
    assert s[0]["status"] == "iraqi_then_jordanian_held", (cid, s[0]["status"])
    day, stage, hc = HANDOVER[cid]
    old = s[0]
    irq = {"from": "1948-05-14", "to": "1949-04-03", "status": "arab_held",
           "note": "On the 'Triangle' front held by the Iraqi expeditionary force from May 1948 (outside Israeli control).", "source": [], "cite": []}
    addcite(irq, *TRI_IRQ)
    jor = {"from": "1949-04-03", "to": day, "status": "jordanian_held",
           "note": "Under the Israel-Jordan General Armistice Agreement (Rhodes, 3 April 1949) Jordan's Arab Legion replaced the Iraqi forces and took responsibility for this sector until it was handed over to Israel under Article VI.",
           "source": [], "cite": []}
    addcite(jor, *TRI_JOR, *[c for c in old.get("cite") or [] if c["source"] == "S1294"])
    isr = s[1]
    isr["from"] = day
    where = ("west of the Baqa-Jaljulia road (Article VI 3(a), within five weeks of signature); the Arab Legion began evacuating these forward positions on 8 May 1949"
             if stage == "a" else
             "in Wadi Ara (Article VI 3(b), within seven weeks of signature); the Arab Legion left its positions at Umm al-Fahm around 22 May 1949" if stage == "b" else
             "in the Baqa area; the Arab Legion evacuated the ceded Triangle areas in stages between 8 and 23 May 1949 and the exact day for Baqa is not established in the sources consulted")
    isr["note"] = "Handed over to Israel under Article VI of the Israel-Jordan armistice, " + where + "; residents kept rights of residence and property and became Israeli citizens." + MG
    addcite(isr, *hc, C_T2)
    put(cid, [irq, jor] + s[1:])
FLAGS.append("Little Triangle (umm_al_fahm, tayibe, tira, kafr_qasim, baqa_al_gharbiyye): the non-standard status 'iraqi_then_jordanian_held' (no map badge) is replaced by arab_held (Iraqi front, 1948-05-14 to 1949-04-03) + jordanian_held (Rhodes armistice 1949-04-03 to handover). Israeli from: kafr_qasim/tira/tayibe 1949-05-08 (start of the 3-day Arab Legion evacuation under Article VI 3(a), JTA 8 May 1949), umm_al_fahm 1949-05-22 (JTA 22-23 May 1949). baqa_al_gharbiyye stays month-level '1949-05' (unclear whether it fell in the 8-10 May or the 22-23 May stage).")

# ---------------------------------------------------------------- Abu Ghosh, Jisr az-Zarqa: Israeli-held from statehood (cite the basis)
s = st("abu_ghosh")
s[0]["note"] = ("On the Tel Aviv-Jerusalem road in the corridor the Haganah secured in April-May 1948; its villagers kept friendly relations with the Jewish side "
                "(some cooperated with the Haganah and Lehi) and most remained, so it is treated as Israeli-held from statehood.")
addcite(s[0], cite("villagers' relations with Jews stayed friendly in the War of Independence; some cooperated with the Haganah and Lehi", JVL_AG, U(JVL_AG),
                   "relations between the villagers and Jews were friendly and remained so in the Israeli War of Independence. Some of the villagers cooperated with the"))
put("abu_ghosh", s)
s = st("jisr_az_zarqa")
s[0]["note"] = ("Coastal village in the Jewish-held plain between Tel Aviv and Haifa; it and al-Faradis were the only Arab villages there not depopulated in May-July 1948, "
                "so it is treated as Israeli-held from statehood.")
addcite(s[0], cite("only al-Faradis and Jisr al-Zarqa remained of the coastal villages between Tel Aviv and Haifa", PQN, U(PQN),
                   "Before that date, sixty-four Palestinian villages in the region extended from Tel Aviv to Haifa; after the ethnic cleansing operations that took place there between May and July 1948, only two villages remained–– al-Faradis and Jisr al-Zarqa"))
put("jisr_az_zarqa", s)

# ---------------------------------------------------------------- everything else the lead's version set (founded only, status unchanged)
for cid in LEAD_IDS:
    if cid not in PATCH:
        put(cid, st(cid))   # carry status as-is so this file alone reproduces the lead's fix

FLAGS.append("daliyat_al_karmel: kept 'israel' from 1948-05-14 (Druze village on Mount Carmel in the Haifa area held by the Haganah from April 1948); no opened page dates its coming under Israeli control, so the status still rests on S100 only.")
FLAGS.append("abu_ghosh, jisr_az_zarqa: kept 'israel' from 1948-05-14 (villages that stayed inside Jewish-held areas, no capture); cites added for that basis, but no source dates a formal takeover.")
FLAGS.append("West Bank: Jenin, Nablus, Tulkarm and Qalqilya were held by the Iraqi army until spring 1949, not by Jordan. They are left as jordanian_administered from 1948-05-14, as instructed; they could be split into arab_held and then jordanian_administered at 1949-04-03, as done for the Little Triangle.")
FLAGS.append("This file supersedes the earlier city_fixes_b.json written by city_fixes_b_build.py. It carries that version's S2050-S2053 and every city it set, so do not re-run city_fixes_b_build.py, which would overwrite this file. New sources are S2060-S2083.")

def dump():
    out = {"cities": [{"id": k, "set": v} for k, v in PATCH.items()], "sources": SOURCES, "flags": FLAGS}
    json.dump(out, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print("wrote", OUT, len(PATCH), "cities", len(SOURCES), "sources")

if __name__ == "__main__":
    dump()
