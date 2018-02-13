{ fetchFromGitHub, pkgHasBinary, python3Packages, stdenv }:

pkgHasBinary "bibcheck"
  (python3Packages.buildPythonPackage {
    name = "bibcheck";
    version = "2015-10-22";
    src = fetchFromGitHub {
      owner = "rmcgibbo";
      repo = "bibcheck";
      rev = "792afe0";
      sha256 = "1gajxdz9j64qixiib8wyyfgm2kyjyv9ix3mmcdkrab9nnbxkwzfz";
    };
    propagatedBuildInputs = [
      python3Packages.python
      python3Packages.six
    ];
  })
