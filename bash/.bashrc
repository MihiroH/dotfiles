export EDITOR=/Applications/MacVim.app/Contents/MacOS/Vim
alias vi='env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'
alias vim='env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'
HISTSIZE=10000
HISTFILESIZE=10000

# エイリアスの設定
# ls（カラー表示）
alias ls='ls -G'
alias ll='ls -lG'
alias la='ls -laG'

# プロンプトの設定
PS1='\[\e[34m\]\w \[\e[37m\]\$\[\e[0m\] '

cdls ()
{
    \cd "$@" && ls
}
alias cd="cdls"
export HISTTIMEFORMAT='%F %T '

export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init -)"

export PATH="$PATH:`yarn global bin`"

# git-alias
alias g='git'
source ~/.git-completion.bash

export YVM_DIR=/Users/mihiro/.yvm
[ -r $YVM_DIR/yvm.sh ] && . $YVM_DIR/yvm.sh
