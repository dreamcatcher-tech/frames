#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Starting update process for all frame projects..."
echo "Working from: $SCRIPT_DIR"

for dir in */; do
    if [ -d "$dir" ]; then
        if [ "$dir" = "frame-harness/" ]; then
            echo "Skipping $dir (special case)"
            continue
        fi
        
        echo "================================"
        echo "Processing $dir"
        echo "================================"
        
        cd "$dir"
        
        echo "Running git pull..."
        git pull
        
        # if [ "$dir" = "dreamcatcher-mock/" ]; then
            # echo "Special case: Removing node_modules and package-lock.json for dreamcatcher-mock"
            # rm -rf node_modules package-lock.json
        # fi
        
        echo "Running npm run up..."
        npm run up
        
        echo "Staging changes..."
        git add .
        
        if git diff --cached --quiet; then
            echo "No changes to commit, skipping git commit and push"
        else
            echo "Committing updates..."
            git commit -m "updates"
            
            echo "Pushing changes..."
            git push
        fi
        
        cd ..
        
        echo "Completed $dir"
        echo ""
    fi
done

echo "All frame projects updated successfully!" 