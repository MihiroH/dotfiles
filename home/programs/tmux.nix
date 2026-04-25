{ pkgs, ... }:

{
  home.packages = [ pkgs.tmux ];

  # tmux.conf's `bind r source-file ~/.config/tmux/tmux.conf` reload
  # expects the XDG path. programs.tmux writes to ~/.tmux.conf instead,
  # so wire the file directly.
  xdg.configFile."tmux/tmux.conf".source = ../../tmux/tmux.conf;
}
