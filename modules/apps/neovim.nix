{ config, inputs, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf mkMerge;

  cfg = config.apps.neovim;
in
{
  options.apps.neovim = {
    enable = mkEnableOption ''
      Enable neovim
    '';
  };

  config = mkIf cfg.enable (mkMerge [
    { nixpkgs.overlays = [ inputs.neovim-overlay.overlays.default ]; }

    { programs.neovim.enable = true; }
  ]);
}
