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
import torch
import torchvision.transforms as T
import matplotlib.pyplot as plt
import io
from blend_modes import multiply, screen, overlay, soft_light

# Initialize parser
parser = argparse.ArgumentParser()
parser.add_argument("-o", "--output", help="Output folder")
parser.add_argument("-i", "--input", help="Input folder")
args = parser.parse_args()


def main():
    print("Starting python...")

    if not args.output:
        exit("Please specify an output folder")

    model = torch.load("./video-artline/torch_650.pkl")

    depth_url = 'http://superuniverse.local:5005/predictions'
    resized_url = 'http://superuniverse.local:5010/predictions'
    input_folder = f"{args.output}/{args.input}"
    background_input_folder = f"{args.output}/output/background"
    alpha_folder = f"{args.output}/output/alpha"
    output_folder = f"{args.output}/output/{args.input}"
    depth_folder = f"{args.output}/output/depth"
    photos_folder = f"{args.output}/images"
    green_folder = f"{args.output}/output/green"
    sketch_folder = f"{args.output}/output/sketch"
    resized_folder = f"{args.output}/output/resized"
    resized_background_folder = f"{args.output}/output/resized-background"

    if not os.path.exists(output_folder):
        os.mkdir(output_folder)
        print("Directory '%s' created" % output_folder)

    if not os.path.exists(f"{args.output}/output/depth"):
        os.mkdir(f"{args.output}/output/depth")
        print("Directory '%s' created" % f"{args.output}/output/depth")

    if not os.path.exists(f"{args.output}/output/resized"):
        os.mkdir(f"{args.output}/output/resized")
        print("Directory '%s' created" % f"{args.output}/output/resized")

    if not os.path.exists(f"{args.output}/output/green"):
        os.mkdir(f"{args.output}/output/green")
        print("Directory '%s' created" % f"{args.output}/output/green")

    if not os.path.exists(f"{args.output}/output/sketch"):
        os.mkdir(f"{args.output}/output/sketch")
        print("Directory '%s' created" % f"{args.output}/output/sketch")

    print(input_folder)
    files = sorted(os.listdir(input_folder))
    for file in files:
        # check if the image ends with png
        if (file.endswith(".png")):
            output_path = os.path.join(
                output_folder, f'{Path(file).stem}.png')

            green_image_path = os.path.join(input_folder, file)
            green_mask_path = os.path.join(alpha_folder, file)
            green_output_path = os.path.join(
                green_folder, f'{Path(file).stem}.png')

            if not os.path.exists(green_output_path):
                print(datetime.now(), green_image_path, green_mask_path, green_output_path)
                mask_image = Image.open(green_mask_path).resize([1024, 1024]).convert("L")
                full_image = Image.open(green_image_path).resize([1024, 1024]).convert("RGBA")
                new_image = Image.new(mode="RGBA", size=full_image.size, color=(0, 0, 0, 0))
                new_image.paste(full_image, mask=mask_image)
                new_image.convert("RGB").save(green_output_path)
            else:
                print("File already exists: %s" % green_output_path)
           

            depth_input_path = green_output_path
            depth_output_path = os.path.join(
                depth_folder, f'{Path(file).stem}.png')

            if not os.path.exists(depth_output_path):
                print(datetime.now(), depth_input_path, depth_output_path)
                img = cv2.imread(depth_input_path)
                png_img = cv2.imencode('.png', img)
                b64_string = base64.b64encode(png_img[1]).decode('utf-8')
                payload = {'input': {'image': f'data:image/png;base64,{b64_string}'}}
                headers = {'content-type': 'application/json'}
                r = requests.post(depth_url, json=payload,
                                    headers=headers, stream=True)
                if r.status_code == 200:
                    json = r.json()
                    resource = json['output'].partition(",")[2]
                    imgdata = base64.b64decode(resource)
                    final_output = Image.open(BytesIO(imgdata))
                    na = np.array(final_output)
                    img_new = skimage.exposure.adjust_gamma(na, 1.0/2.2)
                    img_new = skimage.exposure.rescale_intensity(img_new, (235,255))
                    pi = Image.fromarray(img_new)
                    pi.save(depth_output_path)
                else:
                    raise Exception("Error: %s" % r.status_code)
            else:
                print("File already exists: %s" % depth_output_path)


            resized_input_path = output_path
            resized_output_path = os.path.join(
                resized_folder, f'{Path(file).stem}.png')

            if not os.path.exists(resized_output_path):
                print(datetime.now(), resized_input_path, resized_output_path)
                img = cv2.imread(resized_input_path)
                png_img = cv2.imencode('.png', img)
                b64_string = base64.b64encode(png_img[1]).decode('utf-8')
                payload = {'input': {'img': f'data:image/png;base64,{b64_string}',
                                     'version': f'General - RealESRGANplus'}}
                headers = {'content-type': 'application/json'}
                r = requests.post(resized_url, json=payload,
                                  headers=headers, stream=True)
                if r.status_code == 200:
                    json = r.json()
                    resource = json['output'].partition(",")[2]
                    imgdata = base64.b64decode(resource)
                    with open(resized_output_path, 'wb') as f:
                        f.write(imgdata)
                else:
                    raise Exception("Error: %s" % r.status_code)
            else:
                print("File already exists: %s" % resized_output_path)

            
            resized_background_input_path = os.path.join(background_input_folder, file)
            resized_background_output_path = os.path.join(
                resized_background_folder, f'{Path(file).stem}.png')

            if not os.path.exists(resized_background_output_path):
                print(datetime.now(), resized_background_input_path, resized_background_output_path)
                img = cv2.imread(resized_background_input_path)
                png_img = cv2.imencode('.png', img)
                b64_string = base64.b64encode(png_img[1]).decode('utf-8')
                payload = {'input': {'img': f'data:image/png;base64,{b64_string}',
                                     'version': f'General - RealESRGANplus'}}
                headers = {'content-type': 'application/json'}
                r = requests.post(resized_url, json=payload,
                                  headers=headers, stream=True)
                if r.status_code == 200:
                    json = r.json()
                    resource = json['output'].partition(",")[2]
                    imgdata = base64.b64decode(resource)
                    with open(resized_background_output_path, 'wb') as f:
                        f.write(imgdata)
                else:
                    raise Exception("Error: %s" % r.status_code)
            else:
                print("File already exists: %s" % resized_background_output_path)

       

            sketch_image_path = os.path.join(input_folder, file)
            sketch_mask_path = os.path.join(alpha_folder, file)
            sketch_output_path = os.path.join(
                sketch_folder, f'{Path(file).stem}.png')

            if not os.path.exists(sketch_output_path):
                print(datetime.now(), sketch_image_path, sketch_mask_path, sketch_output_path)
                mask_image = Image.open(sketch_mask_path).resize([1024, 1024]).convert("L")
                full_image = Image.open(sketch_image_path).resize([1024, 1024]).convert("RGBA")
                new_image = Image.new(mode="RGBA", size=full_image.size, color=(255, 255, 255, 255))
                new_image.paste(full_image, mask=mask_image)
                new_image = new_image.convert("RGBA")

                background_img_raw = new_image  # RGBA image
                background_img = np.array(background_img_raw)  # Inputs to blend_modes need to be numpy arrays.
                background_img_float = background_img.astype(float)  # Inputs to blend_modes need to be floats.

                # Import foreground image
                foreground_img_raw = Image.open(depth_output_path).resize([1024, 1024]).convert("RGBA")  # RGBA image
                foreground_img = np.array(foreground_img_raw)  # Inputs to blend_modes need to be numpy arrays.
                foreground_img_float = foreground_img.astype(float)

                opacity = 0.5  # The opacity of the foreground that is blended onto the background is 70 %.
                brightness = 1.4
                contrast = 1.0

                blended_img_float = soft_light(background_img_float, foreground_img_float, opacity)

                blended_img = np.uint8(blended_img_float)  # Image needs to be converted back to uint8 type for PIL handling.
                blended_img_raw = Image.fromarray(blended_img)
                tensor_img = blended_img_raw.convert("RGB")

                tensor_img = ImageEnhance.Brightness(tensor_img).enhance(brightness)
                tensor_img = ImageEnhance.Contrast(tensor_img).enhance(contrast)

                with torch.no_grad():
                    img_t = T.ToTensor()(tensor_img.resize([300,300]))
                    mean = torch.as_tensor([0.4850, 0.4560, 0.4060])
                    std = torch.as_tensor([0.2290, 0.2240, 0.2250])
                    img_t = (img_t-mean[...,None,None]) / std[...,None,None]
                    img_t = img_t[None]
                    p,img_hr,b = model(img_t)[0]
                    img_hr = img_hr*std[...,None,None] + mean[...,None,None] 
                    img_hr_np = img_hr.to("cpu").numpy()
                    img_hr_np = img_hr_np.transpose((1,2,0))

                plt.box(False)
                fig,ax = plt.subplots(figsize=(10.24, 10.24))
                ax.axis('off')
                ax.imshow(img_hr_np, 'binary')
                img_buf = io.BytesIO()
                ax.get_figure().savefig(img_buf, bbox_inches="tight", pad_inches = 0)

                im = Image.open(img_buf)
                im = im.resize([1024, 1024], resample=Image.Resampling.BILINEAR).convert('L')
                im.save(sketch_output_path)
                # im.show()
                # exit(0)
                img_buf.close()
            else:
                print("File already exists: %s" % sketch_output_path)
            

if __name__ == "__main__":
    main()
