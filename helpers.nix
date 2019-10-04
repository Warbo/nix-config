{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "9bd9895";
    sha256 = "1car0v8kxnrwdfwxlca74yczcpxbp0zck9c5a7xr9zlpz24apwbm";
  };
}
