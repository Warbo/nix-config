{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "3b80391";
    sha256 = "07gl6fqfjlg5nj12pgjqavx9apkql30ifpaqw9r26jrh90s5k9qk";
  };
}
