#!/opt/homebrew/bin/bash

# Template for individual tool setup scripts
# Copy this file and modify for each tool

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$SCRIPT_DIR")/lib/common.sh" || {
    echo "Failed to source common utilities"
    exit 1
}

# Tool-specific configuration
TOOL_NAME="TOOL_NAME_HERE"
REQUIRED_COMMANDS=()  # Add required commands like ("git" "curl")

# Configuration files mapping (source:target)
declare -A CONFIG_FILES=(
    # ["$SCRIPT_DIR/config.file"]="$HOME/.config/tool/config.file"
)

# Directories to symlink entirely (source:target)
declare -A SYMLINK_DIRS=(
    # ["$SCRIPT_DIR"]="$HOME/.config/tool"
)

# Files to download (url:target)
declare -A DOWNLOAD_FILES=(
    # ["https://example.com/file.conf"]="$HOME/.config/tool/file.conf"
)

# Git repositories to clone (url:target)
declare -A CLONE_REPOS=(
    # ["https://github.com/user/repo.git"]="$HOME/.local/share/tool/repo"
)

# Setup function
setup_tool() {
    print_section "Setting up $TOOL_NAME"
    
    # Check permissions
    ensure_permissions || return 1
    
    # Check required commands
    if [ ${#REQUIRED_COMMANDS[@]} -gt 0 ]; then
        require_commands "${REQUIRED_COMMANDS[@]}" || return 1
    fi
    
    # Create symlinks for directories
    for source in "${!SYMLINK_DIRS[@]}"; do
        target="${SYMLINK_DIRS[$source]}"
        create_symlink "$source" "$target" || return 1
    done
    
    # Create symlinks for individual files
    for source in "${!CONFIG_FILES[@]}"; do
        target="${CONFIG_FILES[$source]}"
        create_symlink "$source" "$target" || return 1
    done
    
    # Download files
    for url in "${!DOWNLOAD_FILES[@]}"; do
        target="${DOWNLOAD_FILES[$url]}"
        download_if_missing "$url" "$target" || log_warning "Failed to download: $url"
    done
    
    # Clone repositories
    for url in "${!CLONE_REPOS[@]}"; do
        target="${CLONE_REPOS[$url]}"
        clone_if_missing "$url" "$target" || log_warning "Failed to clone: $url"
    done
    
    # Tool-specific post-setup actions
    post_setup || return 1
    
    log_success "$TOOL_NAME setup completed!"
    return 0
}

# Tool-specific post-setup actions
post_setup() {
    # Override this function in your setup script for custom actions
    # Example: setting permissions, running commands, etc.
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
    
    for source in "${!CONFIG_FILES[@]}"; do
        target="${CONFIG_FILES[$source]}"
        validate_symlink "$target" "$source" || return 1
    done
    
    # Tool-specific verification
    verify_tool || return 1
    
    log_success "$TOOL_NAME verification passed!"
    return 0
}

# Tool-specific verification
verify_tool() {
    # Override this function in your setup script for custom verification
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