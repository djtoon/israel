"""Incremental mirror of the live game (game/) into the web source copy (build/web/src/game), with the web transforms.
   python -I build/web/sync_src.py
Only files whose source changed since the last sync (mtime and size, kept in build/web/cache/sync_manifest.json) are
copied; nothing is rewritten when its content is the same, so Godot re-imports only what really changed. Never touches
build/web/src/game/.godot. Files that the web build leaves out (EXCLUDE) are never copied and are removed from the
copy; files the web build adds (KEEP) are never removed. web_diet.py then applies the asset diet to the changed files."""
import fnmatch, json, os, re, shutil, sys

SRC = "C:/civ/game"
DST = "C:/civ/build/web/src/game"
MAN = "C:/civ/build/web/cache/sync_manifest.json"

# dev-only and unused files, and what the web build does not load (HD-only maps, the single ground / kit textures the
# texture arrays replace). Paths relative to the project, fnmatch patterns ("dir/" = the whole directory).
EXCLUDE_DIRS = [".godot", "tests", "assets/_pipeline", "assets/model_src", "assets/models/_cand", "scripts/ui/tests"]
EXCLUDE = ["scenes/art_preview.tscn", "scripts/art/art_preview.gd*", "scripts/map/_preview_models.gd*",
           "assets/images/test_bauhaus.png*", "assets/models/test_bauhaus.glb*",
           "assets/models/vegetation/veg_*.glb*", "assets/models/vegetation/veg_*_0.png*",
           "assets/brand/icon_candidate_*", "game.cfg",
           "assets/textures/hd/*_nrm.png*", "assets/textures/hd/water_ripple_n.png*", "assets/textures/hd/hdp_caustics.png*",
           "assets/textures/terrain/terrain_*.png*", "assets/kit/kit_*.png*",
           "assets/intro/*.ogv", "assets/intro/*.ogv.uid",   # (the web build plays WebM files beside index.html)
           "*.md", "*.py", "*.jsonl", "*.log"]
# made by the web build itself (never removed by the sync)
# web-only files from build/web (not in game/): destination -> source
EXTRA = {"scripts/web_bench.gd": "C:/civ/build/web/tools/web_bench.gd"}
KEEP = ["export_presets.cfg", "scripts/web_bench.gd*", "assets/models/web_far/*", "assets/models/web_mid/*", "web_shell/*", "*.uid", "assets/intro/menu_still.jpg*", "assets/textures/terrain/web_terrain_array.png*", "assets/kit/web_kit_*"]


def excluded(rel):
    for d in EXCLUDE_DIRS:
        if rel == d or rel.startswith(d + "/"):
            return True
    name = rel.rsplit("/", 1)[-1]
    for pat in EXCLUDE:
        if "/" in pat:
            if fnmatch.fnmatch(rel, pat):
                return True
        elif fnmatch.fnmatch(name, pat):
            return True
    return False


def kept(rel):
    # (*.uid: Godot writes one beside a new script in the copy; keeping it avoids re-generating it on every sync)
    return any(fnmatch.fnmatch(rel, p) for p in KEEP)


def t_project(s):
    """the web project settings: Compatibility renderer, name, version, save folder, windowed canvas, desktop VRAM
    formats only, and the web marker israel/web_look (shared code checks OS.has_feature("web") or this setting)"""
    s = re.sub(r'^config/name=.*$', 'config/name="Israel"\nconfig/version="1.0"', s, count=1, flags=re.M)
    s = re.sub(r'^config/version=.*\n(?=config/version)', '', s, flags=re.M)
    s = re.sub(r'^config/custom_user_dir_name=.*$', 'config/custom_user_dir_name="IsraelBirthOfANation"', s, flags=re.M)
    s = s.replace('"Forward Plus"', '"GL Compatibility"')
    # windowed canvas; per-pixel transparency lets the menu loop's WebM play behind the canvas (scripts/ui/web_video.gd)
    s = re.sub(r'^window/size/mode=.*$', 'window/size/mode=0\nwindow/per_pixel_transparency/allowed=true\nwindow/dpi/allow_hidpi=true', s, flags=re.M)
    # (allow_hidpi on, but the page's shell sets the pixel ratio Godot sees: 1.0, or 0.75 on "Web, lighter" (ibnSetScale))
    s = re.sub(r'^demo_last_turn=.*\n?', '', s, flags=re.M)
    s = re.sub(r'^anti_aliasing/quality/msaa_3d=.*\n?', '', s, flags=re.M)
    web = ('renderer/rendering_method="gl_compatibility"\nrenderer/rendering_method.mobile="gl_compatibility"\n'
           'renderer/rendering_method.web="gl_compatibility"\n'
           'textures/vram_compression/import_s3tc_bptc=true\ntextures/vram_compression/import_etc2_astc=false\n'
           'anti_aliasing/quality/msaa_3d=0\n'
           'environment/defaults/default_clear_color=Color(0, 0, 0, 1)\n')
    s = re.sub(r'(\[rendering\]\n)', lambda m: m.group(1) + '\n' + web, s, count=1)
    # the web build's measurement autoload (inert without --web-bench; build/web/tools/web_bench.gd)
    if 'WebBench=' not in s:
        s = re.sub(r'(\[autoload\]\n+)', lambda m: m.group(1) + 'WebBench="*res://scripts/web_bench.gd"\n', s, count=1)
    if '[israel]' not in s:
        s = s.rstrip('\n') + '\n\n[israel]\n\nweb_look=true\n'
    return s


def t_shader(s):
    """the WEB_LOOK shader variants (texture arrays, no HD maps, uniform loop counts: WebGL 2 / ANGLE)"""
    lines = s.split("\n")
    if lines and lines[0].startswith("shader_type") and (len(lines) < 2 or lines[1] != "#define WEB_LOOK"):
        lines.insert(1, "#define WEB_LOOK")
    return "\n".join(lines)


TRANSFORMS = [("project.godot", t_project), ("scripts/map/*.gdshader", t_shader)]


def main():
    man = json.load(open(MAN, encoding="utf-8")) if os.path.exists(MAN) else {}
    boot = os.path.getmtime("C:/civ/build/web/refresh.log") - 120 if not man and os.path.exists("C:/civ/build/web/refresh.log") else 0
    new_man = {}
    copied, transformed, removed, same = [], [], [], 0
    src_set = set()
    for dp, dn, fn in os.walk(SRC):
        rd = os.path.relpath(dp, SRC).replace(os.sep, "/")
        rd = "" if rd == "." else rd
        dn[:] = [d for d in dn if not excluded((rd + "/" + d).lstrip("/"))]
        for f in fn:
            rel = (rd + "/" + f).lstrip("/")
            if excluded(rel):
                continue
            src_set.add(rel)
            sp = os.path.join(SRC, rel)
            dp_ = os.path.join(DST, rel)
            st = os.stat(sp)
            sig = [st.st_mtime_ns, st.st_size]
            new_man[rel] = sig
            tf = next((fnc for pat, fnc in TRANSFORMS if fnmatch.fnmatch(rel, pat)), None)
            if tf:
                out = tf(open(sp, encoding="utf-8").read())
                cur = open(dp_, encoding="utf-8").read() if os.path.exists(dp_) else None
                if cur != out:
                    os.makedirs(os.path.dirname(dp_), exist_ok=True)
                    open(dp_, "w", encoding="utf-8", newline="\n").write(out)
                    transformed.append(rel)
                continue
            # (a copy edited by hand gets the source back: a size check on the files the diet never rewrites)
            diet_owned = rel.endswith((".import", ".glb", ".ogg", ".mp3", ".ogv", ".jpg"))
            if man.get(rel) == sig and os.path.exists(dp_) and (diet_owned or os.path.getsize(dp_) == st.st_size):
                same += 1
                continue
            if not man and boot and os.path.exists(dp_) and st.st_mtime < boot:
                same += 1   # (first incremental sync: the copy made by the last full refresh is current for older files)
                continue
            # changed (or new) source: copy unless the copy already has the same bytes
            if os.path.exists(dp_) and os.path.getsize(dp_) == st.st_size:
                with open(sp, "rb") as a, open(dp_, "rb") as b:
                    if a.read() == b.read():
                        same += 1
                        continue
            os.makedirs(os.path.dirname(dp_), exist_ok=True)
            shutil.copy2(sp, dp_)
            copied.append(rel)
    for rel, sp in EXTRA.items():
        dp_ = os.path.join(DST, rel)
        if not (os.path.exists(dp_) and open(dp_, "rb").read() == open(sp, "rb").read()):
            os.makedirs(os.path.dirname(dp_), exist_ok=True)
            shutil.copyfile(sp, dp_)
            copied.append(rel)
    # remove what the source no longer has (or the web build leaves out), never .godot or the web build's own files
    for dp, dn, fn in os.walk(DST):
        rd = os.path.relpath(dp, DST).replace(os.sep, "/")
        rd = "" if rd == "." else rd
        dn[:] = [d for d in dn if d != ".godot"]
        for f in fn:
            rel = (rd + "/" + f).lstrip("/")
            if rel in src_set or kept(rel):
                continue
            os.remove(os.path.join(DST, rel))
            removed.append(rel)
    os.makedirs(os.path.dirname(MAN), exist_ok=True)
    json.dump(new_man, open(MAN, "w", encoding="utf-8"))
    json.dump({"copied": copied, "transformed": transformed, "removed": removed},
              open(os.path.join(os.path.dirname(MAN), "sync_changes.json"), "w", encoding="utf-8"), indent=0)
    print("sync: %d copied, %d transformed, %d removed, %d unchanged" % (len(copied), len(transformed), len(removed), same))
    for r in (copied + transformed)[:40]:
        print("  changed " + r)
    for r in removed[:40]:
        print("  removed " + r)


if __name__ == "__main__":
    main()
