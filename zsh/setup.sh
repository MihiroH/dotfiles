# Paths to configuration files
CONFIG_FILES=(
  "~/.zshrc|~/Documents/personal/settings-files/zsh/.zshrc"
  "~/.zsh_profile|~/Documents/personal/settings-files/zsh/.zsh_profile"
)

# Plugin URLs and target directories
PLUGINS=(
  "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash|~/.zsh/git-completion.zsh"
  "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh|~/.zsh/git-prompt.sh"
  "https://github.com/zsh-users/zsh-autosuggestions.git|~/.zsh/zsh-autosuggestions"
)

# Create symbolic links
for entry in "${CONFIG_FILES[@]}"; do
  IFS="|" read -r target source <<< "$entry"

  # Expand ~ to $HOME
  target="${target/#\~/$HOME}"
  source="${source/#\~/$HOME}"

  # Ensure the target directory exists
  mkdir -p "$(dirname "$target")"

  # Back up existing file if needed
  if [ -f "$target" ] && [ ! -L "$target" ]; then
    mv "$target" "$target.bak"
    echo "Backed up $target to $target.bak"
  fi

  # Create symbolic link
  ln -sf "$source" "$target"
  echo "Linked $source -> $target"
done

# Download plugins if they don’t Exist
for entry in "${PLUGINS[@]}"; do
  IFS="|" read -r url target <<< "$entry"

  # Expand path
  target="${target/#\~/$HOME}"

  if [ ! -e "$target" ]; then
    # If it's a git repo
    if [[ "$url" == *".git" ]]; then
      git clone "$url" "$target"
      echo "Cloned $url into $target"

    # Otherwise, treat it as a raw file
    else
      # Ensure the target directory exists
      mkdir -p "$(dirname "$target")"

      curl -L "$url" -o "$target"
      echo "Downloaded $url to $target"
    fi
  fi
done
