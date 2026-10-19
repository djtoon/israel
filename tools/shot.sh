#!/usr/bin/env bash
# Usage: tools/shot.sh <out.png> [extra user args e.g. --turns=5 --frames=120]
# Runs the real game windowed (GPU renderer), saves a screenshot, quits.
# Goes through tools/godot.sh, so only one Godot runs at a time (GPU overheating protection).
OUT="$(cygpath -m "$(realpath -m "$1")")"; shift
"$(dirname "$0")/godot.sh" --path "$(cd "$(dirname "$0")/.." && pwd)/game" --windowed --resolution 1672x941 -- --shot="$OUT" "$@" 2>&1 | grep -vE '^\s*$' | tail -40
