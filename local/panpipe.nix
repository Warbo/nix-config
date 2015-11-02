{haskellPackages, fetchgit}:

haskellPackages.callPackage (fetchgit {
  name   = "panpipe";
  url    = http://chriswarbo.net/git/panpipe.git;
  rev    = "c37a8a15e36bc3591e33f9b1dc73f70e18fa850d";
  sha256 = "02fpl2rk6d2cvqf7z6a080v7l014ljkwgyq3xd821vxfknnpbkvs";
}) {};
