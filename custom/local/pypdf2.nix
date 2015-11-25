{ latestGit, fetchurl, pythonPackages, buildPythonPackage }:

buildPythonPackage {
  name = "PyPdf2";

  src = latestGit {
    url = https://github.com/mstamy2/PyPDF2.git;
  };

  propagatedBuildInputs = [
    pythonPackages.python
  ];
}
