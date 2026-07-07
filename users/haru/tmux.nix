{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    terminal = "tmux-256color";
    shortcut = "a"; # Prefix is now Ctrl-a (easier than Ctrl-b)

    mouse = true;
    escapeTime = 0;
    baseIndex = 1;
    keyMode = "vi";

    plugins = with pkgs.tmuxPlugins; [
      sensible
      pain-control
      yank
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_window_tabs_enabled on
          set -g @catppuccin_date_time "%H:%M"
        '';
      }
      {
        plugin = resurrect;
        extraConfig = "set -g @resurrect-capture-pane-contents 'on'";
      }
      {
        plugin = continuum;
        extraConfig = "set -g @continuum-restore 'on'";
      }
    ];

    extraConfig = ''
      # True color support
      set -as terminal-features ",*:RGB"

      # Pane index matches window index
      set -g pane-base-index 1

      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"

      # Vim-style pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Resize panes with H, J, K, L
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Intuitive splits
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Switch windows with prefix + n/p or prefix + number
      bind -r n next-window
      bind -r p previous-window

      # Auto-rename windows based on current directory
      set -g automatic-rename on
      set -g automatic-rename-format '#{b:pane_current_path}'

      # Broadcast keybind — toggle sending input to all panes
      bind B set-window-option synchronize-panes \; display "Sync #{?synchronize-panes,ON,OFF}"

      # Renumber windows when one is closed
      set -g renumber-windows on

      # Increase history limit
      set -g history-limit 50000

      # Pass through escape sequences to outer terminal (enables Claude Code
      # notifications, progress bars, and OSC sequences in iTerm2/Ghostty/Kitty)
      set -g allow-passthrough on
    '';
  };
}
