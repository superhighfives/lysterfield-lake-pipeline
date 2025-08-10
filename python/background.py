from pathlib import Path
import os
import requests
import cv2
from io import BytesIO
import base64
import argparse
from datetime import datetime
from PIL import Image, ImageEnhance, ImageOps, ImageChops, ImageFilter
import skimage
import numpy as np

# Initialize parser
parser = argparse.ArgumentParser()
parser.add_argument("-o", "--output", help="Output folder")
parser.add_argument("-i", "--input", help="Input folder")
args = parser.parse_args()


def main():
    print("Starting python...")

    if not args.output:
        exit("Please specify an output folder")

    url = 'http://superuniverse.local:5000/predictions'
    input_folder = f"{args.output}/{args.input}"
    output_folder = f"{args.output}/output/{args.input}"
    edit = "ImageNet style transfer - Watercolor art"
    step = "12"

    if not os.path.exists(output_folder):
        os.mkdir(output_folder)
        print("Directory '%s' created" % output_folder)

    files = sorted(os.listdir(input_folder))
    for file in files:
        # check if the image ends with png
        if (file.endswith(".png")):
            input_path = os.path.join(input_folder, file)
            output_path = os.path.join(
                output_folder, f'{Path(file).stem}.png')

            if not os.path.exists(output_path):
                print(datetime.now(), input_path, output_path)
                img = cv2.imread(input_path)
                png_img = cv2.imencode('.png', img)
                b64_string = base64.b64encode(png_img[1]).decode('utf-8')
                payload = {'input': {'image': f'data:image/png;base64,{b64_string}',
                                     'n_test_step': f'{step}', 'edit_type': f'{edit}'}}
                headers = {'content-type': 'application/json'}
                r = requests.post(url, json=payload,
                                  headers=headers, stream=True)
                if r.status_code == 200:
                    json = r.json()
                    resource = json['output'].partition(",")[2]
                    imgdata = base64.b64decode(resource)
                    with open(output_path, 'wb') as f:
                        f.write(imgdata)
                else:
                    raise Exception("Error: %s" % r.status_code)
            else:
                print("File already exists: %s" % output_path)

if __name__ == "__main__":
    main()
