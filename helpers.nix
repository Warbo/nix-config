{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "f3ace8b";
    sha256 = "1b63d3f7cpwh1j5cxh01ahw5aah51mk91r7kjnycaz7g0ar6fz9g";
  };
}
