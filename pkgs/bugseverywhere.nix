{ fetchgit, pythonPackages, buildPythonPackage }:

buildPythonPackage {
  name = "bugseverywhere";
  version = "2014-11-28";

  src = fetchgit {
    url = git://gitorious.org/be/be.git;
    rev = "4980830";
    sha256 = "0xy085sfd9dy8bg1ngw9svll96xyxck2yylq7c6jw3lpg7b71if7";
  };

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
