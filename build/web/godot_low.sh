#!/usr/bin/env bash
# GODOT_EXE for tools/godot.sh: the real Godot console exe at below-normal priority, with lowprio.py's silence
# watchdog (no output for LOWPRIO_SILENCE s, default 180 = hung: killed, exit 124). godot.sh's lock logic is untouched.
#   GODOT_EXE=/c/civ/build/web/godot_low.sh GODOT_OWNER=web GODOT_LIMIT=1800 tools/godot.sh --headless ...
REAL="$(cygpath -u "${LOCALAPPDATA:-}")/Microsoft/WinGet/Packages/GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe/Godot_v4.7.1-stable_win64_console.exe"
[ -f "$REAL" ] || REAL="$(command -v godot)"
python -I "$(dirname "$0")/lowprio.py" "$(cygpath -w "$REAL")" "$@"
