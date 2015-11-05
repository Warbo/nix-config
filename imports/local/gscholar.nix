{ fetchurl, pythonPackages, buildPythonPackage, poppler_utils }:

buildPythonPackage {
  name = "gscholar";
  version = "2015-10-27";

  src = fetchurl {
    url = https://pypi.python.org/packages/source/g/gscholar/gscholar-1.3.0.tar.gz;
    sha256 = "0mq7ibqc28pfsw6abxip530lf4535lz83whqybr6mkf1f2ykdwfw";
  };

  propagatedBuildInputs = [
    pythonPackages.python
    poppler_utils
  ];

  preInstallPhases = [ "bins" ];

  bins = ''
    mkdir -p "$out/bin"
    cp ./gscholar/gscholar.py "$out/bin"
  '';

  meta = {
    description = "Python library to query Google Scholar.";
    homepage =  "https://github.com/venthur/gscholar";
  };
}
