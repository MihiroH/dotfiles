#!/opt/homebrew/bin/bash

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Failed to source common utilities"
    exit 1
}

# Configuration
DRY_RUN=false
VERBOSE=false
FORCE=false

# Show help
show_help() {
    cat << EOF
Usage: $0 [OPTIONS] [TOOLS...]

Setup dotfiles for specified tools. If no tools are specified, all default tools will be setup.

OPTIONS:
    --dry-run        Show what would be done without making changes
    --verbose, -v    Show detailed output
    --force, -f      Force overwrite existing configurations without backup
    --help, -h       Show this help message

TOOLS:
    zsh, git, nvim, karabiner, iterm, kitty, mise, claude-squad

EXAMPLES:
    $0                    # Setup all default tools
    $0 zsh git            # Setup only zsh and git
    $0 --dry-run          # Show what would be done
    $0 --force nvim       # Force setup nvim without backups
EOF
}

# Parse command line options
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --force|-f)
            FORCE=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        -*)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

# Install Homebrew if needed
install_homebrew() {
    if ! command_exists "brew"; then
        log_info "Installing Homebrew..."
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY RUN] Would install Homebrew"
            return 0
        fi
        
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
            log_error "Failed to install Homebrew"
            return 1
        }
        
        # Set PATH for Apple Silicon
        if [ -f "/opt/homebrew/bin/brew" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        
        # Verify installation
        if command_exists "brew"; then
            log_success "Homebrew installed successfully: $(brew --version | head -1)"
        else
            log_error "Homebrew installation verification failed"
            return 1
        fi
    else
        log_info "Homebrew is already installed: $(brew --version | head -1)"
    fi
    return 0
}

# Package definitions
BREW_PACKAGES=("git" "ripgrep" "ghq" "fd" "fzf" "nvim" "gpg" "mise" "lua" "luarocks" "lynx" "tmux" "gh")
BREW_CASK_PACKAGES=("kitty")

# Tool dependencies
declare -A TOOL_DEPS=(
    [git]="git"
    [zsh]="zsh git curl"
    [nvim]="nvim git lua luarocks"
    [kitty]=""
    [karabiner]=""
    [iterm]="curl"
    [mise]="mise"
    [claude-squad]="tmux gh"
)

# Install packages
install_packages() {
    log_info "Checking and installing required packages..."
    
    # Install command-line packages
    for package in "${BREW_PACKAGES[@]}"; do
        if ! command_exists "$package" && ! brew list "$package" &>/dev/null; then
            log_info "Installing $package..."
            if [ "$DRY_RUN" = true ]; then
                log_info "[DRY RUN] Would install package: $package"
            else
                if brew install "$package"; then
                    log_success "Installed: $package"
                else
                    log_error "Failed to install: $package"
                    return 1
                fi
            fi
        else
            [ "$VERBOSE" = true ] && log_info "$package is already installed"
        fi
    done
    
    # Install GUI applications
    for package in "${BREW_CASK_PACKAGES[@]}"; do
        if ! brew list --cask "$package" &>/dev/null && [ ! -d "/Applications/${package^}.app" ]; then
            log_info "Installing $package (cask)..."
            if [ "$DRY_RUN" = true ]; then
                log_info "[DRY RUN] Would install cask: $package"
            else
                if brew install --cask "$package"; then
                    log_success "Installed: $package (cask)"
                else
                    log_error "Failed to install: $package (cask)"
                    return 1
                fi
            fi
        else
            [ "$VERBOSE" = true ] && log_info "$package (cask) is already installed"
        fi
    done
    
    # Handle mise config.toml
    if command_exists "mise" && [ -f "$SCRIPT_DIR/mise/config.toml" ]; then
        local mise_config="$HOME/.config/mise/config.toml"
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY RUN] Would link mise config to $mise_config"
        else
            create_symlink "$SCRIPT_DIR/mise/config.toml" "$mise_config" "$FORCE"
        fi
    fi
    
    return 0
}

# Default tools to set up if none are specified
DEFAULT_TOOLS=("zsh" "git" "nvim" "kitty" "karabiner" "iterm" "claude-squad")

# Available tools
AVAILABLE_TOOLS=()
for dir in "$SCRIPT_DIR"/*/; do
    if [ -f "$dir/setup.sh" ]; then
        tool=$(basename "$dir")
        # Skip lib and other non-tool directories
        if [[ ! "$tool" =~ ^(lib|bash|vim|vscode|themes)$ ]]; then
            AVAILABLE_TOOLS+=("$tool")
        fi
    fi
done

# Validate tool selection
validate_tools() {
    local tools=("$@")
    for tool in "${tools[@]}"; do
        if [[ ! " ${AVAILABLE_TOOLS[@]} " =~ " ${tool} " ]]; then
            log_error "Unknown tool: $tool"
            log_info "Available tools: ${AVAILABLE_TOOLS[*]}"
            return 1
        fi
    done
    return 0
}

# Check tool dependencies
check_tool_deps() {
    local tool=$1
    local deps="${TOOL_DEPS[$tool]:-}"
    
    if [ -n "$deps" ]; then
        local missing_deps=()
        for dep in $deps; do
            if ! command_exists "$dep" && ! brew list "$dep" &>/dev/null; then
                missing_deps+=("$dep")
            fi
        done
        
        if [ ${#missing_deps[@]} -gt 0 ]; then
            log_warning "Tool '$tool' requires: ${missing_deps[*]}"
            if [ "$DRY_RUN" = false ]; then
                log_info "Installing missing dependencies..."
                for dep in "${missing_deps[@]}"; do
                    if ! brew install "$dep"; then
                        log_error "Failed to install dependency: $dep"
                        return 1
                    fi
                done
            fi
        fi
    fi
    return 0
}

# Run setup for a tool
run_setup() {
    local tool=$1
    local script="$SCRIPT_DIR/$tool/setup.sh"
    
    if [ ! -f "$script" ]; then
        log_error "Setup script not found for $tool"
        return 1
    fi
    
    if [ ! -x "$script" ]; then
        chmod +x "$script"
    fi
    
    # Check dependencies first
    check_tool_deps "$tool" || return 1
    
    # Run setup
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY RUN] Would run setup for $tool"
        return 0
    fi
    
    # Pass force flag to individual setup scripts
    local setup_env=""
    [ "$FORCE" = true ] && setup_env="FORCE=true"
    
    if env $setup_env "$script"; then
        log_success "Setup completed for $tool"
        return 0
    else
        log_error "Setup failed for $tool"
        return 1
    fi
}

# Main setup function
main() {
    print_section "Dotfiles Setup"
    
    # Ensure not running as root
    ensure_not_sudo
    
    # Check permissions
    ensure_permissions || exit 1
    
    # Install Homebrew if needed
    if is_macos; then
        install_homebrew || exit 1
    else
        log_warning "Homebrew installation skipped (not macOS)"
    fi
    
    # Install required packages
    install_packages || exit 1
    
    # Determine which tools to setup
    local tools=("${@}")
    if [ ${#tools[@]} -eq 0 ]; then
        tools=("${DEFAULT_TOOLS[@]}")
        log_info "No tools specified, using defaults: ${tools[*]}"
    fi
    
    # Validate tool selection
    validate_tools "${tools[@]}" || exit 1
    
    # Setup each tool
    local failed_tools=()
    for tool in "${tools[@]}"; do
        print_section "Setting up: $tool"
        if ! run_setup "$tool"; then
            failed_tools+=("$tool")
            if [ "$FORCE" != true ]; then
                log_error "Stopping due to error. Use --force to continue despite errors."
                exit 1
            fi
        fi
    done
    
    # Summary
    print_section "Setup Summary"
    if [ ${#failed_tools[@]} -eq 0 ]; then
        log_success "All tools setup successfully!"
        
        # Show post-setup instructions
        echo
        log_info "Post-setup steps:"
        log_info "1. Restart your terminal or run: source ~/.zshrc"
        log_info "2. For Neovim, run :PackerSync to install plugins"
        log_info "3. For CopilotChat.nvim:"
        log_info "   - mise install rust && mise use -g rust"
        log_info "   - luarocks install tiktoken_core"
        log_info "4. Check individual tool instructions above"
    else
        log_error "Setup completed with errors for: ${failed_tools[*]}"
        exit 1
    fi
}

# Run main function with remaining arguments
main "$@"
