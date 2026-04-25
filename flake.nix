{
  description = "mihiro-mac dotfiles (nix-darwin + home-manager migration)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, nix-darwin, home-manager }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-darwin" ];
      mkHost = import ./lib/mkHost.nix;
    in
    {
      darwinConfigurations."mihiro-mac" = mkHost {
        inherit inputs;
        hostName = "mihiro-mac";
        system = "aarch64-darwin";
        username = "mihiro";
      };

      formatter = forAllSystems (system:
        nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
    };
}
