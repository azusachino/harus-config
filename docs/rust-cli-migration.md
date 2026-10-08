# Rust CLI binaries via mise

## Ownership

Mise owns 27 portable Rust application CLIs, using explicit Aqua/GitHub binary
backends and `major.minor` version constraints in `users/haru/mise/config.toml`.
Patch versions can advance without editing the manifest. There is no managed
mise lockfile and no global requirement that projects use locks.

Nix retains Tokei and Eza because acceptable portable upstream binaries are
unavailable. The private consumer retains its normal Nix Starship package and
existing prompt theme, and Nix resvg for original Yazi SVG rendering. These are
explicit exceptions: keep working functionality instead of removing it.
Nix also retains mise itself, rustup, language runtime defaults and Nix-specific
utilities. Rust toolchains remain rustup-owned.

Home Manager still owns the application dotfiles, bat defaults, Git delta
settings, Atuin/zoxide shell hooks and private editor/file-manager settings.
Eza powers `l` and directory previews again. Managed shims and Nix bootstrap
precede manual Cargo/standalone binaries in Fish, Bash and Zsh.

## Install and upgrade

After activation, install global tools outside a project:

```sh
cd /tmp
export PATH="$HOME/.nix-profile/bin:$PATH"
mise install
mise reshim
```

Installations are explicit; shell startup and command lookup do not install
software. To update patches within the configured minor versions:

```sh
cd /tmp
mise upgrade
mise reshim
```

For a new minor version, edit the shared config's constraint and apply Home
Manager. The managed global config is read-only; do not use `mise use -g` to
rewrite its symlink. Nix-owned tool versions are updated through the Nix inputs,
not separate upstream-release packaging.

Projects remain free to use `latest`, minor constraints, exact versions or their
own lockfiles. Normal project commands such as `mise use bun@latest` and
`mise install` do not require a lock. Review/trust project configuration
explicitly. If an existing shell inherited `MISE_LOCKED=1`, remove that variable
(`set -e MISE_LOCKED` in Fish); `set -gx MISE_LOCKED 0` temporarily disables it.
Do not force project lockfiles solely to make these globals work.

## Fish prompt recovery

A Fish session started before the migration may have cached
`~/.nix-profile/bin/starship` in its generated prompt functions. Starship is
Nix-owned again, restoring that executable path. For a clean refresh of all
shell hooks after activation:

```fish
exec ~/.nix-profile/bin/fish --login
```

Do not delete unrelated manually installed binaries. PATH precedence handles
old Cargo/standalone copies without modifying them.

## Verification and trade-offs

`make check-policy` validates minor constraints, explicit binary backends,
optional project locks, retained Nix exceptions and disabled automatic installs,
including negative fixtures. Run the owning flake/format gates and actual Fish
interactive/noninteractive, Bash/Zsh, Git-pager and editor/file-manager journeys.
Linux runtime and real UI checks must be reported separately from structural
flake evaluation. Releases follow the owning workstation verification rules;
machine activation requires explicit target approval.

The owner replaced v0.4.0's exact global locks with this lower-maintenance policy
because global locked mode broke ordinary work-project version resolution.
Minor constraints are not reproducible patch pins. There is no committed
artifact-digest matrix; use the selected backend's available upstream checksums,
signatures and attestations. Aqua verification options stay enabled, but do not
claim every upstream publishes equivalent provenance or that every future
patch is already tested. Cargo/asdf backends remain disabled; no quickinstall
or source-build fallback is introduced for these globals.

Cargo-binstall is unnecessary for this manifest. Its default quickinstall/source
fallback is not an approved way to bypass a missing upstream binary; retain a
working Nix package instead of dropping functionality.
