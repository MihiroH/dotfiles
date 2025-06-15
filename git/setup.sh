#!/opt/homebrew/bin/bash

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$SCRIPT_DIR")/lib/common.sh" || {
    echo "Failed to source common utilities"
    exit 1
}

# Tool-specific configuration
TOOL_NAME="Git"
REQUIRED_COMMANDS=("git")

# Configuration files mapping (source:target)
declare -A CONFIG_FILES=(
    ["$SCRIPT_DIR/.gitconfig"]="$HOME/.config/git/config"
    ["$SCRIPT_DIR/.gitignore"]="$HOME/.config/git/ignore"
)

# Setup function
setup_tool() {
    print_section "Setting up $TOOL_NAME"
    
    # Check permissions
    ensure_permissions || return 1
    
    # Check required commands
    require_commands "${REQUIRED_COMMANDS[@]}" || return 1
    
    # Create symlinks for configuration files
    for source in "${!CONFIG_FILES[@]}"; do
        target="${CONFIG_FILES[$source]}"
        create_symlink "$source" "$target" || return 1
    done
    
    # Verify git user configuration
    post_setup || return 1
    
    log_success "$TOOL_NAME setup completed!"
    return 0
}

# Post-setup actions
post_setup() {
    # Check if git user is configured
    if ! git config --global user.name >/dev/null 2>&1; then
        log_warning "Git user name not configured. Run: git config --global user.name 'Your Name'"
    fi
    
    if ! git config --global user.email >/dev/null 2>&1; then
        log_warning "Git user email not configured. Run: git config --global user.email 'your.email@example.com'"
    fi
    
    return 0
}

# Verify installation
verify_installation() {
    log_info "Verifying $TOOL_NAME installation..."
    
    # Verify symlinks
    for source in "${!CONFIG_FILES[@]}"; do
        target="${CONFIG_FILES[$source]}"
        validate_symlink "$target" "$source" || return 1
    done
    
    # Check if git config is readable
    if ! git config --list >/dev/null 2>&1; then
        log_error "Git configuration is not readable"
        return 1
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
