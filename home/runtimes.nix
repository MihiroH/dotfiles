{ pkgs, ... }:

{
  home.packages = with pkgs; [
    awscli2
    bun
    cargo
    ffmpeg
    firebase-tools
    go
    jdk21
    nodejs_24
    pnpm
    python313
    rustc
    rustfmt
    uv
    yarn-berry
  ];
}
