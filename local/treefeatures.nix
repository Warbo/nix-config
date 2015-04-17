{ stdenv, fetchgit, haskellPackages }:

stdenv.mkDerivation {
  name = "treefeatures";
  src  = fetchgit {
    url    = git://gitorious.org/tree-features/tree-features.git;
    rev    = "f80193c";
    sha256 = "0h3c9zw7zdqfkm4zbs0xqkfab2pbbcishamg56vlfxwphqrw9svr";
  };

  buildInputs = [
    haskellPackages.ghc
    haskellPackages.xml
    haskellPackages.QuickCheck
    haskellPackages.MissingH
  ];

  buildPhase = ''
    ghc --make processor.hs
  '';

  installPhase = ''
    mkdir -p "$out/bin"
    cp processor "$out/bin/"
  '';
}
