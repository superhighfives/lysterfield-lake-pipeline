from pathlib import Path
import os
import sys
import requests
import cv2
from io import BytesIO
import base64
import argparse
from datetime import datetime
from PIL import Image, ImageEnhance, ImageOps, ImageChops, ImageFilter
import skimage
import numpy as np
import torch
import torchvision.transforms as T
import matplotlib.pyplot as plt
import io
from blend_modes import multiply, screen, overlay, soft_light

# Initialize parser
parser = argparse.ArgumentParser()
parser.add_argument("-o", "--output", help="Output folder")
parser.add_argument("-i", "--input", help="Input folder")
parser.add_argument("-b", "--base", help="Base folder")
args = parser.parse_args()


def main():
    print("Starting python...")

    if not args.output:
        exit("Please specify an output folder")

    model = torch.load("./video-artline/torch_650.pkl")

    depth_url = 'http://superuniverse.local:5005/predictions'
    resized_url = 'http://superuniverse.local:5010/predictions'
    input_folder = f"{args.input}"
    output_folder = f"{args.output}"
    background_input_folder = f"{args.base}/background"
    alpha_folder = f"{args.base}/alpha"
    depth_folder = f"{args.base}/depth"
    green_folder = f"{args.base}/green"
    sketch_folder = f"{args.base}/sketch"
    resized_folder = f"{args.base}/resized"
    words_folder = f"{args.base}/words"
    resized_background_folder = f"{args.base}/resized-background"

    files = sorted(os.listdir(input_folder))
    for file in files:
        # check if the image ends with png
        if (file.endswith(".png")):
            output_path = os.path.join(
                output_folder, f'{Path(file).stem}.png')
            
            sketch_input_path = os.path.join(
                sketch_folder, f'{Path(file).stem}.png')
            dream_input_path = os.path.join(
                input_folder, f'{Path(file).stem}.png')
            words_input_path = os.path.join(
                words_folder, f'{Path(file).stem}.png')
            
            if not os.path.exists(output_path):
                print(output_folder)
                print(datetime.now(), sketch_input_path, dream_input_path, words_input_path)
                sketch_image = Image.open(sketch_input_path).resize([392, 392]).convert("L")
                
                dream_image = Image.open(dream_input_path).resize([1024, 1024]).convert("RGBA")
                
                clean_word_image = Image.open(words_input_path).resize([1024, 1024]).convert("L")
                word_image = Image.new(mode="RGBA", size=(1920, 1080), color=(255, 255, 255, 0))
                word_image.paste(dream_image, (868, 28), mask=clean_word_image)

                output_image = Image.new(mode="RGBA", size=(1920, 1080), color=(255, 255, 255, 255))
                output_image.paste(dream_image.resize(size=(800, 800)), (140, 140))

                # full_sketch_image = Image.new(mode="RGBA", size=(1920, 1080), color=(255, 255, 255, 255))
                # full_sketch_image.paste(sketch_image, (344, 548))

                background_img = np.array(output_image)  # Inputs to blend_modes need to be numpy arrays.
                background_img_float = background_img.astype(float)  # Inputs to blend_modes need to be floats.

                word_img = np.array(word_image)  # Inputs to blend_modes need to be numpy arrays.
                word_img_float = word_img.astype(float)  # Inputs to blend_modes need to be floats.

                # Blend images
                opacity = 1.0  # The opacity of the foreground that is blended onto the background is 70 %.
                combined_img_float = multiply(background_img_float, word_img_float, opacity)

                # Convert blended image back into PIL image
                blended_img = np.uint8(combined_img_float)  # Image needs to be converted back to uint8 type for PIL handling.
                blended_img_raw = Image.fromarray(blended_img)  # Note that alpha channels are displayed in black by PIL by default.
                                                                # This behavior is difficult to change (although possible).
                                                                # If you have alpha channels in your images, then you should give
                                                                # OpenCV a try.

                output_image = blended_img_raw

                output_image.save(output_path)  
                # output_image.show()
                # sys.exit('Boom')

if __name__ == "__main__":
    main()
