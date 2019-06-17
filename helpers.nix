{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "596c748";
    sha256 = "13npxrs7r58k0vg0qzzfpn9rk04vlj8wk7r9wafmj6qc88z0gdfb";
  };
}
