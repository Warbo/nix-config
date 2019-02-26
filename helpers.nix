{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "69a82fb";
    sha256 = "09251lcbq4yf5snjkzb80lxi6xbkpj2imb01ms6bjpv6wi0vwar5";
  };
}
