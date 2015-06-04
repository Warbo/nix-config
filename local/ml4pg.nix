with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "ml4pg";
  src  = fetchgit {
    name   = "ml4pg";
    url    = /home/chris/Programming/ML4PG;
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
  installPhase = ''
    mkdir -p $out/emacs/site-lisp
    cp -r $src $out/emacs/site-lisp/ml4pg
  '';

  shellHook = ''
    export CWD=$(pwd)
    export ML4PG_HOME="$CWD/"
  '';
}
