{ fetchurl, pythonPackages }:

pythonPackages.buildPythonPackage {
  name = "translitcodec";
  version = "0.4.0";

  src = fetchurl {
    url = https://pypi.python.org/packages/source/t/translitcodec/translitcodec-0.4.0.tar.gz;
    sha256 = "10x6pvblkzky1zhjs8nmx64nb9jdzxad4bxhq4iwv0j4z2aqjnki";
  };

  propagatedBuildInputs = [
    pythonPackages.python
  ];

  meta = {
    description = "Unicode to 8-bit charset transliteration codec";
    homepage =  " https://pypi.python.org/pypi/translitcodec";
  };
}
