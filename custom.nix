stable:

pkgs:

with builtins; with pkgs.lib;

let mkPkg      = x: oldPkgs:
                   let newPkgs = oldPkgs // import x overridden pkgs;
                    in newPkgs // {
                         # Keep a record of which packages are custom
                         customPkgNames = attrNames newPkgs;
                       };

    nixFiles   = let dir = ./custom;
                  in map (f: dir + "/${f}")
                         (filter (hasSuffix ".nix")
                                 (attrNames (readDir dir)));

    overridden = pkgs // overrides;

    overrides = fold mkPkg {} nixFiles;
 in overrides
