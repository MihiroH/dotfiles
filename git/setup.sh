#!/bin/bash

# .gitconfig setup
SOURCE=~/Documents/personal/settings-files/git/.gitconfig
TARGET=~/.gitconfig

# Back up existing .gitconfig if it exists and isn’t already a symlink
if [ -f "$TARGET" ] && [ ! -L "$TARGET" ]; then
  mv "$TARGET" "$TARGET.bak"
  echo "Backed up existing .gitconfig to .gitconfig.bak"
fi

# Create a symbolic link to the managed .gitconfig
ln -sf "$SOURCE" "$TARGET"
echo ".gitconfig setup complete."
