{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "bb066e5";
    sha256 = "1via9zspg1plxr1601x4xp019hxx4bmh7lizd7x0wgmjypgpinl0";
  };
}
