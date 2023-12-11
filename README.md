# Lysterfield Lake (Pipeline)

Video generator for the Lysterfield Lake project.

🚨 **Please note:** 🚨 This repository is largely spaghetti code, intended purely as a resource for anyone looking to dive into aspects of how [Lysterfield Lake](https://lysterfieldlake.com/) was created. It represents the tasks completed on a Mac, while the AI heavy lifting was completed using [Cog](https://github.com/replicate/cog) and a PC with a RTX 3060 GPU. Files specific to that process are in `/pc-settings/` That said, it should paint some of the picture (see what I did there?) of how the project works.

> The client for the app is available at [superhighfives/lysterfield-lake](https://github.com/superhighfives/lysterfield-lake)

✋ You can [learn more about how the project works here](https://medium.com/@superhighfives/lysterfield-lake-71345aa8c016).

<a href="https://medium.com/@superhighfives/lysterfield-lake-71345aa8c016">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/superhighfives/lysterfield-lake-pipeline/assets/449385/5ccd6397-50dd-492c-98bb-ca0c2ab4671b">
    <img src="https://github.com/superhighfives/lysterfield-lake-pipeline/assets/449385/74ed220c-6c68-4090-a91b-7d6778e78ee2">
  </picture>
</a>

## Overview

The pipeline for Lysterfield Lake is made up of a collection of bash scripts. They run a mixture of python scripts, and unix applications (like ffmpeg) to output videos and images.

On the python side, data is partially passed to and from the AI models using [Cog](https://github.com/replicate/cog). It runs three models, which it expects at the following locations on your network:

| Model         | Replicate                                                                | GitHub                                                                | Location                         |
| ------------- | ------------------------------------------------------------------------ | --------------------------------------------------------------------- | -------------------------------- |
| DiffusionCLIP | [gwang-kim/diffusionclip](https://replicate.com/gwang-kim/diffusionclip) | [gwang-kim/DiffusionCLIP](https://github.com/gwang-kim/DiffusionCLIP) | Running on http://localhost:5000 |
| ZoeDepth      | [cjwbw/zoedepth](https://replicate.com/cjwbw/zoedepth)                   | [chenxwh/ZoeDepth](https://github.com/chenxwh/ZoeDepth)               | Running on http://localhost:5005 |
| Real-ESRGAN   | [cjwbw/real-esrgan](https://replicate.com/cjwbw/real-esrgan)             | [xinntao/Real-ESRGAN](https://github.com/xinntao/Real-ESRGAN)         | Running on http://localhost:5010 |

The other models should be added to the root folder, in the paths referenced in the source files.

## Toolchain

- Cog ([Github](https://github.com/replicate/cog))
- ZoeDepth (Depthifier): [Replicate](https://replicate.com/cjwbw/zoedepth), [GitHub](https://github.com/chenxwh/ZoeDepth)
- Real-ESRGAN (Resizer): [Replicate](https://replicate.com/cjwbw/real-esrgan), [GitHub](https://github.com/xinntao/Real-ESRGAN)
- Robust Video Matting (Alphafier): [Replicate](https://replicate.com/arielreplicate/robust_video_matting), [GitHub](https://github.com/PeterL1n/RobustVideoMatting)
- Deforum Stable Diffusion (Dreamer): [Replicate](https://replicate.com/deforum/deforum_stable_diffusion), [GitHub](https://github.com/deforum/stable-diffusion)
- Diffusion CLIP (Stylizer): [Replicate](https://replicate.com/gwang-kim/diffusionclip), [GitHub](https://github.com/gwang-kim/DiffusionCLIP)
- Inpaint Anything (Inpainter): [GitHub](https://github.com/geekyutao/Inpaint-Anything/)
