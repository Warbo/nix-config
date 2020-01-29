{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "35e2f66";
    sha256 = "13x7v5d0qd9kd0slb9552prlp4n7zxkvwahr115q6n9gm5ki6b46";
  };
}
