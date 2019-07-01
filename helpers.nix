{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "1e76135";
    sha256 = "1x8snb1ah7lqs6bk5f92m2nx95fw9ii08b1ih1gp8rc7rjhv4sw8";
  };
}
