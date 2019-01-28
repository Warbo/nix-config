{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "968d510";
    sha256 = "0j6gpl1xv1yxj34snzcvnfwm4hbgr3yh9ba169sm8597m98jyf9a";
  };
}
