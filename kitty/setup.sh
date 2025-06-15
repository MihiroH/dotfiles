#!/opt/homebrew/bin/bash

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$SCRIPT_DIR")/lib/common.sh" || {
    echo "Failed to source common utilities"
    exit 1
}

# Tool-specific configuration
TOOL_NAME="Kitty"
REQUIRED_COMMANDS=() # Kitty itself is optional since it might be GUI installed

# Directories to symlink entirely (source:target)
declare -A SYMLINK_DIRS=(
    ["$SCRIPT_DIR"]="$HOME/.config/kitty"
)

# Setup function
setup_tool() {
    print_section "Setting up $TOOL_NAME"
    
    # Check permissions
    ensure_permissions || return 1
    
    # Create symlinks for directories
    for source in "${!SYMLINK_DIRS[@]}"; do
        target="${SYMLINK_DIRS[$source]}"
        create_symlink "$source" "$target" || return 1
    done
    
    # Post-setup actions
    post_setup || return 1
    
    log_success "$TOOL_NAME setup completed!"
    return 0
}

# Post-setup actions
post_setup() {
    # Check if Kitty is installed
    if command_exists "kitty"; then
        log_info "Kitty is installed at: $(which kitty)"
    else
        if is_macos && [ -d "/Applications/kitty.app" ]; then
            log_info "Kitty.app found in Applications folder"
        else
            log_warning "Kitty not found. Install it with: brew install --cask kitty"
        fi
    fi
    
    # Validate config syntax if kitty is available
    if command_exists "kitty"; then
        if kitty --debug-config 2>&1 | grep -q "Config loaded"; then
            log_success "Kitty configuration syntax is valid"
        else
            log_warning "Kitty configuration may have syntax errors"
        fi
    fi
    
    return 0
}

# Verify installation
verify_installation() {
    log_info "Verifying $TOOL_NAME installation..."
    
    # Verify symlinks
    for source in "${!SYMLINK_DIRS[@]}"; do
        target="${SYMLINK_DIRS[$source]}"
        validate_symlink "$target" "$source" || return 1
    done
    
    # Check if main config file is accessible
    if [ ! -f "$HOME/.config/kitty/kitty.conf" ]; then
        log_error "Kitty configuration file not found"
        return 1
    fi
    
    # Check themes directory
    if [ ! -d "$HOME/.config/kitty/kitty-themes" ]; then
        log_warning "Kitty themes directory not found"
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
