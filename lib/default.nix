{ lib, ... }:
let
  inherit (lib)
    collect
    concatStringsSep
    mapAttrs
    mapAttrsRecursive
    ;
in

rec {
  getDir =
    dir:
    mapAttrs (file: type: if type == "directory" then getDir "${dir}/${file}" else type) (
      builtins.readDir dir
    );

  mkStringPathList =
    path:
    if lib.pathType path == "directory" then
      collect lib.isString (mapAttrsRecursive (path: _type: concatStringsSep "/" path) (getDir path))
    else
      [ path ];

  recursiveImports =
    dir:
    map (file: if lib.hasPrefix "/nix/store" file then file else dir + "/${file}") (
      lib.filter (file: lib.hasSuffix ".nix" file) (mkStringPathList dir)
    );
}
