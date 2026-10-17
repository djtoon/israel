# Israel: The Birth of a Nation: Web build plan (plus mobile notes)

**Goal:** a browser-playable build. Click a link (for example on itch.io), it loads in under a minute, and it plays at 30+ fps on an ordinary laptop. Nothing to install, and no SmartScreen or Gatekeeper warnings.

**Scope:** first the **demo (1948–Q3 1967)**, then the full game once that runs well.

**Status:** plan only (written 2026-10-12, during the v2 fix round). Start after v2 ships.

---

## 1. Review: where the game stands today (measured on the dev build)

| Area | Today | Web problem | Severity |
|---|---|---|---|
| **Renderer** | Forward+ (Vulkan/D3D12) | Browsers only run WebGL 2 through the **Compatibility** renderer. Forward+ cannot run on web. | **Blocker** |
| **Post effects** | SSAO, glow, filmic and AgX tone mapping, aerial-perspective fog, MSAA 2x, 4-split directional shadows (`map_view`, `quality.gd`) | No SSAO in Compatibility. Glow, AgX and fog behave differently. Shadow splits and MSAA cost a lot in WebGL. | High |
| **Shaders** | 7 custom shaders: `terrain` (385 lines), `water` (uses `hint_screen_texture`, `textureLod`, `depth_draw_always`), `building`, `diorama`, `props`, `artinst`, `artmodel`, plus `hexcommon.gdshaderinc` (`texelFetch` on data textures) | Must compile as GLSL ES 3.0. The water screen-texture read and the float data textures (`hex_data`, `height`, `data2`) need checking on WebGL 2. | High |
| **Export size** | Demo `.pck` is **525 MB**. Imported textures 334 MB (295 `.ctex`), model scenes 203 MB (165 `.scn`), videos 30 MB | Too big for a browser download. itch.io also caps each file at about 200 MB, so the `.pck` would not even upload. | **Blocker** |
| **3D models** | 140 AI-generated GLBs in use (477 MB of source), with heavy TRELLIS meshes (1–6 MB each) and an embedded texture per model; plus 3 unused (`test_bauhaus`, 2 `_cand`) | Download size, GPU memory and draw calls | High |
| **Videos** | `intro.ogv` 18 MB (30 s, 720p), `menu_loop.ogv` 12 MB | Size. Theora on web needs a test. Browsers block autoplay with sound until the player clicks. | Medium |
| **Threads** | None (no `Thread`, `WorkerThreadPool` or `Mutex`) | Good: we can use the **no-threads** web template, which needs no special server headers and works on itch.io. | Good |
| **CPU (sim)** | GDScript sim; end of turn and fast-forward run on the main thread | WebAssembly GDScript runs about 1.5–3× slower, and a long end of turn freezes the tab. | Medium |
| **Files** | Saves go to `user://` (`save_slots.gd`, `game_state.gd`). `sim_db.gd` reads `../sources/` (dev validation only). Citations use `OS.shell_open` | `user://` maps to the browser's IndexedDB, which works but only per browser. `../sources` does not exist on web, so guard it. `shell_open` opens a new tab, which is fine. | Low |
| **Keys** | F5 quick-save, F9 load, F11 fullscreen, Ctrl+S/Ctrl+L save and load, Esc, F1 | **F5 reloads the page** and loses the game. Ctrl+S and Ctrl+L are browser shortcuts. Fullscreen needs a user click. | **High** |
| **Quit button** | `get_tree().quit()` | Does nothing in a browser. | Low |
| **Export templates** | Windows and macOS 4.7.1 installed; **web templates not installed** | Install `web_nothreads_release.zip` and the others. | Setup |
| **Test tools** | Chrome, Edge and Python Playwright are installed | Good: the browser build can be driven and screenshotted automatically. | Good |

## 2. Budgets (what "good on web" means)

| Budget | Target |
|---|---|
| Download | **`.pck` ≤ 150 MB** (hard limit 200 MB for itch.io); all files ≤ 180 MB |
| First load | ≤ 45 s on 50 Mbit/s, with a branded progress bar |
| Frame rate | ≥ 30 fps at 1280×720 on integrated graphics (Intel Iris Xe class) in Chrome, at the "Web" quality preset; ≥ 60 fps on this laptop |
| End of turn | ≤ 1.5 s in the browser, with the loading or "Ending turn…" indicator shown while it runs |
| Memory | ≤ 1.5 GB tab memory; GPU textures ≤ 600 MB |
| Browsers | Chrome, Edge and Firefox (desktop) must work; Safari 17+ (macOS) should work |

## 3. The plan

The web build is a **separate copy** (`build/web/src/game`), produced by a script from the live game, the same way the demo is built. The desktop game keeps Forward+ and its full quality. Every web-specific change sits behind a project-setting override or an `OS.has_feature("web")` check. The web version never degrades the desktop one.

### Phase 0: Setup (½ hour)
- Install the Godot 4.7.1 **web export templates**.
- Add a "Web" preset with **no threads** (`variant/thread_support=false`), plus VRAM compression for desktop (S3TC/BPTC) and mobile (ETC2/ASTC).
- Write `build/web/refresh_src.sh` (copy the game, apply web overrides) and `build/web/export.sh`, modelled on `build/demo/`.

### Phase 1: Asset diet (1 day), the biggest win: 525 MB down to about 120 MB
1. **Textures.** Set an import size limit of 1024 px for all model and terrain textures in the web copy, and 512 for small props and vegetation. A 2048→1024 limit alone cuts texture memory and size about 4×. VRAM-compress everything; the terrain data textures stay lossless.
2. **Meshes.** Batch-simplify every GLB to about 25–35% of its triangles with gltfpack/meshoptimizer (or Blender's decimate in a headless script), keeping silhouettes. Check before/after shots of Tel Aviv, Jaffa, Jerusalem and Haifa. TRELLIS meshes are very dense, so most can lose 70% invisibly at map zoom.
3. **Drop** unused and alternate models (`test_bauhaus`, `_cand/`, `__orig` / `__fixed` / `__lo*` variants where one is chosen) and dev-only files (`*.md`, tests, `_pipeline/`, `model_src/`, which `.gdignore` already excludes).
4. **Videos.** Re-encode the intro to 720p at about 2.5 Mbit/s (about 9 MB) and the menu loop to about 4 MB. Keep a still-image fallback (the logo over the first frame) in case Theora fails on a browser.
5. **Audio.** The menu music (3 MB MP3) is fine. Ogg Vorbis at 96 kbps would halve it, if needed.
6. **Split for faster start (optional).** Load city model packs per era as needed, so the 1948 map starts with only the 1948 set.
7. **Measure** every step: `.pck` size per category, logged to `progress/web_size.txt`.

### Phase 2: Renderer port (1–1½ days)
1. Set `rendering/renderer/rendering_method.web="gl_compatibility"` in the web copy; the desktop stays Forward+.
2. Add a **"web" quality preset** to `quality.gd`:
   - no SSAO;
   - 1 shadow split with a short distance, about 14;
   - no tree shadows;
   - MSAA off (FXAA, or MSAA 2× on strong GPUs);
   - lower `art_range`;
   - glow off or light.
   The preset is chosen automatically when `OS.has_feature("web")`.
3. **Shader pass.** Compile all 7 shaders under Compatibility and fix the errors:
   - **water:** if the screen-texture refraction misbehaves, switch to a cheap fake refraction (tinted alpha plus a normal-map shimmer);
   - **terrain:** the `texelFetch` data textures must use formats WebGL 2 can sample (RGBA8 or RG8 without filtering; avoid unsupported float filtering);
   - match the look: tone mapping (Filmic vs AgX), fog density and sun colour, so the web build looks like the desktop target frame (`ref/screenshot.png`).
4. **A/B check.** Compare the same 6 camera shots on desktop and web (Jaffa, Jerusalem, Haifa, Ramon, a wide view, the HUD) and fix the worst differences.

### Phase 3: Web platform behaviour (½ day)
- **Click-to-start gate.** A "Click to play" screen with the logo, because browsers block sound until a click. The click starts the intro video with sound and the music.
- **Keys on web:**
  - quick-save → **Ctrl+Shift+S** or the menu, never F5;
  - quick-load → Ctrl+Shift+L;
  - stop the browser defaults for the game's own shortcuts while the canvas has focus;
  - fullscreen through a button, since browsers need a click.
- **Hide Quit** on web.
- **Saves.** Saves live in this browser (IndexedDB). Add **Export save / Import save** (download or upload a `.json`) so players can move or keep saves. Warn players that clearing site data deletes saves.
- **Guard** dev-only file reads (`sim_db.gd` `../sources`, `sim_test` outputs) with `OS.has_feature("web")`.
- **Citation links** open in a new tab (`shell_open` already works).

### Phase 4: Performance (1 day)
1. **Profile in Chrome** (Godot's web build plus the browser's performance panel). Measure:
   - fps at Low, Web and Medium;
   - draw calls;
   - end-of-turn time;
   - tab memory.
2. **Draw calls.** Use more `MultiMeshInstance3D` (it is used in only 9 places today) for repeated buildings, trees and props per city. Merge static city blocks per hex. Add distance culling and LOD (show low-poly or billboard versions when zoomed out).
3. **End of turn.** Show an "Ending turn…" indicator, and spread heavy post-turn work (map date rebuild, label refresh) over several frames. Cache per-turn computations the UI re-asks for.
4. **Map rebuilds.** The map rebuild on date change (era borders, cities) should update only what changed, not everything.
5. Repeat until the budgets in §2 are met.

### Phase 5: Package and host (½ day)
- **Custom HTML shell:** the black background, your gold wordmark, a progress bar styled in the game's gold, a fullscreen button, and a "best in Chrome/Edge/Firefox on a computer" note for phones.
- **Local test:** `python -m http.server` in `build/web/out`, then open it in Chrome, Edge and Firefox.
- **itch.io (only when you say so):**
  - an HTML5 project with the zip upload (≤ 1,000 files, each file ≤ 200 MB);
  - "SharedArrayBuffer" support **off** (the no-threads build doesn't need it);
  - viewport 1280×720 with a fullscreen button;
  - "Mobile friendly" off until a touch version exists.

### Phase 6: Automated and blind QA (½ day)
- **Playwright script** (Chrome, real GPU) that:
  - loads the page;
  - clicks to start, waits for the menu, starts the tutorial;
  - plays 10 turns through the UI test hooks (`--ui-test` runs inside the web build through URL arguments);
  - screenshots each step and records fps, memory and load time.
- **Blind critic** (Sonnet), given the web build plus the desktop target frames: does it look and play acceptably? It lists the worst differences.

**Total estimate:** about 4–5 working days of builder time for a good web demo. A rough "it runs" build could come in about 1 day (Phases 0–2 at minimum settings), but it would be slow and about 300 MB.

## 4. Risks and fallbacks

| Risk | Fallback |
|---|---|
| A custom shader can't be ported cleanly (water refraction, terrain data textures) | Simpler web-only shader variants with the same colours |
| The AI-model city scenes are too heavy even after decimation | Web-only low-poly building kit for distant zoom; full models only when zoomed into a city |
| Theora video fails in some browser | Logo-over-still intro plus music; no video |
| Safari WebGL quirks | Officially support Chrome, Edge and Firefox; Safari best-effort |
| A slow end of turn on weak laptops | Show progress; lower AI depth on web; split the turn work over frames |

## 5. Mobile (later; notes only)

- **Android tablets** are realistic later: the Mobile renderer, the same asset diet as web, and a build on this PC (Android SDK, JDK and a signing key).
- **Phones** need a UI redesign; the UI was designed for mouse and keyboard.
- **iOS** needs a Mac with Xcode and an Apple developer account ($99 a year).
- **Touch work list:**
  - tap to select and long-press to preview (in place of hover tooltips);
  - pinch zoom and drag pan;
  - larger hit targets (≥ 44 px);
  - no right-click or keyboard dependence (Esc, F-keys);
  - panel layouts for 16:9 and 4:3 tablets.
- **The web build is the stepping stone.** The asset diet, Compatibility renderer and web quality preset carry over directly to mobile.

## 6. Order of work after v2
1. Phases 0–1 (setup and the asset diet). Check: `.pck` ≤ 150 MB.
2. Phase 2 (renderer) and Phase 3 (platform behaviour). Check: it runs in Chrome locally and looks close to desktop.
3. Phase 4 (performance). Check: the budgets in §2 are met.
4. Phases 5–6 (package and QA). Check: Playwright passes and the blind critic has no blockers. Then show you the local build before anything is uploaded.
