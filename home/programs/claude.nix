{ config, dotfilesPath, ... }:

{
  # ~/.claude/ holds Claude Code's global config, skills, and the
  # statusline script. claude CLI may write to settings.json (e.g. when
  # adding MCP servers or hooks), so we mkOutOfStoreSymlink each entry
  # to the repo path rather than putting them in the readonly nix store.
  # The claude binary itself is installed via the official curl
  # installer and lives under ~/.local/bin/.
  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/claude/CLAUDE.md";

  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/claude/settings.json";

  home.file.".claude/skills".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/claude/skills";

  home.file.".claude/statusline-command.sh".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/claude/statusline-command.sh";
}
