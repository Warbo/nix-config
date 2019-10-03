{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "537ebf8";
    sha256 = "0vd9rkf2x47inb1nvs82m4irmadj1hjwm3gqnh3jwc0apl4kljwh";
  };
}
