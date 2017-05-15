{ fetchurl, jq, pythonPackages }:

pythonPackages.buildPythonPackage {
  name = "yq";
  src  = fetchurl {
    url    = https://pypi.python.org/packages/14/1b/5efddd608b7df9849be50aca4a0d8602b75fb2929223a44e241d7290d6ea/yq-2.1.1.tar.gz;
    sha256 = "0g7rbmfn7k4rz77iqg29kp24fjpl678gy1g17hx435sdwjns00pd";
  };
  propagatedBuildInputs = with pythonPackages; [
    jq
    pyyaml
  ];
}
