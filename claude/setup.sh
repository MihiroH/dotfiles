#!/bin/bash

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$SCRIPT_DIR")/lib/common.sh" || {
    echo "Failed to source common utilities"
    exit 1
}

# Tool-specific configuration
TOOL_NAME="Claude"
REQUIRED_COMMANDS=() # No specific commands required

# Configuration files mapping (source:target)
CONFIG_SOURCES=(
    "$SCRIPT_DIR/CLAUDE.md"
    "$SCRIPT_DIR/settings.json"
)
CONFIG_TARGETS=(
    "$HOME/.claude/CLAUDE.md"
    "$HOME/.claude/settings.json"
)

# Setup function
setup_tool() {
    print_section "Setting up $TOOL_NAME"
    
    # Check permissions
    ensure_permissions || return 1
    
    # Create necessary directories
    log_info "Creating Claude configuration directory..."
    mkdir -p "$HOME/.claude"
    
    # Create symlinks for individual files
    for i in "${!CONFIG_SOURCES[@]}"; do
        source="${CONFIG_SOURCES[$i]}"
        target="${CONFIG_TARGETS[$i]}"
        create_symlink "$source" "$target" || return 1
    done
    
    # Create project-level CLAUDE.md symlink
    log_info "Setting up project-level CLAUDE.md..."
    DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"
    if [ -f "$DOTFILES_ROOT/CLAUDE.md" ]; then
        # Check if it's already a symlink to our file
        if [ -L "$DOTFILES_ROOT/CLAUDE.md" ]; then
            current_target=$(readlink "$DOTFILES_ROOT/CLAUDE.md")
            if [ "$current_target" = "$SCRIPT_DIR/CLAUDE.md" ]; then
                log_info "Project CLAUDE.md already linked correctly"
            else
                log_warning "Project CLAUDE.md exists but points elsewhere: $current_target"
            fi
        else
            log_warning "Project CLAUDE.md already exists (not a symlink)"
        fi
    else
        create_symlink "$SCRIPT_DIR/CLAUDE.md" "$DOTFILES_ROOT/CLAUDE.md" || return 1
    fi
    
    # Post-setup actions
    post_setup || return 1
    
    log_success "$TOOL_NAME setup completed!"
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
    echo "  Project instructions: $(dirname "$SCRIPT_DIR")/CLAUDE.md"
    
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
    
    # Check project CLAUDE.md
    DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"
    if [ -f "$DOTFILES_ROOT/CLAUDE.md" ]; then
        log_success "Project CLAUDE.md exists"
    else
        log_error "Project CLAUDE.md not found"
        return 1
    fi
    
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