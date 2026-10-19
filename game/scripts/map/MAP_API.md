# Map API (renderer → gameplay/UI)

Owner: renderer piece (`scripts/map/`). The map is presentation only. The sim owns state and pushes it in.

## Getting the API

```gdscript
var mv: MapView = get_tree().get_first_node_in_group("map_view")   # also: $"/root/Main/MapView", or main.map_view
```

It exists after `Main._ready()`. If you need it from a sibling's `_ready`, use `call_deferred` or `await get_tree().process_frame`.

## Coordinates

- Tiles are `(q, r)` in map.json's `pointy-odd-r` offset coordinates (`q` = column, `r` = row, row 0 = north).
- World space: hex size 1 (centre to corner), `x` east, `z` south. `TerrainMath.offset_center(q, r) -> Vector2(x, z)`.
- `mv.tile_world(q, r) -> Vector3` gives a tile's centre on the ground, e.g. for anchoring UI.

## Signals

| signal | when |
|---|---|
| `tile_clicked(q, r)` | left click on the map (not on a drag; HUD controls that stop the mouse event don't trigger it) |
| `tile_right_clicked(q, r)` | right click |
| `tile_hovered(q, r)` | hovered hex changed |
| `city_clicked(id)` | left click on a city banner or on a hex that holds a shown city (`id` = cities.json `id`) |

## Tiles

| call | notes |
|---|---|
| `highlight_tiles(tiles, color, layer := "default")` | `tiles` is `[Vector2i]` or `[[q, r]]`. Each tile gets a tinted fill plus a bright rim. Setting a layer replaces its previous contents. Layers drawn later sit on top. `color.a` scales the fill. |
| `clear_highlights(layer := "")` | `""` clears all layers. |

Highlights are drawn twice: tinted on the terrain and as bright screen-space hex rims drawn above buildings, so worked tiles stay visible inside dense cities.
| `tile_info(q, r) -> Dictionary` | the map.json tile (`terrain`, `feature`, `region`, `elevation_m`, `resource`, `river`, `coast`, `lat`, `lon`) |
| `city_at(q, r) -> Dictionary` | the city shown on that hex, or `{}` |
| `focus_tile(q, r, zoom := -1)` | smooth camera move; `zoom` 0.3 (far) to 3.0 (close); -1 keeps the current zoom |

## Cities

| call | notes |
|---|---|
| `cities() -> Array` | localities shown at the current date: `{id, name, name_he, q, r, pos, pop, size, kind, control, status, status_note, display_pop, founded}` |
| `focus_city(id, zoom := 2.0)` | smooth camera move to a city |
| `force_city(id, on := true)` | show a real locality from now on even before its historical founding date (player founded it early); triggers an incremental map update |
| `set_city_info(id, pop = null, name = null, badge = null)` | Overrides the banner: the number in the circle, the name, and the badge. `null` leaves a field as it is. Overrides persist across date changes. Badges: `israel`, `palestine`, `jordan`, `egypt`, `syria`, `lebanon`, `hamas`, `contested`; append `_beyond_lines` (e.g. `israel_beyond_lines`) for the dashed "Israeli-controlled beyond the 1949 lines" ring. |

Without overrides, banners use cities.json: the name and control come from `status[]` at the current date, and the number is derived from the population. Tel Aviv and Jaffa show separately until April 1950. Jerusalem is divided from 1948 to 1967.

## Units

| call | notes |
|---|---|
| `show_unit(id, q, r, model, yaw_deg := 0, tint := Color.WHITE, ring := Color(0,0,0,0))` | `model` is a MANIFEST.json id (`unit_palmach_infantry`, `unit_merkava`, ...). Uses hex scale and the manifest's `yaw_fix`. `tint` multiplies the model colours; a `ring` colour with alpha > 0 draws a faction disc under the unit. Re-showing an existing id replaces it. |
| `move_unit(id, q, r, seconds := 0.6)` | walks hex by hex along the straight hex line from the unit's current hex (no teleporting), facing each leg; `seconds` is the minimum, ~0.28 s per hex, capped at 2.4 s. A walking bob plays while moving. |
| `remove_unit(id, instant := false)` | the unit dissolves out over ~0.45 s (dithered fade + sink + glow). `instant := true` skips it (used internally when a unit is re-shown). |

## Date and camera (on the root node, group `"game"`)

- `set_date(turn, force := false)`: turn 1 = Q2 1948. Updates the date-dependent map (which localities exist, names, control, borders, skyline, landmarks, ports). Incremental: only hexes whose city changed are rebuilt (a typical quarter rebuilds a handful of hexes in ~100-200 ms; banner-only changes cost nothing). Redevelopment by era is staggered per hex over 8-year windows. The rebuild is deferred about 0.15 s.
- `set_camera(x, z, zoom)`: world units.

## Map labels vs HUD

City banners and resource pins are drawn by `MapLabels` (`scripts/map/map_labels.gd`, on CanvasLayer 1, below the HUD on layer 2). Labels skip anything that would overlap a HUD panel. The default panel rects follow the current HUD layout. If the HUD layout changes, set `main.overlay.occluders = [Rect2, ...]` (screen pixels).

## Demo

`bash tools/shot.sh out.png --api-demo` shows highlight layers, two units and a banner override around Tel Aviv.

## Banner hit-testing

`main.overlay.banner_hits` is `[{rect: Rect2, id}]` for the banners drawn this frame (top-most first); `main.overlay.banner_at(screen_pos) -> id` returns `""` if none. Banner clicks already emit `MapView.city_clicked`.

`set_city_info(id, pop)` sets the number in the banner circle and survives date changes.

## v2 hooks (district lens, citizen management)

| call | notes |
|---|---|
| `set_tile_labels(entries, layer := "labels")` | `entries` = `[{q, r, label: String, color: Color}]` (or `tile: Vector2i` instead of q/r). Each tile gets a tinted fill + rim in `color` and a small badge with `label` (e.g. `"+3"`, the adjacency bonus) at the hex centre. Replaces that layer's contents. Rims and badges are screen-space, drawn above buildings. |
| `clear_tile_labels(layer := "")` | `""` clears every label layer (and their tints). |
| `set_worked_tiles(worked, locked := [], layer := "worked")` | `worked` / `locked` = `[Vector2i]` or `[[q, r]]`. Worked tiles get a blue citizen medallion, locked ones a gold medallion with a padlock. A tile in both lists shows as locked. Replaces that layer. |
| `clear_worked_tiles(layer := "")` | `""` clears all worked layers. |

Typical use: district lens: `mv.set_tile_labels(sites.map(func(s): return {"q": s.q, "r": s.r, "label": "+%d" % s.bonus, "color": Color(0.4, 0.9, 0.5, 0.6)}), "lens")`, then `mv.clear_tile_labels("lens")` on close. Citizens: `mv.set_worked_tiles(worked, locked)` then `mv.clear_worked_tiles()`. Combine with `highlight_tiles` for the city's tile ring (`workable` tiles in another layer).

## Terrain notes

- Makhteshim (`natural_wonders` kind `crater`) are carved analytically from an oval fitted to their hexes (`TerrainMath.crater_carve`, mirrored in `hexcommon.gdshaderinc`; uniforms `crater_a/crater_b` set in `TerrainRenderer.set_common`). Ramon: ~40 km x 10 km, SW-NE, ~850 m rim over a flat, multicoloured floor.
- Military-control (security zone etc.) overlay: light tint plus a thin dashed edge; deliberately subtle.

## v3 unit animation hooks (tweens and a shader only, no skeletons)

| call | notes |
|---|---|
| `attack_unit(attacker_id, target, ranged := false)` | `target` = a unit id (String) or a hex (`Vector2i`). Melee: a lunge 40% of the way and back. Ranged (flag, or any boat / jet / tank / Iron Dome / truck): a recoil plus a muzzle flash at the front. After 0.18 s an impact flash pops on the target and, if a unit stands there, `hit_unit` plays on it. |
| `hit_unit(id)` | damage feedback: a 0.25 s shake plus a red-white glow (`flash` instance uniform in `artmodel.gdshader`). |
| `kill_unit(id)` | same as `remove_unit(id)`: the death fade. Call it instead of `remove_unit` when the unit died (the fade is also the default, so a unit that vanishes from the sim fades rather than pops). |

Idle motion runs automatically in `MapView._process`: troops and workers breathe-bob, vehicles sway faintly, boats rock on the swell (roll and pitch), jets hover-drift. It only touches the unit's first child (the model), never the holder the move tween drives, and costs one small loop over the shown units. Combat is not detected by the map: the UI/sim calls `attack_unit` then `kill_unit` / `hit_unit` when it resolves an attack.

## v3 hero buildings

Metre-scale landmark models listed in `CityBuilder.LANDMARKS` (manifest `era` gates the year): `v3_king_david_hotel` (1931, Jerusalem), `v3_shalom_meir_tower` (1965, Tel Aviv), `v3_yad_vashem_museum` (2005, Jerusalem), `v3_jaffa_clock_tower2` (1903, Jaffa). Positions are real lat/lon.

## Graphics: SD / HD / HD+ (render-hd, hdplus-port)

Independent of the Low/Medium/High preset. `[graphics] mode = "sd" | "hd" | "hdplus"` in `user://game.cfg` (default `sd`); Settings → "Graphics: SD / HD" (options SD, HD, HD+) switches live (`GameSettings.graphics_hd` / `graphics_plus` → `GameSettings.apply_graphics_mode` → `HDRender.apply(game, on)` → `HDPlus.apply`). Command line: `--quality=sd|hd|hdplus` (or `--graphics=...`) overrides the file. `Quality.hd` is true in HD and HD+, `Quality.plus` only in HD+ (`Quality.is_hdplus()`). In HD and HD+, `Quality.current()` returns the `hd` preset (4 shadow splits, tree shadows, full art range; tree shadows and the art range follow on the next start).

SD renders exactly as before: every HD change sits behind the global shader uniform `hd_mode` (project.godot `[shader_globals]`, 0 in SD) or is applied only by `HDRender` when HD is on. An SD start never touches the environment.

What HD changes (`scripts/map/hd_render.gd`, all rendering, no model changes):
- Sun: warmer, lower (`-25°`), PCSS soft shadows (`light_angular_distance 0.5`, soft-shadow quality High), 4 blended splits. Shadow range and haze are zoom-adaptive (`HDRender._on_cam_moved`): full haze and 30-unit shadows close in, almost no haze and no tree shadows from the far zoom, so the map stays readable.
- GI: SSIL (screen-space bounce) plus a tuned sky ambient. SDFGI was measured (`--hd-sdfgi`): +5 ms average and spikes to 45 ms while panning at 1080p, below the 30 fps bar, so it is off by default.
- Subtle SSAO (small radius, `light_affect 0.15`), MSAA 2x, debanding.
- AgX (exposure 1.08), restrained soft-light glow, distance fog with aerial perspective, saturation 1.25 / contrast 1.13 and a 1D colour-grade curve (cool shadows, warm highlights).
- Terrain: generated detail maps `assets/textures/hd/terrain_*_nrm.png` (RGBA = normal xy, cavity AO, roughness; made from the existing textures by `scripts/map/hd_gen_maps.py`), kit paving normals in towns, a drier Mediterranean palette (straw grass, olive greens, terra-rossa soil, pale stones), reef rocks on the shallow seabed (`hd_rocks()` in `hexcommon.gdshaderinc`), wet sand and kurkar outcrops on the shore.
- Sea: `water_hd.gdshader` replaces `water.gdshader` (same grid and borders): ripple normals (`hd/water_ripple_n.png`), sky reflection, sun glitter, turquoise → navy depth colour, refraction passing the lit seabed through as emission, foam measured in world distance from the waterline (contact band, rolling surf lines, foam on rocks), small whitecaps. The hex grid on water is drawn stronger than in SD.
- Buildings: the kit's baked `kit_*_ao.png` maps, a contact shadow at the street, roughness variation; art-kit models and GLBs get texture-cavity AO and a ground contact shadow.
- Vegetation: per-plant colour variety, warm back lighting, darker bases, foliage normals softened toward the sky.

HD pass 2 additions:
- Rocky shoreline: `HDRender.build_shore()` places EXISTING props only (MeshKit.rock boulders as in SD's CoastRocks, plus the art-kit `shore_rocks_small/medium` and `shore_reef_flat` ledges) along the waterline of rocky coasts: Jaffa, the Sharon kurkar (lighter), Carmel, Akko, Rosh HaNikra and northward (`_rockiness`), and the Gulf of Aqaba (light). The southern coast stays sandy. Node `Map/HDShore`: built on the first HD switch with its own seeded RNG, MultiMesh chunks, `visibility_range_end` 26, hidden in SD.
- Water: intersection foam from the depth texture wraps anything that meets the surface (boulders, ledges, quays, hulls); a teal shelf about twice as wide, then navy; slow large-scale colour patches and wind streaks on the open sea.
- Wet waterline band on rocks, quays and hulls (`props.gdshader`, `artinst.gdshader`).
- Ground: more golden and saturated; a rotated larger-scale second texture sample breaks up the texture grain (`tex_mix`).
- Vegetation: crowns facing the sun are lighter (global `hd_sun_dir`, set by HDRender), with stronger back light and a warm rim.
- Buildings: sunlit stone and plaster are a touch warmer and brighter.
- Far zoom: the sun climbs from -25° to -50°, sun energy drops, and sky ambient and SSAO soften (`_on_cam_moved`), so lee slopes no longer streak.

HD+ effects (ported from the HD lab, `build/hd_lab/HD_LAB.md`, approved 2026-10-14; the HD+ mode = HD plus these). Code: `scripts/map/hdplus.gd` (class `HDPlus`, called by `HDRender.apply` and `HDRender._on_cam_moved`; the season follows `TerrainRenderer.apply_date`; `HDPlus.active` = HD or HD+, `HDPlus.plus` = HD+) and `scripts/map/hdplus.gdshaderinc` (global uniforms `hdp_*` in project.godot `[shader_globals]`, all 0 in SD, so SD is unchanged; in plain HD only `hdp_terrain = 0.5`, the HD bug fixes below). Procedural textures `assets/textures/hd/hdp_clouds.png` and `hdp_caustics.png` (`scripts/map/hdp_gen_maps.py`).
- `dof`: tilt-shift (`CameraAttributesPractical`) focused on the ground at the screen centre; strongest at strategy zoom, light at city zoom. 2D labels, banners and flags stay sharp. Gentler than the lab (2026-10-14): the sharp band reaches about a third of the focus distance beyond the focus and the blur amount is lower, because the lab's setting made the far blocks and towers soft at city zoom (Tel Aviv 2023, zoom 2.2).
- `clouds`: drifting cloud shadows (`hdp_cloud()`) on terrain, sea, vegetation, buildings, art models, dioramas; applied before the grid, borders and highlights.
- `caustics`: seabed caustics in the shallows, faded with depth and camera distance.
- `season`: the quarter (map date: Feb winter, May spring, Aug summer, Nov autumn) sets sun colour, pitch and energy, haze, saturation, contrast, exposure and a tinted grade; winter greens and summer dries the ground and foliage. Spring = HD as before. Summer haze is toned down from the lab (fog x1.2, a less sandy fog colour) so the sea stays blue.
- `terrain`: height-blended rock on slopes, terra-rossa / scree at the slope foot. The HD bug fixes are in HD and HD+ (`hdp_terrain >= 0.5`): a per-pixel normal from the analytic height on steep ground (the interpolated vertex normals of the 0.16-unit mesh made a sawtooth rim and diagonal streaks on walls one or two triangles wide), triplanar rock normals and cavity on steep faces, Makhtesh Ramon walls (critic v3 B3: planar normals and cavity stretched into dark stipple and streaks; now a broader triplanar detail with lighter cavity, warm bounce light, warm strata over more of the desert walls, strata from the per-pixel height so they follow the real contours) and the far-zoom grass (B7: the field patchwork read as a blocky checkerboard; it fades with camera distance). Pass 2 of the Ramon fix (hdplus-port, 2026-10-14): the makhtesh walls are painted from the analytic crater outline (`crater_sd`: a pale limestone cap, soft red / ochre / white sandstone bands from the per-pixel height, a talus apron), because at about 40 degrees they were too gentle for the slope-keyed strata and the desert / desert-hills hex albedo showed through in hex-long grey blocks; their shading normal comes from the height without the old per-hex `cliff_edges` steps (`terrain_height_k(p, false)`, shading only, the geometry and the CPU height are unchanged) and is tilted toward the sky, so the wiggly walls no longer flip in and out of the low HD sun in hard columns; the rock normal detail on them is faint (it speckled at the light terminator) and matte.
- `foliage`: gust-wave wind on MeshKit trees / palms and art-kit `veg_*` trees (`ArtKit` sets `is_veg`), plus translucency in HD's warm back-light colour (the lab's yellow-green tint made palms lime) and a forward-scatter glow when looking toward the sun.
- `decals`: worn road edges, patched asphalt, gutter grime, field-edge tracks, wet sand with a moving swash line; rain streaks and splash dirt on kit and art-kit buildings (not shore rocks, `is_shore`).
- Not ported (lab verdicts): engine SSR / water SSR (+0.5-1.1 ms for faint reflections at this camera pitch: dropped rather than tuned), volumetric fog, TAA.
- Upscaling: Settings → "Upscaling (faster): Off / FSR 2" (`[graphics] upscaling = "off" | "fsr2"`, `GameSettings.upscaling`, `Quality.fsr`; default off). HD and HD+ only: FSR 2 at 0.77 render scale, sharpness 0.35, MSAA off (FSR 2 has its own temporal AA); `HDPlus.apply_upscaling` switches live. `--fsr` / `--fsr=off` override; `--shot=` captures ignore the saved value.
- Testing flags: `--fx=a,b` (HD+ with exactly these effects), `--fx=none` (HD+ without effects = HD), `--fx-off=a,b`, `--season=winter|spring|summer|autumn`.
- Perf / A-B harness `scripts/map/hd_cycle.gd`: `--hd-cycle=hd;hdplus;sd;hdplus+fsr;hdplus-dof#x,z,zoom --hd-out=C:/abs/prefix_ [--hd-pan] [--no-hud]` (with `--quality=hd --shot=<any>.png --frames=100000`) switches configurations live through the Settings path (`GameSettings.apply_graphics_mode`, never saved) in one run, prints `hd-perf[...]` GPU/CPU ms (static, and panning with `--hd-pan`) and saves `<prefix><index>_<cfg>.png`.
- Measured 2026-10-14 14:07-14:27 (after the SD / HD / HD+ split), RTX 5070 Laptop, 1920x1080 window (2205x1240 render), Jaffa 1948 `--cam=28.6,76.5,2.4`, `hd_cycle.gd` GPU time, static / panning average (worst frame): SD 17.1 / 17.7 ms (58 / 56 fps; switched live from HD); HD 25.2 / 26.1 ms (27.7) = 40 / 38 fps; HD+ 25.3 / 26.4 ms (27.7) = 40 / 38 fps, and 26.1 / 28.6 ms (30.9) = 38 / 35 fps in a second, warmer run after a live SD -> HD+ switch; HD+ with FSR 2 21.7 / 23.8 ms (27.5) = 46 / 42 fps. HD before the port was 25.6 / 26.7 ms. Ramon (`--cam=31.7,157.5,1.4`, 1280x720 window): HD 15.1 ms, HD+ 15.9 ms.

Map fixes 2026-10-14 (both modes): the modern airport terminal landmark (`lm_airport_terminal_nb`) appears from 2004 (Terminal 3) at fit 0.8, so 1948 Lydda no longer shows a white slab at the far view (critic v3 B9); the Shalom Meir Tower model's stray 15 m generator spike above the roof (the "red figure", B9) is cut away by `artmodel.gdshader` `clip_top` (`CityBuilder.CLIP_TOP`).

Frame time: `--perf` prints GPU/CPU ms averaged over 120 frames (independent of the 30 fps cap); `--perf-pan` pans the camera while sampling. Example: `tools/godot.sh --path /c/civ/game --windowed --resolution 1920x1080 -- --shot=out.png --cam=28.6,76.5,2.4 --no-hud --frames=230 --perf --quality=hd`. Measured 2026-10-13 on the RTX 5070 Laptop GPU with a 1920x1080 window at the default camera. After HD pass 2: SD 15.6 ms (about 64 fps); HD 22.3 ms (about 45 fps) static; HD 23.6 ms average (about 42 fps) while panning, with one 40 ms spike.

## v5 trees (v5-trees, 2026-10-16)

All vegetation (terrain woods, maquis, orchards, oases, wadis, and the town street trees) is built by `TreeKit` (`scripts/map/tree_kit.gd`): stylised procedural species made of tapered trunk / branch tubes and painted leaf-cluster alpha cards from one atlas, `assets/models/vegetation/veg_atlas.png` (built by `assets/_pipeline/veg_atlas.py` from `tools/gen.py image` paintings in `assets/_pipeline/veg_src/`). The old `MeshKit` blob trees and the v1 image-to-3D `veg_*.glb` (28k-54k faces, never used on the map; only `scripts/art/art_preview.gd` shows them) are no longer used by the map.
- Species (`TreeKit.KINDS`): `pine` (Aleppo pine, umbrella crown on a leaning trunk), `broad` (oak / carob; ficus and plane in towns), `cypress` (dark flame column), `olive` (twin gnarled trunks, silver-green crown), `citrus` (dense dark crown with fruit), `palm` (date palm: ringed curved trunk, arching V-folded fronds, dates), `palm_cluster` (oases), `fanpalm` (Washingtonia: tall slim trunk, dry-frond skirt, fan head; town streets and promenades), `eucalyptus` (pale trunk, tall hanging crown; low plains), `oleander` (northern streams), `bougainvillea` (gardens), `acacia` (umbrella thorn; Negev / Arava wadis). Date groves on desert orchards.
- `MeshKit.pine()` etc. return `TreeKit.mesh(kind)`; any mesh with meta `tree_kind` passed to `TerrainRenderer.mm()` becomes, per 8-unit chunk, a near LOD, a far LOD and a ground-shadow chunk (`TreeKit.add_lods`), all sharing the instance data. LOD 0 (HD near, about 100-370 triangles), LOD 1 (SD near, fewer cards), LOD 2 (far, both modes, 34-120 triangles). Ranges: HD near < 18 units, SD near < 15 units (AABB centre of the chunk; near and far overlap by 0.25 units each side, with no visibility-range margins: a margin is a hysteresis band, and on a cold start with a still camera the chunks inside it drew neither LOD), ground shadows < 30. A live SD <-> HD switch swaps the near meshes and ranges (`TreeKit.sync_mode`, polled by `TerrainRenderer._process`).
- v5 fix (v5-trees-fix, 2026-10-17): broadleaf / oak, olive, citrus, eucalyptus, the shrubs, the acacia and the pine's umbrella are built on opaque domed clumps (`Builder.dome`: a lumpy ellipsoid with a flattened, darker underside, painted with the middle of the species' leaf cell, `UV2.y = 1` = solid whatever the painted alpha), 2-3 per crown (`_clumps`, scaled by `TreeKit.CROWN` = 1.3; the pine's umbrella x1.22; the far LOD a further x1.1), with leaf cards on their upper surface for a leafy outline; so no ground shows through a crown at any LOD. The far LOD has flatter shading and one mid-tone per tree. Olive is a rounder silver-green; eucalyptus a fuller, lower grey-green crown.
- Shadows: trees cast no shadow-map shadows in any mode (small casters came out as a dithered screen-door under the soft-shadow filter). Each tree draws its own ground shadow instead (`TreeKit.shadow(kind)`, `veg_shadow.gdshader`, `blend_mul`): a contact patch at the foot, a trunk stripe and the crown's shadow, an ellipse cast along the real light (`TreeKit.sync_light`, every frame from `TerrainRenderer._process`: the Sun node's direction, the sun by day and the moon by night; strength = DayNight's light factor `lk`, so about 0.27 by moonlight and 0 at the sun / moon switch), draped on the terrain on the GPU (`hexcommon.gdshaderinc` `terrain_height`; the shadow materials get the hex textures through `TreeKit.bind_terrain` -> `TerrainRenderer.set_common`). Per-species shape: `TreeKit.SHADOW`. None inside HD+ cloud shadows; lighter in dense woods (the tint alpha `INSTANCE_CUSTOM.a` = the hex's tree density, set in `_veg_init`) so overlapping shadows do not pile up. Quality's `tree_shadows` no longer matters for trees.
- `foliage.gdshader`: alpha-tested cards with a per-mip alpha boost (`mip_keep` 0.8), crown-spherical normals leaning to the sky, baked AO, custom `light()` (wrapped diffuse and softened self-shadowing on leaves, so crowns never go black against the sun). Every mode: lush leaves (saturation x1.1 near, x1.3 far; value x1.08 near, x1.2 far; a fresher green `leaf_hue`; far = `far_range` 9-20 units from the camera), where the painting also flattens toward its local mean (one mid-tone, no speckle); by moonlight the plain colour, a little desaturated toward the moon's blue. HD: the colour variety, darker foot (both less far), sunlit crowns, cloud shadows and back light of the old props path; HD+: gust wind with leaf / frond-tip flutter (`UV2.x`), translucency and forward glow, season tint (`hdp_season`). SD: no translucency, no rim. Glow and translucency fade at night (`dn_night`).
- Vertex format: `COLOR.rgb` = colour x AO (sRGB), `COLOR.a` = leaf mask, `UV` = atlas, `UV2.x` = flutter weight, `UV2.y` = solid (domes). Every trunk reaches 2 m below the ground, so trees never float on slopes.

## v5 day and night (v5-daynight, `scripts/map/daynight.gd`)

A real-time clock (`DayNight.hour`, 0..24) on top of SD / HD / HD+: sun (by night the same DirectionalLight3D is the moon, compass 235°, 45° up; no extra lights), ambient, sky colours and stars (`ProceduralSkyMaterial.sky_cover`), fog / haze, exposure and grade, plus three shader globals: `dn_lights` (lit windows in building / artinst / artmodel, street lamps and the warm town glow in terrain, harbour lamps on quays, town lights reflected on the HD sea), `dn_night` (darkness: no warm cliff bounce or foliage glow, a deeper navy sea) and `dn_glint` (the HD sea's glitter: sun, gold at sunset, the moon).
- Everything is relative to the mode's own look: at noon every blend weight is 0 and every multiplier 1, so noon is the accepted SD / HD / HD+ look. Writers of base lighting bracket their writes with `DayNight.begin()` / `DayNight.end()` (HDRender.apply, HDRender._on_cam_moved, HDPlus.on_date); the HD+ season applies under it.
- v5-daynight-fix (critic v5 D1-D4): the night grade of surfaces is in `scripts/map/daynight.gdshaderinc` (included by terrain / building / artinst / artmodel; it declares `dn_night`). `dn_k()` = smoothstep(0.2, 1, dn_night), so noon, sunrise and the golden hour are untouched. `dn_land()` compresses linear albedo luminance above 0.095 with power 0.14 and keeps 42 % saturation (pale desert and stone no brighter than the green land, grey-blue, not olive); `dn_wall()` / `dn_roof()` do the same for buildings plus x0.72 / x0.56 (walls about 55 % darker, roofs darker still). Windows: `dn_window()` deep warm (on screen about #f0b880, AgX washes paler colours to white), `dn_lit_share()` 30-60 % lit per building (a per-building hash, no flicker), glass towers light whole floors in three-bay runs, old stone / plaster houses get one small procedural window per storey x bay cell (villages read as lit), `DN_BOUNCE` a faint amber wash on lit walls. Terrain street lamps light the ungraded (day) albedo, so they keep their strength; the grade runs before the grid, borders and highlights. SD far zoom keeps 40 % of the field patchwork (was 20-30 %). Night: environment saturation x0.72 (was 0.6), ambient (0.28, 0.31, 0.52), moon shadow opacity x0.5 (`sho`). Dawn: lavender sky / pink horizon, rose-gold sun, less haze (fog x1.1), lower sun (el 0.38); the SD sea x(0.70, 0.80, 0.76) and its sky reflection x0.75 at dawn via the new global `dn_sea` (vec4, rgb = colour x, a = specular x; (1, 1, 1, 1) by day, water.gdshader).
- Keys: pre-dawn blue hour 5:24, sunrise ("dawn") 6:06, golden hour ("sunset") 17:45, dusk 18:36, night 19:24-4:36; the sun / moon switch happens at 5:30 and 18:27 with the light off. The sun rises in the east-south-east and sets in the west-north-west, never below about 10° while lit (long shadows, readable ground).
- Settings → Display: "Time of day" (Day and night (real time) / Dawn / Noon / Sunset / Night), "Day length" (4 / 8 / 16 minutes, default 8), "Pause the clock". `[graphics] time_of_day`, `day_length`, `clock_paused` in user://game.cfg (`GameSettings`, live via `GameSettings.apply_daynight`). A new game starts the clock at noon.
- Captures and tests: `--shot=` / `--ui-test=` fix noon; `--time=dawn|noon|sunset|night|<hour>` fixes any time, `--time=cycle` lets it run; `--daynight=off` never touches the lighting. hd_cycle.gd: `cfg@time` (e.g. `hdplus@night#x,z,zoom`, `@off`), `--hd-quick` (shots only), `--hd-pan-only`, `sd-medium` / `sd-low` / `sd-high`. Check: `--ui-test-daynight` (scripts/ui/ui_test_daynight.gd).
- Cost, 1920x1080 window (2205x1240 render), Jaffa pan, GPU ms (30 fps cap): HD+ 26.0 off / 26.3 noon / 26.7 night; HD 25.0 off (night = off within noise at a 20 fps cap); SD medium 16.6 off / 16.6 noon / 17.8 night.


## perf60: 60 fps by default, the graphics tiers, the detector, the stutter fixes (2026-10-18)

Players reported stutter: HD / HD+ ran at about 38-41 fps at 1080p on the RTX 5070 Laptop GPU, which with vsync at 60 Hz alternates 60 / 30 fps frames (judder); date changes froze the map for 1-6 s on the main thread.

**Frame pacing.** Settings → Display "Frame rate": `60 (recommended)` (default: vsync on and `Engine.max_fps = 60`), `30, battery saver`, `Unlimited` (no cap, no vsync). `[graphics] fps = "60" | "30" | "unlimited"` (`GameSettings.fps_mode`, `GameSettings.apply_fps`). A command-line `--max-fps` (tools/godot.sh's 30 fps cap for agent runs) is never raised; headless runs stay uncapped.

**Graphics tiers** (`scripts/map/gfx_tier.gd`, class `GfxTier`): one ladder from the richest look to the cheapest; a tier is a mode (SD / HD / HD+), its SD preset and a few levers on top (`ssil`, `ssao`, `splits`, `shadow_k`, `pcss`, `msaa`, `fxaa`, `scale` (FSR 1 render scale), `glow`, `fx` (HD+ effects), `tree_k`, `art_mid`, `shadow_proxy`, `shadow_far`). The top of each mode has no levers, so it looks exactly as before.

| tier | label | what it is |
|---|---|---|
| `hdplus` | HD+ | HD+ as accepted |
| `hdplus_lite` | HD+ lite | HD+ without SSIL, PCSS soft shadows, depth of field and caustics |
| `hd` | HD | HD as accepted |
| `hd_fast` | HD fast | HD at 0.77 render scale (FSR 1 with gentle sharpening 1.0: it compiles at once, unlike FSR 2's first use; the default sharpening made facades grainy), FXAA instead of MSAA, no SSIL / PCSS, 2 shadow splits, kit-building shadows from the far LOD |
| `sd_high` / `sd_medium` | SD high / SD medium | the SD presets as before |
| `sd_low` | SD low | SD low preset, mid LOD from 5 units, shadows from the far LOD |
| `sd_min` | SD low, reduced resolution | SD low at 0.67 render scale, FXAA, mid LOD from 4 units, near trees x0.7 |

`[graphics] tier = "<name>" | "custom"` and `detected_tier` in user://game.cfg (`GameSettings.gfx_tier`, `.detected_tier`). Settings → Display "Graphics preset" picks a tier (applied live, `GfxTier.apply_live`) and has "Detect best settings"; changing Graphics quality, SD / HD or Upscaling makes the preset "Custom" (no levers). Restore defaults goes back to the detected tier. `--tier=<name>` forces one for a run (captures and tests ignore the saved tier unless `--tier` is given). `hd_cycle.gd`: `t-<tier>[+lever=value...]` measures a tier (e.g. `t-hd+ssil=0+splits=2`); `--hd-settle/--hd-measure/--hd-converge=N`, `--hd-dump` (every frame's GPU ms), `--hd-heavy` (the heaviest geometry, by category, with shadow casting), and each config prints primitives / draw calls (visible and shadow) and median / p95 / spike-trimmed p95.

**Cheap wins (every mode, same look):**
- The terrain plane (2.4 million triangles, one mesh, never culled, a heavy vertex shader run in the depth pre-pass and the colour pass) is cut into 96x96-quad tiles (`TerrainRenderer.TERRAIN_TILE`), every vertex where it was: SD medium at Jaffa 17.1 → 8.4 ms, HD 24.2 → 16.1 ms. `--terrain-one` restores the single plane (A/B).
- Kit-building LODs (`ArtKit.build_far`): the generated models are split along their texture seams, so meshoptimizer stopped after one halving (an old-town house kept 26,000 triangles; old towns held millions, drawn again in every shadow split). Welded by position they simplify freely: a mid LOD (~30 %) and a far LOD (~10 %). Chunks draw the full model up to `CityBuilder.ART_NEAR` (12 units, chunk centre) and the far LOD beyond; the near range casts its shadows from the mid LOD (a shadows-only twin, `shadow_proxy`): Tel Aviv 2023 HD shadow triangles 46 M → 19 M, GPU 24.8 → 18.0 ms, no visible change. The LODs are built on a worker thread after start (`TerrainRenderer.warm_assets`, `ArtKit.warm` / `poll_warm`, `CityBuilder.upgrade_lods`); until they arrive, and in headless runs or with `--art-lod=off`, the old single range. `--art-mid=<units>`, `--shadow-proxy=off`, `--shadow-far` override the levers.

**Detector** (`scripts/ui/gfx_detect.gd`, class `GfxDetect`): first launch only (no `[graphics] tier` saved yet, also for players from before the tiers), right after the language prompt and before the intro; Settings "Detect best settings"; `--detect` (any run; with `--detect-quit` it quits after saving; `--detect-shot=` / `--detect-shot-end=` save screenshots; `--settings-detect` presses the Settings button in a capture). "Optimizing graphics for your computer…" with a progress bar over the panning map, about 4-8 s.
1. Prior from `get_video_adapter_name / _vendor / _type`: integrated GPUs (type, or Intel UHD / Iris, "AMD Radeon Graphics", Apple M) start at SD medium and never go above SD high (Apple Pro / Max: HD fast); software renderers stay at the bottom; NVIDIA RTX xx70+ start at HD+, xx60 HD, xx50 HD fast, GTX SD high or medium; AMD RX and Intel Arc by model; "Laptop" one step lower. VRAM is not exposed by Godot and is not used. `--gpu-prior=integrated|discrete|software` forces the kind (test).
2. Benchmark: each tier is switched in live (compiling its pipelines: the step doubles as the shader warm-up), warmed until no pipeline compiled for 5 frames (`RENDERING_INFO_PIPELINE_COMPILATIONS_*`), then 40 frames of `viewport_get_measured_render_time_gpu` while the camera pans slowly; frames that compiled a pipeline are skipped. The 95th percentile without isolated spikes over 1.6x the median (on this laptop one frame in ten reads 2-4x the median in every tier, SD low included, at the agents' capped frame rates) must be at most 13 ms, divided by 1.15 on the 1948 map (Tel Aviv 2023 costs 1.2-1.6x the 1948 Jaffa view). Over budget: skip to the first cheaper tier the measured cost says fits (`GfxDetect.REL`, relative costs from the table below); well under it: one try up at the richest tier that should fit. No GPU timing: SD medium. Never above the prior's cap.
3. Applies and saves the tier and shows "Graphics set to HD fast (60 fps). You can change this in Settings."

**Run-time safety net** (`GameUI._perf_watch`): in play, under min(50, refresh x 0.85) fps for more than 10 s (seconds with a frame over 100 ms do not count; not while loading, ending a turn, rebuilding the map, detecting, unfocused, or capped below 55 fps) drops to the next tier that costs clearly less (`GfxDetect.cheaper`: HD+ lite → HD fast, not HD), once per session, with a toast and an Undo. `--perf-net-test` triggers it after 3 s (test).

**Stutter fixes** (measured with `scripts/ui/ui_test_perf.gd`, UITest mode `--ui-test-perf`: 2 min of panning over the country, then 10 End Turns, `--perf-load=<save>` for the late game, `FrameLog` in `scripts/ui/frame_log.gd`, `FrameLog.mark()` names what ran in a long frame; `--frame-log=<path>` logs any run):
- Date rebuilds run in ~6 ms slices over frames (`TerrainRenderer.apply_date` / `CityBuilder.update` are coroutines; everything new is built hidden and swapped in in one frame; `busy()`; `main.gd` holds later date changes until done). Behind a loading screen (`LoadingScreen.covering`), in captures and tests (`--sync-map`), all at once; `--async-map` slices in a capture.
- Hex signatures included the hex's own footprints, which it re-added on every rebuild: about a quarter of all town hexes rebuilt every quarter, forever, and the footprint list grew. Footprints are now tagged by owner hex (global ones by `GLOBAL_FP`), a rebuilt hex drops its own first, and signatures ignore their own and sort the rest: 18-27 → 1-14 hexes a quarter.
- `TerrainMath.crater_carve` skips the noise of craters whose plain distance is over 3.2 (exact: the noise term lies in [-0.2, 0.175]); about 40 % off every height sample outside the Negev (old-town hexes 50 → 30 ms).
- The minimap bitmap (about 0.25 s of per-pixel work) is drawn on a WorkerThreadPool task in play (`HUD.set_map(map, true)`).
- Panning: the city card refreshes alone when the nearest city changes (`GameUI._refresh_city_card`), not the whole HUD (90 ms late in the game).
- End Turn in play shows "Ending turn…", then runs the sim, the new quarter's UI in the next frame and the autosave a few frames later (`GameUI._turn_split`; tests and captures keep one frame).
- Kit models of later eras and landmark / diorama scenes are prepared in the background (`ArtKit.warm`, `ResourceLoader.load_threaded_request`), so a new era's first models no longer stall a rebuild (30-140 ms each).
- The HD shore rocks (1.2 s of terrain sampling at the first HD switch) are placed over frames in play (`HDRender._fill_shore`).

Measured 2026-10-18, RTX 5070 Laptop, 1920x1080, GPU ms median / p95 (p95 without spikes over 2x the median), 30 fps agent cap, 30 frames static and 30 panning per cell:

| tier | Jaffa 1948 noon static | pan | night static | pan | Tel Aviv 2023 noon static | pan | night static | pan |
|---|---|---|---|---|---|---|---|---|
| HD+ | 13.9 / 18.6 | 13.0 / 15.2 | 14.8 / 17.1 | 14.2 / 16.3 | 17.6 / 18.5 | 17.9 / 19.0 | 18.9 / 20.5 | 17.5 / 19.2 |
| HD+ lite | 10.4 / 13.2 | 10.5 / 23.5 (13.7) | 12.1 / 18.7 | 11.7 / 25.9 (14.5) | 17.5 / 19.4 | 15.9 / 19.1 | 14.6 / 14.9 | 14.4 / 16.2 |
| HD | 14.1 / 17.5 | 13.4 / 17.9 | 14.6 / 17.4 | 13.8 / 17.8 | 19.7 / 20.9 | 18.5 / 20.1 | 19.7 / 20.8 | 17.8 / 20.2 |
| HD fast | 7.6 / 11.4 | 7.0 / 20.9 (9.5) | 7.2 / 9.0 | 8.2 / 16.1 (11.9) | 8.9 / 17.3 (11.1) | 11.4 / 15.4 | 11.3 / 12.9 | 8.8 / 17.7 (11.3) |
| SD high | 10.7 / 17.3 | 8.7 / 12.2 | 8.8 / 18.7 (14.2) | 8.8 / 11.2 | 16.5 / 17.7 | 14.5 / 16.2 | 13.6 / 14.0 | 13.5 / 16.0 |
| SD medium | 8.1 / 9.5 | 8.4 / 8.6 | 8.0 / 18.4 (12.9) | 7.5 / 8.9 | 10.5 / 12.6 | 10.4 / 24.4 (12.6) | 10.2 / 15.8 (13.3) | 10.1 / 11.9 |
| SD low | 4.5 / 9.6 (7.4) | 4.6 / 6.2 | 4.8 / 9.8 (5.8) | 4.7 / 7.4 | 7.1 / 10.8 | 5.7 / 17.7 (7.4) | 7.1 / 8.8 | 7.0 / 12.6 (9.7) |
| SD low, reduced res. | 2.7 / 6.0 | 6.5 / 6.9 | 5.6 / 5.6 | 6.7 / 7.3 | 4.5 / 11.9 (5.6) | 4.5 / 10.0 (5.7) | 4.5 / 9.9 (5.3) | 4.5 / 10.0 (7.2) |

(The HD fast row was measured with the mid LOD from 5 units, MSAA 2x and FSR sharpening 0.2, which made the facades grainy. The final HD fast (full models up to 12 units, sharpening 1.0, FXAA): Tel Aviv 2023 noon panning median 8.8-10.3 ms, p95 without spikes 9.7-14.4 ms over three runs (12.4 typical), night panning 11.0 / 14.7; Jaffa 1948 panning 6.8 / 9.1. Crops: progress/shots/2623-2624.) On this 150 % DPI screen `get_texture().get_size()` reports 1.148x the window (2205x1240 for a 1920x1080 window), but the rendered image is 1920x1080: the earlier "2205x1240 render" notes above were 1920x1080 too.

Before perf60 (same laptop, 1920x1080, Jaffa 1948): HD+ 25.2 ms static / 26.4 ms panning (p95 27.8), HD 24.0 ms, SD medium 17.1 ms. The detector picks **HD fast** here (first launch, a fresh user dir: HD+ lite p95 15.1 / 18.0 ms > 11.3 → HD fast 9.8 / 10.0 ms). Integrated prior (`--gpu-prior=integrated`): SD low.

## web: the HTML5 build (2026-10-18)

The web build (build/web, WEB.md) is a copy of the game made by `build/web/refresh_src.sh` (incremental `sync_src.py`, asset diet `web_diet.py`) and exported with the Compatibility renderer on WebGL 2 (no threads). Shared code only differs behind `OS.has_feature("web")` (browser behaviour) or `GfxTier.web()` (the look: true in the browser and when the web copy runs natively, project setting `israel/web_look`), and shaders behind `#ifdef WEB_LOOK` (defined only in the copy). The desktop never takes these paths.
- Graphics tiers: `web` (SD medium without SSAO and glow, MSAA 2x) and `web_low` (SD low, no MSAA, fewer near trees); `GfxTier.WEB_LADDER`, picked by `GfxTier.web_default()` from the browser's unmasked GPU name (integrated / software -> web_low). No detector on the web (WebGL has no GPU timer).
- WebGL 2 allows 16 texture units per shader: the ground textures (terrain) and the kit facades / normal maps (building) are texture arrays (`web_terrain_array.png`, `web_kit_array.png`, `web_kit_n_array.png`, built by web_diet.py); HD maps and the cloud texture are left out.
- ANGLE's Direct3D compiler (Chrome, Edge) unrolled every loop and branch that sampled textures: loop counts come from uniforms (`HC_N*`, hexcommon), the terrain samples with explicit gradients and HD is a compile-time false (`HD_ON`): the terrain's first compile 65 s -> 16 s.
- Compatibility renderer differences handled: VRAM textures are not sRGB-decoded (`web_srgb()`, hdplus.gdshaderinc); MultiMesh instance colour multiplies vertex COLOR even without colours (white instance colours, `TerrainRenderer.mm`); an unshaded multiply blend is tonemapped (tree ground shadows blend by alpha); the ambient colour / sky mix is not applied (DayNight's web night ambient and moon, `WEB_NIGHT_*`); the water's screen-texture read and glow each forced a per-frame framebuffer check (a sync point): the web water blends by alpha, no glow.
- Kit textures are 512 px on the web (artinst samples one mip finer); the terrain grid spacing is 0.21 (`TerrainRenderer.WEB_TERRAIN_SPACING`) and its vertex normals use 3 height samples.
- Resolution (2026-10-18): the canvas renders at the display's pixel ratio on both tiers (`GfxTier` lever `canvas_scale` 0, capped at 2), so the UI text is sharp; the 3D map has its own resolution, `world_scale` x the page's CSS pixels (web 1.0, web_low 0.66), through `WorldView` (world_view.gd): a SubViewport sharing the World3D, a second camera copying `CameraRig.cam` every frame (and in `frame_pre_draw`), shown stretched on CanvasLayer -100. The game's own camera stays current in the window, so picking, hover, drag-pan, `unproject_position` (map labels, unit flags) and the minimap are unchanged. Code that switches the map's 3D off goes through `WorldView.show_3d(vp, on)` / `is_3d_off(vp)` (plain `disable_3d` on the desktop); render info comes from `WorldView.render_rid(vp)`. `scaling_3d_scale` (lever `world_native`) works in 4.7 Compatibility only with the page's stencil-blit fix and measured slower on a Radeon 610M.
- Loading indicators: the page's spinners are HTML with CSS transform animations (they keep turning while a frame blocks); `WebSpin.loading(text, pct)` sets the loading screen's step and percentage, `WebSpin.busy(text)` / `busy("")` the busy indicator (shown after 0.3 s): End Turn, the autosave after it, F5, the Save window, the loading screen.
- Test levers: `--lever=<name>:<value>` changes one tier lever for a run (e.g. `--lever=shadows:true`, `--lever=trees:1`); `--world-scale=`, `--canvas-scale=`.
