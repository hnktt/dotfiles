{ config, inputs, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf mkMerge;

  cfg = config.modules.neovim;
in
{
  options.modules.neovim = {
    enable = mkEnableOption ''
      Enable neovim
    '';
  };

  config = mkIf cfg.enable (mkMerge [
    { nixpkgs.overlays = [ inputs.neovim-overlay.overlays.default ]; }

    { programs.neovim.enable = true; }
  ]);
}
