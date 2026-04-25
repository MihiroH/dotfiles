{ config, dotfilesPath, ... }:

{
  # Karabiner-Elements writes karabiner.json back whenever rules are
  # edited via the GUI, so the target must be a writeable path (the repo)
  # rather than a readonly nix store copy.
  home.file.".config/karabiner".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/karabiner";
}
