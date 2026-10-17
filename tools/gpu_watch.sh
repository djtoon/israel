#!/usr/bin/env bash
# GPU temperature watchdog for the Godot runs in this project.
#   tools/gpu_watch.sh            run in the foreground
#   tools/gpu_watch.sh --ensure   start in the background unless already running
# Every 10 s it appends "time,tempC,util%" to progress/gpu_temp.csv (last ~1 day kept).
# At KILL_C or above it stops agent-run Godot instances (the ones holding a slot whose owner is not "user"),
# newest first, one per check, so the user's own game keeps running. New launches are already gated by godot.sh.
KILL_C=${KILL_C:-81}
LOG=/c/civ/progress/gpu_temp.csv
PIDF=/c/civ/.gpu_watch.pid

if [ "$1" = "--ensure" ]; then
	if [ -f "$PIDF" ] && kill -0 "$(cat "$PIDF")" 2>/dev/null; then exit 0; fi
	nohup "$0" >/dev/null 2>&1 &
	exit 0
fi
echo $$ > "$PIDF"
while true; do
	line=$(nvidia-smi --query-gpu=temperature.gpu,utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -1 | tr -d ' \r')
	t=${line%%,*}
	echo "$(date -Iseconds),$line" >> "$LOG"
	if [ "$(wc -l < "$LOG")" -gt 9000 ]; then tail -8000 "$LOG" > "$LOG.tmp" && mv "$LOG.tmp" "$LOG"; fi
	if [ -n "$t" ] && [ "$t" -ge "$KILL_C" ]; then
		for s in /c/civ/.godot_gpu.lock2 /c/civ/.godot_gpu.lock; do
			[ -d "$s" ] || continue
			grep -q '^user' "$s/owner" 2>/dev/null && continue
			w=$(cat "$s/winpid" 2>/dev/null)
			echo "$(date -Iseconds),OVERHEAT ${t}C: stopping agent Godot ($(cat "$s/owner" 2>/dev/null | cut -c1-60))" >> "$LOG"
			# stop the Godot exe by its Windows PID; godot.sh then exits and its trap frees the slot
			[ -n "$w" ] && taskkill //F //T //PID "$w" >/dev/null 2>&1
			break
		done
	fi
	sleep 10
done
