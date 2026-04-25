{ ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--layout=reverse"
      "--border"
      "--color=fg:#5c6a72,bg:#fdf6e3,hl:#35a77c"
      "--color=fg+:#5c6a72,bg+:#eaedc8,hl+:#35a77c"
      "--color=info:#8da101,prompt:#5c6a72,pointer:#35a77c"
      "--color=marker:#f85552,spinner:#df69ba,header:#8da101"
    ];
  };
}
