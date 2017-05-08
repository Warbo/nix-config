{ cabal-install, cabal2nix, hackageDb, haskellPackages, haskellTinc, runCommand,
  withNix }:

with builtins;
with rec {
  defHPkg = haskellPackages;

  tincify = { src, name ? "pkg", haskellPackages ? defHPkg,
              pkgs ? import <nixpkgs> {} }:
    with rec {
      defs = runCommand "tinc-of-${name}"
               (withNix {
                 inherit src hackageDb;
                 buildInputs = [
                   cabal-install
                   haskellTinc
                   (haskellPackages.ghcWithPackages (h: [ h.ghc ]))
                   cabal2nix
                 ];
                 TINC_USE_NIX = "yes";
               })
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
