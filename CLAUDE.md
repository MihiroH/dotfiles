# CLAUDE.md

Guidance for Claude Code (claude.ai/code) working in this repository.

## Repository overview

Declarative macOS dotfiles. The whole environment — shell, editor, terminals, fonts, GUI apps, language runtimes, GPG agent, Tailscale — is described by a Nix flake and applied with `nix-darwin` + `home-manager`. One `darwin-rebuild switch` is the only command needed to converge to the declared state.

## Build / verify / activate

```bash
# Type-check and option-name validate without building artifacts
nix flake check

# Evaluate and build the closure into ./result without activating
darwin-rebuild build --flake .#mihiro-mac

# Activate (requires sudo because it reloads launchd daemons and writes /etc)
sudo darwin-rebuild switch --flake .#mihiro-mac

# Roll back
darwin-rebuild --list-generations
sudo darwin-rebuild switch --flake .#mihiro-mac~1
```

`darwin-rebuild` is preferred over `nix run nix-darwin -- ...`; the latter hits the unauthenticated GitHub API.

## Architecture

```
flake.nix                    # inputs: nixpkgs (unstable), nix-darwin, home-manager
└── lib/mkHost.nix           # darwinSystem factory; passes inputs/hostName/system/username/dotfilesPath as specialArgs
    ├── darwin/              # system-level (root)
    │   ├── default.nix      # imports + networking.hostName + nixpkgs config
    │   ├── nix.nix          # experimental-features, gc, trusted-users
    │   ├── system.nix       # system.stateVersion, primaryUser
    │   ├── users.nix        # users.users.<name>, login shell
    │   ├── homebrew.nix     # casks + brews + cleanup="uninstall"
    │   ├── fonts.nix        # fonts.packages
    │   └── tailscale.nix    # services.tailscale.enable
    │
    └── home/                # user-level (home-manager via darwin module)
        ├── default.nix
        ├── packages.nix     # CLI tools as home.packages
        ├── runtimes.nix     # node / python / go / rust / java / etc.
        └── programs/        # programs.<tool> wrappers
            ├── zsh.nix      # initContent + sessionVariables + shellAliases
            ├── git.nix      # settings + aliases + includes + ignores
            ├── tmux.nix
            ├── neovim.nix   # mkOutOfStoreSymlink to ../../nvim
            ├── kitty.nix    # mkOutOfStoreSymlink to ../../kitty
            ├── karabiner.nix
            ├── ghostty.nix
            ├── claude.nix
            ├── iterm2.nix   # defaults import + killall cfprefsd
            ├── fzf.nix
            ├── gh.nix
            └── gpg.nix
```

### `mkOutOfStoreSymlink`

Several home-manager modules use `config.lib.file.mkOutOfStoreSymlink` to point `~/.config/<tool>` directly at the repo path (`dotfilesPath` specialArg from `lib/mkHost.nix`) rather than into the read-only `/nix/store`. Required for tools that write back into their config:

- `nvim/lazy-lock.json` — updated by `:Lazy sync`.
- `karabiner/karabiner.json` — Karabiner-Elements GUI rewrites this.
- `kitty/`, `cmux/ghostty/`, `claude/` — convenience so direct edits don't need a `darwin-rebuild`.

Editing the file in the repo path is the same as editing the file at the symlink target.

### Boundaries

- **Nix CLI tools** → `home/packages.nix`.
- **Language runtimes** → `home/runtimes.nix`.
- **Per-tool config that maps to a `programs.<tool>` module** → `home/programs/<tool>.nix`.
- **System-level** (launchd daemons, system fonts, brew casks, macOS defaults) → `darwin/`.
- **Brew** is reserved for things nix cannot replace cleanly (currently: `phantom` formula, `fork`/`orbstack` casks).
- **Secrets** (API tokens, work GCP credentials) live in `~/.secrets.zsh` (git-ignored), sourced from `programs.zsh.initContent`.

## Common changes

### Add a CLI tool

Edit `home/packages.nix`, append the nixpkgs attribute name, run `darwin-rebuild switch`.

### Add a `programs.<tool>` module

Create `home/programs/<tool>.nix` with `programs.<tool>.enable = true` and tool-specific options, then add the module to the `imports` list in `home/default.nix`.

### Add or remove a brew cask

Edit the `casks` list in `darwin/homebrew.nix`. Removing a line auto-uninstalls (`cleanup = "uninstall"`).

### Modify zsh behavior

Edit `home/programs/zsh.nix`:
- Environment variables → `sessionVariables`
- One-line aliases → `shellAliases`
- Functions, widgets, bindkeys, sourcing → `initContent`

### Bump pinned packages

```bash
nix flake update                # update all inputs
nix flake update <input-name>   # update one
sudo darwin-rebuild switch --flake .#mihiro-mac
```

## Caveats

- **macOS App Management permission**: first activation touching `~/Applications/Home Manager Apps/` requires the active terminal to be granted "App Management" in System Settings → Privacy & Security.
- **Karabiner**: needs Full Disk Access on `karabiner_grabber` and `karabiner_observer` (System Settings → Privacy & Security).
- **iTerm2 plist**: `home/programs/iterm2.nix` runs `defaults import` and `killall cfprefsd` so the imported plist actually takes effect; running iTerm2 windows may need to be relaunched.
- **`phantom` shebang**: the binary's `#!/opt/homebrew/opt/node/bin/node` shebang gets patched in place to `#!/usr/bin/env node` so it can use the nix-managed Node. `brew reinstall phantom` would reset the patch.
