{ fetchFromGitHub, git, latestGit, pythonPackages, shouldFail }:

with {
  plain = pythonPackages.buildPythonPackage {
    name = "airspeed-velocity";
    src  = fetchFromGitHub {
      owner  = "spacetelescope";
      repo   = "asv";
      rev    = "13559be";
      sha256 = "1d4s1j08ky37wpa26r50cdkkw6k4szmfza7adwxi7r70rb3m3yk2";
    };

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
