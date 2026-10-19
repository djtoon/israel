# AGENTS.md: a quick start for coding agents (and humans)

*Israel* is a turn-based, Civilization VI–style strategy game in **Godot 4.7.1** (GDScript, Forward+ renderer on desktop, Compatibility renderer on the web). The player leads Israel from **14 May 1948 (turn 1 = Q2 1948) to Q3 2023 (turn 302)**, one quarter per turn. Read this file first; [`CONTRACT.md`](CONTRACT.md) has the full rules.

## 1. Orientation in 60 seconds

```
game/project.godot          open this in Godot 4.7.1 (main scene: scenes/main.tscn, script: scripts/main.gd)
game/scripts/sim/           the rules engine, headless, no rendering code. API: sim/API.md. Data formats: sim/FORKS.md
game/scripts/ui/            HUD, windows, screens, the UI test drivers (ui_test*.gd), l10n.gd (translation)
game/scripts/map/           3D hex map: terrain, cities, trees, water, day/night, graphics tiers. API: map/MAP_API.md
game/scripts/audio/         music and sound director (AUDIO_API.md)
game/data/                  ALL the history and balance as JSON (events, forks/, wars/, cities, techs, units...)
game/data/i18n/he/          Hebrew for the data files     game/i18n/he/   Hebrew for the UI strings
game/assets/                art, 3D models (GLB), audio, fonts, the intro videos (MANIFEST.json, ART_DIRECTION.md)
sources/                    citation database: sources.json (history), sim_sources.json (gameplay), map_sources.json
tools/                      godot.sh (the launcher), gen.py (AI asset generation), history/ and i18n/ tooling
build/full/  build/web/     release pipelines (desktop zips; HTML5 for itch.io)
```

## 2. Hard rules

1. **History is factual, neutral and sourced.** Every event, date, place or number in `game/data` needs a `source` id that exists in `sources/*.json`. A citation needs a live or archived URL and a short verbatim quote. Casualty and displacement events list **every** affected population (Israeli, Palestinian, other), or say "none reported". Every dilemma option names a real **advocate** from the time. Run `python tools/check_sources.py` before you commit data.
2. **The game ends on 7 October 2023 with the memorial text in `game/data/ending_oct7.json`, verbatim.** Don't edit it. Don't add content about the Gaza war that followed, or anything after Q3 2023.
3. **Keep the sim headless.** Nothing in `scripts/sim/` may touch nodes, rendering or the UI. The UI talks to the sim only through the `Sim` API in `sim/API.md`. Adding to that API is fine; renaming or removing signatures breaks the UI and saves.
4. **All player-facing text is translatable.** Strings go through `L10n` / `tr()` (see `game/i18n/I18N.md`). When you add an English UI string, add its Hebrew to a `game/i18n/he/*.json` file. Use `game/i18n/glossary_he.json` for names and terms. Hebrew is laid out right to left, so check the layout in both languages.
5. **The name is "Israel"** (Hebrew ישראל). Internal ids still say `IsraelBirthOfANation` (the user data folders, save format, exe and zip names, the bundle id). Don't rename them, or players lose their saves. Never write "Civilization" in player-facing text (it's a trademark).
6. **Never write into the player's data folder.** The dev project uses `%APPDATA%/IsraelBirthOfANationDev` (`config/custom_user_dir_name` in `project.godot`). Releases use `%APPDATA%/IsraelBirthOfANation`. Tests must not save the player's settings.
7. **No secrets in the repo.** `tools/gen.py` reads `REPLICATE_API_TOKEN` from the environment. Signing keys stay out of git.

## 3. Run, test, check

Godot must run through **`tools/godot.sh`** (bash; on Windows use Git Bash). It finds Godot, or uses `GODOT_EXE` if you set it. It allows at most **2 Godot instances at once** and waits while an NVIDIA GPU is above 70 °C. A watchdog (`tools/gpu_watch.sh`) stops agent runs at 81 °C, because parallel windowed runs once overheated the development laptop. Prefer `--headless`. Never create or delete the `.godot_gpu.lock*` folders yourself.

```bash
# first-time import (or after adding assets)
tools/godot.sh --headless --path game --import
# simulation suites (seconds to minutes)
tools/godot.sh --headless --path game --script res://scripts/sim/sim_test.gd
# only validate the fork and war JSON files (seconds)
tools/godot.sh --headless --path game --script res://scripts/sim/sim_test.gd -- --validate-only
# UI suites: they drive the real game. --ui-test needs an ABSOLUTE output folder; look for "UITEST FAILURES 0"
tools/godot.sh --headless --path game -- --lang=en --ui-test=C:/tmp/ui/en40 --ui-test-turns=40   # 40 turns of play
tools/godot.sh --headless --path game -- --ui-test=C:/tmp/ui/casual --ui-test-casual             # story mode
tools/godot.sh --headless --path game -- --ui-test=C:/tmp/ui/layout --ui-test-layout             # every window, every screen size
tools/godot.sh --headless --path game -- --ui-test=C:/tmp/ui/dn --ui-test-daynight               # day/night
# a real windowed screenshot (short, GPU-heavy)
tools/shot.sh C:/tmp/shot.png --turns=5
# history and quote checks
python tools/check_sources.py
python tools/check_fork_quotes.py
```

The other flags (`--lang=he`, `--ui-test-end`, `--ui-test-scenarios`, `--perf`, `--detect` and more) are parsed in `scripts/main.gd` and `scripts/ui/ui_test.gd`.

## 4. Common tasks

**Add a historical event.** Append a record to `game/data/events.json`:
`{id, date:"YYYY-MM-DD", title, summary, kind, places:[...], effects:{...}, source:["S…"], cite:[{claim, source, quote, url}]}`. Add `affected_populations` for any casualties. If the source is new, add it to `sources/sources.json` (S-ids are permanent; never renumber one). Then run `check_sources.py` and the sim suite. Put the Hebrew in `game/data/i18n/he/events.json`; `tools/i18n/make_skeletons.py` adds the empty entries.

**Write a cabinet dilemma (fork).** Add it to `game/data/forks/<range>.json`. The schema (`options`, `now`, `lasting` effect types, `historical`, `advocate`, `cite`) is in `game/scripts/sim/FORKS.md`. Exactly one option is `historical: true`. Run `--validate-only`, then the sim suite.

**Change a war.** Edit its file in `game/data/wars/`; the schema is also in `FORKS.md`.

**Balance.** The numbers are in `game/data/{fiscal,techs,civics,buildings,units,districts,policies,difficulty}.json`. The sim reports in `scripts/sim/*_REPORT.md` show how earlier balance passes were measured. Re-run the sim suite and `--ui-test-casual` after you change them.

**UI.** Windows extend `ui_window.gd`. Shared styling is in `ui_theme.gd` and `ui_kit.gd`, and the layout area is `GameUI.hud_space`. Run `--ui-test-layout` after any UI change. It checks overlaps and clipping at many resolutions, in English and Hebrew.

**3D map and graphics.** Read `scripts/map/MAP_API.md` first. The graphics tiers (HD+ … SD, plus `web` and `web_low`) are in `gfx_tier.gd`. Web-only paths are guarded with `OS.has_feature("web")`, so check that desktop behaviour stays the same.

**Art and models.** Run `python tools/gen.py image|model|audio|video ...` (it needs `REPLICATE_API_TOKEN`; usage is in `image_gen.md`, `3d_gen.md`, `audio_gen.md` and `video_gen.md`). Follow the conventions in `CONTRACT.md`: 1.0 = one hex, +Y up; GLBs need normals (`assets/_pipeline/add_normals.py`) and non-metallic materials. After you replace a GLB, delete its stale `.godot/imported` entry.

## 5. Code style

- GDScript with **tabs**, typed where the surrounding code is typed (`var x: int`, `func f() -> void`). Match the comment density and naming of the file you're in.
- Before you add a member, grep for its name: many scripts are large and share names across autoloads.
- Commit the `.uid` files Godot creates next to new scripts.
- `.gitattributes` sets `* -text`, so git never rewrites line endings. Keep each file's existing endings.
- The `.gitignore` is a **whitelist**. A new top-level folder isn't tracked until you add a `!/folder/` line.

## 6. Builds (maintainers)

The build scripts assume Windows with the repo at `C:\civ`, Godot 4.7.1 from winget, and the export templates installed.

- **Desktop:** `build/full/refresh_src.sh` (copies a release source tree and sets the release user folder), then `build/full/export.sh`, then `python build/full/package_release.py`. The zips land in `build/full/release/`.
- **Web:** `build/web/refresh_src.sh`, then `build/web/export.sh`, then `python build/web/package_web.py`. The web build drops HD assets so `index.pck` stays under itch.io's 200 MB file limit. The upload steps are in `build/web/ITCH_UPLOAD.md`, and the design and limits in `WEB.md`.

Export and import are heavy jobs. Run one at a time.

## 7. Where the decisions are written down

- `CONTRACT.md`: the shared rules (history, sources, art, data ownership, user data).
- `V1.md` … `V5.md`, `WEB.md`: what each version set out to do, and how it was accepted.
- `game/scripts/sim/*_REPORT.md`: balance and autoplay measurements.
- `sources/SOURCES.md`: the rendered bibliography. It is generated from `sources/sources.json`; never edit it by hand.
