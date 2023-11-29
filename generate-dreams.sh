#!/bin/bash

# exit when any command fails
set -e

# handle options
while getopts f:i:l:o:q:a: flag
do
    case "${flag}" in
        f) frames=${OPTARG};;      # num of frames per second
        i) input=${OPTARG};;       # path to input folder
        l) length=${OPTARG};;      # additional ffmpeg timecode
        o) offset=${OPTARG};;      # additional ffmpeg timecode
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

if [ $offset ]; then skip="-ss $offset"; fi

# handle optional fields
if [ $quality ]; then crf="-crf $quality"; fi

# output
output=$input/output

OUTPUT_AUDIO_LENGTH=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -sexagesimal resources/audio/lysterfield-lake.wav)

# ---------------------------

echo "✨ make megavideo"

for f in $input/output/dreaming/*.mov;
do
    echo "Processing $f folder..."

    file=$(basename -- "$f")
    file_ext="${file##*.}"
    file_name="${file%.*}"

    mkdir -p $output/dreams/$file_name/input
    mkdir -p $output/dreams/$file_name/output

    # generate images
    if [ ! -f "$output/dreams/$file_name/input/0001.png" ]; then
        ffmpeg -y -i $f -r $frames $duration $output/dreams/$file_name/input/%04d.png
    else
        echo "$output/dreams/$file_name/input/0001.png exists"
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
    python dreams.py --input $output/dreams/$file_name/input --output $output/dreams/$file_name/output --base $output/main/output

    if [ ! -f "$output/dreams/$file_name/$file_name.mov" ]; then
        ffmpeg -y $skip -framerate $frames -i $output/dreams/$file_name/output/%04d.png -i resources/audio/lysterfield-lake.wav -shortest -t $OUTPUT_AUDIO_LENGTH -c:v libx264 -pix_fmt yuv420p $crf $output/dreams/$file_name/$file_name.mov
    else
        echo "✨ video already exists"
    fi

done
