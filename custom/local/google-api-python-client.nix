{ fetchurl, pythonPackages, uritemplate }:

pythonPackages.buildPythonPackage {
  name = "google-api-python-client";
  version = "1.4.2";

  src = fetchurl {
    url    = https://pypi.python.org/packages/source/g/google-api-python-client/google-api-python-client-1.4.2.tar.gz;
    sha256 = "1vl8kayxzd66scpx4d7mv9r4jz54kmsby7pafppx3xdhjz3wrmrc";
  };

  propagatedBuildInputs = [
    pythonPackages.python
    pythonPackages.six
    uritemplate
    pythonPackages.httplib2
    pythonPackages.oauth2client
  ];
}
