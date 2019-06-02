{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "058683c";
    sha256 = "0nxq3anlsby0sg31nhzyyj6l7vksscfpwqm0d3ssj8g17vhnn9ch";
  };
}
