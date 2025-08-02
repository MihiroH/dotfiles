#!/bin/bash

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$SCRIPT_DIR")/lib/common.sh" || {
    echo "Failed to source common utilities"
    exit 1
}

# Tool-specific configuration
TOOL_NAME="Zsh"
REQUIRED_COMMANDS=("zsh" "git" "curl")

# Configuration files mapping (source:target)
CONFIG_SOURCES=(
    "$SCRIPT_DIR/.zshrc"
    "$SCRIPT_DIR/.zsh_profile"
)
CONFIG_TARGETS=(
    "$HOME/.zshrc"
    "$HOME/.zsh_profile"
)

# Files to download (url:target)
DOWNLOAD_URLS=(
    "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash"
    "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh"
)
DOWNLOAD_TARGETS=(
    "$HOME/.zsh/git-completion.zsh"
    "$HOME/.zsh/git-prompt.sh"
)

# Git repositories to clone (url:target)
CLONE_URLS=(
    "https://github.com/zsh-users/zsh-autosuggestions.git"
)
CLONE_TARGETS=(
    "$HOME/.zsh/zsh-autosuggestions"
)

# Setup function
setup_tool() {
    print_section "Setting up $TOOL_NAME"
    
    # Check permissions
    ensure_permissions || return 1
    
    # Check required commands
    require_commands "${REQUIRED_COMMANDS[@]}" || return 1
    
    # Create symlinks for configuration files
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
    
    # Post-setup actions
    post_setup || return 1
    
    log_success "$TOOL_NAME setup completed!"
    return 0
}

# Post-setup actions
post_setup() {
    # Check if zsh is the default shell
    local current_shell=$(basename "$SHELL")
    if [ "$current_shell" != "zsh" ]; then
        log_warning "Zsh is not your default shell"
        log_info "To make zsh your default shell, run: chsh -s $(which zsh)"
    fi
    
    # Create .zsh directory if it doesn't exist
    mkdir -p "$HOME/.zsh"
    
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
    
    # Verify downloaded files
    for i in "${!DOWNLOAD_TARGETS[@]}"; do
        target="${DOWNLOAD_TARGETS[$i]}"
        if [ ! -f "$target" ]; then
            log_error "Missing downloaded file: $target"
            return 1
        fi
    done
    
    # Verify cloned repos
    for i in "${!CLONE_TARGETS[@]}"; do
        target="${CLONE_TARGETS[$i]}"
        if [ ! -d "$target/.git" ]; then
            log_error "Missing git repository: $target"
            return 1
        fi
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