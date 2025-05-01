#!/bin/bash

# Paths
SOURCE=~/Documents/personal/settings-files/nvim
TARGET=~/.config

# Remove existing config directory if it's not a symlink
if [ -d "$TARGET/nvim" ] && [ ! -L "$TARGET/nvim" ]; then
    mv "$TARGET/nvim" "${TARGET}.bak"
    echo "Backed up existing nvim configuration to ${TARGET}/nvim.bak"
fi

# Create symbolic link
ln -s "$SOURCE" "$TARGET"
echo "Symbolic link created: $TARGET -> $SOURCE"
