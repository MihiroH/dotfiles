#!/bin/bash

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$SCRIPT_DIR"
TARGET="$HOME/.config"
KARABINER_DIR="$TARGET/karabiner"

# Back up existing config directory if it's not a symlink
if [ -d "$KARABINER_DIR" ] && [ ! -L "$KARABINER_DIR" ]; then
    mv "$KARABINER_DIR" "$KARABINER_DIR.bak"
    echo "Backed up existing configuration to $KARABINER_DIR.bak"
fi

# Create symbolic link
ln -sf "$SOURCE" "$TARGET"
echo "Karabiner configuration linked: $SOURCE -> $TARGET"

# Output setup instructions
echo
echo "===================="
echo "Important"
echo "===================="
echo "1. Go to System Preferences -> Privacy and Security -> Full Disk Access"
echo "2. Tick karabiner_grabber"
echo "3. Restart Karabiner-Elements"
echo
echo "Please wait a moment while the settings are updated."
echo