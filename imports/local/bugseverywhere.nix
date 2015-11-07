{ latestGit, pythonPackages, buildPythonPackage }:

buildPythonPackage {
  name = "bugseverywhere";
  version = "2014-11-28";

  # README says git://gitorious.org/be/be.git, but it's down
  src = latestGit { url = "http://chriswarbo.net/git/bugseverywhere.git"; };

  propagatedBuildInputs = [
    pythonPackages.python
    pythonPackages.wrapPython
    pythonPackages.jinja2
  ];

  meta = {
    description = "Bugs Everywhere is a distributed bugtracker, designed to complement distributed revision control systems.";
    homepage = http://bugseverywhere.org;
    repositories.git = git://gitorious.org/be/be.git;
  };
}
