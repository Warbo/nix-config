{ fetchFromGitHub, git, pythonPackages, shouldFail }:

with {
  plain = pythonPackages.buildPythonPackage {
    name = "airspeed-velocity";
    src  = builtins.trace "FIXME: https://github.com/spacetelescope/asv/pull/521" fetchFromGitHub {
      owner  = "Warbo";
      repo   = "asv";
      rev    = "e22664e";
      sha256 = "1x4vlgfa9rf6g4myrb5ps3dfxckalkvf8bb8byrls2xw6afvw7ll";
    };

    # For tests
    buildInputs = [
      git
      pythonPackages.virtualenv
      pythonPackages.pip
      pythonPackages.wheel
    ];

    # For resulting scripts
    propagatedBuildInputs = with pythonPackages; [ six ];
  };
};
plain.override (old: {
  stillNeedToDisableTests = shouldFail plain;
  doCheck = false;
})
