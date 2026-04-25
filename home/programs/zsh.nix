{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;

    history = {
      path = "${config.home.homeDirectory}/.zsh_history";
      size = 1000000;
      save = 1000000;
      share = true;
      ignoreDups = true;
      ignoreAllDups = true;
      reduceBlanks = true;
    };

    sessionVariables = {
      EDITOR = "nvim";
      MCP_TIMEOUT = "120000";
      HISTTIMEFORMAT = "%F %T ";
      GOPATH = "${config.home.homeDirectory}/go";
      GOBIN = "${config.home.homeDirectory}/go/bin";
    };

    shellAliases = {
      vi = "nvim";
      vim = "nvim";

      ls = "ls -G";
      ll = "ls -lG";
      la = "ls -laG";

      g = "git";
      ga = "add";
      gac = "g add . && g commit -m";
      gb = "g branch";
      gc = "g commit -am";
      gco = "g checkout";
      gd = "g diff";
      gdc = "git diff --cached";
      gfp = "fetchpull";
      gl = "g log --name-only";
      gp = "g push";
      gpop = "g stash pop";
      gr = "reset";
      gs = "status";
      gsts = "stash";

      ip = "ipconfig getifaddr en1 | pbcopy && pbpaste";
      pwdc = "pwd | tr -d '\\n' | pbcopy";
      ssh = "TERM=xterm-256color ssh";

      ireko = "node ${config.home.homeDirectory}/Documents/personal/ireko/dist/cli.cjs";
    };

    initContent = ''
      # ---- PATH ----------------------------------------------------------
      # claude CLI installs under ~/.local/bin via the official curl
      # installer; keep on PATH ahead of the system fallbacks. nix profile
      # paths are wired up by /etc/zprofile from nix-darwin.
      export PATH="$HOME/.local/bin:$PATH"
      export PATH="$PATH:$GOBIN"

      # ---- kitty / cmux integration --------------------------------------
      # Prevent input keys from being displayed with Ctrl+e or Ctrl+f.
      [[ -n $KITTY_WINDOW_ID ]] && stty sane

      # Set the kitty/ghostty tab title to the git repo root name when
      # inside a repo, otherwise the current directory basename.
      function _kitty_tab_title_precmd() {
        local title
        local git_root
        git_root=$(git rev-parse --show-toplevel 2>/dev/null)
        if [[ -n "$git_root" ]]; then
          title="''${git_root:t}"
        else
          title="''${PWD:t}"
        fi
        print -Pn "\e]2;''${title}\a"
      }
      precmd_functions+=(_kitty_tab_title_precmd)

      # ---- zsh-autosuggestions style -------------------------------------
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#35a77c'

      # ---- git-prompt + PS1 ----------------------------------------------
      # __git_ps1 ships in git's contrib/. Sourced from the nix git so the
      # path tracks flake.lock instead of /opt/homebrew.
      source ${pkgs.git}/share/git/contrib/completion/git-prompt.sh
      GIT_PS1_SHOWDIRTYSTATE=true
      GIT_PS1_SHOWUNTRACKEDFILES=true
      GIT_PS1_SHOWSTASHSTATE=true
      GIT_PS1_SHOWUPSTREAM=auto
      setopt PROMPT_SUBST
      PS1=$'\n%c%F{#3a94c5}$(__git_ps1 " (%s)")%f\n%# '

      # ---- shell options -------------------------------------------------
      bindkey -e
      setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS
      setopt no_beep nolistbeep
      setopt print_eight_bit
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
      autoload -U select-word-style
      select-word-style bash

      # ---- functions (alias targets and standalone helpers) --------------
      cdls() {
        \cd "$@" && ls
      }
      alias cd="cdls"

      add()       { git add .; }
      reset()     { git reset; }
      stash()     { git stash; }
      status()    { git status; }
      fetchpull() { git fetch -p && git pull; }
      rmbranch()  { git branch | grep "$1" | xargs git branch -D; }

      # gcloud wrapper that forces xterm-256color for `compute ssh`
      # because the remote tput often misbehaves with kitty/ghostty.
      gcloud() {
        if [[ "$1" == "compute" && "$2" == "ssh" ]]; then
          TERM=xterm-256color command gcloud "$@"
        else
          command gcloud "$@"
        fi
      }

      # ---- fzf widgets ---------------------------------------------------
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
        if [ -n "''${REPO}" ]; then
          BUFFER="cd ''${GHQ_ROOT}/''${REPO}"
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
          cd "''${DIR}" && ''${EDITOR:-vim} .
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
          cd "''${DIR}"
        fi
      }
      zle -N fzf-cd
      bindkey '^o' fzf-cd

      # ---- phantom (cmux completion) -------------------------------------
      if command -v phantom >/dev/null 2>&1; then
        eval "$(phantom completion zsh)"
      fi

      # ---- history search bindings (must stay near the end) --------------
      # Some sourced completions (phantom past versions, etc.) reset
      # arrow-key bindings, so register these after everything else.
      autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
      zle -N up-line-or-beginning-search
      zle -N down-line-or-beginning-search
      bindkey "''${terminfo[kcuu1]}" up-line-or-beginning-search
      bindkey "''${terminfo[kcud1]}" down-line-or-beginning-search
      bindkey "^[[A" up-line-or-beginning-search
      bindkey "^[[B" down-line-or-beginning-search
      bindkey "^[OA" up-line-or-beginning-search
      bindkey "^[OB" down-line-or-beginning-search

      # ---- secrets -------------------------------------------------------
      # Git-ignored file with TAVILY_API_KEY,
      # GOOGLE_APPLICATION_CREDENTIALS for the work GCP profile, etc.
      # The legacy zshrc inlined those values; pull them out to keep
      # work credentials and API tokens out of the repo.
      if [ -f "$HOME/.secrets.zsh" ]; then
        source "$HOME/.secrets.zsh"
      fi
    '';
  };
}
