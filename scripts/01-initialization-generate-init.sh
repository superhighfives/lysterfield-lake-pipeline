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

f="$input/main.mov"
echo "Processing $f file..."

file=$(basename -- "$f")
file_ext="${file##*.}"
file_name="${file%.*}"

# generate folders
echo "✨ generating folders (input: $output/images, output: $output/output)"

mkdir -p $output/$file_name/{images,output}
mkdir -p $output/$file_name/output/{images,depth,alpha,resized,green,resized-background}

# if crop and move video
echo "✨ move video (and possibly resize $input video to square)"
ffmpeg -y $skip -i $f $duration -filter:v crop=w='min(min(iw\,ih)\,2160)':h='min(min(iw\,ih)\,2160)',scale=2160:2160,setsar=1 $output/$file_name/$file_name-cropped.mov

# convert to images
echo "✨ convert to images at $frames frames per second"
ffmpeg -y -i $output/$file_name/$file_name-cropped.mov -r $frames $duration $output/$file_name/images/%04d.png

# Generate original
ffmpeg -y -framerate $frames $duration -i $output/$file_name/images/%04d.png -c:v libx264 -pix_fmt yuv420p -vf scale=1024:-1 $crf $output/$file_name-compiled-original.mov

# Generate alpha
ffmpeg -y -framerate $frames $duration -i $output/$file_name/images/%04d.png -c:v libx264 -pix_fmt yuv420p $crf $output/$file_name-compiled-full.mov
