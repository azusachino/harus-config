{...}: {
  # Minimal zsh config — primarily ensures hm-session-vars.sh (XDG vars,
  # sessionVariables) is sourced. mise activation is injected automatically via
  # programs.mise.enableZshIntegration.
  programs.zsh = {
    enable = true;
  };
}
