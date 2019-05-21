{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "fbe99a1";
    sha256 = "0gwrn2r4vmbxxnllp86y56n1qj2p0jm71bwlimh9cmyrazk0n7wq";
  };
}
