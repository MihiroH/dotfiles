if [ -f ${HOME}/.zsh_profile ]; then
       source ${HOME}/.zsh_profile
fi

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
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=36'

GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUPSTREAM=auto
# PROMPT="[%m]%# "
RPROMPT="%*"
setopt PROMPT_SUBST
PS1=$'\n%c%F{#5ab0f6}$(__git_ps1 " (%s)")%f\n%# '

# history コマンドに日時を表示させる
export HISTTIMEFORMAT='%F %T '

# Homebrew
export PATH=/opt/homebrew/bin:$PATH

# Homebrew PHP
export PATH=/opt/homebrew/bin/php:$PATH

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
  export YVM_DIR=/Users/mihiro.h/.yvm
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
# bindkey -v

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

#pecoでhistory検索
function peco-select-history() {
       BUFFER=$(\history -n -r 1 | peco --query "$LBUFFER")
       CURSOR=$#BUFFER
       zle clear-screen
}
zle -N peco-select-history
bindkey '^r' peco-select-history

# search a destination from cdr list
function peco-get-destination-from-cdr() {
       cdr -l | \
       sed -e 's/^[[:digit:]]*[[:blank:]]*//' | \
       peco --query "$LBUFFER"
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export PATH="$HOME/anaconda3/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Add cargo-installed binaries to the path
export PATH="$PATH:$CARGO_HOME/bin"

# bun completions
[ -s "/Users/mihiro/.bun/_bun" ] && source "/Users/mihiro/.bun/_bun"

# bun
export BUN_INSTALL="/Users/mihiro/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/mihiro/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/mihiro/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/mihiro/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/mihiro/google-cloud-sdk/completion.zsh.inc'; fi

# gcloud
export GOOGLE_APPLICATION_CREDENTIALS="/Users/mihiro/.config/gcloud/legacy_credentials/mihiro.yanagawa@legalscape.co.jp/adc.json"

# java
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"

export PATH="/opt/homebrew/opt/jpeg/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/jpeg/lib"
export CPPFLAGS="-I/opt/homebrew/opt/jpeg/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/jpeg/lib/pkgconfig"

# export PATH="/usr/local/opt/jpeg/bin:$PATH"
# export LDFLAGS="-L/usr/local/opt/jpeg/lib"
# export CPPFLAGS="-I/usr/local/opt/jpeg/include"
# export PKG_CONFIG_PATH="/usr/local/opt/jpeg/lib/pkgconfig"
