# Used for testing and building via Hydra or "nix-build"
with import <nixpkgs> { config = import ./config.nix; };
with builtins;
with lib;

let

# Select our custom Haskell packages from the various sets of Haskell packages
# provided by nixpkgs (e.g. for different compiler versions)
haskellPkgs = let

  # Ignore less interesting package sets, e.g. "long-term support" ones
  selectedSets = filterAttrs (set: _: !(hasPrefix "lts" set))
                                   haskell.packages;

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
  in fold (x: y: x // y) {} (attrValues prefixed);

in haskellPkgs
