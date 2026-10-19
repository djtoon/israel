# Web performance research: sharp UI on a Radeon 610M (Godot 4.7.1, Compatibility, nothreads)

Date: 2026-10-18. Research only: no Godot, browser or build was run.
Sources were Godot docs, the Godot source (`master` and `4.7` branches), GitHub issues and PRs, release notes, and the exported `build/web/out/index.js` / `index.wasm`.
Confidence: **H** = confirmed in source or official docs, **M** = strong evidence but not tested here, **L** = inference.

---

## 0. Ranked recommendations (expected impact on a 610M with sharp UI)

1. **Stop shrinking the canvas. Use `scaling_3d_scale` again, with a 6-line JS hook that fixes the real bug.** (H)
   - Why the scale "had no effect": a 4.5+ regression on Windows/ANGLE. When 3D is upscaled, Godot blits depth **and stencil** from the internal buffer to the target, and ANGLE's D3D11 backend upscales the stencil **on the CPU**.
     - This is issue #119317, "Web export - Performance tanks when Scaling 3D set to below 1.0". The reports include 160 to 27 fps, about 10x CPU, on Windows only.
     - It is fixed by PR #124310, which is in the 4.8 milestone and is **not** in 4.7.1 or 4.7.2.
   - The workaround: strip `STENCIL_BUFFER_BIT` in `blitFramebuffer` from the HTML head include (see §2.3). The game uses no stencil materials (grep: none), so this is safe.
   - Then set the "light" tier to keep the canvas at full devicePixelRatio and set `scaling_3d_scale` to 0.6–0.75 (bilinear). The 2D HUD keeps rendering at native canvas resolution (canvas_items stretch), so text stays sharp.
   - This recovers the 3D fill savings that the canvas shrink gave, without the blur.
2. **Cut the shadow passes. This is the biggest resolution-independent cost (kit buildings about 22 ms, mostly shadows, plus about 8 ms directional).** (H/M)
   - Kit buildings: `cast_shadow = OFF` on small kit buildings. Only landmarks and large blocks should cast.
   - Splits: 2 splits become `SHADOW_ORTHOGONAL` (1 pass) on the web tiers, with a tight `directional_shadow_max_distance`.
   - Atlas: `rendering/lights_and_shadows/directional_shadow/size.web=2048`.
   - Lowest tier: no realtime shadows. Use blob or contact shadows, extending the existing `veg_shadow.gdshader` multiply-blend approach to buildings.
   - Culling: buildings use `cull_disabled`, which doubles rasterization in both the shadow and main passes. Use `cull_back` on web wherever the meshes are closed.
3. **Make the terrain and water shaders cheaper on the web tier. The 21 ms terrain cost is fragment work, so scaling (1) helps it directly.** (M)
   - Terrain lighting: `diffuse_burley` becomes lambert, and `specular_schlick_ggx` becomes `specular_disabled` or a cheap specular.
   - Branches: sample textures outside branches, or use `textureLod`. FXC flattens branches that contain gradient-based samples, so you pay for both sides.
   - Static layers: bake overlays that change once per turn into a texture.
   - Water: `water.gdshader` reads `hint_screen_texture, filter_linear_mipmap`. That forces a per-frame back-buffer colour copy plus a mip chain at 1920x1080. On web, use `filter_linear` without mips, or fake the refraction with alpha.
4. **Cut the HUD CPU cost (about 15 ms).** (M)
   - `unit_flags.gd` calls `queue_redraw()` **every frame** and re-measures text (`UIKit.text_width`) per banner. Redraw only when the camera transform or banner set changes.
   - The theme sets `font_shadow_color` (alpha 0.6) for **every** Label. That draws each glyph twice. Disable it on web, or keep it only on titles.
   - Hide closed panels with `visible = false`, not with alpha or off-screen positions.
   - Avoid StyleBoxFlat `shadow_size` and anti-aliasing on the many small panels.
5. **Pre-warm shaders behind the HTML loading overlay, and drive the overlay from GDScript** (§5). This fixes the "frozen" feel. It is not an fps gain.
6. **Tell dual-GPU users how to use their discrete GPU** (§6). Check the adapter name; if it is an integrated GPU on a machine that could use a dGPU, show a one-line Windows Graphics settings hint. The page itself cannot force the dGPU.
7. **The Emscripten offscreen blit is real but small** (§2): about 1 ms or less of GPU time per frame. You can trim it (preserveDrawingBuffer false) or remove it (patch `explicitSwapControl` in `index.js`), but treat that as experimental and do it last. The 34% `getParameter` in the RTX profile is most likely the main thread **waiting on the GPU process**, not the blit itself.

---

## 1. Sharp 2D UI with a lower-resolution 3D world

### 1.1 Does `scaling_3d_scale` work in Compatibility? **Yes, since 4.3 (bilinear and, from 4.7, nearest).** (H)

The source path:
- **`renderer_viewport.cpp` `_configure_3d_render_buffers`:** on `gl_compatibility`, any mode other than bilinear or nearest falls back to bilinear, with the warning "MetalFX and FSR upscaling are not supported in the Compatibility renderer. Falling back to bilinear scaling." The internal size is `target * scale`, clamped from 0.1 to 2.0. Scaling turns off only when the scale is within EPSILON of 1.0.
- **`render_scene_buffers_gles3.cpp`:** with scaling active, it allocates an internal buffer. `rasterizer_scene_gles3.cpp` renders at `internal_size`, resolves MSAA into the internal buffer ("We can't combine resolve and scaling"), then calls `post_copy` to the target plus a depth blit from internal to target size.
- **The bug:** since stencil support (PR #80710, 4.5), that depth blit carries the stencil. On ANGLE/D3D11 (all Windows browsers), a scaled depth+stencil blit falls back to a CPU path: copy to staging, upscale on the CPU, re-upload.
  - PR #124310 author: "absolutely kills performance". At 0.1 scale it went from 350 to 7000 fps.
  - Reports in #119317 cover Windows 10 and 11 on AMD, NVIDIA and Intel, in Chrome, Edge, Firefox and Opera. Linux and macOS are unaffected.
  - **This explains the "no effect" measurement exactly.**
- **Related fix:** PR #124342 (4.8) also stops copying the stencil when depth is blitted to the back buffer (`hint_depth_texture`, SSAO). It removes a per-frame `glCheckFramebufferStatus` sync point too. On ANGLE it saved about 1.5 ms.
- **Mipmap bias:** with scaling, Godot auto-applies a mip bias of `log2(scale)`, which makes textures slightly sharper or shimmerier.
- **The 4.7 nearest mode** (GH-79731) costs about the same as bilinear and does not affect 2D.

Sources:
- https://github.com/godotengine/godot/issues/119317
- https://github.com/godotengine/godot/pull/124310
- https://github.com/godotengine/godot/pull/124342
- https://github.com/godotengine/godot/issues/124323
- https://github.com/godotengine/godot/pull/83976 (the original GLES3 MSAA and scaling)
- https://raw.githubusercontent.com/godotengine/godot/master/servers/rendering/renderer_viewport.cpp
- https://godotengine.org/article/dev-snapshot-godot-4-7-beta-1/

**Recommendation:**
- Ship the JS stencil hook (§2.3) and keep the canvas at full DPR.
- Light tier: `scaling_3d_scale` 0.6–0.7. Mid tier: 0.8.
- Re-measure. Expect terrain and water time to drop roughly with pixel count; shadow-pass time will not drop.
- Remove the hook when moving to 4.8, or cherry-pick #124310 and #124342 into a custom 4.7 template.

### 1.2 SubViewport at reduced size (the fallback if you don't want the hook). (H/M)

How it works:
- Use `SubViewportContainer` with `stretch = true` and `stretch_shrink = N`. It renders at size/N and draws at full size.
- **`stretch_shrink` is an integer only**: 2 means 0.5x, which is too coarse here.
- For 0.67, size a `SubViewport` manually (`size = canvas * 0.67`) and draw it with a `TextureRect` (`STRETCH_SCALE`, linear filter), or with a container whose `stretch = false` and a custom size.
- Because there is no internal-to-target upscale, the stencil bug never triggers.

Pitfalls:
- **Input:**
  - `SubViewportContainer` forwards input to the SubViewport and converts coordinates, including for `stretch_shrink`.
  - A `TextureRect` does **not** forward anything. You must call `sub.push_input(ev)` with coordinates scaled yourself.
  - Code that uses `get_viewport().get_mouse_position()` on the root, plus `camera.project_ray_origin`, must convert root to sub coordinates (`* sub.size / rect.size`).
  - `unproject_position` results come back in sub pixels, so HUD overlays like `unit_flags.gd` and `map_lens.gd` must scale them back up. This is the biggest refactor cost in this codebase.
- **World:** the Camera3D, WorldEnvironment and DirectionalLight must be inside the SubViewport, or share the world through `world_3d`.
- **Cost:** one extra full-canvas textured quad per frame (cheap), plus the render target's own memory.
- **MSAA:** set `msaa_3d` on the SubViewport, not on the root.
- **Transparency:** use `transparent_bg = false` (opaque is cheaper). Don't scale the container with `Control.scale`; the docs warn that it distorts.

Source: https://docs.godotengine.org/en/stable/classes/class_subviewportcontainer.html

**Recommendation:** use this only if the hook proves unreliable. `scaling_3d_scale` plus the hook needs zero scene or input changes.

### 1.3 Stretch modes, content scale and devicePixelRatio on web. (H)

- **The project now:** `allow_hidpi=true`, `stretch/mode="canvas_items"`, `aspect="expand"`, base 1672x941.
- **What that gives:** at 150% Windows scaling, Godot's JS sizes the canvas backing store to CSS size x `devicePixelRatio`, so 1280x720 CSS becomes **1920x1080**.
  - The exported glue has `getPixelRatio(){return GodotDisplayScreen.hidpi?window.devicePixelRatio||1:1}`, and `canvasResizePolicy:2` fills the window.
  - `canvas_items` rasterises fonts and 2D at that native size, so the UI is sharp.
- **`viewport` stretch mode** would render everything at the base size and upscale. That is blurry; don't use it.
- **The current light tier** shrinks the backing store (effectively DPR x 0.66), so the browser upscales **the whole canvas**, UI included. That is the blur.
- **Fix:** canvas stays at full DPR; only 3D shrinks (§1.1).
- **An alternative that keeps some blur:** `allow_hidpi=false`. It halves the pixels at 150%, but it blurs the UI too. Rejected.
- `screen_get_scale()` returns `devicePixelRatio` on web. `FEATURE_HIDPI` is not reported.

Sources:
- https://raw.githubusercontent.com/godotengine/godot/master/platform/web/display_server_web.cpp
- https://docs.godotengine.org/en/stable/tutorials/platform/web/html5_shell_classref.html (canvasResizePolicy 0, 1 and 2)

---

## 2. Emscripten offscreen framebuffer and the `getParameter` stall

### 2.1 Why there is an offscreen FB and a blit every frame. (H)

Godot's settings:
- `platform/web/detect.py` links `-sOFFSCREEN_FRAMEBUFFER=1`, with the comment "Allow use to take control of swapping WebGL buffers".
- `display_server_web.cpp` creates the context with `alpha = is_layered_allowed()`, `antialias = false`, `majorVersion = 2` and **`explicitSwapControl = true`**. It never sets `powerPreference`.
- `swap_buffers()` calls `emscripten_webgl_commit_frame()`.

What Emscripten does with them:
- Glue in `out/index.js`: if `explicitSwapControl && !renderViaOffscreenBackBuffer`, it sets `renderViaOffscreenBackBuffer = true`. That forces `preserveDrawingBuffer = true` and creates a hidden FBO.
- Every GL bind of framebuffer 0 is redirected to that FBO.
- On commit, `blitOffscreenFramebuffer` does `getParameter(SCISSOR_TEST)`, `getParameter(FRAMEBUFFER_BINDING)` and a full-canvas `blitFramebuffer` (COLOR only, NEAREST) to the real canvas.

Cost and interpretation:
- **Per-frame cost** at 1920x1080 is one colour blit plus the browser's extra copy, because `preserveDrawingBuffer:true` blocks buffer swapping. That is about 0.3–1 ms on an iGPU. (M)
- **The `getParameter` profile line:**
  - Chrome answers these state queries from client-side caches. A large self-time there usually means the main thread **blocked on the GPU process** at that point (a full command buffer, or a sync), so it marks a GPU-bound frame. (M)
  - Firefox's out-of-process WebGL makes `getParameter` a true sync IPC. Godot issue #118825 shows 58–60% in `getParameter` on Firefox at 4K on an iGPU. (H for that issue)
  - The ANGLE CPU stencil path from §1.1 runs in the GPU process and shows up on the main thread as exactly this kind of wait. Check whether the RTX profile had scale < 1 or MSAA plus a depth-texture shader. (L)

Sources:
- https://raw.githubusercontent.com/godotengine/godot/4.7/platform/web/detect.py
- https://github.com/emscripten-core/emscripten/pull/5581
- https://github.com/godotengine/godot/issues/118825

### 2.2 Can it be avoided without an engine build? Partly. (M)

- **There is no export option or template switch.** Every official web template is linked with OFFSCREEN_FRAMEBUFFER and creates the context with explicit swap. (H)
- **Trim it (low risk):** a `getContext` wrapper in `html/head_include` can force `preserveDrawingBuffer:false`, because Godot redraws the full frame on every commit. That removes the browser-side preserve copy. Test for black frames if low-processor mode is ever used. (M)
- **Remove it (experimental):**
  - Post-process `index.js` in `package_web.py`: replace `explicitSwapControl:HEAP8[attributes+25]` with `explicitSwapControl:0`.
  - Godot then renders straight into the canvas's default framebuffer (Godot's `system_fbo` is 0). `emscripten_webgl_commit_frame` returns an ignored error code, and the browser presents when the rAF callback returns.
  - This saves the blit, the two `getParameter` calls and an FBO.
  - Risks: a frame where Godot issues GL work without drawing could present a cleared canvas, and the patch is tied to the exact Emscripten glue string, so assert that it matched. (L/M)
- **Expected gain:** around 1 ms or less on the 610M. Do it after items 1–4.

### 2.3 The head-include hook (stencil fix plus attributes)

Put this in `html/head_include` or the custom shell, before `index.js` loads:

```html
<script>
(function () {
  var P = WebGL2RenderingContext.prototype, blit = P.blitFramebuffer;
  P.blitFramebuffer = function (a,b,c,d,e,f,g,h, mask, filter) {
    if (mask & 0x400) { mask &= ~0x400; if (!mask) return; }   // drop STENCIL_BUFFER_BIT: Godot #119317/#124310/#124342 (no stencil materials in this game)
    return blit.call(this, a,b,c,d,e,f,g,h, mask, filter);
  };
  var gc = HTMLCanvasElement.prototype.getContext;
  HTMLCanvasElement.prototype.getContext = function (type, attrs) {
    if (type === 'webgl2' && attrs) attrs = Object.assign({}, attrs, { powerPreference: 'high-performance' /*, preserveDrawingBuffer: false (test) */ });
    return gc.call(this, type, attrs);
  };
})();
</script>
```

This is the same approach the reporter of #124323 used for their workaround. Remove the blit part on 4.8.

---

## 3. WebGL 2 / Compatibility tips for iGPUs

- **Draw calls and MultiMesh.** (H/M)
  - In Compatibility, a MultiMesh is one instanced draw per surface per material per pass.
  - Culling is per MultiMeshInstance3D AABB, so one map-wide MMI is drawn whole in the main pass **and in every shadow split**.
  - Chunk MMIs spatially (per city or region block) so frustum and cascade culling can drop them.
  - Share materials across kit pieces.
  - Pre-joined meshes cut draw calls but cannot be culled individually.
  - Source: https://docs.godotengine.org/en/stable/tutorials/performance/gpu_optimization.html
- **Visibility ranges and HLOD.** (H)
  - Use `visibility_range_end` on detailed kit chunks, and a `visibility_parent` with a single merged low-poly city mesh (or MMI) for far zoom.
  - Use **fade mode Disabled**. Self and Dependencies force transparent rendering during the fade.
  - If you want soft transitions, dithering in the shader is cheaper than alpha.
  - Source: https://docs.godotengine.org/en/stable/tutorials/3d/visibility_ranges.html
- **Occlusion culling.** (H/L)
  - The raycast/Embree module builds for wasm32, so it is available on web.
  - It runs on the CPU, and on the nothreads template it runs on the main thread.
  - A top-down hex map has almost no occluders, so **don't use it**.
  - Sources: https://raw.githubusercontent.com/godotengine/godot/master/modules/raycast/config.py and https://docs.godotengine.org/en/stable/tutorials/3d/occlusion_culling.html
- **Shadows.** (H/M)
  - Compatibility draws the first shadowed DirectionalLight in the base pass. Each additional shadowed light adds a **full extra pass**. The game has one sun or moon light, which is good, so keep it that way: no shadowed omni lights for night cities.
  - Directional shadows re-render every frame. There is no cache in `_render_shadows`, and the moving sun would invalidate one anyway.
  - The cost is casters times splits, so these levers matter most:
    - splits become orthogonal (single);
    - a short max distance;
    - atlas size 2048 on web;
    - `cast_shadow` OFF on small meshes and small-building MMIs (split them into "casting" and "non-casting" MMIs);
    - `cull_back` on closed meshes;
    - blob, decal or contact-shadow quads for the lowest tier, as `veg_shadow.gdshader` already does.
  - A baked shadow texture on the terrain is viable for static landmarks if the sun moves slowly. Re-bake per hour step, not per frame. (L)
  - Source: https://docs.godotengine.org/en/stable/engine_details/architecture/internal_rendering_architecture.html
- **Shader cost.** (M)
  - ANGLE on D3D11 translates GLSL to HLSL and compiles it with FXC.
  - Branches that contain implicit-derivative `texture()` calls get flattened, so both sides execute. Use `textureLod`/`textureGrad`, or hoist the samples.
  - Branching on a uniform is fine. You can make web-only variants with the gdshader preprocessor (`#define WEB_LITE` in an include).
  - Use texture arrays freely; WebGL 2 supports them.
  - **`mediump` buys nothing on Windows desktop.** D3D11 runs at 32-bit regardless.
  - The cheapest wins in these shaders: drop `diffuse_burley` and GGX specular, and keep `cull_back`.
- **Texture formats.** (H/M)
  - Chrome and Edge on Windows expose `WEBGL_compressed_texture_s3tc` (+ `_srgb`) and `EXT_texture_compression_bptc`. ETC2 and ASTC are not available on desktop D3D11.
  - The project already imports S3TC/BPTC only (`import_etc2_astc=false`), which is correct. Make sure large 3D textures really are VRAM-compressed, not lossless. That saves bandwidth on a shared-memory iGPU.
- **Vertex-bound or fragment-bound?** (H)
  - The Godot docs' test: compare a small and a large render size. With the hook in place, A/B `scaling_3d_scale` 1.0 against 0.5:
    - the passes that drop are fill-bound (terrain, water);
    - the ones that don't are vertex, shadow or CPU-bound.
  - Spector.js gives a per-draw capture in the browser.
  - `RenderingServer.get_rendering_info(RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME / _PRIMITIVES_)` per pass shows draw-call bloat.
- **MSAA.** (M) The web tier uses MSAA 2x. With the scale at 0.67 and bilinear upscaling, try MSAA off on the light tier; the upscale blur already softens edges. MSAA plus depth or screen copies is what hits the slow ANGLE paths.

---

## 4. 2D HUD CPU cost in Godot 4

What costs CPU per frame (M, from renderer design and docs):
- **The canvas renderer walks every visible CanvasItem each frame** and rebuilds batches and instance data, even when nothing changed. Cost scales with visible items, draw commands and **glyphs**.
  - Command lists are cached until `queue_redraw()`, but batching is per frame.
  - Batching breaks on texture changes, custom materials and shaders, `clip_children` and CanvasGroup / BackBufferCopy (these force render-target copies).
  - 4.x Compatibility does have 2D batching.
- **Per-frame `queue_redraw()` on big custom-draw nodes** re-records every command, re-shapes and measures text, and rebuilds anti-aliased polylines (`draw_polyline(..., true)` generates extra geometry).
  - `unit_flags.gd` does this every frame. `map_lens.gd` does it whenever a lens is on.
- **Label shadows and outlines:** `font_shadow_color` with alpha above 0 adds a full extra glyph draw per Label; outlines add another. The theme turns the shadow on globally.
- **MSDF fonts** make outlines cheap and scalable, but they don't reduce glyph count. They're not needed here.
- **Text shaping:** `Label.set_text` returns early when the string is unchanged. Changing text every frame re-shapes it, so update only on change.
- **RichTextLabel** is heavier than Label for short text.
- **Containers** re-sort on child, minimum-size or visibility changes. The `_rebuild()` patterns (free all children, rebuild) in `history_ticker` and `notify_rail` are fine if they're rare. Make sure no per-frame path triggers them. `history_ticker._process` calls `get_global_rect()` every frame, which is cheap, but guard it with a dirty flag.

How to cut it:
- Redraw custom-draw overlays only when `camera.global_transform` or the data actually changed.
- Cache text widths per (string, size).
- `visible = false` for anything closed or covered.
- Drop the global Label shadow on web.
- Fewer StyleBoxFlat panels with `shadow_size` and anti-aliasing.
- Coalesce small labels into one custom-draw node.
- Measure with `Performance.get_monitor(OBJECT_NODE_COUNT)` and draw calls before and after.

Sources:
- https://docs.godotengine.org/en/stable/classes/class_label.html
- https://docs.godotengine.org/en/stable/tutorials/performance/gpu_optimization.html

---

## 5. Loading UX for Godot web

- **Progress:** `engine.startGame({onProgress: (cur, total) => …})` is called once per frame **during downloads only** (the wasm and pck, sized from `GODOT_CONFIG.fileSizes`). `total` can be 0 under chunked compression. (H)
  - After the download there is **no** built-in progress for WASM compile, engine init, scene load or shader compile.
  - `startGame` resolves when the engine has started, not when the game is ready.
  - Sources:
    - https://docs.godotengine.org/en/stable/tutorials/platform/web/html5_shell_classref.html
    - https://docs.godotengine.org/en/stable/tutorials/platform/web/customizing_html5_shell.html
- **Spinner during blocking:** Chrome and Firefox run CSS animations of **`transform` and `opacity` only** on the compositor thread, so they keep moving while the main thread is busy in WASM, engine init or GDScript. Promote them with `will-change: transform`. (H/M)
  - These break smoothness, because they need the main thread:
    - animating `width`, `left`, `background-position`, `box-shadow`, colours, or `@property`/conic-gradient angles;
    - SVG SMIL;
    - any JS/rAF-driven spinner or progress text;
    - layout-triggering updates.
  - The compositor shares the GPU process with WebGL. A long ANGLE/FXC shader compile in the GPU process can still stall compositor frames briefly. (M)
  - A determinate bar only moves when JS runs. During the blocking phases, show the spinner plus a phase label set **before** each blocking step.
  - Source: https://web.dev/articles/stick-to-compositor-only-properties-and-manage-layer-count
- **Engine phases from GDScript:**
  - Keep the HTML overlay up after `startGame` resolves.
  - In GDScript, call `JavaScriptBridge.eval("window.loadPhase && loadPhase('Building the map', 0.7)")` (or `get_interface("window").loadPhase(...)`) at each milestone.
  - Call `loadPhase('done')` after the first 2–3 frames of the real map are rendered, then fade the overlay with an opacity transition.
  - Yield a frame (`await get_tree().process_frame`) between phases so the browser can paint the label.
- **Shader cache on web:** WebGL 2 has no `getProgramBinary`, so Godot cannot persist compiled programs in IndexedDB. (H for WebGL; M that Godot has no web cache. A forum thread reports the shader-cache settings don't work on web.)
  - Compatibility compiles shader variants **lazily on first draw**, and there are no ubershaders in Compatibility.
  - Repeat visits benefit only from the browser's own GPU program and ANGLE blob disk cache.
  - Sources:
    - https://docs.godotengine.org/en/stable/tutorials/rendering/jitter_stutter.html
    - https://forum.godotengine.org/t/handling-particle-shader-compilation-lag-in-godot-4-web-compatibility-renderer/36170
- **Pre-warm:**
  - Behind the opaque HTML overlay (the canvas stays visible underneath it, not `display:none`), render 2–3 frames that include one instance of every material and mesh type: terrain, water, each kit material, trees, banners and particles.
  - Use the final tier's settings: shadows on, the same light count, fog, MSAA and scale. A different light or shadow state creates different variants.
  - Do day and night, since the light colour is uniform but the shadow on/off state may change variants.
  - This is the docs' "spawn in front of the camera hidden behind a full-screen element" advice.

---

## 6. `powerPreference: "high-performance"`

- **Godot:** it never sets `powerPreference` (Emscripten "default"), and there is no export option for it. You can inject it with the `getContext` wrapper in §2.3. (H)
- **Chrome and Edge on Windows:** the GPU process uses one adapter for the whole browser, and WebGL `powerPreference` has historically been honoured only on dual-GPU macOS. WebGPU's `requestAdapter` preference has been reported ignored on Windows.
  - The reliable switch is the OS: Settings > Display > Graphics > Chrome/Edge > "High performance", or the NVIDIA Control Panel, or the `--force_high_performance_gpu` flag. (M; no current release note says otherwise)
- **Firefox:** similar, and it honours OS GPU preferences. (L)
- **This project:**
  - A Radeon 610M is the iGPU in Ryzen 7045HX-class laptops, which usually ship with an RTX dGPU, so the 610M and RTX numbers may come from the same machine.
  - Inject the hint (harmless) **and** use `gfx_detect.gd`'s adapter name (`RenderingServer.get_video_adapter_name()` returns the ANGLE string, e.g. "AMD Radeon(TM) 610M").
  - When it's a known iGPU, show a dismissible tip: "For smoother play, set your browser to High performance in Windows Graphics settings."
- Sources:
  - https://groups.google.com/g/webgl-dev-list/c/gf0NHCFQkMM
  - https://issues.chromium.org/issues/40268366
  - https://discourse.threejs.org/t/running-webgl-renderer-on-discrete-graphics-card/18948

---

## 7. CPU-side web options in 4.5–4.7 (SIMD, threads, newer features)

- **WASM SIMD is on in our build.** (H)
  - It has been on by default since 4.5 dev 5; `detect.py` on the 4.7 branch has `wasm_simd` default True, adding `-msimd128`.
  - Verified in our official 4.7.1 `index.wasm`: SIMD-prefix (0xFD) opcode pairs occur about 120k times, against about 1k for a random-prefix baseline.
  - It helps CPU-bound code (physics, math, GDScript VM internals), about 1.5–2x in the article's honest range. It does nothing for GPU passes.
  - Source: https://godotengine.org/article/upcoming-serious-web-performance-boost/
- **Threads template plus itch "SharedArrayBuffer support" (COOP/COEP).** (H/M)
  - Rendering stays on the main thread either way: the WebGL context lives there.
  - What threads buy:
    - audio mixing off the frame loop (in nothreads, stream audio can garble when fps drops; sample playback, the web default, mitigates this);
    - real `Thread`/`WorkerThreadPool` parallelism (your minimap worker, any end-of-turn AI you move to a thread).
  - So for a render- and main-thread-bound game, expect **no fps gain**. A possible gain is end-of-turn time, if the sim is threaded.
  - The risks on itch:
    - the setting is experimental and relies on `COEP: credentialless`, which Safari and Firefox Android don't support;
    - cross-origin resources and embeds need CORP, and popups and links behave differently;
    - memory is capped at 2 GB (`WASM_MEM_MAX=2048MB`);
    - Godot 4.3 re-added nothreads precisely because of hosting headers.
  - **Keep nothreads.**
  - Source: https://godotengine.org/article/progress-report-web-export-in-4-3/
- **Newer web features in 4.6 and 4.7:**
  - 4.7 adds a `wasm64` build option (GH-102378). It is opt-in for custom builds; official templates are wasm32. It lifts the 4 GB limit but is slower and needs Memory64; not useful here.
  - No JSPI or loading/startup changes appear in the official 4.6 or 4.7 notes I could find.
  - There is **no official WebGPU** (Compatibility/WebGL 2 only). There is an experimental community fork, lpenguin/godot "4.7.2-webgpu" (not recommended for shipping).
  - 4.5 brought the final blit as a fragment-shader copy (PR #106267) and the stencil support that caused §1.1's regression (PR #80710).
- **4.7.2 (installed, 18 Aug 2026):** 57 fixes, none for web, Compatibility, ANGLE or 3D scaling. It's a safe drop-in, but there is nothing web-specific to gain. The fixes that matter (#124310 and #124342) are 4.8-milestone. Either use the §2.3 hook, or cherry-pick both into a custom 4.7 template if you ever build one.
  - Source: https://godotengine.org/article/maintenance-release-godot-4-7-2/
