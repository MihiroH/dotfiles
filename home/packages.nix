{ pkgs, ... }:

{
  # Phase 1: CLI tools only. Runtimes (node/python/go/rust/bun/etc.) move
  # off mise into nix in Phase 4.
  home.packages = with pkgs; [
    fd
    ghq
    gnupg
    google-cloud-sdk
    jq
    kitty
    lua
    maccy
    prettierd
    ripgrep
    tree-sitter
  ];
}
