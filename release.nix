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
  keepOurs = pkgs:
    with rec {
      go = filterAttrs (name: _: elem name haskellNames);
    };
    mapAttrs (_: go) pkgs // mapAttrs (_: keepOurs) (stableUnstableFrom pkgs);

  versions = { inherit haskellPackages profiledHaskellPackages; } //
             haskell.packages;

  # Paths to WontFix packages, e.g. those which require newer GHC features
  broken = with rec {
    # Flags GHC versions older than some release
    post74  = name:                [ [ "ghc704" name ] [ "ghc722" name ] ];
    post76  = name: post74 name ++ [ [ "ghc742" name ]                   ];
    post78  = name: post76 name ++ [ [ "ghc763" name ]                   ];
    post710 = name: base47 name ++ [ [ "ghc783" name ] [ "ghc784" name ] ];

    # Flags GHC versions without some feature
    base47 = post78;   # base >= 4.7 requires GHC >= 7.8
    base48 = post710;  # base >= 4.8 requires GHC >= 7.10
    th29   = post76;   # template-haskell >= 2.9 requires GHC >= 7.6.3
  };
  # Packages which depend on recent GHC versions
  base48  "ifcxt"              ++
  base48  "ghc-dup"            ++
  base48  "haskell-example"    ++
  base47  "weigh"              ++
  post710 "tip-types"          ++
  th29    "lazysmallcheck2012" ++
  post78  "ghc-simple"         ++
  post74  "tip-lib";

  # Check that known breakages are, in fact, broken. Leave others as-is
  checkBroken = mapAttrsRecursiveCond
    (x: !(isDerivation x))
    (path: value: if elem path broken
                     then callPackage ({}: isBroken value) {}  # For .override
                     else value);

  stableUnstableFrom = sets:
    fold (name: result: if hasAttr name sets
                           then result // {
                                  "${name}" = sets."${name}";
                                }
                           else result)
         {}
         [ "stable" "unstable" ];

  # There are loads of LTS versions, which take resources to process. We prefer
  # to check compiler versions rather than particular package sets.
  # GHC 6.12.3 is marked as broken, so refuses to evaluate at all.
  stripLTS = sets:
    filterAttrs (n: _: !(hasPrefix "lts" n) && n != "ghc6123") sets //
    mapAttrs (_: stripLTS) (stableUnstableFrom sets);

  # Use tinc for dependencies. This gives us per-package dependencies, chosen
  # from hackage by cabal, written in the form of Nix expressions.
  tincified =
    mapAttrs (version: pkgs:
               if elem version [ "stable" "unstable" ]
                  then tincified pkgs
                  else mapAttrs (name: pkg: tincify {
                                              inherit (pkg) src;
                                              name = "${name}-${version}";
                                              haskellPackages = pkgs;
                                            })
                                pkgs);
}; keepOurs (checkBroken (tincified (stripLTS versions)));

}; topLevel // { haskell = haskellPkgs; }
