{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "55e6a79";
    sha256 = "00gjlqghkfg6zdczhb4x5z2ra4pg6nadkiyrddq38kcdswjybdyv";
  };
}
