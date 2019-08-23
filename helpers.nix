{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "1a5152e";
    sha256 = "0lcvbv6mbknyfsjs7748ljb6xvkrr75vn8s7w99ymm2ly9fyq9zs";
  };
}
