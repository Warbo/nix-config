{ latestGit, pythonPackages }:

pythonPackages.buildPythonPackage {
  name = "whitey";
  version = "0.4";

  src = latestGit { url = "git://github.com/rjw57/yt"; };

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
