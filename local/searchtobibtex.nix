{stdenv, fetchFromGitHub, gnumake, which, bibtool, bibclean, curl, poppler_utils}:

stdenv.mkDerivation {
  name = "searchtobibtex";
  version = "2015-10-15";
  src = fetchFromGitHub {
    rev = "c1d0467";
    owner = "atisharma";
    repo = "searchtobibtex";
    sha256 = "1sml5gzjwnrmv3g12n64v2h5mqh1favg0gq6500qdxpwp0zgnygf";
  };

  propagatedBuildInputs = [ which bibtool bibclean curl poppler_utils ];

  preConfigure = ''
    sed -i Makefile -e 's@/usr/bin/make@${gnumake}/bin/make@g'
    sed -i Makefile -e "s@/usr/local@$out@g"
  '';
}
