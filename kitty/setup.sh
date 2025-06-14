#!/bin/bash

# Paths
SOURCE=~/Documents/personal/dotfiles/kitty
TARGET=~/.config

# Remove existing config directory if it's not a symlink
if [ -d "$TARGET/kitty" ] && [ ! -L "$TARGET/kitty" ]; then
    mv "$TARGET/kitty" "${TARGET}/kitty.bak"
    echo "Backed up existing kitty configuration to ${TARGET}/kitty.bak"
fi

# Create symbolic link
ln -s "$SOURCE" "$TARGET"
echo "Symbolic link created: $TARGET -> $SOURCE"
