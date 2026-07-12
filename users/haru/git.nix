{config, ...}: {
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true; # n/N to jump between diff sections
      side-by-side = true;
      line-numbers = true;
      dark = true;
    };
  };

  programs.git = {
    enable = true;
    signing.format = null;

    # Identity comes from the harus.identity option (see modules/identity.nix);
    # consumers override it per-machine (e.g. a work machine).
    settings = {
      user.name = config.harus.identity.name;
      user.email = config.harus.identity.email;
      core.editor = "nvim";
      core.autocrlf = "input";
      format.signOff = true;
      pull.rebase = false;
      push.autoSetupRemote = true;
      fetch.prune = true;
      rebase.autostash = true;
      init.defaultBranch = "main";
      merge.conflictStyle = "diff3";
      transfer.fsckobjects = true;
      status.showStash = true;
      branch.sort = "-committerdate";
      rerere.enabled = true; # reuse recorded conflict resolutions
      diff.algorithm = "histogram"; # clearer diffs than the default myers
      commit.verbose = true; # show the diff in the commit message editor
      column.ui = "auto"; # columnar output for branch/status listings
      help.autocorrect = "prompt"; # offer the intended command on a typo

      # difftastic (difft) as an on-demand structural diff via `git dft`.
      # delta stays the default pager for `git diff`/`git show`; this only
      # affects `git difftool`.
      difftool.difftastic.cmd = ''difft "$LOCAL" "$REMOTE"'';
      difftool.prompt = false;
    };

    settings.alias = {
      co = "checkout";
      sc = "switch -c";
      p = "push";
      fp = "!git fetch -v --prune && git pull -v";
      st = "status -sb";
      lg = "log --oneline --graph --decorate -20";
      undo = "reset --soft HEAD~1";
      ac = ''!f() { git add -A && git commit "$@"; }; f''; # git ac -m "msg"
      dft = "difftool --tool=difftastic"; # structural diff (difft)
    };
  };
}
