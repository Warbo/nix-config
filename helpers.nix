{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "b00d1e1";
    sha256 = "1ixl1z8w1mnaw8vc1912n3jxl6qfs1k07x1qdv30qv3n0wa1ds5j";
  };
}
