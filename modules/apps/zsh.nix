{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkMerge;
  inherit (pkgs) stdenv;

  cfg = config.apps.zsh;
in
{
  options.apps.zsh = {
    enable = mkEnableOption ''
      zsh
    '';
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.zsh.enable = true;
      programs.zsh.defaultKeymap = "viins";
      programs.zsh.dotDir = ".config/zsh";
      programs.zsh.enableCompletion = false;

      programs.zsh.dirHashes = {
        docs = "$HOME/Documents";
        dl = "$HOME/Downloads";
        repos = "$HOME/Documents/Repositories";
      };

      programs.zsh.history = {
        expireDuplicatesFirst = true;
        ignoreAllDups = true;
        path = "${config.xdg.dataHome}/zsh/zsh_history";
      };

      programs.zsh.plugins = [
        {
          name = "typewritten";
          src = pkgs.fetchFromGitHub {
            owner = "reobin";
            repo = "typewritten";
            rev = "6f78ec20f1a3a5b996716d904ed8c7daf9b76a2a";
            sha256 = "qiC4IbmvpIseSnldt3dhEMsYSILpp7epBTZ53jY18x8=";
          };
        }
        {
          name = "zsh-fast-syntax-highlighting";
          file = "fast-syntax-highlighting.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "zdharma-continuum";
            repo = "fast-syntax-highlighting";
            rev = "cf318e06a9b7c9f2219d78f41b46fa6e06011fd9";
            sha256 = "RVX9ZSzjBW3LpFs2W86lKI6vtcvDWP6EPxzeTcRZua4=";
          };
        }
      ];

      programs.zsh.envExtra = lib.concatLines [
        (lib.optionalString stdenv.isDarwin ''
          if [[ $(uname -m) == 'arm64' ]]; then
             eval "$(/opt/homebrew/bin/brew shellenv)"
          fi'')
      ];

      programs.zsh.initExtraBeforeCompInit = lib.concatLines [
        (lib.optionalString stdenv.isDarwin ''
          if [[ -d /opt/homebrew/share/zsh/site-functions ]]; then
            fpath+=/opt/homebrew/share/zsh/site-functions
          fi'')

        ''
          autoload -Uz compinit
          if [[ -n ${"ZDOTDIR:-$HOME"}/.zcompdump(N.mh+24) ]]; then
              compinit
          else
              compinit -C
          fi
        ''
      ];

      programs.zsh.initExtra = lib.concatLines [
        ''
          # Load history substring search
          source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
          bindkey '^[OA' history-substring-search-up
          bindkey '^[[A' history-substring-search-up
          bindkey '^[OB' history-substring-search-down
          bindkey '^[[B' history-substring-search-down''
      ];
    }
  ]);
}
