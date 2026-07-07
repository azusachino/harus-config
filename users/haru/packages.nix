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
      glow
      dasel # query/convert JSON/YAML/TOML/XML/CSV in one tool
      duckdb
      postgresql # psql client + server tools
      miller # mlr: CSV/TSV/JSON data swiss army knife
      shfmt
      eza
      bat
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
      btop
      procs # modern ps: tree view, search, ports
      hyperfine # command-line benchmarking
      oha # modern benchmark tool

      # Code stats & utilities (language-agnostic)
      tokei # count lines of code
      grex # generate regex

      # Development - Tools & Version Control
      git-lfs
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
      ffmpeg
      unar # archive extractor

      # Shell & Navigation
      zoxide
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
