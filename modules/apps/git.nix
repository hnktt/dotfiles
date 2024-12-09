{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.apps.git;
in
{
  options.apps.git = {
    enable = mkEnableOption ''
      Enable git
    '';
  };

  config = mkIf cfg.enable {
    programs.git.enable = true;
    programs.git.extraConfig = {
      core = {
        editor = "vim";
        whitespace = "trailing-space,space-before-tab";
      };
      user = {
        name = "Paul-Mathias Logue";
        email = "git@ethnarque.fr";
      };

      init.defaultBranch = "main";
    };
  };
}
