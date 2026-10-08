{...}: {
  # XDG Base Directory Specification — shared across bash, zsh, and fish.
  # Home Manager writes these into hm-session-vars.sh (bash/zsh) and emits
  # `set -gx` equivalents for fish.
  home.sessionVariables = {
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_CACHE_HOME = "$HOME/.cache";
  };

  # Shims also cover noninteractive shells and Git pager invocations.
  # Run mise install && mise reshim after activation; project locks are optional.
  home.sessionPath = ["$HOME/.local/share/mise/shims"];

  home.file.".npmrc".text = ''
    min-release-age=7
    ignore-scripts=true
    save-exact=true
  '';

  home.file.".bunfig.toml".text = ''
    [install]
    # Only install package versions published at least 7 days ago (supply-chain
    # cooldown). Bun measures minimumReleaseAge in SECONDS — 7 days = 604800.
    # (npm's .npmrc min-release-age is in days; pnpm's is in minutes — units differ.)
    minimumReleaseAge = 604800

    # Trusted packages exempt from the cooldown — e.g. codex, run via `bunx
    # @openai/codex`, where we want the latest bugfixes immediately.
    minimumReleaseAgeExcludes = ["@openai/codex"]
  '';

  xdg.configFile = {
    # Reviewed global CLI pins and platform artifact digests travel together.
    "mise" = {
      source = ./mise;
      recursive = true; # both symlink targets share one store directory/lock root
    };

    "bat/config".text = ''
      --theme=TwoDark
      --style=changes,header
    '';
    "atuin/config.toml".text = ''
      # Enter puts history into the prompt for review instead of executing it.
      enter_accept = false
      inline_height = 20
      style = "compact"
      show_preview = true
      keymap_mode = "auto"
    '';

    # uv — exclude packages newer than 7 days
    "uv/uv.toml".text = ''
      exclude-newer = "7 days"
    '';
  };
}
