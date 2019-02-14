{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "c40058f";
    sha256 = "0r8pgwwzl7m1rmrrpjn34x8kdm5ca1sfkijmfxjbzgsx4m1qi2gc";
  };
}
