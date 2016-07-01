pkgs:

with builtins; with pkgs.lib;

let mkPkg    = x: old: old // import x pkgs;

    nixFiles = let dir = ./custom;
                in map (f: dir + "/${f}")
                       (filter (hasSuffix ".nix")
                               (attrNames (readDir dir)));

 in fold mkPkg {} nixFiles
