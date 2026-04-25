{ config, dotfilesPath, ... }:

{
  # cmux is the macOS app shell built on Ghostty. It reads ghostty
  # rendering settings from ~/.config/ghostty/config and its own
  # app-level prefs from ~/.config/cmux/settings.json. Match the legacy
  # individual-file symlinks (not whole directories) so a future
  # standalone Ghostty install can manage other files under
  # ~/.config/ghostty/ without conflict.
  home.file.".config/ghostty/config".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/cmux/ghostty/config";

  home.file.".config/cmux/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/cmux/settings.json";
}
