{ fetchurl, pythonPackages }:

pythonPackages.buildPythonPackage {
  name = "uritemplate";
  version = "0.6";

  src = fetchurl {
    url = https://pypi.python.org/packages/source/u/uritemplate/uritemplate-0.6.tar.gz;
    md5 = "ecfc1ea8d62c7f2b47aad625afae6173";
  };

  propagatedBuildInputs = [
    pythonPackages.python
    pythonPackages.simplejson
  ];
}
