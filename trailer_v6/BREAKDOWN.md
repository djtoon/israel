# Israel: The Birth of a Nation · Cinematic Trailer (v6) · Breakdown

**Master:** `IsraelBirthOfANation_Trailer_Cinematic.mp4`: 1:42 (102.0 s), 1920x1080, 24 fps, H.264 High (CRF 16, slow, film tune), AAC 320 kb/s at 48 kHz. The Acts 1, 2 and 4 are in a 2.39:1 letterbox (an active picture of 1920x804). The bars glide open for the game-systems act and close on the climax hit.
**Loudness:** −14.1 LUFS integrated, with a true peak of −1.5 dBTP (ebur128 on the master) and no clipping.
**Everything needed to re-render it is in `src/`** (see "Rebuild" at the end).

---

## 1. Structure

The score's downbeats fall on whole seconds, with a 4 s bar and an 8 s phrase. Every cut and every type hit below lands on that grid.

| Act | Time | Music | Idea |
|---|---|---|---|
| Cold open | 0:00–0:07 | sound design only | The TMT logo assembles from dust, then a gold anamorphic flare and a spark burst hit on the lock |
| 1 · The birth | 0:07–0:35 | solo strings, felt piano, frame drum, two timpani hits | Dawn over the 1948 coast, the declaration, "14 MAY 1948", arrivals, the transit camps |
| 2 · Build a nation | 0:35–0:51 | ostinato strings, drums and horns enter | The 1948–2023 timelapse under "BUILD A NATION", then one word per 2 s cut |
| 3 · Every decision is yours | 0:51–1:07 | the same cue through a closed low-pass that opens over 16 s, plus the game's own UI sounds | The game's interface as dimensional cards in 3D space; the letterbox opens; at 0:59–1:03 a full-frame burst of 14 painted Israeli and US leaders cut on the beat |
| 4 · Climax | 1:07–1:31 | full orchestra and choir | The launch on the braam, golden hour to night, then "EVERY WAR / EVERY PEACE / EVERY DREAM" with 1 s cuts |
| Finale | 1:31–1:42 | the drop, one beat of air, the final hit at 1:35, the tail | Last light, then gold dust gathers into the logo on the hit; Hebrew title, 1948–2023, LEAD A NATION, Windows · macOS |

## 2. Shot list

The **Technique** column names the source and the process. "Seedance i2v" means `bytedance/seedance-2.5` image-to-video from a 21:9 crop of the named still, at 720p (1470x630), with no generated audio. The prompts are given in full in section 3.

| # | Timecode | Shot | Technique |
|---|---|---|---|
| 1 | 00:00.00–00:07.00 | TMT logo | `newIntro/logo_comp.mp4`, retimed (6–9 s at 1.5x, then 1.0x), lanczos to 1080p. Over it, additively: the strata `logo_fx.json` light pass, a 3-layer anamorphic streak (a hot core, a warm wing and a haze) and a bloom at 3.30 s, 520 gold spark particles with trails and turbulence, then drifting gold dust. Fades out at 6.4 s. |
| 2 | 00:07.00–00:12.00 | Dawn on the 1948 coast | Seedance i2v from the game still `trailer_shots/01_1948_jaffa_port.png` (an aerial glide; the sun rises behind the hills). Fades in from black over 1.1 s, with a 1.00→1.03 push. Caption: "SPRING 1948". |
| 3 | 00:12.00–00:15.00 | Galilee morning | Seedance i2v from `06_sea_of_galilee.png` (mist and cloud shadows over the lake) |
| 4 | 00:15.00–00:19.00 | Declaration hall | `evt_1948_independence` painting. **Camera only, with no generated motion on real people:** a scripted 2.5D move (`paint25d.py`) with a soft depth split (the foreground rows push 3.5% more than the back wall), an extra push of 1.00→1.07 and a pan, procedural god rays, and drifting dust. A 0.5 s dissolve in. Caption: "TEL AVIV MUSEUM · 4 PM". |
| 5 | 00:19.00–00:23.00 | **"14 MAY 1948"** | The same move continues, graded down by −1.35 stops, desaturated and with a 2.2 px blur, as a title plate. On the timpani hit: an exposure pop and a warm light leak. Kinetic type (strata): Cinzel SemiBold at 164 px, per-character ramp reveal with a 34 px rise, a slow −3% scale settle, and a gold rule that draws out from the centre. "A NEW STATE IS DECLARED" follows in Cormorant at 560 tracking. |
| 6 | 00:23.00–00:27.00 | The ship | Seedance i2v from `evt_1950_law_of_return` (the flag ripples, gulls). Type: "IN THREE YEARS". |
| 7 | 00:27.00–00:31.00 | The airlift | Seedance i2v from `evt_1951_ezra_nehemiah` (propellers, dust, heat haze). Type: "ITS POPULATION DOUBLES". |
| 8 | 00:31.00–00:35.00 | Transit camp at sunset | Seedance i2v from `evt_1950_maabarot`, with a 0.6 s dissolve. A 4 s riser runs into the act break. |
| 9 | 00:35.00–00:39.00 | **"BUILD A NATION"** | The game's own 1948→2023 timelapse (`features/06`) at 1.25x with a 1.04→1.00 pull. The title slams on the downbeat (Cinzel ExtraBold at 124 px, with a 3.5% drift), with an impact, a braam, a light leak and an exposure pop. |
| 10–15 | 00:39–00:51 | WATER · FIELDS · HARBOURS · ROADS · RAILWAYS · TOWERS | One word per 2 s cut, each on a whoosh. Every shot enters on a speed ramp (1.9x→1.0x over 0.22 s, frame-blended). The shots: Seedance water carrier (`evt_1964_national_water_carrier`), game HD+ green Galilee (`features/08`), Seedance Haifa relit to golden hour (`15_2026_haifa`), Seedance highway (`evt_2002_highway_6_opens`), Seedance railway (`evt_2018_jerusalem_tel_aviv_railway`), and the existing Seedance Tel Aviv crane (`work_video/tlv_test.mp4`). |
| 16 | 00:51.00–01:07.00 | **Act 3: the game in 3D** | The strata scene `act3.json`: 41 layers and 20 sub-comps, one 40° camera with 90 keyframes and motion blur. (A, 0–4 s) An exploded HUD: the resource bar, research, history, city panel and minimap float at depths of z −200…+700 with depth-of-field blur. The **NOW button** glows, "EVERY DECISION / ONE AT A TIME" types on, the button is *clicked* at 53.72 (a scale dip, an expanding gold ring and the game's `click.ogg`), and the cut opens the card. (B, 4–8 s) The **Cabinet Decision** card explodes into its header and two options, which slide out and lift toward the camera on the beats in one rigid rotating plane. Gold callouts read "HISTORY CHOSE THIS" and "YOUR CALL"; title: "REAL DILEMMAS FROM THE RECORD". (C, 8–12 s) is the **leaders burst** (shots 16a–16n, below). The strata scene keeps only its backdrop for those 4 s, so no other country's leader portrait appears anywhere in the trailer; the Act 3 UI crops in A, B and D contain no portrait thumbnails. (D, 12–16 s) The **Cabinet**, the **State Budget** sliders and the **vs-history** charts fan out at angles. Each card carries its own clipped light sweep. "IS YOURS" lands at 64.0, then the camera accelerates through the cards (cubic) into the hit. Every UI card is cropped from real game screenshots. |
| 16a–16n | **00:59.00–01:03.00** | **The leaders burst: 75 years of Israeli and US leaders, full frame** | This replaced the orbiting portrait arc after user feedback, and then, after further feedback, uses **only Israeli and US portraits**. Fourteen of the game's painted portraits (`game/assets/images/portraits/*.png`, the 1024² versions) are shown **full frame in the 2.39 letterbox**: the bars snap in for the burst and out again at 1:03. They are **still paintings; only the camera, scale and light move.** `src/scripts/leader_plates.py` crops each one to a 1024x560 face-and-shoulders band, upscales it to 2000x837 and widens it to 2.39 by continuing the painting's own navy backdrop at the sides (the band stretched, blurred and darkened; the face and shoulders are untouched paint), with a light sharpen and a face-centred vignette. The order is chronological, alternating Israel and the US by era, and the cuts follow the score, accelerating into the 1:03 downbeat: **12, 12 frames (8ths), then 6×8 (16ths), then 4, 4, 4 and a 12-frame hold**, 96 frames in all. The cuts fall at 59.00 Ben-Gurion · 59.50 Truman · 60.00 Eshkol · 60.25 Johnson · 60.50 Meir · 60.75 Nixon · 61.00 Begin · 61.25 Carter · 61.50 Rabin · 61.75 Clinton · 62.00 Sharon · 62.17 Bush (43) · 62.33 Netanyahu · 62.50–63.00 Ben-Gurion again, closing the loop. **Transitions:** a horizontal whip-blur through 59.0 and 63.0, exposure flashes on 59, 60, 61, 62, 62.5 and 63, and soft warm leaks at 59.0, 61.0 and 62.7. **Type:** tiny gold Cinzel name tags (22 px, 340 tracking, one-frame fades) on the first six cuts, which are dropped on the faster ones. **"THE LEADERS.  THE ALLIES."** runs over the fastest cuts from 61.0 to 63.0 in the same lower-third slot. **Sound:** a whoosh into the burst, a shutter tick on every cut and a whoosh out into the cabinet cards. |
| 17 | 01:07.00–01:09.00 | Launch | Seedance i2v from `evt_1961_shavit2`: the rocket rises out of the smoke on the braam, with a speed ramp of 1.0→1.45x and a push |
| 18–19 | 01:09.00–01:12.00 | Jerusalem golden hour, then Eilat | Seedance i2v from game stills, relit to golden hour. Climax ramps (2.4x→1.0x→0.85x) with opposing push and pull. |
| 20 | 01:12.00–01:14.00 | Golden hour to night | The game's real day–night cycle (`features/07`) at 2.4x with shutter-blended frames |
| 21 | 01:14.00–01:16.00 | Night city | Seedance i2v from the game's own night frame: a match cut into the same coastline |
| 22 | 01:16.00–01:18.00 | Stage lights | Seedance i2v from `evt_2019_eurovision_tel_aviv` |
| 23 | 01:18.00–01:20.00 | **"EVERY WAR"**: the fronts | The strata `fronts.json`: the game's war-fronts card in 3D (a −22°→−9° turn, a camera dolly and a light sweep) |
| 24 | 01:20.00–01:22.00 | Armour in the dust | Seedance i2v from `evt_1973_yom_kippur_war`. War as painted silhouettes in sunset dust, with no firing and no casualties. 1.6x with a pan. |
| 25 | 01:22.00–01:24.00 | **"EVERY PEACE"** | The `evt_1979_egypt_peace_treaty` painting, again **camera only** (`paint25d.py`, the same method as shot 4) |
| 26 | 01:24.00–01:26.00 | **"EVERY DREAM"** | Seedance i2v from `evt_2019_beresheet`: the lunar lander |
| 27–29 | 01:26.00–01:29.00 | Desalination, White City, water | Three 1 s Seedance cuts with ramps; the peak of the montage |
| 30 | 01:29.00–01:31.00 | Haifa, last gold | The late part of the Haifa generation at 0.8x |
| 31 | 01:31.00–01:33.75 | Last light | The end of the Tel Aviv crane (the sun on the towers) at 0.8x, faded to black. It bookends the dawn of shot 2. |
| 32 | 01:33.75–01:42.00 | **Finale: the logo resolve** | The strata `finale.json`: a navy field over a blurred, darkened golden Tel Aviv. **2,600 gold particles attract onto the alpha of the logo** and gather from 93.75. The logo resolves on the music's final hit at **1:35.0**, with an anamorphic flare and a light leak, then an alpha-matted glint sweep across the gold letters. The Hebrew title **ישראל: לידתה של אומה** (Frank Ruhl Libre, verified RTL in the cloud render) follows, then "1948 – 2023" between drawn gold rules, then "LEAD A NATION", then "Windows · macOS" in Cormorant. Everything holds, then fades by 1:42. |

## 3. Seedance 2.5 generations

Every generation is image-to-video, at 720p and `adaptive` aspect from a pre-cropped 21:9 input, with `--no-audio`, run in parallel by `src/scripts/seedance_batch.py`. Each prompt is a production brief (shot, subject, camera, motion, light, style, mood), with "preserve the painterly impasto oil-painting look" or "preserve the stylised 3D strategy-game miniature look … buildings stay rigid". The full prompts are in `src/seedance/shots.json`, the inputs in `src/seedance/in/`, and the outputs in `src/seedance/*_a.mp4`.

**Budget used:** 23 Seedance predictions. Of these, 19 delivered usable takes and 18 are in the cut, plus the pre-existing Tel Aviv crane test. One input (Operation Moses) was flagged E005 three times and twice more after a neutral rephrase, so it was dropped. One (the offshore gas platform) "succeeded" with no output. Five results that timed out on the client were recovered from the Replicate predictions API (`src/scripts/recover.py`).

Takes were rejected or trimmed for these reasons:
- **The dawn coast:** the camera turns into the sunrise and a stone tower appears at the end, so the shot is used for 1–6 s.
- **Eilat:** the late dune shadows wipe unnaturally, so only the first 2 s are used.
- **Night city:** it came out underexposed, so it gets +0.35 stops.
- **Tanks:** low motion, so it runs at 1.6x.

**No generated motion was applied to any image of a real person.** The declaration and the peace treaty use the scripted camera, parallax and light only, and the leaders in Act 3 are still painted portraits.

## 4. Strata scenes (motion design)

All the scenes are `src/strata/*.json`, generated by the Python scripts in `src/scripts/` and rendered in the Idomoo cloud (library 143651).

| Scene | Script | What it is |
|---|---|---|
| `type_color.json` / `type_matte.json` | `type_overlay.py` | All the Act 1, 2 and 4 typography on one 102 s timeline. It is rendered twice, as a colour pass (type plus glow, on black) and a coverage matte (type plus its soft shadow, white), and the edit composites `plate·(1−matte) + colour`. The glow therefore adds light and the shadow only darkens, with no muddy halos. The type uses per-character `ramp_up` reveals with linear offsets (≥8 frames per letter), rises of 10–34 px, slow scale drifts, and gold rules drawn with stroke trims. |
| `act3.json` | `act3_scene.py` | The dimensional UI act (shot 16). Each card is placed by inverse projection, so that it lands at an intended screen position, width and depth. Sub-comps clip the light sweeps, the rotation pivots are shared so the cards move as one rigid plane, the orbit keys are computed analytically, and depth of field comes from per-card blur by z. |
| `fronts.json` | `scenes_misc.py` | The war-fronts card in 3D (shot 23) |
| `logo_fx.json` | `scenes_misc.py` | The cold-open light pass: the anamorphic streak, the spark burst and the dust (additive) |
| `finale.json` | `scenes_misc.py` | The particle logo resolve, the glint matte and the end-card typography |

**Fonts:** static instances cut from the game's variable fonts (`fontTools.varLib.instancer`): Cinzel 400, 600 and 800, Cormorant Garamond 500 and 600, and Frank Ruhl Libre 500. Cinzel's lining figures are used for every date; Cormorant's old-style figures are kept out of the numerals.

## 5. Finishing, the look (`src/scripts/edit.py`)

Every frame is built in Python and OpenCV, in this order:
1. **The plate:** the source is decoded as a stream and mapped through each shot's speed ramp. Frames are blended, and shutter-blended when the ramp is fast.
2. **Upscale:** lanczos to 1080p with a 1.3 σ unsharp, so the 720p generations sit next to the 1080p game footage. Push or pull zooms and pans are added here.
3. **Per-shot balance:** exposure, saturation, warmth and blur.
4. **The one show grade, applied to every shot:**
   - warm halation from a ¼-resolution highlight blur;
   - saturation of 1.05;
   - a filmic tone curve;
   - split toning, with navy shadows and gold highlights;
   - a vignette.
5. **Type slots:** soft graded "slots" darken the band under each line of type.
6. **Hits:** exposure pops on the hits.
7. **Light leaks:** procedural warm leaks (screen blend) at 0:07, 0:19, 0:35, 1:07 and 1:35.
8. **The strata type composite**, from the colour and matte passes.
9. **The letterbox:** 2.39:1, eased open from 51.0 to 51.45 s and closed from 66.6 to 67.0 s.
10. **Film grain:** half-resolution Gaussian grain, weighted to the midtones, at 2.4%.

The frames are rendered in parallel chunks: 4 processes, 61 chunks, CRF 10 intermediates. They are concatenated and encoded once to the master (`master.py`).

## 6. Music and sound (`src/scripts/mix.py`, `src/scripts/sfx.py`)

**The score.** It was generated with `elevenlabs/music` from a five-section production prompt (`src/music/prompt_score_a.txt`: "Dawn / Building / Decisions / Climax / Finale" at 60/120 BPM in D minor resolving to D major). Two takes were generated and **take a1** was chosen, because its phrase grid is exactly 8 s and its final hit is clean. The edit:
- a1 4–88 s plays continuously under the trailer from 7–91 s;
- a 40 ms splice at a downbeat jumps to a1 96–106 s, covering the drop, one beat of air and the final hit at 1:35;
- the level is automated: +10 dB in Act 1 and +3.5 dB in Act 2, against the climax;
- in Act 3 the cue runs through a two-pole low-pass that snaps closed at 51.0 s and opens exponentially from 420 Hz to the full band by 67 s. This is the tension pulse before the climax.

**The sound design.** It is synthesised in numpy (`sfx.py`):

| Sound | How it is made |
|---|---|
| Impacts | A pitch-dropping sub, a thump and a band-passed crack through a synthetic reverb |
| Braam | Detuned saw stacks with an opening low-pass, saturated |
| Sub drops | A sine falling from 90 to 28 Hz |
| Risers | A swept noise band plus rising stacked fifths |
| Reverse swells | A reversed reverb tail that ends hard on the hit |
| Whooshes | Moving band-pass noise with an auto-pan |
| Others | A shimmer, a rumble and a tick |

The cues are placed on the grid (`work/cues.json`):

| When | Cues |
|---|---|
| Cold open | Rumble, a reverse swell into the logo, and impact + sub + shimmer at 3.30 s |
| 0:19 | Impact on the date |
| 0:35 | Impact + braam + sub on BUILD A NATION |
| Act 2 | Whooshes on every word |
| 0:51 | The drop into Act 3 |
| Act 3 | **The game's own interface sounds** (`click.ogg` on the NOW button, `panel_open` as each card opens, `hover` and ticks on the callouts); in the diplomacy burst, a whoosh in, a tick on every cut and a whoosh out |
| 1:07 | A riser and reverse swell into the climax braam |
| 1:18, 1:22, 1:24 | Impacts under the triad |
| 1:35 | Reverse swell, braam and impact on the logo |

Game ambience (coast, city) runs under Acts 1 and 4.

**The master.** Gentle tanh glue, then an iterative static gain to −14.0 LUFS and a true-peak limiter (`alimiter`, with ASC). The master measures **−14.1 LUFS integrated, −1.5 dBTP**.

## 7. The review loop (the gauntlet)

I reviewed each cut as a harsh creative director: a frame every 2 s, frames at every cut, `strata review` (cuts, freezes, hard stops, energy arc and loudness), and ebur128.

**v1 to v2:**

| Problem in v1 | Fix in v2 |
|---|---|
| The type sat in a muddy brown halo, because the glow was in the matte | The colour and matte passes were split: the glow is light only, the shadow is coverage only |
| "EVERY PEACE" sat across the faces in the treaty painting | The triad moved to the lower third |
| The montage repeated Tel Aviv aerials (shots 30 and 31) | Shot 30 was replaced |
| The finale opened on 1 s of near-black while the particles gathered | The finale starts 1.25 s earlier, so the logo resolves exactly on the music hit |
| The review flagged freezes at 0:15–0:19, 0:56–0:58 and 1:19–1:23 | Stronger pushes and pans on the 2.5D paintings, a wider camera move on the Cabinet card, and the tanks at 1.6x |
| The climax's energy arc was flat | Push and pull zooms on every climax shot |
| The ending was a dead −44 LUFS tail | A declared fade, and the piece was trimmed to 102 s |
| Act 1 was 20 dB under the climax (inaudible on a laptop) | +10 dB in Act 1 and +3.5 dB in Act 2 |
| The platform line read "MACOS" in Cinzel's caps | It is set in Cormorant: "Windows · macOS" |

**v5 to v6 (final, user feedback):** "Only use Israel figures and U.S. figures profile images." The burst was rebuilt with Israeli prime ministers and US presidents only. I also checked the whole trailer for other leader portraits: only the old Act 3 diplomacy screen and portrait arc had them, and that strata segment was emptied and re-rendered. The painted event illustrations (such as the 1979 treaty) stay, as instructed. The caption became "THE LEADERS. THE ALLIES."

**v4 to v5 (user feedback):** The user disliked the 3D portrait arc. It is replaced by the full-frame burst (16a–16l). Stepping frame by frame through 58.8–63.2 s caught two fixes. Floating-point shot edges let the strata plate leak through for a single frame between two cuts, so shots are now looked up by integer frame index. And a chunk that started mid-shot on a still image decoded nothing (a black frame), so stills now always decode from frame 0. After both fixes every frame of the burst is correct.

**v3 to v4:** Stepping frame by frame through the cuts showed a ghost frame on the cuts inside Act 3. `strata review` had flagged "hard stops" at 0:55.08 and 1:03.08. The plate decoder started each source 0.05 s off its frame grid, so every 1:1 shot was blended 20% with its neighbour. That softened the whole piece slightly and double-exposed the cuts. The decode now starts on the source's own frame grid (I checked that the `-ss n/fps` seek returns frame *n* exactly), and blends under 3% snap to the frame.

**v2 to v3:** The type was still too milky over bright plates. The glow was cut to about 40%, and the shadow became tighter (0.2 × the type size) and darker. Graded "type slots" were added (a soft dark band under each line), and shot 30 was swapped for Haifa so Jerusalem is not used twice.

## 8. Rebuild

```
cd C:/civ/trailer_v6/src
python -I scripts/prep_inputs.py; python -I scripts/prep_ui.py           # Seedance inputs, UI card crops
python -I scripts/seedance_batch.py s01_jaffa_dawn s03_ship ... --par 2  # (already generated: seedance/*_a.mp4)
python -I scripts/paint25d.py                                            # camera-only moves on the real-people paintings
python -I scripts/type_overlay.py; python -I scripts/act3_scene.py; python -I scripts/scenes_misc.py
cd strata; strata render <scene>.json --library 143651 -o ../work/r_<scene>.mp4   # type_color, type_matte, act3, fronts, logo_fx, finale
cd ..; python -I scripts/sfx.py; python -I scripts/mix.py                # work/mix.wav
python -I scripts/edit.py --workers 4 --out work/picture.mp4             # picture, about 6 min on this laptop (CPU only)
python -I scripts/master.py work/picture.mp4 work/mix.wav ../IsraelBirthOfANation_Trailer_Cinematic.mp4
```

The cloud renders used by the edit are kept in `src/work/r_*.mp4`, the final picture in `src/work/picture_v6.mp4`, the mix in `src/work/mix.wav`, the review reports in `src/work/review_v1` and `review_v3`, and the previous cut in `src/work/trailer_v3.mp4`.

No Godot run was needed: all the gameplay is the existing `features/` footage and stills. No local GPU work was done, because the strata renders run in the cloud and the finishing runs on the CPU.
