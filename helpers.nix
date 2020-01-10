{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "229959b";
    sha256 = "1lp3glkmfxyf1p0j6fy5l5227kzbza0q1p5l6rgnpxy0shbdvnc7";
  };
}
