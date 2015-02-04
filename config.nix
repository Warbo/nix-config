{
  packageOverrides = pkgs: rec {
    # Custom packages
    panpipe        = pkgs.callPackage ./local/panpipe.nix        {};
    panhandle      = pkgs.callPackage ./local/panhandle.nix      {};
    whitey         = pkgs.callPackage ./local/whitey.nix         {};
    ml4pg          = pkgs.callPackage ./local/ml4pg.nix          {};
    bugseverywhere = pkgs.callPackage ./local/bugseverywhere.nix {};
    pidetop        = pkgs.callPackage ./local/pidetop.nix        {};

    # Override get_iplayer version
    get_iplayer = pkgs.stdenv.lib.overrideDerivation pkgs.get_iplayer (oldAttrs : {
      name = "get_iplayer-2.90";
      src.url    = ftp://ftp.infradead.org/pub/get_iplayer/get_iplayer-2.90.tar.gz;
      src.sha256 = "1zqx8sw3kafyia1gca8z782fmd44af6s6firxa0k2yfn8rgvv6qh";
    });

    # Default Haskell modules
    hsEnv = pkgs.haskellPackages.ghcWithPackagesOld (pkgs : [
       pkgs.xmonad
       pkgs.xmonadExtras
       pkgs.xmonadContrib
    ]);
  };
}
