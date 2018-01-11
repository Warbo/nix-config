# Stable nixpkgs repos

with builtins;
with rec {
  # Only use the system's <nixpkgs> for essentials, e.g. fixed-output git
  # fetchers and pure utility functions.
  unstablePkgs = import <nixpkgs> { config = {}; };

  inherit (unstablePkgs)     fetchFromGitHub;
  inherit (unstablePkgs.lib) mapAttrs mapAttrs';

  nixpkgsRepo = { rev, sha256 }: fetchFromGitHub {
    inherit rev sha256;
    owner = "NixOS";
    repo  = "nixpkgs";
  };

  # Explicitly pass an empty config, to avoid loading ~/.nixpkgs/config.nix
  # and causing an infinite loop
  importPkgs = repo: import repo { config = {}; };

  repos = mapAttrs (_: nixpkgsRepo) {
    repo1603 = {
      rev    = "d231868";
      sha256 = "0m2b5ignccc5i5cyydhgcgbyl8bqip4dz32gw0c6761pd4kgw56v";
    };
    repo1609 = {
      rev    = "f22817d";
      sha256 = "1cx5cfsp4iiwq8921c15chn1mhjgzydvhdcmrvjmqzinxyz71bzh";
    };
    repo1703 = {
      rev    = "1849e69";
      sha256 = "1fw9ryrz1qzbaxnjqqf91yxk1pb9hgci0z0pzw53f675almmv9q2";
    };
    repo1709 = {
      rev    = "39cd40f";
      sha256 = "0kpx4h9p1lhjbn1gsil111swa62hmjs9g93xmsavfiki910s73sh";
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
  stableRepo    = repos.repo1603;
  stableNixpkgs = pkgSets.nixpkgs1603;

  # Allow other versions
  getNixpkgs = args: rec {
    repo = nixpkgsRepo args;
    pkgs = importPkgs repo;
  };
}
