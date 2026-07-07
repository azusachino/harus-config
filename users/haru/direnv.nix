{...}: {
  programs.direnv = {
    enable = true;

    # nix-direnv: faster, cached Nix shell evaluation for .envrc files
    # that use `use nix` or `use flake`
    nix-direnv.enable = true;
  };
}
