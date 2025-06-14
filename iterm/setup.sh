#!/bin/bash

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$SCRIPT_DIR/com.googlecode.iterm2.plist"
TARGET="$HOME/Library/Preferences/com.googlecode.iterm2.plist"

# Font setup
FONT_DIR="$HOME/Library/Fonts"
FONT_NAME="FiraCodeNerdFont-Medium.ttf"
FONT_URL="https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/FiraCode/Medium/$FONT_NAME"

# Ensure Fonts directory exists
mkdir -p "$FONT_DIR"

# Download font if not already installed
if [ ! -f "$FONT_DIR/$FONT_NAME" ]; then
    echo "Downloading FiraCode Nerd Font Medium..."
    curl -L -o "$FONT_DIR/$FONT_NAME" "$FONT_URL"
    echo "FiraCode Nerd Font Medium downloaded: $FONT_DIR/$FONT_NAME"
else
    echo "FiraCode Nerd Font Medium is already installed"
fi

# Back up existing preferences if they exist and aren't a symlink
if [ -f "$TARGET" ] && [ ! -L "$TARGET" ]; then
    mv "$TARGET" "$TARGET.bak"
    echo "Backed up existing configuration to $TARGET.bak"
fi

# Copy preferences file (iTerm2 doesn't work well with symlinks for prefs)
cp "$SOURCE" "$TARGET"
echo "iTerm2 configuration copied: $SOURCE -> $TARGET"