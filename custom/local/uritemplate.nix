{ fetchurl, pythonPackages }:

pythonPackages.buildPythonPackage {
  name = "uritemplate";
  version = "0.6";

  src = fetchurl {
    url    = https://pypi.python.org/packages/source/u/uritemplate/uritemplate-0.6.tar.gz;
    sha256 = "1zapwg406vkwsirnzc6mwq9fac4az8brm6d9bp5xpgkyxc5263m3";
  };

  propagatedBuildInputs = [
    pythonPackages.python
    pythonPackages.simplejson
  ];
}
