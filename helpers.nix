{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "f1b4c1c";
    sha256 = "1is38gh6ga880bnm3iys33n28aps7fs2b7zjmdmiiwc7zr7bfcc7";
  };
}
