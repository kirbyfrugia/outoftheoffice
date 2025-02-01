#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <level_file>"
    exit 1
fi

level_file="$1"

# Charpad exports dos line endings. fix first.
dos2unix "$level_file"
if [ $? -ne 0 ]; then
    echo "dos2unix command failed"
    exit 1
fi

# Replace all semicolon characters with double forward slashes
sed -i 's/;/\/\//g' "$level_file"

# Prepend ".var " to lines starting with a capital letter
awk '/^[A-Z]/ {printf ".var %s\n", $0; next} {print}' "$level_file" > temp_file && mv temp_file "$level_file"

# Add a colon to the end of lines starting with a lower case letter
awk '/^[a-z]/ {printf "%s:\n", $0; next} {print}' "$level_file" > temp_file && mv temp_file "$level_file"