# modules/identity.nix — the single seam for personal identity.
# Consumers override harus.identity.* (e.g. a work machine sets name/email).
{lib, ...}: {
  options.harus.identity = {
    name = lib.mkOption {
      type = lib.types.str;
      default = "haru";
      description = "Git author/committer name.";
    };
    email = lib.mkOption {
      type = lib.types.str;
      default = "azusachino@proton.me";
      description = "Git author/committer email.";
    };
    githubUser = lib.mkOption {
      type = lib.types.str;
      default = "haru";
      description = "GitHub username (for SSH/gh where relevant).";
    };
  };
}
