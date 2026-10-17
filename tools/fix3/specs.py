import json
C = {}
for f in ("cands.json", "cands2.json"):
    for q, lst in json.load(open("C:/civ/work_fix3/" + f, encoding="utf-8")).items():
        for x in lst:
            C[x["title"]] = x

def find(sub):
    m = [v for k, v in C.items() if sub in k]
    assert m, sub
    return m[0]

# id, caption, photo-title-substring or None, scene description
S = [
("evt_1948_altalena", "The Altalena burns off Tel Aviv, 22 June 1948", 'Burning "Altalena"', "The arms ship Altalena burning and smoking off the Tel Aviv beach, crowds of onlookers on the shore watching from a distance, summer 1948."),
("evt_1948_latrun_battles", "Latrun, May 1948", "Latrun (997009322899505171", "Hot dusty hills near the Latrun police fort, Israeli soldiers in 1948 mixed uniforms resting and moving along a dirt road, summer 1948."),
("evt_1948_bernadotte", "UN mediator Count Folke Bernadotte, 1948", "Folke Bernadotte in 1943", "Portrait of Count Folke Bernadotte, a tall Swedish diplomat, in a dark suit with a white UN armband, 1948."),
("evt_1948_beersheba_capture_arab_residents_removed", "Beersheba, October 1948", "Beersheba 1948.jpg", "Israeli soldiers walking through the dusty streets of Beersheba, low stone buildings and a mosque minaret, October 1948."),
("evt_1948_operation_horev", "Negev Brigade soldiers, December 1948", "Negev Brigade soldiers 1948", "Negev Brigade soldiers in desert terrain in the winter of 1948, jeeps and soldiers advancing across the Negev."),
("evt_1948_operation_hiram", "Operation Hiram in the Galilee, October 1948", "Hiram Sasa Attack", "Israeli soldiers moving through rocky Galilee hills near the village of Sasa, October 1948, calm composition."),
("evt_1949_armistice_jordan", "Israeli delegation at the Rhodes armistice talks, 1949", "Moshe Dayan and Walter Eytan (997008137544105171", "Moshe Dayan and Walter Eytan in civilian clothes at the armistice talks on Rhodes, 1949, a hotel room with a table."),
("evt_1950_jerusalem_capital", "The Knesset in Jerusalem, 1949-50", "First Knesset, Jerusalem (997008136747805171", "The first Knesset in session in Jerusalem, members seated, speaker at the podium, 1949-50."),
("evt_1949_kiryat_shmona", "A ma'abara transit camp, early 1950s", "Ma'abara (997009323982805171", "A ma'abara immigrant transit camp of tents and tin huts in the early 1950s, families and children outside, Galilee hills behind."),
("evt_1950_beit_shemesh", "Immigrant tents at Hartuv, early 1950s", "tents in the aisles", "New immigrants living in tents and huts in a Judean hills transit camp, early 1950s, women hanging washing."),
("evt_1951_election", "Soldiers vote in the Second Knesset election, 1951", "SoldElect51", "Israeli soldiers in uniform casting ballots at a polling table in 1951."),
("evt_1952_weizmann_dies", "Funeral of President Chaim Weizmann, Rehovot, 1952", "Chaim Weizmann funeral, Rehovot (997008136197505171", "A solemn state funeral procession in Rehovot in November 1952, mourners with the flag-draped coffin on a carriage, dignified."),
("evt_1953_ben_gurion_sde_boker", "Ben-Gurion's hut at Sde Boker", "Sde Boker - Ben Gurion Home (3)", "The simple wooden hut of David Ben-Gurion at Kibbutz Sde Boker in the Negev desert, evening light."),
("evt_1955_kasztner_verdict", "Rudolf Kasztner, 1950s", "Rudolf Kastner at Kol Yisrael", "Rudolf Kasztner, a man in a 1950s suit, seated in a radio studio at a microphone."),
("evt_1957_sinai_withdrawal", "UN Emergency Force in the Sinai, 1957", "Lynn Garrison 115 ATU, UNEF", "UN Emergency Force soldiers with light-blue helmets and vehicles in the Sinai desert in 1957."),
("evt_1959_wadi_salib", "Wadi Salib, Haifa", "Wadi Salib 02", "The old stone neighbourhood of Wadi Salib on a hillside in Haifa, narrow lanes and old Arab-style houses, 1959."),
("evt_1963_eshkol_pm", "Levi Eshkol, Prime Minister from June 1963", "Portrait of prime minister Levy Eshkol", "Portrait of Prime Minister Levi Eshkol, a heavyset man in a 1960s suit and glasses, seated at his desk."),
("evt_1969_war_of_attrition", "The Bar-Lev Line on the Suez Canal", "Bar Lev Line, November 1970", "Israeli fortification of the Bar-Lev Line on the east bank of the Suez Canal, sand ramparts and bunkers, 1970."),
("evt_1973_agranat_commission", "The Agranat Commission, 1973-74", "Agranat92-1", "Judges of the Agranat Commission seated at a long table in a hearing room, 1974."),
("evt_1978_nobel_peace", "Begin, Carter and Sadat at Camp David, 1978", "Begin, Carter and Sadat at Camp David 1978", "Menachem Begin, Jimmy Carter and Anwar Sadat standing together outdoors at Camp David in autumn 1978."),
("evt_1981_golan_heights_law", "The Golan Heights", "117449 golan heights", "The Golan Heights landscape, volcanic hills and fields with a distant snow-capped Mount Hermon, 1981."),
("evt_1985_us_fta", "Peres meets Reagan, 1985", "Reagan During a Working Visit to Prime Minister Shimon", "President Ronald Reagan and Prime Minister Shimon Peres at the White House in 1985."),
("evt_1987_lavi_cancelled", "The Lavi fighter prototype", "IAI-Lavi-B-2", "An Israeli Lavi fighter jet prototype in a hangar, mid-1980s, engineers around it."),
("evt_1987_first_intifada", "Gaza, December 1987", "Intifada in Gaza Strip (FL45956268", "A street scene in Gaza at the start of the First Intifada, tense but peaceful, soldiers and civilians standing apart in a quiet dusty street, no violence."),
("evt_1990_unity_government_falls", "Yitzhak Shamir, 1990", "Yitzhak Shamir in his office (FL62949795", "Prime Minister Yitzhak Shamir at his office desk, a short grey-haired man in a suit, 1990."),
("evt_1995_oslo_ii", "The Rabins arrive for the Oslo II signing, September 1995", "Rabin couple on their way to the signing ceremony of the Oslo II", "Yitzhak and Leah Rabin walking on their way to the Oslo II signing ceremony in Washington, September 1995."),
("evt_1996_election", "Peres and the newly elected Netanyahu, 1996", "Meeting between PM Peres with newly elected PM Nethanyahu", "Shimon Peres and Benjamin Netanyahu meeting in an office after the 1996 election."),
("evt_2004_arafat_death", "Arafat's funeral in Cairo, November 2004", "Arafat's Cairo Funeral 002", "A solemn state funeral in Cairo, November 2004, a flag-draped coffin carried by honour guard soldiers, crowds around, dignified."),
("evt_2010_mavi_marmara", "The Mavi Marmara", "Mavi Marmara leaving port", "The passenger ship Mavi Marmara leaving a port with flags, calm sea, 2010."),
("evt_2010_carmel_fire", "The Mount Carmel fire, December 2010", "2010 Carmel forest - fire near Isfiya", "A forest fire on Mount Carmel with smoke rising above pine trees and a fire-fighting aircraft, December 2010."),
("evt_2010_leviathan_gas", "The Leviathan gas platform", "Leviathan gas field IMG 64281", "An offshore natural gas platform in the Mediterranean Sea off the Israeli coast, calm sea, sunset."),
("evt_2011_shalit_exchange", "Welcome home, Gilad Shalit, October 2011", "Jerusalem banner Gilad Shalit Welcome home", "A big banner welcoming home Gilad Shalit hanging on a Jerusalem building, October 2011, no readable text."),
("evt_2015_netanyahu_congress_speech", "Netanyahu addresses the US Congress, March 2015", "Benjamin Netanyahu Congress", "Benjamin Netanyahu speaking at the podium of the US House chamber to Congress, March 2015."),
("evt_2020_annexation_suspended", "The Abraham Accords signing, September 2020", "Abraham Accords Signin", "A signing ceremony on the White House South Lawn, leaders at a table with flags, September 2020."),
("evt_2021_bennett_lapid_government", "The new Bennett-Lapid government, June 2021", "Thirty-sixth government of Israel, June 2021 (AVO 5997", "The new Israeli government ministers posing together for a group photo in June 2021."),
("evt_2023_judicial_overhaul_crisis", "Mass protests against the judicial overhaul, 2023", "anti-judicial reform protests - A big demonstration in Je", "A huge crowd with many Israeli flags marching on a Jerusalem highway at a protest, 2023, peaceful."),
("evt_2023_tel_aviv_light_rail", "The Tel Aviv Red Line light rail, August 2023", "Tel Aviv Light Rail Red line passangers.jpg", "Passengers on a modern Tel Aviv light rail Red Line carriage, August 2023."),
# no photo
("evt_1948_jewish_quarter_falls", "The Old City of Jerusalem, May 1948", None, "The Old City of Jerusalem in late May 1948: the stone lanes of the Jewish Quarter, a group of weary residents and defenders walking in a line under a white flag in the evening, dignified, no weapons pointed, no bodies."),
("evt_1948_second_truce", "UN observers during the second truce, July 1948", None, "UN truce observers in white uniforms and helmets standing beside a white jeep with a UN flag on a dusty road in summer 1948, Israeli and Arab soldiers waiting on either side."),
("evt_1948_unga_194", "UN General Assembly, Paris, December 1948", None, "The UN General Assembly hall at the Palais de Chaillot in Paris in December 1948, delegates in suits seated in rows, a speaker at the podium, no readable text."),
("evt_1949_lausanne_conference", "Lausanne Conference, 1949", None, "Delegates of Israel and Arab states at separate tables in a lakeside hotel conference room in Lausanne, Switzerland, spring 1949, a UN commission chair in the middle."),
("evt_1948_haredi_yeshiva_exemption", "Yeshiva students, 1948", None, "Young yeshiva students in black coats and hats studying together at long tables over open books in a crowded beit midrash in 1948 Jerusalem."),
("evt_1952_reparations_debate", "The reparations debate, January 1952", None, "The Knesset plenum in Jerusalem in January 1952 during a tense debate, a speaker at the podium and members listening gravely, and outside the building in the street a large crowd of citizens in 1950s clothes gathered, no violence."),
("evt_1954_lavon_affair", "The Lavon affair, 1954", None, "Defence Minister Pinhas Lavon and senior officers in 1954 around a table in a dim ministry office with files, grave faces."),
("evt_1961_shavit2", "Shavit 2 launch, July 1961", None, "A small Israeli Shavit 2 sounding rocket on its launch rail at a desert site near Palmachim, July 1961, scientists and technicians in shirts watching, bright sky."),
("evt_1964_plo_founded", "The first Palestinian National Council, 1964", None, "Hundreds of delegates in suits and keffiyehs seated in a hall in East Jerusalem in May 1964 during the first Palestinian National Council, a podium at the front, no readable text."),
("evt_1967_allon_plan", "The Allon Plan, July 1967", None, "Yigal Allon and colleagues leaning over a large relief map of the Jordan Valley and the West Bank on a table in 1967, pointing at the map, no readable text."),
("evt_1967_khartoum", "Arab League summit in Khartoum, 1967", None, "Arab heads of state in suits and robes seated at a long table at the Khartoum summit in September 1967, flags behind them, formal, no readable text."),
("evt_1967_eilat_sinking", "INS Eilat, 1967", None, "The Israeli destroyer INS Eilat sailing on a calm Mediterranean sea in 1967, grey ship with a flag, no damage."),
("evt_1968_dakar_lost", "INS Dakar", None, "The Israeli submarine INS Dakar surfaced at sea with crew standing on the conning tower in January 1968, grey sky, calm."),
("evt_1970_goldmann_nasser", "Nahum Goldmann, 1970", None, "Nahum Goldmann, an elderly Jewish leader with white hair in a suit, at a desk with a telephone and papers in 1970, a map of the Middle East on the wall."),
("evt_1973_unscr_338", "UN Security Council, October 1973", None, "The UN Security Council chamber in New York in October 1973, delegates at a horseshoe table in a late-night session, no readable text."),
("evt_1975_sinai_ii", "Kissinger's shuttle diplomacy, 1975", None, "Henry Kissinger in a 1970s suit shaking hands with a delegation on an airport runway beside a US Air Force jet, desert background, 1975."),
("evt_1975_unga_3379", "UN General Assembly, November 1975", None, "The UN General Assembly hall in November 1975, delegates seated, a delegate in a suit standing at the podium, no readable text."),
("evt_1975_sebastia", "Settlers at Sebastia, 1975", None, "Families of settlers with Israeli flags, tents and children on a rocky hill at Sebastia in Samaria in 1975, soldiers talking calmly to them."),
("evt_1977_maccabi_champions", "Maccabi Tel Aviv, European champions, 1977", None, "Maccabi Tel Aviv basketball players in yellow and blue uniforms celebrating with the European Champions Cup trophy in an indoor arena in 1977, crowd cheering."),
("evt_1978_eurovision", "Israel wins Eurovision, 1978", None, "A male singer in a 1970s disco-style outfit performing on a big Eurovision stage in Paris in 1978, orchestra in the pit, bright stage lights, no readable text."),
("evt_1978_peace_now", "Peace Now, 1978", None, "Tens of thousands of Israelis with banners and flags gathered in an open square in Tel Aviv at a Peace Now rally in 1978, hopeful and peaceful, no readable text."),
("evt_1982_lebanon_war", "Into Lebanon, June 1982", None, "A column of Israeli Merkava tanks and trucks driving north along a coastal road in southern Lebanon in June 1982, palm trees and the Mediterranean, soldiers in olive uniforms."),
("evt_1982_peace_now_rally", "Mass protest in Tel Aviv, September 1982", None, "A very large crowd of Israelis filling Kings of Israel Square in Tel Aviv at a night-time protest rally in September 1982, candles and banners, no readable text."),
("evt_1983_bank_shares_crisis", "The bank shares crisis, 1983", None, "Anxious investors in 1980s clothes crowded in front of a Tel Aviv stock exchange board and a bank counter, worried faces, no readable text."),
("evt_1984_election_rotation", "The rotation government, 1984", None, "Shimon Peres and Yitzhak Shamir shaking hands formally in a Knesset hall in 1984, other ministers around them."),
("evt_1985_security_zone", "Withdrawal to the security zone, 1985", None, "Israeli soldiers and armoured vehicles at a hilltop outpost on the southern Lebanese border in 1985, green hills and a border fence."),
("evt_1985_new_shekel", "The new shekel, 1985", None, "A hand placing new silver shekel coins and brand-new banknotes on a counter in a 1985 bank, clerk behind a glass window, no readable text or numbers."),
("evt_1988_palestinian_declaration", "Palestinian Declaration of Independence, Algiers, 1988", None, "Yasser Arafat in keffiyeh and olive uniform addressing a hall of delegates in Algiers in November 1988, Palestinian flags, no readable text."),
("evt_1997_hebron_protocol", "The Hebron Protocol, January 1997", None, "Israeli and Palestinian negotiators signing documents at a table in an office at the Erez crossing in January 1997, US envoy Dennis Ross looking on, no readable text."),
("evt_1998_eurovision_dana", "Dana International wins Eurovision, 1998", None, "A glamorous singer in a feathered colourful dress performing on a Eurovision stage in Birmingham, 1998, lights and cheering audience, no readable text."),
("evt_2000_camp_david", "The Camp David summit, July 2000", None, "Bill Clinton, Ehud Barak and Yasser Arafat on the lawn in front of a rustic Camp David cabin among trees in July 2000, Clinton in the middle with his arms outstretched."),
("evt_2002_arab_peace_initiative", "The Arab League summit in Beirut, March 2002", None, "Arab leaders seated around a large circular conference table at the Beirut Arab League summit in March 2002, flags, no readable text."),
("evt_2003_road_map", "The Aqaba summit, June 2003", None, "George W. Bush, Ariel Sharon and Mahmoud Abbas standing together on a seaside terrace at Aqaba in June 2003."),
("evt_2009_bar_ilan_speech", "Netanyahu's Bar-Ilan speech, June 2009", None, "Benjamin Netanyahu speaking at a lectern in a university hall in June 2009, an audience behind glass, no readable text."),
("evt_2009_settlement_freeze", "The settlement freeze, November 2009", None, "A construction site of a new housing neighbourhood on a West Bank hill with idle cranes and workers standing, an official handing a paper to a site manager, 2009."),
("evt_2012_unga_67_19", "UN General Assembly vote on Palestine, 29 November 2012", None, "The UN General Assembly hall in November 2012 with delegates applauding after a vote, the electronic voting board lit, no readable text."),
("evt_2015_jcpoa", "Nuclear talks in Vienna, July 2015", None, "Foreign ministers and diplomats seated around a table in an ornate Vienna palace room signing and concluding nuclear talks in July 2015, no readable text."),
("evt_2016_unscr_2334", "UN Security Council, December 2016", None, "The UN Security Council chamber in New York in December 2016, delegates raising hands to vote, no readable text."),
("evt_2017_us_jerusalem_recognition", "Jerusalem, December 2017", None, "The Old City of Jerusalem with the golden Dome of the Rock, towers and the skyline at dusk in December 2017, with a US flag and an Israeli flag on a rooftop."),
("evt_2018_nation_state_law", "The Knesset, July 2018", None, "The Knesset plenum at night in July 2018 during a vote, members seated and some standing, ushers, no readable text."),
("evt_2018_netta_eurovision", "Netta wins Eurovision, 2018", None, "A young female singer in a bright kimono-style outfit performing with a loop pedal on a Eurovision stage in Lisbon, 2018, lights and audience, no readable text."),
("evt_2018_us_embassy_jerusalem", "The US embassy opens in Jerusalem, May 2018", None, "A ceremony with US and Israeli flags in front of a modern stone building in Jerusalem, officials in suits at a podium, May 2018."),
("evt_2019_us_recognises_golan", "Trump recognises Israeli sovereignty over the Golan, March 2019", None, "Donald Trump at his desk in the Oval Office signing a proclamation with Benjamin Netanyahu standing beside him, March 2019, no readable text."),
("evt_2019_eurovision_tel_aviv", "Eurovision 2019 in Tel Aviv", None, "A giant colourful Eurovision stage in Tel Aviv in May 2019 with performers and a cheering audience, Tel Aviv skyline, no readable text."),
("evt_2020_trump_peace_plan", "The Trump plan is unveiled, January 2020", None, "Donald Trump and Benjamin Netanyahu at podiums in the White House East Room in January 2020, a large audience, no readable text."),
("evt_2020_covid_first_case", "COVID-19 reaches Israel, February 2020", None, "Medical staff in white protective suits and masks meeting a passenger at Ben Gurion Airport in February 2020, an empty terminal."),
("evt_2022_lebanon_maritime_deal", "Israel-Lebanon maritime agreement, October 2022", None, "A natural gas drilling vessel at sea off the Mediterranean coast with the Naqoura coastline in the distance at sunset, October 2022."),
]
SPECS = []
for i, cap, key, desc in S:
    sp = {"id": i, "caption": cap, "desc": desc}
    if key:
        sp["photo"] = find(key)
    SPECS.append(sp)
if __name__ == "__main__":
    json.dump(SPECS, open("C:/civ/work_fix3/specs.json", "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print(len(SPECS), sum(1 for s in SPECS if "photo" in s))
