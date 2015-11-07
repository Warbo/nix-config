{ stdenv, latestGit, libpng, which, zlib }:

stdenv.mkDerivation {
  name = "pngquant";

  src = latestGit { url = git://github.com/pornel/pngquant.git; };

  buildInputs = [ libpng which zlib ];
}
