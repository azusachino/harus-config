# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2026-09-09

### Removed

- Drop `cargo-update`, `cargo-sweep`, `cargo-cache` and `sqlx-cli`. Every other
  language's ecosystem tooling has one installer; a cargo binary had two, and
  because `~/.nix-profile/bin` precedes `~/.cargo/bin` on `PATH` the nix copy
  won silently — `cargo-update` was answering 20.0.0 over an installed 22.1.1,
  `sqlx-cli` 0.8.6 over 0.9.0. Neither failed loudly; they just ran an older
  tool than the one that was installed. The split is now `rustup` for the
  toolchain, `cargo install` for cargo binaries, `cargo install-update -a` to
  keep them current.

  `rustup` itself **stays**. It is the bootstrap for a fresh machine, and unlike
  the cargo binaries there is nothing to shadow: nix's rustup and a self-managed
  one are the same version and share `~/.rustup/toolchains`, making nix's a
  front-end rather than a rival. Self-update being disabled in the nix build is
  correct here — `flake.lock` is the updater.

- Drop `golangci-lint`. Every Go repo pins its own — `iroha/.mise.toml` has
  `aqua:golangci/golangci-lint = "2.13.1"` and `felicia`'s Makefile documents
  it as coming from mise. Since mise's shims prepend to `PATH` inside a pinned
  project, the nix copy never won where it was used and was dead weight
  everywhere else.

- Drop `yamlfmt` and `navi`. Zero invocations across six months of shell
  history and 27.5k agent commands, and neither is referenced by a build target.

- Drop `markdownlint-cli2`. `harus-k3s` calls it behind a `command -v` guard,
  so its `make check` now warns and skips instead of linting markdown — accepted
  deliberately rather than by accident.

### Added

- `difftastic` (`difft`) and `typos`. The `toolbelt` skill has documented both
  with concrete recipes since it was "reconciled with the actual harus-config
  nix tool set", but `difftastic` was dropped from the base in `7384460` and
  `typos` was never added — so agents were being told to reach for binaries
  that did not exist. Installing them is the cheaper direction of the fix.

### Changed

- `jdk21` → `zulu21` as the default JDK (`JAVA_HOME` follows). Corretto was the
  first choice but is linux-only in nixpkgs, which fails evaluation on the macs;
  `zulu21` is the same 21.0.11 build on every platform this base targets.

## [0.2.6] - 2026-08-06

### Fixed

- Drop `users/haru/sops.nix`, an unused scaffold that hardcoded
  `defaultSopsFile` relative to this repo's own tree — a public base has
  no business assuming secrets live inside it. `sops-nix` itself stays
  registered here (`baseModules`, just the option surface); actual
  `defaultSopsFile` / `age.keyFile` / `secrets.*` wiring now lives in the
  private `harus-nix` consumer, following the same public/private split as
  `harus.identity`.

## [0.2.5] - 2026-08-06

### Changed

- `neovim` is now a plain editor and nothing more: `enable`, `defaultEditor` and
  the vi/vim/vimdiff aliases. The LazyVim setup moves to the private `harus-nix`
  consumer as a dotfile-first config, following `starship`/`lazygit`/`yazi`/`tmux`
  in `0.2.1`. An editor config is a dotfile you want to own directly, and while
  it lived here every keymap change cost a commit, a release, a tag and an input
  bump. Dev machines opt into the LazyVim config in `harus-nix`; lean machines
  (`harus-pi`, `harus-wsl`) get just the plain editor.

### Removed

- Drop 417 lines of embedded lua, the Treesitter grammar wiring, the Nix-pinned
  `lazy-nvim` plugin and the neovim language-server list (`lua-language-server`,
  `nil`, `bash-language-server`, `gopls`, `pyright`, `stylua`, `tree-sitter`,
  `gcc`). The server list moves with the config it serves rather than staying
  behind — splitting a package list from the config that consumes it is the drift
  this split is meant to avoid.

## [0.2.4] - 2026-08-06

### Removed

- Drop `rust-analyzer` from the neovim LSP servers. (Backfilled: `0.2.4` was
  tagged without a changelog entry.)

## [0.2.3] - 2026-07-27

### Removed

- Drop `pgcli` — closure measured at 1.5 GiB (Python 3.14 +
  `cryptography`/`paramiko`/`pynacl`/krb5/libpq-dev), 4x heavier than the
  `postgresql` full server+client it replaced in `0.2.2`. No replacement;
  reach for `duckdb`'s postgres scanner or an ad-hoc shell when a live
  REPL is needed.
- Drop `difftastic` (166 MiB closure) — rarely used. Also removes the
  `git dft` alias and `difftool.difftastic` config from `git.nix`; `delta`
  remains the default diff pager.

## [0.2.2] - 2026-07-25

### Changed

- Replace `postgresql` (full server + client, 345 MB) with `pgcli` —
  interactive-only, so scripts/agents should reach for `duckdb` instead;
  `pgcli` stays for hands-on REPL use.

### Removed

- Drop `miller` — redundant with `duckdb` (reads CSV/JSON/Parquet
  directly) + `dasel`.
- Drop `k9s`, `kubectl`, `stern` — cluster-only tools that shipped to
  every machine, including the Pi and WSL, which never touch a
  cluster. Machines that do (`harus-mini`, `harus-workair`) now declare
  them locally in the private `harus-nix` consumer.

## [0.2.1] - 2026-07-17

### Changed

- Inline the remaining file-sourced dotfiles (`npmrc`, `bunfig.toml`,
  `mise/config.toml`, `uv/uv.toml`) directly into their Nix modules as `text`
  instead of `.source` pointers into `users/config/`; the directory is now
  gone.

### Removed

- Drop `glow` — package, its `xdg.configFile` entry, and config asset.
- Move `claude.nix`, `gemini.nix` (agent statusline/hook scripts), Ghostty
  terminal config, `starship.nix`, `lazygit.nix`, `yazi.nix`, and `tmux.nix`
  out of the public base. They're personal/cosmetic and tweaked often, so
  they now live in the private `harus-nix` consumer (as dotfile-first
  configs — real `.toml`/`.yml`/`.conf` files instead of Nix attrsets) instead
  of requiring a public release for every change.

## [0.2.0] - 2026-07-12

### Added

- `ast-grep`, `difftastic` — toolbelt-referenced code tools.
- `nix-tree`, `comma` — Nix workflow tools (`comma` pairs with `programs.nix-index`).
- `git-cliff` — changelog generation from conventional commits.

### Changed

- Promote config from the private `harus-nix` consumer into the shared base:
  `atuin` settings, `fzf` fd-source + bat/eza previews, `bat` theme/style
  (via `programs.bat.enable`), and low-risk `git` keys (`rerere`, histogram
  diff, `commit.verbose`, `column.ui`, `help.autocorrect`).
- Wire `difftastic` as the `git dft` difftool; `delta` remains the default
  pager. (Backfilled: `0.2.0` was tagged without a changelog entry.)

## [0.1.1] - 2026-07-08

### Removed

- Drop unused packages to slim the closure: `helix` (and its `helix.nix`
  module), `zig`, `cargo-zigbuild`, and `ffmpeg`.

### Changed

- Replace `unar` with `ouch` for unified compress/extract.
- Dedupe `zoxide` — it's already provided by `programs.zoxide.enable`.

## [0.1.0] - 2026-07-07

Initial public release — the reusable Home Manager base.

### Added

- Reusable Home Manager base as `homeManagerModules.default` (shell, editors,
  git, gh, tmux, direnv, yazi, lazygit, mise, atuin, agent config) and
  `homeManagerModules.runtimes` (opt-in language runtimes).
- `harus.identity` option (`name` / `email` / `githubUser`) as the single seam
  for personal identity, defaulting to the author's public GitHub identity.
- `checks.exampleHome` — CI builds a full home-manager generation per system.
- OSS scaffolding: LICENSE (MIT), README, CONTRIBUTING, CODE_OF_CONDUCT,
  SECURITY, issue/PR templates, Makefile, GitHub Actions CI.

[0.2.1]: https://github.com/azusachino/harus-config/releases/tag/v0.2.1
[0.1.1]: https://github.com/azusachino/harus-config/releases/tag/v0.1.1
[0.1.0]: https://github.com/azusachino/harus-config/releases/tag/v0.1.0
