{ fetchurl, python3Packages, buildPythonPackage, python-lhafile, gettext, fs-uae }:

let name    = "fs-uae-launcher";
    version = "2.6.2";
in python3Packages.buildPythonPackage {
  inherit name version;

  src = fetchurl {
    url = "http://fs-uae.net/fs-uae/stable/${version}/fs-uae-launcher-${version}.tar.gz";
    sha256 = "0yf3if9zqwq40cakbb4fj0jvlqmvdiqx7k5cdv7353d4537pzkb0";
  };

  buildInputs = [ gettext ];
  propagatedBuildInputs = [
    python3Packages.python
    python3Packages.pyqt5
    python-lhafile
    fs-uae
  ];
  installFlags = "prefix=$(out)";
}
