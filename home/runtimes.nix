{ pkgs, ... }:

{
  # Phase 4b: language runtimes and per-language CLIs replace the
  # equivalents previously managed by mise (~/.local/share/mise). Pinned
  # at the major-version level for runtimes that move fast (node,
  # python, java); leaf CLIs track nixpkgs latest.
  #
  # Per-project version overrides are not yet wired up; once enough
  # projects need divergent versions, introduce direnv + per-repo
  # flake.nix devShells alongside this baseline.
  home.packages = with pkgs; [
    awscli2
    bun
    cargo
    ffmpeg
    firebase-tools
    go
    jdk23
    nodejs_24
    pnpm
    python310
    rustc
    uv
    yarn-berry
  ];
}
