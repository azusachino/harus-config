{
  pkgs,
  lib,
  ...
}: {
  # XDG Base Directory Specification — shared across bash, zsh, and fish.
  # Home Manager writes these into hm-session-vars.sh (bash/zsh) and emits
  # `set -gx` equivalents for fish.
  home.sessionVariables = {
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_CACHE_HOME = "$HOME/.cache";
  };

  home.file.".npmrc".source = ../config/npmrc;
  home.file.".bunfig.toml".source = ../config/bun/bunfig.toml;

  xdg.configFile = lib.mkMerge [
    {
      # mise global config — all haru machines
      "mise/config.toml".source = ../config/mise/config.toml;

      # uv — exclude packages newer than 7 days
      "uv/uv.toml".source = ../config/uv/uv.toml;

      # glow — markdown renderer (width 0 = follow terminal, no early wrap)
      "glow/glow.yml".source = ../config/glow/glow.yml;
    }
    (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      # Ghostty terminal — macOS only
      "ghostty/config".source = ../config/ghostty;
    })
  ];
}
