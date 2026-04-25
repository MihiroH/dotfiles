{ ... }:

{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      # Uninstall casks that are present in brew but no longer declared
      # below. Set to "zap" to also wipe app support data; leaving as
      # "uninstall" so removing a line drops the cask but keeps user
      # state if reinstalled later.
      cleanup = "uninstall";
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
