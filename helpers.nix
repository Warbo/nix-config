{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "34f5057";
    sha256 = "1ws5nzmv6m1gg9hs0snr8br5hlqzkn9j26rnw9h989dxd2v45h7q";
  };
}
