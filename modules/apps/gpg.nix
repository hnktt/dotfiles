{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkMerge;
  inherit (pkgs) stdenv;

  cfg = config.apps.gpg;
in
{
  options.apps.gpg = {
    enable = mkEnableOption ''
      gpg
    '';
  };

  config = mkIf cfg.enable (mkMerge [
    { programs.gpg.enable = true; }

    (mkIf stdenv.isDarwin {
      home.file.".gnupg/gpg-agent.conf".text = ''
        pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
      '';
    })

    (mkIf stdenv.isLinux {
      services.gpg-agent.enable = true;
      services.gpg-agent.enableSshSupport = true;
      services.gpg-agent.enableZshIntegration = true;
      services.gpg-agent.extraConfig = ''
        pinentry-program ${pkgs.pinentry.gnome3}/bin/pinentry-gnome3
      '';
    })
  ]);
}
