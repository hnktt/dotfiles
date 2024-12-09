{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkMerge;
  inherit (pkgs) stdenv;

  cfg = config.apps.direnv;
in
{
  options.apps.direnv = {
    enable = mkEnableOption ''
      direnv
    '';
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.direnv.enable = true;
      programs.direnv.nix-direnv.enable = true;
    }

    (mkIf config.programs.zsh.enable { programs.direnv.enableZshIntegration = true; })
  ]);
}
