# Used for testing and building via Hydra or "nix-build"
let pkgs      = import <nixpkgs> { config = import ./other.nix; };
    overrides = import ./custom.nix pkgs;
in with builtins;
   with (pkgs // overrides);
   with lib;

let dbg     = x: trace (toJSON x) x;
    haskell = let selectedVersions = filterAttrs (version: _: elem version [ "ghc784" ])
                                                 overrides.haskell.packages;
                  selectedPkgs     = mapAttrs (version:
                                                filterAttrs (name: _:
                                                              elem name overrides.haskellNames))
                                              selectedVersions;

                  prefixed         = mapAttrs (version:
                                                mapAttrs' (name:
                                                            nameValuePair ("haskell-${name}-${version}")))
                                              selectedPkgs;
               in fold (x: y: x // y) {} (attrValues prefixed);

in haskell
