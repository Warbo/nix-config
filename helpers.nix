{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "c4df2ca";
    sha256 = "070fa9v1cmjkm0wzi7r7cpnb3v2grj4glz4b6cg0ncdzm9dx1d0a";
  };
}
