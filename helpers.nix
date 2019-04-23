{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "9b687dd";
    sha256 = "1wzlyhd7j3qhx42r3qk1ijq2m12pg4j9lky48azm0ifk0blx1bnn";
  };
}
