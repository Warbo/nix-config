# Used for testing and building via Hydra or "nix-build"
let pkgs = import <nixpkgs> { config = import ./config.nix; };
in with builtins;
   with pkgs;
   with lib;

let dbg     = x: trace (toJSON x) x;
    haskell = let selectedVersions = filterAttrs (version: _: !(hasPrefix "lts" version))
                                                 pkgs.haskell.packages;

                  prefixed         = mapAttrs (version: hsPkgs:
                                                mapAttrs' (name:
                                                            nameValuePair ("haskell-${name}-${version}"))
                                                          (filterAttrs (name: _:
                                                                         elem name pkgs.haskellNames)
                                                                       hsPkgs))
                                              selectedVersions;
               in fold (x: y: x // y) {} (attrValues prefixed);

in haskell
