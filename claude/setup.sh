#!/bin/bash

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$SCRIPT_DIR")/lib/common.sh" || {
    echo "Failed to source common utilities"
    exit 1
}

# Tool-specific configuration
TOOL_NAME="Claude"
REQUIRED_COMMANDS=("node" "npm") # Required for Claude Code installation

# Configuration files mapping (source:target)
CONFIG_SOURCES=(
    "$SCRIPT_DIR/CLAUDE.md"
    "$SCRIPT_DIR/settings.json"
    "$SCRIPT_DIR/commands"
)
CONFIG_TARGETS=(
    "$HOME/.claude/CLAUDE.md"
    "$HOME/.claude/settings.json"
    "$HOME/.claude/commands"
)

# Install Claude Code binary
install_claude_code() {
    log_info "Checking Claude Code installation..."

    if command_exists "claude"; then
        log_info "Claude Code is already installed: $(claude --version 2>/dev/null || echo 'version unknown')"
        return 0
    fi

    log_info "Installing Claude Code via npm..."

    # Install Node.js via mise if not available
    if ! command_exists "node" || ! command_exists "npm"; then
        log_info "Node.js not found, installing via mise..."

        if ! command_exists "mise"; then
            log_error "mise is required to install Node.js"
            log_error "Please install mise first or run the full setup: ./setup.sh"
            return 1
        fi

        # Install latest Node.js LTS via mise
        if mise install node && mise use -g node; then
            log_success "Node.js installed via mise"

            # Reload environment to pick up new Node.js
            eval "$(mise activate zsh)"

            # Verify installation
            if command_exists "node" && command_exists "npm"; then
                log_success "Node.js and npm are now available"
            else
                log_warning "Node.js installed but not found in PATH"
                log_warning "You may need to restart your terminal or run: eval \"\$(mise activate bash)\""
            fi
        else
            log_error "Failed to install Node.js via mise"
            return 1
        fi
    else
        log_info "Node.js and npm are already available"
    fi

    # Install Claude globally
    if npm install -g @anthropic-ai/claude-code; then
        log_success "Claude Code installed successfully"

        # Verify installation
        if command_exists "claude"; then
            log_success "Claude Code is now available: $(claude --version 2>/dev/null || echo 'installed')"
        else
            log_warning "Claude Code installed but not found in PATH"
            log_warning "You may need to restart your terminal or check your PATH configuration"
        fi
    else
        log_error "Failed to install Claude Code via npm"
        log_error "You may need to install it manually or check your npm configuration"
        return 1
    fi

    return 0
}

# Setup function
setup_tool() {
    print_section "Setting up $TOOL_NAME"

    # Check permissions
    ensure_permissions || return 1

    # Check required commands
    require_commands "${REQUIRED_COMMANDS[@]}" || return 1

    # Install Claude Code binary
    install_claude_code || return 1

    # Create necessary directories
    log_info "Creating Claude configuration directory..."
    mkdir -p "$HOME/.claude"

    # Create symlinks for individual files
    for i in "${!CONFIG_SOURCES[@]}"; do
        source="${CONFIG_SOURCES[$i]}"
        target="${CONFIG_TARGETS[$i]}"
        create_symlink "$source" "$target" || return 1
    done


    # Post-setup actions
    post_setup || return 1

    log_success "$TOOL_NAME setup completed!"
    log_info "Claude Code is now ready to use. Try: claude --help"
    return 0
}

# Post-setup actions
post_setup() {
    # Ensure kitty socket directory exists (required for notifications)
    if [ ! -d "/tmp" ]; then
        log_error "/tmp directory doesn't exist (required for kitty notifications)"
        return 1
    fi

    # Check if kitty is available for notifications
    if command_exists "kitty" || [ -d "/Applications/kitty.app" ]; then
        log_info "Kitty available for Claude notifications"
    else
        log_warning "Kitty not found - Claude notifications may not work"
        log_warning "Install with: brew install --cask kitty"
    fi

    # Display configuration info
    log_info "Claude configuration locations:"
    echo "  Global instructions: $HOME/.claude/CLAUDE.md"
    echo "  Settings: $HOME/.claude/settings.json"
    echo "  Commands: $HOME/.claude/commands"

    return 0
}

# Verify installation
verify_installation() {
    log_info "Verifying $TOOL_NAME installation..."

    # Verify Claude binary is installed
    if command_exists "claude"; then
        local version
        version=$(claude --version 2>/dev/null || echo "unknown")
        log_success "Claude Code binary is installed: $version"
    else
        log_error "Claude binary not found in PATH"
        log_error "Run setup again or install manually: npm install -g @anthropic-ai/claude-code"
        return 1
    fi

    # Verify required commands
    for cmd in "${REQUIRED_COMMANDS[@]}"; do
        if ! command_exists "$cmd"; then
            log_error "Required command not found: $cmd"
            return 1
        fi
    done

    # Verify symlinks
    for i in "${!CONFIG_SOURCES[@]}"; do
        source="${CONFIG_SOURCES[$i]}"
        target="${CONFIG_TARGETS[$i]}"
        validate_symlink "$target" "$source" || return 1
    done


    # Verify file contents are accessible
    if [ ! -r "$HOME/.claude/CLAUDE.md" ]; then
        log_error "Cannot read global CLAUDE.md"
        return 1
    fi

    if [ ! -r "$HOME/.claude/settings.json" ]; then
        log_error "Cannot read settings.json"
        return 1
    fi

    # Check if settings.json is valid JSON
    if command_exists "jq"; then
        if jq . "$HOME/.claude/settings.json" >/dev/null 2>&1; then
            log_success "settings.json is valid JSON"
        else
            log_error "settings.json contains invalid JSON"
            return 1
        fi
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
