{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs;
    [
      # Core Utilities
      curl
      xh # fast HTTP client (Rust httpie) for API testing/debug
      jq
      dasel # query/convert JSON/YAML/TOML/XML/CSV in one tool
      duckdb
      postgresql # psql client + server tools
      miller # mlr: CSV/TSV/JSON data swiss army knife
      shfmt
      eza
      # bat — installed via programs.bat.enable in home.nix (binary + config)
      ripgrep
      fd
      sd # intuitive find & replace (modern sed)
      dust
      tailspin
      hexyl # colored hex viewer
      doggo # modern dig: clean DNS lookups

      # Nix & System Tools
      nh # ergonomic nix/home-manager workflow helper
      nix-output-monitor # nom: colorful nix build progress
      nix-tree # interactive closure explorer (why is this in the closure?)
      comma # run any binary on demand via nix-index (`, <cmd>`)
      btop
      procs # modern ps: tree view, search, ports
      hyperfine # command-line benchmarking
      oha # modern benchmark tool

      # Code stats & utilities (language-agnostic)
      tokei # count lines of code
      grex # generate regex
      ast-grep # structural code search/rewrite by AST pattern

      # Development - Tools & Version Control
      git-lfs
      difftastic # structural diff (difft); syntax-aware git diffs
      git-cliff # changelog generator from conventional commits
      sops
      age
      watchexec
      usage # CLI docs generator
      shellcheck
      yamlfmt
      # pre-commit — provided inside `nix develop` by the flake's pre-commit-hooks input

      # Infrastructure & Cloud
      k9s
      kubectl
      # minikube — run on demand: `nix run nixpkgs#minikube -- start` (heavy, rarely used)
      stern
      rclone

      # File Management & Media
      ouch # modern unified compress/extract (Rust)

      # Shell & Navigation
      # zoxide — installed via programs.zoxide.enable in fish.nix (binary + shell integration)
      navi # interactive cheat sheet

      # Editors
      # helix — configured via users/haru/helix.nix (programs.helix installs the package)
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      # Container toolkit (Linux only — rootless, daemonless)
      podman
      buildah # build OCI images without a daemon
      skopeo # inspect/copy container images
    ];
}
