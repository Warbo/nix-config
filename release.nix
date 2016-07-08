# Used for testing and building via Hydra or "nix-build"
let pkgs      = import <nixpkgs> { config = import ./other.nix; };
    overrides = import ./custom.nix pkgs;
in with builtins;
   with (pkgs // overrides);
   with lib;

let dbg     = x: trace (toJSON x) x;
    haskell = let selectedVersions = filterAttrs (version: _: !(hasPrefix "lts" version))
                                                 overrides.haskell.packages;

                  prefixed         = mapAttrs (version: hsPkgs:
                                                mapAttrs' (name:
                                                            nameValuePair ("haskell-${name}-${version}"))
                                                          (filterAttrs (name: _:
                                                                         elem name overrides.haskellNames)
                                                                       hsPkgs))
                                              selectedVersions;
               in fold (x: y: x // y) {} (attrValues prefixed);

in haskell
