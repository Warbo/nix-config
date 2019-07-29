{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "f3fdbb6";
    sha256 = "1rc0law882dd8d2mwdw51xfrrym6az7f2cbbsmazl8hxhrri54kj";
  };
}
