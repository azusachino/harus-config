# harus-config

Reusable [Home Manager](https://nix-community.github.io/home-manager/) base
modules — shell, editors, git, CLI toolbelt, and agent config — factored out of
a personal Nix flake so any machine (or person) can build on top of them.

This repo is a **module library**, not a runnable configuration. You consume it
from your own flake, supply a `username`, and override identity as needed.

## Usage

```nix
# your-flake.nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    harus-config.url = "github:azusachino/harus-config";
  };

  outputs = {nixpkgs, home-manager, harus-config, ...}: {
    homeConfigurations.me = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = {username = "you";};
      modules = [
        harus-config.homeManagerModules.default
        harus-config.homeManagerModules.runtimes # optional: default language runtimes
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

See [`example/home.nix`](example/home.nix) for a sample machine module.

## What's exported

| Output | Contents |
| --- | --- |
| `homeManagerModules.default` | Shell (bash/zsh/fish/starship), editors (neovim/helix), git + delta, gh, tmux, direnv, yazi, lazygit, mise, atuin, agent config (claude/gemini), plus the `harus.identity` option. Bundles `nix-index-database` and `sops-nix`. |
| `homeManagerModules.runtimes` | Default language runtimes (jdk, go, node, bun, zig) — opt in per machine. |

## Identity

All personal identity lives behind one option, `harus.identity`
(`name` / `email` / `githubUser`), defaulting to the author's public GitHub
identity. Override it per machine — nothing else carries hard-coded identity.

## Requirements

`extraSpecialArgs.username` must be set (the home directory and account name
derive from it). Pin the exact revision via your `flake.lock`.
