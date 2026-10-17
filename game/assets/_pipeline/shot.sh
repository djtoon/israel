#!/usr/bin/env bash
# shot.sh <out.png> [art_preview args...]   renders scenes/art_preview.tscn windowed via the capture harness
G="/c/Users/Dans/AppData/Local/Microsoft/WinGet/Packages/GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe/Godot_v4.7.1-stable_win64_console.exe"
OUT="$(cygpath -m "$(realpath -m "$1")")"; shift
cd /c/civ/game
/c/civ/tools/godot.sh --path /c/civ/game --windowed --resolution 1672x941 res://scenes/art_preview.tscn -- --shot="$OUT" --frames=30 "$@" 2>&1 | grep -E "ERROR|SCRIPT|CAPTURED|Parse" | head -20
