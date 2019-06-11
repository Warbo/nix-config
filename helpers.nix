{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "ee467ff";
    sha256 = "0jp06x72sbd2kbf7spi0gybh9jvrylaipbl81748w8z4sp7w6ph1";
  };
}
