{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "7013b41";
    sha256 = "16h9b5fsk6k9pz84dhfl1wbc4xllwp3nvqbm6jlk2m27ymzram1d";
  };
}
