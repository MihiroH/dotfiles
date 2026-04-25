{ pkgs, ... }:

{
  # gnupg itself is provided via home/packages.nix. Wire pinentry-mac so
  # gpg-agent uses the native macOS dialog when a passphrase is needed.
  # Reference pkgs.pinentry_mac directly so its store path is realised
  # without polluting PATH (the package installs only an .app bundle).
  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
  '';
}
