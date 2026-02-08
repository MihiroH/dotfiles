if [ -f ${HOME}/.zsh_profile ]; then
       source ${HOME}/.zsh_profile
fi

export EDITOR="nvim"

# kitty
# Prevent input keys from being displayed with Ctrl+e or Ctrl+f
[[ -n $KITTY_WINDOW_ID ]] && stty sane

# Git
fpath=(~/.zsh $fpath)
if [ -f ${HOME}/.zsh/git-completion.zsh ]; then
       zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.zsh
fi
if [ -f ${HOME}/.zsh/git-prompt.sh ]; then
       source ${HOME}/.zsh/git-prompt.sh
fi
if [ -f ${HOME}/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
       source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
# ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=36'
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#35a77c'


GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUPSTREAM=auto
# PROMPT="[%m]%# "
# RPROMPT="%*"
setopt PROMPT_SUBST
# PS1=$'\n%c%F{#5ab0f6}$(__git_ps1 " (%s)")%f\n%# '
PS1=$'\n%c%F{#3a94c5}$(__git_ps1 " (%s)")%f\n%# '

# For Copilot Chat (avante.nvim)
# Load API key from secure location if file exists
if [ -f ~/.config/tavily/apps.json ]; then
    export TAVILY_API_KEY=$(jq -r '."api_key"' ~/.config/tavily/apps.json 2>/dev/null)
fi
# export GITHUB_TOKEN=$(jq -r '."github.com:Iv1.b507a08c87ecfe98".oauth_token' ~/.config/github-copilot/apps.json)
# export CODESPACES=true

# history コマンドに日時を表示させる
export HISTTIMEFORMAT='%F %T '

# Homebrew
export PATH=/opt/homebrew/bin:$PATH

export PATH="$HOME/.local/bin:$PATH"

# Homebrew PHP
export PATH=/opt/homebrew/bin/php:$PATH

# mise (package manager)
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
else
  echo "mise is not installed."
fi

# anyenv
if [ -d $HOME/.anyenv/ ]; then
       export PATH="$HOME/.anyenv/bin:$PATH"
       eval "$(anyenv init -)"
fi

# pyenv
if [ -d $HOME/.anyenv/envs/pyenv ]; then
  export PYENV_ROOT="$HOME/.anyenv/envs/pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
fi

# yvm (yarn)
if [ -f ${HOME}/.yvm/yvm.sh ]; then
  source ~/.yvm/yvm.sh
  export YVM_DIR="$HOME/.yvm"
  [ -r $YVM_DIR/yvm.sh ] && . $YVM_DIR/yvm.sh
  export PATH="$PATH:`yarn global bin`"
fi

# nvm
if [ -f ${HOME}/.nvm ]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion" # This loads nvm bash_completion
fi

# go
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN

# 補完機能
autoload -Uz compinit
compinit

# Emacs風キーバインド viがいいひとは -vで
bindkey -e

# cdとタイプしなくても、移動
setopt AUTO_CD

# cdの履歴を保持（同一のディレクトリは重複排除）
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

# ビープ音の停止
setopt no_beep

# ビープ音の停止(補完時)
setopt nolistbeep

# コマンド履歴
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

# 色を使用出来るようにする(数字では指定できない)
# autoload -Uz colors
# colors

# 日本語ファイル名を表示可能にする
setopt print_eight_bit

# 同時に起動したzshの間でヒストリを共有する
setopt share_history

# 直前と同じコマンドの場合は履歴に追加しない
setopt hist_ignore_dups

# 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups

# ヒストリに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks

# 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Ctrl-wでパスの文字列などをスラッシュ単位でdeleteできる
autoload -U select-word-style
select-word-style bash

# fzf
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS' --layout=reverse --border --color=fg:#5c6a72,bg:#fdf6e3,hl:#35a77c --color=fg+:#5c6a72,bg+:#eaedc8,hl+:#35a77c --color=info:#8da101,prompt:#5c6a72,pointer:#35a77c --color=marker:#f85552,spinner:#df69ba,header:#8da101'

function fzf-search-history() {
    local HISTORY=$(history -n -r 1 | fzf --query="$BUFFER" +m)
    if [ -n "$HISTORY" ]; then
        BUFFER=$HISTORY
        CURSOR=$#BUFFER
    else
        zle accept-line
    fi
}
zle -N fzf-search-history
bindkey '^r' fzf-search-history

function fzf-cd-git() {
    local GHQ_ROOT=$(ghq root)
    local REPO=$(fd --type d --hidden --no-ignore --max-depth 4 '.git' "$GHQ_ROOT" \
        | rg -v '/(\.github|node_modules)/' \
        | xargs -I {} dirname {} \
        | sed -e "s|^$GHQ_ROOT/||" \
        | sort -u \
        | fzf --query="$BUFFER" +m)

    if [ -n "${REPO}" ]; then
        BUFFER="cd ${GHQ_ROOT}/${REPO}"
    fi
    zle accept-line
}
zle -N fzf-cd-git
bindkey '^g' fzf-cd-git

function fzf-vim-find() {
    local DIR=$(fd --type d --hidden --no-ignore \
        --exclude '.git' \
        --exclude 'node_modules' \
        . \
        | fzf +m)

    if [ -n "$DIR" ]; then
        cd "${DIR}" && ${EDITOR:-vim} .
    fi
}
zle -N fzf-vim-find
bindkey '^v' fzf-vim-find

function fzf-cd() {
    local DIR=$(fd --type d --hidden --no-ignore \
        --exclude '.git' \
        --exclude 'node_modules' \
        . \
        | fzf +m)

    if [ -n "$DIR" ]; then
        cd "${DIR}"
    fi
}
zle -N fzf-cd
bindkey '^o' fzf-cd

export PATH="$HOME/anaconda3/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Add cargo-installed binaries to the path
export PATH="$PATH:$CARGO_HOME/bin"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# gcloud
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.config/gcloud/legacy_credentials/mihiro.hashimoto@legalscape.co.jp/adc.json"

# java
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"

export PATH="/opt/homebrew/opt/jpeg/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/jpeg/lib"
export CPPFLAGS="-I/opt/homebrew/opt/jpeg/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/jpeg/lib/pkgconfig"

export PATH="/usr/local/opt/jpeg/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/jpeg/lib"
export CPPFLAGS="-I/usr/local/opt/jpeg/include"
export PKG_CONFIG_PATH="/usr/local/opt/jpeg/lib/pkgconfig"

# Claude Code MCP Timeout
export MCP_TIMEOUT=120000

# phantom
if command -v phantom >/dev/null 2>&1; then
  eval "$(phantom completion zsh)"
fi

# cs-completion.zsh
if [ -f ${HOME}/.zsh/cs-completion.zsh ]; then
       source ${HOME}/.zsh/cs-completion.zsh
fi

# Submlime Merge
export PATH="/Applications/Sublime Merge.app/Contents/SharedSupport/bin:$PATH"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc'; fi
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/mihiro/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
