{ fetchurl, pythonPackages, buildPythonPackage }:

buildPythonPackage {
  name = "linkchecker";
  version = "2014-11-28";

  src = fetchurl {
    url = https://pypi.python.org/packages/source/L/LinkChecker/LinkChecker-9.3.tar.gz;
    sha256 = "0v8pavf0bx33xnz1kwflv0r7lxxwj7vg3syxhy2wzza0wh6sc2pf";
  };

  propagatedBuildInputs = [
    pythonPackages.python
    pythonPackages.requests2
  ];

  meta = {
    description = "LinkChecker checks links in web documents or full websites.";
    homepage =  "http://wummel.github.io/linkchecker";
  };
}
