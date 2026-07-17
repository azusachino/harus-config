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
    # mise global config — all haru machines
    "mise/config.toml".text = ''
      # Global mise config — settings only.
      #
      # Language runtime *defaults* now come from nix (users/haru/runtimes.nix).
      # mise is for per-project version pinning: drop a .mise.toml in a repo to
      # override the nix default (e.g. java = "corretto-21", node = "20.11.1",
      # zig = "0.16"). rust is managed by rustup (not nix/mise).
      [settings]
      trusted_config_paths = ["~/Projects", "~/Working"]
    '';

    # uv — exclude packages newer than 7 days
    "uv/uv.toml".text = ''
      exclude-newer = "7 days"
    '';
  };
}
