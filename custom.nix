# pkgs is the nixpkgs we're overriding: use it, but don't put it in the result.
# imports contains everything from ./imports: use it and put it in the result.
# imports.pkgs contains everything from ./pkgs: use it and put it in the result.
pkgs: imports:

let local = imports.local pkgs;
 in with local; with pkgs; with imports;

imports // local // rec {

  # Default version of Theory Exploration tools
  inherit (haskell-te) quickspec;

  # Other #
  #-------#

  haskellPackages = pkgs.haskellPackages.override {
    overrides = self: super: imports.haskellOverrides pkgs self;
  #    nix-eval         = self.callPackage (import /home/chris/Programming/Haskell/nix-eval) {};
  #    every-bit-counts = self.callPackage (import /home/chris/System/Packages/Haskell/ebc/new) {};
  };

  # To use profiled libraries, use: nix-shell --arg compiler '"profiled"'
  #haskell.packages.profiled = haskellPackages.override {
  #  overrides = self: super: {
  #    mkDerivation = args: super.mkDerivation (args // {
  #      enableLibraryProfiling = true;
  #    });
  #  };
  #};

  # Updated get_iplayer
  get_iplayer = stdenv.lib.overrideDerivation pkgs.get_iplayer (oldAttrs : {
    name = "get_iplayer";
    src  = fetchurl {
      url    = ftp://ftp.infradead.org/pub/get_iplayer/get_iplayer-2.94.tar.gz;
      sha256 = "16p0bw879fl8cs6rp37g1hgrcai771z6rcqk2nvm49kk39dx1zi4";
    };
    propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [
      perlPackages.XMLSimple
      ffmpeg
    ];
  });
}
