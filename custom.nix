pkgs:

with builtins; with pkgs.lib;

let mkPkg      = x: old: old // import x overridden pkgs;

    nixFiles   = let dir = ./custom;
                  in map (f: dir + "/${f}")
                         (filter (hasSuffix ".nix")
                                 (attrNames (readDir dir)));

    overridden = pkgs // overrides;

    overrides = fold mkPkg {} nixFiles;
 in overrides