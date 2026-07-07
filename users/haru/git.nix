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
    };
  };
}
