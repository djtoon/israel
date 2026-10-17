# Civilization: Israel — art direction (v1)

Target frame: `ref/screenshot.png`. Every asset should look like it was lifted out of that frame.

## The look in one line
Stylised-realistic Civ VI tabletop: warm golden Mediterranean late-afternoon sun from the upper left, soft warm
shadows, rich saturated colour, chunky readable silhouettes with slightly exaggerated proportions, fine but not noisy detail.

## Palette
| role | colour |
|---|---|
| limestone / Jerusalem stone | honey cream `#E8D2A0` → gold `#C9A15A` |
| roofs, earth | terracotta `#C0623A`, terra rossa `#9A4A2A` |
| vegetation | olive `#6E7F3A`, sage `#9AA77A`, pine `#2F5A2E` |
| water | turquoise `#2FB3B8` → deep blue `#1B5E8C` |
| HUD | navy `#0F1E3F`, gold `#E2B65A` |

Avoid: grey overcast light, cold blue shadows, photo-real grime, pure black, neon.

## Era cues (what makes an asset read as its era)
- 1948–52: white canvas army tents, corrugated tin, water tanks on stilts, khaki, kova tembel caps, vintage trucks.
- 1950s–60s: white/cream International Style (Bauhaus) blocks, rounded balconies, ribbon windows, pilotis; kibbutz water towers; "shikun" concrete slab blocks with rooftop solar heaters.
- 1970s–90s: Merkava, F-16, Sa'ar boats, port cranes.
- 2000s+: glass towers, solar fields, desalination, offshore gas, Iron Dome.

## Asset conventions
- **Models** (GLB): 1.0 world unit = one hex flat-to-flat; +Y up; lowest point at y = 0; footprint centred on origin.
  - *Tiles* (cities, landmarks, improvements) stand on one thin **pointy-top** hex slab (corners on ±Z) exactly 1.0 flat-to-flat.
  - *Nature props*: no base. Heights: date palm 0.42, Aleppo pine 0.36, cypress 0.40, olive 0.26 hex; rock 0.30 wide.
  - *Units*: no base. People 0.30 hex tall; tanks/trucks/launchers 0.45–0.52 hex long; jets 0.55; boats 0.62.
  - `_pipeline/normalize_glb.py` applies all of this (and forces non-metallic materials, since the generators omit
    `metallicFactor` and glTF then defaults to fully metallic = black in Godot).
  - *Buildings* (`kind: building` and `lm_*_nb` landmarks, `scale_units: "m"`): single structures with **no base**,
    cropped at the ground line, at **real scale: 1.0 = 1 metre**; footprint rectangle aligned to X/Z, front towards +Z.
    Use one metres→world factor for all of them. Wide low ones (Knesset, desalination, airport, shikun, dining hall,
    Azrieli, Dome of the Rock) use a compromise scale (geometric mean of real length and real height) because the
    generated proportions are stylised; `real_m` always reports the model's actual size in metres.
  - Round-2 kinds `harbour`, `shore`, `vegetation` and the extra `building` pieces are all metre scale
    (`scale_units: "m"`). `veg_*` replace `nat_*` for real-scale streets (nat_* stay as hex-scale map props).
    Modular segments (quay, pier, breakwater, wall, container stack, arcade, long blocks) have their long side on X.
  - Round-3 `r3_*` buildings (city variety): generated from a 45-degree view so the **roof** is designed, since the
    game camera mostly sees roofs. Flat roofs carry Israeli rooftop clutter (dud shemesh solar heaters, tanks, AC,
    antennas, parapet); `roof` field in MANIFEST says flat or pitched/domed. Templer houses: only Sarona / German
    Colonies.
  - **Normals (important):** TRELLIS/Hunyuan GLBs have no NORMAL attribute and Godot 4.7 then lights every vertex
    with a constant +Z normal: a model is lit only when its +Z side faces the sun and goes uniformly dark when
    rotated. `_pipeline/add_normals.py` bakes crease-aware smooth normals (40 deg) into every GLB; build.py runs it on
    all models. Never ship a generated GLB without it. Also, after replacing a GLB, delete Godot's extracted
    `<model>_0.png` and the `.godot/imported/<model>.glb-*.md5` stamp (build.py does this), or Godot keeps the old texture.
  - Back sides: image-to-3D bakes unseen sides darker/bluer; `_pipeline/relight_back.py` lifts dark texels toward the
    lit facade colours for metre-scale buildings.
  - Every model has `real_m` (approx. real size in m) except hex dioramas (`null`). Tiles have `ground_y` (top of the
    slab in model units: sink by this to make the slab flush with the terrain); city/landmark tiles also ship a
    `*_noplinth` variant with the slab cut away (`_pipeline/strip_plinth.py`).
- **Terrain textures**: 1024² seamless, straight top-down, ~20 m across, even lighting; suggested 2 repeats per hex.
- **Icons**: 128² RGBA. Yields/actions = gold line glyph in a navy medallion with a thin gold rim and a faint
  yield-coloured inner glow. Resource pins = navy map-pin badge, gold rim, resource drawn in natural colours.

## Prompt templates (exact; the code is `_pipeline/prompts.py`, the subjects are in `_pipeline/assets.py`)
STYLE =
> Game asset for a Civilization VI style strategy game: stylised-realistic hand-crafted 3D render, warm golden
> Mediterranean late-afternoon sunlight from the upper left, soft warm shadows, rich saturated colours (honey limestone,
> terracotta, olive and sage greens, turquoise accents), clean chunky readable silhouette with slightly exaggerated
> proportions, fine but not noisy detail

NEG =
> No text, no letters, no numbers, no logos, no signage, no UI, no frame, no border, no cast shadow on the background

**Tile** (city / landmark / improvement source image):
> {SUBJECT}. Everything stands on one thin flat pointy-top hexagonal ground slab (a single map tile; the slab edge is only
> as thick as a kerb stone, no soil cross-section) covered with {GROUND}; nothing overhangs the hexagon edge. {STYLE}.
> Isometric three-quarter view from about 35 degrees above. One single isolated tile centred and filling about 85% of
> the frame on a plain pure white background. {NEG}.

**Prop** (nature):
> {SUBJECT}. {STYLE}. Three-quarter view from about 25 degrees above. One single isolated object, no base, no ground
> patch, centred and filling about 80% of the frame on a plain pure white background. {NEG}.

**Unit**:
> {SUBJECT}. {STYLE}; looks like a painted tabletop miniature as seen in Civilization VI, slightly chunky heroic
> proportions, clean readable shape at small size. Three-quarter view from about 25 degrees above, facing front-left.
> One single isolated unit, no base, no ground, centred and filling about 80% of the frame on a plain pure white
> background. {NEG}.

**Building** (single structure, no base — preferred for city layout):
> {SUBJECT}. {STYLE}. One single isolated building standing directly on the ground line, with no base, no plinth, no
> slab, no ground patch, no lawn, no pavement, no trees around it; the image is cut off exactly at the bottom of the
> walls. Three-quarter view from about 30 degrees above. Centred and filling about 80% of the frame on a plain pure
> white background. {NEG}.

**Building from above** (round 3, `prompts.roofbld`):
> {SUBJECT}; flat roof clearly visible and full of typical Israeli rooftop clutter: several solar water heaters (a
> tilted dark-blue panel with a white horizontal cylinder tank), small water tanks, AC units, antennas, a low parapet.
> {STYLE}; bold readable massing and silhouette, distinct proportions. One single isolated building standing directly
> on the ground line, with no base, no plinth, no ground patch, no lawn, no pavement, no trees, no cars, no people; the
> image is cut off exactly at the bottom of the walls. Three-quarter view from about 45 degrees above so both the roof
> and two facades are visible. Centred and filling about 80% of the frame on a plain pure white background. {NEG}.
(The rooftop clause is dropped for pitched/domed roofs.) Vary massing in the subject: wedge, L, H, stepped, terraced,
courtyard, long "train" slab, tower with setback crown.

**Kit piece** (round 2: quays, piers, breakwaters, walls, gates, cranes, stalls, old-town houses; `_pipeline/assets_r2.py`):
> {SUBJECT}. {STYLE}. One single isolated modular game piece standing directly on the ground line, with no base, no
> plinth, no ground patch, no water, no surroundings, no people; the image is cut off exactly at the bottom of the
> object. Three-quarter view from about 30 degrees above. Centred and filling about 80% of the frame on a plain pure
> white background. {NEG}.
Modular segments say "both ends cut off flat and square like a modular game piece".

**Free object** (boats, shore rocks):
> {SUBJECT}. {STYLE}. One single isolated object with no base, no ground, no water, no reflection, no surroundings, no
> people. Three-quarter view from about 30 degrees above. Centred and filling about 80% of the frame on a plain pure
> white background. {NEG}.
Rocks: name the real stone (kurkar, chalk, sandstone) and ask for "individual blocks with sharp edges and gaps".

**Plant at real scale** (`veg_*`):
> {SUBJECT with height in metres}. {STYLE}; foliage built from chunky solid clumps so the silhouette reads clearly,
> natural irregular asymmetric shape, not a round lollipop. One single isolated plant, no pot, no ground, no grass, cut
> off exactly at the base of the trunk. Side three-quarter view from about 15 degrees above, the whole plant visible,
> centred and filling about 85% of the frame on a plain pure white background. {NEG}.

**Trees**: describe the canopy as "a big dense solid canopy made of four or five chunky rounded clumps … no gaps or
bare branches visible". Image-to-3D turns airy foliage into bare branches or black shells; solid clumps survive.

**Terrain texture**:
> Seamless tileable ground texture, perfectly straight top-down orthographic view looking straight down (no
> perspective, no horizon, no sky), of {SUBJECT}. Map terrain texture for a Civilization VI style strategy game:
> stylised-realistic painterly look, warm sunlit Mediterranean palette, rich saturated but natural colour, soft even
> overhead lighting, uniform density across the whole image with no focal point, no vignette, no single large feature,
> no objects, no buildings, no roads. Area shown is about 20 metres across. {NEG}.
Then `_pipeline/tileable.py` (half-offset + noisy feathered mask) guarantees the wrap; orchard rows use
`_pipeline/orchard_tile.py` (crop to whole tree cells, cross-fade through bare earth).

**Yield / action icon** (`--transparent`):
> Game HUD icon of {GLYPH}. Drawn as a bold clean line-art glyph in warm polished gold (#E2B65A) with a subtle bevel
> highlight, centred inside a round deep-navy (#0F1E3F) medallion with a thin gold rim ring and a faint inner glow, flat
> front view, simple bold shapes that stay readable at 32 pixels, consistent medium line weight, {ACCENT e.g. "a subtle
> sky-blue inner glow behind the glyph"}. Transparent background outside the medallion. One icon only, centred, filling
> the frame. No text, no letters, no numbers.

**Resource pin** (`--transparent`):
> Map resource pin icon of {GLYPH}. A round deep-navy (#0F1E3F) badge with a thin gold (#E2B65A) rim and a small
> downward point at the bottom like a map marker; inside, the resource drawn as a bold simple slightly stylised
> illustration in its natural colours ({COLOURS}) with a gold outline. Flat front view, readable at 32 pixels.
> Transparent background outside the badge. One pin only, centred, filling the frame. No text, no letters, no numbers.
Then `_pipeline/icons.py` fills accidental alpha holes with navy, crops and downsizes to 128 px.

## Pipeline
1. Add the subject to `_pipeline/assets.py`; `python _pipeline/mkjobs.py jobs.json [ids]`; `python _pipeline/batch.py jobs.json`
   (parallel, logs every call to `_pipeline/genlog.jsonl`). Look at the image; iterate the subject until it is clean.
2. `batch.py` with `{"kind":"model"}` jobs → `_pipeline/glb_raw/<id>.glb` (records hunyuan vs trellis).
3. `python _pipeline/build.py` → normalised `models/<cat>/<id>.glb` + `MANIFEST.json`.
4. `_pipeline/make.sh` (= build.py + Godot import), then
   `_pipeline/shot.sh out.png --mode=grid|gridturn|diorama|street|terrain [--filter=prefixes] [--cols=] [--zoom=] [--pitch=]`
   (scene `scenes/art_preview.tscn`, script `scripts/art/art_preview.gd`; grid = one framed viewport per model,
   gridturn = 4 orbit angles, diorama = small map at game zoom, street = metre-scale buildings side by side).
5. Facing/alignment fixes that can't be automated go in MANIFEST.json as `yaw_fix` (`_pipeline/setfix.py id=deg`).

Generation settings: images `openai/gpt-image-2.5-flare`, quality high, 1:1. Models `tencent/hunyuan-3d-3.1`
(40k faces) with automatic fallback to `firtoz/trellis` — see `generator` in MANIFEST.json.
