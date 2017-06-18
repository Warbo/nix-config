{ fetchFromGitHub, git, pythonPackages }:

pythonPackages.buildPythonPackage {
  name = "airspeed-velocity";
  src  = fetchFromGitHub {
    owner  = "spacetelescope";
    repo   = "asv";
    rev    = "953c960";
    sha256 = "10fissqb3fzqs94c9b0rzd9gk1kxccn13bfh22rjih4z9jdfh113";
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
}
