{ config, dotfilesPath, ... }:

{
  home.file.".config/kitty".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/kitty";
}
