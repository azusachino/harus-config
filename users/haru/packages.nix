{
  pkgs,
  lib,
  ...
}: {
  # Portable Rust CLI binaries live in mise/config.toml + mise.lock.
  # Retain working Nix exceptions when upstream binaries are unavailable.
  home.packages = with pkgs;
    [
      curl
      jq
      dasel
      duckdb
      shfmt
      eza # retained: no portable upstream binary set
      tokei # retained: current upstream releases have no binaries
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
