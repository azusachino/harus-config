{
  pkgs,
  lib,
  ...
}: {
  # Minimal bash config — used by agents (Claude Code hooks, etc.), not interactive shells.
  # mise activation is injected automatically via programs.mise.enableBashIntegration.
  programs.bash = {
    enable = true;

    profileExtra = ''
      # Nix profile
      export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"

      ${lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
        export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
      ''}

      # Managed shims/bootstrap win over older manual installations.
      export PATH="$HOME/.local/share/mise/shims:$HOME/.nix-profile/bin:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/go/bin:$PATH"
    '';
  };
}
