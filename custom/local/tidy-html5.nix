{ cmake, fetchFromGitHub, hasBinary, libxslt, stdenv, withDeps }:

with rec {
  pkg = stdenv.mkDerivation {
    name = "tidy-html5";
    src = fetchFromGitHub {
      owner  = "htacg";
      repo   = "tidy-html5";
      rev    = "fbde392";
      sha256 = "1dkr27hr90kszrnzbsyqmkq25l3vaylvh59f8k7llf2mkmd7sg8s";
    };
    buildInputs = [ cmake libxslt ];
  };

  tested = withDeps [ (hasBinary pkg "tidy") ] pkg;
};
{
  pkg   = tested;
  tests = tested;
}
