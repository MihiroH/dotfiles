{ username, ... }:

{
  imports = [
    ./packages.nix
    ./programs/zsh.nix
  ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
}
