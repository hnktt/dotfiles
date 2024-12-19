{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkMerge mkOption types;
  inherit (pkgs) fetchurl stdenv p7zip;

  cfg = config.appearance.fonts;

  apple-fonts = stdenv.mkDerivation {
    pname = "sf-pro";
    version = "1.0";
    src = fetchurl {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
      sha256 = "IccB0uWWfPCidHYX6sAusuEZX906dVYo8IaqeX7/O88=";
    };
    nativeBuildInputs = [ p7zip ];
    unpackPhase = ''
      7z x $src
    '';
    installPhase = ''
      cd SFProFonts 
      7z x 'SF Pro Fonts.pkg'
      7z x 'Payload~'
      mkdir -p $out/share/fonts/opentype
      cp -r Library/Fonts/SF-Pro*.otf $out/share/fonts/opentype/
    '';
    meta = with lib; {
      description = "SF Pro - The system font for Apple platforms";
      homepage = "https://developer.apple.com/fonts/";
      license = licenses.unfree;
      platforms = platforms.all;
      maintainers = [ ];
    };
  };

  iosevka-custom = pkgs.iosevka.override {
    set = "custom";
    privateBuildPlan = {
      family = "Iosevka";
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
    };
  };
in
{
  options.appearance.fonts = {
    enable = mkEnableOption "Enable fonts configuration";
    
    extraFonts = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional fonts to install alongside the default ones";
      example = lib.literalExpression ''
        with pkgs; [
          fira-code
          source-code-pro
        ]
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      nixpkgs.config.allowUnfree = true;
      fonts.fontconfig.enable = true;
      home.packages = with pkgs; [
        iosevka-custom
        etBook
        (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
      ] ++ cfg.extraFonts;
    }

    (mkIf (!stdenv.isDarwin) {
      home.packages = [ apple-fonts ];
      dconf.settings = {
        "org/gnome/desktop/interface" = {
          enable-animations = false;
          font-name = "SF Pro 11";
          monospace-font-name = "Iosevka 12";
        };
      };
    })
  ]);
}
