{pkgs, ...}: {
  programs.helix = {
    enable = true;

    # LSP servers and formatters provided as system binaries (parity with neovim.nix).
    extraPackages = with pkgs; [
      nil # Nix
      lua-language-server # Lua
      bash-language-server # Shell
      gopls # Go
      rust-analyzer # Rust
      pyright # Python
      stylua # Lua formatter
      alejandra # Nix formatter
      shfmt # Shell formatter
      ruff # Python formatter
      prettier # JS/TS/JSON/YAML/Markdown formatter
    ];

    # ── config.toml ──────────────────────────────────────────────────────────
    settings = {
      theme = "catppuccin_mocha";

      editor = {
        line-number = "relative";
        cursorline = true;
        color-modes = true;
        true-color = true;
        bufferline = "multiple";
        rulers = [100];
        text-width = 100;
        completion-replace = true;
        end-of-line-diagnostics = "hint";

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        file-picker.hidden = false;

        statusline = {
          left = ["mode" "spinner" "version-control" "file-name"];
          right = ["diagnostics" "selections" "position" "file-encoding" "file-type"];
        };

        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };

        indent-guides = {
          render = true;
          character = "▏";
        };

        soft-wrap.enable = true;

        inline-diagnostics = {
          cursor-line = "error";
          other-lines = "disable";
        };

        gutters.layout = ["diagnostics" "spacer" "line-numbers" "spacer" "diff"];
      };
    };

    # ── languages.toml ───────────────────────────────────────────────────────
    languages = {
      # Pin rust-analyzer to the Nix binary; ~/.nix-profile/bin/rust-analyzer is
      # the rustup proxy, which recurses when the component is not installed.
      language-server.rust-analyzer.command = "${pkgs.rust-analyzer}/bin/rust-analyzer";

      language = [
        {
          name = "nix";
          auto-format = true;
          formatter = {
            command = "alejandra";
            args = ["-q" "-"];
          };
          language-servers = ["nil"];
        }
        {
          name = "lua";
          auto-format = true;
          formatter = {
            command = "stylua";
            args = ["-"];
          };
          language-servers = ["lua-language-server"];
        }
        {
          name = "bash";
          auto-format = true;
          formatter = {
            command = "shfmt";
            args = ["-i" "2" "-"];
          };
          language-servers = ["bash-language-server"];
        }
        {
          name = "go";
          auto-format = true;
          language-servers = ["gopls"];
        }
        {
          name = "rust";
          auto-format = true;
          language-servers = ["rust-analyzer"];
        }
        {
          name = "python";
          auto-format = true;
          formatter = {
            command = "ruff";
            args = ["format" "-"];
          };
          language-servers = ["pyright"];
        }
        {
          name = "json";
          auto-format = true;
          formatter = {
            command = "prettier";
            args = ["--parser" "json"];
          };
        }
        {
          name = "yaml";
          auto-format = true;
          formatter = {
            command = "prettier";
            args = ["--parser" "yaml"];
          };
        }
        {
          name = "markdown";
          auto-format = true;
          formatter = {
            command = "prettier";
            args = ["--parser" "markdown"];
          };
        }
        {
          name = "typescript";
          auto-format = true;
          formatter = {
            command = "prettier";
            args = ["--parser" "typescript"];
          };
        }
        {
          name = "javascript";
          auto-format = true;
          formatter = {
            command = "prettier";
            args = ["--parser" "babel"];
          };
        }
      ];
    };
  };
}
