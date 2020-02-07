{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "8d5f71c";
    sha256 = "06x5z0zi0b2rypvdklkxp0r49ki2rb6jz446lwfvifph19vgrs1w";
  };
}
