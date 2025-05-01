#!/bin/bash

# Paths
SOURCE=~/Documents/personal/settings-files/karabiner
TARGET=~/.config

# Remove existing config directory if it's not a symlink
if [ -d "$TARGET/karabiner" ] && [ ! -L "$TARGET/karabiner" ]; then
    mv "$TARGET/karabiner" "$TARGET/karabiner.bak"
    echo "Backed up existing karabiner configuration to ${TARGET}/karabiner.bak"
fi

# Create symbolic link
ln -s "$SOURCE" "$TARGET"
echo "Symbolic link created: $TARGET -> $SOURCE"

# Output messages
echo $'\n'
echo "===================="
echo "Important"
echo "===================="
echo "1. Go to System Preferences -> Privacy and Security -> Full Disk Access"
echo "2. Tick karabiner_grabber"
echo "3. Restart Karabiner-Elements"
echo $'\nPlease wait a moment while the settings are updated.'
echo $'\n'
