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

OUTPUT_VIDEO_FLAGS=""
OUTPUT_VIDEO_COUNT=7

# ---------------------------

OUTPUT_AUDIO_LENGTH=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -sexagesimal resources/audio/lysterfield-lake.wav)

echo "✨ make megavideo"

for f in $input/output/dreaming/*.mov;
do
    echo "Processing $f folder..."

    file=$(basename -- "$f")
    file_ext="${file##*.}"
    file_name="${file%.*}"

    mkdir -p $input/output/compiled/$file_name/
    mkdir -p $input/output/final/$file_name/

    if [ ! -f "$output/compiled/$file_name/$file_name-video.mov" ]; then
        ffmpeg -y -i resources/words/words.mov -i $output/main-compiled-resized-images.mov -i $output/main-compiled-resized-background.mov -i $output/main-compiled-alpha.mov -i $output/main-compiled-depth.mov -i $output/main-compiled-sketch.mov -i $f -i resources/audio/lysterfield-lake.wav -shortest -map $OUTPUT_VIDEO_COUNT:a:0 -filter_complex "[0:v]hstack=inputs=$OUTPUT_VIDEO_COUNT" -t $OUTPUT_AUDIO_LENGTH -r $frames $crf $duration $output/compiled/$file_name/$file_name-video.mov
    else
        echo "✋ $output/compiled/$file_name/$file_name-video.mov already exists"
    fi

    if [ ! -f "$output/final/$file_name/video.mov" ]; then
        echo "✨ make compressed videos"
        ffmpeg -y -i $output/compiled/$file_name/$file_name-video.mov -c:v libx264 -pix_fmt yuv420p -crf 28 $output/final/$file_name/video.mov

        if [ $all ]; then
            echo "✨ including webm"
            ffmpeg -y -i $output/compiled/$file_name/$file_name-video.mov -c:v libvpx-vp9 -pix_fmt yuv420p -crf 35 -b:v 0 $output/final/$file_name/video.webm
        fi
    else
        echo "✋ $output/final/$file_name/video.mov already exists"
    fi

    if [ ! -f "$output/final/$file_name/video-small.mov" ]; then
        echo "✨ make compressed videos"
        ffmpeg -y -i $output/compiled/$file_name/$file_name-video.mov -c:v libx264 -pix_fmt yuv420p -vf "scale=iw/2:ih/2" -crf 28 $output/final/$file_name/video-small.mov

        if [ $all ]; then
            echo "✨ including webm"
            ffmpeg -y -i $output/compiled/$file_name/$file_name-video.mov -c:v libvpx-vp9 -pix_fmt yuv420p -vf "scale=iw/2:ih/2" -crf 35 -b:v 0 $output/final/$file_name/video-small.webm
        fi
    else
        echo "✋ $output/final/$file_name/video-small.mov already exists"
    fi

done

# Generating loops
for f in $input/output/dreaming/*.mov;
do
    echo "Processing loops $f folder..."

    file=$(basename -- "$f")
    file_ext="${file##*.}"
    file_name="${file%.*}"

    if [ ! -f "$output/final/$file_name/loop.mov" ]; then
        # dreaming.mov
        ffmpeg -y -i $f -ss 00:00:03 -t 00:00:05 -c:v libx264 -pix_fmt yuv420p $crf $output/compiled/$file_name/$file_name-loop.mov

        echo "✨ make compressed videos"
        ffmpeg -y -i $output/compiled/$file_name/$file_name-loop.mov -c:v libx264 -pix_fmt yuv420p -crf 28 $output/final/$file_name/loop.mov

        if [ $all ]; then
            echo "✨ including webm"
            ffmpeg -y -i $output/compiled/$file_name/$file_name-loop.mov -c:v libvpx-vp9 -pix_fmt yuv420p -crf 35 -b:v 0 $output/final/$file_name/loop.webm
        fi
    else
        echo "✨ video already exists"
    fi
 
    cp `exec find $input/dreaming/$file_name/$file_name\_*.png -prune -o -name $file_name\_00000.png  -type f -maxdepth 1 | shuf -n 1` $output/final/$file_name/00.png
    cp `exec find $input/dreaming/$file_name/$file_name\_*.png -prune -o -name $file_name\_00000.png  -type f -maxdepth 1 | shuf -n 1` $output/final/$file_name/01.png
    cp `exec find $input/dreaming/$file_name/$file_name\_*.png -prune -o -name $file_name\_00000.png  -type f -maxdepth 1 | shuf -n 1` $output/final/$file_name/02.png
    cp `exec find $input/dreaming/$file_name/$file_name\_*.png -prune -o -name $file_name\_00000.png  -type f -maxdepth 1 | shuf -n 1` $output/final/$file_name/03.png

    convert -strip -quality 85% $output/final/$file_name/00.png $output/final/$file_name/00.jpg
    convert -strip -quality 85% $output/final/$file_name/01.png $output/final/$file_name/01.jpg
    convert -strip -quality 85% $output/final/$file_name/02.png $output/final/$file_name/02.jpg
    convert -strip -quality 85% $output/final/$file_name/03.png $output/final/$file_name/03.jpg

    rm $output/final/$file_name/00.png
    rm $output/final/$file_name/01.png
    rm $output/final/$file_name/02.png
    rm $output/final/$file_name/03.png
done
