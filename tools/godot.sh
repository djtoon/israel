#!/usr/bin/env bash
# The ONLY way to launch Godot in this project.
#
#   tools/godot.sh [godot args...]
#
# GPU safety (2026-10-11 and 2026-10-14: the laptop crashed after ~7 min at 84-86C; start <70C, watchdog kills at 81C):
#  - At most 2 Godot instances at once (2 slots). The user's checkpoint PLAY.bat takes slot 1.
#  - A new instance only starts while the GPU is below START_MAX_C (nvidia-smi); otherwise it waits to cool.
#  - tools/gpu_watch.sh (started automatically) logs temperature and, at KILL_C or above, stops agent-run
#    Godot instances (never the user's game) until the GPU cools.
# Windowed runs are capped at 30 fps and followed by a 10 s cooldown. Headless runs (--headless) share the slots.
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# GODOT_EXE: the Godot 4.7.1 binary (or an exported build, run under the same GPU lock). Default: the winget install, else godot on PATH.
DEF_G="$(cygpath -u "${LOCALAPPDATA:-}" 2>/dev/null)/Microsoft/WinGet/Packages/GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe/Godot_v4.7.1-stable_win64_console.exe"
[ -f "$DEF_G" ] || DEF_G="$(command -v godot || command -v godot4 || echo godot)"
G="${GODOT_EXE:-$DEF_G}"
SLOTS=("$ROOT/.godot_gpu.lock" "$ROOT/.godot_gpu.lock2")
START_MAX_C=${START_MAX_C:-70}
WAIT_MAX=7200

gpu_temp() { nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -1 | tr -d ' \r'; }

# make sure the temperature watchdog is running (one instance machine-wide)
"$(dirname "$0")/gpu_watch.sh" --ensure >/dev/null 2>&1

holder_alive() {  # the slot's godot.sh shell or its Godot process is still running
	local s=$1 p w
	p=$(cat "$s/pid" 2>/dev/null); w=$(cat "$s/winpid" 2>/dev/null)
	[ -n "$p" ] && kill -0 "$p" 2>/dev/null && return 0
	[ -n "$w" ] && tasklist //FI "PID eq $w" 2>/dev/null | grep -q " $w " && return 0
	return 1
}

clear_stale() {  # an agent slot older than 15 min whose holder is gone (a still-running holder is never cleared); the user's slot is never cleared
	local s=$1
	if [ -d "$s" ] && ! grep -q '^user' "$s/owner" 2>/dev/null && [ -n "$(find "$s" -maxdepth 0 -mmin +15 2>/dev/null)" ] && ! holder_alive "$s"; then
		echo "godot.sh: clearing stale lock $s" >&2; rm -rf "$s"
	fi
}

waited=0; LOCK=""
while [ -z "$LOCK" ]; do
	t=$(gpu_temp)
	if [ -n "$t" ] && [ "$t" -ge "$START_MAX_C" ]; then
		[ $((waited % 60)) -eq 0 ] && echo "godot.sh: GPU at ${t}C (start limit ${START_MAX_C}C), waiting to cool" >&2
	else
		for s in "${SLOTS[@]}"; do
			clear_stale "$s"
			if mkdir "$s" 2>/dev/null; then LOCK=$s; break; fi
		done
		[ -z "$LOCK" ] && [ $((waited % 60)) -eq 0 ] && echo "godot.sh: both Godot slots busy ($(cat "${SLOTS[0]}/owner" 2>/dev/null | cut -c1-40) | $(cat "${SLOTS[1]}/owner" 2>/dev/null | cut -c1-40))" >&2
	fi
	[ -n "$LOCK" ] && break
	if [ "$waited" -ge "$WAIT_MAX" ]; then echo "godot.sh: gave up after ${WAIT_MAX}s" >&2; exit 75; fi
	sleep 5; waited=$((waited + 5))
done
echo $$ > "$LOCK/pid"
echo "${GODOT_OWNER:-unknown} $(date -Iseconds) $*" > "$LOCK/owner"
trap 'rm -rf "$LOCK"' EXIT INT TERM

headless=0
for a in "$@"; do [ "$a" = "--headless" ] && headless=1; done
if [ "$headless" = 1 ]; then LIMIT=${GODOT_LIMIT:-900}; EXTRA=(); else LIMIT=${GODOT_LIMIT:-240}; EXTRA=(--max-fps 30); fi  # GODOT_LIMIT: longer runs (exports)
# never fullscreen for agent runs: a fullscreen window covers the user's work (2026-10-12)
if [ "$headless" = 0 ]; then
	win=0; for a in "$@"; do case "$a" in --windowed|--fullscreen|-f|--maximized|-m) win=1;; esac; done
	[ "$win" = 0 ] && EXTRA+=(--windowed)
fi

# Run Godot in the background so its Windows PID can be recorded: gpu_watch.sh stops it with taskkill if the GPU overheats.
"$G" "${EXTRA[@]}" "$@" &
GP=$!
WIN=$(cat "/proc/$GP/winpid" 2>/dev/null)
echo "$WIN" > "$LOCK/winpid"
# time-limit watchdog; detached from stdout/stderr so a pipe on godot.sh closes as soon as Godot exits
# (its leftover `sleep` would otherwise hold the pipe open until LIMIT)
( sleep "$LIMIT"; [ -n "$WIN" ] && taskkill //F //T //PID "$WIN" ) </dev/null >/dev/null 2>&1 &
KP=$!
trap 'kill $KP 2>/dev/null; [ -n "$WIN" ] && taskkill //F //T //PID "$WIN" >/dev/null 2>&1; rm -rf "$LOCK"' EXIT INT TERM
wait "$GP"
status=$?
kill "$KP" 2>/dev/null
[ "$headless" = 1 ] || sleep 10  # let the GPU cool between windowed runs
exit $status
