#!/usr/bin/env bash
# Record a long "flight" plan in short Movie Maker segments with GPU cool-downs in between, then join them.
#   bash record_segments.sh <plan-name> <save.json> [segment-seconds=5]
# Every segment loads the same save and replays the camera smoothing up to its start (cinematic.gd --cine-t0),
# so the joins are seamless. Rendered at 10 fps real time (the movie is fixed 30 fps) to keep the laptop GPU cool.
cd /c/civ
G=/c/civ/dev_update/gameplay
n=$1; save=$2; seg=${3:-5}
dur=$(python -I -c "import json;print(json.load(open('C:/civ/dev_update/gameplay/plans/$n.json'))['duration'])")
mkdir -p "$G/raw/seg_$n"; rm -f "$G/raw/seg_$n"/*
list="$G/raw/seg_$n/list.txt"; : > "$list"
i=0; t0=0
while python -I -c "import sys; sys.exit(0 if $t0 < $dur - 1e-6 else 1)"; do
	t1=$(python -I -c "print(min($dur, $t0 + $seg))")
	until [ "$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader | tr -d ' \r')" -lt 60 ]; do sleep 10; done
	out="$G/raw/seg_$n/s$i.avi"
	for try in 1 2 3; do
		rm -f "$out"
		GODOT_OWNER=lead-gameplay GODOT_LIMIT=600 tools/godot.sh --path /c/civ/game --windowed --resolution 1920x1080 --max-fps 10 \
			--write-movie "C:/civ/dev_update/gameplay/raw/seg_$n/s$i.avi" --fixed-fps 30 \
			-- --cine="C:/civ/dev_update/gameplay/plans/$n.json" --cine-load="$save" --cine-t0=$t0 --cine-t1=$t1 --quality=hdplus \
			> "$G/raw/seg_$n/s$i.log" 2>&1
		grep -q "CINE DONE" "$G/raw/seg_$n/s$i.log" && break
		echo "segment $i try $try did not finish; cooling down"; sleep 120
		until [ "$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader | tr -d ' \r')" -lt 58 ]; do sleep 10; done
	done
	start=$(grep -o "CINE START at frame [0-9]*" "$G/raw/seg_$n/s$i.log" | grep -o "[0-9]*$")
	frames=$(python -I -c "print(round(($t1 - $t0) * 30))")
	# keep exactly the frames from the segment's start
	ffmpeg -v error -y -i "$out" -vf "select=gte(n\,$start),setpts=N/30/TB,scale=1920:1080:flags=lanczos" -frames:v $frames \
		-c:v libx264 -preset slow -crf 16 -pix_fmt yuv420p -an "$G/raw/seg_$n/s$i.mp4"
	echo "segment $i: $t0-$t1 s, start frame $start, $(ffprobe -v error -count_frames -show_entries stream=nb_read_frames -of csv=p=0 "$G/raw/seg_$n/s$i.mp4") frames"
	echo "file 's$i.mp4'" >> "$list"
	i=$((i + 1)); t0=$t1
done
ffmpeg -v error -y -f concat -safe 0 -i "$list" -c copy "$G/$n.mp4"
ffprobe -v error -show_entries format=duration -of compact "$G/$n.mp4"
