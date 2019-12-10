{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "9f0ef3c";
    sha256 = "1j6rlx7c5ypw0i2llgcprx835x6ksashglln3mx3bp9fxadpqplk";
  };
}
