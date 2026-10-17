## Basic model info

Model name: tencent/hunyuan-3d-3.1
Model description: 3D models with texture fidelity and geometry precision


## Model inputs

- prompt (optional): Text description of the 3D model to generate. "
        "Either prompt OR image must be provided, but not both. "
        "Supports up to 1024 characters. (string)
- image (optional): Input image to convert to 3D. "
        "Either prompt OR image must be provided, but not both. "
        "Recommendations: simple background, no text, single object, "
        "object occupies >50% of frame. "
        "Supported formats: jpg, png, jpeg, webp. "
        "Resolution: 128-5000px per side, max 6MB. (string)
- enable_pbr (optional): Enable PBR (Physically Based Rendering) material generation. (boolean)
- face_count (optional): Number of faces (polygons) in the generated 3D model. (integer)
- generate_type (optional): Type of 3D generation. "
        "'Normal' generates textured model, "
        "'Geometry' generates white model without textures (EnablePBR has no effect). (string)


## Model output schema

{
  "type": "string",
  "title": "Output",
  "format": "uri"
}

If the input or output schema includes a format of URI, it is referring to a file.


## Example inputs and outputs

Use these example outputs to better understand the types of inputs the model accepts, and the types of outputs the model returns:

### Example (https://replicate.com/p/z9tacg1k4srmw0cw96sa36s8hg)

#### Input

```json
{
  "prompt": "An elegant and opulent 3D chair shaped like an avocado, the outer shell forming a deep green velvet seat, the pit replaced with a polished golden cushion, luxurious materials, ornate carved gold trim, subtle botanical motifs, rich emerald and gold color palette, dramatic studio lighting, ultra-detailed textures, photorealistic 3D render, high-end interior design style, soft shadows, 4K, centered on a dark neutral background",
  "enable_pbr": false,
  "face_count": 500000,
  "generate_type": "Normal"
}
```

#### Output

```json
"https://replicate.delivery/xezq/BPLeh7BF1KxxZKebNlvzq4b7eqnlEgHPRDHcmqfFbf7RpyywC/tmpks5unr_8.glb"
```


## Model readme

> # Hunyuan 3.1 3D
> 
> ## Overview
> **Hunyuan 3.1 3D** is part of Tencent’s **Hunyuan3D** family of generative AI models designed to create **high-quality 3D assets from text, images, or other inputs**.  
> The model focuses on improving geometry accuracy, texture quality, and generation speed for use in digital content production.
> 
> Typical use cases include:
> - Game development
> - Virtual and augmented reality
> - Animation and film pre-visualization
> - Product visualization and e-commerce
> - 3D printing and rapid prototyping
> 
> ---
> 
> ## Features
> 
> - **Text-to-3D Generation**  
>   Generate 3D meshes from natural language descriptions.
> 
> - **Image-to-3D Conversion**  
>   Convert reference images into textured 3D models.
> 
> - **Improved Geometry Quality**  
>   Enhanced mesh topology and surface consistency compared to earlier releases.
> 
> - **High-Resolution Texturing**  
>   Produces more realistic materials and lighting effects.
> 
> - **Pipeline Integration**  
>   Designed to integrate with common 3D workflows and tools.
> 
> ---
> 
> ## Architecture (High-Level)
> 
> Hunyuan 3.1 3D typically consists of multiple stages:
> 
> 1. **Input Encoding**
>    - Text encoder or image encoder converts input into latent representations.
> 
> 2. **Shape Generation**
>    - Diffusion or neural field models generate 3D geometry.
> 
> 3. **Mesh Reconstruction**
>    - Geometry converted into usable mesh formats.
> 
> 4. **Texture Generation**
>    - Textures synthesized and mapped to the mesh.
> 
> ---
> 
> ## Installation
> 
> > Note: Availability depends on Tencent’s official releases and licensing.
> 
> Example structure for using an API or SDK:
> 
> ```bash
> git clone https://github.com/example/hunyuan3d-demo
> cd hunyuan3d-demo
> pip install -r requirements.txt

