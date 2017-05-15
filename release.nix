# Used for testing and building via Hydra or "nix-build"
with import <nixpkgs> { config = import ./config.nix; };
with builtins;
with lib;
with rec {

  # Select our custom packages/overrides, except for those which are buried in
  # larger sets
  topLevel = /*filterAttrs (_: x: x != null)*/ (genAttrs customPkgNames (name:
               if elem name [
                    "stable"                  # Copy of nixpkgs
                    "haskell"                 # Mostly not ours
                    "haskellPackages"         # Ditto
                    "profiledHaskellPackages" # Ditto
                  ]
                  then null
                  else if elem name isolate
                          then buildInDrv name
                          else let pkg = pkgs."${name}";
                                in if isDerivation pkg
                                      then pkg
                                      else null));

  # Packages which may cause evaluation to fail
  isolate = [ "pandoc" "panpipe" "panhandle" ];

  # Build the package with the given name, but do so by invoking nix-build from
  # a derivation's build script. This way, if the package causes Nix's evaluator
  # to abort, only that package's build will be affected, and not e.g. an entire
  # Hydra jobset.
  buildInDrv = name: runCommand "drv-${sanitiseName name}" (withNix {}) ''
    nix-build -E 'with import <nixpkgs> {}; ${name}'
    echo "BUILDS" > "$out"
  '';

  # Select our custom Haskell packages from the various sets of Haskell packages
  # provided by nixpkgs (e.g. for different compiler versions)
  haskell = with rec {
    oursFrom = concatMap (path: map (name: path ++ [ name ]) haskellNames);

    # Paths to Haskell package sets, starting from import <nixpkgs> {}
    versions = concatLists [
      [ [ "haskellPackages" ] [ "profiledHaskellPackages" ] ]

      (map (x: [ "haskell" "packages" x ])
           (filter (n: !(elem n [ "stable" "unstable" ]))
                   (attrNames pkgs.haskell.packages)))

      (map (x: [ "haskell" "packages" "stable"   x ])
           (attrNames pkgs.haskell.packages.stable))

      (map (x: [ "haskell" "packages" "unstable" x ])
           (attrNames pkgs.haskell.packages.unstable))
    ];

    # Paths to WontFix packages, e.g. those which require newer GHC features
    broken = with rec {
      # Flags GHC versions older than some release
      post74  = name:                [ [ "ghc704" name ] [ "ghc722" name ] ];
      post76  = name: post74 name ++ [ [ "ghc742" name ]                   ];
      post78  = name: post76 name ++ [ [ "ghc763" name ]                   ];
      post710 = name: base47 name ++ [ [ "ghc783" name ] [ "ghc784" name ] ];

      # Flags GHC versions without some feature
      base45 = post74;   # base >= 4.5 requires GHC >= 7.4
      base47 = post78;   # base >= 4.7 requires GHC >= 7.8
      base48 = post710;  # base >= 4.8 requires GHC >= 7.10
      th29   = post76;   # template-haskell >= 2.9 requires GHC >= 7.6.3
    };
    concatMap base45 [
      "ArbitraryHaskell" "AstPlugin" "HS2AST" "ML4HSFE" "genifunctors"
      "geniplate" "getDeps" "mlspec" "mlspec-helper" "nix-eval" "panhandle"
      "panpipe" "runtime-arbitrary" "runtime-arbitrary-tests"
      "structural-induction" "tinc" "tip-haskell-frontend"
      "tip-haskell-frontend-main" ] ++
    base47  "weigh"            ++
    base48  "ifcxt"            ++
    base48  "ghc-dup"          ++
    base48  "haskell-example"  ++
    post710 "tip-types"        ++
    post78  "ghc-simple"       ++
    post74  "tip-lib"          ++
    th29    "lazysmallcheck2012";

    # There are loads of LTS versions, which take resources to process. We
    # prefer to check compiler versions rather than particular package sets.
    # GHC 6.12.3 and GHCJS* are broken, but we don't really care.
    stripLTS =  filter (path: let name = last path;
                               in !(hasPrefix "lts"   name) &&
                                  !(hasPrefix "ghcjs" name) &&
                                  !(elem name [ "ghc6123" "ghcCross" ]));

    drvsFor =
      with rec {
        dotted = concatStringsSep ".";

        mkExpr = path:
          with {
            cfg = latestGit {
              url = "http://chriswarbo.net/git/nix-config.git";
            };
            set = dotted (init path);
          };
          ''
            with import <nixpkgs> { config = import "${cfg}/config.nix"; };
            tincify (${dotted path} // {
              haskellPackages = ${set};
            })
          '';

        toAttr = path: {
          inherit path;
          value = runCommand (sanitiseName (toJSON path))
            (withNix {
              expr   = mkExpr path;
              broken = if elem path broken then "true" else "false";
            })
            ''
              function go {
                nix-build --show-trace -E "$expr"
              }

              if $broken
              then
                echo "Ensuring that '$expr' is broken" 1>&2
                if go
                then
                  echo "Error: expected '$expr' to fail!" 1>&2
                  exit 1
                fi
                echo "Success: '$expr' is broken, as we expected" 1>&2
                echo "BROKEN" > "$out"
              else
                echo "Ensuring that '$expr' builds" 1>&2
                go || exit 1
                echo "BUILDS" > "$out"
              fi
            '';
        };
      };
      map toAttr;

    setIn = path: value: set:
      with rec {
        name = head path;
        new  = if length path == 1
                  then value
                  else setIn (tail path) value (set."${name}" or {});
      };
      set // { "${name}" = new; };

    collectUp = fold ({ path, value }: setIn path value) {};
  };
  collectUp (drvsFor (oursFrom (stripLTS versions)));
};
topLevel // { inherit haskell; }
