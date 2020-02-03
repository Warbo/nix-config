{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "9934f6d";
    sha256 = "1qcc8w8077k8j2zhzxkvh9d5j3613pgw7jwj9wq8lj95bbnd7q7f";
  };
}
