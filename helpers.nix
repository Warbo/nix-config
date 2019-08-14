{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "03b725b";
    sha256 = "08g839b6rk1qmaxn4bingl4qwifmri20b1c7q07lm8c8dvhm0pn8";
  };
}
