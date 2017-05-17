{ haskellPackages, pandoc, tincify }:

tincify (haskellPackages.panpipe) { inherit pandoc; }
