"""Act 3, "Every decision is yours": the game's UI as dimensional cards in 3D space (strata scene generator).
   python -I act3_scene.py  ->  C:/civ/trailer_v6/src/strata/act3.json   (16 s, 1920x1080, 24 fps)
Beat grid: the score's downbeats fall on whole seconds; bars every 4 s. Segments cut on the bars:
  A 0-4   the exploded HUD; the NOW button is clicked          "EVERY DECISION"
  B 4-8   the Cabinet Decision card opens and explodes into its options; callouts
  C 8-12  diplomacy: painted leader portraits on an arc, camera orbit
  D 12-16 cabinet + treasury + vs-history cards, then a fly-through   "IS YOURS"
"""
import json, math

W, H, FPS, DUR = 1920, 1080, 24, 16.0
FOV = 40.0
F = (H / 2) / math.tan(math.radians(FOV / 2))  # 1483.6: a z=0 plane at native size
CX, CY = W / 2, H / 2
GOLD, GOLD_HI, CREAM, NAVY = "#E8C878", "#FFE3A0", "#EFE3C6", "#0A1428"
CINZEL, CINZEL_B, CORM = "./Cinzel-SemiBold.ttf", "./Cinzel-ExtraBold.ttf", "./Cormorant-SemiBold.ttf"
P = "C:/civ/game/assets/images/portraits/"
layers, comps = [], {}


def place(sx, sy, z, sw, aspect, camz=-F):
    """Box for a layer that should appear centred at screen (sx,sy), sw px wide, at depth z, seen from the rest camera."""
    s = F / (z - camz)
    w = sw / s
    h = w / aspect
    x = CX + (sx - CX) / s
    y = CY + (sy - CY) / s
    return [round(x - w / 2, 1), round(y - h / 2, 1), round(w, 1), round(h, 1)], [round(x, 1), round(y, 1)]


def card_comp(name, src, iw, ih, sweep_t=None, sweep_dur=0.9, glow=True):
    """A sub-comp holding the UI image plus a soft light sweep that crosses it once (clipped to the card)."""
    ls = [{"type": "image", "name": f"{name}_img", "src": src, "box": [0, 0, iw, ih]}]
    if sweep_t is not None:
        bw = max(iw, ih) * 0.22
        ls.append({"type": "solid", "name": f"{name}_sweep", "color": "#FFF1CC", "box": [-bw, -ih, bw, ih * 3],
                   "opacity": 0.32, "blend": "add", "anchor": [-bw / 2, ih / 2], "rotation": 18,
                   "mask": {"rect": [-bw, -ih, bw, ih * 3], "feather": bw * 0.45},
                   "animate": {"position": [{"t": sweep_t, "v": [-bw, ih / 2], "ease": "inOutSine"},
                                            {"t": sweep_t + sweep_dur, "v": [iw + bw * 1.5, ih / 2]}]}})
    comps[name] = {"width": iw, "height": ih, "duration": DUR, "layers": ls}


def card3d(name, comp, iw, ih, sx, sy, z, sw, t0, t1, fade_in=0.35, anim=None, shadow=True, edge=False, rot=None,
           pivot=None, opacity=1.0, extra_fx=None, blur=0):
    box, anc = place(sx, sy, z, sw, iw / ih)
    lay = {"type": "comp", "name": name, "comp": comp, "box": box, "is_3d": True, "start": t0, "duration": t1 - t0,
           "anchor": pivot or anc, "position": [*(pivot or anc), z]}
    fx = []
    if shadow:
        fx.append({"type": "shadow", "color": "#000000", "opacity": 0.65, "angle": 110, "distance": 26, "size": 40})
    if edge:
        fx.append({"type": "glow", "color": "#E8C878", "opacity": 0.28, "spread": 0, "size": 14, "range": 0.5})
    if blur:
        fx.insert(0, {"type": "blur", "amount": blur, "dimensions": "both", "repeat_edge": False})
    if extra_fx:
        fx += extra_fx
    lay["effects"] = fx
    a = dict(anim or {})
    if fade_in:
        a.setdefault("opacity", [{"t": 0, "v": 0, "ease": "outCubic"}, {"t": fade_in, "v": opacity}])
    elif opacity < 1:
        lay["opacity"] = opacity
    if rot is not None:
        lay["rotation"] = rot
    if a:
        lay["animate"] = a
    layers.append(lay)
    return lay


def bg(name, t0, t1, z=2600, dim=1.0):
    s = F / (z + F)
    w, h = W / s * 1.15, H / s * 1.15
    layers.append({"type": "image", "name": name, "src": "./ui/bg_map.png", "box": [CX - w / 2, CY - h / 2, w, h],
                   "is_3d": True, "position": [0, 0, z], "start": t0, "duration": t1 - t0, "opacity": dim,
                   "motion_blur": False})


def text(name, s, t0, t1, y, size, font=CINZEL, color=GOLD, tracking=160, x=0, w=W, reveal=0.9, glow=0.35,
         align="center middle", out=0.35, shadow=True, rise=28):
    lay = {"type": "text", "name": name, "text": s, "font": font, "size": size, "color": color,
           "box": [x, y - size, w, size * 2], "align": align, "tracking": tracking, "start": t0, "duration": t1 - t0,
           "animators": [{"opacity": 0, "position": [0, rise, 0],
                          "ranges": [{"based_on": "characters", "shape": "ramp_up", "start": 0, "end": 0.5,
                                      "animate": {"offset": [{"t": 0, "v": -0.5}, {"t": reveal, "v": 1}]}}]}]}
    fx = []
    if shadow:
        fx.append({"type": "shadow", "color": "#000000", "opacity": 0.8, "angle": 90, "distance": 3, "size": 18})
    if glow:
        fx.append({"type": "glow", "color": GOLD_HI, "opacity": glow, "spread": 0, "size": 22, "range": 0.6})
    lay["effects"] = fx
    if out:
        d = t1 - t0
        lay["animate"] = {"opacity": [{"t": d - out, "v": 1, "ease": "inCubic"}, {"t": d, "v": 0}]}
    layers.append(lay)
    return lay


def vignette(name, t0, t1, strength=0.75):
    layers.append({"type": "solid", "name": name, "color": "#02050C", "box": [0, 0, W, H], "start": t0,
                   "duration": t1 - t0, "opacity": strength,
                   "mask": {"ellipse": [CX, CY, W * 0.62, H * 0.66], "feather": 420, "inverted": True}})


def band(name, t0, t1, y, h, op=0.55):
    """A soft dark band behind type."""
    layers.append({"type": "solid", "name": name, "color": "#03060E", "box": [0, y - h / 2, W, h], "start": t0,
                   "duration": t1 - t0, "opacity": op,
                   "mask": {"rect": [-200, y - h / 2, W + 400, h], "feather": h * 0.45},
                   "animate": {"opacity": [{"t": 0, "v": 0}, {"t": 0.4, "v": op}]}})


# ---------------------------------------------------------------- A: the exploded HUD, 0-4
bg("bgA", 0, 4)
card_comp("c_topbar", "./ui/topbar.png", 1920, 56, sweep_t=0.6, sweep_dur=1.4)
card_comp("c_research", "./ui/research.png", 346, 190, sweep_t=1.1)
card_comp("c_history", "./ui/history_box.png", 346, 170)
card_comp("c_city", "./ui/city_panel.png", 439, 289, sweep_t=1.5)
card_comp("c_minimap", "./ui/minimap.png", 282, 214)
card_comp("c_now", "./ui/btn_now.png", 284, 69, sweep_t=1.9, sweep_dur=0.7)
drift = lambda dz: {"position": None}
card3d("A_topbar", "c_topbar", 1920, 56, 960, 110, 520, 1760, 0, 4, blur=3, fade_in=0.0)
card3d("A_research", "c_research", 346, 190, 250, 330, 300, 470, 0.1, 4, blur=2)
card3d("A_history", "c_history", 346, 170, 230, 610, 560, 420, 0.2, 4, opacity=0.8, blur=4)
card3d("A_city", "c_city", 439, 289, 380, 850, 120, 600, 0.0, 4, blur=1, fade_in=0.0)
card3d("A_minimap", "c_minimap", 282, 214, 1680, 360, 420, 400, 0.25, 4, blur=3)
now = card3d("A_now", "c_now", 284, 69, 1440, 820, -200, 640, 0.3, 4,
             extra_fx=[{"type": "glow", "color": "#FFC860", "opacity": 0.6, "spread": 0, "size": 40, "range": 0.6}])
# the click: the button dips and a gold ring expands from it at 3.0 s
nb = now["box"]
now["animate"]["scale"] = [{"t": 2.6, "v": 1.0, "ease": "outQuad"}, {"t": 2.72, "v": 0.94, "ease": "outBack"},
                           {"t": 3.0, "v": 1.0}]
layers.append({"type": "solid", "name": "A_ring", "color": GOLD_HI, "box": [0, 0, W, H], "start": 2.72, "duration": 0.9,
               "blend": "add", "anchor": [1440, 820],
               "mask": {"shapes": [{"ellipse": [1440, 820, 330, 92], "blend": "add", "feather": 6},
                                   {"ellipse": [1440, 820, 322, 86], "blend": "subtract", "feather": 6}]},
               "animate": {"opacity": [{"t": 0, "v": 0.95, "ease": "outQuad"}, {"t": 0.85, "v": 0}],
                           "scale": [{"t": 0, "v": 1.0, "ease": "outCubic"}, {"t": 0.85, "v": 1.9}]}})
vignette("A_vig", 0, 4, 0.55)
text("A_t1", "EVERY DECISION", 0.5, 4.0, 500, 100, font=CINZEL, tracking=200, reveal=1.4, out=0.25)
text("A_t2", "ONE AT A TIME", 1.5, 4.0, 615, 32, font=CORM, color=CREAM, tracking=700, reveal=1.5, glow=0, out=0.25,
     rise=12)

# ---------------------------------------------------------------- B: the Cabinet Decision card, 4-8
bg("bgB", 4, 8)
card_comp("c_head", "./ui/card_cab_head.png", 916, 226, sweep_t=4.6, sweep_dur=1.0)
card_comp("c_opt1", "./ui/card_cab_opt1.png", 890, 170, sweep_t=5.6, sweep_dur=0.8)
card_comp("c_opt2", "./ui/card_cab_opt2.png", 890, 170, sweep_t=6.2, sweep_dur=0.8)
piv = [900, 560]
rotk = lambda: {"rotation": [{"t": 0, "v": [4, -16, 0], "ease": "outCubic"}, {"t": 4, "v": [2, -5, 0]}]}
B_SC = 1.18
hb, _ = place(960, 330, 0, 916 * B_SC, 916 / 226)
# open: the header drops in, the two options slide out of it and lift toward the camera on the beats
card3d("B_head", "c_head", 916, 226, 900, 318, 0, 916 * B_SC, 4.0, 8, fade_in=0.0, pivot=piv,
       anim={**rotk(), "scale": [{"t": 0, "v": 0.92, "ease": "outExpo"}, {"t": 0.6, "v": 1.0}]})
for i, (nm, comp, y, z, t) in enumerate([("B_opt1", "c_opt1", 575, -110, 4.9), ("B_opt2", "c_opt2", 790, -220, 5.4)]):
    lay = card3d(nm, comp, 890, 170, 900, y, 0, 890 * B_SC, t, 8, fade_in=0.2, pivot=piv, anim=rotk())
    lay["animate"]["position"] = [{"t": 0, "v": [*piv, 0], "ease": "outExpo"}, {"t": 0.7, "v": [*piv, z]}]
    # rotation keys are relative to the layer start: shift so all three cards stay in one rigid plane
    off = t - 4.0
    lay["animate"]["rotation"] = [{"t": 0, "v": [4 - 2 * off / 4, -16 + 11 * off / 4, 0], "ease": "outCubic"},
                                  {"t": 8 - t, "v": [2, -5, 0]}]
# callouts: a gold tag for history's choice, a cream one for the other road
for nm, label, y, col, t in [("B_call1", "HISTORY CHOSE THIS", 590, GOLD, 5.9), ("B_call2", "YOUR CALL", 812, CREAM, 6.5)]:
    layers.append({"type": "solid", "name": nm + "_line", "color": col, "box": [0, 0, W, H], "start": t,
                   "duration": 8 - t,
                   "mask": {"path": f"M1446 {y} L1516 {y}", "stroke": 2,
                            "trim": {"end": [{"t": 0, "v": 0, "ease": "outCubic"}, {"t": 0.35, "v": 1}]}}})
    text(nm, label, t + 0.15, 8, y, 24, font=CINZEL, color=col, tracking=170, x=1530, w=380, align="left middle",
         reveal=0.9, glow=0.25, out=0.2, rise=10)
vignette("B_vig", 4, 8, 0.5)
text("B_t1", "REAL DILEMMAS FROM THE RECORD", 4.3, 8, 112, 44, font=CINZEL, tracking=320, reveal=1.0, out=0.25,
     glow=0.25)

# ---------------------------------------------------------------- C: 8-12 is covered in the edit by the full-frame
# diplomacy burst of Israeli and US leaders (edit.py BURST); the scene keeps only its backdrop here, so no other
# country's leader portrait exists anywhere in the render.
bg("bgC", 8, 12, dim=0.9)
OC = (960.0, 560.0, 520.0)   # (the orbit centre the camera path still uses)
if False:
    bg("bgC", 8, 12, dim=0.9)
    card_comp("c_diplo", "./ui/card_diplo.png", 1322, 790)
    card3d("C_diplo", "c_diplo", 1322, 790, 960, 560, 1300, 1500, 8, 12, opacity=0.55, edge=False, fade_in=0.0)
    leaders = [("us_truman", "HARRY S. TRUMAN", "UNITED STATES"), ("de_adenauer", "KONRAD ADENAUER", "WEST GERMANY"),
               ("fr_degaulle", "CHARLES DE GAULLE", "FRANCE"), ("eg_sadat", "ANWAR SADAT", "EGYPT"),
               ("jo_hussein", "KING HUSSEIN", "JORDAN"), ("un_hammarskjold", "DAG HAMMARSKJ\u00d6LD", "UNITED NATIONS")]
    # an arc around the orbit centre (960, 540, 500)
    OC = (960.0, 560.0, 520.0)
    for i, (pid, nm, ctry) in enumerate(leaders):
        ang = math.radians(-50 + i * 20)
        R = 760
        x = OC[0] + R * math.sin(ang)
        z = OC[2] - R * math.cos(ang) + 380
        cw, chh = 300, 380
        comp = f"c_p{i}"
        comps[comp] = {"width": cw, "height": chh + 70, "duration": DUR, "layers": [
            {"type": "solid", "name": f"p{i}_bg", "color": "#0B1630", "box": [0, 0, cw, chh + 70]},
            {"type": "image", "name": f"p{i}_img", "src": P + pid + ".png", "box": [0, 0, cw, chh], "fit": "fill"},
            {"type": "solid", "name": f"p{i}_rule", "color": GOLD, "box": [0, chh, cw, 2]},
            {"type": "text", "name": f"p{i}_nm", "text": nm, "font": CINZEL, "size": 19, "color": GOLD,
             "box": [0, chh + 8, cw, 30], "align": "center middle", "tracking": 120},
            {"type": "text", "name": f"p{i}_ct", "text": ctry, "font": CORM, "size": 17, "color": CREAM,
             "box": [0, chh + 36, cw, 26], "align": "center middle", "tracking": 300}]}
        t0 = 8.0 + 0.12 * i
        lay = {"type": "comp", "name": f"C_p{i}", "comp": comp, "box": [x - cw / 2, OC[1] - (chh + 70) / 2, cw, chh + 70],
               "is_3d": True, "anchor": [x, OC[1]], "position": [x, OC[1], z], "rotation": [0, math.degrees(ang), 0],
               "start": t0, "duration": 12 - t0,
               "effects": [{"type": "shadow", "color": "#000000", "opacity": 0.7, "angle": 110, "distance": 20, "size": 34},
                           {"type": "stroke", "color": GOLD, "size": 2, "position": "inside"}],
               "animate": {"opacity": [{"t": 0, "v": 0, "ease": "outCubic"}, {"t": 0.4, "v": 1}],
                           "position": [{"t": 0, "v": [x, OC[1] + 60, z], "ease": "outExpo"}, {"t": 0.9, "v": [x, OC[1], z]}]}}
        layers.append(lay)
    vignette("C_vig", 8, 12, 0.5)
    text("C_t1", "DIPLOMACY WITH 26 PARTNERS", 8.8, 12, 925, 50, font=CINZEL, tracking=300, reveal=1.0, out=0.25)
    text("C_t2", "FROM TRUMAN TO THE ABRAHAM ACCORDS", 9.6, 12, 990, 26, font=CORM, color=CREAM, tracking=420, reveal=1.6,
         glow=0, out=0.25, rise=10)

# ---------------------------------------------------------------- D: cabinet, treasury, the record, 12-16
bg("bgD", 12, 16)
card_comp("c_min", "./ui/card_ministers.png", 1238, 740, sweep_t=12.5, sweep_dur=1.1)
card_comp("c_bud", "./ui/card_budget.png", 1242, 744, sweep_t=12.2, sweep_dur=1.1)
card_comp("c_sl", "./ui/budget_sliders.png", 1212, 131, sweep_t=13.0, sweep_dur=0.8)
card_comp("c_vs", "./ui/vs_charts.png", 716, 430, sweep_t=13.4, sweep_dur=0.8)
card3d("D_min", "c_min", 1238, 740, 1330, 430, 700, 980, 12, 16, rot=[0, 14, 0], opacity=0.9, fade_in=0.0)
card3d("D_bud", "c_bud", 1242, 744, 640, 520, 260, 1000, 12.0, 16, rot=[0, -12, 0], fade_in=0.0)
card3d("D_sl", "c_sl", 1212, 131, 640, 820, -260, 900, 12.4, 16, rot=[0, -12, 0])
card3d("D_vs", "c_vs", 716, 430, 1450, 760, -380, 640, 12.6, 16, rot=[0, 10, 0])
vignette("D_vig", 12, 16, 0.45)
text("D_t1", "IS YOURS", 13.0, 16, 530, 150, font=CINZEL_B, tracking=260, reveal=1.3, out=0.0, glow=0.5)

# ---------------------------------------------------------------- the camera
cam = []
F0 = -F


def k(t, x, y, z, ry=0.0, rx=0.0, ease="inOutSine"):
    cam.append({"t": round(t, 3), "pos": [round(x, 1), round(y, 1), round(z, 1)], "rot": [rx, ry, 0], "ease": ease})


# A: slow dolly in and drift right; B: truck left-to-right; C: orbit around the arc; D: push and fly through
for i in range(17):
    u = i / 16
    k(4 * u * 0.999, 880 + 160 * u, 560 - 30 * u, F0 - 160 + 300 * u, ry=-2 + 4 * u, ease="linear")
for i in range(17):
    u = i / 16
    k(4 + 4 * u * 0.999, 800 + 260 * u, 560 - 30 * u, F0 - 200 + 300 * u, ry=-3 + 5 * u, ease="linear")
for i in range(25):
    u = i / 24
    th = math.radians(-14 + 28 * (u - 0.5 * math.sin(math.pi * u) * 0) )
    R = (OC[2] - F0) + 60 - 120 * u
    k(8 + 4 * u * 0.999, OC[0] - R * math.sin(th), 540, OC[2] - R * math.cos(th), ry=math.degrees(th), ease="linear")
for i in range(25):
    u = i / 24
    e = u * u * u  # accelerate into the fly-through
    k(12 + 4 * u * 0.999, 940 + 60 * u, 540, F0 - 200 + 260 * u + 1700 * e, ease="linear")
pos_keys, rot_keys = [], []
for j, c in enumerate(cam):
    hold = j + 1 < len(cam) and int(cam[j + 1]["t"]) in (4, 8, 12) and cam[j + 1]["t"] == int(cam[j + 1]["t"])
    pos_keys.append({"t": c["t"], "v": c["pos"], **({"ease": "hold"} if hold else {})})
    rot_keys.append({"t": c["t"], "v": c["rot"], **({"ease": "hold"} if hold else {})})
layers.append({"type": "camera", "name": "cam", "fov": FOV, "position": cam[0]["pos"], "motion_blur": True,
               "animate": {"position": pos_keys, "rotation": rot_keys}})
# the camera must sit on top of the list? keep it last; base fill first
layers.insert(0, {"type": "solid", "name": "base", "color": "#050A16", "box": [0, 0, W, H]})
scene = {"width": W, "height": H, "fps": FPS, "duration": DUR, "comps": comps, "layers": layers}
json.dump(scene, open("C:/civ/trailer_v6/src/strata/act3.json", "w", encoding="utf-8"), indent=1, ensure_ascii=False)
print("layers", len(layers), "comps", len(comps))
