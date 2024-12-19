{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    nur.url = "github:nix-community/NUR";
    mac-app-util.url = "github:hraban/mac-app-util";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    neovim-overlay.url = "github:nix-community/neovim-nightly-overlay";
    nix-utils.url = "git+https://codeberg.org/noctologue/nix-utils.git";
  };

  outputs =
    {
      self,
      emacs-overlay,
      neovim-overlay,
      nixpkgs,
      nur,
      home-manager,
      nix-utils,
      mac-app-util,
    }@inputs:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      lib' = nix-utils.mkLib { inherit nixpkgs systems; };

      mkHome =
        system: username: fn:
        fn ({
          inherit username system;

          lib = nixpkgs.lib.extend (
            final: prev: { } // (import ./lib { lib = nixpkgs.lib; }) // home-manager.lib
          );

          pkgs = nixpkgs.legacyPackages.${system};
        });
    in
    {
      homeConfigurations.rabelais = mkHome "x86_64-linux" "pml" (
        {
          lib,
          pkgs,
          system,
          username,
          ...
        }:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = {
            inherit inputs lib system;
          };

          modules = (lib.recursiveImports ./modules) ++ [
            ./machines/rabelais.nix
            {
              home.username = "${username}";
              home.homeDirectory = "/home/${username}";

              programs.home-manager.enable = true;
            }
          ];
        }
      );

      homeConfigurations.montaigne = mkHome "aarch64-darwin" "pml" (
        {
          lib,
          pkgs,
          system,
          username,
          ...
        }:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = {
            inherit inputs lib system;
          };

          modules = (lib.recursiveImports ./modules) ++ [
            ./machines/montaigne.nix
            mac-app-util.homeManagerModules.default
            {
              home.username = "${username}";
              home.homeDirectory = "/Users/${username}";

              programs.home-manager.enable = true;
            }
          ];
        }
      );

      formatter = lib'.forAllSystems ({ pkgs, ... }: pkgs.nixfmt-rfc-style);
    };
}
