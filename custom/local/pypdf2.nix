{ latestGit, fetchurl, pythonPackages }:

pythonPackages.buildPythonPackage {
  name = "PyPdf2";

  src = latestGit {
    url    = https://github.com/mstamy2/PyPDF2.git;
    stable = {
      rev    = "b9caeed";
      sha256 = "0mi1ky1dsg69608pb4n978ddw1l9vrf3ik86lfj7d89iljg2rr4w";
    };
  };

  propagatedBuildInputs = [
    pythonPackages.python
  ];
}
