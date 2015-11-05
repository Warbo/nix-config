{ stdenv, fetchurl }:

stdenv.mkDerivation {
  name = "bibclean";

  src = fetchurl {
    url    = http://ftp.math.utah.edu/pub/bibclean/bibclean-2.17.tar.bz2;
    sha256 = "0xbarljc1qzznawmr0sifzh1mxm19hv61jav6zwijbjc1dk4fh7l";
  };

  preInstall = ''
    mkdir -p "$out/bin"
    mkdir -p "$out/man/man1"
  '';
}
