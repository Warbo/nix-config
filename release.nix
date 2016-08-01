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
                                  typeOf pkgs."${n}" == "set" &&
                                  pkgs."${n}" ? type          &&
                                  pkgs."${n}".type == "derivation")
                     customPkgNames;

topLevel = fold (name: rest: rest // { "${name}" = pkgs."${name}"; })
                {}
                customNames;

# Select our custom Haskell packages from the various sets of Haskell packages
# provided by nixpkgs (e.g. for different compiler versions)
haskellPkgs = let
  # Ignore less interesting package sets, e.g. "long-term support" ones
  ignore       = [
                   "ghc6123" "ghc704" "ghc722" "ghc742" "ghc763" "ghc783"
                   "ghcjs" "ghcNokinds"
                 ] ++ filter (set: hasPrefix "lts" set)
                             (attrNames haskell.packages);

  selectedSets = (filterAttrs (set: _: !(elem set ignore))
                                   haskell.packages) //
                 { inherit profiledHaskellPackages; };

  # Give our packages unique names, so different sets won't overlap
  suffixed     = mapAttrs (set: hsPkgs:
                            # Rename the package attributes for this set
                            mapAttrs' (name:
                                         nameValuePair ("haskell-${name}-${set}"))
                                      # Only select our custom packages
                                      (filterAttrs (name: _:
                                                     elem name haskellNames)
                                                   hsPkgs))
                          selectedSets;
  # Combine all of the selected packages for all of the selected sets
  in fold (x: y: x // y) {} (attrValues suffixed);

in topLevel // haskellPkgs
