#!/bin/bash

# exit when any command fails
set -e

# create a temporary directory
mkdir -p ./tmp

# create an array of images and find maximum number
images=(*.png)
max=${#images[*]}

# loop through array keys and subtract the key from maximum number to reverse
for i in "${!images[@]}"; do 
  # rename to the temporary directory, with four-digit zero padding
  mv -- "${images[$i]}" ./tmp/$(printf "%04d.png" $((i + 1)))
done

# move files back and remove temporary directory
mv ./tmp/*.png .
rmdir ./tmp
