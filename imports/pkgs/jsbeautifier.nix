{ fetchurl, pythonPackages, buildPythonPackage }:

buildPythonPackage {
  name = "jsbeautifier";
  version = "1.5.10";

  src = fetchurl {
    url = https://pypi.python.org/packages/source/j/jsbeautifier/jsbeautifier-1.5.10.tar.gz;
    sha256 = "0crqhb3igigkpr2lyxy7kysqflm720hk6h85hphcig4vvd3lcs08";
  };

  propagatedBuildInputs = [
    pythonPackages.python
    pythonPackages.six
  ];

  meta = {
    description = "Format and de-obfuscate javascript.";
    homepage = "http://jsbeautifier.org";
  };
}
