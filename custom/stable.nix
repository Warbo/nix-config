# Stable nixpkgs
self: super:

rec {
  stableRepo = super.fetchFromGitHub {
    owner  = "NixOS";
    repo   = "nixpkgs";
    rev    = "16.03";
    sha256 = "0m2b5ignccc5i5cyydhgcgbyl8bqip4dz32gw0c6761pd4kgw56v";
  };

  # Explicitly pass an empty config, to avoid loading ~/.nixpkgs/config.nix and
  # causing an infinite loop
  stable = import stableRepo { config = {}; };

  origPkgs = super;
}
