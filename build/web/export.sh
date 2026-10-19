#!/usr/bin/env bash
# Import and export the web build, then add the shell's logo and the WebM videos and log the sizes.
#   bash build/web/refresh_src.sh && bash build/web/export.sh
# Godot runs through tools/godot.sh (GPU slots, temperature guard) with GODOT_EXE=build/web/godot_low.sh: the console
# exe at below-normal priority, killed if it prints nothing for LOWPRIO_SILENCE seconds (a hang; no retry loop).
# A pre-flight check (RAM >= 8 GB, disk >= 40 GB, GPU < 70 C) runs before each heavy step.
set -e
cd /c/civ
W=build/web
export GODOT_EXE=/c/civ/$W/godot_low.sh GODOT_OWNER=web-export LOWPRIO_SILENCE=240
mkdir -p $W/out
python -I $W/preflight.py --label import --wait 20
GODOT_LIMIT=3600 tools/godot.sh --headless --path /c/civ/$W/src/game --import > $W/import.log 2>&1 || { echo "import failed or hung: see $W/import.log"; tail -5 $W/import.log; exit 1; }
python -I $W/preflight.py --label export --wait 20
rm -f $W/out/index.*
GODOT_LIMIT=1800 tools/godot.sh --headless --path /c/civ/$W/src/game --export-release "Web" > $W/export.log 2>&1 || { echo "export failed or hung: see $W/export.log"; tail -5 $W/export.log; exit 1; }
grep -E "ERROR" $W/export.log | head -20 || true
# the loading screen's wordmark (assets/intro/title.png, gold on transparent) as a small WebP
[ $W/out/logo.webp -nt /c/civ/game/assets/intro/title.png ] || python -I - <<'EOF'
from PIL import Image
im = Image.open("C:/civ/game/assets/intro/title.png").convert("RGBA")
im = im.resize((900, round(im.height * 900 / im.width)), Image.LANCZOS)
im.save("C:/civ/build/web/out/logo.webp", "WEBP", quality=88, method=6)
EOF
# the WebM videos beside index.html (streamed by an HTML <video>; build/web/web_video.py, cached)
python -I $W/web_video.py
ls -la $W/out
python -I $W/size_report.py
