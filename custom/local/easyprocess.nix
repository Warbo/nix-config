{ fetchurl, pythonPackages, buildPythonPackage }:

buildPythonPackage {
  name    = "easyprocess";
  version = "0.2";

  src = fetchurl {
    url = https://pypi.python.org/packages/3b/e5/5206a28308b5e7dbb9119b9d7e65d7d92fd23de0fc9756332efab81fce87/EasyProcess-0.2.tar.gz;
    md5 = "0635ff90fb7863f1a58bc3da94523aaf";
  };

  propagatedBuildInputs = [
    pythonPackages.python
  ];
}
