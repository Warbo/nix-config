{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "e86abe1";
    sha256 = "05w0hzls8sis5lz1vcsgaqkyw06yiallr65j75ymkb4zn38n1rsm";
  };
}
