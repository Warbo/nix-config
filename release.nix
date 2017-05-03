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

  breakages = {
    lazysmallcheck2012 = ghc: compareVersions ghc "7.0" == -1;
  };

  # Paths to WontFix packages, e.g. those which require newer GHC features
  broken = [
    [ "ghc6123" "lazysmallcheck2012" ]
  ];

  noNulls = filterAttrsRecursive (_: v: v != null);

  withoutBroken = noNulls (mapAttrsRecursiveCond
    (x: !(isDerivation x))
    (path: value: if elem path broken
                     then null
                     else value)
    ours);

  # There are loads of LTS versions, which take resources to process. We prefer
  # to check compiler versions rather than particular package sets.
  # GHC 6.12.3 is marked as broken, but for some reason is still included...
  stripLTS = filterAttrs (n: _: !(hasPrefix "lts" n) && n != "ghc6123");

  noLTS = stripLTS withoutBroken // mapAttrs (_: stripLTS) {
                                      inherit (withoutBroken) stable unstable;
                                    };
}; noLTS;

}; topLevel // { haskell = haskellPkgs; }
