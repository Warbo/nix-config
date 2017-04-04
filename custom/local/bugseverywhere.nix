{ bash, buildPythonPackage, latestGit, git, pythonPackages, repoSource }:

let repo = "${repoSource}/bugseverywhere.git";
 in buildPythonPackage {
  name = "bugseverywhere";
  version = "2014-11-28";

  # README says git://gitorious.org/be/be.git, but don't rely on that since
  # gitorious is no more
  src = latestGit { url = repo; };

  preConfigure = ''
    git clone "${repo}" TEMP
    pushd TEMP
    make SHELL="${bash}/bin/bash" libbe/_version.py
    popd
    mv -v TEMP/libbe/_version.py libbe/
    rm -rf TEMP
  '';

  propagatedBuildInputs = [
    pythonPackages.python
    pythonPackages.wrapPython
    pythonPackages.jinja2
    git
  ];

  meta = {
    description = "Bugs Everywhere is a distributed bugtracker, designed to complement distributed revision control systems.";
    homepage = http://bugseverywhere.org;
    repositories.git = git://gitorious.org/be/be.git;
  };
}
