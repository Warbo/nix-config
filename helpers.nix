{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "8ccfd6d";
    sha256 = "0iiw447ifya0fmhm346zifdfvnfnv0lr6nnncd4jb3dmrxasm4sl";
  };
}
