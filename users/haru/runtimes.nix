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
#
# mise's shell activation prepends its shims to PATH inside a pinned project,
# so a project .mise.toml transparently overrides the runtime defaults below;
# outside such dirs you fall back to these versions.
{pkgs, ...}: {
  home.packages = with pkgs; [
    # Java
    jdk21 # default JDK;
    maven

    # Go
    go
    golangci-lint

    # Node / JS
    nodejs_24 # current LTS ("Jod" → 24); matches what mise `node = "lts"` resolved to
    bun
    prettier
    markdownlint-cli2

    # Python
    python314
    uv
    ruff
    ty

    # Rust (toolchain via rustup; the rest are cargo-ecosystem helpers)
    rustup # run `rustup default stable`
    cargo-update
    cargo-zigbuild
    cargo-sweep
    cargo-cache
    sqlx-cli # async SQL toolkit / DB migrations (Rust)

    # Zig
    zig
  ];

  # nixpkgs JDKs do not export JAVA_HOME. `.home` is the platform-correct JDK
  # home path (handles the darwin layout). When mise activates a different JDK
  # in a project, it re-exports JAVA_HOME and restores this value on exit.
  home.sessionVariables.JAVA_HOME = "${pkgs.jdk21.home}";
}
