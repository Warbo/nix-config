{ allegro, cmake, fetchurl, libogg, libpng, libvorbis, stdenv }:

stdenv.mkDerivation {
  name = "open-sonic";
  src  = fetchurl {
    url    = "mirror://sourceforge/project/opensnc/Open%20Sonic/0.1.4/opensnc-src-0.1.4.tar.gz";
    sha256 = "1sc84p24hdldl4blcvckf5a36gx8s2d8r17anl27rqlfaflkyk1s";
  };
  buildInputs  = [ allegro cmake libogg libpng libvorbis ];
  buildCommand = ''
    tar xf "$src"
    cd opensnc-src-0.1.4
    for F in ./src/core/global.h ./CMakeLists.txt
    do
      sed -i "$F" -e "s@/usr/@$out/@g"
    done
    sed -i configure -e 's@/bin/bash@/usr/bin/env bash@g'
    ./configure
    make
    make install
  '';
}
