{ fetchurl, pythonPackages }:

pythonPackages.buildPythonPackage {
  name = "python-lhafile";
  version = "0.2.1";

  src = fetchurl {
    url = http://fengestad.no/python-lhafile/python-lhafile-0.2.1.tar.gz;
    sha256 = "0pp30hkxrfx1qnrdzr40sm0y7h7w5vlwa0m7kwali2nh29rzmpfc";
  };

  propagatedBuildInputs = [
    pythonPackages.python
  ];
}
