#!/bin/bash

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
CONFIG_SOURCES=(
    # "$SCRIPT_DIR/config.file"
)
CONFIG_TARGETS=(
    # "$HOME/.config/tool/config.file"
)

# Directories to symlink entirely (source:target)
SYMLINK_SOURCES=(
    # "$SCRIPT_DIR"
)
SYMLINK_TARGETS=(
    # "$HOME/.config/tool"
)

# Files to download (url:target)
DOWNLOAD_URLS=(
    # "https://example.com/file.conf"
)
DOWNLOAD_TARGETS=(
    # "$HOME/.config/tool/file.conf"
)

# Git repositories to clone (url:target)
CLONE_URLS=(
    # "https://github.com/user/repo.git"
)
CLONE_TARGETS=(
    # "$HOME/.local/share/tool/repo"
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
    for i in "${!SYMLINK_SOURCES[@]}"; do
        source="${SYMLINK_SOURCES[$i]}"
        target="${SYMLINK_TARGETS[$i]}"
        create_symlink "$source" "$target" || return 1
    done
    
    # Create symlinks for individual files
    for i in "${!CONFIG_SOURCES[@]}"; do
        source="${CONFIG_SOURCES[$i]}"
        target="${CONFIG_TARGETS[$i]}"
        create_symlink "$source" "$target" || return 1
    done
    
    # Download files
    for i in "${!DOWNLOAD_URLS[@]}"; do
        url="${DOWNLOAD_URLS[$i]}"
        target="${DOWNLOAD_TARGETS[$i]}"
        download_if_missing "$url" "$target" || log_warning "Failed to download: $url"
    done
    
    # Clone repositories
    for i in "${!CLONE_URLS[@]}"; do
        url="${CLONE_URLS[$i]}"
        target="${CLONE_TARGETS[$i]}"
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
    for i in "${!SYMLINK_SOURCES[@]}"; do
        source="${SYMLINK_SOURCES[$i]}"
        target="${SYMLINK_TARGETS[$i]}"
        validate_symlink "$target" "$source" || return 1
    done
    
    for i in "${!CONFIG_SOURCES[@]}"; do
        source="${CONFIG_SOURCES[$i]}"
        target="${CONFIG_TARGETS[$i]}"
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