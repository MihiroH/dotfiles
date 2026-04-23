{ lib, ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "@admin" ];
  };

  nix.gc = {
    automatic = true;
    interval = [{ Weekday = 0; Hour = 3; Minute = 0; }];
    options = "--delete-older-than 30d";
  };

  nix.optimise.automatic = true;

  # Set to false if using Determinate Nix (which manages the daemon itself).
  nix.enable = lib.mkDefault true;
}
