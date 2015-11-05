{ fetchgit, pythonPackages, buildPythonPackage }:

buildPythonPackage {
  name = "whitey";
  version = "0.4";

  src = fetchgit {
    url    = "git://github.com/rjw57/yt";
    rev    = "dae8c4d959";
    sha256 = "18lkpjmqh5r2dwn1b1ik02gy9vh8m9s5jfvk9zvgd7m2c3gg9gqb";
  };

  propagatedBuildInputs = [
    pythonPackages.python
    pythonPackages.curses
  ];

  meta = {
    homepage = "https://pypi.python.org/pypi/whitey";
    repositories.git = https://github.com/rjw57/yt.git;
    description = "Command-line interface for YouTube.com";
  };
}
