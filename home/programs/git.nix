{ ... }:

{
  programs.git = {
    enable = true;

    lfs.enable = true;

    settings = {
      user = {
        name = "MihiroH";
        email = "mihiro.hashimoto.1125@gmail.com";

        # Custom user.mail field used by some downstream tooling.
        mail = "mihiro.hashimoto.1125@gmail.com";
      };

      core = {
        excludesFile = "~/.config/git/ignore";
        editor = "nvim";
      };

      ghq.root = "~/Documents";

      commit.template = "~/.stCommitMsg";

      http.postBuffer = 1048576000;

      push = {
        default = "current";
        autoSetupRemote = true;
      };

      pull.rebase = false;

      phantom.ai = "claude";

      alias = {
        b = "branch";
        c = "commit";
        cm = "commit -m";
        f = "fetch";
        s = "status";
        st = "stash";
        rh = "reset --hard";

        co = ''!f() { args=$@; if [ -z "$args" ]; then branch=$(git branch --all | grep -v HEAD | fzf --preview 'echo {} | cut -c 3- | xargs git log --color=always' | cut -c 3-); git checkout $(echo $branch | sed 's#remotes/[^/]*/##'); else git checkout $args; fi }; f'';

        reb = ''!f() { args=$@; if [ -z "$args" ]; then branch=$(git branch --all | grep -v HEAD | fzf --preview 'echo {} | cut -c 3- | xargs git log --color=always' | cut -c 3-); git rebase $(echo $branch | sed 's#remotes/[^/]*/##'); fi }; f'';

        mer = ''!f() { args=$@; if [ -z "$args" ]; then branch=$(git branch --all | grep -v HEAD | fzf --preview 'echo {} | cut -c 3- | xargs git log --color=always' | cut -c 3-); git merge $(echo $branch | sed 's#remotes/[^/]*/##'); fi }; f'';

        d = ''!f() { args=$@; [ -z "$args" ] && args=HEAD; ([ "$args" = "HEAD" ] && git status --short || git diff --name-status $args | sed 's/\t/  /') | fzf --preview "echo {} | cut -c 4- | xargs git diff --color=always $args --" --multi --height 90% | cut -c 4-; }; f'';

        stl = ''!git stash list | fzf --preview 'echo {} | cut -d":" -f1 | xargs git stash show -p --color=always' --height 90% | cut -d':' -f1'';

        stp = "!git stl | xargs git stash pop";
        std = "!git stl | xargs git stash drop";

        "delete-merged-branch" = ''!f() { git fetch -p; for branch in $(git branch -vv | grep ": gone]" | awk '{print $1}'); do git branch -D "$branch"; done; }; f'';

        parent = ''!git show-branch | grep '*' | grep -v "$(git rev-parse --abbrev-ref HEAD)" | head -n1 | sed 's/.*\[\(.*\)\].*/\1/' | sed 's/[\^~].*//' #'';
      };
    };

    includes = [
      {
        condition = "gitdir:~/Documents/personal/";
        path = "~/.gitconfig-personal";
      }
    ];
  };
}
