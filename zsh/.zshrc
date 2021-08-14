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
PS1=$'\n%c%F{#08e6e6}$(__git_ps1 " (%s)")%f\n%# '

# history コマンドに日時を表示させる
export HISTTIMEFORMAT='%F %T '

export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init -)"

if [ -f ${HOME}/.yvm/yvm.sh ]; then
       source ~/.yvm/yvm.sh
fi

# yarn
export PATH="$PATH:`yarn global bin`"

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

export YVM_DIR=/Users/mihiro.h/.yvm
[ -r $YVM_DIR/yvm.sh ] && . $YVM_DIR/yvm.sh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export PATH="$HOME/anaconda3/bin:$PATH"
