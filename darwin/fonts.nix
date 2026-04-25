{ pkgs, ... }:

{
  # System-wide fonts. nix-darwin links these into /Library/Fonts/Nix
  # Fonts/ during activation, so macOS apps (kitty, iTerm2, Karabiner,
  # IDEs) discover them through the standard font registry without any
  # per-app configuration.
  fonts.packages = [
    pkgs.nerd-fonts.monaspace
  ];
}
