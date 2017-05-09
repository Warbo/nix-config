{ buildEnv, cabal2nix, hackageDb, haskellPackages, haskellTinc, runCommand,
  withNix, writeScript }:

with builtins;
with rec {
  defHPkg = haskellPackages;

  tincify = { src, name ? "pkg", haskellPackages ? defHPkg,
              pkgs ? import <nixpkgs> {} }:
    with rec {
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
      toUse = buildEnv {
        name  = "tinc-env";
        paths = [ (haskellPackages.ghcWithPackages (p: [ p.cabal-install ])) ];
      };

      env = runCommand "tinc-env"
        {
          expr = writeScript "force-tinc-env.nix" ''
            _:
              import <real> {} // {
              haskellPackages = {
                ghcWithPackages = _:
                  ${toUse};
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

      NIX_PATH = concatStringsSep ":" [
        "nixpkgs=${env}"
        "real=${(head (filter (p: p.prefix == "nixpkgs")
                              nixPath)).path}"
      ];

      defs = runCommand "tinc-of-${name}"
               (withNix {
                 inherit src hackageDb;
                 buildInputs = [
                   haskellTinc
                   (haskellPackages.ghcWithPackages (h: [
                     h.ghc
                     h.cabal-install
                   ]))
                   cabal2nix
                 ];
                 TINC_USE_NIX = "yes";
               } // {
                 inherit NIX_PATH; })
               ''
                 cp -r "$hackageDb" ./home
                 chmod +w -R ./home
                 export HOME="$PWD/home"

                 cp -r "$src" ./src
                 chmod +w -R ./src

                 pushd ./src; tinc; popd

                 cp -r ./src "$out"
               '';

      deps = import "${defs}/tinc.nix" {
        nixpkgs = pkgs // { inherit haskellPackages; };
      };
    };
    deps.resolver.callPackage "${defs}/package.nix" {};
};
tincify
