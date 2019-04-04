{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "59ab647";
    sha256 = "1z5yq3sr5gfyjgxdnc4v4xgl2fg9465yjyxkz9csbykzxa7vwvbg";
  };
}
