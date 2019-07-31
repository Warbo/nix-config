{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "f460be4";
    sha256 = "0f16h4ba4nmaw758wivqwi4ifirivd5ldmx3fivzvrf9dgk4nbzk";
  };
}
