{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkMerge;
  inherit (pkgs) emacs29-pgtk fetchpatch stdenv;

  cfg = config.apps.emacs;

  emacs-darwin = emacs29-pgtk.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      # Fix OS window role (needed for window managers like yabai)
      (fetchpatch {
        url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/fix-window-role.patch";
        sha256 = "+z/KfsBm1lvZTZNiMbxzXQGRTjkCFO4QPlEK35upjsE=";
      })
      # Make Emacs aware of OS-level light/dark mode
      (fetchpatch {
        url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/system-appearance.patch";
        sha256 = "oM6fXdXCWVcBnNrzXmF0ZMdp8j0pzkLE66WteeCutv8=";
      })
    ];
  });

  useEmacs =
    e:
    e.pkgs.withPackages (epkgs: [
      (epkgs.treesit-grammars.with-grammars (grammars: [
        epkgs.tree-sitter-langs
        grammars.tree-sitter-nix
        grammars.tree-sitter-ocaml
      ]))
    ]);
in
{
  options.apps.emacs = {
    enable = mkEnableOption ''
      emacs
    '';
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf stdenv.isDarwin {
      programs.emacs = {
        enable = true;
        package = useEmacs emacs-darwin;
      };
    })
  ]);
}
