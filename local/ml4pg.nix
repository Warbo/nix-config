with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "ml4pg";
  src  = fetchgit {
    url    = git://gitorious.org/ml4pg/ml4pg.git;
    rev    = "1d45cf9";
    sha256 = "1icca9mpa819nvlljq70cm0f6a88wldh2zkn28mjgvqgsxv007j0";
  };
  buildInputs = [
    jre
    emacs
    emacs24Packages.proofgeneral
    graphviz
    coq
  ];
  builder = ./ml4pg-builder.sh;
  shellHook = ''
    export CWD=$(pwd)
    export ML4PG_HOME="$CWD/"
  '';
}
