#!/bin/bash

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Configuration files to link
CONFIG_FILES=(
  "$SCRIPT_DIR/.gitconfig:$HOME/.config/git/config"
  "$SCRIPT_DIR/.gitignore:$HOME/.config/git/ignore"
)

# Ensure target directory exists
mkdir -p "$HOME/.config/git"

# Create symbolic links for each config file
for entry in "${CONFIG_FILES[@]}"; do
  IFS=":" read -r source target <<< "$entry"

  # Back up existing file if it exists and isn't already a symlink
  if [ -f "$target" ] && [ ! -L "$target" ]; then
    mv "$target" "$target.bak"
    echo "Backed up existing file to $target.bak"
  fi

  # Create symbolic link
  ln -sf "$source" "$target"
  echo "Git configuration linked: $source -> $target"
done
