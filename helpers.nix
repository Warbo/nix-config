{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "517befa";
    sha256 = "1nbvllbl14dn0cvgxywj7lj9kzl9icv61db6qbb1f2xvgxzpmqb3";
  };
}
