# v3 final round (fix4-av): illustrations for major forks that have no linked event art.
# usage: python forks.py [n_parallel]    -> game/assets/images/events/<fork_id>.png + _768.png
import sys, os, concurrent.futures as cf
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from run import gen, ROOT
F = [
("fork_1954_reprisal_policy","Border reprisals or restraint, 1954","Cabinet ministers in 1950s suits around a long table in a Jerusalem office in lamplight, a large wall map of the armistice lines, one minister standing with a hand on the map, a window showing a quiet border village at dusk."),
("fork_1954_johnston_plan","The Johnston plan for the Jordan waters, 1954","An American envoy and Israeli and Arab engineers in 1950s suits studying large maps and blueprints of the Jordan River on a table, a window with the green Jordan valley and the Sea of Galilee, calm daylight."),
("fork_1970_black_september","Jordan crisis, September 1970","Israeli cabinet in a dim room late at night, ministers and a general studying a map of the Jordan valley by a lamp, cups of tea, serious faces, window showing hills at dawn."),
("fork_1968_hebron","Hebron, 1968","A narrow stone street of Hebron's old city with the pale stone walls of the Cave of the Patriarchs above, shopkeepers, women with baskets and a few Israeli visitors, warm afternoon light, calm."),
("fork_1978_litani_belt","South Lebanon border, 1978","Terraced green hills on the Lebanese border seen from an Israeli hilltop, a lone observation post, olive trees, shepherd with goats below, a distant village with a minaret, soft evening haze."),
("fork_1998_wye","Wye River Memorandum, 1998","A signing table in a quiet American conference hall by a wooded river in autumn, Israeli, Palestinian and American delegates in suits seated formally, flags without writing, golden afternoon light."),
("fork_2012_iran_strike","Iran: strike or not, 2012","A late-night Jerusalem security cabinet room, officials in shirtsleeves around a table with a large map of the Middle East, a lit lamp, a tray of tea glasses, tense thoughtful mood, no weapons."),
("fork_2002_barrier_route","The separation barrier route, 2002","Surveyors and engineers with theodolites and maps on a West Bank hillside of olive terraces, a village in the valley, a bulldozer far away, warm light, neutral observers, no violence."),
("fork_1958_who_is_a_jew","Who is registered as a Jew, 1958","A 1950s Israeli population registry office, a clerk at a wooden desk stamping a form, a couple of varied families waiting with papers, ceiling fan, sunlit shutters."),
("fork_1994_golan_offer","The Golan Heights, 1994","The green and basalt Golan Heights above the Sea of Galilee with wildflowers in spring, an orchard and a kibbutz below, snowy Mount Hermon behind, a quiet road, golden morning."),
("fork_2017_western_wall_compromise","The Western Wall compromise, 2017","The Western Wall plaza in Jerusalem at dawn with worshippers, men and women of different traditions praying in their sections and a pale stone platform to one side, golden light on the stone."),
("fork_1962_devaluation","Devaluing the pound, 1962","A 1960s Israeli street with a currency exchange window and a grocer chalking new prices, shoppers counting pound notes, a bank clerk at a desk, warm afternoon light."),
("fork_1993_health_insurance","National health insurance, 1993","A busy 1990s Israeli clinic waiting room with families of every background, a nurse with a clipboard, a doctor greeting a mother and child, bright windows, warm and hopeful."),
("fork_1993_foreign_workers","Who builds Israel, 1993","A construction site at dusk in a growing Israeli city, workers in hard hats of varied origins raising scaffolding next to a tower crane, apartment blocks half built, warm light."),
("fork_1997_state_stakes_sale","Selling state companies and banks, 1997","A 1990s Tel Aviv stock exchange trading hall, brokers at desks with telephones, a large wall board of numbers without legible text, a glass tower view, bright daylight."),
("fork_1951_kibbutz_split","The kibbutz movement splits, 1951","A kibbutz dining hall at dusk, members in work clothes talking heatedly in two groups around long tables, a clock on the wall, lawns and a water tower through the window, warm light."),
("fork_2012_asylum_seekers","African asylum seekers in south Tel Aviv, 2012","A south Tel Aviv street with African families outside a small shop and a community centre, children playing, residents of the neighbourhood nearby, a social worker, afternoon light, dignified."),
("fork_2004_bedouin_villages","The Negev Bedouin villages, 2004","A Bedouin village in the Negev with tents and tin-roofed houses, a shepherd with goats, women carrying water, children by a pick-up truck, desert hills, golden dusk, dignified."),
("fork_1950_korea_stand","Korea: taking a side at the UN, 1950","The 1950 UN General Assembly hall in Lake Success, an Israeli delegate in a suit at a microphone among rows of delegates, a large blank wall map, solemn light."),
("fork_1953_bnot_yaakov","The Jordan canal at Bnot Yaakov, 1953","Excavators and workers digging a canal near the Jordan River at Gesher Bnot Yaakov, an old stone bridge, green fields and the Hula valley, a UN observer in a white jeep, morning light."),
]
def jobs():
    L = []
    for (i, cap, d) in F:
        L.append((f"Painterly historical illustration, warm golden palette with navy-blue accents, soft brushwork like a Civ VI loading-screen painting, wide cinematic composition. {d} Respectful, neutral, no violence, no gore, no bodies, no weapons pointed at people, no text, no letters, no flags with writing, no logos.", ROOT + f"events/{i}.png", "16:9", None, (1536, 864), ROOT + f"events/{i}_768.png"))
    return L
if __name__ == "__main__":
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 4
    with cf.ThreadPoolExecutor(n) as ex:
        for r in ex.map(lambda j: gen(*j), jobs()):
            print(r, flush=True)
