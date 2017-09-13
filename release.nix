# Used for testing and building via Hydra or "nix-build"
with { nixpkgs = import <nixpkgs> { config = import ./config.nix; }; };
with nixpkgs;
with builtins;
with lib;
with rec {
  # Needed by recursive builds inside derivations (used to isolate errors)
  cfg = latestGit { url = "http://chriswarbo.net/git/nix-config.git"; };

  # Select our custom packages/overrides, except for those which are buried in
  # larger sets
  topLevel = genAttrs customPkgNames (name:
               if elem name [
                    "stable"                    # Copy of nixpkgs
                    "stableRepo"                # Ditto
                    "haskell"                   # Mostly not ours
                    "haskellPackages"           # Ditto
                    "profiledHaskellPackages"   # Ditto
                    "unprofiledHaskellPackages" # Ditto
                    "unstableHaskellPackages"   # Ditto
                  ]
                  then null
                  else if elem name isolate
                          then buildInDrv name
                          else let pkg = getAttr name nixpkgs;
                                in if isDerivation pkg
                                      then pkg
                                      else null);

  # Packages which may cause evaluation to fail
  isolate = [
    "all" "basic" "getDeps" "ghcast" "ML4HSFE" "mlspec" "pandoc" "panpipe"
    "panhandle"
  ];

  innerNixpkgs = ''with import <nixpkgs> {
                     config = import "${cfg}/config.nix";
                   }'';

  # Build the package with the given name, but do so by invoking nix-build from
  # a derivation's build script. This way, if the package causes Nix's evaluator
  # to abort, only that package's build will be affected, and not e.g. an entire
  # Hydra jobset.
  buildInDrv = name: runCommand "drv-${sanitiseName name}"
    (withNix {
      expr = "${innerNixpkgs}; ${name}";
    })
    ''
      nix-build -E "$expr"
      echo "BUILDS" > "$out"
    '';

  # Select our custom Haskell packages from the various sets of Haskell packages
  # provided by nixpkgs (e.g. for different compiler versions)
  haskell = with rec {
    # GHC version ranges
    post710 = [ [ "haskell" "packages" "ghc7102" ]
                [ "haskell" "packages" "ghc7103" ] ] ++ post8;
    post8   = [ [ "haskell" "packages" "ghc801"  ]
                [ "haskell" "packages" "ghc802"  ]
                [ "haskellPackages"              ]
                [ "profiledHaskellPackages"      ] ];

    # GHC versions with a particular feature set
    base48 = post710;

    # Which GHC versions a package should work under
    pkgGhcVersions =
      with rec {
        versions = {
          ArbitraryHaskell          = post710;
          AstPlugin                 = post710;
          genifunctors              = post710;
          geniplate                 = post710;
          getDeps                   = post710;
          ghc-dup                   = base48;
          ghc-simple                = post710;
          haskell-example           = base48;
          HS2AST                    = post710;
          ifcxt                     = base48;
          lazy-lambda-calculus      = post710;
          lazysmallcheck2012        = post710;
          ML4HSFE                   = post710;
          mlspec                    = post710;
          mlspec-helper             = post710;
          nix-eval                  = post710;
          panhandle                 = post710;
          panpipe                   = post710;
          runtime-arbitrary         = post710;
          runtime-arbitrary-tests   = post710;
          structural-induction      = post710;
          tasty                     = post710;
          tasty-ant-xml             = post710;
          tinc                      = post710;
          tip-haskell-frontend      = post710;
          tip-haskell-frontend-main = post710;
          tip-lib                   = post710;
          tip-types                 = post710;
        };

        errorMessage = "pkgGhcVersions name not found";
        debugInfo    = toJSON { inherit errorMessage haskellNames name; };
        check        = name: elem name haskellNames || abort debugInfo;
      };
      assert all check (attrNames versions); versions;

    # Either because they're not on Hackage, or nixpkgs version doesn't match
    extraDeps = {
      AstPlugin = [ "HS2AST" ];
      ML4HSFE   = [ "HS2AST" ];
    };

    # Create attrset containing all working versions of the named Haskell pkg
    getDrvs = name:
      with {
        versions = getAttr name pkgGhcVersions;
        addDrv   = path: set: setIn {
          inherit set;
          path  = path ++ [ name ];
          value = attrByPath (path ++ [ name ])
                             (abort (toJSON {
                               inherit name path;
                               message = "Failed to find Haskell pkg";
                             }))
                             pkgs;
        };
      };
      fold addDrv {} (getAttr name pkgGhcVersions);

    ours = fold (name: recursiveUpdate (getDrvs name)) {} haskellNames;
  };
  ours;

  tests = import ./test.nix;
};
filterAttrs (_: x: x != null)
            (topLevel // haskell // { tests = tests.testDrvs; })
