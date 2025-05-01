#!/bin/bash

# iTerm2 setup script

echo "Setting up iTerm2..."

# Directory to install the font
FONT_DIR="$HOME/Library/Fonts"
FONT_NAME="FiraCodeNerdFont-Medium.ttf"
FONT_URL="https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/FiraCode/Medium/$FONT_NAME"

# Ensure Fonts directory exists
mkdir -p "$FONT_DIR"

# Check if the font is already installed
if [ ! -f "$FONT_DIR/$FONT_NAME" ]; then
    echo "Downloading FiraCode Nerd Font Medium..."
    curl -L -o "$FONT_DIR/$FONT_NAME" "$FONT_URL"
    echo "FiraCode Nerd Font Medium installed."
else
    echo "FiraCode Nerd Font Medium is already installed."
fi

# Example: Load iTerm2 preferences
SOURCE=~/Documents/personal/settings-files/iterm/com.googlecode.iterm2.plist
TARGET=~/Library/Preferences/com.googlecode.iterm2.plist

# Back up existing preferences if they exist
if [ -f "$TARGET" ] && [ ! -L "$TARGET" ]; then
    mv "$TARGET" "$TARGET.bak"
    echo "Existing iTerm2 preferences backed up to com.googlecode.iterm2.plist.bak"
fi

# Create a symbolic link to the managed preferences file
cp -f "$SOURCE" "$TARGET"

echo "iTerm2 preferences setup complete."