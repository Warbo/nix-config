{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "e7d107e";
    sha256 = "1n98kzfkxxnabxw6v9qyv6gqr6h14vwdgxm47i94zs4d975pj12i";
  };
}
