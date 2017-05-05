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

  # Paths to WontFix packages, e.g. those which require newer GHC features
  broken = with rec {
    # Remove GHC versions prior to some release
    post74 = name: [
      [ "ghc704" name ]
      [ "ghc722" name ]
    ];
    post76 = name: post74 name ++ [
      [ "ghc742" name ]
    ];
    post78 = name: post76 name ++ [
      [ "ghc763" name ]
    ];
    post710 = name: base47 name ++ [
      [ "ghc783" name ]
      [ "ghc784" name ]
    ];

    # base >= 4.7 requires GHC >= 7.8
    base47 = post78;

    # base >= 4.8 requires GHC >= 7.10
    base48 = post710;

    # template-haskell >= 2.9 requires GHC >= 7.6.3
    th29 = post76;
  };
  base48  "ifcxt"              ++
  base48  "ghc-dup"            ++
  base48  "haskell-example"    ++
  base47  "weigh"              ++
  post710 "tip-types"          ++
  th29    "lazysmallcheck2012" ++
  post78  "ghc-simple"         ++
  post74  "tip-lib";

  noNulls = filterAttrsRecursive (_: v: v != null);

  # If a package is known to break, check that it does (otherwise we might be
  # ignoring perfectly valid targets!). Note that this will only check that the
  # package itself is broken; not whether or not it has working dependencies.
  checkBroken = noNulls (mapAttrsRecursiveCond
    (x: !(isDerivation x))
    (path: value: if elem path broken
                     then isBroken value
                     else value)
    ours);

  # There are loads of LTS versions, which take resources to process. We prefer
  # to check compiler versions rather than particular package sets.
  # GHC 6.12.3 is marked as broken, but for some reason is still included...
  stripLTS = filterAttrs (n: _: !(hasPrefix "lts" n) && n != "ghc6123");

  noLTS = stripLTS checkBroken // mapAttrs (_: stripLTS) {
                                      inherit (checkBroken) stable unstable;
                                    };
}; noLTS;

}; topLevel // { haskell = haskellPkgs; }
