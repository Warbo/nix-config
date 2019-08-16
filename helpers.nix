{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "3bbe599";
    sha256 = "04kv4p6r93kqsv49p85idr6sys2ilf3fx2f9cg7ix7xs5qag63b8";
  };
}
