{ pkgs, ... }:

{
  # CLI tools and small GUI helpers managed via nix instead of brew.
  # Runtimes are in ./runtimes.nix; per-tool program modules live under
  # ./programs/.
  home.packages = with pkgs; [
    asciinema
    asciinema-agg
    fd
    ghq
    gnupg
    google-cloud-sdk
    jq
    kitty
    lua
    maccy
    prettierd
    pstree
    ripgrep
    tree
    tree-sitter
  ];
}
