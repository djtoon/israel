# Israel: The Birth of a Nation: web (HTML5) version

The user's request on 2026-10-18: "Ok let's make the html version. Desktop only not mobile".

- **Scope:** the FULL game (1948 to Q3 2023, ending with the memorial), played in desktop browsers.
- **Not in scope:** phones, tablets and touch.
- **Destination:** itch.io HTML5 ("Run game in browser"), as a zip.
- **Starting point:** the old plan in `mobile.md` (sections 1–3) is the basis. The desktop parts of it still apply. Ignore its demo scope and its mobile phase.

When every box below is checked, the lead hands over `build/web/release/IsraelBirthOfANation_Web.zip` and stops.

## Rules
- The desktop game keeps Forward+ and its full quality. The web build is a separate copy (`build/web/src/game`), produced by `build/web/refresh_src.sh` from the live game.
- Any web-only change to shared code is guarded by `OS.has_feature("web")` or a project-setting override, so the desktop never degrades. After changing shared code, the desktop suites must still pass.
- **History and Oct 7:**
  - The game ends after Q3 2023 with the memorial, verbatim.
  - Nothing is dated after Q3 2023.
  - There is no 2023– Gaza-war content.
- **GPU safety:**
  - At most 2 Godot instances, through `tools/godot.sh` only.
  - Start a run below 70°C; the watchdog kills at 81°C.
  - A browser rendering the game counts as a Godot instance. Keep it windowed at 1280x720, keep runs short, and close the browser after each run.
  - Never touch `.godot_gpu.lock*`.
- Write GDScript with the Edit tool, not shell heredocs. Grep before adding member names.
- Tests must never write into the player's folder (`%APPDATA%/IsraelBirthOfANation`).

## Acceptance
- [ ] **1. Runs in a browser.**
  - The web export uses the Compatibility renderer and the **no-threads** template, so it needs no special server headers.
  - It loads and plays from a plain local HTTP server in Chrome, Edge and Firefox on Windows, driven by Playwright with screenshots.
  - The page has a branded loading screen (logo and progress bar).
  - There is no SCRIPT ERROR on a 40-turn run.
- [ ] **2. Fits itch.io.** Check itch.io's current HTML5 limits on the web: file count, size per file and total size. The zip and every file in it must be inside those limits.
  - Target: `.pck` ≤ about 200 MB, with a hard cap of whatever itch allows per file.
  - Log the size per category in `progress/web_size.txt`.
- [ ] **3. Looks right.**
  - A "Web" graphics look built on the SD look (Compatibility renderer: no SSAO or SSIL, and no HD/HD+).
  - It must read like the desktop SD medium tier: water, terrain, cities, labels, day and night, and trees.
  - All 7 custom shaders compile on WebGL 2. Any missing effects are listed.
  - Side-by-side shots against desktop SD at Jaffa 1948, Jerusalem 1967 and Tel Aviv 2023, day and night.
- [ ] **4. Performance.**
  - At least 60 fps at 1280x720 on this laptop in Chrome. Also estimate integrated-GPU performance with a forced low setting.
  - First load ≤ about 45 s at 50 Mbit/s, based on the measured download size.
  - End of turn ≤ about 1.5 s in the browser, with the "Ending turn…" indicator shown while it runs.
  - Tab memory ≤ about 1.5 GB.
  - The perf60 graphics detect step either works on web or is replaced by a fixed web tier, whichever is honest.
- [ ] **5. Browser behaviour.**
  - Keys the browser steals are remapped or blocked: F5 reload, Ctrl+S, Ctrl+L, F11.
  - Fullscreen works from a button.
  - Quit is hidden.
  - Audio starts after the first click; there is a click-to-start screen if needed.
  - The intro video plays, or falls back to a still image.
  - Saves persist across a page reload (IndexedDB).
  - There is **Export save / Import save** (download or upload of a file).
  - The language prompt and Hebrew RTL work.
  - Citation links open in a new tab.
- [ ] **6. Full game end to end.** A browser run fast-forwards (or loads a late save) to Q3 2023 and shows the memorial verbatim. The web ui tests that can run in a browser pass (at least en40, end and layout), with 0 failures.
- [ ] **7. Package.**
  - `build/web/export.sh` and `build/web/package_web.py` build `build/web/release/IsraelBirthOfANation_Web.zip`.
  - A short `build/web/ITCH_UPLOAD.md` covers the itch settings: viewport 1280x720, the fullscreen button, "SharedArrayBuffer" off, and so on.
