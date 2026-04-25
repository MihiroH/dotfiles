{ pkgs, ... }:

{
  home.packages = [ pkgs.tmux ];

  # Place at the XDG path the existing config's `bind r source-file
  # ~/.config/tmux/tmux.conf` reload binding expects, instead of using
  # programs.tmux which writes to ~/.tmux.conf.
  xdg.configFile."tmux/tmux.conf".source = ../../tmux/tmux.conf;
}
