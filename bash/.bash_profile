# Setting PATH for Python 3.7
# The original version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.7/bin:${PATH}"
export PATH
export PATH="$HOME/Library/Python/2.7/bin:$PATH"
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# show git branch
# https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
source ~/.git-prompt.sh
source /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash

export EDITOR=/Applications/MacVim.app/Contents/MacOS/Vim
alias vi='env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'
alias vim='env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'
HISTSIZE=10000
HISTFILESIZE=10000

# プロンプト設定
export PS1='\n \[\e[36m $(__git_ps1 "(%s)")\n \[\e[1m\]\u \[\e[0m\]\W \n\[\e[0m\] $ '

cdls ()
{
    \cd "$@" && ls
}

alias cd="cdls"

# historyに日時を追加
# export HISTTIMEFORMAT='%F %T 'export PATH="$HOME/.anyenv/bin:$PATH"
export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init -)"

export PATH="$PATH:`yarn global bin`"

alias g='git'

alias gp='g push'

fetchpull () {
  git fetch -p && git pull
}
alias gfp="fetchpull"

add () {
  g add .
}
alias ga="add"

alias gc='g commit -am'

alias gac='g add . && g commit -m'

reset () {
  g reset
}
alias gr="reset"

alias gco='g checkout'

status() {
  g status
}
alias gs="status"

stash() {
  g stash
}
alias gsts="stash"

alias gpop="g stash pop"

alias gb='g branch'

alias gl='g log --name-only'

alias gd='g diff'

alias practice='cd /Users/mihiro/Documents/practice'

alias ip="networksetup -getinfo Wi-Fi | grep '^IP address:'"
