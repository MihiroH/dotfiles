#!/bin/bash
set -euo pipefail
# Common utility functions for dotfiles setup scripts
# This file should be sourced by individual setup scripts

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Get the absolute path of the script directory
# Usage: SCRIPT_DIR=$(get_script_dir)
get_script_dir() {
    local src="${BASH_SOURCE[1]}"
    ( cd "$(dirname "$src")" && pwd )
}

# Check if a command exists
# Usage: if command_exists "git"; then ... fi
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Create a backup of a file or directory
# Usage: backup_if_exists "/path/to/file"
backup_if_exists() {
    local target="$1"
    local backup_suffix="${2:-.bak}"
    
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        local backup_path="${target}${backup_suffix}"
        local counter=1
        
        # Find a unique backup filename
        while [ -e "$backup_path" ]; do
            backup_path="${target}${backup_suffix}.${counter}"
            ((counter++))
        done
        
        mv "$target" "$backup_path"
        log_info "Backed up existing file to $backup_path"
        return 0
    fi
    return 1
}

# Create a symbolic link with automatic backup
# Usage: create_symlink "/source/path" "/target/path"
create_symlink() {
    local source="$1"
    local target="$2"
    local force="${3:-false}"
    
    # Validate source exists
    if [ ! -e "$source" ]; then
        log_error "Source does not exist: $source"
        return 1
    fi
    
    # Create target directory if needed
    local target_dir=$(dirname "$target")
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
        log_info "Created directory: $target_dir"
    fi
    
    # Handle existing target
    if [ -e "$target" ] || [ -L "$target" ]; then
        if [ -L "$target" ]; then
            # It's already a symlink
            local current_source=$(readlink "$target")
            if [ "$current_source" = "$source" ]; then
                log_info "Symlink already exists and points to correct location: $target"
                return 0
            else
                log_warning "Symlink exists but points to different location: $current_source"
                if [ "$force" = "true" ]; then
                    rm "$target"
                else
                    backup_if_exists "$target"
                fi
            fi
        else
            # It's a regular file/directory
            backup_if_exists "$target"
        fi
    fi
    
    # Create the symlink
    ln -sf "$source" "$target"
    log_success "Created symlink: $source -> $target"
    return 0
}

# Download a file if it doesn't exist
# Usage: download_if_missing "url" "/target/path"
download_if_missing() {
    local url="$1"
    local target="$2"
    
    if [ -f "$target" ]; then
        log_info "File already exists: $target"
        return 0
    fi
    
    # Create target directory if needed
    local target_dir=$(dirname "$target")
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
    fi
    
    log_info "Downloading: $url -> $target"
    if curl -fsSL "$url" -o "$target"; then
        log_success "Downloaded successfully: $target"
        return 0
    else
        log_error "Failed to download: $url"
        return 1
    fi
}

# Clone a git repository if it doesn't exist
# Usage: clone_if_missing "git_url" "/target/path"
clone_if_missing() {
    local url="$1"
    local target="$2"
    
    if [ -d "$target/.git" ]; then
        log_info "Repository already exists: $target"
        return 0
    fi
    
    log_info "Cloning repository: $url -> $target"
    if git clone "$url" "$target"; then
        log_success "Cloned successfully: $target"
        return 0
    else
        log_error "Failed to clone: $url"
        return 1
    fi
}

# Verify that required commands are available
# Usage: require_commands "git" "curl" "nvim"
require_commands() {
    local missing=()
    
    for cmd in "$@"; do
        if ! command_exists "$cmd"; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        log_error "Missing required commands: ${missing[*]}"
        log_error "Please install them before running this script"
        return 1
    fi
    
    return 0
}

# Check if running on macOS
# Usage: if is_macos; then ... fi
is_macos() {
    case "$OSTYPE" in
        darwin*) return 0 ;;
        *) return 1 ;;
    esac
}

# Check if running on Linux
# Usage: if is_linux; then ... fi
is_linux() {
    case "$OSTYPE" in
        linux-gnu*) return 0 ;;
        *) return 1 ;;
    esac
}

# Get the dotfiles root directory
# Usage: DOTFILES_ROOT=$(get_dotfiles_root)
get_dotfiles_root() {
    local current_dir=$(get_script_dir)
    # Navigate up until we find the setup.sh in root
    while [ "$current_dir" != "/" ]; do
        if [ -f "$current_dir/setup.sh" ] && [ -f "$current_dir/CLAUDE.md" ]; then
            echo "$current_dir"
            return 0
        fi
        current_dir=$(dirname "$current_dir")
    done
    log_error "Could not find dotfiles root directory"
    return 1
}

# Display a section header
# Usage: print_section "Installing Git Configuration"
print_section() {
    echo
    echo "========================================"
    echo "$1"
    echo "========================================"
}

# Ask for user confirmation
# Usage: if confirm "Continue with installation?"; then ... fi
confirm() {
    local prompt="${1:-Continue?}"
    local default="${2:-n}"
    
    local yn_prompt="[y/N]"
    if [ "$default" = "y" ]; then
        yn_prompt="[Y/n]"
    fi
    
    read -p "$prompt $yn_prompt " -n 1 -r
    echo
    
    if [ -z "$REPLY" ]; then
        REPLY="$default"
    fi
    
    case "$REPLY" in
        y|Y) return 0 ;;
        *) return 1 ;;
    esac
}

# Check if script is run with sudo when it shouldn't be
# Usage: ensure_not_sudo
ensure_not_sudo() {
    if [ "$EUID" -eq 0 ]; then
        log_error "This script should not be run as root/sudo"
        log_error "Please run as a normal user"
        exit 1
    fi
}

# Ensure script has required permissions
# Usage: ensure_permissions
ensure_permissions() {
    # Check if we can write to home directory
    if [ ! -w "$HOME" ]; then
        log_error "Cannot write to home directory: $HOME"
        return 1
    fi
    
    # Check if we can create directories in .config
    if [ ! -d "$HOME/.config" ]; then
        if ! mkdir -p "$HOME/.config" 2>/dev/null; then
            log_error "Cannot create .config directory"
            return 1
        fi
    elif [ ! -w "$HOME/.config" ]; then
        log_error "Cannot write to .config directory"
        return 1
    fi
    
    return 0
}

# Run a command and handle errors
# Usage: run_command "command" "description"
run_command() {
    local cmd="$1"
    local description="${2:-Running command}"
    
    log_info "$description"
    if eval "$cmd"; then
        log_success "Completed: $description"
        return 0
    else
        log_error "Failed: $description"
        return 1
    fi
}

# Validate that a symlink points to the expected location
# Usage: validate_symlink "/path/to/link" "/expected/source"
validate_symlink() {
    local link="$1"
    local expected_source="$2"
    
    if [ ! -L "$link" ]; then
        log_error "Not a symlink: $link"
        return 1
    fi
    
    local actual_source=$(readlink "$link")
    if [ "$actual_source" != "$expected_source" ]; then
        log_error "Symlink points to wrong location: $link -> $actual_source (expected: $expected_source)"
        return 1
    fi
    
    log_success "Symlink verified: $link -> $expected_source"
    return 0
}