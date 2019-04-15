{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "ce7b333";
    sha256 = "092xp69z6iv54wkjpbk03ijm2viqbybd96k98fb7r7s3lb1sm4jk";
  };
}
