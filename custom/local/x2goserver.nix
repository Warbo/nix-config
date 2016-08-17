{ bash, fetchurl, perl, perl-config-simple, stdenv, which, writeScript }:

let m2h      = writeScript "man2html" "true";
    man2html = stdenv.mkDerivation {
                 name = "dummy-man2html";
                 inherit m2h;
                 buildCommand = ''
                   source $stdenv/setup

                   mkdir -p "$out/bin"
                   cp "$m2h" "$out/bin/man2html"
                 '';
               };
in stdenv.mkDerivation {
  name = "x2go-server";
  buildInputs = [ which man2html  ];
  propagatedBuildInputs = [ perl-config-simple perl ];

  inherit bash;

  src  = fetchurl {
    url    = "http://code.x2go.org/releases/source/x2goserver/x2goserver-4.0.1.19.tar.gz";
    sha256 = "1k130saz8syrgi587xzl77wlcxnkz3shhszxc23s74kr993c3m9x";
  };

  installPhase = ''
    for REGEX in '-o root -g root' '.*sudoers.d.*' '.*logcheck.*'
    do
      find . -name Makefile | xargs sed -i -e "s/$REGEX//g"
    done

    make "PREFIX=$out" "SHELL=$bash/bin/bash" "ETCDIR=$out/etc" install
  '';
}
