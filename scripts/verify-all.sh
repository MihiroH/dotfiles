#!/opt/homebrew/bin/bash

# Verify all dotfile installations
# This script runs verification for all configured tools

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh" || {
    echo "Failed to source common utilities"
    exit 1
}

# Get dotfiles root
DOTFILES_ROOT=$(get_dotfiles_root)

# Tools to verify
TOOLS=("zsh" "git" "nvim" "kitty" "karabiner" "iterm")

# Verify individual tool
verify_tool() {
    local tool="$1"
    local script="$DOTFILES_ROOT/$tool/setup.sh"
    
    if [ ! -f "$script" ]; then
        log_warning "Setup script not found for $tool"
        return 1
    fi
    
    log_info "Verifying $tool..."
    if "$script" verify 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Main verification function
main() {
    print_section "Dotfiles Verification"
    
    local failed_tools=()
    local success_count=0
    
    for tool in "${TOOLS[@]}"; do
        if verify_tool "$tool"; then
            success_count=$((success_count + 1))
        else
            failed_tools+=("$tool")
        fi
    done
    
    echo
    print_section "Verification Summary"
    
    log_info "Tools verified: $success_count/${#TOOLS[@]}"
    
    if [ ${#failed_tools[@]} -eq 0 ]; then
        log_success "All tools verified successfully!"
        
        # Additional system checks
        echo
        log_info "Additional checks:"
        
        # Check shell
        if [ "$(basename "$SHELL")" = "zsh" ]; then
            log_success "Default shell is zsh"
        else
            log_warning "Default shell is not zsh: $SHELL"
        fi
        
        # Check Homebrew
        if command_exists "brew"; then
            log_success "Homebrew is available"
        else
            log_warning "Homebrew not found"
        fi
        
        # Check common tools
        local tools_to_check=("git" "nvim" "rg" "fd" "fzf")
        for cmd in "${tools_to_check[@]}"; do
            if command_exists "$cmd"; then
                log_success "$cmd is available"
            else
                log_warning "$cmd not found"
            fi
        done
        
        return 0
    else
        log_error "Verification failed for: ${failed_tools[*]}"
        log_info "Run individual tool setup to fix issues:"
        for tool in "${failed_tools[@]}"; do
            log_info "  ./setup.sh $tool"
        done
        return 1
    fi
}

# Run main function
main "$@"