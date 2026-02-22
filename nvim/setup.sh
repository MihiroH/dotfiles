#!/bin/bash

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$SCRIPT_DIR")/lib/common.sh" || {
    echo "Failed to source common utilities"
    exit 1
}

# Tool-specific configuration
TOOL_NAME="Neovim"
REQUIRED_COMMANDS=("nvim" "git")

# Directories to symlink entirely (source:target)
SYMLINK_SOURCES=(
    "$SCRIPT_DIR"
)
SYMLINK_TARGETS=(
    "$HOME/.config/nvim"
)

# Setup function
setup_tool() {
    print_section "Setting up $TOOL_NAME"
    
    # Check permissions
    ensure_permissions || return 1
    
    # Check required commands
    require_commands "${REQUIRED_COMMANDS[@]}" || return 1
    
    # Create symlinks for directories
    for i in "${!SYMLINK_SOURCES[@]}"; do
        source="${SYMLINK_SOURCES[$i]}"
        target="${SYMLINK_TARGETS[$i]}"
        create_symlink "$source" "$target" || return 1
    done
    
    # Post-setup actions
    post_setup || return 1
    
    log_success "$TOOL_NAME setup completed!"
    return 0
}

# Post-setup actions
post_setup() {
    # Install Packer if not already installed
    local packer_path="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"
    if [ ! -d "$packer_path" ]; then
        log_info "Installing Packer plugin manager..."
        if git clone --depth 1 https://github.com/wbthomason/packer.nvim "$packer_path"; then
            log_success "Packer installed successfully"
            log_info "Run :PackerSync in Neovim to install plugins"
        else
            log_error "Failed to install Packer. Please check your internet connection and git configuration."
            log_info "To install manually, run:"
            log_info "  git clone --depth 1 https://github.com/wbthomason/packer.nvim $packer_path"
            log_warning "Continuing without Packer - you can install it later"
        fi
    fi
    
    # Check for required tools for plugins
    if ! command_exists "lua"; then
        log_warning "Lua not found. Required for some Neovim plugins."
    fi
    
    if ! command_exists "rg"; then
        log_warning "Ripgrep (rg) not found. Required for Telescope live grep."
    fi
    
    return 0
}

# Verify installation
verify_installation() {
    log_info "Verifying $TOOL_NAME installation..."
    
    # Verify symlinks
    for i in "${!SYMLINK_SOURCES[@]}"; do
        source="${SYMLINK_SOURCES[$i]}"
        target="${SYMLINK_TARGETS[$i]}"
        validate_symlink "$target" "$source" || return 1
    done
    
    # Check if init.lua is accessible
    if [ ! -f "$HOME/.config/nvim/init.lua" ]; then
        log_error "Neovim init.lua not found"
        return 1
    fi
    
    # Check if Neovim can start without errors
    if ! nvim --headless -c "quit" 2>/dev/null; then
        log_warning "Neovim starts with errors. Check configuration."
    fi
    
    log_success "$TOOL_NAME verification passed!"
    return 0
}

# Main execution
main() {
    case "${1:-setup}" in
        setup)
            setup_tool
            ;;
        verify)
            verify_installation
            ;;
        *)
            log_error "Unknown command: $1"
            echo "Usage: $0 [setup|verify]"
            exit 1
            ;;
    esac
}

# Only run main if script is executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
