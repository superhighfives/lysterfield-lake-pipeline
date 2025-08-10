# Lysterfield Lake (Pipeline)

Video generator for the Lysterfield Lake project.

🚨 **Please note:** 🚨 This repository is largely spaghetti code, intended purely as a resource for anyone looking to dive into aspects of how [Lysterfield Lake](https://lysterfieldlake.com/) was created. It represents the tasks completed on a Mac, while the AI heavy lifting was completed using [Cog](https://github.com/replicate/cog) and a PC with a RTX 3060 GPU. Settings files for deforum are in `settings/`. That said, it should paint some of the picture (see what I did there?) of how the project works.

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

## File Structure Requirements

### Minimum Required Input

To start the pipeline, you only need these two video files in your input folder:

```
your-project-folder/
├── main.mov                    # Primary video file (will be cropped to square)
└── background.mov              # Background video file
```

### Additional Files for Complete Pipeline

For the full dream sequence processing (scripts 07-09), you'll also need AI-generated dream sequences:

```
your-project-folder/
├── main.mov
├── background.mov
└── dreaming/                   # AI-generated dream sequences (from Deforum/external tools)
    ├── 1/
    │   ├── 1_00001.png
    │   ├── 1_00002.png
    │   └── ... (more frames)
    ├── 2/
    │   ├── 2_00001.png
    │   ├── 2_00002.png
    │   └── ... (more frames)
    └── ... (more numbered folders)
```

**Note:** The `dreaming/` folder and its contents are generated separately using AI tools like Deforum Stable Diffusion (see `settings/`). Scripts 01-06 can run with just the two video files.

## Processing Pipeline

The scripts are numbered to run in sequential order. Each script takes `-i input_folder` as a parameter:

1. **01-initialization-generate-init.sh** - Initial video processing (crops video to square, converts to frames)
2. **02-initialization-generate-alpha.sh** - Generates alpha channel masks
3. **03-preprocessing-inpaint-background.sh** - AI-powered background removal (runs on PC with GPU)
4. **04-preprocessing-generate-background.sh** - Processes background elements with watercolor effects
5. **05-processing-generate-watercolour.sh** - Applies watercolor effects to main content
6. **06-processing-generate-other.sh** - Generates depth maps, resized versions, and sketches
7. **07-processing-generate-dreaming.sh** - Processes AI dream sequences into videos
8. **08-postprocessing-generate-dreams.sh** - Further processes dream content with effects
9. **09-output-generate-videos.sh** - Final video compilation and compression
10. **10-output-generate-title.sh** - Processes title content

### Usage Example

```bash
# Run each script in order with your input folder
./scripts/01-initialization-generate-init.sh -i /path/to/your/project-folder
./scripts/02-initialization-generate-alpha.sh -i /path/to/your/project-folder
# ... continue with remaining scripts

# Optional parameters:
# -f frames per second (default: 60)
# -l length/duration limit
# -o offset/start time
# -q quality/CRF value
# -a include all formats (webm, etc.)
```

**Note:** Script 03 (`03-preprocessing-inpaint-background.sh`) has hardcoded paths for PC processing and requires the Inpaint Anything environment.

## Toolchain

- Cog ([Github](https://github.com/replicate/cog))
- ZoeDepth (Depthifier): [Replicate](https://replicate.com/cjwbw/zoedepth), [GitHub](https://github.com/chenxwh/ZoeDepth)
- Real-ESRGAN (Resizer): [Replicate](https://replicate.com/cjwbw/real-esrgan), [GitHub](https://github.com/xinntao/Real-ESRGAN)
- Robust Video Matting (Alphafier): [Replicate](https://replicate.com/arielreplicate/robust_video_matting), [GitHub](https://github.com/PeterL1n/RobustVideoMatting)
- Deforum Stable Diffusion (Dreamer): [Replicate](https://replicate.com/deforum/deforum_stable_diffusion), [GitHub](https://github.com/deforum/stable-diffusion)
- Diffusion CLIP (Stylizer): [Replicate](https://replicate.com/gwang-kim/diffusionclip), [GitHub](https://github.com/gwang-kim/DiffusionCLIP)
- Inpaint Anything (Inpainter): [GitHub](https://github.com/geekyutao/Inpaint-Anything/)
