{ buildEnv, cabal-install, cabal2nix, ghcPackageEnv, hackageUpdate, haskell,
  haskellPackages, haskellTinc, latestGit, lib, newNixpkgsEnv, runCommand,
  stdenv, withNix, writeScript, runCabal2nix, unpack, withTincDeps }:

with builtins;
with lib;
with { defHPkg = haskellPackages; };

{ cache           ? { global = true; path = "/tmp/tincify-home"; },
  extras          ? [],
  haskellPackages ? defHPkg,
  name            ? "pkg",
  nixpkgs         ? import <nixpkgs> {},
  ... }@args:
  with rec {
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
                ${ghcPackageEnv haskellPackages
                                ([ "cabal-install" ] ++ extras)};
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

    tincified = runCommand "tinc-of-${name}"
      (newNixpkgsEnv env (withNix {
        src = unpack src;

        buildInputs = [
          cabal2nix
          (haskellPackages.ghcWithPackages (h: [ h.ghc h.cabal-install ]))
          haskellTinc
        ];

        TINC_USE_NIX = "yes";

        # If we're using a global cache, update it based on cache settings. If
        # we're not, this does nothing.
        cacheDep = if cache.global then hackageUpdate cache.path else nothing;

        # Should we share an impure cache with prior/subsequent calls?
        GLOBALCACHE = if cache.global then "true" else "false";

        # Where to find cached data; when global this should be a
        # string like "/tmp/foo". Non-global might be e.g. a path, or a
        # derivation.
        CACHEPATH = assert cache.global -> isString cache.path ||
                    abort ''Global cache path should be a string, to
                            prevent Nix copying it to the store.'';
                    cache.path;
      }))
      ''
        function allow {
          # Allows subsequent users to read/write our cached values
          # Note that we ignore errors because we may not own some of
          # the existing files.
          chmod 777 -R "$HOME" 2>/dev/null || true
        }

        if $GLOBALCACHE
        then
          # Use the cache in-place
          export HOME="$CACHEPATH"
        else
          # Use a mutable copy of the given cache
          cp -r "$CACHEPATH" ./cache
          allow
          export HOME="$PWD/cache"
        fi

        # Die if we have no cache
        [[ -d "$HOME" ]] || {
          echo "Cache dir '$HOME' not found" 1>&2
          exit 1
        }

        cp -r "$src" ./src
        chmod +w -R ./src

        pushd ./src; tinc; popd
        allow

        cp -r ./src "$out"
      '';
  };
  withTincDeps { inherit extras haskellPackages nixpkgs tincified; }
