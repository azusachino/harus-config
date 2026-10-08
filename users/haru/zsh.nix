{lib, ...}: {
  # Minimal zsh config — primarily ensures hm-session-vars.sh (XDG vars,
  # sessionVariables) is sourced. mise activation is injected automatically via
  # programs.mise.enableZshIntegration.
  programs.zsh = {
    enable = true;
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
