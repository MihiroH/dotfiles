#!/bin/bash

# Paths
SOURCE="${PWD}/kitty"
TARGET="${HOME}/.config"
KITTY_DIR="${TARGET}/kitty"

# Back up existing config directory if it's not a symlink
if [ -d "$KITTY_DIR" ] && [ ! -L "$KITTY_DIR" ]; then
    mv "$KITTY_DIR" "${KITTY_DIR}.bak"
    echo "Backed up existing configuration to ${KITTY_DIR}.bak"
fi

# Create symbolic link
ln -s "$SOURCE" "$TARGET"
echo "Kitty configuration linked: $SOURCE -> $TARGET"
