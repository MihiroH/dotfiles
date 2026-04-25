{ pkgs, ... }:

{
  # Phase 1: CLI tools only. Runtimes (node/python/go/rust/bun/etc.) move
  # off mise into nix in Phase 4.
  home.packages = with pkgs; [
    fd
    gh
    ghq
    gnupg
    jq
    lua
    prettierd
    ripgrep
    tree-sitter
  ];
}
