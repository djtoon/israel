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
