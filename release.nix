# Used for testing and building via Hydra or "nix-build"
with import <nixpkgs> { config = import ./config.nix; };
with builtins;
with lib;

let haskellPkgs = let selectedVersions = filterAttrs (version: _: !(hasPrefix "lts" version))
                                                     haskell.packages;

                      prefixed         = mapAttrs (version: hsPkgs:
                                                    mapAttrs' (name:
                                                                nameValuePair ("haskell-${name}-${version}"))
                                                              (filterAttrs (name: _:
                                                                             elem name haskellNames)
                                                                           hsPkgs))
                                                  selectedVersions;
                   in fold (x: y: x // y) {} (attrValues prefixed);

in haskellPkgs
