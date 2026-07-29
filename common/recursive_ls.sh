#!/bin/bash

# Recursive ls -l from current directory

recursive_ls() {
    local dir="$1"

    echo
    echo "===== $dir ====="
    ls -l "$dir"

    for item in "$dir"/*; do
        if [ -d "$item" ]; then
            recursive_ls "$item"
        fi
    done
}

recursive_ls $1

