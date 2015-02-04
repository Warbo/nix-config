{ stdenv, fetchgit, haskellPackages }:

stdenv.mkDerivation {
  name = "panhandle";

  src = fetchgit {
    url = git://gitorious.org/pan-handler/pan-handler.git;
    rev = "541c94f";
    sha256 = "1n93lmq13vqfinndr34cvm5vy2yk8h3xa7d2ipbacgxdnqkni9yl";
  };

  buildInputs = [ haskellPackages.ghc haskellPackages.pandoc ];

  buildPhase = ''
    ghc --make panhandle.hs
  '';

  installPhase = ''
    mkdir -p "$out/bin"
    cp panhandle "$out/bin/"
  '';
}