#!/bin/bash

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$SCRIPT_DIR")/lib/common.sh" || {
    echo "Failed to source common utilities"
    exit 1
}

# Tool-specific configuration
TOOL_NAME="cmux"
REQUIRED_COMMANDS=() # cmux is a GUI app; no CLI dependency required

# cmux is a native macOS terminal app built on Ghostty. It reads rendering
# settings from ~/.config/ghostty/config and app-level settings (shortcuts,
# theme mode, etc.) from ~/.config/cmux/settings.json.
#
# We symlink individual files rather than whole directories so a standalone
# Ghostty install (if ever added) can still manage other files under
# ~/.config/ghostty/ without conflict.
CONFIG_SOURCES=(
    "$SCRIPT_DIR/ghostty/config"
    "$SCRIPT_DIR/settings.json"
)
CONFIG_TARGETS=(
    "$HOME/.config/ghostty/config"
    "$HOME/.config/cmux/settings.json"
)

# Setup function
setup_tool() {
    print_section "Setting up $TOOL_NAME"

    # Check permissions
    ensure_permissions || return 1

    # Create symlinks for individual files
    for i in "${!CONFIG_SOURCES[@]}"; do
        source="${CONFIG_SOURCES[$i]}"
        target="${CONFIG_TARGETS[$i]}"
        create_symlink "$source" "$target" || return 1
    done

    # Post-setup actions
    post_setup || return 1

    log_success "$TOOL_NAME setup completed!"
    return 0
}

# Post-setup actions
post_setup() {
    if is_macos && [ -d "/Applications/cmux.app" ]; then
        log_info "cmux.app found in Applications folder"
    else
        log_warning "cmux not found. Download it from https://cmux.com/"
    fi
    return 0
}

# Verify installation
verify_installation() {
    log_info "Verifying $TOOL_NAME installation..."

    # Verify symlinks
    for i in "${!CONFIG_SOURCES[@]}"; do
        source="${CONFIG_SOURCES[$i]}"
        target="${CONFIG_TARGETS[$i]}"
        validate_symlink "$target" "$source" || return 1
    done

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
