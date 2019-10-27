{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "f1a1246";
    sha256 = "0ccsswanp76i4ipjdfsb8qadrbjhzrzi6wv4hksa6l7pmkccm73q";
  };
}
