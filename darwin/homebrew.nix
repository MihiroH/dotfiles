{ ... }:

{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      # IMPORTANT: cleanup applies to BOTH casks and brew formulae and
      # there is no per-type override in nix-darwin. Set to null until
      # the formulae set is fully declared (planned for Phase 4b after
      # mise is removed); otherwise activation mass-uninstalls anything
      # not listed in `brews`. Removal of a cask currently requires a
      # manual `brew uninstall --cask <name>` after dropping the line.
      cleanup = null;
    };

    casks = [
      "font-monaspice-nerd-font"
      "fork"
      "gcloud-cli"
      "kitty"
      "maccy"
      "orbstack"
    ];
  };
}
