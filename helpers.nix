{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "37de57c";
    sha256 = "0das7gx2i59g1p2fxf75dlxqnilys0h9ydigmw6rgkv3ycqjc48m";
  };
}
