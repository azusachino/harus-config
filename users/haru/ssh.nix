{pkgs, ...}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" =
        {
          AddKeysToAgent = "yes";
        }
        // pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
          UseKeychain = "yes";
        };

      "github.com" = {
        User = "git";
        IdentityFile = "~/.ssh/id_rsa";
        PreferredAuthentications = "publickey";
      };
    };
  };
}
