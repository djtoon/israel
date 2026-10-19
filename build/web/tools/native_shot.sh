#!/usr/bin/env bash
# dev loop: sync the web copy, import it, and shoot it natively with the Compatibility renderer (desktop OpenGL; the
# same renderer as WebGL 2, not its limits). One heavy job at a time, below-normal priority, pre-flight checks.
#   bash build/web/tools/native_shot.sh <out.png> [user args...]
set -e
OUT=$1; shift
cd /c/civ/build/web && bash refresh_src.sh > refresh.log 2>&1 && grep -E "sync:|changed" refresh.log | head -8
cd /c/civ
export GODOT_EXE=/c/civ/build/web/godot_low.sh LOWPRIO_SILENCE=240
python -I build/web/preflight.py --label import >/dev/null
GODOT_OWNER=web-import GODOT_LIMIT=1800 tools/godot.sh --headless --path /c/civ/build/web/src/game --import > build/web/import.log 2>&1
python -I build/web/preflight.py --label native >/dev/null
GODOT_OWNER=web-native GODOT_LIMIT=240 tools/godot.sh --path /c/civ/build/web/src/game --rendering-driver opengl3 --resolution 1280x720 -- --shot=$(cygpath -m "$OUT") --frames=150 "$@" 2>&1 | grep -E "CAPTURED|SCRIPT|Shader|shader" | head -8
