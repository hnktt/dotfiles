{ pkgs, ... }:

{
  appearance.fonts.enable = true;

  apps.firefox.enable = true;
  apps.git.enable = true;
  apps.zsh.enable = true;

  home.packages = with pkgs; [ wl-clipboard ];

  home.stateVersion = "24.05";
}
