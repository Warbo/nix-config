# Used for testing and building via Hydra or "nix-build"
with builtins;
with rec {
  # The stable packages should always work; unstable shows us potential bit rot.
  unstable = import <nixpkgs>         { config = import ./unstable.nix; };
    stable = import unstable.repo1609 { config = import   ./stable.nix; };

  mkSet = pkgs:
    with pkgs;
    with lib;
    with rec {
      # Select our custom packages/overrides, except for those which are buried
      # in larger sets
      tooBig = name: hasPrefix "nixpkgs" name ||
                     hasPrefix "repo"    name ||
                     elem name [
                       "stableNixpkgs"             # Copy of nixpkgs
                       "stableRepo"                # Ditto
                       "haskell"                   # Mostly not ours
                       "haskellPackages"           # Ditto
                       "profiledHaskellPackages"   # Ditto
                       "unprofiledHaskellPackages" # Ditto
                       "unstableHaskellPackages"   # Ditto

                       # These are designed to break on unstable, so avoid them
                       "latestNixCfg"
                       "latestCfgPkgs"
                       "withLatestCfg"
                     ];
      drvName  = name: isDerivation (getAttr name pkgs);
      keepers  = name: !(tooBig name) && isDerivation (getAttr name pkgs);
      topLevel = genAttrs (filter keepers customPkgNames)
                          (name: getAttr name pkgs);

      # Select our custom Haskell packages from the various sets of Haskell
      # packages provided by nixpkgs (e.g. for different compiler versions)
      haskell =
        with rec {
          # GHC version ranges
          ghc7102 = [ [ "haskell" "packages" "ghc7102" ] ];
          ghc7103 = [ [ "haskell" "packages" "ghc7103" ] ];
          ghc710  = ghc7102 ++ ghc7103;
          ghc802  = [ [ "haskell" "packages" "ghc802"  ] ];
          ghc80   = [ [ "haskell" "packages" "ghc801"  ]
                      [ "haskellPackages"              ]
                      [ "profiledHaskellPackages"      ] ] ++ ghc802;

          post710 = ghc710 ++ post80;
          post80  = ghc80;

          # GHC versions with a particular feature set
          base48 = ghc710;

          # Which GHC versions a package should work under
          pkgGhcVersions =
            with rec {
              versions = {
                ArbitraryHaskell          = ghc710;
                AstPlugin                 = ghc710;
                genifunctors              = ghc710;
                geniplate                 = ghc710;
                getDeps                   = ghc710;
                ghc-dup                   = base48;
                ghc-simple                = ghc710;
                haskell-example           = base48;
                HS2AST                    = ghc710;
                ifcxt                     = base48;
                lazy-lambda-calculus      = ghc710;
                lazysmallcheck2012        = ghc710;
                ML4HSFE                   = ghc710;
                mlspec                    = ghc710;
                mlspec-helper             = ghc710;
                nix-eval                  = ghc710;
                runtime-arbitrary         = ghc710;
                runtime-arbitrary-tests   = ghc710;
                structural-induction      = ghc7103;
                tasty                     = ghc710;
                tasty-ant-xml             = ghc710;
                tinc                      = ghc802;
                tip-haskell-frontend      = ghc710;
                tip-haskell-frontend-main = ghc710;
                tip-lib                   = ghc710;
                tip-types                 = ghc710;
              };

              errorMessage = "pkgGhcVersions name not found";
              debugInfo    = toJSON {
                               inherit errorMessage haskellNames name;
                             };
              check        = name: elem name haskellNames || abort debugInfo;
            };
            assert all check (attrNames versions); versions;

          # Either they're not on Hackage, or nixpkgs version doesn't match
          extraDeps = {
            AstPlugin            = [ "HS2AST"             ];
            lazy-lambda-calculus = [ "lazysmallcheck2012" ];
            ML4HSFE              = [ "HS2AST"             ];
            mlspec               = [ "mlspec-helper"      ];
          };

          # Create attrset with all working versions of the named Haskell pkg
          getDrvs = name:
            with {
              versions = getAttr name pkgGhcVersions;
              addDrv   = path: set: setIn {
                inherit set;
                path  = path ++ [ name ];

                # Tincify each package, to ensure it gets the right dependencies
                value =
                  with rec {
                    fail   = abort (toJSON {
                               inherit name path;
                               message = "Couldn't find Haskell package";
                             });
                    hP     = attrByPath path fail pkgs;
                    pkg    = getAttr name hP;
                    extras = if hasAttr name extraDeps
                                then { extras = getAttr name extraDeps; }
                                else {};
                  };
                  tincify (pkg // extras // { haskellPackages = hP; }) {};
              };
            };
            fold addDrv {} (getAttr name pkgGhcVersions);
        };
        fold (name: recursiveUpdate (getDrvs name)) {} haskellNames;

      tests = import ./test.nix { inherit pkgs; };

      # Checking that things *do* build with known-good package sets is only
      # half the story: we should also check that we're right about things
      # failing with known-bad package sets. Otherwise we might end up avoiding
      # something or, even worse, implementing fragile workarounds, due to
      # "problems" which may no longer exist.
      #
      # Here we list all of the known ways that each package breaks.
      breakages =
        with rec {
          # Tincify 'pkgName' using the given 'haskellPackages', and look for a
          # dependency with the name 'depName'
          getTincDep = { depName, haskellPackages, pkgName }:
            with rec {
              pkg     = tincify (getAttr pkgName haskellPackages // {
                                  inherit haskellPackages;
                                }) {};
              allDeps = concatMap (attr: getAttr attr pkg) [
                "buildInputs" "nativeBuildInputs" "propagatedBuildInputs"
                "propagatedNativeBuildInputs"
              ];
              match    = dep: isAttrs dep && dep.name == depName;
              allFound = filter match allDeps;
              found    = unique allFound;
            };
            assert length found == 1 || abort (toJSON {
              inherit depName found pkgName;
              msg = "Couldn't find broken tinc dependency";
            });
            found;

          # Runs the given function across multiple Haskell package sets,
          # concatenating the results
          acrossHaskellVersions = f: concatMap
            (version: f (getAttr version pkgs.haskell.packages));

          # tip-lib causes a few packages to fail
          tipLibFail = pkgName: acrossHaskellVersions
            (haskellPackages: getTincDep {
              inherit haskellPackages pkgName;
              depName = "tip-lib-0.2.2";
            })
            [ "ghc7102" "ghc7103" ];
        };
        mapAttrs (n: ps: withDeps (map isBroken ps) (dummyBuild n)) {
          structural-induction = acrossHaskellVersions
            (haskellPackages: getTincDep {
              inherit haskellPackages;
              depName = "geniplate-0.6.0.0";
              pkgName = "structural-induction";
            })
            [ "ghc7102" "ghc7103" ];

          tip-haskell-frontend      = tipLibFail "tip-haskell-frontend";
          tip-haskell-frontend-main = tipLibFail "tip-haskell-frontend-main";
        };
    };
    topLevel // haskell // { inherit breakages; tests = tests.testDrvs; };
};
stable.lib.mapAttrs (_: mkSet) {
  inherit stable unstable;
}
