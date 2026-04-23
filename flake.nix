{
  description = "mihiro-mac dotfiles (nix-darwin + home-manager migration)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, nix-darwin }:
    let
      mkHost = import ./lib/mkHost.nix;
    in
    {
      darwinConfigurations."mihiro-mac" = mkHost {
        inherit inputs;
        hostName = "mihiro-mac";
        system = "aarch64-darwin";
        username = "mihiro";
      };

      formatter.aarch64-darwin =
        nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
    };
}
