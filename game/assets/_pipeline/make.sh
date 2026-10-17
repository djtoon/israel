#!/usr/bin/env bash
# make.sh [build.py args]  -> normalise GLBs, rewrite MANIFEST.json, re-import into Godot
cd /c/civ/game/assets/_pipeline && python build.py "$@" | tail -1
G="/c/Users/Dans/AppData/Local/Microsoft/WinGet/Packages/GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe/Godot_v4.7.1-stable_win64_console.exe"
/c/civ/tools/godot.sh --headless --path /c/civ/game --import 2>&1 | grep -iE "^ERROR|error:" | head -20
