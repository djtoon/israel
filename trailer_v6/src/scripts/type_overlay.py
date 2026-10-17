"""Kinetic typography for Acts 1, 2 and 4 as ONE strata scene on black, the length of the trailer.
It is rendered twice in the cloud: the colour pass (type on black, premultiplied) and a matte pass (every colour
white), and the edit composites  out = plate * (1 - matte) + colour.
   python -I type_overlay.py  ->  strata/type_color.json, strata/type_matte.json"""
import json, copy

W, H, FPS = 1920, 1080, 24
DUR = 102.0
GOLD, GOLD_HI, CREAM = "#E8C878", "#FFE3A0", "#EFE3C6"
CINZEL, CINZEL_B, CINZEL_R, CORM = "./Cinzel-SemiBold.ttf", "./Cinzel-ExtraBold.ttf", "./Cinzel-Regular.ttf", "./Cormorant-SemiBold.ttf"
layers = []


def text(name, s, t0, t1, y, size, font=CINZEL, color=GOLD, tracking=200, reveal=1.0, glow=0.3, out=0.4,
         rise=24, x=0, w=W, align="center middle", shadow=0.85, drift=0.0, reveal_mode="ramp"):
    d = t1 - t0
    lay = {"type": "text", "name": name, "text": s, "font": font, "size": size, "color": color,
           "box": [x, y - size, w, size * 2], "align": align, "tracking": tracking, "start": t0, "duration": d}
    if reveal_mode == "ramp":
        lay["animators"] = [{"opacity": 0, "position": [0, rise, 0],
                             "ranges": [{"based_on": "characters", "shape": "ramp_up", "start": 0, "end": 0.5,
                                         "animate": {"offset": [{"t": 0, "v": -0.5}, {"t": reveal, "v": 1}]}}]}]
    fx = []
    if shadow:
        fx.append({"type": "shadow", "color": "#000000", "opacity": min(1.0, shadow + 0.1), "angle": 90, "distance": 3,
                   "size": max(10, int(size * 0.2))})
    if glow:
        fx.append({"type": "glow", "color": GOLD_HI, "opacity": glow * 0.4, "spread": 0, "size": 16, "range": 0.5})
    lay["effects"] = fx
    a = {}
    if out:
        a["opacity"] = [{"t": d - out, "v": 1, "ease": "inCubic"}, {"t": d, "v": 0}]
        if reveal_mode == "fade":
            a["opacity"] = [{"t": 0, "v": 0, "ease": "outCubic"}, {"t": reveal, "v": 1}] + a["opacity"]
    if drift:
        lay["anchor"] = [W / 2, y]
        a["scale"] = [{"t": 0, "v": 1.0}, {"t": d, "v": 1.0 + drift}]
    if a:
        lay["animate"] = a
    layers.append(lay)
    return lay


def rule(name, t0, t1, y, half, color=GOLD, grow=1.0, thick=2, cx=W / 2, out=0.4):
    d = t1 - t0
    layers.append({"type": "solid", "name": name, "color": color, "box": [0, 0, W, H], "start": t0, "duration": d,
                   "mask": {"path": f"M{cx - half} {y} L{cx + half} {y}", "stroke": thick, "cap": "butt",
                            "trim": {"start": [{"t": 0, "v": 0.5, "ease": "outExpo"}, {"t": grow, "v": 0}],
                                     "end": [{"t": 0, "v": 0.5, "ease": "outExpo"}, {"t": grow, "v": 1}]}},
                   "animate": {"opacity": [{"t": d - out, "v": 1}, {"t": d, "v": 0}]}})


def caption(name, s, t0, t1, y=872):
    """the small, wide-tracked era captions"""
    text(name, s, t0, t1, y, 27, font=CINZEL_R, color=CREAM, tracking=620, reveal=1.4, glow=0, out=0.5, rise=10)


# ---- ACT 1
caption("c_spring", "SPRING 1948", 8.2, 11.7)
caption("c_museum", "TEL AVIV MUSEUM  \u00b7  4 PM", 15.6, 18.75)
text("t_date", "14 MAY 1948", 19.0, 22.85, 515, 164, font=CINZEL, tracking=150, reveal=1.25, glow=0.42, out=0.5,
     rise=34, drift=-0.03)
rule("r_date", 19.7, 22.85, 628, 420, grow=1.4, out=0.5)
text("t_declared", "A NEW STATE IS DECLARED", 20.3, 22.85, 683, 38, font=CORM, color=CREAM, tracking=560, reveal=1.4,
     glow=0, out=0.5, rise=12)
text("t_three", "IN THREE YEARS", 23.45, 26.75, 850, 58, font=CINZEL, tracking=320, reveal=1.2, glow=0.25, out=0.45)
text("t_double", "ITS POPULATION DOUBLES", 27.3, 30.75, 850, 58, font=CINZEL, tracking=320, reveal=1.3, glow=0.25,
     out=0.45)

# ---- ACT 2: the title slams on the downbeat, then one word per cut
text("t_build", "BUILD A NATION", 35.0, 38.75, 530, 124, font=CINZEL_B, tracking=190, reveal=1.0, glow=0.5, out=0.35,
     rise=0, drift=0.035)
rule("r_build", 35.35, 38.75, 628, 430, grow=0.9, out=0.35)
for i, wd in enumerate(["WATER", "FIELDS", "HARBOURS", "ROADS", "RAILWAYS", "TOWERS"]):
    t0 = 39.0 + 2 * i
    text(f"w_{i}", wd, t0 + 0.08, t0 + 1.92, 858, 64, font=CINZEL, tracking=620, reveal=0.85, glow=0.3, out=0.22,
         rise=16)

# ---- ACT 4: the triad on the climax
for nm, wd, t0, t1 in [("e_war", "EVERY WAR", 78.05, 81.9), ("e_peace", "EVERY PEACE", 82.05, 83.92),
                       ("e_dream", "EVERY DREAM", 84.05, 85.92)]:
    text(nm, wd, t0, t1, 846, 84, font=CINZEL, tracking=380, reveal=0.85, glow=0.35, out=0.2, rise=0, drift=0.03)

# ---- ACT 3: the diplomacy burst (59-63). Tiny gold name tags on the first six cuts (one-frame fades),
# then the title over the fastest cuts into the 63.0 downbeat
_cuts = [(59.0, 12, "DAVID BEN-GURION  ·  ISRAEL"), (59.5, 12, "HARRY S. TRUMAN  ·  UNITED STATES"),
         (60.0, 6, "LEVI ESHKOL  ·  ISRAEL"), (60.25, 6, "LYNDON B. JOHNSON  ·  UNITED STATES"),
         (60.5, 6, "GOLDA MEIR  ·  ISRAEL"), (60.75, 6, "RICHARD NIXON  ·  UNITED STATES")]
for k, (t0, nf, label) in enumerate(_cuts):
    d = nf / FPS
    layers.append({"type": "text", "name": f"lead_{k}", "text": label, "font": CINZEL, "size": 22, "color": GOLD,
                   "box": [0, 880 - 22, W, 44], "align": "center middle", "tracking": 340, "start": t0, "duration": d,
                   "effects": [{"type": "shadow", "color": "#000000", "opacity": 0.95, "angle": 90, "distance": 2, "size": 10}],
                   "animate": {"opacity": [{"t": 0, "v": 0}, {"t": 1 / FPS, "v": 1}, {"t": d - 1 / FPS, "v": 1}, {"t": d, "v": 0}]}})
text("d_title", "THE LEADERS.  THE ALLIES.", 61.0, 63.0, 860, 46, font=CINZEL, tracking=320, reveal=0.7, glow=0.3,
     out=0.08, rise=10)

base = {"width": W, "height": H, "fps": FPS, "duration": DUR, "layers": [
    {"type": "solid", "name": "black", "color": "#000000", "box": [0, 0, W, H]}] + layers}
# colour pass: type + glow (light); matte pass: type + its soft shadow (coverage). The edit composites
# out = plate * (1 - matte) + colour, so the glow adds light and the shadow only darkens.
m = copy.deepcopy(base)
for l in base["layers"][1:]:
    l["effects"] = [fx for fx in l.get("effects", []) if fx["type"] != "shadow"]
for l in m["layers"][1:]:
    if "color" in l:
        l["color"] = "#FFFFFF"
    l["effects"] = [dict(fx, color="#FFFFFF") for fx in l.get("effects", []) if fx["type"] == "shadow"]
json.dump(base, open("C:/civ/trailer_v6/src/strata/type_color.json", "w", encoding="utf-8"), indent=1, ensure_ascii=False)
json.dump(m, open("C:/civ/trailer_v6/src/strata/type_matte.json", "w", encoding="utf-8"), indent=1, ensure_ascii=False)
print(len(layers), "layers")
