# example/home.nix — a sample machine module.
# A consumer flake imports harus-config.homeManagerModules.default alongside a
# module like this one, and passes `username` via extraSpecialArgs.
{pkgs, ...}: {
  # Override identity where it differs from the haru defaults (e.g. a work box):
  harus.identity = {
    name = "Your Name";
    email = "you@example.com";
  };

  # Per-machine packages on top of the shared base:
  home.packages = with pkgs; [
    ripgrep
    fd
  ];
}
