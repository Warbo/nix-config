{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

{
  nix-helpers = fetchgit {
    url    = http://chriswarbo.net/git/nix-helpers.git;
    rev    = "6227a40";
    sha256 = "077kcal167ixwjj41sqrndd5pwvyavs20h826qx3ijl2i02wmwxs";
  };

  warbo-packages = fetchgit {
    url    = http://chriswarbo.net/git/warbo-packages.git;
    rev    = "57165a5";
    sha256 = "1sgd595hf3jdz0hznkhzzw2nszdnkviwqxims7bzaf5sg5rm5pfi";
  };

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "1ad737d";
    sha256 = "14z39l3vdb8cxlhjj7xcxh1yl38rv8x0l2j832483kb0f74ncp9a";
  };
}
