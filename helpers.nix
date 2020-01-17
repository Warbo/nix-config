{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "67d28ae";
    sha256 = "14bw2g4wzcmfnwm4qkwl8fvp52xhg51fjrvnx479dqr9ls35v1cf";
  };
}
