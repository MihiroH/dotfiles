#!/bin/bash

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$SCRIPT_DIR"
TARGET="$HOME/.config"
NVIM_DIR="$TARGET/nvim"

# Back up existing config directory if it's not a symlink
if [ -d "$NVIM_DIR" ] && [ ! -L "$NVIM_DIR" ]; then
    mv "$NVIM_DIR" "$NVIM_DIR.bak"
    echo "Backed up existing configuration to $NVIM_DIR.bak"
fi

# Create symbolic link
ln -sf "$SOURCE" "$TARGET"
echo "Nvim configuration linked: $SOURCE -> $TARGET"
