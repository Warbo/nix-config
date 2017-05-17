{ haskellPackages, runCabal2nix, tincify }:

# We use 1.17.2 for compatibility with panpipe 0.2 and panhandle 0.2
tincify (haskellPackages.callPackage (runCabal2nix {
          url = "cabal://pandoc-1.17.2";
        }) {})
