{stdenv, fetchgit, ocaml, camlp5, findlib, gcc, coq}:

stdenv.mkDerivation {
  name = "pidetop-0.1";

  src = fetchgit {
    url = https://bitbucket.org/Carst/pidetop.git;
    rev = "259235ed79391a172a93772d147d0f4a358ee9b2";
    sha256 = "1c9mk47brs86wihwkiqv08pv347q6pbsb00zihs7cbwyj09w9cns";
  };

  buildInputs = [ ocaml camlp5 findlib gcc coq ];

  configurePhase = ''
    export COQBIN=
    export DSTROOT="$out/"
    #export COQLIB="$out/"
    coq_makefile -f Make > Makefile
    sed -i 's/COQLIB}toploop/out}\/toploop/g' Makefile
    #sed -i '/COQDOCLIBS?=/a \
    #COQLIB="$out/"' Makefile
    echo "MAKEFILE START"
    cat Makefile
    echo "MAKEFILE END"
  '';

  buildPhase = ''
    make install-toploop
  '';

  meta = with stdenv.lib; {
    description = "Async command & control for Coq proof assistant";
  };
}
