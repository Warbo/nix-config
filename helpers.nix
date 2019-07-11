{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "dfb288f";
    sha256 = "1g3sj0wfb86ksl3l8bkp03alx6myfwdrg9552ar71sfdr56ki5bh";
  };
}
