#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <sprites_file>"
    exit 1
fi

sprites_file="$1"

# Get the base name of the sprites_file without the extension
base_name=$(basename "$sprites_file" .${sprites_file##*.})
echo "Base name: $base_name"

# Charpad exports dos line endings. fix first.
dos2unix "$sprites_file"
if [ $? -ne 0 ]; then
    echo "dos2unix command failed"
    exit 1
fi

echo ".segment $base_name [start=\$5000]" | cat - "$sprites_file" > temp_file && mv temp_file "$sprites_file"

# Replace all semicolon characters with double forward slashes
sed -i 's/;/\/\//g' "$sprites_file"

# Prepend ".var " to lines starting with a letter that have an equals
awk -v var="$base_name" '/^[A-Za-z].*=/{printf ".var %s_%s\n", var, $0; next} {print}' "$sprites_file" > temp_file && mv temp_file "$sprites_file"

# Delete all lines starting with * =
sed '/^\* =/d' "$sprites_file" > temp_file && mv temp_file "$sprites_file"

# Append a semi-colon to all lines that start with a lower case letter
awk '/^[a-z].*/{printf "%s:\n", $0; next} {print}' "$sprites_file" > temp_file && mv temp_file "$sprites_file"
