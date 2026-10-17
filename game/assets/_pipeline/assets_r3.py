"""Round 3: building variety for the city generator (metre scale, no base, readable from above).
(id, subject, era_from, era_to, real (w, d, h), measure, flat_roof)"""

R3 = [
 # Tel Aviv Bauhaus 3-4 storeys
 ("r3_bauhaus_corner", "A four-storey white Tel Aviv Bauhaus corner apartment building on a wedge-shaped plot, the corner rounded with stacked curved wrap-around balconies, ribbon windows, raised on pilotis with an open ground floor", 1933, 2026, (20, 14, 15), "h", True),
 ("r3_bauhaus_long", "A long three-storey cream Tel Aviv Bauhaus apartment building with continuous horizontal balcony bands along the whole facade, a projecting rounded stairwell tower at one end, short pilotis", 1934, 2026, (24, 11, 11), "w", True),
 ("r3_bauhaus_cube", "A compact four-storey white cubic Tel Aviv Bauhaus building with deep recessed loggias, one curved balcony on the corner, a vertical strip window for the stairwell, small square plan", 1935, 2026, (12, 12, 14), "h", True),
 # shikun slabs
 ("r3_shikun_pilotis", "A 1950s Israeli shikun: a long plain four-storey grey-cream concrete slab raised on bare concrete pilotis with an open ground floor, rows of identical small windows and tiny balconies", 1952, 2026, (40, 11, 14), "w", True),
 ("r3_shikun_l", "A 1950s Israeli shikun public housing block, L-shaped plan, three storeys, pale cream stucco, small windows with grey roller shutters, enclosed balconies, outdoor stairwell", 1950, 2026, (28, 22, 10), "w", True),
 ("r3_shikun_stepped", "A 1960s Israeli shikun: two four-storey slab blocks joined with a half-storey step between them, pale yellow plaster, rows of balconies with laundry lines", 1958, 2026, (36, 12, 13), "w", True),
 # 1960s-90s 8-storey blocks
 ("r3_block8_a", "A 1970s Israeli eight-storey apartment block: a tall rectangular slab of beige concrete with rows of enclosed balconies and roller shutters, a lift tower on the roof", 1968, 2026, (30, 14, 26), "h", True),
 ("r3_block8_b", "A 1980s Israeli eight-storey apartment block on pilotis: white plaster with protruding staggered balconies, a grey stone-clad ground floor, an H-shaped plan", 1978, 2026, (28, 18, 28), "h", True),
 ("r3_block8_c", "A 1990s Israeli eight-storey apartment tower with a square plan, pink-beige stone cladding, corner balconies on every floor, a pergola on the top floor", 1990, 2026, (20, 20, 28), "h", True),
 # Jerusalem stone apartments, flat roof
 ("r3_jer_flat_3", "A three-storey Jerusalem apartment building fully clad in honey-gold rough Jerusalem stone, tall arched windows on the top floor, square windows below, small stone balconies", 1930, 2026, (16, 12, 11), "h", True),
 ("r3_jer_flat_5", "A five-storey 1960s-80s Jerusalem apartment building clad in pale cream Jerusalem stone, rows of square windows with green shutters, recessed balconies, a stone stairwell tower", 1960, 2026, (22, 13, 17), "h", True),
 ("r3_jer_flat_6t", "A six-storey Jerusalem stone apartment building stepping down a hillside in terraces, each terrace with a balcony and arched openings, warm gold stone", 1970, 2026, (20, 18, 20), "h", True),
 # Arab old-town stone houses
 ("r3_arab_dome_cluster", "A cluster of three joined Arab old-town stone houses of different heights (one, two and three storeys), each with a shallow stone dome on its flat roof, arched doorways and small arched windows, honey limestone", 1800, 2026, (18, 14, 10), "w", False),
 ("r3_arab_courtyard", "A two-storey Arab stone courtyard house: a square block of rough limestone around an open inner courtyard, a row of pointed arches along the courtyard, two small domes, a flat roof terrace with a parapet", 1800, 2026, (16, 16, 8), "w", False),
 ("r3_arab_tall_narrow", "A tall narrow four-storey Arab old-town stone house wedged in a row, rough pale stone, stacked arched windows with turquoise shutters, a small wooden balcony, a flat roof with a little dome", 1850, 2026, (8, 10, 13), "h", False),
 # Templer (only where historical: Sarona, German Colonies)
 ("r3_templer_house_a", "A 19th-century German Templer colony house as in Sarona or the Haifa German Colony: two storeys of pale limestone, a steep red Marseille-tile gable roof, symmetrical shuttered windows, a small porch", 1870, 2026, (14, 11, 11), "h", False),
 ("r3_templer_house_b", "A 19th-century German Templer colony house: a one-and-a-half storey pale stone house with a red-tiled hipped roof with a dormer window, green shutters, stone steps to the door", 1870, 2026, (13, 10, 9), "h", False),
 # kibbutz housing rows
 ("r3_kibbutz_row_a", "A 1950s kibbutz members housing row: a long single-storey whitewashed building with four identical units, a red-tiled gable roof, small porches with simple posts", 1950, 2026, (28, 8, 5), "w", False),
 ("r3_kibbutz_row_b", "A 1960s kibbutz housing row: a long single-storey building of pale blocks with a flat roof with solar water heaters, four small units each with a porch and a door", 1960, 2026, (26, 8, 4), "w", True),
 ("r3_kibbutz_row_c", "A 1970s kibbutz two-storey housing row with a sloped red tile roof, white walls, outdoor stairs to the upper units, small balconies", 1970, 2026, (24, 9, 8), "w", False),
 # development town 4-storey blocks
 ("r3_devtown_a", "A 1960s Israeli development-town apartment block: a plain four-storey slab of grey-beige concrete blocks, exposed concrete frame, tiny windows, enclosed balconies of different colours added by residents", 1957, 2026, (32, 11, 13), "w", True),
 ("r3_devtown_b", "A 1960s Israeli development-town four-storey block on short pilotis, pale yellow plaster weathered with streaks, three entrance stairwells marked by vertical window strips", 1957, 2026, (36, 11, 14), "w", True),
 ("r3_devtown_c", "A 1970s Israeli development-town four-storey train-like block: a very long slab with many repeated stairwell bays, white plaster, balconies with metal railings", 1965, 2026, (50, 11, 13), "w", True),
 # glass towers with setback crowns
 ("r3_glass_setback_a", "A 2010s Tel Aviv glass residential skyscraper: a slim tower of blue-grey glass with white horizontal balcony bands, the top floors stepping back in two setbacks to a narrow crown with a rooftop terrace", 2005, 2026, (30, 26, 150), "h", False),
 ("r3_glass_setback_b", "A 2020s Tel Aviv glass office skyscraper: a square tower of green-tinted glass on a podium, a sharply angled sloping crown cut diagonally at the top, vertical white fins", 2015, 2026, (40, 35, 180), "h", False),
 ("r3_glass_setback_c", "A 2000s Tel Aviv glass tower: an elliptical tower of light blue glass with a stone-clad base, the top three floors set back in a stepped wedding-cake crown with a mast", 2000, 2026, (32, 28, 130), "h", False),
 # v3 hero buildings
 ("v3_king_david_hotel", "The King David Hotel in Jerusalem (1931): a large seven-storey L-shaped hotel of pale pinkish Jerusalem limestone with a symmetrical front, central arched entrance block, small towers", 1948, 2026, (70, 50, 30), "h", True),
 ("v3_yad_vashem_museum", "The Yad Vashem Holocaust History Museum, Jerusalem (2005): a long narrow triangular prism of raw grey concrete with a skylight ridge", 2005, 2026, (110, 20, 20), "w", True),
 ("v3_shalom_meir_tower", "The Shalom Meir Tower, Tel Aviv (1965): a slim 34-storey white and pale-blue modernist office tower on a low podium", 1965, 2026, (35, 35, 142), "h", True),
 ("v3_jaffa_clock_tower2", "The Jaffa Clock Tower (1903): a slender three-stage Ottoman limestone clock tower with clock faces and a crenellated top", 1948, 2026, (6, 6, 25), "h", False),
 ("v3_liebling_house", "The Max Liebling House, Tel Aviv (1936), White City International Style: four storeys, rounded corner, ribbon windows, glazed stairwell strip, pilotis", 1936, 2026, (17, 14, 16), "h", True),
 ("v3_dizengoff_circle", "A Dizengoff Circle style Tel Aviv Bauhaus corner building (1938): five storeys, facade curving in an arc with wrap-around curved balconies, shops on slender columns", 1938, 2026, (22, 20, 20), "h", True),
]
