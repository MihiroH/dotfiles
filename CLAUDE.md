# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a comprehensive dotfiles repository for macOS development environment configuration. It provides a modular, automated setup system for configuring development tools with intelligent backup management and verification capabilities.

## Common Development Commands

### Setup and Installation
```bash
# Install all default tools (zsh, git, nvim, kitty, karabiner, iterm)
make

# Install specific tools
make install-nvim
make install-git
make install-zsh

# Preview what would be installed (dry run)
make test
./setup.sh --dry-run

# Force installation (skip backups)
./setup.sh --force

# Verify installations
make verify
make verify-nvim  # Verify specific tool

# Clean up (remove symlinks, restore backups)
make clean
```

### Development and Testing
```bash
# Check shell scripts for errors
make lint

# Run all checks (lint + verify)
make check

# List available tools
make list

# Individual tool setup
./git/setup.sh
./nvim/setup.sh verify
```

## High-Level Architecture

### Directory Structure
- **`lib/`**: Common utilities shared by all setup scripts
  - `common.sh`: Core functions for logging, backups, symlinks, downloads
  - `setup_template.sh`: Template for creating new tool setup scripts
- **`scripts/`**: Management scripts for cleanup and verification
- **`[tool]/`**: Each tool has its own directory with:
  - `setup.sh`: Installation script following standardized pattern
  - Configuration files specific to that tool
- **`setup.sh`**: Main orchestration script that calls individual tool setups
- **`Makefile`**: User-friendly interface to common operations

### Setup Script Pattern
All setup scripts follow this standardized flow:
1. Source `lib/common.sh` for shared utilities
2. Define tool-specific configuration (names, dependencies, file mappings)
3. Implement `setup_tool()` function with installation logic
4. Implement `verify_tool()` function for validation
5. Main execution block routing setup/verify commands

### Key Design Principles
- **Safety First**: Always create backups before modifying existing configs
- **Modular**: Each tool is independent and can be installed separately
- **Verification**: Every tool includes verification logic
- **Idempotent**: Running setup multiple times is safe
- **Platform-Aware**: Handles macOS-specific requirements (e.g., Apple Silicon Homebrew paths)

### Symlink Strategy
The repository uses symlinks to manage configurations:
- Source files live in this repository
- Symlinks are created to expected config locations
- Original files are backed up with `.bak` suffix
- Multiple backups are numbered (`.bak.1`, `.bak.2`, etc.)

## Tool-Specific Notes

### Neovim
- Config location: `~/.config/nvim/`
- Uses Packer for plugin management
- Post-install: Run `:PackerSync` to install plugins
- Heavy AI integration (Copilot, Avante, Claude Code)

### Git
- Config location: `~/.config/git/`
- Supports conditional includes for work/personal profiles
- FZF-powered interactive commands

### Zsh
- Installs zsh-autosuggestions plugin
- Custom aliases in `.zsh_profile`
- FZF integration for enhanced navigation

## Adding New Tools

To add a new tool to this dotfiles repository:

1. Create directory: `mkdir yourtool`
2. Copy template: `cp lib/setup_template.sh yourtool/setup.sh`
3. Customize the configuration section:
   ```bash
   TOOL_NAME="YourTool"
   REQUIRED_COMMANDS=("command1" "command2")
   CONFIG_SOURCES=("$SCRIPT_DIR/config")
   CONFIG_TARGETS=("$HOME/.config/yourtool/config")
   ```
4. Add tool-specific logic in `post_setup()` and `verify_tool()`
5. Test thoroughly before committing
