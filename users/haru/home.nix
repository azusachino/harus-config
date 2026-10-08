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
    ./xdg.nix
    ./direnv.nix
    ./gh.nix
    ./neovim.nix
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
  programs.nix-index.enable = true;

  # Shell/editor integrations and their dependencies remain Nix-owned.
  programs.atuin = {
    enable = true;
    flags = ["--disable-up-arrow"];
    settings = {
      enter_accept = false;
      inline_height = 20;
      style = "compact";
      show_preview = true;
      keymap_mode = "auto";
    };
  };
  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      style = "changes,header";
    };
  };
  programs.zoxide.enable = true;

  # fzf uses Nix fd/bat/Eza, independent of mise installation.
  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type f --hidden --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--border"
      "--layout=reverse"
    ];
    fileWidgetCommand = "fd --type f --hidden --exclude .git";
    fileWidgetOptions = ["--preview 'bat -n --color=always {}'"];
    changeDirWidgetCommand = "fd --type d --hidden --exclude .git";
    changeDirWidgetOptions = ["--preview 'eza -la --icons {} | head -100'"];
  };
}
