# Used for testing and building via Hydra of "nix-build"
let pkgs      = import <nixpkgs> { config = import ./other.nix; };
    overrides = import ./custom.nix pkgs;
in with builtins;
   with (pkgs // overrides);
   with lib;

{

 haskell = buildEnv {
   name  = "custom-haskell";
   paths = let broken  = [ "ghc6123" ];
               working = filterAttrs (n: _: !(elem n broken))
                                     overrides.haskell.packages;
               all = mapAttrs
                       (version: pkgs:
                          listToAttrs (map (p: {
                                             name  = "${p}-${version}";
                                             value = trace "Version ${version}" pkgs."${p}";
                                           })
                                           overrides.haskellNames))
                       working;
            in concatMap attrValues (attrValues all);
 };

}
