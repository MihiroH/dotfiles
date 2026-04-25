{ pkgs, lib, ... }:

{
  # gnupg itself is provided via home/packages.nix. Wire pinentry-mac so
  # gpg-agent uses the native macOS dialog when a passphrase is needed.
  # Reference pkgs.pinentry_mac directly so its store path is realised
  # without polluting PATH (the package installs only an .app bundle).
  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
  '';

  # Reload gpg-agent on switch so changes to gpg-agent.conf take effect
  # without requiring a manual reloadagent or re-login. Tolerate the
  # agent not being running (no signing happened yet this session).
  home.activation.reloadGpgAgent = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.gnupg}/bin/gpg-connect-agent reloadagent /bye 2>/dev/null || true
  '';
}
