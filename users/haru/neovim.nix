{pkgs, ...}: let
  treesitterPlugin = pkgs.vimPlugins.nvim-treesitter;
  treesitterGrammars = [
    "bash"
    "css"
    "diff"
    "dockerfile"
    "fish"
    "gitcommit"
    "gitignore"
    "go"
    "gomod"
    "gosum"
    "gotmpl"
    "gowork"
    "html"
    "java"
    "javadoc"
    "javascript"
    "json"
    "lua"
    "luadoc"
    "markdown"
    "markdown_inline"
    "nix"
    "python"
    "query"
    "regex"
    "rust"
    "sql"
    "toml"
    "tsx"
    "typescript"
    "typst"
    "vim"
    "vimdoc"
    "yaml"
    "zig"
  ];
  treesitterGrammarPlugins =
    builtins.attrValues
    (pkgs.lib.getAttrs treesitterGrammars pkgs.vimPlugins.nvim-treesitter.grammarPlugins);
  treesitterGrammarSetLua = ''
    {
      ${pkgs.lib.concatMapStringsSep "\n      " (grammar: ''["${grammar}"] = true,'') treesitterGrammars}
    }
  '';
in {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withPython3 = false;
    withRuby = false;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    # lazy.nvim is Nix-pinned; Treesitter is wired through initLua below so
    # LazyVim configures the Nix-provided plugin and grammars.
    plugins = with pkgs.vimPlugins; [lazy-nvim];

    # LSP servers and formatters provided as system binaries
    extraPackages = with pkgs; [
      lua-language-server # Lua (neovim config)
      nil # Nix
      bash-language-server # Shell
      gopls # Go
      rust-analyzer # Rust
      pyright # Python
      stylua # Lua formatter
      tree-sitter # Satisfy nvim-treesitter check
      gcc # Satisfy nvim-treesitter C compiler check
    ];

    initLua = ''
      local function use_nix_treesitter()
        vim.opt.rtp:prepend("${treesitterPlugin}")
        vim.opt.rtp:prepend("${treesitterPlugin}/runtime")
        ${pkgs.lib.concatMapStringsSep "\n" (plugin: ''vim.opt.rtp:prepend("${plugin}")'') treesitterGrammarPlugins}
      end

      -- Bootstrap lazy.nvim from Nix store
      vim.opt.rtp:prepend("${pkgs.vimPlugins.lazy-nvim}")

      -- Provide nvim-treesitter and Nix-built grammars without runtime installs
      use_nix_treesitter()

      -- Bootstrap LazyVim
      require("config.lazy")

      -- lazy.nvim rebuilds runtimepath during setup, so restore parser/query paths.
      use_nix_treesitter()

      local nix_treesitter_grammars = ${treesitterGrammarSetLua}

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("nix_treesitter_highlights", { clear = true }),
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
          if not nix_treesitter_grammars[lang] then
            return
          end

          local lang_ok = pcall(vim.treesitter.language.add, lang)
          if lang_ok and vim.treesitter.query.get(lang, "highlights") then
            pcall(vim.treesitter.start, ev.buf, lang)
          end
        end,
      })
    '';
  };

  # ── Lua config files ──────────────────────────────────────────────────────

  xdg.configFile."nvim/lua/config/lazy.lua".text = ''
    -- Prevent lazy.nvim from crashing when trying to generate helptags in the read-only Nix store
    local orig_nvim_cmd = vim.api.nvim_cmd
    vim.api.nvim_cmd = function(cmd, opts)
      if type(cmd) == "table" and cmd.cmd == "helptags" and cmd.args and type(cmd.args[1]) == "string" and cmd.args[1]:match("/nix/store") then
        return ""
      end
      return orig_nvim_cmd(cmd, opts)
    end

    -- Note: We already prepended the Nix store path for lazy.nvim in init.lua

    require("lazy").setup({
      spec = {
        -- add LazyVim and import its plugins
        { "LazyVim/LazyVim", import = "lazyvim.plugins" },
        { import = "lazyvim.plugins.extras.editor.snacks_picker" },
        { import = "lazyvim.plugins.extras.editor.snacks_explorer" },

        -- import/override with your plugins
        { import = "plugins" },
      },
      defaults = {
        -- Use latest commits and pin resolved versions in the lazy lockfile.
        version = false,
      },
      install = {
        colorscheme = { "catppuccin" },
        missing = true,  -- install missing plugins on first launch / after nvim-clean
      },
      checker = { enabled = false }, -- update manually with :Lazy update
      readme = { enabled = false }, -- Prevent writing doc/tags to Nix store
      lockfile = vim.fn.stdpath("state") .. "/lazy-lock.json", -- Avoid read-only config dir
      performance = {
        rtp = {
          -- disable some rtp plugins
          disabled_plugins = {
            "gzip",
            "tarPlugin",
            "tohtml",
            "tutor",
            "zipPlugin",
          },
        },
      },
    })
  '';

  xdg.configFile."nvim/lua/config/options.lua".text = ''
    -- Options are automatically loaded before lazy.nvim startup
    -- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
    -- Add any additional options here

    local opt = vim.opt

    -- Overrides not present in LazyVim defaults or explicitly preferred
    opt.termguicolors  = true
    opt.wrap           = false
    opt.updatetime     = 200
  '';

  xdg.configFile."nvim/lua/config/keymaps.lua".text = ''
    -- Keymaps are automatically loaded on the VeryLazy event
    -- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
    -- Add any additional keymaps here

    local map = vim.keymap.set

    -- Stay in indent mode
    map("v", "<", "<gv")
    map("v", ">", ">gv")

    -- Quickfix
    map("n", "<leader>qo", ":copen<CR>",  { desc = "Open quickfix" })
    map("n", "<leader>qc", ":cclose<CR>", { desc = "Close quickfix" })
  '';

  xdg.configFile."nvim/lua/config/autocmds.lua".text = ''
    -- Autocmds are automatically loaded on the VeryLazy event
    -- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
    -- Add any additional autocmds here

    local augroup  = vim.api.nvim_create_augroup
    local autocmd  = vim.api.nvim_create_autocmd

    -- Trim trailing whitespace on save
    autocmd("BufWritePre", {
      group    = augroup("trim_whitespace", { clear = true }),
      pattern  = "*",
      callback = function() vim.cmd("%s/\\s\\+$//e") end,
    })
  '';

  # ── Plugins ───────────────────────────────────────────────────────────────

  xdg.configFile."nvim/lua/plugins/lsp.lua".text = ''
    return {
      -- Disable mason as we use Nix to provide binaries
      { "mason-org/mason.nvim", enabled = false },
      { "mason-org/mason-lspconfig.nvim", enabled = false },

      -- Configure LSP servers directly
      {
        "neovim/nvim-lspconfig",
        opts = {
          servers = {
            lua_ls = {},
            nil_ls = {},
            bashls = {},
            gopls = {},
            rust_analyzer = {
              -- Pin to the Nix binary. ~/.nix-profile/bin/rust-analyzer is the
              -- rustup proxy, which recurses into itself ("infinite recursion
              -- detected") when the rust-analyzer component is not installed in
              -- the active toolchain.
              cmd = { "${pkgs.rust-analyzer}/bin/rust-analyzer" },
            },
            pyright = {},
          },
          -- LazyVim uses this setup function to override server configs.
          -- Returning true prevents LazyVim from using Mason to configure them.
          setup = {
            -- Apply setup for all servers to bypass Mason requirement
            ["*"] = function(server, opts)
              require("lspconfig")[server].setup(opts)
              return true -- Tell LazyVim not to do anything further
            end,
          },
        },
      },
    }
  '';

  xdg.configFile."nvim/lua/plugins/colorscheme.lua".text = ''
    return {
      {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,
        priority = 1000,
        opts = {
          flavour = "mocha",
          default_integrations = false,
          integrations = {
            blink_cmp  = true,
            telescope  = true,
            gitsigns   = true,
            snacks     = true,
            treesitter = true,
            which_key  = true,
            mini       = { enabled = true },
            lualine    = true,
            noice      = true,
          },
          custom_highlights = function(colors)
            return {
              ["@comment"] = { fg = colors.overlay0, style = { "italic" } },
              ["@constant"] = { fg = colors.peach },
              ["@constructor"] = { fg = colors.yellow },
              ["@function"] = { fg = colors.blue },
              ["@function.method"] = { fg = colors.sky },
              ["@keyword"] = { fg = colors.mauve, style = { "italic" } },
              ["@module"] = { fg = colors.lavender },
              ["@property"] = { fg = colors.teal },
              ["@string"] = { fg = colors.green },
              ["@type"] = { fg = colors.yellow },
              ["@variable"] = { fg = colors.text },
              ["@variable.member"] = { fg = colors.teal },

              ["@function.go"] = { fg = colors.blue },
              ["@function.method.go"] = { fg = colors.sky },
              ["@property.go"] = { fg = colors.teal },
              ["@type.go"] = { fg = colors.yellow },

              ["@function.rust"] = { fg = colors.sky },
              ["@lifetime.rust"] = { fg = colors.peach, style = { "italic" } },
              ["@type.rust"] = { fg = colors.yellow },

              ["@constructor.typescript"] = { fg = colors.yellow },
              ["@function.typescript"] = { fg = colors.blue },
              ["@property.typescript"] = { fg = colors.teal },
            }
          end,
        },
      },
      {
        "folke/tokyonight.nvim",
        enabled = false,
      },
      {
        "LazyVim/LazyVim",
        opts = {
          colorscheme = "catppuccin",
        },
      },
    }
  '';

  xdg.configFile."nvim/lua/plugins/formatting.lua".text = ''
    return {
      {
        "stevearc/conform.nvim",
        opts = {
          formatters_by_ft = {
            lua        = { "stylua" },
            nix        = { "alejandra" },
            sh         = { "shfmt" },
            fish       = { "fish_indent" },
            go         = { "gofmt" },
            rust       = { "rustfmt" },
            python     = { "ruff_format" },
            javascript = { "prettier" },
            typescript = { "prettier" },
            json       = { "prettier" },
            yaml       = { "prettier" },
            markdown   = { "prettier" },
          },
        },
      },
    }
  '';

  xdg.configFile."nvim/lua/plugins/treesitter.lua".text = ''
    return {
      {
        "nvim-treesitter/nvim-treesitter",
        dir = "${treesitterPlugin}",
        build = false,
        opts = function(_, opts)
          opts.ensure_installed = {}
          opts.auto_install = false
          opts.highlight = vim.tbl_deep_extend("force", opts.highlight or {}, {
            enable = true,
            additional_vim_regex_highlighting = false,
          })
          return opts
        end,
      },
    }
  '';

  xdg.configFile."nvim/lua/plugins/autotag.lua".text = ''
    return {
      { "windwp/nvim-ts-autotag", enabled = false },
    }
  '';

  xdg.configFile."nvim/lua/plugins/markdown.lua".text = ''
    vim.filetype.add({
      extension = {
        mdx = "markdown.mdx",
      },
    })

    return {
      {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = {
          "nvim-treesitter/nvim-treesitter",
          "nvim-mini/mini.icons",
        },
        ft = { "markdown", "markdown.mdx" },
        opts = {},
        config = function(_, opts)
          require("render-markdown").setup(opts)
          Snacks.toggle({
            name = "Render Markdown",
            get = require("render-markdown").get,
            set = require("render-markdown").set,
          }):map("<leader>um")
        end,
      },
    }
  '';

  xdg.configFile."nvim/lua/plugins/snacks.lua".text = ''
    return {
      {
        "folke/snacks.nvim",
        opts = {
          gitbrowse = { enabled = true },
          lazygit = { enabled = true },
        },
        keys = {
          { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
          { "<leader>gG", function() Snacks.lazygit.log() end, desc = "Lazygit Log" },
          { "<leader>gb", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },
        },
      },
    }
  '';

  xdg.configFile."nvim/lua/plugins/trouble.lua".text = ''
    return {
      {
        "folke/trouble.nvim",
        cmd = { "Trouble" },
        keys = {
          { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
          { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
        },
        opts = {},
      },
    }
  '';

  xdg.configFile."nvim/lua/plugins/blink.lua".text = ''
    return {
      {
        "saghen/blink.cmp",
        opts = {
          keymap = {
            -- <Esc> closes the completion menu but stays in insert mode;
            -- press it again to leave insert as usual. (Auto-popup stays on.)
            ["<Esc>"] = { "hide", "fallback" },
          },
        },
      },
    }
  '';
}
