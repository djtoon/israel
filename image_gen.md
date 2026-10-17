## Basic model info

Model name: openai/gpt-image-2.5-flare
Model description: OpenAI's fastest model for high-quality, everyday image generation. Generate and edit images from text and image inputs with strong instruction following and sharp text rendering.


## Model inputs

- prompt (required): A text description of the desired image (string)
- openai_api_key (optional): Your OpenAI API key (optional - uses proxy if not provided) (string)
- aspect_ratio (optional): The size of the generated image. Use 'auto' to let the model pick. Sizes above 2560x1440 are experimental and may give more variable results. (string)
- input_images (optional): A list of images to use as input for the generation (array)
- number_of_images (optional): Number of images to generate (1-10) (integer)
- quality (optional): The quality of the generated image. Higher quality takes longer and costs more. (string)
- background (optional): Set whether the background is transparent or opaque or choose automatically (string)
- output_compression (optional): Compression level (0-100%) (integer)
- output_format (optional): Output format (string)
- moderation (optional): Content moderation level (string)
- user_id (optional): An optional unique identifier representing your end-user. This helps OpenAI monitor and detect abuse. (string)


## Model output schema

{
  "type": "array",
  "items": {
    "type": "string",
    "format": "uri"
  },
  "title": "Output"
}

If the input or output schema includes a format of URI, it is referring to a file.


## Example inputs and outputs

Use these example outputs to better understand the types of inputs the model accepts, and the types of outputs the model returns:

### Example (https://replicate.com/p/frfaqghtzhrmy0d0gamrt9em6g)

#### Input

```json
{
  "prompt": "A cozy bookstore cafe interior at golden hour, warm lighting, photorealistic",
  "quality": "high",
  "aspect_ratio": "3:2"
}
```

#### Output

```json
[
  "https://replicate.delivery/xezq/pYqqAv3ze9wkQSANXVh4pTS7BpnGOsLRd5BleDjeqsRl3DXuA/tmp6tx3388z.webp"
]
```


## Model readme

> # GPT Image 2.5 Flare
> 
> GPT Image 2.5 Flare is OpenAI's fastest model for high-quality, everyday image generation. Generate images from text or edit existing images with instruction-following control, at speed.
> 
> ## What it does
> 
> Flare handles two workflows: generating images from text descriptions, and editing existing images with specific instructions. It's the fast option in the GPT Image 2.5 line — tuned for high-volume, everyday generation where speed matters.
> 
> When you pass reference images, Flare processes them at high fidelity automatically. Pass one image to edit it, or pass multiple images to combine styles, subjects, or references into a single output.
> 
> ## Quality settings
> 
> Flare supports six quality settings: `low`, `medium`, `high`, `xhigh`, `max`, and `auto` (the default). Lower quality is faster and cheaper; `xhigh` and `max` push detail and fidelity further for final assets. Start with `low` for drafts and step up when the image needs it.
> 
> ## Key capabilities
> 
> **Photorealism and detail**: Natural-looking images with accurate lighting, believable materials, and rich textures.
> 
> **Text rendering**: Dense text, small lettering, and complex layouts like infographics, UI mockups, and marketing materials.
> 
> **Precise editing**: Targeted changes without reinterpreting the entire image. The model preserves identity, composition, and lighting while you adjust specific elements.
> 
> **Style control**: Apply consistent visual styles across different subjects, or transfer the look of one image to another with minimal prompting.
> 
> ## Use cases
> 
> **Image generation**: Infographics, logos, UI mockups, photorealistic scenes, comic strips, marketing visuals — at high volume.
> 
> **Image editing**: Style transfer, virtual clothing try-ons, product mockups, text translation in images, lighting adjustments, object removal, scene compositing.
> 
> **Character consistency**: Build multi-page illustrations where characters look the same across different scenes.
> 
> ## How to get good results
> 
> **Be specific**: Instead of "make it better," say "add soft coastal daylight" or "change the red hat to light blue velvet."
> 
> **Use photo language for realism**: Mention lens type, lighting quality, and framing. "Shot with a 50mm lens, soft daylight, shallow depth of field" gets you closer to real photography.
> 
> **Lock what shouldn't change**: When editing, state what must stay the same. "Change only the lighting, preserve the subject's face, pose, and clothing."
> 
> **Put text in quotes**: For readable text, put the exact copy in "quotes" and describe the typography.
> 
> ## Inputs
> 
> - `prompt`: What you want to generate or how to edit the input
> - `input_images`: One or more reference images (for editing or composing)
> - `aspect_ratio`: Named ratios (`1:1`, `3:2`, `2:3`, `4:3`, `3:4`, `16:9`, `9:16`), `auto`, or explicit sizes like `1024x1024`
> - `quality`: `low`, `medium`, `high`, `xhigh`, `max`, or `auto`
> - `number_of_images`: Generate up to 10 images in a single call
> - `output_format`: `webp` (default), `png`, or `jpeg`
> - `background`: `auto`, `transparent`, or `opaque`
> - `moderation`: `auto` (default) or `low` for less strict content filtering
> - `openai_api_key`: Optional — bring your own OpenAI API key to pay OpenAI directly
> 
> You can try this model on the Replicate Playground at [replicate.com/playground](https://replicate.com/playground).

