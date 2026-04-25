{ ... }:

{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      # cleanup applies to both casks and brew formulae. Now that the
      # full set is declared explicitly below, "uninstall" is safe and
      # gives us idempotent activations: anything brew has installed
      # that is not in brews/casks gets removed on the next switch.
      cleanup = "uninstall";
    };

    brews = [
      # cmux's shell completion CLI. Cannot be moved to nix because the
      # binary ships with a hard-coded `#!/opt/homebrew/opt/node/bin/node`
      # shebang; until upstream supports `#!/usr/bin/env node` it stays
      # on brew.
      "phantom"
    ];

    casks = [
      "fork"
      "orbstack"
    ];
  };
}
