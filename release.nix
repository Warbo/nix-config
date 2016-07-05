# Used for testing and building via Hydra of "nix-build"
let pkgs      = import <nixpkgs> { config = import ./other.nix; };
    overrides = import ./custom.nix pkgs;
in with builtins;
   with (pkgs // overrides);
   with lib;

let haskell = let all = mapAttrs
                          (version: pkgs:
                             listToAttrs (map (p: {
                                                name  = "${p}-${version}";
                                                value = pkgs."${p}";
                                              })
                                              overrides.haskellNames))
                          (filterAttrs (n: _: elem n [ "ghc784" ])
                                       overrides.haskell.packages);
               in listToAttrs (fold (version: rest:
                                      fold (pkg: rest:
                                             rest ++ [{
                                               name  = "haskell-${pkg}";
                                               value = all."${version}"."${pkg}";
                                             }])
                                           rest
                                      (attrNames all."${version}"))
                                    []
                                    (attrNames all));

in haskell
