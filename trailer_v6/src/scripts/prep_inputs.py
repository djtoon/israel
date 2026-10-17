"""Crop the source stills to 21:9 (2.333) Seedance inputs. yfrac = vertical centre of the crop (0..1)."""
from PIL import Image
EV = "C:/civ/game/assets/images/events/"
TS = "C:/civ/trailer_shots/"
W = "C:/civ/trailer_v6/src/work/"
jobs = {
    "s01_jaffa_dawn": (TS + "01_1948_jaffa_port.png", 0.5),
    "s03_ship": (EV + "evt_1950_law_of_return.png", 0.45),
    "s04_maabarot": (EV + "evt_1950_maabarot.png", 0.5),
    "s05_ezra": (EV + "evt_1951_ezra_nehemiah.png", 0.45),
    "s06_moses": (EV + "evt_1984_operation_moses.png", 0.5),
    "s07_hula": (EV + "evt_1951_hula_drainage.png", 0.5),
    "s11_water": (EV + "evt_1964_national_water_carrier.png", 0.55),
    "s14_haifa": (TS + "15_2026_haifa.png", 0.5),
    "s15_eilat": (TS + "09_2026_eilat_red_sea.png", 0.5),
    "s16_highway": (EV + "evt_2002_highway_6_opens.png", 0.5),
    "s17_desal": (EV + "evt_2005_ashkelon_desalination.png", 0.5),
    "s18_gas": (EV + "evt_2009_tamar_gas.png", 0.5),
    "s19_shavit": (EV + "evt_1961_shavit2.png", 0.42),
    "s20_beresheet": (EV + "evt_2019_beresheet.png", 0.5),
    "s21_whitecity": (EV + "evt_2003_white_city.png", 0.5),
    "s23_rail": (EV + "evt_2018_jerusalem_tel_aviv_railway.png", 0.5),
    "s30_night": (W + "fr_07_day_night_4.9.png", 0.5),
    "s32_tanks": (EV + "evt_1973_yom_kippur_war.png", 0.5),
    "s35_eurovision": (EV + "evt_2019_eurovision_tel_aviv.png", 0.45),
    "s39_jerusalem": (TS + "14_2026_jerusalem.png", 0.5),
    "s40_galilee": (TS + "06_sea_of_galilee.png", 0.5),
    "s41_dimona_build": (EV + "evt_1957_dimona_reactor.png", 0.5),
    "s42_tlv_golden": ("C:/civ/work_video/tlv_golden.png", 0.5),
}
for name, (src, yf) in jobs.items():
    im = Image.open(src).convert("RGB")
    w, h = im.size
    ch = round(w / (21 / 9))
    y0 = int(min(max(yf * h - ch / 2, 0), h - ch))
    im.crop((0, y0, w, y0 + ch)).save(f"C:/civ/trailer_v6/src/seedance/in/{name}.png")
    print(name, w, ch)
