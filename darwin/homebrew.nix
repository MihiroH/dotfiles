{ ... }:

{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      # Applies to both casks and brews; with the full set declared
      # below it makes activation idempotent.
      cleanup = "uninstall";
    };

    brews = [
      # phantom ships with a hard-coded `#!/opt/homebrew/opt/node/bin/node`
      # shebang, so it can't be moved to nix without upstream changes.
      "phantom"
    ];

    casks = [
      "fork"
      "orbstack"
    ];
  };
}
