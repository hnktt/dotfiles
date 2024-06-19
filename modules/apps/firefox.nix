{ config, inputs, lib, pkgs, system, ... }:
let
  inherit (lib) isDarwin isLinux mkEnableOption mkIf mkMerge optionalAttrs;
  inherit (pkgs) callPackage stdenv;

  cfg = config.apps.firefox;
in
{
  options.apps.firefox = {
    enable = mkEnableOption ''
      Enable firefox
    '';
  };

  config =
    mkIf cfg.enable (mkMerge [
      { nixpkgs.overlays = [ inputs.nur.overlay ]; }
      {
        programs.firefox.enable = true;
        programs.firefox.policies = {
          EnableTrackingProtection = true;
          SearchEngines = {
            Default = "DuckDuckGo";
          };
        };

        programs.firefox.profiles."${config.home.username}" = {
          id = 0;
          isDefault = true;
          name = "${config.home.username}";

          search.force = true;
          search = {
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
            browserpass
          ];
        };
      }

      (mkIf (stdenv.isDarwin) {
        programs.firefox.package = callPackage ../../packages/firefox.nix { };
      })

      (mkIf (stdenv.isDarwin && config.apps.pass.enable) {
        home.activation = {
          browsepassFirefoxActivation = lib.hm.dag.entryAfter [ "writeBoundary" ]
            ''
              install -d -o ${config.home.username} -g staff $HOME/Library/Application\ Support/Mozilla/NativeMessagingHosts
              ln -sf \
                 ${pkgs.browserpass}/lib/mozilla/native-messaging-hosts/com.github.browserpass.native.json \
                 $HOME/Library/Application\ Support/Mozilla/NativeMessagingHosts/com.github.browserpass.native.json
            '';
        };
      })

      # TODO: move to gpg or pass module
      (mkIf (stdenv.isLinux && config.apps.pass.enable) {
        services.gpg-agent.extraConfig = ''
          pinentry-program ${pkgs.pinentry.gnome3}/bin/pinentry-gnome3
        '';


        programs.firefox.package = pkgs.firefox.override {
          nativeMessagingHosts = with pkgs; [
            gnome-browser-connector
            browserpass
          ];
        };

      })
    ]);
}
