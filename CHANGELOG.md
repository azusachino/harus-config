# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[0.1.0]: https://github.com/azusachino/harus-config/releases/tag/v0.1.0
