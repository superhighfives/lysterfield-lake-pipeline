#!/bin/bash

# exit when any command fails
set -e

# handle options
while getopts f:i:l:o:q: flag
do
    case "${flag}" in
        f) frames=${OPTARG};;      # num of frames per second
        i) input=${OPTARG};;       # path to input folder
        l) length=${OPTARG};;      # additional ffmpeg timecode
        o) offset=${OPTARG};;      # additional ffmpeg timecode
        q) quality=${OPTARG};;     # qualty
    esac
done

# set defaults
if [ -z "$frames" ]; then frames="60"; fi

# handle required fields
if [ -z "$input" ]; then
    echo "Please provide an input"
    exit 1
fi

# handle optional fields
if [ $length ]; then duration="-t $length"; fi

if [ $offset ]; then skip="-ss $offset"; fi

# handle optional fields
if [ $quality ]; then crf="-crf $quality"; fi

# output
output=$input/output

# ---------------------------

f="$input/background.mov"
echo "Processing $f file..."

file=$(basename -- "$f")
file_ext="${file##*.}"
file_name="${file%.*}"

# create dir
mkdir -p $output/main/background/
mkdir -p $output/main/output/background/

# convert to images
if [ ! -f "$output/main/background/0001.png" ]; then
  echo "✨ convert to images at $frames frames per second"
  ffmpeg -y $skip -i $f -r $frames $duration $output/main/background/%04d.png
else
  echo "✨ images already exist"
fi

echo "✨ do stuff with cog"
if conda env list | grep ".*watercolour-generator.*" >/dev/null 2>&1; then
    echo "Conda exists"
else 
    conda create --name watercolour-generator python=3.9 --file requirements.txt
fi

# process images
source ~/miniconda3/bin/activate watercolour-generator
python --version
python main.py --input background --output $output/main

echo "Finished generating watercolour images"

if [ ! -f "$output/main-compiled-background.mov" ]; then
    # if crop and move video
    ffmpeg -y -framerate $frames $duration -i $output/main/output/background/%04d.png -c:v libx264 -pix_fmt yuv420p -vf scale=1024:-1 $crf $output/main-compiled-background.mov
else
    echo "✨ video already exists"
fi
