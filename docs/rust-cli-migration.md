# Rust CLI binaries via mise

## Acceptance contract

- General Rust CLI applications no longer enter the Home Manager build closure.
  This includes procs, ouch, typos and oha from the reported 27-minute rebuild.
- Global CLI requests use exact versions and explicit binary download backends.
  Every request has an upstream HTTPS artifact URL and SHA-256 digest for
  linux-x64, linux-arm64 and macos-arm64 in the committed mise.lock.
- Installation fails closed for missing lock entries, corrupted downloads or
  unavailable binaries. No Cargo compilation, quickinstall or executable asdf
  plugins are part of this installation path. Shell lookup never installs tools.
- Home Manager retains dotfile ownership, Git delta settings, bat defaults,
  Atuin's non-executing history selection and zoxide/Atuin shell hooks.
- Rust toolchains remain rustup-owned. Nix-specific bootstrap tools remain Nix-owned.
- Repository checks and a fresh independent verification pass must succeed before
  release. The consumer updates its base tag and lock together, preserving any
  unrelated lockfile changes. Fleet activation is separately authorized.

## Ownership and bootstrap

Home Manager deploys `users/haru/mise/` as the global mise configuration and
lockfile. It no longer compiles the 28 applications declared there, including
uv/ruff/ty and the binaries for consumer-owned StyLua, Starship and Yazi configs.
Their binary pins are shared; personal prompt/file-manager/editor configuration
stays in the private consumer. All binary pins are global, including on lean
machines; language runtime module imports remain unchanged. Nix still
provides mise itself, rustup, nh and Nix-specific utilities: mise cannot install
its own prerequisite, and Nix integration tools are not general application CLIs.
Language runtime defaults are unchanged.

After switching a machine, explicitly install the reviewed tools from outside a
project, then generate shims and open a new shell:

```sh
cd /tmp
export PATH="$HOME/.nix-profile/bin:$PATH"
mise install --locked
mise reshim
```

The PATH export is required when an older standalone mise shadows the Nix
bootstrap: `mise reshim` selects its shim executable from PATH, even when you
invoke the Nix binary by absolute path. Confirm `command -v mise` resolves through
`.nix-profile/bin` before installation/reshimming; do not delete unrelated binaries
as part of this migration.

Home Manager adds the shim directory to session PATH for noninteractive commands
and Git's delta pager. The shell hooks initialize Atuin/zoxide only when available;
no install is triggered by a shell startup. Until the explicit install completes,
commands that use those CLIs (including the Git pager) are unavailable.

Global strict locked mode also applies to per-project tools: projects must supply
complete lock entries before installation. Explicitly review/trust each project;
broad automatic trust of `~/Projects` and `~/Working` is removed. Disabling Cargo
and asdf backends is intentional; existing projects using them need a reviewed
binary backend or a separately approved exception, not a silent source build.

Tokei's current releases publish no binary assets. Eza publishes no native macOS
binaries. Per the owner's decision, both are omitted from the portable global
set, without downgrading or substituting third-party binaries. `l` and the fzf
directory preview use `ls`. Linux-only Eza can be added later with a reviewed
platform-specific binary manifest.

## Supply-chain wall and its limits

Pins, explicit upstream download URLs and committed digests constrain what gets
installed. Aqua verification settings stay enabled, and locked installations
reverify available provenance. `github:` is used for procs, grex, difftastic,
dust, hyperfine, oha and ouch because the flake's mise 2026.5.12 Aqua snapshot lacks
complete native binary support for those releases (including Rosetta-only recipes). Their lock entries still require exact upstream assets/digests.
Neither binary backend needs cargo-binstall.

Do not infer publisher authentication from a SHA-256 hash alone. Some releases
supply signatures/attestations, others supply only a GitHub release digest or a
hash calculated while generating the lock. Review the initial publisher, asset,
version and digest together. Pins cannot prevent a compromised upstream release,
compromised mise/Nix bootstrap, or an owner overriding policy locally. No release
age quarantine was requested. This is not a Cargo project dependency audit.

`mise lock` can exit successfully with incomplete entries (including after API
rate limits). `make check-policy` independently rejects such locks. Generate
updates in a writable local project copy of the config, with GitHub authentication
if necessary; never mutate Home Manager's read-only store copy. Review the complete
config/lock diff and run a clean locked install before committing. Disable strict
mode only for the controlled generation command (`MISE_LOCKED=0 mise lock ...`),
not in the deployed policy.

The upstream sd v1.1.0 asset reports `sd 1.0.0`; its tagged Cargo.toml also declares
1.0.0. The reviewed pin is the v1.1.0 release asset and digest, not its stale
embedded version string.

## cargo-binstall assessment

cargo-binstall is **not necessary for this manifest**, and is not added to Nix or
mise merely to download Rust applications. It remains useful for independently
managed cargo-only binaries if their authors publish compatible binary artifacts.
The installed cargo-binstall 1.23.0 defaults to
`crate-meta-data,quick-install,compile`: those defaults violate this policy.

For a separately reviewed cargo-only exception, use an exact crate version and
explicitly prohibit compilation and third-party quickinstall:

```sh
cargo binstall CRATE@EXACT_VERSION --disable-strategies compile,quick-install \
  --only-signed --disable-telemetry
```

`--only-signed` fails when publisher signatures are absent. It is not equivalent
to mise's reviewed artifact lock, and this command is not an approved exception by
itself. `cargo install --locked` locks build dependencies; it does **not** mean
binary-only, and rebuilding with cargo-update would reintroduce the original pain.

## Sources

- [mise Aqua backend](https://mise.jdx.dev/dev-tools/backends/aqua.html)
- [mise GitHub backend](https://mise.jdx.dev/dev-tools/backends/github.html)
- [mise Cargo backend](https://mise.jdx.dev/dev-tools/backends/cargo.html)
- [mise lockfiles](https://mise.jdx.dev/dev-tools/mise-lock.html)
- [cargo-binstall](https://github.com/cargo-bins/cargo-binstall)
- [Tokei releases](https://github.com/XAMPPRocky/tokei/releases)
- [Eza releases](https://github.com/eza-community/eza/releases)

Online mise documentation can describe newer features than the flake-provided
version. The deployed configuration is checked against mise 2026.5.12; do not
copy newer settings without testing that bootstrap version.
