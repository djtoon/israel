import subprocess, sys, os, json
from concurrent.futures import ThreadPoolExecutor
from PIL import Image
OUT = "C:/civ/game/assets/images/portraits/"
REF = "C:/civ/game/assets/images/portraits/eg_sadat.png"
# id,name,role,actor,from,to,look
P = [
("fr_mendes_france","Pierre Mendes France","French Prime Minister","france",1954,1955,"Pierre Mendes France, French prime minister 1954, aged ~47, slim face, receding dark hair, dark suit and tie"),
("fr_pompidou","Georges Pompidou","French President","france",1969,1974,"Georges Pompidou, French president, aged ~60, heavy dark eyebrows, round face, warm half smile, dark suit"),
("fr_giscard","Valery Giscard d'Estaing","French President","france",1974,1981,"Valery Giscard d'Estaing, French president 1970s, aged ~50, long face, high forehead, thinning swept hair, dark suit"),
("fr_chirac","Jacques Chirac","French President","france",1995,2007,"Jacques Chirac, French president, aged ~65, tall, broad face, grey-brown hair, dark suit, confident smile"),
("fr_sarkozy","Nicolas Sarkozy","French President","france",2007,2012,"Nicolas Sarkozy, French president, aged ~55, dark hair, intense look, dark suit, white shirt"),
("fr_hollande","Francois Hollande","French President","france",2012,2017,"Francois Hollande, French president, aged ~60, round face, grey hair, friendly look, dark suit"),
("un_lie","Trygve Lie","UN Secretary-General","un",1946,1952,"Trygve Lie, first UN Secretary-General, Norwegian, aged ~55, heavyset, round face, thinning hair, 1940s suit"),
("un_hammarskjold","Dag Hammarskjold","UN Secretary-General","un",1953,1961,"Dag Hammarskjold, UN Secretary-General, Swedish, aged ~50, neat side-parted hair, thoughtful expression, 1950s suit"),
("un_thant","U Thant","UN Secretary-General","un",1961,1971,"U Thant, UN Secretary-General from Burma, aged ~55, gentle face, black hair, dark suit, 1960s"),
("un_waldheim","Kurt Waldheim","UN Secretary-General","un",1972,1981,"Kurt Waldheim, UN Secretary-General, Austrian, aged ~55, tall, thick grey hair, dark suit, 1970s"),
("un_perez_de_cuellar","Javier Perez de Cuellar","UN Secretary-General","un",1982,1991,"Javier Perez de Cuellar, UN Secretary-General from Peru, aged ~65, silver hair, refined, dark suit, 1980s"),
("un_boutros_ghali","Boutros Boutros-Ghali","UN Secretary-General","un",1992,1996,"Boutros Boutros-Ghali, UN Secretary-General, Egyptian, aged ~72, white hair, dignified, dark suit"),
("un_annan","Kofi Annan","UN Secretary-General","un",1997,2006,"Kofi Annan, UN Secretary-General from Ghana, aged ~60, short grey hair, kind face, light-blue tie, dark suit"),
("un_ban","Ban Ki-moon","UN Secretary-General","un",2007,2016,"Ban Ki-moon, UN Secretary-General from South Korea, aged ~65, black swept hair, suit and light-blue tie"),
("un_guterres","Antonio Guterres","UN Secretary-General","un",2017,2026,"Antonio Guterres, UN Secretary-General from Portugal, aged ~70, white hair, kind face, dark suit, blue tie"),
("eg_farouk","King Farouk","King of Egypt","egypt",1936,1952,"King Farouk I of Egypt, aged ~30, plump face, small moustache, red tarboosh fez, ornate military uniform with medals"),
("eg_naguib","Muhammad Naguib","President of Egypt","egypt",1952,1954,"General Muhammad Naguib, first president of Egypt 1953, aged ~52, moustache, military uniform with cap, kind face"),
("jo_abdullah1","King Abdullah I of Jordan","King of Jordan","jordan",1946,1951,"King Abdullah I of Jordan, aged ~65, pointed grey beard, white keffiyeh and black agal, dark robe with gold trim"),
("jo_talal","King Talal of Jordan","King of Jordan","jordan",1951,1952,"King Talal of Jordan, aged ~42, fine moustache, red-and-white keffiyeh, dark military uniform"),
("sy_quwatli","Shukri al-Quwatli","President of Syria","syria",1943,1949,"Shukri al-Quwatli, president of Syria, aged ~55, moustache, red tarboosh, dark 1940s suit"),
("sy_shishakli","Adib Shishakli","President of Syria","syria",1951,1954,"Colonel Adib Shishakli, Syrian military ruler, aged ~42, thin moustache, 1950s Syrian army officer uniform and cap"),
("sy_atassi","Hashim al-Atassi","President of Syria","syria",1954,1955,"Hashim al-Atassi, president of Syria, elderly aged ~80, white hair, white moustache, dark suit and tarboosh"),
("sy_bashar_assad","Bashar al-Assad","President of Syria","syria",2000,2024,"Bashar al-Assad, president of Syria, aged ~40, tall, short dark hair, small moustache, dark suit"),
("lb_khoury","Bechara El Khoury","President of Lebanon","lebanon",1943,1952,"Bechara El Khoury, president of Lebanon, aged ~60, white moustache, dark 1940s suit, distinguished"),
("lb_chamoun","Camille Chamoun","President of Lebanon","lebanon",1952,1958,"Camille Chamoun, president of Lebanon, aged ~52, silver hair, dark suit, 1950s"),
("lb_sarkis","Elias Sarkis","President of Lebanon","lebanon",1976,1982,"Elias Sarkis, president of Lebanon, aged ~52, receding hair, glasses, dark suit, 1970s"),
("lb_amine_gemayel","Amine Gemayel","President of Lebanon","lebanon",1982,1988,"Amine Gemayel, president of Lebanon, aged ~40, dark hair, moustache, dark suit, 1980s"),
("lb_hrawi","Elias Hrawi","President of Lebanon","lebanon",1989,1998,"Elias Hrawi, president of Lebanon, aged ~63, grey hair, big moustache, dark suit"),
("lb_lahoud","Emile Lahoud","President of Lebanon","lebanon",1998,2007,"Emile Lahoud, president of Lebanon, aged ~63, grey hair, stern, dark suit"),
("lb_aoun","Michel Aoun","President of Lebanon","lebanon",2016,2022,"Michel Aoun, president of Lebanon, aged ~82, white hair, serious, dark suit"),
("iq_saddam","Saddam Hussein","President of Iraq","iraq",1979,2003,"Saddam Hussein, president of Iraq, aged ~50, thick black moustache, black hair, dark suit"),
("ir_shah","Mohammad Reza Shah Pahlavi","Shah of Iran","iran",1941,1979,"Mohammad Reza Shah Pahlavi of Iran, aged ~45, dark hair, thin moustache, ornate imperial military dress uniform with sash and medals"),
("ir_khomeini","Ayatollah Khomeini","Supreme Leader of Iran","iran",1979,1989,"Ayatollah Ruhollah Khomeini, aged ~80, long white beard, black turban, dark robes, stern"),
("ir_khamenei","Ali Khamenei","Supreme Leader of Iran","iran",1989,2026,"Ali Khamenei, Supreme Leader of Iran, aged ~65, grey beard, glasses, white turban, brown cloak"),
("tr_menderes","Adnan Menderes","Prime Minister of Turkey","turkey",1950,1960,"Adnan Menderes, Turkish prime minister 1950s, aged ~55, receding hair, round face, dark suit"),
("tr_ozal","Turgut Ozal","Prime Minister of Turkey","turkey",1983,1993,"Turgut Ozal, Turkish prime minister and president, aged ~58, thick glasses, grey hair, dark suit"),
("tr_erdogan","Recep Tayyip Erdogan","President of Turkey","turkey",2003,2026,"Recep Tayyip Erdogan, Turkish president, aged ~60, short moustache, grey hair, dark suit and tie"),
("us_kennedy","John F. Kennedy","US President","us",1961,1963,"John F. Kennedy, US president, aged ~44, thick brown swept hair, dark suit, early 1960s"),
("us_ford","Gerald Ford","US President","us",1974,1977,"Gerald Ford, US president, aged ~62, grey-brown hair combed to the side, friendly, dark suit"),
("de_brandt","Willy Brandt","West German Chancellor","germany",1969,1974,"Willy Brandt, West German chancellor, aged ~57, grey hair, prominent features, dark suit"),
("de_kohl","Helmut Kohl","German Chancellor","germany",1982,1998,"Helmut Kohl, German chancellor, aged ~60, tall, heavy, light brown hair, dark suit"),
("de_merkel","Angela Merkel","German Chancellor","germany",2005,2021,"Angela Merkel, German chancellor, aged ~55, short hair, blazer jacket, calm"),
("uk_attlee","Clement Attlee","British Prime Minister","uk",1946,1951,"Clement Attlee, British prime minister, aged ~65, small moustache, grey hair, 1940s suit"),
("uk_eden","Anthony Eden","British Prime Minister","uk",1955,1957,"Anthony Eden, British prime minister, aged ~58, elegant, neat moustache, dark hair swept back, suit"),
("uk_wilson","Harold Wilson","British Prime Minister","uk",1964,1970,"Harold Wilson, British prime minister, aged ~50, round face, thinning hair, suit and tie, 1960s"),
("uk_cameron","David Cameron","British Prime Minister","uk",2010,2016,"David Cameron, British prime minister, aged ~45, round face, short hair, dark suit"),
("ru_yeltsin","Boris Yeltsin","President of Russia","russia",1991,1999,"Boris Yeltsin, Russian president, aged ~62, large head, white hair, dark suit"),
("cn_mao","Mao Zedong","Chairman of China","china",1949,1976,"Mao Zedong, Chairman of China, aged ~60, round face, black hair combed back, grey Mao suit"),
("in_nehru","Jawaharlal Nehru","Prime Minister of India","india",1947,1964,"Jawaharlal Nehru, prime minister of India, aged ~60, white Gandhi cap, buttoned sherwani jacket"),
("in_modi","Narendra Modi","Prime Minister of India","india",2014,2026,"Narendra Modi, prime minister of India, aged ~65, white beard, vest over kurta"),
("eg_sisi","Abdel Fattah el-Sisi","President of Egypt","egypt",2014,2026,"Abdel Fattah el-Sisi, president of Egypt, aged ~60, short grey hair, small moustache, dark suit"),
("hamas_yassin","Sheikh Ahmed Yassin","Hamas founder","hamas",1987,2004,"Sheikh Ahmed Yassin, founder of Hamas, elderly thin clean-shaven gaunt face with no beard, white keffiyeh headcloth, large round glasses, plain dark robe, head and shoulders"),
("hezbollah_nasrallah","Hassan Nasrallah","Hezbollah secretary-general","hezbollah",1992,2024,"Hassan Nasrallah, Hezbollah secretary-general, aged ~55, black turban, grey-black beard, round glasses, dark robe"),
]
STYLE = ("Painted digital portrait, head and shoulders, in the same style as the reference: realistic painterly brushwork, dignified neutral and respectful expression, "
 "deep navy blue background with a subtle golden rim light, square composition, no text, no captions. Recognisable likeness of: ")

def run(p):
    i, n, r, a, f, t, look = p
    out = OUT + i + ".png"
    if os.path.exists(out) and os.path.getsize(out) > 10000:
        return i, "skip"
    src = "C:/civ/work_fix3/" + i + ".png"
    c = subprocess.run([sys.executable, "C:/civ/tools/gen.py", "image", STYLE + look + ".", src, "--ref", REF, "--aspect", "1:1", "--quality", "high"], capture_output=True, text=True)
    if not os.path.exists(src):
        return i, "FAIL " + c.stdout[-200:] + c.stderr[-300:]
    im = Image.open(src).convert("RGB")
    im.resize((1024, 1024), Image.LANCZOS).save(out)
    im.resize((256, 256), Image.LANCZOS).save(OUT + i + "_256.png")
    return i, "ok"

if __name__ == "__main__":
    only = set(sys.argv[1:])
    ps = [p for p in P if not only or p[0] in only]
    with ThreadPoolExecutor(6) as ex:
        for i, s in ex.map(run, ps):
            print(i, s, flush=True)
