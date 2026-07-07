{...}: {
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    shellWrapperName = "y";

    settings = {
      mgr = {
        show_hidden = true;
        show_symlink = true;
        sort_by = "mtime";
        sort_dir_first = true;
        sort_reverse = true;
        sort_sensitive = false;
        linemode = "size";
        ratio = [1 2 5];
        scrolloff = 5;
      };
      preview = {
        max_width = 1000;
        max_height = 1000;
        image_filter = "lanczos3";
        image_quality = 80;
      };
    };

    keymap = {
      manager.prepend_keymap = [
        {
          on = [
            "g"
            "h"
          ];
          run = "cd ~";
          desc = "Go home";
        }
        {
          on = [
            "g"
            "p"
          ];
          run = "cd ~/Projects";
          desc = "Go to Projects";
        }
        {
          on = [
            "g"
            "w"
          ];
          run = "cd ~/Working";
          desc = "Go to Working";
        }
        {
          on = [
            "g"
            "d"
          ];
          run = "cd ~/Downloads";
          desc = "Go to Downloads";
        }
        {
          on = [
            "g"
            "c"
          ];
          run = "cd ~/.config";
          desc = "Go to config";
        }
      ];
    };
  };
}
