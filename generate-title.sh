#!/bin/bash

# exit when any command fails
set -e

# handle options
while getopts f:i:l:q:a: flag
do
    case "${flag}" in
        f) frames=${OPTARG};;      # num of frames per second
        i) input=${OPTARG};;       # path to input folder
        l) length=${OPTARG};;      # additional ffmpeg timecode
        q) quality=${OPTARG};;     # qualty
        a) all=${OPTARG};;         # encode all
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

# handle optional fields
if [ $quality ]; then crf="-crf $quality"; fi

# output
output=$input/output

OUTPUT_VIDEO_FLAGS=""
OUTPUT_VIDEO_COUNT=2

# ---------------------------

f="$input/main.mov"
echo "Processing $f file..."

file=$(basename -- "$f")
file_ext="${file##*.}"
file_name="${file%.*}"

echo "✨ make title video"

echo "✨ make compressed videos"
ffmpeg -y -i resources/words/title.mov -c:v libx264 -pix_fmt yuv420p -crf 28 $output/title.mov

if [ $all ]; then
    echo "✨ including webm"
    ffmpeg -y -i resources/words/title.mov -c:v libvpx-vp9 -pix_fmt yuv420p -crf 35 -b:v 0 $output/title.webm
fi

