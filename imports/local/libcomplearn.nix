{ stdenv, latestGit, autoconf, automake, libtool, zlib, check, pkgconfig }:

stdenv.mkDerivation {
  name = "libcomplearn";
  src = latestGit {
    url = "https://github.com/rudi-cilibrasi/libcomplearn.git";
  };
  preConfigure = ''
    ./autogen
  '';
  buildInputs = [ autoconf automake libtool zlib check pkgconfig ];
}
