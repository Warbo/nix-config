# Used for testing and building via Hydra or "nix-build"
with import <nixpkgs> { config = import ./config.nix; };
with builtins;
with lib;
with rec {

# Select our custom packages/overrides, except for those which are buried in
# larger sets
customNames = filter (n: !(elem n [
                                    "stable"                  # Copy of nixpkgs
                                    "haskell"                 # Mostly not ours
                                    "haskellPackages"         # Ditto
                                    "profiledHaskellPackages" # Ditto
                                  ])                          &&
                         isDerivation pkgs."${n}")
                     customPkgNames;

topLevel = listToAttrs (map (name: {
                              inherit name;
                              value = pkgs."${name}";
                            })
                            customNames);

# Select our custom Haskell packages from the various sets of Haskell packages
# provided by nixpkgs (e.g. for different compiler versions)
haskellPkgs = with rec {
  keepOurs = filterAttrs (name: _: elem name haskellNames);

  versions = { inherit haskellPackages profiledHaskellPackages; } //
             haskell.packages;

  ours = mapAttrs (n: if n == "stable" || n == "unstable"
                         then mapAttrs (_: keepOurs)
                         else keepOurs)
                  versions;
}; ours;

}; topLevel // { haskell = haskellPkgs; }
