{ hostName, system, ... }:

{
  imports = [
    ./nix.nix
    ./system.nix
    ./users.nix
  ];

  networking.hostName = hostName;
  networking.computerName = hostName;
  networking.localHostName = hostName;

  nixpkgs.hostPlatform = system;
  nixpkgs.config.allowUnfree = true;
}
