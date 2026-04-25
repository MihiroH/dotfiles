{ pkgs, config, dotfilesPath, ... }:

{
  home.packages = [ pkgs.neovim ];

  # mkOutOfStoreSymlink (not xdg.configFile.source) so lazy.nvim can
  # keep writing lazy-lock.json back into the repo.
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/nvim";
}
