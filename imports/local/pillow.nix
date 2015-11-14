{ fetchurl, pythonPackages, buildPythonPackage, libjpeg }:

buildPythonPackage {
  name = "xhtml2pdf";

  src = fetchurl {
    url = "https://pypi.python.org/packages/source/P/Pillow/Pillow-3.0.0.tar.gz";
    md5 = "fc8ac44e93da09678eac7e30c9b7377d";
  };

  propagatedBuildInputs = [
    pythonPackages.python
    libjpeg
  ];

  setupPyInstallFlags = [ "--disable-jpeg" ];
}
