# Contributing

Thanks for your interest! This is a personal Home Manager base, but improvements
and fixes are welcome.

## Development

```sh
nix develop        # enter dev shell (alejandra, nixd, pre-commit hooks)
make fmt           # format .nix files
make check         # validate flake + formatting
```

## Guidelines

- Keep modules **identity-free** — anything personal (names, emails, hosts)
  belongs behind the `harus.identity` option or in the consumer's own repo, not
  hard-coded here.
- Format with `alejandra` (`make fmt`) before opening a PR.
- Conventional commit messages (`feat:`, `fix:`, `chore:`).
- One concern per module; match the style of the surrounding files.
