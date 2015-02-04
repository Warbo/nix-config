{
  packageOverrides = pkgs: rec {
    panpipe   = pkgs.callPackage ./local/panpipe.nix {};
    panhandle = pkgs.callPackage ./local/panhandle.nix {};

    hsEnv = pkgs.haskellPackages.ghcWithPackagesOld (pkgs : [
       pkgs.xmonad
       pkgs.xmonadExtras
       pkgs.xmonadContrib
       # add more packages here
    ]);
  };
}
