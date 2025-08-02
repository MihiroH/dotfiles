#!/bin/bash

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$SCRIPT_DIR")/lib/common.sh" || {
    echo "Failed to source common utilities"
    exit 1
}

# Tool-specific configuration
TOOL_NAME="Karabiner-Elements"
REQUIRED_COMMANDS=() # Karabiner is a GUI app

# Directories to symlink entirely (source:target)
SYMLINK_SOURCES=(
    "$SCRIPT_DIR"
)
SYMLINK_TARGETS=(
    "$HOME/.config/karabiner"
)

# Setup function
setup_tool() {
    print_section "Setting up $TOOL_NAME"
    
    # Check permissions
    ensure_permissions || return 1
    
    # macOS only
    if ! is_macos; then
        log_error "Karabiner-Elements is only available for macOS"
        return 1
    fi
    
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
    # Check if Karabiner-Elements is installed
    if [ -d "/Applications/Karabiner-Elements.app" ]; then
        log_info "Karabiner-Elements.app found in Applications folder"
    else
        log_warning "Karabiner-Elements not found. Install from: https://karabiner-elements.pqrs.org/"
    fi
    
    # Display setup instructions
    print_section "Important Setup Instructions"
    echo "1. Open System Preferences -> Privacy & Security -> Full Disk Access"
    echo "2. Enable access for karabiner_grabber and karabiner_observer"
    echo "3. Restart Karabiner-Elements"
    echo
    echo "4. If Karabiner-Elements is running, it should pick up the new configuration automatically"
    echo "5. Check Karabiner-Elements preferences to ensure your rules are loaded"
    
    # Check if Karabiner CLI is available
    if command_exists "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"; then
        log_info "Karabiner CLI is available"
        log_info "You can reload config with: /Library/Application\\ Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli --reload-config"
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
    
    # Check if main config file is accessible
    if [ ! -f "$HOME/.config/karabiner/karabiner.json" ]; then
        log_error "Karabiner configuration file not found"
        return 1
    fi
    
    # Validate JSON syntax
    if command_exists "python3"; then
        if python3 -m json.tool "$HOME/.config/karabiner/karabiner.json" >/dev/null 2>&1; then
            log_success "Karabiner configuration JSON is valid"
        else
            log_error "Karabiner configuration has invalid JSON syntax"
            return 1
        fi
    else
        log_warning "Cannot validate JSON syntax (python3 not found)"
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