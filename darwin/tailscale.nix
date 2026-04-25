{ pkgs, ... }:

{
  # Replaces the brew formula `tailscale` (CLI + tailscaled daemon).
  # brew installed tailscaled with no flags, relying on the macOS-default
  # state path /Library/Tailscale/tailscaled.state. Reusing that exact
  # path here lets the new nix daemon adopt the existing tailnet auth
  # state without re-login.

  environment.systemPackages = [ pkgs.tailscale ];

  launchd.daemons.tailscaled = {
    serviceConfig = {
      Label = "com.tailscale.tailscaled";
      ProgramArguments = [
        "${pkgs.tailscale}/bin/tailscaled"
        "--state=/Library/Tailscale/tailscaled.state"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardErrorPath = "/var/log/tailscaled.log";
      StandardOutPath = "/var/log/tailscaled.log";
    };
  };
}
