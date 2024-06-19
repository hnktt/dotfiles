{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf mkMerge;
  inherit (pkgs) stdenv;

  cfg = config.appearance.fonts;
in
{
  options.appearance.fonts = {
    enable = mkEnableOption ''
      fonts
    '';
  };

  config = mkIf cfg.enable (mkMerge [
    {
      fonts.fontconfig.enable = true;
      nixpkgs.config.allowUnfree = true;

      home.packages = with pkgs;[
        (callPackage ../../packages/apple-fonts.nix { })

        (iosevka.override {
          set = "custom";
          privateBuildPlan = {
            family = "Iosevkarque";
            spacing = "fontconfig-mono";
            serifs = "sans";
            noCvSs = true;
            exportGlyphNames = true;
            noLigation = true;

            variants.inherits = "ss15";

            weights.Light = {
              shape = 300;
              menu = 300;
              css = 300;
            };

            weights.Regular = {
              shape = 400;
              menu = 400;
              css = 400;
            };

            weights.Bold = {
              shape = 700;
              menu = 700;
              css = 700;
            };
            # ligations.inherits = "dlig";
          };
        })
        (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
      ];
    }
  ]);
}
