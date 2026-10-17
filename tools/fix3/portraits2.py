# fix3-art2: leaders for the remaining diplomacy portrait gaps.
# Tuple: id, name, he_name, role, role_he, actor, from, to, look, reuse
# look=None + reuse=<existing portrait id> => the entry reuses an existing image (same person, another term or actor)
import subprocess, sys, os
from concurrent.futures import ThreadPoolExecutor
from PIL import Image
OUT = "C:/civ/game/assets/images/portraits/"
REF = "C:/civ/game/assets/images/portraits/eg_sadat.png"

FRP = ("French President", "נשיא צרפת"); FRPM = ("French Prime Minister", "ראש ממשלת צרפת")
SYP = ("President of Syria", "נשיא סוריה"); LBP = ("President of Lebanon", "נשיא לבנון"); LBPM = ("Prime Minister of Lebanon", "ראש ממשלת לבנון")
IQP = ("President of Iraq", "נשיא עיראק"); UKPM = ("British Prime Minister", "ראש ממשלת בריטניה")
WDC = ("West German Chancellor", "קנצלר מערב גרמניה"); DEC = ("German Chancellor", "קנצלר גרמניה")
TRP = ("President of Turkey", "נשיא טורקיה"); PLOC = ("PLO Chairman", 'יושב ראש אש"ף')
HAM = ("Hamas political bureau chief", "ראש הלשכה המדינית של חמאס"); SOV = ("Soviet leader", "מנהיג ברית המועצות")
UAEP = ("President of the UAE", "נשיא איחוד האמירויות"); BHE = ("Emir of Bahrain", "אמיר בחריין"); MAK = ("King of Morocco", "מלך מרוקו")
SDP = ("President of Sudan", "נשיא סודאן"); SDPM = ("Prime Minister of Sudan", "ראש ממשלת סודאן"); QAE = ("Emir of Qatar", "אמיר קטאר")
SAK = ("King of Saudi Arabia", "מלך ערב הסעודית"); EUP = ("President of the European Commission", "נשיא הנציבות האירופית")
INPM = ("Prime Minister of India", "ראש ממשלת הודו")

def E(i, name, he, role, actor, f, t, look=None, reuse=None):
    return (i, name, he, role[0], role[1], actor, f, t, look, reuse)

P = [
 # France
 E("fr_auriol", "Vincent Auriol", "וינסן אוריול", FRP, "france", 1948, 1953, "Vincent Auriol, French president of the Fourth Republic, aged ~65, round kindly face, thinning grey hair, dark 1950s suit"),
 E("fr_mollet", "Guy Mollet", "גי מולה", FRPM, "france", 1956, 1957, "Guy Mollet, French prime minister 1956, aged ~50, thin face, receding hair, round glasses, dark suit"),
 E("fr_degaulle_1958", "Charles de Gaulle", "שארל דה גול", FRPM, "france", 1958, 1958, None, "fr_degaulle"),
 # Syria
 E("sy_atassi_1950", "Hashim al-Atassi", "האשם אל-אתאסי", SYP, "syria", 1950, 1950, None, "sy_atassi"),
 E("sy_quwatli_2", "Shukri al-Quwatli", "שוכרי אל-קוותלי", SYP, "syria", 1956, 1957, None, "sy_quwatli"),
 E("sy_nasser_uar", "Gamal Abdel Nasser", "גמאל עבד אל-נאצר", ("President of the United Arab Republic", "נשיא הרפובליקה הערבית המאוחדת"), "syria", 1958, 1960, None, "eg_nasser"),
 E("sy_qudsi", "Nazim al-Qudsi", "נאזם אל-קודסי", SYP, "syria", 1961, 1962, "Nazim al-Qudsi, president of Syria 1961, aged ~60, receding grey hair, thin moustache, dark suit and tie"),
 E("sy_amin_hafiz", "Amin al-Hafiz", "אמין אל-חאפז", SYP, "syria", 1963, 1965, "General Amin al-Hafiz, Syrian head of state 1960s, aged ~45, dark hair, moustache, dark Syrian army officer uniform"),
 E("sy_nureddin_atassi", "Nureddin al-Atassi", "נור א-דין אל-אתאסי", SYP, "syria", 1966, 1970, "Nureddin al-Atassi, president of Syria 1966, aged ~37, physician, dark hair, round face, plain dark suit"),
 # Egypt
 E("eg_morsi", "Mohamed Morsi", "מוחמד מורסי", ("President of Egypt", "נשיא מצרים"), "egypt", 2012, 2013, "Mohamed Morsi, president of Egypt, aged ~61, short grey beard, receding grey hair, dark suit and tie"),
 # Lebanon
 E("lb_chehab", "Fuad Chehab", "פואד שהאב", LBP, "lebanon", 1959, 1964, "General Fuad Chehab, president of Lebanon, aged ~57, lean face, thin moustache, dark 1960s suit"),
 E("lb_helou", "Charles Helou", "שארל חלו", LBP, "lebanon", 1965, 1970, "Charles Helou, president of Lebanon, aged ~60, receding grey hair, round face, glasses, dark suit"),
 E("lb_frangieh", "Suleiman Frangieh", "סלימאן פרנג'יה", LBP, "lebanon", 1971, 1975, "Suleiman Frangieh, president of Lebanon 1970s, aged ~60, strong face, big grey moustache, dark suit"),
 E("lb_suleiman", "Michel Suleiman", "מישל סלימאן", LBP, "lebanon", 2008, 2014, "Michel Suleiman, president of Lebanon, aged ~60, short grey hair, moustache, dark suit"),
 E("lb_salam", "Tammam Salam", "תמאם סלאם", LBPM, "lebanon", 2015, 2015, "Tammam Salam, prime minister of Lebanon, aged ~70, white hair, glasses, dark suit"),
 E("lb_mikati", "Najib Mikati", "נג'יב מיקאתי", LBPM, "lebanon", 2023, 2023, "Najib Mikati, prime minister of Lebanon, aged ~67, silver hair, neat grey beard stubble, dark suit"),
 # Iraq
 E("iq_abdulilah", "Abd al-Ilah", "עבד אל-אילאה", ("Regent of Iraq", "העוצר של עיראק"), "iraq", 1948, 1952, "Abd al-Ilah, regent of Iraq, aged ~35, dark moustache, Iraqi military uniform with sidara cap, medals"),
 E("iq_faisal2", "King Faisal II of Iraq", "המלך פייסל השני", ("King of Iraq", "מלך עיראק"), "iraq", 1953, 1957, "King Faisal II of Iraq, aged ~20, young, clean-shaven, dark hair, military dress uniform with ribbon"),
 E("iq_qasim", "Abd al-Karim Qasim", "עבד אל-כרים קאסם", ("Prime Minister of Iraq", "ראש ממשלת עיראק"), "iraq", 1958, 1962, "General Abd al-Karim Qasim, Iraqi leader, aged ~45, round face, small moustache, Iraqi army officer uniform"),
 E("iq_aref", "Abd al-Salam Arif", "עבד א-סלאם עארף", IQP, "iraq", 1963, 1965, "Abd al-Salam Arif, president of Iraq, aged ~42, round face, thick moustache, Iraqi army uniform"),
 E("iq_aref2", "Abd al-Rahman Arif", "עבד א-רחמאן עארף", IQP, "iraq", 1966, 1967, "Abd al-Rahman Arif, president of Iraq, aged ~50, grey moustache, Iraqi army uniform"),
 E("iq_bakr", "Ahmed Hassan al-Bakr", "אחמד חסן אל-בכר", IQP, "iraq", 1968, 1978, "Ahmed Hassan al-Bakr, president of Iraq, aged ~55, grey hair, moustache, dark suit"),
 E("iq_yawer", "Ghazi al-Yawer", "ע'אזי אל-יאוור", IQP, "iraq", 2004, 2004, "Ghazi al-Yawer, interim president of Iraq 2004, aged ~45, dark neat hair, moustache, dark suit"),
 E("iq_talabani", "Jalal Talabani", "ג'לאל טלבאני", IQP, "iraq", 2005, 2013, "Jalal Talabani, president of Iraq, aged ~72, heavyset, grey hair, grey moustache, dark suit"),
 E("iq_masum", "Fuad Masum", "פואד מעצום", IQP, "iraq", 2014, 2018, "Fuad Masum, president of Iraq, aged ~76, white hair, glasses, dark suit"),
 E("iq_salih", "Barham Salih", "ברהם סאלח", IQP, "iraq", 2019, 2022, "Barham Salih, president of Iraq, aged ~60, short grey hair, grey beard stubble, dark suit"),
 E("iq_rashid", "Abdul Latif Rashid", "עבד אל-לטיף ראשיד", IQP, "iraq", 2023, 2023, "Abdul Latif Rashid, president of Iraq, aged ~78, white hair, white moustache, glasses, dark suit"),
 # UK
 E("uk_macmillan", "Harold Macmillan", "הרולד מקמילן", UKPM, "uk", 1957, 1963, "Harold Macmillan, British prime minister, aged ~65, large moustache, swept grey hair, dark suit, elegant"),
 E("uk_heath", "Edward Heath", "אדוארד היית'", UKPM, "uk", 1971, 1973, "Edward Heath, British prime minister, aged ~55, broad face, wavy brushed back hair, suit and tie, 1970s"),
 E("uk_wilson_2", "Harold Wilson", "הרולד וילסון", UKPM, "uk", 1974, 1975, None, "uk_wilson"),
 E("uk_callaghan", "James Callaghan", "ג'יימס קלהאן", UKPM, "uk", 1976, 1978, "James Callaghan, British prime minister, aged ~65, large face, grey hair, avuncular, dark suit, 1970s"),
 E("uk_major", "John Major", "ג'ון מייג'ור", UKPM, "uk", 1991, 1996, "John Major, British prime minister, aged ~50, grey hair, large round glasses, dark suit"),
 E("uk_brown", "Gordon Brown", "גורדון בראון", UKPM, "uk", 2008, 2009, "Gordon Brown, British prime minister, aged ~57, heavy brow, dark swept hair, dark suit"),
 E("uk_may", "Theresa May", "תרזה מיי", UKPM, "uk", 2017, 2018, "Theresa May, British prime minister, aged ~61, short silver hair, dark blazer, composed"),
 E("uk_johnson", "Boris Johnson", "בוריס ג'ונסון", UKPM, "uk", 2019, 2022, "Boris Johnson, British prime minister, aged ~55, tousled blond hair, dark suit"),
 E("uk_sunak", "Rishi Sunak", "רישי סונאק", UKPM, "uk", 2023, 2023, "Rishi Sunak, British prime minister, aged ~43, short dark hair, slim, dark suit and tie"),
 # Germany
 E("de_erhard", "Ludwig Erhard", "לודוויג ארהרד", WDC, "germany", 1964, 1966, "Ludwig Erhard, West German chancellor, aged ~67, round jowly face, thin combed hair, dark 1960s suit"),
 E("de_kiesinger", "Kurt Georg Kiesinger", "קורט גאורג קיזינגר", WDC, "germany", 1967, 1968, "Kurt Georg Kiesinger, West German chancellor, aged ~63, silver swept-back hair, distinguished, dark suit"),
 E("de_schmidt", "Helmut Schmidt", "הלמוט שמידט", WDC, "germany", 1975, 1981, "Helmut Schmidt, West German chancellor, aged ~58, sharp face, thin brushed hair, dark suit"),
 E("de_schroeder", "Gerhard Schroeder", "גרהרד שרדר", DEC, "germany", 1999, 2004, "Gerhard Schroeder, German chancellor, aged ~55, dark hair, confident, dark suit and tie"),
 E("de_scholz", "Olaf Scholz", "אולף שולץ", DEC, "germany", 2022, 2023, "Olaf Scholz, German chancellor, aged ~64, thinning grey hair, calm, dark suit"),
 # Turkey (heads of state)
 E("tr_inonu", "Ismet Inonu", "עיסמת אינונו", TRP, "turkey", 1948, 1949, "Ismet Inonu, president of Turkey, aged ~64, elderly, white moustache, dark 1940s suit"),
 E("tr_gursel", "Cemal Gursel", "ג'מאל גורסל", TRP, "turkey", 1961, 1965, "General Cemal Gursel, president of Turkey, aged ~65, white hair, kindly, dark suit"),
 E("tr_sunay", "Cevdet Sunay", "ג'בדט סוניי", TRP, "turkey", 1966, 1972, "Cevdet Sunay, president of Turkey, aged ~67, grey hair, serious, dark suit"),
 E("tr_koruturk", "Fahri Koruturk", "פחרי קורוטורק", TRP, "turkey", 1973, 1979, "Fahri Koruturk, president of Turkey, aged ~70, grey hair, round glasses, dark suit"),
 E("tr_evren", "Kenan Evren", "קנאן אברן", TRP, "turkey", 1980, 1982, "General Kenan Evren, Turkish head of state, aged ~62, white hair, stern, dark suit"),
 E("tr_demirel", "Suleyman Demirel", "סולימאן דמירל", TRP, "turkey", 1994, 1999, "Suleyman Demirel, president of Turkey, aged ~70, white hair, large eyebrows, glasses, dark suit"),
 E("tr_sezer", "Ahmet Necdet Sezer", "אחמט נג'דט סזר", TRP, "turkey", 2000, 2002, "Ahmet Necdet Sezer, president of Turkey, aged ~60, grey hair, small grey moustache, dark suit"),
 # Palestinians
 E("plo_shuqayri", "Ahmad Shukeiri", "אחמד שוקיירי", PLOC, "plo", 1964, 1967, "Ahmad Shukeiri, first chairman of the PLO, aged ~57, grey hair, jowly, dark 1960s suit"),
 E("plo_hammuda", "Yahya Hammuda", "יחיא חמודה", PLOC, "plo", 1968, 1968, "Yahya Hammuda, acting PLO chairman 1968, aged ~45, dark hair, moustache, dark suit"),
 E("plo_abbas", "Mahmoud Abbas", "מחמוד עבאס", PLOC, "plo", 2005, 2023, None, "pa_abbas"),
 E("pa_arafat", "Yasser Arafat", "יאסר ערפאת", ("Palestinian Authority President", "נשיא הרשות הפלסטינית"), "palestinian_authority", 1994, 2004, None, "plo_arafat"),
 E("hamas_meshaal", "Khaled Meshaal", "ח'אלד משעל", HAM, "hamas", 2005, 2016, "Khaled Meshaal, Hamas political bureau chief, aged ~55, grey beard, dark suit"),
 E("hamas_haniyeh", "Ismail Haniyeh", "איסמאעיל הנייה", HAM, "hamas", 2017, 2023, "Ismail Haniyeh, Hamas political bureau chief, aged ~58, white short beard, white skullcap, dark jacket"),
 # USSR
 E("su_andropov", "Yuri Andropov", "יורי אנדרופוב", SOV, "ussr", 1983, 1983, "Yuri Andropov, Soviet leader, aged ~69, thin face, grey hair, large glasses, dark Soviet suit"),
 E("su_chernenko", "Konstantin Chernenko", "קונסטנטין צ'רננקו", SOV, "ussr", 1984, 1984, "Konstantin Chernenko, Soviet leader, aged ~72, pale, white hair, dark Soviet suit with medals"),
 # Gulf, Morocco
 E("ae_zayed", "Zayed bin Sultan Al Nahyan", "זאיד בן סולטאן אל נהיאן", UAEP, "uae", 1971, 2003, "Sheikh Zayed bin Sultan Al Nahyan, president of the UAE, aged ~60, grey beard, white ghutra and black agal, white robe"),
 E("ae_khalifa", "Khalifa bin Zayed Al Nahyan", "ח'ליפה בן זאיד אל נהיאן", UAEP, "uae", 2004, 2021, "Sheikh Khalifa bin Zayed Al Nahyan, president of the UAE, aged ~60, trimmed grey beard, white ghutra and black agal, white kandura"),
 E("bh_isa", "Isa bin Salman Al Khalifa", "עיסא בן סלמאן אל ח'ליפה", BHE, "bahrain", 1971, 1998, "Sheikh Isa bin Salman Al Khalifa, emir of Bahrain, aged ~55, grey short beard, red-and-white ghutra with black agal, dark bisht cloak"),
 E("bh_hamad_emir", "Hamad bin Isa Al Khalifa", "חמד בן עיסא אל ח'ליפה", BHE, "bahrain", 1999, 2001, None, "bh_hamad"),
 E("ma_mohammed5", "Mohammed V of Morocco", "מוחמד החמישי", MAK, "morocco", 1956, 1960, "King Mohammed V of Morocco, aged ~50, white djellaba and white hood, trimmed grey moustache, dignified"),
 E("ma_hassan2", "Hassan II of Morocco", "חסן השני", MAK, "morocco", 1961, 1998, "King Hassan II of Morocco, aged ~55, dark short hair, thin moustache, dark suit"),
 # Sudan
 E("sd_azhari", "Ismail al-Azhari", "איסמאעיל אל-אזהרי", SDPM, "sudan", 1956, 1957, "Ismail al-Azhari, first prime minister of Sudan, aged ~55, round face, white imama headcloth, white jalabiya robe, glasses"),
 E("sd_abboud", "Ibrahim Abboud", "אברהים עבוד", SDP, "sudan", 1958, 1964, "General Ibrahim Abboud, Sudanese head of state, aged ~58, military uniform, cap, moustache"),
 E("sd_azhari_2", "Ismail al-Azhari", "איסמאעיל אל-אזהרי", SDP, "sudan", 1965, 1968, None, "sd_azhari"),
 E("sd_nimeiry", "Gaafar Nimeiry", "ג'עפר נומיירי", SDP, "sudan", 1969, 1984, "Gaafar Nimeiry, president of Sudan, aged ~45, military uniform with beret, moustache"),
 E("sd_dahab", "Abdel Rahman Swar al-Dahab", "עבד א-רחמאן סוואר א-דהב", ("Head of State of Sudan", "ראש המדינה של סודאן"), "sudan", 1985, 1985, "Field Marshal Abdel Rahman Swar al-Dahab, Sudanese head of state, aged ~50, military uniform with cap"),
 E("sd_mahdi", "Sadiq al-Mahdi", "א-צאדק אל-מהדי", SDPM, "sudan", 1986, 1988, "Sadiq al-Mahdi, prime minister of Sudan, aged ~50, grey beard, white imama turban and white jalabiya, glasses"),
 E("sd_bashir", "Omar al-Bashir", "עומר אל-באשיר", SDP, "sudan", 1989, 2018, "Omar al-Bashir, president of Sudan, aged ~60, short grey beard, white imama turban, white jalabiya robe"),
 E("sd_burhan", "Abdel Fattah al-Burhan", "עבד אל-פתאח אל-בורהאן", ("Chairman of the Sovereignty Council of Sudan", "יושב ראש מועצת הריבונות של סודאן"), "sudan", 2019, 2023, "General Abdel Fattah al-Burhan, Sudanese head of state, aged ~58, short dark moustache, military uniform with cap"),
 # Qatar
 E("qa_ahmad", "Ahmad bin Ali Al Thani", "אחמד בן עלי אל ת'אני", QAE, "qatar", 1971, 1971, "Sheikh Ahmad bin Ali Al Thani, emir of Qatar, aged ~50, white ghutra and agal, dark bisht cloak, thin moustache"),
 E("qa_khalifa", "Khalifa bin Hamad Al Thani", "ח'ליפה בן חמד אל ת'אני", QAE, "qatar", 1972, 1994, "Sheikh Khalifa bin Hamad Al Thani, emir of Qatar, aged ~50, trimmed moustache, white ghutra and agal, dark bisht cloak"),
 E("qa_hamad", "Hamad bin Khalifa Al Thani", "חמד בן ח'ליפה אל ת'אני", QAE, "qatar", 1995, 2012, "Sheikh Hamad bin Khalifa Al Thani, emir of Qatar, aged ~50, trimmed goatee, white ghutra and agal, dark bisht cloak"),
 E("qa_tamim", "Tamim bin Hamad Al Thani", "תמים בן חמד אל ת'אני", QAE, "qatar", 2013, 2023, "Sheikh Tamim bin Hamad Al Thani, emir of Qatar, aged ~35, short dark beard, white ghutra and agal, dark bisht cloak"),
 # Saudi Arabia
 E("sa_ibn_saud", "Abdulaziz Ibn Saud", "עבד אל-עזיז אבן סעוד", SAK, "saudi_arabia", 1948, 1952, "King Abdulaziz Ibn Saud of Saudi Arabia, aged ~70, very tall, grey beard, red-and-white ghutra with black agal, brown bisht cloak"),
 E("sa_saud", "King Saud of Saudi Arabia", "המלך סעוד", SAK, "saudi_arabia", 1953, 1963, "King Saud of Saudi Arabia, aged ~50, heavy face, short beard, white ghutra with black agal, dark bisht cloak"),
 E("sa_faisal", "King Faisal of Saudi Arabia", "המלך פייסל", SAK, "saudi_arabia", 1964, 1974, "King Faisal of Saudi Arabia, aged ~65, thin face, goatee, white ghutra and black agal, dark bisht cloak, stern"),
 E("sa_khalid", "King Khalid of Saudi Arabia", "המלך ח'אלד", SAK, "saudi_arabia", 1975, 1981, "King Khalid of Saudi Arabia, aged ~65, small trimmed beard, red-and-white ghutra with black agal, dark bisht cloak"),
 E("sa_fahd", "King Fahd of Saudi Arabia", "המלך פהד", SAK, "saudi_arabia", 1982, 2004, "King Fahd of Saudi Arabia, aged ~65, heavy build, trimmed beard, white ghutra and black agal, dark bisht cloak"),
 E("sa_abdullah", "King Abdullah of Saudi Arabia", "המלך עבדאללה", SAK, "saudi_arabia", 2005, 2014, "King Abdullah of Saudi Arabia, aged ~80, white goatee and moustache, white ghutra and black agal, dark bisht cloak"),
 E("sa_salman", "King Salman of Saudi Arabia", "המלך סלמאן", SAK, "saudi_arabia", 2015, 2023, "King Salman of Saudi Arabia, aged ~80, white beard, red-and-white ghutra with black agal, dark bisht cloak"),
 # EU (Presidents of the Commission)
 E("eu_hallstein", "Walter Hallstein", "וולטר הלשטיין", EUP, "eec_eu", 1964, 1966, "Walter Hallstein, first President of the European Commission, German, aged ~63, round face, white hair, glasses, dark suit"),
 E("eu_rey", "Jean Rey", "ז'אן ריי", EUP, "eec_eu", 1967, 1969, "Jean Rey, President of the European Commission, Belgian, aged ~65, white hair, glasses, dark suit"),
 E("eu_malfatti", "Franco Maria Malfatti", "פרנקו מריה מלפטי", EUP, "eec_eu", 1970, 1971, "Franco Maria Malfatti, President of the European Commission, Italian, aged ~50, dark hair, dark suit"),
 E("eu_mansholt", "Sicco Mansholt", "סיקו מנשולט", EUP, "eec_eu", 1972, 1972, "Sicco Mansholt, President of the European Commission, Dutch, aged ~64, white hair, strong face, dark suit"),
 E("eu_ortoli", "Francois-Xavier Ortoli", "פרנסואה-קסבייה אורטולי", EUP, "eec_eu", 1973, 1976, "Francois-Xavier Ortoli, President of the European Commission, French, aged ~48, dark hair, dark suit"),
 E("eu_jenkins", "Roy Jenkins", "רוי ג'נקינס", EUP, "eec_eu", 1977, 1980, "Roy Jenkins, President of the European Commission, British, aged ~57, receding grey hair, jowly, dark suit"),
 E("eu_thorn", "Gaston Thorn", "גסטון תורן", EUP, "eec_eu", 1981, 1984, "Gaston Thorn, President of the European Commission, Luxembourgish, aged ~53, grey hair, glasses, dark suit"),
 E("eu_delors", "Jacques Delors", "ז'אק דלור", EUP, "eec_eu", 1985, 1994, "Jacques Delors, President of the European Commission, French, aged ~60, receding grey hair, distinguished, dark suit"),
 E("eu_santer", "Jacques Santer", "ז'אק סנטר", EUP, "eec_eu", 1995, 1998, "Jacques Santer, President of the European Commission, Luxembourgish, aged ~58, grey hair, round face, dark suit"),
 E("eu_prodi", "Romano Prodi", "רומנו פרודי", EUP, "eec_eu", 1999, 2003, "Romano Prodi, President of the European Commission, Italian, aged ~60, grey hair, round glasses, dark suit"),
 E("eu_barroso", "Jose Manuel Barroso", "ז'וזה מנואל ברוזו", EUP, "eec_eu", 2004, 2013, "Jose Manuel Barroso, President of the European Commission, Portuguese, aged ~55, grey hair, dark suit"),
 E("eu_juncker", "Jean-Claude Juncker", "ז'אן-קלוד יונקר", EUP, "eec_eu", 2014, 2018, "Jean-Claude Juncker, President of the European Commission, Luxembourgish, aged ~62, thin grey hair, glasses, dark suit"),
 E("eu_vdl", "Ursula von der Leyen", "אורסולה פון דר ליין", EUP, "eec_eu", 2019, 2023, "Ursula von der Leyen, President of the European Commission, German, aged ~62, blonde short hair, blazer"),
 # China
 E("cn_hua", "Hua Guofeng", "הואה גואופנג", ("Chairman of China", "יושב ראש סין"), "china", 1977, 1978, "Hua Guofeng, Chairman of China, aged ~56, round face, black hair combed back, grey Mao suit"),
 E("cn_deng", "Deng Xiaoping", "דנג שיאופינג", ("Paramount leader of China", "המנהיג העליון של סין"), "china", 1979, 1988, "Deng Xiaoping, paramount leader of China, aged ~78, short stature, thin grey hair, grey Mao suit"),
 E("cn_jiang", "Jiang Zemin", "ג'יאנג דזה-מין", ("Leader of China", "מנהיג סין"), "china", 1989, 2002, "Jiang Zemin, leader of China, aged ~65, large round glasses, black swept hair, dark suit"),
 E("cn_hu", "Hu Jintao", "הו ג'ינטאו", ("President of China", "נשיא סין"), "china", 2003, 2012, "Hu Jintao, president of China, aged ~62, black swept hair, dark suit and red tie"),
 E("cn_xi", "Xi Jinping", "שי ג'ינפינג", ("President of China", "נשיא סין"), "china", 2013, 2023, "Xi Jinping, president of China, aged ~62, black hair, broad face, dark suit"),
 # India
 E("in_shastri", "Lal Bahadur Shastri", "לאל בהאדור שאסטרי", INPM, "india", 1965, 1965, "Lal Bahadur Shastri, prime minister of India, aged ~60, small stature, gentle face, white Gandhi cap, white kurta"),
 E("in_indira", "Indira Gandhi", "אינדירה גנדי", INPM, "india", 1966, 1976, "Indira Gandhi, prime minister of India, aged ~50, grey streak in black hair, sari, dignified"),
 E("in_desai", "Morarji Desai", "מורארג'י דסאי", INPM, "india", 1977, 1979, "Morarji Desai, prime minister of India, aged ~81, thin, white Gandhi cap, white kurta"),
 E("in_indira_2", "Indira Gandhi", "אינדירה גנדי", INPM, "india", 1980, 1984, None, "in_indira"),
 E("in_rajiv", "Rajiv Gandhi", "ראג'יב גנדי", INPM, "india", 1985, 1989, "Rajiv Gandhi, prime minister of India, aged ~42, dark hair, light beard shadow, kurta jacket"),
 E("in_vpsingh", "V. P. Singh", "וי. פי. סינג", INPM, "india", 1990, 1990, "V. P. Singh, prime minister of India, aged ~59, thin face, grey hair, glasses, white kurta"),
 E("in_rao", "P. V. Narasimha Rao", 'פ"ו נארסימהה ראו', INPM, "india", 1991, 1995, "P. V. Narasimha Rao, prime minister of India, aged ~71, white hair, thick glasses, white kurta"),
 E("in_gowda", "H. D. Deve Gowda", "ה.ד. דבה גוודה", INPM, "india", 1996, 1996, "H. D. Deve Gowda, prime minister of India, aged ~63, grey hair, white shirt and shawl"),
 E("in_gujral", "I. K. Gujral", "אינדר קומאר גוג'ראל", INPM, "india", 1997, 1997, "I. K. Gujral, prime minister of India, aged ~77, white hair, thick glasses, white kurta"),
 E("in_vajpayee", "Atal Bihari Vajpayee", "אטל ביהארי ואג'פיי", INPM, "india", 1998, 2003, "Atal Bihari Vajpayee, prime minister of India, aged ~75, white hair, kind face, white kurta and shawl"),
 E("in_manmohan", "Manmohan Singh", "מנמוהן סינג", INPM, "india", 2004, 2013, "Manmohan Singh, prime minister of India, aged ~72, light-blue turban, white beard, glasses, dark jacket"),
]

STYLE = ("Painted digital portrait, head and shoulders, in the same style as the reference: realistic painterly brushwork, dignified neutral and respectful expression, "
         "deep navy blue background with a subtle golden rim light, square composition, no text, no captions. Recognisable likeness of: ")


def run(p):
    i, look = p[0], p[8]
    if look is None:
        return i, "reuse"
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
