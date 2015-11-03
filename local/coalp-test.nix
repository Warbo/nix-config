{ mkDerivation, alex, ansi-wl-pprint, array, base, containers
, deepseq, directory, fetchgit, happy, hashable, haskeline, mtl
, optparse-applicative, parsec, process, stdenv, text, transformers
, unordered-containers
}:
mkDerivation {
  pname = "CoALP";
  version = "0.0.3";
  src = fetchgit {
    url = "git://github.com/frantisekfarka/CoALP.git";
    sha256 = "3b08c18ed5293316aece8271494e848afe35387626fc7f6b42ed0e45de0c23ed";
    rev = "5d7650281cd6aa534ed80b1c02e4db2a6c140e74";
  };
  isLibrary = true;
  isExecutable = true;
  buildDepends = [
    ansi-wl-pprint array base containers deepseq directory hashable
    haskeline mtl optparse-applicative parsec process text transformers
    unordered-containers
  ];
  buildTools = [ alex happy ];
  description = "Coalgebraic logic programming library";
  license = stdenv.lib.licenses.gpl3;
}
