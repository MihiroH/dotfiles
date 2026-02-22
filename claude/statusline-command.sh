#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract data from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')

# Get basename of current directory (equivalent to zsh %c)
current_dir=$(basename "$cwd")

# Get git branch if in a git repo (equivalent to __git_ps1)
git_branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        # Use printf for ANSI color code #3a94c5 (58, 148, 197 in RGB)
        git_branch=$(printf " \033[38;2;58;148;197m(%s)\033[0m" "$branch")
    fi
fi

# Output the status line with model name
printf "%s%s | %s" "$current_dir" "$git_branch" "$model"
