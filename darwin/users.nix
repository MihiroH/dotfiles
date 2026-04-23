{ pkgs, username, ... }:

{
  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
}
