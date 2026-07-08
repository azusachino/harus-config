# users/haru/home.nix — shared base aggregator.
# Exported by the flake as homeManagerModules.default. Machine + identity
# specifics are supplied by the consumer; only `username` comes in as a
# specialArg (nix-index-database / sops-nix modules are wired in the flake).
{
  pkgs,
  username,
  ...
}: {
  imports = [
    ../../modules/identity.nix
    ./packages.nix
    ./git.nix
    ./ssh.nix
    ./bash.nix
    ./zsh.nix
    ./fish.nix
    ./starship.nix
    ./xdg.nix
    ./tmux.nix
    ./direnv.nix
    ./gh.nix
    ./claude.nix
    ./gemini.nix
    ./neovim.nix
    ./sops.nix
    ./lazygit.nix
    ./yazi.nix
  ];

  home.username = username;
  home.homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${username}"
    else "/home/${username}";

  home.stateVersion = "24.11";

  news.display = "silent";

  programs.home-manager.enable = true;
  programs.mise = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };
  programs.fzf.enable = true;
  programs.nix-index.enable = true;
  programs.atuin = {
    enable = true;
    flags = ["--disable-up-arrow"]; # keep fish's default up-arrow, use ctrl+r for atuin
  };
}
