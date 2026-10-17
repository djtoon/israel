#!/usr/bin/env bash
# Record trailer gameplay clips with Godot Movie Maker (through the GPU lock), then convert to MP4.
#   bash record.sh [plan-name ...]   (default: all plans)   HD graphics, 1920x1080, 30 fps   (QUALITY=hdplus for HD+)
cd /c/civ
G=/c/civ/dev_update/gameplay
names=("$@"); [ ${#names[@]} -eq 0 ] && names=($(ls $G/plans | sed 's/\.json$//'))
for n in "${names[@]}"; do
	echo "== $n"
	rm -f "$G/raw/$n.avi"
	GODOT_OWNER=lead-gameplay GODOT_LIMIT=1500 tools/godot.sh --path /c/civ/game --windowed --resolution 1920x1080 \
		--write-movie "C:/civ/dev_update/gameplay/raw/$n.avi" --fixed-fps 30 \
		-- --cine="C:/civ/dev_update/gameplay/plans/$n.json" --quality=${QUALITY:-hd} 2>&1 | grep -E "CINE DONE|SCRIPT ERROR|Parse Error|ERROR: .*cinematic" | head -5
	if [ -f "$G/raw/$n.avi" ]; then
		ffmpeg -v error -y -ss 1.0 -i "$G/raw/$n.avi" -vf "scale=1920:1080:flags=lanczos" -c:v libx264 -preset slow -crf 17 -pix_fmt yuv420p -an "$G/$n.mp4" \
			&& ffprobe -v error -show_entries format=duration -of compact "$G/$n.mp4"
	fi
done
