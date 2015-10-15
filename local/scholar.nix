{fetchFromGitHub, stdenv, pythonPackages }:

stdenv.mkDerivation {
  name = "scholar.py";
  version = "2015-10-15";

  src = fetchFromGitHub {
    rev    = "3f889d";
    owner  = "ckreibich";
    repo   = "scholar.py";
    sha256 = "0haamzjjrz65wzv34lfccwl0vxpwk303q0gz9xif0qmljvp5a716";
  };

  propagatedBuildInputs = [
    pythonPackages.python
    pythonPackages.beautifulsoup
  ];

  installPhase = ''
    mkdir -p "$out/bin"
    cp scholar.py "$out/bin/"

    mkdir -p "$out/share/doc/scholar.py"
    cp README.md "$out/share/doc/scholar.py"
  '';
}
