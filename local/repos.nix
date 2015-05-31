with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "repos";
  src  = /home/chris/Programming/repos;

  buildPhase = "";
  installPhase = ''
    cp -ar * $out/
  '';
}
