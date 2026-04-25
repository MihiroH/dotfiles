{ pkgs, lib, ... }:

{
  # pkgs.pinentry_mac installs only an .app bundle, no binary on PATH —
  # reference the store path directly so gpg-agent can find the
  # interpreter.
  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
  '';

  # Pick up gpg-agent.conf changes on switch so the user does not have
  # to manually `gpg-connect-agent reloadagent /bye` or re-login.
  home.activation.reloadGpgAgent = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.gnupg}/bin/gpg-connect-agent reloadagent /bye 2>/dev/null || true
  '';
}
