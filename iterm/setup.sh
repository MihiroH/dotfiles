#!/opt/homebrew/bin/bash

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$SCRIPT_DIR")/lib/common.sh" || {
    echo "Failed to source common utilities"
    exit 1
}

# Tool-specific configuration
TOOL_NAME="iTerm2"
REQUIRED_COMMANDS=("curl")

# Configuration files (for copying, not symlinking)
PLIST_SOURCE="$SCRIPT_DIR/com.googlecode.iterm2.plist"
PLIST_TARGET="$HOME/Library/Preferences/com.googlecode.iterm2.plist"

# Font configuration
FONT_DIR="$HOME/Library/Fonts"
FONT_NAME="FiraCodeNerdFont-Medium.ttf"
FONT_URL="https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/FiraCode/Medium/$FONT_NAME"

# Setup function
setup_tool() {
    print_section "Setting up $TOOL_NAME"
    
    # Check permissions
    ensure_permissions || return 1
    
    # macOS only
    if ! is_macos; then
        log_error "iTerm2 is only available for macOS"
        return 1
    fi
    
    # Check required commands
    require_commands "${REQUIRED_COMMANDS[@]}" || return 1
    
    # Install font
    download_if_missing "$FONT_URL" "$FONT_DIR/$FONT_NAME" || {
        log_warning "Failed to download FiraCode Nerd Font"
    }
    
    # Handle preferences file
    if [ -f "$PLIST_SOURCE" ]; then
        # Backup existing preferences
        backup_if_exists "$PLIST_TARGET"
        
        # Copy preferences (iTerm2 doesn't work well with symlinks)
        if cp "$PLIST_SOURCE" "$PLIST_TARGET"; then
            log_success "iTerm2 preferences copied: $PLIST_SOURCE -> $PLIST_TARGET"
        else
            log_error "Failed to copy iTerm2 preferences"
            return 1
        fi
    else
        log_error "iTerm2 preferences file not found: $PLIST_SOURCE"
        return 1
    fi
    
    # Post-setup actions
    post_setup || return 1
    
    log_success "$TOOL_NAME setup completed!"
    return 0
}

# Post-setup actions
post_setup() {
    # Check if iTerm2 is installed
    if [ -d "/Applications/iTerm.app" ]; then
        log_info "iTerm.app found in Applications folder"
        
        # Kill iTerm2 if running to apply new preferences
        if pgrep -x "iTerm2" > /dev/null; then
            log_warning "iTerm2 is running. You may need to restart it to apply new preferences."
            log_info "Run: killall iTerm2 && open -a iTerm"
        fi
    else
        log_warning "iTerm2 not found. Install from: https://iterm2.com/"
    fi
    
    # Inform about font installation
    if [ -f "$FONT_DIR/$FONT_NAME" ]; then
        log_info "FiraCode Nerd Font installed. It should be available in iTerm2 preferences."
    fi
    
    # Alternative configuration method
    log_info "Alternative: You can also specify a preferences folder in iTerm2:"
    log_info "Preferences -> General -> Preferences -> Load preferences from a custom folder"
    
    return 0
}

# Verify installation
verify_installation() {
    log_info "Verifying $TOOL_NAME installation..."
    
    # Check preferences file
    if [ ! -f "$PLIST_TARGET" ]; then
        log_error "iTerm2 preferences file not found: $PLIST_TARGET"
        return 1
    fi
    
    # Check if it's a valid plist
    if command_exists "plutil"; then
        if plutil -lint "$PLIST_TARGET" >/dev/null 2>&1; then
            log_success "iTerm2 preferences file is valid"
        else
            log_error "iTerm2 preferences file is corrupted"
            return 1
        fi
    else
        log_warning "Cannot validate plist file (plutil not found)"
    fi
    
    # Check font installation
    if [ -f "$FONT_DIR/$FONT_NAME" ]; then
        log_success "FiraCode Nerd Font is installed"
    else
        log_warning "FiraCode Nerd Font not found"
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