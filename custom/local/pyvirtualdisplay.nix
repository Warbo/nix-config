{ fetchurl, pythonPackages, buildPythonPackage, easyprocess }:

buildPythonPackage {
  name = "pyvirtualdisplay";
  version = "0.2";

  src = fetchurl {
    url = https://pypi.python.org/packages/ce/df/9ab299661784d36e1da9f025d904e96a9a223813be97970277cbb1ca1a04/PyVirtualDisplay-0.2.tar.gz;
    sha256 = "117db6gc1cip0r1dxc9vyakqr5039hjh62s9v2d6nys80ixq5w4b";
  };

  propagatedBuildInputs = [
    pythonPackages.python
    easyprocess
  ];
}
