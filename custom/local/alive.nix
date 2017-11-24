{ fetchFromGitHub, stdenv }:

stdenv.mkDerivation {
  name = "alive-engine";
  src  = fetchFromGitHub {
    owner  = "paulsapps";
    repo   = "alive";
    rev    = "3597acb";
    sha256 = "142dxipzf341x7b324scxxdc7p2kfzrac7dgi8asmn00p3z0238m";
  };
}
