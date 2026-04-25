{ ... }:

{
  programs.zsh = {
    enable = true;

    # Phase 1 minimal: source the legacy ~/.zshrc.backup created on first
    # home-manager activation so existing shell behavior (Homebrew PATH,
    # mise, fzf widgets, prompt, completions) is preserved unchanged.
    # Phase 4 cleans this up and migrates the body into Nix.
    initContent = ''
      if [ -f "$HOME/.zshrc.backup" ]; then
        source "$HOME/.zshrc.backup"
      fi
    '';
  };
}
