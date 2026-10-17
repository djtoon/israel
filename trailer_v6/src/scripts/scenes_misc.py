"""Strata scenes for the cold open light pass, the war-fronts card and the finale logo resolve.
   python -I scenes_misc.py -> strata/logo_fx.json (7 s, additive light on black),
                               strata/fronts.json (2 s), strata/finale.json (8 s)"""
import json, math

W, H, FPS = 1920, 1080, 24
GOLD, GOLD_HI, CREAM = "#E8C878", "#FFE3A0", "#EFE3C6"
CINZEL, CINZEL_B, CINZEL_R, CORM = "./Cinzel-SemiBold.ttf", "./Cinzel-ExtraBold.ttf", "./Cinzel-Regular.ttf", "./Cormorant-SemiBold.ttf"
HEB = "./FrankRuhl-Medium.ttf"
S = "C:/civ/trailer_v6/src/strata/"


def save(name, scene):
    json.dump(scene, open(S + name, "w", encoding="utf-8"), indent=1, ensure_ascii=False)


def streak(prefix, t, y, cx=W / 2, dur=1.1, core="#FFF6DE", warm="#FFB65A", width=1.0):
    """an anamorphic lens streak: a hot thin core and a wide warm wing, flashing out from the centre"""
    out = []
    for nm, col, h, fe, op in [("core", core, 4, 2, 1.0), ("wing", warm, 46, 22, 0.55), ("haze", warm, 180, 90, 0.18)]:
        out.append({"type": "solid", "name": f"{prefix}_{nm}", "color": col, "box": [0, y - h * 2, W, h * 4],
                    "blend": "add", "start": t - 0.08, "duration": dur, "anchor": [cx, y],
                    "mask": {"rect": [-200, y - h / 2, W + 400, h], "feather": fe},
                    "animate": {"scale": [{"t": 0, "v": [0.05, 1], "ease": "outExpo"}, {"t": 0.45, "v": [1.3 * width, 1]},
                                          {"t": dur, "v": [1.6 * width, 0.6]}],
                                "opacity": [{"t": 0, "v": 0}, {"t": 0.1, "v": op, "ease": "outCubic"}, {"t": dur, "v": 0}]}})
    out.append({"type": "solid", "name": f"{prefix}_bloom", "color": warm, "box": [0, 0, W, H], "blend": "add",
                "start": t - 0.05, "duration": dur,
                "mask": {"ellipse": [cx, y, 380, 120], "feather": 260},
                "animate": {"opacity": [{"t": 0, "v": 0}, {"t": 0.08, "v": 0.5, "ease": "outCubic"}, {"t": dur, "v": 0}]}})
    return out


# ------------------------------------------------------------------ cold open: light pass over the TMT logo
logo_fx = {"width": W, "height": H, "fps": FPS, "duration": 7.0, "layers": [
    {"type": "solid", "name": "black", "color": "#000000", "box": [0, 0, W, H]},
    *streak("lk", 3.3, 468, cx=969, dur=1.4, core="#F4F8FF", warm="#FFC46E"),
    {"type": "particles", "name": "lock_sparks", "shape": "rect", "rect": [470, 320, 1000, 300],
     "burst": [{"t": 3.3, "count": 520}], "direction": -90, "spread": 360, "speed": [80, 620],
     "life": [0.7, 1.9], "seed": 48,
     "particle": {"type": "spark", "size": [1.5, 3.5], "color": ["#FFF2CF", "#FFD27A", "#E8C878"], "glow": 1.2,
                  "blend": "add", "opacity_over_life": [[0, 1], [0.6, 0.8], [1, 0]], "trail": {"length": 0.08}},
     "forces": {"gravity": 140, "drag": 1.6, "turbulence": {"strength": 60}}, "resolution": 0.75},
    {"type": "particles", "name": "gold_dust", "shape": "rect", "rect": [0, 0, 1920, 1080], "rate": 36,
     "start": 3.4, "end": 7.0, "direction": -90, "spread": 60, "speed": [6, 30], "life": [2.5, 4.0], "seed": 7,
     "particle": {"type": "dot", "size": [1.2, 3.0], "color": ["#FFE3A0", "#E8C878"], "softness": 0.7, "blend": "add",
                  "opacity_over_life": [[0, 0], [0.3, 0.55], [1, 0]]},
     "forces": {"turbulence": {"strength": 25}}, "resolution": 0.5},
]}
save("logo_fx.json", logo_fx)

# ------------------------------------------------------------------ the war-fronts card, 2 s (letterboxed in the edit)
FOV = 40.0
F = (H / 2) / math.tan(math.radians(FOV / 2))
cw, ch = 804, 784
sc = 690 / ch
box = [960 - cw * sc / 2, 540 - ch * sc / 2, cw * sc, ch * sc]
fronts = {"width": W, "height": H, "fps": FPS, "duration": 2.0,
          "comps": {"c_fr": {"width": cw, "height": ch, "duration": 2.0, "layers": [
              {"type": "image", "name": "fr_img", "src": "./ui/card_fronts.png", "box": [0, 0, cw, ch]},
              {"type": "solid", "name": "fr_sweep", "color": "#FFF1CC", "box": [-180, -400, 180, ch + 800],
               "blend": "add", "opacity": 0.3, "anchor": [-90, ch / 2], "rotation": 16,
               "mask": {"rect": [-180, -400, 180, ch + 800], "feather": 80},
               "animate": {"position": [{"t": 0.2, "v": [-200, ch / 2], "ease": "inOutSine"}, {"t": 1.4, "v": [cw + 300, ch / 2]}]}}]}},
          "layers": [
              {"type": "solid", "name": "fr_base", "color": "#050A16", "box": [0, 0, W, H]},
              {"type": "image", "name": "fr_bg", "src": "./ui/bg_map.png", "box": [-1400, -800, 4720, 2680], "is_3d": True,
               "position": [0, 0, 2200], "motion_blur": False},
              {"type": "comp", "name": "fr_card", "comp": "c_fr", "box": box, "is_3d": True, "anchor": [960, 540],
               "position": [960, 540, 0],
               "effects": [{"type": "shadow", "color": "#000000", "opacity": 0.7, "angle": 110, "distance": 30, "size": 44}],
               "animate": {"rotation": [{"t": 0, "v": [6, -22, 0], "ease": "outCubic"}, {"t": 2, "v": [3, -9, 0]}]}},
              {"type": "solid", "name": "fr_vig", "color": "#02050C", "box": [0, 0, W, H], "opacity": 0.6,
               "mask": {"ellipse": [960, 540, 1180, 640], "feather": 420, "inverted": True}},
              {"type": "camera", "name": "fr_cam", "fov": FOV, "motion_blur": True, "position": [960, 540, -F],
               "animate": {"position": [{"t": 0, "v": [900, 556, -F - 90], "ease": "outCubic"}, {"t": 2, "v": [1000, 540, -F + 110]}]}}]}
save("fronts.json", fronts)

# ------------------------------------------------------------------ finale: the logo resolve and the end card, 8 s
LW = 1240
LH = LW * 464 / 1769
LX, LY = 960 - LW / 2, 392 - LH / 2
D = 8.0
fin_layers = [
    {"type": "solid", "name": "f_base", "color": "#03070F", "box": [0, 0, W, H]},
    {"type": "image", "name": "f_back", "src": "./ui/finale_back.png", "box": [0, 0, W, H], "anchor": [960, 540],
     "opacity": 0.0,
     "animate": {"opacity": [{"t": 0, "v": 0.0}, {"t": 1.2, "v": 0.55, "ease": "outCubic"}, {"t": 7.0, "v": 0.55},
                             {"t": 8.0, "v": 0}],
                 "scale": [{"t": 0, "v": 1.0}, {"t": 8, "v": 1.06}]}},
    {"type": "solid", "name": "f_glow", "color": "#16305A", "box": [0, 0, W, H], "blend": "screen",
     "mask": {"ellipse": [960, 430, 900, 380], "feather": 520},
     "animate": {"opacity": [{"t": 0, "v": 0}, {"t": 1.0, "v": 0.65}, {"t": 7.2, "v": 0.65}, {"t": 8, "v": 0}]}},
    # gold dust gathers into the logo
    {"type": "particles", "name": "f_gather", "shape": "rect", "rect": [-200, -100, 2320, 1280],
     "burst": [{"t": 0.0, "count": 2600}], "direction": 0, "spread": 360, "speed": [0, 80], "life": [1.65, 1.65],
     "seed": 1948,
     "particle": {"type": "dot", "size": [1.4, 3.2], "color": ["#FFE3A0", "#E8C878", "#FFF4DA"], "softness": 0.6,
                  "blend": "add", "glow": 0.6, "opacity_over_life": [[0, 0], [0.15, 1], [0.75, 1], [1, 0]]},
     "forces": {"attract": {"strength": 46, "layer": "f_logo_target"}}, "resolution": 0.75},
    {"type": "image", "name": "f_logo_target", "src": "C:/civ/game/assets/intro/title.png", "box": [LX, LY, LW, LH],
     "visible": False},
    {"type": "image", "name": "f_logo", "src": "C:/civ/game/assets/intro/title.png", "box": [LX, LY, LW, LH],
     "anchor": [960, 392],
     "effects": [{"type": "shadow", "color": "#000000", "opacity": 0.8, "angle": 90, "distance": 6, "size": 30},
                 {"type": "glow", "color": "#FFD58A", "opacity": 0.25, "spread": 0, "size": 30, "range": 0.5}],
     "animate": {"opacity": [{"t": 0.95, "v": 0, "ease": "outCubic"}, {"t": 1.6, "v": 1}, {"t": 7.3, "v": 1},
                             {"t": 8.0, "v": 0}],
                 "scale": [{"t": 0.95, "v": 1.045, "ease": "outCubic"}, {"t": 2.6, "v": 1.0}, {"t": 8, "v": 1.018}]}},
    {"type": "comp", "name": "f_glint", "comp": "c_glint", "box": [LX, LY, LW, LH], "blend": "add", "anchor": [960, 392],
     "animate": {"scale": [{"t": 0.95, "v": 1.045, "ease": "outCubic"}, {"t": 2.6, "v": 1.0}, {"t": 8, "v": 1.018}]}},
    *streak("fs", 1.25, 392, dur=1.5, width=1.0),
]
glint = {"width": round(LW), "height": round(LH), "duration": D, "layers": [
    {"type": "image", "name": "g_matte", "src": "C:/civ/game/assets/intro/title.png", "box": [0, 0, LW, LH], "visible": False},
    {"type": "solid", "name": "g_sweep", "color": "#FFF6DC", "box": [-260, -LH, 260, LH * 3], "opacity": 0.85,
     "anchor": [-130, LH / 2], "rotation": 22, "mask": {"rect": [-260, -LH, 260, LH * 3], "feather": 110},
     "matte": {"type": "alpha", "source": "g_matte"},
     "animate": {"position": [{"t": 1.7, "v": [-300, LH / 2], "ease": "inOutSine"}, {"t": 2.9, "v": [LW + 300, LH / 2]}]}}]}


def txt(name, s, t0, y, size, font, color, tracking, reveal=1.2, rise=14, glow=0.2, mode="ramp"):
    lay = {"type": "text", "name": name, "text": s, "font": font, "size": size, "color": color,
           "box": [0, y - size, W, size * 2], "align": "center middle", "tracking": tracking, "start": t0,
           "duration": D - t0,
           "effects": [{"type": "shadow", "color": "#000000", "opacity": 0.8, "angle": 90, "distance": 2, "size": 16}]
                      + ([{"type": "glow", "color": GOLD_HI, "opacity": glow, "spread": 0, "size": 18, "range": 0.6}] if glow else []),
           "animate": {"opacity": [{"t": D - t0 - 0.8, "v": 1, "ease": "inCubic"}, {"t": D - t0, "v": 0}]}}
    if mode == "ramp":
        lay["animators"] = [{"opacity": 0, "position": [0, rise, 0],
                             "ranges": [{"based_on": "characters", "shape": "ramp_up", "start": 0, "end": 0.5,
                                         "animate": {"offset": [{"t": 0, "v": -0.5}, {"t": reveal, "v": 1}]}}]}]
    else:  # Hebrew: one gentle rise and fade for the whole line (logical order, the engine lays out RTL)
        lay["anchor"] = [960, y]
        lay["animate"]["opacity"] = [{"t": 0, "v": 0, "ease": "outCubic"}, {"t": reveal, "v": 1}] + lay["animate"]["opacity"]
        lay["animate"]["position"] = [{"t": 0, "v": [960, y + rise], "ease": "outCubic"}, {"t": reveal, "v": [960, y]}]
    fin_layers.append(lay)


txt("f_heb", "\u05d9\u05e9\u05e8\u05d0\u05dc: \u05dc\u05d9\u05d3\u05ea\u05d4 \u05e9\u05dc \u05d0\u05d5\u05de\u05d4", 1.75, 612, 46, HEB, CREAM, 60,
    reveal=0.9, mode="fade", glow=0)
for nm, x0 in [("f_rl", 960 - 330), ("f_rr", 960 + 330)]:
    pass
fin_layers.append({"type": "solid", "name": "f_rule_l", "color": GOLD, "box": [0, 0, W, H], "start": 2.6, "duration": D - 2.6,
                   "mask": {"path": "M770 708 L560 708", "stroke": 1.5, "trim": {"end": [{"t": 0, "v": 0, "ease": "outCubic"}, {"t": 0.8, "v": 1}]}},
                   "animate": {"opacity": [{"t": D - 2.6 - 0.8, "v": 1}, {"t": D - 2.6, "v": 0}]}})
fin_layers.append({"type": "solid", "name": "f_rule_r", "color": GOLD, "box": [0, 0, W, H], "start": 2.6, "duration": D - 2.6,
                   "mask": {"path": "M1150 708 L1360 708", "stroke": 1.5, "trim": {"end": [{"t": 0, "v": 0, "ease": "outCubic"}, {"t": 0.8, "v": 1}]}},
                   "animate": {"opacity": [{"t": D - 2.6 - 0.8, "v": 1}, {"t": D - 2.6, "v": 0}]}})
txt("f_years", "1948 \u2013 2023", 2.55, 708, 30, CINZEL_R, CREAM, 520, reveal=1.0, glow=0)
txt("f_lead", "LEAD A NATION", 3.35, 800, 50, CINZEL, GOLD, 520, reveal=1.2, glow=0.3)
txt("f_plat", "Windows  \u00b7  macOS", 4.35, 958, 34, CORM, CREAM, 300, reveal=1.0, glow=0, rise=8)
finale = {"width": W, "height": H, "fps": FPS, "duration": D, "comps": {"c_glint": glint}, "layers": fin_layers}
save("finale.json", finale)
print("ok")
