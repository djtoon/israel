#!/usr/bin/env bash
# Refresh the web (HTML5) source copy (build/web/src/game) from the live game, incrementally.
#   bash build/web/refresh_src.sh        then build/web/export.sh, then python build/web/package_web.py
# The desktop game (game/) is never changed by this script: every web difference is applied here, to the copy, or
# sits in shared code behind OS.has_feature("web") / the project setting israel/web_look (set in the copy only).
# Resource care (2026-10-18): a pre-flight check first (RAM, disk, GPU), then only changed files are copied
# (sync_src.py: mtime/size manifest; .godot is never touched), the diet rewrites only what differs (web_diet.py, cached
# outputs, one Blender / ffmpeg process at below-normal priority), so the next import re-imports only those files.
set -e
W=/c/civ/build/web
DST=$W/src/game
python -I $W/preflight.py --label refresh --wait 20
mkdir -p "$DST" "$W/cache"
# 1. the changed sources, with the web transforms (project settings, the WEB_LOOK shader define)
python -I $W/sync_src.py
# 2. the asset diet (models, texture import limits and arrays, audio, videos)
python -I $W/web_diet.py
# 3. export presets (Web, no threads) and the custom HTML shell: written only when they differ
cmp -s "$W/export_presets.cfg" "$DST/export_presets.cfg" || cp "$W/export_presets.cfg" "$DST/export_presets.cfg"
mkdir -p "$DST/web_shell"
cmp -s "$W/shell/index.html" "$DST/web_shell/index.html" || cp "$W/shell/index.html" "$DST/web_shell/index.html"
[ -f "$DST/web_shell/.gdignore" ] || touch "$DST/web_shell/.gdignore"
grep -n "config/name\|custom_user_dir_name\|rendering_method=\|web_look" "$DST/project.godot"
