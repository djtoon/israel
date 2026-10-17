## Basic model info

Model name: bytedance/seedance-2.5
Model description: ByteDance's flagship multimodal video model with native audio, native 30-second generation, and large multimodal reference sets.
Model page: https://replicate.com/bytedance/seedance-2.5 (schema read from the API on 2026-10-17, version ca38262bae09…)

Use it through the project tool:

```
python tools/gen.py video "<production-brief prompt>" out.mp4 [--image first.png] [--last last.png]
        [--ref-image a.png --ref-image b.png ...] [--ref-video v.mp4 ...] [--ref-audio a.mp3 ...]
        [--seconds 5] [--resolution 720p] [--aspect 21:9] [--no-audio] [--seed 42]
```


## Model inputs

- prompt (optional): Text prompt for video generation. Optional when a media input (image, reference images/videos/audios) is supplied. Seedance 2.5 works best with detailed, structured "production brief" style prompts. (string)
- image (optional): First-frame image for image-to-video or first/last-frame generation. Cannot be combined with reference images, videos, or audios. (string, file or URL)
- last_frame_image (optional): Last-frame image. Requires a first-frame image. Cannot be combined with reference images, videos, or audios. (string)
- reference_images (optional): Reference images (up to 30) for character consistency, style guidance and scene composition. Cannot be combined with first/last-frame images. Refer to them in the prompt as [Image1], [Image2], etc. (array)
- reference_videos (optional): Reference videos (up to 10, combined duration max 30 s) for motion transfer, style reference, editing and extension. Refer to them in the prompt as [Video1], [Video2], etc. (array)
- reference_audios (optional): Reference audio files (up to 10, combined duration max 30 s) for audio-driven generation and lip-sync. Requires at least one reference image or video. Refer to them in the prompt as [Audio1], [Audio2], etc. (array)
- duration (optional, default 5): Video duration in seconds. Set to -1 for intelligent duration (the model picks the best length). Editing mode requires -1. (integer)
- resolution (optional, default 720p): one of `480p`, `720p`. (string)
- aspect_ratio (optional, default 16:9): one of `16:9`, `4:3`, `1:1`, `3:4`, `9:16`, `21:9`, `adaptive`. Set to `adaptive` to let the model choose from the inputs. First/last-frame, editing and extension modes require `adaptive`. (string)
- generate_audio (optional, default true): Generate synchronised audio with the video, including dialogue (in double quotes in the prompt), sound effects and background music. (boolean)
- output_format (optional, default mp4): one of `mp4`, `mov`. (string)
- watermark (optional, default false): Add a watermark. (boolean)
- seed (optional): Random seed for reproducible generation; reproducibility is not guaranteed. (integer)


## Modes (they don't mix)

1. **Text to video:** prompt only.
2. **Image to video / first-and-last frame:** `image` (plus `last_frame_image`). Use it to animate a real game screenshot or painted illustration, or to morph between two frames. The aspect ratio must be `adaptive` with a last frame.
3. **Reference sets:** `reference_images` / `reference_videos` / `reference_audios`, called [Image1], [Video1], [Audio1] in the prompt. Use it to keep the game's art style, to transfer a camera move from a real gameplay clip, or to extend or edit a clip. Editing and extension need `duration: -1` and `aspect_ratio: adaptive`.


## Model output schema

```json
{"type": "string", "title": "Output", "format": "uri"}
```
A URL of the generated video.


## Example input and output

```json
{
  "seed": 42,
  "prompt": "a golden retriever puppy running across a green meadow toward the camera, slow motion, warm afternoon light",
  "duration": 5,
  "resolution": "720p"
}
```
Output: an mp4 URL (https://replicate.delivery/...).


## Project notes
- Output is at most **720p**. For a 1080p or 4K edit, upscale (ffmpeg lanczos plus light sharpening, or an upscaler model) and grade it together with the game footage so the two match.
- Write prompts as a production brief: shot type, lens, camera move, subject, light, mood, grade, duration and audio. Example: "Shot: slow aerial push-in, 35mm anamorphic, golden hour; Subject: …; Camera: …; Style: matches [Image1] painterly game art; Audio: none".
- **Content rules for this project:**
  - no graphic violence or gore;
  - no 7 October 2023 or 2023– Gaza-war content;
  - no photoreal depictions of real people saying or doing things they didn't. Painted portraits may have subtle parallax or light only;
  - keep it historically respectful.
- The safety filter sometimes flags prompts that name places or peoples ("sensitive" E005). Rephrase neutrally (landscape, city and era descriptions) and retry.
