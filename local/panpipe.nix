{ stdenv, fetchgit, haskellPackages }:

stdenv.mkDerivation {
  name = "panpipe";

  src = fetchgit {
    url = git://gitorious.org/panpipe/panpipe.git;
    rev = "361fd45";
    sha256 = "057f4gcfal59xqw91pv97428yb3fwi12zpfy0lr0l77n6ar4ly6c";
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
