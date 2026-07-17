# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.1] - 2026-07-17

### Changed

- Inline the remaining file-sourced dotfiles (`npmrc`, `bunfig.toml`,
  `mise/config.toml`, `uv/uv.toml`) directly into their Nix modules as `text`
  instead of `.source` pointers into `users/config/`; the directory is now
  gone.

### Removed

- Drop `glow` — package, its `xdg.configFile` entry, and config asset.
- Move `claude.nix`, `gemini.nix` (agent statusline/hook scripts), and the
  Ghostty terminal config out of the public base. They're personal/cosmetic
  and tweaked often, so they now live in the private `harus-nix` consumer
  instead of requiring a public release for every change.

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
