{ stdenv, fetchFromGitHub, cmake, libxslt }:

stdenv.mkDerivation {
  name = "tidy-html5";
  src = fetchFromGitHub {
    owner  = "htacg";
    repo   = "tidy-html5";
    rev    = "fbde392";
    sha256 = "1dkr27hr90kszrnzbsyqmkq25l3vaylvh59f8k7llf2mkmd7sg8s";
  };
  buildInputs = [ cmake libxslt ];
}
