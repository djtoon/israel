#!/usr/bin/env bash
# Refresh the full-game release source (build/full/src/game) from the live game, with release settings.
#   bash build/full/refresh_src.sh        then export with build/full/export.sh
set -e
SRC=/c/civ/game
DST=/c/civ/build/full/src/game
mkdir -p "$DST"
[ -f "$DST/export_presets.cfg" ] || cp /c/civ/build/demo/src/game/export_presets.cfg "$DST/export_presets.cfg"
cp "$DST/export_presets.cfg" /tmp/full_export_presets.cfg
# copy everything except the import cache and tests
(cd "$DST" && find . -mindepth 1 -maxdepth 1 ! -name '.godot' ! -name 'export_presets.cfg' -exec rm -rf {} +)
(cd "$SRC" && tar --exclude='./.godot' --exclude='./tests' -cf - .) | (cd "$DST" && tar -xf -)
# release size (2026-10-17, keep each zip under 1 GB): drop dev-only sources and previews, and store the
# painted 2D art (event illustrations, portraits) as lossy WebP instead of lossless (looks the same on screen)
rm -rf "$DST/assets/_pipeline" "$DST/assets/model_src" "$DST/assets/models/_cand" 	"$DST/scenes/art_preview.tscn" "$DST/scripts/art/art_preview.gd" "$DST/scripts/art/art_preview.gd.uid"
rm -f "$DST"/assets/images/test_bauhaus.png* "$DST"/assets/models/test_bauhaus.glb* 	"$DST"/assets/models/vegetation/veg_*.glb* "$DST"/assets/models/vegetation/veg_*_0.png*
python -I - "$DST" <<'PYEOF'
import sys, os, re
dst = sys.argv[1]
n = 0
for sub in ("assets/images/events", "assets/images/portraits", "assets/images/ending"):
    d = os.path.join(dst, sub)
    if not os.path.isdir(d):
        continue
    for f in os.listdir(d):
        if f.endswith(".png.import"):
            p = os.path.join(d, f)
            s = open(p, encoding="utf-8").read()
            t = re.sub(r"^compress/mode=0$", "compress/mode=1", s, flags=re.M)
            t = re.sub(r"^compress/lossy_quality=.*$", "compress/lossy_quality=0.82", t, flags=re.M)
            if t != s:
                open(p, "w", encoding="utf-8", newline=chr(10)).write(t); n += 1
print("release: lossy WebP import for", n, "images")
PYEOF
cp /tmp/full_export_presets.cfg "$DST/export_presets.cfg"
# release project settings: name, version, save folder, fullscreen, Mac texture formats, no demo limit
python -I - "$DST/project.godot" <<'EOF'
import sys, re
p = sys.argv[1]
s = open(p, encoding="utf-8").read()
s = re.sub(r'^config/name=.*$', 'config/name="Israel - The Birth of a Nation"\nconfig/version="1.0"', s, count=1, flags=re.M)
s = re.sub(r'^config/version=.*\n(?=config/version)', '', s, flags=re.M)
s = re.sub(r'^config/custom_user_dir_name=.*$', 'config/custom_user_dir_name="IsraelBirthOfANation"', s, flags=re.M)
s = re.sub(r'^window/size/mode=.*$', 'window/size/mode=3', s, flags=re.M)
if "import_etc2_astc" not in s:
    s = re.sub(r'(\[rendering\]\n)', r'\1\ntextures/vram_compression/import_etc2_astc=true\n', s)
s = re.sub(r'^demo_last_turn=.*\n?', '', s, flags=re.M)
open(p, "w", encoding="utf-8", newline="\n").write(s)
EOF
# export names and branding (from the demo presets)
sed -i -e 's|IsraelBirthOfANation_Demo|IsraelBirthOfANation|g' -e 's|CivilizationIsrael_Demo|IsraelBirthOfANation|g' \
       -e 's|^application/product_name=.*|application/product_name="Israel: The Birth of a Nation"|' \
       -e 's|^application/file_description=.*|application/file_description="Israel: The Birth of a Nation"|' \
       -e 's|^application/company_name=.*|application/company_name="Israel: The Birth of a Nation"|' \
       -e 's|^application/file_version=.*|application/file_version="1.0.0.0"|' \
       -e 's|^application/product_version=.*|application/product_version="1.0.0.0"|' \
       -e 's|com.israelbirthofanation.demo|com.israelbirthofanation.game|' "$DST/export_presets.cfg"
grep -n "config/name\|config/version\|custom_user_dir_name\|window/size/mode\|demo_last_turn\|import_etc2" "$DST/project.godot"
grep -n "export_path\|product_name\|bundle_identifier" "$DST/export_presets.cfg"
