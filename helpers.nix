{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "5042762";
    sha256 = "020yzrdxzvmbrpkfpxf1i0w9ilc5858iv7vrwmh6lrl5ckkhm4ck";
  };
}
