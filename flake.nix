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
    in
    {
      homeConfigurations.evgeniya = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";

        extraSpecialArgs = {
          inherit inputs;
          system = "x86_64-linux";
          lib = nixpkgs.lib.extend
            (final: prev: { }
              // (import ./stdenv.nix { })
              // home-manager.lib);
        };

        modules = [
          ./modules/git.nix
          ./modules/zsh.nix
          ./modules/emacs.nix
          ./modules/gpg.nix
          ./modules/pass.nix
          ./modules/firefox.nix
          ./modules/neovim.nix

          ({ pkgs, ... }: {
            programs.firefox.package = pkgs.firefox.override {
              nativeMessagingHosts = with pkgs; [
                gnome-browser-connector
                browserpass
              ];
            };

            modules.git.enable = true;
            modules.zsh.enable = true;
            modules.emacs.enable = true;
            modules.gpg.enable = true;
            modules.pass.enable = true;
            modules.firefox.enable = true;
            modules.neovim.enable = true;

            # programs.firefox.profiles."pml" = {
            #   settings = {
            #     "browser.startup.page" = 3;
            #     "browser.formfill.enable" = false;
            #     "browser.download.useDownloadDir" = false;
            #     "gfx.webrender.all" = true;
            #     "media.ffmpeg.vaapi.enabled" = true;
            #     "media.ffvpx.enabled" = false;
            #     "media.rdd-vpx.enabled" = false;
            #     "media.navigator.mediadatadecoder_vpx_enabled" = true;
            #     "services.sync.prefs.sync.browser.formfill.enable" = false;
            #     "signon.rememberSignons" = false;
            #     "signon.prefillForms" = false;
            #   };
            # };

            home.username = "pml";
            home.homeDirectory = "/home/pml";
            home.stateVersion = "24.05";

            programs.home-manager.enable = true;
          })
        ];
      };

      homeConfigurations.magda = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."aarch64-darwin";

        extraSpecialArgs = {
          inherit inputs;
          system = "aarch64-darwin";
          lib = nixpkgs.lib.extend
            (final: prev: { }
              // (import ./stdenv.nix { })
              // home-manager.lib);
        };

        modules = [
          ./modules/git.nix
          ./modules/zsh.nix
          ./modules/emacs.nix
          ./modules/gpg.nix
          ./modules/pass.nix
          ./modules/firefox.nix
          ./modules/neovim.nix

          {
            modules.git.enable = true;
            modules.zsh.enable = true;
            modules.emacs.enable = true;
            modules.gpg.enable = true;
            modules.pass.enable = true;
            modules.firefox.enable = true;
            modules.neovim.enable = true;
          }

          {
            home.username = "pml";
            home.homeDirectory = "/Users/pml";
            home.stateVersion = "24.05";

            programs.home-manager.enable = true;
          }
        ];
      };

      formatter = forAllSystems ({ pkgs, ... }: pkgs.nixpkgs-fmt);
    };
}
