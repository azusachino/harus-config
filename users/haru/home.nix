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
  programs.nix-index.enable = true;

  programs.atuin = {
    enable = true;
    flags = ["--disable-up-arrow"]; # keep fish's default up-arrow, use ctrl+r for atuin
    settings = {
      # Enter places the highlighted command into the prompt for review instead
      # of executing it immediately; press Enter again to run it. Tab does the
      # same. Prevents accidental execution of the wrong history entry.
      enter_accept = false;
      inline_height = 20; # keep the search UI inline rather than clearing the screen
      style = "compact";
      show_preview = true; # full command preview for the highlighted entry
      keymap_mode = "auto"; # pick vim/emacs keymap from the shell's current keymap
    };
  };

  # fzf wired to fd (respects .gitignore but includes hidden files) with
  # bat/eza previews for the Ctrl-T (files) and Alt-C (directories) widgets.
  # fd/bat/eza all ship from packages.nix.
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
    changeDirWidgetOptions = ["--preview 'eza --tree --color=always {} | head -100'"];
  };

  # bat defaults; also applies anywhere bat acts as a pager (e.g. fzf Ctrl-T preview).
  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark"; # built-in dark theme (no external theme file needed)
      style = "changes,header";
    };
  };
}
