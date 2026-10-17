## Basic model info

Model name: elevenlabs/music
Model description: Compose a song from a prompt or a composition plan


## Model inputs

- prompt (required): Description of the music you want to generate (string)
- music_length_ms (optional): Target duration of the music in milliseconds (optional, defaults to ~10 seconds) (integer)
- force_instrumental (optional): If true, removes vocal elements from the generated music (boolean)
- output_format (optional): Audio output format: mp3_standard (128kbps MP3, balanced quality/size), mp3_high_quality (192kbps MP3, higher quality), wav_16khz (16kHz WAV, good for voice), wav_22khz (22kHz WAV), wav_24khz (24kHz WAV), wav_cd_quality (44.1kHz WAV, uncompressed CD quality) (string)


## Model output schema

{
  "type": "string",
  "title": "Output",
  "format": "uri"
}

If the input or output schema includes a format of URI, it is referring to a file.


## Example inputs and outputs

Use these example outputs to better understand the types of inputs the model accepts, and the types of outputs the model returns:

### Example (https://replicate.com/p/a9b02ynfthrmc0ct64vvfh9smw)

#### Input

```json
{
  "prompt": "Upbeat electronic dance music",
  "output_format": "mp3_standard",
  "music_length_ms": 30000,
  "force_instrumental": true
}
```

#### Output

```json
"https://replicate.delivery/xezq/tt0c9fnf8qtEXUeG0eRR18fDTWiEnZdZ1EEsVoMemiKFIOAZF/tmp5oukn6ug.mp3"
```


### Example (https://replicate.com/p/bgy45ak45xrme0ct65tazpf3vr)

#### Input

```json
{
  "prompt": "Upbeat electronic dance music",
  "output_format": "wav_cd_quality",
  "music_length_ms": 5000,
  "force_instrumental": false
}
```

#### Output

```json
"https://replicate.delivery/xezq/kf2omE5XAAQSNylyi0u9Klf0PrJySO8ltXzGfel7tsRVaHQWB/tmp5d917b0p.wav"
```


### Example (https://replicate.com/p/zjvcyysyr9rm80ct65tvgr4vd0)

#### Input

```json
{
  "prompt": "Upbeat electronic dance music",
  "output_format": "wav_cd_quality",
  "music_length_ms": 30000,
  "force_instrumental": false
}
```

#### Output

```json
"https://replicate.delivery/xezq/fJaJyWArpIVSIqZnNPTUAexiaQowATMXaLNiewwSdG4GvDIrA/tmpmenp0tc3.wav"
```


## Model readme

> # elevenlabs/music
> 
> **Generate studio-grade full songs from text prompts – instrumental or with vocals – in any style imaginable.**
> 
> Create professional-quality tracks with precise control over **length**, **structure**, **vocals**, and **output format** via a simple API.
> 
> ## ✨ Key Features
> - **Text-to-Music**: Turn natural language prompts into complete songs
> - **Vocals or Instrumental**: Toggle lyrics and singing effortlessly
> - **Full Customization**:
>   |   |   |
>   |---|---|
>   | 🎼 **Structure** | Intro, verses, chorus, bridge, outro
>   | ⏱️ **Length** | Up to 5 minutes
>   | 🎛️ **Style** | Any genre: EDM, rock, orchestral, lo-fi, etc.
>   | 🔊 **Quality** | Studio-grade audio (up to 44.1kHz MP3/WAV)
> - **API-First**: Predict via HTTP, run in seconds
> - **Cost-Effective**: Pay-per-second generated
> 
> ## 🚀 Quickstart
> 
> ### Via Web
> [Try in browser](https://replicate.com/elevenlabs/music)
> 
> ## 🎵 Examples
> 
> | Prompt | Style | Vocals | Length |
> |--------|-------|--------|--------|
> | "A dreamy indie folk song about lost love, acoustic guitar and soft male vocals" | Folk | ✅ | 2:30 | 
> | "High-energy rock anthem with electric guitars, powerful chorus" | Rock | ✅ | 3:00 |
> | "Relaxing ambient pads and piano for meditation" | Ambient | ❌ | 4:00 |
> | "Futuristic synthwave cruise, 80s retro vibes, instrumental" | Synthwave | ❌ | 2:15 |
> 
> ## 🔗 Resources
> - [ElevenLabs Music Docs](https://elevenlabs.io/docs/api-reference/music/compose)
> - [Run on Replicate](https://replicate.com/elevenlabs/music)
> - [Discord Community](https://discord.gg/replicate)
> 
> ## 🙌 License & Usage
> Generated music is yours to use commercially under [ElevenLabs Music Terms](https://elevenlabs.io/music-terms). **No training on your outputs**.

