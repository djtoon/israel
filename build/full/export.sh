#!/usr/bin/env bash
# Import and export the full game for Windows and macOS (GPU lock via tools/godot.sh), then test the exe headless.
#   bash build/full/export.sh
cd /c/civ
export GODOT_LIMIT=3600 GODOT_OWNER=lead-export
D=build/full
rm -f $D/out/windows/* $D/out/macos/*
tools/godot.sh --headless --path /c/civ/$D/src/game --import > $D/import.log 2>&1
tools/godot.sh --headless --path /c/civ/$D/src/game --export-release "Windows Desktop" > $D/export_win.log 2>&1
tools/godot.sh --headless --path /c/civ/$D/src/game --export-release "macOS" > $D/export_mac.log 2>&1
ls -la $D/out/windows $D/out/macos
mkdir -p progress/full_end_test
GODOT_EXE=/c/civ/$D/out/windows/IsraelBirthOfANation.exe GODOT_LIMIT=900 GODOT_OWNER=lead-exetest \
	tools/godot.sh --headless -- --ui-test=C:/civ/progress/full_end_test --ui-test-end 2>&1 | grep -E "UITEST (fast|FAILURES)|SCRIPT ERROR"
