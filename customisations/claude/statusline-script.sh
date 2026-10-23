#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract current directory from the JSON input
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')

# Get the directory name (basename)
dir_name=$(basename "$current_dir")

# Check if we're in a git repository
if git rev-parse --git-dir >/dev/null 2>&1; then
    # Get current branch name
    branch=$(git branch --show-current 2>/dev/null || echo "detached")
    
    # Check git status for cleanliness
    if git diff-index --quiet HEAD -- 2>/dev/null && [ -z "$(git ls-files --others --exclude-standard 2>/dev/null)" ]; then
        status_emoji="✅"
        status_text="clean"
    else
        status_emoji="🔄"
        status_text="changes"
    fi
    
    # Format: 📁 directory | 🌿 branch | status
    echo "📁 $dir_name | 🌿 $branch | $status_emoji $status_text"
else
    # Not a git repository
    echo "📁 $dir_name | 📂 not a git repo"
fi