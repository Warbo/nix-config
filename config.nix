{
  packageOverrides = pkgs: rec {
    # Custom packages
    panpipe        = pkgs.callPackage ./local/panpipe.nix        {};
    panhandle      = pkgs.callPackage ./local/panhandle.nix      {};
    whitey         = pkgs.callPackage ./local/whitey.nix         {};
    ml4pg          = pkgs.callPackage ./local/ml4pg.nix          {};
    bugseverywhere = pkgs.callPackage ./local/bugseverywhere.nix {};
    pidetop        = pkgs.callPackage ./local/pidetop.nix        {};

    # Default Haskell modules
    hsEnv = pkgs.haskellPackages.ghcWithPackagesOld (pkgs : [
       pkgs.xmonad
       pkgs.xmonadExtras
       pkgs.xmonadContrib
    ]);
  };
}
