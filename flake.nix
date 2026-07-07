{
  description = "harus-config — reusable Home Manager base modules";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    pre-commit-hooks,
    nix-index-database,
    sops-nix,
    ...
  }: let
    systems = ["aarch64-darwin" "x86_64-linux" "aarch64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    # Consumers import this into a home-manager evaluation and pass `username`
    # via extraSpecialArgs. It bundles the shared program config + the
    # nix-index-database / sops-nix modules so consumers need neither input.
    homeManagerModules = {
      default = {
        imports = [
          nix-index-database.homeModules.default
          sops-nix.homeManagerModules.sops
          ./users/haru/home.nix
        ];
      };

      # Default language runtimes — dev machines opt in; lean machines skip it.
      runtimes = ./users/haru/runtimes.nix;
    };

    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    devShells = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        hooks = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            alejandra.enable = true;
            shellcheck.enable = true;
          };
        };
      in {
        default = pkgs.mkShell {
          inherit (hooks) shellHook;
          packages = [pkgs.alejandra pkgs.nixd];
        };
      }
    );
  };
}
