{ config, dotfilesPath, ... }:

{
  # Whole repo kitty/ directory: kitty.conf, kitty.d/, kitty-themes/,
  # macos-launch-services-cmdline. mkOutOfStoreSymlink keeps the existing
  # legacy-symlink target shape so a re-activation does not collide with
  # what `kitty/setup.sh` previously set up. The kitty.app itself is still
  # provided by the brew cask until Phase 4.
  home.file.".config/kitty".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/kitty";
}
