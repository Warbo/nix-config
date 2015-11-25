{stdenv, fetchFromGitHub}:

stdenv.mkDerivation {
  name    = "bibtool";
  version = "2015-10-28";
  src     = fetchFromGitHub {
    repo   = "bibtool";
    owner  = "ge-ne";
    rev    = "62c6745";
    sha256 = "0a2q1k974swxw6lqvxg8i9jj9jxxsyrrp4vlp8qg7rgkfkdyfnmq";
  };
}
