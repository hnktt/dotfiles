{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf mkMerge;
  inherit (pkgs) stdenv;

  cfg = config.apps.pass;
in
{
  options.apps.pass = {
    enable = mkEnableOption ''
      Enable gpg
    '';
  };

  config = mkIf cfg.enable (mkMerge [
    { programs.password-store.enable = true; }

    (mkIf config.modules.firefox.enable {
      programs.browserpass.browsers = [ "firefox" ];
    })

    (mkIf stdenv.isDarwin {
      home.file.".gnupg/gpg-agent.conf".text = ''
        pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
      '';
    })

    (mkIf stdenv.isLinux {
      services.gpg-agent.extraConfig = ''
        pinentry-program ${pkgs.pinentry.gnome3}/bin/pinentry-gnome3
      '';
    })
  ]);
}
