{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "e6e26b0";
    sha256 = "1nglraf45qh7hwilww5gd5ri10y2c1gzmz0yi651z8jb6vs2cr19";
  };
}
