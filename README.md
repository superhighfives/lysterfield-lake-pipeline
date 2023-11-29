# Lysterfield Lake (Pipeline)

Video generator for the Lysterfield Lake project.

🚨 **Please note:** 🚨 This repository is largely spaghetti code, intended purely as a resource for anyone looking to dive into aspects of how [Lysterfield Lake](https://lysterfieldlake.com/) was created. It represents the tasks completed on a Mac, while the AI heavy lifting was completed using Cog and a PC with a RTX 3060 GPU. Files specific to that process are in `/pc-settings/` That said, it should paint some of the picture (see what I did there?) of how the project works.

> The client for the app is available at [superhighfives/lysterfield-lake](https://github.com/superhighfives/lysterfield-lake)

✋ You can [learn more about how the project works here](https://medium.com/@superhighfives/lysterfield-lake-71345aa8c016).

<a href="https://medium.com/@superhighfives/lysterfield-lake-71345aa8c016">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/superhighfives/lysterfield-lake/assets/449385/5b88718d-d18d-426d-9aea-307b9404de90">
    <img src="https://github.com/superhighfives/lysterfield-lake/assets/449385/a29f28ee-e5a6-4268-98f0-ab35a1f0448b">
  </picture>
</a>

## Toolchain

- Cog ([Github](https://github.com/replicate/cog))
- ZoeDepth (Depthifier): [Replicate](https://replicate.com/cjwbw/zoedepth), [GitHub](https://github.com/chenxwh/ZoeDepth)
- Real-ESRGAN (Resizer): [Replicate](https://replicate.com/cjwbw/real-esrgan), [GitHub](https://github.com/xinntao/Real-ESRGAN)
- Robust Video Matting (Alphafier): [Replicate](https://replicate.com/arielreplicate/robust_video_matting), [GitHub](https://github.com/PeterL1n/RobustVideoMatting)
- Deforum Stable Diffusion (Dreamer): [Replicate](https://replicate.com/deforum/deforum_stable_diffusion), [GitHub](https://github.com/deforum/stable-diffusion)
- Diffusion CLIP (Stylizer): [Replicate](https://replicate.com/gwang-kim/diffusionclip), [GitHub](https://github.com/gwang-kim/DiffusionCLIP)
- Inpaint Anything (Inpainter): [GitHub](https://github.com/geekyutao/Inpaint-Anything/)
