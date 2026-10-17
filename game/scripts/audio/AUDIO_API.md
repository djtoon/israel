# AudioDirector API (autoload `AudioDirector`)

Safe to call anywhere: no-ops in headless runs and when a file is missing.

| Call | Meaning |
|---|---|
| `set_volume(bus, linear)` / `get_volume(bus)` | bus = "Master", "Music", "SFX", "Ambience", "UI"; linear 0..1. Saved to `user://game.cfg` section `[audio]` (keys `music`, `sfx`, `ambience`, `ui`, `master`) and loaded at start. The Settings menu should just call these. |
| `play_ui(name)` | UI bus: `click`, `hover`, `panel_open`, `panel_close`, `end_turn`, `notification`, `deny` |
| `play_sfx(name)` | SFX bus: `build_complete`, `unit_move`, `unit_attack` (plus any ui name) |
| `play_sting(kind)` | `war_begins`, `ceasefire`, `peace_treaty`, `election`, `fork_decided`, `research_complete`, `era_change`, `game_end_good`, `game_end_mixed`; ducks music/ambience |
| `set_era(era_id)` | int 1..8, or "era3"; crossfades, rotates the era's 2 tracks (also rotates each time the loop wraps) |
| `set_situation(s)` | `"peace"` (era music), `"war"`, `"end"`, `"treaty"` (peace theme for 75 s, then era music) |
| `set_ambience(kind)` | `coast`, `city`, `desert`, `jerusalem`, `""`/`"none"` |
| `duck_for_sting(seconds)` | manual duck of Music+Ambience |

## Aliases (what ui/ui_audio.gd already sends)
- `play_sting`: `war`, `peace` (becomes `ceasefire` when it follows a crisis end), `election`, `government`, `fork`, `research`, `era`, `game_end` (good/mixed from the final score) plus all long names above.
- `play_sfx("research_done")` plays the research stinger; `set_situation("normal")` = `"peace"`; `set_bus_volume(bus, linear)` = `set_volume`.
- Volume persistence is the Settings code's job (`user://game.cfg` `[audio]`, keyed `Music`/`SFX`/`Ambience`/`UI`/`Master`); the director reads those keys at start and does not write them.

## Done by the director itself (polls `game.game_ui.sim`, reconnects on new/loaded game)
Music only, so the UI's stingers are not doubled: era_changed -> era music; crisis_started/ended -> war theme and back;
diplomacy_changed to peace/normalized -> peace theme for 75 s; game_over -> end theme.
SFX: production_completed (build_complete), combat (unit_attack), unit_moved (unit_move).
Starting a game fades out the menu's `MenuMusic` player and starts era music + coast ambience.
Stingers are NOT hooked (the UI queues one per turn and calls `play_sting`).

## UI must still call
- `play_ui`/`play_sfx` `click`, `hover`, `panel_open`, `panel_close`, `end_turn`, `notification`, `deny` (already: click, hover, end_turn, notification).
- `play_sting("fork")` on fork confirm; `set_ambience(kind)` when the camera focus moves (optional).
