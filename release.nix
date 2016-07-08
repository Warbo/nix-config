# Used for testing and building via Hydra or "nix-build"
let pkgs      = import <nixpkgs> { config = import ./other.nix; };
    overrides = import ./custom.nix pkgs;
in with builtins;
   with (pkgs // overrides);
   with lib;

let dbg     = x: trace (toJSON x) x;
    haskell = let selectedVersions = filterAttrs (n: _: elem n [ "ghc784" ])
                                                 overrides.haskell.packages;
                  selectedPkgs     = mapAttrs (version:
                                                filterAttrs (name: _:
                                                              elem name overrides.haskellNames))
                                              selectedVersions;

                  prefixed         = mapAttrs (version: hsPkgs:
                                                mapAttrs' (name: pkg:
                                                            nameValuePair ("haskell-${name}-${version}")
                                                                          pkg)
                                                          hsPkgs)
                                              selectedPkgs;
               in fold (x: y: x // y) {} (attrValues prefixed);

in haskell
