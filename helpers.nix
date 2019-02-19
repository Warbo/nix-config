{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "5ba1b86";
    sha256 = "1dc4ch7bcmknmfnchqzsl1nqk04l58n9rkxmg411a7rgbgkdc307";
  };
}
