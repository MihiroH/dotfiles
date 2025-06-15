#!/opt/homebrew/bin/bash

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$SCRIPT_DIR")/lib/common.sh" || {
    echo "Failed to source common utilities"
    exit 1
}

# Tool-specific configuration
TOOL_NAME="Claude Squad"
REQUIRED_COMMANDS=("tmux" "gh")

# Setup function
setup_tool() {
    print_section "Setting up $TOOL_NAME"
    
    # Check permissions
    ensure_permissions || return 1
    
    # Check required commands
    if [ ${#REQUIRED_COMMANDS[@]} -gt 0 ]; then
        require_commands "${REQUIRED_COMMANDS[@]}" || return 1
    fi
    
    # Install Claude Squad
    if ! command_exists "claude-squad" && ! command_exists "cs"; then
        log_info "Installing Claude Squad..."
        
        if command_exists "brew"; then
            # Install via Homebrew
            log_info "Installing via Homebrew..."
            brew install claude-squad || {
                log_error "Failed to install via Homebrew"
                return 1
            }
            
            # Create alias
            ln -s "$(brew --prefix)/bin/claude-squad" "$(brew --prefix)/bin/cs" 2>/dev/null || {
                log_warning "Failed to create 'cs' alias, it may already exist"
            }
        else
            # Install via curl
            log_info "Installing via curl..."
            curl -fsSL https://raw.githubusercontent.com/smtg-ai/claude-squad/main/install.sh | bash || {
                log_error "Failed to install via curl"
                return 1
            }
        fi
    else
        log_info "Claude Squad is already installed"
    fi
    
    # Post-setup actions
    post_setup || return 1
    
    log_success "$TOOL_NAME setup completed!"
    return 0
}

# Post-setup actions
post_setup() {
    # Check installation
    if command_exists "claude-squad" || command_exists "cs"; then
        log_success "Claude Squad is installed successfully"
        
        # Show version if available
        if command_exists "cs"; then
            log_info "Claude Squad version: $(cs --version 2>/dev/null || echo 'unknown')"
        elif command_exists "claude-squad"; then
            log_info "Claude Squad version: $(claude-squad --version 2>/dev/null || echo 'unknown')"
        fi
    else
        log_error "Claude Squad installation not found"
        return 1
    fi
    
    # Check tmux configuration
    if [ -f "$HOME/.tmux.conf" ]; then
        log_info "tmux configuration found at ~/.tmux.conf"
    else
        log_warning "No tmux configuration found. Claude Squad uses tmux for session management."
    fi
    
    # Provide usage instructions
    log_info "Claude Squad is ready to use!"
    log_info "Run 'cs' to start Claude Squad"
    log_info "Use 'cs --help' for more options"
    
    return 0
}

# Verify installation
verify_installation() {
    log_info "Verifying $TOOL_NAME installation..."
    
    # Check if Claude Squad is installed
    if ! command_exists "claude-squad" && ! command_exists "cs"; then
        log_error "Claude Squad not found in PATH"
        return 1
    fi
    
    # Check required dependencies
    for cmd in "${REQUIRED_COMMANDS[@]}"; do
        if ! command_exists "$cmd"; then
            log_error "Required dependency '$cmd' not found"
            return 1
        fi
    done
    
    # Test Claude Squad command
    if command_exists "cs"; then
        if cs --version &>/dev/null; then
            log_success "Claude Squad 'cs' command is working"
        else
            log_warning "Claude Squad 'cs' command exists but may have issues"
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