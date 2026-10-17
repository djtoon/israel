"""Crop the game's UI panels into card PNGs for the Act 3 strata scenes, plus backgrounds."""
from PIL import Image, ImageFilter, ImageEnhance
A = "C:/civ/dev_update/video/assets/"
U = "C:/civ/trailer_v6/src/strata/ui/"
crops = {
    "card_cabinet": ("06_cabinet_decision_palmach.png", (502, 252, 1418, 830)),
    "card_cab_head": ("06_cabinet_decision_palmach.png", (502, 252, 1418, 478)),
    "card_cab_opt1": ("06_cabinet_decision_palmach.png", (515, 478, 1405, 648)),
    "card_cab_opt2": ("06_cabinet_decision_palmach.png", (515, 652, 1405, 822)),
    "btn_now": ("06_cabinet_decision_palmach.png", (1630, 983, 1914, 1052)),
    "topbar": ("06_cabinet_decision_palmach.png", (0, 0, 1920, 56)),
    "city_panel": ("06_cabinet_decision_palmach.png", (10, 758, 449, 1047)),
    "research": ("06_cabinet_decision_palmach.png", (10, 70, 356, 260)),
    "history_box": ("06_cabinet_decision_palmach.png", (10, 318, 356, 488)),
    "minimap": ("06_cabinet_decision_palmach.png", (1630, 768, 1912, 982)),
    "card_budget": ("05_state_budget.png", (340, 168, 1582, 912)),
    "budget_sliders": ("05_state_budget.png", (354, 703, 1566, 834)),
    "card_diplo": ("02_diplomacy_truman.png", (176, 74, 1498, 864)),
    "diplo_list": ("02_diplomacy_truman.png", (188, 182, 450, 840)),
    "card_vs_history": ("12_end_screen_vs_history.png", None),
    "card_fronts": ("04_war_fronts_yom_kippur.png", None),
    "card_ministers": ("../../../trailer_shots/ui/ui10_ministers.png", None),
}
for name, (src, box) in crops.items():
    im = Image.open(A + src).convert("RGB")
    if box: im = im.crop(box)
    im.save(U + name + ".png"); print(name, im.size)
# background: the 1948 map, blurred and pushed into navy
bg = Image.open("C:/civ/trailer_shots/02_1948_jerusalem_oldcity.png").convert("RGB").resize((2400, 1350))
bg = bg.filter(ImageFilter.GaussianBlur(10)); bg = ImageEnhance.Brightness(bg).enhance(0.35)
navy = Image.new("RGB", bg.size, (8, 16, 36)); bg = Image.blend(bg, navy, 0.55); bg.save(U + "bg_map.png")
