#!/usr/bin/env bash
# Run by tools/godot.sh as GODOT_EXE, so a browser run of the web build takes one of the two Godot GPU slots and the
# watchdog can stop it (taskkill of this process tree). Drops godot.sh's own flags, passes the rest to browser_run.py.
#   GODOT_EXE=/c/civ/build/web/browser_slot.sh GODOT_OWNER=web GODOT_LIMIT=1200 tools/godot.sh --headless --browser chrome ...
args=()
for a in "$@"; do
	case "$a" in --headless) ;; *) args+=("$a");; esac
done
python -I C:/civ/build/web/browser_run.py "${args[@]}"
