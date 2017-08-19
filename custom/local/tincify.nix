{ cabal2nix, ghcPackageEnv, glibcLocales, haskellPackages, haskellTinc, jq,
  lib, newNixpkgsEnv, nixListToBashArray, runCommand, stableHackageDb, unpack,
  withNix, withTincDeps, writeScript, yq }:

with builtins;
with lib;
with { defHPkg = haskellPackages; };
{
  # Where to find cached tinc/cabal data. If global, we'll use it in place and
  # potentially update/overwrite it; otherwise we'll use a copy. We try to use a
  # global cache by default, since it's faster; unless we're on Hydra.
  cache           ? if getEnv "NIX_REMOTE" == ""
                       then { global = false; path = stableHackageDb;     }
                       else { global = true;  path = "/tmp/tincify-home"; },

  # Names of extra dependencies to include in the resulting Haskell package set;
  # useful for things which are in your Nix haskellPackages but not in Hackage.
  extras          ? [],

  # Whether to include the given 'extras' in the result using ghcWithPackages.
  includeExtras   ? false,

  # The Hackage DB for Cabal to use, if cache.global is true:
  #  - stableHackageDb is built from a fixed revision of all-cabal-files. This
  #    means it's a constant, deterministic value which Nix caches nicely.
  #  - hackageDb runs 'cabal update' to get the latest versions. This doesn't
  #    cache well, which causes a lot of extraneous rebuilding.
  hackageContents ? stableHackageDb,

  # Haskell package set to use as a base. 'extras' names should appear in here.
  haskellPackages ? defHPkg,

  # Name to use for the resulting package
  name            ? "pkg",

  # A nixpkgs set, used for non-haskell dependencies (e.g. zlib)
  nixpkgs         ? import <nixpkgs> {},

  # We allow other attributes, so Haskell package derivations can be passed in
  # (giving us 'name' and 'src')
  ... }@args:
  with rec {
    # The Haskell package source to run tinc against. Seems to behave funny when
    # specified in the arguments above, so we inherit it here instead.
    inherit (args) src;

    # By default, tinc runs Cabal in a Nix shell with the following available:
    #
    #   haskellPackages.ghcWithPackages (p: [ p.cabal-install ])'
    #
    # This can be fiddled a bit using TINC_NIX_RESOLVER, but overall we're
    # stuck using a Haskell package set that's available globally with a
    # particular attribute path. We don't want that; we want to use the
    # Haskell package set we've been given (haskellPackages), which might not
    # be available globally.
    #
    # To make tinc use this version, we rely on the fact it's only using
    # cabal-install, as above. We build that derivation, using our Haskell
    # package set, write it to disk, then set NIX_PATH such that tinc's
    # nix-shell invocation uses the derivation we built. Phew!
    env = runCommand "tinc-env"
      {
        expr = writeScript "force-tinc-env.nix" ''
          _:
            import <real> {} // {
            haskellPackages = {
              ghcWithPackages = _:
                ${ghcPackageEnv haskellPackages [ "cabal-install" ]};
            };
          }
        '';
      }
      ''
        mkdir -p "$out/pkgs/build-support/fetchurl"
        cp "$expr" "$out/default.nix"
        cp "${<nixpkgs/pkgs/build-support/fetchurl/mirrors.nix>}" \
           "$out/pkgs/build-support/fetchurl/mirrors.nix"
      '';

    extraSrc = {
      names = nixListToBashArray {
        name = "extraSourceNames";
        args = extras;
      };
      paths = nixListToBashArray {
        name = "extraSourcePaths";
        args = map (name: unpack (getAttr name haskellPackages).src) extras;
      };
    };

    tincified = runCommand "tinc-of-${name}"
      (newNixpkgsEnv env (withNix (extraSrc.names.env // extraSrc.paths.env // {
        inherit hackageContents;

        src = unpack src;

        buildInputs = [
          cabal2nix
          (haskellPackages.ghcWithPackages (h: [ h.ghc h.cabal-install ]))
          haskellTinc
          yq
          jq
        ];

        TINC_USE_NIX = "yes";

        # Should we share an impure cache with prior/subsequent calls?
        GLOBALCACHE = if cache.global then "true" else "false";

        # Where to find cached data; when global this should be a
        # string like "/tmp/foo". Non-global might be e.g. a path, or a
        # derivation.
        CACHEPATH = assert cache.global -> isString cache.path ||
                    abort ''Global cache path should be a string, to
                            prevent Nix copying it to the store.'';
                    cache.path;

        # Otherwise cabal2nix dies for accented characters
        LANG           = "en_US.UTF-8";
        LOCALE_ARCHIVE = "${glibcLocales}/lib/locale/locale-archive";
      })))
      ''
        ${extraSrc.names.code}
        ${extraSrc.paths.code}

        function allow {
          # Allows subsequent users to read/write our cached values
          # Note that we ignore errors because we may not own some of
          # the existing files.
          chmod 777 -R "$HOME" 2>/dev/null || true
        }

        function listExtraSources {
          for NPLUSONE in $(seq 1 "''${#extraSourceNames[@]}")
          do
            N=$(( NPLUSONE - 1 ))

            jq --arg name "''${extraSourceNames[$N]}" \
               --arg path "''${extraSourcePaths[$N]}" \
               -n '{"name": $name, "path": $path}'
          done
        }

        addSources="$PWD/tinc.json"

        jq -n --slurpfile deps <(listExtraSources) \
              '{"dependencies": $deps}' > "$addSources"

        mkdir -p "$out"

        if $GLOBALCACHE
        then
          # Use the cache in-place
          export HOME="$CACHEPATH"

          # (Re-)Initialise the cache's Hackage contents
          cp -r "$hackageContents"/.cabal "$HOME"/
        else
          # Use a mutable copy of the given cache
          cp -r "$CACHEPATH" "$out/cache"
          export HOME="$out/cache"
          allow
        fi

        [[ -d "$HOME" ]] || {
          echo "Cache dir '$HOME' not found" 1>&2
          exit 1
        }

        cp -r "$src" "$out/src"
        chmod +w -R "$out/src"

        pushd "$out/src"
          if ${if extras == [] then "false" else "true"}
          then
            echo "Adding extra sources" 1>&2
            if [[ -f tinc.yaml ]]
            then
              echo "Merging dependencies into tinc.yaml"
              mv tinc.yaml tinc.yaml.orig
              yq --yaml-output '. * $deps' --argfile deps "$addSources" \
                 < tinc.yaml.orig > tinc.yaml
            else
              yq --yaml-output '$deps' --argfile deps "$addSources" > tinc.yaml
            fi
          fi

          tinc
        popd

        allow
      '';
  };
  withTincDeps {
    inherit extras haskellPackages includeExtras nixpkgs;
    tincified = runCommand "tincified-src-of-${name}" { inherit tincified; } ''
      ln -s "$tincified/src" "$out"
    '';
  }
