# Dotfiles

[![macOS](https://img.shields.io/badge/macOS-Supported-green.svg)](https://www.apple.com/macos/)
[![Bash](https://img.shields.io/badge/Bash-5.2%2B-blue.svg)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A comprehensive dotfiles repository for macOS development environment configuration. This repository provides a modular, automated setup system for configuring development tools with intelligent backup management and verification capabilities.

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Install everything with default settings
make

# Or use the setup script directly
./setup.sh
```

## 📋 Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Supported Tools](#supported-tools)
- [Usage](#usage)
- [Architecture](#architecture)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## ✨ Features

- **🔧 Modular Architecture**: Each tool has its own setup script with standardized patterns
- **🔒 Safe Installation**: Automatic backups before modifying existing configurations
- **✅ Verification System**: Built-in verification for all installations
- **🎯 Selective Installation**: Install only the tools you need
- **🔍 Dry Run Mode**: Preview changes before applying them
- **🧹 Clean Uninstall**: Remove configurations and restore backups
- **📝 Comprehensive Logging**: Colored output with detailed error messages
- **🔄 Dependency Management**: Automatic installation of required dependencies

## 🔧 Prerequisites

### Required
- macOS (tested on macOS 11+)
- Command Line Tools for Xcode
- Internet connection for downloading dependencies

### Automatically Installed
- [Homebrew](https://brew.sh/) - Package manager for macOS
- Bash 3.2+ - Works with standard macOS bash (no Homebrew required)
- Various command-line tools (git, ripgrep, fd, fzf, etc.)

## 📦 Installation

### Using Make (Recommended)

```bash
# Install all default tools
make

# Install specific tools
make install-nvim
make install-git
make install-zsh

# Preview what would be installed
make test

# Verify installations
make verify

# List available tools
make list
```

### Using Setup Script

```bash
# Install all default tools
./setup.sh

# Install specific tools
./setup.sh zsh git nvim

# Preview mode (dry run)
./setup.sh --dry-run

# Force installation (skip backups)
./setup.sh --force

# Verbose output
./setup.sh --verbose

# Show help
./setup.sh --help
```

### Individual Tool Setup

Each tool can be installed independently:

```bash
# Install and verify individual tools
./git/setup.sh
./git/setup.sh verify

./nvim/setup.sh
./nvim/setup.sh verify
```

## 🛠 Supported Tools

### 🐚 Zsh
Modern shell with extensive customization and plugins.

- **Config Files**: `.zshrc`, `.zsh_profile`
- **Plugins**: 
  - Git completion and prompt
  - Zsh autosuggestions
- **Features**: 
  - Custom aliases and functions
  - FZF integration
  - Enhanced directory navigation

### 📝 Git
Version control system with custom configuration.

- **Config Location**: `~/.config/git/`
- **Features**:
  - Global gitconfig with useful aliases
  - Custom gitignore patterns
  - Conditional includes for work/personal profiles
  - FZF-powered interactive commands

### 🖥 Neovim
Modern Vim-based text editor configured as a complete IDE.

- **Config Location**: `~/.config/nvim/`
- **Plugin Manager**: Packer
- **Key Features**:
  - AI assistance (Copilot, Avante, Claude Code)
  - LSP support with autocompletion
  - File navigation (Telescope, Fern)
  - Git integration (Gitsigns, Lazygit)
  - Testing and debugging tools
  - Beautiful themes and UI

**Post-install**: Run `:PackerSync` in Neovim to install plugins.

### 🐱 Kitty
Fast, feature-rich terminal emulator.

- **Config Location**: `~/.config/kitty/`
- **Features**:
  - Custom themes (Gruvbox, Everforest)
  - Font configuration
  - Keyboard shortcuts
  - Window management

### ⌨️ Karabiner-Elements
Powerful keyboard customization tool for macOS.

- **Config Location**: `~/.config/karabiner/`
- **Features**:
  - Custom key mappings
  - Complex modifications
  - Japanese input integration

**Post-install**: Grant Full Disk Access to karabiner_grabber and karabiner_observer in System Preferences.

### 🖥 iTerm2
Popular terminal emulator for macOS.

- **Features**:
  - Custom preferences
  - FiraCode Nerd Font installation
  - Color schemes and profiles

### 🔧 Mise
Tool version management (formerly rtx).

- **Config Location**: `~/.config/mise/config.toml`
- **Features**:
  - Language version management
  - Global tool configuration

## 📖 Usage

### Common Commands

```bash
# Setup all tools
make

# Verify all installations
make verify

# Clean up (remove symlinks, restore backups)
make clean

# Check specific tool
./zsh/setup.sh verify

# Force reinstall a tool
./setup.sh --force nvim

# See what would be changed
./setup.sh --dry-run
```

### Managing Configurations

1. **Edit configurations**: Modify files in this repository (not the symlinked files)
2. **Changes take effect**: Most changes apply immediately, some tools may need restart
3. **Commit changes**: Use git to track your configuration changes

### Adding a New Tool

1. Create a new directory for your tool
2. Copy `lib/setup_template.sh` to `yourtool/setup.sh`
3. Customize the configuration:
   ```bash
   TOOL_NAME="YourTool"
   REQUIRED_COMMANDS=("command1" "command2")
   
   CONFIG_SOURCES=(
       "$SCRIPT_DIR/config"
   )
   CONFIG_TARGETS=(
       "$HOME/.config/yourtool/config"
   )
   ```
4. Add tool-specific logic in `post_setup()` and `verify_tool()` functions

## 🏗 Architecture

### Directory Structure

```
dotfiles/
├── lib/                    # Common utilities
│   ├── common.sh          # Shared functions
│   └── setup_template.sh  # Template for new tools
├── scripts/               # Management scripts
│   ├── cleanup.sh        # Remove configurations
│   └── verify-all.sh     # Verify installations
├── [tool]/               # Tool-specific directory
│   ├── setup.sh         # Installation script
│   └── config files     # Tool configurations
├── setup.sh             # Main setup script
├── Makefile            # Make interface
└── README.md           # This file
```

### Setup Script Pattern

All setup scripts follow a standardized pattern:

1. **Source common utilities** - Import shared functions
2. **Define configuration** - Specify files, dependencies, and actions
3. **Setup function** - Handle installation logic
4. **Verification function** - Validate installation
5. **Main execution** - Route commands (setup/verify)

### Common Utilities Features

- **Logging**: `log_info`, `log_success`, `log_warning`, `log_error`
- **Backups**: `backup_if_exists` - Safe file replacement
- **Symlinks**: `create_symlink` - Intelligent symlink creation
- **Downloads**: `download_if_missing`, `clone_if_missing`
- **Validation**: `command_exists`, `require_commands`
- **Platform**: `is_macos`, `is_linux`

## 🎨 Customization

### Environment-Specific Configuration

Git supports conditional includes for different environments:

```gitconfig
[includeIf "gitdir:~/work/"]
    path = ~/.config/git/work.config
[includeIf "gitdir:~/personal/"]
    path = ~/.config/git/personal.config
```

### Adding Custom Aliases

Edit the relevant configuration file:
- Zsh aliases: `zsh/.zsh_profile`
- Git aliases: `git/.gitconfig`

### Modifying Neovim Plugins

1. Edit `nvim/lua/plugins.lua`
2. Run `:PackerSync` in Neovim
3. Restart Neovim

## 🔍 Troubleshooting

### Common Issues

#### Permission Denied
```bash
# Make scripts executable
chmod +x setup.sh
chmod +x */setup.sh
```

#### Bash Version Error
```bash
# Install newer bash
brew install bash

# Verify version (should be 5.2+)
/opt/homebrew/bin/bash --version
```

#### Symlink Already Exists
```bash
# Use force mode to overwrite
./setup.sh --force [tool]

# Or manually remove and retry
rm ~/.config/[tool]
./[tool]/setup.sh
```

#### Homebrew Not Found
The setup script will automatically install Homebrew if missing. If it fails:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Verification Failed

Run individual verification to see specific issues:
```bash
./[tool]/setup.sh verify
```

### Restoring Backups

If something goes wrong:
```bash
# Restore all backups
make clean

# Or manually restore
mv ~/.config/[tool].bak ~/.config/[tool]
```

## 🤝 Contributing

### Adding a New Tool

1. Create a directory with the tool name
2. Copy and customize `lib/setup_template.sh`
3. Add configuration files
4. Update this README
5. Test thoroughly:
   ```bash
   ./yourtool/setup.sh
   ./yourtool/setup.sh verify
   ./setup.sh --dry-run yourtool
   ```

### Best Practices

- Use the common utilities library for consistency
- Always create backups before modifying files
- Provide clear error messages
- Include verification logic
- Document any manual steps required
- Test on a clean system when possible

### Code Style

- Use 4-space indentation in bash scripts
- Follow existing naming conventions
- Add comments for complex logic
- Keep functions focused and small

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- [Homebrew](https://brew.sh/) for package management
- All the amazing open-source tool maintainers
- The dotfiles community for inspiration

---

Made with ❤️ for the developer community
