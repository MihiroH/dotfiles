{ username, ... }:

{
  system.stateVersion = 6;
  system.primaryUser = username;

  # Phase 2+ で拡張予定:
  # system.defaults.dock.autohide = true;
  # system.defaults.NSGlobalDomain.InitialKeyRepeat = 15;
  # system.defaults.NSGlobalDomain.KeyRepeat = 2;
  # system.defaults.CustomUserPreferences."com.googlecode.iterm2" = { ... };
}
