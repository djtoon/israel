"""Asset spec: every asset id, its category, era and prompt subject. Prompts are built with prompts.py."""
import prompts as P
from assets_r2 import R2
from assets_r3 import R3

# (id, subject, ground, era_from, era_to)
CITY = [
 ("city_1948_maabara", "A 1948-1950 Israeli ma'abara immigrant transit camp: rows of white canvas army tents and a few small corrugated-tin huts, a water tank on stilts, washing lines, dirt paths", None, 1948, 1960),
 ("city_1950s_bauhaus", "A 1950s Tel Aviv 'White City' neighbourhood: four white and cream International Style Bauhaus apartment buildings of 3-4 storeys with rounded corner balconies, horizontal ribbon windows, flat roofs, pilotis, small date palms and ficus trees along a street", "pale paving stones and small green gardens", 1948, 1975),
 ("city_jerusalem_stone", "A dense old Jerusalem quarter built entirely of honey-gold Jerusalem limestone: cubic stone houses with small domes and arched windows, inner courtyards, one bell tower and one slender minaret, narrow stepped lanes, a short stretch of crenellated stone city wall along one side", "worn golden limestone paving", 1948, 2026),
 ("city_kibbutz", "A 1950s Israeli kibbutz: a tall concrete water tower on legs as the centrepiece, a long low white communal dining hall, rows of small white houses with red tiled roofs, a cowshed, lawns and a cypress windbreak, a small vintage tractor", "green lawn and dirt tracks", 1948, 2026),
 ("city_dev_town", "A 1960s Israeli development town: three long four-storey concrete 'shikun' apartment blocks in pale cream stucco with rows of small windows and balconies, laundry hanging on balconies, rooftop solar water heaters, a small row of shops with awnings, a few eucalyptus trees", "dusty earth and patched asphalt", 1955, 1990),
 ("city_modern_tlv", "A modern 2020s Tel Aviv downtown cluster: five sleek skyscrapers of varied heights in blue-green glass and white concrete, white mid-rise apartment buildings at their feet, date palms and a small plaza", "light grey paving with small lawns", 1990, 2026),
 ("city_haifa_port", "A Haifa port district: a harbour quay with two large red-and-white container gantry cranes, stacks of colourful shipping containers, a tall grain silo building, warehouses, and a cargo ship moored alongside", "concrete quay on one half and turquoise harbour water on the other half", 1948, 2026),
]
LANDMARK = [
 ("lm_dome_of_the_rock", "The Dome of the Rock in Jerusalem with its golden dome and blue-and-turquoise tiled octagonal walls, standing on a raised stone platform with arcades, with a section of the Old City's crenellated limestone walls and a gate tower along the front edge", "golden limestone paving", 1948, 2026),
 ("lm_knesset", "The Knesset building in Jerusalem: a low square modernist parliament building of pale Jerusalem stone with a flat roof and a colonnade of tall slender rectangular pillars on all sides, set in a lawn with a long reflecting pool and olive trees", "green lawn and stone paths", 1966, 2026),
 ("lm_bahai_gardens", "The Baha'i Shrine of the Bab in Haifa: a shrine with a golden dome and a white marble colonnade at the top of symmetrical terraced gardens stepping down the slope, manicured lawns, cypress trees, flower beds and a central staircase", "green lawns and terraces", 1953, 2026),
 ("lm_azrieli_towers", "The Azrieli Center in Tel Aviv: three tall modern skyscrapers standing together on a low podium building, one round cylindrical tower, one triangular tower and one square tower, all of blue-grey glass with white bands", "light grey paving", 1999, 2026),
 ("lm_nuclear_research", "A generic desert nuclear research centre: one large silver-grey concrete dome building surrounded by low white industrial buildings, a tall slim chimney stack, a perimeter fence", "pale desert sand", 1960, 2026),
 ("lm_sorek_desalination", "A modern seawater desalination plant: long white industrial halls with blue trim, rows of large white cylindrical tanks, blue and white pipework and a pumping station, intake pipes running into the sea", "concrete and gravel on one half and turquoise sea water on the other half", 2005, 2026),
 ("lm_ben_gurion_airport", "A modern international airport: a curved glass passenger terminal with a white wave-shaped roof, an air traffic control tower, a short runway and taxiway with white markings, one plain white passenger jet airliner parked at a gate", "grey tarmac with green grass strips", 1948, 2026),
]
IMPROVEMENT = [
 ("imp_citrus_grove", "A citrus grove: neat rows of round dark-green orange trees heavy with bright orange fruit, little irrigation channels, a few stacked wooden fruit crates", "reddish-brown earth", 1948, 2026),
 ("imp_wheat_field", "A golden ripe wheat field in neat strips, a few round hay bales, a dirt track, a small vintage red tractor", "golden wheat and dirt", 1948, 2026),
 ("imp_fish_ponds", "Aquaculture fish ponds: four rectangular ponds of turquoise-green water separated by earthen dikes, a small white pump house, two white egrets", "earthen dikes and dry grass", 1948, 2026),
 ("imp_solar_field", "A solar power field: rows of tilted dark-blue photovoltaic panels on metal frames, a small white inverter building, gravel service lanes", "pale desert gravel", 2005, 2026),
 ("imp_gas_platform", "An offshore natural gas production platform: a steel platform deck on four tall yellow legs rising out of the sea, a helipad, a flare boom, cranes and pipework", "deep turquoise sea water with small waves", 2004, 2026),
 ("imp_phosphate_mine", "An open-pit phosphate mine: terraced pale cream and ochre quarry benches cut into the ground, a big yellow mining dump truck, an excavator, a conveyor belt to a pile of pale phosphate", "pale ochre desert rock", 1950, 2026),
 ("imp_water_tower", "A classic Israeli concrete water tower: a mushroom-shaped concrete water tank on a slender column, a small pump house and pipes, a few eucalyptus trees", "sun-baked earth and dry grass", 1948, 2026),
 ("imp_olive_grove", "An olive grove: neat rows of silvery-green olive trees with gnarled trunks on low dry-stone terrace walls", "reddish terra rossa earth", 1948, 2026),
]
# (id, subject)  -- no base, era-neutral
NATURE = [
 ("nat_date_palm", "A tall date palm tree with a slightly curved rough trunk, a crown of long arching green fronds and hanging clusters of orange dates"),
 ("nat_olive_tree", "A stylised old olive tree as in Civilization VI: a short thick twisted silver-grey trunk carrying a big dense solid canopy made of four or five chunky rounded clumps of silvery sage-green foliage, no gaps or bare branches visible, compact rounded silhouette"),
 ("nat_aleppo_pine", "A stylised Aleppo pine tree as in Civilization VI: a slender reddish-grey trunk with a slight lean, topped by a broad dense solid crown made of several chunky flat-topped clumps of fresh green pine needles stacked in layers, no bare branches visible, compact readable silhouette"),
 ("nat_cypress", "A tall slender Mediterranean cypress tree, a narrow dark-green column tapering to a point"),
 ("nat_rock_outcrop", "A rock outcrop of weathered pale cream limestone boulders with a few tufts of dry grass and a small green shrub in the cracks"),
]
# (id, subject, era_from, era_to)
UNIT = [
 ("unit_palmach_infantry", "A 1948 Palmach infantry soldier: khaki shorts and shirt, knitted wool 'kova tembel' style cap, webbing, rifle held at the ready, rolled blanket on the back", 1948, 1955),
 ("unit_sherman_m50", "An Israeli M-50 Super Sherman tank of the 1960s: Sherman hull and tracks in olive-grey paint, a modified turret with a long 75 mm gun and muzzle brake, stowage boxes and jerrycans, no markings", 1956, 1980),
 ("unit_merkava", "An Israeli Merkava Mark 4 main battle tank: a low angular wedge-shaped turret with a chain-ball curtain at the rear, sand-grey paint, long 120 mm gun, heavy side skirts over the tracks, no markings", 1979, 2026),
 ("unit_jet_mirage", "A 1960s Dassault Mirage IIIC delta-wing fighter jet in flight with landing gear up, sand-and-brown desert camouflage, single tail fin, no markings", 1962, 1985),
 ("unit_jet_f16", "A modern F-16I fighter jet in flight with landing gear up, desert tan-and-brown camouflage, conformal fuel tanks on the back, missiles under the wings, no markings", 1980, 2026),
 ("unit_saar_missile_boat", "An Israeli Sa'ar class missile boat: a small fast grey naval patrol vessel with an angular superstructure, a radar mast, anti-ship missile canisters on the rear deck and a deck gun at the bow, plain grey hull with no hull number and no markings, the whole boat from bow to stern visible, shown as a complete hull out of the water", 1967, 2026),
 ("unit_iron_dome", "An Iron Dome air-defence battery: a sand-coloured military trailer carrying a big rectangular box launcher with 20 tubes angled upward, a small radar panel unit beside it, no markings", 2011, 2026),
 ("unit_settler_group", "A small group of new immigrants around 1949: a man in a flat cap carrying a suitcase, a woman in a headscarf with a cloth bundle, and a child, standing close together beside a small wooden handcart piled with luggage", 1948, 2026),
 ("unit_worker_builder", "A builder: a sturdy construction worker in a blue work shirt and a cloth 'kova tembel' cap, holding a shovel, standing beside a wheelbarrow full of bricks", 1948, 2026),
 ("unit_archaeologist", "An archaeologist: wide-brimmed sun hat, khaki field clothes, a small pick and brush on the belt, holding a trowel in one hand and a clay amphora in the other", 1948, 2026),
 ("unit_trader_truck", "A vintage 1950s cargo truck with a rounded cab in faded turquoise and cream, the open load bed piled with wooden crates of oranges under a partly rolled canvas cover", 1948, 2026),
]
TERRAIN = [
 ("terrain_grassland", "lush Mediterranean grassland in spring: short green grass with tufts, clover, scattered tiny yellow and white wildflowers, small patches of warm earth"),
 ("terrain_plains", "dry Mediterranean plains in early summer: short straw-yellow and khaki dry grass mixed with patches of faded sage-green grass, small bare light-brown earth patches and a few small dry thistles"),
 ("terrain_desert_sand", "Negev desert sand: fine pale beige and light honey-coloured sand (not orange) with soft wind ripples and a few small scattered pebbles"),
 ("terrain_desert_rock", "Negev rocky desert and loess: cracked pale ochre loess crust partly covered with flat angular brown and black flint pebbles (desert pavement) and small stones"),
 ("terrain_hills_limestone", "Judean limestone hills with garrigue: pale cream limestone rock slabs and stony reddish soil, with low dense rounded shrubs of sage-green and dark green garrigue between the rocks"),
 ("terrain_basalt", "Golan Heights basalt plateau: dark grey-black basalt boulders and stones scattered over dark brown soil with yellow-green dry grass between"),
 ("terrain_marsh", "Hula Valley marsh: dense clumps of green papyrus and reeds with patches of shallow dark blue-green water and floating water-lily pads between"),
 ("terrain_beach_sand", "Mediterranean beach sand: clean pale cream-gold sand with tiny shell fragments and gentle ripple marks"),
 ("terrain_orchard_rows", "an orchard seen from directly above: exactly four straight parallel rows of evenly spaced round dark-green citrus tree canopies dotted with orange fruit, reddish-brown tilled earth between the rows"),
 ("terrain_pine_forest_floor", "Aleppo pine forest floor: a dense carpet of fallen long thin pine needles in warm brown and tan, many scattered small pine cones, a few dark green pine twigs and seedlings, small grey limestone pebbles, dappled shade"),
]
# (id, glyph, accent)
ICON_YIELD = [
 ("yield_gold", "a stack of gold coins", "a subtle warm gold inner glow"),
 ("yield_science", "a round-bottomed laboratory flask with bubbles", "a subtle sky-blue inner glow behind the glyph"),
 ("yield_culture", "a pair of music notes", "a subtle violet inner glow behind the glyph"),
 ("yield_food", "a sheaf of wheat with a leaf", "a subtle fresh-green inner glow behind the glyph"),
 ("yield_production", "a cog wheel with a hammer lying diagonally across its front, the hammer head clearly visible at the top right", "a subtle orange inner glow behind the glyph"),
 ("yield_happiness", "a smiling face", "a subtle sunny-yellow inner glow behind the glyph"),
 ("yield_housing", "a small house with a pitched roof and a door", "a subtle turquoise inner glow behind the glyph"),
]
ICON_ACTION = [
 ("action_cities", "a city skyline of three towers of different heights", "a subtle gold inner glow"),
 ("action_research", "an Erlenmeyer laboratory flask with liquid", "a subtle sky-blue inner glow behind the glyph"),
 ("action_culture", "comedy and tragedy theatre masks", "a subtle violet inner glow behind the glyph"),
 ("action_diplomacy", "two hands in a handshake", "a subtle warm gold inner glow"),
 ("action_trade", "a sailing ship with two sails on small waves", "a subtle turquoise inner glow behind the glyph"),
]
# (id, glyph, natural colours)
PINS = [
 ("res_citrus", "a Jaffa orange with a green leaf", "bright orange fruit, green leaf"),
 ("res_fish", "a leaping fish", "blue and silver fish"),
 ("res_olives", "a sprig of olives with leaves", "green and black olives, silvery-green leaves"),
 ("res_wheat", "two ears of wheat", "golden wheat"),
 ("res_phosphate", "a heap of phosphate rock", "pale cream and light grey rock with a few greenish crystals"),
 ("res_potash", "a heap of potash crystals", "pinkish-red and white salt crystals"),
 ("res_gas", "a natural gas flame", "bright blue flame with a cyan core"),
 ("res_copper", "a copper ingot with copper ore nuggets", "shiny orange-brown copper and green malachite ore"),
 ("res_dates", "a hanging bunch of dates", "glossy brown and amber dates on an orange stalk"),
 ("res_wine", "a bunch of grapes with a vine leaf", "deep purple grapes and a green vine leaf"),
 ("res_sheep", "a fluffy sheep standing in side view", "cream-white wool, dark grey face and legs"),
 ("res_camels", "a dromedary camel standing in side view with one hump", "sandy tan camel"),
 ("res_limestone", "a stack of cut limestone building blocks", "pale honey-cream stone blocks"),
 ("res_tobacco", "a bundle of large tobacco leaves", "green and golden-brown drying leaves"),
 ("res_gypsum", "a cluster of translucent gypsum selenite crystals", "white and pale pink glassy crystals"),
 ("res_clay", "a clay amphora jar beside a lump of wet clay", "terracotta orange-red clay"),
 ("res_salt", "a heap of white salt crystals with a few cubic crystals in front", "bright white and pale grey salt"),
]


# Single buildings / structures with no base (renderer lays them out). (id, subject, era_from, era_to, real size m (w, d, h))
BUILDING = [
 ("bld_bauhaus_block", "A 1930s-1950s Tel Aviv International Style (Bauhaus) apartment block of 3-4 storeys: white and cream rendered walls, rounded corner balconies with thin metal railings, horizontal ribbon windows, flat roof with a small stairwell box, raised on short pilotis", 1948, 2026, (18, 14, 14)),
 ("bld_shikun_block", "A 1950s-60s Israeli 'shikun' public housing block: a long plain four-storey concrete slab building in pale cream stucco with rows of identical small windows and shallow balconies, laundry on some balconies, rooftop solar water heaters", 1952, 2026, (40, 12, 13)),
 ("bld_arab_stone_house", "A traditional Palestinian Arab village stone house: a cubic two-storey house of rough honey-coloured limestone blocks with a shallow stone dome on the flat roof, arched windows with green wooden shutters, an outside stone staircase", 1948, 2026, (12, 10, 9)),
 ("bld_jaffa_old_house", "An Ottoman-era Jaffa old-town building: a three-storey sandstone building with pointed arched windows and doors, a wooden mashrabiya balcony, a small arcade on the ground floor and a terracotta-tiled corner roof", 1948, 2026, (14, 12, 13)),
 ("bld_jaffa_clock_tower", "The Jaffa Clock Tower: a slender three-stage Ottoman limestone clock tower with arched openings, round clock faces without numerals on each side and a small crenellated top", 1948, 2026, (6, 6, 25)),
 ("bld_kibbutz_dining_hall", "A 1950s kibbutz communal dining hall: a long low white-washed building with a red-tiled pitched roof, a row of large windows, a wide entrance porch on simple columns", 1948, 2026, (30, 15, 8)),
 ("bld_kibbutz_water_tower", "A 1940s-50s kibbutz water tower built entirely of grey poured reinforced concrete (no wood, no metal tank): a squat cylindrical concrete tank with a slightly projecting rim, raised on four tall square concrete columns joined by horizontal concrete beams, a thin iron ladder", 1948, 2026, (6, 6, 18)),
 ("bld_maabara_tents", "A small cluster of 1950 ma'abara transit camp shelters standing directly on the bare ground: three white canvas army tents and two small corrugated-tin huts close together with a washing line between them", 1948, 1963, (25, 20, 4)),
 ("bld_concrete_tower_7090", "A 1970s-1990s Israeli concrete residential tower of about 15 storeys: beige precast concrete facade with a grid of square windows and rows of enclosed balconies, rooftop solar water heaters and antennas", 1970, 2026, (25, 20, 50)),
 ("bld_glass_tower_2000s", "A 2000s-2020s Tel Aviv glass office skyscraper: a tall slim tower of blue-green reflective glass with white vertical fins, a slightly tapered crown and a glazed lobby at its foot", 2000, 2026, (35, 30, 160)),
 ("lm_dome_of_the_rock_nb", "The Dome of the Rock shrine in Jerusalem on its own: the octagonal building with blue-and-turquoise tiled walls and a large golden dome, standing directly on the ground", 1948, 2026, (54, 54, 36)),
 ("lm_knesset_nb", "The Knesset building in Jerusalem on its own: a low square modernist parliament building of pale Jerusalem stone with a flat roof and a colonnade of tall slender rectangular pillars on all sides", 1966, 2026, (100, 70, 18)),
 ("lm_bahai_shrine_nb", "The Baha'i Shrine of the Bab in Haifa on its own: a white marble shrine with an arcade of slender columns, an octagonal drum with tall windows and a golden-tiled dome topped by a small lantern", 1953, 2026, (35, 35, 40)),
 ("lm_azrieli_towers_nb", "The Azrieli Center in Tel Aviv on its own: three tall modern skyscrapers rising from one low podium building, one round cylindrical tower, one triangular tower and one square tower, all of blue-grey glass with white bands", 1999, 2026, (160, 110, 187)),
 ("lm_nuclear_dome_nb", "A generic desert nuclear research reactor building on its own: one large silver-grey concrete dome on a round base with a few low attached white blocks and a tall slim chimney", 1960, 2026, (80, 60, 60)),
 ("lm_desalination_nb", "A modern seawater desalination plant building group on its own: two long white industrial halls with blue trim, a row of four large white cylindrical tanks and blue and white pipework between them", 2005, 2026, (250, 150, 25)),
 ("lm_airport_terminal_nb", "A modern airport passenger terminal on its own: a curved glass terminal building with a white wave-shaped roof and a tall air traffic control tower beside it", 1948, 2026, (250, 120, 60)),
]


def all_images():
    """yield (id, group, rawpath relative to game/assets, prompt, transparent)"""
    for i, s, g, *_ in CITY + LANDMARK + IMPROVEMENT:
        yield i, "model", f"model_src/{i}.png", P.tile(s, g) if g else P.tile(s), False
    for i, s in NATURE:
        yield i, "model", f"model_src/{i}.png", P.prop(s), False
    for i, s, *_ in UNIT:
        yield i, "model", f"model_src/{i}.png", P.unit(s), False
    for i, s, *_ in BUILDING:
        yield i, "model", f"model_src/{i}.png", P.building(s), False
    for i, kind, tpl, s, *_ in R2:
        yield i, "model", f"model_src/{i}.png", getattr(P, tpl)(s), False
    for i, s, e0, e1, real, meas, flat in R3:
        yield i, "model", f"model_src/{i}.png", P.roofbld(s, flat), False
    for i, s in TERRAIN:
        yield i, "terrain", f"_pipeline/raw/{i}.png", P.terrain(s), False
    for i, g, a in ICON_YIELD + ICON_ACTION:
        yield i, "icon", f"_pipeline/raw/{i}.png", P.icon(g, a), True
    for i, g, c in PINS:
        yield i, "icon", f"_pipeline/raw/{i}.png", P.pin(g, c), True
