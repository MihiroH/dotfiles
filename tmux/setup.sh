#!/bin/bash

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$SCRIPT_DIR")/lib/common.sh" || {
    echo "Failed to source common utilities"
    exit 1
}

# Tool-specific configuration
TOOL_NAME="Tmux"
REQUIRED_COMMANDS=("tmux")

# File symlink mappings (source -> target)
SYMLINK_SOURCES=(
    "$SCRIPT_DIR/tmux.conf"
)
SYMLINK_TARGETS=(
    "$HOME/.config/tmux/tmux.conf"
)

# Setup function
setup_tool() {
    print_section "Setting up $TOOL_NAME"

    # Check permissions
    ensure_permissions || return 1

    # Check required commands
    require_commands "${REQUIRED_COMMANDS[@]}" || return 1

    # Create symlinks
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
    log_info "Tmux version: $(tmux -V)"
    log_info "Prefix key is Ctrl+a"
    log_info "Key bindings:"
    log_info "  prefix + |  : split horizontally"
    log_info "  prefix + -  : split vertically"
    log_info "  prefix + hjkl : navigate panes"
    log_info "  prefix + r  : reload config"
    return 0
}

# Verify installation
verify_installation() {
    log_info "Verifying $TOOL_NAME installation..."

    # Check tmux is installed
    if ! command_exists "tmux"; then
        log_error "tmux is not installed"
        return 1
    fi

    # Verify symlinks
    for i in "${!SYMLINK_SOURCES[@]}"; do
        source="${SYMLINK_SOURCES[$i]}"
        target="${SYMLINK_TARGETS[$i]}"
        validate_symlink "$target" "$source" || return 1
    done

    # Check config is parseable
    if ! tmux -f "${SYMLINK_TARGETS[0]}" start-server \; kill-server 2>/dev/null; then
        log_warning "Tmux config may have syntax issues"
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
