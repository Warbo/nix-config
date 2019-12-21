{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "7087c3b";
    sha256 = "1w8b95w5fzn2dm7rlw1lpn8h7jd9r9ndngzwqyr4j37mxi4vlrfw";
  };
}
