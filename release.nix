# Used for testing and building via Hydra of "nix-build"
let pkgs      = import <nixpkgs> { config = import ./other.nix; };
    overrides = import ./custom.nix pkgs;
in with builtins;
   with (pkgs // overrides);
   with lib;

let haskell = let broken  = [ "ghc6123" ];
                  toUse   = [ "ghc784"  ];
                  working = filterAttrs (n: _: elem n toUse)
                                        overrides.haskell.packages;
                  all = mapAttrs
                          (version: pkgs:
                             listToAttrs (map (p: {
                                                name  = "${p}-${version}";
                                                value = trace "Version ${version}" pkgs."${p}";
                                              })
                                              overrides.haskellNames))
                          working;
                  lst = fold (version: rest:
                         fold (pkg: rest:
                                rest ++ [{
                                           name  = "haskell-${pkg}";
                                           value = all."${version}"."${pkg}";
                                        }])
                              rest
                              (attrNames all."${version}"))
                       []
                       (attrNames all);
               in listToAttrs lst;

in haskell
