{ fetchurl, pythonPackages, buildPythonPackage, uritemplate }:

buildPythonPackage {
  name = "google-api-python-client";
  version = "1.4.2";

  src = fetchurl {
    url = https://pypi.python.org/packages/source/g/google-api-python-client/google-api-python-client-1.4.2.tar.gz;
    md5 = "7033985a645e39d3ccf1b2971ab7b6b8";
  };

  propagatedBuildInputs = [
    pythonPackages.python
    pythonPackages.six
    uritemplate
    pythonPackages.httplib2
    pythonPackages.oauth2client
  ];
}
