{ username, ... }:

{
  imports = [
    ./packages.nix
    ./programs/fzf.nix
    ./programs/gh.nix
    ./programs/git.nix
    ./programs/gpg.nix
    ./programs/tmux.nix
    ./programs/zsh.nix
  ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
}
