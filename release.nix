# Used for testing and building via Hydra or "nix-build"
with import <nixpkgs> { config = import ./config.nix; };
with builtins;
with lib;
with rec {
  # Needed by recursive builds inside derivations (used to isolate errors)
  cfg = latestGit { url = "http://chriswarbo.net/git/nix-config.git"; };

  # Select our custom packages/overrides, except for those which are buried in
  # larger sets
  topLevel = /*filterAttrs (_: x: x != null)*/ (genAttrs customPkgNames (name:
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
                          else let pkg = pkgs."${name}";
                                in if isDerivation pkg
                                      then pkg
                                      else null));

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
    # The oldest version of GHC we care about
    minVersion = "7.8";

    oursFrom = concatMap (path: map (name: path ++ [ name ]) haskellNames);

    # There are loads of LTS versions, which take resources to process. We
    # prefer to check compiler versions rather than particular package sets.
    # GHC 6.12.3 and GHCJS* are broken, but we don't really care.
    rejectVersion = path: any (f: f path) [
      (path: hasPrefix "lts"   (last path))
      (path: hasPrefix "ghcjs" (last path))
      (path: elem (last path) [ "ghc6123" "ghcCross" "stable" "unstable" ])
      (path: 1 > compareVersions (getAttrFromPath path pkgs).ghc.version
                                 minVersion)
    ];

    # Paths to Haskell package sets, starting from 'import <nixpkgs> {}'
    versions = [ [ "haskellPackages" ] [ "profiledHaskellPackages" ] ] ++
      filter (path: !(rejectVersion path))
             (concatLists [
               (map (x: [ "haskell" "packages"            x ])
                    (attrNames pkgs.haskell.packages))

               (map (x: [ "haskell" "packages" "stable"   x ])
                    (attrNames pkgs.haskell.packages.stable))

               (map (x: [ "haskell" "packages" "unstable" x ])
                    (attrNames pkgs.haskell.packages.unstable))
             ]);

    # Paths to WontFix packages, e.g. those which require newer GHC features
    broken = with rec {
      # Mark as broken for old GHC versions
      post710 = name: [ [ "ghc783" name ] [ "ghc784" name ] ];

      # Mark as broken for old language features
      base48 = post710;  # base >= 4.8
    };
    base48  "ifcxt"            ++
    base48  "ghc-dup"          ++
    base48  "haskell-example"  ++
    post710 "tip-types";

    nonHackageDeps = {
      AstPlugin = [ "HS2AST" ];
    };

    # Choose cache for Cabal and Tinc
    cache = if getEnv "NIX_REMOTE" == ""
               then trace ''info: No NIX_REMOTE set; assuming we are in
                                  restricted mode. Tincifying with a local
                                  cache. This is pure, but slower than a
                                  global cache.''
                          { cache = { global = false; path = hackageDb; }; }
               else {};  # Use default, global, settings

    drvsFor = map (path:
      with rec {
        shouldBreak = any (suffMatch path) broken;
        extras      = nonHackageDeps."${last path}" or [];
        dotted      = concatStringsSep ".";
        failIf      = c: if c then "exit 1" else "true";
        expr        = ''
          ${innerNixpkgs};
          tincify (${dotted path} // {
            haskellPackages = ${dotted (init path)};
            extras = with builtins;
                     fromJSON (readFile "${writeScript "extras.json"
                                                       (toJSON extras)}");
          })
        '';
      };
      {
        inherit path;
        value = runCommand "${concatStringsSep "_" path}"
          (withNix { inherit expr; })
          ''
            if nix-build --show-trace -E "$expr"
            then
              ${failIf   shouldBreak}
            else
              ${failIf (!shouldBreak)}
            fi
            echo "PASS" | tee "$out"
          '';
      });

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
  collectUp (drvsFor (oursFrom versions));
};
topLevel // haskell
