# Used for testing and building via Hydra or "nix-build"
with import <nixpkgs> { config = import ./config.nix; };
with builtins;
with lib;
with rec {

  # Select our custom packages/overrides, except for those which are buried in
  # larger sets
  topLevel = genAttrs customPkgNames (name:
               if elem name [
                    "stable"                  # Copy of nixpkgs
                    "haskell"                 # Mostly not ours
                    "haskellPackages"         # Ditto
                    "profiledHaskellPackages" # Ditto
                  ]
                  then null
                  else let pkg = pkgs."${name}";
                        in if isDerivation pkg
                              then pkg
                              else null);

  # Select our custom Haskell packages from the various sets of Haskell packages
  # provided by nixpkgs (e.g. for different compiler versions)
  haskell = with rec {
    keepOurs = pkgs:
      with rec { go = filterAttrs (name: _: elem name haskellNames); };
      mapAttrs (_: go) pkgs // mapAttrs (_: keepOurs) (stableUnstableFrom pkgs);

    versions = { inherit haskellPackages profiledHaskellPackages; } //
               pkgs.haskell.packages;

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

    # Check that known breakages are, in fact, broken. Leave others as-is.
    checkBroken = mapAttrsRecursiveCond
      (x: !(isDerivation x))
      (path: value: if elem path broken
                       then null #isBroken value
                       else value);

    stableUnstableFrom = sets:
      fold (name: result: if hasAttr name sets
                             then result // {
                                    "${name}" = sets."${name}";
                                  }
                             else result)
           {}
           [ "stable" "unstable" ];

    # There are loads of LTS versions, which take resources to process. We
    # prefer to check compiler versions rather than particular package sets.
    # GHC 6.12.3 and GHCJS* are broken, but we don't really care.
    stripLTS = sets:
      filterAttrs (n: _: !(hasPrefix "lts"   n) &&
                         !(hasPrefix "ghcjs" n) &&
                         !(elem n [ "ghc6123" ]))
                  sets //
      mapAttrs (_: stripLTS) (stableUnstableFrom sets);

    # The dependencies of these can't be satisfied by Cabal
    unsatisfiable = [
      [ "ghc704" "ifcxt" ]
    ];

    # If 'go' is false, returns a derivation whose builder will run nix with 'go'
    # as true. This lets us verify that a package fails to evaluate, whilst
    # isBroken only verifies that it refuses to build.
    unsatisfied = path: pkg:
      with rec {
        e       = "NIX_RUN_UNSATISFIED";

        go      = getEnv e != "";

        ePath   = concatStringsSep "." (["haskell"] ++ path);

        expr    = "(import ${./release.nix}).${ePath}";

        recurse = runCommand "unsatisfied-${pkg.name}"
                    (withNix { "${e}" = "TRUE"; })
                    ''
                      if nix-build -E '${expr}'
                      then
                        echo "Should have failed" 1>&2
                        exit 1
                      fi
                      touch "$out"
                    '';
      };
      if go
         then pkg
         else recurse;

    # Use tinc for dependencies. This gives us per-package dependencies, chosen
    # from hackage by cabal, written in the form of Nix expressions. Unfortunately
    # unsatisfiable dependencies will cause an uncatchable evaluation error rather
    # than a build error; we use 'unsatisfied' to turn these into build errors, to
    # prevent disrupting the building of everything else.
    checkDependencies = prefix:
      mapAttrs (version: pkgs:
                 if elem version [ "stable" "unstable" ]
                    then checkDependencies (prefix ++ [version]) pkgs
                    else mapAttrs (name: pkg:
                                    with {
                                      path      = prefix ++ [name];
                                      tincified = tincify (pkg // {
                                        haskellPackages = pkgs;
                                      });
                                    };
                                    if true /*elem path unsatisfiable*/
                                       then unsatisfied path tincified
                                       else tincified)
                                  pkgs);
  }; keepOurs (checkBroken (checkDependencies [] (stripLTS versions)));

  # Force some packages to be evaluated inside a derivation, since they can kill
  # the evaluator and prevent everything else working. This is fine for globally
  # defined packages, since we can just reference them in the shell by name.
  isolated = mapAttrs (n: v: if elem n [ "panhandle" ]
                                then runCommand "isolated-${n}" (withNix {}) ''
                                       set -e
                                       R=$(nix-build -E \
                                             '(import <nixpkgs> {}).${n}')
                                       ln -s "$R" "$out"
                                     ''
                                else v)
                      topLevel;
};
isolated // { inherit haskell; }
