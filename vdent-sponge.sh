#!/bin/bash

if [[ -d "$1" ]]; then
    for file in "$1"/*; do
        filename=$(basename "$file")
        extension="${filename##*.}"
        filename="${filename%.*}"
        if [[ "$extension" == "sv" ]]; then
            echo "indenting '$file'..."
            vdent -s 3 < "$file" | sponge "$file"
            echo "indented '$file'..."
        fi
    done
elif [[ -e "$1" ]]; then
    filename=$(basename "$1")
    extension="${filename##*.}"
    filename="${filename%.*}"
    if [[ "$extension" == "sv" ]]; then
        echo "indenting '$1'..."
        vdent -s 3 < "$1" | sponge "$1"
        echo "indented '$1'"
    fi
fi

