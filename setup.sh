#!/bin/bash

# Install Homebrew if it's not already installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Set PATH for Apple Silicon
    eval "$(/opt/homebrew/bin/brew shellenv)"

    # Verify that brew was installed correctly
    brew --version
fi

# Homebrew packages
#
# lua@5.1, luarocks and lynx is required for CopilotChat.nvim
# After installing above packages, run the following commands to prepare the environment:
# ```
# % mise install rust
# % mise use -g rust
# % luarocks install --lua-version=5.1 tiktoken_core
# ```
BREW_PACKAGES=("git" "ripgrep" "ghq" "fd" "fzf" "nvim" "gpg" "mise" "lua@5.1" "luarocks" "lynx")

# Install packages
for package in "${BREW_PACKAGES[@]}"; do
  # Install the package if not already installed
  if ! command -v $package >/dev/null 2>&1; then
    echo "Installing $package..."
    brew install $package || {
      echo "Error: $package installation failed. Install it manually."
      exit 1
    }
  fi

  # Supported config extensions
  CONFIG_EXTENSIONS=("json" "toml")

  for ext in "${CONFIG_EXTENSIONS[@]}"; do
    CONFIG_SOURCE=~/Documents/personal/settings-files/$package/config.$ext
    CONFIG_TARGET=~/.config/$package/config.$ext
    if [ -f "$CONFIG_SOURCE" ]; then
      mkdir -p "$(dirname "$CONFIG_TARGET")"
      ln -sf "$CONFIG_SOURCE" "$CONFIG_TARGET"
      echo "Linked $CONFIG_SOURCE to $CONFIG_TARGET"
    fi
  done
done

# Default tools to set up if none are specified
DEFAULT_TOOLS=("zsh" "karabiner" "iterm" "git" "nvim")

# Make sure all setup scripts are executable
echo "Ensuring setup scripts are executable..."
chmod +x ./*/setup.sh

# Function to call a setup script
run_setup() {
    local tool=$1
    local script="./$tool/setup.sh"
    if [ -x "$script" ]; then
        echo "Setting up $tool..."
        if ! "$script"; then
            echo "Error occurred while setting up $tool"
            return 1
        fi
        echo "$tool setup completed!"
    else
        echo "Setup script for $tool not found or not executable."
        return 1
    fi
}

# Check if tools are specified as arguments
if [ "$#" -gt 0 ]; then
    TOOLS=("$@")
else
    TOOLS=("${DEFAULT_TOOLS[@]}")
fi

# Run setup for each tool
for TOOL in "${TOOLS[@]}"; do
    if ! run_setup "$TOOL"; then
        exit 1  # Exit if an error occurs
    fi
done

# If all setups succeed, show the completion message
echo "All setups completed!"
