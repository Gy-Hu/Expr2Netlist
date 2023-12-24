#!/bin/bash

# Define the directory to move files to
trash_dir="./.trash"

# Check if the trash directory exists, if not, create it
if [ ! -d "$trash_dir" ]; then
    mkdir "$trash_dir"
fi

# List of files to move to trash
files_to_trash=(
    "ABC_opt.blif"
    "area.log"
    "EqnGenerator"
    "expr2eqn"
    "expr2eqn.hi"
    "expr2eqn.o"
    "NANDNOR.lib"
    "opt.v"
    "output.eqn"
    "sis_opt.eqn"
    "ABC_opt.eqn"
    "sis_opt.blif"
)

# Loop through the files and move them to the trash directory
for file in "${files_to_trash[@]}"; do
    if [ -e "$file" ]; then
        mv "$file" "$trash_dir"
        echo "Moved $file to $trash_dir."
    else
        echo "Warning: $file does not exist and cannot be moved."
    fi
done

echo "Trash operation complete."
