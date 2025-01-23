#!/usr/bin/env bash

# Usage:
#   ./add_progress_all.sh [bar_height]
#
#   bar_height (optional) => defaults to 10 pixels if not supplied.
#
# Description:
#   Iterates over all *.mp4 videos in the current directory, 
#   adds a progress bar of 'bar_height' pixels, 
#   and saves them as <originalname>_tqdm.mp4.

bar_height="${1:-10}"  # default to 10 if no argument given

# Loop over all MP4 files in the folder
for input in *.mp4; do
  # If there are no .mp4 files, the loop won't run. This check skips "no match" errors.
  [ -e "$input" ] || continue

  echo "Processing: $input"

  # Strip .mp4 from the filename for the output name
  base="${input%.mp4}"
  output="${base}_tqdm.mp4"

  # Extract duration, width, height for each file
  duration=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$input")
  width=$(ffprobe -v error -select_streams v:0 -show_entries stream=width  -of csv=p=0 "$input")
  height=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$input")

  # Run ffmpeg to add progress bar
  ffmpeg -i "$input" \
    -filter_complex "
      [0:v]pad=width=${width}:height=${height}+${bar_height}:x=0:y=0:color=black[padded];
      color=c=0x4c72b0:s=${width}x${bar_height}[bar];
      [padded][bar]overlay=
        x='-W + (W/${duration})*t':
        y=${height}:
        shortest=1
    " \
    -c:a copy \
    "$output"

  echo "Completed: $output"
  echo
done

echo "All conversions completed!"
