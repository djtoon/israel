"""Normalise every raw GLB into assets/models/<cat>/ and (re)write assets/MANIFEST.json.

  python build.py            # normalise all raw GLBs that exist, write manifest
  python build.py --only id  # just these ids (repeatable)
"""
import json, os, subprocess, sys
import assets as A

HERE = os.path.dirname(os.path.abspath(__file__))
ASSETS = os.path.dirname(HERE)

# Scale convention: 1.0 world unit = one hex flat-to-flat. (kind, size, measure)
SIZE = {
    "nat_date_palm": (0.42, "height"), "nat_olive_tree": (0.26, "height"), "nat_aleppo_pine": (0.36, "height"),
    "nat_cypress": (0.40, "height"), "nat_rock_outcrop": (0.30, "extent"),
    "unit_palmach_infantry": (0.30, "height"), "unit_settler_group": (0.30, "height"),
    "unit_worker_builder": (0.30, "height"), "unit_archaeologist": (0.30, "height"),
    "unit_sherman_m50": (0.48, "extent"), "unit_merkava": (0.52, "extent"), "unit_trader_truck": (0.45, "extent"),
    "unit_iron_dome": (0.45, "extent"), "unit_jet_mirage": (0.55, "extent"), "unit_jet_f16": (0.55, "extent"),
    "unit_saar_missile_boat": (0.62, "extent"),
}
# Approximate real-world size in metres (w = longest horizontal, d = other horizontal, h = height).
REAL_M = {
    "unit_palmach_infantry": (0.6, 0.5, 1.8), "unit_settler_group": (3.0, 1.5, 1.8), "unit_worker_builder": (1.8, 0.8, 1.8),
    "unit_archaeologist": (0.8, 0.5, 1.8), "unit_sherman_m50": (7.4, 2.6, 2.7), "unit_merkava": (9.0, 3.7, 2.7),
    "unit_jet_mirage": (15.0, 8.2, 4.5), "unit_jet_f16": (15.0, 10.0, 5.1), "unit_saar_missile_boat": (58.0, 7.6, 18.0),
    "unit_iron_dome": (8.0, 2.6, 3.5), "unit_trader_truck": (6.5, 2.3, 2.8),
    "nat_date_palm": (6.0, 6.0, 15.0), "nat_olive_tree": (7.0, 7.0, 6.0), "nat_aleppo_pine": (9.0, 9.0, 15.0),
    "nat_cypress": (2.5, 2.5, 15.0), "nat_rock_outcrop": (4.0, 3.0, 2.0),
}
# Wide, low structures: scale these by their real length rather than height (footprint matters more for layout).
BY_EXTENT = {"lm_knesset_nb", "lm_desalination_nb", "lm_airport_terminal_nb", "bld_shikun_block", "bld_kibbutz_dining_hall", "lm_azrieli_towers_nb", "lm_dome_of_the_rock_nb"}
# modular segments whose long side must lie along X so they tile in rows
LONG_X = {"hb_quay_straight", "hb_wooden_pier", "hb_breakwater", "jer_wall_straight", "hp_container_stack",
          "market_arcade", "bld_white_block_5070", "hp_refinery_tanks"}
PREVIEW_TERRAIN = {
    "city_haifa_port": "terrain_plains", "lm_sorek_desalination": "terrain_beach_sand",
    "imp_gas_platform": "terrain_beach_sand", "lm_nuclear_research": "terrain_desert_sand",
    "imp_solar_field": "terrain_desert_rock", "imp_phosphate_mine": "terrain_desert_rock",
    "city_kibbutz": "terrain_grassland", "imp_citrus_grove": "terrain_grassland", "imp_fish_ponds": "terrain_grassland",
    "city_jerusalem_stone": "terrain_hills_limestone", "lm_dome_of_the_rock": "terrain_hills_limestone",
    "lm_knesset": "terrain_hills_limestone", "imp_olive_grove": "terrain_hills_limestone",
    "lm_bahai_gardens": "terrain_hills_limestone",
}


def generators():
    g = {}
    p = os.path.join(HERE, "genlog.jsonl")
    for line in open(p, encoding="utf-8") if os.path.exists(p) else []:
        try:
            r = json.loads(line.replace(chr(0), "").strip() or "{}")
        except ValueError:
            continue
        if r.get("kind") == "model" and r.get("ok"):
            g[os.path.basename(r["out"])[:-4]] = r.get("generator", "tencent/hunyuan-3d-3.1")
    return g


def main():
    only = [sys.argv[i + 1] for i, a in enumerate(sys.argv) if a == "--only"]
    old = {}
    mp = os.path.join(ASSETS, "MANIFEST.json")
    if os.path.exists(mp):
        old = {e["id"]: e for e in json.load(open(mp, encoding="utf-8"))["assets"]}
    gens = generators()
    out = []
    groups = [("city", "tile", A.CITY), ("landmark", "tile", A.LANDMARK), ("improvement", "tile", A.IMPROVEMENT)]
    for cat, kind, rows in groups:
        for i, subj, ground, e0, e1 in rows:
            out.append(dict(id=i, kind=cat, file=f"models/{cat}/{i}.glb", source_image=f"model_src/{i}.png",
                            era={"from": e0, "to": e1}, footprint="1 hex (pointy-top hexagonal base slab)",
                            suggested_scale=1.0, _norm=("tile", 1.0, "extent"), desc=subj))
    for i, subj in A.NATURE:
        s = SIZE[i]
        out.append(dict(id=i, kind="nature", file=f"models/nature/{i}.glb", source_image=f"model_src/{i}.png",
                        era={"from": 1948, "to": 2026}, footprint=f"prop, {s[0]} hex {s[1]}",
                        suggested_scale=1.0, _norm=("prop", *s), desc=subj))
    for i, subj, e0, e1 in A.UNIT:
        s = SIZE[i]
        out.append(dict(id=i, kind="unit", file=f"models/unit/{i}.glb", source_image=f"model_src/{i}.png",
                        era={"from": e0, "to": e1}, footprint=f"unit, {s[0]} hex {s[1]}",
                        suggested_scale=1.0, _norm=("unit", *s), desc=subj))
    for i, subj, e0, e1, real in A.BUILDING:
        cat = "landmark" if i.startswith("lm_") else "building"
        out.append(dict(id=i, kind=cat, file=f"models/{cat}/{i}.glb", source_image=f"model_src/{i}.png",
                        era={"from": e0, "to": e1}, scale_units="m",
                        footprint=f"single structure, no base, real scale ({real[0]} x {real[1]} m, {real[2]} m tall)",
                        real_m={"w": real[0], "d": real[1], "h": real[2]},
                        suggested_scale=1.0, desc=subj,
                        _norm=("prop", float(real[0]), "mean", float(real[2])) if i in BY_EXTENT else ("prop", float(real[2]), "height")))
    for i, kind, tpl, subj, e0, e1, real, meas in A.R2:
        norm = {"h": ("prop", float(real[2]), "height"), "w": ("prop", float(real[0]), "extent"),
                "mean": ("prop", float(real[0]), "mean", float(real[2]))}[meas]
        out.append(dict(id=i, kind=kind, file=f"models/{kind}/{i}.glb", source_image=f"model_src/{i}.png",
                        era={"from": e0, "to": e1}, scale_units="m", real_m={"w": real[0], "d": real[1], "h": real[2]},
                        footprint="no base, real scale", suggested_scale=1.0, desc=subj, _norm=norm,
                        _face="none" if kind == "vegetation" else ("boxx" if i in LONG_X else "box")))
    for i, subj, e0, e1, real, meas, flat in A.R3:
        norm = {"h": ("prop", float(real[2]), "height"), "w": ("prop", float(real[0]), "extent"),
                "mean": ("prop", float(real[0]), "mean", float(real[2]))}[meas]
        out.append(dict(id=i, kind="building", file=f"models/building/{i}.glb", source_image=f"model_src/{i}.png",
                        era={"from": e0, "to": e1}, scale_units="m", real_m={"w": real[0], "d": real[1], "h": real[2]},
                        footprint="no base, real scale", suggested_scale=1.0, desc=subj, _norm=norm, _face="boxx",
                        _fit3=real, roof="flat with rooftop clutter" if flat else "pitched/domed"))
    for e in out:
        e.setdefault("scale_units", "hex")
        if e["id"] in REAL_M:
            w, d, h = REAL_M[e["id"]]
            e["real_m"] = {"w": w, "d": d, "h": h}
        elif "real_m" not in e:
            e["real_m"] = None  # hex diorama, not to real scale
        e["preview_terrain"] = PREVIEW_TERRAIN.get(e["id"], "terrain_plains")
        raw = os.path.join(HERE, "glb_raw", e["id"] + ".glb")
        dst = os.path.join(ASSETS, e["file"])
        e["generator"] = gens.get(e["id"])
        if os.path.exists(raw) and (not only or e["id"] in only):
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            k, size, by = e["_norm"][:3]
            cmd = [sys.executable, os.path.join(HERE, "normalize_glb.py"), raw, dst, "--kind", k, "--size", str(size), "--by", by]
            if len(e["_norm"]) > 3:
                cmd += ["--hsize", str(e["_norm"][3])]
            if e.get("scale_units") == "m":
                cmd += ["--face", e.get("_face", "box")]
            if e.get("_fit3"):
                cmd += ["--fit3"] + [str(v) for v in e["_fit3"]]
            if k == "unit":
                cmd += ["--face", "fixed" if by == "height" else "long"]
            yaw = old.get(e["id"], {}).get("yaw_fix", 0.0)
            if yaw:
                cmd += ["--yaw", str(yaw)]
            r = subprocess.run(cmd, capture_output=True, text=True)
            # Godot extracts embedded textures to <model>_N.png and never overwrites them: delete stale extracted
            # textures so the next import picks up the new GLB's texture.
            import glob as _g
            for stale in _g.glob(dst[:-4] + "_[0-9].png") + _g.glob(dst[:-4] + "_[0-9].png.import"):
                os.remove(stale)
            # ...and drop the imported stamp so Godot reimports (and re-extracts) even if the GLB bytes are unchanged
            imp = os.path.join(ASSETS, "..", ".godot", "imported")
            for stamp in _g.glob(os.path.join(imp, os.path.basename(dst) + "-*.md5")):
                os.remove(stamp)
            if r.returncode == 0:
                e["normalised"] = json.loads(r.stdout.strip().splitlines()[-1])
                if e["kind"] in ("building", "harbour", "landmark") and e.get("scale_units") == "m":
                    r2 = subprocess.run([sys.executable, os.path.join(HERE, "strip_groundcard.py"), dst, dst],
                                        capture_output=True, text=True)
                    if r2.returncode == 0:
                        e["normalised"]["groundcard_faces_removed"] = json.loads(r2.stdout.strip().splitlines()[-1])["removed"]
                r_n = subprocess.run([sys.executable, os.path.join(HERE, "add_normals.py"), dst, dst], capture_output=True, text=True)
                if r_n.returncode != 0:
                    print("WARN normals", e["id"], r_n.stderr[-300:])
                if e["kind"] in ("building", "harbour", "landmark") and e.get("scale_units") == "m":
                    r3 = subprocess.run([sys.executable, os.path.join(HERE, "relight_back.py"), dst, dst, "--lo", "70"],
                                        capture_output=True, text=True)
                    if r3.returncode == 0:
                        e["normalised"]["back_relit"] = json.loads(r3.stdout.strip().splitlines()[-1])["relit"]
                    else:
                        print("WARN relight", e["id"], r3.stderr[-200:])
            else:
                e["error"] = r.stderr.strip()[-300:]
                print("ERR", e["id"], e["error"])
        elif e["id"] in old and "normalised" in old[e["id"]]:
            e["normalised"] = old[e["id"]]["normalised"]
        if e["id"] in old:
            for keep in ("yaw_fix", "notes"):
                if keep in old[e["id"]]:
                    e[keep] = old[e["id"]][keep]
        e["status"] = "ok" if os.path.exists(dst) else "missing"
        del e["_norm"]
        e.pop("_face", None)
        e.pop("_fit3", None)
    # tiles: slab-top height (sink the model by this to hide the plinth) + plinth-free variants for city/landmark
    variants = []
    for e in list(out):
        if e["kind"] not in ("city", "landmark", "improvement") or e["status"] != "ok" or e.get("scale_units") == "m":
            continue
        dst = os.path.join(ASSETS, e["file"])
        nop = dst[:-4] + "_noplinth.glb"
        want = e["kind"] in ("city", "landmark")
        redo = (not only or e["id"] in only) or (want and not os.path.exists(nop)) or "--restrip" in sys.argv
        if redo or "ground_y" not in old.get(e["id"], {}):
            cmd = [sys.executable, os.path.join(HERE, "strip_plinth.py"), dst] + ([nop] if want else [])
            r = subprocess.run(cmd, capture_output=True, text=True)
            if r.returncode != 0:
                print("ERR strip", e["id"], r.stderr[-300:]); continue
            st = json.loads(r.stdout.strip().splitlines()[-1])
            if want and os.path.exists(nop):
                subprocess.run([sys.executable, os.path.join(HERE, "add_normals.py"), nop, nop], capture_output=True, text=True)
                import glob as _g
                for stale in _g.glob(nop[:-4] + "_[0-9].png") + _g.glob(nop[:-4] + "_[0-9].png.import") +                         _g.glob(os.path.join(ASSETS, "..", ".godot", "imported", os.path.basename(nop) + "-*.md5")):
                    os.remove(stale)
        else:
            st = {"ground_y": old[e["id"]]["ground_y"], "height": old.get(e["id"] + "_noplinth", {}).get("normalised", {}).get("height")}
        e["ground_y"] = st["ground_y"]
        if want and os.path.exists(nop):
            v = dict(e)
            v.update(id=e["id"] + "_noplinth", file=e["file"][:-4] + "_noplinth.glb", variant_of=e["id"],
                     footprint="buildings only, slab cut away (ground line y=0)", ground_y=0.0,
                     normalised={"height": st.get("height")})
            variants.append(v)
    out += variants
    for i, subj in A.TERRAIN:
        out.append(dict(id=i, kind="texture", file=f"textures/terrain/{i}.png", era={"from": 1948, "to": 2026},
                        footprint="seamless 1024x1024 top-down, depicts ~20 m", suggested_scale=0.5,
                        scale_note="suggested_scale = fraction of a hex one texture repeat spans (2 repeats per hex)",
                        desc=subj, status="ok" if os.path.exists(os.path.join(ASSETS, f"textures/terrain/{i}.png")) else "missing"))
    for grp, rows, folder in (("yield", A.ICON_YIELD, "yield"), ("action", A.ICON_ACTION, "action"), ("resource", A.PINS, "resource")):
        for i, glyph, _ in rows:
            out.append(dict(id=i, kind="icon", group=grp, file=f"icons/{folder}/{i}.png", era={"from": 1948, "to": 2026},
                            footprint="128x128 RGBA", suggested_scale=1.0, desc=glyph,
                            status="ok" if os.path.exists(os.path.join(ASSETS, f"icons/{folder}/{i}.png")) else "missing"))
    for e in out:
        if e.get("scale_units") == "m" and "normalised" in e:  # real size = the model's actual metre bounds
            b0, b1 = e["normalised"]["bounds_min"], e["normalised"]["bounds_max"]
            dims = sorted([b1[0] - b0[0], b1[2] - b0[2]], reverse=True)
            e["real_m"] = {"w": round(dims[0], 1), "d": round(dims[1], 1), "h": round(b1[1], 1)}
            e["footprint"] = f"no base, real scale ({e['real_m']['w']} x {e['real_m']['d']} m, {e['real_m']['h']} m tall)"
    man = {
        "version": 1,
        "conventions": {
            "units": "Models with scale_units 'hex' (default): 1.0 = one hex flat-to-flat; multiply by your hex width. Models with scale_units 'm' (kind building and lm_*_nb): 1.0 = one metre at real size, so one metres->world factor keeps every building consistent.",
            "real_m": "Approximate real-world size in metres (w longest horizontal, d other horizontal, h height); null for hex dioramas. Use real_m.h / normalised.height to convert any model to metres.",
            "ground_y": "Tiles only: height of the top of the hex slab in model units; sink the model by ground_y so the slab top is flush with the terrain. *_noplinth variants have the slab cut away.",
            "up": "+Y up; lowest point at y=0; footprint centred on the origin.",
            "tiles": "Tile models carry a thin pointy-top hex slab (corners on +-Z) exactly 1.0 flat-to-flat.",
            "facing": "Units/props face roughly +Z (towards a default Civ-style camera).",
            "suggested_scale": "Extra multiplier on top of the hex width (1.0 = as authored).",
            "generator": "Which image-to-3D model produced the GLB; trellis ones should be regenerated with hunyuan-3d-3.1 when it has capacity.",
            "art_direction": "See ART_DIRECTION.md",
        },
        "assets": out,
    }
    json.dump(man, open(mp, "w", encoding="utf-8"), indent=1, ensure_ascii=False)
    print("manifest:", len(out), "assets;", sum(e["status"] == "ok" for e in out), "ok")


if __name__ == "__main__":
    main()
