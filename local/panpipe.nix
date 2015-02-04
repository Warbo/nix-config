{ stdenv, fetchgit, haskellPackages }:

stdenv.mkDerivation {
  name = "panpipe";

  src = fetchgit {
    url = git://gitorious.org/panpipe/panpipe.git;
    rev = "36e8537";
    sha256 = "0khp2dyi237f7pdxngnl3q3gg95h6ciwsz4705sch050aka3yvlw";
  };

  buildInputs = [ haskellPackages.ghc haskellPackages.pandoc ];

  buildPhase = ''
    ghc --make panpipe.hs
  '';

  installPhase = ''
    mkdir -p "$out/bin"
    cp panpipe "$out/bin/"
  '';
}