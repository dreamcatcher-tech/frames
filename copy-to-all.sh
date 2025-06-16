#!/bin/bash

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <path-to-file>"
    echo "Example: $0 dreamcatcher-mock/.github/workflows/deploy.yml"
    echo "This will copy the file to all other frame directories preserving the path structure"
    exit 1
fi

FILE_PATH="$1"

if [ ! -f "$FILE_PATH" ]; then
    echo "Error: File '$FILE_PATH' does not exist"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

SOURCE_DIR="$(echo "$FILE_PATH" | cut -d'/' -f1)"
RELATIVE_PATH="${FILE_PATH#$SOURCE_DIR/}"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' does not exist"
    exit 1
fi

echo "Starting file copy process..."
echo "Working from: $SCRIPT_DIR"
echo "Source file: $FILE_PATH"
echo "Source directory: $SOURCE_DIR"
echo "Relative path within source: $RELATIVE_PATH"
echo "Will copy to all directories except: $SOURCE_DIR"
echo ""

COPIED_COUNT=0

for dir in */; do
    if [ -d "$dir" ]; then
        dir_clean="${dir%/}"
        
        if [ "$dir_clean" = "$SOURCE_DIR" ]; then
            echo "Skipping $dir (source directory)"
            continue
        fi
        
        echo "Copying to $dir"
        
        TARGET_PATH="$dir_clean/$RELATIVE_PATH"
        TARGET_DIR="$(dirname "$TARGET_PATH")"
        
        if [ ! -d "$TARGET_DIR" ]; then
            echo "  Creating directory structure: $TARGET_DIR"
            mkdir -p "$TARGET_DIR"
        fi
        
        if cp "$FILE_PATH" "$TARGET_PATH"; then
            echo "✓ Successfully copied to $TARGET_PATH"
            COPIED_COUNT=$((COPIED_COUNT + 1))
        else
            echo "✗ Failed to copy to $TARGET_PATH"
        fi
        
        echo ""
    fi
done

echo "File copy process completed!"
echo "Successfully copied '$RELATIVE_PATH' to $COPIED_COUNT directories" 