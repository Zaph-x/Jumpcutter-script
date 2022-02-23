#!/usr/bin/env bash

process () {
    FILE=$(echo "$1"| sed -r "s/'//g")
    EXT="${FILE##*.}"
    FILE_NAME="${FILE%.*}"
    BASE="$(basename "$FILE_NAME")"
    echo "Generating segments"
    
    ffmpeg -loglevel error -i "$FILE" -map 0 -segment_time 00:10:00 -f segment -reset_timestamps 1 -filter:v fps=30 "./in/segment%03d.$EXT"
    for f in ./in/segment*.$EXT; do
            echo "$f"
            jumpcutter -f "$f" --silent-threshold 0.1 --frame-margin 6 -fps 30 -o "./in/NEW_$(basename $f)"
    done
    echo "Writing to input file"
    for new_f in ./in/NEW_*.$EXT; do
        echo "file '$new_f'" >> input.txt
    done
    ffmpeg -loglevel error -f concat -safe 0 -i input.txt -c copy "./out/$BASE-ALTERED.$EXT"
    rm input.txt
    mkdir "./out/$BASE"
    mv "$FILE" "out/$BASE"
    mv ./in/NEW_* "./out/$BASE/"
    rm ./in/segment*
}

for f in ./in/*; do process "'$f'"; done

