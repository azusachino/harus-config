{...}: {
  programs.gh = {
    enable = true;

    # Only config.yml is managed — hosts.yml (auth tokens) is untouched
    settings = {
      version = 1;
      git_protocol = "https";
      prompt = "enabled";
      spinner = "enabled";
      aliases = {
        co = "pr checkout";
      };
    };
  };
}
