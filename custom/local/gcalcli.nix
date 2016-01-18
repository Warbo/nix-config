{ fetchurl, pythonPackages, buildPythonPackage, google-api-python-client }:

buildPythonPackage {
  name = "gcalcli";
  version = "3.3.2";

  src = fetchurl {
    url = https://pypi.python.org/packages/source/g/gcalcli/gcalcli-3.3.2.tar.gz;
    sha256 = "0yw60zgh2ski46mxsyncwx4bb6zzrfp5bn91hg0xyvmz71339mkj";
  };

  propagatedBuildInputs = [
    pythonPackages.python
    pythonPackages.gflags
    pythonPackages.dateutil
    pythonPackages.vobject
    pythonPackages.parsedatetime
    pythonPackages.httplib2
    pythonPackages.oauth2client
    google-api-python-client
  ];
}
