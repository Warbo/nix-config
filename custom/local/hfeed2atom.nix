{ beautifulsoup-custom, fetchFromGitHub, fetchurl, mf2py, pythonPackages }:

pythonPackages.buildPythonPackage {
  name = "hfeed2atom";

  src = fetchFromGitHub {
    owner  = "kartikprabhu";
    repo   = "hfeed2atom";
    rev    = "214b4c6";
    sha256 = "1p8srrszaj6dxr4xjl0hp71qh1q0irqgkdahynsmilhpylcdqxsr";
  };

  propagatedBuildInputs = [
    pythonPackages.python
    beautifulsoup-custom
    mf2py
  ];
}
