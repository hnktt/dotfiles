{ pkgs, ... }:

{
  appearance.fonts.enable = true;

  apps.emacs.enable = true;
  apps.firefox.enable = true;
  apps.direnv.enable = true;
  apps.git.enable = true;
  apps.zsh.enable = true;

  home.packages = with pkgs; [ ffmpeg ];

  home.stateVersion = "24.05";
}
