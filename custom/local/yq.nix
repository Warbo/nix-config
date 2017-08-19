{ fetchurl, getNixpkgs, jq }:

# Requires setuptools >= 30, so we use a fixed nixpkgs version
with getNixpkgs {
  rev    = "4b0afc1";
  sha256 = "1yz3giqiza9xcblaiz1ic8a7fyhll0ngxy9nm04phyxd0nrdfn6b";
};
pkgs.pythonPackages.buildPythonPackage {
  name = "yq";
  src  = fetchurl {
    url    = https://pypi.python.org/packages/14/1b/5efddd608b7df9849be50aca4a0d8602b75fb2929223a44e241d7290d6ea/yq-2.1.1.tar.gz;
    sha256 = "0g7rbmfn7k4rz77iqg29kp24fjpl678gy1g17hx435sdwjns00pd";
  };
  propagatedBuildInputs = [
    jq
    pkgs.pythonPackages.pyyaml
  ];
}
