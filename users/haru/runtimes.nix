# users/haru/runtimes.nix
# Default language runtimes AND their ecosystem tooling (package managers,
# build helpers, language-specific linters/formatters) — the reproducible dev
# toolchain, pinned by flake.lock. Imported only by dev-capable machines, so the
# Pi / WSL stay lean.
#
# Tool split:
#   nix  → stable default majors + per-language tooling (this file)
#   mise → per-project version pinning via .mise.toml (e.g. java 8/21, zig 0.16, exact patches)
#   rustup → rust toolchains (rustup itself lives here; you run `rustup default stable`)
#   cargo → cargo-installed binaries, and these are deliberately NOT nix'd.
#           ~/.nix-profile/bin precedes ~/.cargo/bin on PATH, so a nix copy of a
#           cargo binary silently shadows whatever you `cargo install` and serves
#           an older version — cargo-update answered 20.0.0 over an installed
#           22.1.1, sqlx-cli 0.8.6 over 0.9.0, neither failing loudly. rustup
#           above is exempt: nix's and the self-managed one are the same version
#           and share ~/.rustup/toolchains, so it is a front-end, not a rival.
#           `cargo install-update -a` is the updater for everything under cargo.
#
# mise's shell activation prepends its shims to PATH inside a pinned project,
# so a project .mise.toml transparently overrides the runtime defaults below;
# outside such dirs you fall back to these versions.
{pkgs, ...}: {
  home.packages = with pkgs; [
    # Java
    corretto21 # default JDK
    maven

    # Go
    go # golangci-lint comes from each project's .mise.toml, pinned per repo

    # Node / JS
    nodejs_24 # current LTS ("Jod" → 24); matches what mise `node = "lts"` resolved to
    bun
    prettier

    # Python
    python314
    uv
    ruff
    ty

    # Rust (toolchain manager only — cargo binaries are `cargo install`ed)
    rustup # run `rustup default stable`
  ];

  # nixpkgs JDKs do not export JAVA_HOME. `.home` is the platform-correct JDK
  # home path (handles the darwin layout). When mise activates a different JDK
  # in a project, it re-exports JAVA_HOME and restores this value on exit.
  home.sessionVariables.JAVA_HOME = "${pkgs.corretto21.home}";
}
