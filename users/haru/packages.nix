{
  pkgs,
  lib,
  ...
}: {
  # Rust application CLIs live in mise/config.toml + mise.lock, not this closure.
  # Nix-coupled bootstrap tools remain here; see docs/rust-cli-migration.md.
  home.packages = with pkgs;
    [
      curl
      jq
      dasel
      duckdb
      shfmt
      doggo # Go DNS CLI; not part of the Rust application migration

      # Nix & System Tools
      nh
      nix-output-monitor
      nix-tree
      comma
      btop

      # Development - Tools & Version Control
      git-lfs
      sops
      age
      shellcheck

      # Infrastructure & Cloud
      rclone
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      podman
      buildah
      skopeo
    ];
}
