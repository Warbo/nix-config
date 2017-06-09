{ fetchFromGitHub, fetchurl, pythonPackages }:

with rec {
  src = fetchFromGitHub {
    owner  = "mrzv";
    repo   = "artemis";
    rev    = "0744562";
    sha256 = "0jz33hmqjwz7fbmfmsb4qmpskz4rhddc7i9pf6na9zslz5c7i3fq";
  };

  mercurial = pythonPackages.buildPythonPackage {
    name = "mercurial";
    src  = fetchurl {
      url    = "https://www.mercurial-scm.org/release/mercurial-4.2.1.tar.gz";
      sha256 = "182qh6d0srps2n5sydzy8n3gi78la6m0wi3846zpyyd0b8pmgmfp";
    };
  };

  pyPkg = pythonPackages.buildPythonPackage {
    inherit src;
    name = "artemis";
    propagatedBuildInputs = with pythonPackages; [
      mercurial
    ];
  };
};
pyPkg
