{ haskellPackages, tincify }:

tincify {
  inherit haskellPackages;
  inherit (haskellPackages.panpipe) name src;
}
