{ latestGit, fetchurl, pythonPackages, buildPythonPackage, pypdf2 }:

buildPythonPackage {
  name = "xhtml2pdf";

  src = latestGit {
    url = https://github.com/xhtml2pdf/xhtml2pdf.git;
  };

  propagatedBuildInputs = [
    pythonPackages.python
    pythonPackages.reportlab
    pythonPackages.pillow
    pythonPackages.html5lib
    pythonPackages.pip
    pypdf2
  ];
}
