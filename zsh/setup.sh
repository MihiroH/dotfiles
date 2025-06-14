#!/bin/bash

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Configuration files to link
CONFIG_FILES=(
  "$HOME/.zshrc:$SCRIPT_DIR/.zshrc"
  "$HOME/.zsh_profile:$SCRIPT_DIR/.zsh_profile"
)

# Plugin URLs and target directories
PLUGINS=(
  "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash:$HOME/.zsh/git-completion.zsh"
  "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh:$HOME/.zsh/git-prompt.sh"
  "https://github.com/zsh-users/zsh-autosuggestions.git:$HOME/.zsh/zsh-autosuggestions"
)

# Create symbolic links for config files
for entry in "${CONFIG_FILES[@]}"; do
  IFS=":" read -r target source <<< "$entry"

  # Ensure the target directory exists
  mkdir -p "$(dirname "$target")"

  # Back up existing file if it's not a symlink
  if [ -f "$target" ] && [ ! -L "$target" ]; then
    mv "$target" "$target.bak"
    echo "Backed up existing file to $target.bak"
  fi

  # Create symbolic link
  ln -sf "$source" "$target"
  echo "Zsh configuration linked: $source -> $target"
done

# Download plugins if they don't exist
for entry in "${PLUGINS[@]}"; do
  IFS=":" read -r url target <<< "$entry"

  if [ ! -e "$target" ]; then
    # If it's a git repo
    if [[ "$url" == *".git" ]]; then
      git clone "$url" "$target"
      echo "Cloned $url into $target"
    else
      # Ensure the target directory exists
      mkdir -p "$(dirname "$target")"
      curl -L "$url" -o "$target"
      echo "Downloaded $url to $target"
    fi
  fi
done