{
  config,
  inputs,
  lib,
  pkgs,
  system,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkMerge;
  inherit (pkgs) fetchurl stdenv undmg;

  cfg = config.apps.firefox;

  firefox-darwin = stdenv.mkDerivation rec {
    pname = "Firefox";
    version = "133.0.3";
    buildInputs = [ undmg ];
    sourceRoot = ".";
    phases = [
      "unpackPhase"
      "installPhase"
    ];
    installPhase = ''
      mkdir -p "$out/Applications"
      cp -r Firefox.app "$out/Applications/Firefox.app"
    '';
    src = fetchurl {
      name = "Firefox-${version}.dmg";
      url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${version}/mac/en-GB/Firefox%20${version}.dmg";
      sha256 = "6wlF8YFqtwPB+83lFdv/ytvOeyc8RVof7z3BVXyAjyU=";
    };
  };
in
{
  options.apps.firefox = {
    enable = mkEnableOption "Enable Firefox";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      nixpkgs.overlays = [ inputs.nur.overlay ];

      programs.firefox = {
        enable = true;
        package = if stdenv.isDarwin then firefox-darwin else pkgs.firefox;
        policies = {
          EnableTrackingProtection = true;
          SearchEngines.Default = "DuckDuckGo";
        };
        profiles."${config.home.username}" = {
          id = 0;
          isDefault = true;
          name = "${config.home.username}";
          search = {
            force = true;
            default = "DuckDuckGo";
          };
          settings = {
            "browser.startup.page" = 3;
            "browser.formfill.enable" = false;
            "browser.download.useDownloadDir" = false;
            "services.sync.prefs.sync.browser.formfill.enable" = false;
            "signon.rememberSignons" = false;
            "signon.prefillForms" = false;
          };
          extensions = with pkgs.nur.repos.rycee.firefox-addons; [
            ublock-origin
            search-by-image
            bitwarden
          ];
        };
      };
    }
  ]);
}
