{ fetchFromGitHub, git, latestGit, pythonPackages, shouldFail }:

with {
  plain = pythonPackages.buildPythonPackage {
    name = "airspeed-velocity";
    src  = builtins.trace "FIXME: https://github.com/spacetelescope/asv/pull/521"
             latestGit { url = "https://github.com/Warbo/asv.git"; };

    # For tests
    buildInputs = [
      git
      pythonPackages.virtualenv
      pythonPackages.pip
      pythonPackages.wheel
    ];

    # For resulting scripts
    propagatedBuildInputs = [ pythonPackages.six ];
  };
};
plain.override (old: {
  stillNeedToDisableTests = shouldFail plain;
  doCheck = false;
})
