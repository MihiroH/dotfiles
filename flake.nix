{
  description = "mihiro-mac dotfiles (nix-darwin + home-manager)";

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

      hostName = "mihiro-mac";
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};

      # darwin-rebuild built from this flake's pinned nix-darwin input.
      # Using this path means `nix run .#switch` does not have to fetch
      # nix-darwin from GitHub on every invocation (which trips the
      # unauthenticated API rate limit).
      darwinRebuild =
        "${self.darwinConfigurations.${hostName}.config.system.build.darwin-rebuild}/bin/darwin-rebuild";
    in
    {
      darwinConfigurations.${hostName} = mkHost {
        inherit inputs hostName system;
        username = "mihiro";
      };

      formatter = forAllSystems (sys:
        nixpkgs.legacyPackages.${sys}.nixpkgs-fmt);

      apps.${system} = {
        # Build the darwin system closure into ./result without activating.
        build = {
          type = "app";
          meta.description = "Build the darwin system into ./result without activating";
          program = toString (pkgs.writeShellScript "darwin-build" ''
            set -e
            echo "Building darwin configuration..."
            nix build .#darwinConfigurations.${hostName}.system "$@"
            echo "Build successful. Run 'nix run .#switch' to apply."
          '');
        };

        # Activate the darwin system. Wraps darwin-rebuild switch so the
        # caller does not have to remember --flake .#${hostName}.
        switch = {
          type = "app";
          meta.description = "Build and activate the darwin system";
          program = toString (pkgs.writeShellScript "darwin-switch" ''
            set -eo pipefail
            exec sudo ${darwinRebuild} switch --flake .#${hostName} "$@"
          '');
        };

        # Refresh flake.lock for all (or selected) inputs.
        update = {
          type = "app";
          meta.description = "Refresh flake.lock (run nix run .#switch afterwards)";
          program = toString (pkgs.writeShellScript "flake-update" ''
            set -e
            echo "Updating flake.lock..."
            nix flake update "$@"
            echo "Done. Run 'nix run .#switch' to apply changes."
          '');
        };
      };
    };
}
