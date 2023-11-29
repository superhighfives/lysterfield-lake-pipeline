#!/bin/bash

# exit when any command fails
set -e

# handle options
while getopts l: flag
do
    case "${flag}" in
        l) length=${OPTARG};;      # additional ffmpeg timecode
    esac
done

# set defaults
if [ -z "$length" ]; then length="5"; fi

# output
input=/mnt/c/Users/hi/Documents/Dreaming/Processing/input
output=/mnt/c/Users/hi/Documents/Dreaming/Processing/output
splits=/mnt/c/Users/hi/Documents/Dreaming/Processing/splits
final=/mnt/c/Users/hi/Documents/Dreaming/Processing/final

# ---------------------------

# generate folders
echo "✨ generating folders"
mkdir -p $input
mkdir -p $output
mkdir -p $splits
mkdir -p $final

if [ ! -f "$splits/main-compiled-original-000.mov" ]; then
    # generate splits
    ffmpeg -y -i $input/main-compiled-original.mov -c:v libx264 -pix_fmt yuv420p -map 0 -segment_time $length -crf 23 -sc_threshold 0 -force_key_frames "expr:gte(t,n_forced*1)" -f segment -reset_timestamps 1 $splits/main-compiled-original-%03d.mov
else
    echo "✨ $splits/main-compiled-original-000.mov already exists"
fi

eval "$(/home/superhighfives/miniconda3/bin/conda shell.zsh hook)"
conda activate inpaint-anything

for f in $splits/*.mov;
do
    echo "Processing $f file..."

    file=$(basename -- "$f")
    file_ext="${file##*.}"
    file_name="${file%.*}"

    if [ ! -f "$output/$file_name.mp4" ]; then
        python remove_anything_video.py \
        --input_video $f \
        --coords_type click \
        --point_coords 256 256 \
        --point_labels 1 \
        --dilate_kernel_size 30 \
        --output_dir ./results \
        --sam_model_type "vit_h" \
        --sam_ckpt ./pretrained_models/sam_vit_h_4b8939.pth \
        --lama_config lama/configs/prediction/default.yaml \
        --lama_ckpt ./pretrained_models/big-lama \
        --tracker_ckpt vitb_384_mae_ce_32x4_ep300 \
        --vi_ckpt ./pretrained_models/sttn.pth \
        --mask_idx 2 \
        --fps 60

        cp ./results/removed_w_mask_30.mp4 $output/$file_name.mp4
    else
        echo "✨ $output/$file_name.mp4 already exists"
    fi
done

if [ ! -f "$output/final/video.mp4" ]; then
    # generate splits
    ffmpeg -safe 0 -f concat -i <(find $output -type f -name '*.mp4' -printf "file '%p'\n" | sort) -c copy $final/background.mov
else
    echo "✨ $final/background.mp4 already exists"
fi
