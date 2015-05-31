with import <nixpkgs> {};

stdenv.mkDerivation {
  name    = "panpipe";

  version = "2015-05-28";

  src     = fetchgit {
    url = git://gitorious.org/panpipe/panpipe.git;
    rev = "361fd45";
    sha256 = "057f4gcfal59xqw91pv97428yb3fwi12zpfy0lr0l77n6ar4ly6c";
  };

  buildInputs = [
    haskellPackages.pandoc
    haskellPackages.pandoc-types
    pandocLib
    haskellPackages.temporary
    haskellPackages.ghc
  ];

  buildPhase = ''
    ghc --make panpipe.hs
  '';

  installPhase = ''
    mkdir -p "$out/bin"
    cp panpipe "$out/bin/"
  '';
}
