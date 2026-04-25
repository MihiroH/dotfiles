{ pkgs, config, dotfilesPath, ... }:

{
  home.packages = [ pkgs.neovim ];

  # mkOutOfStoreSymlink instead of xdg.configFile.source so lazy.nvim can
  # keep writing lazy-lock.json back into the repo (and any future cache
  # files it wants to drop next to init.lua). The repo path is hardcoded
  # via dotfilesPath in mkHost specialArgs.
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/nvim";
}
