{ config, dotfilesPath, ... }:

{
  # Karabiner-Elements writes karabiner.json back to ~/.config/karabiner
  # whenever rules are edited via the GUI, so the target must be a
  # writeable path (the repo) rather than a readonly nix store copy.
  # The Karabiner-Elements.app itself is still provided by the brew cask
  # until Phase 4.
  home.file.".config/karabiner".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/karabiner";
}
