{ config, dotfilesPath, ... }:

{
  # Symlink individual files (not whole directories) so a future
  # standalone Ghostty install can manage other files under
  # ~/.config/ghostty/ without conflict.
  home.file.".config/ghostty/config".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/cmux/ghostty/config";

  home.file.".config/cmux/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/cmux/settings.json";
}
