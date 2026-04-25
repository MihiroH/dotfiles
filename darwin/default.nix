{ hostName, system, ... }:

{
  imports = [
    ./fonts.nix
    ./homebrew.nix
    ./nix.nix
    ./system.nix
    ./tailscale.nix
    ./users.nix
  ];

  networking.hostName = hostName;
  networking.computerName = hostName;
  networking.localHostName = hostName;

  nixpkgs.hostPlatform = system;
  nixpkgs.config.allowUnfree = true;
}
