{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "1a92df0";
    sha256 = "1fycdvzlgbpwjl23zq1jh1vmzryc3hbwpnkgc7wkaacpcxkbmsqq";
  };
}
