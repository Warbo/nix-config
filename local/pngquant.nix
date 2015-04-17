{ stdenv, fetchgit, libpng }:

stdenv.mkDerivation {
  name = "pngquant";

  src = fetchgit {
    url = git://github.com/pornel/pngquant.git;
    rev = "8ed377e7a2";
    sha256 = "0m9i9yiv4zq79j8fc7s4671i1gykykq78zhr4c8pa6wjzpz2vj09";
  };

  buildInputs = [libpng];
}
