{...}: let
  # Bun config shared by both paths below so the cooldown text lives in one place.
  bunfig = ''
    [install]
    # Only install package versions published at least 3 days ago (supply-chain
    # cooldown). Bun measures minimumReleaseAge in SECONDS — 3 days = 259200.
    # (npm's .npmrc min-release-age is in days; pnpm's is in minutes — units differ.)
    minimumReleaseAge = 259200

    # Trusted packages exempt from the cooldown — e.g. codex, run via `bunx
    # @openai/codex`, where we want the latest bugfixes immediately.
    minimumReleaseAgeExcludes = ["@openai/codex"]
  '';
in {
  # XDG Base Directory Specification — shared across bash, zsh, and fish.
  # Home Manager writes these into hm-session-vars.sh (bash/zsh) and emits
  # `set -gx` equivalents for fish.
  home.sessionVariables = {
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_CACHE_HOME = "$HOME/.cache";
  };

  # Provide shims for consumers that declare global mise tools.
  home.sessionPath = ["$HOME/.local/share/mise/shims"];

  home.file.".npmrc".text = ''
    min-release-age=3
    ignore-scripts=true
    save-exact=true
  '';

  # Bun reads $XDG_CONFIG_HOME/.bunfig.toml when XDG_CONFIG_HOME is set, so write both paths.
  home.file.".bunfig.toml".text = bunfig;

  xdg.configFile = {
    ".bunfig.toml".text = bunfig;

    # uv — exclude packages newer than 3 days
    "uv/uv.toml".text = ''
      exclude-newer = "3 days"
    '';
  };
}
