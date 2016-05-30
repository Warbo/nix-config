{ autoconf, automake, intltool, stdenv, fetchurl, glib }:

stdenv.mkDerivation {
  name = "pcsxr";
  buildInputs = [ autoconf automake glib intltool ];
  src = /home/chris/System/Programs/pcsxr-1.9.93.tar.bz2;
  configurePhase = ''
    ./autogen.sh
    ./configure
  '';
}
