<div align="center">

# ❄️ harus-config

**A reusable [Home Manager](https://nix-community.github.io/home-manager/) base — shell, editors, git, CLI toolbelt, and agent config in one flake.**

Factored out of a personal Nix setup so any machine, colleague, or friend can build on the same foundation.

[![CI](https://github.com/azusachino/harus-config/actions/workflows/ci.yml/badge.svg)](https://github.com/azusachino/harus-config/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/tag/azusachino/harus-config?label=release&sort=semver)](https://github.com/azusachino/harus-config/releases)
[![License: MIT](https://img.shields.io/github/license/azusachino/harus-config)](LICENSE)
[![Built with Nix](https://img.shields.io/badge/built%20with-nix-5277C3?logo=nixos&logoColor=white)](https://nixos.org)
[![Home Manager](https://img.shields.io/badge/home--manager-26.05-41439a)](https://github.com/nix-community/home-manager)

[![Last commit](https://img.shields.io/github/last-commit/azusachino/harus-config)](https://github.com/azusachino/harus-config/commits/main)
[![Stars](https://img.shields.io/github/stars/azusachino/harus-config?style=social)](https://github.com/azusachino/harus-config/stargazers)

</div>

---

`harus-config` is a **module library**, not a runnable configuration. You consume it from your own flake, supply a `username`, and override identity as needed. Everything personal lives behind a single option — nothing else is hard-coded.

## ✨ Features

- **One import, a full environment** — shell (bash/zsh/fish + starship), editor (neovim), git + delta, gh, tmux, direnv, yazi, lazygit, mise, atuin, and agent config.
- **Single identity seam** — `harus.identity` (`name` / `email` / `githubUser`). Override per machine; nothing else carries identity.
- **Batteries bundled** — `nix-index-database` and `sops-nix` are wired in, so consumers don't need those inputs.
- **Opt-in runtimes** — default language runtimes (jdk/go/node/bun/zig) are a separate module dev machines opt into.
- **Verified in CI** — every push builds a real home-manager generation on Linux **and** macOS.

## 🚀 Quick start

Add it as an input and import the module:

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    harus-config.url = "github:azusachino/harus-config/v0.1.1"; # pin a tag
  };

  outputs = {nixpkgs, home-manager, harus-config, ...}: {
    homeConfigurations.me = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = {username = "you";}; # required
      modules = [
        harus-config.homeManagerModules.default
        harus-config.homeManagerModules.runtimes # optional
        {
          harus.identity = {
            name = "Your Name";
            email = "you@example.com";
          };
          home.packages = [];
        }
      ];
    };
  };
}
```

Then build and activate:

```sh
nix run home-manager -- switch --flake .#me
```

See [`example/home.nix`](example/home.nix) for a sample machine module.

## 📦 What's exported

| Output | Contents |
| --- | --- |
| `homeManagerModules.default` | Shell (bash/zsh/fish/starship), editor (neovim), git + delta, gh, tmux, direnv, yazi, lazygit, mise, atuin, agent config (claude/gemini) + the `harus.identity` option. Bundles `nix-index-database` and `sops-nix`. |
| `homeManagerModules.runtimes` | Default language runtimes (jdk, go, node, bun) — opt in per machine. |
| `checks.<system>.exampleHome` | Builds a full home-manager generation from the base (what CI runs). |
| `formatter.<system>` | `alejandra`, via `nix fmt`. |
| `devShells.<system>.default` | `alejandra` + `nixd` + pre-commit hooks. |

## 🧩 Identity

All personal identity lives behind one option:

```nix
harus.identity = {
  name       = "haru";                 # default
  email      = "azusachino@proton.me"; # default
  githubUser = "haru";                 # default
};
```

Override it per machine (e.g. a work box sets a different name/email). No other module hard-codes identity, so the base is safe to publish and easy to fork.

## 🏷️ Versioning

This project follows [Semantic Versioning](https://semver.org). Flake inputs pin
by commit hash in your `flake.lock`, but tags give you a stable, human-readable
reference:

```nix
harus-config.url = "github:azusachino/harus-config/v0.1.1"; # pinned
# or track the latest:
harus-config.url = "github:azusachino/harus-config";        # main
```

Bump with `nix flake update harus-config`. See the [CHANGELOG](CHANGELOG.md) for
what changed between releases.

## 🛠️ Development

```sh
nix develop        # dev shell: alejandra, nixd, pre-commit hooks
make fmt           # format .nix files
make check         # flake check + build the example generation (matches CI)
make help          # list targets
```

## 🤝 Contributing

Issues and PRs welcome — see [CONTRIBUTING.md](CONTRIBUTING.md) and the
[Code of Conduct](CODE_OF_CONDUCT.md). The one rule that matters: keep modules
**identity-free**.

## 📄 License

[MIT](LICENSE) © haru
