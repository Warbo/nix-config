# Used for testing and building via Hydra or "nix-build"
with import <nixpkgs> { config = import ./config.nix; };
with builtins;
with lib;

let

# Select our custom packages/overrides, except for those which are buried in
# larger sets
customNames = filter (n: !(elem n [
                                    "stable"                  # Copy of nixpkgs
                                    "haskell"                 # Mostly not ours
                                    "haskellPackages"         # Ditto
                                    "profiledHaskellPackages" # Ditto
                                  ])                          &&
                         typeOf pkgs."${n}" == "set"          &&
                         pkgs."${n}" ? type                   &&
                         pkgs."${n}".type == "derivation")
                     customPkgNames;

topLevel = listToAttrs (map (name: {
                              inherit name;
                              value = pkgs."${name}";
                            })
                            customNames);

# Select our custom Haskell packages from the various sets of Haskell packages
# provided by nixpkgs (e.g. for different compiler versions)
haskellPkgs = let keepOurs = mapAttrs (_: filterAttrs (name: _:
                                                        elem name haskellNames));
                  top      = keepOurs {
                               inherit haskellPackages profiledHaskellPackages;
                               inherit (haskell.packages) ghc7103 ghc801;
                             };
                  unstable = keepOurs {
                               inherit (haskell.packages.unstable) ghc7103
                                       ghc801;
                             };
               in top // { inherit unstable; };

in topLevel // { haskell = haskellPkgs; }
