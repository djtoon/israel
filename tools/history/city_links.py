# city status (id, from-prefix) -> (event ids whose verified cites back the status, keywords to prefer)
LINKS = {
 ("jerusalem", "1948"): (["evt_1949_armistice_jordan", "evt_1950_jerusalem_capital"], ["jerusalem"]),
 ("jerusalem", "1967"): (["evt_1967_jerusalem_unification", "evt_1980_jerusalem_law", "evt_2017_us_jerusalem_recognition"], ["jerusalem", "478"]),
 ("beersheba", "1948"): (["evt_1948_beersheba_capture_arab_residents_removed", "evt_1948_operation_yoav"], ["beersheba"]),
 ("ashkelon", "1948"): (["evt_1950_majdal_transfer"], ["majdal"]),
 ("beit_shemesh", "1950"): (["evt_1950_beit_shemesh"], ["shemesh", "har-tuv", "hartuv"]),
 ("kiryat_gat", "1954"): (["evt_1954_kiryat_gat"], ["gat"]),
 ("eilat", "1949"): (["evt_1949_operation_uvda"], ["rashrash", "eilat", "elat"]),
 ("karmiel", "1964"): (["evt_1964_karmiel"], ["karmiel"]),
 ("nof_hagalil", "1957"): (["evt_1957_nazareth_illit"], ["nazareth"]),
 ("mitzpe_ramon", "1954"): (["evt_1951_sderot_mitzpe_ramon"], ["ramon"]),
 ("maalot_tarshiha", "1948"): (["evt_1948_operation_hiram"], ["galilee", "hiram"]),
 ("lod", "1948"): (["evt_1948_lydda_ramle"], ["lydda", "lod"]),
 ("ramla", "1948"): (["evt_1948_lydda_ramle"], ["ramle", "ramla"]),
 ("acre", "1948"): (["evt_1948_arab_invasion", "evt_1948_palestinian_displacement"], ["acre"]),
 ("nazareth", "1948"): (["evt_1966_military_government_ends"], ["military"]),
 ("sakhnin", "1948"): (["evt_1966_military_government_ends", "evt_1948_operation_hiram"], ["military", "galilee"]),
 ("shefaram", "1948"): (["evt_1966_military_government_ends"], ["military"]),
 ("tamra", "1948"): (["evt_1966_military_government_ends"], ["military"]),
 ("kafr_kanna", "1948"): (["evt_1966_military_government_ends"], ["military"]),
 ("arraba", "1948"): (["evt_1966_military_government_ends", "evt_1948_operation_hiram"], ["military", "galilee"]),
 ("umm_al_fahm", "1949"): (["evt_1949_armistice_jordan", "evt_1966_military_government_ends"], ["triangle", "article vi", "military", "baqa"]),
 ("tayibe", "1949"): (["evt_1949_armistice_jordan", "evt_1966_military_government_ends"], ["triangle", "article vi", "military", "baqa"]),
 ("tira", "1949"): (["evt_1949_armistice_jordan", "evt_1966_military_government_ends"], ["triangle", "article vi", "military", "baqa"]),
 ("kafr_qasim", "1949"): (["evt_1949_armistice_jordan", "evt_1966_military_government_ends"], ["triangle", "kafr qasim", "military", "baqa"]),
 ("baqa_al_gharbiyye", "1949"): (["evt_1949_armistice_jordan", "evt_1966_military_government_ends"], ["triangle", "baqa", "military"]),
 ("majdal_shams", "1967"): (["evt_1967_displacement", "evt_1967_six_day_war"], ["golan", "syrian"]),
 ("hebron", "1997"): (["evt_1997_hebron_protocol"], ["hebron", "h1", "h2"]),
 ("ariel", "1978"): (["evt_2016_unscr_2334", "evt_1978_ariel"], ["settlement", "ariel"]),
 ("maale_adumim", "1975"): (["evt_2016_unscr_2334", "evt_1975_maale_adumim"], ["settlement", "adumim"]),
 ("modiin_illit", "1996"): (["evt_2016_unscr_2334"], ["settlement"]),
 ("beitar_illit", "1985"): (["evt_2016_unscr_2334"], ["settlement"]),
 ("kiryat_arba", "1972"): (["evt_2016_unscr_2334", "evt_1968_hebron_kiryat_arba"], ["settlement", "kiryat arba"]),
 ("kfar_etzion", "1967"): (["evt_1967_kfar_etzion"], ["etzion"]),
}
for _c in ["nablus", "ramallah", "bethlehem", "jenin", "tulkarm", "qalqilya"]:
    LINKS[(_c, "2002")] = (["evt_2002_defensive_shield"], ["defensive shield", "march 29", "29 march", "jenin"])
LINKS[("quneitra", "1967")] = (["evt_1967_displacement"], ["golan", "syrian"])
LINKS[("yamit", "1975")] = (["evt_1975_yamit"], ["yamit"])
LINKS[("yamit", "1982")] = (["evt_1982_sinai_withdrawal"], ["yamit"])
LINKS[("katzrin", "1981")] = (["evt_1981_golan_heights_law"], ["golan"])
LINKS[("majdal_shams", "1981")] = (["evt_1981_golan_heights_law"], ["golan", "majdal"])
LINKS[("neve_dekalim", "2005")] = (["evt_2005_gaza_disengagement"], ["settlement", "gaza"])
