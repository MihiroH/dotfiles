# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a dotfiles repository for macOS development environment configuration. It manages configurations for zsh, git, nvim, karabiner, iterm2, kitty, and mise through a modular setup system.

## Common Commands

### Setup and Installation
```bash
# Full installation (all tools)
./setup.sh

# Selective installation
./setup.sh zsh git nvim  # Install only specified tools

# Individual tool setup (can be run from anywhere)
./zsh/setup.sh
./nvim/setup.sh
./git/setup.sh
./karabiner/setup.sh
./iterm/setup.sh
./kitty/setup.sh
```

### CopilotChat.nvim Setup
After running setup.sh, complete the CopilotChat.nvim environment setup:
```bash
mise install rust
mise use -g rust
luarocks install tiktoken_core
```

### Making Changes
When modifying configurations:
1. Edit the source files in this repository (not the symlinked files)
2. Changes take effect immediately for most tools
3. Some tools may require restart (iTerm2, Karabiner)

## Architecture

### Directory Structure
- Each tool has its own directory with configuration files and a `setup.sh` script
- Setup scripts create symbolic links from standard locations to this repository
- Backups are created before overwriting existing configurations

### Setup Script Pattern
All setup scripts use script directory resolution for reliability:
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```
This ensures scripts work correctly regardless of where they're executed from.

### Symlink Locations
- **Git**: `.gitconfig` → `~/.config/git/config`, `.gitignore` → `~/.config/git/ignore`
- **Zsh**: `.zshrc` → `~/.zshrc`, `.zsh_profile` → `~/.zsh_profile`
- **Nvim**: entire directory → `~/.config/nvim`
- **Karabiner**: entire directory → `~/.config/karabiner`
- **Kitty**: entire directory → `~/.config/kitty`
- **iTerm2**: preferences file copied to `~/Library/Preferences/`
- **Mise**: `config.toml` → `~/.config/mise/config.toml` (via root setup.sh)

### Key Integration Points
1. **Git + FZF**: Custom git aliases use fzf for interactive operations
2. **Zsh + FZF**: Ctrl+r (history), Ctrl+g (git repos), Ctrl+v (vim files)
3. **Nvim + Copilot/Avante**: AI assistance integrated into editor
4. **Mise**: Manages tool versions across the environment

### Root setup.sh Behavior
- Installs Homebrew if missing (with Apple Silicon support)
- Installs packages: git, ripgrep, ghq, fd, fzf, nvim, gpg, mise, lua, luarocks, lynx
- Installs cask packages: kitty
- Auto-links `config.{json,toml}` files for any installed package
- Runs individual setup scripts for specified tools

## Important Notes

- The main `setup.sh` installs Homebrew and essential packages if missing
- Git configuration uses conditional includes for personal/work profiles
- Neovim uses Packer for plugin management - run `:PackerSync` after adding plugins
- Karabiner modifies keyboard behavior (Escape key sends both escape and Japanese input switch)

## CLI Tool Preferences
- Use `fd` instead of `find` for file searching
- Use `rg` instead of `grep` for text searching

## Commit Guidelines
- Always use the Conventional Commits specification to generate a one-line commit message.
- Only generate the title; no additional description and author is needed.
### example messages:
- feat: Add new feature
- fix: Fix bug
- docs: Update documentation
- refactor: Refactor code
- style: Update code style
- test: Add tests
- chore: Update build process