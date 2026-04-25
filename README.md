# Dotfiles

[![macOS](https://img.shields.io/badge/macOS-aarch64-blue.svg)](https://www.apple.com/macos/)
[![Nix](https://img.shields.io/badge/Nix-flakes-5277C3.svg)](https://nixos.wiki/wiki/Flakes)
[![nix-darwin](https://img.shields.io/badge/nix--darwin-managed-success.svg)](https://github.com/LnL7/nix-darwin)
[![home-manager](https://img.shields.io/badge/home--manager-managed-success.svg)](https://github.com/nix-community/home-manager)

Declarative macOS dotfiles managed with [Nix flakes](https://nixos.wiki/wiki/Flakes), [nix-darwin](https://github.com/LnL7/nix-darwin) and [home-manager](https://github.com/nix-community/home-manager). One `darwin-rebuild switch` rebuilds the system: shell, editor, terminals, fonts, GUI apps, language runtimes, GPG agent, Tailscale, all at once and pinned by `flake.lock`.

## Quick start (fresh Mac)

```bash
# 1. Install nix (Determinate Systems installer recommended)
curl -fsSL https://install.determinate.systems/nix | sh -s -- install

# 2. Clone this repo to a stable path
git clone git@github.com:MihiroH/dotfiles.git ~/Documents/personal/dotfiles
cd ~/Documents/personal/dotfiles

# 3. First-time activation. The flake input pin lives in flake.lock so the
#    initial run does not need a GitHub round-trip.
sudo nix --extra-experimental-features 'nix-command flakes' \
  run nix-darwin -- switch --flake .#mihiro-mac

# 4. After step 3 darwin-rebuild lives on PATH; subsequent rebuilds:
sudo darwin-rebuild switch --flake .#mihiro-mac
```

The host configuration is `darwinConfigurations."mihiro-mac"` (Apple Silicon). To target a different machine, copy that block in `flake.nix` and add a new entry to `lib/mkHost.nix`.

## Repository layout

```
dotfiles/
├── flake.nix              # inputs (nixpkgs, nix-darwin, home-manager) + outputs
├── flake.lock
├── lib/
│   └── mkHost.nix         # darwinSystem factory; passes specialArgs (incl. dotfilesPath)
│
├── darwin/                # nix-darwin (system-level, root-managed)
│   ├── default.nix        # imports the rest, sets hostName + nixpkgs.hostPlatform
│   ├── nix.nix            # experimental-features, gc, trusted-users
│   ├── system.nix         # system.stateVersion, primaryUser, defaults
│   ├── users.nix          # users.users.<name>, login shell
│   ├── homebrew.nix       # cask + brew formula declarations
│   ├── fonts.nix          # fonts.packages (Nerd Fonts)
│   └── tailscale.nix      # services.tailscale.enable
│
├── home/                  # home-manager (user-level)
│   ├── default.nix        # imports + home.{username,homeDirectory,stateVersion}
│   ├── packages.nix       # CLI tools as home.packages
│   ├── runtimes.nix       # node / python / go / rust / java / etc.
│   └── programs/
│       ├── zsh.nix        # programs.zsh + initContent
│       ├── git.nix        # programs.git (settings, aliases, includes, ignores)
│       ├── tmux.nix       # tmux + xdg.configFile."tmux/tmux.conf"
│       ├── neovim.nix     # programs.neovim + mkOutOfStoreSymlink to ../../nvim
│       ├── kitty.nix      # mkOutOfStoreSymlink to ../../kitty
│       ├── karabiner.nix  # mkOutOfStoreSymlink to ../../karabiner
│       ├── ghostty.nix    # mkOutOfStoreSymlink to ../../cmux/ghostty
│       ├── claude.nix     # ~/.claude/* mkOutOfStoreSymlink
│       ├── iterm2.nix     # defaults import + killall cfprefsd
│       ├── fzf.nix        # programs.fzf + everforest palette
│       ├── gh.nix         # programs.gh
│       └── gpg.nix        # ~/.gnupg/gpg-agent.conf with pinentry_mac
│
├── nvim/                  # init.lua + lua/ (managed by lazy.nvim, repo-writable)
├── kitty/                 # kitty.conf, kitty.d/, kitty-themes/, ...
├── karabiner/karabiner.json
├── claude/                # CLAUDE.md, settings.json, skills/, statusline-command.sh
├── cmux/                  # ghostty/config, settings.json
├── tmux/tmux.conf
└── iterm/com.googlecode.iterm2.plist
```

The `mkOutOfStoreSymlink` modules point at the repo path (`/Users/<user>/Documents/personal/dotfiles/...`) so tools that write back to their config (lazy.nvim's `lazy-lock.json`, Karabiner-Elements GUI) keep working — the file edited is the file in the repo.

## What the flake manages today

| Layer | Source |
|---|---|
| **Nix CLI tools** | `home/packages.nix` — fd, fzf, gh, ghq, jq, lua, prettierd, ripgrep, tree, tree-sitter, asciinema, asciinema-agg, pstree, gnupg, google-cloud-sdk, kitty, maccy |
| **Language runtimes** | `home/runtimes.nix` — Node 24, Python 3.13, Go, Rust (cargo+rustc+rustfmt), Bun, OpenJDK 21 LTS, awscli2, ffmpeg, firebase-tools, pnpm, uv, yarn-berry |
| **System fonts** | `darwin/fonts.nix` — `nerd-fonts.monaspace` |
| **Tailscale** | `darwin/tailscale.nix` — `services.tailscale.enable = true` (CLI + tailscaled launchd daemon) |
| **Brew casks** | `darwin/homebrew.nix` — `fork`, `orbstack` (apps that need privileged installers) |
| **Brew formulae** | `darwin/homebrew.nix` — `phantom` only (cmux completion CLI with hard-coded shebang) |
| **iTerm2 plist** | `home/programs/iterm2.nix` — `defaults import` + `killall cfprefsd` activation |

`homebrew.onActivation.cleanup = "uninstall"`: anything brew has installed that is not in `brews` / `casks` is removed on the next `darwin-rebuild switch`.

## Common tasks

### Update an upstream package

```bash
# Update a specific input (or omit the arg to update all)
nix flake update home-manager
sudo darwin-rebuild switch --flake .#mihiro-mac
```

### Add a CLI

Edit `home/packages.nix`, append the attribute name, then `darwin-rebuild switch`.

### Add a brew cask

Edit the `casks = [ ... ]` list in `darwin/homebrew.nix`. Removing a line uninstalls the cask (because of `cleanup = "uninstall"`).

### Verify a build without activating

```bash
nix flake check
darwin-rebuild build --flake .#mihiro-mac
```

`nix flake check` runs in seconds and catches option-name typos. `darwin-rebuild build` actually builds the closure into `./result/`.

### Roll back

`darwin-rebuild` keeps the last few generations:

```bash
darwin-rebuild --list-generations
sudo darwin-rebuild switch --flake .#mihiro-mac~1   # previous generation
```

## Secrets

Tokens and per-host work credentials live in `~/.secrets.zsh` (git-ignored, sourced from the end of `programs.zsh.initContent`). Example:

```sh
# ~/.secrets.zsh
if [ -f ~/.config/tavily/apps.json ]; then
    export TAVILY_API_KEY=$(jq -r '."api_key"' ~/.config/tavily/apps.json 2>/dev/null)
fi

export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.config/gcloud/legacy_credentials/<work-email>/adc.json"
```

## Caveats

- **`nix run nix-darwin -- ...`** hits the unauthenticated GitHub API (60 req/h) and may fall back to the cached version with a 403 warning. Use `darwin-rebuild` directly once it is on PATH; it reads `flake.lock` instead.
- **macOS App Management permission**: the first activation that touches `~/Applications/Home Manager Apps/` (kitty / Maccy via nix) requires you to grant the active terminal "App Management" in System Settings → Privacy & Security.
- **Tailscale state**: `services.tailscale.enable` keeps the auth state at `/Library/Tailscale/tailscaled.state`. Migrating from the brew formula adopts that path automatically — no re-login required.
- **`phantom` shebang**: the cmux completion CLI installs with `#!/opt/homebrew/opt/node/bin/node` hard-coded. After moving Node to nix the binary is patched in place to `#!/usr/bin/env node`. Re-running `brew reinstall phantom` would reset that patch.

## License

MIT.
