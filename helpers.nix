{ fetchgit ? (import <nixpkgs> { config = {}; overlays = []; }).fetchgit }:

rec {
  inherit (import "${warbo-utilities}/helpers.nix" { inherit fetchgit; })
    nix-helpers
    warbo-packages;

  warbo-utilities = fetchgit {
    url    = http://chriswarbo.net/git/warbo-utilities.git;
    rev    = "c336695";
    sha256 = "117cgx827rhr8k4y2p9mbyp4mnfmcambhj2926k8wsv41gsfvjgh";
  };
}
