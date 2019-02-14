{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "eb0f1b5";
    sha256 = "0kzadxikamh9ff37px8kn30hbwwgymb39prrkhifwnnqcx5mzlvv";
  };
}
