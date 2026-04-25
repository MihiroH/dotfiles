{ pkgs, ... }:

{
  # Replaces the brew formula `tailscale` (CLI + tailscaled daemon).
  # The brew formula registered tailscaled as a launchd daemon under
  # /Library/LaunchDaemons/homebrew.mxcl.tailscale.plist with state at
  # /opt/homebrew/var/lib/tailscale/. The migration moves both the CLI
  # and the daemon into the nix store and the daemon's state file to
  # the FHS-standard /var/lib/tailscale/.

  environment.systemPackages = [ pkgs.tailscale ];

  launchd.daemons.tailscaled = {
    serviceConfig = {
      Label = "com.tailscale.tailscaled";
      ProgramArguments = [
        "${pkgs.tailscale}/bin/tailscaled"
        "--state=/var/lib/tailscale/tailscaled.state"
        "--socket=/var/run/tailscaled.socket"
        "--port=41641"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardErrorPath = "/var/log/tailscaled.log";
      StandardOutPath = "/var/log/tailscaled.log";
    };
  };
}
