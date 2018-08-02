{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

{
  nix-helpers = fetchgit {
    url    = http://chriswarbo.net/git/nix-helpers.git;
    rev    = "72d9d88";
    sha256 = "1kggqr07dz2widv895wp8g1x314lqg19p67nzr3b97pg97amhjsi";
  };

  warbo-packages = fetchgit {
    url    = http://chriswarbo.net/git/warbo-packages.git;
    rev    = "fadf087";
    sha256 = "0z4jk3wk9lhlq3njr22wsr9plf5fw7mmpbky8l8ppn0gp698vq63";
  };

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "1ad737d";
    sha256 = "14z39l3vdb8cxlhjj7xcxh1yl38rv8x0l2j832483kb0f74ncp9a";
  };
}
