{ fetchFromGitHub, mf2py, pythonPackages, buildPythonPackage }:

buildPythonPackage {
  name = "hfeed2atom";

  src = fetchFromGitHub {
    owner  = "kartikprabhu";
    repo   = "hfeed2atom";
    rev    = "214b4c6";
    sha256 = "1p8srrszaj6dxr4xjl0hp71qh1q0irqgkdahynsmilhpylcdqxsr";
  };

  propagatedBuildInputs = [
    pythonPackages.python
    mf2py
  ];
}
