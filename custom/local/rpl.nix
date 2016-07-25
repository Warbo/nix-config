{ stdenv, fetchurl, file, python }:

stdenv.mkDerivation {
  name = "rpl";
  src  = fetchurl {
    url    = "mirror://sourceforge/rpl/rpl-1.5.5.tar.gz";
    sha256 = "1b02kk41i12798bm4cs7z37lsmicf95pzbqwlls3yrzl3xpqgfsf";
  };
  propagatedBuildInputs = [ python ];
  buildInputs = [ file ];
  installPhase = ''
    mkdir -p "$out/bin"
    cp rpl "$out/bin"
  '';
}
