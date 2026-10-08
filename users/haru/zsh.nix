{lib, ...}: {
  # Minimal zsh config — primarily ensures hm-session-vars.sh (XDG vars,
  # sessionVariables) is sourced. mise activation is injected automatically via
  # programs.mise.enableZshIntegration.
  programs.zsh = {
    enable = true;
    envExtra = ''
      # Also enforce managed binary priority in noninteractive shells.
      export PATH="$HOME/.local/share/mise/shims:$HOME/.nix-profile/bin:$PATH"
    '';
    initContent = lib.mkAfter ''
      if command -v zoxide >/dev/null 2>&1; then
        eval "$(zoxide init zsh)"
      fi
      if command -v atuin >/dev/null 2>&1; then
        eval "$(atuin init zsh --disable-up-arrow)"
      fi
    '';
  };
}
