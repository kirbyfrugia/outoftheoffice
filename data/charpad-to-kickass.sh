#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <level_file>"
    exit 1
fi

level_file="$1"

# Get the base name of the level_file without the extension
base_name=$(basename "$level_file" .${level_file##*.})
echo "Base name: $base_name"

# Charpad exports dos line endings. fix first.
dos2unix "$level_file"
if [ $? -ne 0 ]; then
    echo "dos2unix command failed"
    exit 1
fi

# Delete all lines starting with the first line containing "INSERT EXAMPLE PROGRAM HERE"
sed -n '/INSERT EXAMPLE PROGRAM HERE/q;p' "$level_file" > temp_file && mv temp_file "$level_file"

# Replace all semicolon characters with double forward slashes
sed -i 's/;/\/\//g' "$level_file"

# Prepend ".var " to lines starting with a capital letter
awk '/^[A-Z]/ {printf ".var %s\n", $0; next} {print}' "$level_file" > temp_file && mv temp_file "$level_file"

# Add a colon to the end of lines starting with a lower case letter
awk '/^[a-z]/ {printf "%s:\n", $0; next} {print}' "$level_file" > temp_file && mv temp_file "$level_file"

mv "${base_name} - (8bpc, 80x11) Map.bin" "${base_name}-map.bin"
mv "${base_name} - CharAttribs_L1.bin" "${base_name}-char-attribs.bin"
mv "${base_name} - Chars.bin" "${base_name}-chars.bin"
mv "${base_name} - Tiles.bin" "${base_name}-tiles.bin"