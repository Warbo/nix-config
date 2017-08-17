# Stable nixpkgs
self: super:

with builtins;
with super.lib;
with rec {
  nixpkgsRepo = { rev, sha256 }:
    super.fetchFromGitHub {
      inherit rev sha256;
      owner = "NixOS";
      repo  = "nixpkgs";
    };

  # Explicitly pass an empty config, to avoid loading ~/.nixpkgs/config.nix
  # and causing an infinite loop
  importPkgs = repo: import repo { config = {}; };

  repos = mapAttrs (_: nixpkgsRepo) {
    repo1603 = {
      rev    = "16.03";
      sha256 = "0m2b5ignccc5i5cyydhgcgbyl8bqip4dz32gw0c6761pd4kgw56v";
    };
    repo1609 = {
      rev    = "16.09";
      sha256 = "0m2b5ignccc5i5cyydhgcgbyl8bqip4dz32gw0c6761pd4kgw56v";
    };
    repo1703 = {
      rev    = "17.03";
      sha256 = "1fw9ryrz1qzbaxnjqqf91yxk1pb9hgci0z0pzw53f675almmv9q2";
    };
  };

  loadRepo = n: v: {
    name  = replaceStrings [ "repo" ] [ "nixpkgs" ] n;
    value = importPkgs v;
  };

  pkgSets = mapAttrs' loadRepo repos;
};

repos // pkgSets // {
  # "Blessed" versions
  stableRepo = repos.repo1603;
  stable     = pkgSets.nixpkgs1603;

  # Allow other versions
  getNixpkgs = args: rec {
    repo = nixpkgsRepo args;
    pkgs = importPkgs repo;
  };
}
