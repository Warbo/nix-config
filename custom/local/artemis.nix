{ fetchFromGitHub, fetchurl, hasBinary, pythonPackages, withDeps }:

with rec {
  mercurial = pythonPackages.buildPythonPackage {
    name = "mercurial";
    src  = fetchurl {
      url    = "https://www.mercurial-scm.org/release/mercurial-4.2.1.tar.gz";
      sha256 = "182qh6d0srps2n5sydzy8n3gi78la6m0wi3846zpyyd0b8pmgmfp";
    };
  };

  untested = pythonPackages.buildPythonPackage {
    name = "artemis";
    src  = fetchFromGitHub {
      owner  = "mrzv";
      repo   = "artemis";
      rev    = "6a3d496";
      sha256 = "1xdd4ayb6jyk4w5hdq2dxbxzzk90lk21rvkhwcih8ydwwg6zrnqh";
    };
    propagatedBuildInputs = [ mercurial ];
  };

  pkg = withDeps [ (hasBinary untested "git-artemis") ] untested;
};
{
  inherit pkg;
  tests = pkg;
}
