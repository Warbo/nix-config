{ fetchurl, pythonPackages, buildPythonPackage }:

buildPythonPackage {
  name = "subdist";
  version = "0.2.1";

  src = fetchurl {
    url = https://pypi.python.org/packages/source/s/subdist/subdist-0.2.1.tar.gz;
    sha256 = "13z3qrlyfkbzqy9gcsh8w9rwy0zk0w52cl3spdwgzjv46zh1gkvc";
  };

  unpackPhase = ''
    mkdir subdist
    cd subdist
    tar xf "$src"
  '';

  propagatedBuildInputs = [
    pythonPackages.python
  ];

  meta = {
    description = "Substring edit distance";
    homepage =  "https://pypi.python.org/pypi/subdist/0.2.1";
  };
}
