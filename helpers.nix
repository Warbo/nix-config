{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "9896285";
    sha256 = "1wb652r4vspzq717kpyfab4dwas5268hv0gx0fiszmf1c7s0srvq";
  };
}
