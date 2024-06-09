{ config, inputs, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (pkgs) emacs-pgtk emacsPackagesFor fetchpatch;

  emacsPkg = emacs-pgtk.overrideAttrs (old: {
    patches = (old.patches or [ ])
      ++ [
      # Fix OS window role (needed for window managers like yabai)
      (fetchpatch {
        url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/fix-window-role.patch";
        sha256 = "sha256-+z/KfsBm1lvZTZNiMbxzXQGRTjkCFO4QPlEK35upjsE=";
      })
      # Make Emacs aware of OS-level light/dark mode
      (fetchpatch {
        url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-30/system-appearance.patch";
        sha256 = "sha256-3QLq91AQ6E921/W9nfDjdOUWR8YVsqBAT/W9c1woqAw=";
      })
    ];
  });
  cfg = config.modules.emacs;
in
{
  options.modules.emacs = {
    enable = mkEnableOption ''
      	emacs
    '';
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = with inputs; [
      emacs-overlay.overlay
    ];

    home.packages = [
      ((emacsPackagesFor emacsPkg).emacsWithPackages
        (epkgs: with epkgs; [
          vterm
          treesit-grammars.with-all-grammars
        ]))
    ];
  };
}
