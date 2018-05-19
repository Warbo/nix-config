# Tests for our definitions. These should mostly exercise the actual definition,
# e.g. ensuring there are no type errors, maybe checking that something builds,
# etc. to ensure we've packaged them properly. They shouldn't test the real
# functionality of the actual programs/libraries/etc. since that should be done
# by the package's build script with the usual 'checkPhase' stuff.

with builtins;

{ pkgs ? (import <nixpkgs> { config = import ./config.nix; }) }:
with pkgs;
with lib;
rec {
  failDrv = name: runCommand name "exit 1";

  # Makes a derivation with the given value in its environment; checks whether
  # this causes the build to fail or not.
  tryInEnv = name: x: runCommand "try-${name}-in-env" { inherit x; }
                                 ''echo pass > "$out"'';

  ifDrv   = name: bool: runCommand name {} ''
    mkdir "$out"
    exit ${if bool then "0" else "1"}
  '';

  testWeHave = { label, wanted, have}: runCommand "have-${label}-tests"
    {
      inherit label;
      missing = filter (n: !(elem n have)) wanted;
    }
    ''
      for M in $missing
      do
        echo "Missing '$label' tests for $missing" 1>&2
        exit 1
      done
      echo pass > "$out"
    '';

  tryHaskellPackage = n: getAttr n haskellPackages;

  haskellTests =
    with rec {
      notMine = genAttrs [
        "genifunctors"
        "structural-induction"
        "lazysmallcheck2012"
        "ifcxt"
        "ghc-simple"
        "ghc-dup"
        "tip-lib"
        "tip-haskell-frontend-main"
        "tip-haskell-frontend"
        "tasty-ant-xml"
        "tasty"
        "tip-types"
        "geniplate"
      ] tryHaskellPackage;

      mine = (genAttrs [
        "ArbitraryHaskell"
        "AstPlugin"
        "HS2AST"
        "getDeps"
        "haskell-example"
        "lazy-lambda-calculus"
        "mlspec-helper"
        "nix-eval"
        "runtime-arbitrary"
        "runtime-arbitrary-tests"
      ] tryHaskellPackage);

      pkgTests = mine // notMine // {
        haveAllHaskellTests = testWeHave {
          label  = "haskell";
          wanted = haskellNames;
          have   = attrNames pkgTests;
        };
      };
    };
    pkgTests;

  TODO = genAttrs [
    "anonymous-pro-font"
    "beautifulsoup-custom"
    "citationstyles"
    "droid-fonts"
    "elcid"
    "feed2maildirsimple"
    "fetchGitHashless"
    "font-spacemono"
    "forceBuilds"
    "getNixpkgs"
    "ghcPackageEnv"
    "ghcTurtle"
    "google-api-python-client"
    "gscholar"
    "hackageDb"
    "hackageUpdate"
    "haskellGit"
    "haskellNames"
    "haskellOverrides"
    "haskellPackages"
    "helpers"
    "hfeed2atom"
    "inNixedDir"
    "isBroken"
    "jsbeautifier"
    "latestCabal"
    "latestCfgPkgs"
    "latestGit"
    "latestNixCfg"
    "lhasa"
    "md2pdf"
    "mergeDirs"
    "mf2py"
    "ml4pg"
    "newNixpkgsEnv"
    "nixFromCabal"
    "nixpkgs1603"
    "nixpkgs1609"
    "nixpkgs1703"
    "nixpkgs1709"
    "profiledHaskellPackages"
    "pypdf2"
    "python-lhafile"
    "repo2npm"
    "repoSource"
    "reverse"
    "runCabal2nix"
    "runScript"
    "sanitiseName"
    "scholar"
    "searchtobibtex"
    "skulpture"
    "stripOverrides"
    "suffMatch"
    "tipSrc"
    "translitcodec"
    "unpack"
    "unprofiledHaskellPackages"
    "unstableTipSrc"
    "uritemplate"
    "w3c-validator"
    "withArgs"
    "withArgsOf"
    "withDeps"
    "withLatestCfg"
    "withLatestGit"
    "withNix"
  ] (n: assert hasAttr n pkgs || abort "No attribute '${n}'";
        trace "TODO: no test for ${n} yet" nothing);

  tests = TODO // binaryProviders // {
    inherit nothing pidgin-privacy-please repo1603 repo1609 repo1703 repo1709
            stableHackageDb;

    allDrvsIn       = tryInEnv "allDrvsIn" (allDrvsIn { x = nothing; });

    attrsToDirs     = attrsToDirs { foo = { bar = ./test.nix; }; };

    backtrace       = runCommand "backtrace-test"
                        { buildInputs = [ backtrace fail ]; }
                        ''
                          X=$(NOTRACE=1 backtrace)
                          [[ -z "$X" ]] || fail "NOTRACE should suppress trace"

                          Y=$(backtrace)
                          for Z in "Backtrace" "End Backtrace" "bash"
                          do
                            echo "$Y" | grep -F "$Z" || fail "Didn't find '$Z'"
                          done

                          echo pass > "$out"
                        '';

    cabalField      = runCommand "cabalField-test"
                        {
                          found = cabalField {
                            dir   = unpack haskellPackages.text.src;
                            field = "name";
                          };
                        }
                        ''
                          [[ "x$found" = "xtext" ]] || {
                            echo "Got '$found' instead of 'text'" 1>&2
                            exit 1
                          }
                          mkdir "$out"
                        '';

    callPackage     = tryInEnv "callPackage" (callPackage ({ bash }: "x") {});

    composeWithArgs = tryInEnv "composeWithArgs"
                               (callPackage (composeWithArgs
                                               (x: x)
                                               ({ hello }: hello)) {});

    customPkgNames  = tryInEnv "customPkgNames" customPkgNames;

    dirContaining   = dirContaining ./custom [
                        ./custom/local.nix
                        ./custom/haskell.nix
                      ];

    dirsToAttrs     = runCommand "dirsToAttrs-test"
                        (dirsToAttrs (attrsToDirs {
                          x = ./custom/local/dirsToAttrs.nix; }))
                        ''
                          [[ -n "$x" ]]                      || exit 1
                          [[ -f "$x" ]]                      || exit 2
                          grep 'builtins' < "$x" > /dev/null || exit 3

                          echo "pass" > "$out"
                        '';

    dropWhile = tryInEnv "dropWhile" (dropWhile (x: x > 2) [ 5 4 3 2 1 ]);

    dummyBuild = dummyBuild "dummyBuildTest";

    hackagePackageNames = tryInEnv "hackagePackageNames"
                                   (typeOf hackagePackageNames);

    hackagePackageNamesDrv = hackagePackageNamesDrv;

    haskell         = withDeps (attrValues haskellTests)
                               (runCommand "haskell-tests" {} ''
                                 echo pass > "$out"
                               '');

    isCallable      = ifDrv "isCallable-test"
                            (isCallable (callPackage
                                          ({}: (x: abort "shouldn't force"))
                                          {}));

    isPath          = withDeps [
                        (ifDrv "relativePathIsPath" (isPath ./test.nix))
                        (ifDrv "absolutePathIsPath" (isPath /tmp      ))
                        (ifDrv "pathStringIsPath"   (isPath "/tmp"    ))
                        (ifDrv "stringIsNotPath"  (!(isPath "foo"    )))
                        (ifDrv "otherIsNotPath"   (!(isPath 42       )))
                      ] nothing;

    mkStableHackageDb =
      if elem "0.2.0.0" (mkStableHackageDb {}).versions.panhandle
         then nothing
         else failDrv "mkStableHackageDb-test";

    nixListToBashArray =
      with nixListToBashArray { name = "check"; args = [ "foo" ]; };
      runCommand "check-NLTBA" env ''
        ${code}
        echo pass > "$out"
      '';
  };

  testDrvs = tests // {
    customTests  = withDeps customTests nothing;
  };

  all = withDeps (attrValues testDrvs)
                 (runCommand "all-tests" {} ''echo pass > "$out"'');
}
