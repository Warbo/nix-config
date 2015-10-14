{ stdenv, fetchurl }:

stdenv.mkDerivation {
name = "x2vnc";

src = fetchurl {
  url    = http://fredrik.hubbe.net/x2vnc/x2vnc-1.7.2.tar.gz;
  sha256 = "00bh9j3m6snyd2fgnzhj5vlkj9ibh69gfny9bfzlxbnivb06s1yw";
  };

  buildInputs = [];
}
