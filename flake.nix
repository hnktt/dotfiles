{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    neovim-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, emacs-overlay, neovim-overlay, nixpkgs, nur, home-manager }@ inputs:
    let
      systems = [ "x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      forAllSystems = function:
        (nixpkgs.lib.genAttrs systems (
          system:
          function (
            let
              pkgs = nixpkgs.legacyPackages.${system};
            in
            { inherit pkgs system; }
          )
        ));

      mkHome = system: username: fn: fn
        ({
          inherit username system;

          lib = nixpkgs.lib.extend
            (final: prev: { }
              // (import ./lib { lib = nixpkgs.lib; })
              // home-manager.lib);

          pkgs = nixpkgs.legacyPackages.${system};
        });
    in
    {
      homeConfigurations.evgeniya = mkHome "x86_64-linux" "pml"
        ({ lib, pkgs, system, username, ... }: home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = { inherit inputs lib system; };

          modules =
            (lib.recursiveImports ./modules)
            ++
            [
              ./machines/evgeniya.nix
              {
                home.username = "${username}";
                home.homeDirectory = "/home/${username}";

                programs.home-manager.enable = true;
              }
            ];
        });

      homeConfigurations.magda = mkHome "aarch64-darwin" "pml"
        ({ lib, pkgs, system, username, ... }: home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = { inherit inputs lib system; };

          modules =
            (lib.recursiveImports ./modules)
            ++
            [
              ./machines/magda.nix
              {
                home.username = "${username}";
                home.homeDirectory = "/Users/${username}";

                programs.home-manager.enable = true;
              }
            ];
        });

      formatter = forAllSystems ({ pkgs, ... }: pkgs.nixpkgs-fmt);
    };
}
