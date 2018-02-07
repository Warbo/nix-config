{ stdenv }:

stdenv.mkDerivation {
  name = "ccd2iso";
  src  = ./ccd2iso/ccd2iso-0.3.tar.gz;
}
