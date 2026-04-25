{ inputs, hostName, system, username }:

inputs.nix-darwin.lib.darwinSystem {
  inherit system;
  specialArgs = { inherit inputs hostName username system; };
  modules = [
    ../darwin
  ];
}
