{ lib, ... }:

let
  plistPath = ./../../iterm/com.googlecode.iterm2.plist;
in
{
  # iTerm2 stores its preferences in
  # ~/Library/Preferences/com.googlecode.iterm2.plist, but cfprefsd
  # caches that file in memory and rewrites it on quit, so a plain
  # symlink or `cp` is overwritten. Use `defaults import` to push the
  # repo plist into cfprefsd, then kill the daemon so the next read
  # picks up the new values.
  #
  # Trade-off: every activation re-imports, so any iTerm2 preference
  # changes made through the GUI must be exported back into the repo
  # plist before the next switch or they will be lost.
  home.activation.iterm2ImportPlist =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -f ${plistPath} ]; then
        /usr/bin/defaults import com.googlecode.iterm2 ${plistPath}
        /usr/bin/killall cfprefsd 2>/dev/null || true
      fi
    '';
}
