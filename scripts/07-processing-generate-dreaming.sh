#!/bin/bash

# exit when any command fails
set -e
shopt -s nullglob
shopt -s extglob

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

mkdir -p $input/output/dreaming

# output
output=$input/output/dreaming

echo $input
echo $output

# ---------------------------

# generate folders
echo "✨ generating folders (input: $output/images, output: $output/output)"

for f in $input/dreaming/+([0-9])/;
do
    echo $f
    file=$(basename -- "$f")
    
    if [ ! -f "$output/$file.mov" ]; then
        echo "Processing $f folder..."        
        ffmpeg -y $skip -framerate 10 $duration -start_number 00001 -i $f$file\_%05d.png -vf "scale=1024:-1,fps='60',minterpolate='mi_mode=dup'" -c:v libx264 -pix_fmt yuv420p $crf $output/$file.mov
    else
        echo "✋ $output/$file.mov already exists"
    fi
done
