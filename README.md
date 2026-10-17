# Israel: The Birth of a Nation

A Civilization VI–style historical strategy game: lead the State of Israel from 14 May 1948 to 2023, one quarter per turn. It is built in **Godot 4.7.1**, in English and Hebrew.

## Layout
- `game/`: the Godot project. Open `game/project.godot` in Godot 4.7.1.
  - `scripts/sim/`: the simulation. `API.md` documents it, and `sim_test.gd` runs the headless test suites.
  - `scripts/ui/`: the UI. `ui_test.gd` runs the UI test suites, including `--ui-test-layout`.
  - `scripts/map/`: the 3D map, with SD / HD / HD+ graphics, day/night and trees. See `MAP_API.md`.
  - `data/`: events, forks, wars, diplomacy, cities and endings. All the history is sourced.
  - `i18n/`, `data/i18n/`: the Hebrew catalogs.
- `sources/`: the citation database (`sources.json`, rendered to `SOURCES.md`). Run `python tools/check_sources.py`.
- `tools/`: asset generation (`gen.py`: image, model, audio and video), the history and i18n tooling, and `godot.sh`, the GPU-safe launcher.
- `build/full/`: release builds. Run `refresh_src.sh`, then `export.sh`, then `package_release.py`.
- `CONTRACT.md`: the shared rules for contributors. `V1.md`–`V5.md` define each version's scope and acceptance.

## Running tests (headless)
```
tools/godot.sh --headless --path game --script res://scripts/sim/sim_test.gd
tools/godot.sh --headless --path game -- --shot=x.png --ui-test=out_dir --ui-test-turns=40
```
