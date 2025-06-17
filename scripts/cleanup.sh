#!/bin/bash

# Cleanup script for dotfiles
# This script removes symlinks and restores backups

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh" || {
    echo "Failed to source common utilities"
    exit 1
}

# Configuration paths that might be symlinked
CLEANUP_PATHS=(
    # Git
    "$HOME/.config/git/config"
    "$HOME/.config/git/ignore"
    # Zsh
    "$HOME/.zshrc"
    "$HOME/.zsh_profile"
    # Neovim
    "$HOME/.config/nvim"
    # Kitty
    "$HOME/.config/kitty"
    # Karabiner
    "$HOME/.config/karabiner"
    # Mise
    "$HOME/.config/mise/config.toml"
)

CLEANUP_DESCRIPTIONS=(
    # Git
    "Git config"
    "Git ignore"
    # Zsh
    "Zsh config"
    "Zsh profile"
    # Neovim
    "Neovim config"
    # Kitty
    "Kitty config"
    # Karabiner
    "Karabiner config"
    # Mise
    "Mise config"
)

# Files that were copied (not symlinked)
COPIED_PATHS=(
    "$HOME/Library/Preferences/com.googlecode.iterm2.plist"
)

COPIED_DESCRIPTIONS=(
    "iTerm2 preferences"
)

# Remove symlink and restore backup if available
cleanup_symlink() {
    local path="$1"
    local description="$2"
    
    if [ -L "$path" ]; then
        log_info "Removing symlink: $description"
        rm "$path"
        
        # Look for backup files
        for backup in "$path.bak" "$path.bak."*; do
            if [ -f "$backup" ] || [ -d "$backup" ]; then
                log_info "Restoring backup: $backup -> $path"
                mv "$backup" "$path"
                break
            fi
        done
    elif [ -e "$path" ]; then
        log_info "Skipping non-symlink: $description"
    else
        log_info "Not found: $description"
    fi
}

# Handle copied files
cleanup_copied_file() {
    local path="$1"
    local description="$2"
    
    if [ -f "$path" ]; then
        log_warning "Found copied file: $description"
        if confirm "Remove copied file and restore backup?"; then
            # Look for backup
            for backup in "$path.bak" "$path.bak."*; do
                if [ -f "$backup" ]; then
                    log_info "Restoring backup: $backup -> $path"
                    mv "$backup" "$path"
                    return
                fi
            done
            
            # No backup found, just remove
            log_warning "No backup found for $path"
            if confirm "Remove $path anyway?"; then
                rm "$path"
                log_info "Removed: $description"
            fi
        fi
    fi
}

# Clean up Zsh plugins
cleanup_zsh_plugins() {
    log_info "Cleaning up Zsh plugins..."
    
    local zsh_dir="$HOME/.zsh"
    if [ -d "$zsh_dir" ]; then
        log_info "Removing Zsh plugins directory: $zsh_dir"
        if confirm "Remove $zsh_dir?"; then
            rm -rf "$zsh_dir"
        fi
    fi
}

# Clean up Neovim Packer
cleanup_nvim_plugins() {
    log_info "Cleaning up Neovim plugins..."
    
    local packer_dir="$HOME/.local/share/nvim"
    if [ -d "$packer_dir" ]; then
        log_warning "Found Neovim data directory: $packer_dir"
        if confirm "Remove Neovim plugins and data?"; then
            rm -rf "$packer_dir"
            log_info "Removed Neovim data directory"
        fi
    fi
}

# Clean up fonts
cleanup_fonts() {
    log_info "Checking for installed fonts..."
    
    local font_path="$HOME/Library/Fonts/FiraCodeNerdFont-Medium.ttf"
    if [ -f "$font_path" ]; then
        log_info "Found FiraCode Nerd Font"
        if confirm "Remove FiraCode Nerd Font?"; then
            rm "$font_path"
            log_info "Removed FiraCode Nerd Font"
        fi
    fi
}

# Main cleanup function
main() {
    print_section "Dotfiles Cleanup"
    
    log_warning "This will remove dotfile symlinks and restore backups"
    log_warning "Make sure you have committed any changes you want to keep"
    
    if ! confirm "Continue with cleanup?" "n"; then
        log_info "Cleanup cancelled"
        exit 0
    fi
    
    # Remove symlinks
    log_info "Removing symlinks..."
    for i in "${!CLEANUP_PATHS[@]}"; do
        path="${CLEANUP_PATHS[$i]}"
        description="${CLEANUP_DESCRIPTIONS[$i]}"
        cleanup_symlink "$path" "$description"
    done
    
    # Handle copied files
    log_info "Checking copied files..."
    for i in "${!COPIED_PATHS[@]}"; do
        path="${COPIED_PATHS[$i]}"
        description="${COPIED_DESCRIPTIONS[$i]}"
        cleanup_copied_file "$path" "$description"
    done
    
    # Clean up additional items
    cleanup_zsh_plugins
    cleanup_nvim_plugins
    
    if is_macos; then
        cleanup_fonts
    fi
    
    print_section "Cleanup Summary"
    log_success "Cleanup completed!"
    log_info "Your original configurations have been restored where possible"
    log_info "You may need to restart your terminal or applications"
}

# Run main function
main "$@"