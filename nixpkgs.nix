# Stable nixpkgs repos
{ defaultVersion }:

with builtins;
with rec {
  knownNames = [ "unstable" ] ++ attrNames repoData ++
               map swapName (attrNames repoData);

  unstablePath = if elem defaultVersion knownNames
                    then <nixpkgs>
                    else defaultVersion;

  # Only use the system's <nixpkgs> for essentials, e.g. fixed-output git
  # fetchers and pure utility functions.
  unstablePkgs = import unstablePath { config = {}; };

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

  repos = mapAttrs (_: nixpkgsRepo) repoData;

  repoData = {
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
    repo1803 = {
      rev    = "94d80eb";
      sha256 = "1l4hdxwcqv5izxcgv3v4njq99yai8v38wx7v02v5sd96g7jj2i8f";
    };
  };

  swapName = n: replaceStrings [ "repo" ] [ "nixpkgs" ] n;

  loadRepo = n: v: {
    name  = swapName n;
    value = importPkgs v;
  };

  pkgSets = mapAttrs' loadRepo repos;
};

repos // pkgSets // {
  # Allow other versions
  getNixpkgs = args: rec {
    repo = nixpkgsRepo args;
    pkgs = importPkgs repo;
  };
}
